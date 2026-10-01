--[[
    FerClient | Rusted Version v2
    Battle Projects - Rusted
    ESP + Aimbot + Silent Aim (FOV-based) + Speed + Noclip + FPS Boost
]]

if getgenv().FerClient_Rusted_Loaded then
    if getgenv().FerClient_Rusted_Unload then pcall(getgenv().FerClient_Rusted_Unload) end
    task.wait(0.2)
end
getgenv().FerClient_Rusted_Loaded = true

if not game:IsLoaded() then game.Loaded:Wait() end

local HUI = (gethui and gethui()) or game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local Camera = Workspace.CurrentCamera
local LP = Players.LocalPlayer

--=========================================================
-- ТЕМА
--=========================================================
local Theme = {
    Background = Color3.fromRGB(10, 10, 10),
    Panel      = Color3.fromRGB(15, 15, 15),
    Tab        = Color3.fromRGB(18, 18, 18),
    TabActive  = Color3.fromRGB(30, 30, 30),
    Element    = Color3.fromRGB(22, 22, 22),
    Hover      = Color3.fromRGB(35, 35, 35),
    Accent     = Color3.fromRGB(90, 160, 255),
    Success    = Color3.fromRGB(50, 255, 100),
    Danger     = Color3.fromRGB(255, 60, 60),
    Text       = Color3.fromRGB(240, 245, 255),
    TextDim    = Color3.fromRGB(140, 150, 170),
    Border     = Color3.fromRGB(50, 50, 55),
    Font       = Enum.Font.GothamMedium,
    FontBold   = Enum.Font.GothamBold,
}

--=========================================================
-- КОНФИГ
--=========================================================
local Config = {
    ESP = {
        Enabled = true,
        Box = true, Name = true, Distance = true, Health = true, Tracer = true,
        MaxDistance = 1500, Color = Theme.Accent,
    },
    Aimbot = {
        Enabled = false, AutoAim = false, FOV = 200, Smoothness = 0.5,
        MaxDistance = 600, TargetPart = "Head", Visible = false,
        TeamCheck = true, ShowFOV = true, TriggerActive = false,
        Prediction = true, PredictionX = 0.15,
        AutoFire = false, AutoFireDelay = 0.05, LastFire = 0,
    },
    Silent = {
        Enabled = false,
        TargetPart = "Head",
        Visible = false,
        TeamCheck = true,
        FOV = 250,
        MaxDistance = 800,
        Prediction = true,
        PredictionX = 0.15,
        AutoShoot = true,
        AutoShootDelay = 0.08,
        LastShoot = 0,
        OnlyInCircle = true,
    },
    Player = {
        NoFallDamage = false,
        SpeedEnabled = false,
        SpeedValue = 30,
        Noclip = false,
    },
    Visual = {
        Fullbright = false,
        XRay = false,
        XRayTransparency = 0.5,
        FPSBoost = false,
    },
    Misc = {
        InfiniteJump = false,
        HitLogs = true,
    }
}

local hasDrawing = pcall(function()
    local t = Drawing.new("Square"); t:Remove()
end)

