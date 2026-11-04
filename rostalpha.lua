--[[ FerClient v8.8 | Stable Mobile Fix ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LP = Players.LocalPlayer

local function GetCamera()
    local cam = workspace.CurrentCamera
    if cam and cam.Parent then return cam end
    return nil
end

local C = {
    AimBot=false, AimPart="Head", Smooth=0.35, FOV=150, TeamCheck=false,
    ESP=false, ESPBox=true, ESPName=true, ESPDist=true, ESPSkeleton=false, ESPHP=false, ESPTracers=false, ESPMaxDist=1000,
    ESPColor=Color3.fromRGB(0,200,255), ShowFOV=false
}

local PlayerCache = {}
for _, pl in ipairs(Players:GetPlayers()) do
    if pl ~= LP then PlayerCache[pl] = {Char=pl.Character, HRP=pl.Character and pl.Character:FindFirstChild("HumanoidRootPart")} end
end
Players.PlayerAdded:Connect(function(pl) if pl ~= LP then PlayerCache[pl] = {Char=pl.Character, HRP=pl.Character and pl.Character:FindFirstChild("HumanoidRootPart")} end end)
Players.PlayerRemoving:Connect(function(pl) PlayerCache[pl] = nil end)

local ACC = Color3.fromRGB(0,170,255)
local BG = Color3.fromRGB(15,15,20)
local PANEL = Color3.fromRGB(22,22,30)
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
N("TextLabel", {Text="  FerClient v8.8", Font=Enum.Font.GothamBold, TextSize=16, TextColor3=TXT, BackgroundTransparency=1, Size=UDim2.new(1,-50,1,0), TextXAlignment=Enum.TextXAlignment.Left}, TB)
local CL = N("TextButton", {Text="✕", Font=Enum.Font.GothamBold, TextSize=14, TextColor3=TXT, BackgroundColor3=Color3.fromRGB(220,50,70), Size=UDim2.new(0,26,0,26), Position=UDim2.new(1,-32,0.5,-13), BorderSizePixel=0}, TB)
N("UICorner", {CornerRadius=UDim.new(0,6)}, CL)

local TBB = N("Frame", {Size=UDim2.new(0,100,1,-40), Position=UDim2.new(0,0,0,40), BackgroundColor3=BG, BorderSizePixel=0}, M)
N("UIListLayout", {FillDirection=Enum.FillDirection.Vertical, Padding=UDim.new(0,6), HorizontalAlignment=Enum.HorizontalAlignment.Center, VerticalAlignment=Enum.VerticalAlignment.Top}, TBB)

local CT = N("ScrollingFrame", {Size=UDim2.new(1,-110,1,-50), Position=UDim2.new(0,104,0,44), BackgroundColor3=PANEL, BorderSizePixel=0, ScrollBarThickness=4, ScrollBarImageColor3=ACC, CanvasSize=UDim2.new(0,0,0,0)}, M)
N("UICorner", {CornerRadius=UDim.new(0,8)}, CT)
local CLL = N("UIListLayout", {Padding=UDim.new(0,6)}, CT)
N("UIPadding", {PaddingTop=UDim.new(0,8), PaddingLeft=UDim.new(0,8), PaddingRight=UDim.new(0,8), PaddingBottom=UDim.new(0,8)}, CT)

local FOVCircle = N("Frame", {BackgroundTransparency=1, AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.new(0.5,0,0.5,0), Size=UDim2.new(0,300,0,300), Visible=false}, SG)
N("UICorner", {CornerRadius=UDim.new(1,0)}, FOVCircle)
local FOVStroke = N("UIStroke", {Thickness=1.5, Color=ACC, ApplyStrokeMode=Enum.ApplyStrokeMode.Border}, FOVCircle)

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
    btn.MouseButton1Click:Connect(function() st = not st sw.BackgroundColor3 = st and ACC or OFF if cb then cb(st) end end)
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
            if not tr or not tr.Parent or tr.AbsoluteSize.X == 0 then return end
            local r = math.clamp((i.Position.X - tr.AbsolutePosition.X) / tr.AbsoluteSize.X, 0, 1)
            local v = math.floor(mn + (mx - mn) * r + 0.5)
            vl.Text = tostring(v)
            fl.Size = UDim2.new(r, 0, 1, 0)
            if cb then cb(v) end
        end
    end)
end

local function BuildTab(name)
    for _, obj in ipairs(CT:GetChildren()) do if obj:IsA("GuiObject") then obj:Destroy() end end
    
    if name == "Combat" then
        Label("COMBAT")
        Toggle("Aim Bot", C.AimBot, function(v) C.AimBot = v end)
        Toggle("Team Check", C.TeamCheck, function(v) C.TeamCheck = v end)
        Toggle("Show FOV", C.ShowFOV, function(v) C.ShowFOV = v end)
        Slider("FOV Size", 30, 800, 150, function(v) C.FOV = v FOVCircle.Size = UDim2.new(0, v*2, 0, v*2) end)
        Slider("Smooth", 1, 100, 35, function(v) C.Smooth = v/100 end)
    elseif name == "Visual" then
        Label("PLAYER ESP")
        Toggle("ESP", C.ESP, function(v) C.ESP = v end)
        Toggle("  Box", C.ESPBox, function(v) C.ESPBox = v end)
        Toggle("  Name", C.ESPName, function(v) C.ESPName = v end)
        Toggle("  Distance", C.ESPDist, function(v) C.ESPDist = v end)
        Toggle("  Skeleton", C.ESPSkeleton, function(v) C.ESPSkeleton = v end)
        Toggle("  Health Bar", C.ESPHP, function(v) C.ESPHP = v end)
        Toggle("  Tracers", C.ESPTracers, function(v) C.ESPTracers = v end)
        Slider("Max Dist", 50, 5000, 1000, function(v) C.ESPMaxDist = v end)
    end
    
    task.defer(function()
        task.wait(0.1)
        CT.CanvasSize = UDim2.new(0, 0, 0, CLL.AbsoluteContentSize.Y + 20)
    end)
end

local TabBtn = N("TextButton", {Text="Combat", Font=Enum.Font.GothamSemibold, TextSize=13, TextColor3=ACC, BackgroundColor3=P2, Size=UDim2.new(0,90,0,28), BorderSizePixel=0}, TBB)
N("UICorner", {CornerRadius=UDim.new(0,6)}, TabBtn)
TabBtn.MouseButton1Click:Connect(function() BuildTab("Combat") end)

local TabBtn2 = N("TextButton", {Text="Visual", Font=Enum.Font.GothamSemibold, TextSize=13, TextColor3=SUB, BackgroundColor3=P2, Size=UDim2.new(0,90,0,28), BorderSizePixel=0}, TBB)
N("UICorner", {CornerRadius=UDim.new(0,6)}, TabBtn2)
TabBtn2.MouseButton1Click:Connect(function() BuildTab("Visual") end)

BuildTab("Combat")

AV.MouseButton1Click:Connect(function() M.Visible = not M.Visible end)
CL.MouseButton1Click:Connect(function() M.Visible = false end)

-- Драг
local mdrag, mds, mdp = false, nil, nil
TB.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then mdrag = true mds = i.Position mdp = M.Position end end)
TB.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then mdrag = false end end)
UserInputService.InputChanged:Connect(function(i) if mdrag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then local d = i.Position - mds M.Position = UDim2.new(mdp.X.Scale, mdp.X.Offset + d.X, mdp.Y.Scale, mdp.Y.Offset + d.Y) end end)

