--[[ FerClient v16.0 | Full UI + Silent Walk + All Features ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local Stats = game:GetService("Stats")
local SoundService = game:GetService("SoundService")
local LP = Players.LocalPlayer

local isMobile = UserInputService.TouchEnabled
local function GetCamera() local cam = workspace.CurrentCamera; if cam and cam.Parent then return cam end; return nil end

-- Кастомные обертки
if not newcclosure then getgenv().newcclosure = function(f) return f end end
if not checkcaller then getgenv().checkcaller = function() return false end end
if not hookmetamethod then getgenv().hookmetamethod = function() end end
if not getnamecallmethod then getgenv().getnamecallmethod = function() return "" end end

-- ТЕМЫ
local Themes = {
    Midnight = {Accent=Color3.fromRGB(150,110,255), AccentSoft=Color3.fromRGB(80,60,140), Background=Color3.fromRGB(12,12,16), Sidebar=Color3.fromRGB(18,18,24), Panel=Color3.fromRGB(22,22,30), Card=Color3.fromRGB(28,28,38), CardHover=Color3.fromRGB(38,38,50), Text=Color3.fromRGB(240,240,248), TextDim=Color3.fromRGB(150,150,165), TextMuted=Color3.fromRGB(100,100,115), Border=Color3.fromRGB(38,38,50), BorderLight=Color3.fromRGB(50,50,66)}
}
local Colors = Themes.Midnight
local Themed = {frames={},labels={},strokes={},buttons={},accents={},fills={},knobs={},markers={}}
local function regFrame(i,k) table.insert(Themed.frames,{inst=i,kind=k or "panel"}) end
local function regLabel(i,k) table.insert(Themed.labels,{inst=i,kind=k or "text"}) end
local function regStroke(i) table.insert(Themed.strokes,i) end
local function regAccent(i) table.insert(Themed.accents,i) end

-- СОСТОЯНИЕ
local C = {
    -- Aimbot
    SilentAim=false, AimPart="Head", FOV=150, TeamCheck=false, WallCheck=false, AutoShoot=false, AutoShootDelay=0.05,
    -- Visuals
    ESP=false, ESPBox=true, ESPName=true, ESPDist=true, ESPSkeleton=false, ESPHP=false, ESPHPNum=false, ESPTracers=false, ESPHead=false, ESPMaxDist=1000,
    ESPColor=Color3.fromRGB(0,200,255), ShowFOV=false, Fullbright=false, XRay=false, NoDeco=false,
    -- Resources
    SulfurESP=false, IronESP=false, StoneESP=false, OreDist=500, CrateESP=false, MilitaryESP=false, EliteESP=false, FoodESP=false, CrateDist=500, NpcESP=false, NpcDist=600,
    -- Player
    NoFallDamage=false, InfJump=false, AntiAFK=false, ThirdPerson=false, ThirdPersonDist=15, SilentWalk=false,
    -- World
    NoBulletDrop=false, OptLowGFX=false,
    -- Admin
    AdminList=false
}
_G.FerBinds = {}
local CurrentAimTarget = nil

-- CACHE
local PlayerCache = {}
local function CachePlayer(pl)
    if pl ~= LP then 
        PlayerCache[pl] = {Char=pl.Character, HRP=pl.Character and pl.Character:FindFirstChild("HumanoidRootPart")}
        pl.CharacterAdded:Connect(function(char) task.wait(1); PlayerCache[pl] = {Char=char, HRP=char:FindFirstChild("HumanoidRootPart")} end)
    end
end
for _, pl in ipairs(Players:GetPlayers()) do CachePlayer(pl) end
Players.PlayerAdded:Connect(CachePlayer)
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
local M = N("Frame", {Size=UDim2.new(0,720,0,500), Position=UDim2.new(0.5,-360,0.5,-250), BackgroundColor3=Colors.Background, BorderSizePixel=0, Visible=false, ClipsDescendants=false}, SG)
if isMobile then M.Size=UDim2.new(0,540,0,400) M.Position=UDim2.new(0.5,-270,0.5,-200) end
corner(M,14); regFrame(M,"bg"); regStroke(stroke(M, Colors.BorderLight, 1, 0.3))

local TitleBar = N("Frame", {Size=UDim2.new(1,0,0,44), BackgroundColor3=Colors.Sidebar, BorderSizePixel=0, ZIndex=2}, M)
corner(TitleBar,14); local fixCorner = N("Frame", {Size=UDim2.new(1,0,0,14), Position=UDim2.new(0,0,1,-14), BackgroundColor3=Colors.Sidebar, BorderSizePixel=0, ZIndex=2}, TitleBar)
regFrame(TitleBar,"sidebar"); regFrame(fixCorner,"sidebar")

local tlContainer = N("Frame", {Size=UDim2.new(0,60,0,12), Position=UDim2.new(0,16,0.5,-6), BackgroundTransparency=1, ZIndex=3}, TitleBar)
local function mkDot(color, order) local d=N("Frame",{Size=UDim2.new(0,12,0,12),Position=UDim2.new(0,(order-1)*18,0,0),BackgroundColor3=color,BorderSizePixel=0,ZIndex=3},tlContainer); corner(d,6); return d end
local dotClose = mkDot(Color3.fromRGB(255,95,87),1); mkDot(Color3.fromRGB(255,189,68),2); mkDot(Color3.fromRGB(40,200,65),3)
local closeClick = N("TextButton", {Size=UDim2.new(0,12,0,12), BackgroundTransparency=1, Text="", ZIndex=4}, dotClose)
closeClick.MouseButton1Click:Connect(function() if M then M.Visible=false; if Blur then TweenService:Create(Blur,TweenInfo.new(0.3),{Size=0}):Play() end end end)

local TitleLogo = N("TextLabel", {Size=UDim2.new(0,26,0,26), Position=UDim2.new(0,92,0.5,-13), BackgroundColor3=Colors.Accent, Text="F", TextColor3=Color3.new(1,1,1), Font=Enum.Font.GothamBold, TextSize=15, ZIndex=3}, TitleBar)
corner(TitleLogo,8); regAccent(TitleLogo)
local Title = N("TextLabel", {Size=UDim2.new(1,-300,1,0), Position=UDim2.new(0,126,0,0), BackgroundTransparency=1, Text="FerClient", TextColor3=Colors.Text, Font=Enum.Font.GothamBold, TextSize=15, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=3}, TitleBar)
regLabel(Title,"text")
local SubTitle = N("TextLabel", {Size=UDim2.new(0,200,1,0), Position=UDim2.new(1,-290,0,0), BackgroundTransparency=1, Text="v16.0 • Silent Walk", TextColor3=Colors.TextMuted, Font=Enum.Font.Gotham, TextSize=11, TextXAlignment=Enum.TextXAlignment.Right, ZIndex=3}, TitleBar)
regLabel(SubTitle,"muted")

local Sidebar = N("Frame", {Size=UDim2.new(0,168,1,-60), Position=UDim2.new(0,10,0,50), BackgroundColor3=Colors.Sidebar, BorderSizePixel=0, ZIndex=2}, M)
corner(Sidebar,12); regFrame(Sidebar,"sidebar"); regStroke(stroke(Sidebar,Colors.Border,1,0.5))
N("UIListLayout", {Padding=UDim.new(0,4), SortOrder=Enum.SortOrder.LayoutOrder}, Sidebar); padding(Sidebar,8,10)
N("TextLabel", {Size=UDim2.new(1,0,0,20), BackgroundTransparency=1, Text="НАВИГАЦИЯ", TextColor3=Colors.TextMuted, Font=Enum.Font.GothamMedium, TextSize=10, TextXAlignment=Enum.TextXAlignment.Left, LayoutOrder=0}, Sidebar)

local Container = N("ScrollingFrame", {Position=UDim2.new(0,188,0,50), Size=UDim2.new(1,-198,1,-60), BackgroundColor3=Colors.Panel, BorderSizePixel=0, ScrollBarThickness=isMobile and 0 or 4, ScrollBarImageColor3=Colors.Accent, ScrollBarImageTransparency=0.4, CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y, ZIndex=2}, M)
corner(Container,12); regFrame(Container,"panel"); regStroke(stroke(Container,Colors.Border,1,0.5)); padding(Container,14)
N("UIListLayout", {Padding=UDim.new(0,6), SortOrder=Enum.SortOrder.LayoutOrder}, Container)

local Tabs = {VISUALS={}, AIM={}, PLAYER={}, WORLD={}, MISC={}}
local tabButtons = {}
local CurrentTab = "AIM"
local function showTab(name)
    CurrentTab = name
    for t, objs in pairs(Tabs) do for _, o in ipairs(objs) do o.Visible=(t==name) end end
    for k, b in pairs(tabButtons) do b.TextColor3 = (k==name) and Colors.Accent or Colors.TextDim end
end

local function createTabBtn(name, label, order)
    local b = N("TextButton", {Size=UDim2.new(1,0,0,36), BackgroundColor3=Colors.Sidebar, Text=label, TextColor3=Colors.TextDim, Font=Enum.Font.GothamMedium, TextSize=13, AutoButtonColor=false, LayoutOrder=order, ZIndex=3}, Sidebar)
    corner(b,8); tabButtons[name]=b; b.MouseButton1Click:Connect(function() showTab(name) end)
end

local function createCategory(title, order)
    local f = N("Frame", {Size=UDim2.new(1,0,0,26), BackgroundTransparency=1, LayoutOrder=order}, Container); padding(f,4,0)
    local l = N("TextLabel", {Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Text=title, TextColor3=Colors.TextDim, Font=Enum.Font.GothamMedium, TextSize=11, TextXAlignment=Enum.TextXAlignment.Left}, f)
    return f
end

local refreshToggle
local function createBindBtn(parent, prop, button, status)
    local bindBtn = N("TextButton", {Size=UDim2.new(0,52,0,24), Position=UDim2.new(1,-120,0.5,-12), BackgroundColor3=Colors.Card, Text="—", TextColor3=Colors.TextMuted, Font=Enum.Font.GothamMedium, TextSize=11, AutoButtonColor=false, ZIndex=3}, parent)
    corner(bindBtn,6); stroke(bindBtn,Colors.Border,1,0.5); local waiting = false
    bindBtn.MouseButton1Click:Connect(function() waiting=true; bindBtn.Text="…"; bindBtn.TextColor3=Colors.Accent end)
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if waiting and input.UserInputType==Enum.UserInputType.Keyboard then
            waiting=false; if input.KeyCode==Enum.KeyCode.Escape then _G.FerBinds[prop]=nil; bindBtn.Text="—" else _G.FerBinds[prop]=input.KeyCode; bindBtn.Text=input.KeyCode.Name end; bindBtn.TextColor3=Colors.TextMuted
        elseif not waiting and input.UserInputType==Enum.UserInputType.Keyboard then
            if _G.FerBinds[prop] and input.KeyCode==_G.FerBinds[prop] then C[prop]=not C[prop]; refreshToggle(prop,button,status) end
        end
    end)
end

refreshToggle = function(prop, button, status)
    if not button or not status then return end; local on = C[prop]
    pcall(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3=on and Colors.CardHover or Colors.Card}):Play()
        TweenService:Create(status, TweenInfo.new(0.2), {BackgroundColor3=on and Colors.Accent or Colors.BorderLight}):Play()
        local knob = status:FindFirstChild("Knob"); if knob then TweenService:Create(knob, TweenInfo.new(0.2), {Position=on and UDim2.new(1,-20,0.5,-9) or UDim2.new(0,2,0.5,-9)}):Play() end
    end)
