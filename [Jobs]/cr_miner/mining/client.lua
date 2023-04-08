local objectHitCheckTimer = false

local function onObjectDamage(loss, attacker)
    if source:getData("rock >> id") then 
        if isElement(attacker) and attacker == localPlayer and attacker:getData("char >> job") == jobData.jobId then 
            if attacker:getWeapon() and attacker:getWeapon() == jobData.pickaxeWeaponId then
                if source:getData("rock >> health") > 0 then 
                    if not source:getData("rock >> respawning") then 
                        if not source:getData("rock >> hittingBy") then 
                            source:setData("rock >> hittingBy", localPlayer)
                            localPlayer:setData("rock >> hitting", source)
                        end

                        if source:getData("rock >> hittingBy") == localPlayer then 
                            if isTimer(objectHitCheckTimer) then 
                                killTimer(objectHitCheckTimer)
                                objectHitCheckTimer = nil
                            end

                            objectHitCheckTimer = setTimer(triggerServerEvent, 60000, 1, "onClientRockRespawnRequest", localPlayer, source)

                            local health = source:getData("rock >> health")
                            local randomLoss = attacker.name == "Hugh_Wiley" and 50 or math.random(jobData.minLoss, jobData.maxLoss)
                            local newValue = math.max(0, health - randomLoss)

                            source:setData("rock >> health", newValue)

                            if newValue <= 0 then 
                                if isTimer(objectHitCheckTimer) then 
                                    killTimer(objectHitCheckTimer)
                                    objectHitCheckTimer = nil
                                end

                                localPlayer:setData("forceAnimation", {"carry", "crry_prtial", 0, true, false, true, true})
                                triggerLatentServerEvent("onClientRockMining", 5000, false, localPlayer, source)
                            end
                        else
                            local syntax = exports.cr_core:getServerSyntax("Miner", "error")

                            outputChatBox(syntax .. "Ezt a követ nem te kezdted el ütni.", 255, 0, 0, true)
                        end
                    else
                        local syntax = exports.cr_core:getServerSyntax("Miner", "error")

                        outputChatBox(syntax .. "Várd meg amíg a kő élete teljesen feltöltődik!", 255, 0, 0, true)
                    end
                end
            end
        end
    end
end
addEventHandler("onClientObjectDamage", root, onObjectDamage)