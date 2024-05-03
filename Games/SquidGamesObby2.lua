local module = {}

--function module.PreInit() end

function module.Init(category, connections)
	local plr = game.Players.LocalPlayer
	
	local bridge = game.Workspace:WaitForChild("Glass Bridge")
	local tiles = bridge:WaitForChild("GlassPane")
	
	game.Lighting.Brightness = 1
	game.Lighting.GlobalShadows = true
	game.Lighting.Ambient = _G.COLORS.BLACK
	
	local colReal, colFake =
		_G.COLORS.DARKGREEN,
		_G.COLORS.DARKRED
	
	local function CheckGlassPanes()
		for _,glass in pairs(tiles:GetChildren()) do
			for _,pane in pairs(glass:GetChildren()) do
				if pane:IsA("BasePart") then
					pane.Color = not pane.CanCollide and colFake or colReal
					pane.Material = Enum.Material.SmoothPlastic
					pane.CanTouch = false
					table.insert(connections, pane:GetPropertyChangedSignal("CanTouch"):Connect(function()
						task.wait()
						pane.CanTouch = false
					end))
					if not pane.CanCollide and not pane:FindFirstChild("FakeHolder") then
						local fake = pane:Clone()
						fake.Parent = pane
						fake.Transparency = 1
						fake.CanCollide = true
					end
				end
			end
		end
	end
	CheckGlassPanes()
	category:AddButton("Check Panes", CheckGlassPanes)
	
	local winPart = bridge:WaitForChild("Finish"):WaitForChild("Money Pig"):FindFirstChildWhichIsA("TouchTransmitter", true).Parent
	category:AddButton("Teleport to Win", function() _G.TeleportPlayerTo(winPart.Position) end)
end

return module