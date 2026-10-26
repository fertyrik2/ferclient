--[[
    FerClient | Fust v4.1 FINAL
    Фикс: кнопки нажимаются, вкладки переключаются
]]

if getgenv().Fust_Loaded then
    if getgenv().Fust_Unload then pcall(getgenv().Fust_Unload) end
    task.wait(0.2)
end
getgenv().Fust_Loaded = true

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
local Camera = Workspace.CurrentCamera
local LP = Players.LocalPlayer

-- Тема
local Theme = {
    Background = Color3.fromRGB(15, 15, 25),
    Panel = Color3.fromRGB(20, 20, 35),
    Element = Color3.fromRGB(28, 28, 45),
    Accent = Color3.fromRGB(150, 120, 240),
    On = Color3.fromRGB(150, 120, 240),
    Off = Color3.fromRGB(50, 50, 70),
    Text = Color3.fromRGB(230, 230, 240),
    TextDim = Color3.fromRGB(120, 120, 140),
    Border = Color3.fromRGB(40, 40, 60),
    Font = Enum.Font.Gotham,
    FontBold = Enum.Font.GothamBold,
}

-- Конфиг
local Config = {
    ESP = { Enabled = true, Box = true, Name = true, Distance = true, Health = true, Tracer = true, MaxDistance = 1500 },
    Aimbot = { Enabled = false, AutoAim = false, FOV = 200, Smoothness = 0.5, MaxDistance = 600, TargetPart = "Head", Visible = false, TeamCheck = true, ShowFOV = true, TriggerActive = false },
    Silent = { Enabled = false, FOV = 200, MaxDistance = 600, TargetPart = "Head", TeamCheck = true, Debug = true },
    Gun = { LongRange = false, RangeMultiplier = 3, BowLongRange = false, BowMultiplier = 3 },
    Player = { SpeedEnabled = false, SpeedValue = 30, Noclip = false, NoFallDamage = false },
    Heli = { Enabled = false, Speed = 60 },
    Visual = { Fullbright = false, NoFog = false, FPSBoost = false },
    Misc = { InfiniteJump = false, AntiAFK = false },
}

local hasDrawing = pcall(function()
    local t = Drawing.new("Square"); t:Remove()
end)

local Connections = {}
local function TrackConn(c) Connections[#Connections + 1] = c; return c end

local function notify(title, text)
    pcall(function()
        StarterGui:SetCore("SendNotification", { Title = title or "FerClient", Text = text or "", Duration = 2 })
    end)
end

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FerClient_Fust"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 100
pcall(function() ScreenGui.Parent = HUI end)
if not ScreenGui.Parent then ScreenGui.Parent = LP:WaitForChild("PlayerGui") end

local Menu = Instance.new("Frame")
Menu.Name = "Main"
Menu.Size = UDim2.new(0, 450, 0, 280)
Menu.Position = UDim2.new(0.5, -225, 0.5, -140)
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
TopBar.Size = UDim2.new(1, 0, 0, 26)
TopBar.BackgroundColor3 = Theme.Background
TopBar.BorderSizePixel = 0
TopBar.ZIndex = 10
TopBar.Parent = Menu

local Logo = Instance.new("TextLabel")
Logo.Size = UDim2.new(1, -70, 1, 0)
Logo.Position = UDim2.new(0, 10, 0, 0)
Logo.BackgroundTransparency = 1
Logo.Text = "FerClient | Fust v4.1"
Logo.TextColor3 = Theme.Text
Logo.Font = Theme.FontBold
Logo.TextSize = 12
Logo.TextXAlignment = Enum.TextXAlignment.Left
Logo.ZIndex = 11
Logo.Parent = TopBar

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 18, 0, 18)
MinimizeBtn.Position = UDim2.new(1, -46, 0, 4)
MinimizeBtn.BackgroundTransparency = 1
MinimizeBtn.Text = "—"
MinimizeBtn.TextColor3 = Theme.TextDim
MinimizeBtn.Font = Theme.FontBold
MinimizeBtn.TextSize = 12
MinimizeBtn.ZIndex = 11
MinimizeBtn.Parent = TopBar

