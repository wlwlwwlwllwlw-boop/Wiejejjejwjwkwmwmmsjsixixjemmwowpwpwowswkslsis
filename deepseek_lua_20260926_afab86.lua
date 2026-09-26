--[[
  DARK HUB | Cali Streets
  UI   : ZXCHUB Universal Menu (dari ZXCHUB Menu Lua.txt)
  Logic: DARK HUB (auto farm, ESP, aimbot, dsb)
  Astra UI sudah dihapus sepenuhnya.
]]

local UIS         = game:GetService("UserInputService")
local TweenS      = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService  = game:GetService("RunService")
local CoreGui     = game:GetService("CoreGui")
local Players     = game:GetService("Players")
local Workspace   = game:GetService("Workspace")
local ProximityPromptService = game:GetService("ProximityPromptService")
local lp          = Players.LocalPlayer
local Camera      = Workspace.CurrentCamera
local setclipboard = setclipboard or toboard or writeclipboard

local isMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled

-- ════════════════════════════════════════════════════════
-- THEMES
-- ════════════════════════════════════════════════════════
local Themes = {
    Default = {
        bg0=Color3.fromRGB(8,9,11),    bg1=Color3.fromRGB(13,14,17),
        bg2=Color3.fromRGB(18,20,24),  bg3=Color3.fromRGB(24,26,32),
        bg4=Color3.fromRGB(30,33,40),  brd=Color3.fromRGB(36,39,48),
        brd2=Color3.fromRGB(48,52,64), acc=Color3.fromRGB(215,55,55),
        txt=Color3.fromRGB(198,201,215),txt2=Color3.fromRGB(118,122,140),
        txt3=Color3.fromRGB(55,58,74), grn=Color3.fromRGB(65,195,115),
        white=Color3.fromRGB(255,255,255),
    },
    Ocean = {
        bg0=Color3.fromRGB(7,12,20),   bg1=Color3.fromRGB(11,18,28),
        bg2=Color3.fromRGB(15,24,36),  bg3=Color3.fromRGB(20,32,46),
        bg4=Color3.fromRGB(26,40,56),  brd=Color3.fromRGB(32,48,68),
        brd2=Color3.fromRGB(44,65,88), acc=Color3.fromRGB(40,140,210),
        txt=Color3.fromRGB(188,210,228),txt2=Color3.fromRGB(105,138,162),
        txt3=Color3.fromRGB(50,78,98), grn=Color3.fromRGB(65,195,115),
        white=Color3.fromRGB(255,255,255),
    },
    Amethyst = {
        bg0=Color3.fromRGB(11,8,17),   bg1=Color3.fromRGB(16,12,24),
        bg2=Color3.fromRGB(22,17,33),  bg3=Color3.fromRGB(29,22,43),
        bg4=Color3.fromRGB(37,28,54),  brd=Color3.fromRGB(45,35,65),
        brd2=Color3.fromRGB(60,47,84), acc=Color3.fromRGB(145,50,215),
        txt=Color3.fromRGB(210,195,228),txt2=Color3.fromRGB(132,115,155),
        txt3=Color3.fromRGB(70,56,90), grn=Color3.fromRGB(65,195,115),
        white=Color3.fromRGB(255,255,255),
    },
    Emerald = {
        bg0=Color3.fromRGB(7,13,11),   bg1=Color3.fromRGB(10,18,15),
        bg2=Color3.fromRGB(14,24,20),  bg3=Color3.fromRGB(19,32,26),
        bg4=Color3.fromRGB(24,40,33),  brd=Color3.fromRGB(30,50,41),
        brd2=Color3.fromRGB(42,67,55), acc=Color3.fromRGB(38,190,105),
        txt=Color3.fromRGB(182,215,198),txt2=Color3.fromRGB(105,145,125),
        txt3=Color3.fromRGB(52,80,65), grn=Color3.fromRGB(65,195,115),
        white=Color3.fromRGB(255,255,255),
    },
    Rose = {
        bg0=Color3.fromRGB(15,9,11),   bg1=Color3.fromRGB(21,13,16),
        bg2=Color3.fromRGB(28,17,22),  bg3=Color3.fromRGB(36,22,28),
        bg4=Color3.fromRGB(44,28,35),  brd=Color3.fromRGB(54,35,43),
        brd2=Color3.fromRGB(70,46,57), acc=Color3.fromRGB(218,70,108),
        txt=Color3.fromRGB(228,195,208),txt2=Color3.fromRGB(148,115,130),
        txt3=Color3.fromRGB(82,58,68), grn=Color3.fromRGB(65,195,115),
        white=Color3.fromRGB(255,255,255),
    },
    Midnight = {
        bg0=Color3.fromRGB(5,5,9),     bg1=Color3.fromRGB(9,9,15),
        bg2=Color3.fromRGB(13,13,21),  bg3=Color3.fromRGB(17,17,28),
        bg4=Color3.fromRGB(22,22,36),  brd=Color3.fromRGB(28,28,44),
        brd2=Color3.fromRGB(40,40,60), acc=Color3.fromRGB(85,105,255),
        txt=Color3.fromRGB(188,190,220),txt2=Color3.fromRGB(112,114,148),
        txt3=Color3.fromRGB(56,57,82), grn=Color3.fromRGB(65,195,115),
        white=Color3.fromRGB(255,255,255),
    },
    Sunset = {
        bg0=Color3.fromRGB(13,9,7),    bg1=Color3.fromRGB(19,13,10),
        bg2=Color3.fromRGB(26,18,13),  bg3=Color3.fromRGB(34,23,17),
        bg4=Color3.fromRGB(42,29,21),  brd=Color3.fromRGB(52,36,26),
        brd2=Color3.fromRGB(68,48,34), acc=Color3.fromRGB(238,115,35),
        txt=Color3.fromRGB(232,210,192),txt2=Color3.fromRGB(150,128,112),
        txt3=Color3.fromRGB(82,65,54), grn=Color3.fromRGB(65,195,115),
        white=Color3.fromRGB(255,255,255),
    },
    Arctic = {
        bg0=Color3.fromRGB(232,236,244),bg1=Color3.fromRGB(222,227,238),
        bg2=Color3.fromRGB(209,215,228),bg3=Color3.fromRGB(195,202,218),
        bg4=Color3.fromRGB(179,187,206),brd=Color3.fromRGB(164,173,194),
        brd2=Color3.fromRGB(144,154,178),acc=Color3.fromRGB(42,115,210),
        txt=Color3.fromRGB(28,33,54),  txt2=Color3.fromRGB(76,85,115),
        txt3=Color3.fromRGB(138,146,170),grn=Color3.fromRGB(28,160,85),
        white=Color3.fromRGB(255,255,255),
    },
    Crimson = {
        bg0=Color3.fromRGB(10,6,6),    bg1=Color3.fromRGB(16,9,9),
        bg2=Color3.fromRGB(22,12,12),  bg3=Color3.fromRGB(30,16,16),
        bg4=Color3.fromRGB(38,20,20),  brd=Color3.fromRGB(48,26,26),
        brd2=Color3.fromRGB(64,34,34), acc=Color3.fromRGB(200,30,30),
        txt=Color3.fromRGB(230,200,200),txt2=Color3.fromRGB(148,115,115),
        txt3=Color3.fromRGB(82,58,58), grn=Color3.fromRGB(65,195,115),
        white=Color3.fromRGB(255,255,255),
    },
    Void = {
        bg0=Color3.fromRGB(4,4,4),     bg1=Color3.fromRGB(8,8,8),
        bg2=Color3.fromRGB(12,12,12),  bg3=Color3.fromRGB(17,17,17),
        bg4=Color3.fromRGB(22,22,22),  brd=Color3.fromRGB(28,28,28),
        brd2=Color3.fromRGB(38,38,38), acc=Color3.fromRGB(185,185,185),
        txt=Color3.fromRGB(200,200,200),txt2=Color3.fromRGB(115,115,115),
        txt3=Color3.fromRGB(60,60,60), grn=Color3.fromRGB(65,195,115),
        white=Color3.fromRGB(255,255,255),
    },
}

local C           = Themes.Default
local MenuKeybind = Enum.KeyCode.Insert
local _anyBindWaiting = false

-- ════════════════════════════════════════════════════════
-- EXECUTOR FUNCTION CHECKS
-- ════════════════════════════════════════════════════════
local UnsupportedFunctions = {}
local AllFunctions = {}

local function CheckFn(name, fn, desc, cat, features)
    local supported = fn ~= nil
    table.insert(AllFunctions, {name=name, desc=desc, cat=cat or "Other", supported=supported, features=features or ""})
    if not supported then
        table.insert(UnsupportedFunctions, {name=name, desc=desc, cat=cat or "Other", features=features or ""})
    end
end

CheckFn("readfile",   readfile,   "Read saved config files from disk", "Filesystem", "Config: Load, Auto-Load")
CheckFn("writefile",  writefile,  "Write config files to disk",        "Filesystem", "Config: Save, Auto-Load")
CheckFn("makefolder", makefolder, "Create folders for configs",        "Filesystem", "Config: Save, Load")
CheckFn("isfolder",   isfolder,   "Check if a folder exists",          "Filesystem", "Config: Save, Load")
CheckFn("isfile",     isfile,     "Check if a file exists",            "Filesystem", "Config: Load, Delete")
CheckFn("listfiles",  listfiles,  "List saved config files",           "Filesystem", "Config: List")
CheckFn("delfile",    delfile,    "Delete config files",               "Filesystem", "Config: Delete")
CheckFn("setclipboard",setclipboard,"Copy text to clipboard",          "Clipboard",  "Socials: Copy Discord/YouTube")
CheckFn("request",    request or http_request or (syn and syn.request), "HTTP requests to external servers", "HTTP", "")
CheckFn("queue_on_teleport", queue_on_teleport or queueonteleport or (syn and syn.queue_on_teleport),
        "Run script after server teleport", "Teleport", "")
CheckFn("Drawing",    Drawing,    "Draw 2D shapes over the game",      "Drawing", "")
CheckFn("getgenv",    getgenv,    "Access global environment",         "Environment", "")
CheckFn("loadstring", loadstring, "Compile and run Lua strings",       "Execution", "")
CheckFn("hookfunction", hookfunction or (debug and debug.sethook), "Hook/intercept function calls", "Hooking", "")
CheckFn("getrawmetatable", getrawmetatable, "Access raw metatables",   "Metatables", "")

local FeatureGuards = {}

-- ════════════════════════════════════════════════════════
-- CONFIG SYSTEM
-- ════════════════════════════════════════════════════════
local Flags, Setters = {}, {}
local GameID = tostring(game.GameId ~= 0 and game.GameId or game.PlaceId)

local ConfigManager = {
    BaseFolder = "DARKHUB_Configs",
    GameFolder = "DARKHUB_Configs/" .. GameID,
}
ConfigManager.AutoLoadFile = ConfigManager.GameFolder .. "/autoload.txt"

function ConfigManager:Init()
    if isfolder then
        if not isfolder(self.BaseFolder) then makefolder(self.BaseFolder) end
        if not isfolder(self.GameFolder)  then makefolder(self.GameFolder)  end
    end
end

local function SafeWrite(path, data)
    if writefile then pcall(function() writefile(path, data) end) end
end

local function SafeRead(path)
    if readfile then
        local ok, r = pcall(function() return readfile(path) end)
        if ok then return r end
    end
    return nil
end

function ConfigManager:Save(name)
    self:Init()
    if not writefile then return false, "writefile not supported" end
    SafeWrite(self.GameFolder.."/"..name..".json", HttpService:JSONEncode(Flags))
    return true, "Saved: "..name
end

