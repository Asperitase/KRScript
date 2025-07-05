-- KRScript - Основной файл инициализации
-- Автор: idredakx | Версия: 1.1

if _G.KRScriptUnload then
    _G.KRScriptUnload()
end

-- Загрузка API из GitHub
local API = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Asperitase/KRScript/main/modules/API/init.lua?t=" .. os.time()))()

-- Загрузка модулей из GitHub
local MovementManager = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Asperitase/KRScript/main/modules/modules/Movement.lua?t=" .. os.time()))()
local Menu = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Asperitase/KRScript/main/modules/modules/Menu.lua?t=" .. os.time()))()
local Watermark = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Asperitase/KRScript/main/modules/modules/Watermark.lua?t=" .. os.time()))()

-- Инициализация менеджеров
local Movement = MovementManager.New(API)
local WatermarkInstance = Watermark.New(API)
local MenuInstance = Menu.New(API, Movement, WatermarkInstance)

-- Создание окна меню
local Window = MenuInstance:CreateWindow()

-- Выбор первой вкладки
MenuInstance:SelectTab(1)

-- Создание Watermark
WatermarkInstance:Create()

-- Функция выгрузки
_G.KRScriptUnload = function()
    pcall(function()
        if Movement and Movement.Destroy then Movement:Destroy() end
    end)
    pcall(function()
        if WatermarkInstance and WatermarkInstance.Destroy then WatermarkInstance:Destroy() end
    end)
    pcall(function()
        if MenuInstance and MenuInstance.Destroy then MenuInstance:Destroy() end
    end)
    _G.KRScriptUnload = nil
end