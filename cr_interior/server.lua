local sql = exports["cr_mysql"]:getConnection(getThisResource())

function createRentPed(data)
    local rentPed = Ped(data.skinId, data.position)

    rentPed.interior = data.interior
    rentPed.dimension = data.dimension
    rentPed.rotation = data.rotation
    rentPed.frozen = true

    rentPed:setData("ped.name", data.name)
    rentPed:setData("ped.type", data.typ)
    rentPed:setData("ped.id", data.pedId)
    rentPed:setData("ped >> wallet", true)
    rentPed:setData("char >> noDamage", true)
end

addEventHandler("onResourceStart", root, 
    function(startedRes)
        if getResourceName(startedRes) == "cr_mysql" then
            sql = exports["cr_mysql"]:getConnection(getThisResource())
            restartResource(getThisResource())
        elseif startedRes == getThisResource() then 
            loadInteriors()

            for i = 1, #rentPedData do 
                local v = rentPedData[i]
        
                createRentPed(v)
            end
        end
    end
)

local cache = {}
local spawnTimers = {}

function loadInteriors()
    local startTick = getTickCount()
    local loaded = 0
    dbQuery(
        function(query)
            local query, query_lines = dbPoll(query, 0)
            if query_lines > 0 then 
                Async:foreach(query,
                    function(row)
                        loaded = loaded + 1

                        local outX, outY, outZ, outInt, outDim = unpack(fromJSON(row["outPosition"]))
                        local inX, inY, inZ, inInt, inDim = unpack(fromJSON(row["inPosition"]))

                        local outMarker = Marker(outX, outY, outZ - 0.1, "cylinder", 1, convertType(row["type"]))
                        outMarker:setInterior(outInt)
                        outMarker:setDimension(outDim)
                        outMarker:setAlpha(0)

                        local temp
                        if row["owner"] == "false" and tonumber(row["type"]) ~= 2 then 
                            temp = false
                        else 
                            if tonumber(row["type"]) == 2 then 
                                temp = "Önkormányzat"
                            else
                                temp = tonumber(row["owner"])
                            end
                        end

                        outMarker:setData("marker >> data", {
                            ["id"] = tonumber(row["id"]),
                            ["name"] = row["name"],
                            ["owner"] = temp,
                            ["locked"] = (row["locked"] == "true" and true or false),
                            ["type"] = row["type"],
                            ["price"] = row["price"],
                            ["elevator"] = false,
                            ['maxSafe'] = tonumber(row['safeSlots'] or 3),
                            ["customInterior"] = tonumber(row["customInterior"]),
                            ["faction"] = tonumber(row["faction"]),
                            ["isFarm"] = tostring(row.isFarm) == "true",
                        })

                        local inMarker = Marker(inX, inY, inZ, "cylinder", 1, convertType(row["type"]))
                        inMarker:setInterior(inInt)
                        inMarker:setDimension(inDim)
                        inMarker:setAlpha(0)

                        inMarker:setData("parent", outMarker)
                        outMarker:setData("parent", inMarker)

                        cache[row["id"]] = {outMarker, inMarker}
                    end,

                    function()
                        collectgarbage("collect")
                        outputDebugString("@loadInteriors: loaded "..loaded.." / "..query_lines.." interior(s) in "..getTickCount() - startTick.." ms.", 0, 255, 50, 255)
                    end
                )
            end
        end, sql, "SELECT * FROM interiors"
    )
end

function checkRentedInteriors(thePlayer)
    if not thePlayer then 
        dbQuery(
            function(query)
                local query, query_lines = dbPoll(query, 0)
                if query_lines > 0 then 
                    Async:foreach(query,
                        function(row)
                            local id = tonumber(row["id"])
                            local timestamp = getRealTime()["timestamp"]
                            local rentStamp = tonumber(row["rentDate"])
                            local expireStamp = tonumber(row["expireDate"])
                            local rentDate = getRealTime(rentStamp)
                            local expireDate = getRealTime(expireStamp)
                            local owner = tonumber(row["owner"])
                            local isOnline, element = false, false
                            if owner then 
                                isOnline, element = exports["cr_account"]:getAccountOnline(owner)
                            end

                            if timestamp >= expireStamp then 
                                if isOnline then 
                                    exports["cr_infobox"]:addBox(element, "warning", "Mivel nem fizetted be az ingatlan bérleted, ezért az elvételre került.")
                                end

                                dbExec(sql, "UPDATE interiors SET owner = 'false', rentDate = '0', expireDate = '0' WHERE id = ?", id)

                                local outMarker = cache[row["id"]][1]
                                local data = outMarker:getData("marker >> data")

                                data.owner = false
                                data.elevator = false
                                data.maxSafe = 0

                                outMarker:setData("marker >> data", data)
                            elseif (expireStamp - timestamp) <= 3600 then 
                                if isOnline then 
                                    outputChatBox(exports["cr_core"]:getServerSyntax(false, "warning").."Körülbelül "..exports["cr_core"]:getServerColor("yellow", true).."1 óra#ffffff múlva le fog járni az ingatlan bérleted, további teendőkért fordulj "..exports["cr_core"]:getServerColor("yellow", true).."Marcus Holloway#ffffff-hez.", element, 255, 0, 0, true)
                                    exports["cr_infobox"]:addBox(element, "warning", "Hamarosan le fog járni egy ingatlanod, további instrukciók a chatboxban.")
                                end
                            end
                        end
                    )
                end
            end, sql, "SELECT id, rentDate, expireDate, owner FROM interiors WHERE rentDate > 0 AND expireDate > 0 AND owner > 0"
        )
    else 
        dbQuery(
            function(query)
                local query, query_lines = dbPoll(query, 0)
                if query_lines > 0 then 
                    Async:foreach(query,
                        function(row)
                            local id = tonumber(row["id"])
                            local timestamp = getRealTime()["timestamp"]
                            local rentStamp = tonumber(row["rentDate"])
                            local expireStamp = tonumber(row["expireDate"])
                            local rentDate = getRealTime(rentStamp)
                            local expireDate = getRealTime(expireStamp)
                            local owner = tonumber(row["owner"])

                            if timestamp >= expireStamp then 
                                exports["cr_infobox"]:addBox(thePlayer, "warning", "Mivel nem fizetted be az ingatlan bérleted, ezért az elvételre került.")
                                dbExec(sql, "UPDATE interiors SET owner = 'false', rentDate = '0', expireDate = '0' WHERE id = ?", id)

                                local outMarker = cache[row["id"]][1]
                                local data = outMarker:getData("marker >> data")

                                data.owner = false
                                data.elevator = false
                                data.maxSafe = 0

                                outMarker:setData("marker >> data", data)
                            elseif (expireStamp - timestamp) <= 3600 then
                                outputChatBox(exports["cr_core"]:getServerSyntax(false, "warning").."Körülbelül "..exports["cr_core"]:getServerColor("yellow", true).."1 óra#ffffff múlva le fog járni az ingatlan bérleted, további teendőkért fordulj "..exports["cr_core"]:getServerColor("yellow", true).."Marcus Holloway#ffffff-hez.", thePlayer, 255, 0, 0, true)
                                exports["cr_infobox"]:addBox(thePlayer, "warning", "Hamarosan le fog járni egy ingatlanod, további instrukciók a chatboxban.")
                            end
                        end
                    )
                end
            end, sql, "SELECT id, rentDate, expireDate, owner FROM interiors WHERE owner = ? AND rentDate > 0 AND expireDate > 0", thePlayer:getData("acc >> id")
        )
    end
end
setTimer(checkRentedInteriors, 100, 1)
setTimer(checkRentedInteriors, (60 * 1000 * 60), 0)

addEventHandler("onElementDataChange", root,
    function(dataName, oldValue, newValue)
        if source:getType() == "player" then 
            if dataName == "loggedIn" then 
                if newValue and source:getData(dataName) then 
                    checkRentedInteriors(source)
                end
            end
        end
    end
)

