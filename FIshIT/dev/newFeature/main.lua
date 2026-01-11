--[[
    Title: Smart Blatant Fishing System
    Feature: Automatic Rod Stat Detection + Intelligent Batch Execution
    Anti-Detection: Randomized packets, dynamic UUIDs, realistic timing
]]

--------------------------------------------------------------------------------
-- 1. Configuration & State
--------------------------------------------------------------------------------
local Config = {
    BatchDelay = 0.7,      -- Delay between batches (0.5-1.0s recommended)
    MinBatchSize = 5,      -- Minimum concurrent attempts
    MaxBatchSize = 10,     -- Maximum concurrent attempts
    IsRunning = false,
    DetectedRodStats = nil -- Cached rod statistics
}

--------------------------------------------------------------------------------
-- 2. Service Management
--------------------------------------------------------------------------------
local Services = {
    Players = game:GetService("Players"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    RunService = game:GetService("RunService"),
    HttpService = game:GetService("HttpService")
}

local LocalPlayer = Services.Players.LocalPlayer
local Net = Services.ReplicatedStorage:WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("sleitnick_net@0.2.0")
    :WaitForChild("net")

local Remotes = {
    Rod = Net:WaitForChild("RF/ChargeFishingRod"),
    Minigame = Net:WaitForChild("RF/RequestFishingMinigameStarted"),
    Complete = Net:WaitForChild("RE/FishingCompleted"),
    Cancel = Net:WaitForChild("RF/CancelFishingInputs"),
    Equip = Net:WaitForChild("RE/EquipToolFromHotbar")
}

--------------------------------------------------------------------------------
-- 3. Area Detection Logic
--------------------------------------------------------------------------------
local TeleportLocations = {
    ["Esoteric Depths"] = CFrame.new(3230.84, -1303, 1453.18),
    ["Lost Isle"] = CFrame.new(-3741, -135, -1009),
    ["Fisherman Isle"] = CFrame.new(22, 10, 2813),
    ["Ancient Jungle"] = CFrame.new(1241, 8, -148),
    ["Ancient Ruin"] = CFrame.new(6086, -586, 4638),
    ["Coral"] = CFrame.new(-3032, 2.5, 2276),
    ["Creator"] = CFrame.new(1080, 3.6, 5080),
    ["Kohana"] = CFrame.new(-625, 19, 424),
    ["Sacred Temple"] = CFrame.new(1485, -22, -641),
    ["Sisyphus Statue"] = CFrame.new(-3702, -135, -1009),
    ["Treasure Room"] = CFrame.new(-3609, -279, -1591),
    ["Tropical"] = CFrame.new(-2020, 5, 3755),
    ["Weather Machine"] = CFrame.new(-1525, 3, 1915),
}

local function GetCurrentArea()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return "Unknown" end
    
    local pos = char.HumanoidRootPart.Position
    local closestArea = "Unknown"
    local minDist = math.huge
    
    for name, cf in pairs(TeleportLocations) do
        local dist = (pos - cf.Position).Magnitude
        if dist < minDist then
            minDist = dist
            closestArea = name
        end
    end
    
    if minDist > 500 then return "Ocean" end
    return closestArea
end

--------------------------------------------------------------------------------
-- 4. Automatic Rod Statistics Detection
--------------------------------------------------------------------------------
local RodDetection = {}

function RodDetection.GetEquippedRod()
    -- Check character first
    local char = LocalPlayer.Character
    if char then
        for _, tool in pairs(char:GetChildren()) do
            if tool:IsA("Tool") then
                return tool
            end
        end
    end
    
    -- Check backpack
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, tool in pairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                return tool
            end
        end
    end
    
    return nil
end

function RodDetection.GetRodStats()
    local rod = RodDetection.GetEquippedRod()
    if not rod then
        warn("[RodDetection] No rod equipped, using defaults")
        return {
            Tier = 7,
            ClickPower = 0.31,
            Resilience = 100,
            BaseLuck = 1.0,
            MutationMultiplier = 1.0,
            Name = "Unknown"
        }
    end
    
    local success, stats = pcall(function()
        local itemsFolder = Services.ReplicatedStorage:FindFirstChild("Items")
        if not itemsFolder then
            error("Items folder not found")
        end
        
        local rodModule = itemsFolder:FindFirstChild(rod.Name)
        if not rodModule or not rodModule:IsA("ModuleScript") then
            error("Rod module not found for: " .. rod.Name)
        end
        
        local rodData = require(rodModule)
        
        -- Extract stats from module structure
        return {
            Tier = rodData.Data and rodData.Data.Tier or 7,
            ClickPower = rodData.ClickPower or 0.31,
            Resilience = rodData.Resilience or 100,
            BaseLuck = rodData.BaseLuck or 1.0,
            MutationMultiplier = rodData.MutationMultiplier or 1.0,
            Name = rod.Name
        }
    end)
    
    if success and stats then
        Config.DetectedRodStats = stats
        return stats
    else
        warn("[RodDetection] Failed to detect stats, using defaults")
        return {
            Tier = 7,
            ClickPower = 0.31,
            Resilience = 100,
            BaseLuck = 1.0,
            MutationMultiplier = 1.0,
            Name = "Unknown"
        }
    end
end

--------------------------------------------------------------------------------
-- 5. Smart Batch Fishing Engine
--------------------------------------------------------------------------------
local FishingEngine = {}

function FishingEngine.PerformSmartBatchCatch()
    local rodStats = RodDetection.GetRodStats()
    local batchSize = math.random(Config.MinBatchSize, Config.MaxBatchSize)
    
    for i = 1, batchSize do
        task.spawn(function()
            local success, err = pcall(function()
                -- 0. Auto Equip (Safety)
                local char = LocalPlayer.Character
                if not char or not char:FindFirstChildOfClass("Tool") then
                    Remotes.Equip:FireServer(1)
                    task.wait(0.1)
                end
                
                -- 1. Generate dynamic data
                local currentArea = GetCurrentArea()
                local currentTime = workspace:GetServerTimeNow()
                local uniqueId = Services.HttpService:GenerateGUID(false)
                
                -- Anti-detection randomization
                local randomSeed = math.random(1, 999999)
                local caughtFishCount = math.random(0, 3)
                local minorDelay = math.random(1, 50) / 1000 -- 0.001-0.05s
                
                -- 2. Charge rod
                Remotes.Rod:InvokeServer(currentTime)
                task.wait(minorDelay)
                
                -- 3. Build smart arguments using REAL rod stats
                local args = {
                    ["FishStrength"] = rodStats.ClickPower * 100,
                    ["FishingRodTier"] = rodStats.Tier,
                    ["SelectedRarity"] = 0.015,
                    ["AreaName"] = currentArea,
                    ["UUID"] = uniqueId,
                    ["StartTime"] = currentTime,
                    ["LastShift"] = currentTime,
                    ["RandomSeed"] = randomSeed,
                    ["CaughtFish"] = caughtFishCount,
                    ["Resilience"] = rodStats.Resilience,
                    ["BaseLuck"] = rodStats.BaseLuck
                }
                
                -- 4. Invoke minigame with smart args
                local biteData = Remotes.Minigame:InvokeServer(args)
                
                -- 5. Complete if valid
                if biteData then
                    task.wait(minorDelay)
                    Remotes.Complete:FireServer(true)
                end
                
                -- 6. Cleanup
                task.wait(minorDelay)
                Remotes.Cancel:InvokeServer()
            end)

            if not success and Config.IsRunning then
                warn("[SmartBatch] Error: " .. tostring(err))
            end
        end)
    end
end

function FishingEngine.EmergencyStop()
    Config.IsRunning = false
    task.spawn(function()
        pcall(function() Remotes.Cancel:InvokeServer() end)
    end)
    print("🛑 Smart Blatant Mode Stopped")
end

function FishingEngine.StartSmartBlatantLoop()
    if Config.IsRunning then return end
    Config.IsRunning = true
    
    -- Detect rod stats on start
    local stats = RodDetection.GetRodStats()
    print("🎣 Smart Blatant Mode Active")
    print("📊 Detected Rod: " .. stats.Name)
    print("⚡ Tier: " .. stats.Tier .. " | Power: " .. stats.ClickPower)
    
    task.spawn(function()
        while Config.IsRunning do
            FishingEngine.PerformSmartBatchCatch()
            
            -- Randomized batch delay for anti-detection
            local delay = Config.BatchDelay + (math.random(-100, 100) / 1000)
            task.wait(math.max(0.3, delay))
        end
    end)
end

--------------------------------------------------------------------------------
-- 6. User Interface
--------------------------------------------------------------------------------
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local function sTitle(text) return string.format('<font size="13">%s</font>', text) end
local function sDesc(text) return string.format('<font size="9">%s</font>', text) end
local function sBtn(text) return string.format('<font size="11">%s</font>', text) end

local Window = WindUI:CreateWindow({
    Title = "Smart Blatant System",
    Icon = "brain",
    Author = "Gemini AI",
    Folder = "SmartFishing",
    Size = UDim2.fromOffset(450, 300),
    MinSize = Vector2.new(450, 300),
    MaxSize = Vector2.new(850, 600),
    Transparent = true,
    Theme = "Dark",
    Resizable = true,
    SideBarWidth = 140,
    BackgroundImageTransparency = 0.5,
    HideSearchBar = true,
})

Window:SetToggleKey(Enum.KeyCode.RightControl)
WindUI:SetNotificationLower(true)

local MainTab = Window:Tab({ Title = "Smart Fishing", Icon = "lucide:fish" })

-- Rod Stats Section
local StatsSection = MainTab:Section({ Title = sTitle("Rod Detection"), Icon = "lucide:info" })

StatsSection:Button({
    Title = sBtn("🔍 Detect Current Rod"),
    Callback = function()
        local stats = RodDetection.GetRodStats()
        WindUI:Notify({
            Title = "Rod Detected",
            Content = string.format("%s | Tier %d | Power %.2f", stats.Name, stats.Tier, stats.ClickPower),
            Duration = 3,
            Icon = "circle-check"
        })
    end
})

StatsSection:Paragraph({
    Title = sTitle("Current Rod"),
    Content = function()
        local stats = Config.DetectedRodStats or RodDetection.GetRodStats()
        return string.format("Name: %s\nTier: %d\nPower: %.2f", stats.Name, stats.Tier, stats.ClickPower)
    end
})

-- Configuration Section
local ConfigSection = MainTab:Section({ Title = sTitle("Batch Settings"), Icon = "lucide:settings" })

ConfigSection:Slider({
    Title = sBtn("Batch Delay"),
    Desc = sDesc("Delay between batches (0.5-1.5s)"),
    Step = 0.1,
    Value = {
        Min = 0.5,
        Max = 1.5,
        Default = 0.7,
    },
    Callback = function(v)
        Config.BatchDelay = v
    end
})

ConfigSection:Slider({
    Title = sBtn("Min Batch Size"),
    Desc = sDesc("Minimum concurrent attempts"),
    Step = 1,
    Value = {
        Min = 3,
        Max = 8,
        Default = 5,
    },
    Callback = function(v)
        Config.MinBatchSize = v
    end
})

ConfigSection:Slider({
    Title = sBtn("Max Batch Size"),
    Desc = sDesc("Maximum concurrent attempts"),
    Step = 1,
    Value = {
        Min = 6,
        Max = 15,
        Default = 10,
    },
    Callback = function(v)
        Config.MaxBatchSize = v
    end
})

-- Automation Section
local AutoSection = MainTab:Section({ Title = sTitle("Smart Automation"), Icon = "lucide:zap" })

AutoSection:Toggle({
    Title = sBtn("🧠 Smart Blatant Mode"),
    Content = sDesc("Auto-detects rod stats and executes intelligent batches"),
    Default = false,
    Callback = function(Value)
        if Value then
            FishingEngine.StartSmartBlatantLoop()
        else
            Config.IsRunning = false
        end
    end
})

AutoSection:Button({
    Title = sBtn("🚨 Emergency Stop"),
    Callback = function()
        FishingEngine.EmergencyStop()
    end
})

AutoSection:Paragraph({
    Title = sTitle("Features"),
    Content = "✓ Automatic rod detection\n✓ Dynamic stat extraction\n✓ Randomized packets\n✓ Anti-detection timing"
})
