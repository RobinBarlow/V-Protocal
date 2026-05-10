-- 1. ALLES ALTE LÖSCHEN (RADIKAL-REINIGUNG)
local function Cleanup()
    local target = (gethui and gethui()) or game:GetService("CoreGui") or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    for _, v in pairs(target:GetChildren()) do
        if v:IsA("ScreenGui") and (v.Name:find("V-Protocol") or v.Name:find("Kavo") or v.Name:find("VTaskbar") or v.Name:find("VProtocol")) then
            v:Destroy()
        end
    end
end
Cleanup()

-- GLOBALS
getgenv().Toggles = { Cash = false, Rebirth = false }
local Remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")
local UI_NAME = "VProtocol_V4_Final"
local Parent = (gethui and gethui()) or game:GetService("CoreGui")

-------------------------------------------------------------------------
-- UI CORE
-------------------------------------------------------------------------
local sg = Instance.new("ScreenGui", Parent)
sg.Name = UI_NAME
sg.ResetOnSpawn = false

-- DAS QUADRAT (V-ICON)
local taskbar = Instance.new("TextButton", sg)
taskbar.Size = UDim2.new(0, 50, 0, 50)
taskbar.Position = UDim2.new(0, 20, 0.5, -25)
taskbar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
taskbar.Text = "V"
taskbar.TextColor3 = Color3.fromRGB(0, 255, 150)
taskbar.TextSize = 25
taskbar.Font = Enum.Font.GothamBold
taskbar.Visible = false
taskbar.Active = true
taskbar.Draggable = true -- Damit du es verschieben kannst
Instance.new("UICorner", taskbar).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", taskbar).Color = Color3.fromRGB(0, 255, 150)

-- LOGIK: NUR BEIM KLICKEN ÖFFNEN (NICHT BEIM SCHIEBEN)
local startPos
taskbar.MouseButton1Down:Connect(function()
    startPos = taskbar.AbsolutePosition
end)

taskbar.MouseButton1Up:Connect(function()
    if startPos then
        local endPos = taskbar.AbsolutePosition
        local distance = (startPos - endPos).Magnitude
        if distance < 5 then -- Nur wenn fast nicht bewegt
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
main.Draggable = true -- Das ganze Fenster ist an der Sidebar ziehbar
Instance.new("UICorner", main)

-- SIDEBAR (KATEGORIEN)
local sidebar = Instance.new("Frame", main)
sidebar.Size = UDim2.new(0, 110, 1, 0)
sidebar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Instance.new("UICorner", sidebar)

local layout = Instance.new("UIListLayout", sidebar)
layout.Padding = UDim.new(0, 10)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
Instance.new("UIPadding", sidebar).PaddingTop = UDim.new(0, 60)

-- TITEL IM HEADER
local title = Instance.new("TextLabel", main)
title.Text = "V-PROTOCOL V4"
title.Size = UDim2.new(0, 110, 0, 40)
title.TextColor3 = Color3.fromRGB(0, 255, 150)
title.Font = Enum.Font.GothamBold
title.BackgroundTransparency = 1

-- SCHLIESSEN-BUTTON (X) -> Minimiert
local closeBtn = Instance.new("TextButton", main)
closeBtn.Text = "✕"
closeBtn.Size = UDim2.new(0, 40, 0, 40)
closeBtn.Position = UDim2.new(1, -40, 0, 0)
closeBtn.BackgroundTransparency = 1
closeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
closeBtn.TextSize = 20

closeBtn.MouseButton1Click:Connect(function()
    main.Visible = false
    taskbar.Visible = true
end)

-- CONTAINER FÜR DIE TABS
local container = Instance.new("Frame", main)
container.Size = UDim2.new(1, -120, 1, -20)
container.Position = UDim2.new(0, 115, 0, 10)
container.BackgroundTransparency = 1

-------------------------------------------------------------------------
-- TAB SYSTEM LOGIK
-------------------------------------------------------------------------
local tabs = {}
local function NewTab(name)
    local btn = Instance.new("TextButton", sidebar)
    btn.Size = UDim2.new(0.8, 0, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 12
    Instance.new("UICorner", btn)

    local page = Instance.new("ScrollingFrame", container)
    page.Size = UDim2.new(1, 0, 1, 0)
    page.Visible = false
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 2
    local pageLayout = Instance.new("UIListLayout", page)
    pageLayout.Padding = UDim.new(0, 5)

    btn.MouseButton1Click:Connect(function()
        for _, t in pairs(tabs) do
            t.Page.Visible = false
            t.Btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            t.Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
        page.Visible = true
        btn.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
        btn.TextColor3 = Color3.fromRGB(0, 0, 0)
    end)

    tabs[name] = {Btn = btn, Page = page}
    return page
end

-- FUNKTION FÜR TOGGLES
local function NewToggle(parent, text, callback)
    local t = Instance.new("TextButton", parent)
    t.Size = UDim2.new(1, -10, 0, 40)
    t.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    t.Text = "  " .. text
    t.TextColor3 = Color3.fromRGB(150, 150, 150)
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.Font = Enum.Font.Gotham
    t.TextSize = 13
    Instance.new("UICorner", t)

    local active = false
    t.MouseButton1Click:Connect(function()
        active = not active
        t.TextColor3 = active and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(150, 150, 150)
        callback(active)
    end)
end

-------------------------------------------------------------------------
-- KATEGORIEN ERSTELLEN
-------------------------------------------------------------------------
local mainPage = NewTab("Main")
local shopPage = NewTab("Shop")
local personPage = NewTab("Person")

-- MAIN TAB CONTENT
NewToggle(mainPage, "Auto Collect Cash", function(s)
    getgenv().Toggles.Cash = s
    task.spawn(function()
        while getgenv().Toggles.Cash do Remotes.MoveCash:FireServer() task.wait(0.2) end
    end)
end)

NewToggle(mainPage, "Auto Rebirth", function(s)
    getgenv().Toggles.Rebirth = s
    task.spawn(function()
        while getgenv().Toggles.Rebirth do Remotes.Rebirth:FireServer() task.wait(1) end
    end)
end)

-- PERSON TAB CONTENT
local info = Instance.new("TextLabel", personPage)
info.Size = UDim2.new(1, 0, 0, 50)
info.BackgroundTransparency = 1
info.Text = "User: " .. game.Players.LocalPlayer.Name
info.TextColor3 = Color3.fromRGB(255, 255, 255)
info.Font = Enum.Font.Gotham

-- INITIAL TAB
tabs["Main"].Page.Visible = true
tabs["Main"].Btn.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
tabs["Main"].Btn.TextColor3 = Color3.fromRGB(0, 0, 0)

print("V-Protocol V4 Final geladen!")
