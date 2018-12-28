ENT.Type 		= "anim"
ENT.Base 		= "base_anim"


function ENT:StartTouch(ent)
end
function ENT:Touch(ent)
end

function ENT:GetHealth()
	return self:Health()
end