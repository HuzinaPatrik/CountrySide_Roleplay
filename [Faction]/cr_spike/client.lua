local spikeCache = {}
local spikeCreateCache = {}

local spikeColCache = {}
local spikeAnimations = {}

local renderCache = {}
local objectCheckTimer
local deleteButtonHover = false

local lastInteraction = 0
local interactionDelayTime = 1000

function onClientStart()
    setTimer(triggerServerEvent, 1000, 1, "spike.requestSpikes", localPlayer)
end
addEventHandler("onClientResourceStart", resourceRoot, onClientStart)

function onClientColShapeHit(hitElement, mDim)
    if hitElement and hitElement.type == "vehicle" and spikeColCache[source] and mDim then 
        triggerServerEvent("spike.pierceWheels", localPlayer, hitElement)
    end
end
addEventHandler("onClientColShapeHit", root, onClientColShapeHit)

function renderSpikes()
    local nowTick = getTickCount()

    for k, v in pairs(spikeAnimations) do 
        local startTick = v.startTick
        local elapsedTime = nowTick - startTick
        local duration = 1000
        local progress = elapsedTime / duration

        local scaleAnim = interpolateBetween(0, 0, 0, 1, 0, 0, progress, "InOutQuad")

        setObjectScale(k, 1, scaleAnim)

        if progress >= 1 then 
            local index = v.index

            if spikeCache[index] and not isElement(spikeCache[index].spikeCol) then
                local data = spikeCache[index]
                local defaultSpikeData = spikeData[data.objectId]

                local rotated_x1, rotated_y1 = rotateAround(data.rotZ, -defaultSpikeData.width / 2, -defaultSpikeData.length / 2)
                local rotated_x2, rotated_y2 = rotateAround(data.rotZ, defaultSpikeData.width / 2, -defaultSpikeData.length / 2)
                local rotated_x3, rotated_y3 = rotateAround(data.rotZ, defaultSpikeData.width / 2, defaultSpikeData.length / 2)
                local rotated_x4, rotated_y4 = rotateAround(data.rotZ, -defaultSpikeData.width / 2, defaultSpikeData.length / 2)

                local spikeCol = createColPolygon(
                    data.x, data.y,

                    data.x + rotated_x1,
                    data.y + rotated_y1,
        
                    data.x + rotated_x2,
                    data.y + rotated_y2,
        
                    data.x + rotated_x3,
                    data.y + rotated_y3,
        
                    data.x + rotated_x4,
                    data.y + rotated_y4
                )

                spikeCache[index].spikeCol = spikeCol
                spikeColCache[spikeCol] = true
            end

            spikeAnimations[k] = nil

            -- if table.count(spikeAnimations) <= 0 and not showNearbySpikes then 
            --     destroyRender("renderSpikes")
            -- end
        end
    end

    if showNearbySpikes then 
        local font = exports.cr_fonts:getFont("Poppins-Medium", 20)
        local font2 = exports.cr_fonts:getFont("Poppins-Medium", 14)
        local redR, redG, redB = exports.cr_core:getServerColor("red", false)

        deleteButtonHover = nil

        for i = 1, #renderCache do 
            local v = renderCache[i]

            if v then 
                local id = v.id
                local spikeObject = v.spikeObject
                local distance = v.distance
                local createdBy = v.createdBy
                local createdAt = v.createdAt
                local createdAtString = v.createdAtString

                if isElement(spikeObject) then 
                    local x, y, z = getElementPosition(spikeObject)
                    local theX, theY = getScreenFromWorldPosition(x, y, z)

                    if theX and theY then 
                        local size = 1 - (distance / maxDistance)

                        if size > 0 then 
                            local barW, barH = 150 * size, 25 * size
                            local barX, barY = theX - barW / 2, theY - barH / 2

                            local text = "ID: " .. id .. " - Távolság: " .. math.floor(distance) .. " yard - Lerakta: " .. createdBy .. " - Létrehozva: " .. createdAtString
                            
                            dxDrawText(text, barX + 1, barY + 1, barX + barW, barY + barH, tocolor(0, 0, 0, 255 * size), size, font, "center", "center")
                            dxDrawText(text, barX, barY, barX + barW, barY + barH, tocolor(255, 255, 255, 255 * size), size, font, "center", "center")

                            local barY = barY + barH + (10 * size)
                            local inSlot = exports.cr_core:isInSlot(barX, barY, barW, barH)
                            local buttonColor = tocolor(redR, redG, redB, (255 * 0.7) * size)
                            local textColor = tocolor(255, 255, 255, (255 * 0.7) * size)

                            if inSlot then 
                                buttonColor = tocolor(redR, redG, redB, 255 * size)
                                textColor = tocolor(255, 255, 255, 255 * size)

                                deleteButtonHover = id
                            end

                            dxDrawRectangle(barX, barY, barW, barH, buttonColor)
                            dxDrawText("Törlés", barX, barY + (4 * size), barX + barW, barY + barH, textColor, size, font2, "center", "center")
                        end
                    end
                end
            end
        end
    end
end

function onKey(button, state)
    if button == "mouse1" and state then 
        if deleteButtonHover then 
            if localPlayer.vehicle then 
                return
            end

            if lastInteraction + interactionDelayTime > getTickCount() then 
                return
            end

            triggerServerEvent("spike.deleteSpike", localPlayer, deleteButtonHover)

            lastInteraction = getTickCount()
            deleteButtonHover = nil
        end
    end
end

