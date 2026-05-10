local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("V-Protocol Tycoon God", "DarkTheme")

print("[V-Protocol] Script initialisiert...")

-- GLOBALS
getgenv().Toggles = {Cash = false, Rebirth = false, Chests = false, AutoBuy = false}
local Remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")

-------------------------------------------------------------------------
-- DAS QUADRAT (TASKBAR ICON)
-------------------------------------------------------------------------
local targetParent = (gethui and gethui()) or game:GetService("CoreGui")
local sg = Instance.new("ScreenGui", targetParent)
sg.Name = "VProtocolTaskbar"
sg.DisplayOrder = 99999
sg.IgnoreGuiInset = true

local btn = Instance.new("TextButton", sg)
btn.Size = UDim2.new(0, 50, 0, 50)
btn.Position = UDim2.new(0, 20, 0.5, 0)
btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
btn.BorderSizePixel = 2
btn.BorderColor3 = Color3.fromRGB(255, 255, 255)
btn.TextColor3 = Color3.fromRGB(255, 255, 255)
btn.Text = "V" -- Das Logo auf dem Quadrat
btn.TextSize = 25
btn.Visible = false
btn.Draggable = true
btn.Active = true
Instance.new("UICorner", btn)

-------------------------------------------------------------------------
-- FUNKTIONEN
-------------------------------------------------------------------------
local function ShowMenu(gui)
    print("[DEBUG] Menü wird eingeblendet")
    gui.Enabled = true
    local main = gui:FindFirstChild("Main")
    if main then main.Visible = true end
    btn.Visible = false
end

local function HideMenu(gui)
    print("[DEBUG] Menü wird minimiert")
    gui.Enabled = false
    btn.Visible = true
end

btn.MouseButton1Click:Connect(function()
    local gui = targetParent:FindFirstChild("V-Protocol Tycoon God") or game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("V-Protocol Tycoon God")
    if gui then ShowMenu(gui) end
end)

-------------------------------------------------------------------------
-- INJECTION LOGIK (Der Minus-Button & X-Fix)
-------------------------------------------------------------------------
task.spawn(function()
    local gui = nil
    -- Warten bis Kavo die GUI erstellt hat
    while not gui do
        gui = targetParent:FindFirstChild("V-Protocol Tycoon God") or game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("V-Protocol Tycoon God")
        task.wait(0.5)
    end
    print("[DEBUG] Kavo-GUI gefunden: " .. gui:GetFullName())

    local main = gui:WaitForChild("Main")
    -- Header suchen (Dort wo Titel und X sind)
    local header = main:FindFirstChild("Header") or main:FindFirstChild("TopBar") 
    
    if header then
        print("[DEBUG] Header gefunden. Erstelle Minus-Button...")
        
        -- Wir erstellen einen eigenen Minimieren-Button im Header
        local miniBtn = Instance.new("TextButton", header)
        miniBtn.Name = "MinimizeButton"
        miniBtn.Size = UDim2.new(0, 30, 0, 30)
        -- Wir platzieren ihn links neben dem X (Kavo X ist meistens ganz rechts)
        miniBtn.Position = UDim2.new(1, -65, 0, 5) 
        miniBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        miniBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        miniBtn.Text = "-"
        miniBtn.TextSize = 20
        Instance.new("UICorner", miniBtn)
        
        miniBtn.MouseButton1Click:Connect(function()
            HideMenu(gui)
        end)
        
        -- Den X-Button finden und umfunktionieren
        -- Kavo nutzt oft ein ImageButton für das X
        for _, child in pairs(header:GetChildren()) do
            if child:IsA("ImageButton") or (child:IsA("TextButton") and child.Text == "X") then
                print("[DEBUG] X-Button gefunden und umgeleitet.")
                child.MouseButton1Click:Connect(function()
                    task.wait(0.1) -- Kurz warten bis Kavo fertig ist
                    HideMenu(gui)
                end)
            end
        end
    else
        print("[DEBUG] FEHLER: Header wurde nicht gefunden!")
    end
end)

-------------------------------------------------------------------------
-- DEINE TABS (Unverändert)
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

print("[V-Protocol] UI Geladen. Prüfe Konsole (F9) bei Fehlern.")