function ConfigManager:Load(name)
    local data = SafeRead(self.GameFolder.."/"..name..".json")
    if data then
        local ok, d = pcall(function() return HttpService:JSONDecode(data) end)
        if ok and type(d) == "table" then
            for k,v in pairs(d) do
                if Setters[k] then Setters[k](v) else Flags[k] = v end
            end
            return true, "Loaded: "..name
        end
        return false, "Config corrupted"
    end
    return false, "Config not found"
end

function ConfigManager:Delete(name)
    local path = self.GameFolder.."/"..name..".json"
    if isfile and isfile(path) and delfile then
        pcall(function() delfile(path) end)
        if SafeRead(self.AutoLoadFile) == name then SafeWrite(self.AutoLoadFile, "") end
        return true, "Deleted: "..name
    end
    return false, "File not found"
end

function ConfigManager:SetAutoLoad(name)
    self:Init()
    if isfile and isfile(self.GameFolder.."/"..name..".json") then
        SafeWrite(self.AutoLoadFile, name)
        return true, "Auto-load set to: "..name
    end
    return false, "Config does not exist"
end

function ConfigManager:ResetAutoLoad()
    self:Init(); SafeWrite(self.AutoLoadFile, "")
    return true, "Auto-load cleared"
end

function ConfigManager:GetList()
    self:Init(); local list = {}
    if isfolder and listfiles then
        for _, f in ipairs(listfiles(self.GameFolder)) do
            if f:match("%.json$") then
                table.insert(list, f:match("([^/^\\]+)%.json$"))
            end
        end
    end
    return list
end

-- ════════════════════════════════════════════════════════
-- UI HELPERS
-- ════════════════════════════════════════════════════════
local GUI = Instance.new("ScreenGui")
GUI.Name           = "DARKHUB_Menu"
GUI.ResetOnSpawn   = false
GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
GUI.IgnoreGuiInset = true
GUI.Parent         = CoreGui

local function Frame(parent, size, pos, bg, radius)
    local f = Instance.new("Frame", parent)
    f.Size=size; f.Position=pos; f.BackgroundColor3=bg or C.bg1; f.BorderSizePixel=0
    if radius then Instance.new("UICorner",f).CornerRadius=UDim.new(0,radius) end
    return f
end

local function Stroke(parent, color, thick)
    local s=Instance.new("UIStroke",parent); s.Color=color or C.brd; s.Thickness=thick or 1; return s
end

local function Lbl(parent, text, size, color, font, xa)
    local l=Instance.new("TextLabel",parent)
    l.Size=UDim2.new(1,0,1,0); l.Position=UDim2.new(0,0,0,0)
    l.BackgroundTransparency=1; l.Text=text
    l.TextSize=size or 13; l.TextColor3=color or C.txt
    l.Font=font or Enum.Font.GothamMedium
    l.TextXAlignment=xa or Enum.TextXAlignment.Left
    l.TextTruncate=Enum.TextTruncate.AtEnd
    return l
end

local function Btn(parent, size, pos, bg, radius)
    local b=Instance.new("TextButton",parent)
    b.Size=size; b.Position=pos; b.BackgroundColor3=bg or C.bg3
    b.BorderSizePixel=0; b.Text=""; b.AutoButtonColor=false
    if radius then Instance.new("UICorner",b).CornerRadius=UDim.new(0,radius) end
    return b
end

-- ════════════════════════════════════════════════════════
-- THEME SWITCHER
-- ════════════════════════════════════════════════════════
local function ApplyTheme(name)
    local new = Themes[name]; if not new then return end
    local old = C; C = new
    for _, obj in ipairs(GUI:GetDescendants()) do
        pcall(function()
            for k, oc in pairs(old) do
                if obj:IsA("GuiObject") and obj.BackgroundColor3==oc then obj.BackgroundColor3=new[k] end
                if (obj:IsA("TextLabel") or obj:IsA("TextBox") or obj:IsA("TextButton")) and obj.TextColor3==oc then obj.TextColor3=new[k] end
                if obj:IsA("UIStroke") and obj.Color==oc then obj.Color=new[k] end
            end
        end)
    end
end

-- ════════════════════════════════════════════════════════
-- MAIN WINDOW
-- ════════════════════════════════════════════════════════
local winW = isMobile and 0.88 or 0.46
local winH = isMobile and 0.76 or 0.56

local WIN = Frame(GUI, UDim2.new(winW,0,winH,0), UDim2.new(0.5,0,0.5,0), C.bg0, 8)
WIN.AnchorPoint=Vector2.new(0.5,0.5); WIN.ClipsDescendants=true
Stroke(WIN, C.brd, 1)

local SC = Instance.new("UISizeConstraint", WIN)
SC.MinSize=Vector2.new(290,230); SC.MaxSize=Vector2.new(800,600)

-- TITLE BAR
local TBarH = isMobile and 40 or 34
local TBar  = Frame(WIN, UDim2.new(1,0,0,TBarH), UDim2.new(0,0,0,0), C.bg0)
Frame(TBar, UDim2.new(1,0,0,2), UDim2.new(0,0,1,-2), C.acc)

local LogoL = Lbl(TBar, '<font color="#D73737">DARK</font>HUB',
    isMobile and 14 or 13, C.white, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
LogoL.Size=UDim2.new(0,120,1,-2); LogoL.RichText=true

local BadgeF = Frame(TBar, UDim2.new(0,60,0,isMobile and 18 or 16),
    UDim2.new(0,120,0.5,isMobile and -9 or -8), C.bg3, 3)
Stroke(BadgeF, C.brd2, 1)
Lbl(BadgeF, "v1.0", 8, C.txt2, Enum.Font.GothamMedium, Enum.TextXAlignment.Center)

local bSz = isMobile and 34 or 28
local CloseBtn = Btn(TBar, UDim2.new(0,bSz,0,bSz), UDim2.new(1,-(bSz+4),0.5,-bSz/2), C.bg0)
Lbl(CloseBtn,"X",isMobile and 14 or 13,Color3.fromRGB(180,50,50),Enum.Font.GothamBold,Enum.TextXAlignment.Center)

local SettingsBtn = Btn(TBar, UDim2.new(0,bSz,0,bSz), UDim2.new(1,-(bSz*2+8),0.5,-bSz/2), C.bg0)
Lbl(SettingsBtn,"⚙",isMobile and 17 or 16,C.txt,Enum.Font.GothamBold,Enum.TextXAlignment.Center)

-- OPEN BUTTON
local oBW = isMobile and 190 or 210
local oBH = isMobile and 44 or 40

local OpenBtn = Frame(GUI, UDim2.new(0,oBW,0,oBH), UDim2.new(0,16,1,-(oBH+16)), C.bg1, 8)
OpenBtn.Visible=false; OpenBtn.ClipsDescendants=true
Stroke(OpenBtn, C.brd2, 1)
Frame(OpenBtn, UDim2.new(0,3,1,0), UDim2.new(0,0,0,0), C.acc, 0)

local OpenIconL = Lbl(OpenBtn,"⚡",isMobile and 16 or 14,C.acc,Enum.Font.GothamBold,Enum.TextXAlignment.Center)
OpenIconL.Size=UDim2.new(0,28,1,0); OpenIconL.Position=UDim2.new(0,7,0,0)

local OpenText
if isMobile then
    OpenText = Lbl(OpenBtn, '<font color="#D73737">DARK</font>HUB <font color="#787B8A">| Tap to open</font>',
        11, C.white, Enum.Font.GothamBold, Enum.TextXAlignment.Left)
else
    OpenText = Lbl(OpenBtn, '<font color="#D73737">DARK</font>HUB <font color="#787B8A">| '..MenuKeybind.Name..'</font>',
        11, C.white, Enum.Font.GothamBold, Enum.TextXAlignment.Left)
end
OpenText.Size=UDim2.new(1,-40,1,0); OpenText.Position=UDim2.new(0,36,0,0); OpenText.RichText=true

local OBClick = Btn(OpenBtn, UDim2.new(1,0,1,0), UDim2.new(0,0,0,0), C.bg0, 8)
OBClick.BackgroundTransparency=1

-- CUSTOM CURSOR
local CursorGui = Instance.new("ScreenGui")
CursorGui.Name           = "_DarkHubCursor"
CursorGui.ResetOnSpawn   = false
CursorGui.IgnoreGuiInset = true
CursorGui.DisplayOrder   = 2147483647
CursorGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
CursorGui.Enabled        = false
CursorGui.Parent         = CoreGui

local CursorDot = Instance.new("Frame")
CursorDot.Size = UDim2.new(0, 8, 0, 8)
CursorDot.AnchorPoint = Vector2.new(0.5, 0.5)
CursorDot.BackgroundColor3 = Color3.fromRGB(218, 38, 38)
CursorDot.BorderSizePixel = 0
CursorDot.ZIndex = 10
CursorDot.Parent = CursorGui
Instance.new("UICorner", CursorDot).CornerRadius = UDim.new(1, 0)

RunService.RenderStepped:Connect(function()
    if not CursorGui.Enabled then return end
    local mp = UIS:GetMouseLocation()
    CursorDot.Position = UDim2.new(0, mp.X, 0, mp.Y)
    if UIS.MouseIconEnabled then UIS.MouseIconEnabled = false end
end)

local function ShowCursor()
    if isMobile then return end
    CursorGui.Enabled = true
    UIS.MouseIconEnabled = false
end

local function HideCursor()
    CursorGui.Enabled = false
    UIS.MouseIconEnabled = true
end

-- OPEN / CLOSE
local function OpenMenu()
    WIN.Visible=true; OpenBtn.Visible=false; WIN.Size=UDim2.new(0,0,0,0)
    TweenS:Create(WIN, TweenInfo.new(0.28,Enum.EasingStyle.Back,Enum.EasingDirection.Out),
        {Size=UDim2.new(winW,0,winH,0)}):Play()
    ShowCursor()
end

local function CloseMenu()
    HideCursor()
    TweenS:Create(WIN, TweenInfo.new(0.18,Enum.EasingStyle.Quad,Enum.EasingDirection.In),
        {Size=UDim2.new(0,0,0,0)}):Play()
    task.delay(0.20, function()
        WIN.Visible=false; WIN.Size=UDim2.new(winW,0,winH,0)
        OpenBtn.Visible=true
        OpenBtn.Size=UDim2.new(0,oBW-14,0,oBH-4)
        OpenBtn.Position=UDim2.new(0,22,1,-(oBH+12))
        TweenS:Create(OpenBtn, TweenInfo.new(0.24,Enum.EasingStyle.Back,Enum.EasingDirection.Out),
            {Size=UDim2.new(0,oBW,0,oBH), Position=UDim2.new(0,16,1,-(oBH+16))}):Play()
    end)
end

CloseBtn.MouseButton1Click:Connect(CloseMenu)
OBClick.MouseButton1Click:Connect(OpenMenu)

do
    local drag,ds,sp=false,nil,nil
    TBar.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            drag=true; ds=i.Position; sp=WIN.Position end end)
    TBar.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            drag=false end end)
    UIS.InputChanged:Connect(function(i)
        if drag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local d=i.Position-ds
            WIN.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y) end end)
end

UIS.InputBegan:Connect(function(i,g)
    if not g and not _anyBindWaiting and i.KeyCode==MenuKeybind then
        if WIN.Visible then CloseMenu() else OpenMenu() end
    end
end)

OpenBtn.Visible = not WIN.Visible

-- ════════════════════════════════════════════════════════
-- TAB BAR  (replaced: Dark Hub feature tabs)
-- ════════════════════════════════════════════════════════
local TABS    = {"Main","Farm","Combat","Visuals","Socials","Config","Credits"}
local tabBarH = isMobile and 32 or 28
local TabBarF = Frame(WIN, UDim2.new(1,0,0,tabBarH), UDim2.new(0,0,0,TBarH), C.bg1)
Frame(TabBarF, UDim2.new(1,0,0,1), UDim2.new(0,0,1,-1), C.brd)

