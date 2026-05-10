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

getgenv().Toggles = {Cash=false, Rebirth=false, Chests=false, AutoBuy=false}
getgenv().SelectedItems = {}
local Remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")
local Parent = (gethui and gethui()) or game:GetService("CoreGui")
local TS = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")

local cList   = {"Chamber_Void","Chamber_Plasma","Chamber_Infernal","Chamber_Ruby","Chamber_Legendary","Chamber_Obsidian","Chamber_Epic","Chamber_Emerald","Chamber_Candy","Chamber_Ancient"}
local colList  = {"Collector_Void","Collector_Plasma","Collector_Infernal","Collector_Astral","Collector_Epic","Collector_Legendary","Collector_Emerald","Collector_Radioactive","Collector_Candy","Collector_Ancient"}
local upList   = {"Upgrader_Void","Upgrader_Plasma","Upgrader_Infernal","Upgrader_Legendary","Upgrader_Obsidian","Upgrader_Epic","Upgrader_Ruby","Upgrader_Rare","Upgrader_Candy","Upgrader_Ancient"}
local convList = {"Conveyor_Plasma","Conveyor_Astral","Conveyor_Obsidian","Conveyor_Infernal","Conveyor_Cybernetic","Conveyor_Radioactive","DownwardsConveyor_Astral","UpwardsConveyor_Ruby"}

------------------------------------------------------------------------
-- SCREENGUI
------------------------------------------------------------------------
local sg = Instance.new("ScreenGui", Parent)
sg.Name = "VProtocolV6"
sg.ResetOnSpawn = false
sg.DisplayOrder = 99999
sg.IgnoreGuiInset = true

------------------------------------------------------------------------
-- TASKBAR
------------------------------------------------------------------------
local taskbar = Instance.new("Frame", sg)
taskbar.Size = UDim2.new(0,56,0,56)
taskbar.Position = UDim2.new(0,20,0.5,-28)
taskbar.BackgroundColor3 = Color3.fromRGB(10,10,10)
taskbar.Visible = false
taskbar.Active = true
taskbar.ZIndex = 100
Instance.new("UICorner", taskbar).CornerRadius = UDim.new(0,14)
local tbS = Instance.new("UIStroke", taskbar)
tbS.Color = Color3.fromRGB(0,220,120); tbS.Thickness = 1.5
local tbL = Instance.new("TextLabel", taskbar)
tbL.Size = UDim2.new(1,0,1,0); tbL.BackgroundTransparency = 1
tbL.Text = "VP"; tbL.TextColor3 = Color3.fromRGB(0,220,120)
tbL.Font = Enum.Font.GothamBold; tbL.TextSize = 18; tbL.ZIndex = 101

local tbDragS, tbStartP, tbMoved
taskbar.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        tbDragS = i.Position; tbStartP = taskbar.Position; tbMoved = false
    end
end)
taskbar.InputChanged:Connect(function(i)
    if tbDragS and i.UserInputType == Enum.UserInputType.MouseMovement then
        local d = i.Position - tbDragS
        if d.Magnitude > 5 then tbMoved = true end
        taskbar.Position = UDim2.new(tbStartP.X.Scale, tbStartP.X.Offset+d.X, tbStartP.Y.Scale, tbStartP.Y.Offset+d.Y)
    end
end)
taskbar.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        if not tbMoved then
            taskbar.Visible = false
            sg.MainWindow.Visible = true
        end
        tbDragS = nil
    end
end)

------------------------------------------------------------------------
-- HAUPTFENSTER  (580 x 420)
------------------------------------------------------------------------
local main = Instance.new("Frame", sg)
main.Name = "MainWindow"
main.Size = UDim2.new(0,600,0,420)
main.Position = UDim2.new(0.5,-300,0.5,-210)
main.BackgroundColor3 = Color3.fromRGB(12,12,12)
main.BorderSizePixel = 0
main.Active = true
main.ZIndex = 10
Instance.new("UICorner", main).CornerRadius = UDim.new(0,14)
Instance.new("UIStroke", main).Color = Color3.fromRGB(0,190,100)

-- Drag auf Hauptfenster
local dS2, sP2
main.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then dS2=i.Position; sP2=main.Position end
end)
main.InputChanged:Connect(function(i)
    if dS2 and i.UserInputType == Enum.UserInputType.MouseMovement then
        local d=i.Position-dS2
        main.Position=UDim2.new(sP2.X.Scale,sP2.X.Offset+d.X,sP2.Y.Scale,sP2.Y.Offset+d.Y)
    end
end)
main.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 then dS2=nil end
end)

