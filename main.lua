local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("V-Protocol Tycoon God", "DarkTheme")

-- GLOBALS
getgenv().Toggles = {Cash = false, Rebirth = false}
local Remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")

-------------------------------------------------------------------------
-- 1. DAS QUADRAT (TASKBAR)
-------------------------------------------------------------------------
local targetParent = (gethui and gethui()) or game:GetService("CoreGui")
if targetParent:FindFirstChild("VTaskbar") then targetParent.VTaskbar:Destroy() end

local sg = Instance.new("ScreenGui", targetParent)
sg.Name = "VTaskbar"

local btn = Instance.new("TextButton", sg)
btn.Size = UDim2.new(0, 50, 0, 50)
btn.Position = UDim2.new(0, 15, 0.5, -25)
btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
btn.Text = "V"
btn.TextColor3 = Color3.fromRGB(255, 255, 255)
btn.TextSize = 25
btn.Visible = false
btn.Active = true
btn.Draggable = true
Instance.new("UICorner", btn)

-------------------------------------------------------------------------
-- 2. DAS MINUS (-) UND X-HIJACK
-------------------------------------------------------------------------
task.spawn(function()
    local gui = nil
    -- Suche nach der GUI
    while not gui do
        for _, v in pairs(targetParent:GetChildren()) do
            if v:IsA("ScreenGui") and v:FindFirstChild("Main") then
                gui = v
                break
            end
        end
        task.wait(0.5)
    end

    -- Suche nach dem X-Button (ImageButton mit der Kavo-ID)
    local xButton = nil
    while not xButton do
        for _, v in pairs(gui:GetDescendants()) do
            if v:IsA("ImageButton") and (v.Image == "rbxassetid://5054663650" or v.Name == "Close") then
                xButton = v
                break
            end
        end
        task.wait(0.5)
    end

    -- Wenn das X gefunden wurde, setzen wir das Minus daneben
    if xButton then
        local header = xButton.Parent
        
        local minus = Instance.new("TextButton", header)
        minus.Name = "MinimizeBtn"
        minus.Size = UDim2.new(0, 30, 0, 30)
        -- Positioniere es exakt links neben das X
        minus.Position = UDim2.new(xButton.Position.X.Scale, xButton.Position.X.Offset - 35, xButton.Position.Y.Scale, xButton.Position.Y.Offset)
        minus.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        minus.Text = "-"
        minus.TextColor3 = Color3.fromRGB(255, 255, 255)
        minus.TextSize = 25
        minus.ZIndex = 999
        Instance.new("UICorner", minus)

        local function minimize()
            gui.Enabled = false
            btn.Visible = true
        end

        minus.MouseButton1Click:Connect(minimize)
        
        -- Kapere das X aus dem Screenshot
        xButton.MouseButton1Click:Connect(function()
            task.wait(0.1)
            minimize()
        end)
    end
end)

-- Öffnen-Funktion für das Quadrat
btn.MouseButton1Click:Connect(function()
    local gui = targetParent:FindFirstChild("VTaskbar").Parent:FindFirstChild("V-Protocol Tycoon God") or targetParent:FindFirstChildOfClass("ScreenGui")
    -- Suche die richtige GUI zum Reaktivieren
    for _, v in pairs(targetParent:GetChildren()) do
        if v:IsA("ScreenGui") and v:FindFirstChild("Main") then
            v.Enabled = true
            btn.Visible = false
            break
        end
    end
end)

-------------------------------------------------------------------------
-- 3. CONTENT (Main Section)
-------------------------------------------------------------------------
local MainTab = Window:NewTab("Main")
local mSec = MainTab:NewSection("Automation")

mSec:NewToggle("Auto Collect Cash", "Geld sammeln", function(s)
    getgenv().Toggles.Cash = s
    task.spawn(function() while getgenv().Toggles.Cash do Remotes.MoveCash:FireServer() task.wait(0.2) end end)
end)

-- Hier kommen deine weiteren Toggles hin...
