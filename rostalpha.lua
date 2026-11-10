--[[ FerClient v24.0 | Fixed Raycast, Cache, FallDamage, HeadExpander ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local LP = Players.LocalPlayer

local isMobile = UserInputService.TouchEnabled
local function GetCamera() local cam = workspace.CurrentCamera; if cam and cam.Parent then return cam end; return nil end

-- ОБЕРТКИ
if not newcclosure then getgenv().newcclosure = function(f) return f end end
if not checkcaller then getgenv().checkcaller = function() return false end end
if not hookmetamethod then getgenv().hookmetamethod = function() end end
if not getnamecallmethod then getgenv().getnamecallmethod = function() return "" end end

-- ЦВЕТА
local Colors = {
    Accent = Color3.fromRGB(150, 110, 255), Background = Color3.fromRGB(12, 12, 16), Sidebar = Color3.fromRGB(18, 18, 24),
    Panel = Color3.fromRGB(22, 22, 30), Card = Color3.fromRGB(28, 28, 38), CardHover = Color3.fromRGB(38, 38, 50),
    Text = Color3.fromRGB(240, 240, 248), TextDim = Color3.fromRGB(150, 150, 165), Border = Color3.fromRGB(38, 38, 50), BorderLight = Color3.fromRGB(50, 50, 66)
}

-- СОСТОЯНИЕ
local C = {
    SilentAim=false, AimPart="Head", FOV=150, TeamCheck=false, WallCheck=false, AutoShoot=false, AutoShootDelay=0.05,
    ESP=false, ESPBox=true, ESPName=true, ESPDist=true, ESPSkeleton=false, ESPHP=false, ESPHPNum=false, ESPTracers=false, ESPHead=false, ESPMaxDist=1000,
    ESPColor=Color3.fromRGB(0,200,255), ShowFOV=false, Fullbright=false, XRay=false, NoDeco=false,
    SulfurESP=false, IronESP=false, StoneESP=false, OreDist=500, CrateESP=false, MilitaryESP=false, EliteESP=false, FoodESP=false, CrateDist=500, NpcESP=false, NpcDist=600,
    NoFallDamage=false, InfJump=false, AntiAFK=false, ThirdPerson=false, ThirdPersonDist=15, SilentWalk=false, HeadExpander=false, HitboxSize=5,
    NoBulletDrop=false, OptLowGFX=false, AdminList=false,
    Hitmarker=false, HitSound=false, ReloadIndicator=false, KillSound=false
}
_G.FerBinds = {}
local CurrentAimTarget = nil

-- ============ FIX 1: PlayerCache (БЕЗ task.wait) ============
local PlayerCache = {}
local function UpdatePlayerCache(pl)
    if pl == LP then return end
    local char = pl.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    PlayerCache[pl] = {Char=char, Hum=hum, HRP=hrp}
end
local function RegisterPlayer(pl)
    if pl == LP then return end
    UpdatePlayerCache(pl)
    pl.CharacterAdded:Connect(function() UpdatePlayerCache(pl) end)
    pl.CharacterRemoving:Connect(function() PlayerCache[pl] = nil end)
end
for _, pl in ipairs(Players:GetPlayers()) do RegisterPlayer(pl) end
Players.PlayerAdded:Connect(RegisterPlayer)
Players.PlayerRemoving:Connect(function(pl) PlayerCache[pl] = nil end)

-- UI HELPERS
local function N(class, props, parent)
    local o = Instance.new(class); for k, v in pairs(props or {}) do pcall(function() o[k] = v end) end; if parent then o.Parent = parent end; return o
end
local function corner(p, r) return N("UICorner", {CornerRadius=UDim.new(0,r or 8)}, p) end
local function stroke(p, c, t, tr) return N("UIStroke", {Color=c or Colors.Border, Thickness=t or 1, Transparency=tr or 0.3, ApplyStrokeMode=Enum.ApplyStrokeMode.Border}, p) end
local function padding(p, px, py) local u=N("UIPadding",{},p); local ux,uy=UDim.new(0,px or 0),UDim.new(0,py or px or 0); u.PaddingLeft=ux; u.PaddingRight=ux; u.PaddingTop=uy; u.PaddingBottom=uy; return u end

-- GUI
local Blur = N("BlurEffect", {Size=0, Enabled=true}, Lighting)
local SG = N("ScreenGui", {Name="FerUI", ResetOnSpawn=false, IgnoreGuiInset=true, ZIndexBehavior=Enum.ZIndexBehavior.Sibling}, CoreGui)
local M = N("Frame", {Size=UDim2.new(0,720,0,500), Position=UDim2.new(0.5,-360,0.5,-250), BackgroundColor3=Colors.Background, BorderSizePixel=0, Visible=false}, SG)
if isMobile then M.Size=UDim2.new(0,540,0,400) M.Position=UDim2.new(0.5,-270,0.5,-200) end
corner(M,14); stroke(M, Colors.BorderLight, 1, 0.3)

local TitleBar = N("Frame", {Size=UDim2.new(1,0,0,44), BackgroundColor3=Colors.Sidebar, BorderSizePixel=0}, M)
corner(TitleBar,14)
N("TextLabel", {Size=UDim2.new(1,-50,1,0), Position=UDim2.new(0,16,0,0), BackgroundTransparency=1, Text="FerClient v24.0", TextColor3=Colors.Text, Font=Enum.Font.GothamBold, TextSize=16, TextXAlignment=Enum.TextXAlignment.Left}, TitleBar)
local closeClick = N("TextButton", {Size=UDim2.new(0,26,0,26), Position=UDim2.new(1,-32,0.5,-13), BackgroundColor3=Color3.fromRGB(220,50,70), Text="✕", TextColor3=Color3.new(1,1,1), Font=Enum.Font.GothamBold, TextSize=14}, TitleBar)
corner(closeClick,6); closeClick.MouseButton1Click:Connect(function() M.Visible=false; if Blur then TweenService:Create(Blur,TweenInfo.new(0.3),{Size=0}):Play() end end)

local Sidebar = N("Frame", {Size=UDim2.new(0,168,1,-60), Position=UDim2.new(0,10,0,50), BackgroundColor3=Colors.Sidebar, BorderSizePixel=0}, M)
corner(Sidebar,12); N("UIListLayout", {Padding=UDim.new(0,4)}, Sidebar); padding(Sidebar,8,10)

local Container = N("ScrollingFrame", {Position=UDim2.new(0,188,0,50), Size=UDim2.new(1,-198,1,-60), BackgroundColor3=Colors.Panel, BorderSizePixel=0, ScrollBarThickness=0, CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y}, M)
corner(Container,12); N("UIListLayout", {Padding=UDim.new(0,6)}, Container); padding(Container,14)

local Tabs = {AIM={}, VISUALS={}, PLAYER={}, WORLD={}, MISC={}}
local tabButtons = {}
local function showTab(name)
    for t, objs in pairs(Tabs) do for _, o in ipairs(objs) do o.Visible=(t==name) end end
    for k, b in pairs(tabButtons) do b.TextColor3 = (k==name) and Colors.Accent or Colors.TextDim end
end

local function createTabBtn(name, label, order)
    local b = N("TextButton", {Size=UDim2.new(1,0,0,36), BackgroundColor3=Colors.Sidebar, Text=label, TextColor3=Colors.TextDim, Font=Enum.Font.GothamMedium, TextSize=13, AutoButtonColor=false, LayoutOrder=order}, Sidebar)
    corner(b,8); tabButtons[name]=b; b.MouseButton1Click:Connect(function() showTab(name) end)
end

local function createCategory(title, order)
    return N("TextLabel", {Size=UDim2.new(1,0,0,24), BackgroundTransparency=1, Text=title, TextColor3=Colors.TextDim, Font=Enum.Font.GothamBold, TextSize=12, TextXAlignment=Enum.TextXAlignment.Left, LayoutOrder=order}, Container)
end

local function createToggle(label, prop, order)
    local b = N("TextButton", {Size=UDim2.new(1,0,0,40), BackgroundColor3=Colors.Card, Text="", AutoButtonColor=false, LayoutOrder=order}, Container)
    corner(b,8); N("TextLabel", {Size=UDim2.new(1,-60,1,0), Position=UDim2.new(0,12,0,0), BackgroundTransparency=1, Text=label, TextColor3=Colors.Text, Font=Enum.Font.Gotham, TextSize=13, TextXAlignment=Enum.TextXAlignment.Left}, b)
    local sw = N("Frame", {Size=UDim2.new(0,34,0,18), Position=UDim2.new(1,-46,0.5,-9), BackgroundColor3=C[prop] and Colors.Accent or Colors.BorderLight}, b)
    corner(sw,9); local kn = N("Frame", {Size=UDim2.new(0,14,0,14), Position=C[prop] and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7), BackgroundColor3=Color3.new(1,1,1)}, sw)
    corner(kn,7); b.MouseButton1Click:Connect(function() C[prop]=not C[prop]; sw.BackgroundColor3=C[prop] and Colors.Accent or Colors.BorderLight; kn.Position=C[prop] and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7) end)
    return b
