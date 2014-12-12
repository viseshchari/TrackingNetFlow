function [dresnew, yhat2, dtall, apallmethods, statslocal] = redetectionEstimate( pm, model, x, y, glbvar, relaxloss )
% function dresnew = redetectionEstimate( pm, model, x, y, glbvar, relaxloss)
%  - relaxloss -> flag to use the new full y representation with sinks
%  - glbvar -> used in the maxFunction<> call e.g. to store global
%    variables & stats
%
% SLJ NOTE: I think the argument y is actually ignored usually!

if nargin < 5
	glbvar = 1 ;
end

if nargin < 6
	relaxloss = 0 ;
end

if glbvar
    global STATS;
	% trainerr ;
	% plotiter ;
	% yhatcell ;
end

% if norm(model.w) < 1e-5 
% 	model.w = pm.canonicalw ;
% 	c = [model.w(1) * double(x(pm.connids)) + model.w(2) ; ...
% 		model.w(3) * double(x(pm.detids)) + model.w(4) ; ...
% 		zeros( pm.nvars-length(y), 1 )] ;
% end

% ===== Get RELAXED solution:
yhat = pm.optimizationFn( pm, model, x, y, 0, relaxloss ) ; % no loss augmentation, just prediction
% last argument is new flag for the source/sink aspect.

% ===== Finally do 1 FW step ====
if ~isfield( pm, 'optstruct' )
    [c, Q2] = getweightedObjective( pm, model, pm.patterns{1} ) ;
else
    [c, Q2] = reweightCoefficients( pm.optstruct, model, 1 ) ;
end
% Q2 is now Q+Q' (paper notation).

if ~pm.linearrelaxation
	% if optimizationFn is a QP, Q2 constructed here is the matrix 2*A'*A, where A
	% mentioned in the ECCV paper.
	yhat2 = callCplexLPFlow( pm, c - Q2*yhat, [], 0, 0, 1 ) ;
else
	% solving the linear relaxation FW step here
	% Now Q2 only contains terms of the form Q(x, y) = || vx - vy ||^2

	%%%%%%% March 2
	% These codes do not make any difference to other formulations 
	% but prune these 3 matrix and vectors when we are computing loss for relaxed variables.
	if relaxloss
        if isfield( pm, 'optstruct' )
            pm.optstruct.A = [] ; pm.optstruct.b = [] ; % They need to be turned off since we 
            pm.optstruct.Aeq = pm.optstruct.Aeq( 1:size(pm.optstruct.Aeq, 1), 1:pm.nvars ) ;
            pm.optstruct.xl = pm.optstruct.xl(1:pm.nvars) ;
            pm.optstruct.xu = pm.optstruct.xu(1:pm.nvars) ;
        else
            pm.A = [] ; pm.b = [] ; % They need to be turned off since we 
            pm.Aeq = pm.Aeq(1:size(pm.Aeq,1), 1:pm.nvars) ; % remove extra equality variables if they existed
            pm.xl = pm.xl(1:pm.nvars) ;
            pm.xu = pm.xu(1:pm.nvars) ;
        end
    end
    if isequal( class(Q2), 'cell' )
        for i = 1 : length(Q2)
            if isequal( class(Q2{i}), 'sptensor' )
                if ~isempty( Q2{i}.subs )
                    c = c - sparse( double( ttv( Q2{i}, {yhat(1:pm.nvars), yhat(1:pm.nvars)}, [1 2] ) ) ) ;
                end
            else
                c = c - Q2{i}*yhat(1:pm.nvars) ;
            end
        end
        yhat2 = callCplexLPFlow( pm, c, [], 0, 0, 1 ) ;        
    elseif isequal( class(Q2), 'sptensor' )
        if ~isempty( Q2.subs )
            yhat2 = callCplexLPFlow( pm, c - sparse( double( ttv( Q2, {yhat(1:pm.nvars), yhat(1:pm.nvars)}, [1 2] ) ) ), [], 0, 0, 1 ) ;
        else
            yhat2 = callCplexLPFlow( pm, c, [], 0, 0, 1 ) ;
        end
    else
        yhat2 = callCplexLPFlow( pm, c - Q2*yhat(1:pm.nvars), [], 0, 0, 1 ) ;
    end
	fprintf('Just finished FW step!\n') ;
end
%yhat2 -> integer solution:
% 1e-10 seems to work for CPLEX, but for MOSEK only a less stringent 1e-5 works.
assert ( isempty( find ( yhat2 > 1e-10 & yhat2 < (1-1e-10), 1))); % check NO FRACTIONAL SOLUTION!
yhat2 = round(yhat2);  % to be safe...

% ========== computing statistics of prediction & rounding: ============
% (SLJ: copied back from predict.m function)
if pm.linearrelaxation
    % need to augment y with the relaxation quadratic variables for the
    % feature function.
    yint = augment_variable(pm, yhat2, relaxloss); % integer solution with same size as feature map input
    if (relaxloss)
        yrelaxed = yhat;
    else
        yrelaxed = yhat([1:(pm.nedgs+pm.ndets), (pm.nvars+1):(length(yhat))]); % remove source/sink variables
    end
    
else
    % QP formulation, no other possibilities
    yint = yhat2([1:(pm.nedgs+pm.ndets)]); % no extra quadratic variable needed.
    yrelaxed = yhat([1:(pm.nedgs+pm.ndets)]);
end

