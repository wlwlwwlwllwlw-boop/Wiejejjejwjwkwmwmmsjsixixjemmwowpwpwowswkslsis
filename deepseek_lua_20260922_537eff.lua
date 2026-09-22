-- ====================================================================
-- ⚡ DARM HUB MULTI v3 — ALL IN ONE
-- Flow: Buy Apt → Dealer → Motor → Beli Bahan → Tuang Air → FakeID
--      → Apply → Potato+Flour → Chips Mission → Sugar+Gelatin 47s
--      → Empty Bag → Sell Marshmallow → Claim Card → Swipe ATM
--      → Claim Chips → Panasin → Homeless Sell → LOOP
-- ====================================================================
if not game:IsLoaded() then game.Loaded:Wait() end

local Players    = game:GetService("Players")
local Workspace  = game:GetService("Workspace")
local RS         = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CoreGui    = game:GetService("CoreGui")
local UIS        = game:GetService("UserInputService")
local VIM        = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")
local ProximityPromptService = game:GetService("ProximityPromptService")

while not Players.LocalPlayer do task.wait(0.1) end
local LP = Players.LocalPlayer

local UI_Target = (gethui and gethui()) or CoreGui or LP:WaitForChild("PlayerGui")
local originalGravity = Workspace.Gravity

local RE
pcall(function()
    RE = RS:WaitForChild("RemoteEvents", 5):WaitForChild("ReliableRemoteEvent", 5)
end)

-- ================================================================
-- STATE
-- ================================================================
local ST = {
    running      = false,
    cycle        = 0,
    targetChips  = 5,
    pot          = 1,
    homelessIdx  = 1,
    step         = "Idle",
    apartmentOwned = false,
    kitchenPos   = nil,
    doorPos      = nil,
    batchAmount  = 1,
    -- ==== COUNTERS ====
    marshmallowSold = 0,
    chipsSold       = 0,
    cardSold        = 0,
}

-- ================================================================
-- KOORDINAT
-- ================================================================
local SHOP_POS   = Vector3.new(510.50, 4.5, 598.28)
local DEALER_POS = Vector3.new(730.24, 3.70, 449.47)

local CHIPS_BUY = Vector3.new(-759.197, 3.489, -194.846)
local CHIPS_COORDS = {
    A = Vector3.new(-478.83, 3.86, -438.92),
    B = Vector3.new(-461.69, 3.86, -461.25),
    C = Vector3.new(-461.69, 3.86, -472.88),
    D = Vector3.new(-462.75, 3.86, -521.94),
}
local CHIPS_POTS = {
    Vector3.new(-515.28, 3.86, -451.71),
    Vector3.new(-515.24, 3.86, -462.26),
    Vector3.new(-515.28, 3.86, -471.89),
    Vector3.new(-515.28, 3.86, -481.75),
    Vector3.new(-515.24, 3.86, -492.10),
    Vector3.new(-496.99, 3.86, -452.21),
    Vector3.new(-496.95, 3.86, -462.02),
    Vector3.new(-496.98, 3.86, -471.73),
    Vector3.new(-496.99, 3.86, -481.82),
    Vector3.new(-497.04, 3.86, -491.37),
}
local SC_HOMELESS = {
    Vector3.new(-315.35, 3.72,  -361.56),
    Vector3.new(-273.52, 3.85,  -211.32),
    Vector3.new(1102.42, 3.36,  527.05),
    Vector3.new(52.89,   3.72,  -425.36),
    Vector3.new(152.88,  3.73,  -210.08),
    Vector3.new(-522.75, -7.86, -165.08),
    Vector3.new(65.12,   3.73,  68.10),
    Vector3.new(26.04,   3.73,  217.89),
    Vector3.new(520.08,  3.87,  -295.52),
    Vector3.new(699.28,  3.72,  -427.05),
    Vector3.new(900.03,  3.94,  -283.12),
    Vector3.new(874.89,  3.73,  -63.02),
}
local SC_TUKAR = Vector3.new(-34.91, 4.56, -24.15)

local LOC_FakeID        = Vector3.new(214.960, 1.857, -332.330)
local LOC_ApplyForCard  = Vector3.new(-49.210, 4.000, -310.810)
local CARD_FALLBACK_POS = Vector3.new(-39.090, 5.392, -329.700)

local ApartmentData = {
    { ID = 7,  BuyPos = Vector3.new(1197.11, 3.71, -237.50), DoorPos = Vector3.new(1199.14, 3.71, -243.04), KitchenPos = Vector3.new(1202.15, -2.29, -220.04) },
    { ID = 8,  BuyPos = Vector3.new(1196.79, 3.71, -201.87), DoorPos = Vector3.new(1199.00, 3.71, -207.04), KitchenPos = Vector3.new(1202.14, -2.29, -180.56) },
    { ID = 9,  BuyPos = Vector3.new(1185.65, 3.71, -207.83), DoorPos = Vector3.new(1183.52, 3.71, -202.90), KitchenPos = Vector3.new(1180.38, -2.29, -188.99) },
    { ID = 10, BuyPos = Vector3.new(1185.42, 3.71, -243.37), DoorPos = Vector3.new(1183.58, 3.71, -238.20), KitchenPos = Vector3.new(1180.41, -2.29, -227.24) }
}

local M_BAGS = {
    "Marshmallow", "Marshmellow",
    "Large Marshmallow Bag", "Large Marshmellow Bag",
    "Medium Marshmallow Bag", "Medium Marshmellow Bag",
    "Small Marshmallow Bag", "Small Marshmellow Bag"
}

-- ================================================================
-- TP SETTINGS
-- ================================================================
local MAX_SPEED = 150
local HOP_DIST  = 15
local MIN_DELAY = 0.04
local MAX_DELAY = 0.5
local tpBusy    = false

-- ================================================================
-- ANTI-AFK
-- ================================================================
task.spawn(function()
    local vu = game:GetService("VirtualUser")
    LP.Idled:Connect(function()
        vu:Button2Down(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
        task.wait(1)
        vu:Button2Up(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
    end)
end)

-- ================================================================
-- UI — DARM HUB MULTI
-- ================================================================
local Gui = Instance.new("ScreenGui")
Gui.Name = "DarmHubMulti"
Gui.ResetOnSpawn = false
Gui.DisplayOrder = 9999
Gui.Parent = UI_Target

local Main = Instance.new("Frame", Gui)
Main.Size = UDim2.new(0, 300, 0, 470)
Main.Position = UDim2.new(0.05, 0, 0.12, 0)
Main.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)
local mainStroke = Instance.new("UIStroke", Main)
mainStroke.Color = Color3.fromRGB(0, 200, 100)
mainStroke.Thickness = 1.5

local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 38)
Header.BackgroundColor3 = Color3.fromRGB(10, 26, 16)
Header.BorderSizePixel = 0
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 12)
local hFix = Instance.new("Frame", Header)
hFix.Size = UDim2.new(1, 0, 0, 10)
hFix.Position = UDim2.new(0, 0, 1, -10)
hFix.BackgroundColor3 = Color3.fromRGB(10, 26, 16)
hFix.BorderSizePixel = 0

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 14, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "⚡ DARM HUB MULTI"
Title.TextColor3 = Color3.fromRGB(100, 255, 180)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Position = UDim2.new(1, -30, 0.5, -12)
CloseBtn.BackgroundColor3 = Color3.fromRGB(40, 12, 12)
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(220, 80, 80)
CloseBtn.Font = Enum.Font.GothamBlack
CloseBtn.TextSize = 16
CloseBtn.AutoButtonColor = false
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

