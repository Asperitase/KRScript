--[[
    KRScript v1.1
    Author: idredakx
    Copyright © 2024 idredakx. All rights reserved.
]]

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
    self.DefaultJumpHeight = nil
    self.CustomJumpHeight = 7.2
    self.JumpEnabled = false
    self.FlyEnabled = false
    self.FlySpeed = 16
    self.FlyBodyVelocity = nil
    self.FlyBodyGyro = nil

    API:GetLocalPlayer().CharacterAdded:Connect(function()
        
        if self.SpeedEnabled then
            task.defer(function()
                self:ApplySpeed(self.CustomSpeed)
            end)
        end
        

    end)

    return self
end

function MovementManager:HookWalkSpeed(Humanoid)
    if self.HookWalkSpeed then self.HookWalkSpeed:Disconnect() end
    self.HookWalkSpeed = Humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        if self.SpeedEnabled and Humanoid.WalkSpeed ~= self.CustomSpeed then
            Humanoid.WalkSpeed = self.CustomSpeed
        end
    end)
end

function MovementManager:EnsureHook(Humanoid)
    self:HookWalkSpeed(Humanoid)
end

function MovementManager:ClearHooks()
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
    self:EnsureHook(Humanoid)  
    if not self.HookCharacter then
        self.HookCharacter = self.API:GetLocalPlayer().CharacterAdded:Connect(function()
            if self.SpeedEnabled then
                task.defer(function()
                    self:ApplySpeed(self.CustomSpeed)
                    self:EnsureHook()
                end)
            end
        end)
    end
end

function MovementManager:DisablePlayerSpeed()
    self.SpeedEnabled = false
    self:ClearHooks()
    if self.DefaultSpeed then
        self:ApplySpeed(self.DefaultSpeed)
    end
end

function MovementManager:ApplyJumpHeight(JumpHeight)
    local Humanoid = self:GetHumanoid()
    if Humanoid then
        Humanoid.JumpHeight = JumpHeight
        if Humanoid.UseJumpPower then
            Humanoid.JumpPower = math.sqrt(349.24 * JumpHeight)
        end
    end
end

function MovementManager:SetJumpHeightValue(JumpHeight)
    self.CustomJumpHeight = JumpHeight
    if self.JumpEnabled then
        self:ApplyJumpHeight(JumpHeight)
    end
end

function MovementManager:EnablePlayerJump()
    local Humanoid = self:GetHumanoid()
    if Humanoid and not self.DefaultJumpHeight then
        self.DefaultJumpHeight = Humanoid.JumpHeight
    end
    self.JumpEnabled = true
    self:ApplyJumpHeight(self.CustomJumpHeight)
end

function MovementManager:DisablePlayerJump()
    self.JumpEnabled = false
    if self.DefaultJumpHeight then
        self:ApplyJumpHeight(self.DefaultJumpHeight)
    end
end

