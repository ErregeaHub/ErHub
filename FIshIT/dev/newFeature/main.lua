--[[
    Title: Advanced Fishing Analyst (Ultra Fast Batching)
    Role: Senior Roblox Developer
    Feature: Ultra Fast Instant Catch (3-10 Fish / 5s) via Blatant Remote Exploitation
    Optimization: Batch Execution & Anti-Ticket Implementation
]]

--------------------------------------------------------------------------------
-- 1. Configuration & State
--------------------------------------------------------------------------------
local Config = {
    BatchDelay = 0.5, -- Delay between batches (User requirement 0.5-1.0s)
    BatchSize = 5,    -- Number of concurrent attempts per batch
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
-- Copied from main.lua for accurate area detection
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
    
    -- Heuristic: If detecting specific large areas (like Ocean/Main Map), default if far from POIs
    if minDist > 500 and closestArea == "Unknown" then
        return "Ocean" 
    end
    
    return closestArea
end

--------------------------------------------------------------------------------
-- 4. Core Fishing Engine (Ultra Fast Batching)
--------------------------------------------------------------------------------
local FishingEngine = {}

function FishingEngine.PerformBatchCatch()
    -- Batch Execution Loop (User Req #2)
    for i = 1, Config.BatchSize do
        task.spawn(function()
            local success, err = pcall(function()
                -- 0. Auto Equip (Safety)
                local char = LocalPlayer.Character
                if not char or not char:FindFirstChildOfClass("Tool") then
                    Remotes.Equip:FireServer(1)
                    task.wait(0.1)
                end
                
                -- Dynamic State Generation (User Req #3)
                local currentArea = GetCurrentArea()
                local currentTime = workspace:GetServerTimeNow()
                local uniqueId = Services.HttpService:GenerateGUID(false)

                -- 1. Instant Charge
                Remotes.Rod:InvokeServer(currentTime)
                
                -- 2. Arguments Construction (User Req #1 & #3)
                local args = {
                    ["FishStrength"] = 100,      -- Max strength assumption
                    ["FishingRodTier"] = 7,      -- Max rod tier assumption
                    ["SelectedRarity"] = 0.015,  -- Target rarity control
                    ["AreaName"] = currentArea,
                    ["UUID"] = uniqueId,
                    ["StartTime"] = currentTime,
                    ["LastShift"] = currentTime
                }
                
                -- 3. Invoke Minigame (Blatant args)
                local biteData = Remotes.Minigame:InvokeServer(args)
                
                -- 4. Complete if valid
                if biteData then
                    -- No wait here for "Instant" feel, or very minimal if needed
                    Remotes.Complete:FireServer(true)
                end
                
                -- 5. Cleanup
                Remotes.Cancel:InvokeServer()
            end)

            if not success and Config.IsRunning then
                warn("[FishingEngine] Batch Error: " .. tostring(err))
            end
        end)
    end
end

function FishingEngine.EmergencyStop()
    Config.IsRunning = false
    task.spawn(function()
        pcall(function() Remotes.Cancel:InvokeServer() end)
    end)
    print("🛑 Emergency Stop Triggered")
end

function FishingEngine.StartBlatantLoop()
    if Config.IsRunning then return end
    Config.IsRunning = true
    
    print("🚀 Starting Ultra Fast Batch Mode")
    
    task.spawn(function()
        while Config.IsRunning do
            FishingEngine.PerformBatchCatch()
            
            -- Anti-Kick / Rate Limit Delay (User Req #4)
            task.wait(Config.BatchDelay)
        end
    end)
end

--------------------------------------------------------------------------------
-- 5. User Interface (WindUI)
--------------------------------------------------------------------------------
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- Helper functions
local function sTitle(text) return string.format('<font size="13">%s</font>', text) end
local function sDesc(text) return string.format('<font size="9">%s</font>', text) end
local function sBtn(text) return string.format('<font size="11">%s</font>', text) end

-- Window Setup
local Window = WindUI:CreateWindow({
    Title = "Ultra Fast Analyst",
    Icon = "zap",
    Author = "Gemini",
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

Window:SetToggleKey(Enum.KeyCode.RightControl)
WindUI:SetNotificationLower(true)

-- Tab Creation
local MainTab = Window:Tab({ Title = "Fishing", Icon = "lucide:fish" })

-- 5.1 Configuration Section
local ConfigSection = MainTab:Section({ Title = sTitle("Batch Settings"), Icon = "lucide:settings" })

ConfigSection:Input({
    Title = sBtn("Batch Delay (s)"),
    Content = sDesc("Delay between batches to prevent kicks (Default: 0.5)"),
    Default = tostring(Config.BatchDelay),
    Placeholder = "0.5",
    Callback = function(Value)
        local num = tonumber(Value)
        if num then Config.BatchDelay = num end
    end
})

-- 5.2 Automation Section
local AutoSection = MainTab:Section({ Title = sTitle("Ultra Fast Automation"), Icon = "lucide:zap" })

AutoSection:Toggle({
    Title = sBtn("Ultra Fast Mode"),
    Content = sDesc("Executes 5 catches simultaneously per batch."),
    Default = false,
    Callback = function(Value)
        if Value then
            FishingEngine.StartBlatantLoop()
        else
            Config.IsRunning = false
        end
    end
})

AutoSection:Button({
    Title = sBtn("🚨 Emergency Cancel"),
    Callback = function()
        FishingEngine.EmergencyStop()
    end
})

AutoSection:Paragraph({
    Title = sTitle("Analyst Note"),
    Content = "Current Mode: Batch Execution (5x)\nStatus: " .. (Config.IsRunning and "Active" or "Idle")
})
