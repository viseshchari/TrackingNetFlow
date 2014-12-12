function yaug = augment_variable(param, z, includeSinks)
% function yaug = augment_variable(param, z, includeSinks)
%
% for LP relaxation structure; augment the y_ij = z_i * z_j variables [paper notation] 
% the z vector to get yaug. Only the first connection / detection variables
% are used in z.
%
% set includeSinks to 1 (0 by default) to include the source/sinks
% variables as well in yaug [used in the new AugmentedFeature code]
%
% uses param.Q_data, etc. (required).

if nargin < 3
    includeSinks = 0;
end

pm = param;

if includeSinks
    nvariables = pm.nvars; % include source/sink variables as well
else
    nvariables = pm.nedgs+pm.ndets; % trim z for only connections & detections
end
zstart = z(1:nvariables); 
% need to augment y with the relaxation quadratic variables for the
% feature function.

if isfield( param, 'optstruct' )
    zAdd = computeGTConstraintValue( z, param.optstruct ) ;
else
    edge_firstindx = pm.Q_data(:, 1) ;
    edge_secondindx = pm.Q_data(:, 2) ;
    if pm.spatiotemporal
        edge_thirdindx = pm.Qt_data(:, 1) ;
        edge_fourthindx = pm.Qt_data(:, 2) ;
    else
        edge_thirdindx = [];
        edge_fourthindx = [];
    end
    zAdd = [z(edge_firstindx) .*z(edge_secondindx); z(edge_thirdindx) .* z(edge_fourthindx)] ;
end
yaug = [zstart; ...
        zAdd] ;