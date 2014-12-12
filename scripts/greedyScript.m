function dres_dp = greedyScript( xs, frids, Amats, ntrcks, weights, overlap )
% function dres_dp = greedyScript( xs, frids, Amats, ntrcks, weights, overlap )

if (nargin < 5) || isempty(weights)
    weights = [1;0;1;0] ;
end

if nargin < 6
    overlap = 0 ; % don't do nms by default
end


%%% Run object/human detector on all frames.
display('in object/human detection... (may take an hour using 8 CPU cores: please set the number of available CPU cores in the code)')
weights
% fname = [cachedir vid_name '_scene7_detec_res.mat'];

[dres bboxes] = detect_objects_weighted( xs, frids, weights(3:4) ); % weight the detections

%%% Adding transition links to the graph by fiding overlapping detections in consequent frames.
display('in building the graph...')

dres = build_graph_weighted( dres, 0, Amats, weights(1:2) ) ; % weight the edges.

%%% setting parameters for tracking
c_en      = 0;     %% birth cost
c_ex      = 0;     %% death cost
c_ij      = 0;     %% transition cost
betta     = 0;     %% betta
max_it    = ntrcks ;    %% max number of iterations (max number of tracks)
thr_cost  = 18 ;    %% max acceptable cost for a track (increase it to have more tracks.)

%%% Running tracking algorithms
display('in DP tracking ...')

if ~overlap
    dres_dp       = tracking_dp_klt(dres, c_en, c_ex, c_ij, betta, thr_cost, max_it, 0);
else
    dres_dp       = tracking_dp_klt(dres, c_en, c_ex, c_ij, betta, thr_cost, max_it, 1);
end
% dres_dp.r     = -dres_dp.id;
