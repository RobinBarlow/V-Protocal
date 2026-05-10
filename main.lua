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
getgenv().IsSwitching = false -- Die Sperre
local Remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")

-------------------------------------------------------------------------
-- TASKBAR ICON
-------------------------------------------------------------------------
local pGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
if pGui:FindFirstChild("VProtocolTaskbar") then pGui.VProtocolTaskbar:Destroy() end

local sg = Instance.new("ScreenGui", pGui)
sg.Name = "VProtocolTaskbar"
sg.ResetOnSpawn = false

local btn = Instance.new("ImageButton", sg)
local ui = Instance.new("UICorner", btn)

btn.Name = "TaskbarIcon"
btn.Size = UDim2.new(0, 60, 0, 60)
btn.Position = UDim2.new(0.05, 0, 0.15, 0)
btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
btn.Image = "rbxassetid://6031094678"
btn.Visible = false 
btn.Draggable = true
btn.Active = true
btn.ZIndex = 9999
ui.CornerRadius = UDim.new(0, 15)

-- Funktion zum Umschalten mit Sperre
local function SafeToggle()
    if getgenv().IsSwitching then return end
    getgenv().IsSwitching = true
    
    Library:ToggleUI()
    btn.Visible = not btn.Visible
    
    task.wait(1.5) -- Zeit für die UI zum Reagieren
    getgenv().IsSwitching = false
end

btn.MouseButton1Click:Connect(SafeToggle)

-------------------------------------------------------------------------
-- TABS & FUNCTIONS
-------------------------------------------------------------------------
local MainTab = Window:NewTab("Main")
local ShopTab = Window:NewTab("Merchant")
local Credits = Window:NewTab("V-System")

local mSec = MainTab:NewSection("Automation")

mSec:NewButton("Menü minimieren", "Verschieben ins Logo", SafeToggle)

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

-- MERCHANT
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

-- CREDITS
Credits:NewSection("V-Protocol v3.1")

-------------------------------------------------------------------------
-- DER AUTO-WACHHUND (Anti-Flicker)
-------------------------------------------------------------------------
task.spawn(function()
    while task.wait(0.5) do
        if not getgenv().IsSwitching then
            local menuFound = false
            for _, v in pairs(game:GetService("CoreGui"):GetChildren()) do
                if v:IsA("ScreenGui") and v:FindFirstChild("Main") then
                    if v.Main.Visible == true then
                        menuFound = true
                    end
                end
            end
            
            if not menuFound then
                btn.Visible = true
            else
                btn.Visible = false
            end
        end
    end
end)
