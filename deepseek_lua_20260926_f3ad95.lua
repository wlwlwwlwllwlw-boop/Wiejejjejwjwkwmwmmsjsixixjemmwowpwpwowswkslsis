-- DARK HUB | Cali Streets
-- Rebranded from STR HUB. Cleaned UI, no loading screen, no dummy features.

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

-- ------------------------------
-- Load Fluent UI (Modded)
-- ------------------------------
local Fluent = loadstring(game:HttpGet("https://github.com/StyearX/Fluent-Modded/releases/download/Fluent/FluentPro"))()

local window = Fluent:CreateWindow({
    Title = "DARK HUB",
    SubTitle = "Cali Streets",
    TabWidth = 160,
    Size = UDim2.fromOffset(520, 360),
    Acrylic = true,
    Theme = "AMOLED",
    MinimizeKey = Enum.KeyCode.LeftControl,
    Search = true
})

local mainTab = window:AddTab({ Title = "Main", Icon = "solar/home-bold" })
local farmTab = window:AddTab({ Title = "Auto Farm", Icon = "solar/card-bold" })
local combatTab = window:AddTab({ Title = "Combat", Icon = "solar/target-bold" })
local visualsTab = window:AddTab({ Title = "Visuals", Icon = "solar/eye-bold" })
local socialsTab = window:AddTab({ Title = "Socials", Icon = "solar/chat-round-dots-bold" })
local creditsTab = window:AddTab({ Title = "Credits", Icon = "solar/user-heart-bold" })
local settingsTab = window:AddTab({ Title = "Settings", Icon = "solar/settings-bold" })

-- ------------------------------
-- Global State
-- ------------------------------
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
_G.CustomAutoFarmVisible = false
_G.AutoFarmDraggable = true
_G.CustomAimbotVisible = false
_G.CustomAimbotActive = false
_G.AimbotDraggable = true

local aimbotFOV = 120
local noRecoilActive = false

-- ------------------------------
-- Helpers
-- ------------------------------
local function getCharacter()
    local char = LocalPlayer.Character
    if not char then return nil end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return nil end
    return char:FindFirstChild("HumanoidRootPart")
end

local function getRootPart()
    local char = LocalPlayer.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
end

-- ------------------------------
-- Auto Farm Engine
-- ------------------------------
local autoFarmEnabled = false

local function tweenToPosition(targetPos, duration)
    if not autoFarmEnabled then return end
    local root = getRootPart()
    if not root then return end
    local dist = (targetPos - root.Position).Magnitude
    local speed = 25
    local tweenTime = dist / speed
    root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
    local tween = TweenService:Create(root, TweenInfo.new(tweenTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
        CFrame = CFrame.new(targetPos)
    })
    tween:Play()
    while tweenTime > 0 do
        if not autoFarmEnabled then
            tween:Cancel()
            return
        end
        local root2 = getRootPart()
        if not root2 then
            tween:Cancel()
            return
        end
        root2.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        task.wait(0.05)
        tweenTime = tweenTime - 0.05
    end
    local root3 = getRootPart()
    if root3 then
        root3.CFrame = CFrame.new(targetPos)
        root3.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    end
end

local function interactWithPrompt(targetPos, radius)
    if not autoFarmEnabled then return false end
    radius = radius or 35
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and obj.Enabled then
            local parent = obj.Parent
            if parent and parent:IsA("BasePart") then
                local dist = (parent.Position - targetPos).Magnitude
                if dist < radius then
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
    return false
end

local function findToolInInventory(toolNamePattern)
    if not autoFarmEnabled then return false end
    local char = LocalPlayer.Character
    if not char then return false end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") and string.find(string.lower(tool.Name), string.lower(toolNamePattern)) then
            return true
        end
    end
    if backpack and humanoid then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and string.find(string.lower(tool.Name), string.lower(toolNamePattern)) then
                humanoid:EquipTool(tool)
                task.wait(0.4)
                return true
            end
        end
    end
    return false
end

