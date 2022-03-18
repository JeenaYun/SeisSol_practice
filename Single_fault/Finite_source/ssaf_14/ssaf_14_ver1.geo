lc = 1.5e3;
lc_fault1 = 80;
lc_fault2 = 5e2;
lc_nucl = 50;


// Fault1 (rupture plane) size
Fault1_length = 3e3;                // Horizontal extent of the fault
Fault1_width = 3e3;                 // Vertical extent of the fault
Fault1_dep = -7e3;                  // Fault center depth

// Fault2 (receiver fault) size
Fault2_length = 3e3;                // Horizontal extent of the fault
Fault2_width = 6e3;                 // Vertical extent of the fault
Fault2_strike = 17*Pi/180.;         // Fault Strike
Fault2_dep = -5e3;                  // Fault center depth

// Hypocenter location
Hyp_lat = 2.192e3;
Hyp_lon = -1.065e3;  

//Nucleation in X,Z local coordinates
X_nucl = 0e3;                      // X coordinate of nucleation patch center
Width_nucl = -7e3;                  // Z coordinate of nucleation patch center
R_nucl = 0.25e3;                   // Half of the size of nucleation patch

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
Point(100) = {-0.5*Fault1_length , 0 , Fault1_dep - 0.5 * Fault1_width, lc_fault1};
Point(101) = {-0.5*Fault1_length , 0 , Fault1_dep + 0.5 * Fault1_width, lc_fault1};
Point(102) = { 0.5*Fault1_length , 0 , Fault1_dep + 0.5 * Fault1_width, lc_fault1};
Point(103) = { 0.5*Fault1_length , 0 , Fault1_dep - 0.5 * Fault1_width, lc_fault1};
Line(100) = {100, 101};
Line(101) = {101, 102};
Line(102) = {102, 103};
Line(103) = {103, 100};

Point(110) = {Hyp_lon - 0.5 * Fault2_length * Sin(Fault2_strike) , Hyp_lat - 0.5 * Fault2_length * Cos(Fault2_strike) , Fault2_dep - 0.5 * Fault2_width, lc_fault2};
Point(111) = {Hyp_lon - 0.5 * Fault2_length * Sin(Fault2_strike) , Hyp_lat - 0.5 * Fault2_length * Cos(Fault2_strike) , Fault2_dep + 0.5 * Fault2_width, lc_fault2};
Point(112) = {Hyp_lon + 0.5 * Fault2_length * Sin(Fault2_strike) , Hyp_lat + 0.5 * Fault2_length * Cos(Fault2_strike) , Fault2_dep + 0.5 * Fault2_width, lc_fault2};
Point(113) = {Hyp_lon + 0.5 * Fault2_length * Sin(Fault2_strike) , Hyp_lat + 0.5 * Fault2_length * Cos(Fault2_strike) , Fault2_dep - 0.5 * Fault2_width, lc_fault2};
Line(110) = {110, 111};
Line(111) = {111, 112};
Line(112) = {112, 113};
Line(113) = {113, 110};

//create nucleation patch
Point(201) = {X_nucl + R_nucl , 0 , Width_nucl - R_nucl, lc_nucl};
Point(202) = {X_nucl + R_nucl , 0 , Width_nucl + R_nucl, lc_nucl};
Point(203) = {X_nucl - R_nucl , 0 , Width_nucl + R_nucl, lc_nucl};
Point(204) = {X_nucl - R_nucl , 0 , Width_nucl - R_nucl, lc_nucl};
Line(200) = {201, 202};
Line(201) = {202, 203};
Line(202) = {203, 204};
Line(203) = {204, 201};
Line Loop(204) = {200,201,202,203};
Plane Surface(200) = {204};


Line Loop(105) = {100,101,102,103,200,201,202,203};
Plane Surface(100) = {105};
Line Loop(115) = {110,111,112,113};
Plane Surface(110) = {115};


//There is a bug in "Attractor", we need to define a Ruled surface in FaceList
Line Loop(106) = {100,101,102,103};
Ruled Surface(101) = {106};
Ruled Surface(111) = {115};
Ruled Surface(201) = {204};

Surface{100,110,200} In Volume{1};

//1.2 Managing coarsening away from the fault
// Attractor field returns the distance to the curve (actually, the distance to 100 equidistant points on the curve)
Field[1] = Distance;
Field[1].FacesList = {101,111};

// Matheval field returns "distance squared + lc/20"
Field[2] = MathEval;
Field[2].F = Sprintf("0.05*F1 +(F1/2.5e3)^2 + %g", lc_fault1);

//3.4.5 Managing coarsening around the nucleation Patch
//equivalent of propagation size on element
Field[3] = Threshold;
Field[3].IField = 1;
Field[3].LcMin = lc_fault2;
Field[3].LcMax = lc;
Field[3].DistMin = 2*lc_fault2;
Field[3].DistMax = 2*lc_fault2+0.001;

Field[4] = Min;
Field[4].FieldsList = {2,3};

Background Field = 4;

Physical Surface(101) = {1};
Physical Surface(103) = {100,110,200};
//This ones are read in the gui
Physical Surface(105) = {14,18,22,26,27};

Physical Volume(1) = {1};
Mesh.MshFileVersion = 2.2;
