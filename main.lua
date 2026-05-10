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
local TS = game:GetService("TweenService")

-- DATA LISTS
local cList = {"Chamber_Void","Chamber_Plasma","Chamber_Infernal","Chamber_Ruby","Chamber_Legendary","Chamber_Obsidian","Chamber_Epic","Chamber_Emerald","Chamber_Candy","Chamber_Ancient"}
local colList = {"Collector_Void","Collector_Plasma","Collector_Infernal","Collector_Astral","Collector_Epic","Collector_Legendary","Collector_Emerald","Collector_Radioactive","Collector_Candy","Collector_Ancient"}
local upList = {"Upgrader_Void","Upgrader_Plasma","Upgrader_Infernal","Upgrader_Legendary","Upgrader_Obsidian","Upgrader_Epic","Upgrader_Ruby","Upgrader_Rare","Upgrader_Candy","Upgrader_Ancient"}
local convList = {"Conveyor_Plasma","Conveyor_Astral","Conveyor_Obsidian","Conveyor_Infernal","Conveyor_Cybernetic","Conveyor_Radioactive","DownwardsConveyor_Astral","UpwardsConveyor_Ruby"}

-------------------------------------------------------------------------
-- SCREENGUI
-------------------------------------------------------------------------
local sg = Instance.new("ScreenGui", Parent)
sg.Name = "VProtocolV5"
sg.ResetOnSpawn = false
sg.DisplayOrder = 99999

-------------------------------------------------------------------------
-- TASKBAR ICON
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
tbLabel.Size = UDim2.new(1,0,1,0)
tbLabel.BackgroundTransparency = 1
tbLabel.Text = "VP"
tbLabel.TextColor3 = Color3.fromRGB(0, 220, 120)
tbLabel.Font = Enum.Font.GothamBold
tbLabel.TextSize = 18

local tbDragStart, tbStartPos, tbMoved
taskbar.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        tbDragStart = i.Position
        tbStartPos = taskbar.Position
        tbMoved = false
    end
end)
taskbar.InputChanged:Connect(function(i)
    if tbDragStart and i.UserInputType == Enum.UserInputType.MouseMovement then
        local d = i.Position - tbDragStart
        if d.Magnitude > 4 then tbMoved = true end
        taskbar.Position = UDim2.new(tbStartPos.X.Scale, tbStartPos.X.Offset+d.X, tbStartPos.Y.Scale, tbStartPos.Y.Offset+d.Y)
    end
end)
taskbar.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 and not tbMoved then
        taskbar.Visible = false
        sg.MainWindow.Visible = true
    end
    tbDragStart = nil
end)

-------------------------------------------------------------------------
-- HAUPTFENSTER
-------------------------------------------------------------------------
local main = Instance.new("Frame", sg)
main.Name = "MainWindow"
main.Size = UDim2.new(0, 580, 0, 400)
main.Position = UDim2.new(0.5, -290, 0.5, -200)
main.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
main.BorderSizePixel = 0
main.Active = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 16)
local mainStroke = Instance.new("UIStroke", main)
mainStroke.Color = Color3.fromRGB(0, 200, 110)
mainStroke.Thickness = 1

-- Drag
local dragStart2, startPos2
main.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        dragStart2 = i.Position
        startPos2 = main.Position
    end
end)
main.InputChanged:Connect(function(i)
    if dragStart2 and i.UserInputType == Enum.UserInputType.MouseMovement then
        local d = i.Position - dragStart2
        main.Position = UDim2.new(startPos2.X.Scale, startPos2.X.Offset+d.X, startPos2.Y.Scale, startPos2.Y.Offset+d.Y)
    end
end)
main.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then dragStart2 = nil end
end)

-------------------------------------------------------------------------
-- SIDEBAR
-------------------------------------------------------------------------
local sidebar = Instance.new("Frame", main)
sidebar.Size = UDim2.new(0, 120, 1, 0)
sidebar.Position = UDim2.new(0, 0, 0, 0)
sidebar.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
sidebar.BorderSizePixel = 0
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 16)

