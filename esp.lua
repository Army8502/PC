-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

-- UI Setup
local screenGui = Instance.new("ScreenGui", game.CoreGui)
screenGui.Name = "BackpackViewer"

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 300, 0, 200)
mainFrame.Position = UDim2.new(0, 20, 0, 100)
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainFrame.BorderSizePixel = 0
mainFrame.AnchorPoint = Vector2.new(0, 0)

-- Rounded corners for mainFrame
local mainCorner = Instance.new("UICorner", mainFrame)
mainCorner.CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, 0, 0, 36)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
title.BorderSizePixel = 0
title.Text = "🎒 Backpack Viewer"
title.TextColor3 = Color3.fromRGB(230, 230, 230)
title.TextSize = 18
title.Font = Enum.Font.SourceSansBold

-- Rounded corners for title
local titleCorner = Instance.new("UICorner", title)
titleCorner.CornerRadius = UDim.new(0, 12)

local listFrame = Instance.new("ScrollingFrame", mainFrame)
listFrame.Size = UDim2.new(1, -20, 1, -46)
listFrame.Position = UDim2.new(0, 10, 0, 46)
listFrame.BackgroundTransparency = 1
listFrame.BorderSizePixel = 0
listFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
listFrame.ScrollBarThickness = 6

local listLayout = Instance.new("UIListLayout", listFrame)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 6)

local activeBackpackUI

-- Debounce setup
local lastUpdateTime = 0
local UPDATE_INTERVAL = 0.5  -- seconds

-- Count items in a backpack (excluding "Fists")
local function countBackpackItems(backpack)
    local cnt = 0
    for _, item in ipairs(backpack:GetChildren()) do
        if item:IsA("Tool") and item.Name ~= "Fists" then
            cnt += 1
        end
    end
    return cnt
end

