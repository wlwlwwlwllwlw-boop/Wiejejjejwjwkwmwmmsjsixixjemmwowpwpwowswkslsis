--[[
    Custom UI - RapidFire + No Recoil
    Made from scratch (no external library)
]]

-- ==================== SERVICES ====================
local Players           = game:GetService("Players")
local UserInputService  = game:GetService("UserInputService")
local RunService        = game:GetService("RunService")
local TweenService      = game:GetService("TweenService")
local CoreGui           = game:GetService("CoreGui")
local LocalPlayer       = Players.LocalPlayer

-- ==================== CONFIG ====================
_G.Settings = {
    RapidFire   = false,
    FireRate    = 0.03,
    NoRecoil    = false,
    NoSpread    = false,
    QuickReload = false,
    NoJam       = false,
    UIKeybind   = Enum.KeyCode.RightShift,
}

-- ==================== GUN MODIFIER ====================
local function ApplyGunMods(tool)
    if not tool or not tool:IsA("Tool") then return end
    local setting = tool:FindFirstChild("Setting")
    if not setting or not setting:IsA("ModuleScript") then return end
    pcall(function()
        local s = require(setting)
        if type(s) ~= "table" then return end
        if _G.Settings.NoRecoil then
            if s.Accuracy ~= nil then s.Accuracy = 1 end
            if s.Recoil   ~= nil then s.Recoil   = 0 end
        end
        if _G.Settings.NoSpread then
            if s.SpreadX ~= nil then s.SpreadX = 0 end
            if s.SpreadY ~= nil then s.SpreadY = 0 end
        end
        if _G.Settings.RapidFire and s.FireRate ~= nil then
            s.FireRate = _G.Settings.FireRate
        end
        if _G.Settings.QuickReload and s.ReloadTime ~= nil then
            s.ReloadTime = 0
        end
        if _G.Settings.NoJam and s.JamChance ~= nil then
            s.JamChance = 0
        end
    end)
end

local function ApplyAll()
    for _, c in pairs({LocalPlayer:FindFirstChild("Backpack"), LocalPlayer.Character}) do
        if c then
            for _, t in ipairs(c:GetChildren()) do
                if t:IsA("Tool") then ApplyGunMods(t) end
            end
        end
    end
end

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1)
    ApplyAll()
    char.ChildAdded:Connect(function(ch)
        if ch:IsA("Tool") then task.wait(0.1); ApplyGunMods(ch) end
    end)
end)
if LocalPlayer:FindFirstChild("Backpack") then
    LocalPlayer.Backpack.ChildAdded:Connect(function(ch)
        if ch:IsA("Tool") then task.wait(0.1); ApplyGunMods(ch) end
    end)
end
task.spawn(function()
    while task.wait(1) do ApplyAll() end
end)

-- ==================== NOTIFICATION ====================
local notifHolder
local function Notify(title, text, dur)
    if not notifHolder then return end
    dur = dur or 4

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 260, 0, 60)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    frame.BorderSizePixel = 0
    frame.Position = UDim2.new(0, -280, 0, 0)
    frame.Parent = notifHolder

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(60, 60, 70)
    stroke.Thickness = 1
    stroke.Parent = frame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local accent = Instance.new("Frame")
    accent.Size = UDim2.new(0, 4, 1, 0)
    accent.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    accent.BorderSizePixel = 0
    accent.Parent = frame
    Instance.new("UICorner", accent).CornerRadius = UDim.new(0, 8)

    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1, -20, 0, 20)
    t.Position = UDim2.new(0, 14, 0, 8)
    t.BackgroundTransparency = 1
    t.Text = title
    t.TextColor3 = Color3.fromRGB(255, 255, 255)
    t.Font = Enum.Font.GothamBold
    t.TextSize = 14
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.Parent = frame

    local d = Instance.new("TextLabel")
    d.Size = UDim2.new(1, -20, 0, 24)
    d.Position = UDim2.new(0, 14, 0, 28)
    d.BackgroundTransparency = 1
    d.Text = text
    d.TextColor3 = Color3.fromRGB(180, 180, 190)
    d.Font = Enum.Font.Gotham
    d.TextSize = 12
    d.TextWrapped = true
    d.TextXAlignment = Enum.TextXAlignment.Left
    d.Parent = frame

    local yOffset = 0
    for _, c in ipairs(notifHolder:GetChildren()) do
        if c:IsA("Frame") and c ~= frame then
            yOffset = yOffset + 70
        end
    end
    frame.Position = UDim2.new(0, -280, 0, yOffset)

    TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
        Position = UDim2.new(0, 0, 0, yOffset)
    }):Play()

    task.delay(dur, function()
        local out = TweenService:Create(frame, TweenInfo.new(0.3), {
            Position = UDim2.new(0, -280, 0, frame.Position.Y.Offset)
        })
        out:Play()
        out.Completed:Connect(function() frame:Destroy() end)
    end)
