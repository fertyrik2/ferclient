--[[ FerClient v8.0 | Delta Fix ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local LP = Players.LocalPlayer

local Core = {Destroyed = false, Registry = {Connections = {}, Instances = {}, Tweens = {}}}
function Core.SafeCall(cb, ...) local ok, res = pcall(cb, ...) if not ok then warn("[FerClient Error]", res) end return ok, res end
function Core.RegisterConnection(c) if Core.Destroyed then Core.SafeCall(function() c:Disconnect() end) return nil end table.insert(Core.Registry.Connections, c) return c end
function Core.RegisterInstance(i) if Core.Destroyed then Core.SafeCall(function() i:Destroy() end) return nil end table.insert(Core.Registry.Instances, i) return i end
function Core.RegisterTween(t) if Core.Destroyed then Core.SafeCall(function() t:Cancel() end) return nil end table.insert(Core.Registry.Tweens, t) return t end
function Core.Cleanup()
    if Core.Destroyed then return end
    Core.Destroyed = true
    for _, t in ipairs(Core.Registry.Tweens) do Core.SafeCall(function() t:Cancel() end) end
    for _, c in ipairs(Core.Registry.Connections) do Core.SafeCall(function() c:Disconnect() end) end
    for _, i in ipairs(Core.Registry.Instances) do Core.SafeCall(function() i:Destroy() end) end
    table.clear(Core.Registry.Tweens) table.clear(Core.Registry.Connections) table.clear(Core.Registry.Instances)
    print("[FerClient] Cleanup completed")
end
_G.FerClientCleanup = Core.Cleanup

local Config = {
    AimBot = false, AimPart = "Head", Smooth = 0.35, FOV = 150, MaxDist = 500, WallCheck = false, TeamCheck = false,
    ESP = false, ESPBox = true, ESPName = true, ESPDist = true, ESPMaxDist = 1000, ShowFOV = false
}
local PlayerCache = {}
local CurrentTarget = nil

local function N(class, props, parent) local o = Instance.new(class) for k, v in pairs(props or {}) do o[k] = v end if parent then o.Parent = parent end return o end
local function GetCamera() local cam = Workspace.CurrentCamera if cam and cam.Parent then return cam end return nil end

local UI = {SG = nil, Main = nil, TabBtns = {}, Tabs = {}}
local ACC = Color3.fromRGB(0,170,255)
local BG = Color3.fromRGB(15,15,20)
local PANEL = Color3.fromRGB(22,22,30)
local P2 = Color3.fromRGB(30,30,40)
local TXT = Color3.fromRGB(235,235,245)
local SUB = Color3.fromRGB(150,150,165)
local OFF = Color3.fromRGB(60,60,75)

local function CreateUI()
    UI.SG = N("ScreenGui", {Name="FerUI", ResetOnSpawn=false, IgnoreGuiInset=true, ZIndexBehavior=Enum.ZIndexBehavior.Sibling}, CoreGui)
    Core.RegisterInstance(UI.SG)

    local AV = N("ImageButton", {Size=UDim2.new(0,40,0,40), Position=UDim2.new(0,20,0.5,-20), BackgroundColor3=BG, AutoButtonColor=false, BorderSizePixel=0, ZIndex=50}, UI.SG)
    N("UICorner", {CornerRadius=UDim.new(1,0)}, AV)
    N("UIStroke", {Color=ACC, Thickness=2}, AV)
    N("TextLabel", {Text="F", Font=Enum.Font.GothamBlack, TextSize=24, TextColor3=Color3.new(1,1,1), BackgroundTransparency=1, Size=UDim2.new(1,0,1,0)}, AV)

    UI.Main = N("Frame", {Size=UDim2.new(0,420,0,300), Position=UDim2.new(0.5,-210,0.5,-150), BackgroundColor3=BG, BorderSizePixel=0, Visible=false, ZIndex=40}, UI.SG)
    N("UICorner", {CornerRadius=UDim.new(0,12)}, UI.Main)
    N("UIStroke", {Color=ACC, Thickness=1}, UI.Main)
    
    local TB = N("Frame", {Size=UDim2.new(1,0,0,40), BackgroundColor3=PANEL, BorderSizePixel=0, ZIndex=41}, UI.Main)
    N("UICorner", {CornerRadius=UDim.new(0,12)}, TB)
    N("TextLabel", {Text="  FerClient v8.0", Font=Enum.Font.GothamBold, TextSize=16, TextColor3=TXT, BackgroundTransparency=1, Size=UDim2.new(1,-50,1,0), TextXAlignment=Enum.TextXAlignment.Left}, TB)
    local CL = N("TextButton", {Text="✕", Font=Enum.Font.GothamBold, TextSize=14, TextColor3=TXT, BackgroundColor3=Color3.fromRGB(220,50,70), Size=UDim2.new(0,26,0,26), Position=UDim2.new(1,-32,0.5,-13), BorderSizePixel=0}, TB)
    N("UICorner", {CornerRadius=UDim.new(0,6)}, CL)

    local TBB = N("Frame", {Size=UDim2.new(0,100,1,-40), Position=UDim2.new(0,0,0,40), BackgroundColor3=BG, BorderSizePixel=0, ZIndex=41}, UI.Main)
    N("UIListLayout", {FillDirection=Enum.FillDirection.Vertical, Padding=UDim.new(0,6), HorizontalAlignment=Enum.HorizontalAlignment.Center, VerticalAlignment=Enum.VerticalAlignment.Top}, TBB)
    
    local CT = N("ScrollingFrame", {Size=UDim2.new(1,-110,1,-50), Position=UDim2.new(0,104,0,44), BackgroundColor3=PANEL, BorderSizePixel=0, ScrollBarThickness=3, CanvasSize=UDim2.new(0,0,0,0), ZIndex=41}, UI.Main)
    N("UICorner", {CornerRadius=UDim.new(0,8)}, CT)
    local CLL = N("UIListLayout", {Padding=UDim.new(0,6)}, CT)
    N("UIPadding", {PaddingTop=UDim.new(0,8), PaddingLeft=UDim.new(0,8), PaddingRight=UDim.new(0,8), PaddingBottom=UDim.new(0,8)}, CT)

    local function Toggle(text, val, cb)
        local row = N("Frame", {Size=UDim2.new(1,0,0,30), BackgroundColor3=P2, BorderSizePixel=0}, CT)
        N("UICorner", {CornerRadius=UDim.new(0,6)}, row)
        N("TextLabel", {Text="  "..text, Font=Enum.Font.Gotham, TextSize=13, TextColor3=TXT, BackgroundTransparency=1, Size=UDim2.new(1,-50,1,0), TextXAlignment=Enum.TextXAlignment.Left}, row)
        local sw = N("Frame", {Size=UDim2.new(0,34,0,18), Position=UDim2.new(1,-42,0.5,-9), BackgroundColor3=val and ACC or OFF, BorderSizePixel=0}, row)
        N("UICorner", {CornerRadius=UDim.new(1,0)}, sw)
        local kn = N("Frame", {Size=UDim2.new(0,14,0,14), Position=val and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7), BackgroundColor3=Color3.new(1,1,1), BorderSizePixel=0}, sw)
        N("UICorner", {CornerRadius=UDim.new(1,0)}, kn)
        local st = val
        local btn = N("TextButton", {Text="", BackgroundTransparency=1, Size=UDim2.new(1,0,1,0)}, row)
        btn.MouseButton1Click:Connect(function()
            if Core.Destroyed then return end
            st = not st
            sw.BackgroundColor3 = st and ACC or OFF
            local t = TweenService:Create(kn, TweenInfo.new(0.15), {Position = st and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7)})
            Core.RegisterTween(t)
            t:Play()
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
        N("UICorner", {CornerRadius=UDim.new(0,2)}, fl)
        local inp = N("TextButton", {Text="", BackgroundTransparency=1, Size=UDim2.new(1,0,1,0)}, row)
        local dragging = false
        local function setVal(x)
            if Core.Destroyed or not tr or not tr.Parent or tr.AbsoluteSize.X == 0 then return end
            local r = math.clamp((x - tr.AbsolutePosition.X) / tr.AbsoluteSize.X, 0, 1)
            local v = math.floor(mn + (mx - mn) * r + 0.5)
            vl.Text = tostring(v)
            fl.Size = UDim2.new(r, 0, 1, 0)
            if cb then cb(v) end
        end
        inp.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true setVal(i.Position.X) end end)
        inp.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
        UserInputService.InputChanged:Connect(function(i) if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then setVal(i.Position.X) end end)
    end

    local function AddTab(name)
        local b = N("TextButton", {Text=name, Font=Enum.Font.GothamSemibold, TextSize=13, TextColor3=SUB, BackgroundColor3=P2, Size=UDim2.new(0,90,0,28), BorderSizePixel=0}, TBB)
        N("UICorner", {CornerRadius=UDim.new(0,6)}, b)
        UI.TabBtns[name] = b
        b.MouseButton1Click:Connect(function()
            if Core.Destroyed then return end
            for k, v in pairs(UI.TabBtns) do 
                v.BackgroundColor3 = (k == name) and ACC or P2 
                v.TextColor3 = (k == name) and Color3.new(1,1,1) or SUB 
            end
            for _, obj in ipairs(CT:GetChildren()) do 
                if obj:IsA("GuiObject") then obj:Destroy() end 
            end
            if UI.Tabs[name] then UI.Tabs[name]() end
            task.defer(function() 
                if not Core.Destroyed and CT then CT.CanvasSize = UDim2.new(0,0,0,CLL.AbsoluteContentSize.Y + 16) end 
            end)
        end)
    end

    AddTab("Combat")
    AddTab("Visual")
    AddTab("Misc")

    UI.Tabs.Combat = function()
        N("TextLabel", {Text="COMBAT", Font=Enum.Font.GothamBold, TextSize=12, TextColor3=SUB, BackgroundTransparency=1, Size=UDim2.new(1,0,0,20), TextXAlignment=Enum.TextXAlignment.Left}, CT)
        Toggle("Aim Bot", Config.AimBot, function(v) Config.AimBot = v end)
        Toggle("Team Check", Config.TeamCheck, function(v) Config.TeamCheck = v end)
        Toggle("Wall Check", Config.WallCheck, function(v) Config.WallCheck = v end)
        Slider("Smooth", 1, 100, 35, function(v) Config.Smooth = v/100 end)
        Slider("FOV", 10, 400, 150, function(v) Config.FOV = v end)
    end

    UI.Tabs.Visual = function()
        N("TextLabel", {Text="PLAYER VISUAL", Font=Enum.Font.GothamBold, TextSize=12, TextColor3=SUB, BackgroundTransparency=1, Size=UDim2.new(1,0,0,20), TextXAlignment=Enum.TextXAlignment.Left}, CT)
        Toggle("ESP", Config.ESP, function(v) Config.ESP = v end)
        Toggle("  Box", Config.ESPBox, function(v) Config.ESPBox = v end)
        Toggle("  Name", Config.ESPName, function(v) Config.ESPName = v end)
        Toggle("  Distance", Config.ESPDist, function(v) Config.ESPDist = v end)
        Slider("Max Dist", 50, 5000, 1000, function(v) Config.ESPMaxDist = v end)
        Toggle("Show FOV", Config.ShowFOV, function(v) Config.ShowFOV = v end)
    end

    UI.Tabs.Misc = function()
        N("TextLabel", {Text="MISC", Font=Enum.Font.GothamBold, TextSize=12, TextColor3=SUB, BackgroundTransparency=1, Size=UDim2.new(1,0,0,20), TextXAlignment=Enum.TextXAlignment.Left}, CT)
    end

    UI.Tabs.Combat()

    local mdrag, mds, mdp = false, nil, nil
    TB.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then mdrag = true mds = i.Position mdp = UI.Main.Position end end)
    TB.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then mdrag = false end end)
    UserInputService.InputChanged:Connect(function(i) 
        if mdrag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then 
            local d = i.Position - mds 
            UI.Main.Position = UDim2.new(mdp.X.Scale, mdp.X.Offset + d.X, mdp.Y.Scale, mdp.Y.Offset + d.Y) 
        end 
    end)

    AV.MouseButton1Click:Connect(function() 
        if not Core.Destroyed then UI.Main.Visible = not UI.Main.Visible end 
    end)
    CL.MouseButton1Click:Connect(function() 
        if not Core.Destroyed then UI.Main.Visible = false end 
    end)
