-- init.lua (Farm)
-- Инициализация таба Farm

return function(Window)
    local Tab = Window:CreateTab{
        Title = "Farm",
        Icon = "leaf"
    }
    Tab:AddParagraph{
        Title = "Фарм",
        Content = "Здесь будут функции фарма."
    }
end 