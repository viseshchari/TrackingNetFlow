function param = networkFlowSetup( datamat, gtmat, nTrcks, model, maxFr )
% function param = networkFlowSetup( datamat, gtmat, nTrcks, model, maxFr )

load( datamat ) ;
load( gtmat ) ;
param.ntrcks = nTrcks ;

if nargin == 4
	gt = sub( gt, find( gt.fr < maxFr ) ) ;
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
param.nedgs = nedgs ; % # edges
param.ndets = ndets ; % # detections
param.xs = xs ;		  % detections [x1 y1 x2 y2 conf] 
param.edge_xi = edge_xi ; % edge index into left detection
param.edge_xj = edge_xj ; % edge index into right detection
param.frids = frids ;	  % index into frame number for each detection.
param.gt = gt ; % adding ground truth data to param, so that it contains all information needed for evaluation
param.gtrect = [gt.x gt.y gt.x+gt.w gt.y+gt.h] ;
param.gtdets = length(gt.x) ;
param.alldets = alldets ;
param.Amats = Amats ;		% cell of edge confidences. Each cell element corresponds to a shot.
param.ovthresh = 0.5 ;
param.detstruct = computeTrackStructure( param.Amats ) ;
param.addBdryCond = 0 ; % Do you need to add boundary conditions to the optimization ?
optstruct.connids = 1:param.nedgs ; 
optstruct.detids = (param.nedgs+1):(param.nedgs+param.ndets) ;
param.linearrelaxation = 1 ; % currently this is not needed since linearrelaxation is always done.
							 % To be removed in the future.

param.optimizationFn = @optimizeLPFlexible ; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Flow Constraints %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nvars = param.nedgs + 3 * param.ndets ;
param.nvars = nvars ;
[Aeq_data, cntr] = flowInitialization( param.edge_xi, param.edge_xj, param.nedgs, param.ndets ) ;
% optstruct = struct( 'Aeq', [], 'beq', [], 'xl', [], 'xu', [], 'nvars', 0, 'A', [], 'b', [], 'Constraints', {}, 'ConstraintNames', {}, 'ConstraintOrder', [] ) ;
  
if ~param.addBdryCond
   [optstruct.xl, optstruct.xu, optstruct.Aeq, optstruct.beq, Aeq_data, cntr] = addFlowConstraints( param.xs, param.frids, Aeq_data, cntr, param.nedgs, param.ndets, param.nvars, param.ntrcks ) ;
	optstruct.nvars = length(optstruct.xl) ;
    param.nvars = optstruct.nvars ;
else
    [optstruct.xl, optstruct.xu, optstruct.Aeq, optstruct.beq] = addFlowAndBoundaryConstraints( param.xs, frids, [1150 1980], [80 80], Aeq_data, cntr, nedgs, ndets, param.ntrcks ) ;
    optstruct.nvars = nedgs+3*ndets+2 ;
    param.nvars = optstruct.nvars ;
end

% Assign loss, feature, constraint and optimization functions.
param.lossFn = @lossFunctionAugment
param.featureFn = @featureFunctionFlexible
param.constraintFn = @maxFunctionAugment
param.lossObjective = @relaxLossLPObjective

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
param.beta = 4 ; % recall mistake weight [will make more predictions...]
param.precWeight = 1; % precision mistake weight

%% NEW AUGMENTED FEATURES:
param.featureSink = 1; % this means that the sink/source features are included in input to feature function

%% %%%%%%%%%%%%%%%%%%%%% Add Quadratic or Linear Relaxation Costs / Constraints %%%%%%%%%%%%%%%%%%%%%%%%%
% [param.A, param.b, param.edge_velocity, optstruct.Constraints{2}.A_data, param.Q] = addSpatialRelaxedConstraints( param.detstruct, param.edge_xi, param.edge_xj, ...
%                                                         param.xs, param.frids, 0.5, param.nvars ) ;
% optstruct.ConstraintOrder = [1] ;    
%  [param.A, param.b, param.edge_velocity2, optstruct.Constraints{2}.A_data, param.Q] = addShapeQuadRelaxedConstraints( param.detstruct, param.xs, cat(1, double(cell2mat(edge_indices))'), param.edge_xi, param.edge_xj, ...
%                                                              param.nvars, param.nvars ) ; optstruct.ConstraintNames{2} = 'TemporalConstraint1' ;
[param.A, param.b, param.edge_velocity, optstruct.Constraints{1}.A_data, param.Q] = addOverlapRelaxedConstraintsOld( param.xs, param.frids, param.edge_xi, param.edge_xj, ...
					    0.9, param.nvars, param.nvars ) ; optstruct.ConstraintNames{1} = 'OverlapConstraint' ;
% [param.A, param.b, param.edge_velocity2, optstruct.Constraints{2}.A_data, param.Q] = addTemporalQuadRelaxedConstraints( param.detstruct, param.edge_xi, param.edge_xj, ...
% 														param.xs, param.frids, pi/2, param.nvars + size( optstruct.Constraints{1}.A_data, 1 ), param.nvars, 1 ) ; optstruct.ConstraintNames{2} = 'TemporalConstraint2' ;                    
param.canonicalw = [1;0;1;0;1] ;  
optstruct.ConstraintOrder = [1] ;
optstruct.nrelax = length(param.edge_velocity) ; 

%%%% IF YOU ADD MORE THAN ONE CONSTRAINT UNCOMMENT THESE LINES
% param.canonicalw = [1;0;1;0; % ADD AS MANY 1's here as there are number of constraints.
% optstruct.nrelax = length(param.edge_velocity) + length(param.edge_velocity2) + ... % add ass many
																					% terms as there are number of constraints
% optstruct.ConstraintOrder = [1 2 3 ... % add as many terms as there are number of constraints.


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

param.optstruct = optstruct ;
STATS.plotiter = 0 ;
