local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Removing = false
local Collapsed = false
local PlayerListOpened = false

local OrbitEnabled = false
local CurrentTarget = nil
local OrbitSpeedValue = 5
local OrbitDistanceValue = 10
local CurrentAngle = 0

local SelectedBorderHighlight = nil
local TargetHighlight = nil

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = CoreGui
ScreenGui.DisplayOrder = 10
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local OrbitFrame = Instance.new("Frame")
OrbitFrame.Parent = ScreenGui
OrbitFrame.Name = "OrbitFrame"
OrbitFrame.AnchorPoint = Vector2.new(0.5, 0)
OrbitFrame.Position = UDim2.new(0.5, 0, 0, 60)
OrbitFrame.Size = UDim2.new(0, 280, 0, 241)
OrbitFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
OrbitFrame.BackgroundTransparency = 0.25
OrbitFrame.BorderSizePixel = 0
OrbitFrame.Active = true
OrbitFrame.Draggable = true

local OrbitCorner = Instance.new("UICorner")
OrbitCorner.Parent = OrbitFrame
OrbitCorner.CornerRadius = UDim.new(0, 25)

local PlayerList = Instance.new("Frame")
PlayerList.Parent = OrbitFrame
PlayerList.Name = "PlayerList"
PlayerList.Visible = false
PlayerList.AnchorPoint = Vector2.new(1, 0.5)
PlayerList.Position = UDim2.new(1, 219, 0.5, 0)
PlayerList.Size = UDim2.new(0, 216, 0, 242)
PlayerList.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
PlayerList.BackgroundTransparency = 0.25
PlayerList.BorderSizePixel = 0

local PlayerListCorner = Instance.new("UICorner")
PlayerListCorner.Parent = PlayerList
PlayerListCorner.CornerRadius = UDim.new(0, 25)

local ScrollList = Instance.new("ScrollingFrame")
ScrollList.Parent = PlayerList
ScrollList.Name = "ScrollList"
ScrollList.AnchorPoint = Vector2.new(0.5, 0.5)
ScrollList.Position = UDim2.new(0.5, 0, 0.5, 0)
ScrollList.Size = UDim2.new(0, 208, 0, 224)
ScrollList.BackgroundTransparency = 1
ScrollList.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ScrollList.BorderSizePixel = 0
ScrollList.ScrollBarThickness = 0
ScrollList.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ScrollList
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 6)

local SelectFrame = Instance.new("Frame")
SelectFrame.Name = "SelectFrame"
SelectFrame.Size = UDim2.new(0, 198, 0, 52)
SelectFrame.BackgroundTransparency = 1
SelectFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SelectFrame.BorderSizePixel = 0

local PlayerBtn = Instance.new("TextButton")
PlayerBtn.Parent = SelectFrame
PlayerBtn.Name = "PlayerBtn"
PlayerBtn.AnchorPoint = Vector2.new(0.5, 0.5)
PlayerBtn.Position = UDim2.new(0.5, 0, 0.5, 0)
PlayerBtn.Size = UDim2.new(1, 0, 0, 48)
PlayerBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
PlayerBtn.BackgroundTransparency = 0.7
PlayerBtn.BorderSizePixel = 0
PlayerBtn.Text = ""

local PlayerBtnCorner = Instance.new("UICorner")
PlayerBtnCorner.Parent = PlayerBtn

local SelectBorder = Instance.new("UIStroke")
SelectBorder.Parent = PlayerBtn
SelectBorder.Name = "SelectBorder"
SelectBorder.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
SelectBorder.Thickness = 1.5
SelectBorder.Transparency = 1
SelectBorder.Color = Color3.fromRGB(255, 255, 255)

