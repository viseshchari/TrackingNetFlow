function [pick, ovmat] = nms_normtype(boxes, overlap, normtype)
% Non-maximum suppression.
%   pick = nms(boxes, overlap) 
% 
%   Greedily select high-scoring detections and skip detections that are 
%   significantly covered by a previously selected detection.
%
% Return value
%   pick      Indices of locally maximal detections
%
% Arguments
%   boxes     Detection bounding boxes (see pascal_test.m)
%   overlap   Overlap threshold for suppression
%             For a selected box Bi, all boxes Bj that are covered by 
%             more than overlap are suppressed. Note that 'covered' is
%             is |Bi \cap Bj| / |Bj|, not the PASCAL intersection over 
%             union measure.

if isempty(boxes)
  pick = [];
else
  x1 = boxes(:,1);
  y1 = boxes(:,2);
  x2 = boxes(:,3);
  y2 = boxes(:,4);
  s = boxes(:,end);
  area = (x2-x1+1) .* (y2-y1+1);
  ovmat = zeros(length(s), length(s)) ;

  [vals, I] = sort(s);
  pick = [];
  while ~isempty(I)
    last = length(I);
    i = I(last);
    pick = [pick; i];
    suppress = [last];
    for pos = 1:last-1
      j = I(pos);
      xx1 = max(x1(i), x1(j));
      yy1 = max(y1(i), y1(j));
      xx2 = min(x2(i), x2(j));
      yy2 = min(y2(i), y2(j));

	  % Common minimum rectangle if normtype == 0
	  if normtype == 0
		nx1 = min(x1(i),x1(j)) ;
		nx2 = max(x2(i),x2(j)) ;
		ny1 = min(y1(i),y1(j)) ;
		ny2 = max(y2(i),y2(j)) ;
		carea = (nx2-nx1+1)*(ny2-ny1+1) ;
	  end

      w = xx2-xx1+1;
      h = yy2-yy1+1;
	  % If either is less than 0
	  % then there is no overlap
      if w > 0 && h > 0
        % compute overlap 
		if normtype == 2
			o = w * h / area(j);
		elseif normtype == 0
			o = w * h / carea ;
		elseif normtype == 1
			o = w * h / area(i) ;
		end
        if o > overlap
		  ovmat(i, j) = 1 ;
          suppress = [suppress; pos];
        end
      end
    end
    I(suppress) = [];
  end  
end
