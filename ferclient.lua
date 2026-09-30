--[[
    ███████╗███████╗██████╗  ██████╗██╗     ██╗███████╗███╗   ██╗████████╗
    ██╔════╝██╔════╝██╔══██╗██╔════╝██║     ██║██╔════╝████╗  ██║╚══██╔══╝
    █████╗  █████╗  ██████╔╝██║     ██║     ██║█████╗  ██╔██╗ ██║   ██║
    ██╔══╝  ██╔══╝  ██╔══██╗██║     ██║     ██║██╔══╝  ██║╚██╗██║   ██║
    ██║     ███████╗██║  ██║╚██████╗███████╗██║███████╗██║ ╚████║   ██║
    ╚═╝     ╚══════╝╚═╝  ╚═╝ ╚═════╝╚══════╝╚═╝╚══════╝╚═╝  ╚═══╝   ╚═╝

    FerClient v1.1 | Rost Alpha
    ESP + Aimbot FOV | Mobile & PC
]]

if getgenv().FerClient_Loaded then
    warn("[FerClient] Уже загружен!")
    return
end
getgenv().FerClient_Loaded = true

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local HUI = (gethui and gethui()) or game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LP = Players.LocalPlayer

--=========================================================
-- ТЕМА
--=========================================================
local Theme = {
    Background = Color3.fromRGB(25, 45, 90),
    Panel      = Color3.fromRGB(35, 60, 115),
    Element    = Color3.fromRGB(45, 75, 140),
    Hover      = Color3.fromRGB(60, 95, 170),
    Accent     = Color3.fromRGB(90, 160, 255),
    Success    = Color3.fromRGB(80, 220, 120),
    Danger     = Color3.fromRGB(255, 90, 90),
    Text       = Color3.fromRGB(240, 245, 255),
    TextDim    = Color3.fromRGB(170, 190, 220),
    Border     = Color3.fromRGB(70, 110, 180),
    Font       = Enum.Font.GothamMedium,
    FontBold   = Enum.Font.GothamBold,
}

--=========================================================
-- НАСТРОЙКИ
--=========================================================
local Config = {
    ESP = {
        Enabled = true,
        Box = true, Name = true, Distance = true, Health = true, Tracer = true,
        Color = Theme.Accent, MaxDistance = 1500,
    },
    Aimbot = {
        Enabled = false,
        FOV = 200,              -- Радиус аима (меняется слайдером)
        Smoothness = 0.4,       -- Плавность (0.1 = медленно, 1 = мгновенно)
        MaxDistance = 600,      -- Дальность захвата
        TargetPart = "Head",
        Visible = false,        -- проверка стен (по умолчанию выкл — чтобы работало)
        ShowFOV = true,
        TriggerActive = false,
    }
}

local hasDrawing = pcall(function()
    local t = Drawing.new("Square")
    t:Remove()
end)

--=========================================================
-- ЗАГРУЗОЧНЫЙ ЭКРАН
--=========================================================
local LoaderGui = Instance.new("ScreenGui")
LoaderGui.Name = "FerClient_Loader"
LoaderGui.ResetOnSpawn = false
LoaderGui.IgnoreGuiInset = true
LoaderGui.DisplayOrder = 9999
pcall(function() LoaderGui.Parent = HUI end)
if not LoaderGui.Parent then LoaderGui.Parent = LP:WaitForChild("PlayerGui") end

local LoaderBg = Instance.new("Frame")
LoaderBg.Size = UDim2.new(1, 0, 1, 0)
LoaderBg.BackgroundColor3 = Theme.Background
LoaderBg.BackgroundTransparency = 0.15
LoaderBg.BorderSizePixel = 0
LoaderBg.Parent = LoaderGui

local LoaderCard = Instance.new("Frame")
LoaderCard.AnchorPoint = Vector2.new(0.5, 0.5)
LoaderCard.Position = UDim2.new(0.5, 0, 0.5, 0)
LoaderCard.Size = UDim2.new(0, 300, 0, 140)
LoaderCard.BackgroundColor3 = Theme.Panel
LoaderCard.BorderSizePixel = 0
LoaderCard.Parent = LoaderBg
Instance.new("UICorner", LoaderCard).CornerRadius = UDim.new(0, 12)