local cOff = TBarH+tabBarH
local CArea = Frame(WIN, UDim2.new(1,0,1,-cOff), UDim2.new(0,0,0,cOff), C.bg1)

local TabBtns,TabPages,ActiveTab={},{},1

local function SetTab(idx)
    ActiveTab=idx
    for i,b in pairs(TabBtns) do
        local on=(i==idx)
        b.BackgroundColor3 = on and C.bg3 or C.bg1
        local bl=b:FindFirstChildOfClass("TextLabel")
        if bl then bl.TextColor3 = on and C.white or C.txt2 end
        local ul=b:FindFirstChild("_ul")
        if ul then ul.BackgroundColor3 = on and C.acc or C.bg1 end
    end
    for i,p in pairs(TabPages) do p.Visible=(i==idx) end
end

SettingsBtn.MouseButton1Click:Connect(function() SetTab(#TABS+1) end)

local tsW = 1/#TABS
for i,name in ipairs(TABS) do
    local b=Btn(TabBarF, UDim2.new(tsW,0,1,-1), UDim2.new((i-1)*tsW,0,0,0), C.bg1)
    local bl=Lbl(b,name,isMobile and 9 or 10, C.txt2, Enum.Font.GothamMedium, Enum.TextXAlignment.Center)
    local ul=Frame(b, UDim2.new(1,0,0,2), UDim2.new(0,0,1,-2), C.bg1); ul.Name="_ul"
    b.MouseEnter:Connect(function()
        if ActiveTab~=i then TweenS:Create(bl,TweenInfo.new(0.1),{TextColor3=C.txt}):Play() end
    end)
    b.MouseLeave:Connect(function()
        if ActiveTab~=i then TweenS:Create(bl,TweenInfo.new(0.1),{TextColor3=C.txt2}):Play() end
    end)
    b.MouseButton1Click:Connect(function() SetTab(i) end)
    TabBtns[i]=b
end

local function MakePage()
    local p=Frame(CArea,UDim2.new(1,0,1,0),UDim2.new(0,0,0,0),C.bg1)
    p.Visible=false; table.insert(TabPages,p); return p
end

-- ════════════════════════════════════════════════════════
-- TOAST NOTIFICATIONS
-- ════════════════════════════════════════════════════════
local ActiveToasts = {}
local MAX_TOASTS   = 5

local function Toast(title, msg, kind)
    local col = kind=="err"  and C.acc
             or kind=="ok"   and C.grn
             or kind=="warn" and Color3.fromRGB(235,160,25)
             or C.txt2

    if #ActiveToasts >= MAX_TOASTS then
        local oldest = table.remove(ActiveToasts, 1)
        if oldest and oldest.Parent then oldest:Destroy() end
    end

    local tW = isMobile and 210 or 240
    local t  = Frame(GUI, UDim2.new(0,tW,0,50), UDim2.new(1,20,0,20), C.bg0, 6)
    t.ClipsDescendants=true
    Stroke(t, C.brd2, 1)
    Frame(t, UDim2.new(0,3,1,0), UDim2.new(0,0,0,0), col, 2)

    local tT=Lbl(t,title,isMobile and 11 or 12,C.white,Enum.Font.GothamBold)
    tT.Size=UDim2.new(1,-16,0,18); tT.Position=UDim2.new(0,11,0,7)

    local tM=Lbl(t,msg,isMobile and 10 or 10,C.txt2,Enum.Font.Gotham)
    tM.Size=UDim2.new(1,-16,0,16); tM.Position=UDim2.new(0,11,0,26)
    tM.TextTruncate=Enum.TextTruncate.AtEnd

    table.insert(ActiveToasts,t)

    local function Restack()
        local yo=20
        for _,toast in ipairs(ActiveToasts) do
            TweenS:Create(toast, TweenInfo.new(0.22,Enum.EasingStyle.Back,Enum.EasingDirection.Out),
                {Position=UDim2.new(1,-(tW+16),0,yo)}):Play()
            yo=yo+58
        end
    end
    Restack()

    task.delay(3.5, function()
        local idx=table.find(ActiveToasts,t)
        if idx then table.remove(ActiveToasts,idx); Restack() end
        TweenS:Create(t, TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.In),
            {Position=UDim2.new(1,20,0,t.Position.Y.Offset)}):Play()
        task.delay(0.22, function() t:Destroy() end)
    end)
end

-- Local wrapper matching old DARK HUB notify signature
local function notify(title, desc, duration) Toast(title or "DARK HUB", desc or "", "ok") end

-- ════════════════════════════════════════════════════════
-- UNSUPPORTED FUNCTION NOTIFICATION
-- ════════════════════════════════════════════════════════
local function ShowUnsupportedNotif(funcName, featureName)
    local nW = isMobile and 264 or 308
    local nH = isMobile and 118 or 106

    local notif = Frame(GUI, UDim2.new(0,nW,0,nH), UDim2.new(0.5,-nW/2,0,-(nH+12)), C.bg0, 10)
    notif.ZIndex=200; notif.ClipsDescendants=true
    Stroke(notif, C.acc, 2)
    Frame(notif, UDim2.new(1,0,0,3), UDim2.new(0,0,0,0), C.acc)

    local titleL = Lbl(notif, "⚠  EXECUTOR DOES NOT SUPPORT THIS",
        isMobile and 11 or 10, C.acc, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
    titleL.Size     = UDim2.new(1,-16,0,isMobile and 20 or 18)
    titleL.Position = UDim2.new(0,8,0,isMobile and 9 or 8)

    local fnLine = Lbl(notif, '"'..funcName..'"  required for:  '..featureName,
        isMobile and 10 or 10, C.white, Enum.Font.GothamMedium, Enum.TextXAlignment.Center)
    fnLine.Size = UDim2.new(1,-16,0,isMobile and 16 or 15)
    fnLine.Position = UDim2.new(0,8,0,isMobile and 32 or 29)
    fnLine.TextWrapped = true

    local expL = Lbl(notif, "Your Executor does not support this function",
        isMobile and 10 or 10, C.txt2, Enum.Font.Gotham, Enum.TextXAlignment.Center)
    expL.Size = UDim2.new(1,-16,0,isMobile and 15 or 14)
    expL.Position = UDim2.new(0,8,0,isMobile and 50 or 46)
    expL.TextWrapped = true

    local cdSz = isMobile and 32 or 28
    local cdBadge = Frame(notif, UDim2.new(0,cdSz,0,cdSz), UDim2.new(1,-(cdSz+8),1,-(cdSz+8)), C.bg3, cdSz/2)
    Stroke(cdBadge, C.acc, 1)
    local cdLbl = Lbl(cdBadge,"10",isMobile and 10 or 9,C.acc,Enum.Font.GothamBold,Enum.TextXAlignment.Center)

    TweenS:Create(notif, TweenInfo.new(0.32,Enum.EasingStyle.Back,Enum.EasingDirection.Out),
        {Position=UDim2.new(0.5,-nW/2,0,isMobile and 14 or 10)}):Play()

    task.spawn(function()
        for i = 10, 1, -1 do
            if not notif.Parent then return end
            cdLbl.Text = tostring(i)
            task.wait(1)
        end
        if not notif.Parent then return end
        TweenS:Create(notif, TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.In),
            {Position=UDim2.new(0.5,-nW/2,0,-(nH+12))}):Play()
        task.delay(0.22, function() pcall(function() notif:Destroy() end) end)
    end)
end

-- ════════════════════════════════════════════════════════
-- LAYOUT HELPERS
-- ════════════════════════════════════════════════════════
local function MakeScroll(parent)
    local sf=Instance.new("ScrollingFrame",parent)
    sf.Size=UDim2.new(1,0,1,0); sf.BackgroundTransparency=1; sf.BorderSizePixel=0
    sf.ScrollBarThickness=isMobile and 3 or 2; sf.ScrollBarImageColor3=C.brd2
    sf.CanvasSize=UDim2.new(0,0,0,0); sf.AutomaticCanvasSize=Enum.AutomaticSize.Y
    return sf
end

local function MakeSection(parent, text, yOff)
    local f=Frame(parent,UDim2.new(1,-32,0,20),UDim2.new(0,16,0,yOff),C.bg0)
    f.BackgroundTransparency=1
    Lbl(f,text:upper(),8,C.txt3,Enum.Font.GothamBold).Size=UDim2.new(0,200,1,0)
    Frame(f,UDim2.new(1,-206,0,1),UDim2.new(0,202,0.5,0),C.brd)
    return yOff+26
end

local rowH  = isMobile and 30 or 26
local rowGap= isMobile and 36 or 32

local function MakeLabel(parent, text, yOff, color)
    local lH = isMobile and 20 or 17
    local l = Lbl(parent, text, isMobile and 11 or 10, color or C.txt2, Enum.Font.Gotham)
    l.Size=UDim2.new(1,-32,0,lH); l.Position=UDim2.new(0,16,0,yOff); l.TextWrapped=true
    return yOff+lH+6, l
end

-- ════════════════════════════════════════════════════════
-- TOGGLE
-- ════════════════════════════════════════════════════════
local function MakeToggle(parent, text, yOff, flag, callback)
    local row=Frame(parent,UDim2.new(1,-32,0,rowH),UDim2.new(0,16,0,yOff),C.bg3)
    row.BackgroundTransparency=1
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,4)

    local nL=Lbl(row,text,isMobile and 12 or 11,C.txt,Enum.Font.Gotham)
    nL.Size=UDim2.new(1,-48,1,0); nL.TextTruncate=Enum.TextTruncate.AtEnd

    local pW=isMobile and 36 or 32; local pH=isMobile and 18 or 15
    local pill=Frame(row,UDim2.new(0,pW,0,pH),UDim2.new(1,-pW-2,0.5,-pH/2),C.bg4,pH/2)
    Stroke(pill,C.brd,1)
    local kSz=pH-4
    local knob=Frame(pill,UDim2.new(0,kSz,0,kSz),UDim2.new(0,2,0.5,-kSz/2),C.txt2,kSz/2)

    local function Refresh()
        if Flags[flag] then
            TweenS:Create(pill,TweenInfo.new(0.12),{BackgroundColor3=C.acc}):Play()
            TweenS:Create(knob,TweenInfo.new(0.12),{Position=UDim2.new(0,pW-kSz-2,0.5,-kSz/2),BackgroundColor3=C.white}):Play()
        else
            TweenS:Create(pill,TweenInfo.new(0.12),{BackgroundColor3=C.bg4}):Play()
            TweenS:Create(knob,TweenInfo.new(0.12),{Position=UDim2.new(0,2,0.5,-kSz/2),BackgroundColor3=C.txt2}):Play()
        end
    end
    Refresh()
    Setters[flag]=function(v) Flags[flag]=v; Refresh(); if callback then callback(v) end end

    local cb=Btn(row,UDim2.new(1,0,1,0),UDim2.new(0,0,0,0),C.bg0); cb.BackgroundTransparency=1
    cb.MouseEnter:Connect(function() TweenS:Create(row,TweenInfo.new(0.08),{BackgroundTransparency=0.82}):Play() end)
    cb.MouseLeave:Connect(function() TweenS:Create(row,TweenInfo.new(0.12),{BackgroundTransparency=1}):Play() end)
    cb.MouseButton1Click:Connect(function()
        local requiredFn = FeatureGuards[flag]
        if requiredFn then
            local fnSupported = true
            for _, fn in ipairs(AllFunctions) do
                if fn.name == requiredFn then fnSupported = fn.supported; break end
            end
            if not fnSupported then
                Flags[flag] = true; Refresh()
                task.delay(0.35, function()
                    Flags[flag] = false; Refresh()
                    if callback then callback(false) end
                end)
                ShowUnsupportedNotif(requiredFn, text)
                return
            end
        end
        Flags[flag]=not Flags[flag]; Refresh()
        if callback then callback(Flags[flag]) end
    end)
    return yOff+rowGap