end

local function createToggle(label, prop, order, noBind)
    local b = N("TextButton", {Size=UDim2.new(1,0,0,42), BackgroundColor3=Colors.Card, Text="", AutoButtonColor=false, LayoutOrder=order, ZIndex=3}, Container)
    corner(b,10); regStroke(stroke(b,Colors.Border,1,0.5))
    local marker = N("Frame", {Size=UDim2.new(0,3,0,20), Position=UDim2.new(0,0,0.5,-10), BackgroundColor3=C[prop] and Colors.Accent or Colors.BorderLight, BorderSizePixel=0, ZIndex=4}, b)
    corner(marker,2); local lbl = N("TextLabel", {Size=UDim2.new(1, noBind and -70 or -180, 1,0), Position=UDim2.new(0,18,0,0), BackgroundTransparency=1, Text=label, TextColor3=Colors.Text, Font=Enum.Font.GothamMedium, TextSize=13, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=4}, b)
    regLabel(lbl,"text"); local status = N("Frame", {Size=UDim2.new(0,38,0,22), Position=UDim2.new(1,-50,0.5,-11), BackgroundColor3=C[prop] and Colors.Accent or Colors.BorderLight, BorderSizePixel=0, ZIndex=4}, b)
    corner(status,11); local knob = N("Frame", {Name="Knob", Size=UDim2.new(0,18,0,18), Position=C[prop] and UDim2.new(1,-20,0.5,-9) or UDim2.new(0,2,0.5,-9), BackgroundColor3=Color3.new(1,1,1), BorderSizePixel=0, ZIndex=5}, status)
    corner(knob,9); b.MouseButton1Click:Connect(function()
        C[prop]=not C[prop]; refreshToggle(prop,b,status); TweenService:Create(marker, TweenInfo.new(0.2), {BackgroundColor3=C[prop] and Colors.Accent or Colors.BorderLight}):Play()
    end)
    if not noBind then createBindBtn(b, prop, b, status) end; return b
