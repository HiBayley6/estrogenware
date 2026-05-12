local EstrogenScript = [[
    local Library = {Tabs = {}}
    local UserInputService = game:GetService("UserInputService")
    local CoreGui = game:GetService("CoreGui")
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local HttpService = game:GetService("HttpService")
    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera

    -- Settings & Configs
    _G.Settings = {
        SnapAim = false,
        BlatantMode = false,
        Strength = 5, -- 1 to 10
        FOV = 150,
        ESP = false,
        InfJump = false,
        Speed = 16
    }

    local function Save() if writefile then writefile("EW_Config.json", HttpService:JSONEncode(_G.Settings)) end end
    local function Load() 
        if isfile and isfile("EW_Config.json") then 
            local d = HttpService:JSONDecode(readfile("EW_Config.json"))
            for k,v in pairs(d) do _G.Settings[k] = v end
        end 
    end
    Load()

    -- FOV Circle Visual
    local FOVCircle = Drawing.new("Circle")
    FOVCircle.Thickness = 1
    FOVCircle.Color = Color3.fromRGB(245, 169, 184)
    FOVCircle.Filled = false
    FOVCircle.Transparency = 1

    -- Target Logic
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

    -- THE AIM ENGINE (Fixed Flicking)
    RunService.RenderStepped:Connect(function()
        FOVCircle.Radius = _G.Settings.FOV
        FOVCircle.Position = UserInputService:GetMouseLocation()
        FOVCircle.Visible = _G.Settings.SnapAim

        if _G.Settings.SnapAim and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            local t = GetTarget()
            if t then
                local tPos = Camera:WorldToViewportPoint(t.Position)
                local mPos = UserInputService:GetMouseLocation()
                
                -- The Fix: We clamp the movement so it can't "Flick to sky"
                local moveX = (tPos.X - mPos.X)
                local moveY = (tPos.Y - mPos.Y)
                
                local power = _G.Settings.BlatantMode and 1 or (_G.Settings.Strength / 10)
                
                if mousemoverel then
                    -- Sensitivity scaling to prevent the "Sky Launch"
                    mousemoverel(moveX * power, moveY * power)
                end
            end
        end

        if _G.Settings.InfJump and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
        end
        
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = _G.Settings.Speed
        end
    end)

    -- Visuals
    local Visuals = Instance.new("Folder", CoreGui)
    RunService.Heartbeat:Connect(function()
        Visuals:ClearAllChildren()
        if _G.Settings.ESP then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local hl = Instance.new("Highlight", Visuals)
                    hl.Adornee = p.Character
                    hl.FillColor = Color3.fromRGB(245, 169, 184)
                end
            end
        end
    end)

    -- UI (Fixed Layout)
    function Library:Init()
        local Gui = Instance.new("ScreenGui", CoreGui)
        local Main = Instance.new("Frame", Gui)
        Main.Size, Main.Position = UDim2.new(0, 500, 0, 320), UDim2.new(0.5, -250, 0.5, -160)
        Main.BackgroundColor3, Main.BorderSizePixel = Color3.fromRGB(25, 25, 30), 0
        Main.Active, Main.Draggable, Main.Visible = true, true, false

        UserInputService.InputBegan:Connect(function(i, p)
            if not p and i.KeyCode == Enum.KeyCode.RightShift then Main.Visible = not Main.Visible end
        end)

        local Side = Instance.new("Frame", Main)
        Side.Size, Side.BackgroundColor3, Side.BorderSizePixel = UDim2.new(0, 140, 1, 0), Color3.fromRGB(30, 30, 35), 0

        local TitleBox = Instance.new("Frame", Side)
        TitleBox.Size, TitleBox.BackgroundColor3, TitleBox.BorderSizePixel = UDim2.new(1, 0, 0, 50), Color3.fromRGB(173, 216, 230), 0
        local Title = Instance.new("TextLabel", TitleBox)
        Title.Size, Title.Text, Title.Font, Title.TextColor3 = UDim2.new(1,0,1,0), "EstrogenWare", Enum.Font.GothamBold, Color3.new(1,1,1)
        Title.BackgroundTransparency, Title.TextSize = 1, 16

        local TabContainer = Instance.new("Frame", Side)
        TabContainer.Position, TabContainer.Size = UDim2.new(0, 5, 0, 60), UDim2.new(1, -10, 1, -120)
        TabContainer.BackgroundTransparency = 1
        Instance.new("UIListLayout", TabContainer).Padding = UDim.new(0, 5)

        local Content = Instance.new("Frame", Main)
        Content.Position, Content.Size = UDim2.new(0, 145, 0, 5), UDim2.new(1, -150, 1, -10)
        Content.BackgroundTransparency = 1

        function Library:NewTab(name)
            local Page = Instance.new("ScrollingFrame", Content)
            Page.Size, Page.Visible, Page.BackgroundTransparency, Page.ScrollBarThickness = UDim2.new(1,0,1,0), false, 1, 0
            Instance.new("UIListLayout", Page).Padding = UDim.new(0, 5)

            local b = Instance.new("TextButton", TabContainer)
            b.Size, b.Text, b.BackgroundColor3 = UDim2.new(1, 0, 0, 30), name, Color3.fromRGB(40, 40, 45)
            b.TextColor3, b.Font = Color3.new(1,1,1), Enum.Font.GothamBold
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
            b.MouseButton1Click:Connect(function()
                for _, v in pairs(Content:GetChildren()) do v.Visible = false end
                Page.Visible = true
            end)

            local El = {}
            function El:Toggle(txt, key)
                local t = Instance.new("TextButton", Page)
                t.Size, t.BackgroundColor3 = UDim2.new(1, -10, 0, 30), Color3.fromRGB(45, 45, 50)
                local function Ref()
                    t.Text = (_G.Settings[key] and "[+] " or "[-] ") .. txt
                    t.TextColor3 = _G.Settings[key] and Color3.fromRGB(245, 169, 184) or Color3.new(0.8, 0.8, 0.8)
                end
                Ref()
                t.MouseButton1Click:Connect(function() _G.Settings[key] = not _G.Settings[key]; Ref(); Save() end)
            end
            
            function El:Slider(txt, key, min, max)
                local s = Instance.new("TextButton", Page)
                s.Size, s.BackgroundColor3 = UDim2.new(1,-10,0,30), Color3.fromRGB(45, 45, 50)
                local function Ref() s.Text = txt .. ": " .. _G.Settings[key] end
                Ref()
                s.MouseButton1Click:Connect(function()
                    _G.Settings[key] = (_G.Settings[key] >= max) and min or (_G.Settings[key] + 1)
                    Ref(); Save()
                end)
            end
            return El
        end
        return Library
    end

    local UI = Library:Init()
    local C = UI:NewTab("Combat"); C:Toggle("Enable Snap", "SnapAim"); C:Toggle("Blatant Mode", "BlatantMode")
    C:Slider("Strength", "Strength", 1, 10); C:Slider("FOV", "FOV", 50, 500)
    local V = UI:NewTab("Visuals"); V:Toggle("ESP", "ESP")
    local M = UI:NewTab("Misc"); M:Toggle("Inf Jump", "InfJump"); M:Slider("Speed", "Speed", 16, 100)
]]

local Loader = [[ repeat task.wait() until game:IsLoaded(); task.wait(1.5); ]] .. EstrogenScript
if queue_on_teleport then queue_on_teleport(Loader) end
loadstring(Loader)()
