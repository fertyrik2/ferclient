--[[
    FerClient | Decay v2.1
    Меню: как в Rusted v5.2 (Null-wave style)
    Функции: Decay [HALF WALLS]
]]

if getgenv().FerClient_Decay_Loaded then
    if getgenv().FerClient_Decay_Unload then pcall(getgenv().FerClient_Decay_Unload) end
    task.wait(0.2)
end
getgenv().FerClient_Decay_Loaded = true

if not game:IsLoaded() then game.Loaded:Wait() end

local HUI = (gethui and gethui()) or game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local Camera = Workspace.CurrentCamera
local LP = Players.LocalPlayer

--=========================================================
-- ТЕМА (Null-wave)
--=========================================================
local Theme = {
    Background   = Color3.fromRGB(15, 15, 25),
    Panel        = Color3.fromRGB(20, 20, 35),
    Element      = Color3.fromRGB(28, 28, 45),
    Accent       = Color3.fromRGB(150, 120, 240),
    On           = Color3.fromRGB(150, 120, 240),
    Off          = Color3.fromRGB(50, 50, 70),
    Text         = Color3.fromRGB(230, 230, 240),
    TextDim      = Color3.fromRGB(120, 120, 140),
    Border       = Color3.fromRGB(40, 40, 60),
    Font         = Enum.Font.Gotham,
    FontBold     = Enum.Font.GothamBold,
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
    },
    Player = {
        NoFallDamage = false,
        SpeedEnabled = false, SpeedValue = 30,
        Noclip = false,
    },
    Visual = {
        Fullbright = false, XRay = false, FPSBoost = false,
    },
    Misc = {
        InfiniteJump = false,
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

local function chatMessage(text, color)
    pcall(function()
        StarterGui:SetCore("ChatMakeSystemMessage", {
            Text = text,
            Color = color or Theme.Accent,
            Font = Enum.Font.GothamBold,
        })
    end)
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
-- ГЛАВНЫЙ GUI
--=========================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FerClient_Decay"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 100
pcall(function() ScreenGui.Parent = HUI end)
if not ScreenGui.Parent then ScreenGui.Parent = LP:WaitForChild("PlayerGui") end

local Menu = Instance.new("Frame")
Menu.Name = "FerClient_Main"
Menu.Size = UDim2.new(0, 450, 0, 280)
Menu.Position = UDim2.new(0.5, -225, 0.5, -140)
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

local SNOW_COUNT = 20
local SNOW_SYMBOLS = { "❄", "❅", "❆", "•", "*" }
local snowflakes = {}

local function createSnowflake()
    local flake = Instance.new("TextLabel")
    flake.BackgroundTransparency = 1
    flake.Text = SNOW_SYMBOLS[math.random(1, #SNOW_SYMBOLS)]
    flake.TextColor3 = Color3.fromRGB(180, 160, 240)
    flake.Font = Enum.Font.GothamBold
    flake.TextSize = math.random(4, 10)
    flake.TextTransparency = math.random(50, 85) / 100
    flake.Size = UDim2.new(0, 20, 0, 20)
    flake.AnchorPoint = Vector2.new(0.5, 0.5)
    flake.ZIndex = 2
    flake.Parent = SnowContainer
    local startX = math.random(0, 100)
    flake.Position = UDim2.new(startX / 100, 0, -0.05, 0)
    snowflakes[#snowflakes + 1] = {
        label = flake, xRatio = startX / 100,
        speed = math.random(15, 35),
        swayAmp = math.random(10, 25) / 1000,
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
                data.speed = math.random(15, 35)
                data.label.Text = SNOW_SYMBOLS[math.random(1, #SNOW_SYMBOLS)]
                data.label.TextSize = math.random(4, 10)
                data.label.TextTransparency = math.random(50, 85) / 100
            end
            f.Position = UDim2.new(currentX + swayX, 0, currentY, 0)
            f.Rotation = data.rotation
        end
    end
end))

--=========================================================
-- ЗАГОЛОВОК
--=========================================================
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 26)
TopBar.BackgroundColor3 = Theme.Background
TopBar.BorderSizePixel = 0
TopBar.ZIndex = 3
TopBar.Parent = Menu

local Logo = Instance.new("TextLabel")
Logo.Size = UDim2.new(1, -70, 1, 0)
Logo.Position = UDim2.new(0, 10, 0, 0)
Logo.BackgroundTransparency = 1
Logo.Text = "FerClient.lua"
Logo.TextColor3 = Theme.Text
Logo.Font = Theme.FontBold
Logo.TextSize = 12
Logo.TextXAlignment = Enum.TextXAlignment.Left
Logo.ZIndex = 4
Logo.Parent = TopBar

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 18, 0, 18)
MinimizeBtn.Position = UDim2.new(1, -46, 0, 4)
MinimizeBtn.BackgroundTransparency = 1
MinimizeBtn.Text = "—"
MinimizeBtn.TextColor3 = Theme.TextDim
MinimizeBtn.Font = Theme.FontBold
MinimizeBtn.TextSize = 12
MinimizeBtn.AutoButtonColor = false
MinimizeBtn.ZIndex = 4
MinimizeBtn.Parent = TopBar

local UnloadBtn = Instance.new("TextButton")
UnloadBtn.Size = UDim2.new(0, 18, 0, 18)
UnloadBtn.Position = UDim2.new(1, -24, 0, 4)
UnloadBtn.BackgroundTransparency = 1
UnloadBtn.Text = "✕"
UnloadBtn.TextColor3 = Theme.TextDim
UnloadBtn.Font = Theme.FontBold
UnloadBtn.TextSize = 11
UnloadBtn.AutoButtonColor = false
UnloadBtn.ZIndex = 4
UnloadBtn.Parent = TopBar

--=========================================================
-- КОНТЕНТ (5 вкладок с переключением)
--=========================================================
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -20, 1, -54)
Content.Position = UDim2.new(0, 10, 0, 30)
Content.BackgroundTransparency = 1
Content.ZIndex = 3
Content.Parent = Menu

local function MakeTabContent()
    local sf = Instance.new("ScrollingFrame")
    sf.Size = UDim2.new(1, 0, 1, 0)
    sf.BackgroundTransparency = 1
    sf.BorderSizePixel = 0
    sf.ScrollBarThickness = 2
    sf.ScrollBarImageColor3 = Theme.Accent
    sf.CanvasSize = UDim2.new(0, 0, 0, 0)
    sf.Visible = false
    sf.ZIndex = 3
    sf.Parent = Content

    local layout = Instance.new("UIListLayout", sf)
    layout.Padding = UDim.new(0, 4)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        sf.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    end)

    return sf, layout
end

local CombatContent = MakeTabContent()
local VisualContent = MakeTabContent()
local MovementContent = MakeTabContent()
local MiscContent = MakeTabContent()
local SettingsContent = MakeTabContent()

