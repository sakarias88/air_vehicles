//Scripts
resource.AddFile( "scripts/vehicles/JetSeat.txt" )
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

//Variables
ENT.UpdatePhys = 0
--Delays
ENT.UseDelay = CurTime()
ENT.ShootDel = CurTime()
ENT.ShootSoundDel = CurTime()
ENT.LandGear = CurTime()
ENT.MissileAlertDel = CurTime()
ENT.CounterMeDel = CurTime()
ENT.RudderFlapDel = CurTime()
ENT.RadioDel = CurTime()

--Sounds
ENT.Radio1 = NULL
ENT.Radio2 = NULL
ENT.Radio3 = NULL
ENT.Radio4 = NULL
ENT.Radio5 = NULL
ENT.MinorAlarm = NULL
ENT.LowHealth = NULL
ENT.CrashAlarm = NULL
ENT.MissileAlert = NULL
ENT.LandGearUp = NULL
ENT.LandGearDown = NULL
ENT.StartSound = NULL
ENT.StopThaSound = NULL

--PhysObjects
ENT.Seat = NULL
ENT.LeftWingProp = NULL
ENT.RightWingProp = NULL
ENT.Stabilizer = NULL

ENT.LockTarget = NULL

--Misc
ENT.Throttle = 0
ENT.RealThrottle = 0
ENT.LandGearOnce = 3
ENT.StartOnce = 0
ENT.StopOnce = 0
ENT.DustEffectOnce = false
ENT.DustEffect = NULL
ENT.AlertLevel = 0
ENT.CreateWingProps = 0
ENT.JetHealth = 300
ENT.OldSpeed = 0
ENT.DidCollide = 0
ENT.DieOnce = 0
ENT.RemoveHealthDel = CurTime()
ENT.NotInWater = 0
ENT.DamageLevel = 0
ENT.StopSoundOnce = 0

--Can't use tables since they seem to get global by default >:[
--ENT.RandomPos = {}
--npc targets
ENT.target1 = NULL
ENT.target2 = NULL
ENT.target3 = NULL
ENT.target4 = NULL
ENT.target5 = NULL

------------------------------------VARIABLES END
function ENT:SpawnFunction( ply, tr )
--------Spawning the entity and getting some sounds i use.   
 	if ( !tr.Hit ) then return end 
 	 
 	local SpawnPos = tr.HitPos + tr.HitNormal * 10 + Vector(0,0,40)
 	 
	local vec = ply:GetAimVector():Angle()
	local newAng = Angle(0,vec.y,0)
 	local ent = ents.Create( "sent_SakariasJet_nonAdmin_rfl" )
	ent:SetPos( SpawnPos ) 
	ent:SetAngles(newAng)
 	ent:Spawn()
 	ent:Activate() 
 	ent.Owner = ply
	return ent 
	
end

function ENT:Initialize()

	self.Entity:SetModel("models/military2/air/air_rfl.mdl")
	self.Entity:SetOwner(self.Owner)
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	
	self.Entity:SetSolid(SOLID_VPHYSICS)	
    local phys = self.Entity:GetPhysicsObject()
	if(phys:IsValid()) then phys:Wake() end
	phys:SetMass( 1500 )
	
	self.Entity.HasTarget = 0
	
	--The centre of the model isn't the "real centre" so i have to adjust it
	local PosFix = self.Entity:GetRight() * -5.25
	
	--Spawning a new seat
	self.Seat = ents.Create("prop_vehicle_prisoner_pod")  
    self.Seat:SetKeyValue("vehiclescript","scripts/vehicles/JetSeat.txt")  
    self.Seat:SetModel( "models/nova/airboat_seat.mdl" ) 
    self.Seat:SetPos( self.Entity:GetPos() + ( self.Entity:GetForward() * 125 ) + ( self.Entity:GetUp() * 25 ) + PosFix )  
	self.Seat:SetAngles(self.Entity:GetAngles() + Angle(0,-90,0))
	self.Seat:SetKeyValue("limitview", "0")  
	self.Seat:Spawn()  
	self.Seat:GetPhysicsObject():SetMass(1)	
	self.Seat:SetNotSolid( true )
	self.Seat:GetPhysicsObject():EnableDrag(false)	
	self.Seat:DrawShadow( false )
	--self.Seat:SetNoDraw( true )	
	self.Seat:SetColor(Color(255,255,255,0))
	self.Seat:SetNetworkedEntity( "AirVehicleParent", self )
	self.Entity.Seat = self.Seat
	self.Seat.EntOwner = self.Entity
	//self.Seat.SeatNum = 1
	self.Entity.UseSeat = 0
	constraint.NoCollide( self.Entity, self.Seat, 0, 0 )
	--
	
	--Spawning wing props
	--These are the props that i'm adding spritetrails on when the jet is over a certain speed
	self.LeftWingProp = ents.Create( "prop_physics" )
	self.LeftWingProp:SetModel("models/Items/AR2_Grenade.mdl")		
	self.LeftWingProp:SetPos(self.Entity:GetPos() + (self.Entity:GetRight() * -197) + (self.Entity:GetUp() * 7) + (self.Entity:GetForward() * -225) + PosFix )
	self.LeftWingProp:SetOwner(self.Owner)	
	self.LeftWingProp:SetAngles(self.Entity:GetAngles())	
	self.LeftWingProp:Spawn()
	self.LeftWingProp:GetPhysicsObject():EnableGravity(false)

	self.RightWingProp = ents.Create( "prop_physics" )
	self.RightWingProp:SetModel("models/Items/AR2_Grenade.mdl")		
	self.RightWingProp:SetPos(self.Entity:GetPos() + (self.Entity:GetRight() * 197) + (self.Entity:GetUp() * 7) + (self.Entity:GetForward() * -225) + PosFix )
	self.RightWingProp:SetOwner(self.Owner)		
	self.RightWingProp:SetAngles(self.Entity:GetAngles())
	self.RightWingProp:Spawn()
	self.RightWingProp:GetPhysicsObject():EnableGravity(false)
	
	--Stabilizer
	self.Stabilizer = ents.Create( "prop_physics" )
	self.Stabilizer:SetModel("models/dav0r/hoverball.mdl")		
	self.Stabilizer:SetPos(self.Entity:GetPos() + (self.Entity:GetUp() * 50) + (self.Entity:GetForward() * 1))
	self.Stabilizer:SetOwner(self.Owner)		
	self.Stabilizer:SetAngles(self.Entity:GetAngles())
	self.Stabilizer:SetColor(Color(255,255,255,0))
	self.Stabilizer:Spawn()
	self.Stabilizer:SetNoDraw( true )	
	self.Stabilizer:GetPhysicsObject():EnableGravity(false)	
	self.Stabilizer:GetPhysicsObject():SetMass(500)

	constraint.Weld( self.Entity, test, 0, 0, 0, 1 )
	
	constraint.Weld( self.Entity, self.Stabilizer, 0, 0, 0, 1 )
	--constraint.Keepupright( self.Stabilizer, Angle(0,0,0) , 0, 500000)
		
	util.SpriteTrail( self.LeftWingProp, 0, Color(255,255,255,150), false, 3, 0, 0.2, 1/(3)*0.5, "trails/smoke.vmt" )
	util.SpriteTrail( self.RightWingProp, 0, Color(255,255,255,150), false, 3, 0, 0.2, 1/(3)*0.5, "trails/smoke.vmt" )		
		
	constraint.Weld( self.Entity, self.Seat, 0, 0, 0, 1 )

	constraint.Weld( self.Entity, self.LeftWingProp, 0, 0, 0, 1 )	
	constraint.Weld( self.Entity, self.RightWingProp, 0, 0, 0, 1 ) 
	
 	--constraint.Keepupright( self.Entity, Angle(0,0,0) , 0, 50)	 
	 
	 
