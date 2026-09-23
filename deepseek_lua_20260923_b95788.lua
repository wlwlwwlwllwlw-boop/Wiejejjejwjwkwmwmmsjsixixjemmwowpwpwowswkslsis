-- ================================================================
-- 🚀 UNIFIED FULL CYCLE v1.1 (FIXED — NO GOTO, UI SAFE)
-- Boot: Buy Apt → Dealer → Motor
-- Loop: Bahan → Water → FakeID → Apply → Chips → Sugar/Gelatin
--       → Collect MS → Sell MS → Claim Card → Swipe ATM
--       → Claim Chips → Panasin → Sell Homeless → Repeat
-- ================================================================
if not game:IsLoaded() then game.Loaded:Wait() end

local Players    = game:GetService("Players")
local Workspace  = game:GetService("Workspace")
local RS         = game:GetService("ReplicatedStorage")
local CoreGui    = game:GetService("CoreGui")
local UIS        = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VIM        = game:GetService("VirtualInputManager")
local Tween      = game:GetService("TweenService")
local PPS        = game:GetService("ProximityPromptService")
local VirtualUser= game:GetService("VirtualUser")

while not Players.LocalPlayer do task.wait(0.1) end
local LP = Players.LocalPlayer

pcall(function() LP.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Invisicam end)

-- ================================================================
-- STATE
-- ================================================================
local ST = {
    running       = false,
    cycle         = 0,
    pot           = 5,
    homelessIdx   = 1,
    aptOwned      = false,
    kitchenPos    = nil,
    doorPos       = nil,
    targetMS      = 5,
    targetChips   = 5,
    counter       = { ms = 0, card = 0, hot = 0 },
    startTime     = 0,
}
local originalGravity = Workspace.Gravity

-- ================================================================
-- KOORDINAT
-- ================================================================
local MS_SHOP    = Vector3.new(510.50, 4.5, 598.28)
local DEALER_POS = Vector3.new(730.24, 3.70, 449.47)

local AptData = {
    { ID=7,  Buy=Vector3.new(1197.11, 3.71, -237.50), Door=Vector3.new(1199.14, 3.71, -243.04), Kitchen=Vector3.new(1202.15, -2.29, -220.04) },
    { ID=8,  Buy=Vector3.new(1196.79, 3.71, -201.87), Door=Vector3.new(1199.00, 3.71, -207.04), Kitchen=Vector3.new(1202.14, -2.29, -180.56) },
    { ID=9,  Buy=Vector3.new(1185.65, 3.71, -207.83), Door=Vector3.new(1183.52, 3.71, -202.90), Kitchen=Vector3.new(1180.38, -2.29, -188.99) },
    { ID=10, Buy=Vector3.new(1185.42, 3.71, -243.37), Door=Vector3.new(1183.58, 3.71, -238.20), Kitchen=Vector3.new(1180.41, -2.29, -227.24) },
}

local LOC_FakeID        = Vector3.new( 214.960, 1.857, -332.330)
local LOC_ApplyForCard  = Vector3.new( -49.210, 4.000, -310.810)
local CARD_FALLBACK_POS = Vector3.new( -39.090, 5.392, -329.700)

local CHIPS_BUY = Vector3.new(-759.197, 3.489, -194.846)
local CHIPS_A = Vector3.new(-478.83, 3.86, -438.92)
local CHIPS_B = Vector3.new(-461.69, 3.86, -461.25)
local CHIPS_C = Vector3.new(-461.69, 3.86, -472.88)
local CHIPS_D = Vector3.new(-462.75, 3.86, -521.94)
local CHIPS_POTS = {
    Vector3.new(-515.28, 3.86, -451.71), Vector3.new(-515.24, 3.86, -462.26),
    Vector3.new(-515.28, 3.86, -471.89), Vector3.new(-515.28, 3.86, -481.75),
    Vector3.new(-515.24, 3.86, -492.10), Vector3.new(-496.99, 3.86, -452.21),
    Vector3.new(-496.95, 3.86, -462.02), Vector3.new(-496.98, 3.86, -471.73),
    Vector3.new(-496.99, 3.86, -481.82), Vector3.new(-497.04, 3.86, -491.37),
}
local SC_HOMELESS = {
    Vector3.new(-315.35, 3.72,  -361.56), Vector3.new(-273.52, 3.85,  -211.32),
    Vector3.new(1102.42, 3.36,  527.05),  Vector3.new(52.89,   3.72,  -425.36),
    Vector3.new(152.88,  3.73,  -210.08), Vector3.new(-522.75, -7.86, -165.08),
    Vector3.new(65.12,   3.73,  68.10),   Vector3.new(26.04,   3.73,  217.89),
    Vector3.new(520.08,  3.87,  -295.52), Vector3.new(699.28,  3.72,  -427.05),
    Vector3.new(900.03,  3.94,  -283.12), Vector3.new(874.89,  3.73,  -63.02),
}
local SC_TUKAR = Vector3.new(-34.91, 4.56, -24.15)

-- ================================================================
-- REMOTE
-- ================================================================
local RE
pcall(function()
    RE = RS:WaitForChild("RemoteEvents", 5):WaitForChild("ReliableRemoteEvent", 5)
end)

