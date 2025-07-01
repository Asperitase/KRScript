-- init.lua (Farm)
-- Инициализация таба Farm

return function(Window)
    print("[FarmTab] Window:", Window)
    if not Window or not Window.CreateTab then
        warn("[FarmTab] Window невалиден или не содержит CreateTab!")
        return
    end
    local Tab = Window:CreateTab{
        Title = "Farm",
        Icon = "leaf"
    }
    print("[FarmTab] Tab:", Tab)
    if Tab then
        Tab:AddParagraph{
            Title = "Фарм",
            Content = "Здесь будут функции фарма."
        }
    else
        warn("[FarmTab] Tab не создан!")
    end
end 