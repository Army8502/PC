
--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")

--// VARIABLES
local fovEnabled = false
local fovRadius = 150
local fovCircle = Drawing.new("Circle")
fovCircle.Visible = false
fovCircle.Color = Color3.fromRGB(0, 255, 0)
fovCircle.Thickness = 1
fovCircle.NumSides = 64
fovCircle.Filled = false

--// UI SETUP
local screenGui = Instance.new("ScreenGui", game.CoreGui)
screenGui.Name = "FOV_UI"



-- ปุ่มไอคอนแบบแยกที่ซ่อน UI ทั้งหมด ยกเว้นตัวเอง และจะไม่ซ่อนวง FOV ถ้าเปิดอยู่
local toggleImageBtn = Instance.new("ImageButton")
toggleImageBtn.Name = "MiniToggleBtn"
toggleImageBtn.Parent = screenGui
toggleImageBtn.Size = UDim2.new(0, 30, 0, 30)
toggleImageBtn.Position = UDim2.new(0, 20, 0, 20)
toggleImageBtn.Image = "rbxassetid://118284077656202"
toggleImageBtn.BackgroundTransparency = 1
toggleImageBtn.BorderSizePixel = 0

local corner = Instance.new("UICorner", toggleImageBtn)
corner.CornerRadius = UDim.new(0, 6)

local uiVisible = true

toggleImageBtn.MouseButton1Click:Connect(function()
    uiVisible = not uiVisible

    for _, child in pairs(screenGui:GetChildren()) do
        if child ~= toggleImageBtn and child:IsA("GuiObject") then
            child.Visible = uiVisible
        end
    end

    -- วง FOV จะไม่ถูกซ่อนถ้าเปิดใช้งานอยู่
    if fovCircle then
        fovCircle.Visible = fovEnabled or uiVisible
    end
end)



