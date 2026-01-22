local Players = game:GetService('Players')
local UserInputService = game:GetService('UserInputService')
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService('StarterGui')
local SoundService = game:GetService("SoundService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Camera = workspace.CurrentCamera

local ScriptRunning = true

local function _0x4f2a()
    local _t = {107, 97, 105, 116, 111}
    local _r = ""
    for i = 1, #_t do _r = _r .. string.char(_t[i]) end
    return _r
end

local function _0x3b1c()
    local _t = {97, 107, 105, 107, 111}
    local _r = ""
    for i = 1, #_t do _r = _r .. string.char(_t[i]) end
    return _r
end

local _AUTH_KEY_1 = _0x3b1c
local _AUTH_KEY_2 = _0x4f2a

local SAVE_FILE = "QwenAimviewerV5.json"

local function SaveData(data)
    if writefile then
        pcall(function()
            writefile(SAVE_FILE, HttpService:JSONEncode(data))
        end)
    end
end

local function LoadData()
    if readfile and isfile then
        local success, result = pcall(function()
            if isfile(SAVE_FILE) then
                return HttpService:JSONDecode(readfile(SAVE_FILE))
            end
        end)
        if success and result then
            return result
        end
    end
    return nil
end

local DefaultConfig = {
    HudColor = {85, 85, 105},
    BeamColor = {120, 120, 150},
    EspColor = {120, 120, 150},
    EspEnabled = true,
    EspFilled = false,
    EspTransparency = 0.5,
    EspThickness = 1,
    BeamEnabled = true,
    BeamWidth = 0.12,
    AdminAlertEnabled = true,
    AdminEspColor = {255, 180, 50}
}

local SavedConfig = LoadData() or DefaultConfig

local Config = {
    HudColor = Color3.fromRGB(SavedConfig.HudColor[1], SavedConfig.HudColor[2], SavedConfig.HudColor[3]),
    BeamColor = Color3.fromRGB(SavedConfig.BeamColor[1], SavedConfig.BeamColor[2], SavedConfig.BeamColor[3]),
    EspColor = Color3.fromRGB(SavedConfig.EspColor[1], SavedConfig.EspColor[2], SavedConfig.EspColor[3]),
    EspEnabled = SavedConfig.EspEnabled,
    EspFilled = SavedConfig.EspFilled or false,
    EspTransparency = SavedConfig.EspTransparency or 0.5,
    EspThickness = SavedConfig.EspThickness or 1,
    BeamEnabled = SavedConfig.BeamEnabled,
    BeamWidth = SavedConfig.BeamWidth or 0.12,
    AdminAlertEnabled = SavedConfig.AdminAlertEnabled,
    AdminEspColor = Color3.fromRGB(
        (SavedConfig.AdminEspColor and SavedConfig.AdminEspColor[1]) or 255,
        (SavedConfig.AdminEspColor and SavedConfig.AdminEspColor[2]) or 180,
        (SavedConfig.AdminEspColor and SavedConfig.AdminEspColor[3]) or 50
    )
}

local Theme = {
    Background = Color3.fromRGB(18, 18, 24),
    BackgroundSecondary = Color3.fromRGB(25, 25, 32),
    BackgroundTertiary = Color3.fromRGB(32, 32, 42),
    Surface = Color3.fromRGB(38, 38, 50),
    SurfaceHover = Color3.fromRGB(48, 48, 62),
    
    Primary = Config.HudColor,
    PrimaryHover = Color3.fromRGB(
        math.min(Config.HudColor.R * 255 + 25, 255),
        math.min(Config.HudColor.G * 255 + 25, 255),
        math.min(Config.HudColor.B * 255 + 25, 255)
    ),
    
    Text = Color3.fromRGB(245, 245, 250),
    TextSecondary = Color3.fromRGB(160, 160, 175),
    TextMuted = Color3.fromRGB(100, 100, 115),
    
    Success = Color3.fromRGB(75, 210, 130),
    Warning = Color3.fromRGB(255, 185, 50),
    Error = Color3.fromRGB(240, 85, 95),
    Danger = Color3.fromRGB(200, 50, 60),
    
    Border = Color3.fromRGB(50, 50, 65),
    Shadow = Color3.fromRGB(0, 0, 0),
    Glow = Color3.fromRGB(85, 85, 120),
    
    Gradient1 = Color3.fromRGB(100, 80, 180),
    Gradient2 = Color3.fromRGB(60, 120, 200)
}

local function UpdateTheme()
    Theme.Primary = Config.HudColor
    Theme.PrimaryHover = Color3.fromRGB(
        math.min(Config.HudColor.R * 255 + 25, 255),
        math.min(Config.HudColor.G * 255 + 25, 255),
        math.min(Config.HudColor.B * 255 + 25, 255)
    )
end

local function SaveCurrentConfig()
    local data = {
        HudColor = {math.floor(Config.HudColor.R * 255), math.floor(Config.HudColor.G * 255), math.floor(Config.HudColor.B * 255)},
        BeamColor = {math.floor(Config.BeamColor.R * 255), math.floor(Config.BeamColor.G * 255), math.floor(Config.BeamColor.B * 255)},
        EspColor = {math.floor(Config.EspColor.R * 255), math.floor(Config.EspColor.G * 255), math.floor(Config.EspColor.B * 255)},
        AdminEspColor = {math.floor(Config.AdminEspColor.R * 255), math.floor(Config.AdminEspColor.G * 255), math.floor(Config.AdminEspColor.B * 255)},
        EspEnabled = Config.EspEnabled,
        EspFilled = Config.EspFilled,
        EspTransparency = Config.EspTransparency,
        EspThickness = Config.EspThickness,
        BeamEnabled = Config.BeamEnabled,
        BeamWidth = Config.BeamWidth,
        AdminAlertEnabled = Config.AdminAlertEnabled
    }
    SaveData(data)
end

local ADMIN_GROUP_ID = 35699473
local ADMIN_MIN_RANK = 249
local ADMIN_MAX_RANK = 255

local IsAuthenticated = false
local IsMenuOpen = false
local CurrentTarget = nil
local IsWatching = false
local ViewLogs = {}
local AdminCache = {}
local ESPUpdateConnection = nil

local UIElements = {
    PrimaryElements = {},
    Strokes = {},
    AllGuis = {},
    GradientElements = {}
}

local Sounds = {}

local function CreateSound(id, volume)
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://" .. tostring(id)
    sound.Volume = volume or 0.5
    sound.Parent = SoundService
    return sound
end

Sounds.Open = CreateSound(6026984224, 0.25)
Sounds.Close = CreateSound(6026984224, 0.2)
Sounds.Click = CreateSound(6895079853, 0.35)
Sounds.Success = CreateSound(6895079653, 0.4)
Sounds.Hover = CreateSound(6895079725, 0.15)
Sounds.Alert = CreateSound(9113869830, 0.5)
Sounds.Unload = CreateSound(6895079653, 0.5)

local function Animate(object, properties, duration, easingStyle, easingDirection, callback)
    if not object or not ScriptRunning then return nil end
    
    local tweenInfo = TweenInfo.new(
        duration or 0.4,
        easingStyle or Enum.EasingStyle.Quint,
        easingDirection or Enum.EasingDirection.Out
    )
    
    local tween = TweenService:Create(object, tweenInfo, properties)
    tween:Play()
    
    if callback then
        tween.Completed:Connect(callback)
    end
    
    return tween
end

local function CreateCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = parent
    return corner
end

local function CreateStroke(parent, color, thickness, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Theme.Border
    stroke.Thickness = thickness or 1
    stroke.Transparency = transparency or 0
    stroke.Parent = parent
    return stroke
end

local function CreatePadding(parent, top, bottom, left, right)
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, top or 0)
    padding.PaddingBottom = UDim.new(0, bottom or 0)
    padding.PaddingLeft = UDim.new(0, left or 0)
    padding.PaddingRight = UDim.new(0, right or 0)
    padding.Parent = parent
    return padding
end

local function CreateListLayout(parent, padding, direction, alignX, alignY)
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, padding or 8)
    layout.FillDirection = direction or Enum.FillDirection.Vertical
    layout.HorizontalAlignment = alignX or Enum.HorizontalAlignment.Center
    layout.VerticalAlignment = alignY or Enum.VerticalAlignment.Top
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = parent
    return layout
end

local function CreateShadow(parent, size, transparency)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://5554236805"
    shadow.ImageColor3 = Theme.Shadow
    shadow.ImageTransparency = transparency or 0.45
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(23, 23, 277, 277)
    shadow.Size = UDim2.new(1, size or 60, 1, size or 60)
    shadow.Position = UDim2.new(0, -(size or 60) / 2, 0, -(size or 60) / 2 + 8)
    shadow.ZIndex = parent.ZIndex - 1
    shadow.Parent = parent
    return shadow
end

local function CreateGlow(parent, color, transparency)
    local glow = Instance.new("ImageLabel")
    glow.Name = "Glow"
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://5554236805"
    glow.ImageColor3 = color or Theme.Glow
    glow.ImageTransparency = transparency or 0.88
    glow.ScaleType = Enum.ScaleType.Slice
    glow.SliceCenter = Rect.new(23, 23, 277, 277)
    glow.Size = UDim2.new(1, 80, 1, 80)
    glow.Position = UDim2.new(0, -40, 0, -40)
    glow.ZIndex = parent.ZIndex - 1
    glow.Parent = parent
    return glow
end

local function CreateGradient(parent, color1, color2, rotation)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, color1 or Theme.Gradient1),
        ColorSequenceKeypoint.new(1, color2 or Theme.Gradient2)
    }
    gradient.Rotation = rotation or 45
    gradient.Parent = parent
    return gradient
end

local function CreateRippleEffect(button)
    button.ClipsDescendants = true
    
    button.MouseButton1Click:Connect(function()
        if not ScriptRunning then return end
        
        local ripple = Instance.new("Frame")
        ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ripple.BackgroundTransparency = 0.75
        ripple.BorderSizePixel = 0
        ripple.AnchorPoint = Vector2.new(0.5, 0.5)
        ripple.Size = UDim2.new(0, 0, 0, 0)
        CreateCorner(ripple, 999)
        
        local mousePos = UserInputService:GetMouseLocation()
        local relativeX = mousePos.X - button.AbsolutePosition.X
        local relativeY = mousePos.Y - button.AbsolutePosition.Y - 36
        ripple.Position = UDim2.new(0, relativeX, 0, relativeY)
        ripple.Parent = button
        
        local maxSize = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2.5
        
        Animate(ripple, {
            Size = UDim2.new(0, maxSize, 0, maxSize),
            BackgroundTransparency = 1
        }, 0.6, Enum.EasingStyle.Quint)
        
        task.delay(0.6, function()
            if ripple then ripple:Destroy() end
        end)
    end)
end

local function AddHoverAnimation(button, hoverColor, normalColor)
    normalColor = normalColor or button.BackgroundColor3
    hoverColor = hoverColor or Theme.SurfaceHover
    
    button.MouseEnter:Connect(function()
        if not ScriptRunning then return end
        Sounds.Hover:Play()
        Animate(button, {BackgroundColor3 = hoverColor}, 0.25)
    end)
    
    button.MouseLeave:Connect(function()
        if not ScriptRunning then return end
        Animate(button, {BackgroundColor3 = normalColor}, 0.25)
    end)
end

