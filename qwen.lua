--[[
    ╔═══════════════════════════════════════════════════════════╗
    ║           QWEN AIMVIEWER PRO v6.0 ULTIMATE                ║
    ║              Premium UI & Animations                       ║
    ╠═══════════════════════════════════════════════════════════╣
    ║                                                           ║
    ║           👨‍💻 СОЗДАТЕЛИ: kaito & akiko                    ║
    ║                                                           ║
    ╚═══════════════════════════════════════════════════════════╝
    
    🎮 Открыть/Закрыть: F4
    💬 Новое: Премиум анимации, Glassmorphism, Particles!
    
    🔐 Логин: solvetpain
    🔑 Пароль: kaito
]]

-- ═══════════════════════════════════════════════════════════
-- ОЧИСТКА ПРЕДЫДУЩИХ ИНСТАНСОВ
-- ═══════════════════════════════════════════════════════════
for _, gui in pairs(game.CoreGui:GetChildren()) do
    if gui.Name:find("Qwen") then
        pcall(function() gui:Destroy() end)
    end
end

for _, obj in pairs(workspace.Terrain:GetChildren()) do
    if obj:IsA("Beam") or obj:IsA("Attachment") then
        if obj.Name:find("Qwen") or obj.Name:find("AimBeam") then
            pcall(function() obj:Destroy() end)
        end
    end
end

for _, folder in pairs(workspace:GetChildren()) do
    if folder.Name:find("QwenESP") then
        pcall(function() folder:Destroy() end)
    end
end

for _, effect in pairs(game:GetService("Lighting"):GetChildren()) do
    if effect.Name == "QwenBlur" then
        pcall(function() effect:Destroy() end)
    end
end

-- ═══════════════════════════════════════════════════════════
-- СЕРВИСЫ
-- ═══════════════════════════════════════════════════════════
local Players = game:GetService('Players')
local UserInputService = game:GetService('UserInputService')
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService('StarterGui')
local SoundService = game:GetService("SoundService")
local HttpService = game:GetService("HttpService")
local TextChatService = game:GetService("TextChatService")
local Lighting = game:GetService("Lighting")

-- ═══════════════════════════════════════════════════════════
-- ПЕРЕМЕННЫЕ ИГРОКА
-- ═══════════════════════════════════════════════════════════
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Camera = workspace.CurrentCamera

-- ═══════════════════════════════════════════════════════════
-- СОСТОЯНИЕ СКРИПТА
-- ═══════════════════════════════════════════════════════════
local ScriptRunning = true
local AdminChatMessages = {}
local MAX_CHAT_MESSAGES = 50
local AnimationSpeed = 0.4

local IsAuthenticated = false
local IsMenuOpen = false
local CurrentTarget = nil
local IsWatching = false
local AdminCache = {}
local AdminChatGui = nil
local AdminChatScroll = nil
local BlurEffect = nil

-- ═══════════════════════════════════════════════════════════
-- FORWARD DECLARATIONS (решает проблему undefined функций)
-- ═══════════════════════════════════════════════════════════
local HideMainMenu
local UnloadScript
local ShowChangelog
local ShowMainMenu

-- ═══════════════════════════════════════════════════════════
-- АВТОРИЗАЦИЯ (Логин: solvetpain, Пароль: kaito)
-- ═══════════════════════════════════════════════════════════
local function _0x4f2a()
    local _t = {107, 97, 105, 116, 111}
    local _r = ""
    for i = 1, #_t do _r = _r .. string.char(_t[i]) end
    return _r
end

local function _0x3b1c()
    local _t = {115, 111, 108, 118, 101, 116, 112, 97, 105, 110}
    local _r = ""
    for i = 1, #_t do _r = _r .. string.char(_t[i]) end
    return _r
end

local _AUTH_KEY_1 = _0x3b1c
local _AUTH_KEY_2 = _0x4f2a

-- ═══════════════════════════════════════════════════════════
-- ЖУРНАЛ ОБНОВЛЕНИЙ
-- ═══════════════════════════════════════════════════════════
local Changelog = {
    {
        version = "v6.0 Ultimate",
        date = "2024",
        changes = {
            "• Premium UI с эффектами Glassmorphism",
            "• Неоновое свечение и частицы",
            "• Плавные Spring анимации",
            "• Эффект размытия фона",
            "• Улучшенный мониторинг чата",
            "• ESP только после авторизации",
            "• Исправлены все критические баги"
        }
    },
    {
        version = "v5.4",
        date = "2024",
        changes = {
            "• Мониторинг чата админов",
            "• Уведомления о сообщениях",
            "• Отдельное окно чата"
        }
    },
    {
        version = "v5.3",
        date = "2024",
        changes = {
            "• Улучшенный ESP",
            "• Оптимизация производительности"
        }
    },
    {
        version = "v5.0",
        date = "2024",
        changes = {
            "• Полный редизайн интерфейса",
            "• Новая система ESP",
            "• Луч прицеливания"
        }
    }
}

-- ═══════════════════════════════════════════════════════════
-- СОХРАНЕНИЕ / ЗАГРУЗКА
-- ═══════════════════════════════════════════════════════════
local SAVE_FILE = "QwenAimviewerV6.json"

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
    HudColor = {138, 43, 226},
    BeamColor = {138, 43, 226},
    EspColor = {138, 43, 226},
    EspEnabled = true,
    EspTransparency = 0.5,
    BeamEnabled = true,
    BeamWidth = 0.15,
    AdminAlertEnabled = true,
    AdminEspColor = {255, 165, 0},
    AdminChatEnabled = true,
    ParticlesEnabled = true,
    BlurEnabled = true
}

local SavedConfig = LoadData() or DefaultConfig

local Config = {
    HudColor = Color3.fromRGB(
        SavedConfig.HudColor and SavedConfig.HudColor[1] or 138,
        SavedConfig.HudColor and SavedConfig.HudColor[2] or 43,
        SavedConfig.HudColor and SavedConfig.HudColor[3] or 226
    ),
    BeamColor = Color3.fromRGB(
        SavedConfig.BeamColor and SavedConfig.BeamColor[1] or 138,
        SavedConfig.BeamColor and SavedConfig.BeamColor[2] or 43,
        SavedConfig.BeamColor and SavedConfig.BeamColor[3] or 226
    ),
    EspColor = Color3.fromRGB(
        SavedConfig.EspColor and SavedConfig.EspColor[1] or 138,
        SavedConfig.EspColor and SavedConfig.EspColor[2] or 43,
        SavedConfig.EspColor and SavedConfig.EspColor[3] or 226
    ),
    EspEnabled = SavedConfig.EspEnabled ~= false,
    EspTransparency = SavedConfig.EspTransparency or 0.5,
    BeamEnabled = SavedConfig.BeamEnabled ~= false,
    BeamWidth = SavedConfig.BeamWidth or 0.15,
    AdminAlertEnabled = SavedConfig.AdminAlertEnabled ~= false,
    AdminEspColor = Color3.fromRGB(
        SavedConfig.AdminEspColor and SavedConfig.AdminEspColor[1] or 255,
        SavedConfig.AdminEspColor and SavedConfig.AdminEspColor[2] or 165,
        SavedConfig.AdminEspColor and SavedConfig.AdminEspColor[3] or 0
    ),
    AdminChatEnabled = SavedConfig.AdminChatEnabled ~= false,
    ParticlesEnabled = SavedConfig.ParticlesEnabled ~= false,
    BlurEnabled = SavedConfig.BlurEnabled ~= false
}

-- ═══════════════════════════════════════════════════════════
-- ТЕМА
-- ═══════════════════════════════════════════════════════════
local Theme = {
    Background = Color3.fromRGB(10, 10, 18),
    BackgroundSecondary = Color3.fromRGB(15, 15, 28),
    BackgroundTertiary = Color3.fromRGB(22, 22, 38),
    BackgroundGlass = Color3.fromRGB(30, 30, 50),

    Surface = Color3.fromRGB(28, 28, 45),
    SurfaceHover = Color3.fromRGB(38, 38, 60),
    SurfaceActive = Color3.fromRGB(45, 45, 72),

    Primary = Color3.fromRGB(138, 43, 226),
    PrimaryLight = Color3.fromRGB(168, 85, 247),
    PrimaryDark = Color3.fromRGB(109, 40, 217),
    PrimaryGlow = Color3.fromRGB(147, 51, 234),

    Secondary = Color3.fromRGB(34, 211, 238),
    SecondaryLight = Color3.fromRGB(103, 232, 249),
    SecondaryDark = Color3.fromRGB(6, 182, 212),

    Accent = Color3.fromRGB(244, 114, 182),
    AccentLight = Color3.fromRGB(251, 146, 201),
    AccentDark = Color3.fromRGB(236, 72, 153),

    Text = Color3.fromRGB(250, 250, 255),
    TextSecondary = Color3.fromRGB(180, 180, 200),
    TextMuted = Color3.fromRGB(120, 120, 150),

    Success = Color3.fromRGB(34, 197, 94),
    SuccessGlow = Color3.fromRGB(74, 222, 128),
    Warning = Color3.fromRGB(251, 191, 36),
    WarningGlow = Color3.fromRGB(253, 224, 71),
    Error = Color3.fromRGB(239, 68, 68),
    ErrorGlow = Color3.fromRGB(248, 113, 113),
    Danger = Color3.fromRGB(220, 38, 38),

    Border = Color3.fromRGB(60, 60, 90),
    BorderGlow = Color3.fromRGB(138, 43, 226),
    Shadow = Color3.fromRGB(0, 0, 0),
    Glow = Color3.fromRGB(138, 43, 226),

    Gradient1 = Color3.fromRGB(139, 92, 246),
    Gradient2 = Color3.fromRGB(59, 130, 246),
    Gradient3 = Color3.fromRGB(236, 72, 153),

    NeonPurple = Color3.fromRGB(168, 85, 247),
    NeonBlue = Color3.fromRGB(56, 189, 248),
    NeonPink = Color3.fromRGB(251, 113, 133),

    AdminChat = Color3.fromRGB(255, 165, 0),
    AdminGlow = Color3.fromRGB(255, 200, 100)
}

local function SaveCurrentConfig()
    local data = {
        HudColor = {math.floor(Config.HudColor.R * 255), math.floor(Config.HudColor.G * 255), math.floor(Config.HudColor.B * 255)},
        BeamColor = {math.floor(Config.BeamColor.R * 255), math.floor(Config.BeamColor.G * 255), math.floor(Config.BeamColor.B * 255)},
        EspColor = {math.floor(Config.EspColor.R * 255), math.floor(Config.EspColor.G * 255), math.floor(Config.EspColor.B * 255)},
        AdminEspColor = {math.floor(Config.AdminEspColor.R * 255), math.floor(Config.AdminEspColor.G * 255), math.floor(Config.AdminEspColor.B * 255)},
        EspEnabled = Config.EspEnabled,
        EspTransparency = Config.EspTransparency,
        BeamEnabled = Config.BeamEnabled,
        BeamWidth = Config.BeamWidth,
        AdminAlertEnabled = Config.AdminAlertEnabled,
        AdminChatEnabled = Config.AdminChatEnabled,
        ParticlesEnabled = Config.ParticlesEnabled,
        BlurEnabled = Config.BlurEnabled
    }
    SaveData(data)
end

-- Админ настройки
local ADMIN_GROUP_ID = 367140785
local ADMIN_MIN_RANK = 249
local ADMIN_MAX_RANK = 255

-- Хранилище UI
local UIElements = {
    PrimaryElements = {},
    Strokes = {},
    AllGuis = {},
    Particles = {},
    GlowEffects = {}
}

-- ═══════════════════════════════════════════════════════════
-- ЗВУКИ
-- ═══════════════════════════════════════════════════════════
local Sounds = {}

local function CreateSound(id, volume)
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://" .. tostring(id)
    sound.Volume = volume or 0.5
    sound.Parent = SoundService
    return sound
end

Sounds.Open = CreateSound(6026984224, 0.3)
Sounds.Close = CreateSound(6026984224, 0.25)
Sounds.Click = CreateSound(6895079853, 0.4)
Sounds.Success = CreateSound(6895079653, 0.5)
Sounds.Hover = CreateSound(6895079725, 0.2)
Sounds.Alert = CreateSound(9113869830, 0.6)
Sounds.Message = CreateSound(6895079653, 0.35)

-- ═══════════════════════════════════════════════════════════
-- СИСТЕМА АНИМАЦИЙ
-- ═══════════════════════════════════════════════════════════
local function Animate(object, properties, duration, easingStyle, easingDirection, callback)
    if not object or not object.Parent or not ScriptRunning then return nil end

    local tweenInfo = TweenInfo.new(
        duration or AnimationSpeed,
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

local function AnimateSpring(object, properties, duration, callback)
    return Animate(object, properties, duration or 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out, callback)
end

local function AnimateSmooth(object, properties, duration, callback)
    return Animate(object, properties, duration or 0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, callback)
end

local function ShakeAnimation(element, intensity, duration)
    if not element or not element.Parent then return end
    intensity = intensity or 10
    duration = duration or 0.5

    local originalPos = element.Position
    local startTime = tick()

    task.spawn(function()
        while tick() - startTime < duration and ScriptRunning and element and element.Parent do
            local progress = 1 - ((tick() - startTime) / duration)
            local shakeX = (math.random() - 0.5) * intensity * progress
            local shakeY = (math.random() - 0.5) * intensity * progress
            element.Position = UDim2.new(
                originalPos.X.Scale, originalPos.X.Offset + shakeX,
                originalPos.Y.Scale, originalPos.Y.Offset + shakeY
            )
            task.wait(0.016)
        end
        if element and element.Parent then
            element.Position = originalPos
        end
    end)
end

-- ═══════════════════════════════════════════════════════════
-- UI КОМПОНЕНТЫ
-- ═══════════════════════════════════════════════════════════
local function CreateCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 12)
    corner.Parent = parent
    return corner
