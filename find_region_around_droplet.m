% --------------------------------------------------------------------------------------------------------------------
% Muhammad Shoaib Sikander ......................... Last Modified: 30-April-2019 (Tuesday)
% This code loads images from a folder, performs thresholding and saves results in the form of images and video.
% After that, droplet is detected in threshold images.
% Then a window of fix size is captured around centre of droplet.
% --------------------------------------------------------------------------------------------------------------------
clear all;

%% split frames of input original video
disp('Splitting the frames of Original Video...!');
separateFrames();                                                      % call the function to split frames

%% define working directory and initialize cell arrays.
window_size = 20;                                                      % define the surrounding window size
workingDir = 'C:\Users\Shoaib\Desktop\Github IWT Repo';                % define a directory where all the project files are
filePattern = fullfile(workingDir,'images', '*.tif');                  % connect images folder with directory to read original images
tifFiles = dir(filePattern);                                           % list all images in folder
name = {tifFiles.name}';                                               % copy the names folder
number = numel(tifFiles);                                              % find the number of images in folder

cellCentres = cell(1,number);                                          % initialize a cell to store centre of droplet in each frame
cellArea = cell(1,number);                                             % initialize a cell to store area of droplet in each frame
row = zeros(1,number);                                                 % initialize an array to store the row value of centre point
column = zeros(1,number);                                              % initialize an array to store the column value of centre point

%% for each image, perform thresholding, find region properties and store in cell arrays.
disp('Thresholding...!');
for k=11:number                                                        % start loop from 11th frame                                  
    img_name_current = tifFiles(k).name;                               % copy the name of image                               
    img_fullpath_current = fullfile(workingDir, 'images', img_name_current);% define complete path of current frame
    img_Read = imread(img_fullpath_current);                           % read current frame
    
    img_name_background = tifFiles(k-10).name;                         % copy the name of image for background
    img_fullpath_background = fullfile(workingDir, 'images', img_name_background); %define complete path of background image
    img_Background = imread(img_fullpath_background);                  % read the background image

    img_Sub = imsubtract(img_Background, img_Read);                    % subtract current frame from background image
    img_Edge = edge(img_Sub,'canny',[0.5 0.9],5);                      % find edges in the subtracted image
    img_Fill = imfill(img_Edge,'holes');                               % fill the image after finding edges
    
    filename = [sprintf('%s%04d','Imag',k) '.tif'];                    % make a name of image to save
    fullname = fullfile(workingDir,'threshold_images',filename);       % define complete path of image
    imwrite(img_Fill, fullname);                                       % save processed frame (filled image)
    
    s = regionprops(img_Fill,'centroid', 'Area');                      % find regions in the image and get their centres and area
    centres = cat(1,s.Centroid);                                       % concatenate centres one after another in a frame
    areas = cat(1,s.Area);                                             % concatenate areas one after another in a frame
    fprintf('Frame No: %d\n', k);                                      % display frame number on the console
    disp('------------------------------------------------------');    % display on console
%    disp('Centre Point : ');                                          % display centre points on the console
%    disp(centres);                                                    % display centre points on the console
%    disp('Area : ');                                                  % display areas of detected regions on the console
%    disp(areas);                                                      % display areas of detected regions on the console
%    disp('No. of points detected : ');                                % display number of detected regions
%    disp(size(centres,1));                                            % display number of detected regions
    
    cellArea{k} = areas;                                               % save areas in a cell
    cellCentres{k} = centres;                                          % save centre points in a cell
end                                                                    % end loop

%% remove extra regions in each frame and refine the results stored in cell arrays.
cellsLength = cellfun('length',cellArea);                              % find the length of each cell containing Areas
for j=1:length(cellsLength)                                            % start loop(a loop iteration for each frame)
    if cellsLength(j) > 1                                              % if there are more than one regions in an image
        cellArea{j} = 0;                                               % make that cell element equal to zero
    end                                                                % finish if-condition
    ar = cellArea{j}();                                                % get the value of area in a cell element index
    if ar <150                                                         % if area is less than 150
        cellArea{j}=0;                                                 % make that cell index equal to zero
    end                                                                % finish if-condition
    if isempty(cellArea{1,j})                                          % if a particular area cell array index is empty
        cellArea{j}=0;                                                 % make that equalt to zero
    end                                                                % finish if-condition
    if cellArea{j}() == 0                                              % if a cell element containing area is zero
        cellCentres{j} = 0;                                            % make corresponding element of centres cell equal to zero
    end                                                                % finish if-condition
    if cellCentres{j}()~= 0                                            % if cell centre index is not zero
        column(j) = round(cellCentres{j}(1));                          % get the column pixel
        row(j) = round(cellCentres{j}(2));                             % get the row pixel
    end                                                                % finish if-condition
