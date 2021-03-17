function [data,framerate] = prep_video(file,trim)
% read and reformat video

v = VideoReader(file);
framerate = v.FrameRate;
ski_rgb = read(v);

for i = 1:size(ski_rgb,4)
    data(:,:,i) = rgb2gray(ski_rgb(trim(3):trim(4),trim(1):trim(2),:,i));
end