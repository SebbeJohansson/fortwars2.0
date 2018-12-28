DEFAULT_STATS = {0, 0, 0, 0, 0, 0, 0,}
DEFAULT_UPGRADES = {0, 0, 0, 0, 0,}
DEFAULT_PROPS = {}

/*---------------------------------------------------------
  Handles profile creation for new players and profile loading
  for players that have already joined
---------------------------------------------------------*/

hook.Add("PlayerInitialSpawn", "CheckAccountsExist", function(ply)

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

	 -- If account already exists, load my existing data
	if ( table.HasValue(files, truncatedid..".txt") ) then
	
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
		
		ply:ChatPrint( "Your FortWars account has been loaded!" )
		
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
		
		ply:ChatPrint( "A FortWars account has been created for you!" )
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