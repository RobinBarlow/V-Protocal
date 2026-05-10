local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("V-Protocol Tycoon God", "DarkTheme")

-- DATA LISTS (Aus deinen Logs)
local cList = {"Chamber_Void", "Chamber_Plasma", "Chamber_Infernal", "Chamber_Ruby", "Chamber_Legendary", "Chamber_Obsidian", "Chamber_Epic", "Chamber_Emerald", "Chamber_Candy", "Chamber_Ancient"}
local colList = {"Collector_Void", "Collector_Plasma", "Collector_Infernal", "Collector_Astral", "Collector_Epic", "Collector_Legendary", "Collector_Emerald", "Collector_Radioactive", "Collector_Candy", "Collector_Ancient"}
local upList = {"Upgrader_Void", "Upgrader_Plasma", "Upgrader_Infernal", "Upgrader_Legendary", "Upgrader_Obsidian", "Upgrader_Epic", "Upgrader_Ruby", "Upgrader_Rare", "Upgrader_Candy", "Upgrader_Ancient"}
local convList = {"Conveyor_Plasma", "Conveyor_Astral", "Conveyor_Obsidian", "Conveyor_Infernal", "Conveyor_Cybernetic", "Conveyor_Radioactive", "DownwardsConveyor_Astral", "UpwardsConveyor_Ruby"}

-- GLOBALS
getgenv().Toggles = {Cash = false, Rebirth = false, Chests = false, AutoBuy = false}
getgenv().SelectedItems = {}
local Remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")

-- TABS ERSTELLEN
local MainTab = Window:NewTab("Main")
local ShopTab = Window:NewTab("Merchant")
local Credits = Window:NewTab("V-System")

-- AUTOMATION SECTION
local mSec = MainTab:NewSection("Automation")

mSec:NewToggle("Auto Collect Cash", "Geld einsammeln", function(s) 
    getgenv().Toggles.Cash = s
    task.spawn(function() while getgenv().Toggles.Cash do Remotes.MoveCash:FireServer() task.wait(0.2) end end)
end)

mSec:NewToggle("Auto Rebirth", "Sofort Rebirth", function(s)
    getgenv().Toggles.Rebirth = s
    task.spawn(function() while getgenv().Toggles.Rebirth do Remotes.Rebirth:FireServer() task.wait(1) end end)
end)

mSec:NewToggle("Auto Pick Chests", "Kisten sammeln", function(s) getgenv().Toggles.Chests = s end)
Remotes.ChestDrop.OnClientEvent:Connect(function(_, id) if getgenv().Toggles.Chests then Remotes.PickUpChest:FireServer(id) end end)

-- MERCHANT SECTION
local sSec = ShopTab:NewSection("Multi-Select Shop")
local function add(v) table.insert(getgenv().SelectedItems, v) end

sSec:NewDropdown("Chambers", "Hinzufügen", cList, add)
sSec:NewDropdown("Collectors", "Hinzufügen", colList, add)
sSec:NewDropdown("Upgraders", "Hinzufügen", upList, add)
sSec:NewDropdown("Conveyors", "Hinzufügen", convList, add)

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

sSec:NewButton("Reset Selection", "Liste leeren", function() getgenv().SelectedItems = {} end)

-- CREDITS
Credits:NewSection("V-Protocol by Gemini")
Credits:NewSection("Status: God Mode Active")
-------------------------------------------------------------------------
-- V-PROTOCOL ULTRA TOGGLE (Fix für das rote X)
-------------------------------------------------------------------------
local sg = Instance.new("ScreenGui", game:GetService("CoreGui"))
local btn = Instance.new("ImageButton", sg)
local ui = Instance.new("UICorner", btn)

sg.Name = "VProtocolToggle"
sg.ResetOnSpawn = false
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

btn.Size = UDim2.new(0, 60, 0, 60)
btn.Position = UDim2.new(0.02, 0, 0.2, 0) -- Deine Position
btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
btn.Image = "rbxassetid://6031094678" -- Das Logo
btn.Draggable = true
btn.Visible = false -- Startet unsichtbar, da Menü offen ist
btn.Active = true
ui.CornerRadius = UDim.new(0, 15)

-- Die Funktion zum Wiederherstellen
btn.MouseButton1Click:Connect(function()
    Library:ToggleUI() -- Öffnet das Menü
    btn.Visible = false -- Versteckt das Viereck
end)

-- DER ULTIMATIVE WACHHUND
task.spawn(function()
    local cg = game:GetService("CoreGui")
    -- Wir warten auf die GUI der Library
    local gui = cg:WaitForChild("V-Protocol Tycoon God", 20)
    
    if gui then
        -- Kavo nutzt oft das Enabled Property der ScreenGui oder Visible des MainFrames
        local mainFrame = gui:FindFirstChild("Main")
        
        -- Überwachung 1: Das Enabled-Property (Falls das X die ganze GUI ausschaltet)
        gui:GetPropertyChangedSignal("Enabled"):Connect(function()
            if gui.Enabled == false then
                btn.Visible = true
            else
                btn.Visible = false
            end
        end)

        -- Überwachung 2: Das Visible-Property (Falls nur das Frame versteckt wird)
        if mainFrame then
            mainFrame:GetPropertyChangedSignal("Visible"):Connect(function()
                if mainFrame.Visible == false then
                    btn.Visible = true
                else
                    btn.Visible = false
                end
            end)
        end
    end
end)
-------------------------------------------------------------------------
