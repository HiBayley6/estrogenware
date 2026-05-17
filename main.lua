-- EstrogenWare V56 (Custom Gradient Engine Update)

if not game:IsLoaded() then game.Loaded:Wait() end
local Players = game:GetService("Players")
while not Players.LocalPlayer or not Players.LocalPlayer:FindFirstChildOfClass("PlayerGui") do task.wait(1) end

local LocalPlayer = Players.LocalPlayer
while not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") do task.wait(1) end

local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local TargetFolder = LocalPlayer:FindFirstChildOfClass("PlayerGui") or CoreGui
if TargetFolder:FindFirstChild("EstrogenWare") then TargetFolder.EstrogenWare:Destroy() end
if TargetFolder:FindFirstChild("EstrogenWare_Console") then TargetFolder.EstrogenWare_Console:Destroy() end

getgenv().EW_RUNNING = nil
task.wait(0.05)
getgenv().EW_RUNNING = true

-- Updated configuration schema to store target parts, themes, and colors
getgenv().Settings = getgenv().Settings or {
    SnapAim = false, ShowFOV = true, Blatant = false, ESP = false, SkeletonESP = false, TeamCheck = true,
    FOV = 150, Smoothing = 15, ActiveTheme = "Original", 
    CustomColor = Color3.fromRGB(91, 206, 250), CustomColor2 = Color3.fromRGB(245, 169, 184),
    LockPart = "Head"
}

-- Safe custom serialization system to handle nested elements like Color3
local function SaveConfig(n)
    local p = n or "EW_Last_Config.json"
    pcall(function()
        if writefile then
            local copy = {}
            for k, v in pairs(getgenv().Settings) do
                if typeof(v) == "Color3" then
                    copy[k] = {v.R, v.G, v.B}
                else
                    copy[k] = v
                end
            end
            writefile(p, HttpService:JSONEncode(copy))
        end
    end)
end

local function LoadConfig(n)
    local p = n or "EW_Last_Config.json"
    pcall(function()
        if readfile then
            local content = readfile(p)
            if content then
                local data = HttpService:JSONDecode(content)
                for k, v in pairs(data) do
                    if type(v) == "table" and #v == 3 then
                        getgenv().Settings[k] = Color3.new(v[1], v[2], v[3])
                    else
                        getgenv().Settings[k] = v
                    end
                end
            end
        end
    end)
end

-- Pre-load saved configuration on script load
LoadConfig()

-- ==========================================
-- SMART DRAG SYSTEM (Prevents Slider Interference)
-- ==========================================
local function MakeDraggable(frame)
    local dragging, dragInput, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local target = input.Target
            if target == frame or target:IsA("TextLabel") or target.Name == "Side" or target.Text == "EstrogenWare" then
                dragging = true
                dragStart = input.Position
                startPos = frame.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then dragging = false end
                end)
            end
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- ==========================================
-- MAIN INTERFACE FRAMEWAY (Top-Right)
-- ==========================================
local Gui = Instance.new("ScreenGui")
Gui.Name = "EstrogenWare"
Gui.ResetOnSpawn = false
Gui.DisplayOrder = 2147483647
pcall(function() Gui.Parent = CoreGui end)
if not Gui.Parent then Gui.Parent = TargetFolder end

local Main = Instance.new("Frame", Gui)
Main.Size = UDim2.new(0, 520, 0, 380)
Main.Position = UDim2.new(1, -540, 0, 40)
Main.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Main.BorderSizePixel = 0
Main.Active = true
MakeDraggable(Main)

-- Standalone Console Frame (Bottom-Left)
local ConsoleGui = Instance.new("ScreenGui")
ConsoleGui.Name = "EstrogenWare_Console"
ConsoleGui.ResetOnSpawn = false
ConsoleGui.DisplayOrder = 2147483647
pcall(function() ConsoleGui.Parent = CoreGui end)
if not ConsoleGui.Parent then ConsoleGui.Parent = TargetFolder end

local ConMain = Instance.new("Frame", ConsoleGui)
ConMain.Size = UDim2.new(0, 450, 0, 250)
ConMain.Position = UDim2.new(0, 20, 1, -270)
ConMain.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ConMain.BorderSizePixel = 0
ConMain.Active = true
ConMain.Visible = false
MakeDraggable(ConMain)

-- ==========================================
-- THEME SYSTEM CONFIGURATOR
-- ==========================================
local ThemeObjects = {}
local Side = Instance.new("Frame", Main); Side.Name = "Side"; Side.Size = UDim2.new(0, 140, 1, 0); Side.BackgroundColor3 = Color3.new(1,1,1); Side.BorderSizePixel = 0

