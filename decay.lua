--[[
    FerClient | Decay Edition v1.0
    Universal cheat for Decay [HALF WALLS]
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
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local Camera = Workspace.CurrentCamera
local LP = Players.LocalPlayer

--=========================================================
-- ТЕМА
--=========================================================
local Theme = {
    Background = Color3.fromRGB(10, 10, 10),
    Panel      = Color3.fromRGB(15, 15, 15),
    Element    = Color3.fromRGB(22, 22, 22),
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
        Box = true, Name = true, Distance = true, Health = true,
        MaxDistance = 1500,
    },
    Aimbot = {
        Enabled = false, AutoAim = false, FOV = 200, Smoothness = 0.5,
        MaxDistance = 600, TargetPart = "Head",
        Visible = false, TeamCheck = true, ShowFOV = true,
        TriggerActive = false, Prediction = true, PredictionX = 0.15,
    },
    Player = {
        NoFallDamage = false,
        SpeedEnabled = false, SpeedValue = 30,
        Noclip = false,
    },
    Visual = {
        Fullbright = false,
        XRay = false,
        FPSBoost = false,
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
-- GUI
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
Menu.Size = UDim2.new(0, 300, 0, 420)
Menu.Position = UDim2.new(0, 20, 0, 60)
Menu.BackgroundColor3 = Theme.Background
Menu.BorderSizePixel = 0
Menu.Active = true
Menu.Draggable = true
Menu.Visible = false
Menu.Parent = ScreenGui
Instance.new("UIStroke", Menu).Color = Theme.Border
Instance.new("UIStroke", Menu).Thickness = 1

-- Топбар
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 38)
TopBar.BackgroundColor3 = Theme.Panel
TopBar.BorderSizePixel = 0
TopBar.Parent = Menu

local Dot = Instance.new("Frame")
Dot.Size = UDim2.new(0, 8, 0, 8)
Dot.Position = UDim2.new(0, 12, 0.5, -4)
Dot.BackgroundColor3 = Theme.Success
Dot.BorderSizePixel = 0
Dot.Parent = TopBar
Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)

local Logo = Instance.new("TextLabel")
Logo.Size = UDim2.new(0, 200, 1, 0)
Logo.Position = UDim2.new(0, 28, 0, 0)
Logo.BackgroundTransparency = 1
Logo.Text = "FerClient | Decay"
Logo.TextColor3 = Theme.Text
Logo.Font = Theme.FontBold
Logo.TextSize = 13
Logo.TextXAlignment = Enum.TextXAlignment.Left
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
UnloadBtn.Parent = TopBar

-- Вкладки
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -16, 0, 34)
TabBar.Position = UDim2.new(0, 8, 0, 46)
TabBar.BackgroundColor3 = Theme.Element
TabBar.BorderSizePixel = 0
TabBar.Parent = Menu

local TabLayout = Instance.new("UIListLayout", TabBar)
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabLayout.Padding = UDim.new(0, 4)
TabLayout.Parent = TabBar

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -16, 1, -140)
Content.Position = UDim2.new(0, 8, 0, 88)
Content.BackgroundTransparency = 1
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

