-- ============================================================
--  ⚡ DARM HUB MULTI FARM  —  FULL INTEGRATED SCRIPT
--  Boot (Apartment + Dealer/Motor) → Cycle (15 step) → Loop
--  Sumber: fully.lua + card scam.lua + chips farm.lua
-- ============================================================
if not game:IsLoaded() then game.Loaded:Wait() end

-- ============================================================
-- 1. SERVICES
-- ============================================================
local Players            = game:GetService("Players")
local Workspace          = game:GetService("Workspace")
local ReplicatedStorage  = game:GetService("ReplicatedStorage")
local CoreGui            = game:GetService("CoreGui")
local UIS                = game:GetService("UserInputService")
local RunService         = game:GetService("RunService")
local VIM                = game:GetService("VirtualInputManager")
local TweenService       = game:GetService("TweenService")
local VirtualUser        = game:GetService("VirtualUser")
local ProximityPromptSvc = game:GetService("ProximityPromptService")

while not Players.LocalPlayer do task.wait(0.1) end
local LP = Players.LocalPlayer

pcall(function()
    LP.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Invisicam
end)

local UI_Target = (gethui and gethui()) or CoreGui or LP:WaitForChild("PlayerGui")
local oldUI = UI_Target:FindFirstChild("DarmHubMulti_UI")
if oldUI then oldUI:Destroy() end
getgenv().DARM_HUB_LOADED = true

-- ============================================================
-- 2. GLOBAL RUNTIME STATE
-- ============================================================
local STATE = {
    running        = false,
    bootCompleted  = false,
    cycle          = 0,
    step           = "",
    vehicleReady   = false,
    apartmentOwned = false,
    homelessIndex  = 1,
    potIndex       = 1,
    stopRequested  = false,
    apartmentId    = nil,
    kitchenPos     = nil,
    doorPos        = nil,
    buyPos         = nil,
    counters = { marshmallowSold = 0, chipsSold = 0, cardSold = 0 },
    lastError = "-",
}

local COOK_STATE = {
    chips       = { active = false, startedAt = 0, duration = 60 },
    marshmallow = { active = false, startedAt = 0, duration = 47 },
}

local THREADS     = {}
local CONNECTIONS = {}
local originalGravity = Workspace.Gravity

local function trackThread(t)
    table.insert(THREADS, t)
    return t
end

local function trackConn(c)
    table.insert(CONNECTIONS, c)
    return c
end

local function killAllThreads()
    for _, t in ipairs(THREADS) do
        pcall(function() if task.cancel then task.cancel(t) end end)
    end
    THREADS = {}
end

local function killAllConns()
    for _, c in ipairs(CONNECTIONS) do
        pcall(function() c:Disconnect() end)
    end
    CONNECTIONS = {}
end

-- ============================================================
-- 3. CONFIGURATION
-- ============================================================
local CFG = {
    MAX_SPEED   = 150,
    HOP_DIST    = 15,
    MIN_DELAY   = 0.04,
    MAX_DELAY   = 0.5,
    PROMPT_DIST = 30,

    COOK_CHIPS_TIME = 60,
    COOK_MARSH_TIME = 47,

    DELAY = {
        afterTP      = 0.9,
        equipSettle  = 0.5,
        promptFire   = 0.4,
        insertPotato = 3.5,
        cookProcess  = 3.5,
        insertFlour  = 3.5,
        potOpen      = 1.2,
        claimChips   = 2.5,
        panasinWait  = 2.5,
        sellWait     = 0.6,
        afterSell    = 0.4,
    },

    RETRY = {
        default   = 5,
        prompt    = 8,
        inventory = 12,
        vehicle   = 60,
        approval  = 60,
    },

    BATCH = 1,
}

-- ============================================================
-- 4. COORDINATES
-- ============================================================
-- fully.lua
local shopPos   = Vector3.new(510.50, 4.5, 598.28)
local sellPos   = shopPos
local DEALER_POS = Vector3.new(730.24, 3.70, 449.47)

local ApartmentData = {
    { ID = 7,  BuyPos = Vector3.new(1197.11, 3.71, -237.50), DoorPos = Vector3.new(1199.14, 3.71, -243.04), KitchenPos = Vector3.new(1202.15, -2.29, -220.04) },
    { ID = 8,  BuyPos = Vector3.new(1196.79, 3.71, -201.87), DoorPos = Vector3.new(1199.00, 3.71, -207.04), KitchenPos = Vector3.new(1202.14, -2.29, -180.56) },
    { ID = 9,  BuyPos = Vector3.new(1185.65, 3.71, -207.83), DoorPos = Vector3.new(1183.52, 3.71, -202.90), KitchenPos = Vector3.new(1180.38, -2.29, -188.99) },
    { ID = 10, BuyPos = Vector3.new(1185.42, 3.71, -243.37), DoorPos = Vector3.new(1183.58, 3.71, -238.20), KitchenPos = Vector3.new(1180.41, -2.29, -227.24) },
}

-- card scam.lua
local LOC_FakeID        = Vector3.new( 214.960, 1.857, -332.330)
local LOC_ApplyForCard  = Vector3.new( -49.210, 4.000, -310.810)
local CARD_FALLBACK_POS = Vector3.new( -39.090, 5.392, -329.700)

-- chips farm.lua
local BUY_LOC = Vector3.new(-759.197, 3.489, -194.846)

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
local SC_COOK  = Vector3.new(-487.11, 3.86, -454.16)

local IDX_FLOUR  = 1
local IDX_POTATO = 2

local M_BAGS = {
    "Marshmallow", "Marshmellow", "Large Marshmallow Bag", "Large Marshmellow Bag",
    "Medium Marshmallow Bag", "Medium Marshmellow Bag", "Small Marshmallow Bag", "Small Marshmellow Bag"
}

-- ============================================================
-- 5. INVENTORY MANAGER
-- ============================================================
local function countTool(nameOrList)
    local c = 0
    local char = LP.Character
    local bp = LP:FindFirstChild("Backpack")

    local function scan(container)
        if not container then return end
        for _, item in ipairs(container:GetChildren()) do
            if item:IsA("Tool") then
                if type(nameOrList) == "table" then
                    for _, n in ipairs(nameOrList) do
                        if item.Name == n then c = c + 1; break end
                    end
                elseif item.Name == nameOrList then
                    c = c + 1
                end
            end
        end
    end

    scan(char); scan(bp)
    return c
end

local function hasTool(n) return countTool(n) > 0 end

local function equipTool(name)
    local char = LP.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return false end

    if char:FindFirstChild(name) then return true end
    hum:UnequipTools()
    task.wait(0.1)

    local bp = LP:FindFirstChild("Backpack")
    if not bp then return false end
    local tool = bp:FindFirstChild(name)
    if not tool then
        for _, v in ipairs(bp:GetChildren()) do
            if v:IsA("Tool") and v.Name:lower():find(name:lower()) then
                tool = v; break
            end
        end
    end
    if not tool then return false end
    pcall(function() hum:EquipTool(tool) end)
    local t0 = os.clock()
    while os.clock() - t0 < 1.5 do
        if char:FindFirstChild(tool.Name) then
            task.wait(0.1); return true
        end
        task.wait(0.05)
    end
    return true
end

local function unequipAll()
    local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if hum then pcall(function() hum:UnequipTools() end) end
end

local function countChips()
    local a = countTool("Chips")
    if a > 0 then return a end
    return countTool("Potato Chips")
end

local function getFakeIDCount()
    return countTool("Fake ID")
end

