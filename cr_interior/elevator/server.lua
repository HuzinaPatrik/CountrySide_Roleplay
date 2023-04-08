local sql = exports["cr_mysql"]:getConnection(getThisResource())
addEventHandler("onResourceStart", root, 
    function(startedRes)
        if getResourceName(startedRes) == "cr_mysql" then
            sql = exports["cr_mysql"]:getConnection(getThisResource())
            restartResource(getThisResource())
        elseif startedRes == getThisResource() then 
            loadElevators()
        end
    end
)

local elevatorCache = {}
local elevatorElementCache = {}

function loadElevators()
    local startTick = getTickCount()
    local _loaded = 0
    dbQuery(
        function(query)
            local query, query_lines = dbPoll(query, 0)
            if query_lines > 0 then 
                Async:foreach(query,
                    function(row)
                        _loaded = _loaded + 1

                        local id = tonumber(row["id"])
                        local name = tostring(row["name"])
                        local locked = tostring(row["locked"])
                        local outX, outY, outZ, outInt, outDim = unpack(fromJSON(row["outPosition"]))
                        local inX, inY, inZ, inInt, inDim = unpack(fromJSON(row["inPosition"]))
                        local invisible = tonumber(row.invisible)
                        local spawnProtection = tonumber(row['spawnProtection']) or 0

                        local outMarker = Marker(outX, outY, outZ - 0.1, "cylinder", 1, 124, 197, 118)
                        outMarker:setInterior(outInt)
                        outMarker:setDimension(outDim)
                        outMarker:setAlpha(0)

                        outMarker:setData("marker >> data", {
                            ["id"] = id,
                            ["name"] = name,
                            ["owner"] = "elevator",
                            ["locked"] = (locked == "true" and true or false),
                            ["type"] = 6,
                            ["price"] = 1,
                            ["elevator"] = true,
                            ['spawnProtection'] = spawnProtection == 1,
                        })

                        outMarker:setData("marker >> invisible", invisible == 1)

                        local inMarker = false

                        if inX and inY and inZ and inInt and inDim then 
                            inMarker = Marker(inX, inY, inZ, "cylinder", 1, 255, 197, 118)
                            inMarker:setInterior(inInt)
                            inMarker:setDimension(inDim)
                            inMarker:setAlpha(0)

                            inMarker:setData("parent", outMarker)
                            outMarker:setData("parent", inMarker)
                            inMarker:setData("marker >> invisible", invisible == 1)
                        end

                        elevatorCache[id] = {name, startPosition, endPosition}
                        elevatorElementCache[id] = {outMarker, inMarker}
                    end,

                    function()
                        collectgarbage("collect")
                        outputDebugString("@loadElevators: loaded ".._loaded.." / "..query_lines.." elevator(s) in "..getTickCount() - startTick.." ms.", 0, 255, 50, 255)
                    end
                )
            end
        end, sql, "SELECT * FROM elevators"
    )
end

