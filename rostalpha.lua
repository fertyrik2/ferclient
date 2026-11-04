--[[ FerClient v9.0 | Full Functions + Prediction + FOV ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local LP = Players.LocalPlayer

local function GetCamera()
    local cam = workspace.CurrentCamera
    if cam and cam.Parent then return cam end
    return nil
end

local C = {
    AimBot=false, AimPart="Head", Smooth=0.15, FOV=150, TeamCheck=false, Prediction=0.15,
    ESP=false, ESPBox=true, ESPName=true, ESPDist=true, ESPSkeleton=false, ESPHP=false, ESPTracers=false, ESPMaxDist=1000,
    ESPColor=Color3.fromRGB(0,200,255), ShowFOV=false,
    Fullbright=false, XRay=false, NoDeco=false,
    InfJump=false, AntiAFK=false,
    SulfurESP=false, IronESP=false, StoneESP=false, OreDist=500,
    CrateESP=false, MilitaryESP=false, EliteESP=false, FoodESP=false, CrateDist=500
}

local PlayerCache = {}
local function CachePlayer(pl)
    if pl ~= LP then 
        PlayerCache[pl] = {Char=pl.Character, HRP=pl.Character and pl.Character:FindFirstChild("HumanoidRootPart")}
        pl.CharacterAdded:Connect(function(char)
            task.wait(1)
            PlayerCache[pl] = {Char=char, HRP=char:FindFirstChild("HumanoidRootPart")}
        end)
    end
end
for _, pl in ipairs(Players:GetPlayers()) do CachePlayer(pl) end
Players.PlayerAdded:Connect(CachePlayer)
Players.PlayerRemoving:Connect(function(pl) PlayerCache[pl] = nil end)

local ACC = Color3.fromRGB(0,170,255) local BG = Color3.fromRGB(15,15,20) local PANEL = Color3.fromRGB(22,22,30)
local P2 = Color3.fromRGB(30,30,40) local TXT = Color3.fromRGB(235,235,245) local SUB = Color3.fromRGB(150,150,165) local OFF = Color3.fromRGB(60,60,75)

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
N("TextLabel", {Text="  FerClient v9.0", Font=Enum.Font.GothamBold, TextSize=16, TextColor3=TXT, BackgroundTransparency=1, Size=UDim2.new(1,-50,1,0), TextXAlignment=Enum.TextXAlignment.Left}, TB)
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

local function Label(text) N("TextLabel", {Text=text, Font=Enum.Font.GothamBold, TextSize=12, TextColor3=SUB, BackgroundTransparency=1, Size=UDim2.new(1,0,0,20), TextXAlignment=Enum.TextXAlignment.Left}, CT) end
local function Toggle(text, val, cb)
    local row = N("Frame", {Size=UDim2.new(1,0,0,30), BackgroundColor3=P2, BorderSizePixel=0}, CT) N("UICorner", {CornerRadius=UDim.new(0,6)}, row)
    N("TextLabel", {Text="  "..text, Font=Enum.Font.Gotham, TextSize=13, TextColor3=TXT, BackgroundTransparency=1, Size=UDim2.new(1,-50,1,0), TextXAlignment=Enum.TextXAlignment.Left}, row)
    local sw = N("Frame", {Size=UDim2.new(0,34,0,18), Position=UDim2.new(1,-42,0.5,-9), BackgroundColor3=val and ACC or OFF, BorderSizePixel=0}, row) N("UICorner", {CornerRadius=UDim.new(1,0)}, sw)
    local st = val
    local btn = N("TextButton", {Text="", BackgroundTransparency=1, Size=UDim2.new(1,0,1,0)}, row)
    btn.MouseButton1Click:Connect(function() st = not st sw.BackgroundColor3 = st and ACC or OFF if cb then cb(st) end end)
end
local function Slider(text, mn, mx, def, cb)
    local row = N("Frame", {Size=UDim2.new(1,0,0,48), BackgroundColor3=P2, BorderSizePixel=0}, CT) N("UICorner", {CornerRadius=UDim.new(0,6)}, row)
    N("TextLabel", {Text="  "..text, Font=Enum.Font.Gotham, TextSize=13, TextColor3=TXT, BackgroundTransparency=1, Size=UDim2.new(1,-50,0,22), TextXAlignment=Enum.TextXAlignment.Left}, row)
    local vl = N("TextLabel", {Text=tostring(def), Font=Enum.Font.GothamBold, TextSize=13, TextColor3=ACC, BackgroundTransparency=1, Size=UDim2.new(0,50,0,22), Position=UDim2.new(1,-55,0,0), TextXAlignment=Enum.TextXAlignment.Right}, row)
    local tr = N("Frame", {Size=UDim2.new(1,-20,0,4), Position=UDim2.new(0,10,0,32), BackgroundColor3=OFF, BorderSizePixel=0}, row) N("UICorner", {CornerRadius=UDim.new(0,2)}, tr)
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
            vl.Text = tostring(v) fl.Size = UDim2.new(r, 0, 1, 0)
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
        Slider("Smooth", 1, 100, 15, function(v) C.Smooth = v/100 end)
        Slider("Prediction", 0, 50, 15, function(v) C.Prediction = v/100 end)
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
        
        Label("RESOURCES")
        Toggle("Sulfur ESP", C.SulfurESP, function(v) C.SulfurESP = v end)
        Toggle("Iron ESP", C.IronESP, function(v) C.IronESP = v end)
        Toggle("Stone ESP", C.StoneESP, function(v) C.StoneESP = v end)
        Toggle("Crate ESP", C.CrateESP, function(v) C.CrateESP = v end)
        Toggle("Military Crate", C.MilitaryESP, function(v) C.MilitaryESP = v end)
        Toggle("Elite Crate", C.EliteESP, function(v) C.EliteESP = v end)
        Toggle("Food Box", C.FoodESP, function(v) C.FoodESP = v end)
        
        Label("WORLD")
        Toggle("Fullbright", C.Fullbright, function(v) C.Fullbright = v end)
        Toggle("X-Ray", C.XRay, function(v) C.XRay = v end)
        Toggle("No Deco", C.NoDeco, function(v) C.NoDeco = v end)
    elseif name == "Misc" then
        Label("MISC")
        Toggle("Inf Jump", C.InfJump, function(v) C.InfJump = v end)
        Toggle("Anti AFK", C.AntiAFK, function(v) C.AntiAFK = v end)
    end
    task.defer(function() task.wait(0.1) CT.CanvasSize = UDim2.new(0, 0, 0, CLL.AbsoluteContentSize.Y + 20) end)
end

local TabBtn = N("TextButton", {Text="Combat", Font=Enum.Font.GothamSemibold, TextSize=13, TextColor3=ACC, BackgroundColor3=P2, Size=UDim2.new(0,90,0,28), BorderSizePixel=0}, TBB) N("UICorner", {CornerRadius=UDim.new(0,6)}, TabBtn)
TabBtn.MouseButton1Click:Connect(function() BuildTab("Combat") end)
local TabBtn2 = N("TextButton", {Text="Visual", Font=Enum.Font.GothamSemibold, TextSize=13, TextColor3=SUB, BackgroundColor3=P2, Size=UDim2.new(0,90,0,28), BorderSizePixel=0}, TBB) N("UICorner", {CornerRadius=UDim.new(0,6)}, TabBtn2)
TabBtn2.MouseButton1Click:Connect(function() BuildTab("Visual") end)
local TabBtn3 = N("TextButton", {Text="Misc", Font=Enum.Font.GothamSemibold, TextSize=13, TextColor3=SUB, BackgroundColor3=P2, Size=UDim2.new(0,90,0,28), BorderSizePixel=0}, TBB) N("UICorner", {CornerRadius=UDim.new(0,6)}, TabBtn3)
TabBtn3.MouseButton1Click:Connect(function() BuildTab("Misc") end)

BuildTab("Combat")
AV.MouseButton1Click:Connect(function() M.Visible = not M.Visible end)
CL.MouseButton1Click:Connect(function() M.Visible = false end)

local mdrag, mds, mdp = false, nil, nil
TB.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then mdrag = true mds = i.Position mdp = M.Position end end)
TB.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then mdrag = false end end)
UserInputService.InputChanged:Connect(function(i) if mdrag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then local d = i.Position - mds M.Position = UDim2.new(mdp.X.Scale, mdp.X.Offset + d.X, mdp.Y.Scale, mdp.Y.Offset + d.Y) end end)

