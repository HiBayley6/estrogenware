-- EstrogenWare V56 Persistence Override (Solara Framework Integration)
-- Fixed: Execution Context, CoreGui Sandbox Access, Vector2 Math Errors, and Complete Module Unloading
-- Added: Line-Based Skeleton ESP Module

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
        
        -- Solara Environment Fallback Layer
        local CoreGui = game:GetService("CoreGui")
        local TargetFolder = LocalPlayer:FindFirstChildOfClass("PlayerGui") or CoreGui

        -- Config Logic
        getgenv().Settings = getgenv().Settings or {
            SnapAim = false, ShowFOV = true, Blatant = false, ESP = false, SkeletonESP = false,
            FOV = 150, Smoothing = 15
        }

        local function SaveConfig(n)
            local p = n or "EW_Last_Config.json"
            pcall(function() writefile(p, HttpService:JSONEncode(getgenv().Settings)) end)
        end

        -- UI Build
        if TargetFolder:FindFirstChild("EstrogenWare") then TargetFolder.EstrogenWare:Destroy() end
        local Gui = Instance.new("ScreenGui", TargetFolder); Gui.Name = "EstrogenWare"
        Gui.ResetOnSpawn = false
        
        local Main = Instance.new("Frame", Gui)
        Main.Size = UDim2.new(0, 520, 0, 380)
        Main.Position = UDim2.new(0.5, -260, 0.5, -190) 
        Main.BackgroundColor3 = Color3.new(1,1,1); Main.BorderSizePixel = 0; Main.Active = true
        Main.Visible = true 

        -- Standard Dragging Fix for Solara Container Limits
        local dragging, dragInput, dragStart, startPos
        Main.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true; dragStart = input.Position; startPos = Main.Position
                input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
            end
        end)
        Main.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                local delta = input.Position - dragStart
                Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)

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
                Home.Visible = false
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
        local Visuals = NewTab("Visuals"); AddToggle(Visuals, "Highlight ESP", "ESP"); AddToggle(Visuals, "Skeleton ESP", "SkeletonESP"); AddToggle(Visuals, "Show FOV", "ShowFOV"); AddSlider(Visuals, "FOV Size", "FOV", 10, 800)
        
        -- CONFIG TAB (Dynamic Tracker)
        local Configs = NewTab("Configs")
        local ConfigScroll = Instance.new("ScrollingFrame", Configs); ConfigScroll.Size = UDim2.new(1, -5, 1, -90); ConfigScroll.BackgroundTransparency = 1; ConfigScroll.ScrollBarThickness = 2; ConfigScroll.BorderSizePixel = 0
        Instance.new("UIListLayout", ConfigScroll).Padding = UDim.new(0, 5)

        local CreateContainer = Instance.new("Frame", Configs); CreateContainer.Size = UDim2.new(1, -5, 0, 80); CreateContainer.Position = UDim2.new(0, 0, 1, -80); CreateContainer.BackgroundTransparency = 1; CreateContainer.BorderSizePixel = 0
        local ConfigName = Instance.new("TextBox", CreateContainer); ConfigName.Size = UDim2.new(1, 0, 0, 35); ConfigName.BackgroundColor3 = Color3.new(1,1,1); ConfigName.PlaceholderText = "Config Name..."; ConfigName.Text = ""; ConfigName.Font = Enum.Font.RobotoMono; ConfigName.TextColor3 = Color3.new(0,0,0); ConfigName.BorderSizePixel = 0; ApplyPride(ConfigName)
        local SaveBtn = Instance.new("TextButton", CreateContainer); SaveBtn.Size = UDim2.new(1, 0, 0, 35); SaveBtn.Position = UDim2.new(0, 0, 0, 40); SaveBtn.BackgroundColor3 = Color3.new(1,1,1); SaveBtn.Text = "CREATE CONFIG"; SaveBtn.Font = Enum.Font.RobotoMono; SaveBtn.BorderSizePixel = 0; ApplyPride(SaveBtn)
        
        local TrackedConfigs = getgenv().EW_TrackedConfigs or {}
        getgenv().EW_TrackedConfigs = TrackedConfigs

        local function RefreshConfigs()
            for _, v in pairs(ConfigScroll:GetChildren()) do if v:IsA("Frame") then v:Destroy() end end
            for file, _ in pairs(TrackedConfigs) do
                local row = Instance.new("Frame", ConfigScroll); row.Size = UDim2.new(1, 0, 0, 30); row.BackgroundTransparency = 1; row.BorderSizePixel = 0
                local load = Instance.new("TextButton", row); load.Size = UDim2.new(0.8, -5, 1, 0); load.Text = file; load.Font = Enum.Font.RobotoMono; load.BackgroundColor3 = Color3.new(1,1,1); load.BorderSizePixel = 0; ApplyPride(load)
                local del = Instance.new("TextButton", row); del.Size = UDim2.new(0.2, 0, 1, 0); del.Position = UDim2.new(0.8, 0, 0, 0); del.Text = "X"; del.TextColor3 = Color3.new(1,1,1); del.BackgroundColor3 = Color3.fromRGB(245, 169, 184); del.BorderSizePixel = 0
                
                load.MouseButton1Click:Connect(function() 
                    local success, result = pcall(function() return readfile(file) end)
                    if success then
                        local d = HttpService:JSONDecode(result) 
                        for i, v in pairs(d) do getgenv().Settings[i] = v end 
                    end
                end)
                
                del.MouseButton1Click:Connect(function() 
                    pcall(function() delfile(file) end) 
                    TrackedConfigs[file] = nil
                    RefreshConfigs() 
                end)
            end
        end

        SaveBtn.MouseButton1Click:Connect(function() 
            if ConfigName.Text ~= "" then 
                local fName = ConfigName.Text..".json"
                SaveConfig(fName) 
                TrackedConfigs[fName] = true
                ConfigName.Text = "" 
                RefreshConfigs() 
            end 
        end)
        RefreshConfigs()

        local UnloadBtn = Instance.new("TextButton", Side); UnloadBtn.Size = UDim2.new(1, -10, 0, 45); UnloadBtn.Position = UDim2.new(0, 5, 1, -50); UnloadBtn.BackgroundColor3 = Color3.new(1,1,1); UnloadBtn.Text = "UNLOAD"; UnloadBtn.Font = Enum.Font.RobotoMono; UnloadBtn.TextColor3 = Color3.fromRGB(30,30,30); UnloadBtn.BorderSizePixel = 0; ApplyPride(UnloadBtn)

        -- Drawing API Cache
        local FOVDraw = Drawing.new("Circle")
        local Skeletons = {}

        local function ClearDrawings()
            pcall(function() FOVDraw:Remove() end)
            for _, cache in pairs(Skeletons) do
                for _, line in pairs(cache) do pcall(function() line:Remove() end) end
            end
            Skeletons = {}
        end

        UnloadBtn.MouseButton1Click:Connect(function()
            getgenv().EW_RUNNING = false 
            task.wait(0.05)
            ClearDrawings()
            for _, p in pairs(Players:GetPlayers()) do 
                if p.Character then 
                    local h = p.Character:FindFirstChild("EW_ESP") or CoreGui:FindFirstChild(p.Name.."_Highlight")
                    if h then h:Destroy() end 
                end 
            end
            Gui:Destroy()
            local dog = LogService:FindFirstChild("EW_Watchdog_Active")
            if dog then dog:Destroy() end
        end)

        -- Skeleton Construct Generator
        local BoneStructure = {
            {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
            {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
            {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
            {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
            {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"}
        }

        local function CreateSkelCache(plr)
            if Skeletons[plr] then return end
            local lines = {}
            for i = 1, #BoneStructure do
                local l = Drawing.new("Line")
                l.Thickness = 2
                l.Color = Color3.fromRGB(255, 255, 255)
                l.Visible = false
                table.insert(lines, l)
            end
            Skeletons[plr] = lines
        end

        local MainLoop; MainLoop = RunService.RenderStepped:Connect(function()
            if not getgenv().EW_RUNNING then 
                MainLoop:Disconnect() 
                ClearDrawings()
                return 
            end
            
            local Camera = workspace.CurrentCamera
            if not Camera then return end

            local mouseLoc = UserInputService:GetMouseLocation()
            FOVDraw.Thickness = 2
            FOVDraw.Color = Color3.fromRGB(245, 169, 184)
            FOVDraw.Radius = getgenv().Settings.FOV
            FOVDraw.Position = mouseLoc
            FOVDraw.Visible = getgenv().Settings.ShowFOV
            
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer then
                    -- Highlight Visual Framework Fix
                    if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        local h = p.Character:FindFirstChild("EW_ESP")
                        if getgenv().Settings.ESP then
                            if not h then 
                                h = Instance.new("Highlight")
                                h.Name = "EW_ESP"
                                h.FillColor = Color3.fromRGB(245, 169, 184)
                                h.OutlineColor = Color3.new(1,1,1)
                                h.Parent = p.Character
                            end
                        else
                            if h then h:Destroy() end
                        end

                        -- Skeleton Render Implementation
                        if getgenv().Settings.SkeletonESP then
                            CreateSkelCache(p)
                            local cache = Skeletons[p]
                            local char = p.Character
                            
                            for idx, bone in ipairs(BoneStructure) do
                                local b1, b2 = char:FindFirstChild(bone[1]), char:FindFirstChild(bone[2])
                                local line = cache[idx]
                                if b1 and b2 and line then
                                    local wPos1, vis1 = Camera:WorldToViewportPoint(b1.Position)
                                    local wPos2, vis2 = Camera:WorldToViewportPoint(b2.Position)
                                    if vis1 and vis2 then
                                        line.From = Vector2.new(wPos1.X, wPos1.Y)
                                        line.To = Vector2.new(wPos2.X, wPos2.Y)
                                        line.Visible = true
                                    else
                                        line.Visible = false
                                    end
                                elseif line then
                                    line.Visible = false
                                end
                            end
                        else
                            if Skeletons[p] then
                                for _, line in pairs(Skeletons[p]) do line.Visible = false end
                            end
                        end
                    else
                        if Skeletons[p] then
                            for _, line in pairs(Skeletons[p]) do line.Visible = false end
                        end
                    end
                end
            end

            -- Aimlock Calculation Logic Fix
            if getgenv().Settings.SnapAim and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
                local target, closestDist = nil, getgenv().Settings.FOV
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                        local pos, vis = Camera:WorldToViewportPoint(p.Character.Head.Position)
                        if vis then
                            local mag = (Vector2.new(pos.X, pos.Y) - mouseLoc).Magnitude
                            if mag < closestDist then closestDist = mag; target = p.Character.Head end
                        end
                    end
                end
                
                -- Global Pointer Input Check
                local mouseMove = mousemoverel or (Input and Input.MouseMove) or (syn and syn.mousemoverel)
                if target and mouseMove then
                    local tPos = Camera:WorldToViewportPoint(target.Position)
                    local s = getgenv().Settings.Blatant and 1 or (getgenv().Settings.Smoothing / 100)
                    mouseMove((tPos.X - mouseLoc.X) * s, (tPos.Y - mouseLoc.Y) * s)
                end
            end
        end)

        UserInputService.InputBegan:Connect(function(i) if i.KeyCode == Enum.KeyCode.RightShift then Main.Visible = not Main.Visible end end)
    ]]
    loadstring(src)()
end

if not LogService:FindFirstChild("EW_Watchdog_Active") then
    local WTag = Instance.new("BoolValue", LogService); WTag.Name = "EW_Watchdog_Active"
    task.spawn(function()
        while getgenv().EW_RUNNING do
            local TargetFolder = game:GetService("Players").LocalPlayer:ToDataKeep() or game:GetService("CoreGui")
            if not TargetFolder:FindFirstChild("EstrogenWare") and getgenv().EW_RUNNING then
                pcall(RunSource)
            end
            task.wait(3)
        end
    end)
end

RunSource()
