local module = {}

--function module.PreInit() end

function module.Init(category, connections)
	local plr = game.Players.LocalPlayer
	
	local bridge = game.Workspace:WaitForChild("Bridge")
	
	local colReal, colFake =
		_G.COLORS.GREEN,
		_G.COLORS.RED
	
	local function CheckGlassPanes()
		for _,pane in pairs(bridge:GetChildren()) do
			if pane:IsA("BasePart") then
				pane.Color = pane.Name:find("Kill") and colFake or colReal
				pane.CanTouch = false
				table.insert(connections, pane:GetPropertyChangedSignal("CanTouch"):Connect(function()
					task.wait()
					pane.CanTouch = false
				end))
			end
		end
	end
	CheckGlassPanes()
	category:AddButton("Check Panes", CheckGlassPanes)
	
	local winPart = game.Workspace:WaitForChild("EndArea"):WaitForChild("Chest")
	category:AddButton("Teleport to Win", function() _G.TeleportPlayerTo(winPart.Position) end)
end

return module