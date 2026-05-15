-- EstrogenWare V56 Persistence Override
-- Solara Compatibility Fix (Maintains Original UI & Logic)

local LogService = game:GetService("LogService")
local CoreGui = game:GetService("CoreGui")

getgenv().EW_RUNNING = true

local function RunSource()
    -- Solara environment check: Ensure mousemoverel is globally accessible
    local mousemoverel = mousemoverel or (Input and Input.MouseMove) 

    local src = [[
        local HttpService = game:GetService("HttpService")
        local UserInputService = game:GetService("UserInputService")
        local RunService = game:GetService("RunService")
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer
        local CoreGui = game:GetService("CoreGui")

        -- Config Logic
        getgenv().Settings = getgenv().Settings or {
            SnapAim = false, ShowFOV = true, Blatant = false, ESP = false,
            FOV = 150, Smoothing = 15
        }

        local function SaveConfig(n)
            local p = n or "EW_Last_Config.json"
            pcall(function() writefile(p, HttpService:JSONEncode(getgenv().Settings)) end)
        end

        -- UI Build (Kept EXACTLY as your V56)
        if CoreGui:FindFirstChild("EstrogenWare") then CoreGui.EstrogenWare:Destroy() end
        local Gui = Instance.new("ScreenGui", CoreGui); Gui.Name = "EstrogenWare"
        
        local Main = Instance.new("Frame", Gui)
        Main.Size = UDim2.new(0, 520, 0, 380)
        Main.Position = UDim2.new(1, -530, 0, 50) 
        Main.BackgroundColor3 = Color3.new(1,1,1); Main.BorderSizePixel = 0; Main.Active = true; Main.Draggable = true
        Main.Visible = false 

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
        AddHomeText("detected: n/a", 0)
        AddHomeText("last updated: 26-05-13 @ 1:15 PM EST.", 25)
        AddHomeText("created by ivymroow", 50)

        local function NewTab(name)
            local btn = Instance.new("TextButton", TabContainer); btn.Size = UDim2.new(1, 0, 0, 30); btn.Text = name; btn.BackgroundColor3 = Color3.new(1,1,1); btn.TextColor3 = Color3.fromRGB(30,30,30); btn.Font = Enum.Font.RobotoMono; btn.BorderSizePixel = 0; ApplyPride(btn)
            local Page = Instance.new("Frame", ContentContainer); Page.Size = UDim2.new(1, 0, 1, 0); Page.Visible = false; Page.BackgroundTransparency = 1; Page.Name = name
            
            btn.MouseButton1Click:Connect(function() 
                for _, v in pairs(ContentContainer:GetChildren()) do 
                    if v:IsA("Frame") then v.Visible = false end 
                end 
                Page.Visible = true 
            end)
            return Page
        end

        local function AddToggle(p, t, k)
            local b = Instance.new("TextButton", p); b.Size = UDim2.new(1, -5, 0, 35); b.BackgroundColor3 = Color3.new(1,1,1); b.Font = Enum.Font.RobotoMono; b.BorderSizePixel = 0; ApplyPride(b)
            local function r() b.Text = t..": "..(getgenv().Settings[k] and "ON" or "OFF") end
            b.MouseButton1Click:Connect(function() getgenv().Settings[k] = not getgenv().Settings[k]; r(); SaveConfig() end)
            local c; c = RunService.RenderStepped:Connect(function() if not getgenv().EW_RUNNING then c:Disconnect() return end r() end)
            if not p:FindFirstChild("UIListLayout") then Instance.new("UIListLayout", p).Padding = UDim.new(0, 5) end
        end

        local function AddSlider(p, t, k, min, max)
            local f = Instance.new("Frame", p); f.Size = UDim2.new(1, -5, 0, 50); f.BackgroundTransparency = 1
            local l = Instance.new("TextLabel", f); l.Size = UDim2.new(1, 0, 0, 20); l.TextColor3 = Color3.fromRGB(30,30,30); l.BackgroundTransparency = 1; l.Font = Enum.Font.RobotoMono
            local b = Instance.new("Frame", f); b.Size = UDim2.new(1, 0, 0, 10); b.Position = UDim2.new(0,0,0,25); b.BackgroundColor3 = Color3.new(0,0,0); b.BorderSizePixel = 0
            local fill = Instance.new("Frame", b); fill.BackgroundColor3 = Color3.fromRGB(91, 206, 250); fill.BorderSizePixel = 0
            
            local c; c = RunService.RenderStepped:Connect(function()
                if not getgenv().EW_RUNNING then c:Disconnect() return end
                l.Text = t..": "..getgenv().Settings[k]
                fill.Size = UDim2.new((getgenv().Settings[k]-min)/(max-min), 0, 1, 0)
            end)

            b.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then local c; c = RunService.RenderStepped:Connect(function() if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or not getgenv().EW_RUNNING then c:Disconnect(); SaveConfig(); return end local m = math.clamp((UserInputService:GetMouseLocation().X - b.AbsolutePosition.X) / b.AbsoluteSize.X, 0, 1) getgenv().Settings[k] = math.round(min + (max-min)*m) end) end end)
            if not p:FindFirstChild("UIListLayout") then Instance.new("UIListLayout", p).Padding = UDim.new(0, 5) end
        end

        local Combat = NewTab("Combat"); AddToggle(Combat, "Aimlock", "SnapAim"); AddToggle(Combat, "Blatant", "Blatant"); AddSlider(Combat, "Smoothing", "Smoothing", 1, 100)
        local Visuals = NewTab("Visuals"); AddToggle(Visuals, "Highlight ESP", "ESP"); AddToggle(Visuals, "Show FOV", "ShowFOV"); AddSlider(Visuals, "FOV Size", "FOV", 10, 800)
        
        local Configs = NewTab("Configs")
        local ConfigScroll = Instance.new("ScrollingFrame", Configs); ConfigScroll.Size = UDim2.new(1, -5, 1, -90); ConfigScroll.BackgroundTransparency = 1; ConfigScroll.ScrollBarThickness = 2; ConfigScroll.BorderSizePixel = 0
        Instance.new("UIListLayout", ConfigScroll).Padding = UDim.new(0, 5)

        local CreateContainer = Instance.new("Frame", Configs); CreateContainer.Size = UDim2.new(1, -5, 0, 80); CreateContainer.Position = UDim2.new(0, 0, 1, -80); CreateContainer.BackgroundTransparency = 1; CreateContainer.BorderSizePixel = 0
        local ConfigName = Instance.new("TextBox", CreateContainer); ConfigName.Size = UDim2.new(1, 0, 0, 35); ConfigName.BackgroundColor3 = Color3.new(1,1,1); ConfigName.PlaceholderText = "Config Name..."; ConfigName.Text = ""; ConfigName.Font = Enum.Font.RobotoMono; ConfigName.TextColor3 = Color3.new(0,0,0); ConfigName.BorderSizePixel = 0; ApplyPride(ConfigName)
        local SaveBtn = Instance.new("TextButton", CreateContainer); SaveBtn.Size = UDim2.new(1, 0, 0, 35); SaveBtn.Position = UDim2.new(0, 0, 0, 40); SaveBtn.BackgroundColor3 = Color3.new(1,1,1); SaveBtn.Text = "CREATE CONFIG"; SaveBtn.Font = Enum.Font.RobotoMono; SaveBtn.BorderSizePixel = 0; ApplyPride(SaveBtn)
        
        local function RefreshConfigs()
            for _, v in pairs(ConfigScroll:GetChildren()) do if v:IsA("Frame") then v:Destroy() end end
            if listfiles then
                for _, file in pairs(listfiles("")) do
                    if file:sub(-5) == ".json" and file ~= "EW_Last_Config.json" then
                        local row = Instance.new("Frame", ConfigScroll); row.Size = UDim2.new(1, 0, 0, 30); row.BackgroundTransparency = 1; row.BorderSizePixel = 0
                        local load = Instance.new("TextButton", row); load.Size = UDim2.new(0.8, -5, 1, 0); load.Text = file; load.Font = Enum.Font.RobotoMono; load.BackgroundColor3 = Color3.new(1,1,1); load.BorderSizePixel = 0; ApplyPride(load)
                        local del = Instance.new("TextButton", row); del.Size = UDim2.new(0.2, 0, 1, 0); del.Position = UDim2.new(0.8, 0, 0, 0); del.Text = "X"; del.TextColor3 = Color3.new(1,1,1); del.BackgroundColor3 = Color3.fromRGB(245, 169, 184); del.BorderSizePixel = 0
                        load.MouseButton1Click:Connect(function() local d = HttpService:JSONDecode(readfile(file)) for i, v in pairs(d) do getgenv().Settings[i] = v end end)
                        del.MouseButton1Click:Connect(function() delfile(file) RefreshConfigs() end)
                    end
                end
            end
        end

        SaveBtn.MouseButton1Click:Connect(function() if ConfigName.Text ~= "" then SaveConfig(ConfigName.Text..".json") ConfigName.Text = "" RefreshConfigs() end end)
        RefreshConfigs()

        local UnloadBtn = Instance.new("TextButton", Side); UnloadBtn.Size = UDim2.new(1, -10, 0, 45); UnloadBtn.Position = UDim2.new(0, 5, 1, -50); UnloadBtn.BackgroundColor3 = Color3.new(1,1,1); UnloadBtn.Text = "UNLOAD"; UnloadBtn.Font = Enum.Font.RobotoMono; UnloadBtn.TextColor3 = Color3.fromRGB(30,30,30); UnloadBtn.BorderSizePixel = 0; ApplyPride(UnloadBtn)

        -- Mechanics
        local FOVDraw = Drawing.new("Circle")
        
        UnloadBtn.MouseButton1Click:Connect(function()
            getgenv().EW_RUNNING = false 
            task.wait(0.1)
            FOVDraw:Remove()
            for _, p in pairs(Players:GetPlayers()) do if p.Character and p.Character:FindFirstChild("EW_ESP") then p.Character.EW_ESP:Destroy() end end
            Gui:Destroy()
            if LogService:FindFirstChild("EW_Watchdog_Active") then LogService.EW_Watchdog_Active:Destroy() end
        end)

        local MainLoop; MainLoop = RunService.RenderStepped:Connect(function()
            if not getgenv().EW_RUNNING then MainLoop:Disconnect() return end
            local Camera = workspace.CurrentCamera
            if not Camera then return end

            FOVDraw.Thickness = 2; FOVDraw.Color = Color3.fromRGB(245, 169, 184); FOVDraw.Radius = getgenv().Settings.FOV; FOVDraw.Position = UserInputService:GetMouseLocation(); FOVDraw.Visible = getgenv().Settings.ShowFOV
            
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local h = p.Character:FindFirstChild("EW_ESP")
                    if getgenv().Settings.ESP then
                        if not h then h = Instance.new("Highlight", p.Character); h.Name = "EW_ESP"; h.FillColor = Color3.fromRGB(245, 169, 184); h.OutlineColor = Color3.new(1,1,1) end
                    elseif h then h:Destroy() end
                end
            end

            if getgenv().Settings.SnapAim and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
                local target, d = nil, getgenv().Settings.FOV
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                        local pos, vis = Camera:WorldToViewportPoint(p.Character.Head.Position)
                        if vis then
                            local mag = (Vector2.new(pos.X, pos.Y) - UserInputService:GetMouseLocation()).Magnitude
                            if mag < d then d = mag; target = p.Character.Head end
                        end
                    end
                end
                -- SOLARA FIX: Ensure mousemoverel is accessed correctly in this environment
                if target and (getgenv().mousemoverel or mousemoverel) then
                    local moveFunc = getgenv().mousemoverel or mousemoverel
                    local tPos = Camera:WorldToViewportPoint(target.Position)
                    local mPos = UserInputService:GetMouseLocation()
                    local s = getgenv().Settings.Blatant and 1 or (getgenv().Settings.Smoothing / 100)
                    moveFunc((tPos.X - mPos.X) * s, (tPos.Y - mPos.Y) * s)
                end
            end
        end)

        UserInputService.InputBegan:Connect(function(i) if i.KeyCode == Enum.KeyCode.RightShift then Main.Visible = not Main.Visible end end)
    ]]
    loadstring(src)()
end

-- Fixed Watchdog for Solara
if not LogService:FindFirstChild("EW_Watchdog_Active") then
    local WTag = Instance.new("BoolValue", LogService); WTag.Name = "EW_Watchdog_Active"
    task.spawn(function()
        while getgenv().EW_RUNNING do
            -- Solara can lose CoreGui references on re-execution; this keeps it alive
            if not CoreGui:FindFirstChild("EstrogenWare") and getgenv().EW_RUNNING then
                pcall(RunSource)
            end
            task.wait(3)
        end
    end)
end

RunSource()
