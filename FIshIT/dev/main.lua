
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

    -- New Effect Remotes
    local playFishingEffect = NetRoot:WaitForChild("RE/PlayFishingEffect")
    local destroyEffect = NetRoot:WaitForChild("RE/DestroyEffect")
    local playVFX = NetRoot:WaitForChild("RE/PlayVFX")
    local loadVFX = NetRoot:WaitForChild("RF/LoadVFX")
    local modules = game:GetService("ReplicatedStorage"):WaitForChild("Modules", 5)
    local moduleVFX = modules and modules:FindFirstChild("VFX")
    local mainVFX = game:GetService("ReplicatedStorage"):FindFirstChild("VFX")
    local assets = game:GetService("ReplicatedStorage"):WaitForChild("Assets", 5)
    local cutsceneFolder = assets and assets:FindFirstChild("Cutscenes")

    -------------------------------------------
    ----- =======[ EFFECT HOOKS ] =======
    -------------------------------------------

    -- Hook Fishing Effects
    local oldFishingEffect
    oldFishingEffect = hookmetamethod(playFishingEffect, "__index", function(self, key)
        if key == "OnClientEvent" and state.DisableFishingEffect then
            return Instance.new("BindableEvent").Event
        end
        return oldFishingEffect(self, key)
    end)

    -- Hook VFX Effects
    local oldPlayVFX
    oldPlayVFX = hookmetamethod(playVFX, "__index", function(self, key)
        if key == "OnClientEvent" and state.DisableEffect then
            return Instance.new("BindableEvent").Event
        end
        return oldPlayVFX(self, key)
    end)

    -- Function to hook remotes in a folder
    local function HookRemotesInFolder(folder)
        if not folder then return end
        for _, v in pairs(folder:GetDescendants()) do
            if v:IsA("RemoteEvent") then
                local oldRemote
                oldRemote = hookmetamethod(v, "__index", function(self, key)
                    if key == "OnClientEvent" and state.DisableEffect then
                        return Instance.new("BindableEvent").Event
                    end
                    return oldRemote(self, key)
                end)
            elseif v:IsA("RemoteFunction") then
                local oldFunc
                oldFunc = hookmetamethod(v, "__index", function(self, key)
                    if key == "InvokeServer" and state.DisableEffect then
                        return function() return end
                    end
                    return oldFunc(self, key)
                end)
            end
        end
    end

    HookRemotesInFolder(moduleVFX)
    HookRemotesInFolder(mainVFX)

    -- Hook Cutscenes
    if cutsceneFolder then
        for _, v in pairs(cutsceneFolder:GetDescendants()) do
            if v:IsA("RemoteEvent") then
                local oldRemote
                oldRemote = hookmetamethod(v, "__index", function(self, key)
                    if key == "OnClientEvent" and state.DisableCutscene then
                        return Instance.new("BindableEvent").Event
                    end
                    return oldRemote(self, key)
                end)
            elseif v:IsA("RemoteFunction") then
                local oldFunc
                oldFunc = hookmetamethod(v, "__index", function(self, key)
                    if key == "InvokeServer" and state.DisableCutscene then
                        return function() return end
                    end
                    return oldFunc(self, key)
                end)
            end
        end
    end

    -- Hook Destroy Effect (Optional, usually good to let cleanup happen)
    -- But we can block LoadVFX if needed
    local oldLoadVFX
    oldLoadVFX = hookmetamethod(loadVFX, "__index", function(self, key)
        if key == "InvokeServer" and state.DisableEffect then
            return function() return end
        end
        return oldLoadVFX(self, key)
    end)

    _G.CompleteDelay = 0.1
    _G.CancelDelay = 0.05

    local state = { 
        AutoSell = false, 
        InstantFishing = false,
        WebhookEnabled = false,
        WebhookURL = "",
        WebhookTiers = {
            ["1"] = true,
            ["2"] = true,
            ["3"] = true,
            ["4"] = true,
            ["5"] = true,
            ["6"] = true,
            ["7"] = true,
        },
        -- Support Features
        NoFishingAnimation = false,
        ShowPing = false,
        LockPosition = false,
        DisableSkinEffect = false,
        DisableEffect = false,
        DisableFishingEffect = false,
        -- Booster FPS
        ReduceMap = false,
        -- Server Features
        AutoReconnect = true,
        AntiAfk = false,
        -- Fishing Support
        AutoEquipRod = false,
        WalkOnWater = false,
        DisableCutscene = false,
        -- Lighting & Movement
        Fullbright = false,
        WalkSpeed = 16,
        JumpPower = 50,
    }

    local Player = Players.LocalPlayer

    local TeleportService = game:GetService("TeleportService")
    local PlaceId = game.PlaceId

    local function AutoReconnect()
        while task.wait(5) do
            if state.AutoReconnect then
                if not Players.LocalPlayer or not Players.LocalPlayer:IsDescendantOf(game) then
                    TeleportService:Teleport(PlaceId)
                end
            end
        end
    end

    -- Anti-AFK Logic
    local VirtualUser = game:GetService("VirtualUser")
    LocalPlayer.Idled:Connect(function()
        if state.AntiAfk then
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end
    end)

    -- Ping Panel Logic
    local function CreatePingPanel()
        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
        if not playerGui then return nil end
        
        local screenGui = playerGui:FindFirstChild("PingPanel")
        if not screenGui then
            screenGui = Instance.new("ScreenGui")
            screenGui.Name = "PingPanel"
            screenGui.ResetOnSpawn = false
            screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            screenGui.Parent = playerGui
        end
        
        local label = screenGui:FindFirstChild("PingLabel")
        if not label then
            label = Instance.new("TextLabel")
            label.Name = "PingLabel"
            label.Size = UDim2.new(0, 120, 0, 30)
            label.Position = UDim2.new(0.5, -60, 0, 10) -- Top middle
            label.BackgroundTransparency = 0.5
            label.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
            label.TextColor3 = Color3.new(1, 1, 1)
            label.Font = Enum.Font.RobotoMono
            label.TextSize = 16
            label.BorderSizePixel = 0
            
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 6)
            corner.Parent = label
            
            label.Parent = screenGui
        end
        return label
    end

    task.spawn(function()
        while task.wait(1) do
            if state.ShowPing then
                local ping = 0
                local stats = game:GetService("Stats")
                pcall(function()
                    ping = stats.Network.ServerStatsItem["Data Ping"]:GetValue()
                end)
                
                local label = CreatePingPanel()
                if label then
                    label.Visible = true
                    label.Text = string.format("Ping: %.0f ms", ping)
                end
            else
                local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
                local screenGui = playerGui and playerGui:FindFirstChild("PingPanel")
                if screenGui then
                    screenGui:Destroy()
                end
            end
        end
    end)

    -- No Fishing Animation Logic
    local AnimationModule = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Animations")
    local originalAnimationIds = {}

    -- Store original IDs and clear them if needed
    for _, v in pairs(AnimationModule:GetDescendants()) do
        if v:IsA("Animation") then
            originalAnimationIds[v] = v.AnimationId
        end
    end

    local function ToggleAnimations(value)
        for anim, originalId in pairs(originalAnimationIds) do
            if value then
                local name = anim.Name:lower()
                if name:find("fish") or name:find("cast") or name:find("reel") or name:find("catch") then
                    anim.AnimationId = ""
                end
            else
                anim.AnimationId = originalId
            end
        end
    end

    -- Aggressive Track Stopping
    task.spawn(function()
        local blockAnims = {"startrodcharge", "rodthrow", "reelingidle", "reelstart", "reelintermission", "fishcaught", "equipidle", "fish", "fishing", "cast", "reel", "catch"}
        while task.wait(0.1) do
            if state.NoFishingAnimation then
                local char = LocalPlayer.Character
                if char then
                    local humanoid = char:FindFirstChildOfClass("Humanoid")
                    local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
                    if animator then
                        for _, track in pairs(animator:GetPlayingAnimationTracks()) do
                            local name = track.Name:lower()
                            local id = tostring(track.Animation.AnimationId):lower()
                            local shouldBlock = false
                            for _, b in pairs(blockAnims) do
                                if name:find(b) or id:find(b) then
                                    shouldBlock = true
                                    break
                                end
                            end
                            if shouldBlock then
                                track:Stop(0)
                            end
                        end
                    end
                end
            end
        end
    end)

    -- Hook AnimationTrack:Play correctly
    local oldPlay
    oldPlay = hookmetamethod(game:GetService("Animation"), "Play", function(self, ...)
        if not checkcaller() and state.NoFishingAnimation then
            if self:IsA("AnimationTrack") then
                local name = self.Name:lower()
                local id = tostring(self.Animation.AnimationId):lower()
                local blockAnims = {"startrodcharge", "rodthrow", "reelingidle", "reelstart", "reelintermission", "fishcaught", "equipidle", "fish", "fishing", "cast", "reel", "catch"}
                for _, b in pairs(blockAnims) do
                    if name:find(b) or id:find(b) then
                        return
                    end
                end
            end
        end
        return oldPlay(self, ...)
    end)

    -- Lock Position Logic
    local lockConnection
    local function ToggleLockPosition(value)
        if value then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local lockedCFrame = char.HumanoidRootPart.CFrame
                if lockConnection then lockConnection:Disconnect() end
                lockConnection = RunService.Heartbeat:Connect(function()
                    if state.LockPosition and char:FindFirstChild("HumanoidRootPart") then
                        char.HumanoidRootPart.CFrame = lockedCFrame
                        char.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0,0,0)
                        char.HumanoidRootPart.AssemblyAngularVelocity = Vector3.new(0,0,0)
                    end
                end)
            end
        else
            if lockConnection then lockConnection:Disconnect() lockConnection = nil end
        end
    end

    -- Effect Disabler Logic
    local function CleanEffects(v)
        if not v or not v.Parent then return end
        local name = v.Name:lower()
        
        -- Disable Effect (VFX)
        if state.DisableEffect then
            if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") or v:IsA("Explosion") or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") then
                v.Enabled = false
                if v:IsA("ParticleEmitter") then v:Clear() end
            end
            if name:find("vfx") or name:find("effect") or name:find("particle") or name:find("aura") then
                if v:IsA("BasePart") or v:IsA("MeshPart") then
                    v.Transparency = 1
                    v.CanCollide = false
                elseif v:IsA("Texture") or v:IsA("Decal") then
                    v.Transparency = 1
                end
            end
        end
        
        -- Disable Skin Effect
        if state.DisableSkinEffect then
            if name:find("skin") or name:find("wrap") or name:find("texture") or name:find("material") or name:find("paint") then
                if v:IsA("BasePart") or v:IsA("MeshPart") then
                    v.Transparency = 1
                elseif v:IsA("Texture") or v:IsA("Decal") then
                    v.Transparency = 1
                elseif v:IsA("SpecialMesh") then
                    v.TextureId = ""
                end
            end
        end

        -- Disable Fishing Effect
        if state.DisableFishingEffect then
            if name:find("splash") or name:find("bubble") or name:find("ripple") or name:find("water") or name:find("fish_effect") then
                if v:IsA("ParticleEmitter") then 
                    v.Enabled = false 
                    v:Clear()
                elseif v:IsA("BasePart") or v:IsA("MeshPart") then
                    v.Transparency = 1
                    v.CanCollide = false
                end
            end
        end
    end

    game.DescendantAdded:Connect(function(v)
        pcall(CleanEffects, v)
    end)
    
    -- Continuous Cleanup for existing and missed effects
    task.spawn(function()
        while task.wait(0.5) do
            if state.DisableEffect or state.DisableSkinEffect or state.DisableFishingEffect then
                local targets = {workspace, LocalPlayer.Character, moduleVFX, mainVFX}
                for _, container in pairs(targets) do
                    if container then
                        for _, v in pairs(container:GetDescendants()) do
                            pcall(CleanEffects, v)
                        end
                    end
                end
            end
        end
    end)

    -- Fullbright Logic
    local Lighting = game:GetService("Lighting")
    local originalBrightness = Lighting.Brightness
    local originalClockTime = Lighting.ClockTime
    local originalFogEnd = Lighting.FogEnd
    local originalGlobalShadows = Lighting.GlobalShadows

    local fullbrightConnection
    local function ToggleFullbright(value)
        if value then
            if not fullbrightConnection then
                fullbrightConnection = RunService.RenderStepped:Connect(function()
                    if state.Fullbright then
                        Lighting.Brightness = 2
                        Lighting.ClockTime = 14
                        Lighting.FogEnd = 100000
                        Lighting.GlobalShadows = false
                    end
                end)
            end
        else
            if fullbrightConnection then
                fullbrightConnection:Disconnect()
                fullbrightConnection = nil
                -- Restore original settings
                Lighting.Brightness = originalBrightness
                Lighting.ClockTime = originalClockTime
                Lighting.FogEnd = originalFogEnd
                Lighting.GlobalShadows = originalGlobalShadows
            end
        end
    end

    -- Movement Logic
    RunService.Heartbeat:Connect(function()
        local char = LocalPlayer.Character
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            if state.WalkSpeed ~= 16 then
                humanoid.WalkSpeed = state.WalkSpeed
            end
            if state.JumpPower ~= 50 then
                humanoid.JumpPower = state.JumpPower
                humanoid.UseJumpPower = true
            end
        end
    end)

    task.spawn(AutoReconnect)

    local handleNotification -- Forward declaration

    -- Webhook State & Cache
    local lastSentFish = {name = "", tier = "", time = 0}
    local knownUUIDs = {}

    local function SendWebhook(fishName, tier)
        if not state.WebhookEnabled or state.WebhookURL == "" then return end
        
        -- Duplicate check
        local currentTime = tick()
        if lastSentFish.name == fishName and lastSentFish.tier == tostring(tier) and (currentTime - lastSentFish.time) < 3 then
            return
        end
        lastSentFish = {name = fishName, tier = tostring(tier), time = currentTime}

        -- Filter non-fish
        local lowerName = fishName:lower()
        local filters = {"inventory full", "level up", "quest complete", "new area", "achievement"}
        for _, filter in pairs(filters) do
            if lowerName:find(filter) then return end
        end

        local tierStr = tostring(tier)
        if not state.WebhookTiers[tierStr] then return end
        
        -- Proxy handling
        local url = state.WebhookURL
        if url:find("discord.com/api/webhooks") then
            url = url:gsub("discord.com", "webhook.lewisakura.moe")
        elseif url:find("discordapp.com/api/webhooks") then
            url = url:gsub("discordapp.com", "webhook.lewisakura.moe")
        end
        
        local tierColors = {
            ["1"] = 0x808080, ["2"] = 0x00ff00, ["3"] = 0x0000ff,
            ["4"] = 0xa335ee, ["5"] = 0xff8000, ["6"] = 0xff0000, ["7"] = 0xffff00,
        }

        local tierNames = {
            ["1"] = "Common", ["2"] = "Uncommon", ["3"] = "Rare",
            ["4"] = "Epic", ["5"] = "Legendary", ["6"] = "Mythic", ["7"] = "Secret",
        }

        local data = {
            ["username"] = "ErHub Notification!",
            ["avatar_url"] = "https://i.imgur.com/V1gmBJQ.png",
            ["embeds"] = {{
                ["title"] = "ErHub Webhook | Fish Caught",
                ["description"] = "Congratulations! You just caught a **" .. fishName .. "**!",
                ["color"] = tierColors[tierStr] or 0x00ff00,
                ["fields"] = {
                    {["name"] = "**〢 Rarity :**", ["value"] = "```" .. (tierNames[tierStr] or "Unknown") .. "```", ["inline"] = true},
                    {["name"] = "**〢 Player :**", ["value"] = "```" .. LocalPlayer.Name .. "```", ["inline"] = true}
                },
                ["image"] = {["url"] = "https://i.imgur.com/HeWixh1.gif"},
                ["footer"] = {
                    ["text"] = "ErHub • " .. os.date("%X"),
                    ["icon_url"] = "https://i.imgur.com/V1gmBJQ.png"
                },
                ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
            }}
        }
        
        task.spawn(function()
            print("[ErHub] Attempting to send webhook for: " .. fishName)
            local success, err = pcall(function()
                local json = game:GetService("HttpService"):JSONEncode(data)
                local req = (syn and syn.request) or (http and http.request) or http_request or (Fluxus and Fluxus.request) or request
                
                if req then
                    local res = req({
                        Url = url,
                        Method = "POST",
                        Headers = {["Content-Type"] = "application/json"},
                        Body = json
                    })
                    print("[ErHub] Webhook response status: " .. tostring(res and res.StatusCode or "No Response"))
                else
                    game:HttpPost(url, json, "application/json")
                    print("[ErHub] Webhook sent via HttpPost fallback")
                end
            end)
            if not success then
                warn("[ErHub] Webhook Error: " .. tostring(err))
            end
        end)
    end

    -- Inventory Monitoring System (Based on tradesystem.lua logic)
    task.spawn(function()
        -- Wait for data modules to load
        while not DataReplion or not ItemUtility do task.wait(1) end
        
        local function SafeGet(replion, key)
            local success, result = pcall(replion.Get, replion, key)
            return success and result or nil
        end

        local function getItems()
            local inventoryData = SafeGet(DataReplion, "Inventory") 
            local items = nil
            if inventoryData and type(inventoryData) == "table" then items = inventoryData.Items end
            if not items then items = SafeGet(DataReplion, "Items") end -- Fallback
            return items
        end

        -- Initial scan to populate knownUUIDs
        local initialItems = getItems()
        if initialItems and type(initialItems) == "table" then
            for _, item in pairs(initialItems) do
                if item.UUID then knownUUIDs[item.UUID] = true end
            end
        end

        -- Monitor loop
        while true do
            if state.WebhookEnabled then
                local currentItems = getItems()
                if currentItems and type(currentItems) == "table" then
                    for _, item in pairs(currentItems) do
                        if item.UUID and not knownUUIDs[item.UUID] then
                            knownUUIDs[item.UUID] = true
                            
                            -- New item detected!
                            if item.Id then
                                local itemData = ItemUtility:GetItemData(item.Id)
                                if itemData and itemData.Data and itemData.Data.Type == "Fish" then
                                    local name = itemData.Data.Name or "Unknown Fish"
                                    local tier = itemData.Data.Tier or 1
                                    
                                    SendWebhook(name, tostring(tier))
                                end
                            end
                        end
                    end
                end
            end
            task.wait(1) -- Using a 1s interval for faster detection
        end
    end)

    -- Hook FishingCompleted to detect fish catches directly from the server response
    -- This is a secondary detection method in case the UI monitor fails
    local oldFinishRemote
    oldFinishRemote = hookmetamethod(finishRemote, "__index", function(self, key)
        if key == "FireServer" and not checkcaller() then
            return function(self, ...)
                local args = {...}
                -- If we are firing the remote, it means we caught something or finished the minigame
                -- We can try to wait for a potential notification to appear
                return oldFinishRemote(self, "FireServer")(self, unpack(args))
            end
        end
        return oldFinishRemote(self, key)
    end)

    -- Hook the client event that handles notifications if possible
    -- Many games use a specific RemoteEvent for notifications
    -- For now, we rely on the UI monitor which is already improved.

    -- Monitor notifications for catches (More reliable than hooking the remote since we can't easily see the return of FireServer)
    handleNotification = function(child)
        if not state.WebhookEnabled then return end
        
        -- Use task.spawn to not block the main monitor
        task.spawn(function()
            -- Wait a bit for children to be added
            local main = child:WaitForChild("Main", 2) or child:WaitForChild("main", 2)
            if main then
                local title = main:WaitForChild("Title", 2) or main:WaitForChild("title", 2)
                local amount = main:WaitForChild("Amount", 2) or main:WaitForChild("amount", 2)
                
                if title and title:IsA("TextLabel") then
                    -- Wait for text to be populated if it's empty
                    local timeout = 0
                    while title.Text == "" and timeout < 10 do
                        task.wait(0.1)
                        timeout = timeout + 1
                    end
                    
                    local fishName = title.Text
                    if fishName ~= "" then
                        local tierStr = "1"
                        if amount and amount:IsA("TextLabel") then
                            -- Extract tier from amount text like "Tier 5" or "Tier: 5"
                            tierStr = amount.Text:match("Tier%s*[:]?%s*(%d+)") or "1"
                        end
                        
                        -- Only send if it looks like a fish catch (names are usually capitalized or have multiple words)
                        if #fishName > 1 then
                            SendWebhook(fishName, tierStr)
                        end
                    end
                end
            end
        end)
    end

    task.spawn(function()
        local playerGui = LocalPlayer:WaitForChild("PlayerGui")
        
        local function setupMonitor()
            print("[ErHub] Setting up UI Notification Monitor...")
            local smallNotif = playerGui:WaitForChild("Small Notification", 10)
            if smallNotif then
                local display = smallNotif:WaitForChild("Display", 5) or smallNotif:WaitForChild("display", 5)
                if display then
                    display.ChildAdded:Connect(handleNotification)
                    -- Check existing
                    for _, child in pairs(display:GetChildren()) do
                        if child:IsA("Frame") then
                            handleNotification(child)
                        end
                    end
                end
            end
        end

        setupMonitor()
        -- Re-setup if GUI resets
        playerGui.ChildAdded:Connect(function(child)
            if child.Name == "Small Notification" then
                setupMonitor()
            end
        end)
    end)

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
        task.spawn(function()
            while task.wait(1) do
                if state.ReduceMap then
                    for _, v in game:GetDescendants() do
                        OptimizeObject(v)
                    end
                end
            end
        end)
        
        game.DescendantAdded:Connect(function(v)
            if state.ReduceMap then
                OptimizeObject(v)
            end
        end)
        
        RunService.Heartbeat:Connect(function()
            if state.ReduceMap then
                settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
                ClearTerrainWater()
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
    local WebhookTab = Window:Tab({ Title = "Webhook", Icon = "lucide:message-square" })
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

    local FishingSupportSection = BlatantTab:Section({ Title = sTitle("Fishing Support"), Icon = "lucide:life-buoy" })

    FishingSupportSection:Toggle({
        Title = sBtn("Auto Equip Rod"),
        Content = sDesc("Automatically equips the fishing rod from Slot 1."),
        Callback = function(v)
            state.AutoEquipRod = v
            if v then
                task.spawn(function()
                    while state.AutoEquipRod do
                        local char = LocalPlayer.Character
                        if char and not char:FindFirstChildOfClass("Tool") then
                            equipRemote:FireServer(1)
                        end
                        task.wait(1)
                    end
                end)
            end
        end
    })

    local walkOnWaterPart
    FishingSupportSection:Toggle({
        Title = sBtn("Walk On Water"),
        Content = sDesc("Allows you to walk on water surfaces."),
        Callback = function(v)
            state.WalkOnWater = v
            if v then
                walkOnWaterPart = Instance.new("Part")
                walkOnWaterPart.Name = "WalkOnWaterPart"
                walkOnWaterPart.Size = Vector3.new(1000, 1, 1000)
                walkOnWaterPart.Transparency = 1
                walkOnWaterPart.Anchored = true
                walkOnWaterPart.Position = Vector3.new(0, -2, 0) -- Adjusted height for water surface
                walkOnWaterPart.Parent = workspace
                
                task.spawn(function()
                    while state.WalkOnWater do
                        local char = LocalPlayer.Character
                        if char and char:FindFirstChild("HumanoidRootPart") then
                            walkOnWaterPart.Position = Vector3.new(char.HumanoidRootPart.Position.X, -2, char.HumanoidRootPart.Position.Z)
                        end
                        task.wait()
                    end
                end)
            else
                if walkOnWaterPart then walkOnWaterPart:Destroy() walkOnWaterPart = nil end
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

    local teleportLocations = {
        ["Esoteric Depths"] = CFrame.new(3230.84, -1303, 1453.18),
        ["Lost Isle"] = CFrame.new(-3741.31494141, -135.07441711, -1009.24774170, -0.98377842, -0.00000002, -0.17938799, -0.00000002, 1.00000000, -0.00000002, 0.17938799, -0.00000002, -0.98377842),
        ["Fisherman Isle"] = CFrame.new(22.4053421, 9.88372707, 2813.25854, 0.866007268, 0, 0.500031412, 0, 1, 0, -0.500031412, 0, 0.866007268),
        ["Ancient Jungle"] = CFrame.new(1241, 7.96969652, -148, 0.173648223, 0, 0.98480773, 0, 1, 0, -0.98480773, 0, 0.173648223),
        ["Ancient Ruin"] = CFrame.new(6086, -585.924194, 4638, -0.939692616, 0, 0.342020214, 0, 1, 0, -0.342020214, 0, -0.939692616),
        ["Coral"] = CFrame.new(-3031.87988, 2.51982188, 2276.36011, -4.37113883e-08, 0, 1, 0, 1, 0, -1, 0, -4.37113883e-08),
        ["Creater"] = CFrame.new(1079.56995, 3.64500737, 5080.3501, -4.37113883e-08, 0, 1, 0, 1, 0, -1, 0, -4.37113883e-08),
        ["Kohana"] = CFrame.new(-625, 19.2500706, 424, -1, 2.33922881e-10, -8.74227766e-08, 2.33922548e-10, 1, 4.04458023e-09, 8.74227766e-08, 4.04458023e-09, -1),
        ["Sacred Tample"] = CFrame.new(1485, -21.8749847, -641, 0.866025388, 4.6955515e-09, -0.5, -4.46844801e-08, 1, -6.80046881e-08, 0.5, 8.12360241e-08, 0.866025388),
        ["Sisyphus Statue"] = CFrame.new(-3702, -135.073914, -1009, -1, -3.08633585e-09, -8.74227766e-08, -3.08633119e-09, 1, -5.35081135e-08, 8.74227766e-08, -5.35081135e-08, -1),
        ["Treasure Room"] = CFrame.new(-3609, -279.07373, -1591, 1, 2.84535484e-09, -1.33540589e-14, -2.84535484e-09, 1, -4.93442265e-08, 1.32136572e-14, 4.93442265e-08, 1),
        ["Tropical"] = CFrame.new(-2020, 4.74434376, 3755, -1, -9.58797375e-10, -8.74227766e-08, -9.58795932e-10, 1, -1.6633031e-08, 8.74227766e-08, -1.6633031e-08, -1),
        ["Weather Machine"] = CFrame.new(-1524.88, 2.87499976, 1915.56006, -1, -6.92853996e-09, -8.74227766e-08, -6.92852931e-09, 1, -1.20227327e-07, 8.74227766e-08, -1.20227327e-07, -1),
        ["BLACK HOLE"] = CFrame.new(-100524.88, 100000000.87499976, 1900015.56006, -1, -6.92853996e-09, -8.74227766e-08, -6.92852931e-09, 1, -1.20227327e-07, 8.74227766e-08, -1.20227327e-07, -1)
    }

    local teleportNames = {}
    for name, _ in pairs(teleportLocations) do
        table.insert(teleportNames, sBtn(name))
    end
    table.sort(teleportNames)

    IslandTeleportSection:Dropdown({
        Title = sBtn("Pilih Island"),
        Values = teleportNames,
        Default = sBtn("Treasure Room"),
        Callback = function(v)
            local name = v:gsub("<[^>]*>", "") -- Strip tags
            local targetCFrame = teleportLocations[name]
            
            if targetCFrame then
                local char = Players.LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    char.HumanoidRootPart.CFrame = targetCFrame
                    NotifySuccess("Teleport Berhasil", "Berhasil teleport ke " .. name)
                else
                    NotifyError("Teleport Gagal", "Karakter tidak ditemukan.")
                end
            end
        end
    })

    local MovementSection = UtilityTab:Section({ Title = sTitle("Movement"), Icon = "lucide:move" })

    MovementSection:Slider({
        Title = sBtn("WalkSpeed"),
        Desc = sDesc("Adjust your movement speed (Default: 16)"),
        Step = 1,
        Value = {
            Min = 16,
            Max = 200,
            Default = 16,
        },
        Callback = function(v)
            state.WalkSpeed = v
        end
    })

    MovementSection:Slider({
        Title = sBtn("JumpPower"),
        Desc = sDesc("Adjust your jump height (Default: 50)"),
        Step = 1,
        Value = {
            Min = 50,
            Max = 300,
            Default = 50,
        },
        Callback = function(v)
            state.JumpPower = v
        end
    })

    -------------------------------------------
    ----- =======[ WEBHOOK TAB ] =======
    -------------------------------------------

    local WebhookSection = WebhookTab:Section({ Title = sTitle("Webhook Settings"), Icon = "message-square" })

    WebhookSection:Input({
        Title = sBtn("Webhook URL"),
        Content = sDesc("Enter your Discord Webhook URL"),
        Placeholder = "https://discord.com/api/webhooks/...",
        Callback = function(v)
            state.WebhookURL = v
            NotifySuccess("Webhook Set", "Webhook URL updated.")
        end
    })

    WebhookSection:Toggle({
        Title = sBtn("Enable Webhook"),
        Content = sDesc("Send notification to Discord when catching a fish."),
        Callback = function(v)
            state.WebhookEnabled = v
            if v and state.WebhookURL == "" then
                NotifyError("Error", "Please set Webhook URL first!")
            end
        end
    })

    WebhookSection:Button({
        Title = sBtn("Test Webhook"),
        Callback = function()
            if state.WebhookURL ~= "" then
                local oldEnabled = state.WebhookEnabled
                state.WebhookEnabled = true -- Temporarily enable for test
                SendWebhook("Test Fish", "7")
                state.WebhookEnabled = oldEnabled -- Restore
                NotifyInfo("Sent", "Test webhook sent!")
            else
                NotifyError("Error", "No Webhook URL set!")
            end
        end
    })

    WebhookSection:Dropdown({
        Title = sBtn("Select Tiers"),
        Content = sDesc("Select which fish tiers should trigger notifications."),
        Multi = true,
        Values = {sBtn("common"), sBtn("uncommon"), sBtn("rare"), sBtn("epic"), sBtn("legendary"), sBtn("mythic"), sBtn("secret")},
        Default = {sBtn("common"), sBtn("uncommon"), sBtn("rare"), sBtn("epic"), sBtn("legendary"), sBtn("mythic"), sBtn("secret")},
        Callback = function(v)
            -- Reset all to false first
            for i = 1, 7 do
                state.WebhookTiers[tostring(i)] = false
            end
            
            -- Enable selected ones
            for _, selected in pairs(v) do
                local tierNum = selected:match("Tier (%d+)")
                if tierNum then
                    state.WebhookTiers[tierNum] = true
                end
            end
        end
    })

    -------------------------------------------
    ----- =======[ MISC TAB ] =======
    -------------------------------------------

    local SupportSection = MiscTab:Section({ Title = sTitle("Support Feature"), Icon = "lucide:heart-handshake" })

    SupportSection:Toggle({
        Title = sBtn("No Fishing Animation"),
        Content = sDesc("Disables fishing animations for a cleaner look."),
        Callback = function(v) 
            state.NoFishingAnimation = v 
            ToggleAnimations(v)
        end
    })

    SupportSection:Toggle({
        Title = sBtn("Fullbright"),
        Content = sDesc("Makes the world bright and clear."),
        Callback = function(v) 
            state.Fullbright = v 
            ToggleFullbright(v)
        end
    })

    SupportSection:Toggle({
        Title = sBtn("Show Real Ping Panel"),
        Content = sDesc("Displays a real-time ping indicator."),
        Callback = function(v) state.ShowPing = v end
    })

    SupportSection:Toggle({
        Title = sBtn("Lock Position"),
        Content = sDesc("Freezes your character in place."),
        Callback = function(v) 
            state.LockPosition = v 
            ToggleLockPosition(v)
        end
    })

    SupportSection:Toggle({
        Title = sBtn("Disable Skin Effect"),
        Content = sDesc("Hides rod skin effects."),
        Callback = function(v) state.DisableSkinEffect = v end
    })

    SupportSection:Toggle({
        Title = sBtn("Disable Effect"),
        Content = sDesc("Hides general particles and beams."),
        Callback = function(v) state.DisableEffect = v end
    })

    SupportSection:Toggle({
        Title = sBtn("Disable Fishing Effect"),
        Content = sDesc("Hides water splashes and bubbles."),
        Callback = function(v) state.DisableFishingEffect = v end
    })

    SupportSection:Toggle({
        Title = sBtn("Disable Cutscene"),
        Content = sDesc("Blocks cutscene-related events."),
        Callback = function(v) state.DisableCutscene = v end
    })

    local BoosterSection = MiscTab:Section({ Title = sTitle("Booster Fps"), Icon = "lucide:zap" })

    BoosterSection:Toggle({
        Title = sBtn("Reduce Map"),
        Content = sDesc("Optimizes map objects to boost FPS."),
        Callback = function(v) state.ReduceMap = v end
    })

    local ServerSection = MiscTab:Section({ Title = sTitle("Server Feature"), Icon = "lucide:server" })

    ServerSection:Toggle({
        Title = sBtn("Auto Reconnect"),
        Content = sDesc("Automatically reconnects if disconnected."),
        Callback = function(v) state.AutoReconnect = v end
    })

    ServerSection:Toggle({
        Title = sBtn("Anti-Afk"),
        Content = sDesc("Prevents being kicked for inactivity."),
        Callback = function(v) state.AntiAfk = v end
    })

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
                                -- Ensure webhook still catches it before destruction
                                if state.WebhookEnabled then
                                    handleNotification(child)
                                end
                                task.wait(1.5) -- Give it more time for webhook to process (wait for text to populate)
                                if child and child.Parent then
                                    child:Destroy()
                                end
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



