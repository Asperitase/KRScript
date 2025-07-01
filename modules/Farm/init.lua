-- init.lua (Farm)
-- Инициализация таба Farm

local FarmTab = {}

function FarmTab.Register(Window)
    local tab = Window:CreateTab{
        Title = "Фарм",
        Icon = "ph-farming"
    }
    -- Добавляем элемент, чтобы таб был виден
    tab:AddParagraph{
        Title = "Фарм",
        Content = "Здесь будут функции фарма."
    }
end

return FarmTab 