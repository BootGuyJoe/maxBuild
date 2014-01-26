-- =============================================
-- maxBUILD v0.2 by JOSEPH "BOOT GUY JOE" HANLEY
-- =============================================

/* 
Welcome to maxBUILD! This modification to Autodesk 3ds MAX was designed by
a retro level designer, for modern level designers. If you've ever used BUILD (now known as 
MAPSTER 32) for Duke Nukem 3D, you'll find yourself right at home!
*/

-- ===========================
-- INITIALIZE GLOBAL VARIABLES
-- ===========================

global assetBrwsr
global assetBrwsrOpen
global isoMode
global isoModeOn
global hiZ -- stores the highest vertical vertex position 
global loZ -- stores the lowest vertical vertex position
global sectors = #() -- stores the number of elements (reffered to as sectors) in the scene
global walls = #() -- stores all of the walls (faces) in the scene
global visa = #() -- stores the x,y, and z positions of every single vertex

-- =======================
-- DEFINE GLOBAL FUNCTIONS
-- =======================

fn updateSector = (
	local vArray = #() -- temporary array stores the position of every vertex within the sector
	sectors = #() -- empties the sectors array to start from scartch
	
	for i = 1 to (polyOp.getNumVerts $) do (
		append vArray ($.GetVertex i)
	) -- record the position of every vertex within the sector
	
	append sectors (vArray)
	format "Sectors = %\n" sectors
) -- end function; sector multi-dimensional array updated

fn updateVisa = (
	visa = #() -- erase all data from the v.i.s.a.
	hiZ = undefined
	loZ = undefined

	for i = 1 to (polyOp.getNumVerts $) do (
		-- record each vertex position in the visa array
		append visa ($.GetVertex i)
		
		-- record the highest & lowest vertex position on the grid
		if hiZ == undefined or loZ == undefined then (
			hiZ = visa[1].z
			loZ = visa[1].z
		)
		else (
			if visa[i].z >= hiZ then (hiZ = visa[i].z)
			--print hiZ
			if visa[i].z <= loZ then (loZ = visa[i].z)
			--print loZ
		)
	)
	--format "hiZ: %\n" hiZ
	--format "loZ: %\n" loZ
	--print visa
) -- end function; vertex array updated

fn selectVerts posX:unsupplied posY:unsupplied appendToArray:unsupplied = (
	local current_z = hiZ
	local final_z = loz
	local vertsFound = #{}
	local result, mpos
	
	if posX == unsupplied or posY == unsupplied then (
		print "Click a position on the grid..."
		mpos = pickPoint snap:#2D
		posX = mpos.x
		posY = mpos.y
	)

	if appendToArray == unsupplied then (appendToArray = vertsFound)
	
	while current_z >= final_z do (
		result = findItem visa [posX,posY,current_z]
		if result != 0 then (append appendToArray result)
		current_z -= 2
	)
	
	subobjectlevel = 1
	$.setSelection #vertex appendToArray
	return appendToArray
) -- end function; verticies selected (internal use only)

-- ============
-- VIEW OPTIONS
-- ============

-- CYCLE VIEWS
macroScript cycleView
category:" MyTools" 
toolTip:"Cycle View"
buttonText:"Cycle View"
( -- start cycleView macroScript
	local v = viewport.getType()
	
	if v == #view_top then
	(
		viewport.setType #view_persp_user
		viewport.SetFOV 90
		macros.run "Views" "WalkThroughToggle"
	)
	else
	(
		viewport.setType #view_top
		macros.run " MyTools" "maxBuildSelect"
	)
	completeRedraw()
) -- end cycleView macroScript

-- CYCLE GRID SPACING
macroScript cycleGrid
category:" MyTools" 
toolTip:"Cycle Grid"
buttonText:"Cycle Grid"
( -- start cycleGrid macroScript
	local g = getGridSpacing() as integer
	case of
	(
		(g == 64): SetGridSpacing 32
		(g == 32): SetGridSpacing 16
		(g == 16): SetGridSpacing 8
		(g == 8): SetGridSpacing 4
		default: SetGridSpacing 64
	)
	completeRedraw()
	g = getGridSpacing() as integer
	format "Grid size: %\n" g
) -- end cycleGrid macroScript