local DisplayName = Instance.new("TextLabel")
DisplayName.Parent = PlayerBtn
DisplayName.Name = "DisplayName"
DisplayName.Position = UDim2.new(0, 46, 0, 6)
DisplayName.Size = UDim2.new(0, 146, 0, 16)
DisplayName.BackgroundTransparency = 1
DisplayName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
DisplayName.BorderSizePixel = 0
DisplayName.Text = "DisplayName"
DisplayName.TextWrapped = true
DisplayName.TextScaled = true
DisplayName.TextXAlignment = Enum.TextXAlignment.Left
DisplayName.TextColor3 = Color3.fromRGB(255, 255, 255)
DisplayName.FontFace = Font.new(
    "rbxasset://fonts/families/SourceSansPro.json",
    Enum.FontWeight.Bold,
    Enum.FontStyle.Normal
)

local Username = Instance.new("TextLabel")
Username.Parent = PlayerBtn
Username.Name = "Username"
Username.AnchorPoint = Vector2.new(0, 1)
Username.Position = UDim2.new(0, 46, 1, -6)
Username.Size = UDim2.new(0, 146, 0, 16)
Username.BackgroundTransparency = 1
Username.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Username.BorderSizePixel = 0
Username.Text = "@Username"
Username.TextWrapped = true
Username.TextScaled = true
Username.TextXAlignment = Enum.TextXAlignment.Left
Username.TextColor3 = Color3.fromRGB(201, 201, 201)
Username.FontFace = Font.new(
    "rbxasset://fonts/families/SourceSansPro.json",
    Enum.FontWeight.Bold,
    Enum.FontStyle.Normal
)

local Avatar = Instance.new("ImageLabel")
Avatar.Parent = PlayerBtn
Avatar.Name = "Avatar"
Avatar.AnchorPoint = Vector2.new(0, 0.5)
Avatar.Position = UDim2.new(0, 5, 0.5, 0)
Avatar.Size = UDim2.new(0, 37, 0, 37)
Avatar.BackgroundTransparency = 1
Avatar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Avatar.BorderSizePixel = 0

local OrbitSpeed = Instance.new("Frame")
OrbitSpeed.Parent = OrbitFrame
OrbitSpeed.Name = "OrbitSpeed"
OrbitSpeed.AnchorPoint = Vector2.new(0.5, 0)
OrbitSpeed.Position = UDim2.new(0.5, 0, 0, 94)
OrbitSpeed.Size = UDim2.new(0, 250, 0, 34)
OrbitSpeed.BackgroundTransparency = 1
OrbitSpeed.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
OrbitSpeed.BorderSizePixel = 0

local OrbitSpeedCorner = Instance.new("UICorner")
OrbitSpeedCorner.Parent = OrbitSpeed

local SliderBar = Instance.new("ImageButton")
SliderBar.Parent = OrbitSpeed
SliderBar.Name = "SliderBar"
SliderBar.AnchorPoint = Vector2.new(1, 0.5)
SliderBar.Position = UDim2.new(1, -7, 0.5, 0)
SliderBar.Size = UDim2.new(0, 180, 0, 4)
SliderBar.BackgroundTransparency = 0.9
SliderBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SliderBar.BorderSizePixel = 0

local SliderCorner = Instance.new("UICorner")
SliderCorner.Parent = SliderBar

local Fill = Instance.new("Frame")
Fill.Parent = SliderBar
Fill.Name = "Fill"
Fill.AnchorPoint = Vector2.new(0, 0.5)
Fill.Position = UDim2.new(0, 0, 0.5, 0)
Fill.Size = UDim2.new(0.25, 0, 1, 0)
Fill.BackgroundColor3 = Color3.fromRGB(231, 231, 231)
Fill.BorderSizePixel = 0

local FillCorner = Instance.new("UICorner")
FillCorner.Parent = Fill

local Handle = Instance.new("TextButton")
Handle.Parent = Fill
Handle.Name = "Handle"
Handle.AnchorPoint = Vector2.new(1, 0.5)
Handle.Position = UDim2.new(1, 6, 0.5, 0)
Handle.Size = UDim2.new(0, 14, 0, 13)
Handle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Handle.BorderSizePixel = 0
Handle.Text = ""

