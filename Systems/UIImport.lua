-- Melted Model Exporter
-- Exported Model: MeltedEx
local module = {}

function module.Import(TARGET)
	local obj_1, obj_2, obj_3, obj_4, obj_5, obj_6, obj_7, obj_8, obj_9, obj_10, obj_11, obj_12, obj_13, obj_14, obj_15, obj_16, obj_17, obj_18, obj_19, obj_20, obj_21, obj_22, obj_23, obj_24, obj_25, obj_26, obj_27, obj_28, obj_29, obj_30, obj_31, obj_32, obj_33
	obj_1 = Instance.new("Frame")
	obj_1.BorderSizePixel = 0
	obj_1.BackgroundColor3 = Color3.new(0.180392, 0.180392, 0.180392)
	obj_1.AutomaticSize = Enum.AutomaticSize.Y
	obj_1.Size = UDim2.new(0, 500, 0, 30)
	obj_1.BorderColor3 = Color3.new(0, 0, 0)
	obj_1.Parent = TARGET
	obj_1.Position = UDim2.new(0.2, 0, 0.2, 0)
	obj_1.Name = "MainFrame"
	obj_2 = Instance.new("TextLabel")
	obj_2.TextWrapped = true
	obj_2.BorderSizePixel = 0
	obj_2.Name = "TitleBar"
	obj_2.BackgroundColor3 = Color3.new(0.27451, 0.27451, 0.27451)
	obj_2.FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
	obj_2.TextXAlignment = Enum.TextXAlignment.Left
	obj_2.Parent = obj_1
	obj_2.TextColor3 = Color3.new(1, 1, 1)
	obj_2.Size = UDim2.new(1, 0, 0, 30)
	obj_2.BorderColor3 = Color3.new(0, 0, 0)
	obj_2.Text = "  MeltedEx v1.0"
	obj_2.TextSize = 20
	obj_3 = Instance.new("TextButton")
	obj_3.BorderSizePixel = 0
	obj_3.BackgroundColor3 = Color3.new(0.27451, 0.27451, 0.27451)
	obj_3.FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
	obj_3.Parent = obj_2
	obj_3.TextColor3 = Color3.new(1, 1, 1)
	obj_3.TextSize = 16
	obj_3.Size = UDim2.new(0, 40, 1, 0)
	obj_3.BorderColor3 = Color3.new(0, 0, 0)
	obj_3.Text = "—"
	obj_3.Position = UDim2.new(1, -40, 0, 0)
	obj_3.Name = "MinimizeButton"
	obj_4 = Instance.new("Frame")
	obj_4.BorderSizePixel = 0
	obj_4.BackgroundColor3 = Color3.new(1, 1, 1)
	obj_4.BackgroundTransparency = 1
	obj_4.Size = UDim2.new(1, 0, 0, 280)
	obj_4.BorderColor3 = Color3.new(0, 0, 0)
	obj_4.Parent = obj_1
	obj_4.Position = UDim2.new(0, 0, 0, 30)
	obj_4.Name = "Container"
	obj_5 = Instance.new("ScrollingFrame")
	obj_5.BorderSizePixel = 0
	obj_5.CanvasSize = UDim2.new(0, 0, 0, 0)
	obj_5.BackgroundColor3 = Color3.new(0.156863, 0.156863, 0.156863)
	obj_5.AutomaticCanvasSize = Enum.AutomaticSize.Y
	obj_5.Size = UDim2.new(0.3, 0, 1, 0)
	obj_5.ScrollBarImageColor3 = Color3.new(0, 0, 0)
	obj_5.Name = "CategoryFrame"
	obj_5.Parent = obj_4
	obj_5.BorderColor3 = Color3.new(0, 0, 0)
	obj_6 = Instance.new("UIListLayout")
	obj_6.Parent = obj_5
	obj_6.Padding = UDim.new(0, 5)
	obj_6.SortOrder = Enum.SortOrder.LayoutOrder
	obj_7 = Instance.new("TextButton")
	obj_7.TextTruncate = Enum.TextTruncate.AtEnd
	obj_7.BorderSizePixel = 0
	obj_7.BackgroundColor3 = Color3.new(0.156863, 0.156863, 0.156863)
	obj_7.FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
	obj_7.Parent = obj_5
	obj_7.TextColor3 = Color3.new(1, 1, 1)
	obj_7.TextSize = 18
	obj_7.Size = UDim2.new(1, 0, 0, 30)
	obj_7.BorderColor3 = Color3.new(0, 0, 0)
	obj_7.Text = "Category"
	obj_7.Name = "CategoryPlate"
	obj_8 = Instance.new("ScrollingFrame")
	obj_8.BorderSizePixel = 0
	obj_8.CanvasSize = UDim2.new(0, 0, 0, 0)
	obj_8.BackgroundColor3 = Color3.new(0.180392, 0.180392, 0.180392)
	obj_8.AutomaticCanvasSize = Enum.AutomaticSize.Y
	obj_8.Size = UDim2.new(0.7, 0, 1, 0)
	obj_8.ScrollBarImageColor3 = Color3.new(0, 0, 0)
	obj_8.Name = "ContentFrame"
	obj_8.Parent = obj_4
	obj_8.BorderColor3 = Color3.new(0, 0, 0)
	obj_8.BackgroundTransparency = 1
	obj_8.Position = UDim2.new(0.3, 0, 0, 0)
	obj_9 = Instance.new("Frame")
	obj_9.BorderSizePixel = 0
	obj_9.BackgroundColor3 = Color3.new(1, 1, 1)
	obj_9.BackgroundTransparency = 1
	obj_9.AutomaticSize = Enum.AutomaticSize.Y
	obj_9.Size = UDim2.new(1, 0, 0, 0)
	obj_9.BorderColor3 = Color3.new(0, 0, 0)
	obj_9.Parent = obj_8
	obj_9.Name = "ContentLine"
	obj_10 = Instance.new("UIListLayout")
	obj_10.FillDirection = Enum.FillDirection.Horizontal
	obj_10.Parent = obj_9
	obj_10.Padding = UDim.new(0, 5)
	obj_10.SortOrder = Enum.SortOrder.LayoutOrder
	obj_11 = Instance.new("UIListLayout")
	obj_11.Parent = obj_8
	obj_11.SortOrder = Enum.SortOrder.LayoutOrder
	obj_12 = Instance.new("UIPadding")
	obj_12.PaddingTop = UDim.new(0, 5)
	obj_12.PaddingRight = UDim.new(0, 5)
	obj_12.Parent = obj_8
	obj_12.PaddingLeft = UDim.new(0, 5)
	obj_13 = Instance.new("Frame")
	obj_13.BorderSizePixel = 0
	obj_13.BackgroundColor3 = Color3.new(1, 1, 1)
	obj_13.BackgroundTransparency = 1
	obj_13.Size = UDim2.new(1, 0, 0, 30)
	obj_13.BorderColor3 = Color3.new(0, 0, 0)
	obj_13.Parent = obj_8
	obj_13.Position = UDim2.new(-0.159259, 0, -0.52, 0)
	obj_13.Name = "Element_Button"
	obj_13.ClipsDescendants = true
	obj_14 = Instance.new("TextButton")
	obj_14.TextTruncate = Enum.TextTruncate.AtEnd
	obj_14.BorderSizePixel = 0
	obj_14.BackgroundColor3 = Color3.new(0.27451, 0.27451, 0.27451)
	obj_14.FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
	obj_14.Parent = obj_13
	obj_14.TextColor3 = Color3.new(1, 1, 1)
	obj_14.TextSize = 16
	obj_14.Size = UDim2.new(1, 0, 1, -6)
	obj_14.BorderColor3 = Color3.new(1, 1, 1)
	obj_14.Position = UDim2.new(0, 0, 0, 3)
	obj_15 = Instance.new("UICorner")
	obj_15.Parent = obj_14
	obj_15.CornerRadius = UDim.new(0, 10)
	obj_16 = Instance.new("Frame")
	obj_16.BorderSizePixel = 0
	obj_16.BackgroundColor3 = Color3.new(1, 1, 1)
	obj_16.BackgroundTransparency = 1
	obj_16.Size = UDim2.new(1, 0, 0, 30)
	obj_16.BorderColor3 = Color3.new(0, 0, 0)
	obj_16.Parent = obj_8
	obj_16.Position = UDim2.new(-0.159259, 0, -0.52, 0)
	obj_16.Name = "Element_Label"
	obj_16.ClipsDescendants = true
	obj_17 = Instance.new("TextLabel")
	obj_17.BorderSizePixel = 0
	obj_17.BackgroundColor3 = Color3.new(1, 1, 1)
	obj_17.FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
	obj_17.Parent = obj_16
	obj_17.TextColor3 = Color3.new(1, 1, 1)
	obj_17.Size = UDim2.new(1, 0, 0, 30)
	obj_17.BorderColor3 = Color3.new(0, 0, 0)
	obj_17.TextSize = 16
	obj_17.BackgroundTransparency = 1
	obj_18 = Instance.new("Frame")
	obj_18.BorderSizePixel = 0
	obj_18.BackgroundColor3 = Color3.new(1, 1, 1)
	obj_18.BackgroundTransparency = 1
	obj_18.Size = UDim2.new(1, 0, 0, 30)
	obj_18.BorderColor3 = Color3.new(0, 0, 0)
	obj_18.Parent = obj_8
	obj_18.Position = UDim2.new(-0.159259, 0, -0.52, 0)
	obj_18.Name = "Element_Checkbox"
	obj_18.ClipsDescendants = true
	obj_19 = Instance.new("TextButton")
	obj_19.BorderSizePixel = 0
	obj_19.AutoButtonColor = false
	obj_19.BackgroundColor3 = Color3.new(0.27451, 0.27451, 0.27451)
	obj_19.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
	obj_19.TextTransparency = 1
	obj_19.Parent = obj_18
	obj_19.TextColor3 = Color3.new(0, 0, 0)
	obj_19.TextSize = 14
	obj_19.Size = UDim2.new(0, 40, 0, 24)
	obj_19.BorderColor3 = Color3.new(0, 0, 0)
	obj_19.Text = ""
	obj_19.Position = UDim2.new(0, 0, 0, 3)
	obj_19.Name = "CheckboxToggle"
	obj_20 = Instance.new("UICorner")
	obj_20.Parent = obj_19
	obj_20.CornerRadius = UDim.new(1, 0)
	obj_21 = Instance.new("Frame")
	obj_21.BorderSizePixel = 0
	obj_21.BackgroundColor3 = Color3.new(1, 1, 1)
	obj_21.AnchorPoint = Vector2.new(0, 0.5)
	obj_21.Size = UDim2.new(0, 16, 0, 16)
	obj_21.BorderColor3 = Color3.new(0, 0, 0)
	obj_21.Parent = obj_19
	obj_21.Position = UDim2.new(0, 4, 0.5, 0)
	obj_21.Name = "Indicator"
	obj_22 = Instance.new("UICorner")
	obj_22.Parent = obj_21
	obj_22.CornerRadius = UDim.new(1, 0)
	obj_23 = Instance.new("TextLabel")
	obj_23.TextTruncate = Enum.TextTruncate.AtEnd
	obj_23.BorderSizePixel = 0
	obj_23.BackgroundColor3 = Color3.new(1, 1, 1)
	obj_23.FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
	obj_23.TextXAlignment = Enum.TextXAlignment.Left
	obj_23.Parent = obj_18
	obj_23.TextColor3 = Color3.new(1, 1, 1)
	obj_23.Size = UDim2.new(1, -45, 1, 0)
	obj_23.BorderColor3 = Color3.new(0, 0, 0)
	obj_23.Text = "Checkbox"
	obj_23.TextSize = 16
	obj_23.BackgroundTransparency = 1
	obj_23.Position = UDim2.new(0, 45, 0, 0)
	obj_24 = Instance.new("Frame")
	obj_24.BorderSizePixel = 0
	obj_24.BackgroundColor3 = Color3.new(1, 1, 1)
	obj_24.BackgroundTransparency = 1
	obj_24.Size = UDim2.new(1, 0, 0, 50)
	obj_24.BorderColor3 = Color3.new(0, 0, 0)
	obj_24.Parent = obj_8
	obj_24.Position = UDim2.new(-0.159259, 0, -0.52, 0)
	obj_24.Name = "Element_Slider"
	obj_24.ClipsDescendants = true
	obj_25 = Instance.new("TextLabel")
	obj_25.BorderSizePixel = 0
	obj_25.BackgroundColor3 = Color3.new(1, 1, 1)
	obj_25.FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
	obj_25.Parent = obj_24
	obj_25.TextColor3 = Color3.new(1, 1, 1)
	obj_25.Size = UDim2.new(1, 0, 0, 22)
	obj_25.BorderColor3 = Color3.new(0, 0, 0)
	obj_25.Text = "Slider"
	obj_25.TextSize = 16
	obj_25.BackgroundTransparency = 1
	obj_25.Position = UDim2.new(0, 0, 0, 3)
	obj_26 = Instance.new("Frame")
	obj_26.BorderSizePixel = 0
	obj_26.BackgroundColor3 = Color3.new(0.27451, 0.27451, 0.27451)
	obj_26.BorderMode = Enum.BorderMode.Inset
	obj_26.Size = UDim2.new(1, 0, 0, 25)
	obj_26.BorderColor3 = Color3.new(0, 0, 0)
	obj_26.Parent = obj_24
	obj_26.Position = UDim2.new(0, 0, 0, 25)
	obj_26.Name = "SliderContainer"
	obj_26.ClipsDescendants = true
	obj_27 = Instance.new("Frame")
	obj_27.BorderSizePixel = 0
	obj_27.BackgroundColor3 = Color3.new(0.392157, 0.392157, 0.392157)
	obj_27.Size = UDim2.new(0, 5, 1, 0)
	obj_27.BorderColor3 = Color3.new(0, 0, 0)
	obj_27.Parent = obj_26
	obj_27.Name = "SliderFront"
	obj_28 = Instance.new("UICorner")
	obj_28.Parent = obj_27
	obj_28.CornerRadius = UDim.new(0, 10)
	obj_29 = Instance.new("TextLabel")
	obj_29.BorderSizePixel = 0
	obj_29.Name = "SliderValue"
	obj_29.BackgroundColor3 = Color3.new(1, 1, 1)
	obj_29.FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
	obj_29.Parent = obj_26
	obj_29.TextColor3 = Color3.new(1, 1, 1)
	obj_29.Size = UDim2.new(1, -10, 1, 0)
	obj_29.BorderColor3 = Color3.new(0, 0, 0)
	obj_29.Text = "0"
	obj_29.TextSize = 16
	obj_29.BackgroundTransparency = 1
	obj_29.Position = UDim2.new(0, 5, 0, 0)
	obj_30 = Instance.new("UICorner")
	obj_30.Parent = obj_26
	obj_30.CornerRadius = UDim.new(0, 10)
	obj_31 = Instance.new("Frame")
	obj_31.BorderSizePixel = 0
	obj_31.BackgroundColor3 = Color3.new(1, 1, 1)
	obj_31.BackgroundTransparency = 1
	obj_31.Size = UDim2.new(1, 0, 0, 30)
	obj_31.BorderColor3 = Color3.new(0, 0, 0)
	obj_31.Parent = obj_8
	obj_31.Position = UDim2.new(-0.159259, 0, -0.52, 0)
	obj_31.Name = "Element_Dropdown"
	obj_31.ClipsDescendants = true
	obj_32 = Instance.new("TextButton")
	obj_32.TextTruncate = Enum.TextTruncate.AtEnd
	obj_32.BorderSizePixel = 0
	obj_32.BackgroundColor3 = Color3.new(0.27451, 0.27451, 0.27451)
	obj_32.FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
	obj_32.Parent = obj_31
	obj_32.TextColor3 = Color3.new(1, 1, 1)
	obj_32.TextSize = 16
	obj_32.Size = UDim2.new(1, 0, 1, -6)
	obj_32.BorderColor3 = Color3.new(1, 1, 1)
	obj_32.Position = UDim2.new(0, 0, 0, 3)
	obj_33 = Instance.new("UICorner")
	obj_33.Parent = obj_32
	obj_33.CornerRadius = UDim.new(0, 10)
end

return module