function createElevator(thePlayer, cmd, ...)
    if exports["cr_permission"]:hasPermission(thePlayer, cmd) then 
        if not ... then 
            local syntax = exports["cr_core"]:getServerSyntax(false, "lightyellow")
            outputChatBox(syntax.."/"..cmd.." [név]", thePlayer, 255, 0, 0, true)
            return 
        else 
            local name = table.concat({...}, " ")

            if name:len() > 0 then 
                local outPosition = thePlayer.position 
                local outInt = thePlayer.interior 
                local outDim = thePlayer.dimension
                local cache = toJSON({outPosition["x"], outPosition["y"], outPosition["z"] - 1, outInt, outDim})

                dbExec(sql, "INSERT INTO elevators SET name = ?, outPosition = ?, inPosition = ?", name, cache, toJSON({}))
                
                dbQuery(
                    function(query)
                        local query, query_lines = dbPoll(query, 0)
                        if query_lines > 0 then 
                            Async:foreach(query,
                                function(row)
                                    local startTick = getTickCount()
                                    local id = tonumber(row["id"])
                                    local name = tostring(row["name"])
                                    local locked = tostring(row["locked"])
                                    local outX, outY, outZ, outInt, outDim = unpack(fromJSON(row["outPosition"]))
                                    local inX, inY, inZ, inInt, inDim = unpack(fromJSON(row["inPosition"]))

                                    local outMarker = Marker(outX, outY, outZ - 0.1, "cylinder", 1, 124, 197, 118)
                                    outMarker:setInterior(outInt)
                                    outMarker:setDimension(outDim)
                                    outMarker:setAlpha(0)

                                    outMarker:setData("marker >> data", {
                                        ["id"] = id,
                                        ["name"] = name,
                                        ["owner"] = "elevator",
                                        ["locked"] = (locked == "true" and true or false),
                                        ["type"] = 6,
                                        ["price"] = 1,
                                        ["elevator"] = true,
                                    })
                                    outMarker:setData("parent", false)

                                    elevatorCache[id] = {name, startPosition, endPosition}
                                    elevatorElementCache[id] = {outMarker, false}
                                    outputDebugString("@loadElevators: loaded 1 elevator in "..getTickCount() - startTick.." ms.", 0, 255, 50, 255)

                                    local syntax = exports["cr_core"]:getServerSyntax(false, "green")
                                    local greenHex = exports["cr_core"]:getServerColor("green", true)
                                    local serverHex = exports["cr_core"]:getServerColor("yellow", true)
                                    outputChatBox(syntax.."Sikeresen létrehoztál egy liftet. Most állítsd be a kijáratát a "..greenHex.."/setelevatorexit#ffffff paranccsal.", thePlayer, 255, 0, 0, true)
                                    triggerLatentClientEvent(thePlayer, "alertAdmins", 50000, thePlayer, "#ffffff létrehozott egy liftet. "..serverHex.."("..id..")")
                                    exports["cr_logs"]:addLog(thePlayer, "Elevator", "createelevator", exports["cr_admin"]:getAdminName(thePlayer, true).." létrehozott egy liftet. ("..id..")")
                                end
                            )
                        end
                    end, sql, "SELECT * FROM elevators WHERE id = LAST_INSERT_ID()"
                )
            else 
                local syntax = exports["cr_core"]:getServerSyntax(false, "red")
                outputChatBox(syntax.."A névnek legalább 1 karaktert kell tartalmaznia.", thePlayer, 255, 0, 0, true)
                return 
            end
        end
    end
end
addCommandHandler("createelevator", createElevator, false, false)

function deleteElevator(thePlayer, cmd, id)
    if exports["cr_permission"]:hasPermission(thePlayer, cmd) then 
        if not id then 
            local syntax = exports["cr_core"]:getServerSyntax(false, "lightyellow")
            outputChatBox(syntax.."/"..cmd.." [id]", thePlayer, 255, 0, 0, true)
            return 
        else 
            local id = tonumber(id)

            if id ~= nil then 
                if id > 0 then 
                    if elevatorCache[id] then 
                        if elevatorElementCache[id] then 
                            if isElement(elevatorElementCache[id][1]) then 
                                elevatorElementCache[id][1]:destroy()
                            end
                            if isElement(elevatorElementCache[id][2]) then 
                                elevatorElementCache[id][2]:destroy()
                            end
                            elevatorElementCache[id] = nil
                            elevatorCache[id] = nil
                            collectgarbage("collect")

                            dbExec(sql, "DELETE FROM elevators WHERE id = ?", id)

                            local syntax = exports["cr_core"]:getServerSyntax(false, "green")
                            local serverHex = exports["cr_core"]:getServerColor("yellow", true)
                            outputChatBox(syntax.."Sikeresen kitöröltél egy liftet. "..serverHex.."("..id..")", thePlayer, 255, 0, 0, true)
                            triggerLatentClientEvent(thePlayer, "alertAdmins", 50000, false, thePlayer, "#ffffff kitörölt egy liftet. "..serverHex.."("..id..")")
                            exports["cr_logs"]:addLog(thePlayer, "Elevator", "deleteelevator", exports["cr_admin"]:getAdminName(thePlayer, true).." törölt egy liftet. ("..id..")")
                        else 
                            local syntax = exports["cr_core"]:getServerSyntax(false, "red")
                            outputChatBox(syntax.."Nincs ilyen id az element cache-ben.", thePlayer, 255, 0, 0, true)
                            return 
                        end
                    else 
                        local syntax = exports["cr_core"]:getServerSyntax(false, "red")
                        outputChatBox(syntax.."Nincs ilyen id a cache-ben.", thePlayer, 255, 0, 0, true)
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
addCommandHandler("deleteelevator", deleteElevator, false, false)

