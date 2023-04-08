factionCache = {}
local factionNameCache = {}
local spam = {}
local factionAttach = {}
local factionPlayerAttach = {}
local panelViewers = {}
local panelViewersCache = {}
local panelViewersElementCache = {}

function getFactionData(sendTo, sourcePlayer, factionID, typ)
    if typ == "all" then
        if factionCache[factionID] then 
            local data = fromJSON(toJSON(factionCache[factionID]))
            local players = convertFactionPlayersIntoData(data, factionID)
            data[3] = players
            triggerLatentClientEvent(sendTo, "returnFactionData", 50000, false, sourcePlayer, sendTo, factionID, data, "all")
        end
    elseif typ == "request" then
        if factionCache[factionID] then 
            local data = fromJSON(toJSON(factionCache[factionID]))
            local players = convertFactionPlayersIntoData(data, factionID)
            data[3] = players
            triggerLatentClientEvent(sendTo, "returnFactionData", 50000, false, sourcePlayer, sendTo, factionID, data, "request")
        end
    elseif typ == "clear" then
        triggerLatentClientEvent(sendTo, "returnFactionData", 50000, false, sourcePlayer, sendTo, factionID, nil, "clear")
    end
end
addEvent("getFactionData", true)
addEventHandler("getFactionData", root, getFactionData)

function convertFactionPlayersIntoData(data, factionID)
    local tbl = {}
    for k,v in pairs(data[3]) do 
        local id = tonumber(k)
        local id, playerData, accountData = exports['cr_account']:getPlayerDatasByID(id)
        if playerData then 
            local name = playerData[2]
            local attachID = factionPlayerAttach[id][factionID]
            if attachID then 
                local leader = factionAttach[attachID][4]
                local rank = factionAttach[attachID][5]
                local permissions = factionAttach[attachID][6]
                local dutyskin = factionAttach[attachID][7]
                local online, playerElement = exports['cr_account']:getAccountOnline(id)
                local lastOnline = accountData[6]
                local position = playerData[3]
                if type(position) == "string" then 
                    position = fromJSON(position)
                end 

                local x,y,z = unpack(position)
                if online then 
                    x, y, z = getElementPosition(playerElement)
                end 
                local lastOnlinePlace = getZoneName(x,y,z)
                tbl[tonumber(k)] = {id, name, leader, online, lastOnline, lastOnlinePlace, rank, permissions, dutyskin}
            end
        end 
    end 

    return tbl
end 

function checkPlayerFaction(e)
    if isElement(e) then
        if e:getData("acc >> id") then
            if factionPlayerAttach[e:getData("acc >> id")] then
                for k,v in pairs(factionPlayerAttach[e:getData("acc >> id")]) do 
                    getFactionData(e, e, k, "all")
                end 
            end
        end
    end
end
addEvent("checkPlayerFaction", true)
addEventHandler("checkPlayerFaction", root, checkPlayerFaction)

function loadFaction(row)
    local id = tonumber(row["id"])
    local name = tostring(row["name"])
    local a = fromJSON(tostring(row["players"]))
    local players = {}
    for k,v in pairs(a) do 
        k = tonumber(k) 
        players[k] = v
    end 
    local b = fromJSON(tostring(row["ranks"]))
    local ranks = {}
    for k,v in pairs(b) do 
        k = tonumber(k) 
        ranks[k] = v
    end 
    local logs = fromJSON(tostring(row["logs"]))
    local type = tonumber(row["type"])
    local money = tonumber(row["money"])
    local text = tostring(row["text"])
    factionCache[id] = {id, name, players, ranks, type, money, text, logs}
    factionNameCache[name] = id
end 

function loadFactionAttach(row)
    local id = tonumber(row["id"])
    local playerid = tonumber(row["playerid"])
    local leader = tonumber(row["leader"])
    local factionID = tonumber(row["factionID"])
    local rank = tonumber(row["rank"])
    local permissions = fromJSON(row["permissions"])
    local dutyskin = tonumber(row["dutyskin"])
    factionAttach[id] = {id, factionID, playerid, leader, rank, permissions, dutyskin}
    if not factionPlayerAttach[playerid] then 
        factionPlayerAttach[playerid] = {}
    end 
    factionPlayerAttach[playerid][factionID] = id
end

function checkPlayerDutyStatus(thePlayer, factionId)
    local thePlayer = client or thePlayer

    if isElement(thePlayer) and factionId then 
        if factionCache[factionId] then 
            local factionName = factionCache[factionId][2]
            local players = factionCache[factionId][3]

            if thePlayer:getData("char >> duty") and thePlayer:getData("char >> duty") == factionId then 
                local accountId = thePlayer:getData("acc >> id")

                if not players[accountId] then 
                    triggerLatentClientEvent(thePlayer, "dutyOffHandler", 50000, false, thePlayer, "removedFromFaction", factionName)

                    return true
                end
            end
        end
    end

    return false
end
addEvent("checkPlayerDutyStatus", true)
addEventHandler("checkPlayerDutyStatus", root, checkPlayerDutyStatus)

function loadFactions()
    dbQuery(
        function(query)
            local query, query_lines = dbPoll(query, 0)
            if query_lines > 0 then
                Async:foreach(query, 
                    loadFaction
                )
            end
            outputDebugString("Loading factions finished. Loaded #"..query_lines.." factions!", 0, 255, 50, 255)
        end, 
    connection, "SELECT * FROM `factions`")
    
    dbQuery(
        function(query)
            local query, query_lines = dbPoll(query, 0)
            if query_lines > 0 then
                Async:foreach(query, 
                    loadFactionAttach
                )
            end
            outputDebugString("Loading factionAttach finished. Loaded #"..query_lines.." factionAttach!", 0, 255, 50, 255)
        end, 
    connection, "SELECT * FROM `factionattach`")
end
addEventHandler("onResourceStart", resourceRoot, loadFactions)

