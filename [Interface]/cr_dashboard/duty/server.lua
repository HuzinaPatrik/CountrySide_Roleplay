local dutys = {}
local idToDutys = {}
local dutyLocations = {}
local factionDutyLocations = {}
local idToDutyLocation = {}

function loadDuty(row)
    local id = tonumber(row["id"])
    local factionID = tonumber(row["factionID"])
    local rankID = tonumber(row["rankID"])
    local items = fromJSON(tostring(row["items"]))

    if not dutys[factionID] then 
        dutys[factionID] = {}
    end 

    dutys[factionID][rankID] = {id, items}
    idToDutys[id] = {factionID, rankID}

    if factionDutyLocations[factionID] then 
        for k,v in pairs(factionDutyLocations[factionID]) do 
            local marker = idToDutyLocation[v]
            if isElement(marker) then 
                marker:setData("dutyLocation >> data", dutys[factionID])
            end 
        end 
    end 
end 

function loadDutyLocation(row)
    local id = tonumber(row["id"])
    local factionID = tonumber(row["factionID"])
    local x,y,z,dim,int = unpack(fromJSON(tostring(row["position"])))
    local marker = Marker(x, y, z, "cylinder", 1.5, 242, 202, 65)
    marker.interior = int 
    marker.dimension = dim
    marker:setData("dutyLocation >> id", id)
    marker:setData("dutyLocation >> factionID", factionID)
    local dutyData = dutys[factionID] or {}
    marker:setData("dutyLocation >> data", dutyData)
    marker:setData("marker >> customMarker", true)
	marker:setData("marker >> customIconPath", ":cr_dashboard/assets/images/dutyicon.png")

    dutyLocations[marker] = id 
    idToDutyLocation[id] = marker
    if not factionDutyLocations[factionID] then 
        factionDutyLocations[factionID] = {}
    end 

    table.insert(factionDutyLocations[factionID], id)
end 

function loadDutyData()
    dbQuery(
        function(query)
            local query, query_lines = dbPoll(query, 0)
            if query_lines > 0 then
                Async:foreach(query, 
                    loadDuty
                )
            end
            outputDebugString("Loading dutys finished. Loaded #"..query_lines.." dutys!", 0, 255, 50, 255)
        end, 
    connection, "SELECT * FROM `dutys`")
    
    dbQuery(
        function(query)
            local query, query_lines = dbPoll(query, 0)
            if query_lines > 0 then
                Async:foreach(query, 
                    loadDutyLocation
                )
            end
            outputDebugString("Loading dutylocations finished. Loaded #"..query_lines.." dutylocations!", 0, 255, 50, 255)
        end, 
    connection, "SELECT * FROM `dutylocations`")
end
addEventHandler("onResourceStart", resourceRoot, loadDutyData)

function addDutyLocation(factionID, position)
    if tonumber(factionID) and toJSON(position) then 
        dbExec(connection, "INSERT INTO dutylocations SET factionID=?, position=?", tonumber(factionID), toJSON(position))

        dbQuery(
            function(query)
                local query, query_lines = dbPoll(query, 0)
                if query_lines > 0 then
                    Async:foreach(query, 
                        loadDutyLocation
                    )
                end
                outputDebugString("Loading dutylocations finished. Loaded #"..query_lines.." dutylocations!", 0, 255, 50, 255)
            end, 
        connection, "SELECT * FROM `dutylocations` WHERE factionID=? AND position=?", tonumber(factionID), toJSON(position))
    end 
end 

