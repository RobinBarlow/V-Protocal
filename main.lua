local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("V-Protocol Tycoon God", "DarkTheme")

-- GLOBALS
getgenv().Toggles = {Cash = false, Rebirth = false, Chests = false, AutoBuy = false}
local Remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")

-------------------------------------------------------------------------
-- 1. DAS QUADRAT (TASKBAR) ERSTELLEN
-------------------------------------------------------------------------
local targetParent = (gethui and gethui()) or game:GetService("CoreGui")
if targetParent:FindFirstChild("VTaskbar") then targetParent.VTaskbar:Destroy() end

local sg = Instance.new("ScreenGui", targetParent)
sg.Name = "VTaskbar"
sg.IgnoreGuiInset = true

local btn = Instance.new("TextButton", sg)
btn.Size = UDim2.new(0, 50, 0, 50)
btn.Position = UDim2.new(0, 10, 0.5, -25)
btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
btn.Text = "V"
btn.TextColor3 = Color3.fromRGB(255, 255, 255)
btn.TextSize = 25
btn.Visible = false -- Startet unsichtbar
btn.Active = true
btn.Draggable = true
Instance.new("UICorner", btn)

-------------------------------------------------------------------------
-- 2. DEN "-" BUTTON IN DAS MENÜ PRÜGELN
-------------------------------------------------------------------------
task.spawn(function()
    local foundGui = nil
    
    -- Warteschleife, bis Kavo geladen hat
    while not foundGui do
        for _, v in pairs(targetParent:GetChildren()) do
            if v:IsA("ScreenGui") and v:FindFirstChild("Main") then
                foundGui = v
                break
            end
        end
        task.wait(0.5)
    end

    local main = foundGui.Main
    -- Wir suchen den Header (Die Leiste oben)
    local header = main:FindFirstChild("Header") or main:FindFirstChild("TopBar") or main:FindFirstChild("TitleBar")
    
    -- Falls Kavo keinen Standardnamen nutzt, nehmen wir das erste Frame in Main
    if not header then
        for _, child in pairs(main:GetChildren()) do
            if child:IsA("Frame") and child.Size.Y.Offset < 60 then
                header = child
                break
            end
        end
    end

    if header then
        -- HIER IST DEIN VERDAMMTES MINUS (-)
        local minus = Instance.new("TextButton", header)
        minus.Name = "MinimizeBtn"
        minus.Size = UDim2.new(0, 30, 0, 30)
        minus.Position = UDim2.new(1, -65, 0, 5) -- Direkt neben dem X
        minus.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        minus.Text = "-"
        minus.TextColor3 = Color3.fromRGB(255, 255, 255)
        minus.TextSize = 25
        minus.ZIndex = 9999
        Instance.new("UICorner", minus)

        local function doMinimize()
            foundGui.Enabled = false
            btn.Visible = true
        end

        -- Funktion für das Minus
        minus.MouseButton1Click:Connect(doMinimize)

        -- Funktion für das X (wir kapern alle Buttons im Header, die wie ein X aussehen)
        for _, x in pairs(header:GetChildren()) do
            if x:IsA("ImageButton") or (x:IsA("TextButton") and x.Text == "X") then
                x.MouseButton1Click:Connect(function()
                    task.wait(0.05)
                    doMinimize()
                end)
            end
        end
        
        -- Taskbar Button zum Öffnen
        btn.MouseButton1Click:Connect(function()
            foundGui.Enabled = true
            btn.Visible = false
        end)
    end
end)

-------------------------------------------------------------------------
-- 3. DEIN MENÜ-INHALT (Ohne den alten Minimieren-Button)
-------------------------------------------------------------------------
local MainTab = Window:NewTab("Main")
local mSec = MainTab:NewSection("Automation")

mSec:NewToggle("Auto Collect Cash", "Geld sammeln", function(s)
    getgenv().Toggles.Cash = s
    task.spawn(function() while getgenv().Toggles.Cash do Remotes.MoveCash:FireServer() task.wait(0.2) end end)
end)

mSec:NewToggle("Auto Rebirth", "Sofort Rebirth", function(s)
    getgenv().Toggles.Rebirth = s
    task.spawn(function() while getgenv().Toggles.Rebirth do Remotes.Rebirth:FireServer() task.wait(1) end end)
end)

-- Rest des Shops etc. hier einfügen...
