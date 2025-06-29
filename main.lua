local FluentMenu = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua?t=" .. tick()))()

local SpeedManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/Asperitase/KRScript/main/modules/SpeedManager.lua?t=" .. tick()))()
local FarmManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/Asperitase/KRScript/main/modules/FarmManager.lua?t=" .. tick()))()
local UIManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/Asperitase/KRScript/main/modules/UIManager.lua?t=" .. tick()))()
local RobloxAPI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Asperitase/KRScript/main/modules/RobloxAPI.lua?t=" .. tick()))()

local RobloxApi = RobloxAPI.New()

local SpeedManagerInstance = SpeedManager.New(RobloxApi)
local FarmManagerInstance = FarmManager.New(RobloxApi)
local UiManagerInstance = UIManager.New(RobloxApi, FluentMenu)

task.spawn(function()
    UiManagerInstance:Setup(SpeedManagerInstance, FarmManagerInstance)
end)

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local function CleanupOnExit()
    if SpeedManagerInstance then
        SpeedManagerInstance:Destroy()
    end
    if FarmManagerInstance then
        FarmManagerInstance:Destroy()
    end
    if UiManagerInstance then
        UiManagerInstance:Destroy()
    end
end

UserInputService.InputBegan:Connect(function(Input, GameProcessed)
    if not GameProcessed and Input.KeyCode == Enum.KeyCode.U then
        CleanupOnExit()
    end
end)

game:BindToClose(CleanupOnExit)