local CardStroke = Instance.new("UIStroke", LoaderCard)
CardStroke.Color = Theme.Accent
CardStroke.Thickness = 2

local LogoText = Instance.new("TextLabel")
LogoText.Size = UDim2.new(1, 0, 0, 50)
LogoText.Position = UDim2.new(0, 0, 0, 30)
LogoText.BackgroundTransparency = 1
LogoText.Text = "FerClient"
LogoText.TextColor3 = Theme.Text
LogoText.Font = Theme.FontBold
LogoText.TextSize = 32
LogoText.Parent = LoaderCard

local SubText = Instance.new("TextLabel")
SubText.Size = UDim2.new(1, 0, 0, 20)
SubText.Position = UDim2.new(0, 0, 0, 78)
SubText.BackgroundTransparency = 1
SubText.Text = "ROST ALPHA • LOADING"
SubText.TextColor3 = Theme.TextDim
SubText.Font = Theme.Font
SubText.TextSize = 11
SubText.Parent = LoaderCard

local ProgressBg = Instance.new("Frame")
ProgressBg.Size = UDim2.new(0, 240, 0, 4)
ProgressBg.Position = UDim2.new(0.5, -120, 0, 115)
ProgressBg.BackgroundColor3 = Theme.Element
ProgressBg.BorderSizePixel = 0
ProgressBg.Parent = LoaderCard
Instance.new("UICorner", ProgressBg).CornerRadius = UDim.new(1, 0)

local ProgressFill = Instance.new("Frame")
ProgressFill.Size = UDim2.new(0, 0, 1, 0)
ProgressFill.BackgroundColor3 = Theme.Accent
ProgressFill.BorderSizePixel = 0
ProgressFill.Parent = ProgressBg
Instance.new("UICorner", ProgressFill).CornerRadius = UDim.new(1, 0)

task.spawn(function()
    for _, v in ipairs({ 0.3, 0.6, 0.85, 1 }) do
        TweenService:Create(ProgressFill, TweenInfo.new(0.25), { Size = UDim2.new(v, 0, 1, 0) }):Play()
        task.wait(0.3)
    end
    task.wait(0.2)
    TweenService:Create(LoaderBg, TweenInfo.new(0.4), { BackgroundTransparency = 1 }):Play()
    TweenService:Create(LoaderCard, TweenInfo.new(0.4), { BackgroundTransparency = 1 }):Play()
    task.wait(0.4)
    LoaderGui:Destroy()
end)

--=========================================================
-- МЕНЮ
--=========================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FerClient_Menu"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 100
pcall(function() ScreenGui.Parent = HUI end)
if not ScreenGui.Parent then ScreenGui.Parent = LP:WaitForChild("PlayerGui") end

local Menu = Instance.new("Frame")
Menu.Name = "FerClient_Frame"
Menu.Size = UDim2.new(0, 260, 0, 420)
Menu.Position = UDim2.new(0, 20, 0, 80)
Menu.BackgroundColor3 = Theme.Background
Menu.BorderSizePixel = 0
Menu.Active = true
Menu.Draggable = true
Menu.Parent = ScreenGui
Instance.new("UICorner", Menu).CornerRadius = UDim.new(0, 10)

local MenuStroke = Instance.new("UIStroke", Menu)
MenuStroke.Color = Theme.Border
MenuStroke.Thickness = 1.5

-- Топбар
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 38)
TopBar.BackgroundColor3 = Theme.Panel
TopBar.BorderSizePixel = 0
TopBar.Parent = Menu
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 10)

local TopBarCover = Instance.new("Frame")
TopBarCover.Size = UDim2.new(1, 0, 0, 10)
TopBarCover.Position = UDim2.new(0, 0, 1, -10)
TopBarCover.BackgroundColor3 = Theme.Panel
TopBarCover.BorderSizePixel = 0
TopBarCover.Parent = TopBar

