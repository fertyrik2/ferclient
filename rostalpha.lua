--[[ FerClient v11.0 | Silent Aim (Mouse.Hit) + Camera Fix ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local Stats = game:GetService("Stats")
local LP = Players.LocalPlayer

local PREDICTION = 0.15
local isMobile = UserInputService.TouchEnabled

local function GetCamera()
    local cam = workspace.CurrentCamera
    if cam and cam.Parent then return cam end
    return nil
end

-- ============ ТЕМЫ ============
local Themes = {
    Midnight = {Accent=Color3.fromRGB(150,110,255), AccentSoft=Color3.fromRGB(80,60,140), Background=Color3.fromRGB(12,12,16), Sidebar=Color3.fromRGB(18,18,24), Panel=Color3.fromRGB(22,22,30), Card=Color3.fromRGB(28,28,38), CardHover=Color3.fromRGB(38,38,50), Text=Color3.fromRGB(240,240,248), TextDim=Color3.fromRGB(150,150,165), TextMuted=Color3.fromRGB(100,100,115), Border=Color3.fromRGB(38,38,50), BorderLight=Color3.fromRGB(50,50,66)},
    Obsidian = {Accent=Color3.fromRGB(200,200,210), AccentSoft=Color3.fromRGB(80,80,90), Background=Color3.fromRGB(6,6,8), Sidebar=Color3.fromRGB(10,10,12), Panel=Color3.fromRGB(14,14,18), Card=Color3.fromRGB(20,20,24), CardHover=Color3.fromRGB(30,30,36), Text=Color3.fromRGB(235,235,240), TextDim=Color3.fromRGB(140,140,150), TextMuted=Color3.fromRGB(90,90,100), Border=Color3.fromRGB(28,28,34), BorderLight=Color3.fromRGB(42,42,50)},
    RoseQuartz = {Accent=Color3.fromRGB(255,130,200), AccentSoft=Color3.fromRGB(120,60,100), Background=Color3.fromRGB(18,12,20), Sidebar=Color3.fromRGB(24,16,26), Panel=Color3.fromRGB(30,20,32), Card=Color3.fromRGB(38,26,42), CardHover=Color3.fromRGB(50,34,56), Text=Color3.fromRGB(248,235,245), TextDim=Color3.fromRGB(180,155,175), TextMuted=Color3.fromRGB(120,100,120), Border=Color3.fromRGB(50,34,56), BorderLight=Color3.fromRGB(68,46,74)},
    Arctic = {Accent=Color3.fromRGB(90,180,255), AccentSoft=Color3.fromRGB(40,80,130), Background=Color3.fromRGB(8,12,20), Sidebar=Color3.fromRGB(12,18,28), Panel=Color3.fromRGB(16,24,36), Card=Color3.fromRGB(22,32,48), CardHover=Color3.fromRGB(32,46,66), Text=Color3.fromRGB(235,244,255), TextDim=Color3.fromRGB(150,170,195), TextMuted=Color3.fromRGB(100,120,145), Border=Color3.fromRGB(32,46,66), BorderLight=Color3.fromRGB(46,64,88)}
}
local Colors = Themes.Midnight
local CurrentTheme = "Midnight"
local Themed = {frames={},labels={},strokes={},buttons={},accents={},fills={},knobs={},markers={}}
local function regFrame(i,k) table.insert(Themed.frames,{inst=i,kind=k or "panel"}) end
local function regLabel(i,k) table.insert(Themed.labels,{inst=i,kind=k or "text"}) end
local function regStroke(i) table.insert(Themed.strokes,i) end
local function regAccent(i) table.insert(Themed.accents,i) end

-- ============ СОСТОЯНИЕ ============
local C = {
    AimBot=false, AimPart="Head", Smooth=0.15, FOV=150, TeamCheck=false, WallCheck=false,
    AutoShoot=false, AutoShootDelay=0.05,
    SilentAim=false, -- ГЛАВНОЕ НОВОВВЕДЕНИЕ
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

-- ============ PLAYER CACHE ============
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

-- ============ HELPERS ============
local function N(class, props, parent)
    local o = Instance.new(class)
    for k, v in pairs(props or {}) do pcall(function() o[k] = v end) end
    if parent then o.Parent = parent end
    return o
end
local function corner(p, r) return N("UICorner", {CornerRadius=UDim.new(0,r or 8)}, p) end
local function stroke(p, c, t, tr) return N("UIStroke", {Color=c or Colors.Border, Thickness=t or 1, Transparency=tr or 0.3, ApplyStrokeMode=Enum.ApplyStrokeMode.Border}, p) end
local function padding(p, px, py) local u=N("UIPadding",{},p) local ux,uy=UDim.new(0,px or 0),UDim.new(0,py or px or 0) u.PaddingLeft=ux u.PaddingRight=ux u.PaddingTop=uy u.PaddingBottom=uy return u end

-- ============ GUI ============
local Blur = N("BlurEffect", {Size=0, Enabled=true}, Lighting)
local SG = N("ScreenGui", {Name="FerUI_v11", ResetOnSpawn=false, IgnoreGuiInset=true, ZIndexBehavior=Enum.ZIndexBehavior.Sibling}, CoreGui)

local M = N("Frame", {Size=UDim2.new(0,720,0,500), Position=UDim2.new(0.5,-360,0.5,-250), BackgroundColor3=Colors.Background, BorderSizePixel=0, Visible=false, ClipsDescendants=false}, SG)
if isMobile then M.Size=UDim2.new(0,540,0,400) M.Position=UDim2.new(0.5,-270,0.5,-200) end
corner(M,14)
local MainStroke = stroke(M, Colors.BorderLight, 1, 0.3)
regFrame(M,"bg") regStroke(MainStroke)

local TitleBar = N("Frame", {Size=UDim2.new(1,0,0,44), BackgroundColor3=Colors.Sidebar, BorderSizePixel=0, ZIndex=2}, M)
corner(TitleBar,14)
local fixCorner = N("Frame", {Size=UDim2.new(1,0,0,14), Position=UDim2.new(0,0,1,-14), BackgroundColor3=Colors.Sidebar, BorderSizePixel=0, ZIndex=2}, TitleBar)
regFrame(TitleBar,"sidebar") regFrame(fixCorner,"sidebar")

local tlContainer = N("Frame", {Size=UDim2.new(0,60,0,12), Position=UDim2.new(0,16,0.5,-6), BackgroundTransparency=1, ZIndex=3}, TitleBar)
local function mkDot(color, order) local d=N("Frame",{Size=UDim2.new(0,12,0,12),Position=UDim2.new(0,(order-1)*18,0,0),BackgroundColor3=color,BorderSizePixel=0,ZIndex=3},tlContainer) corner(d,6) return d end
local dotClose = mkDot(Color3.fromRGB(255,95,87),1)
mkDot(Color3.fromRGB(255,189,68),2) mkDot(Color3.fromRGB(40,200,65),3)
local closeClick = N("TextButton", {Size=UDim2.new(0,12,0,12), BackgroundTransparency=1, Text="", ZIndex=4}, dotClose)
closeClick.MouseButton1Click:Connect(function() if M then M.Visible=false if Blur then TweenService:Create(Blur,TweenInfo.new(0.3),{Size=0}):Play() end end end)

local TitleLogo = N("TextLabel", {Size=UDim2.new(0,26,0,26), Position=UDim2.new(0,92,0.5,-13), BackgroundColor3=Colors.Accent, Text="F", TextColor3=Color3.new(1,1,1), Font=Enum.Font.GothamBold, TextSize=15, ZIndex=3}, TitleBar)
corner(TitleLogo,8) regAccent(TitleLogo)
local Title = N("TextLabel", {Size=UDim2.new(1,-300,1,0), Position=UDim2.new(0,126,0,0), BackgroundTransparency=1, Text="FerClient", TextColor3=Colors.Text, Font=Enum.Font.GothamBold, TextSize=15, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=3}, TitleBar)
regLabel(Title,"text")
local SubTitle = N("TextLabel", {Size=UDim2.new(0,200,1,0), Position=UDim2.new(1,-290,0,0), BackgroundTransparency=1, Text="v11.0 • Silent", TextColor3=Colors.TextMuted, Font=Enum.Font.Gotham, TextSize=11, TextXAlignment=Enum.TextXAlignment.Right, ZIndex=3}, TitleBar)
regLabel(SubTitle,"muted")

local Sidebar = N("Frame", {Size=UDim2.new(0,168,1,-60), Position=UDim2.new(0,10,0,50), BackgroundColor3=Colors.Sidebar, BorderSizePixel=0, ZIndex=2}, M)
corner(Sidebar,12) regFrame(Sidebar,"sidebar") regStroke(stroke(Sidebar,Colors.Border,1,0.5))
N("UIListLayout", {Padding=UDim.new(0,4), SortOrder=Enum.SortOrder.LayoutOrder}, Sidebar) padding(Sidebar,8,10)
N("TextLabel", {Size=UDim2.new(1,0,0,20), BackgroundTransparency=1, Text="НАВИГАЦИЯ", TextColor3=Colors.TextMuted, Font=Enum.Font.GothamMedium, TextSize=10, TextXAlignment=Enum.TextXAlignment.Left, LayoutOrder=0}, Sidebar)

local Container = N("ScrollingFrame", {Position=UDim2.new(0,188,0,50), Size=UDim2.new(1,-198,1,-60), BackgroundColor3=Colors.Panel, BorderSizePixel=0, ScrollBarThickness=isMobile and 0 or 4, ScrollBarImageColor3=Colors.Accent, ScrollBarImageTransparency=0.4, CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y, ZIndex=2}, M)
corner(Container,12) regFrame(Container,"panel") regStroke(stroke(Container,Colors.Border,1,0.5)) padding(Container,14)
N("UIListLayout", {Padding=UDim.new(0,6), SortOrder=Enum.SortOrder.LayoutOrder}, Container)

-- ============ UI BUILDERS ============
local Tabs = {VISUALS={}, AIM={}, PLAYER={}, WORLD={}, MISC={}}
local tabButtons = {}
local CurrentTab = "AIM"

local function showTab(name)
    CurrentTab = name
    for t, objs in pairs(Tabs) do for _, o in ipairs(objs) do o.Visible=(t==name) end end
    for k, b in pairs(tabButtons) do
        local active = (k==name)
        TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3=active and Colors.CardHover or Colors.Sidebar}):Play()
        local l = b:FindFirstChildOfClass("TextLabel")
        if l then TweenService:Create(l, TweenInfo.new(0.2), {TextColor3=active and Colors.Accent or Colors.TextDim}):Play() end
    end
end

local function createTabBtn(name, label, order)
    local b = N("TextButton", {Size=UDim2.new(1,0,0,36), BackgroundColor3=Colors.Sidebar, Text="", AutoButtonColor=false, LayoutOrder=order, ZIndex=3}, Sidebar)
    corner(b,8)
    local lbl = N("TextLabel", {Size=UDim2.new(1,-20,1,0), Position=UDim2.new(0,16,0,0), BackgroundTransparency=1, Text=label, TextColor3=Colors.TextDim, Font=Enum.Font.GothamMedium, TextSize=13, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=4}, b)
    regLabel(lbl,"dim")
    tabButtons[name]=b
    b.MouseButton1Click:Connect(function() showTab(name) end)
end

local function createCategory(title, order)
    local f = N("Frame", {Size=UDim2.new(1,0,0,26), BackgroundTransparency=1, LayoutOrder=order}, Container)
    padding(f,4,0)
    local l = N("TextLabel", {Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Text=title, TextColor3=Colors.TextDim, Font=Enum.Font.GothamMedium, TextSize=11, TextXAlignment=Enum.TextXAlignment.Left}, f)
    regLabel(l,"dim"); return f
end

local refreshToggle
local function createBindBtn(parent, prop, button, status)
    local bindBtn = N("TextButton", {Size=UDim2.new(0,52,0,24), Position=UDim2.new(1,-120,0.5,-12), BackgroundColor3=Colors.Card, Text="—", TextColor3=Colors.TextMuted, Font=Enum.Font.GothamMedium, TextSize=11, AutoButtonColor=false, ZIndex=3}, parent)
    corner(bindBtn,6); stroke(bindBtn,Colors.Border,1,0.5)
    local waiting = false
    bindBtn.MouseButton1Click:Connect(function() waiting=true bindBtn.Text="…" bindBtn.TextColor3=Colors.Accent end)
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if waiting and input.UserInputType==Enum.UserInputType.Keyboard then
            waiting=false
            if input.KeyCode==Enum.KeyCode.Escape then _G.FerBinds[prop]=nil bindBtn.Text="—"
            else _G.FerBinds[prop]=input.KeyCode bindBtn.Text=input.KeyCode.Name end
            bindBtn.TextColor3=Colors.TextMuted
        elseif not waiting and input.UserInputType==Enum.UserInputType.Keyboard then
            if _G.FerBinds[prop] and input.KeyCode==_G.FerBinds[prop] then
                C[prop]=not C[prop] refreshToggle(prop,button,status)
            end
        end
    end)
