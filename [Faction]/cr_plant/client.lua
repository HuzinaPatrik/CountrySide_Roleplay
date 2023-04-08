local selectedPlant = false
local selectedPlantObjectId = false
local buttonHover = false

local isRender = false
local maxDistance = 10

local interactionDelayTime = 1000
local lastInteraction = 0

local wateringPlant = false
local wateringTimer = false

local monitoredDatas = {
    ["plant >> status"] = 0,
    ["plant >> growth"] = 0,
    ["plant >> moisture"] = 0
}

local wateringPlants = {}

function onClick(button, state, absX, absY, worldX, worldY, worldZ, clickedElement)
    if button == "right" and state == "down" then 
        if clickedElement and clickedElement.type == "object" then 
            if clickedElement:getData("plant >> pot") then 
                local distance = getDistanceBetweenPoints3D(localPlayer.position, clickedElement.position)

                if distance <= 3 then 
                    if not localPlayer:getData("usingWaterCan") then 
                        local plantElement = clickedElement:getData("plant >> parent")

                        if selectedPlant ~= plantElement then 
                            if isElement(plantElement) then
                                selectedPlantObjectId = plantElement.model
                                selectedPlant = plantElement
                            end

                            for k, v in pairs(monitoredDatas) do 
                                monitoredDatas[k] = plantElement:getData(k)
                            end

                            managePlant("init")
                        end
                    else 
                        exports.cr_infobox:addBox("error", "Előbb rakd el a vizes kannát!")
                    end
                end
            end
        end
    elseif button == "left" and state == "down" then
        if buttonHover == "harvest" then
            if isElement(selectedPlant) then 
                if lastInteraction + interactionDelayTime > getTickCount() then 
                    return
                end

                triggerServerEvent("plant.destroyPlant", localPlayer, selectedPlant)
                lastInteraction = getTickCount()

                return
            end
        elseif buttonHover == "close" then 
            if isRender then 
                isRender = false

                managePlant("close")
                return
            end
        end

        if isElement(clickedElement) and clickedElement.type == "object" then 
            if clickedElement:getData("plant >> pot") then 
                local distance = getDistanceBetweenPoints3D(localPlayer.position, clickedElement.position)

                if distance <= 3 then 
                    local plantElement = clickedElement:getData("plant >> parent")

                    if isElement(plantElement) then 
                        if localPlayer:getData("usingWaterCan") then 
                            local moisture = plantElement:getData("plant >> moisture") or 0

                            if moisture > minMoistureLevel then 
                                local syntax = exports.cr_core:getServerSyntax("Drug", "error")

                                outputChatBox(syntax .. "Ez a növény még túl nedves.", 255, 0, 0, true)
                                return
                            end

                            if moisture >= 100 then 
                                local syntax = exports.cr_core:getServerSyntax("Drug", "error")

                                outputChatBox(syntax .. "Ezt a növényt már nem kell locsolni.", 255, 0, 0, true)
                                return
                            end

                            if not wateringPlant then 
                                wateringPlant = plantElement

                                if isTimer(wateringTimer) then
                                    killTimer(wateringTimer)
                                    wateringTimer = nil
                                end

                                localPlayer:setData("forceAnimation", {"SWORD", "SWORD_idle"})
                                localPlayer:setData("wateringPlant", true)

                                local localPosition = localPlayer.position
                                local targetPosition = clickedElement.position
                                local newRotation = findRotation(localPosition.x, localPosition.y, targetPosition.x, targetPosition.y)

                                localPlayer.rotation = Vector3(0, 0, newRotation)

                                local waterNeed = moisture - 100
                                local time = moisture <= 0 and 10000 or 1000 * (moisture / 10)

                                wateringTimer = setTimer(
                                    function()
                                        if isElement(plantElement) then 
                                            local moisture = plantElement:getData("plant >> moisture") or 0
                                            local newMoisture = math.min(100, moisture + math.abs(waterNeed))

                                            plantElement:setData("plant >> moisture", newMoisture)
                                        end

                                        wateringPlant = false

                                        localPlayer:setData("forceAnimation", {"", ""})
                                        localPlayer:setData("wateringPlant", nil)
                                        triggerServerEvent("plant.manageWatering", localPlayer, getElementsByType("player", root, true), "destroy")
                                    end, time, 1
                                )

                                triggerServerEvent("plant.manageWatering", localPlayer, getElementsByType("player", root, true), "init")
                            end
                        else 
                            exports.cr_infobox:addBox("error", "A locsoláshoz vedd elő a vizes kannát!")
                        end
                    end
                end
            end
        end
    end
end
addEventHandler("onClientClick", root, onClick)

