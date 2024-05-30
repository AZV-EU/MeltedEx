local module = {}

function module.PreInit()
	_G.MX_SETTINGS.ESP.Mode = 1
end

function module.Init()
	local PlayerScripts = plr:WaitForChild("PlayerScripts")
	
	local PlayerGui = plr:WaitForChild("PlayerGui")
	
	local function UpdateUI()
		local ScrollingFrame = PlayerGui:WaitForChild("General"):WaitForChild("Vehicles"):WaitForChild("Content"):WaitForChild("ScrollingFrame")
		ScrollingFrame.CanvasSize = UDim2.new(20, 0, 0, 0)
		
		local adminGui = ReplicatedStorage:WaitForChild("AdminPanel"):Clone()
		adminGui.Parent = PlayerGui
		adminGui.Enabled = true
		adminGui:FindFirstChildWhichIsA("LocalScript").Enabled = true
	end
	UpdateUI()
	table.insert(connections, plr.CharacterAdded:Connect(UpdateUI))

	local UpdateCash = ReplicatedStorage:WaitForChild("UpdateCash")
	local RebirthEvent = ReplicatedStorage:WaitForChild("RebirthEvent")
	
	local Vehicles = ReplicatedStorage:WaitForChild("Vehicles")
	local VehicleFunction = Vehicles:WaitForChild("VehicleFunction")
	
	local RewardFunction = ReplicatedStorage:WaitForChild("RewardFunction")
	
	local Chests = ReplicatedStorage:WaitForChild("Chests")
	local ChestFunction = Chests:WaitForChild("ChestFunction")
	local AdminEvent = ReplicatedStorage:WaitForChild("AdminEvent")
	
	local function GetMyBase()
		if not plr.Team then return end
		local base = Workspace:FindFirstChild(plr.Team.TeamColor.Name)
		if base and base:FindFirstChild("Contents") then
			return base.Contents:FindFirstChild(plr.Team.TeamColor.Name)
		end
	end
	
	--[[UpdateCash:
		{
			[1] = "set", "change"
			[2] = 1234
		}
	]]
		
	--[[ RewardEvent:
		{
			Value = 1234,
			Type = "AddCash"
		}
	]]

	do category:BeginInline()
		category:AddButton("Max Cash", function()
			UpdateCash:FireServer("set", 1000000000)
		end)
		
		category:AddButton("Clear Cash", function()
			UpdateCash:FireServer("set", 0)
		end)
		
		category:AddButton("Rebirth", function()
			RebirthEvent:FireServer({Type = "InitiateRebirth"})
		end)
		
		category:AddButton("Invincible", function()
			AdminEvent:FireServer({Type = "Health", Value = math.huge})
		end)
	end category:EndInline()
	
	local function hasVehicle(myVehicles, targetName)
		for _,category in pairs(myVehicles) do
			for _,vehicleName in pairs(category) do
				if vehicleName == targetName then
					return true
				end
			end
		end
		return false
	end
	
	local buyAllVehicles
	buyAllVehicles = category:AddButton("Buy All Vehicles", function()
		buyAllVehicles:SetEnabled(false)
		local myVehicles = VehicleFunction:InvokeServer("GetPlayerVehicles", {plr})
		local vehicles = {}
		
		local settings
		for _,vehicle in pairs(Vehicles:WaitForChild("Objects"):GetChildren()) do
			if not hasVehicle(myVehicles, vehicle.Name) then
				settings = vehicle:FindFirstChild("Settings")
				if settings then
					table.insert(vehicles, {vehicle, settings})
				end
			end
		end
		
		local count = #vehicles
		if count > 0 then
			buyAllVehicles:SetText("Buying...")
			for i = 1, count do
				buyAllVehicles:SetText(string.format("Buying vehicle %d out of %d...", i, count))
				VehicleFunction:InvokeServer("RequestPurchase",
					{
						plr,
						vehicles[i][1],
						_G.LocalModuleGet(vehicles[i][2])
					}
				)
			end
			buyAllVehicles:SetText("Buy All Vehicles")
		end
		buyAllVehicles:SetEnabled(true)
	end)
	
	do category:BeginInline()
		category:AddButton("Get EM-Chest", function()
			RewardFunction:InvokeServer({"Daily", "ClaimReward"}, {plr, "Chest", "Epic Mecha"})
		end)
		
		category:AddButton("Open EM-Chest", function()
			ChestFunction:InvokeServer("OpenChest", {plr, "Epic Mecha"})
		end)
	end category:EndInline()
	
	local buyingButtons = false
	local buyAllButtons
	buyAllButtons = category:AddButton("Buy All Buttons", function()
		if not buyingButtons then
			buyingButtons = true
			local base = GetMyBase()
			if base then
				local buttons = base:FindFirstChild("Buttons")
				if buttons then
					local toBuy = {}
					local budget = plr.leaderstats.Cash.Value
					for _,button in pairs(buttons:GetChildren()) do
						if button:FindFirstChild("Head") and button.Head.Transparency == 0 and button:FindFirstChild("Price") and budget - button.Price.Value >= 0 then
							budget -= button.Price.Value
							table.insert(toBuy, button.Head)
						end
					end
					
					local count = #toBuy
					if count > 0 then
						for i = 1, count do
							if not buyingButtons or not module.On then break end
							buyAllButtons:SetText(string.format("Buying button %d out of %d", i, count))
							_G.TouchObject(plr.Character.PrimaryPart, toBuy[i])
						end
						buyAllButtons:SetText("Buy All Buttons")
					end
				end
			end
		end
		buyingButtons = false
	end)
end

return module