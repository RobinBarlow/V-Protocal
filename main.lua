local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("V-Protocol Tycoon God", "DarkTheme")

-- SETTINGS
getgenv().Toggles = {
    Cash = false,
    Rebirth = false,
    Chests = false,
    AutoBuy = false
}

getgenv().SelectedItems = {}

local Remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")

-- TABS
local MainTab = Window:NewTab("Main")
local ShopTab = Window:NewTab("Merchant")
local Credits = Window:NewTab("V-System")

-- MAIN SECTION
local MainSection = MainTab:NewSection("Automation")

MainSection:NewToggle("Auto Collect Cash", "Sammelt Geld vom grünen Feld", function(state)
    getgenv().Toggles.Cash = state
    task.spawn(function()
        while getgenv().Toggles.Cash do
            Remotes.MoveCash:FireServer()
            task.wait(0.2)
        end
    end)
end)

MainSection:NewToggle("Auto Rebirth", "Rebirthe sofort wenn möglich", function(state)
    getgenv().Toggles.Rebirth = state
    task.spawn(function()
        while getgenv().Toggles.Rebirth do
            Remotes.Rebirth:FireServer()
            task.wait(1)
        end
    end)
end)

MainSection:NewToggle("Auto Pick Chests", "Nimmt alle Kisten auf der Map", function(state)
    getgenv().Toggles.Chests = state
end)

-- Chest Listener (Globaler Hook basierend auf deinen Logs)
Remotes.ChestDrop.OnClientEvent:Connect(function(name, id, pos)
    if getgenv().Toggles.Chests then
        Remotes.PickUpChest:FireServer(id)
        print("V-Protocol: Kiste eingesackt: " .. id)
    end
end)

-- SHOP SECTION
-- V-Protocol: Merchant Logic Fix
local ShopSection = ShopTab:NewSection("Smart Auto-Buy")

-- Erweiterte Listen aus deinem Log
local cList = {"Chamber_Void", "Chamber_Plasma", "Chamber_Infernal", "Chamber_Ruby", "Chamber_Legendary", "Chamber_Obsidian", "Chamber_Epic", "Chamber_Emerald", "Chamber_Candy", "Chamber_Ancient"}
local colList = {"Collector_Void", "Collector_Plasma", "Collector_Infernal", "Collector_Astral", "Collector_Epic", "Collector_Legendary", "Collector_Emerald", "Collector_Radioactive", "Collector_Candy", "Collector_Ancient"}
local upList = {"Upgrader_Void", "Upgrader_Plasma", "Upgrader_Infernal", "Upgrader_Legendary", "Upgrader_Obsidian", "Upgrader_Epic", "Upgrader_Ruby", "Upgrader_Rare", "Upgrader_Candy", "Upgrader_Ancient"}
local convList = {"Conveyor_Plasma", "Conveyor_Astral", "Conveyor_Obsidian", "Conveyor_Infernal", "Conveyor_Cybernetic", "Conveyor_Radioactive", "DownwardsConveyor_Astral", "UpwardsConveyor_Ruby"}

-- Dropdowns
ShopSection:NewDropdown("Chambers", "Wähle Typ", cList, function(v) table.insert(getgenv().SelectedItems, v) end)
ShopSection:NewDropdown("Collectors", "Wähle Typ", colList, function(v) table.insert(getgenv().SelectedItems, v) end)
ShopSection:NewDropdown("Upgraders", "Wähle Typ", upList, function(v) table.insert(getgenv().SelectedItems, v) end)
ShopSection:NewDropdown("Conveyors", "Wähle Typ", convList, function(v) table.insert(getgenv().SelectedItems, v) end)

ShopSection:NewToggle("Enable Auto-Buy", "Kauft & Restockt", function(state)
    getgenv().Toggles.AutoBuy = state
    task.spawn(function()
        while getgenv().Toggles.AutoBuy do
            -- Wir gehen die Liste durch
            for i, item in pairs(getgenv().SelectedItems) do
                if not getgenv().Toggles.AutoBuy then break end
                
                -- Versuch 1: MerchantBuyAll (Effizienter)
                pcall(function()
                    Remotes.MerchantBuyAll:FireServer(item)
                end)
                
                -- Kleiner Wait, damit der Server nicht "Rate Limited" schreit
                task.wait(0.1)
            end
            
            -- WICHTIG: Restock nur, wenn die Liste einmal durch ist
            pcall(function()
                Remotes.Restock:FireServer()
            end)
            
            task.wait(1) -- Wartezeit zwischen den Shop-Sweeps
        end
    end)
end)

ShopSection:NewButton("Reset Selection", "Leert die Liste", function()
    getgenv().SelectedItems = {}
    print("V-Protocol: Liste geleert.")
end)

ShopSection:NewButton("Clear Selection", "Löscht die Kaufliste", function()
    getgenv().SelectedItems = {}
end)

Credits:NewSection("V-Protocol by Gemini")
Credits:NewSection("Status: Undetected")
