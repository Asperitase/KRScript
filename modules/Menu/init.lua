-- init.lua
-- ООП-стиль для Menu

local FluentMenu = loadstring(game:HttpGet("https://github.com/ActualMasterOogway/Fluent-Renewed/releases/download/v1.0.8/Fluent.luau?t=" .. tick()))()
local FarmTab = loadstring(game:HttpGet("https://raw.githubusercontent.com/Asperitase/KRScript/main/modules/Farm/init.lua?t=" .. tick()))()
local MovementTab = loadstring(game:HttpGet("https://raw.githubusercontent.com/Asperitase/KRScript/main/modules/Movement/init.lua?t=" .. tick()))()

local Menu = {}
Menu.__index = Menu

function Menu.new()
    local self = setmetatable({}, Menu)
    self.Window = FluentMenu:CreateWindow{
        Title = "KRScript",
        SubTitle = "by idredakx | v1.0",
        TabWidth = 160,
        Size = UDim2.fromOffset(830, 525),
        Resize = true,
        MinSize = Vector2.new(470, 380),
        Acrylic = false,
        Theme = "Dark",
        MinimizeKey = Enum.KeyCode.Q
    }
    self:initTabs()
    return self
end

function Menu:initTabs()
    if FarmTab then FarmTab.new(self.Window) end
    if MovementTab then MovementTab.new(self.Window) end
end

return Menu 