local function CreateTab(name, scroller, ratio)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(ratio, -3, 1, 0)
    btn.BackgroundColor3 = Theme.Background
    btn.BorderSizePixel = 0
    btn.Text = name
    btn.TextColor3 = Theme.TextDim
    btn.Font = Theme.FontBold
    btn.TextSize = 10
    btn.AutoButtonColor = false
    btn.Parent = TabBar

    local tab = { Btn = btn, Scroller = scroller }
    btn.MouseButton1Click:Connect(function()
        if activeTab == tab then return end
        activeTab = tab
        for _, t in ipairs(tabs) do
            local isActive = (t == tab)
            t.Btn.BackgroundColor3 = isActive and Theme.Accent or Theme.Background
            t.Btn.TextColor3 = isActive and Color3.new(1,1,1) or Theme.TextDim
            t.Scroller.Visible = isActive
        end
    end)
    tabs[#tabs + 1] = tab
    return tab
end

local AimTab = CreateTab("AIM", AimScroller, 0.25)
local VisualTab = CreateTab("VIS", VisualScroller, 0.25)
local PlayerTab = CreateTab("PLR", PlayerScroller, 0.25)
local MiscTab = CreateTab("MISC", MiscScroller, 0.25)

-- Функция кнопки
local function MakeButton(parent, text, defaultOn, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 38)
    btn.BackgroundColor3 = Color3.fromRGB(90, 15, 15)
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = Color3.fromRGB(255, 60, 60)
    stroke.Thickness = 1.5

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -70, 1, 0)
    nameLabel.Position = UDim2.new(0, 14, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = text
    nameLabel.TextColor3 = Theme.Text
    nameLabel.Font = Theme.Font
    nameLabel.TextSize = 12
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = btn

    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(0, 50, 1, 0)
    statusLabel.Position = UDim2.new(1, -54, 0, 0)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "OFF"
    statusLabel.TextColor3 = Theme.Danger
    statusLabel.Font = Theme.FontBold
    statusLabel.TextSize = 11
    statusLabel.Parent = btn

    local isOn = false
    local function applyState()
        if isOn then
            btn.BackgroundColor3 = Color3.fromRGB(0, 80, 40)
            stroke.Color = Theme.Success
            stroke.Thickness = 2
            statusLabel.Text = "ON"
            statusLabel.TextColor3 = Theme.Success
        else
            btn.BackgroundColor3 = Color3.fromRGB(90, 15, 15)
            stroke.Color = Theme.Danger
            stroke.Thickness = 1.5
            statusLabel.Text = "OFF"
            statusLabel.TextColor3 = Theme.Danger
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

    return { Button = btn, SetOn = function(v) isOn = v; applyState() end }
end

-- Функция слайдера
local function MakeSlider(parent, text, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 50)
    frame.BackgroundColor3 = Theme.Element
    frame.BorderSizePixel = 0
    frame.Parent = parent
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

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

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -24, 0, 8)
    track.Position = UDim2.new(0, 12, 1, -18)
    track.BackgroundColor3 = Theme.Background
    track.BorderSizePixel = 0
    track.Parent = frame
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
    fill.BackgroundColor3 = Theme.Accent
    fill.BorderSizePixel = 0
    fill.Parent = track
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local dragging = false
    local function update(x)
        local relX = math.clamp(x - track.AbsolutePosition.X, 0, track.AbsoluteSize.X)
        local ratio = relX / math.max(track.AbsoluteSize.X, 1)
        local val = math.floor(min + (max-min) * ratio + 0.5)
        fill.Size = UDim2.new(ratio, 0, 1, 0)
        valueLabel.Text = tostring(val)
        pcall(callback, val)
    end

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(input.Position.X)
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            update(input.Position.X)
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
-- AIM ВКЛАДКА
--=========================================================
local AimBtn = MakeButton(AimScroller, "Aimbot", false, function()
    Config.Aimbot.Enabled = not Config.Aimbot.Enabled
end)

local AutoAimBtn = MakeButton(AimScroller, "Auto Aim", false, function()
    Config.Aimbot.AutoAim = not Config.Aimbot.AutoAim
end)

local FovBtn = MakeButton(AimScroller, "FOV Circle", true, function()
    Config.Aimbot.ShowFOV = not Config.Aimbot.ShowFOV
end)

local PredictBtn = MakeButton(AimScroller, "Prediction", true, function()
    Config.Aimbot.Prediction = not Config.Aimbot.Prediction
end)

local VisibleBtn = MakeButton(AimScroller, "Visible Check", false, function()
    Config.Aimbot.Visible = not Config.Aimbot.Visible
end)

local TeamBtn = MakeButton(AimScroller, "Team Check", true, function()
    Config.Aimbot.TeamCheck = not Config.Aimbot.TeamCheck
end)

