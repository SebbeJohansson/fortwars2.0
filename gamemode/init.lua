AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("cl_deathnotice.lua")
AddCSLuaFile("cl_menu.lua")
AddCSLuaFile("cl_scoreboard.lua")
AddCSLuaFile("cl_endgame.lua")

include("shared.lua")
include("sv_database.lua")
include("classes/sv_classes.lua")
include("sv_funcs.lua")
include("sv_commands.lua")
include("sv_upgrades.lua")
include("sv_specials.lua")
include("sv_scoreboard.lua")
include("sv_chat.lua")
include("sv_logs.lua")

util.AddNetworkString( "curclass" )
util.AddNetworkString( "chatprint" )
util.AddNetworkString( "voteskipPassed" )
util.AddNetworkString( "freezeCamSound" )
util.AddNetworkString( "boxCount" )
util.AddNetworkString( "initFW" )
util.AddNetworkString( "changetodm" )
util.AddNetworkString( "changetobuild" )
util.AddNetworkString( "ballentid" )
util.AddNetworkString( "cooldown" )
util.AddNetworkString( "leaderboards" )

//killfeed networking
util.AddNetworkString( "PlayerKilledByPlayers" )
util.AddNetworkString( "PlayerKilledSelf" )
util.AddNetworkString( "PlayerFallKilled" )
util.AddNetworkString( "PlayerKilledByPlayer" )
util.AddNetworkString( "PlayerKilled" )

//endgame networking
util.AddNetworkString( "gameOver" )
util.AddNetworkString( "getMapVote" )
util.AddNetworkString( "getEndVar" )
util.AddNetworkString( "getMaps" )



----------------
--Materials
---------------

resource.AddFile("materials/darkland/scope/scope.vmt")
resource.AddFile("materials/darkland/f1bg_temp.vmt")
resource.AddFile("materials/darkland/fortwars/ammohud1.vmt")
resource.AddFile("materials/darkland/fortwars/prophud1.vmt")
resource.AddFile("materials/darkland/fortwars/timerhud1a.vmt")
resource.AddFile("materials/darkland/fortwars/hud3.vmt")
resource.AddFile("materials/darkland/fortwars/timerbar.vmt")
resource.AddFile("materials/darkland/fortwars/user2.vmt")
resource.AddFile("materials/darkland/fortwars/itembg1.vmt")
resource.AddFile("materials/darkland/fortwars/propmenualt.vmt")
resource.AddFile("materials/darkland/pumpkin2.vmt")

----------------
--Sounds
---------------

resource.AddFile("sound/darkland/fortwars/bomberlol.mp3")
resource.AddFile("sound/darkland/rocket_launcher.mp3")
resource.AddFile("sound/darkland/fortwars/win9.mp3")
resource.AddFile("sound/darkland/fortwars/wintest.mp3")
resource.AddFile("sound/darkland/freeze_cam.wav")
resource.AddFile("sound/weapons/hacks01.wav")
resource.AddFile("sound/darkland/fortwars/killingspree.wav")
resource.AddFile("sound/darkland/fortwars/rampage.wav")
resource.AddFile("sound/darkland/fortwars/dominating.wav")
resource.AddFile("sound/darkland/fortwars/unstoppable.wav")
resource.AddFile("sound/darkland/fortwars/wickedsick.wav")
resource.AddFile("sound/darkland/fortwars/godlike.wav")
resource.AddFile("sound/darkland/fortwars/multikill.wav")
resource.AddFile("sound/darkland/fortwars/ultrakill.wav")
resource.AddFile("sound/darkland/fortwars/monsterkill.wav")
resource.AddFile("sound/darkland/fortwars/ludricouskill.wav")
resource.AddFile("sound/darkland/fortwars/holyshit.wav")
resource.AddFile("sound/darkland/fortwars/ninja_dodge1.wav")
resource.AddFile("sound/darkland/fortwars/ninja_dodge2.wav")
resource.AddFile("sound/darkland/fortwars/ninja_dodge3.wav")
resource.AddFile("sound/darkland/fortwars/ninja_dodge4.wav")
resource.AddFile("sound/darkland/fortwars/chainlightning.wav")
resource.AddFile("sound/darkland/fortwars/sorcerer_seek.wav")
resource.AddFile("sound/darkland/fortwars/pumpkin.wav")
resource.AddFile("sound/darkland/fortwars/pumpkinlaunch.wav")
resource.AddFile("sound/darkland/fortwars/wickedmalelaugh1.wav")
resource.AddFile("sound/darkland/fortwars/wickedmalelaugh2.wav")
resource.AddFile("sound/darkland/fortwars/wickedmalelaugh3.wav")

--gotta have that chat sound :D
resource.AddFile("sound/darkland/chatmessage.wav")

TeamsThisMap = {}
ballcarrier = 0
roundEnd = ENDGAME_TIME

players = {}
EntTeam = {}
ENDGAME = false;

TeamInfo = {}
TeamInfo[1] = {
Spawn = "info_player_blue",
Present = false,
BoxCount = 0,
HoldTime = DEFAULT_BALL_TIME
}
TeamInfo[2] = {
Spawn = "info_player_red",
Present = false,
BoxCount = 0,
HoldTime = DEFAULT_BALL_TIME
}
TeamInfo[3] = {
Spawn = "info_player_yellow",
Present = false,
BoxCount = 0,
HoldTime = DEFAULT_BALL_TIME
}
TeamInfo[4] = {
Spawn = "info_player_green",
Present = false,
BoxCount = 0,
HoldTime = DEFAULT_BALL_TIME
}

