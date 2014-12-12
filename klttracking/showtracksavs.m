function showtracksavs(avsfname,avifname,tracks,thickness)


if ~isempty(tracks)
    frames=[tracks(:).frame];
    
    % generate .avs
    vgfname=regexprep(regexprep(avsfname,'\.avs','\.vg'),'[^/]*/','');
    % fd=fopen(avsfname,'w');
    % fprintf(fd,'d2vplugin="DGDecode.dll"\n');
    % fprintf(fd,'vgplugin="AVSVectorGraphics.dll"\n');
    % fprintf(fd,'LoadPlugin(d2vplugin)\n');
    % fprintf(fd,'LoadPlugin(vgplugin)\n');
    % fprintf(fd,'AVISource("%s")\n',avifname);
    % fprintf(fd,'VectorGraphics("%s")\n',vgfname);
    % fclose(fd);

    fd=fopen(avsfname,'w');
    
%     fprintf(fd,'d2vplugin="DGDecode.dll"\n');
    fprintf(fd,'vgplugin="AVSVectorGraphics.dll"\n');
%     fprintf(fd,'LoadPlugin(d2vplugin)\n');
    fprintf(fd,'LoadPlugin(vgplugin)\n');
    
    fprintf(fd,'AVISource("%s")\n',avifname );
    % fprintf(fd,'Import("init.avs")\n');
    fprintf(fd,'VectorGraphics("%s")\n',vgfname);
    fprintf(fd,'Trim(%i,%i)',min(frames),max(frames));
    fclose(fd);
    
    % generate .vg
    t=tracks(1);
    if isfield(t,'track')
        ids=[tracks(:).track];
    else
        ids=1:length(tracks);
    end
    
    frames=[tracks(:).frame];
    ccol=lines(max(ids));
    vgfname=regexprep(avsfname,'\.avs','\.vg');
    fd=fopen(vgfname,'w');
    %fprintf(fd,'text 0 1000000 0 0 2 0xffffff 0x000000 %s\n',avifname);
    uframes=unique(frames);
    for i=1:length(uframes)
        f=uframes(i)-1;
        ind=find(frames==f);
        for j=1:length(ind)
            det=tracks(ind(j));
            id=ids(ind(j));
            conf=det.conf;
            t=det;
            if isfield(t,'trackconf')
                trackconf=det.trackconf;
            else
                trackconf=conf;
            end
            lab=sprintf('%d(%1.3f)',id,trackconf);
            rect=round(det.rect);
            ccolstr=num2str(dec2hex(round(ccol(id,:).*255)))';
            ccolstr=lower(transpose(ccolstr(:)));
            %     lw=find(histc(trackconf,[-1.2 -1 -.8 -.6 -.4 -.2 0 .2 .4 .6 .8 inf]));
            %     if length(lw)
            fprintf(fd,'box %d %d %d %d %d %d %d 0x%s\n',f,f,rect,thickness,ccolstr);
            fprintf(fd,'text %d %d %d %d 2 0x%s 0x000000 %s\n',f,f,rect(1:2),ccolstr,lab);
            %     end
        end
    end
    fclose(fd);
end
