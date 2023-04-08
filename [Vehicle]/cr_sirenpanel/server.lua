addEvent("siren >> toggleSound", true)
addEventHandler("siren >> toggleSound", root,
    function(thePlayer, id, sourceVehicle)
        if client and client == thePlayer then 
            triggerClientEvent(getElementsByType("player"), "siren >> toggleSound", thePlayer, id, sourceVehicle)
        end
    end
)

addEvent("siren >> toggleLights", true)
addEventHandler("siren >> toggleLights", root,
    function(thePlayer, id)
        if client and client == thePlayer then 
            local vehicle = thePlayer.vehicle

            if vehicle then 
                if emergencyVehicles[vehicle.model] then 
                    if id then 
                        if sirenPositions[vehicle.model] then 
                            vehicle:addSirens(#sirenPositions[vehicle.model][id], 2, false, false, true, true)

                            for k, v in pairs(sirenPositions[vehicle.model][id]) do 
                                vehicle:setSirens(k, unpack(v))
                            end

                            vehicle:setSirensOn(false)
                            vehicle:setSirensOn(true)
                        end
                    else
                        vehicle:setSirensOn(false)
                    end
                end
            end
        end
    end
)