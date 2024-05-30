local module = {}

local CameraScript
function module.Init()
	local Workspace = _G.SafeGetService("Workspace")
	local cam = Workspace.CurrentCamera
	local ReplicatedStorage = _G.SafeGetService("ReplicatedStorage")
	local Players = _G.SafeGetService("Players")
	local plr = Players.LocalPlayer
	local PlayerScripts = plr:WaitForChild("PlayerScripts")
	
	do -- gun mods
		_G.LoadLocalCode([[local ReplicatedStorage = game:GetService("ReplicatedStorage")

local HUD = require(ReplicatedStorage:WaitForChild("Libraries"):WaitForChild("HUD"))
HUD.GetAccuracy = function() return 1 end

local custom = {
	["Homing Launcher"] = function(data)
		data.lockRadius = 10000
	end
}

local data
for _,config in pairs(ReplicatedStorage:WaitForChild("Weapons"):WaitForChild("Guns"):GetDescendants()) do
	if config:IsA("ModuleScript") and config.Name == "Configuration" then
		data = require(config)
		if data.bloom then
			data.bloom.ads = 0
			data.bloom.hipfire = 0
		end
		data.bloomFactor = 0
		data.automatic = true
		data.maxAmmo = 1000
		--if data.projectileVelocity then
			--data.projectileVelocity = math.max(data.projectileVelocity, 500)
		--end
		--data.MaxAmmo = 500
		--data.firerate = 10
		data.noYawRecoil = "true"
		data.recoilCoefficient = 1
		if custom[config.Parent.Name] then
			custom[config.Parent.Name](data)
		end
	end
end]], "GunMods")
	end
	
	_G.MX_ESPSystem.Teams["Allies"].Rule = function(target)
		local player = Players:GetPlayerFromCharacter(target)
		return player and player:GetAttribute("Team") == plr:GetAttribute("Team")
	end
	
	_G.MX_ESPSystem.Teams["Enemies"].Rule = function(target)
		local player = Players:GetPlayerFromCharacter(target)
		return player and player:GetAttribute("Team") ~= plr:GetAttribute("Team")
	end
	
	_G.MX_AimbotSystem.CanUse = function()
		return false
	end
	
	--[[
	_G.MX_AimbotSystem.CanUse = function()
		return plr.Character
	end
	
	_G.MX_AimbotSystem.GetFilterDescendantsInstances = function()
		return {
			Workspace.CurrentCamera,
			plr.Character,
			Workspace:FindFirstChild("Vehicles"),
			Workspace:FindFirstChild("Ignore")
		}
	end
	
	_G.MX_AimbotSystem.TargetChangeCallback = function(prevTarget)
		if prevTarget.Name == "Head" then
			prevTarget.Neck.Enabled = true
			prevTarget.Transparency = 0
		elseif _G.MX_AimbotSystem.CurrentTarget.Name == "HumanoidRootPart" then
			prevTarget.Size = Vector3.new(2, 2, 1)
			prevTarget.Transparency = 1
		end
	end]]
	
	local hitboxesSize = category:AddSlider("Hitboxes Size", 20, 2, 50)
	local hitboxesToggle = category:AddCheckbox("Hitboxes")
	hitboxesToggle:SetChecked(true)
	
	local hitboxSizeDefault = Vector3.new(2, 2, 1)
	
	local vehicleWhitelist = {
		["Biplane"] = true,
		["Dirtbike"] = true,
		["Light Bike"] = true,
		["Go-Kopter"] = true,
		["Airboat"] = true,
		["Dune Buggy"] = true
	}
	
	task.spawn(function()
		while task.wait(1) and module.On do
			_G.MX_ESPSystem.Update()
			local root, vehicle, enabled
			for _,player in pairs(Players:GetPlayers()) do
				if player ~= plr and player.Character then
					root = player.Character.PrimaryPart
					vehicle = player.Character:FindFirstChild("Vehicle")
					if vehicle and root then
						enabled = (not vehicle.Value or vehicleWhitelist[vehicle.Value.Name]) and player:GetAttribute("Team") ~= plr:GetAttribute("Team") and hitboxesToggle.Checked
						root.Size = enabled and Vector3.new(hitboxesSize.Value, hitboxesSize.Value, hitboxesSize.Value) or hitboxSizeDefault
						root.Transparency = enabled and 0.99 or 0
						root.CanCollide = false
					end
				end
			end
		end
	end)
end

return module