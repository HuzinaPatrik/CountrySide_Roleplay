function syncronizeMechanicsDuty()
    local num = 0

    for k,v in pairs(getElementsByType('player')) do 
        if v:getData('char >> duty') == 3 then 
            num = 1
            break 
        end 
    end 

    triggerLatentServerEvent("offlineMarker>>sync>>result", 5000, false, localPlayer, num)
end 
addEvent('syncronizeMechanicsDuty', true)
addEventHandler('syncronizeMechanicsDuty', localPlayer, syncronizeMechanicsDuty)

addEventHandler("onClientMarkerHit", resourceRoot,
    function(hitPlayer, matchingDimension)
        if source:getData("offlineMarker >> id") and source:getData("offlineMarker >> status") == 'active' then
            if hitPlayer == localPlayer and matchingDimension then 
                if getDistanceBetweenPoints3D(localPlayer.position, source.position) <= 3 then 
                    if localPlayer.vehicle then                     
                        if localPlayer.vehicleSeat == 0 then 
                            if localPlayer.vehicle.health < 1000 then 
                                triggerEvent("mechanic.fixVehicle", localPlayer)
                            end 
                        end                         
                    end 
                end 
            end
        end 
    end
)

addEventHandler("onClientMarkerLeave", resourceRoot,
    function(hitPlayer, matchingDimension)
        if source:getData("offlineMarker >> id") and source:getData("offlineMarker >> status") == 'active' then
            if hitPlayer == localPlayer and matchingDimension then 
                if localPlayer.vehicle then                     
                    if localPlayer.vehicleSeat == 0 then 
                        if localPlayer.vehicle.health < 1000 then 
                            if exports['cr_dashboard']:isAlertsActive() then 
                                exports['cr_dashboard']:clearAlerts()
                            end 
                        end 
                    end                         
                end 
            end
        end 
    end
)