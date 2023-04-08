function setBeltSound(veh)
    if veh then
        if hasBelt[veh:getData('veh >> virtuaModellID') or getElementModel(veh)] then
            if not isElement(beltSound) then
                beltSound = playSound("assets/sounds/belt.mp3", true)
            end
        end
    end
end

addEventHandler("onClientElementDataChange", localPlayer, function(dName)
    local value = getElementData(source, dName)
    if dName == "inDeath" then
        if value then
            if isElement(beltSound) then
                destroyElement(beltSound)
            end
                
            if windowState then
                removeEventHandler("onClientRender", root, drawnWindowPanel)
                windowState = false
            end
                
            if doorState then
                removeEventHandler("onClientRender", root, drawnDoorPanel)
                doorState = false
            end
        end
    end
end)

addEventHandler("onClientPlayerVehicleEnter", root, function()
    if source ~= localPlayer then
        local veh = getPedOccupiedVehicle(source)
        local veh2 = getPedOccupiedVehicle(localPlayer)

        local value = getElementData(veh, "veh >> engine")
        setVehicleEngineState(veh, value)

        if veh2 and veh == veh2 then
            if getVehicleType(veh) == "Automobile" or getVehicleType(veh) == "Plane" or getVehicleType(veh) == "Monster Truck"  then
                local breaked = false
                local occupants = getVehicleOccupants(veh)

                for k,v in pairs(occupants) do
                    if not getElementData(v, "char >> belt") then
                         breaked = true
                    end
                end

                if breaked then
                    setBeltSound(veh)
                else
                    setBeltSound(veh)
                end
            end 
        end
    end
end)

addEventHandler("onClientPlayerVehicleExit", root, function(veh, seat)
    if source ~= localPlayer then
        local value = getElementData(veh, "veh >> engine")
        local veh2 = getPedOccupiedVehicle(localPlayer)
        setVehicleEngineState(veh, value)
        
        if veh2 and veh == veh2 then
            if getVehicleType(veh) == "Automobile" or getVehicleType(veh) == "Plane" or getVehicleType(veh) == "Monster Truck"  then
                local breaked = false
                local occupants = getVehicleOccupants(veh)
                    
                for k,v in pairs(occupants) do
                    if v ~= source then
                        if not getElementData(v, "char >> belt") then
                            breaked = true
                        end
                    end
                end
                    
                if breaked then
                    if hasBelt[veh:getData('veh >> virtuaModellID') or getElementModel(veh)] then
                        if not isElement(beltSound) then
                            beltSound = playSound("assets/sounds/belt.mp3", true)
                        end
                    end
                else
                    if isElement(beltSound) then
                        destroyElement(beltSound)
                    end 
                end
            end
        end
    elseif source == localPlayer then
        if isElement(beltSound) then
            destroyElement(beltSound)
        end
            
        if windowState then
            removeEventHandler("onClientRender", root, drawnWindowPanel)
            windowState = false
        end
            
        if doorState then
            removeEventHandler("onClientRender", root, drawnDoorPanel)
            doorState = false
        end
    end
end)

addEventHandler("onClientResourceStart", resourceRoot, function()
    setElementData(localPlayer, "char >> belt", false)
end)

function toggleBelt()
    local veh = getPedOccupiedVehicle(localPlayer)
    
    if not veh then return end

    if veh and getVehicleType(veh) == "Automobile" or getVehicleType(veh) == "Plane" or getVehicleType(veh) == "Monster Truck" then
        if isTimer(spamTimerBelt) then return end
        
        spamTimerBelt = setTimer(function() end, math.random(500,500), 1)
        
        local belt = getElementData(localPlayer, "char >> belt")
        local newBelt = not belt
        
        setElementData(localPlayer, "char >> belt", not belt)
        
        if newBelt then
            exports['cr_chat']:createMessage(localPlayer, "becsatolja a biztonsági övét", 1)
            playSound("assets/sounds/beltin.mp3")
            
            local breaked = false
            local occupants = getVehicleOccupants(veh)
            
            for k,v in pairs(occupants) do
                if not getElementData(v, "char >> belt") then
                     breaked = true
                end
            end
            
            if breaked then
                if hasBelt[veh:getData('veh >> virtuaModellID') or getElementModel(veh)] then
                    if not isElement(beltSound) then
                        beltSound = playSound("assets/sounds/belt.mp3", true)
                    end
                end
            else
                if isElement(beltSound) then
                    destroyElement(beltSound)
                end 
            end
        else
            exports['cr_chat']:createMessage(localPlayer, "kicsatolja a biztonsági övét", 1)
            playSound("assets/sounds/beltout.mp3")
            
            local breaked = true
            local occupants = getVehicleOccupants(veh)
            
            for k,v in pairs(occupants) do
                if not getElementData(v, "char >> belt") then
                    breaked = true
                end
            end
            
            if breaked then
                if hasBelt[veh:getData('veh >> virtuaModellID') or getElementModel(veh)] then
                    if not isElement(beltSound) then
                        beltSound = playSound("assets/sounds/belt.mp3", true)
                    end
                end
            else
                if isElement(beltSound) then
                    destroyElement(beltSound)
                end 
            end
        end
    end
end
bindKey("F5", "down", toggleBelt)

addEventHandler("onClientElementDataChange", root, function(dName)
    local veh = getPedOccupiedVehicle(localPlayer)
    if veh then
        if getElementType(source) == "player" and dName == "char >> belt" then
            local veh2 = getPedOccupiedVehicle(source)
            if veh == veh2 then
                local breaked = false
                    
                local occupants = getVehicleOccupants(veh)
                for k,v in pairs(occupants) do
                    if not getElementData(v, "char >> belt") then
                         breaked = true
                    end
                end
                    
                if breaked then
                    if hasBelt[veh:getData('veh >> virtuaModellID') or getElementModel(veh)] then
                        if not isElement(beltSound) then
                            beltSound = playSound("assets/sounds/belt.mp3", true)
                        end
                    end
                else
                    if isElement(beltSound) then
                        destroyElement(beltSound)
                    end 
                end
            end
        end
    end
end)

addEventHandler("onClientElementDestroy", root, 
    function()
        if getElementType(source) == "vehicle" then
            local veh = getPedOccupiedVehicle(localPlayer)
            if veh == source then
                if isElement(beltSound) then
                    destroyElement(beltSound)
                end
            end
        end
    end
)