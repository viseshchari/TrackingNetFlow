function im = showtrailinimage( im, dresnew, trackid, minfr, maxfr )
% function im = showtrailinimage( im, dresnew, trackid, minfr, maxfr )

trcksz = 5 ;

for i = minfr : (maxfr-1)
	pos = 1 ;
	idx = find( ( dresnew.fr == i ) & ( dresnew.r == -trackid ) ) ;
	if isempty(idx)
		continue ;
	end
	minx = round(dresnew.x(idx)+dresnew.w(idx)/2) ;
	miny = round(dresnew.y(idx)+dresnew.h(idx)/2) ;
	if dresnew.tp(idx) == 0
		pos = 0 ;
	end

	idx = find( ( dresnew.fr == (i+1) ) & ( dresnew.r == -trackid ) ) ;
	if isempty(idx)
		continue ;
	end
	maxx = round(dresnew.x(idx)+dresnew.w(idx)/2) ;
	maxy = round(dresnew.y(idx)+dresnew.h(idx)/2) ;

	if minx == maxx
		yvals = miny : maxy ;
		xvals = repmat( minx, 1, length(yvals) ) ;
	else
		xvals = minx : maxx ;
		try alphas = (xvals - minx) / (maxx-minx) ;
		catch 
			keyboard ;
		end
		yvals = round( miny * (1-alphas) + maxy * alphas ) ;
	end

	for j = 1 : length(xvals)
		validys = min(max((yvals(j)-trcksz):(yvals(j)+trcksz), 1), size(im, 1)) ;
		if pos
			[validys xvals]
			im(validys, xvals(j), 1) = 255 ;
			im(validys, xvals(j), 2) = 0 ;
			im(validys, xvals(j), 3) = 0 ;
		else
			im(validys, xvals(j), 1) = 0 ;
			im(validys, xvals(j), 2) = 255 ;
			im(validys, xvals(j), 3) = 0 ;
		end
	end
end