local HandleCorner = Instance.new("UICorner")
HandleCorner.Parent = Handle

local SpeedTitle = Instance.new("TextLabel")
SpeedTitle.Parent = OrbitSpeed
SpeedTitle.Name = "Title"
SpeedTitle.AnchorPoint = Vector2.new(0, 0.5)
SpeedTitle.Position = UDim2.new(0, 10, 0.5, -1)
SpeedTitle.Size = UDim2.new(0, 48, 0, 20)
SpeedTitle.BackgroundTransparency = 1
SpeedTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SpeedTitle.BorderSizePixel = 0
SpeedTitle.Text = "Speed"
SpeedTitle.TextWrapped = true
SpeedTitle.TextSize = 20
SpeedTitle.TextXAlignment = Enum.TextXAlignment.Left
SpeedTitle.TextColor3 = Color3.fromRGB(226, 226, 226)
SpeedTitle.FontFace = Font.new(
    "rbxasset://fonts/families/SourceSansPro.json",
    Enum.FontWeight.Bold,
    Enum.FontStyle.Normal
)

local OpenPlayerList = Instance.new("TextButton")
OpenPlayerList.Parent = OrbitFrame
OpenPlayerList.Name = "OpenPlayerList"
OpenPlayerList.AnchorPoint = Vector2.new(0.5, 0)
OpenPlayerList.Position = UDim2.new(0.5, 0, 0, 187)
OpenPlayerList.Size = UDim2.new(0, 250, 0, 34)
OpenPlayerList.BackgroundTransparency = 1
OpenPlayerList.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
OpenPlayerList.BorderSizePixel = 0
OpenPlayerList.Text = ""

local OpenPlayerListCorner = Instance.new("UICorner")
OpenPlayerListCorner.Parent = OpenPlayerList

local OpenPlayerListTitle = Instance.new("TextLabel")
OpenPlayerListTitle.Parent = OpenPlayerList
OpenPlayerListTitle.Name = "Title"
OpenPlayerListTitle.AnchorPoint = Vector2.new(0, 0.5)
OpenPlayerListTitle.Position = UDim2.new(0, 10, 0.5, -1)
OpenPlayerListTitle.Size = UDim2.new(0, 116, 0, 20)
OpenPlayerListTitle.BackgroundTransparency = 1
OpenPlayerListTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
OpenPlayerListTitle.BorderSizePixel = 0
OpenPlayerListTitle.Text = "Open Player List"
OpenPlayerListTitle.TextSize = 20
OpenPlayerListTitle.TextXAlignment = Enum.TextXAlignment.Left
OpenPlayerListTitle.TextColor3 = Color3.fromRGB(226, 226, 226)
OpenPlayerListTitle.FontFace = Font.new(
    "rbxasset://fonts/families/SourceSansPro.json",
    Enum.FontWeight.Bold,
    Enum.FontStyle.Normal
)

local OpenPlayerListIcon = Instance.new("ImageLabel")
OpenPlayerListIcon.Parent = OpenPlayerList
OpenPlayerListIcon.Name = "Icon"
OpenPlayerListIcon.AnchorPoint = Vector2.new(1, 0.5)
OpenPlayerListIcon.Position = UDim2.new(1, -10, 0.5, 0)
OpenPlayerListIcon.Size = UDim2.new(0, 22, 0, 22)
OpenPlayerListIcon.BackgroundTransparency = 1
OpenPlayerListIcon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
OpenPlayerListIcon.BorderSizePixel = 0
OpenPlayerListIcon.Image = "rbxassetid://87462136296578"

local TopBar = Instance.new("Frame")
TopBar.Parent = OrbitFrame
TopBar.Name = "TopBar"
TopBar.AnchorPoint = Vector2.new(0.5, 0)
TopBar.Position = UDim2.new(0.5, 0, 0, 5)
TopBar.Size = UDim2.new(0.97, 0, 0, 34)
TopBar.BackgroundTransparency = 1
TopBar.BackgroundColor3 = Color3.fromRGB(99, 99, 99)
TopBar.BorderSizePixel = 0

