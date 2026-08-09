local lib = {RainbowColorValue = 0, HueSelectionPosition = 0}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local TouchMode = UserInputService.TouchEnabled
local function GetViewportSize()
	local Camera = workspace.CurrentCamera
	return Camera and Camera.ViewportSize or Vector2.new(1280, 720)
end
local function GetWindowTargetSize()
	local Viewport = GetViewportSize()
	if TouchMode then
		return Vector2.new(math.max(300, math.min(720, Viewport.X - 12)), math.max(280, math.min(500, Viewport.Y - 18)))
	end
	return Vector2.new(720, 500)
end
local PrimaryColor = Color3.fromRGB(12, 13, 16)
local SecondaryColor = Color3.fromRGB(185, 18, 34)
local TextColor = Color3.fromRGB(218, 220, 224)
local CloseBind = Enum.KeyCode.RightControl
local ThemeBindings = {Primary = {}, Secondary = {}, Text = {}, Callbacks = {Primary = {}, Secondary = {}, Text = {}}}
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Existing = PlayerGui:FindFirstChild("ui") or CoreGui:FindFirstChild("ui")
if Existing then
	pcall(function() Existing:Destroy() end)
end
local ui = Instance.new("ScreenGui")
ui.Name = "ui"
ui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ui.ResetOnSpawn = false
ui.IgnoreGuiInset = false
ui.Parent = PlayerGui
local function ToColor3(c)
	if typeof(c) == "Color3" then
		return c
	end
	if type(c) == "table" then
		if typeof(c.R) == "number" and typeof(c.G) == "number" and typeof(c.B) == "number" then
			if c.R > 1 or c.G > 1 or c.B > 1 then
				return Color3.fromRGB(c.R, c.G, c.B)
			end
			return Color3.new(c.R, c.G, c.B)
		end
		if typeof(c[1]) == "number" and typeof(c[2]) == "number" and typeof(c[3]) == "number" then
			if c[1] > 1 or c[2] > 1 or c[3] > 1 then
				return Color3.fromRGB(c[1], c[2], c[3])
			end
			return Color3.new(c[1], c[2], c[3])
		end
	end
	if type(c) == "string" then
		local r, g, b = string.match(c, "(%d+),%s*(%d+),%s*(%d+)")
		if r and g and b then
			return Color3.fromRGB(tonumber(r), tonumber(g), tonumber(b))
		end
	end
	return nil
end
local function MutedText()
	return Color3.fromRGB(math.clamp(TextColor.R * 255 - 85, 70, 190), math.clamp(TextColor.G * 255 - 85, 70, 190), math.clamp(TextColor.B * 255 - 85, 70, 190))
end
local function HoverPrimary()
	return Color3.fromRGB(math.clamp(PrimaryColor.R * 255 + 15, 0, 255), math.clamp(PrimaryColor.G * 255 + 15, 0, 255), math.clamp(PrimaryColor.B * 255 + 15, 0, 255))
end
local function PanelPrimary()
	return Color3.fromRGB(math.clamp(PrimaryColor.R * 255 + 7, 0, 255), math.clamp(PrimaryColor.G * 255 + 7, 0, 255), math.clamp(PrimaryColor.B * 255 + 7, 0, 255))
end
local function PanelSecondary()
	return Color3.fromRGB(math.clamp(PrimaryColor.R * 255 + 11, 0, 255), math.clamp(PrimaryColor.G * 255 + 11, 0, 255), math.clamp(PrimaryColor.B * 255 + 11, 0, 255))
end
local function BorderColor()
	return Color3.fromRGB(math.clamp(PrimaryColor.R * 255 + 30, 28, 72), math.clamp(PrimaryColor.G * 255 + 30, 28, 72), math.clamp(PrimaryColor.B * 255 + 30, 28, 72))
end
local function BindTheme(obj, prop, kind)
	if not obj then
		return
	end
	table.insert(ThemeBindings[kind], {obj = obj, prop = prop})
	pcall(function()
		if kind == "Primary" then
			obj[prop] = PrimaryColor
		elseif kind == "Secondary" then
			obj[prop] = SecondaryColor
		else
			obj[prop] = TextColor
		end
	end)
end
local function BindThemeCallback(kind, fn)
	table.insert(ThemeBindings.Callbacks[kind], fn)
end
local function UpdateTheme(kind)
	local source = ThemeBindings[kind]
	for i = #source, 1, -1 do
		local entry = source[i]
		if entry.obj and entry.obj.Parent then
			pcall(function()
				if kind == "Primary" then
					entry.obj[entry.prop] = PrimaryColor
				elseif kind == "Secondary" then
					entry.obj[entry.prop] = SecondaryColor
				else
					entry.obj[entry.prop] = TextColor
				end
			end)
		else
			table.remove(source, i)
		end
	end
	local callbacks = ThemeBindings.Callbacks[kind]
	for i = #callbacks, 1, -1 do
		local ok = pcall(callbacks[i], kind == "Primary" and PrimaryColor or kind == "Secondary" and SecondaryColor or TextColor)
		if not ok then
			table.remove(callbacks, i)
		end
	end
end
local function Make(className, props)
	local inst = Instance.new(className)
	for k, v in pairs(props) do
		inst[k] = v
	end
	return inst
end
local function ApplyStroke(obj, color)
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 1
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Color = color or BorderColor()
	stroke.Parent = obj
	if not color then
		BindThemeCallback("Primary", function()
			if stroke and stroke.Parent then
				stroke.Color = BorderColor()
			end
		end)
	end
	return stroke
end
local function ApplyCorner(obj, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 4)
	corner.Parent = obj
	return corner
end
local function ApplyPadding(obj, left, right, top, bottom)
	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, left or 0)
	padding.PaddingRight = UDim.new(0, right or left or 0)
	padding.PaddingTop = UDim.new(0, top or 0)
	padding.PaddingBottom = UDim.new(0, bottom or top or 0)
	padding.Parent = obj
	return padding
end
local function CreateList(parent, padding)
	local layout = Instance.new("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, padding or 6)
	layout.Parent = parent
	return layout
end
local function SyncCanvas(scroll, layout, extra)
	local function update()
		scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + (extra or 0))
	end
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(update)
	update()
end
local function Tween(obj, t, props)
	TweenService:Create(obj, TweenInfo.new(t, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end
local function MakeDraggable(topbarobject, object)
	local dragging = false
	local dragInput = nil
	local dragStart = nil
	local startPosition = nil
	local function update(input)
		local delta = input.Position - dragStart
		object.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X, startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
	end
	topbarobject.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPosition = object.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	topbarobject.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and input == dragInput then
			update(input)
		end
	end)
end
local function CreateBaseItem(parent, height)
	height = height or 34
	if TouchMode then height = math.max(height, 42) end
	local holder = Make("Frame", {
		Parent = parent,
		BackgroundColor3 = PanelPrimary(),
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, height),
		ClipsDescendants = true
	})
	ApplyCorner(holder, 4)
	BindThemeCallback("Primary", function()
		if holder and holder.Parent then
			holder.BackgroundColor3 = PanelPrimary()
		end
	end)
	local stroke = ApplyStroke(holder)
	return holder, stroke