end                                                                    % finish for-loop

row = row';                                                            % take transpose matrix containing row pixel of centre point of droplet
column = column';                                                      % take transpose matrix containing column pixel of centre point of droplet

%% capture a surrounding window around droplet and save it in a folder.
disp('Finding surrounding windows and storing in the folder...!');
img_name_size = tifFiles(1).name;                                      % copy the name of first image in the folder
img_fullpath_size = fullfile(workingDir, 'images', img_name_size);     % define complete path of first image
img_Read_size = imread(img_fullpath_size);                             % read first image
[size_img_rows, size_img_cols] = size(img_Read_size);                  % Find dimensions of first image (all images must have same dimensions)
for i=1:1:number                                                       % start running the loop from first till last frame
    rw = row(i);                                                       % get the row value of detected particle in current frame
    cl = column(i);                                                    % get the column value of detected particle in current frame
    if rw~=0 && cl~=0                                                  % if particle is present
        if (size_img_cols-cl > window_size)                            % if column value of detected particle has sufficient margin from border
            if (size_img_rows-rw > window_size)                        % if row value of detected particle has sufficient margin from border
                start_val = i;                                         % copy the frame number
                break;                                                 % break the for-loop
            end                                                        % finish if-condition
        end                                                            % finish if-condition
    end                                                                % finish if-condition
end                                                                    % finish for-loop

for i=number:-1:1                                                      % start running loop from last frame till first frame
    rw = row(i);                                                       % get the row value of detected particle in current frame
    cl = column(i);                                                    % get the column value of detected particle in current frame
    if rw~=0 && cl~=0                                                  % if particle is present
        if(size_img_cols-cl < (size_img_cols-window_size))             % if column value of detected particle has sufficient margin from border
            if(size_img_rows-rw < (size_img_rows-window_size))         % if row value of detected particle has sufficient margin from border
                finish_val = i;                                        % copy the frame number
                break;                                                 % break the for-loop
            end                                                        % finish if-condition
        end                                                            % finish if-condition
    end                                                                % finish if-condition
end                                                                    % finish for-loop
for j = start_val:1:finish_val
%for j=50:1:250                                                        % run the loop from 50th till 250th frame
    baseFileName = tifFiles(j).name;                                   % read the name of current frame of video                               
    fullFileName = fullfile(workingDir, 'images', baseFileName);       % define complete path of current frame
    currentFrame = imread(fullFileName);                               % read current frame
    
    if row(j)~=0 && column(j)~=0                                       % if row and column values are present (it means that yes there is a droplet)
        rw = row(j);                                                   % copy the value of row pixel
        cl = column(j);                                                % copy the value of column pixel

        surroundingWindow = currentFrame(rw-window_size:rw+window_size, cl-window_size:cl+window_size);% select a surrounding window around centre point
        
        filename = [sprintf('%03d',j) '.tif'];                         % make a name of image to save
        fullname = fullfile(workingDir,'final_images',filename);       % define complete path of image
%        imwrite(surroundingWindow, fullname);                         % save the image (surrounding window)
        imwrite(surroundingWindow, fullname, 'Compression', 'none', 'Resolution',[1270,1270]);  % save the image (surrounding window)
    end                                                                % finish if-condition
end                                                                    % finish for-loop

%% make video from threshold images, just to quick check the result of thresholding.
disp('Making Video from threshold images...!');
imageNames = dir(fullfile(workingDir,'threshold_images','*.tif'));     % define full path to load image
imageNames = {imageNames.name}';                                       % define the names of images to be read
outputVideo = VideoWriter(fullfile(workingDir,'Threshold_Video.avi')); % object to make a video from frames
outputVideo.FrameRate = 30;                                            % define the frame rate of video
open(outputVideo);                                                     % open video object
for ii = 1:length(imageNames)                                          % run the loop for total number of frames                                     
    img = imread(fullfile(workingDir,'threshold_images',imageNames{ii}));% read the frame
    img = im2uint8(img);                                               % Change the data type of the image to unit8
    writeVideo(outputVideo,img)                                        % add frame to the video
end                                                                    % finish loop
close(outputVideo);                                                    % close the video object
disp('All Done ... !!!');