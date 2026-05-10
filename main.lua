-- CORE SETTINGS
local UI_NAME = "VProtocol_Ultimate"
local getHui = (gethui and gethui()) or game:GetService("CoreGui") or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

if getHui:FindFirstChild(UI_NAME) then getHui[UI_NAME]:Destroy() end

-- GLOBALS
getgenv().Toggles = { Cash = false, Rebirth = false, Chests = false }
local Remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")

-------------------------------------------------------------------------
-- UI SETUP
-------------------------------------------------------------------------
local sg = Instance.new("ScreenGui", getHui)
sg.Name = UI_NAME
sg.ResetOnSpawn = false

-- DAS QUADRAT (TASKBAR ICON)
local taskbar = Instance.new("TextButton", sg)
taskbar.Size = UDim2.new(0, 55, 0, 55)
taskbar.Position = UDim2.new(0, 20, 0.5, -25)
taskbar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
taskbar.Text = "V"
taskbar.TextColor3 = Color3.fromRGB(0, 255, 150)
taskbar.TextSize = 28
taskbar.Font = Enum.Font.GothamBold
taskbar.Visible = false
taskbar.Active = true
taskbar.Draggable = true -- Standard Draggable
Instance.new("UICorner", taskbar).CornerRadius = UDim.new(0, 12)
local iconStroke = Instance.new("UIStroke", taskbar)
iconStroke.Color = Color3.fromRGB(0, 255, 150)
iconStroke.Thickness = 2

-- CLICK VS DRAG LOGIK FÜR DAS QUADRAT
local dragStartPos
taskbar.MouseButton1Down:Connect(function()
    dragStartPos = taskbar.Position
end)

taskbar.MouseButton1Up:Connect(function()
    if dragStartPos then
        local delta = (Vector2.new(taskbar.Position.X.Offset, taskbar.Position.Y.Offset) - 
                       Vector2.new(dragStartPos.X.Offset, dragStartPos.Y.Offset)).Magnitude
        if delta < 5 then -- Nur öffnen, wenn kaum bewegt (Klick)
            taskbar.Visible = false
            sg.MainFrame.Visible = true
        end
    end
end)

-- HAUPTFENSTER
local main = Instance.new("Frame", sg)
main.Name = "MainFrame"
main.Size = UDim2.new(0, 500, 0, 350)
main.Position = UDim2.new(0.5, -250, 0.5, -175)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
Instance.new("UICorner", main)

-- SIDEBAR (TASKLEISTE LINKS)
local sidebar = Instance.new("Frame", main)
sidebar.Size = UDim2.new(0, 120, 1, 0)
sidebar.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
Instance.new("UICorner", sidebar)

local sidebarLayout = Instance.new("UIListLayout", sidebar)
sidebarLayout.Padding = UDim.new(0, 5)
sidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local sidebarPadding = Instance.new("UIPadding", sidebar)
sidebarPadding.PaddingTop = UDim.new(0, 50)

-- CONTENT BEREICH
local contentArea = Instance.new("Frame", main)
contentArea.Size = UDim2.new(1, -130, 1, -50)
contentArea.Position = UDim2.new(0, 125, 0, 45)
contentArea.BackgroundTransparency = 1

-- TITEL & CLOSE
local title = Instance.new("TextLabel", main)
title.Text = "V-PROTOCOL"
title.Size = UDim2.new(0, 120, 0, 40)
title.TextColor3 = Color3.fromRGB(0, 255, 150)
title.Font = Enum.Font.GothamBold
title.BackgroundTransparency = 1
title.TextSize = 16

local closeBtn = Instance.new("TextButton", main)
closeBtn.Text = "×"
closeBtn.Size = UDim2.new(0, 40, 0, 40)
closeBtn.Position = UDim2.new(1, -40, 0, 0)
closeBtn.BackgroundTransparency = 1
closeBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
closeBtn.TextSize = 35

