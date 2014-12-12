function [trcksold, trcks, Amats, edge_xi, edge_xj, edge_pairs, nedgs, ndets] = maxflow_fullvid( xs, Amats, frids, ntrcks, scndordr, addextraconstraints, alldets )
% function [trcksold, trcks] = maxflow_fullvid( xs, Amats, frids, ntrcks, scndordr, % addextraconstraints )
% Input
% xs - matrix nx5 of individual detections and confidences. Each row is structured as [minx miny maxx maxy conf]
% Amats - cell (nx1) 1 for each "shot". Corresponding to each shot is an adjacency matrix.
% frids - frame number of individual detections.
% ntrcks - number of tracks to be detected.
% scndordr - add second order constraints, on the motion of the tracks within and across each track.
%			Within track motion makes sure that each track is more or less in a straight line.
%			Across track motion makes sure that two tracks move parallely to each other.
% addextraconstraints - adds extra constraints with scndordr so as to steer the minimization into an 
%						integer solution direction.

if nargin < 5
	scndordr = 0 ; % by default second order constraints are turned OFF.
	addextraconstraints = 0 ; % if second order constraints are not added, no need for extra 
								% constraints.
elseif (nargin < 6) || (~scndordr)
	addextraconstraints = 0 ;
end

nFrames = max(frids)-min(frids)+1 ; % Number of frames to be processed.

% Preprocessing, convert all Amats to upper triangular matrices and slightly change the 
% values of the matrices (change edge weights) based on detection confidences + relative sizes of
% the detection boxes.
Amats = edge_preprocessing( Amats, frids, xs ) ;

x0 = [] ;
options = cplexoptimset( 'cplex' ) ;
% options = mskoptimset( 'Display', 'iter' ) ;
options = cplexoptimset( options, 'diagnostics', 'on', 'lpmethod', 2 ) ;

% Two sets of constraints need to be added for this minimization to work.
% 1 Flow conservation constraints taht are generally  equality constraints.
% 2 Capacity constraints that are generally 1 per edge and are inequality constraints.
% If additional constraints are added they will be of two types.
% 1 Second order constraints that are generally inequality constraints.
% 2 Additional constraints that are also inequality constraints.
ndets = size( xs, 1 ) ; % Number of detections.
[nedgs, edge_indices, edge_xi, edge_xj] = collect_all_edges( Amats, xs ) ;

% If second order constraints are added, new set of variables need to be introduced.
if scndordr
	% This function computes the various pairs that are either coincidental (in case of the same track) 
	% or parallel (in case of different tracks).
	[edge_npairs, edge_pairs] = compute_parallel_pairs( Amats, frids, xs ) ;
else
	edge_npairs = 0 ;
	edge_pairs = [] ;
end

nvars = nedgs + 3 * ndets + edge_npairs ;
% Variables are arranged as before
% [edges virtual-edges]
% where edges could be replaced with 1s for traditional maxflow and virtual-edges
% are for 
% 1 connecting all nodes to source.
% 2 connecting all nodes to sink.
% 3 duplicating each node to two and putting an edge of length in between.
% virtual-edges are arranged in the following order.
% [edges 3, edges 1, edges 2]
% c = [round(Amat(idxs)*10); ones(3*ndets,1)] ; 
c = ones(nvars, 1) ;
% Now add lower and upper limits for the values of each variable.
xl = zeros(nvars, 1) ;
xu = ones(nvars, 1) ;
[min(cat(1, cell2mat(edge_indices))) max(cat(1, cell2mat(edge_indices)))] 
c(1:nedgs) = 5 * cat(1, cell2mat(edge_indices)); % concatenate all the scores of edges.
	% Each edge has to be *boosted* by the number of Frames, otherwise it would be beneficial to
	% pick longer tracks with weak edges than shorter tracks with strong edges.
c((nedgs+1):(nedgs+ndets)) = xs(:, 5) ; % No need to give importance to how many links we are adding.

% First add equality constraints. 2 constraint per node.
%% Aeq = sparse( 2*ndets+2, nvars ) ; % sparse initializes all the values to 0.
beq = zeros( 2*ndets+2, 1 ) ;

tic ;
neqconstraints = 0 ;
neqvars = 0 ;

Aeq_data = zeros( 3e7, 3 ) ;
Aeq_data(:, 3) = 1 ;
Aeq_data( 1:(2*ndets), 3 ) = -1 ;
Aeq_data( 1:ndets, 1 ) = 2*(1:ndets) - 1 ;
Aeq_data( 1:ndets, 2 ) = nedgs + (1:ndets) ;
Aeq_data( (ndets+1):(2*ndets), 1 ) = 2*(1:ndets) ;
Aeq_data( (ndets+1):(2*ndets), 2 ) = nedgs + (1:ndets) ;
Aeq_data( (2*ndets+1):(3*ndets), 1 ) = 2*(1:ndets) - 1 ;
Aeq_data( (2*ndets+1):(3*ndets), 2 ) = nedgs+ndets+(1:ndets) ;
Aeq_data( (3*ndets+1):(4*ndets), 1 ) = 2*(1:ndets) ;
Aeq_data( (3*ndets+1):(4*ndets), 2 ) = nedgs+2*ndets+(1:ndets) ;
cntr = 4 * ndets ;

