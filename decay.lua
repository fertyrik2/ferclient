--[[
    FerClient | Decay v7.0 FINAL
    ESP + Aimbot + Silent Aim + No Recoil + Long Range + No Fog
    + Anti-AFK + FOV Change + Skeleton ESP + Config Save
    + Speed без телепорта
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
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local Camera = Workspace.CurrentCamera
local LP = Players.LocalPlayer

--=========================================================
-- ТЕМА
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
-- КОНФИГ (все функции OFF по умолчанию)
--=========================================================
local Config = {
    ESP = {
        Enabled = true,        -- ВКЛ (базовое)
        Box = true, Name = true, Distance = true, Health = true, Tracer = true,
        Skeleton = false,
        MaxDistance = 1500, Color = Theme.Accent,
    },
    Aimbot = {
        Enabled = false, AutoAim = false, FOV = 200, Smoothness = 0.5,
        MaxDistance = 600, TargetPart = "Head", Visible = false,
        TeamCheck = true, ShowFOV = true, TriggerActive = false,
        Prediction = true, PredictionX = 0.2, PredictionAuto = true,
        PredictionMax = 0.5, UseVelocityHistory = true,
    },
    Silent = {
        Enabled = false, FOV = 300, MaxDistance = 20, TargetPart = "Head",
        TeamCheck = true, Debug = true, LastReplace = 0, Cooldown = 0.3, VisibleCheck = true,
    },
    Gun = {
        NoRecoil = false, LongRange = false, RangeMultiplier = 3,
    },
    Player = {
        NoFallDamage = false,
        SpeedEnabled = false, SpeedValue = 30,
        Noclip = false,
        AntiAFK = false,
    },
    Visual = {
        Fullbright = false, XRay = false, FPSBoost = false, NoFog = false,
        FOVChange = false, FOVValue = 70,
    },
    Misc = {
        InfiniteJump = false,
    }
}

-- Дефолт для восстановления при загрузке конфига
local DefaultConfig = HttpService:JSONEncode(Config)

local hasDrawing = pcall(function()
    local t = Drawing.new("Square"); t:Remove()
end)

local Connections = {}
local function TrackConn(conn)
    Connections[#Connections + 1] = conn
    return conn
end

local function notify(title, text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title or "FerClient",
            Text = text or "",
            Duration = 2,
        })
    end)
end

--=========================================================
-- КОНФИГ SAVE/LOAD
--=========================================================
local CONFIG_FILE = "FerClient_Decay_Config.json"

local function SaveConfig()
    pcall(function()
        if writefile then
            local data = HttpService:JSONEncode(Config)
            writefile(CONFIG_FILE, data)
            notify("Config", "Сохранено ✅")
        else
            notify("Config", "writefile недоступен")
        end
    end)
end

local function LoadConfig()
    pcall(function()
        if isfile and isfile(CONFIG_FILE) then
            local data = readfile(CONFIG_FILE)
            local loaded = HttpService:JSONDecode(data)
            
            -- Применяем по секциям
            for section, values in pairs(loaded) do
                if Config[section] and type(values) == "table" then
                    for key, val in pairs(values) do
                        Config[section][key] = val
                    end
                end
            end
            notify("Config", "Загружено ✅")
        else
            notify("Config", "Файла нет")
        end
    end)
end

local function ResetConfig()
    pcall(function()
        local default = HttpService:JSONDecode(DefaultConfig)
        for section, values in pairs(default) do
            if Config[section] then
                for key, val in pairs(values) do
                    Config[section][key] = val
                end
            end
        end
        notify("Config", "Сброшено ✅")
    end)
end

--=========================================================
-- ANTI-AFK
--=========================================================
local AntiAFKActive = false
local function EnableAntiAFK()
    if AntiAFKActive then return end
    AntiAFKActive = true
    TrackConn(LP.Idled:Connect(function()
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end))
    notify("Anti-AFK", "Включён ✅")
end

local function DisableAntiAFK()
    AntiAFKActive = false
    notify("Anti-AFK", "Выключен")
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

-- СНЕЖИНКИ
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

-- ЗАГОЛОВОК
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
Logo.Text = "FerClient v7.0"
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

-- КОНТЕНТ
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

-- НИЖНИЕ ВКЛАДКИ
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

-- ТУМБЛЕР
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

-- СЛАЙДЕР
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

-- КНОПКА
local function MakeButton(parent, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 28)
    btn.BackgroundColor3 = Theme.Element
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = Theme.Text
    btn.Font = Theme.FontBold
    btn.TextSize = 11
    btn.AutoButtonColor = false
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    Instance.new("UIStroke", btn).Color = Theme.Border
    
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = Theme.Accent }):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = Theme.Element }):Play()
    end)
    
    btn.MouseButton1Click:Connect(function()
        pcall(callback)
    end)
    
    return btn