function addDutyLocationCMD(sourcePlayer, cmd, factionID)
    if exports['cr_permission']:hasPermission(sourcePlayer, "createdutylocation") then 
        if not tonumber(factionID) then 
            local syntax = exports["cr_core"]:getServerSyntax(nil, "warning")
            outputChatBox(syntax .. "/"..cmd.." [frakció ID]", sourcePlayer, 255, 255, 255, true)
            return 
        else 
            if factionCache[tonumber(factionID)] then 
                local syntax = exports['cr_core']:getServerSyntax(nil, "success")
                local green = exports['cr_core']:getServerColor("orange", true)
                local white = "#ffffff"
                outputChatBox(syntax .. "Sikeresen létrehoztad a dutylocationt! (Frakció ID: "..green..factionID..white..")", sourcePlayer, 255, 255, 255, true)
                addDutyLocation(tonumber(factionID), {sourcePlayer.position.x, sourcePlayer.position.y, sourcePlayer.position.z - 1, sourcePlayer.dimension, sourcePlayer.interior})
                local syntax = exports['cr_admin']:getAdminSyntax()
                local aName = exports['cr_admin']:getAdminName(sourcePlayer, true)
                exports['cr_core']:sendMessageToAdmin(sourcePlayer, syntax..green..aName..white.." létrehozott egy dutylocationt! (Frakció ID: "..green..factionID..white..")", 9)
                exports['cr_logs']:addLog(sourcePlayer, "DutyLocation", "createdutylocation", syntax..aName.." létrehozott egy dutylocationt! (Frakció ID: "..factionID..")")
            else 
                local syntax = exports['cr_core']:getServerSyntax(nil, "error")
                outputChatBox(syntax .. "Ez a frakció nem létezik!", sourcePlayer, 255, 255, 255, true)
            end 
        end 
    end 
end 
addCommandHandler("createdutylocation", addDutyLocationCMD)
addCommandHandler("adddutylocation", addDutyLocationCMD)

function deleteDutyLocation(id)
    if idToDutyLocation[id] then 
        dutyLocations[idToDutyLocation[id]] = nil 
        local factionID = tonumber(idToDutyLocation[id]:getData("dutyLocation >> factionID"))
        idToDutyLocation[id]:destroy()
        idToDutyLocation[id] = nil 

        if factionDutyLocations[factionID] then 
            for k,v in pairs(factionDutyLocations[factionID]) do 
                if v == id then 
                    table.remove(factionDutyLocations[factionID], k)
                    break 
                end 
            end 
        end 

        collectgarbage("collect")

        dbExec(connection, "DELETE FROM dutylocations WHERE ID=?", id)
    end 
end 

function deleteDutyLocationCMD(sourcePlayer, cmd, id)
    if exports['cr_permission']:hasPermission(sourcePlayer, "deletedutylocation") then 
        if not tonumber(id) then 
            local syntax = exports["cr_core"]:getServerSyntax(nil, "warning")
            outputChatBox(syntax .. "/"..cmd.." [ID]", sourcePlayer, 255, 255, 255, true)
            return 
        else 
            if idToDutyLocation[tonumber(id)] then 
                local syntax = exports['cr_core']:getServerSyntax(nil, "success")
                local green = exports['cr_core']:getServerColor("orange", true)
                local white = "#ffffff"
                outputChatBox(syntax .. "Sikeresen törölted a dutylocationt! ("..green.."#"..id..white..")", sourcePlayer, 255, 255, 255, true)
                deleteDutyLocation(tonumber(id))
                local syntax = exports['cr_admin']:getAdminSyntax()
                local aName = exports['cr_admin']:getAdminName(sourcePlayer, true)
                exports['cr_core']:sendMessageToAdmin(sourcePlayer, syntax..green..aName..white.." törölt egy dutylocationt! ("..green.."#"..id..white..")", 9)
                exports['cr_logs']:addLog(sourcePlayer, "DutyLocation", "deletedutylocation", syntax..aName.." törölt egy dutylocationt! (".."#"..id..")")
            else 
                local syntax = exports['cr_core']:getServerSyntax(nil, "error")
                outputChatBox(syntax .. "Ez a dutylocation nem létezik!", sourcePlayer, 255, 255, 255, true)
            end 
        end 
    end 
end 
addCommandHandler("deletedutylocation", deleteDutyLocationCMD)
addCommandHandler("deldutylocation", deleteDutyLocationCMD)
addCommandHandler("removedutylocation", deleteDutyLocationCMD)

