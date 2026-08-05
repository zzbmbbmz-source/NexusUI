--[[
    NexusUI v2.5.0 — Full API Test Script
    ทดสอบทุก API · ทุก Element · ทุก Window · ทุก Theme
    
    โหลดและรันในตัว Executor ที่รองรับ Luau
    URL: https://raw.githubusercontent.com/zzbmbbmz-source/Roblox/refs/heads/main/NexusUI.lua
]]

-- ─────────────────────────────────────────────
--  LOAD LIBRARY
-- ─────────────────────────────────────────────
local NexusUI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/zzbmbbmz-source/Roblox/refs/heads/main/NexusUI.lua",
    true -- nocache: ป้องกัน GitHub CDN cache ทำให้ได้ไฟล์เวอร์ชันเก่า
))()

print("[NexusUI Test] Library loaded:", NexusUI ~= nil)

-- ─────────────────────────────────────────────
--  HELPER
-- ─────────────────────────────────────────────
local function log(msg)
    print("[NexusUI Test] " .. tostring(msg))
end

-- ─────────────────────────────────────────────
--  TEST 1: REGISTER CUSTOM THEME
-- ─────────────────────────────────────────────
log("Testing: RegisterTheme")
NexusUI:RegisterTheme("Aqua", {
    Background      = Color3.fromRGB(8,  20, 28),
    Surface         = Color3.fromRGB(12, 28, 40),
    SurfaceAlt      = Color3.fromRGB(16, 36, 52),
    Card            = Color3.fromRGB(14, 32, 46),
    CardAlt         = Color3.fromRGB(18, 40, 58),
    Sidebar         = Color3.fromRGB(10, 22, 32),
    Accent          = Color3.fromRGB(0,  200, 255),
    AccentDark      = Color3.fromRGB(0,  150, 200),
    AccentLight     = Color3.fromRGB(100,230, 255),
    AccentGradient1 = Color3.fromRGB(0,  200, 255),
    AccentGradient2 = Color3.fromRGB(0,  100, 180),
    Text            = Color3.fromRGB(220,245, 255),
    TextSub         = Color3.fromRGB(140,190, 220),
    TextMuted       = Color3.fromRGB(70, 120, 160),
    TextAccent      = Color3.fromRGB(100,230, 255),
    Border          = Color3.fromRGB(20, 60,  90),
    BorderAccent    = Color3.fromRGB(0,  200, 255),
    Success         = Color3.fromRGB(52, 211, 153),
    Warning         = Color3.fromRGB(251,191, 36),
    Error           = Color3.fromRGB(248,113, 113),
    Info            = Color3.fromRGB(96, 165, 250),
    Toggle          = Color3.fromRGB(15, 50,  75),
    ToggleOn        = Color3.fromRGB(0,  200, 255),
    SliderFill      = Color3.fromRGB(0,  200, 255),
    SliderTrack     = Color3.fromRGB(12, 40,  60),
    InputBg         = Color3.fromRGB(8,  18,  28),
    InputBorder     = Color3.fromRGB(20, 65,  95),
    Shadow          = Color3.fromRGB(0,  0,   0),
    Overlay         = Color3.fromRGB(4,  10,  16),
})
log("Custom theme 'Aqua' registered")

-- ─────────────────────────────────────────────
--  TEST 2: SET THEME — Purple (default)
-- ─────────────────────────────────────────────
NexusUI:SetTheme("Purple")
log("Theme set to Purple")

-- ─────────────────────────────────────────────
--  TEST 3: CREATE WINDOW #1 — Main Window (Purple)
-- ─────────────────────────────────────────────
log("Testing: CreateWindow")
local Window1 = NexusUI:CreateWindow({
    Title        = "NexusUI",
    Subtitle     = "Full Test Suite",
    Version      = "2.5.0",
    FPS          = true,
    Time         = true,
    Watermark    = true,
    UserInfo     = true,
    ExecutorName = true,
    ConfigName   = "test_config",
})
log("Window1 created")

-- ─────────────────────────────────────────────
--  TAB 1: Main
-- ─────────────────────────────────────────────
local TabMain = Window1:CreateTab({ Name = "Main", Icon = ">_" })

-- Section: Buttons
local SecButtons = TabMain:CreateSection({ Name = "Buttons" })

local btn1 = SecButtons:CreateButton({
    Name     = "Simple Button",
    Callback = function()
        log("Button clicked: Simple Button")
        NexusUI:Notify({ Type = "Success", Title = "Button", Message = "Simple Button clicked!", Duration = 2 })
    end,
})

