function [a,b] = read_platt(path)

fid = fopen(path);

A = cell2mat(textscan(fid,'%f','CommentStyle','#'));

a = A(1);
b = A(2);

fclose(fid);

end