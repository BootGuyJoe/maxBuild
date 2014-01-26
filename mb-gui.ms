/*
 * maxBuild v2
 * Graphical User Interface Enhancments
 *
 * Created by Joey "Boot Guy Joe" Hanley on 7/20/2013
 *
 */

-- ========
-- COMMANDS
-- ========

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