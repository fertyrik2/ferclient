--[[
    FerClient v5 | Null-wave Style
    Rusted — Silent Aim + ESP + All Features
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
local StarterGui = game:GetService("StarterGui")
local Camera = Workspace.CurrentCamera
local LP = Players.LocalPlayer

--=========================================================
-- ТЕМА (Null-wave стиль)
--=========================================================
local Theme = {
    Background   = Color3.fromRGB(15, 15, 20),
    Panel        = Color3.fromRGB(18, 18, 25),
    Tab          = Color3.fromRGB(22, 22, 30),
    TabActive    = Color3.fromRGB(130, 100, 220),
    Element      = Color3.fromRGB(25, 25, 35),
    Hover        = Color3.fromRGB(35, 35, 50),
    Accent       = Color3.fromRGB(130, 100, 220),   -- фиолетовый
    AccentDim    = Color3.fromRGB(90, 70, 160),
    Success      = Color3.fromRGB(130, 100, 220),   -- фиолетовый для ON
    Danger       = Color3.fromRGB(80, 80, 100),     -- серый для OFF
    Text         = Color3.fromRGB(230, 230, 240),
    TextDim      = Color3.fromRGB(120, 120, 140),
    Border       = Color3.fromRGB(40, 40, 55),
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
        Skeleton = false, Weapon = false,
        MaxDistance = 1500, Radius = 915,
        Color = Theme.Accent,
    },
    Aimbot = {
        Enabled = false, AutoAim = false, FOV = 200, Smoothness = 0.5,
        MaxDistance = 600, TargetPart = "Head", Visible = false,
        TeamCheck = true, ShowFOV = true, TriggerActive = false,
        Prediction = true, PredictionX = 0.15,
    },
    Silent = {
        Enabled = false, TargetPart = "Head", Visible = false,
        TeamCheck = true, FOV = 250, MaxDistance = 800,
        Prediction = true, PredictionX = 0.15,
        DebugChat = false,
    },
    Player = {
        NoFallDamage = false,
        SpeedEnabled = false, SpeedValue = 30,
        Noclip = false,
    },
    Visual = {
        Fullbright = false, XRay = false, XRayTransparency = 0.5,
        FPSBoost = false,
        ArmChams = false, GunChams = false,
        Ambient = false,
    },
    Misc = {
        InfiniteJump = false, HitLogs = true,
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
-- ФУНКЦИЯ: вывод в чат
--=========================================================
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
-- ГЛАВНЫЙ GUI
--=========================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FerClient_Nullwave"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 100
pcall(function() ScreenGui.Parent = HUI end)
if not ScreenGui.Parent then ScreenGui.Parent = LP:WaitForChild("PlayerGui") end

-- Меню — по размеру как на скрине (450x280)
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

-- Верхний заголовок (как "Null-wave.lua")
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 28)
TopBar.BackgroundColor3 = Theme.Background
TopBar.BorderSizePixel = 0
TopBar.Parent = Menu

local Logo = Instance.new("TextLabel")
Logo.Size = UDim2.new(1, -80, 1, 0)
Logo.Position = UDim2.new(0, 12, 0, 0)
Logo.BackgroundTransparency = 1
Logo.Text = "FerClient.lua"
Logo.TextColor3 = Theme.Text
Logo.Font = Theme.FontBold
Logo.TextSize = 13
Logo.TextXAlignment = Enum.TextXAlignment.Left
Logo.Parent = TopBar

-- Кнопки закрытия/сворачивания справа
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 18, 0, 18)
MinimizeBtn.Position = UDim2.new(1, -48, 0, 5)
MinimizeBtn.BackgroundTransparency = 1
MinimizeBtn.Text = "—"
MinimizeBtn.TextColor3 = Theme.TextDim
MinimizeBtn.Font = Theme.FontBold
MinimizeBtn.TextSize = 12
MinimizeBtn.AutoButtonColor = false
MinimizeBtn.Parent = TopBar

local UnloadBtn = Instance.new("TextButton")
UnloadBtn.Size = UDim2.new(0, 18, 0, 18)
UnloadBtn.Position = UDim2.new(1, -25, 0, 5)
UnloadBtn.BackgroundTransparency = 1
UnloadBtn.Text = "✕"
UnloadBtn.TextColor3 = Theme.TextDim
UnloadBtn.Font = Theme.FontBold
UnloadBtn.TextSize = 11
UnloadBtn.AutoButtonColor = false
UnloadBtn.Parent = TopBar

--=========================================================
-- КОНТЕНТ (2 колонки)
--=========================================================
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -20, 1, -56)
Content.Position = UDim2.new(0, 10, 0, 32)
Content.BackgroundTransparency = 1
Content.Parent = Menu