end

local function createSlider(label, prop, min, max, order)
    local f = N("Frame", {Size=UDim2.new(1,0,0,56), BackgroundColor3=Colors.Card, LayoutOrder=order, BorderSizePixel=0, ZIndex=3}, Container)
    corner(f,10); regStroke(stroke(f,Colors.Border,1,0.5)); N("TextLabel", {Size=UDim2.new(1,-110,0,18), Position=UDim2.new(0,18,0,10), BackgroundTransparency=1, Text=label, TextColor3=Colors.Text, Font=Enum.Font.GothamMedium, TextSize=12, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=4}, f)
    local valLbl = N("TextLabel", {Size=UDim2.new(0,90,0,18), Position=UDim2.new(1,-108,0,10), BackgroundTransparency=1, Text=tostring(C[prop]), TextColor3=Colors.Accent, Font=Enum.Font.GothamBold, TextSize=12, TextXAlignment=Enum.TextXAlignment.Right, ZIndex=4}, f)
    regAccent(valLbl); local barBg = N("Frame", {Size=UDim2.new(1,-36,0,6), Position=UDim2.new(0,18,0,38), BackgroundColor3=Colors.BorderLight, BorderSizePixel=0, ZIndex=4}, f)
    corner(barBg,3); local fill = N("Frame", {Size=UDim2.new((C[prop]-min)/(max-min),0,1,0), BackgroundColor3=Colors.Accent, BorderSizePixel=0, ZIndex=5}, barBg)
    corner(fill,3); table.insert(Themed.fills, fill); local thumb = N("Frame", {Size=UDim2.new(0,14,0,14), Position=UDim2.new((C[prop]-min)/(max-min),0,0.5,-7), BackgroundColor3=Color3.new(1,1,1), BorderSizePixel=0, ZIndex=6}, barBg)
    corner(thumb,7); local trigger = N("TextButton", {Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Text="", ZIndex=7}, barBg); local dragging = false
    local function update(input)
        local pos = math.clamp((input.Position.X - barBg.AbsolutePosition.X) / barBg.AbsoluteSize.X, 0, 1); local val = min + (max-min)*pos
        val = (max>5) and math.floor(val) or math.floor(val*100)/100; C[prop] = val; fill.Size = UDim2.new(pos,0,1,0); thumb.Position = UDim2.new(pos,-7,0.5,-7); valLbl.Text = tostring(val)
    end
    trigger.InputBegan:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=true; update(input) end end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=false end end)
    UserInputService.InputChanged:Connect(function(input) if dragging and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then update(input) end end)
    return f