-- Emoji Map for specific items
local emojiMap = {
    -- Weapons
    ["M24"] = "🦌",
    ["C9"] = "🔫",
    ["Draco"] = "🔫",
    ["Uzi"] = "🔫",
    ["P226"] = "🔫",
    ["Double Barrel"] = "🔫",
    ["AK47"] = "🔫",
    ["Remington"] = "🔫",
    ["RPG"] = "🚀",
    ["MP5"] = "🔫",
    ["Glock"] = "🔫",
    ["Sawnoff"] = "🔫",
    ["Crossbow"] = "🏹",
    ["Hunting Rifle"] = "🦌",
    ["G3"] = "🔫",
    ["Anaconda"] = "🔫",

    -- Utility Items
    ["Soda Can"] = "🥤",
    ["Rock"] = "🗿",
    ["Mug"] = "🥛",
    ["Spray Can"] = "🧯",
    ["Molotov"] = "🍾🔥",
    ["Grenade"] = "💣",
    ["Jar"] = "🥫",
    ["Fire Cracker"] = "🧨",
    ["Dumbbell Plate"] = "🏋️",
    ["Cinder Block"] = "🧱",
    ["Brick"] = "🧱",
    ["Bowling Pin"] = "🎳",
    ["Milkshake"] = "🥤",
    ["Bottle"] = "🍾",
    ["Jerry Can"] = "🛢️",
    ["Glass"] = "🥛",
    ["Tomato"] = "🍅",

    -- Melee Weapons
    ["Silver Mop"] = "🧹", 
    ["Bronze Mop"] = "🧹",
    ["Diamond Mop"] = "🧹",
    ["Gold Mop"] = "🧹",
    ["Mop"] = "🧹",

    ["Baseball Bat"] = "🏏",
    ["Barbed Baseball Bat"] = "🏏",
    ["Bike Lock"] = "🔒",

    ["Axe"] = "🪓",
    ["Tactical Axe"] = "🪓",
    ["Combat Axe"] = "🪓",

    ["Switchblade"] = "🔪",
    ["Tactical Knife"] = "🗡️",
    ["Butcher Knife"] = "🔪",
    ["Machette"] = "🔪",
    ["Shank"] = "🗡️",

    ["Tactical Shovel"] = "⛏️",
    ["Rusty Shovel"] = "⚒️",
    ["Shovel"] = "🧹",

    ["Wrench"] = "🔧",
    ["Tire Iron"] = "🛠️",
    ["Sledge Hammer"] = "🛠️",
    ["Hammer"] = "🔨",
    ["Crowbar"] = "🔩",

    ["Taser"] = "⚡",
    ["Frying Pan"] = "🍳",
    ["Rolling Pin"] = "🌀",
    ["Pool Cue"] = "🎱",
    ["Chair Leg"] = "🪑",

    ["Wooden Board"] = "🥖",
    ["Nailed Wooden Board"] = "🥖",
    ["Metal Pipe"] = "📏",
    ["Metal Baseball Bat"] = "🥎",

    -- Medical Items
    ["Bandage"] = "🩹",
    ["First Aid Kit"] = "⛑️",
    ["Blood Bag"] = "🩸",
    ["Emergency Care Kit"] = "🚑",
    ["Pain Relief"] = "💊",
    ["Energy Shot"] = "💉",
    ["Pre Workout"] = "🏋️‍♂️⚡",
    ["Bull Energy"] = "🐂⚡",
    ["Monster X"] = "👹⚡",
    ["Energy Bar Max"] = "🍫⚡"
}
-- Show a player's backpack items in a curved UI
local function showBackpack(player)
    if activeBackpackUI then
        activeBackpackUI:Destroy()
        activeBackpackUI = nil
        return
    end

    local frame = Instance.new("Frame", screenGui)
    frame.Size = UDim2.new(0, 240, 0, 180)
    frame.Position = UDim2.new(0,
        mainFrame.AbsolutePosition.X + mainFrame.AbsoluteSize.X + 12,
        0,
        mainFrame.AbsolutePosition.Y
    )
    frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    frame.BorderSizePixel = 0

    -- Rounded corners
    local frameCorner = Instance.new("UICorner", frame)
    frameCorner.CornerRadius = UDim.new(0, 12)

    -- Title bar
    local titleBar = Instance.new("Frame", frame)
    titleBar.Size = UDim2.new(1, 0, 0, 36)
    titleBar.Position = UDim2.new(0, 0, 0, 0)
    titleBar.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
    titleBar.BorderSizePixel = 0

    local titleText = Instance.new("TextLabel", titleBar)
    titleText.Size = UDim2.new(1, -40, 1, 0)
    titleText.Position = UDim2.new(0, 12, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = "🎒 " .. player.Name .. "'s Items"
    titleText.TextColor3 = Color3.fromRGB(240, 240, 240)
    titleText.Font = Enum.Font.SourceSansBold
    titleText.TextSize = 16
    titleText.TextXAlignment = Enum.TextXAlignment.Left

    -- Close button (red X)
    local closeBtn = Instance.new("TextButton", titleBar)
    closeBtn.Size = UDim2.new(0, 28, 0, 28)
    closeBtn.Position = UDim2.new(1, -36, 0, 4)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Font = Enum.Font.SourceSansBold
    closeBtn.TextSize = 18

    -- Rounded corners for close button
    local closeCorner = Instance.new("UICorner", closeBtn)
    closeCorner.CornerRadius = UDim.new(0, 6)

    closeBtn.MouseButton1Click:Connect(function()
        frame:Destroy()
        activeBackpackUI = nil
    end)

    -- Items list
    local container = Instance.new("ScrollingFrame", frame)
    container.Size = UDim2.new(1, -20, 1, -46)
    container.Position = UDim2.new(0, 10, 0, 46)
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    container.ScrollBarThickness = 0  -- ปิดการเลื่อน
    container.CanvasSize = UDim2.new(0, 0, 0, 5 * 32) -- ตั้งขนาดคงที่สำหรับ 5 ไอเทม

    local itemLayout = Instance.new("UIListLayout", container)
    itemLayout.SortOrder = Enum.SortOrder.LayoutOrder
    itemLayout.Padding = UDim.new(0, 6)

    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        local idx = 0
        for _, item in ipairs(backpack:GetChildren()) do
            if item:IsA("Tool") and item.Name ~= "Fists" then
                idx += 1
                if idx > 5 then break end
                local lblFrame = Instance.new("Frame", container)
                lblFrame.Size = UDim2.new(1, 0, 0, 32)
                lblFrame.BackgroundColor3 = Color3.fromRGB(75, 75, 75)
                lblFrame.BorderSizePixel = 0

                local lblCorner = Instance.new("UICorner", lblFrame)
                lblCorner.CornerRadius = UDim.new(0, 8)

                local lbl = Instance.new("TextLabel", lblFrame)
                lbl.Size = UDim2.new(1, -12, 1, 0)
                lbl.Position = UDim2.new(0, 6, 0, 0)
                lbl.BackgroundTransparency = 1
                lbl.TextColor3 = Color3.fromRGB(245, 245, 245)
                lbl.Font = Enum.Font.SourceSans
                lbl.TextSize = 14

                -- ใช้ emoji จาก emojiMap
                local emoji = emojiMap[item.Name] or "🔹"  -- ถ้าไม่มีใน map จะใช้ลูกลอยแทน
                lbl.Text = emoji .. " " .. item.Name
                lbl.TextXAlignment = Enum.TextXAlignment.Left
            end
        end
    end

    activeBackpackUI = frame
end

-- Update function with debounce
local function tryUpdatePlayerList()
    local now = tick()
    if now - lastUpdateTime < UPDATE_INTERVAL then
        return
    end
    lastUpdateTime = now

    -- Clear old buttons
    for _, child in ipairs(listFrame:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    -- Create new buttons
    for _, player in ipairs(Players:GetPlayers()) do
        local backpack = player:FindFirstChild("Backpack")
        if backpack then
            local btn = Instance.new("TextButton", listFrame)
            btn.Size = UDim2.new(1, -20, 0, 36)
            btn.Position = UDim2.new(0, 0, 0, 0)
            btn.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
            btn.BorderSizePixel = 0
            btn.AutoButtonColor = true
            btn.TextColor3 = Color3.fromRGB(235, 235, 235)
            btn.Font = Enum.Font.SourceSansBold
            btn.TextSize = 14
            btn.Text = player.Name .. " (" .. countBackpackItems(backpack) .. ")"

            local btnCorner = Instance.new("UICorner", btn)
            btnCorner.CornerRadius = UDim.new(0, 8)

            btn.MouseButton1Click:Connect(function()
                showBackpack(player)
            end)

            backpack.ChildAdded:Connect(tryUpdatePlayerList)
            backpack.ChildRemoved:Connect(tryUpdatePlayerList)
            player.CharacterAdded:Connect(function(char)
                local humanoid = char:WaitForChild("Humanoid", 5)
                if humanoid then
                    humanoid.Died:Connect(function()
                        player.CharacterAdded:Wait()
                        tryUpdatePlayerList()
                    end)
                end
            end)
        end
    end

    listFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 12)
end

-- Connect player events
Players.PlayerAdded:Connect(tryUpdatePlayerList)
Players.PlayerRemoving:Connect(tryUpdatePlayerList)

-- Initial update
tryUpdatePlayerList()

-- Keyboard controls
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.M then
        mainFrame.Visible = not mainFrame.Visible
        if activeBackpackUI then
            activeBackpackUI.Visible = mainFrame.Visible
        end
    elseif input.KeyCode == Enum.KeyCode.Delete then
        screenGui:Destroy()
        script:Destroy()
    end
end)
