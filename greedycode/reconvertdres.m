function dresnew = reconvertdres( dresmain, dresdp )
% function dresnew = reconvertdres( dresmain, dresdp )

maxid = max( dresdp.fr ) ;
rct1 = [dresdp.x dresdp.y dresdp.x+dresdp.w dresdp.y+dresdp.h] ;
rct2 = [dresmain.x dresmain.y dresmain.x+dresmain.w dresmain.y+dresmain.h] ;
rnew = zeros(size(rct1,1), 1) ;
dresnew = dresdp ;

for i = 2 : maxid
	idx1 = find( dresdp.fr == i ) ;
	idx2 = find( dresmain.fr == i ) ;
	ovval = bboxoverlapval( rct2(idx2, :), rct1(idx1, :) ) ;
	[mv, midx] = max( ovval ) ;
	% Its not possible that there is no overlap.
	rnew(idx1) = dresmain.r(idx2(midx)) ;
end

dresnew.r = rnew ;