function createDuty(factionID, rankID)
    if tonumber(factionID) and tonumber(rankID) then 
        if not dutys[factionID] or not dutys[factionID][rankID] then 
            dbExec(connection, "INSERT INTO dutys SET factionID=?, rankID=?, items=?", tonumber(factionID), tonumber(rankID), toJSON({}))

            dbQuery(
                function(query)
                    local query, query_lines = dbPoll(query, 0)
                    if query_lines > 0 then
                        Async:foreach(query, 
                            loadDuty
                        )
                    end
                    outputDebugString("Loading dutys finished. Loaded #"..query_lines.." dutys!", 0, 255, 50, 255)
                end, 
            connection, "SELECT * FROM `dutys` WHERE factionID=? AND rankID=? AND items=?", tonumber(factionID), tonumber(rankID), toJSON({}))
        end 
    end 
end 

function deleteDuty(id)
    if idToDutys[id] then 
        local factionID, rankID = unpack(idToDutys[id]) 

        dutys[factionID][rankID] = nil 
        idToDutys[id] = nil 

        local breaked = false 
        for k,v in pairs(dutys[factionID]) do 
            breaked = true 
            break 
        end 

        if not breaked then 
            dutys[factionID] = nil 
        end 

        collectgarbage("collect")

        if factionDutyLocations[factionID] then 
            for k,v in pairs(factionDutyLocations[factionID]) do 
                local marker = idToDutyLocation[v]
                if isElement(marker) then 
                    marker:setData("dutyLocation >> data", dutys[factionID])
                end 
            end 
        end 

        dbExec(connection, "DELETE FROM dutys WHERE ID=?", id)
    end 
end 

function createFactionDutyCMD(sourcePlayer, cmd, factionID, rankID)
    if exports['cr_permission']:hasPermission(sourcePlayer, "createfactionduty") then 
        if not tonumber(factionID) or not tonumber(rankID) then 
            local syntax = exports["cr_core"]:getServerSyntax(nil, "warning")
            outputChatBox(syntax .. "/"..cmd.." [frakció ID] [rang ID]", sourcePlayer, 255, 255, 255, true)
            return 
        else 
            if factionCache[tonumber(factionID)] then 
                if factionCache[tonumber(factionID)][4][tonumber(rankID)] then 
                    if not dutys[factionID] or not dutys[factionID][rankID] then 
                        local green = exports['cr_core']:getServerColor("orange", true)
                        local white = "#ffffff"
                        local syntax = exports['cr_core']:getServerSyntax(nil, "success")
                        outputChatBox(syntax .. "Sikeresen létrehoztad a dutyt! (Frakció ID: "..green..factionID..white..", Rang ID: "..green..rankID..white..")", sourcePlayer, 255, 255, 255, true)
                        createDuty(tonumber(factionID), tonumber(rankID))
                        local syntax = exports['cr_admin']:getAdminSyntax()
                        local aName = exports['cr_admin']:getAdminName(sourcePlayer, true)
                        exports['cr_core']:sendMessageToAdmin(sourcePlayer, syntax..green..aName..white.." létrehozott egy dutyt! (Frakció ID: "..green..factionID..white..", Rang ID: "..green..rankID..white..")", 9)
                        exports['cr_logs']:addLog(sourcePlayer, "Duty", "createfactionduty", syntax..aName.." létrehozott egy dutyt! (Frakció ID: "..factionID..", Rang ID: "..rankID..")")
                    else 
                        local syntax = exports['cr_core']:getServerSyntax(nil, "error")
                        outputChatBox(syntax .. "Erre a rangra már létezik duty!", sourcePlayer, 255, 255, 255, true) 
                    end 
                else
                    local syntax = exports['cr_core']:getServerSyntax(nil, "error")
                    outputChatBox(syntax .. "Ez a rang nem létezik!", sourcePlayer, 255, 255, 255, true) 
                end 
            else 
                local syntax = exports['cr_core']:getServerSyntax(nil, "error")
                outputChatBox(syntax .. "Ez a frakció nem létezik!", sourcePlayer, 255, 255, 255, true)
            end 
        end 
    end 
