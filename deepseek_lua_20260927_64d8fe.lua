-- ============================================================
-- DARK HUB | Kill Aura
-- Self-contained UI + Kill Aura logic
-- ============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ============================================================
-- THEME
-- ============================================================
local C = {
    bg      = Color3.fromRGB(14, 14, 20),
    panel   = Color3.fromRGB(20, 20, 28),
    section = Color3.fromRGB(26, 26, 36),
    element = Color3.fromRGB(34, 34, 46),
    hover   = Color3.fromRGB(44, 44, 58),
    accent  = Color3.fromRGB(160, 110, 240),
    text    = Color3.fromRGB(235, 235, 245),
    subtext = Color3.fromRGB(140, 140, 165),
    line    = Color3.fromRGB(40, 40, 55),
    on      = Color3.fromRGB(140, 100, 220),
    off     = Color3.fromRGB(60, 60, 78),
    danger  = Color3.fromRGB(220, 70, 70),
    success = Color3.fromRGB(80, 210, 130),
}
local FONT = Enum.Font.Gotham
local FONT_B = Enum.Font.GothamBold
local FONT_M = Enum.Font.GothamMedium

-- ============================================================
-- UTILITIES
-- ============================================================
local function create(class, props, parent)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do inst[k] = v end
    if parent then inst.Parent = parent end
    return inst
end

local function corner(inst, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 6)
    c.Parent = inst
    return c
end

local function stroke(inst, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color or C.line
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = inst
    return s
end

local function padding(inst, t, r, b, l)
    local p = Instance.new("UIPadding")
    p.PaddingTop = UDim.new(0, t or 0)
    p.PaddingRight = UDim.new(0, r or 0)
    p.PaddingBottom = UDim.new(0, b or 0)
    p.PaddingLeft = UDim.new(0, l or 0)
    p.Parent = inst
    return p
end

local function list(inst, pad, dir)
    local l = Instance.new("UIListLayout")
    l.Padding = UDim.new(0, pad or 6)
    l.FillDirection = dir or Enum.FillDirection.Vertical
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.Parent = inst
    return l
end

-- ============================================================
-- STATE
-- ============================================================
local Config = {
    Enabled = false,
    Range = 150,
    TargetPart = "Head",       -- Head / Torso / HumanoidRootPart / UpperTorso
    WallCheck = false,
    AutoEquip = true,
    FireRate = 0.05,
    ShowCircle = true,
    ShowLine = true,
    CircleColor = Color3.fromRGB(160, 110, 240),
    LineColor = Color3.fromRGB(255, 80, 80),
    Whitelist = {},            -- {["PlayerName"] = true}
    UseToolRemote = true,
}

local KillAuraActive = false
local lastShot = 0

-- ============================================================
-- HELPERS
-- ============================================================
local function getRoot()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid(plr)
    local char = plr and plr.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function getTargetPart(plr, partName)
    local char = plr and plr.Character
    if not char then return nil end
    return char:FindFirstChild(partName)
end

local function hasLineOfSight(targetPart)
    if not Config.WallCheck then return true end
    local root = getRoot()
    if not root then return false end
    local origin = Camera.CFrame.Position
    local dir = targetPart.Position - origin
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { LocalPlayer.Character, targetPart.Parent }
    params.IgnoreWater = true
    local result = Workspace:Raycast(origin, dir, params)
    return result == nil
end

local function getNearestTarget()
    local root = getRoot()
    if not root then return nil end
    local nearest, nearestDist = nil, Config.Range
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        if Config.Whitelist[plr.Name] then continue end
        local hum = getHumanoid(plr)
        if not hum or hum.Health <= 0 then continue end
        local char = plr.Character
        if char:FindFirstChildOfClass("ForceField") then continue end
        local part = getTargetPart(plr, Config.TargetPart)
        if not part then continue end
        local dist = (part.Position - root.Position).Magnitude
        if dist < nearestDist then
            if hasLineOfSight(part) then
                nearest = plr
                nearestDist = dist
            end
        end
    end
    return nearest
end

local function getEquippedTool()
    local char = LocalPlayer.Character
    if not char then return nil end
    return char:FindFirstChildOfClass("Tool")
end

local function equipTool()
    if not Config.AutoEquip then return end
    local char = LocalPlayer.Character
    if not char then return end
    if char:FindFirstChildOfClass("Tool") then return end
    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    if not backpack then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    for _, tool in ipairs(backpack:GetChildren()) do
        if tool:IsA("Tool") then
            pcall(function() hum:EquipTool(tool) end)
            return
        end
    end
end

-- ============================================================
-- SHOOT LOGIC (multi-strategy)
-- ============================================================
local function shootAt(targetPlr)
    local tool = getEquippedTool()
    if not tool then
        equipTool()
        return
    end
    local targetPart = getTargetPart(targetPlr, Config.TargetPart)
    if not targetPart then return end

    -- Strategy 1: Direct Activate (works for most melee / hitscan tools)
    pcall(function()
        if tool.Activate then
            tool:Activate()
        end
    end)

    -- Strategy 2: Fire common remotes if any exist on the tool
    pcall(function()
        for _, remote in ipairs(tool:GetDescendants()) do
            if remote:IsA("RemoteEvent") then
                remote:FireServer()
            elseif remote:IsA("RemoteFunction") then
                remote:InvokeServer()
            end
        end
    end)

    -- Strategy 3: Aim the camera at target (helps with hitscan weapons)
    pcall(function()
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPart.Position)
    end)