function setElevatorEnter(thePlayer, cmd, id)
    if exports["cr_permission"]:hasPermission(thePlayer, cmd) then 
        if not id then 
            local syntax = exports["cr_core"]:getServerSyntax(false, "lightyellow")
            outputChatBox(syntax.."/"..cmd.." [id]", thePlayer, 255, 0, 0, true)
            return 
        else 
            local id = tonumber(id)

            if id ~= nil then 
                if id > 0 then 
                    if elevatorCache[id] then 
                        if elevatorElementCache[id][1] then 
                            if isElement(elevatorElementCache[id][1]) then 
                                local position = thePlayer.position 
                                local interior = thePlayer.interior 
                                local dimension = thePlayer.dimension 

                                dbExec(sql, "UPDATE elevators SET outPosition = ? WHERE id = ?", toJSON({position["x"], position["y"], position["z"] - 1, interior, dimension}), id)

                                elevatorElementCache[id][1].position = Vector3(position["x"], position["y"], position["z"] - 1)

                                local syntax = exports["cr_core"]:getServerSyntax(false, "green")
                                local serverHex = exports["cr_core"]:getServerColor("yellow", true)
                                outputChatBox(syntax.."Sikeresen megváltoztattad egy liftnek a bejáratát. "..serverHex.."("..id..")", thePlayer, 255, 0, 0, true)
                                triggerLatentClientEvent(thePlayer, "alertAdmins", 50000, false, thePlayer, "#ffffff megváltoztatta egy liftnek a bejáratát. "..serverHex.."("..id..")")
                                exports["cr_logs"]:addLog(thePlayer, "Elevator", "setelevatorenter", exports["cr_admin"]:getAdminName(thePlayer, true).." megváltoztatta egy liftnek a bejáratát. ("..id..")")
                            else 
                                local syntax = exports["cr_core"]:getServerSyntax(false, "red")
                                outputChatBox(syntax.."Hiba, nincs a liftnek bejárata.", thePlayer, 255, 0, 0, true)
                                return 
                            end
                        else 
                            local syntax = exports["cr_core"]:getServerSyntax(false, "red")
                            outputChatBox(syntax.."Nincs ilyen id az element cache-ben.", thePlayer, 255, 0, 0, true)
                            return 
                        end
                    else 
                        local syntax = exports["cr_core"]:getServerSyntax(false, "red")
                        outputChatBox(syntax.."Nincs ilyen id a cache-ben.", thePlayer, 255, 0, 0, true)
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
addCommandHandler("setelevatorenter", setElevatorEnter, false, false)

