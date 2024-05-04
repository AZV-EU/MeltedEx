local module = {
	Enabled = false
}

local COLOR_DEAD = Color3.new(0, 0, 0)

local Players = _G.SafeGetService("Players")
local Workspace = _G.SafeGetService("Workspace")

local plr = Players.LocalPlayer

module.WorkingFolder = Workspace:FindFirstChild("MXES") or Instance.new("Model", Workspace)
module.WorkingFolder.Name = "MXES"
module.WorkingFolder:ClearAllChildren()

module.HighlightStore = module.WorkingFolder:FindFirstChild("HIGHLIGHTS") or Instance.new("Folder", module.WorkingFolder)
module.HighlightStore.Name = "HIGHLIGHTS"

module.BillboardStore = module.WorkingFolder:FindFirstChild("BILLBOARDS") or Instance.new("Folder", module.WorkingFolder)
module.BillboardStore.Name = "BILLBOARDS"
module.BillboardStore:ClearAllChildren()

local NameGuiTemplate = Instance.new("BillboardGui")
NameGuiTemplate.AlwaysOnTop = true
NameGuiTemplate.Size = UDim2.fromScale(30, 3)
NameGuiTemplate.ResetOnSpawn = false
NameGuiTemplate.LightInfluence = 0
NameGuiTemplate.StudsOffsetWorldSpace = Vector3.new(0, 4, 0)
do
	local tl = Instance.new("TextLabel", NameGuiTemplate)
	tl.BackgroundTransparency = 1
	tl.Size = UDim2.fromScale(1, 1)
	tl.Font = Enum.Font.Roboto
	tl.TextSize = 16
	tl.TextColor3 = Color3.new(1, 1, 1)
	tl.TextStrokeTransparency = 0
end

local function AllocateTeamFolder(name)
	local folder = module.WorkingFolder:FindFirstChild("TEAM_" .. tostring(name)) or Instance.new("Model", module.WorkingFolder)
	folder.Name = "TEAM_" .. tostring(name)
	return folder
end

local existingHighlights = 0
local otherHighlights = {}
for _,instance in pairs(game:GetDescendants()) do
	if instance:IsA("Highlight") then
		existingHighlights += 1
		if not instance:IsDescendantOf(module.HighlightStore) then
			table.insert(otherHighlights, instance)
		end
	end
end
local function AllocateHighlight(name, color)
	name = tostring(name)
	local highlight = module.HighlightStore:FindFirstChild("HIGHLIGHT_" .. name)
	if not highlight then
		if existingHighlights >= 31 then
			if not _G.MX_SETTINGS.ESP.HijackHighlights then return end
			if #otherHighlights > 0 then
				highlight = otherHighlights[1]
				table.remove(otherHighlights, 1)
			else
				if _G.MX_SETTINGS.ESP.Mode == 1 then
					for _,h in pairs(module.HighlightStore:GetChildren()) do
						if h:IsA("Highlight") and h:FindFirstChild("Owner") and (not h.Owner.Value or not h.Owner.Value.Parent) then
							highlight = h
							break
						end
					end
				end
				if not highlight then
					print("MX_ESPSYSTEM Too many used highlights, cannot allocate more!")
					return
				end
			end
		else
			highlight = Instance.new("Highlight")
		end
	--elseif _G.MX_SETTINGS.ESP.Mode == 1 then
	--	return highlight
	end
	highlight.Name = "HIGHLIGHT_" .. name
	highlight.Archivable = true
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.FillColor = color
	highlight.FillTransparency = 0.6
	highlight.OutlineColor = _G.COLORS.WHITE
	highlight.OutlineTransparency = 0.6
	highlight.Parent = module.HighlightStore
	if _G.MX_SETTINGS.ESP.Mode == 1 and not highlight:FindFirstChild("Owner") then
		Instance.new("ObjectValue", highlight).Name = "Owner"
	end
	return highlight
end

module.Teams = {}
module.TeamsCount = 0

do -- Default (neutral) team
	module.Teams.Neutral = {
		Name = "Neutral",
		ShowNames = true,
		Color = _G.COLORS.WHITE,
		Rule = function() return true end,
		Folder = AllocateTeamFolder("Neutral"),
		Index = 1000
	}
	if _G.MX_SETTINGS.ESP.Mode == 0 then
		local h = AllocateHighlight("Neutral", _G.COLORS.WHITE)
		if h then
			h.Adornee = module.Teams.Neutral.Folder
		end
		module.Teams.Neutral.Highlight = h
	end
