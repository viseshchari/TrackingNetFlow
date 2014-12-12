function write_webm_chunk_double(pipef1, pipef2, tmpfile, frames)
    for i = 1:size(frames,4)
        imwrite(frames(:,:,:,i), tmpfile, 'jpg', 'Quality', 90);
        imf = fopen(tmpfile, 'rb');
        imbytes = fread(imf);
        fwrite(pipef1, imbytes);
        fwrite(pipef2, imbytes);
        fclose(imf);
    end
end