local Connections = {}
local function TrackConn(conn)
    Connections[#Connections + 1] = conn
    return conn
end

--=========================================================
-- HIT LOGS
--=========================================================
local HitLogsGui = Instance.new("ScreenGui")
HitLogsGui.Name = "FerClient_HitLogs"
HitLogsGui.ResetOnSpawn = false
HitLogsGui.IgnoreGuiInset = true
HitLogsGui.DisplayOrder = 999
pcall(function() HitLogsGui.Parent = HUI end)
if not HitLogsGui.Parent then HitLogsGui.Parent = LP:WaitForChild("PlayerGui") end

local HitLogsHolder = Instance.new("Frame")
HitLogsHolder.Size = UDim2.new(0, 500, 0, 300)
HitLogsHolder.Position = UDim2.new(0.5, -250, 0, 100)
HitLogsHolder.BackgroundTransparency = 1
HitLogsHolder.Parent = HitLogsGui

local HitLogsLayout = Instance.new("UIListLayout", HitLogsHolder)
HitLogsLayout.SortOrder = Enum.SortOrder.LayoutOrder
HitLogsLayout.Padding = UDim.new(0, 2)

local hitLogOrder = 0
local function showHitLog(text, color)
    if not Config.Misc.HitLogs then return end
    if not text then return end
    local lbl = Instance.new("TextLabel")
    hitLogOrder = hitLogOrder + 1
    lbl.LayoutOrder = hitLogOrder
    lbl.Size = UDim2.new(1, 0, 0, 18)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = color or Color3.fromRGB(255, 255, 255)
    lbl.TextStrokeColor3 = Color3.new(0, 0, 0)
    lbl.TextStrokeTransparency = 0.3
    lbl.TextXAlignment = Enum.TextXAlignment.Center
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 14
    lbl.TextTransparency = 1
    lbl.Parent = HitLogsHolder
    TweenService:Create(lbl, TweenInfo.new(0.15), { TextTransparency = 0 }):Play()
    task.delay(3, function()
        local tw = TweenService:Create(lbl, TweenInfo.new(0.5), { TextTransparency = 1 })
        tw:Play()
        tw.Completed:Wait()
        pcall(function() lbl:Destroy() end)
    end)
end

--=========================================================
-- GUI
--=========================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FerClient_Rusted"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 100
pcall(function() ScreenGui.Parent = HUI end)
if not ScreenGui.Parent then ScreenGui.Parent = LP:WaitForChild("PlayerGui") end

local Menu = Instance.new("Frame")
Menu.Name = "FerClient_Main"
Menu.Size = UDim2.new(0, 300, 0, 480)
Menu.Position = UDim2.new(0, 20, 0, 60)
Menu.BackgroundColor3 = Theme.Background
Menu.BorderSizePixel = 0
Menu.Active = true
Menu.Draggable = true
Menu.Visible = false
Menu.ClipsDescendants = false
Menu.Parent = ScreenGui

local MenuStroke = Instance.new("UIStroke", Menu)
MenuStroke.Color = Theme.Border
MenuStroke.Thickness = 1

--=========================================================
-- СНЕЖИНКИ
--=========================================================
local SnowContainer = Instance.new("Frame")
SnowContainer.Size = UDim2.new(1, 0, 1, 0)
SnowContainer.BackgroundTransparency = 1
SnowContainer.ClipsDescendants = true
SnowContainer.ZIndex = 2
SnowContainer.Parent = Menu

local SNOW_COUNT = 30
local SNOW_SYMBOLS = { "❄", "❅", "❆", "•", "*" }
local snowflakes = {}

local function createSnowflake()
    local flake = Instance.new("TextLabel")
    flake.BackgroundTransparency = 1
    flake.Text = SNOW_SYMBOLS[math.random(1, #SNOW_SYMBOLS)]
    flake.TextColor3 = Color3.fromRGB(200, 220, 255)
    flake.Font = Enum.Font.GothamBold
    flake.TextSize = math.random(4, 12)
    flake.TextTransparency = math.random(40, 80) / 100
    flake.Size = UDim2.new(0, 20, 0, 20)
    flake.AnchorPoint = Vector2.new(0.5, 0.5)
    flake.ZIndex = 2
    flake.Parent = SnowContainer
    local startX = math.random(0, 100)
    flake.Position = UDim2.new(startX / 100, 0, -0.05, 0)
    snowflakes[#snowflakes + 1] = {
        label = flake, xRatio = startX / 100,
        speed = math.random(15, 40),
        swayAmp = math.random(10, 30) / 1000,
        swayFreq = math.random(15, 40) / 10,
        rotation = math.random(0, 360),
        rotSpeed = (math.random(-60, 60)) / 10,
        phase = math.random(0, 100) / 10,
    }
end

for i = 1, SNOW_COUNT do createSnowflake() end

TrackConn(RunService.RenderStepped:Connect(function(dt)
    if not SnowContainer.Parent then return end
    for _, data in ipairs(snowflakes) do
        local f = data.label
        if f and f.Parent then
            local currentY = f.Position.Y.Scale
            local currentX = data.xRatio
            currentY = currentY + (data.speed / math.max(Menu.AbsoluteSize.Y, 1)) * dt
            data.phase = data.phase + dt * data.swayFreq
            local swayX = math.sin(data.phase) * data.swayAmp
            data.rotation = data.rotation + data.rotSpeed * dt * 60
            if currentY > 1.05 then
                currentY = -0.05
                data.xRatio = math.random(0, 100) / 100
                data.speed = math.random(15, 40)
                data.label.Text = SNOW_SYMBOLS[math.random(1, #SNOW_SYMBOLS)]
                data.label.TextSize = math.random(4, 12)
                data.label.TextTransparency = math.random(40, 80) / 100
            end
            f.Position = UDim2.new(currentX + swayX, 0, currentY, 0)
            f.Rotation = data.rotation
        end
    end
end))

--=========================================================
-- КНОПКА FC
--=========================================================
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 50, 0, 28)
ToggleBtn.Position = UDim2.new(0, 10, 0.5, -14)
ToggleBtn.BackgroundColor3 = Theme.Background
ToggleBtn.BorderSizePixel = 0
ToggleBtn.Text = "FC"
ToggleBtn.TextColor3 = Theme.Accent
ToggleBtn.Font = Theme.FontBold
ToggleBtn.TextSize = 14
ToggleBtn.AutoButtonColor = false
ToggleBtn.Active = true
ToggleBtn.Draggable = true
ToggleBtn.Parent = ScreenGui

local ToggleStroke = Instance.new("UIStroke", ToggleBtn)
ToggleStroke.Color = Theme.Accent
ToggleStroke.Thickness = 1.5

ToggleBtn.MouseEnter:Connect(function()
    ToggleBtn.BackgroundColor3 = Theme.Accent
    ToggleBtn.TextColor3 = Color3.new(1, 1, 1)
end)
ToggleBtn.MouseLeave:Connect(function()
    ToggleBtn.BackgroundColor3 = Theme.Background
    ToggleBtn.TextColor3 = Theme.Accent
end)

--=========================================================
-- ТОПБАР
--=========================================================
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 38)
TopBar.BackgroundColor3 = Theme.Panel
TopBar.BorderSizePixel = 0
TopBar.ZIndex = 3
TopBar.Parent = Menu

local Dot = Instance.new("Frame")
Dot.Size = UDim2.new(0, 8, 0, 8)
Dot.Position = UDim2.new(0, 12, 0.5, -4)
Dot.BackgroundColor3 = Theme.Success
Dot.BorderSizePixel = 0
Dot.ZIndex = 4
Dot.Parent = TopBar
Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)

local Logo = Instance.new("TextLabel")
Logo.Size = UDim2.new(0, 180, 1, 0)
Logo.Position = UDim2.new(0, 28, 0, 0)
Logo.BackgroundTransparency = 1
Logo.Text = "FerClient | Rusted v2"
Logo.TextColor3 = Theme.Text
Logo.Font = Theme.FontBold
Logo.TextSize = 13
Logo.TextXAlignment = Enum.TextXAlignment.Left
Logo.ZIndex = 4
Logo.Parent = TopBar

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 22, 0, 22)
MinimizeBtn.Position = UDim2.new(1, -60, 0, 8)
MinimizeBtn.BackgroundColor3 = Theme.Element
MinimizeBtn.BorderSizePixel = 0
MinimizeBtn.Text = "—"
MinimizeBtn.TextColor3 = Theme.Text
MinimizeBtn.Font = Theme.FontBold
MinimizeBtn.TextSize = 13
MinimizeBtn.AutoButtonColor = false
MinimizeBtn.ZIndex = 4
MinimizeBtn.Parent = TopBar

local UnloadBtn = Instance.new("TextButton")
UnloadBtn.Size = UDim2.new(0, 22, 0, 22)
UnloadBtn.Position = UDim2.new(1, -32, 0, 8)
UnloadBtn.BackgroundColor3 = Theme.Danger
UnloadBtn.BorderSizePixel = 0
UnloadBtn.Text = "✕"
UnloadBtn.TextColor3 = Theme.Text
UnloadBtn.Font = Theme.FontBold
UnloadBtn.TextSize = 13
UnloadBtn.AutoButtonColor = false
UnloadBtn.ZIndex = 4
UnloadBtn.Parent = TopBar

--=========================================================
-- ВКЛАДКИ (4 штуки — убрал GUN)
--=========================================================
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -16, 0, 34)
TabBar.Position = UDim2.new(0, 8, 0, 46)
TabBar.BackgroundColor3 = Theme.Tab
TabBar.BorderSizePixel = 0
TabBar.ZIndex = 3
TabBar.Parent = Menu