MakeSlider(AimScroller, "FOV Radius", 30, 600, Config.Aimbot.FOV, function(v)
    Config.Aimbot.FOV = v
    FovCircle.Size = UDim2.new(0, v * 2, 0, v * 2)
end)

MakeSlider(AimScroller, "Smoothness x100", 10, 100, 50, function(v)
    Config.Aimbot.Smoothness = v / 100
end)

MakeSlider(AimScroller, "Max Distance", 100, 2000, Config.Aimbot.MaxDistance, function(v)
    Config.Aimbot.MaxDistance = v
end)

--=========================================================
-- VIS ВКЛАДКА
--=========================================================
local ESPBtn = MakeButton(VisualScroller, "ESP", true, function()
    Config.ESP.Enabled = not Config.ESP.Enabled
end)

local BoxBtn = MakeButton(VisualScroller, "Boxes", true, function()
    Config.ESP.Box = not Config.ESP.Box
end)

local NameBtn = MakeButton(VisualScroller, "Names", true, function()
    Config.ESP.Name = not Config.ESP.Name
end)

local DistBtn = MakeButton(VisualScroller, "Distance", true, function()
    Config.ESP.Distance = not Config.ESP.Distance
end)

local HealthBtn = MakeButton(VisualScroller, "Health Bar", true, function()
    Config.ESP.Health = not Config.ESP.Health
end)

local FullbrightBtn = MakeButton(VisualScroller, "Fullbright", false, function()
    Config.Visual.Fullbright = not Config.Visual.Fullbright
end)

local XRayBtn = MakeButton(VisualScroller, "X-Ray", false, function()
    Config.Visual.XRay = not Config.Visual.XRay
end)

local FPSBoostBtn = MakeButton(VisualScroller, "FPS Boost", false, function()
    Config.Visual.FPSBoost = not Config.Visual.FPSBoost
end)

MakeSlider(VisualScroller, "ESP Max Distance", 200, 3000, Config.ESP.MaxDistance, function(v)
    Config.ESP.MaxDistance = v
end)

--=========================================================
-- PLR ВКЛАДКА
--=========================================================
local SpeedBtn = MakeButton(PlayerScroller, "Speed Hack", false, function()
    Config.Player.SpeedEnabled = not Config.Player.SpeedEnabled
end)

MakeSlider(PlayerScroller, "Speed (10-100)", 10, 100, 30, function(v)
    Config.Player.SpeedValue = v
end)

local NoclipBtn = MakeButton(PlayerScroller, "Noclip", false, function()
    Config.Player.Noclip = not Config.Player.Noclip
end)

local NoFallBtn = MakeButton(PlayerScroller, "No Fall Damage", false, function()
    Config.Player.NoFallDamage = not Config.Player.NoFallDamage
end)

--=========================================================
-- MISC ВКЛАДКА
--=========================================================
local InfJumpBtn = MakeButton(MiscScroller, "Infinite Jump", false, function()
    Config.Misc.InfiniteJump = not Config.Misc.InfiniteJump
end)

local infoLbl = Instance.new("TextLabel")
infoLbl.Size = UDim2.new(1, 0, 0, 60)
infoLbl.BackgroundTransparency = 1
infoLbl.Text = "FerClient | Decay Edition\n\nХоткеи:\nF1=ESP | F2=Aimbot | F3=AutoAim"
infoLbl.TextColor3 = Theme.TextDim
infoLbl.Font = Theme.Font
infoLbl.TextSize = 10
infoLbl.TextWrapped = true
infoLbl.TextXAlignment = Enum.TextXAlignment.Left
infoLbl.Parent = MiscScroller

-- HOLD TO AIM
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
TriggerBtn.Parent = Menu
Instance.new("UICorner", TriggerBtn).CornerRadius = UDim.new(0, 6)

local function setTrig(a)
    Config.Aimbot.TriggerActive = a
    TriggerBtn.BackgroundColor3 = a and Color3.fromRGB(120, 180, 255) or Theme.Accent
