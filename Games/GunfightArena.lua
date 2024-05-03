local module = {}

function module.PreInit()
	_G.MX_SETTINGS.ESP.Mode = 1
end

function module.Init(category, connections)
	local plr = game.Players.LocalPlayer
	
	
	
	_G.MX_AimbotSystem.CanUse = function()
		return plr.Character
	end
	
	_G.MX_ESPSystem.GetValidTargets = function()
		local targets = {}
		local character = nil
		for k,v in pairs(game.Players:GetChildren()) do
			if v:IsA("Player") then
				if v ~= plr and v.Character then
					table.insert(targets, v.Character)
				end
			elseif v:IsA("Folder") then
				character = game.Workspace:FindFirstChild(v.Name, true)
				if character and character:IsA("Model") then
					table.insert(targets, character)
				end
			end
		end
		return targets
	end
	
	_G.MX_ESPSystem.Teams["Enemies"].Rule = function(target)
		return game.Players:FindFirstChild(target.Name) and game.Players[target.Name]:GetAttribute("Team") ~= plr:GetAttribute("Team")
	end
	
	_G.MX_ESPSystem.Teams["Allies"].Rule = function(target)
		return game.Players:FindFirstChild(target.Name) and game.Players[target.Name]:GetAttribute("Team") == plr:GetAttribute("Team")
	end
	_G.MX_ESPSystem.Update()
end

return module