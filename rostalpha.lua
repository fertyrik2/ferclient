--[[ FerClient v1.1 | Delta Mobile | UI + Visual fixes applied
     Not runtime-tested. Static analysis only. ]]
local P=game:GetService("Players")
local R=game:GetService("RunService")
local U=game:GetService("UserInputService")
local L=game:GetService("Lighting")
local W=game:GetService("Workspace")
local T=game:GetService("TweenService")
local CG=game:GetService("CoreGui")

local LP = P.LocalPlayer
local CAM = W.CurrentCamera

--==================== CONFIG ====================
local C = {
    AimSelect=false, TriggerBot=false, MagicBullet=false, AimBot=false,
    AimPart="Head", Smooth=0.35, FOV=120,
    ESP=false, ESPBox=true, ESPName=true, ESPCharms=true, ESPDist=true,
    ESPColor=Color3.fromRGB(0,200,255),
    Fullbright=false, XRay=false, NoDeco=false, SkyFon=false, FPSBoost=false,
    Speed=false, SpeedVal=25, InfJump=false, AntiAFK=false,
}

--==================== THEME ====================
local ACC   = Color3.fromRGB(0,170,255)
local BG    = Color3.fromRGB(15,15,20)
local PANEL = Color3.fromRGB(22,22,30)
local P2    = Color3.fromRGB(30,30,40)
local TXT   = Color3.fromRGB(235,235,245)
local SUB   = Color3.fromRGB(150,150,165)
local OFF   = Color3.fromRGB(60,60,75)
local STROKE= Color3.fromRGB(45,45,60)

--==================== HELPERS ====================
local function N(class, props, parent)
    local o = Instance.new(class)
    for k, v in pairs(props or {}) do o[k] = v end
    if parent then o.Parent = parent end
    return o
end
local function Round(o, r)
    N("UICorner", { CornerRadius = UDim.new(0, r or 8) }, o)
end
local function Stroke(o, col, th)
    N("UIStroke", { Color = col or STROKE, Thickness = th or 1 }, o)
end

--==================== CLEAN OLD ====================
pcall(function()
    if CG:FindFirstChild("FerUI") then CG.FerUI:Destroy() end
end)

local SG = N("ScreenGui", {
    Name = "FerUI", ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, CG)

--==================== AVATAR ====================
local AV = N("ImageButton", {
    Size = UDim2.new(0,60,0,60),
    Position = UDim2.new(0,20,0.5,-30),
    BackgroundColor3 = BG,
    AutoButtonColor = false,
    BorderSizePixel = 0, ZIndex = 50,
}, SG)
Round(AV, 60); Stroke(AV, ACC, 2)
N("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(120,40,200)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(20,120,255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255,60,160)),
    }), Rotation = 45,
}, AV)
N("TextLabel", {
    Text = "F", Font = Enum.Font.GothamBlack, TextSize = 34,
    TextColor3 = Color3.new(1,1,1), BackgroundTransparency = 1,
    Size = UDim2.new(1,0,1,0), TextStrokeTransparency = 0.4, ZIndex = 51,
}, AV)

--==================== MAIN PANEL ====================
local M = N("Frame", {
    Name = "M",
    Size = UDim2.new(0,320,0,410),
    Position = UDim2.new(0.5,-160,0.5,-205),
    BackgroundColor3 = BG, BorderSizePixel = 0,
    Visible = false, ZIndex = 40,
}, SG)
Round(M, 14); Stroke(M, ACC, 1)

