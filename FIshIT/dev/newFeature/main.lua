--[[
    Title: Advanced Fishing Analyst (Batch Optimization)
    Role: Senior Roblox Developer
    Feature: High-Performance Batch Fishing (3-10 Fish / 5s)
    Optimization: Low-End Device Friendly & Modular Architecture
]]
--------------------------------------------------------------------------------
-- 4. User Interface (WindUI)
--------------------------------------------------------------------------------
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "Advanced Fishing Analyst",
    Icon = "rbxassetid://10734951102",
    Author = "Gemini",
    Folder = "FishingConfig",
    Theme = "Dark"
})

local MainTab = Window:CreateTab("Automation", "fish")

-- Section: Timing Configuration
MainTab:AddSection("Timing Settings")

MainTab:AddInput({
    Title = "Complete Delay (s)",
    Default = tostring(Config.CompleteDelay),
    Placeholder = "0.1",
    Callback = function(Value)
        local num = tonumber(Value)
        if num then Config.CompleteDelay = num end
    end
})

MainTab:AddInput({
    Title = "Cancel Delay (s)",
    Default = tostring(Config.CancelDelay),
    Placeholder = "0.05",
    Callback = function(Value)
        local num = tonumber(Value)
        if num then Config.CancelDelay = num end
    end
})

-- Section: Blatant Automation
MainTab:AddSection("Blatant Automation")

MainTab:AddToggle({
    Title = "Blatant Mode (Batch 3-10)",
    Default = false,
    Callback = function(Value)
        if Value then
            FishingEngine.StartBatchLoop()
        else
            Config.IsRunning = false
        end
    end
})

MainTab:AddButton({
    Title = "🚨 Emergency Cancel",
    Callback = function()
        FishingEngine.EmergencyStop()
        -- Note: User needs to toggle off manually to restart loop properly in UI state
        -- but the internal flag is set to false immediately.
    end
})

MainTab:AddParagraph({
    Title = "Analyst Note",
    Content = "Running 3-10 fish every 5 seconds. \nUse 'Emergency Cancel' if you get stuck."
})
--------------------------------------------------------------------------------
-- 1. Configuration & State
--------------------------------------------------------------------------------
local Config = {
    -- Default Delays (Mutable via UI)
    CompleteDelay = 0.1,
    CancelDelay = 0.05,
    
    -- Batch Settings
    BatchInterval = 5,
    MinBatchSize = 3,
    MaxBatchSize = 10,
    
    -- Status
    IsRunning = false
}

-- Magic Constants (Minigame Logic)
-- Note: These arguments are specific to the "Fisch" minigame protocol.
local FISH_ARGS = {
    -1, 
    0.1, 
    1768162459.213601
}

--------------------------------------------------------------------------------
-- 2. Service Management
--------------------------------------------------------------------------------
local Services = {
    Players = game:GetService("Players"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    RunService = game:GetService("RunService")
}

local Net = Services.ReplicatedStorage:WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("sleitnick_net@0.2.0")
    :WaitForChild("net")

local Remotes = {
    Rod = Net:WaitForChild("RF/ChargeFishingRod"),
    Minigame = Net:WaitForChild("RF/RequestFishingMinigameStarted"),
    Complete = Net:WaitForChild("RE/FishingCompleted"),
    Cancel = Net:WaitForChild("RF/CancelFishingInputs")
}

--------------------------------------------------------------------------------
-- 3. Core Fishing Logic (Modular)
--------------------------------------------------------------------------------
local FishingEngine = {}

function FishingEngine.PerformCatch()
    -- Run asynchronously to prevent blocking the batch loop
    task.spawn(function()
        local success, err = pcall(function()
            -- 1. Charge Rod (Server Timestamp)
            Remotes.Rod:InvokeServer(workspace:GetServerTimeNow())
            
            -- 2. Initiate Minigame
            -- We pass specific args to simulate a valid game state start
            local biteData = Remotes.Minigame:InvokeServer(unpack(FISH_ARGS))
            
            -- 3. Complete Catch
            -- Only proceed if the server acknowledged the minigame start
            if biteData then
                if Config.CompleteDelay > 0 then
                    task.wait(Config.CompleteDelay)
                end
                Remotes.Complete:FireServer(true)
            end
            
            -- 4. Reset / Cancel Inputs
            -- Essential for clearing server-side state for the next cast
            if Config.CancelDelay > 0 then
                task.wait(Config.CancelDelay)
            end
            Remotes.Cancel:InvokeServer()
        end)
        
        if not success then
            warn("[FishingEngine] Catch Failed: " .. tostring(err))
        end
    end)
end

function FishingEngine.EmergencyStop()
    Config.IsRunning = false
    -- Force cancel to ensure character isn't stuck holding rod
    task.spawn(function()
        pcall(function() Remotes.Cancel:InvokeServer() end)
    end)
    print("🛑 Emergency Stop Triggered")
end

function FishingEngine.StartBatchLoop()
    if Config.IsRunning then return end -- Prevent multiple loops
    Config.IsRunning = true
    
    task.spawn(function()
        while Config.IsRunning do
            local batchSize = math.random(Config.MinBatchSize, Config.MaxBatchSize)
            -- print(string.format("📊 Batch Started: %d fish", batchSize))
            
            for i = 1, batchSize do
                if not Config.IsRunning then break end
                
                FishingEngine.PerformCatch()
                
                -- Micro-yield to prevent network throttling/packet loss
                -- Spreading calls slightly is safer than instant burst
                task.wait(0.1) 
            end
            
            -- Wait for next batch interval
            local elapsed = 0
            while elapsed < Config.BatchInterval do
                if not Config.IsRunning then break end
                elapsed = elapsed + task.wait(0.5)
            end
        end
    end)
end

