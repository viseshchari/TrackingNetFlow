function Amats = create_overlap_matrix_for_linprog( dres, trcbegin, trcend, trcskip )
% function Amats = create_overlap_matrix_for_linprog( dres, trcbegin, trcend, trcskip )
% This function converts the dres datastructures into a cell of adjacency matrices Amats.
% Instead of noting down the common KLT tracks, these adjacency matrices contain the
% amount of overlap between one detection and another.
% Let us assume at this point that dres contains a vector (ovlap) that contains all the overlap values.
% dres.x - x coordinates. (scalar)
% dres.y - y coordinates. (scalar)
% dres.w - detection width. (scalar)
% dres.h - detection height. (scalar)
% dres.r - detection confidence. (scalar)
% dres.nei - neighbor array. (struct)
% dres.nei(i).inds - neighbors for ith detection (vector)
% dres.nei(i).ovlap - neighbors overlap values. (vector)

maxframe = max( dres.fr ) ;
minframe = min( dres.fr ) ;

% There are as many shots as are allowed
Amats = {} ;
nShots = floor( (maxframe-minframe+1) / trcskip ) + 1 ; % max number of shots possible.

for i = 1 : nShots
	fr = minframe + (i-1) * trcbegin ;
	frend = min( minframe + (i-1) * trcbegin + trcend, maxframe ) ;

	idx = find( ( dres.fr >= fr) & ( dres.fr <= frend ) ) ;
	Amats{i} = zeros( length(idx) ) ;

	% Now go through all the detections in the current shot and add neighbors.
	for j = length(idx) : -1 : 1
		inds = dres.nei(idx(j)).inds ; % take all the neighbors of jth detection.
		ovs = dres.nei(idx(j)).ovlap ;
		idxrem = find( inds < min(idx) ) ;
		inds( idxrem ) = [] ; % remove indices that are outside current shot.
		ovs( idxrem ) = [] ;
		if ~isempty(inds)
			Amats{i}(inds-min(idx)+1, j) = ovs ; % always ensures an upper triangular matrix.
		end
	end

	Amats{i} = Amats{i} + Amats{i}' ; % to ensure a symmetric matrix in the end.

	% If nShots is one more than it needs to be then...
	if frend == maxframe
		break ;
	end
end