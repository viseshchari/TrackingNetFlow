%%
clear all ; close all ;
addpath('./SVMStruct') ;
addpath('./utils/') ;
addpath('./utilsopt/') ;
addpath('./utils/trackeval/trackdeteval/scripts/');
addpath('./SimonSolver/helpers') ;
addpath('./SimonSolver') ;
CPLEXPATH = '/meleze/data2/chari/Codes/CrowdAnalysis/PartBasedModel/Optimization/cplex/cplex125/cplex/matlab' ;
% CPLEXPATH = '/meleze/data2/chari/Codes/CrowdAnalysis/PartBasedModel/Optimization/mosek/7/toolbox/r2012a/' ;
addpath(CPLEXPATH) ;
addpath('./Tensor/tensor_toolbox_2.5') ;
% Needs better structuring, comments
LONG = 0; % to choose long dataset

% First load all the data that is going to be input into the SVM.
if LONG
    fprintf('Loading LONG dataset...\n');
%     load('Data/scene_data7') ;
    load('Data/scene_data7_2') ; param.ntrcks = 81 ;
    load('Data/scene_gt7_2') ; 
    gt = sub( gt, find( gt.fr < 107 ) ) ;
else
    fprintf('Loading SHORT dataset...\n');
%     load('Data/scene_datashort879') ;
%     load('Data/scene_dataTCH7short.mat') ; param.ntrcks = 129 ; % data4short with 30 and data3short with 10
%     load('Data/scene_gtTCH.mat' ) ;
%     gt = sub( gt, find( gt.fr < 2206 ) ) ;
%     xs(:,5) = 0.1 ;
      load('Data/pets_s1l2p1.mat') ; param.ntrcks = 50 ;
      load('Data/pets_s1l2p1_gt.mat') ;
      % load('Data/pets_s1l2p1heads2_xs2.mat') ;
      % xs = [round(xs2(:, [1:4])) xs2(:, 6)] ;
%       load('Data/tud_dataset2.mat') ;
%       load('Data/tud_dataset2_gt.mat') ; param.ntrcks = 15 ;
%     load('Data/pets_s1l1p2') ; param.ntrcks = 47 ; 
%     load('Data/pets_s2l1_norm2') ;
%     load('Data/pets_s1l1p2_gt') ; 
%       load('Data/tuds_full.mat') ; param.ntrcks = 14 ;
%       load('Data/tuds_gt.mat') ; gt.r = gt.id ;
% 	  load('Data/tuds_flow.mat') ;
% 	  detflow = zeros( ndets, 2 ) ;
% 	  edgeflow = zeros( nedgs, 2 ) ;
% 	  wtmp = xs(:, 3) - xs(:, 1) ;
% 	  htmp = xs(:, 4) - xs(:, 2) ;
% 	  for i = 1 : length(xflow)
% 		  % first truncate flow vectors.
% 		  xf = xflow{i}(1:(end-int32(htmp(i)/3)), (1+int32(wtmp(i)/3)):(end-int32(wtmp(i)/3))) ;
% 		  yf = yflow{i}(1:(end-int32(htmp(i)/3)), (1+int32(wtmp(i)/3)):(end-int32(wtmp(i)/3))) ;
% 		  % then take median.
% 		  detflow(i, 1) = median( xf(:) ) ;
% 		  detflow(i, 2) = median( yf(:) ) ;
% 	  end
% 	  edgeflow(:,1) = detflow(edge_xj, 1)-detflow(edge_xi, 1) ;
% 	  edgeflow(:,2) = detflow(edge_xj, 2)-detflow(edge_xi, 2) ;
%     gt = sub( gt, find( gt.fr < 56 ) ) ;
%     gt = sub( gt, find( gt.fr < (max(frids)+1) ) ) ;
end
    
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% GLOBAL DISPLAY VARIABLES SET HERE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% global variables that store the various values that could be then plot
% after the end of the optimization.
global STATS; % global structure with fields:

% ploiter NEEDS to be set-up for code to work... 
STATS.plotiter = 0 ; % first call in maxFunction is plotiter = plotier + 1;

% NOTE ON plotiter:
% at each loss-augmented call, we store current model, its duality gap, the
% step-size that will be taken for the update, its loss, etc.