function createFaction(sourcePlayer, cmd, name, type, insert)
    if exports['cr_permission']:hasPermission(sourcePlayer, "createfaction") then 
        type = tonumber(type)
        insert = tonumber(insert)
        if not tonumber(insert) then 
            insert = 0
        end 

        if name and tonumber(type) and tonumber(insert) then 
            if tonumber(insert) ~= 0 and tonumber(insert) ~= 1 then 
                local syntax = exports["cr_core"]:getServerSyntax(nil, "error")
                outputChatBox(syntax .. "Az automatikus beillesztésnek 0nak (nem) vagy 1nek (igen) kell lennie!", sourcePlayer, 255, 255, 255, true)
                return 
            elseif not factionTypes[type] then 
                local syntax = exports["cr_core"]:getServerSyntax(nil, "error")
                outputChatBox(syntax .. "Ez a frakció típus nem létezik!", sourcePlayer, 255, 255, 255, true)
                return 
            elseif factionNameCache[name] then 
                local syntax = exports["cr_core"]:getServerSyntax(nil, "error")
                outputChatBox(syntax .. "Ez a frakció név már létezik!", sourcePlayer, 255, 255, 255, true)
                return 
            end 

            name = name:gsub("_", " ")
            local players = {}
            local ranks = {
                {
                    ["name"] = "Alapértelmezett rang",
                    ["payment"] = 0,
                }
            }
            dbExec(connection, "INSERT INTO factions SET name=?, type=?, players=?, ranks=?, money=?, text=?", name, type, toJSON(players), toJSON(ranks), 0, "Alapértelmezett szöveg")
            dbQuery(
                function(query)
                    local query, query_lines = dbPoll(query, 0)
                    if query_lines > 0 then
                        Async:foreach(query, 
                            function(row)
                                loadFaction(row)

                                local syntax = exports['cr_core']:getServerSyntax(nil, "success")
                                local blue = exports['cr_core']:getServerColor('yellow', true)
                                local white = "#ffffff"
                                outputChatBox(syntax .. "Sikeresen létrehoztad a frakciót! (ID: "..blue..tonumber(row["id"])..white..", Név: "..blue..tostring(row["name"])..white..")", sourcePlayer, 255, 255, 255, true)

                                local green = exports['cr_core']:getServerColor("orange", true)
                                local white = "#ffffff"
                                local syntax = exports['cr_admin']:getAdminSyntax()
                                local aName = exports['cr_admin']:getAdminName(sourcePlayer, true)
                                exports['cr_core']:sendMessageToAdmin(sourcePlayer, syntax..green..aName..white.." létrehozott frakciót! (ID: "..blue..tonumber(row["id"])..white..", Név: "..blue..tostring(row["name"])..white..")", 6)
                                exports['cr_logs']:addLog(sourcePlayer, "Faction", "createfaction", syntax..aName.." létrehozott frakciót! (ID: "..tonumber(row["id"])..", Név: "..tostring(row["name"])..")")

                                if insert == 1 then 
                                    addFactionLog(row["id"], exports['cr_core']:getServerColor('yellow', true) .. exports['cr_admin']:getAdminName(sourcePlayer) .. " #F2F2F2létrehozta a frakciót!")
                                    addPlayerToFaction(sourcePlayer:getData("acc >> id"), tonumber(row["id"]), 1)
                                end 
                            end 
                        )
                    end
                    outputDebugString("Loading factions finished. Loaded #"..query_lines.." factions!", 0, 255, 50, 255)
                end, 
            connection, "SELECT * FROM `factions` WHERE name=? AND type=? AND players=? AND ranks=? and money=? and text=?", name, type, toJSON(players), toJSON(ranks), 0, "Alapértelmezett szöveg")
            
        else 
            local syntax = exports["cr_core"]:getServerSyntax(nil, "warning")
            outputChatBox(syntax .. "/"..cmd.." [név (Space-t _ illusztráld!)] [típus] [beillesztés 1=igen, 0=nem]", sourcePlayer, 255, 255, 255, true)
        end 
    end
end
addCommandHandler("createfaction", createFaction)
addCommandHandler("addfaction", createFaction)

function deleteFaction(sourcePlayer, cmd, id)
    if exports['cr_permission']:hasPermission(sourcePlayer, "createfaction") then 
        id = tonumber(id)

        if tonumber(id) then 
            local data = factionCache[id]
            if data then
                local players = data[3] 
                for k,v in pairs(players) do 
                    if factionPlayerAttach[k] then 
                        local attachID = factionPlayerAttach[k][id]
                        if attachID then 
                            factionPlayerAttach[k][id] = nil 

                            local breaked = false 
                            for k,v in pairs(factionPlayerAttach[k]) do 
                                breaked = true 
                                break
                            end 

                            if not breaked then 
                                factionPlayerAttach[k] = nil
                            end 

                            dbExec(connection, "DELETE FROM factionattach WHERE ID=?", attachID)
                        end 
                    end 
                end 

                factionCache[id] = nil
                factionNameCache[data[2]] = nil 

                dbExec(connection, "DELETE FROM factions WHERE ID=?", id)

                collectgarbage("collect")

                local blue = exports['cr_core']:getServerColor('yellow', true)
                local white = "#ffffff"
                local syntax = exports['cr_core']:getServerSyntax(nil, "success")
                outputChatBox(syntax .. "Sikeresen törölted a frakciót! (ID: "..blue..id..white..")", sourcePlayer, 255, 255, 255, true)

                local green = exports['cr_core']:getServerColor("orange", true)
                local white = "#ffffff"
                local syntax = exports['cr_admin']:getAdminSyntax()
                local aName = exports['cr_admin']:getAdminName(sourcePlayer, true)
                exports['cr_core']:sendMessageToAdmin(sourcePlayer, syntax..green..aName..white.." törölt egy frakciót! (ID: "..blue..id..white..")", 6)
                exports['cr_logs']:addLog(sourcePlayer, "Faction", "deletefaction", syntax..aName.." törölt egy frakciót! (ID: "..id..")")
            else
                local syntax = exports['cr_core']:getServerSyntax(nil, "error")
                outputChatBox(syntax .. "Nem létezik ilyen frakció!", sourcePlayer, 255, 255, 255, true)
            end 
        else 
            local syntax = exports["cr_core"]:getServerSyntax(nil, "warning")
            outputChatBox(syntax .. "/"..cmd.." [id]", sourcePlayer, 255, 255, 255, true)
        end 
    end
end 
addCommandHandler("deletefaction", deleteFaction)

function setFactionName(thePlayer, cmd, id, ...)
    if exports.cr_permission:hasPermission(thePlayer, cmd) then 
        if not id or not ... then 
            local syntax = exports.cr_core:getServerSyntax(false, "lightyellow")

            outputChatBox(syntax .. "/" .. cmd .. " [id] [név]", thePlayer, 255, 0, 0, true)
            return
        end

        local id = tonumber(id)
        local name = table.concat({...}, " ")

        if not id then 
            local syntax = exports.cr_core:getServerSyntax(false, "error")

            outputChatBox(syntax .. "Csak szám.", thePlayer, 255, 0, 0, true)
            return
        end

        id = math.floor(tonumber(id))

        if utf8.len(name) <= 0 then 
            local syntax = exports.cr_core:getServerSyntax(false, "error")

            outputChatBox(syntax .. "A névnek legalább 1 karaktert kell tartalmaznia.", thePlayer, 255, 0, 0, true)
            return
        end

        if factionCache[id] then 
            local oldName = factionCache[id][2]

            factionCache[id][2] = name:gsub("_", " ")
            dbExec(connection, "UPDATE factions SET name = ? WHERE id = ?", name:gsub("_", " "), id)

            local syntax = exports.cr_core:getServerSyntax(false, "success")
            local hexColor = exports.cr_core:getServerColor("yellow", true)
            local white = "#ffffff"

            local adminSyntax = exports.cr_admin:getAdminSyntax()
            local localName = exports.cr_admin:getAdminName(thePlayer, true)

            outputChatBox(syntax .. "Sikeresen megváltoztattad a frakció nevét. " .. hexColor .. "(" .. id .. ") " .. white .. "Új név: " .. hexColor .. name:gsub("_", " "), thePlayer, 255, 0, 0, true)
            exports.cr_core:sendMessageToAdmin(thePlayer, adminSyntax .. hexColor .. localName .. white .. " megváltoztatta a(z) " .. hexColor .. oldName .. white .. " frakció nevét. Új név: " .. hexColor .. name:gsub("_", " ") .. white .. " ID: " .. hexColor .. id, 8)

            getFactionData(getFactionPanelViewers(id), thePlayer, id, "all")
        else
            local syntax = exports.cr_core:getServerSyntax(false, "error")

            outputChatBox(syntax .. "Nem létezik frakció ezzel az id-vel.", thePlayer, 255, 0, 0, true)
        end
    end
