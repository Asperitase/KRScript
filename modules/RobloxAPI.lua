-- Roblox API Module
local RobloxAPI = {}
RobloxAPI.__index = RobloxAPI

function RobloxAPI.new(communication)
    local self = setmetatable({}, RobloxAPI)
    self.communication = communication
    return self
end

function RobloxAPI:HitResource(args)
    return self.communication:WaitForChild("HitResource"):FireServer(args)
end

return RobloxAPI 