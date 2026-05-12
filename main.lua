local EstrogenScript = [[
    local Library = {Tabs = {}}
    local UserInputService = game:GetService("UserInputService")
    local CoreGui = game:GetService("CoreGui")
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local HttpService = game:GetService("HttpService")
    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera

    _G.Settings = {
        SnapAim = false, BlatantMode = false, Strength = 5,
        FOV = 150, ShowFOV = true, ESP = false, InfJump = false, Speed = 16,
        ConfigName = "Default"
    }

    local function SaveConfig(name)
        local path = "EW_" .. (name or _G.Settings.ConfigName) .. ".json"
        writefile(path, HttpService:JSONEncode(_G.Settings))
    end

    local function LoadConfig(name)
        local path = "EW_" .. name .. ".json"
        if isfile(path) then
            local data = HttpService:JSONDecode(readfile(path))
            for k, v in pairs(data) do _G.Settings[k] = v end
            return true
        end
        return false
    end

    local FOVCircle = Drawing.new("Circle")
    FOVCircle.Thickness, FOVCircle.Color, FOVCircle.Transparency = 1, Color3.fromRGB(245, 169, 184), 1

    local function GetTarget()
        local target, dist = nil, _G.Settings.FOV
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                local pos, vis = Camera:WorldToViewportPoint(p.Character.Head.Position)
                if vis then
                    local mPos = UserInputService:GetMouseLocation()
                    local mag = (Vector2.new(pos.X, pos.Y) - mPos).Magnitude
                    if mag < dist then dist = mag; target = p.Character.Head end
                end
            end
        end
        return target
    end

    local Connections = {}
    table.insert(Connections, RunService.RenderStepped:Connect(function()
        FOVCircle.Radius = _G.Settings.FOV
        FOVCircle.Position = UserInputService:GetMouseLocation()
        FOVCircle.Visible = (_G.Settings.SnapAim and _G.Settings.ShowFOV)

        if _G.Settings.SnapAim and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            local t = GetTarget()
            if t then
                local tPos = Camera:WorldToViewportPoint(t.Position)
                local mPos = UserInputService:GetMouseLocation()
                local power = _G.Settings.BlatantMode and 1 or (_G.Settings.Strength / 50)
                if mousemoverel then mousemoverel((tPos.X - mPos.X) * power, (tPos.Y - mPos.Y) * power) end
            end
        end
        if _G.Settings.InfJump and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
        end
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = _G.Settings.Speed
        end
    end))

    function Library:Init()
        local Gui = Instance.new("ScreenGui", CoreGui)
        local Main = Instance.new("Frame", Gui)
        Main.Size, Main.Position = UDim2.new(0, 520, 0, 380), UDim2.new(0.5, -260, 0.5, -190)
        Main.BackgroundColor3, Main.BorderSizePixel = Color3.fromRGB(20, 20, 25), 0
        Main.Active, Main.Draggable, Main.Visible = true, true, false

        table.insert(Connections, UserInputService.InputBegan:Connect(function(i, p)
            if not p and i.KeyCode == Enum.KeyCode.RightShift then Main.Visible = not Main.Visible end
        end))

        local Side = Instance.new("Frame", Main)
        Side.Size, Side.BackgroundColor3 = UDim2.new(0, 140, 1, 0), Color3.fromRGB(25, 25, 30)

        local TitleBox = Instance.new("Frame", Side)
        TitleBox.Size, TitleBox.BackgroundColor3 = UDim2.new(1, 0, 0, 50), Color3.fromRGB(173, 216, 230)
        local Title = Instance.new("TextLabel", TitleBox)
        Title.Size, Title.Text, Title.Font, Title.TextSize = UDim2.new(1,0,1,0), "EstrogenWare", Enum.Font.Code, 18
        Title.TextColor3, Title.BackgroundTransparency = Color3.new(1,1,1), 1

        local TabContainer = Instance.new("Frame", Side)
        TabContainer.Position, TabContainer.Size = UDim2.new(0, 5, 0, 60), UDim2.new(1, -10, 1, -130)
        TabContainer.BackgroundTransparency = 1
        Instance.new("UIListLayout", TabContainer).Padding = UDim.new(0, 5)

        local Content = Instance.new("Frame", Main)
        Content.Position, Content.Size = UDim2.new(0, 150, 0, 10), UDim2.new(1, -160, 1, -20)
        Content.BackgroundTransparency = 1

        function Library:NewTab(name)
            local Page = Instance.new("ScrollingFrame", Content)
            Page.Size, Page.Visible, Page.BackgroundTransparency, Page.ScrollBarThickness = UDim2.new(1,0,1,0), false, 1, 0
            Page.CanvasSize = UDim2.new(0,0,1.5,0) -- Extra space to prevent cutting off toggles
            Instance.new("UIListLayout", Page).Padding = UDim.new(0, 8)

            local b = Instance.new("TextButton", TabContainer)
            b.Size, b.Text, b.BackgroundColor3 = UDim2.new(1, 0, 0, 32), name, Color3.fromRGB(35, 35, 40)
            b.TextColor3, b.Font = Color3.new(1,1,1), Enum.Font.Code
            b.MouseButton1Click:Connect(function()
                for _, v in pairs(Content:GetChildren()) do v.Visible = false end
                Page.Visible = true
            end)

            local El = {}
            function El:Toggle(txt, key)
                local t = Instance.new("TextButton", Page)
                t.Size, t.BackgroundColor3 = UDim2.new(1, -10, 0, 30), Color3.fromRGB(30, 30, 35)
                local function Ref()
                    t.Text = (_G.Settings[key] and "[+] " or "[-] ") .. txt
                    t.TextColor3 = _G.Settings[key] and Color3.fromRGB(245, 169, 184) or Color3.new(0.6, 0.6, 0.6)
                end
                Ref()
                t.MouseButton1Click:Connect(function() _G.Settings[key] = not _G.Settings[key]; Ref() end)
            end

            function El:Slider(txt, key, min, max)
                local sFrame = Instance.new("Frame", Page)
                sFrame.Size, sFrame.BackgroundColor3 = UDim2.new(1, -10, 0, 45), Color3.fromRGB(25, 25, 30)
                local label = Instance.new("TextLabel", sFrame)
                label.Size, label.Position, label.Text = UDim2.new(1, 0, 0, 20), UDim2.new(0, 5, 0, 0), txt .. ": " .. _G.Settings[key]
                label.TextColor3, label.BackgroundTransparency, label.Font, label.TextXAlignment = Color3.new(1,1,1), 1, Enum.Font.Code, Enum.TextXAlignment.Left
                local container = Instance.new("Frame", sFrame)
                container.Size, container.Position = UDim2.new(1, -10, 0, 12), UDim2.new(0, 5, 0, 25)
                container.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
                local fill = Instance.new("Frame", container)
                fill.BackgroundColor3, fill.BorderSizePixel = Color3.fromRGB(245, 169, 184), 0
                local function Update()
                    local percent = math.clamp((_G.Settings[key] - min) / (max - min), 0, 1)
                    fill.Size = UDim2.new(percent, 0, 1, 0)
                    label.Text = txt .. ": " .. tostring(_G.Settings[key])
                end
                container.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        local conn; conn = RunService.RenderStepped:Connect(function()
                            if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then conn:Disconnect() return end
                            local mPos = UserInputService:GetMouseLocation().X - container.AbsolutePosition.X
                            _G.Settings[key] = math.round(min + (max - min) * math.clamp(mPos / container.AbsoluteSize.X, 0, 1))
                            Update()
                        end)
                    end
                end)
                Update()
            end

            function El:TextBox(txt, key, cb)
                local t = Instance.new("TextBox", Page)
                t.Size, t.BackgroundColor3 = UDim2.new(1, -10, 0, 30), Color3.fromRGB(30, 30, 35)
                t.Text, t.PlaceholderText, t.TextColor3, t.Font = _G.Settings[key], txt, Color3.new(1,1,1), Enum.Font.Code
                t.FocusLost:Connect(function() _G.Settings[key] = t.Text; if cb then cb() end end)
            end

            function El:Button(txt, cb)
                local b = Instance.new("TextButton", Page)
                b.Size, b.Text, b.BackgroundColor3 = UDim2.new(1, -10, 0, 30), txt, Color3.fromRGB(40, 40, 45)
                b.TextColor3, b.Font = Color3.new(1,1,1), Enum.Font.Code
                b.MouseButton1Click:Connect(cb)
            end
            return El
        end

        local Unload = Instance.new("TextButton", Side)
        Unload.Size, Unload.Position = UDim2.new(1, -10, 0, 35), UDim2.new(0, 5, 1, -40)
        Unload.BackgroundColor3, Unload.Text = Color3.fromRGB(245, 169, 184), "UNLOAD"
        Unload.Font, Unload.TextColor3, Unload.TextSize = Enum.Font.Code, Color3.new(1,1,1), 14
        Unload.MouseButton1Click:Connect(function()
            for _, c in pairs(Connections) do c:Disconnect() end
            Gui:Destroy(); FOVCircle:Remove()
        end)

        return Library
    end

    local UI = Library:Init()
    local C = UI:NewTab("Combat")
    C:Toggle("Enable Snap", "SnapAim")
    C:Toggle("Show FOV Circle", "ShowFOV") -- This is the one!
    C:Toggle("Blatant Mode", "BlatantMode")
    C:Slider("Strength", "Strength", 1, 50)
    C:Slider("FOV Size", "FOV", 10, 800)

    local M = UI:NewTab("Misc")
    M:Toggle("Inf Jump", "InfJump")
    M:Slider("Walkspeed", "Speed", 16, 200)

    local S = UI:NewTab("Settings")
    S:TextBox("Profile Name", "ConfigName")
    S:Button("Save Profile", function() SaveConfig() end)
    S:Button("Load Profile", function() LoadConfig(_G.Settings.ConfigName) end)
]]

local Loader = [[ repeat task.wait() until game:IsLoaded(); task.wait(1); ]] .. EstrogenScript
if queue_on_teleport then queue_on_teleport(Loader) end
loadstring(Loader)()
