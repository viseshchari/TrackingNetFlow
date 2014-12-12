function dresnew = addEdgeCoefficients( dres, edge_xi, edge_xj, edgeval, weights )
% function dresnew = addEdgeCoefficients( dres, edge_xi, edge_xj, edgeval, weights )

mT = max( dres.id ) ;
dresnew = dres ;

for i = 1 : mT
    idx = find( dres.id == i ) ;
    for j = 1 : length(idx)-1
        idxtmp = find( ( edge_xi == idx(j) ) & ( edge_xj == idx(j+1) ) ) ;
        % Update hogconfs according to weights and adding the edge term
        dresnew.hogconf(idx(j)) = weights(3) * dresnew.hogconf(idx(j)) + weights(4) + weights(1) * edgeval(idxtmp) + weights(2) ;
    end
end