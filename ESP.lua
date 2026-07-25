-- ESP Module for juanitahaxx
-- Drawing-based ESP (compatible with most executors)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera

local ESP = {
    Enabled = false,
    TeamCheck = true,
    MaxDistance = 2000,

    Box = true,
    BoxColor = Color3.fromRGB(255, 255, 255),
    BoxFilled = false,
    BoxFillColor = Color3.fromRGB(255, 255, 255),
    BoxFillTransparency = 0.85,

    Tracer = true,
    TracerColor = Color3.fromRGB(255, 255, 255),
    TracerOrigin = "Bottom", -- "Bottom", "Center", "Mouse"

    Name = true,
    NameColor = Color3.fromRGB(255, 255, 255),
    NameSize = 13,

    HealthBar = true,
    Distance = true,
    DistanceColor = Color3.fromRGB(255, 255, 255),
    DistanceSize = 12,

    Objects = {},
    RenderConnection = nil,
}

-- Utility
local function GetCharacter(player)
    return player.Character
end

local function GetRootPart(character)
    return character:FindFirstChild("HumanoidRootPart")
end

local function GetHumanoid(character)
    return character:FindFirstChildOfClass("Humanoid")
end

local function IsTeammate(player)
    if not ESP.TeamCheck then return false end
    local localPlayer = Players.LocalPlayer
    if not localPlayer then return false end
    return player.Team == localPlayer.Team
end

local function NewDrawing(Type, Props)
    local d = Drawing.new(Type)
    for k, v in pairs(Props or {}) do
        d[k] = v
    end
    return d
end

local function RemoveESP(player)
    local data = ESP.Objects[player]
    if not data then return end
    for _, obj in pairs(data) do
        if obj and obj.Remove then
            obj:Remove()
        end
    end
    ESP.Objects[player] = nil
end

local function CreateESP(player)
    if ESP.Objects[player] then return end
    if player == Players.LocalPlayer then return end

    ESP.Objects[player] = {
        Box = NewDrawing("Square", {Visible = false, Thickness = 1, Filled = false, ZIndex = 1}),
        BoxFill = NewDrawing("Square", {Visible = false, Filled = true, ZIndex = 0}),
        Tracer = NewDrawing("Line", {Visible = false, Thickness = 1, ZIndex = 1}),
        Name = NewDrawing("Text", {Visible = false, Size = ESP.NameSize, Center = true, Outline = true, ZIndex = 2}),
        HealthBar = NewDrawing("Square", {Visible = false, Filled = true, ZIndex = 2}),
        HealthBarBg = NewDrawing("Square", {Visible = false, Filled = true, ZIndex = 1}),
        Distance = NewDrawing("Text", {Visible = false, Size = ESP.DistanceSize, Center = true, Outline = true, ZIndex = 2}),
    }
end