local TopBarCorner = Instance.new("UICorner")
TopBarCorner.Parent = TopBar

local ToggleUI = Instance.new("TextButton")
ToggleUI.Parent = TopBar
ToggleUI.Name = "ToggleUI"
ToggleUI.AnchorPoint = Vector2.new(1, 0.5)
ToggleUI.Position = UDim2.new(1, -42, 0.5, 0)
ToggleUI.Size = UDim2.new(0, 28, 0, 26)
ToggleUI.BackgroundTransparency = 1
ToggleUI.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ToggleUI.BorderSizePixel = 0
ToggleUI.Text = ""

local ToggleIcon = Instance.new("ImageLabel")
ToggleIcon.Parent = ToggleUI
ToggleIcon.Name = "Icon"
ToggleIcon.AnchorPoint = Vector2.new(0.5, 0.5)
ToggleIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
ToggleIcon.Size = UDim2.new(0, 18, 0, 18)
ToggleIcon.BackgroundTransparency = 1
ToggleIcon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ToggleIcon.BorderSizePixel = 0
ToggleIcon.Image = "rbxassetid://122444883127455"

local RemoveBtn = Instance.new("TextButton")
RemoveBtn.Parent = TopBar
RemoveBtn.Name = "RemoveBtn"
RemoveBtn.AnchorPoint = Vector2.new(1, 0.5)
RemoveBtn.Position = UDim2.new(1, -7, 0.5, 0)
RemoveBtn.Size = UDim2.new(0, 28, 0, 26)
RemoveBtn.BackgroundTransparency = 1
RemoveBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
RemoveBtn.BorderSizePixel = 0
RemoveBtn.Text = ""

local RemoveIcon = Instance.new("ImageLabel")
RemoveIcon.Parent = RemoveBtn
RemoveIcon.Name = "Icon"
RemoveIcon.AnchorPoint = Vector2.new(0.5, 0.5)
RemoveIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
RemoveIcon.Size = UDim2.new(0, 17, 0, 17)
RemoveIcon.BackgroundTransparency = 1
RemoveIcon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
RemoveIcon.BorderSizePixel = 0
RemoveIcon.Image = "rbxassetid://110786993356448"

local TopBarTitle = Instance.new("TextLabel")
TopBarTitle.Parent = TopBar
TopBarTitle.Name = "Title"
TopBarTitle.AnchorPoint = Vector2.new(0, 0.5)
TopBarTitle.Position = UDim2.new(0, 10, 0.5, 0)
TopBarTitle.Size = UDim2.new(0, 94, 0, 20)
TopBarTitle.BackgroundTransparency = 1
TopBarTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TopBarTitle.BorderSizePixel = 0
TopBarTitle.Text = "Orbit Gui"
TopBarTitle.TextWrapped = true
TopBarTitle.TextScaled = true
TopBarTitle.TextSize = 10
TopBarTitle.TextXAlignment = Enum.TextXAlignment.Left
TopBarTitle.TextColor3 = Color3.fromRGB(226, 226, 226)
TopBarTitle.FontFace = Font.new(
    "rbxasset://fonts/families/SourceSansPro.json",
    Enum.FontWeight.Bold,
    Enum.FontStyle.Normal
)

local OrbitDistance = Instance.new("Frame")
OrbitDistance.Parent = OrbitFrame
OrbitDistance.Name = "OrbitDistance"
OrbitDistance.AnchorPoint = Vector2.new(0.5, 0)
OrbitDistance.Position = UDim2.new(0.5, 0, 0, 140)
OrbitDistance.Size = UDim2.new(0, 250, 0, 34)
OrbitDistance.BackgroundTransparency = 1
OrbitDistance.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
OrbitDistance.BorderSizePixel = 0

local OrbitDistanceCorner = Instance.new("UICorner")
OrbitDistanceCorner.Parent = OrbitDistance