-- ENTER/EXIT ISOLATION MODE
macroScript isolationMode
category:" MyTools" 
toolTip:"Isolation Mode"
buttonText:"Isolation Mode"
( -- start isolationMode macroScript
	local isoTarget = $
	
	if $ == undefined then
	(
		messagebox "Nothing selected! Cannot enter Isolation Mode." title: "I.M."
	)
	else
	(
		-- select base object to prevent errors
		subobjectLevel = 0
		max zoomext sel all	
		max select invert
		max hide selection
		completeRedraw()
		-- reselect your target object
		select isoTarget
		
		-- create a floater button to exit mode
		if isoModeOn != true then
		(
			isoModeOn = true
			
			Rollout im "Isolation Mode"
			(
				button btnButton "Exit Mode"
				
				on btnButton pressed do 
				(
					max unhide all
					closeRolloutFloater isoMode
					isoModeOn = false
				)
			)
			isoMode = newRolloutFloater "I.M." 150 64 32 50
			addRollout im isoMode
		)
		else
		(
			max unhide all
			closeRolloutFloater isoMode
			global isoModeOn = false
		)
	) -- end else statement
) -- end isolationMode macroScript

-- =============================
-- 2D VIEW GEOMETRY CONSTRUCTION
-- =============================

-- SECTOR CREATION
macroScript drawNewRoom
category:" MyTools" 
toolTip:"Draw New Sector"
buttonText:"Draw New Sector" 
/* Functional code starts here: */ (
	tool drawSector (
		
		-- --------------------------
		-- INITIALIZE LOCAL VARIABLES
		-- --------------------------
		
		local faceArray = #() -- temporary array stores the last four verticies created 
		local startPoint, v1, v2
		
		-- ----------------------
		-- DEFINE LOCAL FUNCTIONS
		-- ----------------------
		
		fn createPoint = (
			local x = gridPoint.x -- temporarily record the current gridPoints
			local y = gridPoint.y
			local z = gridPoint.z
			
			for i = 1 to 2 do (
				polyOp.createVert $ [x,y,z]
				if faceArray.count == 4 do (deleteItem faceArray 1)
				append faceArray (polyOp.getNumVerts $)
				z = z + 256
			)
			updateVisa()
		) -- end function; vertex column created
		
		fn createWall = (
			polyOp.createPolygon $ #(faceArray[1],faceArray[3],faceArray[4],faceArray[2])
			append walls #(faceArray[1],faceArray[3],faceArray[4],faceArray[2])
		) -- end function; faces drawn between previously created vertex columns
		
		-- --------------
		-- MOUSE BEHAVIOR
		-- --------------
		
		on start do (
			updateVisa()
			subobjectlevel = 1
		)
		
		on mousePoint clickno do (	
			case of (
				(clickno == 1): (
					startPoint = gridPoint
					print "Sector drawing started!"
					createPoint()
					-- record the first two vertices for future reference
					v1 = faceArray[1]
					v2 = faceArray[2]
					createPoint()
					createWall()
				) -- create the first vertex column, take note of its position, and ready the next wall
				(clickno >= 3): (
					if gridPoint == startPoint then (
						polyOp.deleteVerts $ #(faceArray[4],faceArray[3])
						faceArray = #(faceArray[1],faceArray[2],faceArray[3]-2,faceArray[4]-2)
						$.createFace #(faceArray[4],faceArray[3],v1,v2)
						polyOp.capHolesByVert $ faceArray
						format "Created new sector: %\n" $.name
						updateVisa()
						#stop
					) -- close the wall loop, print vital information, and exit the tool
					else 
						createPoint()
						createWall()
					) -- keep making new walls
				) -- either close the loop or keep making new walls
			) -- end case; new sector created			
		)
		
		on mouseMove clickno do (			
			if faceArray.count != 2 then (
				for i = 3 to 4 do (	
					polyop.setvert $ faceArray[i] [gridPoint.x,gridPoint.y,visa[faceArray[i]].z]
					updateVisa()
				)
			)
		)
	) -- end tool
	startTool drawSector
) -- end drawNewRoom macroScript

