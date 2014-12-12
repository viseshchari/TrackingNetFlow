function im = markdetections( im, dresnew, trackid, frid )
% function im = markdetections( im, dresnew, trackid, frid )

idx = find( ( dresnew.fr == frid ) & ( dresnew.r == -trackid ) ) ;

mx = round(dresnew.x(idx)) ;
my = round(dresnew.y(idx)) ;
mw = round(dresnew.w(idx)) ;
mh = round(dresnew.h(idx)) ;

im = drawlineinimage( im, mx, mx+mw, my, my ) ;
im = drawlineinimage( im, mx, mx+mw, my+mh, my+mh ) ;
im = drawlineinimage( im, mx, mx, my, my+mh ) ;
im = drawlineinimage( im, mx+mw, mx+mw, my, my+mh ) ;


function im = drawlineinimage( im, mx, mx2, my, my2 ) 
% function im = drawlineinimage( im, mx, mx2, my, my2 ) 

trcksz = 5 ;
mx = min(max(mx, 1),size(im,2)) ;
my = min(max(my, 1),size(im,1)) ;
mx2 = min(max(mx2, 1),size(im,2)) ;
my2 = min(max(my2, 1),size(im,1)) ;

if mx == mx2
	validxs = min( max( (mx-trcksz):(mx+trcksz), 1 ), size(im, 2) ) ;
	im( my:my2, validxs, 1 ) = 0 ;
	im( my:my2, validxs, 2 ) = 0 ;
	im( my:my2, validxs, 3 ) = 255 ;
elseif my == my2
	validys = min( max( (my-trcksz):(my+trcksz), 1 ), size(im, 1) ) ;

	[validys mx mx2]
	im( validys, mx:mx2, 1 ) = 0 ;
	im( validys, mx:mx2, 2 ) = 0 ;
	im( validys, mx:mx2, 3 ) = 255 ;
end