-- ============================================================
-- 6. PROMPT MANAGER
-- ============================================================
local function getPromptPos(prompt)
    local parent = prompt.Parent
    if not parent then return nil end
    if parent:IsA("BasePart") then return parent.Position end
    if parent:IsA("Attachment") then return parent.WorldPosition end
    if parent:IsA("Model") then
        local rp = parent.PrimaryPart or parent:FindFirstChildOfClass("BasePart")
        if rp then return rp.Position end
    end
    if parent:IsA("Folder") then
        local rp = parent:FindFirstChildOfClass("BasePart")
        if rp then return rp.Position end
    end
    return nil
end

local function matchPromptText(actionText, keyword)
    if not keyword then return true end
    local t = string.lower(actionText or "")
    keyword = string.lower(keyword)
    if keyword == "lock" and t:find("unlock") then return false end
    return t:find(keyword) ~= nil
end

local function firePromptAt(pos, maxDist, keyword)
    maxDist = maxDist or CFG.PROMPT_DIST
    local best, bestDist = nil, maxDist
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and obj.Enabled then
            local pPos = getPromptPos(obj)
            if pPos then
                local d = (pos - pPos).Magnitude
                if d <= bestDist and matchPromptText(obj.ActionText, keyword) then
                    bestDist = d; best = obj
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

local function checkPromptExistsAt(pos, maxDist, keyword)
    maxDist = maxDist or CFG.PROMPT_DIST
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and obj.Enabled then
            local pPos = getPromptPos(obj)
            if pPos and (pos - pPos).Magnitude <= maxDist
               and matchPromptText(obj.ActionText, keyword) then
                return true
            end
        end
    end
    return false
end

-- Prompt instant
local function makePromptInstant(p)
    if p and p:IsA("ProximityPrompt") then
        p.HoldDuration = 0
        p.RequiresLineOfSight = false
    end
end
for _, o in ipairs(Workspace:GetDescendants()) do makePromptInstant(o) end
trackConn(Workspace.DescendantAdded:Connect(makePromptInstant))
trackConn(ProximityPromptSvc.PromptShown:Connect(makePromptInstant))

-- ============================================================
-- 7. VEHICLE MANAGER  (unified hopTP)
-- ============================================================
local tpBusy = false

local function VehicleTP(targetPos)
    if tpBusy then return false, "Busy" end
    if STATE.stopRequested then return false, "Stopped" end

    local char = LP.Character
    if not char then return false, "No character" end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false, "Dead" end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false, "No HRP" end

    tpBusy = true
    startGhostMode()

    local seat    = hum.SeatPart
    local vehicle = seat and seat:FindFirstAncestorOfClass("Model")
    local vRoot   = vehicle and (vehicle.PrimaryPart or seat)

    if not vehicle then
        hum.PlatformStand = true
        Workspace.Gravity = 0
    end

    local startPos, rot, tempWeld
    local target = targetPos + Vector3.new(0, 3, 0)

    if vehicle and vRoot then
        pcall(function()
            tempWeld = Instance.new("WeldConstraint")
            tempWeld.Part0 = hrp
            tempWeld.Part1 = seat
            tempWeld.Parent = hrp
        end)
        pcall(function()
            vRoot.AssemblyLinearVelocity  = Vector3.zero
            vRoot.AssemblyAngularVelocity = Vector3.zero
            hrp.AssemblyLinearVelocity    = Vector3.zero
            hrp.AssemblyAngularVelocity   = Vector3.zero
        end)
        task.wait(0.05)
        startPos = vRoot.Position
        rot      = vRoot.CFrame.Rotation
    else
        startPos = hrp.Position
        rot      = hrp.CFrame.Rotation
    end

    local total = (target - startPos).Magnitude
    local hops  = math.max(1, math.ceil(total / CFG.HOP_DIST))
    local delay = math.clamp(CFG.HOP_DIST / CFG.MAX_SPEED, CFG.MIN_DELAY, CFG.MAX_DELAY)

    for i = 1, hops do
        if STATE.stopRequested or not STATE.running then break end
        local t = i / hops
        local stepPos = startPos:Lerp(target, t)

        if vehicle and vRoot then
            pcall(function() vehicle:PivotTo(CFrame.new(stepPos) * rot) end)
            pcall(function()
                if hrp.Parent and seat.Parent then
                    hrp.CFrame = seat.CFrame * CFrame.new(0, 1.5, 0)
                    hrp.AssemblyLinearVelocity  = Vector3.zero
                    hrp.AssemblyAngularVelocity = Vector3.zero
                end
                if vRoot.Parent then
                    vRoot.AssemblyLinearVelocity  = Vector3.zero
                    vRoot.AssemblyAngularVelocity = Vector3.zero
                end
            end)
        else
            pcall(function()
                hrp.CFrame = CFrame.new(stepPos) * rot
                hrp.AssemblyLinearVelocity  = Vector3.zero
                hrp.AssemblyAngularVelocity = Vector3.zero
            end)
        end
        task.wait(delay)
    end

    if vehicle and vRoot then
        pcall(function() vehicle:PivotTo(CFrame.new(target) * rot) end)
        task.wait(0.15)
        pcall(function()
            if hrp.Parent and seat.Parent then
                hrp.CFrame = seat.CFrame * CFrame.new(0, 1.5, 0)
                hrp.AssemblyLinearVelocity  = Vector3.zero
                hrp.AssemblyAngularVelocity = Vector3.zero
            end
        end)
        pcall(function()
            if tempWeld and tempWeld.Parent then tempWeld:Destroy() end
        end)
    else
        pcall(function()
            hrp.CFrame = CFrame.new(target) * rot
            hrp.AssemblyLinearVelocity  = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
        end)
        Workspace.Gravity = originalGravity
        if hum then hum.PlatformStand = false end
    end

    stopGhostMode()
    tpBusy = false
    return true, "OK"
end

-- ============================================================
-- 8. TELEPORT MANAGER  (ghost mode + bypass)
-- ============================================================
local modifiedParts = {}
local ghostConn = nil

function startGhostMode()
    if ghostConn then return end
    ghostConn = RunService.Heartbeat:Connect(function()
        local char = LP.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local hum = char:FindFirstChild("Humanoid")
        if hum and hum.Sit then return end
        local hrp = char.HumanoidRootPart

        local function process(part)
            if not part or not part:IsA("BasePart") or part:IsA("Terrain") then return end
            if part:IsDescendantOf(char) then return end
            if part:IsA("Seat") or part:IsA("VehicleSeat")
               or part.Name:lower():find("seat") then return end
            if not modifiedParts[part] then
                modifiedParts[part] = { CanCollide = part.CanCollide, CanTouch = part.CanTouch }
            end
            part.CanCollide = false
            part.CanTouch   = false
        end

        for _, p in ipairs(hrp:GetTouchingParts()) do process(p) end

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
            local r = Workspace:Raycast(hrp.Position, dir, params)
            if r and r.Instance then process(r.Instance) end
        end
    end)
end

function stopGhostMode()
    if ghostConn then ghostConn:Disconnect(); ghostConn = nil end
    for part, s in pairs(modifiedParts) do
        if part and part.Parent then
            pcall(function()
                part.CanCollide = s.CanCollide
                part.CanTouch   = s.CanTouch
            end)
        end
    end
    modifiedParts = {}
end

-- ============================================================
-- 9. APARTMENT MANAGER
-- ============================================================
local function BypassTP(targetPos)
    local char = LP.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
        local bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Velocity = Vector3.new(0, 9e9, 0)
        bv.Parent = hrp
    end
    local newChar = LP.CharacterAdded:Wait()
    local newHrp  = newChar:WaitForChild("HumanoidRootPart", 10)
    if newHrp then
        task.wait(0.5)
        newHrp.CFrame = CFrame.new(targetPos)
    end
    task.wait(1.2)
end