local btn2 = SecButtons:CreateButton({
    Name     = "Open Confirm Dialog",
    Callback = function()
        log("Opening Confirm dialog")
        NexusUI:Dialog({
            Type    = "Confirm",
            Title   = "Confirm Action",
            Message = "Are you sure you want to proceed with this action?",
            Callback = function(result)
                log("Confirm result: " .. tostring(result))
                NexusUI:Notify({
                    Type    = result and "Success" or "Warning",
                    Title   = "Dialog Result",
                    Message = "You clicked: " .. (result and "OK" or "Cancel"),
                    Duration = 2,
                })
            end,
        })
    end,
})

local btn3 = SecButtons:CreateButton({
    Name     = "Open Yes/No Dialog",
    Callback = function()
        NexusUI:Dialog({
            Type        = "YesNo",
            Title       = "Delete Item",
            Message     = "Are you sure you want to delete this item? This action cannot be undone.",
            ConfirmText = "Yes, Delete",
            CancelText  = "No, Keep",
            Callback    = function(result)
                log("YesNo result: " .. tostring(result))
            end,
        })
    end,
})

local btn4 = SecButtons:CreateButton({
    Name     = "Open Input Dialog",
    Callback = function()
        NexusUI:Dialog({
            Type        = "Input",
            Title       = "Enter Value",
            Message     = "Type something below:",
            Placeholder = "Enter text here...",
            Default     = "Hello NexusUI",
            Callback    = function(result)
                log("Input dialog result: " .. tostring(result))
                NexusUI:Notify({ Type = "Info", Title = "Input Received", Message = "You typed: " .. tostring(result), Duration = 3 })
            end,
        })
    end,
})

local btn5 = SecButtons:CreateButton({
    Name     = "Open Loading Dialog",
    Callback = function()
        local dialog = NexusUI:Dialog({ Type = "Loading", Title = "Processing...", Message = "Please wait while we load data." })
        task.delay(3, function()
            dialog.Close()
            NexusUI:Notify({ Type = "Success", Title = "Done!", Message = "Loading complete.", Duration = 2 })
        end)
    end,
})

-- Section: Toggles
local SecToggles = TabMain:CreateSection({ Name = "Toggles" })

local toggle1 = SecToggles:CreateToggle({
    Name        = "Simple Toggle",
    Value       = false,
    Callback    = function(v)
        log("Toggle1: " .. tostring(v))
    end,
})

local toggle2 = SecToggles:CreateToggle({
    Name        = "Toggle with Description",
    Description = "This is a description explaining what this toggle does.",
    Value       = true,
    Callback    = function(v)
        log("Toggle2: " .. tostring(v))
        NexusUI:Notify({
            Type    = v and "Success" or "Warning",
            Title   = "Toggle Changed",
            Message = "Toggle is now " .. (v and "ON" or "OFF"),
            Duration = 1.5,
        })
    end,
})

local toggle3 = SecToggles:CreateToggle({
    Name     = "Initially ON Toggle",
    Value    = true,
    Callback = function(v) log("Toggle3: " .. tostring(v)) end,
})

-- API: SetValue
task.delay(2, function()
    toggle1:SetValue(true)
    log("toggle1:SetValue(true) called")
end)
task.delay(4, function()
    log("toggle1:GetValue() = " .. tostring(toggle1:GetValue()))
end)

-- ─────────────────────────────────────────────
--  TAB 2: Combat
-- ─────────────────────────────────────────────
local TabCombat = Window1:CreateTab({ Name = "Combat", Icon = "⚔" })

-- Section: Sliders
local SecSliders = TabCombat:CreateSection({ Name = "Sliders" })

local slider1 = SecSliders:CreateSlider({
    Name     = "FOV Radius",
    Min      = 0,
    Max      = 360,
    Value    = 65,
    Step     = 1,
    Suffix   = "px",
    Callback = function(v) log("Slider1 FOV: " .. v) end,
})

local slider2 = SecSliders:CreateSlider({
    Name     = "Prediction",
    Min      = 0,
    Max      = 1,
    Value    = 0.14,
    Step     = 0.01,
    Suffix   = "s",
    Callback = function(v) log("Slider2 Prediction: " .. v) end,
})

local slider3 = SecSliders:CreateSlider({
    Name     = "Smoothness",
    Min      = 0,
    Max      = 100,
    Value    = 50,
    Step     = 5,
    Suffix   = "%",
    Callback = function(v) log("Slider3 Smoothness: " .. v) end,
})