--=========================================================
-- НИЖНИЕ ВКЛАДКИ
--=========================================================
local BottomTabs = Instance.new("Frame")
BottomTabs.Size = UDim2.new(1, 0, 0, 22)
BottomTabs.Position = UDim2.new(0, 0, 1, -24)
BottomTabs.BackgroundColor3 = Theme.Background
BottomTabs.BorderSizePixel = 0
BottomTabs.ZIndex = 3
BottomTabs.Parent = Menu

local BottomLayout = Instance.new("UIListLayout", BottomTabs)
BottomLayout.FillDirection = Enum.FillDirection.Horizontal
BottomLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
BottomLayout.SortOrder = Enum.SortOrder.LayoutOrder
BottomLayout.Padding = UDim.new(0, 15)
BottomLayout.Parent = BottomTabs

local tabs = {}

local function CreateBottomTab(name, contentFrame)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 60, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = name
    btn.TextColor3 = Theme.TextDim
    btn.Font = Theme.Font
    btn.TextSize = 10
    btn.AutoButtonColor = false
    btn.ZIndex = 4
    btn.Parent = BottomTabs

    local tab = { Btn = btn, Name = name, Content = contentFrame }
    btn.MouseButton1Click:Connect(function()
        for _, t in ipairs(tabs) do
            t.Btn.TextColor3 = Theme.TextDim
            t.Btn.Font = Theme.Font
            if t.Content then t.Content.Visible = false end
        end
        btn.TextColor3 = Theme.Accent
        btn.Font = Theme.FontBold
        if contentFrame then contentFrame.Visible = true end
    end)
    tabs[#tabs + 1] = tab
    return tab
end

local CombatTab = CreateBottomTab("Combat", CombatContent)
local VisualTab = CreateBottomTab("Visual", VisualContent)
local MovementTab = CreateBottomTab("Movement", MovementContent)
local MiscTab = CreateBottomTab("Misc", MiscContent)
local SettingsTab = CreateBottomTab("Settings", SettingsContent)

CombatTab.Btn.TextColor3 = Theme.Accent
CombatTab.Btn.Font = Theme.FontBold
CombatContent.Visible = true

--=========================================================
-- ТУМБЛЕР
--=========================================================
local function MakeToggle(parent, text, defaultOn, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 22)
    frame.BackgroundTransparency = 1
    frame.ZIndex = 3
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -45, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Theme.Text
    label.Font = Theme.Font
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 4
    label.Parent = frame

    local track = Instance.new("Frame")
    track.Size = UDim2.new(0, 28, 0, 14)
    track.Position = UDim2.new(1, -30, 0.5, -7)
    track.BackgroundColor3 = Theme.Off
    track.BorderSizePixel = 0
    track.ZIndex = 4
    track.Parent = frame
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.AnchorPoint = Vector2.new(0, 0.5)
    knob.Size = UDim2.new(0, 10, 0, 10)
    knob.Position = UDim2.new(0, 2, 0.5, 0)
    knob.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
    knob.BorderSizePixel = 0
    knob.ZIndex = 5
    knob.Parent = track
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local isOn = false
    local function applyState()
        if isOn then
            track.BackgroundColor3 = Theme.On
            TweenService:Create(knob, TweenInfo.new(0.15), { Position = UDim2.new(1, -12, 0.5, 0) }):Play()
        else
            track.BackgroundColor3 = Theme.Off
            TweenService:Create(knob, TweenInfo.new(0.15), { Position = UDim2.new(0, 2, 0.5, 0) }):Play()
        end
    end

    isOn = defaultOn or false
    applyState()

    local click = Instance.new("TextButton")
    click.Size = UDim2.new(1, 0, 1, 0)
    click.BackgroundTransparency = 1
    click.Text = ""
    click.AutoButtonColor = false
    click.ZIndex = 6
    click.Parent = frame

    local lastClick = 0
    click.MouseButton1Click:Connect(function()
        local now = tick()
        if now - lastClick < 0.25 then return end
        lastClick = now
        pcall(callback)
        isOn = not isOn
        applyState()
    end)

    return { Frame = frame, SetOn = function(v) isOn = v and true or false; applyState() end }
end

--=========================================================
-- СЛАЙДЕР
--=========================================================
local function MakeSlider(parent, text, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 26)
    frame.BackgroundTransparency = 1
    frame.ZIndex = 3
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Theme.Text
    label.Font = Theme.Font
    label.TextSize = 10
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 4
    label.Parent = frame

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0, 35, 1, 0)
    valueLabel.Position = UDim2.new(1, -35, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(default)
    valueLabel.TextColor3 = Theme.Accent
    valueLabel.Font = Theme.FontBold
    valueLabel.TextSize = 10
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.ZIndex = 4
    valueLabel.Parent = frame

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -95, 0, 3)
    track.Position = UDim2.new(0, 55, 0.5, -1)
    track.BackgroundColor3 = Theme.Element
    track.BorderSizePixel = 0
    track.ZIndex = 4
    track.Parent = frame
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Theme.Accent
    fill.BorderSizePixel = 0
    fill.ZIndex = 5
    fill.Parent = track
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Size = UDim2.new(0, 9, 0, 9)
    knob.Position = UDim2.new((default - min) / (max - min), 0, 0.5, 0)
    knob.BackgroundColor3 = Theme.Text
    knob.BorderSizePixel = 0
    knob.ZIndex = 6
    knob.Parent = track
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

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
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateFromX(input.Position.X)
        end
    end)
    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            updateFromX(input.Position.X)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    return { Frame = frame }
end

--=========================================================
-- ЗАГОЛОВОК СЕКЦИИ
--=========================================================
local function MakeSectionTitle(parent, text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 16)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Theme.TextDim
    lbl.Font = Theme.FontBold
    lbl.TextSize = 9
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 3
    lbl.Parent = parent
end

--=========================================================
-- COMBAT ВКЛАДКА (Aimbot)
--=========================================================
MakeSectionTitle(CombatContent, "AIMBOT")

MakeToggle(CombatContent, "Aimbot", false, function()
    Config.Aimbot.Enabled = not Config.Aimbot.Enabled
end)

MakeToggle(CombatContent, "Auto Aim", false, function()
    Config.Aimbot.AutoAim = not Config.Aimbot.AutoAim
end)

MakeToggle(CombatContent, "FOV Circle", true, function()
    Config.Aimbot.ShowFOV = not Config.Aimbot.ShowFOV
end)

MakeToggle(CombatContent, "Prediction", true, function()
    Config.Aimbot.Prediction = not Config.Aimbot.Prediction
end)

MakeToggle(CombatContent, "Visible Check", false, function()
    Config.Aimbot.Visible = not Config.Aimbot.Visible
end)

MakeToggle(CombatContent, "Team Check", true, function()
    Config.Aimbot.TeamCheck = not Config.Aimbot.TeamCheck
end)

MakeSlider(CombatContent, "FOV Radius", 30, 600, Config.Aimbot.FOV, function(v)
    Config.Aimbot.FOV = v
    FovCircle.Size = UDim2.new(0, v * 2, 0, v * 2)
end)

