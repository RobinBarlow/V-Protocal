local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("V-Protocol Tycoon God", "DarkTheme")

-- DEFINITION DER LISTEN
local cList = {"Chamber_Void", "Chamber_Plasma", "Chamber_Infernal", "Chamber_Ruby", "Chamber_Legendary", "Chamber_Obsidian", "Chamber_Epic", "Chamber_Emerald", "Chamber_Candy", "Chamber_Ancient"}
local colList = {"Collector_Void", "Collector_Plasma", "Collector_Infernal", "Collector_Astral", "Collector_Epic", "Collector_Legendary", "Collector_Emerald", "Collector_Radioactive", "Collector_Candy", "Collector_Ancient"}
local upList = {"Upgrader_Void", "Upgrader_Plasma", "Upgrader_Infernal", "Upgrader_Legendary", "Upgrader_Obsidian", "Upgrader_Epic", "Upgrader_Ruby", "Upgrader_Rare", "Upgrader_Candy", "Upgrader_Ancient"}
local convList = {"Conveyor_Plasma", "Conveyor_Astral", "Conveyor_Obsidian", "Conveyor_Infernal", "Conveyor_Cybernetic", "Conveyor_Radioactive", "DownwardsConveyor_Astral", "UpwardsConveyor_Ruby"}

-- SETTINGS
getgenv().Toggles = {Cash = false, Rebirth = false, Chests = false, AutoBuy = false}
getgenv().SelectedItems = {}
local Remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")

-- CUSTOM TOGGLE BUTTON (Das kleine Viereck)
local ScreenGui = Instance.new("ScreenGui")
local ToggleButton = Instance.new("ImageButton")
local UICorner = Instance.new("UICorner")

ScreenGui.Name = "VProtocolToggle"
ScreenGui.Parent = game:GetService("CoreGui")

ToggleButton.Name = "ToggleButton"
ToggleButton.Parent = ScreenGui
ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ToggleButton.Position = UDim2.new(0.02, 0, 0.2, 0) -- Position links oben
ToggleButton.Size = UDim2.new(0, 50, 0, 50) -- Größe des Vierecks
-- Das Logo (Ein cooles "V" oder Cyber-Icon)
ToggleButton.Image = "rbxassetid://6031094678" 
ToggleButton.Draggable = true -- Du kannst es auf dem Screen verschieben!

UICorner.CornerRadius = UDim.new(0, 12) -- Abgerundete Ecken
UICorner.Parent = ToggleButton

-- Funktion zum Öffnen/Schließen
ToggleButton.MouseButton1Click:Connect(function()
    Library:ToggleUI()
end)

-- TABS & SECTIONS
local MainTab = Window:NewTab("Main")
local ShopTab = Window:NewTab("Merchant")
local Credits = Window:NewTab("V-System")

local MainSection = MainTab:NewSection("Automation")

MainSection:NewToggle("Auto Collect Cash", "Sammelt Geld", function(state)
    getgenv().Toggles.Cash = state
    task.spawn(function()
        while getgenv().Toggles.Cash do
            Remotes.MoveCash:FireServer()
            task.wait(0.2)
        end
    end)
end)

MainSection:NewToggle("Auto Rebirth", "Rebirthe sofort", function(state)
    getgenv().Toggles.Rebirth = state
    task.spawn(function()
        while getgenv().Toggles.Rebirth do
            Remotes.Rebirth:FireServer()
            task.wait(1)
        end
    end)
end)

MainSection:NewToggle("Auto Pick Chests", "Nimmt Kisten", function(state)
    getgenv().Toggles.Chests = state
end)

Remotes.ChestDrop.OnClientEvent:Connect(function(name, id, pos)
    if getgenv().Toggles.Chests then
        Remotes.PickUpChest:FireServer(id)
    end
end)

local ShopSection = ShopTab:NewSection("Smart Auto-Buy")

ShopSection:NewDropdown("Chambers", "Wähle Typ", cList, function(v) table.insert(getgenv().SelectedItems, v) end)
ShopSection:NewDropdown("Collectors", "Wähle Typ", colList, function(v) table.insert(getgenv().SelectedItems, v) end)
ShopSection:NewDropdown("Upgraders", "Wähle Typ", upList, function(v) table.insert(getgenv().SelectedItems, v) end)
ShopSection:NewDropdown("Conveyors", "Wähle Typ", convList, function(v) table.insert(getgenv().SelectedItems, v) end)

ShopSection:NewToggle("Enable Auto-Buy", "Kauft & Restockt", function(state)
    getgenv().Toggles.AutoBuy = state
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

ShopSection:NewButton("Reset Selection", "Leert die Liste", function()
    getgenv().SelectedItems = {}
end)

Credits:NewSection("V-Protocol by Gemini")
Credits:NewSection("Status: God Mode Active")
