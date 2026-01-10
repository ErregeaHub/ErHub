
-------------------------------------------
----- =======[ Load WindUI ] =======
-------------------------------------------

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local icon = Instance.new("TextButton")
icon.Text = "E"
icon.Size = UDim2.new(0,20,0,20)
icon.Position = UDim2.new(0,20,0,200)
icon.BackgroundTransparency = 0.8
icon.Parent = game.CoreGui

icon.MouseButton1Click:Connect(function()
    WindUI.Window.Visible = not WindUI.Window.Visible
end)





-------------------------------------------
----- =======[ Localized Globals ] =======
-------------------------------------------

local game = game
local workspace = workspace
local Enum = Enum
local task = task
local string = string
local table = table
local pcall = pcall
local CFrame = CFrame
local Vector3 = Vector3
local Vector2 = Vector2
local UDim2 = UDim2
local Instance = Instance
local require = require
local loadstring = loadstring
local settings = settings

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

local Replion
local ItemUtility
local DataReplion

local function trim(s)
    return s:gsub("^%s*(.-)%s*$", "%1")
end

local function NotifySuccess(title, message, duration)
    WindUI:Notify({
        Title = title,
        Content = message,
        Duration = 1,
        Icon = "circle-check"
    })
end

local function NotifyError(title, message, duration)
    WindUI:Notify({
        Title = title,
        Content = message,
        Duration = 1,
        Icon = "ban"
    })
end

local function NotifyInfo(title, message, duration)
    WindUI:Notify({
        Title = title,
        Content = message,
        Duration = 1,
        Icon = "info"
    })
end

local function NotifyWarning(title, message, duration)
    WindUI:Notify({
        Title = title,
        Content = message,
        Duration = duration,
        Icon = "triangle-alert"
    })
end

local function SafeGet(replion, key)
    local success, result = pcall(replion.Get, replion, key)
    if success then
        return result
    else
        print("[KRITIKAL DEBUG] DataReplion:Get('" .. key .. "') GAGAL! Error: " .. tostring(result))
        return nil
    end
end

local function getPlayers()
    local pList = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(pList, p.Name) end
    end
    return pList
end

local function TeleportToPlayer(playerName)
    local targetPlayer = Players:FindFirstChild(playerName)
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    
    if not targetPlayer then
        NotifyError("Teleport Failed", "Player '" .. playerName .. "' not found.")
        return false
    end

    local targetChar = targetPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then
        NotifyError("Teleport Failed", "Your character is not loaded.")
        return false
    end

    if not targetChar or not targetChar:FindFirstChild("HumanoidRootPart") then
        NotifyError("Teleport Failed", "Target character is not loaded.")
        return false
    end

    char.HumanoidRootPart.CFrame = targetChar.HumanoidRootPart.CFrame * CFrame.new(0, 5, 0)
    NotifySuccess("Teleport Success", "Moved to " .. playerName)
    return true
end

local function initializeDataModules()
    local packages = ReplicatedStorage:WaitForChild("Packages", 10)
    local shared = ReplicatedStorage:WaitForChild("Shared", 10)

    if not packages or not shared then 
        NotifyError("Gagal Load", "Packages/Shared folder tidak ditemukan.")
        return false 
    end

    -- Load Replion
    local replionModule = packages:WaitForChild("Replion", 5)
    if replionModule then
        local s, r = pcall(require, replionModule)
        if s then Replion = r end
    end

    -- Load ItemUtility
    local itemUtilityModule = shared:WaitForChild("ItemUtility", 5)
    if itemUtilityModule then
        local s, r = pcall(require, itemUtilityModule)
        if s then ItemUtility = r end
    end

    -- Load Data Client
    if Replion and Replion.Client then
        DataReplion = Replion.Client:WaitReplion("Data")
        if DataReplion then
            NotifyInfo("System Ready", "Data server berhasil terhubung.")
            return true
        end
    end
    NotifyError("Gagal Load", "Replion/DataReplion tidak terhubung.")
    return false
end

task.spawn(function()
    if not initializeDataModules() then
        NotifyError("KRITIKAL", "Fitur Auto-Give & Auto-Sell kemungkinan tidak berfungsi. Coba rejoin game.")
    end
end)