end

local O = 0; local function nextO() O=O+1; return O end
local function addTo(tab, obj) if obj then table.insert(Tabs[tab], obj); obj.Visible=false end end

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
addTo("PLAYER", createToggle("God Mode (No Fall Dmg)", "NoFallDamage", nextO()))
addTo("PLAYER", createToggle("Silent Walk (No Steps)", "SilentWalk", nextO())) -- НОВАЯ ФУНКЦИЯ
addTo("PLAYER", createToggle("Third Person", "ThirdPerson", nextO()))
addTo("PLAYER", createSlider("Third Dist","ThirdPersonDist",3,50,nextO()))

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
local AdminTitle = N("TextLabel", {Size=UDim2.new(1,0,0,26), BackgroundTransparency=1, Text="Admins Online", TextColor3=Colors.Text, Font=Enum.Font.GothamBold, TextSize=13}, AdminFrame)
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

-- ============ SILENT WALK LOGIC ============
local NoFootsteps = {
    Enabled = false,
    OldVolumes = setmetatable({}, { __mode = "k" })
}
function NoFootsteps:MuteSound(sound)
    if not self.Enabled then return end
    if not sound:IsA("Sound") then return end
    if self.OldVolumes[sound] == nil then self.OldVolumes[sound] = sound.Volume end
    sound.Volume = 0
    sound:Stop()
