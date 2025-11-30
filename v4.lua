
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
----- =======[ GLOBAL FUNCTION ] =======
-------------------------------------------

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
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
    statusInfo.errors = statusInfo.errors + 1
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
    local char = LocalPlayer.Character
    
    if not targetPlayer then
        NotifyError("Teleport Gagal", "Pemain '" .. playerName .. "' tidak ditemukan atau baru saja keluar.")
        return
    end

    local targetChar = targetPlayer.Character
    
    if not char or not char:FindFirstChild("HumanoidRootPart") then
        NotifyError("Teleport Gagal", "Karakter Anda belum dimuat.")
        return
    end

    if not targetChar or not targetChar:FindFirstChild("HumanoidRootPart") then
        NotifyError("Teleport Gagal", "Karakter Player Tujuan belum dimuat.")
        return
    end

    local targetPosition = targetChar.HumanoidRootPart.CFrame * CFrame.new(0, 5, 0) 
    char.HumanoidRootPart.CFrame = targetPosition
    NotifySuccess("Teleport Berhasil", "Berhasil pindah ke lokasi " .. playerName .. ".")
end

local function respawnPlayer()
    local char = Players.LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.Health = 0
        NotifyWarning("Respawn", "Player respawned due to backpack stuck!")
        task.wait(3)
        return true
    end
    return false
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

-- Status tracking
local statusInfo = {
    currentStatus = "Idle",
    tier7Count = 0,
    tradeCount = 0,
    lastRefresh = 0,
    isRunning = false,
    errors = 0
}

local rodRemote = net:WaitForChild("RF/ChargeFishingRod")
local miniGameRemote = net:WaitForChild("RF/RequestFishingMinigameStarted")
local finishRemote = net:WaitForChild("RE/FishingCompleted")
local equipToolRemote = net:WaitForChild("RE/EquipToolFromHotbar")

local Player = Players.LocalPlayer
local XPBar = Player:WaitForChild("PlayerGui"):WaitForChild("XP")

task.spawn(function()
    if XPBar then XPBar.Enabled = true end
end)

local TeleportService = game:GetService("TeleportService")
local PlaceId = game.PlaceId

local function AutoReconnect()
    while task.wait(5) do
        if not Players.LocalPlayer or not Players.LocalPlayer:IsDescendantOf(game) then
            TeleportService:Teleport(PlaceId)
        end
    end
end

Players.LocalPlayer.OnTeleport:Connect(function(teleportState)
    if teleportState == Enum.TeleportState.Failed then
        TeleportService:Teleport(PlaceId)
    end
end)

task.spawn(AutoReconnect)

local RodIdle = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Animations"):WaitForChild("EquipIdle")
local RodReel = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Animations"):WaitForChild("ReelStart")
local RodShake = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Animations"):WaitForChild("StartRodCharge")

local character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)

local RodShakeAnim = animator:LoadAnimation(RodShake)
local RodIdleAnim = animator:LoadAnimation(RodIdle)
local RodReelAnim = animator:LoadAnimation(RodReel)

local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

-------------------------------------------
----- =======[ AUTO BOOST FPS ] =======
-------------------------------------------
local RunService = game:GetService("RunService")
local Terrain = game.Workspace.Terrain

local function OptimizeObject(v)
    
    if v:IsA("BasePart") then
        v.Material = Enum.Material.SmoothPlastic
        v.Reflectance = 0
        v.CastShadow = false
        
    elseif v:IsA("SpecialMesh") or v:IsA("FileMesh") or v:IsA("BlockMesh") then
        v.Scale = Vector3.new(0, 0, 0)
        
    elseif v:IsA("Decal") or v:IsA("Texture") then
        v.Transparency = 1

    elseif v:IsA("SurfaceAppearance") or 
           v:IsA("BloomEffect") or v:IsA("DepthOfFieldEffect") or 
           v:IsA("ColorCorrectionEffect") or v:IsA("ParticleEmitter") or 
           v:IsA("Atmosphere") then
        v:Destroy()
        
    elseif v:IsA("BasePart") or v:IsA("Model") then
        local name = v.Name:lower()
        if name:find("tree") or name:find("bush") or name:find("foliage") or name:find("water") then
            v:Destroy()
        end
    end
end

local function ClearTerrainWater()
    if Terrain then
        Terrain:Clear()
        
    end
end