function createInterior(thePlayer, cmd, id, type, price, ...)
    if exports["cr_permission"]:hasPermission(thePlayer, cmd) then 
        if not id or not type or not price or not ... then 
            outputChatBox(exports["cr_core"]:getServerSyntax(false, "lightyellow").."/"..cmd.." [Interior id] [Típus] [Ár] [Név]", thePlayer, 255, 0, 0, true)
            outputChatBox(exports["cr_core"]:getServerSyntax(false, "lightyellow").."Típusok: 1 = Ház, 2 = Önkormányzat, 3 = Bérház, 4 = Biznisz", thePlayer, 255, 0, 0, true)
            return 
        else 
            local id = tonumber(id)
            local type = tonumber(type)
            local price = tonumber(price)
            local name = table.concat({...}, " ")
            local playerX, playerY, playerZ = getElementPosition(thePlayer)
            local interior, dimension = getElementInterior(thePlayer), getElementDimension(thePlayer)

            local safeSlots = type == 1 and 3 or 0

            if interiorList[id] then 
                if interiorTypes[type] and type ~= 5 and type ~= 6 and type ~= 7 then 
                    if price ~= nil and price > 0 then 
                        local customInterior = customGameInteriors[id] and id or 0

                        dbExec(sql, "INSERT INTO interiors SET name = ?, owner = ?, locked = ?, type = ?, price = ?, outPosition = ?, inPosition = ?, safeSlots = ?, customInterior = ?", name, "false", "false", type, price, toJSON({playerX, playerY, playerZ - 1, interior, dimension}), toJSON({interiorList[id][2], interiorList[id][3], interiorList[id][4] - 1, interiorList[id][1], -1}), safeSlots, customInterior)

                        dbQuery(
                            function(query)
                                local query, query_lines = dbPoll(query, 0)
                                if query_lines > 0 then 
                                    Async:foreach(query,
                                        function(row)
                                            local table = {interiorList[id][2], interiorList[id][3], interiorList[id][4] - 1, interiorList[id][1], -1}
                                            table[5] = row["id"]
                                            dbExec(sql, "UPDATE interiors SET inPosition = ? WHERE id = ?", toJSON(table), row["id"])

                                            local outX, outY, outZ, outInt, outDim = unpack(fromJSON(row["outPosition"]))
                                            local inX, inY, inZ, inInt, inDim = unpack(fromJSON(row["inPosition"]))

                                            local outMarker = Marker(outX, outY, outZ - 0.1, "cylinder", 1, convertType(row["type"]))
                                            outMarker:setInterior(outInt)
                                            outMarker:setDimension(outDim)
                                            outMarker:setAlpha(0)

                                            local temp
                                            if row["owner"] == "false" and tonumber(row["type"]) ~= 2 then 
                                                temp = false
                                            else 
                                                if tonumber(row["type"]) == 2 then 
                                                    temp = "Önkormányzat"
                                                else
                                                    temp = tonumber(row["owner"])
                                                end
                                            end

                                            local data = {
                                                id = tonumber(row.id),
                                                name = row.name,
                                                owner = temp,
                                                locked = row.locked == "true",
                                                type = row.type,
                                                price = row.price,
                                                elevator = false,
                                                maxSafe = tonumber(row.safeSlots or 3),
                                                customInterior = row.customInterior,
                                                faction = row.faction
                                            }

                                            outMarker:setData("marker >> data", data)

                                            local inMarker = Marker(inX, inY, inZ, "cylinder", 1, convertType(row["type"]))
                                            inMarker:setInterior(inInt)
                                            inMarker:setDimension(table[5])
                                            inMarker:setAlpha(0)

                                            inMarker:setData("parent", outMarker)
                                            outMarker:setData("parent", inMarker)

                                            cache[row["id"]] = {outMarker, inMarker}

                                            exports["cr_logs"]:addLog(thePlayer, "Interior", "createinterior", exports["cr_admin"]:getAdminName(thePlayer, true).." létrehozott egy interiort. ("..row["id"]..")")
                                            outputChatBox(exports["cr_core"]:getServerSyntax(false, "success").."Sikeresen létrehoztad az interiort. "..exports["cr_core"]:getServerColor("yellow", true).."("..row["id"]..")", thePlayer, 255, 0, 0, true)
                                            triggerLatentClientEvent(thePlayer, "alertAdmins", 50000, false, thePlayer, "#ffffff létrehozott egy interiort. "..exports["cr_core"]:getServerColor("yellow", true).."("..row["id"]..")")
                                            triggerLatentClientEvent(getElementsByType("player"), "interior.createDisc", 50000, false, thePlayer, outMarker)
                                        end
                                    )
                                end
                            end, sql, "SELECT * FROM interiors WHERE id = LAST_INSERT_ID()"
                        )
                    else 
                        return outputChatBox(exports["cr_core"]:getServerSyntax(false, "red").."Hibás ár.", thePlayer, 255, 0, 0, true)
                    end
                else 
                    return outputChatBox(exports["cr_core"]:getServerSyntax(false, "red").."Hibás típus.", thePlayer, 255, 0, 0, true)
                end
            else 
                return outputChatBox(exports["cr_core"]:getServerSyntax(false, "red").."Nincs ilyen interior.", thePlayer, 255, 0, 0, true)
            end
        end
    end
end
addCommandHandler("createinterior", createInterior, false, false)

function deleteInterior(thePlayer, cmd, id)
    if exports["cr_permission"]:hasPermission(thePlayer, cmd) then 
        if not id then 
            return outputChatBox(exports["cr_core"]:getServerSyntax(false, "lightyellow").."/"..cmd.." [id]", thePlayer, 255, 0, 0, true)
        else 
            local id = tonumber(id)

            if id ~= nil then 
                if cache[id] then 
                    if isElement(cache[id][1]) and isElement(cache[id][2]) then 
                        destroyElement(cache[id][1])
                        destroyElement(cache[id][2])
                        cache[id] = nil
                        dbExec(sql, "DELETE FROM interiors WHERE id = ?", id)

                        exports["cr_logs"]:addLog(thePlayer, "Interior", "deleteinterior", exports["cr_admin"]:getAdminName(thePlayer, true).." kitörölt egy interiort. ("..id..")")
                        outputChatBox(exports["cr_core"]:getServerSyntax(false, "success").."Sikeresen kitörölted az interiort. "..exports["cr_core"]:getServerColor("yellow", true).."("..id..")", thePlayer, 255, 0, 0, true)
                        triggerLatentClientEvent(thePlayer, "alertAdmins", 50000, false, thePlayer, "#ffffff kitörölt egy interiort. "..exports["cr_core"]:getServerColor("yellow", true).."("..id..")")
                    else 
                        return outputChatBox(exports["cr_core"]:getServerSyntax(false, "red").."Nem létezik az interior kijárata, esetleg a bejárata.", thePlayer, 255, 0, 0, true)
                    end
                else 
                    return outputChatBox(exports["cr_core"]:getServerSyntax(false, "red").."Nincs ilyen id az interior cache-ben.", thePlayer, 255, 0, 0, true)
                end
            else 
                return outputChatBox(exports["cr_core"]:getServerSyntax(false, "red").."Hibás id.", thePlayer, 255, 0, 0, true)
            end
        end
    end
end
addCommandHandler("deleteinterior", deleteInterior, false, false)

