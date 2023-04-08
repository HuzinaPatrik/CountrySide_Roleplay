local vehicleLightData = {}
local vehicleLightTimers = {}

function toggleIndicator(vehicle, side, data)
    if isElement(client) and isElement(vehicle) then 
        local towedVehicle = getVehicleTowedByVehicle(vehicle)

        if not vehicleLightData[vehicle] then 
            vehicleLightData[vehicle] = {}

            for i = 0, 3 do 
                vehicleLightData[vehicle][i] = vehicle:getLightState(i)
            end

            vehicleLightData[vehicle].headLightColor = {vehicle:getHeadLightColor()}
            vehicleLightData[vehicle].overRideLights = vehicle:getOverrideLights()
            vehicleLightData[vehicle].oldSide = side

            if isElement(towedVehicle) then 
                if not vehicleLightData[towedVehicle] then 
                    vehicleLightData[towedVehicle] = {}

                    for i = 0, 3 do 
                        vehicleLightData[towedVehicle][i] = towedVehicle:getLightState(i)
                    end

                    vehicleLightData[towedVehicle].headLightColor = {towedVehicle:getHeadLightColor()}
                    vehicleLightData[towedVehicle].overRideLights = towedVehicle:getOverrideLights()
                    vehicleLightData[towedVehicle].oldSide = side
                end
            end
        end

        if not vehicleLightTimers[vehicle] then 
            vehicleLightTimers[vehicle] = {}
        end

        if isElement(towedVehicle) then 
            if not vehicleLightTimers[towedVehicle] then 
                vehicleLightTimers[towedVehicle] = {}
            end

            if not isTimer(vehicleLightTimers[towedVehicle]) then 
                if not towedVehicle:getData("veh >> light") then 
                    towedVehicle:setOverrideLights(2)
                    
                    local tbl = indicatorSidesLightsOff[side] or {}
    
                    if #tbl > 0 then 
                        for i = 1, #tbl do 
                            local v = tbl[i]
    
                            towedVehicle:setLightState(v, 1)
                        end
                    end
                end
    
                for i = 1, #data do 
                    local v = data[i]
                    local state = towedVehicle:getLightState(v) == 1 and 0 or 1
    
                    towedVehicle:setLightState(v, state)
                end
    
                vehicleLightTimers[towedVehicle] = setTimer(
                    function(thePlayer, towedVehicle, side, data)
                        if isElement(towedVehicle) then 
                            local indicatorState = towedVehicle:getData("index." .. side)
        
                            for i = 1, #data do 
                                local v = data[i]
                                local state = towedVehicle:getLightState(v) == 1 and 0 or 1
                
                                towedVehicle:setLightState(v, state)
                            end
        
                            towedVehicle:setData("index." .. side, not indicatorState)
                        end
                    end, 500, 0, client, towedVehicle, side, data
                )
            else
                local oldSide = vehicleLightData[towedVehicle].oldSide
    
                if oldSide == side then 
                    towedVehicle:setOverrideLights(vehicleLightData[towedVehicle].overRideLights)
    
                    for i = 0, 3 do 
                        if vehicleLightData[towedVehicle][i] then 
                            towedVehicle:setLightState(i, vehicleLightData[towedVehicle][i])
                        end
                    end
    
                    killTimer(vehicleLightTimers[towedVehicle])
    
                    vehicleLightData[towedVehicle] = nil
                    vehicleLightTimers[towedVehicle] = nil
    
                    towedVehicle:setData("index." .. side, false)
                else 
                    towedVehicle:setOverrideLights(vehicleLightData[towedVehicle].overRideLights)
    
                    for i = 0, 3 do 
                        if vehicleLightData[towedVehicle][i] then 
                            towedVehicle:setLightState(i, vehicleLightData[towedVehicle][i])
                        end
                    end
    
                    killTimer(vehicleLightTimers[towedVehicle])
    
                    vehicleLightData[towedVehicle] = nil
                    vehicleLightTimers[towedVehicle] = nil
    
                    towedVehicle:setData("index." .. oldSide, false)
                    towedVehicle:setData("index." .. side, false)
                    toggleIndicator(towedVehicle, side, data)
                end
            end
        end

        if not isTimer(vehicleLightTimers[vehicle]) then 
            if not vehicle:getData("veh >> light") then 
                vehicle:setOverrideLights(2)
                
                local tbl = indicatorSidesLightsOff[side] or {}

                if #tbl > 0 then 
                    for i = 1, #tbl do 
                        local v = tbl[i]

                        vehicle:setLightState(v, 1)
                    end
                end
            end

            for i = 1, #data do 
                local v = data[i]
                local state = vehicle:getLightState(v) == 1 and 0 or 1

                vehicle:setLightState(v, state)
            end

            vehicleLightTimers[vehicle] = setTimer(
                function(thePlayer, vehicle, side, data)
                    local indicatorState = vehicle:getData("index." .. side)

                    for i = 1, #data do 
                        local v = data[i]
                        local state = vehicle:getLightState(v) == 1 and 0 or 1
        
                        vehicle:setLightState(v, state)
                    end

                    vehicle:setData("index." .. side, not indicatorState)

                    if isElement(thePlayer) then 
                        if vehicle:getData("index." .. side) then
                            local occupants = getVehicleOccupants(vehicle)
                            local players = {}

                            for k, v in pairs(occupants) do 
                                table.insert(players, v)
                            end

                            if #players > 0 then 
                                triggerClientEvent(players, "indicator.playIndicatorSound", thePlayer)
                            end
                        end
                    end
                end, 500, 0, client, vehicle, side, data
            )
        else
            local oldSide = vehicleLightData[vehicle].oldSide

            if oldSide == side then 
                vehicle:setOverrideLights(vehicleLightData[vehicle].overRideLights)

                for i = 0, 3 do 
                    if vehicleLightData[vehicle][i] then 
                        vehicle:setLightState(i, vehicleLightData[vehicle][i])
                    end
                end

                killTimer(vehicleLightTimers[vehicle])

                vehicleLightData[vehicle] = nil
                vehicleLightTimers[vehicle] = nil

                vehicle:setData("index." .. side, false)
            else 
                vehicle:setOverrideLights(vehicleLightData[vehicle].overRideLights)

                for i = 0, 3 do 
                    if vehicleLightData[vehicle][i] then 
                        vehicle:setLightState(i, vehicleLightData[vehicle][i])
                    end
                end

                killTimer(vehicleLightTimers[vehicle])

                vehicleLightData[vehicle] = nil
                vehicleLightTimers[vehicle] = nil

                vehicle:setData("index." .. oldSide, false)
                vehicle:setData("index." .. side, false)
                toggleIndicator(vehicle, side, data)
            end
        end
    end
