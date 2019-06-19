function findplayeruserid( userid )
	local uid = tonumber(userid)
	if (uid) then
		for _, pl in pairs(player.GetAll()) do
			if (pl:UserID() == uid) then
				return pl
			end
		end
	end
	return nil
end

function findplayername( name )
	local lname = string.lower(name)
	for _,pl in pairs(player.GetAll()) do
		local name = pl:Nick()
		if (string.lower(string.sub(name, 1, #lname)) == lname) then
			return pl
		end
	end
	return findplayeruserid(name)
end

function findplayer( uniqueid )
	if (!uniqueid) then return nil end
	local pl = player.GetBySteamID(uniqueid)
	if (!pl || !pl:IsValid()) then 
		return findplayername(uniqueid)
	end
	return pl
end

function admincommand(ply,command,args)

	if tonumber(args[1]) == 1 then
		if !ply:IsAdmin() and !ply:IsSuperAdmin() then return end
		if DM_MODE == false then
			StartDM()
			for i,v in pairs(player.GetAll()) do
				SendChatText( v, Color( 255, 255, 255 ), ply:Name().." has forced fight mode!")
			end
			FWLOG("[FWADMIN] - " ..ply:Nick().."<"..ply:SteamID().. "> forced fight mode")
		else
			SendChatText( ply, Color( 255, 255, 255 ), "Deathmatch is already on!")
		end
	elseif tonumber(args[1]) == 2 then
		if !ply:IsAdmin() and !ply:IsSuperAdmin() then return end
		if DM_MODE == true then
			StartBuild()
			for i,v in pairs(player.GetAll()) do
				SendChatText( v, Color( 255, 255, 255 ), ply:Name().." has forced build mode!")
			end
			FWLOG("[FWADMIN] - " ..ply:Nick().."<"..ply:SteamID().. "> forced build mode")
		else
			SendChatText( ply, Color( 255, 255, 255 ), "Build mode is already on!")
		end
	elseif tonumber(args[1]) == 3 then
		if !ply:IsAdmin() and !ply:IsSuperAdmin() then return end
        
		for k,v in pairs(TeamInfo) do
            TeamInfo[k].HoldTime = DEFAULT_BALL_TIME
            team.SetScore(k,0)
        end
        
        props = ents.FindByClass("prop")
        for k,v in pairs(props) do
            v:Remove()
        end
        
        StartBuild()
        
		for i,v in pairs(player.GetAll()) do
			SendChatText( v, Color( 255, 255, 255 ), ply:Name().." has restarted the game")
		end
		FWLOG("[FWADMIN] - " ..ply:Nick().."<"..ply:SteamID().. "> restarted the game")
	elseif tonumber(args[1]) == 4 then
		if !ply:IsUserGroup("moderator") and !ply:IsAdmin() and !ply:IsSuperAdmin() then return end
		if DM_MODE && ent:GetName("ball") then
			ent:Remove()
			timer.Simple(0.1, function() 
			CreateBall()
			end)
		end
			
		for i,v in pairs(player.GetAll()) do
			SendChatText( v, Color( 255, 255, 255 ), ply:Name().." has respawned the ball!")
		end
		FWLOG("[FWADMIN] - " ..ply:Nick().."<"..ply:SteamID().. "> respawned the ball")
	end
end
concommand.Add("admincommand",admincommand)

function buildProp(ply, cmd, args)
  --local buyableProp = false
  if GetBoxCount(ply:Team()) >= MAX_PROPS then return end
  ply.LastSpawnProp = ply.LastSpawnProp or 0
  if ply.LastSpawnProp > CurTime() then
    return
  end
  local tbl
  
  if string.find(args[1], "B") then
    args[1] = string.sub(args[1], 0, 1)
    args[1] = tonumber(args[1])
    if !buyableProps[args[1]] or !table.HasValue(ply.props, args[1]) then return end
    tbl = buyableProps[args[1]]
    --buyableProp = true
  else
    --buyableProp = false
    tbl = PropList[tonumber(args[1])]
  end
  
  if !tbl then return end
  
  local tr = {}
  tr.start = ply:GetShootPos()
  tr.endpos = tr.start + ply:GetAimVector() * 300
  tr.filter = ply
  local trace = util.TraceLine(tr)
  if trace.Fraction == 0 then 
    ply:EmitSound(Sound("buttons/button19.wav")) 
    ply.LastSpawnProp = CurTime()+0.75 
    return 
  end
  
  if trace.Hit  then
    local ent = ents.Create("prop")
    ent:SetModel(tbl.MODEL)
    ent:SetPropTable(tbl)
    ent.Team = ply:Team()
    ent:SetNWInt("Team", ply:Team())
    local c = team.GetColor(ent.Team)
	ent:SetColor(team.GetColor(ply:Team()))
    ent:SetPos(toVector(args[3]))
    ent:SetAngles(toAngle(args[2]))
    ent.Spawner = ply
    ent:SetNWEntity("Spawner", ply)
    ent:Spawn()
    ent:EmitSound(Sound("plats/crane/vertical_stop.wav"))
	table.insert(ply.createdProps, ent)
    RaiseBoxCount(ent.Team)
    ply:TakeMoney(tbl.PRICE)
	
    ply.ProppedMoney = ply.ProppedMoney + tbl.PRICE
    ply.LastSpawnProp = CurTime() + 0.75
	
  end
end
concommand.Add("createprop", buildProp)

concommand.Add("gmod_undo", function(ply)
    if table.Count(ply.createdProps) == 0 then return end
    if !DM_MODE then
      ply.lastUndo = CurTime()
      local prop = table.remove(ply.createdProps)
      if IsValid(prop) then
	  
			ply:AddMoney(prop.TBL.PRICE)
			ply.ProppedMoney = ply.ProppedMoney - prop.TBL.PRICE
			LowerBoxCount(prop.Team)
	  
        prop:Remove()
        ply:SendLua([[notification.AddLegacy("Undone Prop", NOTIFY_UNDO, 2) surface.PlaySound("buttons/button15.wav") Msg("Prop undone\n")]])
      else
        while (!IsValid(prop) and #ply.createdProps != 0) do
          prop = table.remove(ply.createdProps)
          if IsValid(prop) then
		  
			ply:AddMoney(prop.TBL.PRICE)
			ply.ProppedMoney = ply.ProppedMoney - prop.TBL.PRICE
			LowerBoxCount(prop.Team)
			
            prop:Remove()
            ply:SendLua([[notification.AddLegacy("Undone Prop", NOTIFY_UNDO, 2) surface.PlaySound("buttons/button15.wav") Msg("Prop undone\n")]])
            break
          end
        end
      end
    end
  end
)

concommand.Add( "setmoney", function(ply, cmd, args)

	if !ply:IsSuperAdmin() then return false end
	
	local name = findplayer(args[1])
	local amount = tonumber(args[2])

	if !name or !amount then
		SendChatText( ply, Color( 255, 0, 0 ), "Usage: /setmoney <name/userid> <amount>" )
		return
	end
	SendChatText( ply, Color( 255, 255, 255 ), "You have set the money of "..name:Name().." to $"..amount.."!")
	SendChatText( name, Color( 255, 255, 255 ), ply:Name().." has set the money of you to $" .. amount)
	name:SetMoney(amount)
	
	FWLOG("[FWADMIN] - " ..ply:Nick().."<"..ply:SteamID().. "> set the money of "..name:Name().." "..name:SteamID().." to $"..amount)
end)

concommand.Add( "addmoney", function(ply, cmd, args)

	if !ply:IsSuperAdmin() then return false end
	
	local name = findplayer(args[1])
	local amount = tonumber(args[2])

	if !name or !amount then
		SendChatText( ply, Color( 255, 0, 0 ), "Usage: /addmoney <name/userid> <amount>" )
		return
	end
	SendChatText( ply, Color( 255, 255, 255 ), "You have added $"..amount.." to ".. name:Name())
	SendChatText( name, Color( 255, 255, 255 ), ply:Name().." has added $" .. amount.." to your account")
	name:AddMoney(amount)
	FWLOG("[FWADMIN] - " ..ply:Nick().."<"..ply:SteamID().. "> added $"..amount.." to "..name:Name().." "..name:SteamID())
	
end)

concommand.Add( "takemoney", function(ply, cmd, args)

	if !ply:IsSuperAdmin() then return false end
	
	local name = findplayer(args[1])
	local amount = tonumber(args[2])

	if !name or !amount then
		SendChatText( ply, Color( 255, 0, 0 ), "Usage: /takemoney <name/userid> <amount>" )
		return
	end
	SendChatText( ply, Color( 255, 255, 255 ), "You took $"..amount.." from ".. name:Name())
	SendChatText( name, Color( 255, 255, 255 ), ply:Name().." took $" .. amount.." from you")
	name:TakeMoney(amount)
	FWLOG("[FWADMIN] - " ..ply:Nick().."<"..ply:SteamID().. "> took $"..amount.." from "..name:Name().." "..name:SteamID())
	
end)

concommand.Add( "setmember", function(ply, cmd, args)

	if !ply:IsSuperAdmin() then return false end
	
	local name = findplayer(args[1])
	local member = tonumber(args[2])
	
	if !name or !member then
		SendChatText( ply, Color( 255, 255, 255 ), "Usage: /setmember <name/userid> <member level>")
		return
	end
	
	name:SetDonor(member)
	FWLOG("[FWADMIN] - " ..ply:Nick().."<"..ply:SteamID().. "> set the member of  "..name:Name().." "..name:SteamID().." to "..member)
end)

concommand.Add( "playerstats", function(ply, cmd, args)
	local name = findplayer(args[1])
	if !name then
		SendChatText( ply, Color( 255, 255, 255 ), "Usage: /stats <name/userid>")
		return
	end
	SendChatText( ply, Color( 255, 255, 255 ), "["..name:Nick().."] Kills: " .. name.stats[1] .. " Assists: " .. name.stats[2] .. " Balltime: " .. name.stats[3] .. " seconds Money: $" .. name.cash .. " Wins: " .. name.stats[4] .. " Losses: " .. name.stats[5] .. "Play time: " .. name.stats["playtime"])
end)

concommand.Add( "givemoney", function(ply, cmd, args)
	local name = findplayer(args[1])
	local amount = tonumber(args[2])
	
	if !name or !amount then
		SendChatText( ply, Color( 255, 255, 255 ), "Usage: /givemoney <name> <amount>")
		return
	end
	
	if ply != name then 
		if ply.cash >= amount then
			SendChatText( ply, Color( 255, 255, 255 ), "You have given "..name:Name().." $"..amount.."!")
			SendChatText( name, Color( 255, 255, 255 ), ply:Name().." has given you ".."$"..amount.."!")
			ply:TakeMoney(amount)
			name:AddMoney(amount)
			FWLOG("[FW] - " ..ply:Nick().."<"..ply:SteamID().. "> gave "..name:Name().." "..name:SteamID().." $"..amount)
		else
			SendChatText( ply, Color( 255, 255, 255 ), "You do not have that much money to give")
		end
	else
		SendChatText( ply, Color( 255, 255, 255 ), "You cannot give money to yourself!")
	end
end)

--Purely for testing purposes only--

concommand.Add( "setclass", function(ply, cmd, args)
	if !ply:IsSuperAdmin() then return false end
	local name = findplayer(args[1])
	local class = tonumber(args[2])
	if !name or !class then
		SendChatText( ply, Color( 255, 255, 255 ), "Usage: /setclass <name> <classid>")
		return
	end
	name:Kill()
	name:SetPData("Class", class)
end)

VoteSkippers = {}
VoteSkips = 0
local firstSkipper = false

concommand.Add( "voteskip", function(ply, cmd, args)
	if !firstSkipper then ply.firstSkipper = true firstSkipper = true end
	
	if DM_MODE then 
		ply:SendLua([[notification.AddLegacy("You can not voteskip during fight mode", NOTIFY_ERROR, 3) surface.PlaySound("buttons/button10.wav") Msg("You can not voteskip during fight mode\n")]])
		return 
	end
	if GetGlobalBool( "voteSkipPassed" ) == true then return end
	
	if (GetGlobalInt("buildtime") > (DEFBUILD_TIMER - VOTE_DELAY)) and numBuilds == 0 then
		ply:SendLua("notification.AddLegacy(\"You must wait "..string.ToMinutesSeconds(	VOTE_DELAY - CurTime()	).." to voteskip\", NOTIFY_ERROR, 3) surface.PlaySound(\"buttons/button10.wav\") MsgN(\"You must wait "..string.ToMinutesSeconds(VOTE_DELAY - CurTime()).." to voteskip\")")
		return
	end
	
	if voteSkipping then return end

	if VoteSkippers[ply:SteamID()] then 
		SendChatText( ply, Color( 255, 255, 255 ), "You have already voteskipped this round!") 
		return 
	end
	VoteSkippers[ply:SteamID()] = true
	
	if ply:IsPremium() then
		VoteSkips = VoteSkips + 2
	elseif ply:IsPlatinum() then
		VoteSkips = VoteSkips + 4
	else
		VoteSkips = VoteSkips + 1
	end
	
	local needed = math.ceil(#player.GetAll()*VOTE_THRESH)
	
	if VoteSkips >= needed then
		VSPASSED = true
		BUILD_TIMER = 10
		SetGlobalInt("buildtime", BUILD_TIMER)
		SetGlobalBool( "voteSkipPassed", true )
		
		net.Start("voteskipPassed")
		net.Broadcast()
	end
	
	for i,v in pairs(player.GetAll()) do 
		SendChatText( v, Color( 255, 255, 255 ), "There are now "..VoteSkips.." voteskips. ("..needed.." needed)") 
	end
end)

concommand.Add( "resetspawn", function(ply, cmd, args)
  if ply.SpawnPoint then
    ply.SpawnPoint:Remove()
  end
  ply.SpawnPoint = nil
  ply.SpawnAng = nil
  ply:SendLua([[notification.AddLegacy("Spawnpoint Undone", NOTIFY_UNDO, 2) surface.PlaySound("buttons/button15.wav") Msg("Spawnpoint Undone\n")]])
end)

local mapVoted = {}
function MapVote(ply, cmd, args)
  local map = tonumber(args[1])
  if !mapList[map] or mapVoted[ply:SteamID()] == "2" then return end
  local voteamt = 1
  if ply:IsPlatinum() then
    voteamt = 4
  elseif ply:IsPremium() then
    voteamt = 2
  end  
 
  if mapVoted[ply:SteamID()] == nil then
    mapVoted[ply:SteamID()] = "1 "..tostring(map)
    mapList[map].votes = mapList[map].votes + voteamt;
  else
    oldmap = tonumber((string.Explode(" ", mapVoted[ply:SteamID()]))[2])
    if oldmap == map then return end
    mapList[oldmap].votes = mapList[oldmap].votes - voteamt;
	
    net.Start("getMapVote")
      net.WriteInt(oldmap, 10)
	  net.WriteInt(-voteamt, 10)
    net.Broadcast()
    
    mapVoted[ply:SteamID()] = "2"
    mapList[map].votes = mapList[map].votes + voteamt;
  end
  
    net.Start("getMapVote")
      net.WriteInt(map, 10)
	  net.WriteInt(voteamt, 10)
    net.Broadcast()
end
concommand.Add("mapVote", MapVote)

function chooseTeam(ply, cmd, args)
  if !TeamInfo[tonumber(args[1])].Present then return end
  if ply:GetNWInt("joinTime") + 30 < CurTime() or players[ply:SteamID()] then return end
  
  local i, canJoin = 1, true
  
  while(canJoin and i <= 4) do
    if team.NumPlayers(tonumber(args[1])) - team.NumPlayers(i) >= 1 and TeamInfo[i].Present then
      canJoin = false
    end
    i = i+1
  end
  if canJoin then
	
    ply:UnSpectate()
    ply:SetDeaths(0)
    ply:SetTeam(args[1])
    local c = team.GetColor(ply:Team())
    ply:SetColor(Color(c.r, c.g, c.b, c.a))
	SetColor( ply, c )
    players[ply:SteamID()] = tonumber(args[1])
    umsg.Start( "SetCanJoinTeam", ply)
      umsg.Bool(false)
    umsg.End()
    
    ply:Spawn()
	ply:SetNWBool("onteam", true)
   // hook.Call("PlayerJoinedTeam", GAMEMODE, ply)
  else
	ply:SetNWBool("onteam", false)
    SendChatText( ply, Color( 255, 255, 255 ), "This team is currently full")
  end
end
concommand.Add("chooseteam", chooseTeam)


--Gonna need to make a 100 account max or so with this, because of the net library limit
concommand.Add("fw_leaderboards", function( ply, cmd, args )

	local tbl = {}
	
	for k, v in pairs (Leaderboard.Players) do
		tbl = table.ForceInsert(tbl, v)
	end
    
	net.Start("leaderboards")
	net.WriteTable(tbl)
	net.Send(ply)
	
end)

----------------------------------------
--Chat Commands
----------------------------------------

ChatCommands = {
--chat command	--concommand
	resetspawn = "resetspawn",
	givemoney = "givemoney",
	setmoney = "setmoney",
	voteskip = "voteskip",
	stats = "playerstats",
	pm = "pm",
	r = "reply",
	s = "superchat",
	a = "adminchat",
	m = "modchat",
}

AdminChatCommands = {
--chat command	--concommand
	//a = "adminchat",
}

function AddChatCommand(chatCmd, consoleCmd)
	if not ChatCommands then return; end
	ChatCommands[chatCmd] = consoleCmd
end

hook.Add("PlayerSay", "ChatCommands", function(ply, text, public)

	if ply.Messages then
		ply.Messages = ply.Messages + 1
	end

	local prefix = string.sub(text, 1, 1)
	local lowerText = string.lower(text)
	local trimText = string.Trim(lowerText)
	local afterPrefix = string.sub(trimText, 2)

	if prefix == "/" or prefix == "!" then
		local args = string.Explode(" ", afterPrefix)
		local command = args[1]
		table.remove(args, 1)

		if ChatCommands[command] then
			local cmdArgs = ""

			for k, v in pairs(args) do
				if k > 1 then
					cmdArgs = cmdArgs .. v .. " "
				else
					cmdArgs = cmdArgs .. " " .. v .. " "
				end
			end				
			
			if (!cmdArgs) then
				ply:ConCommand(ChatCommands[command])
				return ""
			end
			if (cmdArgs) then					
				ply:ConCommand(ChatCommands[command]..cmdArgs)
                return ""
			end
			
		elseif AdminChatCommands[command] then
            if !ply:IsAdmin() then ply:SendLua([[notification.AddLegacy("Invalid authority to use this command.", NOTIFY_ERROR, 4) surface.PlaySound("buttons/button10.wav") Msg("Invalid authority to use this command.\n")]]) end
			local cmdArgs = ""

			for k, v in pairs(args) do
				if k > 1 then
					cmdArgs = cmdArgs .. v .. " "
				else
					cmdArgs = cmdArgs .. " " .. v .. " "
				end
			end				
			
			if (!cmdArgs) then
				ply:ConCommand(AdminChatCommands[command])
				return ""
			end
			if (cmdArgs) then					
				ply:ConCommand(AdminChatCommands[command]..cmdArgs)
                return ""
			end
			
		else
		
			ply:SendLua([[notification.AddLegacy("Invalid command, see the F1 'help' tab for a list of commands.", NOTIFY_ERROR, 4) surface.PlaySound("buttons/button10.wav") Msg("Invalid command, see the F1 'help' tab for a list of commands.\n")]])
			return	""
			
		end
		
	end
end)