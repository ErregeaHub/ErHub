




local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/ErregeaHub/WindUI/main/dist/main.lua"))()

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
    Title = "Erhub [v1.1.2]", -- Updated Title to match image style
    Icon = "droplet", -- Updated Icon
    Author = "", -- Updated Author
    Folder = "AutoCollect_Config",
    -- Compact Mobile Size
    Size = UDim2.fromOffset(450, 250),
    MinSize = Vector2.new(450, 250),
    MaxSize = Vector2.new(850, 560),
    SideBarWidth = 140,
    CornerRadius = 4, -- Slightly rounded for Chloe look
    Transparent = true, 
    Acrylic = true, -- Enable Blur Effect
    Theme = "DeepNavy",
})

Window:EditOpenButton({
    Title = sBtn("Open"),
    Icon = "droplet",
    CornerRadius = 4,
    StrokeThickness = 0,
    OnlyMobile = false,
    Enabled = true,
    Draggable = true,
})

-- Membuat Tab Utama
local MainTab = Window:Tab({
    Title = sTitle("Automation"),
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
