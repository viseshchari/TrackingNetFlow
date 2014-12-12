function yAdd = computeGTConstraintValue( ylabel, optstruct )
% function yAdd = computeGTConstraintValue( ylabel, optstruct ) 
% This function takes as input an optimization variable output (ylabel) and
% optimization parameters (optstruct) and computes the value of
% the relaxed variables given the linear variables in ylabel.

yAdd = zeros( optstruct.nrelax, 1 ) ;

for j = 1 : optstruct.nConstraints
    i = find( optstruct.ConstraintOrder == j ) ;
    edge_firstidx = optstruct.Constraints{i}.A_data(:, 1) ;
    edge_secondidx = optstruct.Constraints{i}.A_data(:, 2) ;
    if size( optstruct.Constraints{i}.A_data, 2 ) == 4
        edge_thirdidx = optstruct.Constraints{i}.A_data(:, 3) ;
        yaug = ylabel( edge_firstidx ) .* ylabel( edge_secondidx ) .* ylabel( edge_thirdidx ) ;
    else
        yaug = ylabel( edge_firstidx ) .* ylabel( edge_secondidx ) ;
    end
    yAdd( optstruct.BackTrackIndices{i} ) = yAdd( optstruct.BackTrackIndices{i} ) | yaug ;
end