-- Sidebar rechte Seite abschneiden damit kein doppelter Radius
local sideClip = Instance.new("Frame", sidebar)
sideClip.Size = UDim2.new(0, 16, 1, 0)
sideClip.Position = UDim2.new(1, -16, 0, 0)
sideClip.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
sideClip.BorderSizePixel = 0

local sLogo = Instance.new("TextLabel", sidebar)
sLogo.Size = UDim2.new(1, 0, 0, 52)
sLogo.BackgroundTransparency = 1
sLogo.Text = "V·PROTO"
sLogo.TextColor3 = Color3.fromRGB(0, 220, 120)
sLogo.Font = Enum.Font.GothamBold
sLogo.TextSize = 13

local sideLayout = Instance.new("UIListLayout", sidebar)
sideLayout.Padding = UDim.new(0, 5)
sideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
Instance.new("UIPadding", sidebar).PaddingTop = UDim.new(0, 58)

-------------------------------------------------------------------------
-- X BUTTON (sauber, gut sichtbar)
-------------------------------------------------------------------------
local xBtn = Instance.new("TextButton", main)
xBtn.Size = UDim2.new(0, 32, 0, 32)
xBtn.Position = UDim2.new(1, -40, 0, 8)
xBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
xBtn.Text = "✕"
xBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
xBtn.Font = Enum.Font.GothamBold
xBtn.TextSize = 15
xBtn.BorderSizePixel = 0
xBtn.ZIndex = 10
Instance.new("UICorner", xBtn).CornerRadius = UDim.new(0, 8)
xBtn.MouseButton1Click:Connect(function()
    main.Visible = false
    taskbar.Visible = true
end)

-------------------------------------------------------------------------
-- CONTENT AREA
-------------------------------------------------------------------------
local content = Instance.new("Frame", main)
content.Size = UDim2.new(1, -135, 1, -12)
content.Position = UDim2.new(0, 128, 0, 6)
content.BackgroundTransparency = 1
content.ClipsDescendants = true

-------------------------------------------------------------------------
-- TAB SYSTEM
-------------------------------------------------------------------------
local activePage, activeBtn = nil, nil
local tabPages = {}

local function NewTab(icon, name)
    local btn = Instance.new("TextButton", sidebar)
    btn.Size = UDim2.new(0.84, 0, 0, 36)
    btn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    btn.Text = icon .. "  " .. name
    btn.TextColor3 = Color3.fromRGB(130, 130, 130)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 12
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 9)
    local bp = Instance.new("UIPadding", btn)
    bp.PaddingLeft = UDim.new(0, 10)

    local page = Instance.new("ScrollingFrame", content)
    page.Size = UDim2.new(1, 0, 1, 0)
    page.Position = UDim2.new(0, 0, 0, 0)
    page.Visible = false
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = Color3.fromRGB(0, 200, 110)
    page.BorderSizePixel = 0
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y

    local pl = Instance.new("UIListLayout", page)
    pl.Padding = UDim.new(0, 6)
    pl.SortOrder = Enum.SortOrder.LayoutOrder
    Instance.new("UIPadding", page).PaddingTop = UDim.new(0, 6)

    btn.MouseButton1Click:Connect(function()
        if activePage then activePage.Visible = false end
        if activeBtn then
            activeBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
            activeBtn.TextColor3 = Color3.fromRGB(130, 130, 130)
        end
        page.Visible = true
        btn.BackgroundColor3 = Color3.fromRGB(0, 170, 95)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        activePage = page
        activeBtn = btn
    end)

    tabPages[name] = {Page = page, Btn = btn}
    return page
end