local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 200, 0, 280)
frame.Position = UDim2.new(0, 20, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0


--// AUTO UI SCALE (GROUP BASED)

-- Advanced scale based on screen size
local screen = camera.ViewportSize
local scale = 1
if screen.X < 700 then
    scale = 0.7
elseif screen.X < 900 then
    scale = 0.85
else
    scale = 1
end
local UIScaleFactor = scale


-- Adjust this to scale the whole UI group (1 = 100%, 1.5 = 150%, etc.)
local UIScaleFactor = (camera.ViewportSize.X < 800 or camera.ViewportSize.Y < 600) and 0.8 or 1

-- Add UIAspectRatioConstraint to avoid stretching
local function applyUIScaleGroup(baseFrame)
    local scale = Instance.new("UIScale")
    scale.Scale = UIScaleFactor
    scale.Parent = baseFrame
end

applyUIScaleGroup(frame)

-- ทำให้ UI หลักสามารถลากได้
frame.Active = true
frame.Draggable = true


-- Styling
local corner = Instance.new("UICorner", frame)
corner.CornerRadius = UDim.new(0, 10)

local stroke = Instance.new("UIStroke", frame)
stroke.Color = Color3.fromRGB(70, 70, 70)
stroke.Thickness = 1.2
stroke.Transparency = 0.3

local function styleButton(btn)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SourceSansBold
    btn.BorderSizePixel = 0

    local btnCorner = Instance.new("UICorner", btn)
    btnCorner.CornerRadius = UDim.new(0, 6)
end

local toggleBtn = Instance.new("TextButton", frame)
toggleBtn.Size = UDim2.new(0, 180, 0, 30)
toggleBtn.Position = UDim2.new(0, 10, 0, 10)
toggleBtn.Text = "FOV: OFF"
styleButton(toggleBtn)
toggleBtn.TextSize = 14

local sizeLabel = Instance.new("TextLabel", frame)
sizeLabel.Size = UDim2.new(0, 80, 0, 20)
sizeLabel.Position = UDim2.new(0, 10, 0, 50)
sizeLabel.Text = "Radius: " .. fovRadius
sizeLabel.BackgroundTransparency = 1
sizeLabel.TextColor3 = Color3.new(1, 1, 1)
sizeLabel.Font = Enum.Font.SourceSans
sizeLabel.TextSize = 14

local plusBtn = Instance.new("TextButton", frame)
plusBtn.Size = UDim2.new(0, 20, 0, 20)
plusBtn.Position = UDim2.new(0, 100, 0, 50)
plusBtn.Text = "+"
styleButton(plusBtn)
plusBtn.TextSize = 14

local minusBtn = Instance.new("TextButton", frame)
minusBtn.Size = UDim2.new(0, 20, 0, 20)
minusBtn.Position = UDim2.new(0, 125, 0, 50)
minusBtn.Text = "-"
styleButton(minusBtn)
minusBtn.TextSize = 14


--// BUTTON FUNCTIONS
toggleBtn.MouseButton1Click:Connect(function()
    fovEnabled = not fovEnabled
    toggleBtn.Text = fovEnabled and "FOV: ON" or "FOV: OFF"
    fovCircle.Visible = fovEnabled
end)

plusBtn.MouseButton1Click:Connect(function()
    fovRadius = math.clamp(fovRadius + 10, 50, 400)
    sizeLabel.Text = "Radius: " .. fovRadius
    fovCircle.Radius = fovRadius
end)

minusBtn.MouseButton1Click:Connect(function()
    fovRadius = math.clamp(fovRadius - 10, 50, 400)
    sizeLabel.Text = "Radius: " .. fovRadius
    fovCircle.Radius = fovRadius
end)

--// TARGET FUNCTION - GET CLOSEST ENEMY (UPDATED)
local function getClosestEnemy()
    local closestPlayer = nil
    local shortestDistance = fovRadius
    local center = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            for _, part in ipairs(player.Character:GetChildren()) do
                if part:IsA("BasePart") then
                    local screenPos, onScreen = camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local distance = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                        if distance < shortestDistance then
                            shortestDistance = distance
                            closestPlayer = player
                        end
                    end
                end
            end
        end
    end

    if closestPlayer and closestPlayer.Character and closestPlayer.Character:FindFirstChild("Head") then
        return closestPlayer.Character.Head
    end
    return nil
end

local function getClosestEnemyHead()
    local closest = nil
    local shortest = math.huge
    local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local head = player.Character.Head
            local screenPos, onScreen = camera:WorldToViewportPoint(head.Position)
            if onScreen then
                local distance = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                if distance < fovRadius and distance < shortest then  -- ตรวจสอบว่าอยู่ภายในวง FOV
                    shortest = distance
                    closest = head
                end
            end
        end
    end

    return closest
end

--// OVERRIDE GUN SYSTEM
local GunModule = require(game:GetService("ReplicatedStorage").Modules.Game.ItemTypes.Gun)
local OriginalCalculateBullet = GunModule.calculate_bullet_direction

GunModule.calculate_bullet_direction = function(self, lookVector)
    if fovEnabled then
        local target = getClosestEnemyHead()
        if target then
            local origin = camera.CFrame.Position
            local targetPos = target.Position
            local targetVel = target.Velocity
            local bulletSpeed = 9999 -- หรือดึงจาก tool:GetAttribute("BulletSpeed")

            local distance = (targetPos - origin).Magnitude
            local timeToTarget = distance / bulletSpeed
            local predictedPosition = targetPos + targetVel * timeToTarget

            return (predictedPosition - origin).Unit
        end
    end
    return OriginalCalculateBullet(self, lookVector)
end


-- OVERRIDE calculate_bullet_direction
local OriginalCalculateBullet = GunModule.calculate_bullet_direction
GunModule.calculate_bullet_direction = function(self, lookVector)
    if fovEnabled then
        local target = getClosestEnemyHead()
        if target then
            return (target.Position - camera.CFrame.Position).Unit
        end
    end
    return OriginalCalculateBullet(self, lookVector)
end

-- OVERRIDE gunshot FOR INSTANT HIT
local OriginalGunshot = GunModule.gunshot

GunModule.gunshot = function(tool, hitPos, normal, part)
    if fovEnabled then
        local target = getClosestEnemyHead()
        if target then
            local normalVec = Vector3.new(0, 1, 0)
            local dummyPart = target

            print("[INSTANT HIT] Triple shot at:", target.Parent.Name)

            for i = 1, 3 do
                task.delay((i - 1) * 0.05, function()
                    -- Offset เล็กน้อยเพื่อหลอกว่าเป็นกระสุนคนละนัด
                    local offset = Vector3.new(
                        math.random(-2, 2) * 0.90,
                        math.random(-2, 2) * 0.70,
                        math.random(-2, 2) * 1
                    )
                    local hitPosition = target.Position + offset

                    if i == 1 then
                        -- นัดแรก: ยิงปกติ เห็นเส้นกระสุน
                        OriginalGunshot(tool, hitPosition, normalVec, dummyPart)
                    else
                        -- นัดที่ 2-3: ยิงเงียบๆ ไม่มีเอฟเฟกต์
                        local gunData = require(ReplicatedStorage.Modules.Game.ItemTypes.Gun)[tool.Name]
                        Net.send("shoot_gun", tool, Camera.CFrame, { {
                            Instance = dummyPart,
                            Position = hitPosition,
                            Normal = normalVec,
                        } })

                        -- 🔇 ลบการเล่นเสียงออกเพื่อหลีกเลี่ยงการโหลด asset ที่ไม่อนุญาต
                        -- if gunData and gunData.FireSound then
                        --     local sound = tool:FindFirstChild(gunData.FireSound)
                        --     if sound then sound:Play() end
                        -- end
                    end
                end)
            end
            return
        end
    end

    -- ยิงปกติถ้าไม่ lock
    OriginalGunshot(tool, hitPos, normal, part)
end



--// MAIN LOOP
RunService.RenderStepped:Connect(function()
    local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    fovCircle.Position = center
    fovCircle.Radius = fovRadius
end)

-- Instant Bullet System Loop
task.spawn(function()
    while true do
        if fovEnabled then
            GunModule.calculate_bullet_direction = function(self, lookVector)
                local target = getClosestEnemyHead()
                if target then
                    local origin = camera.CFrame.Position
                    print("[INSTANT BULLET] Locking onto:", target.Parent.Name)
                    return (target.Position - origin).Unit
                end
                return lookVector
            end
        else
            GunModule.calculate_bullet_direction = OriginalCalculateBullet
        end
        task.wait(0.2)
    end
end)

--// DELETE TO CLOSE SCRIPT

-- Create the Toggle Row for Gun Settings
local function createGunToggleRow(labelText, defaultState, callback)
    local rowFrame = Instance.new("Frame")
    rowFrame.Size = UDim2.new(0, 180, 0, 30)
    rowFrame.BackgroundTransparency = 1

    local label = Instance.new("TextLabel", rowFrame)
    label.Size = UDim2.new(0, 120, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.Text = labelText
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.SourceSans
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left

    local toggleButton = Instance.new("TextButton", rowFrame)
    toggleButton.Size = UDim2.new(0, 25, 0, 25)
    toggleButton.Position = UDim2.new(1, -35, 0.5, -12)
    styleButton(toggleButton)
    toggleButton.TextSize = 20
    toggleButton.Text = ""  -- Start with empty text

    local state = defaultState
    toggleButton.MouseButton1Click:Connect(function()
        state = not state
        toggleButton.Text = state and "" or "●"  -- Toggle between empty and filled circle
        callback(state)
        LocalPlayer:SetAttribute(labelText .. "Enabled", state)
    end)

    LocalPlayer:SetAttribute(labelText .. "Enabled", defaultState)

    return rowFrame
end

-- Gun Toggles
local recoilState = LocalPlayer:GetAttribute("RecoilEnabled") or true
local reloadState = LocalPlayer:GetAttribute("ReloadEnabled") or true

local function setGunAttribute(attrName, value)
    task.spawn(function()
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local tool

        for i = 1, 30 do
            tool = char:FindFirstChildOfClass("Tool")
            if tool then break end
            task.wait(0.1)
        end

        if not tool then
            warn("[SAFE] No tool equipped. Cannot set attribute: " .. attrName)
            return
        end

        if tool:GetAttribute(attrName) ~= nil then
            tool:SetAttribute(attrName, value)
        else
            warn("[SAFE] Tool does not support attribute: " .. attrName)
        end
    end)
end


local recoilRow = createGunToggleRow("Recoil", recoilState, function(state)
    setGunAttribute("Recoil", state and 1 or 0)
end)
recoilRow.Position = UDim2.new(0, 10, 0, 90)
recoilRow.Parent = frame

local reloadRow = createGunToggleRow("Reload", reloadState, function(state)
    setGunAttribute("ReloadTime", state and 2 or 0)
end)
reloadRow.Position = UDim2.new(0, 10, 0, 130)
reloadRow.Parent = frame

-- ESP Toggle Row
local espBoxes = {}
local nameTags = {}
local espState = LocalPlayer:GetAttribute("ESPEnabled") or false  -- Make sure it starts as false by default

local function CreateESP(player)
    if player == LocalPlayer or espBoxes[player] or not player.Character then return end

    -- Create highlight for ESP
    local highlight = Instance.new("Highlight")
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.Adornee = player.Character
    highlight.Parent = player.Character
    espBoxes[player] = highlight

    -- Create name tag above player
    local head = player.Character:FindFirstChild("Head")
    if head then
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "ESP_NameTag"
        billboard.Adornee = head
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 2, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = head

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = player.Name
        label.TextColor3 = Color3.fromRGB(255, 255, 0)
        label.TextSize = 12
        label.Font = Enum.Font.GothamSemibold
        label.TextStrokeTransparency = 0.6
        label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        label.Parent = billboard

        nameTags[player] = billboard
    end
end

local function RemoveESP(player)
    if espBoxes[player] then
        espBoxes[player]:Destroy()
        espBoxes[player] = nil
    end
    if nameTags[player] then
        nameTags[player]:Destroy()
        nameTags[player] = nil
    end
end

local espLoopActive = false
local espLoopThread = nil

local function setESPEnabled(state)
    LocalPlayer:SetAttribute("ESPEnabled", state)

    if state then
        espLoopActive = true
        print("[ESP] เปิดใช้งาน ESP")
        if not espLoopThread then
            espLoopThread = task.spawn(function()
                print("[ESP] เริ่มลูป ESP แล้ว")

                while espLoopActive do
                    print("[ESP] ลูปล่าสุด: ตรวจสอบผู้เล่น...")
                    for _, player in ipairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer then
                            local char = player.Character
                            if char then
                                if not espBoxes[player] then
                                    print("[ESP] สร้าง ESP ให้กับ:", player.Name)
                                    CreateESP(player)
                                elseif espBoxes[player].Adornee ~= char then
                                    print("[ESP] รีเซ็ต ESP ให้กับ:", player.Name)
                                    RemoveESP(player)
                                    CreateESP(player)
                                end
                            end
                        end
                    end
                    task.wait(1)
                end

                print("[ESP] หยุดลูป ESP แล้ว")
                espLoopThread = nil
            end)
        end
    else
        espLoopActive = false
        print("[ESP] ปิดใช้งาน ESP - ลบ ESP ทั้งหมด")
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                RemoveESP(player)
            end
        end
    end
end


-- Create the ESP toggle row
local espRow = createGunToggleRow("ESP", espState, setESPEnabled)
espRow.Position = UDim2.new(0, 10, 0, 170)
espRow.Parent = frame

-- Update when a new player joins
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        if LocalPlayer:GetAttribute("ESPEnabled") then
            task.wait(1)
            CreateESP(player)
        end
    end)
end)