local UnloadBtn = Instance.new("TextButton")
UnloadBtn.Size = UDim2.new(0, 18, 0, 18)
UnloadBtn.Position = UDim2.new(1, -24, 0, 4)
UnloadBtn.BackgroundTransparency = 1
UnloadBtn.Text = "✕"
UnloadBtn.TextColor3 = Theme.TextDim
UnloadBtn.Font = Theme.FontBold
UnloadBtn.TextSize = 11
UnloadBtn.ZIndex = 11
UnloadBtn.Parent = TopBar

-- Контент
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -20, 1, -54)
Content.Position = UDim2.new(0, 10, 0, 30)
Content.BackgroundTransparency = 1
Content.ZIndex = 1
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
    sf.ZIndex = 1
    sf.Parent = Content
    local layout = Instance.new("UIListLayout", sf)
    layout.Padding = UDim.new(0, 4)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        sf.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    end)
    return sf
end

local CombatContent = MakeTabContent()
local VisualContent = MakeTabContent()
local MovementContent = MakeTabContent()
local MiscContent = MakeTabContent()
local SettingsContent = MakeTabContent()

-- Нижние вкладки
local BottomTabs = Instance.new("Frame")
BottomTabs.Size = UDim2.new(1, 0, 0, 22)
BottomTabs.Position = UDim2.new(0, 0, 1, -24)
BottomTabs.BackgroundColor3 = Theme.Background
BottomTabs.BorderSizePixel = 0
BottomTabs.ZIndex = 10
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
    btn.ZIndex = 11
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

-- Тумблер
local function MakeToggle(parent, text, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 22)
    frame.BackgroundTransparency = 1
    frame.ZIndex = 2
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -45, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Theme.Text
    label.Font = Theme.Font
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 3
    label.Parent = frame

    local track = Instance.new("Frame")
    track.Size = UDim2.new(0, 28, 0, 14)
    track.Position = UDim2.new(1, -30, 0.5, -7)
    track.BackgroundColor3 = Theme.Off
    track.BorderSizePixel = 0
    track.ZIndex = 3
    track.Parent = frame
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.AnchorPoint = Vector2.new(0, 0.5)
    knob.Size = UDim2.new(0, 10, 0, 10)
    knob.Position = UDim2.new(0, 2, 0.5, 0)
    knob.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
    knob.BorderSizePixel = 0
    knob.ZIndex = 4
    knob.Parent = track
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local isOn = default or false
    local function apply()
        if isOn then
            track.BackgroundColor3 = Theme.On
            TweenService:Create(knob, TweenInfo.new(0.15), { Position = UDim2.new(1, -12, 0.5, 0) }):Play()
        else
            track.BackgroundColor3 = Theme.Off
            TweenService:Create(knob, TweenInfo.new(0.15), { Position = UDim2.new(0, 2, 0.5, 0) }):Play()
        end
    end
    isOn = default or false
    apply()

    local click = Instance.new("TextButton")
    click.Size = UDim2.new(1, 0, 1, 0)
    click.BackgroundTransparency = 1
    click.Text = ""
    click.ZIndex = 5
    click.Parent = frame
    click.MouseButton1Click:Connect(function()
        pcall(callback)
        isOn = not isOn
        apply()
    end)
end

-- Слайдер
local function MakeSlider(parent, text, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 26)
    frame.BackgroundTransparency = 1
    frame.ZIndex = 2
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Theme.Text
    label.Font = Theme.Font
    label.TextSize = 10
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 3
    label.Parent = frame

    local valLabel = Instance.new("TextLabel")
    valLabel.Size = UDim2.new(0, 35, 1, 0)
    valLabel.Position = UDim2.new(1, -35, 0, 0)
    valLabel.BackgroundTransparency = 1
    valLabel.Text = tostring(default)
    valLabel.TextColor3 = Theme.Accent
    valLabel.Font = Theme.FontBold
    valLabel.TextSize = 10
    valLabel.TextXAlignment = Enum.TextXAlignment.Right
    valLabel.ZIndex = 3
    valLabel.Parent = frame

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -95, 0, 3)
    track.Position = UDim2.new(0, 55, 0.5, -1)
    track.BackgroundColor3 = Theme.Element
    track.BorderSizePixel = 0
    track.ZIndex = 3
    track.Parent = frame
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Theme.Accent
    fill.BorderSizePixel = 0
    fill.ZIndex = 4
    fill.Parent = track
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local dragging = false
    local function update(x)
        local relX = math.clamp(x - track.AbsolutePosition.X, 0, track.AbsoluteSize.X)
        local ratio = relX / math.max(track.AbsoluteSize.X, 1)
        local value = math.floor(min + (max - min) * ratio + 0.5)
        fill.Size = UDim2.new(ratio, 0, 1, 0)
        valLabel.Text = tostring(value)
        pcall(callback, value)
    end

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(input.Position.X)
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            update(input.Position.X)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