end
local function CreateHeaderLabel(parent, text, isAccent)
	local lbl = Make("TextLabel", {
		Parent = parent,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 18),
		Font = Enum.Font.Code,
		Text = text,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = isAccent and SecondaryColor or MutedText()
	})
	if isAccent then
		BindTheme(lbl, "TextColor3", "Secondary")
	else
		BindThemeCallback("Text", function()
			if lbl and lbl.Parent then
				lbl.TextColor3 = MutedText()
			end
		end)
	end
	return lbl
end
local function CreatePanel(parent, size, pos, title)
	local frame = Make("Frame", {
		Parent = parent,
		BackgroundColor3 = PanelPrimary(),
		BorderSizePixel = 0,
		Position = pos,
		Size = size,
		ClipsDescendants = true
	})
	ApplyCorner(frame, 5)
	BindThemeCallback("Primary", function()
		if frame and frame.Parent then
			frame.BackgroundColor3 = PanelPrimary()
		end
	end)
	ApplyStroke(frame)
	local titleLabel = Make("TextLabel", {
		Parent = frame,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 12, 0, 8),
		Size = UDim2.new(1, -24, 0, 17),
		Font = Enum.Font.Code,
		Text = title,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = TextColor
	})
	BindTheme(titleLabel, "TextColor3", "Text")
	local accent = Make("Frame", {
		Parent = frame,
		BorderSizePixel = 0,
		BackgroundColor3 = SecondaryColor,
		Position = UDim2.new(0, 12, 0, 29),
		Size = UDim2.new(0, 30, 0, 2)
	})
	BindTheme(accent, "BackgroundColor3", "Secondary")
	local line = Make("Frame", {
		Parent = frame,
		BorderSizePixel = 0,
		BackgroundColor3 = BorderColor(),
		Position = UDim2.new(0, 48, 0, 29),
		Size = UDim2.new(1, -60, 0, 1)
	})
	BindThemeCallback("Primary", function()
		if line and line.Parent then
			line.BackgroundColor3 = BorderColor()
		end
	end)
	return frame
end
local function CreateScrollingPanel(parent, size, pos, title)
	local panel = CreatePanel(parent, size, pos, title)
	local scroll = Make("ScrollingFrame", {
		Parent = panel,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 10, 0, 39),
		Size = UDim2.new(1, -20, 1, -49),
		CanvasSize = UDim2.new(),
		BorderSizePixel = 0,
		ScrollBarThickness = 2,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		AutomaticCanvasSize = Enum.AutomaticSize.None,
		TopImage = "rbxassetid://0",
		MidImage = "rbxassetid://0",
		BottomImage = "rbxassetid://0",
		ScrollBarImageColor3 = SecondaryColor
	})
	BindTheme(scroll, "ScrollBarImageColor3", "Secondary")
	local layout = CreateList(scroll, 7)
	SyncCanvas(scroll, layout, 6)
	return panel, scroll, layout
end
local function SetVisibleRecursive(holder, state)
	for _, v in ipairs(holder:GetChildren()) do
		if v:IsA("GuiObject") then
			v.Visible = state
		end
	end
end
local function CreatePopupHolder(root)
	local popup = Make("Frame", {
		Parent = root,
		BackgroundColor3 = PrimaryColor,
		BorderSizePixel = 0,
		Visible = false,
		ClipsDescendants = true,
		ZIndex = 50
	})
	BindTheme(popup, "BackgroundColor3", "Primary")
	ApplyStroke(popup)
	return popup
