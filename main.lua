local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("V-Protocol Tycoon God", "DarkTheme")

-- DATA LISTS
local cList = {"Chamber_Void", "Chamber_Plasma", "Chamber_Infernal", "Chamber_Ruby", "Chamber_Legendary", "Chamber_Obsidian", "Chamber_Epic", "Chamber_Emerald", "Chamber_Candy", "Chamber_Ancient"}
local colList = {"Collector_Void", "Collector_Plasma", "Collector_Infernal", "Collector_Astral", "Collector_Epic", "Collector_Legendary", "Collector_Emerald", "Collector_Radioactive", "Collector_Candy", "Collector_Ancient"}
local upList = {"Upgrader_Void", "Upgrader_Plasma", "Upgrader_Infernal", "Upgrader_Legendary", "Upgrader_Obsidian", "Upgrader_Epic", "Upgrader_Ruby", "Upgrader_Rare", "Upgrader_Candy", "Upgrader_Ancient"}
local convList = {"Conveyor_Plasma", "Conveyor_Astral", "Conveyor_Obsidian", "Conveyor_Infernal", "Conveyor_Cybernetic", "Conveyor_Radioactive", "DownwardsConveyor_Astral", "UpwardsConveyor_Ruby"}

-- GLOBALS
getgenv().Toggles = {Cash = false, Rebirth = false, Chests = false, AutoBuy = false}
getgenv().SelectedItems = {}
local Remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")

-------------------------------------------------------------------------
-- TABS (VOR dem Icon, damit alles registriert ist)
-------------------------------------------------------------------------
local MainTab = Window:NewTab("Main")
local ShopTab = Window:NewTab("Merchant")
local Credits = Window:NewTab("V-System")
local mSec = MainTab:NewSection("Automation")

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
-- TASKBAR ICON
-------------------------------------------------------------------------
local pGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
if pGui:FindFirstChild("VProtocolTaskbar") then pGui.VProtocolTaskbar:Destroy() end

local sg = Instance.new("ScreenGui", pGui)
sg.Name = "VProtocolTaskbar"
sg.ResetOnSpawn = false
sg.DisplayOrder = 99999

local btn = Instance.new("ImageButton", sg)
Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 15)
btn.Size = UDim2.new(0, 60, 0, 60)
btn.Position = UDim2.new(0.85, 0, 0.05, 0)
btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
btn.Image = "rbxassetid://6031094678"
btn.Visible = false
btn.Draggable = true
btn.Active = true
btn.ZIndex = 9999

-- Minimieren Button IM Menü
mSec:NewButton("Menü minimieren", "Icon zeigen", function()
    Library:ToggleUI()
    task.wait(0.1)
    btn.Visible = true
end)

-- Icon klicken = Menü wieder aufmachen
btn.MouseButton1Click:Connect(function()
    btn.Visible = false
    task.wait(0.1)
    Library:ToggleUI()
end)

-------------------------------------------------------------------------
-- WATCHDOG: überwacht ob X gedrückt wurde
-- Kavo setzt bei X: gui.Enabled = false
-- Wir suchen die GUI über gethui() was Executors nutzen
-------------------------------------------------------------------------
task.spawn(function()
    task.wait(2)
    
    local kavoGui = nil
    
    -- Alle möglichen Orte durchsuchen
    local searches = {
        function() return game:GetService("CoreGui"):FindFirstChild("V-Protocol Tycoon God") end,
        function() return pGui:FindFirstChild("V-Protocol Tycoon God") end,
        function() 
            if gethui then return gethui():FindFirstChild("V-Protocol Tycoon God") end
        end,
    }
    
    for _, search in pairs(searches) do
        pcall(function()
            local result = search()
            if result then 
                kavoGui = result
                print("GUI gefunden: " .. kavoGui:GetFullName())
            end
        end)
        if kavoGui then break end
    end

    -- Watchdog Loop
    while task.wait(0.3) do
        pcall(function()
            if kavoGui then
                -- GUI direkt überwachen
                if not kavoGui.Enabled and not btn.Visible then
                    btn.Visible = true
                end
            else
                -- Kein direkter Zugriff: RenderStepped Trick
                -- Button bleibt wie er ist, nur Minimieren-Button funktioniert
            end
        end)
    end
end)
