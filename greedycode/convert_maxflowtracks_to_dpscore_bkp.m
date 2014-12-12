function [dres, findlin, ovval] = convert_maxflowtracks_to_dpscore( opttracks, datadir, mikeldata, cachedir, vid_name )
% function convert_maxflowtracks_to_dpscore( opttracks, datadir )

if nargin < 3
	mikeldata = 0 ;
end

optfrms = [opttracks.frame] ;
optrcs = [opttracks.track] ;
optcnfs = [opttracks.conf] ;
optrclen = [opttracks.tracklength] ;

idx = find( optrcs > -1 ) ;
maxt = max( optrcs(idx) ) ;

tcs = [] ;
for i = 1 : maxt
	idx2 = find( optrcs == i ) ;
	tcs = [tcs sum(optcnfs(idx2))] ;
end
[srtval, srtidx] = sort( tcs, 'descend' ) ;
newcnfs = zeros(length(idx), 1) ;
for i = 1 : maxt
	newcnfs( find( optrcs(idx) == srtidx(i) ) ) = -i ;
end

optrcts = cat(1, opttracks(idx).rect ) ;
dres.x = optrcts(:, 1) ;
dres.y = optrcts(:, 2) ;
dres.w = optrcts(:, 3) - optrcts(:, 1) ;
dres.h = optrcts(:, 4) - optrcts(:, 2) ;
dres.fr = optfrms( idx )' ;
trlen( optrcs(idx) ) = optrclen(idx) ; % every track has a length.
dres.r = newcnfs ;
dres.id = optrcs(idx)' ;

if ~mikeldata
	tmp = load([datadir 'seq03-img-left_ground_truth.mat']);
	tmp2 = load('/meleze/data2/chari/Codes/CrowdAnalysis/Deva/tracking_cvpr11_release_v1.0/missing_gt2.mat') ;
else
	tmp = load([datadir 'first500gt.mat']) ;
end
gt2 = tmp.gt ;
people.x = [] ;
people.y = [] ;
people.w = [] ;
people.h = [] ;
people.fr = [] ;

if ~mikeldata
	people  = sub(gt2,find((gt2.w<24)|(gt2.h<30)));    %% move small objects to "don't care" state in evaluation. This detector cannot detect these, so we will ignore false positives on them.
	gt2      = sub(gt2,find((gt2.w>=24)&(gt2.h>=30)));
end

idx = find( dres.fr > max(gt2.fr) ) ;
dres.x(idx) = [] ;
dres.y(idx) = [] ;
dres.w(idx) = [] ;
dres.h(idx) = [] ;
dres.fr(idx) = [] ;
dres.r(idx) = [] ;
dres.id(idx) = [] ;

figure,
display('evaluating...')
[missr, fppi, findlin, ovval] = score(dres, gt2, people);
if ~mikeldata
	ff=find(fppi>3,1);
else
	ff=find(fppi>500,1);
	max(fppi)
end

semilogx(fppi,1-missr, 'k');
hold on
xlabel('False Positive Per Frame')
ylabel('Detection Rate')
set(gcf, 'paperpositionmode','auto') ;
if ~mikeldata
	axis([0.001 5 0 1]);
else
	axis([0.001 500 0 1]);
end
grid
hold off

if nargin > 3
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