end

local function CreateStroke(parent, color, thickness, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Theme.Border
    stroke.Thickness = thickness or 1.5
    stroke.Transparency = transparency or 0
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
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

local function CreateListLayout(parent, padSize, direction, alignX, alignY)
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, padSize or 10)
    layout.FillDirection = direction or Enum.FillDirection.Vertical
    layout.HorizontalAlignment = alignX or Enum.HorizontalAlignment.Center
    layout.VerticalAlignment = alignY or Enum.VerticalAlignment.Top
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = parent
    return layout
end

local function CreatePremiumShadow(parent, intensity)
    intensity = intensity or 1

    local shadowContainer = Instance.new("Frame")
    shadowContainer.Name = "ShadowContainer"
    shadowContainer.BackgroundTransparency = 1
    shadowContainer.Size = UDim2.new(1, 100, 1, 100)
    shadowContainer.Position = UDim2.new(0, -50, 0, -50 + 15)
    shadowContainer.ZIndex = math.max(parent.ZIndex - 2, 1)
    shadowContainer.Parent = parent

    for i = 1, 3 do
        local shadow = Instance.new("ImageLabel")
        shadow.Name = "Shadow" .. i
        shadow.BackgroundTransparency = 1
        shadow.Image = "rbxassetid://5554236805"
        shadow.ImageColor3 = Theme.Shadow
        shadow.ImageTransparency = 0.4 + (i * 0.15) - (intensity * 0.1)
        shadow.ScaleType = Enum.ScaleType.Slice
        shadow.SliceCenter = Rect.new(23, 23, 277, 277)
        shadow.Size = UDim2.new(1, i * 15, 1, i * 15)
        shadow.Position = UDim2.new(0, -i * 7.5, 0, -i * 7.5 + i * 3)
        shadow.ZIndex = math.max(parent.ZIndex - 2 - i, 1)
        shadow.Parent = shadowContainer
    end

    return shadowContainer
end

local function CreateNeonGlow(parent, color, intensity)
    intensity = intensity or 1
    color = color or Theme.Glow

    local glowContainer = Instance.new("Frame")
    glowContainer.Name = "GlowContainer"
    glowContainer.BackgroundTransparency = 1
    glowContainer.Size = UDim2.new(1, 120, 1, 120)
    glowContainer.Position = UDim2.new(0, -60, 0, -60)
    glowContainer.ZIndex = math.max(parent.ZIndex - 1, 1)
    glowContainer.Parent = parent

    for i = 1, 3 do
        local glow = Instance.new("ImageLabel")
        glow.Name = "Glow" .. i
        glow.BackgroundTransparency = 1
        glow.Image = "rbxassetid://5554236805"
        glow.ImageColor3 = color
        glow.ImageTransparency = 0.8 + (i * 0.05) - (intensity * 0.1)
        glow.ScaleType = Enum.ScaleType.Slice
        glow.SliceCenter = Rect.new(23, 23, 277, 277)
        glow.Size = UDim2.new(1, i * 20, 1, i * 20)
        glow.Position = UDim2.new(0, -i * 10, 0, -i * 10)
        glow.ZIndex = math.max(parent.ZIndex - 1, 1)
        glow.Parent = glowContainer
    end

    table.insert(UIElements.GlowEffects, {Container = glowContainer, Color = color})
    return glowContainer
end

local function CreateAnimatedGradient(parent, colors, rotation)
    local gradient = Instance.new("UIGradient")
    gradient.Rotation = rotation or 45

    if #colors == 2 then
        gradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, colors[1]),
            ColorSequenceKeypoint.new(1, colors[2])
        }
    elseif #colors >= 3 then
        gradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, colors[1]),
            ColorSequenceKeypoint.new(0.5, colors[2]),
            ColorSequenceKeypoint.new(1, colors[3])
        }
    end

    gradient.Parent = parent
    return gradient
end

local function CreateGlassEffect(parent)
    local glass = Instance.new("Frame")
    glass.Name = "Glass"
    glass.Size = UDim2.new(1, 0, 1, 0)
    glass.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    glass.BackgroundTransparency = 0.95
    glass.BorderSizePixel = 0
    glass.ZIndex = parent.ZIndex
    glass.Parent = parent
    CreateCorner(glass, 16)
    return glass
end

local function CreateFloatingParticles(parent, count, color)
    if not Config.ParticlesEnabled then return nil end

    count = count or 10
    color = color or Theme.Primary

    local particleContainer = Instance.new("Frame")
    particleContainer.Name = "ParticleContainer"
    particleContainer.Size = UDim2.new(1, 0, 1, 0)
    particleContainer.BackgroundTransparency = 1
    particleContainer.ClipsDescendants = true
    particleContainer.ZIndex = parent.ZIndex + 1
    particleContainer.Parent = parent

    for i = 1, count do
        local particle = Instance.new("Frame")
        particle.Name = "Particle" .. i
        particle.Size = UDim2.new(0, math.random(3, 7), 0, math.random(3, 7))
        particle.Position = UDim2.new(math.random() * 0.9 + 0.05, 0, math.random() * 0.9 + 0.05, 0)
        particle.BackgroundColor3 = color
        particle.BackgroundTransparency = math.random(60, 85) / 100
        particle.BorderSizePixel = 0
        particle.ZIndex = parent.ZIndex + 2
        particle.Parent = particleContainer
        CreateCorner(particle, 100)

        task.spawn(function()
            task.wait(math.random() * 2)
            while ScriptRunning and particle and particle.Parent do
                local targetY = math.random() * 0.8 + 0.1
                local targetX = math.random() * 0.8 + 0.1
                local dur = math.random(4, 7)

                Animate(particle, {
                    Position = UDim2.new(targetX, 0, targetY, 0),
                    BackgroundTransparency = math.random(55, 88) / 100,
                    Size = UDim2.new(0, math.random(3, 8), 0, math.random(3, 8))
                }, dur, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

                task.wait(dur)
            end
        end)
    end

    table.insert(UIElements.Particles, particleContainer)
    return particleContainer
end

local function CreatePremiumRipple(button)
    button.ClipsDescendants = true

    button.MouseButton1Click:Connect(function()
        if not ScriptRunning then return end

        local ripple = Instance.new("Frame")
        ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ripple.BackgroundTransparency = 0.65
        ripple.BorderSizePixel = 0
        ripple.AnchorPoint = Vector2.new(0.5, 0.5)
        ripple.Size = UDim2.new(0, 0, 0, 0)
        CreateCorner(ripple, 999)

        local mousePos = UserInputService:GetMouseLocation()
        local relativeX = mousePos.X - button.AbsolutePosition.X
        local relativeY = mousePos.Y - button.AbsolutePosition.Y - 36
        ripple.Position = UDim2.new(0, relativeX, 0, relativeY)
        ripple.Parent = button

        local maxSize = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 3

        Animate(ripple, {
            Size = UDim2.new(0, maxSize, 0, maxSize),
            BackgroundTransparency = 1
        }, 0.6, Enum.EasingStyle.Quint)

        task.delay(0.7, function()
            if ripple and ripple.Parent then ripple:Destroy() end
        end)
    end)
end

local function CreatePulseEffect(element)
    task.spawn(function()
        while ScriptRunning and element and element.Parent do
            Animate(element, {
                Size = UDim2.new(0, 20, 0, 20),
                BackgroundTransparency = 0.3
            }, 0.8, Enum.EasingStyle.Sine)
            task.wait(0.8)
            if not element or not element.Parent then break end
            Animate(element, {
                Size = UDim2.new(0, 16, 0, 16),
                BackgroundTransparency = 0
            }, 0.8, Enum.EasingStyle.Sine)
            task.wait(0.8)
        end
    end)
end

-- ═══════════════════════════════════════════════════════════
-- ЭФФЕКТ РАЗМЫТИЯ
-- ═══════════════════════════════════════════════════════════
local function CreateBlurEffect()
    if BlurEffect then return BlurEffect end

    BlurEffect = Instance.new("BlurEffect")
    BlurEffect.Name = "QwenBlur"
    BlurEffect.Size = 0
    BlurEffect.Parent = Lighting

    return BlurEffect
end

local function ShowBlur(intensity)
    if not Config.BlurEnabled then return end
    intensity = intensity or 20

    if not BlurEffect then
        CreateBlurEffect()
    end

    Animate(BlurEffect, {Size = intensity}, 0.4)
end

local function HideBlur()
    if BlurEffect then
        Animate(BlurEffect, {Size = 0}, 0.4)
    end
end

-- ═══════════════════════════════════════════════════════════
-- АДМИН ФУНКЦИИ
-- ═══════════════════════════════════════════════════════════
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

-- ═══════════════════════════════════════════════════════════
-- ESP СИСТЕМА
-- ═══════════════════════════════════════════════════════════
local ESPFolder = nil
local ESPObjects = {}

local function InitializeESP()
    if ESPFolder then return end
    ESPFolder = Instance.new("Folder")
    ESPFolder.Name = "QwenESP_V6"
    ESPFolder.Parent = workspace
end

local function CreateESP(player, character)
    if not IsAuthenticated or not ScriptRunning then return nil end
    if not character then return nil end

    local hrp = character:FindFirstChild("HumanoidRootPart")
    local head = character:FindFirstChild("Head")
    if not hrp then return nil end

    InitializeESP()

    if ESPObjects[player.UserId] then
        for _, obj in pairs(ESPObjects[player.UserId]) do
            if obj and obj.Parent then
                pcall(function() obj:Destroy() end)
            end
        end
    end

    ESPObjects[player.UserId] = {}

    local isAdmin = CheckIfAdmin(player)
    local espColor = isAdmin and Config.AdminEspColor or Config.EspColor

    local box = Instance.new("BoxHandleAdornment")
    box.Name = "ESP_Box_" .. player.Name
    box.Adornee = character
    box.AlwaysOnTop = true
    box.ZIndex = 5
    box.Size = character:GetExtentsSize() + Vector3.new(0.3, 0.3, 0.3)
    box.Transparency = Config.EspTransparency
    box.Color3 = espColor
    box.Visible = Config.EspEnabled
    box.Parent = ESPFolder
    table.insert(ESPObjects[player.UserId], box)

    if head then
        local billboardGui = Instance.new("BillboardGui")
        billboardGui.Name = "ESP_Name_" .. player.Name
        billboardGui.Adornee = head
        billboardGui.Size = UDim2.new(0, 180, 0, 60)
        billboardGui.StudsOffset = Vector3.new(0, 2.8, 0)
        billboardGui.AlwaysOnTop = true
        billboardGui.Parent = ESPFolder

        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, 0, 1, 0)
        container.BackgroundTransparency = 1
        container.Parent = billboardGui

        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Font = Enum.Font.GothamBlack
        nameLabel.Text = (isAdmin and "⚠ [ADMIN] " or "") .. player.DisplayName
        nameLabel.TextColor3 = espColor
        nameLabel.TextSize = 15
        nameLabel.TextStrokeTransparency = 0.4
        nameLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
        nameLabel.Parent = container

        local distanceLabel = Instance.new("TextLabel")
        distanceLabel.Name = "DistanceLabel"
        distanceLabel.Size = UDim2.new(1, 0, 0.5, 0)
        distanceLabel.Position = UDim2.new(0, 0, 0.5, 0)
        distanceLabel.BackgroundTransparency = 1
        distanceLabel.Font = Enum.Font.GothamMedium
        distanceLabel.Text = "0m"
        distanceLabel.TextColor3 = Theme.TextSecondary
        distanceLabel.TextSize = 13
        distanceLabel.TextStrokeTransparency = 0.5
        distanceLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
        distanceLabel.Parent = container

        billboardGui.Enabled = Config.EspEnabled
        table.insert(ESPObjects[player.UserId], billboardGui)
    end

    return box
end

local function RemoveESP(player)
    if ESPObjects[player.UserId] then
        for _, obj in pairs(ESPObjects[player.UserId]) do
            if obj and obj.Parent then
                pcall(function() obj:Destroy() end)
            end
        end
        ESPObjects[player.UserId] = nil
    end
end

local function RefreshESPVisibility()
    for _, objects in pairs(ESPObjects) do
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

local function RefreshAllESP()
    if not ScriptRunning or not IsAuthenticated then return end
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            CreateESP(player, player.Character)
        end
    end
end

local function UpdateESPDistances()
    if not ScriptRunning or not IsAuthenticated then return end
    if not Character or not Character:FindFirstChild("HumanoidRootPart") then return end

    local myPos = Character.HumanoidRootPart.Position

    for userId, objects in pairs(ESPObjects) do
        local player = Players:GetPlayerByUserId(userId)
        if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            for _, obj in pairs(objects) do
                if obj and obj:IsA("BillboardGui") then
                    local container = obj:FindFirstChildOfClass("Frame")
                    if container then
                        local distLabel = container:FindFirstChild("DistanceLabel")
                        if distLabel then
                            local distance = (player.Character.HumanoidRootPart.Position - myPos).Magnitude
                            distLabel.Text = math.floor(distance) .. "m"
                        end
                    end
                end
            end
        end
    end
end

-- ESP обновление в фоне
task.spawn(function()
    while ScriptRunning do
        if IsAuthenticated then
            UpdateESPDistances()
            -- Периодическое обновление ESP для новых персонажей
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    if not ESPObjects[player.UserId] or #ESPObjects[player.UserId] == 0 then
                        CreateESP(player, player.Character)
                    end
                end
            end
        end
        task.wait(1.5)
    end
end)