function GM:ShowHelp(ply)
  ply:ConCommand("fw_help")
end

function GM:ShowTeam(ply)
	ply:ConCommand("fw_leaderboards")
end

local meta = FindMetaTable("Entity")
function meta:GetTeam()
	if self.tbl then return self.Team end
	if self:IsPlayer() then return self:Team() end
end
function meta:TakeDmg(amt,atk,inf)
	self:TakeDamage(amt,atk,inf)
	return self:IsPlayer() && !self:Alive()
end

function SendChatText( player, color, text )
    if KokoAdmin then
        KokoAdmin.ColorfulChatprint(player, {color, text})
    else
        net.Start( "chatprint" )
            net.WriteInt( color.r, 10 )
            net.WriteInt( color.g, 10 )
            net.WriteInt( color.b, 10 )
            net.WriteString( text )
        net.Send( player )
    end
end

function SetColor( ply, color )
	ply:SetPlayerColor( Vector( color.r/255, color.g/255, color.b/255 ) )
end

/*---------------------------------------------------------
Converts a string to a vector and returns it
---------------------------------------------------------*/
function toVector(str)
  local vector = string.Explode(" ", str)
  return Vector(vector[1], vector[2], vector[3])
end

/*---------------------------------------------------------
Converts a string to an angle and returns it
---------------------------------------------------------*/
function toAngle(str)
  local angle = string.Explode(" ", str)
  return Angle(angle[1], angle[2], angle[3])
end


hook.Add( "PlayerSay", "ChatSound", function( ply, text, teamchat )

	----------------------
	--How do I X...
	----------------------

	if string.lower(string.sub( text, 1, 8 )) == "how do i" or string.lower(string.sub( text, 1, 10 )) == "how do you"  then
		for k, v in pairs(ChatCommands) do
			print(k)
		end
	
		timer.Simple(.1, function()
			ply:ChatPrint("Most questions can be answered by reading the help tab in the f1 menu")
		end)
	end
	
	----------------------
	--Chat sounds
	----------------------
	
	if string.sub( text, 1, 1 ) == "/" or string.sub( text, 1, 1 ) == "!" then return end
	if teamchat then
		for k, v in pairs(player.GetAll()) do
			if v:Team() == ply:Team() then
				if v:GetInfo( "fw_chatsounds" ) == "1" then v:SendLua( [[surface.PlaySound( "darkland/chatmessage.wav" )]] ) end
			end
		end
	else
		for k, v in pairs(player.GetAll()) do
		
		if v:GetInfo( "fw_chatsounds" ) == "1" then v:SendLua( [[surface.PlaySound( "darkland/chatmessage.wav" )]] ) end
			
		end				
	end
end)

---------------------
-- Drowning
---------------------
function GM:HandlePlayerSwimming(ply)
    if  !IsValid(ply) then return end

    if ply.timerrunning == nil then
        ply.timerrunning = false
    end

    if  !timer.Exists(ply:SteamID() .. "delay") then
        //ply.DrownUpgrade = ply.Skills[6]
        timer.Create(ply:SteamID() .. "delay", 5, 1, function() StartDrown(ply) end)
        timer.Stop(ply:SteamID() .. "delay")
    end

    if  !timer.Exists(ply:SteamID() .. "timer") then
        timer.Create(ply:SteamID() .. "timer", 1, 0, function() Drown(ply) end)
        timer.Stop(ply:SteamID() .. "timer")
    end

    if  !DM_MODE and ply.timerrunning then
        timer.Stop(ply:SteamID() .. "delay")
        timer.Stop(ply:SteamID() .. "timer")
        ply.timerrunning = false
        return
    end

    if ply:WaterLevel() == 3 and !ply.timerrunning and DM_MODE then
        timer.Start(ply:SteamID() .. "delay")
        ply.timerrunning = true
    elseif ply:WaterLevel() != 3 and ply.timerrunning and DM_MODE then
        timer.Stop(ply:SteamID() .. "delay")
        timer.Stop(ply:SteamID() .. "timer")
        ply.timerrunning = false
    end
end

--Starts the drown timer which ticks every second
function StartDrown(ply)
    if  !IsValid(ply) then return end
    if timer.Exists(ply:SteamID() .. "timer") then
        timer.Start(ply:SteamID() .. "timer")
    end
end

-- Takes away 12 hp if the player is underwater and simulates a drowning effect.
function Drown(ply)
    if  !ply:IsValid() then return end
    if ply:WaterLevel() == 3 and DM_MODE then
        local dmginfo = DamageInfo()
        dmginfo:SetDamage(12)
        dmginfo:SetDamageType(DMG_DROWN)
        dmginfo:SetAttacker(game.GetWorld())
        dmginfo:SetInflictor(ply)
        ply:TakeDamageInfo(dmginfo)

        if ply:Health() <= 0 and timer.Exists(ply:SteamID() .. "timer") then
            timer.Stop(ply:SteamID() .. "delay")
            timer.Stop(ply:SteamID() .. "timer")
            ply.timerrunning = false
        end
    end
end

---------------------
-- End drowning
---------------------

