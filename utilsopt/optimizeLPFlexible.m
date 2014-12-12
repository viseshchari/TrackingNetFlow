function [yhat, fval, exitflag, output, lambda, c] = optimizeLPFlexible( pm, model, x, y, lossaugment, relaxloss, onlyLoss, maxFunc )
% function [yhat, fval, exitflag, output, lambda, c] = optimizeLPFlexible( pm, model, x, y, lossaugment )
% This function optimizes the spatial term minimizing velocity differences between connections in the same frame.
%
% Input arguments:
% pm - Datastructure that stores all the optimization variables / parameters.
% model - Datastructure that stores the weight vector to be multipled with costs in the optimization.
% x - costs used in the optimization.
% y - ground truth w.r.t which we are minimizing the loss
% lossaugment - binary variable that indiciates whether to do loss augmented decoding or just plain decoding.
% relaxloss - binary variable that indicates whether we are just minimizing loss w.r.t connections + detections
%				or whether are minimizing w.r.t all optimization variables, connections + detections + source-sink
%				links + augmented variables
%
% Output arguments:
% yhat - optimal solution.
% fval - function value at optimal point.
% exitflag - optimization output indicating nature of solution (converged or not, see cplexlp for more information)
% output - optimization output structure indicating properties of the solution.
% lambda - dual parameter used in optimization.
% c - final linear cost optimized by callCplexLPFlow. 

%% Basic checks and balances + declaration of some variables.
if nargin < 5
	lossaugment = 1 ; % By default do loss augmented decoding.
end

if nargin < 6
	relaxloss = 0 ; % By default don't include relaxation variables in computing loss augmented decoding.
	% Essentially this means that I expect the variable y to be structured as follows
	% relaxloss = 0 ; y = [connections; detections] 
	% 					Hence we need to append it with pm.applen (Append Length!) zeros, to make it a
	%					a valid flow optimization variable.
	% relaxloss = 1 ; y = [connections; detections; source-sink links; augmented variables]
end

if nargin < 7
    % SAME DEFAULT from callCplexLPFlow:
    onlyLoss = 0;
    maxFunc = 1;
end

xedgs = double( x( 1:pm.nedgs ) ) ;
xdets = double( x( (pm.nedgs+1):(pm.nedgs+pm.ndets) ) ) ; 

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scale the linear relaxed data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% construct coefficient vector with following operation.
c = reweightCoefficients( pm.optstruct, model ) ;
if ~relaxloss
	y = [y; zeros( pm.applen, 1 )] ; % append zeros for source links and sink links.
end

if ~relaxloss
	% This appending is not necessary if all variables are being optimized.
	% So please ensure that augmented variables are added to these datastructures
	% before calling the learning code!!
	y = [y; zeros(pm.optstruct.nrelax, 1)] ; 
	pm.optstruct.xl = [pm.optstruct.xl; zeros(pm.optstruct.nrelax, 1)] ;
	pm.optstruct.xu = [pm.optstruct.xu; ones(pm.optstruct.nrelax, 1)] ;
	pm.optstruct.Aeq = [pm.optstruct.Aeq sparse(size(pm.Aeq,1), pm.optstruct.nrelax)] ;
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Set up optimization function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[yhat, fval, exitflag, output, lambda] = callCplexLPFlow( pm, c, y, lossaugment, onlyLoss, maxFunc ) ;

if pm.verbose
	% Computation of extra optimization stats -- 
	nfractional = length( find ( yhat > 1e-10 & yhat < (1-1e-10))) ;
	fprintf('@optimizeLPFlexible::Number of fractional variables in relaxed solution %d out of %d (%1.4f percent).\n', ... 
	        nfractional, length(yhat), nfractional/length(yhat)*100);
end
