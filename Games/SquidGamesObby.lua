local module = {}

--function module.PreInit() end

function module.Init(category, connections)
	local plr = game.Players.LocalPlayer
	
	local gameMap = game.Workspace:WaitForChild("Map"):WaitForChild("Game")
	local tiles = gameMap:WaitForChild("Tiles")
	
	tiles:WaitForChild("Right"):WaitForChild("Tile40")
	
	local colDefault, colReal, colFake =
		Color3.new(0.77, 0.92, 1),
		_G.COLORS.GREEN,
		_G.COLORS.RED
	
	local lastReset = tick()
	local lastKnownGood
	
	for _,tile in pairs(tiles:GetDescendants()) do
		if tile:IsA("BasePart") and tile.Name:sub(1,4) == "Tile" then
			tile.Color = colDefault
			local opposite
			if tile.Parent.Name == "Right" then
				opposite = tiles.Left[tile.Name]
			else
				opposite = tiles.Right[tile.Name]
			end
			opposite.Color = colDefault
			table.insert(connections, tile:GetPropertyChangedSignal("Transparency"):Connect(function()
				if tile.Transparency == 1 then
					task.wait(.33)
					if opposite.Transparency == 1 then -- reset
						tile.Color = colDefault
						opposite.Color = colDefault
						lastReset = tick()
						lastKnownGood = nil
					else
						tile.Color = colFake
						opposite.Color = colReal
					end
				end
			end))
		end
	end
	
	local scanning, scanBtn = false, nil
	scanBtn = category:AddButton("Scan", function()
		if scanning then
			scanning = false
			scanBtn:SetText("Scan")
		else
			scanBtn:SetText("Scanning...")
			lastKnownGood = nil
		end
	end)
end

return module