-- Main Render Loop
function ESP:Render()
    if not self.Enabled then
        for _, data in pairs(self.Objects) do
            for _, obj in pairs(data) do
                if obj and obj.Visible ~= nil then obj.Visible = false end
            end
        end
        return
    end

    local localPlayer = Players.LocalPlayer
    if not localPlayer then return end
    local localChar = localPlayer.Character
    local localRoot = localChar and GetRootPart(localChar)
    local localPos = localRoot and localRoot.Position or Vector3.zero

    for _, player in ipairs(Players:GetPlayers()) do
        if player == localPlayer then continue end

        -- Team check: hide if teammate
        if IsTeammate(player) then
            if self.Objects[player] then
                for _, obj in pairs(self.Objects[player]) do
                    if obj and obj.Visible ~= nil then obj.Visible = false end
                end
            end
            continue
        end

        local char = GetCharacter(player)
        local root = char and GetRootPart(char)
        local humanoid = char and GetHumanoid(char)

        if not char or not root or not humanoid or humanoid.Health <= 0 then
            if self.Objects[player] then
                for _, obj in pairs(self.Objects[player]) do
                    if obj and obj.Visible ~= nil then obj.Visible = false end
                end
            end
            continue
        end

        local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
        if not onScreen then
            if self.Objects[player] then
                for _, obj in pairs(self.Objects[player]) do
                    if obj and obj.Visible ~= nil then obj.Visible = false end
                end
            end
            continue
        end

        local distance = (root.Position - localPos).Magnitude
        if distance > self.MaxDistance then
            if self.Objects[player] then
                for _, obj in pairs(self.Objects[player]) do
                    if obj and obj.Visible ~= nil then obj.Visible = false end
                end
            end
            continue
        end

        if not self.Objects[player] then
            CreateESP(player)
        end

        local data = self.Objects[player]
        local screenPos = Vector2.new(pos.X, pos.Y)

        -- Estimate 2D box size from character height
        local topPos = Camera:WorldToViewportPoint(root.Position + Vector3.new(0, 3, 0))
        local bottomPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
        local boxHeight = math.abs(topPos.Y - bottomPos.Y)
        local boxWidth = boxHeight * 0.55
        local boxPos = Vector2.new(screenPos.X - boxWidth / 2, screenPos.Y - boxHeight / 2)

        -- Box ESP
        if self.Box then
            data.Box.Visible = true
            data.Box.Size = Vector2.new(boxWidth, boxHeight)
            data.Box.Position = boxPos
            data.Box.Color = self.BoxColor

            if self.BoxFilled then
                data.BoxFill.Visible = true
                data.BoxFill.Size = data.Box.Size
                data.BoxFill.Position = data.Box.Position
                data.BoxFill.Color = self.BoxFillColor
                data.BoxFill.Transparency = self.BoxFillTransparency
            else
                data.BoxFill.Visible = false
            end
        else
            data.Box.Visible = false
            data.BoxFill.Visible = false
        end

        -- Tracer ESP
        if self.Tracer then
            data.Tracer.Visible = true
            data.Tracer.Color = self.TracerColor
            local origin
            if self.TracerOrigin == "Bottom" then
                origin = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            elseif self.TracerOrigin == "Center" then
                origin = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            elseif self.TracerOrigin == "Mouse" then
                local mouse = localPlayer:GetMouse()
                origin = Vector2.new(mouse.X, mouse.Y + 36)
            else
                origin = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            end
            data.Tracer.From = origin
            data.Tracer.To = Vector2.new(screenPos.X, boxPos.Y + boxHeight)
        else
            data.Tracer.Visible = false
        end

        -- Name ESP
        if self.Name then
            data.Name.Visible = true
            data.Name.Text = player.Name
            data.Name.Color = self.NameColor
            data.Name.Size = self.NameSize
            data.Name.Position = Vector2.new(screenPos.X, boxPos.Y - 16)
        else
            data.Name.Visible = false
        end

        -- Health Bar ESP
        local health = humanoid.Health
        local maxHealth = humanoid.MaxHealth
        local healthPercent = math.clamp(health / maxHealth, 0, 1)

        if self.HealthBar then
            data.HealthBarBg.Visible = true
            data.HealthBar.Visible = true

            local barHeight = boxHeight
            local barWidth = 3
            local barOffset = 4
            local barX = boxPos.X - barWidth - barOffset
            local barY = boxPos.Y

            data.HealthBarBg.Size = Vector2.new(barWidth, barHeight)
            data.HealthBarBg.Position = Vector2.new(barX, barY)
            data.HealthBarBg.Color = Color3.fromRGB(40, 40, 40)

            local healthHeight = barHeight * healthPercent
            data.HealthBar.Size = Vector2.new(barWidth, healthHeight)
            data.HealthBar.Position = Vector2.new(barX, barY + (barHeight - healthHeight))
            data.HealthBar.Color = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 0)
        else
            data.HealthBar.Visible = false
            data.HealthBarBg.Visible = false
        end

        -- Distance ESP
        if self.Distance then
            data.Distance.Visible = true
            data.Distance.Text = tostring(math.floor(distance)) .. "m"
            data.Distance.Color = self.DistanceColor
            data.Distance.Size = self.DistanceSize
            data.Distance.Position = Vector2.new(screenPos.X, boxPos.Y + boxHeight + 2)
        else
            data.Distance.Visible = false
        end
    end
end

function ESP:Start()
    if self.RenderConnection then return end
    self.RenderConnection = RunService.RenderStepped:Connect(function()
        self:Render()
    end)
end

function ESP:Stop()
    if self.RenderConnection then
        self.RenderConnection:Disconnect()
        self.RenderConnection = nil
    end
    for player, _ in pairs(self.Objects) do
        RemoveESP(player)
    end
end

-- Auto cleanup when players leave
Players.PlayerRemoving:Connect(function(player)
    RemoveESP(player)
end)

return ESP
