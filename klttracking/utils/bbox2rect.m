function rect=bbox2rect(bbox)
  

rect=zeros(size(bbox));
if length(bbox)
  rect(:,1)=min(bbox(:,[1 3]),[],2);
  rect(:,2)=min(bbox(:,[2 4]),[],2);
  rect(:,3)=max(bbox(:,[1 3]),[],2)-rect(:,1)+1;
  rect(:,4)=max(bbox(:,[2 4]),[],2)-rect(:,2)+1;
end