end

-- ============================================================
-- KILL AURA LOOP
-- ============================================================
local auraThread
local function startAura()
    if auraThread then return end
    auraThread = task.spawn(function()
        while KillAuraActive do
            local now = tick()
            if now - lastShot >= Config.FireRate then
                lastShot = now
                local target = getNearestTarget()
                if target then
                    shootAt(target)
                end
            end
            task.wait()
        end
        auraThread = nil
    end)
end

local function stopAura()
    KillAuraActive = false
end

-- ============================================================
-- VISUAL: RANGE CIRCLE + TARGET LINE
-- ============================================================
local visualGui = create("ScreenGui", {
    Name = "DARKHUB_KillAuraViz",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    DisplayOrder = 200,
    Parent = CoreGui,
})

local circle = create("Frame", {
    Parent = visualGui,
    BackgroundTransparency = 1,
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    Size = UDim2.new(0, Config.Range * 2, 0, Config.Range * 2),
    Visible = false,
})
corner(circle, 99999)
local circleStroke = stroke(circle, Config.CircleColor, 1.5, 0.3)

local line = create("Frame", {
    Parent = visualGui,
    BackgroundColor3 = Config.LineColor,
    BorderSizePixel = 0,
    AnchorPoint = Vector2.new(0, 0.5),
    Visible = false,
    Size = UDim2.new(0, 0, 0, 1.5),
})