end
function NoFootsteps:MuteFootstepFolder()
    if not self.Enabled then return end
    local folder = SoundService:FindFirstChild("FootstepSounds")
    if not folder then return end
    for _, obj in ipairs(folder:GetDescendants()) do if obj:IsA("Sound") then self:MuteSound(obj) end end
end
function NoFootsteps:MuteCharacter(char)
    if not self.Enabled then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    for _, obj in ipairs(root:GetChildren()) do if obj:IsA("Sound") then self:MuteSound(obj) end end
end
function NoFootsteps:Set(state)
    self.Enabled = state == true
    if self.Enabled then
        self:MuteFootstepFolder()
        if LP.Character then self:MuteCharacter(LP.Character) end
    else
        for sound, oldVolume in pairs(self.OldVolumes) do
            if sound and sound.Parent and sound:IsA("Sound") then sound.Volume = oldVolume end
        end
        table.clear(self.OldVolumes)
    end
end
RunService.Heartbeat:Connect(function()
    if not NoFootsteps.Enabled then return end
    NoFootsteps:MuteFootstepFolder()
    if LP.Character then NoFootsteps:MuteCharacter(LP.Character) end
end)
LP.CharacterAdded:Connect(function(char) task.wait(1); NoFootsteps:MuteCharacter(char) end)

-- ============ LOGIC ============
local function isVisible(targetPart, targetChar)
    if not C.WallCheck then return true end
    local char = LP.Character if not char then return false end
    local params = RaycastParams.new(); params.FilterType = Enum.RaycastFilterType.Exclude; params.FilterDescendantsInstances = {char, targetChar}
    local cam = GetCamera() if not cam then return false end
    return workspace:Raycast(cam.CFrame.Position, (targetPart.Position - cam.CFrame.Position), params) == nil
end