local TB = N("Frame", {
    Size = UDim2.new(1,0,0,44),
    BackgroundColor3 = PANEL,
    BorderSizePixel = 0, ZIndex = 41,
}, M)
Round(TB, 14)
N("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(120,40,200)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(20,120,255)),
    }), Rotation = 30, Transparency = NumberSequence.new(0.55),
}, TB)
N("TextLabel", {
    Text = "  FerClient", Font = Enum.Font.GothamBold, TextSize = 17,
    TextColor3 = TXT, BackgroundTransparency = 1,
    Size = UDim2.new(1,-100,1,0),
    TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 42,
}, TB)
local CL = N("TextButton", {
    Text = "✕", Font = Enum.Font.GothamBold, TextSize = 16,
    TextColor3 = TXT, BackgroundColor3 = Color3.fromRGB(220,50,70),
    Size = UDim2.new(0,28,0,28),
    Position = UDim2.new(1,-34,0.5,-14),
    BorderSizePixel = 0, ZIndex = 43,
}, TB)
Round(CL, 8)

local TBB = N("Frame", {
    Size = UDim2.new(1,0,0,38),
    Position = UDim2.new(0,0,0,44),
    BackgroundColor3 = BG, BorderSizePixel = 0, ZIndex = 41,
}, M)
N("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal,
    Padding = UDim.new(0,6),
    HorizontalAlignment = Enum.HorizontalAlignment.Center,
    VerticalAlignment = Enum.VerticalAlignment.Center,
}, TBB)

local CT = N("ScrollingFrame", {
    Size = UDim2.new(1,-16,1,-90),
    Position = UDim2.new(0,8,0,86),
    BackgroundColor3 = PANEL,
    BorderSizePixel = 0,
    ScrollBarThickness = 4,
    ScrollBarImageColor3 = ACC,
    CanvasSize = UDim2.new(0,0,0,0),
    ZIndex = 41,
}, M)
Round(CT, 10)
local CLL = N("UIListLayout", { Padding = UDim.new(0,6) }, CT)
N("UIPadding", {
    PaddingTop = UDim.new(0,8), PaddingLeft = UDim.new(0,8),
    PaddingRight = UDim.new(0,8), PaddingBottom = UDim.new(0,8),
}, CT)

--==================== COMPONENTS ====================
local function Label(text)
    N("TextLabel", {
        Text = text, Font = Enum.Font.GothamBold, TextSize = 12,
        TextColor3 = SUB, BackgroundTransparency = 1,
        Size = UDim2.new(1,0,0,22),
        TextXAlignment = Enum.TextXAlignment.Left,
    }, CT)
end

local function Toggle(text, def, cb)
    local row = N("Frame", {
        Size = UDim2.new(1,0,0,34),
        BackgroundColor3 = P2, BorderSizePixel = 0,
    }, CT)
    Round(row, 8)
    N("TextLabel", {
        Text = "  "..text, Font = Enum.Font.Gotham, TextSize = 13,
        TextColor3 = TXT, BackgroundTransparency = 1,
        Size = UDim2.new(1,-60,1,0),
        TextXAlignment = Enum.TextXAlignment.Left,
    }, row)
    local sw = N("Frame", {
        Size = UDim2.new(0,38,0,20),
        Position = UDim2.new(1,-46,0.5,-10),
        BackgroundColor3 = def and ACC or OFF,
        BorderSizePixel = 0,
    }, row)
    Round(sw, 10)
    local kn = N("Frame", {
        Size = UDim2.new(0,16,0,16),
        Position = def and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,2,0.5,-8),
        BackgroundColor3 = Color3.new(1,1,1), BorderSizePixel = 0,
    }, sw)
    Round(kn, 8)
    local st = def
    local btn = N("TextButton", {
        Text = "", BackgroundTransparency = 1,
        Size = UDim2.new(1,0,1,0), ZIndex = 5,
    }, row)
    btn.MouseButton1Click:Connect(function()
        st = not st
        sw.BackgroundColor3 = st and ACC or OFF
        T:Create(kn, TweenInfo.new(0.15), {
            Position = st and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,2,0.5,-8),
        }):Play()
        if cb then cb(st) end
    end)
end

