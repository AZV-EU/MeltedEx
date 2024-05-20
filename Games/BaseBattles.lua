local module = {}

local CameraScript
function module.Init(category, connections)
	local Workspace = _G.SafeGetService("Workspace")
	local cam = Workspace.CurrentCamera
	local ReplicatedStorage = _G.SafeGetService("ReplicatedStorage")
	local Players = _G.SafeGetService("Players")
	local plr = Players.LocalPlayer
	local PlayerScripts = plr:WaitForChild("PlayerScripts")
	
	do -- gun mods
		_G.LoadLocalCode([[local data
for _,config in pairs(game:GetService("ReplicatedStorage"):WaitForChild("Weapons"):WaitForChild("Guns"):GetDescendants()) do
	if config:IsA("ModuleScript") and config.Name == "Configuration" then
		data = require(config)
		if data.bloom then
			data.bloom.ads = 0
			data.bloom.hipfire = 0
		end
		data.bloomFactor = 0
		data.automatic = true
		data.maxAmmo = 500
		data.MaxAmmo = 500
		--data.firerate = 10
		data.noYawRecoil = "true"
		data.recoilCoefficient = 1
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
	
	task.spawn(function()
		while task.wait(1) and module.On do
			_G.MX_ESPSystem.Update()
			local root, vehicle, enabled
			for _,player in pairs(Players:GetPlayers()) do
				if player ~= plr and player.Character then
					root = player.Character.PrimaryPart
					vehicle = player.Character:FindFirstChild("Vehicle")
					if vehicle and not vehicle.Value and root then
						enabled = player:GetAttribute("Team") ~= plr:GetAttribute("Team") and hitboxesToggle.Checked
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