-- ═══════════════════════════════════════════════════════════
-- BEAM (ЛУЧ)
-- ═══════════════════════════════════════════════════════════
local AimBeam = Instance.new("Beam")
AimBeam.Name = "QwenAimBeam"
AimBeam.Segments = 1
AimBeam.Width0 = Config.BeamWidth
AimBeam.Width1 = Config.BeamWidth
AimBeam.Color = ColorSequence.new(Config.BeamColor)
AimBeam.FaceCamera = true
AimBeam.LightEmission = 1
AimBeam.LightInfluence = 0
AimBeam.Transparency = NumberSequence.new(0.2)
AimBeam.Enabled = false

local BeamAttachment0 = Instance.new("Attachment")
BeamAttachment0.Name = "QwenBeamA0"
local BeamAttachment1 = Instance.new("Attachment")
BeamAttachment1.Name = "QwenBeamA1"
AimBeam.Attachment0 = BeamAttachment0
AimBeam.Attachment1 = BeamAttachment1
AimBeam.Parent = workspace.Terrain
BeamAttachment0.Parent = workspace.Terrain
BeamAttachment1.Parent = workspace.Terrain

-- ═══════════════════════════════════════════════════════════
-- CHANGELOG GUI
-- ═══════════════════════════════════════════════════════════
local ChangelogGui = nil

local function CreateChangelogGui()
    if ChangelogGui then return ChangelogGui end

    ChangelogGui = Instance.new("ScreenGui")
    ChangelogGui.Name = "QwenChangelog_V6"
    ChangelogGui.Parent = game.CoreGui
    ChangelogGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ChangelogGui.ResetOnSpawn = false
    ChangelogGui.Enabled = false
    table.insert(UIElements.AllGuis, ChangelogGui)

    local ChangelogOverlay = Instance.new("Frame")
    ChangelogOverlay.Name = "Overlay"
    ChangelogOverlay.Size = UDim2.new(1, 0, 1, 0)
    ChangelogOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    ChangelogOverlay.BackgroundTransparency = 0.5
    ChangelogOverlay.BorderSizePixel = 0
    ChangelogOverlay.ZIndex = 200
    ChangelogOverlay.Parent = ChangelogGui

    local ChangelogFrame = Instance.new("Frame")
    ChangelogFrame.Name = "ChangelogFrame"
    ChangelogFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    ChangelogFrame.Size = UDim2.new(0, 450, 0, 550)
    ChangelogFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    ChangelogFrame.BackgroundColor3 = Theme.Background
    ChangelogFrame.BorderSizePixel = 0
    ChangelogFrame.ZIndex = 201
    ChangelogFrame.ClipsDescendants = true
    ChangelogFrame.Parent = ChangelogOverlay

    CreateCorner(ChangelogFrame, 20)
    CreateStroke(ChangelogFrame, Theme.Primary, 2, 0.3)
    CreatePremiumShadow(ChangelogFrame, 1.2)
    CreateNeonGlow(ChangelogFrame, Theme.Primary, 0.6)
    CreateGlassEffect(ChangelogFrame)
    CreateFloatingParticles(ChangelogFrame, 8, Theme.Primary)

    -- Header
    local ChangelogHeader = Instance.new("Frame")
    ChangelogHeader.Size = UDim2.new(1, 0, 0, 80)
    ChangelogHeader.BackgroundColor3 = Theme.Primary
    ChangelogHeader.BackgroundTransparency = 0.1
    ChangelogHeader.BorderSizePixel = 0
    ChangelogHeader.ZIndex = 202
    ChangelogHeader.Parent = ChangelogFrame
    CreateCorner(ChangelogHeader, 20)
    CreateAnimatedGradient(ChangelogHeader, {Theme.Primary, Theme.Secondary, Theme.Primary}, 45)

    local HeaderCover = Instance.new("Frame")
    HeaderCover.Size = UDim2.new(1, 0, 0, 25)
    HeaderCover.Position = UDim2.new(0, 0, 1, -25)
    HeaderCover.BackgroundColor3 = Theme.Primary
    HeaderCover.BorderSizePixel = 0
    HeaderCover.ZIndex = 202
    HeaderCover.Parent = ChangelogHeader

    local ChangelogTitle = Instance.new("TextLabel")
    ChangelogTitle.Size = UDim2.new(1, 0, 0, 30)
    ChangelogTitle.Position = UDim2.new(0, 0, 0, 15)
    ChangelogTitle.BackgroundTransparency = 1
    ChangelogTitle.Font = Enum.Font.GothamBlack
    ChangelogTitle.Text = "📋 ЖУРНАЛ ОБНОВЛЕНИЙ"
    ChangelogTitle.TextColor3 = Theme.Text
    ChangelogTitle.TextSize = 20
    ChangelogTitle.ZIndex = 203
    ChangelogTitle.Parent = ChangelogHeader

    local ChangelogSubtitle = Instance.new("TextLabel")
    ChangelogSubtitle.Size = UDim2.new(1, 0, 0, 20)
    ChangelogSubtitle.Position = UDim2.new(0, 0, 0, 45)
    ChangelogSubtitle.BackgroundTransparency = 1
    ChangelogSubtitle.Font = Enum.Font.GothamMedium
    ChangelogSubtitle.Text = "👨‍💻 Создатели: kaito & akiko"
    ChangelogSubtitle.TextColor3 = Color3.fromRGB(220, 220, 240)
    ChangelogSubtitle.TextSize = 12
    ChangelogSubtitle.ZIndex = 203
    ChangelogSubtitle.Parent = ChangelogHeader

    -- Content Scroll
    local ChangelogScroll = Instance.new("ScrollingFrame")
    ChangelogScroll.Size = UDim2.new(1, -30, 1, -150)
    ChangelogScroll.Position = UDim2.new(0, 15, 0, 90)
    ChangelogScroll.BackgroundTransparency = 1
    ChangelogScroll.ScrollBarThickness = 4
    ChangelogScroll.ScrollBarImageColor3 = Theme.Primary
    ChangelogScroll.ScrollBarImageTransparency = 0.3
    ChangelogScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    ChangelogScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ChangelogScroll.BorderSizePixel = 0
    ChangelogScroll.ZIndex = 202
    ChangelogScroll.Parent = ChangelogFrame

    CreateListLayout(ChangelogScroll, 12)

    for i, entry in ipairs(Changelog) do
        local versionFrame = Instance.new("Frame")
        versionFrame.Size = UDim2.new(1, 0, 0, 0)
        versionFrame.AutomaticSize = Enum.AutomaticSize.Y
        versionFrame.BackgroundColor3 = Theme.Surface
        versionFrame.BackgroundTransparency = 0.3
        versionFrame.BorderSizePixel = 0
        versionFrame.ZIndex = 203
        versionFrame.LayoutOrder = i
        versionFrame.Parent = ChangelogScroll

        CreateCorner(versionFrame, 12)
        CreateStroke(versionFrame, i == 1 and Theme.Success or Theme.Border, 1, 0.5)
        CreatePadding(versionFrame, 12, 12, 15, 15)

        local versionLayout = Instance.new("UIListLayout")
        versionLayout.Padding = UDim.new(0, 6)
        versionLayout.Parent = versionFrame

        local versionLabel = Instance.new("TextLabel")
        versionLabel.Size = UDim2.new(1, 0, 0, 25)
        versionLabel.BackgroundTransparency = 1
        versionLabel.Font = Enum.Font.GothamBlack
        versionLabel.Text = (i == 1 and "🆕 " or "📌 ") .. entry.version .. " (" .. entry.date .. ")"
        versionLabel.TextColor3 = i == 1 and Theme.Success or Theme.Primary
        versionLabel.TextSize = 15
        versionLabel.TextXAlignment = Enum.TextXAlignment.Left
        versionLabel.ZIndex = 204
        versionLabel.Parent = versionFrame

        for _, change in ipairs(entry.changes) do
            local changeLabel = Instance.new("TextLabel")
            changeLabel.Size = UDim2.new(1, 0, 0, 18)
            changeLabel.BackgroundTransparency = 1
            changeLabel.Font = Enum.Font.Gotham
            changeLabel.Text = "   " .. change
            changeLabel.TextColor3 = Theme.TextSecondary
            changeLabel.TextSize = 12
            changeLabel.TextXAlignment = Enum.TextXAlignment.Left
            changeLabel.ZIndex = 204
            changeLabel.Parent = versionFrame
        end
    end

    -- Close Button
    local CloseChangelogBtn = Instance.new("TextButton")
    CloseChangelogBtn.Size = UDim2.new(1, -30, 0, 48)
    CloseChangelogBtn.Position = UDim2.new(0, 15, 1, -60)
    CloseChangelogBtn.BackgroundColor3 = Theme.Primary
    CloseChangelogBtn.Font = Enum.Font.GothamBold
    CloseChangelogBtn.Text = "✕ ЗАКРЫТЬ"
    CloseChangelogBtn.TextColor3 = Theme.Text
    CloseChangelogBtn.TextSize = 14
    CloseChangelogBtn.AutoButtonColor = false
    CloseChangelogBtn.ZIndex = 202
    CloseChangelogBtn.Parent = ChangelogFrame

    CreateCorner(CloseChangelogBtn, 12)
    CreateAnimatedGradient(CloseChangelogBtn, {Theme.Primary, Theme.Secondary}, 90)
    CreatePremiumRipple(CloseChangelogBtn)

    CloseChangelogBtn.MouseEnter:Connect(function()
        Sounds.Hover:Play()
        AnimateSpring(CloseChangelogBtn, {Size = UDim2.new(1, -26, 0, 52)}, 0.2)
    end)
    CloseChangelogBtn.MouseLeave:Connect(function()
        AnimateSpring(CloseChangelogBtn, {Size = UDim2.new(1, -30, 0, 48)}, 0.2)
    end)

    CloseChangelogBtn.MouseButton1Click:Connect(function()
        if ScriptRunning then
            Sounds.Click:Play()
            Animate(ChangelogFrame, {Position = UDim2.new(0.5, 0, 1.5, 0)}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In)
            HideBlur()
            task.wait(0.4)
            ChangelogGui.Enabled = false
            ChangelogFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        end
    end)

    return ChangelogGui
end

ShowChangelog = function()
    if not ChangelogGui then
        CreateChangelogGui()
    end

    ChangelogGui.Enabled = true
    ShowBlur(22)

    local frame = ChangelogGui:FindFirstChild("Overlay")
    if frame then
        frame = frame:FindFirstChild("ChangelogFrame")
        if frame then
            frame.Position = UDim2.new(0.5, 0, -0.5, 0)
            AnimateSpring(frame, {Position = UDim2.new(0.5, 0, 0.5, 0)}, 0.5)
        end
    end
    Sounds.Open:Play()
end