end

local function createSlider(label, prop, min, max, order)
    local f = N("Frame", {Size=UDim2.new(1,0,0,48), BackgroundColor3=Colors.Card, LayoutOrder=order}, Container)
    corner(f,8); N("TextLabel", {Size=UDim2.new(1,-100,0,20), Position=UDim2.new(0,12,0,6), BackgroundTransparency=1, Text=label, TextColor3=Colors.Text, Font=Enum.Font.Gotham, TextSize=12, TextXAlignment=Enum.TextXAlignment.Left}, f)
    local vl = N("TextLabel", {Size=UDim2.new(0,60,0,20), Position=UDim2.new(1,-70,0,6), BackgroundTransparency=1, Text=tostring(C[prop]), TextColor3=Colors.Accent, Font=Enum.Font.GothamBold, TextSize=12, TextXAlignment=Enum.TextXAlignment.Right}, f)
    local bar = N("Frame", {Size=UDim2.new(1,-24,0,4), Position=UDim2.new(0,12,0,32), BackgroundColor3=Colors.BorderLight}, f)
    corner(bar,2); local fill = N("Frame", {Size=UDim2.new((C[prop]-min)/(max-min),0,1,0), BackgroundColor3=Colors.Accent}, bar)
    corner(fill,2); local inp = N("TextButton", {Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Text=""}, bar); local drag=false
    inp.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=true end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=false end end)
    UserInputService.InputChanged:Connect(function(i) if drag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then local p=math.clamp((i.Position.X-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1); local v=math.floor(min+(max-min)*p+0.5); C[prop]=v; vl.Text=tostring(v); fill.Size=UDim2.new(p,0,1,0) end end)
    return f
end

local O=0; local function nextO() O=O+1; return O end
local function addTo(t,o) if o then table.insert(Tabs[t],o); o.Visible=false end end

createTabBtn("AIM","Silent Aim",1); createTabBtn("VISUALS","Visuals",2); createTabBtn("PLAYER","Player",3); createTabBtn("WORLD","World",4); createTabBtn("MISC","Misc",5)

-- НАПОЛНЕНИЕ
addTo("AIM", createCategory("SILENT AIM", nextO()))
addTo("AIM", createToggle("Включить Silent Aim", "SilentAim", nextO()))
addTo("AIM", createToggle("Team Check", "TeamCheck", nextO()))
addTo("AIM", createToggle("Wall Check", "WallCheck", nextO()))
addTo("AIM", createToggle("AutoShoot", "AutoShoot", nextO()))
addTo("AIM", createSlider("Задержка выстрела","AutoShootDelay",0.01,0.5,nextO()))
addTo("AIM", createSlider("FOV","FOV",20,800,nextO()))
addTo("AIM", createToggle("Show FOV", "ShowFOV", nextO()))

addTo("PLAYER", createCategory("PLAYER", nextO()))
addTo("PLAYER", createToggle("Inf Jump", "InfJump", nextO()))
addTo("PLAYER", createToggle("Anti AFK", "AntiAFK", nextO()))
addTo("PLAYER", createToggle("God Mode (No Fall)", "NoFallDamage", nextO()))
addTo("PLAYER", createToggle("Silent Walk", "SilentWalk", nextO()))
addTo("PLAYER", createToggle("Head Expander", "HeadExpander", nextO()))
addTo("PLAYER", createSlider("Head Size", "HitboxSize", 2, 20, nextO()))
addTo("PLAYER", createToggle("Third Person", "ThirdPerson", nextO()))
addTo("PLAYER", createSlider("Third Dist","ThirdPersonDist",3,50,nextO()))

addTo("VISUALS", createCategory("PLAYER ESP", nextO()))
addTo("VISUALS", createToggle("ESP", "ESP", nextO()))
addTo("VISUALS", createToggle("Box", "ESPBox", nextO()))
addTo("VISUALS", createToggle("Name", "ESPName", nextO()))
addTo("VISUALS", createToggle("Distance", "ESPDist", nextO()))
addTo("VISUALS", createToggle("Skeleton", "ESPSkeleton", nextO()))
addTo("VISUALS", createToggle("Health Bar", "ESPHP", nextO()))
addTo("VISUALS", createToggle("HP Number", "ESPHPNum", nextO()))
addTo("VISUALS", createToggle("Tracers", "ESPTracers", nextO()))
addTo("VISUALS", createToggle("Head Circle", "ESPHead", nextO()))
addTo("VISUALS", createSlider("ESP Max Dist","ESPMaxDist",50,5000,nextO()))

addTo("VISUALS", createCategory("RESOURCES", nextO()))
addTo("VISUALS", createToggle("Sulfur", "SulfurESP", nextO()))
addTo("VISUALS", createToggle("Iron", "IronESP", nextO()))
addTo("VISUALS", createToggle("Stone", "StoneESP", nextO()))
addTo("VISUALS", createToggle("Crate", "CrateESP", nextO()))
addTo("VISUALS", createToggle("Military Crate", "MilitaryESP", nextO()))
addTo("VISUALS", createToggle("Elite Crate", "EliteESP", nextO()))
addTo("VISUALS", createToggle("Food Box", "FoodESP", nextO()))
addTo("VISUALS", createSlider("Ore Dist","OreDist",50,3000,nextO()))
addTo("VISUALS", createSlider("Crate Dist","CrateDist",50,3000,nextO()))
addTo("VISUALS", createToggle("NPC ESP", "NpcESP", nextO()))
addTo("VISUALS", createSlider("NPC Dist","NpcDist",50,3000,nextO()))

addTo("VISUALS", createCategory("WORLD VISUAL", nextO()))
addTo("VISUALS", createToggle("Fullbright", "Fullbright", nextO()))
addTo("VISUALS", createToggle("X-Ray", "XRay", nextO()))
addTo("VISUALS", createToggle("No Deco", "NoDeco", nextO()))
addTo("VISUALS", createToggle("Hitmarker", "Hitmarker", nextO()))
addTo("VISUALS", createToggle("Kill Sound", "KillSound", nextO()))
addTo("VISUALS", createToggle("Hit Sound", "HitSound", nextO()))
addTo("VISUALS", createToggle("Reload Indicator", "ReloadIndicator", nextO()))

addTo("WORLD", createCategory("WORLD", nextO()))
addTo("WORLD", createToggle("No Bullet Drop", "NoBulletDrop", nextO()))

addTo("WORLD", createCategory("OPTIMIZATION", nextO()))
addTo("WORLD", createToggle("Low GFX", "OptLowGFX", nextO()))

addTo("MISC", createCategory("ADMIN LIST", nextO()))
addTo("MISC", createToggle("Show Admin List", "AdminList", nextO()))

-- ============ ADMIN LIST UI ============
local AdminGui = N("ScreenGui", {Name="FerAdminList", ResetOnSpawn=false}, CoreGui)
local AdminFrame = N("Frame", {Size=UDim2.new(0,200,0,100), Position=UDim2.new(0,20,0.3,0), BackgroundColor3=Colors.Panel, BorderSizePixel=0, Visible=false}, AdminGui)
corner(AdminFrame,8); stroke(AdminFrame, Colors.Accent, 1)
N("TextLabel", {Size=UDim2.new(1,0,0,26), BackgroundTransparency=1, Text="Admins Online", TextColor3=Colors.Text, Font=Enum.Font.GothamBold, TextSize=13}, AdminFrame)
local AdminListContainer = N("ScrollingFrame", {Size=UDim2.new(1,0,1,-26), Position=UDim2.new(0,0,0,26), BackgroundTransparency=1, BorderSizePixel=0, CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y}, AdminFrame)
N("UIListLayout", {Padding=UDim.new(0,4)}, AdminListContainer)

local detectedAdmins = {}
local function checkAdmin(pl)
    if pl == LP then return end
    task.spawn(function()
        local success, role = pcall(function() return pl:GetRoleInGroup(15631191) end)
        if success and role and role ~= "Guest" and role ~= "Member" then
            if not detectedAdmins[pl] then
                detectedAdmins[pl] = true
                local label = N("TextLabel", {Size=UDim2.new(1,0,0,20), BackgroundTransparency=1, Text="• "..pl.Name.." ["..role.."]", TextColor3=Color3.fromRGB(255,100,100), Font=Enum.Font.Gotham, TextSize=12, TextXAlignment=Enum.TextXAlignment.Left}, AdminListContainer)
                pl.AncestryChanged:Connect(function() if not pl.Parent then if label then label:Destroy() end; detectedAdmins[pl] = nil end end)
            end
        end
    end)
end
for _, p in ipairs(Players:GetPlayers()) do checkAdmin(p) end
Players.PlayerAdded:Connect(checkAdmin)
Players.PlayerRemoving:Connect(function(pl)
    if detectedAdmins[pl] then detectedAdmins[pl] = nil; for _, v in ipairs(AdminListContainer:GetChildren()) do if v:IsA("TextLabel") and v.Text:find(pl.Name) then v:Destroy() end end end
end)

-- ============ SILENT WALK (FIXED) ============
local NoFootsteps = { Enabled = false, OldVolumes = setmetatable({}, { __mode = "k" }) }
local function MuteSound(s) 
    if not s:IsA("Sound") then return end
    if not NoFootsteps.OldVolumes[s] then NoFootsteps.OldVolumes[s]=s.Volume end
    s.Volume=0; s:Stop() 
end
local function RestoreSounds()
    for s, v in pairs(NoFootsteps.OldVolumes) do
        if s and s.Parent then pcall(function() s.Volume = v end) end
    end
    table.clear(NoFootsteps.OldVolumes)
end
local function MuteFootsteps() if not NoFootsteps.Enabled then return end; local f=SoundService:FindFirstChild("FootstepSounds"); if f then for _,o in ipairs(f:GetDescendants()) do if o:IsA("Sound") then MuteSound(o) end end end end
local function MuteChar(char) if not NoFootsteps.Enabled then return end; local r=char:FindFirstChild("HumanoidRootPart"); if r then for _,o in ipairs(r:GetChildren()) do if o:IsA("Sound") then MuteSound(o) end end end end
RunService.Heartbeat:Connect(function() if NoFootsteps.Enabled then MuteFootsteps(); if LP.Character then MuteChar(LP.Character) end end end)
LP.CharacterAdded:Connect(function(c) if NoFootsteps.Enabled then task.wait(1); MuteChar(c) end end)

-- ============ FIX 2: RAYCAST ============
local v13 = { Enabled = false, TargetPart = "Head", UseFOV = true, FOVRadius = 150, FOVRadiusSq = 22500, MaxDistance = 500, MaxDistanceSq = 250000 }
local screenCenter = Vector2.new(0,0)
local function getMousePosition() local cam = Workspace.CurrentCamera; if cam then local vp = cam.ViewportSize; screenCenter = Vector2.new(vp.X*0.5, vp.Y*0.5) end; return Vector2.new(screenCenter.X, screenCenter.Y + 50) end
local function getPositionOnScreen(pos) local cam = Workspace.CurrentCamera; if not cam then return Vector2.new(0,0), false end; local p, v = cam:WorldToViewportPoint(pos); return Vector2.new(p.X, p.Y), v end
local function distSq2D(a, b) local dx, dy = a.X-b.X, a.Y-b.Y; return dx*dx+dy*dy end
local function distSq3D(a, b) local dx,dy,dz = a.X-b.X, a.Y-b.Y, a.Z-b.Z; return dx*dx+dy*dy+dz*dz end

local ignoreFolderNames = {"Viewmodel","ViewModel","Ignore","Debris","BulletTraces","Effects","GunEffects","Arms","FPSArms","Particles","Bullets"}
local wallRayP = RaycastParams.new(); wallRayP.FilterType = Enum.RaycastFilterType.Exclude; wallRayP.IgnoreWater = true

local function isPartVisible(origin, targetPos, targetChar)
    local il = {}; if LP.Character then il[#il+1] = LP.Character end
    local cam = Workspace.CurrentCamera; if cam then il[#il+1] = cam end
    for i = 1, #ignoreFolderNames do local f = Workspace:FindFirstChild(ignoreFolderNames[i]); if f then il[#il+1] = f end end
    wallRayP.FilterDescendantsInstances = il
    for _ = 1, 4 do
        local dir = targetPos - origin; if dir.Magnitude < 0.5 then return true end
        local r = Workspace:Raycast(origin, dir, wallRayP); if not r then return true end
        if r.Instance:IsDescendantOf(targetChar) then return true end
        if r.Instance:IsA("BasePart") and r.Instance.Transparency >= 0.9 then il[#il+1] = r.Instance; wallRayP.FilterDescendantsInstances = il; continue end
        local hitO = false; for plr in pairs(PlayerCache) do if plr.Character and r.Instance:IsDescendantOf(plr.Character) then il[#il+1] = plr.Character; wallRayP.FilterDescendantsInstances = il; hitO = true; break end end
        if hitO then continue end; return false
    end; return false
end

local function getClosestVomagla()
    local cam = Workspace.CurrentCamera
    if not cam then return nil end
    local myRoot = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    local myPos = myRoot and myRoot.Position
    local center = getMousePosition()
    local best, bestD = nil, nil
    local maxDistSq = v13.MaxDistanceSq
    for pl, data in pairs(PlayerCache) do
        if pl ~= LP then
            local ch = data.Char
            local part = ch and (ch:FindFirstChild(v13.TargetPart) or ch:FindFirstChild("HumanoidRootPart") or ch:FindFirstChild("Head"))
            if part and part.Parent then
                local hum = ch:FindFirstChild("Humanoid")
                if hum and hum.Health > 0 then
                    if not (C.TeamCheck and pl.Team == LP.Team) then
                        local pp = part.Position
                        if not myPos or (myPos - pp).Magnitude <= 500 then
                            local sp, vis = cam:WorldToViewportPoint(pp)
                            if vis then
                                local d = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                                if d < v13.FOVRadius then
                                    if not C.WallCheck or isPartVisible(cam.CFrame.Position, pp, ch) then
                                        if not bestD or d < bestD then 
                                            best = {part = part, char = ch} 
                                            bestD = d 
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return best
end

-- ХУК 1: RAYCAST (ПЕРЕДАЕМ ВСЕ АРГУМЕНТЫ)
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if method == "Raycast" and self == Workspace then
        if not checkcaller() then
            local args = table.pack(...)
            local origin = args[1]
            local direction = args[2]
            if typeof(origin) == "Vector3" and typeof(direction) == "Vector3" then
                local mag = direction.Magnitude
                if C.SilentAim and CurrentAimTarget and CurrentAimTarget.part then
                    local newDir = (CurrentAimTarget.part.Position - origin).Unit * mag
                    args[2] = newDir
                    return oldNamecall(self, table.unpack(args, 1, args.n))
                end
            end
        end
    end
    return oldNamecall(self, ...)
end))

-- ХУК 2: GUNBASE.FIRE (ТОЛЬКО ПОЗИЦИЯ)
pcall(function()
    local GunBase = require(game:GetService("ReplicatedStorage").Gun.Scripts.GunBase)
    if GunBase and type(GunBase.fire) == "function" then
        local origFire = GunBase.fire
        GunBase.fire = function(self, ...)
            if C.SilentAim and CurrentAimTarget and CurrentAimTarget.part then
                local args = table.pack(...)
                local patched = false
                local pos = CurrentAimTarget.part.Position
                for i = 1, args.n do
                    local v = args[i]
                    if typeof(v) == "Vector3" and not patched then
                        -- Проверяем, что это позиция, а не направление (магнитуда > 1)
                        if v.Magnitude > 1 then
                            args[i] = pos
                            patched = true
                        end
                    elseif typeof(v) == "buffer" and not patched then
                        pcall(function()
                            buffer.writef32(v, 4, pos.X)
                            buffer.writef32(v, 8, pos.Y)
                            buffer.writef32(v, 12, pos.Z)
                        end)
                        patched = true
                    end
                end
                if patched then
                    return origFire(self, table.unpack(args, 1, args.n))
                end
            end
            return origFire(self, ...)
        end
    end
end)

local lastShoot = 0
local function tryAutoShoot(target)
    if not C.AutoShoot or not target then return end
    local now = tick()
    if now - lastShoot < C.AutoShootDelay then return end
    lastShoot = now
    pcall(function() local VIM = game:GetService("VirtualInputManager"); if VIM then VIM:SendMouseButtonEvent(0,0,0,true,game,1); task.wait(0.01); VIM:SendMouseButtonEvent(0,0,0,false,game,1) end end)
end

-- ESP
local hasDrawing = pcall(function() local t=Drawing.new("Line"); t:Remove(); return true end)
local ESP = {}
local function removeESP(p) local e=ESP[p]; if e then for _,d in pairs(e) do if d and d.Remove then pcall(function() d:Remove() end) end end; ESP[p]=nil end end
local function createESP(p)
    if p==LP or ESP[p] or not hasDrawing then return end
    local e={}
    local ok=pcall(function()
        e.box={Drawing.new("Line"),Drawing.new("Line"),Drawing.new("Line"),Drawing.new("Line")}
        e.name=Drawing.new("Text"); e.dist=Drawing.new("Text"); e.hpBg=Drawing.new("Line"); e.hpFill=Drawing.new("Line"); e.hpNum=Drawing.new("Text"); e.tracer=Drawing.new("Line"); e.head=Drawing.new("Circle"); e.bones={Drawing.new("Line"),Drawing.new("Line"),Drawing.new("Line"),Drawing.new("Line"),Drawing.new("Line"),Drawing.new("Line")}
    end)
    if not ok then removeESP(p); return end
    for _,l in ipairs(e.box) do l.Thickness=1; l.Color=C.ESPColor; l.Visible=false end
    e.name.Size=13; e.name.Center=true; e.name.Outline=true; e.name.Font=2; e.name.Color=C.ESPColor
    e.dist.Size=11; e.dist.Center=true; e.dist.Outline=true; e.dist.Font=2; e.dist.Color=C.ESPColor
    e.hpBg.Thickness=3; e.hpBg.Visible=false; e.hpFill.Thickness=3; e.hpFill.Visible=false; e.hpNum.Size=11; e.hpNum.Center=true; e.hpNum.Outline=true; e.hpNum.Font=2; e.hpNum.Color=Color3.new(1,1,1)
    e.tracer.Thickness=1; e.tracer.Color=C.ESPColor; e.head.Thickness=2; e.head.NumSides=24; e.head.Filled=false
    for _,b in ipairs(e.bones) do b.Thickness=1; b.Color=C.ESPColor end
    ESP[p]=e
end
for _,p in ipairs(Players:GetPlayers()) do createESP(p) end
Players.PlayerAdded:Connect(function(p) task.wait(1); createESP(p) end)
Players.PlayerRemoving:Connect(function(p) removeESP(p) end)

-- ============ FIX 3: HEAD EXPANDER (ОБНОВЛЕНИЕ РАЗМЕРА) ============
local HeadHitboxes = {}
local function setupHeadExpander(char)
    if not char then return end
    local head = char:FindFirstChild("Head")
    if not head then return end
    if C.HeadExpander then
        if HeadHitboxes[char] and HeadHitboxes[char].Parent then 
            HeadHitboxes[char].Size = Vector3.new(C.HitboxSize, C.HitboxSize, C.HitboxSize)
            return 
        end
        local hb = Instance.new("Part")
        hb.Name="FerHitbox"; hb.Size=Vector3.new(C.HitboxSize,C.HitboxSize,C.HitboxSize); hb.Transparency=1; hb.CanCollide=false; hb.CanQuery=true; hb.Massless=true
        hb.CFrame=head.CFrame
        local weld = Instance.new("WeldConstraint"); weld.Part0=head; weld.Part1=hb; weld.Parent=hb
        hb.Parent=char; HeadHitboxes[char]=hb
    elseif HeadHitboxes[char] then
        HeadHitboxes[char]:Destroy(); HeadHitboxes[char]=nil
    end
end
for _,pl in ipairs(Players:GetPlayers()) do if pl.Character then setupHeadExpander(pl.Character) end; pl.CharacterAdded:Connect(setupHeadExpander) end
Players.PlayerAdded:Connect(function(pl) pl.CharacterAdded:Connect(setupHeadExpander) end)

-- HITMARKER & SOUNDS
local function playHitSound() if not C.HitSound then return end; local s=Instance.new("Sound"); s.SoundId="rbxassetid://988593556"; s.Volume=2; s.Parent=SoundService; s:Play(); game:GetService("Debris"):AddItem(s,1) end
local function playKillSound() if not C.KillSound then return end; local s=Instance.new("Sound"); s.SoundId="rbxassetid://116907610084760"; s.Volume=2; s.Parent=SoundService; s:Play(); game:GetService("Debris"):AddItem(s,1) end
local function createHitmarker(pos)
    if not C.Hitmarker then return end
    local p=Instance.new("Part"); p.Size=Vector3.new(0.1,0.1,0.1); p.Transparency=1; p.Anchored=true; p.CanCollide=false; p.Position=pos; p.Parent=Workspace
    local bill=Instance.new("BillboardGui"); bill.Size=UDim2.new(0,20,0,20); bill.AlwaysOnTop=true; bill.Parent=p
    for i=1,4 do local l=Instance.new("Frame"); l.Size=UDim2.new(0,7,0,1); l.BackgroundColor3=Color3.new(1,1,1); l.BorderSizePixel=0; l.Position=UDim2.new(0.5,0,0.5,0); l.Rotation=i==1 and 45 or i==2 and -45 or i==3 and 135 or 225; l.AnchorPoint=Vector2.new(0.5,0.5); l.Parent=bill end
    game:GetService("Debris"):AddItem(p,0.5)
end
pcall(function()
    local GunClient = require(game:GetService("ReplicatedStorage").Gun.Scripts.GunClient)
    local oldHit = GunClient.hit
    GunClient.hit = function(self, hitResult, ...)
        if oldHit then oldHit(self, hitResult, ...) end
        if hitResult and hitResult.Instance then
            local char = hitResult.Instance:FindFirstAncestorOfClass("Model")
            local pl = Players:GetPlayerFromCharacter(char)
            if pl and pl ~= LP then createHitmarker(hitResult.Position); playHitSound() end
        end
    end
end)
for _,pl in ipairs(Players:GetPlayers()) do
    if pl~=LP then pl.CharacterAdded:Connect(function(char) local hum=char:WaitForChild("Humanoid"); hum.Died:Connect(function() if C.KillSound then playKillSound() end end) end) end
end

-- ============ FIX 4: FALL DAMAGE (ОДИН HEARTBEAT) ============
local FallDamageConn = nil
local function setupNFD(char)
    if FallDamageConn then FallDamageConn:Disconnect() end
    local hrp = char:WaitForChild("HumanoidRootPart", 5)
    if not hrp then return end
    FallDamageConn = RunService.Heartbeat:Connect(function()
        if not C.NoFallDamage or not hrp.Parent then return end
        local vel = hrp.AssemblyLinearVelocity
        if vel.Y < -50 then hrp.AssemblyLinearVelocity = Vector3.new(vel.X, -10, vel.Z) end
    end)
end
if LP.Character then setupNFD(LP.Character) end
LP.CharacterAdded:Connect(setupNFD)

-- MAIN LOOP
local FOVRing = N("Frame", {AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.new(0.5,0,0.5,50), BackgroundTransparency=1, Visible=false, ZIndex=10}, SG)
corner(FOVRing, 500); local FOVStroke = N("UIStroke", {Thickness=1.5, Color=Colors.Accent}, FOVRing)

RunService.RenderStepped:Connect(function()
    local cam = GetCamera(); if not cam then return end
    local now = tick()

    if C.ShowFOV and C.SilentAim then
        FOVRing.Visible = true; FOVRing.Size = UDim2.new(0, C.FOV*2, 0, C.FOV*2)
        FOVStroke.Color = CurrentAimTarget and Color3.fromRGB(0,255,0) or Colors.Accent
    else FOVRing.Visible = false end

    if C.AdminList then
        AdminFrame.Visible = true
        local totalSize = 26
        for _,v in ipairs(AdminListContainer:GetChildren()) do if v:IsA("TextLabel") then totalSize+=24 end end
        AdminFrame.Size = UDim2.new(0,200,0,totalSize)
    else AdminFrame.Visible = false end

    if C.SilentAim then
        v13.Enabled = true
        v13.TargetPart = C.AimPart
        v13.FOVRadius = C.FOV
        CurrentAimTarget = getClosestVomagla()
        if C.AutoShoot and CurrentAimTarget then tryAutoShoot(CurrentAimTarget) end
    else 
        v13.Enabled = false
        CurrentAimTarget = nil 
    end

    if hasDrawing then
        for pl, e in pairs(ESP) do
            local char=pl.Character; local hrp=char and char:FindFirstChild("HumanoidRootPart"); local hum=char and char:FindFirstChildOfClass("Humanoid"); local head=char and char:FindFirstChild("Head")
            local draw=false
            if C.ESP and hrp and hum and hum.Health>0 then
                local ps,on=cam:WorldToViewportPoint(hrp.Position)
                -- ИСПОЛЬЗУЕМ DISTANCE (MAGNITUDE)
                local dist = (hrp.Position - cam.CFrame.Position).Magnitude
                if on and dist <= C.ESPMaxDist then
                    draw=true; local sy=4500/ps.Z; local sx=2800/ps.Z; local x,y=ps.X-sx/2,ps.Y-sy/2
                    for i,l in ipairs(e.box) do
                        l.Visible=C.ESPBox; l.Color=C.ESPColor
                        if i==1 then l.From,l.To=Vector2.new(x,y),Vector2.new(x+sx,y)
                        elseif i==2 then l.From,l.To=Vector2.new(x+sx,y),Vector2.new(x+sx,y+sy)
                        elseif i==3 then l.From,l.To=Vector2.new(x+sx,y+sy),Vector2.new(x,y+sy)
                        else l.From,l.To=Vector2.new(x,y+sy),Vector2.new(x,y) end
                    end
                    local hpR=math.clamp(hum.Health/math.max(hum.MaxHealth,1),0,1)
                    e.hpBg.Visible=C.ESPHP; e.hpFill.Visible=C.ESPHP
                    if C.ESPHP then
                        e.hpBg.From,e.hpBg.To=Vector2.new(x-8,y),Vector2.new(x-8,y+sy)
                        e.hpFill.From,e.hpFill.To=Vector2.new(x-8,y+sy),Vector2.new(x-8,y+sy-sy*hpR)
                        e.hpFill.Color=Color3.fromRGB(255*(1-hpR),255*hpR,60)
                    end
                    e.hpNum.Visible=C.ESPHPNum
                    if C.ESPHPNum then e.hpNum.Text=math.floor(hum.Health).." / "..math.floor(hum.MaxHealth); e.hpNum.Position=Vector2.new(ps.X,y+sy+4) end
                    e.name.Visible=C.ESPName
                    if C.ESPName then e.name.Text=pl.DisplayName; e.name.Position=Vector2.new(ps.X,y-34); e.name.Color=C.ESPColor end
                    e.dist.Visible=C.ESPDist
                    if C.ESPDist then e.dist.Text="["..math.floor(dist).."m]"; e.dist.Position=Vector2.new(ps.X,y-18) end
                    e.tracer.Visible=C.ESPTracers
                    if C.ESPTracers then e.tracer.From=Vector2.new(cam.ViewportSize.X/2,cam.ViewportSize.Y); e.tracer.To=Vector2.new(ps.X,ps.Y); e.tracer.Color=C.ESPColor end
                    e.head.Visible=C.ESPHead
                    if C.ESPHead and head then local hps,hon=cam:WorldToViewportPoint(head.Position); if hon then e.head.Position=Vector2.new(hps.X,hps.Y); e.head.Radius=10; e.head.Color=C.ESPColor else e.head.Visible=false end end
                    local skel=C.ESPSkeleton; for _,b in ipairs(e.bones) do b.Visible=false end
                    if skel then
                        local torso=char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso"); local larm=char:FindFirstChild("LeftUpperArm") or char:FindFirstChild("Left Arm") or char:FindFirstChild("LeftHand"); local rarm=char:FindFirstChild("RightUpperArm") or char:FindFirstChild("Right Arm") or char:FindFirstChild("RightHand"); local lleg=char:FindFirstChild("LeftUpperLeg") or char:FindFirstChild("Left Leg") or char:FindFirstChild("LeftFoot"); local rleg=char:FindFirstChild("RightUpperLeg") or char:FindFirstChild("Right Leg") or char:FindFirstChild("RightFoot")
                        local function to2d(part) if not part then return nil end local sp,on2=cam:WorldToViewportPoint(part.Position) if on2 then return Vector2.new(sp.X,sp.Y) end return nil end
                        local h2d,t2d,hrp2d=to2d(head),to2d(torso),to2d(hrp)
                        if h2d and hrp2d then e.bones[1].From,e.bones[1].To=h2d,hrp2d; e.bones[1].Visible=true end
                        if t2d and hrp2d then e.bones[2].From,e.bones[2].To=t2d,hrp2d; e.bones[2].Visible=true end
                        if t2d and larm then local p=to2d(larm) if p then e.bones[3].From,e.bones[3].To=t2d,p; e.bones[3].Visible=true end end
                        if t2d and rarm then local p=to2d(rarm) if p then e.bones[4].From,e.bones[4].To=t2d,p; e.bones[4].Visible=true end end
                        if hrp2d and lleg then local p=to2d(lleg) if p then e.bones[5].From,e.bones[5].To=hrp2d,p; e.bones[5].Visible=true end end
                        if hrp2d and rleg then local p=to2d(rleg) if p then e.bones[6].From,e.bones[6].To=hrp2d,p; e.bones[6].Visible=true end end
                    end
                end
            end
            if not draw then for _,l in ipairs(e.box) do l.Visible=false end; e.name.Visible=false; e.dist.Visible=false; e.hpBg.Visible=false; e.hpFill.Visible=false; e.hpNum.Visible=false; e.tracer.Visible=false; e.head.Visible=false; for _,b in ipairs(e.bones) do b.Visible=false end end
        end
    end

    if C.Fullbright then Lighting.Ambient=Color3.new(1,1,1); Lighting.OutdoorAmbient=Color3.new(1,1,1); Lighting.Brightness=2; Lighting.ClockTime=14; Lighting.FogEnd=100000; Lighting.GlobalShadows=false end
    if C.OptLowGFX then pcall(function() settings().Rendering.QualityLevel=Enum.QualityLevel.Level01 end); Lighting.GlobalShadows=false end
end)

-- OTHER
UserInputService.JumpRequest:Connect(function() if C.InfJump and LP.Character then local h=LP.Character:FindFirstChildOfClass("Humanoid"); if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end end)
task.spawn(function()
    while true do task.wait(0.2)
        if C.AntiAFK then pcall(function() local v=game:GetService("VirtualUser"); v:CaptureController(); v:ClickButton2(Vector2.new()) end) end
        if C.ThirdPerson then pcall(function() LP.CameraMaxZoomDistance=C.ThirdPersonDist; LP.CameraMinZoomDistance=C.ThirdPersonDist end) end
    end
end)
workspace.DescendantAdded:Connect(function(obj) if C.NoBulletDrop and obj:IsA("BasePart") and (obj.Name:find("Bullet") or obj.Name:find("Projectile")) then pcall(function() local bf=Instance.new("BodyForce"); bf.Force=Vector3.new(0,obj:GetMass()*workspace.Gravity,0); bf.Parent=obj end) end end)

-- F-BUTTON
local OpenBtn = N("TextButton", {Size=UDim2.new(0,36,0,36), Position=UDim2.new(0,12,0.42,0), BackgroundColor3=Colors.Sidebar, Text="F", TextColor3=Colors.Accent, Font=Enum.Font.GothamBold, TextSize=16, AutoButtonColor=false, ZIndex=50}, SG)
corner(OpenBtn,18); stroke(OpenBtn, Colors.Accent, 1.5, 0.3)
local dragBtn, btnStart, posStart, moved = false, nil, nil, false
OpenBtn.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragBtn=true; moved=false; btnStart=i.Position; posStart=OpenBtn.Position end end)
OpenBtn.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragBtn=false end end)
UserInputService.InputChanged:Connect(function(i) if dragBtn and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then local d=i.Position-btnStart; if math.abs(d.X)>4 or math.abs(d.Y)>4 then moved=true end; OpenBtn.Position=UDim2.new(posStart.X.Scale,posStart.X.Offset+d.X,posStart.Y.Scale,posStart.Y.Offset+d.Y) end end)
OpenBtn.MouseButton1Click:Connect(function() if moved then moved=false; return end; M.Visible=not M.Visible end)

local mdrag, mds, mdp = false, nil, nil
TitleBar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then mdrag=true; mds=i.Position; mdp=M.Position end end)
TitleBar.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then mdrag=false end end)
UserInputService.InputChanged:Connect(function(i) if mdrag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then local d=i.Position-mds; M.Position=UDim2.new(mdp.X.Scale,mdp.X.Offset+d.X,mdp.Y.Scale,mdp.Y.Offset+d.Y) end end)

UserInputService.InputBegan:Connect(function(input) if input.KeyCode==Enum.KeyCode.RightShift then M.Visible=not M.Visible end end)
showTab("AIM")
pcall(function() game:GetService("StarterGui"):SetCore("SendNotification", {Title="FerClient v24.0", Text="Fixed: Cache, Raycast, FallDamage", Duration=4}) end)
print("[FerClient v24.0] Loaded.")
