function dres = build_graph_mikeldata(trcname, dres, overlap, nShots)
% function dres = build_graph_mikeldata(trcname, overlap)

trcbegin = 10 ;
trcend = 16 ; % Scene13_fullvid_pyl5_mind3_ssig1_new_15
% nShots = 11 ;
Amats = {} ;
frids = [] ;
detections = [] ;

for fr = 1 : nShots
  finidx = min( (fr-1)*trcbegin + trcend, max(dres.fr) ) ;

  tmp = load( sprintf( '~/Codes/tracking.laptop/test-dir-out/%s/klt_dist/%06d-%06d.mat', trcname, (fr-1)*trcbegin+1, finidx ) ) ;

  dets = readtracks( sprintf( '~/Codes/tracking.laptop/test-dir-out/%s/%s_%07d_%07d_dets.txt', trcname, trcname, (fr-1)*trcbegin+1, finidx) ) ;

  frtmp = [dets.frame] ;
  confs = [dets.conf] ;

  if fr ~= nShots
    idx = find( frtmp == min(fr*trcbegin, max(dres.fr)) ) ;
  else
    idx = length(frtmp) ;
  end

  fr
  Amats{fr} = tmp.C(1:max(idx), :) ;
  frids = [frids; frtmp(1:max(idx))'] ;
  detections = [detections; cat(1, dets(1:max(idx)).rect) confs(1:max(idx))'] ;
  % rect = cat(1, dets.rect) ;

  % dres.x = [dres.x; rect( 1:max(idx), 1 )'] ;
  % dres.y = [dres.y; rect( 1:max(idx), 2 )'] ;
  % dres.w = [dres.w; rect( 1:max(idx), 3 )' - rect( 1:max(idx), 1)'] ;
  % dres.h = [dres.h; rect( 1:max(idx), 4 )' - rect( 1:max(idx), 2)'] ;
  % dres.fr = [dres.fr; frtmp(1:max(idx))'] ;
  % dres.r = [dres.r; conf(1:max(idx))'] ;
end
save('GreedyDets879.mat', 'detections', 'frids' ) ;

if overlap
  ov_thresh = 0.5;
  dnum = length(dres.x);
  time1 = tic;
  len1 = max(dres.fr);
  for fr = 2:max(dres.fr)
    if toc(time1) > 2
      fprintf('%0.1f%%\n', 100*fr/len1);
      time1 = tic;
    end
    f1 = find(dres.fr == fr);     %% indices for detections on this frame
    f2 = find(dres.fr == (fr-1));   %% indices for detections on the previous frame
    for i = 1:length(f1)
      ovs1  = calc_overlap(dres, f1(i), dres, f2);   
      inds1 = find(ovs1 > ov_thresh);                       %% find overlapping bounding boxes.  
      
      ratio1 = dres.h(f1(i))./dres.h(f2(inds1));
      inds2  = (min(ratio1, 1./ratio1) > 0.3);          %% we ignore transitions with large change in the size of bounding boxes.
        
      dres.nei(f1(i),1).inds  = f2(inds1(inds2))';      %% each detction window will have a list of indices pointing to its neighbors in the previous frame.
      dres.nei(f1(i),1).ovlap = ovs1(inds1(inds2))' ;
  %     dres.nei(f1(i),1).ovs   = ovs1(inds1(inds2));
    end
  end
else
  Amats2 = edge_preprocessing_temporal( Amats, frids, [dres.x dres.y dres.x+dres.w, dres.y+dres.h, dres.r] ) ;
  % save('edgevectors.mat', 'Amats', 'Amats2') ;
  rct = [dres.x+dres.w/2 dres.y+dres.w/2] ;

  cumdets = 0 ;

  for i = 1:length(dres.x)
    dres.nei(i,1).inds = [] ;
    dres.nei(i,1).ovlap = [] ;
  end

  for fr = 1 : nShots
    idx = find( Amats2{fr}(:) > 0.0 ) ;
    [xi, xj] = ind2sub( size( Amats2{fr} ), idx ) ;

    % Find only adjacent frames.
    % ind = find( dres.fr(xi+cumdets) == (dres.fr(xj+cumdets)-1) ) ;
    % xi = xi(ind) + cumdets ;
    % xj = xj(ind) + cumdets ;
    xi = xi + cumdets ;
    xj = xj + cumdets ;

    dists = sqrt( (rct(xi,1)-rct(xj,1)).^2 + (rct(xi,2)-rct(xj,2)).^2 ) ;
    idxtmp = find( dists < 40.0 ) ;
    xi = xi(idxtmp) ;
    xj = xj(idxtmp) ;
    idx = idx(idxtmp) ;
    % Amats2{fr}(idx(idxtmp)) = Amats2{fr}(idx(idxtmp)) * 0.1 ; % just discourage edges like this.

    if size(xi,1) == 1
      xi = xi' ;
      xj = xj' ;
    end

    for i = 1 : length(xj)
      dres.nei(xj(i),1).inds = [dres.nei(xj(i), 1).inds xi(i)] ;
      dres.nei(xj(i),1).ovlap = [dres.nei(xj(i), 1).ovlap Amats2{fr}(idx(i))] ;
      % idx = find( dres.fr(xi) == (dres.fr(xj(i))-1) ) ;
      % dres.nei( xj(i), 1 ).inds = unique(xi(idx)) ;
    end

    cumdets = cumdets + size( Amats2{fr}, 1 ) ;
  end
end
