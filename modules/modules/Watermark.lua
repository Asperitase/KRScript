local Watermark = {}
Watermark.__index = Watermark

function Watermark.New(API)
    local self = setmetatable({}, Watermark)
    
    self.API = API
    self.Gui = nil
    self.Container = nil
    self.TextLabel = nil
    self.Avatar = nil
    self.UpdateConnection = nil
    self.Enabled = false
    
    return self
end

function Watermark:Create()
    if self.Gui then return end
    local localPlayer = self.API:GetLocalPlayer()
    if not localPlayer then return end
    -- ScreenGui
    self.Gui = Instance.new("ScreenGui")
    self.Gui.Name = "KR_Watermark"
    self.Gui.ResetOnSpawn = false
    self.Gui.DisplayOrder = 10000
    self.Gui.IgnoreGuiInset = true
    self.Gui.Parent = self.API:GetCoreGui()
    -- Контейнер
    self.Container = Instance.new("Frame")
    self.Container.AnchorPoint = Vector2.new(1, 0)
    self.Container.Position = UDim2.new(1, -18, 0, 18)
    self.Container.Size = UDim2.fromOffset(270, 38)
    self.Container.BackgroundColor3 = Color3.fromRGB(32, 36, 44)
    self.Container.BackgroundTransparency = 0.18
    self.Container.BorderSizePixel = 0
    self.Container.Parent = self.Gui
    self.Container.ZIndex = 2
    -- Скругление Fluent
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 11)
    corner.Parent = self.Container
    -- Имитация блюра: белый полупрозрачный градиент + тонкий белый UIStroke
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255))
    }
    gradient.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0.85),
        NumberSequenceKeypoint.new(1, 0.95)
    }
    gradient.Rotation = 45
    gradient.Parent = self.Container
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255,255,255)
    stroke.Thickness = 1
    stroke.Transparency = 0.85
    stroke.Parent = self.Container
    -- Аватар или Lucide user-иконка
    self.Avatar = Instance.new("ImageLabel")
    self.Avatar.Size = UDim2.fromOffset(26, 26)
    self.Avatar.Position = UDim2.fromOffset(8, 6)
    self.Avatar.BackgroundTransparency = 1
    self.Avatar.ZIndex = 3
    self.Avatar.Parent = self.Container
    local avatarCorner = Instance.new("UICorner")
    avatarCorner.CornerRadius = UDim.new(1, 0)
    avatarCorner.Parent = self.Avatar
    local avatarStroke = Instance.new("UIStroke")
    avatarStroke.Color = Color3.fromRGB(82, 139, 255)
    avatarStroke.Thickness = 1.2
    avatarStroke.Parent = self.Avatar
    -- Попытка загрузить headshot
    local userId = localPlayer.UserId
    local headshotUrl = string.format("https://www.roblox.com/headshot-thumbnail/image?userId=%d&width=420&height=420&format=png", userId)
    self.Avatar.Image = headshotUrl
    -- fallback: если headshot не загрузился, показываем Lucide user-иконку
    self.Avatar.ImageTransparency = 0
    spawn(function()
        wait(0.5)
        if self.Avatar.ImageRectSize == Vector2.new(0,0) or self.Avatar.Image == "" then
            self.Avatar.Image = "rbxassetid://16044046992" -- Lucide user
            self.Avatar.ImageColor3 = Color3.fromRGB(82, 139, 255)
        end
    end)
    -- Lucide-иконки (rbxassetid)
    local iconY = 10
    local iconSize = 14
    local sepColor = Color3.fromRGB(82, 139, 255)
    local function addIcon(assetId, x)
        local icon = Instance.new("ImageLabel")
        icon.Size = UDim2.fromOffset(iconSize, iconSize)
        icon.Position = UDim2.fromOffset(x, iconY)
        icon.BackgroundTransparency = 1
        icon.Image = assetId
        icon.ImageColor3 = sepColor
        icon.ZIndex = 3
        icon.Parent = self.Container
        return icon
    end
    local function addSep(x)
        local sep = Instance.new("Frame")
        sep.Size = UDim2.new(0, 1, 0.7, 0)
        sep.Position = UDim2.fromOffset(x, 6)
        sep.BackgroundColor3 = sepColor
        sep.BackgroundTransparency = 0
        sep.BorderSizePixel = 0
        sep.ZIndex = 2
        sep.Parent = self.Container
        return sep
    end
    -- Иконки и сепараторы
    local nickX = 40
    local pingIconX = 110
    local playersIconX = 160
    local timeIconX = 210
    local fpsIconX = 185
    addSep(98)
    addSep(148)
    addSep(198)
    addSep(178)
    addIcon("rbxassetid://16044047136", pingIconX) -- globe
    addIcon("rbxassetid://16044046884", playersIconX) -- users
    addIcon("rbxassetid://16044047018", timeIconX) -- clock
    addIcon("rbxassetid://16044046797", fpsIconX) -- Lucide line chart (fps)
    -- Текстовые поля
    self.NickLabel = Instance.new("TextLabel")
    self.NickLabel.Position = UDim2.fromOffset(nickX, 0)
    self.NickLabel.Size = UDim2.new(0, 60, 1, 0)
    self.NickLabel.BackgroundTransparency = 1
    self.NickLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.NickLabel.RichText = true
    self.NickLabel.Font = Enum.Font.GothamBold
    self.NickLabel.TextSize = 16
    self.NickLabel.TextColor3 = Color3.fromRGB(255,255,255)
    self.NickLabel.ZIndex = 4
    self.NickLabel.Parent = self.Container
    self.PingLabel = Instance.new("TextLabel")
    self.PingLabel.Position = UDim2.fromOffset(pingIconX+18, 0)
    self.PingLabel.Size = UDim2.new(0, 32, 1, 0)
    self.PingLabel.BackgroundTransparency = 1
    self.PingLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.PingLabel.Font = Enum.Font.GothamMedium
    self.PingLabel.TextSize = 15
    self.PingLabel.TextColor3 = Color3.fromRGB(227,242,253)
    self.PingLabel.ZIndex = 4
    self.PingLabel.Parent = self.Container
    self.PlayersLabel = Instance.new("TextLabel")
    self.PlayersLabel.Position = UDim2.fromOffset(playersIconX+18, 0)
    self.PlayersLabel.Size = UDim2.new(0, 24, 1, 0)
    self.PlayersLabel.BackgroundTransparency = 1
    self.PlayersLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.PlayersLabel.Font = Enum.Font.GothamMedium
    self.PlayersLabel.TextSize = 15
    self.PlayersLabel.TextColor3 = Color3.fromRGB(227,242,253)
    self.PlayersLabel.ZIndex = 4
    self.PlayersLabel.Parent = self.Container
    self.TimeLabel = Instance.new("TextLabel")
    self.TimeLabel.Position = UDim2.fromOffset(timeIconX+18, 0)
    self.TimeLabel.Size = UDim2.new(0, 40, 1, 0)
    self.TimeLabel.BackgroundTransparency = 1
    self.TimeLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.TimeLabel.Font = Enum.Font.GothamMedium
    self.TimeLabel.TextSize = 15
    self.TimeLabel.TextColor3 = Color3.fromRGB(227,242,253)
    self.TimeLabel.ZIndex = 4
    self.TimeLabel.Parent = self.Container
    -- FPS Label
    self.FPSLabel = Instance.new("TextLabel")
    self.FPSLabel.Position = UDim2.fromOffset(fpsIconX+18, 0)
    self.FPSLabel.Size = UDim2.new(0, 32, 1, 0)
    self.FPSLabel.BackgroundTransparency = 1
    self.FPSLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.FPSLabel.Font = Enum.Font.GothamMedium
    self.FPSLabel.TextSize = 15
    self.FPSLabel.TextColor3 = Color3.fromRGB(227,242,253)
    self.FPSLabel.ZIndex = 4
    self.FPSLabel.Parent = self.Container
    -- Анимация появления
    self.Container.BackgroundTransparency = 1
    self.Container.Visible = true
    local TweenService = self.API:GetTweenService()
    TweenService:Create(self.Container, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0.18}):Play()
    self.Enabled = true
    self:StartUpdate()
    self._fps = 60
    self._lastFpsUpdate = tick()
    self._frames = 0
    self._connFps = self.API:GetRunService().RenderStepped:Connect(function()
        self._frames = self._frames + 1
        local now = tick()
        if now - self._lastFpsUpdate >= 0.5 then
            self._fps = math.floor(self._frames / (now - self._lastFpsUpdate) + 0.5)
            self._frames = 0
            self._lastFpsUpdate = now
        end
    end)
