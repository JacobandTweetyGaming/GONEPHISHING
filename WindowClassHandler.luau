--TOP-LEVEL Window Class Module

local RS = game:GetService("ReplicatedStorage")
local WindowModule = {
	UIAssets = RS:FindFirstChild("Assets"):FindFirstChild("UI"),
}

type Window = {
	Name: string,
	Instance: Frame | Instance,
	Settings: ModuleScript?
}

function WindowModule.new(Reference: Instance | string, Stats: {Name: string?, Size: UDim2?, Position: UDim2?}?): Window
	if typeof(Reference) == "string" then
		Reference = WindowModule.UIAssets.WindowBases:WaitForChild(Reference)
	end
	if typeof(Reference) ~= "Instance" then
		return
	end
	Reference = Reference:Clone()
	local Window: Window = {
		Name = Stats and Stats.Name or Reference.Name,
		Instance = Reference,
		Settings = Reference:FindFirstChild("Settings")
	}
	if Stats and Window.Instance:IsA("Frame") then
		if Stats.Name and Window.Settings ~= nil then
			local SettingsProcessed = require(Window.Settings)
			SettingsProcessed.Title = Stats.Name
		end
		if Stats.Size then
			Window.Instance.Size = Stats.Size
		end
		if Stats.Position then
			Window.Instance.Position = Stats.Position
		end
	end
	if Window.Settings ~= nil then
		require(Window.Settings).UpdateWindow()
	end
	return Window
end

return WindowModule
