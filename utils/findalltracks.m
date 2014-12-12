function alltrcks = findalltracks( trids, ndets, numtracks, xi, xj, xval, nedgs, alltrcks )
% function alltrcks = findalltracks( trids, ndets, numtracks, xi, xj, xval, nedgs, alltrcks )

% if ~iscell(Amat)
% 	Amat = triu(Amat) ;
% 	idx = find( Amat(:) > 0.0 ) ;
% 	nedgs = length(idx) ;
% 	[xi, xj] = ind2sub( size(Amat), idx ) ;
% 	size(Amat)
% else
% 	nShots = length(Amat) ;
% 	nedgs = 0 ;
% 	nd = 0 ;
% 	xi = [] ;
% 	xj = [] ;
% 	xval = [] ;
% 	for i = 1 : nShots
% 		Amat{i} = triu(Amat{i}) ;
% 		idx = find( Amat{i}(:) > 0.0 ) ;
% 		[xitmp, xjtmp] = ind2sub( size(Amat{i}), idx ) ;
% 		xi = [xi; xitmp+nd] ;
% 		xj = [xj; xjtmp+nd] ;
% 		xval = [xval; Amat{i}(idx)] ;
% 		nd = nd + size(Amat{i},1) ;
% 		nedgs = nedgs + length(idx) ;
% 	end
% end

% Find all the edges that are turned on.
% By flow constraints, corresponding detections are always on, and others are always off.
edidxs = find( trids((ndets+1):(ndets+nedgs)) > eps ) ; % because of precision matlab sometimes returns very small number

arr = -1 * ones(ndets, 1) ; 
xvalarr = -1*ones(ndets, 1) ;
ednum = -1*ones(ndets, 1) ; % stores edge number corresponding to each detection. (where current detection is in xi)

% Check for fractional solutions, Integer solutions should
% not get this remark!
if length(unique(xi(edidxs))) ~= length(edidxs)
	disp('Duplicate detections here in xi!') ;
	keyboard ;
end

if length(unique(xj(edidxs))) ~= length(edidxs)
	disp('Duplicate detections here in xj!') ;
	keyboard ;
end

% This might not be true for fractional tracks.
[arr(xi(edidxs))] = deal(xj(edidxs)) ;
[xvalarr(xi(edidxs))] = deal(xval(edidxs)) ; % xval now contains strength of all edges.
[ednum(xi(edidxs))] = deal(edidxs) ;

%for i = 1 : length(edidxs)
%	% xi is always less than xj in upper triangular matrices.
%	arr(xi(edidxs(i))) = xj(edidxs(i)) ;
%end

disp('Now sorting through the tracks') ;
% Now rename all the tracks
cntr = 1 ;
tic ;
for i = 1 : numtracks
% 	if toc > 0.1
		fprintf( 'Track Number %d/%d\n', i, numtracks ) ;
% 		tic ;
%   end
	while arr(cntr) < i
		cntr = cntr + 1 ;
		if cntr > length(arr)
			break ;
		end
	end
	if cntr > length(arr)
		break ;
	end
	iter = 1 ;
	while (cntr ~= -1) && (iter < 2000)
		[arr(cntr), cntr] = deal(i, arr(cntr)) ;
		iter = iter + 1 ;
	end
	if iter == 2000
		fprintf( 'Max iterations reached. Should not have come here\n' ) ;
		keyboard ;
	end
	cntr = 1 ;
end

[alltrcks.track] = deal(-1) ; % Reset all counters.
[alltrcks.trackconf] = deal(-1) ;
% Now add edge and detection confidences.
[alltrcks.edgeconf] = deal(-1) ;
[alltrcks.xi] = deal(-1) ;
[alltrcks.xj] = deal(-1) ;
[alltrcks.ednum] = deal(-1) ;
[alltrcks.hogconf] = deal(-1) ;
% alltrcks = setfield(alltrcks, 'hogconf', {alltrcks.conf}) ; % renaming the variable for ease of use in next phase of operations.

disp('Collecting all the tracks now') ;
% Now collect all the tracks.
for i = 1 : numtracks
	idx = find( arr == i ) ;
	[alltrcks(idx).track] = deal(i) ;
	[alltrcks(idx).tracklength] = deal(length(idx)) ;
	[alltrcks(idx).trackconf] = deal(mean(xvalarr(idx))) ;
end


idxedgs = find( arr > -1 ) ;
for i = 1:length(idxedgs)
	alltrcks(idxedgs(i)).edgeconf = xvalarr(idxedgs(i)) ;
	alltrcks(idxedgs(i)).hogconf = alltrcks(idxedgs(i)).conf ;
	if ednum(idxedgs(i))~=-1
		alltrcks(idxedgs(i)).xi = xi(ednum(idxedgs(i))) ;
		alltrcks(idxedgs(i)).xj = xj(ednum(idxedgs(i))) ;
	end
	alltrcks(idxedgs(i)).ednum = ednum(idxedgs(i)) ;
end