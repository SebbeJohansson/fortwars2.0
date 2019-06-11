AddCSLuaFile( "cl_menu.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_deathnotice.lua" )
AddCSLuaFile( "cl_scoreboard.lua" )
AddCSLuaFile( "cl_endgame.lua" )
include("shared.lua")
include( "cl_deathnotice.lua" )
include( "cl_menu.lua" )
include( "cl_scoreboard.lua" )
include( "cl_endgame.lua" )

CreateClientConVar( "fw_advcrouch", "1", true, true )
MenuOnSpawn = CreateClientConVar( "fw_menuonspawn", "1", true, true )
CreateClientConVar( "fw_spawnwithgrav", "1", true, true )
CreateClientConVar( "fw_chatsounds", "1", true, true )
CreateClientConVar( "fw_zoomaftereload", "1", true, true )
CrosshairColor = CreateClientConVar( "fw_crosshaircolor", "0 255 0 255", true, true ):GetString()
CreateClientConVar( "fw_crosshairlength", "20", true, true ):GetString()
CreateClientConVar( "fw_crosshairwidth", "1", true, true ):GetString()
CreateClientConVar( "fw_crosshairdot", "0", true, true )

net.Receive("sendinfo", function(len)
	local actualname = net.ReadString()
	local actualcash = net.ReadInt(32)
	local actualmyclasses = net.ReadTable()
	local actualmyspecials = net.ReadTable()
	local actualupgrades = net.ReadTable()
	local actualprops = net.ReadTable()
	local actualstats = net.ReadTable()
	local actualmember = net.ReadInt(32)
	
	name = actualname
	cash = actualcash
	myclasses = actualmyclasses
	myspecials = actualmyspecials
	myupgrades = actualupgrades
	myprops = actualprops
	mystats = actualstats
	memberlevel = actualmember
    playerloaded = 1
end)

net.Receive("updatecash", function(len)
	local actualcash = net.ReadInt(32)
	cash = actualcash
end)

net.Receive("updateclasses", function(len)
	local actualmyclasses = net.ReadTable()
	myclasses = actualmyclasses
end)

net.Receive("updatespecials", function(len)
	local actualmyspecials = net.ReadTable()
	myspecials = actualmyspecials
end)

net.Receive("updatelevels", function(len)
	local actualupgrades = net.ReadTable()
	myupgrades = actualupgrades
end)

net.Receive("updateprops", function(len)
	local actualprops = net.ReadTable()
	myprops = actualprops
end)

net.Receive("updatedonor", function(len)
	local actualmember = net.ReadInt(32)
	memberlevel = actualmember
end)

net.Receive("curclass", function(len)
	local actualclass = net.ReadInt(8)
	class = actualclass
end)

net.Receive("changetodm", function(len)
	whatmode = "Fight"
end)

net.Receive("changetobuild", function(len)
	whatmode = "Build"
	ballid = nil
end)

net.Receive("ballentid", function(len)
	ballid = net.ReadInt(32)
end)

name = name or ""
cash = cash or 0
myclasses = myclasses or {1, }
myspecials = myspecials or {0, }
myupgrades = myupgrades or {0, 0, 0, 0, }
myprops = myprops or {}
memberlevel = memberlevel or 1
playerloaded = 0

