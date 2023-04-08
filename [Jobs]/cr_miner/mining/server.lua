function carryRestriction(element, state)
    local element = client or element

    if isElement(element) then 
        state = not state

        exports.cr_controls:toggleControl(element, jobData.carryControls, state, "high")
    end
end
addEvent("miner.carryRestriction", true)
addEventHandler("miner.carryRestriction", root, carryRestriction)

local respawnTimers = {}

function startRespawn(element)
    if isElement(element) then 
        local id = element:getData("rock >> id")

        if id and not respawnTimers[id] then 
            element:setData("rock >> respawning", true)
            element:removeData("rock >> hittingBy")

            respawnTimers[id] = setTimer(
                function(element)
                    if isElement(element) then 
                        local randomValue = math.random(jobData.minHealth, jobData.maxHealth)
                        local health = element:getData("rock >> health") or 0
                        local newValue = math.min(100, health + randomValue)

                        element:setData("rock >> health", newValue)

                        if newValue >= 100 then 
                            element:removeData("rock >> respawning")
                            
                            local id = element:getData("rock >> id")

                            if isTimer(respawnTimers[id]) then 
                                killTimer(respawnTimers[id])
                                respawnTimers[id] = nil
                            end
                        end
                    end
                end, jobData.rockRespawnTime, 0, element
            )
        end
    end
end

function onClientRockMining(element)
    if not client:getData("miner >> rockInHand") then 
        client:setData("miner >> rockInHand", true)
        client:removeData("rock >> hitting")

        carryRestriction(client, true)
        startRespawn(element)
    end
end
addEvent("onClientRockMining", true)
addEventHandler("onClientRockMining", root, onClientRockMining)

function onClientRockRespawnRequest(rockElement)
    if isElement(client) and isElement(rockElement) then 
        client:removeData("rock >> hitting")

        startRespawn(rockElement)
    end
end
addEvent("onClientRockRespawnRequest", true)
addEventHandler("onClientRockRespawnRequest", root, onClientRockRespawnRequest)

local function onQuit()
    local rockElement = source:getData("rock >> hitting")

    if isElement(rockElement) then 
        rockElement:removeData("rock >> hittingBy")
    end
end
addEventHandler("onPlayerQuit", root, onQuit)