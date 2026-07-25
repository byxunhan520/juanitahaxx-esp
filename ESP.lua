-- ============================================================
--  ESP V2 - Full Featured & Aesthetic
--  Style: Cyber-Neon with glow effects
-- ============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera

local ESP = {
    Enabled = false,
    TeamCheck = false,          -- 默认关闭团队检测，显示所有人
    MaxDistance = 5000,

    -- 主开关
    Box2D = true,
    Box3D = false,              -- 3D 旋转方框（更帅但更耗）
    Skeleton = true,
    Tracer = true,
    Name = true,
    HealthBar = true,
    Distance = true,
    Weapon = true,              -- 显示手持物品/武器

    -- 颜色预设 (霓虹赛博风格)
    BoxColor = Color3.fromRGB(0, 255, 255),      -- 青色主框
    BoxOutlineColor = Color3.fromRGB(0, 0, 0),   -- 黑边
    SkeletonColor = Color3.fromRGB(180, 120, 255), -- 紫色骨骼
    TracerColor = Color3.fromRGB(0, 255, 255),
    NameColor = Color3.fromRGB(255, 255, 255),
    DistanceColor = Color3.fromRGB(200, 200, 200),
    WeaponColor = Color3.fromRGB(255, 220, 100), -- 金黄色武器名

    -- 样式细节
    BoxThickness = 1.2,
    TracerThickness = 1,
    SkeletonThickness = 1.2,
    NameSize = 13,
    DistanceSize = 11,
    WeaponSize = 11,
    TracerOrigin = "Bottom",    -- Bottom / Center / Mouse

    -- 内部数据
    Objects = {},
    RenderConnection = nil,
}