local function secureDoor(doorPos)
    for i = 1, 10 do
        if STATE.stopRequested then return false end
        if checkPromptExistsAt(doorPos, 8, "unlock") then return true end
        if checkPromptExistsAt(doorPos, 8, "lock") then
            firePromptAt(doorPos, 8, "lock")
            task.wait(0.5)
            if checkPromptExistsAt(doorPos, 8, "unlock") then return true end
            firePromptAt(doorPos, 8, "open")
            task.wait(0.7)
        else
            firePromptAt(doorPos, 8, "open")
            task.wait(0.5)
        end
    end
    return false
end

local function findVacantApartment()
    for _, data in ipairs(ApartmentData) do
        if STATE.stopRequested then return nil end
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("TextLabel") and obj.Text:upper():find("VACANT") then
                local gui   = obj:FindFirstAncestorOfClass("SurfaceGui") or obj:FindFirstAncestorOfClass("BillboardGui")
                local part  = gui and (gui.Adornee or gui.Parent)
                if part and part:IsA("BasePart")
                   and (part.Position - data.BuyPos).Magnitude <= 5 then
                    return data
                end
            end
        end
    end
    return nil
end

local function detectOwnedApartment()
    -- Cari door unlocked = kemungkinan milik sendiri. Fallback: pakai ID 7.
    for _, data in ipairs(ApartmentData) do
        if checkPromptExistsAt(data.DoorPos, 6, "unlock") then
            return data
        end
    end
    return nil
end

local function BuyApartment()
    uiStatus("BUY APARTMENT...")
    local target = findVacantApartment()
    if not target then
        STATE.lastError = "No vacant apartment"
        uiStatus("No Vacant Apt!", Color3.fromRGB(255,80,80))
        return false
    end

    BypassTP(target.BuyPos)
    if STATE.stopRequested then return false end
    firePromptAt(target.BuyPos, 5, "purchase")
    task.wait(1)

    STATE.apartmentId    = target.ID
    STATE.kitchenPos     = target.KitchenPos
    STATE.doorPos        = target.DoorPos
    STATE.buyPos         = target.BuyPos
    STATE.apartmentOwned = true

    -- TP ke door
    VehicleTP(target.DoorPos)
    task.wait(0.8)
    secureDoor(target.DoorPos)
    return true
end

-- ============================================================
-- 10. CARD MANAGER
-- ============================================================
local RE
pcall(function()
    RE = ReplicatedStorage:WaitForChild("RemoteEvents", 10)
        :WaitForChild("ReliableRemoteEvent", 10)
end)

local function findFakeIDSellerPrompt()
    local folders = Workspace:FindFirstChild("Folders")
    if not folders then return nil end
    local npcs = folders:FindFirstChild("NPCs")
    if not npcs then return nil end
    local seller = npcs:FindFirstChild("FakeIDSeller")
    if not seller then return nil end
    for _, d in ipairs(seller:GetDescendants()) do
        if d:IsA("ProximityPrompt") then return d end
    end
    return nil
end

local function findBankTellerPrompt()
    local folders = Workspace:FindFirstChild("Folders")
    if not folders then return nil end
    local npcs = folders:FindFirstChild("NPCs")
    if not npcs then return nil end
    local teller = npcs:FindFirstChild("Bank Teller")
    if not teller then return nil end
    local upper = teller:FindFirstChild("UpperTorso")
    local att = upper and upper:FindFirstChild("Attachment")
    return att and att:FindFirstChild("ProximityPrompt")
end

local function checkApprovalNotif()
    local mainGui = LP.PlayerGui:FindFirstChild("Main")
    local notif = mainGui and mainGui:FindFirstChild("BasicNotification")
    if not notif then return nil end
    if notif.TextTransparency > 0 then return nil end
    local lower = notif.Text:lower()
    if lower:find("not success") or lower:find("denied")
       or lower:find("reject") or lower:find("failed") then
        return false, notif.Text
    end
    if lower:find("successful") or lower:find("approved")
       or lower:find("accepted") then
        return true, notif.Text
    end
    return nil, notif.Text
end

local function findCardPickup()
    local direct = Workspace:FindFirstChild("CardPickup")
    if direct then return direct end
    for _, v in ipairs({"Card Pickup","Card_Pickup","CardPickUp","Cardpickup"}) do
        local f = Workspace:FindFirstChild(v)
        if f then return f end
    end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("BasePart") or obj:IsA("Folder") then
            local n = obj.Name:lower():gsub("[%s_]", "")
            if n == "cardpickup" then return obj end
        end
    end
    return nil
end

local function getObjPos(obj)
    if not obj then return nil end
    if obj:IsA("BasePart") then return obj.Position end
    if obj:IsA("Model") then
        local rp = obj.PrimaryPart or obj:FindFirstChildOfClass("BasePart")
        return rp and rp.Position
    end
    if obj:IsA("Folder") then
        for _, c in ipairs(obj:GetChildren()) do
            if c:IsA("BasePart") then return c.Position end
        end
    end
    return nil
end

local function findAvailableATM()
    local map = Workspace:FindFirstChild("Map")
    local atms = map and map:FindFirstChild("ATMS")
    if not atms then return nil end
    for _, a in ipairs(atms:GetChildren()) do
        local screen = a:FindFirstChild("ATMScreen")
        if screen and screen.Transparency == 0 then return a end
    end
    return nil
end

-- ============================================================
-- 11. CHIPS MANAGER
-- ============================================================
local function fireBuyIndex(index)
    if not RE then return false end
    return (pcall(function()
        local buf = buffer.create(3)
        buffer.writeu8(buf, 0, 24)
        buffer.writeu8(buf, 1, 21)
        buffer.writeu8(buf, 2, index)
        RE:FireServer(buf)
    end))
end

local function buyUntilEnough(index, name, target, maxAttempts)
    maxAttempts = maxAttempts or 40
    if countTool(name) >= target then return true end
    local attempt = 0
    while STATE.running and not STATE.stopRequested and attempt < maxAttempts do
        attempt = attempt + 1
        if not fireBuyIndex(index) then return false end
        local deadline = os.clock() + 2.5
        repeat task.wait(0.08)
        until countTool(name) >= target or os.clock() > deadline
        if countTool(name) >= target then return true end
        task.wait(0.2)
    end
    return countTool(name) >= target
end

local function waitUntilConsumed(name, timeout)
    timeout = timeout or 10
    local before = countTool(name)
    if before <= 0 then return true end
    local t0 = os.clock()
    while STATE.running and not STATE.stopRequested
          and (os.clock() - t0) < timeout do
        if countTool(name) < before then
            task.wait(0.4); return true
        end
        task.wait(0.1)
    end
    return false
end

-- ============================================================
-- 12. MARSHMALLOW MANAGER  (buy via remote)
-- ============================================================
local function buyIngredientRemote(idx)
    if not RE then return false end
    return (pcall(function()
        local buf = buffer.create(3)
        buffer.writeu8(buf, 0, 24)
        buffer.writeu8(buf, 1, 19)
        buffer.writeu8(buf, 2, idx)
        RE:FireServer(buf)
    end))
end

local function robustBuyIngredients(target)
    target = target or CFG.BATCH
    local attempt = 0
    while STATE.running and not STATE.stopRequested and attempt < 60 do
        attempt = attempt + 1
        local w = countTool({"Water","Water23"})
        local s = countTool("Sugar Block Bag")
        local g = countTool("Gelatin")
        if w >= target and s >= target and g >= target then return true end
        if g < target then buyIngredientRemote(1); task.wait(0.3) end
        if s < target then buyIngredientRemote(2); task.wait(0.3) end
        if w < target then buyIngredientRemote(3); task.wait(0.3) end
        task.wait(0.3)
    end
    return countTool({"Water","Water23"}) >= target
        and countTool("Sugar Block Bag") >= target
        and countTool("Gelatin") >= target
end