end

-- ════════════════════════════════════════════════════════
-- SLIDER
-- ════════════════════════════════════════════════════════
local function MakeSlider(parent, text, yOff, flag, minV, maxV, fmt, callback)
    local cont=Frame(parent,UDim2.new(1,-32,0,48),UDim2.new(0,16,0,yOff),C.bg0)
    cont.BackgroundTransparency=1

    local topH=isMobile and 20 or 17
    Lbl(cont,text,isMobile and 12 or 11,C.txt,Enum.Font.Gotham).Size=UDim2.new(1,-58,0,topH)

    local vL=Lbl(cont,"",isMobile and 11 or 10,C.txt2,Enum.Font.GothamMedium,Enum.TextXAlignment.Right)
    vL.Size=UDim2.new(0,52,0,topH); vL.Position=UDim2.new(1,-52,0,0)

    local tY=isMobile and 28 or 24
    local track=Frame(cont,UDim2.new(1,0,0,5),UDim2.new(0,0,0,tY),C.bg4,3)
    local fill=Frame(track,UDim2.new(0,0,1,0),UDim2.new(0,0,0,0),C.acc,3)
    local tSz=isMobile and 14 or 12
    local thumb=Frame(track,UDim2.new(0,tSz,0,tSz),UDim2.new(0,-tSz/2,0.5,-tSz/2),C.white,tSz/2)
    Stroke(thumb,C.brd2,1)

    local isDrag=false
    local isIntFormat = not fmt or fmt:match("%%[^.]*d") or fmt:match("%%[^.]*i") or fmt:match("%%[^.]*u")

    local function SetVal(v, fireCallback)
        local raw = math.clamp(v, minV, maxV)
        if isIntFormat then raw = math.floor(raw + 0.5) end
        Flags[flag] = raw
        local pct = (raw-minV)/(maxV-minV)
        fill.Size=UDim2.new(pct,0,1,0)
        thumb.Position=UDim2.new(pct,-tSz/2,0.5,-tSz/2)
        vL.Text = fmt and string.format(fmt, raw) or tostring(raw)
        if fireCallback and callback then callback(raw) end
    end

    SetVal(Flags[flag] or minV, false)
    Setters[flag]=function(v) SetVal(v,false) end

    local function P2V(ax)
        return minV+(maxV-minV)*math.clamp((ax-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
    end

    track.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            isDrag=true; SetVal(P2V(i.Position.X),false) end end)
    thumb.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            isDrag=true end end)
    UIS.InputChanged:Connect(function(i)
        if isDrag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            SetVal(P2V(i.Position.X),false) end end)
    UIS.InputEnded:Connect(function(i)
        if isDrag and (i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch) then
            isDrag=false
            SetVal(Flags[flag] or minV, true)
        end
    end)

    return yOff+(isMobile and 56 or 50)
end

-- ════════════════════════════════════════════════════════
-- ACTION BUTTON
-- ════════════════════════════════════════════════════════
local function MakeActionBtn(parent, text, yOff, callback)
    local bH=isMobile and 30 or 26
    local b=Btn(parent,UDim2.new(1,-32,0,bH),UDim2.new(0,16,0,yOff),C.bg3,4)
    Stroke(b,C.brd2,1)
    local l=Lbl(b,text,isMobile and 11 or 11,C.txt,Enum.Font.GothamMedium,Enum.TextXAlignment.Center)
    l.TextTruncate=Enum.TextTruncate.AtEnd
    b.MouseButton1Click:Connect(function()
        TweenS:Create(b,TweenInfo.new(0.07),{BackgroundColor3=C.acc}):Play()
        task.delay(0.13,function() TweenS:Create(b,TweenInfo.new(0.1),{BackgroundColor3=C.bg3}):Play() end)
        callback()
    end)
    return yOff+(isMobile and 38 or 32)
end

-- ════════════════════════════════════════════════════════
-- INPUT BOX
-- ════════════════════════════════════════════════════════
local function MakeInput(parent, text, placeholder, yOff, flag, callback)
    local cont=Frame(parent,UDim2.new(1,-32,0,48),UDim2.new(0,16,0,yOff),C.bg0)
    cont.BackgroundTransparency=1
    Lbl(cont,text,isMobile and 12 or 11,C.txt,Enum.Font.Gotham).Size=UDim2.new(1,0,0,isMobile and 19 or 17)

    local box=Instance.new("TextBox",cont)
    local bH=isMobile and 26 or 23
    box.Size=UDim2.new(1,0,0,bH); box.Position=UDim2.new(0,0,0,isMobile and 20 or 18)
    box.BackgroundColor3=C.bg3; box.BorderSizePixel=0
    box.Font=Enum.Font.GothamMedium; box.TextSize=isMobile and 11 or 11
    box.TextColor3=C.txt; box.PlaceholderColor3=C.txt3
    box.PlaceholderText=placeholder; box.Text=Flags[flag] or ""
    box.TextXAlignment=Enum.TextXAlignment.Left; box.ClearTextOnFocus=false
    Instance.new("UICorner",box).CornerRadius=UDim.new(0,4)
    Instance.new("UIPadding",box).PaddingLeft=UDim.new(0,7)
    local st=Stroke(box,C.brd2,1)
    Setters[flag]=function(v) Flags[flag]=v; box.Text=v end
    box:GetPropertyChangedSignal("Text"):Connect(function()
        Flags[flag]=box.Text; if callback then callback(box.Text) end end)
    box.Focused:Connect(function() st.Color=C.acc end)
    box.FocusLost:Connect(function() st.Color=C.brd2 end)
    return yOff+(isMobile and 54 or 48), box
end

-- ════════════════════════════════════════════════════════
-- SELECT
-- ════════════════════════════════════════════════════════
local function MakeSelect(parent, text, yOff, options, callback)
    local bH=isMobile and 30 or 26
    local b=Btn(parent,UDim2.new(1,-32,0,bH),UDim2.new(0,16,0,yOff),C.bg3,4)
    Stroke(b,C.brd2,1)
    local currentVal = options[1] or ""
    local bLbl=Lbl(b,text.."  :  "..currentVal,isMobile and 11 or 11,C.txt,Enum.Font.GothamMedium,Enum.TextXAlignment.Left)
    bLbl.Size=UDim2.new(1,-28,1,0); bLbl.Position=UDim2.new(0,10,0,0)
    local arrow=Lbl(b,"v",isMobile and 10 or 9,C.txt2,Enum.Font.GothamBold,Enum.TextXAlignment.Right)
    arrow.Size=UDim2.new(0,20,1,0); arrow.Position=UDim2.new(1,-22,0,0)

    b.MouseButton1Click:Connect(function()
        local popW  = isMobile and math.min(260, workspace.CurrentCamera.ViewportSize.X-20) or 240
        local itemH = isMobile and 36 or 30
        local popH  = math.min(#options*itemH+16, isMobile and 300 or 260)
        local pop=Frame(GUI,UDim2.new(0,popW,0,popH),UDim2.new(0,0,0,0),C.bg0,6)
        Stroke(pop,C.brd2,1); pop.ZIndex=110; pop.ClipsDescendants=true

        local absPos=b.AbsolutePosition
        local vp=workspace.CurrentCamera.ViewportSize
        local px=math.clamp(absPos.X, 4, vp.X-popW-4)
        local py=absPos.Y+b.AbsoluteSize.Y+4
        if py+popH > vp.Y-4 then py=absPos.Y-popH-4 end
        pop.Position=UDim2.new(0,px,0,py)

        local sc2=MakeScroll(pop)
        sc2.Size=UDim2.new(1,-4,1,-4); sc2.Position=UDim2.new(0,2,0,2)

        for i,opt in ipairs(options) do
            local isSelected = opt==currentVal
            local ib=Btn(sc2,UDim2.new(1,0,0,itemH),UDim2.new(0,0,0,(i-1)*itemH), isSelected and C.bg4 or C.bg3)
            Stroke(ib,C.brd,1)
            local dotSz=isMobile and 10 or 8
            local dotF=Frame(ib,UDim2.new(0,dotSz,0,dotSz),UDim2.new(0,isMobile and 12 or 10,0.5,-dotSz/2),
                isSelected and C.acc or C.bg4, dotSz/2)
            Stroke(dotF,C.brd2,1)
            local iL=Lbl(ib,opt,isMobile and 12 or 11,isSelected and C.white or C.txt,Enum.Font.GothamMedium)
            iL.Size=UDim2.new(1,-(dotSz+24),1,0); iL.Position=UDim2.new(0,dotSz+18,0,0)
            ib.MouseButton1Click:Connect(function()
                currentVal=opt
                bLbl.Text=text.."  :  "..currentVal
                if callback then callback(opt) end
                pop:Destroy()
            end)
        end

        local overlay=Btn(GUI,UDim2.new(1,0,1,0),UDim2.new(0,0,0,0),C.bg0)
        overlay.BackgroundTransparency=1; overlay.ZIndex=109
        overlay.MouseButton1Click:Connect(function() pop:Destroy(); overlay:Destroy() end)
    end)
    return yOff+(isMobile and 38 or 34)
end

-- ════════════════════════════════════════════════════════
-- BIND
-- ════════════════════════════════════════════════════════
local function MakeBind(parent, text, yOff, flag, callback)
    Flags[flag]=Flags[flag] or "None"
    local bH=isMobile and 30 or 26
    local row=Frame(parent,UDim2.new(1,-32,0,bH),UDim2.new(0,16,0,yOff),C.bg3)
    row.BackgroundTransparency=1
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,4)

    local nL=Lbl(row,text,isMobile and 12 or 11,C.txt,Enum.Font.Gotham)
    nL.Size=UDim2.new(1,-88,1,0)

    local bW=isMobile and 80 or 70
    local bindF=Frame(row,UDim2.new(0,bW,1,-4),UDim2.new(1,-bW,0.5,-(bH-4)/2),C.bg3,4)
    Stroke(bindF,C.brd2,1)
    local bL=Lbl(bindF,Flags[flag],isMobile and 10 or 9,C.txt2,Enum.Font.GothamMedium,Enum.TextXAlignment.Center)

    local waiting=false
    local function CancelWait() waiting=false; _anyBindWaiting=false; bL.Text=Flags[flag]; bindF.BackgroundColor3=C.bg3 end
    local function CommitBind(keyCode)
        waiting=false; _anyBindWaiting=false
        Flags[flag]=keyCode.Name; bL.Text=keyCode.Name; bindF.BackgroundColor3=C.bg3
        if callback then callback(keyCode) end
    end
    Setters[flag]=function(v) Flags[flag]=v; bL.Text=v end

    local cbZ=Btn(row,UDim2.new(1,0,1,0),UDim2.new(0,0,0,0),C.bg0); cbZ.BackgroundTransparency=1
    cbZ.MouseEnter:Connect(function() TweenS:Create(row,TweenInfo.new(0.08),{BackgroundTransparency=0.82}):Play() end)
    cbZ.MouseLeave:Connect(function() TweenS:Create(row,TweenInfo.new(0.12),{BackgroundTransparency=1}):Play() end)
    cbZ.MouseButton1Click:Connect(function()
        if waiting then return end
        waiting=true; _anyBindWaiting=true
        bL.Text="..."; bindF.BackgroundColor3=C.acc
    end)
    cbZ.MouseButton2Click:Connect(function()
        if waiting then CancelWait() end
        Flags[flag]="None"; bL.Text="None"; bindF.BackgroundColor3=C.bg3
        Toast("Bind","Bind cleared","warn")
    end)
    UIS.InputBegan:Connect(function(inp, gpe)
        if not waiting then return end
        if inp.UserInputType == Enum.UserInputType.Keyboard then
            if inp.KeyCode == Enum.KeyCode.Escape then CancelWait()
            else CommitBind(inp.KeyCode) end
        end
    end)
    return yOff+rowGap
