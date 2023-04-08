connection = exports['cr_mysql']:getConnection(getThisResource())
addEventHandler("onResourceStart", root, 
    function(startedRes)
        if getResourceName(startedRes) == "cr_mysql" then
            connection = exports['cr_mysql']:getConnection(getThisResource())
            restartResource(getThisResource())
        end
    end
)

spam = {}
spamTimers = {}
cache = {}
ownerCache = {}
factionVehicles = {}

vehicleCounts = {}

Async:setPriority("high")
Async:setDebug(true)

addEvent("onVehicleLoad", true) -- Spawn
addEvent("onVehicleDestroy", true) -- Despawn

local loadTimer
function loadVehicles()
    dbQuery(
        function(queryHandler)
            local query, query_lines = dbPoll(queryHandler, 0)

            if query_lines > 0 then 
                Async:foreach(query,
                    function(row)
                        local modelid = tonumber(row.modelid)
                        local faction = tonumber(row.faction)

                        if faction <= 0 then 
                            vehicleCounts[modelid] = tonumber((vehicleCounts[modelid] or 0) + 1)
                        end
                    end,

                    function()
                        dbQuery(
                            function(query)
                                local query, query_lines = dbPoll(query, 0)
                                local tick = getTickCount()
                                if query_lines > 0 then
                                    Async:foreach(query, 
                                        function(row)
                                            local co = coroutine.create(loadVehicle)
                                            coroutine.resume(co, row, true)
                                        end,
                                        
                                        function()
                                            if isTimer(loadTimer) then
                                                killTimer(loadTimer)
                                            end
                    
                                            loadTimer = setTimer(triggerLatentClientEvent, 2500, 1, root, "loadedVehs", 50000, false, getRandomPlayer())
                                            collectgarbage("collect")
                                            outputDebugString("Loaded "..query_lines.." vehs in "..(getTickCount()-tick).."ms!", 0, 255, 50, 255)
                    
                                            -- triggerLatentClientEvent(root, "getAllVehicleCount", 50000, false, getRandomPlayer() or resourceRoot, vehicleCounts)
                                        end
                                    )
                                else 
                                    loadTimer = setTimer(triggerLatentClientEvent, 2500, 1, root, "loadedVehs", 50000, false, getRandomPlayer())
                                end    
                            end, 
                        connection, "SELECT * FROM vehicle WHERE faction > 0 OR protect = ?", "true")
                    end
                )
            end
        end, connection, "SELECT * FROM vehicle"
    )
end
addEventHandler("onResourceStart", resourceRoot, loadVehicles)

function addVehicleToPlayer(player, vehicle)
    local playerID 
    if isElement(player) then
        playerID = player:getData("acc >> id")
    elseif tonumber(player) then
        playerID = tonumber(player)
    end
    
    local vehicleID
    if isElement(vehicle) then
        vehicleID = vehicle:getData("veh >> id")
    elseif tonumber(vehicle) then
        vehicleID = tonumber(vehicle)
    end
    
    if playerID >= 1 then
        if tonumber(playerID) and tonumber(vehicleID) then
            if not ownerCache[playerID] then
                ownerCache[playerID] = {}
            end

            table.insert(ownerCache[playerID], 1, vehicleID)

            return true
        end
    end
        
    return false
end

function removeVehicleFromPlayer(player, vehicle)
    local playerID 
    if isElement(player) then
        playerID = player:getData("acc >> id")
    elseif tonumber(player) then
        playerID = tonumber(player)
    end
    
    local vehicleID
    if isElement(vehicle) then
        vehicleID = vehicle:getData("veh >> id")
    elseif tonumber(vehicle) then
        vehicleID = tonumber(vehicle)
    end
    
    if playerID >= 1 then
        if ownerCache[playerID] then
            local data = ownerCache[playerID]
            for k,v in pairs(data) do
                if v == vehicleID then
                    table.remove(ownerCache[playerID], k)
                    return true
                end
            end
        end
    end
        
    return false
