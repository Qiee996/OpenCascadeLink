(* Wolfram Language Test file *)

(* Tests on other operations on a single shape, requires MUnit *)

(* Loading relevant package *)
Get[FileNameJoin[{DirectoryName[$CurrentFile], "checkGraphicsRendering.m"}]];

Test[
	Needs["OpenCascadeLink`"];
	Needs["NDSolve`FEM`"];
	,
	Null
	,
	TestID->"OpenCascadeLink_Docs_ShapeProcessing-20200311-R2E2L2"
]

(* Internal boundaries *)

Test[
	shape1 = OpenCascadeShape[Cuboid[{-2, -2, -2}, {2, 2, 1/2}]];
	shape2 = OpenCascadeShape[Cylinder[]];
	union = OpenCascadeShapeUnion [shape1, shape2];
	intersection = OpenCascadeShapeIntersection [shape1, shape2];
	shapeInternalBoundaries = OpenCascadeShapeSewing[{union, intersection}];
	bmeshInternalBoundaries = OpenCascadeShapeSurfaceMeshToBoundaryMesh[shapeInternalBoundaries];
	meshInternalBoundaries = ToElementMesh[bmeshInternalBoundaries, "RegionMarker" -> {{{-1, -1, -1}, 1}, {{0, 0, 3/4}, 
    	2}, {{0, 0, 1/4}, 3}}];
	meshInternalBoundaries["MeshElementMarkerUnion"]
	,
	{1, 2, 3}
	,
	TestID->"OpenCascadeLink_Docs_ShapeProcessing-20200311-C5X4K6"
]