-- ================================================================
-- ANTI-AFK
-- ================================================================
task.spawn(function()
    LP.Idled:Connect(function()
        VirtualUser:Button2Down(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
    end)
end)

-- ================================================================
-- GHOST MODE
-- ================================================================
local ghostConn, modifiedParts = nil, {}
local function startGhost()
    if ghostConn then return end
    ghostConn = RunService.Heartbeat:Connect(function()
        local char = LP.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum and hum.Sit then return end
        local hrp = char.HumanoidRootPart
        local function proc(p)
            if not p or not p:IsA("BasePart") or p:IsA("Terrain") then return end
            if p:IsDescendantOf(char) then return end
            if p:IsA("Seat") or p:IsA("VehicleSeat") or p.Name:lower():find("seat") then return end
            if not modifiedParts[p] then
                modifiedParts[p] = { p.CanCollide, p.CanTouch }
            end
            p.CanCollide = false; p.CanTouch = false
        end
        for _, p in ipairs(hrp:GetTouchingParts()) do proc(p) end
    end)
end
local function stopGhost()
    if ghostConn then ghostConn:Disconnect(); ghostConn = nil end
    for p, s in pairs(modifiedParts) do
        if p and p.Parent then p.CanCollide = s[1]; p.CanTouch = s[2] end
    end
    modifiedParts = {}
end

-- ================================================================
-- PROMPT GLOBAL INSTANT
-- ================================================================
local function instant(p)
    if p:IsA("ProximityPrompt") then
        p.HoldDuration = 0
        p.RequiresLineOfSight = false
        p.MaxActivationDistance = 9e9
    end
end
for _, o in ipairs(Workspace:GetDescendants()) do instant(o) end
Workspace.DescendantAdded:Connect(instant)
PPS.PromptShown:Connect(instant)

local function firePrompt(pos, maxDist, keyword)
    maxDist = maxDist or 30
    for _, o in ipairs(Workspace:GetDescendants()) do
        if o:IsA("ProximityPrompt") and o.Enabled then
            local par = o.Parent
            local pp
            if par:IsA("BasePart") then pp = par.Position
            elseif par:IsA("Attachment") then pp = par.WorldPosition
            elseif par:IsA("Model") or par:IsA("Folder") then
                local rp = par.PrimaryPart or par:FindFirstChildOfClass("BasePart")
                if rp then pp = rp.Position end
            end
            if pp and (pos - pp).Magnitude <= maxDist then
                local at = string.lower(o.ActionText or "")
                if not keyword or at:find(string.lower(keyword)) then
                    o.RequiresLineOfSight = false
                    o.HoldDuration = 0
                    o.MaxActivationDistance = 9e9
                    if fireproximityprompt then
                        pcall(function() fireproximityprompt(o, 0) end)
                    else
                        o:InputHoldBegin(); task.wait(0.05); o:InputHoldEnd()
                    end
                    return true
                end
            end
        end
    end
    return false
end

-- ================================================================
-- VEHICLE TP
-- ================================================================
local vehBusy = false
local MAX_SPEED, HOP_DIST = 150, 25
local MIN_DELAY, MAX_DELAY = 0.04, 0.5

local function doVehicleTP(targetPos)
    if vehBusy then return false, "Busy" end
    local char = LP.Character
    if not char then return false, "No char" end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false, "Dead" end
    local seat = hum.SeatPart
    if not seat then return false, "Not on vehicle" end
    local veh = seat:FindFirstAncestorOfClass("Model")
    if not veh then return false, "No vehicle" end
    local vRoot = veh.PrimaryPart or seat
    if not vRoot then return false, "No vRoot" end

    vehBusy = true
    local startPos = vRoot.Position
    local targetPosV = Vector3.new(targetPos.X, targetPos.Y + 3, targetPos.Z)
    local rot = vRoot.CFrame.Rotation
    local dist = (targetPosV - startPos).Magnitude
    local hopCount = math.max(1, math.ceil(dist / HOP_DIST))
    local hopDelay = math.clamp(HOP_DIST / MAX_SPEED, MIN_DELAY, MAX_DELAY)

    for i = 1, hopCount do
        if not ST.running then vehBusy = false; return false, "Cancelled" end
        local stepPos = startPos:Lerp(targetPosV, i / hopCount)
        pcall(function() veh:PivotTo(CFrame.new(stepPos) * rot) end)
        task.wait(hopDelay)
    end
    pcall(function() veh:PivotTo(CFrame.new(targetPosV) * rot) end)
    task.wait(0.1)
    vehBusy = false
    return true, "OK"
end

-- ================================================================
-- BLINK TP (UNDERGROUND)
-- ================================================================
local function blinkTP(targetPos)
    local char = LP.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    local hum = char:FindFirstChildOfClass("Humanoid")

    startGhost()
    if hum then hum.PlatformStand = true end
    Workspace.Gravity = 0

    local underY = -4
    local steps = {
        Vector3.new(hrp.Position.X, underY, hrp.Position.Z),
        Vector3.new(targetPos.X, underY, targetPos.Z),
        targetPos,
    }
    for _, dest in ipairs(steps) do
        local guard = 0
        while ST.running and (hrp.Position - dest).Magnitude > 1.2 and guard < 400 do
            hrp.CFrame = CFrame.new(hrp.Position + ((dest - hrp.Position).Unit * 1.0))
            hrp.AssemblyLinearVelocity = Vector3.zero
            guard = guard + 1
            task.wait(0.03)
        end
        pcall(function() hrp.CFrame = CFrame.new(dest) end)
    end

    Workspace.Gravity = originalGravity
    if hum then hum.PlatformStand = false end
    stopGhost()
end

-- BypassTP anti-freeze
local function BypassTP(targetPos)
    local char = LP.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        for _, p in pairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
        local bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Velocity = Vector3.new(0, 9e9, 0)
        bv.Parent = char.HumanoidRootPart
    end
    -- Tunggu respawn dengan timeout
    local t0 = os.clock()
    while LP.Character == char and os.clock() - t0 < 10 do
        task.wait(0.1)
    end
    local newChar = LP.Character or LP.CharacterAdded:Wait()
    local newHrp = newChar:WaitForChild("HumanoidRootPart", 10)
    if newHrp then
        task.wait(0.5)
        newHrp.CFrame = CFrame.new(targetPos)
    end
    task.wait(1.2)
end

-- ================================================================
-- INVENTORY HELPERS
-- ================================================================
local function countTool(nameOrList)
    local c = 0
    local function check(cont)
        if not cont then return end
        for _, v in ipairs(cont:GetChildren()) do
            if v:IsA("Tool") then
                if type(nameOrList) == "table" then
                    for _, n in ipairs(nameOrList) do
                        if v.Name == n then c = c + 1 end
                    end
                elseif v.Name == nameOrList then
                    c = c + 1
                end
            end
        end
    end
    check(LP.Character)
    check(LP:FindFirstChild("Backpack"))
    return c
end

local function countFuzzy(keyword1, keyword2)
    local c = 0
    local function check(cont)
        if not cont then return end
        for _, v in ipairs(cont:GetChildren()) do
            if v:IsA("Tool") then
                local n = v.Name:lower()
                if n:find(keyword1) and (not keyword2 or n:find(keyword2)) then
                    c = c + 1
                end
            end
        end
    end
    check(LP.Character)
    check(LP:FindFirstChild("Backpack"))
    return c
end

local function equipTool(name)
    local char = LP.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return false end
    if char:FindFirstChild(name) then return true end
    hum:UnequipTools()
    task.wait(0.15)
    local bp = LP:FindFirstChild("Backpack")
    if not bp then return false end
    local t = bp:FindFirstChild(name)
    if not t then
        for _, v in pairs(bp:GetChildren()) do
            if v:IsA("Tool") and v.Name:lower():find(name:lower()) then
                t = v; break
            end
        end
    end
    if t then
        hum:EquipTool(t)
        local t0 = os.clock()
        while os.clock() - t0 < 1.5 do
            if char:FindFirstChild(t.Name) then task.wait(0.12); return true end
            task.wait(0.05)
        end
        return true
    end
    return false
end

local function unequipAll()
    local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if hum then pcall(function() hum:UnequipTools() end) end
end

-- ================================================================
-- BUY HELPERS
-- ================================================================
local function fireBuyIndex(index)
    if not RE then return false end
    return pcall(function()
        local buf = buffer.create(3)
        buffer.writeu8(buf, 0, 24)
        buffer.writeu8(buf, 1, 21)
        buffer.writeu8(buf, 2, index)
        RE:FireServer(buf)
    end)
end

local function fireBuyIngredient(index)
    if not RE then return false end
    return pcall(function()
        local buf = buffer.create(3)
        buffer.writeu8(buf, 0, 24)
        buffer.writeu8(buf, 1, 19)
        buffer.writeu8(buf, 2, index)
        RE:FireServer(buf)
    end)
end

local function buyUntilEnough(buyFn, countFn, target, maxAttempts)
    maxAttempts = maxAttempts or 40
    if countFn() >= target then return true end
    local attempt = 0
    while ST.running and attempt < maxAttempts do
        attempt = attempt + 1
        buyFn()
        local deadline = os.clock() + 2.5
        repeat task.wait(0.1) until countFn() >= target or os.clock() > deadline
        if countFn() >= target then return true end
        task.wait(0.2)
    end
    return countFn() >= target
end

-- ================================================================
-- UI (SAFE WRAP)
-- ================================================================
local UI_Target
pcall(function()
    UI_Target = (gethui and gethui()) or CoreGui or LP:WaitForChild("PlayerGui")
end)
if not UI_Target then UI_Target = LP:WaitForChild("PlayerGui") end

for _, nm in ipairs({"UnifiedFullCycle_UI","LuzorHub","LENGER_CardScam_UI","AutoFullCycle_UI"}) do
    local old = UI_Target:FindFirstChild(nm)
    if old then pcall(function() old:Destroy() end) end
end

local Gui = Instance.new("ScreenGui")
Gui.Name = "UnifiedFullCycle_UI"
Gui.ResetOnSpawn = false
Gui.DisplayOrder = 99999
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() Gui.Parent = UI_Target end)

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 280, 0, 470)
Main.Position = UDim2.new(0.05, 0, 0.12, 0)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = Gui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)
local ms = Instance.new("UIStroke", Main)
ms.Color = Color3.fromRGB(120, 100, 220); ms.Thickness = 1.5

