local screenX, screenY = guiGetScreenSize()

local alpha = 255
local fadeData = {
    alpha = 255,
    targetAlpha = 0,
    startTick = getTickCount()
}

local minLines = 1
local maxLines = screenY / 10

local lineFadeData = {}

function updateLines()
    lineFadeData = {}

    for i = minLines, maxLines do 
        lineFadeData[i] = {
            startTick = getTickCount() + i * 64,
            state = "start"
        }
    end
end

local controlsEnabled = false
local hoverControls = false
local isRender = false
local oldSelectedCamera = 1

local lineUpdateTimer = false
local oldData = {}

local minZoom = 70
local maxZoom = 5
local currentZoom = minZoom

local maxCameraRotation = 1
local minCameraRotation = -1
local currentCameraRotation = 0

local maxCameraAngle = 3
local minCameraAngle = -3
local currentCameraAngle = 0

local timeUpdateTimer = false
local formattedTime = false

function manageCameraPanel(state)
    if state == "init" then 
        exports.cr_dx:startFade("cameraViewPanel", 
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

        if isTimer(timeUpdateTimer) then 
            killTimer(timeUpdateTimer)
            timeUpdateTimer = nil
        end

        local realTime = getRealTime()
        formattedTime = ("%d.%.2d.%.2d - %02d:%02d:%02d"):format(realTime.year + 1900, realTime.month + 1, realTime.monthday, realTime.hour, realTime.minute, realTime.second)

        timeUpdateTimer = setTimer(
            function()
                local realTime = getRealTime()

                formattedTime = ("%d.%.2d.%.2d - %02d:%02d:%02d"):format(realTime.year + 1900, realTime.month + 1, realTime.monthday, realTime.hour, realTime.minute, realTime.second)
            end, 1000, 0
        )

        selectedCamera = 1
        oldSelectedCamera = 1
        isRender = true

        updateLines()
        createRender("renderCameraPanel", renderCameraPanel)

        oldData.chat = exports["cr_custom-chat"]:isChatVisible()
        oldData.hud = localPlayer:getData("hudVisible")
        oldData.keys = localPlayer:getData("keysDenied")
        oldData.frozen = localPlayer.frozen
        oldData.interior = localPlayer.interior
        oldData.dimension = localPlayer.dimension

        exports["cr_custom-chat"]:showChat(false)
        exports.cr_controls:toggleAllControls(false, "instant")

        localPlayer:setData("hudVisible", false)
        localPlayer:setData("keysDenied", true)
        localPlayer.frozen = true

        if isTimer(lineUpdateTimer) then 
            killTimer(lineUpdateTimer)
            lineUpdateTimer = nil
        end

        lineUpdateTimer = setTimer(updateLines, 10000, 0)

        addEventHandler("onClientKey", root, onCameraKey)
        addEventHandler("onClientElementDestroy", root, onElementDestroy)
        addEventHandler("onClientPlayerWasted", root, onPlayerWasted)
    elseif state == "exit" then
        exports.cr_dx:startFade("cameraViewPanel", 
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

        removeEventHandler("onClientKey", root, onCameraKey)
        removeEventHandler("onClientElementDestroy", root, onElementDestroy)
        removeEventHandler("onClientPlayerWasted", root, onPlayerWasted)
    end
end

function renderCameraPanel()
    local alpha, alphaProgress = exports.cr_dx:getFade("cameraViewPanel")

    if alpha and alphaProgress then 
        if alphaProgress >= 1 and alpha <= 0 then 
            destroyRender("renderCameraPanel")

            if isTimer(lineUpdateTimer) then 
                killTimer(lineUpdateTimer)
                lineUpdateTimer = nil
            end

            if isTimer(timeUpdateTimer) then 
                killTimer(timeUpdateTimer)
                timeUpdateTimer = nil
            end

            exports["cr_custom-chat"]:showChat(oldData.chat)
            exports.cr_controls:toggleAllControls(true, "instant")

            localPlayer:setData("hudVisible", oldData.hud)
            localPlayer:setData("keysDenied", oldData.keys)

            setCameraTarget(localPlayer)

            localPlayer.frozen = oldData.frozen
            localPlayer.interior = oldData.interior
            localPlayer.dimension = oldData.dimension
            
            if isElement(currentTerminal) then 
                local data = currentTerminal:getData("terminal >> data") or {}

                if data then 
                    if data.cameraObjects then 
                        if selectedCamera then 
                            if isElement(data.cameraObjects[selectedCamera]) then 
                                data.cameraObjects[selectedCamera].alpha = 255
                            end
                        end
                    end
                end
            end

            selectedCamera = 1
            currentCameraRotation = 0
            lastMarkerHit = 0
            currentZoom = minZoom

            currentTerminal = false
            currentTerminalData = false
            oldData = {}

            return
        end
    end

    if isElement(currentTerminal) then 
        local playerX, playerY, playerZ = getElementPosition(localPlayer)
        local distance = getDistanceBetweenPoints3D(playerX, playerY, playerZ, getElementPosition(currentTerminal))

        if distance >= 3 then 
            if isRender then 
                isRender = false
                manageCameraPanel("exit")
            end
        end
    end

    local nowTick = getTickCount()

    local elapsedTime = nowTick - fadeData.startTick
    local duration = 1000
    local progress = elapsedTime / duration

    local interpolationValue = interpolateBetween(fadeData.alpha, 0, 0, fadeData.targetAlpha, 0, 0, progress, "InOutQuad")

    if progress >= 1 then 
        fadeData.alpha = fadeData.alpha == 255 and 0 or 255
        fadeData.targetAlpha = fadeData.targetAlpha == 255 and 0 or 255
        fadeData.startTick = getTickCount()
    end

    local font = exports.cr_fonts:getFont("Poppins-Medium", 30)
    local font2 = exports.cr_fonts:getFont("Poppins-Bold", 15)
    local font3 = exports.cr_fonts:getFont("Poppins-Medium", 22)
    local redR, redG, redB = exports.cr_core:getServerColor("red", false)

    dxDrawRectangle(0, 0, screenX, screenY, tocolor(0, 0, 0, alpha * 0.29))

    local lineW, lineH = screenX, 2
    local lineX, lineY = 0, 0

    for i = minLines, maxLines do 
        if lineFadeData[i] then 
            local lineData = lineFadeData[i]

            local elapsedTime = nowTick - lineData.startTick
            local duration = 500
            local progress = elapsedTime / duration

            if progress > 0 then 
                if lineData.state == "start" then 
                    local lineInterpolationValue = interpolateBetween(255 * 0.6, 0, 0, 0, 0, 0, progress, "InOutQuad")
                    local lineAlpha = lineInterpolationValue * (lineInterpolationValue / (alpha * 0.6))

                    if progress >= 1 then 
                        lineFadeData[i].state = "stop"
                        lineFadeData[i].startTick = getTickCount()
                    end

                    dxDrawRectangle(lineX, lineY, lineW, lineH, tocolor(22, 20, 18, lineAlpha))
                elseif lineData.state == "stop" then 
                    local lineInterpolationValue = interpolateBetween(0, 0, 0, 255 * 0.6, 0, 0, progress, "InOutQuad")
                    local lineAlpha = lineInterpolationValue * (lineInterpolationValue / (alpha * 0.6))

                    dxDrawRectangle(lineX, lineY, lineW, lineH, tocolor(22, 20, 18, lineAlpha))
                end
            else
                dxDrawRectangle(lineX, lineY, lineW, lineH, tocolor(22, 20, 18, alpha * 0.6))
            end
        end

        lineY = lineY + lineH + 8
    end

    local recW, recH = 150, 50
    local recX, recY = 65, 65

    dxDrawRectangle(recX, recY, recW, recH, tocolor(51, 51, 51, alpha * 0.6))

    local circleW, circleH = 35, 35
    local circleX, circleY = recX + circleW / 2, recY + recH / 2 - circleH / 2

    dxDrawImage(circleX, circleY, circleW, circleH, "files/images/circle.png", 0, 0, 0, tocolor(redR, redG, redB, interpolationValue * (interpolationValue / alpha)))
    dxDrawText("REC", circleX + circleW + 10, circleY + 8, circleX + circleW, circleY + circleH, tocolor(redR, redG, redB, alpha), 1, font, "left", "center")

    local cameraW, cameraH = 255, 50
    local cameraX, cameraY = screenX - 65 - cameraW, 65

    dxDrawRectangle(cameraX, cameraY, cameraW, cameraH, tocolor(51, 51, 51, alpha * 0.6))
    dxDrawText("CAMERA #" .. selectedCamera, cameraX, cameraY + 6, cameraX + cameraW, cameraY + cameraH, tocolor(255, 255, 255, alpha), 1, font, "center", "center")

    local timeW, timeH = 255, 50
    local timeX, timeY = screenX - 65 - cameraW, screenY - (timeH * 2) - 15

    dxDrawRectangle(timeX, timeY, timeW, timeH, tocolor(51, 51, 51, alpha * 0.6))
    dxDrawText(formattedTime, timeX, timeY + 6, timeX + timeW, timeY + timeH, tocolor(255, 255, 255, alpha), 1, font3, "center", "center")

    hoverControls = nil

    if not controlsEnabled then 
        local panelW, panelH = 53, 55
        local panelX, panelY = screenX / 2 - panelW / 2, screenY - panelH - 15
        local inSlot = exports.cr_core:isInSlot(panelX, panelY, panelW, panelH)

        local imageColor = tocolor(255, 255, 255, alpha)

        if inSlot then 
            hoverControls = true
            imageColor = tocolor(redR, redG, redB, alpha)
        end

        dxDrawRectangle(panelX, panelY, panelW, panelH, tocolor(51, 51, 51, alpha * 0.6))
        
        local imageW, imageH = 43, 45
        local imageX, imageY = panelX + panelW / 2 - imageW / 2, panelY + panelH / 2 - imageH / 2

        dxDrawImage(imageX, imageY, imageW, imageH, "files/images/controls.png", 0, 0, 0, imageColor)
    else
        local panelW, panelH = 808, 55
        local panelX, panelY = screenX / 2 - panelW / 2, screenY - panelH - 15

        dxDrawRectangle(panelX, panelY, panelW, panelH, tocolor(51, 51, 51, alpha * 0.6))

        local imageColor = tocolor(redR, redG, redB, alpha)
        
        local imageW, imageH = 32, 34
        local imageX, imageY = panelX + 10, panelY + panelH / 2 - imageH / 2
        local inSlot = exports.cr_core:isInSlot(imageX, imageY, imageW, imageH)

        if inSlot then 
            hoverControls = true
        end

        dxDrawImage(imageX, imageY, imageW, imageH, "files/images/controls.png", 0, 0, 0, imageColor)

        local lineW, lineH = 2, panelH - 4
        local lineX, lineY = imageX + imageW + 15, panelY + 2

        dxDrawRectangle(lineX, lineY, lineW, lineH, tocolor(153, 153, 153, alpha * 0.8))

        local switchW, switchH = 72, 31
        local switchX, switchY = lineX + 15, panelY + panelH / 2 - switchH / 2

        dxDrawImage(switchX, switchY, switchW, switchH, "files/images/switch.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
        dxDrawText("Kamera váltás", switchX + switchW + 10, switchY + 4, switchX + switchW, switchY + switchH, tocolor(255, 255, 255, alpha), 1, font2, "left", "center")

        local navW, navH = 139, 31
        local textWidth = dxGetTextWidth("Kamera váltás", 1, font2)
        local navX, navY = switchX + switchW + textWidth + 25, panelY + panelH / 2 - navH / 2

        dxDrawImage(navX, navY, navW, navH, "files/images/navigation.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
        dxDrawText("Kamera elforgatás", navX + navW + 10, navY + 4, navX + navW, navY + navH, tocolor(255, 255, 255, alpha), 1, font2, "left", "center")

        local zoomW, zoomH = 19, 31
        local textWidth = dxGetTextWidth("Kamera elforgatás", 1, font2)
        local zoomX, zoomY = navX + navW + textWidth + 25, panelY + panelH / 2 - zoomH / 2

        dxDrawImage(zoomX, zoomY, zoomW, zoomH, "files/images/zoom.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
        dxDrawText("Nagyítás", zoomX + zoomW + 10, zoomY + 4, zoomX + zoomW, zoomY + zoomH, tocolor(255, 255, 255, alpha), 1, font2, "left", "center")

        local closeW, closeH = 31, 31
        local textWidth = dxGetTextWidth("Nagyítás", 1, font2)
        local closeX, closeY = zoomX + zoomW + textWidth + 25, panelY + panelH / 2 - closeH / 2

        dxDrawImage(closeX, closeY, closeW, closeH, "files/images/close.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
        dxDrawText("Kilépés", closeX + closeW + 10, closeY + 4, closeX + closeW, closeY + closeH, tocolor(255, 255, 255, alpha), 1, font2, "left", "center")
    end

    if nowTick - lastMarkerHit >= 500 and currentTerminalData and currentTerminalData.cameraObjects and currentTerminalData.cameraObjects[selectedCamera] then 
        if getKeyState("w") then 
            if currentCameraRotation + 0.1 <= maxCameraRotation then 
                currentCameraRotation = currentCameraRotation + 0.1

                rotateCamera("up", currentTerminalData.cameraObjects[selectedCamera])
            end
        elseif getKeyState("s") then
            if currentCameraRotation - 0.1 >= minCameraRotation then
                currentCameraRotation = currentCameraRotation - 0.1

                rotateCamera("down", currentTerminalData.cameraObjects[selectedCamera])
            end
        elseif getKeyState("d") then
            local rot = select(3, getElementRotation(currentTerminalData.cameraObjects[selectedCamera]))

            if rot <= 0 then 
                if currentCameraAngle + 0.1 <= maxCameraAngle then 
                    currentCameraAngle = currentCameraAngle + 0.1
    
                    rotateCamera("left", currentTerminalData.cameraObjects[selectedCamera])
                end
            else
                if currentCameraAngle - 0.1 >= minCameraAngle then 
                    currentCameraAngle = currentCameraAngle - 0.1

                    rotateCamera("left", currentTerminalData.cameraObjects[selectedCamera])
                end
            end
        elseif getKeyState("a") then
            local rot = select(3, getElementRotation(currentTerminalData.cameraObjects[selectedCamera]))

            if rot <= 0 then
                if currentCameraAngle - 0.1 >= minCameraAngle then 
                    currentCameraAngle = currentCameraAngle - 0.1

                    rotateCamera("right", currentTerminalData.cameraObjects[selectedCamera])
                end
            else
                if currentCameraAngle + 0.1 <= maxCameraAngle then 
                    currentCameraAngle = currentCameraAngle + 0.1

                    rotateCamera("right", currentTerminalData.cameraObjects[selectedCamera])
                end
            end
        end
    end

    drawEdges()
end

function switchCamera(cameraElement, data)
    currentCameraRotation = 0
    currentCameraAngle = 0
    currentZoom = minZoom

    if isElement(cameraElement) then 
        if data then 
            if data.cameraObjects then 
                if oldSelectedCamera then 
                    if isElement(data.cameraObjects[oldSelectedCamera]) then 
                        data.cameraObjects[oldSelectedCamera].alpha = 255
                    end
                end
            end
        end

        local cameraX, cameraY, cameraZ = getElementPosition(cameraElement)
        local rot = select(3, getElementRotation(cameraElement))
        local x, y = rotateAround(rot, 4, 0)

        localPlayer.interior = cameraElement.interior
        localPlayer.dimension = cameraElement.dimension

        cameraElement.alpha = 0
        setCameraMatrix(cameraX, cameraY - 1, cameraZ, cameraX - x, cameraY - y, cameraZ)
    end
end

function updateCameraZoom(cameraElement)
    if isElement(cameraElement) then 
        local cameraX, cameraY, cameraZ = getElementPosition(cameraElement)
        local rot = select(3, getElementRotation(cameraElement))
        local x, y = rotateAround(rot, 4, 0)

        setCameraMatrix(cameraX, cameraY - 1, cameraZ, cameraX - x + currentCameraAngle, cameraY - y, cameraZ + currentCameraRotation, 0, currentZoom)
    end
end

function rotateCamera(state, cameraElement)
    if isElement(cameraElement) then 
        if state == "down" then 
            local cameraX, cameraY, cameraZ = getElementPosition(cameraElement)
            local rot = select(3, getElementRotation(cameraElement))
            local x, y = rotateAround(rot, 4, 0)

            setCameraMatrix(cameraX, cameraY - 1, cameraZ, cameraX - x + currentCameraAngle, cameraY - y, cameraZ + currentCameraRotation, 0, currentZoom)
        elseif state == "up" then
            local cameraX, cameraY, cameraZ = getElementPosition(cameraElement)
            local rot = select(3, getElementRotation(cameraElement))
            local x, y = rotateAround(rot, 4, 0)

            setCameraMatrix(cameraX, cameraY - 1, cameraZ, cameraX - x + currentCameraAngle, cameraY - y, cameraZ + currentCameraRotation, 0, currentZoom)
        elseif state == "left" then
            local cameraX, cameraY, cameraZ = getElementPosition(cameraElement)
            local rot = select(3, getElementRotation(cameraElement))
            local x, y = rotateAround(rot, 4, 0)

            setCameraMatrix(cameraX, cameraY - 1, cameraZ, cameraX - x + currentCameraAngle, cameraY - y, cameraZ + currentCameraRotation, 0, currentZoom)
        elseif state == "right" then
            local cameraX, cameraY, cameraZ = getElementPosition(cameraElement)
            local rot = select(3, getElementRotation(cameraElement))
            local x, y = rotateAround(rot, 4, 0)

            setCameraMatrix(cameraX, cameraY - 1, cameraZ, cameraX - x + currentCameraAngle, cameraY - y, cameraZ + currentCameraRotation, 0, currentZoom)
        end
    end
end

function onCameraKey(button, state)
    if button == "mouse1" then 
        if state then 
            if isRender then 
                if hoverControls then 
                    controlsEnabled = not controlsEnabled
                end
            end
        end
    elseif button == "arrow_l" then
        if state then 
            if isElement(currentTerminal) then 
                local data = currentTerminal:getData("terminal >> data") or {}

                if data.cameraObjects then 
                    if selectedCamera - 1 > 0 and data.cameraObjects[selectedCamera - 1] then 
                        oldSelectedCamera = selectedCamera
                        selectedCamera = selectedCamera - 1

                        switchCamera(data.cameraObjects[selectedCamera], data)
                    end
                end
            end
        end
    elseif button == "arrow_r" then
        if state then 
            if isElement(currentTerminal) then 
                local data = currentTerminal:getData("terminal >> data") or {}

                if data.cameraObjects then 
                    if selectedCamera + 1 <= #data.cameraObjects and data.cameraObjects[selectedCamera + 1] then 
                        oldSelectedCamera = selectedCamera
                        selectedCamera = selectedCamera + 1
                        
                        switchCamera(data.cameraObjects[selectedCamera], data)
                    end
                end
            end
        end
    elseif button == "arrow_u" then
        if state then 
            if isElement(currentTerminal) then 
                local data = currentTerminal:getData("terminal >> data") or {}

                if data.cameraObjects and data.cameraObjects[selectedCamera] then 
                    if currentCameraRotation + 0.1 <= maxCameraRotation then 
                        currentCameraRotation = currentCameraRotation + 0.1

                        rotateCamera("up", data.cameraObjects[selectedCamera])
                    end
                end
            end
        end
    elseif button == "arrow_d" then
        if state then 
            if isElement(currentTerminal) then 
                local data = currentTerminal:getData("terminal >> data") or {}

                if data.cameraObjects and data.cameraObjects[selectedCamera] then 
                    if currentCameraRotation - 0.1 >= minCameraRotation then 
                        currentCameraRotation = currentCameraRotation - 0.1

                        rotateCamera("down", data.cameraObjects[selectedCamera])
                    end
                end
            end
        end
    elseif button == "escape" then
        if state then 
            if isRender then 
                cancelEvent()

                isRender = false
                manageCameraPanel("exit")
            end
        end
    elseif button == "mouse_wheel_up" then
        if state then 
            if isRender then 
                if isElement(currentTerminal) then 
                    local data = currentTerminal:getData("terminal >> data") or {}

                    if data.cameraObjects and data.cameraObjects[selectedCamera] then 
                        if currentZoom - 5 >= maxZoom then 
                            currentZoom = currentZoom - 5
        
                            updateCameraZoom(data.cameraObjects[selectedCamera]) 
                        end
                    end
                end
            end
        end
    elseif button == "mouse_wheel_down" then
        if state then 
            if isRender then 
                if isElement(currentTerminal) then 
                    local data = currentTerminal:getData("terminal >> data") or {}

                    if data.cameraObjects and data.cameraObjects[selectedCamera] then 
                        if currentZoom + 5 <= minZoom then 
                            currentZoom = currentZoom + 5
        
                            updateCameraZoom(data.cameraObjects[selectedCamera]) 
                        end
                    end
                end
            end
        end
    end
end

function onElementDestroy()
    if isElement(currentTerminal) then 
        local data = currentTerminal:getData("terminal >> data") or {}

        if data.cameraObjects and data.cameraObjects[selectedCamera] then 
            if source == data.cameraObjects[selectedCamera] then 
                if isRender then 
                    isRender = false
                    manageCameraPanel("exit")
                end
            end
        end
    end
end

function onPlayerWasted()
    if isElement(currentTerminal) then 
        local data = currentTerminal:getData("terminal >> data") or {}

        if data.cameraObjects and data.cameraObjects[selectedCamera] then 
            if source == data.cameraObjects[selectedCamera] then 
                if isRender then 
                    isRender = false
                    manageCameraPanel("exit")
                end
            end
        end
    end
end

function drawEdges()
    local padding = 30
    local height = 6
    local defaultWidth = 300

    local leftEdgeW, leftEdgeH = defaultWidth, height
    local leftEdgeX, leftEdgeY = padding, padding

    dxDrawRectangle(leftEdgeX, leftEdgeY, leftEdgeW, leftEdgeH, tocolor(255, 255, 255, alpha * 0.6))

    local leftEdgeW, leftEdgeH = height, defaultWidth - height
    local leftEdgeX, leftEdgeY = padding, padding + leftEdgeW

    dxDrawRectangle(leftEdgeX, leftEdgeY, leftEdgeW, leftEdgeH, tocolor(255, 255, 255, alpha * 0.6))

    local rightEdgeW, rightEdgeH = defaultWidth, height
    local rightEdgeX, rightEdgeY = screenX - padding - rightEdgeW, padding

    dxDrawRectangle(rightEdgeX, rightEdgeY, rightEdgeW, rightEdgeH, tocolor(255, 255, 255, alpha * 0.6))

    local rightEdgeW, rightEdgeH = height, defaultWidth - height
    local rightEdgeX, rightEdgeY = screenX - padding - rightEdgeW, padding + rightEdgeW

    dxDrawRectangle(rightEdgeX, rightEdgeY, rightEdgeW, rightEdgeH, tocolor(255, 255, 255, alpha * 0.6))

    local leftBottomEdgeW, leftBottomEdgeH = height, defaultWidth - height
    local leftBottomEdgeX, leftBottomEdgeY = leftEdgeX, screenY - padding - leftBottomEdgeH

    dxDrawRectangle(leftBottomEdgeX, leftBottomEdgeY, leftBottomEdgeW, leftBottomEdgeH, tocolor(255, 255, 255, alpha * 0.6))

    local leftBottomEdgeW, leftBottomEdgeH = defaultWidth, height
    local leftBottomEdgeX, leftBottomEdgeY = leftEdgeX + leftBottomEdgeH, screenY - padding - leftBottomEdgeH

    dxDrawRectangle(leftBottomEdgeX, leftBottomEdgeY, leftBottomEdgeW, leftBottomEdgeH, tocolor(255, 255, 255, alpha * 0.6))

    local rightBottomEdgeW, rightBottomEdgeH = defaultWidth, height
    local rightBottomEdgeX, rightBottomEdgeY = screenX - padding - rightBottomEdgeW, screenY - padding - rightBottomEdgeH

    dxDrawRectangle(rightBottomEdgeX, rightBottomEdgeY, rightBottomEdgeW, rightBottomEdgeH, tocolor(255, 255, 255, alpha * 0.6))

    local rightBottomEdgeW, rightBottomEdgeH = height, defaultWidth - height
    local rightBottomEdgeX, rightBottomEdgeY = screenX - padding - rightBottomEdgeW, screenY - padding - rightBottomEdgeH - rightBottomEdgeW

    dxDrawRectangle(rightBottomEdgeX, rightBottomEdgeY, rightBottomEdgeW, rightBottomEdgeH, tocolor(255, 255, 255, alpha * 0.6))
end