MakeSlider(CombatContent, "Smoothness", 10, 100, 50, function(v)
    Config.Aimbot.Smoothness = v / 100
end)

MakeSlider(CombatContent, "Max Distance", 100, 2000, Config.Aimbot.MaxDistance, function(v)
    Config.Aimbot.MaxDistance = v
end)

--=========================================================
-- VISUAL ВКЛАДКА (ESP)
--=========================================================
MakeSectionTitle(VisualContent, "PLAYER ESP")

MakeToggle(VisualContent, "ESP Enabled", true, function()
    Config.ESP.Enabled = not Config.ESP.Enabled
end)

MakeToggle(VisualContent, "Boxes", true, function()
    Config.ESP.Box = not Config.ESP.Box
end)

MakeToggle(VisualContent, "Names", true, function()
    Config.ESP.Name = not Config.ESP.Name
end)

MakeToggle(VisualContent, "Distance", true, function()
    Config.ESP.Distance = not Config.ESP.Distance
end)

MakeToggle(VisualContent, "Health Bar", true, function()
    Config.ESP.Health = not Config.ESP.Health
end)

MakeToggle(VisualContent, "Tracers", true, function()
    Config.ESP.Tracer = not Config.ESP.Tracer
end)

MakeSlider(VisualContent, "ESP Distance", 200, 3000, Config.ESP.MaxDistance, function(v)
    Config.ESP.MaxDistance = v
end)

MakeSectionTitle(VisualContent, "VISUAL")

MakeToggle(VisualContent, "Fullbright", false, function()
    Config.Visual.Fullbright = not Config.Visual.Fullbright
end)

MakeToggle(VisualContent, "X-Ray", false, function()
    Config.Visual.XRay = not Config.Visual.XRay
end)

MakeToggle(VisualContent, "FPS Boost", false, function()
    Config.Visual.FPSBoost = not Config.Visual.FPSBoost
end)

--=========================================================
-- MOVEMENT ВКЛАДКА
--=========================================================
MakeSectionTitle(MovementContent, "MOVEMENT")

MakeToggle(MovementContent, "Speed Hack", false, function()
    Config.Player.SpeedEnabled = not Config.Player.SpeedEnabled
end)

MakeSlider(MovementContent, "Speed (10-100)", 10, 100, 30, function(v)
    Config.Player.SpeedValue = v
end)

MakeToggle(MovementContent, "Noclip", false, function()
    Config.Player.Noclip = not Config.Player.Noclip
end)

MakeToggle(MovementContent, "No Fall Damage", false, function()
    Config.Player.NoFallDamage = not Config.Player.NoFallDamage
end)

MakeToggle(MovementContent, "Infinite Jump", false, function()
    Config.Misc.InfiniteJump = not Config.Misc.InfiniteJump
end)

--=========================================================
-- MISC ВКЛАДКА
--=========================================================
MakeSectionTitle(MiscContent, "MISC")

MakeToggle(MiscContent, "Infinite Jump", false, function()
    Config.Misc.InfiniteJump = not Config.Misc.InfiniteJump
end)

--=========================================================
-- SETTINGS ВКЛАДКА
--=========================================================
MakeSectionTitle(SettingsContent, "SETTINGS")

local infoLbl = Instance.new("TextLabel")
infoLbl.Size = UDim2.new(1, 0, 0, 80)
infoLbl.BackgroundTransparency = 1
infoLbl.Text = "FerClient Decay v2.1\n\nHotkeys:\nF1=ESP  F2=Aim  F3=AutoAim  F4=InfJump\nRightShift=Menu  Delete=Unload"
infoLbl.TextColor3 = Theme.TextDim
infoLbl.Font = Theme.Font
infoLbl.TextSize = 10
infoLbl.TextWrapped = true
infoLbl.TextXAlignment = Enum.TextXAlignment.Left
infoLbl.TextYAlignment = Enum.TextYAlignment.Top
infoLbl.ZIndex = 3
infoLbl.Parent = SettingsContent

--=========================================================
-- КНОПКА HOLD TO AIM
--=========================================================
local TriggerBtn = Instance.new("TextButton")
TriggerBtn.Size = UDim2.new(0, 100, 0, 18)
TriggerBtn.Position = UDim2.new(0.5, -50, 1, -24)
TriggerBtn.BackgroundColor3 = Theme.Accent
TriggerBtn.BorderSizePixel = 0
TriggerBtn.Text = "HOLD TO AIM"
TriggerBtn.TextColor3 = Color3.new(1, 1, 1)
TriggerBtn.Font = Theme.FontBold
TriggerBtn.TextSize = 9
TriggerBtn.AutoButtonColor = false
TriggerBtn.ZIndex = 6
TriggerBtn.Parent = Menu
Instance.new("UICorner", TriggerBtn).CornerRadius = UDim.new(0, 4)

local function setTrig(a)
    Config.Aimbot.TriggerActive = a
    TriggerBtn.BackgroundColor3 = a and Color3.fromRGB(180, 150, 255) or Theme.Accent
end
TriggerBtn.MouseButton1Down:Connect(function() setTrig(true) end)
TriggerBtn.MouseButton1Up:Connect(function() setTrig(false) end)
TriggerBtn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch then setTrig(true) end end)
TriggerBtn.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch then setTrig(false) end end)
TriggerBtn.MouseLeave:Connect(function() setTrig(false) end)

--=========================================================
-- КНОПКА FC
--=========================================================
local FCBtn = Instance.new("TextButton")
FCBtn.Size = UDim2.new(0, 50, 0, 28)
FCBtn.Position = UDim2.new(0, 10, 0.5, -14)
FCBtn.BackgroundColor3 = Theme.Background
FCBtn.BorderSizePixel = 0
FCBtn.Text = "FC"
FCBtn.TextColor3 = Theme.Accent
FCBtn.Font = Theme.FontBold
FCBtn.TextSize = 14
FCBtn.AutoButtonColor = false
FCBtn.Active = true
FCBtn.Draggable = true
FCBtn.Parent = ScreenGui

local ToggleStroke = Instance.new("UIStroke", FCBtn)
ToggleStroke.Color = Theme.Accent
ToggleStroke.Thickness = 1.5

FCBtn.MouseEnter:Connect(function()
    FCBtn.BackgroundColor3 = Theme.Accent
    FCBtn.TextColor3 = Color3.new(1, 1, 1)
end)
FCBtn.MouseLeave:Connect(function()
    FCBtn.BackgroundColor3 = Theme.Background
    FCBtn.TextColor3 = Theme.Accent
end)

local lastToggle = 0
FCBtn.MouseButton1Click:Connect(function()
    local now = tick()
    if now - lastToggle < 0.3 then return end
    lastToggle = now
    Menu.Visible = not Menu.Visible
end)

--=========================================================
-- СВОРАЧИВАНИЕ
--=========================================================
local isMin = false
local function toggleMin()
    isMin = not isMin
    Menu.Size = isMin and UDim2.new(0, 450, 0, 26) or UDim2.new(0, 450, 0, 280)
    Content.Visible = not isMin
    BottomTabs.Visible = not isMin
    TriggerBtn.Visible = not isMin