end

-- ════════════════════════════════════════════════════════
-- ═══════════════════ DARK HUB LOGIC ═════════════════════
-- ════════════════════════════════════════════════════════
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

local aimbotFOV         = 120
local autoFarmEnabled   = false
local selectedPlayerObj = nil
local espData           = {}

-- Pre-seed defaults so config loaders / UI use correct initial values
Flags.WalkSpeedMultiplier = 1.25
Flags.AimbotFOV           = 120

local function getRootPart()
    local c = lp.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function getCharacter()
    local c = lp.Character
    if not c then return nil end
    local h = c:FindFirstChildOfClass("Humanoid")
    if not h or h.Health <= 0 then return nil end
    return c:FindFirstChild("HumanoidRootPart")
end

-- AUTO FARM
local function tweenToPosition(targetPos)
    if not autoFarmEnabled then return end
    local root = getRootPart()
    if not root then return end
    local dist = (targetPos - root.Position).Magnitude
    local t = dist / 25
    root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
    local tw = TweenS:Create(root, TweenInfo.new(t, Enum.EasingStyle.Linear), {CFrame = CFrame.new(targetPos)})
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
                    if fireproximityprompt then fireproximityprompt(obj)
                    else
                        obj:Hold(lp); task.wait(obj.HoldDuration or 2); obj:Release()
                    end
                end)
                return true
            end
        end
    end
end

local function findToolInInventory(pat)
    if not autoFarmEnabled then return end
    local char = lp.Character; if not char then return end
    local hum  = char:FindFirstChildOfClass("Humanoid")
    local bp   = lp:FindFirstChildOfClass("Backpack")
    for _, t in ipairs(char:GetChildren()) do
        if t:IsA("Tool") and string.find(string.lower(t.Name), string.lower(pat)) then return true end
    end
    if bp and hum then
        for _, t in ipairs(bp:GetChildren()) do
            if t:IsA("Tool") and string.find(string.lower(t.Name), string.lower(pat)) then
                hum:EquipTool(t); task.wait(0.4); return true
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

-- ESP
local function removeESP(player)
    if espData[player] then
        if espData[player].Billboard then espData[player].Billboard:Destroy() end
        if espData[player].Highlight then espData[player].Highlight:Destroy() end
        if espData[player].CharConn  then espData[player].CharConn:Disconnect() end
        espData[player] = nil
    end
end

local function addESP(player)
    if player == lp then return end
    espData[player] = {}
    local function setup(char)
        removeESP(player)
        espData[player] = {}
        if not char then return end
        local head = char:WaitForChild("Head", 5)
        local hum  = char:WaitForChild("Humanoid", 5)
        if not head or not hum then return end

        local bb = Instance.new("BillboardGui")
        bb.Name="ESP_NameTag"; bb.Adornee=head
        bb.Size=UDim2.new(0, 100, 0, 40)
        bb.StudsOffset=Vector3.new(0, 2, 0)
        bb.AlwaysOnTop=true; bb.Parent=head
        local nameL = Instance.new("TextLabel", bb)
        nameL.BackgroundTransparency=1; nameL.Size=UDim2.new(1,0,1,0)
        nameL.Font=Enum.Font.GothamBold; nameL.Text=player.DisplayName
        nameL.TextColor3=Color3.fromRGB(0,255,255); nameL.TextSize=14; nameL.TextStrokeTransparency=0.5

        local hl = Instance.new("Highlight")
        hl.Name="ESP_Highlight"; hl.Adornee=char
        hl.FillColor=Color3.fromRGB(0,170,255); hl.FillTransparency=0.5
        hl.OutlineColor=Color3.fromRGB(255,255,255); hl.OutlineTransparency=0
        hl.Parent=char

        espData[player].Billboard=bb
        espData[player].Highlight=hl
        espData[player].Character=char
    end
    if player.Character then setup(player.Character) end
    espData[player].CharConn = player.CharacterAdded:Connect(setup)
end

local function canSeeTarget(targetHead)
    local char = lp.Character
    local origin = Camera.CFrame.Position
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { char, char and char:FindFirstChild("Head") }
    params.IgnoreWater = true
    local r = Workspace:Raycast(origin, targetHead.Position - origin, params)
    if r then return r.Instance:IsDescendantOf(targetHead.Parent) end
    return true
end

for _, p in ipairs(Players:GetPlayers()) do if p ~= lp then addESP(p) end end
Players.PlayerAdded:Connect(function(p) if p ~= lp then addESP(p) end end)
Players.PlayerRemoving:Connect(function(p) removeESP(p) end)

-- ════════════════════════════════════════════════════════
-- FLOATING AUTO FARM GUI
-- ════════════════════════════════════════════════════════
local autoFarmGui = Instance.new("ScreenGui")
autoFarmGui.Name="DARKHUB_AutoFarmGUI"; autoFarmGui.Parent=CoreGui
autoFarmGui.ResetOnSpawn=false; autoFarmGui.Enabled=false

local AF_F = Instance.new("Frame", autoFarmGui)
AF_F.Size=UDim2.new(0,200,0,90); AF_F.Position=UDim2.new(0.05,0,0.2,0)
AF_F.BackgroundColor3=C.bg1; AF_F.BorderSizePixel=0; AF_F.Active=true; AF_F.Draggable=true
Instance.new("UICorner",AF_F).CornerRadius=UDim.new(0,8)
Stroke(AF_F, C.acc, 1)

local AF_T = Instance.new("TextLabel", AF_F)
AF_T.BackgroundTransparency=1; AF_T.Size=UDim2.new(1,0,0,30)
AF_T.Text="BLANK CARD AUTO-FARM"; AF_T.TextColor3=C.txt
AF_T.TextSize=12; AF_T.Font=Enum.Font.GothamBold

local farmBtn = Instance.new("TextButton", AF_F)
farmBtn.Size=UDim2.new(0.85,0,0,35); farmBtn.Position=UDim2.new(0.075,0,0.45,0)
farmBtn.BackgroundColor3=C.bg3; farmBtn.TextColor3=Color3.fromRGB(255,100,100)
farmBtn.Text="Auto Farm: OFF"; farmBtn.TextSize=12; farmBtn.Font=Enum.Font.GothamBold
farmBtn.BorderSizePixel=0; farmBtn.AutoButtonColor=false
Instance.new("UICorner",farmBtn).CornerRadius=UDim.new(0,6)

farmBtn.MouseButton1Click:Connect(function()
    if not autoFarmEnabled then
        autoFarmEnabled=true
        farmBtn.Text="Auto Farm: ON"; farmBtn.TextColor3=C.grn
        task.spawn(autoFarmLoop)
    else
        autoFarmEnabled=false
        farmBtn.Text="Auto Farm: OFF"; farmBtn.TextColor3=Color3.fromRGB(255,100,100)
    end
end)

-- ════════════════════════════════════════════════════════
-- FLOATING AIMBOT GUI
-- ════════════════════════════════════════════════════════
local aimbotGui = Instance.new("ScreenGui")
aimbotGui.Name="DARKHUB_AimbotGUI"; aimbotGui.Parent=CoreGui
aimbotGui.ResetOnSpawn=false; aimbotGui.Enabled=false

local fovCircle = Instance.new("Frame", aimbotGui)
fovCircle.BackgroundTransparency=1; fovCircle.AnchorPoint=Vector2.new(0.5,0.5)
fovCircle.Position=UDim2.new(0.5,0,0.5,0)
fovCircle.Size=UDim2.new(0, aimbotFOV*2, 0, aimbotFOV*2)
Instance.new("UICorner",fovCircle).CornerRadius=UDim.new(1,0)
local fovStroke = Stroke(fovCircle, Color3.fromRGB(0,170,255), 1.5)

local aimbotBtn = Instance.new("TextButton", aimbotGui)
aimbotBtn.BackgroundColor3=C.bg1
aimbotBtn.BorderColor3=Color3.fromRGB(0,170,255); aimbotBtn.BorderSizePixel=2
aimbotBtn.Position=UDim2.new(0,50,0,110); aimbotBtn.Size=UDim2.new(0,90,0,45)
aimbotBtn.Font=Enum.Font.GothamBold; aimbotBtn.Text="AIMBOT: OFF"
aimbotBtn.TextColor3=Color3.fromRGB(255,255,255); aimbotBtn.TextSize=12; aimbotBtn.AutoButtonColor=false
Instance.new("UICorner",aimbotBtn).CornerRadius=UDim.new(0,8)

aimbotBtn.MouseButton1Click:Connect(function()
    _G.CustomAimbotActive = not _G.CustomAimbotActive
    if _G.CustomAimbotActive then
        aimbotBtn.Text="AIMBOT: ON"; aimbotBtn.TextColor3=C.grn
        fovStroke.Color=C.grn
    else
        aimbotBtn.Text="AIMBOT: OFF"; aimbotBtn.TextColor3=Color3.fromRGB(255,255,255)
        fovStroke.Color=Color3.fromRGB(0,170,255)
    end
end)

local aimDrag, aimStart, aimPos
aimbotBtn.InputBegan:Connect(function(input)
    if not _G.AimbotDraggable then return end
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        aimDrag=true; aimStart=input.Position; aimPos=aimbotBtn.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then aimDrag=false end
        end)
    end
end)
UIS.InputChanged:Connect(function(input)
    if not _G.AimbotDraggable then return end
    if aimDrag and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local d=input.Position - aimStart
        aimbotBtn.Position=UDim2.new(aimPos.X.Scale, aimPos.X.Offset + d.X, aimPos.Y.Scale, aimPos.Y.Offset + d.Y)
    end
end)

-- ════════════════════════════════════════════════════════
-- TAB 1 : MAIN
-- ════════════════════════════════════════════════════════
local P_Main = MakePage()
local S_Main = MakeScroll(P_Main)
local Col1_Main = Frame(S_Main, UDim2.new(1,-16,0,1), UDim2.new(0,8,0,0), C.bg0)
Col1_Main.BackgroundTransparency=1; Col1_Main.AutomaticSize=Enum.AutomaticSize.Y

local yM = 8
yM = MakeSection(Col1_Main, "Player Modules", yM)

yM = MakeToggle(Col1_Main, "Infinite Stamina", yM, "InfiniteStamina", function(v)
    _G.InfiniteStaminaEnabled = v
end)

yM = MakeToggle(Col1_Main, "Auto Pickup Loot", yM, "AutoLoot", function(v)
    _G.AutoLoot = v
    if v then
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
end)

yM = MakeToggle(Col1_Main, "Instant Interact", yM, "InstantInteract", function(v)
    _G.InstantInteractEnabled = v
end)

yM = MakeSection(Col1_Main, "Movement & Physics", yM)

yM = MakeToggle(Col1_Main, "No Jump Cooldown", yM, "NoJumpCooldown", function(v)
    _G.NoJumpCooldownEnabled = v
end)

yM = MakeToggle(Col1_Main, "Noclip", yM, "Noclip", function(v)
    _G.NoclipEnabled = v
end)

yM = MakeToggle(Col1_Main, "Safe Speed Boost", yM, "WalkSpeedEnabled", function(v)
    _G.WalkSpeedEnabled = v
end)

yM = MakeSlider(Col1_Main, "Speed Multiplier", yM, "WalkSpeedMultiplier", 1, 3, "%.2f", function(v)
    _G.WalkSpeedMultiplier = v
end)

yM = MakeSection(Col1_Main, "FPS", yM)

