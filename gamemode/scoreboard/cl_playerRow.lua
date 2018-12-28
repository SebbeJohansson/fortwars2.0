include( "cl_playerInfocard.lua" )

//surface.CreateFont( "Defult", 13, 700, true, false, "ScoreboardPlyInfo" )
//surface.CreateFont( "Defult", 16, 700, true, false, "ScoreboardPlyName" )

local texGradient = surface.GetTextureID( "gui/center_gradient" )
local ROW_HEIGHT = 20

local PANEL = {}

/*---------------------------------------------------------
   Name: Init
---------------------------------------------------------*/
function PANEL:Init()
  self.texRating = Material( "icon16/user.png" )
  self.Size = ROW_HEIGHT
  self:OpenInfo( false )
  
  self.infoCard  = vgui.Create( "ScorePlayerInfoCard", self )
  
  self.lblName    = vgui.Create( "DLabel", self )
  self.lblFrags   = vgui.Create( "DLabel", self )
  self.lblAssists = vgui.Create( "DLabel", self )
  self.lblDeaths  = vgui.Create( "DLabel", self )
  self.lblPing    = vgui.Create( "DLabel", self )
  
  -- If you don't do this it'll block your clicks
  self.lblName:SetMouseInputEnabled( false )
  self.lblFrags:SetMouseInputEnabled( false )
  self.lblAssists:SetMouseInputEnabled( false )
  self.lblDeaths:SetMouseInputEnabled( false )
  self.lblPing:SetMouseInputEnabled( false )
  
  self:SetCursor( "hand" )
end

/*---------------------------------------------------------
   Name: Paint
---------------------------------------------------------*/
function PANEL:Paint()
  if not IsValid( self.Player ) then return end
  
  local color = team.GetColor( self.Player:Team() )
  
  if self.Player:Team() == TEAM_CONNECTING then
    color = Color( 200, 120, 50, 255 )
  end
  
  if self.Open or self.Size ~= self.TargetSize then
    draw.RoundedBox( 4, 0, 16, self:GetWide(), self:GetTall() - 16, color )
    draw.RoundedBox( 4, 2, 16, self:GetWide() - 4, self:GetTall() - 16 - 2, Color( 250, 250, 245, 180 ))
    surface.SetTexture( texGradient )
    surface.SetDrawColor( 255, 255, 255, 220 )
    surface.DrawTexturedRect( 2, 16, self:GetWide() - 4, self:GetTall() - 16 - 2 ) 
  end
  
  draw.RoundedBox( 4, 0, 0, self:GetWide(), ROW_HEIGHT, color )
  
  surface.SetTexture( texGradient )
  if self.Player == LocalPlayer() then
    surface.SetDrawColor( 255, 255, 255, 150 + math.sin( RealTime() * 2 ) * 50 )
  else
    surface.SetDrawColor( 255, 255, 255, 50 )
  end
  surface.DrawTexturedRect( 0, 0, self:GetWide(), ROW_HEIGHT ) 
    
  if self.Player:GetFriendStatus() == "friend" then
		surface.SetMaterial( self.texRating )

      //self.SetIcon( self.texRating )
	  
      surface.SetDrawColor( 255, 255, 255, 255 )
      surface.DrawTexturedRect( 2, ROW_HEIGHT / 2 - 8, 16, 16 )     
  end
  
  return true
end

/*---------------------------------------------------------
   Name: UpdatePlayerData
---------------------------------------------------------*/
function PANEL:SetPlayer( ply )
  self.Player = ply
  self.infoCard:SetPlayer( ply )
  self:UpdatePlayerData()
end

/*---------------------------------------------------------
   Name: UpdatePlayerData
---------------------------------------------------------*/
function PANEL:UpdatePlayerData()
  if not self.Player then return end
  if not self.Player:IsValid() then return end

  if self.Player:GetNWString("ADMDisguise") != "" then
	self.lblName:SetText( self.Player:GetNWString("ADMDisguise") )
  else
    self.lblName:SetText( self.Player:Nick() )
  end
  
  self.lblFrags:SetText( self.Player:Frags() )
  self.lblAssists:SetText( self.Player:GetNWInt( "Assists" ))  
  self.lblDeaths:SetText( self.Player:Deaths() )
  self.lblPing:SetText( self.Player:Ping() )