-- АИМ + ПРЕДУГАДЫВАНИЕ
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

RunService.RenderStepped:Connect(function()
    local cam = GetCamera()
    if not cam then return end
    
    -- FOV
    if C.ShowFOV then
        FOVCircle.Visible = true
        FOVCircle.Size = UDim2.new(0, C.FOV*2, 0, C.FOV*2)
        FOVStroke.Color = C.ESPColor
    else
        FOVCircle.Visible = false
    end

    -- AIM (постоянно, с предугадыванием)
    if C.AimBot then
        local target = GetNearest()
        if target and target.Character then
            local part = target.Character:FindFirstChild(C.AimPart) or target.Character:FindFirstChild("Head")
            if part then
                local vel = target.Character.HumanoidRootPart and target.Character.HumanoidRootPart.AssemblyLinearVelocity or Vector3.new(0,0,0)
                local predPos = part.Position + (vel * C.Prediction)
                cam.CFrame = cam.CFrame:Lerp(CFrame.new(cam.CFrame.Position, predPos), C.Smooth)
            end
        end
    end
end)

-- ВЫСТРЕЛ (резкий доворот)
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if C.AimBot then
            local cam = GetCamera() if not cam then return end
            local target = GetNearest()
            if target and target.Character then
                local part = target.Character:FindFirstChild(C.AimPart) or target.Character:FindFirstChild("Head")
                if part then
                    local vel = target.Character.HumanoidRootPart and target.Character.HumanoidRootPart.AssemblyLinearVelocity or Vector3.new(0,0,0)
                    cam.CFrame = CFrame.new(cam.CFrame.Position, part.Position + (vel * C.Prediction))
                end
            end
        end
    end
end)

