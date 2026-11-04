--[[ FerClient v8.2 | Black Screen Fix ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local LP = Players.LocalPlayer

-- Безопасная камера
local function GetCamera()
    local cam = Workspace.CurrentCamera
    if cam and cam.Parent then return cam end
    return nil
end

-- Конфиг
local C = {
    AimBot=false, AimPart="Head", Smooth=0.35, FOV=150, MaxDist=500, WallCheck=false, TeamCheck=false,
    ESP=false, ESPBox=true, ESPName=true, ESPDist=true, ESPMaxDist=1000,
    ESPColor=Color3.fromRGB(0,200,255), ShowFOV=false,
    Fullbright=false, XRay=false, NoDeco=false, SkyFon=false, FPSBoost=false,
    InfJump=false, AntiAFK=false, HitSound=false
}

-- Кэш
local PlayerCache = {}
for _, pl in ipairs(Players:GetPlayers()) do
    if pl ~= LP then PlayerCache[pl] = {Char=pl.Character, HRP=pl.Character and pl.Character:FindFirstChild("HumanoidRootPart")} end
end
Players.PlayerAdded:Connect(function(pl) if pl ~= LP then PlayerCache[pl] = {Char=pl.Character, HRP=pl.Character and pl.Character:FindFirstChild("HumanoidRootPart")} end end)
Players.PlayerRemoving:Connect(function(pl) PlayerCache[pl] = nil end)

-- UI
local ACC = Color3.fromRGB(0,170,255)
local BG = Color3.fromRGB(15,15,20)
local P2 = Color3.fromRGB(30,30,40)
local TXT = Color3.fromRGB(235,235,245)
local SUB = Color3.fromRGB(150,150,165)
local OFF = Color3.fromRGB(60,60,75)

local function N(class, props, parent)
    local o = Instance.new(class)
    for k, v in pairs(props or {}) do o[k] = v end
    if parent then o.Parent = parent end
    return o
end

local SG = N("ScreenGui", {Name="FerUI", ResetOnSpawn=false, IgnoreGuiInset=true}, CoreGui)
local AV = N("ImageButton", {Size=UDim2.new(0,40,0,40), Position=UDim2.new(0,20,0.5,-20), BackgroundColor3=BG, BorderSizePixel=0}, SG)
N("UICorner", {CornerRadius=UDim.new(1,0)}, AV)
N("TextLabel", {Text="F", Font=Enum.Font.GothamBlack, TextSize=24, TextColor3=Color3.new(1,1,1), BackgroundTransparency=1, Size=UDim2.new(1,0,1,0)}, AV)

local M = N("Frame", {Size=UDim2.new(0,420,0,300), Position=UDim2.new(0.5,-210,0.5,-150), BackgroundColor3=BG, BorderSizePixel=0, Visible=false}, SG)
N("UICorner", {CornerRadius=UDim.new(0,12)}, M)
N("UIStroke", {Color=ACC, Thickness=1}, M)

local TB = N("Frame", {Size=UDim2.new(1,0,0,40), BackgroundColor3=P2, BorderSizePixel=0}, M)
N("UICorner", {CornerRadius=UDim.new(0,12)}, TB)
N("TextLabel", {Text="  FerClient v8.2", Font=Enum.Font.GothamBold, TextSize=16, TextColor3=TXT, BackgroundTransparency=1, Size=UDim2.new(1,-50,1,0), TextXAlignment=Enum.TextXAlignment.Left}, TB)
local CL = N("TextButton", {Text="✕", Font=Enum.Font.GothamBold, TextSize=14, TextColor3=TXT, BackgroundColor3=Color3.fromRGB(220,50,70), Size=UDim2.new(0,26,0,26), Position=UDim2.new(1,-32,0.5,-13), BorderSizePixel=0}, TB)
N("UICorner", {CornerRadius=UDim.new(0,6)}, CL)

local TBB = N("Frame", {Size=UDim2.new(0,100,1,-40), Position=UDim2.new(0,0,0,40), BackgroundColor3=BG, BorderSizePixel=0}, M)
N("UIListLayout", {FillDirection=Enum.FillDirection.Vertical, Padding=UDim.new(0,6), HorizontalAlignment=Enum.HorizontalAlignment.Center, VerticalAlignment=Enum.VerticalAlignment.Top}, TBB)

local CT = N("ScrollingFrame", {Size=UDim2.new(1,-110,1,-50), Position=UDim2.new(0,104,0,44), BackgroundColor3=PANEL, BorderSizePixel=0, ScrollBarThickness=3, CanvasSize=UDim2.new(0,0,0,0)}, M)
N("UICorner", {CornerRadius=UDim.new(0,8)}, CT)
local CLL = N("UIListLayout", {Padding=UDim.new(0,6)}, CT)
N("UIPadding", {PaddingTop=UDim.new(0,8), PaddingLeft=UDim.new(0,8), PaddingRight=UDim.new(0,8), PaddingBottom=UDim.new(0,8)}, CT)

local function Label(text)
    N("TextLabel", {Text=text, Font=Enum.Font.GothamBold, TextSize=12, TextColor3=SUB, BackgroundTransparency=1, Size=UDim2.new(1,0,0,20), TextXAlignment=Enum.TextXAlignment.Left}, CT)
end

local function Toggle(text, val, cb)
    local row = N("Frame", {Size=UDim2.new(1,0,0,30), BackgroundColor3=P2, BorderSizePixel=0}, CT)
    N("UICorner", {CornerRadius=UDim.new(0,6)}, row)
    N("TextLabel", {Text="  "..text, Font=Enum.Font.Gotham, TextSize=13, TextColor3=TXT, BackgroundTransparency=1, Size=UDim2.new(1,-50,1,0), TextXAlignment=Enum.TextXAlignment.Left}, row)
    local sw = N("Frame", {Size=UDim2.new(0,34,0,18), Position=UDim2.new(1,-42,0.5,-9), BackgroundColor3=val and ACC or OFF, BorderSizePixel=0}, row)
    N("UICorner", {CornerRadius=UDim.new(1,0)}, sw)
    local st = val
    local btn = N("TextButton", {Text="", BackgroundTransparency=1, Size=UDim2.new(1,0,1,0)}, row)
    btn.MouseButton1Click:Connect(function()
        st = not st
        sw.BackgroundColor3 = st and ACC or OFF
        if cb then cb(st) end
    end)
end

local function Slider(text, mn, mx, def, cb)
    local row = N("Frame", {Size=UDim2.new(1,0,0,48), BackgroundColor3=P2, BorderSizePixel=0}, CT)
    N("UICorner", {CornerRadius=UDim.new(0,6)}, row)
    N("TextLabel", {Text="  "..text, Font=Enum.Font.Gotham, TextSize=13, TextColor3=TXT, BackgroundTransparency=1, Size=UDim2.new(1,-50,0,22), TextXAlignment=Enum.TextXAlignment.Left}, row)
    local vl = N("TextLabel", {Text=tostring(def), Font=Enum.Font.GothamBold, TextSize=13, TextColor3=ACC, BackgroundTransparency=1, Size=UDim2.new(0,50,0,22), Position=UDim2.new(1,-55,0,0), TextXAlignment=Enum.TextXAlignment.Right}, row)
    local tr = N("Frame", {Size=UDim2.new(1,-20,0,4), Position=UDim2.new(0,10,0,32), BackgroundColor3=OFF, BorderSizePixel=0}, row)
    N("UICorner", {CornerRadius=UDim.new(0,2)}, tr)
    local fl = N("Frame", {Size=UDim2.new((def-mn)/(mx-mn),0,1,0), BackgroundColor3=ACC, BorderSizePixel=0}, tr)
    local inp = N("TextButton", {Text="", BackgroundTransparency=1, Size=UDim2.new(1,0,1,0)}, row)
    local dragging = false
    inp.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true end end)
    inp.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local r = math.clamp((i.Position.X - tr.AbsolutePosition.X) / tr.AbsoluteSize.X, 0, 1)
            local v = math.floor(mn + (mx - mn) * r + 0.5)
            vl.Text = tostring(v)
            fl.Size = UDim2.new(r, 0, 1, 0)
            if cb then cb(v) end
        end
    end)
