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
-- HAUPT-GUI FINDEN (nach Library.CreateLib)
-------------------------------------------------------------------------
local mainFrame = nil
task.spawn(function()
    task.wait(1)
    -- Kavo speichert GUI im CoreGui
    for _, gui in pairs(game:GetService("CoreGui"):GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Name == "V-Protocol Tycoon God" then
            for _, child in pairs(gui:GetChildren()) do
                if child:IsA("Frame") then
                    mainFrame = child
                    break
                end
            end
        end
    end
end)

local function ShowMenu()
    if mainFrame then mainFrame.Visible = true end
end

local function HideMenu()
    if mainFrame then mainFrame.Visible = false end
end

-------------------------------------------------------------------------
-- TASKBAR ICON
-------------------------------------------------------------------------
local pGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
if pGui:FindFirstChild("VProtocolTaskbar") then pGui.VProtocolTaskbar:Destroy() end

local sg = Instance.new("ScreenGui", pGui)
sg.Name = "VProtocolTaskbar"
sg.ResetOnSpawn = false

local btn = Instance.new("ImageButton", sg)
Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 15)

btn.Size = UDim2.new(0, 60, 0, 60)
btn.Position = UDim2.new(0.05, 0, 0.2, 0)
btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
btn.Image = "rbxassetid://6031094678"
btn.Visible = false
btn.Draggable = true
btn.Active = true
btn.ZIndex = 9999

-- Icon klicken = Menü öffnen
btn.MouseButton1Click:Connect(function()
    btn.Visible = false
    ShowMenu()
end)

-------------------------------------------------------------------------
-- TABS
-------------------------------------------------------------------------
local MainTab = Window:NewTab("Main")
local ShopTab = Window:NewTab("Merchant")
local Credits = Window:NewTab("V-System")
local mSec = MainTab:NewSection("Automation")

-- Minimieren Button im Menü
mSec:NewButton("Menü minimieren", "Icon zeigen", function()
    HideMenu()
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

Credits:NewSection("V-Protocol v3.2")

-------------------------------------------------------------------------
-- WATCHDOG: erkennt X-Button der Kavo Library
-------------------------------------------------------------------------
task.spawn(function()
    task.wait(2)
    
    -- X-Button der Library finden und Hook setzen
    for _, gui in pairs(game:GetService("CoreGui"):GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Name == "V-Protocol Tycoon God" then
            local closeBtn = gui:FindFirstChild("Close", true)
            if closeBtn then
                closeBtn.MouseButton1Click:Connect(function()
                    task.wait(0.1)
                    btn.Visible = true
                end)
            end
        end
    end
    
    -- Loop: falls X gedrückt aber Hook hat nicht gegriffen
    while task.wait(0.3) do
        pcall(function()
            if mainFrame and not mainFrame.Visible then
                btn.Visible = true
            end
        end)
    end
end)
