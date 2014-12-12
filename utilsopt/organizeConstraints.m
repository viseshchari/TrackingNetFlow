function optstruct = organizeConstraints( optstruct )
% function optstruct = organizeConstraints( optstruct )
% This function reorganizes the inequality constraints and consolidates the variables used to depict it. This makes sure that the relaxation
% is as tight as possible, and also allows us to add inequality constraints in any manner of choice.
% Input
% 'optstruct' - structure with the following elements.'
%           'Constraints' - cell of structures which contain one component.
%                           - 'A_data'  - n x 3 matrix containing entries to the function 'sparse' to create a sparse matrix.
%           'ConstraintNames' - cell of strings containing names of all the constraints. Mostly just for display purposes.
%           'ConstraintOrder' - order in which constraints have to be added into the main optimization function.
%           'nvars' - total number of variables excluding relaxation variables, since this argument is used by
%                       composeRelaxationConstraints function called in this function.
% Output
% 'optstruct' - same structure as input with the following additional parameters
%            'A' - sparse matrix that is the final matrix that consolidates all the linear constraints.
%            'b' - vector that would represent the limits for all inequality constraints. 
%                   Inequality constraints in the final optimization will be A x <= b
%            'nrelax' - number of variables present in the inequality constraints.
%            'Acoeff' - addition to the cell 'Constraints'
%                       represents the contribution of individual constraints to the final set of linear
%                       relaxation variables.

%% Create local variables and establish basic checks and balances and some basic initialization
nConstraints = length(optstruct.ConstraintOrder) ;
optstruct.BackTrackIndices = {} ;
optstruct.uniqIndices = [] ;
optstruct.A = sparse(0,0) ;
optstruct.b = [] ;
optstruct.nrelax = 0 ;
optstruct.coeffSum = [] ;
optstruct.nConstraints = nConstraints ;

if ~nConstraints
    return ;
end

% First check whether the number and order of constraints is consistent.
if nConstraints ~= length(unique(optstruct.ConstraintOrder))
    error('Constraints have not been ordered properly') ;
end


%% Now create a common set of indices that will be used to construct
% the relaxation constraints.
maxpairs = 0 ;
for i = 1 : nConstraints
    maxpairs = max( maxpairs, size( optstruct.Constraints{i}.A_data, 2 )-1 ) ;
end

allIndices = [] ;
for j = 1 : nConstraints
    i = find( optstruct.ConstraintOrder == j ) ;
    xdiff = zeros( size(optstruct.Constraints{i}.A_data, 1), maxpairs-size(optstruct.Constraints{i}.A_data, 2)+1 ) ;
    allIndices = [allIndices; [xdiff optstruct.Constraints{i}.A_data(:, 1:end-1)]] ;
end

%% Compute all unique pairs. It is important to preseve this mapping between
% 'all constraint pairs' and 'unique constraint pairs' because while the indices output 
% after this function will be used to formulate the relaxation variables, the coefficients
% have yet to be 'mapped' properly. This cannot be done without the knowledge of this
% mapping function.
[uniqIndices, ~, ib] = unique(allIndices, 'rows') ; % '~' is the second argument because it is not needed.
% ib is of the same length as allIndices, and
% the i^th entry of ib tells us the element index in uniqIndices 
% that maps to the i^th element in allIndices.


%% Now compose the relaxation varibles.
if size( allIndices, 2 ) < 3
    [optstruct.A, optstruct.b, optstruct.nrelax] = composeRelaxationConstraints( uniqIndices, optstruct.nvars ) ;
else
    [optstruct.A, optstruct.b, optstruct.nrelax] = composeRelaxationTriConstraints( uniqIndices, optstruct.nvars ) ;
end    
optstruct.uniqIndices = uniqIndices ;


%% Finally, using backtracking indices in ib, re-map the coefficients in each 
% of the constraints, so that in the learning code, they can just be weighted individually
% and added without worrying about correspondence between entries in different constraints.
optstruct.BackTrackIndices = {} ;
currlen = 0 ;

%% Compute constraint coefficients and connect them to the final linear relaxation costs.
coeffSum = zeros( optstruct.nrelax, 1 ) ;
for j = 1 : nConstraints
    i = find( optstruct.ConstraintOrder == j ) ;
    idx = ib( (currlen+1):(currlen+size(optstruct.Constraints{i}.A_data, 1)) ) ;
    optstruct.BackTrackIndices{i} = idx ;
    optstruct.Constraints{i}.Acoeff = zeros(optstruct.nrelax, 1) ;
    optstruct.Constraints{i}.Acoeff(idx) = optstruct.Constraints{i}.A_data(:, end) ; % dimension independent.
    coeffSum = coeffSum + optstruct.Constraints{i}.Acoeff ;
    currlen = currlen + size(optstruct.Constraints{i}.A_data, 1) ;
end

optstruct.coeffSum = coeffSum ;