local function Slider(text, mn, mx, def, cb)
    local row = N("Frame", {
        Size = UDim2.new(1,0,0,52),
        BackgroundColor3 = P2, BorderSizePixel = 0,
    }, CT)
    Round(row, 8)
    N("TextLabel", {
        Text = "  "..text, Font = Enum.Font.Gotham, TextSize = 13,
        TextColor3 = TXT, BackgroundTransparency = 1,
        Size = UDim2.new(1,-60,0,24),
        TextXAlignment = Enum.TextXAlignment.Left,
    }, row)
    local vl = N("TextLabel", {
        Text = tostring(def), Font = Enum.Font.GothamBold, TextSize = 13,
        TextColor3 = ACC, BackgroundTransparency = 1,
        Size = UDim2.new(0,50,0,24),
        Position = UDim2.new(1,-55,0,0),
        TextXAlignment = Enum.TextXAlignment.Right,
    }, row)
    local tr = N("Frame", {
        Size = UDim2.new(1,-20,0,4),
        Position = UDim2.new(0,10,0,34),
        BackgroundColor3 = OFF, BorderSizePixel = 0,
    }, row)
    Round(tr, 2)
    local fl = N("Frame", {
        Size = UDim2.new((def-mn)/(mx-mn),0,1,0),
        BackgroundColor3 = ACC, BorderSizePixel = 0,
    }, tr)
    Round(fl, 2)
    local kn = N("Frame", {
        Size = UDim2.new(0,12,0,12),
        Position = UDim2.new((def-mn)/(mx-mn),-6,0.5,-6),
        BackgroundColor3 = Color3.new(1,1,1),
        BorderSizePixel = 0, ZIndex = 3,
    }, tr)
    Round(kn, 6)
    local dragging = false
    local inp = N("TextButton", {
        Text = "", BackgroundTransparency = 1,
        Size = UDim2.new(1,0,1,0), ZIndex = 4,
    }, row)
    local function setFromX(x)
        local r = math.clamp((x - tr.AbsolutePosition.X) / tr.AbsoluteSize.X, 0, 1)
        local v = math.floor(mn + (mx - mn) * r + 0.5)
        vl.Text = tostring(v)
        fl.Size = UDim2.new(r, 0, 1, 0)
        kn.Position = UDim2.new(r, -6, 0.5, -6)
        if cb then cb(v) end
    end
    inp.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            setFromX(i.Position.X)
        end
    end)
    inp.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    U.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement
        or i.UserInputType == Enum.UserInputType.Touch) then
            setFromX(i.Position.X)
        end
    end)
end

local function Dropdown(text, opts, def, cb)
    local row = N("Frame", {
        Size = UDim2.new(1,0,0,34),
        BackgroundColor3 = P2, BorderSizePixel = 0,
    }, CT)
    Round(row, 8)
    N("TextLabel", {
        Text = "  "..text, Font = Enum.Font.Gotham, TextSize = 13,
        TextColor3 = TXT, BackgroundTransparency = 1,
        Size = UDim2.new(0.5,0,1,0),
        TextXAlignment = Enum.TextXAlignment.Left,
    }, row)
    local btn = N("TextButton", {
        Text = def.." ▼", Font = Enum.Font.Gotham, TextSize = 12,
        TextColor3 = ACC, BackgroundTransparency = 1,
        Size = UDim2.new(0,110,1,0),
        Position = UDim2.new(1,-110,0,0),
    }, row)
    local listH = #opts * 26
    local lst = N("Frame", {
        Size = UDim2.new(1,0,0,listH),
        Position = UDim2.new(0,0,1,2),
        BackgroundColor3 = PANEL, BorderSizePixel = 0,
        Visible = false, ZIndex = 60,
    }, row)
    Round(lst, 6); Stroke(lst, ACC, 1)
    N("UIListLayout", { Padding = UDim.new(0,2) }, lst)
    N("UIPadding", {
        PaddingTop = UDim.new(0,4), PaddingLeft = UDim.new(0,4),
        PaddingRight = UDim.new(0,4), PaddingBottom = UDim.new(0,4),
    }, lst)
    for _, o in ipairs(opts) do
        local ob = N("TextButton", {
            Text = o, Font = Enum.Font.Gotham, TextSize = 12,
            TextColor3 = TXT, BackgroundColor3 = P2,
            Size = UDim2.new(1,0,0,24),
            BorderSizePixel = 0, ZIndex = 61,
        }, lst)
        Round(ob, 4)
        ob.MouseButton1Click:Connect(function()
            btn.Text = o.." ▼"
            lst.Visible = false
            if cb then cb(o) end
        end)
    end
    btn.MouseButton1Click:Connect(function()
        lst.Visible = not lst.Visible
    end)
