--[[ FerClient v13.1 | EXACT Vomagla Aim + Fall Damage Bypass ]]
--[[ Скопировано 1 в 1 с Watermelon (Vomagla) ]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local Stats = game:GetService("Stats")
local LP = Players.LocalPlayer

local isMobile = UserInputService.TouchEnabled

-- КАСТОМНЫЕ ОБЁРТКИ ВОМАГЛЫ (ЧТОБЫ DELTA НЕ БЛОКИРОВАЛА ХУКИ)
if not newcclosure then getgenv().newcclosure = function(f) return f end end
if not checkcaller then getgenv().checkcaller = function() return false end end
if not hookmetamethod then getgenv().hookmetamethod = function() end end
if not getnamecallmethod then getgenv().getnamecallmethod = function() return "" end end

local function GetCamera() local cam = workspace.CurrentCamera; if cam and cam.Parent then return cam end; return nil end

-- ============ СОСТОЯНИЕ ============
local C = {
    SilentAim=false, AimPart="HumanoidRootPart", FOV=150, TeamCheck=false, 
    AutoShoot=false, AutoShootDelay=0.05,
    NoFallDamage=false,
    ESP=false, ESPBox=true, ESPName=true, ESPDist=true, ESPSkeleton=false, ESPHP=false, ESPHPNum=false, ESPTracers=false, ESPHead=false, ESPMaxDist=1000,
    ESPColor=Color3.fromRGB(0,200,255), ShowFOV=false,
    Fullbright=false, XRay=false, NoDeco=false,
    InfJump=false, AntiAFK=false,
    ThirdPerson=false, ThirdPersonDist=15,
    SulfurESP=false, IronESP=false, StoneESP=false, OreDist=500,
    CrateESP=false, MilitaryESP=false, EliteESP=false, FoodESP=false, CrateDist=500,
    NpcESP=false, NpcDist=600,
    OptLowGFX=false, OptNoEffects=false, OptNoParticles=false, OptNoDecals=false, OptNoShadows=false, OptFarParts=false, OptLowTerrain=false, OptNoSounds=false, OptRenderDist=1500,
    NoBulletDrop=false
}
_G.FerBinds = {}
local CurrentAimTarget = nil

local PlayerCache = {}
local function CachePlayer(pl)
    if pl ~= LP then 
        PlayerCache[pl] = {Char=pl.Character, HRP=pl.Character and pl.Character:FindFirstChild("HumanoidRootPart")}
        pl.CharacterAdded:Connect(function(char) task.wait(1) PlayerCache[pl] = {Char=char, HRP=char:FindFirstChild("HumanoidRootPart")} end)
    end
end
for _, pl in ipairs(Players:GetPlayers()) do CachePlayer(pl) end
Players.PlayerAdded:Connect(CachePlayer)
Players.PlayerRemoving:Connect(function(pl) PlayerCache[pl] = nil end)

-- ============ UI HELPERS ============
local function N(class, props, parent)
    local o = Instance.new(class); for k, v in pairs(props or {}) do pcall(function() o[k] = v end) end; if parent then o.Parent = parent end; return o
end
local ACC = Color3.fromRGB(0,170,255) local BG = Color3.fromRGB(15,15,20) local PANEL = Color3.fromRGB(22,22,30) local P2 = Color3.fromRGB(30,30,40)
local TXT = Color3.fromRGB(235,235,245) local SUB = Color3.fromRGB(150,150,165) local OFF = Color3.fromRGB(60,60,75)
local function corner(p, r) return N("UICorner", {CornerRadius=UDim.new(0,r or 8)}, p) end
local function stroke(p, c, t, tr) return N("UIStroke", {Color=c or ACC, Thickness=t or 1, Transparency=tr or 0.3, ApplyStrokeMode=Enum.ApplyStrokeMode.Border}, p) end
local function padding(p, px, py) local u=N("UIPadding",{},p); local ux,uy=UDim.new(0,px or 0),UDim.new(0,py or px or 0); u.PaddingLeft=ux; u.PaddingRight=ux; u.PaddingTop=uy; u.PaddingBottom=uy; return u end

local SG = N("ScreenGui", {Name="FerUI", ResetOnSpawn=false, IgnoreGuiInset=true, ZIndexBehavior=Enum.ZIndexBehavior.Sibling}, CoreGui)
local M = N("Frame", {Size=UDim2.new(0,540,0,400), Position=UDim2.new(0.5,-270,0.5,-200), BackgroundColor3=BG, BorderSizePixel=0, Visible=false}, SG)
corner(M,12); stroke(M, ACC, 1)

local TitleBar = N("Frame", {Size=UDim2.new(1,0,0,44), BackgroundColor3=PANEL, BorderSizePixel=0, ZIndex=2}, M)
corner(TitleBar,12)
N("TextLabel", {Text="  FerClient v13.1", Font=Enum.Font.GothamBold, TextSize=15, TextColor3=TXT, BackgroundTransparency=1, Size=UDim2.new(1,-50,1,0), TextXAlignment=Enum.TextXAlignment.Left, ZIndex=3}, TitleBar)
local closeClick = N("TextButton", {Text="X", Font=Enum.Font.GothamBold, TextSize=14, TextColor3=TXT, BackgroundColor3=Color3.fromRGB(220,50,70), Size=UDim2.new(0,26,0,26), Position=UDim2.new(1,-32,0.5,-13), BorderSizePixel=0, ZIndex=3}, TitleBar)
corner(closeClick,6); closeClick.MouseButton1Click:Connect(function() M.Visible = false end)

local Sidebar = N("Frame", {Size=UDim2.new(0,140,1,-60), Position=UDim2.new(0,10,0,50), BackgroundColor3=BG, BorderSizePixel=0, ZIndex=2}, M)
corner(Sidebar,8); N("UIListLayout", {Padding=UDim.new(0,4)}, Sidebar); padding(Sidebar,8,10)

local Container = N("ScrollingFrame", {Position=UDim2.new(0,160,0,50), Size=UDim2.new(1,-170,1,-60), BackgroundColor3=PANEL, BorderSizePixel=0, CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y}, M)
corner(Container,8); N("UIListLayout", {Padding=UDim.new(0,6)}, Container); padding(Container,12)

local Tabs = {AIM={}, VISUALS={}, PLAYER={}, WORLD={}, MISC={}}
local tabButtons = {}
local CurrentTab = "AIM"
local function showTab(name)
    CurrentTab = name
    for t, objs in pairs(Tabs) do for _, o in ipairs(objs) do o.Visible=(t==name) end end
    for k, b in pairs(tabButtons) do b.TextColor3 = (k==name) and ACC or SUB end
end

local function createTabBtn(name, label, order)
    local b = N("TextButton", {Size=UDim2.new(1,0,0,30), BackgroundColor3=P2, Text=label, TextColor3=SUB, Font=Enum.Font.GothamMedium, TextSize=12, AutoButtonColor=false, LayoutOrder=order}, Sidebar)
    corner(b,6); tabButtons[name]=b; b.MouseButton1Click:Connect(function() showTab(name) end)
end

local function createCategory(title, order)
    local l = N("TextLabel", {Size=UDim2.new(1,0,0,20), BackgroundTransparency=1, Text=title, TextColor3=SUB, Font=Enum.Font.GothamBold, TextSize=11, TextXAlignment=Enum.TextXAlignment.Left, LayoutOrder=order}, Container)
    return l
end

local function createToggle(label, prop, order)
    local b = N("TextButton", {Size=UDim2.new(1,0,0,36), BackgroundColor3=P2, Text="", AutoButtonColor=false, LayoutOrder=order}, Container)
    corner(b,6); N("TextLabel", {Size=UDim2.new(1,-50,1,0), Position=UDim2.new(0,12,0,0), BackgroundTransparency=1, Text=label, TextColor3=TXT, Font=Enum.Font.Gotham, TextSize=12, TextXAlignment=Enum.TextXAlignment.Left}, b)
    local sw = N("Frame", {Size=UDim2.new(0,30,0,16), Position=UDim2.new(1,-40,0.5,-8), BackgroundColor3=C[prop] and ACC or OFF}, b)
    corner(sw,8); local kn = N("Frame", {Size=UDim2.new(0,12,0,12), Position=C[prop] and UDim2.new(1,-14,0.5,-6) or UDim2.new(0,2,0.5,-6), BackgroundColor3=Color3.new(1,1,1)}, sw)
    corner(kn,6); b.MouseButton1Click:Connect(function() C[prop] = not C[prop]; sw.BackgroundColor3 = C[prop] and ACC or OFF; kn.Position = C[prop] and UDim2.new(1,-14,0.5,-6) or UDim2.new(0,2,0.5,-6) end)
    return b
end

local function createSlider(label, prop, min, max, order)
    local f = N("Frame", {Size=UDim2.new(1,0,0,44), BackgroundColor3=P2, LayoutOrder=order}, Container)
    corner(f,6); N("TextLabel", {Size=UDim2.new(1,-50,0,18), Position=UDim2.new(0,12,0,6), BackgroundTransparency=1, Text=label, TextColor3=TXT, Font=Enum.Font.Gotham, TextSize=12, TextXAlignment=Enum.TextXAlignment.Left}, f)
    local vl = N("TextLabel", {Size=UDim2.new(0,50,0,18), Position=UDim2.new(1,-60,0,6), BackgroundTransparency=1, Text=tostring(C[prop]), TextColor3=ACC, Font=Enum.Font.GothamBold, TextSize=12, TextXAlignment=Enum.TextXAlignment.Right}, f)
    local bar = N("Frame", {Size=UDim2.new(1,-24,0,4), Position=UDim2.new(0,12,0,28), BackgroundColor3=OFF}, f); corner(bar,2)
    local fill = N("Frame", {Size=UDim2.new((C[prop]-min)/(max-min),0,1,0), BackgroundColor3=ACC}, bar); corner(fill,2)
    local inp = N("TextButton", {Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Text=""}, bar); local drag = false
    inp.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then drag=true end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end end)
    UserInputService.InputChanged:Connect(function(i) if drag and (i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseMovement) then local p=math.clamp((i.Position.X-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1); local v=math.floor(min+(max-min)*p+0.5); C[prop]=v; vl.Text=tostring(v); fill.Size=UDim2.new(p,0,1,0) end end)
    return f
end

local O = 0; local function nextO() O=O+1; return O end
local function addTo(t, o) if o then table.insert(Tabs[t], o); o.Visible=false end end

createTabBtn("AIM","Aimbot",1); createTabBtn("VISUALS","Visuals",2); createTabBtn("PLAYER","Player",3); createTabBtn("WORLD","World",4); createTabBtn("MISC","Misc",5)

addTo("AIM", createCategory("SILENT AIM", nextO()))
addTo("AIM", createToggle("Включить Silent Aim", "SilentAim", nextO()))
addTo("AIM", createToggle("Team Check", "TeamCheck", nextO()))
addTo("AIM", createToggle("AutoShoot", "AutoShoot", nextO()))
addTo("AIM", createSlider("FOV","FOV",20,800,nextO()))
addTo("AIM", createToggle("Show FOV", "ShowFOV", nextO()))

addTo("PLAYER", createCategory("PLAYER", nextO()))
addTo("PLAYER", createToggle("Inf Jump", "InfJump", nextO()))
addTo("PLAYER", createToggle("Anti AFK", "AntiAFK", nextO()))
addTo("PLAYER", createToggle("God Mode (No Fall Dmg)", "NoFallDamage", nextO()))
addTo("PLAYER", createToggle("Third Person", "ThirdPerson", nextO()))
addTo("PLAYER", createSlider("Third Dist","ThirdPersonDist",3,50,nextO()))

addTo("VISUALS", createCategory("PLAYER ESP", nextO()))
addTo("VISUALS", createToggle("ESP", "ESP", nextO()))
addTo("VISUALS", createToggle("Box", "ESPBox", nextO()))
addTo("VISUALS", createToggle("Name", "ESPName", nextO()))
addTo("VISUALS", createToggle("Distance", "ESPDist", nextO()))
addTo("VISUALS", createToggle("Skeleton", "ESPSkeleton", nextO()))
addTo("VISUALS", createToggle("Health Bar", "ESPHP", nextO()))
addTo("VISUALS", createToggle("Tracers", "ESPTracers", nextO()))
addTo("VISUALS", createToggle("Head Circle", "ESPHead", nextO()))
addTo("VISUALS", createSlider("ESP Max Dist","ESPMaxDist",50,5000,nextO()))

addTo("WORLD", createCategory("WORLD", nextO()))
addTo("WORLD", createToggle("Fullbright", "Fullbright", nextO()))
addTo("WORLD", createToggle("No Bullet Drop", "NoBulletDrop", nextO()))
addTo("WORLD", createToggle("Low GFX", "OptLowGFX", nextO()))

-- ============ FOV КРУГ (СМЕЩЁН ВНИЗ КАК У ВОМАГЛЫ) ============
local FOVCircle = N("Frame", {AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.new(0.5, 0, 0.55, 0), BackgroundTransparency=1, Visible=false, ZIndex=10}, SG)
corner(FOVCircle, 500)
local FOVStroke = N("UIStroke", {Thickness=1.5, Color=ACC}, FOVCircle)

-- ============ VOMAGLA SILENT AIM (ТОЧНАЯ КОПИЯ) ============
local v13 = { Enabled = false, TargetPart = "HumanoidRootPart", UseFOV = true, FOVRadius = 150, FOVRadiusSq = 22500, MaxDistance = 500, MaxDistanceSq = 250000 }
local screenCenter = Vector2.new(0,0)
local function getMousePosition()
    local cam = Workspace.CurrentCamera
    if cam then local vp = cam.ViewportSize; screenCenter = Vector2.new(vp.X*0.5, vp.Y*0.5) end
    -- СМЕЩЕНИЕ ВНИЗ (как в вомагле, из-за 3-го лица)
    return Vector2.new(screenCenter.X, screenCenter.Y + 50) 
end

local function getPositionOnScreen(pos)
    local cam = Workspace.CurrentCamera
    if not cam then return Vector2.new(0,0), false end
    local p, v = cam:WorldToViewportPoint(pos)
    return Vector2.new(p.X, p.Y), v
end

local function distSq2D(a, b) local dx, dy = a.X-b.X, a.Y-b.Y; return dx*dx+dy*dy end
local function distSq3D(a, b) local dx,dy,dz = a.X-b.X, a.Y-b.Y, a.Z-b.Z; return dx*dx+dy*dy+dz*dz end

local ignoreFolderNames = {"Viewmodel","ViewModel","Ignore","Debris","BulletTraces","Effects","GunEffects","Arms","FPSArms","Particles","Bullets"}
local wallRayP = RaycastParams.new(); wallRayP.FilterType = Enum.RaycastFilterType.Exclude; wallRayP.IgnoreWater = true

local function isPartVisible(origin, targetPos, targetChar)
    local il = {}
    if LP.Character then il[#il+1] = LP.Character end
    local cam = Workspace.CurrentCamera
    if cam then il[#il+1] = cam end
    for i = 1, #ignoreFolderNames do local f = Workspace:FindFirstChild(ignoreFolderNames[i]); if f then il[#il+1] = f end end
    wallRayP.FilterDescendantsInstances = il
    for _ = 1, 4 do
        local dir = targetPos - origin
        if dir.Magnitude < 0.5 then return true end
        local r = Workspace:Raycast(origin, dir, wallRayP)
        if not r then return true end
        if r.Instance:IsDescendantOf(targetChar) then return true end
        if r.Instance:IsA("BasePart") and r.Instance.Transparency >= 0.9 then il[#il+1] = r.Instance; wallRayP.FilterDescendantsInstances = il; continue end
        local hitO = false
        for plr in pairs(PlayerCache) do if plr.Character and r.Instance:IsDescendantOf(plr.Character) then il[#il+1] = plr.Character; wallRayP.FilterDescendantsInstances = il; hitO = true; break end end
        if hitO then continue end
        return false
    end
    return false
end

local function getClosestPlayer()
    local cam = Workspace.CurrentCamera
    if not cam then return nil end
    local myRoot = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    local myPos = myRoot and myRoot.Position
    local mousePos = getMousePosition()
    local camPos = cam.CFrame.Position
    local best, bestD = nil, nil
    for plr in pairs(PlayerCache) do
        local ch = plr.Character; if not ch then continue end
        local part = ch:FindFirstChild(v13.TargetPart) or ch:FindFirstChild("HumanoidRootPart") or ch:FindFirstChild("Head")
        if not part or not part.Parent then continue end
        local hum = ch:FindFirstChild("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        local pp = part.Position
        if myPos and distSq3D(myPos, pp) > v13.MaxDistanceSq then continue end
        local sp, vis = getPositionOnScreen(pp)
        if not vis then continue end
        local sd = distSq2D(mousePos, sp)
        if v13.UseFOV and sd > v13.FOVRadiusSq then continue end
        local cd = (myPos) and distSq3D(myPos, pp) or sd
        if not bestD or cd < bestD then best = part; bestD = cd end
    end
    return best
end

-- ХУК (КАК В ВОМАГЛЕ)
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if method == "Raycast" and self == Workspace then
        if not checkcaller() then
            local args = {...}
            local origin = args[1]
            local direction = args[2]
            if typeof(origin) == "Vector3" and typeof(direction) == "Vector3" then
                local mag = direction.Magnitude
                if mag > 50 and v13.Enabled and CurrentAimTarget then
                    local newDir = (CurrentAimTarget.Position - origin).Unit * mag
                    return oldNamecall(self, origin, newDir, args[3])
                end
            end
        end
    end
    return oldNamecall(self, ...)
end))

local function doAutoFire()
    if mouse1click then mouse1click() else
        local s, vim = pcall(game.GetService, game, "VirtualInputManager")
        if s and vim then vim:SendMouseButtonEvent(0,0,0,true,game,0); task.defer(function() vim:SendMouseButtonEvent(0,0,0,false,game,0) end) end
    end
end

-- ============ ОПТИМИЗАЦИЯ / ВИЗУАЛ ============
local hasDrawing = pcall(function() local t=Drawing.new("Line") t:Remove() return true end)
local function applyFullbright(on)
    if on then Lighting.Ambient=Color3.new(1,1,1); Lighting.OutdoorAmbient=Color3.new(1,1,1); Lighting.Brightness=2; Lighting.ClockTime=14; Lighting.FogEnd=100000; Lighting.GlobalShadows=false end
end
local function applyOpt()
    if C.OptLowGFX then pcall(function() settings().Rendering.QualityLevel=Enum.QualityLevel.Level01 end); Lighting.GlobalShadows=false end
end

-- ============ ESP ============
local ESP = {}
local function removeESP(p)
    local e = ESP[p]; if not e then return end
    for _,d in pairs(e) do if d and d.Remove then pcall(function() d:Remove() end) end end
    ESP[p] = nil
end
local function createESP(p)
    if p == LP or ESP[p] or not hasDrawing then return end
    local e = {}
    local ok = pcall(function()
        e.box = {Drawing.new("Line"),Drawing.new("Line"),Drawing.new("Line"),Drawing.new("Line")}
        e.name = Drawing.new("Text"); e.dist = Drawing.new("Text")
        e.hpBg = Drawing.new("Line"); e.hpFill = Drawing.new("Line")
        e.tracer = Drawing.new("Line")
    end)
    if not ok then removeESP(p); return end
    for _,l in ipairs(e.box) do l.Thickness=1; l.Color=ACC; l.Visible=false end
    e.name.Size=13; e.name.Center=true; e.name.Outline=true; e.name.Font=2; e.name.Color=TXT
    e.dist.Size=11; e.dist.Center=true; e.dist.Outline=true; e.dist.Font=2; e.dist.Color=SUB
    e.hpBg.Thickness=3; e.hpBg.Visible=false; e.hpFill.Thickness=3; e.hpFill.Visible=false
    e.tracer.Thickness=1; e.tracer.Color=ACC
    ESP[p] = e
end
for _,p in ipairs(Players:GetPlayers()) do createESP(p) end
Players.PlayerAdded:Connect(function(p) task.wait(1); createESP(p) end)
Players.PlayerRemoving:Connect(function(p) removeESP(p) end)

-- ============ ГЛАВНЫЙ ЦИКЛ ============
RunService.RenderStepped:Connect(function()
    local cam = GetCamera(); if not cam then return end
    local now = tick()

    if C.ShowFOV then
        local radius = v13.FOVRadius * 2
        FOVCircle.Visible = true
        FOVCircle.Size = UDim2.new(0, radius, 0, radius)
        FOVStroke.Color = CurrentAimTarget and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0)
    else
        FOVCircle.Visible = false
    end

    v13.Enabled = C.SilentAim
    v13.UseFOV = C.ShowFOV
    v13.FOVRadius = C.FOV
    v13.FOVRadiusSq = C.FOV * C.FOV
    v13.TargetPart = C.AimPart
    
    if C.SilentAim then
        CurrentAimTarget = getClosestPlayer()
        if C.AutoShoot and CurrentAimTarget then
            if now - (lastShoot or 0) > C.AutoShootDelay then
                lastShoot = now
                doAutoFire()
            end
        end
    else
        CurrentAimTarget = nil
    end

    -- ЛОГИКА FALL DAMAGE (ЧЕРЕЗ СТЕЙТ И ЗДОРОВЬЕ)
    if C.NoFallDamage and LP.Character then
        local hum = LP.Character:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health > 0 then
            if hum:GetState() == Enum.HumanoidStateType.Freefall or hum:GetState() == Enum.HumanoidStateType.FallingDown then
                hum.Health = hum.MaxHealth
            end
        end
    end

    -- ESP
    if hasDrawing then
        for pl, e in pairs(ESP) do
            local char = pl.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local draw = false
            if C.ESP and hrp and hum and hum.Health > 0 then
                local ps, on = cam:WorldToViewportPoint(hrp.Position)
                if on and ps.Z <= C.ESPMaxDist then
                    draw = true
                    local sy = 4500/ps.Z; local sx = 2800/ps.Z
                    local x, y = ps.X - sx/2, ps.Y - sy/2
                    for i, l in ipairs(e.box) do
                        l.Visible = C.ESPBox; l.Color = C.ESPColor
                        if i==1 then l.From,l.To = Vector2.new(x,y),Vector2.new(x+sx,y)
                        elseif i==2 then l.From,l.To = Vector2.new(x+sx,y),Vector2.new(x+sx,y+sy)
                        elseif i==3 then l.From,l.To = Vector2.new(x+sx,y+sy),Vector2.new(x,y+sy)
                        else l.From,l.To = Vector2.new(x,y+sy),Vector2.new(x,y) end
                    end
                    local hpR = math.clamp(hum.Health/math.max(hum.MaxHealth,1),0,1)
                    e.hpBg.Visible = C.ESPHP; e.hpFill.Visible = C.ESPHP
                    if C.ESPHP then
                        e.hpBg.From,e.hpBg.To = Vector2.new(x-8,y),Vector2.new(x-8,y+sy)
                        e.hpFill.From,e.hpFill.To = Vector2.new(x-8,y+sy),Vector2.new(x-8,y+sy-sy*hpR)
                        e.hpFill.Color = Color3.fromRGB(255*(1-hpR), 255*hpR, 60)
                    end
                    e.name.Visible = C.ESPName
                    if C.ESPName then e.name.Text = pl.DisplayName; e.name.Position = Vector2.new(ps.X, y-34); e.name.Color = C.ESPColor end
                    e.dist.Visible = C.ESPDist
                    if C.ESPDist then e.dist.Text = "["..math.floor(ps.Z).."m]"; e.dist.Position = Vector2.new(ps.X, y-18) end
                    e.tracer.Visible = C.ESPTracers
                    if C.ESPTracers then e.tracer.From = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y); e.tracer.To = Vector2.new(ps.X, ps.Y); e.tracer.Color = C.ESPColor end
                end
            end
            if not draw then
                for _,l in ipairs(e.box) do l.Visible=false end
                e.name.Visible=false; e.dist.Visible=false; e.hpBg.Visible=false; e.hpFill.Visible=false; e.tracer.Visible=false
            end
        end
    end

    if C.Fullbright then applyFullbright(true) end
    if C.OptLowGFX then applyOpt() end
end)

-- ============ OTHER ============
local InfConn, AFKConn
UserInputService.JumpRequest:Connect(function() if C.InfJump and LP.Character then local h=LP.Character:FindFirstChildOfClass("Humanoid"); if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end end)
task.spawn(function()
    while true do
        task.wait(0.2)
        if C.AntiAFK then pcall(function() local v=game:GetService("VirtualUser"); v:CaptureController(); v:ClickButton2(Vector2.new()) end) end
        if C.ThirdPerson then pcall(function() LP.CameraMaxZoomDistance=C.ThirdPersonDist; LP.CameraMinZoomDistance=C.ThirdPersonDist end) end
    end
end)

workspace.DescendantAdded:Connect(function(obj)
    if C.NoBulletDrop and obj:IsA("BasePart") and (obj.Name:find("Bullet") or obj.Name:find("Projectile")) then
        pcall(function() local bf = Instance.new("BodyForce"); bf.Force = Vector3.new(0, obj:GetMass() * workspace.Gravity, 0); bf.Parent = obj end)
    end
end)

UserInputService.InputBegan:Connect(function(input) if input.KeyCode == Enum.KeyCode.RightShift then M.Visible = not M.Visible end end)
showTab("AIM")
pcall(function() game:GetService("StarterGui"):SetCore("SendNotification", {Title="FerClient v13.1", Text="Exact Vomagla Logic Loaded", Duration=4}) end)
print("[FerClient v13.1] Exact Vomagla Loaded.")
