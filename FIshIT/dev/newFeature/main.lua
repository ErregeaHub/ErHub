--[[
    Title: Advanced Fishing Analyst (Batch Optimization)
    Role: Senior Roblox Developer
    Feature: High-Performance Batch Fishing (3-10 Fish / 5s)
    Optimization: Low-End Device Friendly & Modular Architecture
]]

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
            local biteData = Remotes.Minigame:InvokeServer(unpack(FISH_ARGS))
            
            -- 3. Complete Catch
            if biteData then
                if Config.CompleteDelay > 0 then
                    task.wait(Config.CompleteDelay)
                end
                Remotes.Complete:FireServer(true)
            end
            
            -- 4. Reset / Cancel Inputs
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
            
            for i = 1, batchSize do
                if not Config.IsRunning then break end
                
                FishingEngine.PerformCatch()
                
                -- Micro-yield to prevent network throttling
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

--------------------------------------------------------------------------------
-- 4. User Interface (WindUI Reference Implementation)
--------------------------------------------------------------------------------
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- Helper functions for styling (Matches final.lua text formatting)
local function sTitle(text) return string.format('<font size="13">%s</font>', text) end
local function sDesc(text) return string.format('<font size="9">%s</font>', text) end
local function sBtn(text) return string.format('<font size="11">%s</font>', text) end

-- Window Setup (Matches final.lua configuration)
local Window = WindUI:CreateWindow({
    Title = "Advanced Fishing Analyst",
    Icon = "fish",
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

-- 4.1 Timing Settings Section
local TimingSection = MainTab:Section({ Title = sTitle("Timing Settings"), Icon = "lucide:clock" })

TimingSection:Input({
    Title = sBtn("Complete Delay (s)"),
    Content = sDesc("Delay before catching (Default: 0.1s)"),
    Default = tostring(Config.CompleteDelay),
    Placeholder = "0.1",
    Callback = function(Value)
        local num = tonumber(Value)
        if num then Config.CompleteDelay = num end
    end
})

TimingSection:Input({
    Title = sBtn("Cancel Delay (s)"),
    Content = sDesc("Delay after catch (Default: 0.05s)"),
    Default = tostring(Config.CancelDelay),
    Placeholder = "0.05",
    Callback = function(Value)
        local num = tonumber(Value)
        if num then Config.CancelDelay = num end
    end
})

-- 4.2 Automation Section
local AutoSection = MainTab:Section({ Title = sTitle("Blatant Automation"), Icon = "lucide:zap" })

AutoSection:Toggle({
    Title = sBtn("Blatant Mode (Batch 3-10)"),
    Content = sDesc("Catches a random batch of fish every 5 seconds."),
    Default = false,
    Callback = function(Value)
        if Value then
            FishingEngine.StartBatchLoop()
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
    Content = "Running 3-10 fish every 5 seconds. \nUse 'Emergency Cancel' if you get stuck."
})
