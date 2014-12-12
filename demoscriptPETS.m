%%%% Add all paths ;
clear all ; close all ;
run pathadd ;

%%%% Load sample data
load('data/pets_s1l1optdata.mat') ;

%%%% Run optimization program.
[yint, ypred] = predict( param, a.model, param.patterns{1}, 1, 1 ) ;

%%%% Now collect the tracks
opttracks = findalltracks( yint( [param.optstruct.detids param.optstruct.connids] ), param.ndets, param.ntrcks, param.edge_xi, param.edge_xj, param.patterns{1}(1:param.nedgs), param.nedgs, param.alldets ) ;

dresdp = convert_opttracks_to_dres( opttracks, param.xs ) ;  
dresdp = interpolate_tracks( dresdp ) ;

%%%% Now compute MOTA values
create_cvml( dresdp, 'MOTA/data/PETS2009-S1L1-2-our-res.xml', 'PETS2009-S1L1-2-c1' ) ;
evaluateCVPR2013(4, 'MOTA/data') ;
