--[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
    
    Ultimate Fix Luau (Version 27 - Auto-Trade Loop & Item Exhaustion Check)
    - NEW FEATURE: The 'Trade' toggle now runs in a loop, continuously performing the trade 
      for the selected tier until the user runs out of that item (exhaustion check).
    - Added state.AutoTrade to control the loop.
    - Added a safe delay (6 seconds) between successful trades.
    - Updated success/stop notifications for the new loop behavior.
    - Preserves all previous fixes (GUI non-blocking load, correct remote names and arguments).
]]
-------------------------------------------
----- =======[ Load WindUI ] =======
-------------------------------------------

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local icon = Instance.new("TextButton")
icon.Text = "E"
icon.Size = UDim2.new(0,40,0,40)
icon.Position = UDim2.new(0,20,0,200)
icon.BackgroundTransparency = 0.3
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

-- Init Variables
local Replion
local ItemUtility
local DataReplion

-- Fungsi untuk menghapus spasi di awal dan akhir string
local function trim(s)
    return s:gsub("^%s*(.-)%s*$", "%1")
end

local function NotifySuccess(title, message, duration)
    WindUI:Notify({
        Title = title,
        Content = message,
        Duration = duration,
        Icon = "circle-check"
    })
end

local function NotifyError(title, message, duration)
    WindUI:Notify({
        Title = title,
        Content = message,
        Duration = duration,
        Icon = "ban"
    })
end

