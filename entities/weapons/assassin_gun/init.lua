if SERVER then AddCSLuaFile("shared.lua") end
include("shared.lua")
	
SWEP.HoldType = "ar2"
	
function SWEP:Deploy()
	self.Weapon:SetNWInt( "zoomed", 0 )
	return true
end

function SWEP:Holster()
	self.Weapon:SetNWInt( "zoomed", 0 )
	return true
end

function SWEP:SecondaryAttack()
	self.Weapon:SetNextSecondaryFire( CurTime() + self.Secondary.Delay )
	local zoomed = self.Weapon:GetNWInt("zoomed", 0)
	
	if(zoomed==0) then
		self.Weapon:SetNWInt("zoomed", 1)
		self.Owner:SetFOV(30, 0.1)
		
	elseif(zoomed==1) then
	
	 if self.Owner:HasSpecial(13) then
		self.Weapon:SetNWInt("zoomed", 2)
		self.Owner:SetFOV(10, 0.1)
	else
		self.Weapon:SetNWInt("zoomed", 0)
		self.Owner:SetFOV(0, 0.1)
	end
		
	elseif(zoomed==2) then
		self.Weapon:SetNWInt("zoomed", 0)
		self.Owner:SetFOV(0, 0.1)
	end
	
	self.Weapon:SetNWInt("prevzoom", self.Weapon:GetNWInt("zoomed"))
	print(self.Weapon:GetNWInt("prevzoom"))
end

function SWEP:Reload()
	if self.ReloadingTime and CurTime() <= self.ReloadingTime then return end
 
	--current clip less than max and 
	if ( self:Clip1() < self.Primary.ClipSize and self.Owner:GetAmmoCount( self.Primary.Ammo ) > 0 ) then
		
				self:SendWeaponAnim( ACT_VM_RELOAD )
				local AnimationTime = self.Owner:GetViewModel():SequenceDuration()

				self.Weapon:SetNWInt("zoomed", 0)
				self.Owner:SetFOV(0, 0.1)
				
				if self.Owner:HasSpecial(13) and self.Owner:Energy() >= 100 then	
					self.Owner:TakeEnergy(100)
					self.Owner:GetViewModel():SetPlaybackRate(2.0)
					self.Weapon:SetNWInt( "reloadtimer", CurTime() + 1.8 )
					AnimationTime = AnimationTime/2
				else
					self.Owner:GetViewModel():SetPlaybackRate(1.0)
					self.Weapon:SetNWInt( "reloadtimer", CurTime() + 3.6 )
				end
 
			    
                self.ReloadingTime = CurTime() + AnimationTime
                self:SetNextPrimaryFire(CurTime() + AnimationTime+.1)
				
				if self.ReloadingTime > CurTime() then 
					self.Weapon:SetClip1(self.Primary.ClipSize)
				end
				
				if self.Owner:GetInfo("fw_zoomaftereload") == "1" then
				
					timer.Simple(AnimationTime, function()
					
						if self.Weapon:GetNWInt("prevzoom") == 1 then
						
							self.Owner:SetFOV(30, 0.1)
							self.Weapon:SetNWInt("zoomed", 1)
							
						elseif self.Weapon:GetNWInt("prevzoom") == 2 then
						
							self.Owner:SetFOV(10, 0.1)
							self.Weapon:SetNWInt("zoomed", 2)
							
						else
						
							self.Owner:SetFOV(0, 0.1)
							self.Weapon:SetNWInt("zoomed", 0)
							
						end
					
					end)
				end
 
	end 
end