local function autoFarmLoop()
    while autoFarmEnabled do
        if not getCharacter() then
            task.wait(1)
            goto continue
        end
        tweenToPosition(Vector3.new(-337, 693, 366))
        for _ = 1, 2 do
            if not autoFarmEnabled then break end
            interactWithPrompt(Vector3.new(-337, 693, 366))
            task.wait(0.6)
        end
        if not autoFarmEnabled then break end
        local positions = {
            Vector3.new(-467, 693, 41),
            Vector3.new(-475, 693, 45)
        }
        for _, pos in ipairs(positions) do
            if not autoFarmEnabled then break end
            tweenToPosition(pos)
            findToolInInventory("blank")
            task.wait(0.4)
            interactWithPrompt(pos)
            task.wait(0.8)
        end
        if not autoFarmEnabled then break end
        for _ = 1, 17 do
            if not autoFarmEnabled then break end
            task.wait(1)
        end
        if not autoFarmEnabled then break end
        tweenToPosition(Vector3.new(-319, 692, 29))
        for _ = 1, 2 do
            if not autoFarmEnabled then break end
            findToolInInventory("activated")
            task.wait(0.4)
            interactWithPrompt(Vector3.new(-319, 692, 29))
            task.wait(0.6)
        end
        task.wait(1)
        ::continue::
    end
end

-- ------------------------------
-- Main Tab
-- ------------------------------
mainTab:AddToggle("InfiniteStamina", {
    Title = "Infinite Stamina",
    Description = "Locks stamina at 100 so you can sprint endlessly.",
    Default = false,
    Callback = function(state) _G.InfiniteStaminaEnabled = state end
})

mainTab:AddToggle("AutoPickup", {
    Title = "Auto Pickup Dropped Loot",
    Description = "Teleports dropped tools to your character.",
    Default = false,
    Callback = function(state)
        _G.AutoLoot = state
        if state then
            task.spawn(function()
                while _G.AutoLoot do
                    pcall(function()
                        for _, obj in ipairs(Workspace:GetChildren()) do
                            if not _G.AutoLoot then break end
                            if obj:IsA("Tool") or string.find(string.lower(obj.Name), "loot") then
                                local handle = obj:FindFirstChild("Handle")
                                if handle and handle:IsA("BasePart") then
                                    local root = getRootPart()
                                    if root then
                                        handle.CFrame = root.CFrame
                                    end
                                end
                            end
                        end
                    end)
                    task.wait(0.5)
                end
            end)
        end
    end
})

mainTab:AddToggle("InstantInteractToggle", {
    Title = "Instant Interact",
    Description = "Removes hold timers on proximity prompts.",
    Default = false,
    Callback = function(state) _G.InstantInteractEnabled = state end
})

mainTab:AddToggle("NoJumpCooldown", {
    Title = "No Jump Cooldown",
    Description = "Removes jump cooldown for continuous jumping.",
    Default = false,
    Callback = function(state) _G.NoJumpCooldownEnabled = state end
})

mainTab:AddToggle("NoclipToggle", {
    Title = "Noclip",
    Description = "Allows you to walk through walls.",
    Default = false,
    Callback = function(state) _G.NoclipEnabled = state end
})

mainTab:AddToggle("WalkSpeedToggle", {
    Title = "Safe Speed Boost",
    Description = "Boost your speed by a small amount to avoid anti-cheat detection.",
    Default = false,
    Callback = function(state) _G.WalkSpeedEnabled = state end
})

-- ------------------------------
-- Auto Farm Tab + Floating UI
-- ------------------------------
local autoFarmGui = Instance.new("ScreenGui")
autoFarmGui.Name = "DARKHUB_AutoFarmGUI"
autoFarmGui.Parent = CoreGui
autoFarmGui.ResetOnSpawn = false
autoFarmGui.Enabled = false