local DistanceSliderBar = Instance.new("ImageButton")
DistanceSliderBar.Parent = OrbitDistance
DistanceSliderBar.Name = "SliderBar"
DistanceSliderBar.AnchorPoint = Vector2.new(1, 0.5)
DistanceSliderBar.Position = UDim2.new(1, -6, 0.5, 0)
DistanceSliderBar.Size = UDim2.new(0, 166, 0, 4)
DistanceSliderBar.BackgroundTransparency = 0.9
DistanceSliderBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
DistanceSliderBar.BorderSizePixel = 0

local DistanceSliderCorner = Instance.new("UICorner")
DistanceSliderCorner.Parent = DistanceSliderBar

local DistanceFill = Instance.new("Frame")
DistanceFill.Parent = DistanceSliderBar
DistanceFill.Name = "Fill"
DistanceFill.AnchorPoint = Vector2.new(0, 0.5)
DistanceFill.Position = UDim2.new(0, 0, 0.5, 0)
DistanceFill.Size = UDim2.new(0.2, 0, 1, 0)
DistanceFill.BackgroundColor3 = Color3.fromRGB(231, 231, 231)
DistanceFill.BorderSizePixel = 0

local DistanceFillCorner = Instance.new("UICorner")
DistanceFillCorner.Parent = DistanceFill

local DistanceHandle = Instance.new("TextButton")
DistanceHandle.Parent = DistanceFill
DistanceHandle.Name = "Handle"
DistanceHandle.AnchorPoint = Vector2.new(1, 0.5)
DistanceHandle.Position = UDim2.new(1, 6, 0.5, 0)
DistanceHandle.Size = UDim2.new(0, 14, 0, 13)
DistanceHandle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
DistanceHandle.BorderSizePixel = 0
DistanceHandle.Text = ""

local DistanceHandleCorner = Instance.new("UICorner")
DistanceHandleCorner.Parent = DistanceHandle

local DistanceTitle = Instance.new("TextLabel")
DistanceTitle.Parent = OrbitDistance
DistanceTitle.Name = "Title"
DistanceTitle.AnchorPoint = Vector2.new(0, 0.5)
DistanceTitle.Position = UDim2.new(0, 10, 0.5, -1)
DistanceTitle.Size = UDim2.new(0, 61, 0, 20)
DistanceTitle.BackgroundTransparency = 1
DistanceTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
DistanceTitle.BorderSizePixel = 0
DistanceTitle.Text = "Distance"
DistanceTitle.TextSize = 20
DistanceTitle.TextXAlignment = Enum.TextXAlignment.Left
DistanceTitle.TextColor3 = Color3.fromRGB(226, 226, 226)
DistanceTitle.FontFace = Font.new(
    "rbxasset://fonts/families/SourceSansPro.json",
    Enum.FontWeight.Bold,
    Enum.FontStyle.Normal
)

local EnabledBtn = Instance.new("TextButton")
EnabledBtn.Parent = OrbitFrame
EnabledBtn.Name = "EnabledBtn"
EnabledBtn.AnchorPoint = Vector2.new(0.5, 0)
EnabledBtn.Position = UDim2.new(0.5, 0, 0, 50)
EnabledBtn.Size = UDim2.new(0, 250, 0, 34)
EnabledBtn.BackgroundTransparency = 1
EnabledBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
EnabledBtn.BorderSizePixel = 0
EnabledBtn.Text = ""

local EnabledBtnCorner = Instance.new("UICorner")
EnabledBtnCorner.Parent = EnabledBtn

local Track = Instance.new("Frame")
Track.Parent = EnabledBtn
Track.Name = "Track"
Track.AnchorPoint = Vector2.new(1, 0.5)
Track.Position = UDim2.new(1, -8, 0.5, 0)
Track.Size = UDim2.new(0, 52, 0, 24)
Track.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Track.BorderSizePixel = 0

local TrackCorner = Instance.new("UICorner")
TrackCorner.Parent = Track
TrackCorner.CornerRadius = UDim.new(1, 0)

