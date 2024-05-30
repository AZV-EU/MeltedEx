local module = {}

function module.PreInit()
	_G.MX_SETTINGS.SETUP.SetCameraMaxZoomDistance = false
end

function module.Init()
	local MainLocalScript = plr:WaitForChild("PlayerScripts"):WaitForChild("MainLocalScript")
	local CWorld = MainLocalScript:WaitForChild("CWorld")
	
	local Constants = {
		PlayerReachBlocks = 5.5,
		BlockSize = 3
	}
	Constants.PlayerReach = Constants.PlayerReachBlocks * Constants.BlockSize - 1
	
	local HttpService = _G.SafeGetService("HttpService")
	local GameRemotes = ReplicatedStorage:WaitForChild("GameRemotes")
	local AssetsMod = ReplicatedStorage:WaitForChild("AssetsMod")
	
	do
		for _,ms in pairs(AssetsMod:GetChildren()) do
			if ms:IsA("ModuleScript") then
				_G.SetIsRobloxScriptModule(ms, true)
			end
		end
		
		-- required by most modules in AssetsMod
		local enums = _G.SafeGetService("ReplicatedFirst"):WaitForChild("Shared"):WaitForChild("Enums")
		_G.SetIsRobloxScriptModule(enums, true)
	end
	
	local Textures = require(AssetsMod:WaitForChild("Textures"))
	local ItemInfo = require(AssetsMod:WaitForChild("ItemInfo"))
	local ItemLevels = require(AssetsMod:WaitForChild("ItemLevels"))
	
	do -- cleanup in order to allow normal functioning of the game
		for _,ms in pairs(AssetsMod:GetChildren()) do
			if ms:IsA("ModuleScript") then
				_G.SetIsRobloxScriptModule(ms, false)
			end
		end
		local enums = _G.SafeGetService("ReplicatedFirst"):WaitForChild("Shared"):WaitForChild("Enums")
		_G.SetIsRobloxScriptModule(enums, false)
	end
	
	do -- setup itemInfo
		for itemName, itemInfo in pairs(ItemInfo) do
			if type(itemInfo) == "table" then
				itemInfo.name = itemName
			end
		end
	end
	
	local Remotes = {
		Attack = GameRemotes:WaitForChild("Attack"),
		ChangeSlot = GameRemotes:WaitForChild("ChangeSlot"),
		DropItem = GameRemotes:WaitForChild("DropItem"),
		MoveItem = GameRemotes:WaitForChild("MoveItem"),
		BreakBlock = GameRemotes:WaitForChild("BreakBlock"),
		AcceptBreakBlock = GameRemotes:WaitForChild("AcceptBreakBlock"),
		UseBlock = GameRemotes:WaitForChild("UseBlock")
	}
	
	local PlayerGui = plr:WaitForChild("PlayerGui")
	local hud = PlayerGui:WaitForChild("HUDGui")
	local overshadow = hud:WaitForChild("Overshadow")
	local inventoryHud = hud:WaitForChild("Inventory")
	
	local Blocks = game.Workspace:WaitForChild("Blocks")
	local Fluids = game.Workspace:WaitForChild("Fluid")
	
	local function FixGui()
		-- remove gamepasses
		for k,v in pairs(PlayerGui:WaitForChild("GamePass Shop Gui"):GetChildren()) do
			v.Visible = false
		end
		
		-- remove vignette
		hud:WaitForChild("Vignette").Visible = false
		
		-- remove pesky paid items
		for _,inv in pairs(hud:WaitForChild("Inventory"):GetChildren()) do
			if inv:IsA("Frame") and inv.Name == "Inventory" then
				inv.Visible = false
			end
		end
		if hud.Inventory:FindFirstChild("Frame") then -- craftblox's advert
			hud.Inventory.Frame.Visible = false
		end
		
		task.wait(3)
		if PlayerGui:FindFirstChild("LoadingGui") then
			PlayerGui.LoadingGui:Destroy()
		end
	end
	task.spawn(FixGui)
	table.insert(connections, plr.CharacterAdded:Connect(FixGui))
	
	-- mute music
	for k,v in pairs(ReplicatedStorage:WaitForChild("Music"):GetChildren()) do
		if v:IsA("Sound") then
			v.Volume = 0
		end
	end
	
	-- anti-falldamage
	local DemoRemote = GameRemotes:FindFirstChild("Demo")
	if DemoRemote and not DemoRemote:FindFirstChild("_isFake") then
		--_G.MethodEmulator:SetMethodOverride(DemoRemote, "FireServer", function() end)
		local fake = Instance.new("RemoteEvent", GameRemotes)
		fake.Name = "Demo"
		Instance.new("BoolValue", fake).Name = "_isFake"
		DemoRemote:Destroy()
	end
	
	-- faster throw held items
	local function GetMyInventory()
		if plr and plr.Character then
			return plr.Character:FindFirstChild("Inventory")
		end
	end
	
	local throwBackground = overshadow:FindFirstChildWhichIsA("TextButton") or Instance.new("TextButton", overshadow)
	do
		throwBackground.Size = UDim2.fromScale(1, 1)
		throwBackground.BackgroundTransparency = 1
		throwBackground.AutoButtonColor = false
		throwBackground.Modal = true
		throwBackground.Text = ""
		throwBackground.Interactable = true
		throwBackground.Active = true
		table.insert(connections, throwBackground.Activated:Connect(function(input)
			if 	input.Position.X >= inventoryHud.AbsolutePosition.X and
				input.Position.X <= inventoryHud.AbsolutePosition.X + inventoryHud.AbsoluteSize.X and
				input.Position.Y >= inventoryHud.AbsolutePosition.Y and
				input.Position.Y <= inventoryHud.AbsolutePosition.Y + inventoryHud.AbsoluteSize.Y then
				return
			else
				local inventory = GetMyInventory()
				if inventory then
					local heldSlot = inventory:FindFirstChild("Slot-1")
					if heldSlot then
						local heldItem = HttpService:JSONDecode(heldSlot.Value)
						if heldItem.count > 0 then
							Remotes.DropItem:InvokeServer(true)
						end
					end
				end
			end
		end))
	end

	category:BeginInline()
	local autoAttack
	autoAttack = category:AddCheckbox("[C] Auto-Attack", function(state)
		if state then
			while task.wait(.33) and autoAttack.Checked and module.On do
				local closest, dist = nil, 0
				local tdist = 0
				for k,v in pairs(game.Players:GetPlayers()) do
					if v ~= plr and v.Character ~= nil and not v.Character:FindFirstChildWhichIsA("ForceField") then
						tdist = plr:DistanceFromCharacter(v.Character:GetPivot().Position)
						if tdist <= Constants.PlayerReach and not plr:IsFriendsWith(v.UserId) then
							if not closest or tdist < dist then
								closest = v
								dist = tdist
							end
						end
					end
				end
				if closest then
					task.spawn(function()
						Remotes.Attack:InvokeServer(closest.Character)
					end)
				end
			end
		end
	end)
	
	table.insert(connections, UserInputService.InputBegan:Connect(function(input, gp)
		if input.KeyCode == Enum.KeyCode.C and not gp then
			autoAttack:SetChecked(not autoAttack.Checked)
		end
	end))
	
	local function setXray(state)
		for _, region in pairs(Blocks:GetChildren()) do
			for _, block in pairs(region:GetChildren()) do
				if block:FindFirstChild("BoxHandleAdornment") then
					block.BoxHandleAdornment.Visible = state
				else
					
					if block.Name == "SapphireOre" then
						local bha = Instance.new("BoxHandleAdornment", block)
						bha.Adornee = block
						bha.AlwaysOnTop = true
						bha.Color3 = Color3.fromRGB(29, 29, 211)
						bha.Size = Vector3.new(3, 3, 3)
						bha.Transparency = 0.7
						bha.ZIndex = 10
						bha.Visible = state
					end
					
				end
			end
		end
	end
	
	local xray
	xray = category:AddCheckbox("Blocks X-Ray", function(state)
		setXray(state)
		if state then
			while task.wait(5) and xray.Checked and module.On do
				setXray(true)
			end
		end
	end)
	category:EndInline()
	
	local itemsXRayBillboard = Instance.new("BillboardGui")
	itemsXRayBillboard.Name = "ItemsBillboard"
	itemsXRayBillboard.AlwaysOnTop = true
	itemsXRayBillboard.ResetOnSpawn = false
	itemsXRayBillboard.LightInfluence = 0
	itemsXRayBillboard.Size = UDim2.fromScale(15, 30)
	itemsXRayBillboard.StudsOffsetWorldSpace = Vector3.new(0, 6, 0)
	itemsXRayBillboard.SizeOffset = Vector2.new(0, .5)
	do
		local container = Instance.new("Frame", itemsXRayBillboard)
		container.Name = "ItemsContainer"
		container.BackgroundTransparency = 1
		container.Size = UDim2.fromScale(1, 1)
		
		local layout = Instance.new("UIGridLayout", container)
		layout.CellSize = UDim2.fromScale(.2, .1)
		layout.CellPadding = UDim2.new(0,0,0,0)
		layout.StartCorner = Enum.StartCorner.BottomLeft
		layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
	end
	
	local itemsTextures = game.StarterPlayer.StarterPlayerScripts.MainLocalScript.ItemTextures
	local itemsXRay, itemsXRayFilter
	
	local itemFilter = {
		"ore", "steel", "gold", "diamond", "ruby", "sapphire", "rainbowite"
	}
	
	local function applyFilter(itemName)
		for _,filter in pairs(itemFilter) do
			if itemName:find(filter) then return true end
		end
		return false
	end
	
	local function updateItemsXRay()
		if not itemsXRay.Checked or not module.On then return end
		local inventory, billboard, container, items, itemsSorted, data, dataName, texture, itemUI, countUI
		for _,player in pairs(game.Players:GetPlayers()) do
			if player ~= plr and player.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
				inventory = player.Character:FindFirstChild("Inventory")
				if inventory then
					billboard = player.Character:FindFirstChild("ItemsXRayBillboard")
					if not billboard then
						billboard = itemsXRayBillboard:Clone()
						billboard.Name = "ItemsXRayBillboard"
						billboard.Adornee = player.Character:FindFirstChild("HumanoidRootPart")
						billboard.Parent = player.Character
					end
					billboard.Enabled = true
					container = billboard:FindFirstChild("ItemsContainer")
					if container then
						items = {}
						for _,slot in pairs(inventory:GetChildren()) do
							if slot:IsA("StringValue") then
								data = HttpService:JSONDecode(slot.Value)
								-- {"durability":false,"count":0,"name":""}
								if data and data.name and data.count > 0 then
									dataName = data.name:lower()
									if itemsTextures:FindFirstChild(dataName) and
										(not itemsXRayFilter.Checked or applyFilter(dataName)) then
										if not items[dataName] then
											items[dataName] = data.count
										else
											items[dataName] += data.count
										end
									end
								end
							end
						end
						for _,oldItemUI in pairs(container:GetChildren()) do
							if oldItemUI:IsA("ImageLabel") and not items[oldItemUI.Name] then
								oldItemUI:Destroy()
							end
						end
						for itemName,count in pairs(items) do
							itemUI = container:FindFirstChild(itemName)
							texture = itemsTextures[itemName]
							if texture:IsA("Frame") then
								texture = texture:FindFirstChildWhichIsA("ImageLabel")
							end
							if not itemUI then
								itemUI = Instance.new("ImageLabel")
								itemUI.Name = itemName
								itemUI.BackgroundTransparency = 1
								itemUI.Image = texture.Image
								itemUI.Parent = container
							end
							countUI = itemUI:FindFirstChild("CountLabel")
							if not countUI then
								countUI = Instance.new("TextLabel", itemUI)
								countUI.Name = "CountLabel"
								countUI.TextScaled = true
								countUI.TextColor3 = _G.COLORS.WHITE
								countUI.TextStrokeTransparency = 0
								countUI.Font = Enum.Font.Roboto
								countUI.Size = UDim2.new(1, 0, .5, 0)
								countUI.Position = UDim2.fromScale(0, .5)
								countUI.BackgroundTransparency = 1
								countUI.TextXAlignment = Enum.TextXAlignment.Right
								countUI.TextYAlignment = Enum.TextYAlignment.Bottom
							end
							countUI.Text = tostring(count)
						end
					end
				end
			end
		end
	end
	
	category:BeginInline()
	itemsXRay = category:AddCheckbox("Items X-Ray", function(state)
		itemsXRayFilter:SetVisible(state)
		if state then
			updateItemsXRay()
			while task.wait(1) and itemsXRay.Checked and module.On do
				updateItemsXRay()
			end
			for _,player in pairs(game.Players:GetPlayers()) do
				if player ~= plr and player.Character and player.Character:FindFirstChild("ItemsXRayBillboard") then
					player.Character.ItemsXRayBillboard:Destroy()
				end
			end
		end
	end)
	itemsXRayFilter = category:AddCheckbox("Filter", updateItemsXRay)
	itemsXRayFilter:SetVisible(false)
	category:EndInline()
	
	category:BeginInline()
	-- chest start = 36 end = 62
	local function GetNextFreeSlot(rangeMin, rangeMax)
		local inventory = GetMyInventory()
		if inventory then
			local slot, slotItem
			for i = rangeMin, rangeMax do
				slot = inventory:FindFirstChild("Slot" .. tostring(i))
				if slot then
					slotItem = HttpService:JSONDecode(slot.Value)
					if slotItem and slotItem.count <= 0 then
						return i
					end
				end
			end
		end
		return -1
	end
	category:AddButton("Take ⬇️ All Items", function()
		local inventory = GetMyInventory()
		if inventory then
			local slot, slotItem, targetSlot
			for i = 36, 62 do
				targetSlot = GetNextFreeSlot(0, 35)
				if targetSlot < 0 then break end
				slot = inventory:FindFirstChild("Slot" .. tostring(i))
				if slot then
					slotItem = HttpService:JSONDecode(slot.Value)
					if slotItem and slotItem.count > 0 then
						Remotes.MoveItem:InvokeServer(i, targetSlot, slotItem.count == 1 and true or 64)
					end
				end
			end
		end
	end)
	category:AddButton("Put ⬆️ All Items", function()
		local inventory = GetMyInventory()
		if inventory then
			local slot, slotItem, targetSlot
			for i = 0, 35 do
				targetSlot = GetNextFreeSlot(36, 62)
				if targetSlot < 0 then break end
				slot = inventory:FindFirstChild("Slot" .. tostring(i))
				if slot then
					slotItem = HttpService:JSONDecode(slot.Value)
					if slotItem and slotItem.count > 0 then
						Remotes.MoveItem:InvokeServer(i, targetSlot, slotItem.count == 1 and true or 64)
					end
				end
			end
		end
	end)
	category:EndInline()
	
	local function PtoT(x,y,z)
		if type(x) == "vector" then
			x,y,z = x.X,x.Y,x.Z
		end
		return math.floor(x / Constants.BlockSize + .5),
			math.floor(y / Constants.BlockSize + .5),
			math.floor(z / Constants.BlockSize + .5)
	end
	
	local function FindBlocks(blockName)
		local blocks = {}
		for _, region in pairs(Blocks:GetChildren()) do
			for _, block in pairs(region:GetChildren()) do
				if block.Name == blockName then
					table.insert(blocks, block)
				end
			end
		end
		return blocks
	end
	
	category:AddButton("Destroy nearest chest", function()
		local chests = FindBlocks("Chest")
		if #chests > 0 then
			local nearest, nearestDist, dist
			for _,chest in pairs(chests) do
				dist = plr:DistanceFromCharacter(chest.Position)
				if dist < Constants.PlayerReach and (not nearest or dist < nearestDist) then
					nearest = chest
					nearestDist = dist
				end
			end
			if nearest then
				local cX, cY, cZ = PtoT(nearest.Position)
				Remotes.BreakBlock:FireServer(cX, cY, cZ)
				task.wait(0.7)
				if Remotes.AcceptBreakBlock:InvokeServer() then
					_G.LocalModuleInvoke(CWorld, "destroyBlock", cX, cY, cZ)
				end
			end
		end
	end)
	
	--[[
	local healthBillboard = itemsXRayBillboard:Clone()
	healthBillboard:FindFirstChild("ItemsContainer"):Destroy()
	healthBillboard.Name = "HealthBillboard"
	healthBillboard.Size = UDim2.fromScale(10, 3)
	healthBillboard.StudsOffsetWorldSpace = Vector3.new(0, 0, 0)
	do
		
	end]]
	
	--[[local autoTrashOn = false
	local autoTrash
	autoTrash = category:AddButton("Auto-Trash", function()
		autoTrashOn = not autoTrashOn
		if autoTrashOn then
			autoTrash:SetText("Stop Auto-Trash")
			local inventory, sSlot, prevSlot, slotNum, data, info
			if plr.Character then
				inventory = plr.Character:FindFirstChild("Inventory")
				if inventory then
					sSlot = plr.Character:FindFirstChild("SelectedSlot")
					if sSlot then
						prevSlot = sSlot.Value
						for _,slot in pairs(inventory:GetChildren()) do
							if not autoTrashOn or not module.On then break end
							if slot:IsA("StringValue") then
								slotNum = tonumber(slot.Name:sub(5))
								data = HttpService:JSONDecode(slot.Value)
								if data and data.name and not applyFilter(data.name:lower()) then
									Remotes.ChangeSlot:InvokeServer(slotNum)
									Remotes.DropItem:InvokeServer(true)
								end
							end
						end
						Remotes.ChangeSlot:InvokeServer(prevSlot)
					end
				end
			end
			autoTrashOn = false
			autoTrash:SetText("Auto-Trash")
		end
	end)]]
end

return module