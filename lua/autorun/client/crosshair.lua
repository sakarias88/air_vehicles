local DoTraceDel = 0
local CurTraceDel = 0
local TracePosOne = Vector(0,0,0)
local TracePosTwo = Vector(0,0,0)

local wepFuncs = {}
local hasTarget = 0
local weaponType = 0
local func = nil

local function DoTheTrace( pos )
	local veh = LocalPlayer():GetVehicle()
	if IsValid(veh) then
		
		local startPos = veh:GetPos()
		local trace = {}
		trace.start = startPos	+ veh:GetRight() * -pos.x + veh:GetForward() * -pos.y + veh:GetUp() * pos.z
		trace.endpos = startPos + (veh:GetRight() * -20000)
		trace.filter = { LocalPlayer(), veh, veh:GetNetworkedEntity( "OwnerEnt" ), veh:GetNetworkedEntity( "OwnerStab" ) }
		trace = util.TraceLine( trace )	

		return trace.HitPos
	end

	return TracePosOne
end		
	
wepFuncs[1] = function()
	if CurTraceDel < CurTime() then
		CurTraceDel = CurTime() + DoTraceDel
		TracePosOne = DoTheTrace( Vector(0,0,0) )
	end
	
	--targetPos = LocalPlayer():GetNetworkedVector("LockTargetPos")
	local pos = TracePosOne:ToScreen()
	
	surface.SetDrawColor( 0, 255, 0, 200 )
	surface.DrawLine( pos.x + 20, pos.y, pos.x + 5 , pos.y )
	surface.DrawLine( pos.x - 20, pos.y, pos.x - 5 , pos.y )			
	surface.DrawLine( pos.x ,pos.y + 20, pos.x, pos.y + 5 )		
	surface.DrawLine( pos.x ,pos.y - 20, pos.x, pos.y - 5 )	
end

wepFuncs[2] = function()

	if CurTraceDel < CurTime() then
		CurTraceDel = CurTime() + DoTraceDel
		TracePosOne = DoTheTrace( Vector(-150,-141,-20) )
		TracePosTwo = DoTheTrace( Vector(-150,141,-20) )
	end

	local posOne = TracePosOne:ToScreen()
	local posTwo = TracePosTwo:ToScreen()
	
	surface.SetDrawColor( 0, 255, 0, 200 )
	surface.DrawLine( posOne.x + 20, posOne.y, posOne.x + 5 , posOne.y )
	surface.DrawLine( posOne.x - 20, posOne.y, posOne.x - 5 , posOne.y )			
	surface.DrawLine( posOne.x ,posOne.y + 20, posOne.x, posOne.y + 5 )		
	surface.DrawLine( posOne.x ,posOne.y - 20, posOne.x, posOne.y - 5 )		
	
	surface.DrawLine( posTwo.x + 20, posTwo.y, posTwo.x + 5 , posTwo.y )
	surface.DrawLine( posTwo.x - 20, posTwo.y, posTwo.x - 5 , posTwo.y )			
	surface.DrawLine( posTwo.x ,posTwo.y + 20, posTwo.x, posTwo.y + 5 )		
	surface.DrawLine( posTwo.x ,posTwo.y - 20, posTwo.x, posTwo.y - 5 )	
end

wepFuncs[3] = function()

	local tstPos = EyePos() + LocalPlayer():GetForward() * 1
	tstPos = tstPos:ToScreen()
	surface.DrawCircle( tstPos.x, tstPos.y, ScrH()*0.29, Color(0, 255, 0, 200))
	surface.DrawCircle( tstPos.x, tstPos.y, ScrH()*0.3, Color(0, 255, 0, 200))
	surface.DrawCircle( tstPos.x, tstPos.y, ScrH()*0.31, Color(0, 255, 0, 200))

	if hasTarget == 1 then
		local target = LocalPlayer():GetNetworkedEntity("AirVehicles_Target")
		surface.SetDrawColor( 0, 255, 0, 200 )
		
		if IsValid(target) then
			TracePosOne = target:GetPos()
		else
			surface.SetDrawColor( 255, 255, 0, 200 )
		end
		
		local pos = TracePosOne:ToScreen()
	
		
		surface.DrawOutlinedRect( pos.x - 20, pos.y - 20, 40, 40)		
	end
end


local function LockOnTargetEffect()
	hasTarget = LocalPlayer():GetNetworkedInt("HasLockedOnTarget")
	weaponType = LocalPlayer():GetNetworkedInt("JetWeaponType")
	func = wepFuncs[weaponType]
	if func then func() end
end
hook.Add("HUDPaint", "LockOnTargetEffect", LockOnTargetEffect)	