-- Левая колонка
local LeftColumn = Instance.new("Frame")
LeftColumn.Size = UDim2.new(0.5, -5, 1, 0)
LeftColumn.Position = UDim2.new(0, 0, 0, 0)
LeftColumn.BackgroundTransparency = 1
LeftColumn.Parent = Content

local LeftLayout = Instance.new("UIListLayout", LeftColumn)
LeftLayout.Padding = UDim.new(0, 4)
LeftLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Правая колонка
local RightColumn = Instance.new("Frame")
RightColumn.Size = UDim2.new(0.5, -5, 1, 0)
RightColumn.Position = UDim2.new(0.5, 5, 0, 0)
RightColumn.BackgroundTransparency = 1
RightColumn.Parent = Content

local RightLayout = Instance.new("UIListLayout", RightColumn)
RightLayout.Padding = UDim.new(0, 4)
RightLayout.SortOrder = Enum.SortOrder.LayoutOrder

--=========================================================
-- НИЖНИЕ ВКЛАДКИ
--=========================================================
local BottomTabs = Instance.new("Frame")
BottomTabs.Size = UDim2.new(1, 0, 0, 22)
BottomTabs.Position = UDim2.new(0, 0, 1, -26)
BottomTabs.BackgroundColor3 = Theme.Background
BottomTabs.BorderSizePixel = 0
BottomTabs.Parent = Menu

local BottomLayout = Instance.new("UIListLayout", BottomTabs)
BottomLayout.FillDirection = Enum.FillDirection.Horizontal
BottomLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
BottomLayout.SortOrder = Enum.SortOrder.LayoutOrder
BottomLayout.Padding = UDim.new(0, 20)
BottomLayout.Parent = BottomTabs

local tabs = {}
local activeTabName = "Combat"