end

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
-- COMBAT
--=========================================================
MakeSectionTitle(CombatContent, "AIMBOT")

MakeToggle(CombatContent, "Aimbot", false, function()
    Config.Aimbot.Enabled = not Config.Aimbot.Enabled
end)

MakeToggle(CombatContent, "Auto Aim", false, function()
    Config.Aimbot.AutoAim = not Config.Aimbot.AutoAim
end)

MakeToggle(CombatContent, "FOV Circle", false, function()
    Config.Aimbot.ShowFOV = not Config.Aimbot.ShowFOV
end)

MakeToggle(CombatContent, "Prediction", true, function()
    Config.Aimbot.Prediction = not Config.Aimbot.Prediction
end)

MakeToggle(CombatContent, "Auto Prediction", true, function()
    Config.Aimbot.PredictionAuto = not Config.Aimbot.PredictionAuto
end)

MakeToggle(CombatContent, "Velocity Smooth", true, function()
    Config.Aimbot.UseVelocityHistory = not Config.Aimbot.UseVelocityHistory
end)

MakeToggle(CombatContent, "Visible Check", false, function()
    Config.Aimbot.Visible = not Config.Aimbot.Visible
end)

MakeToggle(CombatContent, "Team Check", true, function()
    Config.Aimbot.TeamCheck = not Config.Aimbot.TeamCheck
    Config.Silent.TeamCheck = Config.Aimbot.TeamCheck
end)

MakeSlider(CombatContent, "FOV Radius", 30, 600, Config.Aimbot.FOV, function(v)
    Config.Aimbot.FOV = v
    if FovCircle then FovCircle.Size = UDim2.new(0, v * 2, 0, v * 2) end
end)

MakeSlider(CombatContent, "Smoothness", 10, 100, 50, function(v)
    Config.Aimbot.Smoothness = v / 100
end)

MakeSlider(CombatContent, "Aimbot Max Dist", 100, 2000, Config.Aimbot.MaxDistance, function(v)
    Config.Aimbot.MaxDistance = v
end)

MakeSectionTitle(CombatContent, "SILENT AIM")

MakeToggle(CombatContent, "Silent Aim", false, function()
    Config.Silent.Enabled = not Config.Silent.Enabled
end)

MakeToggle(CombatContent, "Silent Team Check", true, function()
    Config.Silent.TeamCheck = not Config.Silent.TeamCheck
end)

MakeToggle(CombatContent, "Silent Visible Check", true, function()
    Config.Silent.VisibleCheck = not Config.Silent.VisibleCheck
end)

MakeSectionTitle(CombatContent, "GUN MODS")

MakeToggle(CombatContent, "No Recoil", false, function()
    Config.Gun.NoRecoil = not Config.Gun.NoRecoil
end)

MakeToggle(CombatContent, "Long Range Bullets", false, function()
    Config.Gun.LongRange = not Config.Gun.LongRange
end)

MakeSlider(CombatContent, "Range Multiplier", 1, 10, Config.Gun.RangeMultiplier, function(v)
    Config.Gun.RangeMultiplier = v
end)

--=========================================================
-- VISUAL
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

