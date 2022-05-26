if game:GetService("SoundService").RespectFilteringEnabled then return error("cringe") end 

local Gui = game:GetObjects("rbxassetid://9663775341")[1]
Gui.Parent = game.CoreGui
Player = game.Players.LocalPlayer
PlayingEnabled = false

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

Connector = Instance.new("RemoteEvent") --game.Workspace:FindFirstChild("GlobalPianoConnector")

----------------------------------
------------FUNCTIONS-------------
----------------------------------

function Receive(action, ...)
	local args = {...}
	if action == "activate" then
		if not PlayingEnabled then
			Activate(args[1], args[2])
		end
	elseif action == "deactivate" then
		if PlayingEnabled then
			Deactivate()
		end
	elseif action == "play" then
		if Player ~= args[1] then
			PlayNoteServer(args[2], args[3], args[4], args[5])
		end
	end
end
function Activate(cameraCFrame, sounds)
	PlayingEnabled = true
	MakeHumanoidConnections()
	MakeKeyboardConnections()
	MakeGuiConnections()
	SetCamera(cameraCFrame)
	SetSounds(sounds)
	ShowPiano()
end
function Deactivate()
	PlayingEnabled = false
	BreakHumanoidConnections()
	BreakKeyboardConnections()
	BreakGuiConnections()
	HidePiano()
	HideSheets()
	ReturnCamera()	
	Jump()
end
function PlayNoteClient(note)
	PlayNoteSound(note)
	HighlightPianoKey(note)

	--Connector:FireServer("play", note)
end
function PlayNoteServer(note, point, range)
	PlayNoteSound(note, point, range)
end
function Abort()
	Connector:FireServer("abort")
end

----------------------------------
-----------CONNECTIONS------------
----------------------------------

--Connector.OnClientEvent:connect(Receive)
--Receive("play","a",2,10,10)

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

function LetterToNote(key, shift)
	local letterNoteMap = "1!2@34$5%6^78*9(0qQwWeErtTyYuiIoOpPasSdDfgGhHjJklLzZxcCvVbBnm"
	local capitalNumberMap = ")!@#$%^&*("
	local letter = string.char(key)
	if shift then
		if tonumber(letter) then
			-- is a number
			letter = string.sub(capitalNumberMap, tonumber(letter) + 1, tonumber(letter) + 1)
		else
			letter = string.upper(letter)
		end
	end
	local note = string.find(letterNoteMap, letter, 1, true)
	if note then
		return note
	end
end

function KeyDown(Object)
	
	if TextBoxFocused then return end
	local key = Object.KeyCode.Value
	local shift = (InputService:IsKeyDown(303) or InputService:IsKeyDown(304)) == not ShiftLock
	if (key >= 97 and key <= 122) or  (key >= 48 and key <= 57) then
		-- a letter was pressed
		local note = LetterToNote(key, shift)
		if note then PlayNoteClient(note) end
	elseif key == 8 then
		-- backspace was pressed
		Deactivate()
	elseif key == 32 then
		-- space was pressed
		ToggleSheets()
	elseif key == 13 then
		-- return was pressed
		ToggleCaps()
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
JumpConnection = nil
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

----------------------------------
------------FUNCTIONS-------------
----------------------------------

function ShowPiano()
	PianoGui:TweenPosition(
		UDim2.new(0.5, -380, 1, -220),
		Enum.EasingDirection.Out,
		Enum.EasingStyle.Sine,
		.5,
		true
	)
end
function HidePiano()
	PianoGui:TweenPosition(
		UDim2.new(0.5, -380, 1, 0),
		Enum.EasingDirection.Out,
		Enum.EasingStyle.Sine,
		.5,
		true
	)
end
function ShowSheets()
	SheetsGui:TweenPosition(
		UDim2.new(0.5, -200, 1, -520),
		Enum.EasingDirection.Out,
		Enum.EasingStyle.Sine,
		.5,
		true
	)
