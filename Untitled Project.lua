local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Settings
local AutoFarmEnabled = true
local AutoBuyEnabled = true
local TargetMobName = "Spawned Mob" -- Change to actual mob name in-game
local FarmingRange = 50 -- distance range to auto-attack mobs

-- References to remote events/functions (adjust names as per the game)
local AttackEvent = ReplicatedStorage:WaitForChild("AttackEvent") -- example remote event
local BuyStatsEvent = ReplicatedStorage:WaitForChild("BuyStatsEvent") -- example buy event

-- Function to find closest mob
local function getClosestMob()
    local closestMob = nil
    local shortestDistance = FarmingRange
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

-- Auto farm loop
RunService.Heartbeat:Connect(function()
    if AutoFarmEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local mob = getClosestMob()
        if mob then
            -- Move close to mob
            LocalPlayer.Character.HumanoidRootPart.CFrame = mob.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
            
            -- Attack mob
            AttackEvent:FireServer(mob)
        end
    end
end)

-- Auto buy stats loop
spawn(function()
    while AutoBuyEnabled do
        wait(10) -- adjust timing
        
        -- Example: Buy Strength stat
        BuyStatsEvent:FireServer("Strength")
        
        -- Add other stats if needed
        -- BuyStatsEvent:FireServer("Stamina")
        -- BuyStatsEvent:FireServer("Agility")
    end
end)

print("Anime Saga auto farm script running!")