local Dot = Instance.new("Frame")
Dot.Size = UDim2.new(0, 8, 0, 8)
Dot.Position = UDim2.new(0, 10, 0.5, -4)
Dot.BackgroundColor3 = Theme.Accent
Dot.BorderSizePixel = 0
Dot.Parent = TopBar
Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)

local Logo = Instance.new("TextLabel")
Logo.Size = UDim2.new(0, 150, 1, 0)
Logo.Position = UDim2.new(0, 25, 0, 0)
Logo.BackgroundTransparency = 1
Logo.Text = "FerClient"
Logo.TextColor3 = Theme.Text
Logo.Font = Theme.FontBold
Logo.TextSize = 16
Logo.TextXAlignment = Enum.TextXAlignment.Left
Logo.Parent = TopBar

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 20, 0, 20)
MinimizeBtn.Position = UDim2.new(1, -28, 0, 9)
MinimizeBtn.BackgroundColor3 = Theme.Element
MinimizeBtn.BorderSizePixel = 0
MinimizeBtn.Text = "—"
MinimizeBtn.TextColor3 = Theme.Text
MinimizeBtn.Font = Theme.FontBold
MinimizeBtn.TextSize = 12
MinimizeBtn.AutoButtonColor = false
MinimizeBtn.Parent = TopBar
Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 4)

-- Контейнер (со скроллом на случай переполнения)
local Content = Instance.new("ScrollingFrame")
Content.Size = UDim2.new(1, -16, 1, -50)
Content.Position = UDim2.new(0, 8, 0, 46)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 3
Content.ScrollBarImageColor3 = Theme.Accent
Content.CanvasSize = UDim2.new(0, 0, 0, 0)
Content.Parent = Menu

local Layout = Instance.new("UIListLayout", Content)
Layout.Padding = UDim.new(0, 6)
Layout.SortOrder = Enum.SortOrder.LayoutOrder

Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Content.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 10)
end)

--=========================================================
-- КНОПКА (улучшенная — меняет и фон, и текст)
--=========================================================
local function MakeButton(text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 38)
    btn.BackgroundColor3 = Theme.Element
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.Parent = Content
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = Theme.Border
    stroke.Thickness = 1

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -70, 1, 0)
    nameLabel.Position = UDim2.new(0, 14, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = text
    nameLabel.TextColor3 = Theme.Text
    nameLabel.Font = Theme.Font
    nameLabel.TextSize = 13
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = btn

    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(0, 45, 1, 0)
    statusLabel.Position = UDim2.new(1, -50, 0, 0)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "OFF"
    statusLabel.TextColor3 = Theme.Danger
    statusLabel.Font = Theme.FontBold
    statusLabel.TextSize = 11
    statusLabel.Parent = btn

    -- Hover
    btn.MouseEnter:Connect(function()
        if not btn:GetAttribute("On") then
            TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = Theme.Hover }):Play()
        end
    end)
    btn.MouseLeave:Connect(function()
        if not btn:GetAttribute("On") then
            TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = Theme.Element }):Play()
        end
    end)

    -- Клик (и мышь, и тач)
    local clickCooldown = false
    local function handleClick()
        if clickCooldown then return end
        clickCooldown = true
        task.delay(0.15, function() clickCooldown = false end)
        pcall(callback)
    end

    btn.MouseButton1Click:Connect(handleClick)
    btn.Activated:Connect(handleClick)

    return {
        Button = btn,
        SetOn = function(isOn)
            btn:SetAttribute("On", isOn)
            statusLabel.Text = isOn and "ON" or "OFF"
            statusLabel.TextColor3 = isOn and Theme.Success or Theme.Danger
            -- ВАЖНО: меняем ФОН кнопки тоже
            TweenService:Create(btn, TweenInfo.new(0.2), {
                BackgroundColor3 = isOn and Color3.fromRGB(40, 90, 60) or Theme.Element
            }):Play()
            TweenService:Create(stroke, TweenInfo.new(0.2), {
                Color = isOn and Theme.Success or Theme.Border
            }):Play()
        end
    }
end

