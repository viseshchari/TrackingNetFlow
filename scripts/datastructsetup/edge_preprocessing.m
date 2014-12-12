function Amats = edge_preprocessing( Amats, frids, xs )
% function Amats = edge_preprocessing( Amats, frids, xs )
% This function processes all edges and adds detection weights and other constraints to the edges.
% These constraints can be added without changing the nature of the problem, and hence
% provide a way for scalable tracking while accounting for errors in KLT tracks ?

nShots = length(Amats) ;
cumdets = 0 ;
frmlen = 1 ;
frmlen2 = 6 ; % 80 in TCH6 50 in TCH5 30 in TCH4 10 in TCH3 4 works best for scene7 and everything else except town center data.
turnoffdetarea = 1 ;
turnoffmultmat = 0 ;
turnoffdetmatrix = 1 ;
fprintf('Coming here') ;
multmat = [] ;

tic ;
for i = 1 : nShots
	if toc > 10
		fprintf( 'Shot number %d\n', i ) ;
		tic ;
	end
	% Number of frames that are common between two consecutive shots.
	nExtra = size(Amats{i},2) - size(Amats{i},1) ;

	% First remove all the unwanted edges.
	Amats{i}(isnan(Amats{i}(:))) = 0.0 ;
	Amats{i}(isinf(Amats{i}(:))) = 0.0 ;

	% Then remove all the edges that are below a particular threshold of strength.
	% This helps in reducing the number of edges in the graph.
	%%%%%%% WARNING %%%%%%%
	detidx = find( Amats{i}(:) <= 0.10 ) ; %% ARBITRARY THRESHOLDING HERE, might change in future, 0.10 works best for scene7, 0.4 for TownCenter
	ndets = size(Amats{i}, 1) ;
	detmatrix = repmat( xs((cumdets+1):(cumdets+ndets+nExtra), 5), 1, ndets+nExtra ) ;
	tmpmat = repmat( xs((cumdets+1):(cumdets+ndets+nExtra), 5)', ndets+nExtra, 1 ) ;
	detmatrix = detmatrix + tmpmat ;
	clear tmpmat ;

	% Now augment each with its corresponding detections.
	if ~turnoffdetmatrix
		% Amats{i} = Amats{i} .* max( 1.0 - abs(log10(detmatrix(1:(end-nExtra), :)/4)), 0.0 ) ;
		% Amats{i} = Amats{i} + detmatrix(1:(end-nExtra), :) ;
	end
	
	% Now ensure no detection is connected to itself.
	Amats{i}(1:(ndets+1):(ndets*ndets)) = 0.0 ;
	if ~turnoffmultmat
		clear multmat ;
		multmat = ( ( repmat( frids((cumdets+1):(cumdets+ndets+nExtra)), 1, ndets+nExtra ) + frmlen ) <= ...
						repmat( frids((cumdets+1):(cumdets+ndets+nExtra))', ndets+nExtra, 1 ) ) ;
		multmat = multmat & ( ( repmat( frids((cumdets+1):(cumdets+ndets+nExtra)), 1, ndets+nExtra ) + frmlen2 ) > ...
						repmat( frids((cumdets+1):(cumdets+ndets+nExtra))', ndets+nExtra, 1 ) ) ;
	end

	% Now compute and normalize edges for area difference. You don't want arbitrarily
	% large edges to be selected.
	detarea = (xs((cumdets+1):(cumdets+ndets+nExtra), 4)-xs((cumdets+1):(cumdets+ndets+nExtra), 2)) ; % Just taking the height when you do this.
	% detarea = (xs((cumdets+1):(cumdets+ndets+nExtra), 3)-xs((cumdets+1):(cumdets+ndets+nExtra), 1)) .* ...
	% 			(xs((cumdets+1):(cumdets+ndets+nExtra), 4)-xs((cumdets+1):(cumdets+ndets+nExtra), 2)) ;
	detarearep = repmat( detarea, 1, ndets+nExtra ) ./ repmat( detarea', ndets+nExtra, 1 ) ;
	detarearep = min( detarearep, 1./detarearep ) ;
	if ~turnoffdetarea
		newidx = find( detarearep(:) <= 0.8 ) ;
		detarearep(newidx) = 0 ;
		Amats{i} = Amats{i} .* detarearep(1:(end-nExtra), :) ;
		% Amats{i} = Amats{i} .* max( 1.0 - abs(log10(detarearep(1:(end-nExtra),:))), 0.0 ) ;
	end
	Amats{i}(detidx) = 0.0 ;

	% Just take upper triangular matrix since graph is directed with earlier frames
	% pointing towards later frames.
	if ~turnoffmultmat
		Amats{i} = triu(Amats{i}).*multmat(1:(end-nExtra), :) ; 
	else
		Amats{i} = triu(Amats{i}) ; % If lot of KLT tracks are tracked over long distances, we trust them
	end
	cumdets = cumdets + ndets ;
end
 
