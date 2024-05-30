local module = {}

function module.PreInit()
	_G.MX_SETTINGS.ESP.Mode = 1
end

function module.Init()
	local plr = game.Players.LocalPlayer
	
	--_G.MX_ESPSystem.Teams["Allies"].Hidden = true -- let in-game ESP work
	
	--_G.MX_ESPSystem.Update()
end

return module