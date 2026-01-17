local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- -------------------------------------------
-- ----- =======[ CUSTOM THEME ] =======
-- -------------------------------------------
local DeepNavy = {
    Name = "DeepNavy",
    
    Accent = Color3.fromHex("#00bfff"),      -- Updated to Bright Cyan/Blue for "Chloe X" look (Vibrant)
    Dialog = Color3.fromHex("#1d2d44"),      -- Secondary
    Outline = Color3.fromHex("#1d2d44"),     -- Borders
    Text = Color3.fromHex("#F0EBD8"),        -- Text
    Placeholder = Color3.fromHex("#748CAB"), -- Placeholder
    Background = Color3.fromHex("#0d1321"),  -- Background
    Button = Color3.fromHex("#1d2d44"),      -- Button
    Icon = Color3.fromHex("#F0EBD8"),        -- Icon
    Toggle = Color3.fromHex("#00bfff"),      -- Toggle Accent
    Slider = Color3.fromHex("#00bfff"),      -- Slider Accent
    Checkbox = Color3.fromHex("#00bfff"),    -- Checkbox Accent
    
    -- Transparency Overrides (if supported by library logic, otherwise handled via Acrylic)
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
local WaitTime = 5 -- Default 5 detik

-- -------------------------------------------
-- ----- =======[ MAPPING SYSTEM ] =======
-- -------------------------------------------
local function findPlayerBase()
    print("Searching for base with Holder:", game.Players.LocalPlayer.UserId)
    if not workspace:FindFirstChild("Bases") then 
        warn("Bases folder not found in Workspace")
        return nil 
    end
    for _, base in pairs(workspace.Bases:GetChildren()) do
        local holder = base:GetAttribute("Holder")
        if tostring(holder) == tostring(game.Players.LocalPlayer.UserId) then
            print("Base found:", base.Name)
            return base
        end
    end
    warn("No base found for Holder:", game.Players.LocalPlayer.UserId)
    return nil
end

local function getBrainrotSlots()
    local base = findPlayerBase()
    local foundItems = {}
    local ExcludeNames = {"Base", "Rim", "Upgrade", "Collect", "Part", "TouchInterest", "SelectionBox", "Highlight", "UI"}
    
    if base and base:FindFirstChild("Slots") then
        print("Scanning slots in:", base.Name)
        for _, slot in pairs(base.Slots:GetChildren()) do
            for _, child in pairs(slot:GetChildren()) do
                -- Only include objects NOT in the exclusion list
                local isGeneric = false
                for _, exName in pairs(ExcludeNames) do
                    if child.Name:find(exName) then
                        isGeneric = true
                        break
                    end
                end

                if not isGeneric and (child:IsA("Model") or child:IsA("Folder") or child:IsA("BasePart")) then
                    print("Found Brainrot:", child.Name, "in", slot.Name)
                    table.insert(foundItems, {Name = child.Name, SlotID = slot.Name})
                end
            end
        end
    else
        warn("Base or Slots folder not found for mapping")
    end
    
    print("Total valid Brainrots found:", #foundItems)
    return foundItems
end


-- -------------------------------------------
-- ----- =======[ MOBILE SCALING ] =======
-- -------------------------------------------


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

local function sTitle(text)
    return string.format('<font size="13">%s</font>', text)
end

local function sDesc(text)
    return string.format('<font size="9">%s</font>', text)
end

local function sBtn(text)
    return string.format('<font size="11">%s</font>', text)
end

-- Inisialisasi Window
local Window = WindUI:CreateWindow({
    Title = "Erhub [v0.0.23]", -- Updated Title to match image style
    Icon = "droplet", -- Updated Icon
    Author = "", -- Updated Author
    Folder = "AutoCollect_Config",
    -- Compact Mobile Size
    Size = UDim2.fromOffset(450, 250),
    MinSize = Vector2.new(450, 250),
    MaxSize = Vector2.new(850, 560),
    SideBarWidth = 140,
    CornerRadius = UDim2.new(0,2), -- Sharp corners 2px
    Transparent = true, 
    Acrylic = true, -- Enable Blur Effect
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

-- Membuat Tab Utama
local MainTab = Window:Tab({
    Title = sTitle("Automatic"),
    Icon = "coins",
})

-- Section
local MainSection = MainTab:Section({
    Title = sTitle("Auto collect"),
    TextSize = 11,
    Opened = true,
})

-- Input untuk mengatur waktu (Detik)
MainSection:Input({
    Title = sTitle("Delay"),
    Desc = sDesc("(Example: 3)"),
    TextSize = 8,
    Callback = function(text)
        local num = tonumber(text)
        if num and num > 0 then
            WaitTime = num
            print("Jeda waktu diubah ke: " .. num .. " detik")
        else
            print("Masukkan angka yang valid!")
        end
    end
})

-- Toggle untuk menyalakan/mematikan Auto Collect
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
                        for i = 1, 20 do
                            local args = {
                                "Slot" .. i
                            }
                            -- Using WaitForChild only once if possible is better, but inside pcall is safe for now
                            game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents"):WaitForChild("CollectMoney"):FireServer(unpack(args))
                        end
                    end)
                    task.wait(WaitTime)
                end
            end)
        end
    end
})

