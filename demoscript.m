%%%% Add all paths ;
clear all ; close all ;
run pathadd ;

%%%% First generate klt tracks
cd klttracking ;
pipeline_example ; 
cd .. ;

%%%% Load ground truth track
load('data/scene_gt7.mat') ;

%%%% Then fillup the graph datastructure. Node confidence, edge confidences etc.
datastructsetup( 'Scene7', 5, 56, [], './data', 'scene_data7vars.mat' ) ;
%%%% Finally setup the graph network constraints, along with the flow infrastructure.
param = networkFlowSetup( './data/scene_data7vars.mat', './data/scene_gt7.mat', 40, [], 56 ) ;

%%%% Set optimization parameters.
a.model.w = sparse([0.1347; -0.0004; 0.0128; -0.0004; 0.0030]) ;

%%%% Run optimization program.
[yint, ypred] = predict( param, a.model, param.patterns{1}, 1, 1 ) ;

%%%% Now collect the tracks
opttracks = findalltracks( yint( [param.optstruct.detids param.optstruct.connids] ), param.ndets, param.ntrcks, param.edge_xi, param.edge_xj, param.patterns{1}(1:param.nedgs), param.nedgs, param.alldets ) ;

dresdp = convert_opttracks_to_dres( opttracks, param.xs ) ;  
dresdp = interpolate_tracks( dresdp ) ;

%%%% Run greedy program.
dresdpgreedy = greedyScript( param.xs, param.frids, param.Amats, param.ntrcks, full(a.model.w), 1 ) ;
dresdpgreedy.hogconf = dresdp.hogconf ;
dresdpgreedy = interpolate_tracks( dresdpgreedy ) ;

%%%% Finally display results using Re-detection to plot both algorithms
plotTrackRedetection( dresdp, gt, [], [], 'r' ) ;
figure(3) ; hold on ;
plotTrackRedetection( dresdpgreedy, gt, [], [], 'b' ) ;
hold off ;

%%%% Display different tracks on images.
ncolrs = rand( param.ntrcks, 3 ) ;

xrect = [dresdp.x dresdp.y dresdp.x+dresdp.w dresdp.y+dresdp.h] ;
fprintf( 'First displaying our result\n' ) ;
for i = 1 : max( param.frids )
	im = imread( sprintf( './detectiondata/Scene7/frame%04d.jpg', i ) ) ;
	idxtmp = find( ( dresdp.fr == i ) & ( dresdp.id ~= -1 ) ) ;
	showboxes( im, xrect(idxtmp, :), ncolrs(dresdp.id(idxtmp), :) ) ;
	%%%% Commented lines can be uncommented if one needs to save these images.
	% img = getframe( gcf ) ;
	% img = img.cdata ;
	pause(0.1) ;
	clf ;
end

xrectg = [dresdpgreedy.x dresdpgreedy.y dresdpgreedy.x+dresdpgreedy.w dresdpgreedy.y+dresdpgreedy.h] ;
fprintf( 'Next displaying greedy result\n' ) ;
for i = 1 : max( param.frids )
	im = imread( sprintf( './detectiondata/Scene7/frame%04d.jpg', i ) ) ;
	idxtmp = find( ( dresdpgreedy.fr == i ) & ( dresdpgreedy.id ~= -1 ) ) ;
	showboxes( im, xrectg(idxtmp, :), ncolrs(dresdpgreedy.id(idxtmp), :) ) ;
	%%%% Commented lines can be uncommented if one needs to save these images.
	% img = getframe( gcf ) ;
	% img = img.cdata ;
	pause(0.1) ;
	clf ;
end
