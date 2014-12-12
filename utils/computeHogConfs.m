function dresnew = computeHogConfs( dres, detections, frids )
% function dresnew = computeHogConfs( dres, detections, frids )

minfr = min(dres.fr) ;
maxfr = max(dres.fr) ;

dresnew = dres ;
rct = [dres.x dres.y dres.x+dres.w dres.y+dres.h] ;

dresnew.hogconf = zeros(length(dresnew.r), 1) ;

for i = minfr : maxfr
	idx = find( dres.fr == i ) ;
	idx2 = find( frids == i ) ;

	ovval = bboxoverlapval( detections(idx2, 1:4), rct(idx, :) ) ;
	[mv, midx] = max( ovval ) ;

	hogcnfs = detections( idx2(midx), 5 ) ;
	dresnew.hogconf(idx) = hogcnfs ;
end