end

function Watermark:GetPing()
    return math.floor(self.API:GetNetworkPing()).."ms"
end

function Watermark:GetPlayersOnline()
    local ok, count = pcall(function()
        return self.API:GetPlayersCount()
    end)
    return ok and count or 0
end

function Watermark:Refresh()
    if not self.Enabled or not self.NickLabel then return end
    local localPlayer = self.API:GetLocalPlayer()
    if not localPlayer then return end
    local ping = self:GetPing()
    local count = self:GetPlayersOnline()
    local timeStr = os.date("%H:%M:%S")
    self.NickLabel.Text = string.format("<b>%s</b>", localPlayer.DisplayName or "Player")
    self.PingLabel.Text = tostring(ping)
    self.PlayersLabel.Text = tostring(count)
    self.FPSLabel.Text = tostring(self._fps) .. " fps"
    self.TimeLabel.Text = timeStr
end

function Watermark:StartUpdate()
    if self.UpdateConnection then
        self.UpdateConnection:Disconnect()
    end
    
    -- Первое обновление сразу
    self:Refresh()
    
    -- Периодическое обновление раз в 0,5 с
    self.UpdateConnection = self.API:GetRunService().RenderStepped:Connect(function(dt)
        if tick() % 0.5 < dt then
            self:Refresh()
        end
    end)
end

function Watermark:StopUpdate()
    if self.UpdateConnection then
        self.UpdateConnection:Disconnect()
        self.UpdateConnection = nil
    end
end

function Watermark:Show()
    if self.Gui then
        self.Gui.Enabled = true
        self.Enabled = true
        self:StartUpdate()
    else
        self:Create()
    end
end

function Watermark:Hide()
    if self.Gui then
        self.Gui.Enabled = false
        self.Enabled = false
        self:StopUpdate()
    end
end

function Watermark:SetPosition(x, y)
    if self.Container then
        self.Container.Position = UDim2.new(1, -(x or 12), 0, y or 10)
    end
end

function Watermark:Destroy()
    self.Enabled = false
    self:StopUpdate()
    if self._connFps then self._connFps:Disconnect() end
    if self.Gui then
        pcall(function() self.Gui:Destroy() end)
        self.Gui = nil
    end
    self.Container = nil
    self.NickLabel = nil
    self.PingLabel = nil
    self.PlayersLabel = nil
    self.FPSLabel = nil
    self.TimeLabel = nil
    self.Avatar = nil
end

return Watermark 