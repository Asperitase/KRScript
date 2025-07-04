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

Window:SelectTab(1)

FluentMenu:Notify{
    Title = "KRScript",
    Content = "has been loaded",
    SubContent = "", -- Optional
    Duration = 5 -- Set to nil to make the notification not disappear
}

SaveManager:SetLibrary(FluentMenu)
InterfaceManager:SetLibrary(FluentMenu)
SaveManager:IgnoreThemeSettings()
InterfaceManager:SetFolder("KRScript")
SaveManager:SetFolder("KRScript/specific-game")