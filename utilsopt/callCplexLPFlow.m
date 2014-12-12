function [yhat, fval, exitflag, output, lambda] = callCplexLPFlow( pm, c, y, lossaugment, onlyLoss, maxFunc )
% function [yhat, fval, exitflag, output, lambda] = callCplexLPOptim( pm, c, y, lossaugment, onlyLoss, maxFunc )
% Call cplex here for the function

if nargin < 6
	maxFunc = 1 ; % by default only maximize. 
end

if nargin < 5
	onlyLoss = 0 ; % by default don't just minimize the loss, do decoding or loss-augmented decoding.
	% Right now only loss minimizes whatever is defined by pm.lossObjective as 'only loss'.
end

if nargin < 4
	lossaugment = 0 ; % by default don't do loss augmented decoding.
end

% -- global warm start variables ---
% note that if they haven't been defined, they are initialized to [] by
% default of Matlab (I think!)
% SLJ NOTE: perhaps this can give error if we call CplexLPFlow with
% different dimensions -- not sure if the code will ever do that -- but be
% warned!
% SLJ: (implemented now -- but note that I didn't see any performance gain
% really!)
global ywarmLoss ; % for loss-augmented decoding problems
global ywarmRelaxed ; % for *relaxed* prediction problem
global ywarmPredict ; % for prediction problem (integer solution)

if lossaugment
    fprintf('**** Loss-augmented decoding!\n\n');
    ywarm = ywarmLoss;
else
    % are we doing relaxed or exact inference?
    if size(pm.A,2) == (pm.nvars + pm.optstruct.nrelax)
        fprintf('**** RELAXED prediction!\n\n');
        ywarm = ywarmRelaxed;
        doRelaxation = 1;
    else
        fprintf('**** FW prediction!\n\n');
        % this is an integer flow problem...
        ywarm = ywarmPredict;
        doRelaxation = 0;
    end
end

options = cplexoptimset( 'cplex' ) ;
% options = mskoptimset( 'mosek' ) ;
if pm.verbose
	options = cplexoptimset( options, 'diagnostics', 'on', 'lpmethod', 4, 'threads',10 ) ;
else
	options = cplexoptimset( options, 'diagnostics', 'off', 'lpmethod', 4, 'threads',10 ) ;
end

% options.MSK_IPAR_SIM_NETWORK_DETECT = 0 ;
% options.MSK_IPAR_OPTIMIZER = 7 ;
% options.MSK_IPAR_PRESOLVE_USE = 0 ;
% options.MSK_IPAR_SIM_SCALING = 0 ;
% fprintf('With ywarm\n') ;
if options.lpmethod == 5
	options.barcrossalg = 1 ;
end
h = pm.lossObjective( pm, c, y, lossaugment, onlyLoss, maxFunc ) ;
if isfield( pm, 'optstruct' )
    xlen = length(pm.optstruct.xl) ;
else
    xlen = length(pm.xl) ;
end

if length(h) ~= xlen
	error('xl problem with h\n') ;
end
% Now call CPLEX to compute the optimization
if isfield( pm, 'optstruct' )
    [yhat, fval, exitflag, output, lambda] = cplexlp( h, pm.optstruct.A, pm.optstruct.b, pm.optstruct.Aeq, pm.optstruct.beq, pm.optstruct.xl, pm.optstruct.xu, [], options ) ;
else
    [yhat, fval, exitflag, output, lambda] = cplexlp( h, pm.A, pm.b, pm.Aeq, pm.beq, pm.xl, pm.xu, [], options ) ;
end
% [yhat, fval, exitflag, output, lambda] = linprog( h, pm.A, pm.b, pm.Aeq, pm.beq, pm.xl, pm.xu, [], options ) ;
% store the warm start *from proper type*
if lossaugment
    ywarmLoss = yhat;
else
    if doRelaxation
        ywarmRelaxed = yhat;
    else
        ywarmPredict = yhat;
    end
end
