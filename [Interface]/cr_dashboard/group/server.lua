local groupCache = {}
local groupNameCache = {}
local spam = {}
local groupAttach = {}
local groupPlayerAttach = {}
local panelViewers = {}
local panelViewersCache = {}

function getGroupData(sendTo, sourcePlayer, groupID, typ)
    if typ == "all" then
        if groupCache[groupID] then 
            local data = fromJSON(toJSON(groupCache[groupID]))
            local players = convertPlayersIntoData(data)
            data[3] = players
            triggerLatentClientEvent(sendTo, "getGroupData", 50000, false, sourcePlayer, sendTo, groupID, data, "all")
        end
    elseif typ == "clear" then
        triggerLatentClientEvent(sendTo, "getGroupData", 50000, false, sourcePlayer, sendTo, groupID, nil, "all")
    end
end
addEvent("getGroupData", true)
addEventHandler("getGroupData", root, getGroupData)

function convertPlayersIntoData(data)
    local tbl = {}
    for k,v in pairs(data[3]) do 
        local id = tonumber(k)
        local id, playerData, accountData = exports['cr_account']:getPlayerDatasByID(id)
        if playerData then 
            local name = playerData[2]
            local groupID = groupPlayerAttach[id]
            local leader = groupAttach[groupID][4]
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
            table.insert(tbl, 1, {id, name, leader, online, lastOnline, lastOnlinePlace})
        end 
    end 

    return tbl
end 

function loadGroups()
    dbQuery(
        function(query)
            local query, query_lines = dbPoll(query, 0)
            if query_lines > 0 then
                Async:foreach(query, 
                    function(row)
                        local id = tonumber(row["id"])
                        local createdBy = tonumber(row["createdBy"])
                        local name = tostring(row["name"])
                        local a = fromJSON(tostring(row["players"]))
                        local players = {}
                        for k,v in pairs(a) do 
                            k = tonumber(k) 
                            players[k] = v
                        end 
                        groupCache[id] = {id, name, players, createdBy}
                        groupNameCache[name] = id
                    end
                )
            end
            outputDebugString("Loading groups finished. Loaded #"..query_lines.." groups!", 0, 255, 50, 255)
        end, 
    connection, "SELECT * FROM `groups`")
    
    dbQuery(
        function(query)
            local query, query_lines = dbPoll(query, 0)
            if query_lines > 0 then
                Async:foreach(query, 
                    function(row)
                        local id = tonumber(row["id"])
                        local playerid = tonumber(row["playerid"])
                        local leader = tonumber(row["leader"])
                        local groupID = tonumber(row["groupID"])
                        groupAttach[id] = {id, groupID, playerid, leader}
                        groupPlayerAttach[playerid] = id
                    end
                )
            end
            outputDebugString("Loading groupAttach finished. Loaded #"..query_lines.." groupAttach!", 0, 255, 50, 255)
        end, 
    connection, "SELECT * FROM `groupAttach`")
end
addEventHandler("onResourceStart", resourceRoot, loadGroups)

function checkPlayerGroup(e)
    if isElement(e) then
        if e:getData("acc >> id") then
            if groupPlayerAttach[e:getData("acc >> id")] then
                local groupID = groupPlayerAttach[e:getData("acc >> id")]
                if groupAttach[groupID] then
                    local id, groupID, playerid, leader = unpack(groupAttach[groupID])
                    e:setData("char >> group", groupID)
                    e:setData("char >> groupLeader", leader == 1)
                end
            end
        end
    end
end
addEvent("checkPlayerGroup", true)
addEventHandler("checkPlayerGroup", root, checkPlayerGroup)

