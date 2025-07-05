--------------------------------------------------------------------
--  Watermark.lua  ·  Glass-morphism edition
--------------------------------------------------------------------
local Watermark = {}
Watermark.__index = Watermark

--  ⟩ конструктор
function Watermark.New(API)
    return setmetatable({
        API            = API,
        Enabled        = false,
        fps            = 60,
        _frames        = 0,
        _lastFpsUpdate = tick(),
    }, Watermark)
end

--== helpers ========================================================

local function mk(instance, props, parent)
    local obj = Instance.new(instance)
    for k, v in pairs(props) do obj[k] = v end
    obj.Parent = parent
    return obj
end

--== создание UI ====================================================

function Watermark:_build()
    if self.Gui then return end
    local plr  = self.API:GetLocalPlayer()
    if not plr then return end

    ----------------------------------------------------------------
    -- ScreenGui
    ----------------------------------------------------------------
    self.Gui = mk("ScreenGui", {
        Name            = "KR_Watermark",
        ResetOnSpawn    = false,
        IgnoreGuiInset  = true,
        DisplayOrder    = 10_000,
        Enabled         = true,
        ZIndexBehavior  = Enum.ZIndexBehavior.Sibling,
    }, self.API:GetCoreGui())

    ----------------------------------------------------------------
    -- Контейнер (glass-morph)
    ----------------------------------------------------------------
    self.Container = mk("Frame", {
        AnchorPoint            = Vector2.new(1, 0),
        Position               = UDim2.new(1, -20, 0, 20),
        Size                   = UDim2.fromOffset(460, 42), -- ⟵ увеличено
        BackgroundTransparency = 0.55,
        BackgroundColor3       = Color3.fromRGB(255, 255, 255),
    }, self.Gui)

    mk("UICorner", {CornerRadius = UDim.new(0, 14)}, self.Container)
    mk("UIStroke", {
        Color        = Color3.fromRGB(255, 255, 255),
        Thickness    = 1,
        Transparency = 0.75,
    }, self.Container)

    -- мягкий inner-gradient
    mk("UIGradient", {
        Rotation = 135,
        Transparency = NumberSequence.new{
            NumberSequenceKeypoint.new(0, 0.6),
            NumberSequenceKeypoint.new(1, 0.85)
        }
    }, self.Container)

    ----------------------------------------------------------------
    -- Аватар
    ----------------------------------------------------------------
    self.Avatar = mk("ImageLabel", {
        Size                   = UDim2.fromOffset(30, 30),
        Position               = UDim2.fromOffset(8, 6),
        BackgroundTransparency = 1,
        Image = "https://www.roblox.com/headshot-thumbnail/image?userId="..plr.UserId.."&width=420&height=420&format=png"
    }, self.Container)
    mk("UICorner", {CornerRadius = UDim.new(1, 0)}, self.Avatar)
    mk("UIStroke", {
        Color        = Color3.fromRGB(90, 150, 255),
        Thickness    = 1,
        Transparency = 0.15
    }, self.Avatar)

    ----------------------------------------------------------------
    -- Шаблон для текста
    ----------------------------------------------------------------
    local textProps = {
        BackgroundTransparency = 1,
        Font         = Enum.Font.Gotham,
        TextColor3   = Color3.fromRGB(235, 245, 255),
        TextSize     = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex       = 2,
    }

    self.NickLabel    = mk("TextLabel", textProps, self.Container)
    self.PingLabel    = mk("TextLabel", textProps, self.Container)
    self.PlayersLabel = mk("TextLabel", textProps, self.Container)
    self.FPSLabel     = mk("TextLabel", textProps, self.Container)
    self.TimeLabel    = mk("TextLabel", textProps, self.Container)

    self.NickLabel.Font = Enum.Font.GothamBold

    -- динамический уголок: разделители-Line
    local function sep(x)
        mk("Frame", {
            Size                   = UDim2.new(0, 1, 0.7, 0),
            Position               = UDim2.fromOffset(x, 6),
            BackgroundColor3       = Color3.fromRGB(90, 150, 255),
            BackgroundTransparency = 0.1,
            BorderSizePixel        = 0,
            ZIndex                 = 1
        }, self.Container)
    end

    ----------------------------------------------------------------
    -- позиционирование
    ----------------------------------------------------------------
    local x = 46
    local function place(lbl, w)
        lbl.Position = UDim2.fromOffset(x, 0)
        lbl.Size     = UDim2.fromOffset(w, 42)
        x = x + w + 12
        sep(x - 6)
    end

    place(self.NickLabel,    100)
    place(self.PingLabel,    55)
    place(self.PlayersLabel, 30)
    place(self.FPSLabel,     48)
    place(self.TimeLabel,    60)

    -- fps счёт
    self._connFps = self.API:GetRunService().RenderStepped:Connect(function()
        self._frames += 1
        local now = tick()
        if now - self._lastFpsUpdate >= 0.5 then
            self.fps = math.floor(self._frames / (now - self._lastFpsUpdate) + 0.5)
            self._frames = 0
            self._lastFpsUpdate = now
        end
    end)
end

--== данные =========================================================

function Watermark:_getPing()
    return math.floor(self.API:GetNetworkPing() * 1000 + 0.5)
end
function Watermark:_playerCount()
    return self.API:GetPlayersCount()
end

function Watermark:_refresh()
    local p = self.API:GetLocalPlayer()
    if not p then return end
    self.NickLabel.Text    = "<b>" .. p.DisplayName .. "</b>"
    self.PingLabel.Text    = ("%dms"):format(self:_getPing())
    self.PlayersLabel.Text = tostring(self:_playerCount())
    self.FPSLabel.Text     = ("%d fps"):format(self.fps)
    self.TimeLabel.Text    = os.date("%H:%M:%S")
end

--== публичные методы ===============================================

function Watermark:Show()
    if self.Enabled then return end
    self.Enabled = true

    if not self.Gui then
        self:_build()
    else
        self.Gui.Enabled = true
    end

    self:_refresh()

    if self.Update then self.Update:Disconnect() end
    self.Update = self.API:GetRunService().RenderStepped:Connect(function(dt)
        if tick() % 0.5 < dt then
            self:_refresh()
        end
    end)
end

function Watermark:Hide()
    if not self.Enabled then return end
    self.Enabled = false
    if self.Update then self.Update:Disconnect() end
    if self.Gui then self.Gui.Enabled = false end
end

function Watermark:Destroy()
    if self.Update then self.Update:Disconnect() end
    if self._connFps then self._connFps:Disconnect() end
    if self.Gui then self.Gui:Destroy() end
    self.Gui, self.Container = nil, nil
    self.Enabled = false
end

return Watermark