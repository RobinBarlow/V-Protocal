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
local Remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")

-------------------------------------------------------------------------
-- REVERSE GUI TOGGLE LOGIC (V-Protocol Special)
-------------------------------------------------------------------------
local sg = Instance.new("ScreenGui", game:GetService("CoreGui"))
local btn = Instance.new("ImageButton", sg)
local ui = Instance.new("UICorner", btn)

sg.Name = "VProtocolToggle"
btn.Size, btn.Position, btn.BackgroundColor3 = UDim2.new(0, 60, 0, 60), UDim2.new(0.02, 0, 0.2, 0), Color3.fromRGB(20, 20, 20)
btn.Image, btn.Draggable, ui.CornerRadius = "rbxassetid://6031094678", true, UDim.new(0, 15)
btn.BorderColor3 = Color3.fromRGB(255, 0, 0) -- Roter Rand für V
btn.BorderSizePixel = 2
btn.ClipsDescendants = true

-- WICHTIG: Am Anfang ist das Logo UNSICHTBAR
btn.Visible = false 

-- Funktion zum Umschalten
local uiVisible = true -- Variable um den Status zu tracken

local function toggleMainUI()
    if uiVisible then
        -- Haupt-UI verstecken
        Library:ToggleUI() -- Versteckt Kavo
        btn.Visible = true -- Mini-Logo zeigen
        uiVisible = false
        print("V-Protocol: Menu minimiert. Logo aktiv.")
    else
        -- Haupt-UI zeigen
        Library:ToggleUI() -- Zeigt Kavo
        btn.Visible = false -- Mini-Logo verstecken
        uiVisible = true
        print("V-Protocol: Menu wiederhergestellt. Logo inaktiv.")
    end
end

-- Klick auf das Logo stellt das Hauptmenü wieder her
btn.MouseButton1Click:Connect(function()
    toggleMainUI()
end)

-------------------------------------------------------------------------
-- TABS & FUNCTIONS (Kavo UI)
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