local function putIngredient(toolNameOrList, waitAfter)
    if not STATE.running or STATE.stopRequested then return false end
    if not STATE.kitchenPos then return false end
    local initial = countTool(toolNameOrList)
    if initial == 0 then return false end
    local attempts = 0
    while STATE.running and not STATE.stopRequested
          and countTool(toolNameOrList) >= initial
          and attempts < 30 do
        if type(toolNameOrList) == "table" then
            for _, n in ipairs(toolNameOrList) do
                if countTool(n) > 0 then equipTool(n); break end
            end
        else
            equipTool(toolNameOrList)
        end
        task.wait(0.2)
        firePromptAt(STATE.kitchenPos, 10)
        task.wait(1.2)
        attempts = attempts + 1
    end
    local ok = countTool(toolNameOrList) < initial
    if ok and waitAfter and waitAfter > 0 then
        COOK_STATE.marshmallow.active    = true
        COOK_STATE.marshmallow.startedAt = os.clock()
        COOK_STATE.marshmallow.duration  = waitAfter
        local t0 = os.clock()
        while STATE.running and not STATE.stopRequested
              and (os.clock() - t0) < waitAfter do
            task.wait(0.5)
        end
        COOK_STATE.marshmallow.active = false
    end
    return ok
end

local function collectMarshmallow()
    if not STATE.kitchenPos then return false end
    local before = countTool(M_BAGS)
    local timeout = 0
    while STATE.running and not STATE.stopRequested
          and countTool(M_BAGS) <= before and timeout < 60 do
        equipTool("Empty Bag")
        firePromptAt(STATE.kitchenPos, 12)
        task.wait(0.3)
        timeout = timeout + 1
    end
    if countTool(M_BAGS) > before then
        if countTool({"Water","Water23"}) > 0 then equipTool("Water") end
        return true
    end
    return false
end

local function sellAllMarshmallow()
    if not STATE.running or STATE.stopRequested then return 0 end
    local sold = 0
    for _, name in ipairs(M_BAGS) do
        while hasTool(name) and STATE.running and not STATE.stopRequested do
            local before = countTool(name)
            equipTool(name)
            task.wait(0.25)
            local char = LP.Character
            if char and char:FindFirstChild(name) then
                firePromptAt(sellPos, 10)
                task.wait(0.4)
            end
            local after = countTool(name)
            if after < before then
                sold = sold + (before - after)
            else
                break
            end
        end
    end
    return sold
end

-- ============================================================
-- 13. HOMELESS SELLER
-- ============================================================
local function sellHomeless()
    if countTool("Hot Chips") == 0 then return 0 end
    if not equipTool("Hot Chips") then return 0 end
    task.wait(0.5)
    if not STATE.running or STATE.stopRequested then return 0 end

    local sold = 0
    local safety = 0
    local maxSafety = countTool("Hot Chips") + #SC_HOMELESS

    while STATE.running and not STATE.stopRequested
          and countTool("Hot Chips") > 0 and safety < maxSafety do
        safety = safety + 1
        local idx = STATE.homelessIndex
        local pos = SC_HOMELESS[idx] or SC_HOMELESS[1]
        if not SC_HOMELESS[idx] then STATE.homelessIndex = 1; idx = 1 end

        uiStatus(("Homeless #%d · sisa %d"):format(idx, countTool("Hot Chips")),
                 Color3.fromRGB(0,220,100))

        if not LP.Character:FindFirstChild("Hot Chips") then
            equipTool("Hot Chips"); task.wait(0.4)
        end

        local before = countTool("Hot Chips")
        local ok = VehicleTP(pos)
        if ok then
            task.wait(CFG.DELAY.sellWait)
            firePromptAt(pos, 30)
            task.wait(0.5)
            firePromptAt(pos, 30)
            task.wait(CFG.DELAY.afterSell)
            local after = countTool("Hot Chips")
            if after < before then
                sold = sold + (before - after)
                STATE.counters.chipsSold = STATE.counters.chipsSold + (before - after)
            end
        end

        STATE.homelessIndex = STATE.homelessIndex + 1
        if STATE.homelessIndex > #SC_HOMELESS then STATE.homelessIndex = 1 end
        task.wait(0.3)
    end
    return sold
end

-- ============================================================
-- 14. COOKING MONITOR (background thread)
-- ============================================================
local function startChipsCookBackground()
    COOK_STATE.chips.active    = true
    COOK_STATE.chips.startedAt = os.clock()
    COOK_STATE.chips.duration  = CFG.COOK_CHIPS_TIME
end

local function isChipsCookDone()
    if not COOK_STATE.chips.active then return true end
    if os.clock() - COOK_STATE.chips.startedAt >= COOK_STATE.chips.duration then
        COOK_STATE.chips.active = false
        return true
    end
    return false
end

-- ============================================================
-- 15. STEP FUNCTIONS
-- ============================================================
local function step4_PourWater()
    STATE.step = "4. Tuang Air"
    uiStatus("Tuang Air...", Color3.fromRGB(80,200,255))
    if countTool({"Water","Water23"}) == 0 then
        -- masih boleh lanjut, tapi kalau gak ada skip
        return true
    end
    local ok = putIngredient({"Water","Water23"}, 0)
    return ok
end

local function step5_BuyFakeID()
    STATE.step = "5. Buy Fake ID"
    if getFakeIDCount() > 0 then return true end
    uiStatus("Buy Fake ID...", Color3.fromRGB(255,200,80))
    local ok = VehicleTP(LOC_FakeID)
    if not ok then return false end
    task.wait(0.5)

    local prompt = findFakeIDSellerPrompt()
    if not prompt then return false end
    pcall(function()
        prompt.HoldDuration = 0
        prompt.RequiresLineOfSight = false
        prompt.MaxActivationDistance = 9e9
        prompt.Enabled = true
    end)
    local start = getFakeIDCount()
    for i = 1, 12 do
        if STATE.stopRequested then return false end
        pcall(function() fireproximityprompt(prompt) end)
        task.wait(0.4)
        if getFakeIDCount() > start then return true end
    end
    return false
end

local function step6_ApplyCard()
    STATE.step = "6. Apply Card"
    if getFakeIDCount() == 0 then return false end
    uiStatus("Apply Card...", Color3.fromRGB(255,200,80))

    local ok = VehicleTP(LOC_ApplyForCard)
    if not ok then return false end
    task.wait(0.5)

    if not equipTool("Fake ID") then return false end
    task.wait(0.3)

    local prompt = findBankTellerPrompt()
    if not prompt then
        -- fallback: prompt terdekat keyword "apply"
        firePromptAt(LOC_ApplyForCard, 10, "apply")
    else
        pcall(function()
            prompt.HoldDuration = 0
            prompt.RequiresLineOfSight = false
            prompt.MaxActivationDistance = 9e9
        end)
        local attempts = 0
        while getFakeIDCount() > 0 and attempts < 20 do
            if STATE.stopRequested then return false end
            pcall(function() fireproximityprompt(prompt) end)
            task.wait(0.5)
            attempts = attempts + 1
        end
    end
    unequipAll()
    if getFakeIDCount() > 0 then return false end

    -- Tunggu approval
    uiStatus("Tunggu approval...", Color3.fromRGB(255,200,80))
    local t0 = os.clock()
    while os.clock() - t0 < CFG.RETRY.approval do
        if STATE.stopRequested then return false end
        local res = checkApprovalNotif()
        if res == true then
            uiStatus("Approved ✔", Color3.fromRGB(0,220,100))
            task.wait(2)
            return true
        elseif res == false then
            return false
        end
        task.wait(0.4)
    end
    -- timeout dianggap sukses (kadang notif hilang cepat)
    return true
end

