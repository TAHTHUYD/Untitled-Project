local function updateBoxes()
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
end