end

function getPlayerVehicles(player)
    local playerID 
    if isElement(player) then
        playerID = player:getData("acc >> id")
    elseif tonumber(player) then
        playerID = tonumber(player)
    end
    
    return ownerCache[playerID] or {}
end

function getVehicleByID(vehicle)
    local vehicleID
    if isElement(vehicle) then
        vehicleID = vehicle:getData("veh >> id")
    elseif tonumber(vehicle) then
        vehicleID = tonumber(vehicle)
    end
    
    return cache[vehicleID] or {}
end

function loadVehicle(row, ignoreCount)
    local id = tonumber(row["id"])
    local modelid = tonumber(row["modelid"])

    if not ignoreCount then 
        vehicleCounts[modelid] = tonumber(vehicleCounts[modelid] or 0) + 1

        getVehicleCounts(root, modelid)
    end

    local pos = fromJSON(tostring(row["pos"]))
    local owner = tonumber(row["owner"])
    local fuel = tonumber(row["fuel"])

    if fuel > getVehicleMaxFuel(modelid) then 
        fuel = getVehicleMaxFuel(modelid)
    end 

    local engine = stringToBoolean(tostring(row["engine"]))
    local engineBroken = stringToBoolean(tostring(row["engineBroken"]))
    local plate = tostring(row["plate"])
    local odometer = tonumber(row["odometer"])
    local lastOilRecoil = tonumber(row["lastOilRecoil"])
    local locked = stringToBoolean(tostring(row["locked"]))
    local health = tonumber(row["health"])
    local colors = fromJSON(tostring(row["colors"]))
    local windows = fromJSON(tostring(row["windows"]))
    local panels = fromJSON(tostring(row["panels"]))
    local wheels = fromJSON(tostring(row["wheels"]))
    local lights = fromJSON(tostring(row["lights"]))
    local doors = fromJSON(tostring(row["doors"]))
    local handbrake = stringToBoolean(tostring(row["handbrake"]))
    local damageProof = stringToBoolean(tostring(row["damageProof"]))
    local variant = fromJSON(tostring(row["variant"]))
    local headlight = fromJSON(tostring(row["headlight"]))
    local kmColor = fromJSON(tostring(row["kmColor"]))
    local parkPos = fromJSON(tostring(row["parkPos"]))
    local protect = stringToBoolean(tostring(row["protect"]))
    local faction = tonumber(row["faction"])
    local fueltype = tostring(row["fueltype"])
    local chassis = tostring(row["chassis"])
    local tuningData = fromJSON(tostring(row["tuningData"]))
    local taxiPlate = stringToBoolean(tostring(row["taxiPlate"]))
    
    local x, y, z, rx, ry, rz, int, dim = unpack(pos)
    
    local vehicle = exports['cr_elements']:getVehicleByID(id)
    
    if not vehicle then
        local v1, v2 = unpack(variant)
        
        vehicle = exports['cr_elements']:createVehicle(
            {
                ["id"] = id,
                ["model"] = modelid <= 611 and modelid or 411,
                ["x"] = x,
                ["y"] = y,
                ["z"] = z,
                ["rx"] = rx,
                ["ry"] = ry,
                ["rz"] = rz,
                ["plate"] = plate,
                ["variant1"] = v1,
                ["variant2"] = v2,
            }
        )

        if modelid > 611 then 
            vehicle:setData('veh >> virtuaModellID', modelid)
        end 
        
        if getVehicleType(vehicle) == "Bike" then
            engine = false
        end

        if health <= 300 then
            health = 300
        end
        
        vehicle.alpha = 255
        
        vehicle:setHealth(health)
        vehicle:setInterior(int)
        vehicle:setDimension(dim)

        vehicle:setVariant(v1, v2)

        local oldfueltype = tostring(getHandlingProperty(vehicle, "engineType"));
        vehicle:setData("veh >> oldfueltype", oldfueltype);
        vehicle:setData("veh >> fueltype", fueltype)

        vehicle:setData("veh >> plateText", plate)
        vehicle.plateText = plate
        vehicle:setData("veh >> chassis", chassis)
        vehicle:setData("veh >> tuningData", tuningData)
        
        setVehicleRespawnPosition(vehicle, x,y,z,rx,ry,rz);
        
        local hr, hg, hb = unpack(headlight);
        setVehicleHeadLightColor(vehicle, hr, hg, hb);

        if vehicle.vehicleType ~= "Bike" and vehicle.vehicleType ~= "BMX" and vehicle.vehicleType ~= "Quad" then
            local window = true
            
            for i, v in pairs(windows) do
                local state = stringToBoolean(tostring(v))
                local i = i+1
                
                if state then
                    window = false
                end
                
                vehicle:setData("veh >> window"..i.."State", state)
            end
            
            vehicle:setData("veh >> windows >> closed", window)
        end
        
        for k, v in pairs(doors) do
            local k = k-1;
            vehicle:setDoorState(k, v)
        end
        
        for k, v in pairs(panels) do
            local num = k-1;
            vehicle:setPanelState(num, v)
        end  
        
        local frontLeft, rearLeft, frontRight, rearRight = unpack(wheels)
        vehicle:setWheelStates(frontLeft, rearLeft, frontRight, rearRight)
        
        vehicle:setColor(unpack(colors))
        
        if vehicle.vehicleType ~= "Bike" then
            if engineBroken then
                engine = false
            end
        end
        
        if faction > 0 then
            owner = 0

            if not factionVehicles[faction] then 
                factionVehicles[faction] = 0
            end

            factionVehicles[faction] = factionVehicles[faction] + 1
        end
        
        if owner > 0 then
            faction = 0
        end
        
        vehicle:setData("veh >> loaded", true)
        vehicle:setData("veh >> id", id)
        vehicle:setData("veh >> owner", owner)
        vehicle:setData("veh >> fuel", fuel)
        vehicle:setData("veh >> engineBroken", engineBroken)
        
        if engineBroken then
            vehicle:setHealth(300)
        end
        
        vehicle:setData("veh >> engine", engine)
        vehicle.engineState = engine
        vehicle:setData("veh >> handbrake", handbrake)
        vehicle.frozen = handbrake
        vehicle:setData("veh >> damageProof", damageProof)
        vehicle.damageProof = damageProof
        vehicle:setData("veh >> odometer", odometer)
        vehicle:setData("veh >> lastOilRecoil", lastOilRecoil)
        vehicle:setData("veh >> locked", locked)
        vehicle:setData("veh >> KM/H Color", kmColor)
        vehicle:setData("veh >> park", parkPos)
        vehicle:setData("veh >> protect", protect)
        vehicle:setData("veh >> faction", faction)
        vehicle:setData("veh >> light", light)
        vehicle:setData('veh >> taxiPlate', taxiPlate)

        if taxiPlate then 
            local randomPlayer = getRandomPlayer()
            triggerClientEvent(randomPlayer, 'syncTaxiLamp', randomPlayer, vehicle)
        end 
                                                                                        
        vehicle:setLocked(locked)
        
        vehicle:setData("needLoad", true) --setTimer(setElementData, 1000, 1, vehicle, "needLoad", true) --or trigger i d'nt kn'w

        if tuningData["optical.14"] then 
            exports['cr_tuning']:addOpticalTuning(vehicle, 14, tuningData["optical.14"])
        end 

        if tuningData["optical.15"] then 
            exports['cr_tuning']:addOpticalTuning(vehicle, 15, tuningData["optical.15"])
        end 

        if tuningData["optical.3"] then 
            exports['cr_tuning']:addOpticalTuning(vehicle, 3, tuningData["optical.3"])
        end 

        if tuningData["optical.0"] then 
            exports['cr_tuning']:addOpticalTuning(vehicle, 0, tuningData["optical.0"])
        end 

        if tuningData["optical.12"] then 
            exports['cr_tuning']:addOpticalTuning(vehicle, 12, tuningData["optical.12"])
        end 

        if tuningData["optical.2"] then 
            exports['cr_tuning']:addOpticalTuning(vehicle, 2, tuningData["optical.2"])
        end 

        if tuningData["optical.13"] then 
            exports['cr_tuning']:addOpticalTuning(vehicle, 13, tuningData["optical.13"])
        end 

        if tuningData["optical.7"] then 
            exports['cr_tuning']:addOpticalTuning(vehicle, 7, tuningData["optical.7"])
        end 

        if tuningData["optical.9"] then 
            exports['cr_tuning']:addOpticalTuning(vehicle, 9, tuningData["optical.9"])
        end 

        --[[ FONTOS INFO: AMI EBBEN VAN AZ A CR_HANDLING KLIENS OLDALABAN IS VAN ALLITVA SZOVAL OTT IS IRD AT!!! ]]

        local wheelSizes = {
            {"verynarrow", "Nagyon vékony"},
            {"narrow", "Vékony"},
            {"default", "Alap"},
            {"wide", "Széles"},
            {"verywide", "Nagyon széles"},
        }

        if tuningData["frontwheel"] then 
            exports['cr_tuning']:setVehicleHandlingFlags(vehicle, 3, wheelSizes[tuningData["frontwheel"]][1])
        end 

        if tuningData["rearwheel"] then 
            exports['cr_tuning']:setVehicleHandlingFlags(vehicle, 4, wheelSizes[tuningData["rearwheel"]][1])
        end 

        local driveTypes = {
            {"fwd", "Elsőkerék"},
            {"awd", "Összkerék"},
            {"rwd", "Hátsókerék"},
        }

        if tuningData["driveType"] then 
            exports['cr_tuning']:setVehicleHandling(vehicle, "driveType", driveTypes[tuningData["driveType"]][1])
        end 

        local offroadTypes = {
            {"default", "Alap"},
            {"dirt", "Dirt"},
            {"sand", "Sand"},
        }

        if tuningData["offroad"] then 
            exports['cr_tuning']:setVehicleHandlingFlags(vehicle, 6, offroadTypes[tuningData["offroad"]][1])
        end 

        --[[ FONTOS INFO: AMI EBBEN VAN AZ A CR_HANDLING KLIENS OLDALABAN IS VAN ALLITVA SZOVAL OTT IS IRD AT!!! ]]
    end
    
    outputDebugString("Veh: ID: "..id.." loaded!")
    cache[id] = vehicle
    
    addVehicleToPlayer(owner, id)
    
    triggerEvent("onVehicleLoad", vehicle, id)