-- Remove ESP when a player leaves
Players.PlayerRemoving:Connect(RemoveESP)

--// Toggle ESP UI with N key
espRow.Position = UDim2.new(0, 10, 0, 170)
espRow.Parent = frame

task.spawn(function()
	while true do
		local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
		local tool = char:FindFirstChildOfClass("Tool")

		if tool then
			pcall(function()
				-- ✅ Force BulletSpeed (ทำให้กระสุนเร็วสุด)
				if tool:GetAttribute("BulletSpeed") == nil or tool:GetAttribute("BulletSpeed") < 9999 then
					tool:SetAttribute("BulletSpeed", 9999)
					print("[FORCE] BulletSpeed set to 9999 for", tool.Name)
				end

				-- ✅ Force ReloadTime (ยิงได้ต่อเนื่อง)
				if LocalPlayer:GetAttribute("ReloadEnabled") == false then
                    if tool:GetAttribute("ReloadTime") ~= 0 then
                        tool:SetAttribute("ReloadTime", 0)
                    end
                end

				-- ✅ Force Recoil (ไม่มีเด้ง)
				if LocalPlayer:GetAttribute("RecoilEnabled") == false then
                    if tool:GetAttribute("Recoil") ~= 0 then
                        tool:SetAttribute("Recoil", 0)
                    end
                end

				-- ✅ Force Range และ MaxDistance (ยิงได้ไกลมาก)
				if tool:GetAttribute("Range") ~= 9999 then
					tool:SetAttribute("Range", 9999)
					print("[FORCE] Range set to 9999 for", tool.Name)
				end
				if tool:GetAttribute("MaxDistance") ~= 9999 then
					tool:SetAttribute("MaxDistance", 9999)
					print("[FORCE] MaxDistance set to 9999 for", tool.Name)
				end
			end)
		end

		task.wait(0.5) -- ตรวจสอบทุกครึ่งวินาที
	end
end)