local Content = Instance.new("Frame", Main)
Content.Size = UDim2.new(1, -20, 1, -50)
Content.Position = UDim2.new(0, 10, 0, 44)
Content.BackgroundTransparency = 1
local Layout = Instance.new("UIListLayout", Content)
Layout.Padding = UDim.new(0, 8)
Layout.SortOrder = Enum.SortOrder.LayoutOrder

local ToggleBtn = Instance.new("TextButton", Content)
ToggleBtn.Size = UDim2.new(1, 0, 0, 42)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(35, 12, 12)
ToggleBtn.Text = "OFF"
ToggleBtn.TextColor3 = Color3.fromRGB(220, 80, 80)
ToggleBtn.Font = Enum.Font.GothamBlack
ToggleBtn.TextSize = 14
ToggleBtn.AutoButtonColor = false
ToggleBtn.LayoutOrder = 1
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 8)
local tStr = Instance.new("UIStroke", ToggleBtn)
tStr.Color = Color3.fromRGB(80, 25, 25)
tStr.Thickness = 1

local StatusCard = Instance.new("Frame", Content)
StatusCard.Size = UDim2.new(1, 0, 0, 44)
StatusCard.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
StatusCard.BorderSizePixel = 0
StatusCard.LayoutOrder = 2
Instance.new("UICorner", StatusCard).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", StatusCard).Color = Color3.fromRGB(40, 40, 55)

local StatusLabel = Instance.new("TextLabel", StatusCard)
StatusLabel.Size = UDim2.new(1, -16, 0, 16)
StatusLabel.Position = UDim2.new(0, 10, 0, 6)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Status: Idle"
StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.TextSize = 11
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left

local StepLabel = Instance.new("TextLabel", StatusCard)
StepLabel.Size = UDim2.new(1, -16, 0, 16)
StepLabel.Position = UDim2.new(0, 10, 0, 22)
StepLabel.BackgroundTransparency = 1
StepLabel.Text = "Idle"
StepLabel.TextColor3 = Color3.fromRGB(140, 200, 255)
StepLabel.Font = Enum.Font.Code
StepLabel.TextSize = 10
StepLabel.TextXAlignment = Enum.TextXAlignment.Left

local LiveCard = Instance.new("Frame", Content)
LiveCard.Size = UDim2.new(1, 0, 0, 100)
LiveCard.BackgroundColor3 = Color3.fromRGB(10, 26, 16)
LiveCard.BorderSizePixel = 0
LiveCard.LayoutOrder = 3
Instance.new("UICorner", LiveCard).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", LiveCard).Color = Color3.fromRGB(20, 80, 50)

local LiveTitle = Instance.new("TextLabel", LiveCard)
LiveTitle.Size = UDim2.new(1, -16, 0, 18)
LiveTitle.Position = UDim2.new(0, 10, 0, 6)
LiveTitle.BackgroundTransparency = 1
LiveTitle.Text = "📊 LIVE STATUS"
LiveTitle.TextColor3 = Color3.fromRGB(100, 255, 180)
LiveTitle.Font = Enum.Font.GothamBlack
LiveTitle.TextSize = 11
LiveTitle.TextXAlignment = Enum.TextXAlignment.Left

local MSLabel = Instance.new("TextLabel", LiveCard)
MSLabel.Size = UDim2.new(1, -16, 0, 20)
MSLabel.Position = UDim2.new(0, 10, 0, 26)
MSLabel.BackgroundTransparency = 1
MSLabel.Text = "🧂 MARSHMELLOW SOLD : 0"
MSLabel.TextColor3 = Color3.fromRGB(255, 220, 150)
MSLabel.Font = Enum.Font.GothamBold
MSLabel.TextSize = 11
MSLabel.TextXAlignment = Enum.TextXAlignment.Left

local ChipsLabel = Instance.new("TextLabel", LiveCard)
ChipsLabel.Size = UDim2.new(1, -16, 0, 20)
ChipsLabel.Position = UDim2.new(0, 10, 0, 48)
ChipsLabel.BackgroundTransparency = 1
ChipsLabel.Text = "🍟 CHIPS SOLD : 0"
ChipsLabel.TextColor3 = Color3.fromRGB(255, 200, 80)
ChipsLabel.Font = Enum.Font.GothamBold
ChipsLabel.TextSize = 11
ChipsLabel.TextXAlignment = Enum.TextXAlignment.Left

local CardLabel = Instance.new("TextLabel", LiveCard)
CardLabel.Size = UDim2.new(1, -16, 0, 20)
CardLabel.Position = UDim2.new(0, 10, 0, 70)
CardLabel.BackgroundTransparency = 1
CardLabel.Text = "💳 CARD SOLD : 0"
CardLabel.TextColor3 = Color3.fromRGB(150, 200, 255)
CardLabel.Font = Enum.Font.GothamBold
CardLabel.TextSize = 11
CardLabel.TextXAlignment = Enum.TextXAlignment.Left

local PotLabel = Instance.new("TextLabel", Content)
PotLabel.Size = UDim2.new(1, 0, 0, 14)
PotLabel.BackgroundTransparency = 1
PotLabel.Text = "🍲 Pilih Pot (1-10):"
PotLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
PotLabel.Font = Enum.Font.GothamBold
PotLabel.TextSize = 11
PotLabel.TextXAlignment = Enum.TextXAlignment.Left
PotLabel.LayoutOrder = 4

local PotGrid = Instance.new("Frame", Content)
PotGrid.Size = UDim2.new(1, 0, 0, 66)
PotGrid.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
PotGrid.BorderSizePixel = 0
PotGrid.LayoutOrder = 5
Instance.new("UICorner", PotGrid).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", PotGrid).Color = Color3.fromRGB(40, 40, 55)

local potBtns = {}
local function refreshPotBtns()
    for i, btn in ipairs(potBtns) do
        local sel = ST.pot == i
        btn.BackgroundColor3 = sel and Color3.fromRGB(20, 70, 130) or Color3.fromRGB(22, 22, 28)
        local s = btn:FindFirstChildOfClass("UIStroke")
        if s then s.Color = sel and Color3.fromRGB(80, 180, 255) or Color3.fromRGB(50, 50, 60) end
        local l = btn:FindFirstChildOfClass("TextLabel")
        if l then l.TextColor3 = sel and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150) end
    end
end

for i = 1, 10 do
    local col = (i-1) % 5
    local row = math.floor((i-1) / 5)
    local pw = 1/5
    local pBtn = Instance.new("TextButton", PotGrid)
    pBtn.Size = UDim2.new(pw - 0.02, 0, 0, 24)
    pBtn.Position = UDim2.new(col*pw + 0.01, 0, 0, 8 + row*30)
    pBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
    pBtn.Text = ""
    pBtn.AutoButtonColor = false
    Instance.new("UICorner", pBtn).CornerRadius = UDim.new(0, 6)
    local pbs = Instance.new("UIStroke", pBtn)
    pbs.Color = Color3.fromRGB(50, 50, 60)
    local pbl = Instance.new("TextLabel", pBtn)
    pbl.Size = UDim2.new(1, 0, 1, 0)
    pbl.BackgroundTransparency = 1
    pbl.Text = tostring(i)
    pbl.TextColor3 = Color3.fromRGB(150, 150, 150)
    pbl.Font = Enum.Font.GothamBlack
    pbl.TextSize = 12
    table.insert(potBtns, pBtn)
    local capI = i
    pBtn.MouseButton1Click:Connect(function()
        if ST.running then return end
        ST.pot = capI
        refreshPotBtns()
        pcall(function() updateStatus("Pot dipilih: #" .. capI, Color3.fromRGB(100, 200, 255)) end)
    end)
