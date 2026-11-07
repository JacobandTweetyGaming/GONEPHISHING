local Counts = {
	Target = 0,
	Total = 0,
	Correct = {},
	Incorrect = {},
}

local RandomGenerator = Random.new()

print("Loaded")

local AmountOfEmails = NumberRange.new(15, 26)
Counts.Target = math.random(AmountOfEmails.Min, AmountOfEmails.Max)

local plrs = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Assets = RS.Assets
local Modules = RS.Modules
local plr = plrs.LocalPlayer

local Main = script.Parent

local WindowModule = require(Modules.WindowModule)
local EmailList = require(script.EmailList)

local function ShuffleTable(Table: {any})
	--[[
	for i = #Table, 2, -1 do
		local RandomIndex = RandomGenerator:NextInteger(1, i)
		Table[i], Table[RandomIndex] = Table[RandomIndex], Table[i]
	end
	return Table
	]]
	RandomGenerator:Shuffle(Table)
end

local function FormatText(Text: string): string
	return string.gsub(Text, "%[(.-)%]", '<font color="#3498DB">%1</font>')
end

local ReadMe = WindowModule.new(Assets:FindFirstChild("UI").WindowBases.CloseableTemplate, {
	Name = "README.md", 
	Size = UDim2.fromScale(0.335*1.75, 0.433*1.75)
})

local ReadMeBody = Assets.UI.BodyText:Clone()
ReadMeBody.Parent = ReadMe.Instance
ReadMeBody.Text = [[
"With the advent of A.I. has come a new wave of phishing attacks. 
It is your job to distinguish the harmless emails from the malicious." 
-Northstar Dynamics IT Department
]]

ReadMe.Instance.Parent = Main

--Setup Mail Window
local MailWindow = WindowModule.new(Assets:FindFirstChild("UI").WindowBases.ScrollTemplate, {
	Name = "Quarantined Mail",
	Size = UDim2.fromScale(0.9, 0.568)
})

local MailSettings = require(MailWindow.Settings)
--MailWindow.Instance.Parent = Main

MailSettings.MaxOptions = 6
MailSettings.UpdateWindow()

local DesktopShortcuts = {
	["POOGI.png"] = {
		Icon = "rbxassetid://102295396044000",
		OnClick = function()
			--Setup Pug Window
			local PugWindow = WindowModule.new(Assets:FindFirstChild("UI").WindowBases.StandardTemplate, {
				Name = "POOGI.png",
				Size = UDim2.fromScale(0.297, 0.433)
			})
			local PugSettings = require(PugWindow.Settings)
			PugWindow.Instance.Parent = Main
			local SparePugImage = Assets.UI.PugImage:Clone()
			SparePugImage.Parent = PugWindow.Instance
		end,
	},
	["Mail.exe"] = {
		Icon = "rbxassetid://121903289332667",
		OnClick = function()
			MailWindow.Instance.Parent = (MailWindow.Instance.Parent ~= Main) and Main or nil
		end,
	},
}

local function SetupShortcuts()
	for i, Shortcut in DesktopShortcuts do
		local Template = Main.Background.ShortcutTemplate:Clone()
		Template.Image = Shortcut.Icon
		Template.Title.Text = i
		Template.Parent = Main.Background
		Template.Visible = true
		Template.MouseButton1Click:Connect(function()
			Shortcut.OnClick()
		end)
	end
end

SetupShortcuts()

