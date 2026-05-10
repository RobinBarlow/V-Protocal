-- CLEANUP
local function Cleanup()
    local targets = {game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")}
    pcall(function() table.insert(targets, gethui()) end)
    pcall(function() table.insert(targets, game:GetService("CoreGui")) end)
    for _, target in pairs(targets) do
        for _, v in pairs(target:GetChildren()) do
            if v:IsA("ScreenGui") and (v.Name:find("VProtocol") or v.Name:find("Kavo") or v.Name:find("VTaskbar")) then
                v:Destroy()
            end
        end
    end
end
Cleanup()

-- GLOBALS
getgenv().Toggles = {Cash = false, Rebirth = false, Chests = false, AutoBuy = false}
getgenv().SelectedItems = {}
local Remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")
local Parent = (gethui and gethui()) or game:GetService("CoreGui")

-- DATA LISTS
local cList = {"Chamber_Void","Chamber_Plasma","Chamber_Infernal","Chamber_Ruby","Chamber_Legendary","Chamber_Obsidian","Chamber_Epic","Chamber_Emerald","Chamber_Candy","Chamber_Ancient"}
local colList = {"Collector_Void","Collector_Plasma","Collector_Infernal","Collector_Astral","Collector_Epic","Collector_Legendary","Collector_Emerald","Collector_Radioactive","Collector_Candy","Collector_Ancient"}
local upList = {"Upgrader_Void","Upgrader_Plasma","Upgrader_Infernal","Upgrader_Legendary","Upgrader_Obsidian","Upgrader_Epic","Upgrader_Ruby","Upgrader_Rare","Upgrader_Candy","Upgrader_Ancient"}
local convList = {"Conveyor_Plasma","Conveyor_Astral","Conveyor_Obsidian","Conveyor_Infernal","Conveyor_Cybernetic","Conveyor_Radioactive","DownwardsConveyor_Astral","UpwardsConveyor_Ruby"}

-------------------------------------------------------------------------
-- HAUPT SCREENGUI
-------------------------------------------------------------------------
local sg = Instance.new("ScreenGui", Parent)
sg.Name = "VProtocolV5"
sg.ResetOnSpawn = false
sg.DisplayOrder = 99999

-------------------------------------------------------------------------
-- TASKBAR ICON (V-Button)
-------------------------------------------------------------------------
local taskbar = Instance.new("Frame", sg)
taskbar.Size = UDim2.new(0, 56, 0, 56)
taskbar.Position = UDim2.new(0, 20, 0.5, -28)
taskbar.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
taskbar.Visible = false
taskbar.Active = true
Instance.new("UICorner", taskbar).CornerRadius = UDim.new(0, 14)

local tbStroke = Instance.new("UIStroke", taskbar)
tbStroke.Color = Color3.fromRGB(0, 220, 120)
tbStroke.Thickness = 1.5

local tbLabel = Instance.new("TextLabel", taskbar)
tbLabel.Size = UDim2.new(1, 0, 1, 0)
tbLabel.BackgroundTransparency = 1
tbLabel.Text = "VP"
tbLabel.TextColor3 = Color3.fromRGB(0, 220, 120)
tbLabel.Font = Enum.Font.GothamBold
tbLabel.TextSize = 18

-- Drag + Click Logik
local tbDragging, tbDragStart, tbStartPos
taskbar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        tbDragging = true
        tbDragStart = input.Position
        tbStartPos = taskbar.Position
    end
end)
taskbar.InputChanged:Connect(function(input)
    if tbDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - tbDragStart
        taskbar.Position = UDim2.new(tbStartPos.X.Scale, tbStartPos.X.Offset + delta.X, tbStartPos.Y.Scale, tbStartPos.Y.Offset + delta.Y)
    end
end)
taskbar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local delta = input.Position - tbDragStart
        tbDragging = false
        if delta.Magnitude < 6 then
            taskbar.Visible = false
            sg.MainWindow.Visible = true
        end
    end
end)