end

--==================== ESP STATE ====================
local ESP = {}

local function destroyESPEntry(e)
    if not e then return end
    for _, d in pairs(e) do
        if d and d.Remove then
            pcall(function() d:Remove() end)
        end
    end
end

P.PlayerRemoving:Connect(function(pl)
    if ESP[pl] then
        destroyESPEntry(ESP[pl])
        ESP[pl] = nil
    end
end)

--==================== TARGET ====================
local function Nearest()
    local best, dist = nil, C.FOV
    local cen = Vector2.new(CAM.ViewportSize.X/2, CAM.ViewportSize.Y/2)
    for _, pl in ipairs(P:GetPlayers()) do
        if pl ~= LP and pl.Character then
            local hrp = pl.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local sp, on = CAM:WorldToViewportPoint(hrp.Position)
                if on then
                    local d = (Vector2.new(sp.X, sp.Y) - cen).Magnitude
                    if d < dist then dist = d; best = pl end
                end
            end
        end
    end
    return best
end

--==================== VISUAL STATE ====================
local OldLB, OldSky, XRayTab, DecoConn, FPSOff, WasFB = {}, nil, {}, nil, {}, false
local NoDecoStore = {}

local function Fullbright(on)
    if on then
        WasFB = true
        for _, k in ipairs({"Brightness","ClockTime","Ambient","OutdoorAmbient","FogEnd","GlobalShadows"}) do
            OldLB[k] = L[k]
        end
        L.Brightness = 3
        L.ClockTime = 12
        L.Ambient = Color3.fromRGB(200,200,200)
        L.OutdoorAmbient = Color3.fromRGB(200,200,200)
        L.FogEnd = 1e5
        L.GlobalShadows = false
    elseif WasFB then
        for k, v in pairs(OldLB) do
            pcall(function() L[k] = v end)
        end
        WasFB = false
    end
end

local function XRay(on)
    if on then
        XRayTab = {}
        for _, v in ipairs(W:GetDescendants()) do
            if v:IsA("BasePart") and v.Transparency < 1 then
                table.insert(XRayTab, { o = v, t = v.Transparency })
                v.Transparency = 0.7
            end
        end
    else
        for _, e in ipairs(XRayTab) do
            if e.o and e.o.Parent then
                pcall(function() e.o.Transparency = e.t end)
            end
        end
        XRayTab = {}
    end
end

local function NoDeco(on)
    if on then
        if DecoConn then DecoConn:Disconnect() end
        NoDecoStore = {}
        local function hide(o)
            if (o:IsA("Decal") or o:IsA("Texture")) and not NoDecoStore[o] then
                NoDecoStore[o] = o.Transparency
                o.Transparency = 1
            end
        end
        for _, v in ipairs(W:GetDescendants()) do hide(v) end
        DecoConn = W.DescendantAdded:Connect(hide)
    else
        if DecoConn then DecoConn:Disconnect(); DecoConn = nil end
        for obj, tr in pairs(NoDecoStore) do
            if obj and obj.Parent then
                pcall(function() obj.Transparency = tr end)
            end
        end
        NoDecoStore = {}
    end
end

