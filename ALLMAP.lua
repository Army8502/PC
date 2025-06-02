local scale = 0.7 -- ปรับขนาดเนื้อหา UI ไม่ให้ container โดนตัด

-- Modern Speed & Jump Booster UI Script
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

local defaultSpeed = Humanoid.WalkSpeed
local defaultJump = Humanoid.JumpPower

local currentSpeed = defaultSpeed
local currentJump = defaultJump

local speedEnabled = false
local jumpEnabled = false

local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "ModernSpeedJumpUI"

--== UI Frame ==--
local container = Instance.new("Frame", gui)
container.Size = UDim2.new(0, 360 * scale, 0, 0 * scale)
container.AutomaticSize = Enum.AutomaticSize.Y
container.Position = UDim2.new(0, 30 * scale, 0.35, 0 * scale)
container.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
container.BackgroundTransparency = 0.1
container.BorderSizePixel = 0
container.Active = true
container.Draggable = true
Instance.new("UICorner", container).CornerRadius = UDim.new(0, 14 * scale)

local layout = Instance.new("UIListLayout", container)
layout.Padding = UDim.new(0, 16 * scale)
layout.FillDirection = Enum.FillDirection.Vertical
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.VerticalAlignment = Enum.VerticalAlignment.Top

local padding = Instance.new("UIPadding", container)
padding.PaddingTop = UDim.new(0, 20 * scale)
padding.PaddingBottom = UDim.new(0, 20 * scale)
padding.PaddingLeft = UDim.new(0, 20 * scale)
padding.PaddingRight = UDim.new(0, 20 * scale)

local function createSection(nameText, valueText)
	local section = Instance.new("Frame")
	section.Size = UDim2.new(1, 0, 0, 80)
	section.BackgroundTransparency = 1

	local label = Instance.new("TextLabel", section)
	label.Size = UDim2.new(0.7, 0 * scale, 0, 20 * scale)
	label.Position = UDim2.new(0, 0 * scale, 0, 0 * scale)
	label.Text = nameText
	label.Font = Enum.Font.GothamBold
	label.TextSize = 18 * scale
	label.TextColor3 = Color3.fromRGB(230, 230, 235)
	label.BackgroundTransparency = 1
	label.TextXAlignment = Enum.TextXAlignment.Left

	local toggle = Instance.new("TextButton", section)
	toggle.Size = UDim2.new(0, 60 * scale, 0, 26 * scale)
	toggle.Position = UDim2.new(1, -65, 0, 0)
	toggle.Text = "OFF"
	toggle.Font = Enum.Font.GothamSemibold
	toggle.TextSize = 14 * scale
	toggle.TextColor3 = Color3.fromRGB(160, 160, 165)
	toggle.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
	Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 6 * scale)

	local valueLabel = Instance.new("TextLabel", section)
	valueLabel.Size = UDim2.new(1, 0, 0, 20)
	valueLabel.Position = UDim2.new(0, 0 * scale, 0, 28 * scale)
	valueLabel.Text = valueText
	valueLabel.Font = Enum.Font.Gotham
	valueLabel.TextSize = 14 * scale
	valueLabel.TextColor3 = Color3.fromRGB(140, 140, 145)
	valueLabel.BackgroundTransparency = 1
	valueLabel.TextXAlignment = Enum.TextXAlignment.Left

	local slider = Instance.new("Frame", section)
	slider.Size = UDim2.new(1, 0, 0, 8)
	slider.Position = UDim2.new(0, 0 * scale, 0, 54 * scale)
	slider.BackgroundColor3 = Color3.fromRGB(55, 55, 60)
	Instance.new("UICorner", slider).CornerRadius = UDim.new(1, 0)

	local fill = Instance.new("Frame", slider)
	fill.Size = UDim2.new(0.3, 0, 1, 0)
	fill.BackgroundColor3 = Color3.fromRGB(0, 160, 255)
	Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

	return section, toggle, valueLabel, slider, fill
end

