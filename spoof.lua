local apiKey = ""
local daysThreshold = 15

AddEventHandler('playerConnecting', function(playerName, setKickReason, deferrals)
    deferrals.defer()
    deferrals.update(string.format("Hola %s. Estamos checkeandote!.", playerName))
    local identifiers = GetPlayerIdentifiers(source)
    local steamID64 = QuitarSteam(identifiers[1])
    local steam64 = hexToSteamID64(steamID64)

    if not steam64 then
        deferrals.done("⚠️|  No encontré tu steam, asegurate de abrirlo antes de entrar al servidor❤️")
    else
        checkSteamAccountCreationDate(steam64, function(puede)
            if puede then
                deferrals.done("⚠️ Tu steam no tiene suficiente tiempo de creado.")
            else
                deferrals.done()
            end
        end)
    end
end)

function checkSteamAccountCreationDate(steamId64, callback)
    local apiUrl = "http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=" .. apiKey .. "&steamids=" .. steamId64

    PerformHttpRequest(apiUrl, function(statusCode, response, headers)
        if statusCode == 200 then
            local data = json.decode(response)

            if data and data.response and data.response.players and data.response.players[1] and data.response.players[1].communityvisibilitystate == 3 then
                local accountCreated = tonumber(data.response.players[1].timecreated)
                local currentTime = os.time()
                local daysSinceCreation = (currentTime - accountCreated) / (24 * 60 * 60)
                local accountName = data.response.players[1].personaname

                if daysSinceCreation < daysThreshold then
                    Log("La cuenta de Steam '**" .. accountName .. "** tiene menos de 15 días de antigüedad.\n Tiene " .. daysSinceCreation .. " días desde su creación.")
                    callback(true)
                else
                    --Log("La cuenta de Steam '**" .. accountName .. "** tiene más de 15 días de antigüedad.\n Tiene " .. daysSinceCreation .. " días desde su creación.")
                    callback(false)
                end
            else
                callback(false)
                print("No se pudo obtener información de la cuenta de Steam con ID64 " .. steamId64.. " O el perfil es privado")
            end
        else
            print("Error al hacer la solicitud a la API de Steam. Código de estado: " .. statusCode)
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
    title = "ANTI WEONE | Conexion Bloqueada"
    local webHook = 'https://discord.com/api/webhooks/1178501785795706910/mE8LrHGPZ6RiLBXJFKb0BEQDN3XLaDqYgpx2gmaKrwMVA6PNqxCZ0VGzurYfcWHyWo5E'
    local embedData = {{
        ['title'] = title,
        ['footer'] = {
            ['text'] = "Loud RP | " .. os.date("%d/%m/%Y %X %p"),
            ['icon_url'] = "https://cdn.discordapp.com/attachments/1138360597256355911/1141890710879080488/88127058.png"
        },
        ['description'] = message,
        ['author'] = {
            ['name'] = "Loud RP",
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
