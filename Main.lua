local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local WS = workspace
local LP = Players.LocalPlayer
local Cam = WS.CurrentCamera

-- ═══════ CONFIGURATION ═══════
local S = {
    esp = true, box = true, skel = true, hp = true, name = true, dist = true, tracer = false,
    colorIdx = 1, rainbow = false,
    aim = false, aimFOV = 120, aimSmooth = 0.2, aimPart = "HumanoidRootPart",
    speed = false, speedVal = 28, jump = 50, infJump = false,
    fly = false, flySpeed = 60, noclip = false, size = 1.0,
    glow = false, invis = false, hideHead = false, hideLLeg = false, hideRLeg = false,
    fullbright = false, bodyColor = 1, dancing = false
}

local colors = {
    Color3.fromRGB(0, 255, 100), Color3.fromRGB(0, 200, 255), 
    Color3.fromRGB(255, 50, 50), Color3.fromRGB(255, 255, 50), 
    Color3.fromRGB(200, 50, 255)
}

local bodyColors = {
    Color3.fromRGB(255, 0, 0), Color3.fromRGB(0, 0, 255), 
    Color3.fromRGB(0, 255, 0), Color3.fromRGB(0, 0, 0), 
    Color3.fromRGB(255, 255, 255), Color3.fromRGB(255, 165, 0),
    Color3.fromRGB(128, 0, 128), Color3.fromRGB(255, 192, 203)
}

local function getChar() return LP.Character end
local function getHum() local c = getChar(); return c and c:FindFirstChildOfClass("Humanoid") end
local function getHRP() local c = getChar(); return c and c:FindFirstChild("HumanoidRootPart") end

-- ═══════ ESP SYSTEM ═══════
local espObjs = {}
local HAS_DRW = pcall(function() return Drawing.new("Square") end)

local function clearESP()
    for _, e in pairs(espObjs) do
        for _, o in pairs(e) do 
            if type(o) == "table" and o.Remove then pcall(function() o:Remove() end) end 
        end
        if e.bones then 
            for _, b in ipairs(e.bones) do pcall(function() b:Remove() end) end 
        end
    end
    espObjs = {}
end

local function initESP()
    clearESP()
    if not HAS_DRW then return end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP then
            local e = {
                box = Drawing.new("Square"), name = Drawing.new("Text"), 
                dist = Drawing.new("Text"), hpBar = Drawing.new("Square"), 
                tracer = Drawing.new("Line"), bones = {}, plr = p
            }
            e.box.Visible = false; e.box.Thickness = 1.5
            e.name.Visible = false; e.name.Size = 14; e.name.Center = true; e.name.Outline = true
            e.dist.Visible = false; e.dist.Size = 12; e.dist.Center = true; e.dist.Outline = true
            e.hpBar.Visible = false; e.hpBar.Filled = true
            e.tracer.Visible = false; e.tracer.Thickness = 1
            for i = 1, 14 do 
                local l = Drawing.new("Line"); l.Visible = false; l.Thickness = 1.5; table.insert(e.bones, l) 
            end
            table.insert(espObjs, e)
        end
    end
end

