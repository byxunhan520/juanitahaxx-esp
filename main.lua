local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/byxunhan520/Juanitahaxx-ESP/main/Library.lua"))()
local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/byxunhan520/Juanitahaxx-ESP/main/ESP.lua"))()

do
    Window = Library:Window({Name = "juanitahaxx ESP Edition"})
    local Watermark = Window:Watermark({Name = "juanitahaxx"})
    local KeybindList = Window:KeybindList()

    do
        local CombatPage = Window:Page({Name = "combat"})
        local MiscPage = Window:Page({Name = "misc"})
        local VisualsPage = Window:Page({Name = "visuals"})
        local PlayersPage = Window:Page({Name = "players"})

        -- ========== COMBAT (保留原样) ==========
        do
            local LeftSection = CombatPage:Section({Name = "Left", Side = 1})
            local RightSection = CombatPage:Section({Name = "Right", Side = 2})

            LeftSection:Toggle({
                Name = "Auto Parry",
                Flag = "AutoParry",
                Default = false,
                Callback = function(v) print(v) end
            })

            LeftSection:Button({
                Name = "Execute",
                Callback = function() print("Clicked") end
            })

            LeftSection:Slider({
                Name = "Walkspeed",
                Flag = "walkspeed",
                Min = 0, Max = 100, Default = 16,
                Decimals = 1, Suffix = "%",
                Callback = function(value) end
            })

            LeftSection:Dropdown({
                Name = "Target",
                Flag = "target",
                Items = {"Head", "Torso", "Random", "foot", "penile"},
                Default = "Head", Multi = false,
                Callback = function(value) end
            })

            RightSection:Button({
                Name = "post notif",
                Callback = function()
                    Library:Notification("This is a notification lmfao", 5, Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255)))
                end
            })

            RightSection:Label({Name = "default laberl"})

            RightSection:Label({Name = "colorpicker"}):Colorpicker({
                Name = "Colorpicker", Flag = "color",
                Default = Color3.fromRGB(255, 255, 255),
                Callback = function(value, alpha) print(value, alpha) end
            })

            RightSection:Label({Name = "Keybind"}):Keybind({
                Name = "Keybind", Flag = "keybind",
                Default = Enum.KeyCode.E, Mode = "Toggle",
                Callback = function(value) print(value) end
            })

            RightSection:Label({Name = "second keybind"}):Keybind({
                Name = "Keybind", Flag = "keybind2",
                Default = Enum.KeyCode.F, Mode = "Toggle",
                Callback = function(value) print(value) end
            })

            RightSection:Label({Name = "third keybind"}):Keybind({
                Name = "Keybind", Flag = "keybind3",
                Default = Enum.KeyCode.R, Mode = "Toggle",
                Callback = function(value) print(value) end
            })

            RightSection:Textbox({
                Name = "Textbox", Flag = "textbox",
                Default = "default", Placeholder = "placeholder",
                Numeric = false, Finished = false,
                Callback = function(value) print(value) end
            })
        end

        -- ========== VISUALS -> ESP ==========
        do
            local ESPSection = VisualsPage:Section({Name = "ESP", Side = 1})
            local ESPStyle = VisualsPage:Section({Name = "ESP Style", Side = 2})
            local ESPSettings = VisualsPage:Section({Name = "ESP Settings", Side = 2})

            -- 主开关
            ESPSection:Toggle({
                Name = "Enabled",
                Flag = "ESPEnabled",
                Default = false,
                Callback = function(v)
                    ESP.Enabled = v
                end
            })

            -- 2D Box
            ESPSection:Toggle({
                Name = "2D Box",
                Flag = "ESPBox2D",
                Default = true,
                Callback = function(v)
                    ESP.Box2D = v
                end
            }):Colorpicker({
                Name = "Box Color",
                Flag = "ESPBoxColor",
                Default = Color3.fromRGB(0, 255, 255),
                Callback = function(color, alpha)
                    ESP.BoxColor = color
                end
            })

            -- Skeleton
            ESPSection:Toggle({
                Name = "Skeleton",
                Flag = "ESPSkeleton",
                Default = true,
                Callback = function(v)
                    ESP.Skeleton = v
                end
            }):Colorpicker({
                Name = "Skeleton Color",
                Flag = "ESPSkeletonColor",
                Default = Color3.fromRGB(180, 120, 255),
                Callback = function(color, alpha)
                    ESP.SkeletonColor = color
                end
            })

            -- Tracer
            ESPSection:Toggle({
                Name = "Tracer",
                Flag = "ESPTracer",
                Default = true,
                Callback = function(v)
                    ESP.Tracer = v
                end
            }):Colorpicker({
                Name = "Tracer Color",
                Flag = "ESPTracerColor",
                Default = Color3.fromRGB(0, 255, 255),
                Callback = function(color, alpha)
                    ESP.TracerColor = color
                end
            })

            -- Name
            ESPSection:Toggle({
                Name = "Name",
                Flag = "ESPName",
                Default = true,
                Callback = function(v)
                    ESP.Name = v
                end
            }):Colorpicker({
                Name = "Name Color",
                Flag = "ESPNameColor",
                Default = Color3.fromRGB(255, 255, 255),
                Callback = function(color, alpha)
                    ESP.NameColor = color
                end
            })

            -- Health Bar
            ESPSection:Toggle({
                Name = "Health Bar",
                Flag = "ESPHealthBar",
                Default = true,
                Callback = function(v)
                    ESP.HealthBar = v
                end
            })

            -- Distance
            ESPSection:Toggle({
                Name = "Distance",
                Flag = "ESPDistance",
                Default = true,
                Callback = function(v)
                    ESP.Distance = v
                end
            }):Colorpicker({
                Name = "Distance Color",
                Flag = "ESPDistanceColor",
                Default = Color3.fromRGB(200, 200, 200),
                Callback = function(color, alpha)
                    ESP.DistanceColor = color
                end
            })

            -- Weapon
            ESPSection:Toggle({
                Name = "Weapon",
                Flag = "ESPWeapon",
                Default = true,
                Callback = function(v)
                    ESP.Weapon = v
                end
            }):Colorpicker({
                Name = "Weapon Color",
                Flag = "ESPWeaponColor",
                Default = Color3.fromRGB(255, 220, 100),
                Callback = function(color, alpha)
                    ESP.WeaponColor = color
                end
            })

            -- 3D Box
            ESPStyle:Toggle({
                Name = "3D Box (Beta)",
                Flag = "ESPBox3D",
                Default = false,
                Callback = function(v)
                    ESP.Box3D = v
                end
            })

            -- Tracer Origin
            ESPSettings:Dropdown({
                Name = "Tracer Origin",
                Flag = "ESPTracerOrigin",
                Items = {"Bottom", "Center", "Mouse"},
                Default = "Bottom", Multi = false,
                Callback = function(value)
                    ESP.TracerOrigin = value
                end
            })

            -- Max Distance
            ESPSettings:Slider({
                Name = "Max Distance",
                Flag = "ESPMaxDistance",
                Min = 100, Max = 5000, Default = 5000,
                Decimals = 0, Suffix = "m",
                Callback = function(value)
                    ESP.MaxDistance = value
                end
            })

            -- Team Check
            ESPSettings:Toggle({
                Name = "Team Check",
                Flag = "ESPTeamCheck",
                Default = false,
                Callback = function(v)
                    ESP.TeamCheck = v
                end
            })
        end
    end

    -- 启动 ESP 渲染
    do
        ESP:Start()
    end

    -- Watermark
    do
        local FpsText = Watermark:Add("FPS: ")
        local DateTimeText = Watermark:Add("")

        local FPS = 0
        local FrameCount = 0
        local Elapsed = 0

        Library:Connect(game:GetService("RunService").RenderStepped, function(DeltaT)
            FrameCount += 1
            Elapsed += DeltaT

            if Elapsed >= 1 then
                FPS = math.floor(FrameCount / Elapsed)
                FpsText:SetText("FPS: " .. FPS)
                FrameCount = 0
                Elapsed = 0
            end

            DateTimeText:SetText(os.date("%H:%M:%S %d/%m/%Y"))
        end)
    end
end

Window:Init()
