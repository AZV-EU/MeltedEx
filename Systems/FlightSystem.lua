local module = {
	Enabled = false,
	Fling = false,
	NormalSpeed = 60,
	BoostSpeed = 500
}

local Players = _G.SafeGetService("Players")
local RunService = _G.SafeGetService("RunService")
local UserInputService = _G.SafeGetService("UserInputService")
local ContextActionService = _G.SafeGetService("ContextActionService")

local plr = Players.LocalPlayer

local Flying = false
local function ResetFlight()
	Flying = false
	pcall(function() RunService:UnbindFromRenderStep("MX_FLIGHT") end)
	
	if not plr.Character or not plr.Character.Parent then return end
	local myChar = plr.Character
	local myHuman = myChar:FindFirstChildWhichIsA("Humanoid")
	if not myHuman then return end
	
	if myHuman and myHuman.RootPart ~= nil and myHuman.RootPart.Parent ~= nil then
		myHuman.PlatformStand = false
		local root = myHuman.RootPart
		root.AssemblyLinearVelocity = Vector3.zero
		root.AssemblyAngularVelocity = Vector3.zero
		myHuman:ChangeState(Enum.HumanoidStateType.GettingUp)
	end
end

local bAngVel, flingResetConn
function module.SetFling(state)
	if not module.Fling and state then
		if plr and plr.Character then
			local human = plr.Character:FindFirstChildWhichIsA("Humanoid")
			if human and human.RootPart and human.RootPart.Parent then
				for _,v in pairs(plr.Character:GetDescendants()) do
					if v:IsA("BasePart") then
						v.CustomPhysicalProperties = PhysicalProperties.new(100, 0.3, 0.5)
					end
				end
				task.wait(0.1) -- let server register new physical properties
				
				bAngVel = Instance.new("BodyAngularVelocity")
				bAngVel.Name = "1e02#lkre03EPAS"
				bAngVel.AngularVelocity = Vector3.new(0, 99999, 0)
				bAngVel.MaxTorque = Vector3.new(0, math.huge, 0)
				bAngVel.P = math.huge
				bAngVel.Parent = human.RootPart
				
				for _,v in pairs(plr.Character:GetChildren()) do
					if v:IsA("BasePart") then
						v.CanCollide = false
						v.Massless = true
						v.AssemblyLinearVelocity = Vector3.zero
						v.AssemblyAngularVelocity = Vector3.zero
					end
				end
				
				spawn(function()
					while module.Fling do
						bAngVel.AngularVelocity = Vector3.new(0,99999,0)
						task.wait(.2)
						bAngVel.AngularVelocity = Vector3.zero
						task.wait(.1)
					end
				end)
				
				flingResetConn = human.Died:Once(function()
					module.SetFling(false)
					flingResetConn = nil
				end)
				module.Fling = true
			end
		end
	elseif module.Fling and not state then
		module.Fling = false
		if bAngVel then
			bAngVel:Destroy()
		end
		if flingResetConn then
			flingResetConn:Disconnect()
		end
		if plr and plr.Character then
			local human = plr.Character:FindFirstChildWhichIsA("Humanoid")
			if human and human.RootPart and human.RootPart.Parent then
				task.wait()
				for k,v in pairs(plr.Character:GetDescendants()) do
					if v:IsA("BasePart") then
						v.AssemblyLinearVelocity  = Vector3.zero
						v.AssemblyAngularVelocity = Vector3.zero
						v.Massless = false
						v.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.5)
					end
				end
			end
		end
	end
end

local RespawnConnection
local function SetupFlight()
	task.spawn(function()
		repeat task.wait() until plr.Character or not module.Enabled
		if not module.Enabled then return end
		ContextActionService:BindAction("FlightToggle", function(_, inputState)
			if not plr.Character or not plr.Character.Parent then return end
			local myChar = plr.Character
			local myHuman = myChar:FindFirstChildWhichIsA("Humanoid")
			if not myHuman then return end
			if myHuman.Health == 0 then return end
			if inputState ~= Enum.UserInputState.Begin then return end
			
			Flying = not Flying
			
			if Flying and myHuman ~= nil and myHuman.RootPart ~= nil and myHuman.RootPart.Parent ~= nil then
				local root = myHuman.RootPart
				targetPos = root.Position
				
				local cam
				
				local speed, moveShift = module.NormalSpeed, Vector3.new()
				local Flying, multiplier = false, 1
				
				RunService:BindToRenderStep("MX_FLIGHT", Enum.RenderPriority.Camera.Value - 1, function(dt)
					cam = game.Workspace.CurrentCamera
					root = myHuman.RootPart
					if root ~= nil then
						root.AssemblyLinearVelocity  = Vector3.zero
						root.AssemblyAngularVelocity = Vector3.zero
						moveShift = Vector3.zero
						
						speed = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and module.BoostSpeed or module.NormalSpeed
						
						if UserInputService:IsKeyDown(Enum.KeyCode.W) then
							moveShift += Vector3.new(0, 0, -speed)
						elseif UserInputService:IsKeyDown(Enum.KeyCode.S) then
							moveShift += Vector3.new(0, 0, speed)
						end
						
						if UserInputService:IsKeyDown(Enum.KeyCode.A) then
							moveShift += Vector3.new(-speed, 0, 0)
						elseif UserInputService:IsKeyDown(Enum.KeyCode.D) then
							moveShift += Vector3.new(speed, 0, 0)
						end
						
						if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
							moveShift += Vector3.new(0, speed, 0)
						end
						
						targetPos = (CFrame.new(targetPos, targetPos + cam.CFrame.LookVector) * CFrame.new(moveShift * dt)).Position
						
						root.CFrame = CFrame.new(targetPos, targetPos + cam.CFrame.LookVector)
						
						if module.Fling then
							for k,v in pairs(plr.Character:GetDescendants()) do
								if v:IsA("BasePart") and v.CanCollide then
									v.CanCollide = false
									--v.AssemblyLinearVelocity  = Vector3.zero
									--v.AssemblyAngularVelocity = Vector3.zero
								end
							end
							--root.CFrame = CFrame.new(targetPos, targetPos + cam.CFrame.LookVector)
						end
					end
				end)
			else
				ResetFlight()
			end
		end, UserInputService.TouchEnabled, Enum.KeyCode.LeftControl, Enum.KeyCode.ButtonR2)
		if UserInputService.TouchEnabled then
			ContextActionService:SetTitle("FlightToggle", "Fly")
			ContextActionService:SetPosition("FlightToggle", UDim2.new(1, -150, 1, -100))
		end
		
		local human = plr.Character:FindFirstChildWhichIsA("Humanoid")
		if human then
			RespawnConnection = human.Died:Once(function()
				module.SetFling(false)
				ResetFlight()
				RespawnConnection = nil
			end)
		end
	end)
end

local function Cleanup()
	ResetFlight()
	pcall(ContextActionService.UnbindAction, ContextActionService, "FlightToggle")
	module.SetFling(false)
end

function module.SetEnabled(enabled)
	if not module.Enabled and enabled then
		module.Enabled = true
		SetupFlight()
	elseif module.Enabled and not enabled then
		module.Enabled = false
		Cleanup()
	end
end

return module