end
addCommandHandler("setfactionname", setFactionName, false, false)

function showFactionTypes(sourcePlayer, cmd)
    if exports['cr_permission']:hasPermission(sourcePlayer, "showfactiontypes") then 
        local syntax = exports['cr_core']:getServerSyntax(nil, "info")
        local blue = exports['cr_core']:getServerColor('yellow', true)
        local white = "#ffffff"
        outputChatBox(syntax .. "Frakció típusok:", sourcePlayer, 255, 255, 255, true)
        for k,v in ipairs(factionTypes) do 
            outputChatBox(blue .. v .. white .. " (".. blue .. k.. white ..")", sourcePlayer, 255, 255, 255, true)
        end 
    end 
end 
addCommandHandler("showfactiontypes", showFactionTypes)

function showFactions(sourcePlayer, cmd)
    if exports['cr_permission']:hasPermission(sourcePlayer, "showfactions") then 
        local syntax = exports['cr_core']:getServerSyntax(nil, "info")
        local blue = exports['cr_core']:getServerColor('yellow', true)
        local white = "#ffffff"
        outputChatBox(syntax .. "Frakciók:", sourcePlayer, 255, 255, 255, true)
        for k,v in pairs(factionCache) do 
            outputChatBox(blue .. v[2] .. white .. " (".. blue .. k .. white ..")", sourcePlayer, 255, 255, 255, true)
        end 
    end 
end 
addCommandHandler("showfactions", showFactions)

function addPlayerToFaction(playerID, factionID, leader)
    if not tonumber(leader) or leader > 1 then 
        leader = 0
    end 

    local playerID, factionID = playerID, factionID -- mta hotfix
    if factionCache[factionID] then 
        if factionPlayerAttach[playerID] then 
            if factionPlayerAttach[playerID][factionID] then 
                return
            end 
        end 

        if not factionCache[factionID][3][playerID] then 
            factionCache[factionID][3][playerID] = true
            dbExec(connection, "UPDATE factions SET players=? WHERE ID=?", toJSON(factionCache[factionID][3]), factionID)
            dbExec(connection, "INSERT INTO factionattach SET playerid=?, leader=?, factionID=?, rank=?, permissions=?", playerID, leader, factionID, 1, toJSON({}))
            dbQuery(
                function(query)
                    local query, query_lines = dbPoll(query, 0)
                    if query_lines > 0 then
                        Async:foreach(query, 
                            function(row)
                                loadFactionAttach(row)
                                local online, playerE = exports['cr_account']:getAccountOnline(playerID)
                                if online then 
                                    getFactionData(playerE, playerE, factionID, "all")
                                end 
                                local _, playerData, _ = exports['cr_account']:getPlayerDatasByID(playerID)
                                if playerData then 
                                    addFactionLog(factionID, exports['cr_core']:getServerColor('yellow', true) .. playerData[2]:gsub("_", " ") .. " #F2F2F2csatlakozott a frakcióhoz!")
                                end 
                                getFactionData(getFactionPanelViewers(factionID), getRandomPlayer(), factionID, "all")
                            end 
                        )
                    end
                    outputDebugString("Loading factionAttach finished. Loaded #"..query_lines.." factionAttach!", 0, 255, 50, 255)
                end, 
            connection, "SELECT * FROM `factionattach` WHERE playerid=? AND leader=? AND factionID=? AND rank=? AND permissions=?", playerID, leader, factionID, 1, toJSON({}))
        end
    end 
end 
addEvent("addPlayerToFaction", true)
addEventHandler("addPlayerToFaction", root, addPlayerToFaction)

function removePlayerFromFaction(playerID, factionID)
    if factionPlayerAttach[playerID] then 
        if factionPlayerAttach[playerID][factionID] then 
            local attachID = factionPlayerAttach[playerID][factionID]
            if attachID then 
                if factionCache[factionID][3][playerID] then 
                    factionCache[factionID][3][playerID] = nil
                    dbExec(connection, "UPDATE factions SET players=? WHERE ID=?", toJSON(factionCache[factionID][3]), factionID)
                    factionPlayerAttach[playerID][factionID] = nil 

                    local breaked = false 
                    for k,v in pairs(factionPlayerAttach[playerID]) do 
                        breaked = true 
                        break
                    end 

                    if not breaked then 
                        factionPlayerAttach[playerID] = nil
                    end 

                    dbExec(connection, "DELETE FROM factionattach WHERE ID=?", attachID)

                    local online, playerE = exports['cr_account']:getAccountOnline(playerID)
                    getFactionData(getFactionPanelViewers(factionID), getRandomPlayer(), factionID, "all")
                    if online then 
                        getFactionData(playerE, playerE, factionID, "clear")

                        if playerE:getData("char >> duty") and playerE:getData("char >> duty") == factionID then 
                            local factionName = factionCache[factionID][2]

                            triggerLatentClientEvent(playerE, "dutyOffHandler", 50000, false, playerE, "removedFromFaction", factionName)
                        end
                    end 
                end
            end 
        end 
    end 
end 
addEvent("removePlayerFromFaction", true)
addEventHandler("removePlayerFromFaction", root, removePlayerFromFaction)

--setplayerfaction, removeplayerfaction, setplayerfactionleader, removeplayerfactionleader, setfactionmoney + az osszes admincommandhoz log es adminok ertesitese