%%
% Add all variables to the param structure.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Graph Variables %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
param.nedgs = nedgs ;
param.ndets = ndets ;
param.xs = xs ;
param.edge_xi = edge_xi ;
param.edge_xj = edge_xj ;
param.frids = frids ;
param.gt = gt ;
param.gtrect = [gt.x gt.y gt.x+gt.w gt.y+gt.h] ;
param.gtdets = length(gt.x) ;
param.alldets = alldets ;
param.Amats = Amats ;
param.ovthresh = 0.5 ;
param.detstruct = computeTrackStructure( param.Amats ) ;
param.addBdryCond = 0 ; % Do you need to add boundary conditions to the optimization ?
optstruct.connids = 1:param.nedgs ; 
optstruct.detids = (param.nedgs+1):(param.nedgs+param.ndets) ;
param.linearrelaxation = 1 ;

param.optimizationFn = @optimizeLPFlexible ; param.canonicalw = [1;0;1;0;1;1] ; 
% param.optimizationFn = @optimizeLPSpatial ; param.canonicalw = [1;0;1;0;0] ; options.positivity_indices = [5] ; param.onlyquadscaling = 1 ; param.ntrcks = 40 ;
% param.optimizationFn = @optimizeLPSpatiotemporal ; param.canonicalw = [1;0;1;0;0;0] ; param.onlyquadscaling = 1 ; param.ntrcks = 41 ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Flow Constraints %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nvars = param.nedgs + 3 * param.ndets ;
param.nvars = nvars ;
[Aeq_data, cntr] = flowInitialization( param.edge_xi, param.edge_xj, param.nedgs, param.ndets ) ;
% optstruct = struct( 'Aeq', [], 'beq', [], 'xl', [], 'xu', [], 'nvars', 0, 'A', [], 'b', [], 'Constraints', {}, 'ConstraintNames', {}, 'ConstraintOrder', [] ) ;
  
if ~param.addBdryCond
   [optstruct.xl, optstruct.xu, optstruct.Aeq, optstruct.beq, Aeq_data, cntr] = addFlowConstraints( param.xs, param.frids, Aeq_data, cntr, param.nedgs, param.ndets, param.nvars, param.ntrcks ) ;
	optstruct.nvars = length(optstruct.xl) ;
    param.nvars = optstruct.nvars ;
	% param.xl = zeros(nvars, 1) ;
	% param.xu = ones(nvars, 1) ;
else
	%[param.xl, param.xu, param.Aeq, param.beq] = addFlowAndBoundaryConstraints( param.xs, frids, [1024 1280], [100 100], Aeq_data, cntr, nedgs, ndets, param.ntrcks ) ;
	% SLJ: CHANGED TO:
    % this was based on: max center position in full temporal dataset:
    % [1033 770]
    % -- 80 pixels seem enough to have all new starting tracks... 
%     [optstruct.xl, optstruct.xu, optstruct.Aeq, optstruct.beq] = addFlowAndBoundaryConstraints( param.xs, frids, [1033 770], [80 80], Aeq_data, cntr, nedgs, ndets, param.ntrcks ) ;
    [optstruct.xl, optstruct.xu, optstruct.Aeq, optstruct.beq] = addFlowAndBoundaryConstraints( param.xs, frids, [1150 1980], [80 80], Aeq_data, cntr, nedgs, ndets, param.ntrcks ) ;
    optstruct.nvars = nedgs+3*ndets+2 ;
    param.nvars = optstruct.nvars ;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SSVM Parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Assign loss, feature, max violated constraint and optimization functions.

%% %%%%% March 2: Change in these functions from previous scripts
param.lossFn = @lossFunctionAugment
param.featureFn = @featureFunctionFlexible
param.constraintFn = @maxFunctionAugment
param.lossObjective = @relaxLossLPObjective

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
param.beta = 4 ; % recall mistake weight [will make more predictions...]
param.precWeight = 1; % precision mistake weight

%% NEW AUGMENTED FEATURES:
param.featureSink = 1; % this means that the sink/source features are included in input to feature function
ylabel = matchDataToGTAll( param.xs, param.frids, param.edge_xi, param.edge_xj, param.gt, param.ovthresh, param.featureSink ) ; % last argument indicates relax loss

