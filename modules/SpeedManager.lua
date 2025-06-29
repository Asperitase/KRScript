local SpeedManager = {}
SpeedManager.__index = SpeedManager

function SpeedManager.new(api)
    local self = setmetatable({}, SpeedManager)
    self.api = api
    self.player = api:GetLocalPlayer()
    self.default_speed = nil
    self.speed_enabled = false
    self.custom_speed = 16
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
    self:set_speed(self.custom_speed)
end

function SpeedManager:disable_speed()
    self.speed_enabled = false
    if self.default_speed then
        self:set_speed(self.default_speed)
    end
end

function SpeedManager:character_added()
    if self.speed_enabled then
        self:set_speed(self.custom_speed)
    end
end

return SpeedManager 