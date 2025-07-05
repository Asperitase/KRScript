--------------------------------------------------------------------
--  Watermark.lua  ·  Dark glass, bold separators
--------------------------------------------------------------------
local Watermark = {}
Watermark.__index = Watermark

function Watermark.New(API)
    return setmetatable({
        API            = API,
        Enabled        = false,
        fps            = 60,
        _frames        = 0,
        _lastFpsUpdate = tick(),
    }, Watermark)
end

-- helper -----------------------------------------------------------
local function mk(class, props, parent)
    local o = Instance.new(class, parent)
    for k,v in pairs(props) do o[k] = v end
    return o
end

-- UI ---------------------------------------------------------------
function Watermark:_build()
    if self.Gui then return end
    local plr = self.API:GetLocalPlayer() if not plr then return end

    -- ScreenGui
    self.Gui = mk("ScreenGui", {
        Name="KR_Watermark", ResetOnSpawn=false, IgnoreGuiInset=true,
        DisplayOrder=10_000, ZIndexBehavior=Enum.ZIndexBehavior.Sibling
    }, self.API:GetCoreGui())

    -- Container
    self.Container = mk("Frame", {
        AnchorPoint=Vector2.new(1,0), Position=UDim2.new(1,-20,0,20),
        Size=UDim2.fromOffset(460,44),
        BackgroundColor3=Color3.fromRGB(22,25,31),
        BackgroundTransparency=0.25
    }, self.Gui)
    mk("UICorner",{CornerRadius=UDim.new(0,14)},self.Container)
    mk("UIStroke",{Color=Color3.fromRGB(255,255,255),Transparency=0.75},self.Container)

    -- Аватар
    self.Avatar = mk("ImageLabel",{
        Size=UDim2.fromOffset(34,34),Position=UDim2.fromOffset(10,5),
        BackgroundTransparency=1,
        Image=("https://www.roblox.com/headshot-thumbnail/image?userId=%d&width=420&height=420&format=png"):format(plr.UserId)
    },self.Container)
    mk("UICorner",{CornerRadius=UDim.new(1,0)},self.Avatar)
    mk("UIStroke",{Color=Color3.fromRGB(120,165,255),Thickness=1.2},self.Avatar)

    -- общий стиль текста
    local baseText = {
        BackgroundTransparency=1, Font=Enum.Font.Gotham, TextSize=15,
        TextColor3=Color3.fromRGB(235,245,255), TextYAlignment=Enum.TextYAlignment.Center,
        ZIndex=3
    }

    -- создаём лейблы
    self.NickLabel    = mk("TextLabel", baseText, self.Container)
    self.NickLabel.Font = Enum.Font.GothamBold
    self.PingLabel    = mk("TextLabel", baseText, self.Container)
    self.PlayersLabel = mk("TextLabel", baseText, self.Container)
    self.FPSLabel     = mk("TextLabel", baseText, self.Container)
    self.TimeLabel    = mk("TextLabel", baseText, self.Container)

    ----------------------------------------------------------------
    -- Раскладка + сепараторы
    ----------------------------------------------------------------
    local cursor = 54   -- старт после аватара
    local function segment(lbl, iconId, width)
        -- иконка Lucide (замени id при желании)
        mk("ImageLabel",{
            Size=UDim2.fromOffset(14,14),
            Position=UDim2.fromOffset(cursor,15),
            BackgroundTransparency=1,
            Image=iconId,
            ImageColor3=Color3.fromRGB(120,165,255),
            ZIndex=3
        },self.Container)
        cursor += 18

        lbl.Position = UDim2.fromOffset(cursor,0)
        lbl.Size     = UDim2.fromOffset(width,44)

        -- красивый «скруглённый» сепаратор
        local bar = mk("Frame",{
            Size=UDim2.new(0,2,0.68,0),
            Position=UDim2.fromOffset(cursor+width+6,7),
            BackgroundColor3=Color3.fromRGB(120,165,255),
            BorderSizePixel=0,
            ZIndex=2
        },self.Container)
        mk("UICorner",{CornerRadius=UDim.new(0,1)},bar)

        cursor += width + 20
    end

    segment(self.NickLabel   ,"rbxassetid://16044046814",110) -- user
    segment(self.PingLabel   ,"rbxassetid://16044047136",60)  -- wifi
    segment(self.PlayersLabel,"rbxassetid://16044046884",30)  -- users
    segment(self.FPSLabel    ,"rbxassetid://16044046797",64)  -- bar-chart
    -- последняя: время, без разделителя в конце
    mk("ImageLabel",{
        Size=UDim2.fromOffset(14,14), Position=UDim2.fromOffset(cursor,15),
        BackgroundTransparency=1, Image="rbxassetid://16044047018",
        ImageColor3=Color3.fromRGB(120,165,255), ZIndex=3
    },self.Container)
    cursor += 18
    self.TimeLabel.Position = UDim2.fromOffset(cursor,0)
    self.TimeLabel.Size     = UDim2.fromOffset(72,44)

    -- FPS подсчёт
    self._connFps = self.API:GetRunService().RenderStepped:Connect(function()
        self._frames += 1
        local t = tick()
        if t - self._lastFpsUpdate >= .5 then
            self.fps            = math.floor(self._frames/(t-self._lastFpsUpdate)+.5)
            self._frames        = 0
            self._lastFpsUpdate = t
        end
    end)
end

-- данные -----------------------------------------------------------
local function round(x) return math.floor(x+0.5) end
function Watermark:_refresh()
    local p = self.API:GetLocalPlayer() if not p then return end
    self.NickLabel.Text    = p.DisplayName
    self.PingLabel.Text    = ("%dms"):format(round(self.API:GetNetworkPing()*1000))
    self.PlayersLabel.Text = tostring(self.API:GetPlayersCount())
    self.FPSLabel.Text     = ("%d fps"):format(self.fps)
    self.TimeLabel.Text    = os.date("%H:%M:%S")
end

-- публичное API ----------------------------------------------------
function Watermark:Show()
    if self.Enabled then return end
    self.Enabled = true
    if not self.Gui then self:_build() else self.Gui.Enabled = true end
    self:_refresh()
    if self.Update then self.Update:Disconnect() end
    self.Update = self.API:GetRunService().RenderStepped:Connect(function(dt)
        if tick()%0.5<dt then self:_refresh() end
    end)
end

function Watermark:Hide()
    if not self.Enabled then return end
    self.Enabled=false
    if self.Update then self.Update:Disconnect() end
    if self.Gui then self.Gui.Enabled=false end
end

function Watermark:Destroy()
    if self.Update then self.Update:Disconnect() end
    if self._connFps then self._connFps:Disconnect() end
    if self.Gui then self.Gui:Destroy() end
    self.Gui,self.Container=nil,nil
    self.Enabled=false
end

return Watermark