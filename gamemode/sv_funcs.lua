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
	//self:SaveAccount()
end

function meta:TakeMoney(i)
	self.cash = self.cash - i
	net.Start("updatecash")
		net.WriteInt(self.cash, 32)
	net.Send(self)
	//self:SaveAccount()
end

function meta:SetMoney(i)
	self.cash = i
	net.Start("updatecash")
		net.WriteInt(self.cash, 32)
	net.Send(self)
	//self:SaveAccount()
end

function meta:AddClass(i)
	table.insert(self.classes, i)
	net.Start("updateclasses")
		net.WriteTable(self.classes)
	net.Send(self)
	//self:SaveAccount()
end

function meta:AddSpecial(i)
	table.insert(self.specials, i)
	net.Start("updatespecials")
		net.WriteTable(self.specials)
	net.Send(self)
	//self:SaveAccount()
end

function meta:HasSpecial(i)
	if (table.HasValue(self.specials, i)) then return true else return false end
end

function meta:LevelUp(i)
	self.upgrades[i] = self.upgrades[i] + 1
	net.Start("updatelevels")
		net.WriteTable(self.upgrades)
	net.Send(self)
	//self:SaveAccount()
end

function meta:AddProp(i)
	table.insert(self.props, i)
	net.Start("updateprops")
		net.WriteTable(self.props)
	net.Send(self)
	//self:SaveAccount()
end

function meta:SetDonor(i)
	self.memberlevel = i
	net.Start("updatedonor")
		net.WriteInt(self.memberlevel, 32)
	net.Send(self)
	//self:SaveAccount()
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
	
	/*local json = util.TableToJSON(tbl)
	file.Write("fortwars/"..truncatedid..".txt", json)*/
end

function meta:SaveAccount()
    local steamid = DB.Escape(self:SteamID())
    local name = DB.Escape(self.name)
    local cash = self.cash
    local memberlevel = self.memberlevel
    local classes = util.TableToJSON(self.classes)
    local stats = util.TableToJSON(self.stats)
    
    DB.Query({sql = string.format([[
        INSERT INTO players
                    (steamid, name, cash, memberlevel, classes, stats, specials)
        VALUES      ("%s", "%s", %i, %i, "%s", "%s", "%s")
        ON DUPLICATE KEY UPDATE name = "%s", cash = %i, memberlevel = %i, classes = "%s", stats = "%s", specials = "%s"
    ]], steamid, name, cash, memberlevel, classes, stats, specials, name, cash, memberlevel, classes, stats, specials)})
    
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

function meta:SpawnPlayer()
    print("LETS SPAWN THE PLAAAAYYYYEEERRR")
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

        if v.ProfileLoadStatus == nil then
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
	end
end)

timer.Create("timeplayed",1,0,function()
	for i,v in pairs(player.GetAll()) do
        if v.ProfileLoadStatus == nil then
            v.stats[6] = v.stats[6] + 1
        end
	end
end)