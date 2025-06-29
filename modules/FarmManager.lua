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
    
    -- Флаги для контроля работы функций
    self.IsAutoHiveRunning = false
    self.IsAutoHarvestRunning = false
    self.IsAutoResourceRunning = false
    self.IsAutoCollectFishRunning = false
    self.IsSpamFishRunning = false
    
    return self
end

function FarmManager:SetSelectedTypes(Types)
    self.SelectedHiveTypes = Types
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
    if TaskName == "autohive" then
        if Value then
            self:StartAutoHive()
        else
            self:StopAutoHive()
        end
    elseif TaskName == "autoharvest" then
        if Value then
            self:StartAutoHarvest()
        else
            self:StopAutoHarvest()
        end
    elseif TaskName == "instafarm" then
        if Value then
            self:StartAutoResource()
        else
            self:StopAutoResource()
        end
    elseif TaskName == "autocollectfish" then
        if Value then
            self:StartAutoCollectFish()
        else
            self:StopAutoCollectFish()
        end
    elseif TaskName == "spamfish" then
        if Value then
            self:StartSpamFish()
        else
            self:StopSpamFish()
        end
    end
end

-- Авто улей - отдельная функция
function FarmManager:StartAutoHive()
    if self.IsAutoHiveRunning then return end
    self.IsAutoHiveRunning = true
    
    self.AutoHiveTask = task.spawn(function()
        while self.IsAutoHiveRunning do
            task.spawn(function()
                self:AutoHive()
            end)
            task.wait(1)
        end
    end)
end

function FarmManager:StopAutoHive()
    self.IsAutoHiveRunning = false
    if self.AutoHiveTask then
        task.cancel(self.AutoHiveTask)
        self.AutoHiveTask = nil
    end
end

-- Авто сбор - отдельная функция
function FarmManager:StartAutoHarvest()
    if self.IsAutoHarvestRunning then return end
    self.IsAutoHarvestRunning = true
    
    self.AutoHarvestTask = task.spawn(function()
        while self.IsAutoHarvestRunning do
            task.spawn(function()
                self:AutoHarvest()
            end)
            task.wait(0.03)
        end
    end)
end

function FarmManager:StopAutoHarvest()
    self.IsAutoHarvestRunning = false
    if self.AutoHarvestTask then
        task.cancel(self.AutoHarvestTask)
        self.AutoHarvestTask = nil
    end
end

-- Авто ресурсы - отдельная функция
function FarmManager:StartAutoResource()
    if self.IsAutoResourceRunning then return end
    self.IsAutoResourceRunning = true
    
    self.AutoResourceTask = task.spawn(function()
        while self.IsAutoResourceRunning do
            task.spawn(function()
                self:AutoResource()
            end)
            task.wait(0.03)
        end
    end)
end

function FarmManager:StopAutoResource()
    self.IsAutoResourceRunning = false
    if self.AutoResourceTask then
        task.cancel(self.AutoResourceTask)
        self.AutoResourceTask = nil
    end
end

-- Авто сбор рыбы - отдельная функция
function FarmManager:StartAutoCollectFish()
    if self.IsAutoCollectFishRunning then return end
    self.IsAutoCollectFishRunning = true
    
    self.AutoCollectFishTask = task.spawn(function()
        while self.IsAutoCollectFishRunning do
            task.spawn(function()
                self:AutoCollectFish()
            end)
            task.wait(0.03)
        end
    end)
end

function FarmManager:StopAutoCollectFish()
    self.IsAutoCollectFishRunning = false
    if self.AutoCollectFishTask then
        task.cancel(self.AutoCollectFishTask)
        self.AutoCollectFishTask = nil
    end
end

-- Спам рыбалка - отдельная функция
function FarmManager:StartSpamFish()
    if self.IsSpamFishRunning then return end
    self.IsSpamFishRunning = true
    
    self.SpamFishTask = task.spawn(function()
        while self.IsSpamFishRunning do
            task.spawn(function()
                self:SpamFish()
            end)
            task.wait(0.001)
        end
    end)
end

function FarmManager:StopSpamFish()
    self.IsSpamFishRunning = false
    if self.SpamFishTask then
        task.cancel(self.SpamFishTask)
        self.SpamFishTask = nil
    end
end

