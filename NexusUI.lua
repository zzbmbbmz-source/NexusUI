--[[
    ███╗   ██╗███████╗██╗  ██╗██╗   ██╗███████╗    ██╗   ██╗██╗
    ████╗  ██║██╔════╝╚██╗██╔╝██║   ██║██╔════╝    ██║   ██║██║
    ██╔██╗ ██║█████╗   ╚███╔╝ ██║   ██║███████╗    ██║   ██║██║
    ██║╚██╗██║██╔══╝   ██╔██╗ ██║   ██║╚════██║    ██║   ██║██║
    ██║ ╚████║███████╗██╔╝ ██╗╚██████╔╝███████║    ╚██████╔╝██║
    ╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝     ╚═════╝ ╚═╝

    NexusUI v2.5.0 — Production Roblox UI Library
    Dark Theme · Purple Accent · Modern Minimal · Glassmorphism

    Author  : NexusUI Team
    License : MIT
    Repo    : https://github.com/nexusui/NexusUI

    Usage:
        local NexusUI = loadstring(game:HttpGet("URL"))()
        local Window = NexusUI:CreateWindow({ Title = "My Script" })
        local Tab = Window:CreateTab({ Name = "Main", Icon = "🏠" })
        local Section = Tab:CreateSection({ Name = "Features" })
        Section:CreateToggle({ Name = "Feature", Callback = function(v) end })
]]

-- ─────────────────────────────────────────────
--  SERVICES
-- ─────────────────────────────────────────────
local Players            = game:GetService("Players")
local RunService         = game:GetService("RunService")
local TweenService       = game:GetService("TweenService")
local UserInputService   = game:GetService("UserInputService")
local CoreGui            = game:GetService("CoreGui")
local HttpService        = game:GetService("HttpService")
local GuiService         = game:GetService("GuiService")
local TextService        = game:GetService("TextService")
local CollectionService  = game:GetService("CollectionService")
local MarketplaceService = game:GetService("MarketplaceService")

local LocalPlayer   = Players.LocalPlayer
local Mouse         = LocalPlayer:GetMouse()
local Camera        = workspace.CurrentCamera

-- ─────────────────────────────────────────────
--  ENVIRONMENT DETECTION
-- ─────────────────────────────────────────────
local IS_MOBILE = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local IS_PC     = UserInputService.KeyboardEnabled
local EXECUTOR  = "Unknown"
do
    if identifyexecutor then
        local ok, name = pcall(identifyexecutor)
        if ok then EXECUTOR = name end
    elseif syn then EXECUTOR = "Synapse X"
    elseif KRNL_LOADED then EXECUTOR = "KRNL"
    elseif _G.FLUXUS_LOADED then EXECUTOR = "Fluxus"
    end
end

-- ─────────────────────────────────────────────
--  CONSTANTS
-- ─────────────────────────────────────────────
local NEXUS_TAG     = "NexusUI_Instance"
local CONFIG_FOLDER = "NexusUI"
local VERSION       = "2.5.0"

-- ─────────────────────────────────────────────
--  THEME ENGINE
-- ─────────────────────────────────────────────
local Themes = {
    Purple = {
        Name            = "Purple",
        Background      = Color3.fromRGB(14, 13, 22),
        Surface         = Color3.fromRGB(20, 19, 32),
        SurfaceAlt      = Color3.fromRGB(26, 24, 42),
        Card            = Color3.fromRGB(22, 21, 36),
        CardAlt         = Color3.fromRGB(29, 27, 46),
        Sidebar         = Color3.fromRGB(16, 15, 26),
        Accent          = Color3.fromRGB(124, 92, 246),
        AccentDark      = Color3.fromRGB(90, 62, 200),
        AccentLight     = Color3.fromRGB(160, 130, 255),
        AccentGradient1 = Color3.fromRGB(124, 92, 246),
        AccentGradient2 = Color3.fromRGB(80, 50, 200),
        Text            = Color3.fromRGB(240, 238, 255),
        TextSub         = Color3.fromRGB(170, 165, 200),
        TextMuted       = Color3.fromRGB(100, 95, 130),
        TextAccent      = Color3.fromRGB(160, 130, 255),
        Border          = Color3.fromRGB(40, 37, 65),
        BorderAccent    = Color3.fromRGB(124, 92, 246),
        Success         = Color3.fromRGB(52, 211, 153),
        Warning         = Color3.fromRGB(251, 191, 36),
        Error           = Color3.fromRGB(248, 113, 113),
        Info            = Color3.fromRGB(96, 165, 250),
        Toggle          = Color3.fromRGB(42, 39, 70),
        ToggleOn        = Color3.fromRGB(124, 92, 246),
        SliderFill      = Color3.fromRGB(124, 92, 246),
        SliderTrack     = Color3.fromRGB(35, 32, 58),
        InputBg         = Color3.fromRGB(18, 17, 30),
        InputBorder     = Color3.fromRGB(45, 42, 72),
        Shadow          = Color3.fromRGB(0, 0, 0),
        Overlay         = Color3.fromRGB(8, 7, 14),
    },
    Blue = {
        Name            = "Blue",
        Background      = Color3.fromRGB(10, 14, 26),
        Surface         = Color3.fromRGB(14, 20, 38),
        SurfaceAlt      = Color3.fromRGB(20, 28, 52),
        Card            = Color3.fromRGB(16, 22, 42),
        CardAlt         = Color3.fromRGB(22, 30, 56),
        Sidebar         = Color3.fromRGB(12, 16, 30),
        Accent          = Color3.fromRGB(59, 130, 246),
        AccentDark      = Color3.fromRGB(37, 99, 210),
        AccentLight     = Color3.fromRGB(147, 197, 253),
        AccentGradient1 = Color3.fromRGB(59, 130, 246),
        AccentGradient2 = Color3.fromRGB(37, 99, 210),
        Text            = Color3.fromRGB(230, 238, 255),
        TextSub         = Color3.fromRGB(148, 175, 220),
        TextMuted       = Color3.fromRGB(80, 105, 155),
        TextAccent      = Color3.fromRGB(147, 197, 253),
        Border          = Color3.fromRGB(30, 45, 80),
        BorderAccent    = Color3.fromRGB(59, 130, 246),
        Success         = Color3.fromRGB(52, 211, 153),
        Warning         = Color3.fromRGB(251, 191, 36),
        Error           = Color3.fromRGB(248, 113, 113),
        Info            = Color3.fromRGB(96, 165, 250),
        Toggle          = Color3.fromRGB(30, 45, 80),
        ToggleOn        = Color3.fromRGB(59, 130, 246),
        SliderFill      = Color3.fromRGB(59, 130, 246),
        SliderTrack     = Color3.fromRGB(25, 38, 68),
        InputBg         = Color3.fromRGB(12, 18, 34),
        InputBorder     = Color3.fromRGB(35, 52, 90),
        Shadow          = Color3.fromRGB(0, 0, 0),
        Overlay         = Color3.fromRGB(5, 8, 18),
    },
    Green = {
        Name            = "Green",
        Background      = Color3.fromRGB(10, 18, 14),
        Surface         = Color3.fromRGB(14, 26, 20),
        SurfaceAlt      = Color3.fromRGB(18, 34, 26),
        Card            = Color3.fromRGB(14, 26, 20),
        CardAlt         = Color3.fromRGB(20, 34, 28),
        Sidebar         = Color3.fromRGB(10, 20, 16),
        Accent          = Color3.fromRGB(52, 211, 153),
        AccentDark      = Color3.fromRGB(16, 185, 129),
        AccentLight     = Color3.fromRGB(110, 231, 183),
        AccentGradient1 = Color3.fromRGB(52, 211, 153),
        AccentGradient2 = Color3.fromRGB(16, 185, 129),
        Text            = Color3.fromRGB(220, 255, 240),
        TextSub         = Color3.fromRGB(134, 190, 168),
        TextMuted       = Color3.fromRGB(70, 130, 100),
        TextAccent      = Color3.fromRGB(110, 231, 183),
        Border          = Color3.fromRGB(25, 55, 40),
        BorderAccent    = Color3.fromRGB(52, 211, 153),
        Success         = Color3.fromRGB(52, 211, 153),
        Warning         = Color3.fromRGB(251, 191, 36),
        Error           = Color3.fromRGB(248, 113, 113),
        Info            = Color3.fromRGB(96, 165, 250),
        Toggle          = Color3.fromRGB(20, 50, 36),
        ToggleOn        = Color3.fromRGB(52, 211, 153),
        SliderFill      = Color3.fromRGB(52, 211, 153),
        SliderTrack     = Color3.fromRGB(16, 40, 28),
        InputBg         = Color3.fromRGB(10, 20, 16),
        InputBorder     = Color3.fromRGB(28, 60, 44),
        Shadow          = Color3.fromRGB(0, 0, 0),
        Overlay         = Color3.fromRGB(5, 10, 7),
    },
    Neon = {
        Name            = "Neon",
        Background      = Color3.fromRGB(5, 5, 10),
        Surface         = Color3.fromRGB(8, 8, 16),
        SurfaceAlt      = Color3.fromRGB(12, 12, 22),
        Card            = Color3.fromRGB(9, 9, 18),
        CardAlt         = Color3.fromRGB(14, 14, 26),
        Sidebar         = Color3.fromRGB(6, 6, 12),
        Accent          = Color3.fromRGB(0, 255, 200),
        AccentDark      = Color3.fromRGB(0, 200, 160),
        AccentLight     = Color3.fromRGB(100, 255, 220),
        AccentGradient1 = Color3.fromRGB(0, 255, 200),
        AccentGradient2 = Color3.fromRGB(100, 0, 255),
        Text            = Color3.fromRGB(220, 255, 250),
        TextSub         = Color3.fromRGB(120, 200, 190),
        TextMuted       = Color3.fromRGB(60, 120, 110),
        TextAccent      = Color3.fromRGB(0, 255, 200),
        Border          = Color3.fromRGB(0, 80, 60),
        BorderAccent    = Color3.fromRGB(0, 255, 200),
        Success         = Color3.fromRGB(0, 255, 150),
        Warning         = Color3.fromRGB(255, 220, 0),
        Error           = Color3.fromRGB(255, 50, 80),
        Info            = Color3.fromRGB(0, 200, 255),
        Toggle          = Color3.fromRGB(10, 40, 34),
        ToggleOn        = Color3.fromRGB(0, 255, 200),
        SliderFill      = Color3.fromRGB(0, 255, 200),
        SliderTrack     = Color3.fromRGB(8, 30, 25),
        InputBg         = Color3.fromRGB(5, 8, 14),
        InputBorder     = Color3.fromRGB(0, 100, 80),
        Shadow          = Color3.fromRGB(0, 0, 0),
        Overlay         = Color3.fromRGB(2, 2, 5),
    },
    Cyber = {
        Name            = "Cyber",
        Background      = Color3.fromRGB(8, 6, 14),
        Surface         = Color3.fromRGB(14, 10, 24),
        SurfaceAlt      = Color3.fromRGB(20, 15, 34),
        Card            = Color3.fromRGB(16, 12, 28),
        CardAlt         = Color3.fromRGB(22, 17, 38),
        Sidebar         = Color3.fromRGB(10, 8, 18),
        Accent          = Color3.fromRGB(255, 0, 128),
        AccentDark      = Color3.fromRGB(200, 0, 100),
        AccentLight     = Color3.fromRGB(255, 100, 180),
        AccentGradient1 = Color3.fromRGB(255, 0, 128),
        AccentGradient2 = Color3.fromRGB(100, 0, 255),
        Text            = Color3.fromRGB(255, 230, 245),
        TextSub         = Color3.fromRGB(200, 150, 190),
        TextMuted       = Color3.fromRGB(120, 80, 120),
        TextAccent      = Color3.fromRGB(255, 100, 180),
        Border          = Color3.fromRGB(80, 20, 60),
        BorderAccent    = Color3.fromRGB(255, 0, 128),
        Success         = Color3.fromRGB(52, 211, 153),
        Warning         = Color3.fromRGB(255, 200, 0),
        Error           = Color3.fromRGB(255, 60, 60),
        Info            = Color3.fromRGB(0, 200, 255),
        Toggle          = Color3.fromRGB(50, 10, 38),
        ToggleOn        = Color3.fromRGB(255, 0, 128),
        SliderFill      = Color3.fromRGB(255, 0, 128),
        SliderTrack     = Color3.fromRGB(40, 8, 30),
        InputBg         = Color3.fromRGB(8, 6, 14),
        InputBorder     = Color3.fromRGB(90, 20, 70),
        Shadow          = Color3.fromRGB(0, 0, 0),
        Overlay         = Color3.fromRGB(4, 3, 8),
    },
    Light = {
        Name            = "Light",
        Background      = Color3.fromRGB(245, 245, 250),
        Surface         = Color3.fromRGB(255, 255, 255),
        SurfaceAlt      = Color3.fromRGB(238, 238, 248),
        Card            = Color3.fromRGB(250, 250, 255),
        CardAlt         = Color3.fromRGB(235, 235, 245),
        Sidebar         = Color3.fromRGB(230, 228, 245),
        Accent          = Color3.fromRGB(124, 92, 246),
        AccentDark      = Color3.fromRGB(90, 62, 200),
        AccentLight     = Color3.fromRGB(160, 130, 255),
        AccentGradient1 = Color3.fromRGB(124, 92, 246),
        AccentGradient2 = Color3.fromRGB(80, 50, 200),
        Text            = Color3.fromRGB(20, 18, 40),
        TextSub         = Color3.fromRGB(80, 75, 110),
        TextMuted       = Color3.fromRGB(150, 145, 175),
        TextAccent      = Color3.fromRGB(100, 70, 220),
        Border          = Color3.fromRGB(210, 205, 235),
        BorderAccent    = Color3.fromRGB(124, 92, 246),
        Success         = Color3.fromRGB(16, 185, 129),
        Warning         = Color3.fromRGB(217, 119, 6),
        Error           = Color3.fromRGB(220, 38, 38),
        Info            = Color3.fromRGB(37, 99, 235),
        Toggle          = Color3.fromRGB(210, 205, 235),
        ToggleOn        = Color3.fromRGB(124, 92, 246),
        SliderFill      = Color3.fromRGB(124, 92, 246),
        SliderTrack     = Color3.fromRGB(210, 205, 235),
        InputBg         = Color3.fromRGB(248, 248, 255),
        InputBorder     = Color3.fromRGB(200, 195, 230),
        Shadow          = Color3.fromRGB(100, 90, 150),
        Overlay         = Color3.fromRGB(200, 195, 230),
    },
    Orange = {
        Name            = "Orange",
        Background      = Color3.fromRGB(16, 10, 6),
        Surface         = Color3.fromRGB(24, 15, 8),
        SurfaceAlt      = Color3.fromRGB(32, 20, 12),
        Card            = Color3.fromRGB(26, 17, 10),
        CardAlt         = Color3.fromRGB(34, 22, 14),
        Sidebar         = Color3.fromRGB(18, 12, 7),
        Accent          = Color3.fromRGB(249, 115, 22),
        AccentDark      = Color3.fromRGB(194, 65, 12),
        AccentLight     = Color3.fromRGB(253, 186, 116),
        AccentGradient1 = Color3.fromRGB(249, 115, 22),
        AccentGradient2 = Color3.fromRGB(220, 60, 10),
        Text            = Color3.fromRGB(255, 240, 225),
        TextSub         = Color3.fromRGB(210, 170, 130),
        TextMuted       = Color3.fromRGB(140, 100, 70),
        TextAccent      = Color3.fromRGB(253, 186, 116),
        Border          = Color3.fromRGB(70, 35, 15),
        BorderAccent    = Color3.fromRGB(249, 115, 22),
        Success         = Color3.fromRGB(52, 211, 153),
        Warning         = Color3.fromRGB(251, 191, 36),
        Error           = Color3.fromRGB(248, 113, 113),
        Info            = Color3.fromRGB(96, 165, 250),
        Toggle          = Color3.fromRGB(55, 28, 10),
        ToggleOn        = Color3.fromRGB(249, 115, 22),
        SliderFill      = Color3.fromRGB(249, 115, 22),
        SliderTrack     = Color3.fromRGB(45, 22, 8),
        InputBg         = Color3.fromRGB(14, 9, 5),
        InputBorder     = Color3.fromRGB(75, 38, 16),
        Shadow          = Color3.fromRGB(0, 0, 0),
        Overlay         = Color3.fromRGB(8, 5, 2),
    },
    Red = {
        Name            = "Red",
        Background      = Color3.fromRGB(16, 6, 6),
        Surface         = Color3.fromRGB(24, 10, 10),
        SurfaceAlt      = Color3.fromRGB(32, 14, 14),
        Card            = Color3.fromRGB(26, 11, 11),
        CardAlt         = Color3.fromRGB(34, 15, 15),
        Sidebar         = Color3.fromRGB(18, 7, 7),
        Accent          = Color3.fromRGB(239, 68, 68),
        AccentDark      = Color3.fromRGB(185, 28, 28),
        AccentLight     = Color3.fromRGB(252, 165, 165),
        AccentGradient1 = Color3.fromRGB(239, 68, 68),
        AccentGradient2 = Color3.fromRGB(180, 20, 20),
        Text            = Color3.fromRGB(255, 235, 235),
        TextSub         = Color3.fromRGB(210, 155, 155),
        TextMuted       = Color3.fromRGB(150, 90, 90),
        TextAccent      = Color3.fromRGB(252, 165, 165),
        Border          = Color3.fromRGB(75, 22, 22),
        BorderAccent    = Color3.fromRGB(239, 68, 68),
        Success         = Color3.fromRGB(52, 211, 153),
        Warning         = Color3.fromRGB(251, 191, 36),
        Error           = Color3.fromRGB(248, 113, 113),
        Info            = Color3.fromRGB(96, 165, 250),
        Toggle          = Color3.fromRGB(60, 18, 18),
        ToggleOn        = Color3.fromRGB(239, 68, 68),
        SliderFill      = Color3.fromRGB(239, 68, 68),
        SliderTrack     = Color3.fromRGB(48, 14, 14),
        InputBg         = Color3.fromRGB(14, 5, 5),
        InputBorder     = Color3.fromRGB(80, 24, 24),
        Shadow          = Color3.fromRGB(0, 0, 0),
        Overlay         = Color3.fromRGB(8, 3, 3),
    },
}

