function [rec,prec,ap] = evaltrackdetnew(delta_t,dettracks,gttracks,optstruct,minoverlap,draw)

%
% [rec,prec,ap] = evaltrackdet(delta_t,dettracks,gttracks,minoverlap,draw)
%
% assumes input tracks in the format structure arrays:
%
%   bboxes: [Nx4 double] - track bounding box at a frame
%   frames: [Nx1 double] - frame time stamp
%     conf: [Nx1 double] - detectior confidence at a frame
%      ids: [1xN double] - track id
%WSW
%

tpall=[];
fpall=[];
detconfall=[];
nposall=0;
  
% loop over time windows
tmin=min(gttracks.frames);
tmax=max(gttracks.frames);
for t=tmin:(tmax-delta_t)
  t1=t; t2=t+delta_t;
  
  % select gttracks passing through t1 and t2
  ind1=find(gttracks.frames==t1);
  ind2=find(gttracks.frames==t2);
  [gtids,i1,i2]=intersect(gttracks.ids(ind1),gttracks.ids(ind2));
  gtbboxes1=gttracks.bboxes(ind1(i1),:);
  gtbboxes2=gttracks.bboxes(ind2(i2),:);
  gtids1=gttracks.ids(ind1(i1),:);
  gtids2=gttracks.ids(ind2(i2),:);
  assert(isequal(gtids1,gtids2));
  gtids=gtids1;
  npos=length(gtids);
  gt=zeros(npos,1);
  
  % select dettracks passing through interval [t1 t2]
  ind1=find((dettracks.frames==t1)&(dettracks.ids~=-1));
  ind2=find((dettracks.frames==t2)&(dettracks.ids~=-1));
  % select ids of tracks passing through t1 and t2
  [detids,i1,i2]=intersect(dettracks.ids(ind1),dettracks.ids(ind2));
  % get start and end bounding boxes for selected subtracks
  detbboxes1=dettracks.bboxes(ind1(i1),:);
  detbboxes2=dettracks.bboxes(ind2(i2),:);
  % assign confidence to subtracks starting at t1 and ending at t2
  % The confidence is a sum of detection confidences at the first and 
  % the last frame of a subtrack.
  % detconf=dettracks.conf(ind1(i1))+dettracks.conf(ind2(i2));

  detids1=dettracks.ids(ind1(i1));
  detids2=dettracks.ids(ind2(i2));
  assert(isequal(detids1,detids2));
  detids=detids1;
  detconf = zeros(length(detids),1) ;
  % to get detections indicies corresponding to subtracks in the
  % interval [t1 t2], do, for example, the following:
  for trid = 1 : length(detids)
    detconf(trid) = quadScoreTrack( dettracks, optstruct, detids(trid), t1, t2 ) ;
  end

  % for i=1:length(detids)
  %   ind=find([dettracks.ids]==detids(i) & [dettracks.frames]>=t1 & [dettracks.frames]<=t2);
  %   % 'ind' now should contain indicies to detections from a track detids(i).
  %   % the subtrack is limited by the time interval [t1,t2].
  % end
  
  if 0 
    img=read(videoobj,t);
    showimage(img)
    ccol=lines(max(dettracks.ids));
    labs=regexp(num2str(detids1'),'\S+','match');
    showbbox(detbboxes1,ccol(detids1,:),labs,3);
    showbbox(detbboxes2,ccol(detids2,:),labs,1);
    pause
  end
  
  
  % sort detections by decreasing confidence
  [sv,si]=sort(-detconf);
  detids=detids(si);
  detconf=detconf(si);
  detbboxes1=detbboxes1(si,:);
  detbboxes2=detbboxes2(si,:);
  
  % assign detections to ground truth objects
  nd=length(detconf);
  tp=zeros(nd,1);
  fp=zeros(nd,1);
  for d=1:nd

    % assign detection to ground truth object if any
    bb1=detbboxes1(d,:);
    bb2=detbboxes2(d,:);
    ov1=bboxoverlapval(bb1,gtbboxes1);
    ov2=bboxoverlapval(bb2,gtbboxes2);
    ov=min([ov1; ov2],[],1);
    [ovmax,gtind]=max(ov);

    % assign detection as true positive/don't care/false positive
    if ovmax>=minoverlap
      if ~gt(gtind)
	tp(d)=1;            % true positive
	gt(gtind)=true;
      else
	fp(d)=1;            % false positive (multiple detection)
      end
    else
      fp(d)=1;              % false positive
    end
  end

  tpall=[tpall; tp];
  fpall=[fpall; fp];
  detconfall=[detconfall; detconf];
  nposall=nposall+npos;
end

% sort
[sv,si]=sort(-detconfall);
tpall=tpall(si);
fpall=fpall(si);

% compute precision/recall
fp=cumsum(fpall);
tp=cumsum(tpall);
rec=tp/nposall;
prec=tp./(fp+tp);

% compute ap
ap=0;
for t=0:0.1:1
    p=max(prec(rec>=t));
    if isempty(p)
        p=0;
    end
    ap=ap+p/11;
end

if draw
    % plot precision/recall
    plot(rec,prec,'-');
    grid; axis([0 1 0 1])
    xlabel 'recall'
    ylabel 'precision'
    title(sprintf('AP = %.3f',ap));
end