%% %%%%%%%% Function call to add strong conditions on start and end of tracks in ytilde
% if ~param.addBdryCond
% 	% currently it is not known how the boundary conditions will affect, the new flow settings.
% 	% so disable adding of strong track constraints 
% 	[param.yAeq, param.ybeq, param.yAeq_data] = addStrongTrackConstraints( param, gt, ylabel ) ;
% 	% convert ylabel back to 0-1 binary vector since it was modified in matchDataToGTAll to contain 
% 	% integers not belonging to the set [0, 1] ;
% else
% 	fprintf( 'Strong track constraints not enabled. Do you really want to do this ?') ;
% 	keyboard ;
% end
ylabel = (ylabel > 0); 
% ylabel now contains an entire set of flows from connections to detections to source and sink links

%% %%%%%%%%%%%%%%%%%%%%% Add Quadratic or Linear Relaxation Costs / Constraints %%%%%%%%%%%%%%%%%%%%%%%%%
%%%% when threshold is 0.0, only overlap matters!
optstruct.ConstraintOrder = [1 2] ;
% [param.A, param.b, param.edge_velocity, optstruct.Constraints{1}.A_data, param.Q] = addSpatialRelaxedConstraints( param.detstruct, param.edge_xi, param.edge_xj, ...
%                                                         param.xs, param.frids, 0.5, param.nvars ) ;
% [param.A, param.b, param.edge_velocity2, optstruct.Constraints{3}.A_data, param.Q] = addTemporalTriRelaxedConstraints( param.detstruct, param.xs, param.frids, param.edge_xi, param.edge_xj, ...
%                                                             param.nvars, param.nvars ) ; optstruct.ConstraintNames{3} = 'TemporalConstraint1' ;
% keyboard ;                                                   
% optstruct.ConstraintOrder = [1] ;    
%  [param.A, param.b, param.edge_velocity2, optstruct.Constraints{2}.A_data, param.Q] = addShapeQuadRelaxedConstraints( param.detstruct, param.xs, cat(1, double(cell2mat(edge_indices))'), param.edge_xi, param.edge_xj, ...
%                                                              param.nvars, param.nvars ) ; optstruct.ConstraintNames{2} = 'TemporalConstraint1' ;
[param.A, param.b, param.edge_velocity, optstruct.Constraints{1}.A_data, param.Q] = addOverlapRelaxedConstraintsOld( param.xs, param.frids, param.edge_xi, param.edge_xj, ...
					    param.ovthresh, param.nvars, param.nvars ) ; optstruct.ConstraintNames{1} = 'OverlapConstraint' ;
% [param.A, param.b, param.edge_velocity2, optstruct.Constraints{2}.A_data, param.Q] = addNewflowConstraint( param.detstruct, param.edge_xi, param.edge_xj, ...
% 														edgeflow, param.xs, param.frids, 1.5, param.nvars + size( optstruct.Constraints{1}.A_data, 1 ), param.nvars, 1 ) ; optstruct.ConstraintNames{2} = 'TemporalConstraint2' ;                    
[param.A, param.b, param.edge_velocity2, optstruct.Constraints{2}.A_data, param.Q] = addTemporalQuadRelaxedConstraints( param.detstruct, param.edge_xi, param.edge_xj, ...
														param.xs, param.frids, pi/2, param.nvars + size( optstruct.Constraints{1}.A_data, 1 ), param.nvars, 1 ) ; optstruct.ConstraintNames{2} = 'TemporalConstraint2' ;                    
optstruct.nrelax = length(param.edge_velocity) + length(param.edge_velocity2) ;
optstruct.featScale = max(frids)*param.ntrcks*ones(length(param.canonicalw), 1) ;
optstruct = organizeConstraints( optstruct ) ;

% dimension in which learning is done.
param.dimension = length(param.canonicalw) ;
 
%% patterns contaings the optimization coefficients. First concatenate all edge confidences, then all
% detection confidences.
param.patterns = {} ;
% SLJ: for later, could include all features in patterns; but for
% back-compatibility, just keep using edge_velocity for quadratic term...
param.patterns{1} = [cat(1, double(cell2mat(edge_indices))'); xs(:, 5)];
optstruct.initCoefficients = zeros( optstruct.nvars + optstruct.nrelax, 1 ) ;
optstruct.initCoefficients( optstruct.connids ) = cat(1, double(cell2mat(edge_indices))') ;
optstruct.initCoefficients( optstruct.detids ) = xs(:, 5) ;
optstruct.initCoefficients( optstruct.nvars+1:end ) = optstruct.coeffSum ;
optstruct.separateWeights = 1 ;
optstruct.separateBias = 0 ;
param.labels = {} ;

%% SLJ: IMPORTANT MODEL ASPECT:
% - to get ytilde, we use full ymore, because we use a loss with quadratic
%   variables
% - but during learning, the loss doesn't include quadratic variables.
%-- ymore_tilde is used as loss reference to ytilde; ymore is the one used
% in the standard loss.
ylabelAdd = computeGTConstraintValue( ylabel, optstruct ) ;
ymore_tilde = [ylabel; ylabelAdd]; % ylabel(edge_thirdindx).*ylabel(edge_fourthindx)] ;
ymore = ymore_tilde;
ymore(param.nvars+1:end) = 0; % loss doesn't include the augmented variables here

%% --- SHORTCIRCUIT HANDLING IN LOSS (because they are not 0-1 variables! --
ymore(param.nvars-1:param.nvars) = param.precWeight/(param.precWeight+param.beta);% THIS IS FOR THE SHORT CIRCUIT TO BE IGNORED in the loss...
ymore_tilde(param.nvars-1:param.nvars) = param.precWeight/(param.precWeight+param.beta);
%--------------------------------------------------------------------
param.ymore = ymore; % this is reference point for general loss-augmentation
param.ytilde = ymore; % TEMPORARY ASSIGNMENT -- this is because some functions might look at size of ytilde to make decisions; this will be overwritten below...

%% spit out information while processing
param.verbose = 1 ; % print optimization progress.
param.display = 1 ; % displ ay progress of w, hinge loss, hamming loss
%%%% Never turn debug off %%%%
%%%% because it just stores intermediate variables %%%%%
param.debug = 1 ; % for each iteration of the optimization compute and store prediction. 
param.predict = 1 ; % do prediction and store its result with corresponding tracks.

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Some useful variables %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% size difference between feature length used for learning, and size of optimization varibale.
param.applen = optstruct.nvars - param.nedgs - param.ndets ;
param.Lmin = 0 ; param.Lmax = 1 ;
optstruct.Aeq = [optstruct.Aeq sparse(size(optstruct.Aeq,1), optstruct.nrelax)] ;
optstruct.xl = [optstruct.xl; zeros(optstruct.nrelax, 1)] ;
optstruct.xu = [optstruct.xu; ones(optstruct.nrelax, 1)] ;

%% Setting the other variables needed to compute ytilde 
%[param.linSolRange, min_score, max_score, ymin, ymax] = setSolutionRange( param) ; % get max feasible score - min feasible score; this gives max variation for scores;
param.linSolRange = 10; % (as computing ymin is too slow...)
relaxloss = 1; % flag for augmented variable stuff
noMax = 1; % do not compute Lmax (too slow) -- just use 2*||ytilde||_1
old_scale = optstruct.featScale(5:end);
optstruct.featScale(5) = 1e-5; % to make the overlap constraints HARD for ytilde:
optstruct.featScale(6) = 1e-1 ;
model_yt.w = [1,0,1,0,1,1]'; % which weighting to use to get ytilde

param.optstruct = optstruct ;
keyboard ;
[param.ytilde, param.Lmin, param.Lmax, param.Lopt] = findFeasibleSolutionAndBounds( param, ymore_tilde, relaxloss, noMax, model_yt) ;
param.optstruct.featScale(5:end) = old_scale;
optstruct.featScale(5:end) = old_scale ;

param.labels{1} = param.ytilde ; % ytilde is used to CONSTRUCT FEATURES [and is different than pm.ymore which is used to compute loss...]
fprintf('Built ytilde\n') ;
keyboard;
%% Start the Learning Algorithm
start_time = tic;
% previous code:
%model = solverFW( param, options ) ; % previous solver (handles
                                      % positivity constraints)

% --------- TO USE SVMStruct now --------------------
% only options needed:
options.lambda = 0.01; %0.05; 
options.gap_threshold = 0.001; % SLJ suggestion...
% some stats: (March 4th 03h00): on small video temporal, converges to 0.01
% in 14 iterations, 1e-3 in 20; 1e-4 in 28. 1e-3 seemed more stable
% solution. Not sure how it generalizes to longer video?
param.stopIter = 200; % this stops SVMStruct when STATS.plotiter reaches this count (in the maxFunctionAugment.m function)\
STATS.plotiter = 0; % just to be sure it is reset before running code again...
model = solverSVMstruct( param, options ) ; % cutting plane (faster) -- but doesn't handle positivity constraints...
%------------------------------------------------------------

learning_time = toc(start_time);
fprintf('Learning time took %d minutes.\n', learning_time/60);
