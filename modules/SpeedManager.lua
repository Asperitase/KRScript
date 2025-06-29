local SpeedManager = {}
SpeedManager.__index = SpeedManager

function SpeedManager.New(Api)
    local self = setmetatable({}, SpeedManager)
    self.Api = Api
    self.Player = Api:GetLocalPlayer()
    self.DefaultSpeed = nil
    self.SpeedEnabled = false
    self.CustomSpeed = 16
    self.SpeedTask = nil
    self.CachedHumanoid = nil
    self.LastHumanoidCheck = 0
    self.HumanoidCheckInterval = 0.5
    return self
end

function SpeedManager:GetHuman()
    local CurrentTime = tick()
    if CurrentTime - self.LastHumanoidCheck > self.HumanoidCheckInterval then
        self.LastHumanoidCheck = CurrentTime
        local Character = self.Player.Character
        if Character then
            self.CachedHumanoid = Character:FindFirstChildOfClass("Humanoid")
        else
            self.CachedHumanoid = nil
        end
    end
    return self.CachedHumanoid
end

function SpeedManager:SetSpeed(Speed)
    local Human = self:GetHuman()
    if Human then
        Human.WalkSpeed = Speed
    end
end

function SpeedManager:EnableSpeed(Speed)
    if not self.DefaultSpeed then
        local Human = self:GetHuman()
        if Human then
            self.DefaultSpeed = Human.WalkSpeed
        end
    end
    
    self.CustomSpeed = Speed or self.CustomSpeed
    self.SpeedEnabled = true
    
    if not self.SpeedTask then
        self.SpeedTask = task.spawn(function()
            while self.SpeedEnabled do
                self:SetSpeed(self.CustomSpeed)
                task.wait(0.05)
            end
        end)
    end
end

function SpeedManager:DisableSpeed()
    self.SpeedEnabled = false
    
    if self.SpeedTask then
        task.cancel(self.SpeedTask)
        self.SpeedTask = nil
    end
    
    if self.DefaultSpeed then
        self:SetSpeed(self.DefaultSpeed)
    end
end

function SpeedManager:CharacterAdded()
    self.CachedHumanoid = nil
    self.LastHumanoidCheck = 0
    
    if self.SpeedEnabled then
        if self.SpeedTask then
            task.cancel(self.SpeedTask)
            self.SpeedTask = nil
        end
        
        self.SpeedTask = task.spawn(function()
            while self.SpeedEnabled do
                self:SetSpeed(self.CustomSpeed)
                task.wait(0.05)
            end
        end)
    end
end

function SpeedManager:Destroy()
    self:DisableSpeed()
    self.DefaultSpeed = nil
    self.CustomSpeed = 16
    self.CachedHumanoid = nil
end

return SpeedManager 