local TabLayout = Instance.new("UIListLayout", TabBar)
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabLayout.Padding = UDim.new(0, 3)
TabLayout.Parent = TabBar

local TabPadding = Instance.new("UIPadding", TabBar)
TabPadding.PaddingTop = UDim.new(0, 4)
TabPadding.PaddingLeft = UDim.new(0, 4)
TabPadding.PaddingRight = UDim.new(0, 4)
TabPadding.PaddingBottom = UDim.new(0, 4)
TabPadding.Parent = TabBar

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -16, 1, -140)
Content.Position = UDim2.new(0, 8, 0, 88)
Content.BackgroundTransparency = 1
Content.ZIndex = 3
Content.Parent = Menu

local function MakeScroller()
    local sf = Instance.new("ScrollingFrame")
    sf.Size = UDim2.new(1, 0, 1, 0)
    sf.BackgroundTransparency = 1
    sf.BorderSizePixel = 0
    sf.ScrollBarThickness = 3
    sf.ScrollBarImageColor3 = Theme.Accent
    sf.CanvasSize = UDim2.new(0, 0, 0, 0)
    sf.Visible = false
    sf.ZIndex = 3
    sf.Parent = Content
    local layout = Instance.new("UIListLayout", sf)
    layout.Padding = UDim.new(0, 6)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        sf.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    end)
    return sf, layout
end

local AimScroller = MakeScroller()
local VisualScroller = MakeScroller()
local PlayerScroller = MakeScroller()
local MiscScroller = MakeScroller()

local tabs = {}
local activeTab = nil

local function CreateTab(name, scroller, widthRatio)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(widthRatio, -3, 1, 0)
    btn.BackgroundColor3 = Theme.Tab
    btn.BorderSizePixel = 0
    btn.Text = name
    btn.TextColor3 = Theme.TextDim
    btn.Font = Theme.FontBold
    btn.TextSize = 10
    btn.AutoButtonColor = false
    btn.ZIndex = 4
    btn.Parent = TabBar

    local tab = { Btn = btn, Scroller = scroller, Name = name }
    local function activate()
        if activeTab == tab then return end
        activeTab = tab
        for _, t in ipairs(tabs) do
            local isActive = (t == tab)
            t.Btn.BackgroundColor3 = isActive and Theme.TabActive or Theme.Tab
            t.Btn.TextColor3 = isActive and Theme.Text or Theme.TextDim
            t.Scroller.Visible = isActive
        end
    end
    btn.MouseButton1Click:Connect(activate)
    tabs[#tabs + 1] = tab
    return tab
end

local AimTab = CreateTab("AIM", AimScroller, 0.25)
local VisualTab = CreateTab("VIS", VisualScroller, 0.25)
local PlayerTab = CreateTab("PLR", PlayerScroller, 0.25)
local MiscTab = CreateTab("MISC", MiscScroller, 0.25)

--=========================================================
-- КНОПКА
--=========================================================
local function MakeButton(parent, text, defaultOn, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(90, 15, 15)
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.ZIndex = 3
    btn.Parent = parent

    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = Color3.fromRGB(255, 60, 60)
    stroke.Thickness = 1.5

    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 14, 0, 14)
    indicator.Position = UDim2.new(0, 10, 0.5, -7)
    indicator.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    indicator.BorderSizePixel = 0
    indicator.ZIndex = 4
    indicator.Parent = btn

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -110, 1, 0)
    nameLabel.Position = UDim2.new(0, 32, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = text
    nameLabel.TextColor3 = Color3.fromRGB(240, 245, 255)
    nameLabel.Font = Enum.Font.GothamMedium
    nameLabel.TextSize = 12
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.ZIndex = 4
    nameLabel.Parent = btn

    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(0, 50, 1, 0)
    statusLabel.Position = UDim2.new(1, -54, 0, 0)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "OFF"
    statusLabel.TextColor3 = Color3.fromRGB(255, 60, 60)
    statusLabel.Font = Enum.Font.GothamBold
    statusLabel.TextSize = 11
    statusLabel.ZIndex = 4
    statusLabel.Parent = btn

    local isOn = false

    local function applyState()
        if isOn then
            btn.BackgroundColor3 = Color3.fromRGB(0, 80, 40)
            stroke.Color = Color3.fromRGB(50, 255, 100)
            stroke.Thickness = 2
            indicator.BackgroundColor3 = Color3.fromRGB(50, 255, 100)
            statusLabel.Text = "ON"
            statusLabel.TextColor3 = Color3.fromRGB(50, 255, 100)
        else
            btn.BackgroundColor3 = Color3.fromRGB(90, 15, 15)
            stroke.Color = Color3.fromRGB(255, 60, 60)
            stroke.Thickness = 1.5
            indicator.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
            statusLabel.Text = "OFF"
            statusLabel.TextColor3 = Color3.fromRGB(255, 60, 60)
        end
    end

    isOn = defaultOn or false
    applyState()

    local lastClick = 0
    btn.MouseButton1Click:Connect(function()
        local now = tick()
        if now - lastClick < 0.25 then return end
        lastClick = now
        pcall(callback)
        isOn = not isOn
        applyState()
    end)

    return {
        Button = btn,
        SetOn = function(v)
            isOn = v and true or false
            applyState()
        end
    }
end

--=========================================================
-- СЛАЙДЕР
--=========================================================
local function MakeSlider(parent, text, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 52)
    frame.BackgroundColor3 = Theme.Element
    frame.BorderSizePixel = 0
    frame.ZIndex = 3
    frame.Parent = parent

    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = Theme.Border
    stroke.Thickness = 1

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -60, 0, 22)
    nameLabel.Position = UDim2.new(0, 12, 0, 4)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = text
    nameLabel.TextColor3 = Theme.Text
    nameLabel.Font = Theme.Font
    nameLabel.TextSize = 12
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.ZIndex = 4
    nameLabel.Parent = frame

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0, 50, 0, 22)
    valueLabel.Position = UDim2.new(1, -55, 0, 4)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(default)
    valueLabel.TextColor3 = Theme.Accent
    valueLabel.Font = Theme.FontBold
    valueLabel.TextSize = 12
    valueLabel.ZIndex = 4
    valueLabel.Parent = frame

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -24, 0, 8)
    track.Position = UDim2.new(0, 12, 1, -20)
    track.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    track.BorderSizePixel = 0
    track.ZIndex = 4
    track.Parent = frame

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Theme.Accent
    fill.BorderSizePixel = 0
    fill.ZIndex = 5
    fill.Parent = track

    local knob = Instance.new("Frame")
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = UDim2.new((default - min) / (max - min), 0, 0.5, 0)
    knob.BackgroundColor3 = Theme.Text
    knob.BorderSizePixel = 0
    knob.ZIndex = 6
    knob.Parent = track

    local knobStroke = Instance.new("UIStroke", knob)
    knobStroke.Color = Theme.Accent
    knobStroke.Thickness = 2

    local dragging = false
    local function updateFromX(x)
        local relX = math.clamp(x - track.AbsolutePosition.X, 0, track.AbsoluteSize.X)
        local ratio = relX / math.max(track.AbsoluteSize.X, 1)
        local value = math.floor(min + (max - min) * ratio + 0.5)
        fill.Size = UDim2.new(ratio, 0, 1, 0)
        knob.Position = UDim2.new(ratio, 0, 0.5, 0)
        valueLabel.Text = tostring(value)
        pcall(callback, value)
    end

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateFromX(input.Position.X)
        end
    end)
    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            updateFromX(input.Position.X)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    return { Frame = frame }
