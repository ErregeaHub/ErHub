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
-- ----- =======[ MOBILE SCALING ] =======
-- -------------------------------------------

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
    Title = "Erhub [v1.1.1]", -- Updated Title to match image style
    Icon = "droplet", -- Updated Icon
    Author = "", -- Updated Author
    Folder = "AutoCollect_Config",
    -- Compact Mobile Size
    Size = UDim2.fromOffset(450, 250),
    MinSize = Vector2.new(450, 250),
    MaxSize = Vector2.new(850, 560),
    SideBarWidth = 140,
    CornerRadius = UDim2.new(0,4), -- Slightly rounded for Chloe look
    Transparent = true, 
    Acrylic = true, -- Enable Blur Effect
    Theme = "DeepNavy",
})

Window:EditOpenButton({
    Title = sBtn("Open"),
    Icon = "droplet",
    CornerRadius = UDim.new(0,4),
    StrokeThickness = 0,
    OnlyMobile = false,
    Enabled = true,
    Draggable = true,
})

-- Membuat Tab Utama
local MainTab = Window:Tab({
    Title = sTitle("Automation"),
    Icon = "fish",
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

-- SCRIPT CUSTOM CORNER OVERRIDE
task.spawn(function()
    task.wait(0.5) -- Wait for UI to fully load
    if game.CoreGui:FindFirstChild("Erhub [v1.1.1]") or game.CoreGui:FindFirstChild("WindUI") then
        local gui = game.CoreGui:FindFirstChild("Erhub [v1.1.1]") or game.CoreGui:FindFirstChild("WindUI")
        if gui then
             for _, v in pairs(gui:GetDescendants()) do
                if v:IsA("UICorner") then
                    v.CornerRadius = UDim.new(0, 4) -- Matched to main radius
                end
            end
        end
    end
end)local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

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
-- ----- =======[ MOBILE SCALING ] =======
-- -------------------------------------------

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
    Title = "Erhub [v1.1.1]", -- Updated Title to match image style
    Icon = "droplet", -- Updated Icon
    Author = "", -- Updated Author
    Folder = "AutoCollect_Config",
    -- Compact Mobile Size
    Size = UDim2.fromOffset(450, 250),
    MinSize = Vector2.new(450, 250),
    MaxSize = Vector2.new(850, 560),
    SideBarWidth = 140,
    CornerRadius = UDim2.new(0,4), -- Slightly rounded for Chloe look
    Transparent = true, 
    Acrylic = true, -- Enable Blur Effect
    Theme = "DeepNavy",
})

Window:EditOpenButton({
    Title = sBtn("Open"),
    Icon = "droplet",
    CornerRadius = UDim.new(0,4),
    StrokeThickness = 0,
    OnlyMobile = false,
    Enabled = true,
    Draggable = true,
})

-- Membuat Tab Utama
local MainTab = Window:Tab({
    Title = sTitle("Automation"),
    Icon = "fish",
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

-- SCRIPT CUSTOM CORNER OVERRIDE
task.spawn(function()
    task.wait(0.5) -- Wait for UI to fully load
    if game.CoreGui:FindFirstChild("Erhub [v1.1.1]") or game.CoreGui:FindFirstChild("WindUI") then
        local gui = game.CoreGui:FindFirstChild("Erhub [v1.1.1]") or game.CoreGui:FindFirstChild("WindUI")
        if gui then
             for _, v in pairs(gui:GetDescendants()) do
                if v:IsA("UICorner") then
                    v.CornerRadius = UDim.new(0, 4) -- Matched to main radius
                end
            end
        end
    end
end)
