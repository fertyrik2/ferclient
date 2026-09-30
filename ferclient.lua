--[[
    ███████╗███████╗██████╗  ██████╗██╗     ██╗███████╗███╗   ██╗████████╗
    ██╔════╝██╔════╝██╔══██╗██╔════╝██║     ██║██╔════╝████╗  ██║╚══██╔══╝
    █████╗  █████╗  ██████╔╝██║     ██║     ██║█████╗  ██╔██╗ ██║   ██║
    ██╔══╝  ██╔══╝  ██╔══██╗██║     ██║     ██║██╔══╝  ██║╚██╗██║   ██║
    ██║     ███████╗██║  ██║╚██████╗███████╗██║███████╗██║ ╚████║   ██║
    ╚═╝     ╚══════╝╚═╝  ╚═╝ ╚═════╝╚══════╝╚═╝╚══════╝╚═╝  ╚═══╝   ╚═╝

    FerClient | Rost Alpha Cheat
    ESP + Aimbot FOV | Mobile & PC
    Version: 1.0
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

local Config = {
    ESP = {
        Enabled = true,
        Box = true,
        Name = true,
        Distance = true,
        Health = true,
        Tracer = true,
        Color = Theme.Accent,
        MaxDistance = 1500,
    },
    Aimbot = {
        Enabled = false,
        FOV = 150,
        Smoothness = 0.3,
        MaxDistance = 600,
        TargetPart = "Head",
        Visible = true,
        ShowFOV = true,
        TriggerActive = false,
    }
}

local hasDrawing = pcall(function()
    local t = Drawing.new("Square")
    t:Remove()
end)

if not hasDrawing then
    warn("[FerClient] Drawing API не поддерживается! ESP работать не будет.")
end

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
    local steps = { 0.3, 0.6, 0.85, 1 }
    for _, v in ipairs(steps) do
        TweenService:Create(ProgressFill, TweenInfo.new(0.25), { Size = UDim2.new(v, 0, 1, 0) }):Play()
        task.wait(0.3)
    end
    task.wait(0.2)
    TweenService:Create(LoaderBg, TweenInfo.new(0.4), { BackgroundTransparency = 1 }):Play()
    TweenService:Create(LoaderCard, TweenInfo.new(0.4), { BackgroundTransparency = 1 }):Play()
    task.wait(0.4)
    LoaderGui:Destroy()
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FerClient_Menu"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 100
pcall(function() ScreenGui.Parent = HUI end)
if not ScreenGui.Parent then ScreenGui.Parent = LP:WaitForChild("PlayerGui") end

local Menu = Instance.new("Frame")
Menu.Name = "FerClient_Frame"
Menu.Size = UDim2.new(0, 250, 0, 310)
Menu.Position = UDim2.new(0, 20, 0, 100)
Menu.BackgroundColor3 = Theme.Background
Menu.BorderSizePixel = 0
Menu.Active = true
Menu.Draggable = true
Menu.Parent = ScreenGui
Instance.new("UICorner", Menu).CornerRadius = UDim.new(0, 10)

local MenuStroke = Instance.new("UIStroke", Menu)
MenuStroke.Color = Theme.Border
MenuStroke.Thickness = 1.5

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

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -16, 1, -50)
Content.Position = UDim2.new(0, 8, 0, 46)
Content.BackgroundTransparency = 1
Content.Parent = Menu

local Layout = Instance.new("UIListLayout", Content)
Layout.Padding = UDim.new(0, 6)
Layout.SortOrder = Enum.SortOrder.LayoutOrder

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

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = Theme.Hover }):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = Theme.Element }):Play()
    end)

    btn.MouseButton1Click:Connect(function()
        pcall(callback)
    end)

    return {
        Button = btn,
        SetOn = function(isOn)
            statusLabel.Text = isOn and "ON" or "OFF"
            statusLabel.TextColor3 = isOn and Theme.Success or Theme.Danger
        end
    }
end

local ESPButton = MakeButton("ESP", function()
    Config.ESP.Enabled = not Config.ESP.Enabled
    ESPButton.SetOn(Config.ESP.Enabled)
end)
ESPButton.SetOn(Config.ESP.Enabled)

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

local TriggerBtn = Instance.new("TextButton")
TriggerBtn.Size = UDim2.new(1, 0, 0, 42)
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

local TrigStroke = Instance.new("UIStroke", TriggerBtn)
TrigStroke.Color = Theme.Border
TrigStroke.Thickness = 1

TriggerBtn.MouseButton1Down:Connect(function()
    Config.Aimbot.TriggerActive = true
    TweenService:Create(TriggerBtn, TweenInfo.new(0.1), { BackgroundColor3 = Color3.fromRGB(120, 180, 255) }):Play()
end)
TriggerBtn.MouseButton1Up:Connect(function()
    Config.Aimbot.TriggerActive = false
    TweenService:Create(TriggerBtn, TweenInfo.new(0.1), { BackgroundColor3 = Theme.Accent }):Play()
end)
TriggerBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        Config.Aimbot.TriggerActive = true
        TweenService:Create(TriggerBtn, TweenInfo.new(0.1), { BackgroundColor3 = Color3.fromRGB(120, 180, 255) }):Play()
    end
end)
TriggerBtn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        Config.Aimbot.TriggerActive = false
        TweenService:Create(TriggerBtn, TweenInfo.new(0.1), { BackgroundColor3 = Theme.Accent }):Play()
    end
end)

local isMinimized = false
local function toggleMinimize()
    isMinimized = not isMinimized
    local targetSize = isMinimized and UDim2.new(0, 250, 0, 38) or UDim2.new(0, 250, 0, 310)
    TweenService:Create(Menu, TweenInfo.new(0.25, Enum.EasingStyle.Quad), { Size = targetSize }):Play()
    Content.Visible = not isMinimized
end

MinimizeBtn.MouseButton1Click:Connect(toggleMinimize)

MinimizeBtn.MouseEnter:Connect(function()
    TweenService:Create(MinimizeBtn, TweenInfo.new(0.15), { BackgroundColor3 = Theme.Hover }):Play()
end)
MinimizeBtn.MouseLeave:Connect(function()
    TweenService:Create(MinimizeBtn, TweenInfo.new(0.15), { BackgroundColor3 = Theme.Element }):Play()
end)

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
    for _, o in pairs(d) do
        pcall(function() o:Remove() end)
    end
    ESPCache[player] = nil
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

RunService.RenderStepped:Connect(function()
    if Config.Aimbot.ShowFOV and Config.Aimbot.Enabled then
        FovCircle.Visible = true
        FovCircle.Size = UDim2.new(0, Config.Aimbot.FOV * 2, 0, Config.Aimbot.FOV * 2)
        FovCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
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

    if Config.Aimbot.Enabled then
        local shouldAim = Config.Aimbot.TriggerActive
            or UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)

        if shouldAim then
            local target = GetClosestTarget()
            if target then
                local newCF = CFrame.new(Camera.CFrame.Position, target.Position)
                Camera.CFrame = Camera.CFrame:Lerp(newCF, Config.Aimbot.Smoothness)
            end
        end
    end
end)

Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(RemoveESP)
for _, plr in ipairs(Players:GetPlayers()) do
    CreateESP(plr)
end

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

print("[FerClient] Успешно загружен на Rost Alpha!")
print("[FerClient] Версия: 1.0")
print("[FerClient] F1 - ESP | F2 - Aimbot | RightShift - Свернуть")
