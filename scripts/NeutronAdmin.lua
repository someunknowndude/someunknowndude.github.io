local req = (syn and syn.request) or request or httprequest or http_request
if req then
    req({
        Url = "http://127.0.0.1:6463/rpc?v=1",
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json",
            ["origin"] = "https://discord.com",
        },
        Body = game:GetService("HttpService"):JSONEncode(
            {
                ["args"] = {
                    ["code"] = "6DJReS2qFZ",
                },
                ["cmd"] = "INVITE_BROWSER",
                ["nonce"] = "."
            }
        )
    })
end

game.Players.LocalPlayer:Kick("This script has been discontinued. Due to a request from Digitality & the harrassment toward him I decided to remove it. It served its purpose but some ppl took it too far. discord.gg/6DJReS2qFZ")
