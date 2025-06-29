-- Roblox API Module
local RobloxAPI = {}
RobloxAPI.__index = RobloxAPI

function RobloxAPI.new()
    local self = setmetatable({}, RobloxAPI)
    
    self.players = game:GetService("Players")
    self.replicated_storage = game:GetService("ReplicatedStorage")
    self.workspace = game:GetService("Workspace")
    
    self.local_player = self.players.LocalPlayer
    self.local_island = self.workspace:WaitForChild("Plots"):WaitForChild(self.local_player.Name)
    self.land_cube = self.local_island:FindFirstChild("Land")
    self.communication = self.replicated_storage:WaitForChild("Communication")
    
    return self
end

function RobloxAPI:HitResource(args)
    if not self.communication then
        warn("Communication не инициализирован для HitResource")
        return
    end
    local hit_resource = self.communication:WaitForChild("HitResource")
    if hit_resource then
        return hit_resource:FireServer(args)
    else
        warn("Не удалось найти HitResource в Communication")
    end
end

-- Геттеры для доступа к сервисам и переменным
function RobloxAPI:GetPlayers()
    return self.players
end

function RobloxAPI:GetReplicatedStorage()
    return self.replicated_storage
end

function RobloxAPI:GetWorkspace()
    return self.workspace
end

function RobloxAPI:GetLocalPlayer()
    return self.local_player
end

function RobloxAPI:GetIsland()
    return self.local_island
end

function RobloxAPI:GetPlatform()
    return self.land_cube
end

function RobloxAPI:GetCommunication()
    return self.communication
end

return RobloxAPI 