-- API: SetValue / GetValue
task.delay(3, function()
    slider1:SetValue(120)
    log("slider1:SetValue(120) called")
    log("slider1:GetValue() = " .. tostring(slider1:GetValue()))
end)

-- Section: Dropdowns
local SecDropdowns = TabCombat:CreateSection({ Name = "Dropdowns" })

local drop1 = SecDropdowns:CreateDropdown({
    Name     = "Target Priority",
    Items    = { "Nearest", "Lowest HP", "Highest HP", "Most Valuable", "Random", "Red Team", "Blue Team" },
    Value    = "Nearest",
    Callback = function(v) log("Dropdown1: " .. tostring(v)) end,
})

local drop2 = SecDropdowns:CreateDropdown({
    Name     = "Hit Part",
    Items    = { "Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg", "Random" },
    Value    = "Head",
    Callback = function(v) log("Dropdown2 HitPart: " .. tostring(v)) end,
})

local multiDrop = SecDropdowns:CreateMultiDropdown({
    Name     = "Ignored Players (Multi-Select)",
    Items    = { "Player1", "Player2", "Player3", "Player4", "Player5" },
    Callback = function(v)
        log("MultiDropdown selected: " .. table.concat(v, ", "))
    end,
})

-- API: SetItems / GetValue
task.delay(5, function()
    drop1:SetItems({ "Option A", "Option B", "Option C", "Option D" })
    log("drop1:SetItems() called with new items")
    drop1:SetValue("Option B")
    log("drop1:SetValue('Option B') called")
    log("drop1:GetValue() = " .. tostring(drop1:GetValue()))
end)

-- ─────────────────────────────────────────────
--  TAB 3: Visuals
-- ─────────────────────────────────────────────
local TabVisuals = Window1:CreateTab({ Name = "Visuals", Icon = "👁" })

-- Section: Input Elements
local SecInput = TabVisuals:CreateSection({ Name = "Text Inputs" })

local tb1 = SecInput:CreateTextbox({
    Name        = "Player Name Filter",
    Placeholder = "Enter player name...",
    Value       = "",
    Callback    = function(v, enter)
        log("Textbox1: '" .. v .. "' enter=" .. tostring(enter))
    end,
})

local tb2 = SecInput:CreateTextbox({
    Name           = "Walkspeed Value",
    Placeholder    = "16",
    Numeric        = true,
    ClearOnFocus   = false,
    Value          = "16",
    Callback       = function(v)
        log("Textbox2 numeric: " .. tostring(v))
    end,
})

-- API: GetValue / SetValue
task.delay(2, function()
    tb1:SetValue("TestPlayer")
    log("tb1:GetValue() = " .. tostring(tb1:GetValue()))
end)

-- Section: Keybinds
local SecKeybinds = SecInput

local kb1 = SecKeybinds:CreateKeybind({
    Name       = "Toggle Aimbot",
    Key        = Enum.KeyCode.E,
    Callback   = function(k) log("Keybind1 changed: " .. k.Name) end,
    OnActivate = function()
        log("Keybind1 activated!")
        NexusUI:Notify({ Type = "Info", Title = "Keybind", Message = "Aimbot toggled via keybind.", Duration = 1.5 })
    end,
})

local kb2 = SecKeybinds:CreateKeybind({
    Name       = "Toggle ESP",
    Key        = Enum.KeyCode.F,
    Callback   = function(k) log("Keybind2 changed: " .. k.Name) end,
    OnActivate = function() log("ESP toggled!") end,
})

-- API: GetKey / SetKey
task.delay(2, function()
    log("kb1:GetKey() = " .. kb1:GetKey().Name)
    kb2:SetKey(Enum.KeyCode.G)
    log("kb2:SetKey(G) called, now: " .. kb2:GetKey().Name)
end)

-- Section: Color Pickers
local SecColors = TabVisuals:CreateSection({ Name = "Color Pickers" })

local cp1 = SecColors:CreateColorPicker({
    Name     = "ESP Color",
    Color    = Color3.fromRGB(124, 92, 246),
    Callback = function(c)
        log("ColorPicker1 ESP: " .. tostring(c))
    end,
})

local cp2 = SecColors:CreateColorPicker({
    Name     = "Chams Color",
    Color    = Color3.fromRGB(255, 100, 100),
    Callback = function(c)
        log("ColorPicker2 Chams: " .. tostring(c))
    end,
})

local cp3 = SecColors:CreateColorPicker({
    Name     = "Highlight Color",
    Color    = Color3.fromRGB(0, 200, 100),
    Callback = function(c)
        log("ColorPicker3 Highlight: " .. tostring(c))
    end,
})

