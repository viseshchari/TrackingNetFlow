function [edge_group, edge_ngroup, edge_velocities, maxvel] = addParallelismConstraints( xs, frids, edge_xi, edge_xj, thresh )
% function [edge_group, edge_velocities] = addParallelismConstraints( xs, frids, edge_xi, edge_xj, thresh )


nedgs = length(edge_xi) ;

edge_group = [] ;
edge_velocities = [] ;
rcent = [xs(:,1)+xs(:,3) xs(:,2)+xs(:,4)] / 2 ;
% Replace the old feature with new feature from optical flow
% This should give a significant boost to all the velocity based computations we
% do in this paper.
% rcent = [xs(:, 6:7) xs(:,1)/2+xs(:,3)/2 xs(:,2)/2+xs(:,4)/2] ;
frdiff = frids(edge_xj)-frids(edge_xi) ;

nfr = max( frids ) ;
mfr = min( frids ) ;
cumdets = 0 ;

for i = mfr : nfr
	fprintf( 'Frame Number %d\n', i ) ;
	idx = find( frids == i ) ;
	idxtmp = find( ismember( edge_xi, idx ) == 1 ) ;

	% ovval now contains 1's at all the vectors that are parallel, or almost parallel
	% e_vecs is a nedgs x 4 vector that contains the vector representing both ei and ej.
	[ei, ej, e_vecs] = findparallelpairs( rcent(edge_xi(idxtmp), :), rcent(edge_xj(idxtmp), :), frdiff(idxtmp), thresh ) ;
	% ovval(1:(length(idx)+1):end) = 0.0 ;
	% ovval = max( ovval, bxinbx( xs(idx, 1:4) ) ) ;

	% transforming the edge groups 
	ei = idxtmp(ei) ;
	ej = idxtmp(ej) ;

	edge_group = [edge_group; [ei ej]] ;
	edge_velocities = [edge_velocities; e_vecs] ;
end

% Now some basic pruning before sending back edge_group, and edge_velocities
% Exclude edge pairs that start from the same edge or end on the same edge.
idxtmp = find( edge_xi(edge_group(:,1)) == edge_xi(edge_group(:,2)) ) ;
edge_group(idxtmp, :) = [] ;
edge_velocities(idxtmp, :) = [] ;
idxtmp = find( edge_xj(edge_group(:,1)) == edge_xj(edge_group(:,2)) ) ;
edge_group(idxtmp, :) = [] ;
edge_velocities(idxtmp, :) = [] ;

% Exclude isolated edges %%%%% HARD CONSTRAINT %%%%%  because these have no constraints on them.
vec = rcent(edge_xj,:)-rcent(edge_xi, :) ;
% vecnm = sqrt(sum(vec.^2,2))./(frids(edge_xj)-frids(edge_xi)) ;
vecnm = sqrt(sum(vec.^2,2)) ;
idxbig = find( vecnm > 45 ) ;
% idxbig = [] ;

% Remove big edges from the edge group as well
idxbiged = find( ismember( edge_group(:, 1), idxbig ) == 1 ) ;
edge_group(idxbiged, :) = [] ;
edge_velocities(idxbiged, :) = [] ;
idxbiged = find( ismember( edge_group(:, 2), idxbig ) == 1 ) ;	
edge_group(idxbiged, :) = [] ;	
edge_velocities(idxbiged, :) = [] ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Normalization of Velocity Vectors %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% edge_vecnm = [sum(edge_velocities(:,1:2).^2, 2) sum(edge_velocities(:, 3:4).^2, 2)] ;
% edge_veczero = double( edge_vecnm < 1 ) ; % if norm is 0, then make it 1
% edge_vecnm = edge_vecnm + edge_veczero ;
% edge_velocities = [edge_velocities(:, 1)./edge_vecnm(:, 1) edge_velocities(:, 2)./edge_vecnm(:, 1) ...
% 				   edge_velocities(:, 3)./edge_vecnm(:, 2) edge_velocities(:, 4)./edge_vecnm(:, 2)] ;

maxvel = max( [sum(edge_velocities(:,1:2).^2, 2); sum(edge_velocities(:, 3:4).^2, 2)] ) ;
edge_ngroup = size( edge_group, 1 ) ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ei, ej, e_vecs] = findparallelpairs( centi, centj, frdiff, thresh )
% function ovval = findparallelpairs( xs, edge_xi, edge_xj )

% vecs = [(centj(:,1:2)+centi(:,1:2))/2] ; % ./ repmat( frdiff, 1, 2 ) ; % velocities normalized by time
vecs = ( centj - centi ) ./ repmat( frdiff, 1, 2 ) ;
nedgs = size(centi, 1) ;

vecnrm = sqrt(sum(vecs.^2, 2)) ;
fprintf( 'Entering finding parallel pairs function\n' ) ;

% Normalize vectors
% vecs = vecs ./ repmat( vecnrm+eps, 1, 2 ) ;
idxrem = find( vecnrm < eps ) ; % for all these edge, do not put any constraints.

% SLJ: this is looking at *all* pairs of velocities for this frame and
% computing ||v_i-v_i||/median
dotprod = sqrt( ( repmat( vecs(:, 1), 1, nedgs ) - repmat( vecs(:, 1)', nedgs, 1 ) ).^2 + ...
			( repmat( vecs(:, 2), 1, nedgs ) - repmat( vecs(:, 2)', nedgs, 1 ) ).^2 ) ;
% dotprod = dotprod ./ median( vecnrm ) ;
% dotprod1 = ( repmat( vecs1(:, 1), 1, nedgs ).* repmat( vecs1(:, 1)', nedgs, 1) ) + ...
% 			( repmat( vecs1(:, 2), 1, nedgs ).* repmat( vecs1(:, 2)', nedgs, 1) ) ;
dotprod = (dotprod) < thresh ; % take only vectors that are really close to each other.
dotprod( idxrem, : ) = 0 ;	
dotprod( :, idxrem ) = 0 ;
% Now remove edges whose centi's are far away from each other.

% centdist = ( repmat( centi(:, 3), 1, nedgs ) - repmat( centi(:, 3)', nedgs, 1 ) ).^2 + ...
% 				( repmat( centi(:, 4), 1, nedgs ) - repmat( centi(:, 4)', nedgs, 1 ) ).^ 2 ;

centdist = ( repmat( centi(:, 1), 1, nedgs ) - repmat( centi(:, 1)', nedgs, 1 ) ).^2 + ...
				( repmat( centi(:, 2), 1, nedgs ) - repmat( centi(:, 2)', nedgs, 1 ) ).^ 2 ;
centdist = sqrt( centdist ) ;
centdist = centdist < 100 ; % 450 works best for scene7
						% warning FREE VARIABLE %%%%%%%%%% HARD CONSTRAINT %%%%%%%%%%%%%

dotprod = triu(dotprod .* centdist) ; % triu reduces all
idx = find( dotprod(:) == 1 ) ;
[ei, ej] = ind2sub( size( dotprod ), idx ) ;
% e_vecs = [centj(ei, 1:2)+centi(ei, 1:2) centj(ej, 1:2)+centi(ej, 1:2)]/2 ;
e_vecs = [ (centj(ej, :) - centi(ej, :))./repmat(frdiff(ej), 1,  2) (centj(ei, :) - centi(ei, :))./repmat(frdiff(ei), 1, 2) ];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%