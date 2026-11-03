--[[ FerClient v6.8 | Skeleton + HP Bar + Tracers ]]
local P=game:GetService("Players")local R=game:GetService("RunService")local U=game:GetService("UserInputService")local L=game:GetService("Lighting")local W=game:GetService("Workspace")local T=game:GetService("TweenService")local CG=game:GetService("CoreGui")
local LP=P.LocalPlayer
local BG_IMAGE_ID = "rbxassetid://70985600234581"
if _G.FerClientCleanup then pcall(_G.FerClientCleanup)_G.FerClientCleanup=nil end
pcall(function()if CG:FindFirstChild("FerUI")then CG.FerUI:Destroy()end end)
local Registry={Connections={},Drawings={},Instances={},Tweens={},TabConnections={},CharConns={}}
local IsCleanedUp=false
local RemoveConn, RemoveDraw, RemoveTween, RemoveInst
function RemoveTween(t)if not t then return end local idx=table.find(Registry.Tweens,t)if idx then table.remove(Registry.Tweens,idx)end end
function RemoveInst(i)if not i then return end local idx=table.find(Registry.Instances,i)if idx then table.remove(Registry.Instances,idx)end end
function RemoveDraw(d)if not d then return end local idx=table.find(Registry.Drawings,d)if idx then table.remove(Registry.Drawings,idx)end end
function RemoveConn(c)if not c then return end local idx=table.find(Registry.Connections,c)if idx then table.remove(Registry.Connections,idx)end end
local function RegConn(c)if c then table.insert(Registry.Connections,c)end return c end
local function RegTabConn(c)if c then table.insert(Registry.TabConnections,c)end return c end
local function RegDraw(d)if d then table.insert(Registry.Drawings,d)end return d end
local function RegInst(i)if i then table.insert(Registry.Instances,i)end return i end
local function RegTween(t)
    if t then 
        table.insert(Registry.Tweens,t)
        local c
        c=t.Completed:Connect(function()local idx=table.find(Registry.Tweens,t)if idx then table.remove(Registry.Tweens,idx)end RemoveConn(c)end)
        table.insert(Registry.Connections,c)
    end 
    return t 
end
local function FlushRegistry()
    for i=#Registry.Tweens,1,-1 do local t=Registry.Tweens[i]if t then pcall(function()t:Cancel()end)end end
    table.clear(Registry.Tweens)
    for i=#Registry.Connections,1,-1 do local c=Registry.Connections[i]if c and c.Connected then pcall(function()c:Disconnect()end)end end
    table.clear(Registry.Connections)
    for i=#Registry.TabConnections,1,-1 do local c=Registry.TabConnections[i]if c and c.Connected then pcall(function()c:Disconnect()end)end end
    table.clear(Registry.TabConnections)
    for i=#Registry.Drawings,1,-1 do local d=Registry.Drawings[i]if d and d.Remove then pcall(function()d:Remove()end)end end
    table.clear(Registry.Drawings)
    for i=#Registry.Instances,1,-1 do local o=Registry.Instances[i]if o then pcall(function()o:Destroy()end)end end
    table.clear(Registry.Instances)
    table.clear(Registry.CharConns)
end
local SG,M,AV,TB,CT,CLL local CurrentAimTarget=nil local LastTargetUpdate=0 local LastESPUpdate=0
local PlayerCache={} local ESP={}
local function CachePlayer(pl)
    if pl~=LP then 
        local char=pl.Character
        PlayerCache[pl]={Char=char, Hum=char and char:FindFirstChildOfClass("Humanoid"), HRP=char and char:FindFirstChild("HumanoidRootPart")}
    end 
end
for _,pl in ipairs(P:GetPlayers())do CachePlayer(pl)end
RegConn(P.PlayerAdded:Connect(CachePlayer))
RegConn(P.PlayerRemoving:Connect(function(pl)
    PlayerCache[pl]=nil 
    if Registry.CharConns[pl] then for _,c in ipairs(Registry.CharConns[pl])do if c and c.Connected then pcall(function()c:Disconnect()end)RemoveConn(c)end end Registry.CharConns[pl]=nil end
    if ESP[pl]then for _,d in pairs(ESP[pl])do if d and d.Remove then pcall(function()d:Remove()end)RemoveDraw(d)end end ESP[pl]=nil end 
end))
local function SetupCharTracker(pl)
    if pl~=LP then
        if Registry.CharConns[pl] then return end
        Registry.CharConns[pl]={}
        local c1=pl.CharacterAdded:Connect(function(char)
            local hum=char:WaitForChild("Humanoid",5)
            local hrp=char:WaitForChild("HumanoidRootPart",5)
            if pl.Parent and pl.Character==char then PlayerCache[pl]={Char=char,Hum=hum,HRP=hrp} end
        end)
        table.insert(Registry.CharConns[pl],c1) RegConn(c1)
        local c2=pl.CharacterRemoving:Connect(function()
            if PlayerCache[pl]then PlayerCache[pl]={Char=nil,Hum=nil,HRP=nil} if ESP[pl]then for _,d in pairs(ESP[pl])do if d and d.Remove then pcall(function()d:Remove()end)RemoveDraw(d)end end ESP[pl]=nil end end
        end)
        table.insert(Registry.CharConns[pl],c2) RegConn(c2)
    end