local R15_Bones = {
    {"Head","UpperTorso"},{"UpperTorso","LowerTorso"},{"UpperTorso","LeftUpperArm"},
    {"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},{"UpperTorso","RightUpperArm"},
    {"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},{"LowerTorso","LeftUpperLeg"},
    {"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},{"LowerTorso","RightUpperLeg"},
    {"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"}
}
local R6_Bones = {
    {"Head","Torso"},{"Torso","Left Arm"},{"Torso","Right Arm"},
    {"Torso","Left Leg"},{"Torso","Right Leg"}
}

local function updateESP()
    if not HAS_DRW then return end
    local c = S.rainbow and Color3.fromHSV((tick() * 0.5) % 1, 1, 1) or colors[S.colorIdx]
    for _, e in ipairs(espObjs) do
        local ch = e.plr.Character
        local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
        local head = ch and ch:FindFirstChild("Head")
        local hum = ch and ch:FindFirstChildOfClass("Humanoid")
        local show = S.esp and hrp and head and hum and hum.Health > 0
        
        if show then
            local d = (getHRP().Position - hrp.Position).Magnitude
            if d < 1000 then
                local top, tv = Cam:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                local bot, bv = Cam:WorldToViewportPoint(hrp.Position - Vector3.new(0, 2.5, 0))
                
                if tv and bv then
                    local bh = math.abs(top.Y - bot.Y)
                    local bw = bh * 0.55
                    local bx = top.X - bw / 2
                    local by = top.Y
                    
                    e.box.Visible = S.box
                    if S.box then e.box.Color = c; e.box.Size = Vector2.new(bw, bh); e.box.Position = Vector2.new(bx, by) end
                    e.name.Visible = S.name
                    if S.name then e.name.Text = e.plr.Name; e.name.Position = Vector2.new(top.X, by - 18); e.name.Color = c end
                    e.dist.Visible = S.dist
                    if S.dist then e.dist.Text = string.format("%.0fm", d / 3.5); e.dist.Position = Vector2.new(top.X, bot.Y + 2); e.dist.Color = c end
                    e.hpBar.Visible = S.hp
                    if S.hp then 
                        e.hpBar.Size = Vector2.new(4, bh * (hum.Health / hum.MaxHealth))
                        e.hpBar.Position = Vector2.new(bx - 8, by + bh * (1 - hum.Health / hum.MaxHealth))
                        e.hpBar.Color = Color3.new(1 - hum.Health / hum.MaxHealth, hum.Health / hum.MaxHealth, 0)
                    end
                    e.tracer.Visible = S.tracer
                    if S.tracer then 
                        e.tracer.From = Vector2.new(Cam.ViewportSize.X / 2, Cam.ViewportSize.Y)
                        e.tracer.To = Vector2.new(top.X, by + bh)
                        e.tracer.Color = c 
                    end
                    
                    local bns = (hum.RigType == Enum.HumanoidRigType.R15) and R15_Bones or R6_Bones
                    for i = 1, #e.bones do
                        if S.skel and i <= #bns then
                            local p1, p2 = ch:FindFirstChild(bns[i][1]), ch:FindFirstChild(bns[i][2])
                            if p1 and p2 then
                                local s1, v1 = Cam:WorldToViewportPoint(p1.Position)
                                local s2, v2 = Cam:WorldToViewportPoint(p2.Position)
                                if v1 and v2 then
                                    e.bones[i].Visible = true
                                    e.bones[i].From = Vector2.new(s1.X, s1.Y)
                                    e.bones[i].To = Vector2.new(s2.X, s2.Y)
                                    e.bones[i].Color = c
                                else e.bones[i].Visible = false end
                            else e.bones[i].Visible = false end
                        else e.bones[i].Visible = false end
                    end
                else
                    e.box.Visible = false; e.name.Visible = false; e.dist.Visible = false; e.hpBar.Visible = false; e.tracer.Visible = false
                    for _, b in ipairs(e.bones) do b.Visible = false end
                end
            else
                e.box.Visible = false; e.name.Visible = false; e.dist.Visible = false; e.hpBar.Visible = false; e.tracer.Visible = false
                for _, b in ipairs(e.bones) do b.Visible = false end
            end
        else
            e.box.Visible = false; e.name.Visible = false; e.dist.Visible = false; e.hpBar.Visible = false; e.tracer.Visible = false
            for _, b in ipairs(e.bones) do b.Visible = false end
        end
    end
end

initESP()
Players.PlayerAdded:Connect(initESP)

-- ═══════ MECHANICS & SIZE FIX ═══════
local aimKeyHeld = false
local origTrans = {}

local function applySize(scale)
    S.size = scale
    local char, hum = getChar(), getHum()
    if not char or not hum then return end
    
    if hum.RigType == Enum.HumanoidRigType.R15 then
        local desc = hum:FindFirstChildOfClass("HumanoidDescription")
        if not desc then desc = Instance.new("HumanoidDescription"); desc.Parent = hum end
        desc.BodyHeightScale = scale; desc.BodyWidthScale = scale; desc.BodyDepthScale = scale; desc.HeadScale = scale
        pcall(function() hum:ApplyDescription(desc) end)
    end
    
    local hrp = getHRP()
    if hrp and scale < 1 then
        local offset = (2.5 - (2.5 * scale)) + 0.5
        task.spawn(function()
            task.wait(0.1)
            if hrp and hrp.Parent then
                local ray = Ray.new(hrp.Position, Vector3.new(0, -10, 0))
                local hit, pos = workspace:FindPartOnRay(ray, char)
                if hit then hrp.CFrame = CFrame.new(pos + Vector3.new(0, offset, 0)) end
            end
        end)
    end
end

local function updateVisuals()
    local ch = getChar()
    if not ch then return end
    for _, p in pairs(ch:GetDescendants()) do
        if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
            local isH = p.Name == "Head" and S.hideHead
            local isL = (p.Name == "Left Leg" or p.Name == "LeftLowerLeg") and S.hideLLeg
            local isR = (p.Name == "Right Leg" or p.Name == "RightLowerLeg") and S.hideRLeg
            p.Transparency = (S.invis or isH or isL or isR) and 1 or (origTrans[p] or 0)
        elseif p:IsA("Decal") then
            p.Transparency = (S.invis or (p.Parent and p.Parent.Name == "Head" and S.hideHead)) and 1 or (origTrans[p] or 0)
        end
    end
end

local function setupTrans(ch)
    origTrans = {}
    for _, p in pairs(ch:GetDescendants()) do
        if p:IsA("BasePart") or p:IsA("Decal") then origTrans[p] = p.Transparency end
    end
end

if getChar() then setupTrans(getChar()) end
LP.CharacterAdded:Connect(function(c)
    task.wait(1)
    setupTrans(c)
    applySize(S.size)
end)

-- ═══════ MAIN LOOPS ═══════
RS.RenderStepped:Connect(function(dt)
    updateESP()
    
    -- Aim Logic (E Key)
    if S.aim and aimKeyHeld then
        local cl, b = nil, S.aimFOV
        local center = Vector2.new(Cam.ViewportSize.X / 2, Cam.ViewportSize.Y / 2)
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LP and p.Character and p.Character:FindFirstChild(S.aimPart) then
                local sp, vis = Cam:WorldToViewportPoint(p.Character[S.aimPart].Position)
                if vis then
                    local d = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                    if d < b then b = d; cl = p.Character[S.aimPart] end
                end
            end
        end
        if cl then
            local tcf = CFrame.new(Cam.CFrame.Position, cl.Position)
            Cam.CFrame = Cam.CFrame:Lerp(tcf, 1 - math.exp(-S.aimSmooth * dt * 60))
        end
    end
    
    -- Fly Logic
    if S.fly then
        local hrp, hum = getHRP(), getHum()
        if hrp and hum then
            hum.PlatformStand = true
            local dir = Vector3.zero
            if UIS:IsKeyDown(Enum.KeyCode.W) then dir += Cam.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then dir -= Cam.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then dir -= Cam.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then dir += Cam.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.yAxis end
            if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.yAxis end
            local lv, ao = hrp:FindFirstChild("FlyLV"), hrp:FindFirstChild("FlyAO")
            if lv and ao then 
                lv.VectorVelocity = dir * S.flySpeed
                ao.CFrame = Cam.CFrame
            end
            hrp.Velocity = Vector3.zero
        end
    end
end)

RS.Heartbeat:Connect(function()
    local hum = getHum()
    if hum then
        if S.speed then hum.WalkSpeed = S.speedVal else if not S.fly then hum.WalkSpeed = 16 end end
        if hum.UseJumpPower then hum.JumpPower = S.jump else hum.JumpHeight = S.jump * 0.15 end
    end
    
    local ch = getChar()
    if ch and S.noclip then 
        for _, p in pairs(ch:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end 
    end
    
    updateVisuals()
    
    local hrp = getHRP()
    if hrp then
        if S.glow then 
            local l = hrp:FindFirstChild("Glow") or Instance.new("PointLight", hrp)
            l.Name = "Glow"; l.Brightness = 4; l.Range = 20; l.Color = Color3.fromHSV((tick() * 0.5) % 1, 1, 1) 
        else 
            local l = hrp:FindFirstChild("Glow"); if l then l:Destroy() end 
        end
    end
end)

UIS.JumpRequest:Connect(function() 
    if S.infJump then local h = getHum(); if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end 
end)

UIS.InputBegan:Connect(function(i, g) 
    if not g and i.KeyCode == Enum.KeyCode.E then aimKeyHeld = true end 
end)
UIS.InputEnded:Connect(function(i, g) 
    if not g and i.KeyCode == Enum.KeyCode.E then aimKeyHeld = false end 
end)

-- ═══════ UI DESIGN (NEON BREACH) ═══════
local COL = {
    bg = Color3.fromRGB(5, 10, 10), panel = Color3.fromRGB(10, 20, 15),
    green = Color3.fromRGB(0, 255, 100), cyan = Color3.fromRGB(0, 200, 255),
    txt = Color3.fromRGB(200, 255, 200), dim = Color3.fromRGB(50, 100, 70),
    bad = Color3.fromRGB(255, 50, 50)
}

local gui = Instance.new("ScreenGui")
gui.Name = "NeonBreach"; gui.ResetOnSpawn = false; gui.DisplayOrder = 9999
pcall(function() if gethui then gui.Parent = gethui() else gui.Parent = CoreGui end end)

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 680, 0, 480); main.Position = UDim2.new(0.5, -340, 0.5, -240)
main.BackgroundColor3 = COL.bg; main.BorderSizePixel = 0; main.Active = true; main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 6)
local stroke = Instance.new("UIStroke", main); stroke.Color = COL.green; stroke.Thickness = 2; stroke.Transparency = 0.2

local header = Instance.new("Frame", main)
header.Size = UDim2.new(1, 0, 0, 40); header.BackgroundColor3 = COL.panel; header.BorderSizePixel = 0
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 6)
local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(1, -80, 1, 0); title.Position = UDim2.new(0, 15, 0, 0)
title.BackgroundTransparency = 1; title.Text = "NEON BREACH v5.0 - SYSTEM OVERRIDE"
title.TextColor3 = COL.green; title.TextSize = 14; title.Font = Enum.Font.Code; title.TextXAlignment = Enum.TextXAlignment.Left

local close = Instance.new("TextButton", header)
close.Size = UDim2.new(0, 30, 0, 30); close.Position = UDim2.new(1, -40, 0, 5)
close.BackgroundTransparency = 1; close.Text = "[X]"; close.TextColor3 = COL.bad
close.TextSize = 16; close.Font = Enum.Font.Code

local reopen
close.MouseButton1Click:Connect(function() 
    main.Visible = false
    if not reopen then
        reopen = Instance.new("TextButton", gui)
        reopen.Size = UDim2.new(0, 45, 0, 45); reopen.Position = UDim2.new(0, 20, 0.5, -20)
        reopen.BackgroundColor3 = COL.bg; reopen.Text = ">_"; reopen.TextColor3 = COL.green; reopen.TextSize = 20; reopen.Font = Enum.Font.Code
        local s = Instance.new("UIStroke", reopen); s.Color = COL.green; s.Thickness = 2
        reopen.MouseButton1Click:Connect(function() main.Visible = true; reopen.Visible = false end)
    end
    reopen.Visible = true 
end)

local side = Instance.new("Frame", main)
side.Size = UDim2.new(0, 160, 1, -40); side.Position = UDim2.new(0, 0, 0, 40)
side.BackgroundColor3 = COL.panel; side.BorderSizePixel = 0
local sideLine = Instance.new("Frame", side)
sideLine.Size = UDim2.new(0, 2, 1, 0); sideLine.Position = UDim2.new(1, -2, 0, 0)
sideLine.BackgroundColor3 = COL.green; sideLine.BorderSizePixel = 0

local cont = Instance.new("Frame", main)
cont.Size = UDim2.new(1, -160, 1, -40); cont.Position = UDim2.new(0, 160, 0, 40); cont.BackgroundTransparency = 1
local pages = Instance.new("Frame", cont)
pages.Size = UDim2.new(1, -20, 1, -190); pages.Position = UDim2.new(0, 10, 0, 10); pages.BackgroundTransparency = 1

local console = Instance.new("Frame", cont)
console.Size = UDim2.new(1, -20, 0, 150); console.Position = UDim2.new(0, 10, 1, -160)
console.BackgroundColor3 = Color3.fromRGB(0, 0, 0); console.BorderSizePixel = 0
local cStroke = Instance.new("UIStroke", console); cStroke.Color = COL.green; cStroke.Thickness = 1
local cTitle = Instance.new("TextLabel", console)
cTitle.Size = UDim2.new(1, 0, 0, 20); cTitle.BackgroundTransparency = 1
cTitle.Text = " CONSOLE"; cTitle.TextColor3 = COL.green; cTitle.Font = Enum.Font.Code; cTitle.TextXAlignment = Enum.TextXAlignment.Left
local cText = Instance.new("ScrollingFrame", console)
cText.Size = UDim2.new(1, -10, 1, -25); cText.Position = UDim2.new(0, 5, 0, 20)
cText.BackgroundTransparency = 1; cText.BorderSizePixel = 0; cText.ScrollBarThickness = 2; cText.AutomaticCanvasSize = Enum.AutomaticSize.Y
local cLayout = Instance.new("UIListLayout", cText); cLayout.Padding = UDim.new(0, 2)

local function Log(msg)
    local l = Instance.new("TextLabel", cText)
    l.Size = UDim2.new(1, 0, 0, 16); l.BackgroundTransparency = 1
    l.Text = "> " .. msg; l.TextColor3 = COL.green; l.Font = Enum.Font.Code; l.TextSize = 12; l.TextXAlignment = Enum.TextXAlignment.Left
    task.delay(3, function() 
        if l then 
            TweenService:Create(l, TweenInfo.new(1), {TextTransparency = 1}):Play()
            task.wait(1); l:Destroy() 
        end 
    end)
end

Log("SYSTEM INITIALIZED...")
Log("LOADING MODULES [SOCIAL, ESP, MOVE]...")
Log("ACCESS GRANTED. WELCOME " .. string.upper(LP.Name))

local tabs = {}
local function selectTab(idx) 
    for i, t in ipairs(tabs) do 
        t.btn.BackgroundTransparency = i == idx and 0.8 or 1
        t.btn.TextColor3 = i == idx and COL.cyan or COL.dim
        t.page.Visible = i == idx 
    end 
end

local function createTab(name, icon)
    local my = #tabs + 1
    local btn = Instance.new("TextButton", side)
    btn.Size = UDim2.new(1, 0, 0, 40); btn.Position = UDim2.new(0, 0, 0, (#tabs * 45) + 10)
    btn.BackgroundColor3 = COL.green; btn.BackgroundTransparency = 1
    btn.Text = "  " .. icon .. "  " .. name; btn.TextColor3 = COL.dim
    btn.Font = Enum.Font.Code; btn.TextSize = 14; btn.TextXAlignment = Enum.TextXAlignment.Left; btn.BorderSizePixel = 0
    local page = Instance.new("Frame", pages)
    page.Size = UDim2.new(1, 0, 1, 0); page.BackgroundTransparency = 1; page.Visible = false
    local lay = Instance.new("UIListLayout", page); lay.Padding = UDim.new(0, 8)
    table.insert(tabs, {btn = btn, page = page})
    btn.MouseButton1Click:Connect(function() selectTab(my) end)
    return page
end

local function makeTog(par, name, get, set)
    local f = Instance.new("Frame", par)
    f.Size = UDim2.new(1, 0, 0, 36); f.BackgroundColor3 = COL.panel; f.BorderSizePixel = 0
    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(1, -60, 1, 0); l.Position = UDim2.new(0, 10, 0, 0); l.BackgroundTransparency = 1
    l.Text = name; l.TextColor3 = COL.txt; l.Font = Enum.Font.Code; l.TextSize = 13; l.TextXAlignment = Enum.TextXAlignment.Left
    local b = Instance.new("TextButton", f)
    b.Size = UDim2.new(0, 50, 0, 20); b.Position = UDim2.new(1, -60, 0.5, -10)
    b.BackgroundColor3 = COL.bg; b.BorderSizePixel = 0
    b.Text = get() and " [ON] " or " [OFF] "; b.TextColor3 = get() and COL.green or COL.bad; b.Font = Enum.Font.Code; b.TextSize = 12
    local s = Instance.new("UIStroke", b); s.Color = COL.green
    b.MouseButton1Click:Connect(function() 
        local st = not get(); set(st)
        b.Text = st and " [ON] " or " [OFF] "; b.TextColor3 = st and COL.green or COL.bad
        Log(string.upper(name) .. ": " .. (st and "ON" or "OFF")) 
    end)
end

local function makeSld(par, name, min, max, get, set)
    local f = Instance.new("Frame", par)
    f.Size = UDim2.new(1, 0, 0, 50); f.BackgroundColor3 = COL.panel; f.BorderSizePixel = 0
    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(1, -60, 0, 20); l.Position = UDim2.new(0, 10, 0, 5); l.BackgroundTransparency = 1
    l.Text = name; l.TextColor3 = COL.txt; l.Font = Enum.Font.Code; l.TextSize = 13; l.TextXAlignment = Enum.TextXAlignment.Left
    local v = Instance.new("TextLabel", f)
    v.Size = UDim2.new(0, 50, 0, 20); v.Position = UDim2.new(1, -60, 0, 5); v.BackgroundTransparency = 1
    v.Text = tostring(get()); v.TextColor3 = COL.cyan; v.Font = Enum.Font.Code; v.TextSize = 13; v.TextXAlignment = Enum.TextXAlignment.Right
    local tr = Instance.new("TextButton", f)
    tr.Size = UDim2.new(1, -20, 0, 4); tr.Position = UDim2.new(0, 10, 0, 35)
    tr.BackgroundColor3 = COL.bg; tr.Text = ""; tr.BorderSizePixel = 0; tr.AutoButtonColor = false
    local fl = Instance.new("Frame", tr)
    fl.Size = UDim2.new((get() - min) / (max - min), 0, 1, 0); fl.BackgroundColor3 = COL.cyan; fl.BorderSizePixel = 0
    local drg = false
    tr.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drg = true end end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drg = false end end)
    UIS.InputChanged:Connect(function(i) 
        if drg and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then 
            local p = math.clamp((i.Position.X - tr.AbsolutePosition.X) / tr.AbsoluteSize.X, 0, 1)
            local val = math.floor((min + (max - min) * p) + 0.5)
            fl.Size = UDim2.new(p, 0, 1, 0); v.Text = tostring(val); set(val) 
        end 
    end)
end

local function makeBtn(par, name, cb)
    local b = Instance.new("TextButton", par)
    b.Size = UDim2.new(1, 0, 0, 36); b.BackgroundColor3 = COL.panel; b.Text = name
    b.TextColor3 = COL.txt; b.Font = Enum.Font.Code; b.BorderSizePixel = 0
    local s = Instance.new("UIStroke", b); s.Color = COL.cyan
    b.MouseButton1Click:Connect(function() cb(); Log(string.upper(name) .. " EXECUTED") end)
end

-- ═══════ TAB POPULATION ═══════
local e = createTab("ESP", "[+]")
makeTog(e, "Enable ESP", function() return S.esp end, function(v) S.esp = v end)
makeTog(e, "Box", function() return S.box end, function(v) S.box = v end)
makeTog(e, "Skeleton", function() return S.skel end, function(v) S.skel = v end)
makeTog(e, "Health", function() return S.hp end, function(v) S.hp = v end)
makeTog(e, "Names", function() return S.name end, function(v) S.name = v end)
makeTog(e, "Distance", function() return S.dist end, function(v) S.dist = v end)
makeTog(e, "Rainbow", function() return S.rainbow end, function(v) S.rainbow = v end)
makeBtn(e, "CHANGE COLOR", function() S.colorIdx = (S.colorIdx % #colors) + 1 end)

local a = createTab("Aim", "[O]")
makeTog(a, "Enable Aim", function() return S.aim end, function(v) S.aim = v end)
makeSld(a, "FOV", 30, 300, function() return S.aimFOV end, function(v) S.aimFOV = v end)
makeSld(a, "Smooth", 1, 100, function() return math.floor(S.aimSmooth * 100) end, function(v) S.aimSmooth = v / 100 end)

local m = createTab("Move", "[>]")
makeTog(m, "Speed", function() return S.speed end, function(v) S.speed = v end)
makeSld(m, "Speed Val", 16, 150, function() return S.speedVal end, function(v) S.speedVal = v end)
makeSld(m, "Jump", 50, 250, function() return S.jump end, function(v) S.jump = v end)
makeTog(m, "Inf Jump", function() return S.infJump end, function(v) S.infJump = v end)
makeTog(m, "Fly", function() return S.fly end, function(v) 
    S.fly = v
    local hrp = getHRP()
    if v and hrp then 
        local at = Instance.new("Attachment", hrp); at.Name = "FlyAttach"
        local lv = Instance.new("LinearVelocity", hrp); lv.Name = "FlyLV"; lv.Attachment0 = at; lv.MaxForce = math.huge
        local ao = Instance.new("AlignOrientation", hrp); ao.Name = "FlyAO"; ao.Attachment0 = at; ao.MaxTorque = math.huge
    elseif not v and hrp then 
        local hum = getHum(); if hum then hum.PlatformStand = false end
        for _, n in pairs({"FlyLV", "FlyAO", "FlyAttach"}) do 
            local ob = hrp:FindFirstChild(n); if ob then ob:Destroy() end 
        end 
    end 
end)
makeSld(m, "Fly Speed", 20, 200, function() return S.flySpeed end, function(v) S.flySpeed = v end)
makeTog(m, "Noclip", function() return S.noclip end, function(v) S.noclip = v end)

local s = createTab("Size", "[#]")
makeSld(s, "Player Size", 4, 25, function() return math.floor(S.size * 10) end, function(v) applySize(v / 10) end)

local l = createTab("Look", "[*]")
makeTog(l, "Glow", function() return S.glow end, function(v) S.glow = v end)
makeTog(l, "Invisible", function() return S.invis end, function(v) S.invis = v end)
makeTog(l, "Hide Head", function() return S.hideHead end, function(v) S.hideHead = v end)
makeTog(l, "Hide L-Leg", function() return S.hideLLeg end, function(v) S.hideLLeg = v end)
makeTog(l, "Hide R-Leg", function() return S.hideRLeg end, function(v) S.hideRLeg = v end)
makeTog(l, "Fullbright", function() return S.fullbright end, function(v) 
    S.fullbright =
