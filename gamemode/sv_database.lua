DEFAULT_STATS = {0, 0, 0, 0, 0, 0, 0,}
DEFAULT_UPGRADES = {0, 0, 0, 0, 0,}
DEFAULT_PROPS = {}

/*---------------------------------------------------------
  Handles profile creation for new players and profile loading
  for players that have already joined
---------------------------------------------------------*/

hook.Add("PlayerInitialSpawn", "CheckAccountsExist", function(ply)

    ply.ProfileLoadStatus = 0
    ply.DbData = {}
	
	local truncatedid = string.gsub(ply:SteamID(), ":", "_")
    
    local steamid = DB.Escape(ply:SteamID())
    local PlayerFound = false
    
    print("[Forwars MSG] Loading account: "..ply:Name().."["..ply:SteamID().."]...")
    DB.Query({sql = "SELECT * FROM players WHERE steamid = '"..steamid.."'", callback = 
        function(mData)
            if #mData != 0 then
                PlayerFound = true
                for k,v in pairs(mData[1]) do
                    ply.DbData[k] = v
                    
                end
            end
            ply.ProfileLoadStatus = ply.ProfileLoadStatus + 1
    
    
            DB.Query({sql = "SELECT * FROM upgrades WHERE steamid = '"..steamid.."'", callback = 
                function(mData)
                    if #mData != 0 then
                        local upgrades = {mData[1]['speed_limit'], mData[1]['health_limit'], mData[1]['energy_limit'], mData[1]['energy_regen'], mData[1]['fall_damage_resistance']}
                        ply.DbData['upgrades'] = upgrades
                    end
                    ply.ProfileLoadStatus = ply.ProfileLoadStatus + 1
                    
                    
                end
            })
        end
    })
    
    timer.Create(ply:SteamID().."_WaitProfile",1,60,function()
		
        if ply and ply:IsValid() then
            if ply.ProfileLoadStatus == 2 then
                // Compltely loaded
                print("Completely loaded player.")
                
                timer.Destroy(ply:SteamID().."_WaitProfile")
                ply.ProfileLoadStatus = nil
                
                if !table.IsEmpty(ply.DbData) && PlayerFound then
                    print("Player was loaded")
                    
                    ply.name = ply.DbData.name or ""
                    ply.cash = ply.DbData.cash or 0
                    ply.classes = util.JSONToTable(ply.DbData.classes) or {1, }
                    ply.specials = util.JSONToTable(ply.DbData.specials) or {1, }
                    ply.upgrades = ply.DbData.upgrades or DEFAULT_UPGRADES
                    ply.props = ply.DbData.props or DEFAULT_PROPS
                    ply.stats = util.JSONToTable(ply.DbData.stats) or DEFAULT_STATS
                    ply.memberlevel = ply.DbData.memberlevel or 1
                    
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
                    
                    ply.SpawnPlayer()
                    
                    ply:ChatPrint( "Your FortWars account has been loaded!" )
                    
                else
                    print("No player was found")
                    
                    --Create a new account upon joining if one does not exist
                    ply.name = ply:Name()
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
                    
                    
                    ply.SpawnPlayer()
                    
                    ply:ChatPrint( "A FortWars account has been created for you!" )
                end
            end
        end
	end)
end)

if ( !timer.Exists("accountsaveinterval") ) then
	timer.Create("accountsaveinterval", 1, 0, function() 
        //print("Saving all players.")
		for k, v in pairs (player.GetAll()) do
            if v.ProfileLoadStatus == nil then
                v:SaveAccount()
            end
		end
        //print("Saved all players.")
	end)
end

hook.Add("PlayerDisconnected", "DisconnectSaveAccount", function(ply)
	ply:SaveAccount()
end)

require("tmysql4")

DB = {}
DB.MySql = {}
DB.Connected = false
DB.Host = "hostaddress"
DB.Database = "databasename"
DB.Port = 3306
DB.Username = "admin"
DB.Password = "password"

function DB.Setup()
	print("[MySQL Msg] Checking / Creating Tables")

	DB.Query({sql = [[CREATE TABLE IF NOT EXISTS players
		(
			steamid VARCHAR(20),
			name VARCHAR(20),
			cash INT,
			memberlevel INT,
            classes VARCHAR(256),
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
        print("Alredy connected.")
    else
        print("Could not initialize database.")
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
hook.Add( "OnReloaded" , "OnReloadedHook" , function()
    DB.Disconnect()
    print("Current Connections:")
    PrintTable(tmysql.GetTable()) 
    for k,v in pairs(tmysql.GetTable()) do
        print(v)
        v:Disconnect() 
    end
    DB.Connected = false
    DB.Connect()
end)

