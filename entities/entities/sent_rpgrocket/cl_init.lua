ENT.Spawnable			= false
ENT.AdminSpawnable		= false

include( "shared.lua" )


function ENT:Think()

self.SmokeTimer = self.SmokeTimer or 0
	if ( self.SmokeTimer > CurTime() ) then return end
	
	self.SmokeTimer = CurTime() + 0.015

	local vOffset = self.Entity:LocalToWorld( Vector(0,0,self.Entity:OBBMins().z) )

	local vNormal = (vOffset - self.Entity:GetPos()):GetNormalized()

	local emitter = ParticleEmitter( vOffset )
	
		local particle = emitter:Add( "particles/fire1", vOffset )
			particle:SetVelocity( vNormal )
			particle:SetDieTime( 0.06 )
			particle:SetStartAlpha( math.Rand( 100, 150 ) )
			particle:SetStartSize( math.Rand( 2, 5 ) )
			particle:SetEndSize( math.Rand( 7, 15 ) )
			particle:SetRoll( math.Rand( -0.2, 0.2 ) )
			particle:SetColor( 200, 20, 20 )
			
		local particle = emitter:Add( "particles/smokey", vOffset )
			particle:SetVelocity( vNormal )
			particle:SetDieTime( 1.3 )
			particle:SetStartAlpha( math.Rand( 100, 150 ) )
			particle:SetStartSize( math.Rand( 5, 10 ) )
			particle:SetEndSize( math.Rand( 20, 40 ) )
			particle:SetRoll( math.Rand( -0.2, 0.2 ) )
			particle:SetColor( 20, 20, 20 )
				
	emitter:Finish()
	
end
