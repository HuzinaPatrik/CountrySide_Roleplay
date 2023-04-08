factionCache = {}
function returnFactionData(element, factionID, data, typ)
    if typ == "all" then
        factionCache[factionID] = data 

        local breaked = false 
        if isElement(element) then 
            if cache["element"] == element then 
                breaked = true
            end 
        elseif type(element) == "table" then 
            for k,v in pairs(element) do 
                if cache["element"] == v then 
                    breaked = true 
                    break 
                end 
            end 
        end 

        if breaked then
            if data[3][tonumber(cache["playerDatas"]["accId"] or localPlayer:getData("acc >> id"))] then 
                local factions = {}
                if cache["playerDatas"] and cache["playerDatas"]["faction"] then 
                    factions = cache["playerDatas"]["faction"]
                end 

                local players = {}
                for k,v in pairs(data[3]) do 
                    table.insert(players, {v[1], v[2], v[7]})
                end 

                table.sort(players, 
                    function(a, b)
                        if a[3] > b[3] then 
                            return a[3] > b[3]
                        elseif a[3] == b[3] then 
                            return a[2] < b[2]
                        else 
                            return false
                        end 
                    end
                )

                data["players"] = players 

                alreadyInserted = false
                for k,v in pairs(factions) do 
                    if v[1] == data[1] then 
                        alreadyInserted = true 
                        factions[k] = data
                    end 
                end 

                if not alreadyInserted then 
                    table.insert(factions, data)
                end

                table.sort(factions, 
                    function(a, b)
                        if a[1] and b[1] then
                            return tonumber(a[1]) < tonumber(b[1])
                        end
                    end
                )

                if cache["page"] == 3 and state then 
                    if not cache["playerDatas"]["faction"] or #cache["playerDatas"]["faction"] == 0 then 
                        triggerLatentServerEvent("openFactionPanel", 5000, false, localPlayer, factionID, localPlayer)
                    end 
                end

                cache["playerDatas"]["faction"] = factions

                generateFactionInformations(cache["playerDatas"]["faction"][selectedFaction])
                getFactionVehicles(cache["playerDatas"]["faction"][selectedFaction][1])

                if factionsSelected == 2 then 
                    if factionRankUpdated and not factionMembersSearchCache then 
                        for k,v in pairs(cache["playerDatas"]["faction"][selectedFaction]["players"]) do 
                            if v[1] == factionRankUpdated then 
                                factionMembersSelected = k
                                factionRankUpdated = nil
                                break 
                            end 
                        end 
                    end 

                    local data = cache["playerDatas"]["faction"][selectedFaction]["players"][factionMembersSelected]
                    if factionMembersSearchCache then 
                        data = factionMembersSearchCache[factionMembersSelected]
                    end 
                    if not data or not cache["playerDatas"]["faction"][selectedFaction][3][data[1]] then 
                        factionMembersSelected = 1
                    end 
                    getFactionMemberInfos(factionMembersSelected)
                    getMyFactionMemberInfos(cache["playerDatas"]["accId"])
                elseif factionsSelected == 3 then 
                    if not data or not cache["playerDatas"]["faction"][selectedFaction][4][factionRanksSelected] then 
                        factionRanksSelected = 1
                    end 

                    if factionRanksUpdated and not factionRanksSearchCache then 
                        for k,v in pairs(cache["playerDatas"]["faction"][selectedFaction][4]) do 
                            if k == factionRanksUpdated then 
                                factionRanksSelected = k
                                factionRanksUpdated = nil
                                break 
                            end 
                        end 
                    end 

                    getFactionRankInfos(factionRanksSelected)
                end 
            end 
        end
    elseif typ == "request" then 
        factionCache[factionID] = data 
    elseif typ == "clear" then 
        local factions = {}
        if cache["playerDatas"] and cache["playerDatas"]["faction"] then 
            factions = cache["playerDatas"]["faction"]
        end 

        for k,v in pairs(factions) do 
            if v[1] == factionID then 
                --factions[k] = nil 
                table.remove(factions, k)
                break
                --collectgarbage("collect")
            end 
        end 

        if factionCache[factionID] then 
            if factionCache[factionID][3] then 
                if factionCache[factionID][3][localPlayer:getData("acc >> id")] then 
                    factionCache[factionID][3][localPlayer:getData("acc >> id")] = nil
                end 
            end 
        end 
        
        local breaked = false
        for k,v in pairs(factions) do 
            breaked = true 
        end 

        if not breaked then
            factions = {}
        else 
            table.sort(factions, 
                function(a, b)
                    if a[1] and b[1] then
                        return tonumber(a[1]) < tonumber(b[1])
                    end
                end
            )
        end 

        if not factions[selectedFaction] then 
            selectedFaction = 1 

            if factions[selectedFaction] then 
                generateFactionInformations(cache["playerDatas"]["faction"][selectedFaction])
                getFactionVehicles(cache["playerDatas"]["faction"][selectedFaction][1])
            end 
        end 

        cache["playerDatas"]["faction"] = factions        

        if cache["page"] == 3 and state then 
            if not cache["playerDatas"]["faction"] or #cache["playerDatas"]["faction"] == 0 then 
                triggerLatentServerEvent("closeFactionPanel", 5000, false, localPlayer, factionID, localPlayer)
            end 

            Clear()
        end
    end