end

--=========================================================
-- ДРОПДАУН
--=========================================================
local function MakeDropdown(parent, text, options, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 40)
    frame.BackgroundColor3 = Theme.Element
    frame.BorderSizePixel = 0
    frame.ZIndex = 3
    frame.Parent = parent

    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = Theme.Border
    stroke.Thickness = 1

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -110, 1, 0)
    nameLabel.Position = UDim2.new(0, 14, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = text
    nameLabel.TextColor3 = Theme.Text
    nameLabel.Font = Theme.Font
    nameLabel.TextSize = 12
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.ZIndex = 4
    nameLabel.Parent = frame

    local valueBtn = Instance.new("TextButton")
    valueBtn.Size = UDim2.new(0, 90, 0, 28)
    valueBtn.Position = UDim2.new(1, -98, 0.5, -14)
    valueBtn.BackgroundColor3 = Theme.Accent
    valueBtn.BorderSizePixel = 0
    valueBtn.Text = default
    valueBtn.TextColor3 = Color3.new(1, 1, 1)
    valueBtn.Font = Theme.FontBold
    valueBtn.TextSize = 11
    valueBtn.AutoButtonColor = false
    valueBtn.ZIndex = 4
    valueBtn.Parent = frame

    local idx = 1
    for i, v in ipairs(options) do if v == default then idx = i break end end

    local lastClick = 0
    valueBtn.MouseButton1Click:Connect(function()
        local now = tick()
        if now - lastClick < 0.25 then return end
        lastClick = now
        idx = idx + 1
        if idx > #options then idx = 1 end
        valueBtn.Text = options[idx]
        pcall(callback, options[idx])
    end)

    return { Frame = frame }
end

--=========================================================
-- AIM ВКЛАДКА (без Aim Assist)
--=========================================================
local AimButton = MakeButton(AimScroller, "Aimbot", false, function()
    Config.Aimbot.Enabled = not Config.Aimbot.Enabled
end)

local AutoAimBtn = MakeButton(AimScroller, "Auto Aim", false, function()
    Config.Aimbot.AutoAim = not Config.Aimbot.AutoAim
end)

local SilentBtn = MakeButton(AimScroller, "Silent Aim", false, function()
    Config.Silent.Enabled = not Config.Silent.Enabled
end)

local SilentAutoShootBtn = MakeButton(AimScroller, "Silent Auto Shoot", true, function()
    Config.Silent.AutoShoot = not Config.Silent.AutoShoot
end)

local PredictBtn = MakeButton(AimScroller, "Prediction", true, function()
    Config.Aimbot.Prediction = not Config.Aimbot.Prediction
    Config.Silent.Prediction = Config.Aimbot.Prediction
end)

local FovButton = MakeButton(AimScroller, "FOV Circle", true, function()
    Config.Aimbot.ShowFOV = not Config.Aimbot.ShowFOV
    Config.Silent.ShowCircle = Config.Aimbot.ShowFOV
end)

local VisibleBtn = MakeButton(AimScroller, "Visible Check", false, function()
    Config.Aimbot.Visible = not Config.Aimbot.Visible
    Config.Silent.Visible = Config.Aimbot.Visible
end)

local TeamBtn = MakeButton(AimScroller, "Team Check", true, function()
    Config.Aimbot.TeamCheck = not Config.Aimbot.TeamCheck
    Config.Silent.TeamCheck = Config.Aimbot.TeamCheck
end)

MakeDropdown(AimScroller, "Target Part", { "Head", "HumanoidRootPart", "Torso" }, Config.Aimbot.TargetPart, function(v)
    Config.Aimbot.TargetPart = v
    Config.Silent.TargetPart = v
end)

MakeSlider(AimScroller, "FOV Circle Radius", 30, 600, Config.Aimbot.FOV, function(v)
    Config.Aimbot.FOV = v
    Config.Silent.FOV = v
    FovCircle.Size = UDim2.new(0, v * 2, 0, v * 2)
end)

MakeSlider(AimScroller, "Smoothness x100", 10, 100, math.floor(Config.Aimbot.Smoothness * 100), function(v)
    Config.Aimbot.Smoothness = v / 100
end)

MakeSlider(AimScroller, "Max Distance", 100, 2000, Config.Aimbot.MaxDistance, function(v)
    Config.Aimbot.MaxDistance = v
    Config.Silent.MaxDistance = v
end)

--=========================================================
-- VISUAL ВКЛАДКА
--=========================================================
local ESPButton = MakeButton(VisualScroller, "ESP", true, function()
    Config.ESP.Enabled = not Config.ESP.Enabled
end)

local BoxButton = MakeButton(VisualScroller, "Boxes", true, function()
    Config.ESP.Box = not Config.ESP.Box
end)

local NameButton = MakeButton(VisualScroller, "Names", true, function()
    Config.ESP.Name = not Config.ESP.Name
end)

local DistButton = MakeButton(VisualScroller, "Distance", true, function()
    Config.ESP.Distance = not Config.ESP.Distance
end)

local TracerButton = MakeButton(VisualScroller, "Tracers", true, function()
    Config.ESP.Tracer = not Config.ESP.Tracer
end)

local HealthButton = MakeButton(VisualScroller, "Health Bar", true, function()
    Config.ESP.Health = not Config.ESP.Health
end)

local FullbrightBtn = MakeButton(VisualScroller, "Fullbright", false, function()
    Config.Visual.Fullbright = not Config.Visual.Fullbright
end)

local XRayBtn = MakeButton(VisualScroller, "X-Ray", false, function()
    Config.Visual.XRay = not Config.Visual.XRay
end)

MakeSlider(VisualScroller, "ESP Max Distance", 200, 3000, Config.ESP.MaxDistance, function(v)
    Config.ESP.MaxDistance = v
end)

MakeSlider(VisualScroller, "X-Ray x100", 10, 90, math.floor(Config.Visual.XRayTransparency * 100), function(v)
    Config.Visual.XRayTransparency = v / 100
end)

--=========================================================
-- PLAYER ВКЛАДКА
--=========================================================
local SpeedBtn = MakeButton(PlayerScroller, "Speed Hack", false, function()
    Config.Player.SpeedEnabled = not Config.Player.SpeedEnabled
end)

MakeSlider(PlayerScroller, "Speed (10-100)", 10, 100, Config.Player.SpeedValue, function(v)
    Config.Player.SpeedValue = v
end)

local NoclipBtn = MakeButton(PlayerScroller, "Noclip", false, function()
    Config.Player.Noclip = not Config.Player.Noclip
end)

local NoFallBtn = MakeButton(PlayerScroller, "No Fall Damage", false, function()
    Config.Player.NoFallDamage = not Config.Player.NoFallDamage
end)

local FPSBoostBtn = MakeButton(PlayerScroller, "FPS Boost", false, function()
    Config.Visual.FPSBoost = not Config.Visual.FPSBoost
end)

--=========================================================
-- MISC ВКЛАДКА
--=========================================================
local InfJumpBtn = MakeButton(MiscScroller, "Infinite Jump", false, function()
    Config.Misc.InfiniteJump = not Config.Misc.InfiniteJump
end)

local HitLogsBtn = MakeButton(MiscScroller, "Hit Logs", true, function()
    Config.Misc.HitLogs = not Config.Misc.HitLogs
end)

--=========================================================
-- HOLD TO AIM
--=========================================================
local TriggerBtn = Instance.new("TextButton")
TriggerBtn.Size = UDim2.new(1, -16, 0, 42)
TriggerBtn.Position = UDim2.new(0, 8, 1, -50)
TriggerBtn.BackgroundColor3 = Theme.Accent
TriggerBtn.BorderSizePixel = 0
TriggerBtn.Text = "HOLD TO AIM"
TriggerBtn.TextColor3 = Color3.new(1, 1, 1)
TriggerBtn.Font = Theme.FontBold
TriggerBtn.TextSize = 13
TriggerBtn.AutoButtonColor = false
TriggerBtn.ZIndex = 3
TriggerBtn.Parent = Menu

local TrigStroke = Instance.new("UIStroke", TriggerBtn)
TrigStroke.Color = Theme.Border
TrigStroke.Thickness = 1

local function setTrig(active)
    Config.Aimbot.TriggerActive = active
    TriggerBtn.BackgroundColor3 = active and Color3.fromRGB(120, 180, 255) or Theme.Accent
end

TriggerBtn.MouseButton1Down:Connect(function() setTrig(true) end)
TriggerBtn.MouseButton1Up:Connect(function() setTrig(false) end)
TriggerBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then setTrig(true) end
end)
TriggerBtn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then setTrig(false) end
end)
TriggerBtn.MouseLeave:Connect(function() setTrig(false) end)