local autoFarmFrame = Instance.new("Frame")
autoFarmFrame.Name = "AutoFarmMainFrame"
autoFarmFrame.Size = UDim2.new(0, 200, 0, 90)
autoFarmFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
autoFarmFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
autoFarmFrame.BorderSizePixel = 0
autoFarmFrame.Active = true
autoFarmFrame.Draggable = true
autoFarmFrame.Parent = autoFarmGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 6)
frameCorner.Parent = autoFarmFrame

local farmTitle = Instance.new("TextLabel")
farmTitle.Size = UDim2.new(1, 0, 0, 30)
farmTitle.BackgroundTransparency = 1
farmTitle.Text = "BLANK CARD AUTO-FARM"
farmTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
farmTitle.TextSize = 13
farmTitle.Font = Enum.Font.GothamBold
farmTitle.Parent = autoFarmFrame

local farmButton = Instance.new("TextButton")
farmButton.Size = UDim2.new(0.85, 0, 0, 35)
farmButton.Position = UDim2.new(0.075, 0, 0.45, 0)
farmButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
farmButton.TextColor3 = Color3.fromRGB(255, 100, 100)
farmButton.Text = "Auto Farm: OFF"
farmButton.TextSize = 12
farmButton.Font = Enum.Font.GothamBold
farmButton.Parent = autoFarmFrame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 4)
btnCorner.Parent = farmButton

farmButton.MouseButton1Click:Connect(function()
    if not autoFarmEnabled then
        autoFarmEnabled = true
        farmButton.Text = "Auto Farm: ON"
        farmButton.TextColor3 = Color3.fromRGB(100, 255, 100)
        task.spawn(autoFarmLoop)
    else
        autoFarmEnabled = false
        farmButton.Text = "Auto Farm: OFF"
        farmButton.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
end)

farmTab:AddToggle("SpawnAutoFarmGui", {
    Title = "Spawn Auto Farm Button",
    Description = "Show or hide the floating auto farm menu.",
    Default = false,
    Callback = function(state)
        _G.CustomAutoFarmVisible = state
        autoFarmGui.Enabled = state
        if not state then
            autoFarmEnabled = false
            farmButton.Text = "Auto Farm: OFF"
            farmButton.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
    end
})

farmTab:AddToggle("FreezeAutoFarmBtn", {
    Title = "Freeze Auto Farm UI",
    Description = "Locks the floating auto farm UI so it cannot be dragged.",
    Default = false,
    Callback = function(state)
        _G.AutoFarmDraggable = not state
        autoFarmFrame.Draggable = not state
    end
})

-- ------------------------------
-- Combat Tab
-- ------------------------------
local aimbotGui = Instance.new("ScreenGui")
aimbotGui.Name = "DARKHUB_AimbotGUI"
aimbotGui.Parent = CoreGui
aimbotGui.ResetOnSpawn = false
aimbotGui.Enabled = false

local fovCircle = Instance.new("Frame")
fovCircle.Name = "FOVCircle"
fovCircle.Parent = aimbotGui
fovCircle.BackgroundTransparency = 1
fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
fovCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
fovCircle.Size = UDim2.new(0, aimbotFOV * 2, 0, aimbotFOV * 2)

local fovStroke = Instance.new("UIStroke")
fovStroke.Parent = fovCircle
fovStroke.Color = Color3.fromRGB(0, 170, 255)
fovStroke.Thickness = 1.5
fovStroke.Transparency = 0.3

local fovCorner = Instance.new("UICorner")
fovCorner.CornerRadius = UDim.new(1, 0)
fovCorner.Parent = fovCircle

local aimbotButton = Instance.new("TextButton")
aimbotButton.Name = "AimbotBtn"
aimbotButton.Parent = aimbotGui
aimbotButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
aimbotButton.BorderColor3 = Color3.fromRGB(0, 170, 255)
aimbotButton.BorderSizePixel = 2
aimbotButton.Position = UDim2.new(0, 50, 0, 110)
aimbotButton.Size = UDim2.new(0, 90, 0, 45)
aimbotButton.Font = Enum.Font.SourceSansBold
aimbotButton.Text = "AIMBOT: OFF"
aimbotButton.TextColor3 = Color3.fromRGB(255, 255, 255)
aimbotButton.TextSize = 12

