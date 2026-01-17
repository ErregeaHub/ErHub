local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

-- -------------------------------------------
-- ----- =======[ CUSTOM THEME ] =======
-- -------------------------------------------
local Theme = {
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
}

-- -------------------------------------------
-- ----- =======[ WINDUI REMAKE ] =======
-- -------------------------------------------
local WindUI = {}
local Library = {}

function WindUI:AddTheme(themeTable)
    -- Placeholder for compatibility
end

function WindUI:SetTheme(themeName)
    -- Placeholder for compatibility
end

function WindUI:CreateWindow(options)
    local window = {}
    
    -- Main GUI
    local gui = Instance.new("ScreenGui")
    gui.Name = "WindUI_Remake"
    -- Try to parent to CoreGui for exploits, or PlayerGui for studio
    pcall(function()
        gui.Parent = CoreGui
    end)
    if not gui.Parent then
        local player = Players.LocalPlayer
        if player then
            gui.Parent = player:WaitForChild("PlayerGui")
        end
    end
    
    -- Mobile Optimization: Scale 0.8
    local scale = Instance.new("UIScale")
    scale.Scale = 0.8
    scale.Parent = gui

    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = options.Size or UDim2.fromOffset(450, 250)
    mainFrame.BackgroundColor3 = Theme.Background
    mainFrame.BorderSizePixel = 0
    mainFrame.Position = UDim2.fromScale(0.5, 0.5)
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.Parent = gui
    
    -- Draggable
    local dragging, dragInput, dragStart, startPos
    local function update(input)
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    mainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    mainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)

    -- Corners (Adjusted to 4px)
    local uicorner = Instance.new("UICorner")
    uicorner.CornerRadius = UDim.new(0, 4)
    uicorner.Parent = mainFrame
    
    -- Sidebar
    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, options.SideBarWidth or 140, 1, 0)
    sidebar.BackgroundColor3 = Theme.Dialog
    sidebar.BorderSizePixel = 0
    sidebar.Parent = mainFrame
    
    local sidebarCorner = Instance.new("UICorner")
    sidebarCorner.CornerRadius = UDim.new(0, 4)
    sidebarCorner.Parent = sidebar
    
    -- Fix sidebar corner overlapping main frame
    local sidebarCover = Instance.new("Frame")
    sidebarCover.Name = "SidebarCover"
    sidebarCover.Size = UDim2.new(0, 10, 1, 0)
    sidebarCover.Position = UDim2.new(1, -5, 0, 0)
    sidebarCover.BackgroundColor3 = Theme.Dialog
    sidebarCover.BorderSizePixel = 0
    sidebarCover.ZIndex = 0
    sidebarCover.Parent = sidebar

    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Text = options.Title:gsub("<[^>]+>", "") -- Strip HTML
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 14
    titleLabel.TextColor3 = Theme.Text
    titleLabel.BackgroundTransparency = 1
    titleLabel.Size = UDim2.new(1, -20, 0, 40)
    titleLabel.Position = UDim2.new(0, 10, 0, 10)
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = sidebar

    -- Tab Container
    local tabContainer = Instance.new("ScrollingFrame")
    tabContainer.Size = UDim2.new(1, 0, 1, -60)
    tabContainer.Position = UDim2.new(0, 0, 0, 60)
    tabContainer.BackgroundTransparency = 1
    tabContainer.BorderSizePixel = 0
    tabContainer.ScrollBarThickness = 0
    tabContainer.Parent = sidebar
    
    local tabListLayout = Instance.new("UIListLayout")
    tabListLayout.Padding = UDim.new(0, 5)
    tabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    tabListLayout.Parent = tabContainer

    -- Content Area
    local contentArea = Instance.new("Frame")
    contentArea.Name = "Content"
    contentArea.Size = UDim2.new(1, -(options.SideBarWidth or 140), 1, 0)
    contentArea.Position = UDim2.new(0, options.SideBarWidth or 140, 0, 0)
    contentArea.BackgroundTransparency = 1
    contentArea.Parent = mainFrame
    
    local contentPadding = Instance.new("UIPadding")
    contentPadding.PaddingTop = UDim.new(0, 10)
    contentPadding.PaddingLeft = UDim.new(0, 10)
    contentPadding.PaddingRight = UDim.new(0, 10)
    contentPadding.PaddingBottom = UDim.new(0, 10)
    contentPadding.Parent = contentArea

    -- Window Methods
    function window:EditOpenButton(opts)
        -- Simplified Open Button Integration (Optional Implementation)
    end

    function window:Tab(opts)
        local tab = {}
        local tabId = opts.Title:gsub("<[^>]+>", "")
        
        -- Tab Button
        local tabBtn = Instance.new("TextButton")
        tabBtn.Text = "  " .. tabId
        tabBtn.Size = UDim2.new(0.9, 0, 0, 30) -- Compact height
        tabBtn.BackgroundColor3 = Theme.Background
        tabBtn.BackgroundTransparency = 1 
        tabBtn.TextColor3 = Theme.Text -- High Contrast
        tabBtn.Font = Enum.Font.GothamMedium
        tabBtn.TextSize = 12
        tabBtn.TextXAlignment = Enum.TextXAlignment.Left
        tabBtn.AutoButtonColor = false
        tabBtn.Parent = tabContainer
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 4)
        btnCorner.Parent = tabBtn

        -- Tab Content Frame
        local tabFrame = Instance.new("ScrollingFrame")
        tabFrame.Name = tabId
        tabFrame.Size = UDim2.new(1, 0, 1, 0)
        tabFrame.BackgroundTransparency = 1
        tabFrame.ScrollBarThickness = 2
        tabFrame.Visible = false -- Hidden by default
        tabFrame.Parent = contentArea
        
        local tabLayout = Instance.new("UIListLayout")
        tabLayout.Padding = UDim.new(0, 8)
        tabLayout.Parent = tabFrame

        -- Activate first tab
        if #tabContainer:GetChildren() == 2 then -- 1 is Layout, 2 is this button
             tabFrame.Visible = true
             tabBtn.BackgroundTransparency = 0
        end

        tabBtn.MouseButton1Click:Connect(function()
            for _, c in pairs(contentArea:GetChildren()) do
                if c:IsA("ScrollingFrame") then c.Visible = false end
            end
            for _, b in pairs(tabContainer:GetChildren()) do
                if b:IsA("TextButton") then b.BackgroundTransparency = 1 end
            end
            tabFrame.Visible = true
            tabBtn.BackgroundTransparency = 0
        end)

        function tab:Section(sectOpts)
            local section = {}
            local sectionTitle = sectOpts.Title:gsub("<[^>]+>", "")
            
            -- Section Frame
            local sectFrame = Instance.new("Frame")
            sectFrame.BackgroundColor3 = Theme.Dialog
            sectFrame.BackgroundTransparency = 0.5
            sectFrame.Size = UDim2.new(1, 0, 0, 0) -- Auto sized
            sectFrame.AutomaticSize = Enum.AutomaticSize.Y
            sectFrame.Parent = tabFrame
            
            local sectCorner = Instance.new("UICorner")
            sectCorner.CornerRadius = UDim.new(0, 4)
            sectCorner.Parent = sectFrame
            
            local sectPad = Instance.new("UIPadding")
            sectPad.PaddingLeft = UDim.new(0, 8)
            sectPad.PaddingRight = UDim.new(0, 8)
            sectPad.PaddingTop = UDim.new(0, 8)
            sectPad.PaddingBottom = UDim.new(0, 8)
            sectPad.Parent = sectFrame
            
            local sectLayout = Instance.new("UIListLayout")
            sectLayout.Padding = UDim.new(0, 6)
            sectLayout.SortOrder = Enum.SortOrder.LayoutOrder
            sectLayout.Parent = sectFrame
            
            -- Section Title
            local title = Instance.new("TextLabel")
            title.Text = sectionTitle
            title.Font = Enum.Font.GothamBold
            title.TextSize = 11
            title.TextColor3 = Theme.Accent
            title.BackgroundTransparency = 1
            title.Size = UDim2.new(1, 0, 0, 20)
            title.TextXAlignment = Enum.TextXAlignment.Left
            title.Parent = sectFrame

            function section:Input(inOpts)
                local container = Instance.new("Frame")
                container.Size = UDim2.new(1, 0, 0, 30) -- Compact
                container.BackgroundTransparency = 1
                container.Parent = sectFrame
                
                local lbl = Instance.new("TextLabel")
                lbl.Text = inOpts.Title:gsub("<[^>]+>", "")
                lbl.Font = Enum.Font.Gotham
                lbl.TextSize = 10
                lbl.TextColor3 = Theme.Text
                lbl.Size = UDim2.new(0.6, 0, 1, 0)
                lbl.BackgroundTransparency = 1
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                lbl.Parent = container

                local textBox = Instance.new("TextBox")
                textBox.Text = ""
                textBox.PlaceholderText = inOpts.Desc:gsub("<[^>]+>", ""):gsub("%(", ""):gsub("%)", "")
                textBox.PlaceholderColor3 = Theme.Placeholder
                textBox.TextColor3 = Theme.Text
                textBox.BackgroundColor3 = Theme.Background
                textBox.Font = Enum.Font.Gotham
                textBox.TextSize = 10
                textBox.Size = UDim2.new(0.4, 0, 1, 0)
                textBox.Position = UDim2.new(0.6, 0, 0, 0)
                textBox.Parent = container
                
                local boxCorner = Instance.new("UICorner")
                boxCorner.CornerRadius = UDim.new(0, 4)
                boxCorner.Parent = textBox

                textBox.FocusLost:Connect(function(enter)
                    if inOpts.Callback then inOpts.Callback(textBox.Text) end
                end)
            end

            function section:Toggle(togOpts)
                local container = Instance.new("TextButton")
                container.Size = UDim2.new(1, 0, 0, 30) -- Compact
                container.BackgroundTransparency = 1
                container.Text = ""
                container.Parent = sectFrame
                
                local lbl = Instance.new("TextLabel")
                lbl.Text = togOpts.Title:gsub("<[^>]+>", "")
                lbl.Font = Enum.Font.Gotham
                lbl.TextSize = 10
                lbl.TextColor3 = Theme.Text
                lbl.Size = UDim2.new(0.8, 0, 1, 0)
                lbl.BackgroundTransparency = 1
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                lbl.Parent = container
                
                local toggler = Instance.new("Frame")
                toggler.Size = UDim2.new(0, 30, 0, 16)
                toggler.Position = UDim2.new(1, -30, 0.5, -8)
                toggler.BackgroundColor3 = Theme.Background
                toggler.Parent = container
                
                local togCorner = Instance.new("UICorner")
                togCorner.CornerRadius = UDim.new(0, 8)
                togCorner.Parent = toggler
                
                local knob = Instance.new("Frame")
                knob.Size = UDim2.new(0, 12, 0, 12)
                knob.Position = UDim2.new(0, 2, 0.5, -6)
                knob.BackgroundColor3 = Theme.Text
                knob.Parent = toggler
                
                local knobCorner = Instance.new("UICorner")
                knobCorner.CornerRadius = UDim.new(1, 0)
                knobCorner.Parent = knob
                
                local state = togOpts.Value or false
                
                local function updateState()
                    if state then
                        TweenService:Create(toggler, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Accent}):Play()
                        TweenService:Create(knob, TweenInfo.new(0.2), {Position = UDim2.new(1, -14, 0.5, -6)}):Play()
                    else
                        TweenService:Create(toggler, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Background}):Play()
                        TweenService:Create(knob, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -6)}):Play()
                    end
                    if togOpts.Callback then togOpts.Callback(state) end
                end
                
                updateState() -- Init
                
                container.MouseButton1Click:Connect(function()
                    state = not state
                    updateState()
                end)
            end

            return section
        end

        return tab
    end

    return window
