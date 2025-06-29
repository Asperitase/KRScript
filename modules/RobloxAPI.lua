-- Roblox API Module
local RobloxAPI = {}
RobloxAPI.__index = RobloxAPI

function RobloxAPI.new()
    local self = setmetatable({}, RobloxAPI)
    
    -- Инициализация сервисов
    self.players = game:GetService("Players")
    self.replicated_storage = game:GetService("ReplicatedStorage")
    self.workspace = game:GetService("Workspace")
    
    -- Инициализация переменных
    self.local_player = self.players.LocalPlayer
    self.plots = self.workspace:WaitForChild("Plots"):WaitForChild(self.local_player.Name)
    self.land = self.plots:FindFirstChild("Land")
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

function RobloxAPI:GetPlots()
    return self.plots
end

function RobloxAPI:GetLand()
    return self.land
end

function RobloxAPI:GetCommunication()
    return self.communication
end

return RobloxAPI 