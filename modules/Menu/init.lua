-- init.lua
-- Точка входа для меню

local FluentMenu = loadstring(game:HttpGet("https://github.com/ActualMasterOogway/Fluent-Renewed/releases/download/v1.0.8/Fluent.luau?t=" .. tick()))()
local Window = FluentMenu:CreateWindow{ 
    Title = "KRScript",
    SubTitle = "by idredakx | v1.0.1",
    TabWidth = 160,
    Size = UDim2.fromOffset(830, 525),
    Resize = true,
    MinSize = Vector2.new(470, 380),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.Q
}
local FarmTab = loadstring(game:HttpGet("https://raw.githubusercontent.com/Asperitase/KRScript/main/modules/Farm/init.lua?t=" .. tick()))()
if FarmTab then FarmTab(Window) end 