-- ─────────────────────────────────────────────
--  UTILITY FUNCTIONS
-- ─────────────────────────────────────────────
local Utility = {}

function Utility.Tween(obj, properties, duration, style, direction, callback)
    duration  = duration  or 0.25
    style     = style     or Enum.EasingStyle.Quart
    direction = direction or Enum.EasingDirection.Out
    local info = TweenInfo.new(duration, style, direction)
    local t    = TweenService:Create(obj, info, properties)
    t:Play()
    if callback then
        t.Completed:Connect(callback)
    end
    return t
end

function Utility.Create(class, props, children)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do
        local ok, err = pcall(function()
            obj[k] = v
        end)
        if not ok then
            warn(("[NexusUI] Skipped invalid property '%s' on %s: %s"):format(tostring(k), class, tostring(err)))
        end
    end
    for _, child in ipairs(children or {}) do
        child.Parent = obj
    end
    return obj
end

function Utility.Round(n, decimals)
    local factor = 10 ^ (decimals or 0)
    return math.floor(n * factor + 0.5) / factor
end

function Utility.Clamp(n, min, max)
    return math.max(min, math.min(max, n))
end

function Utility.Lerp(a, b, t)
    return a + (b - a) * t
end

function Utility.LerpColor(c1, c2, t)
    return Color3.new(
        Utility.Lerp(c1.R, c2.R, t),
        Utility.Lerp(c1.G, c2.G, t),
        Utility.Lerp(c1.B, c2.B, t)
    )
end

function Utility.GetScreenSize()
    return Camera.ViewportSize
end

function Utility.GetScale()
    local vp = Utility.GetScreenSize()
    local base = Vector2.new(1920, 1080)
    local scale = math.min(vp.X / base.X, vp.Y / base.Y)
    -- +25% larger than base calculation, capped at 2.0
    return math.max(0.5, math.min(2.0, scale * 1.25))
end

function Utility.AddRipple(button, theme)
    button.MouseButton1Down:Connect(function(x, y)
        local ripple = Utility.Create("Frame", {
            Parent          = button,
            BackgroundColor3 = Color3.new(1,1,1),
            BackgroundTransparency = 0.8,
            BorderSizePixel  = 0,
            ZIndex           = button.ZIndex + 2,
            Size             = UDim2.new(0, 0, 0, 0),
            Position         = UDim2.new(0, x - button.AbsolutePosition.X, 0, y - button.AbsolutePosition.Y),
            AnchorPoint      = Vector2.new(0.5, 0.5),
        }, {
            Utility.Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
        })
        local targetSize = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2.5
        Utility.Tween(ripple, {
            Size                   = UDim2.new(0, targetSize, 0, targetSize),
            BackgroundTransparency = 1,
        }, 0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, function()
            ripple:Destroy()
        end)
    end)
end

function Utility.MakeDraggable(frame, handle, onDrag, bounds)
    local dragging  = false
    local dragStart = Vector2.new()
    local startPos  = UDim2.new()

    handle = handle or frame

    -- Check whether a screen position falls inside the handle's bounds
    local function isOverHandle(pos)
        local ap = handle.AbsolutePosition
        local as = handle.AbsoluteSize
        return pos.X >= ap.X and pos.X <= ap.X + as.X
           and pos.Y >= ap.Y and pos.Y <= ap.Y + as.Y
    end

    -- Use global InputBegan so child buttons don't swallow the event
    UserInputService.InputBegan:Connect(function(input, gpe)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and
           input.UserInputType ~= Enum.UserInputType.Touch then return end
        local screenPos = Vector2.new(input.Position.X, input.Position.Y)
        if not isOverHandle(screenPos) then return end
        dragging  = true
        dragStart = screenPos
        startPos  = frame.Position
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement and
           input.UserInputType ~= Enum.UserInputType.Touch then return end

        local curPos = Vector2.new(input.Position.X, input.Position.Y)
        local delta  = curPos - dragStart
        local newX   = startPos.X.Offset + delta.X
        local newY   = startPos.Y.Offset + delta.Y

        if bounds then
            local vp = Utility.GetScreenSize()
            local sx = frame.AbsoluteSize.X
            local sy = frame.AbsoluteSize.Y
            newX = Utility.Clamp(newX, 0, vp.X - sx)
            newY = Utility.Clamp(newY, 0, vp.Y - sy)
        end

        frame.Position = UDim2.new(startPos.X.Scale, newX, startPos.Y.Scale, newY)
        if onDrag then onDrag(newX, newY) end
    end)
end

function Utility.FormatNumber(n)
    if n >= 1e9 then
        return string.format("%.1fB", n / 1e9)
    elseif n >= 1e6 then
        return string.format("%.1fM", n / 1e6)
    elseif n >= 1e3 then
        return string.format("%.1fK", n / 1e3)
    end
    return tostring(n)
end

-- Config helpers
function Utility.EnsureFolder(name)
    if not isfolder then return end
    if not isfolder(name) then
        makefolder(name)
    end
end

function Utility.SaveConfig(folder, name, data)
    if not writefile then return end
    Utility.EnsureFolder(folder)
    local ok, encoded = pcall(HttpService.JSONEncode, HttpService, data)
    if ok then
        pcall(writefile, folder .. "/" .. name .. ".json", encoded)
    end
end

function Utility.LoadConfig(folder, name)
    if not readfile then return nil end
    local path = folder .. "/" .. name .. ".json"
    if not isfile or not isfile(path) then return nil end
    local ok, data = pcall(readfile, path)
    if not ok then return nil end
    local ok2, decoded = pcall(HttpService.JSONDecode, HttpService, data)
    return ok2 and decoded or nil
end

function Utility.DeleteConfig(folder, name)
    if not delfile then return end
    local path = folder .. "/" .. name .. ".json"
    if isfile and isfile(path) then
        pcall(delfile, path)
    end
end

function Utility.ListConfigs(folder)
    if not listfiles then return {} end
    Utility.EnsureFolder(folder)
    local ok, files = pcall(listfiles, folder)
    if not ok then return {} end
    local names = {}
    for _, f in ipairs(files) do
        local name = f:match("([^/\\]+)%.json$")
        if name then
            table.insert(names, name)
        end
    end
    return names
end

-- Color utilities
function Utility.RGB(r, g, b) return Color3.fromRGB(r, g, b) end
function Utility.ToHex(color)
    return string.format("#%02X%02X%02X",
        math.floor(color.R * 255),
        math.floor(color.G * 255),
        math.floor(color.B * 255)
    )
end

function Utility.FromHex(hex)
    hex = hex:gsub("#", "")
    local r = tonumber(hex:sub(1,2), 16) or 0
    local g = tonumber(hex:sub(3,4), 16) or 0
    local b = tonumber(hex:sub(5,6), 16) or 0
    return Color3.fromRGB(r, g, b)
end

function Utility.ColorToHSV(color)
    return Color3.toHSV(color)
end

function Utility.HSVToColor(h, s, v)
    return Color3.fromHSV(h, s, v)
end

-- ─────────────────────────────────────────────
--  ICONS (Text-based using unicode/Roblox fonts)
-- ─────────────────────────────────────────────
local Icons = {
    Main       = ">_",
    Combat     = "⚔",
    Visuals    = "👁",
    Player     = "👤",
    Teleport   = "⚡",
    Utility    = "🔧",
    Settings   = "⚙",
    Config     = "💾",
    Credits    = "★",
    Developer  = "</>",
    Home       = "🏠",
    Star       = "★",
    Heart      = "♥",
    Shield     = "🛡",
    Sword      = "⚔",
    Eye        = "◉",
    Gear       = "⚙",
    Bolt       = "⚡",
    Lock       = "🔒",
    Key        = "🔑",
    Globe      = "🌐",
    Map        = "🗺",
    Target     = "◎",
    Flag       = "⚑",
    Bell       = "🔔",
    Chat       = "💬",
    Info       = "ℹ",
    Check      = "✓",
    Cross      = "✗",
    Arrow      = "→",
    Up         = "↑",
    Down       = "↓",
    Search     = "🔍",
    User       = "👤",
    Group      = "👥",
    Folder     = "📁",
    File       = "📄",
    Code       = "</>",
    Terminal   = ">_",
    Game       = "🎮",
    Trophy     = "🏆",
    Coin       = "💰",
    Percent    = "%",
    Plus       = "+",
    Minus      = "-",
    Close      = "×",
    Minimize   = "—",
    Maximize   = "□",
    Refresh    = "↻",
    Power      = "⏻",
    Box        = "☐",
    Menu       = "≡",
    Dots       = "···",
    Separator  = "│",
}

-- ─────────────────────────────────────────────
--  MAIN LIBRARY
-- ─────────────────────────────────────────────
local NexusUI = {}
NexusUI.__index = NexusUI
NexusUI._Version      = VERSION
NexusUI._Windows      = {}
NexusUI._Connections  = {}
NexusUI._Theme        = Themes.Purple
NexusUI._CustomThemes = {}
NexusUI._FPS          = 60
NexusUI._Loaded       = false
NexusUI.Themes        = Themes
NexusUI.Icons         = Icons
NexusUI.Utility       = Utility

-- Current theme accessor
function NexusUI:GetTheme()
    return self._Theme
end

function NexusUI:SetTheme(themeName)
    local t = Themes[themeName] or self._CustomThemes[themeName]
    if not t then
        warn("[NexusUI] Theme '" .. tostring(themeName) .. "' not found.")
        return
    end
    self._Theme = t
    -- Apply to all windows
    for _, win in ipairs(self._Windows) do
        if win._ApplyTheme then
            win:_ApplyTheme()
        end
    end
end

function NexusUI:RegisterTheme(name, themeData)
    -- Ensure all required fields exist, fallback to Purple
    local base = Themes.Purple
    local theme = {}
    for k, v in pairs(base) do
        theme[k] = themeData[k] or v
    end
    theme.Name = name
    self._CustomThemes[name] = theme
    Themes[name] = theme
end

-- FPS tracking
do
    local frames = 0
    local elapsed = 0
    RunService.RenderStepped:Connect(function(dt)
        frames  = frames + 1
        elapsed = elapsed + dt
        if elapsed >= 0.5 then
            NexusUI._FPS = math.floor(frames / elapsed + 0.5)
            frames  = 0
            elapsed = 0
        end
    end)
end

-- ─────────────────────────────────────────────
--  NOTIFICATION SYSTEM
-- ─────────────────────────────────────────────
local NotificationManager = {}
NotificationManager._Queue    = {}
NotificationManager._Active   = {}
NotificationManager._MaxStack = 5
NotificationManager._Container = nil

function NotificationManager:Init(theme)
    if self._Container then return end
    local gui = Utility.Create("ScreenGui", {
        Name            = "NexusUI_Notifications",
        ResetOnSpawn    = false,
        ZIndexBehavior  = Enum.ZIndexBehavior.Sibling,
        DisplayOrder    = 999,
    })

    -- Try to parent to CoreGui
    local ok = pcall(function() gui.Parent = CoreGui end)
    if not ok then gui.Parent = LocalPlayer:FindFirstChildOfClass("PlayerGui") end

    self._Container = Utility.Create("Frame", {
        Parent          = gui,
        BackgroundTransparency = 1,
        Size            = UDim2.new(0, 320, 1, 0),
        Position        = UDim2.new(1, -330, 0, 0),
        AnchorPoint     = Vector2.new(1, 0),
    }, {
        Utility.Create("UIListLayout", {
            SortOrder       = Enum.SortOrder.LayoutOrder,
            VerticalAlignment = Enum.VerticalAlignment.Top,
            Padding         = UDim.new(0, 8),
            FillDirection   = Enum.FillDirection.Vertical,
        }),
        Utility.Create("UIPadding", {
            PaddingTop   = UDim.new(0, 16),
            PaddingRight = UDim.new(0, 10),
        }),
    })
end