end

refreshToggle = function(prop, button, status)
    if not button or not status then return end
    local on = C[prop]
    pcall(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3=on and Colors.CardHover or Colors.Card}):Play()
        TweenService:Create(status, TweenInfo.new(0.2), {BackgroundColor3=on and Colors.Accent or Colors.BorderLight}):Play()
        local knob = status:FindFirstChild("Knob")
        if knob then TweenService:Create(knob, TweenInfo.new(0.2), {Position=on and UDim2.new(1,-20,0.5,-9) or UDim2.new(0,2,0.5,-9)}):Play() end
    end)
end

local function createToggle(label, prop, order, noBind)
    local b = N("TextButton", {Size=UDim2.new(1,0,0,42), BackgroundColor3=Colors.Card, Text="", AutoButtonColor=false, LayoutOrder=order, ZIndex=3}, Container)
    corner(b,10); regStroke(stroke(b,Colors.Border,1,0.5))
    local marker = N("Frame", {Size=UDim2.new(0,3,0,20), Position=UDim2.new(0,0,0.5,-10), BackgroundColor3=C[prop] and Colors.Accent or Colors.BorderLight, BorderSizePixel=0, ZIndex=4}, b)
    corner(marker,2)
    local lbl = N("TextLabel", {Size=UDim2.new(1, noBind and -70 or -180, 1,0), Position=UDim2.new(0,18,0,0), BackgroundTransparency=1, Text=label, TextColor3=Colors.Text, Font=Enum.Font.GothamMedium, TextSize=13, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=4}, b)
    regLabel(lbl,"text")
    local status = N("Frame", {Size=UDim2.new(0,38,0,22), Position=UDim2.new(1,-50,0.5,-11), BackgroundColor3=C[prop] and Colors.Accent or Colors.BorderLight, BorderSizePixel=0, ZIndex=4}, b)
    corner(status,11)
    local knob = N("Frame", {Name="Knob", Size=UDim2.new(0,18,0,18), Position=C[prop] and UDim2.new(1,-20,0.5,-9) or UDim2.new(0,2,0.5,-9), BackgroundColor3=Color3.new(1,1,1), BorderSizePixel=0, ZIndex=5}, status)
    corner(knob,9)
    b.MouseButton1Click:Connect(function()
        C[prop]=not C[prop]
        refreshToggle(prop,b,status)
        TweenService:Create(marker, TweenInfo.new(0.2), {BackgroundColor3=C[prop] and Colors.Accent or Colors.BorderLight}):Play()
    end)
    if not noBind then createBindBtn(b, prop, b, status) end
    return b
