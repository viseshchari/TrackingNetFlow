function showrect(rect,ccol,labels,linewidth,textheight,cornersflag)
  
% showrect(rect,ccol,labels)
%
%  displays N rectangles in a Nx4 array 'rect'
%
%  
  
n=size(rect,1);
if nargin<2 ccol=[]; end
if nargin<3 labels={}; end
if nargin<4 linewidth=1; end
if nargin<5 textheight=5+linewidth; end
if nargin<6 cornersflag=0; end
if ~length(ccol) ccol=lines(n); end
if size(ccol,1)==1 ccol=ones(n,1)*ccol; end

for i=1:n
  if rect(i,3)~=0 & rect(i,4)~=0
    if ~cornersflag
      rectangle('Position',rect(i,:),'EdgeColor',ccol(i,:),'LineWidth',linewidth);
    else
      len=mean(rect(i,3:4))/5;
      x1=rect(i,1); x2=sum(rect(i,[1 3]));
      y1=rect(i,2); y2=sum(rect(i,[2 4]));
      line([x1 x1+len],[y1 y1],'Color',ccol(i,:),'LineWidth',linewidth)
      line([x2 x2-len],[y1 y1],'Color',ccol(i,:),'LineWidth',linewidth)
      line([x1 x1],[y1 y1+len],'Color',ccol(i,:),'LineWidth',linewidth)
      line([x2 x2],[y1 y1+len],'Color',ccol(i,:),'LineWidth',linewidth)
      line([x1 x1+len],[y2 y2],'Color',ccol(i,:),'LineWidth',linewidth)
      line([x2 x2-len],[y2 y2],'Color',ccol(i,:),'LineWidth',linewidth)
      line([x1 x1],[y2 y2-len],'Color',ccol(i,:),'LineWidth',linewidth)
      line([x2 x2],[y2 y2-len],'Color',ccol(i,:),'LineWidth',linewidth)
    end
    if length(labels) 
      ht=text(rect(i,1),rect(i,2)-textheight,labels{i},'Color',ccol(i,:));
      %ht=text(rect(i,1),rect(i,2)+rect(i,4)-textheight,labels{i},'Color',ccol(i,:));
      set(ht,'FontSize',10,'FontWeight','bold','BackgroundColor',1-ccol(i,:));
      %keyboard
    end
  end
end
