-- Roblox API Module
local RobloxAPI = {}
RobloxAPI.__index = RobloxAPI

function RobloxAPI.New()
    local self = setmetatable({}, RobloxAPI)
    
    self.Players = game:GetService("Players")
    self.ReplicatedStorage = game:GetService("ReplicatedStorage")
    self.Workspace = game:GetService("Workspace")
    
    self.LocalPlayer = self.Players.LocalPlayer
    self.LocalIsland = self.Workspace:WaitForChild("Plots"):WaitForChild(self.LocalPlayer.Name)
    self.Communication = self.ReplicatedStorage:WaitForChild("Communication")
    
    return self
end

function RobloxAPI:HitResource(Args)
    return self.Communication:WaitForChild("HitResource"):FireServer(Args)
end

function RobloxAPI:CollectFishCrateContents()
    return self.Communication:WaitForChild("CollectFishCrateContents"):FireServer()    
end

function RobloxAPI:AutoHive(Parent, Name)
    return self.Communication:WaitForChild("Hive"):FireServer(Parent, Name, 2)
end

function RobloxAPI:AutoHarvest(Name)
    return self.Communication:WaitForChild("Harvest"):FireServer(Name)
end

function RobloxAPI:SpamFish(Position, Count)
    return self.Communication:WaitForChild("Fish"):InvokeServer(Position, Count)
end

-- Геттеры для доступа к сервисам и переменным
function RobloxAPI:GetPlayers()
    return self.Players
end

function RobloxAPI:GetReplicatedStorage()
    return self.ReplicatedStorage
end

function RobloxAPI:GetWorkspace()
    return self.Workspace
end

function RobloxAPI:GetLocalPlayer()
    return self.LocalPlayer     
end

function RobloxAPI:GetLocalIsland()
    return self.LocalIsland
end

function RobloxAPI:GetCommunication()
    return self.Communication
end

function RobloxAPI:GetAllIslands()
    return self.Workspace:WaitForChild("Plots")
end

function RobloxAPI:GetAllPlayers()
    return self.Players:GetPlayers()
end


return RobloxAPI 