function FarmManager:AutoHive()
    local island = self.BasePlayer:GetLocalIsland()
    if not island then return end

    -- Кэшируем споты при первом вызове
    if not self._cachedSpots then
        self._cachedSpots = {}
        for _, spot in ipairs(island:GetDescendants()) do
            if spot:IsA("Model") and spot.Name:match("Spot") then
                table.insert(self._cachedSpots, spot)
            end
        end
    end

    for _, Spot in ipairs(self._cachedSpots) do
        if not self.IsAutoHiveRunning then break end
        
        local PrimaryPart = Spot.PrimaryPart or Spot:FindFirstChildWhichIsA("BasePart")
        if PrimaryPart then
            local Parent = Spot.Parent
            if not Parent then continue end

            local hasBee = false
            for _, Child in ipairs(Parent:GetChildren()) do
                local name = Child.Name
                if self.SelectedHiveTypes.MagmaBee and name:find("MagmaHiveRunner") then
                    hasBee = true
                    break
                elseif self.SelectedHiveTypes.Bee and name:find("HiveRunner") and not name:find("Magma") then
                    hasBee = true
                    break
                end
            end

            if hasBee then
                local prompt = Spot:FindFirstChildWhichIsA("ProximityPrompt", true)
                if prompt and prompt.ActionText == "Collect" and prompt.Enabled then
                    task.spawn(function()
                        self.BasePlayer:AutoHive(Parent.Name, Spot.Name)
                    end)
                end
            end
        end
    end
end

function FarmManager:AutoHarvest()
    local island = self.BasePlayer:GetLocalIsland()
    if not island then return end
    
    local Plants = island:FindFirstChild("Plants")
    if not Plants then return end
    
    for _, Plant in ipairs(Plants:GetChildren()) do
        if not self.IsAutoHarvestRunning then break end
        
        local PromptHold = Plant:FindFirstChild("PromptHold")
        if PromptHold then
            local Prompt = PromptHold:FindFirstChildWhichIsA("ProximityPrompt")
            if Prompt and Prompt.ActionText == "Harvest" and Prompt.Enabled then
                local TypeValue = Plant:GetAttribute("Type")
                if self.SelectedBerryTypes[TypeValue] then
                    task.spawn(function()
                        self.BasePlayer:AutoHarvest(Plant.Name)
                    end)
                end
            end
        end
    end
end

function FarmManager:AutoResource()
    for _, TargetPlayer in ipairs(self.SelectedPlayers) do
        if not self.IsAutoResourceRunning then break end
        
        local TargetIsland = self.BasePlayer:GetAllIslands():FindFirstChild(TargetPlayer)
        if TargetIsland and TargetIsland:FindFirstChild("Resources") then
            local Resources = TargetIsland.Resources:GetChildren()
            for _, Resource in ipairs(Resources) do
                if not self.IsAutoResourceRunning then break end
                
                local Name = Resource.Name
                local Hp = Resource:GetAttribute("HP")
                local MaxHp = Resource:GetAttribute("MaxHP")
                local MinHp = HealthResources[Name]
                if self.SelectedResourceTypes[Name] and Hp and MinHp then
                    if self.OnlyMaxHp then
                        if Hp == MaxHp then
                            task.spawn(function()
                                while Resource:GetAttribute("HP") and Resource:GetAttribute("HP") > 0 and self.IsAutoResourceRunning do
                                    self.BasePlayer:HitResource(Resource)
                                    task.wait(0.05)
                                end
                            end)
                        end
                    else
                        if Hp <= MinHp then
                            task.spawn(function()
                                self.BasePlayer:HitResource(Resource)
                            end)
                        end
                    end
                end
            end
        end
    end
end

function FarmManager:AutoCollectFish()
    local island = self.BasePlayer:GetLocalIsland()
    if not island then return end
    
    local Land = island:FindFirstChild("Land")
    if not Land then return end
    
    for _, LandPlace in ipairs(Land:GetChildren()) do
        if not self.IsAutoCollectFishRunning then break end
        
        local FishCrate = LandPlace:FindFirstChild("FISHCRATE")
        if FishCrate then
            local Amount = FishCrate.PromptPart.Top.BillboardGui.Amount
            if Amount then
                if not Amount.Text:find("/") then
                    task.spawn(function()
                        self.BasePlayer:CollectFishCrateContents()
                    end)
                    task.wait(1)
                end
            end
        end
    end
end

function FarmManager:SpamFish()
    if not self.IsSpamFishRunning then return end
    
    local pos = Vector3.new(-362.8326416015625, -1.6463819742202759, 429.3346862792969)
    task.spawn(function()
        self.BasePlayer:SpamFish(pos, 2)
    end)
end

function FarmManager:Destroy()
    self:StopAutoHive()
    self:StopAutoHarvest()
    self:StopAutoResource()
    self:StopAutoCollectFish()
    self:StopSpamFish()
end

return FarmManager 