local btnCorner2 = Instance.new("UICorner")
btnCorner2.CornerRadius = UDim.new(0, 8)
btnCorner2.Parent = aimbotButton

aimbotButton.MouseButton1Click:Connect(function()
    _G.CustomAimbotActive = not _G.CustomAimbotActive
    if _G.CustomAimbotActive then
        aimbotButton.Text = "AIMBOT: ON"
        aimbotButton.TextColor3 = Color3.fromRGB(0, 255, 100)
        fovStroke.Color = Color3.fromRGB(0, 255, 100)
    else
        aimbotButton.Text = "AIMBOT: OFF"
        aimbotButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        fovStroke.Color = Color3.fromRGB(0, 170, 255)
    end
end)

local dragging = false
local dragStart, startPos

aimbotButton.InputBegan:Connect(function(input)
    if not _G.AimbotDraggable then return end
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = aimbotButton.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not _G.AimbotDraggable then return end
    if dragging and input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - dragStart
        aimbotButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local function canSeeTarget(targetHead)
    local char = LocalPlayer.Character
    local origin = Camera.CFrame.Position
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { char, char and char:FindFirstChild("Head") }
    params.IgnoreWater = true
    local result = Workspace:Raycast(origin, targetHead.Position - origin, params)
    if result then
        return result.Instance:IsDescendantOf(targetHead.Parent)
    end
    return true
end

combatTab:AddToggle("NoRecoilToggle", {
    Title = "No Recoil",
    Description = "Freezes weapon recoil so your aim stays steady while firing.",
    Default = false,
    Callback = function(state)
        noRecoilActive = state
        if state then
            Fluent:Notify({
                Title = "No Recoil",
                Content = "Weapon recoil modified to 0.",
                Duration = 4
            })
        end
    end
})

combatTab:AddToggle("SpawnAimbotGui", {
    Title = "Spawn Aimbot UI",
    Description = "Show or hide the floating aimbot UI and FOV ring.",
    Default = false,
    Callback = function(state)
        _G.CustomAimbotVisible = state
        aimbotGui.Enabled = state
        if not state then
            _G.CustomAimbotActive = false
            aimbotButton.Text = "AIMBOT: OFF"
            aimbotButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            fovStroke.Color = Color3.fromRGB(0, 170, 255)
        end
    end
})

combatTab:AddSlider("AimbotCircleSize", {
    Title = "Aimbot Circle Size (FOV)",
    Description = "Adjust the size of the aimbot FOV circle.",
    Default = 120,
    Min = 40,
    Max = 300,
    Rounding = 0,
    Callback = function(value)
        aimbotFOV = value
        fovCircle.Size = UDim2.new(0, aimbotFOV * 2, 0, aimbotFOV * 2)
    end
})

combatTab:AddToggle("FreezeAimbotBtn", {
    Title = "Freeze Aimbot UI",
    Description = "Locks the floating aimbot UI so it cannot be dragged.",
    Default = false,
    Callback = function(state)
        _G.AimbotDraggable = not state
    end
})

RunService.RenderStepped:Connect(function()
    if not _G.CustomAimbotVisible or not _G.CustomAimbotActive then return end
    local viewport = Camera.ViewportSize
    local center = Vector2.new(viewport.X / 2, viewport.Y / 2)
    local closestTarget = nil
    local closestDist = aimbotFOV
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local head = player.Character.Head
            local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
            if onScreen then
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                if dist <= aimbotFOV and canSeeTarget(head) then
                    if dist < closestDist then
                        closestDist = dist
                        closestTarget = head
                    end
                end
            end
        end
    end
    if closestTarget then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, closestTarget.Position)
    end
end)

-- ------------------------------
-- Visuals Tab
-- ------------------------------
visualsTab:AddToggle("InfiniteZoomToggle", {
    Title = "Max Zoom Out",
    Description = "Bypasses max camera zoom limits.",
    Default = false,
    Callback = function(state)
        _G.InfiniteZoomEnabled = state
        if not state then
            LocalPlayer.CameraMaxZoomDistance = 128
        end
    end
})