end
refreshPotBtns()

local InfoCard = Instance.new("Frame", Content)
InfoCard.Size = UDim2.new(1, 0, 0, 50)
InfoCard.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
InfoCard.BorderSizePixel = 0
InfoCard.LayoutOrder = 6
Instance.new("UICorner", InfoCard).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", InfoCard).Color = Color3.fromRGB(40, 40, 55)

local InfoTxt = Instance.new("TextLabel", InfoCard)
InfoTxt.Size = UDim2.new(1, -12, 1, -8)
InfoTxt.Position = UDim2.new(0, 6, 0, 4)
InfoTxt.BackgroundTransparency = 1
InfoTxt.Text = "🔄 Auto Full Cycle · Marshmallow + Card + Chips\n🚀 Hop 150 stud/s · Silent TP · No Loading"
InfoTxt.TextColor3 = Color3.fromRGB(140, 180, 220)
InfoTxt.Font = Enum.Font.Gotham
InfoTxt.TextSize = 10
InfoTxt.TextXAlignment = Enum.TextXAlignment.Left
InfoTxt.TextYAlignment = Enum.TextYAlignment.Top
InfoTxt.TextWrapped = true

local CycleLabel = Instance.new("TextLabel", Content)
CycleLabel.Size = UDim2.new(1, 0, 0, 14)
CycleLabel.BackgroundTransparency = 1
CycleLabel.Text = "Cycle: 0"
CycleLabel.TextColor3 = Color3.fromRGB(150, 180, 220)
CycleLabel.Font = Enum.Font.GothamBold
CycleLabel.TextSize = 11
CycleLabel.TextXAlignment = Enum.TextXAlignment.Left
CycleLabel.LayoutOrder = 7

-- ================================================================
-- UI UPDATE FUNCS
-- ================================================================
local function updateStatus(txt, col)
    pcall(function()
        StatusLabel.Text = "Status: " .. tostring(txt)
        if col then StatusLabel.TextColor3 = col end
    end)
end

local function setStep(txt)
    ST.step = txt
    pcall(function() StepLabel.Text = txt or "" end)
end

local function updateLiveStatus()
    pcall(function()
        MSLabel.Text    = "🧂 MARSHMELLOW SOLD : " .. tostring(ST.marshmallowSold)
        ChipsLabel.Text = "🍟 CHIPS SOLD : " .. tostring(ST.chipsSold)
        CardLabel.Text  = "💳 CARD SOLD : " .. tostring(ST.cardSold)
    end)
end

local function refreshToggle()
    local on = ST.running
    ToggleBtn.BackgroundColor3 = on and Color3.fromRGB(10, 45, 25) or Color3.fromRGB(35, 12, 12)
    ToggleBtn.TextColor3 = on and Color3.fromRGB(100, 255, 180) or Color3.fromRGB(220, 80, 80)
    ToggleBtn.Text = on and "🔁 ON · Sedang Berjalan" or "▶  MULAI MULTI FARM"
    tStr.Color = on and Color3.fromRGB(30, 120, 70) or Color3.fromRGB(80, 25, 25)
end
refreshToggle()
updateLiveStatus()

CloseBtn.MouseButton1Click:Connect(function()
    ST.running = false
    Gui:Destroy()
end)

-- ================================================================
-- GHOST MODE
-- ================================================================
local modifiedParts = {}
local ghostConn = nil

local function startGhostMode()
    if ghostConn then return end
    ghostConn = RunService.Heartbeat:Connect(function()
        local char = LP.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local hum = char:FindFirstChild("Humanoid")
        if hum and hum.Sit then return end
        local hrp = char.HumanoidRootPart

        local function proc(part)
            if not part or not part:IsA("BasePart") or part:IsA("Terrain") then return end
            if part:IsDescendantOf(char) then return end
            if part:IsA("Seat") or part:IsA("VehicleSeat") or part.Name:lower():find("seat") then return end
            if not modifiedParts[part] then
                modifiedParts[part] = { CanCollide = part.CanCollide, CanTouch = part.CanTouch }
            end
            part.CanCollide = false
            part.CanTouch   = false
        end

        for _, part in ipairs(hrp:GetTouchingParts()) do proc(part) end
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = {char}
        for _, dir in ipairs({
            Vector3.new(0, -4, 0),
            hrp.CFrame.LookVector * 3.5,
            -hrp.CFrame.LookVector * 3.5,
            hrp.CFrame.RightVector * 3.5,
            -hrp.CFrame.RightVector * 3.5
        }) do
            local res = Workspace:Raycast(hrp.Position, dir, params)
            if res and res.Instance then proc(res.Instance) end
        end
    end)
end

local function stopGhostMode()
    if ghostConn then ghostConn:Disconnect(); ghostConn = nil end
    for part, state in pairs(modifiedParts) do
        if part and part.Parent then
            part.CanCollide = state.CanCollide
            part.CanTouch   = state.CanTouch
        end
    end
    modifiedParts = {}
end

-- ================================================================
-- DISCRETE STEP TP
-- ================================================================
local function discreteStepTP(startP, endP, speed)
    speed = speed or 0.8
    local char = LP.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return false end
    local hrp = char.HumanoidRootPart
    while ST.running do
        local dist = (endP - hrp.Position).Magnitude
        if dist <= speed then
            hrp.CFrame = CFrame.new(endP)
            hrp.AssemblyLinearVelocity = Vector3.zero
            return true
        end
        hrp.CFrame = CFrame.new(hrp.Position + ((endP - hrp.Position).Unit * speed))
        hrp.AssemblyLinearVelocity = Vector3.zero
        task.wait(0.08)
    end
    return false
end

local function blinkTP(targetPos, underground)
    local char = LP.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return false end
    startGhostMode()
    local hrp = char.HumanoidRootPart
    local hum = char:FindFirstChild("Humanoid")
    if hum then hum.PlatformStand = true end
    Workspace.Gravity = 0

    if underground then
        local uY = -4
        discreteStepTP(hrp.Position, Vector3.new(hrp.Position.X, uY, hrp.Position.Z))
        discreteStepTP(hrp.Position, Vector3.new(targetPos.X, uY, targetPos.Z))
        discreteStepTP(hrp.Position, targetPos)
    else
        discreteStepTP(hrp.Position, targetPos)
    end

    Workspace.Gravity = originalGravity
    if hum then hum.PlatformStand = false end
    stopGhostMode()
    return true
end

local function BypassTP(targetPos)
    local char = LP.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
        local bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Velocity = Vector3.new(0, 9e9, 0)
        bv.Parent = hrp
    end
    local newChar = LP.CharacterAdded:Wait()
    local newHrp = newChar:WaitForChild("HumanoidRootPart", 10)
    if newHrp then
        task.wait(0.5)
        newHrp.CFrame = CFrame.new(targetPos)
    end
    task.wait(1.2)
