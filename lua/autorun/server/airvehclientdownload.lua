AddCSLuaFile( "autorun/client/airveh_thirdpersonview.lua" )
AddCSLuaFile( "autorun/client/crosshair.lua" )
AddCSLuaFile( "autorun/client/killicons.lua" )

local baseDir = "addons/AirVehicles/"

local function AirVeh_AddDownloadDirectory(dir, filt)
	local files, dirs = file.Find(baseDir..dir.."/*", "GAME") --Get all folders
	for _, fdir in pairs(dirs) do
		if fdir != ".svn" and fdir != "radio" then --Don't add svn folders and don't add the radio music. The radio music should be clientside
			AirVeh_AddDownloadDirectory(dir.."/"..fdir, filt)
		end
	end
 
	for k,v in pairs(files) do
		if !file.IsDir("../"..baseDir..dir.."/"..v, "GAME") then
		
			if filt then --Check the filer if we have one
				local expl = string.Explode( ".", v )
				local exte = expl[table.Count( expl )]
				
				if exte == filt then
					resource.AddFile(dir.."/"..v)
				end			
			else
				resource.AddFile(dir.."/"..v)
			end
		end
	end
end

AirVeh_AddDownloadDirectory("models", "mdl") 
AirVeh_AddDownloadDirectory("materials", "vmt")
AirVeh_AddDownloadDirectory("sound") 