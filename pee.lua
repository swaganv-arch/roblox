-- just shit
local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local StarterGui       = game:GetService("StarterGui")
local CoreGui          = game:GetService("CoreGui")

local LP = Players.LocalPlayer

local ShitEnabled = false
local shitEmitter = nil

local function Notify(title, text)
    StarterGui:SetCore("SendNotification", { Title = title, Text = text, Duration = 2 })
end

local function GetHRP()
    local char = LP.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function KillShitEmitter()
    if shitEmitter and shitEmitter.Parent then
        shitEmitter.Enabled = false
        pcall(function() shitEmitter:Destroy() end)
    end
    shitEmitter = nil
    local hrp = GetHRP()
    if hrp then
        local att = hrp:FindFirstChild("ShitAttach")
        if att then att:Destroy() end
    end
end

local function CreateShitEmitter()
    KillShitEmitter()
    local hrp = GetHRP()
    if not hrp then return end

    local attach = Instance.new("Attachment")
    attach.Name     = "ShitAttach"
    attach.Position = Vector3.new(0, -1.1, 0.45)
    attach.Parent   = hrp

    local emitter = Instance.new("ParticleEmitter")
    emitter.Name      = "ShitEmitter"
    emitter.Texture   = "rbxasset://textures/particles/smoke_main.dds"
    emitter.Color     = ColorSequence.new({
        ColorSequenceKeypoint.new(0,   Color3.fromRGB(120, 72, 30)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(90, 52, 22)),
        ColorSequenceKeypoint.new(1,   Color3.fromRGB(70, 40, 18)),
    })
    emitter.Size      = NumberSequence.new({
        NumberSequenceKeypoint.new(0,   0.35),
        NumberSequenceKeypoint.new(0.7, 0.4),
        NumberSequenceKeypoint.new(1,   0.25),
    })
    emitter.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0,    0.0),
        NumberSequenceKeypoint.new(0.85, 0.1),
        NumberSequenceKeypoint.new(1,    0.85),
    })
    emitter.Lifetime          = NumberRange.new(0.5, 0.9)
    emitter.Rate              = 22
    emitter.Speed             = NumberRange.new(4, 7)
    emitter.SpreadAngle       = Vector2.new(10, 10)
    emitter.Acceleration      = Vector3.new(0, -60, 0)
    emitter.EmissionDirection = Enum.NormalId.Back
    emitter.LockedToPart      = false
    emitter.LightEmission     = 0.0
    emitter.LightInfluence    = 1.0
    emitter.Rotation          = NumberRange.new(0, 360)
    emitter.RotSpeed          = NumberRange.new(-180, 180)
    emitter.Squash            = NumberSequence.new({
        NumberSequenceKeypoint.new(0,   1),
        NumberSequenceKeypoint.new(0.5, 0.75),
        NumberSequenceKeypoint.new(1,   1),
    })
    emitter.Parent = attach

    shitEmitter = emitter
    shitEmitter.Enabled = ShitEnabled
end

local function SetShit(enabled)
    ShitEnabled = enabled
    if enabled then
        CreateShitEmitter()
        if shitEmitter then shitEmitter.Enabled = true end
        Notify("Shit", "ON")
    else
        if shitEmitter then shitEmitter.Enabled = false end
        Notify("Shit", "OFF")
    end
end

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.P then
        SetShit(not ShitEnabled)
    end
end)

-- small gui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ShitGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 10

local btn = Instance.new("TextButton")
btn.Size             = UDim2.new(0, 140, 0, 40)
btn.Position         = UDim2.new(0, 10, 0.5, 0)
btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
btn.BorderSizePixel  = 0
btn.Text             = "Shit [P]"
btn.TextColor3       = Color3.new(1, 1, 1)
btn.TextScaled       = true
btn.Font             = Enum.Font.GothamBold
btn.Active           = true
btn.Draggable        = true
btn.Parent           = ScreenGui

Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

btn.MouseButton1Click:Connect(function()
    SetShit(not ShitEnabled)
    btn.BackgroundColor3 = ShitEnabled and Color3.fromRGB(150, 90, 40) or Color3.fromRGB(30, 30, 30)
end)

if syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = CoreGui
elseif gethui then
    ScreenGui.Parent = gethui()
else
    ScreenGui.Parent = CoreGui
end

LP.CharacterAdded:Connect(function()
    task.wait(1)
    if ShitEnabled then
        ShitEnabled = false
        SetShit(true)
    end
end)

Notify("Shit loaded", "P to toggle")