self.ShootSound   = CreateSound(self.Entity,"JetVehicle/Shoot.wav")	
self.LandGearUp   = CreateSound(self.Entity,"vehicles/tank_turret_start1.wav")	
self.LandGearDown = CreateSound(self.Entity,"vehicles/tank_turret_stop1.wav")
self.StartSound   =	CreateSound(self.Entity,"JetVehicle/JetStart.wav")
self.StopThaSound = CreateSound(self.Entity,"JetVehicle/JetStop.wav")
self.MissileShoot = CreateSound(self.Entity,"JetVehicle/MissileShoot.mp3")
self.Radio1 = CreateSound(self.Entity,"JetVehicle/radio/radio1.wav")
self.Radio2 = CreateSound(self.Entity,"JetVehicle/radio/radio2.wav")
self.Radio3 = CreateSound(self.Entity,"JetVehicle/radio/radio3.wav")
self.Radio4 = CreateSound(self.Entity,"JetVehicle/radio/radio4.wav")
self.Radio5 = CreateSound(self.Entity,"JetVehicle/radio/radio5.wav")
self.Radio6 = CreateSound(self.Entity,"JetVehicle/radio/radio6.mp3")
self.LockingSound = CreateSound(self.Entity,"JetVehicle/lockingTarget.wav")
self.MinorAlarm = CreateSound(self.Entity,"JetVehicle/MinorAlarm.wav")
self.LowHealth = CreateSound(self.Entity,"JetVehicle/LowHealth.wav")
self.CrashAlarm = CreateSound(self.Entity,"JetVehicle/CrashAlarm.wav")
self.MissileAlert = CreateSound(self.Entity,"JetVehicle/MissileNearby.mp3")

end

-------------------------------------------USE
function ENT:Use( activator, caller )


	//If the ent is still functioning and there is no one in it you will be able to enter it 
	if activator:IsPlayer() and self.UseDelay < CurTime() and self.DieOnce == 0 then
	
		self.UseDelay = CurTime() + 1
		self.Entity.UseSeat = 0
	
		for k,v in pairs(player.GetAll()) do
			if v:InVehicle( ) then
				local PlyUsedVeh = v:GetVehicle()						
				
				if PlyUsedVeh == self.Entity.Seat then
					self.Entity.UseSeat = 1				
				end
			end
		end

		if self.Entity.UseSeat == 0 then
			activator:EnterVehicle( self.Entity.Seat )
			activator:SetNetworkedBool( "UseAirVehicleThirdPersonView", 0 )
			self.Entity.User = activator
			self.Entity.User:SetNetworkedInt("JetWeaponType", 0)
		end			
		
	end	
	
end

-------------------------------------------PHYS COLLIDE
function ENT:PhysicsCollide( data, phys ) 
	ent = data.HitEntity

	self.DidCollide = 1
