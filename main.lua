local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("V-Protocol Tycoon God", "DarkTheme")

-- DATA LISTS (Aus deinen Logs extrahiert)
local cList = {"Chamber_Void", "Chamber_Plasma", "Chamber_Infernal", "Chamber_Ruby", "Chamber_Legendary", "Chamber_Obsidian", "Chamber_Epic", "Chamber_Emerald", "Chamber_Candy", "Chamber_Ancient"}
local colList = {"Collector_Void", "Collector_Plasma", "Collector_Infernal", "Collector_Astral", "Collector_Epic", "Collector_Legendary", "Collector_Emerald", "Collector_Radioactive", "Collector_Candy", "Collector_Ancient"}
local upList = {"Upgrader_Void", "Upgrader_Plasma", "Upgrader_Infernal", "Upgrader_Legendary", "Upgrader_Obsidian", "Upgrader_Epic", "Upgrader_Ruby", "Upgrader_Rare", "Upgrader_Candy", "Upgrader_Ancient"}
local convList = {"Conveyor_Plasma", "Conveyor_Astral", "Conveyor_Obsidian", "Conveyor_Infernal", "Conveyor_Cybernetic", "Conveyor_Radioactive", "DownwardsConveyor_Astral", "UpwardsConveyor_Ruby"}

-- GLOBALS
getgenv().Toggles = {Cash = false, Rebirth = false, Chests = false, AutoBuy = false}
getgenv().SelectedItems = {}
-------------------------------------------------------------------------
-- V-PROTOCOL LOGIC BRIDGE (Viereck-Logik & Auto-Detection)
-------------------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
local ToggleButton = Instance.new("ImageButton")
local UICorner = Instance.new("UICorner")

ScreenGui.Name = "VProtocolLog"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

ToggleButton.Name = "MiniToggle"
ToggleButton.Parent = ScreenGui
ToggleButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ToggleButton.BorderSizePixel = 0
ToggleButton.Position = UDim2.new(0.02, 0, 0.15, 0)
ToggleButton.Size = UDim2.new(0, 60, 0, 60)
ToggleButton.Image = "rbxassetid://6031094678" -- Das Logo
ToggleButton.Draggable = true
ToggleButton.Visible = false -- Startet unsichtbar

UICorner.CornerRadius = UDim.new(0, 15)
UICorner.Parent = ToggleButton

-- WICHTIG: Die Wachhund-Funktion
local function SetUIVisibility(visible)
    Library:ToggleUI() -- Triggert Kavo
    if visible then
        ToggleButton.Visible = false
    else
        ToggleButton.Visible = true
    end
end

-- Klick aufs Viereck macht Fenster AUF und Viereck WEG
ToggleButton.MouseButton1Click:Connect(function()
    SetUIVisibility(true)
end)

-- Suche nach dem Schließen-Button (X) der Kavo Library
task.spawn(function()
    local coreGui = game:GetService("CoreGui")
    -- Wir warten bis die UI da ist
    local mainUI = coreGui:WaitForChild("V-Protocol Tycoon God", 20)
    if mainUI then
        local mainFrame = mainUI:WaitForChild("Main")
        
        -- Wenn du das Fenster manuell über Kavo schließt:
        mainFrame:GetPropertyChangedSignal("Visible"):Connect(function()
            if mainFrame.Visible == false then
                ToggleButton.Visible = true
            else
                ToggleButton.Visible = false
            end
        end)
    end
end)

-- Funktion für den Button im Menü
local function ManualMinimieren()
    SetUIVisibility(false)
end
-------------------------------------------------------------------------
local MainTab = Window:NewTab("Main")
local ShopTab = Window:NewTab("Merchant")
local Credits = Window:NewTab("V-System")

local mSec = MainTab:NewSection("Automation")

-- Ein Button zum manuellen Minimieren (damit das Logo erscheint)
mSec:NewButton("Minimieren / Logo zeigen", "Versteckt das Menü und zeigt das Mini-Logo", function()
    toggleMainUI()
end)

mSec:NewToggle("Auto Cash", "Sammelt Geld", function(s) 
    getgenv().Toggles.Cash = s
    task.spawn(function() while getgenv().Toggles.Cash do Remotes.MoveCash:FireServer() task.wait(0.2) end end)
end)
mSec:NewToggle("Auto Rebirth", "Sofort Rebirth", function(s)
    getgenv().Toggles.Rebirth = s
    task.spawn(function() while getgenv().Toggles.Rebirth do Remotes.Rebirth:FireServer() task.wait(1) end end)
end)
mSec:NewToggle("Auto Chests", "Nimmt Kisten", function(s) getgenv().Toggles.Chests = s end)
Remotes.ChestDrop.OnClientEvent:Connect(function(_, id) if getgenv().Toggles.Chests then Remotes.PickUpChest:FireServer(id) end end)

-- SHOP (Multi-Select)
local sSec = ShopTab:NewSection("Multi-Select Shop")
local function add(v) table.insert(getgenv().SelectedItems, v) print("Added: "..v) end
sSec:NewDropdown("Chambers", "Select", cList, add)
sSec:NewDropdown("Collectors", "Select", colList, add)
sSec:NewDropdown("Upgraders", "Select", upList, add)
sSec:NewDropdown("Conveyors", "Select", convList, add)

sSec:NewToggle("Enable Auto-Buy", "Kauft & Restockt", function(s)
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
sSec:NewButton("Reset Selection", "Liste leeren", function() getgenv().SelectedItems = {} end)

Credits:NewSection("V-Protocol v2.1")
Credits:NewSection("Status: Operational. Logo Fix applied.")