local function SkyFon(on)
    if on then
        OldSky = L:FindFirstChildOfClass("Sky")
        if OldSky then OldSky.Parent = nil end
        local f = N("Folder", { Name = "FerSky" }, L)
        N("Sky", {
            SkyboxBk="rbxassetid://159454299", SkyboxDn="rbxassetid://159454296",
            SkyboxFt="rbxassetid://159454293", SkyboxLf="rbxassetid://159454286",
            SkyboxRt="rbxassetid://159454300", SkyboxUp="rbxassetid://159454288",
            StarCount = 5000,
        }, f)
    else
        local f = L:FindFirstChild("FerSky")
        if f then f:Destroy() end
        if OldSky then OldSky.Parent = L end
    end
end

local function FPS(on)
    if on then
        FPSOff = {}
        for _, v in ipairs(L:GetChildren()) do
            if v:IsA("PostEffect") or v:IsA("Atmosphere") or v:IsA("Clouds") then
                table.insert(FPSOff, { o = v, e = v.Enabled })
                pcall(function() v.Enabled = false end)
            end
        end
        pcall(function()
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        end)
    else
        for _, e in ipairs(FPSOff) do
            pcall(function() e.o.Enabled = e.e end)
        end
        FPSOff = {}
        pcall(function()
            settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
        end)
    end
end

--==================== MISC STATE ====================
local InfConn, AFKConn

local function Speed(on, v)
    local h = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if h then h.WalkSpeed = on and v or 16 end
end

local function InfJump(on)
    if on then
        if InfConn then InfConn:Disconnect() end
        InfConn = U.JumpRequest:Connect(function()
            local h = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
            if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
        end)
    else
        if InfConn then InfConn:Disconnect(); InfConn = nil end
    end
end

local function AFK(on)
    if on then
        if AFKConn then AFKConn:Disconnect() end
        AFKConn = LP.Idled:Connect(function()
            pcall(function()
                local v = game:GetService("VirtualUser")
                v:CaptureController()
                v:ClickButton2(Vector2.new())
            end)
        end)
    else
        if AFKConn then AFKConn:Disconnect(); AFKConn = nil end
    end
end

