
if ~isempty(UBdet)

  nc=0;
  for s=1:size(SHOTS,2)
    fprintf('shot %d/%d: %d tracks\n',s,size(SHOTS,2),nc);
    
    distpath=sprintf('%s/facedist_faceklt/%06d-%06d.mat',datadir,SHOTS(1,s),SHOTS(2,s));
    load(distpath,'fdi','BB','C','NI');
    if isempty(fdi)
      continue
    end
    fdf=[UBdet(fdi).frame]';
    FD=repmat(fdf,1,numel(fdf))-repmat(fdf',numel(fdf),1);
    C(~FD)=-inf;
    
    clus=agglomclus(C,0.5);
    
    for i=1:length(clus)
      nc=nc+1;
      for j=1:length(clus{i})
	k=clus{i}(j);
	UBdet(fdi(k)).track=nc;
      end
      
      % adjust track length and mean confidence values
      ind=find([UBdet.track]==nc);
      trackconf=mean([UBdet(ind).conf]);
      tracklength=length(ind);
      for j=1:length(ind)
	UBdet(ind(j)).trackconf=trackconf;
	UBdet(ind(j)).tracklength=tracklength;
      end
    end
  end
end