local speedSection, speedToggle, speedLabel, speedSlider, speedFill = createSection("Walk Speed", "Speed: " .. currentSpeed)
speedSection.Parent = container

local jumpSection, jumpToggle, jumpLabel, jumpSlider, jumpFill = createSection("Jump Power", "Jump: " .. currentJump)
jumpSection.Parent = container

local noclipSection = Instance.new("Frame")
noclipSection.Size = UDim2.new(1, 0, 0, 40)
noclipSection.BackgroundTransparency = 1

local noclipLabel = Instance.new("TextLabel", noclipSection)
noclipLabel.Size = UDim2.new(0.7, 0 * scale, 0, 20 * scale)
noclipLabel.Position = UDim2.new(0, 0 * scale, 0, 0 * scale)
noclipLabel.Text = "Noclip"
noclipLabel.Font = Enum.Font.GothamBold
noclipLabel.TextSize = 18 * scale
noclipLabel.TextColor3 = Color3.fromRGB(230, 230, 235)
noclipLabel.BackgroundTransparency = 1
noclipLabel.TextXAlignment = Enum.TextXAlignment.Left

local noclipToggle = Instance.new("TextButton", noclipSection)
noclipToggle.Size = UDim2.new(0, 60 * scale, 0, 26 * scale)
noclipToggle.Position = UDim2.new(1, -65, 0, 0)
noclipToggle.Text = "OFF"
noclipToggle.Font = Enum.Font.GothamSemibold
noclipToggle.TextSize = 14 * scale
noclipToggle.TextColor3 = Color3.fromRGB(160, 160, 165)
noclipToggle.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
Instance.new("UICorner", noclipToggle).CornerRadius = UDim.new(0, 6 * scale)

noclipToggle.Position = UDim2.new(1, -65, 0, 0)
noclipSection.Size = UDim2.new(1, 0, 0, 40)
noclipSection.Parent = container

-- Logic
local dragging = {speed = false, jump = false}
local minSpeed, maxSpeed = 16, 150
local minJump, maxJump = 50, 200

local function setSlider(inputX, target)
	local slider = target == "speed" and speedSlider or jumpSlider
	local fill = target == "speed" and speedFill or jumpFill
	local label = target == "speed" and speedLabel or jumpLabel
	local minVal = target == "speed" and minSpeed or minJump
	local maxVal = target == "speed" and maxJump or maxJump

	local rel = math.clamp((inputX - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
	local value = math.floor(minVal + (maxVal - minVal) * rel)
	fill.Size = UDim2.new(rel, 0, 1, 0)

	if target == "speed" then
		currentSpeed = value
		label.Text = "Speed: " .. value
	else
		currentJump = value
		label.Text = "Jump: " .. value
	end
end

speedSlider.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging.speed = true
		setSlider(input.Position.X, "speed")
	end
end)

jumpSlider.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging.jump = true
		setSlider(input.Position.X, "jump")
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		if dragging.speed then setSlider(input.Position.X, "speed") end
		if dragging.jump then setSlider(input.Position.X, "jump") end
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging.speed = false
		dragging.jump = false
	end
end)

speedToggle.MouseButton1Click:Connect(function()
	speedEnabled = not speedEnabled
	speedToggle.Text = speedEnabled and "ON" or "OFF"
	speedToggle.TextColor3 = speedEnabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(160, 160, 165)
end)

jumpToggle.MouseButton1Click:Connect(function()
	jumpEnabled = not jumpEnabled
	jumpToggle.Text = jumpEnabled and "ON" or "OFF"
	jumpToggle.TextColor3 = jumpEnabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(160, 160, 165)
end)

local noclipEnabled = false
noclipToggle.MouseButton1Click:Connect(function()
	noclipEnabled = not noclipEnabled
	noclipToggle.Text = noclipEnabled and "ON" or "OFF"
	noclipToggle.TextColor3 = noclipEnabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(160, 160, 165)
end)

