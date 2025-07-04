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

function API:GetUserInputService()
    return game:GetService("UserInputService")
end

function API:GetRunService()
    return game:GetService("RunService")
end

function API:IsClient(): boolean
    return self:GetRunService():IsClient()
end

function API:GetPlayers(): { Player }
    return Players:GetPlayers()
end

function API:GetLocalPlayer(): Player?
    if Players.LocalPlayer then
        return Players.LocalPlayer
    else
        warn("LocalPlayer is nil (called from server?)")
        return nil
    end
end

function API:GetCharacter(): Player?
    return self:GetLocalPlayer().Character
end

function API:GetHumanoid(): Player?
    local Character = self:GetCharacter() or self:GetLocalPlayer().CharacterAdded:Wait()
    return Character:FindFirstChildOfClass("Humanoid")
end

function API:GetHumanoidRootPart()
    local Character = self:GetCharacter()
    if Character then
        return Character:FindFirstChild("HumanoidRootPart")
    end
    return nil
end

function API:GetPlayerByUID(uid: number): Player?
    return Players:GetPlayerByUserId(uid)
end

function API:GetWorkspace(
    Child: string,
    TargetPlayer: Player | string?
): Instance?
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

function API:GetLocalIsland(): Instance?
    return self:GetWorkspace("Plots", self:GetLocalPlayer().Name)
end

function API:GetReplicatedStorage(Child: string): Instance?
    return ReplicatedStorage:WaitForChild(Child)
end

function API:GetReplicatedStorageCommunication(): Instance?
    return ReplicatedStorage:WaitForChild("Communication")
end

function API:IsSpawned() : boolean
    local LocalPlayer = self:GetLocalPlayer()
    local Character = LocalPlayer and LocalPlayer.Character
    return Character ~= nil and Character.Parent == Workspace
end

-- function API:WaitForSpawn(): Model
--     local LocalPlayer = self:GetLocalPlayer()
   
--     if self:IsSpawned() then
--         return LocalPlayer.Character
--     end

--     LocalPlayer.CharacterAdded:Wait()
--     return LocalPlayer.Character
-- end

function API:GetTweenService()
    return game:GetService("TweenService")
end

function API:GetHttpService()
    return game:GetService("HttpService")
end

function API:GetCoreGui()
    return game:GetService("CoreGui")
end

function API:GetServerStats()
    return game:GetService("Stats")
end

function API:GetNetworkPing()
    return math.clamp(self:GetServerStats().Network.ServerStatsItem["Data Ping"]:GetValue(), 10, 700)
end

function API:GetPlayersCount()
    return #Players:GetPlayers()
end

return API