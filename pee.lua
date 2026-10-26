local function CreatePeeEmitter()
    KillPeeEmitter()
    local char = GetCharacter()
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local attach = Instance.new("Attachment")
    attach.Name = "PeeAttach"
    -- behind + below pelvis — ass exit
    attach.Position = Vector3.new(0, -1.1, 0.45)
    attach.Parent = hrp

    local emitter = Instance.new("ParticleEmitter")
    emitter.Name              = "PeeEmitter"
    emitter.Texture           = "rbxasset://textures/particles/smoke_main.dds"
    -- brown shit color, slight variation
    emitter.Color             = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 72, 30)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(90, 52, 22)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(70, 40, 18)),
    })
    -- chunky blobs, not drips
    emitter.Size              = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.35),
        NumberSequenceKeypoint.new(0.7, 0.4),
        NumberSequenceKeypoint.new(1, 0.25),
    })
    -- mostly opaque, hard drop
    emitter.Transparency      = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.0),
        NumberSequenceKeypoint.new(0.85, 0.1),
        NumberSequenceKeypoint.new(1, 0.85),
    })
    emitter.Lifetime          = NumberRange.new(0.5, 0.9)
    emitter.Rate              = 22                     -- slower than pee, chunks not stream
    emitter.Speed             = NumberRange.new(4, 7)   -- pushed out, not sprayed
    emitter.SpreadAngle       = Vector2.new(10, 10)
    emitter.Acceleration      = Vector3.new(0, -60, 0) -- heavy — plummets fast
    emitter.EmissionDirection = Enum.NormalId.Back
    emitter.LockedToPart      = false
    emitter.LightEmission     = 0.0
    emitter.LightInfluence    = 1.0                    -- reacts to shadows, looks grounded
    emitter.Rotation          = NumberRange.new(0, 360)
    emitter.RotSpeed          = NumberRange.new(-180, 180)  -- tumbling chunks
    emitter.Squash            = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.5, 0.75),
        NumberSequenceKeypoint.new(1, 1),
    })
    emitter.Parent            = attach

    peeEmitter = emitter
    peeEmitter.Enabled = PeeEnabled
end
