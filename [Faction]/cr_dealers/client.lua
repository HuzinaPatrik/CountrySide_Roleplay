local screenX, screenY = guiGetScreenSize()

local selectedElement = false
local oldData = {}

local isCinematicStarted = false
local currentCinematicData = false

local animHeight = 0
local timeLeft = 3

local defaultTimeLeft = 3
local countingTimer = false
local isCounterStarted = false

local waitTimer = false
local lastTimerStarted = false
local checkedDialog = false

local selectedCount = 0
local selectedPrice = 0

local sliderAnimData = {
    state = "start",
    startTick = getTickCount(),

    widthMul = 1,
    rgb = {}
}

function startCinematic(element)
    local id = element:getData("dealer >> id")
    local cinematicId = math.random(1, #cinematicConversations)

    if cinematicConversations[cinematicId] then 
        isCinematicStarted = true

        createRender("renderCinematic", renderCinematic)

        local name = element:getData("ped.name") or "Ismeretlen"
        local x, y, z, x2, y2, z2 = getCameraMatrix()        
        local pedPosition = element.position

        local dealerId = element:getData("dealer >> id")
        local drugId = element:getData("dealer >> drugId")

        local cameraMatrix = randomLocations[dealerId].cameraMatrix

        currentCinematicData = {
            element = element,
            name = name,
            cinematicId = cinematicId,
            
            dealerId = dealerId,
            drugId = drugId,

            state = "init",
            currentText = 1,

            startCameraPosition = {x = x, y = y, z = z, x2 = x2, y2 = y2, z2 = z2},
            targetCameraPosition = cameraMatrix,
            startTick = getTickCount()
        }

        oldData = {
            chat = exports["cr_custom-chat"]:isChatVisible(),
            hud = localPlayer:getData("hudVisible"),
            keys = localPlayer:getData("keysDenied")
        }

        exports["cr_custom-chat"]:showChat(false)
        toggleAllControls(false)
        element:setData("forceAnimation", {"ped", "idle_chat", -1, true, true, false})

        localPlayer:setData("hudVisible", false)
        localPlayer:setData("keysDenied", true)
    end
end
addEvent("dealer.startCinematic", true)
addEventHandler("dealer.startCinematic", root, startCinematic)

function stopCinematic(element)
    local id = element:getData("dealer >> id")
    local cinematicId = currentCinematicData.cinematicId

    if cinematicConversations[cinematicId] and isCinematicStarted then 
        currentCinematicData.state = "stop"
        currentCinematicData.startTick = getTickCount()
    end
end

function resetCinematic()
    local element = currentCinematicData.element
    local cinematicId = currentCinematicData.cinematicId

    isCinematicStarted = false
    currentCinematicData = false

    setCameraTarget(localPlayer)
    toggleAllControls(true)

    if isElement(element) then 
        element:setData("forceAnimation", {"", ""})
        element:setData("dealer >> talkingWith", nil)
    end

    exports["cr_custom-chat"]:showChat(oldData.chat)
    localPlayer:setData("hudVisible", oldData.hud)
    localPlayer:setData("keysDenied", oldData.keys)

    oldData = {}
    timeLeft = 3
    isCounterStarted = false

    checkedDialog = false
    lastTimerStarted = false

    selectedCount = 0
    selectedPrice = 0

    if cinematicConversations[cinematicId] then 
        for i = 1, #cinematicConversations[cinematicId] do 
            cinematicConversations[cinematicId][i].finished = false
            cinematicConversations[cinematicId][i].promptActive = false
            cinematicConversations[cinematicId][i].selectedPrompt = 1
        end
    end

    destroyRender("renderCinematic", renderCinematic)
end

local interactionDelay = 1000
local lastClick = 0

function onClick(button, state, absX, absY, worldX, worldY, worldZ, clickedElement)
    if button == "left" and state == "down" then 
        if isElement(clickedElement) and clickedElement.type == "ped" and clickedElement:getData("dealer >> id") then 
            if getDistanceBetweenPoints3D(localPlayer.position, clickedElement.position) <= 3 and not localPlayer:isInVehicle() then
                if clickedElement:getData("dealer >> talkingWith") then 
                    local syntax = exports.cr_core:getServerSyntax("Dealer", "error")

                    outputChatBox(syntax .. "Valaki már beszél ezzel a dealerrel.", 255, 0, 0, true)
                    return
                end

                if not isCinematicStarted then 
                    if lastClick + interactionDelay > getTickCount() then 
                        return
                    end

                    triggerServerEvent("dealer.checkDealerState", localPlayer, clickedElement)
                    lastClick = getTickCount()
                end
            end
        end
    end
end
addEventHandler("onClientClick", root, onClick)

local function onKey(button, state)
    if button == "enter" and state then 
        if isCinematicStarted then 
            local data = currentCinematicData
            local currentText = data.currentText
            local cinematicId = data.cinematicId

            if currentText then 
                if cinematicConversations[cinematicId][currentText + 1] then 
                    if cinematicConversations[cinematicId][data.currentText].finished then 
                        local promptType = cinematicConversations[cinematicId][data.currentText].promptType
                        local selectedPrompt = cinematicConversations[cinematicId][data.currentText].selectedPrompt
                        local selectPrice = cinematicConversations[cinematicId][data.currentText].selectPrice

                        if promptType == "default" then 
                            currentCinematicData.currentText = currentCinematicData.currentText + 1
                            currentCinematicData.startTick = getTickCount()
                        elseif type(promptType) == "table" and promptType[selectedPrompt] == "slider" then
                            local count = 0
                            local value = 0

                            local drugId = data.drugId
                            local drugItemId = availableDrugs[drugId]
            
                            local minPrice = drugData[drugItemId].minPrice
                            local maxPrice = drugData[drugItemId].maxPrice

                            local minCount = drugData[drugItemId].minCount
                            local maxCount = drugData[drugItemId].maxCount

                            if not selectPrice then 
                                local count = 1

                                if sliderAnimData.widthMul >= 0.5 then 
                                    local value = (maxCount / (sliderAnimData.widthMul + 0.5))
                                    
                                    if sliderAnimData.widthMul >= 0.97 then 
                                        value = minCount
                                    end

                                    count = math.max(minCount, math.min(maxCount, math.ceil(value)))
                                else
                                    local value = math.max(minCount, (maxCount * (sliderAnimData.widthMul)))
            
                                    if sliderAnimData.widthMul <= 0.5 and sliderAnimData.widthMul >= 0.45 then 
                                        value = maxCount
                                    end

                                    count = math.max(minCount, math.min(maxCount, math.ceil(value)))
                                end

                                selectedCount = count
                                currentCinematicData.currentText = currentCinematicData.currentText + 1
                                currentCinematicData.startTick = getTickCount()
                            else 
                                local price = 5000

                                if sliderAnimData.widthMul >= 0.5 then 
                                    local value = (maxPrice / (sliderAnimData.widthMul + 0.5))
                                    
                                    if sliderAnimData.widthMul >= 0.97 then 
                                        value = minPrice
                                    end

                                    price = math.max(minPrice, math.min(maxPrice, math.ceil(value)))
                                else
                                    local value = math.max(minPrice, (maxPrice * (sliderAnimData.widthMul)))
            
                                    if sliderAnimData.widthMul <= 0.5 and sliderAnimData.widthMul >= 0.45 then 
                                        value = maxPrice
                                    end

                                    price = math.max(minPrice, math.min(maxPrice, math.ceil(value)))
                                end

                                selectedPrice = price
                                currentCinematicData.currentText = currentCinematicData.currentText + 1
                                currentCinematicData.startTick = getTickCount()
                            end

                            -- if widthMul < 0.5 and widthMul ~= 0 then 
                            --     count = math.ceil(maxCount * widthMul)
                            -- elseif widthMul >= 0.5 and widthMul < 0.6 then
                            --     count = minCount
                            -- elseif widthMul >= 0.6 and widthMul ~= 1 then
                            --     count = math.ceil(maxCount * widthMul)
                            -- elseif widthMul == 0 or widthMul == 1 then
                            --     count = maxCount
                            -- end

                            -- if widthMul >= 0 and widthMul < 0.5 then 
                            --     count = maxCount
                            -- elseif widthMul >= 0.5 and widthMul < 0.7 then
                            --     count = minCount
                            -- elseif widthMul >= 0.7 and widthMul <= 1 then
                            --     count = maxCount
                            -- end
                        end

                        if promptType ~= "counting" then 
                            checkedDialog = false
                        end
                    end
                else
                    if cinematicConversations[cinematicId][data.currentText].finished and data.state ~= "stop" then 
                        if not cinematicConversations[cinematicId][data.currentText].promptActive then 
                            stopCinematic(data.element)
                        end
                    end
                end
            end
        end
    elseif button == "backspace" and state then 
        if isCinematicStarted then 
            local data = currentCinematicData
            local cinematicId = data.cinematicId
            local currentText = data.currentText

            if isElement(data.element) then 
                if cinematicConversations[cinematicId][currentText].promptType == "default" and cinematicConversations[cinematicId][currentText].finished and data.state ~= "stop" then 
                    cinematicConversations[cinematicId][currentText].promptActive = false

                    stopCinematic(data.element)
                end
            end
        end
    end
end
addEventHandler("onClientKey", root, onKey)

function renderCinematic()
    local nowTick = getTickCount()

    if currentCinematicData then 
        local data = currentCinematicData
        local font2 = exports.cr_fonts:getFont("Poppins-Medium", 15)

        dxDrawRectangle(0, 0, screenX, animHeight, tocolor(0, 0, 0, 255))
        dxDrawRectangle(0, screenY - animHeight, screenX, animHeight, tocolor(0, 0, 0, 255))

        local promptType = cinematicConversations[data.cinematicId][data.currentText].promptType
        local selectedPrompt = cinematicConversations[data.cinematicId][data.currentText].selectedPrompt
        local selectPrice = cinematicConversations[data.cinematicId][data.currentText].selectPrice

        local promptType = type(promptType) == "table" and promptType[selectedPrompt] or promptType
        local promptActive = cinematicConversations[data.cinematicId][data.currentText].promptActive

        if promptActive then 
            local promptW, promptH = screenX, 44
            local promptX, promptY = screenX / 2 - promptW / 2, screenY - animHeight - promptH

            dxDrawRectangle(promptX, promptY, promptW, promptH, tocolor(0, 0, 0, 100))

            if promptType == "default" then 
                local imgW, imgH = 64, 22
                local imgX, imgY = screenX / 2 - imgW / 2 - 120, promptY + imgH / 2

                dxDrawImage(imgX, imgY, imgW, imgH, "files/images/backspace.png")
                dxDrawText("Mégse", imgX + imgW + 10, imgY + 2, imgX + imgW, imgY + imgH, tocolor(255, 255, 255, 255), 1, font2, "left", "center")

                local imgW, imgH = 47, 22
                local imgX, imgY = screenX / 2 + 40, promptY + imgH / 2

                dxDrawImage(imgX, imgY, imgW, imgH, "files/images/enter.png")
                dxDrawText("Kiválaszt", imgX + imgW + 10, imgY + 4, imgX + imgW, imgY + imgH, tocolor(255, 255, 255, 255), 1, font2, "left", "center")
            elseif promptType == "selector" then
                local arrowW, arrowH = 25, 26
                local arrowX, arrowY = screenX / 2 - arrowW / 2 - 150, promptY + 9

                dxDrawImage(arrowX, arrowY, arrowW, arrowH, "files/images/arrow_l.png")
                dxDrawImage(arrowX + arrowW + 5, arrowY, arrowW, arrowH, "files/images/arrow_r.png")

                dxDrawText("Navigáció", arrowX + (arrowW * 2) + 13, arrowY + 4, arrowX + arrowW, arrowY + arrowH, tocolor(255, 255, 255, 255), 1, font2, "left", "center")

                local imgW, imgH = 47, 22
                local imgX, imgY = screenX / 2 + 40, promptY + imgH / 2

                dxDrawImage(imgX, imgY, imgW, imgH, "files/images/enter.png")
                dxDrawText("Kiválaszt", imgX + imgW + 10, imgY + 4, imgX + imgW, imgY + imgH, tocolor(255, 255, 255, 255), 1, font2, "left", "center")
            elseif promptType == "counting" then
                dxDrawText(timeLeft, promptX, promptY + 4, promptX + promptW, promptY + promptH, tocolor(255, 255, 255, 255), 1, font2, "center", "center")
            elseif promptType == "slider" then
                local redR, redG, redB = exports.cr_core:getServerColor("red", false)
                local greenR, greenG, greenB = exports.cr_core:getServerColor("green", false)

                local sliderW, sliderH = 400, 30
                local sliderX, sliderY = screenX / 2 - sliderW / 2, promptY - sliderH - 20

                dxDrawRectangle(sliderX, sliderY, sliderW, sliderH, tocolor(0, 0, 0, 150))

                local lineW, lineH = 2, 20
                local lineX, lineY = sliderX, sliderY - lineH

                local drugId = data.drugId
                local drugItemId = availableDrugs[drugId]

                local minPrice = drugData[drugItemId].minPrice
                local maxPrice = drugData[drugItemId].maxPrice

                local minCount = drugData[drugItemId].minCount
                local maxCount = drugData[drugItemId].maxCount

                dxDrawRectangle(lineX, lineY, lineW, lineH, tocolor(0, 0, 0, 150))
                dxDrawText(selectPrice and "$" .. minPrice or minCount .. " db", lineX, lineY - lineH - 15, lineX + lineW, lineY + lineH, tocolor(255, 255, 255, 255), 1, font2, "center", "center")

                local lineW, lineH = 2, 20
                local lineX, lineY = sliderX + sliderW - lineW, sliderY - lineH

                dxDrawRectangle(lineX, lineY, lineW, lineH, tocolor(0, 0, 0, 150))
                dxDrawText(selectPrice and "$" .. minPrice or minCount .. " db", lineX, lineY - lineH - 15, lineX + lineW, lineY + lineH, tocolor(255, 255, 255, 255), 1, font2, "center", "center")

                local lineW, lineH = 2, 20
                local lineX, lineY = sliderX + sliderW / 2 - lineW / 2, sliderY - lineH

                dxDrawRectangle(lineX, lineY, lineW, lineH, tocolor(0, 0, 0, 150))
                dxDrawText(selectPrice and "$" .. maxPrice or maxCount .. " db", lineX, lineY - lineH - 15, lineX + lineW, lineY + lineH, tocolor(255, 255, 255, 255), 1, font2, "center", "center")

                if sliderAnimData.state == "start" then 
                    local elapsedTime = nowTick - sliderAnimData.startTick
                    local duration = 5000--1300
                    local progress = elapsedTime / duration

                    sliderAnimData.widthMul = interpolateBetween(1, 0, 0, 0.5, 0, 0, progress, "Linear")
                    sliderAnimData.rgb = {interpolateBetween(redR, redG, redB, greenR, greenG, greenB, progress, "Linear")}

                    -- if sliderAnimData.widthMul >= 0.5 then 
                    --     local value = (maxCount / (sliderAnimData.widthMul + 0.5))
                        
                    --     if sliderAnimData.widthMul >= 0.97 then 
                    --         value = minCount
                    --     end

                    --     count = math.max(minCount, math.min(maxCount, math.ceil(value)))
                    -- else
                    --     local value = math.max(minCount, (maxCount * (sliderAnimData.widthMul)))

                    --     if sliderAnimData.widthMul <= 0.5 and sliderAnimData.widthMul >= 0.45 then 
                    --         value = maxCount
                    --     end

                    --     count = math.max(minCount, math.min(maxCount, math.ceil(value)))
                    -- end

                    -- if progress >= 1 then 
                    --     local widthMul = sliderAnimData.widthMul

                    --     if selectPrice then 
                    --         if widthMul > 0.5 and widthMul <= 1 then 
                    --             value = math.floor(maxPrice * widthMul)
                    --         elseif widthMul < 0.5 and widthMul > 0.35 then
                    --             value = minPrice
                    --         elseif widthMul < 0.4 and widthMul >= 0.15 then
                    --             value = math.floor(maxPrice * widthMul)
                    --         elseif widthMul < 0.15 then
                    --             value = maxPrice
                    --         end

                    --         selectedPrice = value
                    --         currentCinematicData.currentText = currentCinematicData.currentText + 1
                    --         currentCinematicData.startTick = getTickCount()
                    --     else
                    --         if widthMul > 0.5 and widthMul <= 1 then 
                    --             count = math.ceil(maxCount * widthMul)
                    --         elseif widthMul < 0.5 and widthMul > 0.35 then
                    --             count = minCount
                    --         elseif widthMul < 0.4 and widthMul >= 0.15 then
                    --             count = math.ceil(maxCount * widthMul)
                    --         elseif widthMul < 0.15 then
                    --             count = maxCount
                    --         end

                    --         selectedCount = count
                    --         currentCinematicData.currentText = currentCinematicData.currentText + 1
                    --         currentCinematicData.startTick = getTickCount()
                    --     end

                    --     checkedDialog = false
                    -- end
                end

                local r, g, b = sliderAnimData.rgb[1], sliderAnimData.rgb[2], sliderAnimData.rgb[3]
                dxDrawRectangle(sliderX + 4, sliderY + 4, (sliderW - 8) * sliderAnimData.widthMul, sliderH - 8, tocolor(r, g, b, 150))

                local imgW, imgH = 47, 22
                local imgX, imgY = screenX / 2 - imgW / 2 - 40, promptY + imgH / 2

                dxDrawImage(imgX, imgY, imgW, imgH, "files/images/enter.png")
                dxDrawText("Megállítás", imgX + imgW + 10, imgY + 4, imgX + imgW, imgY + imgH, tocolor(255, 255, 255, 255), 1, font2, "left", "center")
            end
        end

        if data.state == "init" then 
            local elapsedTime = nowTick - data.startTick
            local duration = 1200
            local progress = elapsedTime / duration

            local startCamera = data.startCameraPosition
            local targetCamera = data.targetCameraPosition

            local x, y, z = interpolateBetween(startCamera.x, startCamera.y, startCamera.z, targetCamera.x, targetCamera.y, targetCamera.z, progress, "InOutQuad")
            local x2, y2, z2 = interpolateBetween(startCamera.x2, startCamera.y2, startCamera.z2, targetCamera.x2, targetCamera.y2, targetCamera.z2, progress, "InOutQuad")
            animHeight = interpolateBetween(0, 0, 0, cinematicAnimHeight, 0, 0, progress, "InOutQuad")

            setCameraMatrix(x, y, z, x2, y2, z2)

            if progress >= 1 then 
                currentCinematicData.state = "chat"
                currentCinematicData.startTick = getTickCount()
            end
        elseif data.state == "chat" then
            local conversationData = cinematicConversations[data.cinematicId][data.currentText]

            local text = conversationData.whoIsTalking .. ": " .. conversationData.text
            local font = exports.cr_fonts:getFont("Poppins-Medium", 20)
            local conversationTime = conversationData.conversationTime

            local elapsedTime = nowTick - data.startTick
            local duration = conversationTime
            local progress = elapsedTime / duration

            local drugIndex = currentCinematicData.drugId
            local drugId = availableDrugs[drugIndex]
            local itemName = exports.cr_inventory:getItemName(drugId)

            local text = text:gsub("@A", itemName):gsub("@B", selectedCount):gsub("@C", selectedPrice)
            local animTextWidth = interpolateBetween(0, 0, 0, utf8.len(text), 0, 0, progress, "Linear")

            dxDrawText(utf8.sub(text, 1, animTextWidth), 30, screenY - animHeight, screenX / 2, screenY, tocolor(255, 255, 255), 1, font, "left", "center", false, true)

            if progress >= 1 then
                if not checkedDialog then 
                    checkedDialog = true

                    local data = cinematicConversations[data.cinematicId][data.currentText]

                    if data.lastDialog then 
                        if exports.cr_core:hasMoney(localPlayer, selectedPrice) then 
                            if not lastTimerStarted then 
                                lastTimerStarted = true

                                local drugId = currentCinematicData.drugId
                                local drugItemId = availableDrugs[drugId]

                                exports.cr_core:takeMoney(localPlayer, selectedPrice)
                                exports.cr_inventory:giveItem(localPlayer, drugItemId, 1, selectedCount)

                                if isTimer(waitTimer) then 
                                    killTimer(waitTimer)
                                    waitTimer = nil
                                end

                                waitTimer = setTimer(
                                    function()
                                        currentCinematicData.element:setData("forceAnimation", {"DEALER", "DEALER_DEAL", 3000, false, false, false, false})

                                        setTimer(stopCinematic, 3250, 1, currentCinematicData.element)
                                    end, 1250, 1
                                )
                            end
                        else
                            if not lastTimerStarted then 
                                lastTimerStarted = true

                                if isTimer(waitTimer) then 
                                    killTimer(waitTimer)
                                    waitTimer = nil
                                end

                                waitTimer = setTimer(
                                    function()
                                        currentCinematicData.currentText = currentCinematicData.currentText + 1
                                        currentCinematicData.startTick = getTickCount()

                                        checkedDialog = false
                                        lastTimerStarted = false
                                    end, 1000, 1
                                )
                            end
                        end
                    elseif data.noMoneyDialog then
                        if not lastTimerStarted then 
                            lastTimerStarted = true

                            if isTimer(waitTimer) then 
                                killTimer(waitTimer)
                                waitTimer = nil
                            end

                            waitTimer = setTimer(stopCinematic, 3250, 1, currentCinematicData.element)
                        end
                    end
                end

                cinematicConversations[data.cinematicId][data.currentText].finished = true

                if conversationData.promptType then 
                    if type(conversationData.promptType) == "table" then 
                        local promptType = conversationData.promptType[conversationData.selectedPrompt]

                        if promptType == "counting" then 
                            if not isCounterStarted then 
                                isCounterStarted = true

                                countingTimer = setTimer(
                                    function()
                                        timeLeft = timeLeft - 1

                                        if timeLeft <= 0 then 
                                            cinematicConversations[data.cinematicId][data.currentText].selectedPrompt = 2

                                            timeLeft = 3
                                            isCounterStarted = false

                                            sliderAnimData.state = "start"
                                            sliderAnimData.startTick = getTickCount()
                                        end
                                    end, 1000, defaultTimeLeft
                                )
                            end
                        end
                    end

                    cinematicConversations[data.cinematicId][data.currentText].promptActive = true
                end
            end
        elseif data.state == "stop" then 
            local elapsedTime = nowTick - data.startTick
            local duration = 1200
            local progress = elapsedTime / duration

            local startCamera = data.startCameraPosition
            local targetCamera = data.targetCameraPosition

            local x, y, z = interpolateBetween(targetCamera.x, targetCamera.y, targetCamera.z, startCamera.x, startCamera.y, startCamera.z, progress, "InOutQuad")
            local x2, y2, z2 = interpolateBetween(targetCamera.x2, targetCamera.y2, targetCamera.z2, startCamera.x2, startCamera.y2, startCamera.z2, progress, "InOutQuad")
            animHeight = interpolateBetween(cinematicAnimHeight, 0, 0, 0, 0, 0, progress, "InOutQuad")

            setCameraMatrix(x, y, z, x2, y2, z2)

            if progress >= 1 then 
                resetCinematic()
            end
        end
    end
end