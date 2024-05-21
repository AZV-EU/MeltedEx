local module = {}

--[[function module.PreInit()
	_G.MX_SETTINGS.ESP.Mode = 1
end]]

function module.Init(category, connections)
	local plr = game.Players.LocalPlayer
	
	local Planets = game.Workspace:WaitForChild("Planets")
	local Asteroids = game.Workspace:WaitForChild("Asteroids")
	local Planetoids = game.Workspace:WaitForChild("Planetoids")
	
	local Rocks = game.Workspace:FindFirstChild("Rocks")
	if Rocks then
		Rocks.Parent = nil
	end
	
	local function GetAllMinerals()
		local minerals = {}
		local function GetMinerals(body)
			if body:FindFirstChild("Minerals") then
				for _,mineral in pairs(body.Minerals:GetChildren()) do
					table.insert(minerals, mineral)
				end
			end
		end
		for _,body in pairs(Planets:GetChildren()) do
			GetMinerals(body)
		end
		for _,body in pairs(Asteroids:GetChildren()) do
			GetMinerals(body)
		end
		for _,body in pairs(Planetoids:GetChildren()) do
			GetMinerals(body)
		end
		return minerals
	end
	
	category:AddButton("Tp to nearest orb", function()
		local minerals = GetAllMinerals()
		local nearest, nearestDist, dist
		for _,mineral in pairs(minerals) do
			if mineral.Name:lower():find("orb") then
				dist = plr:DistanceFromCharacter(mineral.Position)
				if dist < 1000 and (not nearest or dist < nearestDist) then
					nearest = mineral
					nearestDist = dist
				end
			end
		end
		if nearest then
			_G.TeleportPlayerTo(nearest.Position + Vector3.new(0, 3, 0))
		end
	end)
	
	do -- debug count
		local orbs, minerals = 0, 0
		for _,mineral in pairs(GetAllMinerals()) do
			if mineral.Name:lower():find("orb") then
				orbs += 1
			else
				minerals += 1
			end
		end
		print("There are", orbs, "orbs and", minerals, "minerals.")
	end
	
	task.spawn(function()
		local function ShowDoneMinerals()
			for _,mineral in pairs(GetAllMinerals()) do
				if mineral.Transparency >= 1 then
					mineral.Transparency = 0.5
				end
			end
		end
		ShowDoneMinerals()
		while task.wait(5) and plr.leaderstats.Orbs.Value < 18 and module.On do
			ShowDoneMinerals()
		end
	end)
end

return module