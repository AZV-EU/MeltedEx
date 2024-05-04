_G.MX_VERSION = "0.6.1g"
_G.MX_ENV = "PROD"

local REPOSITORY = {
	[286090429] = "Arsenal.lua",
	[893973440] = "FleeTheFacility.lua",
	[142823291] = "MurderMystery2.lua",
	[9872472334] = "Evade.lua",
	
	[7584496019] = "SquidGamesObby.lua",
	[7952502098] = "SquidGamesObby2.lua",
	[13987158269] = "SquidGamesObby3.lua",
	[13389049867] = "SquidGamesObby4.lua",
	
	[8200787440] = "EatBlobsSimulator.lua",
	
	[2474168535] = "Westbound.lua",
	
	[1340132428] = "ArmoredPatrol.lua",
	[10518166490] = "ArmoredPatrol.lua",
	
	[746820961] = "Unit1968.lua",
	[15514727567] = "GunfightArena.lua",
	[301549746] = "CounterBlox.lua",
	
	[16392065676] = "Minecraft.lua", -- Craft-blox
}
-- _G.SetClipboard(game.PlaceId)

local function log(...)
	print("[MX::Log]", ...)
end
local function logwarn(...)
	print("[MX::Warn]", ...)
end
local function logerror(...)
	print("[MX::Error]", ...)
end

if _G.MX_Cleanup then
	local f, err = pcall(_G.MX_Cleanup)
	if not f then
		logwarn("Cleanup failed:", err)
	end
end

local MX_RUNNING = true

local BaseURLs = {
	DEV = "http://azv.ddns.net/MeltedEx/",
	PROD = "https://raw.githubusercontent.com/AZV-EU/MeltedEx/main/"
}

_G.MX_BaseURL = BaseURLs[_G.MX_ENV]

_G.GAMEINFO = _G.SafeGetService("MarketplaceService"):GetProductInfo(game.PlaceId)

local GameModule
if REPOSITORY[game.PlaceId] then
	log("Loading Game Module '" .. REPOSITORY[game.PlaceId] .. "'")
	GameModule = _G.LoadRemoteModule(_G.MX_BaseURL .. "Games/" .. REPOSITORY[game.PlaceId], REPOSITORY[game.PlaceId])
end

_G.MX_SETTINGS = {
	SETUP = {
		SetCameraMaxZoomDistance = true
	},
	ESP = {
		Mode = 0, -- 0: parenting to folders, 1: 31 highlights for targets
		Enabled = true,
		Checked = true,
		HighlightsEnabled = true,
		HijackHighlights = true
	},
	WALKSPEED = {
		Enabled = true,
		Min = 0,
		Max = 1000
	},
	JUMP = {
		Enabled = true,
		Min = 0,
		Max = 300
	},
	FLY = {
		Enabled = true,
		Checked = true,
		FlingEnabled = true,
		NormalMin = 0,
		NormalDefault = 60,
		NormalMax = 1000,
		BoostMin = 0,
		BoostDefault = 300,
		BoostMax = 10000
	},
	AIMBOT = {
		Enabled = true,
		Checked = false,
		PingCompensation = true
	}
}

local GameModuleConnections = {}
if GameModule and GameModule.PreInit then
	local f, err = pcall(GameModule.PreInit, GameModuleConnections)
	if not f then
		logwarn("Game Module Pre-Init failed:", err)
	end
end

local MXConnections = {}
if not game:IsLoaded() then
	log("Waiting for Game Loaded...")
	game.Loaded:Wait()
end

local Players = _G.SafeGetService("Players")
local Workspace = _G.SafeGetService("Workspace")
local UserInputService = _G.SafeGetService("UserInputService")
local ContextActionService = _G.SafeGetService("ContextActionService")

log("Waiting for Local Player...")
local plr
repeat
	task.wait()
	plr = Players.LocalPlayer
until plr and plr:FindFirstChild("PlayerScripts")

