local UIManager = {}
UIManager.__index = UIManager

function UIManager.New(Api, FluentMenu)
    local self = setmetatable({}, UIManager)
    self.BasePlayer = Api
    self.FluentMenu = FluentMenu
    self.TabsId = {}
    self.FpsData = {
        Current = 0,
        Average = 0,
        Min = 999,
        Max = 0,
        Samples = {},
        LastUpdate = 0
    }
    return self
end

function UIManager:UpdateFPS()
    local RunService = game:GetService("RunService")
    local CurrentTime = tick()
    
    if CurrentTime - self.FpsData.LastUpdate >= 0.1 then
        self.FpsData.LastUpdate = CurrentTime
        local CurrentFPS = math.floor(1 / RunService.RenderStepped:Wait())
        
        table.insert(self.FpsData.Samples, CurrentFPS)
        if #self.FpsData.Samples > 60 then
            table.remove(self.FpsData.Samples, 1)
        end
        
        self.FpsData.Current = CurrentFPS
        self.FpsData.Min = math.min(self.FpsData.Min, CurrentFPS)
        self.FpsData.Max = math.max(self.FpsData.Max, CurrentFPS)
        
        local Sum = 0
        for _, FPS in ipairs(self.FpsData.Samples) do
            Sum = Sum + FPS
        end
        self.FpsData.Average = math.floor(Sum / #self.FpsData.Samples)
    end
end

function UIManager:Setup(SpeedManager, FarmManager)
    local Window = self.FluentMenu:CreateWindow({
        Title = "ketaminex | ",
        SubTitle = "dev build: 1.0.8", 
        TabWidth = 120,
        Size = UDim2.fromOffset(580, 750),
        Theme = "Dark",
        MinimizeKey = Enum.KeyCode.Q
    })

    self.TabsId = {
        farm = Window:AddTab({ Title = "Farm", Icon = "axe" }),
        movement = Window:AddTab({ Title = "Movement", Icon = "move-3d"}),
        test = Window:AddTab({ Title = "Test", Icon = "test-tube"}),
        settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
    }

    local IsAutoHive = self.TabsId.farm:AddToggle("Auto Hive", {Title = "Auto Hive", Default = false})

    local SelectedHiveTypes = {Bee = true, MagmaBee = true}
    local DropdownHive = self.TabsId.farm:AddDropdown("Hive", {
        Title = "Hive",
        Values = {"Bee", "MagmaBee"}, 
        Multi = true,
        Default = {"Bee", "MagmaBee"},
    })
    DropdownHive:OnChanged(function(Value)
        SelectedHiveTypes = {}
        for k in next, Value do
            SelectedHiveTypes[k] = true
        end
        FarmManager:SetSelectedTypes(SelectedHiveTypes)
    end)

    local DistanceHive = 500
    local SliderDistanceHive = self.TabsId.farm:AddSlider("Auto Hive Distance", {
        Title = "Auto Hive Distance",
        Description = "Distance Hive",
        Default = DistanceHive,
        Min = 35,
        Max = 500,
        Rounding = 1,
        Callback = function(Value) end
    })
    SliderDistanceHive:OnChanged(function(Value)
        DistanceHive = tonumber(Value)
        FarmManager:SetDistance(DistanceHive)
    end)
    IsAutoHive:OnChanged(function(Value)
        FarmManager:StartupTask("autohive", Value)
    end)

    local HarvestToggle = self.TabsId.farm:AddToggle("Auto Harvest", {Title = "Auto Harvest", Default = false})
    HarvestToggle:OnChanged(function(Value)
        FarmManager:StartupTask("autoharvest", Value)
    end)

    local BerryDropdown = self.TabsId.farm:AddDropdown("Type Harvest", {
        Title = "Type Harvest",
        Values = {
            "Strawberry",
            "Blueberries",
            "World Tree Fruit",
            "Tomato",
            "Aloe Vera",
            "Celestial Fruit",
            "Peach",
            "Magic Durian",
            "Apple",
            "Sundew",
            "Cherries",
            "Dragonfruit",
            "Mango",
            "Starfruit"
            -- pumpkin
        },
        Multi = true,
        Default = {
            "Strawberry",
            "Blueberries",
            "World Tree Fruit",
            "Tomato",
            "Aloe Vera",
            "Celestial Fruit",
            "Peach",
            "Magic Durian",
            "Apple",
            "Sundew",
            "Cherries",
            "Dragonfruit",
            "Mango",
            "Starfruit"
        },
    })
    BerryDropdown:OnChanged(function(Value)
        local SelectedTypes = {}
        for k, v in pairs(Value) do 
            if v then
                SelectedTypes[k] = true 
            end
        end
        FarmManager:SetSelectedBerryTypes(SelectedTypes)
    end)

    local ResourceToggle = self.TabsId.farm:AddToggle("Auto Resource", {Title = "Auto Resource", Default = false})
    ResourceToggle:OnChanged(function(Value)
        FarmManager:StartupTask("instafarm", Value)
    end)

    local ResourceDropdown = self.TabsId.farm:AddDropdown("Type Resource", {
        Title = "Type Resource",
        Values = {
            "Bamboo",
            "Big Bamboo",
            "Big Obsidian",
            "Big Stone",
            "Banana Tree",
            "Cactus",
            "Iron Ore",
            "Magma Crystal",
            "Magma Tree",
            "Mushroom",
            "Oak Tree",
            "Obsidian",
            "Palm Tree",
            "Pine Tree",
            "Salt",
            "Sand",
            "Stone",
            "Wheat",
            "Crystal"
        },
        Multi = true,
        Default = {
            "Bamboo",
            "Big Bamboo",
            "Big Obsidian",
            "Big Stone",
            "Banana Tree",
            "Cactus",
            "Iron Ore",
            "Magma Crystal",
            "Magma Tree",
            "Mushroom",
            "Oak Tree",
            "Obsidian",
            "Palm Tree",
            "Pine Tree",
            "Salt",
            "Sand",
            "Stone",
            "Wheat",
            "Crystal"
        },
    })
    ResourceDropdown:OnChanged(function(Value)
        local SelectedTypes = {}
        for k, v in pairs(Value) do 
            if v then
                SelectedTypes[k] = true 
            end
        end
        FarmManager:SetSelectedResourceTypes(SelectedTypes)
    end)

    local OnlyMaxHpToggle = self.TabsId.farm:AddToggle("Only Max HP", {
        Title = "Only Max HP",
        Description = "Hit only when resource HP is max",
        Default = true
    })
    OnlyMaxHpToggle:OnChanged(function(Value)
        FarmManager:SetOnlyMaxHp(Value)
    end)

    local AllPlayers = {}
    for _, Player in ipairs(self.BasePlayer:GetAllPlayers()) do
        table.insert(AllPlayers, Player.Name)
    end

    local PlayerDropdown = self.TabsId.farm:AddDropdown("Target Players", {
        Title = "Target Players",
        Description = "Select players for resource farming on their islands",
        Values = AllPlayers,
        Multi = true,
        Default = {self.BasePlayer:GetLocalPlayer().Name},
    })
    PlayerDropdown:OnChanged(function(Value)
        local SelectedPlayers = {}
        for Name, State in next, Value do
            if State then
                table.insert(SelectedPlayers, Name)
            end
        end
        FarmManager:SetSelectedPlayers(SelectedPlayers)
    end)

    self.TabsId.farm:AddButton({
        Title = "Refresh Player List",
        Callback = function()
            local NewPlayers = {}
            for _, Player in ipairs(self.BasePlayer:GetAllPlayers()) do
                table.insert(NewPlayers, Player.Name)
            end
            PlayerDropdown:SetValues(NewPlayers)
        end
    })

    local AutoCollectFishToggle = self.TabsId.farm:AddToggle("Auto Collect Fish", {Title = "Auto Collect Fish", Default = false})
    AutoCollectFishToggle:OnChanged(function(Value)
        FarmManager:StartupTask("autocollectfish", Value)
    end)

    local SpamFishToggle = self.TabsId.farm:AddToggle("Spam Fish", {Title = "Spam Fish", Default = false})
    SpamFishToggle:OnChanged(function(Value)
        FarmManager:StartupTask("spamfish", Value)
    end)

    local PlayerSpeed = 16
    local IsPlayerSpeed = self.TabsId.movement:AddToggle("Player Speed", {Title = "Player Speed", Default = false})
    IsPlayerSpeed:OnChanged(function(Value)
        if Value then
            SpeedManager:EnableSpeed(PlayerSpeed)
        else
            SpeedManager:DisableSpeed()
        end
    end)
    local SliderSpeed = self.TabsId.movement:AddSlider("Player Speed", {
        Title = "Player Speed",
        Description = "Set your walking speed",
        Default = PlayerSpeed,
        Min = 16,
        Max = 60,
        Rounding = 1,
        Callback = function(Value) end
    })
    SliderSpeed:OnChanged(function(Value)
        PlayerSpeed = tonumber(Value)
        if SpeedManager.SpeedEnabled then
            SpeedManager:EnableSpeed(PlayerSpeed)
        end
    end)

    self.BasePlayer:GetLocalPlayer().CharacterAdded:Connect(function()
        SpeedManager:CharacterAdded()
    end)

    self.TabsId.test:AddParagraph({ Title = "Testing Functions", Content = "Test functions here without affecting main settings" })
    
    self.TabsId.test:AddButton({
        Title = "Test Functions",
        Callback = function()
            print("=== CUSTOM TEST ===")
        end
    })

    local FpsParagraph = self.TabsId.test:AddParagraph({ 
        Title = "FPS Monitor", 
        Content = "Current: 0 | Average: 0 | Min: 0 | Max: 0" 
    })

    task.spawn(function()
        while true do
            self:UpdateFPS()
            FpsParagraph:SetDesc(string.format(
                "Current: %d | Average: %d | Min: %d | Max: %d",
                self.FpsData.Current,
                self.FpsData.Average,
                self.FpsData.Min,
                self.FpsData.Max
            ))
            task.wait(0.1)
        end
    end)

    self.TabsId.test:AddButton({
        Title = "Reset FPS Stats",
        Callback = function()
            self.FpsData.Min = 999
            self.FpsData.Max = 0
            self.FpsData.Samples = {}
        end
    })

    local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua?t=" .. tick()))()
    local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua?t=" .. tick()))()
    SaveManager:SetLibrary(self.FluentMenu)
    InterfaceManager:SetLibrary(self.FluentMenu)
    InterfaceManager:SetFolder("KetaminHub")
    SaveManager:SetFolder("KetaminHub/specific-game")
    InterfaceManager:BuildInterfaceSection(self.TabsId.settings)
    Window:SelectTab(4)
end

function UIManager:Destroy()
    if self.FluentMenu then
        self.FluentMenu:Destroy()
    end
    self.TabsId = {}
end

return UIManager 