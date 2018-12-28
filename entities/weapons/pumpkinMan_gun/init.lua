AddCSLuaFile( "shared.lua" )
include("shared.lua")

function SWEP:pumpkin()
  local spos = self.Owner:GetShootPos()
  local aim = self.Owner:GetAimVector()
  local pos = spos + (aim * 50)
  pos = pos + (self.Owner:GetRight() * 10)
  local pumpkin = ents.Create( "sent_pumpkin" )  
  pumpkin:SetOwner( self.Owner )
  pumpkin.Owner = self // The weapon is the owner
  pumpkin.LastHolder = self.Owner
  pumpkin.Team = self.Owner:Team()
  pumpkin:SetPos( pos )
  pumpkin:SetAngles( self:GetAngles() )
  pumpkin:Spawn()
  pumpkin:Activate()
  
  self.Owner:ViewPunch( Angle( math.Rand( 0, -10 ), math.Rand( 0, 0 ), math.Rand( 0, 0 ) ) )  
end

function SWEP:SecondaryAttack()
  //if !self.Owner:HasSpecialAbility(PUMPKINMAN) then self.Owner:ChatPrint("You do not have the special ability for this class. Press F1 and look in the Classes tab to buy it.") return end
  if self.lastSound <= CurTime() then
      self.Owner:EmitSound("darkland/fortwars/wickedmalelaugh"..math.random(3)..".wav")
    self.lastSound = CurTime() + 8
  end
end