function createGroup(playerE, groupName)
    if isElement(playerE) then --online
        if playerE:getData("loggedIn") then
            if tonumber(playerE:getData("char >> group") or 0) > 0 then
                return
            else
                if groupName then
                    dbExec(connection, "INSERT INTO `groups` SET `createdBy`=?, `name`=?", playerE:getData("acc >> id"), groupName)    
                    
                    dbQuery(
                        function(query)
                            local query, query_lines = dbPoll(query, 0)
                            if query_lines > 0 then
                                Async:foreach(query, 
                                    function(row)
                                        local id = tonumber(row["id"])
                                        local createdBy = tonumber(row["createdBy"])
                                        local name = tostring(row["name"])
                                        local a = fromJSON(tostring(row["players"]))
                                        local players = {}
                                        for k,v in pairs(a) do 
                                            k = tonumber(k) 
                                            players[k] = v
                                        end 
                                        groupCache[id] = {id, name, players, createdBy}
                                        groupNameCache[name] = id
                                        
                                        openPanel(id, playerE)
                                        addPlayerToGroup("ByScript", playerE, id, 1)
                                    end
                                )
                            end
                        end, 
                    connection, "SELECT * FROM `groups` WHERE `createdBy`=?", playerE:getData("acc >> id"))
                end
            end
        end
    end
end
addEvent("createGroup", true)
addEventHandler("createGroup", root, createGroup)

function deleteGroup(groupID)
    if groupCache[groupID] then
        local name = groupCache[groupID][2]
        local players = groupCache[groupID][3]
        for id,v in pairs(players) do
            local id = tonumber(id)
            local isOnline, playerElement = exports['cr_account']:getAccountOnline(id)
            if isOnline then
                removePlayerFromGroup("ByScript", playerElement, groupID)
            else
                removePlayerFromGroup("ByScript", id, groupID)
            end
        end
        
        groupCache[groupID] = nil
        groupNameCache[name] = nil
        
        dbExec(connection, "DELETE FROM `groups` WHERE `id`=?", groupID)

        panelViewers[groupID] = nil
        panelViewersCache[groupID] = nil 
        collectgarbage("collect")
    end
end
addEvent("deleteGroup", true)
addEventHandler("deleteGroup", root, deleteGroup)

function addPlayerToGroup(who, playerE, groupID, isLeader)
    if isElement(who) and who:getData("char >> group") == groupID and playerE ~= who or who == "ByScript" then
        if isElement(playerE) then --online
            if playerE:getData("loggedIn") then
                if tonumber(playerE:getData("char >> group") or 0) > 0 then
                    return
                else
                    local playerID = playerE:getData("acc >> id")
                    if not groupPlayerAttach[playerID] then
                        if groupCache[groupID] then
                            if not groupCache[groupID][3][playerID] then
                                groupCache[groupID][3][playerID] = true
                                dbExec(connection, "UPDATE `groups` SET `players`=? WHERE `id`=?", toJSON(groupCache[groupID][3]), groupID)
                                dbExec(connection, "INSERT INTO `groupAttach` SET `playerid`=?, `groupID`=?, `leader`=?", playerID, groupID, isLeader)    

                                local playerE = playerE
                                dbQuery(
                                    function(query)
                                        local query, query_lines = dbPoll(query, 0)
                                        if query_lines > 0 then
                                            Async:foreach(query, 
                                                function(row)
                                                    local id = tonumber(row["id"])
                                                    local playerid = tonumber(row["playerid"])
                                                    local leader = tonumber(row["leader"])
                                                    local groupID = tonumber(row["groupID"])
                                                    groupAttach[id] = {id, groupID, playerid, leader}
                                                    groupPlayerAttach[playerid] = id
                                                    checkPlayerGroup(playerE)
                                                    
                                                    getGroupData(getPanelViewers(groupID), playerE, groupID, "all")  
                                                    getGroupData(playerE, playerE, groupID, "all")  
                                                end
                                            )
                                        end
                                    end, 
                                connection, "SELECT * FROM `groupAttach` WHERE `playerid`=?", playerID)
                            end
                        end
                    end
                end
            end
        elseif tonumber(playerE) then --offline
            local playerID = tonumber(playerE)
            if not groupPlayerAttach[playerID] then
                if groupCache[groupID] then
                    if not groupCache[groupID][3][playerID] then
                        groupCache[groupID][3][playerID] = true
                        dbExec(connection, "UPDATE `groups` SET `players`=? WHERE `id`=?", toJSON(groupCache[groupID][3]), groupID)
                        dbExec(connection, "INSERT INTO `groupAttach` SET `playerid`=?, `groupID`=?, `leader`=?", playerID, groupID, isLeader)  

                        dbQuery(
                            function(query)
                                local query, query_lines = dbPoll(query, 0)
                                if query_lines > 0 then
                                    Async:foreach(query, 
                                        function(row)
                                            local id = tonumber(row["id"])
                                            local playerid = tonumber(row["playerid"])
                                            local leader = tonumber(row["leader"])
                                            local groupID = tonumber(row["groupID"])
                                            groupAttach[id] = {id, groupID, playerid, leader}
                                            groupPlayerAttach[playerid] = id
                                            
                                            getGroupData(getPanelViewers(groupID), getRandomPlayer(), groupID, "all")  
                                        end
                                    )
                                end
                            end, 
                        connection, "SELECT * FROM `groupAttach` WHERE `playerid`=?", playerID)
                    end
                end
            end
        end
    end
