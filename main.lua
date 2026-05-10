local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("V-Protocol Tycoon God", "DarkTheme")

-- GLOBALS
getgenv().Toggles = {Cash = false, Rebirth = false, Chests = false, AutoBuy = false}
getgenv().SelectedItems = {}
local Remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")

-------------------------------------------------------------------------
-- TASKBAR ICON (Das 4eck) - Bessere Platzierung
-------------------------------------------------------------------------
local targetParent = (gethui and gethui()) or game:GetService("CoreGui") or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

if targetParent:FindFirstChild("VProtocolTaskbar") then targetParent.VProtocolTaskbar:Destroy() end

local sg = Instance.new("ScreenGui", targetParent)
sg.Name = "VProtocolTaskbar"
sg.ResetOnSpawn = false
sg.DisplayOrder = 99999
sg.IgnoreGuiInset = true -- Damit es wirklich überall sichtbar ist

local btn = Instance.new("ImageButton", sg)
Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
btn.Size = UDim2.new(0, 50, 0, 50)
btn.Position = UDim2.new(0, 10, 0.5, 0) -- Links am Rand in der Mitte
btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
btn.Image = "rbxassetid://6031094678" 
btn.Visible = false
btn.Draggable = true
btn.Active = true

-------------------------------------------------------------------------
-- KAVO GUI FINDER
-------------------------------------------------------------------------
local kavoGui = nil
local mainFrame = nil

task.spawn(function()
    while not kavoGui do
        task.wait(0.5)
        -- Suche in allen möglichen Ordnern nach dem Kavo-Menü
        for _, p in pairs({targetParent, game:GetService("CoreGui"), game:GetService("Players").LocalPlayer.PlayerGui}) do
            local found = p:FindFirstChild("V-Protocol Tycoon God")
            if found then 
                kavoGui = found 
                mainFrame = found:FindFirstChild("Main")
                break 
            end
        end
    end
end)

btn.MouseButton1Click:Connect(function()
    if kavoGui then
        kavoGui.Enabled = true
        if mainFrame then mainFrame.Visible = true end
        btn.Visible = false
    end
end)

-------------------------------------------------------------------------
-- TABS & CONTENT (Deine Listen etc.)
-------------------------------------------------------------------------
local cList = {"Chamber_Void", "Chamber_Plasma", "Chamber_Infernal", "Chamber_Ruby", "Chamber_Legendary", "Chamber_Obsidian", "Chamber_Epic", "Chamber_Emerald", "Chamber_Candy", "Chamber_Ancient"}
local colList = {"Collector_Void", "Collector_Plasma", "Collector_Infernal", "Collector_Astral", "Collector_Epic", "Collector_Legendary", "Collector_Emerald", "Collector_Radioactive", "Collector_Candy", "Collector_Ancient"}
local upList = {"Upgrader_Void", "Upgrader_Plasma", "Upgrader_Infernal", "Upgrader_Legendary", "Upgrader_Obsidian", "Upgrader_Epic", "Upgrader_Ruby", "Upgrader_Rare", "Upgrader_Candy", "Upgrader_Ancient"}
local convList = {"Conveyor_Plasma", "Conveyor_Astral", "Conveyor_Obsidian", "Conveyor_Infernal", "Conveyor_Cybernetic", "Conveyor_Radioactive", "DownwardsConveyor_Astral", "UpwardsConveyor_Ruby"}

local MainTab = Window:NewTab("Main")
local ShopTab = Window:NewTab("Merchant")
local Credits = Window:NewTab("V-System")
local mSec = MainTab:NewSection("Automation")

-- Auto-Funktionen
mSec:NewToggle("Auto Collect Cash", "Geld sammeln", function(s)
    getgenv().Toggles.Cash = s
    task.spawn(function() while getgenv().Toggles.Cash do Remotes.MoveCash:FireServer() task.wait(0.2) end end)
end)

mSec:NewToggle("Auto Rebirth", "Sofort Rebirth", function(s)
    getgenv().Toggles.Rebirth = s
    task.spawn(function() while getgenv().Toggles.Rebirth do Remotes.Rebirth:FireServer() task.wait(1) end end)
end)

mSec:NewToggle("Auto Pick Chests", "Kisten sammeln", function(s) getgenv().Toggles.Chests = s end)
Remotes.ChestDrop.OnClientEvent:Connect(function(_, id) if getgenv().Toggles.Chests then Remotes.PickUpChest:FireServer(id) end end)

-- Merchant Setup
local sSec = ShopTab:NewSection("Multi-Select Shop")
local function add(v) table.insert(getgenv().SelectedItems, v) end
sSec:NewDropdown("Chambers", "Add", cList, add)
sSec:NewDropdown("Collectors", "Add", colList, add)
sSec:NewDropdown("Upgraders", "Add", upList, add)
sSec:NewDropdown("Conveyors", "Add", convList, add)

sSec:NewToggle("Enable Auto-Buy", "Kaufen & Restocken", function(s)
    getgenv().Toggles.AutoBuy = s
    task.spawn(function()
        while getgenv().Toggles.AutoBuy do
            for _, item in pairs(getgenv().SelectedItems) do
                if not getgenv().Toggles.AutoBuy then break end
                pcall(function() Remotes.MerchantBuyAll:FireServer(item) end)
                task.wait(0.1)
            end
            pcall(function() Remotes.Restock:FireServer() end)
            task.wait(1.5)
        end
    end)
end)
sSec:NewButton("Reset Selection", "Leeren", function() getgenv().SelectedItems = {} end)

Credits:NewSection("V-Protocol v3.2")

-------------------------------------------------------------------------
-- VERBESSERTER WATCHDOG
-------------------------------------------------------------------------
task.spawn(function()
    while task.wait(0.3) do
        pcall(function()
            if kavoGui then
                -- Prüfe ob die GUI deaktiviert ODER das Hauptfenster unsichtbar ist
                local isHidden = (kavoGui.Enabled == false) or (mainFrame and mainFrame.Visible == false)
                
                if isHidden then
                    btn.Visible = true
                else
                    btn.Visible = false
                end
            end
        end)
    end
end)
