-- FunUI_Library.lua
-- A lightweight Roblox UI Library inspired by Rayfield, Linoria, Orion, Kavo
-- Features: Window, Tabs, Sections, Buttons, Toggles, Sliders, Dropdowns, Textboxes,
-- Theme support (Dark/Light/Custom), Notification system, Save/Load config, Open/Close animation, Keybind toggle
-- Works in exploit environments that support Instance creation and writefile/readfile (pcall used)

local FunUI = {}
FunUI.__index = FunUI

-- Services
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

-- Helpers
local function new(class, props)
    local obj = Instance.new(class)
    if props then
        for k,v in pairs(props) do
            if k == "Parent" then
                obj.Parent = v
            else
                obj[k] = v
            end
        end
    end
    return obj
end

local function safeCall(fn, ...)
    local ok, res = pcall(fn, ...)
    return ok, res
end

-- Defaults
local DEFAULT_THEME = {
    Name = "Dark",
    Accent = Color3.fromRGB(0, 170, 255),
    Background = Color3.fromRGB(20, 20, 20),
    Window = Color3.fromRGB(15, 15, 15),
    Section = Color3.fromRGB(25, 25, 25),
    Text = Color3.fromRGB(230, 230, 230),
    Placeholder = Color3.fromRGB(130, 130, 130),
}

-- Utility: Save/Load using writefile/readfile if available
local function canWrite()
    return type(writefile) == "function" and type(readfile) == "function"
end

local function saveConfig(name, tbl)
    if not canWrite() then return false, "writefile/readfile unavailable" end
    local ok, err = pcall(function()
        writefile(name, HttpService:JSONEncode(tbl))
    end)
    if not ok then return false, err end
    return true
end

local function loadConfig(name)
    if not canWrite() then return nil end
    local ok, data = pcall(function()
        if not isfile(name) then return nil end
        local content = readfile(name)
        return HttpService:JSONDecode(content)
    end)
    if ok then return data end
    return nil
end

-- Base UI creation
function FunUI.new(opts)
    opts = opts or {}
    local self = setmetatable({}, FunUI)

    self.Name = opts.Name or "FunUI"
    self.Theme = opts.Theme or DEFAULT_THEME
    self.ConfigName = (opts.ConfigName or (self.Name.."_config.json"))
    self.BindKey = opts.ToggleKey or Enum.KeyCode.RightShift
    self.IsOpen = true
    self.Tabs = {}

    -- root
    self.Root = new("ScreenGui", {Parent = CoreGui, ResetOnSpawn = false, Name = self.Name})

    -- main window
    self.Window = new("Frame", {
        Parent = self.Root,
        Name = "Window",
        Size = UDim2.new(0, 760, 0, 420),
        Position = UDim2.new(0.5, -380, 0.5, -210),
        AnchorPoint = Vector2.new(0.5,0.5),
        BackgroundColor3 = self.Theme.Window,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    })

    new("UICorner", {Parent = self.Window, CornerRadius = UDim.new(0, 10)})

    -- header
    self.Header = new("Frame", {Parent = self.Window, Name = "Header", Size = UDim2.new(1,0,0,48), BackgroundTransparency = 1})
    self.Title = new("TextLabel", {Parent = self.Header, Text = self.Name, Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, TextColor3 = self.Theme.Text, Font = Enum.Font.GothamBold, TextSize = 20, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Center, Position = UDim2.new(0,12,0,0)})

    -- content area: left sidebar + right content
    self.Sidebar = new("Frame", {Parent = self.Window, Name = "Sidebar", Position = UDim2.new(0,0,0,48), Size = UDim2.new(0,200,1,-48), BackgroundColor3 = self.Theme.Section, BorderSizePixel = 0})
    new("UICorner", {Parent = self.Sidebar, CornerRadius = UDim.new(0,10)})
    
    self.Content = new("Frame", {Parent = self.Window, Name = "Content", Position = UDim2.new(0,200,0,48), Size = UDim2.new(1,-200,1,-48), BackgroundColor3 = self.Theme.Background, BorderSizePixel = 0})
    new("UICorner", {Parent = self.Content, CornerRadius = UDim.new(0,10)})

    -- tab list
    self.TabList = new("ScrollingFrame", {Parent = self.Sidebar, Name = "TabList", BackgroundTransparency = 1, Size = UDim2.new(1,0,1,0), CanvasSize = UDim2.new(0,0,0,0), ScrollBarThickness = 4})
    self.TabListLayout = new("UIListLayout", {Parent = self.TabList, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,6)})
    self.TabListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        self.TabList.CanvasSize = UDim2.new(0,0,0,self.TabListLayout.AbsoluteContentSize.Y + 12)
    end)

    -- content pages container
    self.Pages = new("Frame", {Parent = self.Content, Name = "Pages", Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1})

    -- notification holder
    self.NotifyHolder = new("Frame", {Parent = self.Root, Name = "NotifyHolder", Size = UDim2.new(0,300,0,200), Position = UDim2.new(1,-310,0,20), BackgroundTransparency = 1})

    -- default animations (open)
    self:Open(true)

    -- keybind to toggle
    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == self.BindKey then
            self:Toggle()
        end
    end)

    -- attempt to load config
    local conf = loadConfig(self.ConfigName)
    if conf and type(conf) == "table" and conf.Theme then
        self.Theme = conf.Theme
        self:ApplyTheme(self.Theme)
    end

    return self
