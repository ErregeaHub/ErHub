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

    -- Teleport 5 studs di atas player tujuan
    local targetPosition = targetChar.HumanoidRootPart.CFrame * CFrame.new(0, 5, 0) 
    char.HumanoidRootPart.CFrame = targetPosition
    NotifySuccess("Teleport Berhasil", "Berhasil pindah ke lokasi " .. playerName .. ".")
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
-- V29: Tambahkan state.AutoAcceptTrade
local state = { AutoFavourite = false, AutoSell = false, AutoTrade = false, AutoAcceptTrade = false }

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
local RunService = game:GetService("RunService")
local Terrain = game.Workspace.Terrain

-- Fungsi Pembersihan Objek (Sama seperti sebelumnya)
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
        
    -- Menghancurkan model/part pohon, semak, dll.
    elseif v:IsA("BasePart") or v:IsA("Model") then
        local name = v.Name:lower()
        if name:find("tree") or name:find("bush") or name:find("foliage") or name:find("water") then
            v:Destroy()
        end
    end
end

-- Fungsi Pembersihan Terrain Khusus
local function ClearTerrainWater()
    if Terrain then
        -- Mencoba menghapus semua Terrain (jika Terrain di-reset, ini akan membersihkannya lagi)
        -- HATI-HATI: Ini adalah operasi yang sangat mahal, tapi efektif.
        Terrain:Clear()
        
        -- Mengatur Level Air Terrain ke nol (opsional jika Clear() tidak 100% efektif)
        -- Terrain.WaterReflectance = 0
        -- Terrain.WaterTransparency = 1 
        -- Jika game menggunakan Global Water (tidak melalui Terrain), metode ini tidak akan bekerja.
    end
end

local function ContinuousFPSBoost()
    
    -- FASE 1: Pembersihan Awal dan Koneksi Event (Untuk Part Baru)
    
    -- 1a. Pembersihan Pertama
    for _, v in game:GetDescendants() do
        OptimizeObject(v)
    end
    
    -- 1b. Koneksi Event untuk objek yang ditambahkan
    game.DescendantAdded:Connect(OptimizeObject)
    
    -- FASE 2: Pemanfaatan Loop Cepat untuk Pengawasan Reload
    
    -- Gunakan RunService.Heartbeat (Loop tercepat di client) untuk memantau dan membersihkan Terrain/Air.
    -- Loop ini akan memastikan Terrain di-clear SETIAP frame, mencegah air muncul lama.
    RunService.Heartbeat:Connect(function()
        
        -- Pastikan kualitas rendering selalu terendah
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        
        -- Panggil pembersihan Terrain Air setiap frame
        ClearTerrainWater()
        
    end)
    
    -- FASE 3: Pengaturan Kualitas Lainnya (Di luar loop, karena hanya perlu diatur sekali)
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
end

-- Panggil fungsi untuk memulai optimasi kontinu
ContinuousFPSBoost()

-------------------------------------------
----- =======[ LOAD WINDOW ] =======
-------------------------------------------

local Window = WindUI:CreateWindow({
    Title = "Erregea - Fish It",
    Icon = "fish",
    Author = "by @Erregea",
    Folder = "Erregea",
    Resizable = true,
    HideSearchBar = true,
    SideBarWidth = 75,
    Size = UDim2.fromOffset(150, 75),
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

-- Memuat remote di thread terpisah agar GUI tidak nge-bug/delay
task.spawn(function()
    pcall(function()
        Remote_InitiateTrade = net:WaitForChild("RF/InitiateTrade", 5) 
    end)
end)
        
local selectedPlayer = nil
local selectedTierValue = nil 

-- Peta statis Tier Display Name ke Nilai Internal Tier (Angka)
local TIER_MAPPING_V29 = {
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
    if not items then items = SafeGet(DataReplion, "Items") end -- Fallback
    
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
    Title = "Pilih Tier Ikan",
    Content = "Pilih Tier yang ingin dikirim.",
    Values = tierDisplayNames,
    Callback = function(v)
        local trimmed_v = trim(v)
        
        selectedTierValue = TIER_MAPPING_V29[trimmed_v]
        
        if selectedTierValue then
            NotifyInfo("Tier Dipilih", "Siap kirim Tier: " .. trimmed_v)
        else
            selectedTierValue = nil
            NotifyError("Kesalahan Mapping", "Tier yang dipilih ('" .. v .. "') tidak cocok dengan daftar yang diketahui. Coba ulangi pemilihan.")
        end
    end
})


GiveSection:Toggle({
    Title = "Start Trade", -- Mengganti nama toggle
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
                NotifyError("Error", "Pilih Tier Ikan dulu dari dropdown!")
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
                        task.wait(10) 
                    else
                        -- Success!
                        NotifySuccess("Trade BERHASIL!", 
                            string.format("Trade Success, Auto Dalam 6 detik", 
                                fishName or ("Ikan Tier " .. selectedTierValue)))
                        
                        task.wait(6) -- Jeda aman agar pemain target punya waktu untuk menyelesaikan trade window
                    end
                end
            end)
        else
            -- If the user turns off the toggle
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
----- =======[ UTILITY TAB ] =======
-------------------------------------------

-- Teleport Player Section
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

-- Island Teleport Section
local TeleportSection = UtilityTab:Section({ Title = "Island Teleport", Icon = "map-pin" })

-- Koordinat target tunggal yang diambil dari '02' Esoteric Depths
local TARGET_ISLAND_DATA = { 
    name = "Esoteric Depths", 
    position = Vector3.new(3230.84, -1303, 1453.18) 
}

local function TeleportToTarget()
    local data = TARGET_ISLAND_DATA
    local char = Players.LocalPlayer.Character
    
    -- Pastikan karakter dan HumanoidRootPart ada
    if char and char:FindFirstChild("HumanoidRootPart") then
        -- Teleport 5 studs di atas posisi target
        local targetCFrame = CFrame.new(data.position + Vector3.new(0, 5, 0))
        char.HumanoidRootPart.CFrame = targetCFrame
        NotifySuccess("Teleport Berhasil", "Berhasil teleport  ke " .. data.name)
        return true
    else
        NotifyError("Teleport Gagal", "Karakter tidak ditemukan atau belum dimuat. Coba lagi!")
        return false
    end
end

-- Mengganti Dropdown sebelumnya dengan Toggle untuk aksi instan
TeleportSection:Toggle({
    Title = "Teleport: Esoteric Depths",
    Content = "Klik untuk teleport instan ke pulau Esoteric Depths.",
    Value = false, -- Pastikan dimulai dari OFF
    Callback = function(value)
        -- Aksi hanya dilakukan ketika Toggle diubah ke ON
        if value then
            local success = TeleportToTarget()
            
            -- PENTING: Segera set toggle kembali ke OFF untuk siap diklik berikutnya
            -- Ini mensimulasikan fungsi tombol (Button)
            TeleportSection:UpdateToggle("Teleport: Esoteric Depths", false)
        end
    end
})