local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 36)
Header.BackgroundColor3 = Color3.fromRGB(18, 16, 30)
Header.BorderSizePixel = 0
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🔥 UNIFIED FULL CYCLE v1.1"
Title.TextColor3 = Color3.fromRGB(180, 160, 255)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 12
Title.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0, 22, 0, 22)
CloseBtn.Position = UDim2.new(1, -26, 0.5, -11)
CloseBtn.BackgroundColor3 = Color3.fromRGB(50, 15, 15)
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(220, 80, 80)
CloseBtn.Font = Enum.Font.GothamBlack
CloseBtn.TextSize = 15
CloseBtn.AutoButtonColor = false
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 5)

local Content = Instance.new("Frame", Main)
Content.Size = UDim2.new(1, -20, 1, -46)
Content.Position = UDim2.new(0, 10, 0, 42)
Content.BackgroundTransparency = 1
local Lay = Instance.new("UIListLayout", Content)
Lay.Padding = UDim.new(0, 7)
Lay.SortOrder = Enum.SortOrder.LayoutOrder

local ToggleBtn = Instance.new("TextButton", Content)
ToggleBtn.Size = UDim2.new(1, 0, 0, 40)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 15, 15)
ToggleBtn.Text = "▶ START FULL CYCLE"
ToggleBtn.TextColor3 = Color3.fromRGB(220, 80, 80)
ToggleBtn.Font = Enum.Font.GothamBlack
ToggleBtn.TextSize = 13
ToggleBtn.AutoButtonColor = false
ToggleBtn.LayoutOrder = 1
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 8)
local tS = Instance.new("UIStroke", ToggleBtn)
tS.Color = Color3.fromRGB(80, 25, 25)

local function makeSlider(labelText, defaultVal, min, max, layoutOrder, onChange)
    local sf = Instance.new("Frame", Content)
    sf.Size = UDim2.new(1, 0, 0, 46)
    sf.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
    sf.LayoutOrder = layoutOrder
    Instance.new("UICorner", sf).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", sf).Color = Color3.fromRGB(40, 40, 55)

    local lbl = Instance.new("TextLabel", sf)
    lbl.Size = UDim2.new(1, -16, 0, 16)
    lbl.Position = UDim2.new(0, 10, 0, 4)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText .. defaultVal
    lbl.TextColor3 = Color3.fromRGB(210, 210, 220)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local tr = Instance.new("Frame", sf)
    tr.Size = UDim2.new(1, -20, 0, 6)
    tr.Position = UDim2.new(0, 10, 0, 30)
    tr.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    tr.BorderSizePixel = 0
    Instance.new("UICorner", tr).CornerRadius = UDim.new(1, 0)

    local fl = Instance.new("Frame", tr)
    fl.Size = UDim2.new((defaultVal-min)/(max-min), 0, 1, 0)
    fl.BackgroundColor3 = Color3.fromRGB(150, 120, 255)
    fl.BorderSizePixel = 0
    Instance.new("UICorner", fl).CornerRadius = UDim.new(1, 0)

    local hd = Instance.new("TextButton", tr)
    hd.Size = UDim2.new(0, 16, 0, 16)
    hd.Position = UDim2.new((defaultVal-min)/(max-min), -8, 0.5, -8)
    hd.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    hd.Text = ""
    hd.AutoButtonColor = false
    Instance.new("UICorner", hd).CornerRadius = UDim.new(1, 0)

    local dragging = false
    local function upd(x)
        local rel = math.clamp((x - tr.AbsolutePosition.X) / tr.AbsoluteSize.X, 0, 1)
        local v = math.floor(min + (max - min) * rel + 0.5)
        fl.Size = UDim2.new(rel, 0, 1, 0)
        hd.Position = UDim2.new(rel, -8, 0.5, -8)
        lbl.Text = labelText .. v
        onChange(v)
    end
    hd.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true end
    end)
    tr.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then upd(i.Position.X) end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            upd(i.Position.X)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
