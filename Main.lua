local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LP = Players.LocalPlayer

local S = { size = 1.0 }
local function getChar() return LP.Character end
local function getHum() local c=getChar(); return c and c:FindFirstChildOfClass("Humanoid") end

-- دالة تغيير الحجم
local function applySize(scale)
    S.size = scale
    local char, hum = getChar(), getHum()
    if not char or not hum then return end
    if hum.RigType == Enum.HumanoidRigType.R15 then
        local desc = hum:FindFirstChildOfClass("HumanoidDescription")
        if not desc then desc = Instance.new("HumanoidDescription"); desc.Parent = hum end
        desc.BodyHeightScale = scale; desc.BodyWidthScale = scale
        desc.BodyDepthScale = scale; desc.HeadScale = scale
        pcall(function() hum:ApplyDescription(desc) end)
    else
        pcall(function() char:ScaleTo(scale) end)
    end
end

-- حلقة تثبيت الحجم (عشان ما يرجعه السيرفر)
task.spawn(function()
    while true do
        task.wait(0.5)
        if getHum() then
            local hum = getHum()
            local desc = hum:FindFirstChildOfClass("HumanoidDescription")
            if desc and math.abs(desc.BodyHeightScale - S.size) > 0.1 then
                applySize(S.size)
            end
        end
    end
end)

-- واجهة المستخدم
local COL = {bg = Color3.fromRGB(15, 15, 20), panel = Color3.fromRGB(25, 25, 35), acc = Color3.fromRGB(0, 200, 255), txt = Color3.fromRGB(255, 255, 255), bad = Color3.fromRGB(255, 60, 60)}
local gui = Instance.new("ScreenGui")
gui.Name = "SizeChanger"; gui.ResetOnSpawn = false; gui.DisplayOrder = 999
pcall(function() if gethui then gui.Parent = gethui() else gui.Parent = CoreGui end end)

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 220, 0, 90); main.Position = UDim2.new(0.5, -110, 0.5, -45)
main.BackgroundColor3 = COL.bg; main.BorderSizePixel = 0; main.Active = true; main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)
local stroke = Instance.new("UIStroke", main); stroke.Color = COL.acc; stroke.Thickness = 1.5

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, -40, 0, 30); title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1; title.Text = "Player Size"; title.TextColor3 = COL.acc; title.Font = Enum.Font.SourceSansBold; title.TextSize = 14; title.TextXAlignment = Enum.TextXAlignment.Left

-- زر الإغلاق (الطي)
local hideBtn = Instance.new("TextButton", main)
hideBtn.Size = UDim2.new(0, 20, 0, 20); hideBtn.Position = UDim2.new(1, -25, 5, 0)
hideBtn.BackgroundTransparency = 1; hideBtn.Text = "-"; hideBtn.TextColor3 = COL.txt; hideBtn.Font = Enum.Font.SourceSansBold; hideBtn.TextSize = 20

-- زر الاستعادة (يظهر لما تطوي القائمة)
local restoreBtn = Instance.new("TextButton", gui)
restoreBtn.Size = UDim2.new(0, 40, 0, 40); restoreBtn.Position = UDim2.new(0.5, -20, 0.9, 0)
restoreBtn.BackgroundColor3 = COL.bg; restoreBtn.Text = "S"; restoreBtn.TextColor3 = COL.acc; restoreBtn.Font = Enum.Font.SourceSansBold; restoreBtn.TextSize = 16
restoreBtn.Visible = false; restoreBtn.Active = true; restoreBtn.Draggable = true
Instance.new("UICorner", restoreBtn).CornerRadius = UDim.new(1, 0)
local rStroke = Instance.new("UIStroke", restoreBtn); rStroke.Color = COL.acc; rStroke.Thickness = 1.5

hideBtn.MouseButton1Click:Connect(function() main.Visible = false; restoreBtn.Visible = true end)
restoreBtn.MouseButton1Click:Connect(function() main.Visible = true; restoreBtn.Visible = false end)

-- صندوق الكتابة
local textBox = Instance.new("TextBox", main)
textBox.Size = UDim2.new(0, 50, 0, 24); textBox.Position = UDim2.new(0, 10, 0, 40)
textBox.BackgroundColor3 = COL.panel; textBox.Text = "1.0"; textBox.TextColor3 = COL.txt; textBox.Font = Enum.Font.SourceSansBold; textBox.TextSize = 14
textBox.BorderSizePixel = 0; textBox.ClearTextOnFocus = false
Instance.new("UICorner", textBox).CornerRadius = UDim.new(0, 4)

-- شريط التمرير (Slider)
local sliderBg = Instance.new("Frame", main)
sliderBg.Size = UDim2.new(1, -90, 0, 8); sliderBg.Position = UDim2.new(0, 70, 0, 48)
sliderBg.BackgroundColor3 = COL.panel; sliderBg.BorderSizePixel = 0
Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)

local sliderFill = Instance.new("Frame", sliderBg)
sliderFill.Size = UDim2.new((1.0 - 0.4) / (4.0 - 0.4), 0, 1, 0); sliderFill.BackgroundColor3 = COL.acc; sliderFill.BorderSizePixel = 0
Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(1, 0)

local dragging = false
local function updateSlider(val)
    val = math.clamp(val, 0.4, 4.0)
    textBox.Text = string.format("%.1f", val)
    sliderFill.Size = UDim2.new((val - 0.4) / (4.0 - 0.4), 0, 1, 0)
    applySize(val)
end

sliderBg.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        local p = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
        updateSlider(0.4 + p * (4.0 - 0.4))
    end
end)
UIS.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local p = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
        updateSlider(0.4 + p * (4.0 - 0.4))
    end
end)
UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

textBox.FocusLost:Connect(function()
    local num = tonumber(textBox.Text)
    if num then updateSlider(num) else textBox.Text = string.format("%.1f", S.size) end
end)

print("[Size Changer] Loaded. Works locally first.")
