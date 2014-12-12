function tracked = klt_trackfeatsapt( nf, mdsp, wnsz, ssg, pyl, mineig, mdst )
% function tracked = klt_trackfeatsapt( nf, mdsp, wnsz, ssg, pyl, mineig, mdst )


tc=klt_init('nfeats', nf, ...
	'mindisp', mdsp, ...
	'winsize', wnsz, ...
	'smooth_sigma_factor', ssg, ...
	'pyramid_levels', pyl, ...
	'mineigval', mineig, ...
	'mindist', mdst) ;

tracked = [] ;

imgpath = '/meleze/data2/chari/Datasets/CrowdAnalysis/Scene13/interval3/frame%04d.jpg';
detspath = '/meleze/data2/chari/Datasets/CrowdAnalysis/Scene13/interval3/Detections_PerFrame%04d.mat' ;

% careful, 0:50 just to check validity of tracking.
frames = [0:50 (48-25):(48+25) (101-25):(101+25) (848-25):(848+25) (1148-25):(1148+25) (1178-25):(1178+25) ...
 			(1251-25):(1251+25) (2261-25):(2261+25) (2448-25):(2448+25) (2481-25):(2481+25) ...
 			(2648-25):(2648+25) (2948-25):(2948+25) (2981-25):(2981+25) (3081-25):(3081+25) ...
 			(3348-25):(3348+25) (3381-25):(3381+25)] ;

for fnum = 1 : 16

	 f1 = frames( (fnum-1) * 51 + 1 ) ;
	 f2 = frames( fnum * 51 ) ;
	 
	 K=zeros(3,tc.nfeats,f2-f1+1);
	 
	 I=single(rgb2gray(imread(sprintf(imgpath,f1))));
	 M = dets_to_mask_new(load(sprintf(detspath,f1),'newbxs'), I, []) ;
	 % M=(sprintf(maskpath,f1))>0;
	 
	 [tc,P]=klt_selfeats(tc,I,M);
	 K(:,:,1)=P;
	 
	 n=sum(P(3,:)>=0);
	 fprintf('%d found\n', n);
	 
	 for f=f1+1:f2    
	     I=single(rgb2gray(imread(sprintf(imgpath,f))));
	     % M=imread(sprintf(maskpath,f))>0;
	     M = dets_to_mask_new(load(sprintf(detspath,f),'newbxs'), I, []) ;
	     [tc,P]=klt_track(tc,P,I,[]);
	 
	     nt=sum(P(3,:)>=0);
	     fprintf('%d tracked\n', nt);
	     
	     [tc,P]=klt_selfeats(tc,I,M,P);    
	     K(:,:,f-f1+1)=P;
	     
	     nn=sum(P(3,:)>=0);
	 	 tracked = [tracked nt] ;
	     
	     fprintf('Frame %d: now %d (%d replaced)\n', f, nn, nn-nt);
	     
	     % subplot(121);
	     % imagesc(I.*M);
	     % hold on;
	     % plot(P(1,P(3,:)==0),P(2,P(3,:)==0),'g+','linewidth',2,'markersize',10);
	     % plot(P(1,P(3,:)>0),P(2,P(3,:)>0),'r+','linewidth',2,'markersize',10);
	     % hold off;
	     % axis image;
	     % axis off;
	 
	     % subplot(122);
	     % [T,v]=klt_parse(K(:,:,1:f-f1+1));
	     % imagesc(~isnan(squeeze(T(1,:,:)))')    
	     % xlabel 'frame';
	     % ylabel 'feature';
	     
	     % colormap gray;
	     % drawnow;
	     
	 end
 end
