addEventHandler("onClientVehicleEnter", root, 
    function(player, seat)
        if player == localPlayer and seat == 0 then 
            checkHandling(source)
        end 
    end 
)

addEventHandler("onClientVehicleExit", root, 
    function(player, seat)
        if player == localPlayer and seat == 0 then 
            checkHandling(source)
        end 
    end 
)

function checkHandling(vehicle)
    if vehicle then 
        local data = handlingData[vehicle:getData('veh >> virtuaModellID') or vehicle.model]
        if data then 
            local realHandling = {}

            for k,v in pairs(data) do 
                realHandling[k] = v
            end 

            local tuningData = vehicle:getData("veh >> tuningData") 
            if data["tuningFlags"] and tuningData then 
                for k,v in pairs(data["tuningFlags"]) do 
                    if tuningData[k] then 
                        local val = tuningData[k]
                        local val2 = data["tuningFlags"][k][val]

                        if val2 then 
                            for k,v in pairs(val2) do 
                                if realHandling[k] then 
                                    realHandling[k] = realHandling[k] + v
                                else 
                                    realHandling[k] = v 
                                end 
                            end 
                        end 
                    end 
                end 
            end 

            local nowHandling = getVehicleHandling(vehicle)
            for k,v in pairs(realHandling) do 
                if nowHandling[k] then 
                    if nowHandling[k] ~= v then 
                        setVehicleHandling(vehicle, k, v)
                        triggerLatentServerEvent("setVehicleHandling", 5000, false, localPlayer, vehicle, k, v)
                    end 
                end 
            end 

            --[[ Tuning Load #1/2 ]]

            local tuningData = vehicle:getData("veh >> tuningData") 

            if tuningData then 
                local wheelSizes = {
                    {"verynarrow", "Nagyon vékony"},
                    {"narrow", "Vékony"},
                    {"default", "Alap"},
                    {"wide", "Széles"},
                    {"verywide", "Nagyon széles"},
                }
        
                if tuningData["frontwheel"] then 
                    triggerLatentServerEvent("setVehicleHandlingFlags", 5000, false, localPlayer, vehicle, 3, wheelSizes[tuningData["frontwheel"]][1])
                end 
        
                if tuningData["rearwheel"] then 
                    triggerLatentServerEvent("setVehicleHandlingFlags", 5000, false, localPlayer, vehicle, 4, wheelSizes[tuningData["rearwheel"]][1])
                end 
        
                local driveTypes = {
                    {"fwd", "Elsőkerék"},
                    {"awd", "Összkerék"},
                    {"rwd", "Hátsókerék"},
                }
        
                if tuningData["driveType"] then 
                    triggerLatentServerEvent("setVehicleHandling", 5000, false, localPlayer, vehicle, "driveType", driveTypes[tuningData["driveType"]][1])
                end 
        
                local offroadTypes = {
                    {"default", "Alap"},
                    {"dirt", "Dirt"},
                    {"sand", "Sand"},
                }
        
                if tuningData["offroad"] then 
                    triggerLatentServerEvent("setVehicleHandlingFlags", 5000, false, localPlayer, vehicle, 6, offroadTypes[tuningData["offroad"]][1])
                end 

                if tuningData['optical.9'] then 
                    local upgrades = vehicle:getCompatibleUpgrades(9)
                    if upgrades[1] then 
                        if isTimer(hidroTimer) then killTimer(hidroTimer) end
                        hidroTimer = setTimer(addVehicleUpgrade, 250, 1, vehicle, upgrades[1])
                    end 
                end 
            end
        end 
    end 
end 

function refreshHandling(vehicle, fullRefresh)
    if vehicle then 
        local data = handlingData[vehicle:getData('veh >> virtuaModellID') or vehicle.model]
        
        if fullRefresh then 
            if not data then 
                data = {}
            end 

            local originalHandling = getOriginalHandling(vehicle.model)
            for k,v in pairs(originalHandling) do 
                if not data[k] then 
                    data[k] = v
                end 
            end
        end 
    
        if data then 
            local realHandling = {}

            for k,v in pairs(data) do 
                realHandling[k] = v
            end 

            local tuningData = vehicle:getData("veh >> tuningData") 
            if data["tuningFlags"] and tuningData then 
                for k,v in pairs(data["tuningFlags"]) do 
                    if tuningData[k] then 
                        local val = tuningData[k]
                        local val2 = data["tuningFlags"][k][val]

                        if val2 then 
                            for k,v in pairs(val2) do 
                                if realHandling[k] then 
                                    realHandling[k] = realHandling[k] + v
                                else 
                                    realHandling[k] = v 
                                end 
                            end 
                        end 
                    end 
                end 
            end 

            local nowHandling = getVehicleHandling(vehicle)
            for k,v in pairs(realHandling) do 
                if nowHandling[k] then 
                    if nowHandling[k] ~= v then 
                        setVehicleHandling(vehicle, k, v)
                        triggerLatentServerEvent("setVehicleHandling", 5000, false, localPlayer, vehicle, k, v)
                    end 
                end 
            end 

            --[[ Tuning Load #2/2 ]]

            local tuningData = vehicle:getData("veh >> tuningData") 

            if tuningData then 
                local wheelSizes = {
                    {"verynarrow", "Nagyon vékony"},
                    {"narrow", "Vékony"},
                    {"default", "Alap"},
                    {"wide", "Széles"},
                    {"verywide", "Nagyon széles"},
                }
        
                if tuningData["frontwheel"] then 
                    triggerLatentServerEvent("setVehicleHandlingFlags", 5000, false, localPlayer, vehicle, 3, wheelSizes[tuningData["frontwheel"]][1])
                end 
        
                if tuningData["rearwheel"] then 
                    triggerLatentServerEvent("setVehicleHandlingFlags", 5000, false, localPlayer, vehicle, 4, wheelSizes[tuningData["rearwheel"]][1])
                end 
        
                local driveTypes = {
                    {"fwd", "Elsőkerék"},
                    {"awd", "Összkerék"},
                    {"rwd", "Hátsókerék"},
                }
        
                if tuningData["driveType"] then 
                    triggerLatentServerEvent("setVehicleHandling", 5000, false, localPlayer, vehicle, "driveType", driveTypes[tuningData["driveType"]][1])
                end 
        
                local offroadTypes = {
                    {"default", "Alap"},
                    {"dirt", "Dirt"},
                    {"sand", "Sand"},
                }
        
                if tuningData["offroad"] then 
                    triggerLatentServerEvent("setVehicleHandlingFlags", 5000, false, localPlayer, vehicle, 6, offroadTypes[tuningData["offroad"]][1])
                end 

                if tuningData['optical.9'] then 
                    local upgrades = vehicle:getCompatibleUpgrades(9)
                    if upgrades[1] then 
                        if isTimer(hidroTimer) then killTimer(hidroTimer) end
                        hidroTimer = setTimer(addVehicleUpgrade, 250, 1, vehicle, upgrades[1])
                    end 
                end 
            end
        end 
    end 
end 

function getVehicleMaximumTuningLevel(vehicle, tuningName)
    if vehicle then 
        local data = handlingData[vehicle:getData('veh >> virtuaModellID') or vehicle.model]
        if data then 
            if data["tuningFlags"] and data["tuningFlags"][tuningName] then 
                return data["tuningFlags"][tuningName]["maxLevel"]
            end 
        end 
    end 

    return 0
end 

function getVehicleMinimumHandlingData(vehicle, propertyName)
    if vehicle then 
        local data = handlingData[vehicle:getData('veh >> virtuaModellID') or vehicle.model]
        if data and data[propertyName] then 
            return data[propertyName]
        else 
            return getVehicleHandling(vehicle)[propertyName]
        end 
    end 
end 

function getVehicleMaximumHandlingData(vehicle, propertyName)
    if vehicle then 
        local data = handlingData[vehicle:getData('veh >> virtuaModellID') or vehicle.model]
        if data and data[propertyName] then 
            local realHandling = {}

            for k,v in pairs(data) do 
                realHandling[k] = v
            end 

            if data["tuningFlags"] then 
                for k,v in pairs(data["tuningFlags"]) do 
                    local val = data["tuningFlags"][k]["maxLevel"]
                    local val2 = data["tuningFlags"][k][val]

                    if val2 then 
                        for k,v in pairs(val2) do 
                            if realHandling[k] then 
                                realHandling[k] = realHandling[k] + v
                            else 
                                realHandling[k] = v 
                            end 
                        end 
                    end 
                end 
            end 

            return realHandling[propertyName]
        else 
            return getVehicleHandling(vehicle)[propertyName]
        end 
    end 
end 

function getVehicleAdditionalHandlingData(vehicle, propertyName, tuningName, nextLevel)
    if vehicle then 
        local data = handlingData[vehicle:getData('veh >> virtuaModellID') or vehicle.model]
        if data and data[propertyName] then 
            local realHandling = {}

            for k,v in pairs(data) do 
                realHandling[k] = v
            end 

            local tuningData = vehicle:getData("veh >> tuningData") 
            if data["tuningFlags"] and tuningData then 
                local k = tuningName
                if tuningData[k] and data["tuningFlags"][k] then 
                    local val = nextLevel
                    local val2 = data["tuningFlags"][k][val]

                    if val2 then 
                        for k,v in pairs(val2) do 
                            if realHandling[k] then 
                                realHandling[k] = realHandling[k] + v
                            else 
                                realHandling[k] = v 
                            end 
                        end 
                    end 
                end 
            end 

            return realHandling[propertyName]
        else 
            return getVehicleHandling(vehicle)[propertyName]
        end 
    end 
end 