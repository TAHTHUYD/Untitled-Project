local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- CONFIG
local AutoFarm = true
local AutoBuyStats = true
local TargetMobName = "Spawned Mob" -- Adjust to correct mob name in your game
local AttackRange = 50

-- REMOTE EVENTS (change these to match your game's remotes)
local AttackRemote = ReplicatedStorage:WaitForChild("AttackEvent") -- example remote
local BuyStatsRemote = ReplicatedStorage:WaitForChild("BuyStatsEvent") -- example remote

-- Finds closest mob within range
local function getClosestMob()
    local closestMob = nil
    local shortestDistance = AttackRange
    for _, mob in pairs(workspace.Mobs:GetChildren()) do
        if mob.Name == TargetMobName and mob:FindFirstChild("HumanoidRootPart") then
            local dist = (mob.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            if dist < shortestDistance then
                closestMob = mob
                shortestDistance = dist
            end
        end
    end
    return closestMob
end

-- Move to mob and attack
RunService.Heartbeat:Connect(function()
    if AutoFarm and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local mob = getClosestMob()
        if mob then
            -- Smoothly move near mob
            local targetCFrame = mob.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
            local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Linear)
            local tween = TweenService:Create(LocalPlayer.Character.HumanoidRootPart, tweenInfo, {CFrame = targetCFrame})
            tween:Play()

            -- Attack mob (adjust as per actual remote signature)
            AttackRemote:FireServer(mob)
        end
    end
end)

-- Auto buy stats
spawn(function()
    while AutoBuyStats do
        wait(10)
        BuyStatsRemote:FireServer("Strength") -- change stat as needed
    end
end)

print("Anime Saga AutoFarm script loaded!")