-- ============================================================
-- UI BUILDER (DARK HUB style)
-- ============================================================
local function buildWindow()
    local gui = create("ScreenGui", {
        Name = "DARKHUB_KillAura",
        ResetOnSpawn = false,
        DisplayOrder = 100,
        Parent = CoreGui,
    })

    local main = create("Frame", {
        Parent = gui,
        Size = UDim2.fromOffset(360, 420),
        Position = UDim2.new(0.5, -180, 0.5, -210),
        BackgroundColor3 = C.bg,
        BorderSizePixel = 0,
        Active = true,
        ClipsDescendants = true,
    })
    corner(main, 12)
    stroke(main, C.accent, 1, 0.5)

    -- Topbar
    local top = create("Frame", {
        Parent = main,
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = C.panel,
        BorderSizePixel = 0,
    })
    corner(top, 12)
    create("Frame", {
        Parent = top,
        Position = UDim2.new(0, 0, 1, -12),
        Size = UDim2.new(1, 0, 0, 12),
        BackgroundColor3 = C.panel,
        BorderSizePixel = 0,
    })
    local logo = create("Frame", {
        Parent = top,
        BackgroundColor3 = C.accent,
        Position = UDim2.new(0, 12, 0.5, -14),
        Size = UDim2.new(0, 28, 0, 28),
        BorderSizePixel = 0,
    })
    corner(logo, 14)
    create("TextLabel", {
        Parent = logo, BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Font = FONT_B, Text = "KA", TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 12,
    })
    create("TextLabel", {
        Parent = top, BackgroundTransparency = 1,
        Position = UDim2.new(0, 48, 0, 6),
        Size = UDim2.new(1, -100, 0, 18),
        Font = FONT_B, Text = "DARK HUB",
        TextColor3 = C.text, TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    create("TextLabel", {
        Parent = top, BackgroundTransparency = 1,
        Position = UDim2.new(0, 48, 0, 23),
        Size = UDim2.new(1, -100, 0, 14),
        Font = FONT, Text = "Kill Aura Module",
        TextColor3 = C.accent, TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    local closeBtn = create("TextButton", {
        Parent = top, BackgroundColor3 = C.danger,
        Position = UDim2.new(1, -38, 0.5, -9),
        Size = UDim2.new(0, 26, 0, 26),
        BorderSizePixel = 0, Text = "X",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = FONT_B, TextSize = 12,
        AutoButtonColor = false,
    })
    corner(closeBtn, 6)
    closeBtn.MouseButton1Click:Connect(function()
        gui.Enabled = false
    end)

    -- Content
    local content = create("ScrollingFrame", {
        Parent = main,
        Position = UDim2.new(0, 0, 0, 42),
        Size = UDim2.new(1, 0, 1, -42),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = C.accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
    })
    local contentList = list(content, 10)
    padding(content, 12, 12, 12, 12)

    local function refresh()
        task.wait()
        content.CanvasSize = UDim2.new(0, 0, 0, contentList.AbsoluteContentSize.Y + 24)
    end

    -- Section builder
    local function makeSection(name)
        local sec = create("Frame", {
            Parent = content,
            Size = UDim2.new(1, 0, 0, 44),
            BackgroundColor3 = C.section,
            BorderSizePixel = 0,
        })
        corner(sec, 8)
        stroke(sec, C.line, 1, 0.5)
        create("TextLabel", {
            Parent = sec, BackgroundTransparency = 1,
            Position = UDim2.new(0, 14, 0, 0),
            Size = UDim2.new(1, -28, 0, 44),
            Font = FONT_B, Text = name,
            TextColor3 = C.accent, TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
        })
        local body = create("Frame", {
            Parent = sec,
            Position = UDim2.new(0, 0, 0, 44),
            Size = UDim2.new(1, 0, 0, 0),
            BackgroundTransparency = 1,
        })
        local bodyList = list(body, 6)
        padding(body, 8, 10, 8, 10)

        local function refreshSection()
            task.wait()
            body.Size = UDim2.new(1, 0, 0, bodyList.AbsoluteContentSize.Y + 16)
            sec.Size = UDim2.new(1, 0, 0, 44 + body.Size.Y.Offset)
            refresh()
        end

        local section = {}
        function section:Toggle(title, default, cb)
            local card = create("Frame", {
                Parent = body,
                Size = UDim2.new(1, 0, 0, 38),
                BackgroundColor3 = C.element,
                BorderSizePixel = 0,
            })
            corner(card, 6)
            create("TextLabel", {
                Parent = card, BackgroundTransparency = 1,
                Position = UDim2.new(0, 12, 0, 0),
                Size = UDim2.new(1, -70, 1, 0),
                Font = FONT_M, Text = title,
                TextColor3 = C.text, TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
            })
            local state = default and true or false
            local tog = create("TextButton", {
                Parent = card,
                BackgroundColor3 = state and C.on or C.off,
                Position = UDim2.new(1, -52, 0.5, -11),
                Size = UDim2.new(0, 40, 0, 22),
                BorderSizePixel = 0, Text = "", AutoButtonColor = false,
            })
            corner(tog, 11)
            local knob = create("Frame", {
                Parent = tog,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                Size = UDim2.new(0, 18, 0, 18),
                Position = state and UDim2.new(1, -20, 0, 2) or UDim2.new(0, 2, 0, 2),
                BorderSizePixel = 0,
            })
            corner(knob, 9)
            tog.MouseButton1Click:Connect(function()
                state = not state
                TweenService:Create(tog, TweenInfo.new(0.15), {BackgroundColor3 = state and C.on or C.off}):Play()
                TweenService:Create(knob, TweenInfo.new(0.15), {
                    Position = state and UDim2.new(1, -20, 0, 2) or UDim2.new(0, 2, 0, 2)
                }):Play()
                if cb then pcall(cb, state) end
            end)
            task.defer(refreshSection)
        end

        function section:Slider(title, min, max, default, suffix, cb)
            local card = create("Frame", {
                Parent = body,
                Size = UDim2.new(1, 0, 0, 48),
                BackgroundColor3 = C.element,
                BorderSizePixel = 0,
            })
            corner(card, 6)
            create("TextLabel", {
                Parent = card, BackgroundTransparency = 1,
                Position = UDim2.new(0, 12, 0, 4),
                Size = UDim2.new(1, -80, 0, 20),
                Font = FONT_M, Text = title,
                TextColor3 = C.text, TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
            })
            local val = default or min
            local valLabel = create("TextLabel", {
                Parent = card, BackgroundTransparency = 1,
                Position = UDim2.new(1, -70, 0, 4),
                Size = UDim2.new(0, 58, 0, 20),
                Font = FONT_B,
                Text = tostring(val) .. (suffix or ""),
                TextColor3 = C.accent, TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Right,
            })
            local track = create("Frame", {
                Parent = card,
                BackgroundColor3 = C.bg,
                Position = UDim2.new(0, 12, 0, 30),
                Size = UDim2.new(1, -24, 0, 8),
                BorderSizePixel = 0,
            })
            corner(track, 4)
            local ratio = (val - min) / math.max(max - min, 1)
            local fill = create("Frame", {
                Parent = track,
                BackgroundColor3 = C.accent,
                Size = UDim2.new(ratio, 0, 1, 0),
                BorderSizePixel = 0,
            })
            corner(fill, 4)
            local knob = create("Frame", {
                Parent = track,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                Size = UDim2.new(0, 14, 0, 14),
                Position = UDim2.new(ratio, -7, 0.5, -7),
                BorderSizePixel = 0,
                ZIndex = 2,
            })
            corner(knob, 7)
            local dragging = false
            local function upd(x)
                local rel = math.clamp((x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
                local v = math.floor(min + rel * (max - min) + 0.5)
                valLabel.Text = tostring(v) .. (suffix or "")
                fill.Size = UDim2.new(rel, 0, 1, 0)
                knob.Position = UDim2.new(rel, -7, 0.5, -7)
                if cb then pcall(cb, v) end
            end
            track.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    upd(input.Position.X)
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
                or input.UserInputType == Enum.UserInputType.Touch) then
                    upd(input.Position.X)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)
            task.defer(refreshSection)
        end

        function section:Dropdown(title, options, default, cb)
            local card = create("Frame", {
                Parent = body,
                Size = UDim2.new(1, 0, 0, 38),
                BackgroundColor3 = C.element,
                BorderSizePixel = 0,
            })
            corner(card, 6)
            create("TextLabel", {
                Parent = card, BackgroundTransparency = 1,
                Position = UDim2.new(0, 12, 0, 0),
                Size = UDim2.new(1, -110, 1, 0),
                Font = FONT_M, Text = title,
                TextColor3 = C.text, TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
            })
            local index = 1
            for i, v in ipairs(options) do
                if v == default then index = i break end
            end
            local btn = create("TextButton", {
                Parent = card,
                BackgroundColor3 = C.bg,
                Position = UDim2.new(1, -100, 0.5, -12),
                Size = UDim2.new(0, 88, 0, 24),
                BorderSizePixel = 0,
                Font = FONT,
                Text = tostring(options[index] or "None"),
                TextColor3 = C.text, TextSize = 10,
                AutoButtonColor = false,
            })
            corner(btn, 4)
            if cb then pcall(cb, options[index]) end
            btn.MouseButton1Click:Connect(function()
                index = index % #options + 1
                local v = options[index]
                btn.Text = tostring(v)
                if cb then pcall(cb, v) end
            end)
            task.defer(refreshSection)
        end

        function section:Button(title, cb)
            local btn = create("TextButton", {
                Parent = body,
                Size = UDim2.new(1, 0, 0, 36),
                BackgroundColor3 = C.element,
                BorderSizePixel = 0,
                Text = "", AutoButtonColor = false,
            })
            corner(btn, 6)
            create("TextLabel", {
                Parent = btn, BackgroundTransparency = 1,
                Position = UDim2.new(0, 12, 0, 0),
                Size = UDim2.new(1, -24, 1, 0),
                Font = FONT_M, Text = title,
                TextColor3 = C.text, TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
            })
            btn.MouseEnter:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = C.hover}):Play()
            end)
            btn.MouseLeave:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = C.element}):Play()
            end)
            btn.MouseButton1Click:Connect(function()
                if cb then pcall(cb) end
            end)
            task.defer(refreshSection)
        end

        return section
    end

    -- Drag window
    local dragging, dragStart, startPos
    top.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)

    return gui, main, makeSection
