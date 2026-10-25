local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local WS = workspace
local LP = Players.LocalPlayer
local Cam = WS.CurrentCamera

local S = {
    esp = true, box = true, skel = true, hp = true, name = true, dist = true, tracer = false,
    colorIdx = 1, rainbow = false,
    aim = false, aimFOV = 120, aimSmooth = 0.2, aimPart = "HumanoidRootPart",
    speed = false, speedVal = 28, jump = 50, infJump = false,
    fly = false, flySpeed = 60, noclip = false, size = 1.0,
    glow = false, invis = false, hideHead = false, hideLLeg = false, hideRLeg = false
}

local colors = {
    Color3.fromRGB(255, 60, 60), Color3.fromRGB(60, 255, 60), 
    Color3.fromRGB(60, 60, 255), Color3.fromRGB(200, 60, 255), 
    Color3.fromRGB(60, 255, 255), Color3.fromRGB(255, 255, 60)
}

local function getChar() return LP.Character end
local function getHum() local c = getChar(); return c and c:FindFirstChildOfClass("Humanoid") end
local function getHRP() local c = getChar(); return c and c:FindFirstChild("HumanoidRootPart") end

-- ESP SYSTEM
local espObjs = {}
local HAS_DRW = pcall(function() return Drawing.new("Square") end)
local function clearESP()
    for _, e in pairs(espObjs) do
        for _, o in pairs(e) do if type(o) == "table" and o.Remove then pcall(function() o:Remove() end) end end
        if e.bones then for _, b in ipairs(e.bones) do pcall(function() b:Remove() end) end end
    end
    espObjs = {}
end

local function initESP()
    clearESP(); if not HAS_DRW then return end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP then
            local e = {box=Drawing.new("Square"), name=Drawing.new("Text"), dist=Drawing.new("Text"), hpBar=Drawing.new("Square"), tracer=Drawing.new("Line"), bones={}, plr=p}
            e.box.Visible=false; e.box.Thickness=1.5
            e.name.Visible=false; e.name.Size=14; e.name.Center=true; e.name.Outline=true
            e.dist.Visible=false; e.dist.Size=12; e.dist.Center=true; e.dist.Outline=true
            e.hpBar.Visible=false; e.hpBar.Filled=true
            e.tracer.Visible=false; e.tracer.Thickness=1
            for i=1,14 do local l=Drawing.new("Line"); l.Visible=false; l.Thickness=1.5; table.insert(e.bones, l) end
            table.insert(espObjs, e)
        end
    end
end

