local ignoredFactionTypes = {
    [3] = true,
    [4] = true
}

function getLegalFactions()
    local factions = exports.cr_dashboard:getAvailableFactions()
    local legalFactions = {}

    for k, v in pairs(factions) do 
        local typ = v[5]

        if not ignoredFactionTypes[typ] then 
            legalFactions[k] = v
        end
    end

    return legalFactions
end

function getLegalFactionsHandler()
    if isElement(client) then 
        local factions = getLegalFactions()
        local syntax = exports.cr_core:getServerSyntax(false, "info")
        local hexColor = exports.cr_core:getServerColor("yellow", true)

        outputChatBox(syntax .. "Legális frakciók:", client, 255, 0, 0, true)

        for k, v in pairs(factions) do 
            outputChatBox(hexColor .. v[2] .. white .. " (" .. hexColor .. v[1] .. white .. ")", client, 255, 0, 0, true)
        end
    end
end
addEvent("getLegalFactionsHandler", true)
addEventHandler("getLegalFactionsHandler", root, getLegalFactionsHandler)

function getFactionDataHandler(cmd, id)
    if client:getData("loggedIn") then 
        local factions = getLegalFactions()

        if not factions[id] then 
            local syntax = exports.cr_core:getServerSyntax(false, "error")

            outputChatBox(syntax .. "Nem található a frakció.", client, 255, 0, 0, true)
            return
        end

        local factionData = factions[id]
        local syntax = exports.cr_core:getServerSyntax(false, "info")
        local hexColor = exports.cr_core:getServerColor("yellow", true)

        outputChatBox(syntax .. "A(z) " .. hexColor .. factionData[2] .. white .. " frakció adatai:", client, 255, 0, 0, true)
        outputChatBox(syntax .. "Bankszámlán lévő összeg: " .. hexColor .. "$" .. exports.cr_dx:formatMoney(factionData[6]), client, 255, 0, 0, true)
        outputChatBox(syntax .. "Alkalmazottak száma: " .. hexColor .. table.count(factionData[3]) .. white .. " db", client, 255, 0, 0, true)
        
        local vehicleCount = exports.cr_vehicle:getFactionVehicleCount(id) or 0
        outputChatBox(syntax .. "Járművek száma: " .. hexColor .. vehicleCount .. white .. " db", client, 255, 0, 0, true)
        outputChatBox(" ", client)

        local ranks = factionData[4]
        
        table.sort(ranks,
            function(a, b)
                return a.payment > b.payment
            end
        )

        outputChatBox(syntax .. "Rangok és fizetések:", client, 255, 0, 0, true)
        for k, v in pairs(ranks) do 
            outputChatBox(syntax .. v.name .. " - " .. hexColor .. "$" .. v.payment, client, 255, 0, 0, true)
        end
    end
end
addEvent("getFactionDataHandler", true)
addEventHandler("getFactionDataHandler", root, getFactionDataHandler)