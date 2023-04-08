local screenX, screenY = guiGetScreenSize()

createdPeds = {}
local oldData = {}

local isCinematicStarted = false
local currentCinematicData = false
local liftDownAnimationTimer = false
isTalkingWithPed = false

local animHeight = 0
talkedWithShiftLeader = false

function createJobPeds()
    local shiftLeaderData = jobData.shiftLeaderData
    local element = Ped(shiftLeaderData.skinId, shiftLeaderData.spawnPoint)

    element.interior = shiftLeaderData.interior
    element.dimension = shiftLeaderData.dimension
    element.rotation = shiftLeaderData.rotation

    element:setData("ped.name", "Hugh Wiley")
    element:setData("ped.type", "Műszakvezető")

    createdPeds[element] = "shiftLeader"
end

function createPickupMarkers()
    for i = 1, #jobData.pickupMarkerLocations do 
        local v = jobData.pickupMarkerLocations[i]

        if v then 
            local deliveryPickupPoint = Vector3(v.x, v.y, v.z)
            local r, g, b = exports.cr_core:getServerColor("blue", false)

            local deliveryPickupMarker = Marker(deliveryPickupPoint, "checkpoint", 1.5, r, g, b)
            local deliveryPickupBlip = exports.cr_radar:createStayBlip("Áru felvétele #" .. i, Blip(deliveryPickupPoint, 0, 2, 255, 0, 0, 255, 0, 0), 0, "target", 24, 24, 255, 87, 87)

            deliveryPickupMarker.interior = v.interior
            deliveryPickupMarker.dimension = v.dimension

            createdMarkers[deliveryPickupMarker] = {name = "deliveryPickupMarker", index = i}
        end
    end
end

function destroyPickupMarkers()
    for k, v in pairs(createdMarkers) do 
        if v.name and v.name == "deliveryPickupMarker" then 
            if isElement(k) then 
                createdMarkers[k] = nil
                k:destroy()
            end

            exports.cr_radar:destroyStayBlip("Áru felvétele #" .. v.index)
        end
    end
end

function startCinematic(element)
    local typ = createdPeds[element] or false

    if cinematicConversations[typ] then 
        isCinematicStarted = true

        createRender("renderCinematic", renderCinematic)

        local name = element:getData("ped.name") or "Ismeretlen"
        local x, y, z, x2, y2, z2 = getCameraMatrix()        
        local pedPosition = element.position

        currentCinematicData = {
            element = element,
            name = name,
            typ = typ,

            state = "init",
            currentText = 1,

            startCameraPosition = {x = x, y = y, z = z, x2 = x2, y2 = y2, z2 = z2},
            targetCameraPosition = jobData.shiftLeaderData.cameraMatrix,
            startTick = getTickCount()
        }

        oldData = {
            chat = exports["cr_custom-chat"]:isChatVisible(),
            hud = localPlayer:getData("hudVisible"),
            keys = localPlayer:getData("keysDenied")
        }

        exports["cr_custom-chat"]:showChat(false)
        toggleAllControls(false)
        setPedAnimation(element, "ped", "idle_chat", -1, true, true, false)

        localPlayer:setData("hudVisible", false)
        localPlayer:setData("keysDenied", true)
    end
end

function stopCinematic(element)
    local typ = createdPeds[element] or false

    if cinematicConversations[typ] and isCinematicStarted then 
        currentCinematicData.state = "stop"
        currentCinematicData.startTick = getTickCount()
    end
end

function resetCinematic()
    local element = currentCinematicData.element
    local typ = currentCinematicData.typ

    isCinematicStarted = false
    currentCinematicData = false

    setCameraTarget(localPlayer)
    toggleAllControls(true)

    if isElement(element) then 
        setPedAnimation(element, false)
    end

    exports["cr_custom-chat"]:showChat(oldData.chat)
    localPlayer:setData("hudVisible", oldData.hud)
    localPlayer:setData("keysDenied", oldData.keys)

    oldData = {}

    if cinematicConversations[typ] then 
        for i = 1, #cinematicConversations[typ] do 
            cinematicConversations[typ][i].finished = false
        end
    end

    destroyRender("renderCinematic", renderCinematic)
end