end
TriggerBtn.MouseButton1Down:Connect(function() setTrig(true) end)
TriggerBtn.MouseButton1Up:Connect(function() setTrig(false) end)
TriggerBtn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch then setTrig(true) end end)
TriggerBtn.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch then setTrig(false) end end)
TriggerBtn.MouseLeave:Connect(function() setTrig(false) end)

-- Сворачивание
local isMin = false
local function toggleMin()
    isMin = not isMin
    Menu.Size = isMin and UDim2.new(0, 300, 0, 38) or UDim2.new(0, 300, 0, 420)
    TabBar.Visible = not isMin
    Content.Visible = not isMin
    TriggerBtn.Visible = not isMin
end
MinimizeBtn.MouseButton1Click:Connect(toggleMin)

-- FC кнопка
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
FCBtn.Draggable = true
FCBtn.Parent = ScreenGui
Instance.new("UIStroke", FCBtn).Color = Theme.Accent
Instance.new("UIStroke", FCBtn).Thickness = 1.5

local lastToggle = 0
FCBtn.MouseButton1Click:Connect(function()
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
    pcall(function() RunService:UnbindFromRenderStep("Decay_Aimbot") end)
    for _, d in pairs(ESPCache) do
        for _, o in pairs(d) do pcall(function() o:Remove() end) end
    end
    for _, c in ipairs(Connections) do pcall(function() c:Disconnect() end) end
    pcall(function() ScreenGui:Destroy() end)
    getgenv().FerClient_Decay_Loaded = false
    print("[FerClient] Decay — Выгружен.")
end

UnloadBtn.MouseButton1Click:Connect(Unload)
getgenv().FerClient_Decay_Unload = Unload

--=========================================================
-- FOV КРУГ
--=========================================================
local FovCircle = Instance.new("Frame")
FovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FovCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
FovCircle.Size = UDim2.new(0, 400, 0, 400)
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
local function CreateESP(plr)
    if plr == LP or ESPCache[plr] then return end
    if not hasDrawing then return end

    local box = Drawing.new("Square")
    box.Visible = false; box.Color = Theme.Accent
    box.Thickness = 1; box.Filled = false

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

    ESPCache[plr] = { Box = box, Name = nm, Dist = dst, HP = hp }
end

local function RemoveESP(plr)
    local d = ESPCache[plr]
    if not d then return end
    for _, o in pairs(d) do pcall(function() o:Remove() end) end
    ESPCache[plr] = nil
end

--=========================================================
-- AIMBOT ЛОГИКА
--=========================================================
local function IsTeammate(plr)
    if not Config.Aimbot.TeamCheck then return false end
    if not plr.Team or not LP.Team then return false end
    return plr.Team == LP.Team
end

local function IsVisible(part, char)
    local origin = Camera.CFrame.Position
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { LP.Character, Camera, char }
    params.IgnoreWater = true
    local result = Workspace:Raycast(origin, part.Position - origin, params)
    if not result then return true end
    return result.Instance and result.Instance:IsDescendantOf(char)
end

local function GetTarget()
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local closest, closestDist, closestPos = nil, Config.Aimbot.FOV, nil

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and not IsTeammate(plr) then
            local char = plr.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local part = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
                if part then
                    local pos = part.Position
                    if Config.Aimbot.Prediction then
                        local vel = part.AssemblyLinearVelocity
                        if vel then pos = pos + vel * Config.Aimbot.PredictionX end
                    end
                    local sp, onScreen = Camera:WorldToViewportPoint(pos)
                    if onScreen then
                        local d3 = (Camera.CFrame.Position - pos).Magnitude
                        if d3 <= Config.Aimbot.MaxDistance then
                            local sd = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                            if sd < closestDist then
                                if not Config.Aimbot.Visible or IsVisible(part, char) then
                                    closestDist = sd
                                    closest = part
                                    closestPos = pos
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
        local target, predPos = GetTarget()
        if target and predPos then
            local targetCF = CFrame.new(Camera.CFrame.Position, predPos)
            Camera.CFrame = Camera.CFrame:Lerp(targetCF, Config.Aimbot.Smoothness)
        end
    end
end

RunService:BindToRenderStep("Decay_Aimbot", AIM_PRIORITY, AimStep)

--=========================================================
-- ОСНОВНОЙ ЦИКЛ
--=========================================================
TrackConn(RunService.RenderStepped:Connect(function()
    -- FOV круг
    if Config.Aimbot.ShowFOV and Config.Aimbot.Enabled then
        FovCircle.Visible = true
        FovCircle.Size = UDim2.new(0, Config.Aimbot.FOV * 2, 0, Config.Aimbot.FOV * 2)
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

                local h = math.abs(sBot.Y - sTop.Y)
                local w = h * 0.55
                local x, y = sTop.X - w/2, sTop.Y

                d.Box.Visible = Config.ESP.Box
                d.Box.Size = Vector2.new(w, h)
                d.Box.Position = Vector2.new(x, y)

                d.Name.Visible = Config.ESP.Name
                d.Name.Text = plr.Name
                d.Name.Position = Vector2.new(sTop.X, y - 16)

                d.Dist.Visible = Config.ESP.Distance
                d.Dist.Text = math.floor(d3) .. "m"
                d.Dist.Position = Vector2.new(sTop.X, y + h + 2)

                if Config.ESP.Health then
                    local pct = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
                    d.HP.Visible = true
                    d.HP.Size = Vector2.new(3, h * pct)
                    d.HP.Position = Vector2.new(x - 5, y + h - h * pct)
                    d.HP.Color = pct > 0.6 and Color3.fromRGB(0,255,0)
                        or pct > 0.3 and Color3.fromRGB(255,200,0)
                        or Color3.fromRGB(255,0,0)
                else
                    d.HP.Visible = false
                end
            end
        end
    end
end))

TrackConn(Players.PlayerAdded:Connect(CreateESP))
TrackConn(Players.PlayerRemoving:Connect(RemoveESP))
for _, plr in ipairs(Players:GetPlayers()) do CreateESP(plr) end

--=========================================================
-- SPEED / NOCLIP / NO FALL / INF JUMP
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

-- No Fall damage velocity check
TrackConn(RunService.Heartbeat:Connect(function()
    if not Config.Player.NoFallDamage then return end
    local char = LP.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if root and root.AssemblyLinearVelocity.Y < -55 then
        root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, -2, root.AssemblyLinearVelocity.Z)
    end
end))