end
MinimizeBtn.MouseButton1Click:Connect(toggleMin)

--=========================================================
-- UNLOAD
--=========================================================
local ESPCache = {}

local function Unload()
    if getgenv().FerClient_Decay_Unloading then return end
    getgenv().FerClient_Decay_Unloading = true
    pcall(function() RunService:UnbindFromRenderStep("Decay_Aimbot") end)
    for _, d in pairs(ESPCache) do
        for _, o in pairs(d) do pcall(function() o:Remove() end) end
    end
    for _, c in ipairs(Connections) do pcall(function() c:Disconnect() end) end
    Connections = {}
    pcall(function() ScreenGui:Destroy() end)
    pcall(function() HitLogsGui:Destroy() end)
    getgenv().FerClient_Decay_Loaded = false
    getgenv().FerClient_Decay_Unloading = false
    print("[FerClient] Decay v2.1 — Выгружен.")
end

UnloadBtn.MouseButton1Click:Connect(Unload)
getgenv().FerClient_Decay_Unload = Unload

--=========================================================
-- FOV КРУГ
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
-- ESP СИСТЕМА
--=========================================================
local function CreateESP(player)
    if player == LP or ESPCache[player] then return end
    if not hasDrawing then return end

    local box = Drawing.new("Square")
    box.Visible = false; box.Color = Config.ESP.Color
    box.Thickness = 1; box.Filled = false; box.Transparency = 1

    local boxO = Drawing.new("Square")
    boxO.Visible = false; boxO.Color = Color3.new(0,0,0)
    boxO.Thickness = 3; boxO.Filled = false; boxO.Transparency = 1

    local nm = Drawing.new("Text")
    nm.Visible = false; nm.Center = true; nm.Outline = true
    nm.OutlineColor = Color3.new(0,0,0); nm.Color = Color3.new(1,1,1)
    nm.Size = 14; nm.Font = 2

    local dst = Drawing.new("Text")
    dst.Visible = false; dst.Center = true; dst.Outline = true
    dst.OutlineColor = Color3.new(0,0,0); dst.Color = Color3.new(1,1,1)
    dst.Size = 12; dst.Font = 2

    local hp = Drawing.new("Square")
    hp.Visible = false; hp.Thickness = 1; hp.Filled = true
    hp.Color = Color3.fromRGB(0,255,0)

    local hpBg = Drawing.new("Square")
    hpBg.Visible = false; hpBg.Thickness = 1; hpBg.Filled = true
    hpBg.Color = Color3.fromRGB(40,40,40)

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
-- AIMBOT ЛОГИКА
--=========================================================
local function IsTeammate(plr)
    if not Config.Aimbot.TeamCheck then return false end
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

local function GetClosestTarget()
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local closest, closestDist, closestPos = nil, Config.Aimbot.FOV, nil

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and not IsTeammate(plr) then
            local char = plr.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local part = char:FindFirstChild(Config.Aimbot.TargetPart) or char:FindFirstChild("HumanoidRootPart")
                if part then
                    local predPos = Config.Aimbot.Prediction
                        and GetPredictedPosition(part, Config.Aimbot.PredictionX)
                        or part.Position
                    local sp, onScreen = Camera:WorldToViewportPoint(predPos)
                    if onScreen then
                        local d3 = (Camera.CFrame.Position - predPos).Magnitude
                        if d3 <= Config.Aimbot.MaxDistance then
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
    return closest, closestPos
end

local AIM_PRIORITY = Enum.RenderPriority.Camera.Value + 10

local function AimStep()
    local shouldAim = false
    if Config.Aimbot.Enabled then
        if Config.Aimbot.AutoAim then shouldAim = true
        elseif Config.Aimbot.TriggerActive then shouldAim = true
        elseif UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then shouldAim = true
        end
    end

    if shouldAim then
        local target, predPos = GetClosestTarget()
        if target and predPos then
            local targetCF = CFrame.new(Camera.CFrame.Position, predPos)
            Camera.CFrame = Camera.CFrame:Lerp(targetCF, Config.Aimbot.Smoothness)
        end
    end
end

RunService:BindToRenderStep("Decay_Aimbot", AIM_PRIORITY, AimStep)

--=========================================================
-- ГЛАВНЫЙ ЦИКЛ
--=========================================================
TrackConn(RunService.RenderStepped:Connect(function()
    if Config.Aimbot.ShowFOV and Config.Aimbot.Enabled then
        FovCircle.Visible = true
        FovCircle.Size = UDim2.new(0, Config.Aimbot.FOV * 2, 0, Config.Aimbot.FOV * 2)
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
-- SPEED / NOCLIP / NO FALL
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
        if hum.WalkSpeed ~= savedWalkSpeed then hum.WalkSpeed = savedWalkSpeed end
    end

    if Config.Player.Noclip then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end

    if Config.Player.NoFallDamage then
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
    end
end))

TrackConn(LP.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid", 5)
    if hum then savedWalkSpeed = hum.WalkSpeed end
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
                obj.LocalTransparencyModifier = 0.5
            end
        end
    end)
end))

