local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- -------------------------------------------
-- ----- =======[ CUSTOM THEME ] =======
-- -------------------------------------------
local DeepNavy = {
    Name = "DeepNavy",
    
    Accent = Color3.fromHex("#00bfff"),      
    Dialog = Color3.fromHex("#1d2d44"),      
    Outline = Color3.fromHex("#1d2d44"),     
    Text = Color3.fromHex("#F0EBD8"),        
    Placeholder = Color3.fromHex("#748CAB"), 
    Background = Color3.fromHex("#0d1321"),  
    Button = Color3.fromHex("#1d2d44"),      
    Icon = Color3.fromHex("#F0EBD8"),        
    Toggle = Color3.fromHex("#00bfff"),      
    Slider = Color3.fromHex("#00bfff"),      
    Checkbox = Color3.fromHex("#00bfff"),    
    
    Transparency = {
        Background = 0.6,
        Dialog = 0.8,
        Button = 0.8,
    }
}

WindUI:AddTheme(DeepNavy)
WindUI:SetTheme("DeepNavy")

-- Variabel Kontrol
local AutoCollect = false
local WaitTime = 5 
local PlotActionPath = game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Net"):WaitForChild("RF/Plot.PlotAction")

-- -------------------------------------------
-- ----- =======[ MAPPING SYSTEM ] =======
-- -------------------------------------------
local function findPlayerBase()
    if not workspace:FindFirstChild("Bases_NEW") then 
        warn("Bases_NEW folder not found in Workspace")
        return nil 
    end
    for _, base in pairs(workspace.Bases_NEW:GetChildren()) do
        local holder = base:GetAttribute("Holder")
        if tostring(holder) == tostring(game.Players.LocalPlayer.UserId) then
            _G.MyPlotID = base.Name -- Store GUID
            print("Base found (GUID):", _G.MyPlotID)
            return base
        end
    end
    warn("No base found for Holder:", game.Players.LocalPlayer.UserId)
    return nil
end