------------------------------------------------------------------------
-- SIDEBAR  – feste Höhe, oben ausgerichtet
------------------------------------------------------------------------
local sidebar = Instance.new("Frame", main)
sidebar.Size = UDim2.new(0,130,1,0)
sidebar.Position = UDim2.new(0,0,0,0)
sidebar.BackgroundColor3 = Color3.fromRGB(16,16,16)
sidebar.BorderSizePixel = 0
sidebar.ZIndex = 11
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0,14)

-- rechte Ecken gerade machen
local fill = Instance.new("Frame", sidebar)
fill.Size = UDim2.new(0,14,1,0)
fill.Position = UDim2.new(1,-14,0,0)
fill.BackgroundColor3 = Color3.fromRGB(16,16,16)
fill.BorderSizePixel = 0
fill.ZIndex = 11

-- Logo
local logo = Instance.new("TextLabel", sidebar)
logo.Size = UDim2.new(1,0,0,50)
logo.Position = UDim2.new(0,0,0,0)
logo.BackgroundTransparency = 1
logo.Text = "V · PROTO"
logo.TextColor3 = Color3.fromRGB(0,220,120)
logo.Font = Enum.Font.GothamBold
logo.TextSize = 13
logo.ZIndex = 12

-- Tab-Buttons LISTE  (UIListLayout oben ausrichten!)
local sideList = Instance.new("UIListLayout", sidebar)
sideList.Padding = UDim.new(0,6)
sideList.HorizontalAlignment = Enum.HorizontalAlignment.Center
sideList.VerticalAlignment = Enum.VerticalAlignment.Top   -- ← KEY FIX
sideList.SortOrder = Enum.SortOrder.LayoutOrder
local sidePad = Instance.new("UIPadding", sidebar)
sidePad.PaddingTop = UDim.new(0,56)
sidePad.PaddingBottom = UDim.new(0,8)

------------------------------------------------------------------------
-- X-BUTTON
------------------------------------------------------------------------
local xBtn = Instance.new("TextButton", main)
xBtn.Size = UDim2.new(0,32,0,32)
xBtn.Position = UDim2.new(1,-40,0,8)
xBtn.BackgroundColor3 = Color3.fromRGB(200,50,50)
xBtn.Text = "✕"
xBtn.TextColor3 = Color3.fromRGB(255,255,255)
xBtn.Font = Enum.Font.GothamBold
xBtn.TextSize = 15
xBtn.BorderSizePixel = 0
xBtn.ZIndex = 20
Instance.new("UICorner", xBtn).CornerRadius = UDim.new(0,8)
xBtn.MouseButton1Click:Connect(function()
    main.Visible = false
    taskbar.Visible = true
end)

------------------------------------------------------------------------
-- CONTENT AREA
------------------------------------------------------------------------
local content = Instance.new("Frame", main)
content.Size = UDim2.new(1,-145,1,-12)
content.Position = UDim2.new(0,138,0,6)
content.BackgroundTransparency = 1
content.ClipsDescendants = true
content.ZIndex = 11

------------------------------------------------------------------------
-- TAB SYSTEM
------------------------------------------------------------------------
local activePage, activeBtn = nil, nil
local tabPages = {}

local function NewTab(icon, name, order)
    local btn = Instance.new("TextButton", sidebar)
    btn.Size = UDim2.new(0.84,0,0,36)
    btn.BackgroundColor3 = Color3.fromRGB(22,22,22)
    btn.Text = icon.."  "..name
    btn.TextColor3 = Color3.fromRGB(130,130,130)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 12
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.AutoButtonColor = false
    btn.BorderSizePixel = 0
    btn.ZIndex = 12
    btn.LayoutOrder = order
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,9)
    Instance.new("UIPadding", btn).PaddingLeft = UDim.new(0,10)

    local page = Instance.new("ScrollingFrame", content)
    page.Size = UDim2.new(1,0,1,0)
    page.Visible = false
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = Color3.fromRGB(0,200,110)
    page.BorderSizePixel = 0
    page.CanvasSize = UDim2.new(0,0,0,0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.ZIndex = 12
    local pl = Instance.new("UIListLayout", page)
    pl.Padding = UDim.new(0,6)
    pl.SortOrder = Enum.SortOrder.LayoutOrder
    Instance.new("UIPadding", page).PaddingTop = UDim.new(0,6)

    btn.MouseButton1Click:Connect(function()
        if activePage then activePage.Visible = false end
        if activeBtn then
            activeBtn.BackgroundColor3 = Color3.fromRGB(22,22,22)
            activeBtn.TextColor3 = Color3.fromRGB(130,130,130)
        end
        page.Visible = true
        btn.BackgroundColor3 = Color3.fromRGB(0,170,95)
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        activePage = page; activeBtn = btn
    end)

    tabPages[name] = {Page=page, Btn=btn}
    return page
end

------------------------------------------------------------------------
-- KOMPONENTEN
------------------------------------------------------------------------
local function NewSection(parent, text)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1,-8,0,26)
    f.BackgroundColor3 = Color3.fromRGB(0,140,75)
    f.BorderSizePixel = 0
    Instance.new("UICorner", f).CornerRadius = UDim.new(0,7)
    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(1,-12,1,0)
    l.Position = UDim2.new(0,10,0,0)
    l.BackgroundTransparency = 1
    l.Text = text:upper()
    l.TextColor3 = Color3.fromRGB(255,255,255)
    l.Font = Enum.Font.GothamBold
    l.TextSize = 11
    l.TextXAlignment = Enum.TextXAlignment.Left
