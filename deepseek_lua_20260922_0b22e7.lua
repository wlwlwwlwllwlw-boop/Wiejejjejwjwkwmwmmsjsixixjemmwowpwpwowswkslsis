-- ====================================================================
-- MULTI FARM v1 — ALL IN ONE
-- Flow: Buy Apt → Dealer → Vehicle → Beli Bahan Marshmallow → Tuang Air
--      → Buy FakeID → Apply Card → Buy Potato+Flour → Chips Mission
--      → Apt Tuang Sugar+Gelatin (47s) → Sell Marshmallow → Claim Card
--      → Swipe ATM → Claim Chips → Hot Chips → Homeless Sell → LOOP
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
    batchAmount  = 1,   -- jumlah batch marshmallow
}

-- ================================================================
-- KOORDINAT
-- ================================================================
-- Marshmallow / Shop / Dealer
local SHOP_POS   = Vector3.new(510.50, 4.5, 598.28)
local DEALER_POS = Vector3.new(730.24, 3.70, 449.47)

-- Chips
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

-- Card
local LOC_FakeID        = Vector3.new(214.960, 1.857, -332.330)
local LOC_ApplyForCard  = Vector3.new(-49.210, 4.000, -310.810)
local CARD_FALLBACK_POS = Vector3.new(-39.090, 5.392, -329.700)

-- Apartments
local ApartmentData = {
    { ID = 7,  BuyPos = Vector3.new(1197.11, 3.71, -237.50), DoorPos = Vector3.new(1199.14, 3.71, -243.04), KitchenPos = Vector3.new(1202.15, -2.29, -220.04) },
    { ID = 8,  BuyPos = Vector3.new(1196.79, 3.71, -201.87), DoorPos = Vector3.new(1199.00, 3.71, -207.04), KitchenPos = Vector3.new(1202.14, -2.29, -180.56) },
    { ID = 9,  BuyPos = Vector3.new(1185.65, 3.71, -207.83), DoorPos = Vector3.new(1183.52, 3.71, -202.90), KitchenPos = Vector3.new(1180.38, -2.29, -188.99) },
    { ID = 10, BuyPos = Vector3.new(1185.42, 3.71, -243.37), DoorPos = Vector3.new(1183.58, 3.71, -238.20), KitchenPos = Vector3.new(1180.41, -2.29, -227.24) }
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
-- STATUS UI (dibuat sebelum dipakai)
-- ================================================================
local Gui = Instance.new("ScreenGui")
Gui.Name = "MultiFarmUI"
Gui.ResetOnSpawn = false
Gui.DisplayOrder = 9999
Gui.Parent = UI_Target

local Main = Instance.new("Frame", Gui)
Main.Size = UDim2.new(0, 270, 0, 260)
Main.Position = UDim2.new(0.05, 0, 0.2, 0)
Main.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
local ms = Instance.new("UIStroke", Main)
ms.Color = Color3.fromRGB(0, 200, 100); ms.Thickness = 1.5

local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 32)
Header.BackgroundColor3 = Color3.fromRGB(10, 26, 16)
Header.BorderSizePixel = 0
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, -20, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🔁 MULTI FARM v1"
Title.TextColor3 = Color3.fromRGB(100, 255, 180)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 12
Title.TextXAlignment = Enum.TextXAlignment.Left

local Content = Instance.new("Frame", Main)
Content.Size = UDim2.new(1, -20, 1, -44)
Content.Position = UDim2.new(0, 10, 0, 40)
Content.BackgroundTransparency = 1
local Layout = Instance.new("UIListLayout", Content)
Layout.Padding = UDim.new(0, 6)
Layout.SortOrder = Enum.SortOrder.LayoutOrder

local ToggleBtn = Instance.new("TextButton", Content)
ToggleBtn.Size = UDim2.new(1, 0, 0, 40)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(35, 12, 12)
ToggleBtn.Text = "OFF"
ToggleBtn.TextColor3 = Color3.fromRGB(220, 80, 80)
ToggleBtn.Font = Enum.Font.GothamBlack
ToggleBtn.TextSize = 14
ToggleBtn.AutoButtonColor = false
ToggleBtn.LayoutOrder = 1
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 8)

local StatusLabel = Instance.new("TextLabel", Content)
StatusLabel.Size = UDim2.new(1, 0, 0, 18)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Status: Idle"
StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.TextSize = 11
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.LayoutOrder = 2

