function [Q_data, Q] = addSpatialQuadtraticCost( detstruct, edge_xi, edge_xj, xs, frids, velthresh, nvars, nedgs, ntrcks ) ;

[edge_negpairs, edge_nnegpairs, edge_velocity, maxvel] = addParallelismConstraints( xs, frids, edge_xi, edge_xj, velthresh ) ;
[Q_data, nvals] = fillSpaceQuadMatrix( edge_negpairs, edge_velocity, nedgs, ntrcks, maxvel ) ; % call and make idxbig idxlonedge etc.. 0 and idxsmall 1 if it is needed.
Q = sparse( Q_data(:, 1), Q_data(:, 2), Q_data(:, 3), max(Q_data(:, 1)), nvars ) ;