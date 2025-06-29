local fluent_menu = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua?t=" .. tick()))()

local SpeedManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/Asperitase/KRScript/main/modules/SpeedManager.lua?t=" .. tick()))()
local FarmManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/Asperitase/KRScript/main/modules/FarmManager.lua?t=" .. tick()))()
local ESPManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/Asperitase/KRScript/main/modules/ESPManager.lua?t=" .. tick()))()
local UIManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/Asperitase/KRScript/main/modules/UIManager.lua?t=" .. tick()))()
local RobloxAPI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Asperitase/KRScript/main/modules/RobloxAPI.lua?t=" .. tick()))()

-- Инициализация и запуск
local roblox_api = RobloxAPI.new()

local speed_manager = SpeedManager.new(roblox_api)
local farm_manager = FarmManager.new(roblox_api)
local esp_manager = ESPManager.new(roblox_api)
local ui_manager = UIManager.new(roblox_api, fluent_menu)
ui_manager:setup(speed_manager, farm_manager, esp_manager) 