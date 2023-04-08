local createdMarkers = {}

local wrappingTimer = false
local boxReadyTimer = false

meatObject = false
local isMiniGameStarted = false
local isTheBoxReady = false

function createMarkers()
    local wrappingMarker = Marker(jobData.wrappingMarkerPoint, "cylinder", 1, 124, 197, 118)

    wrappingMarker.interior = jobData.wrappingMarkerInterior
    wrappingMarker.dimension = jobData.wrappingMarkerDimension
    createdMarkers[wrappingMarker] = "wrappingMarker"

    local deliveryMarker = Marker(jobData.deliveryMarkerPoint, "cylinder", 1, 255, 197, 118)
    deliveryMarker:setData("marker >> customMarker", true)
    deliveryMarker:setData("marker >> customIconPath", ":cr_butcher/assets/images/icon.png")

    deliveryMarker.interior = jobData.deliveryMarkerInterior
    deliveryMarker.dimension = jobData.deliveryMarkerDimension
    createdMarkers[deliveryMarker] = "deliveryMarker"
end

function destroyMarkers()
    for k, v in pairs(createdMarkers) do 
        if isElement(k) then 
            k:destroy()
        end
    end

    createdMarkers = {}
end

function onClientMarkerHit(hitElement, mDim)
    if hitElement == localPlayer and mDim then 
        if createdMarkers[source] then 
            if createdMarkers[source] == "wrappingMarker" then 
                if localPlayer:getData("butcher >> meatInHand") then 
                    meatObject = Object(jobData.meatObjectId, jobData.wrappingPoint)

                    meatObject.interior = localPlayer.interior
                    meatObject.dimension = localPlayer.dimension

                    if isElement(meatObject) then 
                        triggerLatentServerEvent("onClientMeatPutDown", 5000, false, localPlayer)

                        local newX, newY, newZ = jobData.wrappingPoint.x, jobData.wrappingPoint.y + 17.6, jobData.wrappingPoint.z
                        moveObject(meatObject, jobData.wrapTime, newX, newY, newZ)

                        if isTimer(wrappingTimer) then 
                            killTimer(wrappingTimer)
                            wrappingTimer = nil
                        end

                        wrappingTimer = setTimer(
                            function()
                                meatObject.model = jobData.crateObjectId
                            end, jobData.wrapTime / 4, 1
                        )

                        if isTimer(boxReadyTimer) then 
                            killTimer(boxReadyTimer)
                            boxReadyTimer = nil
                        end

                        boxReadyTimer = setTimer(
                            function()
                                isTheBoxReady = true
                            end, jobData.wrapTime, 1
                        )
                    end
                else
                    local syntax = exports.cr_core:getServerSyntax("Butcher", "error")

                    outputChatBox(syntax .. "Nincs hús a kezedben, amit a szalagra tudnál rakni.", 255, 0, 0, true)
                end
            elseif createdMarkers[source] == "deliveryMarker" then 
                if localPlayer:getData("butcher >> boxInHand") then 
                    triggerLatentServerEvent("onClientMeatBoxDeliver", 5000, false, localPlayer)

                    destroyMeat()
                    payOut("full")
                else
                    local syntax = exports.cr_core:getServerSyntax("Butcher", "error")

                    outputChatBox(syntax .. "Nincs a kezedben kész doboz, amit le tudnál adni.", 255, 0, 0, true)
                end
            end
        end
    end
end

function onClientClick(button, state, absX, absY, worldX, worldY, worldZ, clickedElement)
    if button == "left" then 
        if state == "down" then 
            if clickedElement and isElement(clickedElement) and clickedElement == meatObject then 
                if not isMiniGameStarted then 
                    if meatObject and meatObject.model == jobData.crateObjectId then 
                        if isTheBoxReady then 
                            if getDistanceBetweenPoints3D(localPlayer.position, meatObject.position) < 3 then 
                                isMiniGameStarted = true
                                exports.cr_minigame:createMinigame(localPlayer, 2, "cr_butcher")
                            end
                        else 
                            local syntax = exports.cr_core:getServerSyntax("Butcher", "error")

                            outputChatBox(syntax .. "A doboz még nem ért a szalag végére, várd meg míg a végére ér!", 255, 0, 0, true)
                        end
                    end
                end
            end
        end
    end
end

function destroyMeat()
    if isElement(meatObject) then 
        meatObject:destroy()
        meatObject = nil
    end

    if isTimer(wrappingTimer) then 
        killTimer(wrappingTimer)
        wrappingTimer = nil
    end
end

local lastPayOutTick = -10000

function payOut(typ)
    if exports.cr_network:getNetworkStatus() then 
        return
    end

    local nowTick = getTickCount()
    local count = 10

    if nowTick <= lastPayOutTick + count * 1000 then
        return
    end

    lastPayOutTick = getTickCount()

    local salaryMultiplier = exports.cr_salary:getMultiplier()
    local randomMoney = jobData.payment * salaryMultiplier --math.random(jobData.minPayment, jobData.maxPayment) * salaryMultiplier
    local moneyToGive = randomMoney

    if typ == "full" then 
        local syntax = exports.cr_core:getServerSyntax("Butcher", "success")
        local hexColor = exports.cr_core:getServerColor("yellow", true)

        outputChatBox(syntax .. "Sikeresen becsomagoltad a húst és sértetlenül leadtad azt.", 255, 0, 0, true)
        outputChatBox(syntax .. "Fizettséged cserébe: " .. hexColor .. "$" .. moneyToGive, 255, 0, 0, true)
    elseif typ == "tenpercent" then
        local syntax = exports.cr_core:getServerSyntax("Butcher", "error")
        local hexColor = exports.cr_core:getServerColor("yellow", true)
        local tenPercent = math.ceil(moneyToGive * 0.1)

        moneyToGive = tenPercent

        outputChatBox(syntax .. "Nem sikerült a hús becsomagolása, ezért az nem szállítható el.", 255, 0, 0, true)
        outputChatBox(syntax .. "Fizettséged cserébe: " .. hexColor .. "$" .. moneyToGive, 255, 0, 0, true)
    end

    exports.cr_core:giveMoney(localPlayer, moneyToGive)
end

function stopMinigame(thePlayer, array)
    if thePlayer == localPlayer and array[2] == "cr_butcher" then 
        isMiniGameStarted = false
        isTheBoxReady = false

        if array[3] >= array[5] then 
            destroyMeat()

            localPlayer:setData("forceAnimation", {"carry", "crry_prtial", 0, true, false, true, true})
            triggerLatentServerEvent("onClientMeatBoxPickUp", 5000, false, localPlayer)
        else
            destroyMeat()
            payOut("tenpercent")
        end
    end
end
addEvent("[Minigame - StopMinigame]", true)
addEventHandler("[Minigame - StopMinigame]", root, stopMinigame)