end

addEventHandler("onElementDataChange", root, function(dName)
    if getElementType(source) == "vehicle" then
        local value = getElementData(source, dName);
        if dName == "veh >> engine" then
            setVehicleEngineState(source, value);
        elseif dName == "veh >> damageProof" then
            setVehicleDamageProof(source, value);
        elseif dName == "veh >> light" then
            if value then
                setVehicleOverrideLights(source, 2);
            else
                setVehicleOverrideLights(source, 1);
            end
        elseif utfSub(dName, 1, 12) == "veh >> light" and #dName > 12 then
            local num = tonumber(utfSub(dName, 13, 13));
                
            if num then
                setVehicleLightState(source, num, value);
            end
        elseif dName == "veh >> locked" then
            setVehicleLocked(source, value);
        end
    end
end)

addEvent("setVehicleHealth", true)
addEventHandler("setVehicleHealth", root, 
    function(veh, num)
        if isElement(veh) then
            veh.health = tonumber(num)
        end
    end
)

--Player kocsi betöltés:
function loadPlayerVehicles(player)
    if player:getData("loggedIn") then
        local id = player:getData("acc >> id")

        dbQuery(
            function(query)
                local query, query_lines = dbPoll(query, 0)
                local tick = getTickCount()
                if query_lines > 0 then
                    Async:foreach(query, 
                        function(row)
                            local co = coroutine.create(loadVehicle)
                            coroutine.resume(co, row, true)
                        end,

                        function()
                            collectgarbage("collect")
                            outputDebugString("Loaded "..query_lines.." vehicles in "..(getTickCount()-tick).."ms! (Player: "..id..")", 0, 255, 50, 255)
                        end
                    )
                end    
            end, 
        connection, "SELECT * FROM vehicle WHERE owner = ? AND protect = ?", id, "false")
    end