end

-- ================================================================
-- VEHICLE HOP TP
-- ================================================================
local function vehicleTP(targetPos)
    if tpBusy then return false, "Busy" end
    local char = LP.Character
    if not char then return false, "No char" end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false, "Dead" end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false, "No HRP" end

    local seat = hum.SeatPart
    if not seat then return false, "Belum naik motor" end
    local vehicle = seat:FindFirstAncestorOfClass("Model")
    if not vehicle then return false, "Vehicle not found" end
    local vRoot = vehicle.PrimaryPart or seat
    if not vRoot then return false, "No vRoot" end

    tpBusy = true
    local startPos = vRoot.Position
    local targetPosV = targetPos + Vector3.new(0, 3, 0)
    local rot = vRoot.CFrame.Rotation
    local totalDist = (targetPosV - startPos).Magnitude
    local hopCount = math.max(1, math.ceil(totalDist / HOP_DIST))
    local hopDelay = math.clamp(HOP_DIST / MAX_SPEED, MIN_DELAY, MAX_DELAY)

    for i = 1, hopCount do
        if not ST.running then break end
        local t = i / hopCount
        local stepPos = startPos:Lerp(targetPosV, t)
        pcall(function() vehicle:PivotTo(CFrame.new(stepPos) * rot) end)
        task.wait(hopDelay)
    end

    pcall(function() vehicle:PivotTo(CFrame.new(targetPosV) * rot) end)
    task.wait(0.1)
    tpBusy = false
    return true, "OK"
end

-- ================================================================
-- PROMPT HELPER
-- ================================================================
local function matchPromptText(actionText, keyword)
    if not keyword then return true end
    local text = string.lower(actionText or "")
    keyword = string.lower(keyword)
    if keyword == "lock" and string.find(text, "unlock") then return false end
    return string.find(text, keyword) ~= nil
end

local function firePromptAt(pos, maxDist, keyword)
    maxDist = maxDist or 30
    local best, bestDist = nil, maxDist
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and obj.Enabled then
            if matchPromptText(obj.ActionText, keyword) then
                local parent = obj.Parent
                local pPos = nil
                if parent then
                    if parent:IsA("BasePart") then pPos = parent.Position
                    elseif parent:IsA("Attachment") then pPos = parent.WorldPosition
                    elseif parent:IsA("Model") then
                        local rp = parent.PrimaryPart or parent:FindFirstChildOfClass("BasePart")
                        if rp then pPos = rp.Position end
                    elseif parent:IsA("Folder") then
                        local rp = parent:FindFirstChildOfClass("BasePart")
                        if rp then pPos = rp.Position end
                    end
                end
                if pPos then
                    local d = (pos - pPos).Magnitude
                    if d <= bestDist then bestDist = d; best = obj end
                end
            end
        end
    end
    if not best then return false end
    pcall(function()
        best.MaxActivationDistance = 9e9
        best.RequiresLineOfSight = false
        best.HoldDuration = 0
    end)
    if fireproximityprompt then
        pcall(function() fireproximityprompt(best, 0) end)
    else
        pcall(function()
            best:InputHoldBegin(); task.wait(0.05); best:InputHoldEnd()
        end)
    end
    return true
end

-- ================================================================
-- INSTANT PROXIMITY PROMPT
-- ================================================================
local function makePromptInstant(prompt)
    if prompt and prompt:IsA("ProximityPrompt") then
        pcall(function()
            prompt.HoldDuration = 0
            prompt.RequiresLineOfSight = false
        end)
    end
end

for _, obj in ipairs(Workspace:GetDescendants()) do
    makePromptInstant(obj)
end
Workspace.DescendantAdded:Connect(makePromptInstant)
ProximityPromptService.PromptShown:Connect(makePromptInstant)

-- ================================================================
-- CHECK PROMPT EXISTS
-- ================================================================
local function checkPromptAt(pos, maxDist, keyword)
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and obj.Enabled then
            if matchPromptText(obj.ActionText, keyword) then
                local p = obj.Parent
                local pPos
                if p then
                    if p:IsA("BasePart") then pPos = p.Position
                    elseif p:IsA("Attachment") then pPos = p.WorldPosition
                    elseif p:IsA("Model") then
                        local rp = p.PrimaryPart or p:FindFirstChildOfClass("BasePart")
                        if rp then pPos = rp.Position end
                    end
                end
                if pPos and (pos - pPos).Magnitude <= maxDist then
                    return true
                end
            end
        end
    end
    return false
end

-- ================================================================
-- SECURE APARTMENT DOOR — close + lock
-- ================================================================
local function secureApartmentDoor(doorPos)
    if not doorPos then return false end
    updateStatus("🔒 Kunci pintu...", Color3.fromRGB(200,180,100))

    for i = 1, 12 do
        if not ST.running then return false end

        if checkPromptAt(doorPos, 8, "unlock") then
            updateStatus("🔒 Pintu terkunci ✔", Color3.fromRGB(0,220,100))
            return true
        end

        if checkPromptAt(doorPos, 8, "close") then
            firePromptAt(doorPos, 8, "close")
            task.wait(0.5)
        end

        if checkPromptAt(doorPos, 8, "lock") then
            firePromptAt(doorPos, 8, "lock")
            task.wait(0.6)
        end

        if checkPromptAt(doorPos, 8, "unlock") then
            updateStatus("🔒 Pintu terkunci ✔", Color3.fromRGB(0,220,100))
            return true
        end

        task.wait(0.3)
    end
    return checkPromptAt(doorPos, 8, "unlock")
end

-- ================================================================
-- INVENTORY
-- ================================================================
local function getCount(nameOrList)
    local c = 0
    local function check(container)
        if not container then return end
        for _, v in ipairs(container:GetChildren()) do
            if v:IsA("Tool") then
                if type(nameOrList) == "table" then
                    for _, n in ipairs(nameOrList) do
                        if v.Name == n then c = c + 1; break end
                    end
                elseif v.Name == nameOrList then
                    c = c + 1
                end
            end
        end
    end
    check(LP:FindFirstChild("Backpack"))
    check(LP.Character)
    return c
end

local function hasTool(name) return getCount(name) > 0 end

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
    local tool = bp:FindFirstChild(name)
    if not tool then
        for _, v in pairs(bp:GetChildren()) do
            if v:IsA("Tool") and v.Name:lower():find(name:lower()) then
                tool = v; break
            end
        end
    end
    if tool then
        hum:EquipTool(tool)
        local t0 = os.clock()
        while os.clock() - t0 < 1.5 do
            if char:FindFirstChild(tool.Name) then task.wait(0.1); return true end
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
-- REMOTE BUY
-- ================================================================
local function fireRemote(cat, sub, arg)
    if not RE then return false end
    local ok = pcall(function()
        local buf = buffer.create(3)
        buffer.writeu8(buf, 0, cat)
        buffer.writeu8(buf, 1, sub)
        buffer.writeu8(buf, 2, arg)
        RE:FireServer(buf)
    end)
    return ok
end

