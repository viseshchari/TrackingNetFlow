%
% illustration of running person detection+tracking pipeline on dumped images

startup;

pattern       = '../detectiondata/Scene7/frame%04d.jpg';
sequence_name = 'Scene7';
output_folder = 'test-dir-out';
frames        = [1:56];
klt_tracking  = 1;

%merging_params = read_merging_params;
merging_params = [] ;

detector = @(mi, im, frame) DetectStillImage(...
                                             im, ...
                                             mi.start+mi.stepsz*(frame-1), ...
											 '../detectiondata/Scene7/Detections_PerFrame_five%04d.mat', ...
                                             '', ...
                                             merging_params);

videoinfo = getimagesinfo(pattern, frames, sequence_name, 1);
pipeline_fullvid(videoinfo, @imageread, detector, output_folder, frames, klt_tracking, -0.9);
