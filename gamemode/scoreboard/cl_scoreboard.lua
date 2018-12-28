include( "cl_playerRow.lua" )
include( "cl_playerFrame.lua" )

//surface.CreateFont( "Impact", 32, 500, true, false, "ScoreboardHeader" )
//surface.CreateFont( "Default", 20, 700, true, false, "ScoreboardSubtitle" )

surface.CreateFont( "ScoreboardHeader", {
	font = "Impact",
	extended = false,
	size = 32,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

surface.CreateFont( "ScoreboardSubtitle", {
	font = "Default",
	extended = false,
	size = 20,
	weight = 700,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )


local texLogo     = surface.GetTextureID( "darkland/fortwars/darklandlogo" )
local texGradient = surface.GetTextureID( "gui/center_gradient" )

local PANEL = {}

/*---------------------------------------------------------
   Name: Paint
---------------------------------------------------------*/
function PANEL:Init()
  SCOREBOARD = self

  self.Hostname = vgui.Create( "DLabel", self )
  self.Hostname:SetText( GetHostName() )
  
  self.Description = vgui.Create( "DLabel", self )
 // self.Description:SetExpensiveShadow( true )
  self.Description:SetText( "FortWars 13 - "..game.GetMap() )
  
  self.PlayerFrame = vgui.Create( "PlayerFrame", self )
  self.PlayerRows = {}
  self:UpdateScoreboard()
  
  // Update the scoreboard every 1 second
  timer.Create( "ScoreboardUpdater", .25, 0, self.UpdateScoreboard, self )
  //timer.Create( "ScoreboardUpdater", 1, 0, function() self.UpdateScoreboard end )
  
  self.lblKills = vgui.Create( "DLabel", self )
  self.lblKills:SetText( "Kills" )
  self.lblKills:SizeToContents()
  self.lblAssists = vgui.Create( "DLabel", self )
  self.lblAssists:SetText( "Assists" ) 
  self.lblAssists:SizeToContents()  
  self.lblDeaths = vgui.Create( "DLabel", self )
  self.lblDeaths:SetText( "Deaths" )
  self.lblDeaths:SizeToContents()  
  self.lblPing = vgui.Create( "DLabel", self )
  self.lblPing:SetText( "Ping" )  
  self.lblPing:SizeToContents()  
end

/*---------------------------------------------------------
   Name: Paint
---------------------------------------------------------*/
function PANEL:AddPlayerRow( ply )
  local button = vgui.Create( "ScorePlayerRow", self.PlayerFrame:GetCanvas() )
  button:SetPlayer( ply )
  self.PlayerRows[ ply ] = button
end

/*---------------------------------------------------------
   Name: Paint
---------------------------------------------------------*/
function PANEL:GetPlayerRow( ply )
  return self.PlayerRows[ ply ]
end

/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:PerformLayout()
  self.Hostname:SizeToContents()
  self.Hostname:SetPos( self:GetWide()/3.2, 16 )
  
  self.Description:SizeToContents()
  self.Description:SetPos( self:GetWide()/2.7, 64 )
  
  local iTall = self.PlayerFrame:GetCanvas():GetTall() + self.Description.y + self.Description:GetTall() + 30
  iTall = math.Clamp( iTall, 100, ScrH() * 0.9 )
  local iWide = math.Clamp( ScrW() * 0.5, 650, 850 )
  
  self:SetSize( iWide, iTall )
  self:SetPos( ( ScrW() - self:GetWide() ) / 2, ( ScrH() - self:GetTall() ) / 4 )
  
  self.PlayerFrame:SetPos( 5, self.Description.y + self.Description:GetTall() + 20 )
  self.PlayerFrame:SetSize( self:GetWide() - 10, self:GetTall() - self.PlayerFrame.y - 10 )
  
  local y = 0
  local PlayerSorted = {}
  local tblLength = 0
  for k, v in pairs( self.PlayerRows ) do
    tblLength = tblLength + 1
    PlayerSorted[tblLength] = v
  end
  
  local playerSort = function( a, b ) -- This is 10x faster than inlining 
    return a:HigherOrLower( b )
  end
  table.sort( PlayerSorted, playerSort )
  
  for k = 1, tblLength do
    local v = PlayerSorted[k]
    v:SetPos( 0, y )  
    v:SetSize( self.PlayerFrame:GetWide(), v:GetTall() )
    self.PlayerFrame:GetCanvas():SetSize( self.PlayerFrame:GetCanvas():GetWide(), y + v:GetTall() )
    y = y + v:GetTall() + 1
  end
  
  self.Hostname:SetText( GetHostName() )
  
  self.lblKills:SetPos( self:GetWide() - 50*4 - self.lblKills:GetWide()/2, self.PlayerFrame.y - self.lblPing:GetTall() - 3  )
  
  self.lblAssists:SetPos( self:GetWide() - 50*3 - self.lblKills:GetWide()/2, self.PlayerFrame.y - self.lblPing:GetTall() - 3  )
  
  self.lblDeaths:SetPos( self:GetWide() - 50*2 - self.lblDeaths:GetWide()/2, self.PlayerFrame.y - self.lblPing:GetTall() - 3  )
  
  self.lblPing:SetPos( self:GetWide() - 50 - self.lblPing:GetWide()/2, self.PlayerFrame.y - self.lblPing:GetTall() - 3  )
end

/*---------------------------------------------------------
   Name: ApplySchemeSettings
---------------------------------------------------------*/
function PANEL:ApplySchemeSettings()

  self.Hostname:SetFont( "ScoreboardHeader" )
  self.Description:SetFont( "ScoreboardSubtitle" )
  
  self.Hostname:SetFGColor(  Color( 180, 180, 180, 255 ))
  self.Description:SetFGColor( color_white )
  
  self.lblKills:SetFGColor(  Color( 180, 180, 180, 100 ))
  self.lblAssists:SetFGColor(  Color( 180, 180, 180, 100 ))
  self.lblDeaths:SetFGColor( Color( 180, 180, 180, 100 ))
  self.lblPing:SetFGColor(  Color( 180, 180, 180, 100 ))
end

function PANEL:UpdateScoreboard()

  if not SCOREBOARD:IsVisible() then return end
  //if not self then return end

  for k, v in pairs( SCOREBOARD.PlayerRows ) do
    if not k:IsValid() then
      v:Remove()
      SCOREBOARD.PlayerRows[ k ] = nil
    end
  end
  
  local PlayerList = player.GetAll()

  for k = 1, #PlayerList do
    local ply = PlayerList[k]
    if not SCOREBOARD:GetPlayerRow( ply ) then
      SCOREBOARD:AddPlayerRow( ply )
    end
  end
  SCOREBOARD:InvalidateLayout()
end

function PANEL:Paint()
  if not vgui.CursorVisible() then
    gui.EnableScreenClicker( true ) -- make sure cursor stays visible
  end
  -- Main box
  draw.RoundedBox( 4, 0, 0, self:GetWide(), self:GetTall(), Color( 10, 10, 10, 235 ))
  -- Inner Grey Box
  draw.RoundedBox( 4, 4, self.Description.y - 4, self:GetWide() - 8, self:GetTall() - self.Description.y - 4, Color( 60, 60, 60, 200 ))
  -- Sub Header
  draw.RoundedBox( 4, 5, self.Description.y - 3, self:GetWide() - 10, self.Description:GetTall() + 5, Color( 54, 122, 56, 200 ))
  //surface.SetTexture( texGradient )
  surface.SetDrawColor( 255, 255, 255, 30 )
 // surface.DrawTexturedRect( 5, self.Description.y - 3, self:GetWide() - 10, self.Description:GetTall() + 5 )   
  
  -- Logo
//  surface.SetTexture( texLogo )
 // surface.SetDrawColor( 255, 255, 255, 255 )
 // surface.DrawTexturedRect( 10, 10, 64, 64 )
  
  return true
end
vgui.Register( "ScoreBoard", PANEL, "DPanel" )