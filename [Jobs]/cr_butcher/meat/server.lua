function carryRestriction(element, state)
    state = not state

    exports.cr_controls:toggleControl(element, jobData.carryControls, state, "high")
end

local respawnTimers = {}

function startRespawn(element)
    if isElement(element) then 
        local id = element:getData("carcass >> id")

        if id and not respawnTimers[id] then 
            element:setData("carcass >> respawning", true)

            respawnTimers[id] = setTimer(
                function(element)
                    if isElement(element) then 
                        local randomValue = math.random(jobData.minHealth, jobData.maxHealth)
                        local health = element:getData("carcass >> health") or 0
                        local newValue = math.min(100, health + randomValue)

                        element:setData("carcass >> health", newValue)

                        if newValue >= 100 then 
                            element:removeData("carcass >> respawning")
                            
                            local id = element:getData("carcass >> id")

                            if isTimer(respawnTimers[id]) then 
                                killTimer(respawnTimers[id])
                                respawnTimers[id] = nil
                            end
                        end
                    end
                end, jobData.carcassRespawnTime, 0, element
            )
        end
    end
end

function onClientMeatPickUp(element) 
    if not client:getData("butcher >> meatInHand") then 
        client:setData("butcher >> meatInHand", true)

        carryRestriction(client, true)
        startRespawn(element)
    end
end
addEvent("onClientMeatPickUp", true)
addEventHandler("onClientMeatPickUp", root, onClientMeatPickUp)

function onClientMeatPutDown() 
    if client:getData("butcher >> meatInHand") then 
        client:setData("butcher >> meatInHand", false)

        carryRestriction(client, false)
    end
end
addEvent("onClientMeatPutDown", true)
addEventHandler("onClientMeatPutDown", root, onClientMeatPutDown)