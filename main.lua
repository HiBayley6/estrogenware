-- EstrogenWare V60 Persistence Override
-- FIXED: Combat/Visual Logic + Slider Draggable Conflict + Config List

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
        local Camera = workspace.CurrentCamera
        local CoreGui = game:GetService("CoreGui")

        -- Solara-specific mousemoverel check
        local moveFunc = mousemoverel or (Input and Input.MouseMove)

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
        Main.Size = UDim2.new(0, 520, 0, 380); Main.Position = UDim2.new(1, -530, 0, 50) 
        Main.BackgroundColor3 = Color3.new(1,1,1); Main.BorderSizePixel = 0; Main.Active = true; Main.Draggable = true

        local function ApplyPride(obj)
            local g = Instance.new("UIGradient", obj)
            g.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(91, 206, 250)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(245, 169, 184))
            }); g.Rotation = 45
        end
        ApplyPride(Main)

        local Side = Instance.new("Frame", Main); Side.Size = UDim2.new(0, 140, 1, 0); Side.BackgroundColor3 = Color3.new(1,1,1); Side.BorderSizePixel = 0; ApplyPride(Side)
        local TabContainer = Instance.new("Frame", Side); TabContainer.Position = UDim2.new(0, 5, 0, 60); TabContainer.Size = UDim2.new(1, -10, 1, -120); TabContainer.BackgroundTransparency = 1
        Instance.new("UIListLayout", TabContainer).Padding = UDim.new(0, 5)
        local ContentContainer = Instance.new("Frame", Main); ContentContainer.Position = UDim2.new(0, 150, 0, 10); ContentContainer.Size = UDim2.new(1, -160, 1, -20); ContentContainer.BackgroundTransparency = 1

        local function NewTab(name)
            local btn = Instance.new("TextButton", TabContainer); btn.Size = UDim2.new(1, 0, 0, 30); btn.Text = name; btn.BackgroundColor3 = Color3.new(1,1,1); btn.Font = Enum.Font.RobotoMono; btn.BorderSizePixel = 0; ApplyPride(btn)
            local Page = Instance.new("ScrollingFrame", ContentContainer); Page.Size = UDim2.new(1, 0, 1, 0); Page.Visible = false; Page.BackgroundTransparency = 1; Page.ScrollBarThickness = 0; Page.Name = name
            Instance.new("UIListLayout", Page).Padding = UDim.new(0, 5)
            btn.MouseButton1Click:Connect(function() 
                for _, v in pairs(ContentContainer:GetChildren()) do if v:IsA("ScrollingFrame") or v.Name == "Home" then v.Visible = false end end 
                Page.Visible = true 
            end)
            return Page
        end

        -- Content
        local Home = Instance.new("Frame", ContentContainer); Home.Name = "Home"; Home.Size = UDim2.new(1,0,1,0); Home.BackgroundTransparency = 1
        local l = Instance.new("TextLabel", Home); l.Size = UDim2.new(1,0,0,20); l.Text = "EstrogenWare V60 - Solara Fixed"; l.Font = Enum.Font.RobotoMono; l.BackgroundTransparency = 1; l.TextColor3 = Color3.new(0,0,0)

        local Combat = NewTab("Combat")
        local Visuals = NewTab("Visuals")
        local Configs = NewTab("Configs")

        local function AddToggle(p, t, k)
            local b = Instance.new("TextButton", p); b.Size = UDim2.new(1, -5, 0, 35); b.BackgroundColor3 = Color3.new(1,1,1); b.BorderSizePixel = 0; ApplyPride(b)
            local function r() b.Text = t..": "..(getgenv().Settings[k] and "ON" or "OFF") end
            b.MouseButton1Click:Connect(function() getgenv().Settings[k] = not getgenv().Settings[k]; r(); SaveConfig() end); r()
        end

        local function AddSlider(p, t, k, min, max)
            local f = Instance.new("Frame", p); f.Size = UDim2.new(1, -5, 0, 45); f.BackgroundTransparency = 1
            local b = Instance.new("TextButton", f); b.Size = UDim2.new(1, 0, 1, 0); b.BackgroundColor3 = Color3.new(1,1,1); b.BorderSizePixel = 0; ApplyPride(b)
            local function r() b.Text = t..": "..getgenv().Settings[k] end
            
            b.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    Main.Draggable = false -- STOP UI FROM MOVING
                    local conn; conn = RunService.RenderStepped:Connect(function()
                        if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then 
                            Main.Draggable = true; SaveConfig(); conn:Disconnect() return 
                        end
                        local mPos = UserInputService:GetMouseLocation().X
                        local rel = math.clamp((mPos - b.AbsolutePosition.X) / b.AbsoluteSize.X, 0, 1)
                        getgenv().Settings[k] = math.round(min + (max - min) * rel)
                        r()
                    end)
                end
            end); r()
        end

        AddToggle(Combat, "Aimlock", "SnapAim"); AddSlider(Combat, "Smoothing", "Smoothing", 1, 100)
        AddToggle(Visuals, "ESP", "ESP"); AddToggle(Visuals, "Show FOV", "ShowFOV"); AddSlider(Visuals, "FOV Size", "FOV", 10, 800)

        -- Config Logic Fix
        local ConfigScroll = Instance.new("ScrollingFrame", Configs); ConfigScroll.Size = UDim2.new(1,0,0,200); ConfigScroll.BackgroundTransparency = 1; ConfigScroll.BorderSizePixel = 0
        Instance.new("UIListLayout", ConfigScroll)
        
        local function Refresh()
            for _, v in pairs(ConfigScroll:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
            if listfiles then 
                for _, f in pairs(listfiles("")) do
                    if f:sub(-5) == ".json" then
                        local nb = Instance.new("TextButton", ConfigScroll); nb.Size = UDim2.new(1,0,0,30); nb.Text = f; nb.BackgroundColor3 = Color3.new(1,1,1); ApplyPride(nb)
                        nb.MouseButton1Click:Connect(function() getgenv().Settings = HttpService:JSONDecode(readfile(f)) end)
                    end
                end
            end
        end
        Refresh()

        -- Combat / Visual Loop
        local FOVDraw = Drawing.new("Circle")
        RunService.RenderStepped:Connect(function()
            if not getgenv().EW_RUNNING then FOVDraw:Remove() return end
            
            FOVDraw.Visible = getgenv().Settings.ShowFOV
            FOVDraw.Radius = getgenv().Settings.FOV
            FOVDraw.Position = UserInputService:GetMouseLocation()
            FOVDraw.Color = Color3.fromRGB(245, 169, 184)
            FOVDraw.Thickness = 2

            if getgenv().Settings.ESP then
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character then
                        local h = p.Character:FindFirstChild("EW_ESP") or Instance.new("Highlight", p.Character)
                        h.Name = "EW_ESP"; h.FillColor = Color3.fromRGB(245, 169, 184)
                    end
                end
            end

            if getgenv().Settings.SnapAim and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
                local target, dist = nil, getgenv().Settings.FOV
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                        local pos, vis = Camera:WorldToViewportPoint(p.Character.Head.Position)
                        if vis then
                            local mag = (Vector2.new(pos.X, pos.Y) - UserInputService:GetMouseLocation()).Magnitude
                            if mag < dist then dist = mag; target = p.Character.Head end
                        end
                    end
                end
                if target and moveFunc then
                    local tPos = Camera:WorldToViewportPoint(target.Position)
                    local mPos = UserInputService:GetMouseLocation()
                    local s = getgenv().Settings.Smoothing / 100
                    moveFunc((tPos.X - mPos.X) * s, (tPos.Y - mPos.Y) * s)
                end
            end
        end)

        local UnloadBtn = Instance.new("TextButton", Side); UnloadBtn.Size = UDim2.new(1, -10, 0, 45); UnloadBtn.Position = UDim2.new(0, 5, 1, -50); UnloadBtn.Text = "UNLOAD"; ApplyPride(UnloadBtn)
        UnloadBtn.MouseButton1Click:Connect(function() getgenv().EW_RUNNING = false; Gui:Destroy() end)
    ]]
    loadstring(src)()
end

RunSource()
