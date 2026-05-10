-- CORE SETTINGS
local UI_NAME = "VProtocol_CustomUI"
local getHui = (gethui and gethui()) or game:GetService("CoreGui") or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

-- Vorherige Versionen löschen
if getHui:FindFirstChild(UI_NAME) then getHui[UI_NAME]:Destroy() end

-- GLOBALS
getgenv().Toggles = { Cash = false, Rebirth = false }
local Remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")

-------------------------------------------------------------------------
-- UI ELEMENTE
-------------------------------------------------------------------------
local sg = Instance.new("ScreenGui", getHui)
sg.Name = UI_NAME
sg.ResetOnSpawn = false

-- DAS QUADRAT (TASKBAR)
local taskbar = Instance.new("TextButton", sg)
taskbar.Size = UDim2.new(0, 55, 0, 55)
taskbar.Position = UDim2.new(0, 20, 0.5, -25)
taskbar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
taskbar.BorderSizePixel = 0
taskbar.Text = "V"
taskbar.TextColor3 = Color3.fromRGB(0, 255, 150)
taskbar.TextSize = 28
taskbar.Font = Enum.Font.GothamBold
taskbar.Visible = false
taskbar.Draggable = true
taskbar.Active = true
Instance.new("UICorner", taskbar).CornerRadius = UDim.new(0, 12)
local stroke = Instance.new("UIStroke", taskbar)
stroke.Color = Color3.fromRGB(0, 255, 150)
stroke.Thickness = 2

-- HAUPTFENSTER
local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 400, 0, 300)
main.Position = UDim2.new(0.5, -200, 0.5, -150)
main.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
Instance.new("UICorner", main)

-- HEADER (OBERE LEISTE)
local header = Instance.new("Frame", main)
header.Size = UDim2.new(1, 0, 0, 40)
header.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Instance.new("UICorner", header)

local title = Instance.new("TextLabel", header)
title.Text = "  V-PROTOCOL TYCOON GOD"
title.Size = UDim2.new(0.7, 0, 1, 0)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Font = Enum.Font.GothamBold
title.TextSize = 14

-- DER "-" BUTTON (MINIMIEREN)
local miniBtn = Instance.new("TextButton", header)
miniBtn.Text = "-"
miniBtn.Size = UDim2.new(0, 35, 0, 35)
miniBtn.Position = UDim2.new(1, -75, 0, 2)
miniBtn.BackgroundTransparency = 1
miniBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
miniBtn.TextSize = 35
miniBtn.Font = Enum.Font.GothamMedium

-- DER "X" BUTTON (SCHLIESSEN -> MINIMIERT AUCH!)
local closeBtn = Instance.new("TextButton", header)
closeBtn.Text = "×"
closeBtn.Size = UDim2.new(0, 35, 0, 35)
closeBtn.Position = UDim2.new(1, -40, 0, 2)
closeBtn.BackgroundTransparency = 1
closeBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
closeBtn.TextSize = 35
closeBtn.Font = Enum.Font.GothamMedium

-------------------------------------------------------------------------
-- LOGIK (DAS HERZSTÜCK)
-------------------------------------------------------------------------
local function minimize()
    main.Visible = false
    taskbar.Visible = true
end

local function maximize()
    main.Visible = true
    taskbar.Visible = false
end

miniBtn.MouseButton1Click:Connect(minimize)
closeBtn.MouseButton1Click:Connect(minimize)
taskbar.MouseButton1Click:Connect(maximize)

-------------------------------------------------------------------------
-- CONTENT BEREICH (TOGGLES)
-------------------------------------------------------------------------
local container = Instance.new("ScrollingFrame", main)
container.Size = UDim2.new(1, -20, 1, -55)
container.Position = UDim2.new(0, 10, 0, 45)
container.BackgroundTransparency = 1
container.BorderSizePixel = 0
container.ScrollBarThickness = 2

local layout = Instance.new("UIListLayout", container)
layout.Padding = UDim.new(0, 5)

local function AddToggle(text, callback)
    local tBtn = Instance.new("TextButton", container)
    tBtn.Size = UDim2.new(1, 0, 0, 45)
    tBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    tBtn.Text = "  " .. text
    tBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
    tBtn.TextXAlignment = Enum.TextXAlignment.Left
    tBtn.Font = Enum.Font.Gotham
    tBtn.TextSize = 14
    tBtn.AutoButtonColor = false
    Instance.new("UICorner", tBtn)
    
    local active = false
    tBtn.MouseButton1Click:Connect(function()
        active = not active
        tBtn.TextColor3 = active and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(180, 180, 180)
        tBtn.BackgroundColor3 = active and Color3.fromRGB(40, 40, 40) or Color3.fromRGB(30, 30, 30)
        callback(active)
    end)
end

-------------------------------------------------------------------------
-- DEINE FEATURES
-------------------------------------------------------------------------
AddToggle("Auto Collect Cash", function(state)
    getgenv().Toggles.Cash = state
    task.spawn(function()
        while getgenv().Toggles.Cash do
            Remotes.MoveCash:FireServer()
            task.wait(0.2)
        end
    end)
end)

AddToggle("Auto Rebirth", function(state)
    getgenv().Toggles.Rebirth = state
    task.spawn(function()
        while getgenv().Toggles.Rebirth do
            Remotes.Rebirth:FireServer()
            task.wait(1)
        end
    end)
end)

AddToggle("Auto Pick Chests", function(state)
    -- Hier deine Chest-Logik einfügen
end)

print("V-Protocol Custom UI geladen!")