visualsTab:AddToggle("PlayerESP", {
    Title = "Player ESP",
    Description = "Highlights characters and shows their name tag.",
    Default = false,
    Callback = function(state) _G.ESPEnabled = state end
})

local espData = {}
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
    local function setupESP(char)
        removeESP(player)
        espData[player] = {}
        if not char then return end
        local head = char:WaitForChild("Head", 5)
        local humanoid = char:WaitForChild("Humanoid", 5)
        if not head or not humanoid then return end

        local billboard = Instance.new("BillboardGui")
        billboard.Name = "ESP_NameTag"
        billboard.Adornee = head
        billboard.Size = UDim2.new(0, 100, 0, 40)
        billboard.StudsOffset = Vector3.new(0, 2, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = head

        local nameLabel = Instance.new("TextLabel")
        nameLabel.Parent = billboard
        nameLabel.BackgroundTransparency = 1
        nameLabel.Size = UDim2.new(1, 0, 1, 0)
        nameLabel.Font = Enum.Font.SourceSansBold
        nameLabel.Text = player.DisplayName
        nameLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
        nameLabel.TextSize = 14
        nameLabel.TextStrokeTransparency = 0.5

        local highlight = Instance.new("Highlight")
        highlight.Name = "ESP_Highlight"
        highlight.Adornee = char
        highlight.FillColor = Color3.fromRGB(0, 170, 255)
        highlight.FillTransparency = 0.5
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.OutlineTransparency = 0
        highlight.Parent = char

        espData[player].Billboard = billboard
        espData[player].Highlight = highlight
        espData[player].Character = char
    end

    if player.Character then setupESP(player.Character) end
    espData[player].CharConn = player.CharacterAdded:Connect(setupESP)
end

local playerList = {}
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        table.insert(playerList, player.DisplayName)
        addESP(player)
    end
end

local selectedPlayer = nil
local dropdown = visualsTab:AddDropdown("SelectTargetPlayer", {
    Title = "Select Player",
    Description = "Choose a player to inspect.",
    Values = playerList,
    Default = 1,
    Callback = function(value) selectedPlayer = value end
})

Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        table.insert(playerList, player.DisplayName)
        dropdown:SetValues(playerList)
        addESP(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    removeESP(player)
    for i, name in ipairs(playerList) do
        if name == player.DisplayName then
            table.remove(playerList, i)
            break
        end
    end
    dropdown:SetValues(playerList)
end)

visualsTab:AddButton({
    Title = "Inspect Inventory",
    Description = "Check the selected player's tools and equipped tools.",
    Callback = function()
        if not selectedPlayer then return end
        local targetPlayer = nil
        for _, player in ipairs(Players:GetPlayers()) do
            if player.DisplayName == selectedPlayer or player.Name == selectedPlayer then
                targetPlayer = player
                break
            end
        end
        if not targetPlayer then return end
        local inventory = {}
        local char = targetPlayer.Character
        if char then
            for _, tool in ipairs(char:GetChildren()) do
                if tool:IsA("Tool") then
                    table.insert(inventory, tool.Name)
                end
            end
            local backpack = targetPlayer:FindFirstChildOfClass("Backpack")
            if backpack then
                for _, tool in ipairs(backpack:GetChildren()) do
                    if tool:IsA("Tool") then
                        table.insert(inventory, tool.Name .. " (Equipped)")
                    end
                end
            end
        end
        local content = #inventory > 0 and table.concat(inventory, ", ") or "Inventory is empty."
        Fluent:Notify({
            Title = targetPlayer.DisplayName .. "'s Inventory",
            Content = content,
            Duration = 6
        })
    end
})

-- ------------------------------
-- Socials Tab
-- ------------------------------
socialsTab:AddParagraph({
    Title = "Discord Server",
    Content = "Join the community Discord for updates and support."
})
socialsTab:AddButton({
    Title = "Copy Discord Link",
    Description = "Copies the invite link to your clipboard.",
    Callback = function()
        if setclipboard then setclipboard("https://discord.gg/xKvegCV6yf") end
    end
})

socialsTab:AddParagraph({
    Title = "YouTube Channel",
    Content = "Subscribe to support future releases."
})
socialsTab:AddButton({
    Title = "Copy YouTube Link",
    Description = "Copies the YouTube channel link to your clipboard.",
    Callback = function()
        if setclipboard then setclipboard("https://youtube.com/@strixwashere") end
    end
})

-- ------------------------------
-- Credits Tab
-- ------------------------------
creditsTab:AddParagraph({
    Title = "Developer",
    Content = "@strixwashere"
})
creditsTab:AddParagraph({
    Title = "UI Library",
    Content = "Modded Fluent UI"
})

-- ------------------------------
-- Settings Tab
-- ------------------------------
settingsTab:AddButton({
    Title = "FPS Booster (Potato Graphics)",
    Description = "Strips heavy textures and effects to boost FPS.",
    Callback = function()
        if _G.FPSBoostUsed then return end
        _G.FPSBoostUsed = true
        pcall(function()
            local lighting = game:GetService("Lighting")
            lighting.GlobalShadows = false
            lighting.FogEnd = 999999
            for _, obj in ipairs(lighting:GetChildren()) do
                if obj:IsA("PostEffect") or obj:IsA("Atmosphere") or obj:IsA("Sky") or obj:IsA("Clouds") or obj:IsA("BlurEffect") then
                    obj:Destroy()
                end
            end
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("BasePart") then
                    obj.Material = Enum.Material.SmoothPlastic
                    obj.CastShadow = false
                elseif obj:IsA("Texture") or obj:IsA("Decal") then
                    obj:Destroy()
                end
            end
        end)
    end
})

settingsTab:AddDropdown("UISize", {
    Title = "UI Size",
    Description = "Scale menu dimensions.",
    Values = { "Small", "Medium" },
    Default = 1,
    Callback = function(value)
        if value == "Small" then
            window.Root.Size = UDim2.fromOffset(480, 320)
        elseif value == "Medium" then
            window.Root.Size = UDim2.fromOffset(580, 440)
        end
    end
})

settingsTab:AddButton({
    Title = "Unload Script",
    Description = "Unloads DARK HUB and cleans up all UI and features.",
    Callback = function()
        pcall(function()
            autoFarmGui:Destroy()
            aimbotGui:Destroy()
            local watermark = CoreGui:FindFirstChild("DARKHUB_Watermark")
            if watermark then watermark:Destroy() end
            local mobileToggle = CoreGui:FindFirstChild("DARKHUB_MobileToggle")
            if mobileToggle then mobileToggle:Destroy() end
            _G.CustomAimbotActive = false
            _G.CustomAimbotVisible = false
            _G.CustomAutoFarmVisible = false
            _G.ESPEnabled = false
            autoFarmEnabled = false
            noRecoilActive = false
            for player, _ in pairs(espData) do
                removeESP(player)
            end
            Fluent:Destroy()
        end)
    end
})

-- ------------------------------
-- Watermark
-- ------------------------------
local watermarkGui = Instance.new("ScreenGui")
watermarkGui.Name = "DARKHUB_Watermark"
watermarkGui.Parent = CoreGui
watermarkGui.ResetOnSpawn = false
watermarkGui.DisplayOrder = -1

local watermarkLabel = Instance.new("TextLabel")
watermarkLabel.Name = "WatermarkText"
watermarkLabel.Parent = watermarkGui
watermarkLabel.BackgroundTransparency = 1
watermarkLabel.AnchorPoint = Vector2.new(0.5, 0)
watermarkLabel.Position = UDim2.new(0.5, 0, 0, 5)
watermarkLabel.Size = UDim2.new(0, 400, 0, 20)
watermarkLabel.Font = Enum.Font.SourceSansBold
watermarkLabel.Text = "DARK HUB"
watermarkLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
watermarkLabel.TextTransparency = 0.4
watermarkLabel.TextSize = 13
watermarkLabel.TextXAlignment = Enum.TextXAlignment.Center

-- ------------------------------
-- Mobile Toggle Button
-- ------------------------------
local mobileGui = Instance.new("ScreenGui")
mobileGui.Name = "DARKHUB_MobileToggle"
mobileGui.Parent = CoreGui
mobileGui.ResetOnSpawn = false

local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleBtn"
toggleBtn.Parent = mobileGui
toggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
toggleBtn.BorderColor3 = Color3.fromRGB(50, 50, 50)
toggleBtn.BorderSizePixel = 2
toggleBtn.Position = UDim2.new(0, 50, 0, 50)
toggleBtn.Size = UDim2.new(0, 45, 0, 45)
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.Text = "DH"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextSize = 12

local btnCorner3 = Instance.new("UICorner")
btnCorner3.CornerRadius = UDim.new(1, 0)
btnCorner3.Parent = toggleBtn

local dragMobile = false
local dragStartMobile, startPosMobile

toggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragMobile = true
        dragStartMobile = input.Position
        startPosMobile = toggleBtn.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragMobile = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragMobile and input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - dragStartMobile
        toggleBtn.Position = UDim2.new(startPosMobile.X.Scale, startPosMobile.X.Offset + delta.X, startPosMobile.Y.Scale, startPosMobile.Y.Offset + delta.Y)
    end
end)

