function [dtall,apallmethods] = plotTrackRedetection( dres_dp, gt, detections, frids, col, draw, figidx )
% Code by Ivan

if nargin < 6
    draw = 1 ; % by default draw stuff
end

if nargin < 7
    figidx = 4 ;
end

clear gttracks
gttracks.bboxes=[gt.x gt.y gt.x+gt.w gt.y+gt.h];
gttracks.frames=gt.fr;
gttracks.ids=gt.r;

% hgconf = computeHogConfs( dres_dp, detections, frids ) ;

% dtall = 0:4:40 ;
dtall = 0:30:300 ;
detsall{1} = dres_dp ;

if draw
    methodsall{1} = 'Temp' ;
    figure(figidx-1) ; clf ;
end
apallmethods=[];
hlegall=[];

for j=1:length(detsall)
    clear dettracks
    dettracks.bboxes=[detsall{j}.x detsall{j}.y detsall{j}.x+detsall{j}.w detsall{j}.y+detsall{j}.h];
    dettracks.frames=detsall{j}.fr;
    dettracks.conf=detsall{j}.hogconf;
    dettracks.ids=detsall{j}.id;

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
        if draw        
            hold off
            for k=1:i
                subplot(4,2,j)
                plot(recall{k},precall{k},'Color',ccol(k,:),'LineWidth',2), hold on ;
                leg{k}=sprintf('ap: %.3f, dt=%d',apall(k),dtall(k));
            end
            hlegall(j)=legend(leg);
            title(methodsall{j});
            grid on, axis([0 1 0 1]);
            xlabel('Recall');
            ylabel('Precision');
            drawnow;
        end 
    end

    apallmethods(:,j)=apall(:);
end

if draw
    figure(figidx), hold on ;
    l = plot(dtall,apallmethods,'LineWidth',3) ; grid on ;
    set(l, 'color', col) ;
    xlabel('Time interval (frames)','FontSize',12);
    ylabel('Track detection AP','FontSize',12);
    legend(methodsall,'FontSize',12);
    title('Evaluation of track detection','FontSize',12)
end
%print('-dpng','../plots/trackap.png','-r100')