local function ApplyThemeData()
    local mode = getgenv().Settings.ActiveTheme or "Original"
    local customClr = getgenv().Settings.CustomColor or Color3.fromRGB(91, 206, 250)
    local customClr2 = getgenv().Settings.CustomColor2 or Color3.fromRGB(245, 169, 184)
    
    for obj, typeInfo in pairs(ThemeObjects) do
        pcall(function()
            if typeInfo == "MainFrame" then
                if mode == "Original" then
                    obj.BackgroundColor3 = Color3.new(1,1,1)
                    local g = obj:FindFirstChildOfClass("UIGradient") or Instance.new("UIGradient", obj)
                    g.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(91, 206, 250)),
                        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(245, 169, 184))
                    })
                    g.Rotation = 45
                elseif mode == "Simple" then
                    if obj:FindFirstChildOfClass("UIGradient") then obj:FindFirstChildOfClass("UIGradient"):Destroy() end
                    obj.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
                elseif mode == "Custom" then
                    obj.BackgroundColor3 = Color3.new(1,1,1)
                    local g = obj:FindFirstChildOfClass("UIGradient") or Instance.new("UIGradient", obj)
                    g.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, customClr),
                        ColorSequenceKeypoint.new(1, customClr2)
                    })
                    g.Rotation = 90
                end
            elseif typeInfo == "ConsoleFrame" then
                if mode == "Original" then
                    obj.BackgroundColor3 = Color3.fromRGB(255, 240, 245)
                    local g = obj:FindFirstChildOfClass("UIGradient") or Instance.new("UIGradient", obj)
                    g.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(91, 206, 250)),
                        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(245, 169, 184))
                    })
                    g.Rotation = 135
                elseif mode == "Simple" then
                    if obj:FindFirstChildOfClass("UIGradient") then obj:FindFirstChildOfClass("UIGradient"):Destroy() end
                    obj.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
                elseif mode == "Custom" then
                    obj.BackgroundColor3 = Color3.new(1,1,1)
                    local g = obj:FindFirstChildOfClass("UIGradient") or Instance.new("UIGradient", obj)
                    g.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, customClr),
                        ColorSequenceKeypoint.new(1, customClr2)
                    })
                    g.Rotation = 135
                end
            elseif typeInfo == "Button" then
                if mode == "Original" then
                    obj.BackgroundColor3 = Color3.new(1,1,1)
                    obj.TextColor3 = Color3.fromRGB(30,30,30)
                    local g = obj:FindFirstChildOfClass("UIGradient") or Instance.new("UIGradient", obj)
                    g.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(91, 206, 250)),
                        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(245, 169, 184))
                    })
                elseif mode == "Simple" then
                    if obj:FindFirstChildOfClass("UIGradient") then obj:FindFirstChildOfClass("UIGradient"):Destroy() end
                    obj.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                    obj.TextColor3 = Color3.fromRGB(240, 240, 240)
                elseif mode == "Custom" then
                    if obj:FindFirstChildOfClass("UIGradient") then obj:FindFirstChildOfClass("UIGradient"):Destroy() end
                    obj.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    obj.TextColor3 = Color3.fromRGB(30, 30, 30)
                end
            elseif typeInfo == "Text" then
                if mode == "Simple" then
                    obj.TextColor3 = Color3.fromRGB(240, 240, 240)
                else
                    obj.TextColor3 = Color3.fromRGB(30, 30, 30)
                end
            end
        end)
    end
end

ThemeObjects[Main] = "MainFrame"
ThemeObjects[Side] = "MainFrame"
ThemeObjects[ConMain] = "ConsoleFrame"

local Title = Instance.new("TextButton", Side); Title.Size = UDim2.new(1, 0, 0, 50); Title.BackgroundTransparency = 1; Title.Text = "EstrogenWare"; Title.Font = Enum.Font.RobotoMono; Title.TextSize = 18; ThemeObjects[Title] = "Text"

local TabContainer = Instance.new("Frame", Side); TabContainer.Position = UDim2.new(0, 5, 0, 60); TabContainer.Size = UDim2.new(1, -10, 1, -120); TabContainer.BackgroundTransparency = 1
Instance.new("UIListLayout", TabContainer).Padding = UDim.new(0, 5)
local ContentContainer = Instance.new("Frame", Main); ContentContainer.Position = UDim2.new(0, 150, 0, 10); ContentContainer.Size = UDim2.new(1, -160, 1, -20); ContentContainer.BackgroundTransparency = 1

