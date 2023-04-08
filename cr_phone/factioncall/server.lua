local factionCallCache = {}
local factionCallElementCache = {}
local factionCallElementCacheByElement = {}
local allFactionCall = {}

function callFaction(calledFaction, calledFactionFrom, index)
    if isElement(client) and calledFaction and calledFactionFrom then 
        local calledFactionFrom = calledFactionFrom or "Ismeretlen"
        local factionData = index and factionCalls[calledFaction][index] or factionCalls[calledFaction]

        if factionData then 
            local factionId = factionData.factionId
            local commandName = factionData.commandName
            local dispatchColor = factionData.dispatchColor or "red"
            local name = factionData.name

            if factionId then 
                local syntax = utf8.sub(dispatchColor, 1, 1) == "#" and exports.cr_core:getServerSyntax("Dispatcher", "red"):gsub("#......", dispatchColor) .. white or exports.cr_core:getServerSyntax("Dispatcher", dispatchColor)
                local hexColor = exports.cr_core:getServerColor("yellow", true)

                if not factionCallCache[factionId] then 
                    factionCallCache[factionId] = {}
                end

                if not factionCallElementCache[factionId] then 
                    factionCallElementCache[factionId] = {}
                end

                if not allFactionCall[factionId] then 
                    allFactionCall[factionId] = 0
                end

                if not factionCallElementCache[factionId][client] then 
                    local callId = allFactionCall[factionId] + 1

                    allFactionCall[factionId] = callId

                    if not factionCallCache[factionId][callId] then 
                        factionCallCache[factionId][callId] = {calledFactionFrom = calledFactionFrom, calledAt = os.time(), calledElement = client, calledFactionId = factionId, callId = callId, accepted = false, dispatchColor = dispatchColor}
                    end

                    factionCallElementCache[factionId][client] = callId

                    if not factionCallElementCacheByElement[client] then 
                        factionCallElementCacheByElement[client] = {}
                    end

                    table.insert(factionCallElementCacheByElement[client], {
                        factionId = factionId,
                        callId = callId
                    })

                    exports.cr_dashboard:sendMessageToFaction(factionId, syntax .. "Egy újabb hívás érkezett, az elfogadáshoz " .. hexColor .. "/" .. commandName:gsub("@A", callId) .. white .. " vagy " .. hexColor .. "/" .. commandName:gsub("@A", "auto"))
                    exports.cr_dashboard:sendMessageToFaction(factionId, syntax .. "Segélykérő telefonszáma: " .. hexColor .. formatPhoneNumber(calledFactionFrom))
                    exports.cr_dashboard:sendMessageToFaction(factionId, syntax .. "Helyszín: " .. hexColor .. getZoneName(client.position))

                    if factionId == 2 then 
                        local localName = exports.cr_admin:getAdminName(client)

                        exports.cr_dashboard:sendMessageToFaction(factionId, syntax .. "Segélykérő neve: " .. hexColor .. localName)
                    end

                    exports.cr_infobox:addBox(client, "success", "A hívásod sikeresen továbbítva lett a(z) " .. name .. " felé!")
                else 
                    local syntax = exports.cr_core:getServerSyntax("Dispatcher", "info")
                    local callId = factionCallElementCache[factionId][client]
                    local callData = factionCallCache[factionId][callId]
                    local accepted = callData.accepted

                    factionCallCache[factionId][callId] = nil
                    factionCallElementCache[factionId][client] = nil

                    for k, v in pairs(factionCallElementCacheByElement[client]) do 
                        if v.factionId == factionId then 
                            table.remove(factionCallElementCacheByElement[client], k)
                            break
                        end
                    end

                    -- iprint("factionCallCache", factionCallCache)
                    -- iprint("factionCallElementCache", factionCallElementCache)
                    -- iprint("factionCallElementCacheByElement", factionCallElementCacheByElement)

                    outputChatBox(syntax .. "Neked már volt egy meglévő hívásod a szervezet felé, ezért az lemondásra került.", client, 255, 0, 0, true)

                    local syntax = utf8.sub(dispatchColor, 1, 1) == "#" and exports.cr_core:getServerSyntax("Dispatcher", "red"):gsub("#......", dispatchColor) .. white or exports.cr_core:getServerSyntax("Dispatcher", dispatchColor)
                    local hexColor = exports.cr_core:getServerColor("yellow", true)

                    exports.cr_dashboard:sendMessageToFaction(factionId, syntax .. "A(z) " .. hexColor .. callId .. ". " .. white .. "számú hívást lemondták.")

                    if isElement(accepted) then 
                        triggerClientEvent(accepted, "phone.destroyMarkerAndBlip", accepted)
                    end
                end
            end
        end
    end