--=========================================================
-- FPS BOOST
--=========================================================
local fpsApplied = false
TrackConn(RunService.Heartbeat:Connect(function()
    if Config.Visual.FPSBoost and not fpsApplied then
        fpsApplied = true
        pcall(function()
            for _, obj in ipairs(Lighting:GetChildren()) do
                if obj:IsA("BloomEffect") or obj:IsA("BlurEffect") or obj:IsA("SunRaysEffect")
                    or obj:IsA("ColorCorrectionEffect") or obj:IsA("DepthOfFieldEffect") then
                    obj.Enabled = false
                end
            end
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 1000
        end)
        pcall(function()
            setfflag("DFIntTaskSchedulerTargetFps", "240")
            setfflag("FFlagDisablePostFx", "true")
            setfflag("FIntRenderShadowIntensity", "0")
        end)
    elseif not Config.Visual.FPSBoost and fpsApplied then
        fpsApplied = false
    end
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
-- ХОТКЕИ
--=========================================================
TrackConn(UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.F1 then
        Config.ESP.Enabled = not Config.ESP.Enabled
    elseif input.KeyCode == Enum.KeyCode.F2 then
        Config.Aimbot.Enabled = not Config.Aimbot.Enabled
    elseif input.KeyCode == Enum.KeyCode.F3 then
        Config.Aimbot.AutoAim = not Config.Aimbot.AutoAim
    elseif input.KeyCode == Enum.KeyCode.F4 then
        Config.Misc.InfiniteJump = not Config.Misc.InfiniteJump
    elseif input.KeyCode == Enum.KeyCode.RightShift then
        Menu.Visible = not Menu.Visible
    elseif input.KeyCode == Enum.KeyCode.Delete then
        Unload()
    end
end))

chatMessage("[FerClient] Decay v2.1 загружен", Theme.Accent)
print("[FerClient] Decay v2.1 — Null-wave style загружен") --[[
    FerClient | Decay v2.1
    Меню: как в Rusted v5.2 (Null-wave style)
    Функции: Decay [HALF WALLS]
]]

if getgenv().FerClient_Decay_Loaded then
    if getgenv().FerClient_Decay_Unload then pcall(getgenv().FerClient_Decay_Unload) end
    task.wait(0.2)
end
getgenv().FerClient_Decay_Loaded = true

if not game:IsLoaded() then game.Loaded:Wait() end

local HUI = (gethui and gethui()) or game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local Camera = Workspace.CurrentCamera
local LP = Players.LocalPlayer

--=========================================================
-- ТЕМА (Null-wave)
--=========================================================
local Theme = {
    Background   = Color3.fromRGB(15, 15, 25),
    Panel        = Color3.fromRGB(20, 20, 35),
    Element      = Color3.fromRGB(28, 28, 45),
    Accent       = Color3.fromRGB(150, 120, 240),
    On           = Color3.fromRGB(150, 120, 240),
    Off          = Color3.fromRGB(50, 50, 70),
    Text         = Color3.fromRGB(230, 230, 240),
    TextDim      = Color3.fromRGB(120, 120, 140),
    Border       = Color3.fromRGB(40, 40, 60),
    Font         = Enum.Font.Gotham,
    FontBold     = Enum.Font.GothamBold,
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
    },
    Player = {
        NoFallDamage = false,
        SpeedEnabled = false, SpeedValue = 30,
        Noclip = false,
    },
    Visual = {
        Fullbright = false, XRay = false, FPSBoost = false,
    },
    Misc = {
        InfiniteJump = false,
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

local function chatMessage(text, color)
    pcall(function()
        StarterGui:SetCore("ChatMakeSystemMessage", {
            Text = text,
            Color = color or Theme.Accent,
            Font = Enum.Font.GothamBold,
        })
    end)
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
-- ГЛАВНЫЙ GUI
--=========================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FerClient_Decay"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 100
pcall(function() ScreenGui.Parent = HUI end)
if not ScreenGui.Parent then ScreenGui.Parent = LP:WaitForChild("PlayerGui") end

local Menu = Instance.new("Frame")
Menu.Name = "FerClient_Main"
Menu.Size = UDim2.new(0, 450, 0, 280)
Menu.Position = UDim2.new(0.5, -225, 0.5, -140)
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

local SNOW_COUNT = 20
local SNOW_SYMBOLS = { "❄", "❅", "❆", "•", "*" }
local snowflakes = {}

local function createSnowflake()
    local flake = Instance.new("TextLabel")
    flake.BackgroundTransparency = 1
    flake.Text = SNOW_SYMBOLS[math.random(1, #SNOW_SYMBOLS)]
    flake.TextColor3 = Color3.fromRGB(180, 160, 240)
    flake.Font = Enum.Font.GothamBold
    flake.TextSize = math.random(4, 10)
    flake.TextTransparency = math.random(50, 85) / 100
    flake.Size = UDim2.new(0, 20, 0, 20)
    flake.AnchorPoint = Vector2.new(0.5, 0.5)
    flake.ZIndex = 2
    flake.Parent = SnowContainer
    local startX = math.random(0, 100)
    flake.Position = UDim2.new(startX / 100, 0, -0.05, 0)
    snowflakes[#snowflakes + 1] = {
        label = flake, xRatio = startX / 100,
        speed = math.random(15, 35),
        swayAmp = math.random(10, 25) / 1000,
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
                data.speed = math.random(15, 35)
                data.label.Text = SNOW_SYMBOLS[math.random(1, #SNOW_SYMBOLS)]
                data.label.TextSize = math.random(4, 10)
                data.label.TextTransparency = math.random(50, 85) / 100
            end
            f.Position = UDim2.new(currentX + swayX, 0, currentY, 0)
            f.Rotation = data.rotation
        end
    end
end))

--=========================================================
-- ЗАГОЛОВОК
--=========================================================
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 26)
TopBar.BackgroundColor3 = Theme.Background
TopBar.BorderSizePixel = 0
TopBar.ZIndex = 3
TopBar.Parent = Menu

local Logo = Instance.new("TextLabel")
Logo.Size = UDim2.new(1, -70, 1, 0)
Logo.Position = UDim2.new(0, 10, 0, 0)
Logo.BackgroundTransparency = 1
Logo.Text = "FerClient.lua"
Logo.TextColor3 = Theme.Text
Logo.Font = Theme.FontBold
Logo.TextSize = 12
Logo.TextXAlignment = Enum.TextXAlignment.Left
Logo.ZIndex = 4
Logo.Parent = TopBar

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 18, 0, 18)
MinimizeBtn.Position = UDim2.new(1, -46, 0, 4)
MinimizeBtn.BackgroundTransparency = 1
MinimizeBtn.Text = "—"
MinimizeBtn.TextColor3 = Theme.TextDim
MinimizeBtn.Font = Theme.FontBold
MinimizeBtn.TextSize = 12
MinimizeBtn.AutoButtonColor = false
MinimizeBtn.ZIndex = 4
MinimizeBtn.Parent = TopBar

local UnloadBtn = Instance.new("TextButton")
UnloadBtn.Size = UDim2.new(0, 18, 0, 18)
UnloadBtn.Position = UDim2.new(1, -24, 0, 4)
UnloadBtn.BackgroundTransparency = 1
UnloadBtn.Text = "✕"
UnloadBtn.TextColor3 = Theme.TextDim
UnloadBtn.Font = Theme.FontBold
UnloadBtn.TextSize = 11
UnloadBtn.AutoButtonColor = false
UnloadBtn.ZIndex = 4
UnloadBtn.Parent = TopBar

--=========================================================
-- КОНТЕНТ (5 вкладок с переключением)
--=========================================================
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -20, 1, -54)
Content.Position = UDim2.new(0, 10, 0, 30)
Content.BackgroundTransparency = 1
Content.ZIndex = 3
Content.Parent = Menu

local function MakeTabContent()
    local sf = Instance.new("ScrollingFrame")
    sf.Size = UDim2.new(1, 0, 1, 0)
    sf.BackgroundTransparency = 1
    sf.BorderSizePixel = 0
    sf.ScrollBarThickness = 2
    sf.ScrollBarImageColor3 = Theme.Accent
    sf.CanvasSize = UDim2.new(0, 0, 0, 0)
    sf.Visible = false
    sf.ZIndex = 3
    sf.Parent = Content

    local layout = Instance.new("UIListLayout", sf)
    layout.Padding = UDim.new(0, 4)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        sf.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    end)

    return sf, layout
end

local CombatContent = MakeTabContent()
local VisualContent = MakeTabContent()
local MovementContent = MakeTabContent()
local MiscContent = MakeTabContent()
local SettingsContent = MakeTabContent()

--=========================================================
-- НИЖНИЕ ВКЛАДКИ
--=========================================================
local BottomTabs = Instance.new("Frame")
BottomTabs.Size = UDim2.new(1, 0, 0, 22)
BottomTabs.Position = UDim2.new(0, 0, 1, -24)
BottomTabs.BackgroundColor3 = Theme.Background
BottomTabs.BorderSizePixel = 0
BottomTabs.ZIndex = 3
BottomTabs.Parent = Menu

local BottomLayout = Instance.new("UIListLayout", BottomTabs)
BottomLayout.FillDirection = Enum.FillDirection.Horizontal
BottomLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
BottomLayout.SortOrder = Enum.SortOrder.LayoutOrder
BottomLayout.Padding = UDim.new(0, 15)
BottomLayout.Parent = BottomTabs

local tabs = {}

local function CreateBottomTab(name, contentFrame)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 60, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = name
    btn.TextColor3 = Theme.TextDim
    btn.Font = Theme.Font
    btn.TextSize = 10
    btn.AutoButtonColor = false
    btn.ZIndex = 4
    btn.Parent = BottomTabs

    local tab = { Btn = btn, Name = name, Content = contentFrame }
    btn.MouseButton1Click:Connect(function()
        for _, t in ipairs(tabs) do
            t.Btn.TextColor3 = Theme.TextDim
            t.Btn.Font = Theme.Font
            if t.Content then t.Content.Visible = false end
        end
        btn.TextColor3 = Theme.Accent
        btn.Font = Theme.FontBold
        if contentFrame then contentFrame.Visible = true end
    end)
    tabs[#tabs + 1] = tab
    return tab
end

local CombatTab = CreateBottomTab("Combat", CombatContent)
local VisualTab = CreateBottomTab("Visual", VisualContent)
local MovementTab = CreateBottomTab("Movement", MovementContent)
local MiscTab = CreateBottomTab("Misc", MiscContent)
local SettingsTab = CreateBottomTab("Settings", SettingsContent)

CombatTab.Btn.TextColor3 = Theme.Accent
CombatTab.Btn.Font = Theme.FontBold
CombatContent.Visible = true

--=========================================================
-- ТУМБЛЕР
--=========================================================
local function MakeToggle(parent, text, defaultOn, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 22)
    frame.BackgroundTransparency = 1
    frame.ZIndex = 3
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -45, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Theme.Text
    label.Font = Theme.Font
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 4
    label.Parent = frame

    local track = Instance.new("Frame")
    track.Size = UDim2.new(0, 28, 0, 14)
    track.Position = UDim2.new(1, -30, 0.5, -7)
    track.BackgroundColor3 = Theme.Off
    track.BorderSizePixel = 0
    track.ZIndex = 4
    track.Parent = frame
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.AnchorPoint = Vector2.new(0, 0.5)
    knob.Size = UDim2.new(0, 10, 0, 10)
    knob.Position = UDim2.new(0, 2, 0.5, 0)
    knob.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
    knob.BorderSizePixel = 0
    knob.ZIndex = 5
    knob.Parent = track
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local isOn = false
    local function applyState()
        if isOn then
            track.BackgroundColor3 = Theme.On
            TweenService:Create(knob, TweenInfo.new(0.15), { Position = UDim2.new(1, -12, 0.5, 0) }):Play()
        else
            track.BackgroundColor3 = Theme.Off
            TweenService:Create(knob, TweenInfo.new(0.15), { Position = UDim2.new(0, 2, 0.5, 0) }):Play()
        end
    end

    isOn = defaultOn or false
    applyState()

    local click = Instance.new("TextButton")
    click.Size = UDim2.new(1, 0, 1, 0)
    click.BackgroundTransparency = 1
    click.Text = ""
    click.AutoButtonColor = false
    click.ZIndex = 6
    click.Parent = frame

    local lastClick = 0
    click.MouseButton1Click:Connect(function()
        local now = tick()
        if now - lastClick < 0.25 then return end
        lastClick = now
        pcall(callback)
        isOn = not isOn
        applyState()
    end)

    return { Frame = frame, SetOn = function(v) isOn = v and true or false; applyState() end }
end

--=========================================================
-- СЛАЙДЕР
--=========================================================
local function MakeSlider(parent, text, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 26)
    frame.BackgroundTransparency = 1
    frame.ZIndex = 3
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Theme.Text
    label.Font = Theme.Font
    label.TextSize = 10
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 4
    label.Parent = frame

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0, 35, 1, 0)
    valueLabel.Position = UDim2.new(1, -35, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(default)
    valueLabel.TextColor3 = Theme.Accent
    valueLabel.Font = Theme.FontBold
    valueLabel.TextSize = 10
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.ZIndex = 4
    valueLabel.Parent = frame

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -95, 0, 3)
    track.Position = UDim2.new(0, 55, 0.5, -1)
    track.BackgroundColor3 = Theme.Element
    track.BorderSizePixel = 0
    track.ZIndex = 4
    track.Parent = frame
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Theme.Accent
    fill.BorderSizePixel = 0
    fill.ZIndex = 5
    fill.Parent = track
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Size = UDim2.new(0, 9, 0, 9)
    knob.Position = UDim2.new((default - min) / (max - min), 0, 0.5, 0)
    knob.BackgroundColor3 = Theme.Text
    knob.BorderSizePixel = 0
    knob.ZIndex = 6
    knob.Parent = track
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

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
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateFromX(input.Position.X)
        end
    end)
    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            updateFromX(input.Position.X)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    return { Frame = frame }