local Home = Instance.new("Frame", ContentContainer); Home.Size = UDim2.new(1, 0, 1, 0); Home.BackgroundTransparency = 1; Home.Visible = true; Home.Name = "Home"
local function AddHomeText(t, y)
    local l = Instance.new("TextLabel", Home); l.Size = UDim2.new(1, 0, 0, 20); l.Position = UDim2.new(0, 0, 0, y)
    l.BackgroundTransparency = 1; l.Text = t; l.Font = Enum.Font.RobotoMono; l.TextXAlignment = Enum.TextXAlignment.Left; ThemeObjects[l] = "Text"
end

AddHomeText("status: undetected after testing", 0)
AddHomeText("last updated: 2026-05-17", 25)
AddHomeText("right shift to close / open ui", 50)
AddHomeText("press ` (tilde) to open console", 75)

Title.MouseButton1Click:Connect(function()
    Home.Visible = true
    for _, v in pairs(ContentContainer:GetChildren()) do if v:IsA("Frame") and v ~= Home then v.Visible = false end end
end)

local function NewTab(name)
    local btn = Instance.new("TextButton", TabContainer); btn.Size = UDim2.new(1, 0, 0, 30); btn.Text = name; btn.Font = Enum.Font.RobotoMono; btn.BorderSizePixel = 0; ThemeObjects[btn] = "Button"
    local Page = Instance.new("Frame", ContentContainer); Page.Size = UDim2.new(1, 0, 1, 0); Page.Visible = false; Page.BackgroundTransparency = 1; Page.Name = name
    
    btn.MouseButton1Click:Connect(function() 
        Home.Visible = false
        for _, v in pairs(ContentContainer:GetChildren()) do if v:IsA("Frame") then v.Visible = false end end 
        Page.Visible = true 
    end)
    return Page
end

local function AddToggle(p, t, k)
    local b = Instance.new("TextButton", p); b.Size = UDim2.new(1, -5, 0, 35); b.Font = Enum.Font.RobotoMono; b.BorderSizePixel = 0; ThemeObjects[b] = "Button"
    local function r() b.Text = t..": "..(getgenv().Settings[k] and "ON" or "OFF") end
    b.MouseButton1Click:Connect(function() getgenv().Settings[k] = not getgenv().Settings[k]; r(); SaveConfig() end)
    local c; c = RunService.RenderStepped:Connect(function() if not getgenv().EW_RUNNING then c:Disconnect() return end r() end)
    if not p:FindFirstChild("UIListLayout") then Instance.new("UIListLayout", p).Padding = UDim.new(0, 5) end
end

-- Fixed sliders not dragging properly inside Roblox Escape/Pause menu overlays
local function AddSlider(p, t, k, min, max)
    local f = Instance.new("Frame", p); f.Size = UDim2.new(1, -5, 0, 50); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Size = UDim2.new(1, 0, 0, 20); l.BackgroundTransparency = 1; l.Font = Enum.Font.RobotoMono; ThemeObjects[l] = "Text"
    
    -- Changed standard Frame 'b' to TextButton to capture mouse actions inside all screen layers (including CoreGui and Pause menu)
    local b = Instance.new("TextButton", f); b.Size = UDim2.new(1, 0, 0, 10); b.Position = UDim2.new(0,0,0,25); b.BackgroundColor3 = Color3.new(0,0,0); b.BorderSizePixel = 0; b.Text = ""; b.AutoButtonColor = false; b.Active = true
    local fill = Instance.new("Frame", b); fill.BackgroundColor3 = Color3.fromRGB(91, 206, 250); fill.BorderSizePixel = 0
    
    local c; c = RunService.RenderStepped:Connect(function()
        if not getgenv().EW_RUNNING then c:Disconnect() return end
        l.Text = t..": "..getgenv().Settings[k]
        fill.Size = UDim2.new((getgenv().Settings[k]-min)/(max-min), 0, 1, 0)
    end)

    b.InputBegan:Connect(function(i) 
        if i.UserInputType == Enum.UserInputType.MouseButton1 then 
            local function updateSlider()
                local mousePos = UserInputService:GetMouseLocation()
                local m = math.clamp((mousePos.X - b.AbsolutePosition.X) / b.AbsoluteSize.X, 0, 1) 
                getgenv().Settings[k] = math.round(min + (max-min)*m) 
            end
            updateSlider()
            
            local moveCon, endCon
            moveCon = UserInputService.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement then
                    updateSlider()
                end
            end)
            
            endCon = UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    moveCon:Disconnect()
                    endCon:Disconnect()
                    SaveConfig()
                end
            end)
        end 
    end)
    if not p:FindFirstChild("UIListLayout") then Instance.new("UIListLayout", p).Padding = UDim.new(0, 5) end
end

