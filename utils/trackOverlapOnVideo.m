function trackOverlapOnVideo( tracks, impath, imnums, outpath, outnums )
% function writeTracksToVideo( tracks, impath, imnums, outpath, outvidname )
% This function takes images of a video and overlays tracks on them
% and then writes them to outvidname

nTrcks = max( tracks.id ) ;
trcolrs = rand( nTrcks, 3 ) ;

bboxes = [tracks.x tracks.y tracks.x+tracks.w tracks.y+tracks.h] ;

% for each frame
for i = min( tracks.fr ) : max( tracks.fr )
    % Truncate all tracks.
    trckstmp = sub( tracks, find( tracks.fr <= i ) ) ;
    plotTracks( trckstmp, [], 0, trcolrs, 2 ) ;
    im = imread( sprintf( impath, imnums(i) ) ) ;
    axis( [0 size(im, 2) 0 size(im, 1)] ) ;
    figure(2) ;    
    img = getframe( gca ) ;
    img = imresize( img.cdata, [size(im, 1) size(im,2)], 'bilinear' ) ;
    idx = find( (tracks.fr == i) & (tracks.id ~= -1) ) ;
    im = drawBoxes(im, bboxes(idx, :), trcolrs(tracks.id(idx), :)) ;
    combimage = imresize([img im], 0.5, 'bilinear') ;
    imwrite( combimage, sprintf( outpath, outnums(i) ) ) ;
    figure(3) ; imshow(combimage) ;
end


function im = drawBoxes(im, bboxes, trcolrs)
% function im = drawBoxes(im, bboxes, trcolrs)

nbxs = size( bboxes, 1 ) ;
thcknss = 3 ;
imsz1 = size(im, 1) ;
imsz2 = size(im, 2) ;

for i = 1 : nbxs
    minx = max( bboxes(i, 1), 1) ;
    miny = max( bboxes(i, 2), 1) ;
    maxx = min( bboxes(i, 3), imsz2 ) ;
    maxy = min( bboxes(i, 4), imsz1 ) ;
    
    im( max( miny-thcknss, 1 ) : min( miny+thcknss, imsz1 ), minx : maxx, 1 ) = trcolrs(i, 1) * 255 ;
    im( max( miny-thcknss, 1 ) : min( miny+thcknss, imsz1 ), minx : maxx, 2 ) = trcolrs(i, 2) * 255 ;
    im( max( miny-thcknss, 1 ) : min( miny+thcknss, imsz1 ), minx : maxx, 3 ) = trcolrs(i, 3) * 255 ;
    
    im( max( maxy-thcknss, 1 ) : min( maxy+thcknss, imsz1 ), minx : maxx, 1 ) = trcolrs(i, 1) * 255 ;
    im( max( maxy-thcknss, 1 ) : min( maxy+thcknss, imsz1 ), minx : maxx, 2 ) = trcolrs(i, 2) * 255 ;
    im( max( maxy-thcknss, 1 ) : min( maxy+thcknss, imsz1 ), minx : maxx, 3 ) = trcolrs(i, 3) * 255 ;
    
    im( miny : maxy, max( minx-thcknss, 1 ) : min( minx+thcknss, imsz2 ), 1 ) = trcolrs(i, 1) * 255 ; 
    im( miny : maxy, max( minx-thcknss, 1 ) : min( minx+thcknss, imsz2 ), 2 ) = trcolrs(i, 2) * 255 ;
    im( miny : maxy, max( minx-thcknss, 1 ) : min( minx+thcknss, imsz2 ), 3 ) = trcolrs(i, 3) * 255 ;
    
    im( miny : maxy, max( maxx-thcknss, 1 ) : min( maxx+thcknss, imsz2 ), 1 ) = trcolrs(i, 1) * 255 ;  
    im( miny : maxy, max( maxx-thcknss, 1 ) : min( maxx+thcknss, imsz2 ), 2 ) = trcolrs(i, 2) * 255 ;
    im( miny : maxy, max( maxx-thcknss, 1 ) : min( maxx+thcknss, imsz2 ), 3 ) = trcolrs(i, 3) * 255 ;
end
