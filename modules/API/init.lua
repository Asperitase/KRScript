local API = {}
API.__index = API

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

function API:New(String)
    local obj = {
        name = String or "Empty"
    }
    setmetatable(obj, self)
    return obj
end

function API:GetPlayers()
    return Players:GetPlayers()
end

function API:GetLocalPlayer()
    if Players.LocalPlayer then
        return Players.LocalPlayer
    else
        warn("LocalPlayer is nil (called from server?)")
        return nil
    end
end

function API:GetPlayerByUID(UID)
    return Players:GetPlayerByUserId(UID)
end

function API:GetWorkspace(
    Child: string,
    TargetPlayer: Player | string?
)

    local RootNode = Workspace:WaitForChild(Child)
    if not RootNode then
        warn(`Workspace.{Child} not found`)
        return nil
    end

    if TargetPlayer then
        local name = typeof(TargetPlayer) == "Instance" and TargetPlayer.Name or TargetPlayer
        return RootNode:FindFirstChild(name)
    end

    return RootNode
end

function API:GetLocalIsland()
    return self:GetWorkspace("Plots", self:GetLocalPlayer().Name)
end

function API:GetReplicatedStorage(Child: string)
    return ReplicatedStorage:WaitForChild(Child)
end

function API:GetReplicatedStorageCommunication()
    return ReplicatedStorage:WaitForChild("Communication")
end

function API:IsSpawned() : boolean
    local LocalPlayer = self:GetLocalPlayer()
    local Character = LocalPlayer and LocalPlayer.Character
    return Character ~= nil and Character.Parent == Workspace
end

function API:WaitForSpawn(): Model
    local LocalPlayer = self:GetLocalPlayer()
   
    if self:IsSpawned() then
        return LocalPlayer.Character
    end

    return LocalPlayer.CharacterAdded:Wait()
end


return API