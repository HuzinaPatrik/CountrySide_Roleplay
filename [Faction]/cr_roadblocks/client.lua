local screenX, screenY = guiGetScreenSize()
local boxWidth, gBoxHeight = 450, 351

if maxLines >= #roadblocks then 
    maxLines = #roadblocks
end 
_maxLines = maxLines

local selectedRoadblock = 0
local panelHover = false

local lastInteraction = false
local vehicleModel = false
local oldHeadState = false
local isRender = false
local isSelectorRender = false

local cache = {}

function renderRoadblockSelector()
    local alpha, progress = exports["cr_dx"]:getFade("roadBlockPanel")
    if alpha and progress then 
        if progress >= 1 then 
            if alpha <= 0 then 
                vehicleModel = false
                destroyRender("renderRoadblockSelector")

                if not isRender then 
                    removeEventHandler("onClientKey", root, onKey)
                end
            end
        end
    end

    local cursorX, cursorY = false, false

    if isCursorShowing() then 
        cursorX, cursorY = exports.cr_core:getCursorPosition()
    end

    local redR, redG, redB = exports.cr_core:getServerColor("red", false)
    local greenR, greenG, greenB = exports.cr_core:getServerColor("green", false)
    local blueR, blueG, blueB = exports.cr_core:getServerColor("blue", false)

    local font = exports.cr_fonts:getFont("Poppins-SemiBold", 16)
    local font2 = exports.cr_fonts:getFont("Poppins-Medium", 14)
    local font3 = exports.cr_fonts:getFont("Poppins-Medium", 12)
    local font4 = exports.cr_fonts:getFont("Poppins-Medium", 11)

    local panelW, panelH = 295, 358
    local panelX, panelY = screenX / 2 - panelW / 2, screenY / 2 - panelH / 2
    local inSlot = exports.cr_core:isInSlot(panelX, panelY, panelW, panelH)

    panelHover = nil

    if inSlot then 
        panelHover = true
    end

    dxDrawRectangle(panelX, panelY, panelW, panelH, tocolor(51, 51, 51, alpha * 0.8))

    local logoW, logoH = 26, 30
    local logoX, logoY = panelX + 10, panelY + 8

    dxDrawImage(logoX, logoY, logoW, logoH, "files/images/logo.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
    dxDrawText("Útzárak", logoX + logoW + 10, logoY + 4, logoX + logoW, logoY + logoH, tocolor(255, 255, 255, alpha), 1, font, "left", "center")

    local rowW, rowH = panelW - 25, 20
    local rowX, rowY = panelX + (25 / 2), logoY + logoH + 10

    hoverRoadblock = nil
    closeHover = nil

    for i = minLines, maxLines do 
        local inSlot = exports.cr_core:isInSlot(rowX, rowY, rowW, rowH)
        local rowColor = tocolor(51, 51, 51, alpha * 0.6)
        local textColor = tocolor(255, 255, 255, alpha)

        if inSlot then 
            rowColor = tocolor(242, 242, 242, alpha * 0.8)
            textColor = tocolor(51, 51, 51, alpha)
        end

        dxDrawRectangle(rowX, rowY, rowW, rowH, rowColor)

        local v = roadblocks[i]
        if v then 
            local name = v.name
            local imagePath = v.imagePath

            dxDrawText(name, rowX + 5, rowY + 4, rowX + rowW, rowY + rowH, textColor, 1, font3, "left", "center")

            local buttonW, buttonH = 100, rowH - 4
            local buttonX, buttonY = rowX + rowW - buttonW - 5, rowY + 2

            local iconW, iconH = 32, 32
            local iconX, iconY = buttonX - iconW + 3, rowY - 6
            local iconColor = tocolor(255, 255, 255, alpha * 0.6)

            local hoverW, hoverH = 12, 12
            local hoverX, hoverY = rowX + rowW - buttonW - 5 - hoverW - 7, iconY + hoverH - 2
            local inSlot = exports.cr_core:isInSlot(hoverX, hoverY, hoverW, hoverH)
            local iconSlot = inSlot
            
            if inSlot then 
                iconColor = tocolor(blueR, blueG, blueB, alpha)
            end

            dxDrawImage(iconX, iconY, iconW, iconH, "files/images/info.png", 0, 0, 0, iconColor)

            local buttonColor = tocolor(greenR, greenG, greenB, alpha * 0.7)
            local textColor = tocolor(255, 255, 255, alpha * 0.6)
            local inSlot = exports.cr_core:isInSlot(buttonX, buttonY, buttonW, buttonH)

            if inSlot then 
                hoverRoadblock = i

                buttonColor = tocolor(greenR, greenG, greenB, alpha)
                textColor = tocolor(255, 255, 255, alpha)
            end

            dxDrawRectangle(buttonX, buttonY, buttonW, buttonH, buttonColor)
            dxDrawText("Lerak", buttonX, buttonY + 4, buttonX + buttonW, buttonY + buttonH, textColor, 1, font4, "center", "center")

            if iconSlot then 
                if imagePath and cursorX and cursorY then 
                    local imgW, imgH = 64, 64
                    local imgX, imgY = cursorX - imgW / 2, cursorY - imgH - 10

                    dxDrawImage(imgX, imgY, imgW, imgH, imagePath, 0, 0, 0, tocolor(255, 255, 255, alpha))
                end
            end
        end

        rowY = rowY + rowH + 4
    end

    local buttonW, buttonH = 150, 20
    local buttonX, buttonY = panelX + buttonW / 2, panelY + panelH - (buttonH * 2) + 5
    local inSlot = exports.cr_core:isInSlot(buttonX, buttonY, buttonW, buttonH)

    local buttonColor = tocolor(redR, redG, redB, alpha * 0.7)
    local textColor = tocolor(255, 255, 255, alpha * 0.6)

    if inSlot then 
        buttonColor = tocolor(redR, redG, redB, alpha)
        textColor = tocolor(255, 255, 255, alpha)

        closeHover = true
    end

    dxDrawRectangle(buttonX, buttonY, buttonW, buttonH, buttonColor)
    dxDrawText("Bezár", buttonX, buttonY + 4, buttonX + buttonW, buttonY + buttonH, textColor, 1, font2, "center", "center")

    local scrollW, scrollH = 3, ((rowH + 4) * _maxLines) - 4
    local scrollX, scrollY = panelX + panelW - scrollW - 5, logoY + logoH + 10

    scrollBarHover = exports.cr_core:isInSlot(scrollX, scrollY, scrollW, scrollH)

    -- Scrollbar

    dxDrawRectangle(scrollX, scrollY, scrollW, scrollH, tocolor(242, 242, 242, alpha * 0.6))

    local percent = #roadblocks

    if percent >= 1 then
        local gW, gH = 3, scrollH
        local gX, gY = scrollX, scrollY

        scrollingHover = exports.cr_core:isInSlot(gX, gY, gW, gH)

        if scrolling then
            if isCursorShowing() then
                if getKeyState("mouse1") then
                    local cx, cy = exports.cr_core:getCursorPosition()
                    local cy = math.min(math.max(cy, gY), gY + gH)
                    local y = (cy - gY) / (gH)
                    local num = percent * y

                    minLines = math.max(1, math.floor(math.min(math.max(num, 1), (percent - _maxLines) + 1)))
                    maxLines = minLines + (_maxLines - 1)
                end
            else
                scrolling = false
            end
        end

        local multiplier = math.min(math.max((maxLines - (minLines - 1)) / percent, 0), 1)
        local multiplier2 = math.min(math.max((minLines - 1) / percent, 0), 1)
        local gY = gY + ((gH) * multiplier2)
        local gH = gH * multiplier

        local r, g, b = 255, 59, 59
        dxDrawRectangle(gX, gY, gW, gH, tocolor(r, g, b, alpha))
    end
end

function roadBlockCommand(cmd)
    if localPlayer:getData("loggedIn") then 
        if exports["cr_faction_scripts"]:hasPlayerPermission(localPlayer, cmd) then 
            local vehicle, model = getVehicleInRange(localPlayer, 5)

            if not checkRender("renderRoadblockSelector") then 
                if isElement(vehicle) and model then 
                    vehicleModel = model
                    lastInteraction = false
                    isSelectorRender = true

                    createRender("renderRoadblockSelector", renderRoadblockSelector)
                    removeEventHandler("onClientKey", root, onKey)
                    addEventHandler("onClientKey", root, onKey)

                    exports["cr_dx"]:startFade("roadBlockPanel", 
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
                end
            else 
                if not lastInteraction then
                    lastInteraction = true
                    isSelectorRender = false

                    exports["cr_dx"]:startFade("roadBlockPanel", 
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
end
addCommandHandler("rbs", roadBlockCommand, false, false)

function processRoadblockEditor()
    local x, y, z = getElementPosition(localPlayer)
    local rx, ry, rz = getElementRotation(localPlayer)

    tempObject = Object(roadblocks[selectedRoadblock]["objectId"], x, y, z, rx, ry, rz)
    tempObject:setFrozen(true)
    tempObject:setCollisionsEnabled(false)
    tempObject:setData("roadblockParent", localPlayer)

    exports.cr_head:initHeadMove(true)
    exports["cr_elementeditor"]:toggleEditor(tempObject, "roadblockSaveTrigger", "roadblockRemoveTrigger", true)

    exports["cr_dx"]:startFade("roadBlockPanel", 
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

local maxDistance = 15
local deleteHover = false
local moveHover = false

local objectCheckTimer = false

function renderNearbyRoadblocks()
    local alpha, progress = exports["cr_dx"]:getFade("nearbyRoadblocksPanel")
    if alpha and progress then 
        if progress >= 1 then 
            if alpha <= 0 then 
                destroyRender("renderNearbyRoadblocks")

                if not isSelectorRender then 
                    removeEventHandler("onClientKey", root, onKey)
                end

                clearObjectCache()
            end
        end
    end

    local serverHex = exports["cr_core"]:getServerColor("yellow", true)
    local r, g, b = exports["cr_core"]:getServerColor("red", false)
    local rr, gg, bb = exports["cr_core"]:getServerColor("green", false)

    local font = exports.cr_fonts:getFont("Poppins-Medium", 20)
    local font2 = exports.cr_fonts:getFont("FontAwesome", 16)

    deleteHover = nil 
    moveHover = nil
    for key = 1, #cache do 
        local value = cache[key]

        if value then 
            local element = value["element"]
            local id = value["id"]
            local sourcePlayer = value["sourcePlayer"]
            local createdDate = value["createdDate"]

            if element and isElement(element) then 
                local x, y, z = getElementPosition(element)
                local theX, theY = getScreenFromWorldPosition(x, y, z)
                local distance = getDistanceBetweenPoints3D(element.position, localPlayer.position)

                local size = 1 - (distance / maxDistance)

                if theX and theY then 
                    if size > 0 then 
                        local w, h = 32 * size, 32 * size
                        local inSlot = exports["cr_core"]:isInSlot(theX - w / 2 - 20 * size, theY - h / 2 + 80 * size, w, h)
                        local inSlot2 = exports["cr_core"]:isInSlot(theX - w / 2 + 20 * size, theY - h / 2 + 80 * size, w, h)

                        if inSlot then 
                            deleteHover = id
                        end

                        if inSlot2 then 
                            moveHover = element
                        end
                        
                        dxDrawText("ID: "..id.."\nLerakta: "..sourcePlayer:gsub("_", " ").."\nLerakás időpontja: "..createdDate, theX + 1, theY, theX, theY, tocolor(0, 0, 0, alpha), size, font, "center", "center")
                        dxDrawText("ID: "..serverHex..id..white.."\nLerakta: "..serverHex..sourcePlayer:gsub("_", " ")..white.."\nLerakás időpontja: "..serverHex..createdDate, theX, theY, theX, theY, tocolor(255, 255, 255, alpha), size, font, "center", "center", false, false, false, true)
                        
                        dxDrawText("", theX - 19 * size, theY + 80 * size, theX - 20 * size, theY + 80 * size, tocolor(0, 0, 0, alpha), size, font2, "center", "center")
                        dxDrawText("", theX - 20 * size, theY + 80 * size, theX - 20 * size, theY + 80 * size, (inSlot and tocolor(r, g, b, alpha) or tocolor(255, 255, 255, alpha)), size, font2, "center", "center")
                        
                        dxDrawText("", theX + 19 * size, theY + 80 * size, theX + 20 * size, theY + 80 * size, tocolor(0, 0, 0, alpha), size, font2, "center", "center")
                        dxDrawText("", theX + 20 * size, theY + 80 * size, theX + 20 * size, theY + 80 * size, (inSlot2 and tocolor(rr, gg, bb, alpha) or tocolor(255, 255, 255, alpha)), size, font2, "center", "center")
                    end
                end
            end
        end
    end
end

function insertNearbyObjectsIntoCache()
    for key, value in pairs(getElementsByType("object", resourceRoot)) do 
        if value:getData("roadblock >> id") then 
            local distance = getDistanceBetweenPoints3D(localPlayer.position, value.position)

            if distance <= 15 then 
                local id = value:getData("roadblock >> id")
                local sourcePlayer = value:getData("roadblock >> sourcePlayer")
                local createdDate = tonumber(value:getData("roadblock >> createdDate"))
                local realtime = getRealTime(tonumber(createdDate))
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
                if value:getData("roadblock >> id") then 
                    local distance = getDistanceBetweenPoints3D(localPlayer.position, value.position)

                    if distance <= 15 then 
                        local id = value:getData("roadblock >> id")
                        local sourcePlayer = value:getData("roadblock >> sourcePlayer")
                        local createdDate = tonumber(value:getData("roadblock >> createdDate"))
                        local realtime = getRealTime(tonumber(createdDate))
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

function nearbyRoadblocks(cmd)
    if localPlayer:getData("loggedIn") then 
        if exports["cr_faction_scripts"]:hasPlayerPermission(localPlayer, cmd) then 

            if not checkRender("renderNearbyRoadblocks") then 
                local syntax = exports["cr_core"]:getServerSyntax("Roadblock", "success")
                outputChatBox(syntax.."Közeledben lévő útzárak mutatása bekapcsolva.", 255, 0, 0, true)
                
                isRender = true
                insertNearbyObjectsIntoCache()

                createRender("renderNearbyRoadblocks", renderNearbyRoadblocks)
                removeEventHandler("onClientKey", root, onKey)
                addEventHandler("onClientKey", root, onKey)

                exports["cr_dx"]:startFade("nearbyRoadblocksPanel", 
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
                local syntax = exports["cr_core"]:getServerSyntax("Roadblock", "error")
                outputChatBox(syntax.."Közeledben lévő útzárak mutatása kikapcsolva.", 255, 0, 0, true)

                exports["cr_dx"]:startFade("nearbyRoadblocksPanel", 
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

                isRender = false
            end
        end
    end
end
addCommandHandler("nearbyrbs", nearbyRoadblocks, false, false)

function onKey(button, state)
    if checkRender("renderRoadblockSelector") then 
        if button == "mouse1" then 
            if state then 
                if scrollingHover then 
                    if not scrolling then 
                        scrolling = true 
                    end
                end

                if hoverRoadblock and not lastInteraction then 
                    local data = roadblocks[hoverRoadblock]

                    if data.restricted and vehicleModel ~= 552 then 
                        local syntax = exports.cr_core:getServerSyntax("Roadblock", "error")
                        local hexColor = exports.cr_core:getServerColor("yellow", true)

                        outputChatBox(syntax .. "Ezt az útzárat csak " .. hexColor .. "Utility Van" .. white .. " segítségével rakhatod le.", 255, 0, 0, true)
                        return
                    end

                    if selectedRoadblock ~= hoverRoadblock then 
                        selectedRoadblock = hoverRoadblock 

                        processRoadblockEditor()

                        lastInteraction = true
                        hoverRoadblock = nil
                    end
                end

                if closeHover and not lastInteraction then 
                    lastInteraction = true

                    exports["cr_dx"]:startFade("roadBlockPanel", 
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

                    closeHover = nil 
                end
            else 
                if scrolling then 
                    scrolling = false
                end
            end
        elseif button == "mouse_wheel_down" then 
            if state then 
                if panelHover then 
                    scrollDown()
                end
            end
        elseif button == "mouse_wheel_up" then 
            if state then 
                if panelHover then 
                    scrollUP()
                end
            end
        end
    end

    if isRender then 
        if button == "mouse1" then 
            if state then 
                if deleteHover then 
                    local key = getTableKey(cache, deleteHover)

                    if key then 
                        table.remove(cache, key)
                    end

                    if #cache == 0 then 
                        exports["cr_dx"]:startFade("nearbyRoadblocksPanel", 
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

                    triggerLatentServerEvent("roadblocks.destroyRoadblock", 5000, false, localPlayer, localPlayer, deleteHover)

                    deleteHover = nil 
                end

                if moveHover then 
                    if getDistanceBetweenPoints3D(moveHover.position, localPlayer.position) > 3 then 
                        local syntax = exports["cr_core"]:getServerSyntax("Roadblock", "error")
                        return outputChatBox(syntax.."Túl messze vagy.", 255, 0, 0, true)
                    end

                    exports.cr_head:initHeadMove(true)
                    exports["cr_elementeditor"]:toggleEditor(moveHover, "roadblockEditSaveTrigger", "roadblockEditRemoveTrigger", true)

                    moveHover.collisions = false
                    moveHover:setData("roadblockParent", localPlayer)

                    exports["cr_dx"]:startFade("nearbyRoadblocksPanel", 
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

                    moveHover = nil 
                end
            end
        end
    end
end

-- function deleteRoadblock(cmd, id)
--     if localPlayer:getData("loggedIn") then 
--         if exports["cr_faction_scripts"]:hasPlayerPermission(localPlayer, cmd) then 
--             if not id then 
--                 local syntax = exports["cr_core"]:getServerSyntax("Roadblock", "lightyellow")
--                 return outputChatBox(syntax.."/"..cmd.." [id]", 255, 0, 0, true)
--             else 
--                 local id = tonumber(id)

--                 if id ~= nil then 
--                     if id > 0 then 
--                         local roadblock = findObject(id)

--                         if roadblock and isElement(roadblock) then 
--                             triggerLatentServerEvent("roadblocks.destroyRoadblock", 5000, false, localPlayer, localPlayer, id)
--                         else 
--                             local syntax = exports["cr_core"]:getServerSyntax("Roadblock", "red")
--                             return outputChatBox(syntax.."Nem található roadblock ezzel az id-vel.", 255, 0, 0, true)
--                         end
--                     else 
--                         local syntax = exports["cr_core"]:getServerSyntax("Roadblock", "red")
--                         return outputChatBox(syntax.."Az id-nek nagyobbnak kell lennie mint 0.", 255, 0, 0, true)
--                     end
--                 else 
--                     local syntax = exports["cr_core"]:getServerSyntax("Roadblock", "red")
--                     return outputChatBox(syntax.."Csak szám.", 255, 0, 0, true)
--                 end
--             end
--         end
--     end
-- end
-- addCommandHandler("delrb", deleteRoadblock, false, false)

-- function editRoadblock(cmd, id)
--     if localPlayer:getData("loggedIn") then 
--         if exports["cr_faction_scripts"]:hasPlayerPermission(localPlayer, cmd) then 
--             if not id then 
--                 local syntax = exports["cr_core"]:getServerSyntax("Roadblock", "lightyellow")
--                 return outputChatBox(syntax.."/"..cmd.." [id]", 255, 0, 0, true)
--             else 
--                 local id = tonumber(id)

--                 if id ~= nil then 
--                     if id > 0 then 
--                         local roadblock = findObject(id)

--                         if roadblock and isElement(roadblock) then 
--                             local distance = getDistanceBetweenPoints3D(localPlayer.position, roadblock.position)

--                             if distance <= 3 then 
--                                 exports["cr_elementeditor"]:toggleEditor(roadblock, "roadblockEditSaveTrigger", "roadblockEditRemoveTrigger", true)

--                                 roadblock:setData("roadblockParent", localPlayer)
--                             else 
--                                 local syntax = exports["cr_core"]:getServerSyntax("Roadblock", "red")
--                                 return outputChatBox(syntax.."Túl messze vagy.", 255, 0, 0, true)
--                             end
--                         else 
--                             local syntax = exports["cr_core"]:getServerSyntax("Roadblock", "red")
--                             return outputChatBox(syntax.."Nem található roadblock ezzel az id-vel.", 255, 0, 0, true)
--                         end
--                     else 
--                         local syntax = exports["cr_core"]:getServerSyntax("Roadblock", "red")
--                         return outputChatBox(syntax.."Az id-nek nagyobbnak kell lennie mint 0.", 255, 0, 0, true)
--                     end
--                 else 
--                     local syntax = exports["cr_core"]:getServerSyntax("Roadblock", "red")
--                     return outputChatBox(syntax.."Csak szám.", 255, 0, 0, true)
--                 end
--             end
--         end
--     end
-- end
-- addCommandHandler("editrb", editRoadblock, false, false)

function deleteAllRoadblock(cmd)
    if localPlayer:getData("loggedIn") then 
        if exports["cr_faction_scripts"]:hasPlayerPermission(localPlayer, cmd, true) then 
            triggerLatentServerEvent("roadblocks.destroyAllRoadblock", 5000, false, localPlayer, localPlayer)
        end
    end
end
addCommandHandler("delallrb", deleteAllRoadblock, false, false)

addEvent("roadblockSaveTrigger", true)
addEventHandler("roadblockSaveTrigger", root,
    function(element, x, y, z, rx, ry, rz, scale)
        if element:getData("roadblockParent") == localPlayer then 
            local posX, posY, posZ = getElementPosition(tempObject)
            local rotX, rotY, rotZ = getElementRotation(tempObject)
            local model = tempObject.model 
            local interior = tempObject.interior 
            local dimension = tempObject.dimension 

            triggerLatentServerEvent("roadblocks.createNewRoadblock", 5000, false, localPlayer, localPlayer, {
                ["modelId"] = model,
                ["position"] = {posX, posY, posZ, rotX, rotY, rotZ},
                ["interior"] = interior,
                ["dimension"] = dimension,
                ["sourcePlayer"] = exports["cr_admin"]:getAdminName(localPlayer):gsub(" ", "_"),
            })

            tempObject:setData("roadblockParent", nil)
            tempObject:destroy()
            tempObject = nil
            selectedRoadblock = false
            exports.cr_head:initHeadMove(false)

            collectgarbage("collect")
        end
    end
)

addEvent("roadblockRemoveTrigger", true)
addEventHandler("roadblockRemoveTrigger", root,
    function(element, x, y, z, rx, ry, rz, scale)
        if element:getData("roadblockParent") == localPlayer then 
            element:setData("roadblockParent", nil)
            element:destroy()
            selectedRoadblock = false
            exports.cr_head:initHeadMove(false)

            collectgarbage("collect")
        end
    end
)

addEvent("roadblockEditSaveTrigger", true)
addEventHandler("roadblockEditSaveTrigger", root,
    function(element, x, y, z, rx, ry, rz, scale)
        if element:getData("roadblockParent") == localPlayer then 
            local posX, posY, posZ = getElementPosition(element)
            local rotX, rotY, rotZ = getElementRotation(element)
            local interior = element.interior 
            local dimension = element.dimension 
            local id = tonumber(element:getData("roadblock >> id") or 0)

            triggerLatentServerEvent("roadblocks.updateRoadblock", 5000, false, localPlayer, localPlayer, {
                ["id"] = id,
                ["modelId"] = model,
                ["element"] = element,
                ["position"] = {posX, posY, posZ, rotX, rotY, rotZ},
                ["interior"] = interior,
                ["dimension"] = dimension,
            })

            element.collisions = true
            element:setData("roadblockParent", nil)
            exports.cr_head:initHeadMove(false)
            collectgarbage("collect")
        end
    end
)

addEvent("roadblockEditRemoveTrigger", true)
addEventHandler("roadblockEditRemoveTrigger", root,
    function(element, x, y, z, rx, ry, rz, scale)
        if element:getData("roadblockParent") == localPlayer then 
            element:setData("roadblockParent", nil)
            element.collisions = true
            exports.cr_head:initHeadMove(false)
            collectgarbage("collect")
        end
    end
)

function scrollDown()
    if maxLines + 1 <= #roadblocks then
        minLines = minLines + 1
        maxLines = maxLines + 1

        playSound(":cr_scoreboard/files/wheel.wav")
    end
end

function scrollUP()
    if minLines - 1 >= 1 then
        minLines = minLines - 1
        maxLines = maxLines - 1

        playSound(":cr_scoreboard/files/wheel.wav")
    end
end

function shadowedText(text,x,y,w,h,color,fontsize,font,aligX,alignY, ignoreDrawn, alpha)
    dxDrawText(text:gsub("#%x%x%x%x%x%x", ""),x,y+1,w,h+1,tocolor(0,0,0,alpha),fontsize,font,aligX,alignY, false, false, false, false) -- Fent
    dxDrawText(text:gsub("#%x%x%x%x%x%x", ""),x,y-1,w,h-1,tocolor(0,0,0,alpha),fontsize,font,aligX,alignY, false, false, false, false) -- Lent
    dxDrawText(text:gsub("#%x%x%x%x%x%x", ""),x-1,y,w-1,h,tocolor(0,0,0,alpha),fontsize,font,aligX,alignY, false, false, false, false) -- Bal
    dxDrawText(text:gsub("#%x%x%x%x%x%x", ""),x+1,y,w+1,h,tocolor(0,0,0,alpha),fontsize,font,aligX,alignY, false, false, false, false) -- Jobb
    
    dxDrawText(text,x,y,w,h,color,fontsize,font,aligX,alignY, false, false, false, true)
end