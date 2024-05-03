local module = {}

--function module.PreInit() end

function module.Init(category, connections)
	local plr = game.Players.LocalPlayer
	
	local segmentSystem = game.Workspace:WaitForChild("segmentSystem")
	local segments = segmentSystem:WaitForChild("Segments")
	
	local colReal, colFake =
		_G.COLORS.GREEN,
		_G.COLORS.RED
	
	local function CheckGlassPanes()
		local folder
		for _,segment in pairs(segments:GetChildren()) do
			if segment:IsA("Model") then
				folder = segment:FindFirstChildWhichIsA("Folder")
				if folder then
					for _,pane in pairs(folder:GetChildren()) do
						if pane:IsA("BasePart") then
							pane.Color = pane:FindFirstChild("breakable") and colFake or colReal
							pane.CanTouch = false
							table.insert(connections, pane:GetPropertyChangedSignal("CanTouch"):Connect(function()
								task.wait()
								pane.CanTouch = false
							end))
						end
					end
				end
				if segment:FindFirstChild("Center") then
					segment.Center.CanCollide = true
				end
			end
		end
	end
	CheckGlassPanes()
	category:AddButton("Check Panes", CheckGlassPanes)
	
	local winPart = game.Workspace:WaitForChild("Finish"):WaitForChild("Chest")
	category:AddButton("Teleport to Win", function() _G.TeleportPlayerTo(winPart.Position) end)
end

return module