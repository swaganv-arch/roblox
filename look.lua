-- chinese look
local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local StarterGui       = game:GetService("StarterGui")
local CoreGui          = game:GetService("CoreGui")

local LP = Players.LocalPlayer

local LookEnabled = false
local savedDesc   = nil

local SKIN = Color3.fromRGB(245, 213, 178)  -- warm light East Asian tone

-- hair asset (classic black hair) — pcall'd in case it 404s
local HAIR_ASSET = 16630147
-- a neutral/serious face
local FACE_ASSET = 8560915

local function Notify(title, text)
    StarterGui:SetCore("SendNotification", { Title = title, Text = text, Duration = 2 })
end

local function GetHumanoid()
    local char = LP.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function ApplyLook()
    local hum = GetHumanoid()
    if not hum then return end

    local desc = hum:FindFirstChildOfClass("HumanoidDescription")
    if not desc then
        desc = Instance.new("HumanoidDescription")
        desc.Parent = hum
    end

    -- skin tone across all body parts
    desc.HeadColor    = SKIN
    desc.TorsoColor   = SKIN
    desc.LeftArmColor = SKIN
    desc.RightArmColor = SKIN
    desc.LeftLegColor = SKIN
    desc.RightLegColor = SKIN

    -- slightly rounder head, modest proportions
    desc.HeadScale       = 1.05
    desc.BodyHeightScale = 0.95
    desc.BodyWidthScale  = 0.9
    desc.BodyDepthScale  = 0.9

    -- asset ids — wrapped so failure doesn't kill the whole apply
    pcall(function() desc.Hair = HAIR_ASSET end)
    pcall(function() desc.Face = FACE_ASSET end)

    hum:ApplyDescription(desc)
end

local function SetLook(enabled)
    LookEnabled = enabled
    if enabled then
        ApplyLook()
        Notify("Look", "Applied")
    else
        -- reset to default by clearing the description
        local hum = GetHumanoid()
        if hum then
            pcall(function()
                local fresh = Instance.new("HumanoidDescription")
                fresh.Parent = hum
                hum:ApplyDescription(fresh)
            end)
        end
        Notify("Look", "Reset")
    end
end

LP.CharacterAdded:Connect(function()
    task.wait(1)
    if LookEnabled then ApplyLook() end
end)

-- ── GUI ─────────────────────────────────────────────────────────────────────

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name         = "LookGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 10

local panel = Instance.new("Frame")
panel.Size                   = UDim2.new(0, 200, 0, 100)
panel.Position               = UDim2.new(0, 10, 0.4, 0)
panel.BackgroundColor3       = Color3.fromRGB(15, 15, 15)
panel.BackgroundTransparency = 0.1
panel.BorderSizePixel        = 0
panel.Active                 = true
panel.Draggable              = true
panel.Parent                 = ScreenGui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 10)

local header = Instance.new("Frame")
header.Size             = UDim2.new(1, 0, 0.32, 0)
header.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
header.BorderSizePixel  = 0
header.Parent           = panel
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel")
title.Size                   = UDim2.new(1, 0, 1, 0)
title.BackgroundTransparency = 1
title.Text                   = "LOOK"
title.TextColor3             = Color3.new(1, 1, 1)
title.TextScaled             = true
title.Font                   = Enum.Font.GothamBold
title.Parent                 = header

local lookBtn = Instance.new("TextButton")
lookBtn.Size             = UDim2.new(0.9, 0, 0.4, 0)
lookBtn.Position         = UDim2.new(0.05, 0, 0.45, 0)
lookBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
lookBtn.BorderSizePixel  = 0
lookBtn.Text             = "Chinese Look  [L]"
lookBtn.TextColor3       = Color3.new(1, 1, 1)
lookBtn.TextScaled       = true
lookBtn.Font             = Enum.Font.GothamBold
lookBtn.Parent           = panel
Instance.new("UICorner", lookBtn).CornerRadius = UDim.new(0, 6)

lookBtn.MouseButton1Click:Connect(function()
    SetLook(not LookEnabled)
    lookBtn.BackgroundColor3 = LookEnabled
        and Color3.fromRGB(200, 40, 40)
        or  Color3.fromRGB(30, 30, 30)
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.L then
        SetLook(not LookEnabled)
        lookBtn.BackgroundColor3 = LookEnabled
            and Color3.fromRGB(200, 40, 40)
            or  Color3.fromRGB(30, 30, 30)
    end
end)

if syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = CoreGui
elseif gethui then
    ScreenGui.Parent = gethui()
else
    ScreenGui.Parent = CoreGui
end

Notify("Look loaded", "L to toggle")
