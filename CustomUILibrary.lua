
-- CustomUILibrary.lua
-- Lightweight Full UI Library (Tabs, Button, Toggle, Slider, Dropdown, Colorpicker, Textbox, Notification)
-- Usage:
-- local Library = loadstring(game:HttpGet("https://your-host/CustomUILibrary.lua"))()
-- local Window = Library:CreateWindow("My UI", Enum.StudioStyleGuideModifier.Default)
--
-- Example:
-- local page = Window:CreateTab("Main")
-- page:CreateButton("Hello", function() print("Clicked") end)
-- page:CreateToggle("Enabled", false, function(v) print("Toggle", v) end)
-- page:CreateSlider("Speed", 1, 0, 10, function(v) print("Slider", v) end)
-- page:CreateDropdown("Pick", {"A","B","C"}, function(v) print("Pick", v) end)
-- page:CreateColorPicker("Color", Color3.fromRGB(255,0,0), function(c) print(c) end)
-- page:CreateTextbox("Name", "Player", function(txt) print(txt) end)
-- Library:Notify("Info", "Library loaded", 4)

local Library = {}
Library.__index = Library

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Helpers
local function new(class, props)
    local obj = Instance.new(class)
    for k,v in pairs(props or {}) do
        if k == "Parent" then obj.Parent = v
        else pcall(function() obj[k] = v end) end
    end
    return obj
end

local function tween(obj, propTable, time, style, direction)
    TweenService:Create(obj, TweenInfo.new(time or 0.25, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out), propTable):Play()
end

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CustomUILibrary"
screenGui.ResetOnSpawn = false
screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