-- Restored multi-choice text toggles
local function AddOption(p, t, k, options)
    local b = Instance.new("TextButton", p); b.Size = UDim2.new(1, -5, 0, 35); b.Font = Enum.Font.RobotoMono; b.BorderSizePixel = 0; ThemeObjects[b] = "Button"
    local function r() b.Text = t..": "..(getgenv().Settings[k] or options[1]) end
    b.MouseButton1Click:Connect(function()
        local current = getgenv().Settings[k] or options[1]
        local nextIdx = table.find(options, current)
        if nextIdx then
            nextIdx = nextIdx + 1
            if nextIdx > #options then nextIdx = 1 end
        else
            nextIdx = 1
        end
        getgenv().Settings[k] = options[nextIdx]
        r()
        SaveConfig()
    end)
    local c; c = RunService.RenderStepped:Connect(function() if not getgenv().EW_RUNNING then c:Disconnect() return end r() end)
    if not p:FindFirstChild("UIListLayout") then Instance.new("UIListLayout", p).Padding = UDim.new(0, 5) end
end

-- Set up interface pages
local Combat = NewTab("Combat")
AddToggle(Combat, "Aimlock", "SnapAim")
AddToggle(Combat, "Blatant", "Blatant")
AddSlider(Combat, "Smoothing", "Smoothing", 1, 100)
AddOption(Combat, "Lock Bone", "LockPart", {"Head", "Torso", "HumanoidRootPart"})

local Visuals = NewTab("Visuals")
AddToggle(Visuals, "Highlight ESP", "ESP")
AddToggle(Visuals, "Skeleton ESP", "SkeletonESP")
AddToggle(Visuals, "Team Check", "TeamCheck")
AddToggle(Visuals, "Show FOV", "ShowFOV")
AddSlider(Visuals, "FOV Size", "FOV", 10, 800)

-- ==========================================
-- CONFIGS INTERFACE MANAGEMENT
-- ==========================================
local Configs = NewTab("Configs")
local ConfigScroll = Instance.new("ScrollingFrame", Configs); ConfigScroll.Size = UDim2.new(1, -5, 1, -90); ConfigScroll.BackgroundTransparency = 1; ConfigScroll.ScrollBarThickness = 2; ConfigScroll.BorderSizePixel = 0
Instance.new("UIListLayout", ConfigScroll).Padding = UDim.new(0, 5)

local CreateContainer = Instance.new("Frame", Configs); CreateContainer.Size = UDim2.new(1, -5, 0, 80); CreateContainer.Position = UDim2.new(0, 0, 1, -80); CreateContainer.BackgroundTransparency = 1
local ConfigName = Instance.new("TextBox", CreateContainer); ConfigName.Size = UDim2.new(1, 0, 0, 35); ConfigName.PlaceholderText = "Config Name..."; ConfigName.Text = ""; ConfigName.Font = Enum.Font.RobotoMono; ConfigName.BorderSizePixel = 0; ThemeObjects[ConfigName] = "Button"
local SaveBtn = Instance.new("TextButton", CreateContainer); SaveBtn.Size = UDim2.new(1, 0, 0, 35); SaveBtn.Position = UDim2.new(0, 0, 0, 40); SaveBtn.Text = "CREATE CONFIG"; SaveBtn.Font = Enum.Font.RobotoMono; SaveBtn.BorderSizePixel = 0; ThemeObjects[SaveBtn] = "Button"

local TrackedConfigs = getgenv().EW_TrackedConfigs or {}
getgenv().EW_TrackedConfigs = TrackedConfigs

local function RefreshConfigs()
    for _, v in pairs(ConfigScroll:GetChildren()) do if v:IsA("Frame") then v:Destroy() end end
    for file, _ in pairs(TrackedConfigs) do
        local row = Instance.new("Frame", ConfigScroll); row.Size = UDim2.new(1, 0, 0, 30); row.BackgroundTransparency = 1
        local load = Instance.new("TextButton", row); load.Size = UDim2.new(0.8, -5, 1, 0); load.Text = file; load.Font = Enum.Font.RobotoMono; load.BorderSizePixel = 0; ThemeObjects[load] = "Button"
        local del = Instance.new("TextButton", row); del.Size = UDim2.new(0.2, 0, 1, 0); del.Position = UDim2.new(0.8, 0, 0, 0); del.Text = "X"; del.TextColor3 = Color3.new(1,1,1); del.BackgroundColor3 = Color3.fromRGB(245, 169, 184); del.BorderSizePixel = 0
        
        load.MouseButton1Click:Connect(function() 
            LoadConfig(file)
            ApplyThemeData()
        end)
        del.MouseButton1Click:Connect(function() pcall(function() if delfile then delfile(file) end end); TrackedConfigs[file] = nil; RefreshConfigs() end)
    end