end

local IndexedTeams = {}
function module.ReindexTeams()
	IndexedTeams = {}
	for _,team in pairs(module.Teams) do
		table.insert(IndexedTeams, team)
	end
	table.sort(IndexedTeams, function(a,b)
		return a.Index < b.Index
	end)
	--[[print("IndexedTeams:")
	for _,team in pairs(IndexedTeams) do
		print(team.Name, team.Index)
	end]]
end

function module.AddTeam(name, color, rule, index)
	if not name or not color or not rule then return end
	name = tostring(name)
	if module.Teams[name] then return module.Teams[name] end
	
	module.TeamsCount += 1
	
	local team = {
		Name = name,
		ShowNames = true,
		Color = color,
		Rule = rule,
		Folder = AllocateTeamFolder(name),
		Index = index or module.TeamsCount * 10
	}
	if _G.MX_SETTINGS.ESP.Mode == 0 then
		local h = AllocateHighlight(name, color)
		if h then
			h.Adornee = team.Folder
		end
		team.Highlight = h
	end
	
	module.Teams[name] = team
	module.ReindexTeams()
	return module.Teams[name]
end

function module.RemoveTeam(name)
	if module.Teams[name] then
		module.Teams[name] = nil
		module.ReindexTeams()
		return true
	end
	return false
end

do -- add basic teams
	do -- dead humanoids
		local human
		module.AddTeam("Dead", _G.COLORS.BLACK, function(target)
			human = target:FindFirstChildWhichIsA("Humanoid")
			return human and human.Health <= 0
		end)
	end
	
	do -- local player's friends
		local player
		module.AddTeam("Friends", _G.COLORS.CYAN, function(target)
			player = Players:GetPlayerFromCharacter(target)
			return player and plr:IsFriendsWith(player.UserId)
		end)
	end
	
	do -- local player's enemies
		local player
		module.AddTeam("Enemies", _G.COLORS.RED, function(target)
			if plr.Team then
				player = Players:GetPlayerFromCharacter(target)
				return player and player.Team and player.Team ~= plr.Team
			end
			return false
		end)
	end
	
	do -- local player's teammates
		local player
		module.AddTeam("Allies", _G.COLORS.GREEN, function(target)
			if plr.Team then
				player = Players:GetPlayerFromCharacter(target)
				return player and player.Team and player.Team == plr.Team
			end
			return false
		end)
	end
end

function module.GetTeam(target)
	if not target then return module.Teams.Neutral, module.Teams.Neutral.Index end
	for index, team in ipairs(IndexedTeams) do
		if team.Rule(target) then
			return module.Teams[team.Name]
		end
	end
	return module.Teams.Neutral, module.Teams.Neutral.Index
end

function module.GetValidTargets()
	local targets = {}
	for k,v in pairs(Players:GetPlayers()) do
		if v ~= plr and v.Character then
			table.insert(targets, v.Character)
		end
	end
	return targets
end

local TargetStateMemory = {}

local CleanupTargetState
do
	CleanupTargetState = function(target)
		if not target then return end
		local state = TargetStateMemory[target]
		if not state then return end
		local player = Players:GetPlayerFromCharacter(target)
		if _G.MX_SETTINGS.ESP.HighlightsEnabled and target.Parent then
			if _G.MX_SETTINGS.ESP.Mode == 0 then
				if state.OldParent ~= nil then
					if not player then
						pcall(function() target.Parent = nil end)
						task.wait(.1)
					end
					local f, err = pcall(function() target.Parent = state.OldParent end)
					if not f then
						warn("[MX::ESPSystem] CleanupTargetState1 for", _G.Stringify(target), "error:", err)
					end
				else
					if not player then
						pcall(function() target.Parent = nil end)
						task.wait(.1)
					end
					local f, err = pcall(function() target.Parent = Workspace end)
					if not f then
						warn("[MX::ESPSystem] CleanupTargetState2 for", _G.Stringify(target), "error:", err)
					end
				end
			elseif _G.MX_SETTINGS.ESP.Mode == 1 then
				local h = module.HighlightStore:FindFirstChild("HIGHLIGHT_" .. tostring(target.Name))
				if h then
					h.Owner.Value = nil
					h.Enabled = false
				end
			end
		end
		if state.Billboard then
			pcall(state.Billboard.Destroy, state.Billboard)
		end
		TargetStateMemory[target] = nil
	end
end

