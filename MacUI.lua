--[[
    MacUI.lua
    A production-quality Roblox UI Library inspired by macOS
    Version: 1.0.0
    
    Usage:
        local Library = loadstring(game:HttpGet("URL"))()
        local Window = Library:CreateWindow({ Title = "MyApp", Version = "1.0" })
        local Tab = Window:CreateTab("Home")
        local Section = Tab:CreateSection("General")
        Section:CreateToggle({ Name = "My Toggle", Default = false, Callback = function(v) print(v) end })
--]]

-- ============================================================
-- SERVICES
-- ============================================================
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local Players          = game:GetService("Players")
local HttpService      = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")
local Camera      = workspace.CurrentCamera

-- ============================================================
-- UTILITY
-- ============================================================
local Utility = {}

function Utility.Tween(instance, info, props)
    local tween = TweenService:Create(instance, info, props)
    tween:Play()
    return tween
end

function Utility.Spring(instance, props, duration, style, direction)
    local info = TweenInfo.new(
        duration or 0.3,
        style or Enum.EasingStyle.Quart,
        direction or Enum.EasingDirection.Out
    )
    return Utility.Tween(instance, info, props)
end

function Utility.Fade(instance, targetAlpha, duration)
    return Utility.Spring(instance, { BackgroundTransparency = targetAlpha }, duration or 0.2)
end

function Utility.Ripple(button)
    local ripple = Instance.new("Frame")
    ripple.Name = "Ripple"
    ripple.AnchorPoint = Vector2.new(0.5, 0.5)
    ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ripple.BackgroundTransparency = 0.8
    ripple.BorderSizePixel = 0
    ripple.Position = UDim2.new(0.5, 0, 0.5, 0)
    ripple.Size = UDim2.new(0, 0, 0, 0)
    ripple.ZIndex = button.ZIndex + 10
    ripple.ClipsDescendants = false
    Instance.new("UICorner", ripple).CornerRadius = UDim.new(1, 0)
    ripple.Parent = button

    local size = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2
    Utility.Spring(ripple, {
        Size = UDim2.new(0, size, 0, size),
        BackgroundTransparency = 1
    }, 0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

    task.delay(0.5, function()
        ripple:Destroy()
    end)
end

function Utility.MakeCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = parent
    return c
end

function Utility.MakePadding(parent, top, right, bottom, left)
    local p = Instance.new("UIPadding")
    p.PaddingTop    = UDim.new(0, top    or 8)
    p.PaddingRight  = UDim.new(0, right  or 8)
    p.PaddingBottom = UDim.new(0, bottom or 8)
    p.PaddingLeft   = UDim.new(0, left   or 8)
    p.Parent = parent
    return p
end

function Utility.MakeStroke(parent, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color or Color3.fromRGB(100, 80, 140)
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0.5
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

function Utility.MakeGradient(parent, c0, c1, rotation)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, c0 or Color3.fromRGB(60, 40, 90)),
        ColorSequenceKeypoint.new(1, c1 or Color3.fromRGB(30, 20, 50))
    })
    g.Rotation = rotation or 90
    g.Parent = parent
    return g
end

function Utility.MakeList(parent, padding, fillDir, sortOrder)
    local l = Instance.new("UIListLayout")
    l.Padding = UDim.new(0, padding or 6)
    l.FillDirection = fillDir or Enum.FillDirection.Vertical
    l.SortOrder = sortOrder or Enum.SortOrder.LayoutOrder
    l.Parent = parent
    return l
end

function Utility.ColorToHex(color)
    return string.format("#%02X%02X%02X",
        math.floor(color.R * 255),
        math.floor(color.G * 255),
        math.floor(color.B * 255)
    )
end

function Utility.HexToColor(hex)
    hex = hex:gsub("#", "")
    return Color3.fromRGB(
        tonumber(hex:sub(1,2), 16),
        tonumber(hex:sub(3,4), 16),
        tonumber(hex:sub(5,6), 16)
    )
end

function Utility.Clamp(val, min, max)
    return math.max(min, math.min(max, val))
end

function Utility.Round(val, step)
    if step and step ~= 0 then
        return math.round(val / step) * step
    end
    return val
end

function Utility.CreateSignal()
    local signal = {}
    local connections = {}
    
    function signal:Connect(fn)
        table.insert(connections, fn)
        return {
            Disconnect = function()
                for i, v in ipairs(connections) do
                    if v == fn then
                        table.remove(connections, i)
                        break
                    end
                end
            end
        }
    end
    
    function signal:Fire(...)
        for _, fn in ipairs(connections) do
            task.spawn(fn, ...)
        end
    end
    
    function signal:DisconnectAll()
        connections = {}
    end
    
    return signal
end

-- ============================================================
-- THEME ENGINE
-- ============================================================
local ThemeEngine = {}
ThemeEngine.__index = ThemeEngine

local Themes = {
    DarkPurple = {
        Background        = Color3.fromRGB(18, 12, 28),
        BackgroundSecond  = Color3.fromRGB(25, 17, 40),
        Surface           = Color3.fromRGB(32, 22, 52),
        SurfaceAlt        = Color3.fromRGB(40, 28, 64),
        Border            = Color3.fromRGB(80, 55, 120),
        Accent            = Color3.fromRGB(140, 90, 220),
        AccentDark        = Color3.fromRGB(100, 60, 180),
        AccentLight       = Color3.fromRGB(180, 130, 255),
        Text              = Color3.fromRGB(240, 235, 255),
        TextSecond        = Color3.fromRGB(180, 165, 210),
        TextMuted         = Color3.fromRGB(120, 105, 150),
        Success           = Color3.fromRGB(80, 200, 120),
        Warning           = Color3.fromRGB(255, 190, 60),
        Error             = Color3.fromRGB(255, 80, 80),
        Info              = Color3.fromRGB(80, 160, 255),
        WindowBG          = Color3.fromRGB(20, 13, 32),
        TitleBar          = Color3.fromRGB(28, 18, 46),
        Sidebar           = Color3.fromRGB(22, 15, 36),
        Toggle            = Color3.fromRGB(140, 90, 220),
        ToggleOff         = Color3.fromRGB(60, 50, 80),
        Slider            = Color3.fromRGB(140, 90, 220),
        SliderBg          = Color3.fromRGB(50, 38, 72),
    },
    DarkBlue = {
        Background        = Color3.fromRGB(10, 15, 30),
        BackgroundSecond  = Color3.fromRGB(15, 22, 44),
        Surface           = Color3.fromRGB(20, 30, 58),
        SurfaceAlt        = Color3.fromRGB(28, 40, 72),
        Border            = Color3.fromRGB(50, 80, 160),
        Accent            = Color3.fromRGB(80, 140, 255),
        AccentDark        = Color3.fromRGB(50, 100, 200),
        AccentLight       = Color3.fromRGB(130, 180, 255),
        Text              = Color3.fromRGB(230, 238, 255),
        TextSecond        = Color3.fromRGB(170, 190, 230),
        TextMuted         = Color3.fromRGB(110, 130, 170),
        Success           = Color3.fromRGB(80, 200, 120),
        Warning           = Color3.fromRGB(255, 190, 60),
        Error             = Color3.fromRGB(255, 80, 80),
        Info              = Color3.fromRGB(80, 160, 255),
        WindowBG          = Color3.fromRGB(12, 18, 36),
        TitleBar          = Color3.fromRGB(18, 25, 50),
        Sidebar           = Color3.fromRGB(14, 20, 40),
        Toggle            = Color3.fromRGB(80, 140, 255),
        ToggleOff         = Color3.fromRGB(40, 50, 80),
        Slider            = Color3.fromRGB(80, 140, 255),
        SliderBg          = Color3.fromRGB(30, 45, 80),
    },
    DarkGreen = {
        Background        = Color3.fromRGB(10, 22, 15),
        BackgroundSecond  = Color3.fromRGB(14, 30, 20),
        Surface           = Color3.fromRGB(18, 40, 28),
        SurfaceAlt        = Color3.fromRGB(24, 52, 36),
        Border            = Color3.fromRGB(40, 120, 70),
        Accent            = Color3.fromRGB(60, 200, 100),
        AccentDark        = Color3.fromRGB(40, 150, 70),
        AccentLight       = Color3.fromRGB(100, 230, 140),
        Text              = Color3.fromRGB(220, 250, 230),
        TextSecond        = Color3.fromRGB(160, 210, 180),
        TextMuted         = Color3.fromRGB(100, 150, 120),
        Success           = Color3.fromRGB(80, 200, 120),
        Warning           = Color3.fromRGB(255, 190, 60),
        Error             = Color3.fromRGB(255, 80, 80),
        Info              = Color3.fromRGB(80, 160, 255),
        WindowBG          = Color3.fromRGB(12, 25, 18),
        TitleBar          = Color3.fromRGB(16, 34, 24),
        Sidebar           = Color3.fromRGB(13, 22, 16),
        Toggle            = Color3.fromRGB(60, 200, 100),
        ToggleOff         = Color3.fromRGB(30, 60, 40),
        Slider            = Color3.fromRGB(60, 200, 100),
        SliderBg          = Color3.fromRGB(25, 55, 35),
    },
    DarkOrange = {
        Background        = Color3.fromRGB(25, 15, 8),
        BackgroundSecond  = Color3.fromRGB(35, 22, 12),
        Surface           = Color3.fromRGB(45, 28, 16),
        SurfaceAlt        = Color3.fromRGB(58, 36, 20),
        Border            = Color3.fromRGB(160, 90, 30),
        Accent            = Color3.fromRGB(255, 140, 40),
        AccentDark        = Color3.fromRGB(200, 100, 20),
        AccentLight       = Color3.fromRGB(255, 190, 100),
        Text              = Color3.fromRGB(255, 245, 230),
        TextSecond        = Color3.fromRGB(220, 200, 170),
        TextMuted         = Color3.fromRGB(160, 140, 110),
        Success           = Color3.fromRGB(80, 200, 120),
        Warning           = Color3.fromRGB(255, 190, 60),
        Error             = Color3.fromRGB(255, 80, 80),
        Info              = Color3.fromRGB(80, 160, 255),
        WindowBG          = Color3.fromRGB(28, 17, 9),
        TitleBar          = Color3.fromRGB(38, 24, 13),
        Sidebar           = Color3.fromRGB(25, 15, 8),
        Toggle            = Color3.fromRGB(255, 140, 40),
        ToggleOff         = Color3.fromRGB(70, 45, 25),
        Slider            = Color3.fromRGB(255, 140, 40),
        SliderBg          = Color3.fromRGB(60, 40, 20),
    },
    Cyber = {
        Background        = Color3.fromRGB(5, 8, 18),
        BackgroundSecond  = Color3.fromRGB(8, 12, 25),
        Surface           = Color3.fromRGB(12, 18, 35),
        SurfaceAlt        = Color3.fromRGB(16, 24, 46),
        Border            = Color3.fromRGB(0, 200, 180),
        Accent            = Color3.fromRGB(0, 255, 220),
        AccentDark        = Color3.fromRGB(0, 180, 160),
        AccentLight       = Color3.fromRGB(100, 255, 240),
        Text              = Color3.fromRGB(200, 255, 250),
        TextSecond        = Color3.fromRGB(140, 210, 205),
        TextMuted         = Color3.fromRGB(80, 150, 145),
        Success           = Color3.fromRGB(80, 200, 120),
        Warning           = Color3.fromRGB(255, 190, 60),
        Error             = Color3.fromRGB(255, 80, 80),
        Info              = Color3.fromRGB(80, 160, 255),
        WindowBG          = Color3.fromRGB(6, 9, 20),
        TitleBar          = Color3.fromRGB(10, 14, 30),
        Sidebar           = Color3.fromRGB(7, 10, 22),
        Toggle            = Color3.fromRGB(0, 255, 220),
        ToggleOff         = Color3.fromRGB(20, 40, 50),
        Slider            = Color3.fromRGB(0, 255, 220),
        SliderBg          = Color3.fromRGB(15, 35, 45),
    },
    Neon = {
        Background        = Color3.fromRGB(8, 5, 15),
        BackgroundSecond  = Color3.fromRGB(12, 8, 22),
        Surface           = Color3.fromRGB(18, 12, 32),
        SurfaceAlt        = Color3.fromRGB(24, 16, 42),
        Border            = Color3.fromRGB(255, 0, 140),
        Accent            = Color3.fromRGB(255, 50, 180),
        AccentDark        = Color3.fromRGB(200, 0, 120),
        AccentLight       = Color3.fromRGB(255, 130, 220),
        Text              = Color3.fromRGB(255, 240, 255),
        TextSecond        = Color3.fromRGB(210, 180, 220),
        TextMuted         = Color3.fromRGB(150, 120, 165),
        Success           = Color3.fromRGB(80, 255, 150),
        Warning           = Color3.fromRGB(255, 220, 0),
        Error             = Color3.fromRGB(255, 60, 60),
        Info              = Color3.fromRGB(0, 200, 255),
        WindowBG          = Color3.fromRGB(9, 6, 18),
        TitleBar          = Color3.fromRGB(15, 10, 28),
        Sidebar           = Color3.fromRGB(10, 7, 20),
        Toggle            = Color3.fromRGB(255, 50, 180),
        ToggleOff         = Color3.fromRGB(50, 30, 60),
        Slider            = Color3.fromRGB(255, 50, 180),
        SliderBg          = Color3.fromRGB(40, 20, 55),
    },
    Light = {
        Background        = Color3.fromRGB(245, 245, 248),
        BackgroundSecond  = Color3.fromRGB(238, 238, 245),
        Surface           = Color3.fromRGB(255, 255, 255),
        SurfaceAlt        = Color3.fromRGB(248, 246, 255),
        Border            = Color3.fromRGB(200, 190, 230),
        Accent            = Color3.fromRGB(120, 70, 200),
        AccentDark        = Color3.fromRGB(90, 50, 160),
        AccentLight       = Color3.fromRGB(160, 120, 240),
        Text              = Color3.fromRGB(30, 20, 50),
        TextSecond        = Color3.fromRGB(80, 65, 110),
        TextMuted         = Color3.fromRGB(140, 120, 170),
        Success           = Color3.fromRGB(40, 160, 80),
        Warning           = Color3.fromRGB(200, 140, 0),
        Error             = Color3.fromRGB(200, 50, 50),
        Info              = Color3.fromRGB(50, 120, 220),
        WindowBG          = Color3.fromRGB(248, 248, 252),
        TitleBar          = Color3.fromRGB(240, 238, 250),
        Sidebar           = Color3.fromRGB(235, 233, 248),
        Toggle            = Color3.fromRGB(120, 70, 200),
        ToggleOff         = Color3.fromRGB(200, 196, 220),
        Slider            = Color3.fromRGB(120, 70, 200),
        SliderBg          = Color3.fromRGB(210, 205, 235),
    },
}

ThemeEngine.Current = "DarkPurple"
ThemeEngine.Custom  = {}
ThemeEngine.OnChanged = Utility.CreateSignal()

function ThemeEngine:GetTheme(name)
    if name == "Custom" then
        return self.Custom
    end
    return Themes[name] or Themes["DarkPurple"]
end

function ThemeEngine:Get(key)
    local theme = self:GetTheme(self.Current)
    return theme[key] or Color3.fromRGB(255, 255, 255)
end

function ThemeEngine:SetTheme(name, customData)
    if name == "Custom" and customData then
        -- Merge with default to fill missing keys
        local base = Themes["DarkPurple"]
        self.Custom = {}
        for k, v in pairs(base) do
            self.Custom[k] = customData[k] or v
        end
    end
    self.Current = name
    self.OnChanged:Fire(self:GetTheme(name))
end

function ThemeEngine:RegisterCustomTheme(data)
    local base = Themes["DarkPurple"]
    self.Custom = {}
    for k, v in pairs(base) do
        self.Custom[k] = data[k] or v
    end
end

-- ============================================================
-- CONFIG SYSTEM
-- ============================================================
local ConfigSystem = {}
ConfigSystem.__index = ConfigSystem

ConfigSystem._store = {}
ConfigSystem._autoSaveConnections = {}
ConfigSystem._autoSaveEnabled = false
ConfigSystem._configFolder = nil

function ConfigSystem:Init()
    -- Try to create a folder via AttributeService workaround (session-only storage)
    -- For cross-session, user should export JSON and host it themselves
    self._store = {}
end

function ConfigSystem:Set(key, value)
    self._store[key] = value
    if self._autoSaveEnabled then
        self:Save()
    end
end

function ConfigSystem:Get(key, default)
    local val = self._store[key]
    if val == nil then return default end
    return val
end

function ConfigSystem:Save()
    local ok, encoded = pcall(function()
        return HttpService:JSONEncode(self._store)
    end)
    if ok then
        -- Store in a StringValue under PlayerGui for session persistence
        local holder = PlayerGui:FindFirstChild("_MacUIConfig")
        if not holder then
            holder = Instance.new("StringValue")
            holder.Name = "_MacUIConfig"
            holder.Parent = PlayerGui
        end
        holder.Value = encoded
        return true
    end
    return false, "Failed to encode config"
