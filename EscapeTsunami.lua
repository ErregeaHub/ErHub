local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

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
    Size = UDim2.fromOffset(220, 250),
    CornerRadius = UDim2.new(0,2),
    Transparent = true,
    Theme = "Dark",
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
    Placeholder = "Default: 5",
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
                            -- based on user request layout
                            game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents"):WaitForChild("CollectMoney"):FireServer(unpack(args))
                        end
                    end)
                    task.wait(WaitTime)
                end
            end)
        end
    end
})

