local Menu = {}
Menu.__index = Menu

function Menu.New(API, MovementManager)
    local self = setmetatable({}, Menu)
    
    self.API = API
    self.Movement = MovementManager
    self.Window = nil
    self.Tabs = {}
    
    return self
end

function Menu:CreateWindow()
    local FluentMenu = loadstring(game:HttpGet("https://github.com/ActualMasterOogway/Fluent-Renewed/releases/download/v1.0.8/Fluent.luau?t=" .. os.time()))()
    local SaveManager = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/ActualMasterOogway/Fluent-Renewed/master/Addons/SaveManager.luau?t=" .. os.time()))()
    local InterfaceManager = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/ActualMasterOogway/Fluent-Renewed/master/Addons/InterfaceManager.luau?t=" .. os.time()))()
    
    self.FluentMenu = FluentMenu
    self.SaveManager = SaveManager
    self.InterfaceManager = InterfaceManager
    
    self.Window = FluentMenu:CreateWindow{
        Title = "KRScript",
        SubTitle = "by idredakx | v1.1",
        TabWidth = 160,
        Size = UDim2.fromOffset(830, 525),
        Resize = true,
        MinSize = Vector2.new(470, 380),
        Acrylic = false,
        Theme = "Monokai Vibrant",
        MinimizeKey = Enum.KeyCode.Q
    }
    
    self:CreateTabs()
    self:SetupSaveManager()
    
    return self.Window
end

function Menu:CreateTabs()
    self.Tabs = {
        About = self.Window:CreateTab{
            Title = "About",
            Icon = "info"
        },
        Farm = self.Window:CreateTab{
            Title = "Farm",
            Icon = "axe"
        },
        Movement = self.Window:CreateTab{
            Title = "Movement",
            Icon = "move-3d"
        },
        Settings = self.Window:CreateTab{
            Title = "Settings",
            Icon = "settings"
        }
    }
    
    self:CreateAboutTab()
    self:CreateMovementTab()
end

function Menu:CreateAboutTab()
    self.Tabs.About:CreateParagraph("Discord", {
        Title = "Discord",
        Content = "@redakxx",
        TitleAlignment = "Middle",
        ContentAlignment = Enum.TextXAlignment.Center
    })
    
    self.Tabs.About:CreateButton{
        Title = "Unload",
        Description = "Fully delete menu and disable function",
        Callback = function()
            self.Window:Dialog{
                Title = "Unload",
                Content = "???",
                Buttons = {
                    {
                        Title = "Confirm",
                        Callback = function()
                            if _G.KRScriptUnload then
                                _G.KRScriptUnload()
                            end
                        end
                    },
                    {
                        Title = "Cancel",
                    }
                }
            }
        end
    }
end

function Menu:CreateMovementTab()
    self.Tabs.Movement:CreateToggle("Speed Player", {
        Title = "Speed Player", 
        Default = false,
        Callback = function(enabled)
            if enabled then
                self.Movement:EnablePlayerSpeed()
            else
                self.Movement:DisablePlayerSpeed()
            end
        end
    })
    
    self.Tabs.Movement:CreateSlider("Speed Value", {
        Title = "Speed Value",
        Description = "Adjust player walkspeed",
        Min = 16,
        Max = 100,
        Default = 32,
        Callback = function(value)
            self.Movement:SetSpeedValue(value)
        end
    })
    
    self.Tabs.Movement:CreateToggle("Jump Player", {
        Title = "Jump Player", 
        Default = false,
        Callback = function(enabled)
            if enabled then
                self.Movement:EnablePlayerJump()
            else
                self.Movement:DisablePlayerJump()
            end
        end
    })
    
    self.Tabs.Movement:CreateSlider("Jump Height", {
        Title = "Jump Height",
        Description = "Adjust player jump height",
        Min = 5,
        Max = 50,
        Default = 7.2,
        Callback = function(value)
            self.Movement:SetJumpHeightValue(value)
        end
    })
    
    self.Tabs.Movement:CreateToggle("Fly Player", {
        Title = "Fly Player", 
        Default = false,
        Callback = function(enabled)
            if enabled then
                self.Movement:EnableFly()
            else
                self.Movement:DisableFly()
            end
        end
    })
    
    self.Tabs.Movement:CreateSlider("Fly Speed", {
        Title = "Fly Speed",
        Description = "Adjust player fly speed",
        Min = 8,
        Max = 100,
        Default = 16,
        Callback = function(value)
            self.Movement:SetFlySpeed(value)
        end
    })
end

function Menu:SetupSaveManager()
    self.SaveManager:SetLibrary(self.FluentMenu)
    self.InterfaceManager:SetLibrary(self.FluentMenu)
    self.SaveManager:IgnoreThemeSettings()
    self.InterfaceManager:SetFolder("KRScript")
    self.SaveManager:SetFolder("KRScript/specific-game")
end

function Menu:SelectTab(tabIndex)
    if self.Window then
        self.Window:SelectTab(tabIndex)
    end
end

function Menu:Destroy()
    if self.Window and self.Window.Destroy then
        self.Window:Destroy()
    elseif self.Window and self.Window._window then
        self.Window._window:Destroy()
    end
    
    pcall(function() 
        if self.InterfaceManager then
            self.InterfaceManager:Unload() 
        end
    end)
    
    self.Window = nil
    self.Tabs = {}
end

return Menu 