function setInteriorId(thePlayer, cmd, id, intId)
    if exports["cr_permission"]:hasPermission(thePlayer, cmd) then 
        if not id or not intId then 
            return outputChatBox(exports["cr_core"]:getServerSyntax(false, "lightyellow").."/"..cmd.." [id] [belső interior id]", thePlayer, 255, 0, 0, true)
        else 
            local id = tonumber(id)
            local intId = tonumber(intId)

            if id ~= nil then 
                if cache[id] then 
                    if interiorList[intId] then 
                        if isElement(cache[id][1]) and isElement(cache[id][2]) then 
                            dbExec(sql, "UPDATE interiors SET inPosition = ? WHERE id = ?", toJSON({interiorList[intId][2], interiorList[intId][3], interiorList[intId][4] - 1, interiorList[intId][1], getElementDimension(cache[id][2])}), id)
                            setElementInterior(cache[id][2], interiorList[intId][1])
                            setElementInterior(thePlayer, interiorList[intId][1])
                            setElementPosition(thePlayer, interiorList[intId][2], interiorList[intId][3], interiorList[intId][4])
                            setElementPosition(cache[id][2], interiorList[intId][2], interiorList[intId][3], interiorList[intId][4] - 1)
                            exports["cr_logs"]:addLog(thePlayer, "Interior", "setinteriorid", exports["cr_admin"]:getAdminName(thePlayer, true).." megváltoztatta egy interior belső kinézetét. ID: "..id..", Belső id: "..interiorList[intId][1])
                            outputChatBox(exports["cr_core"]:getServerSyntax(false, "success").."Sikeresen megváltoztattad az "..exports["cr_core"]:getServerColor("yellow", true)..id.."#ffffff-vel/val rendelkező interior id-jét. "..exports["cr_core"]:getServerColor("yellow", true).."("..intId..")", thePlayer, 255, 0, 0, true)
                        else 
                            return outputChatBox(exports["cr_core"]:getServerSyntax(false, "red").."Nem létezik az interior kijárata, esetleg a bejárata.", thePlayer, 255, 0, 0, true)
                        end
                    else 
                        return outputChatBox(exports["cr_core"]:getServerSyntax(false, "red").."Nincs ilyen interior az interiorList-ben.", thePlayer, 255, 0, 0, true)
                    end
                else 
                    return outputChatBox(exports["cr_core"]:getServerSyntax(false, "red").."Nincs ilyen id az interior cache-ben.", thePlayer, 255, 0, 0, true)
                end
            else 
                return outputChatBox(exports["cr_core"]:getServerSyntax(false, "red").."Hibás id.", thePlayer, 255, 0, 0, true)
            end
        end
    end
end
addCommandHandler("setinteriorid", setInteriorId, false, false)

function setInteriorExit(thePlayer, cmd, id)
    if exports["cr_permission"]:hasPermission(thePlayer, cmd) then 
        if not id then 
            return outputChatBox(exports["cr_core"]:getServerSyntax(false, "lightyellow").."/"..cmd.." [id]", thePlayer, 255, 0, 0, true)
        else 
            local id = tonumber(id)
            local playerX, playerY, playerZ = getElementPosition(thePlayer)

            if id ~= nil then 
                if cache[id] then 
                    if isElement(cache[id][1]) and isElement(cache[id][2]) then
                        dbExec(sql, "UPDATE interiors SET inPosition = ? WHERE id = ?", toJSON({playerX, playerY, playerZ - 1, getElementInterior(thePlayer), getElementDimension(thePlayer)}), id) 
                        setElementInterior(cache[id][2], getElementInterior(thePlayer))
                        setElementDimension(cache[id][2], getElementDimension(thePlayer))
                        setElementPosition(cache[id][2], playerX, playerY, playerZ - 1)
                        exports["cr_logs"]:addLog(thePlayer, "Interior", "setinteriorexit", exports["cr_admin"]:getAdminName(thePlayer, true).." megváltoztatta egy interior kijárati pozícióját. ("..id..")")
                        outputChatBox(exports["cr_core"]:getServerSyntax(false, "success").."Sikeresen megváltoztattad az interior kijárati pozícióját. "..exports["cr_core"]:getServerColor("yellow", true).."("..id..")", thePlayer, 255, 0, 0, true)
                        triggerLatentClientEvent(thePlayer, "alertAdmins", 50000, false, thePlayer, "#ffffff megváltoztatta egy interior kijárati pozícióját. "..exports["cr_core"]:getServerColor("yellow", true).."("..id..")")
                    end
                else 
                    return outputChatBox(exports["cr_core"]:getServerSyntax(false, "red").."Nincs ilyen id az interior cache-ben.", thePlayer, 255, 0, 0, true)
                end
            else 
                return outputChatBox(exports["cr_core"]:getServerSyntax(false, "red").."Hibás id.", thePlayer, 255, 0, 0, true)
            end
        end
    end
end
addCommandHandler("setinteriorexit", setInteriorExit, false, false)

function setInteriorEnter(thePlayer, cmd, id)
    if exports["cr_permission"]:hasPermission(thePlayer, cmd) then 
        if not id then 
            return outputChatBox(exports["cr_core"]:getServerSyntax(false, "lightyellow").."/"..cmd.." [id]", thePlayer, 255, 0, 0, true)
        else 
            local id = tonumber(id)
            local playerX, playerY, playerZ = getElementPosition(thePlayer)

            if id ~= nil then 
                if cache[id] then 
                    if isElement(cache[id][1]) and isElement(cache[id][2]) then
                        dbExec(sql, "UPDATE interiors SET outPosition = ? WHERE id = ?", toJSON({playerX, playerY, playerZ - 1, getElementInterior(thePlayer), getElementDimension(thePlayer)}), id) 
                        setElementInterior(cache[id][1], getElementInterior(thePlayer))
                        setElementDimension(cache[id][1], getElementDimension(thePlayer))
                        setElementPosition(cache[id][1], playerX, playerY, playerZ - 1)
                        exports["cr_logs"]:addLog(thePlayer, "Interior", "setinteriorenter", exports["cr_admin"]:getAdminName(thePlayer, true).." megváltoztatta egy interior bejárati pozícióját. ("..id..")")
                        outputChatBox(exports["cr_core"]:getServerSyntax(false, "success").."Sikeresen megváltoztattad az interior bejárati pozícióját. "..exports["cr_core"]:getServerColor("yellow", true).."("..id..")", thePlayer, 255, 0, 0, true)
                        triggerLatentClientEvent(thePlayer, "alertAdmins", 50000, false, thePlayer, "#ffffff megváltoztatta egy interior bejárati pozícióját. "..exports["cr_core"]:getServerColor("yellow", true).."("..id..")")
                    end
                else 
                    return outputChatBox(exports["cr_core"]:getServerSyntax(false, "red").."Nincs ilyen id az interior cache-ben.", thePlayer, 255, 0, 0, true)
                end
            else 
                return outputChatBox(exports["cr_core"]:getServerSyntax(false, "red").."Hibás id.", thePlayer, 255, 0, 0, true)
            end
        end
    end
end
addCommandHandler("setinteriorenter", setInteriorEnter, false, false)

function gotoInterior(thePlayer, cmd, id)
    if exports["cr_permission"]:hasPermission(thePlayer, cmd) then 
        if not id then 
            return outputChatBox(exports["cr_core"]:getServerSyntax(false, "lightyellow").."/"..cmd.." [id]", thePlayer, 255, 0, 0, true)
        else 
            local id = tonumber(id)

            if id ~= nil then 
                if cache[id] then 
                    if isElement(cache[id][1]) and isElement(cache[id][2]) then 
                        local interiorX, interiorY, interiorZ = getElementPosition(cache[id][1])
                        local interior, dimension = getElementInterior(cache[id][1]), getElementDimension(cache[id][1])
                        setElementPosition(thePlayer, interiorX, interiorY, interiorZ + 1)
                        setElementInterior(thePlayer, interior)
                        setElementDimension(thePlayer, dimension)
                        exports["cr_logs"]:addLog(thePlayer, "Interior", "gotointerior", exports["cr_admin"]:getAdminName(thePlayer, true).." elteleportált egy interiorhoz. ("..id..")")
                        outputChatBox(exports["cr_core"]:getServerSyntax(false, "success").."Sikeresen elteleportáltál az interiorhoz. "..exports["cr_core"]:getServerColor("yellow", true).."("..id..")", thePlayer, 255, 0, 0, true)
                        triggerLatentClientEvent(thePlayer, "alertAdmins", 50000, false, thePlayer, "#ffffff elteleportált egy interiorhoz. "..exports["cr_core"]:getServerColor("yellow", true).."("..id..")")
                    end
                else 
                    return outputChatBox(exports["cr_core"]:getServerSyntax(false, "red").."Nincs ilyen id az interior cache-ben.", thePlayer, 255, 0, 0, true)
                end
            else 
                return outputChatBox(exports["cr_core"]:getServerSyntax(false, "red").."Hibás id.", thePlayer, 255, 0, 0, true)
            end
        end
    end
