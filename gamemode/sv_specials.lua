//Note: Only some of the special abilities are in this file. Any that are not would be in the weapon files themselves (e.g Swat)

----------------
--Advancer
---------------

hook.Add("KeyPress","advancerDash",function(ply,key)

	local pos = ply:GetPos()
	local tr = {}
	tr.start = Vector(pos.x, pos.y, pos.z)
	tr.endpos = Vector(pos.x, pos.y, pos.z-250)
	tr.filter = ply
	local trace = util.TraceLine( tr )
	
    if ply:Energy() >= ADVANCER_MANA_COST and ply:HasSpecial(14) and IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetClass() == "advancer_gun" and (trace.Hit) then
	
	if ply:GetInfo( "fw_advcrouch" ) == "1" and !ply:KeyDown(IN_DUCK) then return end
	
    if key == IN_MOVELEFT then
	  timer.Simple(0.001, function() ply.lastLeft = CurTime() end)
        if ply.lastLeft + 0.2 >= CurTime() then -- tapped the key twice, sometimes it goes over 2
          ply:SetVelocity((ply:GetRight()*-1) * 2000)
          ply:TakeEnergy(ADVANCER_MANA_COST)
        end
        
      elseif key == IN_MOVERIGHT then
		timer.Simple(0.001, function() ply.lastRight = CurTime() end)
        if ply.lastRight + 0.2 >= CurTime() then
          ply:SetVelocity(ply:GetRight()*2000)
		  print(ply:GetPData("advancercrouch"))
          ply:TakeEnergy(ADVANCER_MANA_COST)
			end	
		end
	end
end)

----------------
--Ninja (on ground)
----------------

hook.Add("KeyPress","ninjaJump",function(ply,key)
	local special = ply:GetNWBool("superjump", false)
	
		if ( special == true ) then
		timer.Simple(2, function() ply:SetNWBool("superjump", false) end)
		
		if key == IN_JUMP and ply:OnGround() then
		
		if ply:HasSpecial(3) then
			ply:SetVelocity( Vector(0, 0, 800) )
			ply:SetNWBool("superjump", false)
		else
			ply:ChatPrint("You do not own this special ability!")
			end
		end
		
	end
end)