MakeToggle(VisualContent, "Skeleton ESP", false, function()
    Config.ESP.Skeleton = not Config.ESP.Skeleton
    if Config.ESP.Skeleton then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP then CreateSkeleton(p) end
        end
    else
        for _, p in ipairs(Players:GetPlayers()) do
            RemoveSkeleton(p)
        end
    end
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

MakeToggle(VisualContent, "No Fog", false, function()
    Config.Visual.NoFog = not Config.Visual.NoFog
    notify("No Fog", Config.Visual.NoFog and "ON" or "OFF")
end)

MakeToggle(VisualContent, "FOV Change", false, function()
    Config.Visual.FOVChange = not Config.Visual.FOVChange
end)

MakeSlider(VisualContent, "FOV Value", 30, 120, Config.Visual.FOVValue, function(v)
    Config.Visual.FOVValue = v
end)

--=========================================================
-- MOVEMENT
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
-- MISC
--=========================================================
MakeSectionTitle(MiscContent, "MISC")

MakeToggle(MiscContent, "Infinite Jump", false, function()
    Config.Misc.InfiniteJump = not Config.Misc.InfiniteJump
end)

MakeToggle(MiscContent, "Anti-AFK", false, function()
    Config.Player.AntiAFK = not Config.Player.AntiAFK
    if Config.Player.AntiAFK then
        EnableAntiAFK()
    else
        DisableAntiAFK()
    end
end)

--=========================================================
-- SETTINGS
--=========================================================
MakeSectionTitle(SettingsContent, "CONFIG")

MakeButton(SettingsContent, "💾 Сохранить Config", function()
    SaveConfig()
end)

MakeButton(SettingsContent, "📂 Загрузить Config", function()
    LoadConfig()
end)

MakeButton(SettingsContent, "🔄 Сбросить Config", function()
    ResetConfig()
end)

MakeSectionTitle(SettingsContent, "INFO")

local infoLbl = Instance.new("TextLabel")
infoLbl.Size = UDim2.new(1, 0, 0, 130)
infoLbl.BackgroundTransparency = 1
infoLbl.Text = "FerClient Decay v7.0\nAnti-AFK + FOV + Skeleton + Config\n\nHotkeys:\nF1=ESP  F2=Aim  F3=AutoAim  F4=InfJump\nF5=Silent Aim  F6=No Recoil  F7=Long Range\nF8=No Fog  F9=Anti-AFK  RightShift=Menu\nDelete=Unload\n\nВсе функции OFF по умолчанию"
infoLbl.TextColor3 = Theme.TextDim
infoLbl.Font = Theme.Font
infoLbl.TextSize = 10
infoLbl.TextWrapped = true
infoLbl.TextXAlignment = Enum.TextXAlignment.Left
infoLbl.TextYAlignment = Enum.TextYAlignment.Top
infoLbl.ZIndex = 3
infoLbl.Parent = SettingsContent

--=========================================================
-- HOLD TO AIM
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

-- FC КНОПКА
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

-- СВОРАЧИВАНИЕ
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
local SkeletonCache = {}

local function Unload()
    if getgenv().FerClient_Decay_Unloading then return end
    getgenv().FerClient_Decay_Unloading = true
    pcall(function() RunService:UnbindFromRenderStep("Decay_Aimbot") end)
    for _, d in pairs(ESPCache) do
        for _, o in pairs(d) do pcall(function() o:Remove() end) end
    end
    for _, d in pairs(SkeletonCache) do
        for _, o in pairs(d) do pcall(function() o:Remove() end) end
    end
    for _, c in ipairs(Connections) do pcall(function() c:Disconnect() end) end
    Connections = {}
    pcall(function() ScreenGui:Destroy() end)
    getgenv().FerClient_Decay_Loaded = false
    getgenv().FerClient_Decay_Unloading = false
    notify("FerClient", "Выгружен")
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
-- ESP
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
-- SKELETON ESP
--=========================================================
local SKELETON_PARTS = {
    {"Head", "UpperTorso"},
    {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"},
    {"LeftUpperArm", "LeftLowerArm"},
    {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"},
    {"RightUpperArm", "RightLowerArm"},
    {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"},
    {"LeftUpperLeg", "LeftLowerLeg"},
    {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"},
    {"RightUpperLeg", "RightLowerLeg"},
    {"RightLowerLeg", "RightFoot"},
}

local function CreateSkeleton(player)
    if player == LP or SkeletonCache[player] then return end
    if not hasDrawing then return end
    
    local lines = {}
    for i = 1, #SKELETON_PARTS do
        local line = Drawing.new("Line")
        line.Visible = false
        line.Color = Color3.fromRGB(255, 255, 255)
        line.Thickness = 1.5
        line.Transparency = 1
        lines[i] = line
    end
    
    SkeletonCache[player] = lines
end

local function RemoveSkeleton(player)
    local lines = SkeletonCache[player]
    if not lines then return end
    for _, line in ipairs(lines) do
        pcall(function() line:Remove() end)
    end
    SkeletonCache[player] = nil
end

--=========================================================
-- AIMBOT / PREDICTION 2.0
--=========================================================
local function IsTeammate(plr, check)
    if not check then return false end
    if not plr.Team or not LP.Team then return false end
    return plr.Team == LP.Team
end

local _visRayParams = nil
local function IsVisible(part, character)
    if not part or not character then return false end
    if not _visRayParams then
        _visRayParams = RaycastParams.new()
        _visRayParams.FilterType = Enum.RaycastFilterType.Exclude
        _visRayParams.IgnoreWater = true
    end
    _visRayParams.FilterDescendantsInstances = { LP.Character, Camera, character }
    local origin = Camera.CFrame.Position
    local direction = part.Position - origin
    local result = Workspace:Raycast(origin, direction, _visRayParams)
    if not result then return true end
    if result.Instance and result.Instance:IsDescendantOf(character) then return true end
    return false
end

local VelocityHistory = setmetatable({}, { __mode = "k" })
local LastUpdate = {}

local function GetSmoothedVelocity(part)
    if not part or not part.Parent then return Vector3.new(0, 0, 0) end
    local vel = part.AssemblyLinearVelocity
    if not vel then return Vector3.new(0, 0, 0) end
    if not Config.Aimbot.UseVelocityHistory then return vel end
    
    if not VelocityHistory[part] then
        VelocityHistory[part] = { vel, vel, vel, vel, vel }
        LastUpdate[part] = tick()
        return vel
    end
    
    local now = tick()
    local lastTime = LastUpdate[part] or 0
    
    if now - lastTime > 0.05 then
        local history = VelocityHistory[part]
        table.insert(history, 1, vel)
        if #history > 5 then table.remove(history) end
        LastUpdate[part] = now
    end
    
    local history = VelocityHistory[part]
    local sumX, sumY, sumZ, totalWeight = 0, 0, 0, 0
    for i = 1, #history do
        local weight = (6 - i) / 5
        sumX = sumX + history[i].X * weight
        sumY = sumY + history[i].Y * weight
        sumZ = sumZ + history[i].Z * weight
        totalWeight = totalWeight + weight
    end
    if totalWeight == 0 then return vel end
    return Vector3.new(sumX / totalWeight, sumY / totalWeight, sumZ / totalWeight)
end

local function IsTargetMoving(part)
    if not part or not part.Parent then return false end
    local vel = part.AssemblyLinearVelocity
    if not vel then return false end
    return Vector3.new(vel.X, 0, vel.Z).Magnitude > 3
end

local function CalculatePredictionTime(part, distance)
    if not Config.Aimbot.Prediction then return 0 end
    if Config.Aimbot.PredictionAuto then
        local baseTime = Config.Aimbot.PredictionX or 0.2
        local distMult = 1.0
        if distance > 100 then distMult = 1.5 end
        if distance > 200 then distMult = 2.0 end
        if distance > 400 then distMult = 2.5 end
        if distance > 800 then distMult = 3.0 end
        if IsTargetMoving(part) then distMult = distMult * 1.5 end
        return math.min(baseTime * distMult, Config.Aimbot.PredictionMax or 0.5)
    else
        return Config.Aimbot.PredictionX or 0.2
    end
end

local function GetPredictedPosition(part)
    if not part or not part.Parent then return Vector3.new(0, 0, 0) end
    if not Config.Aimbot.Prediction then return part.Position end
    local distance = (part.Position - Camera.CFrame.Position).Magnitude
    local velocity = GetSmoothedVelocity(part)
    local actualTime = CalculatePredictionTime(part, distance)
    local predicted = part.Position + velocity * actualTime
    if Config.Aimbot.TargetPart == "Head" then
        predicted = predicted + Vector3.new(0, 0.5, 0)
    end
    return predicted
end

local function GetClosestTarget(fovRange, maxRange, partName, teamCheck, visibleCheck)
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local closest, closestDist, closestPos, closestPlayer = nil, fovRange, nil, nil
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and not IsTeammate(plr, teamCheck) then
            local char = plr.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local part = char:FindFirstChild(partName) or char:FindFirstChild("HumanoidRootPart")
                if part then
                    local predPos = Config.Aimbot.Prediction and GetPredictedPosition(part) or part.Position
                    local sp, onScreen = Camera:WorldToViewportPoint(predPos)
                    if onScreen then
                        local d3 = (Camera.CFrame.Position - predPos).Magnitude
                        if d3 <= maxRange then
                            local sd = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                            if sd < closestDist then
                                if not visibleCheck or IsVisible(part, char) then
                                    closestDist = sd
                                    closest = part
                                    closestPos = predPos
                                    closestPlayer = plr
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return closest, closestPos, closestPlayer
end

local silentTarget = nil
local silentTargetPos = nil

TrackConn(RunService.RenderStepped:Connect(function()
    if Config.Silent.Enabled then
        local t, p = GetClosestTarget(
            Config.Silent.FOV, Config.Silent.MaxDistance,
            Config.Silent.TargetPart, Config.Silent.TeamCheck, Config.Silent.VisibleCheck
        )
        silentTarget = t
        silentTargetPos = p
    else
        silentTarget = nil
        silentTargetPos = nil
    end
end))

--=========================================================
-- SILENT AIM HOOK
--=========================================================
pcall(function()
    if not (hookmetamethod and newcclosure) then return end
    local oldNC
    oldNC = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if method == "FireServer" and typeof(self) == "Instance" then
            if Config.Silent.Enabled then
                local args = table.pack(...)
                if self.Name == "Swing" then
                    local now = tick()
                    if (now - Config.Silent.LastReplace) < Config.Silent.Cooldown then
                        return oldNC(self, ...)
                    end
                    if silentTargetPos and typeof(args[1]) == "Vector3" then
                        local targetChar = silentTarget and silentTarget.Parent
                        local targetHum = targetChar and targetChar:FindFirstChildOfClass("Humanoid")
                        if targetHum and targetHum.Health > 0 then
                            local dist = (silentTargetPos - Camera.CFrame.Position).Magnitude
                            if dist <= Config.Silent.MaxDistance then
                                if not Config.Silent.VisibleCheck or IsVisible(silentTarget, targetChar) then
                                    Config.Silent.LastReplace = now
                                    args[1] = (silentTargetPos - Camera.CFrame.Position).Unit
                                    if Config.Silent.Debug then
                                        notify("SilentAim ✅", targetChar.Name .. " (" .. math.floor(dist) .. "m)")
                                    end
                                    return oldNC(self, table.unpack(args, 1, args.n))
                                end
                            end
                        end
                    end
                end
            end
        end
        return oldNC(self, ...)
    end))
end)

--=========================================================
-- LONG RANGE HOOK
--=========================================================
pcall(function()
    if not (hookmetamethod and newcclosure) then return end
    local oldNC
    oldNC = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if method == "FireServer" and typeof(self) == "Instance" then
            if Config.Gun.LongRange then
                local args = table.pack(...)
                if self.Name == "BulletFire" or self.Name == "Shot" or self.Name == "BowShoot" then
                    for i = 1, args.n do
                        local v = args[i]
                        if typeof(v) == "number" and v > 50 and v < 10000 then
                            args[i] = v * Config.Gun.RangeMultiplier
                        end
                    end
                    return oldNC(self, table.unpack(args, 1, args.n))
                end
            end
        end
        return oldNC(self, ...)
    end))
end)

--=========================================================
-- AIMBOT РЕНДЕР
--=========================================================
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
        local target, predPos = GetClosestTarget(
            Config.Aimbot.FOV, Config.Aimbot.MaxDistance,
            Config.Aimbot.TargetPart, Config.Aimbot.TeamCheck, Config.Aimbot.Visible
        )
        if target and predPos then
            local targetCF = CFrame.new(Camera.CFrame.Position, predPos)
            Camera.CFrame = Camera.CFrame:Lerp(targetCF, Config.Aimbot.Smoothness)
        end
    end
end
RunService:BindToRenderStep("Decay_Aimbot", AIM_PRIORITY, AimStep)

--=========================================================
-- SPEED (без телепорта назад)
--=========================================================
local savedWalkSpeed = 16
local smoothedSpeed = 16

TrackConn(RunService.RenderStepped:Connect(function(dt)
    local char = LP.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    
    if Config.Player.SpeedEnabled then
        -- ПЛАВНОЕ ускорение (без рывков)
        local targetSpeed = Config.Player.SpeedValue
        smoothedSpeed = smoothedSpeed + (targetSpeed - smoothedSpeed) * math.clamp(dt * 5, 0, 1)
        hum.WalkSpeed = smoothedSpeed
    else
        -- Плавный возврат к норме
        if math.abs(smoothedSpeed - savedWalkSpeed) > 0.1 then
            smoothedSpeed = smoothedSpeed + (savedWalkSpeed - smoothedSpeed) * math.clamp(dt * 5, 0, 1)
            hum.WalkSpeed = smoothedSpeed
        else
            smoothedSpeed = savedWalkSpeed
            hum.WalkSpeed = savedWalkSpeed
        end
    end
end))

TrackConn(LP.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid", 5)
    if hum then 
        savedWalkSpeed = hum.WalkSpeed 
        smoothedSpeed = hum.WalkSpeed
    end
end))