end
addEvent("addPlayerToGroup", true)
addEventHandler("addPlayerToGroup", root, addPlayerToGroup)

function removePlayerFromGroup(who, playerE, groupID)
    if isElement(who) and who:getData("char >> group") == groupID and playerE ~= who or who == "ByScript" then
        if isElement(playerE) then --online
            if playerE:getData("loggedIn") then
                if tonumber(playerE:getData("char >> group") or 0) ~= groupID then
                    return
                else
                    local playerID = playerE:getData("acc >> id")
                    if groupPlayerAttach[playerID] then
                        if groupCache[groupID] then
                            if groupCache[groupID][3][playerID] then
                                groupCache[groupID][3][playerID] = nil
                                local attachID = groupPlayerAttach[playerID]
                                groupAttach[attachID] = nil
                                groupPlayerAttach[playerID] = nil
                                dbExec(connection, "UPDATE `groups` SET `players`=? WHERE `id`=?", toJSON(groupCache[groupID][3]), groupID)
                                dbExec(connection, "DELETE FROM `groupAttach` WHERE `id`=?", attachID)
                                getGroupData(playerE, playerE, groupID, "clear")
                                closePanel(groupID, playerE)
                                
                                playerE:setData("char >> group", nil)
                                playerE:setData("char >> groupLeader", nil)
                                
                                local data = groupCache[groupID][3]
                                local c = 0
                                for k,v in pairs(data) do
                                    c = c + 1
                                    break
                                end
                                
                                if c == 0 then
                                    deleteGroup(groupID)
                                end

                                getGroupData(getPanelViewers(groupID), playerE, groupID, "all")   
                            end
                        end
                    end
                end
            end
        elseif tonumber(playerE) then --offline
            local playerID = tonumber(playerE)
            if groupPlayerAttach[playerID] then
                if groupCache[groupID] then
                    if groupCache[groupID][3][playerID] then
                        groupCache[groupID][3][playerID] = nil
                        local attachID = groupPlayerAttach[playerID]
                        groupAttach[attachID] = nil
                        groupPlayerAttach[playerID] = nil
                        dbExec(connection, "UPDATE `groups` SET `players`=? WHERE `id`=?", toJSON(groupCache[groupID][3]), groupID)
                        dbExec(connection, "DELETE FROM `groupAttach` WHERE `id`=?", attachID)
                        
                        local data = groupCache[groupID][3]
                        local c = 0
                        for k,v in pairs(data) do
                            c = c + 1
                            break
                        end

                        if c == 0 then
                            deleteGroup(groupID)
                        end
                        
                        getGroupData(getPanelViewers(groupID), getRandomPlayer(), groupID, "all")   
                    end
                end
            end
        end
    end
end
addEvent("removePlayerFromGroup", true)
addEventHandler("removePlayerFromGroup", root, removePlayerFromGroup)