end

local function createSlider(label, prop, min, max, order)
    local f = N("Frame", {Size=UDim2.new(1,0,0,56), BackgroundColor3=Colors.Card, LayoutOrder=order, BorderSizePixel=0, ZIndex=3}, Container)
    corner(f,10); regStroke(stroke(f,Colors.Border,1,0.5))
    N("TextLabel", {Size=UDim2.new(1,-110,0,18), Position=UDim2.new(0,18,0,10), BackgroundTransparency=1, Text=label, TextColor3=Colors.Text, Font=Enum.Font.GothamMedium, TextSize=12, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=4}, f)
    local valLbl = N("TextLabel", {Size=UDim2.new(0,90,0,18), Position=UDim2.new(1,-108,0,10), BackgroundTransparency=1, Text=tostring(C[prop]), TextColor3=Colors.Accent, Font=Enum.Font.GothamBold, TextSize=12, TextXAlignment=Enum.TextXAlignment.Right, ZIndex=4}, f)
    regAccent(valLbl)
    local barBg = N("Frame", {Size=UDim2.new(1,-36,0,6), Position=UDim2.new(0,18,0,38), BackgroundColor3=Colors.BorderLight, BorderSizePixel=0, ZIndex=4}, f)
    corner(barBg,3)
    local fill = N("Frame", {Size=UDim2.new((C[prop]-min)/(max-min),0,1,0), BackgroundColor3=Colors.Accent, BorderSizePixel=0, ZIndex=5}, barBg)
    corner(fill,3) table.insert(Themed.fills, fill)
    local thumb = N("Frame", {Size=UDim2.new(0,14,0,14), Position=UDim2.new((C[prop]-min)/(max-min),0,0.5,-7), BackgroundColor3=Color3.new(1,1,1), BorderSizePixel=0, ZIndex=6}, barBg)
    corner(thumb,7)
    local trigger = N("TextButton", {Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Text="", ZIndex=7}, barBg)
    local dragging = false
    local function update(input)
        local pos = math.clamp((input.Position.X - barBg.AbsolutePosition.X) / barBg.AbsoluteSize.X, 0, 1)
        local val = min + (max-min)*pos
        val = (max>5) and math.floor(val) or math.floor(val*100)/100
        C[prop] = val
        fill.Size = UDim2.new(pos,0,1,0)
        thumb.Position = UDim2.new(pos,-7,0.5,-7)
        valLbl.Text = tostring(val)
    end
    trigger.InputBegan:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=true update(input) end end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=false end end)
    UserInputService.InputChanged:Connect(function(input) if dragging and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then update(input) end end)
    return f