local function step7_BuyPotatoFlour()
    STATE.step = "7. Beli Potato & Flour"
    if countTool("Potato") >= 1 and countTool("Flour") >= 1 then return true end
    uiStatus("Beli Potato & Flour...", Color3.fromRGB(255,200,80))
    local ok = VehicleTP(BUY_LOC)
    if not ok then return false end
    task.wait(CFG.DELAY.afterTP)
    buyUntilEnough(IDX_POTATO, "Potato", 1, 40)
    if STATE.stopRequested then return false end
    buyUntilEnough(IDX_FLOUR, "Flour", 1, 40)
    task.wait(0.4)
    return countTool("Potato") >= 1 and countTool("Flour") >= 1
end

local function step8_ChipsMission()
    STATE.step = "8. Chips Mission"
    uiStatus("Chips: A→B→C→D", Color3.fromRGB(255,200,80))

    -- A
    if not VehicleTP(CHIPS_COORDS.A) then return false end
    task.wait(CFG.DELAY.afterTP)
    firePromptAt(CHIPS_COORDS.A, 8)
    task.wait(0.9)
    if STATE.stopRequested then return false end

    -- B (insert potato)
    if not VehicleTP(CHIPS_COORDS.B) then return false end
    task.wait(CFG.DELAY.afterTP)
    equipTool("Potato"); task.wait(CFG.DELAY.equipSettle)
    firePromptAt(CHIPS_COORDS.B, 8)
    waitUntilConsumed("Potato", 10)
    task.wait(CFG.DELAY.insertPotato)
    if STATE.stopRequested then return false end

    -- C
    if not VehicleTP(CHIPS_COORDS.C) then return false end
    task.wait(CFG.DELAY.afterTP)
    firePromptAt(CHIPS_COORDS.C, 8)
    task.wait(CFG.DELAY.cookProcess)
    if STATE.stopRequested then return false end

    -- D (insert flour)
    if not VehicleTP(CHIPS_COORDS.D) then return false end
    task.wait(CFG.DELAY.afterTP)
    equipTool("Flour"); task.wait(CFG.DELAY.equipSettle)
    firePromptAt(CHIPS_COORDS.D, 8)
    waitUntilConsumed("Flour", 10)
    task.wait(CFG.DELAY.insertFlour)
    if STATE.stopRequested then return false end

    -- E — buka pot untuk mulai cook
    local potPos = CHIPS_POTS[STATE.potIndex] or CHIPS_POTS[1]
    if not VehicleTP(potPos) then return false end
    task.wait(CFG.DELAY.afterTP)
    firePromptAt(potPos, 8)
    task.wait(CFG.DELAY.potOpen)

    -- Start cooking di background
    startChipsCookBackground()
    uiStatus("Chips cooking 60s (background)...", Color3.fromRGB(255,160,60))
    return true
end

local function step9_SugarGelatin()
    STATE.step = "9. Sugar + Gelatin"
    uiStatus("Sugar + Gelatin...", Color3.fromRGB(255,200,80))
    if not STATE.kitchenPos then return false end
    if not VehicleTP(STATE.kitchenPos) then return false end
    task.wait(0.5)

    putIngredient("Sugar Block Bag", 0)
    task.wait(0.3)
    putIngredient("Gelatin", CFG.COOK_MARSH_TIME)
    return true
end

local function step9b_CollectMarshmallow()
    STATE.step = "9B. Collect Marshmallow"
    uiStatus("Collect Marshmallow...", Color3.fromRGB(255,200,80))
    if not STATE.kitchenPos then return false end
    if not VehicleTP(STATE.kitchenPos) then return false end
    task.wait(0.5)
    return collectMarshmallow()
end

local function step10_SellMarshmallow()
    STATE.step = "10. Sell Marshmallow"
    uiStatus("Sell Marshmallow...", Color3.fromRGB(0,220,100))
    if not VehicleTP(sellPos) then return false end
    task.wait(0.5)
    local sold = sellAllMarshmallow()
    STATE.counters.marshmallowSold = STATE.counters.marshmallowSold + sold
    return true
end

local function step11_ClaimCard()
    STATE.step = "11. Claim Card"
    if hasTool("Card") then return true end
    uiStatus("Claim Card...", Color3.fromRGB(255,200,80))

    local card = nil
    for i = 1, 30 do
        if STATE.stopRequested then return false end
        card = findCardPickup()
        if card then break end
        task.wait(0.5)
    end

    local pos = card and getObjPos(card) or CARD_FALLBACK_POS
    if not pos then return false end

    for attempt = 1, 3 do
        if STATE.stopRequested then return false end
        if not VehicleTP(pos) then
            task.wait(1)
        else
            task.wait(0.5)
            firePromptAt(pos, 20)
            task.wait(0.6)
        end
        if hasTool("Card") then
            STATE.counters.cardSold = STATE.counters.cardSold + 1
            return true
        end
    end
    return hasTool("Card")
end

local function step12_SwipeATM()
    STATE.step = "12. Swipe ATM"
    if not hasTool("Card") then return false end
    uiStatus("Cari ATM...", Color3.fromRGB(255,200,80))

    local atm
    for i = 1, 20 do
        if STATE.stopRequested then return false end
        atm = findAvailableATM()
        if atm then break end
        task.wait(0.5)
    end
    if not atm then
        STATE.lastError = "No ATM available"
        return false
    end

    local att = atm:FindFirstChild("Attachment")
    local prompt = att and att:FindFirstChild("ProximityPrompt")
    if not prompt then
        local p = atm:FindFirstChild("ProximityPrompt", true)
        prompt = p
    end
    if not prompt then return false end

    pcall(function()
        prompt.HoldDuration = 0
        prompt.RequiresLineOfSight = false
        prompt.MaxActivationDistance = 9e9
    end)

    local oldATM = LP.PlayerGui:FindFirstChild("ATM")
    if oldATM then oldATM:Destroy() end

    for i = 1, 10 do
        if STATE.stopRequested then return false end
        VehicleTP(atm.Position)
        task.wait(0.4)
        pcall(function() fireproximityprompt(prompt) end)
        task.wait(0.4)
        if LP.PlayerGui:FindFirstChild("ATM") then break end
    end

    local atmGui = LP.PlayerGui:FindFirstChild("ATM")
    if not atmGui then return false end
    if not equipTool("Card") then return false end
    task.wait(0.4)

    local frame = atmGui:FindFirstChild("Frame")
    local swipeBtn = frame and frame:FindFirstChild("Swipe")
    if not swipeBtn then return false end

    local clicked = false
    if replicatesignal then
        clicked = pcall(function() replicatesignal(swipeBtn.MouseButton1Click) end)
    end
    if not clicked then
        local p = swipeBtn.AbsolutePosition
        local s = swipeBtn.AbsoluteSize
        if p and s then
            VIM:SendMouseButtonEvent(p.X + s.X/2, p.Y + s.Y/2, 0, true, game, 0)
            task.wait(0.05)
            VIM:SendMouseButtonEvent(p.X + s.X/2, p.Y + s.Y/2, 0, false, game, 0)
        end
    end
    task.wait(0.6)
    unequipAll()
    pcall(function() if atmGui and atmGui.Parent then atmGui:Destroy() end end)
    return true
end

local function step13_ClaimChips()
    STATE.step = "13. Claim Chips"
    uiStatus("Tunggu chips matang...", Color3.fromRGB(255,160,60))

    -- Tunggu cooking selesai
    local t0 = os.clock()
    while not isChipsCookDone() do
        if STATE.stopRequested then return false end
        if os.clock() - t0 > 90 then break end
        task.wait(0.5)
    end

    local potPos = CHIPS_POTS[STATE.potIndex] or CHIPS_POTS[1]
    if not VehicleTP(potPos) then return false end
    task.wait(CFG.DELAY.afterTP)

    local before = countChips()
    firePromptAt(potPos, 8)
    local t1 = os.clock()
    while STATE.running and not STATE.stopRequested and os.clock() - t1 < 8 do
        if countChips() > before then break end
        task.wait(0.15)
    end
    task.wait(CFG.DELAY.claimChips)
    return countChips() > before