end

function ConfigSystem:Load()
    local holder = PlayerGui:FindFirstChild("_MacUIConfig")
    if holder and holder.Value ~= "" then
        local ok, data = pcall(function()
            return HttpService:JSONDecode(holder.Value)
        end)
        if ok and type(data) == "table" then
            self._store = data
            return true
        end
    end
    return false
end

function ConfigSystem:Delete(key)
    self._store[key] = nil
end

function ConfigSystem:Export()
    local ok, encoded = pcall(function()
        return HttpService:JSONEncode(self._store)
    end)
    if ok then return encoded end
    return nil
end

function ConfigSystem:Import(jsonString)
    local ok, data = pcall(function()
        return HttpService:JSONDecode(jsonString)
    end)
    if ok and type(data) == "table" then
        self._store = data
        return true
    end
    return false
end

function ConfigSystem:EnableAutoSave(interval)
    self._autoSaveEnabled = true
    interval = interval or 30
    task.spawn(function()
        while self._autoSaveEnabled do
            task.wait(interval)
            self:Save()
        end
    end)
end

function ConfigSystem:DisableAutoSave()
    self._autoSaveEnabled = false
end

function ConfigSystem:Reset()
    self._store = {}
    self:Save()
end

ConfigSystem:Init()

-- ============================================================
-- AUTO REPAIR SYSTEM
-- ============================================================
local AutoRepair = {}
AutoRepair.__index = AutoRepair

AutoRepair._checks = {}
AutoRepair._running = false

function AutoRepair:RegisterCheck(id, checkFn, repairFn)
    self._checks[id] = { check = checkFn, repair = repairFn }
end

function AutoRepair:Start(interval)
    if self._running then return end
    self._running = true
    interval = interval or 2

    task.spawn(function()
        while self._running do
            task.wait(interval)
            for id, entry in pairs(self._checks) do
                local ok, damaged = pcall(entry.check)
                if ok and damaged then
                    task.spawn(function()
                        pcall(entry.repair)
                    end)
                end
            end
        end
    end)
end

function AutoRepair:Stop()
    self._running = false
end

function AutoRepair:Unregister(id)
    self._checks[id] = nil
end

-- ============================================================
-- NOTIFICATION SYSTEM
-- ============================================================
local NotificationSystem = {}
NotificationSystem.__index = NotificationSystem
NotificationSystem._queue = {}
NotificationSystem._active = {}
NotificationSystem._maxVisible = 4
NotificationSystem._container = nil
NotificationSystem._nextY = 0

function NotificationSystem:Init(screenGui)
    local container = Instance.new("Frame")
    container.Name = "NotificationContainer"
    container.Size = UDim2.new(0, 320, 1, 0)
    container.Position = UDim2.new(1, -330, 0, 0)
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    container.ZIndex = 1000
    container.Parent = screenGui

    Utility.MakeList(container, 8, Enum.FillDirection.Vertical, Enum.SortOrder.LayoutOrder)
    Utility.MakePadding(container, 16, 0, 16, 0)

    self._container = container
end

