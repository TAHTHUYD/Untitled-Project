local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Settings
local AimbotEnabled = false
local ESPEnabled = true
local AimbotFOV = 70
local AimbotStrength = 0.3
local TargetPart = "Head"

-- Create crosshair
local crosshairH = Drawing.new("Line")
crosshairH.From = Vector2.new(Camera.ViewportSize.X / 2 - 10, Camera.ViewportSize.Y / 2)
crosshairH.To = Vector2.new(Camera.ViewportSize.X / 2 + 10, Camera.ViewportSize.Y / 2)
crosshairH.Color = Color3.new(1, 1, 1)
crosshairH.Thickness = 2

local crosshairV = Drawing.new("Line")
crosshairV.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2 - 10)
crosshairV.To = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2 + 10)
crosshairV.Color = Color3.new(1, 1, 1)
crosshairV.Thickness = 2

-- ESP boxes
local ESPBoxes = {}

local function createBox(player)
    if player == LocalPlayer then return end
    local box = Drawing.new("Square")
    box.Visible = true
    box.Color = Color3.new(0, 1, 0)
    box.Thickness = 2
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
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            if not ESPBoxes[player] then
                createBox(player)
            end
        else
            removeBox(player)
        end
    end
end

RunService.RenderStepped:Connect(function()
    if ESPEnabled then
        for player, box in pairs(ESPBoxes) do
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("Head") then
                local rootPos, rootOnScreen = Camera:WorldToViewportPoint(character.HumanoidRootPart.Position)
                local headPos, headOnScreen = Camera:WorldToViewportPoint(character.Head.Position)

                if rootOnScreen and headOnScreen then
                    local height = (headPos.Y - rootPos.Y)
                    local width = height / 2  -- approximate width relative to height

                    local boxPos = Vector2.new(rootPos.X - width / 2, rootPos.Y)
                    local boxSize = Vector2.new(width, height)

                    box.Position = boxPos
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

-- Aimbot
local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = AimbotFOV
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

RunService.RenderStepped:Connect(function()
    if AimbotEnabled then
        local target = getClosestPlayer()
        if target then
            aimAtTarget(target)
        end
    end
end)

updateBoxes()