function renderPlant()
    local playerX, playerY, playerZ = getElementPosition(localPlayer)

    local alpha, progress = exports.cr_dx:getFade("plantPanel")
    if alpha and progress then 
        if progress >= 1 and alpha <= 0 then 
            removeEventHandler("onClientElementDataChange", root, handleDataChange)

            isRender = false
            selectedPlant = false
            selectedPlantObjectId = false

            destroyRender("renderPlant")
        end
    end

    if isElement(selectedPlant) then 
        local plantX, plantY, plantZ = getElementPosition(selectedPlant)
        local distance = getDistanceBetweenPoints3D(playerX, playerY, playerZ, plantX, plantY, plantZ)

        if distance > 3 and isRender then 
            isRender = false

            managePlant("close")
        end

        local screenX, screenY = getScreenFromWorldPosition(plantX, plantY, plantZ)

        if screenX and screenY then
            local scale = 1 - (distance / maxDistance)
            local font = exports.cr_fonts:getFont("Poppins-Bold", 18)
            local font2 = exports.cr_fonts:getFont("Poppins-Medium", 13)

            local yellowR, yellowG, yellowB = exports.cr_core:getServerColor("yellow", false)
            local greenR, greenG, greenB = exports.cr_core:getServerColor("green", false)
            local blueR, blueG, blueB = exports.cr_core:getServerColor("blue", false)
            local redR, redG, redB = exports.cr_core:getServerColor("red", false)

            local panelW, panelH = 170 * scale, 265 * scale
            local panelX, panelY = screenX - panelW / 2, screenY - panelH / 2

            dxDrawRectangle(panelX, panelY, panelW, panelH, tocolor(51, 51, 51, alpha * 0.8))

            local logoW, logoH = 32 * scale, 32 * scale
            local logoX, logoY = panelX + panelW / 2 - logoW / 2, panelY + 5 * scale

            dxDrawImage(logoX, logoY, logoW, logoH, "files/images/logo.png", 0, 0, 0, tocolor(255, 255, 255, alpha))

            local plantType = plantTypes[selectedPlantObjectId] and plantTypes[selectedPlantObjectId].name or "Ismeretlen"
            dxDrawText(plantType, panelX, panelY + logoH + 10 * scale, panelX + panelW, panelY + panelH, tocolor(242, 242, 242, alpha), scale, font, "center", "top")

            local statusBarW, statusBarH = panelW - 20 * scale, 15 * scale
            local statusBarX, statusBarY = panelX + 10 * scale, panelY + logoH + 10 * scale + statusBarH + 35 * scale
            local status = monitoredDatas["plant >> status"] or 0

            dxDrawRectangle(statusBarX, statusBarY, statusBarW, statusBarH, tocolor(242, 242, 242, alpha * 0.6))
            dxDrawRectangle(statusBarX, statusBarY, statusBarW * status / 100, statusBarH, tocolor(yellowR, yellowG, yellowB, alpha))
            dxDrawText("Állapot", statusBarX, statusBarY, statusBarX + statusBarW, statusBarY + statusBarH - 13 * scale, tocolor(242, 242, 242, alpha), scale, font2, "left", "bottom")
            dxDrawText(status .. "%", statusBarX, statusBarY, statusBarX + statusBarW, statusBarY + statusBarH - 13 * scale, tocolor(242, 242, 242, alpha), scale, font2, "right", "bottom")

            local growthBarY = statusBarY + statusBarH + 25 * scale
            local growth = monitoredDatas["plant >> growth"] or 0

            dxDrawRectangle(statusBarX, growthBarY, statusBarW, statusBarH, tocolor(242, 242, 242, alpha * 0.6))
            dxDrawRectangle(statusBarX, growthBarY, statusBarW * growth / 100, statusBarH, tocolor(greenR, greenG, greenB, alpha))
            dxDrawText("Növekedés", statusBarX, growthBarY, statusBarX + statusBarW, growthBarY + statusBarH - 13 * scale, tocolor(242, 242, 242, alpha), scale, font2, "left", "bottom")
            dxDrawText(growth .. "%", statusBarX, growthBarY, statusBarX + statusBarW, growthBarY + statusBarH - 13 * scale, tocolor(242, 242, 242, alpha), scale, font2, "right", "bottom")

            local moistureBarY = growthBarY + statusBarH + 25 * scale
            local moisture = monitoredDatas["plant >> moisture"] or 0

            dxDrawRectangle(statusBarX, moistureBarY, statusBarW, statusBarH, tocolor(242, 242, 242, alpha * 0.6))
            dxDrawRectangle(statusBarX, moistureBarY, statusBarW * moisture / 100, statusBarH, tocolor(blueR, blueG, blueB, alpha))
            dxDrawText("Nedvesség", statusBarX, moistureBarY, statusBarX + statusBarW, moistureBarY + statusBarH - 13 * scale, tocolor(242, 242, 242, alpha), scale, font2, "left", "bottom")
            dxDrawText(moisture .. "%", statusBarX, moistureBarY, statusBarX + statusBarW, moistureBarY + statusBarH - 13 * scale, tocolor(242, 242, 242, alpha), scale, font2, "right", "bottom")

            buttonHover = nil

            local harvestButtonW, harvestButtonH = statusBarW, 20 * scale
            local harvestButtonX, harvestButtonY = statusBarX, moistureBarY + statusBarH + 22 * scale

            local buttonColor = tocolor(greenR, greenG, greenB, alpha * 0.7)
            local textColor = tocolor(242, 242, 242, alpha * 0.6)
            local inSlot = exports.cr_core:isInSlot(harvestButtonX, harvestButtonY, harvestButtonW, harvestButtonH)

            if inSlot then 
                buttonHover = "harvest"

                buttonColor = tocolor(greenR, greenG, greenB, alpha)
                textColor = tocolor(242, 242, 242, alpha)
            end

            dxDrawRectangle(harvestButtonX, harvestButtonY, harvestButtonW, harvestButtonH, buttonColor)
            dxDrawText("Betakarítás", harvestButtonX, harvestButtonY + 4 * scale, harvestButtonX + harvestButtonW, harvestButtonY + harvestButtonH, textColor, scale, font2, "center", "center")

            local closeButtonY = harvestButtonY + harvestButtonH + 5 * scale
            local buttonColor = tocolor(redR, redG, redB, alpha * 0.7)
            local textColor = tocolor(242, 242, 242, alpha * 0.6)
            local inSlot = exports.cr_core:isInSlot(harvestButtonX, closeButtonY, harvestButtonW, harvestButtonH)

            if inSlot then 
                buttonHover = "close"

                buttonColor = tocolor(redR, redG, redB, alpha)
                textColor = tocolor(242, 242, 242, alpha)
            end

            dxDrawRectangle(harvestButtonX, closeButtonY, harvestButtonW, harvestButtonH, buttonColor)
            dxDrawText("Bezár", harvestButtonX, closeButtonY + 4 * scale, harvestButtonX + harvestButtonW, closeButtonY + harvestButtonH, textColor, scale, font2, "center", "center")
        end
    else
        if isRender then 
            isRender = false

            managePlant("close")
        end
    end