local net = ReplicatedStorage:WaitForChild("Packages")
	:WaitForChild("_Index")
	:WaitForChild("sleitnick_net@0.2.0")
	:WaitForChild("net")
	
local Notifs = { WBN = true, FavBlockNotif = true, FishBlockNotif = true, DelayBlockNotif = true, AFKBN = true, APIBN = true }
local state = { AutoFavourite = false, AutoSell = false, AutoTrade = false, AutoAcceptTrade = false, AutoFishing = false, AutoFishingToTrade = false }

local rodRemote = net:WaitForChild("RF/ChargeFishingRod")
local miniGameRemote = net:WaitForChild("RF/RequestFishingMinigameStarted")
local finishRemote = net:WaitForChild("RE/FishingCompleted")
local equipToolRemote = net:WaitForChild("RE/EquipToolFromHotbar")
local updateAutoFishingRemote = net:WaitForChild("RF/UpdateAutoFishingState")

local function SetAutoFishingState(enabled)
    pcall(updateAutoFishingRemote.InvokeServer, updateAutoFishingRemote, enabled)
end

local function equipFishingToolFromHotbar(slotNumber)
    pcall(equipToolRemote.FireServer, equipToolRemote, slotNumber or 1)
end

local function TeleportToTreasureRoom()
    local char = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart", 10)
    if hrp then
        local targetCFrame = CFrame.new(-3609, -279.07373, -1591, 1, 2.84535484e-09, -1.33540589e-14, -2.84535484e-09, 1, -4.93442265e-08, 1.32136572e-14, 4.93442265e-08, 1)
        hrp.CFrame = targetCFrame
        return true
    end
    return false
end

-- Immediate Mobilization & Asset Engagement
task.spawn(function()
    TeleportToTreasureRoom()
    task.wait(1)
    equipFishingToolFromHotbar(1)
end)

-- Session Security: Anti-AFK
LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

local XPBar = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("XP")

task.spawn(function()
    if XPBar then XPBar.Enabled = true end
end)

local PlaceId = game.PlaceId

local function AutoReconnect()
    while task.wait(5) do
        if not LocalPlayer or not LocalPlayer:IsDescendantOf(game) then
            TeleportService:Teleport(PlaceId)
        end
    end
end

LocalPlayer.OnTeleport:Connect(function(teleportState)
    if teleportState == Enum.TeleportState.Failed then
        TeleportService:Teleport(PlaceId)
    end
end)

task.spawn(AutoReconnect)

local RodIdle = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Animations"):WaitForChild("EquipIdle")
local RodReel = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Animations"):WaitForChild("ReelStart")
local RodShake = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Animations"):WaitForChild("StartRodCharge")

local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)

local RodShakeAnim = animator:LoadAnimation(RodShake)
local RodIdleAnim = animator:LoadAnimation(RodIdle)
local RodReelAnim = animator:LoadAnimation(RodReel)

-------------------------------------------
----- =======[ AUTO BOOST FPS ] =======
-------------------------------------------
local Terrain = workspace.Terrain

local OPTIMIZE_TYPES = {
    ["BasePart"] = function(v)
        v.Material = Enum.Material.SmoothPlastic
        v.Reflectance = 0
        v.CastShadow = false
    end,
    ["SpecialMesh"] = function(v) v.Scale = Vector3.new(0,0,0) end,
    ["FileMesh"] = function(v) v.Scale = Vector3.new(0,0,0) end,
    ["BlockMesh"] = function(v) v.Scale = Vector3.new(0,0,0) end,
    ["Decal"] = function(v) v.Transparency = 1 end,
    ["Texture"] = function(v) v.Transparency = 1 end,
    ["SurfaceAppearance"] = function(v) v:Destroy() end,
    ["BloomEffect"] = function(v) v:Destroy() end,
    ["DepthOfFieldEffect"] = function(v) v:Destroy() end,
    ["ColorCorrectionEffect"] = function(v) v:Destroy() end,
    ["ParticleEmitter"] = function(v) v:Destroy() end,
    ["Atmosphere"] = function(v) v:Destroy() end,
}

local OPTIMIZE_NAMES = { "tree", "bush", "foliage", "water" }

