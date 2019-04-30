function separateFrames()
    original_Video = VideoReader('Original_Video.avi');                     % define the name of input video
    loop = 1;                                                               % each frame will be saved with increasing number 
    while hasFrame(original_Video)                                          % continue loop until the last frame of video
        img = readFrame(original_Video);                                    % read a frame
        filename = [sprintf('%s%04d','img',loop) '.tif'];                   % make a name of frame to save
        fullname = fullfile('C:\Users\Shoaib\Desktop\Github IWT Repo\images',filename);% combine directory and name of frame
        imwrite(img,fullname);                                              % save the frame
        loop = loop+1;                                                      % increase loop to save next frame with different name
    end  
end