-------------------------------------------------------------------------
-- HAUPTFENSTER
-------------------------------------------------------------------------
local main = Instance.new("Frame", sg)
main.Name = "MainWindow"
main.Size = UDim2.new(0, 560, 0, 380)
main.Position = UDim2.new(0.5, -280, 0.5, -190)
main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
main.BorderSizePixel = 0
main.Active = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 16)

local mainStroke = Instance.new("UIStroke", main)
mainStroke.Color = Color3.fromRGB(0, 180, 100)
mainStroke.Thickness = 1

-- Drag
local dragging, dragStart, startPos2
main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos2 = main.Position
    end
end)
main.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local d = input.Position - dragStart
        main.Position = UDim2.new(startPos2.X.Scale, startPos2.X.Offset + d.X, startPos2.Y.Scale, startPos2.Y.Offset + d.Y)
    end
end)
main.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

-------------------------------------------------------------------------
-- SIDEBAR
-------------------------------------------------------------------------
local sidebar = Instance.new("Frame", main)
sidebar.Size = UDim2.new(0, 130, 1, 0)
sidebar.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
sidebar.BorderSizePixel = 0
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 16)

-- Logo oben in Sidebar
local logo = Instance.new("TextLabel", sidebar)
logo.Size = UDim2.new(1, 0, 0, 55)
logo.Position = UDim2.new(0, 0, 0, 0)
logo.BackgroundTransparency = 1
logo.Text = "V · PROTO"
logo.TextColor3 = Color3.fromRGB(0, 220, 120)
logo.Font = Enum.Font.GothamBold
logo.TextSize = 13

local sideLayout = Instance.new("UIListLayout", sidebar)
sideLayout.Padding = UDim.new(0, 6)
sideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
Instance.new("UIPadding", sidebar).PaddingTop = UDim.new(0, 62)

-- X Button
local xBtn = Instance.new("TextButton", main)
xBtn.Size = UDim2.new(0, 36, 0, 36)
xBtn.Position = UDim2.new(1, -42, 0, 6)
xBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
xBtn.Text = "✕"
xBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
xBtn.Font = Enum.Font.GothamBold
xBtn.TextSize = 14
xBtn.BorderSizePixel = 0
Instance.new("UICorner", xBtn).CornerRadius = UDim.new(0, 8)

xBtn.MouseButton1Click:Connect(function()
    main.Visible = false
    taskbar.Visible = true
end)

-------------------------------------------------------------------------
-- CONTENT AREA
-------------------------------------------------------------------------
local content = Instance.new("Frame", main)
content.Size = UDim2.new(1, -145, 1, -15)
content.Position = UDim2.new(0, 138, 0, 8)
content.BackgroundTransparency = 1

-------------------------------------------------------------------------
-- TAB SYSTEM
-------------------------------------------------------------------------
local activePage = nil
local activeBtn = nil
local tabPages = {}

local function NewTab(icon, name)
    local btn = Instance.new("TextButton", sidebar)
    btn.Size = UDim2.new(0.82, 0, 0, 38)
    btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    btn.Text = icon .. "  " .. name
    btn.TextColor3 = Color3.fromRGB(140, 140, 140)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 12
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 9)
    Instance.new("UIPadding", btn).PaddingLeft = UDim.new(0, 10)

    local page = Instance.new("ScrollingFrame", content)
    page.Size = UDim2.new(1, 0, 1, 0)
    page.Visible = false
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 2
    page.ScrollBarImageColor3 = Color3.fromRGB(0, 200, 110)
    page.BorderSizePixel = 0
    local pl = Instance.new("UIListLayout", page)
    pl.Padding = UDim.new(0, 7)
    Instance.new("UIPadding", page).PaddingTop = UDim.new(0, 6)

    btn.MouseButton1Click:Connect(function()
        if activePage then activePage.Visible = false end
        if activeBtn then
            activeBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
            activeBtn.TextColor3 = Color3.fromRGB(140, 140, 140)
        end
        page.Visible = true
        btn.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        activePage = page
        activeBtn = btn
    end)

    tabPages[name] = {Page = page, Btn = btn}
    return page
end