function NotificationManager:Send(opts)
    opts = opts or {}
    local nType    = opts.Type     or "Info"
    local title    = opts.Title    or "Notification"
    local message  = opts.Message  or ""
    local duration = opts.Duration or 4
    local theme    = NexusUI._Theme

    local iconColor = theme.Info
    local icon = "ℹ"
    if nType == "Success" then iconColor = theme.Success; icon = "✓"
    elseif nType == "Warning" then iconColor = theme.Warning; icon = "⚠"
    elseif nType == "Error" then iconColor = theme.Error; icon = "✗"
    elseif nType == "Loading" then iconColor = theme.Accent; icon = "↻"
    end

    local card = Utility.Create("Frame", {
        Parent          = self._Container,
        BackgroundColor3 = theme.Card,
        BorderSizePixel = 0,
        Size            = UDim2.new(1, 0, 0, 76),
        BackgroundTransparency = 1,
        LayoutOrder     = #self._Active + 1,
    }, {
        Utility.Create("UICorner",    { CornerRadius = UDim.new(0, 10) }),
        Utility.Create("UIStroke",    {
            Color = iconColor,
            Thickness = 1,
            Transparency = 0.5,
        }),

        -- Accent bar
        Utility.Create("Frame", {
            Name              = "Bar",
            BackgroundColor3  = iconColor,
            BorderSizePixel   = 0,
            Size              = UDim2.new(0, 4, 1, -12),
            Position          = UDim2.new(0, 0, 0, 6),
            AnchorPoint       = Vector2.new(0, 0),
        }, {
            Utility.Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
        }),

        -- Icon
        Utility.Create("TextLabel", {
            Name              = "Icon",
            BackgroundTransparency = 1,
            Size              = UDim2.new(0, 30, 0, 30),
            Position          = UDim2.new(0, 14, 0, 12),
            Text              = icon,
            TextColor3        = iconColor,
            TextSize          = 18,
            Font              = Enum.Font.GothamBold,
            TextXAlignment    = Enum.TextXAlignment.Center,
        }),

        -- Title
        Utility.Create("TextLabel", {
            Name              = "Title",
            BackgroundTransparency = 1,
            Size              = UDim2.new(1, -80, 0, 20),
            Position          = UDim2.new(0, 50, 0, 12),
            Text              = title,
            TextColor3        = theme.Text,
            TextSize          = 14,
            Font              = Enum.Font.GothamBold,
            TextXAlignment    = Enum.TextXAlignment.Left,
            TextTruncate      = Enum.TextTruncate.AtEnd,
        }),

        -- Message
        Utility.Create("TextLabel", {
            Name              = "Message",
            BackgroundTransparency = 1,
            Size              = UDim2.new(1, -80, 0, 32),
            Position          = UDim2.new(0, 50, 0, 34),
            Text              = message,
            TextColor3        = theme.TextSub,
            TextSize          = 12,
            Font              = Enum.Font.Gotham,
            TextXAlignment    = Enum.TextXAlignment.Left,
            TextWrapped       = true,
        }),

        -- Progress bar
        Utility.Create("Frame", {
            Name              = "ProgressBg",
            BackgroundColor3  = theme.SliderTrack,
            BorderSizePixel   = 0,
            Size              = UDim2.new(1, -12, 0, 2),
            Position          = UDim2.new(0, 6, 1, -4),
            AnchorPoint       = Vector2.new(0, 1),
        }, {
            Utility.Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
            Utility.Create("Frame", {
                Name             = "Fill",
                BackgroundColor3 = iconColor,
                BorderSizePixel  = 0,
                Size             = UDim2.new(1, 0, 1, 0),
            }, {
                Utility.Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
            }),
        }),
    })

    -- Animate in
    card.Position = UDim2.new(1, 30, 0, 0)
    Utility.Tween(card, { BackgroundTransparency = 0 }, 0.1)
    Utility.Tween(card, { Position = UDim2.new(0, 0, 0, 0) }, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    -- Progress countdown
    local fill = card:FindFirstChild("ProgressBg") and card.ProgressBg:FindFirstChild("Fill")
    if fill then
        Utility.Tween(fill, { Size = UDim2.new(0, 0, 1, 0) }, duration, Enum.EasingStyle.Linear)
    end

    table.insert(self._Active, card)

    -- Auto close
    task.delay(duration, function()
        if not card.Parent then return end
        Utility.Tween(card, {
            Position             = UDim2.new(1, 30, 0, 0),
            BackgroundTransparency = 1,
        }, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In, function()
            card:Destroy()
        end)
        -- Remove from active
        for i, v in ipairs(self._Active) do
            if v == card then table.remove(self._Active, i) break end
        end
    end)

    -- Trim oldest if overflow
    while #self._Active > self._MaxStack do
        local oldest = table.remove(self._Active, 1)
        if oldest and oldest.Parent then oldest:Destroy() end
    end

    return card
end

-- ─────────────────────────────────────────────
--  DIALOG SYSTEM
-- ─────────────────────────────────────────────
local DialogManager = {}

function DialogManager:Show(opts)
    opts = opts or {}
    local title   = opts.Title   or "Dialog"
    local message = opts.Message or ""
    local dType   = opts.Type    or "Confirm"  -- Confirm | YesNo | Input | Loading
    local callback = opts.Callback
    local theme   = NexusUI._Theme

    local gui = Utility.Create("ScreenGui", {
        Name           = "NexusUI_Dialog",
        ResetOnSpawn   = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder   = 1000,
    })
    local ok = pcall(function() gui.Parent = CoreGui end)
    if not ok then gui.Parent = LocalPlayer:FindFirstChildOfClass("PlayerGui") end

    -- Overlay
    local overlay = Utility.Create("Frame", {
        Parent           = gui,
        BackgroundColor3 = theme.Overlay,
        BackgroundTransparency = 0.3,
        Size             = UDim2.new(1, 0, 1, 0),
    })

    -- Dialog box
    local box = Utility.Create("Frame", {
        Parent           = overlay,
        BackgroundColor3 = theme.Surface,
        BorderSizePixel  = 0,
        Size             = UDim2.new(0, 360, 0, 180),
        Position         = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint      = Vector2.new(0.5, 0.5),
    }, {
        Utility.Create("UICorner",  { CornerRadius = UDim.new(0, 14) }),
        Utility.Create("UIStroke",  { Color = theme.Border, Thickness = 1 }),
    })

    -- Title
    Utility.Create("TextLabel", {
        Parent           = box,
        BackgroundTransparency = 1,
        Size             = UDim2.new(1, -40, 0, 40),
        Position         = UDim2.new(0, 20, 0, 10),
        Text             = title,
        TextColor3       = theme.Text,
        TextSize         = 16,
        Font             = Enum.Font.GothamBold,
        TextXAlignment   = Enum.TextXAlignment.Left,
    })

    -- Message
    Utility.Create("TextLabel", {
        Parent           = box,
        BackgroundTransparency = 1,
        Size             = UDim2.new(1, -40, 0, 60),
        Position         = UDim2.new(0, 20, 0, 50),
        Text             = message,
        TextColor3       = theme.TextSub,
        TextSize         = 13,
        Font             = Enum.Font.Gotham,
        TextXAlignment   = Enum.TextXAlignment.Left,
        TextWrapped      = true,
    })

    local function close(result)
        Utility.Tween(box, { Size = UDim2.new(0, 360, 0, 0), BackgroundTransparency = 1 }, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In, function()
            gui:Destroy()
        end)
        if callback then callback(result) end
    end

    -- Input box if needed
    local inputBox
    if dType == "Input" then
        box.Size = UDim2.new(0, 360, 0, 220)
        inputBox = Utility.Create("TextBox", {
            Parent           = box,
            BackgroundColor3 = theme.InputBg,
            BorderSizePixel  = 0,
            Size             = UDim2.new(1, -40, 0, 36),
            Position         = UDim2.new(0, 20, 0, 118),
            PlaceholderText  = opts.Placeholder or "Type here...",
            PlaceholderColor3 = theme.TextMuted,
            TextColor3       = theme.Text,
            TextSize         = 13,
            Font             = Enum.Font.Gotham,
            ClearTextOnFocus = false,
            Text             = opts.Default or "",
        }, {
            Utility.Create("UICorner",  { CornerRadius = UDim.new(0, 8) }),
            Utility.Create("UIStroke",  { Color = theme.InputBorder, Thickness = 1 }),
            Utility.Create("UIPadding", { PaddingLeft = UDim.new(0, 10) }),
        })
    end

    -- Loading spinner if needed
    if dType == "Loading" then
        box.Size = UDim2.new(0, 300, 0, 140)
        Utility.Create("TextLabel", {
            Parent           = box,
            BackgroundTransparency = 1,
            Size             = UDim2.new(1, 0, 0, 30),
            Position         = UDim2.new(0, 0, 0, 90),
            Text             = "↻ Loading...",
            TextColor3       = theme.Accent,
            TextSize         = 18,
            Font             = Enum.Font.GothamBold,
            TextXAlignment   = Enum.TextXAlignment.Center,
        })
        -- Animate appearance
        box.Size = UDim2.new(0, 0, 0, 0)
        Utility.Tween(box, { Size = UDim2.new(0, 300, 0, 140) }, 0.3, Enum.EasingStyle.Back)
        return {
            Close = function() close(nil) end
        }
    end

    -- Buttons
    local btnY = dType == "Input" and 170 or 120
    box.Size = UDim2.new(0, 360, 0, btnY + 50)

    if dType == "Confirm" or dType == "Loading" then
        -- Single confirm button
        local btn = Utility.Create("TextButton", {
            Parent           = box,
            BackgroundColor3 = theme.Accent,
            BorderSizePixel  = 0,
            Size             = UDim2.new(1, -40, 0, 38),
            Position         = UDim2.new(0, 20, 0, btnY),
            Text             = opts.ConfirmText or "OK",
            TextColor3       = Color3.new(1,1,1),
            TextSize         = 13,
            Font             = Enum.Font.GothamBold,
        }, {
            Utility.Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
        })
        btn.MouseButton1Click:Connect(function()
            if dType == "Input" then
                close(inputBox and inputBox.Text or "")
            else
                close(true)
            end
        end)
    else
        -- Two buttons
        local confirmBtn = Utility.Create("TextButton", {
            Parent           = box,
            BackgroundColor3 = theme.Accent,
            BorderSizePixel  = 0,
            Size             = UDim2.new(0.5, -26, 0, 38),
            Position         = UDim2.new(0, 20, 0, btnY),
            Text             = opts.ConfirmText or (dType == "YesNo" and "Yes" or "Confirm"),
            TextColor3       = Color3.new(1,1,1),
            TextSize         = 13,
            Font             = Enum.Font.GothamBold,
        }, {
            Utility.Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
        })
        local cancelBtn = Utility.Create("TextButton", {
            Parent           = box,
            BackgroundColor3 = theme.SurfaceAlt,
            BorderSizePixel  = 0,
            Size             = UDim2.new(0.5, -26, 0, 38),
            Position         = UDim2.new(0.5, 6, 0, btnY),
            Text             = opts.CancelText or (dType == "YesNo" and "No" or "Cancel"),
            TextColor3       = theme.TextSub,
            TextSize         = 13,
            Font             = Enum.Font.GothamBold,
        }, {
            Utility.Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
            Utility.Create("UIStroke", { Color = theme.Border, Thickness = 1 }),
        })

        confirmBtn.MouseButton1Click:Connect(function()
            if dType == "Input" then close(inputBox and inputBox.Text or "")
            else close(true) end
        end)
        cancelBtn.MouseButton1Click:Connect(function()
            close(false)
        end)
    end

    -- Animate in
    box.Size = UDim2.new(0, 0, 0, 0)
    local targetH = (dType == "Input" and 220 or (dType == "Loading" and 140 or (dType == "Confirm" and 180 or 180)))
    Utility.Tween(box, { Size = UDim2.new(0, 360, 0, targetH) }, 0.3, Enum.EasingStyle.Back)

    return {
        Close = function() close(nil) end
    }
end

-- ─────────────────────────────────────────────
--  COLOR PICKER POPUP
-- ─────────────────────────────────────────────
local function CreateColorPicker(parent, initColor, onChange, theme)
    local h, s, v = Color3.toHSV(initColor)
    local pickerOpen = false
    local picker

    local container = Utility.Create("Frame", {
        Parent           = parent,
        BackgroundColor3 = theme.Card,
        BorderSizePixel  = 0,
        Size             = UDim2.new(1, 0, 0, 44),
    }, {
        Utility.Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
        Utility.Create("UIStroke", { Color = theme.Border, Thickness = 1 }),
    })

    local preview = Utility.Create("Frame", {
        Parent          = container,
        BackgroundColor3 = initColor,
        BorderSizePixel = 0,
        Size            = UDim2.new(0, 26, 0, 26),
        Position        = UDim2.new(1, -36, 0.5, 0),
        AnchorPoint     = Vector2.new(0, 0.5),
    }, {
        Utility.Create("UICorner",  { CornerRadius = UDim.new(0, 6) }),
        Utility.Create("UIStroke",  { Color = theme.Border, Thickness = 1 }),
    })

    local hexLabel = Utility.Create("TextLabel", {
        Parent           = container,
        BackgroundTransparency = 1,
        Size             = UDim2.new(1, -80, 1, 0),
        Position         = UDim2.new(0, 12, 0, 0),
        Text             = Utility.ToHex(initColor),
        TextColor3       = theme.TextSub,
        TextSize         = 12,
        Font             = Enum.Font.Code,
        TextXAlignment   = Enum.TextXAlignment.Left,
    })

    local function updateColor(nh, ns, nv)
        h, s, v = nh, ns, nv
        local c = Color3.fromHSV(h, s, v)
        preview.BackgroundColor3 = c
        hexLabel.Text = Utility.ToHex(c)
        if onChange then onChange(c) end
    end

    -- Popup picker
    preview.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        if picker then picker:Destroy(); picker = nil; pickerOpen = false return end

        pickerOpen = true
        picker = Utility.Create("Frame", {
            Parent           = container,
            BackgroundColor3 = theme.Surface,
            BorderSizePixel  = 0,
            Size             = UDim2.new(0, 220, 0, 200),
            Position         = UDim2.new(1, -220, 1, 4),
            ZIndex           = 20,
        }, {
            Utility.Create("UICorner", { CornerRadius = UDim.new(0, 10) }),
            Utility.Create("UIStroke", { Color = theme.Border, Thickness = 1 }),
        })

        -- SV Square
        local svFrame = Utility.Create("ImageLabel", {
            Parent          = picker,
            BackgroundColor3 = Color3.fromHSV(h, 1, 1),
            BorderSizePixel = 0,
            Size            = UDim2.new(1, -16, 0, 120),
            Position        = UDim2.new(0, 8, 0, 8),
            Image           = "rbxassetid://6020299385",
            ZIndex          = 21,
        }, {
            Utility.Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
        })

        -- White → transparent overlay
        Utility.Create("ImageLabel", {
            Parent = svFrame,
            Size   = UDim2.new(1, 0, 1, 0),
            Image  = "rbxassetid://6020299385",
            ImageColor3 = Color3.new(1,1,1),
            BackgroundTransparency = 1,
            ZIndex = 22,
        })

        -- SV cursor
        local svCursor = Utility.Create("Frame", {
            Parent          = svFrame,
            BackgroundColor3 = Color3.new(1,1,1),
            BorderSizePixel = 0,
            Size            = UDim2.new(0, 12, 0, 12),
            AnchorPoint     = Vector2.new(0.5, 0.5),
            Position        = UDim2.new(s, 0, 1 - v, 0),
            ZIndex          = 23,
        }, {
            Utility.Create("UICorner",  { CornerRadius = UDim.new(1, 0) }),
            Utility.Create("UIStroke",  { Color = theme.Border, Thickness = 2 }),
        })

        -- Hue bar
        local hueBar = Utility.Create("ImageLabel", {
            Parent          = picker,
            BorderSizePixel = 0,
            Size            = UDim2.new(1, -16, 0, 16),
            Position        = UDim2.new(0, 8, 0, 136),
            Image           = "rbxassetid://6020331641",
            ZIndex          = 21,
        }, {
            Utility.Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
        })

        local hueCursor = Utility.Create("Frame", {
            Parent          = hueBar,
            BackgroundColor3 = Color3.new(1,1,1),
            BorderSizePixel = 0,
            Size            = UDim2.new(0, 8, 1, 4),
            AnchorPoint     = Vector2.new(0.5, 0.5),
            Position        = UDim2.new(h, 0, 0.5, 0),
            ZIndex          = 22,
        }, {
            Utility.Create("UICorner",  { CornerRadius = UDim.new(0, 3) }),
            Utility.Create("UIStroke",  { Color = theme.Border, Thickness = 1 }),
        })

        -- Hex input
        local hexInput = Utility.Create("TextBox", {
            Parent           = picker,
            BackgroundColor3 = theme.InputBg,
            BorderSizePixel  = 0,
            Size             = UDim2.new(1, -16, 0, 28),
            Position         = UDim2.new(0, 8, 0, 160),
            Text             = Utility.ToHex(Color3.fromHSV(h, s, v)),
            TextColor3       = theme.Text,
            TextSize         = 12,
            Font             = Enum.Font.Code,
            ZIndex           = 21,
            ClearTextOnFocus = false,
        }, {
            Utility.Create("UICorner",  { CornerRadius = UDim.new(0, 6) }),
            Utility.Create("UIStroke",  { Color = theme.InputBorder, Thickness = 1 }),
            Utility.Create("UIPadding", { PaddingLeft = UDim.new(0, 8) }),
        })

        hexInput.FocusLost:Connect(function()
            local c = pcall(function()
                local col = Utility.FromHex(hexInput.Text)
                local nh, ns, nv = Color3.toHSV(col)
                hueCursor.Position = UDim2.new(nh, 0, 0.5, 0)
                svCursor.Position  = UDim2.new(ns, 0, 1 - nv, 0)
                svFrame.BackgroundColor3 = Color3.fromHSV(nh, 1, 1)
                updateColor(nh, ns, nv)
            end)
        end)

        -- Drag on SV
        local svDragging = false
        svFrame.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 or
               inp.UserInputType == Enum.UserInputType.Touch then
                svDragging = true
            end
        end)
        svFrame.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 or
               inp.UserInputType == Enum.UserInputType.Touch then
                svDragging = false
            end
        end)
        UserInputService.InputChanged:Connect(function(inp)
            if not svDragging then return end
            if inp.UserInputType ~= Enum.UserInputType.MouseMovement and
               inp.UserInputType ~= Enum.UserInputType.Touch then return end
            local rel = inp.Position - svFrame.AbsolutePosition
            local ns  = Utility.Clamp(rel.X / svFrame.AbsoluteSize.X, 0, 1)
            local nv  = Utility.Clamp(1 - rel.Y / svFrame.AbsoluteSize.Y, 0, 1)
            svCursor.Position = UDim2.new(ns, 0, 1 - nv, 0)
            hexInput.Text = Utility.ToHex(Color3.fromHSV(h, ns, nv))
            updateColor(h, ns, nv)
        end)

        -- Drag on Hue
        local hueDragging = false
        hueBar.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 or
               inp.UserInputType == Enum.UserInputType.Touch then
                hueDragging = true
            end
        end)
        hueBar.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 or
               inp.UserInputType == Enum.UserInputType.Touch then
                hueDragging = false
            end
        end)
        UserInputService.InputChanged:Connect(function(inp)
            if not hueDragging then return end
            if inp.UserInputType ~= Enum.UserInputType.MouseMovement and
               inp.UserInputType ~= Enum.UserInputType.Touch then return end
            local rel = inp.Position - hueBar.AbsolutePosition
            local nh  = Utility.Clamp(rel.X / hueBar.AbsoluteSize.X, 0, 1)
            hueCursor.Position = UDim2.new(nh, 0, 0.5, 0)
            svFrame.BackgroundColor3 = Color3.fromHSV(nh, 1, 1)
            hexInput.Text = Utility.ToHex(Color3.fromHSV(nh, s, v))
            updateColor(nh, s, v)
        end)
    end)

    return container, function() return Color3.fromHSV(h, s, v) end
end

-- ─────────────────────────────────────────────
--  ELEMENT BASE
-- ─────────────────────────────────────────────
local ElementBase = {}
ElementBase.__index = ElementBase