end

local function Init()
    Core.SafeCall(CreateUI)
    local function CachePlayer(pl)
        if pl ~= LP then
            PlayerCache[pl] = {Char = pl.Character, Hum = pl.Character and pl.Character:FindFirstChildOfClass("Humanoid"), HRP = pl.Character and pl.Character:FindFirstChild("HumanoidRootPart")}
        end
    end
    for _, pl in ipairs(Players:GetPlayers()) do CachePlayer(pl) end
    Core.RegisterConnection(Players.PlayerAdded:Connect(CachePlayer))
    Core.RegisterConnection(Players.PlayerRemoving:Connect(function(pl) PlayerCache[pl] = nil end))

    Core.RegisterConnection(UserInputService.InputBegan:Connect(function(input)
        if Core.Destroyed then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if Config.AimBot and CurrentTarget then
                if CurrentTarget.Character and CurrentTarget.Character:FindFirstChild(Config.AimPart) then
                    local cam = GetCamera()
                    if cam then 
                        local part = CurrentTarget.Character[Config.AimPart]
                        local vel = CurrentTarget.Character.HumanoidRootPart and CurrentTarget.Character.HumanoidRootPart.AssemblyLinearVelocity or Vector3.new(0,0,0)
                        cam.CFrame = CFrame.new(cam.CFrame.Position, part.Position + (vel * 0.1))
                    end
                end
            end
        end
    end))

    local LastTargetUpdate = 0
    Core.RegisterConnection(RunService.Heartbeat:Connect(function()
        if Core.Destroyed then return end
        local now = tick()
        if now - LastTargetUpdate > 0.1 then
            LastTargetUpdate = now
            local cam = GetCamera()
            if cam then
                local best, dist = nil, Config.FOV
                local cen = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
                for pl, data in pairs(PlayerCache) do
                    local hrp = data.HRP
                    if hrp and hrp.Parent then
                        if Config.TeamCheck and pl.Team == LP.Team then continue end
                        local sp, on = cam:WorldToViewportPoint(hrp.Position)
                        if on then
                            local d = (Vector2.new(sp.X, sp.Y) - cen).Magnitude
                            if d < dist then dist = d best = pl end
                        end
                    end
                end
                CurrentTarget = best
            end
        end
    end))
end

Init()
