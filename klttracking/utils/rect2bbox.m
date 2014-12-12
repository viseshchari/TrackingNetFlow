function bbox=rect2bbox(rect)
  
bbox=rect;
if length(rect)
  bbox(:,3)=rect(:,1)+rect(:,3);
  bbox(:,4)=rect(:,2)+rect(:,4);
end