function setPlayerFactionCMD(sourcePlayer, cmd, targetPlayer, factionID, leader)
    if exports['cr_permission']:hasPermission(sourcePlayer, "setplayerfaction") then 
        if not tonumber(leader) then 
            leader = 0
        end 

        if not targetPlayer or not tonumber(factionID) or not tonumber(leader) then 
            local syntax = exports["cr_core"]:getServerSyntax(nil, "warning")
            outputChatBox(syntax .. "/"..cmd.." [Játékos név / ID] [frakcióID] [leader 1=igen, 0=nem]", sourcePlayer, 255, 255, 255, true)
            return  
        end 

        local target = exports['cr_core']:findPlayer(sourcePlayer, targetPlayer)
        if target then
            if tonumber(leader) ~= 0 and tonumber(leader) ~= 1 then 
                local syntax = exports['cr_core']:getServerSyntax(false, "error")
                outputChatBox(syntax.."A leadernek 1nek vagy 0nak kell lennie!",sourcePlayer, 255,255,255,true) 
                return 
            end 

            if not getElementData(target, "loggedIn") then 
                local syntax = exports['cr_core']:getServerSyntax(false, "error")
                outputChatBox(syntax.."A játékos nincs bejelentkezve!",sourcePlayer, 255,255,255,true) 
                return 
            end

            addPlayerToFaction(target:getData("acc >> id"), tonumber(factionID), tonumber(leader))
            local blue = exports['cr_core']:getServerColor('yellow', true)
            local white = "#ffffff"
            local syntax = exports['cr_core']:getServerSyntax(nil, "success")
            outputChatBox(syntax .. "Sikeresen hozzáadtad "..blue..exports['cr_admin']:getAdminName(target)..white.." játékost a "..blue..factionID..white.." frakcióhoz!", sourcePlayer, 255, 255, 255, true)

            local green = exports['cr_core']:getServerColor("orange", true)
            local white = "#ffffff"
            local syntax = exports['cr_admin']:getAdminSyntax()
            local aName = exports['cr_admin']:getAdminName(sourcePlayer, true)
            exports['cr_core']:sendMessageToAdmin(sourcePlayer, syntax..green..aName..white.." hozzáadta "..blue..exports['cr_admin']:getAdminName(target)..white.." játékost a "..blue..factionID..white.." frakcióhoz!", 6)
            exports['cr_logs']:addLog(sourcePlayer, "Faction", "setplayerfaction", syntax..aName.." hozzáadta "..exports['cr_admin']:getAdminName(target).." játékost a "..factionID.." frakcióhoz!")
        else 
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax.."Nem található ilyen játékos!",sourcePlayer, 255,255,255,true) 
        end
    end 
end 
addCommandHandler("setplayerfaction", setPlayerFactionCMD)

function setPlayerFactionLeaderCMD(sourcePlayer, cmd, targetPlayer, factionID)
    if exports['cr_permission']:hasPermission(sourcePlayer, "setplayerfactionleader") then 
        if not targetPlayer or not tonumber(factionID) then 
            local syntax = exports["cr_core"]:getServerSyntax(nil, "warning")
            outputChatBox(syntax .. "/"..cmd.." [Játékos név / ID] [frakcióID]", sourcePlayer, 255, 255, 255, true)
            return  
        end 

        local target = exports['cr_core']:findPlayer(sourcePlayer, targetPlayer)
        if target then
            if not getElementData(target, "loggedIn") then 
                local syntax = exports['cr_core']:getServerSyntax(false, "error")
                outputChatBox(syntax.."A játékos nincs bejelentkezve!",255,255,255,true) 
                return 
            end

            if not factionCache[tonumber(factionID)] then 
                local syntax = exports['cr_core']:getServerSyntax(false, "error")
                outputChatBox(syntax.."Nincs ilyen idjű frakció!",255,255,255,true) 
                return 
            end 

            if factionPlayerAttach[target:getData("acc >> id")] and factionPlayerAttach[target:getData("acc >> id")][tonumber(factionID)] then 
                local attachID =  factionPlayerAttach[target:getData("acc >> id")][tonumber(factionID)]
                if factionAttach[attachID][4] == 0 then
                    factionAttach[attachID][4] = 1
                    local blue = exports['cr_core']:getServerColor('yellow', true)
                    addFactionLog(tonumber(factionID), blue .. exports['cr_admin']:getAdminName(target) .. " #F2F2F2leader jogokat kapott a frakcióban!")
                    dbExec(connection, "UPDATE factionattach SET leader=? WHERE ID=?", factionAttach[attachID][4], attachID)
                    local white = "#ffffff"
                    local syntax = exports['cr_core']:getServerSyntax(nil, "success")
                    outputChatBox(syntax .. "Sikeresen kinevezted "..blue..exports['cr_admin']:getAdminName(target)..white.." játékost a "..blue..factionID..white.." frakció vezetőjévé!", sourcePlayer, 255, 255, 255, true)

                    local green = exports['cr_core']:getServerColor("orange", true)
                    local white = "#ffffff"
                    local syntax = exports['cr_admin']:getAdminSyntax()
                    local aName = exports['cr_admin']:getAdminName(sourcePlayer, true)
                    exports['cr_core']:sendMessageToAdmin(sourcePlayer, syntax..green..aName..white.." kinevezte "..blue..exports['cr_admin']:getAdminName(target)..white.." játékost a "..blue..factionID..white.." frakció vezetőjévé!", 6)
                    exports['cr_logs']:addLog(sourcePlayer, "Faction", "setplayerfactionleader", syntax..aName.." kinevezte "..exports['cr_admin']:getAdminName(target).." játékost a "..factionID.." frakció vezetőjévé!")

                    getFactionData(getFactionPanelViewers(factionID), sourcePlayer, factionID, "all")
                    givePlayerPermission(target:getData("acc >> id"), factionID, "*")
                else 
                    local syntax = exports['cr_core']:getServerSyntax(false, "error")
                    outputChatBox(syntax.."A célpont már vezető ebben a frakcióban",sourcePlayer, 255,255,255,true) 
                end 
            else 
                local syntax = exports['cr_core']:getServerSyntax(false, "error")
                outputChatBox(syntax.."A célpont nem szerepel ebben a frakcióban",sourcePlayer, 255,255,255,true) 
            end
        else 
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax.."Nem található ilyen játékos!",sourcePlayer, 255,255,255,true) 
        end
    end 
end 
addCommandHandler("setplayerfactionleader", setPlayerFactionLeaderCMD)

function removePlayerFactionCMD(sourcePlayer, cmd, targetPlayer, factionID)
    if exports['cr_permission']:hasPermission(sourcePlayer, "removeplayerfaction") then 
        if not targetPlayer or not tonumber(factionID) then 
            local syntax = exports["cr_core"]:getServerSyntax(nil, "warning")
            outputChatBox(syntax .. "/"..cmd.." [Játékos név / ID] [frakcióID]", sourcePlayer, 255, 255, 255, true)
            return  
        end 

        local target = exports['cr_core']:findPlayer(sourcePlayer, targetPlayer)
        if target then
            if not getElementData(target, "loggedIn") then 
                local syntax = exports['cr_core']:getServerSyntax(false, "error")
                outputChatBox(syntax.."A játékos nincs bejelentkezve!",sourcePlayer, 255,255,255,true) 
                return 
            end

            addFactionLog(factionID, exports['cr_core']:getServerColor('yellow', true) .. exports['cr_admin']:getAdminName(target) .. " #F2F2F2kilépett a frakciból!")
            removePlayerFromFaction(target:getData("acc >> id"), tonumber(factionID))
            local blue = exports['cr_core']:getServerColor('yellow', true)
            local white = "#ffffff"
            local syntax = exports['cr_core']:getServerSyntax(nil, "success")
            outputChatBox(syntax .. "Sikeresen kitörölted "..blue..exports['cr_admin']:getAdminName(target)..white.." játékost a "..blue..factionID..white.." frakcióból!", sourcePlayer, 255, 255, 255, true)

            local green = exports['cr_core']:getServerColor("orange", true)
            local white = "#ffffff"
            local syntax = exports['cr_admin']:getAdminSyntax()
            local aName = exports['cr_admin']:getAdminName(sourcePlayer, true)
            exports['cr_core']:sendMessageToAdmin(sourcePlayer, syntax..green..aName..white.." kitörölte "..blue..exports['cr_admin']:getAdminName(target)..white.." játékost a "..blue..factionID..white.." frakcióból!", 6)
            exports['cr_logs']:addLog(sourcePlayer, "Faction", "removeplayerfaction", syntax..aName.." kitörölte "..exports['cr_admin']:getAdminName(target).." játékost a "..factionID.." frakcióból!")
        else 
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax.."Nem található ilyen játékos!",sourcePlayer, 255,255,255,true) 
        end
    end 