end

local function AddTab(name)
    local b = N("TextButton", {Text=name, Font=Enum.Font.GothamSemibold, TextSize=13, TextColor3=SUB, BackgroundColor3=P2, Size=UDim2.new(0,90,0,28), BorderSizePixel=0}, TBB)
    N("UICorner", {CornerRadius=UDim.new(0,6)}, b)
    b.MouseButton1Click:Connect(function()
        for _, obj in ipairs(CT:GetChildren()) do if obj:IsA("GuiObject") then obj:Destroy() end end
        if name == "Combat" then
            Label("COMBAT")
            Toggle("Aim Bot", C.AimBot, function(v) C.AimBot = v end)
            Toggle("Team Check", C.TeamCheck, function(v) C.TeamCheck = v end)
            Toggle("Wall Check", C.WallCheck, function(v) C.WallCheck = v end)
            Slider("Smooth", 1, 100, 35, function(v) C.Smooth = v/100 end)
            Slider("FOV", 10, 400, 150, function(v) C.FOV = v end)
        elseif name == "Visual" then
            Label("PLAYER VISUAL")
            Toggle("ESP", C.ESP, function(v) C.ESP = v end)
            Toggle("  Box", C.ESPBox, function(v) C.ESPBox = v end)
            Toggle("  Name", C.ESPName, function(v) C.ESPName = v end)
            Toggle("  Distance", C.ESPDist, function(v) C.ESPDist = v end)
            Slider("Max Dist", 50, 5000, 1000, function(v) C.ESPMaxDist = v end)
            Toggle("Show FOV", C.ShowFOV, function(v) C.ShowFOV = v end)
            Toggle("Fullbright", C.Fullbright, function(v) C.Fullbright = v end)
            Toggle("X-Ray", C.XRay, function(v) C.XRay = v end)
            Toggle("FPS Boost", C.FPSBoost, function(v) C.FPSBoost = v end)
        elseif name == "Misc" then
            Label("MISC")
            Toggle("Inf Jump", C.InfJump, function(v) C.InfJump = v end)
            Toggle("Anti AFK", C.AntiAFK, function(v) C.AntiAFK = v end)
            Toggle("Hit Sound", C.HitSound, function(v) C.HitSound = v end)
        end
    end)