end

function handleDataChange(dataName, oldValue, newValue)
    if source.type == "object" and source == selectedPlant and monitoredDatas[dataName] then 
        monitoredDatas[dataName] = newValue
    end

    if source == localPlayer then 
        if dataName == "usingWaterCan" then 
            if isRender then 
                isRender = false

                managePlant("close")
            end
        end
    end
end

function managePlant(state)
    if state == "init" then 
        isRender = true

        exports.cr_dx:startFade("plantPanel", 
            {
                startTick = getTickCount(),
                lastUpdateTick = getTickCount(),
                time = 250,
                animation = "InOutQuad",
                from = 0,
                to = 255,
                alpha = 0,
                progress = 0
            }
        )

        removeEventHandler("onClientElementDataChange", root, handleDataChange)
        addEventHandler("onClientElementDataChange", root, handleDataChange)

        createRender("renderPlant", renderPlant)
    elseif state == "close" then
        exports.cr_dx:startFade("plantPanel", 
            {
                startTick = getTickCount(),
                lastUpdateTick = getTickCount(),
                time = 250,
                animation = "InOutQuad",
                from = 255,
                to = 0,
                alpha = 255,
                progress = 0
            }
        )
    end
end

function manageWatering(state, canElement)
    if isElement(source) then 
        if state == "init" then 
            if wateringPlants[source] then 
                wateringPlants[source]:destroy()
                wateringPlants[source] = nil
            end

            local canRotZ = select(3, getElementRotation(canElement))
            local effectX, effectY, effectZ = getPositionFromElementOffset(canElement, -0.9, 0.1, 0.2)

            wateringPlants[source] = createEffect("petrolcan", effectX, effectY, effectZ, 120, 0, -canRotZ + 90)
            setEffectDensity(wateringPlants[source], 2)

            wateringPlants[source].interior = source.interior
            wateringPlants[source].dimension = source.dimension
        elseif state == "destroy" then 
            if wateringPlants[source] then 
                wateringPlants[source]:destroy()
                wateringPlants[source] = nil
            end
        end
    end
end
addEvent("plant.manageWatering", true)
addEventHandler("plant.manageWatering", root, manageWatering)