function setElevatorExit(thePlayer, cmd, id)
    if exports["cr_permission"]:hasPermission(thePlayer, cmd) then 
        if not id then 
            local syntax = exports["cr_core"]:getServerSyntax(false, "lightyellow")
            outputChatBox(syntax.."/"..cmd.." [id]", thePlayer, 255, 0, 0, true)
            return 
        else 
            local id = tonumber(id)

            if id ~= nil then 
                if id > 0 then 
                    if elevatorCache[id] then 
                        if isElement(elevatorElementCache[id][1]) then 
                            if not elevatorElementCache[id][2] or not isElement(elevatorElementCache[id][2]) then 
                                local position = thePlayer.position 
                                local interior = thePlayer.interior 
                                local dimension = thePlayer.dimension 

                                dbExec(sql, "UPDATE elevators SET inPosition = ? WHERE id = ?", toJSON({position["x"], position["y"], position["z"] - 1, interior, dimension}), id)

                                local inMarker = Marker(position["x"], position["y"], position["z"] - 1, "cylinder", 1, 124, 197, 118)
                                inMarker:setInterior(interior)
                                inMarker:setDimension(dimension)
                                inMarker:setAlpha(0)
                                inMarker:setData("parent", elevatorElementCache[id][1])
                                elevatorElementCache[id][1]:setData("parent", inMarker)

                                elevatorElementCache[id][2] = inMarker

                                local syntax = exports["cr_core"]:getServerSyntax(false, "green")
                                local serverHex = exports["cr_core"]:getServerColor("yellow", true)
                                outputChatBox(syntax.."Sikeresen beállítottad egy liftnek a kijáratát. "..serverHex.."("..id..")", thePlayer, 255, 0, 0, true)
                                triggerLatentClientEvent(thePlayer, "alertAdmins", 50000, false, thePlayer, "#ffffff beállította egy liftnek a kijáratát. "..serverHex.."("..id..")")
                                exports["cr_logs"]:addLog(thePlayer, "Elevator", "setelevatorexit", exports["cr_admin"]:getAdminName(thePlayer, true).." beállította egy liftnek a kijáratát. ("..id..")")
                            else 
                                local position = thePlayer.position 
                                local interior = thePlayer.interior 
                                local dimension = thePlayer.dimension 

                                dbExec(sql, "UPDATE elevators SET inPosition = ? WHERE id = ?", toJSON({position["x"], position["y"], position["z"] - 1, interior, dimension}), id)

                                elevatorElementCache[id][2].position = Vector3(position["x"], position["y"], position["z"] - 1)

                                local syntax = exports["cr_core"]:getServerSyntax(false, "green")
                                local serverHex = exports["cr_core"]:getServerColor("yellow", true)
                                outputChatBox(syntax.."Sikeresen megváltoztattad egy liftnek a kijáratát. "..serverHex.."("..id..")", thePlayer, 255, 0, 0, true)
                                triggerLatentClientEvent(thePlayer, "alertAdmins", 50000, false, thePlayer, "#ffffff megváltoztatta egy liftnek a kijáratát. "..serverHex.."("..id..")")
                                exports["cr_logs"]:addLog(thePlayer, "Elevator", "setelevatorexit", exports["cr_admin"]:getAdminName(thePlayer, true).." megváltoztatta egy liftnek a kijáratát. ("..id..")")
                            end
                        else 
                            local syntax = exports["cr_core"]:getServerSyntax(false, "red")
                            outputChatBox(syntax.."Hiba, nincs a liftnek bejárata.", thePlayer, 255, 0, 0, true)
                            return 
                        end
                    else 
                        local syntax = exports["cr_core"]:getServerSyntax(false, "red")
                        outputChatBox(syntax.."Nincs ilyen id a cache-ben.", thePlayer, 255, 0, 0, true)
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
addCommandHandler("setelevatorexit", setElevatorExit, false, false)

function setElevatorName(thePlayer, cmd, id, ...)
    if exports["cr_permission"]:hasPermission(thePlayer, cmd) then 
        if not id or not ... then 
            local syntax = exports["cr_core"]:getServerSyntax(false, "lightyellow")
            outputChatBox(syntax.."/"..cmd.." [id] [név]", thePlayer, 255, 0, 0, true)
            return 
        else 
            local id = tonumber(id)
            local name = table.concat({...}, " ")

            if id ~= nil then 
                if id > 0 then 
                    if name:len() > 0 then 
                        if elevatorCache[id] then 
                            if elevatorElementCache[id][1] and elevatorElementCache[id][2] then 
                                if isElement(elevatorElementCache[id][1]) and isElement(elevatorElementCache[id][2]) then 
                                    dbExec(sql, "UPDATE elevators SET name = ? WHERE id = ?", name, id)

                                    elevatorCache[id][1] = name

                                    local data = elevatorElementCache[id][1]:getData("marker >> data")
                                    data.name = name

                                    elevatorElementCache[id][1]:setData("marker >> data", data)

                                    local syntax = exports["cr_core"]:getServerSyntax(false, "green")
                                    local serverHex = exports["cr_core"]:getServerColor("yellow", true)
                                    outputChatBox(syntax.."Sikeresen megváltoztattad egy lift nevét. Új név: "..serverHex..name.."#ffffff, id: "..serverHex..id, thePlayer, 255, 0, 0, true)
                                    triggerLatentClientEvent(thePlayer, "alertAdmins", 50000, false, thePlayer, "#ffffff megváltoztatta egy liftnek a nevét. Új név: "..serverHex..name.."#ffffff, id: "..serverHex..id)
                                    exports["cr_logs"]:addLog(thePlayer, "Elevator", "setelevatorexit", exports["cr_admin"]:getAdminName(thePlayer, true).." megváltoztatta egy liftnek a nevét. Új név: "..name.."#ffffff, id: "..id)
                                end
                            else 
                                local syntax = exports["cr_core"]:getServerSyntax(false, "red")
                                outputChatBox(syntax.."Hiba, a lift kijárata vagy a bejárata nem létezik.", thePlayer, 255, 0, 0, true)
                                return 
                            end
                        else 
                            local syntax = exports["cr_core"]:getServerSyntax(false, "red")
                            outputChatBox(syntax.."Nincs ilyen id a cache-ben.", thePlayer, 255, 0, 0, true)
                            return 
                        end
                    else 
                        local syntax = exports["cr_core"]:getServerSyntax(false, "red")
                        outputChatBox(syntax.."A névnek legalább 1 karaktert kell tartalmaznia.", thePlayer, 255, 0, 0, true)
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
addCommandHandler("setelevatorname", setElevatorName, false, false)