--==================== MAIN RENDER LOOP ====================
R.RenderStepped:Connect(function()
    -- Aim
    if C.AimBot or C.AimSelect then
        local t = Nearest()
        if t and t.Character then
            local pt = t.Character:FindFirstChild(C.AimPart) or t.Character:FindFirstChild("Head")
            if pt then
                CAM.CFrame = CAM.CFrame:Lerp(
                    CFrame.new(CAM.CFrame.Position, pt.Position), C.Smooth)
            end
        end
    end
    -- Trigger
    if C.TriggerBot then
        local t = Nearest()
        if t and t.Character and t.Character:FindFirstChildOfClass("Humanoid")
        and t.Character.Humanoid.Health > 0 then
            local tl = LP.Character and LP.Character:FindFirstChildWhichIsA("Tool")
            if tl then pcall(function() tl:Activate() end) end
        end
    end
    -- ESP
    for _, pl in ipairs(P:GetPlayers()) do
        if pl ~= LP then
            if not ESP[pl] then
                ESP[pl] = {
                    b = Drawing.new("Square"),
                    n = Drawing.new("Text"),
                    d = Drawing.new("Text"),
                    c = Drawing.new("Triangle"),
                }
                ESP[pl].b.Thickness = 1
                ESP[pl].b.Filled = false
                ESP[pl].n.Size = 14
                ESP[pl].n.Center = true
                ESP[pl].n.Outline = true
                ESP[pl].n.Color = Color3.new(1,1,1)
                ESP[pl].d.Size = 12
                ESP[pl].d.Center = true
                ESP[pl].d.Outline = true
                ESP[pl].d.Color = C.ESPColor
                ESP[pl].c.Thickness = 1
                ESP[pl].c.Filled = true
            end
            local e = ESP[pl]
            local char = pl.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if C.ESP and hrp and hum and hum.Health > 0 then
                local top = CAM:WorldToViewportPoint(hrp.Position + Vector3.new(0,3,0))
                local bot = CAM:WorldToViewportPoint(hrp.Position - Vector3.new(0,3,0))
                local pos, on = CAM:WorldToViewportPoint(hrp.Position)
                if on then
                    local h = math.abs(top.Y - bot.Y)
                    local w = h * 0.55
                    e.b.Size = Vector2.new(w, h)
                    e.b.Position = Vector2.new(pos.X - w/2, top.Y)
                    e.b.Color = C.ESPColor
                    e.b.Visible = C.ESPBox

                    e.n.Text = pl.Name
                    e.n.Position = Vector2.new(pos.X, top.Y - 18)
                    e.n.Visible = C.ESPName

                    local LPH = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                    local dist = LPH and math.floor((LPH.Position - hrp.Position).Magnitude) or 0
                    e.d.Text = "["..dist.."m]"
                    e.d.Position = Vector2.new(pos.X, bot.Y + 2)
                    e.d.Visible = C.ESPDist

                    if C.ESPCharms then
                        local cx = pos.X
                        local cy = top.Y - 30
                        e.c.PointA = Vector2.new(cx, cy)
                        e.c.PointB = Vector2.new(cx - 6, cy + 10)
                        e.c.PointC = Vector2.new(cx + 6, cy + 10)
                        e.c.Color = C.ESPColor
                        e.c.Visible = true
                    else
                        e.c.Visible = false
                    end
                else
                    e.b.Visible = false
                    e.n.Visible = false
                    e.d.Visible = false
                    e.c.Visible = false
                end
            else
                e.b.Visible = false
                e.n.Visible = false
                e.d.Visible = false
                e.c.Visible = false
            end
        end
    end
end)

--==================== TABS ====================
local TabBtns, Tabs = {}, {}

local function ClearC()
    for _, x in ipairs(CT:GetChildren()) do
        if x:IsA("GuiObject") then x:Destroy() end
    end
end

local function Render(name)
    ClearC()
    for k, b in pairs(TabBtns) do
        b.BackgroundColor3 = (k == name) and ACC or P2
        b.TextColor3 = (k == name) and Color3.new(1,1,1) or SUB
    end
    if Tabs[name] then Tabs[name]() end
    CT.CanvasSize = UDim2.new(0, 0, 0, CLL.AbsoluteContentSize.Y + 16)
end

local function AddTab(name)
    local b = N("TextButton", {
        Text = name, Font = Enum.Font.GothamSemibold, TextSize = 13,
        TextColor3 = SUB, BackgroundColor3 = P2,
        Size = UDim2.new(0,92,0,28),
        BorderSizePixel = 0, AutoButtonColor = false,
    }, TBB)
    Round(b, 8)
    TabBtns[name] = b
    b.MouseButton1Click:Connect(function() Render(name) end)
end

AddTab("Combat"); AddTab("Visual"); AddTab("Misc")

Tabs.Combat = function()
    Label("COMBAT")
    Toggle("Aim Select", C.AimSelect, function(v) C.AimSelect = v end)
    Toggle("Trigger Bot", C.TriggerBot, function(v) C.TriggerBot = v end)
    Toggle("Magic Bullet", C.MagicBullet, function(v) C.MagicBullet = v end)
    Toggle("Aim Bot", C.AimBot, function(v) C.AimBot = v end)
    Dropdown("Aim Part", {"Head","HumanoidRootPart","UpperTorso"}, "Head", function(v)
        C.AimPart = v
    end)
    Slider("Aim Smooth", 1, 100, 35, function(v) C.Smooth = v/100 end)
    Slider("FOV", 30, 400, 120, function(v) C.FOV = v end)
end

