local pedCache = {}
local pedElementCache = {}
local pedTalkingDelayCache = {}
local createdLocations = {}

local talkingDelay = 30 * 60000
local checkTalkingCacheTimer = false
local randomiseDealersTimer = false

function getRandomLocation()
    local randomLocation = math.random(1, #randomLocations)

    if createdLocations[randomLocation] then 
        return getRandomLocation()
    end

    createdLocations[randomLocation] = true
    return randomLocation
end

function generateDealers()
    createdLocations = {}

    for k, v in pairs(pedCache) do 
        if isElement(v) then 
            if not v:getData("dealer >> talkingWith") then 
                if pedElementCache[v] then 
                    pedElementCache[v] = nil
                end

                v:destroy()
            end
        end
    end

    local currentDealers = 1--math.random(1, maxDealer)

    for i = 1, currentDealers do
        local randomLocation = 1--getRandomLocation()

        local v = randomLocations[randomLocation]
        local randomDrugId = math.random(1, #availableDrugs)
        local pedElement = Ped(v.skinId, v.x, v.y, v.z, v.rotZ)
        local id = v.id

        pedElement.interior = v.interior
        pedElement.dimension = v.dimension
        pedElement.frozen = true

        pedElement:setData("ped.name", v.name)
        pedElement:setData("ped.type", "NPC")
        pedElement:setData("char >> noDamage", true)
        pedElement:setData("dealer >> id", id)
        pedElement:setData("dealer >> drugId", randomDrugId)

        pedCache[i] = pedElement
        pedElementCache[pedElement] = true
    end
end

function onStart()
    generateDealers()

    if isTimer(checkTalkingCacheTimer) then 
        killTimer(checkTalkingCacheTimer)
        checkTalkingCacheTimer = nil
    end

    if isTimer(randomiseDealersTimer) then 
        killTimer(randomiseDealersTimer)
        randomiseDealersTimer = nil
    end

    checkTalkingCacheTimer = setTimer(checkDealerTalkingCache, 5 * 60000, 0)
    randomiseDealersTimer = setTimer(generateDealers, 60 * 60000, 0)
end
addEventHandler("onResourceStart", resourceRoot, onStart)

function setDealerState(element, state)
    if isElement(client) and isElement(element) and pedElementCache[element] then 
        if state then 
            element:setData("dealer >> talkingWith", client)

            local accId = client:getData("acc >> id")
            local dealerId = element:getData("dealer >> id")

            if accId then 
                if not pedTalkingDelayCache[accId] then 
                    pedTalkingDelayCache[accId] = {}
                end

                if not pedTalkingDelayCache[accId][dealerId] then 
                    pedTalkingDelayCache[accId][dealerId] = getTickCount() + talkingDelay
                end
            end
        else 
            element:removeData("dealer >> talkingWith")
        end
    end
end
addEvent("dealer.setDealerState", true)
addEventHandler("dealer.setDealerState", root, setDealerState)

function checkDealerState(element)
    if isElement(client) and isElement(element) then 
        local accId = client:getData("acc >> id")
        local dealerId = element:getData("dealer >> id")

        if accId then 
            if not pedTalkingDelayCache[accId] then 
                pedTalkingDelayCache[accId] = {}
            end

            if not pedTalkingDelayCache[accId][dealerId] then 
                setDealerState(element, true)
                triggerClientEvent(client, "dealer.startCinematic", client, element)
            else
                local syntax = exports.cr_core:getServerSyntax("Dealer", "error")

                outputChatBox(syntax .. "Nem rég beszéltél a dealerrel, várj egy kicsit.", client, 255, 0, 0, true)
            end
        end
    end
end
addEvent("dealer.checkDealerState", true)
addEventHandler("dealer.checkDealerState", root, checkDealerState)

function checkDealerTalkingCache()
    local startTick = getTickCount()
    local removedCount = 0

    for k, v in pairs(pedTalkingDelayCache) do 
        for k2, v2 in pairs(v) do 
            if isElement(pedCache[k2]) then 
                if not pedCache[k2]:getData("dealer >> talkingWith") then 
                    local savedTick = v2

                    if savedTick < startTick then 
                        pedTalkingDelayCache[k][k2] = nil
                        removedCount = removedCount + 1

                        if #pedTalkingDelayCache[k] <= 0 then 
                            pedTalkingDelayCache[k] = nil
                        end
                    end
                end
            end
        end
    end

    -- outputDebugString("@checkDealerTalkingCache: deleted " .. removedCount .. " talking delay(s) from the cache in " .. getTickCount() - startTick .. " ms.", 0, 255, 50, 255)
end