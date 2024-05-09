local module = {
	Enabled = false,
	CurrentTarget = nil,
	LineOfSight = {
		MaxDistance = 1000
	},
	Mode = 1, -- [1: FOV-Limited] [2: Unlimited]
	FOV = 150
}

local Players = _G.SafeGetService("Players")
local Workspace = _G.SafeGetService("Workspace")
local RunService = _G.SafeGetService("RunService")
local UserInputService = _G.SafeGetService("UserInputService")
local Stats = _G.SafeGetService("Stats")
local Network = Stats:WaitForChild("Network")
local ServerStatsItem = Network:WaitForChild("ServerStatsItem")
local DataPing = ServerStatsItem:WaitForChild("Data Ping")

local plr = Players.LocalPlayer
local mouse = plr:GetMouse()

module.DefaultRaycastParams = RaycastParams.new()
module.DefaultRaycastParams.FilterType = Enum.RaycastFilterType.Exclude
module.DefaultRaycastParams.IgnoreWater = true
function module.GetFilterDescendantsInstances()
	return {Workspace.CurrentCamera, plr.Character}
end

function module.Raycast(from, to)
	module.DefaultRaycastParams.FilterDescendantsInstances = module.GetFilterDescendantsInstances()
	return Workspace:Raycast(from, to, module.DefaultRaycastParams)
end

function module.CanUse()
	return plr.Character and plr.Character:FindFirstChildWhichIsA("Tool")
end

do
	local ping
	function module.AimFunction()
		if module.CurrentTarget then
			if _G.MX_SETTINGS.AIMBOT.PingCompensation then
				ping = DataPing:GetValue() * 0.001
				Workspace.CurrentCamera.CFrame = CFrame.new(Workspace.CurrentCamera.CFrame.Position, module.CurrentTarget.CFrame.Position + (module.CurrentTarget.AssemblyLinearVelocity * ping))
			else
				Workspace.CurrentCamera.CFrame = CFrame.new(Workspace.CurrentCamera.CFrame.Position, module.CurrentTarget.CFrame.Position)
			end
		end
	end
end

function module.AimCondition()
	return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
end

do
	local targets
	function module.GetValidTargets()
		targets = {}
		for _,v in pairs(Players:GetPlayers()) do
			if v ~= plr and v.Character and v.Character.Parent and
				not v.Character:FindFirstChildWhichIsA("ForceField") and
				not plr:IsFriendsWith(v.UserId) and
				_G.MX_ESPSystem.Teams["Enemies"].Rule(v.Character) then
				table.insert(targets, v.Character)
			end
		end
		return targets
	end
end

do
	local castParts
	function module.GetCastParts(target)
		castParts = {}
		if target:FindFirstChild("Head") then
			table.insert(castParts, target.Head)
		end
		if target:FindFirstChild("HumanoidRootPart") then
			table.insert(castParts, target.HumanoidRootPart)
		end
		return castParts
	end
end

local GetTargets -- get valid targets by distance
do
	local targets, mousePos, human, head, castPoints, pos, inBounds, dist
	GetTargets = function()
		targets = {}
		mousePos = Vector2.new(mouse.X, mouse.Y)
		for _,target in pairs(module.GetValidTargets()) do
			human = target:FindFirstChildWhichIsA("Humanoid")
			if human and human.Health > 0 and human.RootPart then
				pos, inBounds = Workspace.CurrentCamera:WorldToScreenPoint(human.RootPart.Position)
				if inBounds then
					dist = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
					if module.Mode == 2 or (module.Mode == 1 and dist < module.FOV) then
						table.insert(targets, {target, dist})
					end
				end
			end
		end
		table.sort(targets, function(a,b)
			return a[2] < b[2]
		end)
		return targets
	end
end

do
	local root
	function module.AimSource()
		if plr and plr.Character and  then
			local root = plr.Character:FindFirstChild("HumanoidRootPart")
			if root then
				return root.Position
			end
		end
	end
end

do
	local result, losDir, source
	function module.CheckLineOfSight(target)
		source = module.AimSource()
		if not target or not source then return end
		for _,part in pairs(module.GetCastParts(target)) do
			losDir = (part.Position - source)
			if losDir.Magnitude < module.LineOfSight.MaxDistance then
				result = module.Raycast(source, losDir.Unit * module.LineOfSight.MaxDistance)
				if not result or result.Instance == nil or result.Instance:IsDescendantOf(target) then
					return result, part
				end
			end
		end
	end
end

local FOVCircle, TargetLine
function module.SetEnabled(enabled)
	if not module.Enabled and enabled then
		module.Enabled = true
		FOVCircle = _G.Drawing:NewCircle()
		FOVCircle.Transparency = 0.7
		
		TargetLine = _G.Drawing:NewLine()
		TargetLine.Transparency = 0.5
		TargetLine.Color = _G.COLORS.GREEN
		
		local cam, los, fovPos, pos, aimPos
		RunService:BindToRenderStep("MXAIM", Enum.RenderPriority.Camera.Value - 10, function()
			cam = Workspace.CurrentCamera
			if module.CanUse() and cam and cam.CameraSubject then
				fovPos = Vector2.new(mouse.X, mouse.Y)
				
				FOVCircle.Position = fovPos
				TargetLine.From = fovPos
				FOVCircle.Radius = module.FOV
				FOVCircle.Visible = true
				
				for _,target in pairs(GetTargets()) do
					los, module.CurrentTarget = module.CheckLineOfSight(target[1])
					if los then
						aimPos = cam:WorldToScreenPoint(module.CurrentTarget.Position)
						TargetLine.To = Vector2.new(aimPos.X, aimPos.Y)
						TargetLine.Visible = true
						FOVCircle.Color = _G.COLORS.GREEN
						if module.AimFunction and (not module.AimCondition or module.AimCondition()) then
							module.AimFunction()
						end
						return
					end
				end
			else
				FOVCircle.Visible = false
			end
			TargetLine.Visible = false
			FOVCircle.Color = _G.COLORS.WHITE
			module.CurrentTarget = nil
		end)
	elseif module.Enabled and not enabled then
		module.Enabled = false
		RunService:UnbindFromRenderStep("MXAIM")
		task.wait()
		FOVCircle:Destroy()
		TargetLine:Destroy()
		module.CurrentTarget = nil
	end
end

return module