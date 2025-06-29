local ESPManager = {}
ESPManager.__index = ESPManager

function ESPManager.New(Api)
    local self = setmetatable({}, ESPManager)
    self.Api = Api
    self.Player = Api:GetLocalPlayer()
    self.Island = Api:GetLocalIsland()
    self.EspTask = nil
    self.EspEnabled = false
    return self
end

function ESPManager:CreateEspGui(Spot)
    local Gui = Instance.new("BillboardGui")
    Gui.Name = "DistanceGui"
    Gui.Adornee = Spot.PrimaryPart or Spot:FindFirstChildWhichIsA("BasePart")
    Gui.Size = UDim2.new(0, 50, 0, 20)
    Gui.StudsOffset = Vector3.new(0, 3, 0)
    Gui.AlwaysOnTop = true
    Gui.Parent = Spot

    local Label = Instance.new("TextLabel")
    Label.Name = "DistanceLabel"
    Label.Size = UDim2.new(1, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Color3.new(1, 1, 1)
    Label.TextStrokeTransparency = 0
    Label.TextStrokeColor3 = Color3.new(0, 0, 0)
    Label.TextScaled = true
    Label.Font = Enum.Font.SourceSansBold
    Label.Parent = Gui
    
    return Label
end

function ESPManager:ShowEsp()
    if self.EspTask then return end
    self.EspEnabled = true
    self.EspTask = task.spawn(function() 
        while self.EspEnabled do
            local Character = self.Player.Character or self.Player.CharacterAdded:Wait()
            local HumanPart = Character:WaitForChild("HumanoidRootPart")
            
            local Spots = {}
            for _, Spot in ipairs(self.Island:GetDescendants()) do
                if Spot:IsA("Model") and Spot.Name:match("Spot") then
                    table.insert(Spots, Spot)
                end
            end
            
            for _, Spot in ipairs(Spots) do
                if not self.EspEnabled then break end -- Проверка на отключение
                
                local Gui = Spot:FindFirstChild("DistanceGui")
                local Label = Gui and Gui:FindFirstChild("DistanceLabel")
                
                if not Label then
                    Label = self:CreateEspGui(Spot)
                end

                local PrimaryPart = Spot.PrimaryPart or Spot:FindFirstChildWhichIsA("BasePart")
                if PrimaryPart then
                    local Distance = (HumanPart.Position - PrimaryPart.Position).Magnitude * 0.8
                    Label.Text = string.format("%.f meters", Distance)
                end
            end
            task.wait(0.2)
        end
    end)
end

function ESPManager:HideEsp()
    self.EspEnabled = false
    if self.EspTask then
        task.cancel(self.EspTask)
        self.EspTask = nil
    end
    for _, Spot in ipairs(self.Island:GetDescendants()) do
        if Spot:IsA("Model") and Spot.Name:match("Spot") then
            local Gui = Spot:FindFirstChild("DistanceGui")
            if Gui then
                Gui:Destroy()
            end
        end
    end
end

function ESPManager:Destroy()
    self:HideEsp()
end

return ESPManager 