local function buyMarshmallowIngredient(arg, targetItemName, target)
    local attempt = 0
    while ST.running and attempt < 40 do
        attempt = attempt + 1
        if getCount(targetItemName) >= target then return true end
        fireRemote(24, 19, arg)
        local deadline = os.clock() + 2.5
        repeat task.wait(0.1) until getCount(targetItemName) >= target or os.clock() > deadline
        if getCount(targetItemName) >= target then return true end
        task.wait(0.2)
    end
    return getCount(targetItemName) >= target
end

local function buyChipsIngredient(arg, targetItemName, target)
    local attempt = 0
    while ST.running and attempt < 40 do
        attempt = attempt + 1
        if getCount(targetItemName) >= target then return true end
        fireRemote(24, 21, arg)
        local deadline = os.clock() + 2.5
        repeat task.wait(0.1) until getCount(targetItemName) >= target or os.clock() > deadline
        if getCount(targetItemName) >= target then return true end
        task.wait(0.2)
    end
    return getCount(targetItemName) >= target
end

-- ================================================================
-- WAIT HELPERS
-- ================================================================
local function waitUntilConsumed(toolName, timeout)
    timeout = timeout or 10
    local before = getCount(toolName)
    if before <= 0 then return true end
    local t0 = os.clock()
    while ST.running and (os.clock() - t0) < timeout do
        if getCount(toolName) < before then task.wait(0.3); return true end
        task.wait(0.1)
    end
    return false
end

local function waitForVehicle(timeout)
    timeout = timeout or 60
    local t0 = os.clock()
    while ST.running and (os.clock() - t0) < timeout do
        local char = LP.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and hum.SeatPart then task.wait(0.4); return true end
        end
        task.wait(0.3)
    end
    return false
end

-- ================================================================
-- PHASE 1 — BUY APARTMENT
-- ================================================================
local function phase_BuyApartment()
    if ST.apartmentOwned and ST.kitchenPos then return true end
    updateStatus("Cari apartment vacant...", Color3.fromRGB(255,200,80))
    setStep("[1] BUY APARTMENT")

    local targetData = nil
    for _, data in ipairs(ApartmentData) do
        if not ST.running then return false end
        local isVacant = false
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("TextLabel") and string.find(string.upper(obj.Text), "VACANT") then
                local gui = obj:FindFirstAncestorOfClass("SurfaceGui") or obj:FindFirstAncestorOfClass("BillboardGui")
                local uiPart = gui and (gui.Adornee or gui.Parent)
                if uiPart and uiPart:IsA("BasePart") and (uiPart.Position - data.BuyPos).Magnitude <= 5 then
                    isVacant = true; break
                end
            end
        end
        if isVacant then targetData = data; break end
    end

    if not targetData then
        updateStatus("No Vacant Apt!", Color3.fromRGB(255,80,80))
        return false
    end

    BypassTP(targetData.BuyPos)
    if not ST.running then return false end

    firePromptAt(targetData.BuyPos, 5, "purchase")
    task.wait(1)

    ST.kitchenPos = targetData.KitchenPos
    ST.doorPos    = targetData.DoorPos
    ST.apartmentOwned = true

    blinkTP(targetData.DoorPos, false)
    task.wait(0.5)
    secureApartmentDoor(targetData.DoorPos)
    updateStatus("Apartment ✔", Color3.fromRGB(0,220,100))
    return true
end

-- ================================================================
-- PHASE 2 — DEALER + WAIT VEHICLE
-- ================================================================
local function phase_GoToDealer()
    updateStatus("TP ke dealer...", Color3.fromRGB(255,200,80))
    setStep("[2] DEALER + AMBIL MOTOR")
    blinkTP(DEALER_POS, true)
    task.wait(0.8)
    return true
end

local function phase_WaitVehicle()
    updateStatus("Tunggu motor...", Color3.fromRGB(255,200,80))
    if not waitForVehicle(90) then
        updateStatus("Motor gak ketemu", Color3.fromRGB(255,80,80))
        return false
    end
    updateStatus("Motor ✔", Color3.fromRGB(0,220,100))
    return true
end

-- ================================================================
-- PHASE 3 — BELI BAHAN MARSHMALLOW
-- ================================================================
local function phase_BuyMarshmallowIngredients()
    setStep("[3] BELI BAHAN MARSHMALLOW")
    updateStatus("TP ke shop...", Color3.fromRGB(255,200,80))
    local ok, err = vehicleTP(SHOP_POS)
    if not ok then
        blinkTP(SHOP_POS, true)
    end
    task.wait(0.8)

    local target = ST.batchAmount
    updateStatus("Beli Gelatin...", Color3.fromRGB(255,200,80))
    buyMarshmallowIngredient(1, "Gelatin", target)
    updateStatus("Beli Sugar...", Color3.fromRGB(255,200,80))
    buyMarshmallowIngredient(2, "Sugar Block Bag", target)
    updateStatus("Beli Water...", Color3.fromRGB(255,200,80))
    buyMarshmallowIngredient(3, {"Water","Water23"}, target)
    task.wait(0.5)
    return true
end

-- ================================================================
-- PHASE 4 — TUANG AIR + LOCK DOOR
-- ================================================================
local function phase_PourWater()
    setStep("[4] TUANG AIR + LOCK DOOR")
    updateStatus("TP ke apartment...", Color3.fromRGB(255,200,80))
    local ok, err = vehicleTP(ST.kitchenPos)
    if not ok then blinkTP(ST.kitchenPos, true) end
    task.wait(0.8)

    updateStatus("Tuang air...", Color3.fromRGB(80,200,255))
    local attempts = 0
    while ST.running and getCount({"Water","Water23"}) > 0 and attempts < 25 do
        attempts = attempts + 1
        equipTool("Water")
        task.wait(0.25)
        firePromptAt(ST.kitchenPos, 12)
        task.wait(0.8)
    end
    updateStatus("Air dituang ✔", Color3.fromRGB(0,220,100))

    secureApartmentDoor(ST.doorPos)
    return true
end

-- ================================================================
-- PHASE 5 — BUY FAKE ID
-- ================================================================
local function findFakeIDSellerPrompt()
    local folders = Workspace:FindFirstChild("Folders"); if not folders then return nil end
    local npcs = folders:FindFirstChild("NPCs"); if not npcs then return nil end
    local seller = npcs:FindFirstChild("FakeIDSeller"); if not seller then return nil end
    for _, d in ipairs(seller:GetDescendants()) do
        if d:IsA("ProximityPrompt") then return d end
    end
    return nil
end

local function getFakeIDCount()
    local c = 0
    local function check(cont)
        if not cont then return end
        for _, v in ipairs(cont:GetChildren()) do
            if v:IsA("Tool") then
                local n = v.Name:lower()
                if n:find("fake") and n:find("id") then c = c + 1 end
            end
        end
    end
    check(LP:FindFirstChild("Backpack"))
    check(LP.Character)
    return c
end

