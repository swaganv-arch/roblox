-- chinese look (hardened)
local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local StarterGui       = game:GetService("StarterGui")
local CoreGui          = game:GetService("CoreGui")

local LP = Players.LocalPlayer

local LookEnabled = false
local busy        = false

local SKIN = Color3.fromRGB(245, 213, 178)

local HAIR_ASSET = 16630147
local FACE_ASSET = 8560915

local function Notify(title, text)
    StarterGui:SetCore("SendNotification", { Title = title, Text = text, Duration = 2 })
end

local function GetHumanoid()
    local char = LP.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function ApplyLook()
    if busy then return end
    local hum = GetHumanoid()
    if not hum then return end
    if hum.RigType ~= Enum.HumanoidRigType.R15 then
        Notify("Look", "R15 only — skipped")
        return
    end

    busy = true

    local desc = Instance.new("HumanoidDescription")
    desc.HeadColor     = SKIN
    desc.TorsoColor    = SKIN
    desc.LeftArmColor  = SKIN
    desc.RightArmColor = SKIN
    desc.LeftLegColor  = SKIN
    desc.RightLegColor = SKIN

    desc.HeadScale       = 1.05
    desc.BodyHeightScale = 0.95
    desc.BodyWidthScale  = 0.9
    desc.BodyDepthScale  = 0.9

    pcall(function() desc.Hair = HAIR_ASSET end)
    pcall(function() desc.Face = FACE_ASSET end)

    task.wait() -- let description settle before apply[reference:3]

    local ok, err = pcall(function()
        hum:ApplyDescription(desc)
    end)

    desc:Destroy()

    busy = false

    if ok then
        Notify("Look", "Applied")
    else
        Notify("Look", "Failed — asset rejected")
        warn("ApplyDescription error: " .. tostring(err))
    end
end

local function ResetLook()
    if busy then return end
    local hum = GetHumanoid()
    if not hum then return end
    busy = true
    pcall(function()
        local fresh = Instance.new("HumanoidDescription")
        hum:ApplyDescription(fresh)
        fresh:Destroy()
    end)
    busy = false
    Notify("Look", "Reset")
end

local function SetLook(enabled)
    LookEnabled = enabled
    if enabled then ApplyLook() else ResetLook() end
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