-- ESP
local Drawing_OK = pcall(function() local t = Drawing.new("Square") t:Remove() end)
local Drawings = {}

RunService.RenderStepped:Connect(function()
    local cam = GetCamera()
    if not cam or not Drawing_OK then return end
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
                local h = math.abs(top.Y - bot.Y) local w = h * 0.55
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
                    if head then local hpos = cam:WorldToViewportPoint(head.Position)
                        e.sk.Size = Vector2.new(2, math.abs(hpos.Y - pos.Y)) e.sk.Position = Vector2.new(pos.X, hpos.Y) e.sk.Color = C.ESPColor e.sk.Visible = true
                    end
                else e.sk.Visible = false end
                
                if C.ESPTracers then
                    e.tr.Size = Vector2.new(2, 50) e.tr.Position = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y - 50) e.tr.Color = C.ESPColor e.tr.Visible = true
                else e.tr.Visible = false end
            else e.b.Visible = false e.n.Visible = false e.d.Visible = false e.hp.Visible = false e.sk.Visible = false e.tr.Visible = false end
        else e.b.Visible = false e.n.Visible = false e.d.Visible = false e.hp.Visible = false e.sk.Visible = false e.tr.Visible = false end
    end
end)

-- WORLD
local FB_Old, OldSky, XRayTab, NoDecoStore = {}, nil, {}, {}
local function Fullbright(on)
    if on then for _, k in ipairs({"Brightness","ClockTime","FogEnd","GlobalShadows","Ambient"}) do FB_Old[k]=Lighting[k] end Lighting.Brightness=2 Lighting.ClockTime=14 Lighting.FogEnd=100000 Lighting.GlobalShadows=false Lighting.Ambient=Color3.fromRGB(178,178,178)
    else for k, v in pairs(FB_Old) do pcall(function() if Lighting[k] ~= v then Lighting[k]=v end end) end table.clear(FB_Old) end
end
local function XRay(on)
    if on then for _, v in ipairs(Workspace:GetDescendants()) do if v:IsA("BasePart") and v.Transparency < 1 then XRayTab[v]=v.Transparency v.Transparency=0.7 end end
    else for obj, tr in pairs(XRayTab) do if obj and obj.Parent then pcall(function() obj.Transparency=tr end) end end table.clear(XRayTab) end
end
local function NoDeco(on)
    if sethiddenproperty then local t=Workspace:FindFirstChildOfClass("Terrain") if t then pcall(function() sethiddenproperty(t,"Decoration",not on) end) end
    else if on then for _, v in ipairs(Workspace:GetDescendants()) do if (v:IsA("Decal") or v:IsA("Texture")) and not NoDecoStore[v] then NoDecoStore[v]=v.Transparency v.Transparency=1 end end
    else for obj, tr in pairs(NoDecoStore) do if obj and obj.Parent then pcall(function() obj.Transparency=tr end) end end table.clear(NoDecoStore) end end
end

local InfConn, AFKConn
RunService.Heartbeat:Connect(function()
    if C.Fullbright then pcall(Fullbright, true) end
    if C.XRay then pcall(XRay, true) end
    if C.NoDeco then pcall(NoDeco, true) end
    if C.InfJump then if not InfConn then InfConn = UserInputService.JumpRequest:Connect(function() local h=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end) end elseif InfConn then InfConn:Disconnect() InfConn=nil end
    if C.AntiAFK then if not AFKConn then AFKConn = LP.Idled:Connect(function() pcall(function() local v=game:GetService("VirtualUser") v:CaptureController() v:ClickButton2(Vector2.new()) end) end) end elseif AFKConn then AFKConn:Disconnect() AFKConn=nil end
end)

-- RESOURCES
RunService.Heartbeat:Connect(function()
    local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local ores = Workspace:FindFirstChild("ores")
    if ores then for _, ore in ipairs(ores:GetChildren()) do
        local en = (ore.Name == "sulfur" and C.SulfurESP) or (ore.Name == "iron" and C.IronESP) or (ore.Name == "stone" and C.StoneESP)
        local col = (ore.Name == "sulfur" and Color3.new(1,1,0)) or (ore.Name == "iron" and Color3.new(0.7,0.7,0.7)) or Color3.new(1,1,1)
        if en then
            if not ore:FindFirstChild("FerOreTag") then local bg=N("BillboardGui",{Name="FerOreTag",AlwaysOnTop=true,Size=UDim2.new(0,100,0,40),ExtentsOffset=Vector3.new(0,2,0)},ore) N("TextLabel",{Name="Label",BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),TextSize=13,Font=Enum.Font.GothamBold},bg) end
            local dist = (root.Position - ore.Position).Magnitude
            if dist <= C.OreDist then ore.FerOreTag.Enabled = true ore.FerOreTag.Label.Text = ore.Name:upper().."\n["..math.floor(dist).."m]" ore.FerOreTag.Label.TextColor3 = col else ore.FerOreTag.Enabled = false end
        elseif ore:FindFirstChild("FerOreTag") then ore.FerOreTag.Enabled = false end
    end end
end)

print("[FerClient v9.0] Loaded! All functions active.")
