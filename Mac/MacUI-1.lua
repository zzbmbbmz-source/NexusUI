--[[
	MacUI — macOS-inspired Production UI Library for Roblox (Luau)
	Single-file, loadstring-ready.

	Usage:
		local Library = loadstring(game:HttpGet("URL"))()
		local Window = Library:CreateWindow({ Title = "MacUI", Subtitle = "v1.0", Version = "1.0" })
		local Tab = Window:CreateTab("Home")
		local Section = Tab:CreateSection("General")
		Section:CreateButton({ Title = "Click Me", Callback = function() end })

	Design: Dark + Purple glassmorphism, rounded window, macOS traffic-light buttons,
	blurred/soft-shadow surfaces, smooth TweenService animation throughout.

	This file is an original implementation written for this project; it does not
	copy code or assets from any other UI library.
]]

--============================================================
-- SERVICES
--============================================================
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local TextService = game:GetService("TextService")

local LocalPlayer = Players.LocalPlayer

local IsMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled
local IsTouch = UserInputService.TouchEnabled

--============================================================
-- ROOT GUI
--============================================================
local function protectGui(gui)
	if syn and syn.protect_gui then
		syn.protect_gui(gui)
		gui.Parent = CoreGui
	elseif gethui then
		gui.Parent = gethui()
	else
		local ok = pcall(function()
			gui.Parent = CoreGui
		end)
		if not ok then
			gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
		end
	end
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MacUI_" .. tostring(math.random(100000, 999999))
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999
protectGui(ScreenGui)

--============================================================
-- UTILITY
--============================================================
local Utility = {}

function Utility.Create(class, props, children)
	local inst = Instance.new(class)
	for k, v in pairs(props or {}) do
		inst[k] = v
	end
	for _, child in ipairs(children or {}) do
		child.Parent = inst
	end
	return inst
end

function Utility.Tween(obj, info, props)
	local tween = TweenService:Create(obj, info, props)
	tween:Play()
	return tween
end

function Utility.Round(instance, radius)
	return Utility.Create("UICorner", { CornerRadius = UDim.new(0, radius or 8), Parent = instance })
end

function Utility.Stroke(instance, color, thickness, transparency)
	return Utility.Create("UIStroke", {
		Color = color or Color3.fromRGB(255, 255, 255),
		Thickness = thickness or 1,
		Transparency = transparency or 0.85,
		Parent = instance,
	})
end

function Utility.Padding(instance, all)
	return Utility.Create("UIPadding", {
		PaddingTop = UDim.new(0, all),
		PaddingBottom = UDim.new(0, all),
		PaddingLeft = UDim.new(0, all),
		PaddingRight = UDim.new(0, all),
		Parent = instance,
	})
end

function Utility.Gradient(instance, colorSeq, rotation)
	return Utility.Create("UIGradient", {
		Color = colorSeq,
		Rotation = rotation or 0,
		Parent = instance,
	})
end

-- Safe connection registry so we can clean everything on destroy
local Connections = {}
function Utility.Connect(signal, fn)
	local c = signal:Connect(fn)
	table.insert(Connections, c)
	return c
end

function Utility.DisconnectAll()
	for _, c in ipairs(Connections) do
		pcall(function()
			c:Disconnect()
		end)
	end
	table.clear(Connections)
end

--============================================================
-- THEME ENGINE
--============================================================
local Themes = {
	["Dark Purple"] = {
		Background = Color3.fromRGB(24, 22, 32),
		Surface = Color3.fromRGB(32, 29, 42),
		SurfaceLight = Color3.fromRGB(42, 38, 54),
		Accent = Color3.fromRGB(150, 110, 255),
		AccentDark = Color3.fromRGB(110, 80, 210),
		Text = Color3.fromRGB(235, 233, 240),
		SubText = Color3.fromRGB(160, 155, 175),
		Stroke = Color3.fromRGB(255, 255, 255),
		Success = Color3.fromRGB(95, 200, 130),
		Warning = Color3.fromRGB(235, 180, 80),
		Error = Color3.fromRGB(235, 95, 95),
	},
	["Dark Blue"] = {
		Background = Color3.fromRGB(18, 22, 32),
		Surface = Color3.fromRGB(26, 31, 44),
		SurfaceLight = Color3.fromRGB(35, 41, 58),
		Accent = Color3.fromRGB(90, 150, 255),
		AccentDark = Color3.fromRGB(60, 110, 210),
		Text = Color3.fromRGB(230, 235, 245),
		SubText = Color3.fromRGB(150, 160, 180),
		Stroke = Color3.fromRGB(255, 255, 255),
		Success = Color3.fromRGB(95, 200, 130),
		Warning = Color3.fromRGB(235, 180, 80),
		Error = Color3.fromRGB(235, 95, 95),
	},
	["Dark Green"] = {
		Background = Color3.fromRGB(18, 24, 20),
		Surface = Color3.fromRGB(25, 33, 27),
		SurfaceLight = Color3.fromRGB(34, 44, 37),
		Accent = Color3.fromRGB(95, 210, 140),
		AccentDark = Color3.fromRGB(65, 170, 105),
		Text = Color3.fromRGB(230, 240, 232),
		SubText = Color3.fromRGB(150, 170, 155),
		Stroke = Color3.fromRGB(255, 255, 255),
		Success = Color3.fromRGB(95, 200, 130),
		Warning = Color3.fromRGB(235, 180, 80),
		Error = Color3.fromRGB(235, 95, 95),
	},
	["Dark Orange"] = {
		Background = Color3.fromRGB(28, 22, 18),
		Surface = Color3.fromRGB(38, 30, 25),
		SurfaceLight = Color3.fromRGB(50, 40, 33),
		Accent = Color3.fromRGB(255, 150, 80),
		AccentDark = Color3.fromRGB(215, 115, 55),
		Text = Color3.fromRGB(240, 233, 228),
		SubText = Color3.fromRGB(175, 160, 150),
		Stroke = Color3.fromRGB(255, 255, 255),
		Success = Color3.fromRGB(95, 200, 130),
		Warning = Color3.fromRGB(235, 180, 80),
		Error = Color3.fromRGB(235, 95, 95),
	},
	["Cyber"] = {
		Background = Color3.fromRGB(10, 12, 18),
		Surface = Color3.fromRGB(16, 20, 28),
		SurfaceLight = Color3.fromRGB(22, 28, 38),
		Accent = Color3.fromRGB(0, 230, 210),
		AccentDark = Color3.fromRGB(0, 180, 165),
		Text = Color3.fromRGB(225, 245, 245),
		SubText = Color3.fromRGB(130, 165, 165),
		Stroke = Color3.fromRGB(0, 230, 210),
		Success = Color3.fromRGB(95, 200, 130),
		Warning = Color3.fromRGB(235, 180, 80),
		Error = Color3.fromRGB(235, 95, 95),
	},
	["Neon"] = {
		Background = Color3.fromRGB(15, 10, 20),
		Surface = Color3.fromRGB(22, 15, 30),
		SurfaceLight = Color3.fromRGB(32, 22, 42),
		Accent = Color3.fromRGB(255, 60, 200),
		AccentDark = Color3.fromRGB(210, 40, 165),
		Text = Color3.fromRGB(240, 230, 245),
		SubText = Color3.fromRGB(170, 150, 180),
		Stroke = Color3.fromRGB(255, 60, 200),
		Success = Color3.fromRGB(95, 200, 130),
		Warning = Color3.fromRGB(235, 180, 80),
		Error = Color3.fromRGB(235, 95, 95),
	},
	["Light"] = {
		Background = Color3.fromRGB(240, 240, 245),
		Surface = Color3.fromRGB(250, 250, 253),
		SurfaceLight = Color3.fromRGB(255, 255, 255),
		Accent = Color3.fromRGB(130, 95, 230),
		AccentDark = Color3.fromRGB(100, 70, 200),
		Text = Color3.fromRGB(30, 28, 35),
		SubText = Color3.fromRGB(100, 96, 110),
		Stroke = Color3.fromRGB(0, 0, 0),
		Success = Color3.fromRGB(50, 160, 90),
		Warning = Color3.fromRGB(200, 140, 30),
		Error = Color3.fromRGB(200, 60, 60),
	},
}

