-- Untitled Project: ESP (Box) and Aimbot with M2 Activation and smaller FOV

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Settings
local ESPEnabled = true
local AimbotEnabled = false -- true when M2 held
local FOVRadius = 50 -- smaller FOV for aimbot
local AimbotStrength = 0.5
local TargetPart = "Head"

-- ESP Functionality: Boxes instead of nametags
local ESPBoxes = {}

local function createBox(player)
    if player == LocalPlayer then return end
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end

    local box = Drawing.new("Square")
    box.Visible = true
    box.Color = Color3.new(1, 0, 0) -- red color
    box.Thickness = 2
    box.Transparency = 1
    box.Filled = false

    ESPBoxes[player] = box
end

local function removeBox(player)
    if ESPBoxes[player] then
        ESPBoxes[player]:Remove()
        ESPBoxes[player] = nil
    end
end

local function updateBoxes()
    for _, player in pairs(Players:GetPlayers()) do
        if ESPEnabled and player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            if not ESPBoxes[player] then
                createBox(player)
            end
        else
            removeBox(player)
        end
    end
end

-- Update box position every frame
RunService.RenderStepped:Connect(function()
    if ESPEnabled then
        for player, box in pairs(ESPBoxes) do
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                local rootPart = character.HumanoidRootPart
                local pos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
                if onScreen then
                    local sizeFactor = 200 / pos.Z -- scale box size based on distance (pos.Z)
                    local boxSize = Vector2.new(50 * sizeFactor, 100 * sizeFactor) -- width, height
                    
                    box.Position = Vector2.new(pos.X - boxSize.X / 2, pos.Y - boxSize.Y / 2)
                    box.Size = boxSize
                    box.Visible = true
                else
                    box.Visible = false
                end
            else
                box.Visible = false
            end
        end
    else
        for _, box in pairs(ESPBoxes) do
            box.Visible = false
        end
    end
end)

-- Aimbot Functionality
local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = FOVRadius
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(TargetPart) then
            local screenPos, onScreen = Camera:WorldToScreenPoint(player.Character[TargetPart].Position)
            if onScreen then
                local distance = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                if distance < shortestDistance then
                    closestPlayer = player
                    shortestDistance = distance
                end
            end
        end
    end
    return closestPlayer
end

local function aimAtTarget(target)
    if target and target.Character and target.Character:FindFirstChild(TargetPart) then
        local targetPosition = target.Character[TargetPart].Position
        local aimCFrame = CFrame.new(Camera.CFrame.Position, targetPosition)
        Camera.CFrame = Camera.CFrame:Lerp(aimCFrame, AimbotStrength)
    end
end

-- Detect M2 hold to enable/disable aimbot
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        AimbotEnabled = true
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        AimbotEnabled = false
    end
end)

-- Toggle ESP with F1
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F1 then
        ESPEnabled = not ESPEnabled
        updateBoxes()
    end
end)

-- Main Loop for aimbot
RunService.RenderStepped:Connect(function()
    if AimbotEnabled then
        local closestPlayer = getClosestPlayer()
        if closestPlayer then
            aimAtTarget(closestPlayer)
        end
    end
end)

-- Initial ESP Setup
updateBoxes()