end

local function createActionBtn(label, cb, order)
    local b = N("TextButton", {Size=UDim2.new(1,0,0,38), BackgroundColor3=Colors.Card, Text="", AutoButtonColor=false, LayoutOrder=order, ZIndex=3}, Container)
    corner(b,10); regStroke(stroke(b,Colors.Border,1,0.5))
    N("TextLabel", {Size=UDim2.new(1,-40,1,0), Position=UDim2.new(0,18,0,0), BackgroundTransparency=1, Text=label, TextColor3=Colors.Text, Font=Enum.Font.GothamMedium, TextSize=13, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=4}, b)
    b.MouseButton1Click:Connect(cb)
    return b
end

-- ============ NAPOLNENIE ============
local O = 0
local function nextO() O=O+1 return O end
local function addTo(tab, obj) if obj then table.insert(Tabs[tab], obj) obj.Visible=false end end

createTabBtn("AIM","Aimbot",1)
createTabBtn("VISUALS","ESP",2)
createTabBtn("PLAYER","Player",3)
createTabBtn("WORLD","World",4)
createTabBtn("MISC","Misc",5)

addTo("AIM", createCategory("АИМБОТ", nextO()))
addTo("AIM", createToggle("Silent Aim", "SilentAim", nextO()))
addTo("AIM", createToggle("Обычный Аим", "AimBot", nextO()))
addTo("AIM", createToggle("Team Check", "TeamCheck", nextO()))
addTo("AIM", createToggle("Wall Check", "WallCheck", nextO()))
addTo("AIM", createToggle("AutoShoot", "AutoShoot", nextO()))
addTo("AIM", createSlider("Задержка выстрела","AutoShootDelay",0.01,0.5,nextO()))
addTo("AIM", createSlider("Плавность","Smooth",0.01,1,nextO()))
addTo("AIM", createSlider("FOV","FOV",20,800,nextO()))
addTo("AIM", createToggle("Show FOV", "ShowFOV", nextO()))

