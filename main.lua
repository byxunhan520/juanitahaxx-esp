local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/byxunhan520/Juanitahaxx-ESP/main/Library.lua"))()
local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/byxunhan520/Juanitahaxx-ESP/main/ESP.lua"))()

do
    Window = Library:Window({Name = "juanitahaxx free release"})
    local Watermark = Window:Watermark({Name = "juanitahaxx"})
    local KeybindList = Window:KeybindList()

    do
        local CombatPage = Window:Page({Name = "combat"})
        local MiscPage = Window:Page({Name = "misc"})
        local VisualsPage = Window:Page({Name = "visuals"})
        local PlayersPage = Window:Page({Name = "players"})

        do
            local LeftSection = CombatPage:Section({Name = "Left", Side = 1})
            local RightSection = CombatPage:Section({Name = "Right", Side = 2})

            do
                LeftSection:Toggle({
                    Name = "Auto Parry",
                    Flag = "AutoParry",
                    Default = false,
                    Callback = function(v)
                        print(v)
                    end
                })

                LeftSection:Button({
                    Name = "Execute",
                    Callback = function()
                        print("Clicked")
                    end
                })

                LeftSection:Slider({
                    Name = "Walkspeed",
                    Flag = "walkspeed",
                    Min = 0,
                    Max = 100,
                    Default = 16,
                    Decimals = 1,
                    Suffix = "%",
                    Callback = function(value)
                    end
                })

                LeftSection:Dropdown({
                    Name = "Target",
                    Flag = "target",
                    Items = {"Head", "Torso", "Random", "foot", "penile"},
                    Default = "Head",
                    Multi = false,
                    Callback = function(value)
                    end
                })
            end

            do
                RightSection:Button({
                    Name = "post notif",
                    Callback = function()
                        Library:Notification("This is a notification lmfao", 5, Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255)))
                    end
                })

                RightSection:Label({Name = "default laberl"})

                RightSection:Label({Name = "colorpicker"}):Colorpicker({
                    Name = "Colorpicker",
                    Flag = "color",
                    Default = Color3.fromRGB(255, 255, 255),
                    Callback = function(value, alpha)
                        print(value, alpha)
                    end
                })

                RightSection:Label({Name = "Keybind"}):Keybind({
                    Name = "Keybind",
                    Flag = "keybind",
                    Default = Enum.KeyCode.E,
                    Mode = "Toggle",
                    Callback = function(value)
                        print(value)
                    end
                })

                RightSection:Label({Name = "second keybind"}):Keybind({
                    Name = "Keybind",
                    Flag = "keybind2",
                    Default = Enum.KeyCode.F,
                    Mode = "Toggle",
                    Callback = function(value)
                        print(value)
                    end
                })

                RightSection:Label({Name = "third keybind"}):Keybind({
                    Name = "Keybind",
                    Flag = "keybind3",
                    Default = Enum.KeyCode.R,
                    Mode = "Toggle",
                    Callback = function(value)
                        print(value)
                    end
                })

                RightSection:Textbox({
                    Name = "Textbox",
                    Flag = "textbox",
                    Default = "default",
                    Placeholder = "placeholder",
                    Numeric = false,
                    Finished = false,
                    Callback = function(value)
                        print(value)
                    end
                })
            end
        end

        do
            local ESPSection = VisualsPage:Section({Name = "ESP", Side = 1})
            local ESPSettings = VisualsPage:Section({Name = "ESP Settings", Side = 2})

            do
                ESPSection:Toggle({
                    Name = "Enabled",
                    Flag = "ESPEnabled",
                    Default = false,
                    Callback = function(v)
                        ESP.Enabled = v
                    end
                })

                ESPSection:Toggle({
                    Name = "Box",
                    Flag = "ESPBox",
                    Default = true,
                    Callback = function(v)
                        ESP.Box = v
                    end
                }):Colorpicker({
                    Name = "Box Color",
                    Flag = "ESPBoxColor",
                    Default = Color3.fromRGB(255, 255, 255),
                    Callback = function(color, alpha)
                        ESP.BoxColor = color
                    end
                })

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
                    Default = Color3.fromRGB(255, 255, 255),
                    Callback = function(color, alpha)
                        ESP.TracerColor = color
                    end
                })

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

                ESPSection:Toggle({
                    Name = "Health Bar",
                    Flag = "ESPHealthBar",
                    Default = true,
                    Callback = function(v)
                        ESP.HealthBar = v
                    end
                })

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
                    Default = Color3.fromRGB(255, 255, 255),
                    Callback = function(color, alpha)
                        ESP.DistanceColor = color
                    end
                })
            end

            do
                ESPSettings:Toggle({
                    Name = "Team Check",
                    Flag = "ESPTeamCheck",
                    Default = true,
                    Callback = function(v)
                        ESP.TeamCheck = v
                    end
                })

                ESPSettings:Slider({
                    Name = "Max Distance",
                    Flag = "ESPMaxDistance",
                    Min = 100,
                    Max = 5000,
                    Default = 2000,
                    Decimals = 0,
                    Suffix = "m",
                    Callback = function(value)
                        ESP.MaxDistance = value
                    end
                })

                ESPSettings:Dropdown({
                    Name = "Tracer Origin",
                    Flag = "ESPTracerOrigin",
                    Items = {"Bottom", "Center", "Mouse"},
                    Default = "Bottom",
                    Multi = false,
                    Callback = function(value)
                        ESP.TracerOrigin = value
                    end
                })
            end
        end
    end

    do
        ESP:Start()
    end

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
