local UIManager = {}
UIManager.__index = UIManager

function UIManager.New(Api, FluentMenu)
    local self = setmetatable({}, UIManager)
    self.BasePlayer = Api
    self.FluentMenu = FluentMenu
    self.TabsId = {}
    return self
end

function UIManager:Setup(SpeedManager, FarmManager)
    local Window = self.FluentMenu:CreateWindow({
        Title = "ketaminex | ",
        SubTitle = "dev build 1", 
        TabWidth = 120,
        Size = UDim2.fromOffset(580, 750),
        Theme = "Dark",
        MinimizeKey = Enum.KeyCode.Q
    })

    self.TabsId = {
        main = Window:AddTab({ Title = "Main", Icon = "home" }),
        farming = Window:AddTab({ Title = "Farming", Icon = "axe" }),
        movement = Window:AddTab({ Title = "Movement", Icon = "move-3d"}),
        players = Window:AddTab({ Title = "Players", Icon = "users" }),
        test = Window:AddTab({ Title = "Test", Icon = "flask-conical"}),
        settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
    }

    -- ===== MAIN TAB =====
    self.TabsId.main:AddParagraph({ 
        Title = "Welcome to Ketaminex", 
        Content = "Select the desired tab to configure functions" 
    })

    self.TabsId.main:AddButton({
        Title = "Refresh Player List",
        Callback = function()
            local NewPlayers = {}
            for _, Player in ipairs(self.BasePlayer:GetAllPlayers()) do
                table.insert(NewPlayers, Player.Name)
            end
            if self.PlayerDropdown then
                self.PlayerDropdown:SetValues(NewPlayers)
            end
        end
    })

    -- ===== FARMING TAB =====
    -- Auto Hive Section
    self.TabsId.farming:AddParagraph({ Title = "🪺 Auto Hive", Content = "Automatic hive collection" })
    
    local IsAutoHive = self.TabsId.farming:AddToggle("Auto Hive", {Title = "Enable Auto Hive", Default = false})

    local SelectedHiveTypes = {Bee = true, MagmaBee = true}
    local DropdownHive = self.TabsId.farming:AddDropdown("Hive", {
        Title = "Hive Types",
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

    IsAutoHive:OnChanged(function(Value)
        FarmManager:StartupTask("autohive", Value)
    end)

    -- Auto Harvest Section
    self.TabsId.farming:AddParagraph({ Title = "🌾 Auto Harvest", Content = "Automatic berry and fruit collection" })
    
    local HarvestToggle = self.TabsId.farming:AddToggle("Auto Harvest", {Title = "Enable Auto Harvest", Default = false})
    HarvestToggle:OnChanged(function(Value)
        FarmManager:StartupTask("autoharvest", Value)
    end)

    local BerryDropdown = self.TabsId.farming:AddDropdown("Type Harvest", {
        Title = "Harvest Types",
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
        for k, v in pairs(Value) do 
            if v then
                SelectedTypes[k] = true 
            end
        end
        FarmManager:SetSelectedBerryTypes(SelectedTypes)
    end)

    -- Auto Resource Section
    self.TabsId.farming:AddParagraph({ Title = "⛏️ Auto Resources", Content = "Automatic resource collection" })
    
    local ResourceToggle = self.TabsId.farming:AddToggle("Auto Resource", {Title = "Enable Auto Resources", Default = false})
    ResourceToggle:OnChanged(function(Value)
        FarmManager:StartupTask("instafarm", Value)
    end)

    local ResourceDropdown = self.TabsId.farming:AddDropdown("Type Resource", {
        Title = "Resource Types",
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

    local OnlyMaxHpToggle = self.TabsId.farming:AddToggle("Only Max HP", {
        Title = "Only Max HP",
        Description = "Attack only resources with maximum HP",
        Default = true
    })
    OnlyMaxHpToggle:OnChanged(function(Value)
        FarmManager:SetOnlyMaxHp(Value)
    end)

    -- Auto Fishing Section
    self.TabsId.farming:AddParagraph({ Title = "🎣 Auto Fishing", Content = "Automatic fishing and fish collection" })
    
    local AutoCollectFishToggle = self.TabsId.farming:AddToggle("Auto Collect Fish", {Title = "Auto Collect Fish", Default = false})
    AutoCollectFishToggle:OnChanged(function(Value)
        FarmManager:StartupTask("autocollectfish", Value)
    end)

    local SpamFishToggle = self.TabsId.farming:AddToggle("Spam Fish", {Title = "Spam Fish", Default = false})
    SpamFishToggle:OnChanged(function(Value)
        FarmManager:StartupTask("spamfish", Value)
    end)

    -- ===== MOVEMENT TAB =====
    self.TabsId.movement:AddParagraph({ Title = "🏃‍♂️ Movement", Content = "Speed and movement settings" })
    
    local PlayerSpeed = 16
    local IsPlayerSpeed = self.TabsId.movement:AddToggle("Player Speed", {Title = "Enable Speed Boost", Default = false})
    IsPlayerSpeed:OnChanged(function(Value)
        if Value then
            SpeedManager:EnableSpeed(PlayerSpeed)
        else
            SpeedManager:DisableSpeed()
        end
    end)
    
    local SliderSpeed = self.TabsId.movement:AddSlider("Player Speed", {
        Title = "Player Speed",
        Description = "Set your movement speed",
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

    -- ===== PLAYERS TAB =====
    self.TabsId.players:AddParagraph({ Title = "👥 Players", Content = "Player management for resource farming" })
    
    local AllPlayers = {}
    for _, Player in ipairs(self.BasePlayer:GetAllPlayers()) do
        table.insert(AllPlayers, Player.Name)
    end

    self.PlayerDropdown = self.TabsId.players:AddDropdown("Target Players", {
        Title = "Target Players",
        Description = "Select players for resource farming on their islands",
        Values = AllPlayers,
        Multi = true,
        Default = {self.BasePlayer:GetLocalPlayer().Name},
    })
    self.PlayerDropdown:OnChanged(function(Value)
        local SelectedPlayers = {}
        for Name, State in next, Value do
            if State then
                table.insert(SelectedPlayers, Name)
            end
        end
        FarmManager:SetSelectedPlayers(SelectedPlayers)
    end)

    self.TabsId.players:AddButton({
        Title = "Refresh Player List",
        Callback = function()
            local NewPlayers = {}
            for _, Player in ipairs(self.BasePlayer:GetAllPlayers()) do
                table.insert(NewPlayers, Player.Name)
            end
            self.PlayerDropdown:SetValues(NewPlayers)
        end
    })

    -- ===== TEST TAB =====
    self.TabsId.test:AddParagraph({ Title = "🧪 Testing", Content = "Test functions without affecting main settings" })
    
    self.TabsId.test:AddButton({
        Title = "Run Test",
        Callback = function()
            print("=== CUSTOM TEST ===")
        end
    })

    -- ===== SETTINGS TAB =====
    local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua?t=" .. tick()))()
    local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua?t=" .. tick()))()
    SaveManager:SetLibrary(self.FluentMenu)
    InterfaceManager:SetLibrary(self.FluentMenu)
    InterfaceManager:SetFolder("KetaminHub")
    SaveManager:SetFolder("KetaminHub/specific-game")
    InterfaceManager:BuildInterfaceSection(self.TabsId.settings)
    
    -- Устанавливаем главную вкладку по умолчанию
    Window:SelectTab(1)
end

function UIManager:Destroy()
    if self.FluentMenu then
        self.FluentMenu:Destroy()
    end
    self.TabsId = {}
end

return UIManager 