local function MakeSection(parent, text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 16)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Theme.TextDim
    lbl.Font = Theme.FontBold
    lbl.TextSize = 9
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 2
    lbl.Parent = parent
end

-- COMBAT
MakeSection(CombatContent, "AIMBOT")
MakeToggle(CombatContent, "Aimbot", false, function() Config.Aimbot.Enabled = not Config.Aimbot.Enabled end)
MakeToggle(CombatContent, "Auto Aim", false, function() Config.Aimbot.AutoAim = not Config.Aimbot.AutoAim end)
MakeToggle(CombatContent, "FOV Circle", true, function() Config.Aimbot.ShowFOV = not Config.Aimbot.ShowFOV end)
MakeToggle(CombatContent, "Team Check", true, function() Config.Aimbot.TeamCheck = not Config.Aimbot.TeamCheck; Config.Silent.TeamCheck = Config.Aimbot.TeamCheck end)
MakeSlider(CombatContent, "FOV Radius", 30, 600, Config.Aimbot.FOV, function(v) Config.Aimbot.FOV = v end)
MakeSlider(CombatContent, "Smoothness", 10, 100, 50, function(v) Config.Aimbot.Smoothness = v / 100 end)
MakeSlider(CombatContent, "Max Distance", 100, 2000, Config.Aimbot.MaxDistance, function(v) Config.Aimbot.MaxDistance = v end)

MakeSection(CombatContent, "SILENT AIM")
MakeToggle(CombatContent, "Silent Aim (Bow+Gun)", false, function() Config.Silent.Enabled = not Config.Silent.Enabled end)
MakeSlider(CombatContent, "Silent FOV", 30, 600, 200, function(v) Config.Silent.FOV = v end)
MakeSlider(CombatContent, "Silent Max Dist", 100, 2000, 600, function(v) Config.Silent.MaxDistance = v end)
MakeToggle(CombatContent, "Silent Debug", true, function() Config.Silent.Debug = not Config.Silent.Debug end)

MakeSection(CombatContent, "GUN MODS")
MakeToggle(CombatContent, "Gun Long Range", false, function() Config.Gun.LongRange = not Config.Gun.LongRange end)
MakeSlider(CombatContent, "Gun Range x", 1, 10, Config.Gun.RangeMultiplier, function(v) Config.Gun.RangeMultiplier = v end)
MakeToggle(CombatContent, "Bow Long Range", false, function() Config.Gun.BowLongRange = not Config.Gun.BowLongRange end)
MakeSlider(CombatContent, "Bow Range x", 1, 10, Config.Gun.BowMultiplier, function(v) Config.Gun.BowMultiplier = v end)

-- VISUAL
MakeSection(VisualContent, "PLAYER ESP")
MakeToggle(VisualContent, "ESP Enabled", true, function() Config.ESP.Enabled = not Config.ESP.Enabled end)
MakeToggle(VisualContent, "Boxes", true, function() Config.ESP.Box = not Config.ESP.Box end)
MakeToggle(VisualContent, "Names", true, function() Config.ESP.Name = not Config.ESP.Name end)
MakeToggle(VisualContent, "Distance", true, function() Config.ESP.Distance = not Config.ESP.Distance end)
MakeToggle(VisualContent, "Health Bar", true, function() Config.ESP.Health = not Config.ESP.Health end)
MakeToggle(VisualContent, "Tracers", true, function() Config.ESP.Tracer = not Config.ESP.Tracer end)
MakeSlider(VisualContent, "ESP Distance", 200, 3000, 1500, function(v) Config.ESP.MaxDistance = v end)