end
addEvent("returnFactionData", true)
addEventHandler("returnFactionData", root, returnFactionData)

local lastCall = -1
local lastCallTick = -5000
function getFactionData(element, factionID)
    local now = getTickCount()
    if now <= lastCallTick + 1000 then
        cancelLatentEvent(lastCall)
    end 
    if tonumber(factionID) then 
        triggerLatentServerEvent("getFactionData", 1000, false, localPlayer, localPlayer, localPlayer, factionID, "all")
    else 
        triggerLatentServerEvent("checkPlayerFaction", 1000, false, localPlayer, element)
    end 
    lastCall = getLatentEventHandles()[#getLatentEventHandles()] 
    lastCallTick = getTickCount()
end

function inviteToFaction(sourcePlayer, factionID, factionName)
    if isElement(sourcePlayer) and tonumber(factionID) then 
        local blue = exports['cr_core']:getServerColor("yellow", true)
        local red = exports['cr_core']:getServerColor("red", true)
        local white = "#F2F2F2"
        local r,g,b = exports['cr_core']:getServerColor("green")
        local r2,g2,b2 = exports['cr_core']:getServerColor("red")
        
        createAlert(
            {
                ['headerText'] = 'Frakció',
                ["title"] = {white .. blue .. exports['cr_admin']:getAdminName(sourcePlayer) .. white .." meghívott a ".. blue .. factionName .. white .. " nevű frakcióba!"},
                ["buttons"] = {
                    {
                        ["name"] = "Elfogadás", 
                        ["pressFunc"] = function()
                            triggerLatentServerEvent("addPlayerToFaction", 5000, false, localPlayer, localPlayer:getData("acc >> id"), factionID, 0)

                            exports['cr_infobox']:addBox("success", "Sikeresen csatlakoztál "..factionName.." nevű frakcióba!")
                        end,
                        ["onCreate"] = function()
                            sourcePlayer = sourcePlayer
                            factionID = factionID
                            factionName = factionName
                        end,
                        ["color"] = {r,g,b},
                    },

                    {
                        ["name"] = "Elutasítás", 
                        ["onClear"] = true,
                        ["pressFunc"] = function()
                        end,
                        ["color"] = {r2, g2, b2},
                    },
                },
            }
        )
    end 
end
addEvent("inviteToFaction", true)
addEventHandler("inviteToFaction", root, inviteToFaction)

addEventHandler("onClientElementDataChange", localPlayer,
    function(dName, oValue, nValue)
        if dName == "loggedIn" then
            if nValue then
                getFactionData(localPlayer)
            end
        end
    end
)

addEventHandler("onClientResourceStart", resourceRoot, 
    function()
        if localPlayer:getData("loggedIn") then 
            getFactionData(localPlayer)
        end 
    end 
)

local lastCall = -1
local lastCallTick = -5000
function isPlayerInFaction(player, factionID)
    if isElement(player) then 
        player = player:getData("acc >> id")
    end 

    if tonumber(player) and tonumber(factionID) then 
        if factionCache[factionID] then 
            for k,v in pairs(factionCache[factionID][3]) do 
                if tonumber(k) == tonumber(player) then 
                    return true 
                end 
            end 
        else 
            local now = getTickCount()
            if now <= lastCallTick + 1000 then
                cancelLatentEvent(lastCall)
            end 
            triggerLatentServerEvent("getFactionData", 1000, false, localPlayer, localPlayer, localPlayer, factionID, "request")
            lastCall = getLatentEventHandles()[#getLatentEventHandles()] 
            lastCallTick = getTickCount()
        end 
    end 

    return false 
end 

function isPlayerInFactionType(player, factionType)
    if isElement(player) then 
        player = player:getData("acc >> id")
    end 

    if tonumber(player) and tonumber(factionType) then 
        for k,v in pairs(factionCache) do 
            if v[3] and v[3][tonumber(player)] then 
                if v[5] == tonumber(factionType) then 
                    return true
                end 
            end 
        end 
    end 

    return false 
end 

local lastCall = -1
local lastCallTick = -5000
function isPlayerFactionLeader(player, factionID)
    if isElement(player) then 
        player = player:getData("acc >> id")
    end 

    if tonumber(player) and tonumber(factionID) then 
        if factionCache[factionID] then 
            for k,v in pairs(factionCache[factionID][3]) do 
                if tonumber(k) == tonumber(player) then 
                    if v[3] == 1 then 
                        return true 
                    end
                end 
            end 
        else 
            local now = getTickCount()
            if now <= lastCallTick + 1000 then
                cancelLatentEvent(lastCall)
            end 
            triggerLatentServerEvent("getFactionData", 1000, false, localPlayer, localPlayer, localPlayer, factionID, "request")
            lastCall = getLatentEventHandles()[#getLatentEventHandles()] 
            lastCallTick = getTickCount()
        end 
    end 

    return false 
end 

function getPlayerFactions(player)
    local factions = {}
    if isElement(player) then 
        if player:getData("loggedIn") then 
            for k,v in pairs(factionCache) do 
                if v[3][player:getData("acc >> id")] then 
                    table.insert(factions, v[1])
                end 
            end 
        end 
    elseif tonumber(player)  then 
        for k,v in pairs(factionCache) do 
            if v[3][tonumber(player)] then 
                table.insert(factions, v[1])
            end 
        end 
    end 

    return factions 
end 

function sendMessageToFaction(factionID, text)
    if tonumber(factionID) then
        triggerLatentServerEvent("sendMessageToFaction", 5000, false, localPlayer, factionID, text)
    end 
end 

function getFactionBankMoney(factionID)
    if tonumber(factionID) then
        if factionCache[factionID] then 
            return factionCache[factionID][6]
        end 
    end 
end 

function getFactionType(factionID)
    if tonumber(factionID) then
        if factionCache[factionID] then 
            return factionCache[factionID][5]
        end 
    end 
end 

function getFactionMembers(factionID)
    if tonumber(factionID) then 
        if factionCache[factionID] then 
            return factionCache[factionID][3]
        end 
    end 
end 

function getPlayerFactionRank(player, factionID)
    local rank
    if isElement(player) then 
        if player:getData("loggedIn") then 
            if factionCache[factionID] then 
                local playerData = factionCache[factionID][3][player:getData("acc >> id")]

                rank = playerData[7]
            end 
        end 
    elseif tonumber(player) then 
        if factionCache[factionID] then 
            local playerData = factionCache[factionID][3][tonumber(player)]

            rank = playerData[7]
        end 
    end 

    return rank 
end 

function getPlayerFactionRankName(player, factionID)
    local rank
    if isElement(player) then 
        if player:getData("loggedIn") then 
            if factionCache[factionID] then 
                local playerData = factionCache[factionID][3][player:getData("acc >> id")]
                local playerRank = playerData[7]
                local factionRanks = factionCache[factionID][4]

                rank = factionRanks[playerRank]["name"]
            end 
        end 
    elseif tonumber(player) then 
        if factionCache[factionID] then 
            local playerData = factionCache[factionID][3][player:getData("acc >> id")]
            local playerRank = playerData[7]
            local factionRanks = factionCache[factionID][4]

            rank = factionRanks[playerRank]["name"]
        end 
    end 

    return rank 
end 

function getFactionName(factionID)
    local name

    if tonumber(factionID) and factionCache[tonumber(factionID)] then 
        local factionData = factionCache[tonumber(factionID)]

        name = factionData[2]
    end

    return name
end 

function getPlayerFactionRankPayment(player, factionID)
    local payment
    if isElement(player) then 
        if player:getData("loggedIn") then 
            if factionCache[factionID] then 
                local playerData = factionCache[factionID][3][player:getData("acc >> id")]

                payment = factionCache[factionID][4][playerData[7]]["payment"]
            end 
        end 
    elseif tonumber(player) then 
        if factionCache[factionID] then 
            local playerData = factionCache[factionID][3][tonumber(player)]

            payment = factionCache[factionID][4][playerData[7]]["payment"]
        end 
    end 

    return payment 
end 

function hasPlayerPermission(player, factionID, perm)
    local hasPerm = false
    if isElement(player) then 
        if player:getData("loggedIn") then 
            if not factionID or type(factionID) == 'string' and factionID == 'all' then 
                local factions = getPlayerFactions(player)

                for k, factionID in pairs(factions) do 
                    if factionCache[factionID] and factionCache[factionID][3] and factionCache[factionID][3][player:getData("acc >> id")] then 
                        local permissions = factionCache[factionID][3][player:getData("acc >> id")][8]
    
                        if permissions[perm] then 
                            hasPerm = true

                            break 
                        end 
                    end 
                end 
            else 
                if factionCache[factionID] and factionCache[factionID][3] and factionCache[factionID][3][player:getData("acc >> id")] then 
                    local permissions = factionCache[factionID][3][player:getData("acc >> id")][8]

                    hasPerm = permissions[perm]
                end 
            end 
        end 
    elseif tonumber(player) then 
        if not factionID or type(factionID) == 'string' and factionID == 'all' then 
            local factions = getPlayerFactions(player)
            
            for k, factionID in pairs(factions) do 
                if factionCache[factionID] and factionCache[factionID][3] and factionCache[factionID][3][tonumber(player)] then 
                    local permissions = factionCache[factionID][3][tonumber(player)][8]
    
                    if permissions[perm] then 
                        hasPerm = true
                        
                        break
                    end 
                end 
            end
        else 
            if factionCache[factionID] and factionCache[factionID][3] and factionCache[factionID][3][tonumber(player)] then 
                local permissions = factionCache[factionID][3][tonumber(player)][8]

                hasPerm = permissions[perm]
            end 
        end 
    end 

    return hasPerm 
end 

function getFactionRankPayment(factionID, rankID)
    local payment
    if factionCache[factionID] then 
        if factionCache[factionID][4][rankID] then 
            payment = factionCache[factionID][4][rankID]["payment"]
        end
    end 

    return payment 
end 