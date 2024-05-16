local module = {}

function module.PreInit()
	_G.MX_SETTINGS.ESP.Mode = 1
	_G.MX_SETTINGS.AIMBOT.PingCompensation = false
end

function module.Init(category, connections)
	local plr = game.Players.LocalPlayer
	local myTeam = plr:WaitForChild("TeamC")
	
	local ReplicatedStorage = _G.SafeGetService("ReplicatedStorage")
	local WeaponsData = ReplicatedStorage:WaitForChild("Weapons")
	for _,weapon in pairs(WeaponsData:GetChildren()) do
		if weapon:FindFirstChild("Spread") then
			weapon.Spread.Value = 0
		end
		if weapon:FindFirstChild("Recoil") then
			weapon.Recoil.Value = 0
		end
		if weapon:FindFirstChild("LRecoil") then
			weapon.LRecoil.Value = 0
		end
		if weapon:FindFirstChild("Automatic") then
			weapon.Automatic.Value = true
		end
		if weapon:FindFirstChild("Restrictions") and weapon.Restrictions:FindFirstChild("Level") then
			weapon.Restrictions.Level.Value = 0
		end
	end
	
	_G.MX_AimbotSystem.CanUse = function()
		return plr.Character
	end
	
	_G.MX_AimbotSystem.GetFilterDescendantsInstances = function()
		if game.Workspace:FindFirstChild("Map") and game.Workspace.Map:FindFirstChild("Ignore") then
			return {
				game.Workspace.CurrentCamera,
				plr.Character,
				game.Workspace.Ray_Ignore,
				game.Workspace.Debris,
				game.Workspace.Map.Ignore
			}
		else
			return {
				game.Workspace.CurrentCamera,
				plr.Character,
				game.Workspace.Ray_Ignore,
				game.Workspace.Debris
			}
		end
	end
	
	_G.MX_ESPSystem.Teams["Enemies"].Rule = function(target)
		local player = game.Players:GetPlayerFromCharacter(target)
		if player then
			local pTeam = player:FindFirstChild("TeamC")
			return pTeam and pTeam.Value ~= myTeam.Value
		end
	end
	
	_G.MX_ESPSystem.Teams["Allies"].Rule = function(target)
		local player = game.Players:GetPlayerFromCharacter(target)
		if player then
			local pTeam = player:FindFirstChild("TeamC")
			return pTeam and pTeam.Value == myTeam.Value
		end
	end
end

return module