-------------------------------------------------------------------------
-- TOGGLE & BUTTON & DROPDOWN COMPONENTS
-------------------------------------------------------------------------
local function NewSection(parent, text)
    local lbl = Instance.new("TextLabel", parent)
    lbl.Size = UDim2.new(1, -10, 0, 26)
    lbl.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
    lbl.Text = "  " .. text
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", lbl).CornerRadius = UDim.new(0, 7)
end

local function NewToggle(parent, text, callback)
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1, -10, 0, 42)
    row.BackgroundColor3 = Color3.fromRGB(17, 17, 17)
    row.BorderSizePixel = 0
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 10)

    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(1, -60, 1, 0)
    lbl.Position = UDim2.new(0, 14, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local pill = Instance.new("Frame", row)
    pill.Size = UDim2.new(0, 40, 0, 22)
    pill.Position = UDim2.new(1, -52, 0.5, -11)
    pill.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Instance.new("UICorner", pill).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame", pill)
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = UDim2.new(0, 3, 0.5, -8)
    knob.BackgroundColor3 = Color3.fromRGB(120, 120, 120)
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local active = false
    local ts = game:GetService("TweenService")

    local btn = Instance.new("TextButton", row)
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.MouseButton1Click:Connect(function()
        active = not active
        if active then
            ts:Create(pill, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(0, 200, 110)}):Play()
            ts:Create(knob, TweenInfo.new(0.15), {Position = UDim2.new(0, 21, 0.5, -8), BackgroundColor3 = Color3.fromRGB(255,255,255)}):Play()
        else
            ts:Create(pill, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
            ts:Create(knob, TweenInfo.new(0.15), {Position = UDim2.new(0, 3, 0.5, -8), BackgroundColor3 = Color3.fromRGB(120,120,120)}):Play()
        end
        callback(active)
    end)
end

local function NewButton(parent, text, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, -10, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(0, 160, 90)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 13
    btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
    btn.MouseButton1Click:Connect(function()
        game:GetService("TweenService"):Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(0, 120, 70)}):Play()
        task.delay(0.1, function()
            game:GetService("TweenService"):Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(0, 160, 90)}):Play()
        end)
        callback()
    end)
end