RunService.Stepped:Connect(function()
	if noclipEnabled then
		local char = LocalPlayer.Character
		if char then
			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") and part.CanCollide then
					part.CanCollide = false
				end
			end
		end
	end
end)

RunService.RenderStepped:Connect(function()
	local char = LocalPlayer.Character
	if char then
		local hum = char:FindFirstChild("Humanoid")
		if hum then
			if speedEnabled then hum.WalkSpeed = currentSpeed else hum.WalkSpeed = defaultSpeed end
			if jumpEnabled then
				hum.UseJumpPower = true
				hum.JumpPower = currentJump
			else
				hum.JumpPower = defaultJump
			end
		end
	end
end)

UserInputService.InputBegan:Connect(function(input, processed)
	if not processed and input.KeyCode == Enum.KeyCode.Delete then
		local char = LocalPlayer.Character
		if char then
			local hum = char:FindFirstChild("Humanoid")
			if hum then
				hum.WalkSpeed = defaultSpeed
				hum.JumpPower = defaultJump
			end
		end
		gui:Destroy()
	end
end)

--== ESP Section ==--
local function createESP(player)
	if player == LocalPlayer then return end
	if player.Character and player.Character:FindFirstChild("Head") then
		local billboard = Instance.new("BillboardGui")
		billboard.Name = "ESP"
		billboard.Adornee = player.Character.Head
		billboard.Size = UDim2.new(0, 100 * scale, 0, 40 * scale)
		billboard.StudsOffset = Vector3.new(0, 2, 0)
		billboard.AlwaysOnTop = true

		local label = Instance.new("TextLabel", billboard)
		label.Size = UDim2.new(1, 0, 1, 0)
		label.BackgroundTransparency = 1
		label.Text = player.Name
		label.TextColor3 = Color3.fromRGB(255, 255, 0)
		label.TextStrokeTransparency = 0.5
		label.TextScaled = true
		label.Font = Enum.Font.GothamSemibold

		billboard.Parent = player.Character

		local highlight = Instance.new("Highlight")
		highlight.Name = "ESP_HIGHLIGHT"
		highlight.FillColor = (player.Team == LocalPlayer.Team)
			and Color3.fromRGB(0, 170, 255)
			or Color3.fromRGB(255, 0, 0)
		highlight.OutlineColor = Color3.new(1, 1, 1)
		highlight.FillTransparency = 0.5
		highlight.OutlineTransparency = 0
		highlight.Adornee = player.Character
		highlight.Parent = player.Character
	end
end


local function removeESP(player)
	if player.Character then
		for _, v in ipairs(player.Character:GetDescendants()) do
			if v:IsA("BillboardGui") and v.Name == "ESP" then
				v:Destroy()
			elseif v:IsA("Highlight") and v.Name == "ESP_HIGHLIGHT" then
				v:Destroy()
			end
		end
	end
end

local espEnabled = false
local espConnections = {}

local espSection = Instance.new("Frame")
espSection.Size = UDim2.new(1, 0, 0, 40)
espSection.BackgroundTransparency = 1

local espLabel = Instance.new("TextLabel", espSection)
espLabel.Size = UDim2.new(0.7, 0 * scale, 0, 20 * scale)
espLabel.Position = UDim2.new(0, 0 * scale, 0, 0 * scale)
espLabel.Text = "ESP"
espLabel.Font = Enum.Font.GothamBold
espLabel.TextSize = 18 * scale
espLabel.TextColor3 = Color3.fromRGB(230, 230, 235)
espLabel.BackgroundTransparency = 1
espLabel.TextXAlignment = Enum.TextXAlignment.Left

local espToggle = Instance.new("TextButton", espSection)
espToggle.Size = UDim2.new(0, 60 * scale, 0, 26 * scale)
espToggle.Position = UDim2.new(1, -65, 0, 0)
espToggle.Text = "OFF"
espToggle.Font = Enum.Font.GothamSemibold
espToggle.TextSize = 14 * scale
espToggle.TextColor3 = Color3.fromRGB(160, 160, 165)
espToggle.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
Instance.new("UICorner", espToggle).CornerRadius = UDim.new(0, 6 * scale)

