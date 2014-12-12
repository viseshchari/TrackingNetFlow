klaesfacepath=[datadir 'facedets/facedets_klaes_confthr05v2_raw.mat'];
outpath=[datadir 'facedets/facedets_raw.mat'];

load(klaesfacepath,'facedets');

for i=1:length(facedets)
    facedets(i).rect=facedets(i).rect';
    if facedets(i).viewpoint==1
        facedets(i).pose=1;
    else
        facedets(i).pose=1+(facedets(i).facing);
    end
end
facedets=rmfield(facedets,{'x' 'y' 'w' 'h' 'scale' 'viewpoint' 'facing'});

[t,si]=sort([facedets.frame]);
facedets=facedets(si);

save(outpath,'facedets');