end
addCommandHandler("gotointerior", gotoInterior, false, false)

function setInteriorName(thePlayer, cmd, id, ...)
    if exports["cr_permission"]:hasPermission(thePlayer, cmd) then 
        if not id or not ... then 
            return outputChatBox(exports["cr_core"]:getServerSyntax(false, "lightyellow").."/"..cmd.." [id] [név]", thePlayer, 255, 0, 0, true)
        else 
            local id = tonumber(id)
            local name = table.concat({...}, " ")

            if id ~= nil then 
                if cache[id] then 
                    if isElement(cache[id][1]) and isElement(cache[id][2]) then 
                        local data = cache[id][1]:getData("marker >> data")

                        data.name = name
                        cache[id][1]:setData("marker >> data", data)

                        dbExec(sql, "UPDATE interiors SET name = ? WHERE id = ?", name, id)
                        exports["cr_logs"]:addLog(thePlayer, "Interior", "setinteriorname", exports["cr_admin"]:getAdminName(thePlayer, true).." megváltoztatta egy interior nevét. ID: "..id..", Régi név: "..data["name"]..", Új név: "..name)

                        outputChatBox(exports["cr_core"]:getServerSyntax(false, "success").."Sikeresen megváltoztattad az interior nevét. "..exports["cr_core"]:getServerColor("yellow", true).."("..name..")", thePlayer, 255, 0, 0, true)
                        triggerLatentClientEvent(thePlayer, "alertAdmins", 50000, false, thePlayer, "#ffffff megváltoztatta egy interior nevét. ID: "..exports["cr_core"]:getServerColor("yellow", true)..id.."#ffffff, Név: "..exports["cr_core"]:getServerColor("yellow", true)..name)
                    end
                else 
                    return outputChatBox(exports["cr_core"]:getServerSyntax(false, "red").."Nincs ilyen id az interior cache-ben.", thePlayer, 255, 0, 0, true)
                end
            else 
                return outputChatBox(exports["cr_core"]:getServerSyntax(false, "red").."Hibás id.", thePlayer, 255, 0, 0, true)
            end
        end
    end
end
addCommandHandler("setinteriorname", setInteriorName, false, false)

function setInteriorCost(thePlayer, cmd, id, price)
    if exports["cr_permission"]:hasPermission(thePlayer, cmd) then 
        if not id or not price then 
            local syntax = exports["cr_core"]:getServerSyntax(false, "lightyellow")
            outputChatBox(syntax.."/"..cmd.." [id] [ár]", thePlayer, 255, 0, 0, true)
            return 
        else 
            local id = tonumber(id)
            local price = tonumber(price)

            if id ~= nil then 
                if id > 0 then 
                    if price ~= nil then 
                        if price > 0 then 
                            if cache[id] then 
                                if isElement(cache[id][1]) and isElement(cache[id][2]) then  
                                    local data = cache[id][1]:getData("marker >> data")

                                    data.price = price
                                    cache[id][1]:setData("marker >> data", data)

                                    dbExec(sql, "UPDATE interiors SET price = ? WHERE id = ?", price, id)
                                    exports["cr_logs"]:addLog(thePlayer, "Interior", "setinteriorcost", exports["cr_admin"]:getAdminName(thePlayer, true).." megváltoztatta egy interior árát. ID: "..id..", Régi ár: "..data["price"].." $, Új ár: "..price.." $")

                                    outputChatBox(exports["cr_core"]:getServerSyntax(false, "success").."Sikeresen megváltoztattad az interior árát. "..exports["cr_core"]:getServerColor("yellow", true).."("..price.." $)", thePlayer, 255, 0, 0, true)
                                    triggerLatentClientEvent(thePlayer, "alertAdmins", 50000, false, thePlayer, "#ffffff megváltoztatta egy interior árát. ID: "..exports["cr_core"]:getServerColor("yellow", true)..id.."#ffffff, Új ár: "..exports["cr_core"]:getServerColor("yellow", true)..price.." $")
                                end
                            end
                        else
                            local syntax = exports["cr_core"]:getServerSyntax(false, "red")
                            outputChatBox(syntax.."Az ár nem lehet kisebb vagy egyenlő mint 0.", thePlayer, 255, 0, 0, true)
                            return 
                        end
                    else 
                        local syntax = exports["cr_core"]:getServerSyntax(false, "red")
                        outputChatBox(syntax.."Csak szám.", thePlayer, 255, 0, 0, true)
                        return
                    end
                else 
                    local syntax = exports["cr_core"]:getServerSyntax(false, "red")
                    outputChatBox(syntax.."Az id nem lehet kisebb vagy egyenlő mint 0.", thePlayer, 255, 0, 0, true)
                    return 
                end
            else 
                local syntax = exports["cr_core"]:getServerSyntax(false, "red")
                outputChatBox(syntax.."Csak szám.", thePlayer, 255, 0, 0, true)
                return
            end
        end
    end
end
addCommandHandler("setinteriorcost", setInteriorCost, false, false)