--=========================================================
-- СВОРАЧИВАНИЕ + FC
--=========================================================
local isMinimized = false
local function toggleMinimize()
    isMinimized = not isMinimized
    Menu.Size = isMinimized and UDim2.new(0, 300, 0, 38) or UDim2.new(0, 300, 0, 480)
    TabBar.Visible = not isMinimized
    Content.Visible = not isMinimized
    TriggerBtn.Visible = not isMinimized
end

local lastMinClick = 0
MinimizeBtn.MouseButton1Click:Connect(function()
    local now = tick()
    if now - lastMinClick < 0.25 then return end
    lastMinClick = now
    toggleMinimize()
end)

local lastToggle = 0
ToggleBtn.MouseButton1Click:Connect(function()
    local now = tick()
    if now - lastToggle < 0.3 then return end
    lastToggle = now
    Menu.Visible = not Menu.Visible
end)

--=========================================================
-- UNLOAD
--=========================================================
local ESPCache = {}

local function Unload()
    if getgenv().FerClient_Rusted_Unloading then return end
    getgenv().FerClient_Rusted_Unloading = true

    pcall(function() RunService:UnbindFromRenderStep("FerClient_Rusted_Aimbot") end)

    if ESPCache then
        for _, d in pairs(ESPCache) do
            for _, o in pairs(d) do
                pcall(function() o:Remove() end)
            end
        end
    end

    for _, c in ipairs(Connections) do
        pcall(function() c:Disconnect() end)
    end
    Connections = {}

    pcall(function()
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.GlobalShadows = true
    end)

    pcall(function() ScreenGui:Destroy() end)
    pcall(function() HitLogsGui:Destroy() end)

    getgenv().FerClient_Rusted_Loaded = false
    getgenv().FerClient_Rusted_Unloading = false
    print("[FerClient] Rusted v2 — Выгружен.")