end
addEvent("phone.callFaction", true)
addEventHandler("phone.callFaction", root, callFaction)

function deleteFactionCall(sourceFactionId, sourceCallId, ignoreMessage, playerElement)
    if isElement(client) and sourceFactionId and sourceCallId then 
        local factionData = factionCallCache[sourceFactionId][sourceCallId]
        local dispatchColor = factionData.dispatchColor

        factionCallCache[sourceFactionId][sourceCallId] = nil
        factionCallElementCache[sourceFactionId][playerElement] = nil
        
        for k, v in pairs(factionCallElementCacheByElement[playerElement]) do 
            if v.factionId == sourceFactionId then 
                table.remove(factionCallElementCacheByElement[playerElement], k)
                break
            end
        end

        -- iprint("factionCallCache", factionCallCache)
        -- iprint("factionCallElementCache", factionCallElementCache)
        -- iprint("factionCallElementCacheByElement", factionCallElementCacheByElement)

        if not ignoreMessage then 
            local localName = exports.cr_admin:getAdminName(client)
            local hexColor = exports.cr_core:getServerColor("yellow", true)
            local syntax = utf8.sub(dispatchColor, 1, 1) == "#" and exports.cr_core:getServerSyntax("Dispatcher", "red"):gsub("#......", dispatchColor) .. white or exports.cr_core:getServerSyntax("Dispatcher", dispatchColor)

            exports.cr_dashboard:sendMessageToFaction(sourceFactionId, syntax .. hexColor .. localName .. white .. " megérkezett a(z) " .. hexColor .. sourceCallId .. ". " .. white .. "számú hívásra.")
        end
    end
end
addEvent("phone.deleteFactionCall", true)
addEventHandler("phone.deleteFactionCall", root, deleteFactionCall)

function onCallerQuit()
    local tbl = factionCallElementCacheByElement[source]

    if tbl then 
        local thePlayer = source

        for k, v in pairs(tbl) do 
            local factionId = v.factionId
            local callId = v.callId

            if factionId and callId then 
                factionCallCache[factionId][callId] = nil
                factionCallElementCache[factionId][thePlayer] = nil
                factionCallElementCacheByElement[thePlayer] = nil
            end
        end
    end
end
addEventHandler("onPlayerQuit", root, onCallerQuit)

function acceptSheriffCommand(thePlayer, cmd, callId)
    if thePlayer:getData("loggedIn") then 
        local factionId = 1

        if exports.cr_dashboard:isPlayerInFaction(thePlayer, factionId) then 
            if not callId and callId ~= "auto" then 
                local syntax = exports.cr_core:getServerSyntax(false, "yellow")

                outputChatBox(syntax .. "/" .. cmd .. " [hívás id vagy auto]", thePlayer, 255, 0, 0, true)
                return
            end

            local callId = callId == "auto" and (allFactionCall[factionId] and allFactionCall[factionId] or -1) or tonumber(callId)

            if not callId then 
                local syntax = exports.cr_core:getServerSyntax("Dispatcher", "error")

                outputChatBox(syntax .. "Csak szám.", thePlayer, 255, 0, 0, true)
                return
            end

            if not factionCallCache[factionId] or not factionCallCache[factionId][callId] then 
                local syntax = exports.cr_core:getServerSyntax("Dispatcher", "error")

                outputChatBox(syntax .. "Nem található hívás ezzel az id-vel.", thePlayer, 255, 0, 0, true)
                return
            end

            local callData = factionCallCache[factionId][callId]
            local dispatchColor = callData.dispatchColor or "red"

            if callData.accepted then 
                local syntax = exports.cr_core:getServerSyntax("Dispatcher", "error")

                outputChatBox(syntax .. "Ezt a hívást már elfogadták.", thePlayer, 255, 0, 0, true)
                return
            end

            if callData.calledElement == thePlayer then 
                local syntax = exports.cr_core:getServerSyntax("Dispatcher", "error")

                outputChatBox(syntax .. "A saját hívásodat nem fogadhatod el.", thePlayer, 255, 0, 0, true)
                return
            end

            callData.accepted = thePlayer
            factionCallCache[factionId][callId] = callData

            local syntax = utf8.sub(dispatchColor, 1, 1) == "#" and exports.cr_core:getServerSyntax("Dispatcher", "red"):gsub("#......", dispatchColor) .. white or exports.cr_core:getServerSyntax("Dispatcher", dispatchColor)
            local hexColor = exports.cr_core:getServerColor("yellow", true)
            local localName = exports.cr_admin:getAdminName(thePlayer)

            exports.cr_dashboard:sendMessageToFaction(factionId, syntax .. hexColor .. localName .. white .. " elfogadta a(z) " .. hexColor .. callId .. ". " .. white .. "számú hívást.")
            exports.cr_infobox:addBox(callData.calledElement, "info", "A hívásodat elfogadták.")
            triggerClientEvent(thePlayer, "phone.createCallMarker", thePlayer, factionCallCache[factionId][callId])
        end
    end
