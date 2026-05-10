local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("V-Protocol Tycoon God", "DarkTheme")

print("[DEBUG] Script gestartet...")

-- GLOBALS
getgenv().Toggles = {Cash = false, Rebirth = false, Chests = false, AutoBuy = false}
getgenv().SelectedItems = {}
local Remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")

-------------------------------------------------------------------------
-- TASKBAR ICON (Das 4eck)
-------------------------------------------------------------------------
local targetParent = (gethui and gethui()) or game:GetService("CoreGui") or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
print("[DEBUG] Zielordner für Taskbar: " .. targetParent.Name)

if targetParent:FindFirstChild("VProtocolTaskbar") then 
    targetParent.VProtocolTaskbar:Destroy() 
    print("[DEBUG] Alte Taskbar gelöscht.")
end

local sg = Instance.new("ScreenGui", targetParent)
sg.Name = "VProtocolTaskbar"
sg.ResetOnSpawn = false
sg.DisplayOrder = 99999

local btn = Instance.new("ImageButton", sg)
Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
btn.Size = UDim2.new(0, 60, 0, 60)
btn.Position = UDim2.new(0.1, 0, 0.5, 0) 
btn.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- HELLROT zum Testen!
btn.Image = "rbxassetid://6031094678" 
btn.Visible = false
btn.Draggable = true
btn.Active = true

print("[DEBUG] Taskbar-Button erstellt (noch unsichtbar).")

-------------------------------------------------------------------------
-- KAVO GUI FINDER
-------------------------------------------------------------------------
local kavoGui = nil
local mainFrame = nil

task.spawn(function()
    print("[DEBUG] Suche nach Kavo-Menü...")
    while not kavoGui do
        for _, p in pairs({targetParent, game:GetService("CoreGui"), game:GetService("Players").LocalPlayer.PlayerGui}) do
            local found = p:FindFirstChild("V-Protocol Tycoon God")
            if found then 
                kavoGui = found 
                mainFrame = found:FindFirstChild("Main")
                print("[DEBUG] Kavo-GUI gefunden in: " .. p.Name)
                if mainFrame then print("[DEBUG] MainFrame erfolgreich identifiziert.") end
                break 
            end
        end
        task.wait(1)
    end
end)

btn.MouseButton1Click:Connect(function()
    print("[DEBUG] Taskbar-Button geklickt! Öffne Menü...")
    if kavoGui then
        kavoGui.Enabled = true
        if mainFrame then mainFrame.Visible = true end
        btn.Visible = false
    else
        print("[DEBUG] FEHLER: kavoGui nicht gefunden beim Klicken.")
    end
end)

-------------------------------------------------------------------------
-- TABS & CONTENT (Gekürzt für Übersicht)
-------------------------------------------------------------------------
local MainTab = Window:NewTab("Main")
local mSec = MainTab:NewSection("Automation")

mSec:NewToggle("Auto Collect Cash", "Geld sammeln", function(s)
    getgenv().Toggles.Cash = s
    task.spawn(function() while getgenv().Toggles.Cash do Remotes.MoveCash:FireServer() task.wait(0.2) end end)
end)

-- (Hier kämen die anderen Toggles/Tabs wie gehabt...)
print("[DEBUG] UI-Elemente geladen.")

-------------------------------------------------------------------------
-- DER DETEKTIV (WATCHDOG MIT PRINTS)
-------------------------------------------------------------------------
task.spawn(function()
    local lastState = nil
    print("[DEBUG] Watchdog gestartet.")
    
    while task.wait(0.5) do
        if kavoGui then
            -- Wir prüfen, ob das Fenster physikalisch sichtbar ist
            local isGuiEnabled = kavoGui.Enabled
            local isMainVisible = mainFrame and mainFrame.Visible or false
            
            -- Das Menü gilt als "geschlossen", wenn die GUI aus ist ODER das Main-Fenster unsichtbar
            local isHidden = (not isGuiEnabled) or (not isMainVisible)
            
            -- Nur printen, wenn sich der Zustand ändert (um Konsole nicht zu spammen)
            if isHidden ~= lastState then
                print("[DEBUG] Zustand geändert! Hidden: " .. tostring(isHidden) .. " (Enabled: " .. tostring(isGuiEnabled) .. ", MainVisible: " .. tostring(isMainVisible) .. ")")
                btn.Visible = isHidden
                lastState = isHidden
            end
        else
            -- Falls die GUI noch nicht gefunden wurde
            -- print("[DEBUG] Watchdog wartet auf GUI...")
        end
    end
end)
