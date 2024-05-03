local module = {}

function module.PreInit()
	_G.MX_SETTINGS.ESP.Mode = 1
end

function module.Init(category, connections)
	local plr = game.Players.LocalPlayer
	local UserInputService = _G.SafeGetService("UserInputService")
	local ContextActionService = _G.SafeGetService("ContextActionService")
	local ReplicatedStorage = _G.SafeGetService("ReplicatedStorage")
	local IsGameActive = ReplicatedStorage:WaitForChild("IsGameActive")
	local CurrentMap = ReplicatedStorage:WaitForChild("CurrentMap")
	local RemoteEvent = ReplicatedStorage:WaitForChild("RemoteEvent")
	
	_G.MX_ESPSystem.Teams["Enemies"].Rule = function(target)
		return game.Players:GetPlayerFromCharacter(target) and target:FindFirstChild("Hammer") ~= nil
	end
	
	_G.MX_ESPSystem.Teams["Allies"].Rule = function(target)
		return game.Players:GetPlayerFromCharacter(target) and target:FindFirstChild("Hammer") == nil
	end
	
	local ScreenColorComplete = BrickColor.new("Dark green")
	_G.MX_ESPSystem.AddTeam("IncompleteComputers", _G.COLORS.YELLOW, function(target)
		return not game.Players:GetPlayerFromCharacter(target) and target:FindFirstChild("Screen") and target.Screen.BrickColor ~= ScreenColorComplete
	end).ShowNames = false
	
	do -- override & include incomplete computers
		local targets = {}
		_G.MX_ESPSystem.GetValidTargets = function()
			targets = {}
			for k,v in pairs(game.Players:GetPlayers()) do
				if v ~= plr and v.Character then
					table.insert(targets, v.Character)
				end
			end
			if CurrentMap.Value ~= nil then
				for k,v in pairs(CurrentMap.Value:GetDescendants()) do
					if v:IsA("Model") and v.Name:sub(1,13) == "ComputerTable" then
						table.insert(targets, v)
					end
				end
			end
			return targets
		end
	end
	
	local function SetupMap()
		if not CurrentMap.Value then return end
		local cts = {}
		repeat
			task.wait(1)
			cts = {}
			for k,v in pairs(CurrentMap.Value:GetDescendants()) do
				if v:IsA("Model") and v.Name == "ComputerTable" then
					table.insert(cts, v)
				end
			end
		until #cts >= 3 or not module.On
		for k,v in pairs(cts) do
			table.insert(connections, v:WaitForChild("Screen"):GetPropertyChangedSignal("BrickColor"):Connect(function()
				_G.MX_ESPSystem.UpdateTarget(v)
			end))
			v.Name = "ComputerTable" .. tostring(k)
		end
	end
	task.spawn(SetupMap)
	
	table.insert(connections, CurrentMap:GetPropertyChangedSignal("Value"):Connect(function()
		task.wait()
		task.spawn(SetupMap)
		_G.MX_ESPSystem.Update()
	end))
	
	table.insert(connections, plr:GetPropertyChangedSignal("CameraMode"):Connect(function()
		task.wait()
		plr.CameraMode = Enum.CameraMode.Classic
	end))
	
	local function SetupPlayer(player)
		repeat task.wait() until player.Character
		
		local function SetupCharacter(chr)
			table.insert(connections, chr.ChildAdded:Connect(function(child)
				if child.Name == "Hammer" then
					task.wait()
					_G.MX_ESPSystem.UpdateTarget(chr)
				end
			end))
		end
		SetupCharacter(player.Character)
		
		table.insert(connections, player.CharacterAdded:Connect(SetupCharacter))
	end
	for _,v in pairs(game.Players:GetPlayers()) do
		if v ~= plr then
			task.spawn(SetupPlayer, v)
		end
	end
	
	table.insert(connections, game.Players.PlayerAdded:Connect(SetupPlayer))
	
	_G.MX_ESPSystem.Update()
	
	task.spawn(function()
		local progressBox
		while task.wait(.25) and module.On do
			progressBox = plr.PlayerGui:FindFirstChild("ProgressBox", true)
			if progressBox and progressBox.Visible then
				RemoteEvent:FireServer("SetPlayerMinigameResult", true)
			end
		end
	end)
end

return module