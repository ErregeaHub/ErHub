-- [[ Mini Ping Panel for ErHub V2 ]] --
    local Stats = game:GetService("Stats")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local CoreGui = game:GetService("CoreGui")
    
    local PingGui = Instance.new("ScreenGui")
    PingGui.Name = "ErHub_PingPanel"
    PingGui.ResetOnSpawn = false
    PingGui.Parent = CoreGui
    
    local PingFrame = Instance.new("Frame")
    PingFrame.Name = "MainFrame"
    PingFrame.Parent = PingGui
    PingFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    PingFrame.BackgroundTransparency = 0.4
    PingFrame.Position = UDim2.new(0.02, 0, 0.05, 0)
    PingFrame.Size = UDim2.new(0, 160, 0, 60)
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = PingFrame
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Thickness = 1
    Stroke.Color = Color3.fromRGB(0, 225, 255)
    Stroke.Parent = PingFrame
    
    local Header = Instance.new("TextLabel")
    Header.Name = "Header"
    Header.Parent = PingFrame
    Header.BackgroundTransparency = 1
    Header.Position = UDim2.new(0, 6, 0, 4)
    Header.Size = UDim2.new(1, -12, 0, 16)
    Header.Font = Enum.Font.Code
    Header.RichText = true
    Header.Text = "<b>ERHUB PANEL</b>"
    Header.TextSize = 12
    Header.TextColor3 = Color3.fromRGB(255, 255, 255)
    Header.TextXAlignment = Enum.TextXAlignment.Left
    
    local Separator = Instance.new("Frame")
    Separator.Name = "Separator"
    Separator.Parent = PingFrame
    Separator.BackgroundColor3 = Color3.fromRGB(0, 225, 255)
    Separator.BackgroundTransparency = 0
    Separator.Position = UDim2.new(0, 6, 0, 24)
    Separator.Size = UDim2.new(1, -12, 0, 1)
    
    local PingLabel = Instance.new("TextLabel")
    PingLabel.Name = "PingLabel"
    PingLabel.Parent = PingFrame
    PingLabel.BackgroundTransparency = 1
    PingLabel.Position = UDim2.new(0, 6, 0, 28)
    PingLabel.Size = UDim2.new(1, -12, 0, 24)
    PingLabel.Font = Enum.Font.Code
    PingLabel.Text = "Ping: 0 ms"
    PingLabel.TextSize = 12
    PingLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    PingLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local dragging = false
    local dragInput
    local dragStart
    local startPos
    
    local function update(input)
        local delta = input.Position - dragStart
        PingFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    
    PingFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = PingFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    PingFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
    
    RunService.RenderStepped:Connect(function()
        local ok, value = pcall(function()
            return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
        end)
        if ok then
            local ping = math.floor(value)
            PingLabel.Text = "Ping: " .. ping .. " ms"
            if ping < 80 then
                PingLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
            elseif ping <= 120 then
                PingLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
            else
                PingLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
            end
        end
    end)
