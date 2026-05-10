local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("V-Protocol Tycoon God", "DarkTheme")

print("[DEBUG] Script gestartet...")

-- GLOBALS
getgenv().Toggles = {Cash = false, Rebirth = false, Chests = false, AutoBuy = false}
local Remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")

-------------------------------------------------------------------------
-- DAS QUADRAT (TASKBAR ICON)
-------------------------------------------------------------------------
local targetParent = (gethui and gethui()) or game:GetService("CoreGui") or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

if targetParent:FindFirstChild("VProtocolTaskbar") then targetParent.VProtocolTaskbar:Destroy() end

local sg = Instance.new("ScreenGui", targetParent)
sg.Name = "VProtocolTaskbar"
sg.DisplayOrder = 99999
sg.IgnoreGuiInset = true

local btn = Instance.new("TextButton", sg)
btn.Size = UDim2.new(0, 55, 0, 55)
btn.Position = UDim2.new(0, 10, 0.4, 0)
btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
btn.BorderSizePixel = 2
btn.BorderColor3 = Color3.fromRGB(0, 255, 150) -- Giftgrüner Rand damit man es sieht
btn.TextColor3 = Color3.fromRGB(255, 255, 255)
btn.Text = "V"
btn.TextSize = 30
btn.Visible = false -- Startet unsichtbar
btn.Draggable = true
btn.Active = true
Instance.new("UICorner", btn)

-------------------------------------------------------------------------
-- INTELLIGENTER GUI-FINDER & INJECTOR
-------------------------------------------------------------------------
local kavoGui = nil
local mainFrame = nil

task.spawn(function()
    print("[DEBUG] Suche Kavo-Struktur...")
    
    -- Wir suchen eine GUI, die ein Frame namens "Main" hat (typisch für Kavo)
    while not kavoGui do
        for _, g in pairs(targetParent:GetChildren()) do
            if g:IsA("ScreenGui") and g:FindFirstChild("Main") then
                local possibleMain = g.Main
                if possibleMain:FindFirstChild("elements") or possibleMain:FindFirstChild("container") then
                    kavoGui = g
                    mainFrame = possibleMain
                    print("[DEBUG] Kavo-GUI gefunden! Name: " .. g.Name)
                    break
                end
            end
        end
        task.wait(1)
    end

    -- Wenn gefunden, Buttons fixen
    if mainFrame then
        -- 1. Header finden
        local header = mainFrame:FindFirstChild("Header") or mainFrame:FindFirstChild("TopBar") or mainFrame:FindFirstChild("TitleBar")
        
        -- Falls Kavo keinen Header-Namen hat, nehmen wir das oberste Frame
        if not header then
            for _, v in pairs(mainFrame:GetChildren()) do
                if v:IsA("Frame") and v.Size.Y.Offset < 50 then
                    header = v
                    break
                end
            end
        end

        if header then
            print("[DEBUG] Header identifiziert. Erstelle '-' Button...")
            
            -- Erstelle den Minus Button
            local mini = Instance.new("TextButton", header)
            mini.Name = "MinimizeButton"
            mini.Size = UDim2.new(0, 25, 0, 25)
            mini.Position = UDim2.new(1, -60, 0, 5) -- Links neben dem X
            mini.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            mini.Text = "-"
            mini.TextColor3 = Color3.fromRGB(255, 255, 255)
            mini.TextSize = 20
            mini.ZIndex = 10
            Instance.new("UICorner", mini)

            mini.MouseButton1Click:Connect(function()
                print("[DEBUG] Minimieren geklickt")
                kavoGui.Enabled = false
                btn.Visible = true
            end)

            -- 2. Das originale "X" finden und umleiten
            for _, xBtn in pairs(header:GetChildren()) do
                if xBtn:IsA("ImageButton") or (xBtn:IsA("TextButton") and (xBtn.Text == "X" or xBtn.Name == "Close")) then
                    print("[DEBUG] X-Button gefunden. Leite um...")
                    xBtn.MouseButton1Click:Connect(function()
                        task.wait(0.1)
                        kavoGui.Enabled = false
                        btn.Visible = true
                        print("[DEBUG] X gedrückt -> Minimiert statt Schließen")
                    end)
                end
            end
        end
    end
end)

-- Taskbar Button Funktion zum Wiederherstellen
btn.MouseButton1Click:Connect(function()
    if kavoGui then
        kavoGui.Enabled = true
        btn.Visible = false
        print("[DEBUG] Menü wiederhergestellt")
    end
end)

-------------------------------------------------------------------------
-- TABS (Unverändert)
-------------------------------------------------------------------------
local MainTab = Window:NewTab("Main")
local mSec = MainTab:NewSection("Automation")

mSec:NewToggle("Auto Collect Cash", "Geld sammeln", function(s)
    getgenv().Toggles.Cash = s
    task.spawn(function() while getgenv().Toggles.Cash do Remotes.MoveCash:FireServer() task.wait(0.2) end end)
end)

-- (Deine restlichen Tabs hier einfügen...)

print("[DEBUG] Alles geladen. Warte auf GUI-Erkennung...")