end

local function step14_Panasin()
    STATE.step = "14. Panasin Chips"
    local raw = countChips()
    if raw == 0 then return true end
    uiStatus(("Panasin %d chips..."):format(raw), Color3.fromRGB(255,160,60))

    if not VehicleTP(SC_TUKAR) then return false end
    task.wait(CFG.DELAY.afterTP)

    local attempts = 0
    local maxAttempts = raw + 5
    local lastCount = countChips()

    while STATE.running and not STATE.stopRequested
          and countChips() > 0 and attempts < maxAttempts do
        attempts = attempts + 1
        firePromptAt(SC_TUKAR, 30)
        task.wait(CFG.DELAY.panasinWait)
        local now = countChips()
        if now == lastCount and attempts >= 3 then break end
        lastCount = now
    end
    return true
end

local function step15_SellHomeless()
    STATE.step = "15. Sell Homeless"
    if countTool("Hot Chips") == 0 then return true end
    uiStatus("Sell Homeless...", Color3.fromRGB(0,220,100))
    sellHomeless()
    return true
end

-- ============================================================
-- 16. UI
-- ============================================================
local Gui = Instance.new("ScreenGui")
Gui.Name = "DarmHubMulti_UI"
Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.DisplayOrder = 9999
Gui.Parent = UI_Target
getgenv().DARM_HUB_UI = Gui

local Main = Instance.new("Frame", Gui)
Main.Size = UDim2.new(0, 300, 0, 500)
Main.Position = UDim2.new(0.05, 0, 0.1, 0)
Main.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
local mainStroke = Instance.new("UIStroke", Main)
mainStroke.Color = Color3.fromRGB(120, 60, 200)
mainStroke.Thickness = 1.5

local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 34)
Header.BackgroundColor3 = Color3.fromRGB(26, 16, 40)
Header.BorderSizePixel = 0
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 10)
local hFix = Instance.new("Frame", Header)
hFix.Size = UDim2.new(1, 0, 0, 8)
hFix.Position = UDim2.new(0, 0, 1, -8)
hFix.BackgroundColor3 = Color3.fromRGB(26, 16, 40)
hFix.BorderSizePixel = 0

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "⚡ DARM HUB MULTI"
Title.TextColor3 = Color3.fromRGB(200, 140, 255)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Position = UDim2.new(1, -28, 0.5, -12)
CloseBtn.BackgroundColor3 = Color3.fromRGB(40, 12, 12)
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(220, 80, 80)
CloseBtn.Font = Enum.Font.GothamBlack
CloseBtn.TextSize = 16
CloseBtn.AutoButtonColor = false
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

local Content = Instance.new("Frame", Main)
Content.Size = UDim2.new(1, -20, 1, -44)
Content.Position = UDim2.new(0, 10, 0, 40)
Content.BackgroundTransparency = 1
local Layout = Instance.new("UIListLayout", Content)
Layout.Padding = UDim.new(0, 8)
Layout.SortOrder = Enum.SortOrder.LayoutOrder

-- Toggle Button
local ToggleBtn = Instance.new("TextButton", Content)
ToggleBtn.Size = UDim2.new(1, 0, 0, 44)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 20, 50)
ToggleBtn.Text = "▶  MULAI MULTI FARM"
ToggleBtn.TextColor3 = Color3.fromRGB(180, 140, 255)
ToggleBtn.Font = Enum.Font.GothamBlack
ToggleBtn.TextSize = 14
ToggleBtn.AutoButtonColor = false
ToggleBtn.LayoutOrder = 1
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 8)
local tStr = Instance.new("UIStroke", ToggleBtn)
tStr.Color = Color3.fromRGB(80, 50, 140)
tStr.Thickness = 1

-- Status box
local StatusBox = Instance.new("Frame", Content)
StatusBox.Size = UDim2.new(1, 0, 0, 50)
StatusBox.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
StatusBox.LayoutOrder = 2
Instance.new("UICorner", StatusBox).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", StatusBox).Color = Color3.fromRGB(40, 40, 55)

local StatusTitle = Instance.new("TextLabel", StatusBox)
StatusTitle.Size = UDim2.new(1, -12, 0, 16)
StatusTitle.Position = UDim2.new(0, 8, 0, 6)
StatusTitle.BackgroundTransparency = 1
StatusTitle.Text = "Status: Idle"
StatusTitle.TextColor3 = Color3.fromRGB(220, 220, 220)
StatusTitle.Font = Enum.Font.GothamBold
StatusTitle.TextSize = 11
StatusTitle.TextXAlignment = Enum.TextXAlignment.Left

local StatusSub = Instance.new("TextLabel", StatusBox)
StatusSub.Size = UDim2.new(1, -12, 0, 20)
StatusSub.Position = UDim2.new(0, 8, 0, 24)
StatusSub.BackgroundTransparency = 1
StatusSub.Text = "Idle"
StatusSub.TextColor3 = Color3.fromRGB(140, 140, 160)
StatusSub.Font = Enum.Font.Gotham
StatusSub.TextSize = 10
StatusSub.TextXAlignment = Enum.TextXAlignment.Left
StatusSub.TextWrapped = true

-- Live status card
local LiveCard = Instance.new("Frame", Content)
LiveCard.Size = UDim2.new(1, 0, 0, 88)
LiveCard.BackgroundColor3 = Color3.fromRGB(14, 22, 18)
LiveCard.LayoutOrder = 3
Instance.new("UICorner", LiveCard).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", LiveCard).Color = Color3.fromRGB(30, 90, 60)

local LiveTitle = Instance.new("TextLabel", LiveCard)
LiveTitle.Size = UDim2.new(1, -12, 0, 18)
LiveTitle.Position = UDim2.new(0, 8, 0, 4)
LiveTitle.BackgroundTransparency = 1
LiveTitle.Text = "📊 LIVE STATUS"
LiveTitle.TextColor3 = Color3.fromRGB(120, 220, 160)
LiveTitle.Font = Enum.Font.GothamBlack
LiveTitle.TextSize = 11
LiveTitle.TextXAlignment = Enum.TextXAlignment.Left

local MSoldLbl = Instance.new("TextLabel", LiveCard)
MSoldLbl.Size = UDim2.new(1, -12, 0, 16)
MSoldLbl.Position = UDim2.new(0, 8, 0, 26)
MSoldLbl.BackgroundTransparency = 1
MSoldLbl.Text = "🧂 MARSHMELLOW SOLD : 0"
MSoldLbl.TextColor3 = Color3.fromRGB(220, 240, 220)
MSoldLbl.Font = Enum.Font.GothamBold
MSoldLbl.TextSize = 11
MSoldLbl.TextXAlignment = Enum.TextXAlignment.Left

local CSoldLbl = Instance.new("TextLabel", LiveCard)
CSoldLbl.Size = UDim2.new(1, -12, 0, 16)
CSoldLbl.Position = UDim2.new(0, 8, 0, 44)
CSoldLbl.BackgroundTransparency = 1
CSoldLbl.Text = "🍟 CHIPS SOLD : 0"
CSoldLbl.TextColor3 = Color3.fromRGB(220, 240, 220)
CSoldLbl.Font = Enum.Font.GothamBold
CSoldLbl.TextSize = 11
CSoldLbl.TextXAlignment = Enum.TextXAlignment.Left