local CycleLabel = Instance.new("TextLabel", Content)
CycleLabel.Size = UDim2.new(1, 0, 0, 16)
CycleLabel.BackgroundTransparency = 1
CycleLabel.Text = "Cycle: 0"
CycleLabel.TextColor3 = Color3.fromRGB(150, 180, 220)
CycleLabel.Font = Enum.Font.GothamBold
CycleLabel.TextSize = 11
CycleLabel.TextXAlignment = Enum.TextXAlignment.Left
CycleLabel.LayoutOrder = 3

local StepLabel = Instance.new("TextLabel", Content)
StepLabel.Size = UDim2.new(1, 0, 0, 60)
StepLabel.BackgroundTransparency = 1
StepLabel.Text = ""
StepLabel.TextColor3 = Color3.fromRGB(140, 200, 255)
StepLabel.Font = Enum.Font.Code
StepLabel.TextSize = 10
StepLabel.TextWrapped = true
StepLabel.TextXAlignment = Enum.TextXAlignment.Left
StepLabel.TextYAlignment = Enum.TextYAlignment.Top
StepLabel.LayoutOrder = 4

local function updateStatus(txt, col)
    pcall(function()
        StatusLabel.Text = "Status: " .. tostring(txt)
        if col then StatusLabel.TextColor3 = col end
    end)
end
local function setStep(txt)
    ST.step = txt
    pcall(function() StepLabel.Text = txt end)
end
local function refreshToggle()
    local on = ST.running
    ToggleBtn.BackgroundColor3 = on and Color3.fromRGB(10, 45, 25) or Color3.fromRGB(35, 12, 12)
    ToggleBtn.TextColor3 = on and Color3.fromRGB(100, 255, 180) or Color3.fromRGB(220, 80, 80)
    ToggleBtn.Text = on and "🔁 ON" or "OFF"
end
refreshToggle()

-- ================================================================
-- GHOST MODE (nembus tembok)
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
-- DISCRETE STEP TP (untuk blink underground)
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

-- Blink underground (nembus lantai/dinding)
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

-- BypassTP (buat beli apartment — butuh respawn biar masuk)
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

-- Marshmallow shop: cat=24 sub=19
local function buyMarshmallowIngredient(arg, targetItemName, target)
    -- arg: 1=Gelatin, 2=Sugar, 3=Water
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

-- Chips shop: cat=24 sub=21 (arg: 1=Flour, 2=Potato)
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
    -- Lock door
    for i = 1, 5 do
        if not ST.running then return false end
        firePromptAt(targetData.DoorPos, 8, "lock")
        task.wait(0.4)
    end
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
    if not ok then updateStatus("TP shop gagal: "..tostring(err), Color3.fromRGB(255,80,80)); return false end
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
-- PHASE 4 — TUANG AIR (START COOKING WATER)
-- ================================================================
local function phase_PourWater()
    setStep("[4] TUANG AIR (start cook)")
    updateStatus("TP ke apartment...", Color3.fromRGB(255,200,80))
    local ok, err = vehicleTP(ST.kitchenPos)
    if not ok then updateStatus("TP apt gagal: "..tostring(err), Color3.fromRGB(255,80,80)); return false end
    task.wait(0.8)

    -- Equip water & prompt
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
    return true
end

-- ================================================================
-- PHASE 5 — BELI FAKE ID
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
    if not ok then
        -- coba lewat blink (jika vehicleTP gagal karena belum naik motor)
        blinkTP(LOC_FakeID, true)
    end
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

    -- Tunggu approval (best effort, jangan block lama)
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
-- PHASE 8 — CHIPS MISSION (start cooking)
-- ================================================================
local function phase_ChipsMission()
    setStep("[8] CHIPS MISSION")
    -- Step A
    updateStatus("Chips A...", Color3.fromRGB(255,200,80))
    vehicleTP(CHIPS_COORDS.A); task.wait(1.0)
    firePromptAt(CHIPS_COORDS.A, 8); task.wait(0.9)

    -- Step B — Insert Potato
    updateStatus("Insert Potato...", Color3.fromRGB(255,200,80))
    vehicleTP(CHIPS_COORDS.B); task.wait(1.0)
    equipTool("Potato"); task.wait(0.5)
    firePromptAt(CHIPS_COORDS.B, 8)
    waitUntilConsumed("Potato", 10); task.wait(3.5)

    -- Step C — Cook
    updateStatus("Cook (C)...", Color3.fromRGB(255,200,80))
    vehicleTP(CHIPS_COORDS.C); task.wait(1.0)
    firePromptAt(CHIPS_COORDS.C, 8); task.wait(3.5)

    -- Step D — Insert Flour
    updateStatus("Insert Flour...", Color3.fromRGB(255,200,80))
    vehicleTP(CHIPS_COORDS.D); task.wait(1.0)
    equipTool("Flour"); task.wait(0.5)
    firePromptAt(CHIPS_COORDS.D, 8)
    waitUntilConsumed("Flour", 10); task.wait(3.5)

    -- Buka Pot (start cook 60s)
    local pot = CHIPS_POTS[ST.pot]
    updateStatus("Buka Pot — mulai cook...", Color3.fromRGB(255,200,80))
    vehicleTP(pot); task.wait(1.0)
    firePromptAt(pot, 8); task.wait(1.5)

    updateStatus("Chips cooking...", Color3.fromRGB(255,200,80))
    return true
