--------------------------------------
-- Log functions for logging events --
--------------------------------------
NUM_OF_FILES = NUM_OF_FILES or 0
hook.Add("Initialize", "CreateDirs", function()
	if ( !file.IsDir("logs/fortwars", "DATA") ) then
		file.CreateDir("logs/fortwars")
	end
	
	if ( !file.IsDir("logs/fortwars/"..os.date("%m_%d_%y").."_"..GetConVarString("ip"):Replace(".","_"), "DATA" ) ) then
		file.CreateDir("logs/fortwars/"..os.date("%m_%d_%y").."_"..GetConVarString("ip"):Replace(".","_"))
	end
	
	local numfiles = file.Find("logs/fortwars/"..os.date("%m_%d_%y").."_"..GetConVarString("ip"):Replace(".", "_").."/*.txt", "DATA")
	NUM_OF_FILES = #numfiles + 1
end)

hook.Add("PlayerSay", "PlayerChatLog", function(ply, text, public)
	FWLOG("[Player Chat] - " .. "<" .. ply:SteamID() .. "> " .. ply:Nick() .. ": " .. text )
end)

hook.Add("PlayerInitialSpawn", "LogPlayerSpawning", function(ply)
	FWLOG("[PLAYER SPAWNED] - " ..ply:Nick().. "(" ..ply:SteamID()..")")
end)

hook.Add("PlayerDeath", "LogDeath", function(v, w, k)
	if ( v == k ) or ( !k:IsPlayer() ) then
		FWLOG("[DEATH LOG] - " .. "<" .. v:SteamID() .. "> " .. v:Nick().. " KILLED THEMSELVES")
		return
	end
	
	FWLOG("[DEATH LOG] - " .. "<" .. v:SteamID() .. "> " .. v:Nick().. " was KILLED by " .. "<" .. k:SteamID() .. "> " .. k:Nick().. " using " ..k:GetActiveWeapon():GetClass())
end)

function FWLOG(information)
	local information = information or "[LOG] Function called unexpectedly"
	local date = os.date("%m_%d_%y")
	local numfiles = NUM_OF_FILES
	if ( file.Exists("logs/fortwars/"..date.."_"..GetConVarString("ip"):Replace(".","_").."/log"..numfiles..".txt", "DATA") ) then
		file.Append("logs/fortwars/"..date.."_"..GetConVarString("ip"):Replace(".","_").."/log"..numfiles..".txt", "\n" ..os.date("[%H:%M:%S]").. " " ..information)
	else
		file.Write("logs/fortwars/"..date.."_"..GetConVarString("ip"):Replace(".","_").."/log"..numfiles..".txt", "[LOG STARTED]\n" ..os.date("[%H:%M:%S]").. " " .. information)
	end
end