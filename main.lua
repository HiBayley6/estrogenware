local EstrogenScript = [[
    local Library = {Tabs = {}, Configs = {}}
    local UserInputService = game:GetService("UserInputService")
    local CoreGui = game:GetService("CoreGui")
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local HttpService = game:GetService("HttpService")
    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera

    -- Persistence & Profiles
    _G.Settings = {
        SnapStrength = 0.5,
        BlatantMode = false,
        FOV = 200,
        ESP = false,
        SnapAim = false,
        InfJump = false,
        SpeedBoost = 16,
        CurrentProfile = "Default"
    }

    local function Save(name)
        local fileName = "EW_" .. (name or _G.Settings.CurrentProfile) .. ".json"
        writefile(fileName, HttpService:JSONEncode(_G.Settings))
    end

    local function Load(name)
        local fileName = "EW_" .. (name or "Default") .. ".json"
        if isfile(fileName) then
            local data = HttpService:JSONDecode(readfile(fileName))
            for k, v in pairs(data) do _G.Settings[k] = v end
        end
    end
    Load("Default")

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

    -- Aim Engine with Strength Slider
    RunService.RenderStepped:Connect(function()
        if _G.Settings.SnapAim and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            local t = GetTarget()
            if t then
                local targetPos = Camera:WorldToViewportPoint(t.Position)
                local mousePos = UserInputService:GetMouseLocation()
                
                local delta = (Vector2.new(targetPos.X, targetPos.Y) - mousePos)
                
                -- Strength Logic: 
                -- Blatant = No movement off them. 
                -- Legit = Slight nudge.
                local power = _G.Settings.BlatantMode and 1 or _G.Settings.SnapStrength
                if mousemoverel then
                    mousemoverel(delta.X * power, delta.Y * power)
                end
            end
        end

        -- Extra "Rival Ruining" Features
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = _G.Settings.SpeedBoost
        end
    end)

    -- UI (Persistent & Scannable)
    function Library:Init()
        local Gui = Instance.new("ScreenGui", CoreGui)
        local Main = Instance.new("Frame", Gui)
        Main.Size, Main.Position = UDim2.new(0, 500, 0, 350), UDim2.new(0.5, -250, 0.5, -175)
        Main.BackgroundColor3, Main.Draggable = Color3.fromRGB(20, 20, 25), true
        Main.Active = true; Main.Visible = false

        UserInputService.InputBegan:Connect(function(i, p)
            if not p and i.KeyCode == Enum.KeyCode.RightShift then Main.Visible = not Main.Visible end
        end)

        -- Side Panel
        local Side = Instance.new("Frame", Main)
        Side.Size, Side.BackgroundColor3 = UDim2.new(0, 140, 1, 0), Color3.fromRGB(25, 25, 30)
        
        local TitleBox = Instance.new("Frame", Side)
        TitleBox.Size, TitleBox.BackgroundColor3 = UDim2.new(1, 0, 0, 50), Color3.fromRGB(173, 216, 230)
        local Title = Instance.new("TextLabel", TitleBox)
        Title.Size, Title.Text, Title.Font, Title.TextColor3 = UDim2.new(1,0,1,0), "EstrogenWare", Enum.Font.Code, Color3.new(1,1,1)
        Title.BackgroundTransparency, Title.TextSize = 1, 18

        local Content = Instance.new("Frame", Main)
        Content.Position, Content.Size = UDim2.new(0, 145, 0, 10), UDim2.new(1, -155, 1, -20)
        Content.BackgroundTransparency = 1

        local TabContainer = Instance.new("Frame", Side)
        TabContainer.Position, TabContainer.Size = UDim2.new(0, 5, 0, 60), UDim2.new(1, -10, 1, -160)
        TabContainer.BackgroundTransparency = 1
        Instance.new("UIListLayout", TabContainer).Padding = UDim.new(0, 5)

        function Library:NewTab(name)
            local Page = Instance.new("ScrollingFrame", Content)
            Page.Size, Page.Visible, Page.BackgroundTransparency = UDim2.new(1,0,1,0), false, 1
            Page.ScrollBarThickness = 0
            Instance.new("UIListLayout", Page).Padding = UDim.new(0, 6)

            local b = Instance.new("TextButton", TabContainer)
            b.Size, b.Text, b.BackgroundColor3 = UDim2.new(1,0,0,30), name, Color3.fromRGB(35, 35, 40)
            b.TextColor3, b.Font = Color3.new(1,1,1), Enum.Font.Code
            b.MouseButton1Click:Connect(function()
                for _, v in pairs(Content:GetChildren()) do v.Visible = false end
                Page.Visible = true
            end)

            local El = {}
            function El:Toggle(txt, key)
                local t = Instance.new("TextButton", Page)
                t.Size, t.BackgroundColor3 = UDim2.new(1, 0, 0, 28), Color3.fromRGB(40, 40, 45)
                local function Refresh()
                    t.Text = (_G.Settings[key] and " [ + ] " or " [ - ] ") .. txt
                    t.TextColor3 = _G.Settings[key] and Color3.fromRGB(245, 169, 184) or Color3.new(0.8, 0.8, 0.8)
                end
                Refresh()
                t.MouseButton1Click:Connect(function() _G.Settings[key] = not _G.Settings[key]; Refresh(); Save() end)
            end

            function El:Slider(txt, key, min, max)
                local sFrame = Instance.new("Frame", Page)
                sFrame.Size, sFrame.BackgroundColor3 = UDim2.new(1, 0, 0, 40), Color3.fromRGB(30, 30, 35)
                local label = Instance.new("TextLabel", sFrame)
                label.Size, label.Text, label.TextColor3 = UDim2.new(1,0,0,20), txt .. ": " .. _G.Settings[key], Color3.new(1,1,1)
                label.BackgroundTransparency, label.Font = 1, Enum.Font.Code
                
                local btn = Instance.new("TextButton", sFrame)
                btn.Size, btn.Position, btn.Text = UDim2.new(0.9, 0, 0, 10), UDim2.new(0.05, 0, 0.6, 0), ""
                btn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
                
                btn.MouseButton1Click:Connect(function()
                    local mouse = UserInputService:GetMouseLocation()
                    local rel = (mouse.X - btn.AbsolutePosition.X) / btn.AbsoluteSize.X
                    local val = math.clamp(math.round(min + (max - min) * rel), min, max)
                    _G.Settings[key] = val
                    label.Text = txt .. ": " .. val
                    Save()
                end)
            end
            return El
        end
        return Library
    end

    local UI = Library:Init()
    local C = UI:NewTab("Combat")
    C:Toggle("Enable Snap", "SnapAim")
    C:Toggle("100% Blatant", "BlatantMode")
    C:Slider("Aim Strength (%)", "SnapStrength", 0, 100) -- Internal logic handles math
    C:Slider("FOV Radius", "FOV", 50, 800)

    local M = UI:NewTab("Misc")
    M:Toggle("Infinite Jump", "InfJump")
    M:Slider("WalkSpeed", "SpeedBoost", 16, 100)

    local P = UI:NewTab("Profiles")
    -- Simple buttons for Save/Load
    local saveBtn = Instance.new("TextButton", Content:FindFirstChildOfClass("ScrollingFrame"))
    saveBtn.Size, saveBtn.Text = UDim2.new(1,0,0,30), "Save Legit Config"
    saveBtn.MouseButton1Click:Connect(function() Save("Legit") end)
]]

-- Loader Protection: Waits for game to load before executing
local Loader = [[
    repeat task.wait() until game:IsLoaded()
    task.wait(2) -- Extra buffer for Rivals physics to init
    ]] .. EstrogenScript

if queue_on_teleport then queue_on_teleport(Loader) end
loadstring(Loader)()
