if SERVER then AddCSLuaFile("shared.lua") end
SWEP.Author      = "Darkspider / SW"
SWEP.Contact		= ""
SWEP.Purpose		= "Create Props"
SWEP.Instructions  = "Left click to create props. \nRight click to select props. \n+use (default E) to rotate props. \nReload to snap to a\n  prop(platinum only). \n T to reset prop angles"
SWEP.PrintName = "Prop Creator"
SWEP.Slot = 1
SWEP.SlotPos = 1
SWEP.ViewModelFOV	= 60
SWEP.ViewModelFlip	= false
SWEP.ViewModel      = "models/weapons/v_toolgun.mdl"
SWEP.WorldModel      = "models/weapons/w_toolgun.mdl"

SWEP.Spawnable			= false
SWEP.AdminSpawnable		= false

SWEP.Primary.ClipSize		= -1				// Size of a clip
SWEP.Primary.DefaultClip	= -1				// Default number of bullets in a clip
SWEP.Primary.Automatic		= false				// Automatic/Semi Auto
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1				// Size of a clip
SWEP.Secondary.DefaultClip	= -1				// Default number of bullets in a clip
SWEP.Secondary.Automatic	= false				// Automatic/Semi Auto
SWEP.Secondary.Ammo			= "none"

SWEP.Angle = Angle(0,0,0)
SWEP.Pos = Vector(1,0,0)
SWEP.Freeze = false
local totalX = 0
local totalY = 0

local SelectedProp = 1
local selectedBuyableProp = 1

--Smartsnap vars
local target = { active = false }
local snapkey = false
local cache = {}
--End smartsnap vars

GhostProp = CreateClientConVar( "fw_ghost_prop", "1", true, false )
RotationSpeed = CreateClientConVar("rotationSpeed", "16", true, false )
RotationIncrements = CreateClientConVar("RotationIncrements", "45", true, false )
SnapAngle = CreateClientConVar("snapAngle", "1", true, false )
NoCollide = CreateClientConVar("noCollide", "0", true, false )

local lastSend = 0
function SWEP:PrimaryAttack()
  if SERVER then return end
  if !IsValid(self.GhostProp) then return end
  if lastSend > CurTime() then return end
  lastSend = CurTime()+0.2
  
  local min,max = self.GhostProp:WorldSpaceAABB()
  local minadj = min+Vector(1.5,1.5,1.5)
  local maxadj = max-Vector(1.5,1.5,1.5)
  for i,v in pairs (ents.FindInBox(minadj, maxadj)) do
    if v:GetClass() == "spawn_marker" then
      notification.AddLegacy("This prop is blocking a spawnpoint", NOTIFY_ERROR, 2)
      surface.PlaySound("buttons/button10.wav")
      Msg("This prop is blocking a spawnpoint\n")
      return
    elseif v:IsPlayer() and v != self.Owner then
      if v:Alive() then
        notification.AddLegacy("This prop is blocking a player", NOTIFY_ERROR, 2)
        surface.PlaySound("buttons/button10.wav")
        Msg("This prop is blocking a player\n")
        return
      end
    elseif v:GetClass() == "prop" and v:GetPos():Distance(self.Pos) < 2 then
      
      local a1 = v:GetAngles() 
      local ydiff = math.abs(self.Angle.y) - math.abs(a1.y)
      local pdiff = math.abs(self.Angle.p) - math.abs(a1.p)
      local rdiff = math.abs(self.Angle.r) - math.abs(a1.r)
      if ydiff < 10 and pdiff < 10 and rdiff < 10 then
        notification.AddLegacy("This prop is too close to another prop", NOTIFY_ERROR, 2)
        surface.PlaySound("buttons/button10.wav")
        Msg("This prop is too close to another prop\n")
        return
      end
    end
  end

  if SelectedProp then
      RunConsoleCommand( "createprop",SelectedProp,tostring(self.Angle),tostring(self.Pos))
  else
      RunConsoleCommand( "createprop", tostring(selectedBuyableProp.."B"),tostring(self.Angle),tostring(self.Pos))  
  end
 
end