function ElementBase:_FireCallback(...)
    if self._Callback then
        local ok, err = pcall(self._Callback, ...)
        if not ok then
            warn("[NexusUI] Element callback error in '" .. tostring(self._Name) .. "': " .. tostring(err))
        end
    end
end

function ElementBase:SetVisible(v)
    if self._Container then self._Container.Visible = v end
end

function ElementBase:Destroy()
    if self._Container then self._Container:Destroy() end
end

-- ─────────────────────────────────────────────
--  SECTION CLASS
-- ─────────────────────────────────────────────
local Section = {}
Section.__index = Section
setmetatable(Section, { __index = ElementBase })

function Section.new(opts, theme, contentFrame)
    local self = setmetatable({}, Section)
    self._Name     = opts.Name or "Section"
    self._Theme    = theme
    self._Elements = {}
    self._Open     = true

    -- Container
    self._Container = Utility.Create("Frame", {
        Parent           = contentFrame,
        BackgroundTransparency = 1,
        Size             = UDim2.new(1, 0, 0, 0),
        AutomaticSize    = Enum.AutomaticSize.Y,
        ClipsDescendants = false,
    })

    -- Header
    local header = Utility.Create("TextButton", {
        Parent           = self._Container,
        BackgroundTransparency = 1,
        Size             = UDim2.new(1, 0, 0, 28),
        Text             = "",
        AutoButtonColor  = false,
    })

    local label = Utility.Create("TextLabel", {
        Parent           = header,
        BackgroundTransparency = 1,
        Size             = UDim2.new(1, -20, 1, 0),
        Position         = UDim2.new(0, 0, 0, 0),
        Text             = string.upper(opts.Name or "SECTION"),
        TextColor3       = theme.TextAccent,
        TextSize         = 11,
        Font             = Enum.Font.GothamBold,
        TextXAlignment   = Enum.TextXAlignment.Left,
    })

    local arrow = Utility.Create("TextLabel", {
        Parent           = header,
        BackgroundTransparency = 1,
        Size             = UDim2.new(0, 16, 1, 0),
        Position         = UDim2.new(1, -16, 0, 0),
        Text             = "▾",
        TextColor3       = theme.TextMuted,
        TextSize         = 12,
        Font             = Enum.Font.GothamBold,
        TextXAlignment   = Enum.TextXAlignment.Center,
    })

    -- Divider
    local divider = Utility.Create("Frame", {
        Parent           = self._Container,
        BackgroundColor3 = theme.Border,
        BorderSizePixel  = 0,
        Size             = UDim2.new(1, 0, 0, 1),
        Position         = UDim2.new(0, 0, 0, 28),
    })

    -- Content frame
    self._Content = Utility.Create("Frame", {
        Parent        = self._Container,
        BackgroundTransparency = 1,
        Size          = UDim2.new(1, 0, 0, 0),
        Position      = UDim2.new(0, 0, 0, 34),
        AutomaticSize = Enum.AutomaticSize.Y,
        ClipsDescendants = true,
    }, {
        Utility.Create("UIListLayout", {
            SortOrder   = Enum.SortOrder.LayoutOrder,
            Padding     = UDim.new(0, 6),
            FillDirection = Enum.FillDirection.Vertical,
        }),
    })

    -- Toggle collapse
    header.MouseButton1Click:Connect(function()
        self._Open = not self._Open
        if self._Open then
            Utility.Tween(arrow, { Rotation = 0 }, 0.2)
            self._Content.Visible = true
            Utility.Tween(self._Content, { Size = UDim2.new(1, 0, 0, self._Content.AbsoluteContentSize.Y + 6) }, 0.25)
        else
            Utility.Tween(arrow, { Rotation = -90 }, 0.2)
            Utility.Tween(self._Content, { Size = UDim2.new(1, 0, 0, 0) }, 0.25, nil, nil, function()
                if not self._Open then self._Content.Visible = false end
            end)
        end
    end)

    return self
end

-- ─────────────────────── Elements ────────────

function Section:CreateButton(opts)
    opts = opts or {}
    local theme   = self._Theme
    local name    = opts.Name or "Button"
    local cb      = opts.Callback

    local frame = Utility.Create("TextButton", {
        Parent           = self._Content,
        BackgroundColor3 = theme.Accent,
        BorderSizePixel  = 0,
        Size             = UDim2.new(1, 0, 0, 40),
        Text             = name,
        TextColor3       = Color3.new(1, 1, 1),
        TextSize         = 13,
        Font             = Enum.Font.GothamBold,
        AutoButtonColor  = false,
        ClipsDescendants = true,
    }, {
        Utility.Create("UICorner",  { CornerRadius = UDim.new(0, 8) }),
        Utility.Create("UIGradient", {
            Color    = ColorSequence.new({
                ColorSequenceKeypoint.new(0, theme.AccentGradient1),
                ColorSequenceKeypoint.new(1, theme.AccentGradient2),
            }),
            Rotation = 90,
        }),
    })

    -- Hover
    frame.MouseEnter:Connect(function()
        Utility.Tween(frame, { BackgroundColor3 = theme.AccentLight }, 0.15)
    end)
    frame.MouseLeave:Connect(function()
        Utility.Tween(frame, { BackgroundColor3 = theme.Accent }, 0.15)
    end)

    -- Click
    Utility.AddRipple(frame, theme)
    frame.MouseButton1Click:Connect(function()
        Utility.Tween(frame, { Size = UDim2.new(1, 0, 0, 36) }, 0.08)
        task.delay(0.1, function()
            Utility.Tween(frame, { Size = UDim2.new(1, 0, 0, 40) }, 0.1)
        end)
        if cb then pcall(cb) end
    end)

    local btn = setmetatable({
        _Container = frame,
        _Name      = name,
        _Callback  = cb,
    }, { __index = ElementBase })

    function btn:SetText(t) frame.Text = t end
    function btn:SetEnabled(e)
        frame.Active = e
        Utility.Tween(frame, { BackgroundTransparency = e and 0 or 0.5 }, 0.2)
    end

    table.insert(self._Elements, btn)
    return btn
end

function Section:CreateToggle(opts)
    opts = opts or {}
    local theme   = self._Theme
    local name    = opts.Name    or "Toggle"
    local desc    = opts.Description
    local initVal = opts.Value   or false
    local cb      = opts.Callback

    local value = initVal

    local frame = Utility.Create("Frame", {
        Parent           = self._Content,
        BackgroundColor3 = theme.Card,
        BorderSizePixel  = 0,
        Size             = UDim2.new(1, 0, 0, desc and 58 or 44),
    }, {
        Utility.Create("UICorner",  { CornerRadius = UDim.new(0, 8) }),
        Utility.Create("UIStroke",  { Color = theme.Border, Thickness = 1 }),
    })

    Utility.Create("TextLabel", {
        Parent           = frame,
        BackgroundTransparency = 1,
        Size             = UDim2.new(1, -70, 0, 22),
        Position         = UDim2.new(0, 14, 0, desc and 10 or 11),
        Text             = name,
        TextColor3       = theme.Text,
        TextSize         = 13,
        Font             = Enum.Font.GothamBold,
        TextXAlignment   = Enum.TextXAlignment.Left,
    })

    if desc then
        Utility.Create("TextLabel", {
            Parent           = frame,
            BackgroundTransparency = 1,
            Size             = UDim2.new(1, -70, 0, 16),
            Position         = UDim2.new(0, 14, 0, 32),
            Text             = desc,
            TextColor3       = theme.TextMuted,
            TextSize         = 11,
            Font             = Enum.Font.Gotham,
            TextXAlignment   = Enum.TextXAlignment.Left,
            TextWrapped      = true,
        })
    end

    -- Toggle track
    local track = Utility.Create("Frame", {
        Parent           = frame,
        BackgroundColor3 = value and theme.ToggleOn or theme.Toggle,
        BorderSizePixel  = 0,
        Size             = UDim2.new(0, 44, 0, 24),
        Position         = UDim2.new(1, -56, 0.5, 0),
        AnchorPoint      = Vector2.new(0, 0.5),
    }, {
        Utility.Create("UICorner",  { CornerRadius = UDim.new(1, 0) }),
    })

    local knob = Utility.Create("Frame", {
        Parent           = track,
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel  = 0,
        Size             = UDim2.new(0, 18, 0, 18),
        Position         = value and UDim2.new(1, -21, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
        AnchorPoint      = Vector2.new(0, 0.5),
    }, {
        Utility.Create("UICorner",  { CornerRadius = UDim.new(1, 0) }),
    })

    local function setToggle(v, animate)
        value = v
        local pos   = v and UDim2.new(1, -21, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
        local color = v and theme.ToggleOn or theme.Toggle
        if animate ~= false then
            Utility.Tween(knob,  { Position = pos   }, 0.2, Enum.EasingStyle.Quart)
            Utility.Tween(track, { BackgroundColor3 = color }, 0.2)
        else
            knob.Position             = pos
            track.BackgroundColor3    = color
        end
        if cb then pcall(cb, value) end
    end

    local btn = Utility.Create("TextButton", {
        Parent           = frame,
        BackgroundTransparency = 1,
        Size             = UDim2.new(1, 0, 1, 0),
        Text             = "",
    })
    btn.MouseButton1Click:Connect(function()
        setToggle(not value)
    end)

    frame.MouseEnter:Connect(function()
        Utility.Tween(frame, { BackgroundColor3 = theme.CardAlt }, 0.12)
    end)
    frame.MouseLeave:Connect(function()
        Utility.Tween(frame, { BackgroundColor3 = theme.Card }, 0.12)
    end)

    local toggle = setmetatable({
        _Container = frame,
        _Name      = name,
        _Callback  = cb,
    }, { __index = ElementBase })

    function toggle:SetValue(v) setToggle(v) end
    function toggle:GetValue() return value end

    table.insert(self._Elements, toggle)
    return toggle
end

function Section:CreateSlider(opts)
    opts = opts or {}
    local theme    = self._Theme
    local name     = opts.Name    or "Slider"
    local min      = opts.Min     or 0
    local max      = opts.Max     or 100
    local initVal  = opts.Value   or min
    local step     = opts.Step    or 1
    local suffix   = opts.Suffix  or ""
    local cb       = opts.Callback

    local value = Utility.Clamp(initVal, min, max)

    local frame = Utility.Create("Frame", {
        Parent           = self._Content,
        BackgroundColor3 = theme.Card,
        BorderSizePixel  = 0,
        Size             = UDim2.new(1, 0, 0, 58),
    }, {
        Utility.Create("UICorner",  { CornerRadius = UDim.new(0, 8) }),
        Utility.Create("UIStroke",  { Color = theme.Border, Thickness = 1 }),
    })

    Utility.Create("TextLabel", {
        Parent           = frame,
        BackgroundTransparency = 1,
        Size             = UDim2.new(1, -90, 0, 20),
        Position         = UDim2.new(0, 14, 0, 8),
        Text             = name,
        TextColor3       = theme.Text,
        TextSize         = 13,
        Font             = Enum.Font.GothamBold,
        TextXAlignment   = Enum.TextXAlignment.Left,
    })

    local valLabel = Utility.Create("TextLabel", {
        Parent           = frame,
        BackgroundTransparency = 1,
        Size             = UDim2.new(0, 74, 0, 22),
        Position         = UDim2.new(1, -86, 0, 7),
        Text             = tostring(value) .. " " .. suffix,
        TextColor3       = theme.TextSub,
        TextSize         = 12,
        Font             = Enum.Font.GothamBold,
        TextXAlignment   = Enum.TextXAlignment.Right,
        BackgroundColor3 = theme.SurfaceAlt,
        BorderSizePixel  = 0,
    }, {
        Utility.Create("UICorner",  { CornerRadius = UDim.new(0, 6) }),
        Utility.Create("UIPadding", { PaddingRight = UDim.new(0, 6) }),
    })

    -- Track
    local track = Utility.Create("Frame", {
        Parent           = frame,
        BackgroundColor3 = theme.SliderTrack,
        BorderSizePixel  = 0,
        Size             = UDim2.new(1, -28, 0, 6),
        Position         = UDim2.new(0, 14, 0, 38),
    }, {
        Utility.Create("UICorner",  { CornerRadius = UDim.new(1, 0) }),
    })

    local fill = Utility.Create("Frame", {
        Parent           = track,
        BackgroundColor3 = theme.SliderFill,
        BorderSizePixel  = 0,
        Size             = UDim2.new((value - min) / (max - min), 0, 1, 0),
    }, {
        Utility.Create("UICorner",  { CornerRadius = UDim.new(1, 0) }),
        Utility.Create("UIGradient", {
            Color    = ColorSequence.new({
                ColorSequenceKeypoint.new(0, theme.AccentGradient1),
                ColorSequenceKeypoint.new(1, theme.AccentGradient2),
            }),
        }),
    })

    local knob = Utility.Create("Frame", {
        Parent           = track,
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel  = 0,
        Size             = UDim2.new(0, 14, 0, 14),
        AnchorPoint      = Vector2.new(0.5, 0.5),
        Position         = UDim2.new((value - min) / (max - min), 0, 0.5, 0),
    }, {
        Utility.Create("UICorner",  { CornerRadius = UDim.new(1, 0) }),
        Utility.Create("UIStroke",  { Color = theme.Accent, Thickness = 2 }),
    })

    local dragging = false

    local function setSlider(alpha)
        alpha = Utility.Clamp(alpha, 0, 1)
        local raw = min + (max - min) * alpha
        local stepped = math.floor(raw / step + 0.5) * step
        value = Utility.Clamp(stepped, min, max)
        local fa = (value - min) / (max - min)
        Utility.Tween(fill,  { Size     = UDim2.new(fa, 0, 1, 0) }, 0.05)
        Utility.Tween(knob,  { Position = UDim2.new(fa, 0, 0.5, 0) }, 0.05)
        valLabel.Text = tostring(Utility.Round(value, 2)) .. " " .. suffix
        if cb then pcall(cb, value) end
    end

    track.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or
           inp.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            local rel   = inp.Position.X - track.AbsolutePosition.X
            setSlider(rel / track.AbsoluteSize.X)
        end
    end)
    track.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or
           inp.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if not dragging then return end
        if inp.UserInputType ~= Enum.UserInputType.MouseMovement and
           inp.UserInputType ~= Enum.UserInputType.Touch then return end
        local rel = inp.Position.X - track.AbsolutePosition.X
        setSlider(rel / track.AbsoluteSize.X)
    end)

    frame.MouseEnter:Connect(function()
        Utility.Tween(frame, { BackgroundColor3 = theme.CardAlt }, 0.12)
    end)
    frame.MouseLeave:Connect(function()
        Utility.Tween(frame, { BackgroundColor3 = theme.Card }, 0.12)
    end)

    local slider = setmetatable({
        _Container = frame,
        _Name      = name,
        _Callback  = cb,
    }, { __index = ElementBase })

    function slider:SetValue(v)
        local alpha = (Utility.Clamp(v, min, max) - min) / (max - min)
        setSlider(alpha)
    end
    function slider:GetValue() return value end

    table.insert(self._Elements, slider)
    return slider
end