end

makeSlider("Target Marshmallow: ", ST.targetMS, 1, 20, 2, function(v) ST.targetMS = v end)
makeSlider("Target Chips (Pot): ", ST.targetChips, 1, 30, 3, function(v) ST.targetChips = v end)

local PotLbl = Instance.new("TextLabel", Content)
PotLbl.Size = UDim2.new(1, 0, 0, 14)
PotLbl.BackgroundTransparency = 1
PotLbl.Text = "Pilih Pot Chips:"
PotLbl.TextColor3 = Color3.fromRGB(200, 200, 210)
PotLbl.Font = Enum.Font.GothamBold
PotLbl.TextSize = 11
PotLbl.TextXAlignment = Enum.TextXAlignment.Left
PotLbl.LayoutOrder = 4

local PotGrid = Instance.new("Frame", Content)
PotGrid.Size = UDim2.new(1, 0, 0, 66)
PotGrid.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
PotGrid.LayoutOrder = 5
Instance.new("UICorner", PotGrid).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", PotGrid).Color = Color3.fromRGB(40, 40, 55)

local potBtns = {}
local function refreshPots()
    for i, b in ipairs(potBtns) do
        local sel = ST.pot == i
        b.BackgroundColor3 = sel and Color3.fromRGB(40, 30, 90) or Color3.fromRGB(22, 22, 28)
        local s = b:FindFirstChildOfClass("UIStroke")
        if s then s.Color = sel and Color3.fromRGB(150, 120, 255) or Color3.fromRGB(50, 50, 60) end
        local l = b:FindFirstChildOfClass("TextLabel")
        if l then l.TextColor3 = sel and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(140, 140, 150) end
    end
end
for i = 1, 10 do
    local col = (i-1) % 5
    local row = math.floor((i-1)/5)
    local pw = 1/5
    local b = Instance.new("TextButton", PotGrid)
    b.Size = UDim2.new(pw - 0.02, 0, 0, 24)
    b.Position = UDim2.new(col*pw + 0.01, 0, 0, 8 + row*30)
    b.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
    b.Text = ""
    b.AutoButtonColor = false
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    local bs = Instance.new("UIStroke", b); bs.Color = Color3.fromRGB(50, 50, 60)
    local bl = Instance.new("TextLabel", b)
    bl.Size = UDim2.new(1, 0, 1, 0); bl.BackgroundTransparency = 1
    bl.Text = tostring(i)
    bl.TextColor3 = Color3.fromRGB(140, 140, 150)
    bl.Font = Enum.Font.GothamBlack; bl.TextSize = 12
    table.insert(potBtns, b)
    local cap = i
    b.MouseButton1Click:Connect(function()
        if ST.running then return end
        ST.pot = cap
        refreshPots()
    end)
end
refreshPots()

local InfoCard = Instance.new("Frame", Content)
InfoCard.Size = UDim2.new(1, 0, 0, 70)
InfoCard.BackgroundColor3 = Color3.fromRGB(14, 20, 26)
InfoCard.LayoutOrder = 6
Instance.new("UICorner", InfoCard).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", InfoCard).Color = Color3.fromRGB(40, 80, 110)

local StatusLbl = Instance.new("TextLabel", InfoCard)
StatusLbl.Size = UDim2.new(1, -12, 0, 18)
StatusLbl.Position = UDim2.new(0, 6, 0, 4)
StatusLbl.BackgroundTransparency = 1
StatusLbl.Text = "Status: Idle"
StatusLbl.TextColor3 = Color3.fromRGB(140, 220, 180)
StatusLbl.Font = Enum.Font.GothamBold
StatusLbl.TextSize = 11
StatusLbl.TextXAlignment = Enum.TextXAlignment.Left

local CycleLbl = Instance.new("TextLabel", InfoCard)
CycleLbl.Size = UDim2.new(1, -12, 0, 16)
CycleLbl.Position = UDim2.new(0, 6, 0, 24)
CycleLbl.BackgroundTransparency = 1
CycleLbl.Text = "Cycle: -"
CycleLbl.TextColor3 = Color3.fromRGB(180, 180, 200)
CycleLbl.Font = Enum.Font.GothamMedium
CycleLbl.TextSize = 10
CycleLbl.TextXAlignment = Enum.TextXAlignment.Left

local CounterLbl = Instance.new("TextLabel", InfoCard)
CounterLbl.Size = UDim2.new(1, -12, 0, 16)
CounterLbl.Position = UDim2.new(0, 6, 0, 42)
CounterLbl.BackgroundTransparency = 1
CounterLbl.Text = "MS: 0 · Card: 0 · Hot: 0"
CounterLbl.TextColor3 = Color3.fromRGB(255, 200, 100)
CounterLbl.Font = Enum.Font.GothamBold
CounterLbl.TextSize = 10
CounterLbl.TextXAlignment = Enum.TextXAlignment.Left

function updateStatus(t, c)
    StatusLbl.Text = "Status: " .. t
    if c then StatusLbl.TextColor3 = c end
end
function updateCycle(t) CycleLbl.Text = t end
function updateCounters()
    CounterLbl.Text = string.format("MS: %d · Card: %d · Hot: %d",
        ST.counter.ms, ST.counter.card, ST.counter.hot)
end

local function refreshToggle()
    if ST.running then
        ToggleBtn.Text = "■ STOP FULL CYCLE"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(20, 50, 30)
        ToggleBtn.TextColor3 = Color3.fromRGB(100, 255, 180)
        tS.Color = Color3.fromRGB(30, 120, 70)
    else
        ToggleBtn.Text = "▶ START FULL CYCLE"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 15, 15)
        ToggleBtn.TextColor3 = Color3.fromRGB(220, 80, 80)
        tS.Color = Color3.fromRGB(80, 25, 25)
    end
end
refreshToggle()

