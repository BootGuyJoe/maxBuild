/*
 * maxBuild v2
 * Main Behaviors File
 *
 * Created by Joey "Boot Guy Joe" Hanley on 7/20/2013
 *
 */

-- ========
-- INCLUDES
-- ========

include "mb-globals.ms"
include "mb-gui.ms"

-- ========
-- COMMANDS
-- ========

fn MyCallbackFn msg ir obj faceNum shift ctrl alt =
( 
myStr = "Pos ("+mouse.pos.x as string +", "+ mouse.pos.y as string + ")"

case msg of
(
#freeMove: myStr += " [freeMove]"
#mousePoint: myStr += " [left click]"
#mouseMove: myStr += " [left drag]"
#mouseAbout: myStr += " [righ click]"
)

print myStr
#continue 
)


-- SECTOR CREATION
macroScript drawSector
category:" MyTools" 
toolTip:"Draw Sector"
buttonText:"Draw Sector" 
/* Functional code starts here: */ (
	tool drawSector
	(
		
		-- --------------------------
		-- INITIALIZE LOCAL VARIABLES
		-- --------------------------
		
		local faceArray = #() -- temporary array stores the last four verticies created 
		local startPoint, v1, v2
		
		-- ----------------------
		-- DEFINE LOCAL FUNCTIONS
		-- ----------------------
		
		fn createPoint =
		(
			local x = gridPoint.x
			local y = gridPoint.y
			local z = gridPoint.z
			
			for i = 1 to 2 do 
			(
				polyOp.createVert $ [x,y,z] -- creates vert
				if faceArray.count == 4 do (deleteItem faceArray 1) -- checks if the face array is full
				append faceArray (polyOp.getNumVerts $) -- enters the new vert count into the face array
				z = z + 256 -- increases z height for second vert
			)
			updateVisa()
		)
			
		fn createWall =
		(
			polyOp.createPolygon $ #(faceArray[1],faceArray[3],faceArray[4],faceArray[2])
			append walls #(faceArray[1],faceArray[3],faceArray[4],faceArray[2])
		)
		
		-- --------------
		-- MOUSE BEHAVIOR
		-- --------------
		
		on start do
		(
			if $ == undefined then
			(
				ep = editable_mesh name:(uniquename"sector_") -- create an empty mesh
				convertTo ep Editable_Poly -- convert to Editable_Poly
				select ep
				append sectors (ep)
			)
			subobjectlevel = 1
			updateVisa()
		)
		
		on mousePoint clickno do
		(	
			case of 
			(
				(clickno == 1): 
				(
					startPoint = gridPoint -- record the start point in order to close the loop
					print "Sector drawing started!"
					createPoint()
					-- record the first two vertices for future reference
					v1 = faceArray[1]
					v2 = faceArray[2]
					createPoint()
					createWall()
				) -- create the first vertex column, take note of its position, and ready the next wall
				(clickno >= 3):
				(
					if gridPoint == startPoint then 
					(
						polyOp.deleteVerts $ #(faceArray[4],faceArray[3])
						faceArray = #(faceArray[1],faceArray[2],faceArray[3]-2,faceArray[4]-2)
						$.createFace #(faceArray[4],faceArray[3],v1,v2)
						polyOp.capHolesByVert $ faceArray
						format "Created new sector: %\n" $.name
						updateVisa()
						#stop					
					) -- close the wall loop, print vital information, and exit the tool
					else
					(
						-- detatch the last created wall
						-- uvmap it with a the default planar mapping size
						-- weld the verticies back up and keep going
						createPoint()
						createWall()
					) -- keep making new walls
				) -- either close the loop or keep making new walls
			) -- end case; new sector created			
		)
		
		on mouseMove clickno do 
		(			
			if faceArray.count != 2 then
			(
				for i = 3 to 4 do 
				(	
					polyop.setvert $ faceArray[i] [gridPoint.x,gridPoint.y,visa[faceArray[i]].z]
					updateVisa()
				)
				
			)
		)
	) -- end tool
	startTool drawSector
) -- end drawNewRoom macroScript




