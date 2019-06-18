local PANEL = {}
local memberships = {}
memberships[1] = 
{
  1, 
  1, 
  "$0", 
  "$"..KILL_MONEY, 
  "$"..WIN_MONEY, 
  "No", 
  "No", 
  "N/A"
} 
memberships[2] = 
{
  2, 
  2, 
  "+ $"..PREM_BALL_BONUS.." per second", 
  "$"..KILL_MONEY + 10, 
  "$"..WIN_MONEY*1.25, 
  "No", 
  "No", 
  "$5 USD"
}
memberships[3] = 
{
  4, 
  4, 
  "+ $"..PLAT_BALL_BONUS.." per second", 
  "$"..KILL_MONEY + 20, 
  "$"..WIN_MONEY*1.5, 
  "Yes", 
  "Yes", 
  "$15 USD"
}

local m_name = {"Regular", "Premium", "Platinum"}
local m_desc = {"Voteskips", "Votemaps", "Ball Holding Bonus", "Money per kill", "Win Money", "Fly in build", "Prop Snap", "Donation Needed"}
local dollas = "You can also receive $20, 000 FW Cash for each $1 USD you donate."

function PANEL:Init()
  self:SetSize(900, 500)
  // Disabled donations tab until we know what to do with it.
    self.tabNames = {"Help", "Classes", "Upgrades"/*, "Donations"*/, "Options"}
    self.selectedClass = 1
    self.selectedSkill = "speed_limit"
    --Hold all the items in a 1D table and loop to set visibility to false/true...
    self.dispItems = {}
    self.currentTab = 1

    local oldButt
    for i, v in pairs(self.tabNames) do
      local button = vgui.Create("Button", self)
      local xPos = 50
      if oldButt then xPos = oldButt:GetPos()+oldButt:GetWide()+70 end
      button:SetPos(xPos, 90)
      button.col = Color(255, 255, 255, 255)
      button:SetText("")
      button.Paint = function() 
        local col = color_white
        if self.currentTab == i then col = Color(100, 100, 100, 255) end

        draw.SimpleText(v, "ClassName", button:GetWide()*0.5, button:GetTall()*0.5, col, 1, 1) 
      end
      surface.SetFont("ClassName")
      local x, h = surface.GetTextSize(v)
      button:SetSize(x, h)
      button.OnMousePressed = function() self.currentTab = i self:RefreshTabs() end
      button:SetCursor("hand")
      oldButt = button
    end

    local close = vgui.Create("Button", self)
    close:SetPos(689, 87)
    close:SetSize(200, 33)
    close:SetText("")
    close.Paint = function()
      local vData = {}
      vData[1] = {}
      vData[1].x = 21
      vData[1].y = 0

      vData[2] = {}
      vData[2].x = 191
      vData[2].y = 0

      vData[3] = {}
      vData[3].x = 191
      vData[3].y = 28

      vData[4] = {}
      vData[4].x = 3
      vData[4].y = 28
      local col = team.GetColor(Me:Team())
      local amt = 90
      if close.Hovered then amt = 110 end
      surface.SetDrawColor(math.Clamp(amt+col.r, 0, 255), math.Clamp(amt+col.g, 0, 255), math.Clamp(amt+col.b, 0, 255), 100)
      surface.DrawPoly(vData)
      draw.SimpleText("Close", "ClassName", close:GetWide()*0.5, close:GetTall()*0.43, Color(255, 255, 255, 255), 1, 1)
    end
    close.DoClick = function() self:SetVisible(false) RememberCursorPosition() gui.EnableScreenClicker(false) end

    --HELP TAB
    local helpPanel = vgui.Create("DPanelList", self)
    helpPanel.tab = 1
    helpPanel:StretchToParent(20, 125, 20, 20)
    //

    function helpPanel:Think()
      if LocalPlayer():GetNWBool("onteam")==true then
        helpPanel:EnableVerticalScrollbar(true)
      end
    end

    local p = vgui.Create("Panel")
    p:StretchToParent(0, 0, 0, 0)
    p:SetTall(875)

    p.Paint = function()
      local col = team.GetColor(Me:Team())

      draw.RoundedBox(2, 0, 0, helpPanel:GetWide(), p:GetTall(), Color(math.Clamp(90+col.r, 0, 255), math.Clamp(90+col.g, 0, 255), math.Clamp(90+col.b, 0, 255), 100))

      if !DM_MODE and Me:GetNWInt("joinTime") + 30 > CurTime() and canJoinTeam then

        local x, y = helpPanel:GetWide()/2, helpPanel:GetTall()/2
        surface.SetDrawColor( 0, 0, 0, 255 )
        surface.DrawLine(0, y, x-161, y) -- left line of red button
        surface.DrawLine(0, y+60, x-161, y+60) -- left line of blue button
        surface.DrawOutlinedRect(x-161-20, y-26, 152, 52) -- red
        surface.DrawOutlinedRect(x-161-20, y-26+60, 152, 52) -- blue
        surface.DrawLine(x-29, y, x+29, y) -- right line of red button and left of yellow button
        surface.DrawLine(x-29, y+60, x+29, y+60) -- right line of blue button and left of green button
        surface.DrawOutlinedRect(x+29, y-26, 152, 52) -- yellow
        surface.DrawOutlinedRect(x+29, y-26+60, 152, 52) -- green
        surface.DrawLine(x+180, y, x*2, y) -- right line of yellow button
        surface.DrawLine(x+180, y+60, x*2, y+60) -- right line of green button

        draw.SimpleText("You have "..string.ToMinutesSeconds(Me:GetNWInt("joinTime")-CurTime()+30).." seconds to join a team", "ClassName", helpPanel:GetWide()/2, 10, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
      else


        --------------------------
        --START F1 TEXT
        --------------------------

        draw.SimpleTextOutlined("What is the objective of fortwars?", "ClassName", 10, 10, Color(255, 255, 255, 255), 0, 3, 1, Color(0, 0, 0, 255))

        draw.DrawText([[
		The objective of fortwars is to hold the ball for 5 minutes in order to win the round for your team. 
		Each round starts with build mode, in which you and your team work together to create a strong base to hold the ball in. When fight mode 
		starts, players of each team fight with their various classes over the ball.]], "Default", 10, 40, Color(255, 255, 255, 255), 0)


        draw.SimpleTextOutlined("How do I earn money?", "ClassName", 10, 100, Color(255, 255, 255, 255), 0, 3, 1, Color(0, 0, 0, 255))

        draw.DrawText([[
		There are various ways to earn money. You can earn money from killing an enemy or getting an assist, holding the 
		ball, and winning rounds. Money can be spent on building a base or buying different classes and upgrades in the F1 menu.]], "Default", 10, 130, Color(255, 255, 255, 255), 0)

        draw.SimpleTextOutlined("What should I buy?", "ClassName", 10, 170, Color(255, 255, 255, 255), 0, 3, 1, Color(0, 0, 0, 255))

        draw.DrawText([[
		You start off with $12k and the defualt human class. You have a few choices in spending your money. Firstly, you can 
		buy the cost efficient Gunner for $6k, with a deagle doing significantly more damage than the Human's glock. You will have an extra $6k 
		after buying gunner, so you can either save that money or use it to buy an upgrade, or build bases. Another option is to buy a more 
		expensive class, for $10k you can get Raider. Raider has a mac-10 and has a quick movement speed. This is a good offesnive class, and can 
		later be upgraded with his special, which triples Raider's movement speed for a period of time. For the full $12k you start with, the 
		defensive oriented Guardian can be purchased. Guardian uses a double barrel shotgun, and if used in a close quarters situation such as in 
		a base, this class is very deadly. Lastly, you can stick with human for a while to earn some cash, saving for; Ninja for $15k, a quick, agile 
		class that can jump high and easily retrieve the ball, or Hitman for $20k, a sniper able to do up to 140 damage with a headshot.]], "Default", 10, 200, Color(255, 255, 255, 255), 0)

        draw.SimpleTextOutlined("Rules:", "ClassName", 10, 300, Color(255, 255, 255, 255), 0, 3, 1, Color(0, 0, 0, 255))

        draw.DrawText([[
		
		• Do not spam props to intentionally use up all of your team's props, especially if someone is trying to build a base. 
		(This is mostly directed at people who know how to play the game but are trolling. If a new person is doing this, just let them know
		that they are wasting all the props.)

		• Don't grief/minge. This includes fucking with someone's base, and setting your spawn in unfavorable places (particularly in someone 
		elses base when they don't want you to). Just use common sense and don't be a dick. Again, new people may not know that they are doing 
		something wrong, so let them know if they are.

		• Don't push props through the build walls.

		• Don't push yourself through the build walls (We will sometimes allow this in good spirits, it's not really a big deal if you aren't 
		fucking with other people, and rather just having fun).

		• Don't prop push people (Again, we will sometimes allow this if it's just in good spirits or if it's just a friend, not really a big deal).

		• Certain exploits are allowed to an extent. For example, using parts of the map to make an overpowered base is allowed, closed bases 
		are allowed.

		• Do not impersonate staff, other users, or bots.

		• Do not spam chat/voice.

		• No children talking on the mic, use the chat instead please.

		• Don't be toxic or harass other users.

		• Freedom of speech applies here. Swearing/racism is allowed, just don't be too excessive. Again, don't be targeting/harassing other 
		people though.

		• Do not post personal information such as phone numbers.
		
		
		]], "Default", 10, 320, Color(255, 255, 255, 255), 0)	




        draw.SimpleTextOutlined("Chat Commands:", "ClassName", 10, 700, Color(255, 255, 255, 255), 0, 3, 1, Color(0, 0, 0, 255))

        draw.DrawText([[
		/givemoney name amount  -  Gives a specified amount of money to a player if they are on the server.
		/voteskip  -  Vote to skip buildmode.  Regular members get 1 voteskip, Premium get 2, Platinum get 4.
		/resetspawn  -  Resets your current spawnpoint back to a default spawn.  Works in both build and fight mode.
		/stats - Prints your stats to your chat window. (Or you can use the scoreboard)
		/pm name message - PMs a player if they are on the server.
		/r message - Replies to the last pm sent.]], "Default", 10, 730, Color(255, 255, 255, 255), 0)


        --------------------------
        --END F1 TEXT
        --------------------------
      end
    end

    helpPanel:AddItem(p)

    local btnChooseRedTeam  = vgui.Create("Button", self)
    btnChooseRedTeam:SetPos(helpPanel:GetWide()/2-160, helpPanel:GetTall()/2-25+125)
    btnChooseRedTeam:SetSize(150, 50)
    btnChooseRedTeam:SetText("")
    btnChooseRedTeam.Paint = function()  
      if DM_MODE or Me:GetNWInt("joinTime") + 30 < CurTime() or !canJoinTeam then
        btnChooseRedTeam:SetCursor("arrow")
        return true
      else
        btnChooseRedTeam:SetCursor("hand")
      end
      local col = team.GetColor(TEAM_RED)
      local amt = 0
      if btnChooseRedTeam.Hovered then amt = 60 end
      if !TeamInfo[TEAM_RED] then
        btnChooseRedTeam:SetCursor("arrow")
        col = Color(171, 171, 171, 255)
        amt = 0
      end

      draw.RoundedBox(2, 0, 0, btnChooseRedTeam:GetWide(), btnChooseRedTeam:GetTall(), Color(math.Clamp(amt+col.r, 0, 255), math.Clamp(amt+col.g, 0, 255), math.Clamp(amt+col.b, 0, 255), col.a))
      draw.SimpleText("Red Team", "ClassName", btnChooseRedTeam:GetWide()*0.5, btnChooseRedTeam:GetTall()*0.5, Color(255, 255, 255, 255), 1, 1)
    end
    btnChooseRedTeam:SetVisible(true)
    btnChooseRedTeam:SetCursor("hand")

    btnChooseRedTeam.DoClick = function() 
      RunConsoleCommand("chooseteam", TEAM_RED)
      timer.Simple(.2, function()
          if tonumber(MenuOnSpawn:GetInt()) == 0 and LocalPlayer():GetNWBool("onteam") == true then
            self:SetVisible(false) 
            RememberCursorPosition()
            gui.EnableScreenClicker(false)
          end
        end)
    end

    btnChooseRedTeam.tab = 1
    table.insert(self.dispItems, btnChooseRedTeam)

    local btnChooseBlueTeam  = vgui.Create("Button", self)
    btnChooseBlueTeam:SetPos(helpPanel:GetWide()/2-160, helpPanel:GetTall()/2-25+125+ 60)
    btnChooseBlueTeam:SetSize(150, 50)
    btnChooseBlueTeam:SetText("")
    btnChooseBlueTeam.Paint = function()
      if DM_MODE or Me:GetNWInt("joinTime")+ 30 < CurTime() or !canJoinTeam then
        btnChooseBlueTeam:SetCursor("arrow")
        return true
      else
        btnChooseBlueTeam:SetCursor("hand")
      end
      local col = team.GetColor(TEAM_BLUE)
      local amt = 0
      if btnChooseBlueTeam.Hovered then amt = 60 end
      if !TeamInfo[TEAM_BLUE] then
        btnChooseBlueTeam:SetCursor("arrow")
        col = Color(171, 171, 171, 255)
        amt = 0
      end
      draw.RoundedBox(2, 0, 0, btnChooseBlueTeam:GetWide(), btnChooseBlueTeam:GetTall(), Color(math.Clamp(amt+col.r, 0, 255), math.Clamp(amt+col.g, 0, 255), math.Clamp(amt+col.b, 0, 255), col.a))
      draw.SimpleText("Blue Team", "ClassName", btnChooseBlueTeam:GetWide()*0.5, btnChooseBlueTeam:GetTall()*0.5, Color(255, 255, 255, 255), 1, 1)
    end
    btnChooseBlueTeam:SetVisible(true)
    btnChooseBlueTeam.DoClick = function() 
      RunConsoleCommand("chooseteam", TEAM_BLUE)
      timer.Simple(.2, function()
          if tonumber(MenuOnSpawn:GetInt()) == 0 and LocalPlayer():GetNWBool("onteam") == true then
            self:SetVisible(false) 
            RememberCursorPosition()
            gui.EnableScreenClicker(false)
          end
        end)
    end
    btnChooseBlueTeam:SetCursor("hand")
    btnChooseBlueTeam.tab = 1
    table.insert(self.dispItems, btnChooseBlueTeam)

    local btnChooseYellowTeam  = vgui.Create("Button", self)
    btnChooseYellowTeam:SetPos(helpPanel:GetWide()/2+50, helpPanel:GetTall()/2-25+125)
    btnChooseYellowTeam:SetSize(150, 50)
    btnChooseYellowTeam:SetText("")
    btnChooseYellowTeam.Paint = function()
      if DM_MODE or Me:GetNWInt("joinTime") + 30 < CurTime() or !canJoinTeam then
        btnChooseYellowTeam:SetCursor("arrow")
        return true
      else
        btnChooseYellowTeam:SetCursor("hand")
      end
      local col = team.GetColor(TEAM_YELLOW)
      local amt = 0
      if btnChooseYellowTeam.Hovered then amt = 60 end
      if !TeamInfo[TEAM_YELLOW] then
        btnChooseYellowTeam:SetCursor("arrow")
        col = Color(171, 171, 171, 255)
        amt = 0
      end
      draw.RoundedBox(2, 0, 0, btnChooseYellowTeam:GetWide(), btnChooseYellowTeam:GetTall(), Color(math.Clamp(amt+col.r, 0, 255), math.Clamp(amt+col.g, 0, 255), math.Clamp(amt+col.b, 0, 255), col.a))
      draw.SimpleText("Yellow Team", "ClassName", btnChooseYellowTeam:GetWide()*0.5, btnChooseYellowTeam:GetTall()*0.5, Color(255, 255, 255, 255), 1, 1)
    end
    btnChooseYellowTeam:SetVisible(true)
    btnChooseYellowTeam.DoClick = function() 
      RunConsoleCommand("chooseTeam", TEAM_YELLOW) 
      timer.Simple(.2, function()
          if tonumber(MenuOnSpawn:GetInt()) == 0 and LocalPlayer():GetNWBool("onteam") == true then
            self:SetVisible(false) 
            RememberCursorPosition()
            gui.EnableScreenClicker(false)
          end
        end)  
    end
    btnChooseYellowTeam:SetCursor("hand")
    btnChooseYellowTeam.tab = 1
    table.insert(self.dispItems, btnChooseYellowTeam)

    local btnChooseGreenTeam  = vgui.Create("Button", self)
    btnChooseGreenTeam:SetPos(helpPanel:GetWide()/2+50, helpPanel:GetTall()/2-25+125+ 60)
    btnChooseGreenTeam:SetSize(150, 50)
    btnChooseGreenTeam:SetText("")
    btnChooseGreenTeam.Paint = function()
      if DM_MODE or Me:GetNWInt("joinTime") + 30 < CurTime() or !canJoinTeam then
        btnChooseGreenTeam:SetCursor("arrow")
        return true
      else
        btnChooseGreenTeam:SetCursor("hand")
      end
      local col = team.GetColor(TEAM_GREEN)
      local amt = 0
      if btnChooseGreenTeam.Hovered then amt = 60 end
      if !TeamInfo[TEAM_GREEN] then
        btnChooseGreenTeam:SetCursor("arrow")
        col = Color(171, 171, 171, 255)
        amt = 0
      end

      draw.RoundedBox(2, 0, 0, btnChooseGreenTeam:GetWide(), btnChooseGreenTeam:GetTall(), Color(math.Clamp(amt+col.r, 0, 255), math.Clamp(amt+col.g, 0, 255), math.Clamp(amt+col.b, 0, 255), col.a))
      draw.SimpleText("Green Team", "ClassName", btnChooseGreenTeam:GetWide()*0.5, btnChooseGreenTeam:GetTall()*0.5, Color(255, 255, 255, 255), 1, 1)
    end
    btnChooseGreenTeam:SetVisible(true)
    btnChooseGreenTeam.DoClick = function() 
      RunConsoleCommand("chooseTeam", TEAM_GREEN)  
      timer.Simple(.2, function()
          if tonumber(MenuOnSpawn:GetInt()) == 0 and LocalPlayer():GetNWBool("onteam") == true then
            self:SetVisible(false) 
            RememberCursorPosition()
            gui.EnableScreenClicker(false)
          end
        end)
    end
    btnChooseGreenTeam:SetCursor("hand")
    btnChooseGreenTeam.tab = 1
    table.insert(self.dispItems, btnChooseGreenTeam)

    table.insert(self.dispItems, helpPanel)

    -- Classes
    Me = LocalPlayer()

    local classesList = vgui.Create("DPanelList", self)
    classesList:StretchToParent(20, 125, nil, 20)
    classesList.tab = 2
    classesList:SetSpacing(2)
    classesList:SetWide(250)
    classesList:EnableVerticalScrollbar()
    for i, v in SortedPairsByMemberValue( Classes, "COST", false ) do
      local p = vgui.Create("Panel")
      p.OnCursorEntered = function() p.Hovered = true end
      p.OnCursorExited = function() p.Hovered = false end
      p.OnMousePressed = function()  
        if self.selectedClass == i then 
          if myclasses[self.selectedClass] then 
            RunConsoleCommand("fwclass", self.selectedClass) 
          end 
        else 
          self.selectedClass = i 
        end 
      end
      p:SetTall(30)
      p.Paint = function()
        local amt = 90
        if p.Hovered then amt = 110 end
        if i == self.selectedClass then amt = 60 end
        local col = team.GetColor(Me:Team())
        draw.RoundedBox(4, 0, 0, p:GetWide(), p:GetTall(), Color(math.Clamp(amt+col.r, 0, 255), math.Clamp(amt+col.g, 0, 255), math.Clamp(amt+col.b, 0, 255), 255))
        draw.SimpleTextOutlined(v.NAME, "ClassName", p:GetWide()*0.5, p:GetTall()*0.5, Color(255, 255, 255, 255), 1, 1, 1, Color(0, 0, 0, 255))
      end
      classesList:AddItem(p)
    end
    table.insert(self.dispItems, classesList)

    local classPanel = vgui.Create("DPanel", self)
    classPanel:StretchToParent(280, 125, 20, 60)
    classPanel.tab = 2
    classPanel.Paint = function()
      local tbl = Classes[self.selectedClass]
      draw.RoundedBox(0, 0, 0, classPanel:GetWide(), classPanel:GetTall(), Color(50, 50, 50, 200))
      draw.SimpleText(tbl.NAME, "ClassNameLarge", classPanel:GetWide()*0.5, 20, Color(0, 0, 0, 255), 1, 1)
      draw.DrawText(util.WordWrap("About this class: "..tbl.DESCRIPTION, "Default", 1050), "Default", 10, 40, Color(255, 255, 255, 255), 0, 1)
      draw.SimpleText("Speed:\t\t"..tbl.SPEED, "ClassNameSmall", 10, 100, Color(255, 255, 255, 255), 0, 1)
      draw.SimpleText("Health:\t\t"..tbl.HEALTH, "ClassNameSmall", 10, 120, Color(255, 255, 255, 255), 0, 1)
      if Classes[self.selectedClass].SPECIALABILITY then -- is there a special ability for this class
        draw.SimpleText("Special Ability:\t\t", "ClassNameSmall", 10, 140, Color(255, 255, 255, 255), 0, 1)
        local str="Free"

        if !table.HasValue( myspecials, self.selectedClass ) then
          if tbl.SPECIALABILITY_COST then
            str=tbl.SPECIALABILITY_COST
          end
          if cash >= (tbl.SPECIALABILITY_COST or 100000000) then -- draw it red this is for neo/pred
            draw.SimpleText("Special Ability Price:\t\t"..str, "ClassNameSmall", 10, 200, Color(0, 255, 0, 255), 0, 1)
          else
            draw.SimpleText("Special Ability Price:\t\t"..str, "ClassNameSmall", 10, 200, Color(255, 0, 0, 255), 0, 1)
          end
        else
          draw.SimpleText("You already have this special ability.", "ClassNameSmall", 10, 200, Color(255, 0, 0, 255), 0, 1)
        end
        draw.DrawText("\t             	"..Classes[self.selectedClass].SPECIALABILITY, "Default", 10, 134, Color(255, 255, 255, 255), ALIGN_LEFT)
        --draw.SimpleText("Special Ability Price:\t\t"..str, "ClassNameSmall", 10, 200, Color(255, 255, 255, 255), 0, 1)
      end

      local col = Color(255, 0, 0, 255)
      if cash >= tbl.COST then col = Color(0, 255, 0, 255) end
      if table.HasValue(myclasses, self.selectedClass) then
        draw.SimpleText("Class Price: You already have this class\t\t\t", "ClassNameSmall", 10, 225, Color(255, 0, 0, 255), 0, 1)
      else
        draw.SimpleText("Class Price:\t\t\t"..tbl.COST, "ClassNameSmall", 10, 225, col, 0, 1)
      end
    end
    local model = vgui.Create("DModelPanel", classPanel)
    model:StretchToParent(classPanel:GetWide()-classPanel:GetTall(), 0, 0, -50)
    model.currModel = self.selectedClass
    model:SetCamPos(Vector(75, -20, 35))
    model:SetLookAt(Vector(0, -20, 35))
    model:SetModel(Classes[1].MODEL)
    model.Think = function() 
      if model.currModel != self.selectedClass then 
        model:SetModel(Classes[self.selectedClass].MODEL)
        model.currModel = self.selectedClass 
      end
    end
    table.insert(self.dispItems, classPanel)

    local chooseclass = vgui.Create("Button", self)  
    local btnSpecialAbility = vgui.Create("Button", self)
    btnSpecialAbility:StretchToParent(280+classPanel:GetWide()/2+10, self:GetTall()-50, 20, 20)
    btnSpecialAbility:SetText("")
    btnSpecialAbility.Paint = function()
      if self.currentTab != 2 then return end
      local col = team.GetColor(Me:Team())
      local amt = 90
      if btnSpecialAbility.Hovered then 
        amt = 110 
      end
      draw.RoundedBox(2, 0, 0, btnSpecialAbility:GetWide(), btnSpecialAbility:GetTall(), Color(math.Clamp(amt+col.r, 0, 255), math.Clamp(amt+col.g, 0, 255), math.Clamp(amt+col.b, 0, 255), 100))
      draw.SimpleText("Buy Special Ability", "ClassName", btnSpecialAbility:GetWide()*0.5, btnSpecialAbility:GetTall()*0.5, Color(255, 255, 255, 255), 1, 1)
    end

    btnSpecialAbility:SetVisible(false)
    btnSpecialAbility.DoClick = function() RunConsoleCommand("buyspecial", self.selectedClass)  end
    btnSpecialAbility:SetCursor("hand")
    btnSpecialAbility.tab = 2
    chooseclass:StretchToParent(280, self:GetTall()-50, 20, 20)
    chooseclass:SetText("")
    chooseclass.Paint = function()

      if table.HasValue( myclasses, self.selectedClass ) and Classes[self.selectedClass].SPECIALABILITY and !table.HasValue( myspecials, self.selectedClass ) then -- show special ability buy button if they have the class and if the special ability for this class exist
        btnSpecialAbility:SetVisible(true)
        chooseclass:StretchToParent(280, self:GetTall()-50, classPanel:GetWide()/2+20+10, 20)
      else
        btnSpecialAbility:SetVisible(false)
        chooseclass:StretchToParent(280, self:GetTall()-50, 20, 20)
      end
      local col = team.GetColor(Me:Team())
      local amt = 90
      if chooseclass.Hovered then amt = 110 end

      draw.RoundedBox(2, 0, 0, chooseclass:GetWide(), chooseclass:GetTall(), Color(math.Clamp(amt+col.r, 0, 255), math.Clamp(amt+col.g, 0, 255), math.Clamp(amt+col.b, 0, 255), 100))
      local txt = "Buy"
      if table.HasValue(myclasses, self.selectedClass) then txt = "Select" end
      draw.SimpleTextOutlined(txt, "ClassName", chooseclass:GetWide()*0.5, chooseclass:GetTall()*0.5, Color(255, 255, 255, 255), 1, 1, 1, Color(0, 0, 0, 255))
    end
    chooseclass.DoClick = function() RunConsoleCommand("fwclass", self.selectedClass)  end
    chooseclass:SetCursor("hand")
    chooseclass.tab = 2
    table.insert(self.dispItems, chooseclass)

    local chooseskill = vgui.Create("Button", self)
    chooseskill:StretchToParent(280, self:GetTall()-50, 20, 20)
    chooseskill:SetText("")
    chooseskill.Paint = function()
      local txt = "Upgrade"
      if self.selectedSkill then
        if myupgrades[self.selectedSkill] > 4 then 
          chooseskill:SetVisible(false)
          return
        else
          chooseskill:SetVisible(true)
        end
      else
        txt = "Buy"
        if myprops[self.selectedProp] == 1 then
          chooseskill:SetVisible(false)
          return
        else
          chooseskill:SetVisible(true)
        end
      end

      local col = team.GetColor(Me:Team())
      local amt = 90
      if chooseskill.Hovered then amt = 110 end

      draw.RoundedBox(2, 0, 0, chooseskill:GetWide(), chooseskill:GetTall(), Color(math.Clamp(amt+col.r, 0, 255), math.Clamp(amt+col.g, 0, 255), math.Clamp(amt+col.b, 0, 255), 100))

      draw.SimpleTextOutlined(txt, "ClassName", chooseskill:GetWide()*0.5, chooseskill:GetTall()*0.5, Color(255, 255, 255, 255), 1, 1, 1, Color(0, 0, 0, 255))
    end
    chooseskill.DoClick = function()
      if self.selectedSkill then
        RunConsoleCommand("fwupgrade", self.selectedSkill) 
      else
        RunConsoleCommand("buyprop", self.selectedProp)
      end
    end
    chooseskill:SetCursor("hand")
    chooseskill.tab = 3
    table.insert(self.dispItems, chooseskill)

    local skillList = vgui.Create("DPanelList", self)
    skillList:StretchToParent(20, 125, nil, 20)
    skillList.tab = 3
    skillList:SetSpacing(2)
    skillList:SetWide(250)
    skillList:EnableVerticalScrollbar()
    
    for i, v in pairs(Skills) do
      local p = vgui.Create("Panel")
      p.OnCursorEntered = function() p.Hovered = true end
      p.OnCursorExited = function() p.Hovered = false end
      p.OnMousePressed = function() 
        self.selectedSkill = i 
        self.selectedProp = nil 
        chooseskill:SetVisible(true)
        propModel:SetVisible(false)
      end
      p:SetTall(30)
      p.Paint = function()
        local amt = 90
        if p.Hovered then amt = 110 end
        if i == self.selectedSkill then amt = 60 end
        local col = team.GetColor(Me:Team())
        draw.RoundedBox(4, 0, 0, p:GetWide(), p:GetTall(), Color(math.Clamp(amt+col.r, 0, 255), math.Clamp(amt+col.g, 0, 255), math.Clamp(amt+col.b, 0, 255), 255))
        draw.SimpleTextOutlined(v.NAME, "ClassName", p:GetWide()*0.5, p:GetTall()*0.5, Color(255, 255, 255, 255), 1, 1, 1, Color(0, 0, 0, 255))

      end
      skillList:AddItem(p)
    end


    for k, v in pairs(buyableProps) do
      local p = vgui.Create("Panel")
      p.OnCursorEntered = function() p.Hovered = true end
      p.OnCursorExited = function() p.Hovered = false end
      p.OnMousePressed = function() 
        self.selectedProp = k 
        self.selectedSkill = nil 
        propModel:SetVisible(true)
        chooseskill:SetVisible(true)
        propModel:SetModel(buyableProps[self.selectedProp].MODEL)
      end
      p:SetTall(30)
      p.Paint = function()
        local amt = 90
        if p.Hovered then amt = 110 end
        if k == self.selectedProp then amt = 60 end
        local col = team.GetColor(Me:Team())
        draw.RoundedBox(4, 0, 0, p:GetWide(), p:GetTall(), Color(math.Clamp(amt+col.r, 0, 255), math.Clamp(amt+col.g, 0, 255), math.Clamp(amt+col.b, 0, 255), 255))
        draw.SimpleTextOutlined(v.NAME, "ClassName", p:GetWide()*0.5, p:GetTall()*0.5, Color(255, 255, 255, 255), 1, 1, 1, Color(0, 0, 0, 255))
      end
      skillList:AddItem(p)
    end

    -- game modifier
    /*print("", selectedClass)
    if Classes[myClass].SPECIAL_ABILITY != NULL then
      local p = vgui.Create("Panel")
      p.OnCursorEntered = function() p.Hovered = true end
      p.OnCursorExited = function() p.Hovered = false end
      p.OnMousePressed = function() self.selectedSkill = -1 end
      p:SetTall(30)
      p.Paint = function()
        local amt = 90
        if p.Hovered then amt = 110 end
        if i == self.selectedSkill then amt = 60 end
        local col = team.GetColor(Me:Team())
        draw.RoundedBox(4, 0, 0, p:GetWide(), p:GetTall(), Color(math.Clamp(amt+col.r, 0, 255), math.Clamp(amt+col.g, 0, 255), math.Clamp(amt+col.b, 0, 255), 255))
        draw.SimpleTextOutlined("Special Ability", "ClassName", p:GetWide()*0.5, p:GetTall()*0.5, Color(255, 255, 255, 255), 1, 1, 1, Color(0, 0, 0, 255))

      end
      skillList:AddItem(p)
    end*/

    table.insert(self.dispItems, skillList)
    local skillPanel = vgui.Create("DPanel", self)
    skillPanel:StretchToParent(280, 125, 20, 60)
    skillPanel.tab = 3

    skillPanel.Paint = function()
      if self.selectedSkill then -- skill

        local tbl = Skills[self.selectedSkill]

        draw.RoundedBox(0, 0, 0, skillPanel:GetWide(), skillPanel:GetTall(), Color(50, 50, 50, 200))
        draw.SimpleText(tbl.NAME, "ClassNameLarge", skillPanel:GetWide()*0.5, 20, Color(0, 0, 0, 255), 1, 1)
        --color here
        draw.DrawText(util.WordWrap("About this skill: "..tbl.DESCRIPTION, "Default", 1050), "Default", 10, 60, Color(255, 255, 255, 255), 0, 1)

        local col = Color(255, 0, 0, 255)

        if ((myupgrades[self.selectedSkill])+1) <= 5 then

          if cash >= tbl.COST[((myupgrades[self.selectedSkill])+1) or 5] then col = Color(0,255,0,255) end
        end
        if myupgrades[self.selectedSkill] > 4 then
          draw.SimpleText("You own all levels of this upgrade", "ClassName", 10, 190, col, 0, 1)
        else
          draw.SimpleText("Price:\t\t\t"..tbl.COST[(myupgrades[self.selectedSkill])+1], "ClassName", 10, 180, col, 0, 1)
          if !(myupgrades[self.selectedSkill] > 4) then
            draw.SimpleText("Level: "..myupgrades[self.selectedSkill].."/5", "ClassName", 10, 210, col, 0, 1)
          end
        end

        // else self.selectedSkill = 1

      else -- prop
        local tbl = buyableProps[self.selectedProp]
        draw.RoundedBox(0, 0, 0, skillPanel:GetWide(), skillPanel:GetTall(), Color(50, 50, 50, 200))
        draw.SimpleText(tbl.NAME, "ClassNameLarge", skillPanel:GetWide()*0.5, 20, Color(0, 0, 0, 255), 1, 1)
        --draw.DrawText(util.WordWrap("About this prop: ", "Default", 1200), "Default", 10, 60, Color(255, 255, 255, 255), 0, 1)
        local col = Color(255, 0, 0, 255)
        if cash >= tbl.COST and !table.HasValue( myprops, self.selectedProp ) then

          col = Color(0, 255, 0, 255) 
        end
        draw.SimpleText("Health:\t\t\t"..tbl.HEALTH, "ClassName", 10, 180, Color(255, 255, 255, 255), 0, 1)
        if table.HasValue( myprops, self.selectedProp ) then
          draw.SimpleText("You already own this prop", "ClassName", 10, 210, col, 0, 1)
        else
          draw.SimpleText("Price:\t\t\t"..tbl.COST, "ClassName", 10, 210, col, 0, 1)
        end
      end
    end
    table.insert(self.dispItems, skillPanel)

    propModel = vgui.Create("DModelPanel", skillPanel)
    propModel:SetModel("models/fortwars/stairs.mdl")
    propModel:SetVisible(false)
    propModel:SetPos(-75, -40)
    propModel:SetSize(500, 200)
    propModel:SetLookAt(Vector(0, 0, 10))
    propModel:SetCamPos(Vector(0, 250, 60))

    --DONATIONS TAB
    /*local donPanel = vgui.Create("DPanel", self)
    donPanel.tab = 4
    donPanel:StretchToParent(20, 125, 20, 20)
    donPanel.Paint = function()
      local col = team.GetColor(Me:Team())
      draw.RoundedBox(2, 0, 0, donPanel:GetWide(), donPanel:GetTall(), Color(math.Clamp(90+col.r, 0, 255), math.Clamp(90+col.g, 0, 255), math.Clamp(90+col.b, 0, 255), 100))
      local xOff = 15
      local yOff = 15
      local txt = util.WordWrap("Donations go towards running and maintaining the server as well as supporting development of Fortwars. In addition to supporting us you can recieve these perks as well.", "VGUID5", 1000)
      draw.DrawText(txt, "Default", xOff, yOff, Color(255, 255, 255, 255), 0)
      for i, v in pairs(memberships) do
        for e, w in pairs(v) do
          if i == 1 then
            draw.SimpleTextOutlined(w, "Default", xOff+((i) * 140), yOff+(e * 18)+50, Color(255, 150, 45, 255), 0, 1, 1, Color(0, 0, 0, 255))
          elseif i == 2 then
            draw.SimpleTextOutlined(w, "Default", xOff+((i) * 140), yOff+(e * 18)+50, Color(0, 255, 230, 255), 0, 1, 1, Color(0, 0, 0, 255))
          else
            draw.SimpleTextOutlined(w, "Default", xOff+((i) * 140), yOff+(e * 18)+50, Color(0, 255, 0, 255), 0, 1, 1, Color(0, 0, 0, 255))
          end
          --Old way of doing the membership colors.  
          --draw.SimpleText(w, "VGUID5", xOff+((i) * 140), yOff+(e * 18)+50, Color(math.Clamp(255-(i-1)*125, 0, 255), math.Clamp((i-1)*125, 0, 255), 0, 255), 0, 1)  
        end
      end
      for i, v in pairs(m_desc) do
        draw.SimpleTextOutlined(v, "Default", xOff+1, yOff+(i * 18)+50, Color(255, 255, 255, 255), 0, 1, 1, Color(0, 0, 0, 255))
      end
      for i, v in pairs(m_name) do
        draw.SimpleTextOutlined(v, "Default", xOff+((i) * 140)+1, yOff+50, Color(255, 255, 255, 255), 1, 1, 1, Color(0, 0, 0, 255))
      end
      local usd = util.WordWrap(dollas, "Default", donPanel:GetWide()-100)
      draw.DrawText(usd, "Default", xOff, 230, Color(255, 255, 255, 255), 0)
      draw.SimpleText("Join our Discord at https://discord.gg/3uBD8k2 for more info on donations.", "Default", donPanel:GetWide()*0.5+2, donPanel:GetTall()-22, Color(0, 0, 0, 255), 1, 1)
    end

    table.insert(self.dispItems, donPanel)*/


    local optPanel = vgui.Create("DPanel", self)
    optPanel.tab = 4//5
    optPanel:StretchToParent(20, 125, 20, 20)
    optPanel.Paint = function()
      local col = team.GetColor(Me:Team())
      draw.RoundedBox(2, 0, 0, optPanel:GetWide(), optPanel:GetTall(), Color(math.Clamp(90+col.r, 0, 255), math.Clamp(90+col.g, 0, 255), math.Clamp(90+col.b, 0, 255), 100))	
    end

    local sheet = vgui.Create( "DPropertySheet", optPanel )
    sheet:SetPos( -5,-1 ) -- Set the position of the tabs
    sheet:SetSize( optPanel:GetWide(), optPanel:GetTall() )
    sheet.Paint = function() 
      local col = team.GetColor(Me:Team())
      draw.RoundedBox(2, 0, 0, optPanel:GetWide(), optPanel:GetTall(), Color(math.Clamp(70+col.r, 0, 235), math.Clamp(70+col.g, 0, 235), math.Clamp(70+col.b, 0, 235), 0))	
    end

    local panel1 = vgui.Create( "DPanel", sheet )
    panel1.Paint = function() 
      local col = team.GetColor(Me:Team())
      draw.RoundedBox(2, 0, 0, optPanel:GetWide(), optPanel:GetTall(), Color(math.Clamp(90+col.r, 0, 255), math.Clamp(90+col.g, 0, 255), math.Clamp(90+col.b, 0, 255), 0))	
    end


    local info = vgui.Create( "DCheckBoxLabel", panel1 )
    info:SetPos( 25, 25 )
    info:SetText( "Show prop info?" )
    info:SetTooltip("Displays name and steamid of the owner of a prop")

    function info:OnChange( val )
      if val then
        RunConsoleCommand( "propInfo" )
      else
        RunConsoleCommand( "propInfo" )
      end
    end

    local adv = vgui.Create( "DCheckBoxLabel", panel1 )
    adv:SetPos( 25, 75 )
    adv:SetText( "Force advancer crouch?" )
    adv:SetTooltip("When enabled, you are forced to crouch in order to use advancer's special ability.\nHelpful to prevent accidential flying when strafing.")
    adv:SetConVar( "fw_advcrouch" )

    local spawn = vgui.Create( "DCheckBoxLabel", panel1 )
    spawn:SetPos( 25, 125 )
    spawn:SetText( "Open menu on spawn?" )
    spawn:SetTooltip("Decides whether or not the F1 menu will open whenever you spawn.")
    spawn:SetConVar( "fw_menuonspawn" )

    local wep = vgui.Create( "DCheckBoxLabel", panel1 )
    wep:SetPos( 25, 175 )
    wep:SetText( "Spawn holding gravity gun?" )
    wep:SetTooltip("When enabled, you spawn already holding your gravity gun.\nUseful if you plan on grabbing the ball first.")
    wep:SetConVar( "fw_spawnwithgrav" )

    local csound = vgui.Create( "DCheckBoxLabel", panel1 )
    csound:SetPos( 25, 225 )
    csound:SetText( "Play chat tick sounds?" )
    csound:SetConVar( "fw_chatsounds" )

    local zoom = vgui.Create( "DCheckBoxLabel", panel1 )
    zoom:SetPos( 25, 275 )
    zoom:SetText( "Keep zoom after reload" )
    zoom:SetTooltip("When enabled, you will automatically zoom in to your last\nzoom level after reloading.")
    zoom:SetConVar( "fw_zoomaftereload" )

    sheet:AddSheet( "General options", panel1)


    local panel2 = vgui.Create( "DPanel", sheet )
    panel2.Paint = function() 
      local col = team.GetColor(Me:Team())
      draw.RoundedBox(2, 0, 0, optPanel:GetWide(), optPanel:GetTall(), Color(math.Clamp(90+col.r, 0, 255), math.Clamp(90+col.g, 0, 255), math.Clamp(90+col.b, 0, 255), 0))	
    end

    local color = vgui.Create( "DColorMixer", panel2 )
    local w = optPanel:GetWide()
    local h = optPanel:GetTall()

    color:SetSize(w/2, h/1.5)		--Make Mixer fill place of Frame
    color:SetPos((w/2)-30, 25)		--Make Mixer fill place of Frame
    color:SetPalette( true ) 		--Show/hide the palette			DEF:true
    color:SetAlphaBar( true ) 		--Show/hide the alpha bar		DEF:true
    color:SetWangs( true )			--Show/hide the R G B A indicators 	DEF:true
    color:SetColor( string.ToColor( CrosshairColor ) )	--Set the default color
    function color:ValueChanged(color)
      LocalPlayer():ConCommand( "fw_crosshaircolor "..color.r.." "..color.g.." "..color.b.." "..color.a )
    end

    local len = vgui.Create( "DNumSlider", panel2 )
    len:SetPos(25, 25)
    len:SetSize( 300, 100 )
    len:SetText( "Crosshair Length" )
    len:SetToolTip( "Sets the length of your crosshair lines. (Default 20)" )
    len:SetMin( 0 )
    len:SetMax( 1000 )
    len:SetDecimals( 0 )
    len:SetConVar( "fw_crosshairlength" )

    local wid = vgui.Create( "DNumSlider", panel2 )
    wid:SetPos(25, 75)
    wid:SetSize( 300, 100 )
    wid:SetText( "Crosshair Width" )
    wid:SetToolTip( "Sets the width of your crosshair lines. (Default 1)" )
    wid:SetMin( 1 )
    wid:SetMax( 30 )
    wid:SetDecimals( 0 )
    wid:SetConVar( "fw_crosshairwidth" )

    local dot = vgui.Create( "DCheckBoxLabel", panel2 )
    dot:SetPos( 25, 167.5 )
    dot:SetText( "Crosshair dot" )
    dot:SetTooltip("Draw a dot in the middle of your crosshair")
    dot:SetConVar( "fw_crosshairdot" )


    sheet:AddSheet( "Crosshair options", panel2)

    mutemenu = vgui.Create( "DPanel", sheet )
    mutemenu.Paint = function() 
      local col = team.GetColor(Me:Team())
      draw.RoundedBox(2, 0, 0, optPanel:GetWide(), optPanel:GetTall(), Color(math.Clamp(90+col.r, 0, 255), math.Clamp(90+col.g, 0, 255), math.Clamp(90+col.b, 0, 255), 0))	
    end

    local pList = vgui.Create("DListView",mutemenu)
    pList:SetSize(700,325)
    pList:SetPos(5,0)
    pList:Clear()
    pList:AddColumn("Name")
    pList:AddColumn("Muted")
    pList:SetMultiSelect(true)
    pList:SelectFirstItem()

    for i,v in pairs(player.GetAll()) do
      local line
      if v:IsMuted() then
        line =  pList:AddLine(v:Name(),"Muted")
      else
        line =  pList:AddLine(v:Name(),"")
      end
      line.player = v
    end

    local muteButton = vgui.Create("DButton",mutemenu)
    muteButton:SetText("Mute")
    muteButton:SetPos(717, 0)
    muteButton:SetSize(125,30)
    muteButton.DoClick = function()
      local selectedLine = pList:GetLine(pList:GetSelectedLine())
      if selectedPlayer:IsMuted() then
        selectedPlayer:SetMuted(false)
        selectedLine:SetValue(2, "")
        muteButton:SetText("Mute")
      else
        selectedPlayer:SetMuted(true)
        selectedLine:SetValue(2, "Muted")
        muteButton:SetText("Unmute")
      end
    end	

    pList.OnRowSelected = function(panel,lineNum,line) 
      selectedPlayer = line.player
      if selectedPlayer:IsMuted() then
        muteButton:SetText("Unmute")
      else
        muteButton:SetText("Mute")
      end
    end

    pList.DoDoubleClick = function(panel, lineNum, line)
      if selectedPlayer:IsMuted() then
        selectedPlayer:SetMuted(false)
        line:SetValue(2, "")
        muteButton:SetText("Mute")
      else
        selectedPlayer:SetMuted(true)
        line:SetValue(2, "Muted")
        muteButton:SetText("Unmute")
      end
    end

    function mutemenu:updatePList()
      pList:Clear()
      pList:SelectFirstItem()
      for i,v in pairs(player.GetAll()) do
        local line
        if v:IsMuted() then
          line =  pList:AddLine(v:Name(),"Muted")
        else
          line =  pList:AddLine(v:Name(),"")
        end
        line.player = v
      end
    end

    sheet:AddSheet( "Mute options", mutemenu)

    local panel4 = vgui.Create( "DPanel", sheet )
    panel4.Paint = function() 
      local col = team.GetColor(Me:Team())
      draw.RoundedBox(2, 0, 0, optPanel:GetWide(), optPanel:GetTall(), Color(math.Clamp(90+col.r, 0, 255), math.Clamp(90+col.g, 0, 255), math.Clamp(90+col.b, 0, 255), 0))	
    end

    local respawn = vgui.Create( "DButton", panel4 )
    respawn:SetPos( 25, 25 )
    respawn:SetSize( 190, 25 )
    respawn:SetText( "Respawn Ball" )
    function respawn:DoClick()
      RunConsoleCommand( "admincommand", 4 )
    end

    local dm = vgui.Create( "DButton", panel4 )
    dm:SetPos( 25, 60 )
    dm:SetSize( 190, 25 )
    dm:SetText( "Force Fight Mode" )
    function dm:DoClick()
      RunConsoleCommand( "admincommand", 1 )
    end

    local build = vgui.Create( "DButton", panel4 )
    build:SetPos( 25, 95 )
    build:SetSize( 190, 25 )
    build:SetText( "Force Build Mode" )
    function build:DoClick()
      RunConsoleCommand( "admincommand", 2 )
    end

    if LocalPlayer():IsAdmin() then
      sheet:AddSheet( "Admin", panel4)
    end

    table.insert(self.dispItems, optPanel)

    self:RefreshTabs()

  end


--much better :D
  function PANEL:RefreshTabs()
    for i, v in pairs(self.dispItems) do
      v:SetVisible(v.tab == self.currentTab)
    end
  end

  function PANEL:Paint()
    gui.EnableScreenClicker(true) -- make sure cursor stays visible
    surface.SetTexture(surface.GetTextureID("darkland/f1bg_temp"))
    local col = team.GetColor(Me:Team())
    surface.SetDrawColor(math.Clamp(90+col.r, 0, 255), math.Clamp(90+col.g, 0, 255), math.Clamp(90+col.b, 0, 255), 255)
    surface.DrawTexturedRect(0, 0, self:GetWide(), self:GetTall())
  end
  vgui.Register("fw_menu", PANEL, "DPanel")

  function CreateMenu()
    if !ValidPanel(g_fwMenu) then
      g_fwMenu = vgui.Create("fw_menu")
      g_fwMenu:Center()
      g_fwMenu:SetVisible(false) --Little hacky so the next thing works good :D
    end
    mutemenu.updatePList()
    g_fwMenu:SetVisible(!g_fwMenu:IsVisible())
    if !g_fwMenu:IsVisible() then RememberCursorPosition() end
    gui.EnableScreenClicker(g_fwMenu:IsVisible())
    if g_fwMenu:IsVisible() then RestoreCursorPosition() end
  end
  hook.Add("FullyLoaded", "CreateMenu", CreateMenu)
  concommand.Add("fw_help", CreateMenu)