-- 骨骼连接定义 (R15 / R6 兼容)
local SkeletonConnections = {
    {"Head", "UpperTorso"},
    {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"},
    {"LeftUpperArm", "LeftLowerArm"},
    {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"},
    {"RightUpperArm", "RightLowerArm"},
    {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"},
    {"LeftUpperLeg", "LeftLowerLeg"},
    {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"},
    {"RightUpperLeg", "RightLowerLeg"},
    {"RightLowerLeg", "RightFoot"},
    -- R6 兼容别名
    {"Torso", "Left Arm"},
    {"Left Arm", "Left Leg"},
    {"Torso", "Right Arm"},
    {"Right Arm", "Right Leg"},
    {"Torso", "Head"},
}

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
        if type(obj) == "table" then
            for _, sub in pairs(obj) do
                if sub and sub.Remove then sub:Remove() end
            end
        elseif obj and obj.Remove then
            obj:Remove()
        end
    end
    ESP.Objects[player] = nil
end

local function IsTeammate(player)
    if not ESP.TeamCheck then return false end
    local lp = Players.LocalPlayer
    if not lp then return false end
    if not lp.Team or not player.Team then return false end
    return player.Team == lp.Team
end

local function GetChar(player)
    return player.Character
end

local function GetRoot(char)
    return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
end

local function GetHumanoid(char)
    return char:FindFirstChildOfClass("Humanoid")
end

local function GetWeaponName(char)
    local tool = char:FindFirstChildOfClass("Tool")
    if tool then return tool.Name end
    -- 有些游戏武器在 Backpack 或特定位置
    for _, child in pairs(char:GetChildren()) do
        if child:IsA("Tool") then
            return child.Name
        end
    end
    return nil
end

local function WorldToScreen(pos)
    local screenPos, onScreen = Camera:WorldToViewportPoint(pos)
    return Vector2.new(screenPos.X, screenPos.Y), onScreen, screenPos.Z
end

local function CreateESP(player)
    if ESP.Objects[player] then return end
    if player == Players.LocalPlayer then return end

    local data = {
        -- 2D Box: 外框 + 内框 模拟发光
        BoxOuter = NewDrawing("Square", {Visible = false, Thickness = ESP.BoxThickness + 2, Filled = false, Transparency = 0.8}),
        BoxInner = NewDrawing("Square", {Visible = false, Thickness = ESP.BoxThickness, Filled = false}),
        BoxFill  = NewDrawing("Square", {Visible = false, Filled = true, Transparency = 0.08}),

        -- 3D Box (8条线)
        Box3D = {},

        -- 骨骼
        Skeleton = {},

        -- Tracer
        Tracer = NewDrawing("Line", {Visible = false, Thickness = ESP.TracerThickness}),

        -- 文字
        Name = NewDrawing("Text", {Visible = false, Size = ESP.NameSize, Center = true, Outline = true, OutlineColor = Color3.fromRGB(0,0,0), Font = Drawing.Fonts.UI}),
        Distance = NewDrawing("Text", {Visible = false, Size = ESP.DistanceSize, Center = true, Outline = true, OutlineColor = Color3.fromRGB(0,0,0), Font = Drawing.Fonts.UI}),
        Weapon = NewDrawing("Text", {Visible = false, Size = ESP.WeaponSize, Center = true, Outline = true, OutlineColor = Color3.fromRGB(0,0,0), Font = Drawing.Fonts.UI}),

        -- 血条
        HealthBarBg = NewDrawing("Square", {Visible = false, Filled = true, Color = Color3.fromRGB(30, 30, 30), Transparency = 0.9}),
        HealthBar = NewDrawing("Square", {Visible = false, Filled = true}),
    }

    -- 预创建骨骼线
    for i = 1, #SkeletonConnections do
        data.Skeleton[i] = NewDrawing("Line", {Visible = false, Thickness = ESP.SkeletonThickness})
    end

    -- 预创建 3D Box 线 (12条)
    for i = 1, 12 do
        data.Box3D[i] = NewDrawing("Line", {Visible = false, Thickness = ESP.BoxThickness})
    end

    ESP.Objects[player] = data
end

-- 获取角色边界框
local function GetBoundingBox(char)
    local minX, minY, maxX, maxY = math.huge, math.huge, -math.huge, -math.huge
    local root = GetRoot(char)
    if not root then return nil end

    local rootPos = root.Position
    local size = Vector3.new(4, 6, 4) -- 默认大小

    -- 尝试用 Humanoid 获取更准确的高度
    local humanoid = GetHumanoid(char)
    if humanoid then
        -- R15 / R6 高度估算
        local head = char:FindFirstChild("Head")
        if head then
            local headPos = head.Position
            local height = math.abs(headPos.Y - rootPos.Y) * 2.2
            size = Vector3.new(height * 0.45, height, height * 0.45)
        end
    end

    local corners = {
        rootPos + Vector3.new(-size.X/2, size.Y/2, -size.Z/2),
        rootPos + Vector3.new(size.X/2, size.Y/2, -size.Z/2),
        rootPos + Vector3.new(size.X/2, size.Y/2, size.Z/2),
        rootPos + Vector3.new(-size.X/2, size.Y/2, size.Z/2),
        rootPos + Vector3.new(-size.X/2, -size.Y/2, -size.Z/2),
        rootPos + Vector3.new(size.X/2, -size.Y/2, -size.Z/2),
        rootPos + Vector3.new(size.X/2, -size.Y/2, size.Z/2),
        rootPos + Vector3.new(-size.X/2, -size.Y/2, size.Z/2),
    }

    for _, corner in pairs(corners) do
        local screenPos, onScreen = WorldToScreen(corner)
        if onScreen then
            minX = math.min(minX, screenPos.X)
            minY = math.min(minY, screenPos.Y)
            maxX = math.max(maxX, screenPos.X)
            maxY = math.max(maxY, screenPos.Y)
        end
    end

    if minX == math.huge then return nil end

    return {
        X = minX,
        Y = minY,
        W = maxX - minX,
        H = maxY - minY,
        Corners = corners,
    }
end

function ESP:Render()
    if not self.Enabled then
        for _, data in pairs(self.Objects) do
            for k, obj in pairs(data) do
                if type(obj) == "table" then
                    for _, sub in pairs(obj) do
                        if sub.Visible ~= nil then sub.Visible = false end
                    end
                elseif obj.Visible ~= nil then
                    obj.Visible = false
                end
            end
        end
        return
    end

    local lp = Players.LocalPlayer
    if not lp then return end
    local lpChar = lp.Character
    local lpRoot = lpChar and GetRoot(lpChar)
    local lpPos = lpRoot and lpRoot.Position or Vector3.zero

    for _, player in ipairs(Players:GetPlayers()) do
        if player == lp then continue end

        -- 团队检测
        if IsTeammate(player) then
            local data = self.Objects[player]
            if data then
                for k, obj in pairs(data) do
                    if type(obj) == "table" then
                        for _, sub in pairs(obj) do if sub.Visible ~= nil then sub.Visible = false end end
                    elseif obj.Visible ~= nil then obj.Visible = false end
                end
            end
            continue
        end

        local char = GetChar(player)
        local root = char and GetRoot(char)
        local humanoid = char and GetHumanoid(char)

        if not char or not root or not humanoid or humanoid.Health <= 0 then
            local data = self.Objects[player]
            if data then
                for k, obj in pairs(data) do
                    if type(obj) == "table" then
                        for _, sub in pairs(obj) do if sub.Visible ~= nil then sub.Visible = false end end
                    elseif obj.Visible ~= nil then obj.Visible = false end
                end
            end
            continue
        end

        local rootScreen, onScreen, depth = WorldToScreen(root.Position)
        if not onScreen then
            local data = self.Objects[player]
            if data then
                for k, obj in pairs(data) do
                    if type(obj) == "table" then
                        for _, sub in pairs(obj) do if sub.Visible ~= nil then sub.Visible = false end end
                    elseif obj.Visible ~= nil then obj.Visible = false end
                end
            end
            continue
        end

        local distance = (root.Position - lpPos).Magnitude
        if distance > self.MaxDistance then
            local data = self.Objects[player]
            if data then
                for k, obj in pairs(data) do
                    if type(obj) == "table" then
                        for _, sub in pairs(obj) do if sub.Visible ~= nil then sub.Visible = false end end
                    elseif obj.Visible ~= nil then obj.Visible = false end
                end
            end
            continue
        end

        if not self.Objects[player] then
            CreateESP(player)
        end

        local data = self.Objects[player]
        local box = GetBoundingBox(char)

        -- 距离透明度衰减 (越远越淡)
        local fade = math.clamp(1 - (distance / self.MaxDistance), 0.3, 1)

        -- ========== 2D BOX ==========
        if self.Box2D and box then
            -- 外框 (黑色描边效果)
            data.BoxOuter.Visible = true
            data.BoxOuter.Position = Vector2.new(box.X - 1, box.Y - 1)
            data.BoxOuter.Size = Vector2.new(box.W + 2, box.H + 2)
            data.BoxOuter.Color = self.BoxOutlineColor
            data.BoxOuter.Transparency = fade

            -- 内框 (主色)
            data.BoxInner.Visible = true
            data.BoxInner.Position = Vector2.new(box.X, box.Y)
            data.BoxInner.Size = Vector2.new(box.W, box.H)
            data.BoxInner.Color = self.BoxColor
            data.BoxInner.Transparency = fade

            -- 填充
            data.BoxFill.Visible = true
            data.BoxFill.Position = data.BoxInner.Position
            data.BoxFill.Size = data.BoxInner.Size
            data.BoxFill.Color = self.BoxColor
            data.BoxFill.Transparency = 0.05 * fade
        else
            data.BoxOuter.Visible = false
            data.BoxInner.Visible = false
            data.BoxFill.Visible = false
        end

        -- ========== 3D BOX ==========
        if self.Box3D and box and box.Corners then
            local c = box.Corners
            local edges = {
                {1,2},{2,3},{3,4},{4,1}, -- 顶面
                {5,6},{6,7},{7,8},{8,5}, -- 底面
                {1,5},{2,6},{3,7},{4,8}, -- 侧面
            }
            for i, edge in ipairs(edges) do
                local p1, on1 = WorldToScreen(c[edge[1]])
                local p2, on2 = WorldToScreen(c[edge[2]])
                if on1 and on2 then
                    data.Box3D[i].Visible = true
                    data.Box3D[i].From = p1
                    data.Box3D[i].To = p2
                    data.Box3D[i].Color = self.BoxColor
                    data.Box3D[i].Transparency = fade
                else
                    data.Box3D[i].Visible = false
                end
            end
        else
            for i = 1, 12 do data.Box3D[i].Visible = false end
        end

        -- ========== SKELETON ==========
        if self.Skeleton then
            for i, conn in ipairs(SkeletonConnections) do
                local p1 = char:FindFirstChild(conn[1])
                local p2 = char:FindFirstChild(conn[2])
                if p1 and p2 then
                    local s1, on1 = WorldToScreen(p1.Position)
                    local s2, on2 = WorldToScreen(p2.Position)
                    if on1 and on2 then
                        data.Skeleton[i].Visible = true
                        data.Skeleton[i].From = s1
                        data.Skeleton[i].To = s2
                        data.Skeleton[i].Color = self.SkeletonColor
                        data.Skeleton[i].Transparency = fade
                    else
                        data.Skeleton[i].Visible = false
                    end
                else
                    data.Skeleton[i].Visible = false
                end
            end
        else
            for i = 1, #SkeletonConnections do
                data.Skeleton[i].Visible = false
            end
        end

        -- ========== TRACER ==========
        if self.Tracer and box then
            data.Tracer.Visible = true
            data.Tracer.Color = self.TracerColor
            data.Tracer.Transparency = fade

            local origin
            if self.TracerOrigin == "Bottom" then
                origin = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            elseif self.TracerOrigin == "Center" then
                origin = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            elseif self.TracerOrigin == "Mouse" then
                local mouse = lp:GetMouse()
                origin = Vector2.new(mouse.X, mouse.Y + 36)
            else
                origin = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            end

            data.Tracer.From = origin
            data.Tracer.To = Vector2.new(box.X + box.W / 2, box.Y + box.H)
        else
            data.Tracer.Visible = false
        end

        -- ========== NAME ==========
        if self.Name and box then
            data.Name.Visible = true
            data.Name.Text = player.Name
            data.Name.Color = self.NameColor
            data.Name.Size = self.NameSize
            data.Name.Position = Vector2.new(box.X + box.W / 2, box.Y - self.NameSize - 4)
            data.Name.Transparency = fade
        else
            data.Name.Visible = false
        end

        -- ========== HEALTH BAR ==========
        if self.HealthBar and box then
            local health = humanoid.Health
            local maxHealth = humanoid.MaxHealth
            local pct = math.clamp(health / maxHealth, 0, 1)

            local barW = 3
            local barH = box.H
            local barX = box.X - barW - 5
            local barY = box.Y

            -- 背景
            data.HealthBarBg.Visible = true
            data.HealthBarBg.Position = Vector2.new(barX - 1, barY - 1)
            data.HealthBarBg.Size = Vector2.new(barW + 2, barH + 2)
            data.HealthBarBg.Transparency = 0.7 * fade

            -- 血条
            data.HealthBar.Visible = true
            local fillH = barH * pct
            data.HealthBar.Position = Vector2.new(barX, barY + (barH - fillH))
            data.HealthBar.Size = Vector2.new(barW, fillH)
            -- 颜色：满血绿 -> 低血红
            data.HealthBar.Color = Color3.fromRGB(255 * (1 - pct), 255 * pct, 50)
            data.HealthBar.Transparency = fade
        else
            data.HealthBarBg.Visible = false
            data.HealthBar.Visible = false
        end

        -- ========== DISTANCE ==========
        if self.Distance and box then
            data.Distance.Visible = true
            data.Distance.Text = string.format("[%dm]", math.floor(distance))
            data.Distance.Color = self.DistanceColor
            data.Distance.Size = self.DistanceSize
            data.Distance.Position = Vector2.new(box.X + box.W / 2, box.Y + box.H + 2)
            data.Distance.Transparency = fade
        else
            data.Distance.Visible = false
        end

        -- ========== WEAPON ==========
        if self.Weapon and box then
            local weapon = GetWeaponName(char)
            if weapon then
                data.Weapon.Visible = true
                data.Weapon.Text = tostring(weapon)
                data.Weapon.Color = self.WeaponColor
                data.Weapon.Size = self.WeaponSize
                data.Weapon.Position = Vector2.new(box.X + box.W / 2, box.Y + box.H + (self.Distance and (self.DistanceSize + 4) or 2))
                data.Weapon.Transparency = fade
            else
                data.Weapon.Visible = false
            end
        else
            data.Weapon.Visible = false
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

-- 玩家离开时清理
Players.PlayerRemoving:Connect(function(player)
    RemoveESP(player)
end)

return ESP
