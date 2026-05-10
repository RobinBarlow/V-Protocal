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

-- 1. TOGGLE GUI ERSTELLEN (PlayerGui für Mobile Sicherheit)
local pGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
if pGui:FindFirstChild("VProtocolToggle") then pGui.VProtocolToggle:Destroy() end

local sg = Instance.new("ScreenGui", pGui)
sg.Name = "VProtocolToggle"
sg.ResetOnSpawn = false

local btn = Instance.new("ImageButton", sg)
local ui = Instance.new("UICorner", btn)

btn.Name = "MiniToggle"
btn.Size = UDim2.new(0, 60, 0, 60)
btn.Position = UDim2.new(0.1, 0, 0.15, 0)
btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
btn.Image = "rbxassetid://6031094678"
btn.Draggable = true
btn.Visible = false -- Startet unsichtbar
btn.Active = true
btn.ZIndex = 1000
ui.CornerRadius = UDim.new(0, 15)

-- Funktion: Viereck klicken -> Menü auf
btn.MouseButton1Click:Connect(function()
    Library:ToggleUI()
    btn.Visible = false
end)

-- 2. TABS & SECTIONS
local MainTab = Window:NewTab("Main")
local ShopTab = Window:NewTab("Merchant")
local Credits = Window:NewTab("V-System")

local mSec = MainTab:NewSection("Automation")

-- HIER IST DER KNOPF
mSec:NewButton("Menü minimieren", "Zeigt das Viereck-Logo", function()
    Library:ToggleUI()
    btn.Visible = true
end)

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

-- SHOP SECTION
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

Credits:NewSection("V-Protocol v2.6")

-- 3. DER WACHHUND (Checkt das 'X' Schließen)
task.spawn(function()
    while task.wait(1) do
        local core = game:GetService("CoreGui")
        local found = false
        -- Wir suchen nach dem Kavo Fenster
        for _, v in pairs(core:GetChildren()) do
            if v.Name == "V-Protocol Tycoon God" then
                local main = v:FindFirstChild("Main")
                if main and main.Visible == true then
                    found = true
                end
            end
        end
        -- Wenn Menü weg, Viereck an
        if not found then
            btn.Visible = true
        else
            btn.Visible = false
        end
    end
end)