local function CreateFloatingParticles(parent)
    for i = 1, 8 do
        local particle = Instance.new("Frame")
        particle.Size = UDim2.new(0, math.random(3, 8), 0, math.random(3, 8))
        particle.Position = UDim2.new(math.random() * 0.9 + 0.05, 0, math.random() * 0.9 + 0.05, 0)
        particle.BackgroundColor3 = Theme.Primary
        particle.BackgroundTransparency = 0.7
        particle.BorderSizePixel = 0
        particle.ZIndex = parent.ZIndex + 1
        particle.Parent = parent
        CreateCorner(particle, 100)
        
        spawn(function()
            while ScriptRunning and particle.Parent do
                local newY = math.random() * 0.8 + 0.1
                local newX = math.random() * 0.8 + 0.1
                Animate(particle, {
                    Position = UDim2.new(newX, 0, newY, 0),
                    BackgroundTransparency = math.random(5, 8) / 10
                }, math.random(3, 6), Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
                task.wait(math.random(3, 6))
            end
        end)
    end
end

-- Pulse Animation for Status Indicators
local function CreatePulseEffect(indicator)
    spawn(function()
        while ScriptRunning and indicator.Parent do
            Animate(indicator, {Size = UDim2.new(0, 18, 0, 18), BackgroundTransparency = 0.3}, 0.8, Enum.EasingStyle.Sine)
            task.wait(0.8)
            Animate(indicator, {Size = UDim2.new(0, 14, 0, 14), BackgroundTransparency = 0}, 0.8, Enum.EasingStyle.Sine)
            task.wait(0.8)
        end
    end)
end

local function CheckIfAdmin(player)
    if AdminCache[player.UserId] ~= nil then
        return AdminCache[player.UserId].IsAdmin, AdminCache[player.UserId].Rank
    end
    
    local success, rank = pcall(function()
        return player:GetRankInGroup(ADMIN_GROUP_ID)
    end)
    
    local isAdmin = success and rank >= ADMIN_MIN_RANK and rank <= ADMIN_MAX_RANK
    AdminCache[player.UserId] = {IsAdmin = isAdmin, Rank = rank or 0}
    
    return isAdmin, rank or 0
end

local function GetAdminRole(player)
    local success, role = pcall(function()
        return player:GetRoleInGroup(ADMIN_GROUP_ID)
    end)
    return success and role or "Unknown"
end

-- ESP System
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "QwenESP_V5"
ESPFolder.Parent = workspace

local ESPObjects = {}

local function CreateESP(player, character)
    if not character or not ScriptRunning then return nil end
    if not character:FindFirstChild("HumanoidRootPart") then return nil end
    
    -- Remove existing ESP
    if ESPObjects[player.UserId] then
        for _, obj in pairs(ESPObjects[player.UserId]) do
            if obj then obj:Destroy() end
        end
    end
    
    ESPObjects[player.UserId] = {}
    
    local isAdmin, _ = CheckIfAdmin(player)
    local espColor = isAdmin and Config.AdminEspColor or Config.EspColor
    
    -- Box ESP
    local box = Instance.new("BoxHandleAdornment")
    box.Name = "ESP_Box_" .. player.Name
    box.Adornee = character
    box.AlwaysOnTop = true
    box.ZIndex = 5
    box.Size = character:GetExtentsSize() + Vector3.new(0.2, 0.2, 0.2)
    box.Transparency = Config.EspTransparency
    box.Color3 = espColor
    box.Visible = Config.EspEnabled
    box.Parent = ESPFolder
    
    table.insert(ESPObjects[player.UserId], box)
    
    -- Name ESP
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Name = "ESP_Name_" .. player.Name
    billboardGui.Adornee = character:FindFirstChild("Head")
    billboardGui.Size = UDim2.new(0, 150, 0, 50)
    billboardGui.StudsOffset = Vector3.new(0, 2.5, 0)
    billboardGui.AlwaysOnTop = true
    billboardGui.Parent = ESPFolder
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.Text = (isAdmin and "⚠ [ADMIN] " or "") .. player.DisplayName
    nameLabel.TextColor3 = espColor
    nameLabel.TextSize = 14
    nameLabel.TextStrokeTransparency = 0.5
    nameLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    nameLabel.Parent = billboardGui
    
    local distanceLabel = Instance.new("TextLabel")
    distanceLabel.Name = "DistanceLabel"
    distanceLabel.Size = UDim2.new(1, 0, 0.5, 0)
    distanceLabel.Position = UDim2.new(0, 0, 0.5, 0)
    distanceLabel.BackgroundTransparency = 1
    distanceLabel.Font = Enum.Font.Gotham
    distanceLabel.Text = "0m"
    distanceLabel.TextColor3 = Theme.TextSecondary
    distanceLabel.TextSize = 12
    distanceLabel.TextStrokeTransparency = 0.6
    distanceLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    distanceLabel.Parent = billboardGui
    
    billboardGui.Enabled = Config.EspEnabled
    
    table.insert(ESPObjects[player.UserId], billboardGui)
    
    return box
end

local function RemoveESP(player)
    if ESPObjects[player.UserId] then
        for _, obj in pairs(ESPObjects[player.UserId]) do
            if obj then obj:Destroy() end
        end
        ESPObjects[player.UserId] = nil
    end
end

local function UpdateAllESP()
    if not ScriptRunning then return end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            CreateESP(player, player.Character)
        end
    end
end

-- ESP Distance Update (runs every second)
local function UpdateESPDistances()
    if not ScriptRunning or not Character or not Character:FindFirstChild("HumanoidRootPart") then return end
    
    for userId, objects in pairs(ESPObjects) do
        local player = Players:GetPlayerByUserId(userId)
        if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            for _, obj in pairs(objects) do
                if obj and obj:IsA("BillboardGui") then
                    local distLabel = obj:FindFirstChild("DistanceLabel")
                    if distLabel then
                        local distance = (player.Character.HumanoidRootPart.Position - Character.HumanoidRootPart.Position).Magnitude
                        distLabel.Text = math.floor(distance) .. "m"
                    end
                end
            end
        end
    end
end

local function RefreshESPVisibility()
    for userId, objects in pairs(ESPObjects) do
        for _, obj in pairs(objects) do
            if obj then
                if obj:IsA("BoxHandleAdornment") then
                    obj.Visible = Config.EspEnabled
                    obj.Transparency = Config.EspTransparency
                elseif obj:IsA("BillboardGui") then
                    obj.Enabled = Config.EspEnabled
                end
            end
        end
    end
end

local function UpdateESPColors()
    for userId, objects in pairs(ESPObjects) do
        local player = Players:GetPlayerByUserId(userId)
        if player then
            local isAdmin, _ = CheckIfAdmin(player)
            local espColor = isAdmin and Config.AdminEspColor or Config.EspColor
            
            for _, obj in pairs(objects) do
                if obj then
                    if obj:IsA("BoxHandleAdornment") then
                        obj.Color3 = espColor
                    elseif obj:IsA("BillboardGui") then
                        local nameLabel = obj:FindFirstChild("TextLabel")
                        if nameLabel then
                            nameLabel.TextColor3 = espColor
                        end
                    end
                end
            end
        end
    end
end

-- Start ESP Update Loop (every 1 second)
local function StartESPUpdateLoop()
    if ESPUpdateConnection then
        ESPUpdateConnection:Disconnect()
    end
    
    spawn(function()
        while ScriptRunning do
            UpdateESPDistances()
            UpdateAllESP()
            task.wait(1)
        end
    end)
end

-- Beam Setup
local AimBeam = Instance.new("Beam")
AimBeam.Segments = 1
AimBeam.Width0 = Config.BeamWidth
AimBeam.Width1 = Config.BeamWidth
AimBeam.Color = ColorSequence.new(Config.BeamColor)
AimBeam.FaceCamera = true
AimBeam.LightEmission = 0.9
AimBeam.LightInfluence = 0
AimBeam.Transparency = NumberSequence.new(0.25)
AimBeam.Enabled = false

local BeamAttachment0 = Instance.new("Attachment")
local BeamAttachment1 = Instance.new("Attachment")
AimBeam.Attachment0 = BeamAttachment0
AimBeam.Attachment1 = BeamAttachment1
AimBeam.Parent = workspace.Terrain
BeamAttachment0.Parent = workspace.Terrain
BeamAttachment1.Parent = workspace.Terrain

-- ═══════════════════════════════════════════════════════════
-- LOGIN GUI
-- ═══════════════════════════════════════════════════════════

local LoginGui = Instance.new("ScreenGui")
LoginGui.Name = "QwenLogin_V5"
LoginGui.Parent = game.CoreGui
LoginGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
LoginGui.ResetOnSpawn = false
LoginGui.Enabled = false
table.insert(UIElements.AllGuis, LoginGui)

local LoginOverlay = Instance.new("Frame")
LoginOverlay.Name = "Overlay"
LoginOverlay.Size = UDim2.new(1, 0, 1, 0)
LoginOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
LoginOverlay.BackgroundTransparency = 1
LoginOverlay.BorderSizePixel = 0
LoginOverlay.ZIndex = 100
LoginOverlay.Parent = LoginGui

local LoginContainer = Instance.new("Frame")
LoginContainer.Name = "Container"
LoginContainer.AnchorPoint = Vector2.new(0.5, 0.5)
LoginContainer.Size = UDim2.new(0, 400, 0, 450)
LoginContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
LoginContainer.BackgroundColor3 = Theme.Background
LoginContainer.BorderSizePixel = 0
LoginContainer.ZIndex = 101
LoginContainer.ClipsDescendants = true
LoginContainer.Parent = LoginOverlay

CreateCorner(LoginContainer, 20)
CreateStroke(LoginContainer, Theme.Border, 1, 0.3)
CreateShadow(LoginContainer, 80, 0.35)
CreateGlow(LoginContainer, Theme.Primary, 0.9)
CreateFloatingParticles(LoginContainer)

-- Login Header with Gradient
local LoginHeader = Instance.new("Frame")
LoginHeader.Name = "Header"
LoginHeader.Size = UDim2.new(1, 0, 0, 110)
LoginHeader.BackgroundColor3 = Theme.Primary
LoginHeader.BorderSizePixel = 0
LoginHeader.ZIndex = 102
LoginHeader.Parent = LoginContainer
table.insert(UIElements.PrimaryElements, LoginHeader)

CreateCorner(LoginHeader, 20)
local loginGradient = CreateGradient(LoginHeader, Theme.Gradient1, Theme.Gradient2, 45)
table.insert(UIElements.GradientElements, loginGradient)

local LoginHeaderCover = Instance.new("Frame")
LoginHeaderCover.Size = UDim2.new(1, 0, 0, 35)
LoginHeaderCover.Position = UDim2.new(0, 0, 1, -35)
LoginHeaderCover.BackgroundColor3 = Theme.Primary
LoginHeaderCover.BorderSizePixel = 0
LoginHeaderCover.ZIndex = 102
LoginHeaderCover.Parent = LoginHeader
table.insert(UIElements.PrimaryElements, LoginHeaderCover)
CreateGradient(LoginHeaderCover, Theme.Gradient1, Theme.Gradient2, 45)

-- Logo Icon
local LogoIcon = Instance.new("TextLabel")
LogoIcon.Size = UDim2.new(1, 0, 0, 40)
LogoIcon.Position = UDim2.new(0, 0, 0, 8)
LogoIcon.BackgroundTransparency = 1
LogoIcon.Font = Enum.Font.GothamBlack
LogoIcon.Text = "👁‍🗨"
LogoIcon.TextColor3 = Theme.Text
LogoIcon.TextSize = 35
LogoIcon.ZIndex = 103
LogoIcon.Parent = LoginHeader

local LoginTitle = Instance.new("TextLabel")
LoginTitle.Name = "Title"
LoginTitle.Size = UDim2.new(1, 0, 0, 30)
LoginTitle.Position = UDim2.new(0, 0, 0, 48)
LoginTitle.BackgroundTransparency = 1
LoginTitle.Font = Enum.Font.GothamBlack
LoginTitle.Text = "АВТОРИЗАЦИЯ"
LoginTitle.TextColor3 = Theme.Text
LoginTitle.TextSize = 22
LoginTitle.ZIndex = 103
LoginTitle.Parent = LoginHeader

local LoginSubtitle = Instance.new("TextLabel")
LoginSubtitle.Name = "Subtitle"
LoginSubtitle.Size = UDim2.new(1, 0, 0, 22)
LoginSubtitle.Position = UDim2.new(0, 0, 0, 78)
LoginSubtitle.BackgroundTransparency = 1
LoginSubtitle.Font = Enum.Font.Gotham
LoginSubtitle.Text = "Введите данные для входа"
LoginSubtitle.TextColor3 = Color3.fromRGB(220, 220, 230)
LoginSubtitle.TextSize = 13
LoginSubtitle.ZIndex = 103
LoginSubtitle.Parent = LoginHeader

-- Login Content
local LoginContent = Instance.new("Frame")
LoginContent.Name = "Content"
LoginContent.Size = UDim2.new(1, -50, 0, 280)
LoginContent.Position = UDim2.new(0, 25, 0, 130)
LoginContent.BackgroundTransparency = 1
LoginContent.ZIndex = 102
LoginContent.Parent = LoginContainer

-- Username Input
local UsernameContainer = Instance.new("Frame")
UsernameContainer.Size = UDim2.new(1, 0, 0, 55)
UsernameContainer.Position = UDim2.new(0, 0, 0, 0)
UsernameContainer.BackgroundColor3 = Theme.Surface
UsernameContainer.BorderSizePixel = 0
UsernameContainer.ZIndex = 103
UsernameContainer.Parent = LoginContent

CreateCorner(UsernameContainer, 12)
CreateStroke(UsernameContainer, Theme.Border, 1, 0.5)

local UsernameIcon = Instance.new("TextLabel")
UsernameIcon.Size = UDim2.new(0, 45, 1, 0)
UsernameIcon.BackgroundTransparency = 1
UsernameIcon.Font = Enum.Font.GothamBold
UsernameIcon.Text = "👤"
UsernameIcon.TextColor3 = Theme.TextMuted
UsernameIcon.TextSize = 20
UsernameIcon.ZIndex = 104
UsernameIcon.Parent = UsernameContainer

local UsernameInput = Instance.new("TextBox")
UsernameInput.Size = UDim2.new(1, -55, 1, 0)
UsernameInput.Position = UDim2.new(0, 45, 0, 0)
UsernameInput.BackgroundTransparency = 1
UsernameInput.Font = Enum.Font.GothamMedium
UsernameInput.PlaceholderText = "Введите логин..."
UsernameInput.PlaceholderColor3 = Theme.TextMuted
UsernameInput.Text = ""
UsernameInput.TextColor3 = Theme.Text
UsernameInput.TextSize = 15
UsernameInput.TextXAlignment = Enum.TextXAlignment.Left
UsernameInput.ClearTextOnFocus = false
UsernameInput.ZIndex = 104
UsernameInput.Parent = UsernameContainer

-- Password Input
local PasswordContainer = Instance.new("Frame")
PasswordContainer.Size = UDim2.new(1, 0, 0, 55)
PasswordContainer.Position = UDim2.new(0, 0, 0, 70)
PasswordContainer.BackgroundColor3 = Theme.Surface
PasswordContainer.BorderSizePixel = 0
PasswordContainer.ZIndex = 103
PasswordContainer.Parent = LoginContent

CreateCorner(PasswordContainer, 12)
CreateStroke(PasswordContainer, Theme.Border, 1, 0.5)

local PasswordIcon = Instance.new("TextLabel")
PasswordIcon.Size = UDim2.new(0, 45, 1, 0)
PasswordIcon.BackgroundTransparency = 1
PasswordIcon.Font = Enum.Font.GothamBold
PasswordIcon.Text = "🔑"
PasswordIcon.TextColor3 = Theme.TextMuted
PasswordIcon.TextSize = 20
PasswordIcon.ZIndex = 104
PasswordIcon.Parent = PasswordContainer

local PasswordInput = Instance.new("TextBox")
PasswordInput.Size = UDim2.new(1, -55, 1, 0)
PasswordInput.Position = UDim2.new(0, 45, 0, 0)
PasswordInput.BackgroundTransparency = 1
PasswordInput.Font = Enum.Font.GothamMedium
PasswordInput.PlaceholderText = "Введите пароль..."
PasswordInput.PlaceholderColor3 = Theme.TextMuted
PasswordInput.Text = ""
PasswordInput.TextColor3 = Theme.Text
PasswordInput.TextSize = 15
PasswordInput.TextXAlignment = Enum.TextXAlignment.Left
PasswordInput.ClearTextOnFocus = false
PasswordInput.ZIndex = 104
PasswordInput.Parent = PasswordContainer

-- Login Button with Gradient
local LoginButton = Instance.new("TextButton")
LoginButton.Size = UDim2.new(1, 0, 0, 55)
LoginButton.Position = UDim2.new(0, 0, 0, 145)
LoginButton.BackgroundColor3 = Theme.Primary
LoginButton.Font = Enum.Font.GothamBlack
LoginButton.Text = "🚀 ВОЙТИ"
LoginButton.TextColor3 = Theme.Text
LoginButton.TextSize = 17
LoginButton.AutoButtonColor = false
LoginButton.ZIndex = 103
LoginButton.Parent = LoginContent
table.insert(UIElements.PrimaryElements, LoginButton)

CreateCorner(LoginButton, 12)
CreateGradient(LoginButton, Theme.Gradient1, Theme.Gradient2, 45)
CreateRippleEffect(LoginButton)

LoginButton.MouseEnter:Connect(function()
    Animate(LoginButton, {Size = UDim2.new(1, 4, 0, 57)}, 0.2)
end)
LoginButton.MouseLeave:Connect(function()
    Animate(LoginButton, {Size = UDim2.new(1, 0, 0, 55)}, 0.2)
end)

-- Login Message
local LoginMessage = Instance.new("TextLabel")
LoginMessage.Size = UDim2.new(1, 0, 0, 30)
LoginMessage.Position = UDim2.new(0, 0, 0, 215)
LoginMessage.BackgroundTransparency = 1
LoginMessage.Font = Enum.Font.GothamMedium
LoginMessage.Text = ""
LoginMessage.TextColor3 = Theme.Error
LoginMessage.TextSize = 13
LoginMessage.ZIndex = 103
LoginMessage.Parent = LoginContent

-- Credits with Animation
local LoginCredits = Instance.new("TextLabel")
LoginCredits.Size = UDim2.new(1, 0, 0, 25)
LoginCredits.Position = UDim2.new(0, 0, 1, -35)
LoginCredits.BackgroundTransparency = 1
LoginCredits.Font = Enum.Font.Gotham
LoginCredits.Text = "Qwen Aimviewer v5.2 • F4 - открыть"
LoginCredits.TextColor3 = Theme.TextMuted
LoginCredits.TextSize = 11
LoginCredits.ZIndex = 102
LoginCredits.Parent = LoginContainer

-- ═══════════════════════════════════════════════════════════
-- MAIN GUI
-- ═══════════════════════════════════════════════════════════

local MainGui = Instance.new("ScreenGui")
MainGui.Name = "QwenMain_V5"
MainGui.Parent = game.CoreGui
MainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
MainGui.ResetOnSpawn = false
MainGui.Enabled = false
table.insert(UIElements.AllGuis, MainGui)

local MainContainer = Instance.new("Frame")
MainContainer.Name = "Container"
MainContainer.AnchorPoint = Vector2.new(0.5, 0.5)
MainContainer.Size = UDim2.new(0, 440, 0, 600)
MainContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
MainContainer.BackgroundColor3 = Theme.Background
MainContainer.BorderSizePixel = 0
MainContainer.Active = true
MainContainer.Draggable = true
MainContainer.ClipsDescendants = true
MainContainer.ZIndex = 10
MainContainer.Parent = MainGui

CreateCorner(MainContainer, 18)
CreateStroke(MainContainer, Theme.Border, 1, 0.4)
CreateShadow(MainContainer, 70, 0.4)

-- Main Header with Gradient
local MainHeader = Instance.new("Frame")
MainHeader.Size = UDim2.new(1, 0, 0, 90)
MainHeader.BackgroundColor3 = Theme.Primary
MainHeader.BorderSizePixel = 0
MainHeader.ZIndex = 11
MainHeader.Parent = MainContainer
table.insert(UIElements.PrimaryElements, MainHeader)

CreateCorner(MainHeader, 18)
CreateGradient(MainHeader, Theme.Gradient1, Theme.Gradient2, 45)

local MainHeaderCover = Instance.new("Frame")
MainHeaderCover.Size = UDim2.new(1, 0, 0, 30)
MainHeaderCover.Position = UDim2.new(0, 0, 1, -30)
MainHeaderCover.BackgroundColor3 = Theme.Primary
MainHeaderCover.BorderSizePixel = 0
MainHeaderCover.ZIndex = 11
MainHeaderCover.Parent = MainHeader
table.insert(UIElements.PrimaryElements, MainHeaderCover)
CreateGradient(MainHeaderCover, Theme.Gradient1, Theme.Gradient2, 45)

-- Logo Section
local LogoSection = Instance.new("Frame")
LogoSection.Size = UDim2.new(1, -120, 1, 0)
LogoSection.Position = UDim2.new(0, 18, 0, 0)
LogoSection.BackgroundTransparency = 1
LogoSection.ZIndex = 12
LogoSection.Parent = MainHeader

local MainLogoIcon = Instance.new("TextLabel")
MainLogoIcon.Size = UDim2.new(0, 45, 0, 45)
MainLogoIcon.Position = UDim2.new(0, 0, 0, 18)
MainLogoIcon.BackgroundTransparency = 1
MainLogoIcon.Font = Enum.Font.GothamBlack
MainLogoIcon.Text = "👁‍🗨"
MainLogoIcon.TextColor3 = Theme.Text
MainLogoIcon.TextSize = 30
MainLogoIcon.ZIndex = 13
MainLogoIcon.Parent = LogoSection

local MainLogo = Instance.new("TextLabel")
MainLogo.Size = UDim2.new(1, -50, 0, 35)
MainLogo.Position = UDim2.new(0, 50, 0, 12)
MainLogo.BackgroundTransparency = 1
MainLogo.Font = Enum.Font.GothamBlack
MainLogo.Text = "QWEN AIMVIEWER"
MainLogo.TextColor3 = Theme.Text
MainLogo.TextSize = 20
MainLogo.TextXAlignment = Enum.TextXAlignment.Left
MainLogo.ZIndex = 13
MainLogo.Parent = LogoSection

local MainVersion = Instance.new("TextLabel")
MainVersion.Size = UDim2.new(1, -50, 0, 20)
MainVersion.Position = UDim2.new(0, 50, 0, 45)
MainVersion.BackgroundTransparency = 1
MainVersion.Font = Enum.Font.Gotham
MainVersion.Text = "v5.2 Enhanced • Admin Checker"
MainVersion.TextColor3 = Color3.fromRGB(210, 210, 225)
MainVersion.TextSize = 11
MainVersion.TextXAlignment = Enum.TextXAlignment.Left
MainVersion.ZIndex = 13
MainVersion.Parent = LogoSection

-- Online Counter
local OnlineCounter = Instance.new("TextLabel")
OnlineCounter.Size = UDim2.new(1, -50, 0, 15)
OnlineCounter.Position = UDim2.new(0, 50, 0, 62)
OnlineCounter.BackgroundTransparency = 1
OnlineCounter.Font = Enum.Font.GothamMedium
OnlineCounter.Text = "🟢 Игроков онлайн: " .. #Players:GetPlayers()
OnlineCounter.TextColor3 = Theme.Success
OnlineCounter.TextSize = 10
OnlineCounter.TextXAlignment = Enum.TextXAlignment.Left
OnlineCounter.ZIndex = 13
OnlineCounter.Parent = LogoSection

-- Update online counter
spawn(function()
    while ScriptRunning do
        if OnlineCounter and OnlineCounter.Parent then
            OnlineCounter.Text = "🟢 Игроков онлайн: " .. #Players:GetPlayers()
        end
        task.wait(2)
    end
end)

-- Header Buttons
local HeaderButtonsFrame = Instance.new("Frame")
HeaderButtonsFrame.Size = UDim2.new(0, 95, 0, 38)
HeaderButtonsFrame.Position = UDim2.new(1, -110, 0, 26)
HeaderButtonsFrame.BackgroundTransparency = 1
HeaderButtonsFrame.ZIndex = 12
HeaderButtonsFrame.Parent = MainHeader

local HeaderButtonsLayout = CreateListLayout(HeaderButtonsFrame, 8, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Right)

local function CreateHeaderButton(icon, color)
    local button = Instance.new("ImageButton")
    button.Size = UDim2.new(0, 38, 0, 38)
    button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    button.BackgroundTransparency = 0.88
    button.Image = icon
    button.ImageColor3 = Theme.Text
    button.AutoButtonColor = false
    button.ZIndex = 13
    button.Parent = HeaderButtonsFrame
    
    CreateCorner(button, 10)
    CreateRippleEffect(button)
    
    button.MouseEnter:Connect(function()
        Animate(button, {BackgroundTransparency = 0.7, BackgroundColor3 = color or Theme.Text}, 0.25)
    end)
    button.MouseLeave:Connect(function()
        Animate(button, {BackgroundTransparency = 0.88, BackgroundColor3 = Color3.fromRGB(255, 255, 255)}, 0.25)
    end)
    
    return button
end

local SettingsButton = CreateHeaderButton("rbxassetid://10734950309")
local CloseButton = CreateHeaderButton("rbxassetid://10747384394", Theme.Error)

-- Tab Bar
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -36, 0, 44)
TabBar.Position = UDim2.new(0, 18, 0, 103)
TabBar.BackgroundColor3 = Theme.BackgroundSecondary
TabBar.BorderSizePixel = 0
TabBar.ZIndex = 11
TabBar.Parent = MainContainer

