local Library = {}
Library.__index = Library

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- Global Theme Definition Configuration Registry
Library.Theme = {
	Background = Color3.fromRGB(12, 12, 12),
	TitleBarBg = Color3.fromRGB(16, 16, 16),
	SidebarBg = Color3.fromRGB(14, 14, 14),
	AccentColor = Color3.fromRGB(65, 105, 225), -- Primary dynamic color layer
	MainOutline = Color3.fromRGB(35, 75, 200), -- Main exterior highlight box border
	InnerOutline = Color3.fromRGB(255, 255, 255), -- Global standard components line border
	TextPrimary = Color3.fromRGB(255, 255, 255),
	TextSecondary = Color3.fromRGB(160, 160, 160),
	ElementBg = Color3.fromRGB(20, 20, 20),
}

-- Registry array to dynamically hold global elements for theme shifting
local ActiveInstances = {}

local function RegisterElement(instance, propertyName, themeKey)
	table.insert(ActiveInstances, {
		Obj = instance,
		Prop = propertyName,
		Key = themeKey
	})
	instance[propertyName] = Library.Theme[themeKey]
end

-- Helper function to enable dragging on the UI smoothly
local function MakeDraggable(dragHandle, dragTarget)
	local dragging, dragInput, dragStart, startPos
	
	dragHandle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = dragTarget.Position
			
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	
	dragHandle.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)
	
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			dragTarget.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
end

function Library:SetTheme(themeKey, colorValue)
	if Library.Theme[themeKey] then
		Library.Theme[themeKey] = colorValue
		for _, registry in pairs(ActiveInstances) do
			if registry.Obj and registry.Obj.Parent then
				if registry.Key == themeKey then
					registry.Obj[registry.Prop] = colorValue
				end
			end
		end
	end
end

function Library.CreateWindow(titleText, defaultToggleKey)
	local self = setmetatable({}, Library)
	
	self.ToggleKey = defaultToggleKey or Enum.KeyCode.RightShift
	self.UiVisible = true
	
	-- Determine target parent directory for execution context safely
	local targetParent
	if syn and syn.protect_gui then
		targetParent = CoreGui
	elseif gethui then
		targetParent = gethui()
	else
		targetParent = CoreGui
	end

	-- Clean up old existing instances of the same UI library
	if targetParent then
		local oldGui = targetParent:FindFirstChild("CustomUiLibrary_Refined")
		if oldGui then
			oldGui:Destroy()
		end
	end
	
	-- Main ScreenGui Container
	self.ScreenGui = Instance.new("ScreenGui")
	self.ScreenGui.Name = "CustomUiLibrary_Refined"
	self.ScreenGui.ResetOnSpawn = false
	self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	
	if syn and syn.protect_gui then
		syn.protect_gui(self.ScreenGui)
		self.ScreenGui.Parent = CoreGui
	else
		self.ScreenGui.Parent = targetParent
	end
	
	-- Main Frame
	self.MainFrame = Instance.new("Frame")
	self.MainFrame.Name = "MainFrame"
	self.MainFrame.Size = UDim2.new(0, 660, 0, 460)
	self.MainFrame.Position = UDim2.new(0.5, -330, 0.5, -230)
	self.MainFrame.BorderSizePixel = 1
	RegisterElement(self.MainFrame, "BackgroundColor3", "Background")
	RegisterElement(self.MainFrame, "BorderColor3", "MainOutline")
	self.MainFrame.Parent = self.ScreenGui
	
	-- Global Toggle Key Handler Configuration
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if not gameProcessed and input.KeyCode == self.ToggleKey then
			self.UiVisible = not self.UiVisible
			self.MainFrame.Visible = self.UiVisible
		end
	end)
	
	-- Top Title Bar
	self.TitleBar = Instance.new("Frame")
	self.TitleBar.Name = "TitleBar"
	self.TitleBar.Size = UDim2.new(1, 0, 0, 32)
	self.TitleBar.BorderSizePixel = 1
	RegisterElement(self.TitleBar, "BackgroundColor3", "TitleBarBg")
	RegisterElement(self.TitleBar, "BorderColor3", "InnerOutline")
	self.TitleBar.Parent = self.MainFrame
	
	MakeDraggable(self.TitleBar, self.MainFrame)
	
	self.TitleLabel = Instance.new("TextLabel")
	self.TitleLabel.Name = "TitleLabel"
	self.TitleLabel.Size = UDim2.new(1, -15, 1, 0)
	self.TitleLabel.Position = UDim2.new(0, 12, 0, 0)
	self.TitleLabel.BackgroundTransparency = 1
	self.TitleLabel.Text = titleText or "UI Window"
	self.TitleLabel.TextSize = 14
	self.TitleLabel.Font = Enum.Font.SourceSansBold
	self.TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	RegisterElement(self.TitleLabel, "TextColor3", "TextPrimary")
	self.TitleLabel.Parent = self.TitleBar
	
	-- Left Sidebar for Main Tabs
	self.Sidebar = Instance.new("Frame")
	self.Sidebar.Name = "Sidebar"
	self.Sidebar.Size = UDim2.new(0, 70, 1, -32)
	self.Sidebar.Position = UDim2.new(0, 0, 0, 32)
	self.Sidebar.BorderSizePixel = 1
	RegisterElement(self.Sidebar, "BackgroundColor3", "SidebarBg")
	RegisterElement(self.Sidebar, "BorderColor3", "InnerOutline")
	self.Sidebar.Parent = self.MainFrame
	
	self.SidebarLayout = Instance.new("UIListLayout")
	self.SidebarLayout.Padding = UDim.new(0, 12)
	self.SidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	self.SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
	self.SidebarLayout.Parent = self.Sidebar
	
	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 16)
	padding.Parent = self.Sidebar
	
	-- Container for pages
	self.PageContainer = Instance.new("Frame")
	self.PageContainer.Name = "PageContainer"
	self.PageContainer.Size = UDim2.new(1, -70, 1, -32)
	self.PageContainer.Position = UDim2.new(0, 70, 0, 32)
	self.PageContainer.BackgroundTransparency = 1
	self.PageContainer.Parent = self.MainFrame
	
	self.Tabs = {}
	self.FirstTab = nil
	
	return self
