function ov=bboxoverlapval(bb1,bb2,normtype)
% Ivan Laptev
% ov=bboxoverlapval(bb1,bb2,normtype)
%
%  returns normalized intersection area of two rectangles
%  'normtype' = -1: no normalization, absolute overlap area 
%                0: normalization by the area of common min. rectangle (default)
%                1: normalization by the area of the 1st rectangle
%                2: normalization by the area of the 2nd rectangle

if nargin<3 normtype=0; end

ov=zeros(size(bb1,1),size(bb2,1));
for i=1:size(bb1,1) 
  	for j=1:size(bb2,1) 
  			ov(i,j)=bboxsingleoverlapval(bb1(i,:),bb2(j,:),normtype);
  		end
end
function ov=bboxsingleoverlapval(bb1,bb2,normtype)

bb1=[min(bb1(1),bb1(3)) min(bb1(2),bb1(4)) max(bb1(1),bb1(3)) max(bb1(2),bb1(4))];
bb2=[min(bb2(1),bb2(3)) min(bb2(2),bb2(4)) max(bb2(1),bb2(3)) max(bb2(2),bb2(4))];

ov=0;
if normtype<0 ua=1;
elseif normtype==1
	ua=(bb1(3)-bb1(1)+1)*(bb1(4)-bb1(2)+1);
elseif normtype==2
	ua=(bb2(3)-bb2(1)+1)*(bb2(4)-bb2(2)+1);
elseif normtype==0
	bu=[min(bb1(1),bb2(1)) ; min(bb1(2),bb2(2)) ; max(bb1(3),bb2(3)) ; max(bb1(4),bb2(4))];
	ua=(bu(3)-bu(1)+1)*(bu(4)-bu(2)+1);
elseif normtype==3
	ua1=(bb1(3)-bb1(1)+1)*(bb1(4)-bb1(2)+1);
	ua2=(bb2(3)-bb2(1)+1)*(bb2(4)-bb2(2)+1);
end

bi=[max(bb1(1),bb2(1)) ; max(bb1(2),bb2(2)) ; min(bb1(3),bb2(3)) ; min(bb1(4),bb2(4))];
iw=bi(3)-bi(1)+1;
ih=bi(4)-bi(2)+1;
if normtype==3
	ov1 = 0 ;
	ov2 = 0 ;
	if iw>0 & ih>0
		ov1 = iw*ih/ua1 ;
		ov2 = iw*ih/ua2 ;
	end
	ov = max(ov1, ov2) ;
else
	if iw>0 & ih>0              
		ov=iw*ih/ua;
	end
end