local Thumb = Instance.new("Frame")
Thumb.Parent = Track
Thumb.Name = "Thumb"
Thumb.AnchorPoint = Vector2.new(0, 0.5)
Thumb.Position = UDim2.new(0, 5, 0.5, 0)
Thumb.Size = UDim2.new(0, 20, 0, 18)
Thumb.BackgroundColor3 = Color3.fromRGB(185, 185, 185)
Thumb.BorderSizePixel = 0

local ThumbCorner = Instance.new("UICorner")
ThumbCorner.Parent = Thumb
ThumbCorner.CornerRadius = UDim.new(1, 0)

local TrackStroke = Instance.new("UIStroke")
TrackStroke.Parent = Track
TrackStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
TrackStroke.Transparency = 0.85
TrackStroke.Color = Color3.fromRGB(255, 255, 255)

local EnabledTitle = Instance.new("TextLabel")
EnabledTitle.Parent = EnabledBtn
EnabledTitle.Name = "Title"
EnabledTitle.AnchorPoint = Vector2.new(0, 0.5)
EnabledTitle.Position = UDim2.new(0, 10, 0.5, -1)
EnabledTitle.Size = UDim2.new(0, 112, 0, 20)
EnabledTitle.BackgroundTransparency = 1
EnabledTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
EnabledTitle.BorderSizePixel = 0
EnabledTitle.Text = "Enabled Orbit"
EnabledTitle.TextSize = 20
EnabledTitle.TextXAlignment = Enum.TextXAlignment.Left
EnabledTitle.TextColor3 = Color3.fromRGB(226, 226, 226)
EnabledTitle.FontFace = Font.new(
    "rbxasset://fonts/families/SourceSansPro.json",
    Enum.FontWeight.Bold,
    Enum.FontStyle.Normal
)

local function CreateTooltip(handle)
	local tooltip = Instance.new("Frame")
	tooltip.Name = "Tooltip"
	tooltip.Parent = handle
	tooltip.AnchorPoint = Vector2.new(0.5, 1)
	tooltip.Position = UDim2.new(0.5, 0, 0, -6)
	tooltip.Size = UDim2.new(0, 28, 0, 18)
	tooltip.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	tooltip.BorderSizePixel = 0
	tooltip.Visible = false

	local corner = Instance.new("UICorner")
	corner.Parent = tooltip
	corner.CornerRadius = UDim.new(0, 10)

	local label = Instance.new("TextLabel")
	label.Name = "ValueLabel"
	label.Parent = tooltip
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(0, 0, 0)
	label.TextSize = 12
	label.FontFace = Font.new(
		"rbxasset://fonts/families/SourceSansPro.json",
		Enum.FontWeight.Bold,
		Enum.FontStyle.Normal
	)

	return tooltip, label
end

local function SetTargetHighlight(player)
	if TargetHighlight then
		TargetHighlight:Destroy()
		TargetHighlight = nil
	end

	if player and player.Character then
		TargetHighlight = Instance.new("Highlight")
		TargetHighlight.Name = "TargetOrbitHighlight"
		TargetHighlight.Adornee = player.Character
		TargetHighlight.FillColor = Color3.fromRGB(255, 255, 255)
		TargetHighlight.FillTransparency = 0.5
		TargetHighlight.OutlineColor = Color3.fromRGB(255, 255, 255)
		TargetHighlight.OutlineTransparency = 0
		TargetHighlight.Parent = player.Character
	end
end

local function ClearTarget()
	CurrentTarget = nil
	SetTargetHighlight(nil)
	if SelectedBorderHighlight then
		SelectedBorderHighlight.Transparency = 1
		SelectedBorderHighlight = nil
	end
	if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
		Camera.CameraSubject = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	end
end