function createGarage(thePlayer, cmd, type, ...)
    if exports["cr_permission"]:hasPermission(thePlayer, cmd) then 
        if not type or not ... then 
            outputChatBox(exports["cr_core"]:getServerSyntax(false, "lightyellow").."/"..cmd.." [típus] [név]", thePlayer, 255, 0, 0, true)
            outputChatBox(exports["cr_core"]:getServerSyntax(false, "lightyellow").."Típusok: 1 = Kis garázs ("..exports["cr_dx"]:formatMoney(garageDatas[1][2]).." $), 2 = Közepes garázs ("..exports["cr_dx"]:formatMoney(garageDatas[2][2]).." $), 3 = Nagy garázs ("..exports["cr_dx"]:formatMoney(garageDatas[3][2]).." $), 4 = Frakció garázs ("..exports["cr_dx"]:formatMoney(garageDatas[4][2]).." $)", thePlayer, 255, 0, 0, true)
            return 
        else 
            local type = tonumber(type)
            local name = table.concat({...}, " ")
            local playerX, playerY, playerZ = getElementPosition(thePlayer)
            local interior, dimension = thePlayer:getInterior(), thePlayer:getDimension()

            if type ~= nil then 
                if type >= 1 and type <= 4 then 
                    dbExec(sql, "INSERT INTO interiors SET name = ?, owner = ?, locked = ?, type = ?, price = ?, outPosition = ?, inPosition = ?, safeSlots = ?", name, "false", "false", 5, garageDatas[type][2], toJSON({playerX, playerY, playerZ - 1, interior, dimension}), toJSON({interiorList[garageDatas[type][1]][2], interiorList[garageDatas[type][1]][3], interiorList[garageDatas[type][1]][4] - 1, interiorList[garageDatas[type][1]][1], -1}), 3)

                    dbQuery(
                        function(query)
                            local query, query_lines = dbPoll(query, 0)
                            if query_lines > 0 then 
                                Async:foreach(query,
                                    function(row)
                                        local table = {interiorList[garageDatas[type][1]][2], interiorList[garageDatas[type][1]][3], interiorList[garageDatas[type][1]][4] - 1, interiorList[garageDatas[type][1]][1], -1}
                                        table[5] = row["id"]
                                        dbExec(sql, "UPDATE interiors SET inPosition = ? WHERE id = ?", toJSON(table), row["id"])

                                        local outX, outY, outZ, outInt, outDim = unpack(fromJSON(row["outPosition"]))
                                        local inX, inY, inZ, inInt, inDim = unpack(fromJSON(row["inPosition"]))

                                        local outMarker = Marker(outX, outY, outZ - 0.1, "cylinder", 1, convertType(row["type"]))
                                        outMarker:setInterior(outInt)
                                        outMarker:setDimension(outDim)
                                        outMarker:setAlpha(0)

                                        local temp
                                        if row["owner"] == "false" and row["type"] ~= 2 then 
                                            temp = false
                                        else 
                                            temp = tonumber(row["owner"])
                                        end

                                        local data = {
                                            id = tonumber(row.id),
                                            name = row.name,
                                            owner = temp,
                                            locked = row.locked == "true",
                                            type = row.type,
                                            price = row.price,
                                            elevator = false,
                                            maxSafe = tonumber(row.safeSlots or 3),
                                            customInterior = row.customInterior,
                                            faction = row.faction
                                        }

                                        outMarker:setData("marker >> data", data)

                                        local inMarker = Marker(inX, inY, inZ, "cylinder", 1, convertType(row["type"]))
                                        inMarker:setInterior(inInt)
                                        inMarker:setDimension(table[5])
                                        inMarker:setAlpha(0)

                                        inMarker:setData("parent", outMarker)
                                        outMarker:setData("parent", inMarker)

                                        cache[row["id"]] = {outMarker, inMarker}

                                        exports["cr_logs"]:addLog(thePlayer, "Interior", "creategarage", exports["cr_admin"]:getAdminName(thePlayer, true).." létrehozott egy garázst. ID: "..row["id"]..", Típus: "..type)
                                        outputChatBox(exports["cr_core"]:getServerSyntax(false, "success").."Sikeresen létrehoztad a garázst. "..exports["cr_core"]:getServerColor("yellow", true).."("..row["id"]..")", thePlayer, 255, 0, 0, true)
                                        triggerLatentClientEvent(thePlayer, "alertAdmins", 50000, false, thePlayer, "#ffffff létrehozott egy garázst. "..exports["cr_core"]:getServerColor("yellow", true).."("..row["id"]..")")
                                    end
                                )
                            end 
                        end, sql, "SELECT * FROM interiors WHERE id = LAST_INSERT_ID()"
                    )
                else 
                    return outputChatBox(exports["cr_core"]:getServerSyntax(false, "red").."Hibás típus.", thePlayer, 255, 0, 0, true)
                end
            else 
                return outputChatBox(exports["cr_core"]:getServerSyntax(false, "red").."Hibás típus.", thePlayer, 255, 0, 0, true)
            end
        end
    end
end
addCommandHandler("creategarage", createGarage, false, false)

function createFarmCommand(thePlayer, cmd, price, ...)
    if exports.cr_core:getPlayerDeveloper(thePlayer) then 
        if not price or not ... then 
            local syntax = exports.cr_core:getServerSyntax(false, "lightyellow")

            outputChatBox(syntax .. "/" .. cmd .. " [ár] [név]", thePlayer, 255, 0, 0, true)
            return
        end

        local price = tonumber(price)
        local name = table.concat({...}, " ")

        if not price then 
            local syntax = exports.cr_core:getServerSyntax("Farm", "error")

            outputChatBox(syntax .. "Csak szám.", thePlayer, 255, 0, 0, true)
            return
        end

        price = math.floor(tonumber(price))

        if price <= 0 then 
            local syntax = exports.cr_core:getServerSyntax("Farm", "error")

            outputChatBox(syntax .. "Az árnak nagyobbnak kell lennie mint 0.", thePlayer, 255, 0, 0, true)
            return
        end

        if utf8.len(name) <= 0 then 
            local syntax = exports.cr_core:getServerSyntax("Farm", "error")

            outputChatBox(syntax .. "A névnek legalább 1 karaktert kell tartalmaznia.", thePlayer, 255, 0, 0, true)
            return
        end

        local playerX, playerY, playerZ = getElementPosition(thePlayer)
        local interior = thePlayer.interior
        local dimension = thePlayer.dimension
        local outPosition = {playerX, playerY, playerZ - 1, interior, dimension}
        local inPosition = {-23.140625, -367.431640625, 5.4296875, 0, thePlayer:getData("acc >> id")}

        dbExec(sql, "INSERT INTO interiors SET name = ?, owner = ?, locked = ?, type = ?, price = ?, outPosition = ?, inPosition = ?, safeSlots = ?, isFarm = ?", name, "false", "false", 7, price, toJSON(outPosition), toJSON(inPosition), 3, "true")
        dbQuery(
            function(queryHandler, thePlayer)
                local query, query_lines = dbPoll(queryHandler, 0)

                if query_lines > 0 then 
                    local row = query[1]

                    local inPosition = fromJSON(row.inPosition)
                    inPosition[5] = row.id

                    dbExec(sql, "UPDATE interiors SET inPosition = ? WHERE id = ?", toJSON(inPosition), row.id)

                    local outX, outY, outZ, outInt, outDim = unpack(fromJSON(row.outPosition))
                    local inX, inY, inZ, inInt, inDim = unpack(inPosition)

                    local outMarker = Marker(outX, outY, outZ - 0.1, "cylinder", 1, convertType(row["type"]))
                    outMarker:setInterior(outInt)
                    outMarker:setDimension(outDim)
                    outMarker:setAlpha(0)

                    local temp
                    if row["owner"] == "false" and row["type"] ~= 2 then 
                        temp = false
                    else 
                        temp = tonumber(row["owner"])
                    end

                    local data = {
                        id = tonumber(row.id),
                        name = row.name,
                        owner = temp,
                        locked = row.locked == "true",
                        type = row.type,
                        price = row.price,
                        elevator = false,
                        isFarm = true,
                        maxSafe = tonumber(row.safeSlots or 3),
                        customInterior = row.customInterior,
                        faction = row.faction
                    }

                    outMarker:setData("marker >> data", data)

                    local inMarker = Marker(inX, inY, inZ, "cylinder", 1, convertType(row["type"]))
                    inMarker:setInterior(inInt)
                    inMarker:setDimension(row.id)
                    inMarker:setAlpha(0)

                    inMarker:setData("parent", outMarker)
                    outMarker:setData("parent", inMarker)

                    cache[row.id] = {outMarker, inMarker}

                    if isElement(thePlayer) then 
                        local localName = exports.cr_admin:getAdminName(thePlayer, true)
                        exports["cr_logs"]:addLog(thePlayer, "Interior", "createfarm", localName .. " létrehozott egy farmot. ID: ".. row.id)

                        local adminSyntax = exports.cr_admin:getAdminSyntax()
                        local syntax = exports.cr_core:getServerSyntax("Farm", "success")
                        local hexColor = exports.cr_core:getServerColor("yellow", true)
                        local white = "#ffffff"

                        outputChatBox(syntax .. "Sikeresen létrehoztál egy farmot. " .. hexColor .. "(" .. row.id .. ")", thePlayer, 255, 0, 0, true)
                        exports.cr_core:sendMessageToAdmin(thePlayer, adminSyntax .. hexColor .. localName .. white .. " létrehozott egy farmot. " .. hexColor .. "(" .. row.id .. ")", 3)
                    end
                end
            end, {thePlayer}, sql, "SELECT * FROM interiors WHERE id = LAST_INSERT_ID()"
        )
    end
end
addCommandHandler("createfarm", createFarmCommand, false, false)