end
function HideSheets()
	SheetsGui:TweenPosition(
		UDim2.new(0.5, -200, 1, 0),
		Enum.EasingDirection.Out,
		Enum.EasingStyle.Sine,
		.5,
		true
	)
end
function ToggleSheets()
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
end

function HighlightPianoKey(note)
	local keyGui = PianoGui.Keys[note]
	if IsBlack(note) then
		keyGui.BackgroundColor3 = Color3.new(50/255, 50/255, 50/255)
	else
		keyGui.BackgroundColor3 = Color3.new(200/255, 200/255, 200/255)
	end
	delay(.5, function() RestorePianoKey(note) end)
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
		Deactivate()
	end
end

function SheetsButtonPressed(Object)
	local type = Object.UserInputType.Name
	if type == "MouseButton1" or type == "Touch" then
		ToggleSheets()
	end
end

function SheetsEdited(property)
	if property == "Text" then
		local bounds = SheetsGui.Sheet.ScrollingFrame.TextBox.TextBounds
		SheetsGui.Sheet.ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, math.max(14, bounds.Y))
	end
end

function ToggleCaps()
	ShiftLock = not ShiftLock
	if ShiftLock then
		PianoGui.CapsButton.BackgroundColor3 = Color3.new(1, 170/255, 0)
		PianoGui.CapsButton.BorderColor3 = Color3.new(154/255, 103/255, 0)
		PianoGui.CapsButton.TextColor3 = Color3.new(1, 1, 1)
	else
		PianoGui.CapsButton.BackgroundColor3 = Color3.new(140/255, 140/255, 140/255)
		PianoGui.CapsButton.BorderColor3 = Color3.new(68/255, 68/255, 68/255)
		PianoGui.CapsButton.TextColor3 = Color3.new(180/255, 180/255, 180/255)
	end
end

function CapsButtonPressed(Object)
	local type = Object.UserInputType.Name
	if type == "MouseButton1" or type == "Touch" then
		ToggleCaps()
	end
end

----------------------------------
-----------CONNECTIONS------------
----------------------------------

PianoKeysConnections = {}
ExitButtonConnection = nil
SheetsButtonConnection = nil
SheetsEditedConnection = nil
CapsButtonConnection = nil

function MakeGuiConnections()
	for i, v in pairs(PianoGui.Keys:GetChildren()) do
		PianoKeysConnections[i] = v.InputBegan:connect(function(Object) PianoKeyPressed(Object, tonumber(v.Name)) end)
	end
	
	ExitButtonConnection = PianoGui.ExitButton.InputBegan:connect(ExitButtonPressed)
	SheetsButtonConnection = PianoGui.SheetsButton.InputBegan:connect(SheetsButtonPressed)
	SheetsEditedConnection = SheetsGui.Sheet.ScrollingFrame.TextBox.Changed:connect(SheetsEdited)
	CapsButtonConnection = PianoGui.CapsButton.InputBegan:connect(CapsButtonPressed)
end
function BreakGuiConnections()
	for i, v in pairs(PianoKeysConnections) do
		v:disconnect()
	end
	
	ExitButtonConnection:disconnect()
	SheetsButtonConnection:disconnect()
	SheetsEditedConnection:disconnect()
	CapsButtonConnection:disconnect()
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

ContentProvider = game:GetService("ContentProvider")

LocalSounds = {
	"233836579", --C/C#
	"233844049", --D/D#
	"233845680", --E/F
	"233852841", --F#/G
	"233854135", --G#/A
	"233856105", --A#/B
}

ExistingSounds = {}

----------------------------------
------------FUNCTIONS-------------
----------------------------------
local bb
local rem
local audio

for i,v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
    if v:IsA("Tool") and v.Handle and v.Handle:FindFirstChildOfClass("Sound") and v:FindFirstChildOfClass("RemoteEvent") then
        bb = v
        rem = bb:FindFirstChildOfClass("RemoteEvent")
        audio = bb.Handle:FindFirstChildOfClass("Sound")
    end