end
addEvent("loadPlayerVehicles", true)
addEventHandler("loadPlayerVehicles", root, loadPlayerVehicles)

function deleteVehicle(id)
    if isElement(id) then
        id = id:getData("veh >> id")
    end
    
    if not id then return end
    
    local vehicle = cache[id];

    if not vehicle then return end 
    
    local modelid = vehicle:getData('veh >> virtuaModellID') or vehicle.model
    local factionId = vehicle:getData("veh >> faction") or 0

    if factionVehicles[factionId] then 
        factionVehicles[factionId] = math.max(0, factionVehicles[factionId] - 1)
    end
    
    vehicleCounts[modelid] = tonumber(vehicleCounts[modelid] or 0) - 1
    triggerLatentClientEvent(root, "minusVehicleCount", 50000, false, getRandomPlayer(), modelid)
    
    if tonumber(id) >= 1 then
        dbExec(connection, "DELETE FROM `vehicle` WHERE `id`=?", id);
        removeVehicleFromPlayer(vehicle:getData("veh >> owner"), id)
    end
    
    if cache[id] then
        cache[id] = nil;
    end
    
    if vehicle then
        local obj = vehicle:getData("veh >> ambulanceBedE")

        if obj and isElement(obj) then
            destroyElement(obj)
        end

        destroyElement(vehicle);
    end

    outputDebugString("Vehicle deleted! ID: "..id, 0, 255, 50, 255)
