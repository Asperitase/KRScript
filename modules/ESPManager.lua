local ESPManager = {}
ESPManager.__index = ESPManager

function ESPManager.new(api)
    local self = setmetatable({}, ESPManager)
    self.api = api
    self.player = api:GetLocalPlayer()
    self.land = api:GetLand()
    self.esp_task = nil
    return self
end

function ESPManager:create_esp_gui(spot)
    local gui = Instance.new("BillboardGui")
    gui.Name = "DistanceGui"
    gui.Adornee = spot.PrimaryPart or spot:FindFirstChildWhichIsA("BasePart")
    gui.Size = UDim2.new(0, 50, 0, 20)
    gui.StudsOffset = Vector3.new(0, 3, 0)
    gui.AlwaysOnTop = true
    gui.Parent = spot

    local label = Instance.new("TextLabel")
    label.Name = "DistanceLabel"
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextStrokeTransparency = 0
    label.TextStrokeColor3 = Color3.new(0, 0, 0)
    label.TextScaled = true
    label.Font = Enum.Font.SourceSansBold
    label.Parent = gui
    
    return label
end

function ESPManager:show_esp()
    if self.esp_task then return end
    self.esp_task = task.spawn(function() 
        while true do
            local character = self.player.Character or self.player.CharacterAdded:Wait()
            local human_part = character:WaitForChild("HumanoidRootPart")
            for _, spot in ipairs(self.land:GetDescendants()) do
                if spot:IsA("Model") and spot.Name:match("Spot") then
                    local gui = spot:FindFirstChild("DistanceGui")
                    local label = gui and gui:FindFirstChild("DistanceLabel")
                    
                    if not label then
                        label = self:create_esp_gui(spot)
                    end

                    local primaryPart = spot.PrimaryPart or spot:FindFirstChildWhichIsA("BasePart")
                    if primaryPart then
                        local distance = (human_part.Position - primaryPart.Position).Magnitude * 0.8
                        label.Text = string.format("%.f meters", distance)
                    end
                end
            end
            task.wait(0.2)
        end
    end)
end

function ESPManager:hide_esp()
    if self.esp_task then
        task.cancel(self.esp_task)
        self.esp_task = nil
    end
    for _, spot in ipairs(self.land:GetDescendants()) do
        if spot:IsA("Model") and spot.Name:match("Spot") then
            local gui = spot:FindFirstChild("DistanceGui")
            if gui then
                gui:Destroy()
            end
        end
    end
end

return ESPManager 