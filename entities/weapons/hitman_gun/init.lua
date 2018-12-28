AddCSLuaFile("shared.lua")
include("shared.lua")
	
	
function SWEP:Holster()
	self.Weapon:SetNWInt("zoomed", 0)
	self.Owner:SetFOV(0, 0.5)
	return true
end
function SWEP:Deploy()
	self.Weapon:SetNWInt("zoomed", 0)
	self.Owner:SetFOV(0, 0.5)
	return true
end

function SWEP:SecondaryAttack()
	self.Weapon:SetNextSecondaryFire( CurTime() + self.Secondary.Delay )
	local zoomed = self.Weapon:GetNWInt("zoomed", 0)
	
	if(zoomed==0) then
		self.Weapon:SetNWInt("zoomed", 1)
		self.Owner:SetFOV(30, 0.1)
	elseif(zoomed==1) then
		self.Weapon:SetNWInt("zoomed", 0)
		self.Owner:SetFOV(0, 0.1)
	end
end

function SWEP:Reload()

	if self:Clip1() > 0 then return end
  
    self.Weapon:SetNWInt("zoomed", 0)
    self.Owner:SetFOV(0, 0.1)
    self:DefaultReload( ACT_VM_RELOAD )
	local AnimationTime = self.Owner:GetViewModel():SequenceDuration()
	
				if self.Owner:GetInfo("fw_zoomaftereload") == "1" then
				
					timer.Simple(AnimationTime, function()
					
						if self.Weapon:GetNWInt("prevzoom") == 1 then
						
							self.Owner:SetFOV(30, 0.1)
							self.Weapon:SetNWInt("zoomed", 1)
							
						else
						
							self.Owner:SetFOV(0, 0.1)
							self.Weapon:SetNWInt("zoomed", 0)
							
						end
					
					end)
				end

end