local function GetNearest()
    local cam = GetCamera() if not cam then return nil end
    local center = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
    local target, mag = nil, math.huge
    for pl, data in pairs(PlayerCache) do
        if pl ~= LP then
            local char = data.Char; local hrp = data.HRP
            if char and hrp and hrp.Parent then
                if not (C.TeamCheck and pl.Team == LP.Team) then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health > 0 then
                        local part = char:FindFirstChild(C.AimPart) or char:FindFirstChild("Head") or hrp
                        local sp, on = cam:WorldToViewportPoint(part.Position)
                        if on then
                            local dist = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                            if dist < mag and dist < C.FOV then if isVisible(part, char) then mag, target = dist, {pl=pl, part=part, char=char} end end
                        end
                    end
                end
            end
        end
    end
    return target
end

-- Хук
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if method == "Raycast" and self == Workspace then
        if not checkcaller() then
            local args = {...}; local origin = args[1]; local direction = args[2]
            if typeof(origin) == "Vector3" and typeof(direction) == "Vector3" then
                local mag = direction.Magnitude
                if mag > 50 and C.SilentAim and CurrentAimTarget and CurrentAimTarget.part then
                    local newDir = (CurrentAimTarget.part.Position - origin).Unit * mag
                    return oldNamecall(self, origin, newDir, args[3])
                end
            end
        end
    end
    return oldNamecall(self, ...)
end))

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
local function removeESP(p) local e = ESP[p]; if not e then return end; for _,d in pairs(e) do if d and d.Remove then pcall(function() d:Remove() end) end end; ESP[p] = nil end
local function createESP(p)
    if p == LP or ESP[p] or not hasDrawing then return end
    local e = {}
    local ok = pcall(function()
        e.box = {Drawing.new("Line"),Drawing.new("Line"),Drawing.new("Line"),Drawing.new("Line")}
        e.name = Drawing.new("Text"); e.dist = Drawing.new("Text"); e.hpBg = Drawing.new("Line"); e.hpFill = Drawing.new("Line"); e.hpNum = Drawing.new("Text"); e.tracer = Drawing.new("Line"); e.head = Drawing.new("Circle"); e.bones = {Drawing.new("Line"),Drawing.new("Line"),Drawing.new("Line"),Drawing.new("Line"),Drawing.new("Line"),Drawing.new("Line")}
    end)
    if not ok then removeESP(p); return end
    for _,l in ipairs(e.box) do l.Thickness=1; l.Color=C.ESPColor; l.Visible=false end
    e.name.Size=13; e.name.Center=true; e.name.Outline=true; e.name.Font=2; e.name.Color=C.ESPColor
    e.dist.Size=11; e.dist.Center=true; e.dist.Outline=true; e.dist.Font=2; e.dist.Color=C.ESPColor
    e.hpBg.Thickness=3; e.hpBg.Visible=false; e.hpFill.Thickness=3; e.hpFill.Visible=false; e.hpNum.Size=11; e.hpNum.Center=true; e.hpNum.Outline=true; e.hpNum.Font=2; e.hpNum.Color=Color3.new(1,1,1)
    e.tracer.Thickness=1; e.tracer.Color=C.ESPColor; e.head.Thickness=2; e.head.NumSides=24; e.head.Filled=false
    for _,b in ipairs(e.bones) do b.Thickness=1; b.Color=C.ESPColor end
    ESP[p] = e
end
for _,p in ipairs(Players:GetPlayers()) do createESP(p) end
Players.PlayerAdded:Connect(function(p) task.wait(1); createESP(p) end)
Players.PlayerRemoving:Connect(function(p) removeESP(p) end)

-- ============ FALL DAMAGE FIX ============
local function setupNFD(char)
    local hrp = char:WaitForChild("HumanoidRootPart", 5)
    if not hrp then return end
    RunService.Heartbeat:Connect(function()
        if not C.NoFallDamage then return end
        if not hrp.Parent then return end
        local vel = hrp.AssemblyLinearVelocity
        if vel.Y < -50 then
            hrp.AssemblyLinearVelocity = Vector3.new(vel.X, -10, vel.Z)
        end
    end)