-- SUB-OBJECT AUTO-SELECTION ON MOUSE HOVER
macroScript maxBuildSelect
category:" MyTools" 
toolTip:"maxBuild Select"
buttonText:"maxBuild Select"
( -- start maxBuildSelect macroScript
	tool aSel
	(
		local sel = #{}
		local startPoint
		
		on start do
		(
			if $ == undefined then
			(
				select $worldSpawn
			)
			updateVisa()
		)
		
		on freeMove do
		(			
			if (findItem visa [gridPoint.x,gridPoint.y,loZ]) != 0 then
			(
				selectVerts posX:gridPoint.x posY:gridPoint.y appendToArray:sel
				format "Selection: %\n" sel
			)
			else
			(
				sel = #{}
				$.setSelection #vertex sel
				--format "Selection: %\n" (polyOp.getVertSelection $)
			)
		)
		
		on mousePoint clickno do
		(
			polyOp.weldVertsByThreshold $ #all
			updateVisa()
		)
		
		on mouseMove clickno do
		(
			local s = sel as array
			
			if s.count != 0 and lbutton then
			(
				for i = 1 to s.count do
				(	
					polyOp.setVert $ s[i] [gridPoint.x, gridPoint.y, visa[s[i]].z]
				)
			)
			else
			(
				if (findItem visa [gridPoint.x,gridPoint.y,loZ]) != 0 then
				(
					selectVerts posX:gridPoint.x posY:gridPoint.y appendToArray:sel
					--format "Selection: %\n" sel
				)
				else
				(
					sel = #{}
					$.setSelection #vertex sel
					--format "Selection: %\n" (polyOp.getVertSelection $)
				)
			)
		)
		
		on mouseAbort clickno do
		(
			updateVisa()
		)
		
		on end do
		(
			updateVisa()
		)
	)
	startTool aSel
) -- end maxBuildSelect macroScript