end
SaveBtn.MouseButton1Click:Connect(function() if ConfigName.Text ~= "" then local fName = ConfigName.Text..".json"; SaveConfig(fName); TrackedConfigs[fName] = true; ConfigName.Text = ""; RefreshConfigs() end end)
RefreshConfigs()

local UnloadBtn = Instance.new("TextButton", Side); UnloadBtn.Size = UDim2.new(1, -10, 0, 45); UnloadBtn.Position = UDim2.new(0, 5, 1, -50); UnloadBtn.Text = "UNLOAD"; UnloadBtn.Font = Enum.Font.RobotoMono; UnloadBtn.BorderSizePixel = 0; ThemeObjects[UnloadBtn] = "Button"

-- ==========================================
-- THEMES TAB GENERATION (Dual-Color Gradient Engine)
-- ==========================================
local ThemesPage = NewTab("Themes")
local ThemeList = Instance.new("Frame", ThemesPage); ThemeList.Size = UDim2.new(1, 0, 0, 120); ThemeList.BackgroundTransparency = 1
local ThemeLayout = Instance.new("UIListLayout", ThemeList); ThemeLayout.Padding = UDim.new(0, 5)

local function AddThemeSelector(name)
    local b = Instance.new("TextButton", ThemeList); b.Size = UDim2.new(1, -5, 0, 32); b.Text = name.." Theme"; b.Font = Enum.Font.RobotoMono; b.BorderSizePixel = 0; ThemeObjects[b] = "Button"
    b.MouseButton1Click:Connect(function() getgenv().Settings.ActiveTheme = name; ApplyThemeData(); SaveConfig() end)
end

AddThemeSelector("Original")
AddThemeSelector("Simple")
AddThemeSelector("Custom")

-- Dynamic Dual-Slider Container Area
local CustomCanvas = Instance.new("Frame", ThemesPage); CustomCanvas.Size = UDim2.new(1, -5, 0, 100); CustomCanvas.Position = UDim2.new(0, 0, 0, 125); CustomCanvas.BackgroundTransparency = 1

-- Gradient Color 1 Selection Setup
local Lbl1 = Instance.new("TextLabel", CustomCanvas); Lbl1.Size = UDim2.new(1, 0, 0, 15); Lbl1.BackgroundTransparency = 1; Lbl1.Text = "Gradient Start (Top)"; Lbl1.Font = Enum.Font.RobotoMono; Lbl1.TextSize = 12; ThemeObjects[Lbl1] = "Text"
local HueSlider = Instance.new("Frame", CustomCanvas); HueSlider.Size = UDim2.new(1, 0, 0, 20); HueSlider.Position = UDim2.new(0, 0, 0, 18); HueSlider.BorderSizePixel = 0
local HueGrad = Instance.new("UIGradient", HueSlider); HueGrad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.new(1,0,0)), ColorSequenceKeypoint.new(0.16, Color3.new(1,1,0)), ColorSequenceKeypoint.new(0.33, Color3.new(0,1,0)), ColorSequenceKeypoint.new(0.5, Color3.new(0,1,1)), ColorSequenceKeypoint.new(0.66, Color3.new(0,0,1)), ColorSequenceKeypoint.new(0.83, Color3.new(1,0,1)), ColorSequenceKeypoint.new(1, Color3.new(1,0,0))})
local HueSelectorFrame = Instance.new("Frame", HueSlider); HueSelectorFrame.Size = UDim2.new(0, 6, 1, 0); HueSelectorFrame.BackgroundColor3 = Color3.new(1,1,1); HueSelectorFrame.BorderSizePixel = 1; HueSelectorFrame.BorderColor3 = Color3.new(0,0,0)

-- Gradient Color 2 Selection Setup
local Lbl2 = Instance.new("TextLabel", CustomCanvas); Lbl2.Size = UDim2.new(1, 0, 0, 15); Lbl2.Position = UDim2.new(0,0,0,48); Lbl2.BackgroundTransparency = 1; Lbl2.Text = "Gradient End (Bottom)"; Lbl2.Font = Enum.Font.RobotoMono; Lbl2.TextSize = 12; ThemeObjects[Lbl2] = "Text"
local HueSlider2 = Instance.new("Frame", CustomCanvas); HueSlider2.Size = UDim2.new(1, 0, 0, 20); HueSlider2.Position = UDim2.new(0, 0, 0, 66); HueSlider2.BorderSizePixel = 0
local HueGrad2 = Instance.new("UIGradient", HueSlider2); HueGrad2.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.new(1,0,0)), ColorSequenceKeypoint.new(0.16, Color3.new(1,1,0)), ColorSequenceKeypoint.new(0.33, Color3.new(0,1,0)), ColorSequenceKeypoint.new(0.5, Color3.new(0,1,1)), ColorSequenceKeypoint.new(0.66, Color3.new(0,0,1)), ColorSequenceKeypoint.new(0.83, Color3.new(1,0,1)), ColorSequenceKeypoint.new(1, Color3.new(1,0,0))})
local HueSelectorFrame2 = Instance.new("Frame", HueSlider2); HueSelectorFrame2.Size = UDim2.new(0, 6, 1, 0); HueSelectorFrame2.BackgroundColor3 = Color3.new(1,1,1); HueSelectorFrame2.BorderSizePixel = 1; HueSelectorFrame2.BorderColor3 = Color3.new(0,0,0)