end

--=========================================================
-- ЗАГОЛОВОК СЕКЦИИ
--=========================================================
local function MakeSectionTitle(parent, text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 16)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Theme.TextDim
    lbl.Font = Theme.FontBold
    lbl.TextSize = 9
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 3
    lbl.Parent = parent
end

--=========================================================
-- COMBAT ВКЛАДКА (Aimbot)
--=========================================================
MakeSectionTitle(CombatContent, "AIMBOT")

MakeToggle(CombatContent, "Aimbot", false, function()
    Config.Aimbot.Enabled = not Config.Aimbot.Enabled
end)

MakeToggle(CombatContent, "Auto Aim", false, function()
    Config.Aimbot.AutoAim = not Config.Aimbot.AutoAim
end)

MakeToggle(CombatContent, "FOV Circle", true, function()
    Config.Aimbot.ShowFOV = not Config.Aimbot.ShowFOV
end)

MakeToggle(CombatContent, "Prediction", true, function()
    Config.Aimbot.Prediction = not Config.Aimbot.Prediction
end)

MakeToggle(CombatContent, "Visible Check", false, function()
    Config.Aimbot.Visible = not Config.Aimbot.Visible
end)

MakeToggle(CombatContent, "Team Check", true, function()
    Config.Aimbot.TeamCheck = not Config.Aimbot.TeamCheck
end)

MakeSlider(CombatContent, "FOV Radius", 30, 600, Config.Aimbot.FOV, function(v)
    Config.Aimbot.FOV = v
    FovCircle.Size = UDim2.new(0, v * 2, 0, v * 2)
end)

