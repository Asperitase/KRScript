-- init.lua (Farm)
-- Инициализация таба Farm

local FarmTab = {}

function FarmTab.Register(Window)
    local tab = Window:CreateTab{
        Title = "Фарм",
        Icon = "leaf" -- стандартная иконка FluentMenu
    }
end

return FarmTab 