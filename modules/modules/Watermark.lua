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
    self.Container.Size = UDim2.fromOffset(220, 36)
    self.Container.BackgroundColor3 = Color3.fromRGB(32, 36, 44)
    self.Container.BackgroundTransparency = 0.12
    self.Container.BorderSizePixel = 0
    self.Container.Parent = self.Gui
    self.Container.ZIndex = 2
    -- DropShadow (шире, тоньше, прозрачнее)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "DropShadow"
    shadow.Image = "rbxassetid://1316045217"
    shadow.BackgroundTransparency = 1
    shadow.Size = UDim2.new(1, 32, 1, 12)
    shadow.Position = UDim2.new(0, -16, 0, 4)
    shadow.ImageColor3 = Color3.fromRGB(0,0,0)
    shadow.ImageTransparency = 0.85
    shadow.ZIndex = 0
    shadow.Parent = self.Container
    -- Скругление Fluent
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = self.Container
    -- Аватар (круглый с рамкой)
    self.Avatar = Instance.new("ImageLabel")
    self.Avatar.Size = UDim2.fromOffset(28, 28)
    self.Avatar.Position = UDim2.fromOffset(6, 4)
    self.Avatar.BackgroundTransparency = 1
    self.Avatar.Image = string.format("https://www.roblox.com/headshot-thumbnail/image?userId=%d&width=420&height=420&format=png", localPlayer.UserId)
    self.Avatar.ZIndex = 3
    self.Avatar.Parent = self.Container
    local avatarCorner = Instance.new("UICorner")
    avatarCorner.CornerRadius = UDim.new(1, 0)
    avatarCorner.Parent = self.Avatar
    local avatarStroke = Instance.new("UIStroke")
    avatarStroke.Color = Color3.fromRGB(82, 139, 255)
    avatarStroke.Thickness = 1.5
    avatarStroke.Parent = self.Avatar
    -- Lucide-иконки (rbxassetid)
    local iconY = 6
    local iconSize = 16
    local pingIcon = Instance.new("ImageLabel")
    pingIcon.Size = UDim2.fromOffset(iconSize, iconSize)
    pingIcon.Position = UDim2.fromOffset(62, iconY)
    pingIcon.BackgroundTransparency = 1
    pingIcon.Image = "rbxassetid://16044047136" -- Lucide globe
    pingIcon.ImageColor3 = Color3.fromRGB(82, 139, 255)
    pingIcon.ZIndex = 3
    pingIcon.Parent = self.Container
    local playersIcon = Instance.new("ImageLabel")
    playersIcon.Size = UDim2.fromOffset(iconSize, iconSize)
    playersIcon.Position = UDim2.fromOffset(120, iconY)
    playersIcon.BackgroundTransparency = 1
    playersIcon.Image = "rbxassetid://16044046884" -- Lucide users
    playersIcon.ImageColor3 = Color3.fromRGB(82, 139, 255)
    playersIcon.ZIndex = 3
    playersIcon.Parent = self.Container
    local timeIcon = Instance.new("ImageLabel")
    timeIcon.Size = UDim2.fromOffset(iconSize, iconSize)
    timeIcon.Position = UDim2.fromOffset(170, iconY)
    timeIcon.BackgroundTransparency = 1
    timeIcon.Image = "rbxassetid://16044047018" -- Lucide clock
    timeIcon.ImageColor3 = Color3.fromRGB(82, 139, 255)
    timeIcon.ZIndex = 3
    timeIcon.Parent = self.Container
    -- Текстовая часть
    self.TextLabel = Instance.new("TextLabel")
    self.TextLabel.Position = UDim2.fromOffset(36, 0)
    self.TextLabel.Size = UDim2.new(1, -44, 1, 0)
    self.TextLabel.BackgroundTransparency = 1
    self.TextLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.TextLabel.RichText = true
    self.TextLabel.Font = Enum.Font.GothamMedium
    self.TextLabel.TextSize = 16
    self.TextLabel.TextColor3 = Color3.fromRGB(255,255,255)
    self.TextLabel.ZIndex = 4
    self.TextLabel.Parent = self.Container
    -- Анимация появления
    self.Container.BackgroundTransparency = 1
    self.Container.Visible = true
    local TweenService = self.API:GetTweenService()
    TweenService:Create(self.Container, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0.12}):Play()
    self.Enabled = true
    self:StartUpdate()
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
    if not self.Enabled or not self.TextLabel then return end
    local localPlayer = self.API:GetLocalPlayer()
    if not localPlayer then return end
    local ping = self:GetPing()
    local count = self:GetPlayersOnline()
    local timeStr = os.date("%H:%M:%S")
    self.TextLabel.Text = string.format(
        "<font color='#FFFFFF'><b>%s</b></font>  " ..
        "<font color='#528bff'>|</font>  " ..
        "<font color='#E3F2FD'>%s</font>  " ..
        "<font color='#528bff'>|</font>  " ..
        "<font color='#E3F2FD'>%d</font>  " ..
        "<font color='#528bff'>|</font>  " ..
        "<font color='#E3F2FD'>%s</font>",
        localPlayer.DisplayName or "Player", ping, count, timeStr
    )
    -- Размер контейнера не меняем, он фиксированный и компактный
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
    if self.Gui then
        pcall(function() self.Gui:Destroy() end)
        self.Gui = nil
    end
    self.Container = nil
    self.TextLabel = nil
    self.Avatar = nil
end

return Watermark 