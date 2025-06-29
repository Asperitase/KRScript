local fluent_menu = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua?t=" .. tick()))()

local SpeedManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/Asperitase/KRScript/main/modules/SpeedManager.lua?t=" .. tick()))()
local FarmManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/Asperitase/KRScript/main/modules/FarmManager.lua?t=" .. tick()))()
local ESPManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/Asperitase/KRScript/main/modules/ESPManager.lua?t=" .. tick()))()
local UIManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/Asperitase/KRScript/main/modules/UIManager.lua?t=" .. tick()))()
local RobloxAPI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Asperitase/KRScript/main/modules/RobloxAPI.lua?t=" .. tick()))()

-- Инициализация сервисов
local players = game:GetService("Players")
local replicated_storage = game:GetService("ReplicatedStorage")
local workspace = game:GetService("Workspace")

local local_player = players.LocalPlayer
local plots = workspace:WaitForChild("Plots"):WaitForChild(local_player.Name)
local land = plots:FindFirstChild("Land")
local communication = replicated_storage:WaitForChild("Communication")

-- Инициализация и запуск
local roblox_api = RobloxAPI.new(communication)

local speed_manager = SpeedManager.new(local_player)
local farm_manager = FarmManager.new(local_player, communication, land, roblox_api)
local esp_manager = ESPManager.new(local_player, land)
local ui_manager = UIManager.new(local_player, fluent_menu, communication, land)
ui_manager:setup(speed_manager, farm_manager, esp_manager) 