end 
addCommandHandler("createfactionduty", createFactionDutyCMD)
addCommandHandler("addfactionduty", createFactionDutyCMD)

function getFactionDutys(sourcePlayer, cmd, factionID)
    if exports['cr_permission']:hasPermission(sourcePlayer, "getfactiondutys") then 
        if not tonumber(factionID) then 
            local syntax = exports["cr_core"]:getServerSyntax(nil, "warning")
            outputChatBox(syntax .. "/"..cmd.." [frakció ID]", sourcePlayer, 255, 255, 255, true)
            return 
        else 
            if dutys[tonumber(factionID)] then 
                local white = "#ffffff"
                local green = exports['cr_core']:getServerColor("orange", true)
                local syntax = exports['cr_core']:getServerSyntax(nil, "info")
                for k,v in pairs(dutys[tonumber(factionID)]) do
                    local rank = k
                    local id = v[1]
                    if id > 0 then
                        outputChatBox(syntax.."ID: "..green..id..white..", Rang: "..green..rank, sourcePlayer, 255,255,255,true)
                    end
                end
            else
                local green = exports['cr_core']:getServerColor("orange", true)
                local syntax = exports['cr_core']:getServerSyntax(nil, "error")
                outputChatBox(syntax .. "Nincs ehhez a frakcióhoz létrehozva duty!", sourcePlayer, 255,255,255,true)
            end
        end 
    end 
end 
addCommandHandler("getfactiondutys", getFactionDutys)

function deleteFactionDutyCMD(sourcePlayer, cmd, id)
    if exports['cr_permission']:hasPermission(sourcePlayer, "deletefactionduty") then 
        if not tonumber(id) then 
            local syntax = exports["cr_core"]:getServerSyntax(nil, "warning")
            outputChatBox(syntax .. "/"..cmd.." [ID]", sourcePlayer, 255, 255, 255, true)
            return
        else 
            if idToDutys[tonumber(id)] then 
                local syntax = exports['cr_core']:getServerSyntax(nil, "success")
                local green = exports['cr_core']:getServerColor("orange", true)
                local white = "#ffffff"
                outputChatBox(syntax .. "Sikeresen törölted a dutyt! ("..green.."#"..id..white..")", sourcePlayer, 255, 255, 255, true)
                deleteDuty(tonumber(id))
                local syntax = exports['cr_admin']:getAdminSyntax()
                local aName = exports['cr_admin']:getAdminName(sourcePlayer, true)
                exports['cr_core']:sendMessageToAdmin(sourcePlayer, syntax..green..aName..white.." törölt egy dutyt! ("..green.."#"..id..white..")", 9)
                exports['cr_logs']:addLog(sourcePlayer, "Duty", "deletefactionduty", syntax..aName.." törölt egy dutyt! (".."#"..id..")")
            else 
                local syntax = exports['cr_core']:getServerSyntax(nil, "error")
                outputChatBox(syntax .. "Ez a duty nem létezik!", sourcePlayer, 255, 255, 255, true)
            end 
        end 
    end 
end 
addCommandHandler("deletefactionduty", deleteFactionDutyCMD)
addCommandHandler("delfactionduty", deleteFactionDutyCMD)
addCommandHandler("removefactionduty", deleteFactionDutyCMD)

function addDutyItem(id, itemid, value, count, nbt)
    if tonumber(id) and tonumber(itemid) and tonumber(count) and tonumber(count) >= 1 then 
        if idToDutys[tonumber(id)] then
            local factionID, rankID = unpack(idToDutys[id]) 

            if not value then value = 1 end
            if not nbt then nbt = 1 end

            table.insert(dutys[factionID][rankID][2], {itemid, value, count, nbt})

            if factionDutyLocations[factionID] then 
                for k,v in pairs(factionDutyLocations[factionID]) do 
                    local marker = idToDutyLocation[v]
                    if isElement(marker) then 
                        marker:setData("dutyLocation >> data", dutys[factionID])
                    end 
                end 
            end 

            dbExec(connection, "UPDATE dutys SET items=? WHERE ID=?", toJSON(dutys[factionID][rankID][2]), id)
        end 
    end 
