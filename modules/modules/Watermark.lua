-- WatermarkGlass.lua  ·  2025-07-05
local Watermark = {}
Watermark.__index = Watermark

------------------------------------------------------------------ helpers
local function ui(cls, props, parent)
    local o = Instance.new(cls); for k,v in props do o[k]=v end; o.Parent = parent; return o
end
local function fmtTime() return os.date("%H:%M") end
local function round(x)  return math.floor(x+0.5) end

------------------------------------------------------------------ constructor
function Watermark.New(API)   -- Fluent нужен лишь для Lucide-иконок
    local self = setmetatable({}, Watermark)

    self.api      = API
    self.enabled  = false
    self.fps      = 60
    self._frames, self._t0 = 0, tick()

    return self
end

------------------------------------------------------------------ private · build
function Watermark:_build()
    if self.gui then return end
    local player   = self.api:GetLocalPlayer()
    local coreGui  = self.api:GetCoreGui()
    local RunSrv   = self.api:GetRunService()

    ---------------- ScreenGui
    self.gui = ui("ScreenGui",{Name="KR_WM",ResetOnSpawn=false,IgnoreGuiInset=true,DisplayOrder=9e4},coreGui)

    ---------------- common style
    local dark     = Color3.fromRGB(20,23,30)
    local accent   = Color3.fromRGB(122,176,255)

    local function newBlock(size,pos)
        local f = ui("Frame",{Size=size,Position=pos,BackgroundColor3=dark,BackgroundTransparency=.22},self.gui)
        ui("UICorner",{CornerRadius=UDim.new(0,12)},f)
        ui("UIStroke",{Color=Color3.fromRGB(255,255,255),Transparency=.8},f)
        return f
    end

    ---------------- block ▸ SERVER (центр-топ)
    self.blockSrv = newBlock(UDim2.fromOffset(260,34),UDim2.new(.5,-130,0,12))
    self.blockSrv.AnchorPoint = Vector2.new(.5,0)

    local srvTxt  = ui("TextLabel",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,
                    Font=Enum.Font.GothamMedium,TextColor3=Color3.new(1,1,1),TextSize=14},self.blockSrv)
    srvTxt.TextXAlignment = Enum.TextXAlignment.Center
    self._srvLabel = srvTxt

    ---------------- block ▸ PLAYER (право-топ)
    self.blockPlr = newBlock(UDim2.fromOffset(340,40),UDim2.new(1,-12,0,12))
    self.blockPlr.AnchorPoint = Vector2.new(1,0)

    -- аватар
    local avatar = ui("ImageLabel",{Size=UDim2.fromOffset(32,32),Position=UDim2.fromOffset(6,4),
        BackgroundTransparency=1,Image=("https://www.roblox.com/headshot-thumbnail/image?userId=%d&width=420&height=420&format=png")
        :format(player.UserId)},self.blockPlr)
    ui("UICorner",{CornerRadius=UDim.new(1,0)},avatar)
    ui("UIStroke",{Color=accent,Transparency=.2},avatar)

    -- текстовая линейка
    local base = {BackgroundTransparency=1,Font=Enum.Font.GothamMedium,
                  TextColor3=Color3.fromRGB(230,240,255),TextSize=14}
    local nick    = ui("TextLabel",base,self.blockPlr)
    nick.Font     = Enum.Font.GothamBold
    local fpsLbl  = ui("TextLabel",base,self.blockPlr)
    local timeLbl = ui("TextLabel",base,self.blockPlr)

    self._nick, self._fpsLbl, self._timeLbl = nick, fpsLbl, timeLbl

    -- позиционирование + разделители
    local cursor = 44
    local function segment(lbl,w)
        -- иконка Lucide

        cursor += 18
        lbl.Position = UDim2.fromOffset(cursor,0)
        lbl.Size     = UDim2.fromOffset(w,40)
        cursor += w + 12
        -- сепаратор (кроме последнего)
        local bar = ui("Frame",{Size=UDim2.new(0,2,0.65,0),Position=UDim2.fromOffset(cursor-6,7),
                      BackgroundColor3=accent,BackgroundTransparency=.05,BorderSizePixel=0},self.blockPlr)
        ui("UICorner",{CornerRadius=UDim.new(0,1)},bar)
    end

    segment(nick,     120,"user")
    segment(fpsLbl,    60,"activity")   -- fps
    segment(timeLbl,   56,"clock")      -- время (без секун)

    -- fps счёт
    self._connFPS = RunSrv.RenderStepped:Connect(function()
        self._frames+=1
        local t=tick()
        if t-self._t0>.5 then
            self.fps = math.floor(self._frames/(t-self._t0)+.5)
            self._frames, self._t0 = 0, t
        end
    end)
end

------------------------------------------------------------------ private · refresh
function Watermark:_refresh()
    local p = self.api:GetLocalPlayer()
    self._nick.Text    = p.DisplayName
    self._fpsLbl.Text  = ("%d fps"):format(self.fps)
    self._timeLbl.Text = fmtTime()

    local ping  = math.floor(self.api:GetNetworkPing()*1000+0.5)
    self._srvLabel.Text = string.format("%s  |  %d ms", game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name, ping)
end

------------------------------------------------------------------ public API
function Watermark:Show()
    if self.enabled then return end
    self.enabled = true
    if not self.gui then self:_build() else self.gui.Enabled=true end
    self:_refresh()
    if self._upd then self._upd:Disconnect() end
    self._upd = self.api:GetRunService().RenderStepped:Connect(function(dt)
        if tick()%0.5<dt then self:_refresh() end
    end)
end

function Watermark:Hide()
    if not self.enabled then return end
    self.enabled=false
    if self._upd then self._upd:Disconnect() end
    self.gui.Enabled=false
end

function Watermark:Destroy()
    if self._upd then self._upd:Disconnect() end
    if self._connFPS then self._connFPS:Disconnect() end
    if self.gui then self.gui:Destroy() end
end

return Watermark