end

-- ============================================================
-- BUILD UI
-- ============================================================
local mainGui, mainFrame, makeSection = buildWindow()

-- Section: Core
local coreSec = makeSection("Kill Aura")
coreSec:Toggle("Enabled", Config.Enabled, function(state)
    Config.Enabled = state
    KillAuraActive = state
    if state then startAura() else stopAura() end
end)

coreSec:Slider("Range", 20, 500, Config.Range, " st", function(v)
    Config.Range = v
    circle.Size = UDim2.new(0, Config.Range * 2, 0, Config.Range * 2)
end)

coreSec:Slider("Fire Rate (x0.01s)", 1, 50, 5, "", function(v)
    Config.FireRate = v / 100
end)

coreSec:Dropdown("Target Part", {
    "Head", "Torso", "UpperTorso", "HumanoidRootPart"
}, Config.TargetPart, function(v)
    Config.TargetPart = v
end)

-- Section: Options
local optSec = makeSection("Options")
optSec:Toggle("Wall Check", Config.WallCheck, function(state)
    Config.WallCheck = state
end)
optSec:Toggle("Auto Equip", Config.AutoEquip, function(state)
    Config.AutoEquip = state
end)

-- Section: Visual
local visSec = makeSection("Visuals")
visSec:Toggle("Show Range Circle", Config.ShowCircle, function(state)
    Config.ShowCircle = state
end)
visSec:Toggle("Show Target Line", Config.ShowLine, function(state)
    Config.ShowLine = state
end)