local currentHue1, currentHue2 = 0, 0.5

local function UpdateHue1()
    local x = math.clamp((UserInputService:GetMouseLocation().X - HueSlider.AbsolutePosition.X) / HueSlider.AbsoluteSize.X, 0, 1)
    HueSelectorFrame.Position = UDim2.new(x, -3, 0, 0)
    currentHue1 = x
    getgenv().Settings.CustomColor = Color3.fromHSV(currentHue1, 1, 1)
    if getgenv().Settings.ActiveTheme == "Custom" then ApplyThemeData() end
end

local function UpdateHue2()
    local x = math.clamp((UserInputService:GetMouseLocation().X - HueSlider2.AbsolutePosition.X) / HueSlider2.AbsoluteSize.X, 0, 1)
    HueSelectorFrame2.Position = UDim2.new(x, -3, 0, 0)
    currentHue2 = x
    getgenv().Settings.CustomColor2 = Color3.fromHSV(currentHue2, 1, 1)
    if getgenv().Settings.ActiveTheme == "Custom" then ApplyThemeData() end
end

HueSlider.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local con; con = RunService.RenderStepped:Connect(function()
            if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then con:Disconnect(); SaveConfig(); return end
            UpdateHue1()
        end)
    end
end)

HueSlider2.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local con; con = RunService.RenderStepped:Connect(function()
            if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then con:Disconnect(); SaveConfig(); return end
            UpdateHue2()
        end)
    end
end)

RunService.RenderStepped:Connect(function()
    if not getgenv().EW_RUNNING then return end
    CustomCanvas.Visible = (getgenv().Settings.ActiveTheme == "Custom")
end)

-- ==========================================
-- STANDALONE DEV TERMINAL LOGIC
-- ==========================================
local LogBox = Instance.new("ScrollingFrame", ConMain); LogBox.Size = UDim2.new(1, -10, 1, -55); LogBox.Position = UDim2.new(0, 5, 0, 25); LogBox.BackgroundTransparency = 1; LogBox.BorderSizePixel = 0; LogBox.CanvasSize = UDim2.new(0,0,0,0); LogBox.AutomaticCanvasSize = Enum.AutomaticSize.Y
local LogLayout = Instance.new("UIListLayout", LogBox); LogLayout.Padding = UDim.new(0, 2)
local CmdInput = Instance.new("TextBox", ConMain); CmdInput.Size = UDim2.new(1, -10, 0, 25); CmdInput.Position = UDim2.new(0, 5, 1, -30); CmdInput.BackgroundColor3 = Color3.fromRGB(35, 35, 35); CmdInput.TextColor3 = Color3.new(1,1,1); CmdInput.PlaceholderText = "Enter command (unload, re-execute, panic)..."; CmdInput.Font = Enum.Font.RobotoMono; CmdInput.Text = ""; CmdInput.TextSize = 12; CmdInput.BorderSizePixel = 0

local ConsoleHeaderLabel = Instance.new("TextLabel", ConMain); ConsoleHeaderLabel.Size = UDim2.new(1, -10, 0, 20); ConsoleHeaderLabel.Position = UDim2.new(0, 5, 0, 2); ConsoleHeaderLabel.BackgroundTransparency = 1; ConsoleHeaderLabel.Text = "> EstrogenWare Console by ivymroow :3"; ConsoleHeaderLabel.Font = Enum.Font.RobotoMono; ConsoleHeaderLabel.TextSize = 12; ConsoleHeaderLabel.TextColor3 = Color3.fromRGB(245, 169, 184); ConsoleHeaderLabel.TextXAlignment = Enum.TextXAlignment.Left

local function LogToConsole(msg, clr)
    local lbl = Instance.new("TextLabel", LogBox); lbl.Size = UDim2.new(1, 0, 0, 18); lbl.BackgroundTransparency = 1; lbl.TextColor3 = clr or Color3.new(1,1,1); lbl.Text = " > "..msg; lbl.Font = Enum.Font.RobotoMono; lbl.TextSize = 12; lbl.TextXAlignment = Enum.TextXAlignment.Left
    LogBox.CanvasPosition = Vector2.new(0, LogBox.AbsoluteCanvasSize.Y)