Tabs.Visual = function()
    Label("VISUAL")
    Toggle("ESP", C.ESP, function(v) C.ESP = v end)
    Toggle("  Box", C.ESPBox, function(v) C.ESPBox = v end)
    Toggle("  Name", C.ESPName, function(v) C.ESPName = v end)
    Toggle("  Charms", C.ESPCharms, function(v) C.ESPCharms = v end)
    Toggle("  Distance", C.ESPDist, function(v) C.ESPDist = v end)
    Toggle("Fullbright", C.Fullbright, function(v) C.Fullbright = v; Fullbright(v) end)
    Toggle("X-Ray", C.XRay, function(v) C.XRay = v; XRay(v) end)
    Toggle("No Decoration", C.NoDeco, function(v) C.NoDeco = v; NoDeco(v) end)
    Toggle("Sky Fon", C.SkyFon, function(v) C.SkyFon = v; SkyFon(v) end)
    Toggle("FPS Boost", C.FPSBoost, function(v) C.FPSBoost = v; FPS(v) end)
end

Tabs.Misc = function()
    Label("MISC")
    Toggle("Legit Speed", C.Speed, function(v) C.Speed = v; Speed(v, C.SpeedVal) end)
    Slider("Speed", 10, 50, 25, function(v)
        C.SpeedVal = v
        if C.Speed then Speed(true, v) end
    end)
    Toggle("Inf Jump", C.InfJump, function(v) C.InfJump = v; InfJump(v) end)
    Toggle("Anti AFK", C.AntiAFK, function(v) C.AntiAFK = v; AFK(v) end)
end

Render("Combat")

--==================== OPEN / DRAG ====================
CL.MouseButton1Click:Connect(function() M.Visible = false end)
AV.MouseButton1Click:Connect(function() M.Visible = not M.Visible end)

local drag, ds, dp = false, nil, nil
AV.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1
    or i.UserInputType == Enum.UserInputType.Touch then
        drag = true; ds = i.Position; dp = AV.Position
    end
end)
AV.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1
    or i.UserInputType == Enum.UserInputType.Touch then
        drag = false
    end
end)
U.InputChanged:Connect(function(i)
    if drag and (i.UserInputType == Enum.UserInputType.MouseMovement
    or i.UserInputType == Enum.UserInputType.Touch) then
        local d = i.Position - ds
        AV.Position = UDim2.new(dp.X.Scale, dp.X.Offset + d.X, dp.Y.Scale, dp.Y.Offset + d.Y)
    end
end)

local mdrag, mds, mdp = false, nil, nil
TB.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1
    or i.UserInputType == Enum.UserInputType.Touch then
        mdrag = true; mds = i.Position; mdp = M.Position
    end
end)
TB.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1
    or i.UserInputType == Enum.UserInputType.Touch then
        mdrag = false
    end
end)
U.InputChanged:Connect(function(i)
    if mdrag and (i.UserInputType == Enum.UserInputType.MouseMovement
    or i.UserInputType == Enum.UserInputType.Touch) then
        local d = i.Position - mds
        M.Position = UDim2.new(mdp.X.Scale, mdp.X.Offset + d.X, mdp.Y.Scale, mdp.Y.Offset + d.Y)
    end
end)

--==================== CLEANUP ====================
local function Cleanup()
    for pl, e in pairs(ESP) do
        destroyESPEntry(e)
        ESP[pl] = nil
    end
    if InfConn then InfConn:Disconnect(); InfConn = nil end
    if AFKConn then AFKConn:Disconnect(); AFKConn = nil end
    if DecoConn then DecoConn:Disconnect(); DecoConn = nil end
    pcall(function() Fullbright(false) end)
    pcall(function() XRay(false) end)
    pcall(function() NoDeco(false) end)
    pcall(function() SkyFon(false) end)
    pcall(function() FPS(false) end)
    pcall(function() Speed(false) end)
end

game:BindToClose(Cleanup)