local R15 = {{"Head","UpperTorso"},{"UpperTorso","LowerTorso"},{"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},{"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},{"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},{"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"}}
local R6 = {{"Head","Torso"},{"Torso","Left Arm"},{"Torso","Right Arm"},{"Torso","Left Leg"},{"Torso","Right Leg"}}

local function updateESP()
    if not HAS_DRW then return end
    local r, g, b = 1, 0, 0
    if S.rainbow then
        local c = Color3.fromHSV((tick() * 0.5) % 1, 1, 1); r, g, b = c.R, c.G, c.B
    else
        local c = colors[S.colorIdx]; r, g, b = c.R, c.G, c.B
    end
    local currentColor = Color3.new(r, g, b)

    for _, e in ipairs(espObjs) do
        local ch = e.plr.Character
        local hrp, head, hum = ch and ch:FindFirstChild("HumanoidRootPart"), ch and ch:FindFirstChild("Head"), ch and ch:FindFirstChildOfClass("Humanoid")
        local show = S.esp and hrp and head and hum and hum.Health > 0
        
        if show then
            local d = (getHRP().Position - hrp.Position).Magnitude
            if d < 1000 then
                local top, tv = Cam:WorldToViewportPoint(head.Position + Vector3.new(0,0.5,0))
                local bot, bv = Cam:WorldToViewportPoint(hrp.Position - Vector3.new(0,2.5,0))
                
                if tv and bv then
                    local bh = math.abs(top.Y - bot.Y); local bw = bh * 0.55
                    local bx = top.X - bw/2; local by = top.Y
                    
                    e.box.Visible = S.box
                    if S.box then e.box.Color=currentColor; e.box.Size=Vector2.new(bw,bh); e.box.Position=Vector2.new(bx,by) end
                    e.name.Visible = S.name
                    if S.name then e.name.Text=e.plr.Name; e.name.Position=Vector2.new(top.X, by-18); e.name.Color=currentColor end
                    e.dist.Visible = S.dist
                    if S.dist then e.dist.Text=string.format("%.0fm", d/3.5); e.dist.Position=Vector2.new(top.X, bot.Y+2); e.dist.Color=currentColor end
                    e.hpBar.Visible = S.hp
                    if S.hp then e.hpBar.Size=Vector2.new(4, bh*(hum.Health/hum.MaxHealth)); e.hpBar.Position=Vector2.new(bx-8, by + bh*(1-hum.Health/hum.MaxHealth)); e.hpBar.Color=Color3.new(1-hum.Health/hum.MaxHealth, hum.Health/hum.MaxHealth, 0) end
                    e.tracer.Visible = S.tracer
                    if S.tracer then e.tracer.From=Vector2.new(Cam.ViewportSize.X/2, Cam.ViewportSize.Y); e.tracer.To=Vector2.new(top.X, by+bh); e.tracer.Color=currentColor end
                    
                    local bns = (hum.RigType == Enum.HumanoidRigType.R15) and R15 or R6
                    for i=1, #e.bones do
                        if S.skel and i <= #bns then
                            local p1, p2 = ch:FindFirstChild(bns[i][1]), ch:FindFirstChild(bns[i][2])
                            if p1 and p2 then
                                local s1, v1 = Cam:WorldToViewportPoint(p1.Position)
                                local s2, v2 = Cam:WorldToViewportPoint(p2.Position)
                                if v1 and v2 then
                                    e.bones[i].Visible = true; e.bones[i].From = Vector2.new(s1.X, s1.Y); e.bones[i].To = Vector2.new(s2.X, s2.Y); e.bones[i].Color = currentColor
                                else e.bones[i].Visible = false end
                            else e.bones[i].Visible = false end
                        else e.bones[i].Visible = false end
                    end
                else
                    e.box.Visible=false; e.name.Visible=false; e.dist.Visible=false; e.hpBar.Visible=false; e.tracer.Visible=false
                    for _, b in ipairs(e.bones) do b.Visible=false end
                end
            else
                e.box.Visible=false; e.name.Visible=false; e.dist.Visible=false; e.hpBar.Visible=false; e.tracer.Visible=false
                for _, b in ipairs(e.bones) do b.Visible=false end
            end
        else
            e.box.Visible=false; e.name.Visible=false; e.dist.Visible=false; e.hpBar.Visible=false; e.tracer.Visible=false
            for _, b in ipairs(e.bones) do b.Visible=false end
        end
    end
end
initESP(); Players.PlayerAdded:Connect(initESP)

-- MECHANICS
local aimActive = false
local aimKeyHeld = false
local origTrans = {}
local function applySize(scale) S.size = scale; pcall(function() if getChar() then getChar():ScaleTo(scale) end end) end
local function updateVisuals()
    local ch = getChar(); if not ch then return end
    for _, p in pairs(ch:GetDescendants()) do
        if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
            local isH = p.Name=="Head" and S.hideHead
            local isL = (p.Name=="Left Leg" or p.Name=="LeftLowerLeg") and S.hideLLeg
            local isR = (p.Name=="Right Leg" or p.Name=="RightLowerLeg") and S.hideRLeg
            p.Transparency = (S.invis or isH or isL or isR) and 1 or (origTrans[p] or 0)
        elseif p:IsA("Decal") then
            p.Transparency = (S.invis or (p.Parent and p.Parent.Name=="Head" and S.hideHead)) and 1 or (origTrans[p] or 0)
        end
    end
end
local function setupTrans(ch)
    origTrans = {}
    for _, p in pairs(ch:GetDescendants()) do if p:IsA("BasePart") or p:IsA("Decal") then origTrans[p] = p.Transparency end end
end
if getChar() then setupTrans(getChar()) end
LP.CharacterAdded:Connect(function(c) task.wait(1); setupTrans(c); applySize(S.size) end)

RS.RenderStepped:Connect(function(dt)
    updateESP()
    if S.aim and (aimActive or aimKeyHeld) then
        local cl, b = nil, S.aimFOV
        local center = Vector2.new(Cam.ViewportSize.X/2, Cam.ViewportSize.Y/2)
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
    if S.fly then
        local hrp, hum = getHRP(), getHum()
        if hrp and hum then
            hum.PlatformStand = true
            local cf = Cam.CFrame; local dir = Vector3.zero
            if UIS:IsKeyDown(Enum.KeyCode.W) then dir += cf.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then dir -= cf.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then dir -= cf.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then dir += cf.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.yAxis end
            if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.yAxis end
            if dir.Magnitude > 0 then hrp.CFrame = hrp.CFrame + (dir.Unit * S.flySpeed * dt) end
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
    if ch and S.noclip then for _, p in pairs(ch:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end end
    updateVisuals()
    local hrp = getHRP()
    if hrp then
        if S.glow then
            local l = hrp:FindFirstChild("Glow") or Instance.new("PointLight", hrp); l.Name = "Glow"; l.Brightness = 4; l.Range = 20; l.Color = Color3.fromHSV((tick()*0.5)%1, 1, 1)
        else
            local l = hrp:FindFirstChild("Glow"); if l then l:Destroy() end
        end
    end
end)

UIS.JumpRequest:Connect(function() if S.infJump then local h = getHum(); if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end end)
UIS.InputBegan:Connect(function(i, g) if not g and i.KeyCode == Enum.KeyCode.E then aimKeyHeld = true end end)
UIS.InputEnded:Connect(function(i, g) if not g and i.KeyCode == Enum.KeyCode.E then aimKeyHeld = false end end)

-- UI
local COL = {bg = Color3.fromRGB(15,15,18), side = Color3.fromRGB(22,22,28), acc = Color3.fromRGB(0,170,255), txt = Color3.fromRGB(245,245,250), dim = Color3.fromRGB(150,150,160), card = Color3.fromRGB(30,30,38), good = Color3.fromRGB(80,220,140), bad = Color3.fromRGB(240,80,100)}
local gui = Instance.new("ScreenGui")
gui.Name = "Universal_Menu"; gui.ResetOnSpawn = false; gui.DisplayOrder = 9999
pcall(function() if gethui then gui.Parent = gethui() else gui.Parent = CoreGui end end)

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 560, 0, 400); main.Position = UDim2.new(0.5, -280, 0.5, -200); main.BackgroundColor3 = COL.bg; main.BorderSizePixel = 0; main.Active = true; main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)
local side = Instance.new("Frame", main); side.Size = UDim2.new(0, 150, 1, 0); side.BackgroundColor3 = COL.side; side.BorderSizePixel = 0; Instance.new("UICorner", side).CornerRadius = UDim.new(0, 10)
local cont = Instance.new("Frame", main); cont.Size = UDim2.new(1, -150, 1, 0); cont.Position = UDim2.new(0, 150, 0, 0); cont.BackgroundTransparency = 1
local title = Instance.new("TextLabel", cont); title.Size = UDim2.new(1, -40, 0, 40); title.Position = UDim2.new(0, 20, 0, 15); title.BackgroundTransparency = 1; title.Text = "Universal Hub"; title.TextColor3 = COL.acc; title.TextSize = 24; title.Font = Enum.Font.GothamBold; title.TextXAlignment = Enum.TextXAlignment.Left

local close = Instance.new("TextButton", main); close.Size = UDim2.new(0, 30, 0, 30); close.Position = UDim2.new(1, -40, 0, 15); close.BackgroundColor3 = COL.bad; close.Text = "✕"; close.TextColor3 = COL.txt; close.TextSize = 14; close.Font = Enum.Font.GothamBold; close.BorderSizePixel = 0; Instance.new("UICorner", close).CornerRadius = UDim.new(0, 8)
local reopen
close.MouseButton1Click:Connect(function() main.Visible = false; if not reopen then
    reopen = Instance.new("TextButton", gui); reopen.Size = UDim2.new(0, 45, 0, 45); reopen.Position = UDim2.new(0, 20, 0.5, -20); reopen.BackgroundColor3 = COL.acc; reopen.Text = "◆"; reopen.TextColor3 = Color3.new(1,1,1); reopen.TextSize = 20; reopen.Font = Enum.Font.GothamBold; Instance.new("UICorner", reopen).CornerRadius = UDim.new(1, 0)
    reopen.MouseButton1Click:Connect(function() main.Visible = true; reopen.Visible = false end)
end; reopen.Visible = true end)

local tabs = {}
local pages = Instance.new("Frame", cont); pages.Size = UDim2.new(1, -40, 1, -70); pages.Position = UDim2.new(0, 20, 0, 60); pages.BackgroundTransparency = 1
local function selectTab(idx) for i, t in ipairs(tabs) do t.btn.BackgroundColor3 = i==idx and COL.card or COL.side; t.btn.TextColor3 = i==idx and COL.acc or COL.dim; t.page.Visible = i==idx end end
local function createTab(name)
    local my = #tabs + 1
    local btn = Instance.new("TextButton", side); btn.Size = UDim2.new(1, -20, 0, 36); btn.Position = UDim2.new(0, 10, 0, 15 + (#tabs * 40)); btn.BackgroundColor3 = COL.side; btn.Text = "  "..name; btn.TextColor3 = COL.dim; btn.TextSize = 13; btn.Font = Enum.Font.GothamBold; btn.TextXAlignment = Enum.TextXAlignment.Left; btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    local page = Instance.new("ScrollingFrame", pages); page.Size = UDim2.new(1, 0, 1, 0); page.BackgroundTransparency = 1; page.BorderSizePixel = 0; page.ScrollBarThickness = 2; page.ScrollBarImageColor3 = COL.acc; page.AutomaticCanvasSize = Enum.AutomaticSize.Y; page.Visible = false
    local ly = Instance.new("UIListLayout", page); ly.Padding = UDim.new(0, 6)
    table.insert(tabs, {btn = btn, page = page}); btn.MouseButton1Click:Connect(function() selectTab(my) end); return page
end

local function makeTog(par, name, get, set)
    local f = Instance.new("Frame", par); f.Size = UDim2.new(1, 0, 0, 36); f.BackgroundColor3 = COL.card; f.BorderSizePixel = 0; Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)
    local l = Instance.new("TextLabel", f); l.Size = UDim2.new(1, -60, 1, 0); l.Position = UDim2.new(0, 12, 0, 0); l.BackgroundTransparency = 1; l.Text = name; l.TextColor3 = COL.txt; l.TextSize = 13; l.Font = Enum.Font.Gotham; l.TextXAlignment = Enum.TextXAlignment.Left
    local b = Instance.new("TextButton", f); b.Size = UDim2.new(0, 36, 0, 18); b.Position = UDim2.new(1, -46, 0.5, -9); b.BackgroundColor3 = get() and COL.good or COL.bad; b.Text = ""; b.BorderSizePixel = 0; Instance.new("UICorner", b).CornerRadius = UDim.new(1, 0)
    local k = Instance.new("Frame", b); k.Size = UDim2.new(0, 14, 0, 14); k.Position = get() and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7); k.BackgroundColor3 = Color3.new(1,1,1); k.BorderSizePixel = 0; Instance.new("UICorner", k).CornerRadius = UDim.new(1, 0)
    b.MouseButton1Click:Connect(function() local s = not get(); set(s); b.BackgroundColor3 = s and COL.good or COL.bad; k.Position = s and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7) end)
