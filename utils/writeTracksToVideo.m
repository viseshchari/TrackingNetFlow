function writeTracksToVideo( tracks, impath, imnums, outpath, outnums )
% function writeTracksToVideo( tracks, impath, imnums, outpath, outvidname )
% This function takes images of a video and overlays tracks on them
% and then writes them to outvidname


numfigs = min( max( tracks.fr ) - min( tracks.fr ), length( imnums ) ) ;

centx = tracks.x + tracks.w/2 ;
centy = tracks.y + tracks.h/2 ;

centx = [centx; -1] ;
centy = [centy; -1] ;
nomatch = length(centx) ;

trcolrs = rand( max( tracks.id ), 3 ) ;

for i = 1 : (numfigs-1)
    fprintf( 'Writing image %d\n', i ) ;
    im = imread( sprintf( impath, imnums(i) ) ) ;
    idx = find( ( tracks.fr == imnums(i) ) & ( tracks.id ~= -1 ) ) ;
    idxprev = zeros(length(idx),1) ;
    for j = 1 : length(idx)
        idxtmp = find( (tracks.fr == max(imnums(i)-5, 1) ) & (tracks.id == tracks.id(idx(j)) ) ) ;
        if isempty(idxtmp)
            idxprev(j) = nomatch ;
        else
            idxprev(j) = idxtmp ;
        end
    end

%     idx2 = find( tracks.fr == imnums(i+1) ) ;
    
    im = fillImage( im, [centx(idx), centy(idx)], [centx(idxprev), centy(idxprev)], trcolrs(tracks.id(idx),:) ) ;
    
    imwrite( im, sprintf( outpath, outnums(i) ) ) ;
end

function im = fillImage( im, cents, centprev, colrs )
% function fillImage( im, cents, colrs ) 

cents = round(cents) ;
centprev = round(centprev) ;

ntrcks = size(cents, 1) ;

for i = 1 : ntrcks
    
    if centprev(i, 2) ~= -1
        cxs = centprev(i, 1) ;
        cys = centprev(i, 2) ;
    else
        cxs = cents(i, 1) ;
        cys = cents(i, 2) ;
    end
    cxe = cents(i, 1) ;
    cye = cents(i, 2) ;
    
    for ax = 0 : 0.1 : 1
        cx = round(ax * cxs + (1-ax) * cxe) ;
        cy = round(ax * cys + (1-ax) * cye) ;                    
        for j = -25 : 25
            for k = -25 : 25
                if cx+k <= 0
                    continue ;
                end
                if cx+k > size(im, 2)
                    continue ;
                end
                if cy+j <= 0
                    continue ;
                end
                if cy+j > size(im, 1)
                    continue ;
                end 
                im( cy+j, cx+k, 1 ) = colrs(i, 1)*255 ;
                im( cy+j, cx+k, 2 ) = colrs(i, 2)*255 ;
                im( cy+j, cx+k, 3 ) = colrs(i, 3)*255 ;
            end
        end
    end
end