end

AddTab("Combat") AddTab("Visual") AddTab("Misc")

AV.MouseButton1Click:Connect(function() M.Visible = not M.Visible end)
CL.MouseButton1Click:Connect(function() M.Visible = false end)

-- Отрисовка ESP (безопасная)
local Drawing_OK = pcall(function() local t = Drawing.new("Square") t:Remove() end)
local Drawings = {}

RunService.RenderStepped:Connect(function()
    local cam = GetCamera()
    if not cam then return end
    
    if not Drawing_OK then return end

    for pl, data in pairs(PlayerCache) do
        if not Drawings[pl] then
            local b = Drawing.new("Square")
            b.Thickness = 1
            b.Filled = false
            local n = Drawing.new("Text")
            n.Size = 12
            n.Center = true
            n.Outline = true
            n.Color = Color3.new(1,1,1)
            Drawings[pl] = {b = b, n = n}
        end
        
        local d = Drawings[pl]
        local hrp = data.HRP
        
        if C.ESP and hrp and hrp.Parent then
            local top = cam:WorldToViewportPoint(hrp.Position + Vector3.new(0,3,0))
            local bot = cam:WorldToViewportPoint(hrp.Position - Vector3.new(0,3,0))
            local pos, on = cam:WorldToViewportPoint(hrp.Position)
            
            if on then
                local h = math.abs(top.Y - bot.Y)
                local w = h * 0.55
                d.b.Size = Vector2.new(w, h)
                d.b.Position = Vector2.new(pos.X - w/2, top.Y)
                d.b.Color = C.ESPColor
                d.b.Visible = C.ESPBox
                
                d.n.Text = pl.Name
                d.n.Position = Vector2.new(pos.X, top.Y - 14)
                d.n.Visible = C.ESPName
            else
                d.b.Visible = false
                d.n.Visible = false
            end
        else
            d.b.Visible = false
            d.n.Visible = false
        end
    end
end)

print("[FerClient v8.2] Успешно загружен!")