MakeSection(VisualContent, "VISUAL")
MakeToggle(VisualContent, "Fullbright", false, function() Config.Visual.Fullbright = not Config.Visual.Fullbright end)
MakeToggle(VisualContent, "No Fog", false, function() Config.Visual.NoFog = not Config.Visual.NoFog end)
MakeToggle(VisualContent, "FPS Boost", false, function() Config.Visual.FPSBoost = not Config.Visual.FPSBoost end)

-- MOVEMENT
MakeSection(MovementContent, "MOVEMENT")
MakeToggle(MovementContent, "Speed Hack", false, function() Config.Player.SpeedEnabled = not Config.Player.SpeedEnabled end)
MakeSlider(MovementContent, "Speed (10-50)", 10, 50, 30, function(v) Config.Player.SpeedValue = v end)
MakeToggle(MovementContent, "Noclip", false, function() Config.Player.Noclip = not Config.Player.Noclip end)
MakeToggle(MovementContent, "No Fall Damage", false, function() Config.Player.NoFallDamage = not Config.Player.NoFallDamage end)
MakeToggle(MovementContent, "Infinite Jump", false, function() Config.Misc.InfiniteJump = not Config.Misc.InfiniteJump end)

MakeSection(MovementContent, "HELICOPTER")
MakeToggle(MovementContent, "Heli Fly", false, function() Config.Heli.Enabled = not Config.Heli.Enabled end)
MakeSlider(MovementContent, "Heli Speed", 20, 200, 60, function(v) Config.Heli.Speed = v end)

-- MISC
MakeSection(MiscContent, "MISC")
MakeToggle(MiscContent, "Anti-AFK", false, function() Config.Misc.AntiAFK = not Config.Misc.AntiAFK end)

-- SETTINGS
MakeSection(SettingsContent, "INFO")
local infoLbl = Instance.new("TextLabel")
infoLbl.Size = UDim2.new(1, 0, 0, 100)
infoLbl.BackgroundTransparency = 1
infoLbl.Text = "FerClient | Fust v4.1\nКнопки работают ✅\n\nХоткеи:\nF1=ESP  F2=Aim  F3=InfJump\nRightShift=Меню  Delete=Unload"
infoLbl.TextColor3 = Theme.TextDim
infoLbl.Font = Theme.Font
infoLbl.TextSize = 10
infoLbl.TextWrapped = true
infoLbl.TextXAlignment = Enum.TextXAlignment.Left
infoLbl.TextYAlignment = Enum.TextYAlignment.Top
infoLbl.ZIndex = 2
infoLbl.Parent = SettingsContent

-- FC
local FCBtn = Instance.new("TextButton")
FCBtn.Size = UDim2.new(0, 50, 0, 28)
FCBtn.Position = UDim2.new(0, 10, 0.5, -14)
FCBtn.BackgroundColor3 = Theme.Background
FCBtn.BorderSizePixel = 0
FCBtn.Text = "FC"
FCBtn.TextColor3 = Theme.Accent
FCBtn.Font = Theme.FontBold
FCBtn.TextSize = 14
FCBtn.Active = true
FCBtn.Draggable = true
FCBtn.ZIndex = 100
FCBtn.Parent = ScreenGui
Instance.new("UIStroke", FCBtn).Color = Theme.Accent
Instance.new("UIStroke", FCBtn).Thickness = 1.5
FCBtn.MouseButton1Click:Connect(function() Menu.Visible = not Menu.Visible end)

local isMin = false
local function toggleMin()
    isMin = not isMin
    Menu.Size = isMin and UDim2.new(0, 450, 0, 26) or UDim2.new(0, 450, 0, 280)
    Content.Visible = not isMin
    BottomTabs.Visible = not isMin
end
MinimizeBtn.MouseButton1Click:Connect(toggleMin)