end

local function makeSld(par, name, min, max, get, set)
    local f = Instance.new("Frame", par); f.Size = UDim2.new(1, 0, 0, 50); f.BackgroundColor3 = COL.card; f.BorderSizePixel = 0; Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)
    local l = Instance.new("TextLabel", f); l.Size = UDim2.new(1, -60, 0, 20); l.Position = UDim2.new(0, 12, 0, 6); l.BackgroundTransparency = 1; l.Text = name; l.TextColor3 = COL.txt; l.TextSize = 13; l.Font = Enum.Font.Gotham; l.TextXAlignment = Enum.TextXAlignment.Left
    local v = Instance.new("TextLabel", f); v.Size = UDim2.new(0, 50, 0, 20); v.Position = UDim2.new(1, -60, 0, 6); v.BackgroundTransparency = 1; v.Text = tostring(get()); v.TextColor3 = COL.acc; v.TextSize = 13; v.Font = Enum.Font.GothamBold; v.TextXAlignment = Enum.TextXAlignment.Right
    local tr = Instance.new("TextButton", f); tr.Size = UDim2.new(1, -24, 0, 6); tr.Position = UDim2.new(0, 12, 0, 32); tr.BackgroundColor3 = COL.bg; tr.Text = ""; tr.BorderSizePixel = 0; tr.AutoButtonColor = false; Instance.new("UICorner", tr).CornerRadius = UDim.new(1, 0)
    local fl = Instance.new("Frame", tr); fl.Size = UDim2.new((get()-min)/(max-min), 0, 1, 0); fl.BackgroundColor3 = COL.acc; fl.BorderSizePixel = 0; Instance.new("UICorner", fl).CornerRadius = UDim.new(1, 0)
    local drg = false
    tr.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drg = true end end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drg = false end end)
    UIS.InputChanged:Connect(function(i) if drg and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then local p = math.clamp((i.Position.X - tr.AbsolutePosition.X)/tr.AbsoluteSize.X, 0, 1); local val = math.floor((min + (max-min)*p) + 0.5); fl.Size = UDim2.new(p, 0, 1, 0); v.Text = tostring(val); set(val) end end)