end
function lib:Window(text, secondary, closebind, primary, textCol)
	CloseBind = closebind or Enum.KeyCode.RightControl
	local sec = ToColor3(secondary)
	local pri = ToColor3(primary)
	local txt = ToColor3(textCol)
	if sec then SecondaryColor = sec end
	if pri then PrimaryColor = pri end
	if txt then TextColor = txt end
	UpdateTheme("Primary")
	UpdateTheme("Secondary")
	UpdateTheme("Text")
	local main = Make("Frame", {
		Parent = ui,
		Name = "MainWindow",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, 0, 0, 0),
		BackgroundColor3 = PrimaryColor,
		BorderSizePixel = 0,
		ClipsDescendants = true
	})
	BindTheme(main, "BackgroundColor3", "Primary")
	ApplyStroke(main)
	local topBar = Make("Frame", {
		Parent = main,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 36)
	})
	local appName = Make("TextLabel", {
		Parent = topBar,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 8, 0, 5),
		Size = UDim2.new(0, 184, 0, 20),
		Font = Enum.Font.Code,
		Text = tostring(text or "Library"),
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextColor3 = SecondaryColor
	})
	BindTheme(appName, "TextColor3", "Secondary")
	local tabStrip = Make("ScrollingFrame", {
		Parent = topBar,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 194, 0, 0),
		Size = UDim2.new(1, -204, 1, 0),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		ScrollBarThickness = 0,
		ScrollingDirection = Enum.ScrollingDirection.X,
		ElasticBehavior = Enum.ElasticBehavior.WhenScrollable,
		Active = true,
		ClipsDescendants = true
	})
	local tabLayout = Instance.new("UIListLayout")
	tabLayout.FillDirection = Enum.FillDirection.Horizontal
	tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	tabLayout.Padding = UDim.new(0, 8)
	tabLayout.Parent = tabStrip
	local function SyncTabCanvas()
		tabStrip.CanvasSize = UDim2.new(0, math.max(0, tabLayout.AbsoluteContentSize.X + 6), 0, 0)
	end
	tabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(SyncTabCanvas)
	tabStrip.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseWheel then
			local MaxX = math.max(0, tabLayout.AbsoluteContentSize.X - tabStrip.AbsoluteSize.X + 6)
			tabStrip.CanvasPosition = Vector2.new(math.clamp(tabStrip.CanvasPosition.X - input.Position.Z * 48, 0, MaxX), 0)
		end
	end)
	SyncTabCanvas()
	local topLine = Make("Frame", {
		Parent = main,
		BackgroundColor3 = SecondaryColor,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, 35),
		Size = UDim2.new(1, 0, 0, 1)
	})
	BindTheme(topLine, "BackgroundColor3", "Secondary")
	local contentRoot = Make("Frame", {
		Parent = main,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 10, 0, 46),
		Size = UDim2.new(1, -20, 1, -76)
	})
	local footer = Make("Frame", {
		Parent = main,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 1, -24),
		Size = UDim2.new(1, 0, 0, 24)
	})
	local footerLine = Make("Frame", {
		Parent = footer,
		BackgroundColor3 = Color3.fromRGB(22, 22, 22),
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 1)
	})
	BindThemeCallback("Primary", function()
		if footerLine and footerLine.Parent then
			footerLine.BackgroundColor3 = Color3.fromRGB(math.clamp(PrimaryColor.R * 255 + 12, 0, 255), math.clamp(PrimaryColor.G * 255 + 12, 0, 255), math.clamp(PrimaryColor.B * 255 + 12, 0, 255))
		end
	end)
	local footerText = Make("TextLabel", {
		Parent = footer,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 8, 0, 2),
		Size = UDim2.new(0, 200, 0, 18),
		Font = Enum.Font.Code,
		Text = "version: ",
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = MutedText()
	})
	BindThemeCallback("Text", function()
		if footerText and footerText.Parent then
			footerText.TextColor3 = MutedText()
		end
	end)
	local footerAccent = Make("TextLabel", {
		Parent = footer,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 58, 0, 2),
		Size = UDim2.new(0, 120, 0, 18),
		Font = Enum.Font.Code,
		Text = "source",
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = SecondaryColor
	})
	BindTheme(footerAccent, "TextColor3", "Secondary")
	function lib:SetVersionStatus(status)
		local value = string.lower(tostring(status or "source"))
		footerAccent.Text = value == "secure" and "secure" or "source"
	end
	function lib:GetVersionStatus()
		return footerAccent.Text
	end
	local WindowSize = GetWindowTargetSize()
	local hidden = false
	local function ApplyWindowSize(Animated)
		WindowSize = GetWindowTargetSize()
		if hidden then return end
		local Target = UDim2.fromOffset(WindowSize.X, WindowSize.Y)
		if Animated then
			main:TweenSize(Target, Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.25, true)
		else
			main.Size = Target
		end
		main.Position = UDim2.fromScale(0.5, 0.5)
	end
	local function SetHidden(State)
		hidden = State and true or false
		if hidden then
			main:TweenSize(UDim2.fromOffset(WindowSize.X, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.2, true)
			task.delay(0.2, function() if hidden and main.Parent then main.Visible = false end end)
		else
			main.Visible = true
			ApplyWindowSize(true)
		end
	end
	main:TweenSize(UDim2.fromOffset(WindowSize.X, WindowSize.Y), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.35, true)
	MakeDraggable(topBar, main)
	UserInputService.InputBegan:Connect(function(io, p)
		if not p and io.KeyCode == CloseBind then SetHidden(not hidden) end
	end)
	if TouchMode then
		local MobileToggle = Make("TextButton", {
			Parent = ui,
			Name = "MobileToggle",
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 8, 0.5, 0),
			Size = UDim2.fromOffset(50, 50),
			BackgroundColor3 = PrimaryColor,
			BorderSizePixel = 0,
			Text = "SLR",
			Font = Enum.Font.Code,
			TextSize = 13,
			TextColor3 = TextColor,
			AutoButtonColor = false,
			ZIndex = 200
		})
		ApplyCorner(MobileToggle, 25)
		ApplyStroke(MobileToggle)
		BindTheme(MobileToggle, "BackgroundColor3", "Primary")
		BindTheme(MobileToggle, "TextColor3", "Text")
		MobileToggle.Activated:Connect(function() SetHidden(not hidden) end)
		local Minimize = Make("TextButton", {
			Parent = topBar,
			Name = "Minimize",
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -4, 0, 3),
			Size = UDim2.fromOffset(34, 30),
			BackgroundTransparency = 1,
			Text = "—",
			Font = Enum.Font.Code,
			TextSize = 18,
			TextColor3 = TextColor,
			ZIndex = 20
		})
		BindTheme(Minimize, "TextColor3", "Text")
		Minimize.Activated:Connect(function() SetHidden(true) end)
		appName.Size = UDim2.new(0, 112, 0, 20)
		tabStrip.Position = UDim2.new(0, 120, 0, 0)
		tabStrip.Size = UDim2.new(1, -160, 1, 0)
		local function CameraChanged()
			task.defer(function() if main and main.Parent then ApplyWindowSize(false) end end)
		end
		local function BindCamera(Camera)
			if Camera then Camera:GetPropertyChangedSignal("ViewportSize"):Connect(CameraChanged) end
		end
		BindCamera(workspace.CurrentCamera)
		workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function() BindCamera(workspace.CurrentCamera) CameraChanged() end)
	end
	local pages = Instance.new("Folder")
	pages.Name = "Pages"
	pages.Parent = contentRoot
	local selectedTabButton = nil
	local selectedPage = nil
	function lib:ChangeSecondaryColor(toch)
		local c = ToColor3(toch)
		if not c then return end
		SecondaryColor = c
		UpdateTheme("Secondary")
	end
	function lib:ChangePrimaryColor(toch)
		local c = ToColor3(toch)
		if not c then return end
		PrimaryColor = c
		UpdateTheme("Primary")
	end
	function lib:ChangePresetColor(toch)
		lib:ChangeSecondaryColor(toch)
	end
	function lib:ChangeTextColor(toch)
		local c = ToColor3(toch)
		if not c then return end
		TextColor = c
		UpdateTheme("Text")
	end
	function lib:GetPrimaryColor()
		return PrimaryColor
	end
	function lib:GetSecondaryColor()
		return SecondaryColor
	end
	function lib:GetTextColor()
		return TextColor
	end
	function lib:Notification(texttitle, textdesc, textbtn)
		local overlay = Make("TextButton", {
			Parent = main,
			BackgroundColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			AutoButtonColor = false,
			Text = "",
			Size = UDim2.new(1, 0, 1, 0),
			ZIndex = 100
		})
		Tween(overlay, 0.2, {BackgroundTransparency = 0.25})
		local box = Make("Frame", {
			Parent = overlay,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(0, 0, 0, 0),
			BackgroundColor3 = PrimaryColor,
			BorderSizePixel = 0,
			ZIndex = 101
		})
		BindTheme(box, "BackgroundColor3", "Primary")
		ApplyStroke(box)
		box:TweenSize(UDim2.new(0, 280, 0, 150), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.25, true)
		local titleLbl = Make("TextLabel", {
			Parent = box,
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 12, 0, 10),
			Size = UDim2.new(1, -24, 0, 18),
			Font = Enum.Font.Code,
			Text = tostring(texttitle or "Notification"),
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = SecondaryColor,
			ZIndex = 101
		})
		BindTheme(titleLbl, "TextColor3", "Secondary")
		local descLbl = Make("TextLabel", {
			Parent = box,
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 12, 0, 36),
			Size = UDim2.new(1, -24, 0, 62),
			Font = Enum.Font.Code,
			TextWrapped = true,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextXAlignment = Enum.TextXAlignment.Left,
			Text = tostring(textdesc or ""),
			TextSize = 13,
			TextColor3 = TextColor,
			ZIndex = 101
		})
		BindTheme(descLbl, "TextColor3", "Text")
		local ok = Make("TextButton", {
			Parent = box,
			BackgroundColor3 = PanelPrimary(),
			BorderSizePixel = 0,
			Position = UDim2.new(0, 12, 1, -42),
			Size = UDim2.new(1, -24, 0, 28),
			Text = tostring(textbtn or "Ok"),
			Font = Enum.Font.Code,
			TextSize = 13,
			TextColor3 = TextColor,
			ZIndex = 101,
			AutoButtonColor = false
		})
		BindThemeCallback("Primary", function()
			if ok and ok.Parent then
				ok.BackgroundColor3 = PanelPrimary()
			end
		end)
		BindTheme(ok, "TextColor3", "Text")
		ApplyStroke(ok)
		ok.MouseEnter:Connect(function()
			Tween(ok, 0.12, {BackgroundColor3 = HoverPrimary()})
		end)
		ok.MouseLeave:Connect(function()
			Tween(ok, 0.12, {BackgroundColor3 = PanelPrimary()})
		end)
		ok.Activated:Connect(function()
			Tween(overlay, 0.15, {BackgroundTransparency = 1})
			box:TweenSize(UDim2.new(0, 0, 0, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.18, true)
			task.delay(0.18, function()
				overlay:Destroy()
			end)
		end)
	end
	local tabhold = {}
	function tabhold:Tab(name)
		local tabWidth = math.max(58, (#tostring(name) * 8) + 22)
		local button = Make("TextButton", {
			Parent = tabStrip,
			BackgroundTransparency = 1,
			Size = UDim2.new(0, tabWidth, 1, 0),
			AutoButtonColor = false,
			Text = "",
			Font = Enum.Font.Code,
			TextSize = 13
		})
		local selection = Make("Frame", {
			Parent = button,
			BackgroundColor3 = SecondaryColor,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 4, 0, 5),
			Size = UDim2.new(1, -8, 1, -10)
		})
		ApplyCorner(selection, 4)
		BindTheme(selection, "BackgroundColor3", "Secondary")
		local buttonLabel = Make("TextLabel", {
			Parent = button,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, -2),
			Font = Enum.Font.Code,
			Text = tostring(name),
			TextSize = 13,
			TextColor3 = MutedText()
		})
		local indicator = Make("Frame", {
			Parent = button,
			BackgroundColor3 = SecondaryColor,
			BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.new(0.5, 0, 1, 0),
			Size = UDim2.new(0, 0, 0, 2)
		})
		BindTheme(indicator, "BackgroundColor3", "Secondary")
		local page = Make("Frame", {
			Parent = pages,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
			Visible = false
		})
		local leftPanel, leftScroll = CreateScrollingPanel(page, TouchMode and UDim2.new(1, 0, 1, 0) or UDim2.new(0.5, -5, 1, 0), UDim2.new(0, 0, 0, 0), name)
		local rightPanel, rightScroll = CreateScrollingPanel(page, UDim2.new(0.5, -5, 1, 0), UDim2.new(0.5, 5, 0, 0), "Options")
		if TouchMode then rightPanel.Visible = false end
		local leftWeight = 0
		local rightWeight = 0
		local sectionParent = nil
		local function weightFor(kind)
			if kind == "Slider" then
				return 56
			elseif kind == "Label" then
				return 30
			end
			return 39
		end
		local function addWeight(parent, amount)
			if parent == leftScroll then
				leftWeight += amount
			else
				rightWeight += amount
			end
		end
		local function chooseContentParent(kind)
			if TouchMode then
				addWeight(leftScroll, weightFor(kind))
				return leftScroll
			end
			if kind == "Label" then
				sectionParent = leftWeight <= rightWeight and leftScroll or rightScroll
				addWeight(sectionParent, weightFor(kind))
				return sectionParent
			end
			if sectionParent then
				addWeight(sectionParent, weightFor(kind))
				return sectionParent
			end
			local parent = leftWeight <= rightWeight and leftScroll or rightScroll
			addWeight(parent, weightFor(kind))
			return parent
		end
		local function selectThisTab()
			if selectedPage then
				selectedPage.Visible = false
			end
			if selectedTabButton and selectedTabButton:FindFirstChild("Label") then
				Tween(selectedTabButton.Label, 0.12, {TextColor3 = MutedText()})
				Tween(selectedTabButton.Selection, 0.12, {BackgroundTransparency = 1})
				selectedTabButton.Indicator:TweenSize(UDim2.new(0, 0, 0, 2), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.12, true)
			end
			selectedPage = page
			selectedTabButton = button
			page.Visible = true
			Tween(buttonLabel, 0.12, {TextColor3 = TextColor})
			Tween(selection, 0.12, {BackgroundTransparency = 0.88})
			indicator:TweenSize(UDim2.new(0.7, 0, 0, 2), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.12, true)
			task.defer(function()
				local Left = button.AbsolutePosition.X - tabStrip.AbsolutePosition.X + tabStrip.CanvasPosition.X
				local Right = Left + button.AbsoluteSize.X
				local ViewLeft = tabStrip.CanvasPosition.X
				local ViewRight = ViewLeft + tabStrip.AbsoluteSize.X
				if Left < ViewLeft then tabStrip.CanvasPosition = Vector2.new(math.max(0, Left - 6), 0) elseif Right > ViewRight then tabStrip.CanvasPosition = Vector2.new(math.max(0, Right - tabStrip.AbsoluteSize.X + 6), 0) end
			end)
		end
		button.Name = "TabButton"
		buttonLabel.Name = "Label"
		selection.Name = "Selection"
		indicator.Name = "Indicator"
		button.MouseEnter:Connect(function()
			if selectedTabButton ~= button then
				Tween(selection, 0.12, {BackgroundTransparency = 0.95})
			end
		end)
		button.MouseLeave:Connect(function()
			if selectedTabButton ~= button then
				Tween(selection, 0.12, {BackgroundTransparency = 1})
			end
		end)
		button.Activated:Connect(selectThisTab)
		if not selectedPage then
			selectThisTab()
		end
		local tabcontent = {}
		function tabcontent:Button(text, callback)
			local currentText = tostring(text)
			local parent = chooseContentParent("Button")
			local buttonFrame = CreateBaseItem(parent, 32)
			local click = Make("TextButton", {
				Parent = buttonFrame,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 1, 0),
				AutoButtonColor = false,
				Text = ""
			})
			local label = Make("TextLabel", {
				Parent = buttonFrame,
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 10, 0, 0),
				Size = UDim2.new(1, -20, 1, 0),
				Font = Enum.Font.Code,
				Text = currentText,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextColor3 = TextColor
			})
			BindTheme(label, "TextColor3", "Text")
			click.MouseEnter:Connect(function()
				Tween(buttonFrame, 0.12, {BackgroundColor3 = HoverPrimary()})
			end)
			click.MouseLeave:Connect(function()
				Tween(buttonFrame, 0.12, {BackgroundColor3 = PanelPrimary()})
			end)
			click.Activated:Connect(function()
				pcall(callback)
			end)
			local api = {}
			function api:GetCurrentValue()
				return currentText
			end
			function api:SetCurrentValue(value, fire)
				currentText = tostring(value)
				label.Text = currentText
				if fire ~= false then
					pcall(callback)
				end
			end
			return api
		end
		function tabcontent:Toggle(text, default, callback)
			local state = default and true or false
			local parent = chooseContentParent("Toggle")
			local toggleFrame = CreateBaseItem(parent, 32)
			local hit = Make("TextButton", {
				Parent = toggleFrame,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 1, 0),
				Text = "",
				AutoButtonColor = false
			})
			local label = Make("TextLabel", {
				Parent = toggleFrame,
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 10, 0, 0),
				Size = UDim2.new(1, -60, 1, 0),
				Font = Enum.Font.Code,
				Text = tostring(text),
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextColor3 = TextColor
			})
			BindTheme(label, "TextColor3", "Text")
			local switch = Make("Frame", {
				Parent = toggleFrame,
				BackgroundColor3 = Color3.fromRGB(16, 16, 16),
				BorderSizePixel = 0,
				Position = UDim2.new(1, -50, 0.5, -8),
				Size = UDim2.new(0, 38, 0, 16)
			})
			ApplyStroke(switch, Color3.fromRGB(36, 36, 36))
			local fill = Make("Frame", {
				Parent = switch,
				BackgroundColor3 = SecondaryColor,
				BorderSizePixel = 0,
				Size = UDim2.new(0, 0, 1, 0)
			})
			BindTheme(fill, "BackgroundColor3", "Secondary")
			local knob = Make("Frame", {
				Parent = switch,
				BackgroundColor3 = Color3.fromRGB(210, 210, 210),
				BorderSizePixel = 0,
				Position = UDim2.new(0, 2, 0, 2),
				Size = UDim2.new(0, 12, 0, 12)
			})
			local function apply()
				if state then
					fill:TweenSize(UDim2.new(1, 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.12, true)
					knob:TweenPosition(UDim2.new(1, -14, 0, 2), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.12, true)
				else
					fill:TweenSize(UDim2.new(0, 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.12, true)
					knob:TweenPosition(UDim2.new(0, 2, 0, 2), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.12, true)
				end
			end
			apply()
			hit.Activated:Connect(function()
				state = not state
				apply()
				pcall(callback, state)
			end)
			local api = {}
			function api:GetCurrentValue()
				return state
			end
			function api:SetCurrentValue(value, fire)
				state = value and true or false
				apply()
				if fire ~= false then
					pcall(callback, state)
				end
			end
			return api
		end
		function tabcontent:Slider(text, min, max, start, callback)
			local parent = chooseContentParent("Slider")
			min = tonumber(min) or 0
			max = tonumber(max) or 100
			local currentValue = math.clamp(tonumber(start) or min, min, max)
			local sliderFrame = CreateBaseItem(parent, 48)
			local label = Make("TextLabel", {
				Parent = sliderFrame,
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 10, 0, 4),
				Size = UDim2.new(1, -60, 0, 14),
				Font = Enum.Font.Code,
				Text = tostring(text),
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextColor3 = TextColor
			})
			BindTheme(label, "TextColor3", "Text")
			local valueLabel = Make("TextLabel", {
				Parent = sliderFrame,
				BackgroundTransparency = 1,
				Position = UDim2.new(1, -60, 0, 4),
				Size = UDim2.new(0, 50, 0, 14),
				Font = Enum.Font.Code,
				Text = tostring(currentValue),
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Right,
				TextColor3 = TextColor
			})
			BindTheme(valueLabel, "TextColor3", "Text")
			local bar = Make("Frame", {
				Parent = sliderFrame,
				BackgroundColor3 = Color3.fromRGB(16, 16, 16),
				BorderSizePixel = 0,
				Position = UDim2.new(0, 10, 1, -15),
				Size = UDim2.new(1, -20, 0, 5)
			})
			ApplyStroke(bar, Color3.fromRGB(30, 30, 30))
			local fill = Make("Frame", {
				Parent = bar,
				BackgroundColor3 = SecondaryColor,
				BorderSizePixel = 0,
				Size = UDim2.new(0, 0, 1, 0)
			})
			BindTheme(fill, "BackgroundColor3", "Secondary")
			local knob = Make("Frame", {
				Parent = bar,
				BackgroundColor3 = SecondaryColor,
				BorderSizePixel = 0,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0, 0, 0.5, 0),
				Size = UDim2.new(0, 8, 0, 8)
			})
			BindTheme(knob, "BackgroundColor3", "Secondary")
			local dragging = false
			local dragInput = nil
			local touchHit = Make("Frame", {Parent = bar, BackgroundTransparency = 1, Active = true, Position = UDim2.new(0, 0, 0.5, -18), Size = UDim2.new(1, 0, 0, 36), ZIndex = 2})
			local function setValue(v, fire)
				currentValue = math.clamp(math.floor(v + 0.5), min, max)
				local alpha = max == min and 0 or (currentValue - min) / (max - min)
				fill.Size = UDim2.new(alpha, 0, 1, 0)
				knob.Position = UDim2.new(alpha, 0, 0.5, 0)
				valueLabel.Text = tostring(currentValue)
				if fire then
					pcall(callback, currentValue)
				end
			end
			setValue(currentValue, false)
			local function move(input)
				local alpha = math.clamp((input.Position.X - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1), 0, 1)
				setValue(min + ((max - min) * alpha), true)
			end
			local function beginDrag(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = true
					dragInput = input
					move(input)
				end
			end
			touchHit.InputBegan:Connect(beginDrag)
			bar.InputBegan:Connect(beginDrag)
			UserInputService.InputEnded:Connect(function(input)
				if input == dragInput or input.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = false
					dragInput = nil
				end
			end)
			UserInputService.InputChanged:Connect(function(input)
				if dragging and (input == dragInput or input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then move(input) end
			end)
			local api = {}
			function api:GetCurrentValue()
				return currentValue
			end
			function api:SetCurrentValue(value, fire)
				setValue(value, fire ~= false)
			end
			return api
		end
		function tabcontent:Dropdown(text, list, callback)
			local parent = chooseContentParent("Dropdown")
			local currentList = list or {}
			local selectedValue = nil
			local opened = false
			local closedHeight = 36
			local dropdownFrame = CreateBaseItem(parent, closedHeight)
			local title = Make("TextLabel", {
				Parent = dropdownFrame,
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 10, 0, 0),
				Size = UDim2.new(0.52, -10, 0, closedHeight),
				Font = Enum.Font.Code,
				Text = tostring(text),
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextColor3 = TextColor,
				TextTruncate = Enum.TextTruncate.AtEnd
			})
			BindTheme(title, "TextColor3", "Text")
			local selected = Make("TextLabel", {
				Parent = dropdownFrame,
				BackgroundTransparency = 1,
				Position = UDim2.new(0.52, 0, 0, 0),
				Size = UDim2.new(0.48, -30, 0, closedHeight),
				Font = Enum.Font.Code,
				Text = "",
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Right,
				TextColor3 = MutedText(),
				TextTruncate = Enum.TextTruncate.AtEnd
			})
			BindThemeCallback("Text", function()
				if selected and selected.Parent then
					selected.TextColor3 = MutedText()
				end
			end)
			local arrow = Make("TextLabel", {
				Parent = dropdownFrame,
				BackgroundTransparency = 1,
				Position = UDim2.new(1, -24, 0, 0),
				Size = UDim2.new(0, 24, 0, closedHeight),
				Font = Enum.Font.Code,
				Text = "+",
				TextSize = 14,
				TextColor3 = SecondaryColor
			})
			BindTheme(arrow, "TextColor3", "Secondary")
			local hit = Make("TextButton", {
				Parent = dropdownFrame,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, closedHeight),
				Text = "",
				AutoButtonColor = false,
				ZIndex = 3
			})
			local divider = Make("Frame", {
				Parent = dropdownFrame,
				BackgroundColor3 = BorderColor(),
				BorderSizePixel = 0,
				Position = UDim2.new(0, 8, 0, closedHeight),
				Size = UDim2.new(1, -16, 0, 1),
				Visible = false
			})
			BindThemeCallback("Primary", function()
				if divider and divider.Parent then
					divider.BackgroundColor3 = BorderColor()
				end
			end)
			local listHolder = Make("ScrollingFrame", {
				Parent = dropdownFrame,
				BackgroundColor3 = PanelSecondary(),
				BackgroundTransparency = 0,
				Position = UDim2.new(0, 6, 0, closedHeight + 5),
				Size = UDim2.new(1, -12, 0, 0),
				CanvasSize = UDim2.new(),
				BorderSizePixel = 0,
				ScrollBarThickness = 2,
				TopImage = "rbxassetid://0",
				MidImage = "rbxassetid://0",
				BottomImage = "rbxassetid://0",
				ScrollBarImageColor3 = SecondaryColor,
				ZIndex = 4
			})
			ApplyCorner(listHolder, 3)
			ApplyStroke(listHolder)
			BindTheme(listHolder, "ScrollBarImageColor3", "Secondary")
			BindThemeCallback("Primary", function()
				if listHolder and listHolder.Parent then
					listHolder.BackgroundColor3 = PanelSecondary()
				end
			end)
			local listLayout = CreateList(listHolder, 2)
			ApplyPadding(listHolder, 4, 4, 4, 4)
			SyncCanvas(listHolder, listLayout, 8)
			local function menuHeight()
				if #currentList == 0 then
					return 0
				end
				return math.min(#currentList * (TouchMode and 38 or 28) + 8, TouchMode and 190 or 120)
			end
			local function setOpened(value)
				opened = value and #currentList > 0
				arrow.Text = opened and "-" or "+"
				divider.Visible = opened
				local height = opened and menuHeight() or 0
				dropdownFrame:TweenSize(UDim2.new(1, 0, 0, opened and (closedHeight + height + 9) or closedHeight), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.12, true)
				listHolder:TweenSize(UDim2.new(1, -12, 0, height), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.12, true)
			end
			local function rebuild()
				for _, child in ipairs(listHolder:GetChildren()) do
					if child:IsA("GuiObject") then
						child:Destroy()
					end
				end
				for _, value in ipairs(currentList) do
					local item = Make("TextButton", {
						Parent = listHolder,
						BackgroundColor3 = PanelSecondary(),
						BorderSizePixel = 0,
						Size = UDim2.new(1, 0, 0, TouchMode and 36 or 26),
						Text = tostring(value),
						Font = Enum.Font.Code,
						TextSize = 12,
						TextColor3 = value == selectedValue and SecondaryColor or TextColor,
						TextXAlignment = Enum.TextXAlignment.Left,
						AutoButtonColor = false,
						ZIndex = 5
					})
					ApplyCorner(item, 3)
					ApplyPadding(item, 8, 8, 0, 0)
					BindThemeCallback("Primary", function()
						if item and item.Parent then
							item.BackgroundColor3 = PanelSecondary()
						end
					end)
					BindThemeCallback("Text", function()
						if item and item.Parent and value ~= selectedValue then
							item.TextColor3 = TextColor
						end
					end)
					BindThemeCallback("Secondary", function()
						if item and item.Parent and value == selectedValue then
							item.TextColor3 = SecondaryColor
						end
					end)
					item.MouseEnter:Connect(function()
						Tween(item, 0.1, {BackgroundColor3 = HoverPrimary()})
					end)
					item.MouseLeave:Connect(function()
						Tween(item, 0.1, {BackgroundColor3 = PanelSecondary()})
					end)
					item.Activated:Connect(function()
						selectedValue = value
						selected.Text = tostring(value)
						setOpened(false)
						rebuild()
						pcall(callback, value)
					end)
				end
			end
			rebuild()
			hit.Activated:Connect(function()
				setOpened(not opened)
			end)
			local api = {}
			function api:UpdateList(newList)
				currentList = newList or {}
				if selectedValue ~= nil and not table.find(currentList, selectedValue) then
					selectedValue = nil
					selected.Text = ""
				end
				setOpened(false)
				rebuild()
			end
			function api:UpdateSelected(value)
				selectedValue = value
				selected.Text = value and tostring(value) or ""
				rebuild()
			end
			function api:GetCurrentValue()
				return selectedValue
			end
			function api:SetCurrentValue(value, fire)
				selectedValue = value
				selected.Text = value and tostring(value) or ""
				rebuild()
				if fire ~= false then
					pcall(callback, value)
				end
			end
			return api
		end
		function tabcontent:MultiDropdown(text, list, currentListArg, callback)
			local parent = chooseContentParent("MultiDropdown")
			local currentList = list or {}
			local currentValues = currentListArg or {}
			local opened = false
			local closedHeight = 36
			local frame = CreateBaseItem(parent, closedHeight)
			local title = Make("TextLabel", {
				Parent = frame,
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 10, 0, 0),
				Size = UDim2.new(0.5, -10, 0, closedHeight),
				Font = Enum.Font.Code,
				Text = tostring(text),
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextColor3 = TextColor,
				TextTruncate = Enum.TextTruncate.AtEnd
			})
			BindTheme(title, "TextColor3", "Text")
			local selected = Make("TextLabel", {
				Parent = frame,
				BackgroundTransparency = 1,
				Position = UDim2.new(0.5, 0, 0, 0),
				Size = UDim2.new(0.5, -30, 0, closedHeight),
				Font = Enum.Font.Code,
				Text = table.concat(currentValues, ", "),
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Right,
				TextColor3 = MutedText(),
				TextTruncate = Enum.TextTruncate.AtEnd
			})
			BindThemeCallback("Text", function()
				if selected and selected.Parent then
					selected.TextColor3 = MutedText()
				end
			end)
			local arrow = Make("TextLabel", {
				Parent = frame,
				BackgroundTransparency = 1,
				Position = UDim2.new(1, -24, 0, 0),
				Size = UDim2.new(0, 24, 0, closedHeight),
				Font = Enum.Font.Code,
				Text = "+",
				TextSize = 14,
				TextColor3 = SecondaryColor
			})
			BindTheme(arrow, "TextColor3", "Secondary")
			local hit = Make("TextButton", {
				Parent = frame,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, closedHeight),
				Text = "",
				AutoButtonColor = false,
				ZIndex = 3
			})
			local divider = Make("Frame", {
				Parent = frame,
				BackgroundColor3 = BorderColor(),
				BorderSizePixel = 0,
				Position = UDim2.new(0, 8, 0, closedHeight),
				Size = UDim2.new(1, -16, 0, 1),
				Visible = false
			})
			BindThemeCallback("Primary", function()
				if divider and divider.Parent then
					divider.BackgroundColor3 = BorderColor()
				end
			end)
			local listHolder = Make("ScrollingFrame", {
				Parent = frame,
				BackgroundColor3 = PanelSecondary(),
				BackgroundTransparency = 0,
				Position = UDim2.new(0, 6, 0, closedHeight + 5),
				Size = UDim2.new(1, -12, 0, 0),
				CanvasSize = UDim2.new(),
				BorderSizePixel = 0,
				ScrollBarThickness = 2,
				TopImage = "rbxassetid://0",
				MidImage = "rbxassetid://0",
				BottomImage = "rbxassetid://0",
				ScrollBarImageColor3 = SecondaryColor,
				ZIndex = 4
			})
			ApplyCorner(listHolder, 3)
			ApplyStroke(listHolder)
			BindTheme(listHolder, "ScrollBarImageColor3", "Secondary")
			BindThemeCallback("Primary", function()
				if listHolder and listHolder.Parent then
					listHolder.BackgroundColor3 = PanelSecondary()
				end
			end)
			local listLayout = CreateList(listHolder, 2)
			ApplyPadding(listHolder, 4, 4, 4, 4)
			SyncCanvas(listHolder, listLayout, 8)
			local function syncText()
				selected.Text = table.concat(currentValues, ", ")
			end
			local function menuHeight()
				if #currentList == 0 then
					return 0
				end
				return math.min(#currentList * (TouchMode and 38 or 28) + 8, TouchMode and 190 or 120)
			end
			local function setOpened(value)
				opened = value and #currentList > 0
				arrow.Text = opened and "-" or "+"
				divider.Visible = opened
				local height = opened and menuHeight() or 0
				frame:TweenSize(UDim2.new(1, 0, 0, opened and (closedHeight + height + 9) or closedHeight), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.12, true)
				listHolder:TweenSize(UDim2.new(1, -12, 0, height), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.12, true)
			end
			local function rebuild()
				for _, child in ipairs(listHolder:GetChildren()) do
					if child:IsA("GuiObject") then
						child:Destroy()
					end
				end
				for _, value in ipairs(currentList) do
					local item = Make("TextButton", {
						Parent = listHolder,
						BackgroundColor3 = PanelSecondary(),
						BorderSizePixel = 0,
						Size = UDim2.new(1, 0, 0, TouchMode and 36 or 26),
						Text = tostring(value),
						Font = Enum.Font.Code,
						TextSize = 12,
						TextColor3 = TextColor,
						TextXAlignment = Enum.TextXAlignment.Left,
						AutoButtonColor = false,
						ZIndex = 5
					})
					ApplyCorner(item, 3)
					ApplyPadding(item, 28, 8, 0, 0)
					BindTheme(item, "TextColor3", "Text")
					BindThemeCallback("Primary", function()
						if item and item.Parent then
							item.BackgroundColor3 = PanelSecondary()
						end
					end)
					local marker = Make("Frame", {
						Parent = item,
						BackgroundColor3 = PrimaryColor,
						BorderSizePixel = 0,
						Position = UDim2.new(0, -20, 0.5, -6),
						Size = UDim2.new(0, 12, 0, 12),
						ZIndex = 6
					})
					ApplyCorner(marker, 2)
					ApplyStroke(marker)
					BindTheme(marker, "BackgroundColor3", "Primary")
					local markFill = Make("Frame", {
						Parent = marker,
						BackgroundColor3 = SecondaryColor,
						BorderSizePixel = 0,
						Position = UDim2.new(0, 2, 0, 2),
						Size = UDim2.new(1, -4, 1, -4),
						Visible = table.find(currentValues, value) ~= nil,
						ZIndex = 7
					})
					ApplyCorner(markFill, 1)
					BindTheme(markFill, "BackgroundColor3", "Secondary")
					item.MouseEnter:Connect(function()
						Tween(item, 0.1, {BackgroundColor3 = HoverPrimary()})
					end)
					item.MouseLeave:Connect(function()
						Tween(item, 0.1, {BackgroundColor3 = PanelSecondary()})
					end)
					item.Activated:Connect(function()
						local index = table.find(currentValues, value)
						if index then
							table.remove(currentValues, index)
						else
							table.insert(currentValues, value)
						end
						markFill.Visible = table.find(currentValues, value) ~= nil
						syncText()
						pcall(callback, currentValues)
					end)
				end
			end
			rebuild()
			hit.Activated:Connect(function()
				setOpened(not opened)
			end)
			local api = {}
			function api:UpdateList(newList)
				currentList = newList or {}
				setOpened(false)
				rebuild()
			end
			function api:UpdateCurrentList(newCurrentList)
				currentValues = newCurrentList or {}
				syncText()
				rebuild()
			end
			function api:GetCurrentValue()
				local copy = {}
				for i, v in ipairs(currentValues) do
					copy[i] = v
				end
				return copy
			end
			function api:SetCurrentValue(values, fire)
				currentValues = values or {}
				syncText()
				rebuild()
				if fire ~= false then
					pcall(callback, currentValues)
				end
			end
			return api
		end
		function tabcontent:Colorpicker(text, preset, callback)
			local parent = chooseContentParent("Colorpicker")
			local currentColor = ToColor3(preset) or SecondaryColor
			local pickerFrame = CreateBaseItem(parent, 32)
			local label = Make("TextLabel", {
				Parent = pickerFrame,
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 10, 0, 0),
				Size = UDim2.new(1, -46, 1, 0),
				Font = Enum.Font.Code,
				Text = tostring(text),
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextColor3 = TextColor
			})
			BindTheme(label, "TextColor3", "Text")
			local swatch = Make("TextButton", {
				Parent = pickerFrame,
				BackgroundColor3 = currentColor,
				BorderSizePixel = 0,
				Position = UDim2.new(1, -28, 0.5, -9),
				Size = UDim2.new(0, 18, 0, 18),
				Text = "",
				AutoButtonColor = false
			})
			ApplyStroke(swatch, Color3.fromRGB(34, 34, 34))
			local popup = CreatePopupHolder(main)
			popup.Size = UDim2.new(0, 190, 0, 214)
			local sat = Make("ImageLabel", {
				Parent = popup,
				BackgroundColor3 = Color3.fromRGB(255, 0, 0),
				BorderSizePixel = 0,
				Position = UDim2.new(0, 10, 0, 10),
				Size = UDim2.new(0, 130, 0, 130),
				Image = "rbxassetid://4155801252"
			})
			local satCursor = Make("Frame", {
				Parent = sat,
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = Color3.new(1, 1, 1),
				BorderSizePixel = 0,
				Size = UDim2.new(0, 6, 0, 6)
			})
			local hue = Make("ImageLabel", {
				Parent = popup,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BorderSizePixel = 0,
				Position = UDim2.new(0, 148, 0, 10),
				Size = UDim2.new(0, 18, 0, 130),
				Image = "rbxassetid://3641079629"
			})
			local hueCursor = Make("Frame", {
				Parent = hue,
				BackgroundColor3 = Color3.new(1, 1, 1),
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 2)
			})
			local rainbow = Make("TextButton", {
				Parent = popup,
				BackgroundColor3 = PanelPrimary(),
				BorderSizePixel = 0,
				Position = UDim2.new(0, 10, 0, 150),
				Size = UDim2.new(1, -20, 0, 24),
				Text = "Rainbow: Off",
				Font = Enum.Font.Code,
				TextSize = 13,
				TextColor3 = TextColor,
				AutoButtonColor = false
			})
			BindThemeCallback("Primary", function()
				if rainbow and rainbow.Parent then
					rainbow.BackgroundColor3 = PanelPrimary()
				end
			end)
			BindTheme(rainbow, "TextColor3", "Text")
			ApplyStroke(rainbow)
			local out = Make("TextBox", {
				Parent = popup,
				BackgroundColor3 = PanelPrimary(),
				BorderSizePixel = 0,
				Position = UDim2.new(0, 10, 0, 182),
				Size = UDim2.new(1, -20, 0, 22),
				Text = "",
				PlaceholderText = "R, G, B",
				ClearTextOnFocus = false,
				Font = Enum.Font.Code,
				TextSize = 13,
				TextColor3 = TextColor
			})
			BindThemeCallback("Primary", function()
				if out and out.Parent then
					out.BackgroundColor3 = PanelPrimary()
				end
			end)
			BindTheme(out, "TextColor3", "Text")
			ApplyStroke(out)
			local draggingSat = false
			local draggingHue = false
			local rainbowEnabled = false
			local rainbowConnection = nil
			local hueValue, satValue, valValue = currentColor:ToHSV()
			local function applyFromHSV(fire)
				currentColor = Color3.fromHSV(hueValue, satValue, valValue)
				sat.BackgroundColor3 = Color3.fromHSV(hueValue, 1, 1)
				swatch.BackgroundColor3 = currentColor
				satCursor.Position = UDim2.new(satValue, 0, 1 - valValue, 0)
				hueCursor.Position = UDim2.new(0, 0, hueValue, -1)
				out.Text = string.format("%d, %d, %d", math.floor(currentColor.R * 255), math.floor(currentColor.G * 255), math.floor(currentColor.B * 255))
				if fire then
					pcall(callback, currentColor)
				end
			end
			applyFromHSV(false)
			local function openPopup()
				popup.Position = UDim2.new(0, pickerFrame.AbsolutePosition.X - main.AbsolutePosition.X + pickerFrame.AbsoluteSize.X - 190, 0, pickerFrame.AbsolutePosition.Y - main.AbsolutePosition.Y + 32)
				popup.Visible = not popup.Visible
			end
			swatch.Activated:Connect(openPopup)
			local satInput = nil
			local hueInput = nil
			sat.Active = true
			hue.Active = true
			sat.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingSat = true satInput = input end
			end)
			hue.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingHue = true hueInput = input end
			end)
			UserInputService.InputEnded:Connect(function(input)
				if input == satInput or input.UserInputType == Enum.UserInputType.MouseButton1 then draggingSat = false satInput = nil end
				if input == hueInput or input.UserInputType == Enum.UserInputType.MouseButton1 then draggingHue = false hueInput = nil end
			end)
			UserInputService.InputChanged:Connect(function(input)
				if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
				if draggingSat and (not satInput or input == satInput or input.UserInputType == Enum.UserInputType.MouseMovement) then
					local x = math.clamp((input.Position.X - sat.AbsolutePosition.X) / sat.AbsoluteSize.X, 0, 1)
					local y = math.clamp((input.Position.Y - sat.AbsolutePosition.Y) / sat.AbsoluteSize.Y, 0, 1)
					satValue = x
					valValue = 1 - y
					applyFromHSV(true)
				elseif draggingHue and (not hueInput or input == hueInput or input.UserInputType == Enum.UserInputType.MouseMovement) then
					hueValue = math.clamp((input.Position.Y - hue.AbsolutePosition.Y) / hue.AbsoluteSize.Y, 0, 1)
					applyFromHSV(true)
				end
			end)
			rainbow.Activated:Connect(function()
				rainbowEnabled = not rainbowEnabled
				rainbow.Text = rainbowEnabled and "Rainbow: On" or "Rainbow: Off"
				if rainbowConnection then
					rainbowConnection:Disconnect()
					rainbowConnection = nil
				end
				if rainbowEnabled then
					rainbowConnection = RunService.RenderStepped:Connect(function()
						hueValue = (tick() * 0.15) % 1
						applyFromHSV(true)
					end)
				end
			end)
			out.FocusLost:Connect(function(enterPressed)
				if enterPressed then
					local newColor = ToColor3(out.Text)
					if newColor then
						hueValue, satValue, valValue = newColor:ToHSV()
						applyFromHSV(true)
					end
				end
			end)
			local api = {}
			function api:GetCurrentValue()
				return currentColor
			end
			function api:SetCurrentValue(value, fire)
				local newColor = ToColor3(value)
				if not newColor then
					return
				end
				hueValue, satValue, valValue = newColor:ToHSV()
				applyFromHSV(fire ~= false)
			end
			return api
		end
		function tabcontent:Label(text)
			local currentText = tostring(text)
			local parent = chooseContentParent("Label")
			local item = Make("Frame", {
				Parent = parent,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 24)
			})
			local accent = Make("Frame", {
				Parent = item,
				BackgroundColor3 = SecondaryColor,
				BorderSizePixel = 0,
				Position = UDim2.new(0, 0, 0.5, -6),
				Size = UDim2.new(0, 2, 0, 12)
			})
			BindTheme(accent, "BackgroundColor3", "Secondary")
			local label = Make("TextLabel", {
				Parent = item,
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 9, 0, 0),
				Size = UDim2.new(1, -9, 1, 0),
				Font = Enum.Font.Code,
				Text = currentText,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextColor3 = SecondaryColor
			})
			BindTheme(label, "TextColor3", "Secondary")
			local api = {}
			function api:Set(newText)
				currentText = tostring(newText)
				pcall(function() label.Text = currentText end)
			end
			function api:GetCurrentValue()
				return currentText
			end
			function api:SetCurrentValue(value)
				currentText = tostring(value)
				pcall(function() label.Text = currentText end)
			end
			return api
		end
		function tabcontent:Textbox(text, disapper, callback)
			local parent = chooseContentParent("Textbox")
			local item = CreateBaseItem(parent, 32)
			local label = Make("TextLabel", {
				Parent = item,
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 10, 0, 0),
				Size = UDim2.new(0.35, 0, 1, 0),
				Font = Enum.Font.Code,
				Text = tostring(text),
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextColor3 = TextColor
			})
			BindTheme(label, "TextColor3", "Text")
			local box = Make("TextBox", {
				Parent = item,
				BackgroundTransparency = 1,
				Position = UDim2.new(0.35, 0, 0, 0),
				Size = UDim2.new(0.65, -10, 1, 0),
				Font = Enum.Font.Code,
				Text = "",
				TextSize = 13,
				ClearTextOnFocus = false,
				TextXAlignment = Enum.TextXAlignment.Right,
				TextColor3 = MutedText(),
				PlaceholderText = "..."
			})
			BindThemeCallback("Text", function()
				if box and box.Parent then
					box.TextColor3 = MutedText()
				end
			end)
			box.FocusLost:Connect(function(ep)
				if ep and #box.Text > 0 then
					pcall(callback, box.Text)
					if disapper then
						box.Text = ""
					end
				end
			end)
			local api = {}
			function api:GetCurrentValue()
				return box.Text
			end
			function api:SetCurrentValue(value, fire)
				box.Text = tostring(value or "")
				if fire ~= false and #box.Text > 0 then
					pcall(callback, box.Text)
				end
			end
			return api
		end
		function tabcontent:Bind(text, keypreset, callback)
			local parent = chooseContentParent("Bind")
			local key = (keypreset and keypreset.Name) or "Unknown"
			local waiting = false
			local item = CreateBaseItem(parent, 32)
			local hit = Make("TextButton", {
				Parent = item,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 1, 0),
				Text = "",
				AutoButtonColor = false
			})
			local label = Make("TextLabel", {
				Parent = item,
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 10, 0, 0),
				Size = UDim2.new(0.5, 0, 1, 0),
				Font = Enum.Font.Code,
				Text = tostring(text),
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextColor3 = TextColor
			})
			BindTheme(label, "TextColor3", "Text")
			local keyLabel = Make("TextLabel", {
				Parent = item,
				BackgroundTransparency = 1,
				Position = UDim2.new(0.5, 0, 0, 0),
				Size = UDim2.new(0.5, -10, 1, 0),
				Font = Enum.Font.Code,
				Text = key,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Right,
				TextColor3 = SecondaryColor
			})
			BindTheme(keyLabel, "TextColor3", "Secondary")
			if TouchMode then keyLabel.Text = "TAP" end
			hit.Activated:Connect(function()
				if TouchMode then pcall(callback) return end
				if waiting then return end
				waiting = true
				keyLabel.Text = "..."
				local input = UserInputService.InputBegan:Wait()
				if input.KeyCode and input.KeyCode ~= Enum.KeyCode.Unknown then key = input.KeyCode.Name end
				keyLabel.Text = key
				waiting = false
			end)
			UserInputService.InputBegan:Connect(function(current, pressed)
				if not TouchMode and not pressed and not waiting and current.KeyCode.Name == key then
					pcall(callback)
				end
			end)
			local api = {}
			function api:GetCurrentValue()
				return key
			end
			function api:SetCurrentValue(value, fire)
				key = tostring(value)
				keyLabel.Text = key
				if fire ~= false then
					pcall(callback)
				end
			end
			return api
		end
		return tabcontent
	end
	return tabhold
end
return lib
