local endMenu;
local maps = {}

net.Receive("gameOver", function(len)
	ENDGAME = net.ReadInt(10)
	CreateEndGame()
	
	for i,v in pairs(hook.GetTable()["HUDPaint"]) do hook.Remove("HUDPaint",i) end
	--re-add the chat
	hook.Add("HUDPaint","DrawChat",ChatPaint)
end)

net.Receive("getMapVote", function(len)
	local int = net.ReadInt(10)
	local b = endMenu.buttons[maps[int]]
	b.numVotes = b.numVotes + net.ReadInt(10)
	b:SetText(mapList[int][1].." - "..b.numVotes)
end)

net.Receive("getEndVar", function(len)
	endMenu:AddEndVar(net.ReadInt(10),	player.GetByID(net.ReadInt(10)), net.ReadString())
end)


//GetGlobalInt("roundEnd")
local PANEL = {}
function PANEL:Init()
  self.winner = ENDGAME;
  self:SetSize(640, 485)
  self:CenterHorizontal()
  self:AlignTop()
  self.list = vgui.Create("DPanelList", self)
  self.list:StretchToParent(5, 100, 5, 150)--100)
  self.list:EnableHorizontal(true)
  self.list.Paint = function() draw.RoundedBox(0, 0, 0, self.list:GetWide(), self.list:GetTall(), Color(0, 0, 0, 255)) end
  gui.EnableScreenClicker(true)
end
function PANEL:Paint()
  draw.RoundedBox(10, 0, 0, self:GetWide(), self:GetTall(), Color(0, 0, 0, 250))
  draw.RoundedBox(10, 5, 5, self:GetWide()-10, self:GetTall()-10, team.GetColor(self.winner))
  local disp = GetGlobalInt("roundEnd")
  if disp < 1 then disp = "Changing Map..." end
  draw.SimpleTextOutlined(disp, "ClassNameLarge", self:GetWide()*0.5, self:GetTall()-125, Color(255, 255, 255, 255), 1, 1, 2, Color(0, 0, 0, 255))
  draw.SimpleTextOutlined(team.GetName(self.winner).." has won the game!", "ClassNameLarge", self:GetWide()*0.5, 30, Color(255, 255, 255, 255), 1, 1, 2, Color(0, 0, 0, 255))
  
  draw.RoundedBox(0, 0, 70, self:GetWide(), 100, Color(0, 0, 0, 250))
  draw.SimpleText("This Round...", "ClassName", 10, 85, team.GetColor(self.winner), 0, 1)
end

function PANEL:AddEndVar(id, pl, data)
  local p = vgui.Create("DPanel")
  p:SetSize(self.list:GetWide()/3, self.list:GetTall()/4)
  p.lbl = Label(EndGameStats[id].Text(pl, data), p)
  p.lbl:SetPos(64, 5)
  p.lbl:SetWrap(true)
  p.lbl:SetSize(p:GetWide()-80, p:GetTall()-10)
  self.list:AddItem(p)
end
vgui.Register("EndGameMenu", PANEL, "DPanel")

function CreateEndGame()
	endMenu = vgui.Create("EndGameMenu")
end
//
net.Receive("getMaps", function(len)
    endMenu.buttons = {}
  local wide = (endMenu:GetWide() - 10) / math.min(5, table.getn(mapList))
  for i=1, math.min(5, table.getn(mapList)) do
    local int = net.ReadInt(10)
    maps[int] = i
    local image = "darkland/map_images/image_not_found"
    if file.Exists("materials/darkland/map_images/"..mapList[int][1]..".vtf", "GAME") then
      image = "darkland/map_images/"..mapList[int][1]
    end
    local myImage = vgui.Create("DImageButton", endMenu)
    myImage:SetImage( image )
    myImage:SetSize(128, 72)
    myImage:SetPos(4 + (i - 1) * wide, endMenu:GetTall() - 100)
    myImage.DoClick = function() RunConsoleCommand("mapVote", int) end
    local bigImage
    myImage.OnCursorEntered = function(btn) 
      bigImage = vgui.Create("DImage", endMenu)
      bigImage:SetImage(image)
      bigImage:SetSize(512, 288) 
      bigImage:SetPos(endMenu:GetWide() / 2-bigImage:GetWide() / 2, 50)
    end
    myImage.OnCursorExited = function(btn) 
      bigImage:Remove( )
    end  

    local b = vgui.Create("DVoteButton", endMenu)
    b:SetSize(wide, 30)
    b:SetPos(5 + (i - 1) * wide, endMenu:GetTall() - 40)
    
    b.mapType = maps[i]
    b.numVotes = 0
    b.DoClick = function() RunConsoleCommand("mapVote", int) end
    b:SetText(mapList[int][1].." - "..b.numVotes)
    table.insert(endMenu.buttons, b)
  end
end)

local PANEL = {}
function PANEL:Paint()
	draw.RoundedBox(2,0,0,self:GetWide(),self:GetTall(),team.GetColor(self:GetParent().winner))
	draw.RoundedBox(2,1,1,self:GetWide()-2,self:GetTall()-2,Color(50,50,50,250))
end
vgui.Register("DVoteButton",PANEL,"DButton")