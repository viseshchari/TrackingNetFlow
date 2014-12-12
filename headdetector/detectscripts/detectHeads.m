function detectHeads( model, imgfmt, matfmt, nImages, detthresh )
% function detectHeads( model, imgfmt, matfmt, nImages, detthresh )


%%%%% Model sbin and features.extra_octave are the two parameters
%%%%% that can be used to model how the detector works.
% model.sbin = 4 ;
model.features.extra_octave = 1 ;

for i = 1 : nImages
	im = imread( sprintf( imgfmt, i ) ) ;
	[bxs, ds, ts, sce] = imgdetect( im, model, detthresh ) ;
	save( sprintf( matfmt, i ), 'bxs', 'ds', 'ts', 'sce' ) ;
end

%%%% Parallel processing. Only if you are using the APT toolbox.
% imcntr = 1 ;
% cntr = 1 ;
% nThreads = 15 ;
% for i = 1 : nImages
% 	imnext{imcntr} = imread( sprintf( imgfmt, i ) ) ;
% 	imcntr = imcntr + 1 ;
% 	if ~rem( i, nThreads )
% 		[bulkbxs, bulkds, bulkts, bulksce] = APT_run( 'imgdetect', imnext, {model}, {detthresh}, 'UseCluster', 1, 'NJobs', nThreads, 'ClusterID', 2, 'Memory', 17000 ) ;
%		for j = 1 : nImages
%			bxs = bulkbxs{end-j+1} ;
%			ds = bulkds{end-j+1} ;
%			ts = bulkts{end-j+1} ;
%			sce = bulksce{end-j+1} ;
%			save( sprintf( matfmt, i-j+1 ), 'bxs', 'ds', 'ts', 'sce' ) ;
%		end
% 		imcntr = 1 ;
% 		cntr = cntr + 1 ;
% 	end
% end
%
