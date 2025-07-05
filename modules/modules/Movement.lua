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

function MovementManager:ApplyJumpHeight(jumpHeight)
    local Humanoid = self:GetHumanoid()
    if Humanoid then
        Humanoid.JumpHeight = jumpHeight
        if Humanoid.UseJumpPower then
            Humanoid.JumpPower = math.sqrt(349.24 * jumpHeight)
        end
    end
end

function MovementManager:SetJumpHeightValue(jumpHeight)
    self.CustomJumpHeight = jumpHeight
    if self.JumpEnabled then
        self:ApplyJumpHeight(jumpHeight)
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
        local root = self.API:GetHumanoidRootPart()
        local humanoid = self:GetHumanoid()
        if not root or not humanoid then return end

        humanoid.PlatformStand = true

        -- Создаём BodyVelocity и BodyGyro если их нет
        if not self.FlyBodyVelocity then
            self.FlyBodyVelocity = Instance.new("BodyVelocity")
            self.FlyBodyVelocity.MaxForce = Vector3.new(1,1,1) * 9e9
            self.FlyBodyVelocity.Parent = root
        end
        if not self.FlyBodyGyro then
            self.FlyBodyGyro = Instance.new("BodyGyro")
            self.FlyBodyGyro.MaxTorque = Vector3.new(1,1,1) * 9e9
            self.FlyBodyGyro.P = 9e4
            self.FlyBodyGyro.Parent = root
        end

        local cam = workspace.CurrentCamera
        local velocity = Vector3.zero
        local rotation = cam.CFrame.Rotation

        -- Управление направлениями через IsKeyDown
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            velocity += cam.CFrame.LookVector
            rotation *= CFrame.Angles(math.rad(-40), 0, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            velocity -= cam.CFrame.LookVector
            rotation *= CFrame.Angles(math.rad(40), 0, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            velocity += cam.CFrame.RightVector
            rotation *= CFrame.Angles(0, 0, math.rad(-40))
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            velocity -= cam.CFrame.RightVector
            rotation *= CFrame.Angles(0, 0, math.rad(40))
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            velocity += Vector3.yAxis
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            velocity -= Vector3.yAxis
        end

        -- Плавное изменение скорости и поворота
        local tweenInfo = TweenInfo.new(0.2)
        local speed = self.FlySpeed or 16
        if velocity.Magnitude > 0 then
            TweenService:Create(self.FlyBodyVelocity, tweenInfo, { Velocity = velocity.Unit * speed }):Play()
        else
            TweenService:Create(self.FlyBodyVelocity, tweenInfo, { Velocity = Vector3.zero }):Play()
        end
        TweenService:Create(self.FlyBodyGyro, tweenInfo, { CFrame = rotation }):Play()
    end)

    -- Подписка на респавн
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
    local humanoid = self:GetHumanoid()
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
    if humanoid then
        humanoid.PlatformStand = false
    end
end

function MovementManager:SetFlySpeed(speed)
    self.FlySpeed = speed
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

return MovementManager 