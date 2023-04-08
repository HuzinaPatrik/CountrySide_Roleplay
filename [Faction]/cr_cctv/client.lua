local screenX, screenY = guiGetScreenSize()

local cameraEditor = {
    active = false,
    cameraElement = false
}

selectedCamera = 1
currentTerminal = false
currentTerminalData = false
lastMarkerHit = 0

function resetCameraEditor()
    if isElement(cameraEditor.cameraElement) then 
        cameraEditor.cameraElement:destroy()
        cameraEditor.cameraElement = nil
    end

    cameraEditor.active = false
end

function createCameraCommand(cmd)
    if exports.cr_permission:hasPermission(localPlayer, cmd) then 
        if not cameraEditor.active then 
            cameraEditor.active = true

            if isElement(cameraEditor.cameraElement) then 
                cameraEditor.cameraElement:destroy()
                cameraEditor.cameraElement = nil
            end

            cameraEditor.cameraElement = Object(cameraObjectId, localPlayer.position)
            cameraEditor.cameraElement.interior = localPlayer.interior
            cameraEditor.cameraElement.dimension = localPlayer.dimension
            cameraEditor.cameraElement.collisions = false
            cameraEditor.cameraElement:setScale(cameraScale)

            exports.cr_elementeditor:toggleEditor(cameraEditor.cameraElement, "cameraSaveTrigger", "cameraCancelTrigger", true)
        end
    end
end
addCommandHandler("createcamera", createCameraCommand, false, false)

function cameraSaveTrigger(element, x, y, z, rx, ry, rz, scale)
    if isElement(element) then 
        triggerServerEvent("cctv.createCamera", localPlayer, {
            position = {x, y, z},
            rotation = {rx, ry, rz},
            scaleData = scale,
            interior = element.interior,
            dimension = element.dimension
        })

        resetCameraEditor()
    end
end
addEvent("cameraSaveTrigger", true)
addEventHandler("cameraSaveTrigger", root, cameraSaveTrigger)

function cameraCancelTrigger(element, x, y, z, rx, ry, rz, scale)
    resetCameraEditor()
end
addEvent("cameraCancelTrigger", true)
addEventHandler("cameraCancelTrigger", root, cameraCancelTrigger)

function onClientMarkerHit(hitElement, mDim)
    if hitElement == localPlayer and mDim then 
        if source:getData("terminal >> id") and not currentTerminal then 
            local data = source:getData("terminal >> data") or {}

            if getDistanceBetweenPoints3D(localPlayer.position, source.position) < 5 then 
                if data.assignedCameras then 
                    if #data.assignedCameras > 0 then 
                        local cameraData = data.cameraObjects

                        if cameraData[selectedCamera] then 
                            local cameraElement = cameraData[selectedCamera]

                            if isElement(cameraElement) then
                                currentTerminal = source
                                currentTerminalData = source:getData("terminal >> data") or {}
                                lastMarkerHit = getTickCount()
                                
                                manageCameraPanel("init")
                                switchCamera(cameraElement, data)
                            end
                        end
                    else
                        local syntax = exports.cr_core:getServerSyntax("CCTV", "error")

                        outputChatBox(syntax .. "Ehhez a terminálhoz nincs hozzárendelve egy kamera sem.", 255, 0, 0, true)
                    end
                end
            end
        end
    end
end
addEventHandler("onClientMarkerHit", root, onClientMarkerHit)

-- PANEL

local isRender = false
local hoverButton = false
local selectedElement = false
local removeFromPanel = false

