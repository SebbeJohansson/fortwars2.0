AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

function ENT:Initialize()
	self:PhysicsInitBox( Vector( -16, -16, -1 ), Vector( 16, 16, 73 ) )
	self:SetCollisionBounds( Vector( -16, -16, -1 ), Vector( 16, 16, 73 ) )
	self:SetSolid( SOLID_BBOX )
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	self:SetMoveType( MOVETYPE_NONE )
	self:DrawShadow( false )
	self.enabled = true
	self:SetTrigger(true)
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:EnableMotion(false)
		phys:Sleep()
	end

	local ent = ents.Create( "prop_dynamic" )
	ent:SetRenderMode( RENDERMODE_TRANSALPHA )
	ent:SetPos(self:GetPos())
	ent:SetAngles(self:GetAngles())
	ent:SetModel("models/PLAYER.mdl")
	ent:SetMaterial("models/debug/debugwhite")
	ent:SetNotSolid(true)
	ent:DrawShadow(false)
	if self.color then ent:SetColor( Color(self.color.r, self.color.g, self.color.b, 120) ) end
	ent:Spawn()
	ent:Activate()
	self.effect = ent

end


function ENT:Enable()
	self:SetNotSolid(false)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	self.effect:SetNoDraw(false)
	self.enabled = true
end

function ENT:Disable()
	self:SetNotSolid(true)
	self:SetCollisionGroup(COLLISION_GROUP_NONE)
	self.effect:SetNoDraw(true)
	self.enabled = false
end

function ENT:StartTouch(ent)
	if ent.tbl then
		if !ent:GetPhysicsObject():IsMoveable() then
			ent:Remove()
		end
	end
	if ent:IsPlayer() and self.enabled then
		self:SetNotSolid(true)
		timer.Simple(0.1,function()self:SetNotSolid(false)self:SetCollisionGroup(COLLISION_GROUP_WEAPON)end)
	end
end


function ENT:Touch(ent)
	if ent:GetName() == "box" then
		local r,g,b,a = ent:GetColor()
		ent.oldcolor = Color(r,g,b,a)
		ent:SetColor( ent.oldcolor.r, ent.oldcolor.g, ent.oldcolor.b, 100 )
	end
end

function ENT:EndTouch(ent)
	if ent:GetName() == "box" then
		SpawnBoxes[ent:EntIndex()] = nil
		ent:SetColor( ent.oldcolor.r, ent.oldcolor.g, ent.oldcolor.b, 255 )
	end
end

function ENT:OnTakeDamage(something) --spammed consolelooking for this
end

function ENT:PhysicsUpdate(something) --spammed consolelooking for this
end

function ENT:PhysicsCollide(something) --spammed consolelooking for this
end
function ENT:Use(something) --spammed consolelooking for this
end