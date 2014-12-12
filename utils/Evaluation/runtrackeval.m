%
% evaluation of track detection (re-detection)
%

% basepath='D:/proj/evaluation/trackdeteval';
basepath='/meleze/data2/chari/Codes/CrowdAnalysis/PartBasedModel/Optimization/trackeval/trackdeteval';
trackpath=[basepath '/tracks'];
avipath=[basepath '/avi'];

avifname='scene13_recode.avi';
tracksfname=[trackpath '/ivanresults.mat'];
newfile1=[trackpath '/LP1newresults19october2.mat'];
newfile2=[trackpath '/LP2newresults16october.mat'];
newfile3=[trackpath '/LP3newresults16october.mat'];
newfile4=[trackpath '/QP1newresults16october.mat'];
newfile5=[trackpath '/QP2newresults16october.mat'];
newfile6=[trackpath '/QP3newresults16october.mat'];

if 1 % load and reformat tracks
  load(tracksfname);
  load(newfile1) ;
  load(newfile2) ;
  load(newfile3) ;
  load(newfile4) ;
  load(newfile5) ;
  load(newfile6) ;
  
  clear gttracks
  gttracks.bboxes=[gt.x gt.y gt.x+gt.w gt.y+gt.h];
  gttracks.frames=gt.fr;
  gttracks.ids=gt.r;
  
  detsall{1}=dres_greedy_original; methodsall{1}='Greedy original';
  detsall{2}=dres_greedy_modified; methodsall{2}='Greedy modified';
  % detsall{3}=dres_lp;              methodsall{3}='LP';
  detsall{3}=dres_dp;              methodsall{3}='LP Temporal';
  detsall{4}=dres_lp2;              methodsall{4}='LP Spatial';
  detsall{5}=dres_lp3;              methodsall{5}='LP Spatio-Temporal';
  detsall{6}=dres_qp1;              methodsall{6}='QP Temporal';
  detsall{7}=dres_qp2;              methodsall{7}='QP Spatial';
  detsall{8}=dres_qp3;              methodsall{8}='QP Spatio-Temporal';
end

if 1 % evaluate track detection for different methods and tmie intervals dt
  
  figure(1), clf
  apallmethods=[];
  hlegall=[];
  for j=1:length(detsall)    
    clear dettracks
    dettracks.bboxes=[detsall{j}.x detsall{j}.y detsall{j}.x+detsall{j}.w detsall{j}.y+detsall{j}.h];
    dettracks.frames=detsall{j}.fr;
    dettracks.conf=detsall{j}.hogconf;
    dettracks.ids=detsall{j}.id;

    dtall=0:4:40;
    recall={};
    precall={};
    apall=[];
    ccol=jet(length(dtall));
    for i=1:length(dtall)
      [rec,prec,ap]=evaltrackdet(dtall(i),dettracks,gttracks,0.5,0);
      recall{i}=rec;
      precall{i}=prec;
      apall(i)=ap;
      leg={};
      hold off
      for k=1:i
	subplot(4,2,j)
	plot(recall{k},precall{k},'Color',ccol(k,:),'LineWidth',2), hold on
	leg{k}=sprintf('ap: %.3f, dt=%d',apall(k),dtall(k));
      end
      hlegall(j)=legend(leg);
      title(methodsall{j})
      grid on, axis([0 1 0 1])
      xlabel('Recall');
      ylabel('Precision');
      drawnow
    end
    apallmethods(:,j)=apall(:);
  end
  %for i=1:length(hlegall) subplot(2,2,i); set(hlegall(i),'FontSize',5); end
  %print('-dpng','../plots/trackprecrec.png','-r200')
  
  figure(2), clf
  plot(dtall,apallmethods,'LineWidth',3), grid on
  xlabel('Time interval (frames)','FontSize',12);
  ylabel('Track detection AP','FontSize',12);
  legend(methodsall,'FontSize',12)
  title('Evaluation of track detection','FontSize',12)
  %print('-dpng','../plots/trackap.png','-r100')
  pause
end


if 1 % evaluate detection
  
  detsall2=detsall;
  detsall2{end+1}=dres;
  detsall2{end}.hogconf=detsall2{end}.r;
  detsall2{end}.id=1:length(detsall2{end}.r);
  methodsall2=methodsall;
  methodsall2{end+1}='HOG';
  
  figure(1), clf
  apallmethods=[];
  ccol=lines(length(methodsall2));
  leg={};
  
  for j=1:length(detsall2)
    clear dettracks
    dettracks.bboxes=[detsall2{j}.x detsall2{j}.y detsall2{j}.x+detsall2{j}.w detsall2{j}.y+detsall2{j}.h];
    dettracks.frames=detsall2{j}.fr;
    dettracks.conf=detsall2{j}.hogconf;
    dettracks.ids=detsall2{j}.id;

    [rec,prec,ap]=evaltrackdet(0,dettracks,gttracks,0.5,0);
    plot(rec,prec,'Color',ccol(j,:),'LineWidth',3), hold on
    leg{j}=sprintf('ap: %.3f %s',ap,methodsall2{j});
    legend(leg,'FontSize',12)
    grid on, axis([0 1 0 1])
    xlabel('Recall','FontSize',12)
    ylabel('Precision','FontSize',12)
    drawnow
  end
  %print('-dpng','../plots/detprecrec.png','-r100')
end

if 0 % overlay detections in video
  videoobj = mmreader([avipath '/' avifname]);
  tracks=gttracks;
  ccol=lines(max(gttracks.ids));
  
  for i=1:120
    img=read(videoobj,i);
    showimage(img)
    ind=find(gttracks.frames==i);
    labs=regexp(num2str(gttracks.ids(ind)'),'\S+','match');
    showbbox(tracks.bboxes(ind,:),ccol(gttracks.ids(ind),:),labs,3);    
    pause
  end
end