end

/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:ApplySchemeSettings()
  self.lblName:SetFont( "Default" )
  self.lblFrags:SetFont( "Default" )
  self.lblAssists:SetFont( "Default" )
  self.lblDeaths:SetFont( "Default" )
  self.lblPing:SetFont( "Default" )
  
  self.lblName:SetTextColor( Color( 255, 255, 255, 255 ) )
  self.lblFrags:SetTextColor( Color( 255, 255, 255, 255 ) )
  self.lblAssists:SetTextColor( Color( 255, 255, 255, 255 ) )
  self.lblDeaths:SetTextColor( Color( 255, 255, 255, 255 ) )
  self.lblPing:SetTextColor( Color( 255, 255, 255, 255 ) )
end

/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:DoClick( x, y )
  if self.Open then
    surface.PlaySound( "ui/buttonclickrelease.wav" )
  else
    surface.PlaySound( "ui/buttonclick.wav" )
  end

  self:OpenInfo( not self.Open )
end

/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:OpenInfo( bool )
  if bool then
    self.TargetSize = 100
  else
    self.TargetSize = ROW_HEIGHT
  end
  
  self.Open = bool
end

/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:Think()
  if self.Size ~= self.TargetSize then
    self.Size = math.Approach( self.Size, self.TargetSize, ( math.abs( self.Size - self.TargetSize ) + 1 ) * 10 * FrameTime() )
    self:PerformLayout()
    SCOREBOARD:InvalidateLayout()
  //  self:GetParent():InvalidateLayout()
  end
  
  if not self.PlayerUpdate or self.PlayerUpdate < CurTime() then
    self.PlayerUpdate = CurTime() + 1
    self:UpdatePlayerData()
    self:InvalidateLayout()
  end
end

/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:PerformLayout()
  local halfRow = ROW_HEIGHT / 2
  self:SetSize( self:GetWide(), self.Size )
  
  self.lblName:SizeToContents()
  self.lblName:SetPos( 24, halfRow - self.lblName:GetTall() / 2 )
  
  local COLUMN_SIZE = 50
  self.lblFrags:SizeToContents()
  self.lblAssists:SizeToContents()
  self.lblDeaths:SizeToContents()
  self.lblPing:SizeToContents()
  
  self.lblFrags:SetPos( self:GetWide() - COLUMN_SIZE * 4, halfRow - self.lblFrags:GetTall() / 2 )  
  self.lblAssists:SetPos( self:GetWide() - COLUMN_SIZE * 3, halfRow - self.lblAssists:GetTall() /2 )
  self.lblDeaths:SetPos( self:GetWide() - COLUMN_SIZE * 2, halfRow - self.lblDeaths:GetTall() / 2 )
  self.lblPing:SetPos( self:GetWide() - COLUMN_SIZE * 1, halfRow - self.lblPing:GetTall() / 2 )
  
  if self.Open or self.Size ~= self.TargetSize then
    self.infoCard:SetVisible( true )
    self.infoCard:SetPos( 4, ROW_HEIGHT + 10 )
    self.infoCard:SetSize( self:GetWide() - 8, self:GetTall() - self.lblName:GetTall() - 10 )
  else
    self.infoCard:SetVisible( false )
  end
end

/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:HigherOrLower( row )
  if not self.Player:IsValid() or self.Player:Team() == TEAM_CONNECTING then return false end
  if not row.Player:IsValid() or row.Player:Team() == TEAM_CONNECTING then return true end
  
  if self.Player:Team() > row.Player:Team() then 
    return false
  elseif self.Player:Team() < row.Player:Team() then 
    return true
  else
    if self.Player:Frags() == row.Player:Frags() then
      return self.Player:Deaths() < row.Player:Deaths()
    else 
      return self.Player:Frags() > row.Player:Frags()
    end
  end
  return false 
end
vgui.Register( "ScorePlayerRow", PANEL, "Button" )