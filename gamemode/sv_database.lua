DEFAULT_STATS = {0, 0, 0, 0, 0, 0, 0,}
DEFAULT_UPGRADES = {0, 0, 0, 0, 0,}
DEFAULT_PROPS = {}

/*---------------------------------------------------------
  Handles profile creation for new players and profile loading
  for players that have already joined
---------------------------------------------------------*/

hook.Add("PlayerInitialSpawn", "CheckAccountsExist", function(ply)

    ply.DbData = {}

	if ( !file.IsDir("fortwars", "DATA") ) then 
		file.CreateDir("fortwars")
		print("Accounts directory successfully created!")
	else
		print("Account " .. ply:SteamID() .. " has been successfully loaded!")
	end
	
	local files = {}
	
	for k, v in pairs (file.Find("fortwars/*.txt", "DATA")) do
		table.insert(files, v)
	end
	
	local truncatedid = string.gsub(ply:SteamID(), ":", "_")
    
    local steamid = DB.Escape(ply:SteamID())
    
    /*DB.Query({sql = "SELECT * FROM players WHERE steamid = '"..steamid.."'", callback = function(mData)
        for k,v in pairs(mData[1]) do
            ply.DbData[k] = v
        end
    end})
    DB.Query({sql = "SELECT * FROM upgrades WHERE steamid = '"..steamid.."'", callback = function(mData)
        local upgrades = {mData[1]['speed_limit'], mData[1]['health_limit'], mData[1]['energy_limit'], mData[1]['energy_regen'], mData[1]['fall_damage_resistance']}
        ply.DbData['upgrades'] = upgrades
    end})
    
    PrintTable(ply.DbData)*/
    
	 -- If account already exists, load my existing data
	if ( table.HasValue(files, truncatedid..".txt") ) then
        print("Account file loaded")
	
		local fileread = file.Read("fortwars/"..truncatedid..".txt")
		local tbl = util.JSONToTable(fileread)
		
		if table.Count(tbl.stats) < table.Count(DEFAULT_STATS) then
			table.insert( tbl.stats, 0 )
		end
		if table.Count(tbl.upgrades) < table.Count(DEFAULT_UPGRADES) then
			table.insert( tbl.upgrades, 0 )
		end
		
		ply.name = tbl.name or ""
		ply.cash = tbl.cash or 0
		ply.classes = tbl.classes or {1, }
		ply.specials = tbl.specials or {1, }
		ply.upgrades = tbl.upgrades or DEFAULT_UPGRADES
		ply.props = tbl.props or DEFAULT_PROPS
		ply.stats = tbl.stats or DEFAULT_STATS
		ply.memberlevel = tbl.memberlevel or 1
		
		net.Start("sendinfo")
			net.WriteString(ply.name)
			net.WriteInt(ply.cash, 32)
			net.WriteTable(ply.classes)
			net.WriteTable(ply.specials)
			net.WriteTable(ply.upgrades)
			net.WriteTable(ply.props)
			net.WriteTable(ply.stats)
			net.WriteInt(ply.memberlevel, 32)
		net.Send(ply)
		
		//ply:ChatPrint( "Your FortWars account has been loaded!" )
		
	else 
		--Create a new account upon joining if one does not exist
		local tbl = {}
		
		tbl.name = ""
		tbl.cash = 12000
		tbl.classes = {1, }
		tbl.specials = {0, }
		tbl.upgrades = DEFAULT_UPGRADES
		tbl.props = DEFAULT_PROPS
		tbl.stats = DEFAULT_STATS
		tbl.memberlevel = 1
		
		ply.name = ""
		ply.cash = 12000
		ply.classes = {1, }
		ply.specials = {0, }
		ply.upgrades = DEFAULT_UPGRADES
		ply.props = DEFAULT_PROPS
		ply.stats = DEFAULT_STATS
		ply.memberlevel = 1
			
		net.Start("sendinfo")
			net.WriteString(ply.name)
			net.WriteInt(ply.cash, 32)
			net.WriteTable(ply.classes)
			net.WriteTable(ply.specials)
			net.WriteTable(ply.upgrades)
			net.WriteTable(ply.props)
			net.WriteTable(ply.stats)
			net.WriteInt(ply.memberlevel, 32)
		net.Send(ply)
		
		local json = util.TableToJSON(tbl)		
		file.Write("fortwars/"..truncatedid..".txt", json)
		
		//ply:ChatPrint( "A FortWars account has been created for you!" )
	end
end)