-- ESP (ИСПОЛЬЗУЕМ SQUARE ВМЕСТО LINE)
local Drawing_OK = pcall(function() local t = Drawing.new("Square") t:Remove() end)
local Drawings = {}

RunService.RenderStepped:Connect(function()
    local cam = GetCamera()
    if not cam then return end
    
    if C.ShowFOV then
        FOVCircle.Visible = true
        FOVCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
        FOVCircle.Size = UDim2.new(0, C.FOV*2, 0, C.FOV*2)
        FOVStroke.Color = C.ESPColor
    else
        FOVCircle.Visible = false
    end

    if not Drawing_OK then return end
    for pl, data in pairs(PlayerCache) do
        if not Drawings[pl] then
            local b = Drawing.new("Square") b.Thickness = 1 b.Filled = false
            local n = Drawing.new("Text") n.Size = 12 n.Center = true n.Outline = true n.Color = Color3.new(1,1,1)
            local d = Drawing.new("Text") d.Size = 11 d.Center = true d.Outline = true d.Color = C.ESPColor
            local hp = Drawing.new("Square") hp.Thickness = 1 hp.Filled = true
            local sk = Drawing.new("Square") sk.Thickness = 1 sk.Filled = true
            local tr = Drawing.new("Square") tr.Thickness = 1 tr.Filled = true
            Drawings[pl] = {b=b, n=n, d=d, hp=hp, sk=sk, tr=tr}
        end
        
        local e = Drawings[pl]
        local char = pl.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        
        if C.ESP and hrp and hum and hum.Health > 0 then
            local top = cam:WorldToViewportPoint(hrp.Position + Vector3.new(0,3,0))
            local bot = cam:WorldToViewportPoint(hrp.Position - Vector3.new(0,3,0))
            local pos, on = cam:WorldToViewportPoint(hrp.Position)
            
            if on then
                local h = math.abs(top.Y - bot.Y)
                local w = h * 0.55
                local x, y = pos.X - w/2, top.Y
                
                e.b.Size = Vector2.new(w, h) e.b.Position = Vector2.new(x, y) e.b.Color = C.ESPColor e.b.Visible = C.ESPBox
                e.n.Text = pl.Name e.n.Position = Vector2.new(pos.X, y - 16) e.n.Visible = C.ESPName
                local LPH = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                local dist = LPH and math.floor((LPH.Position - hrp.Position).Magnitude) or 0
                e.d.Text = "[" .. dist .. "m]" e.d.Position = Vector2.new(pos.X, bot.Y + 2) e.d.Visible = C.ESPDist
                
                local hp_val = hum.Health / hum.MaxHealth
                e.hp.Size = Vector2.new(3, h * hp_val) e.hp.Position = Vector2.new(x - 6, y + h - (h * hp_val)) e.hp.Color = Color3.fromHSV(hp_val * 0.3, 1, 1) e.hp.Visible = C.ESPHP
                
                if C.ESPSkeleton then
                    local head = char:FindFirstChild("Head")
                    if head then
                        local hpos = cam:WorldToViewportPoint(head.Position)
                        e.sk.Size = Vector2.new(2, math.abs(hpos.Y - pos.Y)) e.sk.Position = Vector2.new(pos.X, hpos.Y) e.sk.Color = C.ESPColor e.sk.Visible = true
                    end
                else
                    e.sk.Visible = false
                end
                
                if C.ESPTracers then
                    e.tr.Size = Vector2.new(2, 1) e.tr.Position = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y) e.tr.Color = C.ESPColor e.tr.Visible = true
                else
                    e.tr.Visible = false
                end
            else
                e.b.Visible = false e.n.Visible = false e.d.Visible = false e.hp.Visible = false e.sk.Visible = false e.tr.Visible = false
            end
        else
            e.b.Visible = false e.n.Visible = false e.d.Visible = false e.hp.Visible = false e.sk.Visible = false e.tr.Visible = false
        end
    end
end)

-- AIM
local function GetNearest()
    local cam = GetCamera() if not cam then return nil end
    local best, dist = nil, C.FOV
    local cen = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
    for pl, data in pairs(PlayerCache) do
        local hrp = data.HRP
        if hrp and hrp.Parent then
            if C.TeamCheck and pl.Team == LP.Team then continue end
            local sp, on = cam:WorldToViewportPoint(hrp.Position)
            if on then
                local d = (Vector2.new(sp.X, sp.Y) - cen).Magnitude
                if d < dist then dist = d best = pl end
            end
        end
    end
    return best
end

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if C.AimBot then
            local target = GetNearest()
            if target and target.Character and target.Character:FindFirstChild(C.AimPart) then
                local cam = GetCamera()
                if cam then 
                    local part = target.Character[C.AimPart]
                    local vel = target.Character.HumanoidRootPart and target.Character.HumanoidRootPart.AssemblyLinearVelocity or Vector3.new(0,0,0)
                    cam.CFrame = CFrame.new(cam.CFrame.Position, part.Position + (vel * 0.1))
                end
            end
        end
    end
end)

print("[FerClient v8.8] Загружен!")