function renderCameraAssignPanel()
    local alpha, progress = exports.cr_dx:getFade("cameraAssignPanel")

    if alpha and progress then 
        if progress >= 1 and alpha <= 0 then 
            if not isRender then 
                destroyRender("renderCameraAssignPanel")
                manageTextbars("destroy")

                return
            end
        end
    end

    local font = exports.cr_fonts:getFont("Poppins-SemiBold", 16)
    local font2 = exports.cr_fonts:getFont("Poppins-Medium", 14)

    local greenR, greenG, greenB = exports.cr_core:getServerColor("green", false)
    local redR, redG, redB = exports.cr_core:getServerColor("red", false)

    local panelW, panelH = 300, 180
    local panelX, panelY = screenX / 2 - panelW / 2, screenY / 2 - panelH / 2

    dxDrawRectangle(panelX, panelY, panelW, panelH, tocolor(51, 51, 51, alpha * 0.8))

    local logoW, logoH = 26, 30
    local logoX, logoY = panelX + 10, panelY + 8

    dxDrawImage(logoX, logoY, logoW, logoH, "files/images/logo.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
    dxDrawText("CCTV", logoX + logoW + 10, logoY + 4, logoX + logoW, logoY + logoH, tocolor(255, 255, 255, alpha), 1, font, "left", "center")

    local inputW, inputH = 250, 25
    local inputX, inputY = panelX + panelW / 2 - inputW / 2, panelY + panelH / 2 - inputH / 2 - 25

    dxDrawRectangle(inputX, inputY, inputW, inputH, tocolor(51, 51, 51, alpha * 0.29))

    UpdatePos("cctv.terminalInput", {inputX, inputY + 2, inputW, inputH})
    UpdateAlpha("cctv.terminalInput", tocolor(255, 255, 255, alpha * 0.6))

    local iconW, iconH = 16, 12
    local iconX, iconY = inputX + 8, inputY + iconH / 2

    dxDrawImage(iconX, iconY, iconW, iconH, "files/images/code.png", 0, 0, 0, tocolor(255, 255, 255, alpha * 0.6))

    local inputW, inputH = 250, 25
    local inputX, inputY = panelX + panelW / 2 - inputW / 2, inputY + 30

    dxDrawRectangle(inputX, inputY, inputW, inputH, tocolor(51, 51, 51, alpha * 0.29))

    UpdatePos("cctv.codeInput", {inputX, inputY + 2, inputW, inputH})
    UpdateAlpha("cctv.codeInput", tocolor(255, 255, 255, alpha * 0.6))

    local iconW, iconH = 50, 50
    local iconX, iconY = inputX - 10, inputY - iconH / 2 + 11

    dxDrawImage(iconX, iconY, iconW, iconH, "files/images/passicon.png", 0, 0, 0, tocolor(255, 255, 255, alpha * 0.6))

    hoverButton = nil

    local buttonW, buttonH = 150, 20
    local buttonX, buttonY = panelX + panelW / 2 - buttonW / 2, panelY + panelH - (buttonH * 2) - 20
    local inSlot = exports.cr_core:isInSlot(buttonX, buttonY, buttonW, buttonH)

    local assignButtonColor = tocolor(greenR, greenG, greenB, alpha * 0.7)
    local assignButtonTextColor = tocolor(255, 255, 255, alpha * 0.6)

    if inSlot then 
        assignButtonColor = tocolor(greenR, greenG, greenB, alpha)
        assignButtonTextColor = tocolor(255, 255, 255, alpha)
        hoverButton = "assign"
    end

    local buttonText = removeFromPanel and "Eltávolítás" or "Hozzárendelés"
    dxDrawRectangle(buttonX, buttonY, buttonW, buttonH, assignButtonColor)
    dxDrawText(buttonText, buttonX, buttonY + 4, buttonX + buttonW, buttonY + buttonH, assignButtonTextColor, 1, font2, "center", "center")

    local buttonW, buttonH = 150, 20
    local buttonX, buttonY = panelX + panelW / 2 - buttonW / 2, panelY + panelH - buttonH - 15
    local inSlot = exports.cr_core:isInSlot(buttonX, buttonY, buttonW, buttonH)

    local cancelButtonColor = tocolor(redR, redG, redB, alpha * 0.7)
    local cancelButtonTextColor = tocolor(255, 255, 255, alpha * 0.6)

    if inSlot then 
        cancelButtonColor = tocolor(redR, redG, redB, alpha)
        cancelButtonTextColor = tocolor(255, 255, 255, alpha)
        hoverButton = "cancel"
    end

    dxDrawRectangle(buttonX, buttonY, buttonW, buttonH, cancelButtonColor)
    dxDrawText("Mégse", buttonX, buttonY + 4, buttonX + buttonW, buttonY + buttonH, cancelButtonTextColor, 1, font2, "center", "center")
end

function manageCameraAssignPanel(state, element, removeFromTerminal)
    if state == "init" then 
        if not isRender then 
            exports.cr_dx:startFade("cameraAssignPanel", 
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

            manageTextbars("create")
            createRender("renderCameraAssignPanel", renderCameraAssignPanel)

            removeEventHandler("onClientKey", root, onKey)
            addEventHandler("onClientKey", root, onKey)

            removeFromPanel = removeFromTerminal
            selectedElement = element
            isRender = true
        end
    elseif state == "exit" then
        exports.cr_dx:startFade("cameraAssignPanel", 
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

        removeEventHandler("onClientKey", root, onKey)
    end
end

function onKey(button, state)
    if button == "mouse1" and state then 
        if hoverButton then 
            if hoverButton == "assign" then 
                if not isElement(selectedElement) then 
                    manageCameraAssignPanel("exit")
                    isRender = false
                    return
                end

                local terminalId = GetText("cctv.terminalInput")
                local cameraCode = GetText("cctv.codeInput")

                if terminalId:len() <= 0 or terminalId == "Add meg a terminál id-jét" then 
                    local syntax = exports.cr_core:getServerSyntax("CCTV", "error")

                    outputChatBox(syntax .. "Add meg a terminálnak az id-jét.", 255, 0, 0, true)
                    return
                end

                if cameraCode:len() <= 0 or cameraCode == "Add meg a kamera kódját" then 
                    local syntax = exports.cr_core:getServerSyntax("CCTV", "error")

                    outputChatBox(syntax .. "Add meg a kamera kódját.", 255, 0, 0, true)
                    return
                end

                local defaultCode = selectedElement:getData("camera >> code")

                if defaultCode ~= cameraCode then 
                    local syntax = exports.cr_core:getServerSyntax("CCTV", "error")

                    outputChatBox(syntax .. "Hibás kamerakód.", 255, 0, 0, true)
                    return
                end

                terminalId = tonumber(terminalId)
                local defaultTerminalId = selectedElement:getData("camera >> terminalId")

                if not removeFromPanel then 
                    if defaultTerminalId == terminalId then 
                        local syntax = exports.cr_core:getServerSyntax("CCTV", "error")

                        outputChatBox(syntax .. "Ez a kamera már a megadott terminálhoz van rendelve.", 255, 0, 0, true)
                        return
                    end

                    triggerServerEvent("cctv.assignCameraToTerminal", localPlayer, terminalId, selectedElement)
                else 
                    if defaultTerminalId ~= terminalId then 
                        local syntax = exports.cr_core:getServerSyntax("CCTV", "error")

                        outputChatBox(syntax .. "Ez a kamera nem ehhez a terminálhoz van rendelve.", 255, 0, 0, true)
                        return
                    end

                    triggerServerEvent("cctv.removeCameraFromTerminal", localPlayer, terminalId, selectedElement)
                end

                isRender = false
                manageCameraAssignPanel("exit")
            elseif hoverButton == "cancel" then
                if isRender then 
                    isRender = false

                    manageCameraAssignPanel("exit")
                end
            end
        end
    end
end

-- COMMANDS

function nearbyTerminals(cmd)
    if exports.cr_permission:hasPermission(localPlayer, cmd) then 
        local cache = {}
        local markers = getElementsByType("marker", resourceRoot, true)
        local playerX, playerY, playerZ = getElementPosition(localPlayer)

        for i = 1, #markers do 
            local v = markers[i]

            if v:getData("terminal >> id") and getDistanceBetweenPoints3D(playerX, playerY, playerZ, getElementPosition(v)) <= 15 then 
                table.insert(cache, v)
            end
        end

        if #cache > 0 then 
            local syntax = exports.cr_core:getServerSyntax("CCTV", "info")
            local hexColor = exports.cr_core:getServerColor("yellow", true)

            for i = 1, #cache do 
                local v = cache[i]

                if isElement(v) then 
                    local id = v:getData("terminal >> id")
                    local distance = math.floor(getDistanceBetweenPoints3D(playerX, playerY, playerZ, getElementPosition(v)))

                    outputChatBox(syntax .. "ID: " .. hexColor .. id .. white .. ", távolság: " .. hexColor .. distance .. white .. " yard.", 255, 0, 0, true)
                end
            end
        else
            local syntax = exports.cr_core:getServerSyntax("CCTV", "error")

            outputChatBox(syntax .. "Nincs a közeledben terminál.", 255, 0, 0, true)
        end
    end
end
addCommandHandler("nearbyterminals", nearbyTerminals, false, false)

function nearbyCamerasCommand(cmd)
    if exports.cr_permission:hasPermission(localPlayer, cmd) then 
        local cache = {}
        local objects = getElementsByType("object", resourceRoot, true)
        local playerX, playerY, playerZ = getElementPosition(localPlayer)

        for i = 1, #objects do 
            local v = objects[i]

            if v:getData("camera >> id") and getDistanceBetweenPoints3D(playerX, playerY, playerZ, getElementPosition(v)) <= 15 then 
                table.insert(cache, v)
            end
        end

        if #cache > 0 then 
            local syntax = exports.cr_core:getServerSyntax("CCTV", "info")
            local hexColor = exports.cr_core:getServerColor("yellow", true)

            for i = 1, #cache do 
                local v = cache[i]

                if isElement(v) then 
                    local id = v:getData("camera >> id")
                    local cameraCode = v:getData("camera >> code")
                    local distance = math.floor(getDistanceBetweenPoints3D(playerX, playerY, playerZ, getElementPosition(v)))

                    outputChatBox(syntax .. "ID: " .. hexColor .. id .. white .. ", kód: " .. hexColor .. cameraCode .. white .. ", távolság: " .. hexColor .. distance .. white .. " yard.", 255, 0, 0, true)
                end
            end
        else
            local syntax = exports.cr_core:getServerSyntax("CCTV", "error")

            outputChatBox(syntax .. "Nincs a közeledben kamera.", 255, 0, 0, true)
        end
    end
end
addCommandHandler("nearbycameras", nearbyCamerasCommand, false, false)

-- ASSETS

function manageTextbars(state)
    if state == "create" then 
        CreateNewBar("cctv.terminalInput", {0, 0, 0, 0}, {5, "Add meg a terminál id-jét", true, tocolor(255, 255, 255), {"Poppins-Medium", 13}, 1, "center", "center", false}, 1)
        CreateNewBar("cctv.codeInput", {0, 0, 0, 0}, {5, "Add meg a kamera kódját", false, tocolor(255, 255, 255), {"Poppins-Medium", 13}, 1, "center", "center", false}, 1)
    elseif state == "destroy" then
        Clear()
    end
end