function drawboxesinvideo( matfile, numtracks, inputframs, outputfolder )
% function drawboxesinvideo( matfile, numtracks, inputframs, outputfolder )

output_vidname = 'tracking_output.avi' ;

load(matfile) ; % the datastructure dres_dp is supposed to contain the tracking results.

idx = find( dres_dp.r > -numtracks ) ;
dres_dp = sub( dres_dp, idx ) ;

fnum = max(dres.fr) ;

bboxes_tracked = dres2bboxes( dres_dp, fnum ) ;

show_bboxes_on_video( inputframs, bboxes_tracked, output_vidname, [], 4, -inf, outputfolder ) ;

% input_frames    = [datadir 'seq03-img-left/image_%0.8d_0.png'];
% output_path     = [cachedir vid_name '_dp_tracked/'];
% output_vidname  = [cachedir vid_name '_dp_tracked.avi'];

% display(output_vidname)

% fnum = max(dres.fr);
% bboxes_tracked = dres2bboxes(dres_dp, fnfum);  %% we are visualizing the "DP with NMS in the lop" results. Can be changed to show the results of DP or push relabel algorithm.
% show_bboxes_on_video(input_frames, bboxes_tracked, output_vidname, bws, 4, -inf, output_path);
