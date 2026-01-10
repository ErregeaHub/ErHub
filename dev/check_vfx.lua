local vfx = game:GetService("ReplicatedStorage"):FindFirstChild("Modules") and game:GetService("ReplicatedStorage").Modules:FindFirstChild("VFX")
if vfx then
    print("VFX found: " .. vfx.ClassName)
else
    print("VFX not found")
end