-- ADD A NEW VERTEX TO THE WALL
macroScript addNewVertex
category:" MyTools"
toolTip:"Add New Vertex"
buttonText:"Add New Vertex"
(	
	local startPoint = pickPoint snap:#2D
	
	$.divideEdge (($.getSelection #Edge as array)[1]) 0.5 select:off
 	polyOp.setVert $ (visa.count + 1) [startPoint.x, startPoint.y, hiZ]
 	subobjectlevel = 1
	updateVisa()
	
)
 
-- ADD TWO NEW VERTICES TO THE WALL
macroScript addTwoVertex
category:" MyTools"
toolTip:"Add Two Vertex"
buttonText:"Add Two Vertex"
(
	-- select the edge and ring it
	$.SelectEdgeRing ()
	-- connect the edges
	$.connectEdgeSegments = 2
	$.ConnectEdges ()
	autosmooth()
	-- switch to vertex sub-object mode
	subobjectLevel = 1
)

-- CHAMFER VERTEX
macroScript chamferVertex
category:" MyTools"
toolTip:"Chamfer Vertex"
buttonText:"Chamfer Vertex"
(
	-- first covert selection to connecting edges
	$.ConvertSelection #Vertex #Edge
	subobjectLevel = 2
	-- the shrink so we only get one edge
	$.ShrinkSelection ()
	-- then chamfer the edge by 128 generic units
	$.edgeChamfer = 128
	$.buttonOp #Chamfer
	autosmooth()
	subobjectLevel = 1
)

-- ===========================
-- 3D VIEW GEOMETRY ALTERATION
-- ===========================

-- RAISE THE SELECTED OBJECT BY 8 GENERIC GRID UNITS
macroScript raisePlane8
category:" MyTools"
toolTip:"Raise Plane 8"
buttonText:"Raise Plane 8"
(
	if subobjectLevel == 2 then
	(
		move $.selectedEdges [0,0,32]
	)
	else
	(
		$.ConvertSelection #Face #Vertex
		subobjectLevel = 1
		move $.selectedVerts [0,0,32]
	)
	updateVisa()
)

-- RAISE THE SELECTED FACE BY 32 GENERIC GRID UNITS
macroScript raisePlane32
category:" MyTools"
toolTip:"Raise Plane 32"
buttonText:"Raise Plane 32"
(
	if subobjectLevel == 2 then
	(
		move $.selectedEdges [0,0,32]
	)
	else
	(
		$.ConvertSelection #Face #Vertex
		subobjectLevel = 1
		move $.selectedVerts [0,0,32]
	)
	updateVisa()
) -- end raiseBy32 script

-- LOWER THE SELECTED FACE BY 8 GENERIC GRID UNITS
macroScript lowerPlane8
category:" MyTools"
toolTip:"Lower Plane 8"
buttonText:"Lower Plane 8"
(
	local sub = subobjectLevel
	local sel = $.getSelection
	local num = #{1..9999}

	if sub == 4 then
	(
		if (sel #face != num ) then
		(
			move $.selectedFaces [0,0,-8]
		)
		else
		(
			move $ [0,0,-8]
			print "No faces swelected. Moving entire object."
		)
	)
	else if sub == 2 then
	(
		if (sel #edge != num) then
		(
			move $.selectedEdges [0,0,-8]
		)
		else
		(
			move $ [0,0,8]
			print "No edges selected. Moving entire object."
		)
	)
	else if sub == 1 then
	(
		if (sel #vertex != num ) then
		(
			move $.selectedVerts [0,0,-8]
		)
		else
		(
			move $ [0,0,-8]
			print "No vertices selected. Moving entire object."
		)
	)
	else
	(
		move $ [0,0,-8]
	)
	updateVisa()
)

-- LOWER THE SELECTED FACE BY 32 GENERIC GRID UNITS
macroScript lowerPlane32
category:" MyTools"
toolTip:"Lower Plane 32"
buttonText:"Lower Plane 32"
(
	if subobjectLevel == 2 then
	(
		move $.selectedEdges [0,0,-32]
	)
	else
	(
		$.ConvertSelection #Face #Vertex
		subobjectLevel = 1
		move $.selectedVerts [0,0,-32]
	)
	updateVisa()
) -- end lowerBy32

-- ==================
-- TEXTURING CONTROLS
-- ==================

-- BREAK FACE AND APPLY UVW BOX MAP
-- (
-- 	$.detachToElement #Face keepOriginal:off
-- 	macros.run "Modifiers" "Uvwmap"
-- 	$.modifiers[#UVW_Mapping].maptype = 4
-- 	$.modifiers[#UVW_Mapping].length = 512
-- 	$.modifiers[#UVW_Mapping].width = 512
-- 	$.modifiers[#UVW_Mapping].height = 512

-- 	macros.run "Modifier Stack" "Convert_to_Poly"
-- 	subobjectLevel = 1
-- 	max select all
-- 	$.weldFlaggedVertices ()
-- 	max select none
-- 	subobjectLevel = 4
-- )

-- =============
-- ASSET BROWSER
-- =============

macroScript applyTexture
category:" MyTools"
toolTip:"Apply Texture"
buttonText:"Apply Texture"
(	
	if assetBrwsrOpen != true then
	(
		-- set a global variable so we know when the window is open
		global assetBrwsrOpen = true
		Rollout ab "Max-Made Prefabs"
		(
			GroupBox currentObj "Selected Object"
				pos: [8,8]
				width: 248
				height: 248
			button btnButton "Generate Prefab" 
				pos: [12,200] 
				width: 240 
				height: 30
				toolTip: "Stores the selected object as a prefabrication which allows for quick duplication."
			label lab1 "Note: Prefabs are instances of the original object" 
				pos: [16,235]
			
			on btnButton pressed do 
			(
				
			)
		)
		
		assetBrwsr = newRolloutFloater "maxBUILD Content Browser" (sysinfo.desktopsize.x/100 * 20) (sysinfo.desktopsize.y/100 * 40)
		addRollout ab assetBrwsr
	)
	else
	(
		closeRolloutFloater assetBrwsr
		global assetBrwsrOpen = false
	)
)