do
	function module.UpdateTarget(target, in_player)
		if not module.Enabled then return end
		if not target or not target.Parent then return end
		local team = module.GetTeam(target)
		if not team or (_G.MX_SETTINGS.ESP.Mode == 0 and not team.Folder) then
			print("MX_ESPSYSTEM NO TEAM FOR TARGET '", target, "'")
			return
		end
		if team.Hidden then
			CleanupTargetState(target)
			return
		end
		local state = TargetStateMemory[target]
		if not state then
			TargetStateMemory[target] = {
				Updating = false,
				OldParent = target.Parent,
				Billboard = team.ShowNames and NameGuiTemplate:Clone() or nil
			}
			state = TargetStateMemory[target]
			if state.Billboard then
				state.Billboard.Parent = module.BillboardStore
			end
		end
		
		if state.Updating then return end
		state.Updating = true
		
		local player = in_player or Players:GetPlayerFromCharacter(target)
		if _G.MX_SETTINGS.ESP.HighlightsEnabled then
			if _G.MX_SETTINGS.ESP.Mode == 0 and target.Parent ~= team.Folder then
				task.spawn(function()
					if not player then
						pcall(function() target.Parent = nil end)
						task.wait(.1)
					end
					pcall(function() target.Parent = team.Folder end)
				end)
			elseif _G.MX_SETTINGS.ESP.Mode == 1 then
				local f, err = pcall(function()
					local h = AllocateHighlight(target.Name, team.Color)
					if h then
						h:SetAttribute("Dirty", nil)
						h.Owner.Value = target
						h.FillColor = team.Color
						h.Adornee = target
						h.Enabled = true
					end
				end)
				if not f then
					warn(err)
				end
			end
		end
		if state.Billboard and state.Billboard:FindFirstChild("TextLabel") then
			xpcall(function()
				state.Billboard.TextLabel.Text = player and player.DisplayName or target.Name
				state.Billboard.TextLabel.TextColor3 = team.Color
				state.Billboard.Adornee = target:FindFirstChild("HumanoidRootPart") or target
				state.Billboard.Enabled = state.Billboard.Adornee ~= nil
			end, function(err) print("[MX::ESPSystem] UpdateTarget error:", err) end)
		end
		state.Updating = false
	end
end

function module.Update()
	if _G.MX_SETTINGS.ESP.Mode == 0 then
		for _,team in pairs(module.Teams) do
			if team.Highlight and team.Color then
				team.Highlight.FillColor = team.Color
			end
		end
	elseif _G.MX_SETTINGS.ESP.Mode == 1 then
		for _,highlight in pairs(module.HighlightStore:GetChildren()) do
			if highlight:IsA("Highlight") then
				highlight:SetAttribute("Dirty", true)
			end
		end
	end
	if module.Enabled then
		for index, target in pairs(module.GetValidTargets()) do
			module.UpdateTarget(target)
		end
		for target,state in pairs(TargetStateMemory) do
			if target and not target.Parent then
				CleanupTargetState(target)
			end
		end
	end
	if _G.MX_SETTINGS.ESP.Mode == 1 then
		for _,highlight in pairs(module.HighlightStore:GetChildren()) do
			if highlight:IsA("Highlight") and highlight:GetAttribute("Dirty") then
				highlight:SetAttribute("Dirty", nil)
				highlight.Owner.Value = nil
				highlight.Enabled = false
				highlight.Adornee = nil
			end
		end
	end
	
	for _,billboard in pairs(module.BillboardStore:GetChildren()) do
		if billboard:IsA("BillboardGui") then
			billboard.Enabled = billboard.Adornee ~= nil
		end
	end
end

local function TargetStateCleanup()
	for target,state in pairs(TargetStateMemory) do
		if target then
			CleanupTargetState(target)
		end
	end
	TargetStateMemory = {}
end

module.CustomRefreshConnection = nil

local PrivateConnections = {
	General = {},
	PlayerRefresh = {},
	PlayerTeamChanged = {},
	PlayerCharacterRemoving = {},
	PlayerCharacterAdded = {}
}