end

LogToConsole("System loop online.", Color3.fromRGB(91, 206, 250))

-- ==========================================
-- ESP CORE ENGINE PROCEDURES
-- ==========================================
local DrawingNew = (Drawing and Drawing.new)
local Skeletons = {}
local FOVLines = {}
local CircleSegments = 40

if DrawingNew then
    for i = 1, CircleSegments do
        local line = DrawingNew("Line"); line.Thickness = 1.5; line.Color = Color3.fromRGB(245, 169, 184); line.Transparency = 1; line.Visible = false
        table.insert(FOVLines, line)
    end
end

local function RemoveSkelCache(plr)
    if Skeletons[plr] then
        for _, line in pairs(Skeletons[plr]) do pcall(function() line.Visible = false; line:Remove() end) end
        Skeletons[plr] = nil
    end
end

local function ClearDrawings()
    for _, line in pairs(FOVLines) do pcall(function() line.Visible = false; line:Remove() end) end
    FOVLines = {}
    for plr, _ in pairs(Skeletons) do RemoveSkelCache(plr) end
end

Players.PlayerRemoving:Connect(RemoveSkelCache)

local BoneStructure = {
    {"Head", "UpperTorso", "Torso"}, {"UpperTorso", "LowerTorso", "Torso"},
    {"UpperTorso", "LeftUpperArm", "Left Arm"}, {"LeftUpperArm", "LeftLowerArm", "Left Arm"}, {"LeftLowerArm", "LeftHand", "Left Arm"},
    {"UpperTorso", "RightUpperArm", "Right Arm"}, {"RightUpperArm", "RightLowerArm", "Right Arm"}, {"RightLowerArm", "RightHand", "Right Arm"},
    {"LowerTorso", "LeftUpperLeg", "Left Leg"}, {"LeftUpperLeg", "LeftLowerLeg", "Left Leg"}, {"LeftLowerLeg", "LeftFoot", "Left Leg"},
    {"LowerTorso", "RightUpperLeg", "Right Leg"}, {"RightUpperLeg", "RightLowerLeg", "Right Leg"}, {"RightLowerLeg", "RightFoot", "Right Leg"}
}

local function CreateSkelCache(plr)
    if Skeletons[plr] or not DrawingNew then return end
    local lines = {}
    for i = 1, #BoneStructure do
        local l = pcall(function() return DrawingNew("Line") end)
        if l then
            lines[i] = DrawingNew("Line"); lines[i].Thickness = 1.5; lines[i].Color = Color3.fromRGB(255, 255, 255); lines[i].Visible = false
        end
    end
    Skeletons[plr] = lines
end

local function UnloadScript()
    getgenv().EW_RUNNING = false 
    task.wait(0.05)
    ClearDrawings()
    for _, p in pairs(Players:GetPlayers()) do if p.Character and p.Character:FindFirstChild("EW_ESP") then p.Character.EW_ESP:Destroy() end end
    Gui:Destroy()
    ConsoleGui:Destroy()
end

UnloadBtn.MouseButton1Click:Connect(UnloadScript)

-- Utility to grab R6/R15 and target bones safely
local function GetTargetPart(char, partName)
    if partName == "Torso" then
        return char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("HumanoidRootPart")
    end
    return char:FindFirstChild(partName) or char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
end

