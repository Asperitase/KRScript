local MovementTab = {}
MovementTab.__index = MovementTab

function MovementTab.new(Window)
    local self = setmetatable({}, MovementTab)
    if not Window or not Window.CreateTab then
        return self
    end
    self.Tab = Window:CreateTab{
        Title = "Movement",
        Icon = "walk"
    }
    return self
end

return MovementTab 