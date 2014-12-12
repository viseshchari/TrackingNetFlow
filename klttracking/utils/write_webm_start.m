function [pipef, tmpfile] = write_webm_start(filename)
    [~, tmpfile] = system(['mktemp']);
    tmpfile = strtrim(tmpfile);
    pipefile = strrep(filename, '.webm', '_pipe');
    if exist(pipefile, 'file')
        delete(pipefile);
    end
    system(['mkfifo ' pipefile]);
    thispath = mfilename('fullpath');
    piperpath = [thispath(1:end-6) '.sh'];
    system([piperpath ' "' pipefile '" "' filename '" &']);
    pipef = fopen(pipefile, 'wb');
end
