local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- -------------------------------------------
-- ----- =======[ CUSTOM THEME ] =======
-- -------------------------------------------
local DeepNavy = {
    Name = "DeepNavy",
    
    Accent = Color3.fromHex("#3E5C76"),      -- Highlights (Steel Blue)
    Dialog = Color3.fromHex("#1d2d44"),      -- Secondary/Container
    Outline = Color3.fromHex("#1d2d44"),     -- Secondary (for borders)
    Text = Color3.fromHex("#F0EBD8"),        -- Text/Icons (Off-White)
    Placeholder = Color3.fromHex("#748CAB"), -- Interactive/Muted Blue
    Background = Color3.fromHex("#0d1321"),  -- Deep Navy
    Button = Color3.fromHex("#1d2d44"),      -- Secondary
    Icon = Color3.fromHex("#F0EBD8"),        -- Text/Icons
    Toggle = Color3.fromHex("#3E5C76"),      -- Highlights
    Slider = Color3.fromHex("#3E5C76"),      -- Highlights
    Checkbox = Color3.fromHex("#3E5C76"),    -- Highlights
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
    Title = "Erhub",
    Icon = "coins",
    Author = "",
    Folder = "AutoCollect_Config",
    -- Compact Mobile Size
    Size = UDim2.fromOffset(220, 250),
    MinSize = Vector2.new(220, 250),
    MaxSize = Vector2.new(450, 560),
    CornerRadius = UDim2.new(0,2),
    Transparent = true,
    Theme = "DeepNavy",
})

Window:EditOpenButton({
    Title = sBtn("ErHub"),
    Icon = "coins",
    CornerRadius = UDim.new(0,4),
    StrokeThickness = 0,
    OnlyMobile = false,
    Enabled = true,
    Draggable = true,
})

-- Membuat Tab Utama
local MainTab = Window:Tab({
    Title = sTitle("Auto"),
    Icon = "hand-coins",
})

-- Section
local MainSection = MainTab:Section({
    Title = sTitle("Settings"),
    TextSize = 11,
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

-- SCRIPT CUSTOM CORNER OVERRIDE (Forced 2px)
task.spawn(function()
    task.wait(0.5) -- Wait for UI to fully load
    if game.CoreGui:FindFirstChild("Erhub") then
        for _, v in pairs(game.CoreGui:FindFirstChild("Erhub"):GetDescendants()) do
            if v:IsA("UICorner") then
                v.CornerRadius = UDim.new(0, 2) 
            end
        end
    end
end)