-------------------------------------------------------------------------
-- KOMPONENTEN
-------------------------------------------------------------------------
local function NewSection(parent, text)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1, -8, 0, 28)
    f.BackgroundColor3 = Color3.fromRGB(0, 140, 75)
    f.BorderSizePixel = 0
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 7)
    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(1, -12, 1, 0)
    l.Position = UDim2.new(0, 10, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = text:upper()
    l.TextColor3 = Color3.fromRGB(255, 255, 255)
    l.Font = Enum.Font.GothamBold
    l.TextSize = 11
    l.TextXAlignment = Enum.TextXAlignment.Left
end

local function NewToggle(parent, text, callback)
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1, -8, 0, 44)
    row.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
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
    pill.Size = UDim2.new(0, 42, 0, 22)
    pill.Position = UDim2.new(1, -54, 0.5, -11)
    pill.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
    Instance.new("UICorner", pill).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame", pill)
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = UDim2.new(0, 3, 0.5, -8)
    knob.BackgroundColor3 = Color3.fromRGB(110, 110, 110)
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local active = false
    local clickArea = Instance.new("TextButton", row)
    clickArea.Size = UDim2.new(1, 0, 1, 0)
    clickArea.BackgroundTransparency = 1
    clickArea.Text = ""
    clickArea.ZIndex = 2
    clickArea.MouseButton1Click:Connect(function()
        active = not active
        if active then
            TS:Create(pill, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(0, 200, 110)}):Play()
            TS:Create(knob, TweenInfo.new(0.15), {Position = UDim2.new(0, 23, 0.5, -8), BackgroundColor3 = Color3.fromRGB(255,255,255)}):Play()
            lbl.TextColor3 = Color3.fromRGB(0, 220, 120)
        else
            TS:Create(pill, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(38, 38, 38)}):Play()
            TS:Create(knob, TweenInfo.new(0.15), {Position = UDim2.new(0, 3, 0.5, -8), BackgroundColor3 = Color3.fromRGB(110,110,110)}):Play()
            lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
        callback(active)
    end)
end

local function NewButton(parent, text, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, -8, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(0, 155, 85)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 13
    btn.AutoButtonColor = false
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
    btn.MouseButton1Click:Connect(function()
        TS:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(0, 110, 60)}):Play()
        task.delay(0.15, function()
            TS:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(0, 155, 85)}):Play()
        end)
        callback()
    end)
end

-- DROPDOWN: zeigt gewählte Items als Liste darunter
local function NewDropdown(parent, label, list, callback)
    -- Container wächst dynamisch
    local wrap = Instance.new("Frame", parent)
    wrap.Size = UDim2.new(1, -8, 0, 40)
    wrap.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    wrap.ClipsDescendants = false
    wrap.BorderSizePixel = 0
    Instance.new("UICorner", wrap).CornerRadius = UDim.new(0, 10)

    local header = Instance.new("TextButton", wrap)
    header.Size = UDim2.new(1, 0, 0, 40)
    header.BackgroundTransparency = 1
    header.Text = "▾   " .. label
    header.TextColor3 = Color3.fromRGB(180, 180, 180)
    header.Font = Enum.Font.GothamSemibold
    header.TextSize = 12
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.ZIndex = 3
    Instance.new("UIPadding", header).PaddingLeft = UDim.new(0, 12)

    -- Dropdown-Liste (schwebt über allem)
    local dropdown = Instance.new("Frame", sg) -- direkt in ScreenGui = immer oben
    dropdown.Size = UDim2.new(0, 290, 0, math.min(#list, 6) * 32 + 6)
    dropdown.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    dropdown.BorderSizePixel = 0
    dropdown.Visible = false
    dropdown.ZIndex = 1000
    Instance.new("UICorner", dropdown).CornerRadius = UDim.new(0, 10)
    Instance.new("UIStroke", dropdown).Color = Color3.fromRGB(0, 180, 100)

    local scroll = Instance.new("ScrollingFrame", dropdown)
    scroll.Size = UDim2.new(1, 0, 1, 0)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 3
    scroll.ScrollBarImageColor3 = Color3.fromRGB(0, 200, 110)
    scroll.CanvasSize = UDim2.new(0, 0, 0, #list * 32 + 6)
    scroll.ZIndex = 1000

    local dLayout = Instance.new("UIListLayout", scroll)
    dLayout.Padding = UDim.new(0, 2)
    Instance.new("UIPadding", scroll).PaddingTop = UDim.new(0, 3)

    for _, item in pairs(list) do
        local opt = Instance.new("TextButton", scroll)
        opt.Size = UDim2.new(1, -6, 0, 30)
        opt.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
        opt.Text = "  " .. item
        opt.TextColor3 = Color3.fromRGB(180, 180, 180)
        opt.Font = Enum.Font.Gotham
        opt.TextSize = 11
        opt.TextXAlignment = Enum.TextXAlignment.Left
        opt.BorderSizePixel = 0
        opt.ZIndex = 1001
        Instance.new("UICorner", opt).CornerRadius = UDim.new(0, 7)
        opt.MouseButton1Click:Connect(function()
            callback(item)
            header.Text = "✓   " .. item
            header.TextColor3 = Color3.fromRGB(0, 220, 120)
            dropdown.Visible = false
        end)
        opt.MouseEnter:Connect(function()
            TS:Create(opt, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(0, 140, 75)}):Play()
        end)
        opt.MouseLeave:Connect(function()
            TS:Create(opt, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(28, 28, 28)}):Play()
        end)
    end

    local open = false
    header.MouseButton1Click:Connect(function()
        open = not open
        if open then
            -- Position berechnen
            local absPos = header.AbsolutePosition
            local absSize = header.AbsoluteSize
            dropdown.Position = UDim2.new(0, absPos.X, 0, absPos.Y + absSize.Y + 4)
            dropdown.Visible = true
        else
            dropdown.Visible = false
        end
    end)

    -- Schließen wenn woanders geklickt
    game:GetService("UserInputService").InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 and open then
            task.wait()
            if not dropdown:IsAncestorOf(game:GetService("Players").LocalPlayer:GetMouse().Target or Instance.new("Part")) then
                open = false
                dropdown.Visible = false
            end
        end
    end)