end 

function getVehicleCounts(e, modelid)
    local e = client or e

    if isElement(e) then 
        triggerLatentClientEvent(e, "getVehicleCounts", 50000, false, e, vehicleCounts, modelid)
    else
        return vehicleCounts
    end
end
addEvent("getVehicleCounts", true)
addEventHandler("getVehicleCounts", root, getVehicleCounts)

function getFactionVehicleCount(id)
    return factionVehicles[id]
end

function makeVehicle(e, model, factionID, playerID, pos, colors)
    if factionID > 0 then
        playerID = 0
    elseif playerID > 0 then
        factionID = 0
    end
        
    dbExec(connection, "INSERT INTO `vehicle` SET `modelid`=?, `owner`=?, `faction`=?, `pos`=?, `parkPos`=?, `colors`=?", model, playerID, factionID, pos, pos, colors)
        
    dbQuery(
        function(query)
            local query, query_lines = dbPoll(query, 0)
            local tick = getTickCount()
            if query_lines > 0 then
                Async:foreach(query, 
                    function(row)
                        local id = row["id"]
                        loadVehicle(row)
                            
                        exports['cr_inventory']:giveItem(e, 16, id, 1, 100, 0, 0, model)
                    end,

                    function()
                        collectgarbage("collect")
                        outputDebugString("Loaded "..query_lines.." vehicles in "..(getTickCount()-tick).."ms!", 0, 255, 50, 255)
                    end
                )
            end    
        end, 
    connection, "SELECT * FROM vehicle WHERE id=LAST_INSERT_ID()")
end 
addEvent("makeVehicle", true)
addEventHandler("makeVehicle", root, makeVehicle)

function warpToVehicle(player, veh)
    player.vehicle = veh 
end 
addEvent("warpToVehicle", true)
addEventHandler("warpToVehicle", root, warpToVehicle)