net.Receive("leaderboards", function(len, pl)

	local accounts = net.ReadTable()
	PrintTable(accounts)
	
	local wid, hei = 1100, 600
	local frame = vgui.Create("DFrame")
	
	frame:SetSkin("Default")
	frame:SetSize(wid, hei)
	frame:Center()
	frame:SetTitle("FortWars Leaderboards - "..table.Count(accounts).." unique accounts")
	frame:MakePopup()

	local hispanel = vgui.Create("DListView", frame)
	hispanel:SetSize(wid-50, 500)
	hispanel:SetPos(20,85)
	
	hispanel:AddColumn("Name")
	hispanel:AddColumn("SteamID")
	hispanel:AddColumn("Money")
	hispanel:AddColumn("Kills")
	hispanel:AddColumn("Assists")
	hispanel:AddColumn("Ball time (seconds)")
	hispanel:AddColumn("Wins")
	hispanel:AddColumn("Losses")
	hispanel:AddColumn("Hours")

	timer.Simple(1, function()
		for k, v in pairs (accounts) do
			local playtime = accounts[k].stats[6]
			if !playtime then playtime = 0 else playtime = math.Round(playtime/3600) end
		
			hispanel:AddLine(accounts[k].name or "Unknown", accounts[k][1], accounts[k].cash, accounts[k].stats[1] or 0, accounts[k].stats[2] or 0, accounts[k].stats[3] or 0, accounts[k].stats[4] or 0, accounts[k].stats[5] or 0, playtime	)
		end
	end)
	
	hispanel.OnClickLine = function(panel, line, selected)
	
	local steamID64 = util.SteamIDTo64(line:GetValue(2))
	
			local ModifyMenu = DermaMenu()
			ModifyMenu:SetPos(gui.MousePos())
			
			ModifyMenu:AddOption("Open Steam Profile", function()
				gui.OpenURL("http://steamcommunity.com/profiles/"..steamID64)
			end):SetImage("icon16/world.png")
			
			ModifyMenu:Open()
end
end)

TeamsPresent = 0
TeamInfo = {}

usermessage.Hook("initFW",function( um )
	local index = um:ReadChar()
	while(index != 0) do
		TeamInfo[index] = {
			Present = true,
			BoxCount = 0
		}
		TeamsPresent = TeamsPresent + 1
		index = um:ReadChar()
	end
end)

function ToMoney( money )
  money = tostring( money )
  for i = #money - 3, 1, -3 do
     money = string.sub( money, 0, i ) .. "," .. string.sub( money, i + 1 )
  end
  return "$"..money
end

net.Receive("boxCount", function(len)
	TeamInfo[LocalPlayer():Team()].BoxCount = net.ReadInt(10)
end)

surface.CreateFont( "ClassName", {
	font = "coolvetica",
	extended = false,
	size = 22,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
} )

surface.CreateFont( "ClassNameSmall", {
	font = "coolvetica",
	extended = false,
	size = 17,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
} )

surface.CreateFont( "ClassNameLarge", {
	font = "coolvetica",
	extended = false,
	size = 26,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
} )

surface.CreateFont( "CSKillIcons", {
      font = "csd",
      size = 50,
      weight = 500,
      blursize = 0,
      scanlines = 0,
      antialias = false,
	  shadow = false,
	  additive = true
} )

surface.CreateFont( "HL2MPTypeDeath", {
      font = "hl2mp",
      size = 50,
      weight = 500,
      blursize = 0,
      scanlines = 0,
      antialias = false,
	  shadow = false,
	  additive = true
} )

function TW(s, f)
	local w = surface.GetTextSize(s, f)
	return w
end

function util.WordWrap(txt, font, maxl)
	local tab = string.Explode(" ", txt)
	local w = ""
	for i, v in pairs(tab) do
		local t = w.." "..v
		if TW(t, font) < maxl then
			w = t
		else
			w = w.."\n"..v
		end
	end

	return w
end

function WrapText(width,charwidth,msg)

local length = string.len(msg)
local char = 0
local lean = 0
local sub = 0
local newstring = ""
if (length * charwidth) > width then //need to add support for different types of fonts

	while (char < length) do
			if (((char)*charwidth)-sub*charwidth) >= width then
				if string.Left(string.Right(msg,length-char),1) == " " then
				newstring = newstring .. "\n"
				sub = char
				char = char + 1 //we dont want a space to be the first character.
				elseif string.Left(string.Right(msg,length-char),1) == "." then
				newstring = newstring .. ".\n"
				sub = char
				char = char + 1 //we dont want a space to be the first character.
				elseif lean > 3 then
				newstring = newstring .. "-\n"
				sub = char
				lean = 0
				else
				lean = lean + 1
				end
			end
			newstring = newstring .. string.Left(string.Right(msg,length-char),1)


			char = char + 1
	end

return newstring
else
return msg
end

end

function HUDHide( hud )
	for k, v in pairs{"CHudHealth","CHudBattery","CHudAmmo"} do
		if hud == v then return false end
	end
end
hook.Add("HUDShouldDraw","HudHide",HUDHide)