end 
addCommandHandler("removeplayerfaction", removePlayerFactionCMD)

function removePlayerFactionLeaderCMD(sourcePlayer, cmd, targetPlayer, factionID)
    if exports['cr_permission']:hasPermission(sourcePlayer, "removeplayerfactionleader") then 
        if not targetPlayer or not tonumber(factionID) then 
            local syntax = exports["cr_core"]:getServerSyntax(nil, "warning")
            outputChatBox(syntax .. "/"..cmd.." [Játékos név / ID] [frakcióID]", sourcePlayer, 255, 255, 255, true)
            return  
        end 

        local target = exports['cr_core']:findPlayer(sourcePlayer, targetPlayer)
        if target then
            if not getElementData(target, "loggedIn") then 
                local syntax = exports['cr_core']:getServerSyntax(false, "error")
                outputChatBox(syntax.."A játékos nincs bejelentkezve!",sourcePlayer, 255,255,255,true) 
                return 
            end

            if not factionCache[tonumber(factionID)] then 
                local syntax = exports['cr_core']:getServerSyntax(false, "error")
                outputChatBox(syntax.."Nincs ilyen idjű frakció!",sourcePlayer, 255,255,255,true) 
                return 
            end 

            if factionPlayerAttach[target:getData("acc >> id")] and factionPlayerAttach[target:getData("acc >> id")][tonumber(factionID)] then 
                local attachID =  factionPlayerAttach[target:getData("acc >> id")][tonumber(factionID)]
                if factionAttach[attachID][4] == 1 then 
                    factionAttach[attachID][4] = 0
                    local blue = exports['cr_core']:getServerColor('yellow', true)
                    addFactionLog(tonumber(factionID), blue .. exports['cr_admin']:getAdminName(target) .. " #F2F2F2elvesztette a leader jogokat a frakcióban!")
                    dbExec(connection, "UPDATE factionattach SET leader=? WHERE ID=?", factionAttach[attachID][4], attachID)
                    local white = "#ffffff"
                    local syntax = exports['cr_core']:getServerSyntax(nil, "success")
                    outputChatBox(syntax .. "Sikeresen elvetted "..blue..exports['cr_admin']:getAdminName(target)..white.." játékostól a "..blue..factionID..white.." frakció vezetőt!", sourcePlayer, 255, 255, 255, true)

                    getFactionData(getFactionPanelViewers(factionID), sourcePlayer, factionID, "all")
                    removePlayerPermission(target:getData("acc >> id"), factionID, "*")

                    local green = exports['cr_core']:getServerColor("orange", true)
                    local white = "#ffffff"
                    local syntax = exports['cr_admin']:getAdminSyntax()
                    local aName = exports['cr_admin']:getAdminName(sourcePlayer, true)
                    exports['cr_core']:sendMessageToAdmin(sourcePlayer, syntax..green..aName..white.." elvette "..blue..exports['cr_admin']:getAdminName(target)..white.." játékostól a "..blue..factionID..white.." frakció vezetőt!", 6)
                    exports['cr_logs']:addLog(sourcePlayer, "Faction", "removeplayerfactionleader", syntax..aName.." elvette "..exports['cr_admin']:getAdminName(target).." játékostól a "..factionID.." frakció vezetőt!")
                else 
                    local syntax = exports['cr_core']:getServerSyntax(false, "error")
                    outputChatBox(syntax.."A célpont nem vezető ebben a frakcióban",sourcePlayer, 255,255,255,true) 
                end 
            else 
                local syntax = exports['cr_core']:getServerSyntax(false, "error")
                outputChatBox(syntax.."A célpont nem szerepel ebben a frakcióban",sourcePlayer, 255,255,255,true) 
            end
        else 
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax.."Nem található ilyen játékos!",sourcePlayer, 255,255,255,true) 
        end
    end
end 
addCommandHandler("removeplayerfactionleader", removePlayerFactionLeaderCMD)

function updateFactionMessage(sourcePlayer, factionID, newMessage)
    if isElement(sourcePlayer) and tonumber(factionID) then 
        if factionCache[factionID] then 
            addFactionLog(tonumber(factionID), exports['cr_core']:getServerColor('yellow', true) .. exports['cr_admin']:getAdminName(sourcePlayer) .. " #F2F2F2frissítette a frakció üzenetet!")
            factionCache[factionID][7] = newMessage
            dbExec(connection, "UPDATE factions SET text=? WHERE ID=?", factionCache[factionID][7], factionID)
            getFactionData(getFactionPanelViewers(factionID), sourcePlayer, factionID, "all")
        end 
    end 
end 
addEvent("updateFactionMessage", true)
addEventHandler("updateFactionMessage", root, updateFactionMessage)

function updatePlayerDutySkin(sourcePlayer, factionID, newSkinId, instantSet)
    if isElement(sourcePlayer) and tonumber(factionID) and tonumber(newSkinId) then 
        local attachID = factionPlayerAttach[sourcePlayer:getData("acc >> id")][factionID]

        if factionAttach[attachID] then 
            factionAttach[attachID][7] = newSkinId
            dbExec(connection, "UPDATE factionattach SET dutyskin=? WHERE ID=?", factionAttach[attachID][7], attachID)
            getFactionData(getFactionPanelViewers(factionID), sourcePlayer, factionID, "all")

            if instantSet then 
                sourcePlayer:setData("char >> duty", factionID)
                sourcePlayer:setData("char >> dutyskin", newSkinId)
            end
        end 
    end 
end 
addEvent("updatePlayerDutySkin", true)
addEventHandler("updatePlayerDutySkin", root, updatePlayerDutySkin)

function updatePlayerRank(sourcePlayer, accID, factionID, newRankID)
    if isElement(sourcePlayer) and tonumber(accID) and tonumber(factionID) and tonumber(newRankID) then 
        local attachID = factionPlayerAttach[accID][factionID]

        if factionAttach[attachID] then 
            factionAttach[attachID][5] = newRankID
            dbExec(connection, "UPDATE factionattach SET rank=? WHERE ID=?", factionAttach[attachID][5], attachID)
            getFactionData(getFactionPanelViewers(factionID), sourcePlayer, factionID, "all")
        end 
    end 