function Section:CreateDropdown(opts)
    opts = opts or {}
    local theme    = self._Theme
    local name     = opts.Name    or "Dropdown"
    local items    = opts.Items   or {}
    local initVal  = opts.Value
    local multi    = opts.Multi   or false
    local cb       = opts.Callback

    local selected = multi and {} or initVal
    local isOpen   = false

    local frame = Utility.Create("Frame", {
        Parent           = self._Content,
        BackgroundColor3 = theme.Card,
        BorderSizePixel  = 0,
        Size             = UDim2.new(1, 0, 0, 72),
        ZIndex           = 5,
        ClipsDescendants = false,
    }, {
        Utility.Create("UICorner",  { CornerRadius = UDim.new(0, 8) }),
        Utility.Create("UIStroke",  { Color = theme.Border, Thickness = 1 }),
    })

    Utility.Create("TextLabel", {
        Parent           = frame,
        BackgroundTransparency = 1,
        Size             = UDim2.new(1, -20, 0, 22),
        Position         = UDim2.new(0, 14, 0, 8),
        Text             = name,
        TextColor3       = theme.Text,
        TextSize         = 13,
        Font             = Enum.Font.GothamBold,
        TextXAlignment   = Enum.TextXAlignment.Left,
        ZIndex           = 6,
    })

    -- Button
    local btn = Utility.Create("TextButton", {
        Parent           = frame,
        BackgroundColor3 = theme.InputBg,
        BorderSizePixel  = 0,
        Size             = UDim2.new(1, -28, 0, 32),
        Position         = UDim2.new(0, 14, 0, 32),
        Text             = "",
        AutoButtonColor  = false,
        ZIndex           = 6,
    }, {
        Utility.Create("UICorner",  { CornerRadius = UDim.new(0, 8) }),
        Utility.Create("UIStroke",  { Color = theme.InputBorder, Thickness = 1 }),
    })

    local selLabel = Utility.Create("TextLabel", {
        Parent           = btn,
        BackgroundTransparency = 1,
        Size             = UDim2.new(1, -36, 1, 0),
        Position         = UDim2.new(0, 10, 0, 0),
        TextColor3       = selected and tostring(selected) ~= "" and theme.Text or theme.TextMuted,
        TextSize         = 12,
        Font             = Enum.Font.Gotham,
        TextXAlignment   = Enum.TextXAlignment.Left,
        Text             = (multi and "Select options..." or (selected or "Select...")),
        TextTruncate     = Enum.TextTruncate.AtEnd,
        ZIndex           = 7,
    })

    local arrow = Utility.Create("TextLabel", {
        Parent           = btn,
        BackgroundTransparency = 1,
        Size             = UDim2.new(0, 24, 1, 0),
        Position         = UDim2.new(1, -26, 0, 0),
        Text             = "▾",
        TextColor3       = theme.TextMuted,
        TextSize         = 12,
        Font             = Enum.Font.GothamBold,
        TextXAlignment   = Enum.TextXAlignment.Center,
        ZIndex           = 7,
    })

    -- Dropdown list
    local dropdown = Utility.Create("Frame", {
        Parent           = frame,
        BackgroundColor3 = theme.Surface,
        BorderSizePixel  = 0,
        Size             = UDim2.new(1, -28, 0, 0),
        Position         = UDim2.new(0, 14, 0, 70),
        ZIndex           = 10,
        ClipsDescendants = true,
        Visible          = false,
    }, {
        Utility.Create("UICorner",  { CornerRadius = UDim.new(0, 8) }),
        Utility.Create("UIStroke",  { Color = theme.Border, Thickness = 1 }),
        Utility.Create("UIListLayout", {
            SortOrder   = Enum.SortOrder.LayoutOrder,
            Padding     = UDim.new(0, 2),
        }),
        Utility.Create("UIPadding", {
            PaddingTop    = UDim.new(0, 4),
            PaddingBottom = UDim.new(0, 4),
            PaddingLeft   = UDim.new(0, 4),
            PaddingRight  = UDim.new(0, 4),
        }),
    })

    local function getLabel()
        if multi then
            if #selected == 0 then return "Select options..." end
            return table.concat(selected, ", ")
        end
        return selected or "Select..."
    end

    local function buildItems()
        for _, c in ipairs(dropdown:GetChildren()) do
            if c:IsA("TextButton") then c:Destroy() end
        end
        for i, item in ipairs(items) do
            local isSelected = multi
                and (function() for _, v in ipairs(selected) do if v == item then return true end end return false end)()
                or (selected == item)

            local row = Utility.Create("TextButton", {
                Parent           = dropdown,
                BackgroundColor3 = isSelected and theme.AccentDark or theme.SurfaceAlt,
                BorderSizePixel  = 0,
                Size             = UDim2.new(1, 0, 0, 30),
                Text             = "",
                AutoButtonColor  = false,
                ZIndex           = 11,
                LayoutOrder      = i,
            }, {
                Utility.Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
            })

            Utility.Create("TextLabel", {
                Parent           = row,
                BackgroundTransparency = 1,
                Size             = UDim2.new(1, -8, 1, 0),
                Position         = UDim2.new(0, 8, 0, 0),
                Text             = tostring(item),
                TextColor3       = isSelected and theme.AccentLight or theme.Text,
                TextSize         = 12,
                Font             = isSelected and Enum.Font.GothamBold or Enum.Font.Gotham,
                TextXAlignment   = Enum.TextXAlignment.Left,
                ZIndex           = 12,
            })

            row.MouseEnter:Connect(function()
                if not isSelected then Utility.Tween(row, { BackgroundColor3 = theme.Card }, 0.1) end
            end)
            row.MouseLeave:Connect(function()
                if not isSelected then Utility.Tween(row, { BackgroundColor3 = theme.SurfaceAlt }, 0.1) end
            end)

            row.MouseButton1Click:Connect(function()
                if multi then
                    local found = false
                    for idx, v in ipairs(selected) do
                        if v == item then table.remove(selected, idx); found = true; break end
                    end
                    if not found then table.insert(selected, item) end
                else
                    selected = item
                    isOpen = false
                    Utility.Tween(dropdown, { Size = UDim2.new(1, -28, 0, 0) }, 0.2)
                    task.delay(0.2, function() dropdown.Visible = false end)
                    Utility.Tween(arrow, { Rotation = 0 }, 0.2)
                end
                selLabel.Text = getLabel()
                selLabel.TextColor3 = theme.Text
                buildItems()
                if cb then pcall(cb, selected) end
            end)
        end
    end

    buildItems()

    btn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        if isOpen then
            dropdown.Visible = true
            local h = math.min(#items * 34 + 8, 180)
            Utility.Tween(dropdown, { Size = UDim2.new(1, -28, 0, h) }, 0.25, Enum.EasingStyle.Back)
            Utility.Tween(arrow, { Rotation = 180 }, 0.2)
            frame.Size = UDim2.new(1, 0, 0, 72 + h + 4)
        else
            Utility.Tween(dropdown, { Size = UDim2.new(1, -28, 0, 0) }, 0.2)
            Utility.Tween(arrow, { Rotation = 0 }, 0.2)
            task.delay(0.2, function() dropdown.Visible = false end)
            frame.Size = UDim2.new(1, 0, 0, 72)
        end
    end)

    local dd = setmetatable({
        _Container = frame,
        _Name      = name,
        _Callback  = cb,
    }, { __index = ElementBase })

    function dd:SetItems(newItems)
        items = newItems
        if not multi then selected = nil; selLabel.Text = "Select..." end
        buildItems()
    end
    function dd:GetValue() return selected end
    function dd:SetValue(v)
        selected = v
        selLabel.Text = getLabel()
        buildItems()
    end

    table.insert(self._Elements, dd)
    return dd
end

function Section:CreateTextbox(opts)
    opts = opts or {}
    local theme   = self._Theme
    local name    = opts.Name        or "Textbox"
    local placeholder = opts.Placeholder or "Type here..."
    local initVal = opts.Value       or ""
    local numeric = opts.Numeric     or false
    local clearOnFocus = opts.ClearOnFocus ~= false
    local cb      = opts.Callback

    local frame = Utility.Create("Frame", {
        Parent           = self._Content,
        BackgroundColor3 = theme.Card,
        BorderSizePixel  = 0,
        Size             = UDim2.new(1, 0, 0, 72),
    }, {
        Utility.Create("UICorner",  { CornerRadius = UDim.new(0, 8) }),
        Utility.Create("UIStroke",  { Color = theme.Border, Thickness = 1 }),
    })

    Utility.Create("TextLabel", {
        Parent           = frame,
        BackgroundTransparency = 1,
        Size             = UDim2.new(1, -20, 0, 22),
        Position         = UDim2.new(0, 14, 0, 8),
        Text             = name,
        TextColor3       = theme.Text,
        TextSize         = 13,
        Font             = Enum.Font.GothamBold,
        TextXAlignment   = Enum.TextXAlignment.Left,
    })

    local stroke = Utility.Create("UIStroke", { Color = theme.InputBorder, Thickness = 1 })

    local tb = Utility.Create("TextBox", {
        Parent           = frame,
        BackgroundColor3 = theme.InputBg,
        BorderSizePixel  = 0,
        Size             = UDim2.new(1, -28, 0, 32),
        Position         = UDim2.new(0, 14, 0, 32),
        Text             = initVal,
        PlaceholderText  = placeholder,
        PlaceholderColor3 = theme.TextMuted,
        TextColor3       = theme.Text,
        TextSize         = 12,
        Font             = Enum.Font.Gotham,
        ClearTextOnFocus = clearOnFocus,
    }, {
        Utility.Create("UICorner",  { CornerRadius = UDim.new(0, 8) }),
        stroke,
        Utility.Create("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) }),
    })

    tb.Focused:Connect(function()
        Utility.Tween(stroke, { Color = theme.Accent }, 0.15)
    end)
    tb.FocusLost:Connect(function(enter)
        Utility.Tween(stroke, { Color = theme.InputBorder }, 0.15)
        if numeric then
            local n = tonumber(tb.Text)
            if n then tb.Text = tostring(n)
            else tb.Text = initVal end
        end
        if cb then pcall(cb, tb.Text, enter) end
    end)

    local textbox = setmetatable({
        _Container = frame,
        _Name      = name,
        _Callback  = cb,
    }, { __index = ElementBase })

    function textbox:GetValue() return tb.Text end
    function textbox:SetValue(v) tb.Text = tostring(v) end

    table.insert(self._Elements, textbox)
    return textbox
end

function Section:CreateKeybind(opts)
    opts = opts or {}
    local theme   = self._Theme
    local name    = opts.Name    or "Keybind"
    local initKey = opts.Key     or Enum.KeyCode.Unknown
    local cb      = opts.Callback

    local key      = initKey
    local binding  = false

    local frame = Utility.Create("Frame", {
        Parent           = self._Content,
        BackgroundColor3 = theme.Card,
        BorderSizePixel  = 0,
        Size             = UDim2.new(1, 0, 0, 44),
    }, {
        Utility.Create("UICorner",  { CornerRadius = UDim.new(0, 8) }),
        Utility.Create("UIStroke",  { Color = theme.Border, Thickness = 1 }),
    })

    Utility.Create("TextLabel", {
        Parent           = frame,
        BackgroundTransparency = 1,
        Size             = UDim2.new(1, -120, 1, 0),
        Position         = UDim2.new(0, 14, 0, 0),
        Text             = name,
        TextColor3       = theme.Text,
        TextSize         = 13,
        Font             = Enum.Font.GothamBold,
        TextXAlignment   = Enum.TextXAlignment.Left,
    })

    local keyBtn = Utility.Create("TextButton", {
        Parent           = frame,
        BackgroundColor3 = theme.SurfaceAlt,
        BorderSizePixel  = 0,
        Size             = UDim2.new(0, 90, 0, 28),
        Position         = UDim2.new(1, -104, 0.5, 0),
        AnchorPoint      = Vector2.new(0, 0.5),
        Text             = key == Enum.KeyCode.Unknown and "None" or key.Name,
        TextColor3       = theme.TextSub,
        TextSize         = 11,
        Font             = Enum.Font.GothamBold,
        AutoButtonColor  = false,
    }, {
        Utility.Create("UICorner",  { CornerRadius = UDim.new(0, 6) }),
        Utility.Create("UIStroke",  { Color = theme.Border, Thickness = 1 }),
    })

    keyBtn.MouseButton1Click:Connect(function()
        binding = true
        keyBtn.Text = "..."
        keyBtn.TextColor3 = theme.Accent
    end)

    UserInputService.InputBegan:Connect(function(inp, gpe)
        if not binding then return end
        if inp.UserInputType == Enum.UserInputType.Keyboard then
            binding = false
            key = inp.KeyCode
            keyBtn.Text = key.Name
            keyBtn.TextColor3 = theme.TextSub
            if cb then pcall(cb, key) end
        end
    end)

    -- Key activation
    UserInputService.InputBegan:Connect(function(inp, gpe)
        if gpe then return end
        if inp.UserInputType == Enum.UserInputType.Keyboard and inp.KeyCode == key then
            if opts.OnActivate then pcall(opts.OnActivate) end
        end
    end)

    local kb = setmetatable({
        _Container = frame,
        _Name      = name,
        _Callback  = cb,
    }, { __index = ElementBase })

    function kb:GetKey() return key end
    function kb:SetKey(k) key = k; keyBtn.Text = k.Name end

    table.insert(self._Elements, kb)
    return kb
end

function Section:CreateColorPicker(opts)
    opts = opts or {}
    local theme   = self._Theme
    local name    = opts.Name  or "Color Picker"
    local initCol = opts.Color or Color3.fromRGB(124, 92, 246)
    local cb      = opts.Callback

    local frame = Utility.Create("Frame", {
        Parent           = self._Content,
        BackgroundColor3 = theme.Card,
        BorderSizePixel  = 0,
        Size             = UDim2.new(1, 0, 0, 70),
        ZIndex           = 5,
        ClipsDescendants = false,
    }, {
        Utility.Create("UICorner",  { CornerRadius = UDim.new(0, 8) }),
        Utility.Create("UIStroke",  { Color = theme.Border, Thickness = 1 }),
    })

    Utility.Create("TextLabel", {
        Parent           = frame,
        BackgroundTransparency = 1,
        Size             = UDim2.new(1, -20, 0, 22),
        Position         = UDim2.new(0, 14, 0, 8),
        Text             = name,
        TextColor3       = theme.Text,
        TextSize         = 13,
        Font             = Enum.Font.GothamBold,
        TextXAlignment   = Enum.TextXAlignment.Left,
        ZIndex           = 6,
    })

    local pickerContainer = Utility.Create("Frame", {
        Parent           = frame,
        BackgroundTransparency = 1,
        Size             = UDim2.new(1, -28, 0, 36),
        Position         = UDim2.new(0, 14, 0, 30),
        ZIndex           = 6,
    })

    local _, getColor = CreateColorPicker(pickerContainer, initCol, function(c)
        if cb then pcall(cb, c) end
    end, theme)

    local cp = setmetatable({
        _Container = frame,
        _Name      = name,
        _Callback  = cb,
    }, { __index = ElementBase })

    function cp:GetColor() return getColor() end

    table.insert(self._Elements, cp)
    return cp
end

function Section:CreateLabel(opts)
    opts = opts or {}
    local theme = self._Theme
    local text  = opts.Text or "Label"

    local label = Utility.Create("TextLabel", {
        Parent           = self._Content,
        BackgroundTransparency = 1,
        Size             = UDim2.new(1, 0, 0, 24),
        Text             = text,
        TextColor3       = theme.TextSub,
        TextSize         = 12,
        Font             = Enum.Font.Gotham,
        TextXAlignment   = Enum.TextXAlignment.Left,
    })

    Utility.Create("UIPadding", {
        Parent     = label,
        PaddingLeft = UDim.new(0, 4),
    })

    local lbl = setmetatable({ _Container = label, _Name = text }, { __index = ElementBase })
    function lbl:SetText(t) label.Text = t end
    table.insert(self._Elements, lbl)
    return lbl
end

function Section:CreateParagraph(opts)
    opts = opts or {}
    local theme   = self._Theme
    local title   = opts.Title   or ""
    local content = opts.Content or ""

    local frame = Utility.Create("Frame", {
        Parent           = self._Content,
        BackgroundColor3 = theme.Card,
        BorderSizePixel  = 0,
        AutomaticSize    = Enum.AutomaticSize.Y,
    }, {
        Utility.Create("UICorner",  { CornerRadius = UDim.new(0, 8) }),
        Utility.Create("UIStroke",  { Color = theme.Border, Thickness = 1 }),
        Utility.Create("UIPadding", {
            PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10),
            PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14),
        }),
    })

    if title ~= "" then
        Utility.Create("TextLabel", {
            Parent           = frame,
            BackgroundTransparency = 1,
            Size             = UDim2.new(1, 0, 0, 18),
            Text             = title,
            TextColor3       = theme.Text,
            TextSize         = 13,
            Font             = Enum.Font.GothamBold,
            TextXAlignment   = Enum.TextXAlignment.Left,
        })
    end

    local bodyLabel = Utility.Create("TextLabel", {
        Parent           = frame,
        BackgroundTransparency = 1,
        Size             = UDim2.new(1, 0, 0, 0),
        AutomaticSize    = Enum.AutomaticSize.Y,
        Position         = UDim2.new(0, 0, 0, title ~= "" and 22 or 0),
        Text             = content,
        TextColor3       = theme.TextSub,
        TextSize          = 12,
        Font             = Enum.Font.Gotham,
        TextXAlignment   = Enum.TextXAlignment.Left,
        TextWrapped      = true,
    })

    local p = setmetatable({ _Container = frame }, { __index = ElementBase })
    function p:SetContent(c) bodyLabel.Text = c end
    table.insert(self._Elements, p)
    return p
end