end

-- -------------------------------------------
-- ----- =======[ SCRIPT LOGIC ] =======
-- -------------------------------------------

-- Variabel Kontrol
local AutoCollect = false
local WaitTime = 5 -- Default 5 detik

-- Helper Functions (Kept for compatibility calls, though functional replacements are above)
local function sTitle(text) return text end
local function sDesc(text) return text end
local function sBtn(text) return text end

-- Inisialisasi Window
local Window = WindUI:CreateWindow({
    Title = "Erhub [v0.0.1]", 
    Size = UDim2.fromOffset(450, 250), -- Compact
    SideBarWidth = 140,
    Theme = "DeepNavy",
})

Window:EditOpenButton({
    Title = "Open",
    Icon = "droplet",
})

-- Membuat Tab Utama
local MainTab = Window:Tab({
    Title = "Automation",
    Icon = "coins",
})

-- Section
local MainSection = MainTab:Section({
    Title = "Auto collect",
})

-- Input untuk mengatur waktu (Detik)
MainSection:Input({
    Title = "Delay",
    Desc = "(Example: 3)",
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
    Title = "Auto Collect",
    Value = false,
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
                            local RE = game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents", 5)
                            if RE then
                                local collectEvent = RE:WaitForChild("CollectMoney", 5)
                                if collectEvent then
                                     collectEvent:FireServer(unpack(args))
                                end
                            end
                        end
                    end)
                    task.wait(WaitTime)
                end
            end)
        end
    end
})
