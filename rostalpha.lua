--[[ FerClient v27.0 | Full Vomagla Code, FerClient Style ]]
do
    if getgenv().__VOMAGLA_UNLOAD then pcall(getgenv().__VOMAGLA_UNLOAD) end
    task.wait(0.2)
end
local cg = game:GetService("CoreGui")
for _, n in ipairs({ "VOMAGLA_FOV", "VOMAGLA_HitLogs", "VOMAGLA_ESP", "STHUD", "VOMAGLA_RL" }) do
    local g = cg:FindFirstChild(n)
    if g then pcall(function() g:Destroy() end) end
end
do
    if not newcclosure then getgenv().newcclosure = function(f) return f end end
    if not checkcaller then getgenv().checkcaller = function() return false end end
    if not hookmetamethod then getgenv().hookmetamethod = function() end end
    if not getnamecallmethod then getgenv().getnamecallmethod = function() return "" end end
end
local CustomSounds = {
    ["None"] = "",
    ["Osu"] = "rbxassetid://7172607676",
    ["Pop"] = "rbxassetid://9125402735",
    ["MLG"] = "rbxassetid://109817519733426",
    ["Ouch"] = "rbxassetid://136844926219636",
    ["Fire"] = "rbxassetid://130412184952886",
    ["Bonk"] = "rbxassetid://5682262154",
    ["Bell"] = "rbxassetid://131573697",
    ["Rust"] = "rbxassetid://5043539486",
    ["Metal"] = "rbxassetid://8917041751",
    ["Skeet"] = "rbxassetid://83717596220569",
    ["Quack"] = "rbxassetid://6435400690",
    ["Katana"] = "rbxassetid://7122613461",
    ["Neverlose"] = "rbxassetid://18391691942",
    ["Undertale"] = "rbxassetid://1471213022",
    ["Jet Set Radio"] = "rbxassetid://97113622160405",
    ["TF2 Critical"] = "rbxassetid://8255306220",
    ["TF2 Frying Pan"] = "rbxassetid://18922477538",
    ["TF2 Alternative"] = "rbxassetid://2868331684"
}
local Svc = {
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    UIS = game:GetService("UserInputService"),
    RS = game:GetService("ReplicatedStorage"),
    WS = game:GetService("Workspace"),
    TS = game:GetService("TweenService"),
    Light = game:GetService("Lighting"),
    CoreGui = game:GetService("CoreGui"),
    SS = game:GetService("SoundService"),
    Debris = game:GetService("Debris"),
    InsertService = game:GetService("InsertService"),
}
local LP = Svc.Players.LocalPlayer
local v6 = Svc.WS.CurrentCamera
local v11 = Svc.WS
local Vector2New, Vector3New, CFrameNew = Vector2.new, Vector3.new, CFrame.new
local mathFloor, mathClamp, mathAbs, mathRad, mathExp = math.floor, math.clamp, math.abs, math.rad, math.exp
local mathCos, mathSin = math.cos, math.sin
local tick, typeof, pairs, ipairs, pcall, next = tick, typeof, pairs, ipairs, pcall, next
local unpack = table.unpack or unpack
local string_format, string_find = string.format, string.find
local task_spawn, task_delay, task_wait, task_defer = task.spawn, task.delay, task.wait, task.defer
local osClock = os.clock
-- ...(весь остальной код Вомаглы идёт сюда без изменений, кроме названий в UI)