--=========================================================
-- СЛАЙДЕР
--=========================================================
local function MakeSlider(text, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 52)
    frame.BackgroundColor3 = Theme.Element
    frame.BorderSizePixel = 0
    frame.Parent = Content
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

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
    nameLabel.Parent = frame

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0, 50, 0, 22)
    valueLabel.Position = UDim2.new(1, -55, 0, 4)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(default)
    valueLabel.TextColor3 = Theme.Accent
    valueLabel.Font = Theme.FontBold
    valueLabel.TextSize = 12
    valueLabel.Parent = frame

    -- Трек
    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -24, 0, 8)
    track.Position = UDim2.new(0, 12, 1, -20)
    track.BackgroundColor3 = Theme.Background
    track.BorderSizePixel = 0
    track.Parent = frame
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    -- Заполнение
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Theme.Accent
    fill.BorderSizePixel = 0
    fill.Parent = track
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    -- Кнопка-ползунок
    local knob = Instance.new("Frame")
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = UDim2.new((default - min) / (max - min), 0, 0.5, 0)
    knob.BackgroundColor3 = Theme.Text
    knob.BorderSizePixel = 0
    knob.Parent = track
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

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

    -- Тач/мышь вниз на треке
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

    return {
        Frame = frame,
        SetValue = function(v)
            local ratio = math.clamp((v - min) / (max - min), 0, 1)
            fill.Size = UDim2.new(ratio, 0, 1, 0)
            knob.Position = UDim2.new(ratio, 0, 0.5, 0)
            valueLabel.Text = tostring(v)
        end
    }
end

--=========================================================
-- КНОПКИ ESP
--=========================================================
local ESPButton = MakeButton("ESP", function()
    Config.ESP.Enabled = not Config.ESP.Enabled
    ESPButton.SetOn(Config.ESP.Enabled)
end)
ESPButton.SetOn(Config.ESP.Enabled)

local TracerButton = MakeButton("Tracers", function()
    Config.ESP.Tracer = not Config.ESP.Tracer
    TracerButton.SetOn(Config.ESP.Tracer)
end)
TracerButton.SetOn(Config.ESP.Tracer)

local HealthButton = MakeButton("Health Bar", function()
    Config.ESP.Health = not Config.ESP.Health
    HealthButton.SetOn(Config.ESP.Health)
end)
HealthButton.SetOn(Config.ESP.Health)

local AimButton = MakeButton("Aimbot", function()
    Config.Aimbot.Enabled = not Config.Aimbot.Enabled
    AimButton.SetOn(Config.Aimbot.Enabled)
end)
AimButton.SetOn(Config.Aimbot.Enabled)

local FovButton = MakeButton("FOV Circle", function()
    Config.Aimbot.ShowFOV = not Config.Aimbot.ShowFOV
    FovButton.SetOn(Config.Aimbot.ShowFOV)
end)
FovButton.SetOn(Config.Aimbot.ShowFOV)

--=========================================================
-- СЛАЙДЕРЫ ДЛЯ AIMBOT (НОВОЕ!)
--=========================================================
local FovSlider = MakeSlider("FOV Radius", 30, 600, Config.Aimbot.FOV, function(v)
    Config.Aimbot.FOV = v
    FovCircle.Size = UDim2.new(0, v * 2, 0, v * 2)
end)

local SmoothSlider = MakeSlider("Smoothness x100", 10, 100, math.floor(Config.Aimbot.Smoothness * 100), function(v)
    Config.Aimbot.Smoothness = v / 100
end)

local DistSlider = MakeSlider("Max Distance", 100, 2000, Config.Aimbot.MaxDistance, function(v)
    Config.Aimbot.MaxDistance = v
end)

--=========================================================
-- HOLD TO AIM
--=========================================================
local TriggerBtn = Instance.new("TextButton")
TriggerBtn.Size = UDim2.new(1, 0, 0, 44)
TriggerBtn.BackgroundColor3 = Theme.Accent
TriggerBtn.BorderSizePixel = 0
TriggerBtn.Text = "HOLD TO AIM"
TriggerBtn.TextColor3 = Color3.new(1, 1, 1)
TriggerBtn.Font = Theme.FontBold
TriggerBtn.TextSize = 13
TriggerBtn.AutoButtonColor = false
TriggerBtn.LayoutOrder = 100
TriggerBtn.Parent = Content
Instance.new("UICorner", TriggerBtn).CornerRadius = UDim.new(0, 6)

