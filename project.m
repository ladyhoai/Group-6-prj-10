close all

%Specifying path to retrieve the Contour and EM data
Contour_Path = '/Users/nguyenxuankhoi/Library/CloudStorage/OneDrive-UTS/Contours/';
EM_Path = '/Users/nguyenxuankhoi/Library/CloudStorage/OneDrive-UTS/EM/';

%Turn these booleans on/off to sketch the reconstructed aorta contour and distance line
plot_ring = true;
plot_distance_line = false;

%Change file_length so that it matches your data.
%In our case, we have 2002 EM and Contour files.
%This code assumes that the number of EM and Contour files are equal
file_length = 2002;

%EM_i is our file iterator
Em_i = 0;

%The 3 arrays below is to store the xyz coordinate of each points of the
%centerline
cenX = zeros(1, file_length);
cenY = zeros(1, file_length);
cenZ = zeros(1, file_length);

% Initialize an array to store all transformed points
all_transformed_points = [];

for k=1:file_length

    file = fopen([Contour_Path, int2str(Em_i), '.txt'], 'r');
    %# Get file size.
    fseek(file, 0, 'eof');
    fileSize = ftell(file);
    frewind(file);
    %# Read the whole file.
    data = fread(file, fileSize, 'uint8');
    %# Count number of line-feeds and increase by one.
    numLines = sum(data == 10) + 1;
    fclose(file);
    
    %X and Y is used to read the contour data
    X = zeros(numLines-1, 1);
    Y = zeros(numLines-1, 1);
    
    fileID = fopen([Contour_Path, int2str(Em_i), '.txt'], 'r');
    
    % The while loop below is used to read the contour data from a file
    i = 1;
    while ~feof(fileID) 
        line = fgetl(fileID);
        xy_coord = textscan(line, '%s %s', 1);
        X(i,1) = str2double(cell2mat(xy_coord{1}));
        Y(i,1) = str2double(cell2mat(xy_coord{2}));
        i = i + 1;
    end

    fclose(fileID);

    %Calculating the 2D center of the contour
    a = mean(X); 
    b = mean(Y);

    %The while loop and the variables before it is used to retrieve data
    %from each EM file
    EM_File = fopen([EM_Path, int2str(Em_i), '.txt'], 'r');
    Em_i = Em_i + 1;
    quad_ro = zeros(1, 4);
    trans = zeros(3, 1);
    
    while ~feof(EM_File)
        line = fgetl(EM_File);
        xy_coord = textscan(line, '%s %s %s %s %s %s %s', 1);
        
        trans(1, 1) = str2double(cell2mat(xy_coord{1}));
        trans(2, 1) = str2double(cell2mat(xy_coord{2}));
        trans(3, 1) = str2double(cell2mat(xy_coord{3}));

        quad_ro(1) = str2double(cell2mat(xy_coord{4}));
        quad_ro(2) = str2double(cell2mat(xy_coord{5}));
        quad_ro(3) = str2double(cell2mat(xy_coord{6}));
        quad_ro(4) = str2double(cell2mat(xy_coord{7}));
    end
    
    %Converting the quartenion rotation to a 3x3 rotation matrix
    RE = quat2rotm(quad_ro);
    
    %Using translation and rotation to find the 3D location of the center
    %of each contour
    mat_center = RE * [a; b; 0] + trans;
    
    %Storing the xyz coordinate in 3 separate array
    cenX(1, k) = mat_center(1,1);
    cenY(1, k) = mat_center(2,1);
    cenZ(1, k) = mat_center(3,1);
   
    % Initialize an array to store transformed points for the current file
    transformed_points = zeros(1, 3);

    % Combine rotation and translation into a 4x4 homogeneous transformation matrix
    transformation_matrix = eye(4);
    transformation_matrix(1:3, 1:3) = RE(1:3, 1:3);
    transformation_matrix(1:3, 4) = trans;

    % Apply the transformation to a point (e.g., [0, 0, 0])
    input_point = [0; 0; 0; 1]; % Homogeneous coordinates
    output_point = transformation_matrix * input_point;

    % Store the transformed point in the array
    transformed_points(1, :) = output_point(1:3)';
    
    % Concatenate the transformed points to the overall array
    all_transformed_points = [all_transformed_points; transformed_points];

    fclose(EM_File);
    
    %The if section is used to sketch the 3D contour
    if(plot_ring) 
        X_new = zeros(1, numLines-1);
        Y_new = zeros(1, numLines-1);
        Z_new = zeros(1, numLines-1);

        for y=1:i-1
            mat_z = RE * [X(y, 1)'; Y(y, 1)'; 0] +trans;
            X_new(1, y) = mat_z(1, 1);
            Y_new(1, y) = mat_z(2, 1);
            Z_new(1, y) = mat_z(3, 1);
        end
        plot3( X_new,  Y_new,  Z_new, '-')
        hold on 
    end
    i = 1;
end

distance_array = [];

% Finding the distance between the centerline and robot's path
for i=1:file_length 
   distance_array = [distance_array, norm([cenX(1, i), cenY(1, i), cenZ(1, i)] - [all_transformed_points(i, 1), all_transformed_points(i, 2), all_transformed_points(i, 3)])];
end
%Uncomment the line below to print out the array that contain the offset between the centerline and catheter's path
%distance_array

hold on

    plot3(all_transformed_points(:, 1), all_transformed_points(:, 2), all_transformed_points(:, 3), '-', 'LineWidth', 2)
    scatter3(cenX, cenY, cenZ, 30, 'MarkerEdgeColor','k','MarkerFaceColor',[1 0 0])%,'bo', 'MarkerSize', 10);
        
    if (plot_distance_line)
        for i = 1:file_length
          plot3([cenX(i), all_transformed_points(i, 1)], ...
          [cenY(i), all_transformed_points(i, 2)], ...
          [cenZ(i), all_transformed_points(i, 3)], 'o--');
        end
    end
xlabel('X-axis');
ylabel('Y-axis');
zlabel('Z-axis');
title('3D Path of Transformed Points with Distance Lines');

legend('Robot Path', 'Catheter Path', 'Distance Lines');