function setInteriorFaction(thePlayer, cmd, intId, factionId)
    if exports.cr_permission:hasPermission(thePlayer, cmd) then 
        if not intId or not factionId then 
            local syntax = exports.cr_core:getServerSyntax(false, "yellow")

            outputChatBox(syntax .. "/" .. cmd .. " [interior id] [frakció id]", thePlayer, 255, 0, 0, true)
            return
        end

        local intId = tonumber(intId)
        local factionId = tonumber(factionId)

        if not intId or not factionId then 
            local syntax = exports.cr_core:getServerSyntax(false, "error")

            outputChatBox(syntax .. "Az interior és a frakció id csak szám lehet.", thePlayer, 255, 0, 0, true)
            return
        end

        if not cache[intId] then 
            local syntax = exports.cr_core:getServerSyntax(false, "error")

            outputChatBox(syntax .. "Nem létezik interior ezzel az id-vel.", thePlayer, 255, 0, 0, true)
            return
        end

        factionId = math.floor(tonumber(factionId))

        local markerElement = cache[intId][1]

        if not isElement(markerElement) then 
            local syntax = exports.cr_core:getServerSyntax(false, "error")

            outputChatBox(syntax .. "Nem létezik az interior bejárata.", thePlayer, 255, 0, 0, true)
            return
        end

        local data = markerElement:getData("marker >> data") or {}

        data.faction = factionId
        markerElement:setData("marker >> data", data)

        dbExec(sql, "UPDATE interiors SET faction = ? WHERE id = ?", factionId, data.id)

        local syntax = exports.cr_core:getServerSyntax(false, "success")
        local hexColor = exports.cr_core:getServerColor("yellow", true)
        local white = "#ffffff"

        outputChatBox(syntax .. "Sikeresen megváltoztattad az interior frakcióját. " .. hexColor .. "(" .. factionId .. ")", thePlayer, 255, 0, 0, true)

        local adminSyntax = exports.cr_admin:getAdminSyntax()
        local localName = exports.cr_admin:getAdminName(thePlayer, true)

        exports.cr_core:sendMessageToAdmin(thePlayer, adminSyntax .. hexColor .. localName .. white .. " megváltoztatta egy interior frakcióját. (Interior id: " .. hexColor .. intId .. white .. ", frakció id: " .. hexColor .. factionId .. white .. ")", 3)
    end
end
addCommandHandler("setinteriorfaction", setInteriorFaction, false, false)
addCommandHandler("setfactioninterior", setInteriorFaction, false, false)

function changeElementInterior(element, other)
    if element and isElement(element) then 
        if not isPedInVehicle(element) then 
            local otherX, otherY, otherZ = getElementPosition(other)
            local otherInterior, otherDimension = getElementInterior(other), getElementDimension(other)

            setElementPosition(element, otherX, otherY, otherZ + 1)
            setElementInterior(element, otherInterior)
            setElementDimension(element, otherDimension)

            if not spawnTimers[element] then 
                triggerClientEvent(root, "ghostMode", element, element, "on")
                setElementAlpha(element, 100)
                spawnTimers[element] = setTimer(
                    function()
                        setElementAlpha(element, 255)
                        triggerClientEvent(root, "ghostMode", element, element, "off")
                        spawnTimers[element] = nil
                    end, 3000, 1
                )
            else 
                if isTimer(spawnTimers[element]) then 
                    killTimer(spawnTimers[element])
                    spawnTimers[element] = nil
                end

                triggerClientEvent(root, "ghostMode", element, element, "on")
                setElementAlpha(element, 100)
                spawnTimers[element] = setTimer(
                    function()
                        setElementAlpha(element, 255)
                        triggerClientEvent(root, "ghostMode", element, element, "off")
                        spawnTimers[element] = nil
                    end, 3000, 1
                )
            end

            local inInterior = element:getData("inInterior")
            
            if isElement(inInterior) then 
                local markerData = inInterior:getData("marker >> data")

                if markerData then 
                    local customInterior = markerData.customInterior

                    if customInterior and customInterior > 0 then 
                        element:setData("customInterior", customInterior)

                        triggerClientEvent(element, "loadCustomInterior", element, customInterior, other)
                    end
                end
            else
                local customInterior = element:getData("customInterior")

                if customInterior and customInterior > 0 then 
                    element:setData("customInterior", 0)
                    triggerClientEvent(element, "destroyCustomInterior", element, customInterior)
                end
            end
        else 
            local vehicle = getPedOccupiedVehicle(element)
            local otherX, otherY, otherZ = getElementPosition(other)
            local otherInterior, otherDimension = getElementInterior(other), getElementDimension(other)
            local occupants = getVehicleOccupants(vehicle)

            setElementPosition(vehicle, otherX, otherY, otherZ + 1)
            setElementInterior(vehicle, otherInterior)
            setElementDimension(vehicle, otherDimension)

            setElementPosition(element, otherX, otherY, otherZ + 1)
            setElementInterior(element, otherInterior)
            setElementDimension(element, otherDimension)

            for k, v in pairs(occupants) do 
                setElementDimension(v, otherDimension)
                setElementInterior(v, otherInterior)
            end
        end
    end
end
addEvent("changeElementInterior", true)
addEventHandler("changeElementInterior", root, changeElementInterior)

function isElementUnderSpawnProtection(element)
    return spawnTimers[element]
end

function buyInterior(thePlayer, sourceMarker)
    if sourceMarker and isElement(sourceMarker) then
        local data = (sourceMarker ~= sourceMarker:getData("parent") and sourceMarker:getData("marker >> data") or sourceMarker:getData("parent"):getData("marker >> data"))
        if exports["cr_core"]:hasMoney(thePlayer, tonumber(data["price"])) then 
            dbExec(sql, "UPDATE interiors SET owner = ? WHERE id = ?", thePlayer:getData("acc >> id"), data["id"])
            exports["cr_core"]:takeMoney(thePlayer, tonumber(data["price"]), false)

            data.owner = tonumber(thePlayer:getData("acc >> id"))
            sourceMarker:setData("marker >> data", data)

            exports["cr_infobox"]:addBox(thePlayer, "success", "Sikeresen megvásároltad az ingatlant "..exports["cr_dx"]:formatMoney(data["price"]).." dollárért.")
            exports["cr_inventory"]:giveItem(thePlayer, 17, data["id"], 1)
        else 
            exports["cr_infobox"]:addBox(thePlayer, "error", "Nincs elég pénzed az ingatlan megvásárlásához. ("..exports["cr_dx"]:formatMoney(data["price"]).." dollár)")
            return 
        end
    end
end
addEvent("buyInterior", true)
addEventHandler("buyInterior", root, buyInterior)