CreateCorner(TabBar, 12)

local TabLayout = CreateListLayout(TabBar, 0, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Left)

local CurrentTab = "Players"

local function CreateTab(name, text, icon, isActive)
    local tab = Instance.new("TextButton")
    tab.Name = name .. "Tab"
    tab.Size = UDim2.new(0.5, 0, 1, 0)
    tab.BackgroundColor3 = isActive and Theme.Primary or Theme.BackgroundSecondary
    tab.BackgroundTransparency = isActive and 0 or 1
    tab.Font = Enum.Font.GothamBold
    tab.Text = icon .. " " .. text
    tab.TextColor3 = Theme.Text
    tab.TextSize = 13
    tab.AutoButtonColor = false
    tab.ZIndex = 12
    tab.Parent = TabBar
    
    CreateCorner(tab, 12)
    
    if isActive then
        table.insert(UIElements.PrimaryElements, tab)
        CreateGradient(tab, Theme.Gradient1, Theme.Gradient2, 45)
    end
    
    return tab
end

local PlayersTab = CreateTab("Players", "Игроки", "👥", true)
local AdminsTab = CreateTab("Admins", "Админы", "⚠", false)

-- Content Area
local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -36, 0, 400)
ContentArea.Position = UDim2.new(0, 18, 0, 158)
ContentArea.BackgroundTransparency = 1
ContentArea.ZIndex = 11
ContentArea.Parent = MainContainer