-- ═══════════════════════════════════════════════════════════
-- ADMIN CHAT MONITOR
-- ═══════════════════════════════════════════════════════════
local function CreateAdminChatGui()
    if AdminChatGui then return AdminChatGui end

    AdminChatGui = Instance.new("ScreenGui")
    AdminChatGui.Name = "QwenAdminChat_V6"
    AdminChatGui.Parent = game.CoreGui
    AdminChatGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    AdminChatGui.ResetOnSpawn = false
    AdminChatGui.Enabled = false
    table.insert(UIElements.AllGuis, AdminChatGui)

    local ChatContainer = Instance.new("Frame")
    ChatContainer.Name = "ChatContainer"
    ChatContainer.AnchorPoint = Vector2.new(1, 0.5)
    ChatContainer.Size = UDim2.new(0, 340, 0, 420)
    ChatContainer.Position = UDim2.new(1, -20, 0.5, 0)
    ChatContainer.BackgroundColor3 = Theme.Background
    ChatContainer.BackgroundTransparency = 0.05
    ChatContainer.BorderSizePixel = 0
    ChatContainer.Active = true
    ChatContainer.Draggable = true
    ChatContainer.ZIndex = 100
    ChatContainer.ClipsDescendants = true
    ChatContainer.Parent = AdminChatGui

    CreateCorner(ChatContainer, 18)
    CreateStroke(ChatContainer, Theme.Warning, 2, 0.2)
    CreatePremiumShadow(ChatContainer, 1)
    CreateNeonGlow(ChatContainer, Theme.Warning, 0.5)
    CreateGlassEffect(ChatContainer)
    CreateFloatingParticles(ChatContainer, 6, Theme.Warning)

    -- Header
    local ChatHeader = Instance.new("Frame")
    ChatHeader.Size = UDim2.new(1, 0, 0, 55)
    ChatHeader.BackgroundColor3 = Theme.Warning
    ChatHeader.BackgroundTransparency = 0.1
    ChatHeader.BorderSizePixel = 0
    ChatHeader.ZIndex = 101
    ChatHeader.Parent = ChatContainer
    CreateCorner(ChatHeader, 18)
    CreateAnimatedGradient(ChatHeader, {Theme.Warning, Theme.WarningGlow, Theme.Warning}, 90)

    local ChatHeaderCover = Instance.new("Frame")
    ChatHeaderCover.Size = UDim2.new(1, 0, 0, 22)
    ChatHeaderCover.Position = UDim2.new(0, 0, 1, -22)
    ChatHeaderCover.BackgroundColor3 = Theme.Warning
    ChatHeaderCover.BorderSizePixel = 0
    ChatHeaderCover.ZIndex = 101
    ChatHeaderCover.Parent = ChatHeader

    local ChatTitle = Instance.new("TextLabel")
    ChatTitle.Size = UDim2.new(1, -60, 1, 0)
    ChatTitle.Position = UDim2.new(0, 15, 0, 0)
    ChatTitle.BackgroundTransparency = 1
    ChatTitle.Font = Enum.Font.GothamBlack
    ChatTitle.Text = "💬 ЧАТ СЕРВЕРА"
    ChatTitle.TextColor3 = Theme.Text
    ChatTitle.TextSize = 16
    ChatTitle.TextXAlignment = Enum.TextXAlignment.Left
    ChatTitle.ZIndex = 102
    ChatTitle.Parent = ChatHeader

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 34, 0, 34)
    CloseBtn.Position = UDim2.new(1, -44, 0.5, -17)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    CloseBtn.BackgroundTransparency = 0.4
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Theme.Text
    CloseBtn.TextSize = 16
    CloseBtn.AutoButtonColor = false
    CloseBtn.ZIndex = 103
    CloseBtn.Parent = ChatHeader
    CreateCorner(CloseBtn, 10)
    CreatePremiumRipple(CloseBtn)

    CloseBtn.MouseEnter:Connect(function()
        Sounds.Hover:Play()
        Animate(CloseBtn, {BackgroundTransparency = 0.2, BackgroundColor3 = Theme.Error}, 0.2)
    end)
    CloseBtn.MouseLeave:Connect(function()
        Animate(CloseBtn, {BackgroundTransparency = 0.4, BackgroundColor3 = Color3.fromRGB(0, 0, 0)}, 0.2)
    end)
    CloseBtn.MouseButton1Click:Connect(function()
        if ScriptRunning then
            Sounds.Click:Play()
            Animate(ChatContainer, {Position = UDim2.new(1, 350, 0.5, 0)}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In, function()
                AdminChatGui.Enabled = false
                ChatContainer.Position = UDim2.new(1, -20, 0.5, 0)
            end)
        end
    end)

    local MessageCount = Instance.new("TextLabel")
    MessageCount.Name = "MessageCount"
    MessageCount.Size = UDim2.new(1, -24, 0, 25)
    MessageCount.Position = UDim2.new(0, 12, 0, 62)
    MessageCount.BackgroundTransparency = 1
    MessageCount.Font = Enum.Font.GothamMedium
    MessageCount.Text = "📊 Сообщений: 0"
    MessageCount.TextColor3 = Theme.TextMuted
    MessageCount.TextSize = 11
    MessageCount.TextXAlignment = Enum.TextXAlignment.Left
    MessageCount.ZIndex = 101
    MessageCount.Parent = ChatContainer

    local ChatFrame = Instance.new("Frame")
    ChatFrame.Size = UDim2.new(1, -20, 1, -140)
    ChatFrame.Position = UDim2.new(0, 10, 0, 92)
    ChatFrame.BackgroundColor3 = Theme.Surface
    ChatFrame.BackgroundTransparency = 0.3
    ChatFrame.BorderSizePixel = 0
    ChatFrame.ZIndex = 101
    ChatFrame.Parent = ChatContainer
    CreateCorner(ChatFrame, 12)
    CreateStroke(ChatFrame, Theme.Border, 1, 0.5)

    AdminChatScroll = Instance.new("ScrollingFrame")
    AdminChatScroll.Size = UDim2.new(1, -8, 1, -8)
    AdminChatScroll.Position = UDim2.new(0, 4, 0, 4)
    AdminChatScroll.BackgroundTransparency = 1
    AdminChatScroll.ScrollBarThickness = 3
    AdminChatScroll.ScrollBarImageColor3 = Theme.Warning
    AdminChatScroll.ScrollBarImageTransparency = 0.3
    AdminChatScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    AdminChatScroll.BorderSizePixel = 0
    AdminChatScroll.ZIndex = 102
    AdminChatScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    AdminChatScroll.Parent = ChatFrame

    CreateListLayout(AdminChatScroll, 6)
    CreatePadding(AdminChatScroll, 6, 6, 6, 6)

    local ClearBtn = Instance.new("TextButton")
    ClearBtn.Size = UDim2.new(1, -20, 0, 38)
    ClearBtn.Position = UDim2.new(0, 10, 1, -48)
    ClearBtn.BackgroundColor3 = Theme.BackgroundTertiary
    ClearBtn.Font = Enum.Font.GothamBold
    ClearBtn.Text = "🗑 Очистить"
    ClearBtn.TextColor3 = Theme.TextSecondary
    ClearBtn.TextSize = 12
    ClearBtn.AutoButtonColor = false
    ClearBtn.ZIndex = 101
    ClearBtn.Parent = ChatContainer
    CreateCorner(ClearBtn, 10)
    CreateStroke(ClearBtn, Theme.Border, 1, 0.5)
    CreatePremiumRipple(ClearBtn)

    ClearBtn.MouseEnter:Connect(function()
        Sounds.Hover:Play()
        Animate(ClearBtn, {BackgroundColor3 = Theme.Surface, TextColor3 = Theme.Text}, 0.2)
    end)
    ClearBtn.MouseLeave:Connect(function()
        Animate(ClearBtn, {BackgroundColor3 = Theme.BackgroundTertiary, TextColor3 = Theme.TextSecondary}, 0.2)
    end)

    ClearBtn.MouseButton1Click:Connect(function()
        if ScriptRunning then
            Sounds.Click:Play()
            AdminChatMessages = {}
            for _, child in pairs(AdminChatScroll:GetChildren()) do
                if child:IsA("Frame") then
                    child:Destroy()
                end
            end
            MessageCount.Text = "📊 Сообщений: 0"
        end
    end)

    return AdminChatGui
end