function rentInterior(thePlayer, sourceMarker, typ)
    if sourceMarker and isElement(sourceMarker) then 
        local data = (sourceMarker ~= sourceMarker:getData("parent") and sourceMarker:getData("marker >> data") or sourceMarker:getData("parent"):getData("marker >> data"))
        local result = {} 
        local ownerId = thePlayer:getData("acc >> id")
        local queryString = dbPrepareString(sql, "SELECT * FROM interiors WHERE (type = 3 AND owner = ?) OR (type = 7 AND owner = ?)", ownerId, ownerId)

        dbQuery(
            function(query)
                local query, query_lines = dbPoll(query, 0)
                if query_lines > 0 then 
                    Async:foreach(query,
                        function(row)
                            table.insert(result, row)
                        end,

                        function()
                            if #result == 1 then 
                                if exports.cr_core:hasMoney(thePlayer, tonumber(data.price)) then 
                                    local timestamp = getRealTime().timestamp
                    
                                    local created = timestamp
                                    local expire = timestamp + 604800
                    
                                    dbExec(sql, "UPDATE interiors SET owner = ?, rentDate = ?, expireDate = ? WHERE id = ?", ownerId, created, expire, data.id)
                                    exports.cr_core:takeMoney(thePlayer, tonumber(data["price"]), false)
                    
                                    data.owner = tonumber(ownerId)
                                    sourceMarker:setData("marker >> data", data)
                    
                                    local text = data.type == 3 and "Sikeresen kibérelted az ingatlant " .. exports.cr_dx:formatMoney(data.price) .. " dollárért." or "Sikeresen kibérelted a farmot " .. exports.cr_dx:formatMoney(data.price) .. " dollárért."
                                    exports.cr_infobox:addBox(thePlayer, "success", text)
                    
                                    exports.cr_inventory:giveItem(thePlayer, 17, data.id, 1)
                                else 
                                    local text = data.type == 3 and "Nincs elég pénzed az ingatlan kibérléséhez. ($ " .. exports.cr_dx:formatMoney(data.price) .. ")" or "Nincs elég pénzed a farm kibérléséhez. ($ " .. exports.cr_dx:formatMoney(data.price) .. ")"
                                    
                                    exports.cr_infobox:addBox(thePlayer, "error", text)
                                end
                            else
                                exports.cr_infobox:addBox(thePlayer, "error", "Csak egy bérházad / farmod lehet.")
                            end
                        end
                    ) 
                else
                    if exports.cr_core:hasMoney(thePlayer, tonumber(data.price)) then 
                        local timestamp = getRealTime().timestamp
        
                        local created = timestamp
                        local expire = timestamp + 604800
        
                        dbExec(sql, "UPDATE interiors SET owner = ?, rentDate = ?, expireDate = ? WHERE id = ?", ownerId, created, expire, data.id)
                        exports.cr_core:takeMoney(thePlayer, tonumber(data["price"]), false)
        
                        data.owner = tonumber(ownerId)
                        sourceMarker:setData("marker >> data", data)
        
                        local text = data.type == 3 and "Sikeresen kibérelted az ingatlant " .. exports.cr_dx:formatMoney(data.price) .. " dollárért." or "Sikeresen kibérelted a farmot " .. exports.cr_dx:formatMoney(data.price) .. " dollárért."
                        exports.cr_infobox:addBox(thePlayer, "success", text)
        
                        exports.cr_inventory:giveItem(thePlayer, 17, data.id, 1)
                    else 
                        local text = data.type == 3 and "Nincs elég pénzed az ingatlan kibérléséhez. ($ " .. exports.cr_dx:formatMoney(data.price) .. ")" or "Nincs elég pénzed a farm kibérléséhez. ($ " .. exports.cr_dx:formatMoney(data.price) .. ")"
                        
                        exports.cr_infobox:addBox(thePlayer, "error", text)
                    end
                end
            end, sql, queryString
        )

        -- setTimer(
        --     function()
        --         if #result <= 0 then 
                    -- if exports["cr_core"]:hasMoney(thePlayer, tonumber(data["price"])) then 
                    --     local timestamp = getRealTime()["timestamp"]
        
                    --     local created = timestamp
                    --     local expire = timestamp + 604800
        
                    --     dbExec(sql, "UPDATE interiors SET owner = ?, rentDate = ?, expireDate = ? WHERE id = ?", thePlayer:getData("acc >> id"), created, expire, data["id"])
                    --     exports["cr_core"]:takeMoney(thePlayer, tonumber(data["price"]), false)
        
                    --     data.owner = tonumber(thePlayer:getData("acc >> id"))
                    --     sourceMarker:setData("marker >> data", data)
        
                    --     exports["cr_infobox"]:addBox(thePlayer, "success", "Sikeresen kibérelted az ingatlant "..exports["cr_dx"]:formatMoney(data["price"]).." dollárért.")
        
                    --     exports["cr_inventory"]:giveItem(thePlayer, 17, data["id"], 1)
                    -- else 
                    --     exports["cr_infobox"]:addBox(thePlayer, "error", "Nincs elég pénzed az ingatlan kibérléséhez. ("..exports["cr_dx"]:formatMoney(data["price"]).." dollár)")
                    --     return 
                    -- end
        --         else 
        --             exports["cr_infobox"]:addBox(thePlayer, "error", "Csak egy bérházat bérelhetsz ki.")
        --             return 
        --         end
        --     end, 100, 1
        -- )
    end
end
addEvent("rentInterior", true)
addEventHandler("rentInterior", root, rentInterior)

function lockInterior(thePlayer, sourceMarker)
    if sourceMarker and isElement(sourceMarker) then 
        local data = sourceMarker:getData("marker >> data")

        if data["type"] ~= 6 then 
            local temp
            if data["owner"] == "false" and tonumber(data["type"]) ~= 2 then 
                temp = false
            else 
                if tonumber(data["type"]) == 2 then 
                    temp = "Önkormányzat"
                else
                    temp = tonumber(data["owner"])
                end
            end

            data.owner = temp
            data.locked = not data.locked

            sourceMarker:setData("marker >> data", data)
        else 
            data.owner = "elevator"
            data.locked = not data.locked
            data.maxSafe = 0
            data.customInterior = 0

            sourceMarker:setData("marker >> data", data)
        end
    end
end
addEvent("lockInterior", true)
addEventHandler("lockInterior", root, lockInterior)

function bellInterior(thePlayer, other, players)
    if other and isElement(other) then 
        exports["cr_chat"]:createMessage(thePlayer, "megnyomja a csengőt.", 1)
        sendSound(thePlayer, thePlayer, "bell", thePlayer)
        sendSound(thePlayer, other, "bell", players)
    end
end
addEvent("bellInterior", true)
addEventHandler("bellInterior", root, bellInterior)

function knockInterior(thePlayer, other, players)
    if other and isElement(other) then 
        exports["cr_chat"]:createMessage(thePlayer, "bekopog az ajtón.", 1)
        sendSound(thePlayer, thePlayer, "knock", thePlayer)
        sendSound(thePlayer, other, "knock", players)
    end
end
addEvent("knockInterior", true)
addEventHandler("knockInterior", root, knockInterior)

function getRentedInterior(thePlayer)
    local result = {}
    local ownerId = thePlayer:getData("acc >> id")

    dbQuery(
        function(query)
            local query, query_lines = dbPoll(query, 0)
            
            if query_lines > 0 then 
                Async:foreach(query,
                    function(row)
                        -- data = {["owner"] = row["owner"], ["name"] = row["name"], ["price"] = row["price"]}
                        table.insert(result, row)
                    end,

                    function()
                        if isElement(thePlayer) then 
                            triggerClientEvent(thePlayer, "receiveRentedInterior", thePlayer, result)
                        end
                    end
                )
            else 
                triggerClientEvent(thePlayer, "receiveRentedInterior", thePlayer, result)
            end
        end, sql, "SELECT * FROM interiors WHERE (type = 3 AND owner = ?) OR (type = 7 AND owner = ?)", ownerId, ownerId
    )
end
addEvent("getRentedInterior", true)
addEventHandler("getRentedInterior", root, getRentedInterior)