local function ContinuousFPSBoost()
    
    
    for _, v in game:GetDescendants() do
        OptimizeObject(v)
    end
    
    game.DescendantAdded:Connect(OptimizeObject)
    
    
    RunService.Heartbeat:Connect(function()
        
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        ClearTerrainWater()
        
    end)
    
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
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

local GiveSection = UtilityTab:Section({ Title = "Auto Trade", Icon = "box" })

task.spawn(function()
    pcall(function()
        Remote_InitiateTrade = net:WaitForChild("RF/InitiateTrade", 5) 
    end)
end)
        
local selectedPlayer = nil
local selectedTierValue = nil 

local TIER_MAPPING_V29 = {
    ["Secret"] = 7, 
    ["Mythic"] = 6, 
    ["Legendary"] = 5,
    ["Epic"] = 4,
    ["Rare"] = 3,
    ["Uncommon"] = 2,
    ["Common"] = 1,
}

local tierDisplayNames = {}
for name in pairs(TIER_MAPPING_V29) do table.insert(tierDisplayNames, name) end
table.sort(tierDisplayNames, function(a, b)
    local numA = TIER_MAPPING_V29[a] or 0
    local numB = TIER_MAPPING_V29[b] or 0
    return numA > numB
end)


local function findUUIDByTier(targetTier)
    if not DataReplion or not ItemUtility then return nil end

    local inventoryData = SafeGet(DataReplion, "Inventory") 
    local items = nil
    if inventoryData and type(inventoryData) == "table" then items = inventoryData.Items end
    if not items then items = SafeGet(DataReplion, "Items") end 
    
    if not items or type(items) ~= "table" then return nil end

    local targetTierString = tostring(targetTier)

    for _, item in ipairs(items) do
        if item.Id then
            local base = ItemUtility:GetItemData(item.Id)
            
            if base and base.Data and base.Data.Type == "Fish" then
                local itemTierString = tostring(base.Data.Tier)
                
                if itemTierString == targetTierString then
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
    local items = nil
    if inventoryData and type(inventoryData) == "table" then items = inventoryData.Items end
    if not items then items = SafeGet(DataReplion, "Items") end 
    
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

local TARGET_ISLAND_DATA = { 
    name = "Esoteric Depths", 
    position = Vector3.new(3230.84, -1303, 1453.18) 
}

local function equipFishingToolFromHotbar(slotNumber)
    slotNumber = slotNumber or 1
    
    local success, result = pcall(equipToolRemote.FireServer, equipToolRemote, slotNumber)
    
    if success then
        NotifySuccess("Tool Equipped", "Fishing rod equipped from hotbar slot " .. slotNumber .. "!")
        return true
    else
        NotifyError("Equip Failed", "Failed to equip tool: " .. tostring(result))
        return false
    end
end

local function TeleportToEsotericDepths()
    local data = TARGET_ISLAND_DATA
    local char = Players.LocalPlayer.Character
    
    if char and char:FindFirstChild("HumanoidRootPart") then
        local targetCFrame = CFrame.new(data.position + Vector3.new(0, 5, 0))
        char.HumanoidRootPart.CFrame = targetCFrame
        NotifySuccess("Teleport Berhasil", "Teleported to Esoteric Depths")
        return true
    else
        NotifyError("Teleport Gagal", "Character not found or not loaded!")
        return false
    end
end

GiveSection:Dropdown({
    Title = "Pilih Player",
    Values = getPlayers(),
    Callback = function(v) selectedPlayer = v end
})

GiveSection:Button({
    Title = "Refresh Player",
    Callback = function() GiveSection:UpdateDropdown("Pilih Player", getPlayers()) end
})



GiveSection:Dropdown({
    Title = "Pilih Tier Ikan",
    Content = "Pilih Rarity yang ingin dikirim.",
    Values = tierDisplayNames,
    Callback = function(v)
        local trimmed_v = trim(v)
        
        selectedTierValue = TIER_MAPPING_V29[trimmed_v]
    end
})