end

local lastUnloadClick = 0
UnloadBtn.MouseButton1Click:Connect(function()
    local now = tick()
    if now - lastUnloadClick < 0.3 then return end
    lastUnloadClick = now
    Unload()
end)

getgenv().FerClient_Rusted_Unload = Unload

--=========================================================
-- FOV КРУГ (главная фишка — круг для Silent Aim)
--=========================================================
local FovCircle = Instance.new("Frame")
FovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FovCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
FovCircle.Size = UDim2.new(0, Config.Aimbot.FOV * 2, 0, Config.Aimbot.FOV * 2)
FovCircle.BackgroundTransparency = 1
FovCircle.BorderSizePixel = 0
FovCircle.Visible = false
FovCircle.Parent = ScreenGui
Instance.new("UICorner", FovCircle).CornerRadius = UDim.new(1, 0)

local FovStroke = Instance.new("UIStroke", FovCircle)
FovStroke.Color = Theme.Accent
FovStroke.Thickness = 2
FovStroke.Transparency = 0.2

--=========================================================
-- ESP
--=========================================================
local function CreateESP(player)
    if player == LP or ESPCache[player] then return end
    if not hasDrawing then return end

    local box = Drawing.new("Square")
    box.Visible = false; box.Color = Config.ESP.Color
    box.Thickness = 1; box.Filled = false; box.Transparency = 1

    local boxO = Drawing.new("Square")
    boxO.Visible = false; boxO.Color = Color3.new(0, 0, 0)
    boxO.Thickness = 3; boxO.Filled = false; boxO.Transparency = 1

    local nm = Drawing.new("Text")
    nm.Visible = false; nm.Center = true; nm.Outline = true
    nm.OutlineColor = Color3.new(0, 0, 0); nm.Color = Color3.new(1, 1, 1)
    nm.Size = 14; nm.Font = 2

    local dst = Drawing.new("Text")
    dst.Visible = false; dst.Center = true; dst.Outline = true
    dst.OutlineColor = Color3.new(0, 0, 0); dst.Color = Color3.new(1, 1, 1)
    dst.Size = 12; dst.Font = 2

    local hp = Drawing.new("Square")
    hp.Visible = false; hp.Thickness = 1; hp.Filled = true
    hp.Color = Color3.fromRGB(0, 255, 0)

    local hpBg = Drawing.new("Square")
    hpBg.Visible = false; hpBg.Thickness = 1; hpBg.Filled = true
    hpBg.Color = Color3.fromRGB(40, 40, 40)

    local tr = Drawing.new("Line")
    tr.Visible = false; tr.Thickness = 1
    tr.Color = Config.ESP.Color; tr.Transparency = 1

    ESPCache[player] = {
        Box = box, BoxOutline = boxO, Name = nm, Dist = dst,
        Health = hp, HealthBg = hpBg, Tracer = tr
    }
end

local function RemoveESP(player)
    local d = ESPCache[player]
    if not d then return end
    for _, o in pairs(d) do pcall(function() o:Remove() end) end
    ESPCache[player] = nil
end

--=========================================================
-- AIMBOT / SILENT LOGIC
--=========================================================
local function IsTeammate(plr)
    if not plr.Team or not LP.Team then return false end
    return plr.Team == LP.Team
end

local function IsVisible(part, character)
    local origin = Camera.CFrame.Position
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { LP.Character, Camera, character }
    params.IgnoreWater = true
    local result = Workspace:Raycast(origin, part.Position - origin, params)
    if not result then return true end
    return result.Instance and result.Instance:IsDescendantOf(character)
end

local function GetPredictedPosition(part, predTime)
    local velocity = part.AssemblyLinearVelocity
    if not velocity then return part.Position end
    return part.Position + velocity * predTime
end

local function GetClosestTarget(fovRange, maxRange)
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local closest, closestDist, closestPos = nil, fovRange, nil
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then
            if not (Config.Aimbot.TeamCheck and IsTeammate(plr)) then
                local char = plr.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    local part = char:FindFirstChild(Config.Aimbot.TargetPart)
                    if part then
                        local predPos = Config.Aimbot.Prediction and GetPredictedPosition(part, Config.Aimbot.PredictionX) or part.Position
                        local sp, onScreen = Camera:WorldToViewportPoint(predPos)
                        if onScreen then
                            local d3 = (Camera.CFrame.Position - predPos).Magnitude
                            if d3 <= maxRange then
                                local sd = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                                if sd < closestDist then
                                    if not Config.Aimbot.Visible or IsVisible(part, char) then
                                        closestDist = sd
                                        closest = part
                                        closestPos = predPos
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return closest, closestPos
end

-- SILENT AIM — только цели в FOV-кружке
local function GetSilentTarget()
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local closest, closestPos, closestDist = nil, nil, Config.Silent.FOV

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then
            if not (Config.Silent.TeamCheck and IsTeammate(plr)) then
                local char = plr.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    local part = char:FindFirstChild(Config.Silent.TargetPart)
                    if part then
                        local predPos = Config.Silent.Prediction
                            and GetPredictedPosition(part, Config.Silent.PredictionX)
                            or part.Position

                        local sp, onScreen = Camera:WorldToViewportPoint(predPos)
                        if onScreen then
                            local screenDist = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                            local worldDist = (Camera.CFrame.Position - predPos).Magnitude

                            -- Жёсткая проверка: цель ВНУТРИ кружка FOV
                            if screenDist <= Config.Silent.FOV and worldDist <= Config.Silent.MaxDistance then
                                if not Config.Silent.Visible or IsVisible(part, char) then
                                    if screenDist < closestDist then
                                        closestDist = screenDist
                                        closest = part
                                        closestPos = predPos
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return closest, closestPos
end

local silentTarget = nil
local silentTargetPos = nil

local AIM_PRIORITY = Enum.RenderPriority.Camera.Value + 10

