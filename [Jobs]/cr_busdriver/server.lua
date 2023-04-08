local sql = exports.cr_mysql:getConnection(getThisResource())

function onStart(startedRes)
    if getResourceName(startedRes) == "cr_mysql" then 
        restartResource(getThisResource())
    elseif startedRes == getThisResource() then 
        loadBusStops()
    end
end
addEventHandler("onResourceStart", root, onStart)

local cache = {}

function loadBusStop(row)
    local id = tonumber(row.id)
    local position = fromJSON(row.position)
    local modelId = tonumber(row.modelid)

    local posX, posY, posZ = position.posX, position.posY, position.posZ
    local rotX, rotY, rotZ = position.rotX, position.rotY, position.rotZ
    local interior, dimension = position.interior, position.dimension

    local busStopObject = Object(jobData.busStopObjectId, posX, posY, posZ, rotX, rotY, rotZ)

    busStopObject:setData("busStop >> id", id)
    busStopObject.interior = interior
    busStopObject.dimension = dimension

    cache[id] = busStopObject
end

function loadBusStops()
    local loaded = 0
    local startTick = getTickCount()

    dbQuery(
        function(queryHandle)
            local query, query_lines = dbPoll(queryHandle, 0)

            if query_lines > 0 then 
                Async:foreach(query,
                    function(row)
                        loaded = loaded + 1
                        
                        loadBusStop(row)
                    end,

                    function()
                        outputDebugString("@loadBusStops: loaded " .. loaded .. " / " .. query_lines .. " bus stop(s) in " .. getTickCount() - startTick .. " ms.", 0, 255, 50, 255)
                    end
                )
            end
        end, sql, "SELECT * FROM bus_stops"
    )
end

function createBusStopCommand(thePlayer, cmd)
    if exports.cr_permission:hasPermission(thePlayer, cmd) or exports.cr_core:getPlayerDeveloper(thePlayer) then 
        local position = thePlayer.position
        local rotation = thePlayer.rotation
        local interior, dimension = thePlayer.interior, thePlayer.dimension

        local array = {
            posX = position.x,
            posY = position.y,
            posZ = position.z + 0.3,
            rotX = rotation.x,
            rotY = rotation.y,
            rotZ = rotation.z,
            interior = interior,
            dimension = dimension
        }

        dbExec(sql, "INSERT INTO bus_stops SET modelid = ?, position = ?", jobData.busStopObjectId, toJSON(array))

        dbQuery(
            function(queryHandle, thePlayer)
                local query, query_lines = dbPoll(queryHandle, 0)

                if query_lines > 0 then 
                    local row = query[1]
                    local dbId = row.id

                    loadBusStop(row)

                    if isElement(thePlayer) then 
                        local syntax = exports.cr_core:getServerSyntax("Buszsofőr", "success")
                        local hexColor = exports.cr_core:getServerColor("blue", true)

                        outputChatBox(syntax .. "Sikeresen létrehoztál egy buszmegállót. " .. hexColor .. "(" .. dbId .. ")", thePlayer, 255, 0, 0, true)

                        local adminSyntax = exports.cr_admin:getAdminSyntax()
                        local adminName = exports.cr_admin:getAdminName(thePlayer, true)

                        exports.cr_core:sendMessageToAdmin(thePlayer, adminSyntax .. hexColor .. adminName .. white .. " létrehozott egy buszmegállót. " .. hexColor .. "(" .. dbId .. ")", 6)
                    end
                end
            end, {thePlayer}, sql, "SELECT * FROM bus_stops WHERE id = LAST_INSERT_ID()"
        )
    end
end
addCommandHandler("createbusstop", createBusStopCommand, false, false)

function deleteBusStopCommand(thePlayer, cmd, dbId)
    if exports.cr_permission:hasPermission(thePlayer, cmd) or exports.cr_core:getPlayerDeveloper(thePlayer) then 
        if not dbId then 
            local syntax = exports.cr_core:getServerSyntax(false, "lightyellow")
            outputChatBox(syntax .. "/" .. cmd .. " [id]", thePlayer, 255, 0, 0, true)

            return
        end

        local dbId = tonumber(dbId)

        if not dbId then 
            local syntax = exports.cr_core:getServerSyntax(false, "error")
            outputChatBox(syntax .. "Csak szám.", thePlayer, 255, 0, 0, true)

            return
        end

        if not cache[dbId] then 
            local syntax = exports.cr_core:getServerSyntax(false, "error")
            outputChatBox(syntax .. "Nem létezik buszmegálló ezzel az id-vel.", thePlayer, 255, 0, 0, true)

            return
        end

        if isElement(cache[dbId]) then 
            local busStopObject = cache[dbId]
            busStopObject:destroy()

            dbExec(sql, "DELETE FROM bus_stops WHERE id = ?", dbId)
            cache[dbId] = nil

            local syntax = exports.cr_core:getServerSyntax("Buszsofőr", "success")
            local hexColor = exports.cr_core:getServerColor("blue", true)

            outputChatBox(syntax .. "Sikeresen kitöröltél egy buszmegállót. " .. hexColor .. "(" .. dbId .. ")", thePlayer, 255, 0, 0, true)

            local adminSyntax = exports.cr_admin:getAdminSyntax()
            local adminName = exports.cr_admin:getAdminName(thePlayer, true)

            exports.cr_core:sendMessageToAdmin(thePlayer, adminSyntax .. hexColor .. adminName .. white .. " kitörölt egy buszmegállót. " .. hexColor .. "(" .. dbId .. ")", 6)
        end
    end
end
addCommandHandler("deletebusstop", deleteBusStopCommand, false, false)