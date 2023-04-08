old = Vector3(0, 0, 0);
oldOdometerFloor = 0;
if localPlayer.vehicle then 
    old = localPlayer.vehicle.position 
    oldOdometerFloor = math.floor(localPlayer.vehicle:getData("veh >> odometer") or 0)
end 

setTimer(function()
    local veh = localPlayer.vehicle
    if veh then
        local seat = localPlayer.vehicleSeat
        if veh.health > 300 and seat == 0 and not disabledType[getVehicleType(veh)] then
            if veh:getData("veh >> engine") then
                local new = veh.position
                local addKM = getDistanceBetweenPoints3D(veh.position, old) / 500
                local oldOdometer = veh:getData("veh >> odometer") or 0
                old = new
                if addKM ~= 0 then
                    veh:setData("veh >> odometer", oldOdometer + addKM)

                    local tuningData = localPlayer.vehicle:getData("veh >> tuningData") or {}
                    if tonumber(tuningData["nitro"] or 0) == 1 then 
                        if veh:getData("veh >> nitro >> active") then 
                            local nitroLevel = tuningData["nitroLevel"]
                            nitroLevel = nitroLevel - (addKM / 5)
                            if nitroLevel <= 0 then 
                                exports['cr_tuning']:stopNitro()
                                nitroLevel = 0
                                tuningData["nitro"] = 0
                                veh:setData("veh >> nitro >> active", false)
                            end 
                            tuningData["nitroLevel"] = nitroLevel 
                            veh:setData("veh >> tuningData", tuningData)
                        end 
                    end 
                    --outputChatBox(addKM * 250)
                    if math.floor(oldOdometer) ~= math.floor(oldOdometer + addKM) then --if addKM * 250 > 1 then
                        if veh.health <= 550 then 
                            if veh.engineState then 
                                local rand = math.random(1, 100)
                                local chance = (1 - (veh.health - 300) / 250) * 100
                                if rand <= chance then 
                                    local players = exports['cr_core']:getNearbyPlayers("medium")
                                    local soundPath = "assets/sounds/fanbelt1.mp3"
                                    local sound = playSound3D(soundPath, localPlayer.vehicle.position)
                                    sound.dimension = localPlayer.vehicle.dimension 
                                    sound.interior = localPlayer.vehicle.interior 
                                    sound:attach(localPlayer.vehicle)
                                    if #players >= 1 then 
                                        triggerLatentServerEvent("playVehicleSound3D", 5000, false, localPlayer, localPlayer, players, soundPath)
                                    end 
                                end 
                                
                                local chance = (1 - (veh.health - 300) / 250) * 100
                                local rand = math.random(1, 100)
                                --outputChatBox(inspect(rand).. " >> "..inspect(chance))

                                if rand <= chance then 
                                    if veh:getData("veh >> engine") then
                                        veh:setData("veh >> engine", false)
                                    end
                                    if veh.engineState then
                                        veh:setEngineState(false)
                                    end
        
                                    exports['cr_infobox']:addBox("error", "Lefulladt a járműved!")
                                end
                            end 
                        end 
                        
                        if getVehicleType(veh) ~= "BMX" then
                            local newOdometer = veh:getData("veh >> odometer")
                            if math.floor(newOdometer) > oldOdometerFloor then
                                local oldFuel = veh:getData("veh >> fuel")
                                oldFuel = oldFuel - kmMultipler[veh:getData('veh >> virtuaModellID') or veh.model]
                                if oldFuel <= 0 then
                                    oldFuel = 0
                                    if veh:getData("veh >> engine") then
                                        veh:setData("veh >> engine", false)
                                    end
                                    if veh.engineState then
                                        veh:setEngineState(false)
                                    end
                                end
                                veh:setData("veh >> fuel", oldFuel)

                                oldOdometerFloor = math.floor(newOdometer)
                            end
                        end

                        if getVehicleType(veh) ~= "BMX" then
                            local oldOilRecoil = veh:getData("veh >> lastOilRecoil") or 0
                            if oldOdometer + addKM >= oldOilRecoil + 1000 then
                                if not veh:getData("veh >> engineBroken") then
                                    veh:setData("veh >> engineBroken", true)
                                end
                                if veh:getData("veh >> engine") then
                                    setElementData(veh, "veh >> engine", false)
                                end
                                --veh.health = 300
                                triggerServerEvent("setVehicleHealth", localPlayer, veh, 300)
                                exports['cr_infobox']:addBox("error", "Mivel túl rég cseréltél motorolajat, a kocsid lefulladt!")
                                if veh.engineState then
                                    veh:setEngineState(false)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end, 500, 0)