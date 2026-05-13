local EstrogenScript = [[
    local UserInputService = game:GetService("UserInputService")
    local CoreGui = game:GetService("CoreGui")
    local HttpService = game:GetService("HttpService")
    
    _G.Settings = _G.Settings or {
        SnapAim = false, ShowFOV = true, 
        Strength = 5, FOV = 150, Smoothing = 0.15,
        ConfigName = "Default"
    }

    local function CreateUI()
        -- Use a unique name to prevent Madium from auto-deleting it
        local UI_NAME = "EW_V15_CORE"
        if CoreGui:FindFirstChild(UI_NAME) then CoreGui[UI_NAME]:Destroy() end

        local Gui = Instance.new("ScreenGui", CoreGui)
        Gui.Name = UI_NAME
        Gui.ResetOnSpawn = false
        Gui.DisplayOrder = 999 -- Force it to stay on top

        local Main = Instance.new("Frame", Gui)
        Main.Size = UDim2.new(0, 520, 0, 380)
        Main.Position = UDim2.new(0.5, -260, 0.5, -190)
        Main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
        Main.Visible = true -- Starts open so you know it worked

        -- [Simplified Toggle Logic]
        UserInputService.InputBegan:Connect(function(input, gpe)
            if not gpe and input.KeyCode == Enum.KeyCode.LeftControl then
                Main.Visible = not Main.Visible
            end
        end)

        -- Title
        local Title = Instance.new("TextLabel", Main)
        Title.Size = UDim2.new(1, 0, 0, 40)
        Title.Text = "EstrogenWare v15 - LeftCtrl to Hide"
        Title.TextColor3 = Color3.new(1,1,1)
        Title.BackgroundColor3 = Color3.fromRGB(245, 169, 184)
        Title.Font = Enum.Font.Code
        
        -- Basic Toggle Button for Aim
        local btn = Instance.new("TextButton", Main)
        btn.Position = UDim2.new(0.5, -100, 0.5, -25)
        btn.Size = UDim2.new(0, 200, 0, 50)
        btn.Text = "Toggle Snap: OFF"
        btn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        btn.TextColor3 = Color3.new(1,1,1)
        
        btn.MouseButton1Click:Connect(function()
            _G.Settings.SnapAim = not _G.Settings.SnapAim
            btn.Text = "Toggle Snap: " .. (_G.Settings.SnapAim and "ON" or "OFF")
            btn.TextColor3 = _G.Settings.SnapAim and Color3.fromRGB(245, 169, 184) or Color3.new(1,1,1)
        end)
    end

    -- Run the UI Creation
    task.spawn(CreateUI)
    print("UI Created. If it's not visible, your executor is blocking CoreGui.")
]]

-- EXECUTION CHECK
if not _G.EstrogenV15Running then
    _G.EstrogenV15Running = true
    local success, err = pcall(function()
        loadstring(EstrogenScript)()
    end)
    if not success then warn("Execution Error: " .. err) end
else
    print("EstrogenWare v15 is already running. Press LeftControl.")
end