end

-- ==================== GUI PARENT ====================
local function GetGuiParent()
    local ok, pg = pcall(function() return game:GetService("CoreGui") end)
    if ok and pg then return pg end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CustomUI_" .. tostring(math.random(1000, 9999))
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = GetGuiParent()

-- ==================== UI HELPERS ====================
local UI = {}

function UI.Corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = parent
    return c
end

function UI.Stroke(parent, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or Color3.fromRGB(60, 60, 70)
    s.Thickness = thickness or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

function UI.Padding(parent, val)
    local p = Instance.new("UIPadding")
    p.PaddingTop = UDim.new(0, val)
    p.PaddingBottom = UDim.new(0, val)
    p.PaddingLeft = UDim.new(0, val)
    p.PaddingRight = UDim.new(0, val)
    p.Parent = parent
    return p
end

-- ==================== MAIN WINDOW ====================
local Window = Instance.new("Frame")
Window.Name = "Window"
Window.Size = UDim2.new(0, 480, 0, 320)
Window.Position = UDim2.new(0.5, -240, 0.5, -160)
Window.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Window.BorderSizePixel = 0
Window.Active = true
Window.Draggable = true
Window.Parent = ScreenGui
UI.Corner(Window, 12)
UI.Stroke(Window, Color3.fromRGB(50, 50, 60), 1)

-- Top bar
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 38)
TopBar.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
TopBar.BorderSizePixel = 0
TopBar.Parent = Window
UI.Corner(TopBar, 12)
local topFix = Instance.new("Frame")
topFix.Size = UDim2.new(1, 0, 0, 12)
topFix.Position = UDim2.new(0, 0, 1, -12)
topFix.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
topFix.BorderSizePixel = 0
topFix.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -100, 1, 0)
Title.Position = UDim2.new(0, 14, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "⚡ RapidFire + NoRecoil"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

-- Close button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Position = UDim2.new(1, -32, 0, 7)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 18
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = TopBar
UI.Corner(CloseBtn, 6)
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui.Enabled = false
    Notify("ℹ️ Info", "Tekan RightShift untuk buka lagi", 3)
end)

-- Minimize button
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 24, 0, 24)
MinBtn.Position = UDim2.new(1, -62, 0, 7)
MinBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
MinBtn.Text = "—"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 14
MinBtn.BorderSizePixel = 0
MinBtn.Parent = TopBar
UI.Corner(MinBtn, 6)
local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    Window.Size = minimized and UDim2.new(0, 480, 0, 38) or UDim2.new(0, 480, 0, 320)
end)

-- ==================== SIDEBAR / TABS ====================
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 120, 1, -50)
Sidebar.Position = UDim2.new(0, 10, 0, 44)
Sidebar.BackgroundColor3 = Color3.fromRGB(26, 26, 32)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Window
UI.Corner(Sidebar, 8)

local TabHolder = Instance.new("Frame")
TabHolder.Size = UDim2.new(1, 0, 1, 0)
TabHolder.BackgroundTransparency = 1
TabHolder.Parent = Sidebar
UI.Padding(TabHolder, 6)

local TabList = Instance.new("UIListLayout")
TabList.Padding = UDim.new(0, 5)
TabList.SortOrder = Enum.SortOrder.LayoutOrder
TabList.Parent = TabHolder

-- Content holder
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -150, 1, -50)
Content.Position = UDim2.new(0, 140, 0, 44)
Content.BackgroundColor3 = Color3.fromRGB(26, 26, 32)
Content.BorderSizePixel = 0
Content.Parent = Window
UI.Corner(Content, 8)

local ContentScroll = Instance.new("ScrollingFrame")
ContentScroll.Size = UDim2.new(1, -12, 1, -12)
ContentScroll.Position = UDim2.new(0, 6, 0, 6)
ContentScroll.BackgroundTransparency = 1
ContentScroll.BorderSizePixel = 0
ContentScroll.ScrollBarThickness = 4
ContentScroll.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 90)
ContentScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
ContentScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
ContentScroll.Parent = Content