end 
addEvent("updatePlayerRank", true)
addEventHandler("updatePlayerRank", root, updatePlayerRank)

function updatePlayerLeader(sourcePlayer, accID, factionID, newVal)
    if isElement(sourcePlayer) and tonumber(accID) and tonumber(factionID) and tonumber(newVal) then 
        local attachID = factionPlayerAttach[accID][factionID]

        if factionAttach[attachID] then 
            factionAttach[attachID][4] = newVal
            dbExec(connection, "UPDATE factionattach SET leader=? WHERE ID=?", factionAttach[attachID][4], attachID)
            getFactionData(getFactionPanelViewers(factionID), sourcePlayer, factionID, "all")
            if newVal == 1 then 
                givePlayerPermission(accID, factionID, "*")
            else 
                removePlayerPermission(accID, factionID, "*")
            end 
        end 
    end 
end 
addEvent("updatePlayerLeader", true)
addEventHandler("updatePlayerLeader", root, updatePlayerLeader)

function givePlayerPermission(accID, factionID, permName)
    if tonumber(accID) and tonumber(factionID) and permName then 
        local attachID = factionPlayerAttach[accID][factionID]

        if factionAttach[attachID] then 
            if permName == "*" then 
                local permissions = factionAttach[attachID][6]
                for k, v in pairs(getFactionPermissions(factionID)) do 
                    permissions[v[1]] = true 
                end 
                factionAttach[attachID][6] = permissions
                dbExec(connection, "UPDATE factionattach SET permissions=? WHERE ID=?", toJSON(factionAttach[attachID][6]), attachID)
            else 
                local permissions = factionAttach[attachID][6]
                permissions[permName] = true 
                factionAttach[attachID][6] = permissions
                dbExec(connection, "UPDATE factionattach SET permissions=? WHERE ID=?", toJSON(factionAttach[attachID][6]), attachID)
            end 

            getFactionData(getFactionPanelViewers(factionID), getRandomPlayer(), factionID, "all")

            local online, playerElement = exports['cr_account']:getAccountOnline(accID) 
            if online then 
                getFactionData(playerElement, getRandomPlayer(), factionID, "all")
            end 
        end 
    end 
end 
addEvent("givePlayerPermission", true)
addEventHandler("givePlayerPermission", root, givePlayerPermission)

function removePlayerPermission(accID, factionID, permName)
    if tonumber(accID) and tonumber(factionID) and permName then 
        local attachID = factionPlayerAttach[accID][factionID]

        if factionAttach[attachID] then 
            if permName == "*" then 
                local permissions = factionAttach[attachID][6]
                for k, v in pairs(getFactionPermissions(factionID)) do 
                    permissions[v[1]] = false 
                end 
                factionAttach[attachID][6] = permissions
                dbExec(connection, "UPDATE factionattach SET permissions=? WHERE ID=?", toJSON(factionAttach[attachID][6]), attachID)
            else 
                local permissions = factionAttach[attachID][6]
                permissions[permName] = false 
                factionAttach[attachID][6] = permissions
                dbExec(connection, "UPDATE factionattach SET permissions=? WHERE ID=?", toJSON(factionAttach[attachID][6]), attachID)
            end 

            getFactionData(getFactionPanelViewers(factionID), getRandomPlayer(), factionID, "all")

            local online, playerElement = exports['cr_account']:getAccountOnline(accID) 
            if online then 
                getFactionData(playerElement, getRandomPlayer(), factionID, "all")
            end 
        end 
    end 
end 
addEvent("removePlayerPermission", true)
addEventHandler("removePlayerPermission", root, removePlayerPermission)

function setPlayerPermissions(accID, factionID, permissions)
    if tonumber(accID) and tonumber(factionID) and permissions then 
        local attachID = factionPlayerAttach[accID][factionID]

        if factionAttach[attachID] then 
            factionAttach[attachID][6] = permissions
            dbExec(connection, "UPDATE factionattach SET permissions=? WHERE ID=?", toJSON(factionAttach[attachID][6]), attachID)
            getFactionData(getFactionPanelViewers(factionID), getRandomPlayer(), factionID, "all")

            local online, playerElement = exports['cr_account']:getAccountOnline(accID) 
            if online then 
                getFactionData(playerElement, getRandomPlayer(), factionID, "all")
            end 
        end 
    end 
end 
addEvent("setPlayerPermissions", true)
addEventHandler("setPlayerPermissions", root, setPlayerPermissions)

function inviteToFaction(sourcePlayer, targetPlayer, factionID)
    if isElement(sourcePlayer) and isElement(targetPlayer) and tonumber(factionID) then 
        if factionCache[factionID] then 
            triggerLatentClientEvent(targetPlayer, "inviteToFaction", 50000, false, sourcePlayer, sourcePlayer, factionID, factionCache[factionID][2])
        end 
    end 
end
addEvent("inviteToFaction", true)
addEventHandler("inviteToFaction", root, inviteToFaction)

function sendNotificationToAccID(accID, type, message)
    local online, playerElement = exports['cr_account']:getAccountOnline(accID) 
    if online then 
        exports['cr_infobox']:addBox(playerElement, type, message)
    end 
end 
addEvent("sendNotificationToAccID", true)
addEventHandler("sendNotificationToAccID", root, sendNotificationToAccID)

function updateRankName(factionID, rankID, newName)
    if tonumber(factionID) and tonumber(rankID) and newName then 
        if factionCache[factionID] then
            if factionCache[factionID][4] and factionCache[factionID][4][rankID] then 
                factionCache[factionID][4][rankID]["name"] = newName
                dbExec(connection, "UPDATE factions SET ranks=? WHERE ID=?", toJSON(factionCache[factionID][4]), factionID)
                getFactionData(getFactionPanelViewers(factionID), getRandomPlayer(), factionID, "all")
            end 
        end 
    end 
end 
addEvent("updateRankName", true)
addEventHandler("updateRankName", root, updateRankName)

function updateRankPayment(factionID, rankID, newPayment)
    if tonumber(factionID) and tonumber(rankID) and tonumber(newPayment) then 
        if factionCache[factionID] then
            if factionCache[factionID][4] and factionCache[factionID][4][rankID] then 
                factionCache[factionID][4][rankID]["payment"] = tonumber(newPayment)
                dbExec(connection, "UPDATE factions SET ranks=? WHERE ID=?", toJSON(factionCache[factionID][4]), factionID)
                getFactionData(getFactionPanelViewers(factionID), getRandomPlayer(), factionID, "all")
            end 
        end 
    end 
end 
addEvent("updateRankPayment", true)
addEventHandler("updateRankPayment", root, updateRankPayment)