local function AimStep()
    -- Обычный Aimbot
    local shouldAim = false
    if Config.Aimbot.Enabled then
        if Config.Aimbot.AutoAim then shouldAim = true
        elseif Config.Aimbot.TriggerActive then shouldAim = true
        elseif UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then shouldAim = true
        end
    end

    if shouldAim then
        local target, predPos = GetClosestTarget(Config.Aimbot.FOV, Config.Aimbot.MaxDistance)
        if target and predPos then
            local targetCF = CFrame.new(Camera.CFrame.Position, predPos)
            Camera.CFrame = Camera.CFrame:Lerp(targetCF, Config.Aimbot.Smoothness)

            if Config.Aimbot.AutoFire then
                local now = tick()
                if now - Config.Aimbot.LastFire >= Config.Aimbot.AutoFireDelay then
                    Config.Aimbot.LastFire = now
                    pcall(function()
                        local vim = game:GetService("VirtualInputManager")
                        vim:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                        task.wait(0.02)
                        vim:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                    end)
                end
            end
        end
    end

    -- SILENT AIM (главное)
    if Config.Silent.Enabled then
        local st, sp = GetSilentTarget()
        silentTarget = st
        silentTargetPos = sp

        -- Auto Shoot когда цель в кружке
        if Config.Silent.AutoShoot and st and sp then
            local now = tick()
            if now - Config.Silent.LastShoot >= Config.Silent.AutoShootDelay then
                Config.Silent.LastShoot = now
                pcall(function()
                    local vim = game:GetService("VirtualInputManager")
                    vim:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                    task.wait(0.02)
                    vim:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                end)
            end
        end
    else
        silentTarget = nil
        silentTargetPos = nil
    end
end

RunService:BindToRenderStep("FerClient_Rusted_Aimbot", AIM_PRIORITY, AimStep)

-- SILENT AIM HOOK — подмена координат выстрела
pcall(function()
    if hookmetamethod and newcclosure then
        local oldNC
        oldNC = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
            local method = getnamecallmethod()
            if (method == "FireServer" or method == "InvokeServer")
                and Config.Silent.Enabled and silentTargetPos then
                local args = {...}
                local newArgs = {}
                for i, v in ipairs(args) do
                    if typeof(v) == "Vector3" then
                        newArgs[i] = silentTargetPos
                    elseif typeof(v) == "CFrame" then
                        newArgs[i] = CFrame.new(silentTargetPos)
                    else
                        newArgs[i] = v
                    end
                end
                return oldNC(self, table.unpack(newArgs))
            end
            return oldNC(self, ...)
        end))
    end
end)

--=========================================================
-- SPEED HACK
--=========================================================
local savedWalkSpeed = 16

TrackConn(RunService.Heartbeat:Connect(function()
    local char = LP.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    if Config.Player.SpeedEnabled then
        hum.WalkSpeed = Config.Player.SpeedValue
    else
        if hum.WalkSpeed ~= savedWalkSpeed then
            hum.WalkSpeed = savedWalkSpeed
        end
    end
end))

TrackConn(LP.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid", 5)
    if hum then
        savedWalkSpeed = hum.WalkSpeed
        if Config.Player.SpeedEnabled then
            hum.WalkSpeed = Config.Player.SpeedValue
        end
    end
end))

--=========================================================
-- NOCLIP
--=========================================================
local originalStates = {}

local function enableNoclip()
    local char = LP.Character
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            originalStates[part] = part.CanCollide
            part.CanCollide = false
        end
    end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
    end
end

TrackConn(RunService.Heartbeat:Connect(function()
    if Config.Player.Noclip then
        local char = LP.Character
        if not char then return end
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                if originalStates[part] == nil then
                    originalStates[part] = part.CanCollide
                end
                part.CanCollide = false
            end
        end
    end
end))

TrackConn(LP.CharacterRemoving:Connect(function()
    originalStates = {}
end))

TrackConn(LP.CharacterAdded:Connect(function()
    task.wait(0.5)
    if Config.Player.Noclip then enableNoclip() end
end))

--=========================================================
-- NO FALL DAMAGE
--=========================================================
TrackConn(RunService.Heartbeat:Connect(function()
    if not Config.Player.NoFallDamage then return end
    local char = LP.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
    end
end))

--=========================================================
-- FULLBRIGHT
--=========================================================
TrackConn(RunService.Heartbeat:Connect(function()
    if not Config.Visual.Fullbright then return end
    pcall(function()
        Lighting.Brightness = 5
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.fromRGB(200, 200, 200)
        Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
    end)
end))

--=========================================================
-- X-RAY
--=========================================================
TrackConn(RunService.Heartbeat:Connect(function()
    if not Config.Visual.XRay then return end
    pcall(function()
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and not obj:IsDescendantOf(LP.Character) then
                obj.LocalTransparencyModifier = Config.Visual.XRayTransparency
            end
        end
    end)
end))

--=========================================================
-- FPS BOOST
--=========================================================
local fpsBoostApplied = false

local function applyFPSBoost()
    if fpsBoostApplied then return end
    fpsBoostApplied = true
    pcall(function()
        for _, obj in ipairs(Lighting:GetChildren()) do
            if obj:IsA("BloomEffect") or obj:IsA("BlurEffect")
                or obj:IsA("SunRaysEffect") or obj:IsA("ColorCorrectionEffect")
                or obj:IsA("DepthOfFieldEffect") then
                obj.Enabled = false
            end
        end
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 1000
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") or obj:IsA("Trail")
                or obj:IsA("Smoke") or obj:IsA("Fire")
                or obj:IsA("Sparkles") then
                obj.Enabled = false
            elseif obj:IsA("BasePart") then
                obj.Material = Enum.Material.Plastic
                obj.Reflectance = 0
                obj.CastShadow = false
            end
        end
    end)
    pcall(function()
        setfflag("DFIntTaskSchedulerTargetFps", "240")
        setfflag("FFlagDisablePostFx", "true")
        setfflag("FIntRenderShadowIntensity", "0")
    end)
end

local function removeFPSBoost()
    fpsBoostApplied = false
    pcall(function()
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.GlobalShadows = true
    end)
end

TrackConn(RunService.Heartbeat:Connect(function()
    if Config.Visual.FPSBoost then applyFPSBoost()
    elseif fpsBoostApplied then removeFPSBoost() end
end))