local function toggleGunRowState(attrName)
    local currentState = LocalPlayer:GetAttribute(attrName .. "Enabled")
    local newState = not currentState
    LocalPlayer:SetAttribute(attrName .. "Enabled", newState)

    -- เรียก callback ของ toggle จริง
    if attrName == "ESP" then
        setESPEnabled(newState)
    elseif attrName == "Recoil" then
        setGunAttribute("Recoil", newState and 1 or 0)
    elseif attrName == "Reload" then
        setGunAttribute("ReloadTime", newState and 2 or 0)
    end

    -- อัปเดตปุ่ม UI
    for _, child in ipairs(frame:GetChildren()) do
        if child:IsA("Frame") and child:FindFirstChildWhichIsA("TextButton") then
            local label = child:FindFirstChildWhichIsA("TextLabel")
            local btn = child:FindFirstChildWhichIsA("TextButton")
            if label and label.Text == attrName then
                btn.Text = newState and "●" or ""  -- Update button text for ESP, Recoil, Reload
            end
        end
    end
end


UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    local key = input.KeyCode

    if key == Enum.KeyCode.Delete then
        screenGui:Destroy()
        fovCircle:Remove()

    elseif key == Enum.KeyCode.N then
        toggleGunRowState("ESP")  -- เรียกใช้งาน toggleGunRowState ที่นี่

    elseif key == Enum.KeyCode.M then
        screenGui.Enabled = not screenGui.Enabled

    elseif key == Enum.KeyCode.B then
        fovEnabled = not fovEnabled
        toggleBtn.Text = fovEnabled and "FOV: ON" or "FOV: OFF"
        fovCircle.Visible = fovEnabled
    end