local function UpdatePlayerList()
	for _, child in ipairs(ScrollList:GetChildren()) do
		if child:IsA("Frame") and child ~= SelectFrame then
			child:Destroy()
		end
	end

	SelectFrame.Visible = false

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer then
			local entry = SelectFrame:Clone()
			entry.Name = plr.Name
			entry.Visible = true
			entry.Parent = ScrollList

			local btn = entry:FindFirstChild("PlayerBtn")
			if btn then
				btn.DisplayName.Text = plr.DisplayName
				btn.Username.Text = "@" .. plr.Name

				task.spawn(function()
					local content = Players:GetUserThumbnailAsync(
						plr.UserId,
						Enum.ThumbnailType.HeadShot,
						Enum.ThumbnailSize.Size100x100
					)
					if btn and btn:FindFirstChild("Avatar") then
						btn.Avatar.Image = content
					end
				end)

				btn.MouseButton1Click:Connect(function()
					if SelectedBorderHighlight then
						SelectedBorderHighlight.Transparency = 1
					end

					if CurrentTarget == plr then
						ClearTarget()
					else
						CurrentTarget = plr
						SelectedBorderHighlight = btn.SelectBorder
						SelectedBorderHighlight.Transparency = 0.15
						SetTargetHighlight(plr)
						if plr.Character and plr.Character:FindFirstChildOfClass("Humanoid") then
							Camera.CameraSubject = plr.Character:FindFirstChildOfClass("Humanoid")
						end
					end
				end)
			end
		end
	end

	ScrollList.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
end

Players.PlayerAdded:Connect(UpdatePlayerList)
Players.PlayerRemoving:Connect(function(plr)
	if CurrentTarget == plr then
		ClearTarget()
	end
	UpdatePlayerList()
end)
UpdatePlayerList()

local function SetupSlider(sliderBar, fill, handle, minVal, maxVal, defaultVal, callback)
	local dragging = false
	local tooltip, valueLabel = CreateTooltip(handle)

	local function Update(input)
		local barPos = sliderBar.AbsolutePosition.X
		local barWidth = sliderBar.AbsoluteSize.X
		local mouseX = input.Position.X
		local percent = math.clamp((mouseX - barPos) / barWidth, 0, 1)

		fill.Size = UDim2.new(percent, 0, 1, 0)
		local value = math.floor(minVal + (maxVal - minVal) * percent)
		valueLabel.Text = tostring(value)
		callback(value)
	end

	sliderBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			tooltip.Visible = true
			Update(input)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			Update(input)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
			tooltip.Visible = false
		end
	end)

	local defaultPercent = math.clamp((defaultVal - minVal) / (maxVal - minVal), 0, 1)
	fill.Size = UDim2.new(defaultPercent, 0, 1, 0)
	valueLabel.Text = tostring(math.floor(defaultVal))
	callback(defaultVal)
end

SetupSlider(SliderBar, Fill, Handle, 1, 45, 5, function(val)
	OrbitSpeedValue = val
end)

SetupSlider(DistanceSliderBar, DistanceFill, DistanceHandle, 3, 55, 10, function(val)
	OrbitDistanceValue = val
end)

