function [A, b, edge_velocity, Q_data, Q] = addShapeQuadRelaxedConstraints( detstruct, xs, edgeval, edge_xi, edge_xj, nvars, nvarq )
% function [A, b, edge_velocity, Q_data, Q] = addShapeQuadRelaxedConstraints( detstruct, xs, edgeval, edge_xi, edge_xj, nvars, nvarq )

width = xs(:,3) - xs(:,1) ;
height = xs(:,4) - xs(:,2) ;

edgewidth = min( width(edge_xi) ./ width(edge_xj), width( edge_xj ) ./ width( edge_xi ) ) ;
edgeheight = min( height(edge_xi) ./ height(edge_xj), height( edge_xj ) ./ height( edge_xi ) ) ;
edgemin = min( edgewidth, edgeheight ) ;

ndets = length(detstruct) ;

allEdges = collectEdgesDepthSearch( detstruct, 1:ndets, 2 ) ;
wsum = edgeval(allEdges(1,:)) + edgeval(allEdges(2,:)) ;

% Take the minimum value of the scale variation over width and height
% % over each pair.
% wscale = min( min( edgewidth( allEdges(1, :) ) ./ edgewidth( allEdges(2, :) ), ...
%                    edgewidth( allEdges(2, :) ) ./ edgewidth( allEdges(1, :) ) ), ...
%               min( edgeheight( allEdges(1, :) ) ./ edgeheight( allEdges(2, :) ), ...
%                    edgeheight( allEdges(2, :) ) ./ edgeheight( allEdges(1, :) ) ) ) ;
wscale = min( edgemin( allEdges(1, :) ), edgemin( allEdges(2, :) ) ) ;
               
% Find all those elements that scale very little.
idx = find( (wscale > 0.94) ) ;

[A, b, edge_npairs,~] = composeRelaxationConstraints( allEdges(:, idx)', nvars ) ;

edge_velocity = -exp( -1+wscale(idx) )' ;


Q_data = zeros( length(idx), 3 ) ;
Q_data(:, 1) = allEdges(1, idx)' ;
Q_data(:, 2) = allEdges(2, idx)' ;
Q_data(:, 3) = edge_velocity ;

Q = sparse( Q_data(:, 1), Q_data(:, 2), Q_data(:, 3), nvarq, nvarq ) ;