function MovementManager:EnableFly()
    if self.FlyEnabled then return end
    self.FlyEnabled = true

    local UserInputService = self.API:GetUserInputService()
    local RunService = self.API:GetRunService()
    local TweenService = self.API:GetTweenService()

    self.FlyConnections = self.FlyConnections or {}

    self.FlyConnections.Heartbeat = RunService.Heartbeat:Connect(function(dt)
        if not self.FlyEnabled then return end
        local Root = self.API:GetHumanoidRootPart()
        local Humanoid = self:GetHumanoid()
        if not Root or not Humanoid then return end

        Humanoid.PlatformStand = true

        -- Создаём BodyVelocity и BodyGyro если их нет
        if not self.FlyBodyVelocity then
            self.FlyBodyVelocity = Instance.new("BodyVelocity")
            self.FlyBodyVelocity.MaxForce = Vector3.new(1,1,1) * 9e9
            self.FlyBodyVelocity.Parent = Root
        end
        if not self.FlyBodyGyro then
            self.FlyBodyGyro = Instance.new("BodyGyro")
            self.FlyBodyGyro.MaxTorque = Vector3.new(1,1,1) * 9e9
            self.FlyBodyGyro.P = 9e4
            self.FlyBodyGyro.Parent = Root
        end
        local Cam = workspace.CurrentCamera
        local Velocity = Vector3.zero
        local Rotation = Cam.CFrame.Rotation
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            Velocity += Cam.CFrame.LookVector
            Rotation *= CFrame.Angles(math.rad(-40), 0, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            Velocity -= Cam.CFrame.LookVector
            Rotation *= CFrame.Angles(math.rad(40), 0, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            Velocity += Cam.CFrame.RightVector
            Rotation *= CFrame.Angles(0, 0, math.rad(-40))
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            Velocity -= Cam.CFrame.RightVector
            Rotation *= CFrame.Angles(0, 0, math.rad(40))
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            Velocity += Vector3.yAxis
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            Velocity -= Vector3.yAxis
        end
        local TweenInfoObj = TweenInfo.new(0.2)
        local Speed = self.FlySpeed or 16
        if Velocity.Magnitude > 0 then
            TweenService:Create(self.FlyBodyVelocity, TweenInfoObj, { Velocity = Velocity.Unit * Speed }):Play()
        else
            TweenService:Create(self.FlyBodyVelocity, TweenInfoObj, { Velocity = Vector3.zero }):Play()
        end
        TweenService:Create(self.FlyBodyGyro, TweenInfoObj, { CFrame = Rotation }):Play()
    end)
    if not self.FlyConnections.CharacterAdded then
        self.FlyConnections.CharacterAdded = self.API:GetLocalPlayer().CharacterAdded:Connect(function()
            if self.FlyEnabled then
                task.defer(function()
                    self:EnableFly()
                end)
            end
        end)
    end
end

function MovementManager:DisableFly()
    self.FlyEnabled = false
    for _, conn in pairs(self.FlyConnections) do
        if conn then conn:Disconnect() end
    end
    self.FlyConnections = {}
    local root = self.API:GetHumanoidRootPart()
    local Humanoid = self:GetHumanoid()
    if root then
        if self.FlyBodyVelocity then
            self.FlyBodyVelocity:Destroy()
            self.FlyBodyVelocity = nil
        end
        if self.FlyBodyGyro then
            self.FlyBodyGyro:Destroy()
            self.FlyBodyGyro = nil
        end
    end
    if Humanoid then
        Humanoid.PlatformStand = false
    end
end

function MovementManager:SetFlySpeed(Speed)
    self.FlySpeed = Speed
end

function MovementManager:Destroy()
    self:DisablePlayerSpeed()
    self:DisablePlayerJump()
    self:DisableFly()
    if self.HookCharacter then
        self.HookCharacter:Disconnect()
    end
    self.HookCharacter = nil
end

local Window = FluentMenu:CreateWindow{
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
TabID.About:CreateButton{
    Title = "Unload",
    Description = "Fully delete menu and disable function",
    Callback = function()
    Window:Dialog{
        Title = "Unload",
        Content = "???",
        Buttons = {
            {
                Title = "Confirm",
                Callback = function()
                    _G.KRScriptUnload()
                end
            },
            {
                Title = "Cancel",
            }
        }
    }
end
}


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
TabID.Movement:CreateToggle("Jump Player", {Title = "Jump Player", Default = false,
    Callback = function(enabled)
        if enabled then
            Movement:EnablePlayerJump()
        else
            Movement:DisablePlayerJump()
        end
    end
})
TabID.Movement:CreateSlider("Jump Height", {
    Title = "Jump Height",
    Description = "Adjust player jump height",
    Min = 5,
    Max = 50,
    Default = 7.2,
    Callback = function(value)
        Movement:SetJumpHeightValue(value)
    end
})
TabID.Movement:CreateToggle("Fly Player", {Title = "Fly Player", Default = false,
    Callback = function(enabled)
        if enabled then
            Movement:EnableFly()
        else
            Movement:DisableFly()
        end
    end
})
TabID.Movement:CreateSlider("Fly Speed", {
    Title = "Fly Speed",
    Description = "Adjust player fly speed",
    Min = 8,
    Max = 100,
    Default = 16,
    Callback = function(value)
        Movement:SetFlySpeed(value)
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