EnabledBtn.MouseButton1Click:Connect(function()
	OrbitEnabled = not OrbitEnabled

	local targetPos = OrbitEnabled and UDim2.new(1, -25, 0.5, 0) or UDim2.new(0, 5, 0.5, 0)
	local targetColor = OrbitEnabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(50, 50, 50)

	TweenService:Create(Thumb, TweenInfo.new(0.2), {Position = targetPos}):Play()
	TweenService:Create(Track, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()

	if not OrbitEnabled then
		if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
			Camera.CameraSubject = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		end
	elseif CurrentTarget and CurrentTarget.Character and CurrentTarget.Character:FindFirstChildOfClass("Humanoid") then
		Camera.CameraSubject = CurrentTarget.Character:FindFirstChildOfClass("Humanoid")
	end
end)

RunService.RenderStepped:Connect(function(deltaTime)
	if not OrbitEnabled or not CurrentTarget or not CurrentTarget.Character then
		return
	end

	local targetRoot = CurrentTarget.Character:FindFirstChild("HumanoidRootPart")
	local myChar = LocalPlayer.Character
	local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")

	if targetRoot and myRoot then
		CurrentAngle = CurrentAngle + (deltaTime * OrbitSpeedValue)

		local offsetX = math.cos(CurrentAngle) * OrbitDistanceValue
		local offsetZ = math.sin(CurrentAngle) * OrbitDistanceValue
		local newPosition = targetRoot.Position + Vector3.new(offsetX, 0, offsetZ)

		myRoot.CFrame = CFrame.lookAt(newPosition, targetRoot.Position)

		if Camera.CameraSubject ~= CurrentTarget.Character:FindFirstChildOfClass("Humanoid") then
			Camera.CameraSubject = CurrentTarget.Character:FindFirstChildOfClass("Humanoid")
		end

		if TargetHighlight and TargetHighlight.Parent ~= CurrentTarget.Character then
			SetTargetHighlight(CurrentTarget)
		end
	end
end)

RemoveBtn.MouseButton1Click:Connect(function()
	if Removing then
		return
	end

	Removing = true
	OrbitEnabled = false
	ClearTarget()

	local FadeTween = TweenInfo.new(
		0.25,
		Enum.EasingStyle.Quart,
		Enum.EasingDirection.Out
	)

	for _, v in ipairs(ScreenGui:GetDescendants()) do
		if v:IsA("Frame") then
			TweenService:Create(v, FadeTween, {
				BackgroundTransparency = 1
			}):Play()

		elseif v:IsA("TextLabel") or v:IsA("TextButton") then
			TweenService:Create(v, FadeTween, {
				BackgroundTransparency = 1,
				TextTransparency = 1
			}):Play()

		elseif v:IsA("ImageLabel") or v:IsA("ImageButton") then
			TweenService:Create(v, FadeTween, {
				BackgroundTransparency = 1,
				ImageTransparency = 1
			}):Play()

		elseif v:IsA("UIStroke") then
			TweenService:Create(v, FadeTween, {
				Transparency = 1
			}):Play()
		end
	end

	TweenService:Create(
		OrbitFrame,
		FadeTween,
		{
			Size = UDim2.new(0, 200, 0, 44)
		}
	):Play()

	if PlayerList.Visible then
		TweenService:Create(
			PlayerList,
			FadeTween,
			{
				Size = UDim2.new(0, 200, 0, 44)
			}
		):Play()
	end

	task.wait(0.3)

	ScreenGui:Destroy()
end)

local OpenTween = TweenInfo.new(
	0.25,
	Enum.EasingStyle.Quart,
	Enum.EasingDirection.Out
)

local CloseTween = TweenInfo.new(
	0.25,
	Enum.EasingStyle.Quart,
	Enum.EasingDirection.Out
)

ToggleUI.MouseButton1Click:Connect(function()
	Collapsed = not Collapsed

	if Collapsed then
		ToggleIcon.Image = "rbxassetid://134243273101015"

		for _, v in ipairs(OrbitFrame:GetChildren()) do
			if v ~= TopBar and v ~= PlayerList and v:IsA("GuiObject") then
				v.Visible = false
			end
		end

		TweenService:Create(
			OrbitFrame,
			CloseTween,
			{
				Size = UDim2.new(0, 159, 0, 44)
			}
		):Play()
	else
		ToggleIcon.Image = "rbxassetid://122444883127455"

		for _, v in ipairs(OrbitFrame:GetChildren()) do
			if v ~= TopBar and v ~= PlayerList and v:IsA("GuiObject") then
				v.Visible = true
			end
		end

		TweenService:Create(
			OrbitFrame,
			OpenTween,
			{
				Size = UDim2.new(0, 280, 0, 241)
			}
		):Play()
	end
end)

OpenPlayerList.MouseButton1Click:Connect(function()
	PlayerListOpened = not PlayerListOpened
	PlayerList.Visible = PlayerListOpened
end)