local function OptimizeObject(v)
    local handler = OPTIMIZE_TYPES[v.ClassName]
    if handler then
        handler(v)
    elseif v:IsA("BasePart") or v:IsA("Model") then
        local name = string.lower(v.Name)
        for _, n in ipairs(OPTIMIZE_NAMES) do
            if string.find(name, n) then
                v:Destroy()
                break
            end
        end
    end
end

local function ClearTerrainWater()
    if Terrain then
        Terrain.WaterWaveSize = 0
        Terrain.WaterWaveSpeed = 0
        Terrain.WaterTransparency = 1
        Terrain.WaterReflectance = 0
    end
end

local function ContinuousFPSBoost()
    local lighting = game:GetService("Lighting")
    
    local function process(parent)
        for _, v in ipairs(parent:GetDescendants()) do
            OptimizeObject(v)
        end
    end

    process(workspace)
    process(lighting)
    
    workspace.DescendantAdded:Connect(OptimizeObject)
    lighting.DescendantAdded:Connect(OptimizeObject)
    
    task.spawn(function()
        while true do
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
            ClearTerrainWater()
            task.wait(10)
        end
    end)
end

ContinuousFPSBoost()

-------------------------------------------
----- =======[ LOAD WINDOW ] =======
-------------------------------------------

local Window = WindUI:CreateWindow({
    Title = "ErHub V2",
    Icon = "fish",
    Author = "by @Erregea",
    Folder = "Erregea",
    Resizable = true,
    HideSearchBar = true,
    SideBarWidth = 45,
    Size = UDim2.fromOffset(220, 120),
    MinSize = Vector2.new(420, 250),
    BackgroundTransparency = 0.1,
    Theme = "Dark",
    KeySystem = false
})

local UIS = game:GetService("UserInputService")
local dragging, dragStart, startPos

icon.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = icon.Position
    end
end)

icon.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
        local delta = input.Position - dragStart
        icon.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

icon.MouseButton1Click:Connect(function()
    Window.Window.Visible = not Window.Window.Visible
end)

Window:SetToggleKey(Enum.KeyCode.G)
WindUI:SetNotificationLower(true)

-------------------------------------------
----- =======[ MAIN TABS ] =======
-------------------------------------------


local UtilityTab = Window:Tab({ Title = "", Icon = "settings" })


-------------------------------------------
----- =======[ AUTO GIVE SYSTEM ] =======
-------------------------------------------

task.spawn(function()
    pcall(function()
        Remote_InitiateTrade = net:WaitForChild("RF/InitiateTrade", 5) 
    end)
end)

-- Peta statis Tier Display Name ke Nilai Internal Tier (Angka)
local TIER_MAPPING = {
    ["Secret"] = 7, 
    ["Mythic"] = 6, 
    ["Legendary"] = 5,
    ["Epic"] = 4,
    ["Rare"] = 3,
    ["Uncommon"] = 2,
    ["Common"] = 1,
}

-- List untuk Dropdown (Diurutkan dari tertinggi ke terendah)
local tierDisplayNames = {}
for name in pairs(TIER_MAPPING) do table.insert(tierDisplayNames, name) end
table.sort(tierDisplayNames, function(a, b)
    local numA = TIER_MAPPING[a] or 0
    local numB = TIER_MAPPING[b] or 0
    return numA > numB
end)

local function findUUIDByTier(targetTier)
    if not DataReplion or not ItemUtility then return nil end

    local inventoryData = SafeGet(DataReplion, "Inventory") 
    local items = (inventoryData and inventoryData.Items) or SafeGet(DataReplion, "Items")
    
    if not items or type(items) ~= "table" then return nil end

    local targetTierString = tostring(targetTier)

    for _, item in ipairs(items) do
        if item.Id then
            local base = ItemUtility:GetItemData(item.Id)
            if base and base.Data and base.Data.Type == "Fish" then
                if tostring(base.Data.Tier) == targetTierString then
                    return item.UUID, base.Data.Name, item.Id 
                end
            end
        end
    end
    return nil 
end