GiveSection:Toggle({
    Title = "Start Trade", 
    Callback = function(value)
        state.AutoTrade = value

        if value then
            if not selectedPlayer then
                NotifyError("Error", "Pilih Player")
                state.AutoTrade = false 
                return
            end

            if not selectedTierValue then
                NotifyError("Error", "Pilih Rarity")
                state.AutoTrade = false
                return
            end
            
            if not Remote_InitiateTrade then 
                NotifyWarning("Loading", "Remote InitiateTrade belum dimuat. Menghentikan Trade Loop.")
                state.AutoTrade = false
                return 
            end

            NotifyInfo("Auto Trade Started", "Memulai pengiriman ikan Tier " .. selectedTierValue .. " ke " .. selectedPlayer .. ".")

            task.spawn(function()
                while state.AutoTrade do
                    
                    local selectedTierUUID, fishName, selectedItemId = findUUIDByTier(selectedTierValue)
                    
                    if not selectedTierUUID then
                        NotifySuccess("Trade Loop Selesai", "Semua ikan Tier " .. selectedTierValue .. " di tas Anda telah dikirim!")
                        state.AutoTrade = false
                        break
                    end
                    
                    local targetPlayerObject = Players:FindFirstChild(selectedPlayer)
                    if not targetPlayerObject then
                        NotifyError("Error", "Pemain '" .. selectedPlayer .. "' tidak ditemukan di game! Menghentikan Trade Loop.")
                        state.AutoTrade = false
                        break
                    end
                    local targetUserId = targetPlayerObject.UserId

                    NotifyInfo("Trade Otomatis", string.format("Kirim 1x %s ke %s...", fishName or ("Ikan Tier " .. selectedTierValue), selectedPlayer))

                    local s1, r1 = pcall(Remote_InitiateTrade.InvokeServer, Remote_InitiateTrade, targetUserId, selectedTierUUID) 
                    
                    if not s1 then
                        NotifyError("Trade Gagal (Init/Loop)", "Trade gagal: " .. tostring(r1) .. ". Mencoba lagi dalam 10 detik.")
                        task.wait(10) 
                    else
                        NotifySuccess("Trade Succes!", 
                            string.format("Trade Success, Auto Dalam 2 detik", 
                                fishName or ("Ikan Tier " .. selectedTierValue)))
                        
                        task.wait(2) 
                    end
                end
            end)
        else
            state.AutoTrade = false
            NotifyInfo("Auto Trade Stopped", "Trade loop dihentikan secara manual.")
        end
    end
})

-------------------------------------------
----- [ Item Data Refresh ] ---------------
-------------------------------------------



GiveSection:Button({
    Title = "Refresh Backpack",
    Content = "Refresh",
    Callback = function()
        local success = initializeDataModules() 
        if success then
            NotifySuccess("Refresh Succes")
        else
            NotifyError("Refresh Failed")
        end
    end
})

-------------------------------------------
----- =======[ STATUS DISPLAY ] =======
-------------------------------------------

local StatusSection = UtilityTab:Section({ Title = "System Status", Icon = "activity" })

local statusLabel = StatusSection:Paragraph({
    Title = "Status",
    Content = "🔴 Idle"
})

local statsLabel = StatusSection:Paragraph({
    Title = "Statistics",
    Content = "Tier 7 Found: 0\nTrades Completed: 0\nErrors: 0"
})

-- Function to update status display
local function updateStatusDisplay()
    local statusText = "🔴 Idle"
    if statusInfo.isRunning then
        if state.AutoFishing then
            statusText = "🟢 Fishing at Esoteric Depths"
        elseif state.AutoTrade then
            statusText = "🟡 Trading with erregea_a"
        else
            statusText = "🟠 Monitoring for Tier 7"
        end
    end
    
    statusLabel:SetContent(statusText)
    statsLabel:SetContent(string.format("Tier 7 Found: %d\nTrades Completed: %d\nErrors: %d\nLast Refresh: %s", 
        statusInfo.tier7Count, 
        statusInfo.tradeCount, 
        statusInfo.errors,
        os.date("%H:%M:%S", statusInfo.lastRefresh)
    ))
end

-- Update display every second
task.spawn(function()
    while true do
        task.wait(1)
        updateStatusDisplay()
    end
end)

-------------------------------------------
----- =======[ AUTO FISHING TO TRADE ] =======
-------------------------------------------

local AutoFishingSection = UtilityTab:Section({ Title = "Auto Fishing to Trade", Icon = "wand2" })

