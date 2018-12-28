function EFFECT:Init( data ) 
	self.Pos = data:GetOrigin()
	self.Norm = data:GetNormal()
	self:EmitSound("ambient/explosions/explode_4.wav")
	
	self.Entity:SetPos(self.Pos)
	EMITTER = ParticleEmitter(self.Pos)


		for i=1,5 do			
			local stream = EMITTER:Add( "effects/yellowflare", self.Pos )
			if (stream) then
					
				local Vec2 = self.Norm + VectorRand()
				stream:SetVelocity( Vec2 * 2000 )			
				stream:SetLifeTime( 0 )
				stream:SetDieTime( 0.5 )				
				stream:SetStartAlpha( 250 )
				stream:SetEndAlpha( 0 )				
				stream:SetStartSize( 80 )
				stream:SetEndSize( 120 )
				stream:SetColor(150,150,140)
				stream:SetAirResistance( 300 )
				stream:SetGravity( Vector( 100, 100, -2000 ) )
				stream:SetLighting( true )
				stream:SetBounce( 0.01 )
				stream:SetThinkFunction(CrysisStyle)
				stream:SetNextThink(RealTime()+0.2)
			
			end
			
		end
	for i=1,3 do
		local centerboom = EMITTER:Add( "particles/smokey", self.Pos )
		if (centerboom) then	
			centerboom:SetVelocity( VectorRand()*1000 )				
			centerboom:SetLifeTime( 0 )
			centerboom:SetDieTime( math.random(3) )				
			centerboom:SetStartAlpha( 250 )
			centerboom:SetEndAlpha( 0 )				
			centerboom:SetStartSize( 15 )
			centerboom:SetEndSize( 400 )
			centerboom:SetColor(100,100,100)
			centerboom:SetAirResistance( 270 )
			centerboom:SetGravity( Vector( 0, 0, -10 ) )
			centerboom:SetLighting( true )
		end
	end
end
function EFFECT:Think() end
function EFFECT:Render() end
function CrysisStyle(stream)
	local pos = stream:GetPos()
	local smoke = EMITTER:Add( "particles/smokey",pos)
	if smoke then
		smoke:SetVelocity( VectorRand() )				
		smoke:SetLifeTime( 0 )
		smoke:SetDieTime( 0.2 )				
		smoke:SetStartAlpha( 200 )
		smoke:SetEndAlpha( 0 )				
		smoke:SetStartSize( 5 )
		smoke:SetEndSize( 30 )
		local col = math.random(50,150)
		smoke:SetColor(col,col,col)
		smoke:SetAirResistance( 250 )
		smoke:SetGravity( Vector( 0, 0, -100 ) )
		smoke:SetLighting( true )
	end
	stream:SetNextThink(RealTime()+0.2)
	return true
end