local function CreateBottomTab(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 60, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = name
    btn.TextColor3 = Theme.TextDim
    btn.Font = Theme.Font
    btn.TextSize = 11
    btn.AutoButtonColor = false
    btn.Parent = BottomTabs

    local tab = { Btn = btn, Name = name }
    btn.MouseButton1Click:Connect(function()
        activeTabName = name
        for _, t in ipairs(tabs) do
            local isActive = (t.Name == name)
            t.Btn.TextColor3 = isActive and Theme.Text or Theme.TextDim
            t.Btn.Font = isActive and Theme.FontBold or Theme.Font
        end
    end)
    tabs[#tabs + 1] = tab
    return tab
end

local CombatTab = CreateBottomTab("Combat")
local VisualTab = CreateBottomTab("Visual")
local MovementTab = CreateBottomTab("Movement")
local MiscTab = CreateBottomTab("Misc")
local SettingsTab = CreateBottomTab("Settings")

-- Активная по умолчанию
CombatTab.Btn.TextColor3 = Theme.Text
CombatTab.Btn.Font = Theme.FontBold

--=========================================================
-- ТУМБЛЕР (переключатель в стиле Null-wave)
--=========================================================
local function MakeToggle(parent, text, defaultOn, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 24)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -50, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Theme.Text
    label.Font = Theme.Font
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    -- Тумблер
    local track = Instance.new("Frame")
    track.Size = UDim2.new(0, 30, 0, 16)
    track.Position = UDim2.new(1, -32, 0.5, -8)
    track.BackgroundColor3 = Theme.Danger
    track.BorderSizePixel = 0
    track.Parent = frame
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.AnchorPoint = Vector2.new(0, 0.5)
    knob.Size = UDim2.new(0, 12, 0, 12)
    knob.Position = UDim2.new(0, 2, 0.5, 0)
    knob.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
    knob.BorderSizePixel = 0
    knob.Parent = track
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local isOn = false

    local function applyState()
        if isOn then
            track.BackgroundColor3 = Theme.Success
            TweenService:Create(knob, TweenInfo.new(0.15), {
                Position = UDim2.new(1, -14, 0.5, 0)
            }):Play()
        else
            track.BackgroundColor3 = Theme.Danger
            TweenService:Create(knob, TweenInfo.new(0.15), {
                Position = UDim2.new(0, 2, 0.5, 0)
            }):Play()
        end
    end

    isOn = defaultOn or false
    applyState()

    local click = Instance.new("TextButton")
    click.Size = UDim2.new(1, 0, 1, 0)
    click.BackgroundTransparency = 1
    click.Text = ""
    click.AutoButtonColor = false
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

    return {
        Frame = frame,
        SetOn = function(v)
            isOn = v and true or false
            applyState()
        end
    }
end

--=========================================================
-- СЛАЙДЕР (компактный)
--=========================================================
local function MakeSlider(parent, text, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 28)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Theme.Text
    label.Font = Theme.Font
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0, 40, 1, 0)
    valueLabel.Position = UDim2.new(1, -40, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(default)
    valueLabel.TextColor3 = Theme.Accent
    valueLabel.Font = Theme.FontBold
    valueLabel.TextSize = 11
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = frame

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -90, 0, 4)
    track.Position = UDim2.new(0, 45, 0.5, -2)
    track.BackgroundColor3 = Theme.Element
    track.BorderSizePixel = 0
    track.Parent = frame
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Theme.Accent
    fill.BorderSizePixel = 0
    fill.Parent = track
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Size = UDim2.new(0, 10, 0, 10)
    knob.Position = UDim2.new((default - min) / (max - min), 0, 0.5, 0)
    knob.BackgroundColor3 = Theme.Text
    knob.BorderSizePixel = 0
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
-- ЗАГОЛОВОК СЕКЦИИ (как "Player ESP" слева)
--=========================================================
local function MakeSectionTitle(parent, text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 18)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Theme.TextDim
    lbl.Font = Theme.FontBold
    lbl.TextSize = 10
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = parent
    return lbl
end

--=========================================================
-- ЛЕВАЯ КОЛОНКА: Player ESP
--=========================================================
MakeSectionTitle(LeftColumn, "Player ESP")

MakeToggle(LeftColumn, "Box ESP", true, function()
    Config.ESP.Box = not Config.ESP.Box
end)

MakeToggle(LeftColumn, "Tracers", true, function()
    Config.ESP.Tracer = not Config.ESP.Tracer
end)

MakeToggle(LeftColumn, "Names", true, function()
    Config.ESP.Name = not Config.ESP.Name
end)

MakeToggle(LeftColumn, "HP Bar", true, function()
    Config.ESP.Health = not Config.ESP.Health
end)

MakeToggle(LeftColumn, "Distance", true, function()
    Config.ESP.Distance = not Config.ESP.Distance
end)

MakeToggle(LeftColumn, "Weapon", false, function()
    Config.ESP.Weapon = not Config.ESP.Weapon
end)

MakeToggle(LeftColumn, "Skeleton", false, function()
    Config.ESP.Skeleton = not Config.ESP.Skeleton
end)

MakeSlider(LeftColumn, "Radius", 100, 2000, Config.ESP.Radius, function(v)
    Config.ESP.Radius = v
    Config.ESP.MaxDistance = v
end)

--=========================================================
-- ПРАВАЯ КОЛОНКА: Customisation
--=========================================================
MakeSectionTitle(RightColumn, "Customisation")

MakeToggle(RightColumn, "Custom FOV", false, function()
    -- FOV circle show
    Config.Aimbot.ShowFOV = not Config.Aimbot.ShowFOV
end)

MakeSlider(RightColumn, "FOV Value", 30, 600, Config.Aimbot.FOV, function(v)
    Config.Aimbot.FOV = v
    Config.Silent.FOV = v
    if FovCircle then FovCircle.Size = UDim2.new(0, v * 2, 0, v * 2) end
end)

MakeToggle(RightColumn, "Zoom", false, function()
    -- Zoom is just placeholder for now
end)

MakeToggle(RightColumn, "Arm Chams", false, function()
    Config.Visual.ArmChams = not Config.Visual.ArmChams
end)

MakeToggle(RightColumn, "Gun Chams", false, function()
    Config.Visual.GunChams = not Config.Visual.GunChams
end)

MakeToggle(RightColumn, "World Particle", false, function()
    -- placeholder
end)

MakeToggle(RightColumn, "Ambience", false, function()
    Config.Visual.Ambient = not Config.Visual.Ambient
end)

--=========================================================
-- ТОЛЬКО ОСНОВНЫЕ ЭЛЕМЕНТЫ ВИДНЫ (как на скрине)
-- Дополнительные функции в других вкладках (не видны)
-- но работают через хоткеи
--=========================================================

--=========================================================
-- КНОПКА FC (открыть/закрыть)
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

local lastToggle = 0
ToggleBtn.MouseButton1Click:Connect(function()
    local now = tick()
    if now - lastToggle < 0.3 then return end
    lastToggle = now
    Menu.Visible = not Menu.Visible
end)

--=========================================================
-- СВОРАЧИВАНИЕ / UNLOAD
--=========================================================
local isMinimized = false
local function toggleMinimize()
    isMinimized = not isMinimized
    Menu.Size = isMinimized and UDim2.new(0, 450, 0, 28) or UDim2.new(0, 450, 0, 280)
    Content.Visible = not isMinimized
    BottomTabs.Visible = not isMinimized
end

local lastMinClick = 0
MinimizeBtn.MouseButton1Click:Connect(function()
    local now = tick()
    if now - lastMinClick < 0.25 then return end
    lastMinClick = now
    toggleMinimize()
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
    print("[FerClient] v5 — Выгружен.")
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
-- AIMBOT / SILENT
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

local function GetClosestTarget(fovRange, maxRange, partName, visibleCheck, teamCheck)
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local closest, closestDist, closestPos = nil, fovRange, nil
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then
            if not (teamCheck and IsTeammate(plr)) then
                local char = plr.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    local part = char:FindFirstChild(partName)
                    if part then
                        local predPos = Config.Aimbot.Prediction
                            and GetPredictedPosition(part, Config.Aimbot.PredictionX)
                            or part.Position
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
            Config.Aimbot.TargetPart, Config.Aimbot.Visible, Config.Aimbot.TeamCheck
        )
        if target and predPos then
            local targetCF = CFrame.new(Camera.CFrame.Position, predPos)
            Camera.CFrame = Camera.CFrame:Lerp(targetCF, Config.Aimbot.Smoothness)
        end
    end

    if Config.Silent.Enabled then
        local st, sp = GetClosestTarget(
            Config.Silent.FOV, Config.Silent.MaxDistance,
            Config.Silent.TargetPart, Config.Silent.Visible, Config.Silent.TeamCheck
        )
        silentTarget = st
        silentTargetPos = sp
    else
        silentTarget = nil
        silentTargetPos = nil
    end
end

RunService:BindToRenderStep("FerClient_Rusted_Aimbot", AIM_PRIORITY, AimStep)

--=========================================================
-- SILENT AIM HOOKS
--=========================================================
pcall(function()
    if not (hookmetamethod and newcclosure) then return end

    local OldNC
    OldNC = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()

        if (method == "FireServer" or method == "InvokeServer") and typeof(self) == "Instance" then
            local args = table.pack(...)

            if Config.Silent.DebugChat and Config.Silent.Enabled then
                local argsStr = ""
                for i = 1, args.n do
                    argsStr = argsStr .. i .. ":" .. typeof(args[i]) .. " "
                end
                chatMessage("[REMOTE] " .. self.Name .. " | " .. argsStr, Theme.Accent)
            end

            if Config.Silent.Enabled and silentTargetPos then
                local newArgs = {}
                local replaced = false
                for i = 1, args.n do
                    local v = args[i]
                    if typeof(v) == "Vector3" then
                        newArgs[i] = silentTargetPos
                        replaced = true
                    elseif typeof(v) == "CFrame" then
                        newArgs[i] = CFrame.new(silentTargetPos)
                        replaced = true
                    else
                        newArgs[i] = v
                    end
                end
                if replaced then
                    return OldNC(self, table.unpack(newArgs, 1, args.n))
                end
            end
        end

        return OldNC(self, ...)
    end))
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
    end)
    pcall(function()
        setfflag("DFIntTaskSchedulerTargetFps", "240")
        setfflag("FFlagDisablePostFx", "true")
    end)
