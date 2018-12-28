include( "scoreboard/cl_scoreboard.lua" )

local pScoreBoard = nil
local ShowScoreboard = false
local mousePos = {ScrW() * 0.5, ScrH() * 0.5}

function GM:ScoreboardShow()
end

function GM:ScoreboardHide()
end


/*---------------------------------------------------------
   Name: CreateScoreboard()
   Desc: Creates/Recreates the scoreboard
-------------------------------------------------*/
function CreateScoreboard()
  if pScoreBoard then
    pScoreBoard:Remove()
    pScoreBoard = nil
  end
  if endGame then return end   
  pScoreBoard = vgui.Create( "ScoreBoard" )
end

/*---------------------------------------------------------
   Name: GM:ScoreboardShow()
   Desc: Sets the scoreboard to visible
-------------------------------------------------*/
hook.Add( "ScoreboardShow", "ScoreboardShow", function()

  if LocalPlayer():Team() == 0 then return end
  gui.EnableScreenClicker( true )
  if not pScoreBoard then
    CreateScoreboard()
  end
  ShowScoreboard = true
  pScoreBoard:SetVisible( true )
  gui.SetMousePos( unpack( mousePos ))
end )

/*---------------------------------------------------------
   Name: FW:ScoreboardHide()
   Desc: Hides the scoreboard
-------------------------------------------------*/
hook.Add( "ScoreboardHide", "ScoreboardHide", function()
  ShowScoreboard = false
  if pScoreBoard then
    mousePos = {gui.MouseX(), gui.MouseY()}
    pScoreBoard:SetVisible( false )
  end
 
   if ROUNDOVER == true then
		gui.EnableScreenClicker( true )
	else
		gui.EnableScreenClicker( false )
	end
end )

function GM:HUDDrawScoreBoard()
  return false
end

function GM:PostRenderVGUI()
  if not ShowScoreboard then return end
  if not pScoreBoard then
    CreateScoreboard()
  end  
  pScoreBoard:SetPaintedManually( false )
  pScoreBoard:PaintManual()
  pScoreBoard:SetPaintedManually( true )
end