end

function PreloadAudio(sounds)
end
function SetSounds(sounds)
end

local counter = 0
function PlayNoteSound(note, source, range, sounds)
	local SoundList =  LocalSounds
	
	local note2 = (note - 1)%12 + 1	-- Which note? (1-12)
	
	local octave = math.ceil(note/12) -- Which octave?
	local sound = math.ceil(note2/2) -- Which audio?
	local offset = 16 * (octave - 1) + 8 * (1 - note2%2) -- How far in audio?
	
	--local audio = bb.Handle:FindFirstChildOfClass("Sound") -- Create the audio
	--audio.SoundId = "rbxassetid://"..SoundList[sound] -- Give its sound
	--if source then
	--	local a = 1/range^2
	--	local distance = (game.Workspace.CurrentCamera.CoordinateFrame.p - source).magnitude
	--	local volume = -a*distance^2 + 1
	--	if volume < 0.05 then
	--		audio:remove()
	--		return
	--	end
	--	audio.Volume = volume
	--end
	local lastplayed = SoundList[sound]
	local counterid = counter
	bb.Parent = game.Players.LocalPlayer.Character
	rem:FireServer("PlaySong",SoundList[sound])
	--repeat task.wait() audio:Stop() audio.TimePosition = offset + (octave - .9)/15 until audio.IsPlaying == false
	--audio:Play()
	for i = 1,10 do
	    audio.TimePosition = offset + (octave - .9)/15
	    audio:Play()
	end
	
	wait(1)
	
	print(offset + (octave - .9)/15)
	task.wait()
	--audio.Played:Wait()
	--audio:Play() -- Play the audio
	--wait(.2)
	--audio.TimePosition = offset + (octave - .9)/15 -- set the time position
	--task.wait()
-- 	table.insert(ExistingSounds, 1, audio)
-- 	if #ExistingSounds >= 10 then
-- 		ExistingSounds[10]:Stop() -- limit the number of playing sounds!
-- 		ExistingSounds[10] = nil
-- 	end
	
    delay(4, function() 
        if audio.SoundId == lastplayed then 
            audio:Stop() 
            print("Stopped")
        end
    end) -- remove the audio in 4 seconds, enough time for it to play
end

----------------------------------
----------------------------------
----------------------------------
----------CAMERA/PLAYER-----------
----------------------------------
----------------------------------
----------------------------------

----------------------------------
------------VARIABLES-------------
----------------------------------

Camera = game.Workspace.CurrentCamera

----------------------------------
------------FUNCTIONS-------------
----------------------------------

function Jump()
	local character = Player.Character
	if character then
		local humanoid = character:FindFirstChild("Humanoid")
		if humanoid then
			humanoid.Jump = true
		end
	end
end
function HumanoidChanged(humanoid, property)
	--print(property)
	if property == "Jump" then
		humanoid.Jump = false
	elseif property == "Sit" then
		humanoid.Sit = true
	elseif property == "Parent" then
		Deactivate()
		Abort()
	end
end
function HumanoidDied()
	Deactivate()
end
function SetCamera(cframe)
end
function ReturnCamera()
	Camera.CameraType = Enum.CameraType.Custom
end

----------------------------------
-----------CONNECTIONS------------
----------------------------------

HumanoidChangedConnection = nil
HumanoidDiedConnection = nil

function MakeHumanoidConnections()
	local character = Player.Character
	if character then
		local humanoid = character:FindFirstChild("Humanoid")
		if humanoid then
			HumanoidChangedConnection = humanoid.Changed:connect(function(property)
				HumanoidChanged(humanoid, property)
			end)
			HumanoidDiedConnection = humanoid.Died:connect(HumanoidDied)
		end
	end
end
function BreakHumanoidConnections()
	HumanoidChangedConnection:disconnect()
	HumanoidDiedConnection:disconnect()
end

Activate()
