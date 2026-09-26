-- ============================================================
-- DARK HUB | Cali Streets
-- UI : Astra UI Library (referensi: Example.lua.txt)
-- Logic : dipertahankan dari versi sebelumnya
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
-- LOAD ASTRA UI LIBRARY
-- ============================================================
local Library
do
    local ok, result = pcall(function()
        return loadstring(game:HttpGet(
            "https://raw.githubusercontent.com/Ali-lov3/AstraUiLib/refs/heads/main/Source.lua"
        ))()
    end)
    if not ok or not result then
        warn("[DARK HUB] Gagal memuat Astra UI Library.")
        return
    end
    Library = result
end

-- ============================================================
-- THEME (dipakai floating helper GUIs: Auto Farm & Aimbot)
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
    success = Color3.fromRGB(80, 210, 130),
    danger  = Color3.fromRGB(220, 70, 70),
}
local FONT   = Enum.Font.Gotham
local FONT_B = Enum.Font.GothamBold
local FONT_M = Enum.Font.GothamMedium

-- ============================================================
-- UTILITIES (untuk floating GUIs & ESP)
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

-- ============================================================
-- NOTIFY WRAPPER (menggunakan Library.Notify)
-- ============================================================
local function notify(title, desc, duration)
    pcall(function()
        Library.Notify({
            Title    = title or "DARK HUB",
            Text     = desc or "",
            Icon     = "bell",
            Duration = duration or 3,
        })
    end)
end

-- ============================================================
-- GAME STATE (dipertahankan dari versi sebelumnya)
-- ============================================================
_G.InfiniteStaminaEnabled   = false
_G.AutoLoot                 = false
_G.NoJumpCooldownEnabled    = false
_G.ESPEnabled               = false
_G.FPSBoostUsed             = false
_G.NoclipEnabled            = false
_G.WalkSpeedEnabled         = false
_G.WalkSpeedMultiplier      = 1.25
_G.InstantInteractEnabled   = false
_G.InfiniteZoomEnabled      = false
_G.CustomAimbotVisible      = false
_G.CustomAimbotActive       = false
_G.AimbotDraggable          = true

local aimbotFOV        = 120
local autoFarmEnabled  = false
local selectedPlayerObj = nil
local espData          = {}

-- ============================================================
-- HELPERS (dipertahankan)
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
-- AUTO FARM (logic dipertahankan utuh)
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
-- ESP (logic dipertahankan utuh)
-- ============================================================
local function removeESP(player)
    if espData[player] then
        if espData[player].Billboard then espData[player].Billboard:Destroy() end
        if espData[player].Highlight then espData[player].Highlight:Destroy() end
        if espData[player].CharConn  then espData[player].CharConn:Disconnect() end
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
        local hum  = char:WaitForChild("Humanoid", 5)
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
    params.FilterDescendantsInstances = { char, char and char:FindFirstChild("Head") }
    params.IgnoreWater = true
    local r = Workspace:Raycast(origin, targetHead.Position - origin, params)
    if r then return r.Instance:IsDescendantOf(targetHead.Parent) end
    return true
end

-- ============================================================
-- FLOATING GUI : AUTO FARM (dibuat terpisah dari Astra)
-- ============================================================
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

-- ============================================================
-- FLOATING GUI : AIMBOT (dibuat terpisah dari Astra)
-- ============================================================
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
addCorner(fovCircle, 9999)
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

-- ============================================================
-- BUILD ASTRA WINDOW
-- ============================================================
local Window = Library.CreateWindow({
    Title        = "DARK HUB",
    Logo         = 0,
    Anonymous    = false,
    ConfigFolder = "DarkHubConfigs",
})

-- ============================================================
-- TAB : MAIN
-- ============================================================
local MainTab = Window:CreateTab({ Name = "Main", Icon = "home" })
local MainLeft  = MainTab:CreateSection({ Name = "Player Modules", Side = "Left" })
local MainRight = MainTab:CreateSection({ Name = "Movement",       Side = "Right" })

MainLeft:AddLabel("Combat & Survival")

MainLeft:AddToggle({
    Name = "Infinite Stamina",
    Default = false,
    ConfigKey = "infinite_stamina",
    Callback = function(state)
        _G.InfiniteStaminaEnabled = state
    end,
})