end
if LP.Character then setupNFD(LP.Character) end
LP.CharacterAdded:Connect(setupNFD)

-- ============ MAIN RENDER ============
RunService.RenderStepped:Connect(function()
    local cam = GetCamera(); if not cam then return end
    local now = tick()

    if C.AdminList then
        AdminFrame.Visible = true
        local totalSize = 26
        for _, v in ipairs(AdminListContainer:GetChildren()) do if v:IsA("TextLabel") then totalSize += 24 end end
        AdminFrame.Size = UDim2.new(0, 200, 0, totalSize)
    else
        AdminFrame.Visible = false
    end

    if C.SilentAim then
        CurrentAimTarget = GetNearest()
        if C.AutoShoot and CurrentAimTarget then tryAutoShoot(CurrentAimTarget) end
    else CurrentAimTarget = nil end

    if hasDrawing then
        for pl, e in pairs(ESP) do
            local char = pl.Character; local hrp = char and char:FindFirstChild("HumanoidRootPart"); local hum = char and char:FindFirstChildOfClass("Humanoid"); local head = char and char:FindFirstChild("Head")
            local draw = false
            if C.ESP and hrp and hum and hum.Health > 0 then
                local ps, on = cam:WorldToViewportPoint(hrp.Position)
                if on and ps.Z <= C.ESPMaxDist then
                    draw = true
                    local sy = 4500/ps.Z; local sx = 2800/ps.Z; local x, y = ps.X - sx/2, ps.Y - sy/2
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
                    e.hpNum.Visible = C.ESPHPNum
                    if C.ESPHPNum then e.hpNum.Text = math.floor(hum.Health).." / "..math.floor(hum.MaxHealth); e.hpNum.Position = Vector2.new(ps.X, y+sy+4) end
                    e.name.Visible = C.ESPName
                    if C.ESPName then e.name.Text = pl.DisplayName; e.name.Position = Vector2.new(ps.X, y-34); e.name.Color = C.ESPColor end
                    e.dist.Visible = C.ESPDist
                    if C.ESPDist then e.dist.Text = "["..math.floor(ps.Z).."m]"; e.dist.Position = Vector2.new(ps.X, y-18) end
                    e.tracer.Visible = C.ESPTracers
                    if C.ESPTracers then e.tracer.From = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y); e.tracer.To = Vector2.new(ps.X, ps.Y); e.tracer.Color = C.ESPColor end
                    e.head.Visible = C.ESPHead
                    if C.ESPHead and head then
                        local hps, hon = cam:WorldToViewportPoint(head.Position)
                        if hon then e.head.Position = Vector2.new(hps.X, hps.Y); e.head.Radius = 10; e.head.Color = C.ESPColor else e.head.Visible = false end
                    end
                    local skel = C.ESPSkeleton
                    for _,b in ipairs(e.bones) do b.Visible = false end
                    if skel then
                        local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
                        local larm = char:FindFirstChild("LeftUpperArm") or char:FindFirstChild("Left Arm") or char:FindFirstChild("LeftHand")
                        local rarm = char:FindFirstChild("RightUpperArm") or char:FindFirstChild("Right Arm") or char:FindFirstChild("RightHand")
                        local lleg = char:FindFirstChild("LeftUpperLeg") or char:FindFirstChild("Left Leg") or char:FindFirstChild("LeftFoot")
                        local rleg = char:FindFirstChild("RightUpperLeg") or char:FindFirstChild("Right Leg") or char:FindFirstChild("RightFoot")
                        local function to2d(part) if not part then return nil end local sp, on2 = cam:WorldToViewportPoint(part.Position) if on2 then return Vector2.new(sp.X, sp.Y) end return nil end
                        local h2d, t2d, hrp2d = to2d(head), to2d(torso), to2d(hrp)
                        if h2d and hrp2d then e.bones[1].From,e.bones[1].To = h2d,hrp2d; e.bones[1].Visible=true end
                        if t2d and hrp2d then e.bones[2].From,e.bones[2].To = t2d,hrp2d; e.bones[2].Visible=true end
                        if t2d and larm then local p=to2d(larm) if p then e.bones[3].From,e.bones[3].To = t2d,p; e.bones[3].Visible=true end end
                        if t2d and rarm then local p=to2d(rarm) if p then e.bones[4].From,e.bones[4].To = t2d,p; e.bones[4].Visible=true end end
                        if hrp2d and lleg then local p=to2d(lleg) if p then e.bones[5].From,e.bones[5].To = hrp2d,p; e.bones[5].Visible=true end end
                        if hrp2d and rleg then local p=to2d(rleg) if p then e.bones[6].From,e.bones[6].To = hrp2d,p; e.bones[6].Visible=true end end
                    end
                end
            end
            if not draw then for _,l in ipairs(e.box) do l.Visible=false end; e.name.Visible=false; e.dist.Visible=false; e.hpBg.Visible=false; e.hpFill.Visible=false; e.hpNum.Visible=false; e.tracer.Visible=false; e.head.Visible=false; for _,b in ipairs(e.bones) do b.Visible=false end end
        end
    end

    if C.Fullbright then Lighting.Ambient=Color3.new(1,1,1); Lighting.OutdoorAmbient=Color3.new(1,1,1); Lighting.Brightness=2; Lighting.ClockTime=14; Lighting.FogEnd=100000; Lighting.GlobalShadows=false end
    if C.OptLowGFX then pcall(function() settings().Rendering.QualityLevel=Enum.QualityLevel.Level01 end); Lighting.GlobalShadows=false end
