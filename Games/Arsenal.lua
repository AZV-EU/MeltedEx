local module = {}

function module.PreInit()
	_G.MX_SETTINGS.ESP.HijackHighlights = false -- manual hijacking
	_G.MX_SETTINGS.SETUP.SetCameraMaxZoomDistance = false -- prevent T2 kick
end

function module.Init()
	local plr = game.Players.LocalPlayer
	
	local status = plr:WaitForChild("Status")
	local myTeam = status:WaitForChild("Team")
	
	do
		local map
		_G.MX_AimbotSystem.GetFilterDescendantsInstances = function()
			map = game.Workspace:FindFirstChild("Map")
			if map and map:FindFirstChild("Ignore") and map:FindFirstChild("Clips") then
				return {
					game.Workspace.CurrentCamera,
					game.Workspace.Ray_Ignore,
					map.Ignore,
					map.Clips,
					plr.Character
				}
			else
				return {
					game.Workspace.CurrentCamera,
					game.Workspace.Ray_Ignore,
					plr.Character
				}
			end
		end
	end
	
	_G.MX_AimbotSystem.CanUse = function()
		return plr.Character
	end
	
	local alliesTeam = _G.MX_ESPSystem.Teams["Allies"]
	do -- Allies rule override
		local player
		_G.MX_ESPSystem.Teams["Allies"].Rule = function(target)
			player = game.Players:GetPlayerFromCharacter(target)
			return myTeam.Value ~= "" and player and player:FindFirstChild("Status") and player.Status:FindFirstChild("Team") and player.Status.Team.Value == myTeam.Value
		end
	end
	
	local enemiesTeam = _G.MX_ESPSystem.Teams["Enemies"]
	do -- Enemies rule override
		local player, team
		enemiesTeam.Rule = function(target)
			player = game.Players:GetPlayerFromCharacter(target)
			return myTeam.Value ~= "" and player and player:FindFirstChild("Status") and player.Status:FindFirstChild("Team") and player.Status.Team.Value ~= myTeam.Value
		end
	end
	
	_G.MX_ESPSystem.Update() -- update after overrides
	
	local function SetupPlayer(player)
		table.insert(connections, player:WaitForChild("Status"):WaitForChild("Team"):GetPropertyChangedSignal("Value"):Connect(function()
			_G.MX_ESPSystem.Update()
		end))
	end
	for _,p in pairs(game.Players:GetPlayers()) do
		task.spawn(SetupPlayer, p)
	end
	table.insert(connections, game.Players.PlayerAdded:Connect(SetupPlayer))
	
	if not _G.Arsenal_HighlightsFix then
		task.wait(10)
	
		local highlights = {}
		for k,v in ipairs(plr:WaitForChild("PlayerGui"):GetChildren()) do
			if v:IsA("Highlight") then
				v.Archivable = true
				v.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
				v.FillTransparency = 0.75
				v.OutlineColor = _G.COLORS.WHITE
				v.OutlineTransparency = 0.75
				table.insert(highlights, v)
			end
		end
		
		local deadTeam = _G.MX_ESPSystem.Teams["Dead"]
		local friendsTeam = _G.MX_ESPSystem.Teams["Friends"]
		
		local deadHL = highlights[5]
		deadHL.FillColor = deadTeam.Color
		deadHL.Adornee = deadTeam.Folder
		deadHL.Name = "HIGHLIGHT_" .. tostring(deadTeam.Name)
		deadHL.Parent = _G.MX_ESPSystem.HighlightStore
		
		local friendsHL = highlights[4]
		friendsHL.FillColor = friendsTeam.Color
		friendsHL.Adornee = friendsTeam.Folder
		friendsHL.Name = "HIGHLIGHT_" .. tostring(friendsTeam.Name)
		friendsHL.Parent = _G.MX_ESPSystem.HighlightStore
		
		local alliesHL = highlights[3]
		alliesHL.FillColor = alliesTeam.Color
		alliesHL.Adornee = alliesTeam.Folder
		alliesHL.Name = "HIGHLIGHT_" .. tostring(alliesTeam.Name)
		alliesHL.Parent = _G.MX_ESPSystem.HighlightStore
		
		local enemiesHL = highlights[2]
		enemiesHL.FillColor = enemiesTeam.Color
		enemiesHL.Adornee = enemiesTeam.Folder
		enemiesHL.Name = "HIGHLIGHT_" .. tostring(enemiesTeam.Name)
		enemiesHL.Parent = _G.MX_ESPSystem.HighlightStore
		
		_G.Arsenal_HighlightsFix = true
	end
end

return module