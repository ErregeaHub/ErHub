
    -------------------------------------------
    ----- =======[ Load WindUI ] =======
    -------------------------------------------

    local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

    -------------------------------------------
    ----- =======[ GLOBAL FUNCTION ] =======
    -------------------------------------------

    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local LocalPlayer = Players.LocalPlayer

    local Replion
    local ItemUtility
    local DataReplion
    local sellRemote = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net"):WaitForChild("RF/SellAllItems")

    -------------------------------------------
    ----- =======[ MOBILE SCALING ] =======
    -------------------------------------------

    local function sTitle(text)
        return string.format('<font size="13">%s</font>', text)
    end

    local function sDesc(text)
        return string.format('<font size="9">%s</font>', text)
    end

    local function sBtn(text)
        return string.format('<font size="11">%s</font>', text)
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
                NotifyInfo("System Ready")
                return true
            end
        end
        NotifyError("Gagal Load", "Replion/DataReplion tidak terhubung.")
        return false
    end

    local function TeleportToLostIsle()
        local char = Players.LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local targetCFrame = CFrame.new(-3741.31494141, -135.07441711, -1009.24774170, -0.98377842, -0.00000002, -0.17938799, -0.00000002, 1.00000000, -0.00000002, 0.17938799, -0.00000002, -0.98377842)
            char.HumanoidRootPart.CFrame = targetCFrame
            NotifySuccess("Teleport Berhasil", "Teleported to Lost Isle")
            return true
        else
            NotifyError("Teleport Gagal", "Character not found or not loaded!")
            return false
        end
    end

    task.spawn(function()
        if not initializeDataModules() then
            NotifyError("KRITIKAL", "Fitur Auto-Give & Auto-Sell kemungkinan tidak berfungsi. Coba rejoin game.")
        end
    end)

    -- Remote Integration (Based on user paths)
    local NetRoot = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net")

    local rodRemote = NetRoot:WaitForChild("RF/ChargeFishingRod")
local miniGameRemote = NetRoot:WaitForChild("RF/RequestFishingMinigameStarted")
local finishRemote = NetRoot:WaitForChild("RE/FishingCompleted")
local equipRemote = NetRoot:WaitForChild("RE/EquipToolFromHotbar")
-- local Remote_InitiateTrade = NetRoot:WaitForChild("RF/InitiateTrade")
local cancelRemote = NetRoot:WaitForChild("RF/CancelFishingInputs")