-- Players Content
local PlayersContent = Instance.new("Frame")
PlayersContent.Size = UDim2.new(1, 0, 1, 0)
PlayersContent.BackgroundTransparency = 1
PlayersContent.Visible = true
PlayersContent.ZIndex = 11
PlayersContent.Parent = ContentArea

-- Search Bar
local SearchBar = Instance.new("Frame")
SearchBar.Size = UDim2.new(1, 0, 0, 48)
SearchBar.BackgroundColor3 = Theme.Surface
SearchBar.BorderSizePixel = 0
SearchBar.ZIndex = 12
SearchBar.Parent = PlayersContent

CreateCorner(SearchBar, 12)
CreateStroke(SearchBar, Theme.Border, 1, 0.6)

local SearchIcon = Instance.new("ImageLabel")
SearchIcon.Size = UDim2.new(0, 22, 0, 22)
SearchIcon.Position = UDim2.new(0, 15, 0.5, -11)
SearchIcon.BackgroundTransparency = 1
SearchIcon.Image = "rbxassetid://10734896206"
SearchIcon.ImageColor3 = Theme.TextMuted
SearchIcon.ZIndex = 13
SearchIcon.Parent = SearchBar

local SearchInput = Instance.new("TextBox")
SearchInput.Size = UDim2.new(1, -55, 1, 0)
SearchInput.Position = UDim2.new(0, 48, 0, 0)
SearchInput.BackgroundTransparency = 1
SearchInput.Font = Enum.Font.GothamMedium
SearchInput.PlaceholderText = "🔍 Поиск игроков..."
SearchInput.PlaceholderColor3 = Theme.TextMuted
SearchInput.Text = ""
SearchInput.TextColor3 = Theme.Text
SearchInput.TextSize = 14
SearchInput.TextXAlignment = Enum.TextXAlignment.Left
SearchInput.ClearTextOnFocus = false
SearchInput.ZIndex = 13
SearchInput.Parent = SearchBar

-- Player List
local PlayerListFrame = Instance.new("Frame")
PlayerListFrame.Size = UDim2.new(1, 0, 1, -60)
PlayerListFrame.Position = UDim2.new(0, 0, 0, 58)
PlayerListFrame.BackgroundColor3 = Theme.Surface
PlayerListFrame.BorderSizePixel = 0
PlayerListFrame.ZIndex = 12
PlayerListFrame.Parent = PlayersContent

CreateCorner(PlayerListFrame, 12)
CreateStroke(PlayerListFrame, Theme.Border, 1, 0.6)

local PlayerScroll = Instance.new("ScrollingFrame")
PlayerScroll.Size = UDim2.new(1, -8, 1, -8)
PlayerScroll.Position = UDim2.new(0, 4, 0, 4)
PlayerScroll.BackgroundTransparency = 1
PlayerScroll.ScrollBarThickness = 3
PlayerScroll.ScrollBarImageColor3 = Theme.Primary
PlayerScroll.ScrollBarImageTransparency = 0.4
PlayerScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
PlayerScroll.BorderSizePixel = 0
PlayerScroll.ZIndex = 13
PlayerScroll.Parent = PlayerListFrame

local PlayerListLayout = CreateListLayout(PlayerScroll, 8)
CreatePadding(PlayerScroll, 6, 6, 6, 6)

-- Admins Content
local AdminsContent = Instance.new("Frame")
AdminsContent.Size = UDim2.new(1, 0, 1, 0)
AdminsContent.BackgroundTransparency = 1
AdminsContent.Visible = false
AdminsContent.ZIndex = 11
AdminsContent.Parent = ContentArea

-- Admin Info Bar
local AdminInfoBar = Instance.new("Frame")
AdminInfoBar.Size = UDim2.new(1, 0, 0, 48)
AdminInfoBar.BackgroundColor3 = Color3.fromRGB(50, 40, 25)
AdminInfoBar.BorderSizePixel = 0
AdminInfoBar.ZIndex = 12
AdminInfoBar.Parent = AdminsContent

CreateCorner(AdminInfoBar, 12)
CreateStroke(AdminInfoBar, Theme.Warning, 1, 0.5)

local AdminInfoText = Instance.new("TextLabel")
AdminInfoText.Size = UDim2.new(1, -20, 1, 0)
AdminInfoText.Position = UDim2.new(0, 10, 0, 0)
AdminInfoText.BackgroundTransparency = 1
AdminInfoText.Font = Enum.Font.GothamMedium
AdminInfoText.Text = "⚠ Группа: " .. ADMIN_GROUP_ID .. " | Ранг: " .. ADMIN_MIN_RANK .. "-" .. ADMIN_MAX_RANK
AdminInfoText.TextColor3 = Theme.Warning
AdminInfoText.TextSize = 12
AdminInfoText.TextXAlignment = Enum.TextXAlignment.Left
AdminInfoText.ZIndex = 13
AdminInfoText.Parent = AdminInfoBar

-- Admin List
local AdminListFrame = Instance.new("Frame")
AdminListFrame.Size = UDim2.new(1, 0, 1, -60)
AdminListFrame.Position = UDim2.new(0, 0, 0, 58)
AdminListFrame.BackgroundColor3 = Theme.Surface
AdminListFrame.BorderSizePixel = 0
AdminListFrame.ZIndex = 12
AdminListFrame.Parent = AdminsContent

CreateCorner(AdminListFrame, 12)
CreateStroke(AdminListFrame, Theme.Border, 1, 0.6)

local AdminScroll = Instance.new("ScrollingFrame")
AdminScroll.Size = UDim2.new(1, -8, 1, -8)
AdminScroll.Position = UDim2.new(0, 4, 0, 4)
AdminScroll.BackgroundTransparency = 1
AdminScroll.ScrollBarThickness = 3
AdminScroll.ScrollBarImageColor3 = Theme.Warning
AdminScroll.ScrollBarImageTransparency = 0.4
AdminScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
AdminScroll.BorderSizePixel = 0
AdminScroll.ZIndex = 13
AdminScroll.Parent = AdminListFrame

local AdminListLayout = CreateListLayout(AdminScroll, 8)
CreatePadding(AdminScroll, 6, 6, 6, 6)

-- Tab Switching with Animation
local function SwitchTab(tabName)
    CurrentTab = tabName
    
    -- Remove old gradients
    for _, child in pairs(PlayersTab:GetChildren()) do
        if child:IsA("UIGradient") then child:Destroy() end
    end
    for _, child in pairs(AdminsTab:GetChildren()) do
        if child:IsA("UIGradient") then child:Destroy() end
    end
    
    if tabName == "Players" then
        PlayersContent.Visible = true
        AdminsContent.Visible = false
        Animate(PlayersTab, {BackgroundTransparency = 0, BackgroundColor3 = Theme.Primary}, 0.35)
        Animate(AdminsTab, {BackgroundTransparency = 1}, 0.35)
        CreateGradient(PlayersTab, Theme.Gradient1, Theme.Gradient2, 45)
    else
        PlayersContent.Visible = false
        AdminsContent.Visible = true
        Animate(AdminsTab, {BackgroundTransparency = 0, BackgroundColor3 = Theme.Primary}, 0.35)
        Animate(PlayersTab, {BackgroundTransparency = 1}, 0.35)
        CreateGradient(AdminsTab, Theme.Gradient1, Theme.Gradient2, 45)
    end
end

PlayersTab.MouseButton1Click:Connect(function()
    Sounds.Click:Play()
    SwitchTab("Players")
end)

AdminsTab.MouseButton1Click:Connect(function()
    Sounds.Click:Play()
    SwitchTab("Admins")
end)

-- ═══════════════════════════════════════════════════════════
-- WATCHING GUI
-- ═══════════════════════════════════════════════════════════

local WatchingGui = Instance.new("ScreenGui")
WatchingGui.Name = "QwenWatching_V5"
WatchingGui.Parent = game.CoreGui
WatchingGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
WatchingGui.ResetOnSpawn = false
WatchingGui.Enabled = false
table.insert(UIElements.AllGuis, WatchingGui)

local WatchingBar = Instance.new("Frame")
WatchingBar.AnchorPoint = Vector2.new(0.5, 1)
WatchingBar.Size = UDim2.new(0, 360, 0, 90)
WatchingBar.Position = UDim2.new(0.5, 0, 1, -25)
WatchingBar.BackgroundColor3 = Theme.Background
WatchingBar.BackgroundTransparency = 0.03
WatchingBar.BorderSizePixel = 0
WatchingBar.ZIndex = 50
WatchingBar.Parent = WatchingGui

CreateCorner(WatchingBar, 16)
local watchingStroke = CreateStroke(WatchingBar, Theme.Primary, 2, 0.25)
table.insert(UIElements.Strokes, watchingStroke)
CreateShadow(WatchingBar, 50, 0.4)

-- Status Indicator with Pulse
local WatchingIndicator = Instance.new("Frame")
WatchingIndicator.AnchorPoint = Vector2.new(0.5, 0.5)
WatchingIndicator.Size = UDim2.new(0, 14, 0, 14)
WatchingIndicator.Position = UDim2.new(0, 30, 0.5, 0)
WatchingIndicator.BackgroundColor3 = Theme.Success
WatchingIndicator.BorderSizePixel = 0
WatchingIndicator.ZIndex = 51
WatchingIndicator.Parent = WatchingBar

CreateCorner(WatchingIndicator, 100)
CreatePulseEffect(WatchingIndicator)

-- Watching Info
local WatchingInfo = Instance.new("Frame")
WatchingInfo.Size = UDim2.new(1, -70, 1, -20)
WatchingInfo.Position = UDim2.new(0, 55, 0, 10)
WatchingInfo.BackgroundTransparency = 1
WatchingInfo.ZIndex = 51
WatchingInfo.Parent = WatchingBar

local WatchingName = Instance.new("TextLabel")
WatchingName.Size = UDim2.new(1, 0, 0, 26)
WatchingName.BackgroundTransparency = 1
WatchingName.Font = Enum.Font.GothamBlack
WatchingName.Text = "Username"
WatchingName.TextColor3 = Theme.Text
WatchingName.TextSize = 17
WatchingName.TextXAlignment = Enum.TextXAlignment.Left
WatchingName.ZIndex = 52
WatchingName.Parent = WatchingInfo