MakeSlider(CombatContent, "Smoothness", 10, 100, 50, function(v)
    Config.Aimbot.Smoothness = v / 100
end)

MakeSlider(CombatContent, "Max Distance", 100, 2000, Config.Aimbot.MaxDistance, function(v)
    Config.Aimbot.MaxDistance = v
end)

--=========================================================
-- VISUAL ВКЛАДКА (ESP)
--=========================================================
MakeSectionTitle(VisualContent, "PLAYER ESP")

MakeToggle(VisualContent, "ESP Enabled", true, function()
    Config.ESP.Enabled = not Config.ESP.Enabled
end)

MakeToggle(VisualContent, "Boxes", true, function()
    Config.ESP.Box = not Config.ESP.Box
end)

MakeToggle(VisualContent, "Names", true, function()
    Config.ESP.Name = not Config.ESP.Name
end)

MakeToggle(VisualContent, "Distance", true, function()
    Config.ESP.Distance = not Config.ESP.Distance
end)

MakeToggle(VisualContent, "Health Bar", true, function()
    Config.ESP.Health = not Config.ESP.Health
end)

MakeToggle(VisualContent, "Tracers", true, function()
    Config.ESP.Tracer = not Config.ESP.Tracer
end)

MakeSlider(VisualContent, "ESP Distance", 200, 3000, Config.ESP.MaxDistance, function(v)
    Config.ESP.MaxDistance = v
end)

MakeSectionTitle(VisualContent, "VISUAL")

MakeToggle(VisualContent, "Fullbright", false, function()
    Config.Visual.Fullbright = not Config.Visual.Fullbright
end)

MakeToggle(VisualContent, "X-Ray", false, function()
    Config.Visual.XRay = not Config.Visual.XRay
end)

MakeToggle(VisualContent, "FPS Boost", false, function()
    Config.Visual.FPSBoost = not Config.Visual.FPSBoost
end)

--=========================================================
-- MOVEMENT ВКЛАДКА
--=========================================================
MakeSectionTitle(MovementContent, "MOVEMENT")

MakeToggle(MovementContent, "Speed Hack", false, function()
    Config.Player.SpeedEnabled = not Config.Player.SpeedEnabled
end)

MakeSlider(MovementContent, "Speed (10-100)", 10, 100, 30, function(v)
    Config.Player.SpeedValue = v
end)

MakeToggle(MovementContent, "Noclip", false, function()
    Config.Player.Noclip = not Config.Player.Noclip
end)

MakeToggle(MovementContent, "No Fall Damage", false, function()
    Config.Player.NoFallDamage = not Config.Player.NoFallDamage
end)

MakeToggle(MovementContent, "Infinite Jump", false, function()
    Config.Misc.InfiniteJump = not Config.Misc.InfiniteJump
end)

--=========================================================
-- MISC ВКЛАДКА
--=========================================================
MakeSectionTitle(MiscContent, "MISC")

MakeToggle(MiscContent, "Infinite Jump", false, function()
    Config.Misc.InfiniteJump = not Config.Misc.InfiniteJump
end)

--=========================================================
-- SETTINGS ВКЛАДКА
--=========================================================
MakeSectionTitle(SettingsContent, "SETTINGS")

local infoLbl = Instance.new("TextLabel")
infoLbl.Size = UDim2.new(1, 0, 0, 80)
infoLbl.BackgroundTransparency = 1
infoLbl.Text = "FerClient Decay v2.1\n\nHotkeys:\nF1=ESP  F2=Aim  F3=AutoAim  F4=InfJump\nRightShift=Menu  Delete=Unload"
infoLbl.TextColor3 = Theme.TextDim
infoLbl.Font = Theme.Font
infoLbl.TextSize = 10
infoLbl.TextWrapped = true
infoLbl.TextXAlignment = Enum.TextXAlignment.Left
infoLbl.TextYAlignment = Enum.TextYAlignment.Top
infoLbl.ZIndex = 3
infoLbl.Parent = SettingsContent

--=========================================================
-- КНОПКА HOLD TO AIM
--=========================================================
local TriggerBtn = Instance.new("TextButton")
TriggerBtn.Size = UDim2.new(0, 100, 0, 18)
TriggerBtn.Position = UDim2.new(0.5, -50, 1, -24)
TriggerBtn.BackgroundColor3 = Theme.Accent
TriggerBtn.BorderSizePixel = 0
TriggerBtn.Text = "HOLD TO AIM"
TriggerBtn.TextColor3 = Color3.new(1, 1, 1)
TriggerBtn.Font = Theme.FontBold
TriggerBtn.TextSize = 9
TriggerBtn.AutoButtonColor = false
TriggerBtn.ZIndex = 6
TriggerBtn.Parent = Menu
Instance.new("UICorner", TriggerBtn).CornerRadius = UDim.new(0, 4)

local function setTrig(a)
    Config.Aimbot.TriggerActive = a
    TriggerBtn.BackgroundColor3 = a and Color3.fromRGB(180, 150, 255) or Theme.Accent
end
TriggerBtn.MouseButton1Down:Connect(function() setTrig(true) end)
TriggerBtn.MouseButton1Up:Connect(function() setTrig(false) end)
TriggerBtn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch then setTrig(true) end end)
TriggerBtn.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch then setTrig(false) end end)
TriggerBtn.MouseLeave:Connect(function() setTrig(false) end)

--=========================================================
-- КНОПКА FC
--=========================================================
local FCBtn = Instance.new("TextButton")
FCBtn.Size = UDim2.new(0, 50, 0, 28)
FCBtn.Position = UDim2.new(0, 10, 0.5, -14)
FCBtn.BackgroundColor3 = Theme.Background
FCBtn.BorderSizePixel = 0
FCBtn.Text = "FC"
FCBtn.TextColor3 = Theme.Accent
FCBtn.Font = Theme.FontBold
FCBtn.TextSize = 14
FCBtn.AutoButtonColor = false
FCBtn.Active = true
FCBtn.Draggable = true
FCBtn.Parent = ScreenGui

local ToggleStroke = Instance.new("UIStroke", FCBtn)
ToggleStroke.Color = Theme.Accent
ToggleStroke.Thickness = 1.5

FCBtn.MouseEnter:Connect(function()
    FCBtn.BackgroundColor3 = Theme.Accent
    FCBtn.TextColor3 = Color3.new(1, 1, 1)
end)
FCBtn.MouseLeave:Connect(function()
    FCBtn.BackgroundColor3 = Theme.Background
    FCBtn.TextColor3 = Theme.Accent
end)

local lastToggle = 0
FCBtn.MouseButton1Click:Connect(function()
    local now = tick()
    if now - lastToggle < 0.3 then return end
    lastToggle = now
    Menu.Visible = not Menu.Visible
end)

--=========================================================
-- СВОРАЧИВАНИЕ
--=========================================================
local isMin = false
local function toggleMin()
    isMin = not isMin
    Menu.Size = isMin and UDim2.new(0, 450, 0, 26) or UDim2.new(0, 450, 0, 280)
    Content.Visible = not isMin
    BottomTabs.Visible = not isMin
    TriggerBtn.Visible = not isMin
