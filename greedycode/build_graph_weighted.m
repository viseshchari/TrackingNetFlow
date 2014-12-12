function dres = build_graph_weighted( dres, overlap, Amats, weights)
% function dres = build_graph_weighted(trcname, overlap)

if nargin < 4
	weights = [1;0] ;
end

frids = dres.fr ;

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
  rct = [dres.x+dres.w/2 dres.y+dres.w/2] ;

  cumdets = 0 ;

  for i = 1:length(dres.x)
    dres.nei(i,1).inds = [] ;
    dres.nei(i,1).ovlap = [] ;
  end

  nShots = length(Amats) ;
  
  for fr = 1 : nShots
    idx = find( Amats{fr}(:) > 0.0 ) ;
    [xi, xj] = ind2sub( size( Amats{fr} ), idx ) ;

    % Find only adjacent frames.
    % ind = find( dres.fr(xi+cumdets) == (dres.fr(xj+cumdets)-1) ) ;
    % xi = xi(ind) + cumdets ;
    % xj = xj(ind) + cumdets ;
    xi = xi + cumdets ;
    xj = xj + cumdets ;

    % dists = sqrt( (rct(xi,1)-rct(xj,1)).^2 + (rct(xi,2)-rct(xj,2)).^2 ) ;
    % idxtmp = find( dists < 40.0 ) ;
    % xi = xi(idxtmp) ;
    % xj = xj(idxtmp) ;
    % idx = idx(idxtmp) ;
    % Amats2{fr}(idx(idxtmp)) = Amats2{fr}(idx(idxtmp)) * 0.1 ; % just discourage edges like this.

    if size(xi,1) == 1
      xi = xi' ;
      xj = xj' ;
    end
    weights = double(weights) ;

    for i = 1 : length(xj)
      dres.nei(xj(i),1).inds = [dres.nei(xj(i), 1).inds xi(i)] ;
      dres.nei(xj(i),1).ovlap = [dres.nei(xj(i), 1).ovlap weights(1)*double(Amats{fr}(idx(i)))+weights(2)] ;
      % idx = find( dres.fr(xi) == (dres.fr(xj(i))-1) ) ;
      % dres.nei( xj(i), 1 ).inds = unique(xi(idx)) ;
    end

    cumdets = cumdets + size( Amats{fr}, 1 ) ;
  end
end
