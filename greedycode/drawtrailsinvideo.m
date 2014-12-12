clear all ; close all ;

load('LPResult879.mat') ;
scene879_script ;
dresnew.tp = zeros( length(dresnew.x), 1 ) ;

% First mark all the true positives
for i = min(gt.fr) : max(gt.fr)
	idx1 = find( dresnew.fr == i ) ;
	idx2 = find( gt.fr == i ) ;
	fprintf( 'Frame %d\n', i ) ;

	ovval = bboxoverlapval( rct(idx1, :), rctgt(idx2, :), 0 ) ;
	[mv, midx] = max( ovval ) ;
	idxtmp = find( mv >= 0.5 ) ;
	dresnew.tp(idx1(idxtmp)) = 1 ;
end

% now take all frames and mark them
outputvid = './outputvid' ;

% Normalize all boxes
for i = 1 : 106
	mxi = max(i-5, 1) ;
	nxi = min(i+5, 106 ) ;
	for j = 1 : 40
		idx = find( (dresnew.fr >= mxi) & ( dresnew.fr <= nxi ) & ( dresnew.r == -j ) ) ;
		dresnew.x(idx) = mean(dresnew.x(idx)) ;
		dresnew.y(idx) = mean(dresnew.y(idx)) ;
	end
end

for j = 1 : 40
	idx = find( dresnew.r == -j )  ;
	dresnew.w(idx) = median( dresnew.w(idx) ) ;
	dresnew.h(idx) = median( dresnew.h(idx) ) ;
end

for i = 1 : 106
	im = imread( sprintf( '/data2/CrowdAnalysis/UCFData/879/frame%04d.jpg', i ) ) ;
	fprintf( 'Frame %d\n', i ) ;

	for j = [1 : 2 : 40]
		% im = showtrailinimage( im, dresnew, j, i, min(i+20, 106) ) ;
		im = showtrailinimage( im, dresnew, j, max(i-40,1), i ) ;
		im = markdetections( im, dresnew,j, i ) ;
	end
	imwrite(im, sprintf( '%s/frame%04d.jpg', outputvid, i ), 'jpg' ) ;
end