local function AddAdminChatMessage(playerName, message, rank, isAdmin)
    if not AdminChatScroll or not ScriptRunning then return end
    if not Config.AdminChatEnabled or not IsAuthenticated then return end

    table.insert(AdminChatMessages, 1, {
        Name = playerName,
        Message = message,
        Rank = rank,
        Time = os.date("%H:%M:%S"),
        IsAdmin = isAdmin
    })

    while #AdminChatMessages > MAX_CHAT_MESSAGES do
        table.remove(AdminChatMessages)
    end

    local msgFrame = Instance.new("Frame")
    msgFrame.Size = UDim2.new(1, 0, 0, 0)
    msgFrame.AutomaticSize = Enum.AutomaticSize.Y
    msgFrame.BackgroundColor3 = isAdmin and Color3.fromRGB(55, 42, 18) or Theme.BackgroundSecondary
    msgFrame.BackgroundTransparency = 0.2
    msgFrame.BorderSizePixel = 0
    msgFrame.ZIndex = 103
    msgFrame.LayoutOrder = -math.floor(tick() * 1000)
    msgFrame.ClipsDescendants = true
    msgFrame.Parent = AdminChatScroll

    CreateCorner(msgFrame, 10)
    if isAdmin then
        CreateStroke(msgFrame, Theme.Warning, 1, 0.4)
    end
    CreatePadding(msgFrame, 10, 10, 12, 12)

    local msgLayout = Instance.new("UIListLayout")
    msgLayout.Padding = UDim.new(0, 4)
    msgLayout.Parent = msgFrame

    local headerFrame = Instance.new("Frame")
    headerFrame.Size = UDim2.new(1, 0, 0, 20)
    headerFrame.BackgroundTransparency = 1
    headerFrame.ZIndex = 104
    headerFrame.Parent = msgFrame

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(0.7, 0, 1, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.Text = (isAdmin and "⚠ " or "") .. playerName .. (isAdmin and " [" .. rank .. "]" or "")
    nameLabel.TextColor3 = isAdmin and Theme.Warning or Theme.Text
    nameLabel.TextSize = 12
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
    nameLabel.ZIndex = 105
    nameLabel.Parent = headerFrame

    local timeLabel = Instance.new("TextLabel")
    timeLabel.Size = UDim2.new(0.3, 0, 1, 0)
    timeLabel.Position = UDim2.new(0.7, 0, 0, 0)
    timeLabel.BackgroundTransparency = 1
    timeLabel.Font = Enum.Font.Gotham
    timeLabel.Text = os.date("%H:%M")
    timeLabel.TextColor3 = Theme.TextMuted
    timeLabel.TextSize = 10
    timeLabel.TextXAlignment = Enum.TextXAlignment.Right
    timeLabel.ZIndex = 105
    timeLabel.Parent = headerFrame

    local msgLabel = Instance.new("TextLabel")
    msgLabel.Size = UDim2.new(1, 0, 0, 0)
    msgLabel.AutomaticSize = Enum.AutomaticSize.Y
    msgLabel.BackgroundTransparency = 1
    msgLabel.Font = Enum.Font.Gotham
    msgLabel.Text = message
    msgLabel.TextColor3 = Theme.TextSecondary
    msgLabel.TextSize = 12
    msgLabel.TextXAlignment = Enum.TextXAlignment.Left
    msgLabel.TextWrapped = true
    msgLabel.ZIndex = 104
    msgLabel.Parent = msgFrame

    -- Обновляем счётчик
    if AdminChatGui then
        local chatContainer = AdminChatGui:FindFirstChild("ChatContainer")
        if chatContainer then
            local countLabel = chatContainer:FindFirstChild("MessageCount")
            if countLabel then
                countLabel.Text = "📊 Сообщений: " .. #AdminChatMessages
            end
        end
    end

    -- Анимация появления
    msgFrame.BackgroundTransparency = 1
    AnimateSpring(msgFrame, {BackgroundTransparency = 0.2}, 0.4)

    if isAdmin then
        Sounds.Message:Play()
        if AdminChatGui and not AdminChatGui.Enabled then
            pcall(function()
                StarterGui:SetCore('SendNotification', {
                    Title = "💬 Сообщение админа!",
                    Text = playerName .. ": " .. string.sub(message, 1, 30) .. (string.len(message) > 30 and "..." or ""),
                    Duration = 3
                })
            end)
        end
    end

    AdminChatScroll.CanvasPosition = Vector2.new(0, 0)
end

local function SetupChatMonitoring()
    -- TextChatService мониторинг
    pcall(function()
        local textChannels = TextChatService:WaitForChild("TextChannels", 5)
        if textChannels then
            for _, channel in pairs(textChannels:GetChildren()) do
                if channel:IsA("TextChannel") then
                    channel.MessageReceived:Connect(function(textChatMessage)
                        if not ScriptRunning or not IsAuthenticated then return end
                        local sender = textChatMessage.TextSource
                        if sender then
                            local player = Players:GetPlayerByUserId(sender.UserId)
                            if player and player ~= LocalPlayer then
                                local isAdmin, rank = CheckIfAdmin(player)
                                if Config.AdminChatEnabled then
                                    AddAdminChatMessage(
                                        player.DisplayName or player.Name,
                                        textChatMessage.Text,
                                        rank,
                                        isAdmin
                                    )
                                end
                            end
                        end
                    end)
                end
            end
        end
    end)

    -- Legacy chat мониторинг
    pcall(function()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                player.Chatted:Connect(function(message)
                    if not ScriptRunning or not IsAuthenticated then return end
                    local isAdmin, rank = CheckIfAdmin(player)
                    if Config.AdminChatEnabled then
                        AddAdminChatMessage(
                            player.DisplayName or player.Name,
                            message,
                            rank,
                            isAdmin
                        )
                    end
                end)
            end
        end
    end)
end

-- ═══════════════════════════════════════════════════════════
-- LOGIN GUI
-- ═══════════════════════════════════════════════════════════
local LoginGui = Instance.new("ScreenGui")
LoginGui.Name = "QwenLogin_V6"
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
LoginContainer.Size = UDim2.new(0, 400, 0, 500)
LoginContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
LoginContainer.BackgroundColor3 = Theme.Background
LoginContainer.BorderSizePixel = 0
LoginContainer.ZIndex = 101
LoginContainer.ClipsDescendants = true
LoginContainer.Parent = LoginOverlay

CreateCorner(LoginContainer, 22)
CreateStroke(LoginContainer, Theme.BorderGlow, 2, 0.3)
CreatePremiumShadow(LoginContainer, 1.3)
CreateNeonGlow(LoginContainer, Theme.Primary, 0.7)
CreateGlassEffect(LoginContainer)
CreateFloatingParticles(LoginContainer, 12, Theme.Primary)

-- Login Header
local LoginHeader = Instance.new("Frame")
LoginHeader.Name = "Header"
LoginHeader.Size = UDim2.new(1, 0, 0, 140)
LoginHeader.BackgroundColor3 = Theme.Primary
LoginHeader.BackgroundTransparency = 0.1
LoginHeader.BorderSizePixel = 0
LoginHeader.ZIndex = 102
LoginHeader.Parent = LoginContainer
CreateCorner(LoginHeader, 22)
CreateAnimatedGradient(LoginHeader, {Theme.Primary, Theme.Secondary, Theme.Primary}, 45)

local LoginHeaderCover = Instance.new("Frame")
LoginHeaderCover.Size = UDim2.new(1, 0, 0, 40)
LoginHeaderCover.Position = UDim2.new(0, 0, 1, -40)
LoginHeaderCover.BackgroundColor3 = Theme.Primary
LoginHeaderCover.BorderSizePixel = 0
LoginHeaderCover.ZIndex = 102
LoginHeaderCover.Parent = LoginHeader

-- Logo
local LogoContainer = Instance.new("Frame")
LogoContainer.Size = UDim2.new(0, 60, 0, 60)
LogoContainer.Position = UDim2.new(0.5, -30, 0, 12)
LogoContainer.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
LogoContainer.BackgroundTransparency = 0.4
LogoContainer.BorderSizePixel = 0
LogoContainer.ZIndex = 103
LogoContainer.Parent = LoginHeader
CreateCorner(LogoContainer, 30)

local LogoIcon = Instance.new("TextLabel")
LogoIcon.Size = UDim2.new(1, 0, 1, 0)
LogoIcon.BackgroundTransparency = 1
LogoIcon.Font = Enum.Font.GothamBlack
LogoIcon.Text = "👁"
LogoIcon.TextColor3 = Theme.Text
LogoIcon.TextSize = 32
LogoIcon.ZIndex = 104
LogoIcon.Parent = LogoContainer

local LoginTitle = Instance.new("TextLabel")
LoginTitle.Name = "Title"
LoginTitle.Size = UDim2.new(1, 0, 0, 28)
LoginTitle.Position = UDim2.new(0, 0, 0, 78)
LoginTitle.BackgroundTransparency = 1
LoginTitle.Font = Enum.Font.GothamBlack
LoginTitle.Text = "QWEN AIMVIEWER"
LoginTitle.TextColor3 = Theme.Text
LoginTitle.TextSize = 22
LoginTitle.ZIndex = 103
LoginTitle.Parent = LoginHeader

local LoginSubtitle = Instance.new("TextLabel")
LoginSubtitle.Name = "Subtitle"
LoginSubtitle.Size = UDim2.new(1, 0, 0, 18)
LoginSubtitle.Position = UDim2.new(0, 0, 0, 105)
LoginSubtitle.BackgroundTransparency = 1
LoginSubtitle.Font = Enum.Font.GothamMedium
LoginSubtitle.Text = "v6.0 Ultimate Edition"
LoginSubtitle.TextColor3 = Color3.fromRGB(220, 220, 240)
LoginSubtitle.TextSize = 12
LoginSubtitle.ZIndex = 103
LoginSubtitle.Parent = LoginHeader

local CreatorsLabel = Instance.new("TextLabel")
CreatorsLabel.Size = UDim2.new(1, 0, 0, 16)
CreatorsLabel.Position = UDim2.new(0, 0, 0, 122)
CreatorsLabel.BackgroundTransparency = 1
CreatorsLabel.Font = Enum.Font.Gotham
CreatorsLabel.Text = "👨‍💻 by kaito & akiko"
CreatorsLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
CreatorsLabel.TextSize = 10
CreatorsLabel.ZIndex = 103
CreatorsLabel.Parent = LoginHeader

-- Login Content
local LoginContent = Instance.new("Frame")
LoginContent.Name = "Content"
LoginContent.Size = UDim2.new(1, -50, 0, 300)
LoginContent.Position = UDim2.new(0, 25, 0, 155)
LoginContent.BackgroundTransparency = 1
LoginContent.ZIndex = 102
LoginContent.Parent = LoginContainer

-- Username Input
local UsernameContainer = Instance.new("Frame")
UsernameContainer.Size = UDim2.new(1, 0, 0, 55)
UsernameContainer.Position = UDim2.new(0, 0, 0, 0)
UsernameContainer.BackgroundColor3 = Theme.Surface
UsernameContainer.BackgroundTransparency = 0.3
UsernameContainer.BorderSizePixel = 0
UsernameContainer.ZIndex = 103
UsernameContainer.Parent = LoginContent
CreateCorner(UsernameContainer, 12)
CreateStroke(UsernameContainer, Theme.Border, 1, 0.4)

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
PasswordContainer.BackgroundTransparency = 0.3
PasswordContainer.BorderSizePixel = 0
PasswordContainer.ZIndex = 103
PasswordContainer.Parent = LoginContent
CreateCorner(PasswordContainer, 12)
CreateStroke(PasswordContainer, Theme.Border, 1, 0.4)

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

-- Login Button
local LoginButton = Instance.new("TextButton")
LoginButton.Size = UDim2.new(1, 0, 0, 55)
LoginButton.Position = UDim2.new(0, 0, 0, 150)
LoginButton.BackgroundColor3 = Theme.Primary
LoginButton.Font = Enum.Font.GothamBlack
LoginButton.Text = "🚀 ВОЙТИ"
LoginButton.TextColor3 = Theme.Text
LoginButton.TextSize = 17
LoginButton.AutoButtonColor = false
LoginButton.ZIndex = 103
LoginButton.Parent = LoginContent
CreateCorner(LoginButton, 12)
CreateAnimatedGradient(LoginButton, {Theme.Primary, Theme.Secondary, Theme.Primary}, 90)
CreateNeonGlow(LoginButton, Theme.Primary, 0.4)
CreatePremiumRipple(LoginButton)

LoginButton.MouseEnter:Connect(function()
    Sounds.Hover:Play()
    AnimateSpring(LoginButton, {Size = UDim2.new(1, 4, 0, 58)}, 0.25)
end)
LoginButton.MouseLeave:Connect(function()
    AnimateSpring(LoginButton, {Size = UDim2.new(1, 0, 0, 55)}, 0.25)
end)

-- Changelog Button in Login
local ChangelogBtnLogin = Instance.new("TextButton")
ChangelogBtnLogin.Size = UDim2.new(1, 0, 0, 40)
ChangelogBtnLogin.Position = UDim2.new(0, 0, 0, 220)
ChangelogBtnLogin.BackgroundColor3 = Theme.Surface
ChangelogBtnLogin.BackgroundTransparency = 0.3
ChangelogBtnLogin.Font = Enum.Font.GothamMedium
ChangelogBtnLogin.Text = "📋 Журнал обновлений"
ChangelogBtnLogin.TextColor3 = Theme.TextSecondary
ChangelogBtnLogin.TextSize = 13
ChangelogBtnLogin.AutoButtonColor = false
ChangelogBtnLogin.ZIndex = 103
ChangelogBtnLogin.Parent = LoginContent
CreateCorner(ChangelogBtnLogin, 10)
CreateStroke(ChangelogBtnLogin, Theme.Border, 1, 0.5)
CreatePremiumRipple(ChangelogBtnLogin)

ChangelogBtnLogin.MouseEnter:Connect(function()
    Sounds.Hover:Play()
    Animate(ChangelogBtnLogin, {BackgroundTransparency = 0.1, TextColor3 = Theme.Text}, 0.2)
end)
ChangelogBtnLogin.MouseLeave:Connect(function()
    Animate(ChangelogBtnLogin, {BackgroundTransparency = 0.3, TextColor3 = Theme.TextSecondary}, 0.2)
end)
ChangelogBtnLogin.MouseButton1Click:Connect(function()
    Sounds.Click:Play()
    ShowChangelog()
end)

-- Login Message
local LoginMessage = Instance.new("TextLabel")
LoginMessage.Size = UDim2.new(1, 0, 0, 30)
LoginMessage.Position = UDim2.new(0, 0, 0, 270)
LoginMessage.BackgroundTransparency = 1
LoginMessage.Font = Enum.Font.GothamMedium
LoginMessage.Text = ""
LoginMessage.TextColor3 = Theme.Error
LoginMessage.TextSize = 13
LoginMessage.ZIndex = 103
LoginMessage.Parent = LoginContent

-- Credits
local LoginCredits = Instance.new("TextLabel")
LoginCredits.Size = UDim2.new(1, 0, 0, 25)
LoginCredits.Position = UDim2.new(0, 0, 1, -35)
LoginCredits.BackgroundTransparency = 1
LoginCredits.Font = Enum.Font.Gotham
LoginCredits.Text = "F4 - Открыть меню • Created by kaito & akiko"
LoginCredits.TextColor3 = Theme.TextMuted
LoginCredits.TextSize = 11
LoginCredits.ZIndex = 102
LoginCredits.Parent = LoginContainer

-- ═══════════════════════════════════════════════════════════
-- MAIN GUI
-- ═══════════════════════════════════════════════════════════
local MainGui = Instance.new("ScreenGui")
MainGui.Name = "QwenMain_V6"
MainGui.Parent = game.CoreGui
MainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
MainGui.ResetOnSpawn = false
MainGui.Enabled = false
table.insert(UIElements.AllGuis, MainGui)

local MainContainer = Instance.new("Frame")
MainContainer.Name = "Container"
MainContainer.AnchorPoint = Vector2.new(0.5, 0.5)
MainContainer.Size = UDim2.new(0, 460, 0, 620)
MainContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
MainContainer.BackgroundColor3 = Theme.Background
MainContainer.BorderSizePixel = 0
MainContainer.Active = true
MainContainer.Draggable = true
MainContainer.ClipsDescendants = true
MainContainer.ZIndex = 10
MainContainer.Parent = MainGui

CreateCorner(MainContainer, 20)
CreateStroke(MainContainer, Theme.BorderGlow, 2, 0.3)
CreatePremiumShadow(MainContainer, 1.2)
CreateNeonGlow(MainContainer, Theme.Primary, 0.6)
CreateGlassEffect(MainContainer)
CreateFloatingParticles(MainContainer, 10, Theme.Primary)

-- Main Header
local MainHeader = Instance.new("Frame")
MainHeader.Size = UDim2.new(1, 0, 0, 95)
MainHeader.BackgroundColor3 = Theme.Primary
MainHeader.BackgroundTransparency = 0.1
MainHeader.BorderSizePixel = 0
MainHeader.ZIndex = 11
MainHeader.Parent = MainContainer
CreateCorner(MainHeader, 20)
CreateAnimatedGradient(MainHeader, {Theme.Primary, Theme.Gradient2, Theme.Primary}, 45)

local MainHeaderCover = Instance.new("Frame")
MainHeaderCover.Size = UDim2.new(1, 0, 0, 30)
MainHeaderCover.Position = UDim2.new(0, 0, 1, -30)
MainHeaderCover.BackgroundColor3 = Theme.Primary
MainHeaderCover.BorderSizePixel = 0
MainHeaderCover.ZIndex = 11
MainHeaderCover.Parent = MainHeader

-- Logo Section
local LogoSection = Instance.new("Frame")
LogoSection.Size = UDim2.new(1, -180, 1, 0)
LogoSection.Position = UDim2.new(0, 18, 0, 0)
LogoSection.BackgroundTransparency = 1
LogoSection.ZIndex = 12
LogoSection.Parent = MainHeader

local MainLogoContainer = Instance.new("Frame")
MainLogoContainer.Size = UDim2.new(0, 50, 0, 50)
MainLogoContainer.Position = UDim2.new(0, 0, 0.5, -25)
MainLogoContainer.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MainLogoContainer.BackgroundTransparency = 0.4
MainLogoContainer.BorderSizePixel = 0
MainLogoContainer.ZIndex = 13
MainLogoContainer.Parent = LogoSection
CreateCorner(MainLogoContainer, 25)

local MainLogoIcon = Instance.new("TextLabel")
MainLogoIcon.Size = UDim2.new(1, 0, 1, 0)
MainLogoIcon.BackgroundTransparency = 1
MainLogoIcon.Font = Enum.Font.GothamBlack
MainLogoIcon.Text = "👁"
MainLogoIcon.TextColor3 = Theme.Text
MainLogoIcon.TextSize = 26
MainLogoIcon.ZIndex = 14
MainLogoIcon.Parent = MainLogoContainer

local MainLogo = Instance.new("TextLabel")
MainLogo.Size = UDim2.new(1, -60, 0, 26)
MainLogo.Position = UDim2.new(0, 58, 0, 18)
MainLogo.BackgroundTransparency = 1
MainLogo.Font = Enum.Font.GothamBlack
MainLogo.Text = "QWEN AIMVIEWER"
MainLogo.TextColor3 = Theme.Text
MainLogo.TextSize = 18
MainLogo.TextXAlignment = Enum.TextXAlignment.Left
MainLogo.ZIndex = 13
MainLogo.Parent = LogoSection

local MainVersion = Instance.new("TextLabel")
MainVersion.Size = UDim2.new(1, -60, 0, 16)
MainVersion.Position = UDim2.new(0, 58, 0, 44)
MainVersion.BackgroundTransparency = 1
MainVersion.Font = Enum.Font.GothamMedium
MainVersion.Text = "v6.0 Ultimate • by kaito & akiko"
MainVersion.TextColor3 = Color3.fromRGB(220, 220, 240)
MainVersion.TextSize = 11
MainVersion.TextXAlignment = Enum.TextXAlignment.Left
MainVersion.ZIndex = 13
MainVersion.Parent = LogoSection

local OnlineCounter = Instance.new("TextLabel")
OnlineCounter.Size = UDim2.new(1, -60, 0, 14)
OnlineCounter.Position = UDim2.new(0, 58, 0, 62)
OnlineCounter.BackgroundTransparency = 1
OnlineCounter.Font = Enum.Font.GothamMedium
OnlineCounter.Text = "🟢 Игроков: " .. #Players:GetPlayers()
OnlineCounter.TextColor3 = Theme.Success
OnlineCounter.TextSize = 10
OnlineCounter.TextXAlignment = Enum.TextXAlignment.Left
OnlineCounter.ZIndex = 13
OnlineCounter.Parent = LogoSection

task.spawn(function()
    while ScriptRunning do
        if OnlineCounter and OnlineCounter.Parent then
            OnlineCounter.Text = "🟢 Игроков: " .. #Players:GetPlayers()
        end
        task.wait(2)
    end
end)

-- Header Buttons
local HeaderButtonsFrame = Instance.new("Frame")
HeaderButtonsFrame.Size = UDim2.new(0, 180, 0, 42)
HeaderButtonsFrame.Position = UDim2.new(1, -195, 0.5, -21)
HeaderButtonsFrame.BackgroundTransparency = 1
HeaderButtonsFrame.ZIndex = 12
HeaderButtonsFrame.Parent = MainHeader

CreateListLayout(HeaderButtonsFrame, 8, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Right)

local function CreateHeaderButton(icon, color, isText)
    local button
    if isText then
        button = Instance.new("TextButton")
        button.Font = Enum.Font.GothamBold
        button.Text = icon
        button.TextColor3 = Theme.Text
        button.TextSize = 18
    else
        button = Instance.new("ImageButton")
        button.Image = icon
        button.ImageColor3 = Theme.Text
    end

    button.Size = UDim2.new(0, 40, 0, 40)
    button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    button.BackgroundTransparency = 0.85
    button.AutoButtonColor = false
    button.ZIndex = 13
    button.BorderSizePixel = 0
    button.Parent = HeaderButtonsFrame

    CreateCorner(button, 10)
    CreatePremiumRipple(button)

    button.MouseEnter:Connect(function()
        Sounds.Hover:Play()
        AnimateSpring(button, {
            BackgroundTransparency = 0.6,
            BackgroundColor3 = color or Theme.Primary,
            Size = UDim2.new(0, 44, 0, 44)
        }, 0.2)
    end)
    button.MouseLeave:Connect(function()
        AnimateSpring(button, {
            BackgroundTransparency = 0.85,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            Size = UDim2.new(0, 40, 0, 40)
        }, 0.2)
    end)

    return button
end

local ChangelogButton = CreateHeaderButton("📋", Theme.Success, true)
local ChatButton = CreateHeaderButton("💬", Theme.Warning, true)
local SettingsButton = CreateHeaderButton("⚙", Theme.Primary, true)
local CloseButton = CreateHeaderButton("✕", Theme.Error, true)

-- Tab Bar
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -36, 0, 48)
TabBar.Position = UDim2.new(0, 18, 0, 108)
TabBar.BackgroundColor3 = Theme.BackgroundSecondary
TabBar.BackgroundTransparency = 0.3
TabBar.BorderSizePixel = 0
TabBar.ZIndex = 11
TabBar.Parent = MainContainer
CreateCorner(TabBar, 12)
CreateStroke(TabBar, Theme.Border, 1, 0.5)

