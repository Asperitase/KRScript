local FluentMenu = loadstring(game:HttpGet("https://github.com/ActualMasterOogway/Fluent-Renewed/releases/download/v1.0.8/Fluent.luau?t=" .. tick()))()
local SaveManager = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/ActualMasterOogway/Fluent-Renewed/master/Addons/SaveManager.luau"))()
local InterfaceManager = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/ActualMasterOogway/Fluent-Renewed/master/Addons/InterfaceManager.luau"))()
 

local Window = FluentMenu:CreateWindow{
    Title = "KRScript",
    SubTitle = "by idredakx | v1.0",
    TabWidth = 160,
    Size = UDim2.fromOffset(830, 525),
    Resize = true,
    MinSize = Vector2.new(470, 380),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.Q
}

local TabID = {
    about = Window:CreateTab{
        Title = "About",
        Icon = "info"
    },
    farm = Window:CreateTab{
        Title = "Farm",
        Icon = "axe"
    },
    movement = Window:CreateTab{
        Title = "Movement",
        Icon = "move-3d"
    },
    settings = Window:CreateTab{
        Title = "Settings",
        Icon = "settings"
    }
}

Window:SelectTab(1)

SaveManager:SetLibrary(Window)
InterfaceManager:SetLibrary(Window)
InterfaceManager:BuildInterfaceSection(TabID.settings)