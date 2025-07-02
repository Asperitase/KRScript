local FarmTab = {}
FarmTab.__index = FarmTab

function FarmTab.new(Window)
    local self = setmetatable({}, FarmTab)
    if not Window or not Window.CreateTab then
        return self
    end
    self.Tab = Window:CreateTab{
        Title = "Farm",
        Icon = "leaf"
    }
    return self
end

return FarmTab 