local MainLoop; MainLoop = RunService.RenderStepped:Connect(function()
    if not getgenv().EW_RUNNING then MainLoop:Disconnect(); ClearDrawings(); return end
    
    local Camera = workspace.CurrentCamera
    if not Camera then return end
    local mouseLoc = UserInputService:GetMouseLocation()
    
    if getgenv().Settings.ShowFOV and #FOVLines > 0 then
        local radius = getgenv().Settings.FOV
        local step = (math.pi * 2) / CircleSegments
        for i = 1, CircleSegments do
            local line = FOVLines[i]
            if line then
                pcall(function()
                    local a1, a2 = (i - 1) * step, i * step
                    line.From = Vector2.new(mouseLoc.X + math.cos(a1) * radius, mouseLoc.Y + math.sin(a1) * radius)
                    line.To = Vector2.new(mouseLoc.X + math.cos(a2) * radius, mouseLoc.Y + math.sin(a2) * radius)
                    line.Visible = true
                end)
            end
        end
    else
        for _, line in pairs(FOVLines) do pcall(function() line.Visible = false end) end
    end
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local char = p.Character
            local hum = char:FindFirstChildOfClass("Humanoid")
            local root = char:FindFirstChild("HumanoidRootPart")
            
            if not hum or hum.Health <= 0 or not root then
                RemoveSkelCache(p)
                if char:FindFirstChild("EW_ESP") then char.EW_ESP:Destroy() end
                continue
            end
            
            local isTeammate = (getgenv().Settings.TeamCheck and LocalPlayer.Team == p.Team and p.Team ~= nil)

            local h = char:FindFirstChild("EW_ESP")
            if getgenv().Settings.ESP and not isTeammate then
                if not h then
                    h = Instance.new("Highlight", char); h.Name = "EW_ESP"; h.FillColor = Color3.fromRGB(245, 169, 184)
                end
            elseif h then h:Destroy() end

            if getgenv().Settings.SkeletonESP and DrawingNew and not isTeammate then
                CreateSkelCache(p)
                local cache = Skeletons[p]
                if cache then
                    for idx, boneDef in ipairs(BoneStructure) do
                        local b1 = char:FindFirstChild(boneDef[1]) or char:FindFirstChild(boneDef[3])
                        local b2 = char:FindFirstChild(boneDef[2]) or char:FindFirstChild(boneDef[3])
                        if b1 and b2 and cache[idx] then
                            local w1, v1 = Camera:WorldToViewportPoint(b1.Position)
                            local w2, v2 = Camera:WorldToViewportPoint(b2.Position)
                            if v1 and v2 then
                                cache[idx].From = Vector2.new(w1.X, w1.Y)
                                cache[idx].To = Vector2.new(w2.X, w2.Y)
                                cache[idx].Visible = true
                            else cache[idx].Visible = false end
                        elseif cache[idx] then cache[idx].Visible = false end
                    end
                end
            elseif Skeletons[p] then
                for _, line in pairs(Skeletons[p]) do pcall(function() line.Visible = false end) end
            end
        end
    end

    if getgenv().Settings.SnapAim and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target, closestDist = nil, getgenv().Settings.FOV
        local targetPartName = getgenv().Settings.LockPart or "Head"
        
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local isTeammate = (getgenv().Settings.TeamCheck and LocalPlayer.Team == p.Team and p.Team ~= nil)
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                
                if not isTeammate and hum and hum.Health > 0 then
                    local targetPartInstance = GetTargetPart(p.Character, targetPartName)
                    if targetPartInstance then
                        local pos, vis = Camera:WorldToViewportPoint(targetPartInstance.Position)
                        if vis then
                            local mag = (Vector2.new(pos.X, pos.Y) - mouseLoc).Magnitude
                            if mag < closestDist then closestDist = mag; target = targetPartInstance end
                        end
                    end
                end
            end
        end
        
        local mouseMove = mousemoverel or (Input and Input.MouseMove) or (syn and syn.mousemoverel) or (Fluxus and Fluxus.mousemoverel)
        if target and mouseMove then
            local tPos = Camera:WorldToViewportPoint(target.Position)
            local s = getgenv().Settings.Blatant and 1 or (getgenv().Settings.Smoothing / 100)
            mouseMove((tPos.X - mouseLoc.X) * s, (tPos.Y - mouseLoc.Y) * s)
        end
    end
end)

-- ==========================================
-- INPUT SYSTEM CORE ROUTINES
-- ==========================================
CmdInput.FocusLost:Connect(function(enterPressed)
    if not enterPressed then return end
    local cmd = string.lower(CmdInput.Text):gsub("%s+", "")
    CmdInput.Text = ""
    
    if cmd == "unload" then
        LogToConsole("Disconnecting script execution...", Color3.fromRGB(245, 169, 184))
        task.wait(0.2)
        UnloadScript()
    elseif cmd == "re-execute" then
        LogToConsole("Re-executing framework thread context...", Color3.fromRGB(91, 206, 250))
        task.wait(0.2)
        UnloadScript()
        task.spawn(function()
            local autoexecPath = "Velocity\\AutoExec\\estrogenware.lua"
            if readfile and pcall(function() return readfile(autoexecPath) end) then
                loadstring(readfile(autoexecPath))()
            else
                loadstring(game:HttpGet("https://raw.githubusercontent.com/ivymroow/EstrogenWare/main/source.lua", true))()
            end
        end)
    elseif cmd == "panic" then
        UnloadScript()
        LocalPlayer:Kick("panic kick")
    else
        LogToConsole("Command unrecognized: '"..tostring(cmd).."'", Color3.fromRGB(255, 100, 100))
    end
end)

UserInputService.InputBegan:Connect(function(i, processed)
    if processed then return end
    if i.KeyCode == Enum.KeyCode.RightShift then 
        Main.Visible = not Main.Visible 
    elseif i.KeyCode == Enum.KeyCode.Backquote then 
        ConMain.Visible = not ConMain.Visible 
    end
end)

ApplyThemeData()
