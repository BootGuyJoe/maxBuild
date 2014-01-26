/*
 * maxBuild v2
 * Global Functions
 *
 * Created by Joey "Boot Guy Joe" Hanley on 7/20/2013
 *
 */

-- ============
-- DECLARATIONS
-- ============

global sectors = #() -- stores the number of elements (reffered to as sectors) in the scene
global walls = #() -- stores all of the walls (faces) in the scene
global visa = #() -- stores the x,y, and z positions of every single vertex
global hiZ -- stores the highest vertical vertex position 
global loZ -- stores the lowest vertical vertex position

-- ========
-- COMMANDS
-- ========

fn resetGlobals =
(
	sectors = #()
	format "sectors = %\n" sectors
	walls = #()
	format "walls = %\n" walls
	visa = #()
	format "visa = %\n" visa
	hiZ = undefined
	format "hiZ = %\n" hiZ
	loZ = undefined
	format "lowZ = %\n" loZ
)

fn updateSector sectorID: unsupplied =
(
	
)

fn updateVisa = 
(
	visa = #() -- erase all data from the v.i.s.a.
	hiZ = undefined
	loZ = undefined

	for i = 1 to (polyOp.getNumVerts $) do 
	(
		-- record each vertex position in the visa array
		append visa ($.GetVertex i)
		
		-- record the highest & lowest vertex position on the grid
		if hiZ == undefined or loZ == undefined then 
		(
			hiZ = visa[1].z
			loZ = visa[1].z
		)
		else 
		(
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

fn selectVerts posX:unsupplied posY:unsupplied appendToArray:unsupplied = 
(
	local current_z = hiZ
	local final_z = loz
	local vertsFound = #{}
	local result, mpos
	
	if posX == unsupplied or posY == unsupplied then
	(
		print "Click a position on the grid..."
		mpos = pickPoint snap:#2D
		posX = mpos.x
		posY = mpos.y
	)

	if appendToArray == unsupplied then (appendToArray = vertsFound)
	
	while current_z >= final_z do
	(
		result = findItem visa [posX,posY,current_z]
		if result != 0 then (append appendToArray result)
		current_z -= 2
	)
	
	subobjectlevel = 1
	$.setSelection #vertex appendToArray
	return appendToArray
) -- end function; verticies selected (internal use only)

fn applyTex  matID: unsupplied =
(
	if matID == unsupplied do ($.material = meditMaterials[1])
	polyop.getFaceSelection $ -- replace with current face selection
	print result
	$.EditablePoly.detachToElement #Face keepOriginal:off
	modPanel.addModToSelection (Uvwmap ()) ui:off
		$.modifiers[#UVW_Mapping].axis = 1 -- gonna need to test the axis here
		$.modifiers[#UVW_Mapping].utile = 1
		$.modifiers[#UVW_Mapping].vtile = 1
		$.modifiers[#UVW_Mapping].wtile = 1
		$.modifiers[#UVW_Mapping].length = 256
		$.modifiers[#UVW_Mapping].width = 256
		$.modifiers[#UVW_Mapping].height = 256
	maxOps.CollapseNodeTo $ 1 off
	subobjectlevel = 4
)