-- Fullbright
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

-- X-Ray
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

-- FPS Boost
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
        end)
    elseif not Config.Visual.FPSBoost and fpsApplied then
        fpsApplied = false
    end
end))

-- Infinite Jump
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
        ESPBtn.SetOn(Config.ESP.Enabled)
    elseif input.KeyCode == Enum.KeyCode.F2 then
        Config.Aimbot.Enabled = not Config.Aimbot.Enabled
        AimBtn.SetOn(Config.Aimbot.Enabled)
    elseif input.KeyCode == Enum.KeyCode.F3 then
        Config.Aimbot.AutoAim = not Config.Aimbot.AutoAim
        AutoAimBtn.SetOn(Config.Aimbot.AutoAim)
    elseif input.KeyCode == Enum.KeyCode.F4 then
        Config.Misc.InfiniteJump = not Config.Misc.InfiniteJump
        InfJumpBtn.SetOn(Config.Misc.InfiniteJump)
    elseif input.KeyCode == Enum.KeyCode.RightShift then
        Menu.Visible = not Menu.Visible
    elseif input.KeyCode == Enum.KeyCode.Delete then
        Unload()
    end
end))

AimTab.Btn.BackgroundColor3 = Theme.Accent
AimTab.Btn.TextColor3 = Color3.new(1,1,1)
AimScroller.Visible = true
activeTab = AimTab

chatMessage("[FerClient] Decay Edition загружен", Theme.Accent)
print("[FerClient] Decay — загружен")