function sortRankUP(factionID, rankID)
    if tonumber(factionID) and tonumber(rankID) then 
        if factionCache[factionID][4][rankID] then 
            if rankID - 1 >= 1 then 
                local ranks = factionCache[factionID][4]

                for k,v in pairs(factionCache[factionID][3]) do 
                    local id = tonumber(k)

                    local attachID = factionPlayerAttach[id][factionID]
                    if attachID then  
                        local rank = factionAttach[attachID][5]
                        if rank == rankID and factionCache[factionID][4][rank] then 
                            factionAttach[attachID][5] = rankID - 1
                            dbExec(connection, "UPDATE factionattach SET rank=? WHERE ID=?", factionAttach[attachID][5], attachID)
                        elseif rank == (rankID - 1) and factionCache[factionID][4][rank] then 
                            factionAttach[attachID][5] = rankID
                            dbExec(connection, "UPDATE factionattach SET rank=? WHERE ID=?", factionAttach[attachID][5], attachID)
                        end 
                    end
                end 

                local data = ranks[rankID]
                local data2 = ranks[rankID - 1]
                ranks[rankID] = data2 
                ranks[rankID - 1] = data
                factionCache[factionID][4] = ranks

                dbExec(connection, "UPDATE factions SET ranks=? WHERE ID=?", toJSON(factionCache[factionID][4]), factionID)
                getFactionData(getFactionPanelViewers(factionID), getRandomPlayer(), factionID, "all")
            end 
        end 
    end 
end 
addEvent("sortRankUP", true)
addEventHandler("sortRankUP", root, sortRankUP)

function sortRankDown(factionID, rankID)
    if tonumber(factionID) and tonumber(rankID) then 
        if factionCache[factionID][4][rankID] then 
            if rankID + 1 <= #factionCache[factionID][4] then 
                local ranks = factionCache[factionID][4]

                for k,v in pairs(factionCache[factionID][3]) do 
                    local id = tonumber(k)

                    local attachID = factionPlayerAttach[id][factionID]
                    if attachID then  
                        local rank = factionAttach[attachID][5]
                        if rank == rankID and factionCache[factionID][4][rank] then 
                            factionAttach[attachID][5] = rankID + 1
                            dbExec(connection, "UPDATE factionattach SET rank=? WHERE ID=?", factionAttach[attachID][5], attachID)
                        elseif rank == (rankID + 1) and factionCache[factionID][4][rank] then 
                            factionAttach[attachID][5] = rankID
                            dbExec(connection, "UPDATE factionattach SET rank=? WHERE ID=?", factionAttach[attachID][5], attachID)
                        end 
                    end
                end 

                local data = ranks[rankID]
                local data2 = ranks[rankID + 1]
                ranks[rankID] = data2 
                ranks[rankID + 1] = data

                factionCache[factionID][4] = ranks

                dbExec(connection, "UPDATE factions SET ranks=? WHERE ID=?", toJSON(factionCache[factionID][4]), factionID)
                getFactionData(getFactionPanelViewers(factionID), getRandomPlayer(), factionID, "all")
            end 
        end 
    end 
end 
addEvent("sortRankDown", true)
addEventHandler("sortRankDown", root, sortRankDown)

