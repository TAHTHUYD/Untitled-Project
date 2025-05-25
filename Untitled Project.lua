-- Untitled Project: ESP and Aimbot

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Camera = game:GetService("Workspace").CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Settings
local ESPEnabled = true
local AimbotEnabled = true
local FOVRadius = 100
local AimbotStrength = 0.5
local AimbotPrediction = 0.1
local TargetPart = "Head"

-- ESP Functionality
local function createESP(player)
    if player == LocalPlayer then return end
    local character = player.Character
    if not character or not character:FindFirstChild("Head") then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = character.Head
    billboard.Size = UDim2.new(0, 100, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.AlwaysOnTop = true
    billboard.Name = "ESP_" .. player.Name
    billboard.Parent = character

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 1, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = Color3.new(1, 0, 0)
    nameLabel.TextStrokeTransparency = 0.5
    nameLabel.Font = Enum.Font.SourceSansBold
    nameLabel.TextScaled = true
    nameLabel.Parent = billboard
end

local function removeESP(player)
    if player == LocalPlayer then return end
    local character = player.Character
    if character then
        for _, gui in pairs(character:GetChildren()) do
            if gui:IsA("BillboardGui") and gui.Name == "ESP_" .. player.Name then
                gui:Destroy()
            end
        end
    end
end

local function updateESP()
    if ESPEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("Head") then
                if not player.Character:FindFirstChild("ESP_" .. player.Name) then
                    createESP(player)
                end
            end
        end
    else
        for _, player in pairs(Players:GetPlayers()) do
            removeESP(player)
        end
    end
end

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
        local direction = (targetPosition - Camera.CFrame.Position).unit
        local aimCFrame = CFrame.new(Camera.CFrame.Position, targetPosition)
        Camera.CFrame = Camera.CFrame:Lerp(aimCFrame, AimbotStrength)
    end
end

-- Main Loop
RunService.RenderStepped:Connect(function()
    if AimbotEnabled then
        local closestPlayer = getClosestPlayer()
        if closestPlayer then
            aimAtTarget(closestPlayer)
        end
    end
end)

-- Toggle ESP and Aimbot
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.F1 then
        ESPEnabled = not ESPEnabled
        updateESP()
    elseif input.KeyCode == Enum.KeyCode.F2 then
        AimbotEnabled = not AimbotEnabled
    end
end)

-- Initial Setup
updateESP()
