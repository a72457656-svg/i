-- Delta iOS用 UIドラッグ完全復活版（シンプル・動くことを最優先）
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

wait(1.5)

local savedPositions = {}
local saveCounter = 0

local coreGui = game:GetService("CoreGui")

-- ==================== トグルボタン 35×35 ====================
local toggleGui = Instance.new("ScreenGui")
toggleGui.ResetOnSpawn = false
toggleGui.IgnoreGuiInset = true
toggleGui.DisplayOrder = 10000000
toggleGui.Parent = coreGui

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 35, 0, 35)
toggleButton.Position = UDim2.new(0, 15, 0, 15)
toggleButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
toggleButton.Text = "📍"
toggleButton.TextScaled = true
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextColor3 = Color3.new(1, 1, 1)
toggleButton.Parent = toggleGui

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(1, 0)
toggleCorner.Parent = toggleButton

-- ==================== メインUI 200×200 ====================
local mainGui = Instance.new("ScreenGui")
mainGui.ResetOnSpawn = false
mainGui.IgnoreGuiInset = true
mainGui.DisplayOrder = 999999
mainGui.Parent = coreGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 200, 0, 200)
mainFrame.Position = UDim2.new(0, 30, 0.25, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = mainGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = mainFrame

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
titleBar.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 1, 0)
title.BackgroundTransparency = 1
title.Text = "📍 テレポート"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = titleBar

local scrollingFrame = Instance.new("ScrollingFrame")
scrollingFrame.Size = UDim2.new(1, -16, 1, -115)
scrollingFrame.Position = UDim2.new(0, 8, 0, 45)
scrollingFrame.BackgroundTransparency = 1
scrollingFrame.ScrollBarThickness = 4
scrollingFrame.Parent = mainFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 8)
listLayout.Parent = scrollingFrame

local fixSelfButton = Instance.new("TextButton")
fixSelfButton.Size = UDim2.new(1, -16, 0, 38)
fixSelfButton.Position = UDim2.new(0, 8, 1, -78)
fixSelfButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
fixSelfButton.Text = "現在地固定"
fixSelfButton.TextColor3 = Color3.new(1, 1, 1)
fixSelfButton.TextScaled = true
fixSelfButton.Font = Enum.Font.GothamSemibold
fixSelfButton.Parent = mainFrame

local fixPlayerButton = Instance.new("TextButton")
fixPlayerButton.Size = UDim2.new(1, -16, 0, 38)
fixPlayerButton.Position = UDim2.new(0, 8, 1, -35)
fixPlayerButton.BackgroundColor3 = Color3.fromRGB(0, 200, 120)
fixPlayerButton.Text = "プレイヤー固定"
fixPlayerButton.TextColor3 = Color3.new(1, 1, 1)
fixPlayerButton.TextScaled = true
fixPlayerButton.Font = Enum.Font.GothamSemibold
fixPlayerButton.Parent = mainFrame

-- ==================== シンプルドラッグ機能（動くことを最優先） ====================

-- メインUIドラッグ
local draggingMain = false
local dragStartMain
local startPosMain

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingMain = true
        dragStartMain = input.Position
        startPosMain = mainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingMain and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStartMain
        mainFrame.Position = UDim2.new(startPosMain.X.Scale, startPosMain.X.Offset + delta.X, startPosMain.Y.Scale, startPosMain.Y.Offset + delta.Y)
    end
end)

titleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingMain = false
    end
end)

-- トグルボタンドラッグ
local draggingToggle = false
local dragStartToggle
local startPosToggle

toggleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingToggle = true
        dragStartToggle = input.Position
        startPosToggle = toggleButton.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingToggle and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStartToggle
        toggleButton.Position = UDim2.new(startPosToggle.X.Scale, startPosToggle.X.Offset + delta.X, startPosToggle.Y.Scale, startPosToggle.Y.Offset + delta.Y)
    end
end)

toggleButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingToggle = false
    end
end)

-- ==================== 表示/非表示 ====================
local visible = true
toggleButton.MouseButton1Click:Connect(function()
    visible = not visible
    mainFrame.Visible = visible
    toggleButton.Text = visible and "📍" or "🔼"
end)