function draw.Outline(x,y,width,height)
	surface.SetDrawColor(155,155,155,255)
	surface.DrawOutlinedRect(x - 1,y - 1,width + 1,height + 1)
	surface.SetDrawColor(0,0,0,255)
	surface.DrawOutlinedRect(x,y,width - 1,height - 1)
end

function draw.Circle( x, y, radius, seg )
	local cir = {}
	table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
	for i = 0, seg do
		local a = math.rad( ( i / seg ) * -360 )
		table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
	end
	local a = math.rad( 0 ) -- This is needed for non absolute segment counts
	table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
	surface.DrawPoly( cir )
end



function ScoreWindow()
local num = 0
local adjustforteams = 0
for i,v in pairs(TeamInfo) do
		if v.Present then
		adjustforteams = adjustforteams + 1
	end
end

draw.RoundedBox(6, 10, -6, 267, 71+(adjustforteams*17), Color(200, 200, 200, 100))
draw.RoundedBox(6, 11, -6, 265, 70+(adjustforteams*17), Color(5, 5, 5, 245))
	
draw.RoundedBox(4, 16, 7, 256, 25, Color(200, 200, 200, 100))
draw.RoundedBox(4, 17, 8, 254, 23, Color(5, 5, 5, 220))

draw.SimpleText("FortWars 13", "ClassName", 136, 20, Color(255, 255, 255, 255), 1, 1)
	
	
draw.DrawText(util.WordWrap("Capture the ball and hold it until your team's timer runs out", "Default", 350), "Default", 136, 35, Color(255, 255, 255, 255), 1, 1)
	for i, v in pairs(TeamInfo) do
	
		if v.Present then
		
			local c = team.GetColor(i)
			draw.RoundedBox(0, 29, 65 + num * 16, 242, 13, Color(0, 0, 0, 100))
			surface.SetTexture(surface.GetTextureID("darkland/fortwars/timerBar"))
		
			//if holdingTeam == i then 
			//	c = Color(math.Clamp((c.r + 75), 0, 255), math.Clamp((c.g + 75), 0, 255), math.Clamp((c.b + 75), 0, 255), 210)
			//end
			surface.SetDrawColor(Color(c.r, c.g, c.b, 210))
			surface.DrawTexturedRect(30, 66 + num * 16, 240, 11)
			
			draw.RoundedBox(7, 23 + (DEFAULT_BALL_TIME - GetGlobalInt("team"..i.."time")) / DEFAULT_BALL_TIME * 242, 64 + num * 16, 14, 14, Color(c.r, c.g, c.b, 255))
			//draw.Circle( 23 + (DEFAULT_BALL_TIME - GetGlobalInt("team"..i.."time")) / DEFAULT_BALL_TIME * 242, 64 + num * 16, 2, 2 )
			
			local font = "Default"
			//if holdingTeam == i then font = "DefaultSmall" end
			draw.SimpleText(string.ToMinutesSeconds(GetGlobalInt("team"..i.."time")), font, 136, 70+num*16, Color(255, 255, 255, 255), 0, 1)
		end
		num = num + 1;
	end

end
-------------------------------------------------------------

-------------------------------------------------------------

function ModeWindow()
	local y = -5
	surface.SetTexture(surface.GetTextureID("darkland/fortwars/timerhud1a"))
	surface.SetDrawColor(255, 255, 255, 255)
	surface.DrawTexturedRect(ScrW() * 0.5-64, -3, 128, 64) 
	
	if whatmode == "Build" then
		draw.SimpleTextOutlined("Build Mode", "Default", ScrW() * 0.5, y + 15, Color(255, 255, 255, 255), 1, 1, 1, Color(0, 0, 0, 255))
		draw.SimpleText( string.ToMinutesSeconds( GetGlobalInt("buildtime")), "ClassNameLarge", ScrW() * 0.5, y + 35, Color(255, 255, 255, 255), 1, 1, 1, Color(0, 0, 0, 255))	
		draw.SimpleTextOutlined("Remaining", "Default", ScrW() * 0.5, y + 50, Color(255, 255, 255, 255), 1, 1, 1, Color(0, 0, 0, 255))

	elseif whatmode == "Fight" then
		draw.SimpleTextOutlined("Fight Mode", "Default", ScrW() * 0.5, y + 15, Color(255, 255, 255, 255), 1, 1, 1, Color(0, 0, 0, 255))
		draw.SimpleText( string.ToMinutesSeconds( GetGlobalInt("dmtime")), "ClassNameLarge", ScrW() * 0.5, y + 35, Color(255, 255, 255, 255), 1, 1, 1, Color(0, 0, 0, 255))	
		draw.SimpleTextOutlined("Remaining", "Default", ScrW() * 0.5, y + 50, Color(255, 255, 255, 255), 1, 1, 1, Color(0, 0, 0, 255))
	end
