-- made by quirky anime boy. Discord: smokedoutlocedout

local startSignal = Vector3.new(123123,6969,123123)
local deleteSignal = Vector3.new(0,8000, 133769)

local customTime = 0.3

local players = game:GetService("Players")
local lp = players.LocalPlayer
local mouse = lp:GetMouse()
local playerList = {}
local lphrp
local lphum
local oldPosition

local partSelection = {
    num = nil,
    cf = nil
}

local partsFolder = Instance.new("Folder",workspace)
partsFolder.Name = "Spawned Parts"

local buildParts = { -- editing this will cause desync with other users
	[1] = {
		name = "Default Part",
		func = function(self, cf)
            local part = Instance.new("Part")
			part.Anchored = true
			part.CFrame = cf
            part.CanCollide = true
            part.Transparency = 0
            local model = Instance.new("Model")
            model.Name = self.name
            model.Parent = partsFolder

            part.Parent = model
            model.PrimaryPart = part
            return model
		end
	},
	[2] = {
		name = "3s³ Ball",
		func = function(self, cf)
			local part = Instance.new("Part")
            local model = Instance.new("Model")
            model.Name = self.name
            model.Parent = partsFolder
            part.CanCollide = true
            part.Transparency = 0
			part.Anchored = true
			part.CFrame = cf
			part.Shape = "Ball"
			part.Size = Vector3.new(3,3,3)
            part.Parent = model
            
            model.PrimaryPart = part
            return model
		end
	},
    [3] = {
        name = "Roblox House",
        func = function(self, cf)
            local model = game:GetObjects("rbxassetid://8959904556")[1].House
            model.Name = self.name
            model.PrimaryPart = model["Smooth Block Model"]
            model:PivotTo(cf)
            model.Parent = partsFolder
            return model
        end
    }
}


for i,v in pairs(buildParts) do
	v.signal = Vector3.new(500,909090,1337) + Vector3.new(i*20,0,i*20)
end

for i,v in pairs(players:GetPlayers()) do
	playerList[v.Name] = {
		state = "none"
	}
end


players.PlayerAdded:Connect(function(p)
	playerList[p.Name] =  {
		state = "none"
	}
end)

players.PlayerRemoving:Connect(function(p)
	playerList[p.Name] = nil
end)


local function getBodyParts()
	local char = lp.Character or lp.CharacterAdded:Wait()
	lphrp = char:WaitForChild("HumanoidRootPart", 5)
	lphum =  char:WaitForChild("Humanoid", 5)
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

local function uniqueOffset(user)
    local random = Random.new(user.UserId)
	random = random:NextInteger(0,1000)
	return Vector3.new(random, 0, random)
end

lp.Chatted:Connect(function(m)
	if m == "-rj" then
		game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId)
	end
end)

local lpOffset = uniqueOffset(lp)
local lpStartSignal = startSignal + lpOffset
local lpDeleteSignal = deleteSignal + lpOffset

local noclipToggle = false
local noclipLoop = game:GetService("RunService").Stepped:Connect(function()
	if not noclipToggle then return end
    for i,v in pairs(lp.Character:GetChildren()) do
		if v:IsA("BasePart") then
			v.CanCollide = false
		end
	end
end)