function gotoElevator(thePlayer, cmd, id)
    if exports["cr_permission"]:hasPermission(thePlayer, cmd) then 
        if not id then 
            local syntax = exports["cr_core"]:getServerSyntax(false, "lightyellow")
            outputChatBox(syntax.."/"..cmd.." [id]", thePlayer, 255, 0, 0, true)
            return 
        else 
            local id = tonumber(id)

            if id ~= nil then 
                if id > 0 then 
                    if elevatorCache[id] then 
                        if elevatorElementCache[id] then 
                            if isElement(elevatorElementCache[id][1]) then 
                                local position = elevatorElementCache[id][1].position 
                                local interior = elevatorElementCache[id][1].interior 
                                local dimension = elevatorElementCache[id][1].dimension 

                                thePlayer.position = Vector3(position["x"], position["y"], position["z"] + 1)
                                thePlayer.interior = interior 
                                thePlayer.dimension = dimension 

                                local syntax = exports["cr_core"]:getServerSyntax(false, "green")
                                local serverHex = exports["cr_core"]:getServerColor("yellow", true)
                                outputChatBox(syntax.."Sikeresen elteleportáltál egy lifthez. "..serverHex.."("..id..")", thePlayer, 255, 0, 0, true)
                                triggerLatentClientEvent(thePlayer, "alertAdmins", 50000, false, thePlayer, "#ffffff elteleportált egy lifthez. "..serverHex.."("..id..")")
                                exports["cr_logs"]:addLog(thePlayer, "Elevator", "setelevatorexit", exports["cr_admin"]:getAdminName(thePlayer, true).." elteleportált egy lifthez. ("..id..")")
                            else 
                                local syntax = exports["cr_core"]:getServerSyntax(false, "red")
                                outputChatBox(syntax.."Hiba, nem létezik a lift bejárata.", thePlayer, 255, 0, 0, true)
                                return 
                            end
                        else 
                            local syntax = exports["cr_core"]:getServerSyntax(false, "red")
                            outputChatBox(syntax.."Nincs ilyen id az element cache-ben.", thePlayer, 255, 0, 0, true)
                            return 
                        end
                    else 
                        local syntax = exports["cr_core"]:getServerSyntax(false, "red")
                        outputChatBox(syntax.."Nincs ilyen id a cache-ben.", thePlayer, 255, 0, 0, true)
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
addCommandHandler("gotoelevator", gotoElevator, false, false)

