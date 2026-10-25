--[[
    FerClient | Fust v2.0
    Silent Aim (через таблицу Fire) + ESP + Aimbot + Speed + Noclip + Heli Fly
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

--=========================================================
-- ТЕМА
--=========================================================
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

--=========================================================
-- КОНФИГ
--=========================================================
local Config = {
    ESP = {
        Enabled = true,
        Box = true, Name = true, Distance = true, Health = true, Tracer = true,
        MaxDistance = 1500,
    },
    Aimbot = {
        Enabled = false, FOV = 200, Smoothness = 0.5, MaxDistance = 600,
        TriggerActive = false,
    },
    Silent = {
        Enabled = false,
        FOV = 200,
        MaxDistance = 600,
        TargetPart = "Head",
        TeamCheck = true,
        Debug = true,
    },
    Player = {
        SpeedEnabled = false, SpeedValue = 30,
        Noclip = false, NoFallDamage = false,
    },
    Heli = {
        Enabled = false, Speed = 60,
    },
    Visual = {
        Fullbright = false, NoFog = false, FPSBoost = false,
    },
    Misc = {
        InfiniteJump = false, AntiAFK = false,
    }
}

local hasDrawing = pcall(function()
    local t = Drawing.new("Square"); t:Remove()
end)

local Connections = {}
local function TrackConn(c)
    Connections[#Connections + 1] = c
    return c
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
-- ГЛАВНЫЙ GUI
--=========================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FerClient_Fust"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 100
pcall(function() ScreenGui.Parent = HUI end)
if not ScreenGui.Parent then ScreenGui.Parent = LP:WaitForChild("PlayerGui") end

local Menu = Instance.new("Frame")
Menu.Name = "Main"
Menu.Size = UDim2.new(0, 280, 0, 420)
Menu.Position = UDim2.new(0.5, -140, 0.5, -210)
Menu.BackgroundColor3 = Theme.Background
Menu.BorderSizePixel = 0
Menu.Active = true
Menu.Draggable = true
Menu.Visible = false
Menu.Parent = ScreenGui
Instance.new("UIStroke", Menu).Color = Theme.Border
Instance.new("UIStroke", Menu).Thickness = 1
Instance.new("UICorner", Menu).CornerRadius = UDim.new(0, 10)

-- Topbar
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 30)
TopBar.BackgroundColor3 = Theme.Background
TopBar.BorderSizePixel = 0
TopBar.Parent = Menu

local Logo = Instance.new("TextLabel")
Logo.Size = UDim2.new(1, -40, 1, 0)
Logo.Position = UDim2.new(0, 10, 0, 0)
Logo.BackgroundTransparency = 1
Logo.Text = "FerClient | Fust v2.0"
Logo.TextColor3 = Theme.Text
Logo.Font = Theme.FontBold
Logo.TextSize = 12
Logo.TextXAlignment = Enum.TextXAlignment.Left
Logo.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 20, 0, 20)
CloseBtn.Position = UDim2.new(1, -25, 0, 5)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Theme.TextDim
CloseBtn.Font = Theme.FontBold
CloseBtn.TextSize = 12
CloseBtn.Parent = TopBar

local Content = Instance.new("ScrollingFrame")
Content.Size = UDim2.new(1, -16, 1, -38)
Content.Position = UDim2.new(0, 8, 0, 34)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 2
Content.ScrollBarImageColor3 = Theme.Accent
Content.CanvasSize = UDim2.new(0, 0, 0, 0)
Content.Parent = Menu

local Layout = Instance.new("UIListLayout", Content)
Layout.Padding = UDim.new(0, 5)
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Content.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 10)
end)