local WatchingID = Instance.new("TextLabel")
WatchingID.Size = UDim2.new(1, 0, 0, 18)
WatchingID.Position = UDim2.new(0, 0, 0, 26)
WatchingID.BackgroundTransparency = 1
WatchingID.Font = Enum.Font.Gotham
WatchingID.Text = "ID: 0"
WatchingID.TextColor3 = Theme.TextMuted
WatchingID.TextSize = 12
WatchingID.TextXAlignment = Enum.TextXAlignment.Left
WatchingID.ZIndex = 52
WatchingID.Parent = WatchingInfo

local WatchingStatus = Instance.new("TextLabel")
WatchingStatus.Size = UDim2.new(1, 0, 0, 18)
WatchingStatus.Position = UDim2.new(0, 0, 0, 48)
WatchingStatus.BackgroundTransparency = 1
WatchingStatus.Font = Enum.Font.GothamMedium
WatchingStatus.Text = "👁 Режим наблюдения активен"
WatchingStatus.TextColor3 = Theme.Primary
WatchingStatus.TextSize = 11
WatchingStatus.TextXAlignment = Enum.TextXAlignment.Left
WatchingStatus.ZIndex = 52
WatchingStatus.Parent = WatchingInfo

-- ═══════════════════════════════════════════════════════════
-- ADMIN ALERT
-- ═══════════════════════════════════════════════════════════

local AlertGui = Instance.new("ScreenGui")
AlertGui.Name = "QwenAlert_V5"
AlertGui.Parent = game.CoreGui
AlertGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
AlertGui.ResetOnSpawn = false
AlertGui.Enabled = false
table.insert(UIElements.AllGuis, AlertGui)

local AlertBar = Instance.new("Frame")
AlertBar.AnchorPoint = Vector2.new(0.5, 0)
AlertBar.Size = UDim2.new(0, 440, 0, 100)
AlertBar.Position = UDim2.new(0.5, 0, 0, -120)
AlertBar.BackgroundColor3 = Theme.Background
AlertBar.BorderSizePixel = 0
AlertBar.ZIndex = 200
AlertBar.Parent = AlertGui

CreateCorner(AlertBar, 16)
CreateStroke(AlertBar, Theme.Warning, 2, 0)
CreateShadow(AlertBar, 60, 0.35)

local AlertIcon = Instance.new("TextLabel")
AlertIcon.Size = UDim2.new(0, 70, 1, 0)
AlertIcon.BackgroundTransparency = 1
AlertIcon.Font = Enum.Font.GothamBlack
AlertIcon.Text = "⚠"
AlertIcon.TextColor3 = Theme.Warning
AlertIcon.TextSize = 45
AlertIcon.ZIndex = 201
AlertIcon.Parent = AlertBar

local AlertContent = Instance.new("Frame")
AlertContent.Size = UDim2.new(1, -85, 1, -20)
AlertContent.Position = UDim2.new(0, 75, 0, 10)
AlertContent.BackgroundTransparency = 1
AlertContent.ZIndex = 201
AlertContent.Parent = AlertBar

local AlertTitle = Instance.new("TextLabel")
AlertTitle.Size = UDim2.new(1, 0, 0, 30)
AlertTitle.BackgroundTransparency = 1
AlertTitle.Font = Enum.Font.GothamBlack
AlertTitle.Text = "🚨 АДМИН ОБНАРУЖЕН!"
AlertTitle.TextColor3 = Theme.Warning
AlertTitle.TextSize = 18
AlertTitle.TextXAlignment = Enum.TextXAlignment.Left
AlertTitle.ZIndex = 202
AlertTitle.Parent = AlertContent

local AlertInfo = Instance.new("TextLabel")
AlertInfo.Size = UDim2.new(1, 0, 0, 45)
AlertInfo.Position = UDim2.new(0, 0, 0, 32)
AlertInfo.BackgroundTransparency = 1
AlertInfo.Font = Enum.Font.GothamMedium
AlertInfo.Text = "Игрок: Unknown | Ранг: 0"
AlertInfo.TextColor3 = Theme.Text
AlertInfo.TextSize = 13
AlertInfo.TextXAlignment = Enum.TextXAlignment.Left
AlertInfo.TextWrapped = true
AlertInfo.ZIndex = 202
AlertInfo.Parent = AlertContent

local function ShowAdminAlert(playerName, rank, roleName)
    if not Config.AdminAlertEnabled or not ScriptRunning then return end
    
    AlertInfo.Text = "👤 " .. playerName .. " | 📊 Ранг: " .. rank .. " (" .. roleName .. ")"
    AlertGui.Enabled = true
    Sounds.Alert:Play()
    
    AlertBar.Position = UDim2.new(0.5, 0, 0, -120)
    Animate(AlertBar, {Position = UDim2.new(0.5, 0, 0, 25)}, 0.6, Enum.EasingStyle.Back)
    
    task.delay(6, function()
        if ScriptRunning then
            Animate(AlertBar, {Position = UDim2.new(0.5, 0, 0, -120)}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In, function()
                AlertGui.Enabled = false
            end)
        end
    end)
end

-- ═══════════════════════════════════════════════════════════
-- SETTINGS GUI
-- ═══════════════════════════════════════════════════════════

local SettingsGui = Instance.new("ScreenGui")
SettingsGui.Name = "QwenSettings_V5"
SettingsGui.Parent = game.CoreGui
SettingsGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
SettingsGui.ResetOnSpawn = false
SettingsGui.Enabled = false
table.insert(UIElements.AllGuis, SettingsGui)

local SettingsOverlay = Instance.new("Frame")
SettingsOverlay.Size = UDim2.new(1, 0, 1, 0)
SettingsOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
SettingsOverlay.BackgroundTransparency = 1
SettingsOverlay.BorderSizePixel = 0
SettingsOverlay.ZIndex = 60
SettingsOverlay.Parent = SettingsGui

local SettingsFrame = Instance.new("Frame")
SettingsFrame.AnchorPoint = Vector2.new(0.5, 0.5)
SettingsFrame.Size = UDim2.new(0, 430, 0, 620)
SettingsFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
SettingsFrame.BackgroundColor3 = Theme.Background
SettingsFrame.BorderSizePixel = 0
SettingsFrame.ZIndex = 61
SettingsFrame.Parent = SettingsOverlay

CreateCorner(SettingsFrame, 18)
CreateStroke(SettingsFrame, Theme.Border, 1, 0.4)
CreateShadow(SettingsFrame, 70, 0.4)
CreateGlow(SettingsFrame, Theme.Primary, 0.92)

-- Settings Header with Gradient
local SettingsHeader = Instance.new("Frame")
SettingsHeader.Size = UDim2.new(1, 0, 0, 75)
SettingsHeader.BackgroundColor3 = Theme.Primary
SettingsHeader.BorderSizePixel = 0
SettingsHeader.ZIndex = 62
SettingsHeader.Parent = SettingsFrame
table.insert(UIElements.PrimaryElements, SettingsHeader)

CreateCorner(SettingsHeader, 18)
CreateGradient(SettingsHeader, Theme.Gradient1, Theme.Gradient2, 45)

local SettingsHeaderCover = Instance.new("Frame")
SettingsHeaderCover.Size = UDim2.new(1, 0, 0, 28)
SettingsHeaderCover.Position = UDim2.new(0, 0, 1, -28)
SettingsHeaderCover.BackgroundColor3 = Theme.Primary
SettingsHeaderCover.BorderSizePixel = 0
SettingsHeaderCover.ZIndex = 62
SettingsHeaderCover.Parent = SettingsHeader
table.insert(UIElements.PrimaryElements, SettingsHeaderCover)
CreateGradient(SettingsHeaderCover, Theme.Gradient1, Theme.Gradient2, 45)

local SettingsTitle = Instance.new("TextLabel")
SettingsTitle.Size = UDim2.new(1, 0, 1, 0)
SettingsTitle.BackgroundTransparency = 1
SettingsTitle.Font = Enum.Font.GothamBlack
SettingsTitle.Text = "⚙ НАСТРОЙКИ"
SettingsTitle.TextColor3 = Theme.Text
SettingsTitle.TextSize = 19
SettingsTitle.ZIndex = 63
SettingsTitle.Parent = SettingsHeader

-- Settings Content
local SettingsContent = Instance.new("ScrollingFrame")
SettingsContent.Size = UDim2.new(1, -40, 0, 410)
SettingsContent.Position = UDim2.new(0, 20, 0, 90)
SettingsContent.BackgroundTransparency = 1
SettingsContent.ScrollBarThickness = 3
SettingsContent.ScrollBarImageColor3 = Theme.Primary
SettingsContent.CanvasSize = UDim2.new(0, 0, 0, 750)
SettingsContent.BorderSizePixel = 0
SettingsContent.ZIndex = 62
SettingsContent.Parent = SettingsFrame

local SettingsLayout = CreateListLayout(SettingsContent, 12)

-- Section Label Creator
local function CreateSectionLabel(parent, text, icon)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 30)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.Text = (icon or "") .. " " .. text
    label.TextColor3 = Theme.TextSecondary
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 63
    label.Parent = parent
    return label
end

-- Toggle Creator
local function CreateToggle(parent, text, icon, defaultValue, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 52)
    container.BackgroundColor3 = Theme.Surface
    container.BorderSizePixel = 0
    container.ZIndex = 63
    container.Parent = parent
    
    CreateCorner(container, 12)
    CreateStroke(container, Theme.Border, 1, 0.6)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0, 15, 0, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamMedium
    label.Text = (icon or "") .. " " .. text
    label.TextColor3 = Theme.Text
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 64
    label.Parent = container
    
    local toggleBg = Instance.new("Frame")
    toggleBg.Size = UDim2.new(0, 55, 0, 28)
    toggleBg.Position = UDim2.new(1, -70, 0.5, -14)
    toggleBg.BackgroundColor3 = defaultValue and Theme.Success or Theme.BackgroundTertiary
    toggleBg.BorderSizePixel = 0
    toggleBg.ZIndex = 64
    toggleBg.Parent = container
    
    CreateCorner(toggleBg, 14)
    
    local toggleCircle = Instance.new("Frame")
    toggleCircle.Size = UDim2.new(0, 22, 0, 22)
    toggleCircle.Position = defaultValue and UDim2.new(1, -25, 0.5, -11) or UDim2.new(0, 3, 0.5, -11)
    toggleCircle.BackgroundColor3 = Theme.Text
    toggleCircle.BorderSizePixel = 0
    toggleCircle.ZIndex = 65
    toggleCircle.Parent = toggleBg
    
    CreateCorner(toggleCircle, 11)
    
    local enabled = defaultValue
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundTransparency = 1
    button.Text = ""
    button.ZIndex = 66
    button.Parent = container
    
    button.MouseButton1Click:Connect(function()
        if not ScriptRunning then return end
        Sounds.Click:Play()
        enabled = not enabled
        
        Animate(toggleBg, {BackgroundColor3 = enabled and Theme.Success or Theme.BackgroundTertiary}, 0.3)
        Animate(toggleCircle, {Position = enabled and UDim2.new(1, -25, 0.5, -11) or UDim2.new(0, 3, 0.5, -11)}, 0.3, Enum.EasingStyle.Back)
        
        if callback then callback(enabled) end
    end)
    
    return container
end