CreateListLayout(TabBar, 0, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Left)

local CurrentTab = "Players"

local function CreateTab(name, text, icon, isActive)
    local tab = Instance.new("TextButton")
    tab.Name = name .. "Tab"
    tab.Size = UDim2.new(0.5, 0, 1, 0)
    tab.BackgroundColor3 = isActive and Theme.Primary or Theme.BackgroundSecondary
    tab.BackgroundTransparency = isActive and 0.1 or 1
    tab.Font = Enum.Font.GothamBold
    tab.Text = icon .. "  " .. text
    tab.TextColor3 = Theme.Text
    tab.TextSize = 13
    tab.AutoButtonColor = false
    tab.ZIndex = 12
    tab.BorderSizePixel = 0
    tab.Parent = TabBar
    CreateCorner(tab, 12)

    if isActive then
        CreateAnimatedGradient(tab, {Theme.Primary, Theme.Gradient2}, 90)
    end

    return tab
end

local PlayersTab = CreateTab("Players", "Игроки", "👥", true)
local AdminsTab = CreateTab("Admins", "Админы", "⚠", false)

-- Content Area
local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -36, 0, 420)
ContentArea.Position = UDim2.new(0, 18, 0, 168)
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
SearchBar.BackgroundTransparency = 0.2
SearchBar.BorderSizePixel = 0
SearchBar.ZIndex = 12
SearchBar.Parent = PlayersContent
CreateCorner(SearchBar, 12)
CreateStroke(SearchBar, Theme.Border, 1, 0.5)

local SearchInput = Instance.new("TextBox")
SearchInput.Size = UDim2.new(1, -20, 1, 0)
SearchInput.Position = UDim2.new(0, 15, 0, 0)
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
PlayerListFrame.BackgroundTransparency = 0.3
PlayerListFrame.BorderSizePixel = 0
PlayerListFrame.ZIndex = 12
PlayerListFrame.Parent = PlayersContent
CreateCorner(PlayerListFrame, 12)
CreateStroke(PlayerListFrame, Theme.Border, 1, 0.5)

local PlayerScroll = Instance.new("ScrollingFrame")
PlayerScroll.Size = UDim2.new(1, -8, 1, -8)
PlayerScroll.Position = UDim2.new(0, 4, 0, 4)
PlayerScroll.BackgroundTransparency = 1
PlayerScroll.ScrollBarThickness = 4
PlayerScroll.ScrollBarImageColor3 = Theme.Primary
PlayerScroll.ScrollBarImageTransparency = 0.3
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

local AdminInfoBar = Instance.new("Frame")
AdminInfoBar.Size = UDim2.new(1, 0, 0, 48)
AdminInfoBar.BackgroundColor3 = Color3.fromRGB(50, 40, 20)
AdminInfoBar.BackgroundTransparency = 0.2
AdminInfoBar.BorderSizePixel = 0
AdminInfoBar.ZIndex = 12
AdminInfoBar.Parent = AdminsContent
CreateCorner(AdminInfoBar, 12)
CreateStroke(AdminInfoBar, Theme.Warning, 1, 0.4)

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

local AdminListFrame = Instance.new("Frame")
AdminListFrame.Size = UDim2.new(1, 0, 1, -60)
AdminListFrame.Position = UDim2.new(0, 0, 0, 58)
AdminListFrame.BackgroundColor3 = Theme.Surface
AdminListFrame.BackgroundTransparency = 0.3
AdminListFrame.BorderSizePixel = 0
AdminListFrame.ZIndex = 12
AdminListFrame.Parent = AdminsContent
CreateCorner(AdminListFrame, 12)
CreateStroke(AdminListFrame, Theme.Border, 1, 0.5)

local AdminScroll = Instance.new("ScrollingFrame")
AdminScroll.Size = UDim2.new(1, -8, 1, -8)
AdminScroll.Position = UDim2.new(0, 4, 0, 4)
AdminScroll.BackgroundTransparency = 1
AdminScroll.ScrollBarThickness = 4
AdminScroll.ScrollBarImageColor3 = Theme.Warning
AdminScroll.ScrollBarImageTransparency = 0.3
AdminScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
AdminScroll.BorderSizePixel = 0
AdminScroll.ZIndex = 13
AdminScroll.Parent = AdminListFrame

local AdminListLayout = CreateListLayout(AdminScroll, 8)
CreatePadding(AdminScroll, 6, 6, 6, 6)

-- Tab Switching
local function SwitchTab(tabName)
    CurrentTab = tabName

    for _, child in pairs(PlayersTab:GetChildren()) do
        if child:IsA("UIGradient") then child:Destroy() end
    end
    for _, child in pairs(AdminsTab:GetChildren()) do
        if child:IsA("UIGradient") then child:Destroy() end
    end

    if tabName == "Players" then
        PlayersContent.Visible = true
        AdminsContent.Visible = false
        AnimateSpring(PlayersTab, {BackgroundTransparency = 0.1, BackgroundColor3 = Theme.Primary}, 0.3)
        Animate(AdminsTab, {BackgroundTransparency = 1}, 0.3)
        CreateAnimatedGradient(PlayersTab, {Theme.Primary, Theme.Gradient2}, 90)
    else
        PlayersContent.Visible = false
        AdminsContent.Visible = true
        AnimateSpring(AdminsTab, {BackgroundTransparency = 0.1, BackgroundColor3 = Theme.Warning}, 0.3)
        Animate(PlayersTab, {BackgroundTransparency = 1}, 0.3)
        CreateAnimatedGradient(AdminsTab, {Theme.Warning, Theme.WarningGlow}, 90)
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
WatchingGui.Name = "QwenWatching_V6"
WatchingGui.Parent = game.CoreGui
WatchingGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
WatchingGui.ResetOnSpawn = false
WatchingGui.Enabled = false
table.insert(UIElements.AllGuis, WatchingGui)

local WatchingBar = Instance.new("Frame")
WatchingBar.AnchorPoint = Vector2.new(0.5, 1)
WatchingBar.Size = UDim2.new(0, 380, 0, 95)
WatchingBar.Position = UDim2.new(0.5, 0, 1, -25)
WatchingBar.BackgroundColor3 = Theme.Background
WatchingBar.BackgroundTransparency = 0.05
WatchingBar.BorderSizePixel = 0
WatchingBar.ZIndex = 50
WatchingBar.Parent = WatchingGui
CreateCorner(WatchingBar, 16)
local watchingStroke = CreateStroke(WatchingBar, Theme.Primary, 2, 0.2)
table.insert(UIElements.Strokes, watchingStroke)
CreatePremiumShadow(WatchingBar, 1)
CreateNeonGlow(WatchingBar, Theme.Primary, 0.5)
CreateGlassEffect(WatchingBar)

local WatchingIndicator = Instance.new("Frame")
WatchingIndicator.AnchorPoint = Vector2.new(0.5, 0.5)
WatchingIndicator.Size = UDim2.new(0, 16, 0, 16)
WatchingIndicator.Position = UDim2.new(0, 32, 0.5, 0)
WatchingIndicator.BackgroundColor3 = Theme.Success
WatchingIndicator.BorderSizePixel = 0
WatchingIndicator.ZIndex = 51
WatchingIndicator.Parent = WatchingBar
CreateCorner(WatchingIndicator, 100)
CreatePulseEffect(WatchingIndicator)

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
WatchingID.Font = Enum.Font.GothamMedium
WatchingID.Text = "ID: 0"
WatchingID.TextColor3 = Theme.TextMuted
WatchingID.TextSize = 12
WatchingID.TextXAlignment = Enum.TextXAlignment.Left
WatchingID.ZIndex = 52
WatchingID.Parent = WatchingInfo

local WatchingStatus = Instance.new("TextLabel")
WatchingStatus.Size = UDim2.new(1, 0, 0, 16)
WatchingStatus.Position = UDim2.new(0, 0, 0, 48)
WatchingStatus.BackgroundTransparency = 1
WatchingStatus.Font = Enum.Font.GothamMedium
WatchingStatus.Text = "👁 Режим наблюдения • F4 - выход"
WatchingStatus.TextColor3 = Theme.Primary
WatchingStatus.TextSize = 11
WatchingStatus.TextXAlignment = Enum.TextXAlignment.Left
WatchingStatus.ZIndex = 52
WatchingStatus.Parent = WatchingInfo

-- ═══════════════════════════════════════════════════════════
-- ADMIN ALERT
-- ═══════════════════════════════════════════════════════════
local AlertGui = Instance.new("ScreenGui")
AlertGui.Name = "QwenAlert_V6"
AlertGui.Parent = game.CoreGui
AlertGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
AlertGui.ResetOnSpawn = false
AlertGui.Enabled = false
table.insert(UIElements.AllGuis, AlertGui)

local AlertBar = Instance.new("Frame")
AlertBar.AnchorPoint = Vector2.new(0.5, 0)
AlertBar.Size = UDim2.new(0, 450, 0, 100)
AlertBar.Position = UDim2.new(0.5, 0, 0, -120)
AlertBar.BackgroundColor3 = Theme.Background
AlertBar.BorderSizePixel = 0
AlertBar.ZIndex = 200
AlertBar.ClipsDescendants = true
AlertBar.Parent = AlertGui
CreateCorner(AlertBar, 16)
CreateStroke(AlertBar, Theme.Warning, 2, 0)
CreatePremiumShadow(AlertBar, 1)
CreateNeonGlow(AlertBar, Theme.Warning, 0.7)
CreateGlassEffect(AlertBar)

local AlertIcon = Instance.new("TextLabel")
AlertIcon.Size = UDim2.new(0, 60, 1, 0)
AlertIcon.Position = UDim2.new(0, 15, 0, 0)
AlertIcon.BackgroundTransparency = 1
AlertIcon.Font = Enum.Font.GothamBlack
AlertIcon.Text = "⚠"
AlertIcon.TextColor3 = Theme.Warning
AlertIcon.TextSize = 38
AlertIcon.ZIndex = 201
AlertIcon.Parent = AlertBar

local AlertContent = Instance.new("Frame")
AlertContent.Size = UDim2.new(1, -95, 1, -20)
AlertContent.Position = UDim2.new(0, 80, 0, 10)
AlertContent.BackgroundTransparency = 1
AlertContent.ZIndex = 201
AlertContent.Parent = AlertBar

local AlertTitle = Instance.new("TextLabel")
AlertTitle.Size = UDim2.new(1, 0, 0, 28)
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
AlertInfo.Position = UDim2.new(0, 0, 0, 30)
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
    if not Config.AdminAlertEnabled or not ScriptRunning or not IsAuthenticated then return end

    AlertInfo.Text = "👤 " .. playerName .. " | 📊 Ранг: " .. rank .. " (" .. (roleName or "Unknown") .. ")"
    AlertGui.Enabled = true
    Sounds.Alert:Play()

    AlertBar.Position = UDim2.new(0.5, 0, 0, -120)
    AnimateSpring(AlertBar, {Position = UDim2.new(0.5, 0, 0, 25)}, 0.6)

    task.delay(0.3, function()
        if AlertBar and AlertBar.Parent then
            ShakeAnimation(AlertBar, 4, 0.25)
        end
    end)

    task.delay(5, function()
        if ScriptRunning and AlertBar and AlertBar.Parent then
            Animate(AlertBar, {Position = UDim2.new(0.5, 0, 0, -120)}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In, function()
                AlertGui.Enabled = false
            end)
        end
    end)
end

-- ═══════════════════════════════════════════════════════════
-- SETTINGS GUI
-- ═══════════════════════════════════════════════════════════
local SettingsGui = Instance.new("ScreenGui")
SettingsGui.Name = "QwenSettings_V6"
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
SettingsFrame.Size = UDim2.new(0, 440, 0, 600)
SettingsFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
SettingsFrame.BackgroundColor3 = Theme.Background
SettingsFrame.BorderSizePixel = 0
SettingsFrame.ZIndex = 61
SettingsFrame.ClipsDescendants = true
SettingsFrame.Active = true
SettingsFrame.Draggable = true
SettingsFrame.Parent = SettingsOverlay
CreateCorner(SettingsFrame, 20)
CreateStroke(SettingsFrame, Theme.BorderGlow, 2, 0.3)
CreatePremiumShadow(SettingsFrame, 1.2)
CreateNeonGlow(SettingsFrame, Theme.Primary, 0.6)
CreateGlassEffect(SettingsFrame)
CreateFloatingParticles(SettingsFrame, 8, Theme.Primary)