espSection.Parent = container

espToggle.MouseButton1Click:Connect(function()
	espEnabled = not espEnabled
	espToggle.Text = espEnabled and "ON" or "OFF"
	espToggle.TextColor3 = espEnabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(160, 160, 165)

	if espEnabled then
		for _, plr in ipairs(Players:GetPlayers()) do
			createESP(plr)
		end
		table.insert(espConnections, Players.PlayerAdded:Connect(function(plr)
			plr.CharacterAdded:Connect(function()
				if espEnabled then createESP(plr) end
			end)
		end))
		table.insert(espConnections, Players.PlayerRemoving:Connect(function(plr)
			removeESP(plr)
		end))
	else
		for _, plr in ipairs(Players:GetPlayers()) do
			removeESP(plr)
		end
		for _, conn in ipairs(espConnections) do
			if conn then conn:Disconnect() end
		end
		table.clear(espConnections)
	end
end)


-- Loop to refresh ESP highlights for new characters or respawned players
RunService.RenderStepped:Connect(function()
	if espEnabled then
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= LocalPlayer and plr.Character and not plr.Character:FindFirstChild("ESP_HIGHLIGHT") then
				createESP(plr)
			end
		end
	end
end)

--== FOV Aimbot Section ==--
local fovEnabled = false
local fovRadius = 150

local fovSection = Instance.new("Frame")
fovSection.Size = UDim2.new(1, 0, 0, 80)
fovSection.BackgroundTransparency = 1

local fovLabel = Instance.new("TextLabel", fovSection)
fovLabel.Size = UDim2.new(0.7, 0 * scale, 0, 20 * scale)
fovLabel.Position = UDim2.new(0, 0 * scale, 0, 0 * scale)
fovLabel.Text = "FOV Aimbot"
fovLabel.Font = Enum.Font.GothamBold
fovLabel.TextSize = 18 * scale
fovLabel.TextColor3 = Color3.fromRGB(230, 230, 235)
fovLabel.BackgroundTransparency = 1
fovLabel.TextXAlignment = Enum.TextXAlignment.Left

local fovToggle = Instance.new("TextButton", fovSection)
fovToggle.Size = UDim2.new(0, 60 * scale, 0, 26 * scale)
fovToggle.Position = UDim2.new(1, -65, 0, 0)
fovToggle.Text = "OFF"
fovToggle.Font = Enum.Font.GothamSemibold
fovToggle.TextSize = 14 * scale
fovToggle.TextColor3 = Color3.fromRGB(160, 160, 165)
fovToggle.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
Instance.new("UICorner", fovToggle).CornerRadius = UDim.new(0, 6 * scale)

local fovValue = Instance.new("TextLabel", fovSection)
fovValue.Size = UDim2.new(0, 60 * scale, 0, 20 * scale)
fovValue.Position = UDim2.new(0, 0 * scale, 0, 25 * scale)
fovValue.Text = "Size: " .. fovRadius
fovValue.Font = Enum.Font.Gotham
fovValue.TextSize = 14 * scale
fovValue.TextColor3 = Color3.fromRGB(140, 140, 145)
fovValue.BackgroundTransparency = 1
fovValue.TextXAlignment = Enum.TextXAlignment.Left

local plusBtn = Instance.new("TextButton", fovSection)
plusBtn.Size = UDim2.new(0, 24 * scale, 0, 24 * scale)
plusBtn.Position = UDim2.new(1, -95, 0, 0)
plusBtn.Text = "+"
plusBtn.Font = Enum.Font.GothamBold
plusBtn.TextSize = 14 * scale
plusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
plusBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
Instance.new("UICorner", plusBtn).CornerRadius = UDim.new(1, 0)