end 

function removeDutyItem(id, dutyItemID)
    if tonumber(id) and tonumber(dutyItemID) then 
        if idToDutys[tonumber(id)] then
            local factionID, rankID = unpack(idToDutys[id]) 
            if dutys[factionID][rankID][2][dutyItemID] then 
                table.remove(dutys[factionID][rankID][2], dutyItemID)

                if factionDutyLocations[factionID] then 
                    for k,v in pairs(factionDutyLocations[factionID]) do 
                        local marker = idToDutyLocation[v]
                        if isElement(marker) then 
                            marker:setData("dutyLocation >> data", dutys[factionID])
                        end 
                    end 
                end 

                dbExec(connection, "UPDATE dutys SET items=? WHERE ID=?", toJSON(dutys[factionID][rankID][2]), id)
            end 
        end 
    end 
end 

function addDutyItemCMD(sourcePlayer, cmd, dutyID, itemid, count, value, nbt)
    if exports['cr_permission']:hasPermission(sourcePlayer, "adddutyitem") then 
        if not tonumber(dutyID) or not tonumber(itemid) or not tonumber(count) then 
            local syntax = exports["cr_core"]:getServerSyntax(nil, "warning")
            outputChatBox(syntax .. "/"..cmd.." [dutyID] [itemID] [darab] [érték (Nem muszáj!)] [nbt (Nem muszáj!)]", sourcePlayer, 255, 255, 255, true)
            return 
        else 
            if idToDutys[tonumber(dutyID)] then
                if tonumber(itemid) >= 1 and tonumber(count) >= 1 then 
                    local green = exports['cr_core']:getServerColor("orange", true)
                    local white = "#ffffff"
                    local syntax = exports['cr_core']:getServerSyntax(nil, "success")
                    outputChatBox(syntax .. "Sikeresen hozzáadott egy tárgyat a dutyhoz! (Duty ID: "..green..dutyID..white..", Item ID: "..green..itemid..white..")", sourcePlayer, 255, 255, 255, true)
                    addDutyItem(tonumber(dutyID), tonumber(itemid), value, tonumber(count), nbt)
                    local syntax = exports['cr_admin']:getAdminSyntax()
                    local aName = exports['cr_admin']:getAdminName(sourcePlayer, true)
                    exports['cr_core']:sendMessageToAdmin(sourcePlayer, syntax..green..aName..white.." hozzáadott egy tárgyat a dutyhoz! (Duty ID: "..green..dutyID..white..", Item ID: "..green..itemid..white..")", 9)
                    exports['cr_logs']:addLog(sourcePlayer, "Duty", "adddutyitem", syntax..aName.." hozzáadott egy tárgyat a dutyhoz! (Duty ID: "..dutyID..", Item ID: "..itemid..")")
                else
                    local syntax = exports['cr_core']:getServerSyntax(nil, "error")
                    outputChatBox(syntax .. "Az itemidnek / darabnak egy számnak kell lennie mely nagyobb mint 0!", sourcePlayer, 255, 255, 255, true) 
                end 
            else 
                local syntax = exports['cr_core']:getServerSyntax(nil, "error")
                outputChatBox(syntax .. "Ez a duty nem létezik!", sourcePlayer, 255, 255, 255, true)
            end 
        end 
    end 
end 
addCommandHandler("adddutyitem", addDutyItemCMD)
addCommandHandler("createdutyitem", addDutyItemCMD)