-- -------------------------------------------
-- ----- =======[ AUTO REBIRTH ] =======
-- -------------------------------------------
local RebirthSection = MainTab:Section({
    Title = sTitle("Auto Rebirth"),
    TextSize = 11,
    Opened = true,
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
                    task.wait(5) -- Delay 5 seconds for Rebirth
                end
            end)
        end
    end
})

-- -------------------------------------------
-- ----- =======[ AUTO UPGRADE SPEED ] =======
-- -------------------------------------------
local UpgradeSection = MainTab:Section({
    Title = sTitle("Auto Upgrade Speed"),
    TextSize = 11,
    Opened = true,
})

local Upgrade1 = false
UpgradeSection:Toggle({
    Title = sTitle("Upgrade +1"),
    Value = false,
    TextSize = 9,
    Callback = function(state)
        Upgrade1 = state
        if Upgrade1 then
            task.spawn(function()
                while Upgrade1 do
                    pcall(function()
                         game:GetService("ReplicatedStorage").RemoteFunctions.UpgradeSpeed:InvokeServer(1)
                    end)
                    task.wait(1) -- Delay 1 second for Upgrade
                end
            end)
        end
    end
})

local Upgrade5 = false
UpgradeSection:Toggle({
    Title = sTitle("Upgrade +5"),
    Value = false,
    TextSize = 9,
    Callback = function(state)
        Upgrade5 = state
        if Upgrade5 then
            task.spawn(function()
                while Upgrade5 do
                    pcall(function()
                         game:GetService("ReplicatedStorage").RemoteFunctions.UpgradeSpeed:InvokeServer(5)
                    end)
                    task.wait(1) -- Delay 1 second for Upgrade
                end
            end)
        end
    end
})

local Upgrade10 = false
UpgradeSection:Toggle({
    Title = sTitle("Upgrade +10"),
    Value = false,
    TextSize = 9,
    Callback = function(state)
        Upgrade10 = state
        if Upgrade10 then
            task.spawn(function()
                while Upgrade10 do
                    pcall(function()
                         game:GetService("ReplicatedStorage").RemoteFunctions.UpgradeSpeed:InvokeServer(10)
                    end)
                    task.wait(1) -- Delay 1 second for Upgrade
                end
            end)
        end
    end
})



-- -------------------------------------------
-- ----- =======[ BRAINROT SYSTEM ] =======
-- -------------------------------------------
local BrainrotTab = Window:Tab({
    Title = sTitle("Brainrot"),
    Icon = "brain",
})

local BrainrotSection = BrainrotTab:Section({
    Title = sTitle("Auto Upgrade Brainrot"),
    TextSize = 11,
    Opened = true,
})

local SelectedBrainrot = nil
local AutoUpgradeBrainrot = false
local MappedSlots = {} -- Local cache for slots

local BrainrotDropdown = BrainrotSection:Dropdown({
    Title = sTitle("Select Brainrot"),
    Multi = false,
    AllowNone = true,
    Value = nil,
    Values = {},
    Callback = function(val)
        SelectedBrainrot = val
    end
})

BrainrotSection:Button({
    Title = sBtn("Refresh Slots"),
    Callback = function()
        print("Refresh button clicked")
        local slots = getBrainrotSlots()
        MappedSlots = slots -- Update cache
        
        local names = {}
        for _, item in pairs(slots) do
            if not table.find(names, item.Name) then
                table.insert(names, item.Name)
            end
        end
        print("Updating dropdown with", #names, "items")
        if BrainrotDropdown.Refresh then
            BrainrotDropdown:Refresh(names)
        else
            warn("WindUI Dropdown update method not found (tried Refresh)")
        end
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
                print("Auto Upgrade Loop Started")
                while AutoUpgradeBrainrot do
                    if SelectedBrainrot then
                        local foundAny = false
                        for _, item in pairs(MappedSlots) do
                            if item.Name == SelectedBrainrot then
                                foundAny = true
                                pcall(function()
                                    game:GetService("ReplicatedStorage").RemoteFunctions.UpgradeBrainrot:InvokeServer(item.SlotID)
                                end)
                            end
                        end
                        
                        if not foundAny then
                            -- Fallback: One rescan if cache is empty or invalid
                            local slots = getBrainrotSlots()
                            MappedSlots = slots
                            for _, item in pairs(slots) do
                                if item.Name == SelectedBrainrot then
                                    pcall(function()
                                        game:GetService("ReplicatedStorage").RemoteFunctions.UpgradeBrainrot:InvokeServer(item.SlotID)
                                    end)
                                end
                            end
                        end
                    end
                    task.wait(1)
                end
                print("Auto Upgrade Loop Stopped")
            end)
        end
    end
})