local minusBtn = Instance.new("TextButton", fovSection)
minusBtn.Size = UDim2.new(0, 24 * scale, 0, 24 * scale)
minusBtn.Position = UDim2.new(1, -125, 0, 0)
minusBtn.Text = "-"
minusBtn.Font = Enum.Font.GothamBold
minusBtn.TextSize = 14 * scale
minusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minusBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
Instance.new("UICorner", minusBtn).CornerRadius = UDim.new(1, 0)

fovSection.Parent = container


local blockCheckEnabled = true

local blockCheckToggle = Instance.new("TextButton", fovSection)
blockCheckToggle.Size = UDim2.new(0, 130 * scale, 0, 26 * scale)
blockCheckToggle.Position = UDim2.new(0, 0 * scale, 0, 55 * scale)
blockCheckToggle.Text = "BlockCheck: ON"
blockCheckToggle.Font = Enum.Font.GothamSemibold
blockCheckToggle.TextSize = 14 * scale
blockCheckToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
blockCheckToggle.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
Instance.new("UICorner", blockCheckToggle).CornerRadius = UDim.new(0, 6 * scale)

blockCheckToggle.MouseButton1Click:Connect(function()
    blockCheckEnabled = not blockCheckEnabled
    blockCheckToggle.Text = "BlockCheck: " .. (blockCheckEnabled and "ON" or "OFF")
end)

--== PLAYER TELEPORT LIST UNDER BLOCKCHECK ==--
local playerListLabel = Instance.new("TextLabel")
playerListLabel.Size = UDim2.new(1, -10, 0, 20)
playerListLabel.Text = "ผู้เล่น (กดแล้ววาร์ป)"
playerListLabel.Font = Enum.Font.GothamBold
playerListLabel.TextSize = 18 * scale
playerListLabel.TextColor3 = Color3.fromRGB(230, 230, 235)
playerListLabel.BackgroundTransparency = 1
playerListLabel.TextXAlignment = Enum.TextXAlignment.Left
playerListLabel.LayoutOrder = 1000

local playerListScroll = Instance.new("ScrollingFrame")
playerListScroll.Size = UDim2.new(1, -10, 0, 95)
playerListScroll.CanvasSize = UDim2.new(0, 0 * scale, 0, 0 * scale)
playerListScroll.ScrollBarThickness = 6
playerListScroll.BackgroundTransparency = 1
playerListScroll.BorderSizePixel = 0
playerListScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
playerListScroll.ScrollBarImageColor3 = Color3.fromRGB(120, 120, 120)
playerListScroll.LayoutOrder = 1001

local layout = Instance.new("UIListLayout", playerListScroll)
layout.Padding = UDim.new(0, 4 * scale)
layout.SortOrder = Enum.SortOrder.LayoutOrder

local function createPlayerButton(player)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 30)
    btn.Text = player.Name
    btn.BackgroundTransparency = 1
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14 * scale
    btn.Parent = playerListScroll
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6 * scale)

    btn.MouseButton1Click:Connect(function()
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root then
                root.CFrame = char.HumanoidRootPart.CFrame + Vector3.new(0, 5, 0)
            end
        end
    end)
end

