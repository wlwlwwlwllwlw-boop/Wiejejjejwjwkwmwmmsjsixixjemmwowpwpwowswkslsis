-- ============================================================
-- DARK HUB | Cali Streets
-- Custom UI - Self-contained, no external library
-- ============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local ProximityPromptService = game:GetService("ProximityPromptService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local setclipboard = setclipboard or toboard or writeclipboard

-- ============================================================
-- THEME
-- ============================================================
local C = {
    bg        = Color3.fromRGB(14, 14, 20),
    panel     = Color3.fromRGB(20, 20, 28),
    section   = Color3.fromRGB(26, 26, 36),
    element   = Color3.fromRGB(34, 34, 46),
    hover     = Color3.fromRGB(44, 44, 58),
    accent    = Color3.fromRGB(160, 110, 240),
    accent2   = Color3.fromRGB(120, 80, 200),
    text      = Color3.fromRGB(235, 235, 245),
    subtext   = Color3.fromRGB(140, 140, 165),
    line      = Color3.fromRGB(40, 40, 55),
    on        = Color3.fromRGB(140, 100, 220),
    off       = Color3.fromRGB(60, 60, 78),
    danger    = Color3.fromRGB(220, 70, 70),
    success   = Color3.fromRGB(80, 210, 130),
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

local function addCorner(inst, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = inst
    return c
end

local function addStroke(inst, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color or C.line
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = inst
    return s
end

local function addPadding(inst, t, r, b, l)
    local p = Instance.new("UIPadding")
    p.PaddingTop = UDim.new(0, t or 0)
    p.PaddingRight = UDim.new(0, r or 0)
    p.PaddingBottom = UDim.new(0, b or 0)
    p.PaddingLeft = UDim.new(0, l or 0)
    p.Parent = inst
    return p
end

local function addList(inst, pad, dir)
    local l = Instance.new("UIListLayout")
    l.Padding = UDim.new(0, pad or 6)
    l.FillDirection = dir or Enum.FillDirection.Vertical
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.Parent = inst
    return l
end

-- ============================================================
-- NOTIFICATION SYSTEM
-- ============================================================
local notifyGui = create("ScreenGui", {
    Name = "DARKHUB_Notify", ResetOnSpawn = false,
    DisplayOrder = 500, Parent = CoreGui,
})
local notifyHolder = create("Frame", {
    Parent = notifyGui, BackgroundTransparency = 1,
    AnchorPoint = Vector2.new(1, 1),
    Position = UDim2.new(1, -14, 1, -14),
    Size = UDim2.new(0, 300, 0, 500),
})
addList(notifyHolder, 8, Enum.FillDirection.Vertical)
notifyHolder.UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
notifyHolder.UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right

local function notify(title, desc, duration)
    duration = duration or 3
    local f = create("Frame", {
        Parent = notifyHolder,
        Size = UDim2.new(1, 0, 0, 64),
        BackgroundColor3 = C.section,
        BorderSizePixel = 0,
        LayoutOrder = os.clock() * 1000,
    })
    addCorner(f, 8)
    addStroke(f, C.accent, 1, 0.5)
    local bar = create("Frame", {
        Parent = f, BackgroundColor3 = C.accent,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0, 3, 1, 0),
        BorderSizePixel = 0,
    })
    addCorner(bar, 8)
    create("TextLabel", {
        Parent = f, BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 8),
        Size = UDim2.new(1, -22, 0, 18),
        Font = FONT_B, Text = title or "Notification",
        TextColor3 = C.text, TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    create("TextLabel", {
        Parent = f, BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 26),
        Size = UDim2.new(1, -22, 0, 32),
        Font = FONT, Text = desc or "",
        TextColor3 = C.subtext, TextSize = 10,
        TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
    })
    task.delay(duration, function()
        if not f.Parent then return end
        local t = TweenService:Create(f, TweenInfo.new(0.25), {BackgroundTransparency = 1})
        t:Play()
        for _, d in ipairs(f:GetDescendants()) do
            if d:IsA("TextLabel") then
                TweenService:Create(d, TweenInfo.new(0.25), {TextTransparency = 1}):Play()
            elseif d:IsA("Frame") then
                TweenService:Create(d, TweenInfo.new(0.25), {BackgroundTransparency = 1}):Play()
            elseif d:IsA("UIStroke") then
                TweenService:Create(d, TweenInfo.new(0.25), {Transparency = 1}):Play()
            end
        end
        t.Completed:Wait()
        f:Destroy()
    end)
end

-- ============================================================
-- CONTROL FACTORIES
-- ============================================================
local function makeToggle(parent, cfg)
    local card = create("Frame", {
        Parent = parent, Size = UDim2.new(1, 0, 0, cfg.Desc and 52 or 38),
        BackgroundColor3 = C.element, BorderSizePixel = 0,
    })
    addCorner(card, 6)
    create("TextLabel", {
        Parent = card, BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(1, -70, cfg.Desc and 0.5 or 1, 0),
        Font = FONT_M, Text = cfg.Title,
        TextColor3 = C.text, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    if cfg.Desc then
        create("TextLabel", {
            Parent = card, BackgroundTransparency = 1,
            Position = UDim2.new(0, 12, 0, 24),
            Size = UDim2.new(1, -70, 0, 22),
            Font = FONT, Text = cfg.Desc,
            TextColor3 = C.subtext, TextSize = 9,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top,
        })
    end
    local state = cfg.Default and true or false
    local tog = create("TextButton", {
        Parent = card, BackgroundColor3 = state and C.on or C.off,
        Position = UDim2.new(1, -52, 0.5, -11),
        Size = UDim2.new(0, 40, 0, 22),
        BorderSizePixel = 0, Text = "", AutoButtonColor = false,
    })
    addCorner(tog, 11)
    local knob = create("Frame", {
        Parent = tog, BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Size = UDim2.new(0, 18, 0, 18),
        Position = state and UDim2.new(1, -20, 0, 2) or UDim2.new(0, 2, 0, 2),
        BorderSizePixel = 0,
    })
    addCorner(knob, 9)
    tog.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(tog, TweenInfo.new(0.15), {BackgroundColor3 = state and C.on or C.off}):Play()
        TweenService:Create(knob, TweenInfo.new(0.15), {
            Position = state and UDim2.new(1, -20, 0, 2) or UDim2.new(0, 2, 0, 2)
        }):Play()
        if cfg.Callback then pcall(cfg.Callback, state) end
    end)
end

local function makeButton(parent, cfg)
    local btn = create("TextButton", {
        Parent = parent,
        Size = UDim2.new(1, 0, 0, cfg.Desc and 52 or 36),
        BackgroundColor3 = C.element, BorderSizePixel = 0,
        Text = "", AutoButtonColor = false,
    })
    addCorner(btn, 6)
    create("TextLabel", {
        Parent = btn, BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(1, -24, cfg.Desc and 0.5 or 1, 0),
        Font = FONT_M, Text = cfg.Title,
        TextColor3 = C.text, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    if cfg.Desc then
        create("TextLabel", {
            Parent = btn, BackgroundTransparency = 1,
            Position = UDim2.new(0, 12, 0, 24),
            Size = UDim2.new(1, -24, 0, 22),
            Font = FONT, Text = cfg.Desc,
            TextColor3 = C.subtext, TextSize = 9,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top,
        })
    end
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = C.hover}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = C.element}):Play()
    end)
    btn.MouseButton1Click:Connect(function()
        if cfg.Callback then pcall(cfg.Callback) end
    end)
end

local function makeSlider(parent, cfg)
    local card = create("Frame", {
        Parent = parent,
        Size = UDim2.new(1, 0, 0, cfg.Desc and 64 or 48),
        BackgroundColor3 = C.element, BorderSizePixel = 0,
    })
    addCorner(card, 6)
    create("TextLabel", {
        Parent = card, BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 4),
        Size = UDim2.new(1, -80, 0, 20),
        Font = FONT_M, Text = cfg.Title,
        TextColor3 = C.text, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    local valLabel = create("TextLabel", {
        Parent = card, BackgroundTransparency = 1,
        Position = UDim2.new(1, -70, 0, 4),
        Size = UDim2.new(0, 58, 0, 20),
        Font = FONT_B, Text = tostring(cfg.Default or cfg.Min),
        TextColor3 = C.accent, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Right,
    })
    local trackY = cfg.Desc and 42 or 30
    local track = create("Frame", {
        Parent = card, BackgroundColor3 = C.bg,
        Position = UDim2.new(0, 12, 0, trackY),
        Size = UDim2.new(1, -24, 0, 8), BorderSizePixel = 0,
    })
    addCorner(track, 4)
    local defVal = cfg.Default or cfg.Min
    local ratio = (defVal - cfg.Min) / math.max(cfg.Max - cfg.Min, 1)
    local fill = create("Frame", {
        Parent = track, BackgroundColor3 = C.accent,
        Size = UDim2.new(ratio, 0, 1, 0), BorderSizePixel = 0,
    })
    addCorner(fill, 4)
    local knob = create("Frame", {
        Parent = track, BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new(ratio, -7, 0.5, -7),
        BorderSizePixel = 0, ZIndex = 2,
    })
    addCorner(knob, 7)
    local dragging = false
    local function update(x)
        local rel = math.clamp((x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
        local v = math.floor(cfg.Min + rel * (cfg.Max - cfg.Min) + 0.5)
        valLabel.Text = tostring(v)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        knob.Position = UDim2.new(rel, -7, 0.5, -7)
        if cfg.Callback then pcall(cfg.Callback, v) end
    end
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; update(input.Position.X)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

local function makeDropdown(parent, cfg)
    local card = create("Frame", {
        Parent = parent,
        Size = UDim2.new(1, 0, 0, cfg.Desc and 52 or 38),
        BackgroundColor3 = C.element, BorderSizePixel = 0,
    })
    addCorner(card, 6)
    create("TextLabel", {
        Parent = card, BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(1, -110, cfg.Desc and 0.5 or 1, 0),
        Font = FONT_M, Text = cfg.Title,
        TextColor3 = C.text, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    if cfg.Desc then
        create("TextLabel", {
            Parent = card, BackgroundTransparency = 1,
            Position = UDim2.new(0, 12, 0, 24),
            Size = UDim2.new(1, -110, 0, 22),
            Font = FONT, Text = cfg.Desc,
            TextColor3 = C.subtext, TextSize = 9,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top,
        })
    end
    local opts = cfg.Options or {}
    local index = 1
    local multi = cfg.Multi or false
    local selectedSet = {}
    local btn = create("TextButton", {
        Parent = card, BackgroundColor3 = C.bg,
        Position = UDim2.new(1, -100, 0.5, -12),
        Size = UDim2.new(0, 88, 0, 24), BorderSizePixel = 0,
        Font = FONT, Text = multi and "Select" or tostring(opts[1] or "None"),
        TextColor3 = C.text, TextSize = 10, AutoButtonColor = false,
    })
    addCorner(btn, 4)
    if multi then
        if cfg.Callback then pcall(cfg.Callback, selectedSet) end
    else
        if cfg.Callback then pcall(cfg.Callback, opts[1]) end
    end
    btn.MouseButton1Click:Connect(function()
        if #opts == 0 then return end
        if multi then
            local cur = opts[index]
            if cur then
                selectedSet[cur] = not selectedSet[cur]
                local list = {}
                for k, v in pairs(selectedSet) do if v then table.insert(list, k) end end
                btn.Text = #list > 0 and (#list .. " selected") or "Select"
                if cfg.Callback then pcall(cfg.Callback, selectedSet) end
            end
            index = index % #opts + 1
        else
            index = index % #opts + 1
            local val = opts[index]
            btn.Text = tostring(val)
            if cfg.Callback then pcall(cfg.Callback, val) end
        end
    end)
end

local function makeColorPicker(parent, cfg)
    local card = create("Frame", {
        Parent = parent,
        Size = UDim2.new(1, 0, 0, cfg.Desc and 52 or 38),
        BackgroundColor3 = C.element, BorderSizePixel = 0,
    })
    addCorner(card, 6)
    create("TextLabel", {
        Parent = card, BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(1, -70, cfg.Desc and 0.5 or 1, 0),
        Font = FONT_M, Text = cfg.Title,
        TextColor3 = C.text, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    if cfg.Desc then
        create("TextLabel", {
            Parent = card, BackgroundTransparency = 1,
            Position = UDim2.new(0, 12, 0, 24),
            Size = UDim2.new(1, -70, 0, 22),
            Font = FONT, Text = cfg.Desc,
            TextColor3 = C.subtext, TextSize = 9,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top,
        })
    end
    local swatch = create("TextButton", {
        Parent = card, BackgroundColor3 = cfg.Default or Color3.fromRGB(255, 0, 0),
        Position = UDim2.new(1, -44, 0.5, -12),
        Size = UDim2.new(0, 32, 0, 24),
        BorderSizePixel = 0, Text = "", AutoButtonColor = false,
    })
    addCorner(swatch, 4)
    addStroke(swatch, C.line, 1, 0.3)
    swatch.MouseButton1Click:Connect(function()
        local col = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
        swatch.BackgroundColor3 = col
        if cfg.Callback then pcall(cfg.Callback, col) end
    end)
end

local function makeTextbox(parent, cfg)
    local card = create("Frame", {
        Parent = parent,
        Size = UDim2.new(1, 0, 0, cfg.Desc and 52 or 38),
        BackgroundColor3 = C.element, BorderSizePixel = 0,
    })
    addCorner(card, 6)
    create("TextLabel", {
        Parent = card, BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(1, -140, cfg.Desc and 0.5 or 1, 0),
        Font = FONT_M, Text = cfg.Title,
        TextColor3 = C.text, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    if cfg.Desc then
        create("TextLabel", {
            Parent = card, BackgroundTransparency = 1,
            Position = UDim2.new(0, 12, 0, 24),
            Size = UDim2.new(1, -140, 0, 22),
            Font = FONT, Text = cfg.Desc,
            TextColor3 = C.subtext, TextSize = 9,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top,
        })
    end
    local box = create("TextBox", {
        Parent = card, BackgroundColor3 = C.bg,
        Position = UDim2.new(1, -128, 0.5, -12),
        Size = UDim2.new(0, 116, 0, 24), BorderSizePixel = 0,
        Font = FONT, PlaceholderText = cfg.Placeholder or "Enter...",
        PlaceholderColor3 = C.subtext, Text = "",
        TextColor3 = C.text, TextSize = 10,
        ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left,
    })
    addCorner(box, 4)
    addPadding(box, 0, 0, 0, 6)
    box.FocusLost:Connect(function()
        if cfg.Callback then pcall(cfg.Callback, box.Text) end
    end)
end

-- ============================================================
-- WINDOW BUILDER
-- ============================================================
local function BuildWindow(cfg)
    cfg = cfg or {}
    local gui = create("ScreenGui", {
        Name = "DARKHUB_Main", ResetOnSpawn = false,
        DisplayOrder = 100, Parent = CoreGui,
    })
    local main = create("Frame", {
        Parent = gui,
        Size = UDim2.fromOffset(600, 420),
        Position = UDim2.new(0.5, -300, 0.5, -210),
        BackgroundColor3 = C.bg,
        BorderSizePixel = 0, Active = true, ClipsDescendants = true,
    })
    addCorner(main, 12)
    addStroke(main, C.accent, 1, 0.5)

    -- Topbar
    local topbar = create("Frame", {
        Parent = main, Size = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = C.panel, BorderSizePixel = 0,
    })
    addCorner(topbar, 12)
    create("Frame", {
        Parent = topbar, Position = UDim2.new(0, 0, 1, -12),
        Size = UDim2.new(1, 0, 0, 12),
        BackgroundColor3 = C.panel, BorderSizePixel = 0,
    })
    -- Logo circle
    local logo = create("Frame", {
        Parent = topbar, BackgroundColor3 = C.accent,
        Position = UDim2.new(0, 12, 0.5, -14),
        Size = UDim2.new(0, 28, 0, 28), BorderSizePixel = 0,
    })
    addCorner(logo, 14)
    create("TextLabel", {
        Parent = logo, BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Font = FONT_B, Text = "DH", TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 12,
    })
    create("TextLabel", {
        Parent = topbar, BackgroundTransparency = 1,
        Position = UDim2.new(0, 48, 0, 6),
        Size = UDim2.new(1, -140, 0, 18),
        Font = FONT_B, Text = cfg.Title or "DARK HUB",
        TextColor3 = C.text, TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    create("TextLabel", {
        Parent = topbar, BackgroundTransparency = 1,
        Position = UDim2.new(0, 48, 0, 23),
        Size = UDim2.new(1, -140, 0, 14),
        Font = FONT, Text = cfg.Subtitle or "Cali Streets",
        TextColor3 = C.accent, TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    -- Window buttons
    local minBtn = create("TextButton", {
        Parent = topbar, BackgroundColor3 = C.element,
        Position = UDim2.new(1, -78, 0.5, -9),
        Size = UDim2.new(0, 26, 0, 26),
        BorderSizePixel = 0, Text = "-", TextColor3 = C.text,
        Font = FONT_B, TextSize = 14, AutoButtonColor = false,
    })
    addCorner(minBtn, 6)
    local closeBtn = create("TextButton", {
        Parent = topbar, BackgroundColor3 = C.danger,
        Position = UDim2.new(1, -44, 0.5, -9),
        Size = UDim2.new(0, 26, 0, 26),
        BorderSizePixel = 0, Text = "X", TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = FONT_B, TextSize = 12, AutoButtonColor = false,
    })
    addCorner(closeBtn, 6)
    closeBtn.MouseButton1Click:Connect(function() gui.Enabled = false end)

    -- Sidebar
    local sidebar = create("Frame", {
        Parent = main, Position = UDim2.new(0, 0, 0, 42),
        Size = UDim2.new(0, 140, 1, -42),
        BackgroundColor3 = C.panel, BorderSizePixel = 0,
    })
    create("Frame", {
        Parent = sidebar, Position = UDim2.new(1, -1, 0, 0),
        Size = UDim2.new(0, 1, 1, 0),
        BackgroundColor3 = C.line, BorderSizePixel = 0,
    })
    local sideScroll = create("ScrollingFrame", {
        Parent = sidebar, BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0), BorderSizePixel = 0,
        ScrollBarThickness = 2, ScrollBarImageColor3 = C.accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
    })
    addList(sideScroll, 4)
    addPadding(sideScroll, 8, 8, 8, 8)

    -- Content
    local content = create("Frame", {
        Parent = main, Position = UDim2.new(0, 140, 0, 42),
        Size = UDim2.new(1, -140, 1, -42),
        BackgroundColor3 = C.bg, BorderSizePixel = 0,
    })
    local pageBar = create("Frame", {
        Parent = content, Size = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = C.bg, BorderSizePixel = 0,
    })
    create("Frame", {
        Parent = pageBar, Position = UDim2.new(0, 0, 1, -1),
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = C.line, BorderSizePixel = 0,
    })
    local pageScroll = create("ScrollingFrame", {
        Parent = pageBar, BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -20, 1, 0), BorderSizePixel = 0,
        ScrollBarThickness = 0, CanvasSize = UDim2.new(0, 0, 1, 0),
        ScrollingDirection = Enum.ScrollingDirection.X,
    })
    local pageList = addList(pageScroll, 6, Enum.FillDirection.Horizontal)
    pageList.VerticalAlignment = Enum.VerticalAlignment.Center

    local pageContainer = create("Frame", {
        Parent = content, Position = UDim2.new(0, 0, 0, 34),
        Size = UDim2.new(1, 0, 1, -34), BackgroundTransparency = 1,
    })

    local Window = { _gui = gui, _main = main }
    local allTabs = {}
    local activeTab

    local function selectTab(tab)
        activeTab = tab
        for _, t in ipairs(allTabs) do
            local isActive = (t == tab)
            t.btn.BackgroundColor3 = isActive and C.element or C.panel
            t.btn.BackgroundTransparency = isActive and 0 or 1
            t.lbl.TextColor3 = isActive and C.accent or C.text
        end
        if tab._showFirst then tab._showFirst() end
    end

    function Window:CreateTab(name, isDefault)
        local btn = create("TextButton", {
            Parent = sideScroll, Size = UDim2.new(1, 0, 0, 30),
            BackgroundColor3 = C.panel, BackgroundTransparency = 1,
            BorderSizePixel = 0, Text = "", AutoButtonColor = false,
        })
        addCorner(btn, 6)
        local lbl = create("TextLabel", {
            Parent = btn, BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 0),
            Size = UDim2.new(1, -20, 1, 0),
            Font = FONT_M, Text = name,
            TextColor3 = C.text, TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
        })
        sideScroll.CanvasSize = UDim2.new(0, 0, 0, #allTabs * 34 + 20)

        local tab = { btn = btn, lbl = lbl, _pages = {}, _name = name }
        local firstPage

        local function showPage(pg)
            for _, p in ipairs(tab._pages) do
                local isActive = (p == pg)
                p.btn.BackgroundColor3 = isActive and C.accent or C.panel
                p.btn.TextColor3 = isActive and Color3.fromRGB(255, 255, 255) or C.subtext
                p.frame.Visible = isActive
            end
        end

        function tab:CreatePage(pageName)
            local pbtn = create("TextButton", {
                Parent = pageScroll, Size = UDim2.new(0, 100, 0, 24),
                BackgroundColor3 = C.panel, BorderSizePixel = 0,
                Text = pageName, Font = FONT_M,
                TextColor3 = C.subtext, TextSize = 11, AutoButtonColor = false,
            })
            addCorner(pbtn, 5)

            local frame = create("ScrollingFrame", {
                Parent = pageContainer, BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0), BorderSizePixel = 0,
                ScrollBarThickness = 3, ScrollBarImageColor3 = C.accent,
                CanvasSize = UDim2.new(0, 0, 0, 0), Visible = false,
            })
            local fl = addList(frame, 10)
            addPadding(frame, 12, 12, 12, 12)

            local page = { _frame = frame, btn = pbtn, frame = frame, _sections = {} }

            local function refreshCanvas()
                task.wait()
                frame.CanvasSize = UDim2.new(0, 0, 0, fl.AbsoluteContentSize.Y + 24)
            end

            function page:CreateSection(sectionName)
                local section = create("Frame", {
                    Parent = frame, Size = UDim2.new(1, 0, 0, 44),
                    BackgroundColor3 = C.section, BorderSizePixel = 0,
                })
                addCorner(section, 8)
                addStroke(section, C.line, 1, 0.5)
                create("TextLabel", {
                    Parent = section, BackgroundTransparency = 1,
                    Position = UDim2.new(0, 14, 0, 0),
                    Size = UDim2.new(1, -28, 0, 44),
                    Font = FONT_B, Text = sectionName,
                    TextColor3 = C.accent, TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                })
                local body = create("Frame", {
                    Parent = section, Position = UDim2.new(0, 0, 0, 44),
                    Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1,
                })
                local bl = addList(body, 6)
                addPadding(body, 8, 10, 8, 10)

                local function refresh()
                    task.wait()
                    body.Size = UDim2.new(1, 0, 0, bl.AbsoluteContentSize.Y + 16)
                    section.Size = UDim2.new(1, 0, 0, 44 + body.Size.Y.Offset)
                    refreshCanvas()
                end

                local sec = {}
                function sec:AddToggle(name, default, callback, opts)
                    opts = opts or {}
                    makeToggle(body, {Title = opts.Title or name, Desc = opts.Description, Default = default, Callback = callback})
                    task.defer(refresh)
                end
                function sec:AddButton(name, callback, opts)
                    opts = opts or {}
                    makeButton(body, {Title = opts.Title or name, Desc = opts.Description, Callback = callback})
                    task.defer(refresh)
                end
                function sec:AddSlider(name, min, max, default, callback, opts)
                    opts = opts or {}
                    makeSlider(body, {Title = opts.Title or name, Desc = opts.Description, Min = min, Max = max, Default = default, Callback = callback})
                    task.defer(refresh)
                end
                function sec:AddDropdown(name, options, multi, callback, opts)
                    opts = opts or {}
                    makeDropdown(body, {Title = opts.Title or name, Desc = opts.Description, Options = options, Multi = multi, Callback = callback})
                    task.defer(refresh)
                end
                function sec:AddColorPicker(name, default, callback, opts)
                    opts = opts or {}
                    makeColorPicker(body, {Title = opts.Title or name, Desc = opts.Description, Default = default, Callback = callback})
                    task.defer(refresh)
                end
                function sec:AddTextbox(name, placeholder, callback, opts)
                    opts = opts or {}
                    makeTextbox(body, {Title = opts.Title or name, Desc = opts.Description, Placeholder = placeholder, Callback = callback})
                    task.defer(refresh)
                end
                function sec:AddCopyButton(name, textToCopy, opts)
                    opts = opts or {}
                    makeButton(body, {
                        Title = opts.Title or name,
                        Desc = opts.Description,
                        Callback = function()
                            if setclipboard then setclipboard(textToCopy) end
                            notify("Copied", "Text copied to clipboard.", 2)
                        end,
                    })
                    task.defer(refresh)
                end
                function sec:AddConfigManager(name) end -- no-op, kept for API compatibility
                return sec
            end

            pbtn.MouseButton1Click:Connect(function() showPage(page) end)
            table.insert(tab._pages, page)
            if not firstPage then
                firstPage = page
                tab._showFirst = function() showPage(page) end
            end
            task.defer(function()
                pageScroll.CanvasSize = UDim2.new(0, #tab._pages * 106, 1, 0)
            end)
            return page
        end

        btn.MouseButton1Click:Connect(function() selectTab(tab) end)
        table.insert(allTabs, tab)
        if isDefault or #allTabs == 1 then
            task.defer(function() selectTab(tab) end)
        end
        return tab
    end

    -- Drag
    local dragging, dragStart, startPos
    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)

    function Window:SetTransparency(v)
        v = v or 0
        main.BackgroundTransparency = v
        topbar.BackgroundTransparency = v
        sidebar.BackgroundTransparency = v
        content.BackgroundTransparency = v
    end

    function Window:Destroy()
        gui:Destroy()
    end

    return Window
end

-- ============================================================
-- GAME STATE
-- ============================================================
_G.InfiniteStaminaEnabled = false
_G.AutoLoot = false
_G.NoJumpCooldownEnabled = false
_G.ESPEnabled = false
_G.FPSBoostUsed = false
_G.NoclipEnabled = false
_G.WalkSpeedEnabled = false
_G.WalkSpeedMultiplier = 1.25
_G.InstantInteractEnabled = false
_G.InfiniteZoomEnabled = false
_G.CustomAimbotVisible = false
_G.CustomAimbotActive = false
_G.AimbotDraggable = true

local aimbotFOV = 120
local autoFarmEnabled = false
local selectedPlayer = nil
local espData = {}

-- ============================================================
-- HELPERS
-- ============================================================
local function getRootPart()
    local c = LocalPlayer.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function getCharacter()
    local c = LocalPlayer.Character
    if not c then return nil end
    local h = c:FindFirstChildOfClass("Humanoid")
    if not h or h.Health <= 0 then return nil end
    return c:FindFirstChild("HumanoidRootPart")
end

-- ============================================================
-- AUTO FARM
-- ============================================================
local function tweenToPosition(targetPos)
    if not autoFarmEnabled then return end
    local root = getRootPart()
    if not root then return end
    local dist = (targetPos - root.Position).Magnitude
    local t = dist / 25
    root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
    local tw = TweenService:Create(root, TweenInfo.new(t, Enum.EasingStyle.Linear), {CFrame = CFrame.new(targetPos)})
    tw:Play()
    while t > 0 do
        if not autoFarmEnabled then tw:Cancel() return end
        local r = getRootPart()
        if not r then tw:Cancel() return end
        r.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        task.wait(0.05)
        t = t - 0.05
    end
    local r = getRootPart()
    if r then
        r.CFrame = CFrame.new(targetPos)
        r.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    end
end

local function interactWithPrompt(targetPos, radius)
    if not autoFarmEnabled then return end
    radius = radius or 35
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and obj.Enabled then
            local p = obj.Parent
            if p and p:IsA("BasePart") and (p.Position - targetPos).Magnitude < radius then
                pcall(function()
                    if fireproximityprompt then
                        fireproximityprompt(obj)
                    else
                        obj:Hold(LocalPlayer)
                        task.wait(obj.HoldDuration or 2)
                        obj:Release()
                    end
                end)
                return true
            end
        end
    end
end

local function findToolInInventory(pat)
    if not autoFarmEnabled then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
    for _, t in ipairs(char:GetChildren()) do
        if t:IsA("Tool") and string.find(string.lower(t.Name), string.lower(pat)) then return true end
    end
    if bp and hum then
        for _, t in ipairs(bp:GetChildren()) do
            if t:IsA("Tool") and string.find(string.lower(t.Name), string.lower(pat)) then
                hum:EquipTool(t)
                task.wait(0.4)
                return true
            end
        end
    end
end

local function autoFarmLoop()
    while autoFarmEnabled do
        if not getCharacter() then
            task.wait(1)
        else
            tweenToPosition(Vector3.new(-337, 693, 366))
            for _ = 1, 2 do
                if not autoFarmEnabled then break end
                interactWithPrompt(Vector3.new(-337, 693, 366))
                task.wait(0.6)
            end
            if autoFarmEnabled then
                for _, pos in ipairs({ Vector3.new(-467, 693, 41), Vector3.new(-475, 693, 45) }) do
                    if not autoFarmEnabled then break end
                    tweenToPosition(pos)
                    findToolInInventory("blank")
                    task.wait(0.4)
                    interactWithPrompt(pos)
                    task.wait(0.8)
                end
            end
            if autoFarmEnabled then
                for _ = 1, 17 do
                    if not autoFarmEnabled then break end
                    task.wait(1)
                end
            end
            if autoFarmEnabled then
                tweenToPosition(Vector3.new(-319, 692, 29))
                for _ = 1, 2 do
                    if not autoFarmEnabled then break end
                    findToolInInventory("activated")
                    task.wait(0.4)
                    interactWithPrompt(Vector3.new(-319, 692, 29))
                    task.wait(0.6)
                end
            end
            task.wait(1)
        end
    end
end

-- ============================================================
-- ESP
-- ============================================================
local function removeESP(player)
    if espData[player] then
        if espData[player].Billboard then espData[player].Billboard:Destroy() end
        if espData[player].Highlight then espData[player].Highlight:Destroy() end
        if espData[player].CharConn then espData[player].CharConn:Disconnect() end
        espData[player] = nil
    end
end

local function addESP(player)
    if player == LocalPlayer then return end
    espData[player] = {}
    local function setup(char)
        removeESP(player)
        espData[player] = {}
        if not char then return end
        local head = char:WaitForChild("Head", 5)
        local hum = char:WaitForChild("Humanoid", 5)
        if not head or not hum then return end
        local bb = create("BillboardGui", {
            Name = "ESP_NameTag", Adornee = head,
            Size = UDim2.new(0, 100, 0, 40),
            StudsOffset = Vector3.new(0, 2, 0),
            AlwaysOnTop = true, Parent = head,
        })
        create("TextLabel", {
            Parent = bb, BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Font = FONT_B, Text = player.DisplayName,
            TextColor3 = Color3.fromRGB(0, 255, 255),
            TextSize = 14, TextStrokeTransparency = 0.5,
        })
        local hl = create("Highlight", {
            Name = "ESP_Highlight", Adornee = char,
            FillColor = Color3.fromRGB(0, 170, 255),
            FillTransparency = 0.5,
            OutlineColor = Color3.fromRGB(255, 255, 255),
            OutlineTransparency = 0, Parent = char,
        })
        espData[player].Billboard = bb
        espData[player].Highlight = hl
        espData[player].Character = char
    end
    if player.Character then setup(player.Character) end
    espData[player].CharConn = player.CharacterAdded:Connect(setup)
end

local function canSeeTarget(targetHead)
    local char = LocalPlayer.Character
    local origin = Camera.CFrame.Position
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {char, char and char:FindFirstChild("Head")}
    params.IgnoreWater = true
    local r = Workspace:Raycast(origin, targetHead.Position - origin, params)
    if r then return r.Instance:IsDescendantOf(targetHead.Parent) end
    return true
end

-- ============================================================
-- BUILD UI
-- ============================================================
local Window = BuildWindow({
    Title = "DARK HUB",
    Subtitle = "Cali Streets",
})

local MainTab    = Window:CreateTab("Main", true)
local FarmTab    = Window:CreateTab("Auto Farm")
local CombatTab  = Window:CreateTab("Combat")
local VisualsTab = Window:CreateTab("Visuals")
local SocialsTab = Window:CreateTab("Socials")
local SettingsTab = Window:CreateTab("Settings")

-- ===== Main Tab =====
local MainPage = MainTab:CreatePage("Player")
local MainSec = MainPage:CreateSection("Player Modules")
MainSec:AddToggle("InfiniteStamina", false, function(s) _G.InfiniteStaminaEnabled = s end, {
    Title = "Infinite Stamina",
    Description = "Locks stamina at 100 so you can sprint endlessly.",
})
MainSec:AddToggle("AutoPickup", false, function(s)
    _G.AutoLoot = s
    if s then
        task.spawn(function()
            while _G.AutoLoot do
                pcall(function()
                    for _, obj in ipairs(Workspace:GetChildren()) do
                        if not _G.AutoLoot then break end
                        if obj:IsA("Tool") or string.find(string.lower(obj.Name), "loot") then
                            local h = obj:FindFirstChild("Handle")
                            if h and h:IsA("BasePart") then
                                local r = getRootPart()
                                if r then h.CFrame = r.CFrame end
                            end
                        end
                    end
                end)
                task.wait(0.5)
            end
        end)
    end
end, {
    Title = "Auto Pickup Loot",
    Description = "Teleports dropped tools to your character.",
})
MainSec:AddToggle("InstantInteract", false, function(s) _G.InstantInteractEnabled = s end, {
    Title = "Instant Interact",
    Description = "Removes hold timers on proximity prompts.",
})
MainSec:AddToggle("NoJumpCooldown", false, function(s) _G.NoJumpCooldownEnabled = s end, {
    Title = "No Jump Cooldown",
    Description = "Removes jump cooldown for continuous jumping.",
})
MainSec:AddToggle("Noclip", false, function(s) _G.NoclipEnabled = s end, {
    Title = "Noclip",
    Description = "Allows you to walk through walls.",
})
MainSec:AddToggle("SafeSpeed", false, function(s) _G.WalkSpeedEnabled = s end, {
    Title = "Safe Speed Boost",
    Description = "Boost your speed slightly to avoid anti-cheat detection.",
})

-- ===== Auto Farm Tab =====
local FarmPage = FarmTab:CreatePage("Auto Farm")
local FarmSec = FarmPage:CreateSection("Blank Card Auto Farm")

local autoFarmGui = create("ScreenGui", {
    Name = "DARKHUB_AutoFarmGUI", Parent = CoreGui,
    ResetOnSpawn = false, Enabled = false,
})
local autoFarmFrame = create("Frame", {
    Parent = autoFarmGui,
    Size = UDim2.new(0, 200, 0, 90),
    Position = UDim2.new(0.05, 0, 0.2, 0),
    BackgroundColor3 = C.bg, BorderSizePixel = 0,
    Active = true, Draggable = true,
})
addCorner(autoFarmFrame, 8)
addStroke(autoFarmFrame, C.accent, 1, 0.5)
create("TextLabel", {
    Parent = autoFarmFrame, BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 30),
    Text = "BLANK CARD AUTO-FARM",
    TextColor3 = C.text, TextSize = 12, Font = FONT_B,
})
local farmBtn = create("TextButton", {
    Parent = autoFarmFrame,
    Size = UDim2.new(0.85, 0, 0, 35),
    Position = UDim2.new(0.075, 0, 0.45, 0),
    BackgroundColor3 = C.element,
    TextColor3 = Color3.fromRGB(255, 100, 100),
    Text = "Auto Farm: OFF", TextSize = 12, Font = FONT_B,
    BorderSizePixel = 0, AutoButtonColor = false,
})
addCorner(farmBtn, 6)
farmBtn.MouseButton1Click:Connect(function()
    if not autoFarmEnabled then
        autoFarmEnabled = true
        farmBtn.Text = "Auto Farm: ON"
        farmBtn.TextColor3 = C.success
        task.spawn(autoFarmLoop)
    else
        autoFarmEnabled = false
        farmBtn.Text = "Auto Farm: OFF"
        farmBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
end)

FarmSec:AddToggle("SpawnAutoFarmGui", false, function(s)
    autoFarmGui.Enabled = s
    if not s then
        autoFarmEnabled = false
        farmBtn.Text = "Auto Farm: OFF"
        farmBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
end, {
    Title = "Spawn Auto Farm UI",
    Description = "Show or hide the floating auto farm menu.",
})
FarmSec:AddToggle("FreezeAutoFarmBtn", false, function(s)
    autoFarmFrame.Draggable = not s
end, {
    Title = "Freeze Auto Farm UI",
    Description = "Locks the floating auto farm UI so it cannot be dragged.",
})

-- ===== Combat Tab =====
local CombatPage = CombatTab:CreatePage("Combat")
local CombatSec = CombatPage:CreateSection("Combat Modules")

local aimbotGui = create("ScreenGui", {
    Name = "DARKHUB_AimbotGUI", Parent = CoreGui,
    ResetOnSpawn = false, Enabled = false,
})
local fovCircle = create("Frame", {
    Parent = aimbotGui, BackgroundTransparency = 1,
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    Size = UDim2.new(0, aimbotFOV * 2, 0, aimbotFOV * 2),
})
local fovCorner = addCorner(fovCircle, 9999)
local fovStroke = addStroke(fovCircle, Color3.fromRGB(0, 170, 255), 1.5, 0.3)

local aimbotBtn = create("TextButton", {
    Parent = aimbotGui,
    BackgroundColor3 = C.bg,
    BorderColor3 = Color3.fromRGB(0, 170, 255),
    BorderSizePixel = 2,
    Position = UDim2.new(0, 50, 0, 110),
    Size = UDim2.new(0, 90, 0, 45),
    Font = FONT_B, Text = "AIMBOT: OFF",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 12, AutoButtonColor = false,
})
addCorner(aimbotBtn, 8)
aimbotBtn.MouseButton1Click:Connect(function()
    _G.CustomAimbotActive = not _G.CustomAimbotActive
    if _G.CustomAimbotActive then
        aimbotBtn.Text = "AIMBOT: ON"
        aimbotBtn.TextColor3 = C.success
        fovStroke.Color = C.success
    else
        aimbotBtn.Text = "AIMBOT: OFF"
        aimbotBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        fovStroke.Color = Color3.fromRGB(0, 170, 255)
    end
end)
local aimDrag, aimStart, aimPos
aimbotBtn.InputBegan:Connect(function(input)
    if not _G.AimbotDraggable then return end
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        aimDrag = true
        aimStart = input.Position
        aimPos = aimbotBtn.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then aimDrag = false end
        end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if not _G.AimbotDraggable then return end
    if aimDrag and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local d = input.Position - aimStart
        aimbotBtn.Position = UDim2.new(aimPos.X.Scale, aimPos.X.Offset + d.X, aimPos.Y.Scale, aimPos.Y.Offset + d.Y)
    end
end)

CombatSec:AddToggle("SpawnAimbotGui", false, function(s)
    _G.CustomAimbotVisible = s
    aimbotGui.Enabled = s
    if not s then
        _G.CustomAimbotActive = false
        aimbotBtn.Text = "AIMBOT: OFF"
        aimbotBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        fovStroke.Color = Color3.fromRGB(0, 170, 255)
    end
end, {
    Title = "Spawn Aimbot UI",
    Description = "Show or hide the floating aimbot UI and FOV ring.",
})
CombatSec:AddSlider("AimbotCircleSize", 40, 300, 120, function(v)
    aimbotFOV = v
    fovCircle.Size = UDim2.new(0, aimbotFOV * 2, 0, aimbotFOV * 2)
end, {
    Title = "Aimbot Circle Size (FOV)",
    Description = "Adjust the size of the aimbot FOV circle.",
})
CombatSec:AddToggle("FreezeAimbotBtn", false, function(s)
    _G.AimbotDraggable = not s
end, {
    Title = "Freeze Aimbot UI",
    Description = "Locks the floating aimbot UI so it cannot be dragged.",
})

-- ===== Visuals Tab =====
local VisPage = VisualsTab:CreatePage("Visuals")
local VisSec = VisPage:CreateSection("Visual Modules")
VisSec:AddToggle("MaxZoomOut", false, function(s)
    _G.InfiniteZoomEnabled = s
    if not s then LocalPlayer.CameraMaxZoomDistance = 128 end
end, {
    Title = "Max Zoom Out",
    Description = "Bypasses max camera zoom limits.",
})
VisSec:AddToggle("PlayerESP", false, function(s) _G.ESPEnabled = s end, {
    Title = "Player ESP",
    Description = "Highlights characters and shows their name tag.",
})

local playerList = {}
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then
        table.insert(playerList, p.DisplayName)
        addESP(p)
    end
end
if #playerList == 0 then table.insert(playerList, "None") end

VisSec:AddDropdown("SelectTargetPlayer", playerList, false, function(sel)
    selectedPlayer = sel
end, {
    Title = "Select Player",
    Description = "Click to cycle to the next player.",
})
VisSec:AddButton("InspectInventory", function()
    if not selectedPlayer then
        notify("Inspect", "No player selected.", 3)
        return
    end
    local t = nil
    for _, p in ipairs(Players:GetPlayers()) do
        if p.DisplayName == selectedPlayer or p.Name == selectedPlayer then
            t = p
            break
        end
    end
    if not t then
        notify("Not Found", "Player not in game.", 3)
        return
    end
    local inv = {}
    local char = t.Character
    if char then
        for _, item in ipairs(char:GetChildren()) do
            if item:IsA("Tool") then table.insert(inv, item.Name) end
        end
        local bp = t:FindFirstChildOfClass("Backpack")
        if bp then
            for _, item in ipairs(bp:GetChildren()) do
                if item:IsA("Tool") then table.insert(inv, item.Name .. " (Equipped)") end
            end
        end
    end
    local content = #inv > 0 and table.concat(inv, ", ") or "Inventory is empty."
    notify(t.DisplayName .. "'s Inventory", content, 6)
end, {
    Title = "Inspect Inventory",
    Description = "Check the selected player's tools.",
})

Players.PlayerAdded:Connect(function(p)
    if p ~= LocalPlayer then
        table.insert(playerList, p.DisplayName)
        addESP(p)
    end
end)
Players.PlayerRemoving:Connect(function(p)
    removeESP(p)
    for i, n in ipairs(playerList) do
        if n == p.DisplayName then table.remove(playerList, i) break end
    end
end)

-- ===== Socials Tab =====
local SocPage = SocialsTab:CreatePage("Links")
local SocSec = SocPage:CreateSection("Social Links")
SocSec:AddCopyButton("CopyDiscord", "https://discord.gg/xKvegCV6yf", {
    Title = "Discord Server",
    Description = "Click to copy the Discord invite link.",
})
SocSec:AddCopyButton("CopyYouTube", "https://youtube.com/@strixwashere", {
    Title = "YouTube Channel",
    Description = "Click to copy the YouTube channel link.",
})

-- ===== Settings Tab =====
local SetPage = SettingsTab:CreatePage("Settings")
local SetSec = SetPage:CreateSection("General")
SetSec:AddButton("FPSBooster", function()
    if _G.FPSBoostUsed then
        notify("FPS Booster", "Already applied.", 3)
        return
    end
    _G.FPSBoostUsed = true
    pcall(function()
        local l = game:GetService("Lighting")
        l.GlobalShadows = false
        l.FogEnd = 999999
        for _, o in ipairs(l:GetChildren()) do
            if o:IsA("PostEffect") or o:IsA("Atmosphere") or o:IsA("Sky") or o:IsA("Clouds") or o:IsA("BlurEffect") then
                o:Destroy()
            end
        end
        for _, o in ipairs(Workspace:GetDescendants()) do
            if o:IsA("BasePart") then
                o.Material = Enum.Material.SmoothPlastic
                o.CastShadow = false
            elseif o:IsA("Texture") or o:IsA("Decal") then
                o:Destroy()
            end
        end
    end)
    notify("FPS Booster", "Graphics stripped.", 4)
end, {
    Title = "FPS Booster (Potato Graphics)",
    Description = "Strips heavy textures and effects to boost FPS.",
})
SetSec:AddButton("TransparencyToggle", function()
    local current = Window._main.BackgroundTransparency
    Window:SetTransparency(current > 0 and 0 or 0.2)
end, {
    Title = "Toggle Transparency",
    Description = "Toggle main window transparency.",
})
SetSec:AddButton("UnloadScript", function()
    pcall(function()
        autoFarmGui:Destroy()
        aimbotGui:Destroy()
        local wm = CoreGui:FindFirstChild("DARKHUB_Watermark")
        if wm then wm:Destroy() end
        local mt = CoreGui:FindFirstChild("DARKHUB_MobileToggle")
        if mt then mt:Destroy() end
        if notifyGui then notifyGui:Destroy() end
        Window:Destroy()
        autoFarmEnabled = false
        _G.ESPEnabled = false
        for p, _ in pairs(espData) do removeESP(p) end
    end)
end, {
    Title = "Unload Script",
    Description = "Unloads DARK HUB and cleans up all UI.",
})

-- ============================================================
-- WATERMARK
-- ============================================================
local wmGui = create("ScreenGui", {
    Name = "DARKHUB_Watermark", Parent = CoreGui,
    ResetOnSpawn = false, DisplayOrder = -1,
})
create("TextLabel", {
    Parent = wmGui, BackgroundTransparency = 1,
    AnchorPoint = Vector2.new(0.5, 0),
    Position = UDim2.new(0.5, 0, 0, 6),
    Size = UDim2.new(0, 400, 0, 20),
    Font = FONT_B, Text = "DARK HUB",
    TextColor3 = C.accent, TextTransparency = 0.3, TextSize = 13,
    TextXAlignment = Enum.TextXAlignment.Center,
})

-- ============================================================
-- MOBILE TOGGLE
-- ============================================================
local mtGui = create("ScreenGui", {
    Name = "DARKHUB_MobileToggle", Parent = CoreGui, ResetOnSpawn = false,
})
local mtBtn = create("TextButton", {
    Parent = mtGui,
    BackgroundColor3 = C.bg,
    BorderColor3 = C.accent, BorderSizePixel = 2,
    Position = UDim2.new(0, 50, 0, 50),
    Size = UDim2.new(0, 46, 0, 46),
    Font = FONT_B, Text = "DH",
    TextColor3 = C.text, TextSize = 12, AutoButtonColor = false,
})
addCorner(mtBtn, 999)
local mtDrag, mtStart, mtPos
mtBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        mtDrag = true
        mtStart = input.Position
        mtPos = mtBtn.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then mtDrag = false end
        end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if mtDrag and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local d = input.Position - mtStart
        mtBtn.Position = UDim2.new(mtPos.X.Scale, mtPos.X.Offset + d.X, mtPos.Y.Scale, mtPos.Y.Offset + d.Y)
    end
end)
mtBtn.MouseButton1Click:Connect(function()
    Window._gui.Enabled = not Window._gui.Enabled
end)

-- ============================================================
-- GAME LOOPS
-- ============================================================
ProximityPromptService.PromptTriggered:Connect(function(prompt)
    if _G.InstantInteractEnabled then
        pcall(function()
            if fireproximityprompt then fireproximityprompt(prompt) end
        end)
    end
end)

RunService.RenderStepped:Connect(function()
    if not _G.CustomAimbotVisible or not _G.CustomAimbotActive then return end
    local vp = Camera.ViewportSize
    local center = Vector2.new(vp.X / 2, vp.Y / 2)
    local tgt, best = nil, aimbotFOV
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
            local h = p.Character.Head
            local sp, on = Camera:WorldToViewportPoint(h.Position)
            if on then
                local d = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                if d <= aimbotFOV and canSeeTarget(h) and d < best then
                    best = d
                    tgt = h
                end
            end
        end
    end
    if tgt then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, tgt.Position)
    end
end)

RunService.Heartbeat:Connect(function()
    if _G.InfiniteZoomEnabled then
        LocalPlayer.CameraMaxZoomDistance = 100000
    end
    for _, data in pairs(espData) do
        local vis = _G.ESPEnabled and data.Character and data.Character:FindFirstChild("Humanoid")
        if data.Billboard then data.Billboard.Enabled = vis end
        if data.Highlight then data.Highlight.Enabled = vis end
    end
end)

RunService.Stepped:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local rp = char:FindFirstChild("HumanoidRootPart")
    if not hum or not rp then return end

    if _G.NoclipEnabled then
        for _, part in ipairs(Workspace:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end

    if _G.InfiniteStaminaEnabled then
        for _, v in ipairs(char:GetDescendants()) do
            if v:IsA("NumberValue") and string.find(string.lower(v.Name), "stamina") then
                v.Value = 100
            end
        end
        for an, val in pairs(hum:GetAttributes()) do
            if string.find(string.lower(an), "stamina") and typeof(val) == "number" then
                hum:SetAttribute(an, 100)
            end
        end
    end

    if _G.WalkSpeedEnabled then
        rp.CFrame = rp.CFrame + hum.MoveDirection * (_G.WalkSpeedMultiplier - 1) * 0.5
    end
end)

UserInputService.JumpRequest:Connect(function()
    if _G.NoJumpCooldownEnabled then
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
    end
end)

RunService.Stepped:Connect(function()
    if _G.NoJumpCooldownEnabled then
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true) end)
            end
        end
    end
end)

-- ============================================================
-- READY
-- ============================================================
notify("DARK HUB Loaded", "All features ready.", 5)