function Section:CreateDivider(opts)
    opts = opts or {}
    local theme = self._Theme
    local text  = opts.Text

    local frame = Utility.Create("Frame", {
        Parent           = self._Content,
        BackgroundTransparency = 1,
        Size             = UDim2.new(1, 0, 0, 20),
    })

    Utility.Create("Frame", {
        Parent           = frame,
        BackgroundColor3 = theme.Border,
        BorderSizePixel  = 0,
        Size             = text and UDim2.new(0.4, 0, 0, 1) or UDim2.new(1, 0, 0, 1),
        Position         = UDim2.new(0, 0, 0.5, 0),
        AnchorPoint      = Vector2.new(0, 0.5),
    }, {
        Utility.Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
    })

    if text then
        Utility.Create("TextLabel", {
            Parent           = frame,
            BackgroundTransparency = 1,
            Size             = UDim2.new(0.2, 0, 1, 0),
            Position         = UDim2.new(0.4, 0, 0, 0),
            Text             = text,
            TextColor3       = theme.TextMuted,
            TextSize         = 10,
            Font             = Enum.Font.GothamBold,
            TextXAlignment   = Enum.TextXAlignment.Center,
        })
        Utility.Create("Frame", {
            Parent           = frame,
            BackgroundColor3 = theme.Border,
            BorderSizePixel  = 0,
            Size             = UDim2.new(0.4, 0, 0, 1),
            Position         = UDim2.new(0.6, 0, 0.5, 0),
            AnchorPoint      = Vector2.new(0, 0.5),
        }, {
            Utility.Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
        })
    end

    local d = setmetatable({ _Container = frame }, { __index = ElementBase })
    table.insert(self._Elements, d)
    return d
end

function Section:CreateProgressBar(opts)
    opts = opts or {}
    local theme   = self._Theme
    local name    = opts.Name  or "Progress"
    local initVal = opts.Value or 0
    local max     = opts.Max   or 100
    local suffix  = opts.Suffix or "%"

    local value = Utility.Clamp(initVal, 0, max)

    local frame = Utility.Create("Frame", {
        Parent           = self._Content,
        BackgroundColor3 = theme.Card,
        BorderSizePixel  = 0,
        Size             = UDim2.new(1, 0, 0, 50),
    }, {
        Utility.Create("UICorner",  { CornerRadius = UDim.new(0, 8) }),
        Utility.Create("UIStroke",  { Color = theme.Border, Thickness = 1 }),
    })

    Utility.Create("TextLabel", {
        Parent           = frame,
        BackgroundTransparency = 1,
        Size             = UDim2.new(1, -60, 0, 20),
        Position         = UDim2.new(0, 14, 0, 6),
        Text             = name,
        TextColor3       = theme.Text,
        TextSize         = 12,
        Font             = Enum.Font.GothamBold,
        TextXAlignment   = Enum.TextXAlignment.Left,
    })

    local pctLabel = Utility.Create("TextLabel", {
        Parent           = frame,
        BackgroundTransparency = 1,
        Size             = UDim2.new(0, 50, 0, 20),
        Position         = UDim2.new(1, -60, 0, 6),
        Text             = tostring(Utility.Round(value / max * 100)) .. suffix,
        TextColor3       = theme.TextSub,
        TextSize         = 12,
        Font             = Enum.Font.GothamBold,
        TextXAlignment   = Enum.TextXAlignment.Right,
    })

    local track = Utility.Create("Frame", {
        Parent           = frame,
        BackgroundColor3 = theme.SliderTrack,
        BorderSizePixel  = 0,
        Size             = UDim2.new(1, -28, 0, 8),
        Position         = UDim2.new(0, 14, 0, 30),
    }, {
        Utility.Create("UICorner",  { CornerRadius = UDim.new(1, 0) }),
    })

    local fill = Utility.Create("Frame", {
        Parent           = track,
        BackgroundColor3 = theme.SliderFill,
        BorderSizePixel  = 0,
        Size             = UDim2.new(value / max, 0, 1, 0),
    }, {
        Utility.Create("UICorner",  { CornerRadius = UDim.new(1, 0) }),
        Utility.Create("UIGradient", {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, theme.AccentGradient1),
                ColorSequenceKeypoint.new(1, theme.AccentGradient2),
            }),
        }),
    })

    local pb = setmetatable({
        _Container = frame,
        _Name      = name,
    }, { __index = ElementBase })

    function pb:SetValue(v)
        value = Utility.Clamp(v, 0, max)
        Utility.Tween(fill, { Size = UDim2.new(value / max, 0, 1, 0) }, 0.3)
        pctLabel.Text = tostring(Utility.Round(value / max * 100)) .. suffix
    end
    function pb:GetValue() return value end

    table.insert(self._Elements, pb)
    return pb
end

function Section:CreateSearchBox(opts)
    opts = opts or {}
    local theme   = self._Theme
    local placeholder = opts.Placeholder or "Search..."
    local cb      = opts.Callback

    local frame = Utility.Create("Frame", {
        Parent           = self._Content,
        BackgroundColor3 = theme.InputBg,
        BorderSizePixel  = 0,
        Size             = UDim2.new(1, 0, 0, 36),
    }, {
        Utility.Create("UICorner",  { CornerRadius = UDim.new(0, 8) }),
        Utility.Create("UIStroke",  { Color = theme.InputBorder, Thickness = 1 }),
    })

    local stroke = frame:FindFirstChildOfClass("UIStroke")

    Utility.Create("TextLabel", {
        Parent           = frame,
        BackgroundTransparency = 1,
        Size             = UDim2.new(0, 24, 1, 0),
        Position         = UDim2.new(0, 8, 0, 0),
        Text             = "🔍",
        TextColor3       = theme.TextMuted,
        TextSize         = 14,
        Font             = Enum.Font.Gotham,
        TextXAlignment   = Enum.TextXAlignment.Center,
    })

    local tb = Utility.Create("TextBox", {
        Parent           = frame,
        BackgroundTransparency = 1,
        Size             = UDim2.new(1, -40, 1, 0),
        Position         = UDim2.new(0, 34, 0, 0),
        PlaceholderText  = placeholder,
        PlaceholderColor3 = theme.TextMuted,
        TextColor3       = theme.Text,
        TextSize         = 12,
        Font             = Enum.Font.Gotham,
        ClearTextOnFocus = false,
    })

    tb.Focused:Connect(function() Utility.Tween(stroke, { Color = theme.Accent }, 0.15) end)
    tb.FocusLost:Connect(function() Utility.Tween(stroke, { Color = theme.InputBorder }, 0.15) end)

    tb:GetPropertyChangedSignal("Text"):Connect(function()
        if cb then pcall(cb, tb.Text) end
    end)

    local sb = setmetatable({ _Container = frame }, { __index = ElementBase })
    function sb:GetValue() return tb.Text end
    function sb:SetValue(v) tb.Text = v end
    table.insert(self._Elements, sb)
    return sb
end

function Section:CreateImage(opts)
    opts = opts or {}
    local theme  = self._Theme
    local id     = opts.Image or ""
    local size   = opts.Size  or 80

    local frame = Utility.Create("Frame", {
        Parent           = self._Content,
        BackgroundColor3 = theme.Card,
        BorderSizePixel  = 0,
        Size             = UDim2.new(1, 0, 0, size + 16),
    }, {
        Utility.Create("UICorner",  { CornerRadius = UDim.new(0, 8) }),
    })

    Utility.Create("ImageLabel", {
        Parent           = frame,
        BackgroundTransparency = 1,
        Size             = UDim2.new(0, size, 0, size),
        Position         = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint      = Vector2.new(0.5, 0.5),
        Image            = id,
        ScaleType        = Enum.ScaleType.Fit,
    }, {
        Utility.Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
    })

    local img = setmetatable({ _Container = frame }, { __index = ElementBase })
    table.insert(self._Elements, img)
    return img
end

function Section:CreateComboBox(opts)
    -- Alias to Dropdown
    return self:CreateDropdown(opts)
end

function Section:CreateMultiDropdown(opts)
    opts = opts or {}
    opts.Multi = true
    return self:CreateDropdown(opts)
end

-- ─────────────────────────────────────────────
--  TAB CLASS
-- ─────────────────────────────────────────────
local Tab = {}
Tab.__index = Tab

function Tab.new(opts, theme, contentParent)
    local self = setmetatable({}, Tab)
    self._Name     = opts.Name or "Tab"
    self._Icon     = opts.Icon or ""
    self._Theme    = theme
    self._Sections = {}

    -- Content scroll frame
    self._Content = Utility.Create("ScrollingFrame", {
        Parent              = contentParent,
        BackgroundTransparency = 1,
        BorderSizePixel     = 0,
        Size                = UDim2.new(1, 0, 1, 0),
        ScrollBarThickness  = 3,
        ScrollBarImageColor3 = theme.Accent,
        CanvasSize          = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible             = false,
    }, {
        Utility.Create("UIListLayout", {
            SortOrder   = Enum.SortOrder.LayoutOrder,
            Padding     = UDim.new(0, 10),
            FillDirection = Enum.FillDirection.Vertical,
        }),
        Utility.Create("UIPadding", {
            PaddingTop    = UDim.new(0, 10),
            PaddingBottom = UDim.new(0, 16),
            PaddingLeft   = UDim.new(0, 12),
            PaddingRight  = UDim.new(0, 12),
        }),
    })

    return self
end

function Tab:CreateSection(opts)
    local s = Section.new(opts, self._Theme, self._Content)
    table.insert(self._Sections, s)
    return s
end

function Tab:_Select()
    self._Content.Visible = true
    Utility.Tween(self._Content, { BackgroundTransparency = 1 }, 0.15)
end

function Tab:_Deselect()
    self._Content.Visible = false
end

-- ─────────────────────────────────────────────
--  MOBILE FLOATING BUTTON
-- ─────────────────────────────────────────────
local function CreateFloatingButton(onToggle, theme)
    local BTN_SIZE   = 58   -- ขนาดปุ่ม (px)
    local EDGE_PAD   = 14   -- ระยะห่างขอบตอน snap

    local gui = Utility.Create("ScreenGui", {
        Name           = "NexusUI_FloatBtn",
        ResetOnSpawn   = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder   = 998,
        IgnoreGuiInset = true,
    })
    local gOk = pcall(function() gui.Parent = CoreGui end)
    if not gOk then gui.Parent = LocalPlayer:FindFirstChildOfClass("PlayerGui") end

    -- วงแสง (glow ring)
    local glow = Utility.Create("Frame", {
        Parent           = gui,
        BackgroundColor3 = theme.Accent,
        BackgroundTransparency = 0.7,
        BorderSizePixel  = 0,
        Size             = UDim2.new(0, BTN_SIZE + 18, 0, BTN_SIZE + 18),
        Position         = UDim2.new(1, -(BTN_SIZE + 18 + EDGE_PAD), 0.5, -(BTN_SIZE + 18) / 2),
        ZIndex           = 9,
    }, {
        Utility.Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
    })

    local btn = Utility.Create("TextButton", {
        Parent           = gui,
        BackgroundColor3 = theme.Accent,
        BorderSizePixel  = 0,
        Size             = UDim2.new(0, BTN_SIZE, 0, BTN_SIZE),
        Position         = UDim2.new(1, -(BTN_SIZE + EDGE_PAD), 0.5, -BTN_SIZE / 2),
        Text             = "≡",
        TextColor3       = Color3.new(1, 1, 1),
        TextSize         = 24,
        Font             = Enum.Font.GothamBold,
        ZIndex           = 10,
        AutoButtonColor  = false,
    }, {
        Utility.Create("UICorner",  { CornerRadius = UDim.new(1, 0) }),
        Utility.Create("UIGradient", {
            Color    = ColorSequence.new({
                ColorSequenceKeypoint.new(0, theme.AccentGradient1),
                ColorSequenceKeypoint.new(1, theme.AccentGradient2),
            }),
            Rotation = 135,
        }),
        Utility.Create("UIStroke", {
            Color        = theme.AccentLight,
            Thickness    = 2,
            Transparency = 0.4,
        }),
    })

    -- ─── DRAG (ปุ่มลอยลากได้อิสระ) ───
    local btnDragging = false
    local btnDragStart = Vector2.new()
    local btnStartPos  = UDim2.new()
    local moved        = false   -- แยก click กับ drag

    local function syncGlow()
        -- กลอว์ตามปุ่มเสมอ
        glow.Position = UDim2.new(
            btn.Position.X.Scale,
            btn.Position.X.Offset - 9,
            btn.Position.Y.Scale,
            btn.Position.Y.Offset - 9
        )
    end

    UserInputService.InputBegan:Connect(function(inp)
        if inp.UserInputType ~= Enum.UserInputType.MouseButton1 and
           inp.UserInputType ~= Enum.UserInputType.Touch then return end
        local sp  = Vector2.new(inp.Position.X, inp.Position.Y)
        local ap  = btn.AbsolutePosition
        local as  = btn.AbsoluteSize
        if sp.X < ap.X or sp.X > ap.X + as.X or
           sp.Y < ap.Y or sp.Y > ap.Y + as.Y then return end
        btnDragging = true
        moved       = false
        btnDragStart = sp
        btnStartPos  = btn.Position
    end)

    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType ~= Enum.UserInputType.MouseButton1 and
           inp.UserInputType ~= Enum.UserInputType.Touch then return end
        if not btnDragging then return end
        btnDragging = false

        -- Snap to nearest edge
        local vp    = Utility.GetScreenSize()
        local cx    = btn.AbsolutePosition.X + btn.AbsoluteSize.X / 2
        local finalX, finalY

        -- snap X
        if cx < vp.X / 2 then
            finalX = EDGE_PAD
        else
            finalX = vp.X - BTN_SIZE - EDGE_PAD
        end
        finalY = Utility.Clamp(btn.Position.Y.Offset, EDGE_PAD, vp.Y - BTN_SIZE - EDGE_PAD)

        Utility.Tween(btn,  { Position = UDim2.new(0, finalX, 0, finalY) }, 0.25, Enum.EasingStyle.Back)
        Utility.Tween(glow, { Position = UDim2.new(0, finalX - 9, 0, finalY - 9) }, 0.25, Enum.EasingStyle.Back)
    end)

    UserInputService.InputChanged:Connect(function(inp)
        if not btnDragging then return end
        if inp.UserInputType ~= Enum.UserInputType.MouseMovement and
           inp.UserInputType ~= Enum.UserInputType.Touch then return end

        local cur   = Vector2.new(inp.Position.X, inp.Position.Y)
        local delta = cur - btnDragStart
        if delta.Magnitude > 4 then moved = true end

        local vp = Utility.GetScreenSize()
        local newX = Utility.Clamp(btnStartPos.X.Offset + delta.X, 0, vp.X - BTN_SIZE)
        local newY = Utility.Clamp(btnStartPos.Y.Offset + delta.Y, 0, vp.Y - BTN_SIZE)
        btn.Position  = UDim2.new(0, newX, 0, newY)
        glow.Position = UDim2.new(0, newX - 9, 0, newY - 9)
    end)

    -- ─── PULSE ANIMATION ───
    local pulseRunning = true
    local function pulse()
        if not pulseRunning then return end
        local baseSize = UDim2.new(0, BTN_SIZE + 6, 0, BTN_SIZE + 6)
        local normSize = UDim2.new(0, BTN_SIZE,     0, BTN_SIZE)
        Utility.Tween(btn, { Size = baseSize }, 0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, function()
            if not pulseRunning then btn.Size = normSize; return end
            Utility.Tween(btn, { Size = normSize }, 0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, function()
                task.delay(1.5, pulse)
            end)
        end)
    end
    task.delay(2, pulse)

    -- หยุด pulse ขณะลาก
    UserInputService.InputBegan:Connect(function(inp)
        if inp.UserInputType ~= Enum.UserInputType.MouseButton1 and
           inp.UserInputType ~= Enum.UserInputType.Touch then return end
        pulseRunning = false
        btn.Size = UDim2.new(0, BTN_SIZE, 0, BTN_SIZE)
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType ~= Enum.UserInputType.MouseButton1 and
           inp.UserInputType ~= Enum.UserInputType.Touch then return end
        task.delay(0.5, function()
            pulseRunning = true
            pulse()
        end)
    end)

    -- ─── CLICK (เปิด/ปิด UI) ───
    btn.MouseButton1Up:Connect(function()
        if not moved then
            if onToggle then onToggle() end
            -- Feedback animation
            Utility.Tween(btn, { Size = UDim2.new(0, BTN_SIZE - 8, 0, BTN_SIZE - 8) }, 0.08, nil, nil, function()
                Utility.Tween(btn, { Size = UDim2.new(0, BTN_SIZE, 0, BTN_SIZE) }, 0.15, Enum.EasingStyle.Back)
            end)
        end
    end)

    -- Double-tap สำหรับ touch
    local lastTap = 0
    btn.InputBegan:Connect(function(inp)
        if inp.UserInputType ~= Enum.UserInputType.Touch then return end
        local now = tick()
        if now - lastTap < 0.35 then
            if onToggle then onToggle() end
        end
        lastTap = now
    end)

    return gui, btn
end

-- ─────────────────────────────────────────────
--  WINDOW CLASS
-- ─────────────────────────────────────────────
local Window = {}
Window.__index = Window