-- ================================================================
-- BOOT PHASE
-- ================================================================
local function setupApartment()
    updateStatus("BOOT · Cari VACANT apartment...")
    local target = nil
    for _, d in ipairs(AptData) do
        if not ST.running then return false end
        local vacant = false
        for _, o in ipairs(Workspace:GetDescendants()) do
            if o:IsA("TextLabel") and string.find(string.upper(o.Text), "VACANT") then
                local g = o:FindFirstAncestorOfClass("SurfaceGui") or o:FindFirstAncestorOfClass("BillboardGui")
                local part = g and (g.Adornee or g.Parent)
                if part and part:IsA("BasePart") and (part.Position - d.Buy).Magnitude <= 5 then
                    vacant = true; break
                end
            end
        end
        if vacant then target = d; break end
    end
    if not target then updateStatus("Tidak ada VACANT apartment", Color3.fromRGB(255,80,80)); return false end

    updateStatus(("BOOT · Beli Apartment #%d..."):format(target.ID))
    BypassTP(target.Buy)
    if not ST.running then return false end

    firePrompt(target.Buy, 6, "purchase")
    task.wait(1.2)

    ST.kitchenPos = target.Kitchen
    ST.doorPos = target.Door
    ST.aptOwned = true

    updateStatus("BOOT · Lock door apartment...")
    blinkTP(target.Door)
    if not ST.running then return false end
    task.wait(0.6)
    for _ = 1, 6 do
        if not ST.running then break end
        if firePrompt(target.Door, 8, "unlock") then break end
        firePrompt(target.Door, 8, "lock")
        task.wait(0.5)
        firePrompt(target.Door, 8, "open")
        task.wait(0.5)
    end
    return true
end

local function goToDealerAndWaitMotor()
    updateStatus("BOOT · Blink ke Dealer (underground)...")
    blinkTP(DEALER_POS)
    if not ST.running then return false end
    task.wait(1)

    updateStatus("BOOT · Tunggu naik motor...", Color3.fromRGB(255, 200, 80))
    local t0 = os.clock()
    while ST.running and (os.clock() - t0) < 90 do
        local char = LP.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum and hum.SeatPart then
            updateStatus("Motor siap ✔", Color3.fromRGB(0, 220, 100))
            task.wait(0.5)
            return true
        end
        task.wait(0.4)
    end
    updateStatus("Gagal dapat motor", Color3.fromRGB(255, 80, 80))
    return false
end

-- ================================================================
-- ROUTINE STEPS
-- ================================================================
local function step_buyMarshmallowIngredients()
    updateStatus("STEP 3 · Beli Gelatin/Sugar/Water...")
    local ok = doVehicleTP(MS_SHOP)
    if not ok then return false end
    task.wait(0.4)

    local target = ST.targetMS
    local attempt = 0
    while ST.running and attempt < 80 do
        attempt = attempt + 1
        local g = countTool("Gelatin")
        local s = countTool("Sugar Block Bag")
        local w = countTool({"Water", "Water23"})
        if g >= target and s >= target and w >= target then return true end
        if g < target then fireBuyIngredient(1); task.wait(0.35) end
        if s < target then fireBuyIngredient(2); task.wait(0.35) end
        if w < target then fireBuyIngredient(3); task.wait(0.35) end
        task.wait(0.2)
    end
    return true
end

local function step_putWater()
    updateStatus("STEP 4 · Tuang Water...")
    local ok = doVehicleTP(ST.kitchenPos)
    if not ok then return false end
    task.wait(0.3)

    local before = countTool({"Water", "Water23"})
    local tries = 0
    while ST.running and countTool({"Water", "Water23"}) >= before and tries < 40 do
        tries = tries + 1
        equipTool("Water")
        task.wait(0.15)
        if not LP.Character:FindFirstChild("Water") then
            equipTool("Water23")
            task.wait(0.15)
        end
        firePrompt(ST.kitchenPos, 12)
        task.wait(1)
    end
    return countTool({"Water", "Water23"}) < before
end

local function findFakeIDSellerPrompt()
    local f = Workspace:FindFirstChild("Folders")
    local n = f and f:FindFirstChild("NPCs")
    local s = n and n:FindFirstChild("FakeIDSeller")
    if not s then return nil end
    for _, d in ipairs(s:GetDescendants()) do
        if d:IsA("ProximityPrompt") then return d end
    end
    return nil
end

local function step_buyFakeID()
    if countFuzzy("fake", "id") > 0 then return true end
    updateStatus("STEP 5 · Beli Fake ID...")

    local ok = doVehicleTP(LOC_FakeID)
    if not ok then return false end
    task.wait(0.4)

    local prompt = findFakeIDSellerPrompt()
    if not prompt then
        for _ = 1, 12 do
            if not ST.running then return false end
            firePrompt(LOC_FakeID, 15)
            task.wait(0.5)
            if countFuzzy("fake", "id") > 0 then return true end
        end
        return false
    end

    pcall(function()
        prompt.HoldDuration = 0
        prompt.RequiresLineOfSight = false
        prompt.MaxActivationDistance = 9e9
    end)

    for _ = 1, 12 do
        if not ST.running then return false end
        pcall(function() fireproximityprompt(prompt) end)
        task.wait(0.5)
        if countFuzzy("fake", "id") > 0 then return true end
    end
    return false
end

local function findBankTellerPrompt()
    local f = Workspace:FindFirstChild("Folders")
    local n = f and f:FindFirstChild("NPCs")
    local t = n and n:FindFirstChild("Bank Teller")
    if not t then return nil end
    local u = t:FindFirstChild("UpperTorso")
    local a = u and u:FindFirstChild("Attachment")
    return a and a:FindFirstChild("ProximityPrompt")
end

local function checkApprovalNotif()
    local mg = LP.PlayerGui:FindFirstChild("Main")
    local n = mg and mg:FindFirstChild("BasicNotification")
    if not n or n.TextTransparency > 0 then return nil end
    local l = n.Text:lower()
    if l:find("not success") or l:find("denied") or l:find("reject") or l:find("failed") then
        return false, n.Text
    end
    if l:find("success") or l:find("approved") or l:find("accepted") then
        return true, n.Text
    end
    return nil
end