-- Slider Creator
local function CreateSlider(parent, text, icon, minVal, maxVal, defaultValue, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 68)
    container.BackgroundColor3 = Theme.Surface
    container.BorderSizePixel = 0
    container.ZIndex = 63
    container.Parent = parent
    
    CreateCorner(container, 12)
    CreateStroke(container, Theme.Border, 1, 0.6)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 0, 30)
    label.Position = UDim2.new(0, 15, 0, 5)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamMedium
    label.Text = (icon or "") .. " " .. text
    label.TextColor3 = Theme.Text
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 64
    label.Parent = container
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.3, 0, 0, 30)
    valueLabel.Position = UDim2.new(0.7, 0, 0, 5)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.Text = tostring(defaultValue)
    valueLabel.TextColor3 = Theme.Primary
    valueLabel.TextSize = 14
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.ZIndex = 64
    valueLabel.Parent = container
    
    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, -30, 0, 12)
    sliderBg.Position = UDim2.new(0, 15, 0, 45)
    sliderBg.BackgroundColor3 = Theme.BackgroundTertiary
    sliderBg.BorderSizePixel = 0
    sliderBg.ZIndex = 64
    sliderBg.Parent = container
    
    CreateCorner(sliderBg, 6)
    
    local fillPercent = (defaultValue - minVal) / (maxVal - minVal)
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new(fillPercent, 0, 1, 0)
    sliderFill.BackgroundColor3 = Theme.Primary
    sliderFill.BorderSizePixel = 0
    sliderFill.ZIndex = 65
    sliderFill.Parent = sliderBg
    
    CreateCorner(sliderFill, 6)
    CreateGradient(sliderFill, Theme.Gradient1, Theme.Gradient2, 0)
    
    local sliderButton = Instance.new("TextButton")
    sliderButton.Size = UDim2.new(1, 0, 1, 10)
    sliderButton.Position = UDim2.new(0, 0, 0, -5)
    sliderButton.BackgroundTransparency = 1
    sliderButton.Text = ""
    sliderButton.ZIndex = 66
    sliderButton.Parent = sliderBg

        local isDragging = false
    
    sliderButton.MouseButton1Down:Connect(function()
        isDragging = true
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
        end
    end)
    
    RunService.RenderStepped:Connect(function()
        if isDragging and ScriptRunning then
            local mousePos = UserInputService:GetMouseLocation()
            local relX = math.clamp((mousePos.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
            sliderFill.Size = UDim2.new(relX, 0, 1, 0)
            
            local value = minVal + (maxVal - minVal) * relX
            value = math.floor(value * 100) / 100
            valueLabel.Text = tostring(value)
            
            if callback then callback(value) end
        end
    end)
    
    return container
end

-- RGB Slider Creator
local function CreateRGBSlider(parent, text, icon, defaultColor, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 98)
    container.BackgroundColor3 = Theme.Surface
    container.BorderSizePixel = 0
    container.ZIndex = 63
    container.Parent = parent
    
    CreateCorner(container, 12)
    CreateStroke(container, Theme.Border, 1, 0.6)
    
    local topRow = Instance.new("Frame")
    topRow.Size = UDim2.new(1, 0, 0, 35)
    topRow.BackgroundTransparency = 1
    topRow.ZIndex = 64
    topRow.Parent = container
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Position = UDim2.new(0, 15, 0, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamMedium
    label.Text = (icon or "") .. " " .. text
    label.TextColor3 = Theme.Text
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 65
    label.Parent = topRow
    
    local colorPreview = Instance.new("Frame")
    colorPreview.Size = UDim2.new(0, 50, 0, 25)
    colorPreview.Position = UDim2.new(1, -65, 0.5, -12)
    colorPreview.BackgroundColor3 = defaultColor
    colorPreview.BorderSizePixel = 0
    colorPreview.ZIndex = 65
    colorPreview.Parent = topRow
    
    CreateCorner(colorPreview, 8)
    CreateStroke(colorPreview, Theme.Border, 1, 0.4)
    
    local currentColor = defaultColor
    
    local slidersFrame = Instance.new("Frame")
    slidersFrame.Size = UDim2.new(1, -30, 0, 48)
    slidersFrame.Position = UDim2.new(0, 15, 0, 42)
    slidersFrame.BackgroundTransparency = 1
    slidersFrame.ZIndex = 64
    slidersFrame.Parent = container
    
    local sliderFills = {}
    
    local function CreateSingleSlider(name, sliderColor, xPos, initialValue)
        local sliderContainer = Instance.new("Frame")
        sliderContainer.Size = UDim2.new(0.31, 0, 0, 38)
        sliderContainer.Position = UDim2.new(xPos, 0, 0, 0)
        sliderContainer.BackgroundTransparency = 1
        sliderContainer.ZIndex = 65
        sliderContainer.Parent = slidersFrame
        
        local sliderLabel = Instance.new("TextLabel")
        sliderLabel.Size = UDim2.new(1, 0, 0, 14)
        sliderLabel.BackgroundTransparency = 1
        sliderLabel.Font = Enum.Font.GothamBold
        sliderLabel.Text = name
        sliderLabel.TextColor3 = sliderColor
        sliderLabel.TextSize = 11
        sliderLabel.ZIndex = 66
        sliderLabel.Parent = sliderContainer
        
        local sliderBg = Instance.new("Frame")
        sliderBg.Size = UDim2.new(1, 0, 0, 14)
        sliderBg.Position = UDim2.new(0, 0, 0, 20)
        sliderBg.BackgroundColor3 = Theme.BackgroundTertiary
        sliderBg.BorderSizePixel = 0
        sliderBg.ZIndex = 66
        sliderBg.Parent = sliderContainer
        
        CreateCorner(sliderBg, 7)
        
        local sliderFill = Instance.new("Frame")
        sliderFill.Size = UDim2.new(initialValue / 255, 0, 1, 0)
        sliderFill.BackgroundColor3 = sliderColor
        sliderFill.BackgroundTransparency = 0.3
        sliderFill.BorderSizePixel = 0
        sliderFill.ZIndex = 67
        sliderFill.Parent = sliderBg
        
        CreateCorner(sliderFill, 7)
        
        sliderFills[name] = sliderFill
        
        local sliderButton = Instance.new("TextButton")
        sliderButton.Size = UDim2.new(1, 0, 1, 0)
        sliderButton.BackgroundTransparency = 1
        sliderButton.Text = ""
        sliderButton.ZIndex = 68
        sliderButton.Parent = sliderBg
        
        local isDragging = false
        
        sliderButton.MouseButton1Down:Connect(function()
            isDragging = true
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                isDragging = false
            end
        end)
        
        RunService.RenderStepped:Connect(function()
            if isDragging and ScriptRunning then
                local mousePos = UserInputService:GetMouseLocation()
                local relX = math.clamp((mousePos.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
                sliderFill.Size = UDim2.new(relX, 0, 1, 0)
                
                local r, g, b = currentColor.R * 255, currentColor.G * 255, currentColor.B * 255
                if name == "R" then r = relX * 255
                elseif name == "G" then g = relX * 255
                else b = relX * 255 end
                
                currentColor = Color3.fromRGB(r, g, b)
                colorPreview.BackgroundColor3 = currentColor
                
                if callback then callback(currentColor) end
            end
        end)
        
        return sliderFill
    end
    
    CreateSingleSlider("R", Color3.fromRGB(255, 100, 100), 0, defaultColor.R * 255)
    CreateSingleSlider("G", Color3.fromRGB(100, 255, 100), 0.345, defaultColor.G * 255)
    CreateSingleSlider("B", Color3.fromRGB(100, 100, 255), 0.69, defaultColor.B * 255)
    
    return container, colorPreview
end

-- Danger Button Creator (for Unload)
local function CreateDangerButton(parent, text, icon, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 55)
    button.BackgroundColor3 = Theme.Danger
    button.Font = Enum.Font.GothamBlack
    button.Text = (icon or "") .. " " .. text
    button.TextColor3 = Theme.Text
    button.TextSize = 15
    button.AutoButtonColor = false
    button.ZIndex = 63
    button.Parent = parent
    
    CreateCorner(button, 12)
    CreateStroke(button, Color3.fromRGB(255, 80, 80), 1, 0.5)
    CreateRippleEffect(button)
    
    button.MouseEnter:Connect(function()
        if not ScriptRunning then return end
        Sounds.Hover:Play()
        Animate(button, {BackgroundColor3 = Color3.fromRGB(230, 60, 70), Size = UDim2.new(1, 4, 0, 57)}, 0.25)
    end)
    
    button.MouseLeave:Connect(function()
        if not ScriptRunning then return end
        Animate(button, {BackgroundColor3 = Theme.Danger, Size = UDim2.new(1, 0, 0, 55)}, 0.25)
    end)
    
    button.MouseButton1Click:Connect(function()
        if not ScriptRunning then return end
        Sounds.Click:Play()
        if callback then callback() end
    end)
    
    return button
end

-- Create Settings
CreateSectionLabel(SettingsContent, "ESP НАСТРОЙКИ", "👁")

CreateToggle(SettingsContent, "Включить ESP", "📦", Config.EspEnabled, function(value)
    Config.EspEnabled = value
    RefreshESPVisibility()
    SaveCurrentConfig()
end)

CreateSlider(SettingsContent, "Прозрачность ESP", "🔍", 0, 1, Config.EspTransparency, function(value)
    Config.EspTransparency = value
    for _, objects in pairs(ESPObjects) do
        for _, obj in pairs(objects) do
            if obj and obj:IsA("BoxHandleAdornment") then
                obj.Transparency = value
            end
        end
    end
    SaveCurrentConfig()
end)

CreateRGBSlider(SettingsContent, "Цвет ESP", "🎨", Config.EspColor, function(color)
    Config.EspColor = color
    UpdateESPColors()
    SaveCurrentConfig()
end)

CreateRGBSlider(SettingsContent, "Цвет ESP админов", "⚠", Config.AdminEspColor, function(color)
    Config.AdminEspColor = color
    UpdateESPColors()
    SaveCurrentConfig()
end)

CreateSectionLabel(SettingsContent, "ЛУЧ НАСТРОЙКИ", "✨")

CreateToggle(SettingsContent, "Включить луч", "💫", Config.BeamEnabled, function(value)
    Config.BeamEnabled = value
    AimBeam.Enabled = value and IsWatching
    SaveCurrentConfig()
end)

CreateSlider(SettingsContent, "Ширина луча", "📏", 0.05, 0.5, Config.BeamWidth, function(value)
    Config.BeamWidth = value
    AimBeam.Width0 = value
    AimBeam.Width1 = value
    SaveCurrentConfig()
end)

CreateRGBSlider(SettingsContent, "Цвет луча", "🌈", Config.BeamColor, function(color)
    Config.BeamColor = color
    AimBeam.Color = ColorSequence.new(color)
    SaveCurrentConfig()
end)

CreateSectionLabel(SettingsContent, "ИНТЕРФЕЙС", "🎭")

CreateRGBSlider(SettingsContent, "Цвет темы", "🖌", Config.HudColor, function(color)
    Config.HudColor = color
    UpdateTheme()
    
    for _, element in pairs(UIElements.PrimaryElements) do
        if element and element.Parent then
            Animate(element, {BackgroundColor3 = color}, 0.4)
        end
    end
    
    for _, stroke in pairs(UIElements.Strokes) do
        if stroke and stroke.Parent then
            stroke.Color = color
        end
    end
    
    SaveCurrentConfig()
end)

CreateSectionLabel(SettingsContent, "ОПОВЕЩЕНИЯ", "🔔")

CreateToggle(SettingsContent, "Алерт об админах", "🚨", Config.AdminAlertEnabled, function(value)
    Config.AdminAlertEnabled = value
    SaveCurrentConfig()
end)

CreateSectionLabel(SettingsContent, "УПРАВЛЕНИЕ СКРИПТОМ", "⚙")

-- UNLOAD BUTTON IN SETTINGS
CreateDangerButton(SettingsContent, "ВЫГРУЗИТЬ СКРИПТ", "🗑", function()
    -- Close settings first
    Animate(SettingsFrame, {Position = UDim2.new(0.5, 0, 1.5, 0)}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In)
    Animate(SettingsOverlay, {BackgroundTransparency = 1}, 0.3)
    
    task.wait(0.5)
    UnloadScript()
end)

-- Save Button
local SaveSettingsBtn = Instance.new("TextButton")
SaveSettingsBtn.Size = UDim2.new(1, -40, 0, 52)
SaveSettingsBtn.Position = UDim2.new(0, 20, 1, -68)
SaveSettingsBtn.BackgroundColor3 = Theme.Primary
SaveSettingsBtn.Font = Enum.Font.GothamBlack
SaveSettingsBtn.Text = "💾 СОХРАНИТЬ И ЗАКРЫТЬ"
SaveSettingsBtn.TextColor3 = Theme.Text
SaveSettingsBtn.TextSize = 15
SaveSettingsBtn.AutoButtonColor = false
SaveSettingsBtn.ZIndex = 63
SaveSettingsBtn.Parent = SettingsFrame
table.insert(UIElements.PrimaryElements, SaveSettingsBtn)

CreateCorner(SaveSettingsBtn, 12)
CreateGradient(SaveSettingsBtn, Theme.Gradient1, Theme.Gradient2, 45)
CreateRippleEffect(SaveSettingsBtn)

SaveSettingsBtn.MouseEnter:Connect(function()
    Animate(SaveSettingsBtn, {Size = UDim2.new(1, -36, 0, 54)}, 0.2)
end)
SaveSettingsBtn.MouseLeave:Connect(function()
    Animate(SaveSettingsBtn, {Size = UDim2.new(1, -40, 0, 52)}, 0.2)
end)

SaveSettingsBtn.MouseButton1Click:Connect(function()
    if not ScriptRunning then return end
    Sounds.Success:Play()
    SaveCurrentConfig()
    
    Animate(SettingsFrame, {Position = UDim2.new(0.5, 0, 1.5, 0)}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In)
    Animate(SettingsOverlay, {BackgroundTransparency = 1}, 0.4)
    
    task.wait(0.5)
    SettingsGui.Enabled = false
    SettingsFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
end)

-- ═══════════════════════════════════════════════════════════
-- PLAYER CARD CREATOR
-- ═══════════════════════════════════════════════════════════

local function CreatePlayerCard(player, isAdmin, rank, roleName)
    if not ScriptRunning then return nil end
    
    local targetScroll = isAdmin and AdminScroll or PlayerScroll
    
    local card = Instance.new("Frame")
    card.Name = player.Name
    card.Size = UDim2.new(1, -10, 0, 72)
    card.BackgroundColor3 = isAdmin and Color3.fromRGB(55, 42, 25) or Theme.BackgroundSecondary
    card.BorderSizePixel = 0
    card.ZIndex = 14
    card.Parent = targetScroll
    
    CreateCorner(card, 14)
    
    if isAdmin then
        CreateStroke(card, Theme.Warning, 1, 0.4)
    else
        CreateStroke(card, Theme.Border, 1, 0.7)
    end
    
    -- Avatar
    local avatarFrame = Instance.new("Frame")
    avatarFrame.Size = UDim2.new(0, 52, 0, 52)
    avatarFrame.Position = UDim2.new(0, 10, 0.5, -26)
    avatarFrame.BackgroundColor3 = Theme.Surface
    avatarFrame.BorderSizePixel = 0
    avatarFrame.ZIndex = 15
    avatarFrame.Parent = card
    
    CreateCorner(avatarFrame, 26)
    
    local avatar = Instance.new("ImageLabel")
    avatar.Size = UDim2.new(1, -4, 1, -4)
    avatar.Position = UDim2.new(0, 2, 0, 2)
    avatar.BackgroundTransparency = 1
    avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. player.UserId .. "&w=150&h=150"
    avatar.ZIndex = 16
    avatar.Parent = avatarFrame
    
    CreateCorner(avatar, 24)
    
    -- Online indicator
    local onlineIndicator = Instance.new("Frame")
    onlineIndicator.Size = UDim2.new(0, 12, 0, 12)
    onlineIndicator.Position = UDim2.new(1, -12, 1, -12)
    onlineIndicator.BackgroundColor3 = Theme.Success
    onlineIndicator.BorderSizePixel = 0
    onlineIndicator.ZIndex = 17
    onlineIndicator.Parent = avatarFrame
    
    CreateCorner(onlineIndicator, 6)
    CreateStroke(onlineIndicator, Theme.Background, 2, 0)
    
    -- Info
    local infoFrame = Instance.new("Frame")
    infoFrame.Size = UDim2.new(1, -135, 1, 0)
    infoFrame.Position = UDim2.new(0, 72, 0, 0)
    infoFrame.BackgroundTransparency = 1
    infoFrame.ZIndex = 15
    infoFrame.Parent = card
    
    local displayName = Instance.new("TextLabel")
    displayName.Size = UDim2.new(1, 0, 0, 24)
    displayName.Position = UDim2.new(0, 0, 0, isAdmin and 8 or 14)
    displayName.BackgroundTransparency = 1
    displayName.Font = Enum.Font.GothamBold
    displayName.Text = (isAdmin and "⚠ " or "") .. (player.DisplayName or player.Name)
    displayName.TextColor3 = isAdmin and Theme.Warning or Theme.Text
    displayName.TextSize = 14
    displayName.TextXAlignment = Enum.TextXAlignment.Left
    displayName.TextTruncate = Enum.TextTruncate.AtEnd
    displayName.ZIndex = 16
    displayName.Parent = infoFrame
    
    local username = Instance.new("TextLabel")
    username.Size = UDim2.new(1, 0, 0, 18)
    username.Position = UDim2.new(0, 0, 0, isAdmin and 30 or 36)
    username.BackgroundTransparency = 1
    username.Font = Enum.Font.Gotham
    username.Text = "@" .. player.Name
    username.TextColor3 = Theme.TextMuted
    username.TextSize = 12
    username.TextXAlignment = Enum.TextXAlignment.Left
    username.ZIndex = 16
    username.Parent = infoFrame
    
    if isAdmin then
        local rankLabel = Instance.new("TextLabel")
        rankLabel.Size = UDim2.new(1, 0, 0, 14)
        rankLabel.Position = UDim2.new(0, 0, 0, 50)
        rankLabel.BackgroundTransparency = 1
        rankLabel.Font = Enum.Font.Gotham
        rankLabel.Text = "📊 Ранг: " .. rank .. " | " .. (roleName or "Unknown")
        rankLabel.TextColor3 = Theme.Warning
        rankLabel.TextSize = 10
        rankLabel.TextXAlignment = Enum.TextXAlignment.Left
        rankLabel.ZIndex = 16
        rankLabel.Parent = infoFrame
    end
    
    -- Watch Button
    local watchButton = Instance.new("TextButton")
    watchButton.Size = UDim2.new(0, 48, 0, 48)
    watchButton.Position = UDim2.new(1, -58, 0.5, -24)
    watchButton.BackgroundColor3 = isAdmin and Theme.Warning or Theme.Primary
    watchButton.Font = Enum.Font.GothamBold
    watchButton.Text = "👁"
    watchButton.TextColor3 = Theme.Text
    watchButton.TextSize = 20
    watchButton.AutoButtonColor = false
    watchButton.ZIndex = 15
    watchButton.Parent = card
    
    CreateCorner(watchButton, 12)
    CreateRippleEffect(watchButton)
    
    if not isAdmin then
        CreateGradient(watchButton, Theme.Gradient1, Theme.Gradient2, 45)
    end
    
    local normalBtnColor = isAdmin and Theme.Warning or Theme.Primary
    local hoverBtnColor = isAdmin and Color3.fromRGB(255, 205, 70) or Theme.PrimaryHover
    local normalCardColor = isAdmin and Color3.fromRGB(55, 42, 25) or Theme.BackgroundSecondary
    local hoverCardColor = isAdmin and Color3.fromRGB(65, 50, 30) or Theme.BackgroundTertiary
    
    watchButton.MouseEnter:Connect(function()
        if not ScriptRunning then return end
        Sounds.Hover:Play()
        Animate(watchButton, {Size = UDim2.new(0, 52, 0, 52)}, 0.2)
        Animate(card, {BackgroundColor3 = hoverCardColor}, 0.25)
    end)
    
    watchButton.MouseLeave:Connect(function()
        if not ScriptRunning then return end
        Animate(watchButton, {Size = UDim2.new(0, 48, 0, 48)}, 0.2)
        Animate(card, {BackgroundColor3 = normalCardColor}, 0.25)
    end)
    
    watchButton.MouseButton1Click:Connect(function()
        if not ScriptRunning then return end
        Sounds.Click:Play()
        CurrentTarget = player.Character
        
        if CurrentTarget and CurrentTarget:FindFirstChild("Humanoid") then
            IsWatching = true
            
            WatchingName.Text = (isAdmin and "⚠ " or "") .. (player.DisplayName or player.Name)
            WatchingID.Text = "ID: " .. player.UserId .. (isAdmin and " | Ранг: " .. rank or "")
            WatchingStatus.TextColor3 = isAdmin and Theme.Warning or Theme.Primary
            WatchingIndicator.BackgroundColor3 = isAdmin and Theme.Warning or Theme.Success
            
            Camera.CameraSubject = CurrentTarget:FindFirstChild("Humanoid")
            
            Animate(MainContainer, {Position = UDim2.new(0.5, 0, 1.6, 0)}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In)
            
            task.wait(0.5)
            MainGui.Enabled = false
            IsMenuOpen = false
            MainContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
            
            WatchingGui.Enabled = true
            WatchingBar.Position = UDim2.new(0.5, 0, 1, 50)
            Animate(WatchingBar, {Position = UDim2.new(0.5, 0, 1, -25)}, 0.5, Enum.EasingStyle.Back)
            
            table.insert(ViewLogs, 1, {
                Name = (isAdmin and "[ADMIN] " or "") .. (player.DisplayName or player.Name),
                UserId = player.UserId,
                Time = os.date("%H:%M:%S")
            })
            
            CreateESP(player, CurrentTarget)
            
            pcall(function()
                StarterGui:SetCore('SendNotification', {
                    Title = "👁 Qwen Aimviewer",
                    Text = "Наблюдение за " .. (player.DisplayName or player.Name),
                    Duration = 2.5
                })
            end)
        end
    end)
    
    -- Entry animation
    card.BackgroundTransparency = 1
    card.Size = UDim2.new(1, -10, 0, 0)
    
    Animate(card, {BackgroundTransparency = 0, Size = UDim2.new(1, -10, 0, 72)}, 0.4, Enum.EasingStyle.Back)
    
    return card
end

-- ═══════════════════════════════════════════════════════════
-- UPDATE FUNCTIONS
-- ═══════════════════════════════════════════════════════════

local function UpdatePlayerList(filter)
    if not ScriptRunning then return end
    
    for _, child in pairs(PlayerScroll:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    local delayTime = 0
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local matchesFilter = not filter or filter == "" or
                player.Name:lower():find(filter:lower()) or
                (player.DisplayName and player.DisplayName:lower():find(filter:lower()))
            
            if matchesFilter then
                local isAdmin, rank = CheckIfAdmin(player)
                
                if not isAdmin then
                    task.delay(delayTime, function()
                        if ScriptRunning then
                            CreatePlayerCard(player, false, 0, nil)
                        end
                    end)
                    delayTime = delayTime + 0.05
                end
            end
        end
    end
    
    task.delay(delayTime + 0.2, function()
        if ScriptRunning and PlayerScroll then
            PlayerScroll.CanvasSize = UDim2.new(0, 0, 0, PlayerListLayout.AbsoluteContentSize.Y + 15)
        end
    end)
end

local function UpdateAdminList()
    if not ScriptRunning then return end
    
    for _, child in pairs(AdminScroll:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextLabel") then
            child:Destroy()
        end
    end
    
    local delayTime = 0
    local adminCount = 0
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local isAdmin, rank = CheckIfAdmin(player)
            
            if isAdmin then
                adminCount = adminCount + 1
                local roleName = GetAdminRole(player)
                
                task.delay(delayTime, function()
                    if ScriptRunning then
                        CreatePlayerCard(player, true, rank, roleName)
                    end
                end)
                delayTime = delayTime + 0.06
            end
        end
    end
    
    if adminCount == 0 then
        task.delay(0.1, function()
            if not ScriptRunning or not AdminScroll then return end
            
            local noAdmins = Instance.new("TextLabel")
            noAdmins.Size = UDim2.new(1, -20, 0, 80)
            noAdmins.BackgroundTransparency = 1
            noAdmins.Font = Enum.Font.GothamMedium
            noAdmins.Text = "✅ Админов не обнаружено\nМожно играть спокойно!"
            noAdmins.TextColor3 = Theme.Success
            noAdmins.TextSize = 14
            noAdmins.ZIndex = 14
            noAdmins.Parent = AdminScroll
        end)
    end
    
    task.delay(delayTime + 0.2, function()
        if ScriptRunning and AdminScroll then
            AdminScroll.CanvasSize = UDim2.new(0, 0, 0, AdminListLayout.AbsoluteContentSize.Y + 15)
        end
    end)
end

local function RefreshAllESP()
    if not ScriptRunning then return end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            CreateESP(player, player.Character)
        end
    end
end

local function CheckAllAdmins()
    if not ScriptRunning then return end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local isAdmin, rank = CheckIfAdmin(player)
            if isAdmin then
                local roleName = GetAdminRole(player)
                ShowAdminAlert(player.DisplayName or player.Name, rank, roleName)
            end
        end
    end
end

-- ═══════════════════════════════════════════════════════════
-- MENU FUNCTIONS
-- ═══════════════════════════════════════════════════════════

local function ShowLoginScreen()
    if not ScriptRunning then return end
    
    LoginGui.Enabled = true
    LoginOverlay.BackgroundTransparency = 1
    LoginContainer.Position = UDim2.new(0.5, 0, 0.5, -50)
    LoginContainer.BackgroundTransparency = 1
    
    Animate(LoginOverlay, {BackgroundTransparency = 0.45}, 0.5)
    Animate(LoginContainer, {Position = UDim2.new(0.5, 0, 0.5, 0), BackgroundTransparency = 0}, 0.6, Enum.EasingStyle.Back)
    
    Sounds.Open:Play()
end

local function HideLoginScreen()
    if not ScriptRunning then return end
    
    Animate(LoginContainer, {Position = UDim2.new(0.5, 0, 0.5, 50), BackgroundTransparency = 1}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In)
    Animate(LoginOverlay, {BackgroundTransparency = 1}, 0.4)
    
    task.wait(0.5)
    LoginGui.Enabled = false
    LoginContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
    LoginContainer.BackgroundTransparency = 0
end

local function ShowMainMenu()
    if IsMenuOpen or not ScriptRunning then return end
    IsMenuOpen = true
    
    MainGui.Enabled = true
    MainContainer.Position = UDim2.new(0.5, 0, -0.6, 0)
    
    Animate(MainContainer, {Position = UDim2.new(0.5, 0, 0.5, 0)}, 0.6, Enum.EasingStyle.Back)
    Sounds.Open:Play()
    
    UpdatePlayerList()
    UpdateAdminList()
end

local function HideMainMenu()
    if not IsMenuOpen or not ScriptRunning then return end
    
    Sounds.Close:Play()
    Animate(MainContainer, {Position = UDim2.new(0.5, 0, 1.6, 0)}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In)
    
    task.wait(0.5)
    MainGui.Enabled = false
    IsMenuOpen = false
    MainContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
end

local function ToggleMainMenu()
    if IsMenuOpen then
        HideMainMenu()
    else
        ShowMainMenu()
    end
end

local function StopWatching()
    if not IsWatching or not ScriptRunning then return end
    
    IsWatching = false
    CurrentTarget = nil
    
    if Character and Character:FindFirstChild("Humanoid") then
        Camera.CameraSubject = Character:FindFirstChild("Humanoid")
    end
    
    Animate(WatchingBar, {Position = UDim2.new(0.5, 0, 1, 50)}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In)
    
    task.wait(0.4)
    WatchingGui.Enabled = false
    AimBeam.Enabled = false
    
    pcall(function()
        StarterGui:SetCore('SendNotification', {
            Title = "👁 Qwen Aimviewer",
            Text = "Наблюдение отменено",
            Duration = 2
        })
    end)
end

-- Unload Script Function
function UnloadScript()
    if not ScriptRunning then return end
    ScriptRunning = false
    
    Sounds.Unload:Play()
    
    -- Stop watching
    if IsWatching then
        IsWatching = false
        CurrentTarget = nil
        if Character and Character:FindFirstChild("Humanoid") then
            Camera.CameraSubject = Character:FindFirstChild("Humanoid")
        end
    end
    
    -- Remove all ESP
    for userId, objects in pairs(ESPObjects) do
        for _, obj in pairs(objects) do
            if obj then
                pcall(function() obj:Destroy() end)
            end
        end
    end
    ESPObjects = {}
    
    -- Destroy ESP Folder
    pcall(function()
        if ESPFolder then ESPFolder:Destroy() end
    end)
    
    -- Destroy Beam
    pcall(function()
        if AimBeam then AimBeam:Destroy() end
        if BeamAttachment0 then BeamAttachment0:Destroy() end
        if BeamAttachment1 then BeamAttachment1:Destroy() end
    end)
    
    -- Destroy all GUIs with animation
    for _, gui in pairs(UIElements.AllGuis) do
        pcall(function()
            if gui then gui:Destroy() end
        end)
    end
    
    -- Destroy sounds
    for _, sound in pairs(Sounds) do
        pcall(function()
            if sound then sound:Destroy() end
        end)
    end
    
    pcall(function()
        StarterGui:SetCore('SendNotification', {
            Title = "👋 Qwen Aimviewer",
            Text = "Скрипт выгружен! До встречи!",
            Duration = 3
        })
    end)
    
    print("")
    print("═══════════════════════════════════════")
    print("   👋 Qwen Aimviewer v5.2 выгружен!")
    print("═══════════════════════════════════════")
    print("")
end

-- ═══════════════════════════════════════════════════════════
-- EVENT CONNECTIONS
-- ═══════════════════════════════════════════════════════════

-- Login Button
LoginButton.MouseButton1Click:Connect(function()
    if not ScriptRunning then return end
    Sounds.Click:Play()
    
    local enteredUsername = UsernameInput.Text
    local enteredPassword = PasswordInput.Text
    
    -- Check credentials using obfuscated functions
    if enteredUsername == _AUTH_KEY_1() and enteredPassword == _AUTH_KEY_2() then
        Sounds.Success:Play()
        IsAuthenticated = true
        
        LoginMessage.Text = "✅ Добро пожаловать!"
        LoginMessage.TextColor3 = Theme.Success
        
        task.wait(0.5)
        HideLoginScreen()
        
        task.wait(0.3)
        ShowMainMenu()
        RefreshAllESP()
        CheckAllAdmins()
        StartESPUpdateLoop()
        
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "👁 Qwen Aimviewer v5.2",
                Text = "Добро пожаловать! ESP обновляется каждую секунду",
                Duration = 3
            })
        end)
    else
        LoginMessage.Text = "❌ Неверный логин или пароль!"
        LoginMessage.TextColor3 = Theme.Error
        
        -- Shake animation
        local originalPos = LoginContainer.Position
        for i = 1, 4 do
            Animate(LoginContainer, {Position = UDim2.new(0.5, (i % 2 == 0 and 12 or -12), 0.5, 0)}, 0.05)
            task.wait(0.05)
        end
        Animate(LoginContainer, {Position = originalPos}, 0.05)
    end
end)

-- Settings Button
SettingsButton.MouseButton1Click:Connect(function()
    if not ScriptRunning then return end
    Sounds.Click:Play()
    
    SettingsGui.Enabled = true
    SettingsOverlay.BackgroundTransparency = 1
    SettingsFrame.Position = UDim2.new(0.5, 0, -0.6, 0)
    
    Animate(SettingsOverlay, {BackgroundTransparency = 0.5}, 0.4)
    Animate(SettingsFrame, {Position = UDim2.new(0.5, 0, 0.5, 0)}, 0.5, Enum.EasingStyle.Back)
end)

-- Close Button
CloseButton.MouseButton1Click:Connect(function()
    if not ScriptRunning then return end
    Sounds.Click:Play()
    HideMainMenu()
end)

-- Search Input
SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
    if ScriptRunning then
        UpdatePlayerList(SearchInput.Text)
    end
end)

SearchInput.Focused:Connect(function()
    if ScriptRunning then
        Animate(SearchBar, {BackgroundColor3 = Theme.SurfaceHover}, 0.25)
    end
end)

SearchInput.FocusLost:Connect(function()
    if ScriptRunning then
        Animate(SearchBar, {BackgroundColor3 = Theme.Surface}, 0.25)
    end
end)

-- Keyboard Input (F4 only for open/close)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or not ScriptRunning then return end
    
    -- F4 - Toggle Menu
    if input.KeyCode == Enum.KeyCode.F4 then
        if IsAuthenticated then
            if IsWatching then
                StopWatching()
            else
                ToggleMainMenu()
            end
        else
            ShowLoginScreen()
        end
    end
end)

-- Player Events
Players.PlayerAdded:Connect(function(player)
    if not ScriptRunning then return end
    
    player.CharacterAdded:Connect(function(character)
        if not ScriptRunning then return end
        task.wait(1.5)
        
        if Config.EspEnabled and ScriptRunning then
            CreateESP(player, character)
        end
        
        local isAdmin, rank = CheckIfAdmin(player)
        if isAdmin and Config.AdminAlertEnabled and ScriptRunning then
            local roleName = GetAdminRole(player)
            ShowAdminAlert(player.DisplayName or player.Name, rank, roleName)
        end
    end)
    
    if IsMenuOpen and ScriptRunning then
        task.wait(0.5)
        UpdatePlayerList(SearchInput.Text)
        UpdateAdminList()
    end
    
    task.wait(1)
    if not ScriptRunning then return end
    
    local isAdmin, rank = CheckIfAdmin(player)
    if isAdmin and Config.AdminAlertEnabled then
        local roleName = GetAdminRole(player)
        ShowAdminAlert(player.DisplayName or player.Name, rank, roleName)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    if not ScriptRunning then return end
    
    AdminCache[player.UserId] = nil
    RemoveESP(player)
    
    if CurrentTarget and CurrentTarget.Name == player.Name then
        StopWatching()
    end
    
    if IsMenuOpen and ScriptRunning then
        task.wait(0.3)
        UpdatePlayerList(SearchInput.Text)
        UpdateAdminList()
    end
end)

-- Character Respawn
LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    Character = newCharacter
end)

-- Beam Render Loop
RunService.RenderStepped:Connect(function()
    if not ScriptRunning then return end
    
    if IsWatching and CurrentTarget and CurrentTarget:FindFirstChild("Head") and CurrentTarget:FindFirstChild("Humanoid") then
        AimBeam.Enabled = Config.BeamEnabled
        
        BeamAttachment0.Position = CurrentTarget.Head.Position
        
        local aimPosition = CurrentTarget.Head.Position
        if CurrentTarget:FindFirstChild("BodyEffects") then
            local mousePos = CurrentTarget.BodyEffects:FindFirstChild("MousePos")
            if mousePos then
                aimPosition = mousePos.Value
            end
        end
        BeamAttachment1.Position = aimPosition
        
        local screenPos = Camera:WorldToScreenPoint(CurrentTarget.Head.Position)
        local mousePos = UserInputService:GetMouseLocation()
        local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
        
        if distance < 60 then
            AimBeam.Color = ColorSequence.new(Theme.Success)
        else
            AimBeam.Color = ColorSequence.new(Config.BeamColor)
        end
    else
        AimBeam.Enabled = false
    end
end)

-- ═══════════════════════════════════════════════════════════
-- INITIALIZATION
-- ═══════════════════════════════════════════════════════════

pcall(function()
    StarterGui:SetCore('SendNotification', {
        Title = "👁 Qwen Aimviewer v5.2",
        Text = "Нажми F4 для открытия",
        Duration = 4
    })
end)

print("")
print("╔═══════════════════════════════════════════════════════╗")
print("║        👁 QWEN AIMVIEWER PRO v5.2                     ║")
print("║           Enhanced Edition                            ║")
print("╠═══════════════════════════════════════════════════════╣")
print("║                                                       ║")
print("║   🎮 Открыть/Закрыть: F4                              ║")
print("║   🗑 Выгрузить: Через настройки                       ║")
print("║                                                       ║")
print("║   ✨ Новое в v5.2:                                    ║")
print("║   • ESP обновляется каждую секунду                    ║")
print("║   • Кнопка выгрузки в настройках                      ║")
print("║   • Красивые градиенты и анимации                     ║")
print("║   • Плавающие частицы                                 ║")
print("║   • Пульсирующие индикаторы                           ║")
print("║                                                       ║")
print("╠═══════════════════════════════════════════════════════╣")
print("║   📋 Группа админов: " .. ADMIN_GROUP_ID .. "                      ║")
print("║   📊 Ранг админов: " .. ADMIN_MIN_RANK .. " - " .. ADMIN_MAX_RANK .. "                           ║")
print("╚═══════════════════════════════════════════════════════╝")
print("")
print("   ✅ Скрипт загружен! Удачной игры!")
print("")