-- ==================== 位置ボタン作成 ====================
local function createTeleportButton(name, cframe)
    local item = Instance.new("Frame")
    item.Size = UDim2.new(1, 0, 0, 48)
    item.BackgroundTransparency = 1
    item.Parent = scrollingFrame

    local tpBtn = Instance.new("TextButton")
    tpBtn.Size = UDim2.new(0.65, 0, 1, 0)
    tpBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    tpBtn.Text = "→ " .. name
    tpBtn.TextColor3 = Color3.new(1, 1, 1)
    tpBtn.TextXAlignment = Enum.TextXAlignment.Left
    tpBtn.TextScaled = true
    tpBtn.Font = Enum.Font.Gotham
    tpBtn.Parent = item

    local editBtn = Instance.new("TextButton")
    editBtn.Size = UDim2.new(0.17, 0, 1, 0)
    editBtn.Position = UDim2.new(0.65, 0, 0, 0)
    editBtn.BackgroundColor3 = Color3.fromRGB(255, 160, 0)
    editBtn.Text = "✏️"
    editBtn.TextScaled = true
    editBtn.Font = Enum.Font.GothamBold
    editBtn.TextColor3 = Color3.new(1, 1, 1)
    editBtn.Parent = item

    local delBtn = Instance.new("TextButton")
    delBtn.Size = UDim2.new(0.17, 0, 1, 0)
    delBtn.Position = UDim2.new(0.82, 0, 0, 0)
    delBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    delBtn.Text = "🗑"
    delBtn.TextScaled = true
    delBtn.Font = Enum.Font.GothamBold
    delBtn.TextColor3 = Color3.new(1, 1, 1)
    delBtn.Parent = item

    tpBtn.MouseButton1Click:Connect(function()
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = savedPositions[name]
            print("✅ " .. name)
        end
    end)

    editBtn.MouseButton1Click:Connect(function()
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            savedPositions[name] = char.HumanoidRootPart.CFrame
            print("✏️ " .. name .. " の座標を変更しました！")
        end
    end)

    delBtn.MouseButton1Click:Connect(function()
        item:Destroy()
        savedPositions[name] = nil
        print("🗑 " .. name .. " を削除")
    end)
end

-- ==================== 現在地を固定 ====================
fixSelfButton.MouseButton1Click:Connect(function()
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        saveCounter = saveCounter + 1
        local name = "固定位置 " .. saveCounter
        savedPositions[name] = hrp.CFrame
        createTeleportButton(name, savedPositions[name])
        print("📍 " .. name .. " を保存しました！")
    end
end)

-- ==================== プレイヤー選択UI 150×150 ====================
fixPlayerButton.MouseButton1Click:Connect(function()
    local playerList = Players:GetPlayers()
    if #playerList <= 1 then
        print("他のプレイヤーがいません")
        return
    end

    local selGui = Instance.new("ScreenGui")
    selGui.ResetOnSpawn = false
    selGui.DisplayOrder = 1000000
    selGui.Parent = coreGui

    local selFrame = Instance.new("Frame")
    selFrame.Size = UDim2.new(0, 150, 0, 150)
    selFrame.Position = UDim2.new(0.5, -75, 0.5, -75)
    selFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    selFrame.Parent = selGui

    local selCorner = Instance.new("UICorner")
    selCorner.CornerRadius = UDim.new(0, 10)
    selCorner.Parent = selFrame

    local selTitle = Instance.new("TextLabel")
    selTitle.Size = UDim2.new(1, 0, 0, 30)
    selTitle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    selTitle.Text = "プレイヤー選択"
    selTitle.TextColor3 = Color3.new(1,1,1)
    selTitle.TextScaled = true
    selTitle.Font = Enum.Font.GothamBold
    selTitle.Parent = selFrame

    local selScroll = Instance.new("ScrollingFrame")
    selScroll.Size = UDim2.new(1, -12, 1, -68)
    selScroll.Position = UDim2.new(0, 6, 0, 35)
    selScroll.BackgroundTransparency = 1
    selScroll.Parent = selFrame

    local selLayout = Instance.new("UIListLayout")
    selLayout.Padding = UDim.new(0, 5)
    selLayout.Parent = selScroll

    for _, other in ipairs(playerList) do
        if other ~= player then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 30)
            btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            btn.Text = other.Name
            btn.TextColor3 = Color3.new(1,1,1)
            btn.TextScaled = true
            btn.Parent = selScroll

            btn.MouseButton1Click:Connect(function()
                local char = other.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    saveCounter = saveCounter + 1
                    local name = other.Name .. " " .. saveCounter
                    savedPositions[name] = char.HumanoidRootPart.CFrame
                    createTeleportButton(name, savedPositions[name])
                    print("📍 " .. name .. " を保存しました")
                end
                selGui:Destroy()
            end)
        end
    end

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(1, -12, 0, 28)
    closeBtn.Position = UDim2.new(0, 6, 1, -35)
    closeBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
    closeBtn.Text = "閉じる"
    closeBtn.TextColor3 = Color3.new(1,1,1)
    closeBtn.Parent = selFrame

    closeBtn.MouseButton1Click:Connect(function()
        selGui:Destroy()
    end)
end)

print("🎉 UIドラッグ完全復活版が起動しました！")
print("タイトルバーとトグルボタンをドラッグして動かしてみて")
print("カメラ操作中も意図的にドラッグすれば動くはずです")