local function NewDropdown(parent, text, list, callback)
    local wrap = Instance.new("Frame", parent)
    wrap.Size = UDim2.new(1, -10, 0, 42)
    wrap.BackgroundColor3 = Color3.fromRGB(17, 17, 17)
    wrap.ClipsDescendants = true
    Instance.new("UICorner", wrap).CornerRadius = UDim.new(0, 10)

    local header = Instance.new("TextButton", wrap)
    header.Size = UDim2.new(1, 0, 0, 42)
    header.BackgroundTransparency = 1
    header.Text = "  ▾  " .. text
    header.TextColor3 = Color3.fromRGB(180, 180, 180)
    header.Font = Enum.Font.GothamSemibold
    header.TextSize = 12
    header.TextXAlignment = Enum.TextXAlignment.Left

    local open = false
    local itemFrames = {}

    for i, item in pairs(list) do
        local opt = Instance.new("TextButton", wrap)
        opt.Size = UDim2.new(1, 0, 0, 34)
        opt.Position = UDim2.new(0, 0, 0, 42 + (i-1)*34)
        opt.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
        opt.Text = "    " .. item
        opt.TextColor3 = Color3.fromRGB(160, 160, 160)
        opt.Font = Enum.Font.Gotham
        opt.TextSize = 11
        opt.TextXAlignment = Enum.TextXAlignment.Left
        opt.MouseButton1Click:Connect(function()
            callback(item)
            header.Text = "  ✓  " .. item
            header.TextColor3 = Color3.fromRGB(0, 220, 120)
            open = false
            game:GetService("TweenService"):Create(wrap, TweenInfo.new(0.15), {Size = UDim2.new(1, -10, 0, 42)}):Play()
        end)
        table.insert(itemFrames, opt)
    end

    header.MouseButton1Click:Connect(function()
        open = not open
        local targetH = open and (42 + #list * 34) or 42
        game:GetService("TweenService"):Create(wrap, TweenInfo.new(0.15), {Size = UDim2.new(1, -10, 0, targetH)}):Play()
    end)
end

-------------------------------------------------------------------------
-- TABS ERSTELLEN
-------------------------------------------------------------------------
local mainPage  = NewTab("⚡", "Main")
local shopPage  = NewTab("🛒", "Shop")
local playerPage = NewTab("👤", "Player")
local infoPage  = NewTab("ℹ", "Info")

-- Ersten Tab aktivieren
tabPages["Main"].Page.Visible = true
tabPages["Main"].Btn.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
tabPages["Main"].Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
activePage = tabPages["Main"].Page
activeBtn = tabPages["Main"].Btn

-------------------------------------------------------------------------
-- MAIN TAB
-------------------------------------------------------------------------
NewSection(mainPage, "Automation")

NewToggle(mainPage, "Auto Collect Cash", function(s)
    getgenv().Toggles.Cash = s
    task.spawn(function() while getgenv().Toggles.Cash do Remotes.MoveCash:FireServer() task.wait(0.2) end end)
end)

NewToggle(mainPage, "Auto Rebirth", function(s)
    getgenv().Toggles.Rebirth = s
    task.spawn(function() while getgenv().Toggles.Rebirth do Remotes.Rebirth:FireServer() task.wait(1) end end)
end)

NewToggle(mainPage, "Auto Pick Chests", function(s)
    getgenv().Toggles.Chests = s
end)
Remotes.ChestDrop.OnClientEvent:Connect(function(_, id)
    if getgenv().Toggles.Chests then Remotes.PickUpChest:FireServer(id) end
end)

-------------------------------------------------------------------------
-- SHOP TAB
-------------------------------------------------------------------------
NewSection(shopPage, "Multi-Select Shop")

NewDropdown(shopPage, "Chambers", cList, function(v) table.insert(getgenv().SelectedItems, v) end)
NewDropdown(shopPage, "Collectors", colList, function(v) table.insert(getgenv().SelectedItems, v) end)
NewDropdown(shopPage, "Upgraders", upList, function(v) table.insert(getgenv().SelectedItems, v) end)
NewDropdown(shopPage, "Conveyors", convList, function(v) table.insert(getgenv().SelectedItems, v) end)

NewSection(shopPage, "Auto Buy")

NewToggle(shopPage, "Enable Auto-Buy", function(s)
    getgenv().Toggles.AutoBuy = s
    task.spawn(function()
        while getgenv().Toggles.AutoBuy do
            for _, item in pairs(getgenv().SelectedItems) do
                if not getgenv().Toggles.AutoBuy then break end
                pcall(function() Remotes.MerchantBuyAll:FireServer(item) end)
                task.wait(0.1)
            end
            pcall(function() Remotes.Restock:FireServer() end)
            task.wait(1.5)
        end
    end)
end)

NewButton(shopPage, "Reset Selection", function()
    getgenv().SelectedItems = {}
end)

-------------------------------------------------------------------------
-- PLAYER TAB
-------------------------------------------------------------------------
NewSection(playerPage, "Player Info")

local plrLabel = Instance.new("TextLabel", playerPage)
plrLabel.Size = UDim2.new(1, -10, 0, 44)
plrLabel.BackgroundColor3 = Color3.fromRGB(17, 17, 17)
plrLabel.Text = "👤  " .. game.Players.LocalPlayer.Name
plrLabel.TextColor3 = Color3.fromRGB(0, 220, 120)
plrLabel.Font = Enum.Font.GothamBold
plrLabel.TextSize = 14
Instance.new("UICorner", plrLabel).CornerRadius = UDim.new(0, 10)

-------------------------------------------------------------------------
-- INFO TAB
-------------------------------------------------------------------------
NewSection(infoPage, "V-Protocol")

local verLabel = Instance.new("TextLabel", infoPage)
verLabel.Size = UDim2.new(1, -10, 0, 44)
verLabel.BackgroundColor3 = Color3.fromRGB(17, 17, 17)
verLabel.Text = "Version  v5.0  –  Modern UI"
verLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
verLabel.Font = Enum.Font.Gotham
verLabel.TextSize = 12
Instance.new("UICorner", verLabel).CornerRadius = UDim.new(0, 10)

print("V-Protocol V5 geladen!")
