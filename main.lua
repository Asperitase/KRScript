local FluentMenu = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua?t=" .. tick()))()

local SpeedManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/Asperitase/KRScript/main/modules/SpeedManager.lua?t=" .. tick()))()
local FarmManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/Asperitase/KRScript/main/modules/FarmManager.lua?t=" .. tick()))()
local ESPManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/Asperitase/KRScript/main/modules/ESPManager.lua?t=" .. tick()))()
local UIManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/Asperitase/KRScript/main/modules/UIManager.lua?t=" .. tick()))()
local RobloxAPI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Asperitase/KRScript/main/modules/RobloxAPI.lua?t=" .. tick()))()

local RobloxApi = RobloxAPI.New()
 
local SpeedManagerInstance = SpeedManager.New(RobloxApi)
local FarmManagerInstance = FarmManager.New(RobloxApi)
local EspManagerInstance = ESPManager.New(RobloxApi)
local UiManagerInstance = UIManager.New(RobloxApi, FluentMenu)
UiManagerInstance:Setup(SpeedManagerInstance, FarmManagerInstance, EspManagerInstance)