local ContentList = Instance.new("UIListLayout")
ContentList.Padding = UDim.new(0, 8)
ContentList.SortOrder = Enum.SortOrder.LayoutOrder
ContentList.Parent = ContentScroll

-- ==================== TAB SYSTEM ====================
local Tabs = {}
local CurrentTab

local function CreateTab(name, icon)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    btn.Text = "  " .. (icon or "") .. "  " .. name
    btn.TextColor3 = Color3.fromRGB(170, 170, 180)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 13
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = TabHolder
    UI.Corner(btn, 6)

    local page = Instance.new("Frame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.Parent = ContentScroll

    local pageList = Instance.new("UIListLayout")
    pageList.Padding = UDim.new(0, 8)
    pageList.SortOrder = Enum.SortOrder.LayoutOrder
    pageList.Parent = page

    local tab = { Button = btn, Page = page, Layout = pageList }

    btn.MouseButton1Click:Connect(function()
        for _, t in pairs(Tabs) do
            t.Button.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
            t.Button.TextColor3 = Color3.fromRGB(170, 170, 180)
            t.Page.Visible = false
        end
        btn.BackgroundColor3 = Color3.fromRGB(0, 120, 220)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        page.Visible = true
        CurrentTab = tab
    end)

    btn.MouseEnter:Connect(function()
        if CurrentTab ~= tab then
            btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        end
    end)
    btn.MouseLeave:Connect(function()
        if CurrentTab ~= tab then
            btn.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
        end
    end)

    table.insert(Tabs, tab)
    return tab
end

-- ==================== SECTION ====================
local function CreateSection(tab, name)
    local sec = Instance.new("Frame")
    sec.Size = UDim2.new(1, 0, 0, 28)
    sec.BackgroundTransparency = 1
    sec.Parent = tab.Page

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = name:upper()
    lbl.TextColor3 = Color3.fromRGB(120, 120, 140)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = sec
    return sec
end

-- ==================== TOGGLE ====================
local function CreateToggle(parent, name, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 34)
    frame.BackgroundColor3 = Color3.fromRGB(32, 32, 40)
    frame.BorderSizePixel = 0
    frame.Parent = parent
    UI.Corner(frame, 6)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -70, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(230, 230, 240)
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local toggleBg = Instance.new("TextButton")
    toggleBg.Size = UDim2.new(0, 42, 0, 20)
    toggleBg.Position = UDim2.new(1, -54, 0.5, -10)
    toggleBg.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    toggleBg.Text = ""
    toggleBg.BorderSizePixel = 0
    toggleBg.AutoButtonColor = false
    toggleBg.Parent = frame
    UI.Corner(toggleBg, 10)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = UDim2.new(0, 2, 0.5, -8)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.Parent = toggleBg
    UI.Corner(knob, 10)

    local state = default or false
    local function render()
        TweenService:Create(toggleBg, TweenInfo.new(0.2), {
            BackgroundColor3 = state and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(60, 60, 70)
        }):Play()
        TweenService:Create(knob, TweenInfo.new(0.2), {
            Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        }):Play()
    end
    render()

    toggleBg.MouseButton1Click:Connect(function()
        state = not state
        render()
        if callback then callback(state) end
    end)

    return frame
end

-- ==================== SLIDER ====================
local function CreateSlider(parent, name, min, max, default, decimals, suffix, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 46)
    frame.BackgroundColor3 = Color3.fromRGB(32, 32, 40)
    frame.BorderSizePixel = 0
    frame.Parent = parent
    UI.Corner(frame, 6)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -60, 0, 18)
    label.Position = UDim2.new(0, 12, 0, 6)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(230, 230, 240)
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(0, 60, 0, 18)
    valLbl.Position = UDim2.new(1, -72, 0, 6)
    valLbl.BackgroundTransparency = 1
    valLbl.Text = tostring(default) .. (suffix or "")
    valLbl.TextColor3 = Color3.fromRGB(0, 170, 255)
    valLbl.Font = Enum.Font.GothamBold
    valLbl.TextSize = 12
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.Parent = frame

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, -24, 0, 6)
    bar.Position = UDim2.new(0, 12, 0, 30)
    bar.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    bar.BorderSizePixel = 0
    bar.Parent = frame
    UI.Corner(bar, 3)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    fill.BorderSizePixel = 0
    fill.Parent = bar
    UI.Corner(fill, 3)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 12, 0, 12)
    knob.Position = UDim2.new((default - min) / (max - min), -6, 0.5, -6)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.Parent = bar
    UI.Corner(knob, 6)

    local dragging = false
    local value = default

    local function update(inputX)
        local rel = math.clamp((inputX - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        value = min + (max - min) * rel
        if decimals then
            local m = 10 ^ decimals
            value = math.floor(value * m + 0.5) / m
        else
            value = math.floor(value + 0.5)
        end
        fill.Size = UDim2.new(rel, 0, 1, 0)
        knob.Position = UDim2.new(rel, -6, 0.5, -6)
        valLbl.Text = tostring(value) .. (suffix or "")
        if callback then callback(value) end
    end

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(input.Position.X)
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

    return frame
end

-- ==================== BUTTON ====================
local function CreateButton(parent, name, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 34)
    btn.BackgroundColor3 = Color3.fromRGB(0, 120, 220)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = parent
    UI.Corner(btn, 6)

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(0, 140, 255)
        }):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(0, 120, 220)
        }):Play()
    end)
    btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
    return btn