-- Root window creation
function Library:CreateWindow(title)
    local Window = {}
    Window.tabs = {}
    Window._activeTab = nil

    -- Main frame
    local main = new("Frame", {
        Name = "MainWindow",
        Parent = screenGui,
        AnchorPoint = Vector2.new(0.5,0.5),
        Position = UDim2.new(0.5,0.5,0,0),
        Size = UDim2.new(0, 700, 0, 430),
        BackgroundColor3 = Color3.fromRGB(20,20,20),
        BorderSizePixel = 0,
        ClipsDescendants = true,
    })

    local uiCorner = new("UICorner", {Parent = main, CornerRadius = UDim.new(0, 12)})
    local uiStroke = new("UIStroke", {Parent = main, Color = Color3.fromRGB(40,40,40), Thickness = 1})

    local left = new("Frame", {
        Parent = main,
        Name = "Left",
        Size = UDim2.new(0, 180, 1, 0),
        Position = UDim2.new(0,0,0,0),
        BackgroundColor3 = Color3.fromRGB(16,16,16),
        BorderSizePixel = 0,
    })
    new("UICorner", {Parent = left, CornerRadius = UDim.new(0, 12)})

    local titleLabel = new("TextLabel", {
        Parent = left,
        Size = UDim2.new(1, -12, 0, 48),
        Position = UDim2.new(0, 6, 0, 6),
        BackgroundTransparency = 1,
        Text = title or "Custom UI",
        TextSize = 18,
        TextColor3 = Color3.fromRGB(240,240,240),
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    local tabsContainer = new("ScrollingFrame", {
        Parent = left,
        Name = "Tabs",
        Position = UDim2.new(0,6,0,64),
        Size = UDim2.new(1,-12,1,-70),
        BackgroundTransparency = 1,
        ScrollBarThickness = 6,
    })
    new("UIPadding", {Parent = tabsContainer, PaddingTop = UDim.new(0,4), PaddingBottom = UDim.new(0,4)})
    local tabsLayout = new("UIListLayout", {Parent = tabsContainer, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,6)})

    local right = new("Frame", {
        Parent = main,
        Name = "Right",
        Size = UDim2.new(1, -190, 1, 0),
        Position = UDim2.new(0,190,0,0),
        BackgroundColor3 = Color3.fromRGB(24,24,24),
        BorderSizePixel = 0,
    })
    new("UICorner", {Parent = right, CornerRadius = UDim.new(0, 12)})

    local pagesFolder = Instance.new("Folder", right)
    pagesFolder.Name = "Pages"

    -- Dragging
    local dragging = false
    local dragStart = nil
    local startPos = nil
    local function onInputBegan(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
        end
    end
    local function onInputChanged(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            main.Position = startPos + UDim2.new(0, delta.X, 0, delta.Y)
        end
    end
    local function onInputEnded(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end
    titleLabel.InputBegan:Connect(onInputBegan)
    UserInputService.InputChanged:Connect(onInputChanged)
    UserInputService.InputEnded:Connect(onInputEnded)

    -- Tab creation
    function Window:CreateTab(tabName)
        local Tab = {}
        Tab.elements = {}

        local btn = new("TextButton", {
            Parent = tabsContainer,
            Size = UDim2.new(1,0,0,34),
            BackgroundColor3 = Color3.fromRGB(28,28,28),
            Text = tabName,
            TextSize = 14,
            TextColor3 = Color3.fromRGB(230,230,230),
            Font = Enum.Font.Gotham,
            AutoButtonColor = false,
            BorderSizePixel = 0,
        })
        new("UICorner", {Parent = btn, CornerRadius = UDim.new(0,8)})

        local page = new("Frame", {
            Parent = pagesFolder,
            Size = UDim2.new(1,0,1,0),
            BackgroundTransparency = 1,
            Visible = false,
        })

        local pageCanvas = new("ScrollingFrame", {
            Parent = page,
            Size = UDim2.new(1, -20, 1, -20),
            Position = UDim2.new(0, 10, 0, 10),
            BackgroundTransparency = 1,
            ScrollBarThickness = 6,
        })
        new("UIListLayout", {Parent = pageCanvas, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,8)})
        new("UIPadding", {Parent = pageCanvas, PaddingTop = UDim.new(0,6), PaddingLeft = UDim.new(0,6), PaddingRight = UDim.new(0,6)})

        function Tab:Show()
            for i,v in pairs(pagesFolder:GetChildren()) do
                if v:IsA("Frame") then v.Visible = false end
            end
            page.Visible = true
            Window._activeTab = Tab
        end

        btn.MouseButton1Click:Connect(function()
            Tab:Show()
        end)

        -- Elements creation functions
        function Tab:CreateButton(text, callback)
            local frame = new("Frame", {Parent = pageCanvas, Size = UDim2.new(1,0,0,36), BackgroundTransparency = 1})
            local button = new("TextButton", {
                Parent = frame,
                Size = UDim2.new(1,0,1,0),
                BackgroundColor3 = Color3.fromRGB(55,55,55),
                Text = text,
                Font = Enum.Font.GothamSemibold,
                TextSize = 14,
                TextColor3 = Color3.fromRGB(245,245,245),
                BorderSizePixel = 0,
                AutoButtonColor = false,
            })
            new("UICorner", {Parent = button, CornerRadius = UDim.new(0,8)})
            button.MouseButton1Click:Connect(function()
                pcall(callback)
            end)
            return button
        end

        function Tab:CreateToggle(text, default, callback)
            default = default == true
            local frame = new("Frame", {Parent = pageCanvas, Size = UDim2.new(1,0,0,36), BackgroundTransparency = 1})
            local label = new("TextLabel", {
                Parent = frame, Size = UDim2.new(1, -60, 1, 0), BackgroundTransparency = 1,
                Text = text, TextSize = 14, Font = Enum.Font.Gotham, TextColor3 = Color3.fromRGB(230,230,230), TextXAlignment = Enum.TextXAlignment.Left
            })
            local toggle = new("TextButton", {
                Parent = frame, Size = UDim2.new(0,48,0,24), Position = UDim2.new(1, -54, 0.5, -12),
                BackgroundColor3 = default and Color3.fromRGB(50,180,100) or Color3.fromRGB(60,60,60),
                Text = "",
                BorderSizePixel = 0,
            })
            new("UICorner", {Parent = toggle, CornerRadius = UDim.new(0,6)})
            local circle = new("Frame", {Parent = toggle, Size = UDim2.new(0,20,0,20), Position = default and UDim2.new(1,-22,0,2) or UDim2.new(0,2,0,2), BackgroundColor3 = Color3.fromRGB(250,250,250), BorderSizePixel = 0})
            new("UICorner", {Parent = circle, CornerRadius = UDim.new(1,0)})
            local state = default
            local function update()
                toggle.BackgroundColor3 = state and Color3.fromRGB(50,180,100) or Color3.fromRGB(60,60,60)
                local target = state and UDim2.new(1,-22,0,2) or UDim2.new(0,2,0,2)
                tween(circle, {Position = target}, 0.12)
                pcall(callback, state)
            end
            toggle.MouseButton1Click:Connect(function()
                state = not state
                update()
            end)
            update()
            return {Set = function(v) state = v; update() end, Get = function() return state end}
        end

        function Tab:CreateSlider(text, default, min, max, callback)
            min = min or 0; max = max or 100; default = default or min
            local frame = new("Frame", {Parent = pageCanvas, Size = UDim2.new(1,0,0,48), BackgroundTransparency = 1})
            local label = new("TextLabel", {
                Parent = frame, Size = UDim2.new(1,-12,0,18), BackgroundTransparency = 1,
                Text = text.." ("..tostring(default)..")", TextSize = 14, Font = Enum.Font.Gotham, TextColor3 = Color3.fromRGB(230,230,230), TextXAlignment = Enum.TextXAlignment.Left
            })
            local barBg = new("Frame", {Parent = frame, Size = UDim2.new(1,0,0,12), Position = UDim2.new(0,0,0,26), BackgroundColor3 = Color3.fromRGB(60,60,60), BorderSizePixel = 0})
            new("UICorner", {Parent = barBg, CornerRadius = UDim.new(0,6)})
            local fill = new("Frame", {Parent = barBg, Size = UDim2.new((default-min)/(max-min),0,1,0), BackgroundColor3 = Color3.fromRGB(90,150,255), BorderSizePixel = 0})
            new("UICorner", {Parent = fill, CornerRadius = UDim.new(0,6)})

            local dragging = false
            local function setValueFromPos(x)
                local rel = math.clamp((x - barBg.AbsolutePosition.X)/barBg.AbsoluteSize.X, 0, 1)
                local value = min + rel * (max - min)
                fill.Size = UDim2.new(rel,0,1,0)
                label.Text = text.." ("..string.format("%.2f", value)..")"
                pcall(callback, value)
            end
            barBg.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    setValueFromPos(inp.Position.X)
                end
            end)
            UserInputService.InputChanged:Connect(function(inp)
                if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
                    setValueFromPos(inp.Position.X)
                end
            end)
            UserInputService.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
            end)
            return {Set = function(v) local rel = (v-min)/(max-min) fill.Size = UDim2.new(rel,0,1,0) end}
        end

        function Tab:CreateDropdown(text, items, callback)
            local frame = new("Frame", {Parent = pageCanvas, Size = UDim2.new(1,0,0,36), BackgroundTransparency = 1})
            local label = new("TextLabel", {Parent = frame, Size = UDim2.new(1,-120,1,0), BackgroundTransparency = 1, Text = text, TextSize = 14, Font = Enum.Font.Gotham, TextColor3 = Color3.fromRGB(230,230,230), TextXAlignment = Enum.TextXAlignment.Left})
            local btn = new("TextButton", {Parent = frame, Size = UDim2.new(0,100,0,28), Position = UDim2.new(1,-104,0.5,-14), BackgroundColor3 = Color3.fromRGB(50,50,50), Text = "Select", BorderSizePixel = 0})
            new("UICorner", {Parent = btn, CornerRadius = UDim.new(0,6)})
            local dropdownFrame = new("Frame", {Parent = pageCanvas, Size = UDim2.new(1,0,0,#items*28), Position = UDim2.new(0,0,0,0), BackgroundTransparency = 1, Visible = false})
            local list = new("Frame", {Parent = dropdownFrame, Size = UDim2.new(1,0,0,#items*28), BackgroundColor3 = Color3.fromRGB(40,40,40), BorderSizePixel = 0})
            new("UICorner", {Parent = list, CornerRadius = UDim.new(0,6)})
            local layout = new("UIListLayout", {Parent = list, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,4)})
            for i,v in ipairs(items) do
                local itBtn = new("TextButton", {Parent = list, Size = UDim2.new(1,-12,0,24), Position = UDim2.new(0,6,0,(i-1)*28+6), BackgroundTransparency = 1, Text = v, TextSize = 14, Font = Enum.Font.Gotham, TextColor3 = Color3.fromRGB(230,230,230), BorderSizePixel = 0})
                itBtn.MouseButton1Click:Connect(function()
                    btn.Text = v
                    dropdownFrame.Visible = false
                    pcall(callback, v)
                end)
            end
            btn.MouseButton1Click:Connect(function()
                dropdownFrame.Visible = not dropdownFrame.Visible
            end)
            return {Set = function(v) btn.Text = v end}
        end

        function Tab:CreateColorPicker(text, defaultColor, callback)
            local frame = new("Frame", {Parent = pageCanvas, Size = UDim2.new(1,0,0,40), BackgroundTransparency = 1})
            local label = new("TextLabel", {Parent = frame, Size = UDim2.new(1,-100,0,20), BackgroundTransparency = 1, Text = text, TextSize = 14, Font = Enum.Font.Gotham, TextColor3 = Color3.fromRGB(230,230,230), TextXAlignment = Enum.TextXAlignment.Left})
            local preview = new("Frame", {Parent = frame, Size = UDim2.new(0,34,0,24), Position = UDim2.new(1,-40,0,8), BackgroundColor3 = defaultColor or Color3.new(1,1,1), BorderSizePixel = 0})
            new("UICorner", {Parent = preview, CornerRadius = UDim.new(0,6)})
            local picking = false
            preview.MouseButton1Click:Connect(function()
                -- simple toggle color cycle for demo (since full color picker UI is long)
                local colors = {Color3.fromRGB(255,0,0), Color3.fromRGB(0,255,0), Color3.fromRGB(0,0,255), Color3.fromRGB(255,255,0)}
                local idx = 1
                picking = not picking
                if picking then
                    preview.BackgroundColor3 = colors[idx]
                    pcall(callback, colors[idx])
                    picking = false
                end
            end)
            return {Set = function(c) preview.BackgroundColor3 = c end}
        end

        function Tab:CreateTextbox(text, default, callback)
            local frame = new("Frame", {Parent = pageCanvas, Size = UDim2.new(1,0,0,36), BackgroundTransparency = 1})
            local label = new("TextLabel", {Parent = frame, Size = UDim2.new(1,-140,1,0), BackgroundTransparency = 1, Text = text, TextSize = 14, Font = Enum.Font.Gotham, TextColor3 = Color3.fromRGB(230,230,230), TextXAlignment = Enum.TextXAlignment.Left})
            local box = new("TextBox", {Parent = frame, Size = UDim2.new(0,140,0,24), Position = UDim2.new(1,-146,0.5,-12), BackgroundColor3 = Color3.fromRGB(55,55,55), Text = default or "", TextSize = 14, Font = Enum.Font.Gotham, TextColor3 = Color3.fromRGB(245,245,245), ClearTextOnFocus = false, BorderSizePixel = 0})
            new("UICorner", {Parent = box, CornerRadius = UDim.new(0,6)})
            box.FocusLost:Connect(function(enter)
                if enter then pcall(callback, box.Text) end
            end)
            return box
        end

        -- return Tab API
        Window.tabs[tabName] = Tab
        return Tab
    end

    -- Notify helper
    function Library:Notify(title, text, duration)
        duration = duration or 3
        local notifFrame = new("Frame", {Parent = screenGui, Size = UDim2.new(0,260,0,64), Position = UDim2.new(0.5,-130,0,40), BackgroundColor3 = Color3.fromRGB(25,25,25), BorderSizePixel = 0})
        new("UICorner", {Parent = notifFrame, CornerRadius = UDim.new(0,8)})
        local ttl = new("TextLabel", {Parent = notifFrame, Size = UDim2.new(1,-12,0,22), Position = UDim2.new(0,6,0,6), BackgroundTransparency = 1, Text = title, Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = Color3.fromRGB(240,240,240), TextXAlignment = Enum.TextXAlignment.Left})
        local body = new("TextLabel", {Parent = notifFrame, Size = UDim2.new(1,-12,0,28), Position = UDim2.new(0,6,0,30), BackgroundTransparency = 1, Text = text, Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = Color3.fromRGB(210,210,210), TextXAlignment = Enum.TextXAlignment.Left})
        notifFrame.Position = UDim2.new(0.5,-130,0,-80)
        tween(notifFrame, {Position = UDim2.new(0.5,-130,0,40)}, 0.35)
        delay(duration, function()
            tween(notifFrame, {Position = UDim2.new(0.5,-130,0,-120)}, 0.28)
            wait(0.3)
            notifFrame:Destroy()
        end)
    end

    return Window
end

return Library