trainerr = pm.lossFn( pm, [], yint);
score_relaxed = dot(model.w, pm.featureFn( pm, pm.patterns{1}, yrelaxed ) ); 
score_integer = dot(model.w, pm.featureFn( pm, pm.patterns{1}, yint ) ); 
subopt = full(score_relaxed - score_integer);
%assert (suopt >= -1e-6) % we should have true uppert bound!
if (subopt < -1e-6)
    fprintf('NUMERICAL ISSUES! Suboptimality is very negative... TO INVESTIGATE!\n') ;
end
fprintf('Error of prediction: %1.3f\n', trainerr);
fprintf('Suboptimality: %0.5g\n', subopt);

% FW gap [this is a measure of how close to stationarity for the *QP*
% the relaxed LP solution yhat is. If the QP is convex, than this is an
% upper bound to the suboptimality of yhat for the *relaxed QP*. It is 
% a fairly different quantity than to the suboptimality certificate which has to
% do with *integer solutions*. We have the following inequalities which
% will always hold: 
%    integer certificate bound >= suboptimality QP(y*)-QP(yhat)
%           [maximizing QP; relaxed version]
%    now if QP is convex, we also have: FW_gap >= QP(y*)-QP(yhat)
%        if QP is not-convex, FW_gap is simply a 'stationary condition'
%        condition (a *necessary condition* to be a local min is FW_gap
%        = 0; though it is not sufficient)
% FW_gap(zhat) = max_{z in FLOW} <grad of QP(zhat), z-zhat> 
%[maximization QP version]    
if isequal( class(Q2), 'cell' )
    for i = 1 : length(Q2)
        if isequal( class(Q2{i}), 'sptensor' )
            if ~isempty( Q2{i}.subs )
                c = c - sparse( double( ttv( Q2{i}, {yhat(1:pm.nvars), yhat(1:pm.nvars)}, [1 2] ) ) ) ;
            end
        else
            c = c - Q2{i}*yhat(1:pm.nvars) ;
        end
    end
    FW_gap = dot( c, yhat2-yhat(1:pm.nvars) ) ;        
elseif isequal( class(Q2), 'sptensor' )
    if ~isempty( Q2.subs )
        FW_gap = dot(c - sparse( double( ttv( Q2, {yhat(1:pm.nvars), yhat(1:pm.nvars)}, [1 2] ))), yhat2-yhat(1:pm.nvars) ) ;
    else
        FW_gap = dot(c, yhat2-yhat(1:pm.nvars)) ;
    end
else
    FW_gap = dot(c - Q2*yhat(1:pm.nvars), yhat2-yhat(1:pm.nvars));
end

fprintf('FW gap criterion: %0.5g\n', FW_gap);

% computation of extra optimization stats -- need to reconstruct the
% yhat2 with the same number of variables as yhat; we now add the
% quadratic extra variables to the optimization one:

if (relaxloss)
    full_yhat2 = yint; % was already full dimensional
else
    % NOTE: yint is ndedges + ndets + nquadratic_variables [just doesn't have
    % source/sinks]
    % yint didn't have the source/sink variables, so bring them back
    % (or just have QP stuff with no need at the end.)
    full_yhat2 = [yhat2(1:pm.nvars); yint((pm.nedgs+pm.ndets+1):end)];
end
fprintf('-------------------- Extra optimization stats ---------------\n')
nfractional = length( find ( yhat > 1e-10 & yhat < (1-1e-10)));
number_flips = length( find ( abs(yhat - full_yhat2) > 1e-10 ) );
fprintf('Number of fractional variables in relaxed solution %d out of %d (%1.4f percent).\n', ... 
        nfractional, length(yhat), nfractional/length(yhat)*100);
fprintf('Number of flips after FW step %d out of %d (%1.4f percent). \n', ...
        number_flips, length(yhat), number_flips/length(yhat)*100);
fprintf('------------------------------------------------------------\n\n')
    
if glbvar
    if ~isfield( STATS, 'plotiter' )
        STATS.plotiter = 1 ;
    end
    % prediction stats:
    STATS.opt.subopt(STATS.plotiter) = subopt;
    STATS.opt.FW_gap(STATS.plotiter) = FW_gap;
    STATS.opt.score_integer(STATS.plotiter) = score_integer;
    STATS.opt.score_relaxed(STATS.plotiter) = score_relaxed;
    STATS.opt.nfractional(STATS.plotiter) = nfractional;
    STATS.opt.number_flipsl(STATS.plotiter) = number_flips;
    STATS.trainerr(STATS.plotiter) = trainerr;
	STATS.yhatcell{STATS.plotiter} = yhat2; % FW integer solution without quadratic variables
    statslocal = STATS ;
else
    statslocal.plotiter = 1 ;
    statslocal.opt.subopt(statslocal.plotiter) = subopt;
    statslocal.opt.FW_gap(statslocal.plotiter) = FW_gap;
    statslocal.opt.score_integer(statslocal.plotiter) = score_integer;
    statslocal.opt.score_relaxed(statslocal.plotiter) = score_relaxed;
    statslocal.opt.nfractional(statslocal.plotiter) = nfractional;
    statslocal.opt.number_flipsl(statslocal.plotiter) = number_flips;
    statslocal.trainerr(statslocal.plotiter) = trainerr;
    statslocal.yhatcell{statslocal.plotiter} = yhat2; % FW integer solution without quadratic variables
    statslocal = statslocal ;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Display Code %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~glbvar || pm.display
	[dresnew, dtall,apallmethods] = displayAndStoreTracks( pm, yhat2, model, glbvar ) ;
    if glbvar
        STATS.ap{STATS.plotiter} = apallmethods; % re-detection AP
        STATS.dt{STATS.plotiter} = dtall; % vector of dt for the plot
    end
end