end
-------------------------------------------PHYSICS =D
function ENT:PhysicsUpdate( physics )
if self.UpdatePhys > RealTime() then
	--Need to check water level since garrysmod sometimes crashes when trying to get physicsobject when the airplane is submerged. ={
	--Seems not to be the airplanes fault since it have happened to me when just throwing ordinary props in the water.
	--The new freespace map doesn't like when you put things in the water.
	if self.Entity:WaterLevel() == 0 && self.DieOnce == 0 && self.Entity:GetPhysicsObject() != NULL then
	
		local entphys = self.Entity:GetPhysicsObject()
		local speed = self.Entity:GetPhysicsObject():GetVelocity():Length()		
		local realSpeed = (self.Entity:GetForward():GetNormalized() * self.Entity:GetPhysicsObject():GetVelocity()):Length()	
		
		local newSpeed = speed
		if newSpeed > 1000 then
			newSpeed = 1000
		end
		
		if realSpeed > 1000 then
			realSpeed = 1000
		end
		
		local healthMul = 200
		
		if self.JetHealth < 200 then
			healthMul = self.JetHealth
		end
			
		healthMul = healthMul / 200
		
		--Applying force depending on the health and throttle.
		entphys:ApplyForceCenter( healthMul * (self.Entity:GetUp() * 12000 * (newSpeed / 1000)) )		
				
		--Changes the mass depending on speed and throttle.
		--Really have to do this since the model aerodynamics are bad.
		if  self.Entity.UseSeat == 1 then
			entphys:SetMass( 1500 + (( 1 - (newSpeed / 1000)) * 5000) + ((1 - ((self.Throttle - 6000) / 44000)) * 3000) )
		else
			entphys:SetMass( 12000 )
		end
		
		--Changing the pitch on the sound so we actually can hear how much throttle we have
		--if self.StartOnce == 1 then
			local pitchHP = self.JetHealth
			
			if pitchHP > 200 then 
				pitchHP = 200
			end
			
			pitchHP = pitchHP / 200
		
			local Pitch = (((self.RealThrottle * pitchHP) - 6000) / 44000) * 150
			
			self.StartSound:ChangePitch( Pitch + 100, 0);
		--end
					
			if self.Entity.UseSeat == 1 && self.DieOnce == 0 && self.NotInWater == 0 then
				--Controls
		
				local testSpeed = speed
				
				if testSpeed > 2000 then
					testSpeed = 2000
				end
				
				local flipForce = testSpeed / 2000
				
				--How much force that will be applyed on the plane is depending on the speed.
				--High speed means that you won't get much response at all.
				self:CheckForViewChange( self.Entity.User )				
				
				--Pitch down
				if 	self.Entity.User:KeyDown( IN_FORWARD ) then
					entphys:AddAngleVelocity( Vector(0,(5 * flipForce),0 ) )						
				end
			
				--Pitch up
				if 	self.Entity.User:KeyDown( IN_BACK ) then
					entphys:AddAngleVelocity( Vector(0,(-5 * flipForce),0 ) )					
				end	
				
				
				--Calculating control force
				local spinForce = newSpeed / 1000
				local turnForce = 0
				
				if speed < 750 then
					turnForce = speed / 750
				end
				
				if speed > 750 then
					turnForce = 1.1 - ((speed - 750) / 1250)
				end
				
				if turnForce < 0 then
					turnForce = 0
				end
				
				--Roll Left
				if 	self.Entity.User:KeyDown( IN_MOVELEFT ) && not(self.Entity.User:KeyDown( IN_ATTACK2 )) then		
					entphys:AddAngleVelocity( Vector( (-6 * spinForce),0, 0 ) )	
				end
			
				--Roll Right
				if 	self.Entity.User:KeyDown( IN_MOVERIGHT ) && not(self.Entity.User:KeyDown( IN_ATTACK2 )) then
					entphys:AddAngleVelocity( Vector((6 * spinForce),0, 0 ) )			
				end				
				
				--Yaw Left
				if self.Entity.User:KeyDown( IN_MOVELEFT ) && self.Entity.User:KeyDown( IN_ATTACK2 ) then		
					entphys:AddAngleVelocity( Vector( 0,0, (2 * turnForce) ) )				
				end

				--Yaw Right
				if self.Entity.User:KeyDown( IN_MOVERIGHT ) && self.Entity.User:KeyDown( IN_ATTACK2 ) then
					entphys:AddAngleVelocity( Vector( 0,0, (-2 * turnForce) ) )											
				end	
				
				--Increase Throttle
				if 	self.Entity.User:KeyDown( IN_JUMP ) then	
					self.Throttle = self.Throttle + 150	
				end
			
				--Decrease Throttle
				if 	self.Entity.User:KeyDown( IN_WALK ) then
					self.Throttle = self.Throttle - 100
				end
				
				--It's over 50000!
				if self.Throttle > 50000 then
					self.Throttle = 50000
				end

				if self.Throttle < 6000 then
					self.Throttle = 6000
				end
		
		
				if self.Throttle > self.RealThrottle then
					self.RealThrottle = math.Approach(self.Throttle, 200, 1)
				end
				
				if self.Throttle < self.RealThrottle then
					self.RealThrottle = math.Approach(self.Throttle, 20, 1)	
				end
									
					
					--Damage
					local speed = self.Entity:GetPhysicsObject():GetVelocity():Length()				
					
					--Rudders will start flapping and the ent will start to make some noises
					if self.JetHealth < 200 && self.RudderFlapDel < CurTime() && speed > 500 then
					
						local delay = self.JetHealth / 200
						local RanMax = (speed / 200 )
						
						if delay < 0 then
							delay = 0;
						end
						
						if RanMax < 0 then
							RanMax = 1
						end
						
						RanMax = RanMax * 8
						
						self.RudderFlapDel = CurTime() + delay
						FlapVec = Vector(math.random(-1,1),math.random(-1,1), math.random(-1,1)) * math.random( 0, RanMax )
						
						entphys:AddAngleVelocity( FlapVec )	
						
						local RanSound = math.random(1,50)
						
						if RanSound <= 5 then
							self.Entity:EmitSound("physics/metal/metal_solid_strain"..RanSound..".wav")
						end
						
					end
					
					
					
			end
		
		--Someone is driving it so we apply force forward
		--if self.DieOnce == 0 && self.Entity.UseSeat == 1 then
			entphys:ApplyForceCenter(self.Entity:GetForward() * self.RealThrottle * healthMul * 1.5)
		--end
		
		--There is no one driving it. Setting default throttle to 0
		--if self.Entity.UseSeat == 0 then
			--self.Throttle = 0
		--end
	end
end		
end
-------------------------------------------DAMAGE
function ENT:OnTakeDamage(dmg)

	local Damage = 	0

	if dmg:IsExplosionDamage() then
		Damage = dmg:GetDamage()
	else
		Damage = (dmg:GetDamage()) / 4
	end

	self.JetHealth = self.JetHealth - Damage

end
-------------------------------------------THINK
function ENT:Think()
	self.UpdatePhys = RealTime() + 0.5
	self.NotInWater = 0
	--Water is bad. The ent will lose health when it's in contact with water
	if self.Entity:WaterLevel() > 0 then
		self.NotInWater = 1
		self.JetHealth = self.JetHealth - 10		
	end
	
	--If the health is below 50 it will start to drain health
	if self.RemoveHealthDel < CurTime() && self.JetHealth < 50 then
		self.RemoveHealthDel = CurTime() + 0.5
		self.JetHealth = self.JetHealth - 5
	end
	
	local speed = self.Entity:GetPhysicsObject():GetVelocity():Length()				
	local SpeedDelta = self.OldSpeed - speed
	self.OldSpeed = speed
	local dmg = SpeedDelta / 4			

	--We collided with something and are going to calculate the damage made to the hull
	if SpeedDelta > 100 && self.DidCollide == 1 && dmg > 50 then
		self.DidCollide = 0
		self.JetHealth = self.JetHealth - dmg		
	end
	
	self.DidCollide = 0
	
	--I know this is a helicopter effect but it looks awesome on planes aswell
	if self.DustEffectOnce == false && speed > 1000 then
		self.DustEffect = ents.Create("env_rotorwash_emitter")
		self.DustEffect:SetPos(self.Entity:GetPos())
		self.DustEffect:SetParent(self.Entity)
		self.DustEffect:Activate()
		self.DustEffectOnce = true
	end
	
	--Removing the effect when the ent is going to slow.
	if self.DustEffectOnce == true && speed < 1000 then
		self.DustEffect:Remove()
		self.DustEffectOnce = false
	end
			
	--landing gear
	if self.LandGear < CurTime() then
	
		self.LandGear = CurTime() + 1
		local trace = {}
		trace.start = self.Entity:GetPos()
		trace.endpos = self.Entity:GetPos() + (Vector(0,0,1) * -500)
		trace.filter = { self.Entity, self.Seat, self.Stabilizer }
		local tr = util.TraceLine( trace )
		local hitpos = tr.HitPos
		local dist = self.Entity:GetPos():Distance(hitpos)
		
		if speed < 1300 && dist < 500 && self.LandGearOnce < 2 then	
			self.LandGearOnce = 2
		elseif self.LandGearOnce > 2 && self.LandGearOnce != 0 && dist >= 400 && speed > 1000 then
			self.LandGearOnce = 1
		end
	end
	
	if self.LandGearOnce == 2 then
		self.LandGearOnce = 3
		
		if self.JetHealth > 0 then
			self.LandGearDown:Stop()
			self.LandGearDown:Play()
		end
		
		self.Entity:SetModel("models/military2/air/air_rfl.mdl")
		self.LandGear = CurTime() + 2
	end

	if self.LandGearOnce == 1 && self.JetHealth > 0 then
		self.LandGearOnce = 0
		self.LandGearUp:Stop()	
		self.LandGearUp:Play()
		self.Entity:SetModel("models/military2/air/air_rfl_l.mdl")
		self.LandGear = CurTime() + 2
	end
				
				
	--For the ENT:PhysicsUpdate() function to run the phys object needs to be awake at all times.
    local phys = self.Entity:GetPhysicsObject()
	phys:Wake()
	
			
	--Is there someone using the ent now?
	self.Entity.UseSeat = 0
	for k,v in pairs(player.GetAll()) do
		if v:InVehicle( ) then
		
			local PlyUsedVeh = v:GetVehicle()						
					
			if PlyUsedVeh == self.Entity.Seat then
				self.Entity.UseSeat = 1
			end
			
		end
	end
	
	--If someone is using the ent
	if self.Entity.UseSeat == 1 then
		self.UseDelay = CurTime() + 1
		self.StopSoundOnce = 0	
		
		self.Entity:SetNetworkedInt("jetThrottle", self.Throttle)
		
		--Alarms
		if self.AlertLevel == 0 && self.JetHealth < 200 then
			self.AlertLevel = 1
			self.MinorAlarm:Stop()
			self.MinorAlarm:Play()
		end

		if self.AlertLevel == 1 && self.JetHealth < 150 then
			self.AlertLevel = 2
			self.MinorAlarm:Stop()
			self.LowHealth:Stop()
			self.LowHealth:Play()	
		end

		if self.AlertLevel == 2 && self.JetHealth < 50 then
			self.AlertLevel = 3
			self.LowHealth:Stop()		
			self.CrashAlarm:Stop()
			self.CrashAlarm:Play()	
		end	
		
		--If someone shot a guided missile and it's close and it's locked on this ent we will emit an alarm so we have a chance to use countermeasures
		--for k, v in pairs( ents.FindInSphere( self.Entity:GetPos(), 4000 ) ) do	
			--if string.find(v:GetClass(), "sent_guidedjetmissile") && self.MissileAlertDel < CurTime() then
				if (self.Entity.IsMissileTarget == 1 or self.Seat.IsMissileTarget == 1 or self.Entity.User.IsMissileTarge == 1) && self.MissileAlertDel < CurTime() then
					self.MissileAlertDel = CurTime() + 3
					self.MissileAlert:Stop()
					self.MissileAlert:Play()	
				end
			--end
		--end
		
		if self.Entity.IsMissileTarget == 0 && self.Seat.IsMissileTarget == 0 && self.Entity.User.IsMissileTarge == 0 then
			self.MissileAlert:Stop()
		end
		
		--Dropping countermeasures
		if 	self.Entity.User:KeyDown( IN_ZOOM ) && self.CounterMeDel < CurTime() then
			self.CounterMeDel = CurTime() + 10

			local countermeasure = ents.Create( "sent_countermeasure" )	
			countermeasure:SetPos(self.Entity:GetPos() + self.Entity:GetForward() * -290 + self.Entity:GetUp() * -30)		
			countermeasure:Spawn()
			countermeasure:Activate()
			countermeasure:SetVelocity( self.Entity:GetVelocity() + (self.Entity:GetForward() * - 1000) )	
			countermeasure.FlareType = 1
			constraint.NoCollide( self.Entity, countermeasure, 0, 0 )			
			
			local countermeasure = ents.Create( "sent_countermeasure" )	
			countermeasure:SetPos(self.Entity:GetPos() + self.Entity:GetForward() * -290 + self.Entity:GetUp() * -30)		
			countermeasure:Spawn()
			countermeasure:Activate()
			countermeasure:SetVelocity( self.Entity:GetVelocity() + (self.Entity:GetRight() * 1000) )	
			countermeasure.FlareType = 3		
			constraint.NoCollide( self.Entity, countermeasure, 0, 0 )	
			
			local countermeasure = ents.Create( "sent_countermeasure" )	
			countermeasure:SetPos(self.Entity:GetPos() + self.Entity:GetForward() * -290 + self.Entity:GetUp() * -30)		
			countermeasure:Spawn()
			countermeasure:Activate()
			countermeasure:SetVelocity( self.Entity:GetVelocity() + (self.Entity:GetRight() * -1000))	
			countermeasure.FlareType = 3
			constraint.NoCollide( self.Entity, countermeasure, 0, 0 )	
			self.Entity:EmitSound("weapons/slam/mine_mode.wav")			
		end
			
		if self.StartOnce == 0 then
			self.StartOnce = 1
			self.StopOnce = 0
			self.StopThaSound:Stop()	
			
			if self.Throttle < 7000 then			
				self.StartSound:Stop()			
				self.StartSound:Play()
			end	

			--Adding targets so npcs will shoot you while you are inside the jet
			self.target1 = ents.Create("npc_bullseye")   
			self.target1:SetPos(self.Entity:GetPos() + (self.Entity:GetRight() * 150) ) 
			self.target1:SetParent(self.Entity)  
			self.target1:SetKeyValue("health","9999")  
			self.target1:SetKeyValue("spawnflags","256") 
			self.target1:SetNotSolid( true )  
			self.target1:Spawn()  
			self.target1:Activate() 
			 
			self.target2 = ents.Create("npc_bullseye")   
			self.target2:SetPos(self.Entity:GetPos() + (self.Entity:GetRight() * -153) )
			self.target2:SetParent(self.Entity)  
			self.target2:SetKeyValue("health","9999")  
			self.target2:SetKeyValue("spawnflags","256") 
			self.target2:SetNotSolid( true )  
			self.target2:Spawn()  
			self.target2:Activate() 

			self.target3 = ents.Create("npc_bullseye")   
			self.target3:SetPos((self.Entity:GetPos() + self.Entity:GetForward() * -330 + self.Entity:GetUp() * 19) + (self.Entity:GetRight() * -5.25)) 
			self.target3:SetParent(self.Entity)  
			self.target3:SetKeyValue("health","9999")  
			self.target3:SetKeyValue("spawnflags","256") 
			self.target3:SetNotSolid( true )  
			self.target3:Spawn()  
			self.target3:Activate() 

			self.target4 = ents.Create("npc_bullseye")   
			self.target4:SetPos(self.Entity:GetPos() + (self.Entity:GetUp() * -70) ) 
			self.target4:SetParent(self.Entity)  
			self.target4:SetKeyValue("health","9999")  
			self.target4:SetKeyValue("spawnflags","256") 
			self.target4:SetNotSolid( true )  
			self.target4:Spawn()  
			self.target4:Activate() 

			self.target5 = ents.Create("npc_bullseye")   
			self.target5:SetPos((self.Entity:GetPos() + self.Entity:GetForward() * 330 + self.Entity:GetUp() * 19) + (self.Entity:GetRight() * -5.25))
			self.target5:SetParent(self.Entity)  
			self.target5:SetKeyValue("health","9999")  
			self.target5:SetKeyValue("spawnflags","256") 
			self.target5:SetNotSolid( true )  
			self.target5:Spawn()  
			self.target5:Activate()  	
			
		end

		for k,v in pairs(ents.FindByClass("npc_*")) do
			if ( string.find(v:GetClass(), "npc_antlionguard")) or ( string.find(v:GetClass(), "npc_combine*")) or ( string.find(v:GetClass(), "*zombie*")) or ( string.find(v:GetClass(), "npc_helicopter")) or ( string.find(v:GetClass(), "npc_manhack")) or ( string.find(v:GetClass(), "npc_metropolice")) or ( string.find(v:GetClass(), "npc_rollermine")) or ( string.find(v:GetClass(), "npc_strider")) or ( string.find(v:GetClass(), "npc_turret*")) or ( string.find(v:GetClass(), "npc_hunter")) or ( string.find(v:GetClass(), "antlion")) then
				v:Fire( "setrelationship", "npc_bullseye D_HT 5" )
			end
		end	
	
		--Forcing the player out from the seat when pressing use
		if 	self.Entity.User:KeyDown( IN_USE ) and self.UseDelay < CurTime()  then
			self.UseDelay = CurTime() + 1
			self.Entity.User:ExitVehicle()
		end
		
		--Radio Sound Effect
		--Just adding some random radio conversations
		--Why not just randomize the sound directory?
		--Because i want to stop the sound whenever i want to
		if self.RadioDel < CurTime() then
			local RanSound = math.random( 1, 5 )
		
			if RanSound == 1 then
				self.Radio1:Stop()
				self.Radio1:Play()
				self.Radio1:ChangeVolume( 0.2, 0)
				self.RadioDel = CurTime() +	26			
			end
			
			if RanSound == 2 then
				self.Radio2:Stop()
				self.Radio2:Play()	
				self.Radio2:ChangeVolume( 0.3, 0)				
				self.RadioDel = CurTime() +	30					
			end
			
			if RanSound == 3 then
				self.Radio3:Stop()
				self.Radio3:Play()	
				self.Radio3:ChangeVolume( 0.3, 0)				
				self.RadioDel = CurTime() +	21					
			end			
			
			if RanSound == 4 then
				self.Radio4:Stop()
				self.Radio4:Play()	
				self.Radio4:ChangeVolume( 0.3, 0)				
				self.RadioDel = CurTime() +	16					
			end			

			if RanSound == 5 then
				self.Radio5:Stop()
				self.Radio5:Play()	
				self.Radio4:ChangeVolume( 0.3, 0)				
				self.RadioDel = CurTime() +	47					
			end				
			
		end
		
	end
			
	--No one is flying the plane D=
	if self.Entity.UseSeat == 0 then
	
		self.Throttle = self.Throttle - 500 
		self.RealThrottle = self.Throttle
		
		if self.Throttle < 6000 then
			self.Throttle = 6000
			self.RealThrottle = 6000
			
			self.Entity:SetNetworkedInt("jetThrottle", 0)
			self.StartSound:Stop()
			
			if self.DieOnce == 0 && self.StopSoundOnce == 0 then
				self.StopThaSound:Stop()			
				self.StopThaSound:Play()
				self.StopSoundOnce = 1
			end			
			
		end
			
		if self.StopOnce == 0 then
			self.StopOnce = 1
			self.StartOnce = 0
			self.MinorAlarm:Stop()
			self.LowHealth:Stop()
			self.CrashAlarm:Stop()			
			--self.StopThaSound:Stop()
			
			--self.StartSound:Stop()	
			self.Radio1:Stop()
			self.Radio2:Stop()
			self.Radio3:Stop()
			self.Radio4:Stop()
			self.Radio5:Stop()			
			self.RadioDel = 0

			if self.target1 != NULL then
				self.target1:Remove()
			end

			if self.target2 != NULL then
				self.target2:Remove()
			end

			if self.target3 != NULL then
				self.target3:Remove()
			end

			if self.target4 != NULL then
				self.target4:Remove()
			end

			if self.target5 != NULL then
				self.target5:Remove()
			end			
	
			self.target1 = NULL
			self.target2 = NULL
			self.target3 = NULL
			self.target4 = NULL
			self.target5 = NULL			
			
			--if self.DieOnce == 0 then
				--self.StopThaSound:Play()
			--end
			
			if self.AlertLevel > 0 then
				self.AlertLevel = self.AlertLevel - 1
			end
	
		end
	end
	
	if self.NotInWater == 1 then
		self.StopOnce = 1
		self.StartOnce = 0
		self.StopThaSound:Stop()
		self.StartSound:Stop()	
		self.Radio1:Stop()
		self.Radio2:Stop()
		self.Radio3:Stop()
		self.Radio4:Stop()
		self.Radio5:Stop()
		self.RadioDel = 0
	end	
	
	
	--Adding cool wing trails for awesomeness 8]
	if self.CreateWingProps == 1 && speed > 1500 then
	
		self.CreateWingProps = 0
		local PosFix = self.Entity:GetRight() * -5.25
		
		self.LeftWingProp = ents.Create( "prop_physics" )
		self.LeftWingProp:SetModel("models/Items/AR2_Grenade.mdl")		
		self.LeftWingProp:SetPos(self.Entity:GetPos() + (self.Entity:GetRight() * -197) + (self.Entity:GetUp() * 7) + (self.Entity:GetForward() * -225) + PosFix )
		self.LeftWingProp:SetOwner(self.Owner)	
		self.LeftWingProp:SetColor(Color(0,0,0,255)	)
		self.LeftWingProp:Spawn()
		self.LeftWingProp:GetPhysicsObject():EnableGravity(false)
	
		self.RightWingProp = ents.Create( "prop_physics" )
		self.RightWingProp:SetModel("models/Items/AR2_Grenade.mdl")		
		self.RightWingProp:SetPos(self.Entity:GetPos() + (self.Entity:GetRight() * 197) + (self.Entity:GetUp() * 7) + (self.Entity:GetForward() * -225) + PosFix )
		self.RightWingProp:SetOwner(self.Owner)		
		self.RightWingProp:SetColor(Color(0,0,0,255))
		self.RightWingProp:Spawn()
		self.RightWingProp:GetPhysicsObject():EnableGravity(false)
			
		util.SpriteTrail( self.LeftWingProp, 0, Color(255,255,255,150), false, 3, 0, 0.2, 1/(3)*0.5, "trails/smoke.vmt" )
		util.SpriteTrail( self.RightWingProp, 0, Color(255,255,255,150), false, 3, 0, 0.2, 1/(3)*0.5, "trails/smoke.vmt" )	
		
		constraint.Weld( self.Entity, self.LeftWingProp, 0, 0, 0, 1 )	
		constraint.Weld( self.Entity, self.RightWingProp, 0, 0, 0, 1 ) 		
		
	end
	
	--Removing the wing trails
	if self.CreateWingProps == 0 && speed < 1500 then
		self.CreateWingProps = 1
		self.LeftWingProp:Remove()
		self.RightWingProp:Remove()
		self.LeftWingProp = NULL
		self.RightWingProp = NULL
		
	end
	
	--"It will explod!" :o
	if self.DieOnce == 0 && self.JetHealth < 0 then
		self.DieOnce = 1
		
			self.Throttle = 0
			self.RealThrottle = 0
		
			self.MinorAlarm:Stop()
			self.LowHealth:Stop()
			self.CrashAlarm:Stop()			
			self.StopThaSound:Stop()
			
			self.StartSound:Stop()	
			self.Radio1:Stop()
			self.Radio2:Stop()
			self.Radio3:Stop()
			self.Radio4:Stop()
			self.Radio5:Stop()
			
		if self.Entity.UseSeat == 1 then
			self.Entity.User:SetNetworkedInt("JetWeaponType", 0)
		end
		
		--Boom!
		local expl = ents.Create("env_explosion")
		expl:SetKeyValue("spawnflags",128)
		expl:SetPos(self.Entity:GetPos())
		expl:Spawn()
		expl:Fire("explode","",0)
	
		local FireExp = ents.Create("env_physexplosion")
		FireExp:SetPos(self.Entity:GetPos())
		FireExp:SetParent(self.Entity)
		FireExp:SetKeyValue("magnitude", 500)
		FireExp:SetKeyValue("radius", 500)
		FireExp:SetKeyValue("spawnflags", "1")
		FireExp:Spawn()
		FireExp:Fire("Explode", "", 0)
		FireExp:Fire("kill", "", 5)
		util.BlastDamage( self.Entity, self.Entity, self.Entity:GetPos(), 500, 500)
	
		local effectdata = EffectData()
		effectdata:SetStart( self.Entity:GetPos() )
		effectdata:SetOrigin( self.Entity:GetPos() )
		effectdata:SetScale( 1 )
		
		--Explosions ftw!
		util.Effect( "Explosion", effectdata )	
		util.Effect( "HelicopterMegaBomb", effectdata )	
		util.Effect( "cball_explode", effectdata )
		
		self.Entity:SetColor(Color(0,0,0,255)	)
		
		--You can't die even if the jet explodes
		--Only faggots try to kill players that doesn't have weapons
		--If the jet explodes the player will automatically eject (if they have the bail out addon)
		if self.Entity.UseSeat == 1 then	
			self.Entity.User:ConCommand("BailOut")	
			local health = self.Entity.User:Health() 
			
			if health > 1 then
				health = health / 2
			end

			self.Entity.User:Fire("sethealth", ""..health.."", 0)				
		end	

		--Spawning gibs
		local gib = NULL;
		gib = ents.Create( "prop_physics" )
		gib:SetModel("models/military2/air/gibs/rfl/backthruster.mdl")
		gib:SetColor(Color(150,150,150,255)	)	
		gib:SetPos(self.Entity:GetPos())	
		gib:SetAngles(self.Entity:GetAngles())
		gib:Spawn()
		gib:GetPhysicsObject():SetVelocity( self.Entity:GetVelocity() )
		gib:Fire("kill", "", 15)
		
		gib = ents.Create( "prop_physics" )
		gib:SetModel("models/military2/air/gibs/rfl/backwing.mdl")	
		gib:SetColor(Color(150,150,150,255)	)				
		gib:SetPos(self.Entity:GetPos())	
		gib:SetAngles(self.Entity:GetAngles())
		gib:Spawn()
		gib:GetPhysicsObject():SetVelocity( self.Entity:GetVelocity() )	
		gib:Fire("kill", "", 15)		

		gib = ents.Create( "prop_physics" )
		gib:SetModel("models/military2/air/gibs/rfl/cockpit.mdl")
		gib:SetColor(Color(150,150,150,255)		)		
		gib:SetPos(self.Entity:GetPos())	
		gib:SetAngles(self.Entity:GetAngles())
		gib:Spawn()
		gib:GetPhysicsObject():SetVelocity( self.Entity:GetVelocity() )			
		gib:Fire("kill", "", 15)		
		constraint.Weld( gib, self.Seat, 0, 0, 0, 1 )
		self.Seat:Fire("kill", "", 15)	
		
		gib = ents.Create( "prop_physics" )
		gib:SetModel("models/military2/air/gibs/rfl/frontleftwing.mdl")
		gib:SetColor(Color(150,150,150,255)		)			
		gib:SetPos(self.Entity:GetPos())	
		gib:SetAngles(self.Entity:GetAngles())
		gib:Spawn()
		gib:GetPhysicsObject():SetVelocity( self.Entity:GetVelocity() )			
		gib:Fire("kill", "", 15)		

		gib = ents.Create( "prop_physics" )
		gib:SetModel("models/military2/air/gibs/rfl/frontrightwing.mdl")	
		gib:SetColor(Color(150,150,150,255)	)				
		gib:SetPos(self.Entity:GetPos())	
		gib:SetAngles(self.Entity:GetAngles())
		gib:Spawn()		
		gib:GetPhysicsObject():SetVelocity( self.Entity:GetVelocity() )		
		gib:Fire("kill", "", 15)
		
		gib = ents.Create( "prop_physics" )
		gib:SetModel("models/military2/air/gibs/rfl/leftwheel.mdl")		
		gib:SetColor(Color(150,150,150,255)	)		
		gib:SetPos(self.Entity:GetPos())	
		gib:SetAngles(self.Entity:GetAngles())
		gib:Spawn()	
		gib:GetPhysicsObject():SetVelocity( self.Entity:GetVelocity() )		
		gib:Fire("kill", "", 15)
		
		gib = ents.Create( "prop_physics" )
		gib:SetModel("models/military2/air/gibs/rfl/leftwing.mdl")	
		gib:SetColor(Color(150,150,150,255)		)		
		gib:SetPos(self.Entity:GetPos())		
		gib:SetAngles(self.Entity:GetAngles())
		gib:Spawn()		
		gib:GetPhysicsObject():SetVelocity( self.Entity:GetVelocity() )		
		gib:Fire("kill", "", 15)
		
		gib = ents.Create( "prop_physics" )
		gib:SetModel("models/military2/air/gibs/rfl/middle.mdl")
		gib:SetColor(Color(150,150,150,255)	)				
		gib:SetPos(self.Entity:GetPos())	
		gib:SetAngles(self.Entity:GetAngles())
		gib:Spawn()		
		gib:GetPhysicsObject():SetVelocity( self.Entity:GetVelocity() )	
		gib:Fire("kill", "", 15)
		
		gib = ents.Create( "prop_physics" )
		gib:SetModel("models/military2/air/gibs/rfl/rightwheel.mdl")
		gib:SetColor(Color(150,150,150,255)		)		
		gib:SetPos(self.Entity:GetPos())	
		gib:SetAngles(self.Entity:GetAngles())
		gib:Spawn()			
		gib:GetPhysicsObject():SetVelocity( self.Entity:GetVelocity() )	
		gib:Fire("kill", "", 15)		
		
		gib = ents.Create( "prop_physics" )
		gib:SetModel("models/military2/air/gibs/rfl/rightwing.mdl")	
		gib:SetColor(Color(150,150,150,255)		)				
		gib:SetPos(self.Entity:GetPos())	
		gib:SetAngles(self.Entity:GetAngles())
		gib:Spawn()	
		gib:GetPhysicsObject():SetVelocity( self.Entity:GetVelocity() )
		gib:Fire("kill", "", 15)		
		
		local effectdata = EffectData()
		effectdata:SetOrigin( self.Entity:GetPos() )
		effectdata:SetStart( Vector(0,0,90) )
		util.Effect( "jetdestruction_explosion", effectdata )			
		
		self.Entity:Remove()		
		
	end
	
	
	--Starting some fires if the jet is damaged
	if self.DamageLevel == 0 && self.JetHealth < 200 then
		self.DamageLevel = 1
			
		local PosFix = self.Entity:GetRight() * -5.25
		
		local pos = NULL
		
		local ranPos = math.random(1,7)
		
		if ranPos == 1 then
			pos = (self.Entity:GetRight() * 100) + (self.Entity:GetUp() * 20) + (self.Entity:GetForward() * -170)
			
		elseif ranPos == 2 then
			pos = (self.Entity:GetRight() * -100) + (self.Entity:GetUp() * 20) + (self.Entity:GetForward() * -170)
			
		elseif ranPos == 3 then
			pos = (self.Entity:GetForward() * -260) + (self.Entity:GetUp() * 110) + PosFix
			
		elseif ranPos == 4 then
			pos = (self.Entity:GetForward() * 30 ) + ( self.Entity:GetUp() * -35 )
			
		elseif ranPos == 5 then
			pos = ((self.Entity:GetForward() * 65 ) + (self.Entity:GetRight() * -30) + (self.Entity:GetUp() * 14) + PosFix)
			
		elseif ranPos == 6 then
			pos = ((self.Entity:GetForward() * 65 ) + (self.Entity:GetRight() * -30) + (self.Entity:GetUp() * 14) + PosFix)
			
		elseif ranPos == 7 then
			pos = ((self.Entity:GetForward() * -275) + (self.Entity:GetUp() * 19) + PosFix)
		end	
		
		local fire = ents.Create( "env_fire_trail" )
		fire:SetPos( self.Entity:GetPos() + pos) --By sakarias88
		fire:Spawn()
		fire:SetParent(self.Entity)
	end
	
	if self.DamageLevel == 1 && self.JetHealth < 150 then
		self.DamageLevel = 2		
		
		local PosFix = self.Entity:GetRight() * -5.25
		
		local pos = NULL
		
		local ranPos = math.random(1,7)
		
		if ranPos == 1 then
			pos = (self.Entity:GetRight() * 100) + (self.Entity:GetUp() * 20) + (self.Entity:GetForward() * -170)
			
		elseif ranPos == 2 then
			pos = (self.Entity:GetRight() * -100) + (self.Entity:GetUp() * 20) + (self.Entity:GetForward() * -170)
			
		elseif ranPos == 3 then
			pos = (self.Entity:GetForward() * -260) + (self.Entity:GetUp() * 110) + PosFix
			
		elseif ranPos == 4 then
			pos = (self.Entity:GetForward() * 30 ) + ( self.Entity:GetUp() * -35 )
			
		elseif ranPos == 5 then
			pos = ((self.Entity:GetForward() * 65 ) + (self.Entity:GetRight() * -30) + (self.Entity:GetUp() * 14) + PosFix)
			
		elseif ranPos == 6 then
			pos = ((self.Entity:GetForward() * 65 ) + (self.Entity:GetRight() * -30) + (self.Entity:GetUp() * 14) + PosFix)
			
		elseif ranPos == 7 then
			pos = ((self.Entity:GetForward() * -275) + (self.Entity:GetUp() * 19) + PosFix)
		end	
		
		local fire = ents.Create( "env_fire_trail" )
		fire:SetPos( self.Entity:GetPos() + pos) --By sakarias88
		fire:Spawn()
		fire:SetParent(self.Entity)
	end
	
	if self.DamageLevel == 2 && self.JetHealth < 100 then
		self.DamageLevel = 3
		
		local PosFix = self.Entity:GetRight() * -5.25
		
		local pos = NULL
		
		local ranPos = math.random(1,7)
		
		if ranPos == 1 then
			pos = (self.Entity:GetRight() * 100) + (self.Entity:GetUp() * 20) + (self.Entity:GetForward() * -170)
			
		elseif ranPos == 2 then
			pos = (self.Entity:GetRight() * -100) + (self.Entity:GetUp() * 20) + (self.Entity:GetForward() * -170)
			
		elseif ranPos == 3 then
			pos = (self.Entity:GetForward() * -260) + (self.Entity:GetUp() * 110) + PosFix
			
		elseif ranPos == 4 then
			pos = (self.Entity:GetForward() * 30 ) + ( self.Entity:GetUp() * -35 )
			
		elseif ranPos == 5 then
			pos = ((self.Entity:GetForward() * 65 ) + (self.Entity:GetRight() * -30) + (self.Entity:GetUp() * 14) + PosFix)
			
		elseif ranPos == 6 then
			pos = ((self.Entity:GetForward() * 65 ) + (self.Entity:GetRight() * -30) + (self.Entity:GetUp() * 14) + PosFix)
			
		elseif ranPos == 7 then
			pos = ((self.Entity:GetForward() * -275) + (self.Entity:GetUp() * 19) + PosFix)
		end	
		
		local fire = ents.Create( "env_fire_trail" )
		fire:SetPos( self.Entity:GetPos() + pos) --By sakarias88
		fire:Spawn()
		fire:SetParent(self.Entity)	
	end
	
	if self.DamageLevel == 3 && self.JetHealth < 50 then
		self.DamageLevel = 4	
		
		local PosFix = self.Entity:GetRight() * -5.25
		
		local pos = NULL
		
		local ranPos = math.random(1,7)
		
		if ranPos == 1 then
			pos = (self.Entity:GetRight() * 100) + (self.Entity:GetUp() * 20) + (self.Entity:GetForward() * -170)
			
		elseif ranPos == 2 then
			pos = (self.Entity:GetRight() * -100) + (self.Entity:GetUp() * 20) + (self.Entity:GetForward() * -170)
			
		elseif ranPos == 3 then
			pos = (self.Entity:GetForward() * -260) + (self.Entity:GetUp() * 110) + PosFix
			
		elseif ranPos == 4 then
			pos = (self.Entity:GetForward() * 30 ) + ( self.Entity:GetUp() * -35 )
			
		elseif ranPos == 5 then
			pos = ((self.Entity:GetForward() * 65 ) + (self.Entity:GetRight() * -30) + (self.Entity:GetUp() * 14) + PosFix)
			
		elseif ranPos == 6 then
			pos = ((self.Entity:GetForward() * 65 ) + (self.Entity:GetRight() * -30) + (self.Entity:GetUp() * 14) + PosFix)
			
		elseif ranPos == 7 then
			pos = ((self.Entity:GetForward() * -275) + (self.Entity:GetUp() * 19) + PosFix)
		end	
		
		local fire = ents.Create( "env_fire_trail" )
		fire:SetPos( self.Entity:GetPos() + pos) --By sakarias88
		fire:Spawn()
		fire:SetParent(self.Entity)	
	end
	
