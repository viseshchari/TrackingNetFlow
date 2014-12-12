function [dres, findagglo] = convert_agglotracks_to_dpscore( opttracks, datadir, cachedir, vid_name )
% function convert_agglotracks_to_dpscore( opttracks, datadir, cachedir, vid_name )

% First prune the tracks to discard the ones that have a few frames less..
trc = [opttracks.track] ;
trconfs = [opttracks.conf] ; % use this to rank the order of the tracks leter.

trl = [] ;
trcnfs = [] ;

for i = 1 : max(trc)
	idx = find( trc == i ) ;
	trl(i) = length(idx) ;
	trcnfs(i) = sum( trconfs(idx) ) ;
	% update opttracks with the current length of each track.
	[opttracks(idx).track] = deal(trl(i)) ;
end

% Now find tracks whose length is greater than a specified amount.
idx = find( trl > 45 ) ; % For now arbitrary length, check how it performs.

% Now only consider these tracks.
rct = cat(1, opttracks(idx).rect) ;
cnfs = cat(1, opttracks(idx).conf) ;
frms = cat(1, opttracks(idx).frame) ;
[dval, didx] = sort( trcnfs, 'descend' ) ; % sort track confidences in descending order.
newcnfs = zeros(length(trcnfs), 1) ;
newcnfs(didx) = 1:length(didx) ; % re-order tracks based on new confidences.

% Now build the dres datastructure.
dres.x = rct(:, 1) ;
dres.y = rct(:, 2) ;
dres.w = rct(:, 3) - rct(:, 1) ;
dres.h = rct(:, 4) - rct(:, 2) ;
dres.r = -newcnfs(trc(idx)) ;
dres.fr = frms ;
dres.id = trc(idx) ;

tmp = load([datadir 'seq03-img-left_ground_truth.mat']);
gt2 = tmp.gt ;
people  = sub(gt2,find((gt2.w<24)|(gt2.h<50)));    %% move small objects to "don't care" state in evaluation. This detector cannot detect these, so we will ignore false positives on them.
gt2      = sub(gt2,find((gt2.w>=24)&(gt2.h>=50)));
load('/meleze/data2/chari/Codes/CrowdAnalysis/Deva/tracking_cvpr11_release_v1.0/missing_gt2.mat') ;

figure(1),
display('evaluating...')
[missr, fppi, findagglo] = score(dres, gt2, people);
ff=find(fppi>3,1);

semilogx(fppi,1-missr, 'k');
hold on
xlabel('False Positive Per Frame')
ylabel('Detection Rate')
set(gcf, 'paperpositionmode','auto')
axis([0.001 5 0 1])
grid
hold off

if nargin > 2
	load([datadir 'label_image_file']);
	m=2;
	for i=1:length(bws)                   %% adds some margin to the label images
  		[sz1 sz2] = size(bws(i).bw);
  		bws(i).bw = [zeros(sz1+2*m,m) [zeros(m,sz2); bws(i).bw; zeros(m,sz2)] zeros(sz1+2*m,m)];
	end

	input_frames    = [datadir 'seq03-img-left/image_%0.8d_0.png'];
	output_path     = [cachedir '/'];
	output_vidname  = [cachedir vid_name '_dp_tracked.avi'];

	fnum = max(dres.fr);
	bboxes_tracked = dres2bboxes(dres, fnum);  %% we are visualizing the "DP with NMS in the lop" results. Can be changed to show the results of DP or push relabel algorithm.
	show_bboxes_on_video(input_frames, bboxes_tracked, output_vidname, bws, 4, -inf, output_path);
end
