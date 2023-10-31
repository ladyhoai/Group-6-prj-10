# Group-6-prj-10
MATLAB repository for surgical robot project
Group member: Xuan Kien Nguyen (14363978) and Van Minh Duc Nguyen (24624114)

To select plot mode, there are 2 booleans: 'plot_ring' and 'plot_distance_line'. Change plot_ring to true to plot the 3D contour. Change plot_distance_line to true to visualize the distance between the centreline and the actual cathether's path. 

To run the code with a different dataset, change 'file_length' to the number of Contour or EM file (In our case, we have 2002 contour files). This code assumes that the number of Contour and EM file are equal. Also, make sure to change 'Contour_Path' and 'EM_Path' to the location of the data folder that is different for each computer.

Code structure:
- Specify the path to the data folder and initialize required variables
- Main loop: perform the same operation for every pair of contour and EM data:
  + Iterate through the contour file to find the total number of lines (number of xy-coordinate pair)
  + The number of line is used as the boundary for the next for-loop, which read the contour data and store them in 2 arrays that hold x and y position separately
  + Find the mean of each array, which gives the xy coordinate of the centre of the 2D contour.
  + Read the EM file to get the rotation and translation data. Convert the quaternion rotation to a 3x3 rotation matrix.
  + Use the 3D transformation formula : 'mat_center = RE * [a; b; 0] + trans' to convert the 2D center to its corresponding 3D location. The same technique can be used to transform the entire 2D contour to 3D.
  + From the same EM data, we find the actual path that the cathether took.
  + Plot the result.
 
Above is the structure of the code. Also, there are comments in the code file that further specify what each lines of the code do.

Contribution:
* Xuan Kien Nguyen: 
  - Read and initialize the variables to handle data.
  - Calculate, transform and plot the 3D centreline.
 
* Van Minh Duc Nguyen:
  - Calculate and transform the 3D path that the cathether took.
  - Find the distance between the centreline and the actual path and visualize its distance.
