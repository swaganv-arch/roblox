-- fly
local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local StarterGui       = game:GetService("StarterGui")
local CoreGui          = game:GetService("CoreGui")

local LP     = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local FlyEnabled = false
local FlySpeed   = 50
local BodyVel    = nil
local BodyGyro   = nil

local Keys = {
    W = false, A = false, S = false, D = false,
    Space = false, LeftCtrl = false
}

local function Notify(title, text)
    StarterGui:SetCore("SendNotification", { Title = title, Text = text, Duration = 2 })
end

local function GetHRP()
    local char = LP.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function StartFly()
    local hrp = GetHRP()
    if not hrp then return end

    BodyVel = Instance.new("BodyVelocity")
    BodyVel.Name        = "FlyBV"
    BodyVel.MaxAxesForce = Vector3.new(1e5, 1e5, 1e5)
    BodyVel.Velocity    = Vector3.zero
    BodyVel.P         = 1250
    BodyVel.Parent      = hrp

    BodyGyro = Instance.new("BodyGyro")
    BodyGyro.Name       = "FlyBG"
    BodyGyro.MaxTorque  = Vector3.new(1e5, 1e5, 1e5)
    BodyGyro.P          = 3000
    BodyGyro.D          = 200
    BodyGyro.CFrame     = hrp.CFrame
    BodyGyro.Parent     = hrp

    FlyEnabled = true
    Notify("Fly", "ON")
end

local function StopFly()
    FlyEnabled = false
    if BodyVel then BodyVel:Destroy(); BodyVel = nil end
    if BodyGyro then BodyGyro:Destroy(); BodyGyro = nil end
    Notify("Fly", "OFF")
end

local function ToggleFly()
    if FlyEnabled then StopFly() else StartFly() end
end

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    local k = input.KeyCode
    if k == Enum.KeyCode.W then Keys.W = true
    elseif k == Enum.KeyCode.A then Keys.A = true
    elseif k == Enum.KeyCode.S then Keys.S = true
    elseif k == Enum.KeyCode.D then Keys.D = true
    elseif k == Enum.KeyCode.Space then Keys.Space = true
    elseif k == Enum.KeyCode.LeftControl then Keys.LeftCtrl = true
    elseif k == Enum.KeyCode.F then ToggleFly()
    end
end)

UserInputService.InputEnded:Connect(function(input)
    local k = input.KeyCode
    if k == Enum.KeyCode.W then Keys.W = false
    elseif k == Enum.KeyCode.A then Keys.A = false
    elseif k == Enum.KeyCode.S then Keys.S = false
    elseif k == Enum.KeyCode.D then Keys.D = false
    elseif k == Enum.KeyCode.Space then Keys.Space = false
    elseif k == Enum.KeyCode.LeftControl then Keys.LeftCtrl = false
    end
end)

RunService.RenderStepped:Connect(function()
    if not FlyEnabled then return end
    local hrp = GetHRP()
    if not hrp or not BodyVel or not BodyGyro then return end

    -- keep humanoid grounded-state off so anim doesn't fight
    local hum = hrp.Parent:FindFirstChildOfClass("Humanoid")
    if hum then hum.PlatformStand = true end

    BodyGyro.CFrame = Camera.CFrame

    local dir = Vector3.zero
    if Keys.W then dir += Camera.CFrame.LookVector end
    if Keys.S then dir -= Camera.CFrame.LookVector end
    if Keys.A then dir -= Camera.CFrame.RightVector end
    if Keys.D then dir += Camera.CFrame.RightVector end
    if Keys.Space then dir += Vector3.yAxis end
    if Keys.LeftCtrl then dir -= Vector3.yAxis end

    if dir.Magnitude > 0 then
        BodyVel.Velocity = dir.Unit * FlySpeed
    else
        BodyVel.Velocity = Vector3.zero
    end
end)

LP.CharacterAdded:Connect(function()
    if FlyEnabled then
        FlyEnabled = false
        task.wait(1)
        StartFly()
    end
end)

-- ── GUI ─────────────────────────────────────────────────────────────────────

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name         = "FlyGui"
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
title.Text                   = "FLY"
title.TextColor3             = Color3.new(1, 1, 1)
title.TextScaled             = true
title.Font                   = Enum.Font.GothamBold
title.Parent                 = header

local flyBtn = Instance.new("TextButton")
flyBtn.Size             = UDim2.new(0.9, 0, 0.28, 0)
flyBtn.Position         = UDim2.new(0.05, 0, 0.32, 0)
flyBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
flyBtn.BorderSizePixel  = 0
flyBtn.Text             = "Fly  [F]"
flyBtn.TextColor3       = Color3.new(1, 1, 1)
flyBtn.TextScaled       = true
flyBtn.Font             = Enum.Font.GothamBold
flyBtn.Parent           = panel
Instance.new("UICorner", flyBtn).CornerRadius = UDim.new(0, 6)

flyBtn.MouseButton1Click:Connect(function()
    ToggleFly()
    flyBtn.BackgroundColor3 = FlyEnabled and Color3.fromRGB(50, 180, 90) or Color3.fromRGB(30, 30, 30)
end)

local speedLabel = Instance.new("TextLabel")
speedLabel.Size                   = UDim2.new(0.9, 0, 0.12, 0)
speedLabel.Position               = UDim2.new(0.05, 0, 0.62, 0)
speedLabel.BackgroundTransparency = 1
speedLabel.Text                   = "Speed: " .. FlySpeed
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

local fill = Instance.new("Frame")
fill.Size             = UDim2.new(0.5, 0, 1, 0)  -- 50 default
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
        fill.Size = UDim2.new(rel, 0, 1, 0)
        FlySpeed  = math.floor(10 + rel * 190) -- 10 to 200
        speedLabel.Text = "Speed: " .. FlySpeed
    end
end)

local hint = Instance.new("TextLabel")
hint.Size                   = UDim2.new(1, 0, 0.08, 0)
hint.Position               = UDim2.new(0, 0, 0.92, 0)
hint.BackgroundTransparency = 1
hint.Text                   = "WASD + Space/Ctrl"
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

Notify("Fly loaded", "F to toggle")
