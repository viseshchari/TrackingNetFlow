function delta = lossFunctionAugment( pm, y, ybar, useymore )
% function delta = lossFunctionAugment( param, y, ybar, useymore )
% By default we use ymore for computing loss.
%
% This means that the second argument to this function (y) always remains unused.
% however for specific calls to the function, one might need to use (y) 
% instead of ymore. In such cases, set useymore to 0
% In case useymore is set to 0, the loss function returned is not scaled.
%
% TRUNCATED LOSS: we only use Hamming on edges/detections & sinks/sources,
% not on quadratic variables...
%
% Added pm.beta coefficient -- set pm.beta > 1 to weight more recall
% mistakes...
% pm.precWeight -> precision mistake weight

if nargin < 4
	useymore = 1 ;
end

if useymore
	y = pm.ymore ;
end

% trim variables to avoid quadratic variables:
y = y(1:pm.nvars);
ybar = ybar(1:pm.nvars);

if ~isfield( pm, 'precWeight' )
	pm.precWeight = 1.0 ; % by default set the normal precWeight
end

% if pm.debug && useymore
% 	assert( pm.Lmin > eps ) ; % alert if Lmin is small
% end

if useymore
    % scaled loss with respect to ymore:
	delta = ( sum( pm.beta*y.*(1-ybar) + pm.precWeight*ybar.*(1-y) ) - pm.Lmin ) / pm.Lmax ; 
else
	delta = sum( pm.beta*y.*(1-ybar) + pm.precWeight*ybar.*(1-y) ) ; % vanilla hamming loss
end

% SLJ: REMOVED below as it doesn't make sense to have all these global
% tracking in subfunctions --- I have put this in the maxFunction
% instead...
% if pm.debug
% 	global plotiter ;
% 	global lossvar ;
%
% 	lossvar(plotiter) = delta ;
% end
