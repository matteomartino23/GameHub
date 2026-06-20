local UI = {}

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")

local lp = Players.LocalPlayer
local pg = lp:WaitForChild("PlayerGui")

-- CONFIG
local THEME = {
    BG = Color3.fromRGB(20,20,20),
    TOP = Color3.fromRGB(30,30,30),
    ACCENT = Color3.fromRGB(255,255,255),
}

local sahurImage = "rbxassetid://139818999438291"

-- WINDOW OBJECT
local Window = {}
Window.__index = Window

-- TAB OBJECT
local Tab = {}
Tab.__index = Tab

-- CREATE WINDOW
function UI:CreateWindow(config)
    config = config or {}

    local screen = Instance.new("ScreenGui")
    screen.Name = "TungUI"
    screen.ResetOnSpawn = false
    screen.Parent = pg

    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 520, 0, 350)
    main.Position = UDim2.new(0.5, -260, 0.5, -175)
    main.BackgroundColor3 = THEME.BG
    main.Parent = screen

    local top = Instance.new("Frame")
    top.Size = UDim2.new(1,0,0,40)
    top.BackgroundColor3 = THEME.TOP
    top.Parent = main

    local img = Instance.new("ImageLabel")
    img.Size = UDim2.new(0,40,0,40)
    img.BackgroundTransparency = 1
    img.Image = sahurImage
    img.Parent = top

    local close = Instance.new("TextButton")
    close.Size = UDim2.new(0,40,0,40)
    close.Position = UDim2.new(1,-40,0,0)
    close.Text = "X"
    close.Parent = top

    local tabList = Instance.new("Frame")
    tabList.Size = UDim2.new(0,140,1,-40)
    tabList.Position = UDim2.new(0,0,0,40)
    tabList.Parent = main

    local content = Instance.new("Frame")
    content.Size = UDim2.new(1,-140,1,-40)
    content.Position = UDim2.new(0,140,0,40)
    content.Parent = main

    local openBtn = Instance.new("ImageButton")
    openBtn.Size = UDim2.new(0,60,0,60)
    openBtn.Position = UDim2.new(0,20,0.5,-30)
    openBtn.Image = sahurImage
    openBtn.Visible = false
    openBtn.Parent = screen

    local self = setmetatable({}, Window)
    self.Gui = screen
    self.Main = main
    self.Content = content
    self.TabList = tabList
    self.OpenBtn = openBtn
    self.Tabs = {}

    -- drag
    local dragging = false
    local dragStart, startPos

    top.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = i.Position
            startPos = main.Position
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = i.Position - dragStart
            main.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    game:GetService("UserInputService").InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    close.MouseButton1Click:Connect(function()
        main.Visible = false
        openBtn.Visible = true
    end)

    openBtn.MouseButton1Click:Connect(function()
        main.Visible = true
        openBtn.Visible = false
    end)

    return self
end

-- CREATE TAB
function Window:CreateTab(name)
    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(1,0,0,35)
    tabBtn.Text = name
    tabBtn.Parent = self.TabList

    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1,0,1,0)
    page.Visible = false
    page.Parent = self.Content

    local layout = Instance.new("UIListLayout")
    layout.Parent = page

    local selfTab = setmetatable({}, Tab)
    selfTab.Page = page

    function selfTab:Show()
        for _,t in pairs(self.Tabs or {}) do
            t.Page.Visible = false
        end
        page.Visible = true
    end

    tabBtn.MouseButton1Click:Connect(function()
        selfTab:Show()
    end)

    -- DEFAULT FIRST TAB
    if #self.Tabs == 0 then
        page.Visible = true
    end

    table.insert(self.Tabs, selfTab)

    return selfTab
end

-- BUTTON
function Tab:CB(text, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1,-10,0,35)
    b.Text = text
    b.Parent = self.Page

    b.MouseButton1Click:Connect(callback)
end

-- TOGGLE
function Tab:CT(text, default, callback)
    local state = default or false

    local t = Instance.new("TextButton")
    t.Size = UDim2.new(1,-10,0,35)
    t.Text = text .. ": " .. tostring(state)
    t.Parent = self.Page

    t.MouseButton1Click:Connect(function()
        state = not state
        t.Text = text .. ": " .. tostring(state)
        callback(state)
    end)
end

-- SLIDER (semplice)
function Tab:CS(text, min, max, default, callback)
    local value = default or min

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1,-10,0,50)
    frame.Parent = self.Page

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,0,0,20)
    label.Text = text .. " : " .. value
    label.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,0,0,30)
    btn.Position = UDim2.new(0,0,0,20)
    btn.Text = "Click to increase"
    btn.Parent = frame

    btn.MouseButton1Click:Connect(function()
        value += 1
        if value > max then value = min end
        label.Text = text .. " : " .. value
        callback(value)
    end)
end

-- DROPDOWN (semplice cycle)
function Tab:CDD(text, list, callback)
    local index = 1

    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1,-10,0,35)
    b.Text = text .. ": " .. list[index]
    b.Parent = self.Page

    b.MouseButton1Click:Connect(function()
        index += 1
        if index > #list then index = 1 end
        b.Text = text .. ": " .. list[index]
        callback(list[index])
    end)
end

-- GAME TELEPORT
function Tab:CreateGameTeleport(name, placeId)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1,-10,0,35)
    b.Text = "Teleport: " .. name
    b.Parent = self.Page

    b.MouseButton1Click:Connect(function()
        TeleportService:Teleport(placeId, lp)
    end)
end

-- ALIAS API
Tab.CB = Tab.CB
Tab.CT = Tab.CT
Tab.CS = Tab.CS
Tab.CDD = Tab.CDD

return UI
