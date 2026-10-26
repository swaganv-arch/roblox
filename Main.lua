local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local LP = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "SizeChanger"
gui.ResetOnSpawn = false
gui.DisplayOrder = 9999
pcall(function() if gethui then gui.Parent = gethui() else gui.Parent = CoreGui end end)

local targetSize = 1.0
local isOpen = true
local isBinding = false
local toggleKey = Enum.KeyCode.Equals
local draggingSlider = false
local dragInput = nil

if isfile and readfile then
    pcall(function()
        if isfile("EYZ_Size.txt") then
            local s = tonumber(readfile("EYZ_Size.txt"))
            if s then targetSize = s end
        end
    end)
end

local function saveSize()
    if writefile then pcall(function() writefile("EYZ_Size.txt", tostring(targetSize)) end) end
end

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 220, 0, 110)
main.Position = UDim2.new(0.5, -110, 0.5, -55)
main.BackgroundColor3 = Color3.fromRGB(37, 37, 37)
main.BorderSizePixel = 0
main.Active = false
main.ClipsDescendants = true

local corner = Instance.new("UICorner", main)
corner.CornerRadius = UDim.new(0, 6)
local stroke = Instance.new("UIStroke", main)
stroke.Color = Color3.fromRGB(60, 60, 60)
stroke.Thickness = 1
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local title = Instance.new("TextButton", main)
title.Size = UDim2.new(1, -80, 0, 26)
title.Position = UDim2.new(0, 12, 0, 4)
title.BackgroundTransparency = 1
title.Text = "Size Control"
title.TextColor3 = Color3.fromRGB(240, 240, 240)
title.TextSize = 13
title.Font = Enum.Font.GothamMedium
title.TextXAlignment = Enum.TextXAlignment.Left
title.AutoButtonColor = false
title.Active = false

local keybindBtn = Instance.new("TextButton", main)
keybindBtn.Size = UDim2.new(0, 30, 0, 20)
keybindBtn.Position = UDim2.new(1, -65, 0, 7)
keybindBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
keybindBtn.Text = "="
keybindBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
keybindBtn.Font = Enum.Font.GothamMedium
keybindBtn.TextSize = 12
keybindBtn.BorderSizePixel = 0
keybindBtn.ZIndex = 3
Instance.new("UICorner", keybindBtn).CornerRadius = UDim.new(0, 4)
keybindBtn.MouseEnter:Connect(function() TweenService:Create(keybindBtn, TweenInfo.new(0.1), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play() end)
keybindBtn.MouseLeave:Connect(function() if not isBinding then TweenService:Create(keybindBtn, TweenInfo.new(0.1), {TextColor3 = Color3.fromRGB(200, 200, 200)}):Play() end end)

local triangleBtn = Instance.new("TextButton", main)
triangleBtn.Size = UDim2.new(0, 26, 0, 26)
triangleBtn.Position = UDim2.new(1, -30, 0, 4)
triangleBtn.BackgroundTransparency = 1
triangleBtn.Text = "▼"
triangleBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
triangleBtn.Font = Enum.Font.GothamMedium
triangleBtn.TextSize = 12
triangleBtn.AutoButtonColor = false
triangleBtn.ZIndex = 3
triangleBtn.MouseEnter:Connect(function() TweenService:Create(triangleBtn, TweenInfo.new(0.1), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play() end)
triangleBtn.MouseLeave:Connect(function() TweenService:Create(triangleBtn, TweenInfo.new(0.1), {TextColor3 = Color3.fromRGB(200, 200, 200)}):Play() end)

local expandBtn = Instance.new("Frame", main)
expandBtn.Size = UDim2.new(1, 0, 1, 0)
expandBtn.BackgroundTransparency = 1
expandBtn.Visible = false
expandBtn.ZIndex = 10

local dragTop = Instance.new("Frame", main)
dragTop.Size = UDim2.new(1, 0, 0, 20)
dragTop.Position = UDim2.new(0, 0, 0, 0)
dragTop.BackgroundTransparency = 1
dragTop.Active = true

local dragBot = Instance.new("Frame", main)
dragBot.Size = UDim2.new(1, 0, 0, 20)
dragBot.Position = UDim2.new(0, 0, 1, -20)
dragBot.BackgroundTransparency = 1
dragBot.Active = true

local dragLeft = Instance.new("Frame", main)
dragLeft.Size = UDim2.new(0, 20, 1, 0)
dragLeft.Position = UDim2.new(0, 0, 0, 0)
dragLeft.BackgroundTransparency = 1
dragLeft.Active = true

local dragRight = Instance.new("Frame", main)
dragRight.Size = UDim2.new(0, 20, 1, 0)
dragRight.Position = UDim2.new(1, -20, 0, 0)
dragRight.BackgroundTransparency = 1
dragRight.Active = true

local draggingWindow = false
local isDragging = false
local dragStart = nil
local startPos = nil

local function attachDrag(f)
    f.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingWindow = true
            isDragging = false
            dragStart = input.Position
            startPos = main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    if draggingWindow then
                        draggingWindow = false
                        if not isDragging and f == expandBtn then
                            toggleUI()
                        end
                    end
                end
            end)
        end
    end)
