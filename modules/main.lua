-- Основной файл KRScript
-- Подключение модулей

if _G.KRScriptUnload then
    _G.KRScriptUnload()
end

-- Загрузка API
local API = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Asperitase/KRScript/main/modules/API/init.lua?t=" .. os.time()))()

-- Загрузка модулей
local MovementManager = require(script.Parent.modules.Movement)
local Menu = require(script.Parent.modules.Menu)

-- Инициализация менеджеров
local Movement = MovementManager.New(API)
local MenuInstance = Menu.New(API, Movement)

-- Создание окна меню
local Window = MenuInstance:CreateWindow()

-- Выбор первой вкладки
MenuInstance:SelectTab(1)

-- Функция выгрузки
_G.KRScriptUnload = function()
    if Movement and Movement.Destroy then
        Movement:Destroy()
    end

    if MenuInstance and MenuInstance.Destroy then
        MenuInstance:Destroy()
    end

    _G.KRScriptUnload = nil
end 