addTo("VISUALS", createCategory("PLAYER ESP", nextO()))
addTo("VISUALS", createToggle("ESP", "ESP", nextO()))
addTo("VISUALS", createToggle("Box", "ESPBox", nextO(), true))
addTo("VISUALS", createToggle("Name", "ESPName", nextO(), true))
addTo("VISUALS", createToggle("Distance", "ESPDist", nextO(), true))
addTo("VISUALS", createToggle("Skeleton", "ESPSkeleton", nextO(), true))
addTo("VISUALS", createToggle("Health Bar", "ESPHP", nextO(), true))
addTo("VISUALS", createToggle("HP Number", "ESPHPNum", nextO(), true))
addTo("VISUALS", createToggle("Tracers", "ESPTracers", nextO(), true))
addTo("VISUALS", createToggle("Head Circle", "ESPHead", nextO(), true))
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

addTo("PLAYER", createCategory("PLAYER", nextO()))
addTo("PLAYER", createToggle("Inf Jump", "InfJump", nextO()))
addTo("PLAYER", createToggle("Anti AFK", "AntiAFK", nextO()))
addTo("PLAYER", createToggle("Third Person", "ThirdPerson", nextO()))
addTo("PLAYER", createSlider("Third Dist","ThirdPersonDist",3,50,nextO()))

