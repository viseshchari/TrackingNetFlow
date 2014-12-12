% rectangles are in columns [x1 x2 y1 y2]'

function [a1,a2,O] = rectoverlap(RC1,RC2)

O=zeros(size(RC1,2),size(RC2,2));

a1=(RC1(2,:)-RC1(1,:)+1).*(RC1(4,:)-RC1(3,:)+1);
a2=(RC2(2,:)-RC2(1,:)+1).*(RC2(4,:)-RC2(3,:)+1);

for i=1:size(RC1,2)
    RI=[max(RC1(1,i),RC2(1,:)) ;
        min(RC1(2,i),RC2(2,:)) ;
        max(RC1(3,i),RC2(3,:)) ; 
        min(RC1(4,i),RC2(4,:))];
    iw=RI(2,:)-RI(1,:)+1;
    ih=RI(4,:)-RI(3,:)+1;
    iw(iw<=0|ih<=0)=0;
    amin=min(a1(i),a2);
    O(i,:)=iw.*ih./min(a1(i),a2);
end
        