end
addCommandHandler("acceptsheriff", acceptSheriffCommand, false, false)

function acceptMedicCommand(thePlayer, cmd, callId)
    if thePlayer:getData("loggedIn") then 
        local factionId = 2

        if exports.cr_dashboard:isPlayerInFaction(thePlayer, factionId) then 
            if not callId and callId ~= "auto" then 
                local syntax = exports.cr_core:getServerSyntax(false, "yellow")

                outputChatBox(syntax .. "/" .. cmd .. " [hívás id vagy auto]", thePlayer, 255, 0, 0, true)
                return
            end

            local callId = callId == "auto" and (allFactionCall[factionId] and allFactionCall[factionId] or -1) or tonumber(callId)

            if not callId then 
                local syntax = exports.cr_core:getServerSyntax("Dispatcher", "error")

                outputChatBox(syntax .. "Csak szám.", thePlayer, 255, 0, 0, true)
                return
            end

            if not factionCallCache[factionId] or not factionCallCache[factionId][callId] then 
                local syntax = exports.cr_core:getServerSyntax("Dispatcher", "error")

                outputChatBox(syntax .. "Nem található hívás ezzel az id-vel.", thePlayer, 255, 0, 0, true)
                return
            end

            local callData = factionCallCache[factionId][callId]
            local dispatchColor = callData.dispatchColor or "red"

            if callData.accepted then 
                local syntax = exports.cr_core:getServerSyntax("Dispatcher", "error")

                outputChatBox(syntax .. "Ezt a hívást már elfogadták.", thePlayer, 255, 0, 0, true)
                return
            end

            if callData.calledElement == thePlayer then 
                local syntax = exports.cr_core:getServerSyntax("Dispatcher", "error")

                outputChatBox(syntax .. "A saját hívásodat nem fogadhatod el.", thePlayer, 255, 0, 0, true)
                return
            end

            callData.accepted = thePlayer
            factionCallCache[factionId][callId] = callData

            local syntax = utf8.sub(dispatchColor, 1, 1) == "#" and exports.cr_core:getServerSyntax("Dispatcher", "red"):gsub("#......", dispatchColor) .. white or exports.cr_core:getServerSyntax("Dispatcher", dispatchColor)
            local hexColor = exports.cr_core:getServerColor("yellow", true)
            local localName = exports.cr_admin:getAdminName(thePlayer)

            exports.cr_dashboard:sendMessageToFaction(factionId, syntax .. hexColor .. localName .. white .. " elfogadta a(z) " .. hexColor .. callId .. ". " .. white .. "számú hívást.")
            exports.cr_infobox:addBox(callData.calledElement, "info", "A hívásodat elfogadták.")
            triggerClientEvent(thePlayer, "phone.createCallMarker", thePlayer, factionCallCache[factionId][callId])
        end
    end
end
addCommandHandler("acceptmedic", acceptMedicCommand, false, false)

