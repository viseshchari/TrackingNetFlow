function [res min_cs] = tracking_dp_klt(dres, c_en, c_ex, c_ij, betta, thr_cost, max_it, nms_in_loop)
% function [res min_cs] = tracking_dp_klt(dres, c_en, c_ex, c_ij, betta, thr_cost, max_it, nms_in_loop)

if ~exist('max_it')
  max_it = 1e5;
end
if ~exist('thr_cost')
  thr_cost = 0;
end

thr_nms = 0.5;

dnum = length(dres.x);
res = dres ;


dres.c = betta - dres.r; % now all the detections are reversed
disp('mincost')

dres.dp_c     = [];
dres.dp_link  = [];
dres.orig     = [];

min_c     = -inf;
it        = 0;
k         = 0;
inds_all  = zeros(1,1e5);
id_s      = zeros(1,1e5);
redo_nodes = [1:dnum]';
while (min_c < thr_cost) && (it < max_it)
  it = it+1;
  
  dres.dp_c(redo_nodes,1) = dres.c(redo_nodes) + c_en;
  dres.dp_link(redo_nodes,1) = 0;
  dres.orig(redo_nodes,1) = redo_nodes;
  
  % only a single pass is needed because detections are arranged frame-wise
  % so bread-first search is enough to pass through entire tree.
  for ii=1:length(redo_nodes)
    i = redo_nodes(ii);
    f2 = dres.nei(i).inds ;
    fo = -dres.nei(i).ovlap ;
    if isempty(f2)
      continue
    end
    
    [min_cost j] = min(c_ij + dres.c(i) + dres.dp_c(f2) + fo' );
    min_link = f2(j);
    if dres.dp_c(i,1) > min_cost
      dres.dp_c(i,1) = min_cost;
      dres.dp_link(i,1) = min_link;         % remember parent node.
      dres.orig(i,1) = dres.orig(min_link); % remember tree root. used for nms algorithm
    end
  end  
  [min_c ind] = min(dres.dp_c + c_ex); % find the track with minimum cost.
  
  inds = zeros(dnum,1);
  
  % This code just finds the track once dp has been done.
  % It traces out the track using order n algorithm just like the one I use.
  k1 = 0;
  while ind~=0
    k1 = k1+1;
    inds(k1) = ind;
    ind = dres.dp_link(ind);
  end
  inds = inds(1:k1);

  % put all the indices of each track into the variable inds_all.
  inds_all(k+1:k+length(inds)) = inds;
  id_s(k+1:k+length(inds)) = it;
  k = k+length(inds);
  
  if nms_in_loop
    supp_inds = nms_aggressive(dres, inds, thr_nms);
    origs = unique(dres.orig(supp_inds)); % find the roots of all tracks that have changed because of nms based removal of detections.
    redo_nodes = find(ismember(dres.orig, origs)); % take all the detections of those tracks and mark them for removal.
  else
    supp_inds = inds;
    origs = inds(end);
    redo_nodes = find(dres.orig == origs);
  end
  redo_nodes = setdiff(redo_nodes, supp_inds);
  dres.dp_c(supp_inds) = inf;
  dres.c(supp_inds) = inf;

  min_cs(it) = min_c;
end
inds_all = inds_all(1:k);
id_s = id_s(1:k);

% res = sub(dres, inds_all);
res.id = -1 * ones(length(dres.r),1) ;
res.id(inds_all') = id_s';

