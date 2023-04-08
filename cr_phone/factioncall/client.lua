local screenX, screenY = guiGetScreenSize()

local alpha = 255
local lastClick = false

local factionCallHover = false
local closeButtonHover = false
local factionToCall = false

local closingPhone = false

function manageFactionCall(state, spec)
    if state == "init" then 
        local factionData = factionCalls[calledFaction]

        if #factionData > 0 then 
            exports.cr_dx:startFade("phone.factionCall", 
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

            createRender("renderFactionCallSelector", renderFactionCallSelector)

            removeEventHandler("onClientKey", root, onFactionKey)
            addEventHandler("onClientKey", root, onFactionKey)
        else
            if localPlayer.interior > 0 then 
                local syntax = exports.cr_core:getServerSyntax("Phone", "error")
    
                outputChatBox(syntax .. "Interiorban nem tudod használni a segélyhívót.", 255, 0, 0, true)
                return
            end

            local hoverData = factionCalls[calledFaction]
            local hexColor = exports.cr_core:getServerColor("yellow", true)
            factionToCall = factionCallHover

            exports.cr_dashboard:createAlert(
                {
                    title = {"Biztosan ki szeretnéd hívni a(z) " .. hexColor .. hoverData.name .. white .. " szervet?"},
                    buttons = {
                        {
                            name = "Igen", 
                            pressFunc = "phone.callFaction",
                            color = {exports.cr_core:getServerColor("green", false)},
                        },

                        {
                            name = "Nem", 
                            onClear = true,
                            pressFunc = "phone.cancelFactionCall",
                            color = {exports.cr_core:getServerColor("red", false)},
                        },
                    },
                }
            )
        end
    elseif state == "close" then
        if checkRender("renderFactionCallSelector") then 
            exports.cr_dx:startFade("phone.factionCall", 
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

            closingPhone = spec
            removeEventHandler("onClientKey", root, onFactionKey)
        end
    end
end

function renderFactionCallSelector()
    local alpha, progress = exports.cr_dx:getFade("phone.factionCall")
    if alpha and progress then 
        if progress >= 1 and alpha <= 0 then 
            if closingPhone then 
                calledFaction = false
                calledFactionFrom = false
                closingPhone = false
            end

            lastClick = false
            destroyRender("renderFactionCallSelector")
        end
    end

    local font = exports.cr_fonts:getFont("Poppins-SemiBold", 16)
    local font2 = exports.cr_fonts:getFont("Poppins-Medium", 12)

    local redR, redG, redB = exports.cr_core:getServerColor("red", false)

    local panelW, panelH = 250, 120
    local panelX, panelY = screenX / 2 - panelW / 2, screenY / 2 - panelH / 2

    dxDrawRectangle(panelX, panelY, panelW, panelH, tocolor(51, 51, 51, alpha * 0.8))
    
    local logoW, logoH = 26, 30
    local logoX, logoY = panelX + 10, panelY + 8

    exports.cr_dx:dxDrawImageAsTexture(logoX, logoY, logoW, logoH, ":cr_phone/factioncall/files/images/logo.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
    dxDrawText("Segélyhívó", logoX + logoW + 10, logoY + 4, logoX + logoW, logoY + logoH, tocolor(255, 255, 255, alpha), 1, font, "left", "center")

    local rowW, rowH = 100, 20
    local rowX, rowY = panelX + 25, logoY + logoH + 10

    factionCallHover = nil

    if factionCalls[calledFaction] then
        for i = 1, #factionCalls[calledFaction] do 
            local v = factionCalls[calledFaction][i]

            if v then 
                local rowColor = tocolor(51, 51, 51, alpha * 0.6)
                local textColor = tocolor(255, 255, 255, alpha)
                local inSlot = exports.cr_core:isInSlot(rowX, rowY, rowW, rowH)

                if inSlot then 
                    factionCallHover = i

                    rowColor = tocolor(242, 242, 242, alpha)
                    textColor = tocolor(51, 51, 51, alpha)
                end

                dxDrawRectangle(rowX, rowY, rowW, rowH, rowColor)
                dxDrawText(v.name, rowX, rowY + 2, rowX + rowW, rowY + rowH, textColor, 1, font2, "center", "center")

                rowX = rowX + rowW + 4
            end
        end
    end

    local buttonW, buttonH = 150, 20
    local buttonX, buttonY = panelX + panelW / 2 - buttonW / 2, panelY + panelH - (buttonH * 2) + 5
    local inSlot = exports.cr_core:isInSlot(buttonX, buttonY, buttonW, buttonH)

    local buttonColor = tocolor(redR, redG, redB, alpha * 0.7)
    local textColor = tocolor(255, 255, 255, alpha * 0.6)

    closeButtonHover = nil

    if inSlot then 
        buttonColor = tocolor(redR, redG, redB, alpha)
        textColor = tocolor(255, 255, 255, alpha)

        closeButtonHover = true
    end

    dxDrawRectangle(buttonX, buttonY, buttonW, buttonH, buttonColor)
    dxDrawText("Bezár", buttonX, buttonY + 2, buttonX + buttonW, buttonY + buttonH, textColor, 1, font2, "center", "center")
end

function onFactionKey(button, state)
    if button == "mouse1" and state then 
        if factionCallHover then
            local hoverData = factionCalls[calledFaction][factionCallHover]

            if hoverData then 
                if not lastClick then 
                    if localPlayer.interior > 0 then 
                        local syntax = exports.cr_core:getServerSyntax("Phone", "error")
            
                        outputChatBox(syntax .. "Interiorban nem tudod használni a segélyhívót.", 255, 0, 0, true)
                        return
                    end

                    manageFactionCall("close")

                    local hexColor = exports.cr_core:getServerColor("yellow", true)
                    factionToCall = factionCallHover

                    exports.cr_dashboard:createAlert(
                        {
                            title = {"Biztosan ki szeretnéd hívni a(z) " .. hexColor .. hoverData.name .. white .. " szervet?"},
                            buttons = {
                                {
                                    name = "Igen", 
                                    pressFunc = "phone.callFaction",
                                    color = {exports.cr_core:getServerColor("green", false)},
                                },

                                {
                                    name = "Nem", 
                                    onClear = true,
                                    pressFunc = "phone.cancelFactionCall",
                                    color = {exports.cr_core:getServerColor("red", false)},
                                },
                            },
                        }
                    )

                    lastClick = true
                end
            end
        elseif closeButtonHover then 
            if not lastClick then 
                manageFactionCall("close")

                lastClick = true
            end
        end
    end
end

local markerElement = false
local blipElement = false
local playerElement = false

local blipName = false
local sourceFactionId = false
local sourceCallId = false

function createCallMarker(data)
    if data then 
        if isElement(data.calledElement) then 
            local localName = exports.cr_admin:getAdminName(data.calledElement)
            local redR, redG, redB = exports.cr_core:getServerColor("red", false)
            local playerX, playerY, playerZ = data.calledElement.position.x, data.calledElement.position.y, data.calledElement.position.z - 1

            markerElement = Marker(playerX, playerY, playerZ, "checkpoint", 1, redR, redG, redB)
            markerElement:attach(data.calledElement)

            blipElement = Blip(data.calledElement.position, 0, 2, 255, 0, 0, 255, 0, 0)
            blipElement:attach(data.calledElement)

            blipName = data.callId .. ". számú hívás"
            exports.cr_radar:createStayBlip(blipName, blipElement, 0, "target", 24, 24, redR, redG, redB)

            sourceFactionId = data.calledFactionId
            sourceCallId = data.callId
            playerElement = data.calledElement

            addEventHandler("onClientMarkerHit", markerElement, onClientMarkerHit)
            addEventHandler("onClientPlayerQuit", root, onCallerQuit)
            addEventHandler("onClientElementDataChange", playerElement, handleDataChange)
        end
    end
end
addEvent("phone.createCallMarker", true)
addEventHandler("phone.createCallMarker", root, createCallMarker)

function destroyMarkerAndBlip()
    if isElement(markerElement) then 
        markerElement:destroy()
        markerElement = nil
    end

    if isElement(blipElement) then 
        blipElement:destroy()
        blipElement = nil
    end

    exports.cr_radar:destroyStayBlip(blipName)
end
addEvent("phone.destroyMarkerAndBlip", true)
addEventHandler("phone.destroyMarkerAndBlip", root, destroyMarkerAndBlip)

function onClientMarkerHit(hitElement, mDim)
    if hitElement == localPlayer and mDim then 
        removeEventHandler("onClientMarkerHit", markerElement, onClientMarkerHit)
        removeEventHandler("onClientPlayerQuit", root, onCallerQuit)
        removeEventHandler("onClientElementDataChange", playerElement, handleDataChange)

        triggerServerEvent("phone.deleteFactionCall", localPlayer, sourceFactionId, sourceCallId, false, playerElement)
        destroyMarkerAndBlip()
    end
end

function handleDataChange(dataName, oldValue, newValue)
    if dataName == "inInterior" then
        if newValue then  
            markerElement:detach(source)
            blipElement:detach(source)

            local syntax = exports.cr_core:getServerSyntax("Dispatcher", "error")
            outputChatBox(syntax .. "A gps jel elveszett.", 255, 0, 0, true)
        else 
            setTimer(attachElements, 1000, 1, markerElement, source)
            setTimer(attachElements, 1000, 1, blipElement, source)

            local syntax = exports.cr_core:getServerSyntax("Dispatcher", "success")
            outputChatBox(syntax .. "A gps jel újra elérhető.", 255, 0, 0, true)
        end
    end
end

function onCallerQuit()
    if source == playerElement then 
        local syntax = exports.cr_core:getServerSyntax("Dispatcher", "info")

        outputChatBox(syntax .. "A játékos aki a hívást kezdeményezte, lecsatlakozott a szerverről.", 255, 0, 0, true)
        removeEventHandler("onClientPlayerQuit", root, onCallerQuit)

        destroyMarkerAndBlip()
        triggerServerEvent("phone.deleteFactionCall", localPlayer, sourceFactionId, sourceCallId, true)
    end
end

function callFaction()
    if localPlayer.interior > 0 then 
        local syntax = exports.cr_core:getServerSyntax("Phone", "error")

        outputChatBox(syntax .. "Interiorban nem tudod használni a segélyhívót.", 255, 0, 0, true)
        return
    end

    triggerServerEvent("phone.callFaction", localPlayer, calledFaction, calledFactionFrom, factionToCall)

    factionToCall = false
    calledFaction = false
    calledFactionFrom = false
end
addEvent("phone.callFaction", true)
addEventHandler("phone.callFaction", root, callFaction)

function cancelFactionCall()
    factionToCall = false
    calledFaction = false
    calledFactionFrom = false
end
addEvent("phone.cancelFactionCall", true)
addEventHandler("phone.cancelFactionCall", root, cancelFactionCall)