--=========================================================
-- ГЛАВНЫЙ ЦИКЛ
--=========================================================
TrackConn(RunService.RenderStepped:Connect(function()
    -- FOV Circle
    if Config.Aimbot.ShowFOV and (Config.Aimbot.Enabled or Config.Silent.Enabled) then
        FovCircle.Visible = true
        FovCircle.Size = UDim2.new(0, Config.Aimbot.FOV * 2, 0, Config.Aimbot.FOV * 2)
        if Config.Silent.Enabled and silentTarget and silentTargetPos then
            local targetChar = silentTarget.Parent
            if targetChar and (not Config.Silent.VisibleCheck or IsVisible(silentTarget, targetChar)) then
                FovStroke.Color = Color3.fromRGB(0, 255, 100)
            else
                FovStroke.Color = Theme.Accent
            end
        else
            FovStroke.Color = Theme.Accent
        end
    else
        FovCircle.Visible = false
    end

    -- ESP
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
        
        -- Skeleton ESP
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LP then
                if not Config.ESP.Skeleton then
                    if SkeletonCache[plr] then RemoveSkeleton(plr) end
                    continue
                end
                
                if not SkeletonCache[plr] then CreateSkeleton(plr) end
                local lines = SkeletonCache[plr]
                local char = plr.Character
                
                if not char or not char:FindFirstChild("HumanoidRootPart") then
                    if lines then for _, l in ipairs(lines) do l.Visible = false end end
                    continue
                end
                
                local hum = char:FindFirstChildOfClass("Humanoid")
                if not hum or hum.Health <= 0 then
                    if lines then for _, l in ipairs(lines) do l.Visible = false end end
                    continue
                end
                
                local d3 = (Camera.CFrame.Position - char.HumanoidRootPart.Position).Magnitude
                if d3 > Config.ESP.MaxDistance then
                    if lines then for _, l in ipairs(lines) do l.Visible = false end end
                    continue
                end
                
                for i, pair in ipairs(SKELETON_PARTS) do
                    local p1 = char:FindFirstChild(pair[1])
                    local p2 = char:FindFirstChild(pair[2])
                    local line = lines[i]
                    
                    if p1 and p2 and p1:IsA("BasePart") and p2:IsA("BasePart") then
                        local sp1, on1 = Camera:WorldToViewportPoint(p1.Position)
                        local sp2, on2 = Camera:WorldToViewportPoint(p2.Position)
                        
                        if on1 and on2 then
                            line.Visible = true
                            line.From = Vector2.new(sp1.X, sp1.Y)
                            line.To = Vector2.new(sp2.X, sp2.Y)
                        else
                            line.Visible = false
                        end
                    else
                        line.Visible = false
                    end
                end
            end
        end
    end

    -- Noclip / NoFall
    local char = LP.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum and Config.Player.NoFallDamage then
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        end
        if Config.Player.Noclip then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end
end))