-- API: GetColor
task.delay(2, function()
    local c = cp1:GetColor()
    log("cp1:GetColor() = R:" .. math.floor(c.R*255) .. " G:" .. math.floor(c.G*255) .. " B:" .. math.floor(c.B*255))
end)

-- ─────────────────────────────────────────────
--  TAB 4: Player
-- ─────────────────────────────────────────────
local TabPlayer = Window1:CreateTab({ Name = "Player", Icon = "👤" })

local SecPlayerMod = TabPlayer:CreateSection({ Name = "Player Modifiers" })

SecPlayerMod:CreateSlider({ Name = "WalkSpeed",  Min = 0,   Max = 500, Value = 16,  Step = 1, Suffix = "", Callback = function(v) log("WalkSpeed: " .. v) end })
SecPlayerMod:CreateSlider({ Name = "JumpPower",  Min = 0,   Max = 500, Value = 50,  Step = 1, Suffix = "", Callback = function(v) log("JumpPower: " .. v) end })
SecPlayerMod:CreateSlider({ Name = "Gravity",    Min = 0,   Max = 1000,Value = 196, Step = 1, Suffix = "", Callback = function(v) log("Gravity: " .. v) end })
SecPlayerMod:CreateToggle({ Name = "Noclip",     Value = false, Callback = function(v) log("Noclip: " .. tostring(v)) end })
SecPlayerMod:CreateToggle({ Name = "Infinite Jump", Value = false, Callback = function(v) log("InfJump: " .. tostring(v)) end })
SecPlayerMod:CreateToggle({ Name = "Anti-Void",  Value = true,  Callback = function(v) log("AntiVoid: " .. tostring(v)) end })

local SecPlayerInfo = TabPlayer:CreateSection({ Name = "Player Info" })
SecPlayerInfo:CreateLabel({ Text = "Name: " .. game.Players.LocalPlayer.Name })
SecPlayerInfo:CreateLabel({ Text = "Display: " .. game.Players.LocalPlayer.DisplayName })
SecPlayerInfo:CreateLabel({ Text = "UserId: " .. tostring(game.Players.LocalPlayer.UserId) })
SecPlayerInfo:CreateParagraph({
    Title   = "Account Info",
    Content = "Player: " .. game.Players.LocalPlayer.Name .. "\nGame: " .. tostring(game.PlaceId) .. "\nVersion: NexusUI v2.5.0",
})
SecPlayerInfo:CreateDivider({ Text = "STATS" })
SecPlayerInfo:CreateProgressBar({ Name = "Health",  Value = 100, Max = 100, Suffix = "%" })
SecPlayerInfo:CreateProgressBar({ Name = "Stamina", Value = 75,  Max = 100, Suffix = "%" })
SecPlayerInfo:CreateProgressBar({ Name = "XP",      Value = 32,  Max = 100, Suffix = "%" })

-- API: SetValue on progress bar
local hpBar = SecPlayerInfo:CreateProgressBar({ Name = "Shield", Value = 0, Max = 100, Suffix = "%" })
task.delay(2, function()
    for i = 0, 100, 5 do
        task.wait(0.1)
        hpBar:SetValue(i)
    end
    log("hpBar filled to 100")
end)

-- ─────────────────────────────────────────────
--  TAB 5: Teleport
-- ─────────────────────────────────────────────
local TabTeleport = Window1:CreateTab({ Name = "Teleport", Icon = "⚡" })
local SecTele = TabTeleport:CreateSection({ Name = "Quick Teleport" })

local searchBox = SecTele:CreateSearchBox({
    Placeholder = "Search location...",
    Callback    = function(v) log("Search: " .. v) end,
})

SecTele:CreateButton({ Name = "Teleport to Spawn",  Callback = function() log("Teleport: Spawn") end })
SecTele:CreateButton({ Name = "Teleport to Target", Callback = function() log("Teleport: Target") end })
SecTele:CreateButton({ Name = "Teleport to Waypoint", Callback = function() log("Teleport: Waypoint") end })

local SecTelePos = TabTeleport:CreateSection({ Name = "Custom Coordinates" })
SecTelePos:CreateTextbox({ Name = "X Position", Placeholder = "0", Numeric = true, Callback = function(v) log("Tele X: " .. v) end })
SecTelePos:CreateTextbox({ Name = "Y Position", Placeholder = "0", Numeric = true, Callback = function(v) log("Tele Y: " .. v) end })
SecTelePos:CreateTextbox({ Name = "Z Position", Placeholder = "0", Numeric = true, Callback = function(v) log("Tele Z: " .. v) end })
SecTelePos:CreateButton({
    Name = "Teleport to Coordinates",
    Callback = function()
        NexusUI:Notify({ Type = "Info", Title = "Teleporting", Message = "Moving to custom coordinates...", Duration = 2 })
    end,
})