if SERVER then
function SWEP:SecondaryAttack() end
return end
local MousePos = {ScrW()*0.5,ScrH()*0.5}



/*---------------------------------------------------------
  Creates and sets the convar to the selected props 
  name so it can be drawn on the tool gun screen.
---------------------------------------------------------*/
 function SWEP:Deploy()
 
     if SelectedProp then
      self.Owner:SetNWString("PropName", PropList[SelectedProp].NAME)
    else
		self.Owner:SetNWString("PropName", buyableProps[selectedBuyableProp].NAME)
    end
    //self.Owner:SetNWString("PropName", PropList[SelectedProp].NAME)
 end

function SWEP:MakeGhostProp()

  if SelectedProp then
    util.PrecacheModel( PropList[SelectedProp].MODEL )
  else
    util.PrecacheModel( buyableProps[selectedBuyableProp].MODEL )
  end
	
	self:ReleaseGhostProp()
	
	if SelectedProp then
	self.GhostProp = ents.CreateClientProp( PropList[SelectedProp].MODEL )
	else
	self.GhostProp = ents.CreateClientProp( buyableProps[selectedBuyableProp].MODEL )
	end
	
	self.GhostProp:Spawn()
	self.GhostProp:SetSolid( SOLID_VPHYSICS );
	self.GhostProp:SetMoveType( MOVETYPE_NONE )
	self.GhostProp:SetNotSolid( true );
	self.GhostProp:SetRenderMode( RENDERMODE_TRANSALPHA )
	local c = team.GetColor(LocalPlayer():Team())
	self.GhostProp:SetColor( Color(c.r,c.g,c.b, 150) )
end

function SWEP:ReleaseGhostProp()
	if ( IsValid(self.GhostProp) ) then
		self.GhostProp:Remove()
		self.GhostProp = nil
	end
end

function SWEP:UpdateGhostProp()
	if tonumber(GhostProp:GetInt()) == 0 then self:ReleaseGhostProp() return end
	
	local tr = {}
	tr.start = self.Owner:GetShootPos()
	tr.endpos = tr.start + (self.Owner:GetAimVector() * 200)
	tr.filter = self.Owner

	local trace = util.TraceLine( tr )
	if (trace.Hit) then
		if ( !self.GhostProp ) then
			self:MakeGhostProp( )
		end	
		
    if SelectedProp then
      self.GhostProp:SetModel( PropList[SelectedProp].MODEL)
    else
      self.GhostProp:SetModel(buyableProps[selectedBuyableProp].MODEL)
    end
		
		
		if tonumber(RotationSpeed:GetInt()) == 0 then
			self.Angle = trace.Entity:GetAngles()
		end
		
		self.GhostProp:SetAngles(Angle(self.Angle))
    
		if snapkey or NoCollide:GetInt() == 1 then
	
	-- Set position of the ghost prop (No-collided)	
	
			local CurPos = self.GhostProp:GetPos()
			local NearestPoint = self.GhostProp:NearestPoint(CurPos - (trace.HitNormal * 512))
			local PropOffset = CurPos - NearestPoint
			
			self.Pos = trace.HitPos + trace.HitNormal + PropOffset
			self.GhostProp:SetPos(self.Pos)
		
		else
	
	-- Set position of the ghost prop (normal)	
	
			local norm = trace.HitNormal
			local min,max = self.GhostProp:WorldSpaceAABB()
			local offset=max-min
	  
			
				if !SelectedProp then
				
					self.Pos = trace.HitPos - norm * self.GhostProp:OBBMins().z
				
					
				else
				
					self.Pos = trace.HitPos + norm*(offset/2)
					
				end
			
			self.GhostProp:SetPos( self.Pos )
	  
    end
	
	else
		self:ReleaseGhostProp()
	end
end

