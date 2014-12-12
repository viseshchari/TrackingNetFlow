function dres = build_graph_KLT_tracks( dres, nShots )
% function dres = build_graph_KLT_tracks( dres )

if nargin < 2
	nShots = 34 ;
end

trcbegin = 30 ;
trcend = 36 ;
% Change trcname to one that contains deva video.
trcname = 'DevaScene_win11_pyl3_ssig1.0_mind7' ;
Amats = {} ;
frids = [] ;

for fr = 1 : nShots
	finidx = min( (fr-1)*trcbegin + trcend, max(dres.fr) ) ;

	tmp = load( sprintf( '/meleze/data2/chari/Codes/tracking.laptop/test-dir-out/%s/klt_dist/%06d-%06d.mat', trcname, (fr-1)*trcbegin+1, finidx ) ) ;

	dets = readtracks( sprintf( '/meleze/data2/chari/Codes/tracking.laptop/test-dir-out/%s/%s_%07d_%07d_dets.txt', trcname, trcname, (fr-1)*trcbegin+1, finidx) ) ;

	frtmp = [dets.frame] ;
	idx = find( frtmp == min(fr*trcbegin, max(dres.fr)) ) ;

	fr
	Amats{fr} = tmp.C(1:max(idx), :) ;
	frids = [frids; frtmp(1:max(idx))'] ;
end

Amats2 = edge_preprocessing( Amats, frids, [dres.x dres.y dres.x+dres.w, dres.y+dres.h, dres.r+2.01] ) ;
% save('edgevectors.mat', 'Amats', 'Amats2') ;

cumdets = 0 ;

for i = 1:length(dres.x)
	dres.nei(i,1).inds = [] ;
end

for fr = 1 : nShots
	idx = find( Amats2{fr}(:) > 0.0 ) ;
	[xi, xj] = ind2sub( size( Amats2{fr} ), idx ) ;

	% Find only adjacent frames.
	ind = find( dres.fr(xi+cumdets) == (dres.fr(xj+cumdets)-1) ) ;
	xi = xi(ind) + cumdets ;
	xj = xj(ind) + cumdets ;

	if size(xi,1) == 1
		xi = xi' ;
		xj = xj' ;
	end

	for i = 1 : length(xj)
		dres.nei(xj(i),1).inds = [dres.nei(xj(i), 1).inds xi(i)] ;
		% idx = find( dres.fr(xi) == (dres.fr(xj(i))-1) ) ;
		% dres.nei( xj(i), 1 ).inds = unique(xi(idx)) ;
	end

	cumdets = cumdets + size( Amats2{fr}, 1 ) ;
end
