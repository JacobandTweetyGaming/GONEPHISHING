--ScrollingWindowTemplate.Settings.luau
local HardReferences = {}
HardReferences.Window = script.Parent
HardReferences.Content = HardReferences.Window:FindFirstChild("Content")
HardReferences.ContentFrame = HardReferences.Content:FindFirstChild("ScrollingFrame")

local WindowSettings = {
	Title = "Scroll_Template_new",
	MaxLines = 3,
}

type Option = {
	Text: string,
	RunOnClick: () -> (),
	Remove: () -> (),
	Instance: Instance
}

function WindowSettings.CreateOption(Text: string, RunOnClick: () -> ()): Option
	local Template = HardReferences.ContentFrame:FindFirstChild("OptionTemplate")
	if Template then
		local NewOption = Template:Clone()
		NewOption.Text = Text
		NewOption.Visible = true
		NewOption.MouseButton1Click:Connect(RunOnClick)
		NewOption.Parent = HardReferences.ContentFrame
		local FinalOption: Option = {
			Text = Text,
			RunOnClick = RunOnClick,
			Remove = function(self: Option)
				self.Text = nil
				self.RunOnClick = nil
				self.Remove = function()
					warn("This option has already been removed.")
				end
				self.Instance = nil
				NewOption:Destroy()
			end,
			Instance = NewOption
		}
		return FinalOption
	end
end

function WindowSettings.UpdateWindow()
	local Window = HardReferences.Window
	local Scroller = HardReferences.ContentFrame
	
	Window.TitleBar.Title.Text = WindowSettings.Title
	
	local OptionSize = UDim2.fromScale(
		1,
		1 / (Scroller.CanvasSize.Y.Scale * WindowSettings.MaxLines)
	)
	Scroller.OptionTemplate.Size = OptionSize
	
	for i, Frame: Frame? in Scroller:GetChildren() do
		if Frame:IsA("Frame") or Frame:IsA("TextButton") then
			Frame.Size = OptionSize
		end
	end
end

return WindowSettings