local ActiveTheme = Themes["Dark Purple"]
local ThemedObjects = {} -- { instance = { property = themeKey } }

local function RegisterThemed(instance, map)
	ThemedObjects[instance] = map
	for prop, key in pairs(map) do
		pcall(function()
			instance[prop] = ActiveTheme[key]
		end)
	end
	instance.AncestryChanged:Connect(function(_, parent)
		if not parent then
			ThemedObjects[instance] = nil
		end
	end)
end

local function ApplyTheme(themeNameOrTable)
	local theme = themeNameOrTable
	if type(themeNameOrTable) == "string" then
		theme = Themes[themeNameOrTable]
	end
	if not theme then
		return
	end
	ActiveTheme = theme
	for instance, map in pairs(ThemedObjects) do
		if instance and instance.Parent then
			for prop, key in pairs(map) do
				pcall(function()
					Utility.Tween(instance, TweenInfo.new(0.25, Enum.EasingStyle.Quad), { [prop] = theme[key] })
				end)
			end
		else
			ThemedObjects[instance] = nil
		end
	end
end

--============================================================
-- NOTIFICATION SYSTEM
--============================================================
local NotificationHolder = Utility.Create("Frame", {
	Name = "Notifications",
	BackgroundTransparency = 1,
	AnchorPoint = Vector2.new(1, 1),
	Position = UDim2.new(1, -16, 1, -16),
	Size = UDim2.new(0, 300, 1, -32),
	Parent = ScreenGui,
})
Utility.Create("UIListLayout", {
	FillDirection = Enum.FillDirection.Vertical,
	VerticalAlignment = Enum.VerticalAlignment.Bottom,
	HorizontalAlignment = Enum.HorizontalAlignment.Right,
	Padding = UDim.new(0, 8),
	SortOrder = Enum.SortOrder.LayoutOrder,
	Parent = NotificationHolder,
})

local NotifyIcons = {
	Success = "✓",
	Info = "ℹ",
	Warning = "⚠",
	Error = "✕",
	Loading = "⟳",
}

local function Notify(opts)
	opts = opts or {}
	local kind = opts.Type or "Info"
	local duration = opts.Duration or 4

	local card = Utility.Create("Frame", {
		BackgroundColor3 = ActiveTheme.Surface,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 0.05,
		ClipsDescendants = true,
		Parent = NotificationHolder,
	})
	RegisterThemed(card, { BackgroundColor3 = "Surface" })
	Utility.Round(card, 12)
	Utility.Stroke(card, ActiveTheme.Accent, 1, 0.7)
	Utility.Padding(card, 12)

	local layout = Utility.Create("UIListLayout", {
		FillDirection = Enum.FillDirection.Vertical,
		Padding = UDim.new(0, 4),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = card,
	})

	local titleRow = Utility.Create("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 18),
		Parent = card,
	})
	local icon = Utility.Create("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 20, 1, 0),
		Font = Enum.Font.GothamBold,
		Text = NotifyIcons[kind] or "•",
		TextColor3 = ActiveTheme[kind] or ActiveTheme.Accent,
		TextSize = 14,
		Parent = titleRow,
	})
	local title = Utility.Create("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 22, 0, 0),
		Size = UDim2.new(1, -22, 1, 0),
		Font = Enum.Font.GothamBold,
		Text = opts.Title or "Notification",
		TextColor3 = ActiveTheme.Text,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = titleRow,
	})
	RegisterThemed(title, { TextColor3 = "Text" })

	if opts.Content then
		local content = Utility.Create("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Font = Enum.Font.Gotham,
			Text = opts.Content,
			TextColor3 = ActiveTheme.SubText,
			TextSize = 12,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = card,
		})
		RegisterThemed(content, { TextColor3 = "SubText" })
	end

	card.Size = UDim2.new(1, 0, 0, 0)
	card.Position = UDim2.new(1.2, 0, 0, 0)
	Utility.Tween(card, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Position = UDim2.new(0, 0, 0, 0) })

	task.delay(duration, function()
		if card and card.Parent then
			local t = Utility.Tween(card, TweenInfo.new(0.3, Enum.EasingStyle.Quad), { Position = UDim2.new(1.2, 0, 0, 0) })
			t.Completed:Connect(function()
				card:Destroy()
			end)
		end
	end)

	return card
end

--============================================================
-- CONFIG SYSTEM
--============================================================
local ConfigSystem = {}
ConfigSystem.Flags = {} -- flagName -> { Get, Set }
ConfigSystem.Folder = "MacUI_Configs"

local function fileApiAvailable()
	return typeof(writefile) == "function" and typeof(readfile) == "function"
end

if fileApiAvailable() then
	pcall(function()
		if typeof(isfolder) == "function" and not isfolder(ConfigSystem.Folder) then
			makefolder(ConfigSystem.Folder)
		end
	end)
end

function ConfigSystem.Register(flagName, getter, setter)
	ConfigSystem.Flags[flagName] = { Get = getter, Set = setter }
end

function ConfigSystem.Export()
	local data = {}
	for flag, handlers in pairs(ConfigSystem.Flags) do
		local ok, val = pcall(handlers.Get)
		if ok then
			data[flag] = val
		end
	end
	local ok, json = pcall(HttpService.JSONEncode, HttpService, data)
	if ok then
		return json
	end
	return "{}"
end

function ConfigSystem.Import(json)
	local ok, data = pcall(HttpService.JSONDecode, HttpService, json)
	if not ok or type(data) ~= "table" then
		return false
	end
	for flag, value in pairs(data) do
		local handlers = ConfigSystem.Flags[flag]
		if handlers then
			pcall(handlers.Set, value)
		end
	end
	return true
end

function ConfigSystem.Save(name)
	if not fileApiAvailable() then
		return false, "File API not available on this executor"
	end
	local json = ConfigSystem.Export()
	local ok, err = pcall(writefile, ConfigSystem.Folder .. "/" .. name .. ".json", json)
	return ok, err
end

function ConfigSystem.Load(name)
	if not fileApiAvailable() then
		return false, "File API not available on this executor"
	end
	local ok, content = pcall(readfile, ConfigSystem.Folder .. "/" .. name .. ".json")
	if not ok then
		return false, content
	end
	return ConfigSystem.Import(content)
end

function ConfigSystem.Delete(name)
	if not fileApiAvailable() then
		return false
	end
	return pcall(delfile, ConfigSystem.Folder .. "/" .. name .. ".json")
end

function ConfigSystem.List()
	if typeof(listfiles) ~= "function" then
		return {}
	end
	local ok, files = pcall(listfiles, ConfigSystem.Folder)
	if not ok then
		return {}
	end
	local names = {}
	for _, path in ipairs(files) do
		local name = path:match("([^/\\]+)%.json$")
		if name then
			table.insert(names, name)
		end
	end
	return names
end

--============================================================
-- LIBRARY OBJECT
--============================================================
local Library = {}
Library.Themes = Themes
Library.Config = ConfigSystem
Library.__index = Library

function Library:Notify(opts)
	return Notify(opts)
end

function Library:SetTheme(theme)
	ApplyTheme(theme)
end

function Library:Destroy()
	Utility.DisconnectAll()
	ScreenGui:Destroy()
end