-- Section: Whitelist
local wlSec = makeSection("Whitelist")
wlSec:Button("Add Me (Local Player)", function()
    Config.Whitelist[LocalPlayer.Name] = not Config.Whitelist[LocalPlayer.Name]
end)
wlSec:Button("Clear Whitelist", function()
    Config.Whitelist = {}
end)

-- Section: Control
local ctrlSec = makeSection("Control")
ctrlSec:Button("Force Unload Kill Aura", function()
    KillAuraActive = false
    auraThread = nil
    visualGui:Destroy()
    mainGui:Destroy()
end)

-- ============================================================
-- VISUAL UPDATE LOOP
-- ============================================================
RunService.RenderStepped:Connect(function()
    -- Circle
    if Config.ShowCircle and KillAuraActive then
        circle.Visible = true
        circleStroke.Color = Config.CircleColor
        circle.Size = UDim2.new(0, Config.Range * 2, 0, Config.Range * 2)
    else
        circle.Visible = false
    end

    -- Line to nearest target
    if Config.ShowLine and KillAuraActive then
        local target = getNearestTarget()
        if target then
            local part = getTargetPart(target, Config.TargetPart)
            if part then
                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local mouseLoc = UserInputService:GetMouseLocation()
                    -- Draw line from center of screen to target
                    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                    local delta = Vector2.new(screenPos.X, screenPos.Y) - center
                    local dist = delta.Magnitude
                    local angle = math.atan2(delta.Y, delta.X)
                    line.Visible = true
                    line.Position = UDim2.new(0, center.X, 0, center.Y)
                    line.Size = UDim2.new(0, dist, 0, 1.5)
                    line.Rotation = math.deg(angle)
                    line.BackgroundColor3 = Config.LineColor
                else
                    line.Visible = false
                end
            else
                line.Visible = false
            end
        else
            line.Visible = false
        end
    else
        line.Visible = false
    end
end)

-- ============================================================
-- MOBILE TOGGLE BUTTON
-- ============================================================
local mtGui = create("ScreenGui", {
    Name = "DARKHUB_KillAuraToggle",
    ResetOnSpawn = false,
    Parent = CoreGui,
})
local mtBtn = create("TextButton", {
    Parent = mtGui,
    BackgroundColor3 = C.bg,
    BorderColor3 = C.accent,
    BorderSizePixel = 2,
    Position = UDim2.new(0, 50, 0, 50),
    Size = UDim2.new(0, 46, 0, 46),
    Font = FONT_B, Text = "KA",
    TextColor3 = C.text, TextSize = 12,
    AutoButtonColor = false,
})
corner(mtBtn, 999)
local mtDrag, mtStart, mtPos
mtBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
    or input.UserInputType == Enum.UserInputType.MouseButton1 then
        mtDrag = true
        mtStart = input.Position
        mtPos = mtBtn.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then mtDrag = false end
        end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if mtDrag and (input.UserInputType == Enum.UserInputType.Touch
    or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local d = input.Position - mtStart
        mtBtn.Position = UDim2.new(mtPos.X.Scale, mtPos.X.Offset + d.X, mtPos.Y.Scale, mtPos.Y.Offset + d.Y)
    end
end)
mtBtn.MouseButton1Click:Connect(function()
    mainGui.Enabled = not mainGui.Enabled
end)