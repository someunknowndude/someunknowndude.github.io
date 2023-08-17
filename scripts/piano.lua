-- FE Piano by quirky anime boy (Discord: smokedoutlocedout)
-- make sure you have at least 6 boomboxes

local settings = {
	AirSit = true, 				-- makes you sit in place for a better "piano" experience
	DisableSheetPage = true, 	-- disables the built-in sheet music button/keybind
	DisableZoomKeys = true, 	-- disables the I and O zoom keybinds
	LoadMidiPlayer = true, 		-- loads  0866's midi autoplayer
	AlternativeBoombox = false 	-- Removes the "PlaySong" argument from the RemoteEvent. Change this if no sounds are playing. 
}

if game:GetService("SoundService").RespectFilteringEnabled then return end -- timeposition and Stop cant be used

if settings.DisableZoomKeys then
	game:GetService("ContextActionService"):BindActionAtPriority("do nothing", function() return Enum.ContextActionResult.Sink end, false, 3000, Enum.KeyCode.I, Enum.KeyCode.O)
end

local PianoGui = game:GetObjects("rbxassetid://11319793375")[1].PianoGui
local script = PianoGui.Main

Gui = script.Parent
Player = game.Players.LocalPlayer

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
	BreakHumanoidConnections()
	BreakKeyboardConnections()
	BreakGuiConnections()
	HidePiano()
	HideSheets()
	for i,v in pairs(Player.Character:GetChildren()) do
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
ExitButtonConnection = nil;
SheetsButtonConnection = nil;
CapsButtonConnection = nil;
TransDnConnection = nil;
TransUpConnection = nil;

function MakeGuiConnections()
	for i, v in pairs(PianoGui.Keys:GetChildren()) do
		PianoKeysConnections[i] = v.InputBegan:connect(function(Object) PianoKeyPressed(Object, tonumber(v.Name)) end)
	end
	
	ExitButtonConnection = PianoGui.ExitButton.InputBegan:connect(ExitButtonPressed)
	SheetsButtonConnection = PianoGui.SheetsButton.InputBegan:connect(SheetsButtonPressed)
	CapsButtonConnection = PianoGui.CapsButton.InputBegan:connect(CapsButtonPressed)
	
	TransDnConnection = PianoGui.TransDnButton.MouseButton1Click:connect(function()
		Transpose(-1)
	end)
	
	TransUpConnection = PianoGui.TransUpButton.MouseButton1Click:connect(function()
		Transpose(1)
	end)
end
function BreakGuiConnections()
	for i, v in pairs(PianoKeysConnections) do
		v:disconnect()
	end
	ExitButtonConnection:disconnect()
	SheetsButtonConnection:disconnect()
	CapsButtonConnection:disconnect()
	if MidiGui then
		MidiGui.Enabled = false
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

local lp = game.Players.LocalPlayer
local char = lp.Character or lp.CharacterAdded:Wait()

local boomboxes = {}

local noteBoomboxes = {}

LocalSounds = {
	[1] = {id = "233836579", lastPlayed = 0}, --C/C#
	[2] = {id = "233844049", lastPlayed = 0}, --D/D#
	[3] = {id = "233845680", lastPlayed = 0}, --E/F
	[4] = {id = "233852841", lastPlayed = 0}, --F#/G
	[5] = {id = "233854135", lastPlayed = 0}, --G#/A
	[6] = {id = "233856105", lastPlayed = 0}, --A#/B
}


local function findBoomboxes(parent)
	for i,v in pairs(parent:GetChildren()) do
		local partName = v.Name:lower():gsub(" ","")
		if v:IsA("Tool") and (partName:find("boombox") or partName:find("radio")) then
			table.insert(boomboxes, v)
		end
	end
end

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
	task.spawn(function()
		task.wait(5)
		if os.clock() - sound.lastPlayed >= 5 then
			audio:Stop()
		end
	end)
end

findBoomboxes(lp.Backpack)
findBoomboxes(char)

for i = 1,6 do
	noteBoomboxes[i] = boomboxes[i]
	noteBoomboxes[i].Parent = char
end

local oldpos = char.HumanoidRootPart.CFrame
char.HumanoidRootPart.CFrame = CFrame.new(1000,99999999,10000)

task.wait(.3)

for i,v in pairs(noteBoomboxes) do
	v.Parent = workspace
end

task.wait(.2)

local fakeTools = {}
for i = 1,10 do
	local tool = Instance.new("Tool",lp.Backpack)
	table.insert(fakeTools, tool)
end

task.wait()

for i,v in pairs(noteBoomboxes) do
	char.Humanoid:EquipTool(v)
end

task.wait(.2)

for i,v in pairs(fakeTools) do
	v:Destroy()
end

task.wait()

for i,v in pairs(noteBoomboxes) do
    v.Parent = char
end

for i,v in pairs(lp.Backpack:GetChildren()) do
	if v:IsA("Tool") and not table.find(noteBoomboxes,v) then
		v:Destroy()
	end
end

char.HumanoidRootPart.CFrame = oldpos

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
Player.Character.Humanoid.Died:Connect(Deactivate)
if settings.LoadMidiPlayer then
	MidiGui = game:GetService("CoreGui"):FindFirstChild("ScreenGui")
	if not MidiGui then
		loadstring(game:HttpGet("https://raw.githubusercontent.com/richie0866/MidiPlayer/main/package.lua"))()
		MidiGui = game:GetService("CoreGui"):WaitForChild("ScreenGui")
	else
		MidiGui.Enabled = true
	end
end
