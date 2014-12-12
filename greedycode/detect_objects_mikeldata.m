function [dres bboxes] = detect_objects_mikeldata(trcname, nShots)
% vid_path = 'data/seq03-img-left/';

trcbegin = 10 ;
trcend = 16 ; % Scene13_fullvid_pyl5_mind3_ssig1_new_15
% nShots = 11 ;
maxFrame = 510 ;
Amats = {} ;
frids = [] ;

dres.x = [] ;
dres.y = [] ;
dres.w = [] ;
dres.h = [] ;
dres.r = [] ;
dres.fr = [] ;


for fr = 1 : nShots
  finidx = min( (fr-1)*trcbegin + trcend, maxFrame ) ;

  dets = readtracks( sprintf( '~/Codes/tracking.laptop/test-dir-out/%s/%s_%07d_%07d_dets.txt', trcname, trcname, (fr-1)*trcbegin+1, finidx) ) ;

  frtmp = [dets.frame] ;
  confs = [dets.conf] ;
  if fr ~= nShots
    idx = find( frtmp == min(fr*trcbegin, maxFrame) ) ;
  else
    idx = length(frtmp) ;
  end

  fr
  frids = [frids; frtmp(1:max(idx))'] ;
  rect = cat(1, dets.rect) ;

  dres.x = [dres.x; rect( 1:max(idx), 1 )] ;
  dres.y = [dres.y; rect( 1:max(idx), 2 )] ;
  dres.w = [dres.w; rect( 1:max(idx), 3 ) - rect( 1:max(idx), 1)] ;
  dres.h = [dres.h; rect( 1:max(idx), 4 ) - rect( 1:max(idx), 2)] ;
  dres.fr = [dres.fr; frtmp(1:max(idx))'] ;
  dres.r = [dres.r; confs(1:max(idx))'] ;
end

bboxes = [] ;