end)

-- ============ ОСТАЛЬНОЕ ============
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

-- F-КНОПКА
local OpenBtn = N("TextButton", {Size=UDim2.new(0,36,0,36), Position=UDim2.new(0,12,0.42,0), BackgroundColor3=Colors.Sidebar, Text="F", TextColor3=Colors.Accent, Font=Enum.Font.GothamBold, TextSize=16, AutoButtonColor=false, ZIndex=50}, SG)
corner(OpenBtn,18); stroke(OpenBtn, Colors.Accent, 1.5, 0.3)
local dragBtn, btnStart, posStart, moved = false, nil, nil, false
OpenBtn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragBtn = true; moved = false; btnStart = i.Position; posStart = OpenBtn.Position end end)
OpenBtn.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragBtn = false end end)
UserInputService.InputChanged:Connect(function(i) if dragBtn and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then local d = i.Position - btnStart; if math.abs(d.X) > 4 or math.abs(d.Y) > 4 then moved = true end; OpenBtn.Position = UDim2.new(posStart.X.Scale, posStart.X.Offset + d.X, posStart.Y.Scale, posStart.Y.Offset + d.Y) end end)
OpenBtn.MouseButton1Click:Connect(function() if moved then moved = false; return end; M.Visible = not M.Visible end)

local mdrag, mds, mdp = false, nil, nil
TitleBar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then mdrag=true; mds=i.Position; mdp=M.Position end end)
TitleBar.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then mdrag=false end end)
UserInputService.InputChanged:Connect(function(i) if mdrag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then local d=i.Position-mds; M.Position=UDim2.new(mdp.X.Scale,mdp.X.Offset+d.X,mdp.Y.Scale,mdp.Y.Offset+d.Y) end end)

UserInputService.InputBegan:Connect(function(input) if input.KeyCode == Enum.KeyCode.RightShift then M.Visible = not M.Visible end end)
showTab("AIM")
pcall(function() game:GetService("StarterGui"):SetCore("SendNotification", {Title="FerClient v16.0", Text="Silent Walk + Admin + Fall Dmg", Duration=4}) end)
print("[FerClient v16.0] Loaded.")
