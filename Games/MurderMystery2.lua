local module = {}

function module.PreInit()
	_G.MX_SETTINGS.ESP.Mode = 1
end

function module.Init(category, connections)
	local plr = game.Players.LocalPlayer
	local ReplicatedStorage = _G.SafeGetService("ReplicatedStorage")
	local RemotesGameplay = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Gameplay")
	local RemotesExtras = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Extras")
	local Remotes = {
		RoleSelect = RemotesGameplay:WaitForChild("RoleSelect"),
		RoundStart = RemotesGameplay:WaitForChild("RoundStart"),
		GameOver = RemotesGameplay:WaitForChild("GameOver"),
		GetPlayerData = RemotesExtras:WaitForChild("GetPlayerData")
	}
	local CurrentMap = nil
	
	category:BeginInline()
	category:AddButton("Take Gun", function()
		local gunDrop = game.Workspace:FindFirstChild("GunDrop", true)
		if gunDrop and plr.Character and plr.Character.PrimaryPart then
			_G.TeleportPlayerTo(gunDrop.Position)
			--_G.TouchObjects(plr.Character.PrimaryPart, gunDrop)
		end
	end)
	
	category:AddButton("Transparent Map", function()
		if CurrentMap then
			for k,v in pairs(CurrentMap:GetDescendants()) do
				if v:IsA("BasePart") then
					if v.Transparency == 0 then
						v.Transparency = 0.75
					elseif v.Transparency == 0.75 then
						v.Transparency = 0
					end
				end
			end
		end
	end)
	category:EndInline()
	
	_G.MX_ESPSystem.AddTeam("Sheriff", _G.COLORS.BLUE, function(target)
		local player = game.Players:GetPlayerFromCharacter(target)
		return player and player:GetAttribute("Role") == "Sheriff"
	end, 2)
	
	_G.MX_ESPSystem.Teams["Enemies"].Rule = function(target)
		local player = game.Players:GetPlayerFromCharacter(target)
		return player and player:GetAttribute("Role") == "Murderer"
	end
	
	_G.MX_ESPSystem.Teams["Allies"].Rule = function(target)
		local player = game.Players:GetPlayerFromCharacter(target)
		return player and player:GetAttribute("Role") == "Innocent"
	end
	
	_G.MX_ESPSystem.AddTeam("GunDrop", _G.COLORS.BLUE, function(target)
		return target:IsA("BasePart") and target.Name == "GunDrop" and target.Parent == game.Workspace
	end)
	
	_G.MX_ESPSystem.ReindexTeams()
	
	for k,v in pairs(game.Workspace:GetChildren()) do
		if v:IsA("Model") and v:FindFirstChild("GlitchProof") then
			v.GlitchProof:Destroy()
		end
	end
	
	local function UpdateRoles(roundData)
		for playerName, data in pairs(roundData) do
			local player = game.Players:FindFirstChild(playerName)
			if player then
				player:SetAttribute("Role", data.Role)
			end
		end
		_G.MX_ESPSystem.Update()
	end
	
	table.insert(connections, Remotes.RoleSelect.OnClientEvent:Connect(function()
		for k,v in pairs(game.Workspace:GetChildren()) do
			if v:IsA("Model") and v:FindFirstChild("CoinContainer") and v:FindFirstChild("Spawns") and v.Name ~= "Lobby" then
				CurrentMap = v
				break
			end
		end
		for k,v in pairs(game.Workspace:GetChildren()) do
			if v:IsA("Model") and v:FindFirstChild("GlitchProof") then
				v.GlitchProof:Destroy()
			end
		end
		_G.MX_ESPSystem.Update()
	end))
	
	table.insert(connections, Remotes.RoundStart.OnClientEvent:Connect(function(_, roundData)
		_G.MX_ESPSystem.Update()
	end))
	
	table.insert(connections, Remotes.GameOver.OnClientEvent:Connect(function(...)
		for _,player in pairs(game.Players:GetPlayers()) do
			player:SetAttribute("Role", "Innocent")
		end
		_G.MX_ESPSystem.Update()
	end))
	
	table.insert(connections, game.Workspace.ChildAdded:Connect(function(child)
		if child.Name == "GunDrop" then
			task.wait(.33)
			_G.MX_ESPSystem.UpdateTarget(child)
		end
	end))
	
	table.insert(connections, game.Workspace.ChildRemoved:Connect(function(child)
		if child.Name == "GunDrop" then
			task.wait(.33)
			_G.MX_ESPSystem.Update()
		end
	end))
	
	_G.MX_ESPSystem.GetValidTargets = function()
		local targets = {}
		local playerData = Remotes.GetPlayerData:InvokeServer()
		for k,v in pairs(game.Players:GetPlayers()) do
			if v ~= plr and v.Character then
				v:SetAttribute("Role", playerData[v.Name] and playerData[v.Name].Role or "Innocent")
				table.insert(targets, v.Character)
			end
		end
		local gunDrop = game.Workspace:FindFirstChild("GunDrop")
		if gunDrop then
			table.insert(targets, gunDrop)
		end
		return targets
	end
end

return module