MainLeft:AddToggle({
    Name = "Auto Pickup Loot",
    Default = false,
    ConfigKey = "auto_pickup",
    Callback = function(state)
        _G.AutoLoot = state
        if state then
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
    end,
})

MainLeft:AddToggle({
    Name = "Instant Interact",
    Default = false,
    ConfigKey = "instant_interact",
    Callback = function(state)
        _G.InstantInteractEnabled = state
    end,
})

MainRight:AddLabel("Movement & Physics")

MainRight:AddToggle({
    Name = "No Jump Cooldown",
    Default = false,
    ConfigKey = "no_jump_cooldown",
    Callback = function(state)
        _G.NoJumpCooldownEnabled = state
    end,
})

MainRight:AddToggle({
    Name = "Noclip",
    Default = false,
    ConfigKey = "noclip",
    Callback = function(state)
        _G.NoclipEnabled = state
    end,
})

MainRight:AddToggle({
    Name = "Safe Speed Boost",
    Default = false,
    ConfigKey = "safe_speed",
    Callback = function(state)
        _G.WalkSpeedEnabled = state
    end,
})

MainRight:AddSlider({
    Name = "Speed Multiplier",
    Min = 1,
    Max = 3,
    Default = 1.25,
    ConfigKey = "speed_multiplier",
    Callback = function(val)
        _G.WalkSpeedMultiplier = val
    end,
})

-- ============================================================
-- TAB : AUTO FARM
-- ============================================================
local FarmTab = Window:CreateTab({ Name = "Auto Farm", Icon = "leaf" })
local FarmLeft = FarmTab:CreateSection({ Name = "Blank Card Auto Farm", Side = "Left" })
local FarmRight = FarmTab:CreateSection({ Name = "Floating UI Control",  Side = "Right" })

FarmLeft:AddLabel("Jalankan Auto Farm dari tombol di bawah ini.")
FarmLeft:AddButton({
    Name = "Toggle Auto Farm (Start/Stop)",
    Callback = function()
        if not autoFarmEnabled then
            autoFarmEnabled = true
            farmBtn.Text = "Auto Farm: ON"
            farmBtn.TextColor3 = C.success
            task.spawn(autoFarmLoop)
            notify("Auto Farm", "Auto Farm diaktifkan.", 3)
        else
            autoFarmEnabled = false
            farmBtn.Text = "Auto Farm: OFF"
            farmBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
            notify("Auto Farm", "Auto Farm dimatikan.", 3)
        end
    end,
})

FarmRight:AddToggle({
    Name = "Spawn Auto Farm UI",
    Default = false,
    ConfigKey = "spawn_autofarm_ui",
    Callback = function(state)
        autoFarmGui.Enabled = state
        if not state then
            autoFarmEnabled = false
            farmBtn.Text = "Auto Farm: OFF"
            farmBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
    end,
})

FarmRight:AddToggle({
    Name = "Freeze Auto Farm UI",
    Default = false,
    ConfigKey = "freeze_autofarm_ui",
    Callback = function(state)
        autoFarmFrame.Draggable = not state
    end,
})

-- ============================================================
-- TAB : COMBAT
-- ============================================================
local CombatTab = Window:CreateTab({ Name = "Combat", Icon = "crosshair" })
local CombatLeft  = CombatTab:CreateSection({ Name = "Aimbot",           Side = "Left" })
local CombatRight = CombatTab:CreateSection({ Name = "Floating UI Control", Side = "Right" })

CombatLeft:AddToggle({
    Name = "Spawn Aimbot UI",
    Default = false,
    ConfigKey = "spawn_aimbot_ui",
    Callback = function(state)
        _G.CustomAimbotVisible = state
        aimbotGui.Enabled = state
        if not state then
            _G.CustomAimbotActive = false
            aimbotBtn.Text = "AIMBOT: OFF"
            aimbotBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            fovStroke.Color = Color3.fromRGB(0, 170, 255)
        end
    end,
})