local function hasTier7Fish()
    if not DataReplion or not ItemUtility then return false end

    local inventoryData = SafeGet(DataReplion, "Inventory") 
    local items = (inventoryData and inventoryData.Items) or SafeGet(DataReplion, "Items")
    
    if not items or type(items) ~= "table" then return false end

    for _, item in ipairs(items) do
        if item.Id then
            local base = ItemUtility:GetItemData(item.Id)
            if base and base.Data and base.Data.Type == "Fish" and base.Data.Tier == 7 then
                return true
            end
        end
    end
    return false
end



local function AutoFishingLoop()
    while true do
        if state.AutoFishing then
            pcall(function()
                rodRemote:InvokeServer(100, 1)
                task.wait(0.5)
                miniGameRemote:InvokeServer()
                task.wait(2)
                finishRemote:FireServer(true)
            end)
        end
        task.wait(1)
    end
end
task.spawn(AutoFishingLoop)


-------------------------------------------
----- =======[ AUTO FISHING TO TRADE ] =======
-------------------------------------------

local AutoFishingSection = UtilityTab:Section({ Title = "Full Auto", Icon = "wand2" })

AutoFishingSection:Toggle({
    Title = "Auto Fishing",
    Value = false,
    Callback = function(value)
        state.AutoFishing = value
        SetAutoFishingState(value)
    end
})

AutoFishingSection:Toggle({
    Title = "Full Auto (Tier 7)",
    Value = false,
    Callback = function(value)
        state.AutoFishingToTrade = value
        if value then
            state.AutoFishing = true
            SetAutoFishingState(true)
            NotifyInfo("Full Auto Enabled", "Monitoring for Tier 7 fish...")
        else
            state.AutoFishing = false
            SetAutoFishingState(false)
        end
    end
})

-- Real-time Inventory Monitor & Trade Logic
task.spawn(function()
    while true do
        if state.AutoFishingToTrade then
            if hasTier7Fish() then
                state.AutoFishing = false
                SetAutoFishingState(false)
                NotifyWarning("Tier 7 Detected!", "Halt fishing. Teleporting to ruptor02...")
                
                local targetPlayer = Players:FindFirstChild("ruptor02")
                if targetPlayer then
                    TeleportToPlayer("ruptor02")
                    task.wait(5)
                    
                    local uuid, fishName = findUUIDByTier(7)
                    if uuid and Remote_InitiateTrade then
                        NotifyInfo("Trading", "Initiating trade with ruptor02...")
                        local success, err = pcall(Remote_InitiateTrade.InvokeServer, Remote_InitiateTrade, targetPlayer.UserId, uuid)
                        
                        if success then
                            NotifySuccess("Trade Success", "Tier 7 fish sent!")
                            task.wait(6) -- Sync with tradesystem.lua safe wait
                            TeleportToTreasureRoom()
                            task.wait(2)
                            equipFishingToolFromHotbar(1)
                            state.AutoFishing = true
                            SetAutoFishingState(true)
                        else
                            NotifyError("Trade Failed", tostring(err))
                            task.wait(10) -- Sync with tradesystem.lua error wait
                        end
                    end
                else
                    NotifyError("Target Not Found", "ruptor02 not in game. Waiting...")
                end
            end
        end
        task.wait(5)
    end
end)

-------------------------------------------
----- =======[ MANUAL TRADE SYSTEM ] =======
-------------------------------------------

local ManualTradeSection = UtilityTab:Section({ Title = "Manual Trade", Icon = "box" })
local manualSelectedPlayer = nil
local manualSelectedTierValue = nil

ManualTradeSection:Dropdown({
    Title = "Pilih Player",
    Values = getPlayers(),
    Callback = function(v) manualSelectedPlayer = v end
})

ManualTradeSection:Button({
    Title = "Refresh Player List",
    Callback = function() ManualTradeSection:UpdateDropdown("Pilih Player", getPlayers()) end
})

ManualTradeSection:Dropdown({
    Title = "Pilih Tier Ikan",
    Values = tierDisplayNames,
    Callback = function(v)
        manualSelectedTierValue = TIER_MAPPING[trim(v)]
        if manualSelectedTierValue then
            NotifyInfo("Tier Dipilih", "Siap kirim Tier: " .. v)
        end
    end
})