end

function SniperScope()
if LocalPlayer():GetActiveWeapon():IsValid() && LocalPlayer():GetActiveWeapon():GetNWInt( "zoomed" ) != 0 then

			draw.RoundedBox( 0, 0, 0, ScrW(), ScrH(), Color(0, 0, 0, 100))
			local ScopeId = surface.GetTextureID("darkland/scope/scope")
			surface.SetTexture(ScopeId)

			QuadTable = {}
			QuadTable.texture 	= ScopeId
			QuadTable.color		= Color( 0, 0, 0, 255 )
			QuadTable.x = 0
			QuadTable.y = 0
			QuadTable.w = ScrW()
			QuadTable.h = ScrH()

			draw.TexturedQuad( QuadTable )
			surface.SetDrawColor( 0, 0, 0, 200)
			surface.DrawRect(ScrW() / 2 - 1, 0, 2, ScrH() )
			surface.DrawRect(0, ScrH() / 2 - 1, ScrW(), 2 )
	end
end

function HudPropCounter()
local y = -5
if whatmode == "Build" then
	if !DM_MODE and TeamInfo[LocalPlayer():Team()] then

		surface.SetTexture(surface.GetTextureID("darkland/fortwars/prophud1"))
		surface.SetDrawColor(255, 255, 255, 255)
		surface.DrawTexturedRect(ScrW() * 0.5-134, ScrH() - 32, 512, 32) 
		if TeamInfo[LocalPlayer():Team()].BoxCount > 0 then
			draw.RoundedBox(6, ScrW() * 0.5 - 71, ScrH() - 22, math.Clamp(TeamInfo[LocalPlayer():Team()].BoxCount / MAX_PROPS * 196, 11, 196), 14, Color(204, 85, 0, 240)) 
		end
		draw.SimpleTextOutlined(TeamInfo[LocalPlayer():Team()].BoxCount.."/"..MAX_PROPS, "Default", ScrW() * 0.5 + 10, ScrH() - 15, Color(255, 255, 255, 255), 0, 1, 1, Color(0, 0, 0, 255))
	
		end
	end
end

function GM:HUDDrawTargetID()
	local tr = util.GetPlayerTrace( LocalPlayer() )
	local trace = util.TraceLine( tr )
	if (!trace.Hit) then return end
	if (!trace.HitNonWorld) then return end
	
	local text = "ERROR"
	local font = "TargetID"
	

	if (trace.Entity:IsPlayer()) then
		if trace.Entity:GetNWString("ADMDisguise") == "" then
			text = trace.Entity:GetName()
		else
			text = trace.Entity:GetNWString("ADMDisguise")
		end
	else
		return
		--text = trace.Entity:GetClass()
	end

	
	surface.SetFont( font )
	local w, h = surface.GetTextSize( text )
	
	local MouseX, MouseY = gui.MousePos()
	
	if ( MouseX == 0 && MouseY == 0 ) then
	
		MouseX = ScrW() / 2
		MouseY = ScrH() / 2
	
	end
	
	local x = MouseX
	local y = MouseY
	x = x - w / 2
	y = y + 30
	
	 if trace.Entity:GetNWBool( "cloaked") == false and trace.Entity:GetNWBool( "acloaked") == false then
	 
	-- The fonts internal drop shadow looks lousy with AA on
	draw.SimpleText( text, font, x+1, y+1, Color(0,0,0,120) )
	draw.SimpleText( text, font, x+2, y+2, Color(0,0,0,50) )
	draw.SimpleText( text, font, x, y, self:GetTeamColor( trace.Entity ) )
	
	y = y + h + 5
	
	local text = trace.Entity:Health() .. "%"
	local font = "TargetIDSmall"
	
	surface.SetFont( font )
	local w, h = surface.GetTextSize( text )
	local x =  MouseX  - w / 2
	
	draw.SimpleText( text, font, x+1, y+1, Color(0,0,0,120) )
	draw.SimpleText( text, font, x+2, y+2, Color(0,0,0,50) )
	draw.SimpleText( text, font, x, y, self:GetTeamColor( trace.Entity ) )	
	end