task.wait(2)
local IterationCount = 0
ShuffleTable(EmailList)
for Title, Metadata: {Content: string, Safe: boolean?, Sender: string?, Reason: string?} in EmailList do
	if math.random(0, 100) <= 50 then continue end
	IterationCount += 1
	if (not Metadata) or (not Metadata.Content) then warn("generational save, iter.", IterationCount) continue end
	--print("Meta:", Metadata, Metadata.Content)
	local Text = string.gsub(Metadata.Content, "{user}", plr.DisplayName)
	local Option = nil
	Option = MailSettings.CreateOption(Title, function()
		--Setup Window
		local MessageWindow = WindowModule.new(Assets:FindFirstChild("UI").WindowBases.EmailTemplate, {
			Name = Title.. " - Reading",
			Size = UDim2.fromScale(0.335*1.75, 0.433*1.75)
		})
		local WindowSettings = require(MessageWindow.Settings)
		WindowSettings.Sender = Metadata.Sender or "<unknown@unknown>"
		local function DestroyMsgWindow()
			MessageWindow.Instance:Destroy()
			MessageWindow = nil
			Option:Remove()
		end
		WindowSettings.YesFunction = function()
			Counts.Total += 1
			if Metadata.Safe then
				Counts.Correct[Title] = Metadata.Reason
			else
				Counts.Incorrect[Title] = Metadata.Reason
			end
			DestroyMsgWindow()
		end
		WindowSettings.NoFunction = function()
			Counts.Total += 1
			if Metadata.Safe ~= true then
				Counts.Correct[Title] = Metadata.Reason
			else
				Counts.Incorrect[Title] = Metadata.Reason
			end
			DestroyMsgWindow()
		end
		local BodyText = Assets.UI.BodyText:Clone()
		BodyText.RichText = true
		BodyText.Text = FormatText(Text)
		BodyText.Parent = MessageWindow.Instance
		MessageWindow.Instance.Parent = Main
		WindowSettings.UpdateWindow()
		WindowSettings.PressBind()
	end)
	if IterationCount > Counts.Target then break end
end

repeat task.wait() until Counts.Total > Counts.Target

local CorrectCount = 0
local IncorrectCount = 0

for i, v in Counts.Correct do
	CorrectCount += 1
end

for i, v in Counts.Incorrect do
	IncorrectCount += 1
end

print(CorrectCount, IncorrectCount)

--Setup Results Window
local ResultsWindow = WindowModule.new(Assets:FindFirstChild("UI").WindowBases.ScrollTemplate, {
	Name = "Shift Results",
	Size = UDim2.fromScale(0.8, 0.65)
})

local ResultSettings = require(ResultsWindow.Settings)
--MailWindow.Instance.Parent = Main

ResultSettings.MaxOptions = 12
ResultSettings.UpdateWindow()

for Title, Reason in Counts.Correct do
	local Option = nil
	Option = ResultSettings.CreateOption(Title, function()
		--Setup Window
		local MessageWindow = WindowModule.new(Assets:FindFirstChild("UI").WindowBases.CloseableTemplate, {
			Name = Title.. " - Review",
			Size = UDim2.fromScale(0.335*1.75, 0.433*1.75)
		})
		local WindowSettings = require(MessageWindow.Settings)
		local function DestroyMsgWindow()
			MessageWindow.Instance:Destroy()
			MessageWindow = nil
			Option:Remove()
		end
		local Trash = Assets.UI.TrashCan:Clone()
		Trash.Parent = Option.Instance
		Trash.MouseButton1Click:Connect(DestroyMsgWindow)
		local BodyText = Assets.UI.BodyText:Clone()
		BodyText.RichText = true
		BodyText.Text = Reason
		BodyText.Parent = MessageWindow.Instance
		MessageWindow.Instance.Parent = Main
		if MessageWindow.Settings then
			WindowSettings.UpdateWindow()
			WindowSettings.PressBind()
		end
	end)
end

for Title, Reason in Counts.Incorrect do
	local Option = nil
	Option = ResultSettings.CreateOption(Title, function()
		--Setup Window
		local MessageWindow = WindowModule.new(Assets:FindFirstChild("UI").WindowBases.CloseableTemplate, {
			Name = Title.. " - Review",
			Size = UDim2.fromScale(0.335*1.75, 0.433*1.75)
		})
		local WindowSettings = require(MessageWindow.Settings)
		local function DestroyMsgWindow()
			MessageWindow.Instance:Destroy()
			MessageWindow = nil
			Option:Remove()
		end
		local Trash = Assets.UI.TrashCan:Clone()
		Trash.Parent = Option.Instance
		Trash.MouseButton1Click:Connect(DestroyMsgWindow)
		local BodyText = Assets.UI.BodyText:Clone()
		BodyText.RichText = true
		BodyText.Text = Reason
		BodyText.Parent = MessageWindow.Instance
		MessageWindow.Instance.Parent = Main
		if MessageWindow.Settings then
			WindowSettings.UpdateWindow()
			WindowSettings.PressBind()
		end
	end)
end

local Template = Main.Background.ShortcutTemplate:Clone()
Template.Image = "rbxassetid://89469893993351"
Template.Title.Text = "Shift Report"
Template.Parent = Main.Background
Template.Visible = true
Template.MouseButton1Click:Connect(function()
	ResultsWindow.Instance.Parent = (ResultsWindow.Instance.Parent ~= Main) and Main or nil
end)
