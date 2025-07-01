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
end 