function acceptTaxiCommand(thePlayer, cmd, callId)
    if thePlayer:getData("loggedIn") then 
        local factionId = 5

        if exports.cr_dashboard:isPlayerInFaction(thePlayer, factionId) then 
            if not callId and callId ~= "auto" then 
                local syntax = exports.cr_core:getServerSyntax(false, "yellow")

                outputChatBox(syntax .. "/" .. cmd .. " [hívás id vagy auto]", thePlayer, 255, 0, 0, true)
                return
            end

            local callId = callId == "auto" and (allFactionCall[factionId] and allFactionCall[factionId] or -1) or tonumber(callId)

            if not callId then 
                local syntax = exports.cr_core:getServerSyntax("Dispatcher", "error")

                outputChatBox(syntax .. "Csak szám.", thePlayer, 255, 0, 0, true)
                return
            end

            if not factionCallCache[factionId] or not factionCallCache[factionId][callId] then 
                local syntax = exports.cr_core:getServerSyntax("Dispatcher", "error")

                outputChatBox(syntax .. "Nem található hívás ezzel az id-vel.", thePlayer, 255, 0, 0, true)
                return
            end

            local callData = factionCallCache[factionId][callId]
            local dispatchColor = callData.dispatchColor or "red"

            if callData.accepted then 
                local syntax = exports.cr_core:getServerSyntax("Dispatcher", "error")

                outputChatBox(syntax .. "Ezt a hívást már elfogadták.", thePlayer, 255, 0, 0, true)
                return
            end

            if callData.calledElement == thePlayer then 
                local syntax = exports.cr_core:getServerSyntax("Dispatcher", "error")

                outputChatBox(syntax .. "A saját hívásodat nem fogadhatod el.", thePlayer, 255, 0, 0, true)
                return
            end

            callData.accepted = thePlayer
            factionCallCache[factionId][callId] = callData

            local syntax = utf8.sub(dispatchColor, 1, 1) == "#" and exports.cr_core:getServerSyntax("Dispatcher", "red"):gsub("#......", dispatchColor) .. white or exports.cr_core:getServerSyntax("Dispatcher", dispatchColor)
            local hexColor = exports.cr_core:getServerColor("yellow", true)
            local localName = exports.cr_admin:getAdminName(thePlayer)

            exports.cr_dashboard:sendMessageToFaction(factionId, syntax .. hexColor .. localName .. white .. " elfogadta a(z) " .. hexColor .. callId .. ". " .. white .. "számú hívást.")
            exports.cr_infobox:addBox(callData.calledElement, "info", "A hívásodat elfogadták.")
            triggerClientEvent(thePlayer, "phone.createCallMarker", thePlayer, factionCallCache[factionId][callId])
        end
    end
end
addCommandHandler("accepttaxi", acceptTaxiCommand, false, false)

function acceptMechanicCommand(thePlayer, cmd, callId)
    if thePlayer:getData("loggedIn") then 
        local factionId = 3

        if exports.cr_dashboard:isPlayerInFaction(thePlayer, factionId) then 
            if not callId and callId ~= "auto" then 
                local syntax = exports.cr_core:getServerSyntax(false, "yellow")

                outputChatBox(syntax .. "/" .. cmd .. " [hívás id vagy auto]", thePlayer, 255, 0, 0, true)
                return
            end

            local callId = callId == "auto" and (allFactionCall[factionId] and allFactionCall[factionId] or -1) or tonumber(callId)

            if not callId then 
                local syntax = exports.cr_core:getServerSyntax("Dispatcher", "error")

                outputChatBox(syntax .. "Csak szám.", thePlayer, 255, 0, 0, true)
                return
            end

            if not factionCallCache[factionId] or not factionCallCache[factionId][callId] then 
                local syntax = exports.cr_core:getServerSyntax("Dispatcher", "error")

                outputChatBox(syntax .. "Nem található hívás ezzel az id-vel.", thePlayer, 255, 0, 0, true)
                return
            end

            local callData = factionCallCache[factionId][callId]
            local dispatchColor = callData.dispatchColor or "red"

            if callData.accepted then 
                local syntax = exports.cr_core:getServerSyntax("Dispatcher", "error")

                outputChatBox(syntax .. "Ezt a hívást már elfogadták.", thePlayer, 255, 0, 0, true)
                return
            end

            if callData.calledElement == thePlayer then 
                local syntax = exports.cr_core:getServerSyntax("Dispatcher", "error")

                outputChatBox(syntax .. "A saját hívásodat nem fogadhatod el.", thePlayer, 255, 0, 0, true)
                return
            end

            callData.accepted = thePlayer
            factionCallCache[factionId][callId] = callData

            local syntax = utf8.sub(dispatchColor, 1, 1) == "#" and exports.cr_core:getServerSyntax("Dispatcher", "red"):gsub("#......", dispatchColor) .. white or exports.cr_core:getServerSyntax("Dispatcher", dispatchColor)
            local hexColor = exports.cr_core:getServerColor("yellow", true)
            local localName = exports.cr_admin:getAdminName(thePlayer)

            exports.cr_dashboard:sendMessageToFaction(factionId, syntax .. hexColor .. localName .. white .. " elfogadta a(z) " .. hexColor .. callId .. ". " .. white .. "számú hívást.")
            exports.cr_infobox:addBox(callData.calledElement, "info", "A hívásodat elfogadták.")
            triggerClientEvent(thePlayer, "phone.createCallMarker", thePlayer, factionCallCache[factionId][callId])
        end
    end
end
addCommandHandler("acceptmechanic", acceptMechanicCommand, false, false)