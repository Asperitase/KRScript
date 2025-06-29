local SpeedManager = {}
SpeedManager.__index = SpeedManager

function SpeedManager.new(api)
    local self = setmetatable({}, SpeedManager)
    self.api = api
    self.player = api:GetLocalPlayer()
    self.default_speed = nil
    self.speed_enabled = false
    self.custom_speed = 16
    self.speed_task = nil
    return self
end

function SpeedManager:get_human()
    local character = self.player.Character or self.player.CharacterAdded:Wait()
    return character:FindFirstChildOfClass("Humanoid")
end

function SpeedManager:set_speed(speed)
    local human = self:get_human()
    if human then
        human.WalkSpeed = speed
    end
end

function SpeedManager:enable_speed(speed)
    if not self.default_speed then
        local human = self:get_human()
        if human then
            self.default_speed = human.WalkSpeed
        end
    end
    
    self.custom_speed = speed or self.custom_speed
    self.speed_enabled = true
    
    -- Запускаем цикл для постоянного поддержания скорости
    if not self.speed_task then
        self.speed_task = task.spawn(function()
            while self.speed_enabled do
                self:set_speed(self.custom_speed)
                task.wait(0.001)
            end
        end)
    end
end

function SpeedManager:disable_speed()
    self.speed_enabled = false
    
    -- Останавливаем цикл
    if self.speed_task then
        task.cancel(self.speed_task)
        self.speed_task = nil
    end
    
    -- Возвращаем исходную скорость
    if self.default_speed then
        self:set_speed(self.default_speed)
    end
end

function SpeedManager:character_added()
    if self.speed_enabled then
        -- Перезапускаем цикл для нового персонажа
        if self.speed_task then
            task.cancel(self.speed_task)
            self.speed_task = nil
        end
        
        self.speed_task = task.spawn(function()
            while self.speed_enabled do
                self:set_speed(self.custom_speed)
                task.wait(0.001)
            end
        end)
    end
end

return SpeedManager 