end
addEvent("indicator.toggleIndicator", true)
addEventHandler("indicator.toggleIndicator", root, toggleIndicator)

function onElementDestroy()
    if source.type == "vehicle" then 
        if vehicleLightData[source] then 
            local oldSide = vehicleLightData[source].oldSide

            source:setData("index." .. oldSide, false)

            for i = 0, 3 do 
                if vehicleLightData[source][i] then 
                    source:setLightState(i, vehicleLightData[source][i])
                end
            end

            if vehicleLightTimers[source] and isTimer(vehicleLightTimers[source]) then 
                killTimer(vehicleLightTimers[source])
                vehicleLightTimers[source] = nil
            end

            vehicleLightData[source] = nil
        end
    end
end
addEventHandler("onElementDestroy", root, onElementDestroy)

function onTrailerAttach(sourceVehicle)
    if isElement(sourceVehicle) then 
        for k, v in pairs(indicatorSides) do 
            if sourceVehicle:getData("index." .. v.name) then 
                toggleIndicator(sourceVehicle, v.name, v.data)

                break
            end
        end
    end
end
addEventHandler("onTrailerAttach", root, onTrailerAttach)

function onTrailerDetach(sourceVehicle)
    if vehicleLightData[source] then 
        local oldSide = vehicleLightData[source].oldSide

        source:setData("index." .. oldSide, false)

        for i = 0, 3 do 
            if vehicleLightData[source][i] then 
                source:setLightState(i, vehicleLightData[source][i])
            end
        end

        if vehicleLightTimers[source] and isTimer(vehicleLightTimers[source]) then 
            killTimer(vehicleLightTimers[source])
            vehicleLightTimers[source] = nil
        end

        vehicleLightData[source] = nil
    end
end 
addEventHandler("onTrailerDetach", root, onTrailerDetach)