end

attachDrag(dragTop)
attachDrag(dragBot)
attachDrag(dragLeft)
attachDrag(dragRight)
attachDrag(expandBtn)

UIS.InputChanged:Connect(function(input)
    if draggingWindow and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        if delta.Magnitude > 5 then isDragging = true end
        if isDragging then
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end
end)

local sizeBox = Instance.new("TextBox", main)
sizeBox.Size = UDim2.new(0, 44, 0, 22)
sizeBox.Position = UDim2.new(0, 12, 0, 36)
sizeBox.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
sizeBox.Text = string.format("%.1f", targetSize)
sizeBox.TextColor3 = Color3.fromRGB(240, 240, 240)
sizeBox.Font = Enum.Font.GothamMedium
sizeBox.TextSize = 12
sizeBox.BorderSizePixel = 0
sizeBox.ZIndex = 3
Instance.new("UICorner", sizeBox).CornerRadius = UDim.new(0, 4)

local sliderHit = Instance.new("Frame", main)
sliderHit.Size = UDim2.new(0, 144, 0, 24)
sliderHit.Position = UDim2.new(0, 64, 0, 35)
sliderHit.BackgroundTransparency = 1
sliderHit.Active = true
sliderHit.ZIndex = 3

local sliderBg = Instance.new("Frame", sliderHit)
sliderBg.Size = UDim2.new(1, 0, 0, 4)
sliderBg.Position = UDim2.new(0, 0, 0.5, -2)
sliderBg.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
sliderBg.BorderSizePixel = 0
Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)

local sliderFill = Instance.new("Frame", sliderBg)
sliderFill.Size = UDim2.new((targetSize - 0.4) / (4.0 - 0.4), 0, 1, 0)
sliderFill.BackgroundColor3 = Color3.fromRGB(208, 208, 208)
sliderFill.BorderSizePixel = 0
Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(1, 0)

local sliderThumb = Instance.new("Frame", sliderBg)
sliderThumb.Size = UDim2.new(0, 12, 0, 12)
sliderThumb.AnchorPoint = Vector2.new(0.5, 0.5)
sliderThumb.Position = UDim2.new((targetSize - 0.4) / (4.0 - 0.4), 0, 0.5, 0)
sliderThumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
sliderThumb.BorderSizePixel = 0
Instance.new("UICorner", sliderThumb).CornerRadius = UDim.new(1, 0)

local presetFrame = Instance.new("Frame", main)
presetFrame.Size = UDim2.new(1, -24, 0, 22)
presetFrame.Position = UDim2.new(0, 12, 0, 76)
presetFrame.BackgroundTransparency = 1
presetFrame.ZIndex = 3

local function applyServerSize(scale)
    local char = LP.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    pcall(function() char:ScaleTo(scale) end)
    if hum.RigType == Enum.HumanoidRigType.R15 then
        local oldDesc = hum:FindFirstChildOfClass("HumanoidDescription")
        if oldDesc then
            local newDesc = oldDesc:Clone()
            newDesc.BodyHeightScale = scale
            newDesc.BodyWidthScale = scale
            newDesc.BodyDepthScale = scale
            newDesc.HeadScale = scale
            pcall(function() hum:ApplyDescription(newDesc) end)
            task.delay(1, function() if newDesc then newDesc:Destroy() end end)
        end
    end
end

local function applyVisualSize(scale)
    local char = LP.Character
    if char then pcall(function() char:ScaleTo(scale) end) end
end

