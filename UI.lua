local UI = {}

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")

local lp = Players.LocalPlayer
local pg = lp:WaitForChild("PlayerGui")

local SAHUR = "rbxassetid://139818999438291"

------------------------------------------------
-- STYLE HELPERS
------------------------------------------------
local function Corner(obj, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r or 10)
	c.Parent = obj
end

local function Stroke(obj)
	local s = Instance.new("UIStroke")
	s.Thickness = 1
	s.Transparency = 0.6
	s.Color = Color3.fromRGB(255,255,255)
	s.Parent = obj
end

------------------------------------------------
-- WINDOW / TAB
------------------------------------------------
local Window = {}
Window.__index = Window

local Tab = {}
Tab.__index = Tab

local DEFAULT_TABS = {
	"🏠Home",
	"🎮Game",
	"🎮🎮Games",
	"⚙️Settings",
	"👾Universal Cheats",
	"🏆Credits"
}

------------------------------------------------
-- CREATE WINDOW
------------------------------------------------
function UI:CreateWindow()

	local gui = Instance.new("ScreenGui")
	gui.Name = "TungUI"
	gui.ResetOnSpawn = false
	gui.Parent = pg

	local main = Instance.new("Frame")
	main.AnchorPoint = Vector2.new(0.5, 0.5)
	main.Position = UDim2.fromScale(0.5, 0.5)
	main.Size = UDim2.fromScale(0.62, 0.62)
	main.BackgroundColor3 = Color3.fromRGB(15,15,18)
	main.Parent = gui

	Corner(main, 12)
	Stroke(main)

	local scale = Instance.new("UIScale")
	scale.Parent = main

	local cam = workspace.CurrentCamera

	local function update()
		local v = cam.ViewportSize
		scale.Scale = math.clamp(math.min(v.X/1920, v.Y/1080), 0.65, 1.2)
	end

	update()
	cam:GetPropertyChangedSignal("ViewportSize"):Connect(update)

	------------------------------------------------
	-- TOP
	------------------------------------------------
	local top = Instance.new("Frame")
	top.Size = UDim2.new(1,0,0,45)
	top.BackgroundColor3 = Color3.fromRGB(22,22,28)
	top.Parent = main

	Corner(top, 12)

	local icon = Instance.new("ImageLabel")
	icon.Size = UDim2.new(0,40,0,40)
	icon.Position = UDim2.new(0,5,0,2)
	icon.BackgroundTransparency = 1
	icon.Image = SAHUR
	icon.Parent = top

	local close = Instance.new("TextButton")
	close.Size = UDim2.new(0,40,0,40)
	close.Position = UDim2.new(1,-45,0,2)
	close.Text = "X"
	close.TextColor3 = Color3.fromRGB(255,255,255)
	close.BackgroundColor3 = Color3.fromRGB(40,40,50)
	close.Parent = top

	Corner(close, 8)

	------------------------------------------------
	-- SIDEBAR
	------------------------------------------------
	local tabList = Instance.new("Frame")
	tabList.Size = UDim2.new(0,170,1,-45)
	tabList.Position = UDim2.new(0,0,0,45)
	tabList.BackgroundColor3 = Color3.fromRGB(18,18,22)
	tabList.Parent = main

	Corner(tabList, 12)

	------------------------------------------------
	-- CONTENT
	------------------------------------------------
	local content = Instance.new("Frame")
	content.Size = UDim2.new(1,-170,1,-45)
	content.Position = UDim2.new(0,170,0,45)
	content.BackgroundColor3 = Color3.fromRGB(14,14,18)
	content.Parent = main

	Corner(content, 12)

	------------------------------------------------
	-- OPEN BUTTON
	------------------------------------------------
	local open = Instance.new("ImageButton")
	open.Size = UDim2.fromScale(0.07,0.12)
	open.Position = UDim2.fromScale(0.02,0.45)
	open.Image = SAHUR
	open.Visible = false
	open.Parent = gui

	------------------------------------------------
	local self = setmetatable({}, Window)

	self.Gui = gui
	self.Main = main
	self.Content = content
	self.TabList = tabList
	self.OpenBtn = open

	self.Tabs = {}
	self.TabByName = {}

	------------------------------------------------
	-- CLOSE / OPEN
	close.MouseButton1Click:Connect(function()
		main.Visible = false
		open.Visible = true
	end)

	open.MouseButton1Click:Connect(function()
		main.Visible = true
		open.Visible = false
	end)

	------------------------------------------------
	-- CREATE DEFAULT TABS
	for _, name in ipairs(DEFAULT_TABS) do
		local tab = self:CreateTab(name)
		self.TabByName[name] = tab
	end

	return self, self.TabByName
end