end

TrackConn(RunService.Heartbeat:Connect(function()
    if Config.Visual.FPSBoost then applyFPSBoost() end
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
-- ESP ЦИКЛ
--=========================================================
TrackConn(RunService.RenderStepped:Connect(function()
    if Config.Aimbot.ShowFOV and (Config.Aimbot.Enabled or Config.Silent.Enabled) then
        FovCircle.Visible = true
        FovCircle.Size = UDim2.new(0, Config.Aimbot.FOV * 2, 0, Config.Aimbot.FOV * 2)
        FovCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
        if Config.Silent.Enabled and silentTarget then
            FovStroke.Color = Theme.Success
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
-- ХОТКЕИ (работают все функции, даже невидимые в меню)
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
    elseif input.KeyCode == Enum.KeyCode.F6 then
        Config.Silent.DebugChat = not Config.Silent.DebugChat
    elseif input.KeyCode == Enum.KeyCode.F7 then
        Config.Player.SpeedEnabled = not Config.Player.SpeedEnabled
    elseif input.KeyCode == Enum.KeyCode.F8 then
        Config.Player.Noclip = not Config.Player.Noclip
    elseif input.KeyCode == Enum.KeyCode.RightShift then
        Menu.Visible = not Menu.Visible
    elseif input.KeyCode == Enum.KeyCode.Delete then
        Unload()
    end
end))

chatMessage("[FerClient] v5 Null-wave загружен", Theme.Accent)
print("[FerClient] v5 загружен")
