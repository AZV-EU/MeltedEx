local module = {}

function module.PreInit()
	_G.MX_SETTINGS.ESP.Mode = 1
end

function module.Init(category, connections)
	local plr = game.Players.LocalPlayer
	
	local Workspace = _G.SafeGetService("Workspace")
	local ReplicatedStorage = _G.SafeGetService("ReplicatedStorage")
	local Interaction = ReplicatedStorage:WaitForChild("Interaction")
	
	local Remotes = {
		ClientIsDragging = Interaction:WaitForChild("ClientIsDragging")
	}
	
	local Properties = Workspace:WaitForChild("Properties")
	local LogModels = Workspace:WaitForChild("LogModels")
	local PlayerModels = Workspace:WaitForChild("PlayerModels")
	local Stores = Workspace:WaitForChild("Stores")
	
	local function GetMyPlot()
		for _,property in pairs(Properties:GetChildren()) do
			if property:FindFirstChild("Owner") and property.Owner.Value == plr and property:FindFirstChild("OriginSquare") then
				return property, property.OriginSquare.Position
			end
		end
	end
	
	local function GetLogs()
		local logs = {}
		for _,logModel in pairs(LogModels:GetChildren()) do
			if logModel:IsA("Model") and logModel:FindFirstChild("Owner") and (logModel.Owner.Value == plr or logModel.Owner.Value == nil) then
				local root, rootID
				for _,woodSection in pairs(logModel:GetChildren()) do
					if woodSection:IsA("BasePart") and woodSection.Name == "WoodSection" and woodSection:FindFirstChild("ID") then
						if not root or woodSection.ID.Value < rootID then
							root = woodSection
							rootID = woodSection.ID.Value
						end
					end
				end
				table.insert(logs, {logModel, root})
			end
		end
		return logs
	end
	
	local function GetItems()
		local items = {}
		for _,itemModel in pairs(PlayerModels:GetChildren()) do
			if itemModel:IsA("Model") and itemModel:FindFirstChild("Owner") and (itemModel.Owner.Value == plr or itemModel.Owner.Value == nil) then
				local root = itemModel.PrimaryPart
				if not root then
					local rootID
					for _,woodSection in pairs(itemModel:GetChildren()) do
						if woodSection:IsA("BasePart") and woodSection.Name == "WoodSection" and woodSection:FindFirstChild("ID") then
							if not root or woodSection.ID.Value < rootID then
								root = woodSection
								rootID = woodSection.ID.Value
							end
						end
					end
					if not root then continue end
				end
				if root.Anchored then continue end
				table.insert(items, {itemModel, root})
			end
		end
		return items
	end
	
	local function GetNearestCarryable()
		local dist
		local nearest, nearestDist
		for _,logData in pairs(GetLogs()) do
			dist = plr:DistanceFromCharacter(logData[2].Position)
			if dist < 20 and (not nearest or dist < nearestDist) then
				nearest = logData
				nearestDist = dist
			end
		end
		for _,itemData in pairs(GetItems()) do
			dist = plr:DistanceFromCharacter(itemData[2].Position)
			if dist < 20 and (not nearest or dist < nearestDist) then
				nearest = itemData
				nearestDist = dist
			end
		end
		if nearest then
			return nearest[1], nearest[2]
		end
	end
	
	category:AddButton("Teleport Home", function()
		local myPlot, plotPos = GetMyPlot()
		if myPlot then
			_G.TeleportPlayerTo(CFrame.new(plotPos + Vector3.new(0, 5, 0)))
		end
	end)
	
	do category:BeginInline()
		local carryNearest
		carryNearest = category:AddCheckbox("Carry Nearest", function(state)
			if state then
				task.wait()
				local nearest, root = GetNearestCarryable()
				if not nearest then
					carryNearest:SetChecked(false)
					return
				end
				
				local offset = CFrame.new(0, 0, -3 - root.Size.Y/2)
				local rot = CFrame.fromEulerAnglesXYZ(0,-math.pi/2,math.pi/2)
				
				while task.wait() and carryNearest.Checked and root.Parent and plr.Character and plr.Character.PrimaryPart and module.On do
					Remotes.ClientIsDragging:FireServer(nearest)
					root.CFrame = plr.Character.PrimaryPart.CFrame * offset * rot
					for _,part in pairs(nearest:GetChildren()) do
						if part:IsA("BasePart") then
							part.AssemblyLinearVelocity = Vector3.zero
							part.AssemblyAngularVelocity = Vector3.zero
						end
					end
				end
				carryNearest:SetChecked(false)
			end
		end)
	end category:EndInline()
	
	do category:BeginInline()
		category:AddButton("Tp Nearest Home", function()
			local nearest, root = GetNearestCarryable()
			local _, plotPos = GetMyPlot()
			if nearest and root and plotPos and plr.Character and plr.Character.PrimaryPart then
				Remotes.ClientIsDragging:FireServer(nearest)
				task.wait(.1)
				root.CFrame = CFrame.new(plotPos) * CFrame.new(0, 10 + root.Size.Y/2, 0)
				for _,part in pairs(nearest:GetChildren()) do
					if part:IsA("BasePart") then
						part.AssemblyLinearVelocity = Vector3.zero
						part.AssemblyAngularVelocity = Vector3.zero
					end
				end
			end
		end)
		
		local sellPos = Stores:WaitForChild("WoodRUs"):WaitForChild("Furnace"):FindFirstChild("Big",true).Parent.Position - Vector3.new(0, 5, 0)
		category:AddButton("Sell Nearest", function()
			local nearest, root = GetNearestCarryable()
			if nearest and root and plr.Character and plr.Character.PrimaryPart then
				Remotes.ClientIsDragging:FireServer(nearest)
				task.wait(.1)
				root.CFrame = CFrame.new(sellPos) * CFrame.new(0, 10 + root.Size.Y/2, 0) * CFrame.fromEulerAnglesXYZ(0,0,math.pi/2)
				for _,part in pairs(nearest:GetChildren()) do
					if part:IsA("BasePart") then
						part.AssemblyLinearVelocity = Vector3.zero
						part.AssemblyAngularVelocity = Vector3.zero
					end
				end
			end
		end)
	end category:EndInline()
	
	do -- region teleports
		local category = _G.MX_UIHandler:AddCategory("Regions")
		
		local regions = {
			["Maze Cave"] = Workspace:WaitForChild("Region_MazeCave"):FindFirstChild("ParticleEmitter",true).Parent.Position + Vector3.new(0,3,0),
			["Volcano"] = Vector3.new(-1614, 625, 1137),
			["Frost"] = Vector3.new(1452, 417, 3195)
		}
		
		local inline = false
		for regionName,targetPos in pairs(regions) do
			if not inline then
				category:BeginInline()
			end
			category:AddButton(regionName, function()
				_G.TeleportPlayerTo(targetPos)
			end)
			if inline then
				category:EndInline()
				inline = false
			else
				inline = true
			end
		end
		if inline then
			category:EndInline()
		end
	end
	
	do -- store teleports
		local category = _G.MX_UIHandler:AddCategory("Stores")
		
		local stores = {}
		for _,store in pairs(Stores:GetChildren()) do
			if store:FindFirstChild("Counter") then
				stores[store.Name] = store.Counter.Position + Vector3.new(0,3,0)
			end
		end
		stores["LandStore"] = Workspace.Stores:WaitForChild("LandStore").Union.Position
		
		local inline = false
		for storeName,targetPos in pairs(stores) do
			if not inline then
				category:BeginInline()
			end
			category:AddButton(storeName, function()
				_G.TeleportPlayerTo(targetPos)
			end)
			if inline then
				category:EndInline()
				inline = false
			else
				inline = true
			end
		end
		if inline then
			category:EndInline()
		end
	end
end

return module