end

local PANEL = {}
function PANEL:Paint()
    if playerloaded == 1 then
        local Me = LocalPlayer()
        --HUD Texture
        if !IsValid(Me) then return end
        surface.SetTexture(surface.GetTextureID("darkland/fortwars/hud3"))
        surface.SetDrawColor(255, 255, 255, 255)
        surface.DrawTexturedRect(0, 0, self:GetWide(), self:GetTall())
        
        --Status Information
        local c = team.GetColor(Me:Team())
        local txt = "Regular"
        if memberlevel == 3 then txt = "Platinum" elseif memberlevel == 2 then txt = "Premium" end
        draw.RoundedBox(8, 13, 148, 264, 14, Color(c.r, c.g, c.b, 220))
        local status = "Class: "..Classes[class].NAME.."  |  "..""..txt.."  |  "..ToMoney( cash )
        draw.SimpleTextOutlined(status, "Default", 18, 153, Color(255, 255, 255, 255), 0, 1, 1, Color(0, 0, 0, 255)) 
        
        
        --health bar
        local healthSkill = myupgrades[2] or 0
        draw.RoundedBox(6, 75, 188, math.Clamp(11+Me:Health()/(Classes[class].HEALTH + (healthSkill * 10))*215, 11, 226), 12, Color(170, 0, 0, 240))
        draw.SimpleTextOutlined("Health: "..math.abs(Me:Health()), "Default", 87, 193, Color(255, 255, 255, 255), 0, 1, 1, Color(0, 0, 0, 255))
        
        --energy bar
        draw.RoundedBox(6, 74, 232, 11+Me:GetNWInt('energy')/(100+(myupgrades[3]*5))*215, 12, Color(0, 0, 170, 240))
        draw.SimpleTextOutlined("Energy: "..math.Round(Me:GetNWInt('energy')), "Default", 87, 237, Color(255, 255, 255, 255), 0, 1, 1, Color(0, 0, 0, 255))
    end
end

vgui.Register("Status", PANEL, "DPanel")
statusPanel = vgui.Create("Status")
statusPanel:SetSize(512, 256)
statusPanel:SetPos(22, ScrH()-266)

function CreateStatusPanel()
  if !ValidPanel(status) then
    status = vgui.Create("Status")
    status:SetVisible(true) --Little hacky so the next thing works good :D
  end
end


