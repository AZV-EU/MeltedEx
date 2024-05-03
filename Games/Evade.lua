local module = {}

function module.PreInit()
	_G.MX_SETTINGS.ESP.Mode = 1
end

function module.Init(category, connections)
	local plr = game.Players.LocalPlayer
	local gameDir = game.Workspace:WaitForChild("Game")
	
	local skullGui = Instance.new("BillboardGui")
	skullGui.AlwaysOnTop = true
	skullGui.ResetOnSpawn = false
	skullGui.LightInfluence = 0
	skullGui.StudsOffsetWorldSpace = Vector3.new(0, 3, 0)
	skullGui.Name = "skull_esp_billboard"
	skullGui.Size = UDim2.fromOffset(60, 60)
	skullGui.StudsOffsetWorldSpace = Vector3.new(0, 0, 0)
	do
		local il = Instance.new("ImageLabel", skullGui)
		il.BackgroundTransparency = 1
		il.Size = UDim2.new(1, 0, 1, 0)
		il.ImageColor3 = Color3.new(1, 150/255, 150/255)
		il.Image = "rbxassetid://36697080"
	end

	local boostCheckbox = category:AddCheckbox("Cola Boost!")
	boostCheckbox:SetChecked(true)
	
	local downedCheckbox = category:AddCheckbox("Anti-downed")
	downedCheckbox:SetChecked(true)
	
	_G.MX_ESPSystem.GetValidTargets = function()
		local targets = {}
		for k,v in pairs(game.Players:GetPlayers()) do
			if v ~= plr and v.Character then
				table.insert(targets, v.Character)
			end
		end
		local mapDir = gameDir:WaitForChild("Map")
		local partsDir = mapDir:WaitForChild("Parts")
		local objectivesDir = partsDir:FindFirstChild("Objectives")
		if objectivesDir then
			for k, objective in pairs(objectivesDir:GetChildren()) do
				if objective:IsA("Model") and objective.PrimaryPart and not objective:FindFirstChild("esp_billboard") then
					table.insert(targets, objective)
				end
			end
		end
		return targets
	end
	
	_G.MX_ESPSystem.CustomRefreshConnection = function(player, chr, human, func)
		return chr:GetAttributeChangedSignal("Downed"):Once(func)
	end
	
	_G.MX_ESPSystem.Teams["Dead"].Rule = function(target)
		local player = game.Players:GetPlayerFromCharacter(target)
		return player and player.Character and player.Character:GetAttribute("Downed")
	end
	
	_G.MX_ESPSystem.AddTeam("Objectives", _G.COLORS.YELLOW, function(target)
		local mapDir = gameDir:FindFirstChild("Map")
		if mapDir then
			local partsDir = mapDir:WaitForChild("Parts")
			if partsDir then
				local objectivesDir = partsDir:FindFirstChild("Objectives")
				return objectivesDir and target.Parent == objectivesDir
			end
		end
	end)--.ShowNames = false
	
	task.spawn(function()
		while task.wait(1) and module.On do
			
			for k,v in pairs(game.Players:GetPlayers()) do
				if v.Character then
					if v.Character:GetAttribute("Downed") and not v.Character:FindFirstChild("skull_esp_billboard") then
						local sg = skullGui:Clone()
						sg.Parent = v.Character
						sg.Adornee = v.Character
					elseif (not v.Character:GetAttribute("Downed") or v.Character:GetAttribute("FullyDowned")) and v.Character:FindFirstChild("skull_esp_billboard") then
						v.Character.skull_esp_billboard:Destroy()
					end
				end
			end
			
			if plr.Character then
				local stats = plr.Character:FindFirstChild("StatChanges")
				if stats then
					local speed = stats:FindFirstChild("Speed")
					if speed then
						if boostCheckbox.Checked then
							local boost = speed:FindFirstChild("ColaBoost") or Instance.new("NumberValue", speed)
							boost.Name = "ColaBoost"
							boost.Value = 1.8
						elseif downedCheckbox.Checked then
							local downed = speed:FindFirstChild("Downed")
							if downed then
								downed:Destroy()
							end
						end
					end
				end
			end
			
		end
	end)
end

return module