--=========================================================
-- UI ЭЛЕМЕНТЫ
--=========================================================
local function MakeToggle(text, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 26)
    frame.BackgroundColor3 = Theme.Element
    frame.BorderSizePixel = 0
    frame.Parent = Content
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 4)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -40, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Theme.Text
    label.Font = Theme.Font
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local track = Instance.new("Frame")
    track.Size = UDim2.new(0, 28, 0, 14)
    track.Position = UDim2.new(1, -36, 0.5, -7)
    track.BackgroundColor3 = Theme.Off
    track.BorderSizePixel = 0
    track.Parent = frame
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.AnchorPoint = Vector2.new(0, 0.5)
    knob.Size = UDim2.new(0, 10, 0, 10)
    knob.Position = UDim2.new(0, 2, 0.5, 0)
    knob.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
    knob.BorderSizePixel = 0
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
    click.Parent = frame
    click.MouseButton1Click:Connect(function()
        pcall(callback)
        isOn = not isOn
        apply()
    end)
end

local function MakeSlider(text, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 30)
    frame.BackgroundColor3 = Theme.Element
    frame.BorderSizePixel = 0
    frame.Parent = Content
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 4)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Theme.Text
    label.Font = Theme.Font
    label.TextSize = 10
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local valLabel = Instance.new("TextLabel")
    valLabel.Size = UDim2.new(0, 40, 1, 0)
    valLabel.Position = UDim2.new(1, -50, 0, 0)
    valLabel.BackgroundTransparency = 1
    valLabel.Text = tostring(default)
    valLabel.TextColor3 = Theme.Accent
    valLabel.Font = Theme.FontBold
    valLabel.TextSize = 10
    valLabel.TextXAlignment = Enum.TextXAlignment.Right
    valLabel.Parent = frame

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -110, 0, 4)
    track.Position = UDim2.new(0, 10, 1, -8)
    track.BackgroundColor3 = Theme.Off
    track.BorderSizePixel = 0
    track.Parent = frame
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Theme.Accent
    fill.BorderSizePixel = 0
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
            dragging = true; update(input.Position.X)
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

local function MakeSection(text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 18)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Theme.TextDim
    lbl.Font = Theme.FontBold
    lbl.TextSize = 10
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = Content
end

--=========================================================
-- UI СЕКЦИИ
--=========================================================
MakeSection("ESP")
MakeToggle("ESP Enabled", true, function() Config.ESP.Enabled = not Config.ESP.Enabled end)
MakeToggle("Boxes", true, function() Config.ESP.Box = not Config.ESP.Box end)
MakeToggle("Names", true, function() Config.ESP.Name = not Config.ESP.Name end)
MakeToggle("Distance", true, function() Config.ESP.Distance = not Config.ESP.Distance end)
MakeToggle("Health Bar", true, function() Config.ESP.Health = not Config.ESP.Health end)
MakeToggle("Tracers", true, function() Config.ESP.Tracer = not Config.ESP.Tracer end)
MakeSlider("ESP Distance", 200, 3000, 1500, function(v) Config.ESP.MaxDistance = v end)

MakeSection("AIMBOT")
MakeToggle("Aimbot", false, function() Config.Aimbot.Enabled = not Config.Aimbot.Enabled end)
MakeSlider("FOV Radius", 30, 600, 200, function(v) Config.Aimbot.FOV = v end)
MakeSlider("Smoothness x100", 10, 100, 50, function(v) Config.Aimbot.Smoothness = v / 100 end)
MakeSlider("Max Distance", 100, 2000, 600, function(v) Config.Aimbot.MaxDistance = v end)

MakeSection("SILENT AIM")
MakeToggle("Silent Aim", false, function() Config.Silent.Enabled = not Config.Silent.Enabled end)
MakeSlider("Silent FOV", 30, 600, 200, function(v) Config.Silent.FOV = v end)
MakeSlider("Silent Max Dist", 100, 2000, 600, function(v) Config.Silent.MaxDistance = v end)

MakeSection("MOVEMENT (Anti-Teleport)")
MakeToggle("Speed Hack", false, function() Config.Player.SpeedEnabled = not Config.Player.SpeedEnabled end)
MakeSlider("Speed (10-50)", 10, 50, 30, function(v) Config.Player.SpeedValue = v end)
MakeToggle("Noclip", false, function() Config.Player.Noclip = not Config.Player.Noclip end)
MakeToggle("No Fall Damage", false, function() Config.Player.NoFallDamage = not Config.Player.NoFallDamage end)
MakeToggle("Infinite Jump", false, function() Config.Misc.InfiniteJump = not Config.Misc.InfiniteJump end)