local function phase_BuyFakeID()
    if hasTool("Fake ID") then return true end
    setStep("[5] BUY FAKE ID")
    updateStatus("TP ke FakeIDSeller...", Color3.fromRGB(255,200,80))

    local ok, err = vehicleTP(LOC_FakeID)
    if not ok then blinkTP(LOC_FakeID, true) end
    task.wait(0.8)

    local prompt = findFakeIDSellerPrompt()
    if not prompt then updateStatus("Prompt seller gak ada", Color3.fromRGB(255,80,80)); return false end
    pcall(function()
        prompt.HoldDuration = 0
        prompt.RequiresLineOfSight = false
        prompt.MaxActivationDistance = 9e9
        prompt.Enabled = true
    end)

    local before = getFakeIDCount()
    for i = 1, 15 do
        if not ST.running then return false end
        pcall(function() fireproximityprompt(prompt) end)
        task.wait(0.4)
        if getFakeIDCount() > before then
            updateStatus("Fake ID ✔", Color3.fromRGB(0,220,100))
            return true
        end
    end
    updateStatus("Fake ID gagal", Color3.fromRGB(255,80,80))
    return false
end

-- ================================================================
-- PHASE 6 — APPLY CARD
-- ================================================================
local function findBankTellerPrompt()
    local folders = Workspace:FindFirstChild("Folders"); if not folders then return nil end
    local npcs = folders:FindFirstChild("NPCs"); if not npcs then return nil end
    local teller = npcs:FindFirstChild("Bank Teller"); if not teller then return nil end
    local upper = teller:FindFirstChild("UpperTorso")
    local att = upper and upper:FindFirstChild("Attachment")
    return att and att:FindFirstChild("ProximityPrompt")
end

local function phase_ApplyCard()
    if not hasTool("Fake ID") then return false end
    setStep("[6] APPLY CARD")
    updateStatus("TP ke Bank...", Color3.fromRGB(255,200,80))

    local ok = vehicleTP(LOC_ApplyForCard)
    if not ok then blinkTP(LOC_ApplyForCard, true) end
    task.wait(0.8)

    equipTool("Fake ID")
    task.wait(0.3)

    local prompt = findBankTellerPrompt()
    if not prompt then updateStatus("Teller prompt gak ada", Color3.fromRGB(255,80,80)); return false end
    pcall(function()
        prompt.HoldDuration = 0
        prompt.RequiresLineOfSight = false
        prompt.MaxActivationDistance = 9e9
    end)

    local attempts = 0
    while ST.running and hasTool("Fake ID") and attempts < 20 do
        attempts = attempts + 1
        pcall(function() fireproximityprompt(prompt) end)
        task.wait(0.5)
    end
    unequipAll()

    if hasTool("Fake ID") then
        updateStatus("Apply gagal", Color3.fromRGB(255,80,80))
        return false
    end
    updateStatus("Apply ✔", Color3.fromRGB(0,220,100))
    task.wait(3)
    return true
end

-- ================================================================
-- PHASE 7 — BELI POTATO + FLOUR
-- ================================================================
local function phase_BuyPotatoFlour()
    setStep("[7] BELI POTATO + FLOUR")
    updateStatus("TP ke Chips Shop...", Color3.fromRGB(255,200,80))
    local ok = vehicleTP(CHIPS_BUY)
    if not ok then blinkTP(CHIPS_BUY, true) end
    task.wait(0.8)

    updateStatus("Beli Potato...", Color3.fromRGB(255,200,80))
    buyChipsIngredient(2, "Potato", 1)
    updateStatus("Beli Flour...", Color3.fromRGB(255,200,80))
    buyChipsIngredient(1, "Flour", 1)
    task.wait(0.5)
    return true
end

-- ================================================================
-- PHASE 8 — CHIPS MISSION
-- ================================================================
local function phase_ChipsMission()
    setStep("[8] CHIPS MISSION")
    updateStatus("Chips A...", Color3.fromRGB(255,200,80))
    vehicleTP(CHIPS_COORDS.A); task.wait(1.0)
    firePromptAt(CHIPS_COORDS.A, 8); task.wait(0.9)

    updateStatus("Insert Potato...", Color3.fromRGB(255,200,80))
    vehicleTP(CHIPS_COORDS.B); task.wait(1.0)
    equipTool("Potato"); task.wait(0.5)
    firePromptAt(CHIPS_COORDS.B, 8)
    waitUntilConsumed("Potato", 10); task.wait(3.5)

    updateStatus("Cook (C)...", Color3.fromRGB(255,200,80))
    vehicleTP(CHIPS_COORDS.C); task.wait(1.0)
    firePromptAt(CHIPS_COORDS.C, 8); task.wait(3.5)

    updateStatus("Insert Flour...", Color3.fromRGB(255,200,80))
    vehicleTP(CHIPS_COORDS.D); task.wait(1.0)
    equipTool("Flour"); task.wait(0.5)
    firePromptAt(CHIPS_COORDS.D, 8)
    waitUntilConsumed("Flour", 10); task.wait(3.5)

    local pot = CHIPS_POTS[ST.pot]
    updateStatus("Buka Pot — mulai cook...", Color3.fromRGB(255,200,80))
    vehicleTP(pot); task.wait(1.0)
    firePromptAt(pot, 8); task.wait(1.5)

    updateStatus("Chips cooking...", Color3.fromRGB(255,200,80))
    return true
end

-- ================================================================
-- PHASE 9 — SUGAR + GELATIN (47s)
-- ================================================================
local function phase_SugarGelatin()
    setStep("[9] SUGAR + GELATIN (47s)")
    updateStatus("TP ke apartment...", Color3.fromRGB(255,200,80))
    local ok = vehicleTP(ST.kitchenPos)
    if not ok then blinkTP(ST.kitchenPos, true) end
    task.wait(0.8)

    secureApartmentDoor(ST.doorPos)

    updateStatus("Tuang Sugar...", Color3.fromRGB(255,200,80))
    local att = 0
    while ST.running and getCount("Sugar Block Bag") > 0 and att < 20 do
        att = att + 1
        equipTool("Sugar Block Bag"); task.wait(0.25)
        firePromptAt(ST.kitchenPos, 12); task.wait(0.8)
    end

    updateStatus("Tuang Gelatin...", Color3.fromRGB(255,200,80))
    att = 0
    while ST.running and getCount("Gelatin") > 0 and att < 20 do
        att = att + 1
        equipTool("Gelatin"); task.wait(0.25)
        firePromptAt(ST.kitchenPos, 12); task.wait(0.8)
    end

    secureApartmentDoor(ST.doorPos)

    for i = 47, 1, -1 do
        if not ST.running then return false end
        updateStatus(("Masak marshmallow... %ds"):format(i), Color3.fromRGB(255,160,60))
        task.wait(1)
    end
    return true
end

-- ================================================================
-- PHASE 9B — COLLECT MARSHMALLOW (Empty Bag)
-- ================================================================
local function phase_CollectMarshmallow()
    setStep("[9b] COLLECT MARSHMALLOW")
    updateStatus("Ambil marshmallow...", Color3.fromRGB(255,180,100))

    secureApartmentDoor(ST.doorPos)

    local initialMarshmallows = getCount(M_BAGS)
    local timeout = 0
    local maxTimeout = 200

    while ST.running and getCount(M_BAGS) <= initialMarshmallows and timeout < maxTimeout do
        equipTool("Empty Bag")
        task.wait(0.25)
        firePromptAt(ST.kitchenPos, 12)
        task.wait(0.35)
        timeout = timeout + 1

        if timeout % 20 == 0 then
            updateStatus(("Ambil marshmallow... (%d attempts)"):format(timeout), Color3.fromRGB(255,180,100))
        end
    end

    local got = getCount(M_BAGS) - initialMarshmallows
    if got > 0 then
        updateStatus(("🍬 Dapat %d marshmallow ✔"):format(got), Color3.fromRGB(0,220,100))
        return true
    end
    updateStatus("⚠ Marshmallow gagal (door/state)", Color3.fromRGB(255,80,80))
    return false