end) 



-- Define variables for the ReplicatedStorage modules
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RagdollModule = require(ReplicatedStorage.Modules.Game.Ragdoll)

-- Set up a function to log info in the output window (F9)
local function logInfo(message)
    print("[Ragdoll Hack] " .. message)
end

local function getRandomDirection()
    -- Randomly generate a force vector in 3D space (X, Y, Z)
    -- แบบหมุนกระเด็นเวียนๆ
    local angle = math.rad(math.random(0, 360))
    local forceMagnitude = 400
    local randomX = math.cos(angle) * forceMagnitude
    local randomZ = math.sin(angle) * forceMagnitude
    local randomY = math.random(10, 60)

    -- Create a Vector3 with the random values
    return Vector3.new(randomX, randomY, randomZ)
end

-- Variable to track whether the auto-ragdoll is enabled or disabled
local isAutoRagdollEnabled = false
local isRagdollActive = false  -- Track whether the ragdoll feature is currently active

-- Function to perform Hyper-Ragdoll Kill
local function hyperRagdollKill()
    -- Find all characters in the game
    local characters = game:GetService("Players"):GetPlayers()
    for _, player in ipairs(characters) do
        -- Ensure the player isn't yourself
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local humanoidRoot = player.Character.HumanoidRootPart
            -- Apply a random force vector (with higher force for faster movement)
            local randomForce = getRandomDirection()
            humanoidRoot:ApplyImpulse(randomForce)
            
            -- Log the action to the output
            logInfo("Hyper-Ragdoll Kill executed on " .. player.Name)
        end
    end
end

-- Function to check player health and enable/disable auto ragdoll based on health
local function checkPlayerHealthAndToggleAuto(player)
    local health = player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health

    if health and health < 35 then
        if not isAutoRagdollEnabled then
            logInfo(player.Name .. "'s health is low (" .. health .. "), enabling auto ragdoll.")
            isAutoRagdollEnabled = true
            -- When health is low, start ragdolling immediately
            hyperRagdollKill()
        end
    elseif health and health >= 35 then
        if isAutoRagdollEnabled then
            logInfo(player.Name .. "'s health is sufficient (" .. health .. "), disabling auto ragdoll.")
            isAutoRagdollEnabled = false
        end
    end
end

-- Monitor health continuously while auto ragdoll is enabled
local function monitorAutoRagdoll()
    while true do
        -- Get the player in question (you can change this to any specific player)
        local player = game:GetService("Players").LocalPlayer
        if player and player.Character and player.Character:FindFirstChild("Humanoid") then
            local humanoid = player.Character.Humanoid
            -- If the player's health goes below 30, continue triggering hyper ragdoll
            if humanoid.Health < 35 then
                -- Perform hyper ragdoll kill every 1 second
                hyperRagdollKill()
            end
        end
        wait(0.01)  -- Increase the frequency of the check to 0.5 second for faster action
    end
end

