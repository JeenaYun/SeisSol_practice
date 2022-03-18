lc = 1e3;
lc_2 = 250;

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
Point(5) = {0, 0, -7e3, lc_2};
Line(1) = {1, 2};
Line(2) = {2, 3};
Line(3) = {3, 4};
Line(4) = {4, 1};
Line Loop(5) = {1,2,3,4};
Plane Surface(1) = {5};
Extrude {0,0, Zmin} { Surface{1}; }

Field[1] = Distance;
Field[1].NodesList = {5};

Field[2] = Threshold;
Field[2].IField = 1;
Field[2].LcMin = lc_2;
Field[2].LcMax = lc;
Field[2].DistMin = 2.5e3;
Field[2].DistMax = 5e3;

Field[3] = Min;
Field[3].FieldsList = {2};

Background Field = 3;

Physical Surface(101) = {1};

//This ones are read in the gui
Physical Surface(105) = {14,18,22,26,27};

Physical Volume(1) = {1};
Mesh.MshFileVersion = 2.2;

