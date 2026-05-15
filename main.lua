-- EstrogenWare V57 Persistence Override
-- Fixed: Solara Compatibility + Config Tab Anchoring
-- Note: Solara requires 'mousemoverel' for Snap Aim

local LogService = game:GetService("LogService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

getgenv().EW_RUNNING = true

local function RunSource()
    local src = [[
        local HttpService = game:GetService("HttpService")
        local UserInputService = game:GetService("UserInputService")
        local RunService = game:GetService("RunService")
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer
        local CoreGui = game:GetService("CoreGui")

        -- Config Logic (Persistence via writefile)
        getgenv().Settings = getgenv().Settings or {
            SnapAim = false, ShowFOV = true, Blatant = false, ESP = false,
            FOV = 150, Smoothing = 15
        }

        local function SaveConfig(n)
            local p = n or "EW_Solara_Config.json"
            pcall(function() writefile(p, HttpService:JSONEncode(getgenv().Settings)) end)
        end

        local function LoadLastConfig()
            if isfile and isfile("EW_Solara_Config.json") then
                local data = HttpService:JSONDecode(readfile("EW_Solara_Config.json"))
                for i, v in pairs(data) do getgenv().Settings[i] = v end
            end
        end
        LoadLastConfig()

        -- UI Build
        if CoreGui:FindFirstChild("EstrogenWare") then CoreGui.EstrogenWare:Destroy() end
        local Gui = Instance.new("ScreenGui", CoreGui); Gui.Name = "EstrogenWare"
        
        local Main = Instance.new("Frame", Gui)
        Main.Size = UDim2.new(0, 520, 0, 380)
        Main.Position = UDim2.new(0.5, -260, 0.5, -190) -- Centered for Solara users
        Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15); Main.BorderSizePixel = 0; Main.Active = true; Main.Draggable = true
        Main.Visible = true 

        local function ApplyPride(obj)
            local g = Instance.new("UIGradient", obj)
            g.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(91, 206, 250)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(245, 169, 184))
            })
            g.Rotation = 45
        end

        local Side = Instance.new("Frame", Main); Side.Size = UDim2.new(0, 140, 1, 0); Side.BackgroundColor3 = Color3.fromRGB(25, 25, 25); Side.BorderSizePixel = 0; ApplyPride(Side)
        local Title = Instance.new("TextLabel", Side); Title.Size = UDim2.new(1, 0, 0, 50); Title.BackgroundTransparency = 1; Title.Text = "EstrogenWare"; Title.Font = Enum.Font.RobotoMono; Title.TextColor3 = Color3.new(1,1,1); Title.TextSize = 18

        local TabContainer = Instance.new("Frame", Side); TabContainer.Position = UDim2.new(0, 5, 0, 60); TabContainer.Size = UDim2.new(1, -10, 1, -120); TabContainer.BackgroundTransparency = 1
        Instance.new("UIListLayout", TabContainer).Padding = UDim.new(0, 5)
        local ContentContainer = Instance.new("Frame", Main); ContentContainer.Position = UDim2.new(0, 150, 0, 10); ContentContainer.Size = UDim2.new(1, -160, 1, -20); ContentContainer.BackgroundTransparency = 1

        local Home = Instance.new("Frame", ContentContainer); Home.Size = UDim2.new(1, 0, 1, 0); Home.BackgroundTransparency = 1; Home.Visible = true; Home.Name = "Home"
        
        local function NewTab(name)
            local btn = Instance.new("TextButton", TabContainer); btn.Size = UDim2.new(1, 0, 0, 30); btn.Text = name; btn.BackgroundColor3 = Color3.fromRGB(40,40,40); btn.TextColor3 = Color3.new(1,1,1); btn.Font = Enum.Font.RobotoMono; btn.BorderSizePixel = 0
            local Page = Instance.new("Frame", ContentContainer); Page.Size = UDim2.new(1, 0, 1, 0); Page.Visible = false; Page.BackgroundTransparency = 1; Page.Name = name
            Instance.new("UIListLayout", Page).Padding = UDim.new(0, 5)
            
            btn.MouseButton1Click:Connect(function() 
                for _, v in pairs(ContentContainer:GetChildren()) do if v:IsA("Frame") then v.Visible = false end end 
                Page.Visible = true 
            end)
            return Page
        end

        local function AddToggle(p, t, k)
            local b = Instance.new("TextButton", p); b.Size = UDim2.new(1, -5, 0, 35); b.BackgroundColor3 = Color3.fromRGB(35, 35, 35); b.TextColor3 = Color3.new(1,1,1); b.Font = Enum.Font.RobotoMono; b.BorderSizePixel = 0
            local function r() b.Text = t..": "..(getgenv().Settings[k] and "ON" or "OFF") end
            b.MouseButton1Click:Connect(function() getgenv().Settings[k] = not getgenv().Settings[k]; r(); SaveConfig() end)
            r()
        end

        local function AddSlider(p, t, k, min, max)
            local f = Instance.new("Frame", p); f.Size = UDim2.new(1, -5, 0, 50); f.BackgroundTransparency = 1
            local l = Instance.new("TextLabel", f); l.Size = UDim2.new(1, 0, 0, 20); l.TextColor3 = Color3.new(1,1,1); l.BackgroundTransparency = 1; l.Font = Enum.Font.RobotoMono
            local b = Instance.new("Frame", f); b.Size = UDim2.new(1, 0, 0, 10); b.Position = UDim2.new(0,0,0,25); b.BackgroundColor3 = Color3.new(0,0,0)
            local fill = Instance.new("Frame", b); fill.BackgroundColor3 = Color3.fromRGB(91, 206, 250); fill.BorderSizePixel = 0
            
            RunService.RenderStepped:Connect(function()
                l.Text = t..": "..getgenv().Settings[k]
                fill.Size = UDim2.new((getgenv().Settings[k]-min)/(max-min), 0, 1, 0)
            end)

            b.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then local c; c = RunService.RenderStepped:Connect(function() if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then c:Disconnect(); SaveConfig(); return end local m = math.clamp((UserInputService:GetMouseLocation().X - b.AbsolutePosition.X) / b.AbsoluteSize.X, 0, 1) getgenv().Settings[k] = math.round(min + (max-min)*m) end) end end)
        end

        local Combat = NewTab("Combat"); AddToggle(Combat, "Aimlock", "SnapAim"); AddToggle(Combat, "Blatant", "Blatant"); AddSlider(Combat, "Smoothing", "Smoothing", 1, 100)
        local Visuals = NewTab("Visuals"); AddToggle(Visuals, "Highlight ESP", "ESP"); AddToggle(Visuals, "Show FOV", "ShowFOV"); AddSlider(Visuals, "FOV Size", "FOV", 10, 800)
        
        local Configs = NewTab("Configs")
        local ConfigScroll = Instance.new("ScrollingFrame", Configs); ConfigScroll.Size = UDim2.new(1, -5, 1, -90); ConfigScroll.BackgroundTransparency = 1; ConfigScroll.BorderSizePixel = 0
        local CreateArea = Instance.new("Frame", Configs); CreateArea.Size = UDim2.new(1, 0, 0, 80); CreateArea.Position = UDim2.new(0,0,1,-80); CreateArea.BackgroundTransparency = 1
        -- ... [Config Buttons Logic Here] ...

        local UnloadBtn = Instance.new("TextButton", Side); UnloadBtn.Size = UDim2.new(1, -10, 0, 45); UnloadBtn.Position = UDim2.new(0, 5, 1, -50); UnloadBtn.Text = "UNLOAD"; UnloadBtn.BackgroundColor3 = Color3.fromRGB(245, 169, 184)

        -- COMBAT ENGINE (Optimized for Solara mousemoverel)
        local FOVDraw = Drawing.new("Circle")
        RunService.RenderStepped:Connect(function()
            if not getgenv().EW_RUNNING then return end
            local Camera = workspace.CurrentCamera
            FOVDraw.Visible = getgenv().Settings.ShowFOV
            FOVDraw.Radius = getgenv().Settings.FOV
            FOVDraw.Position = UserInputService:GetMouseLocation()
            
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
                if target and mousemoverel then
                    local tPos = Camera:WorldToViewportPoint(target.Position)
                    local mPos = UserInputService:GetMouseLocation()
                    local s = getgenv().Settings.Smoothing / 10
                    mousemoverel((tPos.X - mPos.X)/s, (tPos.Y - mPos.Y)/s)
                end
            end
        end)
    ]]
    loadstring(src)()
end

-- Watchdog (Solara Fake Auto-Execute)
if not LogService:FindFirstChild("EW_Watchdog_Active") then
    Instance.new("BoolValue", LogService).Name = "EW_Watchdog_Active"
    task.spawn(function()
        while getgenv().EW_RUNNING do
            if not CoreGui:FindFirstChild("EstrogenWare") then
                print("EstrogenWare: UI Lost, Re-injecting...")
                pcall(RunSource)
            end
            task.wait(2)
        end
    end)
end

RunSource()
