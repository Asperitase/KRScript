local UIManager = {}
UIManager.__index = UIManager

function UIManager.New(Api, FluentMenu)
    local self = setmetatable({}, UIManager)
    self.Api = Api
    self.Player = Api:GetLocalPlayer()
    self.FluentMenu = FluentMenu
    self.Communication = Api:GetCommunication()
    self.LandPlot = Api:GetLandPlots()
    self.TabsId = {}
    return self
end

function UIManager:Setup(SpeedManager, FarmManager, EspManager)
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
        esp = Window:AddTab({ Title = "Esp", Icon = "eye"}),
        movement = Window:AddTab({ Title = "Movement", Icon = "move-3d"}),
        settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
    }

    -- Farm Tab
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
        for k in pairs(Value) do SelectedTypes[k] = true end
        FarmManager:SetSelectedBerryTypes(SelectedTypes)
    end)

    local HarvestDelay = 0
    local SliderHarvestDelay = self.TabsId.farm:AddSlider("Harvest Delay", {
        Title = "Harvest Delay",
        Description = "Задержка между сбором (сек)",
        Default = HarvestDelay,
        Min = 0,
        Max = 5,
        Rounding = 1,
        Callback = function(Value) end
    })
    SliderHarvestDelay:OnChanged(function(Value)
        HarvestDelay = tonumber(Value)
        FarmManager:SetHarvestDelay(HarvestDelay)
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
            "Wheat"
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
            "Wheat"
        },
    })
    ResourceDropdown:OnChanged(function(Value)
        local SelectedTypes = {}
        for k in pairs(Value) do SelectedTypes[k] = true end
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

    -- Выбор игроков для ломания ресурсов
    local AllPlayers = {}
    for _, Player in ipairs(self.Api:GetAllPlayers()) do
        table.insert(AllPlayers, Player.Name)
    end

    local PlayerDropdown = self.TabsId.farm:AddDropdown("Target Players", {
        Title = "Target Players",
        Description = "Выберите игроков для ломания ресурсов на их островах",
        Values = AllPlayers,
        Multi = true,
        Default = {self.Player.Name},
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

    -- Кнопка обновления списка игроков
    self.TabsId.farm:AddButton({
        Title = "Refresh Player List",
        Callback = function()
            local NewPlayers = {}
            for _, Player in ipairs(self.Api:GetAllPlayers()) do
                table.insert(NewPlayers, Player.Name)
            end
            PlayerDropdown:SetValues(NewPlayers)
        end
    })

    -- ESP Tab
    self.TabsId.esp:AddParagraph({ Title = "Farm", Content = "Farm visual" })
    local EspToggle = self.TabsId.esp:AddToggle("ESP Hive", {Title = "ESP Hive", Default = false})
    EspToggle:OnChanged(function(Value)
        if Value then
            EspManager:ShowEsp()
        else
            EspManager:HideEsp()
        end
    end)

    -- Movement Tab
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

    -- Character respawn support
    self.Player.CharacterAdded:Connect(function()
        SpeedManager:CharacterAdded()
    end)

    -- SaveManager и InterfaceManager
    local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua?t=" .. tick()))()
    local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua?t=" .. tick()))()
    SaveManager:SetLibrary(self.FluentMenu)
    InterfaceManager:SetLibrary(self.FluentMenu)
    InterfaceManager:SetFolder("KetaminHub")
    SaveManager:SetFolder("KetaminHub/specific-game")
    InterfaceManager:BuildInterfaceSection(self.TabsId.settings)
    -- SaveManager:BuildConfigSection(self.TabsId.settings) -- пока закомментировано
    Window:SelectTab(2)
end

return UIManager 