yM = MakeActionBtn(Col1_Main, "FPS Booster (Potato Graphics)", yM, function()
    if _G.FPSBoostUsed then
        notify("FPS Booster", "Already applied.", 3); return
    end
    _G.FPSBoostUsed = true
    pcall(function()
        local l = game:GetService("Lighting")
        l.GlobalShadows=false; l.FogEnd=999999
        for _, o in ipairs(l:GetChildren()) do
            if o:IsA("PostEffect") or o:IsA("Atmosphere") or o:IsA("Sky")
               or o:IsA("Clouds") or o:IsA("BlurEffect") then o:Destroy() end
        end
        for _, o in ipairs(Workspace:GetDescendants()) do
            if o:IsA("BasePart") then
                o.Material=Enum.Material.SmoothPlastic; o.CastShadow=false
            elseif o:IsA("Texture") or o:IsA("Decal") then o:Destroy() end
        end
    end)
    notify("FPS Booster", "Graphics stripped.", 4)
end)

-- ════════════════════════════════════════════════════════
-- TAB 2 : FARM
-- ════════════════════════════════════════════════════════
local P_Farm = MakePage()
local S_Farm = MakeScroll(P_Farm)
local Col_Farm = Frame(S_Farm, UDim2.new(1,-16,0,1), UDim2.new(0,8,0,0), C.bg0)
Col_Farm.BackgroundTransparency=1; Col_Farm.AutomaticSize=Enum.AutomaticSize.Y

local yF = 8
yF = MakeSection(Col_Farm, "Blank Card Auto Farm", yF)
yF = MakeLabel(Col_Farm, "Klik tombol di bawah untuk start/stop. Atau spawn floating UI untuk kontrol terpisah.", yF)
yF = MakeActionBtn(Col_Farm, "Toggle Auto Farm (Start / Stop)", yF, function()
    if not autoFarmEnabled then
        autoFarmEnabled=true
        farmBtn.Text="Auto Farm: ON"; farmBtn.TextColor3=C.grn
        task.spawn(autoFarmLoop)
        notify("Auto Farm", "Auto Farm diaktifkan.", 3)
    else
        autoFarmEnabled=false
        farmBtn.Text="Auto Farm: OFF"; farmBtn.TextColor3=Color3.fromRGB(255,100,100)
        notify("Auto Farm", "Auto Farm dimatikan.", 3)
    end
end)

yF = MakeSection(Col_Farm, "Floating UI", yF)
yF = MakeToggle(Col_Farm, "Spawn Auto Farm UI", yF, "SpawnAutoFarmUI", function(v)
    autoFarmGui.Enabled = v
    if not v then
        autoFarmEnabled=false
        farmBtn.Text="Auto Farm: OFF"; farmBtn.TextColor3=Color3.fromRGB(255,100,100)
    end
end)
yF = MakeToggle(Col_Farm, "Freeze Auto Farm UI", yF, "FreezeAutoFarmUI", function(v)
    AF_F.Draggable = not v
end)

-- ════════════════════════════════════════════════════════
-- TAB 3 : COMBAT
-- ════════════════════════════════════════════════════════
local P_Combat = MakePage()
local S_Combat = MakeScroll(P_Combat)
local Col_Combat = Frame(S_Combat, UDim2.new(1,-16,0,1), UDim2.new(0,8,0,0), C.bg0)
Col_Combat.BackgroundTransparency=1; Col_Combat.AutomaticSize=Enum.AutomaticSize.Y

local yC = 8
yC = MakeSection(Col_Combat, "Aimbot", yC)
yC = MakeToggle(Col_Combat, "Spawn Aimbot UI", yC, "SpawnAimbotUI", function(v)
    _G.CustomAimbotVisible = v
    aimbotGui.Enabled = v
    if not v then
        _G.CustomAimbotActive = false
        aimbotBtn.Text="AIMBOT: OFF"; aimbotBtn.TextColor3=Color3.fromRGB(255,255,255)
        fovStroke.Color=Color3.fromRGB(0,170,255)
    end
end)
yC = MakeSlider(Col_Combat, "Aimbot FOV Circle", yC, "AimbotFOV", 40, 300, "%d", function(v)
    aimbotFOV = v
    fovCircle.Size = UDim2.new(0, aimbotFOV*2, 0, aimbotFOV*2)
end)
yC = MakeToggle(Col_Combat, "Freeze Aimbot UI", yC, "FreezeAimbotUI", function(v)
    _G.AimbotDraggable = not v
end)

-- ════════════════════════════════════════════════════════
-- TAB 4 : VISUALS
-- ════════════════════════════════════════════════════════
local P_Vis = MakePage()
local S_Vis = MakeScroll(P_Vis)
local Col_Vis = Frame(S_Vis, UDim2.new(1,-16,0,1), UDim2.new(0,8,0,0), C.bg0)
Col_Vis.BackgroundTransparency=1; Col_Vis.AutomaticSize=Enum.AutomaticSize.Y

local yV = 8
yV = MakeSection(Col_Vis, "Visual Modules", yV)
yV = MakeToggle(Col_Vis, "Max Zoom Out", yV, "MaxZoomOut", function(v)
    _G.InfiniteZoomEnabled = v
    if not v then lp.CameraMaxZoomDistance = 128 end
end)
yV = MakeToggle(Col_Vis, "Player ESP", yV, "PlayerESP", function(v)
    _G.ESPEnabled = v
end)

yV = MakeSection(Col_Vis, "Player Info", yV)
yV = MakeLabel(Col_Vis, "Pilih player target lalu klik Inspect untuk melihat inventory.", yV)

-- Build player options list dynamically
local playerNames = {}
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= lp then table.insert(playerNames, p.DisplayName) end
end
if #playerNames == 0 then table.insert(playerNames, "None") end

yV = MakeSelect(Col_Vis, "Select Target Player", yV, playerNames, function(sel)
    for _, p in ipairs(Players:GetPlayers()) do
        if p.DisplayName == sel or p.Name == sel then
            selectedPlayerObj = p; break
        end
    end
end)

yV = MakeActionBtn(Col_Vis, "Inspect Inventory", yV, function()
    if not selectedPlayerObj or not selectedPlayerObj.Parent then
        notify("Inspect", "Pilih player target dulu.", 3); return
    end
    local t = selectedPlayerObj
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
    local content = #inv > 0 and table.concat(inv, ", ") or "Inventory kosong."
    notify(t.DisplayName .. "'s Inventory", content, 6)
end)

-- ════════════════════════════════════════════════════════
-- TAB 5 : SOCIALS
-- ════════════════════════════════════════════════════════
local P_Soc = MakePage()
local S_Soc = MakeScroll(P_Soc)
local Col_Soc = Frame(S_Soc, UDim2.new(1,-16,0,1), UDim2.new(0,8,0,0), C.bg0)
Col_Soc.BackgroundTransparency=1; Col_Soc.AutomaticSize=Enum.AutomaticSize.Y

local ySoc = 8
ySoc = MakeSection(Col_Soc, "Social Links", ySoc)
ySoc = MakeActionBtn(Col_Soc, "Copy Discord Link", ySoc, function()
    if setclipboard then setclipboard("https://discord.gg/xKvegCV6yf") end
    notify("Discord", "Invite copied to clipboard.", 3)
end)
ySoc = MakeActionBtn(Col_Soc, "Copy YouTube Link", ySoc, function()
    if setclipboard then setclipboard("https://youtube.com/@strixwashere") end
    notify("YouTube", "Link copied to clipboard.", 3)
end)

-- ════════════════════════════════════════════════════════
-- TAB 6 : CONFIG  (from ZXCHUB)
-- ════════════════════════════════════════════════════════
local P_Cfg = MakePage(); local S_Cfg = MakeScroll(P_Cfg)

local CfgCol1,CfgCol2
if isMobile then
    CfgCol1=Frame(S_Cfg,UDim2.new(1,-16,0,1),UDim2.new(0,8,0,0),C.bg0)
    CfgCol1.BackgroundTransparency=1; CfgCol1.AutomaticSize=Enum.AutomaticSize.Y; CfgCol1.LayoutOrder=1
    CfgCol2=Frame(S_Cfg,UDim2.new(1,-16,0,1),UDim2.new(0,8,0,0),C.bg0)
    CfgCol2.BackgroundTransparency=1; CfgCol2.AutomaticSize=Enum.AutomaticSize.Y; CfgCol2.LayoutOrder=2
    local ll=Instance.new("UIListLayout",S_Cfg); ll.SortOrder=Enum.SortOrder.LayoutOrder; ll.Padding=UDim.new(0,4)
else
    CfgCol1=Frame(S_Cfg,UDim2.new(0.5,-6,0,1),UDim2.new(0,0,0,0),C.bg0)
    CfgCol1.BackgroundTransparency=1; CfgCol1.AutomaticSize=Enum.AutomaticSize.Y
    CfgCol2=Frame(S_Cfg,UDim2.new(0.5,-6,0,1),UDim2.new(0.5,6,0,0),C.bg0)
    CfgCol2.BackgroundTransparency=1; CfgCol2.AutomaticSize=Enum.AutomaticSize.Y
end

local yc1=8
yc1=MakeSection(CfgCol1,"Manage Configs",yc1)

local ALbl=Lbl(CfgCol1,"Auto-Load: None",isMobile and 10 or 10,C.txt2,Enum.Font.Gotham)
ALbl.Size=UDim2.new(1,-32,0,isMobile and 17 or 15); ALbl.Position=UDim2.new(0,16,0,yc1)
yc1=yc1+(isMobile and 21 or 19)

local function UpdateALbl()
    local v=SafeRead(ConfigManager.AutoLoadFile)
    ALbl.Text=(v and v~="") and ("Auto-Load: "..v) or "Auto-Load: None"
end
UpdateALbl()

local cfgName="Default"; local CfgBox
yc1,CfgBox=MakeInput(CfgCol1,"Config Name","Enter name...",yc1,"_cfgInput",function(v) cfgName=v end)

local RefreshCfgList

yc1=MakeActionBtn(CfgCol1,"Save Config",yc1,function()
    if cfgName=="" then return Toast("Config","Enter a name first","err") end
    local ok,m=ConfigManager:Save(cfgName); Toast("Config",m,ok and "ok" or "err"); RefreshCfgList()
end)
yc1=MakeActionBtn(CfgCol1,"Load Config",yc1,function()
    if cfgName=="" then return Toast("Config","Enter a name first","err") end
    local ok,m=ConfigManager:Load(cfgName); Toast("Config",m,ok and "ok" or "err")
end)
yc1=MakeActionBtn(CfgCol1,"Set Auto-Load",yc1,function()
    if cfgName=="" then return Toast("Config","Enter a name first","err") end
    local ok,m=ConfigManager:SetAutoLoad(cfgName); UpdateALbl(); Toast("Config",m,ok and "ok" or "err")
end)
yc1=MakeActionBtn(CfgCol1,"Clear Auto-Load",yc1,function()
    local ok,m=ConfigManager:ResetAutoLoad(); UpdateALbl(); Toast("Config",m,ok and "ok" or "err")
end)
yc1=MakeActionBtn(CfgCol1,"Delete Config",yc1,function()
    if cfgName=="" then return Toast("Config","Enter a name first","err") end
    local ok,m=ConfigManager:Delete(cfgName); UpdateALbl(); Toast("Config",m,ok and "ok" or "err"); RefreshCfgList()
end)

local yc2=8
yc2=MakeSection(CfgCol2,"Saved Configs",yc2)

local CfgListF=Frame(CfgCol2,UDim2.new(1,-16,0,10),UDim2.new(0,8,0,yc2),C.bg0)
CfgListF.BackgroundTransparency=1

