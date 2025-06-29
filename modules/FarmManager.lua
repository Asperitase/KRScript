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
    self.SelectedHiveTypes = {Bee = true, MagmaBee = true}
    self.DistanceHive = 500
    self.AutoHiveTask = nil
    self.AutoHarvestTask = nil
    self.SelectedBerryTypes = {Strawberry = true, Blueberries = true}
    self.SelectedResourceTypes = {Bamboo = true, Cactus = true}
    self.AutoResourceTask = nil
    self.AutoCollectFishTask = nil
    self.SpamFishTask = nil
    self.OnlyMaxHp = true
    self.BasePlayer = Api
    self.SelectedPlayers = {Api:GetLocalPlayer().Name}
    return self
end

function FarmManager:SetSelectedTypes(Types)
    self.SelectedHiveTypes = Types
end

function FarmManager:SetDistance(Distance)
    self.DistanceHive = Distance
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
        instafarm = {task = "AutoResourceTask", func = "AutoResource"},
        autocollectfish = {task = "AutoCollectFishTask", func = "AutoCollectFish"},
        spamfish = {task = "SpamFishTask", func = "SpamFish"}
    }
    
    local Config = TaskMap[TaskName]
    if not Config then 
        return 
    end
        
    if Value then
        if self[Config.task] then 
            return 
        end
        self[Config.task] = task.spawn(function()
            while true do
                self[Config.func](self)
                task.wait(0.01)
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
    local Character = self.BasePlayer:GetLocalPlayer().Character
    if not Character then return end
    
    local HumanPart = Character:FindFirstChild("HumanoidRootPart")
    if not HumanPart then return end
    
    local LocalIsland = self.BasePlayer:GetLocalIsland()
    if not LocalIsland then return end
    
    for _, Spot in ipairs(LocalIsland:GetDescendants()) do
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
                            self.BasePlayer:AutoHive(Spot.Parent.Name, Spot.Name)
                        end
                    end
                end
            end
        end
    end
end

function FarmManager:AutoHarvest()
    for _, Plant in ipairs(self.BasePlayer:GetLocalIsland():FindFirstChild("Plants"):GetChildren()) do
        local PromptHold = Plant:FindFirstChild("PromptHold")
        if PromptHold then
            local Prompt = PromptHold:FindFirstChildWhichIsA("ProximityPrompt")
            if Prompt and Prompt.ActionText == "Harvest" and Prompt.Enabled then
                local TypeValue = Plant:GetAttribute("Type")
                if self.SelectedBerryTypes[TypeValue] then
                    self.BasePlayer:AutoHarvest(Plant.Name)
                end
            end
        end
    end
end

function FarmManager:AutoResource()
    for _, TargetPlayer in ipairs(self.SelectedPlayers) do
        local TargetIsland = self.BasePlayer:GetAllIslands():FindFirstChild(TargetPlayer)
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
                                    task.wait(0.05)
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

function FarmManager:AutoCollectFish()
    for _, LandPlace in ipairs(self.BasePlayer:GetLocalIsland():FindFirstChild("Land"):GetChildren()) do
        local FishCrate = LandPlace:FindFirstChild("FISHCRATE")
        if FishCrate then
            local Amount = FishCrate.PromptPart.Top.BillboardGui.Amount
            if Amount then
                if not Amount.Text:find("/") then
                    self.BasePlayer:CollectFishCrateContents()
                end
            end
        end
    end
end

function FarmManager:SpamFish()
    local pos = Vector3.new(-362.8326416015625, -1.6463819742202759, 429.3346862792969)
    while true do
        self.BasePlayer:SpamFish(pos, 2)
        task.wait(0.001)
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
    if self.AutoCollectFishTask then
        task.cancel(self.AutoCollectFishTask)
        self.AutoCollectFishTask = nil
    end
    if self.SpamFishTask then
        task.cancel(self.SpamFishTask)
        self.SpamFishTask = nil
    end
end

return FarmManager 