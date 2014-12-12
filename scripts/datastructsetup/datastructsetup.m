function datastructsetup( trcname, nShots, maxFr, ntrcks, datapath, dataname ) 
% function datastructsetup( trcname, nShots, maxFr, ntrcks, datapath, dataname ) 

Amats = {} ;
detections = [] ;
frids = [] ;
alldets = [] ;
trcbegin = 10 ;
trcend = 16 ;
trclipend = maxFr ; 

for i = 1 : nShots

	finidx = min( (i-1)*trcbegin+trcend, trclipend ) ;

	fprintf( 'Reading Shot Number %d\n', i ) ;
	tmp = load( sprintf( './klttracking/test-dir-out/%s/klt_dist/%06d-%06d.mat', trcname, (i-1)*trcbegin+1, finidx ) ) ;

	dets = readtracks( sprintf( './klttracking/test-dir-out/%s/%s_%07d_%07d_dets.txt', trcname, trcname, (i-1)*trcbegin+1, finidx) ) ;

	frtmp = [dets.frame] ;
	confs = [dets.conf] ; % 1.15 for Scene13
	max(confs)

	idx = find( frtmp == (i*trcbegin) ) ;
	if i ~= nShots
		xs = [cat(1, dets(1:max(idx)).rect) confs(1:max(idx))'];
		frids = [frids; frtmp(1:max(idx))'] ;
		alldets = [alldets dets(1:max(idx))] ;
		Amats{i} = tmp.C(1:max(idx), :) ; % .* multfact(1:max(idx), :) ;
	else
		xs = [cat(1, dets.rect) confs'];
		frids = [frids; frtmp'] ;
		alldets = [alldets dets] ;
		Amats{i} = tmp.C(:, :) ; % .* multfact ;
	end

	detections = [detections; xs] ;
end

xs = detections ;
Amats = edge_preprocessing( Amats, frids, xs ) ;

[nedgs, edge_indices, edge_xi, edge_xj] = collect_all_edges( Amats, xs ) ;
ndets = size( xs, 1 ) ; % Number of detections.
nedgs = length(edge_xi) ;
nvars = nedgs + 3 * ndets ;


save( sprintf( '%s/%s', datapath, dataname ), 'xs', 'frids', 'edge_xi', 'edge_xj', 'nedgs', 'ndets', 'ntrcks', 'nvars', 'edge_indices', 'Amats', 'alldets','-v7.3' ) ;

return ;

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
 