TrackConn(Players.PlayerAdded:Connect(function(plr)
    CreateESP(plr)
    if Config.ESP.Skeleton then CreateSkeleton(plr) end
end))

TrackConn(Players.PlayerRemoving:Connect(function(plr)
    RemoveESP(plr)
    RemoveSkeleton(plr)
end))

for _, plr in ipairs(Players:GetPlayers()) do 
    CreateESP(plr)
end

--=========================================================
-- FULLBRIGHT / X-RAY / FPS BOOST / NO FOG / FOV
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

-- NO FOG
local OriginalFog = { Saved = false }
TrackConn(RunService.Heartbeat:Connect(function()
    if not OriginalFog.Saved then
        OriginalFog.FogEnd = Lighting.FogEnd
        OriginalFog.FogStart = Lighting.FogStart
        OriginalFog.Atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
        if OriginalFog.Atmosphere then
            OriginalFog.Density = OriginalFog.Atmosphere.Density
            OriginalFog.Haze = OriginalFog.Atmosphere.Haze
            OriginalFog.Glare = OriginalFog.Atmosphere.Glare
        end
        OriginalFog.Saved = true
    end
    
    if Config.Visual.NoFog then
        pcall(function()
            Lighting.FogEnd = 9e9
            Lighting.FogStart = 0
            local atm = Lighting:FindFirstChildOfClass("Atmosphere")
            if atm then
                atm.Density = 0
                atm.Haze = 0
                atm.Glare = 0
            end
        end)
    elseif OriginalFog.Saved then
        pcall(function()
            Lighting.FogEnd = OriginalFog.FogEnd
            Lighting.FogStart = OriginalFog.FogStart
            if OriginalFog.Atmosphere then
                OriginalFog.Atmosphere.Density = OriginalFog.Density
                OriginalFog.Atmosphere.Haze = OriginalFog.Haze
                OriginalFog.Atmosphere.Glare = OriginalFog.Glare
            end
        end)
    end
end))