for i = 1 : nedgs
	Aeq_data( cntr+1, 1 ) = 2*edge_xj(i)-1 ;
	Aeq_data( cntr+1, 2 ) = i ;
	cntr = cntr + 1 ;
	Aeq_data( cntr+1, 1 ) = 2*edge_xi(i) ;
	Aeq_data( cntr+1, 2 ) = i ;
	cntr = cntr + 1 ;
end

Aeq_data( (cntr+1):(cntr+ndets), 1 ) = 2*ndets+1 ;
Aeq_data( (cntr+1):(cntr+ndets), 2 ) = nedgs+ndets+(1:ndets) ;
cntr = cntr + ndets ;
Aeq_data( (cntr+1):(cntr+ndets), 1 ) = 2*ndets+2 ;
Aeq_data( (cntr+1):(cntr+ndets), 2 ) = nedgs+2*ndets+(1:ndets) ;
cntr = cntr + ndets ;
% Aeq_data( cntr+1, 1 ) = 2*ndets+1 ;
% Aeq_data( cntr+1, 2 ) = 
beq((2*ndets+1):(2*ndets+2)) = ntrcks ;

save('pets_s2l2heads2.mat', 'xs', 'frids', 'edge_xi', 'edge_xj', 'nedgs', 'ndets', 'ntrcks', 'nvars', 'edge_indices', 'Amats', 'alldets','-v7.3' ) ;
fprintf('Finished saving\n') ;
keyboard ;

%% for i = 1 : ndets
%% 	if toc > 10
%% 		fprintf( 'Flow Conservation: Constraint Number %d\n', i ) ;
%% 		tic ;
%% 	end
%% 	% Find all the edges where the right-hand-side is detection i, so edges in previous frame.
%% 	leftidx = find( edge_xj == i ) ;
%% 	% Find all the edges where the left-hand-side is detection i, so edges in next frame.
%% 	rightidx = find( edge_xi == i ) ;
%% 	Aeq(2*i-1, leftidx) = 1 ;
%% 	Aeq(2*i-1, nedgs+ndets+i) = 1 ;
%% 	Aeq(2*i-1, nedgs+i) = -1 ;
%% 	neqvars = neqvars + length(leftidx)+2 ;
%% 
%% 	Aeq(2*i, rightidx) = 1 ;
%% 	Aeq(2*i, nedgs+2*ndets+i) = 1 ;
%% 	Aeq(2*i, nedgs+i) = -1 ;
%% 	neqvars = neqvars + length(rightidx)+2 ;
%% 	neqconstraints = neqconstraints+2 ;
%% end
%% % Now add source and sink equality constraints
%% Aeq(2*ndets+1, (nedgs+ndets+1):(nedgs+2*ndets)) = 1 ;
%% beq(2*ndets+1) = ntrcks ;
%% Aeq(2*ndets+2, (nedgs+2*ndets+1):(nedgs+3*ndets)) = 1 ;
%% beq(2*ndets+2) = ntrcks ;

Aeq = sparse( Aeq_data(1:cntr, 1), Aeq_data(1:cntr, 2), Aeq_data(1:cntr, 3), 2*ndets+2, nvars ) ;

fprintf( 'Flow Conservation: Total number of variables: %d\n', nvars ) ;
fprintf( 'Flow Conservation: Total number of constraints: %d\n', cntr ) ;

% Remember of scndordr is turned ON, nvars already contains edge_npairs
allconstraints = 2 * edge_npairs + 2 * addextraconstraints * ndets ;
A = sparse( allconstraints, nvars ) ;
b = ones( allconstraints, 1 ) ;
b(1:2*edge_npairs) = 0 ; % If scndordr is OFF, this
						% numbering gives a null vector

% First add all the edge constraints
% This might actually be redundant since all edge variables are optimization variables and they
% already have minimum and maximum bounds, xl and xu.
fprintf( 'Adding Capacity Constraints\n' ) ;
% A(1:(allconstraints+1):((nvars-edge_npairs)*allconstraints)) = 1 ;
fprintf( 'Capacity Constraints added\n' ) ;

% Now add second order constraints.
if scndordr
	fprintf( 'Total Number of Second Order Constraints %d\n', edge_npairs ) ;
	scstart = 1 ;
	tic ;
	for i = 1 : edge_npairs
		if toc > 10
			fprintf( 'Second Order: Constraint Number %d/%d\n', i, edge_npairs ) ;
			tic ;
		end
		A(scstart+2*i-1, scstart+i) = 1 ;
		A(scstart+2*i-1, edge_pairs(i, 1)) = -1 ;
		A(scstart+2*i, scstart+i) = 1 ;
		A(scstart+2*i, edge_pairs(i, 2)) = -1 ;
	end

	if addextraconstraints
	end
end

