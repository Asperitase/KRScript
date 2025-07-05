if _G.KRScriptUnload then
    _G.KRScriptUnload()
end

local FluentMenu = loadstring(game:HttpGet("https://github.com/ActualMasterOogway/Fluent-Renewed/releases/download/v1.0.8/Fluent.luau?t=" .. tick()))()
local SaveManager = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/ActualMasterOogway/Fluent-Renewed/master/Addons/SaveManager.luau?t=" .. tick()))()
local InterfaceManager = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/ActualMasterOogway/Fluent-Renewed/master/Addons/InterfaceManager.luau?t=" .. tick()))()
local API = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Asperitase/KRScript/main/modules/API/init.lua?t=" .. tick()))()

local MovementManager = {}
MovementManager.__index = MovementManager

function MovementManager.New(API)
    local self = setmetatable({}, MovementManager)

    self.API = API

    self.DefaultSpeed = nil
    self.CustomSpeed = 32
    self.SpeedEnabled = false
    self.HookWalkSpeed = nil
    self.HookCharacter = nil

    API:GetLocalPlayer().CharacterAdded:Connect(function()
        
        if self.SpeedEnabled then
            task.defer(function()
                self:ApplySpeed(self.CustomSpeed)
            end)
        end
        

    end)

    return self
end

function MovementManager:_HookWalkSpeed(Humanoid)
    if self.HookWalkSpeed then self.HookWalkSpeed:Disconnect() end

    self.HookWalkSpeed = Humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        if self.SpeedEnabled and Humanoid.WalkSpeed ~= self.CustomSpeed then
            Humanoid.WalkSpeed = self.CustomSpeed
        end
    end)
end

function MovementManager:_EnsureHook(Humanoid)
    self:_HookWalkSpeed(Humanoid)
end

function MovementManager:_ClearHooks()
    if self.HookWalkSpeed then 
        self.HookWalkSpeed:Disconnect() 
    end
    self.HookWalkSpeed = nil
end

function MovementManager:GetHumanoid()
    return self.API:GetHumanoid()
end

function MovementManager:ApplySpeed(Speed)
    local Humanoid = self:GetHumanoid()
    if Humanoid then
        Humanoid.WalkSpeed = Speed
    end
end

function MovementManager:SetSpeedValue(Speed)
    self.CustomSpeed = Speed
    if self.SpeedEnabled then
        self:ApplySpeed(Speed)
    end
end

function MovementManager:EnablePlayerSpeed()
    local Humanoid = self:GetHumanoid()
    if Humanoid and not self.DefaultSpeed then
        self.DefaultSpeed = Humanoid.WalkSpeed
    end

    self.CustomSpeed = self.CustomSpeed
    self.SpeedEnabled = true
    self:ApplySpeed(self.CustomSpeed)
    self:_EnsureHook(Humanoid)  

    if not self.HookCharacter then
        self.HookCharacter = self.API:GetLocalPlayer().CharacterAdded:Connect(function()
            if self.SpeedEnabled then
                task.defer(function()
                    self:ApplySpeed(self.CustomSpeed)
                    self:_EnsureHook()
                end)
            end
        end)
    end
end

function MovementManager:DisablePlayerSpeed()
    self.SpeedEnabled = false
    self:_ClearHooks()

    if self.DefaultSpeed then
        self:ApplySpeed(self.DefaultSpeed)
    end
end

function MovementManager:Destroy()
    self:DisablePlayerSpeed()

    if self.HookCharacter then
        self.HookCharacter:Disconnect()
    end
    self.HookCharacter = nil
end


local Window = FluentMenu:CreateWindow{
    Title = "KRScript",
    SubTitle = "by idredakx | v1.0",
    TabWidth = 160,
    Size = UDim2.fromOffset(830, 525),
    Resize = true,
    MinSize = Vector2.new(470, 380),
    Acrylic = false,
    Theme = "Monokai Vibrant",
    MinimizeKey = Enum.KeyCode.Q
}

local TabID = {
    About = Window:CreateTab{
        Title = "About",
        Icon = "info"
    },
    Farm = Window:CreateTab{
        Title = "Farm",
        Icon = "axe"
    },
    Movement = Window:CreateTab{
        Title = "Movement",
        Icon = "move-3d"
    },
    Settings = Window:CreateTab{
        Title = "Settings",
        Icon = "settings"
    }
}

TabID.About:CreateParagraph("Discord", {
    Title = "Discord",
    Content = "@redakxx",
    TitleAlignment = "Middle",
    ContentAlignment = Enum.TextXAlignment.Center
})
-- TabID.About:CreateButton("Unload KRScript", {
--     Title = "Unload KRScript",
--     Description = "Fully delete menu and disable function"
-- }, function()
--     if _G.KRScriptUnload then
--         Window:Dialog{
--             Title = "Unload",
--             Content = "???",
--             Buttons = {
--                 {
--                     Title = "Confirm",
--                     Callback = function()
--                         _G.KRScriptUnload()
--                     end
--                 },
--                 {
--                     Title = "Cancel",
--                 }
--             }
--         }
--     end
-- end)




local Movement = MovementManager.New(API)
TabID.Movement:CreateToggle("Speed Player", {Title = "Speed Player", Default = false,
    Callback = function(enabled)
    if enabled then
        Movement:EnablePlayerSpeed()
    else
        Movement:DisablePlayerSpeed()
    end
end })
TabID.Movement:CreateSlider("Speed Value", {
    Title = "Speed Value",
    Description = "Adjust player walkspeed",
    Min = 16,
    Max = 100,
    Default = 32,
    Callback = function(value)
        Movement:SetSpeedValue(value)
    end
})

Window:SelectTab(1)

SaveManager:SetLibrary(FluentMenu)
InterfaceManager:SetLibrary(FluentMenu)
SaveManager:IgnoreThemeSettings()
InterfaceManager:SetFolder("KRScript")
SaveManager:SetFolder("KRScript/specific-game")

_G.KRScriptUnload = function()
    if Movement and Movement.Destroy then
        Movement:Destroy()
    end

    if Window and Window.Destroy then
        Window:Destroy()
    elseif Window and Window._window then
        Window._window:Destroy()
    end

    pcall(function() InterfaceManager:Unload() end)

    _G.KRScriptUnload = nil
end