local showPropInfo = false
function Hud()
local ply = LocalPlayer()


	local tr = {}
	tr.start = ply:GetShootPos()
	tr.endpos = tr.start + ply:GetAimVector()*500
	tr.filter = ply
	tr = util.TraceLine(tr)
	local ent = tr.Entity
	
	--prophp
	if ent:IsValid() && ent:GetClass() == "prop" then
		local t = (ent:GetPos() + ent:OBBCenter()):ToScreen()
		draw.RoundedBox(0, t.x - 30, t.y - 4, 60, 8, Color(200, 200, 200, 200))
		draw.RoundedBox(0, t.x - 29, t.y - 3, 58, 6, Color(200, 0, 0, 255))
		local frac = ent:Health() / ent:GetNWInt("MaxHP")
		draw.RoundedBox(0, t.x - 29, t.y - 3, frac * 58, 6, Color(0, 200, 0, 255))
	end	

	--propinfo
	if ent:IsValid() && ent:GetClass() == "prop" && showPropInfo then
		local t = (ent:GetPos() + ent:OBBCenter() + Vector(0, 0, 10)):ToScreen() 
		local spawner = ent:GetNWEntity("Spawner")
		if IsValid(spawner) then
			draw.SimpleTextOutlined( spawner:Nick().."  "..tostring(spawner:SteamID()), "BudgetLabel", t.x, t.y, Color(255, 255, 255, 255), 1, 1, 1, Color(0, 0, 0, 255))
		end
	end


	ScoreWindow()
	ModeWindow()
	SniperScope()
	HudPropCounter()
	
	
	local wep = ply:GetActiveWeapon()
	if !wep:IsValid() then return end
	local clipSize = wep:Clip1()
	if clipSize < 0 then return end

	local prim = wep.Primary
	if prim then				
		surface.SetTexture(surface.GetTextureID("darkland/fortwars/ammohud1"))
		surface.SetDrawColor(255, 255, 255, 255)
		surface.DrawTexturedRect(ScrW() - 290, ScrH() - 50, 512, 32) 
		if clipSize > 0 then
			draw.RoundedBox(6, ScrW() - 227, ScrH() - 40, clipSize / prim.ClipSize * 193, 14, Color(204, 85, 0, 240))
		end
		draw.SimpleTextOutlined(clipSize.."/"..prim.ClipSize, "Default", ScrW() - 132, ScrH() - 34, Color(255, 255, 255, 255), 1, 1, 1, Color(0, 0, 0, 255))
	end	
	
	
	if GetGlobalBool( "voteSkipPassed") == true and whatmode == "Build" then
		draw.SimpleTextOutlined("Vote Skip Passed! Round Ending in: "..GetGlobalInt("buildtime"),"ClassNameLarge",ScrW()*0.5,80,Color(255,255,255,255),1,1,2,Color(0,0,0,255))
	end

if ballid then
		ball = ents.GetByIndex(ballid)
	else
		ball = nil
end
if ball then
end
end
hook.Add( "HUDPaint", "FWHud", Hud )

function ShowHidePropInfo()
	showPropInfo =! showPropInfo
	LocalPlayer():ChatPrint( "ShowPropInfo = " .. tostring( showPropInfo ) )
end
concommand.Add("propInfo", ShowHidePropInfo)


ball = nil
function GM:Initialize()
end

function GM:SpawnMenuOpen()
	return false
end

function GM:PostDrawViewModel( vm, ply, weapon )
  if ( weapon.UseHands || !weapon:IsScripted() ) then
    local hands = LocalPlayer():GetHands()
    if ( IsValid( hands ) ) then hands:DrawModel() end
  end
end

function draw.BlackOut(x,y,width,height)
	surface.SetDrawColor(0,0,0,255)
	surface.DrawOutlinedRect(x,y,width ,height)
	surface.DrawOutlinedRect(x-1,y-1,width + 2,height + 2)
	surface.DrawOutlinedRect(x+1,y+1,width - 2,height - 2)
end

function surface.GTW(txt,fnt)
	surface.SetFont(fnt)
	local w,h = surface.GetTextSize(txt)

	return w,h
end

function CreateMenu()
	if !ValidPanel(g_fwMenu) then
		g_fwMenu = vgui.Create("fw_menu")
		g_fwMenu:Center()
		g_fwMenu:SetVisible(false) --Little hacky so the next thing works good :D
	end

	g_fwMenu:SetVisible(!g_fwMenu:IsVisible())
	if !g_fwMenu:IsVisible() then RememberCursorPosition() end
	gui.EnableScreenClicker(g_fwMenu:IsVisible())
	if g_fwMenu:IsVisible() then RestoreCursorPosition() end
end
usermessage.Hook( "showhelp", CreateMenu )

net.Receive("voteSkipPassed", function(len)
	local obj = CreateSound(LocalPlayer(),"ambient/alarms/alarm_citizen_loop1.wav")
	obj:Play()
	timer.Create( "voteskipWarning", 1, 5, function() obj:Play() end)
end)

net.Receive("freezeCamSound", function(len)
	surface.PlaySound('misc/freeze_cam.wav')
end)

net.Receive("chatprint", function(len)
	local r = net.ReadInt(10)
	local g = net.ReadInt(10)
	local b = net.ReadInt(10)
	local color = Color( r, g, b )
	local text = net.ReadString()
	
	chat.AddText( color, text )
end)

usermessage.Hook("SetCanJoinTeam", function(um) canJoinTeam = um:ReadBool() end)