------------------------------------------------
-- CREATE TAB
------------------------------------------------
function Window:CreateTab(name)

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1,0,0,38)
	btn.Text = name
	btn.BackgroundColor3 = Color3.fromRGB(25,25,32)
	btn.TextColor3 = Color3.fromRGB(200,200,200)
	btn.Font = Enum.Font.GothamMedium
	btn.TextSize = 14
	btn.Parent = self.TabList

	Corner(btn, 8)

	local page = Instance.new("ScrollingFrame")
	page.Size = UDim2.new(1,0,1,0)
	page.BackgroundTransparency = 1
	page.Visible = false
	page.Parent = self.Content

	local layout = Instance.new("UIListLayout")
	layout.Parent = page

	local selfTab = setmetatable({}, Tab)
	selfTab.Page = page
	selfTab.Window = self

	function selfTab:Show()
		for _,t in pairs(self.Window.Tabs) do
			t.Page.Visible = false
		end
		page.Visible = true

		-- highlight reset
		for _,b in pairs(self.Window.TabList:GetChildren()) do
			if b:IsA("TextButton") then
				b.BackgroundColor3 = Color3.fromRGB(25,25,32)
				b.TextColor3 = Color3.fromRGB(200,200,200)
			end
		end

		btn.BackgroundColor3 = Color3.fromRGB(120,80,255)
		btn.TextColor3 = Color3.fromRGB(255,255,255)
	end

	btn.MouseButton1Click:Connect(function()
		selfTab:Show()
	end)

	table.insert(self.Tabs, selfTab)

	if #self.Tabs == 1 then
		selfTab:Show()
	end

	return selfTab
end

------------------------------------------------
-- GAME CHECKER
------------------------------------------------
function Tab:CreateGameChecker(placeId, callback)

	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1,0,0,38)
	b.Text = "GameChecker: "..placeId
	b.BackgroundColor3 = Color3.fromRGB(25,25,32)
	b.TextColor3 = Color3.fromRGB(255,255,255)
	b.Parent = self.Page

	Corner(b, 8)

	b.MouseButton1Click:Connect(function()
		callback(game.PlaceId == placeId)
	end)
end

------------------------------------------------
-- BUTTON
------------------------------------------------
function Tab:CB(text, callback)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1,0,0,38)
	b.Text = text
	b.BackgroundColor3 = Color3.fromRGB(25,25,32)
	b.TextColor3 = Color3.fromRGB(220,220,220)
	b.Parent = self.Page

	Corner(b, 8)

	b.MouseButton1Click:Connect(callback)
end

------------------------------------------------
-- TOGGLE
------------------------------------------------
function Tab:CT(text, default, callback)
	local state = default

	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1,0,0,38)
	b.Text = text..": "..tostring(state)
	b.BackgroundColor3 = Color3.fromRGB(25,25,32)
	b.TextColor3 = Color3.fromRGB(220,220,220)
	b.Parent = self.Page

	Corner(b, 8)

	b.MouseButton1Click:Connect(function()
		state = not state
		b.Text = text..": "..tostring(state)
		callback(state)
	end)
end

------------------------------------------------
-- SLIDER (simple)
------------------------------------------------
function Tab:CS(text, min, max, default, callback)
	local value = default

	local f = Instance.new("Frame")
	f.Size = UDim2.new(1,0,0,60)
	f.BackgroundColor3 = Color3.fromRGB(25,25,32)
	f.Parent = self.Page

	Corner(f, 8)

	local l = Instance.new("TextLabel")
	l.Size = UDim2.new(1,0,0,30)
	l.BackgroundTransparency = 1
	l.Text = text..": "..value
	l.TextColor3 = Color3.fromRGB(255,255,255)
	l.Parent = f

	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1,0,0,30)
	b.Position = UDim2.new(0,0,0,30)
	b.Text = "Change"
	b.Parent = f

	b.MouseButton1Click:Connect(function()
		value += 1
		if value > max then value = min end
		l.Text = text..": "..value
		callback(value)
	end)
end

------------------------------------------------
-- DROPDOWN
------------------------------------------------
function Tab:CDD(text, list, callback)
	local i = 1

	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1,0,0,38)
	b.Text = text..": "..list[i]
	b.BackgroundColor3 = Color3.fromRGB(25,25,32)
	b.Parent = self.Page

	Corner(b, 8)

	b.MouseButton1Click:Connect(function()
		i += 1
		if i > #list then i = 1 end
		b.Text = text..": "..list[i]
		callback(list[i])
	end)
end

------------------------------------------------
-- TELEPORT
------------------------------------------------
function Tab:CreateGameTeleport(name, placeId)

	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1,0,0,38)
	b.Text = "Teleport: "..name
	b.BackgroundColor3 = Color3.fromRGB(25,25,32)
	b.TextColor3 = Color3.fromRGB(255,255,255)
	b.Parent = self.Page

	Corner(b, 8)

	b.MouseButton1Click:Connect(function()
		TeleportService:Teleport(placeId, lp)
	end)
end

return UI
