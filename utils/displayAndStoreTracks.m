function [dresnew, dtall, apallmethods] = displayAndStoreTracks( pm, yhat, model, glbvar )
% function dresnew = displayAndStoreTracks( pm, yhat, glbvar )

if nargin < 4
	glbvar = 1 ;
end

if ~isfield( pm, 'optstruct' )
    opttracks = findalltracks( ( yhat( [pm.detids pm.connids] ) ), pm.ndets, pm.ntrcks, pm.edge_xi, pm.edge_xj, pm.patterns{1}, pm.nedgs, pm.alldets ) ;
else
    opttracks = findalltracks( ( yhat( [pm.optstruct.detids pm.optstruct.connids] ) ), pm.ndets, pm.ntrcks, pm.edge_xi, pm.edge_xj, pm.patterns{1}, pm.nedgs, pm.alldets ) ;
end
try
	dresnew = convert_opttracks_to_dres( opttracks, pm.xs ) ;
catch
	dresnew = struct('x',[],'y',[],'r',[],'fr',[],'w',[],'h',[]) ;
end
idx = find( dresnew.id ~= -1 ) ;	
dresnew.vx = zeros(pm.ndets, 1) ;
dresnew.vy = zeros(pm.ndets, 1) ;
if size(pm.xs, 2) > 5
    dresnew.vx(idx) = pm.xs(idx, 6) ;
    dresnew.vy(idx) = pm.xs(idx, 7) ;
end

if glbvar
    global STATS
	% drescell ;
	% global optcell ;
	% global plotiter ;

	STATS.drescell{STATS.plotiter} = dresnew ;
	STATS.optcell{STATS.plotiter} = opttracks ;

end

% New code here, adding variables to pm datastructure that will be useful 
% for the scoring function
pm.y = yhat ;
pm.w = model.w ;
% pm.w = sparse([0;0;1;0;0]) ;
yaug = augment_variable( pm, yhat, pm.featureSink ) ;
pm.quadscore = dot( model.w, pm.featureFn( pm, pm.patterns{1}, yaug ) ) ;
dtall = [] ;
apallmethods = [] ;

if ~isempty(dresnew.x)
	if exist('STATS','var') && isfield('STATS', 'plotiter')
		% Might make for bad display since now convergence happens in at max 50 iterations.
		[dtall,apallmethods] = plotTrackRedetection( dresnew, pm.gt, pm.xs, pm.frids, [1.0 rem(STATS.plotiter,25)*0.03 rem(STATS.plotiter,25)*0.03], pm.display ) ;
	else
		% plotTrackRedetectionNew( dresnew, pm, pm.gt, pm.xs, pm.frids, [1.0 0 0] ) ;
		[dtall,apallmethods] = plotTrackRedetection( dresnew, pm.gt, pm.xs, pm.frids, [1.0 0 0], pm.display ) ;
	end
end