/*---------------------------------------------------------
  Handles the free prop rotation and the 45 degree
  increment prop rotation
---------------------------------------------------------*/
function SWEP:PropRotation()

  local cmd = self:GetOwner():GetCurrentCommand()
  local Xdegrees = cmd:GetMouseX() * (tonumber(RotationSpeed:GetInt())/400)
  local Ydegrees = cmd:GetMouseY() * (tonumber(RotationSpeed:GetInt())/400)
  local Increments = tonumber(RotationIncrements:GetFloat())
  
  --------------------------------------------------
  --free-rotate when shift is not held down.
  --------------------------------------------------
  
  if !self.Owner:KeyDown(IN_SPEED) then
    self.Angle:RotateAroundAxis(self.Owner:GetRight(), Ydegrees)
    self.Angle:RotateAroundAxis(Vector( 0, 0, 1 ), Xdegrees)
	
	----------------------------------------------------------------------------------------------------
    -- Rotate p, y, and r in increments of 45 when shift + e is held down.
	----------------------------------------------------------------------------------------------------
	
  else
  if Increments < 0 then return end
    if ((math.Round(self.Angle.p % Increments) != 0 ) || (math.Round(self.Angle.y) % Increments != 0) || (math.Round(self.Angle.r) % Increments != 0)) then
      self.Angle.p = (math.Round(self.Angle.p/Increments)) * Increments
      self.Angle.y = (math.Round(self.Angle.y/Increments)) * Increments
      self.Angle.r = (math.Round(self.Angle.r/Increments)) * Increments
    end
    
    --Does the 45 and -45 degree rotations along the world's z-axis		(left / right)
    totalX = totalX + Xdegrees
    if totalX > Increments then
      totalX = 0
      self.Angle:RotateAroundAxis(Vector(0, 0, 1), Increments)
    elseif totalX < -Increments then
      totalX = 0
      self.Angle:RotateAroundAxis(Vector(0, 0, 1), -Increments)
    end
  
    --Does the 45 and -45 degree rotations along the prop 	(up / down)
    totalY = totalY + Ydegrees
    if totalY > Increments then
      totalY = 0
      self.Angle:RotateAroundAxis(self.Owner:GetRight(), Increments)
    elseif totalY < -Increments then
      totalY = 0
      self.Angle:RotateAroundAxis(self.Owner:GetRight(), -Increments)
    end
	
  end  
end

function SWEP:Think()

if (SERVER) then return end

    if SelectedProp then
      self.Owner:SetNWString("PropName", PropList[SelectedProp].NAME)
    else
		self.Owner:SetNWString("PropName", buyableProps[selectedBuyableProp].NAME)
    end


if self.Owner:KeyReleased(IN_ATTACK) then
    snapkey = false
    target.locked = false
	
  elseif self.Owner:KeyDown(IN_RELOAD) then

   if memberlevel >= 3 then
   
		snapkey = target.active
		
		if IsValid(target.entity) and tonumber(SnapAngle:GetInt()) == 1 then
			self.Angle = target.entity:GetAngles()
		end
		
    end
	
  elseif self.Owner:KeyReleased(IN_RELOAD) then
    snapkey = false
	
  
  elseif self.Owner:KeyReleased(IN_WALK) then
	if IsValid(target.entity) then
		self.Angle = target.entity:GetAngles()
    end
  -- Used to reset prop angle
  
	elseif input.IsKeyDown(KEY_T) then
		self.Angle = Angle(0, 0, 0)  
    
  elseif self.Owner:KeyDown( IN_USE ) and tonumber(RotationSpeed:GetInt()) != 0 then
     self.Freeze = true
    self:PropRotation()
  else
     self.Freeze = false
  end

target.locked = snapkey and target.active
self:UpdateGhostProp()

end

function SWEP:FreezeMovement() 
  return self.Freeze
end

function SWEP:Holster()
	self:ReleaseGhostProp()
	return true
end

function SWEP:OnRemove()
	self:ReleaseGhostProp()
end

---
--Snap functions
---
local function RayQuadIntersect(vOrigin, vDirection, vPlane, vX, vY)
  local vp = vDirection:Cross(vY)

  local d = vX:DotProduct(vp)
  if (d <= 0.0) then return end

  local vt = vOrigin - vPlane
  local u = vt:DotProduct(vp)
  if (u < 0.0 or u > d) then return end

  local v = vDirection:DotProduct(vt:Cross(vX))
  if (v < 0.0 or v > d) then return end
  return Vector(u / d, v / d, 0)