closeBtn.MouseButton1Click:Connect(function()
    main.Visible = false
    taskbar.Visible = true
end)

-------------------------------------------------------------------------
-- TAB SYSTEM
-------------------------------------------------------------------------
local tabs = {}
local function CreateTab(name)
    -- Der Button in der Sidebar
    local tabBtn = Instance.new("TextButton", sidebar)
    tabBtn.Size = UDim2.new(0.9, 0, 0, 35)
    tabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    tabBtn.Text = name
    tabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    tabBtn.Font = Enum.Font.GothamSemibold
    tabBtn.TextSize = 13
    Instance.new("UICorner", tabBtn)
    
    -- Der Inhalt für diesen Tab
    local tabContent = Instance.new("ScrollingFrame", contentArea)
    tabContent.Size = UDim2.new(1, 0, 1, 0)
    tabContent.BackgroundTransparency = 1
    tabContent.Visible = false
    tabContent.ScrollBarThickness = 2
    local l = Instance.new("UIListLayout", tabContent)
    l.Padding = UDim.new(0, 8)
    
    tabBtn.MouseButton1Click:Connect(function()
        for _, t in pairs(tabs) do
            t.Content.Visible = false
            t.Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        end
        tabContent.Visible = true
        tabBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
        tabBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
        task.wait(0.1)
        tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255) -- Reset color but keep bg
    end)
    
    tabs[name] = {Btn = tabBtn, Content = tabContent}
    return tabContent
end

-- FUNKTION FÜR TOGGLES
local function AddToggle(parent, text, callback)
    local tBtn = Instance.new("TextButton", parent)
    tBtn.Size = UDim2.new(1, -10, 0, 40)
    tBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    tBtn.Text = "  " .. text
    tBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
    tBtn.TextXAlignment = Enum.TextXAlignment.Left
    tBtn.Font = Enum.Font.Gotham
    tBtn.TextSize = 13
    Instance.new("UICorner", tBtn)
    
    local active = false
    tBtn.MouseButton1Click:Connect(function()
        active = not active
        tBtn.TextColor3 = active and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(150, 150, 150)
        callback(active)
    end)
end

-------------------------------------------------------------------------
-- INHALT ERSTELLEN
-------------------------------------------------------------------------
local mainTab = CreateTab("Main")
local shopTab = CreateTab("Shop")
local personTab = CreateTab("Person")

-- MAIN FEATURES
AddToggle(mainTab, "Auto Collect Cash", function(s)
    getgenv().Toggles.Cash = s
    task.spawn(function()
        while getgenv().Toggles.Cash do Remotes.MoveCash:FireServer() task.wait(0.2) end
    end)
end)

AddToggle(mainTab, "Auto Rebirth", function(s)
    getgenv().Toggles.Rebirth = s
    task.spawn(function()
        while getgenv().Toggles.Rebirth do Remotes.Rebirth:FireServer() task.wait(1) end
    end)
end)

-- SHOP PLACEHOLDER
local shopInfo = Instance.new("TextLabel", shopTab)
shopInfo.Size = UDim2.new(1,0,0,50)
shopInfo.Text = "Shop system coming soon..."
shopInfo.TextColor3 = Color3.fromRGB(100,100,100)
shopInfo.BackgroundTransparency = 1

-- PERSON INFO
local personInfo = Instance.new("TextLabel", personTab)
personInfo.Size = UDim2.new(1,0,0,100)
personInfo.Text = "Player: " .. game.Players.LocalPlayer.Name .. "\nStatus: Premium User"
personInfo.TextColor3 = Color3.fromRGB(255,255,255)
personInfo.BackgroundTransparency = 1
personInfo.Font = Enum.Font.Gotham

-- Start Tab setzen
tabs["Main"].Content.Visible = true
tabs["Main"].Btn.BackgroundColor3 = Color3.fromRGB(0, 255, 150)

print("V-Protocol Ultimate geladen!")
