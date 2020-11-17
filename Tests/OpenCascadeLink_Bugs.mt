(* Wolfram Language Test file *)

Needs["OpenCascadeLink`"];
Needs["NDSolve`FEM`"];

Test[
	shape = OpenCascadeShape[PolyhedronData["MathematicaPolyhedron", "Polyhedron"]];
	OpenCascadeShapeLinearSweep[shape, {{0, 0, 0}, {1, 1, 1}}]
	,
	$Failed
	,
	TestID->"OpenCascadeLink_Bugs-20200708-L0S5G8-bug-395241"
]

Test[
	shape = OpenCascadeShape[PolyhedronData["MathematicaPolyhedron", "Polyhedron"]];
	OpenCascadeShapeRotationalSweep[shape, {{0, 0, 0}, {1, 0, 0}}]
	,
	$Failed
	,
	TestID->"OpenCascadeLink_Bugs-20200708-W1B1T8-bug-395241"
]

TestMatch[
	regions = {Ellipsoid[{0, 0, 0}, {{5, 2, 3}, {2, 3, 2}, {3, 2, 5}}], 
				Ball[{1, 0, 0}]};
	Block[{out = {}}, 
 		Internal`HandlerBlock[{"Wolfram.System.Print", (out = {out, #}) &},
	{OpenCascadeShapeIntersection @@ OpenCascadeShape /@ regions, out}]]
	,
	{_OpenCascadeShapeExpression, {}}
	,
	TestID->"OpenCascadeLink_Bugs-20201116-M7T8X0-bug-401214"
]

Test[
	shape = OpenCascadeShapeImport[FileNameJoin[{DirectoryName[$CurrentFile], "Data/ClassicalMuffler.stl"}]];
	elementMesh = OpenCascadeShapeSurfaceMeshToBoundaryMesh[shape, 
 						"MarkerMethod" -> "ElementMesh"];
 	markers = AssociationMap[elementMesh[#]&, {"PointElementMarkerUnion", "BoundaryElementMarkerUnion",
 												"MeshElementMarkerUnion"}];
 	(* The choice of length is arbitrarily but should be small. *)
 	DeleteCases[markers, _?(Length[#] <= 25 &)]
 	,
 	<||>
	,
	TestID->"OpenCascadeLink_Bugs-20201117-A5R3Y2-bug-398536"
]

Test[
	(*shape = Get[FileNameJoin[{DirectoryName[$CurrentFile], "Data/ClassicalMuffler.stl"}]];*)
	elementMesh = OpenCascadeShapeSurfaceMeshToBoundaryMesh[shape, 
 						"MarkerMethod" -> None];
 	AssociationMap[elementMesh[#]&, {"PointElementMarkerUnion", "BoundaryElementMarkerUnion",
 									"MeshElementMarkerUnion"}]
 	,
 	<|"PointElementMarkerUnion" -> {0},
 	"BoundaryElementMarkerUnion" -> {0},
 	"MeshElementMarkerUnion" -> {0}|>
	,
	TestID->"OpenCascadeLink_Bugs-20201117-G4W2N0-bug-398536"
]

NTest[
	box1 = Cuboid[{-0.0325`, 0, -0.0135`}, {0.0325`, 0.033`, 0.0135`}];
	boxTransformed = TransformedRegion[box1, RotationTransform[10 \[Degree], {0, 1, 0}]];
	shape = OpenCascadeShape[boxTransformed];
	bmesh = OpenCascadeShapeSurfaceMeshToBoundaryMesh[shape];
	Sort[bmesh["Coordinates"]]
	,
	Sort[First /@ MeshPrimitives[boxTransformed, 0]]
	,
	PrecisionGoal -> 5
	,
	TestID->"OpenCascadeLink_Bugs-20201117-N9A1L2-bug-397202"
]

NTest[
	shape = OpenCascadeShape[Parallelepiped[{0.5, 0, 0}, {{0, 1, 0}, {0, 0, 1}}]];
	bmesh = OpenCascadeShapeSurfaceMeshToBoundaryMesh[shape];
	bmesh["Coordinates"]
	,
	{{0.5, 0., 0.}, {0.5, 1., 0.}, {0.5, 1., 1.}, {0.5, 0., 1.}}
	,
	TestID->"OpenCascadeLink_Bugs-20201117-H2R8O5-bug-399162"
]