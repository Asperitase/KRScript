local UIManager = {}
UIManager.__index = UIManager

function UIManager.new(player, fluent_menu, communication, land)
    local self = setmetatable({}, UIManager)
    self.player = player
    self.fluent_menu = fluent_menu
    self.communication = communication
    self.land = land
    self.tabs_id = {}
    return self
end

function UIManager:setup(speed_manager, farm_manager, esp_manager) 
    local window = self.fluent_menu:CreateWindow({
        Title = "ketaminex | ",
        SubTitle = "dev build: 1.0.74", 
        TabWidth = 120,
        Size = UDim2.fromOffset(580, 750),
        Theme = "Dark",
        MinimizeKey = Enum.KeyCode.Q
    })

    self.tabs_id = {
        farm = window:AddTab({ Title = "Farm", Icon = "axe" }),
        esp = window:AddTab({ Title = "Esp", Icon = "eye"}),
        movement = window:AddTab({ Title = "Movement", Icon = "move-3d"}),
        settings = window:AddTab({ Title = "Settings", Icon = "settings" })
    }

    -- Farm Tab
    local is_auto_hive = self.tabs_id.farm:AddToggle("Auto Hive", {Title = "Auto Hive", Default = false})

    local selected_hive_types = {Bee = true, MagmaBee = true}
    local dropdown_hive = self.tabs_id.farm:AddDropdown("Hive", {
        Title = "Hive",
        Values = {"Bee", "MagmaBee"}, 
        Multi = true,
        Default = {"Bee", "MagmaBee"},
    })
    dropdown_hive:OnChanged(function(Value)
        selected_hive_types = {}
        for k in next, Value do
            selected_hive_types[k] = true
        end
        farm_manager:set_selected_types(selected_hive_types)
    end)

    local distance_hive = 35
    local slider_distance_hive = self.tabs_id.farm:AddSlider("Auto Hive Distance", {
        Title = "Auto Hive Distance",
        Description = "Distance Hive",
        Default = distance_hive,
        Min = 35,
        Max = 500,
        Rounding = 1,
        Callback = function(Value) end
    })
    slider_distance_hive:OnChanged(function(Value)
        distance_hive = tonumber(Value)
        farm_manager:set_distance(distance_hive)
    end)
    is_auto_hive:OnChanged(function(Value)
        farm_manager:startup_task("autohive", Value)
    end)

    local harvest_toggle = self.tabs_id.farm:AddToggle("Auto Harvest", {Title = "Auto Harvest", Default = false})
    harvest_toggle:OnChanged(function(Value)
        farm_manager:startup_task("autoharvest", Value)
    end)

    local berry_dropdown = self.tabs_id.farm:AddDropdown("Type Harvest", {
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
            "Dragonfruit"
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
             "Dragonfruit"
        },
    })
    berry_dropdown:OnChanged(function(Value)
        local selected_types = {}
        for k in pairs(Value) do selected_types[k] = true end
        farm_manager:set_selected_berry_types(selected_types)
    end)

    local harvest_delay = 0.2
    local slider_harvest_delay = self.tabs_id.farm:AddSlider("Harvest Delay", {
        Title = "Harvest Delay",
        Description = "Задержка между сбором (сек)",
        Default = harvest_delay,
        Min = 0,
        Max = 5,
        Rounding = 1,
        Callback = function(Value) end
    })
    slider_harvest_delay:OnChanged(function(Value)
        harvest_delay = tonumber(Value)
        farm_manager:set_harvest_delay(harvest_delay)
    end)

    local resource_toggle = self.tabs_id.farm:AddToggle("Auto Resource", {Title = "Auto Resource", Default = false})
    resource_toggle:OnChanged(function(Value)
        farm_manager:startup_task("instafarm", Value)
    end)

    local resource_dropdown = self.tabs_id.farm:AddDropdown("Type Resource", {
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
    resource_dropdown:OnChanged(function(Value)
        local selected_types = {}
        for k in pairs(Value) do selected_types[k] = true end
        farm_manager:set_selected_resource_types(selected_types)
    end)

    local only_max_hp_toggle = self.tabs_id.farm:AddToggle("Only Max HP", {
        Title = "Only Max HP",
        Description = "Hit only when resource HP is max",
        Default = true
    })
    only_max_hp_toggle:OnChanged(function(Value)
        farm_manager:set_only_max_hp(Value)
    end)

    -- ESP Tab
    self.tabs_id.esp:AddParagraph({ Title = "Farm", Content = "Farm visual" })
    local esp_toggle = self.tabs_id.esp:AddToggle("ESP Hive", {Title = "ESP Hive", Default = false})
    esp_toggle:OnChanged(function(Value)
        if Value then
            esp_manager:show_esp()
        else
            esp_manager:hide_esp()
        end
    end)

    -- Movement Tab
    local player_speed = 16
    local is_player_speed = self.tabs_id.movement:AddToggle("Player Speed", {Title = "Player Speed", Default = false})
    is_player_speed:OnChanged(function(Value)
        if Value then
            speed_manager:enable_speed(player_speed)
        else
            speed_manager:disable_speed()
        end
    end)
    local slider_speed = self.tabs_id.movement:AddSlider("Player Speed", {
        Title = "Player Speed",
        Description = "Set your walking speed",
        Default = player_speed,
        Min = 16,
        Max = 60,
        Rounding = 1,
        Callback = function(Value) end
    })
    slider_speed:OnChanged(function(Value)
        player_speed = tonumber(Value)
        if speed_manager.speed_enabled then
            speed_manager:enable_speed(player_speed)
        end
    end)

    -- Character respawn support
    self.player.CharacterAdded:Connect(function()
        speed_manager:character_added()
    end)

    -- SaveManager и InterfaceManager
    local save_manager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua?t=" .. tick()))()
    local interface_manager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua?t=" .. tick()))()
    save_manager:SetLibrary(self.fluent_menu)
    interface_manager:SetLibrary(self.fluent_menu)
    interface_manager:SetFolder("KetaminHub")
    save_manager:SetFolder("KetaminHub/specific-game")
    interface_manager:BuildInterfaceSection(self.tabs_id.settings)
    -- save_manager:BuildConfigSection(self.tabs_id.settings) -- пока закомментировано
    window:SelectTab(2)
end

return UIManager 