local function setTrigActive(active)
    Config.Aimbot.TriggerActive = active
    TweenService:Create(TriggerBtn, TweenInfo.new(0.1), {
        BackgroundColor3 = active and Color3.fromRGB(120, 180, 255) or Theme.Accent
    }):Play()
end

TriggerBtn.MouseButton1Down:Connect(function() setTrigActive(true) end)
TriggerBtn.MouseButton1Up:Connect(function() setTrigActive(false) end)
TriggerBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then setTrigActive(true) end
end)
TriggerBtn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then setTrigActive(false) end
end)
TriggerBtn.MouseLeave:Connect(function() setTrigActive(false) end)

--=========================================================
-- СВОРАЧИВАНИЕ
--=========================================================
local isMinimized = false
local defaultMenuHeight = 420
local function toggleMinimize()
    isMinimized = not isMinimized
    local targetSize = isMinimized and UDim2.new(0, 260, 0, 38) or UDim2.new(0, 260, 0, defaultMenuHeight)
    TweenService:Create(Menu, TweenInfo.new(0.25, Enum.EasingStyle.Quad), { Size = targetSize }):Play()
    Content.Visible = not isMinimized
end

MinimizeBtn.MouseButton1Click:Connect(toggleMinimize)
MinimizeBtn.Activated:Connect(toggleMinimize)

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
local ESPCache = {}

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
-- AIMBOT — БОЛЕЕ НАДЁЖНЫЙ МЕТОД
--=========================================================
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

local function GetClosestTarget()
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local closest, closestDist = nil, Config.Aimbot.FOV

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then
            local char = plr.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local part = char:FindFirstChild(Config.Aimbot.TargetPart)
                if part then
                    local sp, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local d3 = (Camera.CFrame.Position - part.Position).Magnitude
                        if d3 <= Config.Aimbot.MaxDistance then
                            local sd = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                            if sd < closestDist then
                                if not Config.Aimbot.Visible or IsVisible(part, char) then
                                    closestDist = sd
                                    closest = part
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return closest
end

--=========================================================
-- ГЛАВНЫЙ ЦИКЛ
--=========================================================
local aimActive = false

RunService.RenderStepped:Connect(function()
    -- FOV circle
    if Config.Aimbot.ShowFOV and Config.Aimbot.Enabled then
        FovCircle.Visible = true
        FovCircle.Size = UDim2.new(0, Config.Aimbot.FOV * 2, 0, Config.Aimbot.FOV * 2)
        FovCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
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
    end

    -- AIMBOT (улучшенный)
    if Config.Aimbot.Enabled then
        local shouldAim = Config.Aimbot.TriggerActive
            or UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)

        if shouldAim then
            local target = GetClosestTarget()
            if target then
                -- Меняем CFrame НАПРЯМУЮ (а не Lerp) — чтобы игра не сбрасывала
                local targetCF = CFrame.new(Camera.CFrame.Position, target.Position)
                -- Смешиваем с текущей через Smooth
                local currentCF = Camera.CFrame
                local s = Config.Aimbot.Smoothness
                Camera.CFrame = currentCF:Lerp(targetCF, s)
            end
        end
    end
end)

Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(RemoveESP)
for _, plr in ipairs(Players:GetPlayers()) do CreateESP(plr) end

--=========================================================
-- ГОРЯЧИЕ КЛАВИШИ (ПК)
--=========================================================
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.F1 then
        Config.ESP.Enabled = not Config.ESP.Enabled
        ESPButton.SetOn(Config.ESP.Enabled)
    elseif input.KeyCode == Enum.KeyCode.F2 then
        Config.Aimbot.Enabled = not Config.Aimbot.Enabled
        AimButton.SetOn(Config.Aimbot.Enabled)
    elseif input.KeyCode == Enum.KeyCode.RightShift then
        toggleMinimize()
    end
end)

print("[FerClient] v1.1 загружен | ESP + Aimbot + Слайдеры")
