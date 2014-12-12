if ~exist([datadir '/facedist_faceklt'],'file')
    mkdir([datadir '/facedist_faceklt']);
end


if ~isempty(UBdet)
    
    fdf=[UBdet.frame];
    
    for s=1:size(SHOTS,2)
        fprintf('shot %d/%d\n',s,size(SHOTS,2));
        trkpathF=sprintf('%s/faceklt/%06d-%06d_1.mat',datadir,SHOTS(1,s),SHOTS(2,s));
        trkpathB=sprintf('%s/faceklt/%06d-%06d_-1.mat',datadir,SHOTS(1,s),SHOTS(2,s));
        distpath=sprintf('%s/facedist_faceklt/%06d-%06d.mat',datadir,SHOTS(1,s),SHOTS(2,s));
        lockpath=sprintf('%s/facedist_faceklt/%06d-%06d.lock',datadir,SHOTS(1,s),SHOTS(2,s));
        if exist(distpath,'file')
            continue
        end
        if exist(lockpath,'file')
            continue
        end
        fid=fopen(lockpath,'w');
        if fid==-1
            continue
        end
        
        load(trkpathF,'K');
        [TX,TY]=klt_parse_sparse(K);
        
        load(trkpathB,'K');r
        K=K(:,:,end:-1:1);
        [TXb,TYb]=klt_parse_sparse(K);
        TXb=TXb(end:-1:1,:);
        TYb=TYb(end:-1:1,:);
        TX=[TX TXb];
        TY=[TY TYb];
        
        f1=SHOTS(1,s);
        f2=SHOTS(2,s);
        
        fdi=find(fdf>=f1&fdf<=f2);
        
        BB=zeros(4,length(fdi));
        frm=[UBdet(fdi).frame];
        for i=1:length(fdi)
            BB(:,i)=rectunion(UBdet(fdi(i)).rect');
        end
        
        fprintf('%d-%d: %d\n',f1,f2,length(frm));
        V=sparse(size(TX,2),length(frm));
        V=logical(V);
        tic;
        for i=1:length(frm)
            if toc>1
                fprintf('\tcompute %d/%d\n',i,length(frm));
                tic;
            end
            fa=frm(i);
            bba=BB(:,i);
            va=TX(fa-f1+1,:)>0&...
                TX(fa-f1+1,:)>=bba(1)&TX(fa-f1+1,:)<=bba(2)&...
                TY(fa-f1+1,:)>=bba(3)&TY(fa-f1+1,:)<=bba(4);
            V(:,i)=va';
        end
        
        C=zeros(length(frm));
        NI=zeros(length(frm));
        
        tic;
        for i=1:length(frm)
            
            C(i,i)=-inf;
            
            for j=1:i-1
                
                if frm(i)==frm(j)
                    c=-inf;
                    ni=0;
                else
                    ni=sum(V(:,i)&V(:,j));
                    c=ni/(sum(V(:,i)|V(:,j)));
                end
                
                C(i,j)=c;
                C(j,i)=c;
                NI(i,j)=ni;
                NI(j,i)=ni;
            end
            
            if toc>1||i==numel(frm)
                fprintf('-- intersect %d/%d\n',i,numel(frm));
                tic;
            end
        end
        
        save(distpath,'fdi','BB','C','NI');
        fclose(fid);
        delete(lockpath);
    end
end