function NotificationSystem:Notify(config)
    config = config or {}
    local notifType = config.Type or "Info"
    local title     = config.Title or "Notification"
    local message   = config.Message or ""
    local duration  = config.Duration or 4
    local callback  = config.Callback

    -- Type colors
    local typeColors = {
        Success = ThemeEngine:Get("Success"),
        Info    = ThemeEngine:Get("Info"),
        Warning = ThemeEngine:Get("Warning"),
        Error   = ThemeEngine:Get("Error"),
        Loading = ThemeEngine:Get("Accent"),
    }
    local typeIcons = {
        Success = "✓", Info = "ℹ", Warning = "⚠", Error = "✕", Loading = "⟳"
    }

    local accentColor = typeColors[notifType] or typeColors.Info
    local icon = typeIcons[notifType] or "ℹ"

    -- Build notification frame
    local card = Instance.new("Frame")
    card.Name = "Notification"
    card.Size = UDim2.new(1, 0, 0, 70)
    card.BackgroundColor3 = ThemeEngine:Get("Surface")
    card.BackgroundTransparency = 0.15
    card.BorderSizePixel = 0
    card.ClipsDescendants = true
    card.AutomaticSize = Enum.AutomaticSize.Y
    Utility.MakeCorner(card, 12)
    Utility.MakeStroke(card, ThemeEngine:Get("Border"), 1, 0.4)

    -- Left accent stripe
    local stripe = Instance.new("Frame")
    stripe.Name = "Stripe"
    stripe.Size = UDim2.new(0, 4, 1, 0)
    stripe.Position = UDim2.new(0, 0, 0, 0)
    stripe.BackgroundColor3 = accentColor
    stripe.BorderSizePixel = 0
    stripe.ZIndex = card.ZIndex + 1
    stripe.Parent = card

    -- Content
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -12, 1, 0)
    content.Position = UDim2.new(0, 12, 0, 0)
    content.BackgroundTransparency = 1
    content.AutomaticSize = Enum.AutomaticSize.Y
    content.Parent = card
    Utility.MakePadding(content, 12, 12, 12, 8)

    local iconLabel = Instance.new("TextLabel")
    iconLabel.Size = UDim2.new(0, 22, 0, 22)
    iconLabel.Position = UDim2.new(0, 0, 0, 0)
    iconLabel.BackgroundColor3 = accentColor
    iconLabel.BackgroundTransparency = 0.7
    iconLabel.TextColor3 = accentColor
    iconLabel.Text = icon
    iconLabel.Font = Enum.Font.GothamBold
    iconLabel.TextSize = 13
    iconLabel.TextXAlignment = Enum.TextXAlignment.Center
    iconLabel.TextYAlignment = Enum.TextYAlignment.Center
    iconLabel.BorderSizePixel = 0
    iconLabel.ZIndex = card.ZIndex + 2
    iconLabel.Parent = content
    Utility.MakeCorner(iconLabel, 6)

    if notifType == "Loading" then
        task.spawn(function()
            local angle = 0
            while card and card.Parent do
                angle = (angle + 5) % 360
                iconLabel.Text = ({"⟳","⟲","⟳"})[math.floor(angle/120)%2+1]
                task.wait(0.1)
            end
        end)
    end

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -32, 0, 18)
    titleLabel.Position = UDim2.new(0, 30, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextColor3 = ThemeEngine:Get("Text")
    titleLabel.Text = title
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 13
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.ZIndex = card.ZIndex + 2
    titleLabel.Parent = content

    local msgLabel = Instance.new("TextLabel")
    msgLabel.Size = UDim2.new(1, 0, 0, 0)
    msgLabel.Position = UDim2.new(0, 0, 0, 22)
    msgLabel.BackgroundTransparency = 1
    msgLabel.TextColor3 = ThemeEngine:Get("TextSecond")
    msgLabel.Text = message
    msgLabel.Font = Enum.Font.Gotham
    msgLabel.TextSize = 11
    msgLabel.TextXAlignment = Enum.TextXAlignment.Left
    msgLabel.TextWrapped = true
    msgLabel.AutomaticSize = Enum.AutomaticSize.Y
    msgLabel.ZIndex = card.ZIndex + 2
    msgLabel.Parent = content

    -- Progress bar for auto-close
    local progressBg = Instance.new("Frame")
    progressBg.Size = UDim2.new(1, 0, 0, 2)
    progressBg.Position = UDim2.new(0, 0, 1, -2)
    progressBg.BackgroundColor3 = ThemeEngine:Get("SurfaceAlt")
    progressBg.BorderSizePixel = 0
    progressBg.ZIndex = card.ZIndex + 3
    progressBg.Parent = card

    local progressBar = Instance.new("Frame")
    progressBar.Size = UDim2.new(1, 0, 1, 0)
    progressBar.BackgroundColor3 = accentColor
    progressBar.BorderSizePixel = 0
    progressBar.ZIndex = card.ZIndex + 4
    progressBar.Parent = progressBg

    card.Parent = self._container

    -- Slide in
    card.Position = UDim2.new(1, 20, 0, 0)
    Utility.Spring(card, { Position = UDim2.new(0, 0, 0, 0) }, 0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

    table.insert(self._active, card)

    -- Click to dismiss
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.ZIndex = card.ZIndex + 10
    btn.Parent = card
    btn.MouseButton1Click:Connect(function()
        if callback then callback() end
        self:_dismiss(card)
    end)

    -- Auto close with progress
    if notifType ~= "Loading" then
        task.spawn(function()
            local elapsed = 0
            local step = 0.05
            while elapsed < duration and card and card.Parent do
                task.wait(step)
                elapsed = elapsed + step
                local pct = 1 - (elapsed / duration)
                if progressBar and progressBar.Parent then
                    progressBar.Size = UDim2.new(pct, 0, 1, 0)
                end
            end
            self:_dismiss(card)
        end)
    end

    return card
end

function NotificationSystem:_dismiss(card)
    if not card or not card.Parent then return end

    -- Remove from active
    for i, v in ipairs(self._active) do
        if v == card then table.remove(self._active, i) break end
    end

    Utility.Spring(card, { Position = UDim2.new(1, 20, 0, 0) }, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
    task.delay(0.35, function()
        if card and card.Parent then
            card:Destroy()
        end
    end)
end

function NotificationSystem:DismissAll()
    for _, card in ipairs(self._active) do
        self:_dismiss(card)
    end
end

-- ============================================================
-- DIALOG SYSTEM
-- ============================================================
local DialogSystem = {}
DialogSystem.__index = DialogSystem

function DialogSystem:CreateDialog(screenGui, config)
    config = config or {}

    local overlay = Instance.new("Frame")
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    overlay.BackgroundTransparency = 0.5
    overlay.BorderSizePixel = 0
    overlay.ZIndex = 900
    overlay.Parent = screenGui

    local dialog = Instance.new("Frame")
    dialog.Size = UDim2.new(0, 360, 0, 0)
    dialog.Position = UDim2.new(0.5, -180, 0.5, 0)
    dialog.AnchorPoint = Vector2.new(0, 0.5)
    dialog.BackgroundColor3 = ThemeEngine:Get("Surface")
    dialog.BackgroundTransparency = 0.1
    dialog.BorderSizePixel = 0
    dialog.AutomaticSize = Enum.AutomaticSize.Y
    dialog.ZIndex = 901
    Utility.MakeCorner(dialog, 14)
    Utility.MakeStroke(dialog, ThemeEngine:Get("Border"), 1, 0.3)
    dialog.Parent = screenGui

    Utility.MakePadding(dialog, 20, 20, 20, 20)
    local listLayout = Utility.MakeList(dialog, 12, Enum.FillDirection.Vertical, Enum.SortOrder.LayoutOrder)

    -- Title
    if config.Title then
        local titleLabel = Instance.new("TextLabel")
        titleLabel.Size = UDim2.new(1, 0, 0, 22)
        titleLabel.BackgroundTransparency = 1
        titleLabel.TextColor3 = ThemeEngine:Get("Text")
        titleLabel.Text = config.Title
        titleLabel.Font = Enum.Font.GothamBold
        titleLabel.TextSize = 16
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.ZIndex = 902
        titleLabel.LayoutOrder = 1
        titleLabel.Parent = dialog
    end

    -- Message
    if config.Message then
        local msgLabel = Instance.new("TextLabel")
        msgLabel.Size = UDim2.new(1, 0, 0, 0)
        msgLabel.AutomaticSize = Enum.AutomaticSize.Y
        msgLabel.BackgroundTransparency = 1
        msgLabel.TextColor3 = ThemeEngine:Get("TextSecond")
        msgLabel.Text = config.Message
        msgLabel.Font = Enum.Font.Gotham
        msgLabel.TextSize = 13
        msgLabel.TextXAlignment = Enum.TextXAlignment.Left
        msgLabel.TextWrapped = true
        msgLabel.ZIndex = 902
        msgLabel.LayoutOrder = 2
        msgLabel.Parent = dialog
    end

    -- Progress bar (for progress type)
    local progressRef = nil
    if config.Type == "Progress" then
        local progressBg = Instance.new("Frame")
        progressBg.Size = UDim2.new(1, 0, 0, 8)
        progressBg.BackgroundColor3 = ThemeEngine:Get("SliderBg")
        progressBg.BorderSizePixel = 0
        progressBg.ZIndex = 902
        progressBg.LayoutOrder = 3
        Utility.MakeCorner(progressBg, 4)
        progressBg.Parent = dialog

        local progressFill = Instance.new("Frame")
        progressFill.Size = UDim2.new(0, 0, 1, 0)
        progressFill.BackgroundColor3 = ThemeEngine:Get("Accent")
        progressFill.BorderSizePixel = 0
        progressFill.ZIndex = 903
        Utility.MakeCorner(progressFill, 4)
        progressFill.Parent = progressBg
        progressRef = progressFill
    end

    -- Input field
    local inputRef = nil
    if config.Type == "Input" then
        local inputBg = Instance.new("Frame")
        inputBg.Size = UDim2.new(1, 0, 0, 36)
        inputBg.BackgroundColor3 = ThemeEngine:Get("Background")
        inputBg.BorderSizePixel = 0
        inputBg.ZIndex = 902
        inputBg.LayoutOrder = 3
        Utility.MakeCorner(inputBg, 8)
        Utility.MakeStroke(inputBg, ThemeEngine:Get("Border"), 1, 0.4)
        inputBg.Parent = dialog

        local inputBox = Instance.new("TextBox")
        inputBox.Size = UDim2.new(1, -16, 1, 0)
        inputBox.Position = UDim2.new(0, 8, 0, 0)
        inputBox.BackgroundTransparency = 1
        inputBox.TextColor3 = ThemeEngine:Get("Text")
        inputBox.PlaceholderColor3 = ThemeEngine:Get("TextMuted")
        inputBox.PlaceholderText = config.Placeholder or "Enter text..."
        inputBox.Text = ""
        inputBox.Font = Enum.Font.Gotham
        inputBox.TextSize = 13
        inputBox.TextXAlignment = Enum.TextXAlignment.Left
        inputBox.ZIndex = 903
        inputBox.Parent = inputBg
        inputRef = inputBox
    end

    -- Buttons
    local buttonFrame = Instance.new("Frame")
    buttonFrame.Size = UDim2.new(1, 0, 0, 36)
    buttonFrame.BackgroundTransparency = 1
    buttonFrame.LayoutOrder = 10
    buttonFrame.Parent = dialog
    Utility.MakeList(buttonFrame, 8, Enum.FillDirection.Horizontal, Enum.SortOrder.LayoutOrder)

    local function close()
        Utility.Spring(overlay, { BackgroundTransparency = 1 }, 0.2)
        Utility.Spring(dialog, { Size = UDim2.new(0, 360, 0, 0) }, 0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        task.delay(0.25, function()
            overlay:Destroy()
            dialog:Destroy()
        end)
    end

    local function makeButton(text, color, layoutOrder, onClick)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.5, -4, 1, 0)
        btn.BackgroundColor3 = color
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Text = text
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 13
        btn.BorderSizePixel = 0
        btn.ZIndex = 902
        btn.LayoutOrder = layoutOrder
        Utility.MakeCorner(btn, 8)
        btn.Parent = buttonFrame
        btn.MouseButton1Click:Connect(function()
            Utility.Ripple(btn)
            task.delay(0.1, function()
                close()
                if onClick then onClick() end
            end)
        end)
        return btn
    end

    local dialogType = config.Type or "Confirm"

    if dialogType == "Confirm" or dialogType == "Input" then
        makeButton(config.CancelText or "Cancel", ThemeEngine:Get("SurfaceAlt"), 1, function()
            if config.OnCancel then config.OnCancel() end
        end)
        makeButton(config.ConfirmText or "Confirm", ThemeEngine:Get("Accent"), 2, function()
            if dialogType == "Input" then
                if config.OnConfirm then config.OnConfirm(inputRef and inputRef.Text or "") end
            else
                if config.OnConfirm then config.OnConfirm() end
            end
        end)
    elseif dialogType == "Loading" then
        -- No buttons for loading, return control function
    elseif dialogType == "Progress" then
        makeButton("Cancel", ThemeEngine:Get("SurfaceAlt"), 1, function()
            if config.OnCancel then config.OnCancel() end
        end)
    end

    -- Entrance animation
    dialog.Size = UDim2.new(0, 360, 0, 0)
    task.defer(function()
        Utility.Spring(dialog, { Position = UDim2.new(0.5, -180, 0.5, 0) }, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    end)

    local handle = {
        Close = close,
        SetProgress = function(self, value)
            if progressRef then
                Utility.Spring(progressRef, { Size = UDim2.new(Utility.Clamp(value, 0, 1), 0, 1, 0) }, 0.3)
            end
        end
    }
    return handle
end

-- ============================================================
-- MACUI MAIN LIBRARY
-- ============================================================
local MacUI = {}
MacUI.__index = MacUI
MacUI.Version = "1.0.0"
MacUI.Theme = ThemeEngine
MacUI.Config = ConfigSystem
MacUI.Notify = function(_, ...) return NotificationSystem:Notify(...) end

-- Internal state
MacUI._windows = {}
MacUI._screenGui = nil
MacUI._connections = {}

function MacUI:Init()
    -- Remove previous instance
    local existing = PlayerGui:FindFirstChild("MacUI")
    if existing then existing:Destroy() end

    local gui = Instance.new("ScreenGui")
    gui.Name = "MacUI"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.DisplayOrder = 100
    gui.IgnoreGuiInset = true
    gui.Parent = PlayerGui

    self._screenGui = gui

    NotificationSystem:Init(gui)
    AutoRepair:Start(3)

    ConfigSystem:Load()

    -- Auto repair: check ScreenGui exists
    AutoRepair:RegisterCheck("ScreenGui", function()
        return not (PlayerGui:FindFirstChild("MacUI"))
    end, function()
        self:Init()
        for _, win in ipairs(self._windows) do
            if win and win._repair then win:_repair() end
        end
    end)

    return self
end

function MacUI:SetTheme(name, customData)
    ThemeEngine:SetTheme(name, customData)
end

function MacUI:Notify(config)
    return NotificationSystem:Notify(config)
end

function MacUI:DismissAll()
    NotificationSystem:DismissAll()
end

function MacUI:Dialog(config)
    return DialogSystem:CreateDialog(self._screenGui, config)
end

function MacUI:CreateWindow(config)
    config = config or {}
    local Window = {}
    Window.__index = Window
    setmetatable(Window, { __index = MacUI })

    local title     = config.Title    or "MacUI"
    local subtitle  = config.Subtitle or ""
    local version   = config.Version  or ""
    local logoId    = config.Logo
    local watermark = config.Watermark
    local executorInfo = config.ExecutorInfo or ""
    local showClock = config.Clock   ~= false
    local showFPS   = config.FPS     ~= false

    Window._tabs = {}
    Window._activeTab = nil
    Window._minimized = false
    Window._connections = {}
    Window._sidebarCollapsed = false

    -- --------------------------------
    -- Root Frame
    -- --------------------------------
    local rootFrame = Instance.new("Frame")
    rootFrame.Name = "Window_" .. title
    rootFrame.Size = UDim2.new(0, 720, 0, 480)
    rootFrame.Position = UDim2.new(0.5, -360, 0.5, -240)
    rootFrame.BackgroundColor3 = ThemeEngine:Get("WindowBG")
    rootFrame.BackgroundTransparency = 0.05
    rootFrame.BorderSizePixel = 0
    rootFrame.ClipsDescendants = true
    rootFrame.ZIndex = 10
    Utility.MakeCorner(rootFrame, 14)
    Utility.MakeStroke(rootFrame, ThemeEngine:Get("Border"), 1, 0.35)
    rootFrame.Parent = MacUI._screenGui
    Window._rootFrame = rootFrame

    -- Subtle gradient background
    Utility.MakeGradient(rootFrame,
        ThemeEngine:Get("WindowBG"),
        ThemeEngine:Get("BackgroundSecond"),
        135
    )

    -- Drop shadow (simulated via a background frame)
    local shadow = Instance.new("ImageLabel")
    shadow.Size = UDim2.new(1, 40, 1, 40)
    shadow.Position = UDim2.new(0, -20, 0, 10)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://6014054489"
    shadow.ImageColor3 = Color3.fromRGB(0,0,0)
    shadow.ImageTransparency = 0.5
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    shadow.ZIndex = rootFrame.ZIndex - 1
    shadow.Parent = MacUI._screenGui
    Window._shadow = shadow

    -- --------------------------------
    -- Title Bar
    -- --------------------------------
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 42)
    titleBar.BackgroundColor3 = ThemeEngine:Get("TitleBar")
    titleBar.BackgroundTransparency = 0.1
    titleBar.BorderSizePixel = 0
    titleBar.ZIndex = rootFrame.ZIndex + 1
    titleBar.Parent = rootFrame
    Window._titleBar = titleBar

    -- Separator line
    local titleSep = Instance.new("Frame")
    titleSep.Size = UDim2.new(1, 0, 0, 1)
    titleSep.Position = UDim2.new(0, 0, 1, -1)
    titleSep.BackgroundColor3 = ThemeEngine:Get("Border")
    titleSep.BackgroundTransparency = 0.5
    titleSep.BorderSizePixel = 0
    titleSep.ZIndex = titleBar.ZIndex + 1
    titleSep.Parent = titleBar

    -- Traffic Light Buttons
    local tlContainer = Instance.new("Frame")
    tlContainer.Size = UDim2.new(0, 70, 0, 14)
    tlContainer.Position = UDim2.new(0, 12, 0.5, -7)
    tlContainer.BackgroundTransparency = 1
    tlContainer.ZIndex = titleBar.ZIndex + 2
    tlContainer.Parent = titleBar
    Utility.MakeList(tlContainer, 7, Enum.FillDirection.Horizontal, Enum.SortOrder.LayoutOrder)

    local function makeTrafficLight(color, layoutOrder)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 14, 0, 14)
        btn.BackgroundColor3 = color
        btn.BorderSizePixel = 0
        btn.Text = ""
        btn.ZIndex = tlContainer.ZIndex + 1
        btn.LayoutOrder = layoutOrder
        Utility.MakeCorner(btn, 7)
        btn.Parent = tlContainer

        -- Hover glow
        btn.MouseEnter:Connect(function()
            Utility.Spring(btn, { BackgroundTransparency = 0.2 }, 0.15)
        end)
        btn.MouseLeave:Connect(function()
            Utility.Spring(btn, { BackgroundTransparency = 0 }, 0.15)
        end)

        return btn
    end

    local closeBtn    = makeTrafficLight(Color3.fromRGB(255, 95, 87), 1)
    local minimizeBtn = makeTrafficLight(Color3.fromRGB(255, 189, 68), 2)
    local maximizeBtn = makeTrafficLight(Color3.fromRGB(40, 200, 64), 3)

    -- Logo
    if logoId then
        local logo = Instance.new("ImageLabel")
        logo.Size = UDim2.new(0, 24, 0, 24)
        logo.Position = UDim2.new(0, 90, 0.5, -12)
        logo.BackgroundTransparency = 1
        logo.Image = logoId
        logo.ZIndex = titleBar.ZIndex + 2
        logo.Parent = titleBar
    end

    -- Title text
    local titleOffset = logoId and 120 or 90
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(0, 300, 1, 0)
    titleLabel.Position = UDim2.new(0, titleOffset, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextColor3 = ThemeEngine:Get("Text")
    titleLabel.Text = title .. (version ~= "" and (" v" .. version) or "") .. (subtitle ~= "" and (" — " .. subtitle) or "")
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 13
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.ZIndex = titleBar.ZIndex + 2
    titleLabel.Parent = titleBar

    -- Right side info (Clock, FPS, Executor)
    local rightContainer = Instance.new("Frame")
    rightContainer.Size = UDim2.new(0, 220, 1, 0)
    rightContainer.Position = UDim2.new(1, -230, 0, 0)
    rightContainer.BackgroundTransparency = 1
    rightContainer.ZIndex = titleBar.ZIndex + 2
    rightContainer.Parent = titleBar
    Utility.MakeList(rightContainer, 8, Enum.FillDirection.Horizontal, Enum.SortOrder.LayoutOrder)
    -- Align right using a spacer approach
    local filler = Instance.new("Frame")
    filler.Size = UDim2.new(1, 0, 1, 0)
    filler.BackgroundTransparency = 1
    filler.LayoutOrder = 0
    filler.Parent = rightContainer

    local function makeInfoLabel(text, order)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0, 70, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.TextColor3 = ThemeEngine:Get("TextMuted")
        lbl.Text = text
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 11
        lbl.TextXAlignment = Enum.TextXAlignment.Right
        lbl.ZIndex = rightContainer.ZIndex + 1
        lbl.LayoutOrder = order
        lbl.Parent = rightContainer
        return lbl
    end

    local executorLabel, clockLabel, fpsLabel
    if executorInfo ~= "" then
        executorLabel = makeInfoLabel(executorInfo, 1)
    end
    if showFPS then
        fpsLabel = makeInfoLabel("-- fps", 2)
    end
    if showClock then
        clockLabel = makeInfoLabel("--:--", 3)
    end

    -- Update clock & FPS
    task.spawn(function()
        while rootFrame and rootFrame.Parent do
            if clockLabel then
                local t = os.date("*t")
                clockLabel.Text = string.format("%02d:%02d", t.hour, t.min)
            end
            task.wait(1)
        end
    end)

    if showFPS then
        local frameCount = 0
        local elapsed = 0
        local fpsConn = RunService.RenderStepped:Connect(function(dt)
            frameCount += 1
            elapsed += dt
            if elapsed >= 0.5 then
                if fpsLabel and fpsLabel.Parent then
                    fpsLabel.Text = math.floor(frameCount / elapsed) .. " fps"
                end
                frameCount = 0
                elapsed = 0
            end
        end)
        table.insert(Window._connections, fpsConn)
    end

    -- --------------------------------
    -- Body (Sidebar + Content)
    -- --------------------------------
    local body = Instance.new("Frame")
    body.Name = "Body"
    body.Size = UDim2.new(1, 0, 1, -42)
    body.Position = UDim2.new(0, 0, 0, 42)
    body.BackgroundTransparency = 1
    body.ZIndex = rootFrame.ZIndex + 1
    body.Parent = rootFrame
    Window._body = body

    -- Sidebar
    local SIDEBAR_WIDTH = 160
    local SIDEBAR_COLLAPSED_WIDTH = 48

    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, SIDEBAR_WIDTH, 1, 0)
    sidebar.BackgroundColor3 = ThemeEngine:Get("Sidebar")
    sidebar.BackgroundTransparency = 0.1
    sidebar.BorderSizePixel = 0
    sidebar.ZIndex = body.ZIndex + 1
    sidebar.ClipsDescendants = true
    sidebar.Parent = body
    Window._sidebar = sidebar

    local sidebarSep = Instance.new("Frame")
    sidebarSep.Size = UDim2.new(0, 1, 1, 0)
    sidebarSep.Position = UDim2.new(1, -1, 0, 0)
    sidebarSep.BackgroundColor3 = ThemeEngine:Get("Border")
    sidebarSep.BackgroundTransparency = 0.4
    sidebarSep.BorderSizePixel = 0
    sidebarSep.ZIndex = sidebar.ZIndex + 1
    sidebarSep.Parent = sidebar

    local sidebarScroll = Instance.new("ScrollingFrame")
    sidebarScroll.Size = UDim2.new(1, 0, 1, -8)
    sidebarScroll.Position = UDim2.new(0, 0, 0, 8)
    sidebarScroll.BackgroundTransparency = 1
    sidebarScroll.BorderSizePixel = 0
    sidebarScroll.ScrollBarThickness = 2
    sidebarScroll.ScrollBarImageColor3 = ThemeEngine:Get("Accent")
    sidebarScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    sidebarScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    sidebarScroll.ZIndex = sidebar.ZIndex + 1
    sidebarScroll.Parent = sidebar

    local sidebarList = Utility.MakeList(sidebarScroll, 3, Enum.FillDirection.Vertical, Enum.SortOrder.LayoutOrder)
    Utility.MakePadding(sidebarScroll, 6, 6, 6, 6)

    -- Collapse button
    local collapseBtn = Instance.new("TextButton")
    collapseBtn.Size = UDim2.new(1, -16, 0, 28)
    collapseBtn.Position = UDim2.new(0, 8, 1, -34)
    collapseBtn.BackgroundColor3 = ThemeEngine:Get("SurfaceAlt")
    collapseBtn.BackgroundTransparency = 0.6
    collapseBtn.Text = "◀"
    collapseBtn.TextColor3 = ThemeEngine:Get("TextMuted")
    collapseBtn.Font = Enum.Font.GothamBold
    collapseBtn.TextSize = 11
    collapseBtn.BorderSizePixel = 0
    collapseBtn.ZIndex = sidebar.ZIndex + 2
    Utility.MakeCorner(collapseBtn, 6)
    collapseBtn.Parent = sidebar

    -- Content area
    local contentArea = Instance.new("Frame")
    contentArea.Name = "ContentArea"
    contentArea.Size = UDim2.new(1, -SIDEBAR_WIDTH, 1, 0)
    contentArea.Position = UDim2.new(0, SIDEBAR_WIDTH, 0, 0)
    contentArea.BackgroundTransparency = 1
    contentArea.ZIndex = body.ZIndex + 1
    contentArea.Parent = body
    Window._contentArea = contentArea

    -- Collapse/Expand sidebar
    collapseBtn.MouseButton1Click:Connect(function()
        Window._sidebarCollapsed = not Window._sidebarCollapsed
        if Window._sidebarCollapsed then
            Utility.Spring(sidebar, { Size = UDim2.new(0, SIDEBAR_COLLAPSED_WIDTH, 1, 0) }, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
            Utility.Spring(contentArea, {
                Size = UDim2.new(1, -SIDEBAR_COLLAPSED_WIDTH, 1, 0),
                Position = UDim2.new(0, SIDEBAR_COLLAPSED_WIDTH, 0, 0)
            }, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
            task.delay(0.1, function()
                collapseBtn.Text = "▶"
            end)
        else
            Utility.Spring(sidebar, { Size = UDim2.new(0, SIDEBAR_WIDTH, 1, 0) }, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
            Utility.Spring(contentArea, {
                Size = UDim2.new(1, -SIDEBAR_WIDTH, 1, 0),
                Position = UDim2.new(0, SIDEBAR_WIDTH, 0, 0)
            }, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
            task.delay(0.1, function()
                collapseBtn.Text = "◀"
            end)
        end
    end)

    -- --------------------------------
    -- Drag Window
    -- --------------------------------
    do
        local dragging = false
        local dragStart, startPos

        titleBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or
               input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = rootFrame.Position
            end
        end)

        local dragConn = UserInputService.InputChanged:Connect(function(input)
            if dragging and (
                input.UserInputType == Enum.UserInputType.MouseMovement or
                input.UserInputType == Enum.UserInputType.Touch
            ) then
                local delta = input.Position - dragStart
                local vp = Camera.ViewportSize

                local newX = Utility.Clamp(
                    startPos.X.Offset + delta.X,
                    0,
                    vp.X - rootFrame.AbsoluteSize.X
                )
                local newY = Utility.Clamp(
                    startPos.Y.Offset + delta.Y,
                    0,
                    vp.Y - rootFrame.AbsoluteSize.Y
                )

                rootFrame.Position = UDim2.new(0, newX, 0, newY)
                shadow.Position = UDim2.new(0, newX - 20, 0, newY + 10)
            end
        end)

        local endConn = UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or
               input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)

        table.insert(Window._connections, dragConn)
        table.insert(Window._connections, endConn)
    end

    -- --------------------------------
    -- Traffic Light Actions
    -- --------------------------------
    closeBtn.MouseButton1Click:Connect(function()
        Utility.Ripple(closeBtn)
        Window:Hide()
    end)

    minimizeBtn.MouseButton1Click:Connect(function()
        Utility.Ripple(minimizeBtn)
        Window:Minimize()
    end)

    local maximized = false
    local normalSize, normalPos
    maximizeBtn.MouseButton1Click:Connect(function()
        Utility.Ripple(maximizeBtn)
        local vp = Camera.ViewportSize
        if not maximized then
            normalSize = rootFrame.Size
            normalPos  = rootFrame.Position
            Utility.Spring(rootFrame, {
                Size = UDim2.new(0, vp.X - 40, 0, vp.Y - 40),
                Position = UDim2.new(0, 20, 0, 20)
            }, 0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        else
            Utility.Spring(rootFrame, { Size = normalSize, Position = normalPos }, 0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        end
        maximized = not maximized
    end)

    -- Watermark
    if watermark then
        local wm = Instance.new("TextLabel")
        wm.Size = UDim2.new(0, 200, 0, 18)
        wm.Position = UDim2.new(1, -210, 1, -24)
        wm.BackgroundTransparency = 1
        wm.TextColor3 = ThemeEngine:Get("TextMuted")
        wm.Text = watermark
        wm.Font = Enum.Font.Gotham
        wm.TextSize = 10
        wm.TextXAlignment = Enum.TextXAlignment.Right
        wm.ZIndex = rootFrame.ZIndex + 5
        wm.Parent = rootFrame
    end

    -- --------------------------------
    -- Window Methods
    -- --------------------------------
    function Window:Show()
        rootFrame.Visible = true
        shadow.Visible = true
        Utility.Spring(rootFrame, { BackgroundTransparency = 0.05 }, 0.2)
    end

    function Window:Hide()
        Utility.Spring(rootFrame, { BackgroundTransparency = 1 }, 0.2)
        task.delay(0.25, function()
            if rootFrame then rootFrame.Visible = false end
            if shadow then shadow.Visible = false end
        end)
    end

    function Window:Minimize()
        if not self._minimized then
            local targetH = 42
            Utility.Spring(rootFrame, { Size = UDim2.new(0, rootFrame.Size.X.Offset, 0, targetH) }, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
            self._minimized = true
        else
            Utility.Spring(rootFrame, { Size = UDim2.new(0, rootFrame.Size.X.Offset, 0, 480) }, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
            self._minimized = false
        end
    end

    function Window:SetTitle(newTitle)
        titleLabel.Text = newTitle
    end

    function Window:LockPosition()
        -- Disable drag by setting titleBar input to inactive
        titleBar.Active = false
    end

    function Window:UnlockPosition()
        titleBar.Active = true
    end

    function Window:SetPosition(x, y)
        rootFrame.Position = UDim2.new(0, x, 0, y)
        shadow.Position = UDim2.new(0, x - 20, 0, y + 10)
    end

    function Window:Destroy()
        for _, conn in ipairs(self._connections) do
            if conn then pcall(function() conn:Disconnect() end) end
        end
        if rootFrame then rootFrame:Destroy() end
        if shadow then shadow:Destroy() end
    end

    -- --------------------------------
    -- Create Tab
    -- --------------------------------
    function Window:CreateTab(tabName, tabIcon)
        local Tab = {}
        Tab.__index = Tab
        Tab._sections = {}
        Tab._name = tabName

        -- Sidebar button
        local tabBtn = Instance.new("TextButton")
        tabBtn.Name = "Tab_" .. tabName
        tabBtn.Size = UDim2.new(1, -8, 0, 36)
        tabBtn.BackgroundColor3 = ThemeEngine:Get("SurfaceAlt")
        tabBtn.BackgroundTransparency = 1
        tabBtn.Text = ""
        tabBtn.BorderSizePixel = 0
        tabBtn.ZIndex = sidebarScroll.ZIndex + 1
        tabBtn.LayoutOrder = #self._tabs + 1
        Utility.MakeCorner(tabBtn, 8)
        tabBtn.Parent = sidebarScroll

        -- Active indicator
        local activeBar = Instance.new("Frame")
        activeBar.Size = UDim2.new(0, 3, 0.7, 0)
        activeBar.Position = UDim2.new(0, 0, 0.15, 0)
        activeBar.BackgroundColor3 = ThemeEngine:Get("Accent")
        activeBar.BackgroundTransparency = 1
        activeBar.BorderSizePixel = 0
        activeBar.ZIndex = tabBtn.ZIndex + 1
        Utility.MakeCorner(activeBar, 2)
        activeBar.Parent = tabBtn

        -- Icon
        if tabIcon then
            local iconLbl = Instance.new("TextLabel")
            iconLbl.Size = UDim2.new(0, 18, 0, 18)
            iconLbl.Position = UDim2.new(0, 10, 0.5, -9)
            iconLbl.BackgroundTransparency = 1
            iconLbl.TextColor3 = ThemeEngine:Get("TextSecond")
            iconLbl.Text = tabIcon
            iconLbl.Font = Enum.Font.GothamBold
            iconLbl.TextSize = 14
            iconLbl.ZIndex = tabBtn.ZIndex + 2
            iconLbl.Parent = tabBtn
            Tab._iconLabel = iconLbl
        end

        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, tabIcon and -36 or -16, 1, 0)
        nameLabel.Position = UDim2.new(0, tabIcon and 34 or 12, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.TextColor3 = ThemeEngine:Get("TextSecond")
        nameLabel.Text = tabName
        nameLabel.Font = Enum.Font.Gotham
        nameLabel.TextSize = 13
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.ZIndex = tabBtn.ZIndex + 2
        nameLabel.Parent = tabBtn
        Tab._nameLabel = nameLabel

        -- Tab content page
        local page = Instance.new("ScrollingFrame")
        page.Name = "Page_" .. tabName
        page.Size = UDim2.new(1, 0, 1, 0)
        page.BackgroundTransparency = 1
        page.BorderSizePixel = 0
        page.ScrollBarThickness = 3
        page.ScrollBarImageColor3 = ThemeEngine:Get("Accent")
        page.CanvasSize = UDim2.new(0, 0, 0, 0)
        page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        page.Visible = false
        page.ZIndex = contentArea.ZIndex + 1
        page.Parent = contentArea

        Utility.MakePadding(page, 14, 14, 14, 14)
        Utility.MakeList(page, 10, Enum.FillDirection.Vertical, Enum.SortOrder.LayoutOrder)

        Tab._page = page
        Tab._tabBtn = tabBtn
        Tab._activeBar = activeBar
        Tab._nameLabel = nameLabel

        table.insert(self._tabs, Tab)

        local function selectTab()
            -- Deactivate all
            for _, t in ipairs(Window._tabs) do
                Utility.Spring(t._tabBtn, { BackgroundTransparency = 1 }, 0.2)
                Utility.Spring(t._activeBar, { BackgroundTransparency = 1 }, 0.2)
                t._nameLabel.Font = Enum.Font.Gotham
                t._nameLabel.TextColor3 = ThemeEngine:Get("TextSecond")
                t._page.Visible = false
            end

            -- Activate this tab
            Utility.Spring(tabBtn, { BackgroundTransparency = 0.75 }, 0.2)
            Utility.Spring(activeBar, { BackgroundTransparency = 0 }, 0.2)
            nameLabel.Font = Enum.Font.GothamBold
            nameLabel.TextColor3 = ThemeEngine:Get("Text")
            page.Visible = true
            Window._activeTab = Tab

            -- Page fade in
            page.BackgroundTransparency = 1
        end

        tabBtn.MouseButton1Click:Connect(function()
            Utility.Ripple(tabBtn)
            selectTab()
        end)

        tabBtn.MouseEnter:Connect(function()
            if Window._activeTab ~= Tab then
                Utility.Spring(tabBtn, { BackgroundTransparency = 0.88 }, 0.15)
            end
        end)
        tabBtn.MouseLeave:Connect(function()
            if Window._activeTab ~= Tab then
                Utility.Spring(tabBtn, { BackgroundTransparency = 1 }, 0.15)
            end
        end)

        -- Auto-select first tab
        if #Window._tabs == 1 then
            selectTab()
        end

        -- --------------------------------
        -- Create Section
        -- --------------------------------
        function Tab:CreateSection(sectionName)
            local Section = {}
            Section.__index = Section
            Section._elements = {}
            Section._collapsed = false

            local sectionFrame = Instance.new("Frame")
            sectionFrame.Name = "Section_" .. sectionName
            sectionFrame.Size = UDim2.new(1, 0, 0, 0)
            sectionFrame.AutomaticSize = Enum.AutomaticSize.Y
            sectionFrame.BackgroundColor3 = ThemeEngine:Get("Surface")
            sectionFrame.BackgroundTransparency = 0.15
            sectionFrame.BorderSizePixel = 0
            sectionFrame.LayoutOrder = #Tab._sections + 1
            Utility.MakeCorner(sectionFrame, 10)
            Utility.MakeStroke(sectionFrame, ThemeEngine:Get("Border"), 1, 0.55)
            sectionFrame.Parent = page
            Section._frame = sectionFrame

            Utility.MakePadding(sectionFrame, 10, 10, 10, 10)

            -- Header
            local headerBtn = Instance.new("TextButton")
            headerBtn.Size = UDim2.new(1, 0, 0, 26)
            headerBtn.BackgroundTransparency = 1
            headerBtn.Text = ""
            headerBtn.BorderSizePixel = 0
            headerBtn.ZIndex = sectionFrame.ZIndex + 1
            headerBtn.LayoutOrder = 0
            headerBtn.Parent = sectionFrame

            local headerLabel = Instance.new("TextLabel")
            headerLabel.Size = UDim2.new(1, -24, 1, 0)
            headerLabel.BackgroundTransparency = 1
            headerLabel.TextColor3 = ThemeEngine:Get("Text")
            headerLabel.Text = sectionName
            headerLabel.Font = Enum.Font.GothamBold
            headerLabel.TextSize = 13
            headerLabel.TextXAlignment = Enum.TextXAlignment.Left
            headerLabel.ZIndex = sectionFrame.ZIndex + 2
            headerLabel.Parent = headerBtn

            local chevron = Instance.new("TextLabel")
            chevron.Size = UDim2.new(0, 18, 1, 0)
            chevron.Position = UDim2.new(1, -20, 0, 0)
            chevron.BackgroundTransparency = 1
            chevron.TextColor3 = ThemeEngine:Get("TextMuted")
            chevron.Text = "▾"
            chevron.Font = Enum.Font.GothamBold
            chevron.TextSize = 13
            chevron.ZIndex = sectionFrame.ZIndex + 2
            chevron.Parent = headerBtn

            local contentHolder = Instance.new("Frame")
            contentHolder.Name = "Content"
            contentHolder.Size = UDim2.new(1, 0, 0, 0)
            contentHolder.AutomaticSize = Enum.AutomaticSize.Y
            contentHolder.BackgroundTransparency = 1
            contentHolder.LayoutOrder = 1
            contentHolder.Parent = sectionFrame
            Section._content = contentHolder

            local contentList = Utility.MakeList(contentHolder, 6, Enum.FillDirection.Vertical, Enum.SortOrder.LayoutOrder)

            local topDivider = Instance.new("Frame")
            topDivider.Size = UDim2.new(1, 0, 0, 1)
            topDivider.BackgroundColor3 = ThemeEngine:Get("Border")
            topDivider.BackgroundTransparency = 0.5
            topDivider.BorderSizePixel = 0
            topDivider.LayoutOrder = 0
            topDivider.Parent = contentHolder

            local sectionLayout = Utility.MakeList(sectionFrame, 6, Enum.FillDirection.Vertical, Enum.SortOrder.LayoutOrder)

            -- Collapse toggle
            headerBtn.MouseButton1Click:Connect(function()
                Section._collapsed = not Section._collapsed
                if Section._collapsed then
                    contentHolder.Visible = false
                    Utility.Spring(chevron, { Rotation = -90 }, 0.25)
                else
                    contentHolder.Visible = true
                    Utility.Spring(chevron, { Rotation = 0 }, 0.25)
                end
            end)

            table.insert(Tab._sections, Section)

            -- ============================================================
            -- COMPONENTS
            -- ============================================================

            --[[ BUTTON ]]--
            function Section:CreateButton(config)
                config = config or {}
                local name     = config.Name or "Button"
                local callback = config.Callback or function() end

                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(1, 0, 0, 36)
                btn.BackgroundColor3 = ThemeEngine:Get("Accent")
                btn.BackgroundTransparency = 0.2
                btn.Text = name
                btn.TextColor3 = ThemeEngine:Get("Text")
                btn.Font = Enum.Font.GothamBold
                btn.TextSize = 13
                btn.BorderSizePixel = 0
                btn.LayoutOrder = #self._elements + 1
                Utility.MakeCorner(btn, 8)
                Utility.MakeStroke(btn, ThemeEngine:Get("Accent"), 1, 0.6)
                btn.Parent = contentHolder

                btn.MouseEnter:Connect(function()
                    Utility.Spring(btn, { BackgroundTransparency = 0 }, 0.15)
                end)
                btn.MouseLeave:Connect(function()
                    Utility.Spring(btn, { BackgroundTransparency = 0.2 }, 0.15)
                end)
                btn.MouseButton1Down:Connect(function()
                    Utility.Spring(btn, { BackgroundTransparency = 0.4 }, 0.1)
                    Utility.Ripple(btn)
                end)
                btn.MouseButton1Up:Connect(function()
                    Utility.Spring(btn, { BackgroundTransparency = 0.2 }, 0.1)
                end)
                btn.MouseButton1Click:Connect(function()
                    task.spawn(callback)
                end)

                local element = { Type = "Button", Instance = btn }
                table.insert(self._elements, element)
                return element
            end

            --[[ TOGGLE ]]--
            function Section:CreateToggle(config)
                config = config or {}
                local name     = config.Name or "Toggle"
                local default  = config.Default ~= nil and config.Default or false
                local callback = config.Callback or function() end
                local flag     = config.Flag

                local value = default
                if flag and ConfigSystem:Get(flag) ~= nil then
                    value = ConfigSystem:Get(flag)
                end

                local row = Instance.new("Frame")
                row.Size = UDim2.new(1, 0, 0, 36)
                row.BackgroundTransparency = 1
                row.LayoutOrder = #self._elements + 1
                row.Parent = contentHolder

                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(1, -52, 1, 0)
                label.BackgroundTransparency = 1
                label.TextColor3 = ThemeEngine:Get("Text")
                label.Text = name
                label.Font = Enum.Font.Gotham
                label.TextSize = 13
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.ZIndex = row.ZIndex + 1
                label.Parent = row

                -- Toggle track
                local track = Instance.new("TextButton")
                track.Size = UDim2.new(0, 44, 0, 24)
                track.Position = UDim2.new(1, -46, 0.5, -12)
                track.BackgroundColor3 = value and ThemeEngine:Get("Toggle") or ThemeEngine:Get("ToggleOff")
                track.BorderSizePixel = 0
                track.Text = ""
                track.ZIndex = row.ZIndex + 2
                Utility.MakeCorner(track, 12)
                track.Parent = row

                -- Toggle knob
                local knob = Instance.new("Frame")
                knob.Size = UDim2.new(0, 18, 0, 18)
                knob.Position = value
                    and UDim2.new(1, -21, 0.5, -9)
                    or  UDim2.new(0, 3, 0.5, -9)
                knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                knob.BorderSizePixel = 0
                knob.ZIndex = track.ZIndex + 1
                Utility.MakeCorner(knob, 9)
                knob.Parent = track

                local function setToggle(newVal, silent)
                    value = newVal
                    Utility.Spring(track, {
                        BackgroundColor3 = value and ThemeEngine:Get("Toggle") or ThemeEngine:Get("ToggleOff")
                    }, 0.2)
                    Utility.Spring(knob, {
                        Position = value and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
                    }, 0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
                    if flag then ConfigSystem:Set(flag, value) end
                    if not silent then task.spawn(callback, value) end
                end

                track.MouseButton1Click:Connect(function()
                    setToggle(not value)
                end)

                -- Keyboard accessibility: UserInputService handles global
                local element = {
                    Type = "Toggle",
                    Instance = row,
                    GetValue = function() return value end,
                    SetValue = function(_, v) setToggle(v) end
                }
                table.insert(self._elements, element)
                return element
            end

            --[[ SLIDER ]]--
            function Section:CreateSlider(config)
                config = config or {}
                local name     = config.Name    or "Slider"
                local min      = config.Min     or 0
                local max      = config.Max     or 100
                local default  = config.Default or min
                local step     = config.Step    or 1
                local decimals = config.Decimals or 0
                local suffix   = config.Suffix  or ""
                local callback = config.Callback or function() end
                local flag     = config.Flag

                local value = default
                if flag and ConfigSystem:Get(flag) ~= nil then
                    value = ConfigSystem:Get(flag)
                end
                value = Utility.Clamp(value, min, max)

                local container = Instance.new("Frame")
                container.Size = UDim2.new(1, 0, 0, 52)
                container.BackgroundTransparency = 1
                container.LayoutOrder = #self._elements + 1
                container.Parent = contentHolder

                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(1, -60, 0, 20)
                label.BackgroundTransparency = 1
                label.TextColor3 = ThemeEngine:Get("Text")
                label.Text = name
                label.Font = Enum.Font.Gotham
                label.TextSize = 13
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.ZIndex = container.ZIndex + 1
                label.Parent = container

                local valueLabel = Instance.new("TextLabel")
                valueLabel.Size = UDim2.new(0, 55, 0, 20)
                valueLabel.Position = UDim2.new(1, -58, 0, 0)
                valueLabel.BackgroundTransparency = 1
                valueLabel.TextColor3 = ThemeEngine:Get("Accent")
                valueLabel.Font = Enum.Font.GothamBold
                valueLabel.TextSize = 13
                valueLabel.TextXAlignment = Enum.TextXAlignment.Right
                valueLabel.ZIndex = container.ZIndex + 1
                valueLabel.Parent = container

                local function formatValue(v)
                    if decimals > 0 then
                        return string.format("%." .. decimals .. "f", v) .. suffix
                    end
                    return tostring(math.floor(v)) .. suffix
                end
                valueLabel.Text = formatValue(value)

                -- Slider bar background
                local barBg = Instance.new("Frame")
                barBg.Size = UDim2.new(1, 0, 0, 8)
                barBg.Position = UDim2.new(0, 0, 0, 30)
                barBg.BackgroundColor3 = ThemeEngine:Get("SliderBg")
                barBg.BorderSizePixel = 0
                barBg.ZIndex = container.ZIndex + 1
                Utility.MakeCorner(barBg, 4)
                barBg.Parent = container

                -- Slider fill
                local barFill = Instance.new("Frame")
                barFill.BackgroundColor3 = ThemeEngine:Get("Slider")
                barFill.BorderSizePixel = 0
                barFill.ZIndex = barBg.ZIndex + 1
                Utility.MakeCorner(barFill, 4)
                barFill.Parent = barBg

                -- Slider handle
                local handle = Instance.new("Frame")
                handle.Size = UDim2.new(0, 16, 0, 16)
                handle.AnchorPoint = Vector2.new(0.5, 0.5)
                handle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                handle.BorderSizePixel = 0
                handle.ZIndex = barBg.ZIndex + 2
                Utility.MakeCorner(handle, 8)
                Utility.MakeStroke(handle, ThemeEngine:Get("Slider"), 2, 0)
                handle.Parent = barBg

                -- Hitbox (invisible, bigger than the bar for easier touch)
                local hitbox = Instance.new("TextButton")
                hitbox.Size = UDim2.new(1, 0, 0, 32)
                hitbox.Position = UDim2.new(0, 0, 0.5, -16)
                hitbox.BackgroundTransparency = 1
                hitbox.Text = ""
                hitbox.ZIndex = barBg.ZIndex + 5
                hitbox.Parent = barBg

                local function computeValue(inputX)
                    local absPos  = barBg.AbsolutePosition.X
                    local absSize = barBg.AbsoluteSize.X
                    local relX = Utility.Clamp((inputX - absPos) / absSize, 0, 1)
                    local rawVal = min + relX * (max - min)
                    rawVal = Utility.Round(rawVal, step)
                    return Utility.Clamp(rawVal, min, max)
                end

                local function updateVisual(v)
                    local pct = (v - min) / (max - min)
                    barFill.Size = UDim2.new(pct, 0, 1, 0)
                    handle.Position = UDim2.new(pct, 0, 0.5, 0)
                end

                local function setValue(v, silent)
                    value = Utility.Clamp(v, min, max)
                    updateVisual(value)
                    valueLabel.Text = formatValue(value)
                    if flag then ConfigSystem:Set(flag, value) end
                    if not silent then task.spawn(callback, value) end
                end

                -- Initialize visual
                setValue(value, true)

                local dragging = false
                local lastValue = value

                hitbox.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or
                       input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        local v = computeValue(input.Position.X)
                        setValue(v)
                        lastValue = v
                    end
                end)

                local dragConn = UserInputService.InputChanged:Connect(function(input)
                    if dragging and (
                        input.UserInputType == Enum.UserInputType.MouseMovement or
                        input.UserInputType == Enum.UserInputType.Touch
                    ) then
                        local v = computeValue(input.Position.X)
                        if v ~= lastValue then
                            setValue(v)
                            lastValue = v
                        end
                    end
                end)

                local endConn = UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or
                       input.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                    end
                end)

                table.insert(Window._connections, dragConn)
                table.insert(Window._connections, endConn)

                -- Handle hover effect
                hitbox.MouseEnter:Connect(function()
                    Utility.Spring(handle, { Size = UDim2.new(0, 20, 0, 20) }, 0.15)
                end)
                hitbox.MouseLeave:Connect(function()
                    Utility.Spring(handle, { Size = UDim2.new(0, 16, 0, 16) }, 0.15)
                end)

                local element = {
                    Type = "Slider",
                    Instance = container,
                    GetValue = function() return value end,
                    SetValue = function(_, v) setValue(v) end
                }
                table.insert(self._elements, element)
                return element
            end

            --[[ DROPDOWN ]]--
            function Section:CreateDropdown(config)
                config = config or {}
                local name     = config.Name    or "Dropdown"
                local options  = config.Options or {}
                local default  = config.Default or options[1]
                local callback = config.Callback or function() end
                local flag     = config.Flag

                local selected = default
                if flag and ConfigSystem:Get(flag) ~= nil then
                    selected = ConfigSystem:Get(flag)
                end

                local isOpen = false

                local container = Instance.new("Frame")
                container.Size = UDim2.new(1, 0, 0, 36)
                container.BackgroundTransparency = 1
                container.ClipsDescendants = false
                container.LayoutOrder = #self._elements + 1
                container.Parent = contentHolder
                Section._ddContainer = container

                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(1, -10, 0, 20)
                label.BackgroundTransparency = 1
                label.TextColor3 = ThemeEngine:Get("TextSecond")
                label.Text = name
                label.Font = Enum.Font.Gotham
                label.TextSize = 11
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.ZIndex = container.ZIndex + 1
                label.Parent = container

                local selectBtn = Instance.new("TextButton")
                selectBtn.Size = UDim2.new(1, 0, 0, 32)
                selectBtn.Position = UDim2.new(0, 0, 0, 18)
                selectBtn.BackgroundColor3 = ThemeEngine:Get("SurfaceAlt")
                selectBtn.Text = ""
                selectBtn.BorderSizePixel = 0
                selectBtn.ZIndex = container.ZIndex + 2
                Utility.MakeCorner(selectBtn, 8)
                Utility.MakeStroke(selectBtn, ThemeEngine:Get("Border"), 1, 0.4)
                selectBtn.Parent = container

                local selectedLabel = Instance.new("TextLabel")
                selectedLabel.Size = UDim2.new(1, -36, 1, 0)
                selectedLabel.Position = UDim2.new(0, 10, 0, 0)
                selectedLabel.BackgroundTransparency = 1
                selectedLabel.TextColor3 = ThemeEngine:Get("Text")
                selectedLabel.Text = tostring(selected or "Select...")
                selectedLabel.Font = Enum.Font.Gotham
                selectedLabel.TextSize = 13
                selectedLabel.TextXAlignment = Enum.TextXAlignment.Left
                selectedLabel.ZIndex = selectBtn.ZIndex + 1
                selectedLabel.Parent = selectBtn

                local chevronLabel = Instance.new("TextLabel")
                chevronLabel.Size = UDim2.new(0, 24, 1, 0)
                chevronLabel.Position = UDim2.new(1, -28, 0, 0)
                chevronLabel.BackgroundTransparency = 1
                chevronLabel.TextColor3 = ThemeEngine:Get("TextMuted")
                chevronLabel.Text = "▾"
                chevronLabel.Font = Enum.Font.GothamBold
                chevronLabel.TextSize = 12
                chevronLabel.ZIndex = selectBtn.ZIndex + 1
                chevronLabel.Parent = selectBtn

                -- Dropdown list
                local dropFrame = Instance.new("Frame")
                dropFrame.Name = "DropdownList"
                dropFrame.Size = UDim2.new(1, 0, 0, 0)
                dropFrame.Position = UDim2.new(0, 0, 0, 52)
                dropFrame.BackgroundColor3 = ThemeEngine:Get("Surface")
                dropFrame.BackgroundTransparency = 0.05
                dropFrame.BorderSizePixel = 0
                dropFrame.ZIndex = container.ZIndex + 20
                dropFrame.ClipsDescendants = true
                dropFrame.Visible = false
                Utility.MakeCorner(dropFrame, 8)
                Utility.MakeStroke(dropFrame, ThemeEngine:Get("Border"), 1, 0.3)
                dropFrame.Parent = container

                local scrollFrame = Instance.new("ScrollingFrame")
                scrollFrame.Size = UDim2.new(1, 0, 1, 0)
                scrollFrame.BackgroundTransparency = 1
                scrollFrame.BorderSizePixel = 0
                scrollFrame.ScrollBarThickness = 2
                scrollFrame.ScrollBarImageColor3 = ThemeEngine:Get("Accent")
                scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
                scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
                scrollFrame.ZIndex = dropFrame.ZIndex + 1
                scrollFrame.Parent = dropFrame
                Utility.MakeList(scrollFrame, 2, Enum.FillDirection.Vertical, Enum.SortOrder.LayoutOrder)
                Utility.MakePadding(scrollFrame, 4, 4, 4, 4)

                local function buildOptions()
                    for _, child in ipairs(scrollFrame:GetChildren()) do
                        if child:IsA("Frame") or child:IsA("TextButton") then child:Destroy() end
                    end
                    for i, opt in ipairs(options) do
                        local optBtn = Instance.new("TextButton")
                        optBtn.Size = UDim2.new(1, 0, 0, 30)
                        optBtn.BackgroundColor3 = tostring(opt) == tostring(selected)
                            and ThemeEngine:Get("Accent")
                            or ThemeEngine:Get("SurfaceAlt")
                        optBtn.BackgroundTransparency = tostring(opt) == tostring(selected) and 0.5 or 0.8
                        optBtn.Text = tostring(opt)
                        optBtn.TextColor3 = ThemeEngine:Get("Text")
                        optBtn.Font = Enum.Font.Gotham
                        optBtn.TextSize = 13
                        optBtn.BorderSizePixel = 0
                        optBtn.ZIndex = scrollFrame.ZIndex + 1
                        optBtn.LayoutOrder = i
                        Utility.MakeCorner(optBtn, 6)
                        optBtn.Parent = scrollFrame

                        optBtn.MouseEnter:Connect(function()
                            if tostring(opt) ~= tostring(selected) then
                                Utility.Spring(optBtn, { BackgroundTransparency = 0.6 }, 0.15)
                            end
                        end)
                        optBtn.MouseLeave:Connect(function()
                            if tostring(opt) ~= tostring(selected) then
                                Utility.Spring(optBtn, { BackgroundTransparency = 0.8 }, 0.15)
                            end
                        end)

                        optBtn.MouseButton1Click:Connect(function()
                            selected = opt
                            selectedLabel.Text = tostring(selected)
                            if flag then ConfigSystem:Set(flag, selected) end
                            task.spawn(callback, selected)
                            buildOptions()
                            -- Close
                            isOpen = false
                            Utility.Spring(dropFrame, { Size = UDim2.new(1, 0, 0, 0) }, 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
                            task.delay(0.22, function() dropFrame.Visible = false end)
                            Utility.Spring(chevronLabel, { Rotation = 0 }, 0.2)
                        end)
                    end
                end

                buildOptions()

                local function openDropdown()
                    isOpen = true
                    local itemHeight = 34
                    local maxVisible = 5
                    local totalH = math.min(#options, maxVisible) * itemHeight + 8
                    dropFrame.Visible = true
                    dropFrame.Size = UDim2.new(1, 0, 0, 0)
                    Utility.Spring(dropFrame, { Size = UDim2.new(1, 0, 0, totalH) }, 0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
                    Utility.Spring(chevronLabel, { Rotation = 180 }, 0.2)
                end

                local function closeDropdown()
                    isOpen = false
                    Utility.Spring(dropFrame, { Size = UDim2.new(1, 0, 0, 0) }, 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
                    task.delay(0.22, function() if not isOpen then dropFrame.Visible = false end end)
                    Utility.Spring(chevronLabel, { Rotation = 0 }, 0.2)
                end

                selectBtn.MouseButton1Click:Connect(function()
                    if isOpen then closeDropdown() else openDropdown() end
                end)

                -- Close when clicking outside
                local clickConn = UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or
                       input.UserInputType == Enum.UserInputType.Touch then
                        if isOpen then
                            local mp = input.Position
                            local btnPos = selectBtn.AbsolutePosition
                            local btnSize = selectBtn.AbsoluteSize
                            local dropPos = dropFrame.AbsolutePosition
                            local dropSize = dropFrame.AbsoluteSize

                            local inBtn = mp.X >= btnPos.X and mp.X <= btnPos.X + btnSize.X
                                and mp.Y >= btnPos.Y and mp.Y <= btnPos.Y + btnSize.Y
                            local inDrop = mp.X >= dropPos.X and mp.X <= dropPos.X + dropSize.X
                                and mp.Y >= dropPos.Y and mp.Y <= dropPos.Y + dropSize.Y

                            if not inBtn and not inDrop then
                                closeDropdown()
                            end
                        end
                    end
                end)
                table.insert(Window._connections, clickConn)

                container.Size = UDim2.new(1, 0, 0, 52)

                local element = {
                    Type = "Dropdown",
                    Instance = container,
                    GetValue = function() return selected end,
                    SetValue = function(_, v)
                        selected = v
                        selectedLabel.Text = tostring(v)
                        buildOptions()
                    end,
                    SetOptions = function(_, newOptions)
                        options = newOptions
                        buildOptions()
                    end
                }
                table.insert(self._elements, element)
                return element
            end

            --[[ MULTI DROPDOWN ]]--
            function Section:CreateMultiDropdown(config)
                config = config or {}
                local name     = config.Name    or "MultiDropdown"
                local options  = config.Options or {}
                local default  = config.Default or {}
                local callback = config.Callback or function() end
                local flag     = config.Flag

                local selected = {}
                for _, v in ipairs(default) do selected[v] = true end
                if flag and ConfigSystem:Get(flag) ~= nil then
                    selected = ConfigSystem:Get(flag)
                end

                local isOpen = false

                local container = Instance.new("Frame")
                container.Size = UDim2.new(1, 0, 0, 52)
                container.BackgroundTransparency = 1
                container.ClipsDescendants = false
                container.LayoutOrder = #self._elements + 1
                container.Parent = contentHolder

                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(1, 0, 0, 18)
                label.BackgroundTransparency = 1
                label.TextColor3 = ThemeEngine:Get("TextSecond")
                label.Text = name
                label.Font = Enum.Font.Gotham
                label.TextSize = 11
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.ZIndex = container.ZIndex + 1
                label.Parent = container

                local selectBtn = Instance.new("TextButton")
                selectBtn.Size = UDim2.new(1, 0, 0, 32)
                selectBtn.Position = UDim2.new(0, 0, 0, 18)
                selectBtn.BackgroundColor3 = ThemeEngine:Get("SurfaceAlt")
                selectBtn.Text = ""
                selectBtn.BorderSizePixel = 0
                selectBtn.ZIndex = container.ZIndex + 2
                Utility.MakeCorner(selectBtn, 8)
                Utility.MakeStroke(selectBtn, ThemeEngine:Get("Border"), 1, 0.4)
                selectBtn.Parent = container

                local selectedLabel = Instance.new("TextLabel")
                selectedLabel.Size = UDim2.new(1, -36, 1, 0)
                selectedLabel.Position = UDim2.new(0, 10, 0, 0)
                selectedLabel.BackgroundTransparency = 1
                selectedLabel.TextColor3 = ThemeEngine:Get("Text")
                selectedLabel.Font = Enum.Font.Gotham
                selectedLabel.TextSize = 12
                selectedLabel.TextXAlignment = Enum.TextXAlignment.Left
                selectedLabel.ZIndex = selectBtn.ZIndex + 1
                selectedLabel.Parent = selectBtn

                local chevronLabel = Instance.new("TextLabel")
                chevronLabel.Size = UDim2.new(0, 24, 1, 0)
                chevronLabel.Position = UDim2.new(1, -28, 0, 0)
                chevronLabel.BackgroundTransparency = 1
                chevronLabel.TextColor3 = ThemeEngine:Get("TextMuted")
                chevronLabel.Text = "▾"
                chevronLabel.Font = Enum.Font.GothamBold
                chevronLabel.TextSize = 12
                chevronLabel.ZIndex = selectBtn.ZIndex + 1
                chevronLabel.Parent = selectBtn

                local function getSelectedText()
                    local arr = {}
                    for k, v in pairs(selected) do
                        if v then table.insert(arr, k) end
                    end
                    if #arr == 0 then return "None selected" end
                    return table.concat(arr, ", ")
                end
                selectedLabel.Text = getSelectedText()

                local dropFrame = Instance.new("Frame")
                dropFrame.Size = UDim2.new(1, 0, 0, 0)
                dropFrame.Position = UDim2.new(0, 0, 0, 52)
                dropFrame.BackgroundColor3 = ThemeEngine:Get("Surface")
                dropFrame.BackgroundTransparency = 0.05
                dropFrame.BorderSizePixel = 0
                dropFrame.ZIndex = container.ZIndex + 20
                dropFrame.ClipsDescendants = true
                dropFrame.Visible = false
                Utility.MakeCorner(dropFrame, 8)
                Utility.MakeStroke(dropFrame, ThemeEngine:Get("Border"), 1, 0.3)
                dropFrame.Parent = container

                local scrollFrame = Instance.new("ScrollingFrame")
                scrollFrame.Size = UDim2.new(1, 0, 1, 0)
                scrollFrame.BackgroundTransparency = 1
                scrollFrame.BorderSizePixel = 0
                scrollFrame.ScrollBarThickness = 2
                scrollFrame.ScrollBarImageColor3 = ThemeEngine:Get("Accent")
                scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
                scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
                scrollFrame.ZIndex = dropFrame.ZIndex + 1
                scrollFrame.Parent = dropFrame
                Utility.MakeList(scrollFrame, 2, Enum.FillDirection.Vertical, Enum.SortOrder.LayoutOrder)
                Utility.MakePadding(scrollFrame, 4, 4, 4, 4)

                local function buildOptions()
                    for _, child in ipairs(scrollFrame:GetChildren()) do
                        if child:IsA("Frame") or child:IsA("TextButton") then child:Destroy() end
                    end
                    for i, opt in ipairs(options) do
                        local isChecked = selected[opt] == true
                        local optRow = Instance.new("Frame")
                        optRow.Size = UDim2.new(1, 0, 0, 30)
                        optRow.BackgroundColor3 = isChecked and ThemeEngine:Get("Accent") or ThemeEngine:Get("SurfaceAlt")
                        optRow.BackgroundTransparency = isChecked and 0.5 or 0.8
                        optRow.BorderSizePixel = 0
                        optRow.ZIndex = scrollFrame.ZIndex + 1
                        optRow.LayoutOrder = i
                        Utility.MakeCorner(optRow, 6)
                        optRow.Parent = scrollFrame

                        local checkLbl = Instance.new("TextLabel")
                        checkLbl.Size = UDim2.new(0, 20, 1, 0)
                        checkLbl.Position = UDim2.new(0, 6, 0, 0)
                        checkLbl.BackgroundTransparency = 1
                        checkLbl.TextColor3 = isChecked and ThemeEngine:Get("Accent") or ThemeEngine:Get("TextMuted")
                        checkLbl.Text = isChecked and "✓" or "○"
                        checkLbl.Font = Enum.Font.GothamBold
                        checkLbl.TextSize = 12
                        checkLbl.ZIndex = optRow.ZIndex + 1
                        checkLbl.Parent = optRow

                        local optLbl = Instance.new("TextLabel")
                        optLbl.Size = UDim2.new(1, -30, 1, 0)
                        optLbl.Position = UDim2.new(0, 28, 0, 0)
                        optLbl.BackgroundTransparency = 1
                        optLbl.TextColor3 = ThemeEngine:Get("Text")
                        optLbl.Text = tostring(opt)
                        optLbl.Font = Enum.Font.Gotham
                        optLbl.TextSize = 12
                        optLbl.TextXAlignment = Enum.TextXAlignment.Left
                        optLbl.ZIndex = optRow.ZIndex + 1
                        optLbl.Parent = optRow

                        local hitBtn = Instance.new("TextButton")
                        hitBtn.Size = UDim2.new(1, 0, 1, 0)
                        hitBtn.BackgroundTransparency = 1
                        hitBtn.Text = ""
                        hitBtn.ZIndex = optRow.ZIndex + 2
                        hitBtn.Parent = optRow

                        hitBtn.MouseButton1Click:Connect(function()
                            selected[opt] = not selected[opt]
                            selectedLabel.Text = getSelectedText()
                            if flag then ConfigSystem:Set(flag, selected) end
                            task.spawn(callback, selected)
                            buildOptions()
                        end)
                    end
                end
                buildOptions()

                selectBtn.MouseButton1Click:Connect(function()
                    isOpen = not isOpen
                    if isOpen then
                        local totalH = math.min(#options, 5) * 34 + 8
                        dropFrame.Visible = true
                        dropFrame.Size = UDim2.new(1, 0, 0, 0)
                        Utility.Spring(dropFrame, { Size = UDim2.new(1, 0, 0, totalH) }, 0.25)
                        Utility.Spring(chevronLabel, { Rotation = 180 }, 0.2)
                    else
                        Utility.Spring(dropFrame, { Size = UDim2.new(1, 0, 0, 0) }, 0.2)
                        task.delay(0.22, function() dropFrame.Visible = false end)
                        Utility.Spring(chevronLabel, { Rotation = 0 }, 0.2)
                    end
                end)

                local element = {
                    Type = "MultiDropdown",
                    Instance = container,
                    GetValue = function() return selected end,
                    SetValue = function(_, v) selected = v; selectedLabel.Text = getSelectedText(); buildOptions() end
                }
                table.insert(self._elements, element)
                return element
            end

            --[[ TEXTBOX ]]--
            function Section:CreateTextbox(config)
                config = config or {}
                local name        = config.Name or "Textbox"
                local placeholder = config.Placeholder or "Enter text..."
                local default     = config.Default or ""
                local callback    = config.Callback or function() end
                local clearOnFocus = config.ClearOnFocus ~= false
                local flag        = config.Flag

                local value = default
                if flag and ConfigSystem:Get(flag) ~= nil then
                    value = ConfigSystem:Get(flag)
                end

                local container = Instance.new("Frame")
                container.Size = UDim2.new(1, 0, 0, 54)
                container.BackgroundTransparency = 1
                container.LayoutOrder = #self._elements + 1
                container.Parent = contentHolder

                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(1, 0, 0, 18)
                label.BackgroundTransparency = 1
                label.TextColor3 = ThemeEngine:Get("TextSecond")
                label.Text = name
                label.Font = Enum.Font.Gotham
                label.TextSize = 11
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.ZIndex = container.ZIndex + 1
                label.Parent = container

                local inputBg = Instance.new("Frame")
                inputBg.Size = UDim2.new(1, 0, 0, 32)
                inputBg.Position = UDim2.new(0, 0, 0, 20)
                inputBg.BackgroundColor3 = ThemeEngine:Get("Background")
                inputBg.BorderSizePixel = 0
                inputBg.ZIndex = container.ZIndex + 1
                Utility.MakeCorner(inputBg, 8)
                local inputStroke = Utility.MakeStroke(inputBg, ThemeEngine:Get("Border"), 1, 0.4)
                inputBg.Parent = container

                local inputBox = Instance.new("TextBox")
                inputBox.Size = UDim2.new(1, -16, 1, 0)
                inputBox.Position = UDim2.new(0, 8, 0, 0)
                inputBox.BackgroundTransparency = 1
                inputBox.TextColor3 = ThemeEngine:Get("Text")
                inputBox.PlaceholderColor3 = ThemeEngine:Get("TextMuted")
                inputBox.PlaceholderText = placeholder
                inputBox.Text = value
                inputBox.Font = Enum.Font.Gotham
                inputBox.TextSize = 13
                inputBox.TextXAlignment = Enum.TextXAlignment.Left
                inputBox.ClearTextOnFocus = clearOnFocus
                inputBox.ZIndex = container.ZIndex + 2
                inputBox.Parent = inputBg

                inputBox.Focused:Connect(function()
                    Utility.Spring(inputBg, { BackgroundColor3 = ThemeEngine:Get("Surface") }, 0.15)
                    inputStroke.Color = ThemeEngine:Get("Accent")
                    inputStroke.Transparency = 0.2
                end)

                inputBox.FocusLost:Connect(function(enterPressed)
                    value = inputBox.Text
                    Utility.Spring(inputBg, { BackgroundColor3 = ThemeEngine:Get("Background") }, 0.15)
                    inputStroke.Color = ThemeEngine:Get("Border")
                    inputStroke.Transparency = 0.4
                    if flag then ConfigSystem:Set(flag, value) end
                    task.spawn(callback, value, enterPressed)
                end)

                local element = {
                    Type = "Textbox",
                    Instance = container,
                    GetValue = function() return inputBox.Text end,
                    SetValue = function(_, v)
                        inputBox.Text = v
                        value = v
                    end
                }
                table.insert(self._elements, element)
                return element
            end

            --[[ PARAGRAPH ]]--
            function Section:CreateParagraph(config)
                config = config or {}
                local name  = config.Name or ""
                local text  = config.Text or ""

                local container = Instance.new("Frame")
                container.Size = UDim2.new(1, 0, 0, 0)
                container.AutomaticSize = Enum.AutomaticSize.Y
                container.BackgroundTransparency = 1
                container.LayoutOrder = #self._elements + 1
                container.Parent = contentHolder

                if name ~= "" then
                    local titleLbl = Instance.new("TextLabel")
                    titleLbl.Size = UDim2.new(1, 0, 0, 18)
                    titleLbl.BackgroundTransparency = 1
                    titleLbl.TextColor3 = ThemeEngine:Get("Text")
                    titleLbl.Text = name
                    titleLbl.Font = Enum.Font.GothamBold
                    titleLbl.TextSize = 13
                    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
                    titleLbl.ZIndex = container.ZIndex + 1
                    titleLbl.Parent = container
                end

                local bodyLbl = Instance.new("TextLabel")
                bodyLbl.Size = UDim2.new(1, 0, 0, 0)
                bodyLbl.Position = UDim2.new(0, 0, 0, name ~= "" and 20 or 0)
                bodyLbl.AutomaticSize = Enum.AutomaticSize.Y
                bodyLbl.BackgroundTransparency = 1
                bodyLbl.TextColor3 = ThemeEngine:Get("TextSecond")
                bodyLbl.Text = text
                bodyLbl.Font = Enum.Font.Gotham
                bodyLbl.TextSize = 12
                bodyLbl.TextXAlignment = Enum.TextXAlignment.Left
                bodyLbl.TextWrapped = true
                bodyLbl.ZIndex = container.ZIndex + 1
                bodyLbl.Parent = container

                local element = {
                    Type = "Paragraph",
                    Instance = container,
                    SetText = function(_, newText) bodyLbl.Text = newText end
                }
                table.insert(self._elements, element)
                return element
            end

            --[[ LABEL ]]--
            function Section:CreateLabel(config)
                config = config or {}
                local text = config.Text or "Label"

                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(1, 0, 0, 22)
                label.BackgroundTransparency = 1
                label.TextColor3 = ThemeEngine:Get("TextSecond")
                label.Text = text
                label.Font = Enum.Font.Gotham
                label.TextSize = 12
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.LayoutOrder = #self._elements + 1
                label.Parent = contentHolder

                local element = {
                    Type = "Label",
                    Instance = label,
                    SetText = function(_, t) label.Text = t end
                }
                table.insert(self._elements, element)
                return element
            end

            --[[ DIVIDER ]]--
            function Section:CreateDivider()
                local div = Instance.new("Frame")
                div.Size = UDim2.new(1, 0, 0, 1)
                div.BackgroundColor3 = ThemeEngine:Get("Border")
                div.BackgroundTransparency = 0.5
                div.BorderSizePixel = 0
                div.LayoutOrder = #self._elements + 1
                div.Parent = contentHolder

                table.insert(self._elements, { Type = "Divider", Instance = div })
                return div
            end

            --[[ KEYBIND ]]--
            function Section:CreateKeybind(config)
                config = config or {}
                local name     = config.Name or "Keybind"
                local default  = config.Default or Enum.KeyCode.Unknown
                local callback = config.Callback or function() end
                local flag     = config.Flag

                local boundKey = default
                if flag and ConfigSystem:Get(flag) ~= nil then
                    local saved = ConfigSystem:Get(flag)
                    boundKey = Enum.KeyCode[saved] or default
                end

                local listening = false

                local row = Instance.new("Frame")
                row.Size = UDim2.new(1, 0, 0, 36)
                row.BackgroundTransparency = 1
                row.LayoutOrder = #self._elements + 1
                row.Parent = contentHolder

                local lbl = Instance.new("TextLabel")
                lbl.Size = UDim2.new(1, -100, 1, 0)
                lbl.BackgroundTransparency = 1
                lbl.TextColor3 = ThemeEngine:Get("Text")
                lbl.Text = name
                lbl.Font = Enum.Font.Gotham
                lbl.TextSize = 13
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                lbl.ZIndex = row.ZIndex + 1
                lbl.Parent = row

                local keyBtn = Instance.new("TextButton")
                keyBtn.Size = UDim2.new(0, 90, 0, 26)
                keyBtn.Position = UDim2.new(1, -92, 0.5, -13)
                keyBtn.BackgroundColor3 = ThemeEngine:Get("SurfaceAlt")
                keyBtn.TextColor3 = ThemeEngine:Get("Text")
                keyBtn.Text = boundKey == Enum.KeyCode.Unknown and "None" or boundKey.Name
                keyBtn.Font = Enum.Font.GothamBold
                keyBtn.TextSize = 11
                keyBtn.BorderSizePixel = 0
                keyBtn.ZIndex = row.ZIndex + 2
                Utility.MakeCorner(keyBtn, 6)
                Utility.MakeStroke(keyBtn, ThemeEngine:Get("Border"), 1, 0.4)
                keyBtn.Parent = row

                keyBtn.MouseButton1Click:Connect(function()
                    listening = true
                    keyBtn.Text = "..."
                    keyBtn.TextColor3 = ThemeEngine:Get("Accent")
                    Utility.Spring(keyBtn, { BackgroundColor3 = ThemeEngine:Get("Surface") }, 0.15)
                end)

                local keyConn = UserInputService.InputBegan:Connect(function(input, gp)
                    if not listening then return end
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        if input.KeyCode == Enum.KeyCode.Escape then
                            boundKey = Enum.KeyCode.Unknown
                            keyBtn.Text = "None"
                        else
                            boundKey = input.KeyCode
                            keyBtn.Text = input.KeyCode.Name
                        end
                        listening = false
                        keyBtn.TextColor3 = ThemeEngine:Get("Text")
                        Utility.Spring(keyBtn, { BackgroundColor3 = ThemeEngine:Get("SurfaceAlt") }, 0.15)
                        if flag then ConfigSystem:Set(flag, boundKey.Name) end
                    end
                end)

                -- Listen for key press to trigger callback
                local fireConn = UserInputService.InputBegan:Connect(function(input)
                    if not listening and input.KeyCode == boundKey and boundKey ~= Enum.KeyCode.Unknown then
                        task.spawn(callback, boundKey)
                    end
                end)

                table.insert(Window._connections, keyConn)
                table.insert(Window._connections, fireConn)

                local element = {
                    Type = "Keybind",
                    Instance = row,
                    GetValue = function() return boundKey end,
                    SetValue = function(_, k)
                        boundKey = k
                        keyBtn.Text = k == Enum.KeyCode.Unknown and "None" or k.Name
                    end
                }
                table.insert(self._elements, element)
                return element
            end

            --[[ COLOR PICKER ]]--
            function Section:CreateColorPicker(config)
                config = config or {}
                local name     = config.Name     or "Color Picker"
                local default  = config.Default  or Color3.fromRGB(255, 100, 150)
                local callback = config.Callback or function() end
                local flag     = config.Flag

                local selectedColor = default
                local isOpen = false

                local container = Instance.new("Frame")
                container.Size = UDim2.new(1, 0, 0, 36)
                container.BackgroundTransparency = 1
                container.ClipsDescendants = false
                container.LayoutOrder = #self._elements + 1
                container.Parent = contentHolder

                local row = Instance.new("Frame")
                row.Size = UDim2.new(1, 0, 0, 36)
                row.BackgroundTransparency = 1
                row.ZIndex = container.ZIndex + 1
                row.Parent = container

                local lbl = Instance.new("TextLabel")
                lbl.Size = UDim2.new(1, -50, 1, 0)
                lbl.BackgroundTransparency = 1
                lbl.TextColor3 = ThemeEngine:Get("Text")
                lbl.Text = name
                lbl.Font = Enum.Font.Gotham
                lbl.TextSize = 13
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                lbl.ZIndex = row.ZIndex + 1
                lbl.Parent = row

                local preview = Instance.new("TextButton")
                preview.Size = UDim2.new(0, 40, 0, 22)
                preview.Position = UDim2.new(1, -42, 0.5, -11)
                preview.BackgroundColor3 = selectedColor
                preview.Text = ""
                preview.BorderSizePixel = 0
                preview.ZIndex = row.ZIndex + 2
                Utility.MakeCorner(preview, 6)
                Utility.MakeStroke(preview, ThemeEngine:Get("Border"), 1, 0.3)
                preview.Parent = row

                -- Color picker popup
                local popup = Instance.new("Frame")
                popup.Size = UDim2.new(0, 220, 0, 0)
                popup.Position = UDim2.new(0, 0, 0, 38)
                popup.BackgroundColor3 = ThemeEngine:Get("Surface")
                popup.BackgroundTransparency = 0.05
                popup.BorderSizePixel = 0
                popup.ZIndex = container.ZIndex + 30
                popup.ClipsDescendants = true
                popup.Visible = false
                Utility.MakeCorner(popup, 10)
                Utility.MakeStroke(popup, ThemeEngine:Get("Border"), 1, 0.3)
                popup.Parent = container
                Utility.MakePadding(popup, 10, 10, 10, 10)

                -- Hue bar
                local hueBarBg = Instance.new("Frame")
                hueBarBg.Size = UDim2.new(1, 0, 0, 16)
                hueBarBg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                hueBarBg.BorderSizePixel = 0
                hueBarBg.ZIndex = popup.ZIndex + 1
                Utility.MakeCorner(hueBarBg, 4)
                hueBarBg.Parent = popup

                local hueGradient = Instance.new("UIGradient")
                hueGradient.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)),
                    ColorSequenceKeypoint.new(1/6, Color3.fromHSV(1/6, 1, 1)),
                    ColorSequenceKeypoint.new(2/6, Color3.fromHSV(2/6, 1, 1)),
                    ColorSequenceKeypoint.new(3/6, Color3.fromHSV(3/6, 1, 1)),
                    ColorSequenceKeypoint.new(4/6, Color3.fromHSV(4/6, 1, 1)),
                    ColorSequenceKeypoint.new(5/6, Color3.fromHSV(5/6, 1, 1)),
                    ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, 1)),
                })
                hueGradient.Parent = hueBarBg

                local hueHandle = Instance.new("Frame")
                hueHandle.Size = UDim2.new(0, 4, 1, 4)
                hueHandle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                hueHandle.BorderSizePixel = 0
                hueHandle.ZIndex = hueBarBg.ZIndex + 2
                hueHandle.AnchorPoint = Vector2.new(0.5, 0.5)
                hueHandle.Position = UDim2.new(0, 0, 0.5, 0)
                Utility.MakeCorner(hueHandle, 2)
                hueHandle.Parent = hueBarBg

                -- Saturation/Value picker
                local svPicker = Instance.new("Frame")
                svPicker.Size = UDim2.new(1, 0, 0, 100)
                svPicker.Position = UDim2.new(0, 0, 0, 24)
                svPicker.BackgroundColor3 = Color3.fromHSV(0, 1, 1)
                svPicker.BorderSizePixel = 0
                svPicker.ZIndex = popup.ZIndex + 1
                Utility.MakeCorner(svPicker, 6)
                svPicker.Parent = popup

                -- White gradient (left-right)
                local whiteGrad = Instance.new("UIGradient")
                whiteGrad.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
                })
                whiteGrad.Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0),
                    NumberSequenceKeypoint.new(1, 1)
                })
                whiteGrad.Parent = svPicker

                local blackOverlay = Instance.new("Frame")
                blackOverlay.Size = UDim2.new(1, 0, 1, 0)
                blackOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                blackOverlay.BackgroundTransparency = 0
                blackOverlay.BorderSizePixel = 0
                blackOverlay.ZIndex = svPicker.ZIndex + 1
                Utility.MakeCorner(blackOverlay, 6)
                blackOverlay.Parent = svPicker

                local blackGrad = Instance.new("UIGradient")
                blackGrad.Color = ColorSequence.new(Color3.fromRGB(0, 0, 0))
                blackGrad.Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 1),
                    NumberSequenceKeypoint.new(1, 0)
                })
                blackGrad.Rotation = 90
                blackGrad.Parent = blackOverlay

                local svHandle = Instance.new("Frame")
                svHandle.Size = UDim2.new(0, 12, 0, 12)
                svHandle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                svHandle.BorderSizePixel = 0
                svHandle.ZIndex = blackOverlay.ZIndex + 2
                svHandle.AnchorPoint = Vector2.new(0.5, 0.5)
                svHandle.Position = UDim2.new(1, 0, 0, 0)
                Utility.MakeCorner(svHandle, 6)
                Utility.MakeStroke(svHandle, Color3.fromRGB(255, 255, 255), 2, 0)
                svHandle.Parent = svPicker

                -- Hex input
                local hexBg = Instance.new("Frame")
                hexBg.Size = UDim2.new(1, 0, 0, 28)
                hexBg.Position = UDim2.new(0, 0, 0, 132)
                hexBg.BackgroundColor3 = ThemeEngine:Get("Background")
                hexBg.BorderSizePixel = 0
                hexBg.ZIndex = popup.ZIndex + 2
                Utility.MakeCorner(hexBg, 6)
                Utility.MakeStroke(hexBg, ThemeEngine:Get("Border"), 1, 0.4)
                hexBg.Parent = popup

                local hexBox = Instance.new("TextBox")
                hexBox.Size = UDim2.new(1, -12, 1, 0)
                hexBox.Position = UDim2.new(0, 6, 0, 0)
                hexBox.BackgroundTransparency = 1
                hexBox.TextColor3 = ThemeEngine:Get("Text")
                hexBox.Font = Enum.Font.GothamMono
                hexBox.TextSize = 12
                hexBox.Text = Utility.ColorToHex(selectedColor)
                hexBox.PlaceholderText = "#RRGGBB"
                hexBox.ZIndex = hexBg.ZIndex + 1
                hexBox.Parent = hexBg

                popup.Size = UDim2.new(0, 220, 0, 170)

                local h, s, v = Color3.toHSV(selectedColor)

                local function updateColor()
                    selectedColor = Color3.fromHSV(h, s, v)
                    preview.BackgroundColor3 = selectedColor
                    svPicker.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                    hexBox.Text = Utility.ColorToHex(selectedColor)
                    hueHandle.Position = UDim2.new(h, 0, 0.5, 0)
                    svHandle.Position = UDim2.new(s, 0, 1 - v, 0)
                    if flag then ConfigSystem:Set(flag, { R = selectedColor.R, G = selectedColor.G, B = selectedColor.B }) end
                    task.spawn(callback, selectedColor)
                end

                -- Hue drag
                local hueDragging = false
                local hueHit = Instance.new("TextButton")
                hueHit.Size = UDim2.new(1, 0, 1, 0)
                hueHit.BackgroundTransparency = 1
                hueHit.Text = ""
                hueHit.ZIndex = hueBarBg.ZIndex + 3
                hueHit.Parent = hueBarBg

                hueHit.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                        hueDragging = true
                        local relX = Utility.Clamp((inp.Position.X - hueBarBg.AbsolutePosition.X) / hueBarBg.AbsoluteSize.X, 0, 1)
                        h = relX; updateColor()
                    end
                end)

                local hueConn = UserInputService.InputChanged:Connect(function(inp)
                    if hueDragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
                        local relX = Utility.Clamp((inp.Position.X - hueBarBg.AbsolutePosition.X) / hueBarBg.AbsoluteSize.X, 0, 1)
                        h = relX; updateColor()
                    end
                end)

                local hueEnd = UserInputService.InputEnded:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                        hueDragging = false
                    end
                end)

                -- SV drag
                local svDragging = false
                local svHit = Instance.new("TextButton")
                svHit.Size = UDim2.new(1, 0, 1, 0)
                svHit.BackgroundTransparency = 1
                svHit.Text = ""
                svHit.ZIndex = svHandle.ZIndex + 1
                svHit.Parent = svPicker

                svHit.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                        svDragging = true
                        s = Utility.Clamp((inp.Position.X - svPicker.AbsolutePosition.X) / svPicker.AbsoluteSize.X, 0, 1)
                        v = 1 - Utility.Clamp((inp.Position.Y - svPicker.AbsolutePosition.Y) / svPicker.AbsoluteSize.Y, 0, 1)
                        updateColor()
                    end
                end)

                local svConn = UserInputService.InputChanged:Connect(function(inp)
                    if svDragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
                        s = Utility.Clamp((inp.Position.X - svPicker.AbsolutePosition.X) / svPicker.AbsoluteSize.X, 0, 1)
                        v = 1 - Utility.Clamp((inp.Position.Y - svPicker.AbsolutePosition.Y) / svPicker.AbsoluteSize.Y, 0, 1)
                        updateColor()
                    end
                end)

                local svEnd = UserInputService.InputEnded:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                        svDragging = false
                    end
                end)

                hexBox.FocusLost:Connect(function()
                    local ok, color = pcall(function()
                        return Utility.HexToColor(hexBox.Text)
                    end)
                    if ok then
                        selectedColor = color
                        h, s, v = Color3.toHSV(color)
                        updateColor()
                    end
                end)

                table.insert(Window._connections, hueConn)
                table.insert(Window._connections, hueEnd)
                table.insert(Window._connections, svConn)
                table.insert(Window._connections, svEnd)

                preview.MouseButton1Click:Connect(function()
                    isOpen = not isOpen
                    popup.Visible = isOpen
                    if isOpen then
                        Utility.Spring(popup, { BackgroundTransparency = 0.05 }, 0.2)
                    end
                end)

                updateColor()

                local element = {
                    Type = "ColorPicker",
                    Instance = container,
                    GetValue = function() return selectedColor end,
                    SetValue = function(_, c)
                        selectedColor = c
                        h, s, v = Color3.toHSV(c)
                        updateColor()
                    end
                }
                table.insert(self._elements, element)
                return element
            end

            --[[ IMAGE ]]--
            function Section:CreateImage(config)
                config = config or {}
                local assetId = config.Image or ""
                local size    = config.Size   or UDim2.new(1, 0, 0, 100)

                local img = Instance.new("ImageLabel")
                img.Size = size
                img.Image = assetId
                img.BackgroundTransparency = 1
                img.ScaleType = Enum.ScaleType.Fit
                img.LayoutOrder = #self._elements + 1
                img.ZIndex = contentHolder.ZIndex + 1
                img.Parent = contentHolder

                local element = { Type = "Image", Instance = img }
                table.insert(self._elements, element)
                return element
            end

            --[[ PROGRESS BAR ]]--
            function Section:CreateProgressBar(config)
                config = config or {}
                local name     = config.Name    or "Progress"
                local default  = config.Default or 0
                local color    = config.Color   or ThemeEngine:Get("Accent")

                local container = Instance.new("Frame")
                container.Size = UDim2.new(1, 0, 0, 42)
                container.BackgroundTransparency = 1
                container.LayoutOrder = #self._elements + 1
                container.Parent = contentHolder

                local lbl = Instance.new("TextLabel")
                lbl.Size = UDim2.new(1, -40, 0, 18)
                lbl.BackgroundTransparency = 1
                lbl.TextColor3 = ThemeEngine:Get("Text")
                lbl.Text = name
                lbl.Font = Enum.Font.Gotham
                lbl.TextSize = 13
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                lbl.ZIndex = container.ZIndex + 1
                lbl.Parent = container

                local pctLbl = Instance.new("TextLabel")
                pctLbl.Size = UDim2.new(0, 36, 0, 18)
                pctLbl.Position = UDim2.new(1, -38, 0, 0)
                pctLbl.BackgroundTransparency = 1
                pctLbl.TextColor3 = ThemeEngine:Get("Accent")
                pctLbl.Text = "0%"
                pctLbl.Font = Enum.Font.GothamBold
                pctLbl.TextSize = 12
                pctLbl.TextXAlignment = Enum.TextXAlignment.Right
                pctLbl.ZIndex = container.ZIndex + 1
                pctLbl.Parent = container

                local barBg = Instance.new("Frame")
                barBg.Size = UDim2.new(1, 0, 0, 8)
                barBg.Position = UDim2.new(0, 0, 0, 24)
                barBg.BackgroundColor3 = ThemeEngine:Get("SliderBg")
                barBg.BorderSizePixel = 0
                barBg.ZIndex = container.ZIndex + 1
                Utility.MakeCorner(barBg, 4)
                barBg.Parent = container

                local fill = Instance.new("Frame")
                fill.Size = UDim2.new(0, 0, 1, 0)
                fill.BackgroundColor3 = color
                fill.BorderSizePixel = 0
                fill.ZIndex = barBg.ZIndex + 1
                Utility.MakeCorner(fill, 4)
                fill.Parent = barBg

                local function setProgress(val)
                    val = Utility.Clamp(val, 0, 1)
                    Utility.Spring(fill, { Size = UDim2.new(val, 0, 1, 0) }, 0.3)
                    pctLbl.Text = math.floor(val * 100) .. "%"
                end
                setProgress(default)

                local element = {
                    Type = "ProgressBar",
                    Instance = container,
                    SetProgress = function(_, val) setProgress(val) end,
                    GetProgress = function() return fill.Size.X.Scale end
                }
                table.insert(self._elements, element)
                return element
            end

            --[[ SEARCH BOX ]]--
            function Section:CreateSearchBox(config)
                config = config or {}
                local placeholder = config.Placeholder or "Search..."
                local callback    = config.Callback    or function() end

                local inputBg = Instance.new("Frame")
                inputBg.Size = UDim2.new(1, 0, 0, 34)
                inputBg.BackgroundColor3 = ThemeEngine:Get("Background")
                inputBg.BorderSizePixel = 0
                inputBg.LayoutOrder = #self._elements + 1
                Utility.MakeCorner(inputBg, 8)
                local stroke = Utility.MakeStroke(inputBg, ThemeEngine:Get("Border"), 1, 0.4)
                inputBg.Parent = contentHolder

                local searchIcon = Instance.new("TextLabel")
                searchIcon.Size = UDim2.new(0, 20, 1, 0)
                searchIcon.Position = UDim2.new(0, 8, 0, 0)
                searchIcon.BackgroundTransparency = 1
                searchIcon.TextColor3 = ThemeEngine:Get("TextMuted")
                searchIcon.Text = "🔍"
                searchIcon.Font = Enum.Font.Gotham
                searchIcon.TextSize = 13
                searchIcon.ZIndex = inputBg.ZIndex + 1
                searchIcon.Parent = inputBg

                local searchBox = Instance.new("TextBox")
                searchBox.Size = UDim2.new(1, -36, 1, 0)
                searchBox.Position = UDim2.new(0, 30, 0, 0)
                searchBox.BackgroundTransparency = 1
                searchBox.TextColor3 = ThemeEngine:Get("Text")
                searchBox.PlaceholderColor3 = ThemeEngine:Get("TextMuted")
                searchBox.PlaceholderText = placeholder
                searchBox.Text = ""
                searchBox.Font = Enum.Font.Gotham
                searchBox.TextSize = 13
                searchBox.TextXAlignment = Enum.TextXAlignment.Left
                searchBox.ZIndex = inputBg.ZIndex + 2
                searchBox.Parent = inputBg

                searchBox.Focused:Connect(function()
                    stroke.Color = ThemeEngine:Get("Accent")
                    stroke.Transparency = 0.2
                end)
                searchBox.FocusLost:Connect(function()
                    stroke.Color = ThemeEngine:Get("Border")
                    stroke.Transparency = 0.4
                end)

                searchBox:GetPropertyChangedSignal("Text"):Connect(function()
                    task.spawn(callback, searchBox.Text)
                end)

                local element = {
                    Type = "SearchBox",
                    Instance = inputBg,
                    GetValue = function() return searchBox.Text end,
                    SetValue = function(_, t) searchBox.Text = t end
                }
                table.insert(self._elements, element)
                return element
            end

            --[[ INPUT NUMBER ]]--
            function Section:CreateInputNumber(config)
                config = config or {}
                local name     = config.Name    or "Number"
                local default  = config.Default or 0
                local min      = config.Min
                local max      = config.Max
                local step     = config.Step    or 1
                local callback = config.Callback or function() end
                local flag     = config.Flag

                local value = default
                if flag and ConfigSystem:Get(flag) ~= nil then value = ConfigSystem:Get(flag) end

                local row = Instance.new("Frame")
                row.Size = UDim2.new(1, 0, 0, 36)
                row.BackgroundTransparency = 1
                row.LayoutOrder = #self._elements + 1
                row.Parent = contentHolder

                local lbl = Instance.new("TextLabel")
                lbl.Size = UDim2.new(1, -120, 1, 0)
                lbl.BackgroundTransparency = 1
                lbl.TextColor3 = ThemeEngine:Get("Text")
                lbl.Text = name
                lbl.Font = Enum.Font.Gotham
                lbl.TextSize = 13
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                lbl.ZIndex = row.ZIndex + 1
                lbl.Parent = row

                -- Stepper container
                local stepBg = Instance.new("Frame")
                stepBg.Size = UDim2.new(0, 110, 0, 28)
                stepBg.Position = UDim2.new(1, -112, 0.5, -14)
                stepBg.BackgroundColor3 = ThemeEngine:Get("Background")
                stepBg.BorderSizePixel = 0
                stepBg.ZIndex = row.ZIndex + 2
                Utility.MakeCorner(stepBg, 8)
                Utility.MakeStroke(stepBg, ThemeEngine:Get("Border"), 1, 0.4)
                stepBg.Parent = row

                local decBtn = Instance.new("TextButton")
                decBtn.Size = UDim2.new(0, 28, 1, 0)
                decBtn.BackgroundColor3 = ThemeEngine:Get("SurfaceAlt")
                decBtn.BackgroundTransparency = 0.5
                decBtn.Text = "−"
                decBtn.TextColor3 = ThemeEngine:Get("Text")
                decBtn.Font = Enum.Font.GothamBold
                decBtn.TextSize = 16
                decBtn.BorderSizePixel = 0
                decBtn.ZIndex = stepBg.ZIndex + 1
                Utility.MakeCorner(decBtn, 6)
                decBtn.Parent = stepBg

                local valLbl = Instance.new("TextLabel")
                valLbl.Size = UDim2.new(1, -58, 1, 0)
                valLbl.Position = UDim2.new(0, 30, 0, 0)
                valLbl.BackgroundTransparency = 1
                valLbl.TextColor3 = ThemeEngine:Get("Text")
                valLbl.Text = tostring(value)
                valLbl.Font = Enum.Font.GothamBold
                valLbl.TextSize = 13
                valLbl.ZIndex = stepBg.ZIndex + 1
                valLbl.Parent = stepBg

                local incBtn = Instance.new("TextButton")
                incBtn.Size = UDim2.new(0, 28, 1, 0)
                incBtn.Position = UDim2.new(1, -28, 0, 0)
                incBtn.BackgroundColor3 = ThemeEngine:Get("SurfaceAlt")
                incBtn.BackgroundTransparency = 0.5
                incBtn.Text = "+"
                incBtn.TextColor3 = ThemeEngine:Get("Text")
                incBtn.Font = Enum.Font.GothamBold
                incBtn.TextSize = 14
                incBtn.BorderSizePixel = 0
                incBtn.ZIndex = stepBg.ZIndex + 1
                Utility.MakeCorner(incBtn, 6)
                incBtn.Parent = stepBg

                local function setValue(v)
                    if min then v = math.max(v, min) end
                    if max then v = math.min(v, max) end
                    value = v
                    valLbl.Text = tostring(value)
                    if flag then ConfigSystem:Set(flag, value) end
                    task.spawn(callback, value)
                end

                decBtn.MouseButton1Click:Connect(function() setValue(value - step) end)
                incBtn.MouseButton1Click:Connect(function() setValue(value + step) end)

                local element = {
                    Type = "InputNumber",
                    Instance = row,
                    GetValue = function() return value end,
                    SetValue = function(_, v) setValue(v) end
                }
                table.insert(self._elements, element)
                return element
            end

            --[[ COMBO BOX ]]--
            -- Alias for single dropdown with text input filter
            function Section:CreateComboBox(config)
                config = config or {}
                local name     = config.Name    or "ComboBox"
                local options  = config.Options or {}
                local callback = config.Callback or function() end

                local container = Instance.new("Frame")
                container.Size = UDim2.new(1, 0, 0, 52)
                container.BackgroundTransparency = 1
                container.ClipsDescendants = false
                container.LayoutOrder = #self._elements + 1
                container.Parent = contentHolder

                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(1, 0, 0, 18)
                label.BackgroundTransparency = 1
                label.TextColor3 = ThemeEngine:Get("TextSecond")
                label.Text = name
                label.Font = Enum.Font.Gotham
                label.TextSize = 11
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.ZIndex = container.ZIndex + 1
                label.Parent = container

                local inputBg = Instance.new("Frame")
                inputBg.Size = UDim2.new(1, 0, 0, 32)
                inputBg.Position = UDim2.new(0, 0, 0, 20)
                inputBg.BackgroundColor3 = ThemeEngine:Get("Background")
                inputBg.BorderSizePixel = 0
                inputBg.ZIndex = container.ZIndex + 2
                Utility.MakeCorner(inputBg, 8)
                Utility.MakeStroke(inputBg, ThemeEngine:Get("Border"), 1, 0.4)
                inputBg.Parent = container

                local inputBox = Instance.new("TextBox")
                inputBox.Size = UDim2.new(1, -16, 1, 0)
                inputBox.Position = UDim2.new(0, 8, 0, 0)
                inputBox.BackgroundTransparency = 1
                inputBox.TextColor3 = ThemeEngine:Get("Text")
                inputBox.PlaceholderColor3 = ThemeEngine:Get("TextMuted")
                inputBox.PlaceholderText = "Type to search..."
                inputBox.Text = ""
                inputBox.Font = Enum.Font.Gotham
                inputBox.TextSize = 13
                inputBox.ZIndex = inputBg.ZIndex + 1
                inputBox.Parent = inputBg

                local dropFrame = Instance.new("Frame")
                dropFrame.Size = UDim2.new(1, 0, 0, 0)
                dropFrame.Position = UDim2.new(0, 0, 0, 54)
                dropFrame.BackgroundColor3 = ThemeEngine:Get("Surface")
                dropFrame.BackgroundTransparency = 0.05
                dropFrame.BorderSizePixel = 0
                dropFrame.ZIndex = container.ZIndex + 20
                dropFrame.ClipsDescendants = true
                dropFrame.Visible = false
                Utility.MakeCorner(dropFrame, 8)
                Utility.MakeStroke(dropFrame, ThemeEngine:Get("Border"), 1, 0.3)
                dropFrame.Parent = container

                local scrollFrame = Instance.new("ScrollingFrame")
                scrollFrame.Size = UDim2.new(1, 0, 1, 0)
                scrollFrame.BackgroundTransparency = 1
                scrollFrame.BorderSizePixel = 0
                scrollFrame.ScrollBarThickness = 2
                scrollFrame.ScrollBarImageColor3 = ThemeEngine:Get("Accent")
                scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
                scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
                scrollFrame.ZIndex = dropFrame.ZIndex + 1
                scrollFrame.Parent = dropFrame
                Utility.MakeList(scrollFrame, 2)
                Utility.MakePadding(scrollFrame, 4, 4, 4, 4)

                local function buildList(filter)
                    for _, child in ipairs(scrollFrame:GetChildren()) do
                        if child:IsA("TextButton") then child:Destroy() end
                    end
                    local count = 0
                    for _, opt in ipairs(options) do
                        if filter == "" or string.find(string.lower(tostring(opt)), string.lower(filter), 1, true) then
                            count += 1
                            local btn = Instance.new("TextButton")
                            btn.Size = UDim2.new(1, 0, 0, 28)
                            btn.BackgroundColor3 = ThemeEngine:Get("SurfaceAlt")
                            btn.BackgroundTransparency = 0.8
                            btn.Text = tostring(opt)
                            btn.TextColor3 = ThemeEngine:Get("Text")
                            btn.Font = Enum.Font.Gotham
                            btn.TextSize = 12
                            btn.BorderSizePixel = 0
                            btn.ZIndex = scrollFrame.ZIndex + 1
                            Utility.MakeCorner(btn, 6)
                            btn.Parent = scrollFrame
                            btn.MouseButton1Click:Connect(function()
                                inputBox.Text = tostring(opt)
                                task.spawn(callback, opt)
                                Utility.Spring(dropFrame, { Size = UDim2.new(1, 0, 0, 0) }, 0.2)
                                task.delay(0.22, function() dropFrame.Visible = false end)
                            end)
                        end
                    end
                    return count
                end

                inputBox.Focused:Connect(function()
                    local n = buildList("")
                    local h = math.min(n, 5) * 30 + 8
                    dropFrame.Visible = true
                    Utility.Spring(dropFrame, { Size = UDim2.new(1, 0, 0, h) }, 0.2)
                end)

                inputBox:GetPropertyChangedSignal("Text"):Connect(function()
                    local n = buildList(inputBox.Text)
                    local h = math.min(n, 5) * 30 + 8
                    if h > 8 then
                        dropFrame.Visible = true
                        Utility.Spring(dropFrame, { Size = UDim2.new(1, 0, 0, h) }, 0.15)
                    else
                        Utility.Spring(dropFrame, { Size = UDim2.new(1, 0, 0, 0) }, 0.15)
                        task.delay(0.2, function() dropFrame.Visible = false end)
                    end
                end)

                inputBox.FocusLost:Connect(function()
                    task.delay(0.3, function()
                        Utility.Spring(dropFrame, { Size = UDim2.new(1, 0, 0, 0) }, 0.2)
                        task.delay(0.22, function() dropFrame.Visible = false end)
                    end)
                end)

                local element = {
                    Type = "ComboBox",
                    Instance = container,
                    GetValue = function() return inputBox.Text end
                }
                table.insert(self._elements, element)
                return element
            end

            --[[ SCROLL AREA ]]--
            function Section:CreateScrollArea(config)
                config = config or {}
                local height   = config.Height or 120
                local children = config.Children

                local scrollArea = Instance.new("ScrollingFrame")
                scrollArea.Size = UDim2.new(1, 0, 0, height)
                scrollArea.BackgroundColor3 = ThemeEngine:Get("Background")
                scrollArea.BackgroundTransparency = 0.3
                scrollArea.BorderSizePixel = 0
                scrollArea.ScrollBarThickness = 3
                scrollArea.ScrollBarImageColor3 = ThemeEngine:Get("Accent")
                scrollArea.CanvasSize = UDim2.new(0, 0, 0, 0)
                scrollArea.AutomaticCanvasSize = Enum.AutomaticSize.Y
                scrollArea.LayoutOrder = #self._elements + 1
                Utility.MakeCorner(scrollArea, 8)
                Utility.MakeList(scrollArea, 4)
                Utility.MakePadding(scrollArea, 6, 6, 6, 6)
                scrollArea.Parent = contentHolder

                local element = {
                    Type = "ScrollArea",
                    Instance = scrollArea,
                    GetContainer = function() return scrollArea end
                }
                table.insert(self._elements, element)
                return element
            end

            --[[ ICON ]]--
            function Section:CreateIcon(config)
                config = config or {}
                local assetId = config.Image or ""
                local size    = config.Size  or 32

                local frame = Instance.new("Frame")
                frame.Size = UDim2.new(0, size, 0, size)
                frame.BackgroundTransparency = 1
                frame.LayoutOrder = #self._elements + 1
                frame.Parent = contentHolder

                local img = Instance.new("ImageLabel")
                img.Size = UDim2.new(1, 0, 1, 0)
                img.Image = assetId
                img.BackgroundTransparency = 1
                img.Parent = frame

                local element = { Type = "Icon", Instance = frame }
                table.insert(self._elements, element)
                return element
            end

            table.insert(Tab._sections, Section)
            return Section
        end -- CreateSection

        table.insert(Window._tabs, Tab)
        return Tab
    end -- CreateTab

    -- --------------------------------
    -- Sidebar Category + Divider
    -- --------------------------------
    function Window:AddSidebarCategory(text)
        local catLabel = Instance.new("TextLabel")
        catLabel.Size = UDim2.new(1, -16, 0, 20)
        catLabel.BackgroundTransparency = 1
        catLabel.TextColor3 = ThemeEngine:Get("TextMuted")
        catLabel.Text = string.upper(text)
        catLabel.Font = Enum.Font.GothamBold
        catLabel.TextSize = 9
        catLabel.TextXAlignment = Enum.TextXAlignment.Left
        catLabel.LayoutOrder = #self._tabs * 2 + 1
        catLabel.Parent = sidebarScroll
    end

    function Window:AddSidebarDivider()
        local div = Instance.new("Frame")
        div.Size = UDim2.new(1, -16, 0, 1)
        div.BackgroundColor3 = ThemeEngine:Get("Border")
        div.BackgroundTransparency = 0.5
        div.BorderSizePixel = 0
        div.LayoutOrder = #self._tabs * 2 + 2
        div.Parent = sidebarScroll
    end

    -- --------------------------------
    -- Theme change propagation
    -- --------------------------------
    ThemeEngine.OnChanged:Connect(function(theme)
        rootFrame.BackgroundColor3 = theme.WindowBG
        titleBar.BackgroundColor3  = theme.TitleBar
        sidebar.BackgroundColor3   = theme.Sidebar
    end)

    -- --------------------------------
    -- Auto Repair registration
    -- --------------------------------
    local winId = "Window_" .. title
    AutoRepair:RegisterCheck(winId, function()
        return not (rootFrame and rootFrame.Parent)
    end, function()
        -- Simple fix: re-parent
        if rootFrame then
            rootFrame.Parent = MacUI._screenGui
            shadow.Parent = MacUI._screenGui
        end
    end)

    Window._rootFrame = rootFrame
    Window._shadow = shadow
    table.insert(MacUI._windows, Window)

    -- Entrance animation
    rootFrame.BackgroundTransparency = 1
    Utility.Spring(rootFrame, { BackgroundTransparency = 0.05 }, 0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

    return Window
end

-- ============================================================
-- FLOATING BUTTON (MOBILE)
-- ============================================================
function MacUI:CreateFloatingButton(config)
    config = config or {}
    local icon     = config.Icon        or "☰"
    local onTap    = config.OnTap       or function() end
    local onLong   = config.OnLongPress or function() end
    local onDouble = config.OnDoubleTap or function() end

    local btnSize = 52

    local btn = Instance.new("TextButton")
    btn.Name = "FloatingButton"
    btn.Size = UDim2.new(0, btnSize, 0, btnSize)
    btn.Position = UDim2.new(1, -(btnSize + 20), 0.5, 0)
    btn.BackgroundColor3 = ThemeEngine:Get("Accent")
    btn.Text = icon
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 22
    btn.BorderSizePixel = 0
    btn.ZIndex = 200
    Utility.MakeCorner(btn, btnSize // 2)

    -- Shadow
    local btnShadow = Instance.new("ImageLabel")
    btnShadow.Size = UDim2.new(1, 20, 1, 20)
    btnShadow.Position = UDim2.new(0, -10, 0, 5)
    btnShadow.BackgroundTransparency = 1
    btnShadow.Image = "rbxassetid://6014054489"
    btnShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    btnShadow.ImageTransparency = 0.5
    btnShadow.ScaleType = Enum.ScaleType.Slice
    btnShadow.SliceCenter = Rect.new(49, 49, 450, 450)
    btnShadow.ZIndex = btn.ZIndex - 1
    btnShadow.Parent = btn

    Utility.MakeStroke(btn, ThemeEngine:Get("AccentLight"), 1, 0.5)
    btn.Parent = self._screenGui

    -- Drag
    local dragging = false
    local dragStart, startPos
    local tapTime = 0
    local tapCount = 0

    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos  = btn.Position

            -- Long press detection
            local t0 = tick()
            task.delay(0.6, function()
                if dragging then
                    onLong()
                end
            end)
        end
    end)

    local fbDragConn = UserInputService.InputChanged:Connect(function(input)
        if dragging and (
            input.UserInputType == Enum.UserInputType.MouseMovement or
            input.UserInputType == Enum.UserInputType.Touch
        ) then
            local delta = input.Position - dragStart
            local vp = Camera.ViewportSize
            local newX = Utility.Clamp(startPos.X.Offset + delta.X, 0, vp.X - btnSize)
            local newY = Utility.Clamp(startPos.Y.Offset + delta.Y, 0, vp.Y - btnSize)
            btn.Position = UDim2.new(0, newX, 0, newY)
        end
    end)

    local fbEndConn = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            if dragging then
                dragging = false
                -- Snap to nearest edge
                local vp = Camera.ViewportSize
                local cx = btn.AbsolutePosition.X + btnSize / 2
                if cx < vp.X / 2 then
                    Utility.Spring(btn, { Position = UDim2.new(0, 20, 0, btn.AbsolutePosition.Y) }, 0.3, Enum.EasingStyle.Back)
                else
                    Utility.Spring(btn, { Position = UDim2.new(0, vp.X - btnSize - 20, 0, btn.AbsolutePosition.Y) }, 0.3, Enum.EasingStyle.Back)
                end
            end
        end
    end)

    table.insert(self._connections, fbDragConn)
    table.insert(self._connections, fbEndConn)

    btn.MouseButton1Click:Connect(function()
        Utility.Ripple(btn)
        tapCount += 1
        if tapCount == 1 then
            task.delay(0.3, function()
                if tapCount == 1 then
                    onTap()
                elseif tapCount >= 2 then
                    onDouble()
                end
                tapCount = 0
            end)
        end
        Utility.Spring(btn, { Size = UDim2.new(0, btnSize - 4, 0, btnSize - 4) }, 0.1)
        task.delay(0.15, function()
            Utility.Spring(btn, { Size = UDim2.new(0, btnSize, 0, btnSize) }, 0.25, Enum.EasingStyle.Back)
        end)
    end)

    local fbRef = {
        Instance = btn,
        Show = function()
            btn.Visible = true
            Utility.Spring(btn, { BackgroundTransparency = 0 }, 0.2)
        end,
        Hide = function()
            Utility.Spring(btn, { BackgroundTransparency = 1 }, 0.2)
            task.delay(0.25, function() btn.Visible = false end)
        end,
        SetIcon = function(_, newIcon) btn.Text = newIcon end,
        SetPosition = function(_, x, y)
            btn.Position = UDim2.new(0, x, 0, y)
        end
    }
    return fbRef
