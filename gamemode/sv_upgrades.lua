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

concommand.Add("fwupgrade", function(ply, cmd, args)

    local upgradetype = args[1]
    local truncatedid = string.gsub(ply:SteamID(), ":", "_")
    local tbl = ply.upgrades
    local curclass = tonumber(ply:GetPData("Class"))
    local curclasshp = Classes[curclass].HEALTH
    local curclassspeed = Classes[curclass].SPEED
    local curenergy = ply:GetNWInt('energy')

    print(upgradetype)

    if (ply.upgrades[upgradetype] <= #Skills[upgradetype].COST-1) then
      if (ply.cash >= Skills[upgradetype].COST[(ply.upgrades[upgradetype])+1]) then

        ply:LevelUp(upgradetype)
        ply:TakeMoney(Skills[upgradetype].COST[ply.upgrades[upgradetype]])
        ply:SaveAccount()
        
        if upgradetype == "speed_limit" then
          ply:SetWalkSpeed( curclassspeed + Skills[upgradetype].LEVEL[ply.upgrades[upgradetype]] )
          ply:SetRunSpeed(ply:GetWalkSpeed())
        elseif upgradetype == "health_limit" then
          ply:SetHealth(curclasshp + Skills[upgradetype].LEVEL[ply.upgrades[upgradetype]])
          ply:SetMaxHealth(curclasshp + Skills[upgradetype].LEVEL[ply.upgrades[upgradetype]])
        elseif upgradetype == "energy_limit" then
          ply:SetNWInt('energy', 100 + Skills[upgradetype].LEVEL[ply.upgrades[upgradetype]])
        end

      else
        ply:ChatPrint("You cannot afford that upgrade!")
      end
    else
      ply:ChatPrint("You have maxed out your "..Skills[upgradetype].NAME.." upgrade!")			
    end


    /*if upgradetype == "speed_limit" then

      if (ply.upgrades[upgradetype] <= #Skills[upgradetype].COST-1) then
        if (ply.cash >= Skills[upgradetype].COST[(ply.upgrades[upgradetype])+1]) then

          ply:LevelUp(upgradetype)
          ply:TakeMoney(Skills[upgradetype].COST[ply.upgrades[upgradetype]])
          ply:SaveAccount()

          ply:SetWalkSpeed( curclassspeed + Skills[upgradetype].LEVEL[ply.upgrades[upgradetype]] )
          ply:SetRunSpeed(ply:GetWalkSpeed())

        else
          ply:ChatPrint("You cannot afford that upgrade!")
        end
      else
        ply:ChatPrint("You have maxed out your speed levels!")			
      end


    elseif upgradetype == "health_limit" then

      if (ply.upgrades[upgradetype] <= #Skills[upgradetype].COST-1) then
        if (ply.cash >= Skills[upgradetype].COST[(ply.upgrades[upgradetype])+1]) then

          ply:LevelUp(upgradetype)
          ply:TakeMoney(Skills[upgradetype].COST[ply.upgrades[upgradetype]])
          ply:SaveAccount()

          ply:SetHealth(curclasshp + Skills[upgradetype].LEVEL[ply.upgrades[upgradetype]])
          ply:SetMaxHealth(curclasshp + Skills[upgradetype].LEVEL[ply.upgrades[upgradetype]])
        else
          ply:ChatPrint("You cannot afford that upgrade!")
        end	
      else
        ply:ChatPrint("You have maxed out your health levels!")		
      end

    elseif upgradetype == "energy_limit" then

      if (ply.upgrades[upgradetype] <= #Skills[upgradetype].COST-1) then
        if (ply.cash >= Skills[upgradetype].COST[(ply.upgrades[upgradetype])+1]) then

          ply:LevelUp(upgradetype)
          ply:TakeMoney(Skills[upgradetype].COST[ply.upgrades[upgradetype]])
          ply:SaveAccount()

          ply:SetNWInt('energy', 100 + Skills[upgradetype].LEVEL[ply.upgrades[upgradetype]])
        else
          ply:ChatPrint("You cannot afford that upgrade!")
        end
      else
        ply:ChatPrint("You have maxed out your max energy levels!")			
      end

    elseif upgradetype == "energy_regen" then

      if (ply.upgrades[upgradetype] <= #Skills[upgradetype].COST-1) then
        if (ply.cash >= Skills[upgradetype].COST[(ply.upgrades[upgradetype])+1]) then

          ply:LevelUp(upgradetype)
          ply:TakeMoney(Skills[upgradetype].COST[ply.upgrades[upgradetype]])
          ply:SaveAccount()
        else
          ply:ChatPrint("You cannot afford that upgrade!")
        end
      else
        ply:ChatPrint("You have maxed out your max energy levels!")			
      end

    elseif upgradetype == "fall_damage_resistance" then

      if (ply.upgrades[upgradetype] <= #Skills[upgradetype].COST-1) then
        if (ply.cash >= Skills[upgradetype].COST[(ply.upgrades[upgradetype])+1]) then

          ply:LevelUp(upgradetype)
          ply:TakeMoney(Skills[upgradetype].COST[ply.upgrades[upgradetype]])
          ply:SaveAccount()

        else
          ply:ChatPrint("You cannot afford that upgrade!")
        end
      else
        ply:ChatPrint("You have maxed out your fall damage levels!")			
      end

    end*/
  end)