end

/*---------------------------------------------------------
  Computes the edges of the given entity
---------------------------------------------------------*/
local function ComputeEdges(entity, obbmax, obbmin)
  return {
    lsw = entity:LocalToWorld(Vector(obbmin.x, obbmin.y, obbmin.z)),
    lse = entity:LocalToWorld(Vector(obbmax.x, obbmin.y, obbmin.z)),
    lnw = entity:LocalToWorld(Vector(obbmin.x, obbmax.y, obbmin.z)),
    lne = entity:LocalToWorld(Vector(obbmax.x, obbmax.y, obbmin.z)),
    usw = entity:LocalToWorld(Vector(obbmin.x, obbmin.y, obbmax.z)),
    use = entity:LocalToWorld(Vector(obbmax.x, obbmin.y, obbmax.z)),
    unw = entity:LocalToWorld(Vector(obbmin.x, obbmax.y, obbmax.z)),
    une = entity:LocalToWorld(Vector(obbmax.x, obbmax.y, obbmax.z)),
  }
end

local function OnPaintHUD()
  target.active = false
  
  --if () then return end--if plat
  if !LocalPlayer():Alive() then return end
  
  if target.locked then
    if !target.entity:IsValid() then return end
  else
  

	local tr = {}
	tr.start = LocalPlayer():GetShootPos()
	tr.endpos = tr.start + (LocalPlayer():GetAimVector() * 200)
	tr.filter = LocalPlayer()
	local trace = util.TraceLine( tr )
	
    if !trace.Hit then return end

    local entity = trace.Entity
	
    if entity == nil or entity:GetClass() != "prop" or !entity:IsValid() then return end
	 
	target.entity = entity
	//print(target.entity)
	
end
  
  -- updating the cache perhaps shouldn't be done here, CalcView?
  
  if cache.eEntity != target.entity or cache.vEntAngles != target.entity:GetAngles() or cache.vEntPosition != target.entity:GetPos() then
    cache.eEntity = target.entity
    cache.vEntAngles = target.entity:GetAngles()
    cache.vEntPosition = target.entity:GetPos()
    
    local obbmax = target.entity:OBBMaxs()
    local obbmin = target.entity:OBBMins()
    local obvgrid = ComputeEdges(target.entity, obbmax, obbmin)
    
    local faces = {
      { obvgrid.unw, obvgrid.usw - obvgrid.unw, obvgrid.une - obvgrid.unw, obvgrid.lnw - obvgrid.unw },
      { obvgrid.lsw, obvgrid.lnw - obvgrid.lsw, obvgrid.lse - obvgrid.lsw, obvgrid.usw - obvgrid.lsw },
      { obvgrid.unw, obvgrid.une - obvgrid.unw, obvgrid.lnw - obvgrid.unw, obvgrid.usw - obvgrid.unw },
      { obvgrid.usw, obvgrid.lsw - obvgrid.usw, obvgrid.use - obvgrid.usw, obvgrid.unw - obvgrid.usw },
      { obvgrid.une, obvgrid.use - obvgrid.une, obvgrid.lne - obvgrid.une, obvgrid.unw - obvgrid.une },
      { obvgrid.unw, obvgrid.lnw - obvgrid.unw, obvgrid.usw - obvgrid.unw, obvgrid.une - obvgrid.unw },
    }
    cache.aFaces = faces
  end
  
  local faces = cache.aFaces
  
  if (!target.locked) then    
    for face,vertices in ipairs(faces) do
      intersection = RayQuadIntersect(LocalPlayer():GetShootPos(), LocalPlayer():GetAimVector(), vertices[1], vertices[2], vertices[3])
      if intersection then
        target.face = face
        break
      end
    end
    if intersection == nil then return end
  end
    
  local vectorOrigin = faces[target.face][1]
  local vectorX =      faces[target.face][2]
  local vectorY =      faces[target.face][3]
  local vectorZ =      faces[target.face][4]
  
  local vectorGrid
  if !target.locked then
    vectorGrid = vectorOrigin + (vectorY * .5) + (vectorX * .5)
    
    local trace = util.TraceLine({
      start  = target.entity:LocalToWorld(target.entity:WorldToLocal(vectorGrid)) - vectorZ:GetNormalized() * 0.01,
      endpos = vectorGrid + vectorZ,
    })
        
    local vectorSnap = trace.HitPos
    target.offset = target.entity:WorldToLocal(vectorSnap)
    target.vector = target.entity:WorldToLocal(vectorGrid)
  else
    vectorGrid = target.entity:LocalToWorld(target.vector)
  end
  target.active = true