--=========================================================
-- INFINITE JUMP
--=========================================================
TrackConn(UIS.JumpRequest:Connect(function()
    if not Config.Misc.InfiniteJump then return end
    local char = LP.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end))

--=========================================================
-- ESP ЦИКЛ + FOV КРУГ
--=========================================================
TrackConn(RunService.RenderStepped:Connect(function()
    -- FOV круг — показывается если включен Aimbot ИЛИ Silent Aim
    if Config.Aimbot.ShowFOV and (Config.Aimbot.Enabled or Config.Silent.Enabled) then
        FovCircle.Visible = true
        FovCircle.Size = UDim2.new(0, Config.Aimbot.FOV * 2, 0, Config.Aimbot.FOV * 2)
        FovCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
        -- Если Silent Aim — меняем цвет круга на зелёный (индикатор что цель внутри)
        if Config.Silent.Enabled and silentTarget then
            FovStroke.Color = Theme.Success
        elseif Config.Silent.Enabled then
            FovStroke.Color = Theme.Accent
        else
            FovStroke.Color = Theme.Accent
        end
    else
        FovCircle.Visible = false
    end

    if hasDrawing then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LP then
                local d = ESPCache[plr]
                if not d then CreateESP(plr); d = ESPCache[plr] end

                local char = plr.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                local root = char and char:FindFirstChild("HumanoidRootPart")

                if not Config.ESP.Enabled or not root or not hum or hum.Health <= 0 then
                    for _, o in pairs(d) do o.Visible = false end
                    continue
                end

                local d3 = (Camera.CFrame.Position - root.Position).Magnitude
                if d3 > Config.ESP.MaxDistance then
                    for _, o in pairs(d) do o.Visible = false end
                    continue
                end

                local sTop, onT = Camera:WorldToViewportPoint(root.Position + Vector3.new(0, 3, 0))
                local sBot, onB = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
                if not (onT and onB) then
                    for _, o in pairs(d) do o.Visible = false end
                    continue
                end

                local height = math.abs(sBot.Y - sTop.Y)
                local width = height * 0.55
                local x, y = sTop.X - width / 2, sTop.Y

                d.Box.Visible = Config.ESP.Box
                d.Box.Size = Vector2.new(width, height)
                d.Box.Position = Vector2.new(x, y)

                d.BoxOutline.Visible = Config.ESP.Box
                d.BoxOutline.Size = Vector2.new(width, height)
                d.BoxOutline.Position = Vector2.new(x, y)

                d.Name.Visible = Config.ESP.Name
                d.Name.Text = plr.Name
                d.Name.Position = Vector2.new(sTop.X, y - 16)

                d.Dist.Visible = Config.ESP.Distance
                d.Dist.Text = math.floor(d3) .. "m"
                d.Dist.Position = Vector2.new(sTop.X, y + height + 2)

                if Config.ESP.Health then
                    local pct = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
                    d.HealthBg.Visible = true
                    d.HealthBg.Size = Vector2.new(3, height)
                    d.HealthBg.Position = Vector2.new(x - 5, y)

                    d.Health.Visible = true
                    d.Health.Size = Vector2.new(3, height * pct)
                    d.Health.Position = Vector2.new(x - 5, y + height - height * pct)

                    d.Health.Color = pct > 0.6 and Color3.fromRGB(0, 255, 0)
                        or pct > 0.3 and Color3.fromRGB(255, 200, 0)
                        or Color3.fromRGB(255, 0, 0)
                else
                    d.Health.Visible = false
                    d.HealthBg.Visible = false
                end

                d.Tracer.Visible = Config.ESP.Tracer
                if Config.ESP.Tracer then
                    d.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    d.Tracer.To = Vector2.new(sBot.X, sBot.Y)
                end
            end
        end
    end
end))

TrackConn(Players.PlayerAdded:Connect(CreateESP))
TrackConn(Players.PlayerRemoving:Connect(RemoveESP))
for _, plr in ipairs(Players:GetPlayers()) do CreateESP(plr) end

--=========================================================
-- ХОТКЕИ
--=========================================================
TrackConn(UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.F1 then
        Config.ESP.Enabled = not Config.ESP.Enabled
        ESPButton.SetOn(Config.ESP.Enabled)
    elseif input.KeyCode == Enum.KeyCode.F2 then
        Config.Aimbot.Enabled = not Config.Aimbot.Enabled
        AimButton.SetOn(Config.Aimbot.Enabled)
    elseif input.KeyCode == Enum.KeyCode.F3 then
        Config.Aimbot.AutoAim = not Config.Aimbot.AutoAim
        AutoAimBtn.SetOn(Config.Aimbot.AutoAim)
    elseif input.KeyCode == Enum.KeyCode.F4 then
        Config.Misc.InfiniteJump = not Config.Misc.InfiniteJump
        InfJumpBtn.SetOn(Config.Misc.InfiniteJump)
    elseif input.KeyCode == Enum.KeyCode.F5 then
        Config.Silent.Enabled = not Config.Silent.Enabled
        SilentBtn.SetOn(Config.Silent.Enabled)
    elseif input.KeyCode == Enum.KeyCode.F7 then
        Config.Player.SpeedEnabled = not Config.Player.SpeedEnabled
        SpeedBtn.SetOn(Config.Player.SpeedEnabled)
    elseif input.KeyCode == Enum.KeyCode.F8 then
        Config.Player.Noclip = not Config.Player.Noclip
        NoclipBtn.SetOn(Config.Player.Noclip)
    elseif input.KeyCode == Enum.KeyCode.RightShift then
        Menu.Visible = not Menu.Visible
    elseif input.KeyCode == Enum.KeyCode.Delete then
        Unload()
    end
end))

AimTab.Btn.BackgroundColor3 = Theme.TabActive
AimTab.Btn.TextColor3 = Theme.Text
AimScroller.Visible = true
activeTab = AimTab

print("[FerClient] Rusted v2 загружен")
print("Silent Aim работает через FOV кружок")
print("F1=ESP F2=Aim F3=AutoAim F4=InfJump F5=Silent F7=Speed F8=Noclip")