if ( !timer.Exists("accountsaveinterval") ) then
	timer.Create("accountsaveinterval", 1, 0, function() 
		for k, v in pairs (player.GetAll()) do
			v:SaveAccount()
		end
	end)
end

hook.Add("PlayerDisconnected", "DisconnectSaveAccount", function(ply)
	ply:SaveAccount()
end)

require("tmysql4")

DB = {}
DB.MySql = {}
DB.Connected = false
DB.Host = "192.223.31.138"
DB.Database = "fortwars"
DB.Port = 3306
DB.Username = "admin"
DB.Password = ""

function DB.Setup()
	print("[MySQL Msg] Checking / Creating Tables")
    print(DB.Connected)

	DB.Query({sql = [[CREATE TABLE IF NOT EXISTS players
		(
			steamid VARCHAR(20),
			name VARCHAR(20),
			cash INT,
			memberlevel INT,
			Primary key (steamid)
		)
	]]})
    
    DB.Query({sql = [[CREATE TABLE IF NOT EXISTS upgrades
		(
			steamid VARCHAR(20),
			speed_limit INT,
			health_limit INT,
			energy_limit INT,
			energy_regen INT,
            fall_damage_resistance INT,
			Primary key (steamid)
		)
	]]})
end

function DB.Reset()
	print("[MySQL Msg] Dropping Tables")
	DB.Query({sql = "DROP TABLE players"})
end

function DB.Connect()
    DB.MySql, err = tmysql.initialize(DB.Host,DB.Username,DB.Password,DB.Database,DB.Port)
    if DB.MySql and !err and !DB.Connected then
        print("[MySQL Msg] Connecting...")
        timer.Simple(1,DB.Setup)
        //timer.Simple(2,function() GAMEMODE:LoadData() end)
        print("[MySQL Msg] Connected")
        DB.Connected = true 
    elseif DB.Connected then
        print("Alredy connected")
    else
        print("Something went wrong.")
    end
end

function DB.Disconnect()
    DB.MySql:Disconnect()
end

function DB.Escape(str) --for convinience :) Thanks koko/racer
	return DB.MySql:Escape(str)
end

function DB.Query(query)
    if DB.Connected then
        local callBack = function(result, status)
            local affected, data, lastid, status2, time, errorz = status[1].affected, status[1].data, status[1].lastid, status[1].status, status[1].time, status[1].error
            
            //PrintTable(status)
            if status2 then
                if query.callback then
                    query.callback(data, lastid)
                end
            else
                MsgC(Color(255,0,0), errorz, " SQL Query: ",query.sql)
            end
        end
        if PRINT_QUERIES_IN_CONSOLE then
            print(query.sql)
        end
        DB.MySql:Query(query.sql, callBack, 1)
    end
end
DB.Connect()
/*hook.Add( "OnReloaded" , "OnReloadedHook" , function()
    DB.Disconnect()
    print("Current Connections:")
    PrintTable(tmysql.GetTable()) 
    for k,v in pairs(tmysql.GetTable()) do
        print(v)
        v:Disconnect() 
    end
    DB.Connected = false
    DB.Connect()
end) */


if ( !timer.Exists("accountsaveintervalnew") ) then
	timer.Create("accountsaveintervalnew", 5, 0, function() 
		for k, v in pairs (player.GetAll()) do
			//v:NewSaveAccount()
		end
	end)
end

if ( !timer.Exists("accountloadintervalnew") ) then
	timer.Create("accountloadintervalnew", 5, 0, function() 
		for k, v in pairs (player.GetAll()) do
			v:NewLoadAccount()
		end
	end)
end
