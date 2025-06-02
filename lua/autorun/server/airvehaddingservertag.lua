local tags = string.Explode(",",(GetConVarString("sv_tags") or ""))
for i,tag in ipairs(tags) do
	if tag:find("AirVehicles 1.5") then table.remove(tags,i) end	
end
table.insert(tags, "AirVehicles 1.5")
table.sort(tags)
RunConsoleCommand("sv_tags", table.concat(tags, ","))