MakeSection("HELICOPTER")
MakeToggle("Heli Fly", false, function() Config.Heli.Enabled = not Config.Heli.Enabled end)
MakeSlider("Heli Speed", 20, 200, 60, function(v) Config.Heli.Speed = v end)

MakeSection("VISUAL")
MakeToggle("Fullbright", false, function() Config.Visual.Fullbright = not Config.Visual.Fullbright end)
MakeToggle("No Fog", false, function() Config.Visual.NoFog = not Config.Visual.NoFog end)
MakeToggle("FPS Boost", false, function() Config.Visual.FPSBoost = not Config.Visual.FPSBoost end)

MakeSection("MISC")
MakeToggle("Anti-AFK", false, function() Config.Misc.AntiAFK = not Config.Misc.AntiAFK end)

--=========================================================
-- FC КНОПКА
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
FCBtn.Active = true
FCBtn.Draggable = true
FCBtn.Parent = ScreenGui
Instance.new("UIStroke", FCBtn).Color = Theme.Accent
Instance.new("UIStroke", FCBtn).Thickness = 1.5
FCBtn.MouseButton1Click:Connect(function() Menu.Visible = not Menu.Visible end)
CloseBtn.MouseButton1Click:Connect(function() Menu.Visible = false end)

--=========================================================
-- ESP
--=========================================================
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

--=========================================================
-- ТАРГЕТ (общий для Aimbot и Silent Aim)
--=========================================================
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

-- Silent target обновление
local silentPart = nil
TrackConn(RunService.RenderStepped:Connect(function()
    if Config.Silent.Enabled then
        local plr, part = GetClosestTarget(Config.Silent.FOV, Config.Silent.MaxDistance, Config.Silent.TeamCheck)
        silentPart = part
    else
        silentPart = nil
    end
end))

--=========================================================
-- SILENT AIM HOOK — подмена таблицы в Fire
--=========================================================
pcall(function()
    if not (hookmetamethod and newcclosure) then return end
    local oldNC
    oldNC = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        
        if method == "FireServer" and typeof(self) == "Instance" then
            if self.Name == "Fire" and Config.Silent.Enabled and silentPart then
                local args = {...}
                
                -- Первый аргумент — таблица с данными выстрела
                if type(args[1]) == "table" then
                    local data = args[1]
                    
                    -- Ищем поле dir (направление)
                    if data.dir then
                        local myPos = Camera.CFrame.Position
                        local targetPos = silentPart.Position
                        -- ВАЖНО: направление = (цель - камера).Unit
                        local newDir = (targetPos - myPos).Unit
                        
                        data.dir = newDir
                        
                        if Config.Silent.Debug then
                            notify("SilentAim ✅", silentPart.Parent.Name)
                        end
                        
                        return oldNC(self, table.unpack(args))
                    end
                    
                    -- Пробуем другие поля (например origin)
                    if data.origin and data.dir then
                        data.dir = (silentPart.Position - data.origin).Unit
                        return oldNC(self, table.unpack(args))
                    end
                end
            end
        end
        
        return oldNC(self, ...)
    end))
end)

--=========================================================
-- SPEED (Anti-Teleport)
--=========================================================
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
        if hum.WalkSpeed < 10 and smoothedSpeed > 20 then hum.WalkSpeed = smoothedSpeed end
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

