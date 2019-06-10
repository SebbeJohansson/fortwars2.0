local meta = FindMetaTable("Player")

util.AddNetworkString("sendinfo")
util.AddNetworkString("updatecash")
util.AddNetworkString("updateclasses")
util.AddNetworkString("updatespecials")
util.AddNetworkString("updatelevels")
util.AddNetworkString("updateprops")
util.AddNetworkString("updatedonor")

function meta:GetMoney()
	return self.cash
end

function meta:Energy()
	return self:GetNWInt('energy')
end

function meta:TakeEnergy(i)
	self:SetNWInt('energy', (self:GetNWInt('energy') - i))
	return self:GetNWInt('energy')
end

function meta:AddMoney(i)
	self.cash = self.cash + i
	net.Start("updatecash")
		net.WriteInt(self.cash, 32)
	net.Send(self)
	self:SaveAccount()
end

function meta:TakeMoney(i)
	self.cash = self.cash - i
	net.Start("updatecash")
		net.WriteInt(self.cash, 32)
	net.Send(self)
	self:SaveAccount()
end

function meta:SetMoney(i)
	self.cash = i
	net.Start("updatecash")
		net.WriteInt(self.cash, 32)
	net.Send(self)
	self:SaveAccount()
end

function meta:AddClass(i)
	table.insert(self.classes, i)
	net.Start("updateclasses")
		net.WriteTable(self.classes)
	net.Send(self)
	self:SaveAccount()
end

function meta:AddSpecial(i)
	table.insert(self.specials, i)
	net.Start("updatespecials")
		net.WriteTable(self.specials)
	net.Send(self)
	self:SaveAccount()
end

function meta:HasSpecial(i)
	if (table.HasValue(self.specials, i)) then return true else return false end
end

function meta:LevelUp(i)
	self.upgrades[i] = self.upgrades[i] + 1
	net.Start("updatelevels")
		net.WriteTable(self.upgrades)
	net.Send(self)
	self:SaveAccount()
end

function meta:AddProp(i)
	table.insert(self.props, i)
	net.Start("updateprops")
		net.WriteTable(self.props)
	net.Send(self)
	self:SaveAccount()
end

function meta:SetDonor(i)
	self.memberlevel = i
	net.Start("updatedonor")
		net.WriteInt(self.memberlevel, 32)
	net.Send(self)
	self:SaveAccount()
end

function meta:IsPremium()
	if self.memberlevel == 2 then return true else return false end
end

function meta:IsPlatinum()
	if self.memberlevel == 3 then return true else return false end
end

function meta:Gib( norm )
	local effectdata = EffectData()
	effectdata:SetOrigin( self:GetPos() )
	effectdata:SetNormal( norm )
	util.Effect( "gib_player", effectdata )
end

function meta:SaveAccount()
	local truncatedid = string.gsub(self:SteamID(), ":", "_")
	local tbl = {}
	local classes = {}
	local specials = {}
	local upgrades = {}
	local props = {}
	local stats = {}
	local memberlevel = {}
	
	tbl.name = self.name
	tbl.cash = self.cash
	tbl.classes = self.classes
	tbl.specials = self.specials
	tbl.upgrades = self.upgrades
	tbl.props = self.props
	tbl.stats = self.stats
	tbl.memberlevel = self.memberlevel
	
	local json = util.TableToJSON(tbl)
	file.Write("fortwars/"..truncatedid..".txt", json)
end

function meta:NewSaveAccount()
    local steamid = DB.Escape(self:SteamID())
    local name = DB.Escape(self.name)
    local cash = self.cash
    local memberlevel = self.memberlevel
    
    print("Saved "..steamid)
    
    DB.Query({sql = string.format([[
        INSERT INTO players
                    (steamid, name, cash, memberlevel)
        VALUES      ("%s", "%s", %i, %i)
        ON DUPLICATE KEY UPDATE name = "%s", cash = %i, memberlevel = %i
    ]], steamid, name, cash, memberlevel, name, cash, memberlevel)})
    
    local speed_limit               = self.upgrades[1]
    local health_limit              = self.upgrades[2]
    local energy_limit              = self.upgrades[3]
    local energy_regen              = self.upgrades[4]
    local fall_damage_resistance    = self.upgrades[5]
    
    DB.Query({sql = string.format([[
        INSERT INTO upgrades
                    (steamid, speed_limit, health_limit, energy_limit, energy_regen, fall_damage_resistance)
        VALUES      ("%s", %i, %i, %i, %i, %i)
        ON DUPLICATE KEY UPDATE speed_limit = %i, health_limit = %i, energy_limit = %i, energy_regen = %i, fall_damage_resistance = %i
    ]], steamid, speed_limit, health_limit, energy_limit, energy_regen, fall_damage_resistance, speed_limit, health_limit, energy_limit, energy_regen, fall_damage_resistance)})
    