function setElevatorInvisible(thePlayer, cmd, id, value)
    if exports.cr_permission:hasPermission(thePlayer, cmd) then 
        if not id or not value then 
            local syntax = exports.cr_core:getServerSyntax(false, "lightyellow")

            outputChatBox(syntax .. "/" .. cmd .. " [id] [0 = látható, 1 = láthatatlan]", thePlayer, 255, 0, 0, true)
            return
        end

        local id = tonumber(id)
        local value = tonumber(value)

        if not id or not value then 
            local syntax = exports.cr_core:getServerSyntax(false, "error")

            outputChatBox(syntax .. "Az id és az érték csak szám lehet.", thePlayer, 255, 0, 0, true)
            return
        end

        value = math.floor(tonumber(value))

        if value ~= 0 and value ~= 1 then 
            local syntax = exports.cr_core:getServerSyntax(false, "error")

            outputChatBox(syntax .. "Az érték csak 0 vagy 1 lehet.", thePlayer, 255, 0, 0, true)
            return
        end

        if not elevatorElementCache[id] then 
            local syntax = exports.cr_core:getServerSyntax(false, "error")

            outputChatBox(syntax .. "Nem létezik lift ezzel az id-vel.", thePlayer, 255, 0, 0, true)
            return
        else
            if not isElement(elevatorElementCache[id][1]) or not isElement(elevatorElementCache[id][2]) then 
                local syntax = exports.cr_core:getServerSyntax(false, "error")

                outputChatBox(syntax .. "Nem létezik a lift kijárata.", thePlayer, 255, 0, 0, true)
                return
            end
        end

        if isElement(elevatorElementCache[id][1]) and isElement(elevatorElementCache[id][2]) then 
            if value == 1 then 
                if not elevatorElementCache[id][1]:getData("marker >> invisible") and not elevatorElementCache[id][2]:getData("marker >> invisible") then 
                    elevatorElementCache[id][1]:setData("marker >> invisible", true)
                    elevatorElementCache[id][2]:setData("marker >> invisible", true)

                    local syntax = exports.cr_core:getServerSyntax(false, "success")
                    local adminSyntax = exports.cr_admin:getAdminSyntax()

                    local hexColor = exports.cr_core:getServerColor("yellow", true)
                    local adminName = exports.cr_admin:getAdminName(thePlayer, true)
                    local visiblityState = value == 1 and "látható" or "láthatatlan"

                    outputChatBox(syntax .. "Sikeresen megváltoztattad a lift láthatóságát. " .. hexColor .. "(" .. id .. ") " .. white .. "Státusz: " .. hexColor .. visiblityState, thePlayer, 255, 0, 0, true)
                    exports.cr_core:sendMessageToAdmin(thePlayer, adminSyntax .. hexColor .. adminName .. white .. " megváltoztatta egy liftnek a láthatóságát. " .. hexColor .. "(" .. id .. ") " .. white .. "Státusz: " .. hexColor .. visiblityState, 8)
                else 
                    local syntax = exports.cr_core:getServerSyntax(false, "error")

                    outputChatBox(syntax .. "Ez a lift már láthatatlan.", thePlayer, 255, 0, 0, true)
                end
            else
                if elevatorElementCache[id][1]:getData("marker >> invisible") and elevatorElementCache[id][2]:getData("marker >> invisible") then 
                    elevatorElementCache[id][1]:removeData("marker >> invisible")
                    elevatorElementCache[id][2]:removeData("marker >> invisible")

                    local syntax = exports.cr_core:getServerSyntax(false, "success")
                    local adminSyntax = exports.cr_admin:getAdminSyntax()

                    local hexColor = exports.cr_core:getServerColor("yellow", true)
                    local adminName = exports.cr_admin:getAdminName(thePlayer, true)
                    local visiblityState = value == 1 and "látható" or "láthatatlan"

                    outputChatBox(syntax .. "Sikeresen megváltoztattad a lift láthatóságát. " .. hexColor .. "(" .. id .. ") " .. white .. "Státusz: " .. hexColor .. visiblityState, thePlayer, 255, 0, 0, true)
                    exports.cr_core:sendMessageToAdmin(thePlayer, adminSyntax .. hexColor .. adminName .. white .. " megváltoztatta egy liftnek a láthatóságát. " .. hexColor .. "(" .. id .. ") " .. white .. "Státusz: " .. hexColor .. visiblityState, 8)
                else 
                    local syntax = exports.cr_core:getServerSyntax(false, "error")

                    outputChatBox(syntax .. "Ez a lift nem láthatatlan.", thePlayer, 255, 0, 0, true)
                end
            end

            dbExec(sql, "UPDATE elevators SET invisible = ? WHERE id = ?", value, id)
        end
    end
end
addCommandHandler("setelevatorinvisible", setElevatorInvisible, false, false)

