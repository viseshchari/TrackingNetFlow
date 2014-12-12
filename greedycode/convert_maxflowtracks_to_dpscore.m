function [dres, findlin, ovval] = convert_maxflowtracks_to_dpscore( opttracks, datadir, mikeldata, cachedir, vid_name )
% function convert_maxflowtracks_to_dpscore( opttracks, datadir )

if nargin < 3
	mikeldata = 0 ;
end

dres = convert_opttracks_to_dres( opttracks ) ;

if ~mikeldata
	tmp = load([datadir 'seq03-img-left_ground_truth.mat']);
	% tmp2 = load('/meleze/data2/chari/Codes/CrowdAnalysis/Deva/tracking_cvpr11_release_v1.0/missing_gt2.mat') ;
else
	% tmp = load([datadir 'first500gt.mat']) ;
	tmp = load([datadir 'vid879gtdeva.mat']) ;
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

display('evaluating...')
[missr, fppi, findlin, ovval] = score(dres, gt2, people);
figure(1),
if ~mikeldata
	ff=find(fppi>3,1);
else
	ff=find(fppi>50,1);
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
	% load([datadir 'label_image_file']);
	load('/meleze/data2/chari/Codes/CrowdAnalysis/Deva/tracking_cvpr11_release_v1.0/data/label_image_file.mat')
	m=2;
	for i=1:length(bws)                   %% adds some margin to the label images
  		[sz1 sz2] = size(bws(i).bw);
  		bws(i).bw = [zeros(sz1+2*m,m) [zeros(m,sz2); bws(i).bw; zeros(m,sz2)] zeros(sz1+2*m,m)];
	end

	% input_frames    = [datadir 'seq03-img-left/image_%0.8d_0.png'];
	input_frames = '/meleze/data2/chari/Codes/CrowdAnalysis/Datasets/879-38-frames/frame%04d.jpg' ;
	output_path     = [cachedir '/'];
	output_vidname  = [cachedir vid_name '_dp_tracked.avi'];

	fnum = max(dres.fr);
	bboxes_tracked = dres2bboxes(dres, fnum);  %% we are visualizing the "DP with NMS in the lop" results. Can be changed to show the results of DP or push relabel algorithm.
	show_bboxes_on_video(input_frames, bboxes_tracked, output_vidname, bws, 4, -inf, output_path);
end

