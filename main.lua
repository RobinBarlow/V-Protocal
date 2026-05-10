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
-- SMART MINI-TOGGLE LOGIC
-------------------------------------------------------------------------
local sg = Instance.new("ScreenGui", game:GetService("CoreGui"))
local btn = Instance.new("ImageButton", sg)
local ui = Instance.new("UICorner", btn)

sg.Name = "VProtocolToggle"
btn.Size, btn.Position, btn.BackgroundColor3 = UDim2.new(0, 60, 0, 60), UDim2.new(0.02, 0, 0.2, 0), Color3.fromRGB(20, 20, 20)
btn.Image, btn.Draggable, ui.CornerRadius = "rbxassetid://6031094678", true, UDim.new(0, 15)
btn.Visible = false -- Startet unsichtbar

-- Wir suchen das Haupt-Frame der Library
local MainFrame = game:GetService("CoreGui"):WaitForChild("V-Protocol Tycoon God"):FindFirstChild("Main") or game:GetService("CoreGui"):FindFirstChildOfClass("ScreenGui"):FindFirstChild("Main")

-- Wenn das Hauptfenster geschlossen wird (Visible = false), zeige das Logo
if MainFrame then
    MainFrame:GetPropertyChangedSignal("Visible"):Connect(function()
        if MainFrame.Visible == false then
            btn.Visible = true
        else
            btn.Visible = false
        end
    end)
end

-- Klick auf das Logo macht das Fenster wieder auf
btn.MouseButton1Click:Connect(function()
    Library:ToggleUI() -- Das macht das MainFrame wieder Visible
end)

-------------------------------------------------------------------------
-- TABS & FUNCTIONS
-------------------------------------------------------------------------
local MainTab = Window:NewTab("Main")
local ShopTab = Window:NewTab("Merchant")
local Credits = Window:NewTab("V-System")

local mSec = MainTab:NewSection("Automation")
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

-- SHOP
local sSec = ShopTab:NewSection("Multi-Select Shop")
local function add(v) table.insert(getgenv().SelectedItems, v) end
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

Credits:NewSection("V-Protocol v2.2")
Credits:NewSection("Status: Perfect Toggle Active")
