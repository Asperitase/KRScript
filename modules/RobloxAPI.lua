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
    return self.communication:WaitForChild("HitResource"):FireServer(args)
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

function RobloxAPI:GetAllIsland()
    return self.workspace:WaitForChild("Plots")
end

function RobloxAPI:GetAllPlayers()
    return self.players:GetPlayers()
end

return RobloxAPI 