function [yint, yrelaxed] = predict( param, model, x, verbose, relaxloss)
% function [yint, yrelaxed] = predict( param, model, x, verbose, relaxloss)
% return MAP prediction -- yint = argmax_{y in Y} <model.w, phi(x,y)>
% 
% Output:
%   yint is the integer variable (after FW step) -- of same dimensionality as
%       needed for the input features
%   yrelaxed is the original relaxed solution (LP or QP before FW step)
%
%   dimension of output:
%       - QP format -> yint is simply edges/detections
%       - LP relaxed format -> 
%               old format:is both edges/detecdtions + quadratic variables (no sink/sources)
%               new augmented format (March 2): [with param.featureSink] -> also
%                   include sink/sources in the variable
%        yrelaxed has similar format
%
%
% optional arg:
%   verbose = 1 (default) prints train error & suboptimality certificate
%               for objective <w, phi(x,yint)>

pm = param; % will change local copy to remove some variables like pm.A, etc.)

if nargin < 5
    relaxloss = 0 ;
end

if nargin < 4
    verbose = 1;
end

% This is no longer important since featureSink is by default included.
if isfield(pm, 'featureSink')
    featureSink = pm.featureSink; % whether we include source/sinks in the y output
else
    featureSink = 0;
end

% SLJ NOTE: just cleaned-up version of the redetectionEstimate.m code from
% LearningToTrackNew/. as of 2014/02/28.

% ==== RELAXED MAP INFERENCE (fractional solutions) ====
% [yhat, fval, exitflag, output, lambda] 
yhat = pm.optimizationFn( pm, model, x, [], 0 , relaxloss) ; % no loss augmentation, just prediction

% =====
% SLJ SPAGHETTI CODING COMMENT (note to self and other readers! ;): the
% argument after x above (shoulde be a 'y') is, after a lot of different function calls,
% ignored in the pm.lossObjective function call as it was used *only*
% for adding the loss in loss-augmented decoding (which is off by setting 0
% ['addbeta' variable <- WTF a bad variable name for this; why not 'lossOn'
% or something]). So this is why we can pass [] to all these non-loss
% augmented decoding calls...
% =====

% SLJ: NOTE: remove randomization for now as we are NOT doing multiple FW
% search directions (so randomization is useless -- we only need to search
% once). Also, this means that our results are NOT reproducible as Visesh
% you were NOT storing the random seeds. This will make the results more
% stable for now (repeat runs should give the same results).

% Also, we do not need random perturbations for the LP case (though could
% check stability under random perturbationso of direction for
% suboptimality) -- but this is later...

% ===== Finally do 1 FW step =========
if ~isfield( pm, 'optstruct' )
    [c, Q2] = getweightedObjective( pm, model, pm.patterns{1} ) ;
else
    [c, Q2] = reweightCoefficients( pm.optstruct, model, 1 ) ;
end% note here that c doesn't have any augmented variable (no more relaxation)
% as we are doing simply the flow formulation... Will need to put back
% augmented variables later.
%
% Q2 = Q + Q' in the paper notation...

if ~pm.linearrelaxation
	% if optimizationFn is a QP

	% RANDOM OFF FOR NOW; [yhat2, fval2, exitflag2, output2, lambda2] = callCplexLPFlow( pm, c - Q2*yhat - (rand(length(c),1)-0.5)*max(Q2(:)), [], 0, 0, 1 ) ;
    yhat2 = callCplexLPFlow( pm, c - Q2*yhat, [], 0, 0, 1 );
else
	% solving the linear relaxation FW step here
	pm.A = [] ; pm.b = [] ; % Turn off the relaxation inequality constraints for the FLOW solving
	%[yhat2, fval2, exitflag2, output2, lambda2] = callCplexLPFlow( pm, c - Q2*yhat(1:pm.nvars) - (rand(length(c),1)-0.5)*max(Q2(:)), [], 0, 0, 1 ) ;    
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
    
    % note that 1 in arg at last is for MAXIMIZATION    
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
    
