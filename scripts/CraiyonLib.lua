if not isfolder("generatedImages") then makefolder("generatedImages") end
local getasset = getsynasset or getcustomasset or error("not supported")
local hreq = (syn and syn.request) or (http and http.request) or request or error("not supported")
local base64 = {} do -- idk who made this
	local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
	
    function base64.encode(data)
		return ((data:gsub('.', function(x) 
			local r,b='',x:byte()
			for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
			return r;
		end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
			if (#x < 6) then return '' end
			local c=0
			for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
			return b:sub(c+1,c+1)
		end)..({ '', '==', '=' })[#data%3+1])
	end
	
	function base64.decode(data)
		data = string.gsub(data, '[^'..b..'=]', '')
		return (data:gsub('.', function(x)
			if (x == '=') then return '' end
			local r,f='',(b:find(x)-1)
			for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
			return r;
		end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
			if (#x ~= 8) then return '' end
			local c=0
			for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
			return string.char(c)
		end))
	end
end

local function generateImages(prompt)
    local req = hreq({
        Url = "https://backend.craiyon.com/generate",
        Method = "POST",
        Headers = {
            ["content-type"] = "application/json",
            
        },
        Body = [[{"prompt":"]] .. prompt .. "\"}" --JSONEncode didnt work idk
    })
    
    local dec = game:GetService("HttpService"):JSONDecode(req.Body)
    local images = dec.images
    return images
end
local function getAssetId(imgdata)
    local data = base64.decode(imgdata)
    local rng = game:GetService("HttpService"):GenerateGUID()
    local filename = "/generatedImages/generated" .. rng .. ".jpeg"
    writefile(filename,data)
    local id = getasset(filename)
    spawn(function()
        task.wait(3) -- deletes the image after 3 seconds, trying to load the image in after this timespan wont work
        delfile(filename)
    end)
    return id
end

local lib = {}
function lib:Generate(token) -- returns table of 9 generated images to use on ImageLabels/Buttons
    local generated = generateImages(token)
    local imgs = {}
    for i,v in pairs(generated) do
        local assetid = getAssetId(v)
        table.insert(imgs,assetid)
    end
    return imgs
end

function lib:Clear() -- in case anything didnt get deleted for some reason
    for i,v in pairs(listfiles("/generatedImages")) do 
        delfile(v)
    end
end

return lib
