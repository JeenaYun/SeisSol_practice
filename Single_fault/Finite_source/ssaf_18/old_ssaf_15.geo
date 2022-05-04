lc = 1e3;
lc_fault = 80;

// Fault size
Fault_length = 3e3;                // Horizontal extent of the fault
Fault_width = 3e3;                // Vertical extent of the fault
Fault_dip = 90*Pi/180.;

//Nucleation in X,Z local coordinates
X_nucl = 0e3;                      // X coordinate of nucleation patch center
Width_nucl = 7e3;                  // Z coordinate of nucleation patch center
R_nucl = 0.25e3;                   // Half of the size of nucleation patch
lc_nucl = 50;

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

//Create the fault
Point(100) = {-0.5*Fault_length , 0 , -(7e3 + 0.5 * Fault_width), lc};
Point(101) = {-0.5*Fault_length , 0 , -(7e3 - 0.5 * Fault_width), lc};
Point(102) = { 0.5*Fault_length , 0 , -(7e3 - 0.5 * Fault_width), lc};
Point(103) = { 0.5*Fault_length , 0 , -(7e3 + 0.5 * Fault_width), lc};
Line(100) = {100, 101};
Line(101) = {101, 102};
Line(102) = {102, 103};
Line(103) = {103, 100};

//create nucleation patch
Point(201) = {X_nucl + R_nucl , 0 , -(Width_nucl+R_nucl), lc_nucl};
Point(202) = {X_nucl + R_nucl , 0 , -(Width_nucl-R_nucl), lc_nucl};
Point(203) = {X_nucl - R_nucl , 0 , -(Width_nucl-R_nucl), lc_nucl};
Point(204) = {X_nucl - R_nucl , 0 , -(Width_nucl+R_nucl), lc_nucl};
Line(200) = {201, 202};
Line(201) = {202, 203};
Line(202) = {203, 204};
Line(203) = {204, 201};
Line Loop(204) = {200,201,202,203};
Plane Surface(200) = {204};

Line Loop(105) = {100,101,102,103,200,201,202,203};
Plane Surface(100) = {105};

//There is a bug in "Attractor", we need to define a Ruled surface in FaceList
Line Loop(106) = {100,101,102,103};
Ruled Surface(101) = {106};
Ruled Surface(201) = {204};

Surface{100,200} In Volume{1};


//1.2 Managing coarsening away from the fault
// Attractor field returns the distance to the curve (actually, the
// distance to 100 equidistant points on the curve)
Field[1] = Distance;
Field[1].FacesList = {101};

// Matheval field returns "distance squared + lc/20"
Field[2] = MathEval;
//Field[2].F = Sprintf("0.02*F1 + 0.00001*F1^2 + %g", lc_fault);
//Field[2].F = Sprintf("0.02*F1 +(F1/2e3)^2 + %g", lc_fault);
Field[2].F = Sprintf("0.05*F1 +(F1/2.5e3)^2 + %g", lc_fault);

//3.4.5 Managing coarsening around the nucleation Patch
Field[3] = Distance;
Field[3].FacesList = {201};

Field[4] = Threshold;
Field[4].IField = 3;
Field[4].LcMin = lc_nucl;
Field[4].LcMax = lc_fault;
Field[4].DistMin = R_nucl;
Field[4].DistMax = 3*R_nucl;

Field[5] = Restrict;
Field[5].IField = 4;
Field[5].FacesList = {100,200} ;

//equivalent of propagation size on element
Field[6] = Threshold;
Field[6].IField = 1;
Field[6].LcMin = lc_fault;
Field[6].LcMax = lc;
Field[6].DistMin = 2*lc_fault;
Field[6].DistMax = 2*lc_fault+0.001;


Field[7] = Min;
Field[7].FieldsList = {2,5,6};


Background Field = 7;

Physical Surface(101) = {1};
Physical Surface(103) = {100,200};
//This ones are read in the gui
Physical Surface(105) = {14,18,22,26,27};

Physical Volume(1) = {1};
Mesh.MshFileVersion = 2.2;