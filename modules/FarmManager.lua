local FarmManager = {}
FarmManager.__index = FarmManager

local HealthResources = {
    ["Bamboo"] = 6,
    ["Big Bamboo"] = 10,
    ["Big Obsidian"] = 35,
    ["Big Stone"] = 5,
    ["Banana Tree"] = 28,
    ["Cactus"] = 15,
    ["Iron Ore"] = 9,
    ["Magma Crystal"] = 15,
    ["Magma Tree"] = 20,
    ["Mushroom"] = 23,
    ["Oak Tree"] = 10,
    ["Obsidian"] = 25,
    ["Palm Tree"] = 4,
    ["Pine Tree"] = 5,
    ["Salt"] = 32,
    ["Sand"] = 12,
    ["Stone"] = 3,
    ["Wheat"] = 7,
    ["Crystal"] = 37
}

function FarmManager.New(Api)
    local self = setmetatable({}, FarmManager)
    self.Api = Api
    self.Player = Api:GetLocalPlayer()
    self.Communication = Api:GetCommunication()
    self.Island = Api:GetIsland()
    self.LandPlots = Api:GetLandPlots()
    self.SelectedHiveTypes = {Bee = true, MagmaBee = true}
    self.DistanceHive = 500
    self.AutoHiveTask = nil
    self.AutoHarvestTask = nil
    self.HarvestDelay = 0
    self.SelectedBerryTypes = {Strawberry = true, Blueberries = true}
    self.SelectedResourceTypes = {Bamboo = true, Cactus = true}
    self.AutoResourceTask = nil
    self.OnlyMaxHp = true
    self.BasePlayer = Api
    self.SelectedPlayers = {self.Player.Name}
    return self
end

function FarmManager:SetSelectedTypes(Types)
    self.SelectedHiveTypes = Types
end

function FarmManager:SetDistance(Distance)
    self.DistanceHive = Distance
end

function FarmManager:SetHarvestDelay(Delay)
    self.HarvestDelay = Delay
end

function FarmManager:SetSelectedBerryTypes(Types)
    self.SelectedBerryTypes = Types
end

function FarmManager:SetSelectedResourceTypes(Types)
    self.SelectedResourceTypes = Types
end

function FarmManager:SetOnlyMaxHp(Value)
    self.OnlyMaxHp = Value
end

function FarmManager:SetSelectedPlayers(Players)
    self.SelectedPlayers = Players
end

function FarmManager:StartupTask(TaskName, Value)
    local TaskMap = {
        autohive = {task = "AutoHiveTask", func = "AutoHive"},
        autoharvest = {task = "AutoHarvestTask", func = "AutoHarvest"},
        instafarm = {task = "AutoResourceTask", func = "AutoResource"}
    }
    
    local Config = TaskMap[TaskName]
    if not Config then return end
    
    if Value then
        if self[Config.task] then return end
        self[Config.task] = task.spawn(function()
            while true do
                self[Config.func](self)
                task.wait(1)
            end
        end)
    else
        if self[Config.task] then
            task.cancel(self[Config.task])
            self[Config.task] = nil
        end
    end
end

function FarmManager:AutoHive()
    local Character = self.Player.Character or self.Player.CharacterAdded:Wait()
    local HumanPart = Character:WaitForChild("HumanoidRootPart")
    local Island = self.Api:GetIsland()
    for _, Spot in ipairs(Island:GetDescendants()) do
        if Spot:IsA("Model") and Spot.Name:match("Spot") then
            local PrimaryPart = Spot.PrimaryPart or Spot:FindFirstChildWhichIsA("BasePart")
            if PrimaryPart then
                local Distance = (HumanPart.Position - PrimaryPart.Position).Magnitude * 0.8
                if Distance < self.DistanceHive then
                    local Parent = Spot.Parent
                    local IsBee, IsMagma = false, false
                    for _, Child in ipairs(Parent:GetChildren()) do
                        if string.find(Child.Name, "MagmaHiveRunner") and self.SelectedHiveTypes.MagmaBee then
                            IsMagma = true
                        elseif string.find(Child.Name, "HiveRunner") and not string.find(Child.Name, "Magma") and self.SelectedHiveTypes.Bee then
                            IsBee = true
                        end
                    end
                    if IsBee or IsMagma then
                        local CollectPrompt = nil
                        for _, Prompt in ipairs(Spot:GetDescendants()) do
                            if Prompt:IsA("ProximityPrompt") and Prompt.ActionText == "Collect" then
                                CollectPrompt = Prompt
                                break
                            end
                        end
                        if CollectPrompt and CollectPrompt.Enabled then
                            self.Communication:WaitForChild("Hive"):FireServer(Spot.Parent.Name, Spot.Name, 2)
                        end
                    end
                end
            end
        end
    end
end

function FarmManager:AutoHarvest()
    local Island = self.Api:GetIsland()
    for _, Plant in ipairs(Island:FindFirstChild("Plants"):GetChildren()) do
        local PromptHold = Plant:FindFirstChild("PromptHold")
        if PromptHold then
            local Prompt = PromptHold:FindFirstChildWhichIsA("ProximityPrompt")
            if Prompt and Prompt.ActionText == "Harvest" and Prompt.Enabled then
                local TypeValue = Plant:GetAttribute("Type")
                if self.SelectedBerryTypes[TypeValue] then
                    self.Communication:WaitForChild("Harvest"):FireServer(Plant.Name)
                    task.wait(self.HarvestDelay)
                end
            end
        end
    end
end

function FarmManager:AutoResource()
    local AllIslands = self.Api:GetAllIslands()
    
    for _, TargetPlayer in ipairs(self.SelectedPlayers) do
        local TargetIsland = AllIslands:FindFirstChild(TargetPlayer)
        if TargetIsland and TargetIsland:FindFirstChild("Resources") then
            local Resources = TargetIsland.Resources:GetChildren()
            for _, Resource in ipairs(Resources) do
                local Name = Resource.Name
                local Hp = Resource:GetAttribute("HP")
                local MaxHp = Resource:GetAttribute("MaxHP")
                local MinHp = HealthResources[Name]
                
                if self.SelectedResourceTypes[Name] and Hp and MinHp then
                    if self.OnlyMaxHp then
                        if Hp == MaxHp then
                            task.spawn(function()
                                while Resource:GetAttribute("HP") and Resource:GetAttribute("HP") > 0 do
                                    self.BasePlayer:HitResource(Resource)
                                    task.wait(0.001)
                                end
                            end)
                        end
                    else
                        if Hp <= MinHp then
                            self.BasePlayer:HitResource(Resource)
                        end
                    end
                end
            end
        end
    end
end

function FarmManager:Destroy()
    if self.AutoHiveTask then
        task.cancel(self.AutoHiveTask)
        self.AutoHiveTask = nil
    end
    if self.AutoHarvestTask then
        task.cancel(self.AutoHarvestTask)
        self.AutoHarvestTask = nil
    end
    if self.AutoResourceTask then
        task.cancel(self.AutoResourceTask)
        self.AutoResourceTask = nil
    end
end

return FarmManager 