-- first time releasing this anywhere woooo. this prevents .Chatted from being fired and roblox receiving any of your sent messages so you wont get banned for "inappropiate behavior". whispers are buggy and chat commands stop working but this is an unpatchable method of having "safe chat"
local gui = Instance.new("ScreenGui",game:GetService("CoreGui"))
local box = Instance.new("TextBox",gui)
local lp = game:GetService("Players").LocalPlayer
local chatgui = lp.PlayerGui.Chat.Frame.ChatBarParentFrame.Frame.BoxFrame.Frame
local chatbar = chatgui.ChatBar
local chatlabel = chatgui.TextLabel

local chatevent = game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest

gui.Name = "safe chat"

box.Position = UDim2.new(2,0,2,0)
box.Size = UDim2.new(0,0,0,0)
box.Transparency = 1
box.Text = ""
box.ClearTextOnFocus = true

game:GetService("RunService").RenderStepped:Connect(function()
    if chatlabel.Text == [[To chat click here or press "/" key]] then
        chatlabel.Text = [[To safe chat press "/", or click here for regular chat.]]
    end
    if chatbar:IsFocused() then
        box.Text = ""
        return
    end
    chatbar.Text = box.Text
end)

game:GetService("UserInputService").InputBegan:Connect(function(key)
    if key.KeyCode == Enum.KeyCode.Slash and game:GetService("UserInputService"):GetFocusedTextBox() == nil then
        task.wait()
        box:CaptureFocus()
    end
end)

box.FocusLost:Connect(function(enter)
    if enter then
        chatevent:FireServer(box.Text,"All")
        box.Text = ""
    end
end)
