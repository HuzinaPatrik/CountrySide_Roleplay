local function onObjectDamage(loss, attacker)
    if source:getData("carcass >> id") then 
        if isElement(attacker) and attacker == localPlayer and attacker:getData("char >> job") == jobData.jobId then 
            if attacker:getWeapon() and attacker:getWeapon() == jobData.hatchetWeaponId then
                if source:getData("carcass >> health") > 0 then 
                    if not source:getData("carcass >> respawning") then 
                        if not meatObject then 
                            local health = source:getData("carcass >> health")
                            local randomLoss = math.random(jobData.minLoss, jobData.maxLoss)
                            local newValue = math.max(0, health - randomLoss)

                            source:setData("carcass >> health", newValue)

                            if newValue <= 0 then 
                                localPlayer:setData("forceAnimation", {"carry", "crry_prtial", 0, true, false, true, true})
                                triggerLatentServerEvent("onClientMeatPickUp", 5000, false, localPlayer, source)
                            end
                        else 
                            local syntax = exports.cr_core:getServerSyntax("Butcher", "error")

                            outputChatBox(syntax .. "Addig nem tudsz új húst levágni, ameddig a becsomagolt változatát nem adtad le.", 255, 0, 0, true)
                        end
                    else
                        local syntax = exports.cr_core:getServerSyntax("Butcher", "error")

                        outputChatBox(syntax .. "Várd meg amíg a hús élete teljesen feltöltődik!", 255, 0, 0, true)
                    end
                end
            end
        end
    end
end
addEventHandler("onClientObjectDamage", root, onObjectDamage)