end
hook.Add("HUDPaintBackground", "SnapPaintHUD", OnPaintHUD)

local function OnSnapView(ply, angles)
  local targetvalid = target.active and target.locked and target.entity:IsValid()
  if targetvalid then
    return {angles = (target.entity:LocalToWorld(target.offset) - ply:GetShootPos()):Angle()}
  end
end
hook.Add("CalcView", "SnapView", OnSnapView)

local function OnSnapAim(ply)
  local targetvalid = target.active and target.locked and target.entity:IsValid()
  if targetvalid then
    ply:SetViewAngles((target.entity:LocalToWorld(target.offset) - LocalPlayer():GetShootPos()):Angle())
  end
end
hook.Add("CreateMove", "Snap", OnSnapAim)
---
--End Snap
---


/*---------------------------------------------------------
	Build Menu
---------------------------------------------------------*/
--[[ BEGIN BUTTON ]]--
local PANEL = {}

function PANEL:Init()
  self.Model = vgui.Create( "DModelPanel", self )
  self.Model.LayoutEntity = function( Entity ) -- Stops model rotation
    if self.bAnimated then 
      self:RunAnimation()
    end 
  end   
  self.modelToSet = nil  
end

function PANEL:SetModel( model )
  self.modelToSet = model
end

local x,y,w,h = nil, nil, nil, nil
function PANEL:PerformLayout()
  if self.modelToSet then
    self.Model:SetModel( self.modelToSet )
    self.Model:SetSize( self:GetTall(), self:GetWide() )
    self.Model:SetPos( 0, 0 )
  end

  x, y = self:LocalToScreen( 0, 0 )
  w, h = self:GetSize()
end

function PANEL:Paint()
  if not x or not y or not w or not h then return end
  sl, st, sr, sb = x, y, x + w, y + h
      
  p = self
     
  while p:GetParent() do
    p = p:GetParent()
    pl, pt = p:LocalToScreen( 0, 0 )
    pr, pb = pl + p:GetWide(), pt + p:GetTall()
    sl = sl < pl and pl or sl
    st = st < pt and pt or st
    sr = sr > pr and pr or sr
    sb = sb > pb and pb or sb
  end
    
  render.SetScissorRect( 0, 0, w, h, true )
    self.BaseClass.Paint( self )
  render.SetScissorRect( 0, 0, 0, 0, false )   
  return true
end

vgui.Register( "TestBtn", PANEL, "DPanel" )
--[[ END BUTTON ]]--


-- Sets up a button for use in the DPanelLists

