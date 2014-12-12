function c = reweightObjective( optstruct, model )
% function c = reweightObjective( optstruct, model )
% This function reweights all the various contributions to the linear term, and return them as the
% output.
% Input
% 'optstruct' - structure with the following fields.
%           'featScale'
%           'nvars'
%           'nConstraints'
%           'detids'
%           'connids'
%           'Constraints'
%           'initCoeffs'


%% Some variable definitions and basic checks and and balances.
c = optstruct.initCoeffs ;
nEdgeDetCoeff = 4 ; % used later. Ideally this variable should be set in optstruct. But for now this is OK.

%% Fill out the weights for the edge and connection coefficients.
c( optstruct.connids ) = model.w(1) / optstruct.featScale(1) * c( optstruct.connids ) + model.w(2) / optstruct.featScale(2) ;
c( optstruct.detids ) = model.w(3) / optstruct.featScale(3) * c( optstruct.detids ) + model.w(4) / optstruct.featScale(4) ;

%% Now check if there are only 2 weights (or 1 weight) or more.
% Ideally, there should be a set of strings preferrably in optstruct
% which shows what weight should be used for what set of coefficients (& whether it should be scale or
% bias). But right now let's just keep it simple.
if length( model.w ) <= 6
    % In this section weight all the linear relaxation coefficients with the same scale.
    if length( model.w ) == 5
        c( optstruct.nvars+1:end ) = model.w(5) / optstruct.featScale(5) * c( optstruct.nvars+1:end ) ;
    else
        c( optstruct.nvars+1:end ) = model.w(5) / optstruct.featScale(5) * c( optstruct.nvars+1:end ) + model.w(6) / optstruct.featScale(6) ;
    end
else
    if length( model.w )-nEdgeDetCoeff == optstruct.nConstraints
        % Every additional linear term is weighted separately.
        for i = 1 : optstruct.nConstraints
            c( optstruct.nvars+1:end ) = model.w(i+nEdgeDetCoeff) / optstruct.featScale(i+nEdgeDetCoeff) * optstruct.Constraints{i}.Acoeff ;
        end
    else
        % Assume that both scales and biases are given for all additional linear terms.
        for i = 1 : optstruct.nConstraints
            c( optstruct.nvars+1:end ) = model.w(2*(i-1)+nEdgeDetCoeff) / optstruct.featScale(2*(i-1)+nEdgeDetCoeff) * optstruct.Constraints{i}.Acoeff + model.w(2*i+nEdgeDetCoeff) / optstruct.featScale(2*i+nEdgeDetCoeff) ;
        end
    end
end