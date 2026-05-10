-- GLOBALS & REMOTES
getgenv().Toggles = {Cash = false, Rebirth = false}
local Remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")

-- UI REFERENZ LÖSCHEN FALLS VORHANDEN
local old = game:GetService("CoreGui"):FindFirstChild("VProtocol_Custom") or game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("VProtocol_Custom")
if old then old:Destroy() end

-- HAUPT-CONTAINER
local sg = Instance.new("ScreenGui")
sg.Name = "VProtocol_Custom"
sg.Parent = (gethui and gethui()) or game:GetService("CoreGui")
sg.ResetOnSpawn = false

-- DAS QUADRAT (TASKBAR ICON)
local taskbarBtn = Instance.new("TextButton", sg)
taskbarBtn.Name = "TaskbarBtn"
taskbarBtn.Size = UDim2.new(0, 55, 0, 55)
taskbarBtn.Position = UDim2.new(0, 20, 0.5, -25)
taskbarBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
taskbarBtn.Text = "V"
taskbarBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
taskbarBtn.TextSize = 30
taskbarBtn.Visible = false -- Startet unsichtbar
taskbarBtn.Draggable = true
taskbarBtn.Active = true
Instance.new("UICorner", taskbarBtn).CornerRadius = UDim.new(0, 12)
local border = Instance.new("UIStroke", taskbarBtn)
border.Color = Color3.fromRGB(0, 255, 150)
border.Thickness = 2

-- DAS HAUPTFENSTER
local main = Instance.new("Frame", sg)
main.Name = "MainFrame"
main.Size = UDim2.new(0, 400, 0, 300)
main.Position = UDim2.new(0.5, -200, 0.5, -150)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
Instance.new("UICorner", main)

-- HEADER (DIE LEISTE OBEN)
local header = Instance.new("Frame", main)
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 40)
header.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Instance.new("UICorner", header)

local title = Instance.new("TextLabel", header)
title.Text = "  V-PROTOCOL TYCOON GOD"
title.Size = UDim2.new(0.7, 0, 1, 0)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Font = Enum.Font.GothamBold
title.TextSize = 14

-- MINIMIEREN BUTTON (-)
local miniBtn = Instance.new("TextButton", header)
miniBtn.Text = "-"
miniBtn.Size = UDim2.new(0, 35, 0, 35)
miniBtn.Position = UDim2.new(1, -75, 0, 2)
miniBtn.BackgroundTransparency = 1
miniBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
miniBtn.TextSize = 30

-- SCHLIESSEN BUTTON (X) -> Soll auch minimieren!
local closeBtn = Instance.new("TextButton", header)
closeBtn.Text = "×"
closeBtn.Size = UDim2.new(0, 35, 0, 35)
closeBtn.Position = UDim2.new(1, -40, 0, 2)
closeBtn.BackgroundTransparency = 1
closeBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
closeBtn.TextSize = 30

-- LOGIK FÜR DAS MINIMIEREN
local function toggleUI()
    main.Visible = not main.Visible
    taskbarBtn.Visible = not main.Visible
end

miniBtn.MouseButton1Click:Connect(toggleUI)
closeBtn.MouseButton1Click:Connect(toggleUI)
taskbarBtn.MouseButton1Click:Connect(toggleUI)

-- SCROLLING CONTENT BEREICH
local content = Instance.new("ScrollingFrame", main)
content.Size = UDim2.new(1, -20, 1, -50)
content.Position = UDim2.new(0, 10, 0, 45)
content.BackgroundTransparency = 1
content.CanvasSize = UDim2.new(0, 0, 2, 0)
content.ScrollBarThickness = 4

local listLayout = Instance.new("UIListLayout", content)
listLayout.Padding = UDim.new(0, 8)

-- FUNKTION UM TOGGLES HINZUZUFÜGEN
local function CreateToggle(name, callback)
    local tFrame = Instance.new("TextButton", content)
    tFrame.Size = UDim2.new(1, 0, 0, 40)
    tFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    tFrame.Text = "  " .. name
    tFrame.TextColor3 = Color3.fromRGB(150, 150, 150)
    tFrame.TextXAlignment = Enum.TextXAlignment.Left
    tFrame.Font = Enum.Font.Gotham
    tFrame.TextSize = 14
    tFrame.AutoButtonColor = false
    Instance.new("UICorner", tFrame)
    
    local status = false
    tFrame.MouseButton1Click:Connect(function()
        status = not status
        tFrame.TextColor3 = status and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(150, 150, 150)
        tFrame.BackgroundColor3 = status and Color3.fromRGB(50, 50, 50) or Color3.fromRGB(40, 40, 40)
        callback(status)
    end)
end

-------------------------------------------------------------------------
-- DEINE FUNKTIONEN (HIER EINTRAGEN)
-------------------------------------------------------------------------

CreateToggle("Auto Collect Cash", function(s)
    getgenv().Toggles.Cash = s
    task.spawn(function()
        while getgenv().Toggles.Cash do
            Remotes.MoveCash:FireServer()
            task.wait(0.2)
        end
    end)
end)

CreateToggle("Auto Rebirth", function(s)
    getgenv().Toggles.Rebirth = s
    task.spawn(function()
        while getgenv().Toggles.Rebirth do
            Remotes.Rebirth:FireServer()
            task.wait(1)
        end
    end)
end)

CreateToggle("Auto Pick Chests", function(s)
    getgenv().Toggles.Chests = s
    -- Logic here...
end)

print("V-Protocol Custom Geladen!")