function factionAddRank(factionID, rankName, payment)
    if tonumber(factionID) and rankName and tonumber(payment) then 
        if factionCache[factionID] then
            if factionCache[factionID][4] then 
                if #factionCache[factionID][4] <= 50 then 
                    local ranks = factionCache[factionID][4]
                    table.insert(ranks, #ranks + 1, {["name"] = rankName, ["payment"] = tonumber(payment)})
                    factionCache[factionID][4] = ranks
                    dbExec(connection, "UPDATE factions SET ranks=? WHERE ID=?", toJSON(factionCache[factionID][4]), factionID)
                    getFactionData(getFactionPanelViewers(factionID), getRandomPlayer(), factionID, "all")
                end
            end 
        end 
    end 
end 
addEvent("factionAddRank", true)
addEventHandler("factionAddRank", root, factionAddRank)

function factionRemoveRank(factionID, rankID) 
    if tonumber(factionID) and tonumber(rankID) then 
        if factionCache[factionID] then
            if factionCache[factionID][4] and factionCache[factionID][4][rankID] then 
                if #factionCache[factionID][4] >= 2 then 
                    for k, v in pairs(factionCache[factionID][4]) do 
                        if k == rankID then 
                            table.remove(factionCache[factionID][4], k)
                            break 
                        end 
                    end 

                    for k,v in pairs(factionCache[factionID][3]) do 
                        local id = tonumber(k)

                        local attachID = factionPlayerAttach[id][factionID]
                        if attachID then 
                            local rank = factionAttach[attachID][5]
                            if rank == rankID or not factionCache[factionID][4][rank] then 
                                factionAttach[attachID][5] = 1 
                                dbExec(connection, "UPDATE factionattach SET rank=? WHERE ID=?", factionAttach[attachID][5], attachID)
                            end 
                        end
                    end 

                    dbExec(connection, "UPDATE factions SET ranks=? WHERE ID=?", toJSON(factionCache[factionID][4]), factionID)
                    getFactionData(getFactionPanelViewers(factionID), getRandomPlayer(), factionID, "all")
                end 
            end 
        end 
    end 
end  
addEvent("factionRemoveRank", true)
addEventHandler("factionRemoveRank", root, factionRemoveRank)

function giveFactionMoney(sourcePlayer, factionID, val)
    if tonumber(factionID) and tonumber(val) then 
        if factionCache[factionID] then 
            factionCache[factionID][6] = factionCache[factionID][6] + val
            dbExec(connection, "UPDATE factions SET money=? WHERE ID=?", factionCache[factionID][6], factionID)
            getFactionData(getFactionPanelViewers(factionID), sourcePlayer, factionID, "all")
            exports['cr_infobox']:addBox(sourcePlayer, "success", "Sikeresen beraktál "..val.." $-t a frakcióba!")
        end 
    end
end 
addEvent("giveFactionMoney", true)
addEventHandler("giveFactionMoney", root, giveFactionMoney)

function getFactionMoney(sourcePlayer, factionID, val)
    if tonumber(factionID) and tonumber(val) then 
        if factionCache[factionID] then 
            if factionCache[factionID][6] >= val then 
                sourcePlayer:setData("char >> money", sourcePlayer:getData("char >> money") + val)
                factionCache[factionID][6] = factionCache[factionID][6] - val
                dbExec(connection, "UPDATE factions SET money=? WHERE ID=?", factionCache[factionID][6], factionID)
                getFactionData(getFactionPanelViewers(factionID), sourcePlayer, factionID, "all")
                exports['cr_infobox']:addBox(sourcePlayer, "success", "Sikeresen kivettél "..val.." $-t a frakcióból!")
            end 
        end 
    end 
end 
addEvent("getFactionMoney", true)
addEventHandler("getFactionMoney", root, getFactionMoney)

function requestFactionMoney(factionID)
    if tonumber(factionID) then 
        if factionCache[factionID] then 
            return factionCache[factionID][6]
        end 
    end 
end 

function takeFactionMoney(sourcePlayer, factionID, amount)
    if tonumber(factionID) and tonumber(amount) then 
        if factionCache[factionID] then 
            if requestFactionMoney(factionID) >= amount then 
                factionCache[factionID][6] = factionCache[factionID][6] - amount
                dbExec(connection, "UPDATE factions SET money=? WHERE ID=?", factionCache[factionID][6], factionID)
                getFactionData(getFactionPanelViewers(factionID), sourcePlayer, factionID, "all")

                return true 
            end 
        end 
    end 

    return false
end 
addEvent("takeFactionMoney", true)
addEventHandler("takeFactionMoney", root, takeFactionMoney)

function giveMoneyToFaction(sourcePlayer, factionID, amount)
    if tonumber(factionID) and tonumber(amount) then 
        if factionCache[factionID] then 
            factionCache[factionID][6] = factionCache[factionID][6] + amount
            dbExec(connection, "UPDATE factions SET money=? WHERE ID=?", factionCache[factionID][6], factionID)
            getFactionData(getFactionPanelViewers(factionID), sourcePlayer, factionID, "all")

            return true 
        end 
    end 

    return false
end 
addEvent("giveMoneyToFaction", true)
addEventHandler("giveMoneyToFaction", root, giveMoneyToFaction)

function sendMessageToFaction(factionID, text)
    if tonumber(factionID) then 
        if factionCache[factionID] then 
            for k,v in pairs(factionCache[factionID][3]) do 
                local online, playerElement = exports['cr_account']:getAccountOnline(tonumber(k))
                if online then 
                    outputChatBox(text, playerElement, 255, 255, 255, true)
                end 
            end 
        end 
    end 
end 
addEvent("sendMessageToFaction", true)
addEventHandler("sendMessageToFaction", root, sendMessageToFaction)

function isPlayerInFaction(player, factionID)
    if isElement(player) then 
        player = player:getData("acc >> id")
    end 

    if tonumber(player) and tonumber(factionID) then 
        if factionPlayerAttach[tonumber(player)] then 
            for k, v in pairs(factionPlayerAttach[tonumber(player)]) do 
                if k == tonumber(factionID) then 
                    return true 
                end 
            end 
        end 
    end 

    return false 
end 

function isPlayerInFactionType(player, factionType)
    if isElement(player) then 
        player = player:getData("acc >> id")
    end 

    if tonumber(player) and tonumber(factionType) then 
        if factionPlayerAttach[tonumber(player)] then 
            for k, v in pairs(factionPlayerAttach[tonumber(player)]) do 
                if factionCache[k] then 
                    if factionCache[k][5] == tonumber(factionType) then 
                        return true 
                    end 
                end 
            end 
        end 
    end 

    return false 
end 

function isPlayerFactionLeader(player, factionID)
    if isElement(player) then 
        player = player:getData("acc >> id")
    end

    if tonumber(player) and tonumber(factionID) then 
        if factionPlayerAttach[tonumber(player)] then 
            for k, v in pairs(factionPlayerAttach[tonumber(player)]) do 
                if k == tonumber(factionID) then
                    local attachID = factionPlayerAttach[tonumber(player)][factionID]
                    if attachID then 
                        local leader = factionAttach[attachID][4]

                        if leader == 1 then 
                            return true 
                        end 
                    end
                end 
            end 
        end 
    end 

    return false 
end 

function setFactionBankMoney(factionID, value)
    if tonumber(factionID) and tonumber(value) then 
        if factionCache[factionID] then 
            local currentMoney = factionCache[factionID][6]
            local newValue = currentMoney + value

            factionCache[factionID][6] = newValue

            dbExec(connection, "UPDATE factions SET money=? WHERE ID=?", factionCache[factionID][6], factionID)
            getFactionData(getFactionPanelViewers(factionID), getRandomPlayer(), factionID, "all")
        end
    end
end
addEvent("dashboard.setFactionBankMoney", true)
addEventHandler("dashboard.setFactionBankMoney", root, setFactionBankMoney)

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

function getPlayerFactionRankName(player, factionID)
    if isElement(player) then 
        player = player:getData("acc >> id")
    end

    local rank = false

    if tonumber(player) and tonumber(factionID) then 
        if factionPlayerAttach[tonumber(player)] then
            local availableFactionRanks = factionCache[factionID][4]
            
            for k, v in pairs(factionPlayerAttach[tonumber(player)]) do 
                if k == tonumber(factionID) then
                    local attachID = factionPlayerAttach[tonumber(player)][factionID]
                    if attachID then 
                        local playerRank = factionAttach[attachID][5]

                        rank = playerRank
                        break
                    end
                end 
            end 

            if rank then 
                if availableFactionRanks[rank] then 
                    return availableFactionRanks[rank].name
                end
            end
        end 
    end 

    return false 
end

function getAvailableFactions()
    return factionCache
end

function hasPlayerPermission(player, factionID, perm)
    local hasPerm = false
    if isElement(player) then 
        if player:getData("loggedIn") then 
            if factionCache[factionID] then 
                local permissions = factionCache[factionID][3][player:getData("acc >> id")][8]

                hasPerm = permissions[perm]
            end 
        end 
    elseif tonumber(player) then 
        if factionCache[factionID] then 
            local permissions = factionCache[factionID][3][tonumber(player)][8]

            hasPerm = permissions[perm]
        end 
    end 

    return hasPerm 
end 

local maxLogs = 250
function addFactionLog(factionID, text)
    if factionCache[factionID] then 
        local logs = factionCache[factionID][8]
        local time = exports['cr_core']:getTime() .. " "
        if #logs + 1 > maxLogs then 
            table.remove(logs, #logs)
        end 

        table.insert(logs, 1, time .. text)

        dbExec(connection, "UPDATE factions SET logs=? WHERE ID=?", toJSON(factionCache[factionID][8]), factionID)
    end 
end 
addEvent("addFactionLog", true)
addEventHandler("addFactionLog", root, addFactionLog)

function openFactionPanel(factionID, element)
    if not panelViewers[factionID] then 
        panelViewers[factionID] = {}
    end 

    if not panelViewersCache[factionID] then 
        panelViewersCache[factionID] = {}
    end 

    panelViewersElementCache[element] = factionID
    panelViewers[factionID][element] = true
    table.insert(panelViewersCache[factionID], element)
end 
addEvent("openFactionPanel", true)
addEventHandler("openFactionPanel", root, openFactionPanel)

function closeFactionPanel(factionID, element)
    if panelViewers[factionID] and panelViewers[factionID][element] then 
        panelViewersElementCache[element] = nil
        panelViewers[factionID][element] = nil 

        for k,v in pairs(panelViewersCache[factionID]) do 
            if v == element then 
                table.remove(panelViewersCache[factionID], k)
                return 
            end
        end 
    end 
end 
addEvent("closeFactionPanel", true)
addEventHandler("closeFactionPanel", root, closeFactionPanel)

function getFactionPanelViewers(factionID)
    return panelViewersCache[factionID] or {}
end 

addEventHandler("onPlayerQuit", root, 
    function()
        if panelViewersElementCache[source] then 
            local factionID = panelViewersElementCache[source]
            closeFactionPanel(factionID, source)
        end 
    end 
)