local CardSoldLbl = Instance.new("TextLabel", LiveCard)
CardSoldLbl.Size = UDim2.new(1, -12, 0, 16)
CardSoldLbl.Position = UDim2.new(0, 8, 0, 62)
CardSoldLbl.BackgroundTransparency = 1
CardSoldLbl.Text = "💳 CARD SOLD : 0"
CardSoldLbl.TextColor3 = Color3.fromRGB(220, 240, 220)
CardSoldLbl.Font = Enum.Font.GothamBold
CardSoldLbl.TextSize = 11
CardSoldLbl.TextXAlignment = Enum.TextXAlignment.Left

-- Pot selector
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
PotGrid.LayoutOrder = 5
Instance.new("UICorner", PotGrid).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", PotGrid).Color = Color3.fromRGB(40, 40, 55)

local potBtns = {}
local function refreshPotBtns()
    for i, btn in ipairs(potBtns) do
        local sel = STATE.potIndex == i
        btn.BackgroundColor3 = sel and Color3.fromRGB(60, 40, 120) or Color3.fromRGB(22, 22, 30)
        local s = btn:FindFirstChildOfClass("UIStroke")
        if s then s.Color = sel and Color3.fromRGB(180, 140, 255) or Color3.fromRGB(50, 50, 60) end
        local l = btn:FindFirstChildOfClass("TextLabel")
        if l then l.TextColor3 = sel and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 170) end
    end
end

for i = 1, 10 do
    local col = (i-1) % 5
    local row = math.floor((i-1) / 5)
    local pw = 1/5
    local btn = Instance.new("TextButton", PotGrid)
    btn.Size = UDim2.new(pw - 0.02, 0, 0, 24)
    btn.Position = UDim2.new(col*pw + 0.01, 0, 0, 8 + row*30)
    btn.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
    btn.Text = ""
    btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    local bs = Instance.new("UIStroke", btn)
    bs.Color = Color3.fromRGB(50, 50, 60)
    local l = Instance.new("TextLabel", btn)
    l.Size = UDim2.new(1, 0, 1, 0)
    l.BackgroundTransparency = 1
    l.Text = tostring(i)
    l.TextColor3 = Color3.fromRGB(150, 150, 170)
    l.Font = Enum.Font.GothamBlack
    l.TextSize = 12
    table.insert(potBtns, btn)
    local capI = i
    btn.MouseButton1Click:Connect(function()
        STATE.potIndex = capI
        refreshPotBtns()
    end)
end
refreshPotBtns()

-- Footer info
local InfoLbl = Instance.new("TextLabel", Content)
InfoLbl.Size = UDim2.new(1, 0, 0, 14)
InfoLbl.BackgroundTransparency = 1
InfoLbl.Text = "🔄 Auto Full Cycle · Marshmallow + Chips + Card"
InfoLbl.TextColor3 = Color3.fromRGB(150, 150, 170)
InfoLbl.Font = Enum.Font.GothamBold
InfoLbl.TextSize = 10
InfoLbl.TextXAlignment = Enum.TextXAlignment.Left
InfoLbl.LayoutOrder = 6

local CycleLbl = Instance.new("TextLabel", Content)
CycleLbl.Size = UDim2.new(1, 0, 0, 14)
CycleLbl.BackgroundTransparency = 1
CycleLbl.Text = "Cycle: 0"
CycleLbl.TextColor3 = Color3.fromRGB(180, 140, 255)
CycleLbl.Font = Enum.Font.GothamBlack
CycleLbl.TextSize = 11
CycleLbl.TextXAlignment = Enum.TextXAlignment.Left
CycleLbl.LayoutOrder = 7

local StepLbl = Instance.new("TextLabel", Content)
StepLbl.Size = UDim2.new(1, 0, 0, 14)
StepLbl.BackgroundTransparency = 1
StepLbl.Text = "Step: -"
StepLbl.TextColor3 = Color3.fromRGB(140, 140, 180)
StepLbl.Font = Enum.Font.GothamMedium
StepLbl.TextSize = 10
StepLbl.TextXAlignment = Enum.TextXAlignment.Left
StepLbl.LayoutOrder = 8

local ErrLbl = Instance.new("TextLabel", Content)
ErrLbl.Size = UDim2.new(1, 0, 0, 14)
ErrLbl.BackgroundTransparency = 1
ErrLbl.Text = "Last Error: -"
ErrLbl.TextColor3 = Color3.fromRGB(200, 120, 120)
ErrLbl.Font = Enum.Font.GothamMedium
ErrLbl.TextSize = 10
ErrLbl.TextXAlignment = Enum.TextXAlignment.Left
ErrLbl.TextWrapped = true
ErrLbl.LayoutOrder = 9

-- UI API
function uiStatus(txt, col)
    pcall(function()
        StatusTitle.Text = "Status: " .. tostring(txt)
        if col then StatusTitle.TextColor3 = col end
        StatusSub.Text = tostring(txt)
    end)
end
function uiStep(txt)
    pcall(function() StepLbl.Text = "Step: " .. tostring(txt or "-") end)
end
function uiCycle(n)
    pcall(function() CycleLbl.Text = "Cycle: " .. tostring(n) end)
end
function uiCounters()
    pcall(function()
        MSoldLbl.Text = "🧂 MARSHMELLOW SOLD : " .. STATE.counters.marshmallowSold
        CSoldLbl.Text = "🍟 CHIPS SOLD : " .. STATE.counters.chipsSold
        CardSoldLbl.Text = "💳 CARD SOLD : " .. STATE.counters.cardSold
    end)
end
function uiError(txt)
    STATE.lastError = tostring(txt)
    pcall(function() ErrLbl.Text = "Last Error: " .. STATE.lastError end)
end
function refreshToggle()
    if STATE.running then
        ToggleBtn.Text = "■  STOP MULTI FARM"
        ToggleBtn.TextColor3 = Color3.fromRGB(255, 120, 120)
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(45, 18, 30)
        tStr.Color = Color3.fromRGB(120, 40, 80)
    else
        ToggleBtn.Text = "▶  MULAI MULTI FARM"
        ToggleBtn.TextColor3 = Color3.fromRGB(180, 140, 255)
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 20, 50)
        tStr.Color = Color3.fromRGB(80, 50, 140)
    end
end
refreshToggle()
uiCounters()

-- Auto update counters loop
trackThread(task.spawn(function()
    while Gui.Parent do
        uiCounters()
        task.wait(1)
    end
end))