local function NotifyInfo(title, message, duration)
    WindUI:Notify({
        Title = title,
        Content = message,
        Duration = duration,
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

-- FIX: Fungsi Inisialisasi Modul
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
-- V27: Tambahkan state.AutoTrade
local state = { AutoFavourite = false, AutoSell = false, AutoTrade = false }

local rodRemote = net:WaitForChild("RF/ChargeFishingRod")
local miniGameRemote = net:WaitForChild("RF/RequestFishingMinigameStarted")
local finishRemote = net:WaitForChild("RE/FishingCompleted")

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
local function BoostFPS()
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("BasePart") then
            v.Material = Enum.Material.SmoothPlastic
            v.Reflectance = 0
        elseif v:IsA("Decal") or v:IsA("Texture") then
            v.Transparency = 1
        end
    end
    settings().Rendering.QualityLevel = "Level01"
end
BoostFPS()

-------------------------------------------
----- =======[ LOAD WINDOW ] =======
-------------------------------------------

local Window = WindUI:CreateWindow({
    Title = "Erregea",
    Icon = "door-open", -- lucide icon
    Author = "by Erregea",
    Folder = "Erregea",
    
    -- ↓ This all is Optional. You can remove it.
    Size = UDim2.fromOffset(290, 230),
    MaxSize = Vector2.new(850, 560),
    Transparent = true,
    Theme = "Red",
    Resizable = true,
    SideBarWidth = 140,
    BackgroundImageTransparency = 0.85,
    HideSearchBar = true,
    ScrollBarEnabled = false,
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

local AutoFishTab = Window:Tab({ Title = "Auto Fishing", Icon = "fish" })
local GiveTab = Window:Tab({ Title = "Trade Features", Icon = "gift" })
local UtilityTab = Window:Tab({ Title = "Utility", Icon = "settings" })
local SettingsTab = Window:Tab({ Title = "Settings", Icon = "user-cog" })

-------------------------------------------
----- =======[ AUTO FISHING TAB ] =======
-------------------------------------------

local AutoFishSection = AutoFishTab:Section({ Title = "Fishing Automation", Icon = "fish" })

local FuncAutoFishV2 = {
	REReplicateTextEffectV2 = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/ReplicateTextEffect"],
	autofishV2 = false,
	perfectCastV2 = true,
	fishingActiveV2 = false,
	delayInitializedV2 = false
}

local RodDelaysV2 = {
    ["Ares Rod"] = {custom = 1.12, bypass = 1.45},
    ["Angler Rod"] = {custom = 1.12, bypass = 1.45},
    ["Ghostfinn Rod"] = {custom = 0.75, bypass = 2.35},
    ["Astral Rod"] = {custom = 1.9, bypass = 1.45},
    ["Chrome Rod"] = {custom = 2.3, bypass = 2},
    ["Steampunk Rod"] = {custom = 2.5, bypass = 2.3},
    ["Lucky Rod"] = {custom = 3.5, bypass = 3.6},
    ["Midnight Rod"] = {custom = 3.3, bypass = 3.4},
    ["Demascus Rod"] = {custom = 3.9, bypass = 3.8},
    ["Grass Rod"] = {custom = 3.8, bypass = 3.9},
    ["Luck Rod"] = {custom = 4.2, bypass = 4.1},
    ["Carbon Rod"] = {custom = 4, bypass = 3.8},
    ["Lava Rod"] = {custom = 4.2, bypass = 4.1},
    ["Starter Rod"] = {custom = 4.3, bypass = 4.2},
}

local customDelayV2 = 1
local BypassDelayV2 = 0.5

local function getValidRodNameV2()
    local player = Players.LocalPlayer
    local display = player.PlayerGui:WaitForChild("Backpack"):WaitForChild("Display")
    for _, tile in ipairs(display:GetChildren()) do
        local success, itemNamePath = pcall(function() return tile.Inner.Tags.ItemName end)
        if success and itemNamePath and itemNamePath:IsA("TextLabel") then
            local name = itemNamePath.Text
            if RodDelaysV2[name] then return name end
        end
    end
    return nil
end

local function updateDelayBasedOnRodV2(showNotify)
    if FuncAutoFishV2.delayInitializedV2 then return end
    local rodName = getValidRodNameV2()
    if rodName and RodDelaysV2[rodName] then
        customDelayV2 = RodDelaysV2[rodName].custom
        BypassDelayV2 = RodDelaysV2[rodName].bypass
        FuncAutoFishV2.delayInitializedV2 = true
        if showNotify and FuncAutoFishV2.autofishV2 then
            NotifySuccess("Rod Detected", string.format("%s | Delay: %.2f", rodName, customDelayV2))
        end
    else
        customDelayV2 = 10
        BypassDelayV2 = 1
        FuncAutoFishV2.delayInitializedV2 = true
    end
end

local function setupRodWatcher()
    local player = Players.LocalPlayer
    local display = player.PlayerGui:WaitForChild("Backpack"):WaitForChild("Display")
    display.ChildAdded:Connect(function()
        task.wait(0.05)
        if not FuncAutoFishV2.delayInitializedV2 then updateDelayBasedOnRodV2(true) end
    end)
end
setupRodWatcher()

local lastSellTime = 0
local AUTO_SELL_THRESHOLD = 60 
local AUTO_SELL_DELAY = 60 

local function getNetFolder() return net end

local function startAutoSell()
    task.spawn(function()
        while state.AutoSell do
            pcall(function()
                if not Replion or not DataReplion or not ItemUtility then return end
                
                -- FIX PENCARIAN ITEM (ULTIMATE FIX)
                local inventoryData = DataReplion:Get("Inventory")
                local items = nil
                if inventoryData and type(inventoryData) == "table" then items = inventoryData.Items end
                if not items then items = DataReplion:Get("Items") end -- Fallback
                if not items or type(items) ~= "table" then return end

                local unfavoritedCount = 0
                for _, item in ipairs(items) do
                    if item.Id then
                        local base = ItemUtility:GetItemData(item.Id)
                        if base and base.Data and base.Data.Type == "Fish" then
                            if not item.Favorited then
                                unfavoritedCount = unfavoritedCount + (item.Quantity or 1)
                            end
                        end
                    end
                end

                if unfavoritedCount >= AUTO_SELL_THRESHOLD and os.time() - lastSellTime >= AUTO_SELL_DELAY then
                    local netFolder = getNetFolder()
                    if netFolder then
                        local sellFunc = netFolder:FindFirstChild("RF/SellAllItems")
                        if sellFunc then
                            task.spawn(sellFunc.InvokeServer, sellFunc)
							NotifyInfo("Auto Sell", "Selling items...")
                            lastSellTime = os.time()
                        end
                    end
                end
            end)
            task.wait(10)
        end
    end)
end

FuncAutoFishV2.REReplicateTextEffectV2.OnClientEvent:Connect(function(data)
    if FuncAutoFishV2.autofishV2 and FuncAutoFishV2.fishingActiveV2
    and data and data.TextData and data.TextData.EffectType == "Exclaim" then
        local myHead = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("Head")
        if myHead and data.Container == myHead then
            task.spawn(function()
                for i = 1, 3 do
                    task.wait(BypassDelayV2)
                    finishRemote:FireServer()
                end
            end)
        end
    end
end)

function StartAutoFishV2()
    if FuncAutoFishV2.autofishV2 then return end
    FuncAutoFishV2.autofishV2 = true
    updateDelayBasedOnRodV2(true)
    task.spawn(function()
        while FuncAutoFishV2.autofishV2 do
            pcall(function()
                FuncAutoFishV2.fishingActiveV2 = true
                local equipRemote = net:WaitForChild("RE/EquipToolFromHotbar")
                equipRemote:FireServer(1)
                task.wait(0.1)
                local chargeRemote = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/ChargeFishingRod"]
                chargeRemote:InvokeServer(workspace:GetServerTimeNow())
                task.wait(0.5)
                local timestamp = workspace:GetServerTimeNow()
                RodShakeAnim:Play()
                rodRemote:InvokeServer(timestamp)
                local baseX, baseY = -0.7499996423721313, 1
                local x, y
                if FuncAutoFishV2.perfectCastV2 then
                    x = baseX + (math.random(-500, 500) / 10000000)
                    y = baseY + (math.random(-500, 500) / 10000000)
                else
                    x = math.random(-1000, 1000) / 1000
                    y = math.random(0, 1000) / 1000
                end
                RodIdleAnim:Play()
                miniGameRemote:InvokeServer(x, y)
                task.wait(customDelayV2)
                FuncAutoFishV2.fishingActiveV2 = false
            end)
        end
    end)
end

function StopAutoFishV2()
    FuncAutoFishV2.autofishV2 = false
    FuncAutoFishV2.fishingActiveV2 = false
    FuncAutoFishV2.delayInitializedV2 = false
    RodIdleAnim:Stop()
    RodShakeAnim:Stop()
    RodReelAnim:Stop()
end

AutoFishSection:Input({
	Title = "Bypass Delay",
	Content = "Adjust delay between catches",
	Placeholder = "Example: 1.45",
	Callback = function(value)
		local number = tonumber(value)
		if number then BypassDelayV2 = number end
	end,
})

AutoFishSection:Toggle({
    Title = "Auto Sell",
    Content = "Automatically sells non-favorited fish when count > 60",
    Callback = function(value)
        state.AutoSell = value
        if value then startAutoSell() end
    end
})

AutoFishSection:Toggle({
	Title = "Auto Fish V2",
	Content = "Advanced fishing automation",
	Callback = function(value)
		if value then StartAutoFishV2() else StopAutoFishV2() end
	end
})

AutoFishSection:Toggle({
    Title = "Auto Perfect Cast",
    Value = true,
    Callback = function(value) FuncAutoFishV2.perfectCastV2 = value end
})

local AutoFavoriteSection = AutoFishTab:Section({ Title = "Auto Favorite System", Icon = "star" })
-- Ditambahkan "7" dan "6" agar Tier tertinggi otomatis difavoritkan
local allowedTiers = { ["Secret"] = true, ["Mythic"] = true, ["Legendary"] = true, ["7"] = true, ["6"] = true } 

local function startAutoFavourite()
    task.spawn(function()
        while state.AutoFavourite do
            pcall(function()
                if not Replion or not ItemUtility or not DataReplion then return end
                
                local inventoryData = SafeGet(DataReplion, "Inventory") 
                local items = nil
                if inventoryData and type(inventoryData) == "table" then items = inventoryData.Items end
                if not items then items = SafeGet(DataReplion, "Items") end -- Fallback
                
                if items and type(items) == "table" then
                    for _, item in ipairs(items) do
                        if item.Id then
                            local base = ItemUtility:GetItemData(item.Id)
                            if base and base.Data and base.Data.Type == "Fish" then
                                -- Check Tier. Tiers from data are strings/numbers like "7", "Secret"
                                local tierString = tostring(base.Data.Tier)
                                
                                if allowedTiers[tierString] and not item.Favorited then
                                    local setFavoriteRemote = net:WaitForChild("RE/ToggleFavorite")
                                    pcall(setFavoriteRemote.InvokeServer, setFavoriteRemote, item.UUID)
                                    NotifyInfo("Auto Favorite", "Favorited: " .. base.Data.Name .. " (" .. tierString .. ")")
                                    task.wait(0.1) -- Delay kecil untuk mencegah flood
                                end
                            end
                        end
                    end
                end
            end)
            task.wait(5)
        end
    end)
end

AutoFavoriteSection:Toggle({
    Title = "Enable Auto Favorite",
    Callback = function(value)
        state.AutoFavourite = value
        if value then startAutoFavourite() end
    end
})

local ManualSection = AutoFishTab:Section({ Title = "Manual Actions", Icon = "hand" })

ManualSection:Button({
    Title = "Sell All Fishes",
    Callback = function()
        local sellRemote = net:WaitForChild("RF/SellAllItems")
        pcall(sellRemote.InvokeServer, sellRemote)
        NotifySuccess("Sold!", "All fish sold.")
    end
})

-------------------------------------------
----- =======[ AUTO GIVE SYSTEM ] =======
-------------------------------------------


local GiveSection = GiveTab:Section({ Title = "Auto Trade", Icon = "box" })

local Remote_InitiateTrade

-- Memuat remote di thread terpisah agar GUI tidak nge-bug/delay
task.spawn(function()
    pcall(function()
        Remote_InitiateTrade = net:WaitForChild("RF/InitiateTrade", 5) 
        if Remote_InitiateTrade then
            
        end
    end)
end)

local selectedPlayer = nil
local selectedTierValue = nil 

-- Peta statis Tier Display Name ke Nilai Internal Tier (Angka)
local TierMapping = {
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
for name in pairs(TierMapping) do table.insert(tierDisplayNames, name) end
table.sort(tierDisplayNames, function(a, b)
    local numA = TierMapping[a] or 0
    local numB = TierMapping[b] or 0
    return numA > numB
end)

local function getPlayers()
    local pList = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(pList, p.Name) end
    end
    return pList
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
                    -- Mengembalikan UUID, Nama, dan Item Id
                    return item.UUID, base.Data.Name, item.Id 
                end
            end
        end
    end
    
    return nil 
end

GiveSection:Dropdown({
    Title = "Pilih Player",
    Values = getPlayers(),
    Callback = function(v) selectedPlayer = v end
})

GiveSection:Button({
    Title = "Refresh Player List",
    Callback = function() GiveSection:UpdateDropdown("Pilih Player", getPlayers()) end
})

GiveSection:Dropdown({
    Title = "Pilih Rarity Ikan",
    Content = "Pilih Rarity yang ingin dikirim.",
    Values = tierDisplayNames,
    Callback = function(v)
        local trimmed_v = trim(v)
        
        selectedTierValue = TierMapping[trimmed_v]
        
        if selectedTierValue then
            NotifyInfo("Rarity Dipilih", "Siap kirim Rarity: " .. trimmed_v)
        else
            selectedTierValue = nil
            NotifyError("Kesalahan Mapping", "Rarity yang dipilih ('" .. v .. "') tidak cocok dengan daftar yang diketahui. Coba ulangi pemilihan.")
        end
    end
})


GiveSection:Toggle({
    Title = "Trade", 
    Callback = function(value)
        state.AutoTrade = value

        if value then
            -- Initial Checks
            if not selectedPlayer then
                NotifyError("Error", "Pilih Player dulu!")
                state.AutoTrade = false 
                return
            end

            if not selectedTierValue then
                NotifyError("Error", "Pilih Rarity Ikan!")
                state.AutoTrade = false
                return
            end
            
            if not Remote_InitiateTrade then 
                NotifyWarning("Loading", "Remote InitiateTrade belum dimuat. Menghentikan Trade Loop.")
                state.AutoTrade = false
                return 
            end

            -- Start the loop
            NotifyInfo("Auto Trade Started", "Memulai pengiriman ikan Tier " .. selectedTierValue .. " ke " .. selectedPlayer .. ".")

            task.spawn(function()
                while state.AutoTrade do
                    
                    local selectedTierUUID, fishName, selectedItemId = findUUIDByTier(selectedTierValue)
                    
                    if not selectedTierUUID then
                        -- Out of items, stop loop
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

                    -- STEP 1: Initiate Trade (UserId, UUID)
                    local s1, r1 = pcall(Remote_InitiateTrade.InvokeServer, Remote_InitiateTrade, targetUserId, selectedTierUUID) 
                    
                    if not s1 then
                        -- Jika gagal, mungkin target menolak trade, atau server error.
                        NotifyError("Trade Gagal (Init/Loop)", "Trade gagal: " .. tostring(r1) .. ". Mencoba lagi dalam 10 detik.")
                        task.wait(6) 
                    else
                        -- Success!
                        NotifySuccess("Trade Berhasil!", 
                            string.format("Otomatis melanjutkan trade berikutnya dalam 6 detik.", 
                                fishName or ("Ikan Tier " .. selectedTierValue)))
                        
                        task.wait(6) -- Jeda aman agar pemain target punya waktu untuk menyelesaikan trade window
                    end
                end
            end)
        else
            -- If the user turns off the toggle
            state.AutoTrade = false
            NotifyInfo("Auto Trade Stopped")
        end
    end
})

-------------------------------------------
----- =======[ UTILITY TAB ] =======
-------------------------------------------

local TeleportSection = UtilityTab:Section({ Title = "Teleport", Icon = "map-pin" })
local islandCoords = {
	["01"] = { name = "Weather Machine", position = Vector3.new(-1471, -3, 1929) },
	["02"] = { name = "Esoteric Depths", position = Vector3.new(3145, -1303, 1439) }, 
	["03"] = { name = "Tropical Grove", position = Vector3.new(-2038, 3, 3650) },
	["04"] = { name = "Stingray Shores", position = Vector3.new(-32, 4, 2773) },
	["05"] = { name = "Kohana Volcano", position = Vector3.new(-519, 24, 189) },
	["06"] = { name = "Coral Reefs", position = Vector3.new(-3095, 1, 2177) },
    ["08"] = { name = "Kohana", position = Vector3.new(-658, 3, 719) },
    ["13"] = { name = "Sishypus Statue", position = Vector3.new(-3792, -135, -986) }
}
local islandNames = {}
for _, data in pairs(islandCoords) do table.insert(islandNames, data.name) end

TeleportSection:Dropdown({
    Title = "Island Teleport",
    Values = islandNames,
    Callback = function(selectedName)
        for _, data in pairs(islandCoords) do
            if data.name == selectedName then
                local char = Players.LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    char.HumanoidRootPart.CFrame = CFrame.new(data.position + Vector3.new(0, 5, 0))
                end
                break
            end
        end
    end
})

-- Anti-AFK Section
local AFKSection = SettingsTab:Section({
	Title = "Anti-AFK System",
	Icon = "user-x"
})

local AntiAFKEnabled = true
local AFKConnection = nil

AFKSection:Toggle({
	Title = "Anti-AFK",
	Content = "Prevent automatic disconnection",
	Value = true,
	Callback = function(Value)
		AntiAFKEnabled = Value
		if AntiAFKEnabled then
			if AFKConnection then AFKConnection:Disconnect() end
			
			local VirtualUser = game:GetService("VirtualUser")

			AFKConnection = LocalPlayer.Idled:Connect(function()
				pcall(function()
					VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
					task.wait(1)
					VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
				end)
			end)

			NotifySuccess("Anti-AFK Activated", "You will now avoid being kicked.")

		else
			if AFKConnection then
				AFKConnection:Disconnect()
				AFKConnection = nil
			end

			NotifySuccess("Anti-AFK Deactivated", "You can now go idle again.")
		end
	end,
})

WindUI:Notify({
	Title = "Erregea - Fish It",
	Content = "Script Loaded.",
	Duration = 8,
	Icon = "circle-check"
})