local function makePreset(text, val, xPos)
    local btn = Instance.new("TextButton", presetFrame)
    btn.Size = UDim2.new(0.31, 0, 1, 0)
    btn.Position = UDim2.new(xPos, 0, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 11
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    btn.MouseEnter:Connect(function() TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(55, 55, 55)}):Play() end)
    btn.MouseLeave:Connect(function() TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(45, 45, 45)}):Play() end)
    btn.MouseButton1Click:Connect(function()
        targetSize = val
        local p = (val - 0.4) / (4.0 - 0.4)
        sizeBox.Text = string.format("%.1f", val)
        sliderFill.Size = UDim2.new(p, 0, 1, 0)
        sliderThumb.Position = UDim2.new(p, 0, 0.5, 0)
        saveSize()
        applyServerSize(targetSize)
    end)
end

makePreset("Small", 0.6, 0)
makePreset("Normal", 1.0, 0.34)
makePreset("Giant", 2.5, 0.69)

local function updateVisuals(pct)
    sliderFill.Size = UDim2.new(pct, 0, 1, 0)
    sliderThumb.Position = UDim2.new(pct, 0, 0.5, 0)
end

function toggleUI()
    isOpen = not isOpen
    draggingSlider = false
    dragInput = nil
    draggingWindow = false
    
    if isOpen then
        title.Visible = true
        keybindBtn.Visible = true
        triangleBtn.Visible = true
        sizeBox.Visible = true
        sliderHit.Visible = true
        presetFrame.Visible = true
        expandBtn.Visible = false
        dragTop.Visible = true
        dragBot.Visible = true
        dragLeft.Visible = true
        dragRight.Visible = true
        
        TweenService:Create(main, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0, 220, 0, 110)}):Play()
        TweenService:Create(corner, TweenInfo.new(0.3), {CornerRadius = UDim.new(0, 6)}):Play()
        TweenService:Create(triangleBtn, TweenInfo.new(0.3), {Position = UDim2.new(1, -30, 0, 4)}):Play()
        triangleBtn.Text = "▼"
    else
        title.Visible = false
        keybindBtn.Visible = false
        sizeBox.Visible = false
        sliderHit.Visible = false
        presetFrame.Visible = false
        triangleBtn.Visible = false
        expandBtn.Visible = true
        dragTop.Visible = false
        dragBot.Visible = false
        dragLeft.Visible = false
        dragRight.Visible = false
        
        TweenService:Create(main, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0, 40, 0, 40)}):Play()
        TweenService:Create(corner, TweenInfo.new(0.3), {CornerRadius = UDim.new(1, 0)}):Play()
    end
end

triangleBtn.MouseButton1Click:Connect(function() if isOpen then toggleUI() end end)

keybindBtn.MouseButton1Click:Connect(function()
    isBinding = true
    keybindBtn.Text = "..."
    keybindBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
end)

UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if isBinding then
        if input.KeyCode ~= Enum.KeyCode.Unknown then
            toggleKey = input.KeyCode
            keybindBtn.Text = input.KeyCode.Name
            isBinding = false
            keybindBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
        return
    end
    if input.KeyCode == toggleKey then
        toggleUI()
    end
end)

sliderHit.InputBegan:Connect(function(input)
    if not isOpen then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingSlider = true
        dragInput = input
        local p = math.clamp((input.Position.X - sliderHit.AbsolutePosition.X) / sliderHit.AbsoluteSize.X, 0, 1)
        targetSize = 0.4 + p * (4.0 - 0.4)
        sizeBox.Text = string.format("%.1f", targetSize)
        updateVisuals(p)
        applyVisualSize(targetSize)
    end
end)

UIS.InputChanged:Connect(function(input)
    if not isOpen then return end
    if draggingSlider and input == dragInput then
        local p = math.clamp((input.Position.X - sliderHit.AbsolutePosition.X) / sliderHit.AbsoluteSize.X, 0, 1)
        targetSize = 0.4 + p * (4.0 - 0.4)
        sizeBox.Text = string.format("%.1f", targetSize)
        updateVisuals(p)
        applyVisualSize(targetSize)
    end
end)

UIS.InputEnded:Connect(function(input)
    if draggingSlider and input == dragInput then
        if isOpen then
            saveSize()
            applyServerSize(targetSize)
        end
        draggingSlider = false
        dragInput = nil
    end
end)

sizeBox.FocusLost:Connect(function()
    local num = tonumber(sizeBox.Text)
    if num then
        num = math.clamp(num, 0.4, 4.0)
        targetSize = num
        sizeBox.Text = string.format("%.1f", num)
        local p = (num - 0.4) / (4.0 - 0.4)
        updateVisuals(p)
        saveSize()
        applyServerSize(targetSize)
    else
        sizeBox.Text = string.format("%.1f", targetSize)
    end
end)