-- ESP
local ESPCache = {}
local function CreateESP(plr)
    if plr == LP or ESPCache[plr] or not hasDrawing then return end
    local box = Drawing.new("Square"); box.Visible = false; box.Color = Theme.Accent; box.Thickness = 1
    local boxO = Drawing.new("Square"); boxO.Visible = false; boxO.Color = Color3.new(0,0,0); boxO.Thickness = 3
    local nm = Drawing.new("Text"); nm.Visible = false; nm.Center = true; nm.Outline = true; nm.OutlineColor = Color3.new(0,0,0); nm.Color = Color3.new(1,1,1); nm.Size = 14; nm.Font = 2
    local dst = Drawing.new("Text"); dst.Visible = false; dst.Center = true; dst.Outline = true; dst.OutlineColor = Color3.new(0,0,0); dst.Color = Color3.new(1,1,1); dst.Size = 12; dst.Font = 2
    local hp = Drawing.new("Square"); hp.Visible = false; hp.Filled = true; hp.Color = Color3.fromRGB(0,255,0)
    local tr = Drawing.new("Line"); tr.Visible = false; tr.Thickness = 1; tr.Color = Theme.Accent
    ESPCache[plr] = { Box = box, BoxOutline = boxO, Name = nm, Dist = dst, HP = hp, Tracer = tr }
end
local function RemoveESP(plr)
    local d = ESPCache[plr]; if not d then return end
    for _, o in pairs(d) do pcall(function() o:Remove() end) end
    ESPCache[plr] = nil
end

-- Aimbot
local function IsTeammate(plr)
    if not plr.Team or not LP.Team then return false end
    return plr.Team == LP.Team
end

local function GetClosestTarget(fovRange, maxRange, teamCheck)
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local closest, closestDist, closestPart = nil, fovRange, nil
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and not (teamCheck and IsTeammate(plr)) then
            local char = plr.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local part = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
                if part then
                    local sp, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local d3 = (Camera.CFrame.Position - part.Position).Magnitude
                        if d3 <= maxRange then
                            local sd = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                            if sd < closestDist then
                                closestDist = sd
                                closest = plr
                                closestPart = part
                            end
                        end
                    end
                end
            end
        end
    end
    return closest, closestPart
end

local silentPart = nil
TrackConn(RunService.RenderStepped:Connect(function()
    if Config.Silent.Enabled then
        local _, part = GetClosestTarget(Config.Silent.FOV, Config.Silent.MaxDistance, Config.Silent.TeamCheck)
        silentPart = part
    else
        silentPart = nil
    end
end))

-- SILENT AIM + LONG RANGE HOOK
pcall(function()
    if not (hookmetamethod and newcclosure) then return end
    local oldNC
    oldNC = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if method == "FireServer" and typeof(self) == "Instance" then
            local args = {...}
            
            if self.Name == "Shoot" and Config.Silent.Enabled and silentPart then
                if type(args[1]) == "table" and args[1].dir and args[1].origin then
                    local data = args[1]
                    data.dir = (silentPart.Position - data.origin).Unit
                    if Config.Silent.Debug then
                        notify("SilentAim Bow ✅", silentPart.Parent.Name)
                    end
                end
            end
            
            if self.Name == "Fire" and Config.Silent.Enabled and silentPart then
                if type(args[1]) == "table" and args[1].dir then
                    local data = args[1]
                    local origin = data.origin or Camera.CFrame.Position
                    data.dir = (silentPart.Position - origin).Unit
                    if Config.Silent.Debug then
                        notify("SilentAim Gun ✅", silentPart.Parent.Name)
                    end
                end
            end
            
            if self.Name == "Shoot" and Config.Gun.BowLongRange and type(args[1]) == "table" then
                local data = args[1]
                for k, v in pairs(data) do
                    if typeof(v) == "number" and v > 10 and v < 5000 then
                        data[k] = v * Config.Gun.BowMultiplier
                    end
                end
            end
            
            if self.Name == "Fire" and Config.Gun.LongRange and type(args[1]) == "table" then
                local data = args[1]
                for k, v in pairs(data) do
                    if typeof(v) == "number" and v > 50 and v < 10000 then
                        data[k] = v * Config.Gun.RangeMultiplier
                    end
                end
            end
            
            return oldNC(self, table.unpack(args))
        end
        return oldNC(self, ...)
    end))