local function listen(char)
	--print("listening on character", char.Name)
	local hrp = char:WaitForChild("HumanoidRootPart",5)
	if not hrp then return end
	
    local plrOffset = uniqueOffset(game.Players[char.Name])
	local startSignal =  startSignal + plrOffset
    local deleteSignal = deleteSignal + plrOffset

	local entry = playerList[char.Name]
	local selectedPart
	local enoughTimePassed
	local connection
    -- lp.Character.Humanoid.Died:Connect(function()
    --     connection:Disconnect()
    -- end)
	connection = game:GetService("RunService").PreRender:Connect(function()
		if not hrp then connection:Disconnect() end
		local cf = hrp.CFrame
		local pos = cf.Position
		local state = entry["state"]
		
		if state == "none" and checkPosition(pos,startSignal,1) then
			entry["state"] = "started"
			print("Stream was started")
			return
		end
		
        if state == "none" and checkPosition(pos,deleteSignal,1) then
			entry["state"] = "deleting"
			print("Destroy begun")
            task.wait(customTime + 0.05)
            enoughTimePassed = true
			return
		end

        if state == "deleting" then
            
            if not enoughTimePassed then return end
            entry["state"] = "none"
            for i,v in pairs(partsFolder:GetChildren()) do
                if table.find({"Start signal platform", "Build tool platform", "Delete tool platform"},v.Name) then continue end
                if checkPosition(hrp.Position, v.PrimaryPart.Position ,1) then
                    v:Destroy()
                    print(char.Name .. " destroyed " .. v.Name)
                    enoughTimePassed = false
                    return
                end
            end
        end

		if state == "started" then
			for i,v in pairs(buildParts) do
				if checkPosition(pos, v.signal + plrOffset,1) then
					selectedPart = v
					entry["state"] = "selected"
                    print("selected prefab " .. selectedPart.name)
                    task.wait(customTime + 0.05)
                    enoughTimePassed = true
					return
				end
			end
		end

		if state == "selected" and enoughTimePassed then
			entry["state"] = "none"
			if enoughTimePassed then
                enoughTimePassed = false
                selectedPart.func(selectedPart, hrp.CFrame)
                print("Part placed, Stream reset")
                return
            end
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
	position(lpStartSignal,0.1)
end

local function endStream()
	lphrp.CFrame = oldPosition
    noclipToggle = false
	lphum.PlatformStand = false
end

for i,v in pairs(players:GetPlayers()) do
	v.CharacterAdded:Connect(listen)
	local char = v.Character
	if char then
		listen(char)
	end
end

players.PlayerAdded:Connect((function(p)
	p.CharacterAdded:Connect(listen)
end))

local rotationArray = {}
local function generateRotationMatrix()
	local function generateRow(Z)
		return {Vector3.new(0, 0, Z), Vector3.new(0, 45, Z), Vector3.new(0, 90, Z), Vector3.new(0, 135, Z), Vector3.new(0, 180, Z), Vector3.new(0, -135, Z), Vector3.new(0, -90, Z), Vector3.new(0, -45, Z)}
	end

	rotationArray[1] = generateRow(0)
	rotationArray[2] = generateRow(45)
	rotationArray[3] = generateRow(90)
	rotationArray[4] = generateRow(135)
	rotationArray[5] = generateRow(180)
	rotationArray[6] = generateRow(-135)
	rotationArray[7] = generateRow(-90)
	rotationArray[8] = generateRow(-45)
end

generateRotationMatrix()

local module = {}
local mti = {}

function mti:Rotate()
	self.r = self.r % 8 + 1
end

function mti:Tilt()
	self.t = self.t % 8 + 1
end

function mti:Determine()
	return rotationArray[self.t][self.r]
end

function module.new()
	return setmetatable({r = 1, t = 1}, {__index = mti})
end

--[[ Usage:

local rotator = module.new()
rotator:Tilt()
rotate:Rotate()
local determined = rotator:Determine() -- Get faces
part.CFrame = CFrame.new(part.Position) * CFrame.Angles(math.rad(determined.X), math.rad(determined.Y), math.rad(determined.Z))

--]]


local debounce = false
local function giveBtools()
    for i,v in pairs(buildParts) do
        local buildTool = Instance.new("Tool")
        buildTool.Name = v.name
        buildTool.CanBeDropped = false
        buildTool.RequiresHandle = false
        buildTool.Parent = lp.Backpack

        local preview
        local previewConnection
        local rotateConnection
        local buildCF

        buildTool.Equipped:Connect(function()
            preview = v.func(v,CFrame.new(0,0,0))
            preview.Name = "Preview Model"
            preview.Parent = lp.Character
            for i,v in pairs(preview:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CastShadow = false
                    v.Transparency = 0.75
                    v.CanCollide = false
                end
            end

            local rotator = module.new()
            local determined = preview.PrimaryPart.Orientation
            rotateConnection = game:GetService("UserInputService").InputBegan:Connect(function(obj,proc)
                if proc then return end
                if obj.KeyCode == Enum.KeyCode.R then
                    rotator:Rotate()
                    determined = rotator:Determine()
                    return
                end
                if obj.KeyCode == Enum.KeyCode.T then
                    rotator:Tilt()
                    determined = rotator:Determine()
                end
            end)
            previewConnection = game:GetService("RunService").Heartbeat:Connect(function()
                -- preview:PivotTo(CFrame.new(mouse.Hit.Position ) * CFrame.Angles(math.rad(determined.X), math.rad(determined.Y), math.rad(determined.Z)))
                -- preview:PivotTo(preview.PrimaryPart.CFrame + Vector3.new(0,preview:GetExtentsSize().Y/2,0))
                preview:PivotTo(CFrame.new((mouse.Hit * CFrame.new(0,preview.PrimaryPart.Size.Y/2,0)).Position ) * CFrame.Angles(math.rad(determined.X), math.rad(determined.Y), math.rad(determined.Z)))
            end)
        end)

        buildTool.Unequipped:Connect(function()
            previewConnection:Disconnect()
            rotateConnection:Disconnect()
            preview:Destroy()
        end)

        buildTool.Activated:Connect(function()
        	if debounce or not mouse.Target then return end
            debounce = true
            partSelection.num = i
            partSelection.cf = preview.PrimaryPart.CFrame

            startStream()
            position(v.signal + lpOffset, .2)
            noclipToggle = true
            for i = 1,50 do
                lphrp.CFrame = partSelection.cf
                task.wait(0.01)
            end
            noclipToggle = false
            endStream()
            task.wait()
            debounce = false
        end)
    end

    local redoTool = Instance.new("Tool")
    redoTool.Name = "Redo Tool"
    redoTool.CanBeDropped = false
    redoTool.RequiresHandle = false
    redoTool.Parent = lp.Backpack
    redoTool.TextureId = "rbxassetid://13492317101"

    redoTool.Activated:Connect(function()
        if debounce or partSelection.num == nil or partSelection.cf == nil then return end
        debounce = true
            startStream()
            position(buildParts[partSelection.num].signal + lpOffset, .1)
            noclipToggle = true
            for i = 1,50 do
                lphrp.CFrame = partSelection.cf
                task.wait(0.01)
            end
            noclipToggle = false
            endStream()
            task.wait()
            debounce = false
    end)
    redoTool.Activated:Connect(function()
        if debounce or partSelection.num == nil or partSelection.cf == nil then return end
        debounce = true
            startStream()
            position(buildParts[partSelection.num].signal + lpOffset, .1)
            noclipToggle = true
            for i = 1,50 do
                lphrp.CFrame = partSelection.cf
                task.wait(0.01)
            end
            noclipToggle = false
            endStream()
            task.wait()
            debounce = false
    end)

    local deleteTool = Instance.new("Tool")
    deleteTool.Name = "Delete Tool"
    deleteTool.CanBeDropped = false
    deleteTool.RequiresHandle = false
    deleteTool.Parent = lp.Backpack
    deleteTool.TextureId = "rbxassetid://14808588"

    deleteTool.Activated:Connect(function()
        if debounce then return end
        local selection = mouse.Target
        if selection and selection:IsDescendantOf(partsFolder) and selection.Parent:IsA("Model") and selection.Parent.PrimaryPart == selection then
            debounce = true
            getBodyParts()
            oldPosition = lphrp.CFrame
            lphum.PlatformStand = true
            position(lpDeleteSignal,0.2)
            noclipToggle = true
            for i = 1,50 do
                lphrp.CFrame = selection.CFrame
                task.wait(0.01)
            end
            noclipToggle = false
            endStream()
            task.wait()
            debounce = false
        end
    end)
end

giveBtools()
lp.CharacterAdded:Connect(giveBtools)

spawnPart(lpStartSignal - Vector3.new(0,1,0)).Name = "Start signal platform"
spawnPart(lpDeleteSignal - Vector3.new(0,1,0)).Name = "Delete tool platform"

for i,v in pairs(buildParts) do
	spawnPart(v.signal + lpOffset - Vector3.new(0,1,0)).Name = "Build tool platform"
end

print("init")