addTo("WORLD", createCategory("WORLD", nextO()))
addTo("WORLD", createToggle("No Bullet Drop", "NoBulletDrop", nextO()))

addTo("WORLD", createCategory("OPTIMIZATION", nextO()))
addTo("WORLD", createToggle("Low GFX (всё)", "OptLowGFX", nextO()))
addTo("WORLD", createToggle("No Effects", "OptNoEffects", nextO()))
addTo("WORLD", createToggle("No Particles", "OptNoParticles", nextO()))
addTo("WORLD", createToggle("No Decals", "OptNoDecals", nextO()))
addTo("WORLD", createToggle("No Shadows", "OptNoShadows", nextO()))
addTo("WORLD", createToggle("Far Parts", "OptFarParts", nextO()))
addTo("WORLD", createToggle("Low Terrain", "OptLowTerrain", nextO()))
addTo("WORLD", createToggle("No Sounds", "OptNoSounds", nextO()))
addTo("WORLD", createSlider("Render Dist","OptRenderDist",100,5000,nextO()))

addTo("MISC", createCategory("THEME", nextO()))
addTo("MISC", createActionBtn("Midnight", function() ApplyTheme("Midnight") end, nextO()))
addTo("MISC", createActionBtn("Obsidian", function() ApplyTheme("Obsidian") end, nextO()))
addTo("MISC", createActionBtn("Rose Quartz", function() ApplyTheme("RoseQuartz") end, nextO()))
addTo("MISC", createActionBtn("Arctic", function() ApplyTheme("Arctic") end, nextO()))

-- ============ THEME APPLY ============
function ApplyTheme(name)
    local th = Themes[name] if not th then return end
    Colors = th CurrentTheme = name
    for _, it in ipairs(Themed.frames) do pcall(function()
        if it.kind=="bg" then it.inst.BackgroundColor3=th.Background
        elseif it.kind=="sidebar" then it.inst.BackgroundColor3=th.Sidebar
        elseif it.kind=="panel" then it.inst.BackgroundColor3=th.Panel end
    end) end
    for _, it in ipairs(Themed.labels) do pcall(function()
        if it.kind=="text" then it.inst.TextColor3=th.Text
        elseif it.kind=="dim" then it.inst.TextColor3=th.TextDim
        elseif it.kind=="muted" then it.inst.TextColor3=th.TextMuted end
    end) end
    for _, s in ipairs(Themed.strokes) do pcall(function() s.Color=th.Border end) end
    for _, it in ipairs(Themed.buttons) do pcall(function() it.inst.BackgroundColor3=(it.prop and C[it.prop]) and th.CardHover or th.Card end) end
    for _, it in ipairs(Themed.accents) do pcall(function() it.inst.BackgroundColor3=th.Accent end) end
    for _, f in ipairs(Themed.fills) do pcall(function() f.BackgroundColor3=th.Accent end) end
    pcall(function() TitleLogo.BackgroundColor3=th.Accent end)
    showTab(CurrentTab)
end

-- ============ МЕНЮ TOGGLE ============
local menuOpen = false
local function toggleMenu()
    menuOpen = not menuOpen
    if menuOpen then
        M.Visible = true
        if Blur then TweenService:Create(Blur, TweenInfo.new(0.35), {Size=14}):Play() end
        TweenService:Create(M, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position=isMobile and UDim2.new(0.5,-270,0.5,-200) or UDim2.new(0.5,-360,0.5,-250)}):Play()
    else
        if Blur then TweenService:Create(Blur, TweenInfo.new(0.3), {Size=0}):Play() end
        local tw = TweenService:Create(M, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Position=isMobile and UDim2.new(0.5,-270,0,-420) or UDim2.new(0.5,-360,0,-520)})
        tw:Play() tw.Completed:Connect(function() if not menuOpen then M.Visible=false end end)
    end
end

-- ============ F-КНОПКА ============
local OpenBtn
if isMobile then
    OpenBtn = N("TextButton", {Size=UDim2.new(0,36,0,36), Position=UDim2.new(0,12,0.42,0), BackgroundColor3=Colors.Sidebar, Text="F", TextColor3=Colors.Accent, Font=Enum.Font.GothamBold, TextSize=16, AutoButtonColor
