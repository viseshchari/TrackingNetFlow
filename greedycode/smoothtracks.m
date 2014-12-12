function dressmooth = smoothtracks( dres )
% function dressmooth = smoothtracks( dres )

maxtr = min( dres.r ) ;

rct = [dres.x dres.y dres.w dres.h] ;
rctmean = rct ;

for i = 1 : maxtr
	idx = find( dres.r == -i ) ;
	rctmean(idx, 3) = mean( rct(idx, 3) ) ;
	rctmean(idx, 4) = mean( rct(idx, 4) ) ;
end

dressmooth = dres ;
dressmooth.w = rctmean(:, 3) ;
dressmooth.h = rctmean(:, 4) ;