function RefreshCfgList()
    for _,ch in ipairs(CfgListF:GetChildren()) do ch:Destroy() end
    local list=ConfigManager:GetList(); local cy=0
    local ibH=isMobile and 32 or 26

    if #list==0 then
        local el=Lbl(CfgListF,"No configs saved",isMobile and 11 or 10,C.txt3,Enum.Font.Gotham,Enum.TextXAlignment.Center)
        el.Size=UDim2.new(1,0,0,32); el.Position=UDim2.new(0,0,0,6)
        CfgListF.Size=UDim2.new(1,-16,0,44); return
    end

    for _,name in ipairs(list) do
        local ib=Btn(CfgListF,UDim2.new(1,0,0,ibH),UDim2.new(0,0,0,cy),C.bg3,4)
        Stroke(ib,C.brd2,1)
        local iL=Lbl(ib,name,isMobile and 11 or 11,C.txt,Enum.Font.GothamMedium,Enum.TextXAlignment.Center)
        iL.TextTruncate=Enum.TextTruncate.AtEnd
        ib.MouseButton1Click:Connect(function()
            cfgName=name; CfgBox.Text=name
            TweenS:Create(ib,TweenInfo.new(0.08),{BackgroundColor3=C.acc}):Play()
            task.delay(0.14,function() TweenS:Create(ib,TweenInfo.new(0.1),{BackgroundColor3=C.bg3}):Play() end)
            Toast("Config","Selected: "..name,"ok")
        end)
        cy=cy+ibH+4
    end
    CfgListF.Size=UDim2.new(1,-16,0,cy)
end
RefreshCfgList()

-- ════════════════════════════════════════════════════════
-- TAB 7 : CREDITS
-- ════════════════════════════════════════════════════════
local P_Cred = MakePage()

local Card=Frame(P_Cred,UDim2.new(isMobile and 0.88 or 0.76,0,isMobile and 0.65 or 0.60,0),
    UDim2.new(0.5,0,0.5,0),C.bg1,8)
Card.AnchorPoint=Vector2.new(0.5,0.5); Stroke(Card,C.brd2,1)
Frame(Card,UDim2.new(1,0,0,2),UDim2.new(0,0,0,0),C.acc)

local CLogo=Lbl(Card,'<font color="#D73737">DARK</font>HUB',isMobile and 24 or 26,C.white,Enum.Font.GothamBold,Enum.TextXAlignment.Center)
CLogo.Size=UDim2.new(1,0,0,42); CLogo.Position=UDim2.new(0,0,0,14); CLogo.RichText=true

local CVer=Lbl(Card,"v1.0  |  Cali Streets",isMobile and 11 or 11,C.txt2,Enum.Font.GothamMedium,Enum.TextXAlignment.Center)
CVer.Size=UDim2.new(1,0,0,16); CVer.Position=UDim2.new(0,0,0,58)

Frame(Card,UDim2.new(0.5,0,0,1),UDim2.new(0.25,0,0,84),C.brd)

local CDesc=Lbl(Card,"Built by the DARK HUB team\nAuto Farm  |  ESP  |  Aimbot  |  Config System",
    isMobile and 11 or 12,C.txt,Enum.Font.Gotham,Enum.TextXAlignment.Center)
CDesc.Size=UDim2.new(1,-24,0,50); CDesc.Position=UDim2.new(0,12,0,92); CDesc.TextWrapped=true

local dcH=isMobile and 38 or 32
local DC=Btn(Card,UDim2.new(isMobile and 0.82 or 0.76,0,0,dcH),
    UDim2.new(isMobile and 0.09 or 0.12,0,1,-(dcH+14)),C.acc,6)
local DCL=Lbl(DC,"Copy Discord Link",isMobile and 12 or 12,C.white,Enum.Font.GothamBold,Enum.TextXAlignment.Center)

DC.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard("https://discord.gg/xKvegCV6yf"); DCL.Text="Copied!"
        TweenS:Create(DC,TweenInfo.new(0.1),{BackgroundColor3=C.grn}):Play()
        task.delay(2,function()
            DCL.Text="Copy Discord Link"
            TweenS:Create(DC,TweenInfo.new(0.1),{BackgroundColor3=C.acc}):Play()
        end)
    else Toast("Error","Clipboard not supported","err") end
end)

-- ════════════════════════════════════════════════════════
-- TAB 8 : SETTINGS  (gear icon)
-- ════════════════════════════════════════════════════════
local P_Set = MakePage(); local S_Set = MakeScroll(P_Set)

local SC1,SC2
if isMobile then
    SC1=Frame(S_Set,UDim2.new(1,-16,0,1),UDim2.new(0,8,0,0),C.bg0)
    SC1.BackgroundTransparency=1; SC1.AutomaticSize=Enum.AutomaticSize.Y; SC1.LayoutOrder=1
    SC2=Frame(S_Set,UDim2.new(1,-16,0,1),UDim2.new(0,8,0,0),C.bg0)
    SC2.BackgroundTransparency=1; SC2.AutomaticSize=Enum.AutomaticSize.Y; SC2.LayoutOrder=2
    local ll2=Instance.new("UIListLayout",S_Set); ll2.SortOrder=Enum.SortOrder.LayoutOrder; ll2.Padding=UDim.new(0,4)
else
    SC1=Frame(S_Set,UDim2.new(0.5,-6,0,1),UDim2.new(0,0,0,0),C.bg0)
    SC1.BackgroundTransparency=1; SC1.AutomaticSize=Enum.AutomaticSize.Y
    SC2=Frame(S_Set,UDim2.new(0.5,-6,0,1),UDim2.new(0.5,6,0,0),C.bg0)
    SC2.BackgroundTransparency=1; SC2.AutomaticSize=Enum.AutomaticSize.Y
end

local ys1=8
ys1=MakeSection(SC1,"Menu Settings",ys1)

local kbH=isMobile and 30 or 26
local KBRow=Frame(SC1,UDim2.new(1,-32,0,kbH),UDim2.new(0,16,0,ys1),C.bg3,4)
Stroke(KBRow,C.brd2,1)
local KBLbl=Lbl(KBRow,"Menu Key: "..MenuKeybind.Name,isMobile and 11 or 11,C.txt,Enum.Font.GothamMedium,Enum.TextXAlignment.Center)
local bindingKey=false
local KBCZ=Btn(KBRow,UDim2.new(1,0,1,0),UDim2.new(0,0,0,0),C.bg0); KBCZ.BackgroundTransparency=1

KBCZ.MouseButton1Click:Connect(function()
    if bindingKey then return end
    bindingKey=true; _anyBindWaiting=true
    KBLbl.Text="Press any key..."; KBRow.BackgroundColor3=C.acc
end)
UIS.InputBegan:Connect(function(inp,gpe)
    if bindingKey and inp.UserInputType==Enum.UserInputType.Keyboard then
        bindingKey=false; _anyBindWaiting=false
        MenuKeybind=inp.KeyCode
        KBLbl.Text="Menu Key: "..MenuKeybind.Name; KBRow.BackgroundColor3=C.bg3
        Toast("Settings","Menu key set to: "..MenuKeybind.Name,"ok")
        if not isMobile and OpenText then
            OpenText.Text='<font color="#D73737">DARK</font>HUB <font color="#787B8A">| '..MenuKeybind.Name..'</font>'
        end
    end
end)
ys1=ys1+(isMobile and 38 or 34)

ys1=MakeSection(SC1,"Themes",ys1)
local themeOrder={"Default","Ocean","Amethyst","Emerald","Rose","Midnight","Sunset","Arctic","Crimson","Void"}
for _,tName in ipairs(themeOrder) do
    if Themes[tName] then
        local tH=isMobile and 30 or 26
        local tRow=Frame(SC1,UDim2.new(1,-32,0,tH),UDim2.new(0,16,0,ys1),C.bg3,4)
        Stroke(tRow,C.brd2,1)
        local dotSz=isMobile and 10 or 8
        Frame(tRow,UDim2.new(0,dotSz,0,dotSz),UDim2.new(0,isMobile and 9 or 7,0.5,-dotSz/2),Themes[tName].acc,dotSz/2)
        local tLbl=Lbl(tRow,tName,isMobile and 11 or 11,C.txt,Enum.Font.GothamMedium)
        tLbl.Size=UDim2.new(1,-26,1,0); tLbl.Position=UDim2.new(0,dotSz+14,0,0)
        local tCZ=Btn(tRow,UDim2.new(1,0,1,0),UDim2.new(0,0,0,0),C.bg0); tCZ.BackgroundTransparency=1
        tCZ.MouseButton1Click:Connect(function()
            ApplyTheme(tName); Toast("Theme","Applied: "..tName,"ok")
        end)
        ys1=ys1+(isMobile and 38 or 34)
    end
end

local ys2=8
ys2=MakeSection(SC2,"Player",ys2)

local pcH=isMobile and 80 or 70
local PCard=Frame(SC2,UDim2.new(1,-32,0,pcH),UDim2.new(0,16,0,ys2),C.bg3,8)
Stroke(PCard,C.brd2,1)
Frame(PCard,UDim2.new(0,4,1,-14),UDim2.new(0,0,0,7),C.acc,2)

local vpSz=isMobile and 56 or 50
local VP=Instance.new("ViewportFrame",PCard)
VP.Size=UDim2.new(0,vpSz,0,vpSz)
VP.Position=UDim2.new(0,isMobile and 14 or 12,0.5,-vpSz/2)
VP.BackgroundColor3=C.bg4
Instance.new("UICorner",VP).CornerRadius=UDim.new(0,6)
Stroke(VP,C.acc,1)

local function TryLoadChar()
    for _,ch in ipairs(VP:GetChildren()) do
        if not ch:IsA("Camera") then ch:Destroy() end
    end
    local char=lp.Character; if not char then return end
    local clone=char:Clone()
    for _,s in ipairs(clone:GetDescendants()) do
        if s:IsA("BaseScript") then s:Destroy() end
    end
    for _,p in ipairs(clone:GetDescendants()) do
        if p:IsA("BasePart") then p.Anchored=true; p.CastShadow=false end
    end
    clone.Parent=VP
    pcall(function() clone:PivotTo(CFrame.new(0,0,0)) end)
    local cam=Instance.new("Camera",VP); VP.CurrentCamera=cam
    local head=clone:FindFirstChild("Head")
    local target=head and head.Position or Vector3.new(0,1.5,0)
    cam.CFrame=CFrame.new(target+Vector3.new(0,0.3,2.6), target+Vector3.new(0,0.05,0))
end

pcall(TryLoadChar)
lp.CharacterAdded:Connect(function() task.wait(1); pcall(TryLoadChar) end)

local tx=vpSz+(isMobile and 18 or 16)
local dnLbl=Lbl(PCard,lp.DisplayName,isMobile and 13 or 13,C.white,Enum.Font.GothamBold)
dnLbl.Size=UDim2.new(1,-(tx+10),0,isMobile and 20 or 18)
dnLbl.Position=UDim2.new(0,tx,0,isMobile and 10 or 9)
dnLbl.TextXAlignment=Enum.TextXAlignment.Left

local unLbl=Lbl(PCard,"@"..lp.Name,isMobile and 11 or 10,C.txt2,Enum.Font.Gotham)
unLbl.Size=UDim2.new(1,-(tx+10),0,isMobile and 16 or 15)
unLbl.Position=UDim2.new(0,tx,0,isMobile and 32 or 29)
unLbl.TextXAlignment=Enum.TextXAlignment.Left

local execName="Unknown Executor"
if syn then execName="Synapse X"
elseif KRNL_LOADED then execName="KRNL"
elseif pebc_enabled then execName="ProtoSmasher"
elseif getexecutorname then pcall(function() execName=getexecutorname() end)
elseif identifyexecutor then pcall(function() execName=identifyexecutor() end)
elseif writefile then execName="Unknown (writefile OK)"
end

local exLbl=Lbl(PCard,execName,isMobile and 10 or 9,C.acc,Enum.Font.GothamMedium)
exLbl.Size=UDim2.new(1,-(tx+10),0,isMobile and 15 or 13)
exLbl.Position=UDim2.new(0,tx,0,isMobile and 51 or 46)
exLbl.TextXAlignment=Enum.TextXAlignment.Left

