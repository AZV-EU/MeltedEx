local module = {
	Minimized = false
}

local CONSTANTS = {
	TweenInfoDefault = TweenInfo.new(0.2, Enum.EasingStyle.Linear),
	MinimizeWidth = 200
}

local Players = _G.SafeGetService("Players")
local TextService = _G.SafeGetService("TextService")
local TweenService = _G.SafeGetService("TweenService")
local UserInputService = _G.SafeGetService("UserInputService")

local connections = {}

function module.Init()
	if module.GUI then return end
	local loader = _G.LoadRemoteModule(_G.MX_BaseURL .. "Systems/UIImport.lua", "UIImport")
	module.GUI = Instance.new("ScreenGui", game.CoreGui)
	module.GUI.Name = "MXUI"
	module.GUI.Enabled = false
	module.GUI.DisplayOrder = 9999
	loader.Import(module.GUI)
	
	-- declare base components
	local mainFrame = module.GUI:FindFirstChild("MainFrame")
	CONSTANTS.MaximizeWidth = mainFrame.Size.X.Offset
	local titleBar = mainFrame:FindFirstChild("TitleBar")
	if _G.MX_ENV == "PROD" then
		titleBar.Text = string.format(" MeltedEx v%s", _G.MX_VERSION)
	else
		titleBar.Text = string.format(" MeltedEx v%s (%s)", _G.MX_VERSION, _G.MX_ENV)
	end
	local minimizeButton = titleBar:FindFirstChild("MinimizeButton")
	
	local modalWindow = module.GUI:FindFirstChild("ModalWindow")
	modalWindow.Parent = nil
	
	local mainContainer = mainFrame:FindFirstChild("Container")
	local categoryFrame = mainContainer:FindFirstChild("CategoryFrame")
	local contentFrame = mainContainer:FindFirstChild("ContentFrame")
	
	-- template assignment
	local categoryPlate = categoryFrame:FindFirstChild("CategoryPlate")
	categoryPlate.Parent = nil
	
	local contentLine = contentFrame:FindFirstChild("ContentLine")
	local elementLabel = contentFrame:FindFirstChild("Element_Label")
	local elementButton = contentFrame:FindFirstChild("Element_Button")
	local elementSlider = contentFrame:FindFirstChild("Element_Slider")
	local elementCheckbox = contentFrame:FindFirstChild("Element_Checkbox")
	local elementDropdown = contentFrame:FindFirstChild("Element_Dropdown")
	contentLine.Parent = nil
	elementLabel.Parent = nil
	elementButton.Parent = nil
	elementSlider.Parent = nil
	elementCheckbox.Parent = nil
	elementDropdown.Parent = nil
	
	contentFrame.Parent = nil -- reuse for different categories
	
	function module:Move(posX, posY)
		mainFrame.Position = UDim2.fromOffset(
			math.min(module.GUI.AbsoluteSize.X - mainFrame.AbsoluteSize.X, math.max(0, posX)),
			math.min(module.GUI.AbsoluteSize.Y - mainFrame.AbsoluteSize.Y, math.max(0, posY))
		)
	end
	
	do -- Maximize/minimize functionality
		local minMaxOffset = (CONSTANTS.MaximizeWidth - CONSTANTS.MinimizeWidth)
		minimizeButton.Activated:Connect(function()
			module.Minimized = not module.Minimized
			
			minimizeButton.Text = module.Minimized and "+" or "—"
			
			mainContainer.Visible = not module.Minimized
			
			mainFrame.Size = module.Minimized and UDim2.fromOffset(CONSTANTS.MinimizeWidth, 0) or UDim2.fromOffset(CONSTANTS.MaximizeWidth, 0)
			
			if module.Minimized then
				module:Move(mainFrame.AbsolutePosition.X + minMaxOffset, mainFrame.AbsolutePosition.Y)
			else
				module:Move(mainFrame.AbsolutePosition.X - minMaxOffset, mainFrame.AbsolutePosition.Y)
			end
		end)
	end
	
	do -- Dragging functionality
		local dragging = false
		local dragOffset = Vector2.zero
		titleBar.InputBegan:Connect(function(input)
			if not dragging and
				(input.UserInputType == Enum.UserInputType.MouseButton1 or
				input.UserInputType == Enum.UserInputType.Touch) then
				dragging = true
				dragOffset = mainFrame.AbsolutePosition - Vector2.new(input.Position.X, input.Position.Y)
			end
		end)
		
		table.insert(connections, UserInputService.InputChanged:Connect(function(input)
			if dragging and
				(input.UserInputType == Enum.UserInputType.MouseMovement or
				input.UserInputType == Enum.UserInputType.Touch) then
				
				module:Move(input.Position.X + dragOffset.X, input.Position.Y + dragOffset.Y)
			end
		end))
		
		table.insert(connections, UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or
				input.UserInputType == Enum.UserInputType.Touch then
				dragging = false
			end
		end))
	end
	
	module.Categories = {}
	module.CurrentCategory = nil
	
	function module:SelectCategory(name)
		local category = module.Categories[name]
		if category then
			module.CurrentCategory = category
		end
		for _,ct in pairs(module.Categories) do
			if ct ~= module.CurrentCategory then
				ct.CategoryPlate.BackgroundColor3 = categoryFrame.BackgroundColor3
				ct.Content.Visible = false
			else
				ct.CategoryPlate.BackgroundColor3 = mainFrame.BackgroundColor3
				ct.Content.Visible = true
			end
			ct.CategoryPlate.Text = tostring(ct.Name)
		end
	end
	
	function module:AddCategory(name)
		if module.Categories[name] then
			return module.Categories[name]
		end
		local category = {
			Name = name,
			CategoryPlate = categoryPlate:Clone(),
			Content = contentFrame:Clone()
		}
		
		category.CategoryPlate.Text = tostring(name)
		category.CategoryPlate.Parent = categoryFrame
		category.CategoryPlate.Activated:Connect(function()
			module:SelectCategory(category.Name)
		end)
		
		category.Content.Visible = false
		category.Content.Parent = mainContainer
		
		local currentLine = nil
		
		local function SetupElement(element)
			element.UI.Parent = currentLine or category.Content
			
			function element:SetVisible(visible)
				element.UI.Visible = visible
			end
			
			function element:SetEnabled(enabled)
				element.Enabled = enabled
				element.UI.Interactable = enabled
				if element.Class == elementLabel then
					element.UI.TextLabel.TextColor3 = enabled and Color3.new(1, 1, 1) or Color3.new(0.7, 0.7, 0.7)
				elseif element.Class == elementButton then
					element.UI.TextButton.TextColor3 = enabled and Color3.new(1, 1, 1) or Color3.new(0.7, 0.7, 0.7)
					element.UI.TextButton.AutoButtonColor = enabled
				elseif element.Class == elementCheckbox then
					element.UI.TextLabel.TextColor3 = enabled and Color3.new(1, 1, 1) or Color3.new(0.7, 0.7, 0.7)
					element.UI.CheckboxToggle.Indicator.BackgroundColor3 = enabled and Color3.new(1, 1, 1) or Color3.new(0.7, 0.7, 0.7)
				end
			end
			
			function element:Destroy()
				if element.UI then
					element.UI:Destroy()
				end
			end
		end
		
		function category:BeginInline()
			if currentLine then return end
			currentLine = contentLine:Clone()
			currentLine.Parent = category.Content
		end
		
		function category:EndInline()
			if not currentLine then return end
			local width = 1/(#currentLine:GetChildren() - 1)
			for _,element in pairs(currentLine:GetChildren()) do
				if element:IsA("Frame") then
					element.Size = UDim2.new(width, 0, element.Size.Y.Scale, element.Size.Y.Offset)
				end
			end
			currentLine = nil
		end
		
		function category:AddLabel(text)
			local label = {
				Text = tostring(text),
				UI = elementLabel:Clone(),
				Class = elementLabel,
				Enabled = true
			}
			SetupElement(label)
			
			function label:SetText(newText)
				newText = tostring(newText)
				label.Text = newText
				label.UI.Text = newText
			end
			label:SetText(text)
			
			function label:SetColor(color)
				label.UI.TextColor3 = color
			end
			
			return label
		end
		
		function category:AddButton(text, action)
			local button = {
				Text = tostring(text),
				Action = action,
				UI = elementButton:Clone(),
				Class = elementButton,
				Enabled = true
			}
			SetupElement(button)
			
			function button:SetText(newText)
				newText = tostring(newText)
				button.Text = newText
				button.UI.TextButton.Text = newText
			end
			button:SetText(text)
			
			function button:SetColor(color)
				button.UI.TextButton.TextColor3 = color
			end
			
			function button:SetAction(action)
				button.Action = action
			end
			
			button.UI.TextButton.Activated:Connect(function()
				if button.Action then
					local f, err = pcall(button.Action)
					if not f then
						print("[MX::UI] Button activated action failed:", err)
					end
				end
			end)
			
			return button
		end
		
		function category:AddCheckbox(text, action)
			local checkbox = {
				Text = tostring(text),
				Action = action,
				Checked = false,
				UI = elementCheckbox:Clone(),
				Class = elementCheckbox,
				Enabled = true
			}
			SetupElement(checkbox)
			
			function checkbox:SetText(newText)
				newText = tostring(newText)
				checkbox.Text = newText
				checkbox.UI.TextLabel.Text = newText
			end
			checkbox:SetText(text)
			
			function checkbox:SetColor(color)
				checkbox.UI.TextLabel.TextColor3 = color
			end
			
			function checkbox:SetAction(action)
				checkbox.Action = action
			end
			
			local toggleTweenOn = TweenService:Create(checkbox.UI.CheckboxToggle, CONSTANTS.TweenInfoDefault, { BackgroundColor3 = Color3.new(0, 0.4, 0) })
			local toggleTweenOff = TweenService:Create(checkbox.UI.CheckboxToggle, CONSTANTS.TweenInfoDefault, { BackgroundColor3 = elementCheckbox.CheckboxToggle.BackgroundColor3 })
			
			local indicatorTweenOn = TweenService:Create(checkbox.UI.CheckboxToggle.Indicator, CONSTANTS.TweenInfoDefault, { Position = UDim2.new(1, -20, 0.5, 0) })
			local indicatorTweenOff = TweenService:Create(checkbox.UI.CheckboxToggle.Indicator, CONSTANTS.TweenInfoDefault, { Position = UDim2.new(0, 4, 0.5, 0) })
			
			local function FireAction()
				if checkbox.Checked then
					toggleTweenOff:Cancel()
					indicatorTweenOff:Cancel()
					toggleTweenOn:Play()
					indicatorTweenOn:Play()
				else
					toggleTweenOn:Cancel()
					indicatorTweenOn:Cancel()
					toggleTweenOff:Play()
					indicatorTweenOff:Play()
				end
				if checkbox.Action then
					local f, err = pcall(checkbox.Action, checkbox.Checked)
					if not f then
						print("[MX::UI] Checkbox toggle action failed:", err)
					end
				end
			end
			
			function checkbox:SetChecked(checked)
				if checkbox.Checked ~= checked then
					checkbox.Checked = checked
					FireAction()
				end
			end
			
			checkbox.UI.CheckboxToggle.Activated:Connect(function()
				checkbox.Checked = not checkbox.Checked
				FireAction()
			end)
			
			return checkbox
		end
		
		function category:AddSlider(text, value, rangeMin, rangeMax, action, step)
			step = step or 1
			local slider = {
				Text = tostring(text),
				Action = action,
				Value = tonumber(value) or 0,
				Min = tonumber(rangeMin) or 0,
				Max = tonumber(rangeMax) or 0,
				Step = tonumber(step) or 1,
				UI = elementSlider:Clone(),
				Class = elementSlider,
				Enabled = true
			}
			SetupElement(slider)
			
			function slider:SetText(newText)
				newText = tostring(newText)
				slider.Text = newText
				slider.UI.TextLabel.Text = newText
			end
			slider:SetText(text)
			
			function slider:SetColor(color)
				slider.UI.TextLabel.TextColor3 = color
			end
			
			function slider:SetAction(action)
				slider.Action = action
			end
			
			local function FireAction()
				if slider.Action then
					local f, err = pcall(slider.Action, slider.Value)
					if not f then
						print("[MX::UI] Slider action failed:", err)
					end
				end
			end
			
			function slider:SetValue(newValue)
				newValue = tonumber(newValue) or slider.Value
				newValue = math.max(slider.Min, math.min(slider.Max, newValue - math.fmod(newValue, slider.Step)))
				if math.abs(table.pack(math.modf(slider.Step))[2]) > 0 then
					slider.UI.SliderContainer.SliderValue.Text = string.format("%.2f / %.2f", newValue, slider.Max)
				else
					slider.UI.SliderContainer.SliderValue.Text = string.format("%d / %d", newValue, slider.Max)
				end
				slider.UI.SliderContainer.SliderFront.Size = UDim2.new(0, (slider.UI.SliderContainer.AbsoluteSize.X - 5) * ( (slider.Value - slider.Min) / (slider.Max - slider.Min) ) + 5, 1, 0)
				if slider.Value ~= newValue then
					slider.Value = newValue
					FireAction()
				end
			end
			slider:SetValue(value)
			
			local function SlideTo(posX)
				slider:SetValue(((posX - slider.UI.SliderContainer.AbsolutePosition.X) / slider.UI.SliderContainer.AbsoluteSize.X) * slider.Max - slider.Min + slider.Step / 2)
			end
			
			local DefaultValue = slider.Value
			
			local sliding, slidingOffset = false, 0
			slider.UI.SliderContainer.InputBegan:Connect(function(input)
				if not sliding and
					(input.UserInputType == Enum.UserInputType.MouseButton1 or
					input.UserInputType == Enum.UserInputType.Touch) then
					sliding = true
					--slidingOffset = (slider.UI.SliderContainer.SliderFront.AbsolutePosition.X + slider.UI.SliderContainer.SliderFront.AbsoluteSize.X) - input.Position.X
					--SlideTo(input.Position.X + slidingOffset)
					SlideTo(input.Position.X)
				elseif input.UserInputType == Enum.UserInputType.MouseButton3 then
					Slider:SetValue(DefaultValue)
				end
			end)
			
			slider.UI.SliderContainer.InputChanged:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseWheel then
					if input.Position.Z > 0 then
						slider:SetValue(slider.Value + slider.Step * 1.5)
					elseif input.Position.Z < 0 then
						slider:SetValue(slider.Value - slider.Step)
					end
					--sliding = false
				end
			end)
			
			table.insert(connections, UserInputService.InputChanged:Connect(function(input)
				if sliding and
					(input.UserInputType == Enum.UserInputType.MouseMovement or
					input.UserInputType == Enum.UserInputType.Touch) then
					--SlideTo(input.Position.X + slidingOffset)
					SlideTo(input.Position.X)
				end
			end))
			
			table.insert(connections, UserInputService.InputEnded:Connect(function(input)
				if sliding and
					(input.UserInputType == Enum.UserInputType.MouseButton1 or
					input.UserInputType == Enum.UserInputType.Touch) then
					sliding = false
					--SlideTo(input.Position.X + slidingOffset)
					SlideTo(input.Position.X)
				end
			end))
			
			return slider
		end
		
		function category:AddDropdown(options, default, onChange)
			local dropdown = {
				UI = elementDropdown:Clone(),
				Options = options,
				SelectedOption = default and options[default] or "",
				Class = elementDropdown,
				Enabled = true
			}
			SetupElement(dropdown)
			
			function button:SetColor(color)
				label.UI.TextColor3 = color
			end
			
			return label
		end
		
		module.Categories[name] = category
		return module.Categories[name]
	end
	
	module.CurrentModal = nil
	function module:HideModal(option)
		if module.CurrentModal then
			if module.CurrentModal.OnSelected then
				local f, err = pcall(module.CurrentModal.OnSelected, option)
				if not f then
					warn(err)
				end
			end
			pcall(module.CurrentModal.Window.Destroy, module.CurrentModal.Window)
		end
		module.CurrentModal = nil
	end
	function module:ShowModal(title, options, onSelected)
		if module.CurrentModal then
			module:HideModal()
		end
		if not options then return end
		module.CurrentModal = {
			Window = modalWindow:Clone(),
			Options = options,
			OnSelected = onSelected
		}
		module.CurrentModal.Window.TitleBar.Text = tostring(title)
		module.CurrentModal.Window.TitleBar.CloseButton.Activated:Connect(function()
			module:HideModal()
		end)
		local filterBox = module.CurrentModal.Window.FilterBox
		local optionUI = module.CurrentModal.Window.Content.TextButton
		optionUI.Parent = nil
		function module.CurrentModal:Update(newOptions)
			if not newOptions then return end
			module.CurrentModal.Options = newOptions
			for _,v in pairs(module.CurrentModal.Window.Content:GetChildren()) do
				if v:IsA("TextButton") then
					v:Destroy()
				end
			end
			for index,option in pairs(newOptions) do
				local ui = optionUI:Clone()
				ui.Name = "Option" .. tostring(index)
				if not option.Image then
					ui.Text = option.Text
					if option.Color then
						ui.TextColor3 = option.Color
					end
				else
					ui.Text = ""
					ui.ImageLabel.Image = option.Image
					ui.TextLabel.Text = option.Text
					if option.Color then
						ui.TextLabel.TextColor3 = option.Color
					end
					ui.ImageLabel.Visible = true
					ui.TextLabel.Visible = true
				end
				ui.Visible = option.Text:lower():find(filterBox.Text:lower())
				ui.Activated:Connect(function()
					module:HideModal(index)
				end)
				ui.Parent = module.CurrentModal.Window.Content
			end
		end
		module.CurrentModal:Update(options)
		filterBox:GetPropertyChangedSignal("Text"):Connect(function()
			for _,v in pairs(module.CurrentModal.Window.Content:GetChildren()) do
				if v:IsA("TextButton") then
					v.Visible = v.Text:lower():find(filterBox.Text:lower()) or v.TextLabel.Text:lower():find(filterBox.Text:lower())
				end
			end
		end)
		module.CurrentModal.Window.Visible = true
		module.CurrentModal.Window.Parent = module.GUI
	end
	
	module:Move(module.GUI.AbsoluteSize.X - CONSTANTS.MaximizeWidth, module.GUI.AbsoluteSize.Y * .5)
	
	module.GUI.Enabled = true
end

function module.Cleanup()
	for _,conn in pairs(connections) do
		pcall(conn.Disconnect, conn)
	end
	module.GUI:Destroy()
	if module.CurrentModal then
		module:HideModal()
	end
end

return module