end

-- ================================================================
-- PHASE 10 — SELL MARSHMALLOW
-- ================================================================
local function phase_SellMarshmallow()
    setStep("[10] SELL MARSHMALLOW")
    updateStatus("TP ke Shop (jual)...", Color3.fromRGB(0,220,100))
    local ok = vehicleTP(SHOP_POS)
    if not ok then blinkTP(SHOP_POS, true) end
    task.wait(0.8)

    for _, name in ipairs(M_BAGS) do
        while ST.running and hasTool(name) do
            local before = getCount(name)
            equipTool(name); task.wait(0.25)
            local char = LP.Character
            if char and char:FindFirstChild(name) then
                firePromptAt(SHOP_POS, 10); task.wait(0.4)
            else
                task.wait(0.2)
            end
            local after = getCount(name)
            if after < before then
                ST.marshmallowSold = ST.marshmallowSold + (before - after)
                updateLiveStatus()
            end
        end
    end
    updateStatus("Marshmallow sold ✔", Color3.fromRGB(0,220,100))
    task.wait(0.4)
    return true
end

-- ================================================================
-- PHASE 11 — CLAIM CARD
-- ================================================================
local function findCardPickup()
    local direct = Workspace:FindFirstChild("CardPickup")
    if direct then return direct end
    for _, v in ipairs({"Card Pickup","Card_Pickup","CardPickUp","cardpickup"}) do
        local f = Workspace:FindFirstChild(v)
        if f then return f end
    end
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("BasePart") or obj:IsA("Folder") then
            local n = obj.Name:lower():gsub("[%s_]", "")
            if n == "cardpickup" then return obj end
        end
    end
    return nil
end

local function getCardPos(card)
    if not card then return nil end
    if card:IsA("BasePart") then return card.Position end
    if card:IsA("Model") then
        local rp = card.PrimaryPart or card:FindFirstChildOfClass("BasePart")
        return rp and rp.Position
    end
    if card:IsA("Folder") then
        for _, c in pairs(card:GetChildren()) do
            if c:IsA("BasePart") then return c.Position end
        end
    end
    return nil
end

local function findPromptIn(obj)
    if not obj then return nil end
    for _, d in ipairs(obj:GetDescendants()) do
        if d:IsA("ProximityPrompt") then return d end
    end
    return nil
end

local function findPromptNear(pos, radius)
    radius = radius or 20
    local bestPrompt, bestDist = nil, radius
    for _, d in ipairs(Workspace:GetDescendants()) do
        if d:IsA("ProximityPrompt") then
            local p = d.Parent
            local pPos
            if p:IsA("Attachment") then pPos = p.WorldPosition
            elseif p:IsA("BasePart") then pPos = p.Position
            elseif p:IsA("Model") then
                local rp = p.PrimaryPart or p:FindFirstChildOfClass("BasePart")
                if rp then pPos = rp.Position end
            end
            if pPos then
                local dist = (pPos - pos).Magnitude
                if dist < bestDist then bestDist = dist; bestPrompt = d end
            end
        end
    end
    return bestPrompt, bestDist
end

local function phase_ClaimCard()
    if hasTool("Card") then return true end
    setStep("[11] CLAIM CARD")
    updateStatus("Cari CardPickup...", Color3.fromRGB(255,200,80))

    local card
    for i = 1, 30 do
        if not ST.running then return false end
        card = findCardPickup()
        if card then break end
        task.wait(0.5)
    end

    if not card then
        updateStatus("Fallback coord claim...", Color3.fromRGB(255,200,80))
        local ok = vehicleTP(CARD_FALLBACK_POS)
        if not ok then blinkTP(CARD_FALLBACK_POS, true) end
        task.wait(1)
        local pr = findPromptNear(CARD_FALLBACK_POS, 20)
        if pr then
            pcall(function()
                pr.HoldDuration = 0
                pr.RequiresLineOfSight = false
                pr.MaxActivationDistance = 9e9
            end)
            for i = 1, 20 do
                if not ST.running then return false end
                pcall(function() fireproximityprompt(pr) end)
                task.wait(0.6)
                if hasTool("Card") then
                    ST.cardSold = ST.cardSold + 1
                    updateLiveStatus()
                    updateStatus("Card ✔ (fallback)", Color3.fromRGB(0,220,100))
                    return true
                end
            end
        end
        updateStatus("Claim gagal", Color3.fromRGB(255,80,80))
        return false
    end

    local cardPos = getCardPos(card)
    local prompt = findPromptIn(card)
    if not cardPos or not prompt then
        updateStatus("Card object invalid", Color3.fromRGB(255,80,80))
        return false
    end

    pcall(function()
        prompt.HoldDuration = 0
        prompt.RequiresLineOfSight = false
        prompt.MaxActivationDistance = 9e9
    end)

    for i = 1, 15 do
        if not ST.running then return false end
        vehicleTP(cardPos)
        task.wait(0.5)
        pcall(function() fireproximityprompt(prompt) end)
        task.wait(0.6)
        if hasTool("Card") then
            ST.cardSold = ST.cardSold + 1
            updateLiveStatus()
            updateStatus("Card ✔", Color3.fromRGB(0,220,100))
            return true
        end
    end
    updateStatus("Claim Card gagal", Color3.fromRGB(255,80,80))
    return false
end

-- ================================================================
-- PHASE 12 — SWIPE ATM
-- ================================================================
local function findAvailableATM()
    local map = Workspace:FindFirstChild("Map")
    local atms = map and map:FindFirstChild("ATMS")
    if not atms then return nil end
    for _, a in pairs(atms:GetChildren()) do
        local screen = a:FindFirstChild("ATMScreen")
        if screen and screen.Transparency == 0 then return a end
    end
    return nil
end

local function phase_SwipeATM()
    setStep("[12] SWIPE ATM")
    updateStatus("Cari ATM...", Color3.fromRGB(255,200,80))
    local atm
    for i = 1, 20 do
        if not ST.running then return false end
        atm = findAvailableATM()
        if atm then break end
        task.wait(0.5)
    end
    if not atm then updateStatus("ATM tidak tersedia", Color3.fromRGB(255,80,80)); return false end

    local att = atm:FindFirstChild("Attachment")
    local prompt = att and att:FindFirstChild("ProximityPrompt")
    if not prompt then updateStatus("ATM prompt gak ada", Color3.fromRGB(255,80,80)); return false end
    pcall(function()
        prompt.HoldDuration = 0
        prompt.RequiresLineOfSight = false
        prompt.MaxActivationDistance = 9e9
    end)

    local oldATM = LP.PlayerGui:FindFirstChild("ATM")
    if oldATM then oldATM:Destroy() end

    for i = 1, 10 do
        if not ST.running then return false end
        vehicleTP(atm.Position); task.wait(0.4)
        pcall(function() fireproximityprompt(prompt) end)
        task.wait(0.4)
        if LP.PlayerGui:FindFirstChild("ATM") then break end
    end

    local atmGui = LP.PlayerGui:FindFirstChild("ATM")
    if not atmGui then updateStatus("ATM gagal buka", Color3.fromRGB(255,80,80)); return false end

    equipTool("Card"); task.wait(0.4)

    local frame = atmGui:FindFirstChild("Frame")
    local swipeBtn = frame and frame:FindFirstChild("Swipe")
    if not swipeBtn then updateStatus("Swipe btn gak ada", Color3.fromRGB(255,80,80)); return false end

    local clicked = false
    if replicatesignal then
        clicked = pcall(function() replicatesignal(swipeBtn.MouseButton1Click) end)
    end
    if not clicked then
        local pos, size = swipeBtn.AbsolutePosition, swipeBtn.AbsoluteSize
        if pos and size then
            VIM:SendMouseButtonEvent(pos.X + size.X/2, pos.Y + size.Y/2, 0, true, game, 0)
            task.wait(0.05)
            VIM:SendMouseButtonEvent(pos.X + size.X/2, pos.Y + size.Y/2, 0, false, game, 0)
        end
    end
    task.wait(0.6)
    unequipAll()
    updateStatus("Swipe ✔", Color3.fromRGB(0,220,100))
    return true
