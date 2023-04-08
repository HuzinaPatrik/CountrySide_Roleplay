function toggleLight()
    local veh = getPedOccupiedVehicle(localPlayer)
    
    if veh then
        if disabledType[getVehicleType(veh)] then return end
        
        if isTimer(spamTimerLight) then return end
        
        spamTimerLight = setTimer(function() end, math.random(500,500), 1)
        
        if getElementData(veh, "index.left") or getElementData(veh, "index.right") then
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax .. "Indexelés közben nem tudod fel/lekapcsolni a fenyszórókat!",255,255,255,true)
            return
        end
        if getPedOccupiedVehicleSeat(localPlayer) == 0 then
            local oldValue = getElementData(veh, "veh >> light")
            local newValue = not oldValue
            setElementData(veh, "veh >> light", newValue)
            playSound("assets/sounds/light.mp3")
            local vehicleName = getVehicleName(veh)
            if newValue then
                exports['cr_chat']:createMessage(localPlayer, "felkapcsolja egy jármű fényszóróit", 1)
            else
                exports['cr_chat']:createMessage(localPlayer, "lekapcsolja egy jármű fényszóróit", 1)
            end
        end
    end
end
bindKey("L", "down", toggleLight)