if scndordr
	% First solve the normal maxflow problem and get an initial solution.
	% Then use the initial solution to solve a linear program with second order and additional
	% constraints.
	% [trcks, fval, exitflag, output, lambda] = linprog( -c(1:(nvars-edge_npairs)), ...
	% [], [], ...
	% Aeq(:, 1:(nvars-edge_npairs)), beq, xl(1:(nvars-edge_npairs)), xu(1:(nvars-edge_npairs)), [], options ) ;
	% x0 = [trcks:zeros(edge_npairs, 1)] ;
	[trcks, fval, exitflag, output, lambda] = cplexlp( -c(1:(nvars-edge_npairs)), [], [], ...
		Aeq( :, 1:(nvars-edge_npairs)), beq, xl(1:(nvars-edge_npairs)), xu(1:(nvars-edge_npairs)), [], options ) ;
	x0 = [trcks;zeros(edge_npairs, 1)] ;

	% Now solving (relaxed) second order program problem with maxflow initialization.
	% [trcks, fval, exitflag, output, lambda] = linprog( -c, A, b, Aeq, beq, xl, xu, x0, options ) ;
	[trcks, fval, exitflag, output, lambda] = cplexlp( -c, A, b, Aeq, beq, xl, xu, x0, options ) ;
else
	% if ntrcks > 10
	% 	beq(2*ndets+1) = 10 ;
	% 	beq(2*ndets+2) = 10 ;
	% end
	% while ntrcks > 0
	% 	% [trcks, fval, exitflag, output, lambda] = linprog( -c, A, b, Aeq, beq, xl, xu, x0, options ) ;
	% 	[trcks, fval, exitflag, output, lambda] = cplexlp( -c, A, b, Aeq, beq, xl, xu, x0, options ) ;
	% 	% Reduce maximum capacities to 0 thereby not selecting them at all.
	% 	xu(find(trcks>0.999)) = 0 ;
	% 	ntrcks = ntrcks - 10 ;
	% end
	% [trcks, fval, exitflag, output, lambda] = linprog( -c, A, b, Aeq, beq, xl, xu, x0, options ) ;
	alltrcks = zeros(nvars, 1) ;
	% [trcks, fval, exitflag, output, lambda] = cplexlp( -c, A, b, Aeq, beq, xl, xu, x0, options ) ;
	keyboard ;
	for times = 1 : 10
		[trcks, fval, exitflag, output, lambda] = cplexlp( -c, A, b, Aeq, beq, xl, xu, x0, options ) ;
		c((nedgs+1):(nedgs+ndets)) = c((nedgs+1):(nedgs+ndets)) + 0.3 ;
		alltrcks(find(trcks(1:nvars)==1)) = 1 ;
		xu(find(trcks(1:nvars)==1)) = 0 ;
	end

	trcks(1:nvars) = alltrcks ;
	% trcks(find(xu<0.0001)) = 1 ;
	fval
	exitflag
	output
	lambda
end

selidx = find( trcks(1:nedgs) > 0.1 ) ;
seldets = zeros(ndets, 1) ;
seldets(unique([edge_xi(selidx); edge_xj(selidx)])) = 1 ;
trcksold = [seldets; trcks(1:nedgs)>0.1] ;

if scndordr
	selidx = find( x0(1:nedgs) > 1 ) ;
	seldets = zeros(ndets, 1) ;
	seldets(unique([edge_xi(selidx); edge_xj(selidx)])) = 1 ;
	x0 = [seldets; x0(1:nedgs)>0.1] ;
end

function [nedgs, edge_indices, edge_xi, edge_xj] = collect_all_edges( Amats, xs )
% function [nedgs, edge_indices, edge_xi, edge_xj] = collect_all_edges( Amats )
% This function just collects all the edges from cell Amats, where each element reprsents the
% adjacency matrix corresponding to 1 shot.

nedgs = 0 ;
cumdets = 0 ;
nShots = length(Amats) ;
edge_indices = {} ;
edge_xi = [] ;
edge_xj = [] ;
[min(xs(:, 5)) max(xs(:, 5))]

for i = 1 : nShots
	idx = find( Amats{i} > 0.0 ) ;
	[xi, xj] = ind2sub( size(Amats{i}), idx ) ;
	edge_xi = [edge_xi; xi+cumdets] ;
	edge_xj = [edge_xj; xj+cumdets] ;
	% edge_indices{i} = xs(xi+cumdets, 5)' + xs(xj+cumdets, 5)' ;
	edge_indices{i} = Amats{i}(idx)' ; % one sided edge as opposed to xs(xi+cumdets,5)' + xs(xj+cumdets, 5)'


	nedgs = nedgs + length(idx) ;
	cumdets = cumdets + size(Amats{i}, 1) ;
end

function [edge_npairs, edge_pairs] = compute_parallel_pairs( Amats, frids, xs ) ;
% function [edge_npairs, edge_pairs] = compute_parallel_pairs( Amats, frids, xs ) ;
% This function collects all pairs of edges (belong to 1 track or multiple tracks) that can help
% give a set of second order constraints to be added to the maxflow problem.

edge_npairs = 0 ;
edge_pairs = [] ;
