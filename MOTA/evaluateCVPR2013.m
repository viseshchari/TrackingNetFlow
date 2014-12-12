function evaluateCVPR2013( seq, datadir ) 
% function evaluateCVPR2013( seq, datadir ) 

%% Evaluate tracking results 
% 
% evaluate tracking results for the paper
% "Detection- and Trajectory-Level Exclusion
% in Multiple Object Tracking". 
% A. Milan, K. Schindler, and S. Roth
% CVPR 2013
% 
% Note that the results for S2L2 and S1L2-1 reported in the paper are
% evaluated with a wrong ground truth. This script produces the correct
% numbers.

% set test sequence (1..6)
% seq=4;
% datadir='MOTA/data';

datasets={'PETS2009','PETS2009','PETS2009','PETS2009','PETS2009','TUD','PETS2009','PETS2009','TUD'};
sequences={'S2L1','S2L2','S2L3','S1L1-2','S1L2-1','Stadtmitte', 'S2L2', 'S2L1','Stadtmitte'};

fprintf('Evaluating %s %s...\n',datasets{seq},sequences{seq});
resfile=fullfile(datadir, ...
    sprintf('%s-%s-our-res.xml',datasets{seq},sequences{seq}));
gtfile=fullfile(datadir, ...
    sprintf('%s-%s-gt.xml',datasets{seq},sequences{seq}));
camfile=fullfile(datadir, ...
    sprintf('%s-calib.xml',datasets{seq}));

evaluateCVML(resfile,gtfile,camfile);