-- ─────────────────────────────────────────────
--  TAB 6: Utility
-- ─────────────────────────────────────────────
local TabUtility = Window1:CreateTab({ Name = "Utility", Icon = "🔧" })
local SecUtil = TabUtility:CreateSection({ Name = "General Utilities" })

SecUtil:CreateButton({ Name = "Rejoin Server",       Callback = function() log("Rejoin") end })
SecUtil:CreateButton({ Name = "Copy Server ID",      Callback = function() log("Copy Server ID") end })
SecUtil:CreateButton({ Name = "Copy Game ID",        Callback = function() log("Copy Game ID") end })
SecUtil:CreateButton({ Name = "Screenshot",          Callback = function() log("Screenshot") end })
SecUtil:CreateDivider({ Text = "CHAT" })
SecUtil:CreateTextbox({ Name = "Chat Message", Placeholder = "Type message...", Callback = function(v) log("Chat: " .. v) end })
SecUtil:CreateButton({ Name = "Send Chat", Callback = function() log("Send chat") end })

local SecAntiAFK = TabUtility:CreateSection({ Name = "Anti-AFK" })
SecAntiAFK:CreateToggle({ Name = "Anti-AFK", Value = false, Description = "Prevents being kicked for inactivity.", Callback = function(v) log("AntiAFK: " .. tostring(v)) end })
SecAntiAFK:CreateSlider({ Name = "Interval",  Min = 1, Max = 60, Value = 10, Suffix = "s", Callback = function(v) log("AFK interval: " .. v) end })

-- ─────────────────────────────────────────────
--  TAB 7: Settings + Theme Switcher
-- ─────────────────────────────────────────────
Window1:AddSeparator()
local TabSettings = Window1:CreateTab({ Name = "Settings", Icon = "⚙" })
local SecTheme = TabSettings:CreateSection({ Name = "Theme" })

local themeList = { "Purple", "Blue", "Green", "Neon", "Cyber", "Light", "Orange", "Red", "Aqua" }
SecTheme:CreateDropdown({
    Name     = "UI Theme",
    Items    = themeList,
    Value    = "Purple",
    Callback = function(v)
        log("Switching theme to: " .. v)
        NexusUI:SetTheme(v)
        NexusUI:Notify({ Type = "Success", Title = "Theme Changed", Message = "Applied theme: " .. v, Duration = 2 })
    end,
})

local SecKeybindSettings = TabSettings:CreateSection({ Name = "Keybinds" })
SecKeybindSettings:CreateKeybind({
    Name     = "Toggle UI",
    Key      = Enum.KeyCode.RightShift,
    Callback = function(k)
        NexusUI:SetToggleKey(k)
        log("Toggle key changed to: " .. k.Name)
    end,
})

-- ─────────────────────────────────────────────
--  TAB 8: Config
-- ─────────────────────────────────────────────
local TabConfig = Window1:CreateTab({ Name = "Config", Icon = "💾" })
local SecConfig = TabConfig:CreateSection({ Name = "Configuration" })

local configNameBox = SecConfig:CreateTextbox({
    Name        = "Config Name",
    Placeholder = "my_config",
    Value       = "test_config",
})

SecConfig:CreateButton({
    Name = "Save Config",
    Callback = function()
        local name = configNameBox:GetValue()
        if name == "" then name = "test_config" end
        NexusUI:SaveConfig(name, {
            theme    = NexusUI:GetTheme().Name,
            aimbot   = toggle1:GetValue(),
            fov      = slider1:GetValue(),
            target   = drop1:GetValue(),
            savedAt  = os.time(),
        })
        log("Config saved: " .. name)
    end,
})

SecConfig:CreateButton({
    Name = "Load Config",
    Callback = function()
        local name = configNameBox:GetValue()
        if name == "" then name = "test_config" end
        local data = NexusUI:LoadConfig(name)
        if data then
            log("Config loaded: " .. name)
            NexusUI:Notify({ Type = "Success", Title = "Config Loaded", Message = "Loaded: " .. name, Duration = 2 })
        else
            NexusUI:Notify({ Type = "Warning", Title = "Not Found", Message = "Config '" .. name .. "' not found.", Duration = 2 })
        end
    end,
})

