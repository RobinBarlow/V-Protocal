local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("V-Protocol Tycoon God", "DarkTheme")

-- GLOBALS
getgenv().Toggles = {Cash = false, Rebirth = false, Chests = false, AutoBuy = false}
local Remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")

-------------------------------------------------------------------------
-- DAS QUADRAT (TASKBAR ICON)
-------------------------------------------------------------------------
-- Wir nutzen den Ordner, den dein Executor im Screenshot angezeigt hat
local targetParent = (gethui and gethui()) or game:GetService("CoreGui")

if targetParent:FindFirstChild("VProtocolTaskbar") then targetParent.VProtocolTaskbar:Destroy() end

local sg = Instance.new("ScreenGui", targetParent)
sg.Name = "VProtocolTaskbar"
sg.DisplayOrder = 99999
sg.IgnoreGuiInset = true

local btn = Instance.new("TextButton", sg)
btn.Size = UDim2.new(0, 50, 0, 50)
btn.Position = UDim2.new(0, 15, 0.5, -25) -- Links mittig
btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
btn.BorderSizePixel = 2
btn.BorderColor3 = Color3.fromRGB(0, 255, 150)
btn.TextColor3 = Color3.fromRGB(255, 255, 255)
btn.Text = "V"
btn.TextSize = 25
btn.Visible = false
btn.Draggable = true
btn.Active = true
Instance.new("UICorner", btn)

-------------------------------------------------------------------------
-- DER "ALLES-FINDER" & INJECTOR
-------------------------------------------------------------------------
local kavoGui = nil

task.spawn(function()
    print("[DEBUG] Suche nach Kavo-Struktur in " .. targetParent.Name)
    
    while not kavoGui do
        for _, g in pairs(targetParent:GetChildren()) do
            -- Kavo-Guis haben immer ein "Main" Frame und darin ein "container" oder "elements"
            if g:IsA("ScreenGui") and g:FindFirstChild("Main") then
                kavoGui = g
                print("[DEBUG] KAVO GEFUNDEN! Name ist: " .. g.Name)
                break
            end
        end
        task.wait(1)
    end

    local main = kavoGui.Main
    -- Wir suchen die Kopfzeile (Kavo nennt sie oft Header)
    local header = main:FindFirstChild("Header") or main:FindFirstChild("TopBar")
    
    if not header then
        -- Fallback: Suche das oberste kleine Frame
        for _, v in pairs(main:GetChildren()) do
            if v:IsA("Frame") and v.Size.Y.Offset < 60 and v.Size.Y.Offset > 10 then
                header = v
                break
            end
        end
    end

    if header then
        print("[DEBUG] Header gefunden, füge '-' hinzu.")
        
        -- MINUS BUTTON ERSTELLEN
        local mini = Instance.new("TextButton", header)
        mini.Name = "CustomMinimize"
        mini.Size = UDim2.new(0, 30, 0, 30)
        mini.Position = UDim2.new(1, -65, 0, 5) -- Direkt links neben dem X
        mini.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        mini.Text = "-"
        mini.TextColor3 = Color3.fromRGB(255, 255, 255)
        mini.TextSize = 25
        mini.ZIndex = 999
        Instance.new("UICorner", mini)

        local function minimize()
            kavoGui.Enabled = false
            btn.Visible = true
            print("[DEBUG] Minimiert!")
        end

        mini.MouseButton1Click:Connect(minimize)

        -- X-BUTTON HIJACK
        for _, child in pairs(header:GetChildren()) do
            if child:IsA("ImageButton") or (child:IsA("TextButton") and child.Text == "X") then
                child.MouseButton1Click:Connect(function()
                    task.wait(0.05)
                    minimize()
                end)
            end
        end
    end
end)

btn.MouseButton1Click:Connect(function()
    if kavoGui then
        kavoGui.Enabled = true
        btn.Visible = false
    end
end)

-------------------------------------------------------------------------
-- TABS
-------------------------------------------------------------------------
local MainTab = Window:NewTab("Main")
local mSec = MainTab:NewSection("Automation")

mSec:NewToggle("Auto Collect Cash", "Geld sammeln", function(s)
    getgenv().Toggles.Cash = s
    task.spawn(function() while getgenv().Toggles.Cash do Remotes.MoveCash:FireServer() task.wait(0.2) end end)
end)

-- (Deine anderen Toggles hier...)
