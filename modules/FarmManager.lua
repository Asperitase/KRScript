local FarmManager = {}
FarmManager.__index = FarmManager

local health_resources = {
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
}

function FarmManager.new(api)
    local self = setmetatable({}, FarmManager)
    self.api = api
    self.player = api:GetLocalPlayer()
    self.communication = api:GetCommunication()
    self.land = api:GetIsland()
    self.selected_hive_types = {Bee = true, MagmaBee = true}
    self.distance_hive = 500
    self.auto_hive_task = nil
    self.auto_harvest_task = nil
    self.harvest_delay = 0
    self.selected_berry_types = {Strawberry = true, Blueberries = true}
    self.selected_resource_types = {Bamboo = true, Cactus = true}
    self.auto_resource_task = nil
    self.only_max_hp = true
    self.base_player = api
    return self
end

function FarmManager:set_selected_types(types)
    self.selected_hive_types = types
end

function FarmManager:set_distance(distance)
    self.distance_hive = distance
end

function FarmManager:set_harvest_delay(delay)
    self.harvest_delay = delay
end

function FarmManager:set_selected_berry_types(types)
    self.selected_berry_types = types
end

function FarmManager:set_selected_resource_types(types)
    self.selected_resource_types = types
end

function FarmManager:set_only_max_hp(value)
    self.only_max_hp = value
end

function FarmManager:startup_task(task_name, Value)
    local task_map = {
        autohive = {task = "auto_hive_task", func = "auto_hive"},
        autoharvest = {task = "auto_harvest_task", func = "auto_harvest"},
        instafarm = {task = "auto_resource_task", func = "auto_resource"}
    }
    
    local config = task_map[task_name]
    if not config then return end
    
    if Value then
        if self[config.task] then return end
        self[config.task] = task.spawn(function()
            while true do
                self[config.func](self)
                task.wait(1)
            end
        end)
    else
        if self[config.task] then
            task.cancel(self[config.task])
            self[config.task] = nil
        end
    end
end

function FarmManager:auto_hive()
    local character = self.player.Character or self.player.CharacterAdded:Wait()
    local human_part = character:WaitForChild("HumanoidRootPart")
    local island = self.api:GetIsland()
    for _, spot in ipairs(island:GetDescendants()) do
        if spot:IsA("Model") and spot.Name:match("Spot") then
            local primaryPart = spot.PrimaryPart or spot:FindFirstChildWhichIsA("BasePart")
            if primaryPart then
                local distance = (human_part.Position - primaryPart.Position).Magnitude * 0.8
                if distance < self.distance_hive then
                    local parent = spot.Parent
                    local is_bee, is_magma = false, false
                    for _, child in ipairs(parent:GetChildren()) do
                        if string.find(child.Name, "MagmaHiveRunner") and self.selected_hive_types.MagmaBee then
                            is_magma = true
                        elseif string.find(child.Name, "HiveRunner") and not string.find(child.Name, "Magma") and self.selected_hive_types.Bee then
                            is_bee = true
                        end
                    end
                    if is_bee or is_magma then
                        local collect_prompt = nil
                        for _, prompt in ipairs(spot:GetDescendants()) do
                            if prompt:IsA("ProximityPrompt") and prompt.ActionText == "Collect" then
                                collect_prompt = prompt
                                break
                            end
                        end
                        if collect_prompt and collect_prompt.Enabled then
                            self.communication:WaitForChild("Hive"):FireServer(spot.Parent.Name, spot.Name, 2)
                        end
                    end
                end
            end
        end
    end
end

function FarmManager:auto_harvest()
    local plots = self.api:GetIsland()
    for _, plant in ipairs(plots:FindFirstChild("Plants"):GetChildren()) do
        local promptHold = plant:FindFirstChild("PromptHold")
        if promptHold then
            local prompt = promptHold:FindFirstChildWhichIsA("ProximityPrompt")
            if prompt and prompt.ActionText == "Harvest" and prompt.Enabled then
                local type_value = plant:GetAttribute("Type")
                if self.selected_berry_types[type_value] then
                    self.communication:WaitForChild("Harvest"):FireServer(plant.Name)
                    task.wait(self.harvest_delay)
                end
            end
        end
    end
end

function FarmManager:auto_resource()
    local plots = self.api:GetIsland()
    if plots:FindFirstChild("Resources") then
        local resources = plots.Resources:GetChildren()
        for _, resource in ipairs(resources) do
            local name = resource.Name
            local hp = resource:GetAttribute("HP")
            local max_hp = resource:GetAttribute("MaxHP")
            local min_hp = health_resources[name]
            if self.selected_resource_types[name] and hp and min_hp then
                if self.only_max_hp then
                    if hp == max_hp then
                        task.spawn(function()
                            while resource:GetAttribute("HP") and resource:GetAttribute("HP") > 0 do
                                self.base_player:HitResource(resource)
                                task.wait(0.001)
                            end
                        end)
                    end
                else
                    if hp <= min_hp then
                        self.base_player:HitResource(resource)
                    end
                end
            end
        end
    end
end

return FarmManager 