function Window.new(opts, theme, library)
    local self = setmetatable({}, Window)
    self._Opts     = opts or {}
    self._Theme    = theme
    self._Library  = library
    self._Tabs     = {}
    self._ActiveTab = nil
    self._Visible  = true
    self._Minimized = false
    self._Connections = {}

    local title    = opts.Title    or "NexusUI"
    local subtitle = opts.Subtitle or ""
    local version  = opts.Version  or VERSION
    local logo     = opts.Logo     or ""
    local watermark = opts.Watermark ~= false
    local showFPS  = opts.FPS      ~= false
    local showTime = opts.Time     ~= false
    local configName = opts.ConfigName or "default"

    -- ScreenGui
    local gui = Utility.Create("ScreenGui", {
        Name           = "NexusUI_" .. title,
        ResetOnSpawn   = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder   = 100,
        IgnoreGuiInset = true,
    })
    local gOk = pcall(function() gui.Parent = CoreGui end)
    if not gOk then gui.Parent = LocalPlayer:FindFirstChildOfClass("PlayerGui") end
    self._Gui = gui

    -- UIScale
    local uiScale = Utility.Create("UIScale", {
        Parent = gui,
        Scale  = Utility.GetScale(),
    })
    self._UIScale = uiScale

    -- Main window frame — วางกลางจอ (หน้าต่างลอย ลากได้)
    local vp = Utility.GetScreenSize()
    local winW, winH = 800, 540
    local startX = math.max(0, vp.X / 2 - winW / 2)
    local startY = math.max(0, vp.Y / 2 - winH / 2)

    local window = Utility.Create("Frame", {
        Parent           = gui,
        BackgroundColor3 = theme.Background,
        BorderSizePixel  = 0,
        Size             = UDim2.new(0, 800, 0, 540),
        Position         = UDim2.new(0, startX, 0, startY),
        ClipsDescendants = false,
    }, {
        Utility.Create("UICorner",  { CornerRadius = UDim.new(0, 14) }),
        Utility.Create("UIStroke",  {
            Color     = theme.Border,
            Thickness = 1.5,
        }),
    })
    self._Window = window

    -- Drop shadow
    Utility.Create("ImageLabel", {
        Parent           = window,
        BackgroundTransparency = 1,
        Size             = UDim2.new(1, 60, 1, 60),
        Position         = UDim2.new(0, -30, 0, -30),
        ZIndex           = 0,
        Image            = "rbxassetid://6014261993",
        ImageColor3      = Color3.new(0, 0, 0),
        ImageTransparency = 0.5,
        ScaleType        = Enum.ScaleType.Slice,
        SliceCenter      = Rect.new(49, 49, 450, 450),
    })

    -- ─── TITLEBAR ───
    local titlebar = Utility.Create("Frame", {
        Parent           = window,
        BackgroundColor3 = theme.Surface,
        BorderSizePixel  = 0,
        Size             = UDim2.new(1, 0, 0, 52),
    }, {
        Utility.Create("UICorner",  { CornerRadius = UDim.new(0, 14) }),
    })
    self._Titlebar = titlebar

    -- Round only top corners trick: cover bottom corners
    Utility.Create("Frame", {
        Parent           = titlebar,
        BackgroundColor3 = theme.Surface,
        BorderSizePixel  = 0,
        Size             = UDim2.new(1, 0, 0, 14),
        Position         = UDim2.new(0, 0, 1, -14),
    })

    -- Logo
    if logo ~= "" then
        Utility.Create("ImageLabel", {
            Parent           = titlebar,
            BackgroundColor3 = theme.Accent,
            BorderSizePixel  = 0,
            Size             = UDim2.new(0, 28, 0, 28),
            Position         = UDim2.new(0, 12, 0.5, 0),
            AnchorPoint      = Vector2.new(0, 0.5),
            Image            = logo,
        }, {
            Utility.Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
        })
    else
        -- Default logo box
        Utility.Create("Frame", {
            Parent           = titlebar,
            BackgroundColor3 = theme.Accent,
            BorderSizePixel  = 0,
            Size             = UDim2.new(0, 28, 0, 28),
            Position         = UDim2.new(0, 12, 0.5, 0),
            AnchorPoint      = Vector2.new(0, 0.5),
        }, {
            Utility.Create("UICorner",  { CornerRadius = UDim.new(0, 8) }),
            Utility.Create("UIGradient", {
                Color    = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, theme.AccentGradient1),
                    ColorSequenceKeypoint.new(1, theme.AccentGradient2),
                }),
                Rotation = 135,
            }),
            Utility.Create("TextLabel", {
                BackgroundTransparency = 1,
                Size       = UDim2.new(1, 0, 1, 0),
                Text       = ">_",
                TextColor3 = Color3.new(1, 1, 1),
                TextSize   = 12,
                Font       = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Center,
            }),
        })
    end

    -- Title label
    local titleLabel = Utility.Create("TextLabel", {
        Parent           = titlebar,
        BackgroundTransparency = 1,
        Size             = UDim2.new(0, 200, 0, 28),
        Position         = UDim2.new(0, 48, 0.5, 0),
        AnchorPoint      = Vector2.new(0, 0.5),
        Text             = title .. " ",
        TextColor3       = theme.Text,
        TextSize         = 15,
        Font             = Enum.Font.GothamBold,
        TextXAlignment   = Enum.TextXAlignment.Left,
    })

    Utility.Create("TextLabel", {
        Parent           = titleLabel,
        BackgroundTransparency = 1,
        Size             = UDim2.new(0, 60, 1, 0),
        Position         = UDim2.new(1, 0, 0, 0),
        Text             = "v" .. version,
        TextColor3       = theme.TextMuted,
        TextSize         = 11,
        Font             = Enum.Font.Code,
        TextXAlignment   = Enum.TextXAlignment.Left,
    })

    -- Subtitle
    if subtitle ~= "" then
        Utility.Create("TextLabel", {
            Parent           = titlebar,
            BackgroundTransparency = 1,
            Size             = UDim2.new(0, 200, 0, 16),
            Position         = UDim2.new(0, 48, 1, -20),
            Text             = subtitle,
            TextColor3       = theme.TextMuted,
            TextSize         = 10,
            Font             = Enum.Font.Gotham,
            TextXAlignment   = Enum.TextXAlignment.Left,
        })
    end

    -- Info bar (top-right of titlebar)
    local infoBar = Utility.Create("Frame", {
        Parent           = titlebar,
        BackgroundTransparency = 1,
        Size             = UDim2.new(0, 200, 0, 24),
        Position         = UDim2.new(1, -300, 0.5, 0),
        AnchorPoint      = Vector2.new(0, 0.5),
    }, {
        Utility.Create("UIListLayout", {
            FillDirection   = Enum.FillDirection.Horizontal,
            SortOrder       = Enum.SortOrder.LayoutOrder,
            Padding         = UDim.new(0, 8),
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
        }),
    })

    -- FPS display
    local fpsLabel
    if showFPS then
        fpsLabel = Utility.Create("TextLabel", {
            Parent           = infoBar,
            BackgroundColor3 = theme.SurfaceAlt,
            BorderSizePixel  = 0,
            Size             = UDim2.new(0, 52, 0, 22),
            Text             = "60 FPS",
            TextColor3       = theme.Success,
            TextSize         = 10,
            Font             = Enum.Font.GothamBold,
            TextXAlignment   = Enum.TextXAlignment.Center,
            LayoutOrder      = 1,
        }, {
            Utility.Create("UICorner",  { CornerRadius = UDim.new(0, 5) }),
        })
    end

    -- Time display
    local timeLabel
    if showTime then
        timeLabel = Utility.Create("TextLabel", {
            Parent           = infoBar,
            BackgroundColor3 = theme.SurfaceAlt,
            BorderSizePixel  = 0,
            Size             = UDim2.new(0, 58, 0, 22),
            Text             = "00:00",
            TextColor3       = theme.TextSub,
            TextSize         = 10,
            Font             = Enum.Font.Code,
            TextXAlignment   = Enum.TextXAlignment.Center,
            LayoutOrder      = 2,
        }, {
            Utility.Create("UICorner",  { CornerRadius = UDim.new(0, 5) }),
        })
    end

    -- Titlebar buttons
    local btnFrame = Utility.Create("Frame", {
        Parent           = titlebar,
        BackgroundTransparency = 1,
        Size             = UDim2.new(0, 80, 0, 28),
        Position         = UDim2.new(1, -92, 0.5, 0),
        AnchorPoint      = Vector2.new(0, 0.5),
    }, {
        Utility.Create("UIListLayout", {
            FillDirection  = Enum.FillDirection.Horizontal,
            SortOrder      = Enum.SortOrder.LayoutOrder,
            Padding        = UDim.new(0, 6),
            VerticalAlignment = Enum.VerticalAlignment.Center,
        }),
    })

    local function mkBtn(color, txt, order)
        return Utility.Create("TextButton", {
            Parent           = btnFrame,
            BackgroundColor3 = color,
            BorderSizePixel  = 0,
            Size             = UDim2.new(0, 14, 0, 14),
            Text             = "",
            AutoButtonColor  = false,
            LayoutOrder      = order,
        }, {
            Utility.Create("UICorner",  { CornerRadius = UDim.new(1, 0) }),
        })
    end

    local minBtn   = mkBtn(theme.Warning, "—", 1)
    local maxBtn   = mkBtn(theme.Success, "□", 2)
    local closeBtn = mkBtn(theme.Error,   "×", 3)

    -- ─── BODY ───
    local body = Utility.Create("Frame", {
        Parent           = window,
        BackgroundTransparency = 1,
        BorderSizePixel  = 0,
        Size             = UDim2.new(1, 0, 1, -52),
        Position         = UDim2.new(0, 0, 0, 52),
    })
    self._Body = body

    -- ─── SIDEBAR ───
    local sidebarWidth = 170
    local sidebar = Utility.Create("Frame", {
        Parent           = body,
        BackgroundColor3 = theme.Sidebar,
        BorderSizePixel  = 0,
        Size             = UDim2.new(0, sidebarWidth, 1, 0),
    }, {
        Utility.Create("UICorner",  { CornerRadius = UDim.new(0, 0) }),
    })
    self._Sidebar = sidebar

    -- Round bottom-left corner
    Utility.Create("Frame", {
        Parent           = sidebar,
        BackgroundColor3 = theme.Sidebar,
        BorderSizePixel  = 0,
        Size             = UDim2.new(0, 14, 1, 0),
        Position         = UDim2.new(1, -14, 0, 0),
    })

    local tabList = Utility.Create("Frame", {
        Parent        = sidebar,
        BackgroundTransparency = 1,
        Size          = UDim2.new(1, 0, 1, -60),
        Position      = UDim2.new(0, 0, 0, 10),
        ClipsDescendants = true,
    }, {
        Utility.Create("UIListLayout", {
            SortOrder   = Enum.SortOrder.LayoutOrder,
            Padding     = UDim.new(0, 3),
            FillDirection = Enum.FillDirection.Vertical,
        }),
        Utility.Create("UIPadding", {
            PaddingLeft  = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
        }),
    })
    self._TabList = tabList

    -- Status bar
    local statusBar = Utility.Create("Frame", {
        Parent           = sidebar,
        BackgroundTransparency = 1,
        Size             = UDim2.new(1, 0, 0, 50),
        Position         = UDim2.new(0, 0, 1, -50),
    })

    Utility.Create("TextLabel", {
        Parent           = statusBar,
        BackgroundTransparency = 1,
        Size             = UDim2.new(1, 0, 0, 14),
        Position         = UDim2.new(0, 12, 0, 6),
        Text             = "STATUS:",
        TextColor3       = theme.TextMuted,
        TextSize          = 9,
        Font             = Enum.Font.GothamBold,
        TextXAlignment   = Enum.TextXAlignment.Left,
    })

    Utility.Create("TextLabel", {
        Parent           = statusBar,
        BackgroundTransparency = 1,
        Size             = UDim2.new(1, 0, 0, 14),
        Position         = UDim2.new(0, 12, 0, 22),
        Text             = "UNDETECTED",
        TextColor3       = theme.Success,
        TextSize          = 10,
        Font             = Enum.Font.GothamBold,
        TextXAlignment   = Enum.TextXAlignment.Left,
    })

    -- Watermark
    if watermark then
        Utility.Create("TextLabel", {
            Parent           = statusBar,
            BackgroundTransparency = 1,
            Size             = UDim2.new(1, 0, 0, 14),
            Position         = UDim2.new(0, 12, 0, 36),
            Text             = "NexusUI v" .. VERSION,
            TextColor3       = theme.TextMuted,
            TextSize         = 9,
            Font             = Enum.Font.Code,
            TextXAlignment   = Enum.TextXAlignment.Left,
        })
    end

    -- ─── CONTENT AREA ───
    local content = Utility.Create("Frame", {
        Parent           = body,
        BackgroundColor3 = theme.Background,
        BorderSizePixel  = 0,
        Size             = UDim2.new(1, -sidebarWidth, 1, 0),
        Position         = UDim2.new(0, sidebarWidth, 0, 0),
        ClipsDescendants = true,
    }, {
        Utility.Create("UICorner",  { CornerRadius = UDim.new(0, 14) }),
    })

    -- Round only bottom-right corner
    Utility.Create("Frame", {
        Parent           = content,
        BackgroundColor3 = theme.Background,
        BorderSizePixel  = 0,
        Size             = UDim2.new(0, 14, 0.5, 0),
        Position         = UDim2.new(0, 0, 0, 0),
    })

    self._Content = content

    -- ─── DRAGGING ───
    Utility.MakeDraggable(window, titlebar, nil, true)

    -- ─── TITLEBAR BUTTON ACTIONS ───
    closeBtn.MouseButton1Click:Connect(function()
        self:Close()
    end)

    minBtn.MouseButton1Click:Connect(function()
        self:ToggleMinimize()
    end)

    maxBtn.MouseButton1Click:Connect(function()
        self:ToggleMaximize()
    end)

    -- ─── INFO UPDATE LOOP ───
    local infoConn = RunService.RenderStepped:Connect(function()
        if fpsLabel then
            local fps = library._FPS
            fpsLabel.Text = fps .. " FPS"
            if fps >= 55 then fpsLabel.TextColor3 = theme.Success
            elseif fps >= 30 then fpsLabel.TextColor3 = theme.Warning
            else fpsLabel.TextColor3 = theme.Error end
        end
        if timeLabel then
            local t = os.date("*t")
            timeLabel.Text = string.format("%02d:%02d", t.hour, t.min)
        end
    end)
    table.insert(self._Connections, infoConn)

    -- ─── UISCALE UPDATE ───
    local scaleConn = Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
        uiScale.Scale = Utility.GetScale()
    end)
    table.insert(self._Connections, scaleConn)

    -- ─── MOBILE FLOATING BUTTON (สร้างเสมอ ทุก platform) ───
    -- ปุ่มลอยลากได้ กดเพื่อเปิด/ปิด UI
    do
        local floatGui, floatBtn = CreateFloatingButton(function()
            self:Toggle()
        end, theme)
        self._FloatGui = floatGui
        self._FloatBtn = floatBtn
    end

    -- ─── USER INFO ───
    if opts.UserInfo then
        local userName = LocalPlayer.DisplayName or LocalPlayer.Name
        Utility.Create("TextLabel", {
            Parent           = titlebar,
            BackgroundTransparency = 1,
            Size             = UDim2.new(0, 120, 0, 18),
            Position         = UDim2.new(0, 48, 1, -22),
            Text             = "👤 " .. userName,
            TextColor3       = theme.TextMuted,
            TextSize         = 10,
            Font             = Enum.Font.Gotham,
            TextXAlignment   = Enum.TextXAlignment.Left,
        })
    end

    -- Executor name
    if opts.ExecutorName ~= false then
        Utility.Create("TextLabel", {
            Parent           = infoBar,
            BackgroundColor3 = theme.SurfaceAlt,
            BorderSizePixel  = 0,
            Size             = UDim2.new(0, 72, 0, 22),
            Text             = EXECUTOR,
            TextColor3       = theme.Accent,
            TextSize         = 10,
            Font             = Enum.Font.GothamBold,
            TextXAlignment   = Enum.TextXAlignment.Center,
            LayoutOrder      = 0,
        }, {
            Utility.Create("UICorner",  { CornerRadius = UDim.new(0, 5) }),
        })
    end

    -- Animate in
    window.Size     = UDim2.new(0, 0, 0, 0)
    window.BackgroundTransparency = 1
    Utility.Tween(window, {
        Size     = UDim2.new(0, 800, 0, 540),
        BackgroundTransparency = 0,
    }, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    return self
end

function Window:CreateTab(opts)
    opts = opts or {}
    local theme = self._Theme
    local name  = opts.Name or "Tab"
    local icon  = opts.Icon or ""
    local badge = opts.Badge

    local tab = Tab.new(opts, theme, self._Content)
    table.insert(self._Tabs, tab)

    -- Sidebar button
    local isFirst = #self._Tabs == 1
    local btn = Utility.Create("TextButton", {
        Parent           = self._TabList,
        BackgroundColor3 = isFirst and theme.AccentDark or Color3.new(0,0,0),
        BackgroundTransparency = isFirst and 0 or 1,
        BorderSizePixel  = 0,
        Size             = UDim2.new(1, 0, 0, 36),
        Text             = "",
        AutoButtonColor  = false,
        LayoutOrder      = #self._Tabs,
    }, {
        Utility.Create("UICorner",  { CornerRadius = UDim.new(0, 8) }),
    })
    tab._SidebarBtn = btn

    local iconLabel = Utility.Create("TextLabel", {
        Parent           = btn,
        BackgroundTransparency = 1,
        Size             = UDim2.new(0, 22, 1, 0),
        Position         = UDim2.new(0, 10, 0, 0),
        Text             = icon ~= "" and icon or Icons[name] or ">",
        TextColor3       = isFirst and theme.AccentLight or theme.TextMuted,
        TextSize         = 14,
        Font             = Enum.Font.GothamBold,
        TextXAlignment   = Enum.TextXAlignment.Center,
    })

    local nameLabel = Utility.Create("TextLabel", {
        Parent           = btn,
        BackgroundTransparency = 1,
        Size             = UDim2.new(1, -44, 1, 0),
        Position         = UDim2.new(0, 36, 0, 0),
        Text             = name,
        TextColor3       = isFirst and theme.Text or theme.TextMuted,
        TextSize         = 13,
        Font             = isFirst and Enum.Font.GothamBold or Enum.Font.Gotham,
        TextXAlignment   = Enum.TextXAlignment.Left,
    })

    -- Active indicator
    local indicator = Utility.Create("Frame", {
        Parent           = btn,
        BackgroundColor3 = theme.Accent,
        BorderSizePixel  = 0,
        Size             = UDim2.new(0, 3, 0, 18),
        Position         = UDim2.new(0, 0, 0.5, 0),
        AnchorPoint      = Vector2.new(0, 0.5),
        Visible          = isFirst,
    }, {
        Utility.Create("UICorner",  { CornerRadius = UDim.new(1, 0) }),
    })

    -- Badge
    if badge then
        local badgeFrame = Utility.Create("Frame", {
            Parent           = btn,
            BackgroundColor3 = theme.Error,
            BorderSizePixel  = 0,
            Size             = UDim2.new(0, 18, 0, 18),
            Position         = UDim2.new(1, -22, 0.5, 0),
            AnchorPoint      = Vector2.new(0, 0.5),
        }, {
            Utility.Create("UICorner",  { CornerRadius = UDim.new(1, 0) }),
            Utility.Create("TextLabel", {
                BackgroundTransparency = 1,
                Size      = UDim2.new(1, 0, 1, 0),
                Text      = tostring(badge),
                TextColor3 = Color3.new(1, 1, 1),
                TextSize  = 9,
                Font      = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Center,
            }),
        })
        tab._Badge = badgeFrame
    end

    -- Select tab
    local function selectTab()
        -- Deselect all
        for _, t in ipairs(self._Tabs) do
            t:_Deselect()
            if t._SidebarBtn then
                Utility.Tween(t._SidebarBtn, {
                    BackgroundTransparency = 1,
                }, 0.15)
                if t._SidebarBtn:FindFirstChild("TextLabel") then
                    for _, lbl in ipairs(t._SidebarBtn:GetChildren()) do
                        if lbl:IsA("TextLabel") then
                            Utility.Tween(lbl, { TextColor3 = theme.TextMuted }, 0.15)
                            lbl.Font = Enum.Font.Gotham
                        end
                    end
                end
            end
        end

        -- Select this tab
        tab:_Select()
        self._ActiveTab = tab
        Utility.Tween(btn, { BackgroundTransparency = 0, BackgroundColor3 = theme.AccentDark }, 0.15)
        Utility.Tween(iconLabel, { TextColor3 = theme.AccentLight }, 0.15)
        Utility.Tween(nameLabel, { TextColor3 = theme.Text }, 0.15)
        nameLabel.Font = Enum.Font.GothamBold
        indicator.Visible = true
    end

    -- Hide all indicators
    for _, t in ipairs(self._Tabs) do
        if t._SidebarBtn then
            for _, c in ipairs(t._SidebarBtn:GetChildren()) do
                if c:IsA("Frame") and c.Size == UDim2.new(0, 3, 0, 18) then
                    c.Visible = false
                end
            end
        end
    end

    if isFirst then
        selectTab()
    end

    btn.MouseButton1Click:Connect(selectTab)

    btn.MouseEnter:Connect(function()
        if self._ActiveTab ~= tab then
            Utility.Tween(btn, { BackgroundTransparency = 0.7, BackgroundColor3 = theme.SurfaceAlt }, 0.1)
            Utility.Tween(nameLabel, { TextColor3 = theme.TextSub }, 0.1)
        end
    end)
    btn.MouseLeave:Connect(function()
        if self._ActiveTab ~= tab then
            Utility.Tween(btn, { BackgroundTransparency = 1 }, 0.1)
            Utility.Tween(nameLabel, { TextColor3 = theme.TextMuted }, 0.1)
        end
    end)

    -- Add separator support
    tab.AddSeparator = function()
        Utility.Create("Frame", {
            Parent           = self._TabList,
            BackgroundColor3 = theme.Border,
            BorderSizePixel  = 0,
            Size             = UDim2.new(1, -16, 0, 1),
            LayoutOrder      = #self._Tabs + 0.5,
        }, {
            Utility.Create("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) }),
        })
    end

    return tab
end

function Window:AddSeparator()
    Utility.Create("Frame", {
        Parent           = self._TabList,
        BackgroundColor3 = self._Theme.Border,
        BorderSizePixel  = 0,
        Size             = UDim2.new(1, -16, 0, 1),
        LayoutOrder      = #self._Tabs + 0.5,
    })
end

function Window:Toggle()
    self._Visible = not self._Visible
    if self._Visible then
        self._Window.Visible = true
        Utility.Tween(self._Window, { BackgroundTransparency = 0, Size = UDim2.new(0, 800, 0, 540) }, 0.3, Enum.EasingStyle.Back)
    else
        Utility.Tween(self._Window, {
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 0, 0, 0),
        }, 0.25, nil, nil, function()
            self._Window.Visible = false
        end)
    end
end

function Window:Close()
    Utility.Tween(self._Window, {
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 0, 0, 0),
    }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In, function()
        self._Gui:Destroy()
    end)