end

function Library:CreateTab(iconId)
	local tab = {}
	tab.SubTabs = {}
	tab.FirstSubTab = nil
	tab.ActiveSubTab = nil
	
	-- Sidebar Icon Button
	tab.Button = Instance.new("ImageButton")
	tab.Button.Name = "TabButton"
	tab.Button.Size = UDim2.new(0, 38, 0, 38)
	tab.Button.BackgroundTransparency = 1
	tab.Button.Image = iconId or "rbxassetid://6031225818"
	tab.Button.ImageColor3 = Library.Theme.TextSecondary
	tab.Button.Parent = self.Sidebar
	
	-- Main Page Frame for this Tab
	tab.PageFrame = Instance.new("Frame")
	tab.PageFrame.Name = "TabFrame"
	tab.PageFrame.Size = UDim2.new(1, 0, 1, 0)
	tab.PageFrame.BackgroundTransparency = 1
	tab.PageFrame.Visible = false
	tab.PageFrame.Parent = self.PageContainer
	
	-- Top Ribbon Bar for Sub-Tabs
	tab.TopRibbon = Instance.new("Frame")
	tab.TopRibbon.Name = "TopRibbon"
	tab.TopRibbon.Size = UDim2.new(1, -12, 0, 28)
	tab.TopRibbon.Position = UDim2.new(0, 6, 0, 6)
	tab.TopRibbon.BorderSizePixel = 1
	RegisterElement(tab.TopRibbon, "BackgroundColor3", "TitleBarBg")
	RegisterElement(tab.TopRibbon, "BorderColor3", "InnerOutline")
	tab.TopRibbon.Parent = tab.PageFrame
	
	tab.RibbonLayout = Instance.new("UIListLayout")
	tab.RibbonLayout.FillDirection = Enum.FillDirection.Horizontal
	tab.RibbonLayout.SortOrder = Enum.SortOrder.LayoutOrder
	tab.RibbonLayout.Parent = tab.TopRibbon
	
	-- Subpage holder frame
	tab.SubPageContainer = Instance.new("Frame")
	tab.SubPageContainer.Name = "SubPageContainer"
	tab.SubPageContainer.Size = UDim2.new(1, -12, 1, -46)
	tab.SubPageContainer.Position = UDim2.new(0, 6, 0, 40)
	tab.SubPageContainer.BackgroundTransparency = 1
	tab.
