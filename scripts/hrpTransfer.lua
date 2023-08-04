local startSignal = Vector3.new(123123,6969,123123)
local endSignal = Vector3.new(6969,42000,6969)

local customTime = 0.3

local lp = game.Players.LocalPlayer
local lphrp
local lphum
local oldPosition

local partsFolder = Instance.new("Folder",workspace)
partsFolder.Name = "Spawned Parts"

local function getBodyParts()
	local char = lp.Character or lp.CharacterAdded:Wait()
	lphrp = char:WaitForChild("HumanoidRootPart", 5)
	lphum =  char:WaitForChild("Humanoid", 5)
	print("got body parts")
end

local function checkPosition(pos1, pos2, range)
	return (pos1 - pos2).magnitude <= range
end


local function spawnPart(partPos)
	local part = Instance.new("Part")
	part.Anchored = true
	part.Position = partPos
	part.Parent = partsFolder
	return part
end

local function listen(char)
	print("listening on character", char.Name)
	local hrp = char:WaitForChild("HumanoidRootPart",5)
	if not hrp then return end
	
	local streamStarted = false
	local streamEnded = false
	local placed = false
	local enoughTimePassed
	local partPosition = Vector3.new()
	local connection
	connection = game:GetService("RunService").Heartbeat:Connect(function()
		if not hrp then connection:Disconnect() end
		local cf = hrp.CFrame
		local pos = cf.Position
		--if char ~= lp.Character then print(hrp.Position) end
		if streamStarted == false and checkPosition(pos,startSignal,1) then
			streamStarted = true
			streamEnded = false
			print("Stream was started")
			task.wait(customTime + 0.05)
			enoughTimePassed = true
			return
		end
		
		if checkPosition(pos,endSignal,1) and not streamEnded then
			streamStarted = false
			streamEnded = true
			placed = false
			enoughTimePassed = false
			print("Stream ended")
			return
		end
		
		if pos ~= startSignal and streamStarted and not placed and enoughTimePassed and not checkPosition(pos, startSignal, 3) and not checkPosition(pos, endSignal, 3) then
			partPosition = pos
			print("Part was placed at", partPosition)
			spawnPart(partPosition)
			placed = true
		end
	end)
end

local function position(position, waitTime)
	if not lphrp then return end
	lphrp.CFrame = CFrame.new(position)
	local waitTime = waitTime or customTime
	if waitTime > 0 then 
		task.wait(waitTime)
	end
end

local function startStream()
	getBodyParts()
	oldPosition = lphrp.CFrame
	lphum.PlatformStand = true
	position(startSignal)
end

local function endStream()
	position(endSignal)
	lphrp.CFrame = oldPosition
	lphum.PlatformStand = false
end

local noclipToggle = false
local noclipLoop
noclipLoop = game.RunService.Stepped:Connect(function()
	if noclipToggle and lp.Character then
		for i,v in pairs(lp.Character:GetChildren()) do
			if v:IsA("BasePart") then
				v.CanCollide = false
			end
		end
	end
end)

local debounce = false
local function placePart(partPosition)
	if debounce then return end
	debounce = true
	startStream()
	for i = 1,50 do
		noclipToggle = true
		if i%20 == 0 then
			lphrp.Anchored = true
		elseif i%40 == 0 then
			lphrp.Anchored = false
		end
		position(partPosition,0.01)
	end
	noclipToggle = false
	endStream()
	debounce = false
end

for i,v in pairs(game.Players:GetPlayers()) do
	v.CharacterAdded:Connect(listen)
	local char = v.Character
	if char then
		listen(char)
	end
end

game.Players.PlayerAdded:Connect((function(p)
	p.CharacterAdded:Connect(listen)
end))

game:GetService("UserInputService").InputBegan:Connect(function(obj,proc)
	if obj.KeyCode == Enum.KeyCode.E and not proc then
		print("E pressed")
		local hit = lp:GetMouse().Hit
		local tempPart = spawnPart(hit.Position - Vector3.new(0,1,0))
		placePart(hit.Position + Vector3.new(0,0.5,0))
		tempPart:Destroy()
	end
end)

lp.Chatted:Connect(function(m)
	if m == "-rj" then
		game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, lp)
	end
	if m:split(" ")[1] == "-time" then
		customTime = tonumber(m:split(" ")[2])
	end		
end)

spawnPart(startSignal - Vector3.new(0,1,0))
spawnPart(endSignal - Vector3.new(0,1,0))
