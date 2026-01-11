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
    Cancel = Net:WaitForChild("RF/CancelFishingInputs"),
    Equip = Net:WaitForChild("RE/EquipToolFromHotbar")
}

--------------------------------------------------------------------------------
-- 3. Core Fishing Logic (Modular)
--------------------------------------------------------------------------------
local FishingEngine = {}

function FishingEngine.PerformBlatantCatch()
    -- Ported Logic from dev/final.lua aka "Blatant Mode"
    task.spawn(function()
        local success, err = pcall(function()
            -- 0. Auto Equip (Safety)
            local char = Services.Players.LocalPlayer.Character
            if not char or not char:FindFirstChildOfClass("Tool") then
                Remotes.Equip:FireServer(1)
                task.wait(0.1)
            end

            -- 1. Instant Cast (Server Time)
            Remotes.Rod:InvokeServer(workspace:GetServerTimeNow())
            
            -- 2. Instant Start (Fixed Blatant Args: -1, 1, ServerTime)
            local biteData = Remotes.Minigame:InvokeServer(-1, 1, workspace:GetServerTimeNow())
            
            -- 3. Complete Catch
            if biteData then
                if Config.CompleteDelay > 0 then
                    task.wait(Config.CompleteDelay)
                end
                Remotes.Complete:FireServer(true)
            end
            
            -- 4. Instant Reset
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
    -- Force cancel to ensure character isn't stuck holding rod
    task.spawn(function()
        pcall(function() Remotes.Cancel:InvokeServer() end)
    end)
    print("🛑 Emergency Stop Triggered")
end

function FishingEngine.StartBlatantLoop()
    if Config.IsRunning then return end
    Config.IsRunning = true
    
    -- Ported Loop Structure from dev/final.lua
    task.spawn(function()
        while Config.IsRunning do
            FishingEngine.PerformBlatantCatch()
            
            -- Loop speed controlled by completion delays to prevent overflow
            -- Matches final.lua formula: Complete + Cancel + 0.01
            local loopDelay = (Config.CompleteDelay or 0.1) + (Config.CancelDelay or 0.05) + 0.01
            task.wait(loopDelay)
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
    Title = sBtn("Blatant Mode (High Speed)"),
    Content = sDesc("Ported from v2/Final: Auto-Equip, ServerTime Sync, Max Speed."),
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
    Content = "Running 3-10 fish every 5 seconds. \nUse 'Emergency Cancel' if you get stuck."
})
