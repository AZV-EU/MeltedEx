local module = {}

--[[function module.PreInit()
	_G.MX_SETTINGS.ESP.Mode = 1
end]]

function module.Init(category, connections)
	local plr = game.Players.LocalPlayer
	local ReplicatedStorage = _G.SafeGetService("ReplicatedStorage")
	local RE = ReplicatedStorage:WaitForChild("RemoteEvent")
	
--[[ FOR LATER USE ;)
local args = {
    [1] = "FireAllClients",
    [2] = "WeldItemToHand",
    [3] = getNil("GripAttachment", "Attachment"),
    [4] = game:GetService("Players").LocalPlayer.Character.RightHand.RightGripAttachment
}]]

	local portal = game.Workspace:FindFirstChild("Main Portal Template")
	if portal then
		portal:Destroy()
	end
	
	category:BeginInline()
	local customSize = category:AddSlider("Custom Size Control", 1, 0.1, 1000)
	category:AddButton("Set Size", function()
		RE:FireServer("ChangeSize", customSize.Value)
	end)
	category:EndInline()
end

return module