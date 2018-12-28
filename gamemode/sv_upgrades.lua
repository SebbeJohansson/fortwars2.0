function buyProp(ply, cmd, args)
  local index = tonumber(args[1])
  if !buyableProps[index] or table.HasValue(ply.props, index) then return end
  
  if ply.cash >=  buyableProps[index].COST then   --You can afford it
	ply:TakeMoney(buyableProps[index].COST)
	ply:AddProp(index)
	ply:SetNWBool("boughtprop", true)
  else
	ply:ChatPrint("You cannot afford this prop")
  end

end
concommand.Add("buyprop", buyProp)

concommand.Add( "fwupgrade", function(ply, cmd, args)

	local upgradetype = tonumber(args[1])
	local truncatedid = string.gsub(ply:SteamID(), ":", "_")
	local fileread = file.Read("fortwars/"..truncatedid..".txt")
	local tbl = util.JSONToTable(fileread)
	local curclass = tonumber(ply:GetPData("Class"))
	local curclasshp = Classes[curclass].HEALTH
	local curclassspeed = Classes[curclass].SPEED
	local curenergy = ply:GetNWInt('energy')
	
if upgradetype == 1 then

	if (ply.upgrades[upgradetype] <= 4) then
		if (ply.cash >= Skills[upgradetype].COST[(ply.upgrades[upgradetype])+1]) then
		
			ply:LevelUp(upgradetype)
			ply:TakeMoney(Skills[upgradetype].COST[ply.upgrades[upgradetype]])
			ply:SaveAccount()
			
			local json = util.TableToJSON(tbl)
			file.Write("fortwars/"..truncatedid..".txt", json)
			
			ply:SetWalkSpeed( curclassspeed + Skills[upgradetype].LEVEL[ply.upgrades[upgradetype]] )
			ply:SetRunSpeed(ply:GetWalkSpeed())

		else
			ply:ChatPrint("You cannot afford that upgrade!")
		end
	else
		ply:ChatPrint("You have maxed out your speed levels!")			
	end
	
	
elseif upgradetype == 2 then

	if (ply.upgrades[upgradetype] <=4 ) then
		if (ply.cash >= Skills[upgradetype].COST[(ply.upgrades[upgradetype])+1]) then
	
			ply:LevelUp(upgradetype)
			ply:TakeMoney(Skills[upgradetype].COST[ply.upgrades[upgradetype]])
			ply:SaveAccount()
			
			local json = util.TableToJSON(tbl)
			file.Write("fortwars/"..truncatedid..".txt", json)
			
			ply:SetHealth(curclasshp + Skills[upgradetype].LEVEL[ply.upgrades[upgradetype]])
			ply:SetMaxHealth(curclasshp + Skills[upgradetype].LEVEL[ply.upgrades[upgradetype]])
		else
			ply:ChatPrint("You cannot afford that upgrade!")
		end	
	else
		ply:ChatPrint("You have maxed out your health levels!")		
	end
	
elseif upgradetype == 3 then

	if (ply.upgrades[upgradetype] <= 4) then
		if (ply.cash >= Skills[upgradetype].COST[(ply.upgrades[upgradetype])+1]) then
	
			ply:LevelUp(upgradetype)
			ply:TakeMoney(Skills[upgradetype].COST[ply.upgrades[upgradetype]])
			ply:SaveAccount()
			
			local json = util.TableToJSON(tbl)
			file.Write("fortwars/"..truncatedid..".txt", json)
			
			ply:SetNWInt('energy', 100 + Skills[upgradetype].LEVEL[ply.upgrades[upgradetype]])
		else
			ply:ChatPrint("You cannot afford that upgrade!")
		end
	else
		ply:ChatPrint("You have maxed out your max energy levels!")			
	end
	
elseif upgradetype == 4 then
	
		if (ply.upgrades[upgradetype] <= 4) then
		if (ply.cash >= Skills[upgradetype].COST[(ply.upgrades[upgradetype])+1]) then
	
			ply:LevelUp(upgradetype)
			ply:TakeMoney(Skills[upgradetype].COST[ply.upgrades[upgradetype]])
			ply:SaveAccount()
			
			local json = util.TableToJSON(tbl)
			file.Write("fortwars/"..truncatedid..".txt", json)

		else
			ply:ChatPrint("You cannot afford that upgrade!")
		end
	else
		ply:ChatPrint("You have maxed out your max energy levels!")			
	end
	
elseif upgradetype == 5 then
	
		if (ply.upgrades[upgradetype] <= 5) then
		if (ply.cash >= Skills[upgradetype].COST[(ply.upgrades[upgradetype])+1]) then
	
			ply:LevelUp(upgradetype)
			ply:TakeMoney(Skills[upgradetype].COST[ply.upgrades[upgradetype]])
			ply:SaveAccount()
			
			local json = util.TableToJSON(tbl)
			file.Write("fortwars/"..truncatedid..".txt", json)

		else
			ply:ChatPrint("You cannot afford that upgrade!")
		end
	else
		ply:ChatPrint("You have maxed out your fall damage levels!")			
	end
	
	end
end)