log("Loading ESP System")
_G.MX_ESPSystem = _G.LoadRemoteModule(_G.MX_BaseURL .. "Systems/ESPSystem.lua", "ESPSystem")
log("Loading Flight System")
_G.MX_FlightSystem = _G.LoadRemoteModule(_G.MX_BaseURL .. "Systems/FlightSystem.lua", "FlightSystem")
log("Loading Aimbot System")
_G.MX_AimbotSystem = _G.LoadRemoteModule(_G.MX_BaseURL .. "Systems/AimbotSystem.lua", "AimbotSystem")
log("Loading UI Handler")
_G.MX_UIHandler = _G.LoadRemoteModule(_G.MX_BaseURL .. "Systems/UIHandler.lua", "UIHandler")

log("Initializing UI")
do
	local f, err = pcall(_G.MX_UIHandler.Init)
	if not f then
		print("Failed to initialize UI:", err)
		if _G.MX_UIHandler.GUI then
			_G.MX_UIHandler.GUI:Destroy()
		end
		return {}
	end
end

do -- initial setup
	if _G.MX_SETTINGS.SETUP.SetCameraMaxZoomDistance then
		plr.CameraMaxZoomDistance = 1000
	end
	local VUService = _G.SafeGetService("VirtualUser")
	table.insert(MXConnections, plr.Idled:Connect(function()
		VUService:ClickButton1(Vector2.zero, Workspace.CurrentCamera.CFrame)
	end))
end

do -- Main category
	local category = _G.MX_UIHandler:AddCategory("Main")
	
	do category:BeginInline()
		local espToggle = category:AddCheckbox("ESP", _G.MX_ESPSystem.SetEnabled)
		espToggle:SetEnabled(_G.MX_SETTINGS.ESP.Enabled)
		if espToggle.Enabled then
			espToggle:SetChecked(_G.MX_SETTINGS.ESP.Checked)
		end
		
		local aimbotToggle = category:AddCheckbox("Aimbot", _G.MX_AimbotSystem.SetEnabled)
		aimbotToggle:SetEnabled(_G.MX_SETTINGS.AIMBOT.Enabled)
		if aimbotToggle.Enabled then
			aimbotToggle:SetChecked(_G.MX_SETTINGS.AIMBOT.Checked)
		end
		
		local flyToggle = category:AddCheckbox("Fly", _G.MX_FlightSystem.SetEnabled)
		flyToggle:SetEnabled(_G.MX_SETTINGS.FLY.Enabled)
		if flyToggle.Enabled then
			flyToggle:SetChecked(_G.MX_SETTINGS.FLY.Checked)
		end
		
		table.insert(MXConnections, UserInputService.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Keyboard then
				if aimbotToggle.Enabled and input.KeyCode == Enum.KeyCode.F7 then
					aimbotToggle:SetChecked(not aimbotToggle.Checked)
				elseif _G.MX_SETTINGS.FLY.FlingEnabled and input.KeyCode == Enum.KeyCode.F4 then
					_G.MX_FlightSystem.SetFling(not _G.MX_FlightSystem.Fling)
				end
			end
		end))
	end category:EndInline()
	
	--[[
	do category:BeginInline()
	
	end category:EndInline()
	]]
	
	do category:BeginInline()
		category:AddSlider("Fly Speed", _G.MX_SETTINGS.FLY.NormalDefault, _G.MX_SETTINGS.FLY.NormalMin, _G.MX_SETTINGS.FLY.NormalMax, function(newValue)
			_G.MX_FlightSystem.NormalSpeed = newValue
		end)
		_G.MX_FlightSystem.NormalSpeed = _G.MX_SETTINGS.FLY.NormalDefault
		
		category:AddSlider("Fly Boost Speed", _G.MX_SETTINGS.FLY.BoostDefault, _G.MX_SETTINGS.FLY.BoostMin, _G.MX_SETTINGS.FLY.BoostMax, function(newValue)
			_G.MX_FlightSystem.BoostSpeed = newValue
		end)
		_G.MX_FlightSystem.BoostSpeed = _G.MX_SETTINGS.FLY.BoostDefault
	end category:EndInline()

	local freezeValues
	do category:BeginInline()
		local walkSpeedSlider = category:AddSlider("Walk Speed", 16, _G.MX_SETTINGS.WALKSPEED.Min, _G.MX_SETTINGS.WALKSPEED.Max, function(newValue)
			if plr and plr.Character then
				local human = plr.Character:FindFirstChildWhichIsA("Humanoid")
				if human then
					human.WalkSpeed = newValue
				end
			end
		end)
		
		local jumpSlider = category:AddSlider("Jump Height", 0, _G.MX_SETTINGS.JUMP.Min, _G.MX_SETTINGS.JUMP.Max, function(newValue)
			if plr and plr.Character then
				local human = plr.Character:FindFirstChildWhichIsA("Humanoid")
				if human then
					if human.UseJumpPower then
						human.JumpPower = newValue
					else
						human.JumpHeight = newValue
					end
				end
			end
		end)
		
		local function SetupCharMods(chr)
			local human
			repeat
				task.wait()
				human = chr:FindFirstChildWhichIsA("Humanoid")
			until human or not MX_RUNNING
			
			jumpSlider:SetText(human.UseJumpPower and "Jump Power" or "Jump Height")
			
			if freezeValues.Checked then
				human.WalkSpeed = walkSpeedSlider.Value
				if human.UseJumpPower then
					human.JumpPower = jumpSlider.Value
				else
					human.JumpHeight = jumpSlider.Values
				end
			else
				walkSpeedSlider:SetValue(human.WalkSpeed)
				jumpSlider:SetValue(human.UseJumpPower and human.JumpPower or human.JumpHeight)
			end
			
			table.insert(MXConnections, human:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
				if freezeValues.Checked then
					human.Walkspeed = walkSpeedSlider.Value
				else
					walkSpeedSlider:SetValue(human.WalkSpeed)
				end
			end))
			
			table.insert(MXConnections, human:GetPropertyChangedSignal("UseJumpPower"):Connect(function()
				if freezeValues.Checked then
					if human.UseJumpPower then
						human.JumpPower = jumpSlider.Value
					else
						human.JumpHeight = jumpSlider.Value
					end
				else
					jumpSlider:SetValue(human.UseJumpPower and human.JumpPower or human.JumpHeight)
				end
				jumpSlider:SetText(human.UseJumpPower and "Jump Power" or "Jump Height")
			end))
		end
		if plr and plr.Character then
			task.spawn(SetupCharMods, plr.Character)
		end
		table.insert(MXConnections, plr.CharacterAdded:Connect(SetupCharMods))
	end category:EndInline()
	
	do category:BeginInline()
		freezeValues = category:AddCheckbox("Freeze Values")
		category:AddButton("Trip", function()
			if plr and plr.Character then
				local human = plr.Character:FindFirstChildWhichIsA("Humanoid")
				if human then
					human:ChangeState(human:GetState() ~= Enum.HumanoidStateType.Physics and Enum.HumanoidStateType.Physics or Enum.HumanoidStateType.GettingUp)
				end
			end
		end)
	end category:EndInline()
	
	_G.MX_UIHandler:SelectCategory(category.Name)
