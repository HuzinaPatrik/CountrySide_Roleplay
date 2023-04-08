local cinemaStart = 0
local currentVodId = false
local currentMovieIndex = false
local lastCinemaSync = {}

function startMovie(thePlayer, vodId)
    local players = getElementsByType("player")

    cinemaStart = getTickCount()
    currentVodId = vodId

    triggerClientEvent(players, "cinema.onCinemaStart", thePlayer, vodId, 0, currentMovieIndex)
end

function stopMovie(thePlayer)
    local players = getElementsByType("player")

    cinemaStart = 0
    currentVodId = false
    currentMovieIndex = false

    triggerClientEvent(players, "cinema.onCinemaStop", thePlayer)
end

function startCinemaCommand(thePlayer, cmd, vodId)
    if exports.cr_permission:hasPermission(thePlayer, cmd) then 
        if not vodId then 
            local syntax = exports.cr_core:getServerSyntax(false, "lightyellow")

            outputChatBox(syntax .. "/" .. cmd .. " [videó id a ?v= után]", thePlayer, 255, 0, 0, true)
            return
        end

        local vodId = tostring(vodId)
        
        startMovie(thePlayer, vodId)
    end
end
addCommandHandler("startcinema", startCinemaCommand, false, false)

function syncCinemaCommand(thePlayer)
    if thePlayer:getData("loggedIn") then 
        if currentVodId then 
            if not lastCinemaSync[thePlayer] then 
                lastCinemaSync[thePlayer] = 0
            end

            if getTickCount() - lastCinemaSync[thePlayer] >= 10000 then 
                syncCinema(thePlayer)

                lastCinemaSync[thePlayer] = getTickCount()
            end
        end
    end
end
addCommandHandler("synccinema", syncCinemaCommand, false, false)

function onJoin()
    syncCinema(source)
end
addEventHandler("onPlayerJoin", root, onJoin)

function onQuit()
    if lastCinemaSync[source] then 
        lastCinemaSync[source] = nil
    end
end
addEventHandler("onPlayerQuit", root, onQuit)

function syncCinema(thePlayer)
    local thePlayer = client or thePlayer

    if isElement(thePlayer) and currentVodId then 
        triggerClientEvent(thePlayer, "cinema.onCinemaStart", thePlayer, currentVodId, getTickCount() - cinemaStart, currentMovieIndex)
    end
end
addEvent("cinema.sync", true)
addEventHandler("cinema.sync", root, syncCinema)

function startMovieHandler(vodId, hoverMovieIndex)
    if isElement(client) then 
        currentMovieIndex = hoverMovieIndex

        startMovie(client, vodId)
    end
end
addEvent("cinema.startMovie", true)
addEventHandler("cinema.startMovie", root, startMovieHandler)

function stopMovieHandler()
    if isElement(client) then 
        stopMovie(client)
    end
end
addEvent("cinema.stopMovie", true)
addEventHandler("cinema.stopMovie", root, stopMovieHandler)