local PropMenu = {}
function PropMenu:Init()
  self.SelectedProp = 1
  self:SetSize( 393, 313 )
  self:SetPos( ScrW() * 0.5 - self:GetWide() / 2, ScrH() * 0.5 )
  
  --Setup contextPanel
  self.ContextPanel = vgui.Create( "DPanel", self )
  self.ContextPanel:SetSize( self:GetWide() - 10, 110 )
  self.ContextPanel:SetPos( 5, self:GetTall() - self.ContextPanel:GetTall() - 5 )
  self.ContextPanel.Paint = function() return end
  
  self.PropPanelList = vgui.Create( "DPanelList", self )
  self.PropPanelList:SetPos( 10, 10 )
  self.PropPanelList:SetSize( self:GetWide() - 20, self:GetTall() - self.ContextPanel:GetTall() - 20 )
  self.PropPanelList:SetSpacing( 6 )
  self.PropPanelList:SetPadding( 6 )
  self.PropPanelList:EnableVerticalScrollbar()
  self.PropPanelList:EnableHorizontal( true )
  self.PropPanelList.Paint = function()
    draw.RoundedBox( 8, 0, 0, self.PropPanelList:GetWide(), self.PropPanelList:GetTall(), Color( 50, 50, 50, 200 ))
  end
  
	for i,v in pairs(PropList) do
		local p = vgui.Create("SpawnIcon")
		p:SetModel(v.MODEL)
		p:SetToolTip(v.NAME.."\nPrice: $"..v.PRICE.."\nHealth: "..v.HEALTH)
		p.OnCursorMoved = function() 
		selectedBuyableProp = nil
		SelectedProp = i 
		print(i)
		end
		self.PropPanelList:AddItem(p)
	end
	
	for i,v in pairs(buyableProps) do

		local p = vgui.Create("SpawnIcon")
		p:SetModel(v.MODEL)
		p:SetToolTip(v.NAME.."\nPrice: $"..v.PRICE.."\nHealth: "..v.HEALTH)
		p.OnCursorMoved = function() 
			SelectedProp = nil
			selectedBuyableProp = i 
		end
		
		if table.HasValue(myprops, i) then
			self.PropPanelList:AddItem(p)
		end

	end

 
  self.RotationSpeedNumSlider = vgui.Create( "DNumSlider", self.ContextPanel )
  self.RotationSpeedNumSlider:SetPos( 140, 10 )
  self.RotationSpeedNumSlider:SetWide( 250 )
  self.RotationSpeedNumSlider:SetMinMax( 1, 64 )
  self.RotationSpeedNumSlider:SetDecimals( 0 )
  self.RotationSpeedNumSlider:SetValue( 8 )
  self.RotationSpeedNumSlider:SetToolTip( "Ghost Prop Rotation Speed ( Default 16 )" )
  self.RotationSpeedNumSlider:SetConVar( "RotationSpeed" )
  self.RotationSpeedNumSlider.OnValueChanged = function(p, v)
	  self.RotationSpeedNumSlider:SetValue(	 math.Round(v/4)*4	)
  end
  
  local gpx, gpy = self.RotationSpeedNumSlider:GetPos()
  self.RotationSpeedLabel = Label( "Rotation Speed", self.ContextPanel )
  self.RotationSpeedLabel:SizeToContentsX()
  self.RotationSpeedLabel:SetPos( gpx+110, gpy-10 )
  
  
  self.AngleNumSlider = vgui.Create( "DNumSlider", self.ContextPanel )
  self.AngleNumSlider:SetPos( 140, 60 )
  self.AngleNumSlider:SetWide( 250 )
  self.AngleNumSlider:SetMinMax( 11.25, 90 )
  self.AngleNumSlider:SetDecimals( 2 )
  self.AngleNumSlider:SetToolTip( "Amount prop rotates when holding shift + use( E ) ( Default 45 )" )
  self.AngleNumSlider:SetConVar( "RotationIncrements" )
  self.AngleNumSlider.OnValueChanged = function(p, v)
	  self.AngleNumSlider:SetValue(	 math.Round(v/11.25)*11.25	)
  end
  
  local gpx, gpy = self.AngleNumSlider:GetPos()
  self.AngleNumLabel = Label( "Rotation Angle", self.ContextPanel )
  self.AngleNumLabel:SizeToContentsX()
  self.AngleNumLabel:SetPos( gpx+110, gpy-10 )
  
  self.GhostPropCheckBox = vgui.Create( "DCheckBox", self.ContextPanel )
  self.GhostPropCheckBox:SetPos( 30, 10 )
  self.GhostPropCheckBox:SetConVar( "fw_ghost_prop" )
  local gpx, gpy = self.GhostPropCheckBox:GetPos()
  self.GhostPropLabel = Label( "Show/Hide Ghost Prop", self.ContextPanel )
  self.GhostPropLabel:SizeToContentsX()
  self.GhostPropLabel:SetPos( gpx + 17, gpy - 5 )
  
  
  self.NoCollideCheckBox = vgui.Create( "DCheckBox", self.ContextPanel )
  self.NoCollideCheckBox:SetPos( 30, 30 )
  self.NoCollideCheckBox:SetConVar( "noCollide" )
  self.NoCollideCheckBox:SetToolTip( "Ghost prop doesnt collide with the item you're looking at. *Screws up prop rotation*" )
  local ncx, ncy = self.NoCollideCheckBox:GetPos()
  self.NoCollideLabel = Label( "No Collide", self.ContextPanel )
  self.NoCollideLabel:SizeToContentsX()
  self.NoCollideLabel:SetPos( ncx + 17, ncy - 5 )
  
  
  self.SnapAngleCheckBox = vgui.Create( "DCheckBox", self.ContextPanel )
  self.SnapAngleCheckBox:SetPos( 30, 50 )
  self.SnapAngleCheckBox:SetConVar( "snapAngle" )
  if SERVER then
  if not LocalPlayer():IsPlatinum() then
    self.SnapAngleCheckBox:SetDisabled( true )
    self.SnapAngleCheckBox:SetToolTip( "Platinum Donators Only" )
  end
  end
  local sax, say = self.SnapAngleCheckBox:GetPos()
  self.SnapLabel = Label( "Persist Angles (Prop snap)", self.ContextPanel )
  self.SnapLabel:SizeToContentsX()
  self.SnapLabel:SetPos( sax + 17, say - 5 )
  
  
  self.RemoveAllBtn = vgui.Create( "DButton", self.ContextPanel )
  self.RemoveAllBtn:SetPos( 30, 75 )
  self.RemoveAllBtn:SetSize( 85, 25 )
  self.RemoveAllBtn:SetText( "Default Settings" )
  self.RemoveAllBtn:SetToolTip( "Retain all of the default prop gun settings." )
  self.RemoveAllBtn.DoClick = function()
	LocalPlayer():ConCommand("snapAngle 1")
	LocalPlayer():ConCommand("noCollide 0")
	LocalPlayer():ConCommand("RotationIncrements 45")
	LocalPlayer():ConCommand("RotationSpeed 16")
	LocalPlayer():ConCommand("fw_ghost_prop 1")
  end