end

-- ================================================================
-- PHASE 9 — APT: TUANG SUGAR + GELATIN, TUNGGU 47s
-- ================================================================
local function phase_SugarGelatin()
    setStep("[9] SUGAR + GELATIN (47s)")
    updateStatus("TP ke apartment...", Color3.fromRGB(255,200,80))
    local ok = vehicleTP(ST.kitchenPos)
    if not ok then blinkTP(ST.kitchenPos, true) end
    task.wait(0.8)

    -- Sugar
    updateStatus("Tuang Sugar...", Color3.fromRGB(255,200,80))
    local att = 0
    while ST.running and getCount("Sugar Block Bag") > 0 and att < 20 do
        att = att + 1
        equipTool("Sugar Block Bag"); task.wait(0.25)
        firePromptAt(ST.kitchenPos, 12); task.wait(0.8)
    end

    -- Gelatin
    updateStatus("Tuang Gelatin...", Color3.fromRGB(255,200,80))
    att = 0
    while ST.running and getCount("Gelatin") > 0 and att < 20 do
        att = att + 1
        equipTool("Gelatin"); task.wait(0.25)
        firePromptAt(ST.kitchenPos, 12); task.wait(0.8)
    end

    -- Tunggu 47 detik
    for i = 47, 1, -1 do
        if not ST.running then return false end
        updateStatus(("Masak marshmallow... %ds"):format(i), Color3.fromRGB(255,160,60))
        task.wait(1)
    end
    return true
end

-- ================================================================
-- PHASE 10 — SELL MARSHMALLOW
-- ================================================================
local M_BAGS = {
    "Marshmallow", "Marshmellow",
    "Large Marshmallow Bag", "Large Marshmellow Bag",
    "Medium Marshmallow Bag", "Medium Marshmellow Bag",
    "Small Marshmallow Bag", "Small Marshmellow Bag"
}

local function phase_SellMarshmallow()
    setStep("[10] SELL MARSHMALLOW")
    updateStatus("TP ke Shop (jual)...", Color3.fromRGB(0,220,100))
    local ok = vehicleTP(SHOP_POS)
    if not ok then blinkTP(SHOP_POS, true) end
    task.wait(0.8)

    for _, name in ipairs(M_BAGS) do
        while ST.running and hasTool(name) do
            equipTool(name); task.wait(0.25)
            local char = LP.Character
            if char and char:FindFirstChild(name) then
                firePromptAt(SHOP_POS, 10); task.wait(0.4)
            else
                task.wait(0.2)
            end
        end
    end
    updateStatus("Marshmallow sold ✔", Color3.fromRGB(0,220,100))
    task.wait(0.4)
    return true
end

-- ================================================================
-- PHASE 11 — CLAIM CARD + SWIPE ATM
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
        -- Fallback
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
            updateStatus("Card ✔", Color3.fromRGB(0,220,100))
            return true
        end
    end
    updateStatus("Claim Card gagal", Color3.fromRGB(255,80,80))
    return false
end

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
-- PHASE 13 — CLAIM HOT CHIPS (dari pot) + PANASIN di SC_TUKAR
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

        local phases = {
            phase_BuyApartment,
            phase_GoToDealer,
            phase_WaitVehicle,
            phase_BuyMarshmallowIngredients,
            phase_PourWater,
            phase_BuyFakeID,
            phase_ApplyCard,
            phase_BuyPotatoFlour,
            phase_ChipsMission,
            phase_SugarGelatin,
            phase_SellMarshmallow,
            phase_ClaimCard,
            phase_SwipeATM,
            phase_ClaimChips,
            phase_MakeHotChips,
            phase_SellHomeless,
        }

        local allOK = true
        for _, fn in ipairs(phases) do
            if not ST.running then allOK = false; break end
            local ok, err = pcall(fn)
            if not ok then
                warn("[MultiFarm] Phase error:", err)
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

updateStatus("Idle · Tekan OFF untuk mulai", Color3.fromRGB(150,150,150))
print("[MULTI FARM v1] Loaded — Flow lengkap siap dipakai.")