local PANEL = {}

--[[  
- Initializes player infocard
-
- @author SW

--]]
function PANEL:Init()
  self.rowCol = {}
  
  self.InfoLabels = {}
  self.InfoLabels[1] = {}
  self.InfoLabels[2] = {}
  self.InfoLabels[3] = {}  
  
  self.imgAvatar = vgui.Create( "AvatarImage", self )
  self.classString = ""
  self.classUpdateCount = 2
end

--[[  
- Sets the players information
-
- @author SW
- @param column - column to set info in
- @param k - key
- @param v - value
--]]
function PANEL:SetInfo( column, k, v )
  if not self.rowCol[column] then
    self.rowCol[column] = 0
  end
  if not v or v == ""  then 
    v = "N/A" 
  end
  if not self.InfoLabels[column][k] then
    self.InfoLabels[column][k] = {}
    self.InfoLabels[column][k].Key   = vgui.Create( "DLabel", self )
    self.InfoLabels[column][k].Value   = vgui.Create( "DLabel", self )
    self.InfoLabels[column][k].Key:SetText( k )
    self.InfoLabels[column][k].Row = self.rowCol[column]
    self:InvalidateLayout()
  end
  
  self.InfoLabels[column][k].Value:SetText( v )
  self.rowCol[column]  = self.rowCol[column] + 1
end


--[[  
- Sets the infocard's owner to the specified player.
-
- @author SW
- @param ply - player to set infocard to
--]]
function PANEL:SetPlayer( ply )
  self.Player = ply
  self:UpdatePlayerData()
  
  
  timer.Simple(2, function()
  if self.Player:GetNWString("ADMDisguise") != "" then
	self.imgAvatar:SetSteamID("76561197974983106")
  else
    self.imgAvatar:SetPlayer( ply )
  end
	end)
end

--[[  
- Updates the player's data
-self.Player:GetTotalKills()
- @author SW
--]]
function PANEL:UpdatePlayerData()
  if not self.Player then return end
  if not self.Player:IsValid() then return end
  self:SetInfo( 1, "Kills:", self.Player:GetNWInt("mykills") )
  self:SetInfo( 1, "Assists:", self.Player:GetNWInt("myassists") )
  self:SetInfo( 1, "Ball Time:", self.Player:GetNWInt("myballtime") )
  self:SetInfo( 1, "Money:", ToMoney( self.Player:GetNWInt("mymoney") ))
  
  self:SetInfo( 2, "Wins:", self.Player:GetNWInt("mywins") )
  self:SetInfo( 2, "Losses:", self.Player:GetNWInt("mylosses") )
  //self:SetInfo( 2, "Props:", 1 )


  local status = "Regular"
  if self.Player:GetNWInt("mystatus")  == 3 then 
    status = "Platinum" 
  elseif self.Player:GetNWInt("mystatus")  == 2 then 
    status = "Premium" 
  end  
  self:SetInfo( 2, "Status:", status, self.Player:GetNWInt("mystatus") )
  self:SetInfo( 2, "Playtime:", self.Player:GetNWInt("mytime") )
  -- self:SetInfo( 2, "Class:", FW.ClassInfo[self.Player:GetCurrentClass()].NAME )
  
  -- self:UpdateClassString()
 // self:SetInfo( 3, "Classes:", 1 )
  self:InvalidateLayout()
end

--[[  
- Updates the player class string.
-
- Parses through class table and creates a
- string which lists the players classes, specials
- and word wraps.
-
- @author SW
function PANEL:UpdateClassString()
  if self.classUpdateCount > 3 then return end
  self.classString = ""
  local len = 0
  local tbl = self.Player:GetClasses()
  if tbl == nil then return "" end
  for k, v in pairs( tbl ) do
    if len >= 44 then
      self.classString = self.classString.."\n"
      len = 0
    end
    if v.CLASS then
      self.classString = self.classString..FW.ClassInfo[k].NAME
      len = len + string.len( FW.ClassInfo[k].NAME )
      if v.SPECIALABILITY then
        self.classString = self.classString.." ( s )"
        len = len + 4
      end
      if k ~= #myClasses then
        self.classString = self.classString..",  "
        len = len + 3
      end
    end
  end
  self.classUpdateCount = self.classUpdateCount + 1
  return self.classString
end

--]]



--[[  
- Sets color of labels
-
- @author SW
--]]
function PANEL:ApplySchemeSettings()
  for _k, column in pairs( self.InfoLabels ) do
    for k, v in pairs( column ) do
      v.Key:SetFGColor( 0, 0, 0, 235 )
      //v.Key:SetFont("Default")
      v.Key:SetTextColor( Color( 0, 0, 0, 255 ) )
      v.Value:SetFGColor( 0, 70, 0, 200 )
	  v.Value:SetTextColor( Color( 0, 0, 0, 255 ) )
      //v.Value:SetFont("Default")
    end
  end
end

--[[  
- Updates players information every 3 second
-
- @author SW
--]]
function PANEL:Think()
  if self.PlayerUpdate and self.PlayerUpdate > CurTime() then return end
  self.PlayerUpdate = CurTime() + 3
  self:UpdatePlayerData()
end

--[[  
- Lays out all the elements on the panel
-
- @author SW
--]]
function PANEL:PerformLayout()  
  self.imgAvatar:SetPos( self:GetWide() - 44, 0 )
  self.imgAvatar:SetSize( 38, 38 )
  
  local x = 5
  
  for colnum, column in pairs( self.InfoLabels ) do
    local y = 0
    local RightMost = 0
    for k, v in pairs( column ) do
      v.Key:SizeToContents()
      local y = ( v.Key:GetTall() + 2 ) * v.Row
      v.Key:SetPos( x, y )      
      v.Value:SetPos( x + 52 , y )
      v.Value:SizeToContents()
      -- y = y + v.Key:GetTall() + 2
      RightMost = math.max( RightMost, v.Value.x + v.Value:GetWide() )
    end
    x = RightMost + 40
    -- x = x + 300
  end
end

function PANEL:Paint()
  return true
end
vgui.Register( "ScorePlayerInfoCard", PANEL, "Panel" )