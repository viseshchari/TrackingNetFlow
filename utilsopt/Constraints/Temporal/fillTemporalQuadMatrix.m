function [Q_data, nvals] = fillTemporalQuadMatrix( xs, frids, edge_xi, edge_xj, edge_negpairs, edge_velocity, maxvel )
% function [Q_data, nvals] = fillTemporalQuadMatrix( pm, edge_negpairs )
% nvals is returned from here just in case I need to change the quadratic function so that computing
% nvals is no longer trivial

% xscent = [xs(:, 1) + xs(:, 3) xs(:, 2) + xs(:, 4)] / 2 ;
% frdiff = frids(edge_xj)-frids(edge_xi) ;
% xone = (xscent(edge_xj(edge_negpairs(:,1)), 1) - xscent(edge_xi(edge_negpairs(:,1)), 1))./frdiff(edge_negpairs(:,1)) ;
% yone = (xscent(edge_xj(edge_negpairs(:,1)), 2) - xscent(edge_xi(edge_negpairs(:,1)), 2))./frdiff(edge_negpairs(:,1)) ;
% xtwo = (xscent(edge_xj(edge_negpairs(:,2)), 1) - xscent(edge_xi(edge_negpairs(:,2)), 1))./frdiff(edge_negpairs(:,2)) ;
% ytwo = (xscent(edge_xj(edge_negpairs(:,2)), 2) - xscent(edge_xi(edge_negpairs(:,2)), 2))./frdiff(edge_negpairs(:,2)) ;

nvals = size(edge_negpairs, 1) ;
% maxvel = max( [sum(edge_velocity(:,1:2).^2,2); sum(edge_velocity(:,3:4).^2, 2)] ) ;
xone = edge_velocity(:, 1) ;
xtwo = edge_velocity(:, 3) ;
yone = edge_velocity(:, 2) ;
ytwo = edge_velocity(:, 4) ;
maxvel = sqrt(maxvel) ;

Q_data = ones( 4 * nvals, 3 ) ;
Q_data(1:(nvals), 1) = 1:nvals ;
Q_data(1:(nvals), 2) = edge_negpairs(:, 1) ;
Q_data(1:(nvals), 3) = xone / maxvel ;

Q_data((nvals+1):(2*nvals), 1) = 1:nvals ;
Q_data((nvals+1):(2*nvals), 2) = edge_negpairs(:, 2) ;
Q_data((nvals+1):(2*nvals), 3) = -xtwo / maxvel ;

Q_data((2*nvals+1):(3*nvals), 1) = (nvals+1):(2*nvals) ;
Q_data((2*nvals+1):(3*nvals), 2) = edge_negpairs(:, 1) ;
Q_data((2*nvals+1):(3*nvals), 3) = yone / maxvel ;

Q_data((3*nvals+1):(4*nvals), 1) = (nvals+1):(2*nvals) ;
Q_data((3*nvals+1):(4*nvals), 2) = edge_negpairs(:, 2) ;
Q_data((3*nvals+1):(4*nvals), 3) = -ytwo / maxvel ;