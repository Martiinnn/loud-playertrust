

local apiKey = "YOUR_API_KEY" -- Steam api key https://steamcommunity.com/dev
local daysThreshold = 15 -- Days to check

AddEventHandler('playerConnecting', function(playerName, setKickReason, deferrals)
    deferrals.defer()
    deferrals.update(string.format("Hi %s We are checking you!.", playerName))
    local identifiers = GetPlayerIdentifiers(source)
    local steamID64 = QuitarSteam(identifiers[1])
    local steam64 = hexToSteamID64(steamID64)


    if not steam64 then
        deferrals.done("⚠️|  You need to have steam open to play on this server. ")
    end

    checkSteamAccountCreationDate(steam64, function(puede)
        if puede then
            deferrals.done("⚠️ Your account must be at least "..daysThreshold.." days old to play on this server.")
        else
            deferrals.done()
        end
    end)
end)

function checkSteamAccountCreationDate(steamId64, callback)
    local apiUrl = "http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=" .. apiKey .. "&steamids=" .. steamId64

    PerformHttpRequest(apiUrl, function(statusCode, response, headers)
        if statusCode == 200 then
            local data = json.decode(response)

            if data and data.response and data.response.players and data.response.players[1] and data.response.players[1].communityvisibilitystate ~= 1 then
                local accountCreated = tonumber(data.response.players[1].timecreated)
                local currentTime = os.time()
                local daysSinceCreation = (currentTime - accountCreated) / (24 * 60 * 60)
                local accountName = data.response.players[1].personaname

                if daysSinceCreation < daysThreshold then
                    Log("The Steam account '**" .. accountName .. "**' is less than " .. daysThreshold .. " days old.\nIt has been " .. daysSinceCreation .. " days since its creation.")
                    callback(true)
                else
                    callback(false)
                end
            else
                print("Failed to retrieve Steam account information with ID64 " .. steamId64 .. " or the profile is private.")
                -- If the player has a private profile, allow them to join (true)
                -- If you want to block the connection, set it to false
                callback(true) -- Change this
            end
        else
            print("Error making request to the Steam API. Status code: " .. statusCode)
        end
    end, "GET", "", { ["Content-Type"] = "application/json" })
end

function QuitarSteam(hex)
    return string.gsub(hex, "steam:", "")
end

function hexToSteamID64(hex)
    local dec = tonumber(hex, 16)
    return dec
end

function Log(message)
    title = "Loud | Player Trust System"
    local webHook = ""
    local embedData = {{
        ['title'] = title,
        ['footer'] = {
            ['text'] = "Loud | " .. os.date("%d/%m/%Y %X %p"),
            ['icon_url'] = "https://cdn.discordapp.com/attachments/1138360597256355911/1141890710879080488/88127058.png"
        },
        ['description'] = message,
        ['author'] = {
            ['name'] = "Loud",
            ['icon_url'] = "https://cdn.discordapp.com/attachments/1138360597256355911/1141890710879080488/88127058.png"
        }
    }}
    PerformHttpRequest(webHook, nil, 'POST', json.encode({
        username = 'Logs',
        embeds = embedData
    }), {
        ['Content-Type'] = 'application/json'
    })
end
