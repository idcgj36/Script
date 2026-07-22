local _Players = game:GetService('Players')
local _CoreGui = game:GetService('CoreGui')
local _TweenService = game:GetService("TweenService")
local _RunService = game:GetService("RunService")
local _LocalPlayer = _Players.LocalPlayer

getgenv().TP_GUI_COUNT = (getgenv().TP_GUI_COUNT or 0) + 1
local function formatID(num)
    return num < 10 and "0" .. num or tostring(num)
end
local GUI_ID = formatID(getgenv().TP_GUI_COUNT)

if _CoreGui:FindFirstChild("TPGui_" .. GUI_ID) then 
    return 
end

local targetPos = nil
local TPType = "Teleport"
local isLooping = false
local MarkerPart = nil
local DistanceLabel = nil

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TPGui_" .. GUI_ID
ScreenGui.Parent = _CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Parent = ScreenGui
Main.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Main.BackgroundTransparency = 0.3
Main.BorderSizePixel = 0
Main.AnchorPoint = Vector2.new(0.5, 0)
Main.Size = UDim2.new(0, 96, 0, 85)
Main.Position = UDim2.new(0.5, 0, 0, 34)
Main.Active = true
Main.Draggable = true

local UICornerMain = Instance.new("UICorner")
UICornerMain.CornerRadius = UDim.new(0, 10)
UICornerMain.Parent = Main

local IDLabel = Instance.new("TextLabel")
IDLabel.Name = "ID"
IDLabel.Parent = Main
IDLabel.Text = GUI_ID
IDLabel.Size = UDim2.new(0, 80, 0, 15)
IDLabel.Position = UDim2.new(0.5, 0, 0, 2)
IDLabel.AnchorPoint = Vector2.new(0.5, 0)
IDLabel.BackgroundTransparency = 1
IDLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
IDLabel.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold)
IDLabel.TextScaled = true

local SetBtn = Instance.new("TextButton")
SetBtn.Name = "SetBtn"
SetBtn.Parent = Main
SetBtn.Text = "SET"
SetBtn.Size = UDim2.new(0, 44, 0, 18)
SetBtn.Position = UDim2.new(0, 3, 0, 21)
SetBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SetBtn.BackgroundTransparency = 0.8
SetBtn.TextColor3 = Color3.fromRGB(246, 246, 246)
SetBtn.TextSize = 13
SetBtn.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold)
Instance.new("UICorner", SetBtn).CornerRadius = UDim.new(0, 5)

local TPBtn = Instance.new("TextButton")
TPBtn.Name = "TPBtn"
TPBtn.Parent = Main
TPBtn.Text = "TP"
TPBtn.Size = UDim2.new(0, 44, 0, 18)
TPBtn.Position = UDim2.new(1, -3, 0, 21)
TPBtn.AnchorPoint = Vector2.new(1, 0)
TPBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TPBtn.BackgroundTransparency = 0.8
TPBtn.TextColor3 = Color3.fromRGB(246, 246, 246)
TPBtn.TextSize = 13
TPBtn.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold)
Instance.new("UICorner", TPBtn).CornerRadius = UDim.new(0, 5)

local ModeBtn = Instance.new("TextButton")
ModeBtn.Name = "ModeBtn"
ModeBtn.Parent = Main
ModeBtn.Text = "Teleport"
ModeBtn.Size = UDim2.new(0, 89, 0, 17)
ModeBtn.Position = UDim2.new(0.5, 0, 1, -26)
ModeBtn.AnchorPoint = Vector2.new(0.5, 1)
ModeBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ModeBtn.BackgroundTransparency = 0.8
ModeBtn.TextColor3 = Color3.fromRGB(246, 246, 246)
ModeBtn.TextSize = 13
ModeBtn.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold)
Instance.new("UICorner", ModeBtn).CornerRadius = UDim.new(0, 5)

