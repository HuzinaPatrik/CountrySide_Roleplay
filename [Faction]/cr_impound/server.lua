local sql = exports["cr_mysql"]:getConnection(getThisResource())
addEventHandler("onResourceStart", root,
    function(startedRes)
        if getResourceName(startedRes) == "cr_mysql" then 
            sql = exports["cr_mysql"]:getConnection(getThisResource())
            restartResource(getThisResource())
        elseif startedRes == getThisResource() then 
            loadImpoundedVehicles()
        end
    end
)

local cache = {}
local vehicleCache = {}

function loadImpoundedVehicles()
    local loaded = 0
    local startTick = getTickCount()

    dbQuery(
        function(query)
            local query, query_lines = dbPoll(query, 0)
            if query_lines > 0 then 
                Async:foreach(query,
                    function(row)
                        loaded = loaded + 1

                        local id = tonumber(row["id"])
                        local ownerId = tonumber(row["ownerId"])
                        local vehicleModel = tonumber(row["vehicleModel"])
                        local vehicleId = tonumber(row["vehicleId"])
                        local enforcer = tonumber(row["enforcer"])
                        local enforcerFaction = tostring(row["enforcerFaction"])
                        local date = tonumber(row["date"])

                        if not cache[ownerId] then 
                            cache[ownerId] = {}
                        end

                        table.insert(cache[ownerId], {id, ownerId, vehicleModel, vehicleId, enforcer, enforcerFaction, date})
                        vehicleCache[vehicleId] = ownerId
                    end,

                    function()
                        outputDebugString("@loadImpoundedVehicles: loaded "..loaded.." / "..query_lines.." impounded vehicle(s) in "..getTickCount() - startTick.." ms.", 0, 255, 0, 255)
                    end
                )
            end
        end, sql, "SELECT * FROM impound"
    )
end

function impoundVehicle(thePlayer, vehicle, enforcerFaction)
    local ownerId = vehicle:getData("veh >> owner")
    local vehicleModel = vehicle.model 
    local enforcer = thePlayer:getData("acc >> id")
    local date = getRealTime()["timestamp"]
    local vehicleDimension = vehicle.dimension
    local vehicleId = vehicle:getData("veh >> id")
    local impounded = exports["cr_impound"]:isVehicleImpounded(vehicleId)

    if impounded then 
        return exports["cr_infobox"]:addBox(thePlayer, "error", "Ez a jármű már le van foglalva.")
    end

    thePlayer:removeFromVehicle(vehicle)
    vehicle.dimension = vehicleDimension + ownerId

    local syntax = exports["cr_core"]:getServerSyntax("Impound", "success")
    local serverHex = exports["cr_core"]:getServerColor("blue", true)
    outputChatBox(syntax.."Sikeresen lefoglaltad a járművet.", thePlayer, 255, 0, 0, true)
    exports["cr_core"]:sendMessageToAdmin(thePlayer, exports["cr_admin"]:getAdminSyntax()..serverHex..exports["cr_admin"]:getAdminName(thePlayer).."#ffffff lefoglalt egy járművet. "..serverHex.."("..vehicleId..")", 3)

    dbExec(sql, "INSERT INTO impound SET ownerId = ?, vehicleModel = ?, vehicleId = ?, enforcer = ?, enforcerFaction = ?, date = ?", ownerId, vehicleModel, vehicleId, enforcer, enforcerFaction, date)

    dbQuery(
        function(query)
            local query, query_lines = dbPoll(query, 0)
            if query_lines > 0 then 
                Async:foreach(query,
                    function(row)
                        local id = tonumber(row["id"])
                        local ownerId = tonumber(row["ownerId"])
                        local vehicleModel = tonumber(row["vehicleModel"])
                        local vehicleId = tonumber(row["vehicleId"])
                        local enforcer = tonumber(row["enforcer"])
                        local enforcerFaction = tostring(row["enforcerFaction"])
                        local date = tonumber(row["date"])

                        if not cache[ownerId] then 
                            cache[ownerId] = {}
                        end

                        table.insert(cache[ownerId], {id, ownerId, vehicleModel, vehicleId, enforcer, enforcerFaction, date})
                        vehicleCache[vehicleId] = ownerId
                    end
                )
            end
        end, sql, "SELECT * FROM impound WHERE id = LAST_INSERT_ID()"
    )
end

function getImpoundedVehicles(ownerId)
    local ownerId = tonumber(ownerId) or false 

    if ownerId then 
        if ownerId > 0 then 
            if cache[ownerId] then 
                return cache[ownerId]
            end
        end
    end

    return false 
end

function isVehicleImpounded(vehicleId)
    local vehicleId = tonumber(vehicleId) or false 

    if vehicleId then 
        if vehicleId > 0 then 
            if vehicleCache[vehicleId] then 
                return vehicleCache[vehicleId]
            end
        end
    end

    return false
end

addEvent("impound.getImpoundedVehicles", true)
addEventHandler("impound.getImpoundedVehicles", root, 
    function(thePlayer, ownerId)
        local data = getImpoundedVehicles(ownerId)

        if data then 
            triggerLatentClientEvent(thePlayer, "impound.getImpoundedVehicles", 50000, false, thePlayer, data)
        end
    end
)

addEvent("impound.takeVehicle", true)
addEventHandler("impound.takeVehicle", root,
    function(thePlayer, data)
        -- TODO
    end
)