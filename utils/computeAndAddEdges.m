function dresdp = computeAndAddEdges( dresdp, edge_xj, edge_xi, edgeval )


if isfield( dresdp, 'edgeconf' )
    idx = find( dresdp.edgeconf ~= -1 ) ;
else
    ntrcks = max( dresdp.id ) ;
    dresdp.edgeconf = zeros(length(dresdp.id),1) ;
    for i = 1 : ntrcks
        idx = find( dresdp.id == i ) ;
        for j = 1 : length(idx)-1
            idxtmp = find( (edge_xj == idx(j+1)) & (edge_xi == idx(j)) ) ;
            dresdp.edgeconf(idx(j)) = edgeval(idxtmp) ;
        end
    end
end
dresdp.hogconf(idx) = dresdp.hogconf(idx) + dresdp.edgeconf(idx) ;