end

local function NewToggle(parent, text, callback)
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1,-8,0,44)
    row.BackgroundColor3 = Color3.fromRGB(18,18,18)
    row.BorderSizePixel = 0
    Instance.new("UICorner", row).CornerRadius = UDim.new(0,10)

    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(1,-60,1,0)
    lbl.Position = UDim2.new(0,14,0,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(200,200,200)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local pill = Instance.new("Frame", row)
    pill.Size = UDim2.new(0,42,0,22)
    pill.Position = UDim2.new(1,-54,0.5,-11)
    pill.BackgroundColor3 = Color3.fromRGB(38,38,38)
    Instance.new("UICorner", pill).CornerRadius = UDim.new(1,0)

    local knob = Instance.new("Frame", pill)
    knob.Size = UDim2.new(0,16,0,16)
    knob.Position = UDim2.new(0,3,0.5,-8)
    knob.BackgroundColor3 = Color3.fromRGB(110,110,110)
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)

    local active = false
    local ca = Instance.new("TextButton", row)
    ca.Size = UDim2.new(1,0,1,0); ca.BackgroundTransparency = 1; ca.Text = ""; ca.ZIndex = 13
    ca.MouseButton1Click:Connect(function()
        active = not active
        if active then
            TS:Create(pill,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(0,200,110)}):Play()
            TS:Create(knob,TweenInfo.new(0.15),{Position=UDim2.new(0,23,0.5,-8),BackgroundColor3=Color3.fromRGB(255,255,255)}):Play()
            lbl.TextColor3 = Color3.fromRGB(0,220,120)
        else
            TS:Create(pill,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(38,38,38)}):Play()
            TS:Create(knob,TweenInfo.new(0.15),{Position=UDim2.new(0,3,0.5,-8),BackgroundColor3=Color3.fromRGB(110,110,110)}):Play()
            lbl.TextColor3 = Color3.fromRGB(200,200,200)
        end
        callback(active)
    end)
end

local function NewButton(parent, text, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1,-8,0,40)
    btn.BackgroundColor3 = Color3.fromRGB(0,155,85)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 13
    btn.AutoButtonColor = false
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,10)
    btn.MouseButton1Click:Connect(function()
        TS:Create(btn,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(0,110,60)}):Play()
        task.delay(0.15,function() TS:Create(btn,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(0,155,85)}):Play() end)
        callback()
    end)
end