%     yhat2 = callCplexLPFlow( pm, c - Q2*yhat(1:pm.nvars), [], 0, 0, 1 ) ;
end
%yhat2 -> integer solution:
assert ( isempty( find ( yhat2 > 1e-10 & yhat2 < (1-1e-10), 1))); % check NO FRACTIONAL SOLUTION!
yhat2 = round(yhat2);  % to be safe...

if pm.linearrelaxation
    % need to augment y with the relaxation quadratic variables for the
    % feature function.
    yint = augment_variable(pm, yhat2, featureSink); % integer solution with same size as feature map input
    if (featureSink)
        yrelaxed = yhat;
    else
        yrelaxed = yhat([1:(pm.nedgs+pm.ndets), (pm.nvars+1):(length(yhat))]); % remove source/sink variables
    end
    
else
    % QP formulation, no other possibilities
    yint = yhat2([1:(pm.nedgs+pm.ndets)]); % no extra quadratic variable needed.
    yrelaxed = yhat([1:(pm.nedgs+pm.ndets)]);
end

if verbose
    % ----------
    % SLJ note: from redetection code, had something like: trainerr = pm.lossFn( pm, [], yint(1:(pm.nedgs+pm.ndets)) );
    % BUT lossFn code should handle the FULL y representation -- so no need
    % to trim here (should be trimmed in the loss code).
    % --- to remove comment when redectionEstimate.m code is fixed ----
    % trainerr = pm.lossFn( pm, [], yint);
    score_relaxed = dot(model.w, pm.featureFn( pm, pm.patterns{1}, yrelaxed ) ); 
    score_integer = dot(model.w, pm.featureFn( pm, pm.patterns{1}, yint ) ); 
    subopt = full(score_relaxed - score_integer);
    %assert (suopt >= -1e-6) % we should have true uppert bound!
    if (subopt < -1e-6)
        fprintf('NUMERICAL ISSUES! Suboptimality is very negative... TO INVESTIGATE!\n') ;
    end
    % fprintf('Error of prediction: %1.3f\n', trainerr);
    fprintf('Suboptimality certificate: %0.5g\n', subopt);
    
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

    if (featureSink)
        full_yhat2 = yint; % was already full dimensional
    else
        % NOTE: yint is ndedges + ndets + nquadratic_variables [just doesn't have
        % source/sinks]
        % yint didn't have the source/sink variables, so bring them back
        % (or just have QP stuff with no need at the end.)
        full_yhat2 = [yhat2(1:pm.nvars); yint((pm.nedgs+pm.ndets+1):end)];
    end
    fprintf('-- Extra optimization stats --\n')
    nfractional = length( find ( yhat > 1e-10 & yhat < (1-1e-10)));
    number_flips = length( find ( abs(yhat - full_yhat2) > 1e-10 ) );
    fprintf('Number of fractional variables in relaxed solution %d out of %d (%1.4f percent).\n', ... 
            nfractional, length(yhat), nfractional/length(yhat)*100);
    fprintf('Number of flips after FW step %d out of %d (%1.4f percent). \n', ...
            number_flips, length(yhat), number_flips/length(yhat)*100);
        
    if nfractional == 0 && pm.linearrelaxation
        yhat = round(yhat);
        
        if param.dimension > 4
            % verifying that y_ij = z_i * z_j [paper notation]
            % AS WE HAVE INTEGER SOLUTION FROM RELAXED PROBLEM (COOL!)
%             edge_firstindx = pm.Q_data(:, 1) ;
%             edge_secondindx = pm.Q_data(:, 2) ;
%             if pm.spatiotemporal
%                 edge_thirdindx = pm.Qt_data(:, 1) ;
%                 edge_fourthindx = pm.Qt_data(:, 2) ;
%             else
%                 edge_thirdindx = [];
%                 edge_fourthindx = [];
%             end
%             ycomp = [yhat(1:pm.nvars); ...
%                  yhat( edge_firstindx ) .* yhat( edge_secondindx ); ...
%                  yhat( edge_thirdindx ) .* yhat( edge_fourthindx ) ] ;
              ycomp = augment_variable( pm, yhat, pm.featureSink ) ;
            assert( isempty( find( yhat ~= ycomp, 1)  ) );
        end
        fprintf('Relaxed LP had integer solution: y_ij = z_i * z_j VERIFIED!\n')
    end
end


