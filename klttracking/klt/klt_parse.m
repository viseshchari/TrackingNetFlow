% KLT_PARSE  Parse output of KLT tracker
%   [T,v] = klt_parse(P) parses the output of the KLT tracker into distinct
%   tracks. P is a 3 x nfeats x nframes matrix formed by concatenating the
%   per-frame output of KLT_SELFEATS and KLT_TRACK. T is a 2 x nframes x
%   ntracks matrix with columns [x ; y]. Features missing from a frame
%   contain [nan ; nan]. v is a vector of ntracks elements containing the
%   'goodness' i.e. smaller eigenvalue of the feature in the first frame in
%   which it appears.
%
%   See also KLT_INIT, KLT_SELFEATS, KLT_TRACK.

function [T,v] = klt_parse(P)

nf=size(P,2);
ni=size(P,3);
nt=sum(sum(P(3,:,:)>0));

T=repmat(nan,[2 ni nt]);
v=zeros(nt,1);

k=0;
for i=1:nf
    for j=1:ni
        if P(3,i,j)>0
            k=k+1;
            v(k)=P(3,i,j);
        end
        if P(3,i,j)>=0
            T(:,j,k)=P(1:2,i,j);
        end
    end
end
