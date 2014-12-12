

if ~exist([datadir '/faceklt'],'file')
    mkdir([datadir '/faceklt']);
end

if ~isempty(UBdet)
    fdf=[UBdet.frame];
    
    for s=1:size(SHOTS,2)
        fprintf('%s: %d/%d\n',videoName,s,size(SHOTS,2));
        
        for step=[1 -1]
            if step==1
                f1=SHOTS(1,s);
                f2=SHOTS(2,s);
            else
                f1=SHOTS(2,s);
                f2=SHOTS(1,s);
            end
            
            lockpath=sprintf('%s/faceklt/%06d-%06d_%d.lock',datadir,SHOTS(1,s),SHOTS(2,s),step);
            trkpath=sprintf('%s/faceklt/%06d-%06d_%d.mat',datadir,SHOTS(1,s),SHOTS(2,s),step);
            
            if exist(lockpath,'file')
                continue
            end
            
            if exist(trkpath,'file')
                continue
            end
            
            fid=fopen(lockpath,'w');
            if fid==-1
                continue
            end
            
            tc  = klt_init('nfeats',1000,'mindisp',0.5,'pyramid_levels',2,'mineigval',1/(255^6),'mindist',5);
            K   = zeros(3,tc.nfeats,max(f1,f2)-min(f1,f2)+1,'single');
            
            f=f1;
            
            % reading frame
            I = single(rgb2gray(imgs{imgs_frames==f}))/255;
            
            % creating the mask 
            M = false( size(I,1) , size(I,2) );
            v = find( fdf == f );
            for i = v
                bb = UBdet(i).rect;
                bb(1:2)     = max( min( bb(1:2) , size(I,2) ) , 1 );
                bb(3:4)     = max( min( bb(3:4) , size(I,1) ) , 1 );
                M( bb(3):bb(4) , bb(1):bb(2) ) = true;
            end
            
            [tc,P]=klt_selfeats(tc,I,M);
            K(:,:,f-min(f1,f2)+1)=P;
            for f=f1+step:step:f2
                fprintf('%s: shot %d frame %d (%d-%d)\n',videoName,s,f,f1,f2);
                
                % reading frame
                I = single(rgb2gray(imgs{imgs_frames==f}))/255;
                
                M=false(size(I,1),size(I,2));
                v=find(fdf==f);
                for i=v
                    bb=round(UBdet(i).rect);
                    bb(1:2)=max(min(bb(1:2),size(I,2)),1);
                    bb(3:4)=max(min(bb(3:4),size(I,1)),1);
                    M(bb(3):bb(4),bb(1):bb(2))=true;
                end
                
                [tc,P]=klt_track(tc,P,I,[]);
                if f~=f2
                    [tc,P]=klt_selfeats(tc,I,M,P);
                end
                K(:,:,f-min(f1,f2)+1)=P;
            end
            
            save(trkpath,'K');
            
            fclose(fid);
            
            delete(lockpath);
            
        end
    end
end