end

-- ==================== BUILD UI ====================
local MainTab = CreateTab("Main", "🎯")
local TestTab = CreateTab("Tester", "🧪")

-- ===== MAIN TAB =====
CreateSection(MainTab, "Gun Mods")

CreateToggle(MainTab, "Rapid Fire", false, function(s)
    _G.Settings.RapidFire = s
    ApplyAll()
    Notify("⚡ Rapid Fire", s and "Enabled" or "Disabled", 3)
end)

CreateSlider(MainTab, "Fire Rate", 0.01, 0.15, 0.03, 2, "s", function(v)
    _G.Settings.FireRate = v
    ApplyAll()
end)

CreateToggle(MainTab, "No Recoil", false, function(s)
    _G.Settings.NoRecoil = s
    ApplyAll()
    Notify("🎯 No Recoil", s and "Enabled" or "Disabled", 3)
end)

CreateToggle(MainTab, "No Spread", false, function(s)
    _G.Settings.NoSpread = s
    ApplyAll()
end)

CreateToggle(MainTab, "Quick Reload", false, function(s)
    _G.Settings.QuickReload = s
    ApplyAll()
end)

CreateToggle(MainTab, "No Jam", false, function(s)
    _G.Settings.NoJam = s
    ApplyAll()
end)

CreateButton(MainTab, "✅ Apply Now (Force)", function()
    ApplyAll()
    Notify("✅ Applied", "Semua gun mods diterapkan", 3)
end)

-- ===== TESTER TAB =====
CreateSection(TestTab, "UI Tester")

CreateToggle(TestTab, "Test Toggle", false, function(s)
    print("[TEST TOGGLE]:", s)
    Notify("🔔 Toggle", "State: " .. tostring(s), 2)
end)

CreateSlider(TestTab, "Test Slider", 0, 100, 50, 0, "%", function(v)
    print("[TEST SLIDER]:", v)
end)

CreateButton(TestTab, "🔔 Test Notification", function()
    Notify("🔔 Test", "Notifikasi berhasil muncul!", 4)
end)

CreateButton(TestTab, "🖨️ Print to Console", function()
    print("[TEST] Hello from Custom UI!")
end)

CreateButton(TestTab, "💥 Trigger All Test", function()
    Notify("💥 All Test", "Semua fitur aktif!", 4)
end)

-- ==================== KEYBIND TOGGLE ====================
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == _G.Settings.UIKeybind then
        ScreenGui.Enabled = not ScreenGui.Enabled
    end
end)

-- ==================== NOTIFICATION HOLDER ====================
notifHolder = Instance.new("Frame")
notifHolder.Size = UDim2.new(0, 280, 0, 400)
notifHolder.Position = UDim2.new(0, 20, 0, 20)
notifHolder.BackgroundTransparency = 1
notifHolder.Parent = ScreenGui

local notifList = Instance.new("UIListLayout")
notifList.Padding = UDim.new(0, 10)
notifList.SortOrder = Enum.SortOrder.LayoutOrder
notifList.Parent = notifHolder

-- ==================== INITIAL ====================
CurrentTab = MainTab
MainTab.Button.BackgroundColor3 = Color3.fromRGB(0, 120, 220)
MainTab.Button.TextColor3 = Color3.fromRGB(255, 255, 255)
MainTab.Page.Visible = true

task.wait(0.3)
Notify("✅ Loaded", "Custom UI aktif!\nRightShift untuk toggle UI", 5)
print("[Custom UI] Loaded. Press RightShift to toggle.")