
local IsAirVehicleSeat = false
local UsesThirdPersonView = false
local AirVehicle = NULL

local MaxDist = 2000
local MinDist = 100
local MoveSmooth = 0.05
local AngSmooth = 0.05
local wasTurnedOn = false
local view = {}

local viewLastPos = Vector(0,0,0)
local viewLastAng = Angle(0,0,0)

function AirVeh_ThirdPersonView(ply, position, angles, fov)
	if !ply:Alive() then return end
	if ply:GetActiveWeapon() == "Camera" then return end
	if GetViewEntity() != ply then return end

	AirVehicle = LocalPlayer():GetVehicle()
	if IsValid(AirVehicle) then
		AirVehicleEnt = AirVehicle:GetNetworkedEntity( "AirVehicleParent" )
		UsesThirdPersonView =  ply:GetNetworkedInt( "UseAirVehicleThirdPersonView" )	
	else
		AirVehicleEnt = NULL
		UsesThirdPersonView = 0
	end


	if IsValid(AirVehicleEnt) and UsesThirdPersonView != 0 then
		if wasTurnedOn == false then
			wasTurnedOn = true
			viewLastPos = position
			viewLastAng = angles			
		end	
		
		if UsesThirdPersonView == 1 then

			local wantedAng = angles
			wantedAng.p = wantedAng.p - AirVehicleEnt:GetAngles().p		
			local wantedPos = AirVehicleEnt:GetPos() + wantedAng:Forward() * -500
			
			local Trace = {}
			Trace.start = AirVehicleEnt:GetPos()
			Trace.endpos = wantedPos
			Trace.mask = MASK_NPCWORLDSTATIC
			local tr = util.TraceLine(Trace)
					
			if tr.Hit then
				wantedPos = tr.HitPos + tr.HitNormal * 10
			end	
	
			view.origin = wantedPos
			view.angles = angles
			view.fov = fov
			return view			
		elseif UsesThirdPersonView == 2 then


			local newPos = AirVehicleEnt:GetPos() + AirVehicleEnt:GetForward() * -600 + AirVehicleEnt:GetUp() * 200
			
			local Trace = {}
			Trace.start = AirVehicleEnt:GetPos()
			Trace.endpos = newPos
			Trace.mask = MASK_NPCWORLDSTATIC
			local tr = util.TraceLine(Trace)
			
			if tr.Hit then
				newPos = tr.HitPos + tr.HitNormal * 10
			end				
			
			local dist = viewLastPos:Distance( newPos )
			local lerpy = math.Clamp(  0.5 * dist * FrameTime() * MoveSmooth, 0,1)
			newPos = LerpVector( lerpy, viewLastPos, newPos)
			lerpy = math.Clamp(  50 * FrameTime() * AngSmooth, 0,1)
			local newAng = LerpAngle( lerpy, viewLastAng, AirVehicleEnt:GetAngles() )

			view.origin = newPos
			view.angles = newAng
			viewLastPos = newPos
			viewLastAng = newAng
			view.fov = fov			
			return view		
		end
	else
		wasTurnedOn = false
	end
end
hook.Add("CalcView", "AirVeh_ThirdPersonView", AirVeh_ThirdPersonView)