ManualTradeSection:Toggle({
    Title = "Start Manual Trade",
    Callback = function(value)
        state.AutoTrade = value
        if value then
            if not manualSelectedPlayer or not manualSelectedTierValue then
                NotifyError("Error", "Pilih Player dan Tier dulu!")
                state.AutoTrade = false
                ManualTradeSection:UpdateToggle("Start Manual Trade", false)
                return
            end
            
            NotifyInfo("Manual Trade Started", "Sending Tier " .. manualSelectedTierValue .. " fish to " .. manualSelectedPlayer)
            
            task.spawn(function()
                while state.AutoTrade do
                    local uuid, fishName = findUUIDByTier(manualSelectedTierValue)
                    if not uuid then
                        NotifySuccess("Done", "All Tier " .. manualSelectedTierValue .. " fish sent!")
                        state.AutoTrade = false
                        ManualTradeSection:UpdateToggle("Start Manual Trade", false)
                        break
                    end
                    
                    local target = Players:FindFirstChild(manualSelectedPlayer)
                    if not target then
                        NotifyError("Error", "Player left!")
                        state.AutoTrade = false
                        ManualTradeSection:UpdateToggle("Start Manual Trade", false)
                        break
                    end
                    
                    NotifyInfo("Trading", "Sending " .. (fishName or "fish") .. "...")
                    local s, r = pcall(Remote_InitiateTrade.InvokeServer, Remote_InitiateTrade, target.UserId, uuid)
                    
                    if not s then
                        NotifyError("Failed", tostring(r))
                        task.wait(10)
                    else
                        NotifySuccess("Success", "Sent! Waiting 6s...")
                        task.wait(6)
                    end
                end
            end)
        end
    end
})

ManualTradeSection:Button({
    Title = "Refresh Backpack",
    Callback = function()
        if initializeDataModules() then
            NotifySuccess("Success", "Backpack refreshed")
        else
            NotifyError("Failed", "Refresh failed")
        end
    end
})

-------------------------------------------
----- =======[ UTILITY TAB ] =======
-------------------------------------------

local selectedPlayerForTeleport = nil 

local PlayerTeleportSection = UtilityTab:Section({ Title = "Teleport to Player", Icon = "user-check" })

PlayerTeleportSection:Dropdown({
    Title = "Pilih Player Tujuan",
    Values = getPlayers(), 
    Callback = function(v) selectedPlayerForTeleport = v end
})

PlayerTeleportSection:Button({
    Title = "Refresh Player List",
    Callback = function() PlayerTeleportSection:UpdateDropdown("Pilih Player Tujuan", getPlayers()) end
})

PlayerTeleportSection:Button({
    Title = "Teleport Now!",
    Callback = function()
        if not selectedPlayerForTeleport then
            NotifyError("Error", "Pilih Player yang ingin dituju dulu!")
            return
        end
        TeleportToPlayer(selectedPlayerForTeleport)
    end
})

local TeleportSection = UtilityTab:Section({ Title = "Island Teleport", Icon = "map-pin" })

local TARGET_ISLAND_DATA = { 
    name = "Treasure Room", 
    -- position = Vector3.new(-1518.46802, 7.875, 1913.32983,  -0.45599404, -0.00000005, -0.88998282, -0.00000002, 1.00000000, -0.00000004, 0.88998282, -0.00000001, -0.45599404) 
}

local function TeleportToTarget()
    
    local char = Players.LocalPlayer.Character
    
    if char and char:FindFirstChild("HumanoidRootPart") then
        local targetCFrame = CFrame.new(-3609, -279.07373, -1591, 1, 2.84535484e-09, -1.33540589e-14, -2.84535484e-09, 1, -4.93442265e-08, 1.32136572e-14, 4.93442265e-08, 1)
        char.HumanoidRootPart.CFrame = targetCFrame
        NotifySuccess("Teleport Berhasil", "Berhasil teleport ke " .. TARGET_ISLAND_DATA.name)
        return true
    else
        NotifyError("Teleport Gagal", "Karakter tidak ditemukan atau belum dimuat. Coba lagi!")
        return false
    end
end

TeleportSection:Toggle({
    Title = "Teleport: Treasure Room",
    Content = "Klik untuk teleport instan ke Treasure Room.",
    Value = false,
    Callback = function(value)
        if value then
            local success = TeleportToTarget()
            
            TeleportSection:UpdateToggle("Teleport: Treasure Room", false)
        end
    end
})