-- Informing the user in the F9 output about what the button does
logInfo("Auto Hyper-Ragdoll จะทำงานทันทีเมื่อโหลดสคริปต์ และจะตรวจสอบเลือดตลอดเวลา...")

-- Start monitoring health immediately when the script is loaded
task.spawn(monitorAutoRagdoll)

-- Optionally, if you still want to disable the feature with the 'Delete' key
game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Delete then
        -- Disable the feature
        logInfo("Hyper-Ragdoll Kill feature is now disabled.")
        isAutoRagdollEnabled = false
        isRagdollActive = false
    end
end)



--// JUMP POWER SLIDER UI
local jumpLabel = Instance.new("TextLabel", frame)
jumpLabel.Size = UDim2.new(0, 180, 0, 20)
jumpLabel.Position = UDim2.new(0, 10, 0, 210)
jumpLabel.Text = "Jump Power: 50"
jumpLabel.BackgroundTransparency = 1
jumpLabel.TextColor3 = Color3.new(1, 1, 1)
jumpLabel.Font = Enum.Font.SourceSans
jumpLabel.TextSize = 14

local jumpSlider = Instance.new("TextButton", frame)
jumpSlider.Size = UDim2.new(0, 180, 0, 6)
jumpSlider.Position = UDim2.new(0, 10, 0, 235)
jumpSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
jumpSlider.BorderSizePixel = 0

local sliderFill = Instance.new("Frame", jumpSlider)
sliderFill.Size = UDim2.new(0, 0, 1, 0)
sliderFill.Position = UDim2.new(0, 0, 0, 0)
sliderFill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
sliderFill.BorderSizePixel = 0

local dragging = false
local minPower, maxPower = 10, 65

local function updateJumpPower(x)
    local relativeX = math.clamp(x - jumpSlider.AbsolutePosition.X, 0, jumpSlider.AbsoluteSize.X)
    local percent = relativeX / jumpSlider.AbsoluteSize.X
    local jumpPower = math.floor(minPower + (maxPower - minPower) * percent)

    sliderFill.Size = UDim2.new(percent, 0, 1, 0)
    currentJump = jumpPower
    jumpLabel.Text = "Jump Power: " .. jumpPower

    local char = workspace:FindFirstChild(LocalPlayer.Name)
    if char and char:FindFirstChild("Humanoid") then
        if jumpEnabled then
        if jumpEnabled then
        
    end
    end
    end
end

jumpSlider.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        updateJumpPower(input.Position.X)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        updateJumpPower(input.Position.X)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)



local currentJump = defaultJump


-- ลูปเปลี่ยน JumpHeight ตามลูกเลื่อนเมื่อ ON
local jumpLoopActive = false
local jumpLoopThread = nil

local function startJumpLoop()
    if jumpLoopActive then return end
    jumpLoopActive = true
    jumpLoopThread = task.spawn(function()
        while jumpLoopActive do
            local char = workspace:FindFirstChild(LocalPlayer.Name)
            if char and char:FindFirstChild("Humanoid") and jumpEnabled then
                char.Humanoid.UseJumpPower = false
                char.Humanoid.JumpHeight = currentJump / 2
            end
            task.wait(0.1)
        end
    end)
end

local function stopJumpLoop()
    jumpLoopActive = false
    local char = workspace:FindFirstChild(LocalPlayer.Name)
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.UseJumpPower = false
        char.Humanoid.JumpHeight = defaultJump
    end
end


--// SUPER JUMP TOGGLE
local jumpEnabled = false
local defaultJump = 12

local jumpToggle = Instance.new("TextButton", frame)
jumpToggle.Size = UDim2.new(0, 180, 0, 25)
jumpToggle.Position = UDim2.new(0, 10, 0, 250)
jumpToggle.Text = "Jump: OFF"
styleButton(jumpToggle)
jumpToggle.TextSize = 14

jumpToggle.MouseButton1Click:Connect(function()
    jumpEnabled = not jumpEnabled
    jumpToggle.Text = jumpEnabled and "Jump: ON" or "Jump: OFF"

    local char = workspace:FindFirstChild(LocalPlayer.Name)
    if char and char:FindFirstChild("Humanoid") then
        if jumpEnabled then
            char.Humanoid.UseJumpPower = false
        char.Humanoid.JumpHeight = tonumber(jumpLabel.Text:match("%d+")) / 2
        else
            char.Humanoid.UseJumpPower = false
        char.Humanoid.JumpHeight = defaultJump / 2
        end
    end
end)