CombatLeft:AddSlider({
    Name = "Aimbot Circle Size (FOV)",
    Min = 40,
    Max = 300,
    Default = 120,
    ConfigKey = "aimbot_fov",
    Callback = function(val)
        aimbotFOV = val
        fovCircle.Size = UDim2.new(0, aimbotFOV * 2, 0, aimbotFOV * 2)
    end,
})

CombatRight:AddToggle({
    Name = "Freeze Aimbot UI",
    Default = false,
    ConfigKey = "freeze_aimbot_ui",
    Callback = function(state)
        _G.AimbotDraggable = not state
    end,
})

-- ============================================================
-- TAB : VISUALS
-- ============================================================
local VisualsTab = Window:CreateTab({ Name = "Visuals", Icon = "eye" })
local VisLeft  = VisualsTab:CreateSection({ Name = "Visual Modules", Side = "Left" })
local VisRight = VisualsTab:CreateSection({ Name = "Player Info",    Side = "Right" })

VisLeft:AddToggle({
    Name = "Max Zoom Out",
    Default = false,
    ConfigKey = "max_zoom_out",
    Callback = function(state)
        _G.InfiniteZoomEnabled = state
        if not state then
            LocalPlayer.CameraMaxZoomDistance = 128
        end
    end,
})

VisLeft:AddToggle({
    Name = "Player ESP",
    Default = false,
    ConfigKey = "player_esp",
    Callback = function(state)
        _G.ESPEnabled = state
    end,
})

VisRight:AddSearchDropdown({
    Name = "Select Target Player",
    Player = true,
    Team = false,
    ConfigKey = "target_player",
    Callback = function(name, entryType, object)
        selectedPlayerObj = object
    end,
})

VisRight:AddButton({
    Name = "Inspect Inventory",
    Callback = function()
        if not selectedPlayerObj then
            notify("Inspect", "No player selected.", 3)
            return
        end
        local t = selectedPlayerObj
        if not t or not t.Parent then
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
    end,
})

-- ESP lifecycle (dipertahankan)
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then addESP(p) end
end
Players.PlayerAdded:Connect(function(p)
    if p ~= LocalPlayer then addESP(p) end
end)
Players.PlayerRemoving:Connect(function(p)
    removeESP(p)
end)

-- ============================================================
-- TAB : SOCIALS
-- ============================================================
local SocialsTab = Window:CreateTab({ Name = "Socials", Icon = "link" })
local SocLeft = SocialsTab:CreateSection({ Name = "Social Links", Side = "Left" })

SocLeft:AddButton({
    Name = "Copy Discord Link",
    Callback = function()
        if setclipboard then setclipboard("https://discord.gg/xKvegCV6yf") end
        notify("Discord", "Invite copied to clipboard.", 3)
    end,
})

SocLeft:AddButton({
    Name = "Copy YouTube Link",
    Callback = function()
        if setclipboard then setclipboard("https://youtube.com/@strixwashere") end
        notify("YouTube", "Link copied to clipboard.", 3)
    end,
})

-- ============================================================
-- TAB : SETTINGS
-- ============================================================
local SettingsTab = Window:CreateTab({ Name = "Settings", Icon = "settings" })
local SetLeft  = SettingsTab:CreateSection({ Name = "General",  Side = "Left" })
local SetRight = SettingsTab:CreateSection({ Name = "Config",   Side = "Right" })

SetLeft:AddButton({
    Name = "FPS Booster (Potato Graphics)",
    Callback = function()
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
                if o:IsA("PostEffect") or o:IsA("Atmosphere") or o:IsA("Sky")
                   or o:IsA("Clouds") or o:IsA("BlurEffect") then
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
    end,
})

SetLeft:AddButton({
    Name = "Unload Script",
    Callback = function()
        autoFarmEnabled = false
        _G.ESPEnabled = false
        for p, _ in pairs(espData) do removeESP(p) end
        pcall(function() autoFarmGui:Destroy() end)
        pcall(function() aimbotGui:Destroy() end)
        pcall(function()
            if Window and Window.Destroy then Window:Destroy() end
        end)
        notify("DARK HUB", "Script unloaded.", 3)
    end,
})

SetRight:ApplyConfigManager({})

-- ============================================================
-- GAME LOOPS (logic dipertahankan utuh)
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
    local rp  = char:FindFirstChild("HumanoidRootPart")
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