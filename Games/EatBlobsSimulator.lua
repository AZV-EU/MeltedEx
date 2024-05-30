local module = {}

--function module.PreInit() end

function module.Init()
	local plr = game.Players.LocalPlayer
	
	local orbsFolder = game.Workspace:WaitForChild("Orbs")
	
	local function SetupCharacter(chr)
		local human = chr:WaitForChild("Humanoid")
		human.WalkSpeed = 80
		table.insert(connections, human:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
			task.wait()
			human.WalkSpeed = 80
		end))
	end
	if plr.Character then
		SetupCharacter(plr.Character)
	end
	table.insert(connections, plr.CharacterAdded:Connect(SetupCharacter))
	
	--[[
	local autoCollect
	autoCollect = category:AddCheckbox("Auto-collect", function(state)
		if state then
			local children
			while task.wait(.05) and autoCollect.Checked and module.On do
				if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
					children = orbsFolder:GetChildren()
					if #children > 1 then
						children[math.random(1, #children)].CFrame = plr.Character.HumanoidRootPart.CFrame
					end
				else
					print(plr.Character)
				end
			end
		end
	end)]]
end

return module