local function SetupPrivateConnections()
	local function SetupCharacter(chr)
		local player = Players:GetPlayerFromCharacter(chr)
		if not player then print(chr, "is not a valid character of any player!") return end
		if PrivateConnections.PlayerRefresh[player] then
			pcall(PrivateConnections.PlayerRefresh[player].Disconnect, PrivateConnections.PlayerRefresh[player])
			PrivateConnections.PlayerRefresh[player] = nil
		end
		
		local human
		repeat
			task.wait()
			human = chr:FindFirstChildWhichIsA("Humanoid")
		until human
		
		if module.CustomRefreshConnection then
			PrivateConnections.PlayerRefresh[player] = module.CustomRefreshConnection(player, chr, human, function()
				module.UpdateTarget(chr, player)
				PrivateConnections.PlayerRefresh[player] = nil
			end)
		else
			PrivateConnections.PlayerRefresh[player] = human.Died:Once(function()
				module.UpdateTarget(chr, player)
				PrivateConnections.PlayerRefresh[player] = nil
			end)
		end
		
		module.Update()
		--module.UpdateTarget(chr, player)
	end
	
	local function SetupPlayer(player)
		if PrivateConnections.PlayerCharacterAdded[player] then
			pcall(PrivateConnections.PlayerCharacterAdded[player].Disconnect, PrivateConnections.PlayerCharacterAdded[player])
			PrivateConnections.PlayerCharacterAdded[player] = nil
		end
		PrivateConnections.PlayerCharacterAdded[player] = player.CharacterAdded:Connect(SetupCharacter)
		
		PrivateConnections.PlayerCharacterRemoving[player] = player.CharacterRemoving:Connect(function(chr)
			if PrivateConnections.PlayerRefresh[player] then
				pcall(PrivateConnections.PlayerRefresh[player].Disconnect, PrivateConnections.PlayerRefresh[player])
				PrivateConnections.PlayerRefresh[player] = nil
			end
			pcall(function() chr.Parent = nil end)
			module.Update()
		end)
		
		PrivateConnections.PlayerTeamChanged[player] = player:GetPropertyChangedSignal("Team"):Connect(function()
			module.UpdateTarget(player.Character, player)
		end)
		
		repeat task.wait() until player.Character
		SetupCharacter(player.Character)
	end
	
	table.insert(PrivateConnections.General, Players.PlayerAdded:Connect(SetupPlayer))
	
	table.insert(PrivateConnections.General, Players.PlayerRemoving:Connect(function(player)
		if player ~= plr then
			CleanupTargetState(player.Character)
			
			if PrivateConnections.PlayerRefresh[player] then
				pcall(PrivateConnections.PlayerRefresh[player].Disconnect, PrivateConnections.PlayerRefresh[player])
				PrivateConnections.PlayerRefresh[player] = nil
			end
			
			if PrivateConnections.PlayerTeamChanged[player] then
				pcall(PrivateConnections.PlayerTeamChanged[player].Disconnect, PrivateConnections.PlayerTeamChanged[player])
				PrivateConnections.PlayerTeamChanged[player] = nil
			end
			
			if PrivateConnections.PlayerCharacterAdded[player] then
				pcall(PrivateConnections.PlayerCharacterAdded[player].Disconnect, PrivateConnections.PlayerCharacterAdded[player])
				PrivateConnections.PlayerCharacterAdded[player] = nil
			end
			
			if PrivateConnections.PlayerCharacterRemoving[player] then
				pcall(PrivateConnections.PlayerCharacterRemoving[player].Disconnect, PrivateConnections.PlayerCharacterRemoving[player])
				PrivateConnections.PlayerCharacterRemoving[player] = nil
			end
			
			if player.Character then
				pcall(function() player.Character.Parent = nil end)
			end
			
			task.wait(.1)
			
			module.Update()
		end
	end))
	
	for _,player in pairs(Players:GetPlayers()) do
		if player ~= plr then
			task.spawn(SetupPlayer, player)
		end
	end
	
	table.insert(PrivateConnections.General, plr:GetPropertyChangedSignal("Team"):Connect(module.Update))
end

local function CleanupPrivateConnections()
	for _,category in pairs(PrivateConnections) do
		for _,conn in pairs(category) do
			pcall(conn.Disconnect, conn)
		end
	end
	PrivateConnections = {
		General = {},
		PlayerRefresh = {},
		PlayerTeamChanged = {},
		PlayerCharacterRemoving = {},
		PlayerCharacterAdded = {}
	}
end

function module.SetEnabled(enabled)
	if not module.Enabled and enabled then
		module.Enabled = true
		for _,highlight in pairs(module.HighlightStore:GetChildren()) do
			highlight.Enabled = true
		end
		SetupPrivateConnections()
		module.Update()
	elseif module.Enabled and not enabled then
		module.Enabled = false
		for _,highlight in pairs(module.HighlightStore:GetChildren()) do
			highlight.Enabled = false
		end
		module.BillboardStore:ClearAllChildren()
		CleanupPrivateConnections()
		TargetStateCleanup()
	end
end

return module