local function updatePlayerList()
    for _, child in ipairs(playerListScroll:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            createPlayerButton(player)
        end
    end
end

task.spawn(function()
    while gui and gui.Parent do
        updatePlayerList()
        task.wait(2)
    end
end)

playerListLabel.Parent = container
playerListScroll.Parent = container



local function updatePlayerList()
    for _, child in ipairs(playerListScroll:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            createPlayerButton(player)
        end
    end
end

task.spawn(function()
    while gui and gui.Parent do
        updatePlayerList()
        task.wait(2)
    end
end)



-- FOV Circle Drawing
local fovCircle = Drawing.new("Circle")
fovCircle.Visible = false
fovCircle.Color = Color3.fromRGB(0, 255, 0)
fovCircle.Thickness = 1
fovCircle.NumSides = 64
fovCircle.Filled = false
fovCircle.Radius = fovRadius

RunService.RenderStepped:Connect(function()
	local viewport = workspace.CurrentCamera.ViewportSize
	fovCircle.Position = Vector2.new(viewport.X/2, viewport.Y/2)
	fovCircle.Radius = fovRadius
	fovCircle.Visible = fovEnabled
end)

-- Toggle FOV
fovToggle.MouseButton1Click:Connect(function()
	fovEnabled = not fovEnabled
	fovToggle.Text = fovEnabled and "ON" or "OFF"
	fovToggle.TextColor3 = fovEnabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(160, 160, 165)
end)

plusBtn.MouseButton1Click:Connect(function()
	fovRadius = math.clamp(fovRadius + 10, 10, 500)
	fovValue.Text = "Size: " .. fovRadius
end)

minusBtn.MouseButton1Click:Connect(function()
	fovRadius = math.clamp(fovRadius - 10, 10, 500)
	fovValue.Text = "Size: " .. fovRadius
end)


local camera = workspace.CurrentCamera

-- Lock-on system: track head in FOV circle (partially) within 1000 studs
local function getClosestTargetInFOV()
    local closest = nil
    local shortestDist = math.huge
    local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team then -- ไม่ล็อกทีมเดียวกัน
            if player.Character and player.Character:FindFirstChild("Head") and player.Character:FindFirstChild("Humanoid") then
                if player.Character.Humanoid.Health > 0 then -- ไม่ล็อกถ้าเลือดหมด
                    local head = player.Character.Head
                    local headPos = head.Position
                    local dist3D = (headPos - camera.CFrame.Position).Magnitude
                    if dist3D <= 1000 then
                        local screenPoint, onScreen = camera:WorldToViewportPoint(headPos)
                        if onScreen then
                            local origin = camera.CFrame.Position
                            local direction = (headPos - origin)
                            local raycastParams = RaycastParams.new()
                            raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
                            raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
                            if blockCheckEnabled then
                                local result = workspace:Raycast(origin, direction, raycastParams)
                                if result and not result.Instance:IsDescendantOf(player.Character) then
                                    continue
                                end
                            end
                            local dist2D = (Vector2.new(screenPoint.X, screenPoint.Y) - center).Magnitude
                            if dist2D <= fovRadius and dist2D < shortestDist then
                                shortestDist = dist2D
                                closest = head
                            end
                        end
                    end
                end
            end
        end
    end
    return closest
end

-- Lock character rotation toward closest valid head
RunService.RenderStepped:Connect(function()
    local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    fovCircle.Position = center
    fovCircle.Radius = fovRadius

    if fovEnabled then
        local target = getClosestTargetInFOV()
        if target then
            local camPos = camera.CFrame.Position
            local direction = (target.Position - camPos).Unit
            camera.CFrame = CFrame.lookAt(camPos, target.Position)
        end
    end
end)


--== Keybind for toggling FOV with "B" ==--
UserInputService.InputBegan:Connect(function(input, processed)
	if not processed and input.KeyCode == Enum.KeyCode.B then
		fovEnabled = not fovEnabled
		fovToggle.Text = fovEnabled and "ON" or "OFF"
		fovToggle.TextColor3 = fovEnabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(160, 160, 165)
	end
end)

-- ปุ่ม Toggle UI ใช้ icon ที่แสดงผลได้จริง
local toggleImageBtn = Instance.new("ImageButton", gui)
toggleImageBtn.Size = UDim2.new(0, 30, 0, 30)
toggleImageBtn.Position = UDim2.new(0, 20, 0, 20)
toggleImageBtn.Image = "rbxassetid://118284077656202"
toggleImageBtn.BackgroundTransparency = 1
toggleImageBtn.ImageTransparency = 0
toggleImageBtn.BorderSizePixel = 2
toggleImageBtn.BorderColor3 = Color3.fromRGB(0, 0, 0)

local corner = Instance.new("UICorner", toggleImageBtn)
corner.CornerRadius = UDim.new(0, 6)

local uiVisible = true
toggleImageBtn.MouseButton1Click:Connect(function()
	uiVisible = not uiVisible
	container.Visible = uiVisible
end)


--== HEALTH BAR ESP TOGGLE UI ==--
local healthEspEnabled = false

local healthEspToggle = Instance.new("TextButton", espSection)
healthEspToggle.Size = UDim2.new(0, 130 * scale, 0, 26 * scale)
healthEspToggle.Position = UDim2.new(0, 0, 1, -25 * scale)
healthEspToggle.Text = "Show Health: OFF"
healthEspToggle.Font = Enum.Font.Gotham
healthEspToggle.TextSize = 13 * scale
healthEspToggle.TextColor3 = Color3.fromRGB(200, 200, 200)
healthEspToggle.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
Instance.new("UICorner", healthEspToggle).CornerRadius = UDim.new(0, 5 * scale)

-- Function to create health bar for a player
local function createHealthBar(player)
    if player == LocalPlayer then return end
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
        if player.Character:FindFirstChild("HealthBarESP") then
            player.Character.HealthBarESP:Destroy()
        end

        local billboard = Instance.new("BillboardGui")
        billboard.Name = "HealthBarESP"
        billboard.Adornee = player.Character.HumanoidRootPart
        billboard.Size = UDim2.new(0, 4, 0, 40)
billboard.SizeOffset = Vector2.new(0, 0)
billboard.LightInfluence = 0
billboard.StudsOffset = Vector3.new(0, 0, 0)
billboard.MaxDistance = math.huge

        billboard.StudsOffset = Vector3.new(2, 0, 0)
        billboard.AlwaysOnTop = true

        local bgBar = Instance.new("Frame", billboard)
        bgBar.Size = UDim2.new(1, 0, 1, 0)
bgBar.BorderSizePixel = 0
        bgBar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        bgBar.BorderSizePixel = 0
        Instance.new("UICorner", bgBar).CornerRadius = UDim.new(0, 3)

        local fgBar = Instance.new("Frame", bgBar)
        fgBar.Name = "Fill"
        fgBar.Size = UDim2.new(1, 0, 1, 0)
fgBar.BorderSizePixel = 0
        fgBar.Position = UDim2.new(0, 0, 1, 0)
        fgBar.AnchorPoint = Vector2.new(0, 1)
        fgBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        fgBar.BorderSizePixel = 0
        Instance.new("UICorner", fgBar).CornerRadius = UDim.new(0, 3)

        billboard.Parent = player.Character

        task.spawn(function()
            while billboard and billboard.Parent and player.Character and player.Character:FindFirstChild("Humanoid") and healthEspEnabled do
                local hum = player.Character.Humanoid
                local hp = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                fgBar.Size = UDim2.new(1, 0, hp, 0)
                fgBar.BackgroundColor3 = hp < 0.5 and Color3.fromRGB(255, 165, 0) or Color3.fromRGB(0, 255, 0)
                task.wait(0.1)
            end
        end)
    end
end

-- Toggle handler
healthEspToggle.MouseButton1Click:Connect(function()
    healthEspEnabled = not healthEspEnabled
    healthEspToggle.Text = "Show Health: " .. (healthEspEnabled and "ON" or "OFF")

    if healthEspEnabled then
        for _, plr in ipairs(Players:GetPlayers()) do
            createHealthBar(plr)
        end
        table.insert(espConnections, Players.PlayerAdded:Connect(function(plr)
            plr.CharacterAdded:Connect(function()
                if healthEspEnabled then
                    task.wait(1)
                    createHealthBar(plr)
                end
            end)
        end))
    else
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr.Character and plr.Character:FindFirstChild("HealthBarESP") then
                plr.Character.HealthBarESP:Destroy()
            end
        end
    end
end)

-- Ensure refresh if new character spawned while toggle on
RunService.RenderStepped:Connect(function()
    if healthEspEnabled then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and not plr.Character:FindFirstChild("HealthBarESP") then
                createHealthBar(plr)
            end
        end
    end
end)