local maps = {}
function SendMaps()
    while (#maps < 5) do
        local map = math.random(1, #mapList)
        if (!table.HasValue(maps, map)) then
            table.insert(maps, map)
        end
    end
    file.Write("lastfwmaps.txt", table.concat(maps, "|"))
    net.Start("getMaps")
    for i = 1, 5 do
        net.WriteInt(maps[i], 10)
    end
    net.Broadcast()
end

function SendEndGameVars()
    for i, v in pairs(EndGameStats) do
        local pl, amt = v.Grabber()
        net.Start("getEndVar")
        net.WriteInt(i, 10)
        if IsValid(pl) then
            net.WriteInt(pl:EntIndex(), 10)
        else
            net.WriteInt(0, 10)
        end
        net.WriteString(amt or "")
        net.Broadcast()
    end
end

function CheckMapCompatibility() --change level if incompatible
    local exists = ents.FindByClass("balldrop")[1] != nil
    if  !exists then
        game.ConsoleCommand("changelevel " .. mapList[math.random(1, #mapList)][1] .. "\n")
    end
end

function GM:InitPostEntity()
    CheckMapCompatibility()
    --Now count the number of valid teams
    local num = 0
    for i, v in pairs(TeamInfo) do
        local tbl = ents.FindByClass(v.Spawn)
        if tbl[1] then
            num = num + 1
            TeamInfo[i].Present = true

            for ii, v in pairs(tbl) do
                timer.Simple(ii * 0.1, function()
                    local tr = util.TraceLine({ start = v:GetPos() + Vector(0, 0, 46), endpos = v:GetPos() + Vector(0, 0, -1000), filter = v })
                    if tr.Hit then v:SetPos(tr.HitPos + Vector(0, 0, 10)) end
                    local ent = ents.Create("spawn_marker")
                    local ang = v:GetAngles()
                    ent:SetPos(v:GetPos())
                    ent:SetAngles(Angle(0, ang.y, 0))
                    ent.color = team.GetColor(i)
                    ent:Spawn()
                    ent:Activate()
                    v.blocker = ent
                    v.blocker:SetNotSolid(true)
                end)
            end
        end
        TeamInfo[i].Spawns = tbl --Hold a table of all the spawns so we don't have to find them everytime we spawn
    end

    for i, v in pairs(ents.FindByClass("balldrop")) do
        local ent = ents.Create("ball_spawn")
        ent:SetPos(v:GetPos())
        ent:SetAngles(v:GetAngles())
        ent:Spawn()
        ent:Activate()
    end
end

function roundendTimer()
    timer.Create("roundendTimer", 1, 0, function()
        roundEnd = roundEnd - 1
        SetGlobalInt("roundEnd", roundEnd)
    end)
end

function GM:AdjustMouseSensitivity()
    return 1
end

function assignPlayerTeam(ply)
    if  !IsValid(ply) or ply:Team() == (1 or 2 or 3 or 4) then return end -- he picked a team already

    local t = {}
    for i, v in pairs(TeamInfo) do
        if v.Present then
            table.insert(t, i)
        end
    end
    table.sort(t, function(a, b) return team.NumPlayers(a) < team.NumPlayers(b) end)
    ply:UnSpectate()


    if table.Count(t) == 0 then
        print("No teams. Something has happened. Reloading post entiies")
        GAMEMODE:InitPostEntity()
        for i, v in pairs(TeamInfo) do
            if v.Present then
                table.insert(t, i)
            end
        end
        table.sort(t, function(a, b) return team.NumPlayers(a) < team.NumPlayers(b) end)
    end

    ply:SetTeam(t[1])
    local c = team.GetColor(t[1])
    ply:SetColor(Color(c.r, c.g, c.b, c.a))
    SetColor(ply, c)
    players[ply:SteamID()] = t[1]
    --ply:Kill()

    ply:Spawn()
    ply:SetDeaths(0)

    hook.Call("PlayerJoinedTeam", GAMEMODE, ply)
end

function GM:PlayerInitialSpawn(ply)

    SendChatText(ply, Color(255, 255, 255), "Welcome to FortWars 13!")

    -- So our donators feel special :)

    if ply:IsPremium() then
        SendChatText(ply, Color(0, 255, 230), "Welcome back, Premium member!")
    elseif ply:IsPlatinum() then
        SendChatText(ply, Color(0, 255, 0), "Welcome back, Platinum member!")
    end

    ply.name = ply:Nick()

    ply.BallSecs = 0
    ply.Suicides = 0
    ply.MoneyEarned = 0
    ply.ProppedMoney = 0
    ply.BuildingDamage = 0
    ply.Headshots = 0
    ply.TeirProgressEarned = 0
    ply.Messages = 0
    ply.LastPlayerKillTime = {}
    ply.damagetaken = 0
    ply.createdProps = {}
    ply.lastLeft = CurTime()
    ply.lastRight = CurTime()

    ply:ClassLoad()

    // So you can view stats of other people on scoreboard
    ply:SetNWInt("joinTime", CurTime())
    timer.Create(ply:SteamID().."_SpawnTimer",1,0,function()
        if ply.ProfileLoadStatus == nil then
            timer.Destroy(ply:SteamID().."_SpawnTimer")
            InitialSpawnPlayer(ply)
        end
    end)
end

function InitialSpawnPlayer(ply)
    ply:SetNWInt("mymoney", ply.cash)
    ply:SetNWInt("mykills", ply.stats['kills'])
    ply:SetNWInt("myassists", ply.stats['assists'])
    ply:SetNWInt("myballtime", ply.stats['balltime'])
    ply:SetNWInt("mywins", ply.stats['wins'])
    ply:SetNWInt("mylosses", ply.stats['losses'])
    ply:SetNWInt("mytime", math.Round(ply.stats["playtime"] / 3600))
    ply:SetNWInt("mystatus", ply.memberlevel)

    for k, v in pairs(TeamInfo) do
        if v.Present then
            table.insert(TeamsThisMap, k)
        end
    end

    umsg.Start("initFW", ply)
    for i, v in pairs(TeamsThisMap) do
        umsg.Char(v)
    end
    umsg.End()

    ----------------------
    -- Team picking shit
    ----------------------

    local canJoinTeam = true
    local canJoin = true
    local i = 1

    if DM_MODE then

        assignPlayerTeam(ply)
        canJoinTeam = false

        timer.Simple(2, function()
            ply:SetNWBool("onteam", true)
        end)
    else


        timer.Simple(1, function()
            if  !players[ply:SteamID()] then
                ply:SetTeam(TEAM_SPECTATOR)
                ply:StripWeapons()
            end
        end)


        if players[ply:SteamID()] then -- player rejoined to choose a new team
            timer.Simple(2, function()
                ply:SetNWBool("onteam", true)
            end)
            while (canJoin and i <= 4) do -- check if teams are unbalanced
                if team.NumPlayers(players[ply:SteamID()]) - team.NumPlayers(i) >= 1 and TeamInfo[i].Present then
                    canJoin = false
                end
                i = i + 1
            end
            if canJoin then -- teams are not unbalanced, put the player back to it's original team
                ply:UnSpectate()
                ply:SetTeam(players[ply:SteamID()])
            else -- put the player in the team with the least players 
                local t = {}
                for i, v in pairs(TeamInfo) do
                    if v.Present then
                        table.insert(t, i)
                    end
                end
                table.sort(t, function(a, b) return team.NumPlayers(a) < team.NumPlayers(b) end)
                ply:UnSpectate()
                ply:SetTeam(t[1])
            end

            local c = team.GetColor(ply:Team())
            ply:SetColor(Color(c.r, c.g, c.b, c.a))
            SetColor(ply, c)

            ply:Spawn()
            ply:SetDeaths(0)
            canJoinTeam = false
            hook.Call("PlayerJoinedTeam", GAMEMODE, ply)
        end
    end

    umsg.Start("SetCanJoinTeam", ply)
    umsg.Bool(canJoinTeam)
    umsg.End()
    ----------------------
    -- Team picking shit END
    ----------------------

    if  !players[ply:SteamID()] then -- if you havent join yet
        timer.Simple(.1, function() ply:ConCommand("fw_help") end)
    elseif players[ply:SteamID()] and ply:GetInfo("fw_menuonspawn") == "1" then
        timer.Simple(.1, function() ply:ConCommand("fw_help") end)
    end

    if DM_MODE then
        net.Start("changetodm")
        net.Send(ply)
    else
        net.Start("changetobuild")
        net.Send(ply)
    end
end

function SpawnPlayer(ply)
    local index = tonumber(ply:GetPData("Class"))
    local oldhp = Classes[index].HEALTH
    local oldspeed = Classes[index].SPEED

    ply:SetWalkSpeed(oldspeed + Skills["speed_limit"].LEVEL[ply.upgrades["speed_limit"]])
    ply:SetRunSpeed(ply:GetWalkSpeed())
    ply:SetHealth(oldhp + Skills["health_limit"].LEVEL[ply.upgrades["health_limit"]])
    ply:SetMaxHealth(oldhp + Skills["health_limit"].LEVEL[ply.upgrades["health_limit"]])
    ply:SetNWInt('energy', 100 + Skills["energy_limit"].LEVEL[ply.upgrades["energy_limit"]])
    ply:SetModel(Classes[index].MODEL)
    ply:SetJumpPower(Classes[index].JUMPOWER)

    if DM_MODE == true then

        local index = tonumber(ply:GetPData("Class"))
        ply:Give(Classes[index].WEAPON)
        ply:Give("weapon_physcannon")

        if ply:GetInfo("fw_spawnwithgrav") == "1" then
            ply:SelectWeapon("weapon_physcannon")
        else
            ply:SelectWeapon(Classes[index].WEAPON)
        end

    elseif DM_MODE == false then

        ply:Give("weapon_physgun")
        ply:Give("prop_creator")
        ply:Give("prop_remover")
        ply:Give("fw_spawngun")
    end

    if ply.SpawnAng then
        ply:SetEyeAngles(ply.SpawnAng)
    end

    if ply:GetPData("Class") != 5 then
        ply:SetNWBool("outtamyway", false)
    end


    local oldhands = ply:GetHands()
    if (IsValid(oldhands)) then oldhands:Remove() end

    local hands = ents.Create("gmod_hands")
    if (IsValid(hands)) then
        ply:SetHands(hands)
        hands:SetOwner(ply)

        local cl_playermodel = ply:GetInfo("cl_playermodel")
        local info = player_manager.TranslatePlayerHands(cl_playermodel)
        if (info) then
            hands:SetModel(info.model)
            hands:SetSkin(info.skin)
            hands:SetBodyGroups(info.body)
        end

        local vm = ply:GetViewModel(0)
        hands:AttachToViewmodel(vm)

        vm:DeleteOnRemove(hands)
        ply:DeleteOnRemove(hands)

        hands:Spawn()
    end
end

function GM:PlayerPostThink(ply)
    if ply:Team() == TEAM_SPECTATOR and ply:GetNWInt("joinTime") + 30 < CurTime() then
        assignPlayerTeam(ply)
    end
end

function GM:PlayerSelectSpawn(pl)
    if pl.SpawnPoint then
        return pl.SpawnPoint
    end
    local tbl = TeamInfo[pl:Team()]

    if  !tbl then return nil end --They have not loaded, spawn them in noclip underground

    if  !tbl.Spawns || table.Count(tbl.Spawns) == 0 then
        GAMEMODE:InitPostEntity()
        tbl = TeamInfo[pl:Team()]
    end

    local v = tbl.Spawns[math.random(#tbl.Spawns)]
    if (v) then return v end
    return tbl.Spawns[1]
end

function GM:PlayerSpawn(ply)

    ply.multiKills = 0
    ply.currentLifeKills = 0
    ply.killTime = 0
    ply.damagedealt = 0
    ply.myassistor = nil
    ply:ClassLoad()

    net.Start("curclass")
    net.WriteInt(ply:GetPData("Class"), 8)
    net.Send(ply)

    if ply:Team() == TEAM_SPECTATOR then
        timer.Simple(.1, function()
            if ply.ProfileLoadStatus == nil then
                GAMEMODE:PlayerSpawnAsSpectator(ply)
            end
            ply:StripWeapons()
        end)
    end
    
    if ply.ProfileLoadStatus == nil then
        SpawnPlayer(ply)
    end
end

function RaiseBoxCount(tm)
    TeamInfo[tm].BoxCount = TeamInfo[tm].BoxCount + 1
    local rf = RecipientFilter()
    for i, v in pairs(team.GetPlayers(tm)) do rf:AddPlayer(v) end
    net.Start("boxCount")
    net.WriteInt(TeamInfo[tm].BoxCount, 10)
    net.Send(rf)
end

function LowerBoxCount(tm)
    TeamInfo[tm].BoxCount = TeamInfo[tm].BoxCount - 1
    local rf = RecipientFilter()
    for i, v in pairs(team.GetPlayers(tm)) do rf:AddPlayer(v) end
    net.Start("boxCount")
    net.WriteInt(TeamInfo[tm].BoxCount, 10)
    net.Send(rf)
end

function GetBoxCount(tm)
    return TeamInfo[tm].BoxCount
end

function GM:PlayerDisconnected(ply)

    if IsValid(ply.SpawnPoint) then
        ply.SpawnPoint:Remove()
    end
end

function GM:Think()
    if CurTime() > nextsec then --adjust the timer
        nextsec = CurTime() + 1
        if DM_MODE == false then
            BUILD_TIMER = BUILD_TIMER - 1

        elseif DM_MODE == true then
            DM_TIMER = DM_TIMER - 1
        end
        SetGlobalInt("buildtime", BUILD_TIMER)
        SetGlobalInt("dmtime", DM_TIMER)

        for i = 1, 4 do
            SetGlobalInt("team" .. i .. "time", TeamInfo[i].HoldTime)
        end
    end

    if BUILD_TIMER <= 0 and DM_MODE == false then --change to deathmatch
        StartDM()

    elseif DM_TIMER <= 0 and DM_MODE == true then --change to build mode
        StartBuild()
    end

    if roundEnd <= 0 then
        ChangeMap()
    end
end

DamagedPlayers = {}

function GM:PlayerHurt(victim, attacker, hprem, dmgtoply)
    local threshold = victim:GetMaxHealth() * .4

    -- must do at least 40% damage to get assist
    ------------------------------------------------------------------------
    -- Assign assistor
    ------------------------------------------------------------------------
    -- Need damage to be player specific

    if attacker:IsPlayer() then

        local attid = attacker:UserID()
        local victid = victim:UserID()


        victim.damagetaken = victim.damagetaken + dmgtoply

        DamagedPlayers[attid] = { [victid] = victim.damagetaken }

        attacker:SetNWInt("dmgtoplayer", DamagedPlayers[attid][victid])
        print(attacker:GetNWInt("dmgtoplayer"))

        if attacker:IsPlayer() and attacker ~= victim then
            if victim:Team() ~= attacker:Team() and attacker:GetNWInt("dmgtoplayer") >= threshold and victim:Health() > 0 then

                if victim.myassistor == nil then victim.myassistor = attacker end

                print(victim.myassistor)

                victim.lastattack = CurTime() + 5
            end
        end
    end
    ------------------------------------------------------------------------
    -- End assists
    ------------------------------------------------------------------------

    if attacker:IsPlayer() and attacker:GetActiveWeapon():GetClass() == "pred_gun" then
        attacker:EmitSound(Sound("weapons/knife/knife_hit" .. math.random(1, 4) .. ".wav"))
    end
end

function addKillMoney(killer)
    if killer:IsPlatinum() then
        killer.MoneyEarned = killer.MoneyEarned + (KILL_MONEY + PLAT_KILL_BONUS)
        killer:AddMoney(KILL_MONEY + PLAT_KILL_BONUS)
    elseif killer:IsPremium() then
        killer.MoneyEarned = killer.MoneyEarned + (KILL_MONEY + PREM_KILL_BONUS)
        killer:AddMoney(KILL_MONEY + PREM_KILL_BONUS)
    else
        killer:AddMoney(KILL_MONEY)
    end
end

function GM:PlayerDeath(victim, weapon, killer)

    victim.damagetaken = 0
    victim.currentLifeKills = 0
    victim.respawntime = CurTime() + RESPAWN_TIME
    print(victim.myassistor)

    if IsValid(killer.LastHolder) then killer = killer.LastHolder end

    if (killer == victim) and IsValid(victim.myassistor) then
        killer = victim.myassistor
    end

    if (killer:IsWorld() and IsValid(victim.myassistor)) then
        killer = victim.myassistor
                //addKillMoney(killer)
    end


    if (victim.myassistor != killer and IsValid(victim.myassistor) and IsValid(killer) and killer != victim and victim.lastattack > CurTime()) then

        victim.myassistor:SetNWInt("Assists", victim.myassistor:GetNWInt("Assists") + 1)
        victim.myassistor.stats['assists'] = victim.myassistor.stats['assists'] + 1
        victim.myassistor:AddMoney(ASSIST_MONEY)


        if (killer != victim) then
            killer:AddFrags(1)
        end

        timer.Simple(1.5, function() self:FreezeCam(victim, killer) end)
        net.Start("PlayerKilledByPlayers")
        net.WriteEntity(victim)
        local str = killer:GetActiveWeapon()
        if str:IsValid() then
            str = str:GetClass()
        else
            str = ""
        end
        net.WriteString(str)
        net.WriteEntity(killer)
        net.WriteEntity(victim.myassistor)
        net.Broadcast()

        return
    end

    if (killer == victim) then

        if IsValid(victim.myassistor) then
            victim.myassistor:AddFrags(1)
        else

            victim.Suicides = victim.Suicides + 1
            net.Start("PlayerKilledSelf")
            net.WriteEntity(victim)
            net.Broadcast()
        end

        return
    end

    if (killer:IsWorld()) then

        net.Start("PlayerFallKilled")
        net.WriteEntity(victim)
        net.Broadcast()

        return
    end

    if (killer:IsPlayer()) then

        addKillMoney(killer)

        killer:AddFrags(1)
        killer.currentLifeKills = killer.currentLifeKills + 1
        killer.multiKills = killer.multiKills + 1
        killer.stats['kills'] = killer.stats['kills'] + 1

        if killer.killTime + 4 > CurTime() then -- check for multi kill

            if utSounds.multiKills[killer.multiKills] then -- play a multi kill sound   
                for k, v in pairs(player.GetAll()) do
                    v:ConCommand("play " .. (utSounds.multiKills[killer.multiKills].SOUND))
                end
                if IsValid(killer) then PrintMessage(HUD_PRINTCENTER, killer:Nick() .. " " .. utSounds.multiKills[killer.multiKills].DESC) end
            end

        else

            if utSounds.killingSprees[killer.currentLifeKills] then
                if IsValid(killer) then PrintMessage(HUD_PRINTCENTER, killer:Nick() .. " " .. utSounds.killingSprees[killer.currentLifeKills].DESC) end
                for k, v in pairs(player.GetAll()) do
                    v:ConCommand("play " .. (utSounds.killingSprees[killer.currentLifeKills].SOUND))
                end
            end
            killer.multiKills = 0
        end
        lastPrintMessage = CurTime()
        killer.killTime = CurTime()


        timer.Simple(1.5, function() self:FreezeCam(victim, killer) end)

        net.Start("PlayerKilledByPlayer")
        net.WriteEntity(victim)
        local str = killer:GetActiveWeapon()
        if str:IsValid() then str = str:GetClass() else str = "" end
        net.WriteString(str)
        net.WriteEntity(killer)
        net.Broadcast()

        return
    end

    net.Start("PlayerKilled")
    net.WriteEntity(victim)
    net.WriteString(weapon:GetClass())
    net.WriteString(killer:GetClass())
    net.Broadcast()
end

function GM:DoPlayerDeath(ply, attacker, dmginfo)
    ply:CreateRagdoll()
    ply:AddDeaths(1)
end

function GM:FreezeCam(ply, attacker)
    if (IsValid(ply) and IsValid(attacker) and !ply:Alive()) then
        ply:Spectate(OBS_MODE_IN_EYE)
        ply:SpectateEntity(attacker)
        ply:ChatPrint("Spectating " .. attacker:Nick() .. " (" .. attacker:SteamID() .. ")")
        net.Start("freezeCamSound")
        net.Send(ply)
    end
end

function GM:PlayerDeathThink(ply)
    if CurTime() < ply.respawntime then return end

    if (ply:KeyPressed(IN_ATTACK) or ply:KeyPressed(IN_ATTACK2) or ply:KeyPressed(IN_JUMP)) then
        ply:Spectate(OBS_MODE_NONE)
        ply:SetMoveType(MOVETYPE_WALK)
        ply:UnSpectate()
        ply:Spawn()
    end
end


function ChangeMap()
    table.sort(mapList, function(a, b) return a.votes > b.votes end)
    print("changelevel " .. mapList[1][1] .. "\n")
    game.ConsoleCommand("changelevel " .. mapList[1][1] .. "\n")
end

function GM:PlayerShouldTakeDamage(victim, attacker)
    if DM_MODE == false then return false

    elseif DM_MODE == true then

        if victim:IsPlayer() and attacker:IsPlayer() then

            if victim:Team() == attacker:Team() then
                return false

            elseif victim:Team() != attacker:Team() then
                return true
            end

        elseif victim:IsPlayer() and attacker:GetName() == "ball" then

            if attacker.LastHolder:Team() != victim:Team() then
                return true else return false
            end

        else
            return true
        end
    end
end



function GM:ScalePlayerDamage(ply, hitgroup, dmginfo)

    --More damage if we're shot in the head
    if (hitgroup == HITGROUP_HEAD) then

        if dmginfo:GetAttacker():GetActiveWeapon():GetClass() == "sorcerer_gun" then
            dmginfo:ScaleDamage(1.43)
        else
            dmginfo:ScaleDamage(2)
        end

        -- Less damage if we're shot in the arms or legs
    elseif (hitgroup == HITGROUP_LEFTARM ||
        hitgroup == HITGROUP_RIGHTARM ||
        hitgroup == HITGROUP_RIGHTLEG ||
        hitgroup == HITGROUP_LEFTLEG ||
        hitgroup == HITGROUP_GEAR) then

        dmginfo:ScaleDamage(0.65)

    elseif (hitgroup == HITGROUP_STOMACH ||
        hitgroup == HITGROUP_CHEST) then

        dmginfo:ScaleDamage(1)
    end
end

hook.Add("PlayerNoClip", "FWFlyNoclipPlayerNoClip", function(ply)
    if DM_MODE then return false end

    if ply:IsAdmin() then return true
    end
    if ply:IsPlatinum() then
        if ply:GetMoveType() == MOVETYPE_FLY then
            ply:SetMoveType(MOVETYPE_WALK)
        else
            ply:SetMoveType(MOVETYPE_FLY)
        end
        return
    end
end)

/*
hook.Add("KeyPress", "usesound", function(ply, key)
    if key == IN_USE and ply:GetActiveWeapon():GetClass() == "prop_creator" then
        ply:SendLua("surface.PlaySound('common/wpn_select.wav')")
    end
end)
*/

hook.Add("KeyPress", "FWFlyKeyPress", function(ply, key)

    if key ~= IN_SPEED then return end
    if not IsValid(ply) then return end
    if DM_MODE then return end
    if ply:GetMoveType() == MOVETYPE_FLY then
        ply:SetVelocity(ply:GetVelocity() * -1)
    end
end)

function PhysgunPickup(pl, ent)
    if  ! (ent:GetClass() == "prop") and ! (ent:GetClass():lower() == "player") then return false end

    if ent:IsPlayer() then
        if pl:IsAdmin() then
            ent:SetMoveType(MOVETYPE_NONE)
            return true
        else
            return false
        end
    end

    if  ! ent.Spawner then return end
    if ent.Spawner == pl then
        ent:SetColor(Color(255, 255, 255, 255))
        return true
    end

    if pl:IsAdmin() and IsValid(ent.Spawner) then
        pl:PrintMessage(4, "This prop belongs to " .. ent.Spawner:Name())
        ent:SetColor(Color(255, 255, 255, 255))
        return true
    end

    if  ! IsValid(ent.Spawner) then
        pl:PrintMessage(4, "The owner of this prop is gone, it is now yours")
        table.insert(pl.createdProps, ent)
        ent.Spawner = pl
        ent.Team = pl:Team()
        ent:SetColor(Color(255, 255, 255, 255))
        return true
    end

    pl:PrintMessage(4, "This prop belongs to " .. ent.Spawner:Name())
    return false
end

hook.Add("PhysgunPickup", "phys", PhysgunPickup)

function GM:PlayerSwitchFlashlight(ply, SwitchOn)
    return true
end

function GM:PhysgunDrop(ply, ent)
    ent:GetPhysicsObject():EnableMotion(false)
    if ent:IsPlayer() then
        ent:SetMoveType(MOVETYPE_WALK)
    end
end

function PhysUnfreeze(ply, ent, phys)
    return false
end
hook.Add("CanPlayerUnfreeze", "PhysUnfreeze", PhysUnfreeze)

function GameOver(winner)
    ENDGAME = winner;
    roundendTimer()
    ROUNDOVER = true

    net.Start("gameOver")
    net.WriteInt(winner, 10);
    net.Broadcast()

    SendMaps()

    for k, v in pairs(team.GetPlayers(winner)) do

        if v:IsPlatinum() then
            v:AddMoney(WIN_MONEY * PLAT_WIN_MULTIPLIER)
            v.MoneyEarned = v.MoneyEarned + (WIN_MONEY * PLAT_WIN_MULTIPLIER)
        elseif v:IsPremium() then
            v.MoneyEarned = v.MoneyEarned + (WIN_MONEY * PREM_WIN_MULTIPLIER)
            v:AddMoney(WIN_MONEY * PREM_WIN_MULTIPLIER)
        else
            v.MoneyEarned = v.MoneyEarned + WIN_MONEY
            v:AddMoney(WIN_MONEY)
        end

        v:ConCommand("play " .. WIN_SONG)

        v.stats['wins'] = v.stats['wins'] + 1
    end

    for k, v in pairs(player.GetAll()) do
        v:Lock()
        v:StripWeapon("weapon_physcannon")

        if v:Team() != winner then
            v:ConCommand("play " .. LOSE_SONG)
            v.stats['losses'] = v.stats['losses'] + 1
        end
    end

    SendEndGameVars()
    return true
end

function GM:GravGunOnPickedUp(ply, ent)
    local PlayerTeam = ply:Team()
    if ent:GetName() == "ball" and DM_MODE == true then

        ent.LastHolder = ply
        ballcarrier = ply
        ballcarrier:SetNWBool("carrying", true)

        timer.Create("balltimer", 1, 0, function()
            if DM_MODE == true then
                TeamInfo[ballcarrier:Team()].HoldTime = TeamInfo[ballcarrier:Team()].HoldTime - 1
                ballcarrier.BallSecs = ballcarrier.BallSecs + 1
                ballcarrier.stats['balltime'] = ballcarrier.stats['balltime'] + 1

                if ballcarrier:IsPremium() then
                    ballcarrier:AddMoney(BALL_MONEY + PREM_BALL_BONUS)
                    ballcarrier.MoneyEarned = ballcarrier.MoneyEarned + (BALL_MONEY + PREM_BALL_BONUS)

                elseif ballcarrier:IsPlatinum() then
                    ballcarrier:AddMoney(BALL_MONEY + PLAT_BALL_BONUS)
                    ballcarrier.MoneyEarned = ballcarrier.MoneyEarned + (BALL_MONEY + PLAT_BALL_BONUS)
                else
                    ballcarrier:AddMoney(BALL_MONEY)
                    ballcarrier.MoneyEarned = ballcarrier.MoneyEarned + (BALL_MONEY)
                end

                if (TeamInfo[ballcarrier:Team()].HoldTime <= 0) then
                    GameOver(ballcarrier:Team())
                end
            end
        end)

    elseif (ent:GetClass() == "nade" or ent:GetClass() == "sent_rpgrocket" or ent:GetClass() == "swatnade") and DM_MODE == true then
        ent.LastHolder = ply
    end
end

function GM:GravGunOnDropped(ply, ent)
    local PlayerTeam = ply:Team()
    if ent:GetName() == "ball" then
        ply:SetNWBool("carrying", false)
        ballcarrier = 0
        timer.Destroy("balltimer")
    end
end

function GM:GetFallDamage(ply, speed)
    speed = speed - 580
    if tonumber(ply:GetPData("Class")) != 3 then return speed * (1 / Skills["fall_damage_resistance"].LEVEL[ply.upgrades["fall_damage_resistance"]]) end
end

function GM:EntityTakeDamage(ply, dmginfo)

    local inflictorType = dmginfo:GetInflictor():GetClass()
    local inflictor = dmginfo:GetInflictor()
    local attacker = dmginfo:GetAttacker()
    local amount = dmginfo:GetDamage()



    if (ply:IsPlayer() and dmginfo:GetDamageType() == DMG_CRUSH and (dmginfo:GetInflictor():GetClass() == "swatnade" or dmginfo:GetInflictor():GetClass() == "sent_rpgrocket")) then

        dmginfo:ScaleDamage(0)

    elseif ply:GetNWBool("outtamyway") == true and ply:IsPlayer() then
        dmginfo:ScaleDamage(.5)

        // temp gunner special

        elseif ply:IsPlayer() and ply:GetActiveWeapon():GetClass() == "gunner_gun" and dmginfo:IsBulletDamage() and ply:HasSpecial(2) then

        ply:TakeEnergy(amount * 1.5)

        if ply:GetNWInt('energy') > 0 then
            dmginfo:ScaleDamage(0)
            ply:EmitSound(Sound("darkland/fortwars/ninja_dodge" .. tostring(math.random(1, 4)) .. ".wav"), 100, 100)
        else
            dmginfo:ScaleDamage(1)
        end
    end

    return dmginfo
end

function StartDM()
    BUILD_TIMER = DEFBUILD_TIMER
    DM_MODE = true
    ToggleWalls()
    ToggleSpawnMarkers()
    ToggleGhostBall()

    VoteSkippers = {}
    VoteSkips = 0
    numBuilds = numBuilds + 1

    SetGlobalBool("voteSkipPassed", false)

    for k, v in pairs(player.GetAll()) do
        if v:Alive() then
            v:StripWeapons()
        end
        v:Spawn()
        net.Start("changetodm")
        net.Send(v)
    end
    CreateBall()
end

function StartBuild()
    DM_TIMER = DEFDM_TIMER
    DM_MODE = false
    ToggleWalls()
    ToggleSpawnMarkers()
    ToggleGhostBall()

    SetGlobalBool("voteSkipPassed", false)

    for k, v in pairs(player.GetAll()) do
        if v:Alive() then
            v:StripWeapons()
            v:Spawn()
        end
        net.Start("changetobuild")
        net.Send(v)
    end
    ballcarrier = 0
    timer.Destroy("balltimer")
    CreateBall()
end

function ToggleSpawnMarkers()
    if DM_MODE == true then
        for k, v in pairs(ents.FindByClass("spawn_marker")) do
            v:Disable()
        end
    end
    if DM_MODE == false then
        for k, v in pairs(ents.FindByClass("spawn_marker")) do
            v:Enable()
        end
    end
end

function ToggleGhostBall()
    if DM_MODE == true then
        for k, v in pairs(ents.FindByClass("ball_spawn")) do
            v:Disable()
        end
    end
    if DM_MODE == false then
        for k, v in pairs(ents.FindByClass("ball_spawn")) do
            v:Enable()
        end
    end
end

function ToggleWalls()
    if DM_MODE == true then
        for k, v in pairs(ents.FindByClass("func_wall_toggle")) do
            v:SetColor(Color(0, 0, 0, 0))
            v:SetNotSolid(true)
            v:SetNoDraw(true)
        end
    end
    if DM_MODE == false then
        for k, v in pairs(ents.FindByClass("func_wall_toggle")) do
            v:SetColor(Color(255, 255, 255, 255))
            v:SetNotSolid(false)
            v:SetNoDraw(false)
        end
    end
end

function CreateBall()
    local balldrop = ents.FindByClass("balldrop")
    if DM_MODE == true then
        ent = ents.Create("prop_physics")
        ent:SetModel("models/Roller.mdl")
        ent:SetName("ball")

        for _, t in pairs(ents.FindByClass("balldrop")) do
            ent:SetPos(t:GetPos())
        end

        ent:Spawn()
        ent:GetPhysicsObject():EnableMotion(true)
        ent:GetPhysicsObject():Wake()
        ent:Activate()

        local rp = RecipientFilter()
        rp:AddAllPlayers()
        net.Start("ballentid")
        net.WriteInt(ent:EntIndex(), 32)
        net.Send(rp)

    elseif DM_MODE == false then
        //ent:Remove()
    end
end