local function step_applyCard()
    updateStatus("STEP 6 · Apply Card di Bank...")
    if countFuzzy("fake", "id") == 0 then return false end

    local ok = doVehicleTP(LOC_ApplyForCard)
    if not ok then return false end
    task.wait(0.5)

    local char = LP.Character
    local bp = LP:FindFirstChild("Backpack")
    local fid
    for _, v in ipairs((bp and bp:GetChildren()) or {}) do
        if v:IsA("Tool") and v.Name:lower():find("fake") then fid = v; break end
    end
    if fid then equipTool(fid.Name) end
    task.wait(0.3)

    local prompt = findBankTellerPrompt()
    if not prompt then return false end
    pcall(function()
        prompt.HoldDuration = 0
        prompt.RequiresLineOfSight = false
        prompt.MaxActivationDistance = 9e9
    end)

    local tries = 0
    while ST.running and countFuzzy("fake", "id") > 0 and tries < 25 do
        tries = tries + 1
        pcall(function() fireproximityprompt(prompt) end)
        task.wait(0.5)
    end
    unequipAll()

    if countFuzzy("fake", "id") > 0 then return false end

    updateStatus("STEP 6 · Tunggu approval...", Color3.fromRGB(255, 200, 80))
    local t0 = os.clock()
    while ST.running and (os.clock() - t0) < 60 do
        local result = checkApprovalNotif()
        if result == true then
            updateStatus("Card Approved ✔", Color3.fromRGB(0, 220, 100))
            task.wait(1.5)
            return true
        elseif result == false then
            updateStatus("Card DITOLAK", Color3.fromRGB(255, 80, 80))
            return false
        end
        task.wait(0.4)
    end
    return true
end

local function step_buyChipsIngredients()
    updateStatus("STEP 7 · Beli Potato + Flour...")
    local ok = doVehicleTP(CHIPS_BUY)
    if not ok then return false end
    task.wait(0.4)

    buyUntilEnough(function() fireBuyIndex(2) end, function() return countTool("Potato") end, 1, 30)
    if not ST.running then return false end
    buyUntilEnough(function() fireBuyIndex(1) end, function() return countTool("Flour") end, 1, 30)
    return true
end

local function step_chipsMission()
    updateStatus("STEP 8 · Chips mission (A→B→C→D)...")

    if not doVehicleTP(CHIPS_A) then return false end
    task.wait(0.5); firePrompt(CHIPS_A, 8); task.wait(0.7)

    if not doVehicleTP(CHIPS_B) then return false end
    task.wait(0.5)
    equipTool("Potato"); task.wait(0.4)
    firePrompt(CHIPS_B, 8); task.wait(4)

    if not doVehicleTP(CHIPS_C) then return false end
    task.wait(0.5); firePrompt(CHIPS_C, 8); task.wait(3)

    if not doVehicleTP(CHIPS_D) then return false end
    task.wait(0.5)
    equipTool("Flour"); task.wait(0.4)
    firePrompt(CHIPS_D, 8); task.wait(4)

    local pot = CHIPS_POTS[ST.pot]
    if not doVehicleTP(pot) then return false end
    task.wait(0.5)
    firePrompt(pot, 8)
    task.wait(1.5)
    updateStatus("STEP 8 · Cook 60s berjalan di background...", Color3.fromRGB(255, 160, 60))
    return true
end

local function step_sugarGelatin()
    updateStatus("STEP 9 · Cook Sugar + Gelatin...")
    local ok = doVehicleTP(ST.kitchenPos)
    if not ok then return false end
    task.wait(0.3)

    local beforeS = countTool("Sugar Block Bag")
    local ts = 0
    while ST.running and countTool("Sugar Block Bag") >= beforeS and ts < 40 do
        ts = ts + 1
        equipTool("Sugar Block Bag"); task.wait(0.15)
        firePrompt(ST.kitchenPos, 12); task.wait(1)
    end

    local beforeG = countTool("Gelatin")
    local tg = 0
    while ST.running and countTool("Gelatin") >= beforeG and tg < 40 do
        tg = tg + 1
        equipTool("Gelatin"); task.wait(0.15)
        firePrompt(ST.kitchenPos, 12); task.wait(1)
    end

    for i = 47, 1, -1 do
        if not ST.running then return false end
        if i % 5 == 0 then
            updateStatus(("STEP 9 · Tunggu %ds..."):format(i), Color3.fromRGB(255, 160, 60))
        end
        task.wait(1)
    end
    return true
end

local mBags = {
    "Marshmallow","Marshmellow","Large Marshmallow Bag","Large Marshmellow Bag",
    "Medium Marshmallow Bag","Medium Marshmellow Bag","Small Marshmallow Bag","Small Marshmellow Bag"
}

local function step_collectMS()
    updateStatus("STEP 9b · Collect Marshmallow...")
    local before = countTool(mBags)
    local tries = 0
    while ST.running and countTool(mBags) <= before and tries < 200 do
        tries = tries + 1
        equipTool("Empty Bag")
        firePrompt(ST.kitchenPos, 12)
        task.wait(0.3)
    end
    return countTool(mBags) > before
end

local function step_sellMS()
    updateStatus("STEP 10 · Jual Marshmallow...")
    local ok = doVehicleTP(MS_SHOP)
    if not ok then return false end
    task.wait(0.4)

    local totalSold = 0
    for _, name in ipairs(mBags) do
        while ST.running and countTool(name) > 0 do
            equipTool(name)
            task.wait(0.25)
            if LP.Character and LP.Character:FindFirstChild(name) then
                firePrompt(MS_SHOP, 12)
                task.wait(0.4)
                totalSold = totalSold + 1
            else
                task.wait(0.2)
            end
        end
    end
    ST.counter.ms = ST.counter.ms + totalSold
    updateCounters()
    return true
end

local function findCardPickup()
    local d = Workspace:FindFirstChild("CardPickup")
    if d then return d end
    for _, v in ipairs({"Card Pickup","Card_Pickup","CardPickUp","Cardpickup","cardpickup"}) do
        local f = Workspace:FindFirstChild(v)
        if f then return f end
    end
    for _, o in ipairs(Workspace:GetDescendants()) do
        if (o:IsA("Model") or o:IsA("BasePart") or o:IsA("Folder")) then
            if o.Name:lower():gsub("[%s_]", "") == "cardpickup" then return o end
        end
    end
    return nil
end

local function getPos(o)
    if not o then return nil end
    if o:IsA("BasePart") then return o.Position end
    if o:IsA("Model") then
        local rp = o.PrimaryPart or o:FindFirstChildOfClass("BasePart")
        if rp then return rp.Position end
    end
    if o:IsA("Folder") then
        for _, c in pairs(o:GetChildren()) do
            if c:IsA("BasePart") then return c.Position end
        end
    end
    return nil
