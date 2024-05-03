local module = {}

function module.PreInit()
	_G.MX_SETTINGS.ESP.Mode = 1
end

function module.Init(category, connections)
	local plr = game.Players.LocalPlayer
	
	do
		local castParts
		_G.MX_AimbotSystem.GetCastParts = function(target)
			castParts = {}
			if target:FindFirstChild("Head") then
				table.insert(castParts, target.Head)
			end
			if target:FindFirstChild("HumanoidRootPart") then
				table.insert(castParts, target.HumanoidRootPart)
			end
			if target:FindFirstChild("RightHand") then
				table.insert(castParts, target.RightHand)
			end
			if target:FindFirstChild("LeftHand") then
				table.insert(castParts, target.LeftHand)
			end
			if target:FindFirstChild("RightFoot") then
				table.insert(castParts, target.RightFoot)
			end
			if target:FindFirstChild("LeftFoot") then
				table.insert(castParts, target.LeftFoot)
			end
			return castParts
		end
	end
	
	_G.MX_AimbotSystem.CanUse = function()
		return plr.Character
	end
end

return module