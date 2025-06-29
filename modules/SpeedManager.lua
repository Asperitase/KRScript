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
    return self
end

function SpeedManager:GetHuman()
    local Character = self.Player.Character or self.Player.CharacterAdded:Wait()
    return Character:FindFirstChildOfClass("Humanoid")
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
    
    -- Запускаем цикл для постоянного поддержания скорости
    if not self.SpeedTask then
        self.SpeedTask = task.spawn(function()
            while self.SpeedEnabled do
                self:SetSpeed(self.CustomSpeed)
                task.wait(0.001)
            end
        end)
    end
end

function SpeedManager:DisableSpeed()
    self.SpeedEnabled = false
    
    -- Останавливаем цикл
    if self.SpeedTask then
        task.cancel(self.SpeedTask)
        self.SpeedTask = nil
    end
    
    -- Возвращаем исходную скорость
    if self.DefaultSpeed then
        self:SetSpeed(self.DefaultSpeed)
    end
end

function SpeedManager:CharacterAdded()
    if self.SpeedEnabled then
        -- Перезапускаем цикл для нового персонажа
        if self.SpeedTask then
            task.cancel(self.SpeedTask)
            self.SpeedTask = nil
        end
        
        self.SpeedTask = task.spawn(function()
            while self.SpeedEnabled do
                self:SetSpeed(self.CustomSpeed)
                task.wait(0.001)
            end
        end)
    end
end

return SpeedManager 