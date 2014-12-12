function [Q_data, Q] = addTemporalQuadtraticCost( detstruct, edge_xi, edge_xj, xs, frids, velthresh, nvars ) ;

[edge_negpairs, edge_nnegpairs, edge_negcost, maxvel] = addTemporalConstraintsMatlab( detstruct, edge_xi, edge_xj, xs, frids, velthresh ) ;
[Q_data, nvals] = fillTemporalQuadMatrix( xs, frids, edge_xi, edge_xj, edge_negpairs, edge_negcost, maxvel ) ; 
Q = sparse( Q_data(:, 1), Q_data(:, 2), Q_data(:, 3), max(Q_data(:, 1)), nvars ) ;