end

function FunUI:ApplyTheme(theme)
    if not theme then return end
    self.Theme = theme
    -- apply to elements
    self.Window.BackgroundColor3 = theme.Window or self.Theme.Window
    self.Sidebar.BackgroundColor3 = theme.Section or self.Theme.Section
    self.Content.BackgroundColor3 = theme.Background or self.Theme.Background
    self.Title.TextColor3 = theme.Text or self.Theme.Text
    -- update existing controls (they will read theme on creation normally)
end

function FunUI:Toggle()
    if self.IsOpen then
        self:Close()
    else
        self:Open()
    end
end

function FunUI:Open(skipTween)
    self.IsOpen = true
    local goal = {Size = self.Window.Size, Position = self.Window.Position, AnchorPoint = self.Window.AnchorPoint}
    if not skipTween then
        self.Window.Visible = true
        self.Window.ClipsDescendants = true
        local s = TweenService:Create(self.Window, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, -380, 0.5, -210), Size = UDim2.new(0,760,0,420)})
        s:Play()
    else
        self.Window.Visible = true
    end
end

function FunUI:Close()
    self.IsOpen = false
    local s = TweenService:Create(self.Window, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(0.5, -380, 0.5, -260), Size = UDim2.new(0,760,0,420)})
    s:Play()
    delay(0.18, function()
        if self and self.Window then
            self.Window.Visible = false
        end
    end)
end