--============================================================
-- WINDOW
--============================================================
function Library:CreateWindow(config)
	config = config or {}
	local title = config.Title or "MacUI"
	local subtitle = config.Subtitle or ""
	local version = config.Version or "1.0.0"
	local size = config.Size or UDim2.fromOffset(620, 420)
	local minimizeKey = config.MinimizeKeybind or Enum.KeyCode.RightControl

	if config.Theme then
		ApplyTheme(config.Theme)
	end

	local Window = {}
	Window.Tabs = {}
	Window.CurrentTab = nil

	------------------------------------------------------------------
	-- Root window frame
	------------------------------------------------------------------
	local Main = Utility.Create("Frame", {
		Name = "MainWindow",
		BackgroundColor3 = ActiveTheme.Background,
		BorderSizePixel = 0,
		Position = UDim2.new(0.5, -size.X.Offset / 2, 0.5, -size.Y.Offset / 2),
		Size = size,
		ClipsDescendants = true,
		Parent = ScreenGui,
	})
	RegisterThemed(Main, { BackgroundColor3 = "Background" })
	Utility.Round(Main, 14)
	Utility.Stroke(Main, ActiveTheme.Accent, 1, 0.75)

	-- soft shadow (image-based shadow avoided to not depend on external assets;
	-- emulate with a semi-transparent stroked frame behind the window)
	local Shadow = Utility.Create("Frame", {
		Name = "Shadow",
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.55,
		Position = UDim2.new(0.5, 0, 0.5, 8),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.new(1, 24, 1, 24),
		ZIndex = Main.ZIndex - 1,
		Parent = Main.Parent,
	})
	Utility.Round(Shadow, 20)
	Main.AncestryChanged:Connect(function(_, parent)
		if not parent then
			Shadow:Destroy()
		end
	end)

	Utility.Gradient(Main, ColorSequence.new({
		ColorSequenceKeypoint.new(0, ActiveTheme.Surface),
		ColorSequenceKeypoint.new(1, ActiveTheme.Background),
	}), 60)

	------------------------------------------------------------------
	-- Title bar (macOS-style)
	------------------------------------------------------------------
	local TitleBar = Utility.Create("Frame", {
		Name = "TitleBar",
		BackgroundColor3 = ActiveTheme.Surface,
		BackgroundTransparency = 0.15,
		Size = UDim2.new(1, 0, 0, 40),
		Parent = Main,
	})
	RegisterThemed(TitleBar, { BackgroundColor3 = "Surface" })
	Utility.Round(TitleBar, 14)

	-- mask the bottom corners of the round title bar so it looks flush
	local TitleBarMask = Utility.Create("Frame", {
		BackgroundColor3 = ActiveTheme.Surface,
		BackgroundTransparency = 0.15,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 1, -14),
		Size = UDim2.new(1, 0, 0, 14),
		Parent = TitleBar,
	})
	RegisterThemed(TitleBarMask, { BackgroundColor3 = "Surface" })

	local TrafficHolder = Utility.Create("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 12, 0.5, -6),
		Size = UDim2.new(0, 60, 0, 12),
		Parent = TitleBar,
	})
	Utility.Create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 8),
		Parent = TrafficHolder,
	})

	local function trafficButton(color, hoverText)
		local btn = Utility.Create("TextButton", {
			BackgroundColor3 = color,
			Size = UDim2.new(0, 12, 0, 12),
			AutoButtonColor = false,
			Text = "",
			Parent = TrafficHolder,
		})
		Utility.Round(btn, 6)
		btn.MouseEnter:Connect(function()
			Utility.Tween(btn, TweenInfo.new(0.15), { Size = UDim2.new(0, 13, 0, 13) })
		end)
		btn.MouseLeave:Connect(function()
			Utility.Tween(btn, TweenInfo.new(0.15), { Size = UDim2.new(0, 12, 0, 12) })
		end)
		return btn
	end

	local CloseBtn = trafficButton(Color3.fromRGB(255, 95, 86))
	local MinBtn = trafficButton(Color3.fromRGB(255, 189, 46))
	local MaxBtn = trafficButton(Color3.fromRGB(39, 201, 63))

	local TitleLabel = Utility.Create("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 84, 0, 2),
		Size = UDim2.new(1, -180, 0, 18),
		Font = Enum.Font.GothamBold,
		Text = title,
		TextColor3 = ActiveTheme.Text,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = TitleBar,
	})
	RegisterThemed(TitleLabel, { TextColor3 = "Text" })

	local SubtitleLabel = Utility.Create("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 84, 0, 19),
		Size = UDim2.new(1, -180, 0, 14),
		Font = Enum.Font.Gotham,
		Text = subtitle ~= "" and subtitle or ("v" .. version),
		TextColor3 = ActiveTheme.SubText,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = TitleBar,
	})
	RegisterThemed(SubtitleLabel, { TextColor3 = "SubText" })

	local ClockLabel = Utility.Create("TextLabel", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0.5, 0),
		Size = UDim2.new(0, 70, 0, 16),
		Font = Enum.Font.Code,
		Text = os.date("%H:%M:%S"),
		TextColor3 = ActiveTheme.SubText,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = TitleBar,
	})
	RegisterThemed(ClockLabel, { TextColor3 = "SubText" })
	Utility.Connect(RunService.Heartbeat, function()
		-- throttle updates to once per second using os.clock
	end)
	task.spawn(function()
		while ClockLabel and ClockLabel.Parent do
			ClockLabel.Text = os.date("%H:%M:%S")
			task.wait(1)
		end
	end)

	------------------------------------------------------------------
	-- Body: Sidebar + Content
	------------------------------------------------------------------
	local Body = Utility.Create("Frame", {
		Name = "Body",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 40),
		Size = UDim2.new(1, 0, 1, -40),
		Parent = Main,
	})

	local SIDEBAR_EXPANDED = 150
	local SIDEBAR_COLLAPSED = 52
	local sidebarExpanded = true

	local Sidebar = Utility.Create("Frame", {
		Name = "Sidebar",
		BackgroundColor3 = ActiveTheme.Surface,
		BackgroundTransparency = 0.3,
		Size = UDim2.new(0, SIDEBAR_EXPANDED, 1, 0),
		Parent = Body,
	})
	RegisterThemed(Sidebar, { BackgroundColor3 = "Surface" })

	local TabList = Utility.Create("ScrollingFrame", {
		Name = "TabList",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 8),
		Size = UDim2.new(1, 0, 1, -44),
		ScrollBarThickness = 3,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = Sidebar,
	})
	Utility.Create("UIListLayout", {
		FillDirection = Enum.FillDirection.Vertical,
		Padding = UDim.new(0, 4),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = TabList,
	})
	Utility.Padding(TabList, 6)

	local CollapseBtn = Utility.Create("TextButton", {
		Name = "CollapseBtn",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -8),
		Size = UDim2.new(0, 28, 0, 28),
		Font = Enum.Font.GothamBold,
		Text = "‹",
		TextColor3 = ActiveTheme.SubText,
		TextSize = 18,
		Parent = Sidebar,
	})
	RegisterThemed(CollapseBtn, { TextColor3 = "SubText" })

	local ContentArea = Utility.Create("Frame", {
		Name = "ContentArea",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, SIDEBAR_EXPANDED, 0, 0),
		Size = UDim2.new(1, -SIDEBAR_EXPANDED, 1, 0),
		Parent = Body,
	})

	CollapseBtn.MouseButton1Click:Connect(function()
		sidebarExpanded = not sidebarExpanded
		local target = sidebarExpanded and SIDEBAR_EXPANDED or SIDEBAR_COLLAPSED
		Utility.Tween(Sidebar, TweenInfo.new(0.25, Enum.EasingStyle.Quad), { Size = UDim2.new(0, target, 1, 0) })
		Utility.Tween(ContentArea, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
			Position = UDim2.new(0, target, 0, 0),
			Size = UDim2.new(1, -target, 1, 0),
		})
		Utility.Tween(CollapseBtn, TweenInfo.new(0.25), { Rotation = sidebarExpanded and 0 or 180 })
		for _, tab in ipairs(Window.Tabs) do
			tab._labelObj.Visible = sidebarExpanded
		end
	end)

	------------------------------------------------------------------
	-- Window dragging
	------------------------------------------------------------------
	do
		local dragging = false
		local dragStart, startPos

		local function updateInput(input)
			local delta = input.Position - dragStart
			local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)

			-- clamp so window can't leave the screen
			local viewport = ScreenGui.AbsoluteSize
			local absSize = Main.AbsoluteSize
			local minX, minY = -absSize.X + 60, 0
			local maxX, maxY = viewport.X - 60, viewport.Y - 30
			local px = math.clamp(newPos.X.Offset, minX, maxX)
			local py = math.clamp(newPos.Y.Offset, minY, maxY)

			Main.Position = UDim2.new(newPos.X.Scale, px, newPos.Y.Scale, py)
			Shadow.Position = UDim2.new(0.5, 0, 0.5, 8)
		end

		TitleBar.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				dragStart = input.Position
				startPos = Main.Position
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						dragging = false
					end
				end)
			end
		end)

		UserInputService.InputChanged:Connect(function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				updateInput(input)
			end
		end)
	end

	------------------------------------------------------------------
	-- Minimize / restore / close
	------------------------------------------------------------------
	local minimized = false
	local lastSize = Main.Size

	local function setMinimized(state)
		minimized = state
		if state then
			lastSize = Main.Size
			Utility.Tween(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quad), { Size = UDim2.new(0, Main.Size.X.Offset, 0, 40) })
			Body.Visible = false
		else
			Body.Visible = true
			Utility.Tween(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quad), { Size = lastSize })
		end
	end

	MinBtn.MouseButton1Click:Connect(function()
		setMinimized(not minimized)
	end)

	local hidden = false
	local FloatingButton -- forward declare

	local function setHidden(state)
		hidden = state
		if state then
			Utility.Tween(Main, TweenInfo.new(0.25), { Size = UDim2.new(Main.Size.X.Scale, Main.Size.X.Offset, 0, 0) })
			task.delay(0.25, function()
				Main.Visible = not state
				Shadow.Visible = not state
			end)
		else
			Main.Visible = true
			Shadow.Visible = true
			Utility.Tween(Main, TweenInfo.new(0.25), { Size = lastSize })
		end
		if FloatingButton then
			FloatingButton.Visible = state
		end
	end

	CloseBtn.MouseButton1Click:Connect(function()
		setHidden(true)
	end)

	MaxBtn.MouseButton1Click:Connect(function()
		-- toggle maximize between default size and near-fullscreen
		local viewport = ScreenGui.AbsoluteSize
		if Main.Size.X.Offset < viewport.X - 40 then
			lastSize = Main.Size
			Utility.Tween(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
				Size = UDim2.new(0, viewport.X - 40, 0, viewport.Y - 80),
				Position = UDim2.new(0, 20, 0, 40),
			})
		else
			Utility.Tween(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quad), { Size = lastSize })
		end
	end)

	Utility.Connect(UserInputService.InputBegan, function(input, processed)
		if processed then
			return
		end
		if input.KeyCode == minimizeKey then
			setHidden(not hidden)
		end
	end)

	------------------------------------------------------------------
	-- Floating button (mobile show/hide)
	------------------------------------------------------------------
	FloatingButton = Utility.Create("TextButton", {
		Name = "FloatingButton",
		BackgroundColor3 = ActiveTheme.Accent,
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -20, 1, -20),
		Size = UDim2.new(0, 50, 0, 50),
		Text = "☰",
		TextColor3 = Color3.new(1, 1, 1),
		Font = Enum.Font.GothamBold,
		TextSize = 20,
		Visible = false,
		Parent = ScreenGui,
	})
	RegisterThemed(FloatingButton, { BackgroundColor3 = "Accent" })
	Utility.Round(FloatingButton, 25)

	do
		local dragging, dragStart, startPos, moved = false, nil, nil, false
		local function begin(input)
			dragging = true
			moved = false
			dragStart = input.Position
			startPos = FloatingButton.Position
		end
		local function update(input)
			local delta = input.Position - dragStart
			if delta.Magnitude > 4 then
				moved = true
			end
			FloatingButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
		local function finish()
			dragging = false
			-- snap to nearest horizontal edge
			local viewport = ScreenGui.AbsoluteSize
			local center = FloatingButton.AbsolutePosition.X + FloatingButton.AbsoluteSize.X / 2
			local targetX = (center < viewport.X / 2) and 20 or (viewport.X - 70)
			Utility.Tween(FloatingButton, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
				Position = UDim2.new(0, targetX, FloatingButton.Position.Y.Scale, FloatingButton.Position.Y.Offset),
			})
			if not moved then
				setHidden(false)
			end
		end

		FloatingButton.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				begin(input)
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				update(input)
			end
		end)
		UserInputService.InputEnded:Connect(function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
				finish()
			end
		end)
	end

	------------------------------------------------------------------
	-- Tabs
	------------------------------------------------------------------
	function Window:CreateTab(name, icon)
		local Tab = {}
		Tab.Sections = {}
		Tab.Name = name

		local btn = Utility.Create("TextButton", {
			Name = name .. "TabButton",
			BackgroundColor3 = ActiveTheme.SurfaceLight,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 34),
			AutoButtonColor = false,
			Text = "",
			Parent = TabList,
		})
		Utility.Round(btn, 8)

		local indicator = Utility.Create("Frame", {
			BackgroundColor3 = ActiveTheme.Accent,
			Position = UDim2.new(0, 0, 0.2, 0),
			Size = UDim2.new(0, 3, 0.6, 0),
			Visible = false,
			Parent = btn,
		})
		RegisterThemed(indicator, { BackgroundColor3 = "Accent" })
		Utility.Round(indicator, 2)

		local iconLabel = Utility.Create("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 10, 0, 0),
			Size = UDim2.new(0, 20, 1, 0),
			Font = Enum.Font.GothamBold,
			Text = icon or "•",
			TextColor3 = ActiveTheme.SubText,
			TextSize = 14,
			Parent = btn,
		})
		RegisterThemed(iconLabel, { TextColor3 = "SubText" })

		local label = Utility.Create("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 36, 0, 0),
			Size = UDim2.new(1, -40, 1, 0),
			Font = Enum.Font.GothamMedium,
			Text = name,
			TextColor3 = ActiveTheme.SubText,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = btn,
		})
		RegisterThemed(label, { TextColor3 = "SubText" })
		Tab._labelObj = label

		local page = Utility.Create("ScrollingFrame", {
			Name = name .. "Page",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
			ScrollBarThickness = 3,
			ScrollBarImageColor3 = ActiveTheme.Accent,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			Visible = false,
			Parent = ContentArea,
		})
		Utility.Padding(page, 16)
		Utility.Create("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			Padding = UDim.new(0, 12),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = page,
		})

		Tab._button = btn
		Tab._page = page
		Tab._indicator = indicator

		local function selectTab()
			for _, t in ipairs(Window.Tabs) do
				t._page.Visible = false
				t._indicator.Visible = false
				Utility.Tween(t._button, TweenInfo.new(0.2), { BackgroundTransparency = 1 })
				Utility.Tween(t._labelObj, TweenInfo.new(0.2), { TextColor3 = ActiveTheme.SubText })
			end
			page.Visible = true
			indicator.Visible = true
			Utility.Tween(btn, TweenInfo.new(0.2), { BackgroundTransparency = 0.5 })
			Utility.Tween(label, TweenInfo.new(0.2), { TextColor3 = ActiveTheme.Text })
			Window.CurrentTab = Tab
		end

		btn.MouseButton1Click:Connect(selectTab)

		table.insert(Window.Tabs, Tab)
		if #Window.Tabs == 1 then
			selectTab()
		end

		------------------------------------------------------------------
		-- Section
		------------------------------------------------------------------
		function Tab:CreateSection(sectionName)
			local Section = {}

			local container = Utility.Create("Frame", {
				Name = sectionName .. "Section",
				BackgroundColor3 = ActiveTheme.Surface,
				BackgroundTransparency = 0.2,
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				Parent = page,
			})
			RegisterThemed(container, { BackgroundColor3 = "Surface" })
			Utility.Round(container, 10)
			Utility.Stroke(container, ActiveTheme.Accent, 1, 0.85)
			Utility.Padding(container, 12)

			local layout = Utility.Create("UIListLayout", {
				FillDirection = Enum.FillDirection.Vertical,
				Padding = UDim.new(0, 8),
				SortOrder = Enum.SortOrder.LayoutOrder,
				Parent = container,
			})

			local header = Utility.Create("TextLabel", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 18),
				Font = Enum.Font.GothamBold,
				Text = sectionName,
				TextColor3 = ActiveTheme.Text,
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = container,
			})
			RegisterThemed(header, { TextColor3 = "Text" })

			local body = Utility.Create("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				Parent = container,
			})
			Utility.Create("UIListLayout", {
				FillDirection = Enum.FillDirection.Vertical,
				Padding = UDim.new(0, 8),
				SortOrder = Enum.SortOrder.LayoutOrder,
				Parent = body,
			})

			--============================================================
			-- ELEMENT: Divider
			--============================================================
			function Section:CreateDivider()
				local line = Utility.Create("Frame", {
					BackgroundColor3 = ActiveTheme.SubText,
					BackgroundTransparency = 0.8,
					Size = UDim2.new(1, 0, 0, 1),
					Parent = body,
				})
				RegisterThemed(line, { BackgroundColor3 = "SubText" })
				return line
			end

			--============================================================
			-- ELEMENT: Label
			--============================================================
			function Section:CreateLabel(text)
				local lbl = Utility.Create("TextLabel", {
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 16),
					Font = Enum.Font.Gotham,
					Text = text or "",
					TextColor3 = ActiveTheme.SubText,
					TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Left,
					Parent = body,
				})
				RegisterThemed(lbl, { TextColor3 = "SubText" })
				local api = {}
				function api:Set(newText)
					lbl.Text = newText
				end
				return api
			end

			--============================================================
			-- ELEMENT: Paragraph
			--============================================================
			function Section:CreateParagraph(opts)
				opts = opts or {}
				local holder = Utility.Create("Frame", {
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 0),
					AutomaticSize = Enum.AutomaticSize.Y,
					Parent = body,
				})
				Utility.Create("UIListLayout", {
					Padding = UDim.new(0, 2),
					Parent = holder,
				})
				local t = Utility.Create("TextLabel", {
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 16),
					Font = Enum.Font.GothamBold,
					Text = opts.Title or "",
					TextColor3 = ActiveTheme.Text,
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Left,
					Parent = holder,
				})
				RegisterThemed(t, { TextColor3 = "Text" })
				local c = Utility.Create("TextLabel", {
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 0),
					AutomaticSize = Enum.AutomaticSize.Y,
					Font = Enum.Font.Gotham,
					Text = opts.Content or "",
					TextColor3 = ActiveTheme.SubText,
					TextSize = 12,
					TextWrapped = true,
					TextXAlignment = Enum.TextXAlignment.Left,
					Parent = holder,
				})
				RegisterThemed(c, { TextColor3 = "SubText" })
				local api = {}
				function api:SetContent(text)
					c.Text = text
				end
				return api
			end

			--============================================================
			-- ELEMENT: Button
			--============================================================
			function Section:CreateButton(opts)
				opts = opts or {}
				local callback = opts.Callback or function() end

				local btn2 = Utility.Create("TextButton", {
					BackgroundColor3 = ActiveTheme.SurfaceLight,
					Size = UDim2.new(1, 0, 0, 34),
					AutoButtonColor = false,
					Font = Enum.Font.GothamMedium,
					Text = opts.Title or "Button",
					TextColor3 = ActiveTheme.Text,
					TextSize = 13,
					Parent = body,
				})
				RegisterThemed(btn2, { BackgroundColor3 = "SurfaceLight", TextColor3 = "Text" })
				Utility.Round(btn2, 8)

				btn2.MouseEnter:Connect(function()
					Utility.Tween(btn2, TweenInfo.new(0.15), { BackgroundColor3 = ActiveTheme.Accent })
				end)
				btn2.MouseLeave:Connect(function()
					Utility.Tween(btn2, TweenInfo.new(0.15), { BackgroundColor3 = ActiveTheme.SurfaceLight })
				end)

				btn2.MouseButton1Click:Connect(function()
					-- ripple effect
					local ripple = Utility.Create("Frame", {
						BackgroundColor3 = Color3.new(1, 1, 1),
						BackgroundTransparency = 0.7,
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.new(0.5, 0, 0.5, 0),
						Size = UDim2.new(0, 0, 0, 0),
						Parent = btn2,
					})
					Utility.Round(ripple, 100)
					local t = Utility.Tween(ripple, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
						Size = UDim2.new(1.4, 0, 3, 0),
						BackgroundTransparency = 1,
					})
					t.Completed:Connect(function()
						ripple:Destroy()
					end)
					local ok, err = pcall(callback)
					if not ok then
						warn("[MacUI] Button callback error: " .. tostring(err))
					end
				end)

				local api = {}
				function api:SetTitle(text)
					btn2.Text = text
				end
				return api
			end

			--============================================================
			-- ELEMENT: Toggle
			--============================================================
			function Section:CreateToggle(opts)
				opts = opts or {}
				local state = opts.Default or false
				local callback = opts.Callback or function() end

				local holder = Utility.Create("TextButton", {
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 28),
					AutoButtonColor = false,
					Text = "",
					Parent = body,
				})

				local label = Utility.Create("TextLabel", {
					BackgroundTransparency = 1,
					Size = UDim2.new(1, -50, 1, 0),
					Font = Enum.Font.GothamMedium,
					Text = opts.Title or "Toggle",
					TextColor3 = ActiveTheme.Text,
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Left,
					Parent = holder,
				})
				RegisterThemed(label, { TextColor3 = "Text" })

				local track = Utility.Create("Frame", {
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, 0, 0.5, 0),
					Size = UDim2.new(0, 40, 0, 22),
					BackgroundColor3 = state and ActiveTheme.Accent or ActiveTheme.SurfaceLight,
					Parent = holder,
				})
				Utility.Round(track, 11)

				local knob = Utility.Create("Frame", {
					Size = UDim2.new(0, 18, 0, 18),
					Position = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9),
					BackgroundColor3 = Color3.new(1, 1, 1),
					Parent = track,
				})
				Utility.Round(knob, 9)

				local function render(animated)
					local trackColor = state and ActiveTheme.Accent or ActiveTheme.SurfaceLight
					local knobPos = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
					if animated then
						Utility.Tween(track, TweenInfo.new(0.18, Enum.EasingStyle.Quad), { BackgroundColor3 = trackColor })
						Utility.Tween(knob, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Position = knobPos })
					else
						track.BackgroundColor3 = trackColor
						knob.Position = knobPos
					end
				end

				local function setValue(v, fireCallback)
					state = v
					render(true)
					if fireCallback ~= false then
						local ok, err = pcall(callback, state)
						if not ok then
							warn("[MacUI] Toggle callback error: " .. tostring(err))
						end
					end
				end

				holder.MouseButton1Click:Connect(function()
					setValue(not state, true)
				end)
				holder.SelectionOrder = 1

				-- keyboard accessibility: Enter/Space toggles when GuiObject selected
				holder.InputBegan:Connect(function(input)
					if input.KeyCode == Enum.KeyCode.Return or input.KeyCode == Enum.KeyCode.Space then
						setValue(not state, true)
					end
				end)

				render(false)

				local api = { Value = state }
				function api:SetValue(v)
					setValue(v, true)
					api.Value = v
				end
				function api:GetValue()
					return state
				end
				if opts.Flag then
					ConfigSystem.Register(opts.Flag, function()
						return state
					end, function(v)
						setValue(v, true)
					end)
				end
				return api
			end

			--============================================================
			-- ELEMENT: Slider  (fully functional: mouse + touch, real-time)
			--============================================================
			function Section:CreateSlider(opts)
				opts = opts or {}
				local min = opts.Min or 0
				local max = opts.Max or 100
				local step = opts.Step or 1
				local decimals = opts.Decimals or 0
				local value = math.clamp(opts.Default or min, min, max)
				local callback = opts.Callback or function() end

				local holder = Utility.Create("Frame", {
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 40),
					Parent = body,
				})

				local label = Utility.Create("TextLabel", {
					BackgroundTransparency = 1,
					Size = UDim2.new(1, -50, 0, 16),
					Font = Enum.Font.GothamMedium,
					Text = opts.Title or "Slider",
					TextColor3 = ActiveTheme.Text,
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Left,
					Parent = holder,
				})
				RegisterThemed(label, { TextColor3 = "Text" })

				local valueLabel = Utility.Create("TextLabel", {
					BackgroundTransparency = 1,
					AnchorPoint = Vector2.new(1, 0),
					Position = UDim2.new(1, 0, 0, 0),
					Size = UDim2.new(0, 50, 0, 16),
					Font = Enum.Font.Code,
					Text = string.format("%." .. decimals .. "f", value),
					TextColor3 = ActiveTheme.SubText,
					TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Right,
					Parent = holder,
				})
				RegisterThemed(valueLabel, { TextColor3 = "SubText" })

				local track = Utility.Create("Frame", {
					Position = UDim2.new(0, 0, 0, 24),
					Size = UDim2.new(1, 0, 0, 8),
					BackgroundColor3 = ActiveTheme.SurfaceLight,
					Parent = holder,
				})
				Utility.Round(track, 4)

				local fill = Utility.Create("Frame", {
					Size = UDim2.new(0, 0, 1, 0),
					BackgroundColor3 = ActiveTheme.Accent,
					Parent = track,
				})
				RegisterThemed(fill, { BackgroundColor3 = "Accent" })
				Utility.Round(fill, 4)

				local handle = Utility.Create("Frame", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					Size = UDim2.new(0, 16, 0, 16),
					Position = UDim2.new(0, 0, 0.5, 0),
					BackgroundColor3 = Color3.new(1, 1, 1),
					ZIndex = 2,
					Parent = track,
				})
				Utility.Round(handle, 8)
				Utility.Stroke(handle, ActiveTheme.Accent, 2, 0)

				local function alpha()
					return (value - min) / (max - min)
				end

				local function renderPosition()
					local a = alpha()
					fill.Size = UDim2.new(a, 0, 1, 0)
					handle.Position = UDim2.new(a, 0, 0.5, 0)
					valueLabel.Text = string.format("%." .. decimals .. "f", value)
				end

				local function setValue(newValue, fireCallback)
					newValue = math.clamp(newValue, min, max)
					if step and step > 0 then
						newValue = min + math.floor(((newValue - min) / step) + 0.5) * step
						newValue = math.clamp(newValue, min, max)
					end
					if decimals == 0 then
						newValue = math.floor(newValue + 0.5)
					end
					value = newValue
					renderPosition()
					if fireCallback ~= false then
						local ok, err = pcall(callback, value)
						if not ok then
							warn("[MacUI] Slider callback error: " .. tostring(err))
						end
					end
				end

				-- Correct position math using AbsolutePosition/AbsoluteSize as required.
				local function updateFromInputPosition(inputPos)
					local trackPos = track.AbsolutePosition.X
					local trackSize = track.AbsoluteSize.X
					if trackSize <= 0 then
						return
					end
					local relative = (inputPos - trackPos) / trackSize
					relative = math.clamp(relative, 0, 1)
					local newVal = min + relative * (max - min)
					setValue(newVal, true)
				end

				local sliding = false

				local function onBegin(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						sliding = true
						updateFromInputPosition(input.Position.X)
					end
				end

				track.InputBegan:Connect(onBegin)
				handle.InputBegan:Connect(onBegin)

				Utility.Connect(UserInputService.InputChanged, function(input)
					if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
						updateFromInputPosition(input.Position.X)
					end
				end)

				Utility.Connect(UserInputService.InputEnded, function(input)
					if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and sliding then
						sliding = false
					end
				end)

				renderPosition()

				local api = {}
				function api:SetValue(v)
					setValue(v, true)
				end
				function api:GetValue()
					return value
				end
				if opts.Flag then
					ConfigSystem.Register(opts.Flag, function()
						return value
					end, function(v)
						setValue(v, true)
					end)
				end
				return api
			end

			--============================================================
			-- ELEMENT: Dropdown (single + multi)
			--============================================================
			function Section:CreateDropdown(opts)
				opts = opts or {}
				local options = opts.Options or {}
				local multi = opts.Multi or false
				local callback = opts.Callback or function() end
				local selected = {}

				if multi then
					for _, v in ipairs(opts.Default or {}) do
						selected[v] = true
					end
				else
					selected.single = opts.Default
				end

				local holder = Utility.Create("Frame", {
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 34),
					ClipsDescendants = false,
					Parent = body,
				})

				local btn3 = Utility.Create("TextButton", {
					BackgroundColor3 = ActiveTheme.SurfaceLight,
					Size = UDim2.new(1, 0, 0, 34),
					AutoButtonColor = false,
					Text = "",
					Parent = holder,
				})
				RegisterThemed(btn3, { BackgroundColor3 = "SurfaceLight" })
				Utility.Round(btn3, 8)
				Utility.Padding(btn3, 10)

				local title = Utility.Create("TextLabel", {
					BackgroundTransparency = 1,
					Size = UDim2.new(1, -20, 1, 0),
					Font = Enum.Font.GothamMedium,
					Text = opts.Title or "Dropdown",
					TextColor3 = ActiveTheme.Text,
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Left,
					Parent = btn3,
				})
				RegisterThemed(title, { TextColor3 = "Text" })

				local arrow = Utility.Create("TextLabel", {
					BackgroundTransparency = 1,
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, 0, 0.5, 0),
					Size = UDim2.new(0, 16, 0, 16),
					Font = Enum.Font.GothamBold,
					Text = "▾",
					TextColor3 = ActiveTheme.SubText,
					TextSize = 12,
					Parent = btn3,
				})
				RegisterThemed(arrow, { TextColor3 = "SubText" })

				local listFrame = Utility.Create("Frame", {
					BackgroundColor3 = ActiveTheme.Surface,
					Position = UDim2.new(0, 0, 1, 4),
					Size = UDim2.new(1, 0, 0, 0),
					ClipsDescendants = true,
					Visible = false,
					ZIndex = 10,
					Parent = holder,
				})
				RegisterThemed(listFrame, { BackgroundColor3 = "Surface" })
				Utility.Round(listFrame, 8)
				Utility.Stroke(listFrame, ActiveTheme.Accent, 1, 0.7)

				local scroller = Utility.Create("ScrollingFrame", {
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 1, 0),
					ScrollBarThickness = 3,
					CanvasSize = UDim2.new(0, 0, 0, 0),
					AutomaticCanvasSize = Enum.AutomaticSize.Y,
					ZIndex = 10,
					Parent = listFrame,
				})
				Utility.Create("UIListLayout", {
					Padding = UDim.new(0, 2),
					SortOrder = Enum.SortOrder.LayoutOrder,
					Parent = scroller,
				})
				Utility.Padding(scroller, 6)

				local open = false
				local optionButtons = {}

				local function refreshTitle()
					if multi then
						local names = {}
						for k, v in pairs(selected) do
							if v then
								table.insert(names, k)
							end
						end
						title.Text = #names > 0 and table.concat(names, ", ") or (opts.Title or "Dropdown")
					else
						title.Text = selected.single or (opts.Title or "Dropdown")
					end
				end

				local function setOpen(state)
					open = state
					listFrame.Visible = true
					local target = state and math.min(#options * 30 + 12, 160) or 0
					local t = Utility.Tween(listFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), { Size = UDim2.new(1, 0, 0, target) })
					Utility.Tween(arrow, TweenInfo.new(0.2), { Rotation = state and 180 or 0 })
					if not state then
						t.Completed:Connect(function()
							listFrame.Visible = false
						end)
					end
				end

				local function selectOption(opt)
					if multi then
						selected[opt] = not selected[opt]
						optionButtons[opt].BackgroundTransparency = selected[opt] and 0.7 or 1
					else
						selected.single = opt
						for name, b in pairs(optionButtons) do
							b.BackgroundTransparency = (name == opt) and 0.7 or 1
						end
						setOpen(false)
					end
					refreshTitle()
					local ok, err = pcall(callback, multi and selected or selected.single)
					if not ok then
						warn("[MacUI] Dropdown callback error: " .. tostring(err))
					end
				end

				for _, opt in ipairs(options) do
					local optBtn = Utility.Create("TextButton", {
						BackgroundColor3 = ActiveTheme.Accent,
						BackgroundTransparency = 1,
						Size = UDim2.new(1, 0, 0, 28),
						AutoButtonColor = false,
						Font = Enum.Font.Gotham,
						Text = tostring(opt),
						TextColor3 = ActiveTheme.Text,
						TextSize = 12,
						ZIndex = 10,
						Parent = scroller,
					})
					RegisterThemed(optBtn, { TextColor3 = "Text" })
					Utility.Round(optBtn, 6)
					optionButtons[opt] = optBtn
					optBtn.MouseButton1Click:Connect(function()
						selectOption(opt)
					end)
				end

				btn3.MouseButton1Click:Connect(function()
					setOpen(not open)
				end)

				-- close on outside click
				Utility.Connect(UserInputService.InputBegan, function(input)
					if not open then
						return
					end
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						local mousePos = UserInputService:GetMouseLocation()
						local abs = listFrame.AbsolutePosition
						local size = listFrame.AbsoluteSize
						local btnAbs = btn3.AbsolutePosition
						local btnSize = btn3.AbsoluteSize
						local insideList = mousePos.X >= abs.X and mousePos.X <= abs.X + size.X and mousePos.Y >= abs.Y and mousePos.Y <= abs.Y + size.Y
						local insideBtn = mousePos.X >= btnAbs.X and mousePos.X <= btnAbs.X + btnSize.X and mousePos.Y >= btnAbs.Y and mousePos.Y <= btnAbs.Y + btnSize.Y
						if not insideList and not insideBtn then
							setOpen(false)
						end
					end
				end)

				refreshTitle()

				local api = {}
				function api:SetOptions(newOptions)
					options = newOptions
					for _, b in pairs(optionButtons) do
						b:Destroy()
					end
					optionButtons = {}
					for _, opt in ipairs(options) do
						local optBtn = Utility.Create("TextButton", {
							BackgroundColor3 = ActiveTheme.Accent,
							BackgroundTransparency = 1,
							Size = UDim2.new(1, 0, 0, 28),
							AutoButtonColor = false,
							Font = Enum.Font.Gotham,
							Text = tostring(opt),
							TextColor3 = ActiveTheme.Text,
							TextSize = 12,
							ZIndex = 10,
							Parent = scroller,
						})
						Utility.Round(optBtn, 6)
						optionButtons[opt] = optBtn
						optBtn.MouseButton1Click:Connect(function()
							selectOption(opt)
						end)
					end
				end
				function api:GetValue()
					return multi and selected or selected.single
				end
				if opts.Flag then
					ConfigSystem.Register(opts.Flag, function()
						return multi and selected or selected.single
					end, function(v)
						if multi then
							selected = v
						else
							selected.single = v
						end
						refreshTitle()
					end)
				end
				return api
			end

			--============================================================
			-- ELEMENT: Textbox
			--============================================================
			function Section:CreateTextbox(opts)
				opts = opts or {}
				local callback = opts.Callback or function() end

				local holder = Utility.Create("Frame", {
					BackgroundColor3 = ActiveTheme.SurfaceLight,
					Size = UDim2.new(1, 0, 0, 34),
					Parent = body,
				})
				RegisterThemed(holder, { BackgroundColor3 = "SurfaceLight" })
				Utility.Round(holder, 8)
				Utility.Padding(holder, 8)

				local box = Utility.Create("TextBox", {
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 1, 0),
					Font = Enum.Font.Gotham,
					PlaceholderText = opts.Placeholder or opts.Title or "Enter text...",
					Text = opts.Default or "",
					TextColor3 = ActiveTheme.Text,
					PlaceholderColor3 = ActiveTheme.SubText,
					TextSize = 13,
					ClearTextOnFocus = false,
					TextXAlignment = Enum.TextXAlignment.Left,
					Parent = holder,
				})
				RegisterThemed(box, { TextColor3 = "Text", PlaceholderColor3 = "SubText" })

				box.Focused:Connect(function()
					Utility.Tween(holder, TweenInfo.new(0.15), { BackgroundColor3 = ActiveTheme.Accent })
				end)
				box.FocusLost:Connect(function(enterPressed)
					Utility.Tween(holder, TweenInfo.new(0.15), { BackgroundColor3 = ActiveTheme.SurfaceLight })
					local ok, err = pcall(callback, box.Text, enterPressed)
					if not ok then
						warn("[MacUI] Textbox callback error: " .. tostring(err))
					end
				end)

				local api = {}
				function api:SetValue(text)
					box.Text = text
				end
				function api:GetValue()
					return box.Text
				end
				if opts.Flag then
					ConfigSystem.Register(opts.Flag, function()
						return box.Text
					end, function(v)
						box.Text = v
					end)
				end
				return api
			end

			--============================================================
			-- ELEMENT: Keybind
			--============================================================
			function Section:CreateKeybind(opts)
				opts = opts or {}
				local current = opts.Default
				local callback = opts.Callback or function() end
				local listening = false

				local holder = Utility.Create("Frame", {
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 30),
					Parent = body,
				})
				local label = Utility.Create("TextLabel", {
					BackgroundTransparency = 1,
					Size = UDim2.new(1, -90, 1, 0),
					Font = Enum.Font.GothamMedium,
					Text = opts.Title or "Keybind",
					TextColor3 = ActiveTheme.Text,
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Left,
					Parent = holder,
				})
				RegisterThemed(label, { TextColor3 = "Text" })

				local keyBtn = Utility.Create("TextButton", {
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, 0, 0.5, 0),
					Size = UDim2.new(0, 80, 0, 26),
					BackgroundColor3 = ActiveTheme.SurfaceLight,
					AutoButtonColor = false,
					Font = Enum.Font.Code,
					Text = current and current.Name or "None",
					TextColor3 = ActiveTheme.Text,
					TextSize = 12,
					Parent = holder,
				})
				RegisterThemed(keyBtn, { BackgroundColor3 = "SurfaceLight", TextColor3 = "Text" })
				Utility.Round(keyBtn, 6)

				keyBtn.MouseButton1Click:Connect(function()
					listening = true
					keyBtn.Text = "..."
				end)

				Utility.Connect(UserInputService.InputBegan, function(input, processed)
					if listening and input.UserInputType == Enum.UserInputType.Keyboard then
						current = input.KeyCode
						keyBtn.Text = current.Name
						listening = false
						return
					end
					if not processed and current and input.KeyCode == current then
						local ok, err = pcall(callback, current)
						if not ok then
							warn("[MacUI] Keybind callback error: " .. tostring(err))
						end
					end
				end)

				local api = {}
				function api:SetValue(keyCode)
					current = keyCode
					keyBtn.Text = keyCode and keyCode.Name or "None"
				end
				function api:GetValue()
					return current
				end
				if opts.Flag then
					ConfigSystem.Register(opts.Flag, function()
						return current and current.Name or nil
					end, function(v)
						if v then
							current = Enum.KeyCode[v]
							keyBtn.Text = current and current.Name or "None"
						end
					end)
				end
				return api
			end

			--============================================================
			-- ELEMENT: Color Picker (simple HSV square + hue slider)
			--============================================================
			function Section:CreateColorPicker(opts)
				opts = opts or {}
				local color = opts.Default or Color3.fromRGB(150, 110, 255)
				local callback = opts.Callback or function() end
				local h, s, v = Color3.toHSV(color)

				local holder = Utility.Create("Frame", {
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 30),
					Parent = body,
				})
				local label = Utility.Create("TextLabel", {
					BackgroundTransparency = 1,
					Size = UDim2.new(1, -60, 1, 0),
					Font = Enum.Font.GothamMedium,
					Text = opts.Title or "Color",
					TextColor3 = ActiveTheme.Text,
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Left,
					Parent = holder,
				})
				RegisterThemed(label, { TextColor3 = "Text" })

				local swatch = Utility.Create("TextButton", {
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, 0, 0.5, 0),
					Size = UDim2.new(0, 40, 0, 22),
					BackgroundColor3 = color,
					AutoButtonColor = false,
					Text = "",
					Parent = holder,
				})
				Utility.Round(swatch, 6)
				Utility.Stroke(swatch, ActiveTheme.Text, 1, 0.6)

				local panel = Utility.Create("Frame", {
					BackgroundColor3 = ActiveTheme.Surface,
					Position = UDim2.new(0, 0, 1, 4),
					Size = UDim2.new(1, 0, 0, 130),
					Visible = false,
					ZIndex = 10,
					Parent = holder,
				})
				RegisterThemed(panel, { BackgroundColor3 = "Surface" })
				Utility.Round(panel, 8)
				Utility.Stroke(panel, ActiveTheme.Accent, 1, 0.7)
				Utility.Padding(panel, 10)

				local svBox = Utility.Create("ImageButton", {
					Size = UDim2.new(1, 0, 0, 80),
					BackgroundColor3 = Color3.fromHSV(h, 1, 1),
					AutoButtonColor = false,
					ZIndex = 11,
					Parent = panel,
				})
				Utility.Round(svBox, 6)
				Utility.Gradient(svBox, ColorSequence.new(Color3.new(1, 1, 1), Color3.new(1, 1, 1)))
				local satGradient = svBox:FindFirstChildOfClass("UIGradient")
				satGradient.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromHSV(h, 1, 1))
				local valOverlay = Utility.Create("Frame", {
					BackgroundColor3 = Color3.new(0, 0, 0),
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 1, 0),
					ZIndex = 11,
					Parent = svBox,
				})
				Utility.Gradient(valOverlay, ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
					ColorSequenceKeypoint.new(1, Color3.new(0, 0, 0)),
				}), 90)
				valOverlay.BackgroundTransparency = 0
				local valGradient = valOverlay:FindFirstChildOfClass("UIGradient")
				valGradient.Transparency = NumberSequence.new(0, 0)

				local svCursor = Utility.Create("Frame", {
					Size = UDim2.new(0, 8, 0, 8),
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundColor3 = Color3.new(1, 1, 1),
					ZIndex = 12,
					Parent = svBox,
				})
				Utility.Round(svCursor, 4)
				Utility.Stroke(svCursor, Color3.new(0, 0, 0), 1, 0)

				local hueBar = Utility.Create("Frame", {
					Position = UDim2.new(0, 0, 0, 90),
					Size = UDim2.new(1, 0, 0, 16),
					ZIndex = 11,
					Parent = panel,
				})
				Utility.Round(hueBar, 6)
				local hueGradient = Utility.Gradient(hueBar, ColorSequence.new({
					ColorSequenceKeypoint.new(0.00, Color3.fromHSV(0, 1, 1)),
					ColorSequenceKeypoint.new(0.17, Color3.fromHSV(1 / 6, 1, 1)),
					ColorSequenceKeypoint.new(0.33, Color3.fromHSV(2 / 6, 1, 1)),
					ColorSequenceKeypoint.new(0.50, Color3.fromHSV(3 / 6, 1, 1)),
					ColorSequenceKeypoint.new(0.67, Color3.fromHSV(4 / 6, 1, 1)),
					ColorSequenceKeypoint.new(0.83, Color3.fromHSV(5 / 6, 1, 1)),
					ColorSequenceKeypoint.new(1.00, Color3.fromHSV(1, 1, 1)),
				}))

				local hueCursor = Utility.Create("Frame", {
					Size = UDim2.new(0, 4, 1, 4),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.new(h, 0, 0.5, 0),
					BackgroundColor3 = Color3.new(1, 1, 1),
					ZIndex = 12,
					Parent = hueBar,
				})

				local function updateColor(fireCallback)
					color = Color3.fromHSV(h, s, v)
					swatch.BackgroundColor3 = color
					satGradient.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromHSV(h, 1, 1))
					svBox.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
					svCursor.Position = UDim2.new(s, 0, 1 - v, 0)
					hueCursor.Position = UDim2.new(h, 0, 0.5, 0)
					if fireCallback then
						local ok, err = pcall(callback, color)
						if not ok then
							warn("[MacUI] ColorPicker callback error: " .. tostring(err))
						end
					end
				end

				local draggingSV, draggingHue = false, false

				svBox.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						draggingSV = true
					end
				end)
				hueBar.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						draggingHue = true
					end
				end)
				Utility.Connect(UserInputService.InputEnded, function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						draggingSV = false
						draggingHue = false
					end
				end)
				Utility.Connect(UserInputService.InputChanged, function(input)
					if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
						return
					end
					if draggingSV then
						local pos = svBox.AbsolutePosition
						local size = svBox.AbsoluteSize
						s = math.clamp((input.Position.X - pos.X) / size.X, 0, 1)
						v = 1 - math.clamp((input.Position.Y - pos.Y) / size.Y, 0, 1)
						updateColor(true)
					elseif draggingHue then
						local pos = hueBar.AbsolutePosition
						local size = hueBar.AbsoluteSize
						h = math.clamp((input.Position.X - pos.X) / size.X, 0, 1)
						updateColor(true)
					end
				end)

				swatch.MouseButton1Click:Connect(function()
					panel.Visible = not panel.Visible
				end)

				updateColor(false)

				local api = {}
				function api:SetValue(c)
					h, s, v = Color3.toHSV(c)
					updateColor(true)
				end
				function api:GetValue()
					return color
				end
				if opts.Flag then
					ConfigSystem.Register(opts.Flag, function()
						return { color.R, color.G, color.B }
					end, function(val)
						if type(val) == "table" then
							h, s, v = Color3.toHSV(Color3.new(val[1], val[2], val[3]))
							updateColor(true)
						end
					end)
				end
				return api
			end

			table.insert(Tab.Sections, Section)
			return Section
		end

		return Tab
	end

	------------------------------------------------------------------
	-- AUTO REPAIR SYSTEM
	-- Periodically verifies critical UI parts still exist / are parented
	-- correctly and repairs only the damaged piece (no full reload).
	------------------------------------------------------------------
	task.spawn(function()
		while true do
			task.wait(2)
			if not ScreenGui or not ScreenGui.Parent then
				pcall(protectGui, ScreenGui)
			end
			if Main and Main.Parent ~= ScreenGui then
				pcall(function()
					Main.Parent = ScreenGui
				end)
			end
			if Main and not Main:FindFirstChildOfClass("UICorner") then
				Utility.Round(Main, 14)
			end
			if Shadow and Shadow.Parent ~= ScreenGui then
				pcall(function()
					Shadow.Parent = ScreenGui
				end)
			end
			-- re-clamp window inside viewport in case resolution changed
			if Main then
				local viewport = ScreenGui.AbsoluteSize
				local pos = Main.Position
				local absSize = Main.AbsoluteSize
				local minX, minY = -absSize.X + 60, 0
				local maxX, maxY = viewport.X - 60, viewport.Y - 30
				local clampedX = math.clamp(pos.X.Offset, minX, maxX)
				local clampedY = math.clamp(pos.Y.Offset, minY, maxY)
				if clampedX ~= pos.X.Offset or clampedY ~= pos.Y.Offset then
					Main.Position = UDim2.new(pos.X.Scale, clampedX, pos.Y.Scale, clampedY)
				end
			end
		end
	end)

	function Window:SetTitle(newTitle)
		TitleLabel.Text = newTitle
	end

	function Window:Destroy()
		Library:Destroy()
	end

	return Window
end

return Library
