function [c, Q] = reweightCoefficients( optstruct, model, reweight )
% function c = reweightCoefficients( optstruct, model )
% This function takes weights and reweights differnt parts of the coefficients
% and finally returns a vector which will then be used as the main
% objective minimized in the linear programming function callCplexLPFlow

if nargin < 3
    reweight = 0 ;
end

nEdgeDets = 4 ; % This variable indicates that the first 4 components of any model would be the 
                    % connection scale, connection bias, detection scale and detection bias.
                    
c = optstruct.initCoefficients ;
W = model.w ;
FS = optstruct.featScale ;
Q = sparse( optstruct.nvars, optstruct.nvars ) ;

%% First reweight the detection and connection ids
c( optstruct.connids ) = c( optstruct.connids ) * W(1) / FS(1) + W(2) / FS(2) ;
c( optstruct.detids ) = c( optstruct.detids ) * W(3) / FS(3) + W(4) / FS(4) ;

if length(W) == 4
    %% Finally check for the case where you just want to give back linear c and Q
    if reweight
        c = c( 1:optstruct.nvars ) ;
    end
    return ;
end

%% Now check whether a single weight has been passed to you or a bunch.
if ~optstruct.separateWeights
    %% If only a scale and a bias has been given and it has to be shared between all the terms.
    c( optstruct.nvars+1:end ) = -c( optstruct.nvars+1:end ) * W(5) / FS(5) ;
    if length(W) == 6 % we have a global bias term as well
        c( optstruct.nvars+1:end ) = -c( optstruct.nvars+1:end ) - W(6) / FS(6) ;
    end
else
    %% If separate scales and biases have been given to all the terms.
    c( optstruct.nvars+1:end ) = 0 ;
    for i = 1 : optstruct.nConstraints
        c( optstruct.nvars+1:end ) = c( optstruct.nvars+1:end ) - optstruct.Constraints{i}.Acoeff * W(nEdgeDets+i) / FS(nEdgeDets+i) ;
        if optstruct.separateBias
          c( optstruct.nvars+1:end ) = c( optstruct.nvars+1:end ) - W(nEdgeDets+i+optstruct.nConstraints) / FS(nEdgeDets+i+optstruct.nConstraints) ;
        end
    end
end

%% Finally check for the case where you just want to give back linear c and Q
if reweight
    if size( optstruct.uniqIndices, 2 ) == 2
        Q = sparse( optstruct.uniqIndices(:, 1), optstruct.uniqIndices(:, 2), -c( optstruct.nvars+1:end ), optstruct.nvars, optstruct.nvars ) ;
        Q = Q + Q' ;
    else
        display('in sptensor')
        idx = find( optstruct.uniqIndices(:, 1) ~= 0 ) ;
        Q1 = sptensor( optstruct.uniqIndices(idx, 1:3), -c( optstruct.nvars+idx ), [optstruct.nvars optstruct.nvars, optstruct.nvars] ) ;
        Q2 = sptensor( optstruct.uniqIndices(idx, [2 1 3]), -c( optstruct.nvars+idx ), [optstruct.nvars optstruct.nvars, optstruct.nvars] ) ;
        Q3 = sptensor( optstruct.uniqIndices(idx, [1 3 2]), -c( optstruct.nvars+idx ), [optstruct.nvars optstruct.nvars, optstruct.nvars] ) ;
        Q4 = sptensor( optstruct.uniqIndices(idx, [3 2 1]), -c( optstruct.nvars+idx ), [optstruct.nvars optstruct.nvars, optstruct.nvars] ) ;
        clear Q ;
        Q{1} = Q1 + Q2 + Q3 + Q4 ;
        
        idx = find( optstruct.uniqIndices(:, 1) == 0 ) ;
        Q1 = sparse( optstruct.uniqIndices(idx, 2), optstruct.uniqIndices(idx, 3), -c( optstruct.nvars+idx ), optstruct.nvars, optstruct.nvars ) ;
        Q{2} = Q1+Q1' ;
    end
    
    c = c( 1:optstruct.nvars ) ;
end