end
for _,pl in ipairs(P:GetPlayers())do SetupCharTracker(pl)end
RegConn(P.PlayerAdded:Connect(SetupCharTracker))
local function GetCamera()local cam=W.CurrentCamera if cam and cam.Parent then return cam end return nil end
local hasDrawing=pcall(function()local s=Drawing.new("Square")local t=Drawing.new("Text")local tr=Drawing.new("Triangle")if s then s:Remove()end if t then t:Remove()end if tr then tr:Remove()end return true end)
local function SafeDrawing(class)if not hasDrawing then return nil end local ok,obj=pcall(function()return Drawing.new(class)end)return ok and RegDraw(obj)or nil end
local function destroyESPEntry(e)if not e then return end for _,d in pairs(e)do if d and d.Remove then pcall(function()d:Remove()end)RemoveDraw(d)end end end
local C={AimSelect=false,AimBot=false,AimPart="Head",Smooth=0.35,FOV=150,MaxDist=500,WallCheck=false,
ESP=false,ESPBox=true,ESPName=true,ESPCharms=true,ESPDist=true,ESPSkeleton=false,ESPHP=false,ESPTracers=false,
ESPColor=Color3.fromRGB(0,200,255),
ShowFOV=false,Fullbright=false,XRay=false,NoDeco=false,SkyFon=false,FPSBoost=false,
InfJump=false,AntiAFK=false,HitSound=false,
OreESP=false, SulfurESP=false, IronESP=false, StoneESP=false, OreDist=500,
CrateESP=false, MilitaryESP=false, EliteESP=false, FoodESP=false, CrateDist=500}
local ACC=Color3.fromRGB(0,170,255)local BG=Color3.fromRGB(15,15,20)local PANEL=Color3.fromRGB(22,22,30)local P2=Color3.fromRGB(30,30,40)local TXT=Color3.fromRGB(235,235,245)local SUB=Color3.fromRGB(150,150,165)local OFF=Color3.fromRGB(60,60,75)local STROKE=Color3.fromRGB(45,45,60)
local function N(class,props,parent)local o=Instance.new(class)for k,v in pairs(props or{})do o[k]=v end if parent then o.Parent=parent end return o end
local function Round(o,r)N("UICorner",{CornerRadius=UDim.new(0,r or 8)},o)end
local function Stroke(o,col,th)N("UIStroke",{Color=col or STROKE,Thickness=th or 1},o)end
SG=RegInst(N("ScreenGui",{Name="FerUI",ResetOnSpawn=false,IgnoreGuiInset=true,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},CG))
AV=N("ImageButton",{Size=UDim2.new(0,40,0,40),Position=UDim2.new(0,20,0.5,-20),BackgroundColor3=BG,AutoButtonColor=false,BorderSizePixel=0,ZIndex=50},SG)Round(AV,40)Stroke(AV,ACC,2)
N("UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(120,40,200)),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(20,120,255)),ColorSequenceKeypoint.new(1,Color3.fromRGB(255,60,160))}),Rotation=45},AV)
N("TextLabel",{Text="F",Font=Enum.Font.GothamBlack,TextSize=24,TextColor3=Color3.new(1,1,1),BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),TextStrokeTransparency=0.4,ZIndex=51},AV)
M=N("Frame",{Name="M",Size=UDim2.new(0,420,0,300),Position=UDim2.new(0.5,-210,0.5,-150),BackgroundColor3=BG,BorderSizePixel=0,Visible=false,ZIndex=40},SG)Round(M,12)Stroke(M,ACC,1)
if BG_IMAGE_ID ~= "" then
    local BgImg = RegInst(N("ImageLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Image=BG_IMAGE_ID,ImageTransparency=0.3,ScaleType=Enum.ScaleType.Crop,ZIndex=1},M))
    Round(BgImg,12)
end
TB=N("Frame",{Size=UDim2.new(1,0,0,40),BackgroundColor3=PANEL,BackgroundTransparency=0.2,BorderSizePixel=0,ZIndex=41},M)Round(TB,12)
N("UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(120,40,200)),ColorSequenceKeypoint.new(1,Color3.fromRGB(20,120,255))}),Rotation=30,Transparency=NumberSequence.new(0.55)},TB)
N("TextLabel",{Text="  FerClient",Font=Enum.Font.GothamBold,TextSize=16,TextColor3=TXT,BackgroundTransparency=1,Size=UDim2.new(1,-100,1,0),TextXAlignment=Enum.TextXAlignment.Left,ZIndex=42},TB)
local CL=N("TextButton",{Text="✕",Font=Enum.Font.GothamBold,TextSize=14,TextColor3=TXT,BackgroundColor3=Color3.fromRGB(220,50,70),Size=UDim2.new(0,26,0,26),Position=UDim2.new(1,-32,0.5,-13),BorderSizePixel=0,ZIndex=43},TB)Round(CL,6)
local TBB=N("Frame",{Size=UDim2.new(0,100,1,-40),Position=UDim2.new(0,0,0,40),BackgroundColor3=BG,BackgroundTransparency=0.3,BorderSizePixel=0,ZIndex=41},M)
N("UIListLayout",{FillDirection=Enum.FillDirection.Vertical,Padding=UDim.new(0,6),HorizontalAlignment=Enum.HorizontalAlignment.Center,VerticalAlignment=Enum.VerticalAlignment.Top},TBB)N("UIPadding",{PaddingTop=UDim.new(0,10)},TBB)
CT=N("ScrollingFrame",{Size=UDim2.new(1,-110,1,-50),Position=UDim2.new(0,104,0,44),BackgroundColor3=PANEL,BackgroundTransparency=0.4,BorderSizePixel=0,ScrollBarThickness=3,ScrollBarImageColor3=ACC,CanvasSize=UDim2.new(0,0,0,0),ZIndex=41},M)Round(CT,8)
CLL=N("UIListLayout",{Padding=UDim.new(0,6)},CT)N("UIPadding",{PaddingTop=UDim.new(0,8),PaddingLeft=UDim.new(0,8),PaddingRight=UDim.new(0,8),PaddingBottom=UDim.new(0,8)},CT)
local function Label(text)N("TextLabel",{Text=text,Font=Enum.Font.GothamBold,TextSize=12,TextColor3=SUB,BackgroundTransparency=1,Size=UDim2.new(1,0,0,20),TextXAlignment=Enum.TextXAlignment.Left},CT)end
local function Toggle(text,currentVal,cb)
local row=N("Frame",{Size=UDim2.new(1,0,0,30),BackgroundColor3=P2,BorderSizePixel=0},CT)Round(row,6)
N("TextLabel",{Text="  "..text,Font=Enum.Font.Gotham,TextSize=13,TextColor3=TXT,BackgroundTransparency=1,Size=UDim2.new(1,-50,1,0),TextXAlignment=Enum.TextXAlignment.Left},row)
local sw=N("Frame",{Size=UDim2.new(0,34,0,18),Position=UDim2.new(1,-42,0.5,-9),BackgroundColor3=currentVal and ACC or OFF,BorderSizePixel=0},row)Round(sw,9)
local kn=N("Frame",{Size=UDim2.new(0,14,0,14),Position=currentVal and UDim2.new(1,-16,0.5,-7)or UDim2.new(0,2,0.5,-7),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0},sw)Round(kn,7)
local st=currentVal local btn=N("TextButton",{Text="",BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),ZIndex=5},row)
local activeTween=nil
RegTabConn(btn.MouseButton1Click:Connect(function()
    if IsCleanedUp or not row.Parent then return end 
    st=not st sw.BackgroundColor3=st and ACC or OFF 
    if activeTween then activeTween:Cancel()RemoveTween(activeTween)end 
    activeTween=RegTween(T:Create(kn,TweenInfo.new(0.15),{Position=st and UDim2.new(1,-16,0.5,-7)or UDim2.new(0,2,0.5,-7)}))
    activeTween:Play()
    if cb then cb(st)end 
end))
end
local function Slider(text,mn,mx,def,cb)
if mx==mn then mx=mn+1 end 
def=math.clamp(def,mn,mx) 
local row=N("Frame",{Size=UDim2.new(1,0,0,48),BackgroundColor3=P2,BorderSizePixel=0},CT)Round(row,6)
N("TextLabel",{Text="  "..text,Font=Enum.Font.Gotham,TextSize=13,TextColor3=TXT,BackgroundTransparency=1,Size=UDim2.new(1,-50,0,22),TextXAlignment=Enum.TextXAlignment.Left},row)
local vl=N("TextLabel",{Text=tostring(def),Font=Enum.Font.GothamBold,TextSize=13,TextColor3=ACC,BackgroundTransparency=1,Size=UDim2.new(0,50,0,22),Position=UDim2.new(1,-55,0,0),TextXAlignment=Enum.TextXAlignment.Right},row)
local tr=N("Frame",{Size=UDim2.new(1,-20,0,4),Position=UDim2.new(0,10,0,32),BackgroundColor3=OFF,BorderSizePixel=0},row)Round(tr,2)
local fl=N("Frame",{Size=UDim2.new((def-mn)/(mx-mn),0,1,0),BackgroundColor3=ACC,BorderSizePixel=0},tr)Round(fl,2)
local kn=N("Frame",{Size=UDim2.new(0,12,0,12),Position=UDim2.new((def-mn)/(mx-mn),-6,0.5,-6),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,ZIndex=3},tr)Round(kn,6)
local dragging=false local inp=N("TextButton",{Text="",BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),ZIndex=4},row)
local function setFromX(x)if IsCleanedUp or not tr or not tr.Parent or tr.AbsoluteSize.X==0 then return end local r=math.clamp((x-tr.AbsolutePosition.X)/tr.AbsoluteSize.X,0,1)local v=math.floor(mn+(mx-mn)*r+0.5)vl.Text=tostring(v)fl.Size=UDim2.new(r,0,1,0)kn.Position=UDim2.new(r,-6,0.5,-6)if cb then cb(v)end end
local c1=inp.InputBegan:Connect(function(i)if IsCleanedUp then return end if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=true setFromX(i.Position.X)end end)
local c2=inp.InputEnded:Connect(function(i)if IsCleanedUp then return end if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=false end end)
local c3=U.InputChanged:Connect(function(i)if IsCleanedUp or not row.Parent then return end if dragging and(i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch)then setFromX(i.Position.X)end end)
RegTabConn(c1)RegTabConn(c2)RegTabConn(c3)
RegTabConn(row.Destroying:Connect(function()for _,c in ipairs({c1,c2,c3})do if c and c.Connected then pcall(function()c:Disconnect()end)end end end))
end
local function Dropdown(text,opts,def,cb)
local row=N("Frame",{Size=UDim2.new(1,0,0,30),BackgroundColor3=P2,BorderSizePixel=0},CT)Round(row,6)
N("TextLabel",{Text="  "..text,Font=Enum.Font.Gotham,TextSize=13,TextColor3=TXT,BackgroundTransparency=1,Size=UDim2.new(0.5,0,1,0),TextXAlignment=Enum.TextXAlignment.Left},row)
local btn=N("TextButton",{Text=def.." ▼",Font=Enum.Font.Gotham,TextSize=12,TextColor3=ACC,BackgroundTransparency=1,Size=UDim2.new(0,100,1,0),Position=UDim2.new(1,-100,0,0)},row)
local lst=N("Frame",{Size=UDim2.new(1,0,0,#opts*24),Position=UDim2.new(0,0,1,2),BackgroundColor3=PANEL,BorderSizePixel=0,Visible=false,ZIndex=60},row)Round(lst,6)Stroke(lst,ACC,1)
N("UIListLayout",{Padding=UDim.new(0,2)},lst)N("UIPadding",{PaddingTop=UDim.new(0,4),PaddingLeft=UDim.new(0,4),PaddingRight=UDim.new(0,4),PaddingBottom=UDim.new(0,4)},lst)
for _,o in ipairs(opts)do local ob=N("TextButton",{Text=o,Font=Enum.Font.Gotham,TextSize=12,TextColor3=TXT,BackgroundColor3=P2,Size=UDim2.new(1,0,0,22),BorderSizePixel=0,ZIndex=61},lst)Round(ob,4)RegTabConn(ob.MouseButton1Click:Connect(function()if IsCleanedUp or not row.Parent then return end btn.Text=o.." ▼"lst.Visible=false if cb then cb(o)end end))end
RegTabConn(btn.MouseButton1Click:Connect(function()if IsCleanedUp or not row.Parent then return end lst.Visible=not lst.Visible end))
end
local FOVCircle=RegInst(N("Frame",{BackgroundTransparency=1,AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,0,0.5,0),Visible=false,ZIndex=10},SG))
N("UICorner",{CornerRadius=UDim.new(1,0)},FOVCircle)
local FOVStroke=N("UIStroke",{Thickness=1.5,Color=Color3.new(1,1,1),ApplyStrokeMode=Enum.ApplyStrokeMode.Border},FOVCircle)
local function IsVisible(targetPart)
    if not C.WallCheck then return true end
    local cam = GetCamera()
    if not cam then return false end
    local origin = cam.CFrame.Position
    local direction = (targetPart.Position - origin)
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = {LP.Character}
    local result = W:Raycast(origin, direction, rayParams)
    if result then
        if result.Instance:IsDescendantOf(targetPart.Parent) then return true else return false end
    end
    return true
end
local function Nearest()
    local cam=GetCamera()
    if not cam then return nil end 
    local best,dist=nil,C.FOV 
    local cen=Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
    local myChar = LP.Character
    local myPos = myChar and myChar:FindFirstChild("HumanoidRootPart")
    
    for pl,data in pairs(PlayerCache)do 
        local hrp=data.HRP 
        if hrp and hrp.Parent then 
            local dist3D = myPos and (myPos.Position - hrp.Position).Magnitude or 9999
            if dist3D > C.MaxDist then continue end
            
            local sp,on=cam:WorldToViewportPoint(hrp.Position)
            if on then 
                local d=(Vector2.new(sp.X,sp.Y)-cen).Magnitude 
                if d<dist then 
                    local targetPart = data.Char:FindFirstChild(C.AimPart) or hrp
                    if IsVisible(targetPart) then 
                        dist=d 
                        best=pl 
                    end
                end 
            end 
        end 
    end 
    return best 
end
local function GetPredictedPos(targetPart)
    local velocity = Vector3.new(0,0,0)
    local character = targetPart.Parent
    if character then
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if hrp then velocity = hrp.AssemblyLinearVelocity end
    end
    return targetPart.Position + (velocity * 0.1)
end
RegConn(U.InputBegan:Connect(function(input)
    if IsCleanedUp then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if C.AimBot or C.AimSelect then
            local target = CurrentAimTarget
            if target and target.Character and target.Character:FindFirstChild(C.AimPart) then
                local cam = GetCamera()
                if cam then
                    cam.CFrame = CFrame.new(cam.CFrame.Position, GetPredictedPos(target.Character[C.AimPart]))
                end
            end
        end
    end
end))
RegConn(W.DescendantAdded:Connect(function(desc)
    if IsCleanedUp or not C.HitSound then return end
    if desc:IsA("Sound") and (desc.Name == "HitClient" or desc.Name == "HeadShotClient") then
        desc.SoundId = "rbxassetid://9046912122"
        desc.Volume = 2
    end
end))
local function ApplyHitSound(tool)
    if not tool or not tool:IsA("Tool") or not C.HitSound then return end
    local bodyAttach = tool:FindFirstChild("BodyAttach")
    if bodyAttach then
        for _, sName in ipairs({"HitClient", "HeadShotClient", "HitCharacterClient"}) do
            local snd = bodyAttach:FindFirstChild(sName)
            if snd and snd:IsA("Sound") then
                snd.SoundId = "rbxassetid://9046912122"
                snd.Volume = 2
            end
        end
    end
end
local function OnCharAdded(char)
    if C.HitSound then
        task.wait(0.5)
        for _, tool in pairs(char:GetChildren()) do ApplyHitSound(tool) end
    end
end
RegConn(LP.CharacterAdded:Connect(OnCharAdded))
if LP.Character then OnCharAdded(LP.Character) end

local FB_Old={}local OldSky={}local XRayTab={}local FPSOff={}local NoDecoStore={}local SkyFolder=nil
local function Fullbright(on)
    if on then for _,k in ipairs({"Brightness","ClockTime","FogEnd","GlobalShadows","Ambient"})do FB_Old[k]=L[k]end L.Brightness=2 L.ClockTime=14 L.FogEnd=100000 L.GlobalShadows=false L.Ambient=Color3.fromRGB(178,178,178)
    else for k,v in pairs(FB_Old)do pcall(function()if L[k]~=v then L[k]=v end end)end table.clear(FB_Old)end 
end
local function XRay(on)if on then for _,v in ipairs(W:GetDescendants())do if v:IsA("BasePart")and v.Transparency<1 then XRayTab[v]=v.Transparency v.Transparency=0.7 end end else for obj,tr in pairs(XRayTab)do if obj and obj.Parent then pcall(function()if obj.Transparency~=tr then obj.Transparency=tr end end)end end table.clear(XRayTab)end end
local OldTerrainDeco = true
local function NoDeco(on)
    if sethiddenproperty then 
        local t=W:FindFirstChildOfClass("Terrain")
        if t then 
            if on then 
                local ok, val = pcall(function() return gethiddenproperty(t, "Decoration") end)
                if ok then OldTerrainDeco = val end
                pcall(function() sethiddenproperty(t,"Decoration",false) end)
            else 
                pcall(function() sethiddenproperty(t,"Decoration",OldTerrainDeco) end)
            end
        end
    else 
        if on then for _,v in ipairs(W:GetDescendants())do if(v:IsA("Decal")or v:IsA("Texture"))and not NoDecoStore[v]then NoDecoStore[v]=v.Transparency v.Transparency=1 end end 
        else for obj,tr in pairs(NoDecoStore)do if obj and obj.Parent then pcall(function()if obj.Transparency~=tr then obj.Transparency=tr end end)end end table.clear(NoDecoStore)end 
    end 
end
local function SkyFon(on)
    local existing=L:FindFirstChild("FerSky")
    if on then 
        if existing then return end 
        local currentSky=L:FindFirstChildOfClass("Sky")
        if currentSky then OldSky[1]=currentSky currentSky.Parent=nil end 
        local success=pcall(function()
            SkyFolder=RegInst(N("Folder",{Name="FerSky"},L))
            N("Sky",{Name="FerSkybox",SkyboxBk="rbxassetid://159454299",SkyboxDn="rbxassetid://159454296",SkyboxFt="rbxassetid://159454293",SkyboxLf="rbxassetid://159454286",SkyboxRt="rbxassetid://159454300",SkyboxUp="rbxassetid://159454288",StarCount=5000},SkyFolder)
        end)
        if not success then if SkyFolder then RemoveInst(SkyFolder)SkyFolder=nil end if OldSky[1]then OldSky[1].Parent=L table.clear(OldSky)end end 
    else 
        if SkyFolder then SkyFolder:Destroy()RemoveInst(SkyFolder)SkyFolder=nil end 
        if OldSky[1]and OldSky[1].Parent==nil then pcall(function()OldSky[1].Parent=L end)end 
        table.clear(OldSky)
    end 
end
local function FPS(on)if on then for _,obj in ipairs(L:GetDescendants())do if obj:IsA("PostEffect")then FPSOff[obj]=obj.Enabled obj.Enabled=false end end else for obj,en in pairs(FPSOff)do if obj and obj.Parent then pcall(function()if obj.Enabled~=en then obj.Enabled=en end end)end end table.clear(FPSOff)end end
local InfConn,AFKConn
local function InfJump(on)if on then if not InfConn then InfConn=RegConn(U.JumpRequest:Connect(function()local h=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")if h then h:ChangeState(Enum.HumanoidStateType.Jumping)end end))end elseif InfConn then InfConn:Disconnect()RemoveConn(InfConn)InfConn=nil end end
local function AFK(on)if on then if not AFKConn then AFKConn=RegConn(LP.Idled:Connect(function()pcall(function()local v=game:GetService("VirtualUser")v:CaptureController()v:ClickButton2(Vector2.new())end)end))end elseif AFKConn then AFKConn:Disconnect()RemoveConn(AFKConn)AFKConn=nil end end
-- ESP Ресурсов
local function ApplyOreESP(obj, name, color)
    if not obj:FindFirstChild("FerOreHighlight") then local h = Instance.new("Highlight", obj) h.Name = "FerOreHighlight" h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop end
    if not obj:FindFirstChild("FerOreTag") then local bg = Instance.new("BillboardGui", obj) bg.Name = "FerOreTag" bg.AlwaysOnTop = true bg.Size = UDim2.new(0, 100, 0, 40) bg.ExtentsOffset = Vector3.new(0, 2, 0) local label = Instance.new("TextLabel", bg) label.Name = "Label" label.BackgroundTransparency = 1 label.Size = UDim2.new(1, 0, 1, 0) label.TextSize = 13 label.Font = Enum.Font.GothamBold label.TextStrokeTransparency = 0 end
    local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if root then local pos = obj:IsA("Model") and obj:GetModelCFrame().Position or obj.Position local dist = math.floor((root.Position - pos).Magnitude)
        if dist <= C.OreDist then obj.FerOreTag.Enabled = true obj.FerOreHighlight.Enabled = true obj.FerOreTag.Label.Text = name:upper().."\n["..dist.."m]" obj.FerOreTag.Label.TextColor3 = color obj.FerOreHighlight.FillColor = color
        else obj.FerOreTag.Enabled = false obj.FerOreHighlight.Enabled = false end
    end
end
local function ApplyCrateESP(obj, name, color)
    if not obj:FindFirstChild("FerCrateHighlight") then local h = Instance.new("Highlight", obj) h.Name = "FerCrateHighlight" h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop end
    if not obj:FindFirstChild("FerCrateTag") then local bg = Instance.new("BillboardGui", obj) bg.Name = "FerCrateTag" bg.AlwaysOnTop = true bg.Size = UDim2.new(0, 100, 0, 40) bg.ExtentsOffset = Vector3.new(0, 2, 0) local label = Instance.new("TextLabel", bg) label.Name = "Label" label.BackgroundTransparency = 1 label.Size = UDim2.new(1, 0, 1, 0) label.TextSize = 13 label.Font = Enum.Font.GothamBold label.TextStrokeTransparency = 0 end
    local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if root then local pos = obj:IsA("Model") and obj:GetModelCFrame().Position or obj.Position local dist = math.floor((root.Position - pos).Magnitude)
        if dist <= C.CrateDist then obj.FerCrateTag.Enabled = true obj.FerCrateHighlight.Enabled = true obj.FerCrateTag.Label.Text = name:upper().."\n["..dist.."m]" obj.FerCrateTag.Label.TextColor3 = color obj.FerCrateHighlight.FillColor = color
        else obj.FerCrateTag.Enabled = false obj.FerCrateHighlight.Enabled = false end
    end
end

RegConn(R.Heartbeat:Connect(function()
if IsCleanedUp then return end
local now=tick()
if now-LastTargetUpdate>0.1 then LastTargetUpdate=now CurrentAimTarget=Nearest()end
if now-LastESPUpdate>0.03 then 
LastESPUpdate=now
local cam=GetCamera()
-- ESP Игроков
if cam and C.ESP and hasDrawing then 
for pl,data in pairs(PlayerCache)do 
if not ESP[pl]then 
    local b=SafeDrawing("Square")local n=SafeDrawing("Text")local d=SafeDrawing("Text")local c=SafeDrawing("Triangle")
    local sk=SafeDrawing("Line") local sk2=SafeDrawing("Line") local sk3=SafeDrawing("Line") local sk4=SafeDrawing("Line")
    local hp=SafeDrawing("Line") local tr=SafeDrawing("Line")
    if b and n and d and c and sk and sk2 and sk3 and sk4 and hp and tr then 
        ESP[pl]={b=b,n=n,d=d,c=c,sk=sk,sk2=sk2,sk3=sk3,sk4=sk4,hp=hp,tr=tr}
        b.Thickness=1 b.Filled=false 
        n.Size=11 n.Center=true n.Outline=true n.Color=Color3.new(1,1,1)
        d.Size=10 d.Center=true d.Outline=true d.Color=C.ESPColor
        c.Thickness=1 c.Filled=true 
        for _,l in pairs({sk,sk2,sk3,sk4})do l.Thickness=1 l.Color=C.ESPColor end
        hp.Thickness=3 hp.Color=Color3.new(0,255,0)
        tr.Thickness=1 tr.Color=C.ESPColor
    else if b then pcall(function()b:Remove()end)RemoveDraw(b)end if n then pcall(function()n:Remove()end)RemoveDraw(n)end if d then pcall(function()d:Remove()end)RemoveDraw(d)end if c then pcall(function()c:Remove()end)RemoveDraw(c)end if sk then pcall(function()sk:Remove()end)end if sk2 then pcall(function()sk2:Remove()end)end if sk3 then pcall(function()sk3:Remove()end)end if sk4 then pcall(function()sk4:Remove()end)end if hp then pcall(function()hp:Remove()end)end if tr then pcall(function()tr:Remove()end)end end 
end 
local e=ESP[pl]if e then local hrp=data.HRP local hum=data.Hum
if hrp and hrp.Parent and hum and hum.Health>0 then 
local top=cam:WorldToViewportPoint(hrp.Position+Vector3.new(0,3,0))local bot=cam:WorldToViewportPoint(hrp.Position-Vector3.new(0,3,0))local pos,on=cam:WorldToViewportPoint(hrp.Position)
if on then 
    local h=math.abs(top.Y-bot.Y)local w=h*0.55 
    -- Box
    e.b.Size=Vector2.new(w,h)e.b.Position=Vector2.new(pos.X-w/2,top.Y)e.b.Color=C.ESPColor e.b.Visible=C.ESPBox 
    -- Name & Dist
    e.n.Text=pl.Name e.n.Position=Vector2.new(pos.X,top.Y-14)e.n.Visible=C.ESPName 
    local LPH=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")local dist=LPH and math.floor((LPH.Position-hrp.Position).Magnitude)or 0 
    e.d.Text="["..dist.."m]"e.d.Position=Vector2.new(pos.X,bot.Y+2)e.d.Visible=C.ESPDist 
    -- Charms
    if C.ESPCharms then local cx=pos.X local cy=top.Y-24 e.c.PointA=Vector2.new(cx,cy)e.c.PointB=Vector2.new(cx-4,cy+8)e.c.PointC=Vector2.new(cx+4,cy+8)e.c.Color=C.ESPColor e.c.Visible=true else e.c.Visible=false end 
    -- Health Bar
    if C.ESPHP then
        local hp_val = hum.Health / hum.MaxHealth
        e.hp.From = Vector2.new(pos.X-w/2-6, top.Y + h)
        e.hp.To = Vector2.new(pos.X-w/2-6, top.Y + h - (h * hp_val))
        e.hp.Color = Color3.fromHSV(hp_val * 0.3, 1, 1)
        e.hp.Visible = true
    else e.hp.Visible = false end
    -- Skeleton
    if C.ESPSkeleton then
        local head = data.Char:FindFirstChild("Head")
        local larm = data.Char:FindFirstChild("Left Arm") or data.Char:FindFirstChild("LeftHand")
        local rarm = data.Char:FindFirstChild("Right Arm") or data.Char:FindFirstChild("RightHand")
        local lleg = data.Char:FindFirstChild("Left Leg") or data.Char:FindFirstChild("LeftFoot")
        local rleg = data.Char:FindFirstChild("Right Leg") or data.Char:FindFirstChild("RightFoot")
        local function to2d(part) if not part then return Vector2.new(0,0) end local sp,on2=Camera:WorldToViewportPoint(part.Position) return Vector2.new(sp.X, sp.Y) end
        if head then
            local hpos = to2d(head)
            local rpos = to2d(hrp)
            e.sk.From = hpos e.sk.To = rpos e.sk.Visible = true
            if larm then e.sk2.From = rpos e.sk2.To = to2d(larm) e.sk2.Visible = true else e.sk2.Visible = false end
            if rarm then e.sk3.From = rpos e.sk3.To = to2d(rarm) e.sk3.Visible = true else e.sk3.Visible = false end
            if lleg then e.sk4.From = rpos e.sk4.To = to2d(lleg) e.sk4.Visible = true else e.sk4.Visible = false end
            -- 4th line for right leg
            e.tr.From = rpos e.tr.To = to2d(rleg) e.tr.Visible = true
        else
            e.sk.Visible = false e.sk2.Visible = false e.sk3.Visible = false e.sk4.Visible = false e.tr.Visible = false
        end
    else
        e.sk.Visible = false e.sk2.Visible = false e.sk3.Visible = false e.sk4.Visible = false e.tr.Visible = false
    end
    -- Tracers
    if C.ESPTracers then
        e.tr.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
        e.tr.To = Vector2.new(pos.X, pos.Y)
        e.tr.Visible = true
    else e.tr.Visible = false end
else e.b.Visible=false e.n.Visible=false e.d.Visible=false e.c.Visible=false e.hp.Visible=false e.sk.Visible=false e.sk2.Visible=false e.sk3.Visible=false e.sk4.Visible=false e.tr.Visible=false end 
else e.b.Visible=false e.n.Visible=false e.d.Visible=false e.c.Visible=false e.hp.Visible=false e.sk.Visible=false e.sk2.Visible=false e.sk3.Visible=false e.sk4.Visible=false e.tr.Visible=false end end end 
elseif not C.ESP then for _,e in pairs(ESP)do if e.b then e.b.Visible=false end if e.n then e.n.Visible=false end if e.d then e.d.Visible=false end if e.c then e.c.Visible=false end if e.hp then e.hp.Visible=false end if e.sk then e.sk.Visible=false end if e.sk2 then e.sk2.Visible=false end if e.sk3 then e.sk3.Visible=false end if e.sk4 then e.sk4.Visible=false end if e.tr then e.tr.Visible=false end end end

-- ESP Ресурсов
local ores = W:FindFirstChild("ores")
if ores then for _, ore in ipairs(ores:GetChildren()) do local en = (ore.Name == "sulfur" and C.SulfurESP) or (ore.Name == "iron" and C.IronESP) or (ore.Name == "stone" and C.StoneESP) local col = (ore.Name == "sulfur" and Color3.new(1,1,0)) or (ore.Name == "iron" and Color3.new(0.7,0.7,0.7)) or Color3.new(1,1,1) if en then ApplyOreESP(ore, ore.Name, col) elseif ore:FindFirstChild("FerOreTag") then ore.FerOreTag.Enabled, ore.FerOreHighlight.Enabled = false, false end end end
local crates = W:FindFirstChild("Crates")
if crates then for _, crate in ipairs(crates:GetChildren()) do local en, col = false, Color3.new(1,1,1) if crate.Name == "Crate" then en = C.CrateESP; col = Color3.fromRGB(150, 75, 0) elseif crate.Name == "MilitaryCrate" then en = C.MilitaryESP; col = Color3.fromRGB(0, 150, 0) elseif crate.Name == "EliteCrate" then en = C.EliteESP; col = Color3.fromRGB(255, 0, 50) elseif crate.Name == "FoodBox" or crate.Name == "ToolBox" then en = C.FoodESP; col = Color3.fromRGB(0, 200, 255) end if en then ApplyCrateESP(crate, crate.Name, col) elseif crate:FindFirstChild("FerCrateTag") then crate.FerCrateTag.Enabled, crate.FerCrateHighlight.Enabled = false, false end end end

end
end))
RegConn(R.RenderStepped:Connect(function()
if IsCleanedUp then return end local cam=GetCamera()
if cam and FOVCircle then if C.ShowFOV then FOVCircle.Visible=true local size=C.FOV*2 FOVCircle.Size=UDim2.new(0,size,0,size)FOVStroke.Color=C.ESPColor else FOVCircle.Visible=false end end
end))
local TabBtns,Tabs={},{}
local function ClearC()for _,x in ipairs(CT:GetChildren())do if x:IsA("GuiObject")then x:Destroy()end end for i=#Registry.TabConnections,1,-1 do local c=Registry.TabConnections[i]if c and c.Connected then pcall(function()c:Disconnect()end)end end table.clear(Registry.TabConnections) end
local function UpdateCanvas()if CT and not IsCleanedUp then CT.CanvasSize=UDim2.new(0,0,0,CLL.AbsoluteContentSize.Y+16)end end
local function Render(name)
    ClearC()
    for k,b in pairs(TabBtns)do b.BackgroundColor3=(k==name)and ACC or P2 b.TextColor3=(k==name)and Color3.new(1,1,1)or SUB end 
    if Tabs[name]then Tabs[name]()end 
    task.defer(function()
        if IsCleanedUp then return end
        UpdateCanvas()task.wait(0.05)if IsCleanedUp then return end UpdateCanvas()
    end)
end
local function AddTab(name)local b=N("TextButton",{Text=name,Font=Enum.Font.GothamSemibold,TextSize=13,TextColor3=SUB,BackgroundColor3=P2,Size=UDim2.new(0,90,0,28),BorderSizePixel=0,AutoButtonColor=false},TBB)Round(b,6)TabBtns[name]=b RegConn(b.MouseButton1Click:Connect(function()if IsCleanedUp or not b.Parent then return end Render(name)end))end
AddTab("Combat")AddTab("Visual")AddTab("Misc")
Tabs.Combat=function()
    Label("COMBAT")
    Toggle("Aim Bot (Camera)",C.AimBot,function(v)C.AimBot=v end)
    Toggle("Wall Check",C.WallCheck,function(v)C.WallCheck=v end)
    Dropdown("Aim Part",{"Head","HumanoidRootPart","UpperTorso"},"Head",function(v)C.AimPart=v end)
    Slider("Aim Smooth",1,100,35,function(v)C.Smooth=v/100 end)
    Slider("Aim FOV",10,400,150,function(v)C.FOV=v end)
    Slider("Max Dist",50,2000,500,function(v)C.MaxDist=v end)
end
Tabs.Visual=function()
    Label("PLAYER VISUAL")
    Toggle("ESP",C.ESP,function(v)C.ESP=v if not v then for pl,e in pairs(ESP)do destroyESPEntry(e)ESP[pl]=nil end end end)
    Toggle("  Box",C.ESPBox,function(v)C.ESPBox=v end)
    Toggle("  Name",C.ESPName,function(v)C.ESPName=v end)
    Toggle("  Charms",C.ESPCharms,function(v)C.ESPCharms=v end)
    Toggle("  Distance",C.ESPDist,function(v)C.ESPDist=v end)
    Toggle("  Skeleton",C.ESPSkeleton,function(v)C.ESPSkeleton=v end)
    Toggle("  Health Bar",C.ESPHP,function(v)C.ESPHP=v end)
    Toggle("  Tracers",C.ESPTracers,function(v)C.ESPTracers=v end)
    
    Label("RESOURCE VISUAL")
    Toggle("Sulfur ESP",C.SulfurESP,function(v)C.SulfurESP=v end)
    Toggle("Iron ESP",C.IronESP,function(v)C.IronESP=v end)
    Toggle("Stone ESP",C.StoneESP,function(v)C.StoneESP=v end)
    Slider("Ore Max Dist",50,2000,500,function(v)C.OreDist=v end)
    
    Label("CRATE VISUAL")
    Toggle("Crate ESP",C.CrateESP,function(v)C.CrateESP=v end)
    Toggle("Military Crate",C.MilitaryESP,function(v)C.MilitaryESP=v end)
    Toggle("Elite Crate",C.EliteESP,function(v)C.EliteESP=v end)
    Toggle("Food Box",C.FoodESP,function(v)C.FoodESP=v end)
    Slider("Crate Max Dist",50,2000,500,function(v)C.CrateDist=v end)

    Label("WORLD VISUAL")
    Toggle("Show FOV",C.ShowFOV,function(v)C.ShowFOV=v end)
    Toggle("Fullbright",C.Fullbright,function(v)C.Fullbright=v Fullbright(v)end)
    Toggle("X-Ray",C.XRay,function(v)C.XRay=v XRay(v)end)
    Toggle("No Decoration",C.NoDeco,function(v)C.NoDeco=v NoDeco(v)end)
    Toggle("Sky Fon",C.SkyFon,function(v)C.SkyFon=v SkyFon(v)end)
    Toggle("FPS Boost",C.FPSBoost,function(v)C.FPSBoost=v FPS(v)end)
    Toggle("Hit Sound (Anime)",C.HitSound,function(v)
        C.HitSound=v 
        if v and LP.Character then for _,tool in pairs(LP.Character:GetChildren())do ApplyHitSound(tool)end end
    end)
end
Tabs.Misc=function()Label("MISC")Toggle("Inf Jump",C.InfJump,function(v)C.InfJump=v InfJump(v)end)Toggle("Anti AFK",C.AntiAFK,function(v)C.AntiAFK=v AFK(v)end)end
Render("Combat")
RegConn(CL.MouseButton1Click:Connect(function()if not IsCleanedUp and M then M.Visible=false end end))
RegConn(AV.MouseButton1Click:Connect(function()if not IsCleanedUp and M then M.Visible=not M.Visible end end))
local drag,ds,dp=false,nil,nil
RegConn(AV.InputBegan:Connect(function(i)if IsCleanedUp then return end if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=true ds=i.Position dp=AV.Position end end))
RegConn(AV.InputEnded:Connect(function(i)if IsCleanedUp then return end if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=false end end))
RegConn(U.InputChanged:Connect(function(i)if IsCleanedUp or not AV then return end if drag and(i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch)then local d=i.Position-ds AV.Position=UDim2.new(dp.X.Scale,dp.X.Offset+d.X,dp.Y.Scale,dp.Y.Offset+d.Y)end end))
local mdrag,mds,mdp=false,nil,nil
RegConn(TB.InputBegan:Connect(function(i)if IsCleanedUp then return end if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then mdrag=true mds=i.Position mdp=M.Position end end))
RegConn(TB.InputEnded:Connect(function(i)if IsCleanedUp then return end if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then mdrag=false end end))
RegConn(U.InputChanged:Connect(function(i)if IsCleanedUp or not M then return end if mdrag and(i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch)then local d=i.Position-mds M.Position=UDim2.new(mdp.X.Scale,mdp.X.Offset+d.X,mdp.Y.Scale,mdp.Y.Offset+d.Y)end end))
-- МАЛЕНЬКИЙ WATERMARK
local WM = RegInst(N("ScreenGui",{Name="FerWM",ResetOnSpawn=false,IgnoreGuiInset=true},CG))
local WFrame = RegInst(N("Frame",{Size=UDim2.new(0,130,0,24),Position=UDim2.new(1,-140,1,-34),BackgroundColor3=BG,BackgroundTransparency=0.2,BorderSizePixel=0,ZIndex=10},WM))
Round(WFrame,6) Stroke(WFrame,ACC,1)
local WLabel = N("TextLabel",{Size=UDim2.new(1,-10,1,0),Position=UDim2.new(0,5,0,0),BackgroundTransparency=1,TextColor3=TXT,Font=Enum.Font.GothamBold,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,Text="FerClient | 60 FPS"},WFrame)
local FPS_Last = tick() local FPS_Frames = 0
RegConn(R.RenderStepped:Connect(function()
    if IsCleanedUp then return end
    FPS_Frames = FPS_Frames + 1
    if tick() - FPS_Last >= 1 then WLabel.Text = "FerClient | " .. FPS_Frames .. " FPS" FPS_Frames = 0 FPS_Last = tick() end
end))

local function Cleanup()
    if IsCleanedUp then return end 
    IsCleanedUp=true
    pcall(Fullbright,false)
    pcall(XRay,false)
    pcall(NoDeco,false)
    pcall(SkyFon,false)
    pcall(FPS,false)
    FlushRegistry()
    table.clear(PlayerCache)
    table.clear(ESP)
    print("[FerClient] Cleanup complete. All resources released.")
end
_G.FerClientCleanup=Cleanup
game:BindToClose(Cleanup)
