--[[
    Title: Advanced Fishing Analyst (Blatant Mode)
    Feature: High-Speed Automated Fishing with Auto-Equip Detection
    Optimization: Low-End Device Friendly & Modular Architecture
]]

--------------------------------------------------------------------------------
-- 1. Configuration & State
--------------------------------------------------------------------------------
local Config = {
    -- Default Delays (Mutable via UI)
    CompleteDelay = 0.1,
    CancelDelay = 0.05,
    
    -- Status
    IsRunning = false
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
        print("[RodDetection] Failed to detect stats, using defaults")
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

function FishingEngine.PerformBlatantCatch()
    task.spawn(function()
        local success, err = pcall(function()
             -- Step 0 (Auto-Equip Safety): Ensure rod is equipped
            local playerName = Services.Players.LocalPlayer.Name
            local char = workspace:FindFirstChild("Characters") and workspace.Characters:FindFirstChild(playerName)
            if not char or not char:FindFirstChild("!!!EQUIPPED_TOOL!!!") then
                Remotes.Equip:FireServer(1)
                task.wait(0.1)
            end
            
            -- Step 1 (Charge): Begin the fishing action
            Remotes.Rod:InvokeServer(workspace:GetServerTimeNow())
            
            -- Step 2 (Request): Immediately request minigame with blatant arguments
            local biteData = Remotes.Minigame:InvokeServer(-1, 1, workspace:GetServerTimeNow())
            
            -- Step 3 (Complete): Claim catch after minimal delay
            if biteData then
                if Config.CompleteDelay > 0 then
                    task.wait(Config.CompleteDelay)
                end
                Remotes.Complete:FireServer(true)
            end
            
            -- Step 4 (Reset): Reset state for next cast
            if Config.CancelDelay > 0 then
                task.wait(Config.CancelDelay)
            end
            Remotes.Cancel:InvokeServer()
        end)

        if not success and Config.IsRunning then
            -- Silent fail or warn if needed
        end
    end)
end

function FishingEngine.EmergencyStop()
    Config.IsRunning = false
    task.spawn(function()
        pcall(function() Remotes.Cancel:InvokeServer() end)
    end)
    print(" Smart Blatant Mode Stopped")
end

function FishingEngine.StartBlatantLoop()
    if Config.IsRunning then return end
    Config.IsRunning = true
    
    print(" Starting Blatant Mode v2")
    
    -- Auto-Equip rod once before starting
    pcall(function()
        Remotes.Equip:FireServer(1)
    end)
    task.wait(0.000002)
    
    task.spawn(function()
        while Config.IsRunning do
            FishingEngine.PerformBlatantCatch()
            -- Loop speed controlled by CompleteDelay
            task.wait(Config.CompleteDelay or 0.1)
        end
    end)
end

--------------------------------------------------------------------------------
-- 6. User Interface
--------------------------------------------------------------------------------
local success, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
end)

if not success then
    warn("[UI] Failed to load WindUI, using fallback")
    return
end

local function sTitle(text) return string.format('<font size="13">%s</font>', text) end
local function sDesc(text) return string.format('<font size="9">%s</font>', text) end
local function sBtn(text) return string.format('<font size="11">%s</font>', text) end

local windowSuccess, Window = pcall(function()
    return WindUI:CreateWindow({
    Title = "BLATANT",
    Icon = "fish",
    Author = "BLATANT",
    Folder = "FishingConfig",
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
end)

if not windowSuccess or not Window then
    warn("[UI] Failed to create window: ToolTip parent locked error")
    warn("[UI] Script will run without UI - use console commands")
    return
end

Window:SetToggleKey(Enum.KeyCode.RightControl)
WindUI:SetNotificationLower(true)

local MainTab = Window:Tab({ Title = "Fishing", Icon = "lucide:fish" })

-- Timing Settings Section
local TimingSection = MainTab:Section({ Title = sTitle("Timing Settings"), Icon = "lucide:clock" })

TimingSection:Input({
    Title = sBtn("Complete Delay"),
    Content = sDesc("Delay before catching (Default: 0.1s)"),
    Default = tostring(Config.CompleteDelay),
    Placeholder = "0.1",
    Callback = function(Value)
        local num = tonumber(Value)
        if num then Config.CompleteDelay = num end
    end
})

TimingSection:Input({
    Title = sBtn("Cancel Delay"),
    Content = sDesc("Delay after catch (Default: 0.05s)"),
    Default = tostring(Config.CancelDelay),
    Placeholder = "0.05",
    Callback = function(Value)
        local num = tonumber(Value)
        if num then Config.CancelDelay = num end
    end
})

TimingSection:Toggle({
    Title = sBtn("Blatant Mode test"),
    Content = sDesc("Auto-Equip, ServerTime Sync, Max Speed"),
    Default = false,
    Callback = function(Value)
        if Value then
            FishingEngine.StartBlatantLoop()
        else
            Config.IsRunning = false
        end
    end
})

TimingSection:Button({
    Title = sBtn("Recovery Fishing"),
    Callback = function()
        FishingEngine.EmergencyStop()
    end
})

