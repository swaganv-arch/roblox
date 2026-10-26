-- speed
local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local StarterGui       = game:GetService("StarterGui")
local CoreGui          = game:GetService("CoreGui")

local LP = Players.LocalPlayer

local SpeedEnabled = false
local SpeedValue   = 60

local function Notify(title, text)
    StarterGui:SetCore("SendNotification", { Title = title, Text = text, Duration = 2 })
end

local function GetHumanoid()
    local char = LP.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function ApplySpeed()
    local hum = GetHumanoid()
    if not hum then return end
    hum.WalkSpeed = SpeedEnabled and SpeedValue or 16
end

local function SetSpeed(enabled)
    SpeedEnabled = enabled
    ApplySpeed()
    Notify("Speed", enabled and ("ON — " .. SpeedValue) or "OFF")
end

-- keep applying every frame so game scripts don't reset it
RunService.Heartbeat:Connect(function()
    if not SpeedEnabled then return end
    local hum = GetHumanoid()
    if hum and hum.WalkSpeed ~= SpeedValue then
        hum.WalkSpeed = SpeedValue
    end
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.F then
        SetSpeed(not SpeedEnabled)
    end
end)

LP.CharacterAdded:Connect(function()
    task.wait(1)
    ApplySpeed()
end)

-- ── GUI ─────────────────────────────────────────────────────────────────────

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name         = "SpeedGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 10

local panel = Instance.new("Frame")
panel.Size                   = UDim2.new(0, 200, 0, 130)
panel.Position               = UDim2.new(0, 10, 0.4, 0)
panel.BackgroundColor3       = Color3.fromRGB(15, 15, 15)
panel.BackgroundTransparency = 0.1
panel.BorderSizePixel        = 0
panel.Active                 = true
panel.Draggable              = true
panel.Parent                 = ScreenGui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 10)

local header = Instance.new("Frame")
header.Size             = UDim2.new(1, 0, 0.25, 0)
header.BackgroundColor3 = Color3.fromRGB(60, 120, 220)
header.BorderSizePixel  = 0
header.Parent           = panel
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel")
title.Size                   = UDim2.new(1, 0, 1, 0)
title.BackgroundTransparency = 1
title.Text                   = "SPEED"
title.TextColor3             = Color3.new(1, 1, 1)
title.TextScaled             = true
title.Font                   = Enum.Font.GothamBold
title.Parent                 = header

local speedBtn = Instance.new("TextButton")
speedBtn.Size             = UDim2.new(0.9, 0, 0.28, 0)
speedBtn.Position         = UDim2.new(0.05, 0, 0.32, 0)
speedBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
speedBtn.BorderSizePixel  = 0
speedBtn.Text             = "Speed  [F]"
speedBtn.TextColor3       = Color3.new(1, 1, 1)
speedBtn.TextScaled       = true
speedBtn.Font             = Enum.Font.GothamBold
speedBtn.Parent           = panel
Instance.new("UICorner", speedBtn).CornerRadius = UDim.new(0, 6)

speedBtn.MouseButton1Click:Connect(function()
    SetSpeed(not SpeedEnabled)
    speedBtn.BackgroundColor3 = SpeedEnabled and Color3.fromRGB(50, 180, 90) or Color3.fromRGB(30, 30, 30)
end)

local speedLabel = Instance.new("TextLabel")
speedLabel.Size                   = UDim2.new(0.9, 0, 0.12, 0)
speedLabel.Position               = UDim2.new(0.05, 0, 0.62, 0)
speedLabel.BackgroundTransparency = 1
speedLabel.Text                   = "Value: " .. SpeedValue
speedLabel.TextColor3             = Color3.fromRGB(200, 200, 200)
speedLabel.TextScaled             = true
speedLabel.Font                   = Enum.Font.Gotham
speedLabel.Parent                 = panel

local slider = Instance.new("Frame")
slider.Size             = UDim2.new(0.9, 0, 0.12, 0)
slider.Position         = UDim2.new(0.05, 0, 0.78, 0)
slider.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
slider.BorderSizePixel  = 0
slider.Parent           = panel
Instance.new("UICorner", slider).CornerRadius = UDim.new(1, 0)

-- default fill for 60 in a 16..400 range = (60-16)/384 ≈ 0.1146
local fill = Instance.new("Frame")
fill.Size             = UDim2.new(0.1146, 0, 1, 0)
fill.BackgroundColor3 = Color3.fromRGB(60, 120, 220)
fill.BorderSizePixel  = 0
fill.Parent           = slider
Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

local drag = false
slider.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        drag = true
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        drag = false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if drag and input.UserInputType == Enum.UserInputType.MouseMovement then
        local rel = math.clamp((input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
        fill.Size    = UDim2.new(rel, 0, 1, 0)
        SpeedValue   = math.floor(16 + rel * 384) -- 16 to 400
        speedLabel.Text = "Value: " .. SpeedValue
        if SpeedEnabled then ApplySpeed() end
    end
end)

local hint = Instance.new("TextLabel")
hint.Size                   = UDim2.new(1, 0, 0.08, 0)
hint.Position               = UDim2.new(0, 0, 0.92, 0)
hint.BackgroundTransparency = 1
hint.Text                   = "drag slider, F to toggle"
hint.TextColor3             = Color3.fromRGB(120, 120, 120)
hint.TextScaled             = true
hint.Font                   = Enum.Font.Gotham
hint.Parent                 = panel

if syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = CoreGui
elseif gethui then
    ScreenGui.Parent = gethui()
else
    ScreenGui.Parent = CoreGui
end

Notify("Speed loaded", "F to toggle")