end

	
function PropMenu:updatelist()
	for i,v in pairs(buyableProps) do

		local p = vgui.Create("SpawnIcon")
		p:SetModel(v.MODEL)
		p:SetToolTip(v.NAME.."\nPrice: $"..v.PRICE.."\nHealth: "..v.HEALTH)
		p.OnCursorMoved = function() 
			SelectedProp = nil
			selectedBuyableProp = i 
		end
		
		if table.HasValue(myprops, i) then
			self.PropPanelList:AddItem(p)
		end

	end
end


function SWEP:SecondaryAttack()
	if !BuildPanel then
		BuildPanel = vgui.Create("PropMenu")
		gui.EnableScreenClicker(true)
		gui.SetMousePos(ScrW()*0.5,ScrH()*0.5)
	else
		BuildPanel:SetVisible(true)
		
		if self.Owner:GetNWInt("boughtprop") == true then
			BuildPanel:updatelist()
			self.Owner:SetNWBool("boughtprop", false)
		end
		
		
		gui.EnableScreenClicker(true)
		gui.SetMousePos(ScrW()*0.5,ScrH()*0.5)
	end
end

function PropMenu:Paint()
  surface.SetDrawColor( 255, 255, 255, 255 )
  surface.SetTexture( surface.GetTextureID("darkland/fortwars/propmenualt" ))
  surface.DrawTexturedRect( -60, -100, 512, 512 )
end

-- If not in Attack 2 then hide PropMenu, restore mouse pos, and disable screen clicker
function PropMenu:Think()
  if not LocalPlayer():KeyDown( IN_ATTACK2 ) and self:IsVisible() then
    self:SetVisible( false )
    mousePos = { gui.MouseX(), gui.MouseY() }
    gui.EnableScreenClicker( false )
  end
end

function PropMenu:GetSelectedProp()
  return self.selectedProp
end
vgui.Register( "PropMenu", PropMenu, "DPanel" )