function setElevatorProtection(thePlayer, cmd, id, value)
    if exports.cr_permission:hasPermission(thePlayer, cmd) then 
        if not id or not value then 
            local syntax = exports.cr_core:getServerSyntax(false, "lightyellow")

            outputChatBox(syntax .. "/" .. cmd .. " [id] [0 = nincs, 1 = van]", thePlayer, 255, 0, 0, true)
            return
        end

        local id = tonumber(id)
        local value = tonumber(value)

        if not id or not value then 
            local syntax = exports.cr_core:getServerSyntax(false, "error")

            outputChatBox(syntax .. "Az id és az érték csak szám lehet.", thePlayer, 255, 0, 0, true)
            return
        end

        value = math.floor(tonumber(value))

        if value ~= 0 and value ~= 1 then 
            local syntax = exports.cr_core:getServerSyntax(false, "error")

            outputChatBox(syntax .. "Az érték csak 0 vagy 1 lehet.", thePlayer, 255, 0, 0, true)
            return
        end

        if not elevatorElementCache[id] then 
            local syntax = exports.cr_core:getServerSyntax(false, "error")

            outputChatBox(syntax .. "Nem létezik lift ezzel az id-vel.", thePlayer, 255, 0, 0, true)
            return
        else
            if not isElement(elevatorElementCache[id][1]) or not isElement(elevatorElementCache[id][2]) then 
                local syntax = exports.cr_core:getServerSyntax(false, "error")

                outputChatBox(syntax .. "Nem létezik a lift kijárata.", thePlayer, 255, 0, 0, true)
                return
            end
        end

        if isElement(elevatorElementCache[id][1]) and isElement(elevatorElementCache[id][2]) then 
            local markerData = elevatorElementCache[id][1]:getData('marker >> data')
            if value == 1 then 
                if not markerData['spawnProtection'] then 
                    markerData['spawnProtection'] = true 
                    elevatorElementCache[id][1]:setData("marker >> data", markerData)

                    local syntax = exports.cr_core:getServerSyntax(false, "success")
                    local adminSyntax = exports.cr_admin:getAdminSyntax()

                    local hexColor = exports.cr_core:getServerColor("yellow", true)
                    local adminName = exports.cr_admin:getAdminName(thePlayer, true)
                    local visiblityState = value == 1 and "van" or "nincs"

                    outputChatBox(syntax .. "Sikeresen megváltoztattad a lift spawnprotectjét. " .. hexColor .. "(" .. id .. ") " .. white .. "Státusz: " .. hexColor .. visiblityState, thePlayer, 255, 0, 0, true)
                    exports.cr_core:sendMessageToAdmin(thePlayer, adminSyntax .. hexColor .. adminName .. white .. " megváltoztatta egy liftnek a spawnprotectjét. " .. hexColor .. "(" .. id .. ") " .. white .. "Státusz: " .. hexColor .. visiblityState, 8)
                else 
                    local syntax = exports.cr_core:getServerSyntax(false, "error")

                    outputChatBox(syntax .. "Ez a lift már spawnprotectes.", thePlayer, 255, 0, 0, true)
                end
            else
                if markerData['spawnProtection'] then 
                    markerData['spawnProtection'] = false 
                    elevatorElementCache[id][1]:setData("marker >> data", markerData)

                    local syntax = exports.cr_core:getServerSyntax(false, "success")
                    local adminSyntax = exports.cr_admin:getAdminSyntax()

                    local hexColor = exports.cr_core:getServerColor("yellow", true)
                    local adminName = exports.cr_admin:getAdminName(thePlayer, true)
                    local visiblityState = value == 1 and "van" or "nincs"

                    outputChatBox(syntax .. "Sikeresen megváltoztattad a lift spawnprotectjét. " .. hexColor .. "(" .. id .. ") " .. white .. "Státusz: " .. hexColor .. visiblityState, thePlayer, 255, 0, 0, true)
                    exports.cr_core:sendMessageToAdmin(thePlayer, adminSyntax .. hexColor .. adminName .. white .. " megváltoztatta egy liftnek a spawnprotectjét. " .. hexColor .. "(" .. id .. ") " .. white .. "Státusz: " .. hexColor .. visiblityState, 8)
                else 
                    local syntax = exports.cr_core:getServerSyntax(false, "error")

                    outputChatBox(syntax .. "Ez a lift nem spawnprotectes.", thePlayer, 255, 0, 0, true)
                end
            end

            dbExec(sql, "UPDATE elevators SET spawnProtection = ? WHERE id = ?", value, id)
        end
    end
end
addCommandHandler("setelevatorprotection", setElevatorProtection, false, false)

timers = {}
addEvent("useElevator", true)
addEventHandler("useElevator", root,
    function(element, other)
        if other and isElement(other) then 
            local position = other.position 
            local interior = other.interior 
            local dimension = other.dimension 

            element.position = Vector3(position["x"], position["y"], position["z"] + 1)
            element.interior = interior 
            element.dimension = dimension

            local markerData = other:getData('marker >> data') or other:getData('parent'):getData('marker >> data')
            if markerData and markerData['spawnProtection'] then 
                if isTimer(timers[element]) then 
                    killTimer(timers[element])
                end 

                element.frozen = true 

                timers[element] = setTimer(setElementFrozen, 5000, 1, element, false)
            end 
        end
    end
)