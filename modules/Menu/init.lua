-- init.lua
-- Точка входа для меню

local Window = loadstring(game:HttpGet("https://raw.githubusercontent.com/Asperitase/KRScript/main/modules/Menu/Window.lua?t=" .. tick()))()

local Tab = Window:CreateTab{
    Title = "Farm",
    Icon = "leaf"
}

-- Подгружаем только таб Farm
local FarmTab = loadstring(game:HttpGet("https://raw.githubusercontent.com/Asperitase/KRScript/main/modules/Farm/init.lua?t=" .. tick()))()
if FarmTab and FarmTab.Register then FarmTab:Register(Window) end

return Window 