function getDutyItems(sourcePlayer, cmd, dutyID)
    if exports['cr_permission']:hasPermission(sourcePlayer, "getdutyitems") then 
        if not tonumber(dutyID) then 
            local syntax = exports["cr_core"]:getServerSyntax(nil, "warning")
            outputChatBox(syntax .. "/"..cmd.." [duty ID]", sourcePlayer, 255, 255, 255, true)
            return 
        else 
            if idToDutys[tonumber(dutyID)] then
                local factionID, rankID = unpack(idToDutys[tonumber(dutyID)])
                if #dutys[factionID][rankID][2] >= 1 then 
                    local white = "#ffffff"
                    local green = exports['cr_core']:getServerColor("orange", true)
                    local syntax = exports['cr_core']:getServerSyntax(nil, "info")
                    for k,v in pairs(dutys[factionID][rankID][2]) do
                        local id = k 
                        local itemid, value, count, nbt = unpack(v)
                        if id > 0 then
                            outputChatBox(syntax.."ID: "..green..id..white..", ItemID: "..green..itemid..white..", Érték: "..green..value..white..", Darab: "..green..count..white..", NBT: "..green..nbt, sourcePlayer, 255,255,255,true)
                        end
                    end
                else 
                    local green = exports['cr_core']:getServerColor("orange", true)
                    local syntax = exports['cr_core']:getServerSyntax(nil, "error")
                    outputChatBox(syntax .. "Ehhez a dutyhoz nincs hozzáadva item!", sourcePlayer, 255,255,255,true)
                end 
            else
                local green = exports['cr_core']:getServerColor("orange", true)
                local syntax = exports['cr_core']:getServerSyntax(nil, "error")
                outputChatBox(syntax .. "Nincs ilyen duty!", sourcePlayer, 255,255,255,true)
            end
        end 
    end 
end 
addCommandHandler("getdutyitems", getDutyItems)

function deleteDutyItemCMD(sourcePlayer, cmd, dutyID, id)
    if exports['cr_permission']:hasPermission(sourcePlayer, "deletedutyitem") then 
        if not tonumber(dutyID) or not tonumber(id) then 
            local syntax = exports["cr_core"]:getServerSyntax(nil, "warning")
            outputChatBox(syntax .. "/"..cmd.." [Duty ID] [ID]", sourcePlayer, 255, 255, 255, true)
            return
        else 
            if idToDutys[tonumber(dutyID)] then 
                local factionID, rankID = unpack(idToDutys[tonumber(dutyID)])
                if dutys[factionID][rankID][2][tonumber(id)] then 
                    local syntax = exports['cr_core']:getServerSyntax(nil, "success")
                    local green = exports['cr_core']:getServerColor("orange", true)
                    local white = "#ffffff"
                    outputChatBox(syntax .. "Sikeresen törölted a duty itemet! (Duty ID: "..green..dutyID..white..", ID: "..green..id..white..")", sourcePlayer, 255, 255, 255, true)
                    removeDutyItem(tonumber(dutyID), tonumber(id))
                    local syntax = exports['cr_admin']:getAdminSyntax()
                    local aName = exports['cr_admin']:getAdminName(sourcePlayer, true)
                    exports['cr_core']:sendMessageToAdmin(sourcePlayer, syntax..green..aName..white.." törölt egy duty itemet! (Duty ID: "..green..dutyID..white..", ID: "..green..id..white..")", 9)
                    exports['cr_logs']:addLog(sourcePlayer, "Duty", "deletedutyitem", syntax..aName.." törölt egy duty itemet! (Duty ID: "..dutyID..", ID: "..id..")")
                else 
                    local syntax = exports['cr_core']:getServerSyntax(nil, "error")
                    outputChatBox(syntax .. "Ez a duty item nem létezik!", sourcePlayer, 255, 255, 255, true)
                end 
            else 
                local syntax = exports['cr_core']:getServerSyntax(nil, "error")
                outputChatBox(syntax .. "Ez a duty nem létezik!", sourcePlayer, 255, 255, 255, true)
            end 
        end 
    end 
end 
addCommandHandler("deletedutyitem", deleteDutyItemCMD)
addCommandHandler("deldutyitem", deleteDutyItemCMD)
addCommandHandler("removedutyitem", deleteDutyItemCMD)