end

-- ============================================================
-- TOOLTIP SYSTEM
-- ============================================================
function MacUI:AddTooltip(target, text)
    local tooltip = Instance.new("Frame")
    tooltip.Name = "Tooltip"
    tooltip.Size = UDim2.new(0, 0, 0, 28)
    tooltip.AutomaticSize = Enum.AutomaticSize.X
    tooltip.BackgroundColor3 = ThemeEngine:Get("Surface")
    tooltip.BackgroundTransparency = 0.05
    tooltip.BorderSizePixel = 0
    tooltip.ZIndex = 999
    tooltip.Visible = false
    Utility.MakeCorner(tooltip, 6)
    Utility.MakeStroke(tooltip, ThemeEngine:Get("Border"), 1, 0.3)
    tooltip.Parent = self._screenGui

    local tipLabel = Instance.new("TextLabel")
    tipLabel.Size = UDim2.new(0, 0, 1, 0)
    tipLabel.AutomaticSize = Enum.AutomaticSize.X
    tipLabel.BackgroundTransparency = 1
    tipLabel.TextColor3 = ThemeEngine:Get("TextSecond")
    tipLabel.Text = text
    tipLabel.Font = Enum.Font.Gotham
    tipLabel.TextSize = 11
    tipLabel.ZIndex = tooltip.ZIndex + 1
    Utility.MakePadding(tipLabel, 0, 8, 0, 8)
    tipLabel.Parent = tooltip

    target.MouseEnter:Connect(function()
        local mp = UserInputService:GetMouseLocation()
        tooltip.Position = UDim2.new(0, mp.X + 10, 0, mp.Y - 36)
        tooltip.Visible = true
        Utility.Spring(tooltip, { BackgroundTransparency = 0.05 }, 0.15)
    end)

    target.MouseMoved:Connect(function(x, y)
        tooltip.Position = UDim2.new(0, x + 10, 0, y - 36)
    end)

    target.MouseLeave:Connect(function()
        tooltip.Visible = false
    end)
end

-- ============================================================
-- ENTRY POINT
-- ============================================================
MacUI:Init()

return MacUI