-- Settings Header
local SettingsHeader = Instance.new("Frame")
SettingsHeader.Size = UDim2.new(1, 0, 0, 80)
SettingsHeader.BackgroundColor3 = Theme.Primary
SettingsHeader.BackgroundTransparency = 0.1
SettingsHeader.BorderSizePixel = 0
SettingsHeader.ZIndex = 62
SettingsHeader.Parent = SettingsFrame
CreateCorner(SettingsHeader, 20)
CreateAnimatedGradient(SettingsHeader, {Theme.Primary, Theme.Gradient2, Theme.Primary}, 45)

local SettingsHeaderCover = Instance.new("Frame")
SettingsHeaderCover.Size = UDim2.new(1, 0, 0, 28)
SettingsHeaderCover.Position = UDim2.new(0, 0, 1, -28)
SettingsHeaderCover.BackgroundColor3 = Theme.Primary
SettingsHeaderCover.BorderSizePixel = 0
SettingsHeaderCover.ZIndex = 62
SettingsHeaderCover.Parent = SettingsHeader

local SettingsTitle = Instance.new("TextLabel")
SettingsTitle.Size = UDim2.new(1, 0, 1, 0)
SettingsTitle.BackgroundTransparency = 1
SettingsTitle.Font = Enum.Font.GothamBlack
SettingsTitle.Text = "⚙ НАСТРОЙКИ"
SettingsTitle.TextColor3 = Theme.Text
SettingsTitle.TextSize = 20
SettingsTitle.ZIndex = 63
SettingsTitle.Parent = SettingsHeader

-- Settings Content
local SettingsContent = Instance.new("ScrollingFrame")
SettingsContent.Size = UDim2.new(1, -36, 0, 420)
SettingsContent.Position = UDim2.new(0, 18, 0, 95)
SettingsContent.BackgroundTransparency = 1
SettingsContent.ScrollBarThickness = 4
SettingsContent.ScrollBarImageColor3 = Theme.Primary
SettingsContent.ScrollBarImageTransparency = 0.3
SettingsContent.CanvasSize = UDim2.new(0, 0, 0, 0)
SettingsContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
SettingsContent.BorderSizePixel = 0
SettingsContent.ZIndex = 62
SettingsContent.Parent = SettingsFrame

CreateListLayout(SettingsContent, 10)

-- Settings Helper Functions
local function CreateSectionLabel(parent, text, icon)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 32)
    container.BackgroundTransparency = 1
    container.ZIndex = 63
    container.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBlack
    label.Text = (icon or "") .. "  " .. text
    label.TextColor3 = Theme.TextSecondary
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 64
    label.Parent = container

    return container
end

local function CreateToggle(parent, text, icon, defaultValue, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 52)
    container.BackgroundColor3 = Theme.Surface
    container.BackgroundTransparency = 0.3
    container.BorderSizePixel = 0
    container.ZIndex = 63
    container.Parent = parent
    CreateCorner(container, 12)
    CreateStroke(container, Theme.Border, 1, 0.5)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0, 15, 0, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamMedium
    label.Text = (icon or "") .. "  " .. text
    label.TextColor3 = Theme.Text
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 64
    label.Parent = container

    local toggleBg = Instance.new("Frame")
    toggleBg.Size = UDim2.new(0, 52, 0, 28)
    toggleBg.Position = UDim2.new(1, -67, 0.5, -14)
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

    button.MouseEnter:Connect(function()
        Animate(container, {BackgroundTransparency = 0.1}, 0.2)
    end)
    button.MouseLeave:Connect(function()
        Animate(container, {BackgroundTransparency = 0.3}, 0.2)
    end)

    button.MouseButton1Click:Connect(function()
        if not ScriptRunning then return end
        Sounds.Click:Play()
        enabled = not enabled
        AnimateSpring(toggleBg, {BackgroundColor3 = enabled and Theme.Success or Theme.BackgroundTertiary}, 0.25)
        AnimateSpring(toggleCircle, {Position = enabled and UDim2.new(1, -25, 0.5, -11) or UDim2.new(0, 3, 0.5, -11)}, 0.25)
        if callback then callback(enabled) end
    end)

    return container
end

local function CreateDangerButton(parent, text, icon, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 55)
    button.BackgroundColor3 = Theme.Danger
    button.Font = Enum.Font.GothamBlack
    button.Text = (icon or "") .. "  " .. text
    button.TextColor3 = Theme.Text
    button.TextSize = 15
    button.AutoButtonColor = false
    button.ZIndex = 63
    button.Parent = parent
    CreateCorner(button, 12)
    CreateStroke(button, Theme.Error, 1.5, 0.4)
    CreatePremiumRipple(button)

    button.MouseEnter:Connect(function()
        if not ScriptRunning then return end
        Sounds.Hover:Play()
        AnimateSpring(button, {BackgroundColor3 = Theme.Error, Size = UDim2.new(1, 4, 0, 58)}, 0.2)
    end)
    button.MouseLeave:Connect(function()
        if not ScriptRunning then return end
        AnimateSpring(button, {BackgroundColor3 = Theme.Danger, Size = UDim2.new(1, 0, 0, 55)}, 0.2)
    end)
    button.MouseButton1Click:Connect(function()
        if not ScriptRunning then return end
        Sounds.Click:Play()
        if callback then callback() end
    end)

    return button
end

-- Create Settings Content
CreateSectionLabel(SettingsContent, "ESP НАСТРОЙКИ", "👁")

CreateToggle(SettingsContent, "Включить ESP", "📦", Config.EspEnabled, function(value)
    Config.EspEnabled = value
    RefreshESPVisibility()
    SaveCurrentConfig()
end)

CreateSectionLabel(SettingsContent, "ЛУЧ НАСТРОЙКИ", "✨")

CreateToggle(SettingsContent, "Включить луч", "💫", Config.BeamEnabled, function(value)
    Config.BeamEnabled = value
    AimBeam.Enabled = value and IsWatching
    SaveCurrentConfig()
end)

CreateSectionLabel(SettingsContent, "ЧАТ АДМИНОВ", "💬")

CreateToggle(SettingsContent, "Мониторинг чата", "📡", Config.AdminChatEnabled, function(value)
    Config.AdminChatEnabled = value
    SaveCurrentConfig()
end)

CreateSectionLabel(SettingsContent, "ИНТЕРФЕЙС", "🎨")

CreateToggle(SettingsContent, "Частицы", "✨", Config.ParticlesEnabled, function(value)
    Config.ParticlesEnabled = value
    SaveCurrentConfig()
end)

CreateToggle(SettingsContent, "Эффект размытия", "🌫", Config.BlurEnabled, function(value)
    Config.BlurEnabled = value
    SaveCurrentConfig()
end)

CreateSectionLabel(SettingsContent, "ОПОВЕЩЕНИЯ", "🔔")

CreateToggle(SettingsContent, "Алерт об админах", "🚨", Config.AdminAlertEnabled, function(value)
    Config.AdminAlertEnabled = value
    SaveCurrentConfig()
end)

CreateSectionLabel(SettingsContent, "УПРАВЛЕНИЕ", "⚙")

CreateDangerButton(SettingsContent, "ВЫГРУЗИТЬ СКРИПТ", "🗑", function()
    Animate(SettingsFrame, {Position = UDim2.new(0.5, 0, 1.5, 0)}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In)
    Animate(SettingsOverlay, {BackgroundTransparency = 1}, 0.3)
    HideBlur()
    task.wait(0.5)
    UnloadScript()
end)

-- Save Button
local SaveSettingsBtn = Instance.new("TextButton")
SaveSettingsBtn.Size = UDim2.new(1, -36, 0, 52)
SaveSettingsBtn.Position = UDim2.new(0, 18, 1, -68)
SaveSettingsBtn.BackgroundColor3 = Theme.Primary
SaveSettingsBtn.Font = Enum.Font.GothamBlack
SaveSettingsBtn.Text = "💾  СОХРАНИТЬ И ЗАКРЫТЬ"
SaveSettingsBtn.TextColor3 = Theme.Text
SaveSettingsBtn.TextSize = 15
SaveSettingsBtn.AutoButtonColor = false
SaveSettingsBtn.ZIndex = 70
SaveSettingsBtn.Parent = SettingsFrame
CreateCorner(SaveSettingsBtn, 12)
CreateAnimatedGradient(SaveSettingsBtn, {Theme.Primary, Theme.Secondary, Theme.Primary}, 90)
CreatePremiumRipple(SaveSettingsBtn)

SaveSettingsBtn.MouseEnter:Connect(function()
    Sounds.Hover:Play()
    AnimateSpring(SaveSettingsBtn, {Size = UDim2.new(1, -32, 0, 56)}, 0.2)
end)
SaveSettingsBtn.MouseLeave:Connect(function()
    AnimateSpring(SaveSettingsBtn, {Size = UDim2.new(1, -36, 0, 52)}, 0.2)
end)

