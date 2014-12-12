function showbbox(bbox,ccol,labels,linewidth,textheight)
  
% showbbox(bbox,ccol,labels,linewidth,textheight)
%
%  displays N bounding boxes in a Nx4 array 'bbox'
%
%  
  
n=size(bbox,1);
if nargin<2 ccol=[]; end
if nargin<3 labels={}; end
if nargin<4 linewidth=1; end
if nargin<5 textheight=5+linewidth; end
if ~length(ccol) ccol=lines(n); end
if size(ccol,1)==1 ccol=ones(n,1)*ccol; end

showrect(bbox2rect(bbox),ccol,labels,linewidth,textheight);