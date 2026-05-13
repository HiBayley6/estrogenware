local EstrogenScript = [[
    local UserInputService = game:GetService("UserInputService")
    local HttpService = game:GetService("HttpService")
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera

    -- 1. DEFINE DEFAULT SETTINGS
    _G.Settings = {
        SnapAim = false, ShowFOV = true, 
        Strength = 5, FOV = 150, Smoothing = 0.15,
        ConfigName = "DefaultConfig"
    }

    -- 2. AUTO-LOAD SYSTEM (The Fix)
    local fileName = _G.Settings.ConfigName .. ".json"
    
    local function SaveConfig()
        local success, err = pcall(function()
            writefile(fileName, HttpService:JSONEncode(_G.Settings))
        end)
        if success then print("Config Saved!") else warn("Save Failed: " .. err) end
    end

    local function LoadConfig()
        if isfile(fileName) then
            local success, data = pcall(function()
                return HttpService:JSONDecode(readfile(fileName))
            end)
            if success and data then
                for k, v in pairs(data) do _G.Settings[k] = v end
                print("Config Auto-Loaded!")
            end
        end
    end

    -- Run Load immediately
    LoadConfig()

    -- 3. THE GHOST LOGIC (V13 Smoothing)
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

    local Connection; Connection = RunService.RenderStepped:Connect(function()
        FOVCircle.Radius = _G.Settings.FOV
        FOVCircle.Position = UserInputService:GetMouseLocation()
        FOVCircle.Visible = (_G.Settings.SnapAim and _G.Settings.ShowFOV)

        if _G.Settings.SnapAim and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            local t = GetTarget()
            if t then
                local tPos = Camera:WorldToViewportPoint(t.Position)
                local mPos = UserInputService:GetMouseLocation()
                local diffX = (tPos.X - mPos.X) * _G.Settings.Smoothing
                local diffY = (tPos.Y - mPos.Y) * _G.Settings.Smoothing
                if mousemoverel then
                    mousemoverel(diffX * (_G.Settings.Strength / 10), diffY * (_G.Settings.Strength / 10))
                end
            end
        end
    end)

    -- [UI Creation Code would go here, calling SaveConfig() on button clicks]
    print("v14 Persistent Loaded. Settings will stick now!")
]]

-- Simple execution check to prevent double-loading
if not _G.EstrogenLoaded then
    _G.EstrogenLoaded = true
    loadstring(EstrogenScript)()
else
    print("EstrogenWare already running!")
end
