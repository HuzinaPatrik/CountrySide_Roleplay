local blackJackTablesInUse = {}
local blackJackTablesInUseByElement = {}

function openBlackJackTable(tableId, element)
    if isElement(client) and isElement(element) then 
        if not blackJackTablesInUse[tableId] then 
            local sourcePlayer = client

            blackJackTablesInUse[tableId] = sourcePlayer
            blackJackTablesInUseByElement[sourcePlayer] = tableId

            local newRot = exports.cr_core:findRotation(sourcePlayer.position.x, sourcePlayer.position.y, element.position.x, element.position.y)
            client.rotation = Vector3(0, 0, newRot)

            triggerClientEvent(sourcePlayer, "blackJack.openBlackJackTable", sourcePlayer, element)
            setPedAnimation(sourcePlayer, "casino", "roulette_in", -1, false, false, false)
            setTimer(setPedAnimation, 550, 1, sourcePlayer, "casino", "roulette_loop", -1, true, false, false)
        else
            local syntax = exports.cr_core:getServerSyntax("Blackjack", "error")

            outputChatBox(syntax .. "Ez az asztal már használatban van.", client, 255, 0, 0, true)
        end
    end
end
addEvent("blackJack.openBlackJackTable", true)
addEventHandler("blackJack.openBlackJackTable", root, openBlackJackTable)

function closeBlackJackPanel(tableId)
    if isElement(client) then 
        if blackJackTablesInUse[tableId] and blackJackTablesInUse[tableId] == client then 
            blackJackTablesInUse[tableId] = nil
            blackJackTablesInUseByElement[client] = nil

            client:setData("forceAnimation", {"", ""})
            setPedAnimation(client, "casino", "roulette_out", 1500, false, false, false, false)
        end
    end
end
addEvent("blackJack.closeBlackJackPanel", true)
addEventHandler("blackJack.closeBlackJackPanel", root, closeBlackJackPanel)

function onQuit()
    if blackJackTablesInUseByElement[source] then 
        local tableId = blackJackTablesInUseByElement[source]

        if blackJackTablesInUse[tableId] then 
            blackJackTablesInUse[tableId] = nil
        end

        blackJackTablesInUseByElement[source] = nil
    end
end
addEventHandler("onPlayerQuit", root, onQuit)