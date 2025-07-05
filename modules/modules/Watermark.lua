------------------------------------------------------------------ Watermark.lua
local Watermark  = {} ; Watermark.__index = Watermark

-- helper ----------------------------------------------------------------------
local function ui(c,p,par) local o=Instance.new(c);for k,v in p do o[k]=v end;o.Parent=par;return o end
local grey      = Color3.fromRGB(22,25,31)
local accent    = Color3.fromRGB(122,176,255)

-------------------------------------------------------------------------------
function Watermark.New(API,Fluent)
    return setmetatable({api=API,fluent=Fluent,fps=60,_frames=0,_t0=tick()},Watermark)
end

-- build -----------------------------------------------------------------------
function Watermark:_build()
    if self.gui then return end
    local p        = self.api:GetLocalPlayer()
    self.gui       = ui("ScreenGui",{Name="KR_WM",ResetOnSpawn=false,IgnoreGuiInset=true,
                                     DisplayOrder=9e4,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},
                                     self.api:GetCoreGui())

    -- контейнер: auto-width
    self.frame     = ui("Frame",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-12,0,12),
                                 AutomaticSize=Enum.AutomaticSize.X,Size=UDim2.fromOffset(0,44),
                                 BackgroundColor3=grey,BackgroundTransparency=.22},self.gui)
    ui("UICorner",{CornerRadius=UDim.new(0,14)},self.frame)
    ui("UIStroke",{Color=Color3.fromRGB(255,255,255),Transparency=.8},self.frame)

    local list = ui("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,
                                    VerticalAlignment=Enum.VerticalAlignment.Center,
                                    Padding=UDim.new(0,10)},self.frame)

    -- avatar ------------------------------------------------------------------
    local avatar = ui("ImageLabel",{Size=UDim2.fromOffset(34,34),BackgroundTransparency=1,
        Image=("https://www.roblox.com/headshot-thumbnail/image?userId=%d&width=420&height=420&format=png")
        :format(p.UserId)},self.frame)
    ui("UICorner",{CornerRadius=UDim.new(1,0)},avatar)
    ui("UIStroke",{Color=accent,Transparency=.2},avatar)

    -- шаблон текста -----------------------------------------------------------
    local baseT = {
        BackgroundTransparency=1,
        Font=Enum.Font.GothamMedium,
        TextSize=14,
        TextColor3=Color3.fromRGB(230,240,255),
        TextYAlignment=Enum.TextYAlignment.Center,
        AutomaticSize=Enum.AutomaticSize.X,
        Size=UDim2.new(0,0,1,0),
        TextXAlignment=Enum.TextXAlignment.Left
    }

    local function bar()
        ui("TextLabel", {
            Text = "║",
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            TextSize = 16,
            TextColor3 = Color3.fromRGB(122,176,255),
            AutomaticSize = Enum.AutomaticSize.X,
            Size = UDim2.new(0,0,1,0),
            TextYAlignment = Enum.TextYAlignment.Center,
            TextXAlignment = Enum.TextXAlignment.Center
        }, self.frame)
    end
    
    self.nick   = ui("TextLabel", baseT, self.frame)  self.nick.Font = Enum.Font.GothamBold
    bar()
    self.server = ui("TextLabel", baseT, self.frame)
    bar()
    self.ping   = ui("TextLabel", baseT, self.frame)
    bar()
    self.clock  = ui("TextLabel", baseT, self.frame)

    -- Удаляем Lucide-иконки --------------------------------------------------
    -- local function addIcon(name)
    --     local ico=self.fluent:CreateIcon(name,14,accent) ; ico.Parent=self.frame
    -- end
    -- addIcon("server")
    -- addIcon("wifi")
    -- addIcon("clock")

    -- порядок элементов в листе:
    -- avatar | nick | sep | server | icon | sep | ping | icon | sep | clock | icon
    list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        -- обновление позиции (anchor=1,0)
        self.frame.Position = UDim2.new(1,-12,0,12)
    end)
end

-- refresh ---------------------------------------------------------------------
local function fmtTime() return os.date("%H:%M") end
function Watermark:_refresh()
    local plr=self.api:GetLocalPlayer()
    self.nick.Text   = plr.DisplayName
    self.server.Text = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
    self.ping.Text   = ("%d ms"):format(math.floor(self.api:GetNetworkPing()))
    self.clock.Text  = fmtTime()
end

-- public ----------------------------------------------------------------------
function Watermark:Show()
    if self.enabled then return end
    self.enabled=true
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
    if self.gui then self.gui:Destroy() end
end

return Watermark