end

function ENT:OnRemove()

	--If the jet haven't exploded we should remove the seat manually
	if self.DieOnce == 0 then
		if self.Seat:IsValid() then
			self.Seat:Remove()
		end
	end
	
	if self.Stabilizer:IsValid() then
		self.Stabilizer:Remove()
	end
	
	self.MinorAlarm:Stop()
	self.LowHealth:Stop()
	self.CrashAlarm:Stop()			
	self.StopThaSound:Stop()
	self.StartSound:Stop()	
	self.Radio1:Stop()
	self.Radio2:Stop()
	self.Radio3:Stop()
	self.Radio4:Stop()
	self.Radio5:Stop()
	
	--Removing wing props
	if self.CreateWingProps == 0 then
		self.LeftWingProp:Remove()
		self.RightWingProp:Remove()
	end

	--Removing Targets
	if 	self.target1 != NULL then
		self.target1:Remove()
	end

	if 	self.target2 != NULL then
		self.target2:Remove()
	end

	if 	self.target3 != NULL then
		self.target3:Remove()
	end

	if 	self.target4 != NULL then
		self.target4:Remove()
	end

	if 	self.target5 != NULL then
		self.target5:Remove()
	end	
	
	--Removing corshairs
	if self.Entity.UseSeat == 1 && self.Entity.User != NULL && self.Entity.User != nil && self.Entity.User:IsValid() then
		self.Entity.User:SetNetworkedInt("JetWeaponType", 0)
		self.Entity.User:SetNetworkedInt("HasLockedOnTarget", 0)	
	end
	