ys2=ys2+pcH+8
ys2=MakeSection(SC2,"Executor Functions",ys2)

local supported    = #AllFunctions-#UnsupportedFunctions
local allOk        = #UnsupportedFunctions==0
local statusCol    = allOk and C.grn or Color3.fromRGB(232,158,24)
local statusBg     = allOk and Color3.fromRGB(10,38,20) or Color3.fromRGB(40,26,8)
local pct          = #AllFunctions>0 and (supported/#AllFunctions) or 1

local sumH=isMobile and 96 or 84
local sumF=Frame(SC2,UDim2.new(1,-32,0,sumH),UDim2.new(0,16,0,ys2),C.bg3,8)
Stroke(sumF, statusCol, 1)
Frame(sumF,UDim2.new(0,4,1,-14),UDim2.new(0,0,0,7),statusCol,2)

local iconSz=isMobile and 44 or 38
local iconF=Frame(sumF,UDim2.new(0,iconSz,0,iconSz),UDim2.new(0,isMobile and 14 or 12,0.5,-iconSz/2),statusBg,iconSz/2)
Stroke(iconF,statusCol,1)
Lbl(iconF,allOk and "✓" or "!",isMobile and 20 or 17,statusCol,Enum.Font.GothamBold,Enum.TextXAlignment.Center)

local stx=isMobile and (14+iconSz+12) or (12+iconSz+10)

local cpW=isMobile and 50 or 44; local cpH2=isMobile and 19 or 16
local cpF=Frame(sumF,UDim2.new(0,cpW,0,cpH2),UDim2.new(1,-(cpW+8),0,isMobile and 10 or 8),statusBg,cpH2/2)
Stroke(cpF,statusCol,1)
Lbl(cpF,supported.."  /  "..#AllFunctions,isMobile and 9 or 8,statusCol,Enum.Font.GothamBold,Enum.TextXAlignment.Center)

local titL=Lbl(sumF, allOk and "All Functions Supported" or (#UnsupportedFunctions.." Function(s) Missing"),
    isMobile and 13 or 12,C.white,Enum.Font.GothamBold)
titL.Size=UDim2.new(1,-(stx+cpW+18),0,isMobile and 20 or 18)
titL.Position=UDim2.new(0,stx,0,isMobile and 11 or 9)
titL.TextXAlignment=Enum.TextXAlignment.Left

local subL=Lbl(sumF, allOk and "Executor is fully compatible" or "Open details to see what's missing",
    isMobile and 10 or 9,C.txt2,Enum.Font.Gotham)
subL.Size=UDim2.new(1,-(stx+8),0,isMobile and 15 or 13)
subL.Position=UDim2.new(0,stx,0,isMobile and 34 or 30)
subL.TextXAlignment=Enum.TextXAlignment.Left

local barY=isMobile and 56 or 49; local barPx=isMobile and 6 or 5
local barTrack=Frame(sumF,UDim2.new(1,-(stx+10),0,barPx),UDim2.new(0,stx,0,barY),C.bg4,barPx/2)
Frame(barTrack,UDim2.new(pct,0,1,0),UDim2.new(0,0,0,0),statusCol,barPx/2)
local pctL=Lbl(sumF,math.floor(pct*100).."%",isMobile and 9 or 8,statusCol,Enum.Font.GothamBold,Enum.TextXAlignment.Right)
pctL.Size=UDim2.new(0,30,0,isMobile and 14 or 12)
pctL.Position=UDim2.new(1,-38,0,barY-(isMobile and 4 or 3))

ys2=ys2+sumH+4

if #UnsupportedFunctions>0 then
    for _,fn in ipairs(UnsupportedFunctions) do
        local chipH=isMobile and 26 or 22
        local chipF=Frame(SC2,UDim2.new(1,-32,0,chipH),UDim2.new(0,16,0,ys2),Color3.fromRGB(36,10,10),4)
        Stroke(chipF,C.acc,1)
        Frame(chipF,UDim2.new(0,3,1,-8),UDim2.new(0,0,0,4),C.acc,1)
        local nL=Lbl(chipF,"✗  "..fn.name,isMobile and 10 or 9,C.acc,Enum.Font.GothamBold)
        nL.Size=UDim2.new(0,isMobile and 120 or 110,1,0); nL.Position=UDim2.new(0,8,0,0)
        local dL=Lbl(chipF,fn.desc,isMobile and 10 or 9,C.txt3,Enum.Font.Gotham)
        dL.Size=UDim2.new(1,-(isMobile and 128 or 118),1,0); dL.Position=UDim2.new(0,isMobile and 120 or 110,0,0)
        dL.TextXAlignment=Enum.TextXAlignment.Left; dL.TextTruncate=Enum.TextTruncate.AtEnd
        ys2=ys2+chipH+4
    end
    ys2=ys2+2
end

local function ShowFnPopup()
    local vp=workspace.CurrentCamera.ViewportSize
    local popW=isMobile and math.clamp(vp.X-16, 260, 400) or 430
    local popH=isMobile and math.clamp(vp.Y*0.85, 300, 520) or 400

    local pop=Frame(GUI,UDim2.new(0,popW,0,popH),UDim2.new(0.5,-popW/2,0.5,-popH/2),C.bg0,8)
    pop.ZIndex=120; Stroke(pop,C.brd2,1); pop.ClipsDescendants=true

    local fhH=isMobile and 38 or 32
    local fHead=Frame(pop,UDim2.new(1,0,0,fhH),UDim2.new(0,0,0,0),C.bg1)
    Frame(fHead,UDim2.new(1,0,0,2),UDim2.new(0,0,1,-2),C.acc)
    local fhLbl=Lbl(fHead,"Functions  —  "..supported.."/"..#AllFunctions.." supported",
        isMobile and 11 or 12, C.white, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
    fhLbl.Size=UDim2.new(1,-44,1,0); fhLbl.TextTruncate=Enum.TextTruncate.AtEnd

    local fClose=Btn(fHead,
        UDim2.new(0,isMobile and 30 or 26,0,isMobile and 30 or 26),
        UDim2.new(1,-(isMobile and 34 or 30),0.5,-(isMobile and 15 or 13)), C.acc,4)
    Lbl(fClose,"X",isMobile and 12 or 12,C.white,Enum.Font.GothamBold,Enum.TextXAlignment.Center)
    fClose.MouseButton1Click:Connect(function() pop:Destroy() end)

    local fScroll=MakeScroll(pop)
    fScroll.Size=UDim2.new(1,-8,1,-(fhH+8))
    fScroll.Position=UDim2.new(0,4,0,fhH+4)

    local cats,catOrder={},{}
    for _,fn in ipairs(AllFunctions) do
        local c=fn.cat or "Other"
        if not cats[c] then cats[c]={}; table.insert(catOrder,c) end
        table.insert(cats[c],fn)
    end

    local yp=0
    local entH=isMobile and 80 or 72
    local catH2=isMobile and 24 or 20

    for _,cat in ipairs(catOrder) do
        local fns=cats[cat]
        local cF=Frame(fScroll,UDim2.new(1,-6,0,catH2),UDim2.new(0,3,0,yp),C.bg2,4)
        Stroke(cF,C.brd2,1)
        Lbl(cF,cat.."  ("..#fns..")",isMobile and 10 or 10,C.txt2,Enum.Font.GothamBold,Enum.TextXAlignment.Center)
        yp=yp+catH2+4

        for _,fn in ipairs(fns) do
            local eF=Frame(fScroll,UDim2.new(1,-6,0,entH),UDim2.new(0,3,0,yp),C.bg3,4)
            Stroke(eF,C.brd2,1)
            Frame(eF,UDim2.new(0,3,1,-8),UDim2.new(0,0,0,4),fn.supported and C.grn or C.acc,2)

            local fnL=Lbl(eF,fn.name,isMobile and 11 or 11,C.white,Enum.Font.GothamBold)
            fnL.Size=UDim2.new(1,-78,0,isMobile and 18 or 17)
            fnL.Position=UDim2.new(0,10,0,isMobile and 6 or 5)
            fnL.TextXAlignment=Enum.TextXAlignment.Left

            local bdgW=isMobile and 64 or 60; local bdgH=isMobile and 17 or 15
            local bdgF=Frame(eF,UDim2.new(0,bdgW,0,bdgH),
                UDim2.new(1,-(bdgW+6),0,isMobile and 6 or 5),
                fn.supported and Color3.fromRGB(15,45,25) or Color3.fromRGB(45,12,12),4)
            Stroke(bdgF,fn.supported and C.grn or C.acc,1)
            Lbl(bdgF,fn.supported and "OK" or "Missing",
                isMobile and 9 or 9, fn.supported and C.grn or C.acc,
                Enum.Font.GothamBold,Enum.TextXAlignment.Center)

            local dL=Lbl(eF,fn.desc,isMobile and 10 or 9,C.txt2,Enum.Font.Gotham)
            dL.Size=UDim2.new(1,-16,0,isMobile and 20 or 18)
            dL.Position=UDim2.new(0,10,0,isMobile and 28 or 25)
            dL.TextXAlignment=Enum.TextXAlignment.Left; dL.TextWrapped=true

            local usedStr = (fn.features and fn.features~="") and fn.features or "—"
            local uL=Lbl(eF,"Used by:  "..usedStr,isMobile and 9 or 9,C.txt3,Enum.Font.Gotham)
            uL.Size=UDim2.new(1,-16,0,isMobile and 16 or 14)
            uL.Position=UDim2.new(0,10,0,isMobile and 52 or 46)
            uL.TextXAlignment=Enum.TextXAlignment.Left

            yp=yp+entH+4
        end
        yp=yp+6
    end
end

ys2=MakeActionBtn(SC2,"Show all "..#AllFunctions.." functions",ys2,ShowFnPopup)

-- ════════════════════════════════════════════════════════
-- GAME LOOPS
-- ════════════════════════════════════════════════════════
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
        if p ~= lp and p.Character and p.Character:FindFirstChild("Head") then
            local h = p.Character.Head
            local sp, on = Camera:WorldToViewportPoint(h.Position)
            if on then
                local d = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                if d <= aimbotFOV and canSeeTarget(h) and d < best then
                    best = d; tgt = h
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
        lp.CameraMaxZoomDistance = 100000
    end
    for _, data in pairs(espData) do
        local vis = _G.ESPEnabled and data.Character and data.Character:FindFirstChild("Humanoid")
        if data.Billboard then data.Billboard.Enabled = vis end
        if data.Highlight then data.Highlight.Enabled = vis end
    end
end)

RunService.Stepped:Connect(function()
    local char = lp.Character
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
        local mult = Flags.WalkSpeedMultiplier or 1.25
        rp.CFrame = rp.CFrame + hum.MoveDirection * (mult - 1) * 0.5
    end
end)

UIS.JumpRequest:Connect(function()
    if _G.NoJumpCooldownEnabled then
        local char = lp.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
    end
end)

RunService.Stepped:Connect(function()
    if _G.NoJumpCooldownEnabled then
        local char = lp.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true) end)
            end
        end
    end
end)

-- ════════════════════════════════════════════════════════
-- INITIALIZATION
-- ════════════════════════════════════════════════════════
local autoName=SafeRead(ConfigManager.AutoLoadFile) or ""
if autoName~="" then
    local ok,msg=ConfigManager:Load(autoName)
    if ok then Toast("Auto-Load","Loaded: "..autoName,"ok") end
end

SetTab(1)
ShowCursor()
Toast("DARK HUB","Menu loaded  v1.0","ok")

if #UnsupportedFunctions>0 then
    task.delay(1.8,function()
        Toast("Warning",#UnsupportedFunctions.." function(s) unsupported","warn")
    end)
end