local function getBrainrotSlots()
    local base = findPlayerBase()
    local foundItems = {}
    
    if base then
        print("Scanning slots in GUID base:", _G.MyPlotID)
        for _, slot in pairs(base:GetChildren()) do
            local brainrotName = slot:GetAttribute("BrainrotName")
            if brainrotName then
                local slotIndex = string.match(slot.Name, "%d+")
                if slotIndex then
                    print("Found Brainrot:", brainrotName, "Index:", slotIndex)
                    table.insert(foundItems, {Name = brainrotName, SlotID = slotIndex})
                end
            end
        end
    else
        warn("Base not found for mapping in Bases_NEW")
    end
    
    print("Total valid Brainrots found:", #foundItems)
    return foundItems
end

-- Initial Base Detection
task.spawn(function()
    findPlayerBase()
end)

-- -------------------------------------------
-- ----- =======[ NOTIFICATIONS ] =======
-- -------------------------------------------
local function NotifySuccess(title, message)
    WindUI:Notify({Title = title, Content = message, Duration = 1, Icon = "circle-check"})
end

local function sTitle(text) return string.format('<font size="13">%s</font>', text) end
local function sDesc(text) return string.format('<font size="9">%s</font>', text) end
local function sBtn(text) return string.format('<font size="11">%s</font>', text) end

-- Inisialisasi Window
local Window = WindUI:CreateWindow({
    Title = "Erhub [v0.0.22]",
    Icon = "droplet",
    Author = "",
    Folder = "AutoCollect_Config",
    Size = UDim2.fromOffset(450, 250),
    MinSize = Vector2.new(450, 250),
    MaxSize = Vector2.new(850, 560),
    SideBarWidth = 140,
    CornerRadius = UDim2.new(0,2),
    Transparent = true, 
    Acrylic = true,
    Theme = "DeepNavy",
})

Window:EditOpenButton({
    Title = sBtn("Open"),
    Icon = "droplet",
    CornerRadius = UDim.new(0,2),
    StrokeThickness = 0,
    OnlyMobile = false,
    Enabled = true,
    Draggable = true,
})

-- Tab Utama
local MainTab = Window:Tab({
    Title = sTitle("Automatic"),
    Icon = "coins",
})

-- Auto Collect Section
local MainSection = MainTab:Section({
    Title = sTitle("Auto collect"),
    TextSize = 11,
})

MainSection:Input({
    Title = sTitle("Delay"),
    Desc = sDesc("(Example: 3)"),
    TextSize = 8,
    Callback = function(text)
        local num = tonumber(text)
        if num and num > 0 then
            WaitTime = num
        end
    end
})

MainSection:Toggle({
    Title = sTitle("Auto Collect"),
    Value = false,
    TextSize = 9,
    Callback = function(state)
        AutoCollect = state
        if AutoCollect then
            task.spawn(function()
                while AutoCollect do
                    pcall(function()
                        if not _G.MyPlotID then findPlayerBase() end
                        for i = 1, 30 do
                            pcall(function()
                                PlotActionPath:InvokeServer("Collect Money", _G.MyPlotID, tostring(i))
                            end)
                        end
                    end)
                    task.wait(WaitTime)
                end
            end)
        end
    end
})

-- Auto Rebirth Section
local RebirthSection = MainTab:Section({
    Title = sTitle("Auto Rebirth"),
    TextSize = 11,
})

local AutoRebirth = false
RebirthSection:Toggle({
    Title = sTitle("Auto Rebirth"),
    Value = false,
    TextSize = 9,
    Callback = function(state)
        AutoRebirth = state
        if AutoRebirth then
            task.spawn(function()
                while AutoRebirth do
                    pcall(function()
                        game:GetService("ReplicatedStorage").RemoteFunctions.Rebirth:InvokeServer()
                    end)
                    task.wait(2)
                end
            end)
        end
    end
})

-- Auto Upgrade Speed Section
local UpgradeSection = MainTab:Section({
    Title = sTitle("Auto Upgrade Speed"),
    TextSize = 11,
})

local function SpeedLoop(amount, stateVar)
    task.spawn(function()
        while _G[stateVar] do
            pcall(function()
                game:GetService("ReplicatedStorage").RemoteFunctions.UpgradeSpeed:InvokeServer(amount)
            end)
            task.wait(1)
        end
    end)
end

UpgradeSection:Toggle({
    Title = sTitle("Upgrade +1"),
    Value = false,
    TextSize = 9,
    Callback = function(state)
        _G.Upgrade1 = state
        if state then SpeedLoop(1, "Upgrade1") end
    end
})

UpgradeSection:Toggle({
    Title = sTitle("Upgrade +5"),
    Value = false,
    TextSize = 9,
    Callback = function(state)
        _G.Upgrade5 = state
        if state then SpeedLoop(5, "Upgrade5") end
    end
})

UpgradeSection:Toggle({
    Title = sTitle("Upgrade +10"),
    Value = false,
    TextSize = 9,
    Callback = function(state)
        _G.Upgrade10 = state
        if state then SpeedLoop(10, "Upgrade10") end
    end
})

-- Brainrot system
local BrainrotTab = Window:Tab({
    Title = sTitle("Brainrot"),
    Icon = "brain",
})

local BrainrotSection = BrainrotTab:Section({
    Title = sTitle("Auto Upgrade Brainrot"),
    TextSize = 11,
})

local SelectedBrainrot = nil
local AutoUpgradeBrainrot = false
local MappedSlots = {}

local BrainrotDropdown = BrainrotSection:Dropdown({
    Title = sTitle("Select Brainrot"),
    Multi = false,
    AllowNone = true,
    Callback = function(val)
        SelectedBrainrot = val
    end
})

BrainrotSection:Button({
    Title = sBtn("Refresh Slots"),
    Callback = function()
        local slots = getBrainrotSlots()
        MappedSlots = slots
        local names = {}
        for _, item in pairs(slots) do
            if not table.find(names, item.Name) then table.insert(names, item.Name) end
        end
        if BrainrotDropdown.Refresh then BrainrotDropdown:Refresh(names) end
    end
})

BrainrotSection:Toggle({
    Title = sTitle("Enable Auto Upgrade"),
    Value = false,
    TextSize = 9,
    Callback = function(state)
        AutoUpgradeBrainrot = state
        if AutoUpgradeBrainrot then
            task.spawn(function()
                while AutoUpgradeBrainrot do
                    if SelectedBrainrot then
                        local foundAny = false
                        for _, item in pairs(MappedSlots) do
                            if item.Name == SelectedBrainrot then
                                foundAny = true
                                pcall(function()
                                    if not _G.MyPlotID then findPlayerBase() end
                                    PlotActionPath:InvokeServer("Upgrade Brainrot", _G.MyPlotID, tostring(item.SlotID))
                                end)
                            end
                        end
                        if not foundAny then
                            local slots = getBrainrotSlots()
                            MappedSlots = slots
                            for _, item in pairs(slots) do
                                if item.Name == SelectedBrainrot then
                                    pcall(function()
                                        PlotActionPath:InvokeServer("Upgrade Brainrot", _G.MyPlotID, tostring(item.SlotID))
                                    end)
                                end
                            end
                        end
                    end
                    task.wait(1)
                end
            end)
        end
    end
})
