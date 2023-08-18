--[[
FE Boombox Piano by quirky anime boy (Discord: smokedoutlocedout)

Make sure you aren't in shiftlock, use Airsit to play midis without moving.

If you have less than 6 boomboxes the script will try to dupe them for you.

Credits to 0866 for the midi player 
(note: put midi files you wanna play into the midi folder located in your exploit's workspace folder)

for some good midis:
Musescore: https://musescore.com/
Musescore downloader extension: https://github.com/ingui-n/musescore-downloader/tree/master
--]]

local settings
if getgenv().PianoSettings == nil then
	settings = {
		DisableSheetPage = true, 	-- disables the built-in sheet music button/keybind
		DisableZoomKeys = true, 	-- disables the I and O zoom keybinds
		LoadMidiPlayer = true, 		-- loads  0866's midi autoplayer
		AlternativeBoombox = false, -- removes the "PlaySong" argument from the RemoteEvent. Change this if no sounds are playing
		PlayPianoAnimations = true, -- plays piano animations while airsitting (will break tool hold animation)
	}
else
	settings = getgenv().PianoSettings
end
if game:GetService("SoundService").RespectFilteringEnabled then return error("RespectFilteringEnabled is active. Please try a different game.") end -- TimePosition etc. can't be used


if settings.DisableZoomKeys then
	game:GetService("ContextActionService"):BindActionAtPriority("do nothing", function() return Enum.ContextActionResult.Sink end, false, 3000, Enum.KeyCode.I, Enum.KeyCode.O)
end

Player = game.Players.LocalPlayer
Character = Player.Character or Player.CharacterAdded:Wait()

local boomboxes = {}
local function findBoomboxes(parent)
	for i,v in pairs(parent:GetChildren()) do
		local partName = v.Name:lower():gsub(" ","")
		if v:IsA("Tool") and (partName:find("boombox") or partName:find("radio")) then
			table.insert(boomboxes, v)
		end
	end
end

findBoomboxes(Player.Backpack)
findBoomboxes(Character)

local bbAmount = #boomboxes
if bbAmount < 6 then
	Character = Player.Character or Player.CharacterAdded:Wait()
	local pos = Character.HumanoidRootPart.CFrame
	local tools = {}

	local function dupe(num)
		Character = Player.Character or Player.CharacterAdded:Wait()
		local hrp = Character:WaitForChild("HumanoidRootPart")
		hrp.CFrame = CFrame.new(420 + (num * 20),9999999,0)
		
		for i,v in pairs(Player.Backpack:GetChildren()) do
			if v:IsA("Tool") then
				table.insert(tools, v)
				v.Parent = Character
			end
		end
		task.wait(.3)
		for i,v in pairs(Character:GetChildren()) do
			if v:IsA("Tool") then
				v.Parent = workspace
				v.Handle.Anchored = true
			end
		end
		
		task.wait(.2)
		
		Character.Humanoid:ChangeState("Dead")
		
		Player.CharacterAdded:Wait()
	end

	for i = 1, 6 - ((bbAmount > 0 and bbAmount) or 0) do
		dupe(i)
	end
	
	Character = Player.Character or Player.CharacterAdded:Wait()

	Character:WaitForChild("HumanoidRootPart").CFrame = pos

	for i,v in pairs(tools) do
		v.Handle.Anchored = false
		Character.Humanoid:EquipTool(v)
	end

	task.wait(.2)

	findBoomboxes(Player.Backpack)
	findBoomboxes(Character)
end

local PianoGui = game:GetObjects("rbxassetid://11319793375")[1].PianoGui
local script = PianoGui.Main


Gui = script.Parent

Gui.Parent = Player.PlayerGui
PlayingEnabled = false

ScriptReady = false



----------------------------------
----------------------------------
----------------------------------
---------PIANO CONNECTION---------
----------------------------------
----------------------------------
----------------------------------

----------------------------------
------------VARIABLES-------------
----------------------------------

PianoId = nil

local Transposition, Volume = script.Parent:WaitForChild("Transpose"), 1
----------------------------------
------------FUNCTIONS-------------
----------------------------------


function Activate()
	PlayingEnabled = true
	MakeKeyboardConnections()
	MakeGuiConnections()
	ShowPiano()
end

function Deactivate()
	PlayingEnabled = false
	BreakKeyboardConnections()
	BreakGuiConnections()
	HidePiano()
	HideSheets()
	for i,v in pairs(Character:GetChildren()) do
		if v:IsA("Tool") then
			v.Handle.Sound:Stop()
		end
	end
end
function PlayNoteClient(note)
		PlayNoteSound(note)
		HighlightPianoKey(note)
end


function Transpose(value)
	Transposition.Value = Transposition.Value + value
	
	PianoGui.TransposeLabel.Text = "Transposition: " .. Transposition.Value
end


----------------------------------
----------------------------------
----------------------------------
----------KEYBOARD INPUT----------
----------------------------------
----------------------------------
----------------------------------

----------------------------------
------------VARIABLES-------------
----------------------------------

InputService = game:GetService("UserInputService")
Mouse = Player:GetMouse()
TextBoxFocused = false
FocusLost = false
ShiftLock = false

----------------------------------
------------FUNCTIONS-------------
----------------------------------

letterNoteMap = "1!2@34$5%6^78*9(0qQwWeErtTyYuiIoOpPasSdDfgGhHjJklLzZxcCvVbBnm"
function LetterToNote(key, shift, ctrl)
	local note = letterNoteMap:find(string.char(key), 1, true)
	if note then
		return note + Transposition.Value + (shift and 1 or ctrl and -1 or 0)
	end
end

function KeyDown(Object)
	if TextBoxFocused then
		return
	end
	local key = Object.KeyCode.Value
	if key >= 97 and key <= 122 or key >= 48 and key <= 57 then
		local note = LetterToNote(key, (InputService:IsKeyDown(303) or InputService:IsKeyDown(304)) ~= ShiftLock, InputService:IsKeyDown(305) or InputService:IsKeyDown(306))
		if note then
			do
				local conn
				conn = InputService.InputEnded:connect(function(obj)
					if obj.KeyCode.Value == key then
						conn:disconnect()
					end
				end)
				PlayNoteClient(note)
			end
		else
			PlayNoteClient(note)
		end
	elseif key == 32 then
		ToggleSheets()
	elseif key == 301 then
		ToggleCaps()
	elseif key == 13 then
		ToggleCaps()
	elseif key == 274 then
		Transpose(-1)
	elseif key == 273 then
		Transpose(1)
	end
end

function Input(Object)
	local type = Object.UserInputType.Name
	local state = Object.UserInputState.Name -- in case I ever add input types
	if type == "Keyboard" then
		if state == "Begin" then
			if FocusLost then -- this is so when enter is pressed in a textbox, it doesn't toggle caps
				FocusLost = false
				return
			end
			KeyDown(Object)
		end
	end
end

function TextFocus()
	TextBoxFocused = true
end
function TextUnfocus()
	FocusLost = true
	TextBoxFocused = false
end

----------------------------------
-----------CONNECTIONS------------
----------------------------------

KeyboardConnection = nil
FocusConnection = InputService.TextBoxFocused:connect(TextFocus) --always needs to be connected
UnfocusConnection = InputService.TextBoxFocusReleased:connect(TextUnfocus)

function MakeKeyboardConnections()
	KeyboardConnection = InputService.InputBegan:connect(Input)
	
end
function BreakKeyboardConnections()
	KeyboardConnection:disconnect()
end



----------------------------------
----------------------------------
----------------------------------
----------GUI FUNCTIONS-----------
----------------------------------
----------------------------------
----------------------------------

----------------------------------
------------VARIABLES-------------
----------------------------------

PianoGui = Gui.PianoGui
SheetsGui = Gui.SheetsGui
SheetsVisible = false
MidiGui = nil

----------------------------------
------------FUNCTIONS-------------
----------------------------------

function ShowPiano()
	PianoGui:TweenPosition(
		UDim2.new(0.481, -355, 0.68, 0),
		Enum.EasingDirection.Out,
		Enum.EasingStyle.Sine,
		.5,
		true
	)
end
function HidePiano()
	if PianoGui.Parent == nil then return end
	PianoGui:TweenPosition(
		UDim2.new(0.481, -355, 1, 1),
		Enum.EasingDirection.Out,
		Enum.EasingStyle.Sine,
		.5,
		true,
		function()
			Gui:Destroy()
		end
	)

end
function ShowSheets()
	SheetsGui:TweenPosition(
		UDim2.new(0.492, -200, 1, -520),
		Enum.EasingDirection.Out,
		Enum.EasingStyle.Sine,
		.5,
		true
	)
end
function HideSheets()
	SheetsGui:TweenPosition(
		UDim2.new(0.492, -200, 1, 1),
		Enum.EasingDirection.Out,
		Enum.EasingStyle.Sine,
		.5,
		true
	)
end

function ToggleSheets()
	if settings.DisableSheetPage then return end
	SheetsVisible = not SheetsVisible
	if SheetsVisible then
		ShowSheets()
	else
		HideSheets()
	end
end

function IsBlack(note)
	if note%12 == 2 or note%12 == 4 or note%12 == 7 or note%12 == 9 or note%12 == 11 then
		return true
	end
	return
end


function HighlightPianoKey(note)
	local x = (note > 61 and 61) or (note < 1 and 1);
	local keyGui = PianoGui.Keys[x or note];
	
	if x then
		keyGui.BackgroundColor3 = Color3.new(200/255, 50/255, 50/255)
	elseif IsBlack(note) then
		keyGui.BackgroundColor3 = Color3.new(50/255, 50/255, 50/255)
	else
		keyGui.BackgroundColor3 = Color3.new(200/255, 200/255, 200/255)
	end
	
	delay(.5, function() RestorePianoKey(x or note) end)
end

function RestorePianoKey(note)
	local keyGui = PianoGui.Keys[note]
	if IsBlack(note) then
		keyGui.BackgroundColor3 = Color3.new(0, 0, 0)
	else
		keyGui.BackgroundColor3 = Color3.new(1, 1, 1)
	end
end

function PianoKeyPressed(Object, note)
	local type = Object.UserInputType.Name
	if type == "MouseButton1" or type == "Touch" then
		PlayNoteClient(note)
	end
end

function ExitButtonPressed(Object)
	local type = Object.UserInputType.Name
	if type == "MouseButton1" or type == "Touch" then
		PlayingEnabled = false
		BreakKeyboardConnections()
		BreakGuiConnections()
		HidePiano()
		HideSheets()
	end
end

function SheetsButtonPressed(Object)
	local type = Object.UserInputType.Name
	if type == "MouseButton1" or type == "Touch" then
		ToggleSheets()
	end
end

function ToggleCaps()
	local capscheck = Gui.PianoGui.capscheck
	ShiftLock = not ShiftLock
	if ShiftLock then
		PianoGui.CapsButton.buttonXD.ImageColor3 = Color3.fromRGB(49, 189, 245)
		capscheck.Text = "Caps: On"
	else
		PianoGui.CapsButton.buttonXD.ImageColor3 = Color3.fromRGB(132, 132, 132)
		capscheck.Text = "Caps: Off"
	end
	return
end

function CapsButtonPressed(Object)
	local type = Object.UserInputType.Name
	if type == "MouseButton1" or type == "Touch" then
		ToggleCaps()
	end
	return
end


----------------------------------
-----------CONNECTIONS------------
----------------------------------

PianoKeysConnections = {};
ForceStopConnections = {};
ExitButtonConnection = nil;
SheetsButtonConnection = nil;
CapsButtonConnection = nil;
TransDnConnection = nil;
TransUpConnection = nil;
NewGuiConnection = nil;

function MakeGuiConnections()
	for i, v in pairs(PianoGui.Keys:GetChildren()) do
		PianoKeysConnections[i] = v.InputBegan:connect(function(Object) PianoKeyPressed(Object, tonumber(v.Name)) end)
	end
	
	local AnchorButton = PianoGui.SheetsButton:Clone()
	AnchorButton.Name = "AnchorButton"
	AnchorButton.Text = "Airsit"
	AnchorButton.Position = UDim2.new(0,80,0,15)
	AnchorButton.Parent = PianoGui

	ExitButtonConnection = PianoGui.ExitButton.InputBegan:connect(ExitButtonPressed)
	SheetsButtonConnection = PianoGui.SheetsButton.InputBegan:connect(SheetsButtonPressed)
	CapsButtonConnection = PianoGui.CapsButton.InputBegan:connect(CapsButtonPressed)
	
	local playingAnimation = false

	AnchorButton.MouseButton1Click:connect(function()
		Character.HumanoidRootPart.Anchored = not Character.HumanoidRootPart.Anchored
		Character.Humanoid.Sit = not Character.Humanoid.Sit
	
		if not settings.PlayPianoAnimations then return end
		playingAnimation = not playingAnimation
		if playingAnimation then
			local animation = Instance.new("Animation")
			local animationId
			if Character.Humanoid.RigType == Enum.HumanoidRigType.R6 then
				animationId = "673670051"
			else
				animationId = "673670434"
			end
			animation.AnimationId = "rbxassetid://" .. animationId
			local loadedAnimation = Character.Humanoid:LoadAnimation(animation)
			loadedAnimation:Play()
		else
			for i,v in pairs(Character.Humanoid:GetPlayingAnimationTracks()) do
				v:Stop()
			end

		end
	end)

	TransDnConnection = PianoGui.TransDnButton.MouseButton1Click:connect(function()
		Transpose(-1)
	end)
	
	TransUpConnection = PianoGui.TransUpButton.MouseButton1Click:connect(function()
		Transpose(1)
	end)

	NewGuiConnection = Player.PlayerGui.ChildAdded:Connect(function(instance)
		if instance.Name == "ChooseSongGui" then
			task.wait()
			instance.Enabled = false
		end
	end)
end
function BreakGuiConnections()
	for i, v in pairs(PianoKeysConnections) do
		v:disconnect()
	end
	for i,v in pairs(ForceStopConnections) do
		v:disconnect()
	end
	NewGuiConnection:disconnect()
	ExitButtonConnection:disconnect()
	SheetsButtonConnection:disconnect()
	CapsButtonConnection:disconnect()
	if MidiGui then
		MidiGui.Enabled = false
	end
	Character.HumanoidRootPart.Anchored = false
	Character.Humanoid.Sit = false
	if settings.PlayPianoAnimations then
		for i,v in pairs(Character.Humanoid:GetPlayingAnimationTracks()) do
			v:Stop()
		end
	end
end

----------------------------------
----------------------------------
----------------------------------
----------SOUND CONTROL-----------
----------------------------------
----------------------------------
----------------------------------

----------------------------------
------------VARIABLES-------------
----------------------------------

local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

local noteBoomboxes = {}

LocalSounds = {
	[1] = {id = "233836579", lastPlayed = 0}, --C/C#
	[2] = {id = "233844049", lastPlayed = 0}, --D/D#
	[3] = {id = "233845680", lastPlayed = 0}, --E/F
	[4] = {id = "233852841", lastPlayed = 0}, --F#/G
	[5] = {id = "233854135", lastPlayed = 0}, --G#/A
	[6] = {id = "233856105", lastPlayed = 0}, --A#/B
}



local function playSound(bb, sound, timepos)
	local remote = bb:FindFirstChildOfClass("RemoteEvent")
	local audio = bb.Handle.Sound
	local sound = LocalSounds[sound]
	sound.lastPlayed = os.clock()
	if not audio.Playing then
		if settings.AlternativeBoombox then
			remote:FireServer(sound.id)
		else
			remote:FireServer("PlaySong",sound.id)
		end
		bb.Handle.Sound.Destroying:Wait()
		task.wait()
		audio = bb.Handle:FindFirstChild("Sound")
	end
	audio.TimePosition = timepos
	audio:Resume()
	local stopcon;stopcon = audio.DidLoop:Connect(function()
		audio:Pause()
		stopcon:Disconnect()
	end)
	table.insert(ForceStopConnections, stopcon)
	task.spawn(function()
		task.wait(5)
		if os.clock() - sound.lastPlayed >= 5 then
			audio:Pause()
		end
	end)
end

for i = 1,6 do
	noteBoomboxes[i] = boomboxes[i]
	noteBoomboxes[i].Parent = Character
end

local oldpos = Character.HumanoidRootPart.CFrame
Character.HumanoidRootPart.CFrame = CFrame.new(1000,99999999,10000)

task.wait(.3)

for i,v in pairs(noteBoomboxes) do
	v.Parent = workspace
end

task.wait(.2)

local fakeTools = {}
for i = 1,10 do
	local tool = Instance.new("Tool",Player.Backpack)
	table.insert(fakeTools, tool)
end

task.wait()

for i,v in pairs(noteBoomboxes) do
	Character.Humanoid:EquipTool(v)
end

task.wait(.2)

for i,v in pairs(fakeTools) do
	v:Destroy()
end

task.wait()

for i,v in pairs(noteBoomboxes) do
    v.Parent = Character
end

for i,v in pairs(Player.Backpack:GetChildren()) do
	if v:IsA("Tool") and not table.find(noteBoomboxes,v) then
		v:Destroy()
	end
end

Character.HumanoidRootPart.CFrame = oldpos

task.wait()



local counter = 0
function PlayNoteSound(note)
	local SoundList =  LocalSounds
	
	local note2 = (note - 1)%12 + 1	-- Which note? (1-12)
	
	local octave = math.ceil(note/12) -- Which octave?
	local sound = math.ceil(note2/2) -- Which audio?
	local offset = 16 * (octave - 1) + 8 * (1 - note2%2) -- How far in audio?
	
	playSound(noteBoomboxes[sound], sound, offset + (octave - .9)/15)
end


----------------------------------
----------------------------------
----------------------------------
---------INITIATE SCRIPT----------
----------------------------------
----------------------------------
----------------------------------

ScriptReady = true
Activate()
Character.Humanoid.Died:Connect(Deactivate)
if settings.LoadMidiPlayer then
	for i,v in pairs(game:GetService("CoreGui"):GetChildren()) do
		if v.Name == "ScreenGui" and v:FindFirstChild("Frame") and v.Frame:FindFirstChild("Handle") then
			MidiGui = v
			break
		end
	end
	if not MidiGui then
		loadstring(game:HttpGet("https://raw.githubusercontent.com/richie0866/MidiPlayer/main/package.lua"))()
		MidiGui = game:GetService("CoreGui"):WaitForChild("ScreenGui")
	else
		MidiGui.Enabled = true
	end
end