end

local function findPromptIn(o)
    if not o then return nil end
    for _, d in ipairs(o:GetDescendants()) do
        if d:IsA("ProximityPrompt") then return d end
    end
    return nil
end

local function findPromptNear(pos, radius)
    radius = radius or 20
    local best, bd = nil, radius
    for _, d in ipairs(Workspace:GetDescendants()) do
        if d:IsA("ProximityPrompt") then
            local par = d.Parent
            local pp
            if par:IsA("Attachment") then pp = par.WorldPosition
            elseif par:IsA("BasePart") then pp = par.Position
            elseif par:IsA("Model") then
                local rp = par.PrimaryPart or par:FindFirstChildOfClass("BasePart")
                if rp then pp = rp.Position end
            end
            if pp then
                local dist = (pp - pos).Magnitude
                if dist < bd then bd = dist; best = d end
            end
        end
    end
    return best, bd
end

local function step_claimCard()
    if countTool("Card") > 0 then return true end
    updateStatus("STEP 11 · Cari CardPickup...")

    local card
    for _ = 1, 30 do
        if not ST.running then return false end
        card = findCardPickup()
        if card then break end
        task.wait(0.5)
    end

    if card then
        local pos = getPos(card)
        local prompt = findPromptIn(card)
        if pos and prompt then
            pcall(function()
                prompt.HoldDuration = 0
                prompt.RequiresLineOfSight = false
                prompt.MaxActivationDistance = 9e9
            end)
            for _ = 1, 20 do
                if not ST.running then return false end
                doVehicleTP(pos)
                task.wait(0.5)
                pcall(function() fireproximityprompt(prompt) end)
                task.wait(0.6)
                if countTool("Card") > 0 then
                    ST.counter.card = ST.counter.card + 1
                    updateCounters()
                    return true
                end
            end
        end
    end

    updateStatus("STEP 11 · Fallback coord claim...", Color3.fromRGB(255, 200, 80))
    doVehicleTP(CARD_FALLBACK_POS)
    task.wait(1)
    local bp, _ = findPromptNear(CARD_FALLBACK_POS, 25)
    if bp then
        pcall(function()
            bp.HoldDuration = 0
            bp.RequiresLineOfSight = false
            bp.MaxActivationDistance = 9e9
        end)
        for _ = 1, 20 do
            if not ST.running then return false end
            pcall(function() fireproximityprompt(bp) end)
            task.wait(0.6)
            if countTool("Card") > 0 then
                ST.counter.card = ST.counter.card + 1
                updateCounters()
                return true
            end
        end
    end
    return false
end

local function findATM()
    local map = Workspace:FindFirstChild("Map")
    local atms = map and map:FindFirstChild("ATMS")
    if not atms then return nil end
    for _, a in pairs(atms:GetChildren()) do
        local sc = a:FindFirstChild("ATMScreen")
        if sc and sc.Transparency == 0 then return a end
    end
    return nil
end

local function step_swipeATM()
    if countTool("Card") == 0 then return true end
    updateStatus("STEP 12 · Cari ATM...")

    local atm
    for _ = 1, 25 do
        if not ST.running then return false end
        atm = findATM()
        if atm then break end
        task.wait(0.5)
    end
    if not atm then return false end

    local att = atm:FindFirstChild("Attachment")
    local prompt = att and att:FindFirstChild("ProximityPrompt")
    if not prompt then return false end
    pcall(function()
        prompt.HoldDuration = 0
        prompt.RequiresLineOfSight = false
        prompt.MaxActivationDistance = 9e9
    end)

    local oldATM = LP.PlayerGui:FindFirstChild("ATM")
    if oldATM then oldATM:Destroy() end

    for _ = 1, 12 do
        if not ST.running then return false end
        doVehicleTP(atm.Position)
        task.wait(0.4)
        pcall(function() fireproximityprompt(prompt) end)
        task.wait(0.4)
        if LP.PlayerGui:FindFirstChild("ATM") then break end
    end

    local atmGui = LP.PlayerGui:FindFirstChild("ATM")
    if not atmGui then return false end

    equipTool("Card")
    task.wait(0.4)

    local frame = atmGui:FindFirstChild("Frame")
    local swipe = frame and frame:FindFirstChild("Swipe")
    if not swipe then return false end

    local clicked = false
    if replicatesignal then
        clicked = pcall(function() replicatesignal(swipe.MouseButton1Click) end)
    end
    if not clicked then
        local p = swipe.AbsolutePosition
        local s = swipe.AbsoluteSize
        if p and s then
            VIM:SendMouseButtonEvent(p.X + s.X/2, p.Y + s.Y/2, 0, true, game, 0)
            task.wait(0.05)
            VIM:SendMouseButtonEvent(p.X + s.X/2, p.Y + s.Y/2, 0, false, game, 0)
        end
    end
    task.wait(0.6)
    unequipAll()
    return true
end

local function step_claimChips()
    updateStatus("STEP 13 · Claim Chips dari Pot...")
    local pot = CHIPS_POTS[ST.pot]
    if not pot then return false end
    doVehicleTP(pot)
    task.wait(0.5)

    local before = countTool("Chips") + countTool("Potato Chips")
    firePrompt(pot, 8)
    local t0 = os.clock()
    while ST.running and (os.clock() - t0) < 8 do
        if (countTool("Chips") + countTool("Potato Chips")) > before then break end
        task.wait(0.2)
    end
    task.wait(1)
    return true
end

local function step_panasin()
    updateStatus("STEP 14 · Panasin Chips → Hot...")
    local raw = countTool("Chips") + countTool("Potato Chips")
    if raw == 0 then return true end

    doVehicleTP(SC_TUKAR)
    task.wait(0.5)

    local attempts = 0
    local lastCount = raw
    while ST.running and (countTool("Chips") + countTool("Potato Chips")) > 0 and attempts < (raw + 5) do
        attempts = attempts + 1
        task.wait(0.5)
        firePrompt(SC_TUKAR, 30)
        task.wait(3)
        local now = countTool("Chips") + countTool("Potato Chips")
        if now >= lastCount and attempts >= 3 then break end
        lastCount = now
    end
    task.wait(0.6)
    return true
end