function onClick(button, state, absX, absY, worldX, worldY, worldZ, clickedElement)
    if button == "left" and state == "down" then 
        if isElement(clickedElement) and clickedElement.type == "ped" and createdPeds[clickedElement] then 
            if createdPeds[clickedElement] == "shiftLeader" then
                if getDistanceBetweenPoints3D(localPlayer.position, clickedElement.position) <= 3 and not localPlayer:isInVehicle() and not isElement(deliveryPickupMarker) and not talkedWithShiftLeader then  
                    if not isCinematicStarted then 
                        startCinematic(clickedElement)
                    end
                end
            elseif createdPeds[clickedElement].typ and createdPeds[clickedElement].typ == "customer" then 
                if getDistanceBetweenPoints3D(localPlayer.position, clickedElement.position) <= 3 then
                    if currentOrderInHand and ordersInPDA[currentOrderInHand] then 
                        local pedOrderId = createdPeds[clickedElement].orderId
                        local index = orderIdCache[pedOrderId:lower()]

                        if not ordersInPDA[index].delivered then 
                            if ordersInPDA[currentOrderInHand].orderId == pedOrderId then 
                                if localPlayer:getData("delivery >> crateInHand") and not isTalkingWithPed then 
                                    isTalkingWithPed = true
            
                                    deliverPackage(clickedElement, pedOrderId)
                                end
                            else
                                local syntax = exports.cr_core:getServerSyntax("Delivery", "error")

                                outputChatBox(syntax .. "Rossz csomagot hoztál, ezt nem tudod kézbesíteni.", 255, 0, 0, true)
                            end
                        else 
                            local syntax = exports.cr_core:getServerSyntax("Delivery", "error")

                            outputChatBox(syntax .. "Ez a vásárló már megkapta a csomagját.", 255, 0, 0, true)
                        end
                    end
                end
            end
        elseif isElement(clickedElement) and clickedElement.type == "vehicle" then 
            local jobVehicle = localPlayer:getData("char >> jobVehicle")

            if jobVehicle and clickedElement == jobVehicle then 
                if getDistanceBetweenPoints3D(localPlayer.position, clickedElement.position) <= 5 then 
                    if not isOrdersShowing and isVehicleFilledUp and not closingPanel then 
                        if not localPlayer:getData("delivery >> crateInHand") then 
                            if #orders > 0 and not localPlayer:isInVehicle() then 
                                local compX, compY, compZ = clickedElement:getComponentPosition("boot_dummy", "world")

                                if compX and compY and compZ then 
                                    local vehicleRot = clickedElement.rotation.z
                                    local compPoint = Vector3(compX, compY, compZ)
                                    local distance = getDistanceBetweenPoints3D(localPlayer.position, compPoint)
                                    local playerPosition = localPlayer.position
                                    local playerX, playerY = playerPosition.x, playerPosition.y

                                    if distance < 2 then 
                                        local angle = math.deg(math.atan2(compY - playerY, compX - playerX)) + 180 - vehicleRot

                                        if angle < 0 then 
                                            angle = angle + 360
                                        end

                                        if angle > 210 and angle <= 330 then 
                                            manageOrdersPanel("open")
                                
                                            clickedVehicle = clickedElement
                                        else
                                            local syntax = exports.cr_core:getServerSyntax("Delivery", "error")

                                            outputChatBox(syntax .. "Csak a raktérnél állva tudod használni azt.", 255, 0, 0, true)
                                        end
                                    else
                                        local syntax = exports.cr_core:getServerSyntax("Delivery", "error")

                                        outputChatBox(syntax .. "Túl messze vagy a raktértől.", 255, 0, 0, true)
                                    end
                                else
                                    local syntax = exports.cr_core:getServerSyntax("Delivery", "error")

                                    outputChatBox(syntax .. "Hiba! Ennek a járműnek nincs csomagtartója! Jelentsd egy fejlesztőnek!", 255, 0, 0, true)
                                end
                            end
                        else
                            if not isTalkingWithPed then 
                                local nowTick = getTickCount()

                                if lastClick + 1500 > nowTick then 
                                    return
                                end

                                if currentOrderInHand then 
                                    ordersInPDA[currentOrderInHand].visible = true
                                end

                                localPlayer:setData("forceAnimation", {"carry", "putdwn", -1, false, false, false, false, 250, true})

                                if isTimer(liftDownAnimationTimer) then 
                                    killTimer(liftDownAnimationTimer)
                                    liftDownAnimationTimer = nil
                                end

                                liftDownAnimationTimer = setTimer(
                                    function()
                                        localPlayer:setData("forceAnimation", {"", ""})
                                        liftDownAnimationTimer = nil
                                    end, 275, 1
                                )

                                triggerLatentServerEvent("onClientDeliveryPackagePutdown", 5000, false, localPlayer)
                                lastClick = getTickCount()
                            end
                        end
                    end
                end
            end
        end
    end
end
addEventHandler("onClientClick", root, onClick)