function kickPlayerFromGroup(sourcePlayer, playerData, groupID)
    if isElement(sourcePlayer) and playerData and tonumber(groupID) then 
        local id = tonumber(playerData[1])
        local online, playerElement = exports['cr_account']:getAccountOnline(id)
        if online then 
            exports['cr_infobox']:addBox(playerElement, "warning", "Kirúgtak a "..groupCache[groupID][2].." nevű csoportból!")
            removePlayerFromGroup(sourcePlayer, playerElement, groupID) 
        else
            removePlayerFromGroup(sourcePlayer, id, groupID) 
        end 
    end 
end
addEvent("kickPlayerFromGroup", true)
addEventHandler("kickPlayerFromGroup", root, kickPlayerFromGroup)

function setPlayerGroupLeader(sourcePlayer, playerData, groupID)
    if isElement(sourcePlayer) and playerData and tonumber(groupID) then 
        local id = tonumber(playerData[1])
        sourcePlayer:setData("char >> groupLeader", false)
        local online, playerElement = exports['cr_account']:getAccountOnline(id)
        if online then 
            exports['cr_infobox']:addBox(playerElement, "warning", "Kineveztek a "..groupCache[groupID][2].." nevű csoport vezetőjévé!")
            playerElement:setData("char >> groupLeader", true)
        end 

        groupAttach[groupPlayerAttach[sourcePlayer:getData("acc >> id")]][4] = 0
        groupAttach[groupPlayerAttach[id]][4] = 1

        dbExec(connection, "UPDATE groupAttach SET leader = ? WHERE `id`=?", 0, groupPlayerAttach[sourcePlayer:getData("acc >> id")])
        dbExec(connection, "UPDATE groupAttach SET leader = ? WHERE `id`=?", 1, groupPlayerAttach[id])

        getGroupData(getPanelViewers(groupID), sourcePlayer, groupID, "all")
    end 
end
addEvent("setPlayerGroupLeader", true)
addEventHandler("setPlayerGroupLeader", root, setPlayerGroupLeader)

function changeGroupName(sourcePlayer, groupID, newName)
    if groupCache[groupID] and newName then
        local oldName = groupCache[groupID][2]
        groupCache[groupID][2] = newName
        groupNameCache[oldName] = nil
        groupNameCache[newName] = groupID
        
        dbExec(connection, "UPDATE `groups` SET `name`=? WHERE `id`=?", newName, groupID)
        
        getGroupData(getPanelViewers(groupID), sourcePlayer, groupID, "all")   
    end
end
addEvent("changeGroupName", true)
addEventHandler("changeGroupName", root, changeGroupName)

function openPanel(groupID, element)
    if not panelViewers[groupID] then 
        panelViewers[groupID] = {}
    end 

    if not panelViewersCache[groupID] then 
        panelViewersCache[groupID] = {}
    end 

    panelViewers[groupID][element] = true
    table.insert(panelViewersCache[groupID], element)
end 
addEvent("openPanel", true)
addEventHandler("openPanel", root, openPanel)

function closePanel(groupID, element)
    if panelViewers[groupID] and panelViewers[groupID][element] then 
        panelViewers[groupID][element] = nil 

        for k,v in pairs(panelViewersCache[groupID]) do 
            if v == element then 
                table.remove(panelViewersCache[groupID], k)
                return 
            end 
        end 
    end 
end 
addEvent("closePanel", true)
addEventHandler("closePanel", root, closePanel)

function getPanelViewers(groupID)
    if panelViewersCache[groupID] then 
        return panelViewersCache[groupID]
    end 

    return {}
end 

addEventHandler("onPlayerQuit", root, 
    function()
        if tonumber(source:getData("char >> group")) then 
            local groupID = tonumber(source:getData("char >> group"))
            closePanel(groupID, source)
        end 
    end 
)

function inviteToGroup(sourcePlayer, targetPlayer, groupID)
    if isElement(sourcePlayer) and isElement(targetPlayer) and tonumber(groupID) then 
        if groupCache[groupID] then 
            triggerLatentClientEvent(targetPlayer, "inviteToGroup", 50000, false, sourcePlayer, sourcePlayer, groupID, groupCache[groupID][2])
        end 
    end 
end
addEvent("inviteToGroup", true)
addEventHandler("inviteToGroup", root, inviteToGroup)