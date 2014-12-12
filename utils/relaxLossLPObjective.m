function objVec = relaxLossLPObjective( pm, c, y, lossaugment, onlyhamming, maxfunc )
% function objVec = relaxLossLPOjbective( pm, c, y, lossaugment, onlyhamming, maxfunc )

if nargin < 6
	maxfunc = 0 ; % by default only minimize
end

% This if condition has been added to cope with the new flexible code.
if isfield( pm, 'optstruct')
    xlen = length( pm.optstruct.xl ) ;
    nvars = pm.optstruct.nvars ;
    nrelax = pm.optstruct.nrelax ;
else
    xlen = length( pm.xl )
    nvars = pm.nvars ;
    nrelax = pm.nrelax ;
end

% append zeros of size 2*pm.ndets, to convert input to optimization variable.
if (lossaugment || onlyhamming) && (length(y) ~= xlen)
	error( 'relaxLossLPObjective::Length of y and xl should be the same!') ;
end

if lossaugment
    % Since now we compute loss with respect to *both* con./det. and source & sinks (but NOT quadratic)
	lossconst = pm.precWeight*[ones(nvars-pm.applen, 1); ones(pm.applen, 1); zeros(nrelax, 1)] ;
    
	% Loss augmented decoding. c + 1 - (1 + pm.beta) * y ; beta is supposed to be 1. variable from the ymore minimization legacy
	objVec = c + 1/pm.Lmax * ( lossconst - ( pm.precWeight + pm.beta ) * y ) ;
elseif onlyhamming
	% do loss minimization + score maximization
	% Here the variable pm.linSolRange is set before-hand by using the setSolutionRange function.
	if pm.debug && ( ~isfield(pm, 'linSolRange') || ~pm.linSolRange )
		error( 'relaxLossLPObjective::linSolRange not defined or is 0. Either way, please set it!') ;
    end
    % to get ytilde, we will also want to minimize the velocity term loss,
    % to get even better bias; even though while learning, we won't have a
    % loss on the quadratic variables...
    % NOTE: so this means that ymore used (for y) here *will be different*
    % - that's why we call it ymore_tilde -
    % than ymore used in the lossaugment part.
    shrink = 1; % before was 1e5
    fprintf('\n**Using shrink: %f **\n\n', shrink);
    lossconst = pm.precWeight*[ones(nvars-pm.applen, 1); ones(pm.applen, 1); ones(nrelax, 1)] ; %NOTE; rewriting lossconst from above!
	objVec = -c/pm.linSolRange/shrink       + lossconst - (pm.precWeight+pm.beta)* y  ; % will have accuracy of 1e-5 on the loss from this
else
	% do decoding (or prediction)
	objVec = c ;
end

if maxfunc
	objVec = -objVec ;
end
