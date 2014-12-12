% Script to show the problem of missing annotation.

if ~exist( 'finvaldp' )
	main ; % in case this has not been run.
end

datadir = '/meleze/data2/chari/Codes/CrowdAnalysis/Deva/tracking_cvpr11_release_v1.0/data/'; 
load([datadir 'seq03-img-left_ground_truth.mat']);
people  = sub(gt,find(gt.w<24));    %% move small objects to "don't care" state in evaluation. This detector cannot detect these, so we will ignore false positives on them.
gt      = sub(gt,find(gt.w>=24));

% if ~exist( trclen )
	trclen = [] ;
	trctrue = [] ;

	for i = 1 : max( dres_dp.id )
		idx = find( dres_dp.id == i ) ;
		trclen = [trclen length(idx)] ;
		trctrue = [trctrue sum(finvaldp(idx))] ;
	end

	[srtval, srtidx] = sort( trclen, 'descend' ) ;

	trstart = 1 ;
	trend = 40 ;
	srtidx = srtidx( trstart:trend ) ;
	srtval = srtval( trstart:trend ) ;

	figure ; hold on ;
	x1 = plot( trclen(srtidx), 'r' ) ;
	x2 = plot( trctrue(srtidx), 'b' ) ;

	set( [x1 x2], 'linewidth', 3 ) ;
	set( gca, 'linewidth', 3 ) ;
	set( gca, 'fontsize', 20 ) ;

	xl = xlabel( 'Track Number' ) ;
	yl = ylabel( 'Track Length' ) ;
	% axis( [1  0 200] ) ;

	lgn = legend( [x1 x2], 'Track Length', 'True Positive Length', 'Location', 'NorthEast' ) ;
	% s = get( gca, 'XTickLabel' ) ;
	% tmpnum = str2num( s ) ;
	% set( gca, 'XTickLabel', num2str(srtidx(tmpnum)') ) ;
% end

% Now get frames for track 2 and plot all its ground truth boxes, and plot the box which
trid = 251 ;
idx = find( dres_dp.id == trid ) ;
% idx2 = find( finvaldp(idx) == 0 ) ;
idx2 = 1:length(idx) ;

rct = [dres_dp.x dres_dp.y dres_dp.x+dres_dp.w dres_dp.y+dres_dp.h] ;
rctgt = [gt.x gt.y gt.x+gt.w gt.y+gt.h] ;

frtr = rem(10, length(idx2)) + 1 ; % frame within set of false positives that you want to show.
frid = dres_dp.fr( idx(idx2(frtr)) ) ;
im = imread( sprintf( '/meleze/data2/chari/Codes/CrowdAnalysis/Deva/tracking_cvpr11_release_v1.0/data/seq03-img-left/image_%08d_0.png', frid-1 ) ) ;

idxgt = find( gt.fr == frid ) ;

figure; hold on ;
showboxes( im, rctgt( idxgt, : ) ) ; % first show ground truth boxes.
showboxes( im, rct(idx(idx2(frtr)), :), 'b', 0 ) ;
fprintf( 'Detection confidence %f\n', dres_dp.r(idx(idx2(frtr))) ) ;
axis ij ;
