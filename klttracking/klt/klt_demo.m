figure(1);
clf reset;
set(gcf,'doublebuffer','on');

d2vpath='c:/data/video/buffy/05_02/vobs/luce.d2v';

f1=38893;
f2=39015;

tc=klt_init('nfeats',1000,'mindisp',0.5,'pyramid_levels',2);

K=zeros(3,tc.nfeats,f2-f1+1);

I=im2double(rgb2gray(vgg_d2vfile(d2vpath,f1)));
M=[];

[tc,P]=klt_selfeats(tc,I,M);
K(:,:,1)=P;

n=sum(P(3,:)>=0);
mre_printf('%d found\n', n);

for f=f1+1:f2    
    I=im2double(rgb2gray(vgg_d2vfile(d2vpath,f)));
    [tc,P]=klt_track(tc,P,I,M);

    nt=sum(P(3,:)>=0);
    mre_printf('%d tracked\n', n);
    
    [tc,P]=klt_selfeats(tc,I,M,P);    
    K(:,:,f-f1+1)=P;
    
    nn=sum(P(3,:)>=0);
    
    mre_printf('now %d (%d replaced)\n', nn, nn-nt);
    
    subplot(121);
    imagesc(I);
    hold on;
    plot(P(1,P(3,:)==0),P(2,P(3,:)==0),'g+');
    plot(P(1,P(3,:)>0),P(2,P(3,:)>0),'r+');
    hold off;
    axis image;
    axis off;

%     if mod(f-f1,10)==1
    if 1
        subplot(122);
        [T,v]=klt_parse(K);
        plot(squeeze(T(1,1:f-f1+1,:)),squeeze(T(2,1:f-f1+1,:)))
        axis([1 size(I,2) 1 size(I,1)]);
        axis image;
        axis ij;
    end

    colormap gray;
    drawnow;
end