end

-------------------------------------------------------------------------
-- TABS ERSTELLEN
-------------------------------------------------------------------------
local mainPage   = NewTab("⚡", "Main")
local shopPage   = NewTab("🛒", "Shop")
local playerPage = NewTab("👤", "Player")
local infoPage   = NewTab("ℹ", "Info")

-- Ersten Tab aktivieren
tabPages["Main"].Page.Visible = true
tabPages["Main"].Btn.BackgroundColor3 = Color3.fromRGB(0, 170, 95)
tabPages["Main"].Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
activePage = tabPages["Main"].Page
activeBtn  = tabPages["Main"].Btn

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
NewSection(shopPage, "Item Selection")
NewDropdown(shopPage, "Chambers",  cList,   function(v) table.insert(getgenv().SelectedItems, v) end)
NewDropdown(shopPage, "Collectors",colList,  function(v) table.insert(getgenv().SelectedItems, v) end)
NewDropdown(shopPage, "Upgraders", upList,   function(v) table.insert(getgenv().SelectedItems, v) end)
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
NewButton(shopPage, "🗑  Reset Selection", function()
    getgenv().SelectedItems = {}
end)

-------------------------------------------------------------------------
-- PLAYER TAB
-------------------------------------------------------------------------
NewSection(playerPage, "Player Info")
local plrName = Instance.new("TextLabel", playerPage)
plrName.Size = UDim2.new(1, -8, 0, 44)
plrName.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
plrName.Text = "  👤  " .. game.Players.LocalPlayer.Name
plrName.TextColor3 = Color3.fromRGB(0, 220, 120)
plrName.Font = Enum.Font.GothamBold
plrName.TextSize = 14
plrName.TextXAlignment = Enum.TextXAlignment.Left
plrName.BorderSizePixel = 0
Instance.new("UICorner", plrName).CornerRadius = UDim.new(0, 10)

-------------------------------------------------------------------------
-- INFO TAB
-------------------------------------------------------------------------
NewSection(infoPage, "V-Protocol")
local verLbl = Instance.new("TextLabel", infoPage)
verLbl.Size = UDim2.new(1, -8, 0, 44)
verLbl.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
verLbl.Text = "  V-Protocol  v5.1  —  Custom UI"
verLbl.TextColor3 = Color3.fromRGB(160, 160, 160)
verLbl.Font = Enum.Font.Gotham
verLbl.TextSize = 12
verLbl.TextXAlignment = Enum.TextXAlignment.Left
verLbl.BorderSizePixel = 0
Instance.new("UICorner", verLbl).CornerRadius = UDim.new(0, 10)

print("V-Protocol V5.1 geladen!")
