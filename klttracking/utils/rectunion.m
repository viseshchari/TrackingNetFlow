function rc = rectunion(RC)

rc=zeros(4,1);
rc([1 3])=min(RC([1 3],:),[],2);
rc([2 4])=max(RC([2 4],:),[],2);
