lc = 5e2;

// Domain Size
Xmax = 6e3; 
Xmin = -Xmax;
Ymax = 6e3; 
Ymin = -Ymax;
Zmin = -12e3;

//Create the Volume
Point(1) = {Xmin, Ymin, 0, lc};
Point(2) = {Xmin, Ymax, 0, lc};
Point(3) = {Xmax, Ymax, 0, lc};
Point(4) = {Xmax, Ymin, 0, lc};
Line(1) = {1, 2};
Line(2) = {2, 3};
Line(3) = {3, 4};
Line(4) = {4, 1};
Line Loop(5) = {1,2,3,4};
Plane Surface(1) = {5};
Extrude {0,0, Zmin} { Surface{1}; }

Physical Surface(101) = {1};

//This ones are read in the gui
Physical Surface(105) = {14,18,22,26,27};

Physical Volume(1) = {1};
Mesh.MshFileVersion = 2.2;

