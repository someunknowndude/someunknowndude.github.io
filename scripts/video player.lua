local videoPath = "/output"

local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/TheJoaqun/UI-Librarys/UI-Library/UI%20Librarys%20Loadstring/WallyV3.lua"))()
local window = library:CreateWindow("console video player")

local credits = "     quirky anime boy#5506 | https://dsc.gg/nilhub |"
local delay = 0.03
local lp = game.Players.LocalPlayer

local sec = window:CreateFolder("select a video")
for i,v in pairs(listfiles(videoPath)) do
    local filename = v:split("\\")[#v:split("\\")]:sub(1,-5)
    sec:Button(filename,function()
        game:GetService("NetworkClient"):SetOutgoingKBPSLimit(math.huge)
        
        local file = readfile(videoPath .. "/" .. filename .. ".txt")
        repeat wait() until file ~= nil
        local splitlines = file:split("N")
        splitlines[#splitlines] = nil
        
        local bb
        for i,v in pairs(lp.Backpack:GetChildren()) do
            if v:IsA("Tool") and v.Name:lower():find("boom") or v.Name:lower():find("radio") then
                bb = v
                break
            end
        end
        for i,v in pairs(lp.Character:GetChildren()) do
            if v:IsA("Tool") and v.Name:lower():find("boom") or v.Name:lower():find("radio") then
                bb = v
                break
            end
        end
        
        if bb == nil then
            return error("no working boombox found")
        end
        local rem = bb:FindFirstChildOfClass("RemoteEvent") or bb.Handle:FindFirstChildOfClass("RemoteEvent")
        if rem == nil then
            return error("no working boombox found")
        end
        bb.Parent = lp.Character
        wait()
        
        for i,v in pairs(splitlines) do
            if bb.Parent ~= lp.Character then break end
            if game.PlaceId ~= 5100950559 then
                rem:FireServer("PlaySong","\n"..v..credits)
            else
                rem:FireServer("\n"..v..credits)
            end
            task.wait(delay)
        end
    end)
end

local sec2 = window:CreateFolder("misc/options")
sec2:Button("discord invite",function() setclipboard("https://dsc.gg/nilhub") end)
sec2:Box("frame delay (default 0.03)","number",function(t)
    if t ~= "" and t ~= nil then
        delay = tonumber(t)
    else
        delay = 0.03
    end
end)
sec2:Box("custom credits","string",function(t)
    if t ~= "" and t ~= nil then
        credits = t
    else
        credits = "Made by quirky anime boy#5506 | https://dsc.lol/nilhub |"
    end
end)