local LoopBtn = Instance.new("TextButton")
LoopBtn.Name = "LoopTP"
LoopBtn.Parent = Main
LoopBtn.Text = "LOOP"
LoopBtn.Size = UDim2.new(0, 89, 0, 17)
LoopBtn.Position = UDim2.new(0.5, 0, 1, -6)
LoopBtn.AnchorPoint = Vector2.new(0.5, 1)
LoopBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
LoopBtn.BackgroundTransparency = 0.8
LoopBtn.TextColor3 = Color3.fromRGB(246, 246, 246)
LoopBtn.TextSize = 13
LoopBtn.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold)
Instance.new("UICorner", LoopBtn).CornerRadius = UDim.new(0, 5)

local UIStroke = Instance.new("UIStroke")
UIStroke.Parent = LoopBtn
UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
UIStroke.Transparency = 0.1
UIStroke.Thickness = 1.1
UIStroke.Color = Color3.fromRGB(245, 245, 245)
UIStroke.Enabled = false

local function CreateMarker(targetCFrame)
    if MarkerPart then MarkerPart:Destroy() end
    MarkerPart = Instance.new("Part")
    MarkerPart.Name = "Marker_" .. GUI_ID
    MarkerPart.Anchored = true
    MarkerPart.CanCollide = false
    MarkerPart.Transparency = 1
    MarkerPart.Size = Vector3.new(1, 1, 1)
    MarkerPart.CFrame = targetCFrame
    MarkerPart.Parent = workspace

    local Billboard = Instance.new("BillboardGui")
    Billboard.Size = UDim2.new(0, 100, 0, 50)
    Billboard.AlwaysOnTop = true
    Billboard.Adornee = MarkerPart
    Billboard.Parent = MarkerPart

    local Icon = Instance.new("TextLabel")
    Icon.Size = UDim2.new(1, 0, 0.5, 0)
    Icon.BackgroundTransparency = 1
    Icon.TextColor3 = Color3.new(1, 1, 1)
    Icon.Text = "" .. GUI_ID
    Icon.TextSize = 16
    Icon.Parent = Billboard

    DistanceLabel = Instance.new("TextLabel")
    DistanceLabel.Position = UDim2.new(0, 0, 0.5, 0)
    DistanceLabel.Size = UDim2.new(1, 0, 0.5, 0)
    DistanceLabel.BackgroundTransparency = 1
    DistanceLabel.TextColor3 = Color3.new(0.9, 0.9, 0.9)
    DistanceLabel.TextSize = 16
    DistanceLabel.Parent = Billboard
end

_RunService.RenderStepped:Connect(function()
    if MarkerPart and DistanceLabel then
        local char = _LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local dist = (char.HumanoidRootPart.Position - MarkerPart.Position).Magnitude
            DistanceLabel.Text = math.floor(dist) .. "m"
        end
    end
end)

local function doTeleport()
    local char = _LocalPlayer.Character
    if targetPos and char and char:FindFirstChild('HumanoidRootPart') and MarkerPart then
        local hrp = char.HumanoidRootPart
        local goalCFrame = CFrame.new(targetPos) * MarkerPart.CFrame.Rotation
        if TPType == "Teleport" then
            hrp.CFrame = goalCFrame
        else
            local dist = (hrp.Position - targetPos).Magnitude
            local tween = _TweenService:Create(
                hrp,
                TweenInfo.new(dist/60, Enum.EasingStyle.Linear),
                {CFrame = goalCFrame}
            )
            tween:Play()
        end
    end
end

SetBtn.MouseButton1Click:Connect(function()
    local char = _LocalPlayer.Character
    if char and char:FindFirstChild('HumanoidRootPart') then
        targetPos = char.HumanoidRootPart.Position
        CreateMarker(char.HumanoidRootPart.CFrame)
    end
end)

ModeBtn.MouseButton1Click:Connect(function()
    if TPType == "Teleport" then
        TPType = "Tween"
        ModeBtn.Text = "Tween"
    else
        TPType = "Teleport"
        ModeBtn.Text = "Teleport"
    end
end)

TPBtn.MouseButton1Click:Connect(doTeleport)

LoopBtn.MouseButton1Click:Connect(function()
    isLooping = not isLooping
    UIStroke.Enabled = isLooping
    
    if isLooping then
        task.spawn(function()
            while isLooping do
                doTeleport()
                task.wait(0.031)
            end
        end)
    end
end)
