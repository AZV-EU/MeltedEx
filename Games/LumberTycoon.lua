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
		ClientIsDragging = Interaction:WaitForChild("ClientIsDragging"),
		RemoteProxy = Interaction:WaitForChild("RemoteProxy")
	}
	
	local Properties = Workspace:WaitForChild("Properties")
	local LogModels = Workspace:WaitForChild("LogModels")
	local PlayerModels = Workspace:WaitForChild("PlayerModels")
	local Stores = Workspace:WaitForChild("Stores")
	local Lava = Workspace:WaitForChild("Region_Volcano"):WaitForChild("Lava"):WaitForChild("Lava")
	local SellCFrame = CFrame.new(315, 0, 85)
	
	-- putting into _G as to not memory leak per reset
	if not _G.AxeClasses then
		local LOCAL_BRIDGE, BRIDGE_IN = _G.LocalBridge([[script:WaitForChild("DATA_IN").OnInvoke = function(axeClass)
	return require(axeClass).new()
end]], "LT2_BRIDGE")
		_G.AxeClasses = {}
		for _,axeClass in pairs(ReplicatedStorage:WaitForChild("AxeClasses"):GetChildren()) do
			if axeClass:IsA("ModuleScript") and axeClass.Name:sub(1,9) == "AxeClass_" then
				_G.AxeClasses[axeClass.Name:sub(10)] = BRIDGE_IN:Invoke(axeClass)
			end
		end
		LOCAL_BRIDGE:Destroy()
	end
	
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
	
	local function GetNearestTree()
		local dist
		local nearest, nearestDist
		for _,logData in pairs(GetLogs()) do
			dist = plr:DistanceFromCharacter(logData[2].Position)
			if dist < 20 and (not nearest or dist < nearestDist) then
				nearest = logData
				nearestDist = dist
			end
		end
		if nearest then
			return nearest[1], nearest[2]
		end
	end
	
	local function CalculateAxeDamage(axeName, treeClass)
		axeName = axeName or ""
		local axeClass = _G.AxeClasses[axeName]
		local damage, cooldown = 0, 1
		if axeClass then
			damage = axeClass.Damage
			cooldown = axeClass.SwingCooldown
			if treeClass and axeClass.SpecialTrees and axeClass.SpecialTrees[treeClass] then
				damage = axeClass.SpecialTrees[treeClass].Damage
				cooldown = axeClass.SpecialTrees[treeClass].SwingCooldown
			end
		end
		return damage * (1 / cooldown), damage, cooldown
	end
	
	local function GetBestAxe(tree)
		if not plr.Character or not plr.Character.Parent then return end
		local axes = {}
		for _,tool in pairs(plr.Backpack:GetChildren()) do
			if tool:IsA("Tool") and tool.Name == "Tool" and tool:FindFirstChild("AxeClient") and tool:FindFirstChild("ToolName") then
				table.insert(axes, tool)
			end
		end
		for _,tool in pairs(plr.Character:GetChildren()) do
			if tool:IsA("Tool") and tool.Name == "Tool" and tool:FindFirstChild("AxeClient") and tool:FindFirstChild("ToolName") then
				table.insert(axes, tool)
			end
		end
		
		if #axes > 0 then
			local best = axes[1]
			local bestDPS, bestDamage, bestCooldown = CalculateAxeDamage(best.ToolName.Value)
			if tree and tree:FindFirstChild("TreeClass") then
				best = nil
				bestDPS = 0
				local dps, damage, cooldown
				for _,axe in pairs(axes) do
					dps, damage, cooldown = CalculateAxeDamage(axe.ToolName.Value, tree.TreeClass.Value)
					if not best or dps > bestDPS then
						best = axe
						bestDPS = dps
						bestDamage = damage
						bestCooldown = cooldown
					end
				end
			end
			return best, bestDamage, bestCooldown
		end
	end
	
	local function HitTree(tree, sectionId, height)
		if not tree then warn("no tree to hit") return end
		local cutEvent = tree:FindFirstChild("CutEvent")
		if not cutEvent then warn("no cutevent") return end
		local axe, axeDamage, axeCooldown = GetBestAxe(tree)
		if not axe or axeDamage <= 0 then warn("no best axe") return end
		
		sectionId = sectionId or 1
		Remotes.RemoteProxy:FireServer(cutEvent,
			{
				height = height or 0.5,
				sectionId = sectionId or 1,
				faceVector = Vector3.xAxis,
				hitPoints = axeDamage,
				cooldown = axeCooldown,
				tool = axe,
				cuttingClass = "Axe"
			}
		)
		return true, axeCooldown
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
				task.wait(.1)
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
		category:AddButton("HomeTp Nearest", function()
			local nearest, root = GetNearestCarryable()
			local _, plotPos = GetMyPlot()
			if nearest and root and plotPos then
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
		
		category:AddButton("Sell Nearest", function()
			local tree, root = GetNearestTree()
			if tree and root then
				Remotes.ClientIsDragging:FireServer(tree)
				task.wait(.1)
				root.CFrame = SellCFrame
				for _,part in pairs(tree:GetChildren()) do
					if part:IsA("BasePart") then
						part.AssemblyLinearVelocity = Vector3.zero
						part.AssemblyAngularVelocity = Vector3.zero
					end
				end
			end
		end)
		
		table.insert(connections, Lava.Touched:Connect(function(part) end))
		
		local treeModding = false
		local modTree
		modTree = category:AddButton("Mod Nearest", function()
			if treeModding then
				treeModding = false
				modTree:SetText("Mod Nearest")
			else
				local tree, root = GetNearestTree()
				if tree and root and plr.Character and plr.Character.PrimaryPart then
					local highest, highestID
					for _,section in pairs(tree:GetChildren()) do
						if section.Name == "WoodSection" and section:FindFirstChild("ID") then
							if not highest or section.ID.Value > highestID then
								highest = section
								highestID = section.ID.Value
							end
						end
					end
					if highest and highest ~= root and highestID > 2 then
						local parentID = highest.ParentID.Value
						if parentID ~= root.ID.Value then
							local parent
							for _,section in pairs(tree:GetChildren()) do
								if section.Name == "WoodSection" and section:FindFirstChild("ID") and section.ID.Value == parentID then
									parent = section
									break
								end
							end
							if parent then
								treeModding = true
								modTree:SetText("Cancel Mod")
								local pOrigin, tOrigin = plr.Character.PrimaryPart.CFrame, root.CFrame
								
								_G.TeleportPlayerTo(root.Position + Vector3.new(0, 0, 3))
								task.wait(.1)
								Remotes.ClientIsDragging:FireServer(tree)
								task.wait(.1)
								_G.TeleportPlayerTo(CFrame.new(-1425, 435, 1244))
								root.CFrame = CFrame.new(-1425, 435 + root.Size.Y/2, 1247)
								root.AssemblyLinearVelocity = Vector3.zero
								root.AssemblyAngularVelocity = Vector3.zero
								task.wait()
								for _,weld in pairs(parent:GetChildren()) do
									if weld:IsA("Weld") then
										weld:Destroy()
									end
								end
								if not treeModding or not module.On then return end
								
								print("putting on fire")
								repeat
									Remotes.ClientIsDragging:FireServer(tree)
									task.wait()
									root.CFrame = CFrame.new(-1425, 440 + root.Size.Y/2, 1247)
									_G.TeleportPlayerTo(CFrame.new(-1425, 435, 1244))
									root.AssemblyLinearVelocity = Vector3.zero
									root.AssemblyAngularVelocity = Vector3.zero
									task.wait()
									root.CFrame = CFrame.new(Lava.Position + Vector3.new(0, Lava.Size.Y/2 + root.Size.Y/2 + 5, 0))
									root.AssemblyLinearVelocity = Vector3.zero
									root.AssemblyAngularVelocity = Vector3.zero
									parent.Position = Lava.Position + Vector3.new(0, Lava.Size.Y/2, 0)
									task.wait()
									root.CFrame = CFrame.new(-1425, 440 + root.Size.Y/2, 1247)
								until parent:FindFirstChild("LavaFire") or not treeModding or not module.On
								if not treeModding or not module.On then return end
								
								print("selling parent")
								repeat
									_G.TeleportPlayerTo(root.Position + Vector3.new(0, 0, 3))
									task.wait()
									Remotes.ClientIsDragging:FireServer(tree)
									task.wait()
									root.CFrame = CFrame.new(-1055, 291, -458)
									_G.TeleportPlayerTo(CFrame.new(-1055, 291, -458))
									root.AssemblyLinearVelocity = Vector3.zero
									root.AssemblyAngularVelocity = Vector3.zero
									parent.CFrame = SellCFrame
									task.wait(.1)
								until not parent or not parent.Parent or not treeModding or not module.On
								if not treeModding or not module.On then return end
								
								print("going back")
								_G.TeleportPlayerTo(root.Position + Vector3.new(0, 0, 3))
								task.wait(.1)
								Remotes.ClientIsDragging:FireServer(tree)
								task.wait(.1)
								root.CFrame = tOrigin
								_G.TeleportPlayerTo(pOrigin)
								highest.CFrame = CFrame.new(pOrigin.Position + Vector3.new(0, 5, 0))
								
								local rootMass = math.floor(root.AssemblyMass)
								if not HitTree(tree, root.ID.Value) then
									print("Could not cutoff tree trunk")
									return
								end
								
								local success, cooldown
								repeat
									_G.TeleportPlayerTo(root.Position + Vector3.new(0, 0, 3))
									task.wait()
									Remotes.ClientIsDragging:FireServer(tree)
									task.wait()
									success, cooldown = HitTree(tree, root.ID.Value)
									task.wait(.1)
								until math.floor(root.AssemblyMass) < rootMass or not success or not treeModding or not module.On
							else
								_G.Notify("Tree not high enough [3]", "Mod Wood Fail")
							end
						else
							_G.Notify("Tree not high enough [2]", "Mod Wood Fail")
						end
					else
						_G.Notify("Tree not high enough [1]", "Mod Wood Fail")
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
			["Frost"] = Vector3.new(1452, 417, 3195),
			["Beach"] = Vector3.new(2620, -4.5, -10)
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