end

function meta:NewLoadAccount()
    print("[Forwars MSG] Loading account: "..self:Name().."["..self:SteamID().."]...")
    local steamid = DB.Escape(self:SteamID())
    self.DbData['data_loaded'] = false
    
    DB.Query({sql = "SELECT * FROM players WHERE steamid = '"..steamid.."'", callback = function(mData)
        for k,v in pairs(mData[1]) do
            self.DbData[k] = v
        end
        DB.Query({sql = "SELECT * FROM upgrades WHERE steamid = '"..steamid.."'", callback = function(mData)
            
            local upgrades = {mData[1]['speed_limit'], mData[1]['health_limit'], mData[1]['energy_limit'], mData[1]['energy_regen'], mData[1]['fall_damage_resistance']}
            self.DbData['upgrades'] = upgrades
            self.DbData['data_loaded'] = true
            print("All player data is loaded. Let player spawn.")
            print(self.DbData['cash'])
            
            /*net.Start("sendinfo")
                net.WriteInt(self.DbData['cash'], 32)
            net.Send(self)*/
            
            net.Start("sendinfo")
                net.WriteString(self.name)
                net.WriteInt(self.DbData['cash'], 32)
                net.WriteTable(self.classes)
                net.WriteTable(self.specials)
                net.WriteTable(self.DbData['upgrades'])
                net.WriteTable(self.props)
                net.WriteTable(self.stats)
                net.WriteInt(self.DbData['memberlevel'], 32)
            net.Send(self)
            
            /*umsg.Start("SetCanJoinTeam", self)
                umsg.Bool(true)
            umsg.End()*/
        end})
    end})
    
    //PrintTable(self.DbData)
    
    
    /*net.Start( "SyncPlayer" )
        net.WriteTable( self.DbData )
    net.Send(self)*/
    
end

function meta:SpawnPlayer()
        
end


function EnergyRegen(ply)
	ply:SetNWInt('energy', ply:GetNWInt('energy') + tonumber(Skills[4].LEVEL[ply.upgrades[4]]))
	ply:SetNWInt('energy', (math.Clamp( ply:GetNWInt('energy'), 0, 100 + Skills[3].LEVEL[ply.upgrades[3]] )))
end

function EnergyFreeze(ply)
	ply:SetNWInt('energy', ply:GetNWInt('energy'))
	ply:SetNWInt('energy', (math.Clamp( ply:GetNWInt('energy'), 0, 100 + Skills[3].LEVEL[ply.upgrades[3]] )))
end

function EnergyDrainPred(ply)
	ply:SetNWInt('energy', ply:GetNWInt('energy') - (PRED_DRAIN_RATE/10) )
	ply:SetNWInt('energy', (math.Clamp( ply:GetNWInt('energy'), 0, 100 + Skills[3].LEVEL[ply.upgrades[3]] )))
end

function EnergyDrainRaid(ply)
	ply:SetNWInt('energy', ply:GetNWInt('energy') - 2.5 )
	ply:SetNWInt('energy', (math.Clamp( ply:GetNWInt('energy'), 0, 100 + Skills[3].LEVEL[ply.upgrades[3]] )))
end

timer.Create("energyTimer",0.1,0,function()

	for i,v in pairs(player.GetAll()) do

		if v:GetNWBool( "cloaked" ) == false and v:GetNWBool( "raidrunning" ) == false and tonumber(v:GetPData("Class")) != 2 then
			EnergyRegen(v)
		elseif v:GetNWBool( "cloaked" ) == true then
			EnergyDrainPred(v)
		elseif v:GetNWBool( "raidrunning" ) == true then
			EnergyDrainRaid(v)
		elseif tonumber(v:GetPData("Class")) == 2 then
			EnergyFreeze(v)
		else return end
	end
end)

timer.Create("timeplayed",1,0,function()
	for i,v in pairs(player.GetAll()) do
		v.stats[6] = v.stats[6] + 1
	end
end)