local function step_sellHomeless()
    local hot = countTool("Hot Chips")
    if hot == 0 then return true end
    updateStatus(("STEP 15 · Jual %d Hot Chips..."):format(hot))

    equipTool("Hot Chips")
    task.wait(0.6)

    local safety = 0
    local maxSafety = hot + #SC_HOMELESS * 2

    while ST.running and countTool("Hot Chips") > 0 and safety < maxSafety do
        safety = safety + 1
        local idx = ST.homelessIdx
        local pos = SC_HOMELESS[idx]
        if not pos then ST.homelessIdx = 1; idx = 1; pos = SC_HOMELESS[1] end

        updateStatus(("STEP 15 · Homeless #%d (sisa: %d)"):format(idx, countTool("Hot Chips")))

        if not LP.Character:FindFirstChild("Hot Chips") then
            equipTool("Hot Chips")
            task.wait(0.4)
        end

        local before = countTool("Hot Chips")
        if doVehicleTP(pos) then
            task.wait(0.6)
            firePrompt(pos, 30); task.wait(0.6)
            firePrompt(pos, 30); task.wait(0.6)
            local after = countTool("Hot Chips")
            if after < before then
                ST.counter.hot = ST.counter.hot + (before - after)
                updateCounters()
            end
        end

        ST.homelessIdx = ST.homelessIdx + 1
        if ST.homelessIdx > #SC_HOMELESS then ST.homelessIdx = 1 end
        task.wait(0.3)
    end
    return true
end

-- ================================================================
-- MAIN LOOP (NO GOTO — pakai flag skipCycle)
-- ================================================================
local function runFullCycle()
    updateStatus("═══ BOOT PHASE ═══", Color3.fromRGB(180, 160, 255))
    updateCycle("Cycle #1 · Boot")

    if not ST.aptOwned then
        if not setupApartment() then
            updateStatus("Boot gagal: apartment", Color3.fromRGB(255, 80, 80))
            return
        end
    end
    if not ST.running then return end

    if not goToDealerAndWaitMotor() then return end
    if not ST.running then return end

    updateStatus("Boot selesai! Mulai routine...", Color3.fromRGB(0, 220, 100))
    task.wait(1.5)

    while ST.running do
        ST.cycle = ST.cycle + 1
        updateCycle(("Cycle #%d"):format(ST.cycle))
        updateStatus(("─── CYCLE #%d ───"):format(ST.cycle), Color3.fromRGB(180, 160, 255))
        task.wait(0.5)

        local skipCycle = false

        -- [3] Beli bahan MS
        if not skipCycle and not step_buyMarshmallowIngredients() then skipCycle = true end
        if not skipCycle and not ST.running then break end

        -- [4] Tuang Water
        if not skipCycle and not step_putWater() then
            updateStatus("Water gagal, retry cycle", Color3.fromRGB(255, 80, 80))
            task.wait(2); skipCycle = true
        end
        if not skipCycle and not ST.running then break end

        -- [5] Beli Fake ID
        if not skipCycle and not step_buyFakeID() then
            updateStatus("FakeID gagal", Color3.fromRGB(255, 80, 80))
            task.wait(2); skipCycle = true
        end
        if not skipCycle and not ST.running then break end

        -- [6] Apply Card
        if not skipCycle then step_applyCard() end
        if not skipCycle and not ST.running then break end

        -- [7] Beli bahan Chips
        if not skipCycle and not step_buyChipsIngredients() then
            updateStatus("Bahan chips gagal", Color3.fromRGB(255, 80, 80))
            task.wait(2); skipCycle = true
        end
        if not skipCycle and not ST.running then break end

        -- [8] Chips mission
        if not skipCycle and not step_chipsMission() then
            updateStatus("Chips mission gagal", Color3.fromRGB(255, 80, 80))
            task.wait(2); skipCycle = true
        end
        if not skipCycle and not ST.running then break end

        -- [9] Sugar + Gelatin
        if not skipCycle and not step_sugarGelatin() then break end
        if not skipCycle and not ST.running then break end

        -- [9b] Collect marshmallow
        if not skipCycle then step_collectMS() end
        if not skipCycle and not ST.running then break end

        -- [10] Sell marshmallow
        if not skipCycle then step_sellMS() end
        if not skipCycle and not ST.running then break end

        -- [11] Claim Card
        if not skipCycle then step_claimCard() end
        if not skipCycle and not ST.running then break end

        -- [12] Swipe ATM
        if not skipCycle then step_swipeATM() end
        if not skipCycle and not ST.running then break end

        -- [13] Claim Chips
        if not skipCycle then step_claimChips() end
        if not skipCycle and not ST.running then break end

        -- [14] Panasin
        if not skipCycle then step_panasin() end
        if not skipCycle and not ST.running then break end

        -- [15] Sell Homeless
        if not skipCycle then step_sellHomeless() end
        if not skipCycle and not ST.running then break end

        if not skipCycle then
            updateStatus(("✅ Cycle #%d selesai!"):format(ST.cycle), Color3.fromRGB(0, 220, 100))
        else
            updateStatus(("⚠ Cycle #%d skip, retry..."):format(ST.cycle), Color3.fromRGB(255, 200, 80))
        end
        task.wait(1.5)
    end

    ST.running = false
    refreshToggle()
    updateStatus("Stopped.", Color3.fromRGB(180, 60, 60))
    updateCycle("")
end

-- ================================================================
-- HANDLERS
-- ================================================================
ToggleBtn.MouseButton1Click:Connect(function()
    if not ST.running then
        ST.running = true
        ST.cycle = 0
        ST.startTime = os.time()
        refreshToggle()
        updateStatus("Memulai...", Color3.fromRGB(100, 255, 180))
        task.spawn(function()
            local ok, err = pcall(runFullCycle)
            if not ok then
                warn("[UnifiedFullCycle] Error:", err)
                updateStatus("Error: " .. tostring(err), Color3.fromRGB(255, 80, 80))
            end
            ST.running = false
            refreshToggle()
        end)
    else
        ST.running = false
        refreshToggle()
        updateStatus("Dihentikan manual.", Color3.fromRGB(180, 60, 60))
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    ST.running = false
    Gui:Destroy()
end)

task.spawn(function()
    while Gui.Parent do
        task.wait(1)
        pcall(updateCounters)
    end
end)

updateStatus("Idle · Tekan START untuk mulai", Color3.fromRGB(150, 150, 150))
print("[UNIFIED FULL CYCLE v1.1] Loaded! No goto, UI safe, all steps ready.")