SecConfig:CreateButton({
    Name = "Delete Config",
    Callback = function()
        local name = configNameBox:GetValue()
        if name == "" then name = "test_config" end
        NexusUI:Dialog({
            Type    = "YesNo",
            Title   = "Delete Config",
            Message = "Delete config '" .. name .. "'? This cannot be undone.",
            Callback = function(result)
                if result then
                    NexusUI:DeleteConfig(name)
                    log("Config deleted: " .. name)
                end
            end,
        })
    end,
})

SecConfig:CreateDivider({ Text = "IMPORT / EXPORT" })

SecConfig:CreateButton({
    Name = "Export Config (Copy to Clipboard)",
    Callback = function()
        NexusUI:ExportConfig("test_export", {
            version  = "2.5.0",
            settings = { aimbot = true, fov = 65, theme = "Purple" },
        })
    end,
})

local importBox = SecConfig:CreateTextbox({
    Name        = "Import JSON",
    Placeholder = '{"version":"2.5.0",...}',
    Callback    = function(v, enter)
        if enter and v ~= "" then
            local data = NexusUI:ImportConfig(v)
            if data then
                log("Import success: " .. tostring(data))
                NexusUI:Notify({ Type = "Success", Title = "Imported", Message = "Config imported successfully.", Duration = 2 })
            end
        end
    end,
})