end

-- ================================================================
-- PHASE 13 — CLAIM CHIPS
-- ================================================================
local function phase_ClaimChips()
    setStep("[13] CLAIM CHIPS")
    local pot = CHIPS_POTS[ST.pot]
    updateStatus("TP ke pot claim...", Color3.fromRGB(255,200,80))
    local ok = vehicleTP(pot)
    if not ok then blinkTP(pot, true) end
    task.wait(1.0)

    local before = getCount({"Chips","Potato Chips"})
    firePromptAt(pot, 8)
    local t0 = os.clock()
    while ST.running and (os.clock() - t0) < 8 do
        if getCount({"Chips","Potato Chips"}) > before then break end
        task.wait(0.15)
    end
    task.wait(2.5)
    updateStatus("Chips ✔", Color3.fromRGB(0,220,100))
    return true
end

-- ================================================================
-- PHASE 14 — PANASIN → HOT CHIPS
-- ================================================================
local function phase_MakeHotChips()
    setStep("[14] PANASIN → HOT CHIPS")
    updateStatus("TP ke Tukar...", Color3.fromRGB(255,200,80))
    local ok = vehicleTP(SC_TUKAR)
    if not ok then blinkTP(SC_TUKAR, true) end
    task.wait(1.0)

    local attempts = 0
    while ST.running and getCount({"Chips","Potato Chips"}) > 0 and attempts < 30 do
        attempts = attempts + 1
        firePromptAt(SC_TUKAR, 30)
        task.wait(2.5)
    end
    updateStatus("Hot Chips ✔", Color3.fromRGB(255,160,60))
    return true
end

-- ================================================================
-- PHASE 15 — SELL HOMELESS (rotasi 1→12→1)
-- ================================================================
local function phase_SellHomeless()
    setStep("[15] SELL HOMELESS")
    local hotCount = getCount("Hot Chips")
    if hotCount <= 0 then return true end

    equipTool("Hot Chips"); task.wait(0.5)

    local safety, maxSafety = 0, hotCount + #SC_HOMELESS
    while ST.running and getCount("Hot Chips") > 0 and safety < maxSafety do
        safety = safety + 1
        local hIdx = ST.homelessIdx
        local hPos = SC_HOMELESS[hIdx]
        if not hPos then ST.homelessIdx = 1; hIdx = 1; hPos = SC_HOMELESS[1] end

        updateStatus(("Homeless #%d sisa %d"):format(hIdx, getCount("Hot Chips")), Color3.fromRGB(0,220,100))

        if not LP.Character:FindFirstChild("Hot Chips") then
            equipTool("Hot Chips"); task.wait(0.3)
        end

        local before = getCount("Hot Chips")
        vehicleTP(hPos)
        task.wait(0.6)
        firePromptAt(hPos, 30); task.wait(0.6)
        firePromptAt(hPos, 30); task.wait(0.4)
        local after = getCount("Hot Chips")
        if after < before then
            ST.chipsSold = ST.chipsSold + (before - after)
            updateLiveStatus()
        end

        ST.homelessIdx = ST.homelessIdx + 1
        if ST.homelessIdx > #SC_HOMELESS then ST.homelessIdx = 1 end
        task.wait(0.3)
    end

    if getCount("Hot Chips") > 0 then
        updateStatus(("Sisa %d Hot — balik Tukar"):format(getCount("Hot Chips")), Color3.fromRGB(255,160,60))
        vehicleTP(SC_TUKAR); task.wait(0.8)
    end
    return true
end

-- ================================================================
-- MAIN LOOP
-- ================================================================
local function mainLoop()
    while ST.running do
        ST.cycle = ST.cycle + 1
        pcall(function() CycleLabel.Text = "Cycle: " .. ST.cycle end)

        -- ========================================================
        -- FASE AWAL — HANYA CYCLE PERTAMA
        -- ========================================================
        if not ST.apartmentOwned then
            local bootPhases = {
                phase_BuyApartment,
                phase_GoToDealer,
                phase_WaitVehicle,
            }
            for _, fn in ipairs(bootPhases) do
                if not ST.running then break end
                local ok, err = pcall(fn)
                if not ok then
                    warn("[DarmHub] Boot error:", err)
                    updateStatus("Error: "..tostring(err), Color3.fromRGB(255,80,80))
                    task.wait(2)
                end
            end
            if not ST.running then break end
        end

        -- ========================================================
        -- FASE RUTIN — SETIAP CYCLE
        -- ========================================================
        local phases = {
            phase_BuyMarshmallowIngredients,
            phase_PourWater,
            phase_BuyFakeID,
            phase_ApplyCard,
            phase_BuyPotatoFlour,
            phase_ChipsMission,
            phase_SugarGelatin,
            phase_CollectMarshmallow,
            phase_SellMarshmallow,
            phase_ClaimCard,
            phase_SwipeATM,
            phase_ClaimChips,
            phase_MakeHotChips,
            phase_SellHomeless,
        }

        for _, fn in ipairs(phases) do
            if not ST.running then break end
            local ok, err = pcall(fn)
            if not ok then
                warn("[DarmHub] Phase error:", err)
                updateStatus("Error: "..tostring(err), Color3.fromRGB(255,80,80))
                task.wait(2)
            end
        end

        if not ST.running then break end
        updateStatus(("Cycle #%d selesai!"):format(ST.cycle), Color3.fromRGB(0,220,100))
        task.wait(2)
    end

    ST.running = false
    refreshToggle()
    updateStatus("Stopped", Color3.fromRGB(180,60,60))
    setStep("")
end

-- ================================================================
-- TOGGLE
-- ================================================================
ToggleBtn.MouseButton1Click:Connect(function()
    if not ST.running then
        ST.running = true
        ST.cycle = 0
        refreshToggle()
        updateStatus("Memulai...", Color3.fromRGB(100,255,180))
        task.spawn(mainLoop)
    else
        ST.running = false
        refreshToggle()
        updateStatus("Dihentikan manual", Color3.fromRGB(180,60,60))
    end
end)

updateStatus("Idle · Tekan ▶ untuk mulai", Color3.fromRGB(150,150,150))
print("[DARM HUB MULTI v3] Loaded ✔")