SaveSettingsBtn.MouseButton1Click:Connect(function()
    if not ScriptRunning then return end
    Sounds.Success:Play()
    SaveCurrentConfig()

    Animate(SettingsFrame, {Position = UDim2.new(0.5, 0, 1.5, 0)}, 0.45, Enum.EasingStyle.Back, Enum.EasingDirection.In)
    Animate(SettingsOverlay, {BackgroundTransparency = 1}, 0.35)
    HideBlur()

    task.wait(0.45)
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
    card.Size = UDim2.new(1, -10, 0, 75)
    card.BackgroundColor3 = isAdmin and Color3.fromRGB(50, 40, 18) or Theme.BackgroundSecondary
    card.BackgroundTransparency = 0.2
    card.BorderSizePixel = 0
    card.ZIndex = 14
    card.ClipsDescendants = true
    card.Parent = targetScroll
    CreateCorner(card, 14)

    if isAdmin then
        CreateStroke(card, Theme.Warning, 1.5, 0.3)
    else
        CreateStroke(card, Theme.Border, 1, 0.5)
    end

    -- Avatar
    local avatarFrame = Instance.new("Frame")
    avatarFrame.Size = UDim2.new(0, 52, 0, 52)
    avatarFrame.Position = UDim2.new(0, 12, 0.5, -26)
    avatarFrame.BackgroundColor3 = Theme.Surface
    avatarFrame.BorderSizePixel = 0
    avatarFrame.ZIndex = 15
    avatarFrame.Parent = card
    CreateCorner(avatarFrame, 26)
    CreateStroke(avatarFrame, isAdmin and Theme.Warning or Theme.Primary, 2, 0.4)

    local avatar = Instance.new("ImageLabel")
    avatar.Size = UDim2.new(1, -6, 1, -6)
    avatar.Position = UDim2.new(0, 3, 0, 3)
    avatar.BackgroundTransparency = 1
    avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. player.UserId .. "&w=150&h=150"
    avatar.ZIndex = 16
    avatar.Parent = avatarFrame
    CreateCorner(avatar, 23)

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
    infoFrame.Position = UDim2.new(0, 74, 0, 0)
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
    username.TextSize = 11
    username.TextXAlignment = Enum.TextXAlignment.Left
    username.ZIndex = 16
    username.Parent = infoFrame

    if isAdmin then
        local rankLabel = Instance.new("TextLabel")
        rankLabel.Size = UDim2.new(1, 0, 0, 14)
        rankLabel.Position = UDim2.new(0, 0, 0, 50)
        rankLabel.BackgroundTransparency = 1
        rankLabel.Font = Enum.Font.Gotham
        rankLabel.Text = "📊 Ранг: " .. (rank or 0) .. " | " .. (roleName or "Unknown")
        rankLabel.TextColor3 = Theme.WarningGlow
        rankLabel.TextSize = 10
        rankLabel.TextXAlignment = Enum.TextXAlignment.Left
        rankLabel.ZIndex = 16
        rankLabel.Parent = infoFrame
    end

    -- Watch Button
    local watchButton = Instance.new("TextButton")
    watchButton.Size = UDim2.new(0, 48, 0, 48)
    watchButton.Position = UDim2.new(1, -60, 0.5, -24)
    watchButton.BackgroundColor3 = isAdmin and Theme.Warning or Theme.Primary
    watchButton.Font = Enum.Font.GothamBold
    watchButton.Text = "👁"
    watchButton.TextColor3 = Theme.Text
    watchButton.TextSize = 20
    watchButton.AutoButtonColor = false
    watchButton.ZIndex = 15
    watchButton.BorderSizePixel = 0
    watchButton.Parent = card
    CreateCorner(watchButton, 12)
    CreatePremiumRipple(watchButton)

    if not isAdmin then
        CreateAnimatedGradient(watchButton, {Theme.Primary, Theme.Gradient2}, 45)
    end

    local normalCardColor = isAdmin and Color3.fromRGB(50, 40, 18) or Theme.BackgroundSecondary
    local hoverCardColor = isAdmin and Color3.fromRGB(62, 50, 25) or Theme.BackgroundTertiary

    watchButton.MouseEnter:Connect(function()
        if not ScriptRunning then return end
        Sounds.Hover:Play()
        AnimateSpring(watchButton, {Size = UDim2.new(0, 54, 0, 54)}, 0.2)
        Animate(card, {BackgroundColor3 = hoverCardColor, BackgroundTransparency = 0.1}, 0.2)
    end)

    watchButton.MouseLeave:Connect(function()
        if not ScriptRunning then return end
        AnimateSpring(watchButton, {Size = UDim2.new(0, 48, 0, 48)}, 0.2)
        Animate(card, {BackgroundColor3 = normalCardColor, BackgroundTransparency = 0.2}, 0.2)
    end)

    watchButton.MouseButton1Click:Connect(function()
        if not ScriptRunning then return end
        Sounds.Click:Play()
        CurrentTarget = player.Character

        if CurrentTarget and CurrentTarget:FindFirstChild("Humanoid") then
            IsWatching = true

            WatchingName.Text = (isAdmin and "⚠ " or "") .. (player.DisplayName or player.Name)
            WatchingID.Text = "ID: " .. player.UserId .. (isAdmin and " | Ранг: " .. (rank or 0) or "")
            WatchingStatus.TextColor3 = isAdmin and Theme.Warning or Theme.Primary
            WatchingIndicator.BackgroundColor3 = isAdmin and Theme.Warning or Theme.Success

            Camera.CameraSubject = CurrentTarget:FindFirstChild("Humanoid")

            Animate(MainContainer, {Position = UDim2.new(0.5, 0, 1.6, 0)}, 0.45, Enum.EasingStyle.Back, Enum.EasingDirection.In)

            task.wait(0.45)
            MainGui.Enabled = false
            IsMenuOpen = false
            MainContainer.Position = UDim2.new(0.5, 0, 0.5, 0)

            WatchingGui.Enabled = true
            WatchingBar.Position = UDim2.new(0.5, 0, 1, 55)
            AnimateSpring(WatchingBar, {Position = UDim2.new(0.5, 0, 1, -25)}, 0.5)

            CreateESP(player, CurrentTarget)

            pcall(function()
                StarterGui:SetCore('SendNotification', {
                    Title = "👁 Qwen Aimviewer",
                    Text = "Наблюдение за " .. (player.DisplayName or player.Name),
                    Duration = 2.5
                })
            end)
        else
            pcall(function()
                StarterGui:SetCore('SendNotification', {
                    Title = "👁 Qwen Aimviewer",
                    Text = "Персонаж не найден!",
                    Duration = 2
                })
            end)
        end
    end)

    -- Entry animation
    card.BackgroundTransparency = 1
    card.Position = UDim2.new(-0.3, 0, 0, 0)
    AnimateSpring(card, {BackgroundTransparency = 0.2, Position = UDim2.new(0, 0, 0, 0)}, 0.45)

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
                local isAdmin = CheckIfAdmin(player)

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

    task.delay(delayTime + 0.3, function()
        if ScriptRunning and PlayerScroll and PlayerScroll.Parent then
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
        task.delay(0.15, function()
            if not ScriptRunning or not AdminScroll or not AdminScroll.Parent then return end

            local noAdmins = Instance.new("Frame")
            noAdmins.Size = UDim2.new(1, -15, 0, 90)
            noAdmins.BackgroundColor3 = Theme.Success
            noAdmins.BackgroundTransparency = 0.85
            noAdmins.BorderSizePixel = 0
            noAdmins.ZIndex = 14
            noAdmins.Parent = AdminScroll
            CreateCorner(noAdmins, 12)
            CreateStroke(noAdmins, Theme.Success, 1, 0.5)

            local noAdminsText = Instance.new("TextLabel")
            noAdminsText.Size = UDim2.new(1, 0, 1, 0)
            noAdminsText.BackgroundTransparency = 1
            noAdminsText.Font = Enum.Font.GothamMedium
            noAdminsText.Text = "✅ Админов не обнаружено\nМожно играть спокойно!"
            noAdminsText.TextColor3 = Theme.Success
            noAdminsText.TextSize = 14
            noAdminsText.ZIndex = 15
            noAdminsText.Parent = noAdmins
        end)
    end

    task.delay(delayTime + 0.3, function()
        if ScriptRunning and AdminScroll and AdminScroll.Parent then
            AdminScroll.CanvasSize = UDim2.new(0, 0, 0, AdminListLayout.AbsoluteContentSize.Y + 15)
        end
    end)
end

local function CheckAllAdmins()
    if not ScriptRunning or not IsAuthenticated then return end

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
-- MENU FUNCTIONS (определяем forward-declared функции)
-- ═══════════════════════════════════════════════════════════
local function ShowLoginScreen()
    if not ScriptRunning then return end

    LoginGui.Enabled = true
    LoginOverlay.BackgroundTransparency = 1
    LoginContainer.Position = UDim2.new(0.5, 0, 0.5, -50)
    LoginContainer.BackgroundTransparency = 1

    ShowBlur(25)
    Animate(LoginOverlay, {BackgroundTransparency = 0.4}, 0.45)
    AnimateSpring(LoginContainer, {Position = UDim2.new(0.5, 0, 0.5, 0), BackgroundTransparency = 0}, 0.6)

    Sounds.Open:Play()
end

local function HideLoginScreen()
    if not ScriptRunning then return end

    Animate(LoginContainer, {Position = UDim2.new(0.5, 0, 0.5, 50), BackgroundTransparency = 1}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In)
    Animate(LoginOverlay, {BackgroundTransparency = 1}, 0.35)
    HideBlur()

    task.wait(0.4)
    LoginGui.Enabled = false
    LoginContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
    LoginContainer.BackgroundTransparency = 0
end

ShowMainMenu = function()
    if IsMenuOpen or not ScriptRunning then return end
    IsMenuOpen = true

    MainGui.Enabled = true
    MainContainer.Position = UDim2.new(0.5, 0, -0.6, 0)

    Sounds.Open:Play()
    AnimateSpring(MainContainer, {Position = UDim2.new(0.5, 0, 0.5, 0)}, 0.55)

    UpdatePlayerList()
    UpdateAdminList()
end

HideMainMenu = function()
    if not IsMenuOpen or not ScriptRunning then return end

    Sounds.Close:Play()
    Animate(MainContainer, {Position = UDim2.new(0.5, 0, 1.6, 0)}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In)

    task.wait(0.4)
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

    Animate(WatchingBar, {Position = UDim2.new(0.5, 0, 1, 55)}, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.In)

    task.wait(0.35)
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

-- Unload Function
UnloadScript = function()
    if not ScriptRunning then return end
    ScriptRunning = false

    pcall(function() Sounds.Success:Play() end)

    if IsWatching then
        IsWatching = false
        CurrentTarget = nil
        if Character and Character:FindFirstChild("Humanoid") then
            Camera.CameraSubject = Character:FindFirstChild("Humanoid")
        end
    end

    HideBlur()
    if BlurEffect then
        pcall(function() BlurEffect:Destroy() end)
        BlurEffect = nil
    end

    for _, objects in pairs(ESPObjects) do
        for _, obj in pairs(objects) do
            pcall(function() if obj then obj:Destroy() end end)
        end
    end
    ESPObjects = {}

    pcall(function() if ESPFolder then ESPFolder:Destroy() end end)
    pcall(function() if AimBeam then AimBeam:Destroy() end end)
    pcall(function() if BeamAttachment0 then BeamAttachment0:Destroy() end end)
    pcall(function() if BeamAttachment1 then BeamAttachment1:Destroy() end end)

    for _, gui in pairs(UIElements.AllGuis) do
        pcall(function() if gui then gui:Destroy() end end)
    end

    for _, sound in pairs(Sounds) do
        pcall(function() if sound then sound:Destroy() end end)
    end

    pcall(function()
        StarterGui:SetCore('SendNotification', {
            Title = "👋 Qwen Aimviewer v6.0",
            Text = "Скрипт выгружен! До встречи!",
            Duration = 3
        })
    end)
end

-- ═══════════════════════════════════════════════════════════
-- HEADER BUTTON EVENTS (теперь функции определены)
-- ═══════════════════════════════════════════════════════════
ChangelogButton.MouseButton1Click:Connect(function()
    if not ScriptRunning then return end
    Sounds.Click:Play()
    ShowChangelog()
end)

ChatButton.MouseButton1Click:Connect(function()
    if not ScriptRunning then return end
    Sounds.Click:Play()

    if AdminChatGui then
        if AdminChatGui.Enabled then
            local chatContainer = AdminChatGui:FindFirstChild("ChatContainer")
            if chatContainer then
                Animate(chatContainer, {Position = UDim2.new(1, 350, 0.5, 0)}, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.In, function()
                    AdminChatGui.Enabled = false
                    chatContainer.Position = UDim2.new(1, -20, 0.5, 0)
                end)
            end
        else
            AdminChatGui.Enabled = true
            local chatContainer = AdminChatGui:FindFirstChild("ChatContainer")
            if chatContainer then
                chatContainer.Position = UDim2.new(1, 350, 0.5, 0)
                AnimateSpring(chatContainer, {Position = UDim2.new(1, -20, 0.5, 0)}, 0.45)
            end
        end
    end
end)

SettingsButton.MouseButton1Click:Connect(function()
    if not ScriptRunning then return end
    Sounds.Click:Play()

    SettingsGui.Enabled = true
    SettingsOverlay.BackgroundTransparency = 1
    SettingsFrame.Position = UDim2.new(0.5, 0, -0.6, 0)

    ShowBlur(22)
    Animate(SettingsOverlay, {BackgroundTransparency = 0.5}, 0.35)
    AnimateSpring(SettingsFrame, {Position = UDim2.new(0.5, 0, 0.5, 0)}, 0.5)
end)

CloseButton.MouseButton1Click:Connect(function()
    if not ScriptRunning then return end
    Sounds.Click:Play()
    HideMainMenu()
end)

-- ═══════════════════════════════════════════════════════════
-- LOGIN EVENT
-- ═══════════════════════════════════════════════════════════
LoginButton.MouseButton1Click:Connect(function()
    if not ScriptRunning then return end
    Sounds.Click:Play()

    local enteredUsername = UsernameInput.Text
    local enteredPassword = PasswordInput.Text

    if enteredUsername == _AUTH_KEY_1() and enteredPassword == _AUTH_KEY_2() then
        Sounds.Success:Play()
        IsAuthenticated = true

        LoginMessage.Text = "✅ Добро пожаловать!"
        LoginMessage.TextColor3 = Theme.Success

        AnimateSpring(LoginButton, {BackgroundColor3 = Theme.Success}, 0.25)

        task.wait(0.6)
        HideLoginScreen()

        task.wait(0.35)

        CreateAdminChatGui()
        SetupChatMonitoring()
        ShowMainMenu()
        RefreshAllESP()
        CheckAllAdmins()

        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "👁 Qwen Aimviewer v6.0",
                Text = "Добро пожаловать! by kaito & akiko",
                Duration = 3
            })
        end)
    else
        LoginMessage.Text = "❌ Неверный логин или пароль!"
        LoginMessage.TextColor3 = Theme.Error

        ShakeAnimation(LoginContainer, 10, 0.35)
        AnimateSpring(LoginButton, {BackgroundColor3 = Theme.Error}, 0.2)
        task.delay(0.4, function()
            if LoginButton and LoginButton.Parent then
                AnimateSpring(LoginButton, {BackgroundColor3 = Theme.Primary}, 0.25)
            end
        end)
    end
end)

-- ═══════════════════════════════════════════════════════════
-- INPUT & SEARCH EVENTS
-- ═══════════════════════════════════════════════════════════
SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
    if ScriptRunning then
        UpdatePlayerList(SearchInput.Text)
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or not ScriptRunning then return end

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

-- ═══════════════════════════════════════════════════════════
-- PLAYER EVENTS
-- ═══════════════════════════════════════════════════════════
Players.PlayerAdded:Connect(function(player)
    if not ScriptRunning then return end

    player.CharacterAdded:Connect(function(character)
        if not ScriptRunning or not IsAuthenticated then return end
        task.wait(1.5)

        if Config.EspEnabled and ScriptRunning and IsAuthenticated then
            CreateESP(player, character)
        end

        local isAdmin, rank = CheckIfAdmin(player)
        if isAdmin and Config.AdminAlertEnabled and ScriptRunning and IsAuthenticated then
            local roleName = GetAdminRole(player)
            ShowAdminAlert(player.DisplayName or player.Name, rank, roleName)
        end
    end)

    player.Chatted:Connect(function(message)
        if not ScriptRunning or not IsAuthenticated then return end
        local isAdmin, rank = CheckIfAdmin(player)
        if Config.AdminChatEnabled then
            AddAdminChatMessage(
                player.DisplayName or player.Name,
                message,
                rank,
                isAdmin
            )
        end
    end)

    if IsMenuOpen and ScriptRunning then
        task.wait(0.4)
        UpdatePlayerList(SearchInput.Text)
        UpdateAdminList()
    end

    task.wait(1)
    if not ScriptRunning or not IsAuthenticated then return end

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
        task.wait(0.25)
        UpdatePlayerList(SearchInput.Text)
        UpdateAdminList()
    end
end)

-- Character Respawn
LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    Character = newCharacter
end)

-- ═══════════════════════════════════════════════════════════
-- BEAM RENDER LOOP
-- ═══════════════════════════════════════════════════════════
RunService.RenderStepped:Connect(function()
    if not ScriptRunning or not IsAuthenticated then return end

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
        Title = "👁 Qwen Aimviewer v6.0",
        Text = "Нажми F4 для открытия | by kaito & akiko",
        Duration = 4
    })
end)

print("")
print("═══════════════════════════════════════════════════════")
print("   👁 Qwen Aimviewer v6.0 Ultimate загружен!")
print("   👨‍💻 Создатели: kaito & akiko")
print("   🎮 Нажми F4 для открытия")
print("   🔐 Логин: solvetpain | Пароль: kaito")
print("═══════════════════════════════════════════════════════")
print("")