Test[
	Length[Map[meshInternalBoundaries["Wireframe"[ElementMarker == #[[1]], 
     "MeshElement" -> "MeshElements", 
     "ElementMeshDirective" -> Directive[EdgeForm[], FaceForm[#[[2]]]]]] &, {{1, Gray}, {2, Pink}, {3, Orange}}]]
     ,
     3
	,
	TestID->"OpenCascadeLink_Docs_ShapeProcessing-20200311-U6T1Q5"
]

(* Fillet *)

TestMatch[
	shape = OpenCascadeShape[Cuboid[{0, 0, 0}, {1, 2, 3}]];
	fillet = OpenCascadeShapeFillet[shape, 0.25];
	bmeshFillet = OpenCascadeShapeSurfaceMeshToBoundaryMesh[fillet];
	Length[ToElementMesh[bmeshFillet]["Coordinates"]]
	,
	x_Integer /; x > 1
	,
	TestID->"OpenCascadeLink_Docs_ShapeProcessing-20200311-P9Y7A8"
]

TestMatch[
	fillet = OpenCascadeShapeFillet[shape, 0.25, {1, 7}];
	bmeshFilletEdge = OpenCascadeShapeSurfaceMeshToBoundaryMesh[fillet];
	Length[ToElementMesh[bmeshFilletEdge]["Coordinates"]]
	,
	x_Integer /; x > 1
	,
	TestID->"OpenCascadeLink_Docs_ShapeProcessing-20200311-Z6Z1X5"
]

TestMatch[
	(* possible issue: radius too large *)
	shape = OpenCascadeShape[Cylinder[{{1, -1, 0}, {1, 1, 0}}, 1/2]];
	fillet = OpenCascadeShapeFillet[shape, 1]
	,
	$Failed
	,
	TestID->"OpenCascadeLink_Docs_ShapeProcessing-20200311-U7Q5E6"
]

(* Chamfers *)
TestMatch[
	shape = OpenCascadeShape[Cuboid[{0, 0, 0}, {1, 2, 3}]];
	chamfer = OpenCascadeShapeChamfer[shape, 0.25, {5, 6}];
	bmeshChamfer = OpenCascadeShapeSurfaceMeshToBoundaryMesh[chamfer];
	Length[ToElementMesh[bmeshChamfer]["Coordinates"]]
	,
	x_Integer /; x > 1
	,
	TestID->"OpenCascadeLink_Docs_ShapeProcessing-20200311-J9E2X7"	
]

(* Shelling *)
Test[
	cuboid = OpenCascadeShape[Cuboid[]];
	OpenCascadeShapeNumberOfFaces[cuboid]
	,
	6
	,
	TestID->"OpenCascadeLink_Docs_ShapeProcessing-20200311-S6P1M7"
]

Test[
	shell = OpenCascadeShapeShelling[cuboid, 0.1, {2, 3}];
	bmeshShell = OpenCascadeShapeSurfaceMeshToBoundaryMesh[shell];
	groups = bmesh["BoundaryElementMarkerUnion"];
	temp = Most[Range[0, 1, 1/(Length[groups])]];
	colors = ColorData["BrightBands"][#] & /@ temp;
	checkGraphicsRendering[Head, bmeshShell["Wireframe"["MeshElementStyle" -> FaceForm /@ colors]]]
	,
	{Graphics3D, "Rendering Errors" ->{}}
	,
	TestID->"OpenCascadeLink_Docs_ShapeProcessing-20200311-G5I6Q9"
]

(* De-featuring *)
Test[
	b1 = Cuboid[{0, 0, 0}, {9, 4, 2}];
	b2 = Cuboid[{0, 0, 1}, {4, 1, 2}];
	b3 = Cuboid[{4, 0, 0}, {6, 2, 2}]; 
	shapes = OpenCascadeShape /@ {b1, b2, b3};
	shape = OpenCascadeShapeDifference @@ shapes;
	OpenCascadeShapeNumberOfFaces[shape]
	,
	12
	,
	TestID->"OpenCascadeLink_Docs_ShapeProcessing-20200311-J8S1M3"
]

Test[
	bmesh = OpenCascadeShapeSurfaceMeshToBoundaryMesh[shape];
	bmesh["BoundaryElementMarkerUnion"]
	,
	Range[12]
	,
	TestID->"OpenCascadeLink_Docs_ShapeProcessing-20200311-K7W9X8"
]

Test[
	defeatured = OpenCascadeShapeDefeaturing[shape, {11, 12}];
	bmeshDefeatured = OpenCascadeShapeSurfaceMeshToBoundaryMesh[defeatured];
	checkGraphicsRendering[Head, bmeshDefeatured["Wireframe"["MeshElementStyle" -> FaceForm[Orange]]]]
	,
	{Graphics3D, "Rendering Errors" ->{}}
	,
	TestID->"OpenCascadeLink_Docs_ShapeProcessing-20200311-K6P2S6"
]

(* Import/Export *)

(* STL *)

With[{fileName = FileNameJoin[{DirectoryName[$CurrentFile], "Data/test.stl"}]},
Test[
	shape = OpenCascadeShape[Ball[{1, 0, 0}]];
	OpenCascadeShapeExport[fileName, shape];
	If[FileExistsQ[fileName],
		bmesh = Import[fileName, "ElementMesh"];
		checkGraphicsRendering[Head, bmesh["Wireframe"]]
		,
		False]
	,
	{Graphics3D, "Rendering Errors" ->{}}
	,
	TestID->"OpenCascadeLink_Docs_ShapeProcessing-20200311-I8W6L2"
]]

TestExecute[
	DeleteFile[fileName];
]

With[{path = FileNameJoin[{DirectoryName[$CurrentFile], "Data/spikey.stl"}]},
Test[
	shape = OpenCascadeShapeImport[path];
	bmesh = OpenCascadeShapeSurfaceMeshToBoundaryMesh[shape];
	checkGraphicsRendering[Head, bmesh["Wireframe"]]
	,
	{Graphics3D, "Rendering Errors" ->{}}
	,
	TestID->"OpenCascadeLink_Docs_ShapeProcessing-20200311-X9Z5D8"
]]

(* STEP *)

With[{fileName = FileNameJoin[{DirectoryName[$CurrentFile], "Data/test.stp"}]},
Test[
	shape = OpenCascadeShape[Cone[{{0, 0, 0}, {0, 0, 1}}, 1]];
	OpenCascadeShapeExport[fileName, shape];
	If[FileExistsQ[fileName],
		shape = OpenCascadeShapeImport[fileName];
		bmesh = OpenCascadeShapeSurfaceMeshToBoundaryMesh[shape];
		checkGraphicsRendering[Head, bmesh["Wireframe"]]
		,
		False]
	,
	{Graphics3D, "Rendering Errors" ->{}}
	,
	TestID->"OpenCascadeLink_Docs_ShapeProcessing-20200311-I4H4N4"
]]

With[{path = FileNameJoin[{DirectoryName[$CurrentFile], "Data/screw.step"}]},
Test[
	shape = OpenCascadeShapeImport[path];
	bmesh = OpenCascadeShapeSurfaceMeshToBoundaryMesh[shape];
	checkGraphicsRendering[Head, bmesh["Wireframe"]]
	,
	{Graphics3D, "Rendering Errors" ->{}}
	,
	TestID->"OpenCascadeLink_Docs_ShapeProcessing-20200311-V8O1O7"
]]


TestExecute[
	DeleteFile[fileName];
]

(* BRep *)

With[{fileName = FileNameJoin[{DirectoryName[$CurrentFile], "Data/test.brep"}]},
Test[
	shape = OpenCascadeShape[Cone[{{0, 0, 0}, {0, 0, 1}}, 1]];
	OpenCascadeShapeExport[fileName, shape];
	If[FileExistsQ[fileName],
		shape = OpenCascadeShapeImport[fileName];
		bmesh = OpenCascadeShapeSurfaceMeshToBoundaryMesh[shape];
		checkGraphicsRendering[Head, bmesh["Wireframe"]]
		,
		False]
	,
	{Graphics3D, "Rendering Errors" ->{}}
	,
	TestID->"OpenCascadeLink_Docs_ShapeProcessing-20200311-P4I1W0"
]]

With[{path = FileNameJoin[{DirectoryName[$CurrentFile], "Data/Bottom.brep"}]},
Test[
	shape = OpenCascadeShapeImport[path];
	bmesh = OpenCascadeShapeSurfaceMeshToBoundaryMesh[shape];
	checkGraphicsRendering[Head, bmesh["Wireframe"]]
	,
	{Graphics3D, "Rendering Errors" ->{}}
	,
	TestID->"OpenCascadeLink_Docs_ShapeProcessing-20200311-U1I7U8"
]]


TestExecute[
	DeleteFile[fileName];
]

CleaAll["Global`*"];