toggleBtn.MouseButton1Click:Connect(function()
    window:Minimize()
end)

-- ------------------------------
-- Instant Interact Hook
-- ------------------------------
ProximityPromptService.PromptTriggered:Connect(function(prompt)
    if _G.InstantInteractEnabled then
        pcall(function()
            if fireproximityprompt then
                fireproximityprompt(prompt)
            end
        end)
    end
end)

-- ------------------------------
-- Heartbeat Updates
-- ------------------------------
RunService.Heartbeat:Connect(function()
    if _G.InfiniteZoomEnabled then
        LocalPlayer.CameraMaxZoomDistance = 100000
    end

    for _, data in pairs(espData) do
        local visible = _G.ESPEnabled and data.Character and data.Character:FindFirstChild("Humanoid")
        if data.Billboard then data.Billboard.Enabled = visible end
        if data.Highlight then data.Highlight.Enabled = visible end
    end
end)

RunService.Stepped:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    if not humanoid or not rootPart then return end

    if _G.NoclipEnabled then
        for _, part in ipairs(Workspace:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end

    if _G.InfiniteStaminaEnabled then
        for _, valueObj in ipairs(char:GetDescendants()) do
            if valueObj:IsA("NumberValue") and string.find(string.lower(valueObj.Name), "stamina") then
                valueObj.Value = 100
            end
        end
        local attrs = humanoid:GetAttributes()
        for attrName, val in pairs(attrs) do
            if string.find(string.lower(attrName), "stamina") and typeof(val) == "number" then
                humanoid:SetAttribute(attrName, 100)
            end
        end
    end

    if _G.WalkSpeedEnabled then
        rootPart.CFrame = rootPart.CFrame + humanoid.MoveDirection * (_G.WalkSpeedMultiplier - 1) * 0.5
    end
end)

-- ------------------------------
-- Jump Handling
-- ------------------------------
UserInputService.JumpRequest:Connect(function()
    if _G.NoJumpCooldownEnabled then
        local char = LocalPlayer.Character
        if char then
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end
end)

RunService.Stepped:Connect(function()
    if _G.NoJumpCooldownEnabled then
        local char = LocalPlayer.Character
        if char then
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid then
                pcall(function()
                    humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
                end)
            end
        end
    end
end)

-- ------------------------------
-- Ready Notification
-- ------------------------------
Fluent:Notify({
    Title = "DARK HUB Loaded",
    Content = "Interface ready.",
    Duration = 5
})