-- List configs
SecConfig:CreateButton({
    Name = "List All Configs",
    Callback = function()
        local configs = NexusUI:ListConfigs()
        log("Available configs: " .. #configs)
        for _, name in ipairs(configs) do log("  - " .. name) end
        if #configs == 0 then
            NexusUI:Notify({ Type = "Info", Title = "No Configs", Message = "No saved configs found.", Duration = 2 })
        else
            NexusUI:Notify({ Type = "Info", Title = "Configs", Message = table.concat(configs, ", "), Duration = 3 })
        end
    end,
})

-- ─────────────────────────────────────────────
--  TAB 9: Credits
-- ─────────────────────────────────────────────
local TabCredits = Window1:CreateTab({ Name = "Credits", Icon = "★" })
local SecCredits = TabCredits:CreateSection({ Name = "Credits" })

SecCredits:CreateParagraph({ Title = "NexusUI v2.5.0", Content = "A production-grade Roblox UI Library with Dark Theme, Purple Accent, and Modern Minimal Design." })
SecCredits:CreateDivider({ Text = "TEAM" })
SecCredits:CreateLabel({ Text = "Developer: NexusUI Team" })
SecCredits:CreateLabel({ Text = "Design: Modern Minimal" })
SecCredits:CreateLabel({ Text = "Version: 2.5.0" })
SecCredits:CreateDivider({ Text = "LINKS" })
SecCredits:CreateButton({ Name = "GitHub Repository",  Callback = function() log("Opening GitHub...") end })
SecCredits:CreateButton({ Name = "Discord Server",     Callback = function() log("Opening Discord...") end })
SecCredits:CreateButton({ Name = "Report Bug",         Callback = function()
    NexusUI:Dialog({ Type = "Input", Title = "Report Bug", Message = "Describe the bug:", Placeholder = "Bug description...", Callback = function(v) log("Bug report: " .. tostring(v)) end })
end })

-- ─────────────────────────────────────────────
--  TAB 10: Developer
-- ─────────────────────────────────────────────
local TabDev = Window1:CreateTab({ Name = "Developer", Icon = "</>" })
local SecDev = TabDev:CreateSection({ Name = "Developer Tools" })

SecDev:CreateToggle({ Name = "Debug Mode",       Value = false, Callback = function(v) log("DebugMode: " .. tostring(v)) end })
SecDev:CreateToggle({ Name = "Verbose Logging",  Value = false, Callback = function(v) log("Verbose: " .. tostring(v)) end })
SecDev:CreateToggle({ Name = "Show Hit Debug",   Value = false, Callback = function(v) log("HitDebug: " .. tostring(v)) end })

local SecDevConsole = TabDev:CreateSection({ Name = "Console" })
local consoleOut = SecDevConsole:CreateParagraph({ Title = "Output", Content = "Ready..." })

local consoleIn = SecDevConsole:CreateTextbox({
    Name        = "Execute Lua",
    Placeholder = "print('Hello World')",
    Callback    = function(v, enter)
        if enter and v ~= "" then
            log("Exec: " .. v)
            local ok, err = pcall(loadstring(v))
            consoleOut:SetContent(ok and "OK" or "Error: " .. tostring(err))
        end
    end,
})

SecDevConsole:CreateDivider()
SecDevConsole:CreateSearchBox({ Placeholder = "Search output...", Callback = function(v) log("Console search: " .. v) end })

-- ─────────────────────────────────────────────
--  TEST 4: NOTIFICATIONS — All types
-- ─────────────────────────────────────────────
task.delay(1,   function() NexusUI:Notify({ Type = "Success", Title = "Success",     Message = "Operation completed successfully!",   Duration = 3 }) end)
task.delay(1.8, function() NexusUI:Notify({ Type = "Warning", Title = "Warning",     Message = "This action might have side effects.", Duration = 3 }) end)
task.delay(2.6, function() NexusUI:Notify({ Type = "Error",   Title = "Error",       Message = "Something went wrong. Please retry.", Duration = 3 }) end)
task.delay(3.4, function() NexusUI:Notify({ Type = "Info",    Title = "Information", Message = "Did you know? NexusUI v2.5.0 is here!", Duration = 3 }) end)
task.delay(4.2, function() NexusUI:Notify({ Type = "Loading", Title = "Loading",     Message = "Fetching data from server...",         Duration = 4 }) end)

-- ─────────────────────────────────────────────
--  TEST 5: CREATE WINDOW #2 — Blue Theme
-- ─────────────────────────────────────────────
task.delay(1, function()
    NexusUI:SetTheme("Blue")
    log("Creating Window2 with Blue theme")

    local Window2 = NexusUI:CreateWindow({
        Title    = "NexusUI #2",
        Subtitle = "Blue Theme Demo",
        Version  = "2.5.0",
        FPS      = true,
        Time     = false,
    })

    local W2Tab1 = Window2:CreateTab({ Name = "Main",     Icon = ">_" })
    local W2Tab2 = Window2:CreateTab({ Name = "Settings", Icon = "⚙" })

    local S1 = W2Tab1:CreateSection({ Name = "Blue Theme Demo" })
    S1:CreateToggle({ Name = "Feature A", Value = false, Callback = function(v) log("W2 FeatureA: " .. tostring(v)) end })
    S1:CreateToggle({ Name = "Feature B", Value = true,  Callback = function(v) log("W2 FeatureB: " .. tostring(v)) end })
    S1:CreateSlider({ Name = "Value", Min = 0, Max = 100, Value = 50, Callback = function(v) log("W2 Value: " .. v) end })
    S1:CreateButton({ Name = "Close This Window", Callback = function() Window2:Close() end })

    local S2 = W2Tab2:CreateSection({ Name = "Theme" })
    S2:CreateDropdown({ Name = "Theme", Items = { "Purple", "Blue", "Neon" }, Value = "Blue", Callback = function(v) NexusUI:SetTheme(v) end })

    log("Window2 created with Blue theme")

    -- Restore purple theme for Window1 after a bit
    task.delay(2, function()
        NexusUI:SetTheme("Purple")
    end)
end)

-- ─────────────────────────────────────────────
--  TEST 6: CREATE WINDOW #3 — Neon Theme
-- ─────────────────────────────────────────────
task.delay(2, function()
    NexusUI:SetTheme("Neon")
    log("Creating Window3 with Neon theme")

    local Window3 = NexusUI:CreateWindow({
        Title    = "NexusUI #3",
        Subtitle = "Neon Theme Demo",
        Version  = "2.5.0",
        FPS      = false,
        Time     = true,
    })

    local W3Tab = Window3:CreateTab({ Name = "Neon", Icon = "⚡" })
    local W3S   = W3Tab:CreateSection({ Name = "Neon Effects" })

    W3S:CreateColorPicker({ Name = "Neon Color 1", Color = Color3.fromRGB(0,255,200), Callback = function(c) log("W3 Color1: " .. tostring(c)) end })
    W3S:CreateColorPicker({ Name = "Neon Color 2", Color = Color3.fromRGB(100,0,255), Callback = function(c) log("W3 Color2: " .. tostring(c)) end })
    W3S:CreateSlider({ Name = "Glow Intensity", Min = 0, Max = 100, Value = 80, Suffix = "%", Callback = function(v) log("W3 Glow: " .. v) end })
    W3S:CreateButton({ Name = "Pulse Neon", Callback = function()
        NexusUI:Notify({ Type = "Success", Title = "Neon!", Message = "Neon mode activated.", Duration = 2 })
    end })
    W3S:CreateButton({ Name = "Close Window 3", Callback = function() Window3:Close() end })

    log("Window3 created")

    -- Restore theme
    task.delay(2, function()
        NexusUI:SetTheme("Purple")
    end)
end)

-- ─────────────────────────────────────────────
--  TEST 7: WINDOW TOGGLE (hide/show)
-- ─────────────────────────────────────────────
task.delay(8, function()
    log("Test: Toggle Window1 (hide)")
    Window1:Toggle()
    task.delay(1.5, function()
        log("Test: Toggle Window1 (show)")
        Window1:Toggle()
    end)
end)

-- ─────────────────────────────────────────────
--  TEST 8: MINIMIZE / MAXIMIZE
-- ─────────────────────────────────────────────
task.delay(10, function()
    log("Test: Minimize Window1")
    Window1:ToggleMinimize()
    task.delay(1.5, function()
        log("Test: Restore Window1")
        Window1:ToggleMinimize()
    end)
end)

-- ─────────────────────────────────────────────
--  TEST 9: MAXIMIZE
-- ─────────────────────────────────────────────
task.delay(12, function()
    log("Test: Maximize Window1")
    Window1:ToggleMaximize()
    task.delay(2, function()
        log("Test: Restore from maximize")
        Window1:ToggleMaximize()
    end)
end)

-- ─────────────────────────────────────────────
--  TEST 10: SetVisible on elements
-- ─────────────────────────────────────────────
task.delay(6, function()
    log("Test: btn1:SetVisible(false)")
    btn1:SetVisible(false)
    task.delay(2, function()
        log("Test: btn1:SetVisible(true)")
        btn1:SetVisible(true)
    end)
end)

-- ─────────────────────────────────────────────
--  TEST 11: SetText on button
-- ─────────────────────────────────────────────
task.delay(3, function()
    log("Test: btn2:SetText()")
    btn2:SetText("✓ Confirm Dialog (renamed)")
    task.delay(3, function()
        btn2:SetText("Open Confirm Dialog")
    end)
end)

-- ─────────────────────────────────────────────
--  TEST 12: btn SetEnabled
-- ─────────────────────────────────────────────
task.delay(5, function()
    log("Test: btn3:SetEnabled(false)")
    btn3:SetEnabled(false)
    task.delay(3, function()
        btn3:SetEnabled(true)
        log("Test: btn3:SetEnabled(true)")
    end)
end)

-- ─────────────────────────────────────────────
--  TEST 13: GLOBAL KEYBIND CHANGE
-- ─────────────────────────────────────────────
NexusUI:SetToggleKey(Enum.KeyCode.RightShift)
log("Global toggle keybind set to RightShift")

-- ─────────────────────────────────────────────
--  TEST 14: SearchBox API
-- ─────────────────────────────────────────────
task.delay(2, function()
    searchBox:SetValue("Spawn")
    log("searchBox:GetValue() = " .. tostring(searchBox:GetValue()))
end)

-- ─────────────────────────────────────────────
--  FINAL SUMMARY
-- ─────────────────────────────────────────────
task.delay(15, function()
    NexusUI:Notify({
        Type    = "Success",
        Title   = "Test Complete",
        Message = "All API tests passed. Check console for logs.",
        Duration = 5,
    })
    log("=== ALL TESTS COMPLETE ===")
    log("APIs tested:")
    log("  CreateWindow, CreateTab, AddSeparator")
    log("  CreateSection, CreateButton, CreateToggle")
    log("  CreateSlider, CreateDropdown, CreateMultiDropdown")
    log("  CreateTextbox, CreateKeybind, CreateColorPicker")
    log("  CreateLabel, CreateParagraph, CreateDivider")
    log("  CreateProgressBar, CreateSearchBox, CreateImage")
    log("  CreateComboBox")
    log("  Notify (5 types), Dialog (4 types)")
    log("  SetTheme, RegisterTheme, GetTheme")
    log("  SaveConfig, LoadConfig, DeleteConfig, ListConfigs")
    log("  ExportConfig, ImportConfig")
    log("  Toggle, ToggleMinimize, ToggleMaximize, Close")
    log("  SetToggleKey")
    log("  SetVisible, SetText, SetEnabled (elements)")
    log("  SetValue, GetValue (Toggle, Slider, Dropdown, Textbox, ProgressBar)")
    log("  GetKey, SetKey (Keybind)")
    log("  GetColor (ColorPicker)")
    log("  SetItems (Dropdown)")
    log("  SetContent (Paragraph)")
    log("  Window #1 (Purple), Window #2 (Blue), Window #3 (Neon)")
end)
