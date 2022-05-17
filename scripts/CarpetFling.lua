local lp = game.Players.LocalPlayer
for i,v in pairs(game.Players:GetPlayers()) do
    if v.Name:lower():match("^"..Target:lower()) or v.DisplayName:lower():match("^"..Target:lower()) then
        Target = v
        break
    end
end

if type(Target) == "string" then return end

local oldpos = lp.Character.HumanoidRootPart.CFrame
local oldhh = lp.Character.Humanoid.HipHeight

local carpetAnim = Instance.new("Animation")
carpetAnim.AnimationId = "rbxassetid://282574440"
carpet = lp.Character:FindFirstChildOfClass('Humanoid'):LoadAnimation(carpetAnim)
carpet:Play(.1, 1, 1)

local carpetLoop

local tTorso = Target.Character:FindFirstChild("Torso") or Target.Character:FindFirstChild("LowerTorso") or Target.Character:FindFirstChild("HumanoidRootPart")

spawn(function()
    carpetLoop = game:GetService('RunService').Heartbeat:Connect(function()
	    pcall(function()
	        if tTorso.Velocity.magnitude <= 28 then -- if target uses netless just target their local position
    	        local pos = {x=0, y=0, z=0}
        		pos.x = tTorso.Position.X
        		pos.y = tTorso.Position.Y
        		pos.z = tTorso.Position.Z
        		pos.x = pos.x + tTorso.Velocity.X / 2
        		pos.y = pos.y + tTorso.Velocity.Y / 2
        		pos.z = pos.z + tTorso.Velocity.Z / 2
    		    lp.Character.HumanoidRootPart.CFrame = CFrame.new(Vector3.new(pos.x,pos.y,pos.z))
    		else
    		    lp.Character.HumanoidRootPart.CFrame = tTorso.CFrame
		    end
	    end)
    end)
end)

wait()

lp.Character.Humanoid.HipHeight = flinghh

wait(.5)

carpetLoop:Disconnect()
wait()
lp.Character.Humanoid.Health = 0
wait(game.Players.RespawnTime + .6)
lp.Character.HumanoidRootPart.CFrame = oldpos
