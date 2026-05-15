-- EstrogenWare V59 Persistence Override
-- Fixed: Slider Dragging + Unload Logic + Persistence Loop

local LogService = game:GetService("LogService")
local CoreGui = game:GetService("CoreGui")

getgenv().EW_RUNNING = true

local function RunSource()
    local src = [[
        local HttpService = game:GetService("HttpService")
        local UserInputService = game:GetService("UserInputService")
        local RunService = game:GetService("RunService")
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer
        local CoreGui = game:GetService("CoreGui")

        getgenv().Settings = getgenv().Settings or {
            SnapAim = false, ShowFOV = true, Blatant = false, ESP = false,
            FOV = 150, Smoothing = 15
        }

        local function SaveConfig(n)
            local p = n or "EW_Last_Config.json"
            pcall(function() writefile(p, HttpService:JSONEncode(getgenv().Settings)) end)
        end

        -- UI Build
        if CoreGui:FindFirstChild("EstrogenWare") then CoreGui.EstrogenWare:Destroy() end
        local Gui = Instance.new("ScreenGui", CoreGui); Gui.Name = "EstrogenWare"
        
        local Main = Instance.new("Frame", Gui)
        Main.Size = UDim2.new(0, 520, 0, 380)
        Main.Position = UDim2.new(1, -530, 0, 50) 
        Main.BackgroundColor3 = Color3.new(1,1,1); Main.BorderSizePixel = 0; Main.Active = true; Main.Draggable = true

        local function ApplyPride(obj)
            local g = Instance.new("UIGradient", obj)
            g.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(91, 206, 250)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(245, 169, 184))
            })
            g.Rotation = 45
        end
        ApplyPride(Main)

        local Side = Instance.new("Frame", Main); Side.Size = UDim2.new(0, 140, 1, 0); Side.BackgroundColor3 = Color3.new(1,1,1); Side.BorderSizePixel = 0; ApplyPride(Side)
        local Title = Instance.new("TextButton", Side); Title.Size = UDim2.new(1, 0, 0, 50); Title.BackgroundTransparency = 1; Title.Text = "EstrogenWare"; Title.Font = Enum.Font.RobotoMono; Title.TextColor3 = Color3.fromRGB(30,30,30); Title.TextSize = 18

        local TabContainer = Instance.new("Frame", Side); TabContainer.Position = UDim2.new(0, 5, 0, 60); TabContainer.Size = UDim2.new(1, -10, 1, -120); TabContainer.BackgroundTransparency = 1
        Instance.new("UIListLayout", TabContainer).Padding = UDim.new(0, 5)
        local ContentContainer = Instance.new("Frame", Main); ContentContainer.Position = UDim2.new(0, 150, 0, 10); ContentContainer.Size = UDim2.new(1, -160, 1, -20); ContentContainer.BackgroundTransparency = 1

        local Home = Instance.new("Frame", ContentContainer); Home.Size = UDim2.new(1, 0, 1, 0); Home.BackgroundTransparency = 1; Home.Visible = true; Home.Name = "Home"
        local function AddHomeText(t, y)
            local l = Instance.new("TextLabel", Home); l.Size = UDim2.new(1, 0, 0, 20); l.Position = UDim2.new(0, 0, 0, y)
            l.BackgroundTransparency = 1; l.Text = t; l.Font = Enum.Font.RobotoMono; l.TextColor3 = Color3.fromRGB(30,30,30); l.TextXAlignment = Enum.TextXAlignment.Left
        end
        AddHomeText("detected: n/a", 0); AddHomeText("last updated: 26-05-15 @ 3:00 PM", 25); AddHomeText("created by ivymroow", 50)

        local function NewTab(name)
            local btn = Instance.new("TextButton", TabContainer); btn.Size = UDim2.new(1, 0, 0, 30); btn.Text = name; btn.BackgroundColor3 = Color3.new(1,1,1); btn.TextColor3 = Color3.fromRGB(30,30,30); btn.Font = Enum.Font.RobotoMono; btn.BorderSizePixel = 0; ApplyPride(btn)
            local Page = Instance.new("Frame", ContentContainer); Page.Size = UDim2.new(1, 0, 1, 0); Page.Visible = false; Page.BackgroundTransparency = 1; Page.Name = name
            btn.MouseButton1Click:Connect(function() 
                for _, v in pairs(ContentContainer:GetChildren()) do if v:IsA("Frame") then v.Visible = false end end 
                Page.Visible = true 
            end)
            return Page
        end

        local function AddToggle(p, t, k)
            local b = Instance.new("TextButton", p); b.Size = UDim2.new(1, -5, 0, 35); b.BackgroundColor3 = Color3.new(1,1,1); b.Font = Enum.Font.RobotoMono; b.BorderSizePixel = 0; ApplyPride(b)
            local function r() b.Text = t..": "..(getgenv().Settings[k] and "ON" or "OFF") end
            b.MouseButton1Click:Connect(function() getgenv().Settings[k] = not getgenv().Settings[k]; r(); SaveConfig() end)
            r()
        end

        local function AddSlider(p, t, k, min, max)
            local f = Instance.new("Frame", p); f.Size = UDim2.new(1, -5, 0, 50); f.BackgroundTransparency = 1
            local l = Instance.new("TextLabel", f); l.Size = UDim2.new(1, 0, 0, 20); l.TextColor3 = Color3.fromRGB(30,30,30); l.BackgroundTransparency = 1; l.Font = Enum.Font.RobotoMono
            local b = Instance.new("Frame", f); b.Size = UDim2.new(1, 0, 0, 10); b.Position = UDim2.new(0,0,0,25); b.BackgroundColor3 = Color3.fromRGB(200,200,200); b.BorderSizePixel = 0
            local fill = Instance.new("Frame", b); fill.Size = UDim2.new(0,0,1,0); fill.BackgroundColor3 = Color3.fromRGB(91, 206, 250); fill.BorderSizePixel = 0
            
            local function update()
                local percent = math.clamp((getgenv().Settings[k] - min) / (max - min), 0, 1)
                fill.Size = UDim2.new(percent, 0, 1, 0)
                l.Text = t..": "..getgenv().Settings[k]
            end

            b.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    local dragging = true
                    local con; con = UserInputService.InputEnded:Connect(function(ended)
                        if ended.UserInputType == Enum.UserInputType.MouseButton1 then
                            dragging = false; SaveConfig(); con:Disconnect()
                        end
                    end)
                    spawn(function()
                        while dragging do
                            local mPos = UserInputService:GetMouseLocation().X
                            local relativeX = math.clamp(mPos - b.AbsolutePosition.X, 0, b.AbsoluteSize.X)
                            getgenv().Settings[k] = math.round(min + (max - min) * (relativeX / b.AbsoluteSize.X))
                            update()
                            task.wait()
                        end
                    end)
                end
            end)
            update()
            if not p:FindFirstChild("UIListLayout") then Instance.new("UIListLayout", p).Padding = UDim.new(0, 5) end
        end

        local Combat = NewTab("Combat"); AddToggle(Combat, "Aimlock", "SnapAim"); AddSlider(Combat, "Smoothing", "Smoothing", 1, 100)
        local Visuals = NewTab("Visuals"); AddToggle(Visuals, "ESP", "ESP"); AddSlider(Visuals, "FOV", "FOV", 10, 800)
        local Configs = NewTab("Configs")

        local UnloadBtn = Instance.new("TextButton", Side); UnloadBtn.Size = UDim2.new(1, -10, 0, 45); UnloadBtn.Position = UDim2.new(0, 5, 1, -50); UnloadBtn.BackgroundColor3 = Color3.new(1,1,1); UnloadBtn.Text = "UNLOAD"; UnloadBtn.Font = Enum.Font.RobotoMono; UnloadBtn.BorderSizePixel = 0; ApplyPride(UnloadBtn)

        UnloadBtn.MouseButton1Click:Connect(function()
            getgenv().EW_RUNNING = false
            task.wait(0.2)
            if game:GetService("LogService"):FindFirstChild("EW_Watchdog_Active") then
                game:GetService("LogService").EW_Watchdog_Active:Destroy()
            end
            Gui:Destroy()
        end)

        UserInputService.InputBegan:Connect(function(i) if i.KeyCode == Enum.KeyCode.RightShift then Main.Visible = not Main.Visible end end)
    ]]
    loadstring(src)()
end

-- Persistence Watchdog Logic
if not LogService:FindFirstChild("EW_Watchdog_Active") then
    local WTag = Instance.new("BoolValue", LogService); WTag.Name = "EW_Watchdog_Active"
    task.spawn(function()
        while task.wait(3) do
            if not getgenv().EW_RUNNING then break end
            if not CoreGui:FindFirstChild("EstrogenWare") then
                RunSource()
            end
        end
    end)
end

RunSource()