end)

-- SPEED
local savedSpeed = 16; local smoothedSpeed = 16
TrackConn(RunService.Heartbeat:Connect(function(dt)
    local char = LP.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if Config.Player.SpeedEnabled then
        local targetSpeed = math.clamp(Config.Player.SpeedValue, 16, 50)
        smoothedSpeed = smoothedSpeed + (targetSpeed - smoothedSpeed) * math.clamp(dt * 8, 0, 1)
        hum.WalkSpeed = smoothedSpeed
    else
        if math.abs(smoothedSpeed - savedSpeed) > 0.1 then
            smoothedSpeed = smoothedSpeed + (savedSpeed - smoothedSpeed) * math.clamp(dt * 8, 0, 1)
            hum.WalkSpeed = smoothedSpeed
        else smoothedSpeed = savedSpeed; hum.WalkSpeed = savedSpeed end
    end
end))

TrackConn(LP.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid", 5)
    if hum then savedSpeed = hum.WalkSpeed; smoothedSpeed = hum.WalkSpeed end
end))

-- HELI
TrackConn(RunService.Heartbeat:Connect(function()
    if not Config.Heli.Enabled then return end
    local char = LP.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or not hum.SeatPart then return end
    local vehicle = hum.SeatPart.Parent
    if not vehicle then return end
    local base = vehicle:FindFirstChild("Base") or vehicle:FindFirstChild("Chassis") or vehicle.PrimaryPart
    if not base then return end
    local moveVec = Vector3.zero
    if UIS:IsKeyDown(Enum.KeyCode.W) then moveVec += Camera.CFrame.LookVector end
    if UIS:IsKeyDown(Enum.KeyCode.S) then moveVec -= Camera.CFrame.LookVector end
    if UIS:IsKeyDown(Enum.KeyCode.A) then moveVec -= Camera.CFrame.RightVector end
    if UIS:IsKeyDown(Enum.KeyCode.D) then moveVec += Camera.CFrame.RightVector end
    if UIS:IsKeyDown(Enum.KeyCode.Space) then moveVec += Vector3.new(0, 1, 0) end
    if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then moveVec -= Vector3.new(0, 1, 0) end
    if moveVec.Magnitude > 0 then
        base.CFrame = base.CFrame + moveVec.Unit * Config.Heli.Speed * 0.016
    end
end))

-- FOV круг
local FovCircle = Instance.new("Frame")
FovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FovCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
FovCircle.Size = UDim2.new(0, 400, 0, 400)
FovCircle.BackgroundTransparency = 1
FovCircle.Visible = false
FovCircle.Parent = ScreenGui
Instance.new("UICorner", FovCircle).CornerRadius = UDim.new(1, 0)
local FovStroke = Instance.new("UIStroke", FovCircle)
FovStroke.Color = Theme.Accent; FovStroke.Thickness = 2

