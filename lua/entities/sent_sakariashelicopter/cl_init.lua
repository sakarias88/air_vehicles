include('shared.lua')


function ENT:Initialize()
end

function ENT:Draw()
	
	self:DrawModel()
	local doDraw = self:GetNetworkedBool("IsOn")
	
	
	if doDraw then
		local emitter = ParticleEmitter( self:GetPos() )
		local particle = emitter:Add( "sprites/heatwave", self:LocalToWorld( Vector(-80, 0, -10) ))
		particle:SetVelocity( self:GetVelocity() + self:GetForward() * math.Rand(0, -150))
		particle:SetDieTime(0.2)
		particle:SetStartSize(20)
		particle:SetEndSize(0)
		emitter:Finish()     
	end
	
	
end      