end
MinimizeBtn.MouseButton1Click:Connect(toggleMin)

--=========================================================
-- UNLOAD
--=========================================================
local ESPCache = {}

local function Unload()
    if getgenv().FerClient_Decay_Unloading then return end
    getgenv().FerClient_Decay_Unloading = true
    pcall(function() RunService:UnbindFromRenderStep("Decay_Aimbot") end)
    for _, d in pairs(ESPCache) do
        for _, o in pairs(d) do pcall(function() o:Remove() end) end
    end
    for _, c in ipairs(Connections) do pcall(function() c:Disconnect() end) end
    Connections = {}
    pcall(function() ScreenGui:Destroy() end)
    pcall(function() HitLogsGui:Destroy() end)
    getgenv().FerClient_Decay_Loaded = false
    getgenv().FerClient_Decay_Unloading = false
    print("[FerClient] Decay v2.1 — Выгружен.")
end

UnloadBtn.MouseButton1Click:Connect(Unload)
getgenv().FerClient_Decay_Unload = Unload

--=========================================================
-- FOV КРУГ
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
-- ESP СИСТЕМА
--=========================================================
local function CreateESP(player)
    if player == LP or ESPCache[player] then return end
    if not hasDrawing then return end

    local box = Drawing.new("Square")
    box.Visible = false; box.Color = Config.ESP.Color
    box.Thickness = 1; box.Filled = false; box.Transparency = 1

    local boxO = Drawing.new("Square")
    boxO.Visible = false; boxO.Color = Color3.new(0,0,0)
    boxO.Thickness = 3; boxO.Filled = false; boxO.Transparency = 1

    local nm = Drawing.new("Text")
    nm.Visible = false; nm.Center = true; nm.Outline = true
    nm.OutlineColor = Color3.new(0,0,0); nm.Color = Color3.new(1,1,1)
    nm.Size = 14; nm.Font = 2

    local dst = Drawing.new("Text")
    dst.Visible = false; dst.Center = true; dst.Outline = true
    dst.OutlineColor = Color3.new(0,0,0); dst.Color = Color3.new(1,1,1)
    dst.Size = 12; dst.Font = 2

    local hp = Drawing.new("Square")
    hp.Visible = false; hp.Thickness = 1; hp.Filled = true
    hp.Color = Color3.fromRGB(0,255,0)

    local hpBg = Drawing.new("Square")
    hpBg.Visible = false; hpBg.Thickness = 1; hpBg.Filled = true
    hpBg.Color = Color3.fromRGB(40,40,40)

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
-- AIMBOT ЛОГИКА
--=========================================================
local function IsTeammate(plr)
    if not Config.Aimbot.TeamCheck then return false end
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

local function GetClosestTarget()
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local closest, closestDist, closestPos = nil, Config.Aimbot.FOV, nil

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and not IsTeammate(plr) then
            local char = plr.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local part = char:FindFirstChild(Config.Aimbot.TargetPart) or char:FindFirstChild("HumanoidRootPart")
                if part then
                    local predPos = Config.Aimbot.Prediction
                        and GetPredictedPosition(part, Config.Aimbot.PredictionX)
                        or part.Position
                    local sp, onScreen = Camera:WorldToViewportPoint(predPos)
                    if onScreen then
                        local d3 = (Camera.CFrame.Position - predPos).Magnitude
                        if d3 <= Config.Aimbot.MaxDistance then
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
    return closest, closestPos
end

local AIM_PRIORITY = Enum.RenderPriority.Camera.Value + 10

local function AimStep()
    local shouldAim = false
    if Config.Aimbot.Enabled then
        if Config.Aimbot.AutoAim then shouldAim = true
        elseif Config.Aimbot.TriggerActive then shouldAim = true
        elseif UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then shouldAim = true
        end
    end

    if shouldAim then
        local target, predPos = GetClosestTarget()
        if target and predPos then
            local targetCF = CFrame.new(Camera.CFrame.Position, predPos)
            Camera.CFrame = Camera.CFrame:Lerp(targetCF, Config.Aimbot.Smoothness)
        end
    end
end

RunService:BindToRenderStep("Decay_Aimbot", AIM_PRIORITY, AimStep)

--=========================================================
-- ГЛАВНЫЙ ЦИКЛ
--=========================================================
TrackConn(RunService.RenderStepped:Connect(function()
    if Config.Aimbot.ShowFOV and Config.Aimbot.Enabled then
        FovCircle.Visible = true
        FovCircle.Size = UDim2.new(0, Config.Aimbot.FOV * 2, 0, Config.Aimbot.FOV * 2)
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
-- SPEED / NOCLIP / NO FALL
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
        if hum.WalkSpeed ~= savedWalkSpeed then hum.WalkSpeed = savedWalkSpeed end
    end

    if Config.Player.Noclip then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end

    if Config.Player.NoFallDamage then
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
    end
end))

TrackConn(LP.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid", 5)
    if hum then savedWalkSpeed = hum.WalkSpeed end
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
                obj.LocalTransparencyModifier = 0.5
            end
        end
    end)
end))

--=========================================================
-- FPS BOOST
--=========================================================
local fpsApplied = false
TrackConn(RunService.Heartbeat:Connect(function()
    if Config.Visual.FPSBoost and not fpsApplied then
        fpsApplied = true
        pcall(function()
            for _, obj in ipairs(Lighting:GetChildren()) do
                if obj:IsA("BloomEffect") or obj:IsA("BlurEffect") or obj:IsA("SunRaysEffect")
                    or obj:IsA("ColorCorrectionEffect") or obj:IsA("DepthOfFieldEffect") then
                    obj.Enabled = false
                end
            end
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 1000
        end)
        pcall(function()
            setfflag("DFIntTaskSchedulerTargetFps", "240")
            setfflag("FFlagDisablePostFx", "true")
            setfflag("FIntRenderShadowIntensity", "0")
        end)
    elseif not Config.Visual.FPSBoost and fpsApplied then
        fpsApplied = false
    end
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
-- ХОТКЕИ
--=========================================================
TrackConn(UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.F1 then
        Config.ESP.Enabled = not Config.ESP.Enabled
    elseif input.KeyCode == Enum.KeyCode.F2 then
        Config.Aimbot.Enabled = not Config.Aimbot.Enabled
    elseif input.KeyCode == Enum.KeyCode.F3 then
        Config.Aimbot.AutoAim = not Config.Aimbot.AutoAim
    elseif input.KeyCode == Enum.KeyCode.F4 then
        Config.Misc.InfiniteJump = not Config.Misc.InfiniteJump
    elseif input.KeyCode == Enum.KeyCode.RightShift then
        Menu.Visible = not Menu.Visible
    elseif input.KeyCode == Enum.KeyCode.Delete then
        Unload()
    end
end))

chatMessage("[FerClient] Decay v2.1 загружен", Theme.Accent)
print("[FerClient] Decay v2.1 — Null-wave style загружен")
