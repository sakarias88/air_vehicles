
hook.Add("PlayerLeaveVehicle", "CustomHeliVehicleExitsTOYBOXss", function( ply, veh )            
    if veh.IsHeliSeat and IsValid(veh.SeatOwner) and ply.SwapDel < CurTime() then

		local sN = veh.SeatNum

		ply:SetVelocity( veh.SeatOwner:GetPhysicsObject():GetVelocity() * 0.9 )
		ply:SetPos( veh.SeatOwner:LocalToWorld( veh.SeatOwner.SeatExitPos[sN] ) )
		ply:SetEyeAngles( veh.SeatOwner:LocalToWorld(veh.SeatOwner.SeatExitPos[sN] - ply:GetPos()):Angle() )           
    end
end)