-- SELECTED ITEMS ANZEIGE
local function NewSelectedDisplay(parent)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1,-8,0,36)
    frame.BackgroundColor3 = Color3.fromRGB(14,14,14)
    frame.BorderSizePixel = 0
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0,8)
    Instance.new("UIStroke", frame).Color = Color3.fromRGB(0,140,75)

    local lbl = Instance.new("TextLabel", frame)
    lbl.Size = UDim2.new(1,-10,1,0)
    lbl.Position = UDim2.new(0,8,0,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = "Ausgewählt: –"
    lbl.TextColor3 = Color3.fromRGB(0,200,110)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextWrapped = true

    -- Update-Funktion zurückgeben
    return function()
        if #getgenv().SelectedItems == 0 then
            lbl.Text = "Ausgewählt: –"
        else
            lbl.Text = "✓ "..table.concat(getgenv().SelectedItems, "  |  ")
        end
    end
end

-- MULTI-SELECT DROPDOWN (mehrere auswählbar, Haken zeigen)
local function NewMultiDropdown(parent, label, list, updateDisplay)
    local wrap = Instance.new("Frame", parent)
    wrap.Size = UDim2.new(1,-8,0,38)
    wrap.BackgroundColor3 = Color3.fromRGB(18,18,18)
    wrap.BorderSizePixel = 0
    wrap.ClipsDescendants = false
    Instance.new("UICorner", wrap).CornerRadius = UDim.new(0,10)

    local header = Instance.new("TextButton", wrap)
    header.Size = UDim2.new(1,0,0,38)
    header.BackgroundTransparency = 1
    header.Text = "  ▾   "..label
    header.TextColor3 = Color3.fromRGB(170,170,170)
    header.Font = Enum.Font.GothamSemibold
    header.TextSize = 12
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.ZIndex = 50

    -- Floating dropdown direkt in sg
    local ddHeight = math.min(#list,7)*32+8
    local dd = Instance.new("Frame", sg)
    dd.Size = UDim2.new(0,300,0,ddHeight)
    dd.BackgroundColor3 = Color3.fromRGB(20,20,20)
    dd.BorderSizePixel = 0
    dd.Visible = false
    dd.ZIndex = 200
    Instance.new("UICorner", dd).CornerRadius = UDim.new(0,10)
    Instance.new("UIStroke", dd).Color = Color3.fromRGB(0,180,100)

    local scroll = Instance.new("ScrollingFrame", dd)
    scroll.Size = UDim2.new(1,0,1,0)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 3
    scroll.ScrollBarImageColor3 = Color3.fromRGB(0,200,110)
    scroll.CanvasSize = UDim2.new(0,0,0,#list*32+8)
    scroll.ZIndex = 201
    local dL = Instance.new("UIListLayout", scroll)
    dL.Padding = UDim.new(0,2)
    Instance.new("UIPadding", scroll).PaddingTop = UDim.new(0,4)

    local selected = {}
    local optBtns = {}

    for _, item in pairs(list) do
        selected[item] = false
        local opt = Instance.new("TextButton", scroll)
        opt.Size = UDim2.new(1,-8,0,30)
        opt.BackgroundColor3 = Color3.fromRGB(26,26,26)
        opt.Text = "  "..item
        opt.TextColor3 = Color3.fromRGB(170,170,170)
        opt.Font = Enum.Font.Gotham
        opt.TextSize = 11
        opt.TextXAlignment = Enum.TextXAlignment.Left
        opt.BorderSizePixel = 0
        opt.ZIndex = 202
        Instance.new("UICorner", opt).CornerRadius = UDim.new(0,7)
        optBtns[item] = opt

        opt.MouseButton1Click:Connect(function()
            selected[item] = not selected[item]
            if selected[item] then
                opt.Text = "  ✓  "..item
                opt.TextColor3 = Color3.fromRGB(0,220,120)
                opt.BackgroundColor3 = Color3.fromRGB(0,80,45)
                -- zu SelectedItems hinzufügen
                local found = false
                for _,v in pairs(getgenv().SelectedItems) do if v==item then found=true break end end
                if not found then table.insert(getgenv().SelectedItems, item) end
            else
                opt.Text = "  "..item
                opt.TextColor3 = Color3.fromRGB(170,170,170)
                opt.BackgroundColor3 = Color3.fromRGB(26,26,26)
                -- aus SelectedItems entfernen
                for i,v in pairs(getgenv().SelectedItems) do
                    if v==item then table.remove(getgenv().SelectedItems,i) break end
                end
            end
            if updateDisplay then updateDisplay() end
        end)
        opt.MouseEnter:Connect(function()
            if not selected[item] then
                TS:Create(opt,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(35,35,35)}):Play()
            end
        end)
        opt.MouseLeave:Connect(function()
            if not selected[item] then
                TS:Create(opt,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(26,26,26)}):Play()
            end
        end)
    end

    local open = false
    header.MouseButton1Click:Connect(function()
        open = not open
        if open then
            local ap = header.AbsolutePosition
            local as = header.AbsoluteSize
            dd.Position = UDim2.new(0, ap.X, 0, ap.Y + as.Y + 4)
            dd.Visible = true
        else
            dd.Visible = false
        end
    end)

    -- Schließen bei Klick außerhalb
    UIS.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 and open then
            task.wait()
            local mp = UIS:GetMouseLocation()
            local ddPos = dd.AbsolutePosition
            local ddSize = dd.AbsoluteSize
            if mp.X < ddPos.X or mp.X > ddPos.X+ddSize.X or mp.Y < ddPos.Y or mp.Y > ddPos.Y+ddSize.Y then
                open = false
                dd.Visible = false
            end
        end
    end)