function renewInterior(data)
    if isElement(client) and data then 
        if #data == 1 then 
            data = data[1]

            dbQuery(
                function(queryHandler, thePlayer)
                    local query, query_lines = dbPoll(queryHandler, 0)

                    if query_lines > 0 then 
                        local row = query[1]

                        local timestamp = getRealTime().timestamp
                        local rentStamp = row.rentDate
                        local expireStamp = row.expireDate
                        local rentDate = getRealTime(rentStamp)
                        local expireDate = getRealTime(expireStamp)
                        local newExpireDate = timestamp + 604800

                        if expireStamp - 86400 < timestamp then 
                            if exports.cr_core:hasMoney(thePlayer, tonumber(row.price)) then 
                                dbExec(sql, "UPDATE interiors SET expireDate = ? WHERE type = ? AND owner = ?", newExpireDate, row.type, row.owner)
                                
                                exports.cr_core:takeMoney(thePlayer, tonumber(row.price), false)
                                exports.cr_infobox:addBox(thePlayer, "success", "Sikeresen meghosszabítottad 1 héttel az ingatlanodat. (" .. row.name .. ")")
                            else 
                                exports.cr_infobox:addBox(thePlayer, "error", "Nincs elég pénzed az ingatlanod meghosszabításához. ($ " .. exports.cr_dx:formatMoney(tonumber(row.price)) .. ")")
                            end
                        else 
                            exports.cr_infobox:addBox(thePlayer, "error", "Csak a lejárati dátum előtt 1 nappal tudod meghosszabítani az ingatlanod.") 
                        end
                    end
                end, {client}, sql, "SELECT * FROM interiors WHERE type = ? AND rentDate > 0 AND expireDate > 0 AND owner = ? AND id = ?", data.type, data.owner, data.id
            )
        elseif #data > 1 then
            local currentTimestamp = getRealTime().timestamp
            local gData = {}

            for k, v in pairs(data) do 
                if tonumber(v.expireDate) - 86400 < currentTimestamp then 
                    table.insert(gData, v)
                end
            end

            if #gData == 0 then
                exports.cr_infobox:addBox(client, "info", "Az összes ingatlanod be van jelentve.")
            elseif #gData == 1 then 
                local data = gData[1]

                dbQuery(
                    function(queryHandler, thePlayer)
                        local query, query_lines = dbPoll(queryHandler, 0)

                        if query_lines > 0 then 
                            local row = query[1]

                            local timestamp = getRealTime().timestamp
                            local rentStamp = row.rentDate
                            local expireStamp = row.expireDate
                            local rentDate = getRealTime(rentStamp)
                            local expireDate = getRealTime(expireStamp)
                            local newExpireDate = timestamp + 604800

                            if expireStamp - 86400 < timestamp then 
                                if exports.cr_core:hasMoney(thePlayer, tonumber(row.price)) then 
                                    dbExec(sql, "UPDATE interiors SET expireDate = ? WHERE type = ? AND owner = ?", newExpireDate, row.type, row.owner)
                                    
                                    exports.cr_core:takeMoney(thePlayer, tonumber(row.price), false)
                                    exports.cr_infobox:addBox(thePlayer, "success", "Sikeresen meghosszabítottad 1 héttel az ingatlanodat. (" .. row.name .. ")")
                                else 
                                    exports.cr_infobox:addBox(thePlayer, "error", "Nincs elég pénzed az ingatlanod meghosszabításához. ($ " .. exports.cr_dx:formatMoney(tonumber(row.price)) .. ")")
                                end
                            else 
                                exports.cr_infobox:addBox(thePlayer, "error", "Csak a lejárati dátum előtt 1 nappal tudod meghosszabítani az ingatlanod.") 
                            end
                        end
                    end, {client}, sql, "SELECT * FROM interiors WHERE type = ? AND rentDate > 0 AND expireDate > 0 AND owner = ? AND id = ?", data.type, data.owner, data.id
                )
            elseif #gData > 1 then
                for i = 1, #gData do 
                    local v = gData[i]

                    if v then 
                        dbQuery(
                            function(queryHandler, thePlayer)
                                local query, query_lines = dbPoll(queryHandler, 0)

                                if query_lines > 0 then 
                                    local row = query[1]

                                    local timestamp = getRealTime().timestamp
                                    local rentStamp = row.rentDate
                                    local expireStamp = row.expireDate
                                    local rentDate = getRealTime(rentStamp)
                                    local expireDate = getRealTime(expireStamp)
                                    local newExpireDate = timestamp + 604800

                                    if expireStamp - 86400 < timestamp then 
                                        if exports.cr_core:hasMoney(thePlayer, tonumber(row.price)) then 
                                            dbExec(sql, "UPDATE interiors SET expireDate = ? WHERE type = ? AND owner = ?", newExpireDate, row.type, row.owner)
                                            
                                            exports.cr_core:takeMoney(thePlayer, tonumber(row.price), false)
                                            exports.cr_infobox:addBox(thePlayer, "success", "Sikeresen meghosszabítottad 1 héttel az ingatlanodat. (" .. row.name .. ")")
                                        else 
                                            exports.cr_infobox:addBox(thePlayer, "error", "Nincs elég pénzed az ingatlanod meghosszabításához. ($ " .. exports.cr_dx:formatMoney(tonumber(row.price)) .. ")")
                                        end
                                    else 
                                        exports.cr_infobox:addBox(thePlayer, "error", "Csak a lejárati dátum előtt 1 nappal tudod meghosszabítani az ingatlanod.") 
                                    end
                                end
                            end, {client}, sql, "SELECT * FROM interiors WHERE type = ? AND rentDate > 0 AND expireDate > 0 AND owner = ? AND id = ?", v.type, v.owner, v.id
                        )
                    end
                end
            end
        end
    end
end
addEvent("renewInterior", true)
addEventHandler("renewInterior", root, renewInterior)

function updateInteriorSafeSlots(element, newSlots)
    local data = element:getData("marker >> data")

    if data then 
        dbExec(sql, 'UPDATE interiors SET safeSlots = ? WHERE id = ?', newSlots, tonumber(data['id']))
    end 
end 
addEvent("updateInteriorSafeSlots", true)
addEventHandler("updateInteriorSafeSlots", root, updateInteriorSafeSlots)

function resignateInterior(data)
    if isElement(client) and data then 
        if #data == 1 then 
            data = data[1]

            dbQuery(
                function(queryHandler, thePlayer)
                    local query, query_lines = dbPoll(queryHandler, 0)

                    if query_lines > 0 then 
                        local row = query[1]

                        if exports.cr_core:hasMoney(thePlayer, tonumber(row.price)) then 
                            local outMarker = cache[row.id][1]
                            local data = outMarker:getData("marker >> data")

                            dbExec(sql, "UPDATE interiors SET rentDate = '0', expireDate = '0', owner = 'false' WHERE type = ? AND owner = ? AND id = ?", row.type, thePlayer:getData("acc >> id"), tonumber(row.id))

                            data.owner = false
                            exports.cr_core:takeMoney(thePlayer, tonumber(row.price), false)

                            if isElement(outMarker) then 
                                outMarker:setData("marker >> data", data)
                            end
        
                            exports.cr_infobox:addBox(thePlayer, "success", "Sikeresen lemondtad az ingatlanodat. (" .. row.name .. ")")
                        else 
                            exports.cr_infobox:addBox(thePlayer, "error", "Nincs elég pénzed az ingatlanod lemondásához. ($ " .. exports.cr_dx:formatMoney(tonumber(row.price)) .. ")")
                        end
                    end
                end, {client}, sql, "SELECT * FROM interiors WHERE type = ? AND rentDate > 0 AND expireDate > 0 AND owner = ? AND id = ?", data.type, data.owner, data.id
            )
        elseif #data > 1 then
            for k, v in pairs(data) do 
                dbQuery(
                    function(queryHandler, thePlayer)
                        local query, query_lines = dbPoll(queryHandler, 0)

                        if query_lines > 0 then 
                            local row = query[1]

                            if exports.cr_core:hasMoney(thePlayer, tonumber(row.price)) then 
                                local outMarker = cache[row.id][1]
                                local data = outMarker:getData("marker >> data")

                                iprint(row.id)
                                dbExec(sql, "UPDATE interiors SET rentDate = '0', expireDate = '0', owner = 'false' WHERE type = ? AND owner = ? AND id = ?", row.type, thePlayer:getData("acc >> id"), tonumber(row.id))

                                data.owner = false
                                exports.cr_core:takeMoney(thePlayer, tonumber(row.price), false)

                                if isElement(outMarker) then 
                                    outMarker:setData("marker >> data", data)
                                end
            
                                exports.cr_infobox:addBox(thePlayer, "success", "Sikeresen lemondtad az ingatlanodat. (" .. row.name .. ")")
                            else 
                                exports.cr_infobox:addBox(thePlayer, "error", "Nincs elég pénzed az ingatlanod lemondásához. ($ " .. exports.cr_dx:formatMoney(tonumber(row.price)) .. ")")
                            end
                        end
                    end, {client}, sql, "SELECT * FROM interiors WHERE type = ? AND rentDate > 0 AND expireDate > 0 AND owner = ? AND id = ?", v.type, v.owner, v.id
                )
            end
        end
    end
end
addEvent("resignateInterior", true)
addEventHandler("resignateInterior", root, resignateInterior)

function sendSound(thePlayer, element, filePath, players)
    triggerLatentClientEvent(players, "receiveSound", 50000, false, thePlayer, thePlayer, element, filePath)
end