-- ГЛАВНЫЙ ЦИКЛ
TrackConn(RunService.RenderStepped:Connect(function()
    if Config.Aimbot.Enabled or Config.Silent.Enabled then
        FovCircle.Visible = true
        local size = Config.Aimbot.Enabled and Config.Aimbot.FOV or Config.Silent.FOV
        FovCircle.Size = UDim2.new(0, size * 2, 0, size * 2)
        if Config.Silent.Enabled and silentPart then
            FovStroke.Color = Color3.fromRGB(0, 255, 100)
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
                else
                    local dist = (Camera.CFrame.Position - root.Position).Magnitude
                    if dist > Config.ESP.MaxDistance then
                        for _, o in pairs(d) do o.Visible = false end
                    else
                        local sTop, onT = Camera:WorldToViewportPoint(root.Position + Vector3.new(0, 3, 0))
                        local sBot, onB = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
                        if onT and onB then
                            local h = math.abs(sBot.Y - sTop.Y); local w = h * 0.55
                            local x, y = sTop.X - w/2, sTop.Y
                            d.Box.Visible = Config.ESP.Box; d.Box.Size = Vector2.new(w, h); d.Box.Position = Vector2.new(x, y)
                            d.BoxOutline.Visible = Config.ESP.Box; d.BoxOutline.Size = Vector2.new(w, h); d.BoxOutline.Position = Vector2.new(x, y)
                            d.Name.Visible = Config.ESP.Name; d.Name.Text = plr.Name; d.Name.Position = Vector2.new(sTop.X, y - 16)
                            d.Dist.Visible = Config.ESP.Distance; d.Dist.Text = math.floor(dist) .. "m"; d.Dist.Position = Vector2.new(sTop.X, y + h + 2)
                            if Config.ESP.Health then
                                local pct = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
                                d.HP.Visible = true; d.HP.Size = Vector2.new(3, h * pct); d.HP.Position = Vector2.new(x - 5, y + h - h * pct)
                                d.HP.Color = pct > 0.6 and Color3.fromRGB(0,255,0) or pct > 0.3 and Color3.fromRGB(255,200,0) or Color3.fromRGB(255,0,0)
                            else d.HP.Visible = false end
                            d.Tracer.Visible = Config.ESP.Tracer
                            if Config.ESP.Tracer then
                                d.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                                d.Tracer.To = Vector2.new(sBot.X, sBot.Y)
                            end
                        else for _, o in pairs(d) do o.Visible = false end end
                    end
                end
            end
        end
    end

    if Config.Aimbot.Enabled and (Config.Aimbot.TriggerActive or UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)) then
        local _, part = GetClosestTarget(Config.Aimbot.FOV, Config.Aimbot.MaxDistance, Config.Aimbot.TeamCheck)
        if part then
            local targetCF = CFrame.new(Camera.CFrame.Position, part.Position)
            Camera.CFrame = Camera.CFrame:Lerp(targetCF, Config.Aimbot.Smoothness)
        end
    end

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

    if Config.Visual.Fullbright then
        pcall(function()
            Lighting.Brightness = 5; Lighting.ClockTime = 14
            Lighting.FogEnd = 100000; Lighting.GlobalShadows = false
        end)
    end
    if Config.Visual.NoFog then
        pcall(function()
            Lighting.FogEnd = 9e9; Lighting.FogStart = 0
            local atm = Lighting:FindFirstChildOfClass("Atmosphere")
            if atm then atm.Density = 0; atm.Haze = 0 end
        end)
    end
end))

TrackConn(Players.PlayerAdded:Connect(CreateESP))
TrackConn(Players.PlayerRemoving:Connect(RemoveESP))
for _, plr in ipairs(Players:GetPlayers()) do CreateESP(plr) end

TrackConn(UIS.JumpRequest:Connect(function()
    if not Config.Misc.InfiniteJump then return end
    local char = LP.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end))

TrackConn(LP.Idled:Connect(function()
    if not Config.Misc.AntiAFK then return end
    pcall(function()
        local VU = game:GetService("VirtualUser")
        VU:CaptureController(); VU:ClickButton2(Vector2.new())
    end)
end))

local function Unload()
    for _, d in pairs(ESPCache) do
        for _, o in pairs(d) do pcall(function() o:Remove() end) end
    end
    for _, c in ipairs(Connections) do pcall(function() c:Disconnect() end) end
    pcall(function() ScreenGui:Destroy() end)
    getgenv().Fust_Loaded = false
    notify("FerClient", "Выгружен")
end
UnloadBtn.MouseButton1Click:Connect(Unload)
getgenv().Fust_Unload = Unload

TrackConn(UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.F1 then Config.ESP.Enabled = not Config.ESP.Enabled
    elseif input.KeyCode == Enum.KeyCode.F2 then Config.Aimbot.Enabled = not Config.Aimbot.Enabled
    elseif input.KeyCode == Enum.KeyCode.F3 then Config.Misc.InfiniteJump = not Config.Misc.InfiniteJump
    elseif input.KeyCode == Enum.KeyCode.RightShift then Menu.Visible = not Menu.Visible
    elseif input.KeyCode == Enum.KeyCode.Delete then Unload() end
end))

notify("FerClient | Fust v4.1", "Кнопки работают ✅")
print("[FerClient] Fust v4.1 — фикс кнопок")