function placeSpikeOnGround(id, data)
    local objectId = data.objectId
    local x, y, z = data.x, data.y, data.z
    local rotZ = data.rotZ
    local createdBy = data.createdBy
    local createdAt = data.createdAt

    if spikeCreateCache[createdAt] then 
        return
    end

    local spikeObject = Object(objectId, x, y, z, 0, 0, rotZ)

    if not spikeAnimations[spikeObject] then 
        spikeAnimations[spikeObject] = {startTick = getTickCount(), index = false}

        if not checkRender("renderSpikes") then 
            createRender("renderSpikes", renderSpikes)
        end
    end

    spikeCache[id] = {
        objectId = objectId,
        x = x,
        y = y,
        z = z,
        rotZ = rotZ,
        createdBy = createdBy,
        createdAt = createdAt,
        spikeObject = spikeObject,
        spikeCol = false
    }

    spikeAnimations[spikeObject].index = id
    spikeCreateCache[createdAt] = spikeObject
end
addEvent("spike.placeSpikeOnGround", true)
addEventHandler("spike.placeSpikeOnGround", root, placeSpikeOnGround)

function nearbySpikesCommand(cmd)
    if exports.cr_faction_scripts:hasPlayerPermission(localPlayer, cmd) then 
        showNearbySpikes = not showNearbySpikes

        if showNearbySpikes then 
            local syntax = exports.cr_core:getServerSyntax("Spike", "success")
            outputChatBox(syntax .. "Sikeresen bekapcsoltad a közelben lévő szögesdrótok megjelenítését.", 255, 0, 0, true)

            if not checkRender("renderSpikes") then 
                createRender("renderSpikes", renderSpikes)
            end

            removeEventHandler("onClientKey", root, onKey)
            addEventHandler("onClientKey", root, onKey)

            if isTimer(objectCheckTimer) then 
                killTimer(objectCheckTimer)
                objectCheckTimer = nil
            end

            renderCache = {}
            objectCheckTimer = setTimer(
                function()
                    renderCache = {}

                    for k, v in pairs(spikeCache) do 
                        if isElement(v.spikeObject) then 
                            local spikeObject = v.spikeObject
                            local distance = getDistanceBetweenPoints3D(localPlayer.position, spikeObject.position)

                            if distance <= 15 then 
                                local objectId = v.objectId
                                local x, y, z = v.x, v.y, v.z
                                local rotZ = v.rotZ
                                local createdBy = v.createdBy
                                local createdAt = v.createdAt

                                local realTime = getRealTime(createdAt)
                                local createdAtString = ("%i.%.2i.%.2i. %.2i:%.2i:%.2i"):format(realTime.year + 1900, realTime.month + 1, realTime.monthday, realTime.hour, realTime.minute, realTime.second)

                                table.insert(renderCache, {
                                    id = k,
                                    objectId = objectId,
                                    x = x,
                                    y = y,
                                    z = z,
                                    rotZ = rotZ,
                                    createdBy = createdBy,
                                    createdAt = createdAt,
                                    spikeObject = spikeObject,
                                    createdAtString = createdAtString,
                                    distance = distance
                                })
                            end
                        end
                    end
                end, 50, 0
            )
        else
            local syntax = exports.cr_core:getServerSyntax("Spike", "error")
            outputChatBox(syntax .. "Sikeresen kikapcsoltad a közelben lévő szögesdrótok megjelenítését.", 255, 0, 0, true)

            destroyRender("renderSpikes")
            removeEventHandler("onClientKey", root, onKey)

            if isTimer(objectCheckTimer) then 
                killTimer(objectCheckTimer)
                objectCheckTimer = nil
            end

            renderCache = {}
        end
    end
end
addCommandHandler("nearbyspikes", nearbySpikesCommand, false, false)

function receiveSpikes(data)
    if type(data) == "table" then 
        for k, v in pairs(data) do 
            placeSpikeOnGround(k, v)
        end
    end
end
addEvent("spike.receiveSpikes", true)
addEventHandler("spike.receiveSpikes", root, receiveSpikes)

function deleteSpike(id)
    if spikeCache[id] then 
        local createdAt = spikeCache[id].createdAt
        local spikeCol = spikeCache[id].spikeCol

        if isElement(spikeCol) then 
            spikeCol:destroy()
        end

        if isElement(spikeCache[id].spikeObject) then 
            spikeCache[id].spikeObject:destroy()
        end

        spikeCreateCache[createdAt] = nil
        spikeCache[id] = nil
        spikeColCache[spikeCol] = nil
    end
end
addEvent("spike.deleteSpike", true)
addEventHandler("spike.deleteSpike", root, deleteSpike)

-- local customYaw = 0
-- local customRoll = 0

-- function processPeds()
--     if localPlayer.name == "Hugh_Wiley" then 
--         local yaw, pitch, roll = getElementBoneRotation(localPlayer, 2)
--         -- local yaw, pitch, roll = getElementBoneRotation(localPlayer, 25)

--         customYaw = customYaw + 0.5
--         customRoll = customRoll + 0.5

--         setElementBoneRotation(localPlayer, 22, customYaw, pitch, -customRoll)
--         setElementBoneRotation(localPlayer, 23, customYaw, pitch, -customRoll)
--         setElementBoneRotation(localPlayer, 25, 180, 0, 0)
--         -- setElementBoneRotation(localPlayer, 2, 0, 0, 0)

--         updateElementRpHAnim(localPlayer)
--     end
-- end
-- addEventHandler("onClientPedsProcessed", root, processPeds)