end

if GameModule and GameModule.Init then
	task.spawn(function()
		local category = _G.MX_UIHandler:AddCategory(GameModule.CustomCategoryName or _G.GAMEINFO.Name)
		GameModule.On = true
		local f, err = pcall(GameModule.Init, category, GameModuleConnections)
		if not f then
			logwarn("Game Module Init failed:", err)
		end
	end)
end

_G.MX_Cleanup = function()
	MX_RUNNING = false
	_G.MX_UIHandler.Cleanup()
	_G.MX_ESPSystem.SetEnabled(false)
	_G.MX_FlightSystem.SetEnabled(false)
	_G.MX_AimbotSystem.SetEnabled(false)
	
	for _,conn in pairs(MXConnections) do
		if conn then
			pcall(conn.Disconnect, conn)
		end
	end
	
	for _,conn in pairs(GameModuleConnections) do
		if conn then
			pcall(conn.Disconnect, conn)
		end
	end
	
	if GameModule then
		GameModule.On = false
		if GameModule.Shutdown then
			xpcall(GameModule.Shutdown, function(err) logwarn("GameModule.Shutdown:", err) end)
		end
	end
	
	pcall(ContextActionService.UnbindAction, ContextActionService, "MXAIM_TOGGLE")
	
	_G.MX_Cleanup = nil
end

if script:IsA("ModuleScript") then return {} end