local UI = {}

-- SERVICES
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")

local lp = Players.LocalPlayer
local pg = lp:WaitForChild("PlayerGui")

local sahurImage = "rbxassetid://139818999438291"

------------------------------------------------
-- WINDOW + TAB SYSTEM
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

	local screen = Instance.new("ScreenGui")
	screen.Name = "TungUI"
	screen.ResetOnSpawn = false
	screen.Parent = pg

	local main = Instance.new("Frame")
	main.AnchorPoint = Vector2.new(0.5, 0.5)
	main.Size = UDim2.fromScale(0.65, 0.65)
	main.Position = UDim2.fromScale(0.5, 0.5)
	main.BackgroundColor3 = Color3.fromRGB(20,20,20)
	main.Parent = screen

	local aspect = Instance.new("UIAspectRatioConstraint")
	aspect.AspectRatio = 520/350
	aspect.Parent = main

	local uiScale = Instance.new("UIScale")
	uiScale.Parent = main

	local camera = workspace.CurrentCamera

	local function updateScale()
		local v = camera.ViewportSize
		local scale = math.clamp(math.min(v.X/1920, v.Y/1080), 0.6, 1.3)
		uiScale.Scale = scale
	end

	updateScale()
	camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)

	-- TOP BAR
	local top = Instance.new("Frame")
	top.Size = UDim2.new(1,0,0.1,0)
	top.BackgroundColor3 = Color3.fromRGB(30,30,30)
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

	-- TAB LIST + CONTENT
	local tabList = Instance.new("Frame")
	tabList.Size = UDim2.new(0.25,0,0.9,0)
	tabList.Position = UDim2.new(0,0,0.1,0)
	tabList.Parent = main

	local content = Instance.new("Frame")
	content.Size = UDim2.new(0.75,0,0.9,0)
	content.Position = UDim2.new(0.25,0,0.1,0)
	content.Parent = main

	-- OPEN BUTTON
	local openBtn = Instance.new("ImageButton")
	openBtn.Size = UDim2.fromScale(0.07,0.12)
	openBtn.Position = UDim2.fromScale(0.02,0.45)
	openBtn.Image = sahurImage
	openBtn.Visible = false
	openBtn.Parent = screen

	------------------------------------------------
	local self = setmetatable({}, Window)

	self.Gui = screen
	self.Main = main
	self.Content = content
	self.TabList = tabList
	self.OpenBtn = openBtn
	self.Tabs = {}
	self.TabByName = {}

	------------------------------------------------
	-- CLOSE / OPEN
	close.MouseButton1Click:Connect(function()
		main.Visible = false
		openBtn.Visible = true
	end)

	openBtn.MouseButton1Click:Connect(function()
		main.Visible = true
		openBtn.Visible = false
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
	btn.Size = UDim2.new(1,0,0,35)
	btn.Text = name
	btn.Parent = self.TabList

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
	end

	btn.MouseButton1Click:Connect(function()
		selfTab:Show()
	end)

	table.insert(self.Tabs, selfTab)

	if #self.Tabs == 1 then
		page.Visible = true
	end

	return selfTab
end

------------------------------------------------
-- GAME CHECKER (ONLY GAME TAB USE)
------------------------------------------------
function Tab:CreateGameChecker(placeId, callback)

	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1,-10,0,35)
	b.Text = "GameChecker: "..placeId
	b.Parent = self.Page

	b.MouseButton1Click:Connect(function()
		if game.PlaceId == placeId then
			callback(true)
		else
			callback(false)
		end
	end)
end

------------------------------------------------
-- BUTTON
------------------------------------------------
function Tab:CB(text, callback)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1,-10,0,35)
	b.Text = text
	b.Parent = self.Page
	b.MouseButton1Click:Connect(callback)
end

------------------------------------------------
-- TOGGLE
------------------------------------------------
function Tab:CT(text, default, callback)
	local state = default or false

	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1,-10,0,35)
	b.Text = text..": "..tostring(state)
	b.Parent = self.Page

	b.MouseButton1Click:Connect(function()
		state = not state
		b.Text = text..": "..tostring(state)
		callback(state)
	end)
end

------------------------------------------------
-- SLIDER (CLICK BASED)
------------------------------------------------
function Tab:CS(text, min, max, default, callback)
	local value = default or min

	local f = Instance.new("Frame")
	f.Size = UDim2.new(1,-10,0,50)
	f.Parent = self.Page

	local l = Instance.new("TextLabel")
	l.Size = UDim2.new(1,0,0,25)
	l.Text = text..": "..value
	l.Parent = f

	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1,0,0,25)
	b.Position = UDim2.new(0,0,0,25)
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
	b.Size = UDim2.new(1,-10,0,35)
	b.Text = text..": "..list[i]
	b.Parent = self.Page

	b.MouseButton1Click:Connect(function()
		i += 1
		if i > #list then i = 1 end
		b.Text = text..": "..list[i]
		callback(list[i])
	end)
end

------------------------------------------------
-- GAME TELEPORT
------------------------------------------------
function Tab:CreateGameTeleport(name, placeId)

	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1,-10,0,35)
	b.Text = "Teleport: "..name
	b.Parent = self.Page

	b.MouseButton1Click:Connect(function()
		TeleportService:Teleport(placeId, lp)
	end)
end

return UI