end

------------------------------------------------------------------------
-- TABS ERSTELLEN
------------------------------------------------------------------------
local mainPage   = NewTab("⚡","Main",1)
local shopPage   = NewTab("🛒","Shop",2)
local playerPage = NewTab("👤","Player",3)
local infoPage   = NewTab("ℹ","Info",4)

-- Ersten Tab aktivieren
tabPages["Main"].Page.Visible = true
tabPages["Main"].Btn.BackgroundColor3 = Color3.fromRGB(0,170,95)
tabPages["Main"].Btn.TextColor3 = Color3.fromRGB(255,255,255)
activePage = tabPages["Main"].Page
activeBtn  = tabPages["Main"].Btn

------------------------------------------------------------------------
-- MAIN TAB
------------------------------------------------------------------------
NewSection(mainPage,"Automation")
NewToggle(mainPage,"Auto Collect Cash",function(s)
    getgenv().Toggles.Cash=s
    task.spawn(function() while getgenv().Toggles.Cash do Remotes.MoveCash:FireServer() task.wait(0.2) end end)
end)
NewToggle(mainPage,"Auto Rebirth",function(s)
    getgenv().Toggles.Rebirth=s
    task.spawn(function() while getgenv().Toggles.Rebirth do Remotes.Rebirth:FireServer() task.wait(1) end end)
end)
NewToggle(mainPage,"Auto Pick Chests",function(s)
    getgenv().Toggles.Chests=s
end)
Remotes.ChestDrop.OnClientEvent:Connect(function(_,id)
    if getgenv().Toggles.Chests then Remotes.PickUpChest:FireServer(id) end
end)

------------------------------------------------------------------------
-- SHOP TAB
------------------------------------------------------------------------
NewSection(shopPage,"Item Selection")

-- Anzeige zuerst erstellen
local updateDisplay = NewSelectedDisplay(shopPage)

NewMultiDropdown(shopPage,"Chambers",  cList,   updateDisplay)
NewMultiDropdown(shopPage,"Collectors",colList,  updateDisplay)
NewMultiDropdown(shopPage,"Upgraders", upList,   updateDisplay)
NewMultiDropdown(shopPage,"Conveyors", convList, updateDisplay)

NewSection(shopPage,"Auto Buy")
NewToggle(shopPage,"Enable Auto-Buy",function(s)
    getgenv().Toggles.AutoBuy=s
    task.spawn(function()
        while getgenv().Toggles.AutoBuy do
            for _,item in pairs(getgenv().SelectedItems) do
                if not getgenv().Toggles.AutoBuy then break end
                pcall(function() Remotes.MerchantBuyAll:FireServer(item) end)
                task.wait(0.1)
            end
            pcall(function() Remotes.Restock:FireServer() end)
            task.wait(1.5)
        end
    end)
end)
NewButton(shopPage,"🗑  Reset Selection",function()
    getgenv().SelectedItems={}
    updateDisplay()
end)

------------------------------------------------------------------------
-- PLAYER TAB
------------------------------------------------------------------------
NewSection(playerPage,"Player Info")
local plrLbl = Instance.new("TextLabel", playerPage)
plrLbl.Size = UDim2.new(1,-8,0,44)
plrLbl.BackgroundColor3 = Color3.fromRGB(18,18,18)
plrLbl.Text = "  👤  "..game.Players.LocalPlayer.Name
plrLbl.TextColor3 = Color3.fromRGB(0,220,120)
plrLbl.Font = Enum.Font.GothamBold
plrLbl.TextSize = 14
plrLbl.TextXAlignment = Enum.TextXAlignment.Left
plrLbl.BorderSizePixel = 0
Instance.new("UICorner",plrLbl).CornerRadius = UDim.new(0,10)

------------------------------------------------------------------------
-- INFO TAB
------------------------------------------------------------------------
NewSection(infoPage,"V-Protocol")
local verLbl = Instance.new("TextLabel", infoPage)
verLbl.Size = UDim2.new(1,-8,0,44)
verLbl.BackgroundColor3 = Color3.fromRGB(18,18,18)
verLbl.Text = "  V-Protocol  v6.0"
verLbl.TextColor3 = Color3.fromRGB(160,160,160)
verLbl.Font = Enum.Font.Gotham
verLbl.TextSize = 12
verLbl.TextXAlignment = Enum.TextXAlignment.Left
verLbl.BorderSizePixel = 0
Instance.new("UICorner",verLbl).CornerRadius = UDim.new(0,10)

print("V-Protocol V6 geladen!")