local autoFishingToggle = AutoFishingSection:Toggle({
    Title = "Auto Fishing to Trade T7",
    Content = "Auto fish until Tier 7 detected, then trade to erregea_a",
    Value = false,
    Callback = function(value)
        state.AutoFishingToTrade = value

        if value then
            NotifyInfo("Auto Fish to Trade", "Monitoring backpack for Tier 7 fish...")

            task.spawn(function()
                local lastItemCount = 0
                
                while state.AutoFishingToTrade do
                    local success = initializeDataModules()
                    if success then
                        -- Get current item count to detect stuck backpack
                        local inventoryData = SafeGet(DataReplion, "Inventory")
                        local items = nil
                        if inventoryData and type(inventoryData) == "table" then items = inventoryData.Items end
                        if not items then items = SafeGet(DataReplion, "Items") end
                        
                        local currentItemCount = items and #items or 0
                        
                        -- Check if backpack is stuck (item count not changing)
                        if currentItemCount == lastItemCount and lastItemCount > 0 then
                            respawnPlayer()
                            task.wait(4)
                            TeleportToEsotericDepths()
                            task.wait(2)
                            lastItemCount = 0
                        else
                            lastItemCount = currentItemCount
                        end
                        
                        -- Check for Tier 7 after refresh
                        if hasTier7Fish() then
                            state.AutoFishing = false
                            autoFishingToggle:SetValue(false)
                            NotifyInfo("Tier 7 Found", "Starting trade...")
                            task.wait(0.5)

                            -- Teleport to erregea_a
                            local targetPlayer = Players:FindFirstChild("erregea_a")
                            if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                                TeleportToPlayer("erregea_a")
                                task.wait(2)
                            else
                                NotifyError("Error", "erregea_a not in game")
                                state.AutoFishingToTrade = false
                                break
                            end

                            task.wait(5)
                            selectedPlayer = "erregea_a"
                            selectedTierValue = 7

                            if Remote_InitiateTrade then
                                state.AutoTrade = true
                                local tradeCompleted = false

                                task.spawn(function()
                                    while state.AutoTrade and not tradeCompleted do
                                        local selectedTierUUID, fishName, selectedItemId = findUUIDByTier(7)
                                        
                                        if not selectedTierUUID then
                                            state.AutoTrade = false
                                            tradeCompleted = true
                                            break
                                        end
                                        
                                        local targetPlayerObject = Players:FindFirstChild("erregea_a")
                                        if not targetPlayerObject then
                                            state.AutoTrade = false
                                            tradeCompleted = true
                                            break
                                        end
                                        
                                        local targetUserId = targetPlayerObject.UserId
                                        local s1, r1 = pcall(Remote_InitiateTrade.InvokeServer, Remote_InitiateTrade, targetUserId, selectedTierUUID)
                                        
                                        if not s1 then
                                            task.wait(5)
                                        else
                                            task.wait(1)
                                        end
                                    end
                                end)
                                
                                -- Wait for trade to complete
                                while not tradeCompleted and state.AutoFishingToTrade do
                                    task.wait(1)
                                end
                                
                                if tradeCompleted and state.AutoFishingToTrade then
                                    local teleportSuccess = TeleportToEsotericDepths()
                                    if not teleportSuccess then
                                        state.AutoFishingToTrade = false
                                    else
                                        task.wait(1)
                                        equipFishingToolFromHotbar(1)
                                        task.wait(0.5)
                                        state.AutoFishing = true
                                        autoFishingToggle:SetValue(true)
                                    end
                                end
                            else
                                NotifyError("Remote Error", "InitiateTrade remote not loaded!")
                                state.AutoFishingToTrade = false
                            end
                        end
                    end
                    
                    task.wait(120)
                end
            end)
        else
            state.AutoFishingToTrade = false
            state.AutoFishing = false
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
    name = "Esoteric Depths", 
    position = Vector3.new(3230.84, -1303, 1453.18) 
}

local function TeleportToTarget()
    local data = TARGET_ISLAND_DATA
    local char = Players.LocalPlayer.Character
    
    if char and char:FindFirstChild("HumanoidRootPart") then
        local targetCFrame = CFrame.new(data.position + Vector3.new(0, 5, 0))
        char.HumanoidRootPart.CFrame = targetCFrame
        NotifySuccess("Teleport Berhasil", "Berhasil teleport  ke " .. data.name)
        return true
    else
        NotifyError("Teleport Gagal", "Karakter tidak ditemukan atau belum dimuat. Coba lagi!")
        return false
    end
end

TeleportSection:Toggle({
    Title = "Teleport: Esoteric Depths",
    Content = "Klik untuk teleport instan ke pulau Esoteric Depths.",
    Value = false,
    Callback = function(value)
        if value then
            local success = TeleportToTarget()
            
            TeleportSection:UpdateToggle("Teleport: Esoteric Depths", false)
        end
    end
})