end

--Making the player sit in the seat. If we don't force the anim it will have the default prison pod anim.
local function SetPlyJetAnimation( pl, anim )

	 if pl:InVehicle( ) then
	 local Veh = pl:GetVehicle()
	
		if string.find(Veh:GetModel(), "models/nova/airboat_seat") then 
		
			local seq = pl:LookupSequence( "sit" )
				
			pl:SetPlaybackRate( 1.0 )
			pl:ResetSequence( seq )
			pl:SetCycle( 0 )
			return true

		end
	end
end
hook.Add( "SetPlayerAnimation", "SetJetChairAnim", SetPlyJetAnimation )


function ENT:CheckForViewChange( ply )
	if ply:KeyDown( IN_RELOAD ) and (ply.AirVeh_ThirdPersonViewDel == nil or ply.AirVeh_ThirdPersonViewDel < CurTime()) then
		ply.AirVeh_ThirdPersonViewDel = CurTime() + 0.5
		if ply.AirVeh_ThirdPersonView then
			ply.AirVeh_ThirdPersonView = false
			ply:SetNetworkedBool( "UseAirVehicleThirdPersonView", 0)	
		else
			ply.AirVeh_ThirdPersonView = true
			ply:SetNetworkedBool( "UseAirVehicleThirdPersonView", 2)
		end
	end		
end
