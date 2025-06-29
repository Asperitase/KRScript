-- Roblox API Module
local RobloxAPI = {}
RobloxAPI.__index = RobloxAPI

function RobloxAPI.new(communication)
    local self = setmetatable({}, RobloxAPI)
    self.communication = communication
    return self
end

function RobloxAPI:HitResource()
    return self.communication:WaitForChild("HitResource")
end

return RobloxAPI 