function renderCinematic()
    local nowTick = getTickCount()

    if currentCinematicData then 
        local data = currentCinematicData

        dxDrawRectangle(0, 0, screenX, animHeight, tocolor(0, 0, 0, 255))
        dxDrawRectangle(0, screenY - animHeight, screenX, animHeight, tocolor(0, 0, 0, 255))

        if data.state == "init" then 
            local elapsedTime = nowTick - data.startTick
            local duration = 1200
            local progress = elapsedTime / duration

            local startCamera = data.startCameraPosition
            local targetCamera = data.targetCameraPosition

            local x, y, z = interpolateBetween(startCamera.x, startCamera.y, startCamera.z, targetCamera.x, targetCamera.y, targetCamera.z, progress, "InOutQuad")
            local x2, y2, z2 = interpolateBetween(startCamera.x2, startCamera.y2, startCamera.z2, targetCamera.x2, targetCamera.y2, targetCamera.z2, progress, "InOutQuad")
            animHeight = interpolateBetween(0, 0, 0, resp(jobData.cinematicAnimHeight), 0, 0, progress, "InOutQuad")

            setCameraMatrix(x, y, z, x2, y2, z2)

            if progress >= 1 then 
                currentCinematicData.state = "chat"
                currentCinematicData.startTick = getTickCount()
            end
        elseif data.state == "chat" then
            local conversationData = cinematicConversations[data.typ][data.currentText]

            local text = conversationData.whoIsTalking .. ": " .. conversationData.text
            local font = exports.cr_fonts:getFont("Poppins-Medium", getRealFontSize(20))
            local conversationTime = conversationData.conversationTime

            local elapsedTime = nowTick - data.startTick
            local duration = conversationTime
            local progress = elapsedTime / duration

            local animTextWidth = interpolateBetween(0, 0, 0, utf8.len(text), 0, 0, progress, "Linear")

            dxDrawText(utf8.sub(text, 1, animTextWidth), 30, screenY - animHeight, screenX / 2, screenY, tocolor(255, 255, 255), 1, font, "left", "center", false, true)

            if progress >= 1 then
                cinematicConversations[data.typ][data.currentText].finished = true
            end
        elseif data.state == "stop" then 
            local elapsedTime = nowTick - data.startTick
            local duration = 1200
            local progress = elapsedTime / duration

            local startCamera = data.startCameraPosition
            local targetCamera = data.targetCameraPosition

            local x, y, z = interpolateBetween(targetCamera.x, targetCamera.y, targetCamera.z, startCamera.x, startCamera.y, startCamera.z, progress, "InOutQuad")
            local x2, y2, z2 = interpolateBetween(targetCamera.x2, targetCamera.y2, targetCamera.z2, startCamera.x2, startCamera.y2, startCamera.z2, progress, "InOutQuad")
            animHeight = interpolateBetween(resp(jobData.cinematicAnimHeight), 0, 0, 0, 0, 0, progress, "InOutQuad")

            setCameraMatrix(x, y, z, x2, y2, z2)

            if progress >= 1 then 
                local count = 0

                for i = 1, #cinematicConversations.shiftLeader do 
                    local v = cinematicConversations.shiftLeader[i]

                    if v.finished then 
                        count = count + 1
                    end
                end

                if count >= #cinematicConversations.shiftLeader then 
                    if not isElement(deliveryPickupMarker) then 
                        talkedWithShiftLeader = true

                        createPickupMarkers()
                    end
                end

                resetCinematic()
            end
        end
    end
end

local function onKey(button, state)
    if button == "enter" and state then 
        if isCinematicStarted then 
            local data = currentCinematicData
            local currentText = data.currentText
            local typ = data.typ

            if cinematicConversations[typ][currentText + 1] then 
                if cinematicConversations[data.typ][data.currentText].finished then 
                    currentCinematicData.currentText = currentCinematicData.currentText + 1
                    currentCinematicData.startTick = getTickCount()
                end
            else
                if cinematicConversations[data.typ][data.currentText].finished and data.state ~= "stop" then 
                    stopCinematic(data.element)
                end
            end
        end
    elseif button == "backspace" and state then 
        if isCinematicStarted then 
            local data = currentCinematicData

            if isElement(data.element) then 
                if cinematicConversations[data.typ][data.currentText].finished and data.state ~= "stop" then 
                    stopCinematic(data.element)
                end
            end
        end
    end
end
addEventHandler("onClientKey", root, onKey)

function createCustomer(orderId, name, skinId, x, y, z, rot)
    local customerPoint = Vector3(x, y, z)
    local element = Ped(skinId, customerPoint, rot)

    element.frozen = true
    element:setData("ped.name", name)
    element:setData("ped.type", "Vásárló")
    element:setData("char >> noDamage", true)

    local r, g, b = exports.cr_core:getServerColor("lightyellow", false)
    local customerBlip = exports.cr_radar:createStayBlip("#" .. orderId .. " - " .. name, Blip(customerPoint, 0, 2, 255, 0, 0, 255, 0, 0), 0, "target", 24, 24, r, g, b)

    local arrow = Marker(x, y, z + 1.7, "arrow", 0.5, r, g, b)

    createdPeds[element] = {typ = "customer", orderId = orderId}
    createdMarkers[element] = arrow
end