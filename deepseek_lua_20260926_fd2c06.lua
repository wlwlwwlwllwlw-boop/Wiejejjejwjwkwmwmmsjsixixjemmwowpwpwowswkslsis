-- ═══════════════════════════════════════════════════════════════
-- DARK HUB | Cali Streets
-- UI Library  : made by samet (joestar._3 on discord)
-- Logic       : DARK HUB
-- ═══════════════════════════════════════════════════════════════

if getgenv().Library then
    getgenv().Library:Unload()
end

local Library do
    local Workspace = game:GetService("Workspace")
    local UserInputService = game:GetService("UserInputService")
    local Players = game:GetService("Players")
    local HttpService = game:GetService("HttpService")
    local RunService = game:GetService("RunService")
    local CoreGui = cloneref and cloneref(game:GetService("CoreGui")) or game:GetService("CoreGui")
    local TweenService = game:GetService("TweenService")

    gethui = gethui or function() return CoreGui end

    local LocalPlayer = Players.LocalPlayer
    local Mouse = LocalPlayer:GetMouse()

    local FromRGB = Color3.fromRGB
    local FromHSV = Color3.fromHSV
    local FromHex = Color3.fromHex

    local RGBSequence = ColorSequence.new
    local RGBSequenceKeypoint = ColorSequenceKeypoint.new

    local UDim2New = UDim2.new
    local UDimNew = UDim.new
    local Vector2New = Vector2.new

    local MathClamp = math.clamp
    local MathFloor = math.floor

    local TableInsert = table.insert
    local TableFind = table.find
    local TableRemove = table.remove
    local TableConcat = table.concat
    local TableClone = table.clone
    local TableUnpack = table.unpack

    local StringFormat = string.format
    local StringFind = string.find
    local StringGSub = string.gsub
    local StringLen = string.len
    local StringSub = string.sub

    local InstanceNew = Instance.new

    Library = {
        Theme =  { },
        MenuKeybind = tostring(Enum.KeyCode.Z),
        Flags = { },
        Tween = {
            Time = 0.4,
            Style = Enum.EasingStyle.Quint,
            Direction = Enum.EasingDirection.Out
        },
        FadeSpeed = 0.2,
        Folders = {
            Directory = "esdeeeeee",
            Configs = "esdeeeeee/Configs",
            Assets = "esdeeeeee/Assets",
        },
        Pages = { },
        Sections = { },
        Connections = { },
        Threads = { },
        ThemeMap = { },
        ThemeItems = { },
        OpenFrames = { },
        SetFlags = { },
        UnnamedConnections = 0,
        UnnamedFlags = 0,
        Holder = nil,
        NotifHolder = nil,
        UnusedHolder = nil,
        Font = nil
    }

    local Keys = {
        ["Unknown"]="Unknown",["Backspace"]="Back",["Tab"]="Tab",["Clear"]="Clear",["Return"]="Return",
        ["Pause"]="Pause",["Escape"]="Escape",["Space"]="Space",["QuotedDouble"]='"',["Hash"]="#",
        ["Dollar"]="$",["Percent"]="%",["Ampersand"]="&",["Quote"]="'",["LeftParenthesis"]="(",
        ["RightParenthesis"]=" )",["Asterisk"]="*",["Plus"]="+",["Comma"]=",",["Minus"]="-",
        ["Period"]=".",["Slash"]="`",["Three"]="3",["Seven"]="7",["Eight"]="8",["Colon"]=":",
        ["Semicolon"]=";",["LessThan"]="<",["GreaterThan"]=">",["Question"]="?",["Equals"]="=",
        ["At"]="@",["LeftBracket"]="LeftBracket",["RightBracket"]="RightBracked",["BackSlash"]="BackSlash",
        ["Caret"]="^",["Underscore"]="_",["Backquote"]="`",["LeftCurly"]="{",["Pipe"]="|",
        ["RightCurly"]="}",["Tilde"]="~",["Delete"]="Delete",["End"]="End",["KeypadZero"]="Keypad0",
        ["KeypadOne"]="Keypad1",["KeypadTwo"]="Keypad2",["KeypadThree"]="Keypad3",["KeypadFour"]="Keypad4",
        ["KeypadFive"]="Keypad5",["KeypadSix"]="Keypad6",["KeypadSeven"]="Keypad7",["KeypadEight"]="Keypad8",
        ["KeypadNine"]="Keypad9",["KeypadPeriod"]="KeypadP",["KeypadDivide"]="KeypadD",
        ["KeypadMultiply"]="KeypadM",["KeypadMinus"]="KeypadM",["KeypadPlus"]="KeypadP",
        ["KeypadEnter"]="KeypadE",["KeypadEquals"]="KeypadE",["Insert"]="Insert",["Home"]="Home",
        ["PageUp"]="PageUp",["PageDown"]="PageDown",["RightShift"]="RightShift",["LeftShift"]="LeftShift",
        ["RightControl"]="RightControl",["LeftControl"]="LeftControl",["LeftAlt"]="LeftAlt",["RightAlt"]="RightAlt"
    }

    local Themes = {
        ["Preset"] = {
            ["Background"] = FromRGB(16, 18, 18),
            ["Inline"]     = FromRGB(21, 24, 24),
            ["Element"]    = FromRGB(30, 34, 34),
            ["Accent"]     = FromRGB(255, 255, 255),
            ["Border"]     = FromRGB(30, 34, 34),
            ["Border 2"]   = FromRGB(56, 62, 62)
        }
    }

    Library.__index = Library
    Library.Sections.__index = Library.Sections
    Library.Pages.__index = Library.Pages

    Library.Theme = TableClone(Themes["Preset"])

    for Index, Value in Library.Folders do
        if not isfolder(Value) then makefolder(Value) end
    end

    -- Tweening
    local Tween = { } do
        Tween.__index = Tween

        Tween.Create = function(self, Item, Info, Goal, IsRawItem)
            Item = IsRawItem and Item or Item.Instance
            Info = Info or TweenInfo.new(Library.Tween.Time, Library.Tween.Style, Library.Tween.Direction)
            local NewTween = {
                Tween = TweenService:Create(Item, Info, Goal),
                Info = Info, Goal = Goal, Item = Item
            }
            NewTween.Tween:Play()
            setmetatable(NewTween, Tween)
            return NewTween
        end

        Tween.GetProperty = function(self, Item)
            Item = Item or self.Item
            if Item:IsA("Frame") then
                return { "BackgroundTransparency" }
            elseif Item:IsA("TextLabel") or Item:IsA("TextButton") then
                return { "TextTransparency", "BackgroundTransparency" }
            elseif Item:IsA("ImageLabel") or Item:IsA("ImageButton") then
                return { "BackgroundTransparency", "ImageTransparency" }
            elseif Item:IsA("ScrollingFrame") then
                return { "BackgroundTransparency", "ScrollBarImageTransparency" }
            elseif Item:IsA("TextBox") then
                return { "TextTransparency", "BackgroundTransparency" }
            elseif Item:IsA("UIStroke") then
                return { "Transparency" }
            end
        end

        Tween.FadeItem = function(self, Item, Property, Visibility, Speed)
            local Item = Item or self.Item
            local OldTransparency = Item[Property]
            Item[Property] = Visibility and 1 or OldTransparency
            local NewTween = Tween:Create(Item, TweenInfo.new(Speed or Library.Tween.Time, Library.Tween.Style, Library.Tween.Direction), {
                [Property] = Visibility and OldTransparency or 1
            }, true)
            Library:Connect(NewTween.Tween.Completed, function()
                if not Visibility then task.wait(); Item[Property] = OldTransparency end
            end)
            return NewTween
        end

        Tween.Pause = function(self) if self.Tween then self.Tween:Pause() end end
        Tween.Play  = function(self) if self.Tween then self.Tween:Play() end end
        Tween.Clean = function(self) if self.Tween then Tween:Pause() self = nil end end
    end

    -- Instances
    local Instances = { } do
        Instances.__index = Instances

        Instances.Create = function(self, Class, Properties)
            local NewItem = { Instance = InstanceNew(Class), Properties = Properties, Class = Class }
            setmetatable(NewItem, Instances)
            for Property, Value in NewItem.Properties do
                NewItem.Instance[Property] = Value
            end
            return NewItem
        end

        Instances.AddToTheme = function(self, Properties)
            if not self.Instance then return end
            Library:AddToTheme(self, Properties)
        end

        Instances.ChangeItemTheme = function(self, Properties)
            if not self.Instance then return end
            Library:ChangeItemTheme(self, Properties)
        end

        Instances.Connect = function(self, Event, Callback, Name)
            if not self.Instance then return end
            if not self.Instance[Event] then return end
            return Library:Connect(self.Instance[Event], Callback, Name)
        end

        Instances.Tween = function(self, Info, Goal)
            if not self.Instance then return end
            return Tween:Create(self, Info, Goal)
        end

        Instances.Clean = function(self)
            if not self.Instance then return end
            self.Instance:Destroy()
            self = nil
        end

        Instances.MakeDraggable = function(self)
            if not self.Instance then return end
            local Gui = self.Instance
            local Dragging = false
            local DragStart, StartPosition

            local Set = function(Input)
                local DragDelta = Input.Position - DragStart
                self:Tween(TweenInfo.new(0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
                    {Position = UDim2New(StartPosition.X.Scale, StartPosition.X.Offset + DragDelta.X,
                                        StartPosition.Y.Scale, StartPosition.Y.Offset + DragDelta.Y)})
            end

            local InputChanged
            self:Connect("InputBegan", function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    Dragging = true
                    DragStart = Input.Position
                    StartPosition = Gui.Position
                    if InputChanged then return end
                    InputChanged = Input.Changed:Connect(function()
                        if Input.UserInputState == Enum.UserInputState.End then
                            Dragging = false
                            InputChanged:Disconnect()
                            InputChanged = nil
                        end
                    end)
                end
            end)
            Library:Connect(UserInputService.InputChanged, function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
                    if Dragging then Set(Input) end
                end
            end)
            return Dragging
        end

        Instances.MakeResizeable = function(self, Minimum, Maximum)
            if not self.Instance then return end
            local Gui = self.Instance
            local Resizing = false
            local Start = UDim2New()
            local Delta = UDim2New()
            local ResizeMax = Gui.Parent.AbsoluteSize - Gui.AbsoluteSize

            local ResizeButton = Instances:Create("ImageButton", {
                Parent = Gui, Image = "rbxassetid://",
                AnchorPoint = Vector2New(1, 1),
                BorderColor3 = FromRGB(0, 0, 0),
                Size = UDim2New(0, 8, 0, 8),
                Position = UDim2New(1, -4, 1, -4),
                Name = "\0", BorderSizePixel = 0,
                BackgroundTransparency = 1, ZIndex = 5,
                AutoButtonColor = false, Visible = true,
            })  ResizeButton:AddToTheme({ImageColor3 = "Accent"})

            local InputChanged
            ResizeButton:Connect("InputBegan", function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    Resizing = true
                    Start = Gui.Size - UDim2New(0, Input.Position.X, 0, Input.Position.Y)
                    if InputChanged then return end
                    InputChanged = Input.Changed:Connect(function()
                        if Input.UserInputState == Enum.UserInputState.End then
                            Resizing = false
                            InputChanged:Disconnect()
                            InputChanged = nil
                        end
                    end)
                end
            end)
            Library:Connect(UserInputService.InputChanged, function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
                    if Resizing then
                        ResizeMax = Maximum or Gui.Parent.AbsoluteSize - Gui.AbsoluteSize
                        Delta = Start + UDim2New(0, Input.Position.X, 0, Input.Position.Y)
                        Delta = UDim2New(0, math.clamp(Delta.X.Offset, Minimum.X, ResizeMax.X),
                                         0, math.clamp(Delta.Y.Offset, Minimum.Y, ResizeMax.Y))
                        Tween:Create(Gui, TweenInfo.new(0.17, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
                            {Size = Delta}, true)
                    end
                end
            end)
            return Resizing
        end
    end

    -- Custom font
    local CustomFont = { } do
        function CustomFont:New(Name, Weight, Style, Data)
            if not isfile(Data.Id) then
                writefile(Data.Id, game:HttpGet(Data.Url))
            end
            local Data = {
                name = Name,
                faces = {{
                    name = Name, weight = Weight, style = Style,
                    assetId = getcustomasset(Data.Id)
                }}
            }
            writefile(`{Library.Folders.Fonts}/{Name}.font`, HttpService:JSONEncode(Data))
            return Font.new(getcustomasset(`{Library.Folders.Fonts}/{Name}.font`),
                Enum.FontWeight.Regular, Enum.FontStyle.Normal)
        end

        pcall(function()
            Library.Font = CustomFont:New("InterSemiBold", "Regular", "Normal", {
                Id = "Inter",
                Url = "https://github.com/sametexe001/luas/raw/refs/heads/main/fonts/InterSemibold.ttf"
            })
        end)
    end

    Library.Holder = Instances:Create("ScreenGui", {
        Parent = gethui(), Name = "\0",
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
        DisplayOrder = 2, ResetOnSpawn = false
    })

    Library.UnusedHolder = Instances:Create("ScreenGui", {
        Parent = gethui(), Name = "\0",
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
        Enabled = false, ResetOnSpawn = false
    })

    Library.NotifHolder = Instances:Create("Frame", {
        Parent = Library.Holder.Instance, Name = "\0",
        BackgroundTransparency = 1, Size = UDim2New(0, 0, 1, 0),
        BorderColor3 = FromRGB(0, 0, 0), BorderSizePixel = 0,
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundColor3 = FromRGB(255, 255, 255)
    })

    Instances:Create("UIListLayout", {
        Parent = Library.NotifHolder.Instance, Name = "\0",
        Padding = UDimNew(0, 12), SortOrder = Enum.SortOrder.LayoutOrder
    })

    Instances:Create("UIPadding", {
        Parent = Library.NotifHolder.Instance, Name = "\0",
        PaddingTop = UDimNew(0, 12), PaddingBottom = UDimNew(0, 12),
        PaddingRight = UDimNew(0, 12), PaddingLeft = UDimNew(0, 12)
    })

    Library.Unload = function(self)
        for Index, Value in self.Connections do Value.Connection:Disconnect() end
        for Index, Value in self.Threads do coroutine.close(Value) end
        if self.Holder then self.Holder:Clean() end
        Library = nil
        getgenv().Library = nil
    end

    Library.Round = function(self, Number, Float)
        local Multiplier = 1 / (Float or 1)
        return MathFloor(Number * Multiplier) / Multiplier
    end

    Library.Thread = function(self, Function)
        local NewThread = coroutine.create(Function)
        coroutine.wrap(function() coroutine.resume(NewThread) end)()
        TableInsert(self.Threads, NewThread)
        return NewThread
    end

    Library.SafeCall = function(self, Function, ...)
        local Arguements = { ... }
        local Success, Result = pcall(Function, TableUnpack(Arguements))
        if not Success then warn(Result); return false end
        return Success
    end

    Library.Connect = function(self, Event, Callback, Name)
        Name = Name or StringFormat("connection_number_%s_%s", self.UnnamedConnections + 1, HttpService:GenerateGUID(false))
        local NewConnection = { Event = Event, Callback = Callback, Name = Name, Connection = nil }
        Library:Thread(function() NewConnection.Connection = Event:Connect(Callback) end)
        TableInsert(self.Connections, NewConnection)
        return NewConnection
    end

    Library.NextFlag = function(self)
        local FlagNumber = self.UnnamedFlags + 1
        return StringFormat("flag_number_%s_%s", FlagNumber, HttpService:GenerateGUID(false))
    end

    Library.AddToTheme = function(self, Item, Properties)
        Item = Item.Instance or Item
        local ThemeData = { Item = Item, Properties = Properties }
        for Property, Value in ThemeData.Properties do
            if type(Value) == "string" then Item[Property] = self.Theme[Value]
            else Item[Property] = Value() end
        end
        TableInsert(self.ThemeItems, ThemeData)
        self.ThemeMap[Item] = ThemeData
    end

    Library.ChangeTheme = function(self, Theme, Color)
        self.Theme[Theme] = Color
        for _, Item in self.ThemeItems do
            for Property, Value in Item.Properties do
                if type(Value) == "string" and Value == Theme then
                    Item.Item[Property] = Color
                elseif type(Value) == "function" then
                    Item.Item[Property] = Value()
                end
            end
        end
    end

    Library.IsMouseOverFrame = function(self, Frame)
        Frame = Frame.Instance
        local MousePosition = Vector2New(Mouse.X, Mouse.Y)
        return MousePosition.X >= Frame.AbsolutePosition.X and MousePosition.X <= Frame.AbsolutePosition.X + Frame.AbsoluteSize.X
        and MousePosition.Y >= Frame.AbsolutePosition.Y and MousePosition.Y <= Frame.AbsolutePosition.Y + Frame.AbsoluteSize.Y
    end

    Library.CompareVectors = function(self, PointA, PointB)
        return (PointA.X < PointB.X) or (PointA.Y < PointB.Y)
    end

    Library.IsClipped = function(self, Object, Column)
        local Parent = Column
        local BoundryTop = Parent.AbsolutePosition
        local BoundryBottom = BoundryTop + Parent.AbsoluteSize
        local Top = Object.AbsolutePosition
        local Bottom = Top + Object.AbsoluteSize
        return Library:CompareVectors(Top, BoundryTop) or Library:CompareVectors(BoundryBottom, Bottom)
    end

    -- ═══════════ Colorpicker ═══════════
    do
        Library.CreateColorpicker = function(self, Data)
            local Colorpicker = {
                Hue = 0, Saturation = 0, Value = 0,
                Color = FromRGB(0, 0, 0), HexValue = "000000",
                Flag = Data.Flag, IsOpen = false
            }

            local Items = { } do
                Items["ColorpickerButton"] = Instances:Create("TextButton", {
                    Parent = Data.Parent.Instance, Name = "\0", FontFace = Library.Font,
                    TextColor3 = FromRGB(0, 0, 0), BorderColor3 = FromRGB(0, 0, 0),
                    Text = "", AutoButtonColor = false,
                    Size = UDim2New(0, 14, 0, 14), BorderSizePixel = 0,
                    TextSize = 14, BackgroundColor3 = FromRGB(164, 229, 255)
                })
                Instances:Create("UIStroke", {
                    Parent = Items["ColorpickerButton"].Instance, Name = "\0",
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                    Color = FromRGB(56, 62, 62), Thickness = 1.5
                }):AddToTheme({Color = "Border 2"})
                Instances:Create("UICorner", {
                    Parent = Items["ColorpickerButton"].Instance, Name = "\0",
                    CornerRadius = UDimNew(0, 4)
                })
                Items["ColorpickerWindow"] = Instances:Create("Frame", {
                    Parent = Library.UnusedHolder.Instance, Name = "\0",
                    Visible = false, Position = UDim2New(0, 115, 0, 102),
                    BorderColor3 = FromRGB(0, 0, 0), Size = UDim2New(0, 183, 0, 201),
                    BorderSizePixel = 0, BackgroundColor3 = FromRGB(16, 18, 18)
                })  Items["ColorpickerWindow"]:AddToTheme({BackgroundColor3 = "Background"})
                Instances:Create("UICorner", {
                    Parent = Items["ColorpickerWindow"].Instance, Name = "\0",
                    CornerRadius = UDimNew(0, 7)
                })
                Items["Inline"] = Instances:Create("Frame", {
                    Parent = Items["ColorpickerWindow"].Instance, Name = "\0",
                    Position = UDim2New(0, 6, 0, 6), BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(1, -12, 1, -12), BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(21, 24, 24)
                })  Items["Inline"]:AddToTheme({BackgroundColor3 = "Inline"})
                Instances:Create("UIStroke", {
                    Parent = Items["Inline"].Instance, Name = "\0",
                    Color = FromRGB(30, 33, 33), ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                }):AddToTheme({Color = "Border"})
                Instances:Create("UICorner", {
                    Parent = Items["Inline"].Instance, Name = "\0", CornerRadius = UDimNew(0, 7)
                })
                Items["Palette"] = Instances:Create("TextButton", {
                    Parent = Items["Inline"].Instance, Name = "\0", FontFace = Library.Font,
                    TextColor3 = FromRGB(0, 0, 0), BorderColor3 = FromRGB(0, 0, 0),
                    Text = "-,", AutoButtonColor = false,
                    Position = UDim2New(0, 6, 0, 6), Size = UDim2New(1, -12, 1, -40),
                    BorderSizePixel = 0, TextSize = 14, BackgroundColor3 = FromRGB(164, 229, 255)
                })
                Instances:Create("UICorner", {
                    Parent = Items["Palette"].Instance, Name = "\0", CornerRadius = UDimNew(0, 7)
                })
                Instances:Create("UIStroke", {
                    Parent = Items["Palette"].Instance, Name = "\0",
                    Color = FromRGB(30, 33, 33), ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                }):AddToTheme({Color = "Border"})
                Items["Saturation"] = Instances:Create("ImageLabel", {
                    Parent = Items["Palette"].Instance, Name = "\0",
                    BorderColor3 = FromRGB(0, 0, 0), Image = "rbxassetid://130624743341203",
                    BackgroundTransparency = 1, Size = UDim2New(1, 0, 1, 0),
                    ZIndex = 2, BorderSizePixel = 0, BackgroundColor3 = FromRGB(255, 255, 255)
                })
                Instances:Create("UICorner", {
                    Parent = Items["Saturation"].Instance, Name = "\0", CornerRadius = UDimNew(0, 7)
                })
                Items["Value"] = Instances:Create("ImageLabel", {
                    Parent = Items["Palette"].Instance, Name = "\0", BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(1, 2, 1, 0), Image = "rbxassetid://96192970265863",
                    BackgroundTransparency = 1, Position = UDim2New(0, -1, 0, 0),
                    ZIndex = 3, BorderSizePixel = 0, BackgroundColor3 = FromRGB(255, 255, 255)
                })
                Instances:Create("UICorner", {
                    Parent = Items["Value"].Instance, Name = "\0", CornerRadius = UDimNew(0, 7)
                })
                Items["PaletteDragger"] = Instances:Create("Frame", {
                    Parent = Items["Palette"].Instance, Name = "\0",
                    Size = UDim2New(0, 3, 0, 3), Position = UDim2New(0, 5, 0, 5),
                    BorderColor3 = FromRGB(0, 0, 0), ZIndex = 3, BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })
                Instances:Create("UICorner", {
                    Parent = Items["PaletteDragger"].Instance, Name = "\0", CornerRadius = UDimNew(1, 0)
                })
                Instances:Create("UIStroke", {
                    Parent = Items["PaletteDragger"].Instance, Name = "\0",
                    Color = FromRGB(120, 120, 120), ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                })
                Items["Hue"] = Instances:Create("TextButton", {
                    Parent = Items["Inline"].Instance, Name = "\0", FontFace = Library.Font,
                    TextColor3 = FromRGB(0, 0, 0), BorderColor3 = FromRGB(0, 0, 0),
                    Text = "", AutoButtonColor = false,
                    AnchorPoint = Vector2New(0, 1), Position = UDim2New(0, 6, 1, -6),
                    Size = UDim2New(1, -12, 0, 18), BorderSizePixel = 0,
                    TextSize = 14, BackgroundColor3 = FromRGB(255, 255, 255)
                })
                Instances:Create("UICorner", {
                    Parent = Items["Hue"].Instance, Name = "\0", CornerRadius = UDimNew(0, 7)
                })
                Instances:Create("UIStroke", {
                    Parent = Items["Hue"].Instance, Name = "\0",
                    Color = FromRGB(30, 33, 33), ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                }):AddToTheme({Color = "Border"})
                Instances:Create("UIGradient", {
                    Parent = Items["Hue"].Instance, Name = "\0",
                    Color = RGBSequence{
                        RGBSequenceKeypoint(0, FromRGB(255,0,0)),
                        RGBSequenceKeypoint(0.17, FromRGB(255,255,0)),
                        RGBSequenceKeypoint(0.33, FromRGB(0,255,0)),
                        RGBSequenceKeypoint(0.5, FromRGB(0,255,255)),
                        RGBSequenceKeypoint(0.67, FromRGB(0,0,255)),
                        RGBSequenceKeypoint(0.83, FromRGB(255,0,255)),
                        RGBSequenceKeypoint(1, FromRGB(255,0,0))
                    }
                })
                Items["HueDragger"] = Instances:Create("Frame", {
                    Parent = Items["Hue"].Instance, Name = "\0", BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(0, 2, 1, 0), BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })
                Instances:Create("UIStroke", {
                    Parent = Items["HueDragger"].Instance, Name = "\0",
                    Color = FromRGB(30, 33, 33), ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                }):AddToTheme({Color = "Border"})
            end

            local Debounce = false
            local RenderStepped

            function Colorpicker:SetVisibility(Bool) Items["ColorpickerButton"].Instance.Visible = Bool end

            function Colorpicker:SetOpen(Bool)
                if Debounce then return end
                Colorpicker.IsOpen = Bool
                Debounce = true
                if Colorpicker.IsOpen then
                    Items["ColorpickerWindow"].Instance.Visible = true
                    Items["ColorpickerWindow"].Instance.Parent = Library.Holder.Instance
                    RenderStepped = RunService.RenderStepped:Connect(function()
                        Items["ColorpickerWindow"].Instance.Position = UDim2New(
                            0, Items["ColorpickerButton"].Instance.AbsolutePosition.X + 18,
                            0, Items["ColorpickerButton"].Instance.AbsolutePosition.Y - 25)
                    end)
                    for Index, Value in Library.OpenFrames do
                        if not Data.Section.IsSettings then Value:SetOpen(false) end
                    end
                    Library.OpenFrames[Colorpicker] = Colorpicker
                else
                    if Library.OpenFrames[Colorpicker] then Library.OpenFrames[Colorpicker] = nil end
                    if RenderStepped then RenderStepped:Disconnect(); RenderStepped = nil end
                end
                local Descendants = Items["ColorpickerWindow"].Instance:GetDescendants()
                TableInsert(Descendants, Items["ColorpickerWindow"].Instance)
                local NewTween
                for Index, Value in Descendants do
                    local TransparencyProperty = Tween:GetProperty(Value)
                    if not TransparencyProperty then continue end
                    if not Value.ClassName:find("UI") then
                        Value.ZIndex = Colorpicker.IsOpen and 4 or 1
                    end
                    if type(TransparencyProperty) == "table" then
                        for _, Property in TransparencyProperty do
                            NewTween = Tween:FadeItem(Value, Property, Bool, Library.FadeSpeed)
                        end
                    else
                        NewTween = Tween:FadeItem(Value, TransparencyProperty, Bool, Library.FadeSpeed)
                    end
                end
                NewTween.Tween.Completed:Connect(function()
                    Debounce = false
                    Items["ColorpickerWindow"].Instance.Visible = Colorpicker.IsOpen
                    task.wait(0.2)
                    Items["ColorpickerWindow"].Instance.Parent = not Colorpicker.IsOpen and Library.UnusedHolder.Instance or Library.Holder.Instance
                end)
            end

            function Colorpicker:Update()
                local Hue, Saturation, Value = Colorpicker.Hue, Colorpicker.Saturation, Colorpicker.Value
                Colorpicker.Color = FromHSV(Hue, Saturation, Value)
                Colorpicker.HexValue = Colorpicker.Color:ToHex()
                Library.Flags[Colorpicker.Flag] = { Color = Colorpicker.Color, HexValue = Colorpicker.HexValue }
                Items["ColorpickerButton"]:Tween(nil, {BackgroundColor3 = Colorpicker.Color})
                Items["Palette"]:Tween(nil, {BackgroundColor3 = FromHSV(Hue, 1, 1)})
                if Data.Callback then Library:SafeCall(Data.Callback, Colorpicker.Color, Colorpicker.Alpha) end
            end

            local SlidingPalette = false
            local PaletteChanged
            function Colorpicker:SlidePalette(Input)
                if not Input or not SlidingPalette then return end
                local ValueX = MathClamp(1 - (Input.Position.X - Items["Palette"].Instance.AbsolutePosition.X) / Items["Palette"].Instance.AbsoluteSize.X, 0, 1)
                local ValueY = MathClamp(1 - (Input.Position.Y - Items["Palette"].Instance.AbsolutePosition.Y) / Items["Palette"].Instance.AbsoluteSize.Y, 0, 1)
                Colorpicker.Saturation = ValueX
                Colorpicker.Value = ValueY
                local SlideX = MathClamp((Input.Position.X - Items["Palette"].Instance.AbsolutePosition.X) / Items["Palette"].Instance.AbsoluteSize.X, 0, 0.98)
                local SlideY = MathClamp((Input.Position.Y - Items["Palette"].Instance.AbsolutePosition.Y) / Items["Palette"].Instance.AbsoluteSize.Y, 0, 0.98)
                Items["PaletteDragger"]:Tween(TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2New(SlideX, 0, SlideY, 0)})
                Colorpicker:Update()
            end

            local SlidingHue = false
            local HueChanged
            function Colorpicker:SlideHue(Input)
                if not Input or not SlidingHue then return end
                local ValueX = MathClamp((Input.Position.X - Items["Hue"].Instance.AbsolutePosition.X) / Items["Hue"].Instance.AbsoluteSize.X, 0, 1)
                Colorpicker.Hue = ValueX
                local SlideX = MathClamp((Input.Position.X - Items["Hue"].Instance.AbsolutePosition.X) / Items["Hue"].Instance.AbsoluteSize.X, 0, 0.995)
                Items["HueDragger"]:Tween(TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2New(SlideX, 0, 0, 0)})
                Colorpicker:Update()
            end

            function Colorpicker:Set(Color, Alpha)
                if type(Color) == "table" then Color = FromRGB(Color[1], Color[2], Color[3]); Alpha = Color[4]
                elseif type(Color) == "string" then Color = FromHex(Color) end
                Colorpicker.Hue, Colorpicker.Saturation, Colorpicker.Value = Color:ToHSV()
                Colorpicker.Alpha = Alpha or 0
                local PaletteValueX = MathClamp(1 - Colorpicker.Saturation, 0, 0.98)
                local PaletteValueY = MathClamp(1 - Colorpicker.Value, 0, 0.98)
                local HuePositionX = MathClamp(Colorpicker.Hue, 0, 0.99)
                Items["PaletteDragger"]:Tween(TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2New(PaletteValueX, 0, PaletteValueY, 0)})
                Items["HueDragger"]:Tween(TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2New(HuePositionX, 0, 0, 0)})
                Colorpicker:Update()
            end

            Items["ColorpickerButton"]:Connect("MouseButton1Down", function()
                Colorpicker:SetOpen(not Colorpicker.IsOpen)
            end)
            Items["Palette"]:Connect("InputBegan", function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                    SlidingPalette = true
                    Colorpicker:SlidePalette(Input)
                    if PaletteChanged then return end
                    PaletteChanged = Input.Changed:Connect(function()
                        if Input.UserInputState == Enum.UserInputState.End then
                            SlidingPalette = false
                            PaletteChanged:Disconnect()
                            PaletteChanged = nil
                        end
                    end)
                end
            end)
            Items["Hue"]:Connect("InputBegan", function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                    SlidingHue = true
                    Colorpicker:SlideHue(Input)
                    if HueChanged then return end
                    HueChanged = Input.Changed:Connect(function()
                        if Input.UserInputState == Enum.UserInputState.End then
                            SlidingHue = false
                            HueChanged:Disconnect()
                            HueChanged = nil
                        end
                    end)
                end
            end)
            Library:Connect(UserInputService.InputBegan, function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    if Colorpicker.IsOpen then
                        if Library:IsMouseOverFrame(Items["ColorpickerWindow"]) then return end
                        Colorpicker:SetOpen(false)
                    end
                end
            end)
            Library:Connect(UserInputService.InputChanged, function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
                    if SlidingPalette then Colorpicker:SlidePalette(Input) end
                    if SlidingHue then Colorpicker:SlideHue(Input) end
                end
            end)
            if Data.Default then Colorpicker:Set(Data.Default) end
            Library.SetFlags[Colorpicker.Flag] = function(Color, Alpha) Colorpicker:Set(Color, Alpha) end
            return Colorpicker, Items
        end

        -- ═══════════ Keybind ═══════════
        Library.CreateKeybind = function(self, Data)
            local Keybind = {
                Flag = Data.Flag, Key = "", Value = "", Mode = "",
                Toggled = false, Picking = false, IsOpen = false
            }

            local Items = { } do
                Items["KeyButton"] = Instances:Create("TextButton", {
                    Parent = Data.Parent.Instance, Name = "\0", FontFace = Library.Font,
                    TextColor3 = FromRGB(100, 100, 100), BorderColor3 = FromRGB(0, 0, 0),
                    Text = "-", AutoButtonColor = false,
                    Size = UDim2New(0, 0, 1, 0), BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.X,
                    TextSize = 12, BackgroundColor3 = FromRGB(30, 34, 34)
                })  Items["KeyButton"]:AddToTheme({BackgroundColor3 = "Element"})
                Instances:Create("UICorner", {
                    Parent = Items["KeyButton"].Instance, Name = "\0", CornerRadius = UDimNew(0, 4)
                })
                Instances:Create("UIPadding", {
                    Parent = Items["KeyButton"].Instance, Name = "\0",
                    PaddingRight = UDimNew(0, 4), PaddingLeft = UDimNew(0, 5)
                })
                Items["KeybindWindow"] = Instances:Create("Frame", {
                    Parent = Library.UnusedHolder.Instance, Name = "\0",
                    Visible = false, Position = UDim2New(0, 231, 0, 102),
                    BorderColor3 = FromRGB(0, 0, 0), Size = UDim2New(0, 67, 0, 92),
                    BorderSizePixel = 0, BackgroundColor3 = FromRGB(16, 18, 18)
                })  Items["KeybindWindow"]:AddToTheme({BackgroundColor3 = "Background"})
                Instances:Create("UICorner", {
                    Parent = Items["KeybindWindow"].Instance, Name = "\0", CornerRadius = UDimNew(0, 7)
                })
                Items["Inline"] = Instances:Create("Frame", {
                    Parent = Items["KeybindWindow"].Instance, Name = "\0",
                    Position = UDim2New(0, 6, 0, 6), BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(1, -12, 1, -12), BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(21, 24, 24)
                })  Items["Inline"]:AddToTheme({BackgroundColor3 = "Inline"})
                Instances:Create("UIStroke", {
                    Parent = Items["Inline"].Instance, Name = "\0",
                    Color = FromRGB(30, 33, 33), ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                }):AddToTheme({Color = "Border"})
                Instances:Create("UICorner", {
                    Parent = Items["Inline"].Instance, Name = "\0", CornerRadius = UDimNew(0, 7)
                })
                Items["Toggle"] = Instances:Create("TextButton", {
                    Parent = Items["Inline"].Instance, Name = "\0", FontFace = Library.Font,
                    TextColor3 = FromRGB(255, 255, 255), BorderColor3 = FromRGB(0, 0, 0),
                    Text = "Toggle", AutoButtonColor = false, BackgroundTransparency = 1,
                    Size = UDim2New(1, 0, 0, 20), BorderSizePixel = 0,
                    TextSize = 14, BackgroundColor3 = FromRGB(255, 255, 255)
                })
                Instances:Create("UIListLayout", {
                    Parent = Items["Inline"].Instance, Name = "\0",
                    Padding = UDimNew(0, 5), SortOrder = Enum.SortOrder.LayoutOrder
                })
                Instances:Create("UIPadding", {
                    Parent = Items["Inline"].Instance, Name = "\0", PaddingTop = UDimNew(0, 4)
                })
                Items["Hold"] = Instances:Create("TextButton", {
                    Parent = Items["Inline"].Instance, Name = "\0", FontFace = Library.Font,
                    TextColor3 = FromRGB(100, 100, 100), BorderColor3 = FromRGB(0, 0, 0),
                    Text = "Hold", AutoButtonColor = false, BackgroundTransparency = 1,
                    Size = UDim2New(1, 0, 0, 20), BorderSizePixel = 0,
                    TextSize = 14, BackgroundColor3 = FromRGB(255, 255, 255)
                })
                Items["Always"] = Instances:Create("TextButton", {
                    Parent = Items["Inline"].Instance, Name = "\0", FontFace = Library.Font,
                    TextColor3 = FromRGB(100, 100, 100), BorderColor3 = FromRGB(0, 0, 0),
                    Text = "Always", AutoButtonColor = false, BackgroundTransparency = 1,
                    Size = UDim2New(1, 0, 0, 20), BorderSizePixel = 0,
                    TextSize = 14, BackgroundColor3 = FromRGB(255, 255, 255)
                })
            end

            local Modes = { ["Always"] = Items["Always"], ["Hold"] = Items["Hold"], ["Toggle"] = Items["Toggle"] }
            local Debounce = false
            local RenderStepped

            function Keybind:SetMode(Mode)
                for Index, Value in Modes do
                    if Index == Mode then Value:Tween(nil, {TextColor3 = FromRGB(255, 255, 255)})
                    else Value:Tween(nil, {TextColor3 = FromRGB(100, 100, 100)}) end
                end
                Library.Flags[Keybind.Flag] = { Mode = Keybind.Mode, Key = Keybind.Key, Toggled = Keybind.Toggled }
                if Data.Callback then Library:SafeCall(Data.Callback, Keybind.Toggled) end
            end

            function Keybind:Set(Key)
                if StringFind(tostring(Key), "Enum") then
                    Keybind.Key = tostring(Key)
                    Key = Key.Name == "Backspace" and "None" or Key.Name
                    local KeyString = Keys[Keybind.Key] or StringGSub(Key, "Enum.", "") or "None"
                    local TextToDisplay = StringGSub(StringGSub(KeyString, "KeyCode.", ""), "UserInputType.", "") or "None"
                    Keybind.Value = TextToDisplay
                    Items["KeyButton"].Instance.Text = TextToDisplay
                    Library.Flags[Keybind.Flag] = { Mode = Keybind.Mode, Key = Keybind.Key, Toggled = Keybind.Toggled }
                    if Data.Callback then Library:SafeCall(Data.Callback, Keybind.Toggled) end
                elseif type(Key) == "table" then
                    local RealKey = Key.Key == "Backspace" and "None" or Key.Key
                    Keybind.Key = tostring(Key.Key)
                    if Key.Mode then Keybind.Mode = Key.Mode; Keybind:SetMode(Key.Mode)
                    else Keybind.Mode = "Toggle"; Keybind:SetMode("Toggle") end
                    local KeyString = Keys[Keybind.Key] or StringGSub(tostring(RealKey), "Enum.", "") or RealKey
                    local TextToDisplay = StringGSub(StringGSub(KeyString, "KeyCode.", ""), "UserInputType.", "")
                    Keybind.Value = TextToDisplay
                    Items["KeyButton"].Instance.Text = TextToDisplay
                    if Data.Callback then Library:SafeCall(Data.Callback, Keybind.Toggled) end
                elseif TableFind({"Toggle", "Hold", "Always"}, Key) then
                    Keybind.Mode = Key
                    Keybind:SetMode(Key)
                    if Data.Callback then Library:SafeCall(Data.Callback, Keybind.Toggled) end
                end
                Keybind.Picking = false
            end

            function Keybind:Press(Bool)
                if Keybind.Mode == "Toggle" then Keybind.Toggled = not Keybind.Toggled
                elseif Keybind.Mode == "Hold" then Keybind.Toggled = Bool
                elseif Keybind.Mode == "Always" then Keybind.Toggled = true end
                Library.Flags[Keybind.Flag] = { Mode = Keybind.Mode, Key = Keybind.Key, Toggled = Keybind.Toggled }
                if Data.Callback then Library:SafeCall(Data.Callback, Keybind.Toggled) end
            end

            Items["KeyButton"]:Connect("MouseButton1Click", function()
                Keybind.Picking = true
                Items["KeyButton"].Instance.Text = "."
                Library:Thread(function()
                    local Count = 1
                    while true do
                        if not Keybind.Picking then break end
                        if Count == 4 then Count = 1 end
                        Items["KeyButton"].Instance.Text = Count == 1 and "." or Count == 2 and ".." or Count == 3 and "..."
                        Count += 1
                        task.wait(0.35)
                    end
                end)
                local InputBegan
                InputBegan = UserInputService.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.Keyboard then Keybind:Set(Input.KeyCode)
                    else Keybind:Set(Input.UserInputType) end
                    InputBegan:Disconnect()
                    InputBegan = nil
                end)
            end)

            Items["Toggle"]:Connect("MouseButton1Down", function() Keybind.Mode = "Toggle"; Keybind:SetMode("Toggle") end)
            Items["Hold"]:Connect("MouseButton1Down",   function() Keybind.Mode = "Hold";   Keybind:SetMode("Hold")   end)
            Items["Always"]:Connect("MouseButton1Down", function() Keybind.Mode = "Always"; Keybind:SetMode("Always") end)

            Library:Connect(UserInputService.InputBegan, function(Input)
                if Keybind.Value == "None" then return end
                if tostring(Input.KeyCode) == Keybind.Key then
                    if Keybind.Mode == "Toggle" then Keybind:Press()
                    elseif Keybind.Mode == "Hold" then Keybind:Press(true)
                    elseif Keybind.Mode == "Always" then Keybind:Press(true) end
                elseif tostring(Input.UserInputType) == Keybind.Key then
                    if Keybind.Mode == "Toggle" then Keybind:Press()
                    elseif Keybind.Mode == "Hold" then Keybind:Press(true)
                    elseif Keybind.Mode == "Always" then Keybind:Press(true) end
                end
            end)

            Library:Connect(UserInputService.InputEnded, function(Input)
                if Keybind.Value == "None" then return end
                if tostring(Input.KeyCode) == Keybind.Key then
                    if Keybind.Mode == "Hold" then Keybind:Press(false)
                    elseif Keybind.Mode == "Always" then Keybind:Press(true) end
                elseif tostring(Input.UserInputType) == Keybind.Key then
                    if Keybind.Mode == "Hold" then Keybind:Press(false)
                    elseif Keybind.Mode == "Always" then Keybind:Press(true) end
                end
            end)

            if Data.Default then Keybind:Set({ Mode = Data.Mode or "Toggle", Key = Data.Default }) end
            Library.SetFlags[Keybind.Flag] = function(Value) Keybind:Set(Value) end
            return Keybind, Items
        end

        -- ═══════════ Notification ═══════════
        Library.Notification = function(self, Name, Duration, Icon)
            local Items = { } do
                Items["Notification"] = Instances:Create("Frame", {
                    Parent = Library.NotifHolder.Instance, Name = "\0",
                    Size = UDim2New(0, 0, 0, 30), BorderColor3 = FromRGB(0, 0, 0),
                    BorderSizePixel = 0, AutomaticSize = Enum.AutomaticSize.X,
                    BackgroundColor3 = FromRGB(16, 18, 18)
                })  Items["Notification"]:AddToTheme({BackgroundColor3 = "Background"})
                Instances:Create("UICorner", {
                    Parent = Items["Notification"].Instance, Name = "\0", CornerRadius = UDimNew(0, 7)
                })
                Items["UIStroke"] = Instances:Create("UIStroke", {
                    Parent = Items["Notification"].Instance, Name = "\0",
                    Color = FromRGB(30, 33, 33), ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                })  Items["UIStroke"]:AddToTheme({Color = "Border"})
                Instances:Create("UIPadding", {
                    Parent = Items["Notification"].Instance, Name = "\0",
                    PaddingRight = UDimNew(0, 8), PaddingLeft = UDimNew(0, 8)
                })
                if Icon then
                    Items["Icon"] = Instances:Create("ImageLabel", {
                        Parent = Items["Notification"].Instance, Name = "\0",
                        ImageColor3 = FromRGB(255, 255, 255), BorderColor3 = FromRGB(0, 0, 0),
                        AnchorPoint = Vector2New(0, 0.5), Image = "rbxassetid://"..Icon,
                        BackgroundTransparency = 1, Position = UDim2New(0, 0, 0.5, 0),
                        Size = UDim2New(0, 16, 0, 16), BorderSizePixel = 0,
                        BackgroundColor3 = FromRGB(255, 255, 255)
                    })
                end
                Items["Text"] = Instances:Create("TextLabel", {
                    Parent = Items["Notification"].Instance, Name = "\0", FontFace = Library.Font,
                    TextColor3 = FromRGB(255, 255, 255), BorderColor3 = FromRGB(0, 0, 0),
                    Text = Name, AnchorPoint = Vector2New(0, 0.5),
                    Size = UDim2New(0, 0, 0, 15), BackgroundTransparency = 1,
                    Position = UDim2New(0, Icon and 24 or 0, 0.5, 0),
                    BorderSizePixel = 0, AutomaticSize = Enum.AutomaticSize.X,
                    TextSize = 14, BackgroundColor3 = FromRGB(255, 255, 255)
                })
            end

            local Size = Items["Notification"].Instance.AbsoluteSize

            for Index, Value in Items do
                if Value.Instance:IsA("Frame") then Value.Instance.BackgroundTransparency = 1
                elseif Value.Instance:IsA("TextLabel") then Value.Instance.TextTransparency = 1
                elseif Value.Instance:IsA("ImageLabel") then Value.Instance.ImageTransparency = 1
                elseif Value.Instance:IsA("UIStroke") then Value.Instance.Transparency = 1 end
            end

            task.wait(0.3)
            Items["Notification"].Instance.AutomaticSize = Enum.AutomaticSize.Y

            Library:Thread(function()
                for Index, Value in Items do
                    if Value.Instance:IsA("Frame") then Value:Tween(nil, {BackgroundTransparency = 0})
                    elseif Value.Instance:IsA("TextLabel") then Value:Tween(nil, {TextTransparency = 0})
                    elseif Value.Instance:IsA("ImageLabel") then Value:Tween(nil, {ImageTransparency = 0.5})
                    elseif Value.Instance:IsA("UIStroke") then Value:Tween(nil, {Transparency = 0}) end
                end
                Items["Notification"]:Tween(nil, {Size = UDim2New(0, Size.X, 0, Size.Y)})
                task.delay(Duration, function()
                    for Index, Value in Items do
                        if Value.Instance:IsA("Frame") then Value:Tween(nil, {BackgroundTransparency = 1})
                        elseif Value.Instance:IsA("TextLabel") then Value:Tween(nil, {TextTransparency = 1})
                        elseif Value.Instance:IsA("ImageLabel") then Value:Tween(nil, {ImageTransparency = 1})
                        elseif Value.Instance:IsA("UIStroke") then Value:Tween(nil, {Transparency = 1}) end
                    end
                    Items["Notification"]:Tween(nil, {Size = UDim2New(0, 0, 0, 0)})
                    task.wait(0.5)
                    Items["Notification"]:Clean()
                end)
            end)
        end

        -- ═══════════ Window ═══════════
        Library.Window = function(self, Data)
            local StartTime = tick()
            Data = Data or { }

            local Window = {
                Name = Data.Name or Data.name or "Window",
                SubTitle = Data.SubTitle or Data.subtitle or "for PUBG",
                ExpiresIn = Data.ExpiresIn or Data.expiresin or "23d",
                Pages = { }, Items = { }, IsOpen = false
            }

            local Items = { } do
                local FirstLetterOfName = StringSub(Window.Name, 1, 1)
                Items["MainFrame"] = Instances:Create("Frame", {
                    Parent = Library.Holder.Instance, Name = "\0",
                    AnchorPoint = Vector2New(0.5, 0.5),
                    Position = UDim2New(0.5, 0, 0.5, 0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(0, 798, 0, 599),
                    BorderSizePixel = 0, BackgroundColor3 = FromRGB(16, 18, 18)
                })  Items["MainFrame"]:AddToTheme({BackgroundColor3 = "Background"})

                Items["MainFrame"]:MakeDraggable()
                Items["MainFrame"]:MakeResizeable(
                    Vector2New(Items["MainFrame"].Instance.AbsoluteSize.X, Items["MainFrame"].Instance.AbsoluteSize.Y),
                    Vector2New(9999, 9999))

                Instances:Create("UICorner", {
                    Parent = Items["MainFrame"].Instance, Name = "\0", CornerRadius = UDimNew(0, 7)
                })
                Items["Side"] = Instances:Create("Frame", {
                    Parent = Items["MainFrame"].Instance, Name = "\0",
                    BackgroundTransparency = 1, BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(0, 215, 1, 0), BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })
                Items["Title"] = Instances:Create("Frame", {
                    Parent = Items["Side"].Instance, Name = "\0",
                    Position = UDim2New(0, 6, 0, 6), BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(1, -12, 0, 60), BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(21, 24, 24)
                })  Items["Title"]:AddToTheme({BackgroundColor3 = "Inline"})
                Instances:Create("UICorner", {
                    Parent = Items["Title"].Instance, Name = "\0", CornerRadius = UDimNew(0, 7)
                })
                Instances:Create("UIStroke", {
                    Parent = Items["Title"].Instance, Name = "\0",
                    Color = FromRGB(30, 33, 33), ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                }):AddToTheme({Color = "Border"})
                Items["Background"] = Instances:Create("Frame", {
                    Parent = Items["Title"].Instance, Name = "\0",
                    AnchorPoint = Vector2New(0, 0.5), Position = UDim2New(0, 12, 0.5, 0),
                    BorderColor3 = FromRGB(0, 0, 0), Size = UDim2New(0, 40, 0, 40),
                    BorderSizePixel = 0, BackgroundColor3 = FromRGB(207, 207, 207)
                })
                Instances:Create("UICorner", {
                    Parent = Items["Background"].Instance, Name = "\0", CornerRadius = UDimNew(0, 7)
                })
                Instances:Create("UIStroke", {
                    Parent = Items["Background"].Instance, Name = "\0",
                    Color = FromRGB(30, 33, 33), ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                }):AddToTheme({Color = "Border"})
                Items["Text"] = Instances:Create("TextLabel", {
                    Parent = Items["Background"].Instance, Name = "\0", FontFace = Library.Font,
                    TextColor3 = FromRGB(0, 0, 0), BorderColor3 = FromRGB(0, 0, 0),
                    Text = FirstLetterOfName, AnchorPoint = Vector2New(0.5, 0.5),
                    BackgroundTransparency = 1, Position = UDim2New(0.5, 0, 0.5, 0),
                    Size = UDim2New(1, -10, 1, -10), BorderSizePixel = 0,
                    TextSize = 22, BackgroundColor3 = FromRGB(255, 255, 255)
                })
                Items["RealTitle"] = Instances:Create("TextLabel", {
                    Parent = Items["Title"].Instance, Name = "\0", FontFace = Library.Font,
                    TextColor3 = FromRGB(255, 255, 255), BorderColor3 = FromRGB(0, 0, 0),
                    Text = Window.Name, Size = UDim2New(0, 0, 0, 15),
                    BackgroundTransparency = 1, Position = UDim2New(0, 65, 0, 14),
                    BorderSizePixel = 0, AutomaticSize = Enum.AutomaticSize.X,
                    TextSize = 14, BackgroundColor3 = FromRGB(255, 255, 255)
                })
                Items["Game"] = Instances:Create("TextLabel", {
                    Parent = Items["Title"].Instance, Name = "\0", FontFace = Library.Font,
                    TextColor3 = FromRGB(255, 255, 255), TextTransparency = 0.5,
                    Text = Window.SubTitle, Size = UDim2New(0, 0, 0, 15),
                    BorderSizePixel = 0, BackgroundTransparency = 1,
                    Position = UDim2New(0, 65, 0, 30), BorderColor3 = FromRGB(0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.X, TextSize = 14,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })
                Items["Pages"] = Instances:Create("Frame", {
                    Parent = Items["Side"].Instance, Name = "\0",
                    BackgroundTransparency = 1, Position = UDim2New(0, 0, 0, 75),
                    BorderColor3 = FromRGB(0, 0, 0), Size = UDim2New(1, 0, 1, -80),
                    BorderSizePixel = 0, BackgroundColor3 = FromRGB(255, 255, 255)
                })
                Instances:Create("UIListLayout", {
                    Parent = Items["Pages"].Instance, Name = "\0",
                    Padding = UDimNew(0, 8), SortOrder = Enum.SortOrder.LayoutOrder
                })
                Instances:Create("UIPadding", {
                    Parent = Items["Pages"].Instance, Name = "\0", PaddingLeft = UDimNew(0, 8)
                })
                Items["Content"] = Instances:Create("Frame", {
                    Parent = Items["MainFrame"].Instance, Name = "\0",
                    Position = UDim2New(0, 220, 0, 6), BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(1, -226, 1, -12), BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(21, 24, 24)
                })  Items["Content"]:AddToTheme({BackgroundColor3 = "Inline"})
                Instances:Create("UICorner", {
                    Parent = Items["Content"].Instance, Name = "\0", CornerRadius = UDimNew(0, 7)
                })
                Instances:Create("UIStroke", {
                    Parent = Items["Content"].Instance, Name = "\0",
                    Color = FromRGB(30, 33, 33), ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                }):AddToTheme({Color = "Border"})
                Items["Bottom_"] = Instances:Create("Frame", {
                    Parent = Items["Side"].Instance, Name = "\0",
                    AnchorPoint = Vector2New(0, 1), Position = UDim2New(0, 6, 1, -6),
                    BorderColor3 = FromRGB(0, 0, 0), Size = UDim2New(1, -12, 0, 45),
                    BorderSizePixel = 0, BackgroundColor3 = FromRGB(21, 24, 24)
                })  Items["Bottom_"]:AddToTheme({BackgroundColor3 = "Inline"})
                Instances:Create("UICorner", {
                    Parent = Items["Bottom_"].Instance, Name = "\0", CornerRadius = UDimNew(0, 7)
                })
                Instances:Create("UIStroke", {
                    Parent = Items["Bottom_"].Instance, Name = "\0",
                    Color = FromRGB(30, 33, 33), ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                }):AddToTheme({Color = "Border"})
                Items["SubExpires"] = Instances:Create("TextLabel", {
                    Parent = Items["Bottom_"].Instance, Name = "\0", FontFace = Library.Font,
                    TextColor3 = FromRGB(255, 255, 255), TextTransparency = 0.5,
                    Text = "Sub expires in "..Window.ExpiresIn,
                    Size = UDim2New(0, 0, 0, 15), BorderSizePixel = 0,
                    BackgroundTransparency = 1, Position = UDim2New(0, 10, 0, 8),
                    BorderColor3 = FromRGB(0, 0, 0), AutomaticSize = Enum.AutomaticSize.X,
                    TextSize = 12, BackgroundColor3 = FromRGB(255, 255, 255)
                })
                Items["SessionDuration"] = Instances:Create("TextLabel", {
                    Parent = Items["Bottom_"].Instance, Name = "\0", FontFace = Library.Font,
                    TextColor3 = FromRGB(255, 255, 255), BorderColor3 = FromRGB(0, 0, 0),
                    Text = "Session duration: ", Size = UDim2New(0, 0, 0, 15),
                    BackgroundTransparency = 1, Position = UDim2New(0, 10, 0, 23),
                    BorderSizePixel = 0, AutomaticSize = Enum.AutomaticSize.X,
                    TextSize = 12, BackgroundColor3 = FromRGB(255, 255, 255)
                })
                Library:Thread(function()
                    while task.wait(1) do
                        local SecondsPassed = MathFloor(tick() - StartTime)
                        local MinutesPassed = MathFloor(SecondsPassed / 60)
                        if MinutesPassed > 0 then SecondsPassed = SecondsPassed - MinutesPassed * 60 end
                        Items["SessionDuration"].Instance.Text = "Session duration: "..MinutesPassed..":"..SecondsPassed
                    end
                end)
                Window.Items = Items
            end

            local Debounce = false

            function Window:SetCenter()
                local CenterPosition = Items["MainFrame"].Instance.AbsolutePosition
                task.wait()
                Items["MainFrame"].Instance.AnchorPoint = Vector2New(0, 0)
                Items["MainFrame"].Instance.Position = UDim2New(0, CenterPosition.X, 0, CenterPosition.Y)
            end

            function Window:SetOpen(Bool)
                if Debounce then return end
                Window.IsOpen = Bool
                Debounce = true
                if Window.IsOpen then Items["MainFrame"].Instance.Visible = true end
                local Descendants = Items["MainFrame"].Instance:GetDescendants()
                TableInsert(Descendants, Items["MainFrame"].Instance)
                local NewTween
                for Index, Value in Descendants do
                    local TransparencyProperty = Tween:GetProperty(Value)
                    if not TransparencyProperty then continue end
                    if type(TransparencyProperty) == "table" then
                        for _, Property in TransparencyProperty do
                            NewTween = Tween:FadeItem(Value, Property, Bool, Library.FadeSpeed)
                        end
                    else
                        NewTween = Tween:FadeItem(Value, TransparencyProperty, Bool, Library.FadeSpeed)
                    end
                end
                NewTween.Tween.Completed:Connect(function()
                    Debounce = false
                    Items["MainFrame"].Instance.Visible = Window.IsOpen
                end)
            end

            Library:Connect(UserInputService.InputBegan, function(Input)
                if tostring(Input.KeyCode) == Library.MenuKeybind
                   or tostring(Input.UserInputType) == Library.MenuKeybind then
                    Window:SetOpen(not Window.IsOpen)
                end
            end)

            Window:SetCenter()
            task.wait()
            Window:SetOpen(true)
            return setmetatable(Window, Library)
        end

        -- ═══════════ Page ═══════════
        Library.Page = function(self, Data)
            Data = Data or { }
            local Page = {
                Window = self,
                Name = Data.Name or Data.name or "Page",
                Icon = Data.Icon or Data.icon or "136879043989014",
                Items = { }, SubPages = { }, Active = false
            }

            local Items = { } do
                Items["Inactive"] = Instances:Create("TextButton", {
                    Parent = Page.Window.Items["Pages"].Instance, Name = "\0",
                    FontFace = Library.Font, TextColor3 = FromRGB(0, 0, 0),
                    BorderColor3 = FromRGB(0, 0, 0), Text = "", AutoButtonColor = false,
                    BackgroundTransparency = 1, Size = UDim2New(0, 200, 0, 30),
                    BorderSizePixel = 0, TextSize = 14, BackgroundColor3 = FromRGB(21, 24, 24)
                })  Items["Inactive"]:AddToTheme({BackgroundColor3 = "Inline"})
                Items["UIStroke"] = Instances:Create("UIStroke", {
                    Parent = Items["Inactive"].Instance, Name = "\0",
                    Color = FromRGB(30, 33, 33), Transparency = 1,
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                })  Items["UIStroke"]:AddToTheme({Color = "Border"})
                Instances:Create("UICorner", {
                    Parent = Items["Inactive"].Instance, Name = "\0", CornerRadius = UDimNew(0, 7)
                })
                Items["Icon"] = Instances:Create("ImageLabel", {
                    Parent = Items["Inactive"].Instance, Name = "\0",
                    ImageColor3 = FromRGB(100, 100, 100), BorderColor3 = FromRGB(0, 0, 0),
                    AnchorPoint = Vector2New(0, 0.5), Image = "rbxassetid://"..Page.Icon,
                    BackgroundTransparency = 1, Position = UDim2New(0, 10, 0.5, 0),
                    Size = UDim2New(0, 16, 0, 16), BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })
                Items["Text"] = Instances:Create("TextLabel", {
                    Parent = Items["Inactive"].Instance, Name = "\0", FontFace = Library.Font,
                    TextColor3 = FromRGB(100, 100, 100), BorderColor3 = FromRGB(0, 0, 0),
                    Text = Page.Name, AnchorPoint = Vector2New(0, 0.5),
                    Size = UDim2New(0, 0, 0, 15), BackgroundTransparency = 1,
                    Position = UDim2New(0, 38, 0.5, 0), BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.X, TextSize = 14,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })
                Items["Page"] = Instances:Create("Frame", {
                    Parent = Library.UnusedHolder.Instance, Name = "\0", Visible = false,
                    BackgroundTransparency = 1, BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(1, 0, 1, 0), BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })
                Items["SubPages"] = Instances:Create("Frame", {
                    Parent = Items["Page"].Instance, Name = "\0",
                    Size = UDim2New(0, 0, 0, 30), Position = UDim2New(0, 13, 0, 42),
                    BorderColor3 = FromRGB(0, 0, 0), BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.X, BackgroundColor3 = FromRGB(16, 18, 18)
                })  Items["SubPages"]:AddToTheme({BackgroundColor3 = "Background"})
                Instances:Create("UIPadding", {
                    Parent = Items["SubPages"].Instance, Name = "\0",
                    PaddingTop = UDimNew(0, 2), PaddingBottom = UDimNew(0, 2),
                    PaddingRight = UDimNew(0, 2), PaddingLeft = UDimNew(0, 2)
                })
                Instances:Create("UIListLayout", {
                    Parent = Items["SubPages"].Instance, Name = "\0",
                    Padding = UDimNew(0, 2), FillDirection = Enum.FillDirection.Horizontal,
                    SortOrder = Enum.SortOrder.LayoutOrder
                })
                Instances:Create("UICorner", {
                    Parent = Items["SubPages"].Instance, Name = "\0", CornerRadius = UDimNew(0, 7)
                })
                Items["Columns"] = Instances:Create("Frame", {
                    Parent = Items["Page"].Instance, Name = "\0",
                    Size = UDim2New(1, -20, 1, -82), Position = UDim2New(0, 10, 0, 75),
                    BorderColor3 = FromRGB(0, 0, 0), BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.X, BackgroundColor3 = FromRGB(255, 255, 255),
                    BackgroundTransparency = 1
                })
                Page.Items = Items
            end

            local Debounce = false

            function Page:Turn(Bool)
                if Debounce then return end
                Page.Active = Bool
                Debounce = true
                Items["Page"].Instance.Visible = Bool
                Items["Page"].Instance.Parent = Bool and Page.Window.Items["Content"].Instance or Library.UnusedHolder.Instance
                if Page.Active then
                    Items["Inactive"]:Tween(nil, {BackgroundTransparency = 0})
                    Items["Icon"]:Tween(nil, {ImageColor3 = FromRGB(200, 200, 200)})
                    Items["Text"]:Tween(nil, {TextColor3 = FromRGB(200, 200, 200)})
                    Items["UIStroke"]:Tween(nil, {Transparency = 0})
                else
                    Items["Inactive"]:Tween(nil, {BackgroundTransparency = 1})
                    Items["Icon"]:Tween(nil, {ImageColor3 = FromRGB(100, 100, 100)})
                    Items["Text"]:Tween(nil, {TextColor3 = FromRGB(100, 100, 100)})
                    Items["UIStroke"]:Tween(nil, {Transparency = 1})
                end
                Debounce = false
            end

            Items["Inactive"]:Connect("MouseButton1Down", function()
                for Index, Value in Page.Window.Pages do
                    if Value == Page and Page.Active then return end
                    Value:Turn(Value == Page)
                end
            end)

            if #Page.Window.Pages == 0 then Page:Turn(true) end
            TableInsert(Page.Window.Pages, Page)
            return setmetatable(Page, Library.Pages)
        end

        -- ═══════════ Category ═══════════
        Library.Category = function(self, Name)
            local Items = { } do
                Items["Category"] = Instances:Create("TextLabel", {
                    Parent = self.Items["Pages"].Instance, Name = "\0", FontFace = Library.Font,
                    TextColor3 = FromRGB(255, 255, 255), TextTransparency = 0.5,
                    Text = Name, Size = UDim2New(0, 0, 0, 15),
                    BackgroundTransparency = 1, BorderSizePixel = 0,
                    BorderColor3 = FromRGB(0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.X,
                    TextSize = 12, BackgroundColor3 = FromRGB(255, 255, 255)
                })
            end
            return Items
        end

        -- ═══════════ SubPage ═══════════
        Library.Pages.SubPage = function(self, Data)
            Data = Data or { }
            local Page = {
                Window = self.Window, Page = self,
                Name = Data.Name or Data.name or "SubPage",
                Columns = Data.Columns or Data.columns or 2,
                Items = { }, ColumnsData = { }, Active = false
            }

            local Items = { } do
                Items["Inactive"] = Instances:Create("TextButton", {
                    Parent = Page.Page.Items["SubPages"].Instance, Name = "\0",
                    FontFace = Library.Font, TextColor3 = FromRGB(255, 255, 255),
                    TextTransparency = 0.5, Text = Page.Name, AutoButtonColor = false,
                    Size = UDim2New(0, 0, 1, 0), BackgroundTransparency = 1,
                    BorderSizePixel = 0, BorderColor3 = FromRGB(0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.X,
                    TextSize = 14, BackgroundColor3 = FromRGB(30, 34, 34)
                })  Items["Inactive"]:AddToTheme({BackgroundColor3 = "Element"})
                Instances:Create("UIPadding", {
                    Parent = Items["Inactive"].Instance, Name = "\0",
                    PaddingRight = UDimNew(0, 8), PaddingLeft = UDimNew(0, 8)
                })
                Instances:Create("UICorner", {
                    Parent = Items["Inactive"].Instance, Name = "\0", CornerRadius = UDimNew(0, 7)
                })
                Items["Page"] = Instances:Create("Frame", {
                    Parent = Library.UnusedHolder.Instance, Name = "\0", Visible = false,
                    BackgroundTransparency = 1, BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(1, 0, 1, 0), BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })
                Instances:Create("UIListLayout", {
                    Parent = Items["Page"].Instance, Name = "\0",
                    FillDirection = Enum.FillDirection.Horizontal,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    HorizontalFlex = Enum.UIFlexAlignment.Fill
                })
                for Index = 1, Page.Columns do
                    local NewColumn = Instances:Create("ScrollingFrame", {
                        Parent = Items["Page"].Instance, Name = "\0",
                        ScrollBarImageColor3 = FromRGB(0, 0, 0), Active = true,
                        BorderColor3 = FromRGB(0, 0, 0), ScrollBarThickness = 0,
                        BackgroundTransparency = 1, Size = UDim2New(1, 0, 1, 0),
                        BorderSizePixel = 0, BackgroundColor3 = FromRGB(255, 255, 255)
                    })
                    if Index == 1 then
                        Instances:Create("UIPadding", {
                            Parent = NewColumn.Instance, Name = "\0",
                            PaddingTop = UDimNew(0, 3), PaddingBottom = UDimNew(0, 3),
                            PaddingRight = UDimNew(0, 8), PaddingLeft = UDimNew(0, 3)
                        })
                    elseif Index == 2 then
                        Instances:Create("UIPadding", {
                            Parent = NewColumn.Instance, Name = "\0",
                            PaddingTop = UDimNew(0, 3), PaddingBottom = UDimNew(0, 3),
                            PaddingRight = UDimNew(0, 20), PaddingLeft = UDimNew(0, 8)
                        })
                    end
                    Page.ColumnsData[Index] = NewColumn
                end
            end

            local Debounce = false

            function Page:Turn(Bool)
                if Debounce then return end
                Page.Active = Bool
                Debounce = true
                Items["Page"].Instance.Visible = Bool
                Items["Page"].Instance.Parent = Bool and Page.Page.Items["Columns"].Instance or Library.UnusedHolder.Instance
                if Page.Active then
                    Items["Inactive"]:Tween(nil, {BackgroundTransparency = 0, TextTransparency = 0})
                else
                    Items["Inactive"]:Tween(nil, {BackgroundTransparency = 1, TextTransparency = 0.5})
                end
                Debounce = false
            end

            Items["Inactive"]:Connect("MouseButton1Down", function()
                for Index, Value in Page.Page.SubPages do
                    if Value == Page and Page.Active then return end
                    Value:Turn(Value == Page)
                end
            end)

            if #Page.Page.SubPages == 0 then Page:Turn(true) end
            TableInsert(Page.Page.SubPages, Page)
            return setmetatable(Page, Library.Pages)
        end

        -- ═══════════ Section ═══════════
        Library.Pages.Section = function(self, Data)
            Data = Data or { }
            local Section = {
                Window = self.Window, Page = self,
                Name = Data.Name or Data.name or "Section",
                Icon = Data.Icon or Data.icon or "",
                Side = Data.Side or Data.side or 1,
                Items = { }
            }

            local Items = { } do
                Items["Section"] = Instances:Create("Frame", {
                    Parent = Section.Page.ColumnsData[Section.Side].Instance, Name = "\0",
                    Size = UDim2New(1, 0, 0, 25), BorderColor3 = FromRGB(0, 0, 0),
                    BorderSizePixel = 0, AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundColor3 = FromRGB(21, 24, 24)
                })  Items["Section"]:AddToTheme({BackgroundColor3 = "Inline"})
                Instances:Create("UICorner", {
                    Parent = Items["Section"].Instance, Name = "\0", CornerRadius = UDimNew(0, 7)
                })
                Instances:Create("UIStroke", {
                    Parent = Items["Section"].Instance, Name = "\0",
                    Color = FromRGB(30, 33, 33), ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                }):AddToTheme({Color = "Border"})
                Items["Icon"] = Instances:Create("ImageLabel", {
                    Parent = Items["Section"].Instance, Name = "\0",
                    ImageColor3 = FromRGB(100, 100, 100), BorderColor3 = FromRGB(0, 0, 0),
                    Image = "rbxassetid://"..Section.Icon, BackgroundTransparency = 1,
                    Position = UDim2New(0, 12, 0, 12), Size = UDim2New(0, 16, 0, 16),
                    BorderSizePixel = 0, BackgroundColor3 = FromRGB(255, 255, 255)
                })
                Instances:Create("UIPadding", {
                    Parent = Items["Section"].Instance, Name = "\0", PaddingBottom = UDimNew(0, 12)
                })
                Items["Text"] = Instances:Create("TextLabel", {
                    Parent = Items["Section"].Instance, Name = "\0", FontFace = Library.Font,
                    TextColor3 = FromRGB(100, 100, 100), BorderColor3 = FromRGB(0, 0, 0),
                    Text = Section.Name, Size = UDim2New(0, 0, 0, 15),
                    BackgroundTransparency = 1, Position = UDim2New(0, 35, 0, 12),
                    BorderSizePixel = 0, AutomaticSize = Enum.AutomaticSize.X,
                    TextSize = 14, BackgroundColor3 = FromRGB(255, 255, 255)
                })
                Items["Content"] = Instances:Create("Frame", {
                    Parent = Items["Section"].Instance, Name = "\0", BorderColor3 = FromRGB(0, 0, 0),
                    BackgroundTransparency = 1, Position = UDim2New(0, 12, 0, 42),
                    Size = UDim2New(1, -24, 0, 0), BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = FromRGB(255, 255, 255)
                })
                Instances:Create("UIListLayout", {
                    Parent = Items["Content"].Instance, Name = "\0",
                    Padding = UDimNew(0, 8), SortOrder = Enum.SortOrder.LayoutOrder
                })
                Section.Items = Items
            end

            return setmetatable(Section, Library.Sections)
        end

        -- ═══════════ Toggle ═══════════
        Library.Sections.Toggle = function(self, Data)
            Data = Data or { }
            local Toggle = {
                Window = self.Window, Page = self.Page, Section = self,
                Name = Data.Name or Data.name or "Toggle",
                Flag = Data.Flag or Data.flag or Library:NextFlag(),
                Default = Data.Default or Data.default or false,
                Callback = Data.Callback or Data.callback or function() end,
                Value = false
            }

            local Items = { } do
                Items["Toggle"] = Instances:Create("TextButton", {
                    Parent = Toggle.Section.Items["Content"].Instance, Name = "\0",
                    FontFace = Library.Font, TextColor3 = FromRGB(0, 0, 0),
                    BorderColor3 = FromRGB(0, 0, 0), Text = "", AutoButtonColor = false,
                    BackgroundTransparency = 1, Size = UDim2New(1, 0, 0, 16),
                    BorderSizePixel = 0, TextSize = 14, BackgroundColor3 = FromRGB(255, 255, 255)
                })
                Items["Text"] = Instances:Create("TextLabel", {
                    Parent = Items["Toggle"].Instance, Name = "\0", FontFace = Library.Font,
                    TextColor3 = FromRGB(100, 100, 100), BorderColor3 = FromRGB(0, 0, 0),
                    Text = Toggle.Name, AnchorPoint = Vector2New(0, 0.5),
                    Size = UDim2New(0, 0, 0, 15), BackgroundTransparency = 1,
                    Position = UDim2New(0, 0, 0.5, 0), BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.X, TextSize = 14,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })
                Items["Indicator"] = Instances:Create("Frame", {
                    Parent = Items["Toggle"].Instance, Name = "\0", BorderColor3 = FromRGB(0, 0, 0),
                    AnchorPoint = Vector2New(1, 0), BackgroundTransparency = 1,
                    Position = UDim2New(1, 0, 0, 0), Size = UDim2New(0, 14, 0, 14),
                    BorderSizePixel = 0, BackgroundColor3 = FromRGB(30, 33, 33)
                })  Items["Indicator"]:AddToTheme({BackgroundColor3 = "Element"})
                Instances:Create("UIStroke", {
                    Parent = Items["Indicator"].Instance, Name = "\0",
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                    Color = FromRGB(56, 62, 62), Thickness = 2
                }):AddToTheme({Color = "Border 2"})
                Instances:Create("UICorner", {
                    Parent = Items["Indicator"].Instance, Name = "\0", CornerRadius = UDimNew(0, 4)
                })
                Items["Inline"] = Instances:Create("Frame", {
                    Parent = Items["Indicator"].Instance, Name = "\0",
                    BackgroundTransparency = 1, BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(1, 0, 1, 0), BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  Items["Inline"]:AddToTheme({BackgroundColor3 = "Accent"})
                Instances:Create("UICorner", {
                    Parent = Items["Inline"].Instance, Name = "\0", CornerRadius = UDimNew(0, 4)
                })
                Items["CheckImage"] = Instances:Create("ImageLabel", {
                    Parent = Items["Inline"].Instance, Name = "\0",
                    ImageColor3 = FromRGB(0, 0, 0), BorderColor3 = FromRGB(0, 0, 0),
                    AnchorPoint = Vector2New(0.5, 0.5),
                    Image = "rbxassetid://132128200461292", ImageTransparency = 1,
                    BackgroundTransparency = 1, Position = UDim2New(0.5, 0, 0.5, 0),
                    Size = UDim2New(1, -4, 1, -4), BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })
                Items["SubElements"] = Instances:Create("Frame", {
                    Parent = Items["Toggle"].Instance, Name = "\0",
                    BorderColor3 = FromRGB(0, 0, 0), AnchorPoint = Vector2New(1, 0),
                    BackgroundTransparency = 1, Position = UDim2New(1, -25, 0, 0),
                    Size = UDim2New(0, 0, 1, 0), BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.X, BackgroundColor3 = FromRGB(255, 255, 255)
                })
                Instances:Create("UIListLayout", {
                    Parent = Items["SubElements"].Instance, Name = "\0",
                    FillDirection = Enum.FillDirection.Horizontal,
                    HorizontalAlignment = Enum.HorizontalAlignment.Right,
                    Padding = UDimNew(0, 6), SortOrder = Enum.SortOrder.LayoutOrder
                })
            end

            function Toggle:Get() return Toggle.Value end

            function Toggle:Set(Value)
                Toggle.Value = Value
                Library.Flags[Toggle.Flag] = Value
                if Toggle.Value then
                    Items["Inline"]:Tween(nil,  {BackgroundTransparency = 0})
                    Items["CheckImage"]:Tween(nil, {ImageTransparency = 0})
                    Items["Text"]:Tween(nil, {TextColor3 = FromRGB(255, 255, 255)})
                else
                    Items["Inline"]:Tween(nil,  {BackgroundTransparency = 1})
                    Items["CheckImage"]:Tween(nil, {ImageTransparency = 1})
                    Items["Text"]:Tween(nil, {TextColor3 = FromRGB(100, 100, 100)})
                end
                if Toggle.Callback then Library:SafeCall(Toggle.Callback, Toggle.Value) end
            end

            Items["Toggle"]:Connect("MouseButton1Down", function()
                Toggle:Set(not Toggle.Value)
            end)

            Toggle:Set(Toggle.Default)
            Library.SetFlags[Toggle.Flag] = function(Value) Toggle:Set(Value) end
            return Toggle
        end

        -- ═══════════ Button ═══════════
        Library.Sections.Button = function(self, Data)
            Data = Data or { }
            local Button = {
                Window = self.Window, Page = self.Page, Section = self,
                Name = Data.Name or Data.name,
                Callback = Data.Callback or Data.callback or function() end
            }

            local Items = { } do
                Items["Button"] = Instances:Create("TextButton", {
                    Parent = Button.Section.Items["Content"].Instance, Name = "\0",
                    FontFace = Library.Font, TextColor3 = FromRGB(255, 255, 255),
                    BorderColor3 = FromRGB(0, 0, 0), Text = Button.Name,
                    AutoButtonColor = false, Size = UDim2New(1, 0, 0, 25),
                    BorderSizePixel = 0, TextSize = 14, BackgroundColor3 = FromRGB(30, 34, 34)
                })  Items["Button"]:AddToTheme({BackgroundColor3 = "Element"})
                Instances:Create("UICorner", {
                    Parent = Items["Button"].Instance, Name = "\0", CornerRadius = UDimNew(0, 4)
                })
                Instances:Create("UIStroke", {
                    Parent = Items["Button"].Instance, Name = "\0",
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                    Color = FromRGB(56, 62, 62), Thickness = 2
                }):AddToTheme({Color = "Border 2"})
                Instances:Create("UIPadding", {
                    Parent = Items["Button"].Instance, Name = "\0", PaddingBottom = UDimNew(0, 1)
                })
            end

            function Button:SetVisibility(Bool) Items["Button"].Instance.Visible = Bool end

            function Button:Press()
                Items["Button"]:ChangeItemTheme({BackgroundColor3 = "Accent"})
                Items["Button"]:Tween(nil, {BackgroundColor3 = Library.Theme.Accent, TextColor3 = FromRGB(0, 0, 0)})
                task.wait(0.1)
                Items["Button"]:ChangeItemTheme({BackgroundColor3 = "Element"})
                Items["Button"]:Tween(nil, {BackgroundColor3 = Library.Theme.Element, TextColor3 = FromRGB(255, 255, 255)})
                Library:SafeCall(Button.Callback)
            end

            Items["Button"]:Connect("MouseButton1Down", function() Button:Press() end)
            return Button
        end

        -- ═══════════ Slider ═══════════
        Library.Sections.Slider = function(self, Data)
            Data = Data or { }
            local Slider = {
                Window = self.Window, Page = self.Page, Section = self,
                Name = Data.Name or Data.name or "Slider",
                Min = Data.Min or Data.min or 0,
                Max = Data.Max or Data.max or 100,
                Callback = Data.Callback or Data.callback or function() end,
                Default = Data.Default or Data.default or 0,
                Flag = Data.Flag or Data.flag or Library:NextFlag(),
                Decimals = Data.Decimals or Data.decimals or 1,
                Suffix = Data.Suffix or Data.suffix or "",
                Value = 0, Sliding = false
            }

            local Items = { } do
                Items["Slider"] = Instances:Create("Frame", {
                    Parent = Slider.Section.Items["Content"].Instance, Name = "\0",
                    BackgroundTransparency = 1, BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(1, 0, 0, 30), BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })
                Items["Text"] = Instances:Create("TextLabel", {
                    Parent = Items["Slider"].Instance, Name = "\0", FontFace = Library.Font,
                    TextColor3 = FromRGB(255, 255, 255), BorderColor3 = FromRGB(0, 0, 0),
                    Text = Slider.Name, BackgroundTransparency = 1,
                    Size = UDim2New(0, 0, 0, 15), BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.X, TextSize = 14,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })
                Items["Value"] = Instances:Create("TextLabel", {
                    Parent = Items["Slider"].Instance, Name = "\0", FontFace = Library.Font,
                    TextColor3 = FromRGB(100, 100, 100), BorderColor3 = FromRGB(0, 0, 0),
                    Text = "", AnchorPoint = Vector2New(1, 0),
                    Size = UDim2New(0, 0, 0, 15), BackgroundTransparency = 1,
                    Position = UDim2New(1, 0, 0, 0), BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.X, TextSize = 14,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })
                Items["RealSlider"] = Instances:Create("TextButton", {
                    Parent = Items["Slider"].Instance, Text = "", AutoButtonColor = false,
                    Name = "\0", AnchorPoint = Vector2New(0, 1),
                    Position = UDim2New(0, 0, 1, 0), BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(1, 0, 0, 5), BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(30, 34, 34)
                })  Items["RealSlider"]:AddToTheme({BackgroundColor3 = "Element"})
                Instances:Create("UICorner", {
                    Parent = Items["RealSlider"].Instance, Name = "\0", CornerRadius = UDimNew(1, 0)
                })
                Items["Accent"] = Instances:Create("Frame", {
                    Parent = Items["RealSlider"].Instance, Name = "\0",
                    BorderColor3 = FromRGB(0, 0, 0), Size = UDim2New(0.4, 0, 1, 0),
                    BorderSizePixel = 0, BackgroundColor3 = FromRGB(255, 255, 255)
                })  Items["Accent"]:AddToTheme({BackgroundColor3 = "Accent"})
                Instances:Create("UICorner", {
                    Parent = Items["Accent"].Instance, Name = "\0", CornerRadius = UDimNew(0, 7)
                })
                Items["Circle"] = Instances:Create("Frame", {
                    Parent = Items["Accent"].Instance, Name = "\0",
                    AnchorPoint = Vector2New(1, 0.5), Position = UDim2New(1, 5, 0.5, 0),
                    BorderColor3 = FromRGB(0, 0, 0), Size = UDim2New(0, 8, 0, 8),
                    BorderSizePixel = 0, BackgroundColor3 = FromRGB(255, 255, 255)
                })  Items["Circle"]:AddToTheme({BackgroundColor3 = "Accent"})
                Instances:Create("UICorner", {
                    Parent = Items["Circle"].Instance, Name = "\0", CornerRadius = UDimNew(0, 7)
                })
                Instances:Create("UIGradient", {
                    Parent = Items["Accent"].Instance, Name = "\0",
                    Color = RGBSequence{
                        RGBSequenceKeypoint(0, FromRGB(180, 180, 180)),
                        RGBSequenceKeypoint(1, FromRGB(255, 255, 255))
                    }
                })
            end

            function Slider:Get() return Slider.Value end

            function Slider:Set(Value)
                Slider.Value = Library:Round(MathClamp(Value, Slider.Min, Slider.Max), Slider.Decimals)
                Library.Flags[Slider.Flag] = Slider.Value
                Items["Accent"]:Tween(TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
                    {Size = UDim2New((Slider.Value - Slider.Min) / (Slider.Max - Slider.Min), -2, 1, 0)})
                Items["Value"].Instance.Text = StringFormat("%s%s", Slider.Value, Slider.Suffix)
                if Slider.Callback then Library:SafeCall(Slider.Callback, Slider.Value) end
            end

            local InputChanged, InputChanged2

            Items["RealSlider"]:Connect("InputBegan", function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    Slider.Sliding = true
                    local SizeX = (Input.Position.X - Items["RealSlider"].Instance.AbsolutePosition.X) / Items["RealSlider"].Instance.AbsoluteSize.X
                    Slider:Set(((Slider.Max - Slider.Min) * SizeX) + Slider.Min)
                    if InputChanged then return end
                    InputChanged = Input.Changed:Connect(function()
                        if Input.UserInputState == Enum.UserInputState.End then
                            Slider.Sliding = false
                            InputChanged:Disconnect(); InputChanged = nil
                        end
                    end)
                end
            end)

            Items["Circle"]:Connect("InputBegan", function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    Slider.Sliding = true
                    local SizeX = (Input.Position.X - Items["RealSlider"].Instance.AbsolutePosition.X) / Items["RealSlider"].Instance.AbsoluteSize.X
                    Slider:Set(((Slider.Max - Slider.Min) * SizeX) + Slider.Min)
                    if InputChanged2 or InputChanged then return end
                    InputChanged2 = Input.Changed:Connect(function()
                        if Input.UserInputState == Enum.UserInputState.End then
                            Slider.Sliding = false
                            InputChanged2:Disconnect(); InputChanged2 = nil
                        end
                    end)
                end
            end)

            Library:Connect(UserInputService.InputChanged, function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
                    if Slider.Sliding then
                        local SizeX = (Input.Position.X - Items["RealSlider"].Instance.AbsolutePosition.X) / Items["RealSlider"].Instance.AbsoluteSize.X
                        Slider:Set(((Slider.Max - Slider.Min) * SizeX) + Slider.Min)
                    end
                end
            end)

            Slider:Set(Slider.Default)
            Library.SetFlags[Slider.Flag] = function(Value) Slider:Set(Value) end
            return Slider
        end

        -- ═══════════ Dropdown ═══════════
        Library.Sections.Dropdown = function(self, Data)
            Data = Data or { }
            local Dropdown = {
                Window = self.Window, Page = self.Page, Section = self,
                Name = Data.Name or Data.name or "Dropdown",
                Flag = Data.Flag or Data.flag or Library:NextFlag(),
                Items = Data.Items or Data.items or { },
                Default = Data.Default or Data.default or "",
                Callback = Data.Callback or Data.callback or function() end,
                Multi = Data.Multi or Data.multi or false,
                Value = { }, Options = { }, IsOpen = false
            }

            local Items = { } do
                Items["Dropdown"] = Instances:Create("Frame", {
                    Parent = Dropdown.Section.Items["Content"].Instance, Name = "\0",
                    BackgroundTransparency = 1, BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(1, 0, 0, 25), BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })
                Items["Text"] = Instances:Create("TextLabel", {
                    Parent = Items["Dropdown"].Instance, Name = "\0", FontFace = Library.Font,
                    TextColor3 = FromRGB(255, 255, 255), BorderColor3 = FromRGB(0, 0, 0),
                    Text = Dropdown.Name, AnchorPoint = Vector2New(0, 0.5),
                    Size = UDim2New(0, 0, 0, 15), BackgroundTransparency = 1,
                    Position = UDim2New(0, 0, 0.5, 0), BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.X, TextSize = 14,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })
                Items["RealDropdown"] = Instances:Create("TextButton", {
                    Parent = Items["Dropdown"].Instance, Name = "\0", FontFace = Library.Font,
                    TextColor3 = FromRGB(0, 0, 0), BorderColor3 = FromRGB(0, 0, 0),
                    Text = "", AutoButtonColor = false, AnchorPoint = Vector2New(1, 0.5),
                    Position = UDim2New(1, 0, 0.5, 0), Size = UDim2New(0, 80, 0, 25),
                    BorderSizePixel = 0, TextSize = 14, BackgroundColor3 = FromRGB(30, 34, 34)
                })  Items["RealDropdown"]:AddToTheme({BackgroundColor3 = "Element"})
                Instances:Create("UICorner", {
                    Parent = Items["RealDropdown"].Instance, Name = "\0", CornerRadius = UDimNew(0, 4)
                })
                Items["Value"] = Instances:Create("TextLabel", {
                    Parent = Items["RealDropdown"].Instance, Name = "\0", FontFace = Library.Font,
                    TextColor3 = FromRGB(100, 100, 100), BorderColor3 = FromRGB(0, 0, 0),
                    Text = "...", AnchorPoint = Vector2New(0, 0.5),
                    Size = UDim2New(1, -6, 0, 15), BackgroundTransparency = 1,
                    Position = UDim2New(0, 6, 0.5, 0), BorderSizePixel = 0,
                    TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })
                Items["Icon"] = Instances:Create("ImageLabel", {
                    Parent = Items["RealDropdown"].Instance, Name = "\0",
                    ImageColor3 = FromRGB(100, 100, 100), BorderColor3 = FromRGB(0, 0, 0),
                    AnchorPoint = Vector2New(1, 0.5),
                    Image = "rbxassetid://135448248851234", BackgroundTransparency = 1,
                    Position = UDim2New(1, -5, 0.5, 0), Size = UDim2New(0, 16, 0, 16),
                    BorderSizePixel = 0, BackgroundColor3 = FromRGB(255, 255, 255)
                })
                Items["OptionHolder"] = Instances:Create("Frame", {
                    Parent = Library.UnusedHolder.Instance, Name = "\0", Visible = false,
                    BorderColor3 = FromRGB(0, 0, 0), AnchorPoint = Vector2New(0, 0),
                    Position = UDim2New(1, 0, 0.5, 0), Size = UDim2New(0, 80, 0, 0),
                    BorderSizePixel = 0, AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundColor3 = FromRGB(21, 24, 24)
                })  Items["OptionHolder"]:AddToTheme({BackgroundColor3 = "Inline"})
                Instances:Create("UIStroke", {
                    Parent = Items["OptionHolder"].Instance, Name = "\0",
                    Color = FromRGB(30, 33, 33), ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                }):AddToTheme({Color = "Border"})
                Items["Holder"] = Instances:Create("ScrollingFrame", {
                    Parent = Items["OptionHolder"].Instance, Name = "\0", Active = true,
                    AutomaticCanvasSize = Enum.AutomaticSize.XY, ScrollBarThickness = 2,
                    Size = UDim2New(1, 0, 1, 0), BorderSizePixel = 0,
                    BackgroundTransparency = 1, ScrollingDirection = Enum.ScrollingDirection.Y,
                    BorderColor3 = FromRGB(0, 0, 0), BackgroundColor3 = FromRGB(255, 255, 255),
                    AutomaticSize = Enum.AutomaticSize.Y, CanvasSize = UDim2New(0, 0, 0, 0)
                })  Items["Holder"]:AddToTheme({ScrollBarImageColor3 = "Accent"})
                Instances:Create("UIListLayout", {
                    Parent = Items["Holder"].Instance, Name = "\0", SortOrder = Enum.SortOrder.LayoutOrder
                })
                Instances:Create("UIPadding", {
                    Parent = Items["OptionHolder"].Instance, Name = "\0", PaddingBottom = UDimNew(0, 4)
                })
            end

            function Dropdown:Get() return Dropdown.Value end

            local Debounce = false
            local RenderStepped

            function Dropdown:SetOpen(Bool)
                if Debounce then return end
                Dropdown.IsOpen = Bool
                Debounce = true
                if Dropdown.IsOpen then
                    Items["OptionHolder"].Instance.Visible = true
                    Items["OptionHolder"].Instance.Parent = Library.Holder.Instance
                    RenderStepped = RunService.RenderStepped:Connect(function()
                        Items["OptionHolder"].Instance.Position = UDim2New(
                            0, Items["RealDropdown"].Instance.AbsolutePosition.X,
                            0, Items["RealDropdown"].Instance.AbsolutePosition.Y - 25)
                        Items["OptionHolder"].Instance.Size = UDim2New(
                            0, Items["RealDropdown"].Instance.AbsoluteSize.X, 0, 0)
                    end)
                    for Index, Value in Library.OpenFrames do
                        if Value ~= Dropdown and not Dropdown.Section.IsSettings then Value:SetOpen(false) end
                    end
                    Library.OpenFrames[Dropdown] = Dropdown
                else
                    if Library.OpenFrames[Dropdown] then Library.OpenFrames[Dropdown] = nil end
                    if RenderStepped then RenderStepped:Disconnect(); RenderStepped = nil end
                end
                local Descendants = Items["OptionHolder"].Instance:GetDescendants()
                TableInsert(Descendants, Items["OptionHolder"].Instance)
                local NewTween
                for Index, Value in Descendants do
                    local TransparencyProperty = Tween:GetProperty(Value)
                    if not TransparencyProperty then continue end
                    if not Value.ClassName:find("UI") then Value.ZIndex = Dropdown.IsOpen and 3 or 1 end
                    if type(TransparencyProperty) == "table" then
                        for _, Property in TransparencyProperty do
                            NewTween = Tween:FadeItem(Value, Property, Bool, Library.FadeSpeed)
                        end
                    else
                        NewTween = Tween:FadeItem(Value, TransparencyProperty, Bool, Library.FadeSpeed)
                    end
                end
                NewTween.Tween.Completed:Connect(function()
                    Debounce = false
                    Items["OptionHolder"].Instance.Visible = Dropdown.IsOpen
                    task.wait(0.2)
                    Items["OptionHolder"].Instance.Parent = not Dropdown.IsOpen and Library.UnusedHolder.Instance or Library.Holder.Instance
                end)
            end

            function Dropdown:Set(Option)
                if Dropdown.Multi then
                    if type(Option) ~= "table" then return end
                    Dropdown.Value = Option
                    Library.Flags[Dropdown.Flag] = Option
                    for Index, Value in Option do
                        local OptionData = Dropdown.Options[Value]
                        if not OptionData then continue end
                        OptionData.Selected = true
                        OptionData:Toggle("Active")
                    end
                    Items["Value"].Instance.Text = TableConcat(Option, ", ")
                else
                    if not Dropdown.Options[Option] then return end
                    local OptionData = Dropdown.Options[Option]
                    Dropdown.Value = Option
                    Library.Flags[Dropdown.Flag] = Option
                    for Index, Value in Dropdown.Options do
                        if Value ~= OptionData then
                            Value.Selected = false
                            Value:Toggle("Inactive")
                        else
                            Value.Selected = true
                            Value:Toggle("Active")
                        end
                    end
                    Items["Value"].Instance.Text = Option
                end
                if Dropdown.Callback then Library:SafeCall(Dropdown.Callback, Dropdown.Value) end
            end

            function Dropdown:Add(Option)
                local OptionButton = Instances:Create("TextButton", {
                    Parent = Items["Holder"].Instance, Name = "\0", FontFace = Library.Font,
                    TextColor3 = FromRGB(100, 100, 100), BorderColor3 = FromRGB(0, 0, 0),
                    Text = Option, AutoButtonColor = false, BackgroundTransparency = 1,
                    Size = UDim2New(1, 0, 0, 25), BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.X, TextSize = 14,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  OptionButton:AddToTheme({BackgroundColor3 = "Accent"})

                local OptionData = { Button = OptionButton, Name = Option, Selected = false }

                function OptionData:Toggle(Value)
                    if Value == "Active" then
                        OptionData.Button:Tween(nil, {BackgroundTransparency = 0, TextColor3 = FromRGB(0, 0, 0)})
                    else
                        OptionData.Button:Tween(nil, {BackgroundTransparency = 1, TextColor3 = FromRGB(100, 100, 100)})
                    end
                end

                function OptionData:Set()
                    OptionData.Selected = not OptionData.Selected
                    if Dropdown.Multi then
                        local Index = TableFind(Dropdown.Value, OptionData.Name)
                        if Index then TableRemove(Dropdown.Value, Index)
                        else TableInsert(Dropdown.Value, OptionData.Name) end
                        OptionData:Toggle(Index and "Inactive" or "Active")
                        Library.Flags[Dropdown.Flag] = Dropdown.Value
                        local TextFormat = #Dropdown.Value > 0 and TableConcat(Dropdown.Value, ", ") or "..."
                        Items["Value"].Instance.Text = TextFormat
                    else
                        if OptionData.Selected then
                            Dropdown.Value = OptionData.Name
                            Library.Flags[Dropdown.Flag] = OptionData.Name
                            OptionData.Selected = true
                            OptionData:Toggle("Active")
                            for Index, Value in Dropdown.Options do
                                if Value ~= OptionData then
                                    Value.Selected = false
                                    Value:Toggle("Inactive")
                                end
                            end
                            Items["Value"].Instance.Text = OptionData.Name
                        else
                            Dropdown.Value = nil
                            Library.Flags[Dropdown.Flag] = nil
                            OptionData.Selected = false
                            OptionData:Toggle("Inactive")
                            Items["Value"].Instance.Text = "..."
                        end
                    end
                    if Dropdown.Callback then Library:SafeCall(Dropdown.Callback, Dropdown.Value) end
                end

                OptionData.Button:Connect("MouseButton1Down", function() OptionData:Set() end)
                Dropdown.Options[OptionData.Name] = OptionData
                return OptionData
            end

            function Dropdown:Remove(Option)
                if Dropdown.Options[Option] then
                    Dropdown.Options[Option].Button:Clean()
                    Dropdown.Options[Option] = nil
                end
            end

            function Dropdown:Refresh(List)
                for Index, Value in Dropdown.Options do Dropdown:Remove(Value.Name) end
                for Index, Value in List do Dropdown:Add(Value) end
            end

            Items["RealDropdown"]:Connect("MouseButton1Down", function()
                Dropdown:SetOpen(not Dropdown.IsOpen)
            end)

            Library:Connect(UserInputService.InputBegan, function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    if Dropdown.IsOpen then
                        if Library:IsMouseOverFrame(Items["OptionHolder"]) then return end
                        Dropdown:SetOpen(false)
                    end
                end
            end)

            for Index, Value in Dropdown.Items do Dropdown:Add(Value) end
            if Dropdown.Default then Dropdown:Set(Dropdown.Default) end
            Library.SetFlags[Dropdown.Flag] = function(Value) Dropdown:Set(Value) end
            return Dropdown
        end

        -- ═══════════ Label ═══════════
        Library.Sections.Label = function(self, Name)
            local Label = {
                Window = self.Window, Page = self.Page, Section = self,
                Name = Name or "Label"
            }

            local Items = { } do
                Items["Label"] = Instances:Create("Frame", {
                    Parent = Label.Section.Items["Content"].Instance, Name = "\0",
                    BackgroundTransparency = 1, BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(1, 0, 0, 17), BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })
                Items["Text"] = Instances:Create("TextLabel", {
                    Parent = Items["Label"].Instance, Name = "\0", FontFace = Library.Font,
                    TextColor3 = FromRGB(100, 100, 100), BorderColor3 = FromRGB(0, 0, 0),
                    Text = Label.Name, AnchorPoint = Vector2New(0, 0.5),
                    Size = UDim2New(0, 0, 0, 15), BackgroundTransparency = 1,
                    Position = UDim2New(0, 0, 0.5, 0), BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.X, TextSize = 14,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })
                Items["SubElements"] = Instances:Create("Frame", {
                    Parent = Items["Label"].Instance, Name = "\0",
                    BorderColor3 = FromRGB(0, 0, 0), AnchorPoint = Vector2New(1, 0),
                    BackgroundTransparency = 1, Position = UDim2New(1, 0, 0, 0),
                    Size = UDim2New(0, 0, 1, 0), BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.X, BackgroundColor3 = FromRGB(255, 255, 255)
                })
                Instances:Create("UIListLayout", {
                    Parent = Items["SubElements"].Instance, Name = "\0",
                    FillDirection = Enum.FillDirection.Horizontal,
                    HorizontalAlignment = Enum.HorizontalAlignment.Right,
                    Padding = UDimNew(0, 6), SortOrder = Enum.SortOrder.LayoutOrder
                })
            end

            function Label:SetText(Text)
                Text = tostring(Text)
                Items["Text"].Instance.Text = Text
            end
            function Label:SetVisibility(Bool) Items["Label"].Instance.Visible = Bool end

            function Label:Colorpicker(Data)
                Data = Data or { }
                return Library:CreateColorpicker({
                    Parent = Items["SubElements"], Page = Label.Page, Section = Label.Section,
                    Flag = Data.Flag or Data.flag or Library:NextFlag(),
                    Default = Data.Default or Data.default or Color3.fromRGB(255, 255, 255),
                    Callback = Data.Callback or Data.callback or function() end
                })
            end

            function Label:Keybind(Data)
                Data = Data or { }
                return Library:CreateKeybind({
                    Parent = Items["SubElements"], Page = Label.Page, Section = Label.Section,
                    Flag = Data.Flag or Data.flag or Library:NextFlag(),
                    Default = Data.Default or Data.default or Enum.KeyCode.E,
                    Mode = Data.Mode or Data.mode or "Toggle",
                    Callback = Data.Callback or Data.callback or function() end
                })
            end

            return Label
        end

        -- ═══════════ Textbox ═══════════
        Library.Sections.Textbox = function(self, Data)
            Data = Data or { }
            local Textbox = {
                Window = self.Window, Page = self.Page, Section = self,
                Flag = Data.Flag or Data.flag or Library:NextFlag(),
                Default = Data.Default or Data.default or "",
                Callback = Data.Callback or Data.callback or function() end,
                Placeholder = Data.Placeholder or Data.placeholder or "Placeholder",
                Numeric = Data.Numeric or Data.numeric or false,
                Finished = Data.Finished or Data.finished or false,
                Value = ""
            }

            local Items = { } do
                Items["Textbox"] = Instances:Create("Frame", {
                    Parent = Textbox.Section.Items["Content"].Instance, Name = "\0",
                    BackgroundTransparency = 1, BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(1, 0, 0, 25), BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })
                Items["Input"] = Instances:Create("TextBox", {
                    Parent = Items["Textbox"].Instance, Name = "\0", FontFace = Library.Font,
                    CursorPosition = -1, TextColor3 = FromRGB(255, 255, 255),
                    BorderColor3 = FromRGB(0, 0, 0), Text = "", Size = UDim2New(1, 0, 1, 0),
                    ClipsDescendants = true, BorderSizePixel = 0,
                    PlaceholderColor3 = FromRGB(100, 100, 100),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    PlaceholderText = Textbox.Placeholder, TextSize = 14,
                    BackgroundColor3 = FromRGB(30, 34, 34)
                })  Items["Input"]:AddToTheme({BackgroundColor3 = "Element"})
                Instances:Create("UICorner", {
                    Parent = Items["Input"].Instance, Name = "\0", CornerRadius = UDimNew(0, 4)
                })
                Instances:Create("UIStroke", {
                    Parent = Items["Input"].Instance, Name = "\0",
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                    Color = FromRGB(56, 62, 62), Thickness = 2
                }):AddToTheme({Color = "Border 2"})
                Instances:Create("UIPadding", {
                    Parent = Items["Input"].Instance, Name = "\0", PaddingLeft = UDimNew(0, 8)
                })
            end

            function Textbox:Get() return Textbox.Value end
            function Textbox:SetVisibility(Bool) Items["Textbox"].Instance.Visible = Bool end

            function Textbox:Set(Value)
                if Textbox.Numeric then
                    if (not tonumber(Value)) and StringLen(tostring(Value)) > 0 then Value = Textbox.Value end
                end
                Textbox.Value = Value
                Items["Input"].Instance.Text = Value
                Library.Flags[Textbox.Flag] = Value
                if Textbox.Callback then Library:SafeCall(Textbox.Callback, Value) end
            end

            if Textbox.Finished then
                Items["Input"]:Connect("FocusLost", function(Enter)
                    if Enter then Textbox:Set(Items["Input"].Instance.Text) end
                end)
            else
                Items["Input"].Instance:GetPropertyChangedSignal("Text"):Connect(function()
                    Textbox:Set(Items["Input"].Instance.Text)
                end)
            end

            if Textbox.Default then Textbox:Set(Textbox.Default) end
            Library.SetFlags[Textbox.Flag] = function(Value) Textbox:Set(Value) end
            return Textbox
        end
    end

    -- ═══════════ Settings Page ═══════════
    Library.CreateSettingsPage = function(self, Window)
        local SettingsPage = Window:Page({Name = "Settings", Icon = "72732892493295"}) do
            local ConfigsSubPage  = SettingsPage:SubPage({Name = "Configs"})
            local ThemingSubPage  = SettingsPage:SubPage({Name = "Theming"})
            local SettingsSubPage = SettingsPage:SubPage({Name = "Settings"})

            do -- Configs
                local ConfigsSection = ConfigsSubPage:Section({Name = "Configs", Side = 1, Icon = "97491613646216"})
                local ConfigName = ""
                local ConfigSelected
                local ConfigsList = ConfigsSection:Dropdown({
                    Name = "Configs", Flag = "ConfigsList", Items = { }, Multi = false,
                    Callback = function(Value) ConfigSelected = Value end
                })
                ConfigsSection:Textbox({
                    Default = "", Flag = "ConfigName", Placeholder = "Config name",
                    Callback = function(Value) ConfigName = Value end
                })
                ConfigsSection:Button({ Name = "Create", Callback = function()
                    if ConfigName and ConfigName ~= "" then
                        if not isfile(Library.Folders.Configs .. "/" .. ConfigName .. ".json") then
                            writefile(Library.Folders.Configs .. "/" .. ConfigName .. ".json", Library:GetConfig())
                            Library:RefreshConfigsList(ConfigsList)
                        end
                    end
                end})
                ConfigsSection:Button({ Name = "Delete", Callback = function()
                    if ConfigSelected then
                        Library:DeleteConfig(ConfigSelected)
                        Library:RefreshConfigsList(ConfigsList)
                    end
                end})
                ConfigsSection:Button({ Name = "Load", Callback = function()
                    if ConfigSelected then
                        Library:LoadConfig(readfile(Library.Folders.Configs .. "/" .. ConfigSelected))
                    end
                end})
                ConfigsSection:Button({ Name = "Save", Callback = function()
                    if ConfigName and ConfigName ~= "" then
                        writefile(Library.Folders.Configs .. "/" .. ConfigName .. ".json", Library:GetConfig())
                        Library:RefreshConfigsList(ConfigsList)
                    end
                end})
                ConfigsSection:Button({ Name = "Refresh", Callback = function()
                    Library:RefreshConfigsList(ConfigsList)
                end})
            end

            do -- Theming
                local ThemingSection = ThemingSubPage:Section({Name = "Theming", Icon = "131595494666590", Side = 1})
                for Index, Value in Library.Theme do
                    ThemingSection:Label(Index):Colorpicker({
                        Flag = Index.."Theme", Default = Value,
                        Callback = function(Value)
                            Library.Theme[Index] = Value
                            Library:ChangeTheme(Index, Value)
                        end
                    })
                end
            end

            do -- Settings
                local SettingsSection = SettingsSubPage:Section({Name = "Settings", Icon = "72732892493295", Side = 1})
                SettingsSection:Button({ Name = "Unload", Callback = function() Library:Unload() end })
                SettingsSection:Label("Menu Keybind"):Keybind({
                    Name = "Menu Keybind", Flag = "MenuKeybind",
                    Default = Library.MenuKeybind, Mode = "Toggle",
                    Callback = function() Library.MenuKeybind = Library.Flags["MenuKeybind"].Key end
                })
                SettingsSection:Slider({
                    Name = "Tween Speed", Default = 0.3, Flag = "Tween Speed",
                    Decimals = 0.01, Suffix = "s", Max = 10, Min = 0,
                    Callback = function(Value) Library.Tween.Time = Value end
                })
                SettingsSection:Dropdown({
                    Name = "Tween Style", Flag = "Tween style",
                    Items = { "Linear", "Quad", "Quart", "Back", "Bounce", "Circular", "Cubic", "Elastic", "Exponential", "Sine", "Quint" },
                    Default = "Quart",
                    Callback = function(Value)
                        if not Value then Value = "Quint" end
                        Library.Tween.Style = Enum.EasingStyle[Value]
                    end
                })
                SettingsSection:Dropdown({
                    Name = "Tween Direction", Flag = "Tween direction",
                    Items = { "In", "Out", "InOut" }, Default = "Out",
                    Callback = function(Value)
                        if not Value then Value = "Out" end
                        Library.Tween.Direction = Enum.EasingDirection[Value]
                    end
                })
            end
        end
    end
end

-- ═══════════════════════════════════════════════════════════════
-- DARK HUB | Cali Streets  —  Logic
-- ═══════════════════════════════════════════════════════════════

local Players                = game:GetService("Players")
local RunService             = game:GetService("RunService")
local UserInputService       = game:GetService("UserInputService")
local TweenService           = game:GetService("TweenService")
local Workspace              = game:GetService("Workspace")
local CoreGui                = game:GetService("CoreGui")
local ProximityPromptService = game:GetService("ProximityPromptService")

local LocalPlayer  = Players.LocalPlayer
local Camera       = Workspace.CurrentCamera
local setclipboard = setclipboard or toboard or writeclipboard

-- ─── State ───
_G.InfiniteStaminaEnabled = false
_G.AutoLoot               = false
_G.NoJumpCooldownEnabled  = false
_G.ESPEnabled             = false
_G.FPSBoostUsed           = false
_G.NoclipEnabled          = false
_G.WalkSpeedEnabled       = false
_G.WalkSpeedMultiplier    = 1.25
_G.InstantInteractEnabled = false
_G.InfiniteZoomEnabled    = false
_G.CustomAimbotVisible    = false
_G.CustomAimbotActive     = false
_G.AimbotDraggable        = true

local aimbotFOV         = 120
local autoFarmEnabled   = false
local selectedPlayerObj = nil
local espData           = {}

-- ─── Helpers ───
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

local function notify(title, desc, duration)
    pcall(function()
        Library:Notification(tostring(title).." — "..tostring(desc), duration or 4, nil)
    end)
end

-- ─── Auto Farm ───
local function tweenToPosition(targetPos)
    if not autoFarmEnabled then return end
    local root = getRootPart(); if not root then return end
    local dist = (targetPos - root.Position).Magnitude
    local t = dist / 25
    root.AssemblyLinearVelocity  = Vector3.new(0, 0, 0)
    root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
    local tw = TweenService:Create(root, TweenInfo.new(t, Enum.EasingStyle.Linear), {CFrame = CFrame.new(targetPos)})
    tw:Play()
    while t > 0 do
        if not autoFarmEnabled then tw:Cancel() return end
        local r = getRootPart(); if not r then tw:Cancel() return end
        r.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        task.wait(0.05); t = t - 0.05
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
                    else obj:Hold(LocalPlayer); task.wait(obj.HoldDuration or 2); obj:Release() end
                end)
                return true
            end
        end
    end
end

local function findToolInInventory(pat)
    if not autoFarmEnabled then return end
    local char = LocalPlayer.Character; if not char then return end
    local hum  = char:FindFirstChildOfClass("Humanoid")
    local bp   = LocalPlayer:FindFirstChildOfClass("Backpack")
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

-- ─── ESP ───
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

        local bb = Instance.new("BillboardGui")
        bb.Name = "ESP_NameTag"; bb.Adornee = head
        bb.Size = UDim2.new(0, 100, 0, 40)
        bb.StudsOffset = Vector3.new(0, 2, 0)
        bb.AlwaysOnTop = true; bb.Parent = head
        local nl = Instance.new("TextLabel", bb)
        nl.BackgroundTransparency = 1; nl.Size = UDim2.new(1, 0, 1, 0)
        nl.Font = Enum.Font.GothamBold; nl.Text = player.DisplayName
        nl.TextColor3 = Color3.fromRGB(0, 255, 255)
        nl.TextSize = 14; nl.TextStrokeTransparency = 0.5

        local hl = Instance.new("Highlight")
        hl.Name = "ESP_Highlight"; hl.Adornee = char
        hl.FillColor = Color3.fromRGB(0, 170, 255)
        hl.FillTransparency = 0.5
        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
        hl.OutlineTransparency = 0; hl.Parent = char

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

for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then addESP(p) end end
Players.PlayerAdded:Connect(function(p)    if p ~= LocalPlayer then addESP(p) end end)
Players.PlayerRemoving:Connect(function(p) removeESP(p) end)

-- ─── Floating GUI: Auto Farm ───
local autoFarmGui = Instance.new("ScreenGui")
autoFarmGui.Name = "DARKHUB_AutoFarmGUI"
autoFarmGui.Parent = CoreGui
autoFarmGui.ResetOnSpawn = false; autoFarmGui.Enabled = false

local AF_F = Instance.new("Frame", autoFarmGui)
AF_F.Size = UDim2.new(0, 200, 0, 90)
AF_F.Position = UDim2.new(0.05, 0, 0.2, 0)
AF_F.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
AF_F.BorderSizePixel = 0; AF_F.Active = true; AF_F.Draggable = true
Instance.new("UICorner", AF_F).CornerRadius = UDim.new(0, 8)

local AF_T = Instance.new("TextLabel", AF_F)
AF_T.BackgroundTransparency = 1; AF_T.Size = UDim2.new(1, 0, 0, 30)
AF_T.Text = "BLANK CARD AUTO-FARM"
AF_T.TextColor3 = Color3.fromRGB(235, 235, 245)
AF_T.TextSize = 12; AF_T.Font = Enum.Font.GothamBold

local farmBtn = Instance.new("TextButton", AF_F)
farmBtn.Size = UDim2.new(0.85, 0, 0, 35)
farmBtn.Position = UDim2.new(0.075, 0, 0.45, 0)
farmBtn.BackgroundColor3 = Color3.fromRGB(34, 34, 46)
farmBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
farmBtn.Text = "Auto Farm: OFF"; farmBtn.TextSize = 12
farmBtn.Font = Enum.Font.GothamBold
farmBtn.BorderSizePixel = 0; farmBtn.AutoButtonColor = false
Instance.new("UICorner", farmBtn).CornerRadius = UDim.new(0, 6)

farmBtn.MouseButton1Click:Connect(function()
    if not autoFarmEnabled then
        autoFarmEnabled = true
        farmBtn.Text = "Auto Farm: ON"
        farmBtn.TextColor3 = Color3.fromRGB(80, 210, 130)
        task.spawn(autoFarmLoop)
    else
        autoFarmEnabled = false
        farmBtn.Text = "Auto Farm: OFF"
        farmBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
end)

-- ─── Floating GUI: Aimbot ───
local aimbotGui = Instance.new("ScreenGui")
aimbotGui.Name = "DARKHUB_AimbotGUI"; aimbotGui.Parent = CoreGui
aimbotGui.ResetOnSpawn = false; aimbotGui.Enabled = false

local fovCircle = Instance.new("Frame", aimbotGui)
fovCircle.BackgroundTransparency = 1
fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
fovCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
fovCircle.Size = UDim2.new(0, aimbotFOV * 2, 0, aimbotFOV * 2)
Instance.new("UICorner", fovCircle).CornerRadius = UDim.new(1, 0)
local fovStroke = Instance.new("UIStroke", fovCircle)
fovStroke.Color = Color3.fromRGB(0, 170, 255); fovStroke.Thickness = 1.5

local aimbotBtn = Instance.new("TextButton", aimbotGui)
aimbotBtn.BackgroundColor3 = Color3.fromRGB(14, 14, 20)
aimbotBtn.BorderColor3 = Color3.fromRGB(0, 170, 255)
aimbotBtn.BorderSizePixel = 2
aimbotBtn.Position = UDim2.new(0, 50, 0, 110)
aimbotBtn.Size = UDim2.new(0, 90, 0, 45)
aimbotBtn.Font = Enum.Font.GothamBold
aimbotBtn.Text = "AIMBOT: OFF"
aimbotBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
aimbotBtn.TextSize = 12; aimbotBtn.AutoButtonColor = false
Instance.new("UICorner", aimbotBtn).CornerRadius = UDim.new(0, 8)

aimbotBtn.MouseButton1Click:Connect(function()
    _G.CustomAimbotActive = not _G.CustomAimbotActive
    if _G.CustomAimbotActive then
        aimbotBtn.Text = "AIMBOT: ON"
        aimbotBtn.TextColor3 = Color3.fromRGB(80, 210, 130)
        fovStroke.Color = Color3.fromRGB(80, 210, 130)
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
        aimDrag = true; aimStart = input.Position; aimPos = aimbotBtn.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then aimDrag = false end
        end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if not _G.AimbotDraggable then return end
    if aimDrag and (input.UserInputType == Enum.UserInputType.Touch
                    or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local d = input.Position - aimStart
        aimbotBtn.Position = UDim2.new(aimPos.X.Scale, aimPos.X.Offset + d.X,
                                       aimPos.Y.Scale, aimPos.Y.Offset + d.Y)
    end
end)

-- ═══════════════════════════════════════════════════════════════
-- BUILD UI
-- ═══════════════════════════════════════════════════════════════
local Window = Library:Window({
    Name = "DARK HUB",
    SubTitle = "Cali Streets",
    ExpiresIn = "∞"
})

-- ─── MAIN ───
Window:Category("MAIN")
local MainPage = Window:Page({ Name = "Main", Icon = "136879043989014" })
local MainSub  = MainPage:SubPage({ Name = "Main", Columns = 2 })

local PlayerSec = MainSub:Section({ Name = "Player Modules", Icon = "136879043989014", Side = 1 })
PlayerSec:Toggle({
    Name = "Infinite Stamina", Flag = "InfiniteStamina", Default = false,
    Callback = function(v) _G.InfiniteStaminaEnabled = v end
})
PlayerSec:Toggle({
    Name = "Auto Pickup Loot", Flag = "AutoLoot", Default = false,
    Callback = function(v)
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
    end
})
PlayerSec:Toggle({
    Name = "Instant Interact", Flag = "InstantInteract", Default = false,
    Callback = function(v) _G.InstantInteractEnabled = v end
})

local MoveSec = MainSub:Section({ Name = "Movement & Physics", Icon = "136879043989014", Side = 2 })
MoveSec:Toggle({
    Name = "No Jump Cooldown", Flag = "NoJumpCooldown", Default = false,
    Callback = function(v) _G.NoJumpCooldownEnabled = v end
})
MoveSec:Toggle({
    Name = "Noclip", Flag = "Noclip", Default = false,
    Callback = function(v) _G.NoclipEnabled = v end
})
MoveSec:Toggle({
    Name = "Safe Speed Boost", Flag = "WalkSpeedEnabled", Default = false,
    Callback = function(v) _G.WalkSpeedEnabled = v end
})
MoveSec:Slider({
    Name = "Speed Multiplier", Flag = "WalkSpeedMultiplier",
    Min = 1, Max = 3, Default = 1.25,
    Decimals = 2, Suffix = "x",
    Callback = function(v) _G.WalkSpeedMultiplier = v end
})
MoveSec:Button({
    Name = "FPS Booster (Potato Graphics)",
    Callback = function()
        if _G.FPSBoostUsed then
            notify("FPS Booster", "Sudah diterapkan.", 3); return
        end
        _G.FPSBoostUsed = true
        pcall(function()
            local l = game:GetService("Lighting")
            l.GlobalShadows = false; l.FogEnd = 999999
            for _, o in ipairs(l:GetChildren()) do
                if o:IsA("PostEffect") or o:IsA("Atmosphere") or o:IsA("Sky")
                   or o:IsA("Clouds") or o:IsA("BlurEffect") then o:Destroy() end
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
        notify("FPS Booster", "Graphics telah di-strip.", 4)
    end
})

-- ─── AUTO FARM ───
Window:Category("AUTO FARM")
local FarmPage = Window:Page({ Name = "Auto Farm", Icon = "136879043989014" })
local FarmSub  = FarmPage:SubPage({ Name = "Farm", Columns = 2 })

local FarmL = FarmSub:Section({ Name = "Blank Card Auto Farm", Icon = "136879043989014", Side = 1 })
FarmL:Label("Klik tombol di bawah untuk start/stop auto farm.")
FarmL:Button({
    Name = "Toggle Auto Farm (Start / Stop)",
    Callback = function()
        if not autoFarmEnabled then
            autoFarmEnabled = true
            farmBtn.Text = "Auto Farm: ON"
            farmBtn.TextColor3 = Color3.fromRGB(80, 210, 130)
            task.spawn(autoFarmLoop)
            notify("Auto Farm", "Auto Farm diaktifkan.", 3)
        else
            autoFarmEnabled = false
            farmBtn.Text = "Auto Farm: OFF"
            farmBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
            notify("Auto Farm", "Auto Farm dimatikan.", 3)
        end
    end
})

local FarmR = FarmSub:Section({ Name = "Floating UI", Icon = "136879043989014", Side = 2 })
FarmR:Toggle({
    Name = "Spawn Auto Farm UI", Flag = "SpawnAutoFarmUI", Default = false,
    Callback = function(v)
        autoFarmGui.Enabled = v
        if not v then
            autoFarmEnabled = false
            farmBtn.Text = "Auto Farm: OFF"
            farmBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
    end
})
FarmR:Toggle({
    Name = "Freeze Auto Farm UI", Flag = "FreezeAutoFarmUI", Default = false,
    Callback = function(v) AF_F.Draggable = not v end
})

-- ─── COMBAT ───
Window:Category("COMBAT")
local CombatPage = Window:Page({ Name = "Combat", Icon = "136879043989014" })
local CombatSub  = CombatPage:SubPage({ Name = "Combat", Columns = 2 })

local CombatL = CombatSub:Section({ Name = "Aimbot Settings", Icon = "136879043989014", Side = 1 })
CombatL:Toggle({
    Name = "Spawn Aimbot UI", Flag = "SpawnAimbotUI", Default = false,
    Callback = function(v)
        _G.CustomAimbotVisible = v
        aimbotGui.Enabled = v
        if not v then
            _G.CustomAimbotActive = false
            aimbotBtn.Text = "AIMBOT: OFF"
            aimbotBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            fovStroke.Color = Color3.fromRGB(0, 170, 255)
        end
    end
})
CombatL:Slider({
    Name = "Aimbot FOV Circle", Flag = "AimbotFOV",
    Min = 40, Max = 300, Default = 120, Decimals = 0,
    Callback = function(v)
        aimbotFOV = v
        fovCircle.Size = UDim2.new(0, aimbotFOV * 2, 0, aimbotFOV * 2)
    end
})

local CombatR = CombatSub:Section({ Name = "Floating UI Control", Icon = "136879043989014", Side = 2 })
CombatR:Toggle({
    Name = "Freeze Aimbot UI", Flag = "FreezeAimbotUI", Default = false,
    Callback = function(v) _G.AimbotDraggable = not v end
})

-- ─── VISUALS ───
Window:Category("VISUALS")
local VisPage = Window:Page({ Name = "Visuals", Icon = "136879043989014" })
local VisSub  = VisPage:SubPage({ Name = "Visuals", Columns = 2 })

local VisL = VisSub:Section({ Name = "Visual Modules", Icon = "136879043989014", Side = 1 })
VisL:Toggle({
    Name = "Max Zoom Out", Flag = "MaxZoomOut", Default = false,
    Callback = function(v)
        _G.InfiniteZoomEnabled = v
        if not v then LocalPlayer.CameraMaxZoomDistance = 128 end
    end
})
VisL:Toggle({
    Name = "Player ESP", Flag = "PlayerESP", Default = false,
    Callback = function(v) _G.ESPEnabled = v end
})

local VisR = VisSub:Section({ Name = "Player Info", Icon = "136879043989014", Side = 2 })
VisR:Label("Pilih player target lalu klik Inspect.")

local function buildPlayerList()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(list, p.DisplayName) end
    end
    if #list == 0 then table.insert(list, "None") end
    return list
end

local PlayerDropdown
PlayerDropdown = VisR:Dropdown({
    Name = "Target Player", Flag = "TargetPlayer",
    Items = buildPlayerList(), Multi = false,
    Callback = function(value)
        for _, p in ipairs(Players:GetPlayers()) do
            if p.DisplayName == value or p.Name == value then
                selectedPlayerObj = p; break
            end
        end
    end
})

VisR:Button({
    Name = "Refresh Player List",
    Callback = function()
        if PlayerDropdown and PlayerDropdown.Refresh then
            PlayerDropdown:Refresh(buildPlayerList())
        end
    end
})

VisR:Button({
    Name = "Inspect Inventory",
    Callback = function()
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
    end
})

-- ─── SOCIALS ───
Window:Category("SOCIALS")
local SocPage = Window:Page({ Name = "Socials", Icon = "136879043989014" })
local SocSub  = SocPage:SubPage({ Name = "Socials", Columns = 1 })

local SocSec = SocSub:Section({ Name = "Social Links", Icon = "136879043989014", Side = 1 })
SocSec:Button({
    Name = "Copy Discord Link",
    Callback = function()
        if setclipboard then setclipboard("https://discord.gg/xKvegCV6yf") end
        notify("Discord", "Invite copied to clipboard.", 3)
    end
})
SocSec:Button({
    Name = "Copy YouTube Link",
    Callback = function()
        if setclipboard then setclipboard("https://youtube.com/@strixwashere") end
        notify("YouTube", "Link copied to clipboard.", 3)
    end
})

-- ─── SETTINGS (auto) ───
Library:CreateSettingsPage(Window)

-- ═══════════════════════════════════════════════════════════════
-- GAME LOOPS
-- ═══════════════════════════════════════════════════════════════
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
        local mult = (Library.Flags and Library.Flags.WalkSpeedMultiplier) or _G.WalkSpeedMultiplier or 1.25
        rp.CFrame = rp.CFrame + hum.MoveDirection * (mult - 1) * 0.5
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

-- ═══════════════════════════════════════════════════════════════
notify("DARK HUB Loaded", "All features ready.", 5)

getgenv().Library = Library
return Library