--=========================================================
-- HELI FLY
--=========================================================
TrackConn(RunService.Heartbeat:Connect(function()
    if not Config.Heli.Enabled then return end
    local char = LP.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or not hum.SeatPart then return end
    local seat = hum.SeatPart
    local vehicle = seat.Parent
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

--=========================================================
-- FOV КРУГ
--=========================================================
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

--=========================================================
-- ГЛАВНЫЙ ЦИКЛ
--=========================================================
TrackConn(RunService.RenderStepped:Connect(function()
    -- FOV
    if Config.Aimbot.Enabled or Config.Silent.Enabled then
        FovCircle.Visible = true
        local size = Config.Aimbot.Enabled and Config.Aimbot.FOV or Config.Silent.FOV
        FovCircle.Size = UDim2.new(0, size * 2, 0, size * 2)
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
                            d.Box.Visible = Config.ESP.Box
                            d.Box.Size = Vector2.new(w, h)
                            d.Box.Position = Vector2.new(x, y)
                            d.BoxOutline.Visible = Config.ESP.Box
                            d.BoxOutline.Size = Vector2.new(w, h)
                            d.BoxOutline.Position = Vector2.new(x, y)
                            d.Name.Visible = Config.ESP.Name
                            d.Name.Text = plr.Name
                            d.Name.Position = Vector2.new(sTop.X, y - 16)
                            d.Dist.Visible = Config.ESP.Distance
                            d.Dist.Text = math.floor(dist) .. "m"
                            d.Dist.Position = Vector2.new(sTop.X, y + h + 2)
                            if Config.ESP.Health then
                                local pct = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
                                d.HP.Visible = true
                                d.HP.Size = Vector2.new(3, h * pct)
                                d.HP.Position = Vector2.new(x - 5, y + h - h * pct)
                                d.HP.Color = pct > 0.6 and Color3.fromRGB(0,255,0) or pct > 0.3 and Color3.fromRGB(255,200,0) or Color3.fromRGB(255,0,0)
                            else
                                d.HP.Visible = false
                            end
                            d.Tracer.Visible = Config.ESP.Tracer
                            if Config.ESP.Tracer then
                                d.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                                d.Tracer.To = Vector2.new(sBot.X, sBot.Y)
                            end
                        else
                            for _, o in pairs(d) do o.Visible = false end
                        end
                    end
                end
            end
        end
    end

    -- Aimbot (двигает камеру)
    if Config.Aimbot.Enabled and (Config.Aimbot.TriggerActive or UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)) then
        local _, part = GetClosestTarget(Config.Aimbot.FOV, Config.Aimbot.MaxDistance, false)
        if part then
            local targetCF = CFrame.new(Camera.CFrame.Position, part.Position)
            Camera.CFrame = Camera.CFrame:Lerp(targetCF, Config.Aimbot.Smoothness)
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

    -- Visual
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
        VU:CaptureController()
        VU:ClickButton2(Vector2.new())
    end)
end))

--=========================================================
-- HOLD TO AIM
--=========================================================
local TriggerBtn = Instance.new("TextButton")
TriggerBtn.Size = UDim2.new(1, -16, 0, 36)
TriggerBtn.Position = UDim2.new(0, 8, 1, -44)
TriggerBtn.BackgroundColor3 = Theme.Accent
TriggerBtn.BorderSizePixel = 0
TriggerBtn.Text = "HOLD TO AIM"
TriggerBtn.TextColor3 = Color3.new(1,1,1)
TriggerBtn.Font = Theme.FontBold
TriggerBtn.TextSize = 12
TriggerBtn.Parent = Menu
Instance.new("UICorner", TriggerBtn).CornerRadius = UDim.new(0, 6)

local function setTrig(a)
    Config.Aimbot.TriggerActive = a
    TriggerBtn.BackgroundColor3 = a and Color3.fromRGB(180,150,255) or Theme.Accent
end
TriggerBtn.MouseButton1Down:Connect(function() setTrig(true) end)
TriggerBtn.MouseButton1Up:Connect(function() setTrig(false) end)
TriggerBtn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch then setTrig(true) end end)
TriggerBtn.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch then setTrig(false) end end)
TriggerBtn.MouseLeave:Connect(function() setTrig(false) end)

--=========================================================
-- UNLOAD
--=========================================================
local function Unload()
    for _, d in pairs(ESPCache) do
        for _, o in pairs(d) do pcall(function() o:Remove() end) end
    end
    for _, c in ipairs(Connections) do pcall(function() c:Disconnect() end) end
    pcall(function() ScreenGui:Destroy() end)
    getgenv().Fust_Loaded = false
    notify("FerClient", "Выгружен")
end
getgenv().Fust_Unload = Unload

notify("FerClient | Fust v2.0", "Silent Aim + ESP + Aimbot")
print("[FerClient] Fust v2.0 — Silent Aim через таблицу Fire")