end

local function makeBtn(par, name, cb)
    local b = Instance.new("TextButton", par); b.Size = UDim2.new(1, 0, 0, 36); b.BackgroundColor3 = COL.acc; b.Text = name; b.TextColor3 = COL.txt; b.TextSize = 13; b.Font = Enum.Font.GothamBold; b.BorderSizePixel = 0; Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    b.MouseButton1Click:Connect(cb)
end

local e = createTab("ESP")
makeTog(e, "Enable ESP", function() return S.esp end, function(v) S.esp = v end)
makeTog(e, "Box", function() return S.box end, function(v) S.box = v end)
makeTog(e, "Skeleton", function() return S.skel end, function(v) S.skel = v end)
makeTog(e, "Health Bar", function() return S.hp end, function(v) S.hp = v end)
makeTog(e, "Names", function() return S.name end, function(v) S.name = v end)
makeTog(e, "Distance", function() return S.dist end, function(v) S.dist = v end)
makeTog(e, "Rainbow ESP", function() return S.rainbow end, function(v) S.rainbow = v end)
makeBtn(e, "Change Color", function() S.colorIdx = (S.colorIdx % #colors) + 1 end)

local a = createTab("Aim")
makeTog(a, "Enable Aim", function() return S.aim end, function(v) S.aim = v end)
makeSld(a, "FOV", 30, 300, function() return S.aimFOV end, function(v) S.aimFOV = v end)
makeSld(a, "Smoothness", 1, 100, function() return math.floor(S.aimSmooth*100) end, function(v) S.aimSmooth = v/100 end)

local m = createTab("Move")
makeTog(m, "Speed Hack", function() return S.speed end, function(v) S.speed = v end)
makeSld(m, "WalkSpeed", 16, 150, function() return S.speedVal end, function(v) S.speedVal = v end)
makeSld(m, "JumpPower", 50, 250, function() return S.jump end, function(v) S.jump = v end)
makeTog(m, "Infinite Jump", function() return S.infJump end, function(v) S.infJump = v end)
makeTog(m, "Fly", function() return S.fly end, function(v) S.fly = v end)
makeSld(m, "Fly Speed", 20, 200, function() return S.flySpeed end, function(v) S.flySpeed = v end)
makeTog(m, "Noclip", function() return S.noclip end, function(v) S.noclip = v end)

local s = createTab("Size")
makeSld(s, "Player Size", 4, 25, function() return math.floor(S.size*10) end, function(v) applySize(v/10) end)

local l = createTab("Look")
makeTog(l, "Glow (Rainbow)", function() return S.glow end, function(v) S.glow = v end)
makeTog(l, "Invisible", function() return S.invis end, function(v) S.invis = v end)
makeTog(l, "Hide Head", function() return S.hideHead end, function(v) S.hideHead = v end)
makeTog(l, "Hide Left Leg", function() return S.hideLLeg end, function(v) S.hideLLeg = v end)
makeTog(l, "Hide Right Leg", function() return S.hideRLeg end, function(v) S.hideRLeg = v end)

selectTab(1)

-- MOBILE AIM BUTTON
local aimBtn = Instance.new("TextButton", gui)
aimBtn.Size = UDim2.new(0, 60, 0, 60)
aimBtn.Position = UDim2.new(1, -80, 0.5, -30)
aimBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
aimBtn.BackgroundTransparency = 0.3
aimBtn.Text = "AIM"
aimBtn.TextColor3 = Color3.new(1,1,1)
aimBtn.TextSize = 14
aimBtn.Font = Enum.Font.GothamBold
aimBtn.BorderSizePixel = 0
aimBtn.Active = true
aimBtn.Draggable = true
Instance.new("UICorner", aimBtn).CornerRadius = UDim.new(1, 0)
local stroke = Instance.new("UIStroke", aimBtn)
stroke.Color = COL.acc
stroke.Thickness = 2

aimBtn.MouseButton1Click:Connect(function()
    aimActive = not aimActive
    if aimActive then
        aimBtn.BackgroundColor3 = COL.good
        aimBtn.BackgroundTransparency = 0
    else
        aimBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        aimBtn.BackgroundTransparency = 0.3
    end
end)

print("[KD] Universal Menu Loaded.")