-- ============================================================
-- 17. ANTI-AFK
-- ============================================================
pcall(function()
    if getconnections then
        for _, c in ipairs(getconnections(LP.Idled)) do
            if c.Disable then c:Disable()
            elseif c.Disconnect then c:Disconnect() end
        end
    else
        trackConn(LP.Idled:Connect(function()
            VirtualUser:Button2Down(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
            task.wait(1)
            VirtualUser:Button2Up(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
        end))
    end
end)

-- ============================================================
-- 18. ERROR/RETRY HELPER
-- ============================================================
local function protectStep(name, fn, retries)
    retries = retries or 1
    for i = 1, retries do
        if STATE.stopRequested or not STATE.running then return false end
        local ok, res = pcall(fn)
        if ok and res then return true end
        if not ok then
            uiError(name .. ": " .. tostring(res))
        end
        task.wait(0.5)
    end
    uiError(name .. " gagal setelah " .. retries .. " retry")
    return false
end

-- ============================================================
-- 19. BOOT CONTROLLER
-- ============================================================
local function waitForVehicle(timeout)
    timeout = timeout or CFG.RETRY.vehicle
    local t0 = os.clock()
    while STATE.running and not STATE.stopRequested do
        local char = LP.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and hum.SeatPart then
                STATE.vehicleReady = true
                return true
            end
        end
        if os.clock() - t0 > timeout then return false end
        task.wait(0.3)
    end
    return false
end

local function killTPDealer()
    -- TP ke dealer (on-foot atau vehicle)
    local pos = DEALER_POS
    return VehicleTP(pos)
end

local function runBoot()
    STATE.step = "BOOT"
    uiStep("BOOT")
    uiStatus("Boot Phase...", Color3.fromRGB(180, 140, 255))

    -- 1. Apartment
    if not STATE.apartmentOwned then
        local owned = detectOwnedApartment()
        if owned then
            STATE.apartmentId    = owned.ID
            STATE.kitchenPos     = owned.KitchenPos
            STATE.doorPos        = owned.DoorPos
            STATE.buyPos         = owned.BuyPos
            STATE.apartmentOwned = true
            uiStatus("Apartment sudah dimiliki (ID "..owned.ID..")", Color3.fromRGB(0,220,100))
        else
            local ok = protectStep("BuyApartment", function()
                return BuyApartment()
            end, 3)
            if not ok then
                uiError("Boot: gagal beli apartment")
                return false
            end
        end
    end

    -- 2. Dealer + Motor
    uiStatus("Ke Dealer (motor)...", Color3.fromRGB(255,200,80))
    killTPDealer()
    task.wait(1)
    if STATE.stopRequested then return false end

    uiStatus("Tunggu motor...", Color3.fromRGB(255,200,80))
    if not waitForVehicle(CFG.RETRY.vehicle) then
        uiError("Boot: vehicle tidak ditemukan")
        return false
    end

    STATE.bootCompleted = true
    uiStatus("Boot selesai ✔", Color3.fromRGB(0,220,100))
    return true
end

-- ============================================================
-- 20. MAIN CYCLE CONTROLLER
-- ============================================================
local function runCycleStep(num, label, fn)
    STATE.step = ("%d. %s"):format(num, label)
    uiStep(STATE.step)
    if STATE.stopRequested or not STATE.running then return false end
    return protectStep(label, fn, 3)
end

local function runOneCycle()
    STATE.cycle = STATE.cycle + 1
    uiCycle(STATE.cycle)

    -- Step 3: Beli bahan
    if not runCycleStep(3, "Beli Bahan Marshmallow", function()
        if not VehicleTP(shopPos) then return false end
        task.wait(0.5)
        return robustBuyIngredients(CFG.BATCH)
    end) then return false end

    -- Step 4: Tuang Air
    if not runCycleStep(4, "Tuang Air", function()
        if not VehicleTP(STATE.kitchenPos) then return false end
        task.wait(0.5)
        return step4_PourWater()
    end) then return false end

    -- Step 5: Buy Fake ID
    if not runCycleStep(5, "Buy Fake ID", step5_BuyFakeID) then return false end

    -- Step 6: Apply Card
    if not runCycleStep(6, "Apply Card", step6_ApplyCard) then return false end

    -- Step 7: Beli Potato + Flour
    if not runCycleStep(7, "Beli Potato & Flour", step7_BuyPotatoFlour) then return false end

    -- Step 8: Chips Mission (mulai cook background)
    if not runCycleStep(8, "Chips Mission", step8_ChipsMission) then return false end

    -- Step 9: Sugar + Gelatin (jalan bareng cooking chips)
    if not runCycleStep(9, "Sugar + Gelatin", step9_SugarGelatin) then return false end

    -- Step 9B: Collect Marshmallow
    if not runCycleStep(9.5, "Collect Marshmallow", step9b_CollectMarshmallow) then
        uiStatus("Collect marshmallow gagal, lanjut", Color3.fromRGB(255,160,60))
    end

    -- Step 10: Sell Marshmallow
    if not runCycleStep(10, "Sell Marshmallow", step10_SellMarshmallow) then return false end

    -- Step 11: Claim Card
    if not runCycleStep(11, "Claim Card", step11_ClaimCard) then
        uiStatus("Claim card gagal, lanjut", Color3.fromRGB(255,160,60))
    end

    -- Step 12: Swipe ATM
    if not runCycleStep(12, "Swipe ATM", step12_SwipeATM) then
        uiStatus("Swipe ATM gagal, lanjut", Color3.fromRGB(255,160,60))
    end

    -- Step 13: Claim Chips
    if not runCycleStep(13, "Claim Chips", step13_ClaimChips) then return false end

    -- Step 14: Panasin
    if not runCycleStep(14, "Panasin Chips", step14_Panasin) then return false end

    -- Step 15: Sell Homeless
    if not runCycleStep(15, "Sell Homeless", step15_SellHomeless) then return false end

    uiStatus(("Cycle #%d selesai ✔"):format(STATE.cycle), Color3.fromRGB(0,220,100))
    return true
end

-- ============================================================
-- 21. MAIN LOOP
-- ============================================================
local function mainLoop()
    uiStatus("Memulai...", Color3.fromRGB(180, 140, 255))

    -- Boot sekali
    if not STATE.bootCompleted then
        if not runBoot() then
            STATE.running = false
            refreshToggle()
            uiStatus("Boot gagal", Color3.fromRGB(255,80,80))
            return
        end
    end

    -- Cek character hidup
    local function ensureAlive()
        local char = LP.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then
            uiStatus("Mati, tunggu respawn...", Color3.fromRGB(255,80,80))
            LP.CharacterAdded:Wait():WaitForChild("HumanoidRootPart", 15)
            task.wait(1.5)
            -- Setelah respawn, validasi vehicle
            if not waitForVehicle(30) then
                uiError("Vehicle hilang setelah respawn")
                return false
            end
        end
        return true
    end

    while STATE.running and not STATE.stopRequested do
        if not ensureAlive() then break end
        local ok = runOneCycle()
        if not ok then
            if STATE.stopRequested then break end
            uiStatus("Cycle gagal, retry 3s...", Color3.fromRGB(255,160,60))
            task.wait(3)
        end
        task.wait(1)
    end

    STATE.running = false
    refreshToggle()
    uiStatus("Dihentikan", Color3.fromRGB(180,60,60))
    uiStep("-")
end

-- ============================================================
-- 22. START / STOP / RESTART
-- ============================================================
local function doCleanup()
    STATE.stopRequested = true
    STATE.running = false

    -- Stop background cooking state
    COOK_STATE.chips.active       = false
    COOK_STATE.marshmallow.active = false

    -- Restore ghost
    stopGhostMode()
    pcall(function() Workspace.Gravity = originalGravity end)

    -- Cancel semua thread yang dilacak (kecuali main kontroler)
    killAllThreads()

    refreshToggle()
    uiStep("-")
end

local function doStart()
    if STATE.running then return end
    STATE.running       = true
    STATE.stopRequested = false

    -- Restart auto counter loop
    trackThread(task.spawn(function()
        while Gui.Parent and STATE.running do
            uiCounters()
            task.wait(1)
        end
    end))

    refreshToggle()
    uiStatus("Running...", Color3.fromRGB(0,220,100))

    trackThread(task.spawn(function()
        local ok, err = pcall(mainLoop)
        if not ok then
            uiError("Main loop error: " .. tostring(err))
            warn("[DARM HUB] Main loop error:", err)
        end
        STATE.running = false
        refreshToggle()
    end))
end

local function doStop()
    STATE.stopRequested = true
    STATE.running = false
    uiStatus("Stopping...", Color3.fromRGB(255,160,60))
    task.wait(0.5)
    doCleanup()
    uiStatus("Stopped", Color3.fromRGB(180,60,60))
end

ToggleBtn.MouseButton1Click:Connect(function()
    if STATE.running then
        doStop()
    else
        doStart()
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    doStop()
    pcall(function() Gui:Destroy() end)
end)

uiStatus("Idle · Atur pot lalu MULAI", Color3.fromRGB(150,150,170))

print("[DARM HUB MULTI] Loaded. Boot → Cycle 15 step → Loop.")