-- Notifications
function FunUI:Notify(opts)
    opts = opts or {}
    local title = opts.Title or "Notification"
    local text = opts.Text or "Hello"
    local duration = opts.Duration or 4

    local card = new("Frame", {Parent = self.NotifyHolder, Size = UDim2.new(1,0,0,70), AnchorPoint = Vector2.new(1,0), BackgroundColor3 = self.Theme.Section, BorderSizePixel = 0})
    new("UICorner", {Parent = card, CornerRadius = UDim.new(0,8)})
    local t = new("TextLabel", {Parent = card, Text = title, Size = UDim2.new(1,-12,0,24), BackgroundTransparency = 1, Position = UDim2.new(0,8,0,8), TextXAlignment = Enum.TextXAlignment.Left, Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = self.Theme.Text})
    local b = new("TextLabel", {Parent = card, Text = text, Size = UDim2.new(1,-12,0,30), BackgroundTransparency = 1, Position = UDim2.new(0,8,0,30), TextXAlignment = Enum.TextXAlignment.Left, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = self.Theme.Text})

    -- slide in
    card.Position = UDim2.new(1, 320, 0, 0)
    local inTween = TweenService:Create(card, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(1,-310,0, #self.NotifyHolder:GetChildren()*76)})
    inTween:Play()

    delay(duration, function()
        local out = TweenService:Create(card, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(1,320,0,0), BackgroundTransparency = 1})
        out:Play()
        out.Completed:Wait()
        pcall(function() card:Destroy() end)
    end)
end

-- Tabs & Sections
function FunUI:CreateTab(name)
    local tabBtn = new("TextButton", {Parent = self.TabList, Text = "   "..name, Size = UDim2.new(1, -12, 0, 36), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = self.Theme.Text, Font = Enum.Font.GothamBold, TextSize = 14, AutoButtonColor = false})
    local uic = new("UICorner", {Parent = tabBtn, CornerRadius = UDim.new(0,6)})
    local page = new("Frame", {Parent = self.Pages, Name = name, Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Visible = false})

    local sections = {}

    tabBtn.MouseButton1Click:Connect(function()
        for i,v in pairs(self.Pages:GetChildren()) do
            if v:IsA("Frame") then v.Visible = false end
        end
        page.Visible = true
        -- highlight
        for _,b in pairs(self.TabList:GetChildren()) do
            if b:IsA("TextButton") then
                b.BackgroundTransparency = 1
            end
        end
        tabBtn.BackgroundTransparency = 0.85
    end)

    table.insert(self.Tabs, {Name = name, Button = tabBtn, Page = page, Sections = sections})
    -- if first tab, activate
    if #self.Tabs == 1 then
        tabBtn.MouseButton1Click:Fire()
    end

    local function AddSection(title)
        local sectionFrame = new("Frame", {Parent = page, Size = UDim2.new(1, -24, 0, 140), Position = UDim2.new(0, 12, 0, (#sections)*148 + 12), BackgroundColor3 = self.Theme.Section, BorderSizePixel = 0})
        new("UICorner", {Parent = sectionFrame, CornerRadius = UDim.new(0,8)})
        local label = new("TextLabel", {Parent = sectionFrame, Text = title, Size = UDim2.new(1, -12, 0, 28), Position = UDim2.new(0, 6, 0, 6), BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = self.Theme.Text, TextXAlignment = Enum.TextXAlignment.Left})
        local content = new("Frame", {Parent = sectionFrame, Size = UDim2.new(1, -12, 1, -40), Position = UDim2.new(0,6,0,36), BackgroundTransparency = 1})
        local layout = new("UIListLayout", {Parent = content, Padding = UDim.new(0,6), SortOrder = Enum.SortOrder.LayoutOrder})
        table.insert(sections, {Title = title, Frame = sectionFrame, Content = content, Layout = layout})
        -- update page canvas (simple) - increase page size if needed
        page.Size = UDim2.new(1,0,0, math.max(420, (#sections)*148 + 24))

        local function AddButton(opts)
            opts = opts or {}
            local btn = new("TextButton", {Parent = content, Text = opts.Text or "Button", Size = UDim2.new(1,0,0,36), BackgroundColor3 = self.Theme.Window, TextColor3 = self.Theme.Text, Font = Enum.Font.GothamBold, TextSize = 14, AutoButtonColor = false})
            new("UICorner", {Parent = btn, CornerRadius = UDim.new(0,6)})
            btn.MouseButton1Click:Connect(function()
                safeCall(opts.Callback or function() end)
            end)
            return btn
        end

        local function AddToggle(opts)
            opts = opts or {}
            local holder = new("Frame", {Parent = content, Size = UDim2.new(1,0,0,36), BackgroundTransparency = 1})
            local lab = new("TextLabel", {Parent = holder, Text = opts.Text or "Toggle", Size = UDim2.new(0.8,0,1,0), BackgroundTransparency = 1, TextColor3 = self.Theme.Text, Font = Enum.Font.Gotham, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left})
            local box = new("TextButton", {Parent = holder, Size = UDim2.new(0,46,0,24), Position = UDim2.new(1, -52, 0, 6), BackgroundColor3 = self.Theme.Window, AutoButtonColor = false, Text = ""})
            new("UICorner", {Parent = box, CornerRadius = UDim.new(0,6)})
            local circle = new("Frame", {Parent = box, Size = UDim2.new(0,20,0,20), Position = UDim2.new(0,2,0,2), BackgroundColor3 = Color3.fromRGB(240,240,240)})
            new("UICorner", {Parent = circle, CornerRadius = UDim.new(1,0)})
            local state = opts.Default or false
            local function refresh()
                if state then
                    TweenService:Create(circle, TweenInfo.new(0.12), {Position = UDim2.new(1, -22, 0, 2), BackgroundColor3 = self.Theme.Accent}):Play()
                else
                    TweenService:Create(circle, TweenInfo.new(0.12), {Position = UDim2.new(0,2,0,2), BackgroundColor3 = Color3.fromRGB(240,240,240)}):Play()
                end
            end
            box.MouseButton1Click:Connect(function()
                state = not state
                safeCall(opts.Callback or function() end, state)
                refresh()
            end)
            refresh()
            return {Get = function() return state end, Set = function(v) state = v; refresh() end}
        end

        local function AddSlider(opts)
            opts = opts or {}
            local min = opts.Min or 0
            local max = opts.Max or 100
            local default = opts.Default or min
            local holder = new("Frame", {Parent = content, Size = UDim2.new(1,0,0,44), BackgroundTransparency = 1})
            local lab = new("TextLabel", {Parent = holder, Text = (opts.Text or "Slider").. " — "..tostring(default), Size = UDim2.new(1,0,0,18), BackgroundTransparency = 1, Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = self.Theme.Text, TextXAlignment = Enum.TextXAlignment.Left})
            local barBack = new("Frame", {Parent = holder, Position = UDim2.new(0,0,0,22), Size = UDim2.new(1,0,0,12), BackgroundColor3 = self.Theme.Window, BorderSizePixel = 0})
            new("UICorner", {Parent = barBack, CornerRadius = UDim.new(0,8)})
            local fill = new("Frame", {Parent = barBack, Size = UDim2.new((default-min)/(max-min),0,1,0), BackgroundColor3 = self.Theme.Accent, BorderSizePixel = 0})
            new("UICorner", {Parent = fill, CornerRadius = UDim.new(0,8)})
            local dragging = false
            local function updateFromPos(x)
                local rel = math.clamp((x - barBack.AbsolutePosition.X) / barBack.AbsoluteSize.X, 0, 1)
                local val = min + (max - min) * rel
                fill.Size = UDim2.new(rel, 0, 1, 0)
                lab.Text = (opts.Text or "Slider").. " — "..string.format("%.2f", val)
                safeCall(opts.Callback or function() end, val)
            end
            barBack.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    updateFromPos(input.Position.X)
                end
            end)
            barBack.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    updateFromPos(input.Position.X)
                end
            end)
            return {Get = function() return default end}
        end

        local function AddDropdown(opts)
            opts = opts or {}
            local choices = opts.Items or {}
            local selected = opts.Default or choices[1]
            local holder = new("Frame", {Parent = content, Size = UDim2.new(1,0,0,36), BackgroundTransparency = 1})
            local lab = new("TextLabel", {Parent = holder, Text = opts.Text or "Dropdown", Size = UDim2.new(0.5,0,1,0), BackgroundTransparency = 1, TextColor3 = self.Theme.Text, Font = Enum.Font.Gotham, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left})
            local box = new("TextButton", {Parent = holder, Size = UDim2.new(0.45,0,0,28), Position = UDim2.new(1,-(0.45*holder.AbsoluteSize.X) - 4, 0, 4), BackgroundColor3 = self.Theme.Window, Text = tostring(selected or ""), AutoButtonColor = false})
            new("UICorner", {Parent = box, CornerRadius = UDim.new(0,6)})
            local list = new("Frame", {Parent = holder, Position = UDim2.new(0,0,1,6), Size = UDim2.new(1,0,0,0), BackgroundColor3 = self.Theme.Section, Visible = false, ClipsDescendants = true})
            new("UICorner", {Parent = list, CornerRadius = UDim.new(0,6)})
            local layout = new("UIListLayout", {Parent = list, SortOrder = Enum.SortOrder.LayoutOrder})
            local open = false
            local function rebuild()
                for i,v in pairs(list:GetChildren()) do if v:IsA("TextButton") or v:IsA("TextLabel") then v:Destroy() end end
                for i,item in ipairs(choices) do
                    local it = new("TextButton", {Parent = list, Text = tostring(item), Size = UDim2.new(1,0,0,28), BackgroundTransparency = 1, TextColor3 = self.Theme.Text, Font = Enum.Font.Gotham, TextSize = 13})
                    it.MouseButton1Click:Connect(function()
                        selected = item
                        box.Text = tostring(item)
                        safeCall(opts.Callback or function() end, selected)
                        list.Visible = false
                        open = false
                    end)
                end
                list.Size = UDim2.new(1,0,0,#choices*28)
            end
            box.MouseButton1Click:Connect(function()
                open = not open
                list.Visible = open
                if open then rebuild() end
            end)
            rebuild()
            return {Get = function() return selected end, Set = function(v) selected = v; box.Text = tostring(v) end}
        end

        local function AddTextbox(opts)
            opts = opts or {}
            local holder = new("Frame", {Parent = content, Size = UDim2.new(1,0,0,36), BackgroundTransparency = 1})
            local lab = new("TextLabel", {Parent = holder, Text = opts.Text or "Textbox", Size = UDim2.new(0.4,0,1,0), BackgroundTransparency = 1, TextColor3 = self.Theme.Text, Font = Enum.Font.Gotham, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left})
            local box = new("TextBox", {Parent = holder, Size = UDim2.new(0.58,0,0,24), Position = UDim2.new(1,-(0.58*holder.AbsoluteSize.X) - 8, 0, 6), BackgroundColor3 = self.Theme.Window, Text = opts.Default or "", TextColor3 = self.Theme.Text, Font = Enum.Font.Gotham, TextSize = 14, ClearTextOnFocus = false})
            new("UICorner", {Parent = box, CornerRadius = UDim.new(0,6)})
            box.FocusLost:Connect(function(enter)
                safeCall(opts.Callback or function() end, box.Text)
            end)
            return box
        end

        -- return API
        return {
            AddButton = AddButton,
            AddToggle = AddToggle,
            AddSlider = AddSlider,
            AddDropdown = AddDropdown,
            AddTextbox = AddTextbox,
            SectionFrame = sectionFrame,
            ContentFrame = content,
        }
    end

    return {
        Button = tabBtn,
        Page = page,
        AddSection = AddSection,
    }
end

-- Config save
function FunUI:SaveAll()
    local data = {Theme = self.Theme}
    local ok, err = saveConfig(self.ConfigName, data)
    if not ok then
        warn("FunUI: failed saving config: ", err)
    end
    return ok
end

function FunUI:Destroy()
    pcall(function() self.Root:Destroy() end)
end

-- Utility to create an instance quickly for external use
local function Create(opts)
    return FunUI.new(opts)
end

-- Export
return {
    Create = Create,
    DEFAULT_THEME = DEFAULT_THEME,
}
