local ply = FindMetaTable("Player")

function ply:ClassLoad()
	if(self:GetPData("Class") == nil) then
		self:SetPData("Class", 1)
	else
		self:SetPData("Class", self:GetPData("Class"))
	end
end

concommand.Add( "fwclass", function(ply, cmd, args)
	
    if ply.ProfileLoadStatus == nil then
        local class = tonumber(args[1])
        local truncatedid = string.gsub(ply:SteamID(), ":", "_")
        local classcost = Classes[class].COST
        local classtbl = ply.classes
        
        if !( table.HasValue(classtbl, class) ) then
            
            if (ply.cash >= classcost) then
                ply:TakeMoney(classcost)
                ply:AddClass(class)
            else
                ply:ChatPrint("You do not have enough money to purchase this class!")
            end
                
        elseif ( table.HasValue(classtbl, class) ) then
            
            if ply:Alive() then
                ply:Kill()
            end
            
            ply:SetPData("Class", class )
        end
    end
end)

concommand.Add( "buyspecial", function(ply, cmd, args)
	
    if ply.ProfileLoadStatus == nil then
        local class = tonumber(args[1])
        local truncatedid = string.gsub(ply:SteamID(), ":", "_")
        local speccost = Classes[class].SPECIALABILITY_COST
        local spectbl = ply.specials
        
        if !( table.HasValue(spectbl, class) ) then
            
            if (ply.cash >= speccost) then
                ply:TakeMoney(speccost)
                ply:AddSpecial(class)
            else
                ply:ChatPrint("You do not have enough money to purchase this special ability!")
            end
                
        elseif ( table.HasValue(spectbl, class) ) then
                ply:ChatPrint("You already have this special ability!")
                
        end
    end
end)