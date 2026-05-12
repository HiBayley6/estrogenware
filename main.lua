-- EstrogenWare v6 (Hardware-State Injection)
local EstrogenScript = [[
    local Library = {}
    local UserInputService = game:GetService("UserInputService")
    local CoreGui = game:GetService("CoreGui")
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local HttpService = game:GetService("HttpService")
    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera

    -- Config System
    local ConfigFile = "EstrogenWare_Settings.json"
    _G.Settings = { SnapAim = false, ESP = false, InfJump = false }

    local function Save() if writefile then writefile(ConfigFile, HttpService:JSONEncode(_G.Settings)) end end
    local function Load() 
        if isfile and isfile(ConfigFile) then 
            local success, data = pcall(function() return HttpService:JSONDecode(readfile(ConfigFile)) end)
            if success then _G.Settings = data end
        end 
    end
    Load()

    -- Hardware-Level Input Check
    local function IsRightClickDown()
        local buttons = UserInputService:GetMouseButtonsPressed()
        for _, btn in pairs(buttons) do
            if btn.UserInputType == Enum.UserInputType.MouseButton2 then return true end
        end
        return false
    end

    -- Targeted Aim Logic
    local function GetClosestTarget()
        local target, dist = nil, 400
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

    -- THE HARDWARE SNAP FIX
    RunService.RenderStepped:Connect(function()
        if _G.Settings.SnapAim and IsRightClickDown() then
            local t = GetClosestTarget()
            if t then
                local targetPos = Camera:WorldToViewportPoint(t.Position)
                local mousePos = UserInputService:GetMouseLocation()
                
                -- Calculate delta with a multiplier to beat game friction
                local delta = (Vector2.new(targetPos.X, targetPos.Y) - mousePos) / 2
                
                -- Hardware-simulated movement
                if mousemoverel then
                    mousemoverel(delta.X, delta.Y)
                end
            end
        end
    end)

    -- Movement & ESP
    RunService.RenderStepped:Connect(function()
        if _G.Settings.InfJump and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum:ChangeState("Jumping") end
        end
    end)

    local VisualsFolder = Instance.new("Folder", CoreGui)
    RunService.Heartbeat:Connect(function()
        VisualsFolder:ClearAllChildren()
        if _G.Settings.ESP then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local hl = Instance.new("Highlight", VisualsFolder)
                    hl.Adornee = p.Character
                    hl.FillColor = Color3.fromRGB(245, 169, 184)
                    hl.OutlineColor = Color3.new(1,1,1)
                end
            end
        end
    end)

    -- UI (Persistent & Toggle: RightShift)
    function Library:Init()
        local Gui = Instance.new("ScreenGui", CoreGui)
        local Main = Instance.new("Frame", Gui)
        Main.Size, Main.Position = UDim2.new(0, 500, 0, 320), UDim2.new(0.5, -250, 0.5, -160)
        Main.BackgroundColor3, Main.Active, Main.Draggable = Color3.fromRGB(20, 20, 25), true, true
        Main.Visible = false

        UserInputService.InputBegan:Connect(function(input, processed)
            if not processed and input.KeyCode == Enum.KeyCode.RightShift then
                Main.Visible = not Main.Visible
            end
        end)

        local Side = Instance.new("Frame", Main)
        Side.Size, Side.BackgroundColor3 = UDim2.new(0, 140, 1, 0), Color3.fromRGB(25, 25, 30)

        local TitleBox = Instance.new("Frame", Side)
        TitleBox.Size, TitleBox.BackgroundColor3 = UDim2.new(1, 0, 0, 50), Color3.fromRGB(173, 216, 230)
        local Title = Instance.new("TextLabel", TitleBox)
        Title.Size, Title.Text, Title.Font, Title.TextSize = UDim2.new(1,0,1,0), "EstrogenWare", Enum.Font.GothamBold, 18
        Title.TextColor3, Title.BackgroundTransparency = Color3.new(1,1,1), 1

        local TabContainer = Instance.new("Frame", Side)
        TabContainer.Position, TabContainer.Size = UDim2.new(0, 5, 0, 60), UDim2.new(1, -10, 1, -120)
        TabContainer.BackgroundTransparency = 1
        Instance.new("UIListLayout", TabContainer).Padding = UDim.new(0, 5)

        local Content = Instance.new("Frame", Main)
        Content.Position, Content.Size = UDim2.new(0, 145, 0, 10), UDim2.new(1, -155, 1, -20)
        Content.BackgroundTransparency = 1

        local Tabs = {}
        function Tabs:NewTab(name)
            local Page = Instance.new("ScrollingFrame", Content)
            Page.Size, Page.Visible, Page.BackgroundTransparency = UDim2.new(1,0,1,0), false, 1
            Page.ScrollBarThickness = 0
            Instance.new("UIListLayout", Page).Padding = UDim.new(0, 6)

            local b = Instance.new("TextButton", TabContainer)
            b.Size, b.Text, b.BackgroundColor3 = UDim2.new(1,0,0,35), name, Color3.fromRGB(35, 35, 40)
            b.TextColor3, b.Font = Color3.new(1,1,1), Enum.Font.GothamBold
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)

            b.MouseButton1Click:Connect(function()
                for _, v in pairs(Content:GetChildren()) do if v:IsA("ScrollingFrame") then v.Visible = false end end
                Page.Visible = true
            end)

            local El = {}
            function El:Toggle(txt, key)
                local t = Instance.new("TextButton", Page)
                t.Size, t.BackgroundColor3 = UDim2.new(1, 0, 0, 30), Color3.fromRGB(40, 40, 45)
                local function Refresh()
                    t.Text = (_G.Settings[key] and " [ + ] " or " [ - ] ") .. txt
                    t.TextColor3 = _G.Settings[key] and Color3.fromRGB(245, 169, 184) or Color3.new(0.8, 0.8, 0.8)
                end
                Refresh()
                t.MouseButton1Click:Connect(function() _G.Settings[key] = not _G.Settings[key]; Refresh(); Save() end)
            end
            return El
        end

        local Unload = Instance.new("TextButton", Side)
        Unload.Size, Unload.Position = UDim2.new(1, -10, 0, 40), UDim2.new(0, 5, 1, -50)
        Unload.BackgroundColor3, Unload.Text = Color3.fromRGB(245, 169, 184), "Unload"
        Unload.Font, Unload.TextColor3 = Enum.Font.GothamBold, Color3.new(1,1,1)
        Unload.MouseButton1Click:Connect(function() Gui:Destroy(); VisualsFolder:Destroy() end)

        return Tabs
    end

    local UI = Library:Init()
    local C = UI:NewTab("Combat"); C:Toggle("Raw Hardware Snap", "SnapAim")
    local V = UI:NewTab("Visuals"); V:Toggle("ESP", "ESP")
    local M = UI:NewTab("Misc"); M:Toggle("Inf Jump", "InfJump")
]]

if queue_on_teleport then queue_on_teleport(EstrogenScript) end
loadstring(EstrogenScript)()