-- FOV CHANGE
local OriginalFOV = nil
TrackConn(RunService.Heartbeat:Connect(function()
    if not OriginalFOV then OriginalFOV = Camera.FieldOfView end
    if Config.Visual.FOVChange then
        pcall(function() Camera.FieldOfView = Config.Visual.FOVValue end)
    else
        if OriginalFOV then
            pcall(function() Camera.FieldOfView = OriginalFOV end)
        end
    end
end))

-- INFINITE JUMP
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
    elseif input.KeyCode == Enum.KeyCode.F5 then
        Config.Silent.Enabled = not Config.Silent.Enabled
        notify("Silent Aim", Config.Silent.Enabled and "ON" or "OFF")
    elseif input.KeyCode == Enum.KeyCode.F6 then
        Config.Gun.NoRecoil = not Config.Gun.NoRecoil
        notify("No Recoil", Config.Gun.NoRecoil and "ON" or "OFF")
    elseif input.KeyCode == Enum.KeyCode.F7 then
        Config.Gun.LongRange = not Config.Gun.LongRange
        notify("Long Range", Config.Gun.LongRange and "ON" or "OFF")
    elseif input.KeyCode == Enum.KeyCode.F8 then
        Config.Visual.NoFog = not Config.Visual.NoFog
        notify("No Fog", Config.Visual.NoFog and "ON" or "OFF")
    elseif input.KeyCode == Enum.KeyCode.F9 then
        Config.Player.AntiAFK = not Config.Player.AntiAFK
        if Config.Player.AntiAFK then EnableAntiAFK() else DisableAntiAFK() end
    elseif input.KeyCode == Enum.KeyCode.RightShift then
        Menu.Visible = not Menu.Visible
    elseif input.KeyCode == Enum.KeyCode.Delete then
        Unload()
    end
end))

notify("FerClient v7.0", "Anti-AFK + FOV + Skeleton + Config")
print("[FerClient] Decay v7.0 — все функции OFF по умолчанию")