_G.CompleteDelay = 0.1
    _G.CancelDelay = 0.05

    local state = { 
        AutoSell = false, 
        InstantFishing = false,
    }

    local Player = Players.LocalPlayer

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

    -------------------------------------------
    ----- =======[ AUTO BOOST FPS ] =======
    -------------------------------------------
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
        Size = UDim2.fromOffset(450, 250),
        MinSize = Vector2.new(450, 250),
        MaxSize = Vector2.new(850, 560),
        Transparent = true,
        Theme = "Dark",
        Resizable = true,
        SideBarWidth = 140,
        BackgroundImageTransparency = 0.5,
        HideSearchBar = true,
        
    })

    local UIS = game:GetService("UserInputService")

    Window:SetToggleKey(Enum.KeyCode.G)
    WindUI:SetNotificationLower(true)

    -------------------------------------------
    ----- =======[ MAIN TABS ] =======
    -------------------------------------------


    local UtilityTab = Window:Tab({ Title = "Teleport", Icon = "lucide:map-pin" })
    local BlatantTab = Window:Tab({ Title = "Fishing", Icon = "lucide:fishing-hook" })
    local MiscTab = Window:Tab({ Title = "Misc", Icon = "lucide:settings" })

    -------------------------------------------
    ----- =======[ BLATANT FEATURES ] =======
    -------------------------------------------

    local FishingSection = BlatantTab:Section({ Title = sTitle("Blatant Mode"), Icon = "fish" })

    FishingSection:Input({
        Title = sBtn("Complete Delay"),
        Content = sDesc("Delay before catching fish (Blatant: 0.1s)"),
        Placeholder = "Default: 0.1",
        Callback = function(v)
            local num = tonumber(v)
            if num then
                _G.CompleteDelay = num
                NotifySuccess("Delay Set", "Complete Delay updated to: " .. num .. "s")
            end
        end
    })

    FishingSection:Input({
        Title = sBtn("Cancel Delay"),
        Content = sDesc("Delay for resetting rod (Blatant: 0.05s)"),
        Placeholder = "Default: 0.05",
        Callback = function(v)
            local num = tonumber(v)
            if num then
                _G.CancelDelay = num
                NotifySuccess("Delay Set", "Cancel Delay updated to: " .. num .. "s")
            end
        end
    })

    FishingSection:Toggle({
        Title = sBtn("Blatant Mode"),
        Content = sDesc("Blatant Mode: High-speed automated fishing with customizable delays."),
        Callback = function(value)
            state.InstantFishing = value
            
            if value then
                NotifyInfo("Blatant Active", "Blatant Fishing Mode enabled.")
                
                -- Auto-Equip Rod from Slot 1
                local args = { 1 }
                pcall(function()
                    equipRemote:FireServer(unpack(args))
                end)
                
                task.spawn(function()
                    while state.InstantFishing do
                        task.spawn(function()
                            local success, err = pcall(function()
                                local char = Players.LocalPlayer.Character
                                if not char or not char:FindFirstChildOfClass("Tool") then 
                                    equipRemote:FireServer(1)
                                    task.wait(0.1)
                                end
                                
                                -- 1. Instant Cast (Using Server Time)
                                rodRemote:InvokeServer(workspace:GetServerTimeNow())
                                
                                -- 2. Instant Start (Fixed Blatant Args)
                                local arg1 = -1.
                                local arg2 = 1
                                local serverTime = workspace:GetServerTimeNow()
                                
                                local biteData = miniGameRemote:InvokeServer(arg1, arg2, serverTime)
                                
                                if biteData then
                                    -- 3. Adjustable Completion
                                    if (_G.CompleteDelay or 0) > 0 then
                                        task.wait(_G.CompleteDelay)
                                    end
                                    finishRemote:FireServer(true)
                                end
                                
                                -- 4. Adjustable Reset (Cancel)
                                if (_G.CancelDelay or 0) > 0 then
                                    task.wait(_G.CancelDelay)
                                end
                                cancelRemote:InvokeServer()
                            end)
                        end)
                        
                        -- Loop speed controlled by completion delay to prevent overflow
                        task.wait((_G.CompleteDelay or 0.1) + (_G.CancelDelay or 0.05) + 0.01)
                    end
                end)
            else
                NotifyInfo("Blatant Disabled", "Blatant Fishing disabled.")
            end
        end
    })

    local InventorySection = BlatantTab:Section({ Title = sTitle("Auto Sell"), Icon = "lucide:shopping-bag" })

    _G.SellDelay = 60

    InventorySection:Input({
        Title = sBtn("Sell Delay (s)"),
        Content = sDesc("Delay between auto-sell attempts (Default: 60)"),
        Placeholder = "60",
        Callback = function(v)
            local num = tonumber(v)
            if num then
                _G.SellDelay = num
                NotifySuccess("Sell Delay Set", "Auto-sell delay updated to: " .. num .. "s")
            end
        end
    })

    InventorySection:Toggle({
        Title = sBtn("Auto Sell All"),
        Content = sDesc("Automatically sells all items in your inventory at the specified interval."),
        Callback = function(value)
            state.AutoSell = value
            if value then
                NotifyInfo("Auto Sell Enabled", "Items will be sold every " .. (_G.SellDelay or 60) .. "s")
                task.spawn(function()
                    while state.AutoSell do
                        pcall(function()
                            sellRemote:InvokeServer()
                        end)
                        task.wait(_G.SellDelay or 60)
                    end
                end)
            else
                NotifyInfo("Auto Sell Disabled", "")
            end
        end
    })


    -------------------------------------------
    ----- =======[ UTILITY TAB ] =======
    -------------------------------------------

    local PlayerTeleportSection = UtilityTab:Section({ Title = sTitle("Teleport to Player"), Icon = "user-check" })
    local selectedPlayerForTeleport = nil 

    local function getScaledPlayers()
        local list = {}
        for _, name in pairs(getPlayers()) do
            table.insert(list, sBtn(name))
        end
        return list
    end

    PlayerTeleportSection:Dropdown({
        Title = sBtn("Pilih Player Tujuan"),
        Values = getScaledPlayers(), 
        Callback = function(v) 
            -- Strip tags to get the actual name
            selectedPlayerForTeleport = v:gsub("<[^>]*>", "") 
        end
    })

    PlayerTeleportSection:Button({
        Title = sBtn("Refresh Player List"),
        Callback = function() 
            PlayerTeleportSection:UpdateDropdown(sBtn("Pilih Player Tujuan"), getScaledPlayers()) 
        end
    })

    PlayerTeleportSection:Button({
        Title = sBtn("Teleport Now!"),
        Callback = function()
            if not selectedPlayerForTeleport then
                NotifyError("Error", "Pilih Player yang ingin dituju dulu!")
                return
            end
            TeleportToPlayer(selectedPlayerForTeleport)
        end
    })

    local IslandTeleportSection = UtilityTab:Section({ Title = sTitle("Island Teleport"), Icon = "map-pin" })

    IslandTeleportSection:Dropdown({
        Title = sBtn("Pilih Island"),
        Values = {sBtn("Esoteric Depths"), sBtn("Lost Isle")},
        Callback = function(v)
            local name = v:gsub("<[^>]*>", "") -- Strip tags
            if name == "Lost Isle" then
                TeleportToLostIsle()
            elseif name == "Esoteric Depths" then
                local char = Players.LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    char.HumanoidRootPart.CFrame = CFrame.new(3230.84, -1303, 1453.18)
                    NotifySuccess("Teleport Berhasil", "Berhasil teleport ke Esoteric Depths")
                else
                    NotifyError("Teleport Gagal", "FEKFEK")
                end
            end
        end
    })

    -------------------------------------------
    ----- =======[ MISC TAB ] =======
    -------------------------------------------

    local VisualsSection = MiscTab:Section({ Title = sTitle("Disable Obtained Fish"), Icon = "eye-off" })

    local smallNotifCleaner
    local displayMonitor
    local scaleHook

    VisualsSection:Toggle({
        Title = sBtn("Hide Obtained Fish"),
        Content = sDesc("Hides notifications via UIScale and destroys children for performance."),
        Callback = function(value)
            _G.HideNotifications = value
            
            local function getDisplay()
                local playerGui = Player:FindFirstChild("PlayerGui")
                local notif = playerGui and playerGui:FindFirstChild("Small Notification")
                if notif then
                    return notif:FindFirstChild("Display") or notif:FindFirstChild("display")
                end
                return nil
            end

            local display = getDisplay()
            
            if value then
                local function setupDisplay(disp)
                    local uiScale = disp:FindFirstChildOfClass("UIScale") or disp:FindFirstChild("UIScale")
                    
                    if uiScale then
                        uiScale.Scale = 0
                        -- Ensure scale stays at 0 if the game tries to reset it
                        if not scaleHook then
                            scaleHook = uiScale:GetPropertyChangedSignal("Scale"):Connect(function()
                                if _G.HideNotifications then
                                    uiScale.Scale = 0
                                end
                            end)
                        end
                    end
                    
                    -- Memory Cleanup: Destroy all children except UIScale
                    if not displayMonitor then
                        displayMonitor = disp.ChildAdded:Connect(function(child)
                            if _G.HideNotifications and not child:IsA("UIScale") then
                                task.wait()
                                child:Destroy()
                            end
                        end)
                    end
                    
                    -- Clear existing children immediately
                    for _, child in pairs(disp:GetChildren()) do
                        if not child:IsA("UIScale") then
                            child:Destroy()
                        end
                    end
                end

                if display then
                    setupDisplay(display)
                end
                
                -- Monitor for the GUI being re-created/re-added
                if not smallNotifCleaner then
                    smallNotifCleaner = Player.PlayerGui.ChildAdded:Connect(function(child)
                        if _G.HideNotifications and child.Name == "Small Notification" then
                            task.wait()
                            local newDisplay = child:FindFirstChild("Display") or child:FindFirstChild("display")
                            if newDisplay then
                                setupDisplay(newDisplay)
                            end
                        end
                    end)
                end
                
                NotifyInfo("Notifications Hidden", "")
            else
                -- Toggle OFF: Clean up connections and reset scale
                if scaleHook then scaleHook:Disconnect() scaleHook = nil end
                if displayMonitor then displayMonitor:Disconnect() displayMonitor = nil end
                if smallNotifCleaner then smallNotifCleaner:Disconnect() smallNotifCleaner = nil end
                
                if display then
                    local uiScale = display:FindFirstChildOfClass("UIScale") or display:FindFirstChild("UIScale")
                    if uiScale then
                        uiScale.Scale = 1
                    end
                end
                
                NotifyInfo("Notifications Shown", "Notifications restored to normal.")
            end
        end
    })



