function im = draw_rectangle_on_image(im, x1, y1, x2, y2, c, thickness)
    if nargin < 7, thickness = 3; end
    if isa(c,'double') && isa(im,'uint8'), c = uint8(255*c); end
    c = reshape(c, [1 1 length(c)]);
    im = draw_horiz_thick_line(im, x1, y1, x2, c, thickness);
    im = draw_horiz_thick_line(im, x1, y2, x2, c, thickness);
    im = draw_vert_thick_line(im, x1, y1, y2, c, thickness);
    im = draw_vert_thick_line(im, x2, y1, y2, c, thickness);
end

function im = draw_horiz_thick_line(im, x1, y, x2, c, thickness)
    if y < 1 || y > size(im, 1), return; end
    y1 = min(max(floor(y - (thickness-1) / 2), 1), size(im, 1));
    y2 = min(max(floor(y + (thickness-1) / 2), 1), size(im, 1));
    x1 = min(max(floor(x1), 1), size(im, 2));
    x2 = min(max(floor(x2), 1), size(im, 2));
    im(y1:y2,x1:x2,:) = repmat(c, [y2-y1+1, x2-x1+1 1]);
end

function im = draw_vert_thick_line(im, x, y1, y2, c, thickness)
    if x < 1 || x > size(im, 2), return; end
    x1 = min(max(floor(x - (thickness-1) / 2), 1), size(im, 2));
    x2 = min(max(floor(x + (thickness-1) / 2), 1), size(im, 2));
    y1 = min(max(floor(y1), 1), size(im, 1));
    y2 = min(max(floor(y2), 1), size(im, 1));
    im(y1:y2,x1:x2,:) = repmat(c, [y2-y1+1, x2-x1+1 1]);
end