end

function Window:ToggleMinimize()
    self._Minimized = not self._Minimized
    if self._Minimized then
        Utility.Tween(self._Window, { Size = UDim2.new(0, 800, 0, 52) }, 0.3, Enum.EasingStyle.Quart)
    else
        Utility.Tween(self._Window, { Size = UDim2.new(0, 800, 0, 540) }, 0.3, Enum.EasingStyle.Back)
    end
end

function Window:ToggleMaximize()
    local vp = Utility.GetScreenSize()
    if self._Maximized then
        Utility.Tween(self._Window, {
            Size     = UDim2.new(0, 800, 0, 540),
            Position = UDim2.new(0, vp.X / 2 - 400, 0, vp.Y / 2 - 270),
        }, 0.3, Enum.EasingStyle.Back)
        self._Maximized = false
    else
        Utility.Tween(self._Window, {
            Size     = UDim2.new(0, vp.X - 20, 0, vp.Y - 20),
            Position = UDim2.new(0, 10, 0, 10),
        }, 0.3, Enum.EasingStyle.Back)
        self._Maximized = true
    end
end

function Window:_ApplyTheme()
    -- Theme reload support (basic)
    self._Theme = NexusUI._Theme
end

function Window:Destroy()
    for _, conn in ipairs(self._Connections) do
        pcall(function() conn:Disconnect() end)
    end
    if self._Gui then self._Gui:Destroy() end
    if self._FloatGui then self._FloatGui:Destroy() end
end

-- ─────────────────────────────────────────────
--  AUTO RECOVERY SYSTEM
-- ─────────────────────────────────────────────
local function StartAutoRecovery(window)
    local gui    = window._Gui
    local mainWin = window._Window

    local function recover()
        if not gui or not gui.Parent then return end
        if not mainWin or not mainWin.Parent then
            -- Re-parent
            local ok = pcall(function() gui.Parent = CoreGui end)
            if not ok then
                pcall(function()
                    gui.Parent = LocalPlayer:FindFirstChildOfClass("PlayerGui")
                end)
            end
        end

        -- Recover UIScale
        if not gui:FindFirstChildOfClass("UIScale") then
            Utility.Create("UIScale", {
                Parent = gui,
                Scale  = Utility.GetScale(),
            })
        end

        -- Recover ZIndex / DisplayOrder
        pcall(function()
            gui.DisplayOrder = 100
        end)

        -- Recover UIStroke on window
        if mainWin and not mainWin:FindFirstChildOfClass("UIStroke") then
            local theme = NexusUI._Theme
            Utility.Create("UIStroke", {
                Parent    = mainWin,
                Color     = theme.Border,
                Thickness = 1.5,
            })
        end

        -- Recover UICorner on window
        if mainWin and not mainWin:FindFirstChildOfClass("UICorner") then
            Utility.Create("UICorner", {
                Parent        = mainWin,
                CornerRadius  = UDim.new(0, 14),
            })
        end
    end

    -- Check every 3 seconds
    local conn = RunService.Heartbeat:Connect(function()
        if not gui or not gui.Parent then return end
        recover()
    end)

    -- Also recover on character spawn
    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(0.5)
        recover()
    end)

    return conn
end

-- ─────────────────────────────────────────────
--  CONFIG SYSTEM
-- ─────────────────────────────────────────────
function NexusUI:SaveConfig(name, data)
    Utility.SaveConfig(CONFIG_FOLDER, name, data)
    NotificationManager:Send({
        Type    = "Success",
        Title   = "Config Saved",
        Message = "'" .. name .. "' saved successfully.",
        Duration = 2.5,
    })
end

function NexusUI:LoadConfig(name)
    return Utility.LoadConfig(CONFIG_FOLDER, name)
end

function NexusUI:DeleteConfig(name)
    Utility.DeleteConfig(CONFIG_FOLDER, name)
    NotificationManager:Send({
        Type    = "Info",
        Title   = "Config Deleted",
        Message = "'" .. name .. "' has been deleted.",
        Duration = 2.5,
    })
end

function NexusUI:ListConfigs()
    return Utility.ListConfigs(CONFIG_FOLDER)
end

function NexusUI:ExportConfig(name, data)
    local ok, encoded = pcall(HttpService.JSONEncode, HttpService, data)
    if ok then
        if setclipboard then
            setclipboard(encoded)
            NotificationManager:Send({ Type = "Success", Title = "Exported", Message = "Config copied to clipboard." })
        else
            NotificationManager:Send({ Type = "Warning", Title = "Export", Message = "Clipboard not supported. Config: " .. encoded:sub(1, 50) .. "..." })
        end
    end
end

function NexusUI:ImportConfig(jsonStr)
    local ok, data = pcall(HttpService.JSONDecode, HttpService, jsonStr)
    if ok then return data end
    NotificationManager:Send({ Type = "Error", Title = "Import Failed", Message = "Invalid JSON format." })
    return nil
end

-- ─────────────────────────────────────────────
--  NOTIFICATION PUBLIC API
-- ─────────────────────────────────────────────
function NexusUI:Notify(opts)
    return NotificationManager:Send(opts)
end

-- ─────────────────────────────────────────────
--  DIALOG PUBLIC API
-- ─────────────────────────────────────────────
function NexusUI:Dialog(opts)
    return DialogManager:Show(opts)
end

-- ─────────────────────────────────────────────
--  WINDOW PUBLIC API
-- ─────────────────────────────────────────────
function NexusUI:CreateWindow(opts)
    opts = opts or {}

    -- Init notifications
    NotificationManager:Init(self._Theme)

    local window = Window.new(opts, self._Theme, self)
    table.insert(self._Windows, window)

    -- Start auto recovery
    StartAutoRecovery(window)

    -- Present welcome notification
    task.delay(0.8, function()
        NotificationManager:Send({
            Type    = "Info",
            Title   = "NexusUI v" .. VERSION,
            Message = "UI Library loaded successfully.",
            Duration = 3,
        })
    end)

    return window
end

-- ─────────────────────────────────────────────
--  KEYBIND TO TOGGLE ALL WINDOWS
-- ─────────────────────────────────────────────
NexusUI._GlobalKeybind = Enum.KeyCode.RightShift

UserInputService.InputBegan:Connect(function(inp, gpe)
    if gpe then return end
    if inp.UserInputType == Enum.UserInputType.Keyboard and
       inp.KeyCode == NexusUI._GlobalKeybind then
        for _, win in ipairs(NexusUI._Windows) do
            win:Toggle()
        end
    end
end)

function NexusUI:SetToggleKey(key)
    NexusUI._GlobalKeybind = key
end

-- ─────────────────────────────────────────────
--  CLEANUP
-- ─────────────────────────────────────────────
function NexusUI:Destroy()
    for _, win in ipairs(self._Windows) do
        pcall(function() win:Destroy() end)
    end
    self._Windows = {}
    if NotificationManager._Container then
        pcall(function() NotificationManager._Container.Parent.Parent:Destroy() end)
        NotificationManager._Container = nil
    end
end

-- ─────────────────────────────────────────────
--  EXAMPLE USAGE (remove when deploying)
-- ─────────────────────────────────────────────
--[[

local NexusUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/.../NexusUI.lua"))()

-- Optional: change theme before creating window
NexusUI:SetTheme("Purple")  -- Purple | Blue | Green | Neon | Cyber | Light | Orange | Red

-- Create window
local Window = NexusUI:CreateWindow({
    Title       = "NexusUI",
    Subtitle    = "v2.5.0",
    Version     = "2.5.0",
    FPS         = true,
    Time        = true,
    Watermark   = true,
    UserInfo    = true,
    ExecutorName = true,
})

-- Create tabs
local Main   = Window:CreateTab({ Name = "Main",      Icon = ">_" })
local Combat = Window:CreateTab({ Name = "Combat",     Icon = "⚔" })
Window:AddSeparator()
local Config = Window:CreateTab({ Name = "Config",     Icon = "💾" })

-- Main tab
local Section1 = Main:CreateSection({ Name = "Combat Features" })

Section1:CreateToggle({
    Name        = "Aimbot (Silent)",
    Description = "Automatically redirects hits to target.",
    Value       = false,
    Callback    = function(v)
        print("Aimbot:", v)
    end,
})

Section1:CreateSlider({
    Name    = "FOV Radius",
    Min     = 0,
    Max     = 360,
    Value   = 65,
    Step    = 1,
    Suffix  = "px",
    Callback = function(v)
        print("FOV:", v)
    end,
})

Section1:CreateDropdown({
    Name     = "Target Priority",
    Items    = { "Nearest", "Lowest HP", "Highest HP", "Random", "Red", "Blue" },
    Value    = "Nearest",
    Callback = function(v)
        print("Target:", v)
    end,
})

local Section2 = Main:CreateSection({ Name = "Misc Features" })

Section2:CreateTextbox({
    Name        = "Spam Delay",
    Placeholder = "0.1",
    Numeric     = true,
    Callback    = function(v)
        print("Delay:", v)
    end,
})

Section2:CreateButton({
    Name     = "Execute Script",
    Callback = function()
        print("Executing!")
    end,
})

-- Config tab
local ConfigSection = Config:CreateSection({ Name = "Configuration" })

ConfigSection:CreateButton({
    Name     = "Save Config",
    Callback = function()
        NexusUI:SaveConfig("myconfig", { aimbot = true, fov = 65 })
    end,
})

ConfigSection:CreateButton({
    Name     = "Load Config",
    Callback = function()
        local data = NexusUI:LoadConfig("myconfig")
        if data then print("Loaded:", data.fov) end
    end,
})

-- Notifications
NexusUI:Notify({ Type = "Success", Title = "Hello!", Message = "NexusUI is ready.", Duration = 3 })

-- Dialog
NexusUI:Dialog({
    Type    = "YesNo",
    Title   = "Confirm Action",
    Message = "Are you sure you want to proceed?",
    Callback = function(result)
        if result then print("Confirmed!") end
    end,
})

-- Custom theme
NexusUI:RegisterTheme("Custom", {
    Background  = Color3.fromRGB(10, 10, 20),
    Accent      = Color3.fromRGB(255, 100, 200),
    -- ... other fields inherit from Purple
})
NexusUI:SetTheme("Custom")

-- Toggle all windows with RightShift (default)
NexusUI:SetToggleKey(Enum.KeyCode.RightControl)

]]

-- ─────────────────────────────────────────────
--  RETURN LIBRARY
-- ─────────────────────────────────────────────
return NexusUI
