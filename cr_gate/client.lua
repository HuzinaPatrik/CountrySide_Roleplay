local screenX, screenY = guiGetScreenSize()
local boxWidth, boxHeight = 230, 83 + 71

local alpha = 0

local minLines = 1
local maxLines = 4

local panelDatas = {
    [1] = "Model: @a",
    [2] = {"Nyitási pozíció", {}},
    [3] = {"Zárási pozíció", {}},
    [4] = "Előnézet",
}

local tempObject = false
local selectedObject = 1

local hoverData = false

local objectFadingInterpolation = false
local objectAlpha = false

local objectState = true
local objectMoving = false

function renderGateEditor()
    -- if localPlayer.name ~= "Hugh_Wiley" then 
    --     return
    -- end

    -- local alpha = 255
    local alpha, progress = exports["cr_dx"]:getFade("gateEditorPanel")
    if alpha and progress then 
        if progress >= 1 then 
            if alpha <= 0 then 
                destroyRender("renderGateEditor")
            end
        end
    end

    local nowTick = getTickCount()

    local font = exports.cr_fonts:getFont("Poppins-SemiBold", 16)
    local font2 = exports.cr_fonts:getFont("Poppins-Medium", 12)

    local w, h = boxWidth, boxHeight
    local _w = w
    local x, y = screenX - w - 5, screenY / 2 - h / 2

    dxDrawRectangle(x, y, w, h, tocolor(51, 51, 51, alpha * 0.8))

    local logoW, logoH = 26, 30
    local logoX, logoY = x + 10, y + 8

    dxDrawImage(logoX, logoY, logoW, logoH, "files/images/logo.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
    dxDrawText("Kapu szerkesztő", logoX + logoW + 10, logoY + 4, logoX + logoW, logoY + logoH, tocolor(255, 255, 255, alpha), 1, font, "left", "center")

    local w, h = _w - 20, 20
    local x, y = x + 10, logoY + logoH + h
    local r, g, b = exports["cr_core"]:getServerColor("blue", false)

    hoverData = nil
    for i = minLines, maxLines do 
        local v = panelDatas[i]

        if v then 
            local text = (type(v) == "table" and v[1] or v:gsub("@a", objectDatas["models"][selectedObject]))

            local rowColor = tocolor(51, 51, 51, alpha * 0.29)
            local textColor = tocolor(255, 255, 255, alpha)
            local inSlot = exports["cr_core"]:isInSlot(x, y, w, h)

            if inSlot then 
                rowColor = tocolor(242, 242, 242, alpha)
                textColor = tocolor(51, 51, 51, alpha)

                hoverData = i
            end

            dxDrawRectangle(x, y, w, h, rowColor)
            dxDrawText(text, x, y + 1, x + w, y + h, textColor, 1, font2, "center", "center")
            -- dxDrawText(text, x, y, x + w, y + h, (inSlot and tocolor(51, 51, 51, alpha) or tocolor(242, 242, 242, alpha)), 1, exports["cr_fonts"]:getFont("Roboto", 11), "center", "center")
        end

        y = y + h + 2
    end

    if objectFadingInterpolation then 
        local elapsedTime = nowTick - objectFadingInterpolation
        local duration = 2000
        local progress = elapsedTime / duration

        objectAlpha = interpolateBetween(255, 0, 0, 150, 0, 0, progress, "CosineCurve")

        if tempObject and isElement(tempObject) then 
            tempObject.alpha = objectAlpha
        end
    end
end
-- createRender("renderGateEditor", renderGateEditor)

function changeHoverData(data)
    if data == 1 then 
        if selectedObject + 1 <= #objectDatas["models"] then 
            selectedObject = selectedObject + 1

            setElementModel(tempObject, objectDatas["models"][selectedObject])
            -- local cursorState = isCursorShowing()
            -- exports.cr_elementeditor:quitEditor(true)

            -- if cursorState then 
            --     showCursor(cursorState)
            -- end

            -- local x, y, z = getElementPosition(tempObject)
            -- local rx, ry, rz = getElementRotation(tempObject)

            -- if isElement(tempObject) then 
            --     tempObject:destroy()
            --     tempObject = nil
            -- end

            -- tempObject = Object(objectDatas["models"][selectedObject], x, y, z, rx, ry, rz)
            -- exports.cr_elementeditor:toggleEditor(tempObject, "gateSaveTrigger", "gateRemoveTrigger", true)
        else
            selectedObject = 1
            
            setElementModel(tempObject, objectDatas["models"][selectedObject])
            -- local cursorState = isCursorShowing()
            -- exports.cr_elementeditor:quitEditor(true)

            -- if cursorState then 
            --     showCursor(cursorState)
            -- end

            -- local x, y, z = getElementPosition(tempObject)
            -- local rx, ry, rz = getElementRotation(tempObject)

            -- if isElement(tempObject) then 
            --     tempObject:destroy()
            --     tempObject = nil
            -- end

            -- tempObject = Object(objectDatas["models"][selectedObject], x, y, z, rx, ry, rz)
            -- exports.cr_elementeditor:toggleEditor(tempObject, "gateSaveTrigger", "gateRemoveTrigger", true)
        end
    elseif data == 2 then 
        local startX, startY, startZ = getElementPosition(tempObject)
        local startRx, startRy, startRz = getElementRotation(tempObject)
        local startInterior, startDimension = getElementInterior(tempObject), getElementDimension(tempObject)

        panelDatas[data][2] = {startX, startY, startZ, startRx, startRy, startRz, startInterior, startDimension}

        local syntax = exports["cr_core"]:getServerSyntax(false, "success")
        outputChatBox(syntax.."Sikeresen beállítottad a kapu nyitási pozícióját!", 255, 0, 0, true)
    elseif data == 3 then 
        if #panelDatas[2][2] <= 0 then 
            return exports["cr_infobox"]:addBox("error", "Előbb állítsd be a kapu nyitási pozícióját!")
        end

        local endX, endY, endZ = getElementPosition(tempObject)
        local endRx, endRy, endRz = getElementRotation(tempObject)
        local endInterior, endDimension = getElementInterior(tempObject), getElementDimension(tempObject)

        panelDatas[data][2] = {endX, endY, endZ, endRx, endRy, endRz, endInterior, endDimension}

        local syntax = exports["cr_core"]:getServerSyntax(false, "success")
        outputChatBox(syntax.."Sikeresen beállítottad a kapu zárási pozícióját!", 255, 0, 0, true)
    elseif data == 4 then -- preview
        if tempObject and isElement(tempObject) then 
            local startPosition = panelDatas[2][2]
            local endPosition = panelDatas[3][2]

            if #startPosition > 0 then 
                if #endPosition > 0 then 
                    local startX, startY, startZ, startRx, startRy, startRz, startInterior, startDimension = unpack(startPosition)
                    local endX, endY, endZ, endRx, endRy, endRz, endInterior, endDimension = unpack(endPosition)

                    if not objectMoving then 
                        if not objectState then 
                            local calculatedRz = calculateDifferenceBetweenAngles(startRz, endRz)
                            local calculatedRy = calculateDifferenceBetweenAngles(startRy, endRy)

                            tempObject:move(moveTime, endX, endY, endZ, 0, calculatedRy, calculatedRz, "InOutQuad")

                            objectState = true
                            objectMoving = true
                        else
                            local calculatedRz = calculateDifferenceBetweenAngles(endRz, startRz)
                            local calculatedRy = calculateDifferenceBetweenAngles(endRy, startRy)

                            tempObject:move(moveTime, startX, startY, startZ, 0, calculatedRy, calculatedRz, "InOutQuad")

                            objectState = false
                            objectMoving = true
                        end

                        setTimer(
                            function()
                                objectMoving = false
                            end, moveTime, 1
                        )
                    end
                else
                    return exports["cr_infobox"]:addBox("error", "Nincs beállítva a kapunak zárási pozíció.")
                end
            else
                return exports["cr_infobox"]:addBox("error", "Nincs beállítva a kapunak nyitási pozíció.")
            end
        end
    end
end

function processGateEditor(state)
    if state == "init" then 
        createRender("renderGateEditor", renderGateEditor)

        removeEventHandler("onClientKey", root, onKey)
        addEventHandler("onClientKey", root, onKey)

        exports["cr_dx"]:startFade("gateEditorPanel", 
            {
                ["startTick"] = getTickCount(),
                ["lastUpdateTick"] = getTickCount(),
                ["time"] = 250,
                ["animation"] = "InOutQuad",
                ["from"] = 0,
                ["to"] = 255,
                ["alpha"] = 0,
                ["progress"] = 0,
            }
        )

        local x, y, z = getElementPosition(localPlayer)
        local rx, ry, rz = getElementRotation(localPlayer)

        tempObject = Object(objectDatas["models"][selectedObject], x, y + 1, z - 1, rx, ry, rz)
        tempObject.interior = localPlayer.interior
        tempObject.dimension = localPlayer.dimension

        exports["cr_elementeditor"]:toggleEditor(tempObject, "gateSaveTrigger", "gateRemoveTrigger", true)

        objectFadingInterpolation = getTickCount()
    else
        exports["cr_dx"]:startFade("gateEditorPanel", 
            {
                ["startTick"] = getTickCount(),
                ["lastUpdateTick"] = getTickCount(),
                ["time"] = 250,
                ["animation"] = "InOutQuad",
                ["from"] = 255,
                ["to"] = 0,
                ["alpha"] = 255,
                ["progress"] = 0,
            }
        )

        panelDatas[2][2] = {}
        panelDatas[3][2] = {}

        removeEventHandler("onClientKey", root, onKey)
        objectFadingInterpolation = false

        tempObject:destroy()
        tempObject = nil 

        selectedObject = 1
        objectAlpha = false

        collectgarbage("collect")
    end
end

function createGateCommand(cmd)
    if localPlayer:getData("loggedIn") then 
        if exports["cr_permission"]:hasPermission(localPlayer, cmd) then 
            if not checkRender("renderGateEditor") then 
                processGateEditor("init")
            else 
                processGateEditor("exit")
            end
        end
    end
end
addCommandHandler("creategate", createGateCommand, false, false)

function gateCommand(cmd)
    if localPlayer:getData("loggedIn") then 
        local gateObject = getClosestGate(8)

        if gateObject and isElement(gateObject) then 
            local data = gateObject:getData("object >> data")
            local id = data["id"]

            if id and id > 0 then 
                if exports["cr_inventory"]:hasItem(localPlayer, 20, id) or exports["cr_permission"]:hasPermission(localPlayer, "forceGate") then 
                    local startPosition = data["startPosition"]
                    local endPosition = data["endPosition"]

                    if #startPosition > 0 then 
                        if #endPosition > 0 then 
                            local openX, openY, openZ, openRx, openRy, openRz, openInterior, openDimension = unpack(startPosition)
                            local closeX, closeY, closeZ, closeRx, closeRy, closeRz, closeInterior, closeDimension = unpack(endPosition)

                            local calculatedRz = false 
                            local calculatedRy = false

                            if not data["state"] then 
                                calculatedRz = calculateDifferenceBetweenAngles(openRz, closeRz)
                                calculatedRy = calculateDifferenceBetweenAngles(openRy, closeRy)
                            else 
                                calculatedRz = calculateDifferenceBetweenAngles(closeRz, openRz)
                                calculatedRy = calculateDifferenceBetweenAngles(closeRy, openRy)
                            end

                            triggerServerEvent("gate >> handleGate", localPlayer, gateObject, {
                                ["calculatedRz"] = calculatedRz,
                                ["calculatedRy"] = calculatedRy,
                            })
                        end
                    end
                else
                    local syntax = exports["cr_core"]:getServerSyntax(false, "error")

                    outputChatBox(syntax.."Nincs kulcsod a kapuhoz.", 255, 0, 0, true)
                    return 
                end
            end
        end
    end
end
addCommandHandler("gate", gateCommand, false, false)

local cache = {}

local maxDistance = 15
local deleteHover = false
local keyHover = false

local objectCheckTimer = false

function renderNearbyGates()
    local alpha, progress = exports["cr_dx"]:getFade("nearbyGatesPanel")
    if alpha and progress then 
        if progress >= 1 then 
            if alpha <= 0 then 
                destroyRender("renderNearbyGates")
                removeEventHandler("onClientKey", root, onKey)

                clearObjectCache()
            end
        end
    end

    local serverHex = exports["cr_core"]:getServerColor("blue", true)
    local r, g, b = exports["cr_core"]:getServerColor("red", false)
    local rr, gg, bb = exports["cr_core"]:getServerColor("green", false)
    local white = "#C8C8C8"

    deleteHover = nil 
    keyHover = nil
    for i = 1, #cache do 
        local v = cache[i]

        if v then 
            local element = v["element"]
            local id = v["id"]
            local sourcePlayer = v["sourcePlayer"]
            local createdDate = v["createdDate"]

            if element and isElement(element) then 
                local x, y, z = getElementPosition(element)
                local theX, theY = getScreenFromWorldPosition(x, y, z)
                local distance = getDistanceBetweenPoints3D(element.position, localPlayer.position)

                local size = 1 - (distance / maxDistance)

                if theX and theY then 
                    if size > 0 then 
                        local w, h = 32 * size, 32 * size
                        local inSlot = exports["cr_core"]:isInSlot(theX - w / 2 - 20 * size, theY - h / 2 + 60 * size, w, h)
                        local inSlot2 = exports["cr_core"]:isInSlot(theX - w / 2 + 20 * size, theY - h / 2 + 60 * size, w, h)

                        if inSlot then 
                            deleteHover = id
                        end

                        if inSlot2 then 
                            keyHover = id
                        end
                        
                        shadowedText("ID: "..serverHex..id..white.."\nLerakta: "..serverHex..sourcePlayer:gsub("_", " ")..white.."\nLerakás időpontja: "..serverHex..createdDate, theX, theY, theX, theY, tocolor(200, 200, 200, alpha), size, exports["cr_fonts"]:getFont("RobotoB", 13), "center", "center", false, alpha)
                        shadowedText("", theX - 20 * size, theY + 60 * size, theX - 20 * size, theY + 60 * size, (inSlot and tocolor(r, g, b, alpha) or tocolor(200, 200, 200, alpha)), size, exports["cr_fonts"]:getFont("FontAwesome", 18), "center", "center", false, alpha)
                        shadowedText("", theX + 20 * size, theY + 60 * size, theX + 20 * size, theY + 60 * size, (inSlot2 and tocolor(rr, gg, bb, alpha) or tocolor(200, 200, 200, alpha)), size, exports["cr_fonts"]:getFont("FontAwesome", 18), "center", "center", false, alpha)
                    end
                end
            end
        end
    end
end

function insertNearbyObjectsIntoCache()
    for key, value in pairs(getElementsByType("object", resourceRoot)) do 
        if value:getData("object >> data") and value:getData("object >> data")["startPosition"] then 
            local distance = getDistanceBetweenPoints3D(localPlayer.position, value.position)

            if distance <= maxDistance then 
                local data = value:getData("object >> data")
                local id = data["id"]
                local sourcePlayer = data["createdBy"]
                local createdDate = tonumber(data["createdDate"])

                local realtime = getRealTime(createdDate)
                local formattedTime = ("%i.%.2i.%.2i. %.2i:%.2i:%.2i"):format(realtime["year"] + 1900, realtime["month"] + 1, realtime["monthday"], realtime["hour"], realtime["minute"], realtime["second"])

                table.insert(cache, {
                    ["element"] = value,
                    ["id"] = id,
                    ["sourcePlayer"] = sourcePlayer,
                    ["createdDate"] = formattedTime,
                })
            end
        end
    end

    if isTimer(objectCheckTimer) then 
        killTimer(objectCheckTimer)
        objectCheckTimer = nil 
    end

    objectCheckTimer = setTimer(
        function()
            cache = {}

            for key, value in pairs(getElementsByType("object", resourceRoot)) do 
                if value:getData("object >> data") and value:getData("object >> data")["startPosition"] then 
                    local distance = getDistanceBetweenPoints3D(localPlayer.position, value.position)

                    if distance <= 15 then 
                        local data = value:getData("object >> data")
                        local id = data["id"]
                        local sourcePlayer = data["createdBy"]
                        local createdDate = tonumber(data["createdDate"])

                        local realtime = getRealTime(createdDate)
                        local formattedTime = ("%i.%.2i.%.2i. %.2i:%.2i:%.2i"):format(realtime["year"] + 1900, realtime["month"] + 1, realtime["monthday"], realtime["hour"], realtime["minute"], realtime["second"])

                        table.insert(cache, {
                            ["element"] = value,
                            ["id"] = id,
                            ["sourcePlayer"] = sourcePlayer,
                            ["createdDate"] = formattedTime,
                        })
                    end
                end
            end
        end, 50, 0
    )
end

function clearObjectCache()
    cache = {}

    if isTimer(objectCheckTimer) then 
        killTimer(objectCheckTimer)
        objectCheckTimer = nil
    end

    collectgarbage("collect")
end

function getNearbyGates(cmd)
    if localPlayer:getData("loggedIn") then 
        if exports["cr_permission"]:hasPermission(localPlayer, cmd) then 

            if not checkRender("renderNearbyGates") then 
                local syntax = exports["cr_core"]:getServerSyntax(false, "success")
                outputChatBox(syntax.."Közeledben lévő kapuk mutatása bekapcsolva.", 255, 0, 0, true)
                
                insertNearbyObjectsIntoCache()

                createRender("renderNearbyGates", renderNearbyGates)
                removeEventHandler("onClientKey", root, onKey)
                addEventHandler("onClientKey", root, onKey)

                exports["cr_dx"]:startFade("nearbyGatesPanel", 
                    {
                        ["startTick"] = getTickCount(),
                        ["lastUpdateTick"] = getTickCount(),
                        ["time"] = 250,
                        ["animation"] = "InOutQuad",
                        ["from"] = 0,
                        ["to"] = 255,
                        ["alpha"] = 0,
                        ["progress"] = 0,
                    }
                )
            else 
                local syntax = exports["cr_core"]:getServerSyntax(false, "error")
                outputChatBox(syntax.."Közeledben lévő kapuk mutatása kikapcsolva.", 255, 0, 0, true)

                exports["cr_dx"]:startFade("nearbyGatesPanel", 
                    {
                        ["startTick"] = getTickCount(),
                        ["lastUpdateTick"] = getTickCount(),
                        ["time"] = 250,
                        ["animation"] = "InOutQuad",
                        ["from"] = 255,
                        ["to"] = 0,
                        ["alpha"] = 255,
                        ["progress"] = 0,
                    }
                )
            end
        end
    end
end
addCommandHandler("nearbygates", getNearbyGates, false, false)

function onKey(button, state)
    if button == "mouse1" then 
        if state then 
            if checkRender("renderGateEditor") then 
                if hoverData then 
                    changeHoverData(hoverData)

                    hoverData = nil
                end
            end

            if checkRender("renderNearbyGates") then 
                if deleteHover then 
                    triggerLatentServerEvent("gate >> deleteGate", 5000, false, localPlayer, localPlayer, deleteHover)

                    deleteHover = nil
                end

                if keyHover then 
                    exports["cr_inventory"]:giveItem(localPlayer, 20, keyHover)

                    exports["cr_dx"]:startFade("nearbyGatesPanel", 
                        {
                            ["startTick"] = getTickCount(),
                            ["lastUpdateTick"] = getTickCount(),
                            ["time"] = 250,
                            ["animation"] = "InOutQuad",
                            ["from"] = 255,
                            ["to"] = 0,
                            ["alpha"] = 255,
                            ["progress"] = 0,
                        }
                    )

                    keyHover = nil 
                end
            end
        end
    end
end

addEvent("gateSaveTrigger", true)
addEventHandler("gateSaveTrigger", root,
    function(e, x, y, z, rx, ry, rz, scale)
        local startPosition = panelDatas[2][2]
        local endPosition = panelDatas[3][2]

        if #startPosition > 0 then 
            if #endPosition > 0 then 
                local startX, startY, startZ, startRx, startRy, startRz, startInterior, startDimension = unpack(startPosition)
                local endX, endY, endZ, endRx, endRy, endRz, endInterior, endDimension = unpack(endPosition)

                triggerLatentServerEvent("gate >> createGate", 5000, false, localPlayer, {
                    ["modelId"] = e.model,
                    ["createdBy"] = exports["cr_admin"]:getAdminName(localPlayer):gsub(" ", "_"),
                    ["startPosition"] = toJSON({startX, startY, startZ, startRx, startRy, startRz, startInterior, startDimension}),
                    ["endPosition"] = toJSON({endX, endY, endZ, endRx, endRy, endRz, endInterior, endDimension}),
                })
            else 
                exports["cr_infobox"]:addBox("error", "Nincs beállítva a kapunak zárási pozíció.")
            end
        else
            exports["cr_infobox"]:addBox("error", "Nincs beállítva a kapunak nyitási pozíció.")
        end

        processGateEditor("exit")
    end
)

addEvent("gateRemoveTrigger", true)
addEventHandler("gateRemoveTrigger", root,
    function(e, x, y, z, rx, ry, rz, scale)
        processGateEditor("exit")
    end
)

function shadowedText(text,x,y,w,h,color,fontsize,font,aligX,alignY, ignoreDrawn, alpha)
    dxDrawText(text:gsub("#%x%x%x%x%x%x", ""),x,y+1,w,h+1,tocolor(0,0,0,alpha),fontsize,font,aligX,alignY, false, false, false, false) -- Fent
    dxDrawText(text:gsub("#%x%x%x%x%x%x", ""),x,y-1,w,h-1,tocolor(0,0,0,alpha),fontsize,font,aligX,alignY, false, false, false, false) -- Lent
    dxDrawText(text:gsub("#%x%x%x%x%x%x", ""),x-1,y,w-1,h,tocolor(0,0,0,alpha),fontsize,font,aligX,alignY, false, false, false, false) -- Bal
    dxDrawText(text:gsub("#%x%x%x%x%x%x", ""),x+1,y,w+1,h,tocolor(0,0,0,alpha),fontsize,font,aligX,alignY, false, false, false, false) -- Jobb
    
    dxDrawText(text,x,y,w,h,color,fontsize,font,aligX,alignY, false, false, false, true)
end