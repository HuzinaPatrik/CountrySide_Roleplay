local sx, sy = guiGetScreenSize()
local alpha = 0

local hoverCategory = false
local hoverType = false
local hoverSlot = false
local hoverClothSlot = false
local hoverButton = false

local closeHover = false
local boxHover = false
local slotToBuy = false
local selectedSlot = false

local panelType = 1

local cache = {}
local slotCache = {}
local attachmentsInUse = {}

local oldFactions = {}
local currentFactions = {}
local editingCloth = false
local factionCheckTimer = false

local firstLoad = false

function onClientStart()
    setTimer(triggerServerEvent, 2000, 1, "attachments.loadAttachments", localPlayer)
    setTimer(triggerServerEvent, 2000, 1, "attachments.loadUsingAttachments", localPlayer, localPlayer)

    if isTimer(factionCheckTimer) then 
        killTimer(factionCheckTimer)
        factionCheckTimer = nil
    end

    factionCheckTimer = setTimer(
        function()
            local resource = getResourceFromName("cr_dashboard")

            if resource and getResourceState(resource) == "running" then 
                oldFactions = currentFactions
                currentFactions = exports.cr_dashboard:getPlayerFactions(localPlayer)

                if #oldFactions ~= #currentFactions and firstLoad then 
                    triggerServerEvent("attachments.checkFactionAttachments", localPlayer)
                end
            end
        end, 1000, 0
    )

    -- tesztnek

    -- local txd = engineLoadTXD("files/parrot1.txd")
    -- engineImportTXD(txd, 7510)

    -- local dff = engineLoadDFF("files/parrot1.dff")
    -- engineReplaceModel(dff, 7510)
    
    -- local txd = engineLoadTXD("files/hut.txd")
    -- engineImportTXD(txd, 4329)

    -- local dff = engineLoadDFF("files/hut.dff")
    -- engineReplaceModel(dff, 4329)

    -- local txd = engineLoadTXD("files/Nyaklanc_1.txd")
    -- engineImportTXD(txd, 3389)

    -- local dff = engineLoadDFF("files/Nyaklanc_1.dff")
    -- engineReplaceModel(dff, 3389)

    -- local txd = engineLoadTXD("files/edison_szakall.txd")
    -- engineImportTXD(txd, 3387)

    -- local dff = engineLoadDFF("files/edison_szakall.dff")
    -- engineReplaceModel(dff, 3387)

    -- local dff = engineLoadDFF("files/GlassesType1.dff")
    -- engineReplaceModel(dff, 16644)
end
addEventHandler("onClientResourceStart", resourceRoot, onClientStart)

function RGBToHex(red, green, blue, alpha)
	
	-- Make sure RGB values passed to this function are correct
	if( ( red < 0 or red > 255 or green < 0 or green > 255 or blue < 0 or blue > 255 ) or ( alpha and ( alpha < 0 or alpha > 255 ) ) ) then
		return nil
	end

	-- Alpha check
	if alpha then
		return string.format("#%.2X%.2X%.2X%.2X", red, green, blue, alpha)
	else
		return string.format("#%.2X%.2X%.2X", red, green, blue)
	end

end

function renderClothesShop()
    local alpha, progress = exports["cr_dx"]:getFade("clothesShopPanel")
    if not start then
        if progress >= 1 then 
            destroyRender("renderClothesShop")

            panelType = 1
            hoverClothSlot = nil
            hoverButton = nil

            for k, v in pairs(clothes) do 
                v[2] = false
            end

            return
        end
    end

    local font = exports['cr_fonts']:getFont('Poppins-SemiBold', 16)
    local font2 = exports['cr_fonts']:getFont('Poppins-Medium', 14)
    local font3 = exports['cr_fonts']:getFont('Poppins-Medium', 10)
    local font4 = exports['cr_fonts']:getFont('Poppins-Medium', 12)

    local w, h = 330, panelType == 3 and 200 or 290
    local x, y = sx/2 - w/2, sy/2 - h/2

    dxDrawRectangle(x, y, w, h, tocolor(51, 51, 51, alpha * 0.8))
    boxHover = exports['cr_core']:isInSlot(x,y,w,h)
	dxDrawImage(x + 10, y + 5, 25, 25, ":cr_account/files/logo-white.png", 0, 0, 0, tocolor(255, 255, 255, alpha))

	dxDrawText(panelType == 1 and 'Ruházati Bolt' or panelType == 3 and 'Kiegészítőim' or "Kinézet", x + 10 + 25 + 10,y+5,x+w,y+5+25 + 4,tocolor(242, 242, 242, alpha),1,font,"left","center")

    closeHover = nil
	if exports['cr_core']:isInSlot(x + w - 10 - 15, y + 10, 15, 15) then 
		closeHover = true 

        dxDrawImage(x + w - 10 - 15, y + 10, 15, 15, ":cr_inventory/assets/images/close.png", 0, 0, 0, tocolor(255, 59, 59, alpha))
    else 
        dxDrawImage(x + w - 10 - 15, y + 10, 15, 15, ":cr_inventory/assets/images/close.png", 0, 0, 0, tocolor(255, 59, 59, alpha * 0.6))
    end 

    positions = {
        {x + 15, y + 50, 300, 20},
        {x + 15, y + 50 + (20 + 3), 300, 20},
        {x + 15, y + 50 + ((20 + 3)*2), 300, 20},
        {x + 15, y + 50 + ((20 + 3)*3), 300, 20},
        {x + 15, y + 50 + ((20 + 3)*4), 300, 20},
        {x + 15, y + 50 + ((20 + 3)*5), 300, 20},
        {x + 15, y + 50 + ((20 + 3)*6), 300, 20},
        {x + 15, y + 50 + ((20 + 3)*7), 300, 20},
        {x + 15, y + 50 + ((20 + 3)*8), 300, 20},
        {x + 15, y + 50 + ((20 + 3)*9), 300, 20},
    }

    listedHover = nil
    buyHover = nil
    viewHover = nil
    pickupHover = nil 
    moveHover = nil
    local index, num = 1, 1
    
    if panelType == 1 then 
        if getDistanceBetweenPoints3D(gPed.position, localPlayer.position) > 3 then 
            processClothesShop("exit")
        end 

        for k, v in pairs(clothes) do
            local category, listed, items = unpack(v)

            if index >= minLines and index <= maxLines then
                local x, y, w, h = unpack(positions[num])

                local tWidth = dxGetTextWidth(category, 1, font2)

                if exports['cr_core']:isInSlot(x,y,w,h) then
                    dxDrawRectangle(x, y, w, h, tocolor(242, 242, 242, alpha * 0.4))
                    dxDrawText(category, x + 10, y, x + w, y + h + 4, tocolor(242,242,242,alpha * 0.9), 1, font2, "left", "center")

                    if exports['cr_core']:isInSlot(x + 10 + tWidth + 10, y + h/2 - 8/2, 14, 8) then 
                        listedHover = k 

                        dxDrawImage(x + 10 + tWidth + 10, y + h/2 - 8/2, 14, 8, ":cr_payday/assets/images/icon.png", listed and 180 or 0, 0, 0, tocolor(255, 59, 59, alpha))
                    else 
                        dxDrawImage(x + 10 + tWidth + 10, y + h/2 - 8/2, 14, 8, ":cr_payday/assets/images/icon.png", listed and 180 or 0, 0, 0, tocolor(255, 59, 59, alpha * 0.6))
                    end 
                else
                    dxDrawRectangle(x, y, w, h, tocolor(242, 242, 242, alpha * 0.2))
                    dxDrawText(category, x + 10, y, x + w, y + h + 4, tocolor(242,242,242,alpha * 0.6), 1, font2, "left", "center")
                    dxDrawImage(x + 10 + tWidth + 10, y + h/2 - 8/2, 14, 8, ":cr_payday/assets/images/icon.png", listed and 180 or 0, 0, 0, tocolor(255, 59, 59, alpha * 0.2))
                end

                num = num + 1
            end

            if listed then
                for k2,v2 in pairs(items) do
                    local name = v2["name"]
                    local price = v2["price"]
                    local availableForFactions = v2["availableForFactions"]
                    local invisible = v2["invisible"]

                    if not availableForFactions or isPlayerEligible(localPlayer, availableForFactions) and not invisible then 
                        index = index + 1

                        if index >= minLines and index <= maxLines then
                            local x, y, w, h = unpack(positions[num])

                            if exports['cr_core']:isInSlot(x,y,w,h) then
                                dxDrawRectangle(x, y, w, h, tocolor(51, 51, 51, alpha * 0.9))
                                dxDrawText(name, x + 5, y, x + w, y + h + 4, tocolor(242,242,242,alpha * 0.9), 1, font2, "left", "center")

                                local x = x + w - 5 - 18
                                if exports['cr_core']:isInSlot(x, y + h/2 - 14/2, 18, 14) then 
                                    buyHover = {k, k2}
                                    dxDrawImage(x, y + h/2 - 14/2, 18, 14, "files/images/cloth.png", 0, 0, 0, tocolor(255, 59, 59, alpha))

                                    local tWidth = dxGetTextWidth('Megvétel ($' .. price .. ")", 1, font3)
                                    dxDrawText('Megvétel ($' .. price .. ")", x - tWidth - 5, y, x + w, y + h + 4, tocolor(255, 59, 59, alpha), 1, font3, "left", "center")

                                    x = x - 18 - 5 - tWidth - 5
                                else 
                                    dxDrawImage(x, y + h/2 - 14/2, 18, 14, "files/images/cloth.png", 0, 0, 0, tocolor(242, 242, 242, alpha * 0.6))

                                    x = x - 18 - 5
                                end 

                                if exports['cr_core']:isInSlot(x, y + h/2 - 12/2, 15, 12) then 
                                    viewHover = {k, k2}
                                    dxDrawImage(x, y + h/2 - 12/2, 15, 12, "files/images/view.png", 0, 0, 0, tocolor(255, 59, 59, alpha)) 

                                    local tWidth = dxGetTextWidth('Megtekintés', 1, font3)
                                    dxDrawText('Megtekintés', x - tWidth - 5, y, x + w, y + h + 4, tocolor(255, 59, 59, alpha), 1, font3, "left", "center")
                                else
                                    dxDrawImage(x, y + h/2 - 12/2, 15, 12, "files/images/view.png", 0, 0, 0, tocolor(242, 242, 242, alpha * 0.6)) 
                                end 
                            else
                                dxDrawRectangle(x, y, w, h, tocolor(51, 51, 51, alpha * 0.6))
                                dxDrawText(name, x + 5, y, x + w, y + h + 4, tocolor(242,242,242,alpha * 0.6), 1, font2, "left", "center")

                                local x = x + w - 5 - 18
                                dxDrawImage(x, y + h/2 - 14/2, 18, 14, "files/images/cloth.png", 0, 0, 0, tocolor(242, 242, 242, alpha * 0.2))

                                x = x - 18 - 5
                                dxDrawImage(x, y + h/2 - 12/2, 15, 12, "files/images/view.png", 0, 0, 0, tocolor(242, 242, 242, alpha * 0.2))
                            end

                            num = num + 1
                        end
                    end
                end
            end
            index = index + 1
        end

        if num <= 10 then
            for i = num, 10 do
                local x, y, w, h = unpack(positions[i])
                if exports['cr_core']:isInSlot(x,y,w,h) then
                    dxDrawRectangle(x, y, w, h, tocolor(51, 51, 51, alpha * 0.9))
                else
                    dxDrawRectangle(x, y, w, h, tocolor(51, 51, 51, alpha * 0.6))
                end
            end
        end
    elseif panelType == 2 then 
        for k, v in pairs(clothes) do
            local category, listed, items = unpack(v)

            if index >= minLines and index <= maxLines then
                local x, y, w, h = unpack(positions[num])

                local tWidth = dxGetTextWidth(category, 1, font2)

                if exports['cr_core']:isInSlot(x,y,w,h) then
                    dxDrawRectangle(x, y, w, h, tocolor(242, 242, 242, alpha * 0.4))
                    dxDrawText(category, x + 10, y, x + w, y + h + 4, tocolor(242,242,242,alpha * 0.9), 1, font2, "left", "center")

                    if exports['cr_core']:isInSlot(x + 10 + tWidth + 10, y + h/2 - 8/2, 14, 8) then 
                        listedHover = k 

                        dxDrawImage(x + 10 + tWidth + 10, y + h/2 - 8/2, 14, 8, ":cr_payday/assets/images/icon.png", listed and 180 or 0, 0, 0, tocolor(255, 59, 59, alpha))
                    else 
                        dxDrawImage(x + 10 + tWidth + 10, y + h/2 - 8/2, 14, 8, ":cr_payday/assets/images/icon.png", listed and 180 or 0, 0, 0, tocolor(255, 59, 59, alpha * 0.6))
                    end 
                else
                    dxDrawRectangle(x, y, w, h, tocolor(242, 242, 242, alpha * 0.2))
                    dxDrawText(category, x + 10, y, x + w, y + h + 4, tocolor(242,242,242,alpha * 0.6), 1, font2, "left", "center")
                    dxDrawImage(x + 10 + tWidth + 10, y + h/2 - 8/2, 14, 8, ":cr_payday/assets/images/icon.png", listed and 180 or 0, 0, 0, tocolor(255, 59, 59, alpha * 0.2))
                end

                num = num + 1
            end

            if listed then
                if cache[k] then 
                    for k2,v2 in pairs(cache[k]) do
                        local name = v2["name"]
                        local price = v2["price"]
                        local objectId = v2["objectId"]

                        index = index + 1

                        if index >= minLines and index <= maxLines then
                            local x, y, w, h = unpack(positions[num])

                            if exports['cr_core']:isInSlot(x,y,w,h) then
                                dxDrawRectangle(x, y, w, h, tocolor(51, 51, 51, alpha * 0.9))
                                dxDrawText(name, x + 5, y, x + w, y + h + 4, tocolor(242,242,242,alpha * 0.9), 1, font2, "left", "center")

                                local x = x + w - 5 - 18
                                if exports['cr_core']:isInSlot(x, y + h/2 - 14/2, 18, 14) then 
                                    pickupHover = {k, k2}
                                    dxDrawImage(x, y + h/2 - 14/2, 18, 14, "files/images/cloth.png", 0, 0, 0, tocolor(255, 59, 59, alpha))

                                    local tWidth = dxGetTextWidth((attachmentsInUse[objectId] and "Levétel" or "Felvétel"), 1, font3)
                                    dxDrawText((attachmentsInUse[objectId] and "Levétel" or "Felvétel"), x - tWidth - 5, y, x + w, y + h + 4, tocolor(255, 59, 59, alpha), 1, font3, "left", "center")

                                    x = x - 18 - 5 - tWidth - 5
                                else 
                                    dxDrawImage(x, y + h/2 - 14/2, 18, 14, "files/images/cloth.png", 0, 0, 0, tocolor(242, 242, 242, alpha * 0.6))

                                    x = x - 18 - 5
                                end 

                                if exports['cr_core']:isInSlot(x, y + h/2 - 12/2, 15, 12) then 
                                    viewHover = {k, k2}
                                    dxDrawImage(x, y + h/2 - 12/2, 15, 12, "files/images/view.png", 0, 0, 0, tocolor(255, 59, 59, alpha)) 

                                    local tWidth = dxGetTextWidth('Megtekintés', 1, font3)
                                    dxDrawText('Megtekintés', x - tWidth - 5, y, x + w, y + h + 4, tocolor(255, 59, 59, alpha), 1, font3, "left", "center")

                                    x = x - 15 - 5 - tWidth - 5
                                else
                                    dxDrawImage(x, y + h/2 - 12/2, 15, 12, "files/images/view.png", 0, 0, 0, tocolor(242, 242, 242, alpha * 0.6)) 

                                    x = x - 15 - 5
                                end 

                                if exports['cr_core']:isInSlot(x, y + h/2 - 14/2, 14, 14) then 
                                    moveHover = {k, k2}
                                    dxDrawImage(x, y + h/2 - 14/2, 14, 14, "files/images/move.png", 0, 0, 0, tocolor(255, 59, 59, alpha)) 

                                    local tWidth = dxGetTextWidth('Mozgatás', 1, font3)
                                    dxDrawText('Mozgatás', x - tWidth - 5, y, x + w, y + h + 4, tocolor(255, 59, 59, alpha), 1, font3, "left", "center")
                                else 
                                    dxDrawImage(x, y + h/2 - 14/2, 14, 14, "files/images/move.png", 0, 0, 0, tocolor(242, 242, 242, alpha * 0.6)) 
                                end 
                            else
                                dxDrawRectangle(x, y, w, h, tocolor(51, 51, 51, alpha * 0.6))
                                dxDrawText(name, x + 5, y, x + w, y + h + 4, tocolor(242,242,242,alpha * 0.6), 1, font2, "left", "center")

                                local x = x + w - 5 - 18
                                dxDrawImage(x, y + h/2 - 14/2, 18, 14, "files/images/cloth.png", 0, 0, 0, tocolor(242, 242, 242, alpha * 0.2))

                                x = x - 18 - 5
                                dxDrawImage(x, y + h/2 - 12/2, 15, 12, "files/images/view.png", 0, 0, 0, tocolor(242, 242, 242, alpha * 0.2))

                                x = x - 15 - 5
                                dxDrawImage(x, y + h/2 - 14/2, 14, 14, "files/images/move.png", 0, 0, 0, tocolor(242, 242, 242, alpha * 0.2))
                            end

                            num = num + 1
                        end
                    end
                end
            end
            index = index + 1
        end

        if num <= 10 then
            for i = num, 10 do
                local x, y, w, h = unpack(positions[i])
                if exports['cr_core']:isInSlot(x,y,w,h) then
                    dxDrawRectangle(x, y, w, h, tocolor(51, 51, 51, alpha * 0.9))
                else
                    dxDrawRectangle(x, y, w, h, tocolor(51, 51, 51, alpha * 0.6))
                end
            end
        end
    elseif panelType == 3 then 
        local w, h = 300, 20
        local x, y = x + 15, y + 50

        local r, g, b = exports.cr_core:getServerColor("green", false)
        local r2, g2, b2 = exports.cr_core:getServerColor("red", false)
        local yellowHex = exports.cr_core:getServerColor("yellow", true)
        local grayHex = "#F2F2F2"

        local buttonW, buttonH = 70, 15

        hoverClothSlot = nil
        hoverButton = nil

        for i = clothesMinLines, clothesMaxLines do 
            local inSlot = exports.cr_core:isInSlot(x, y, w, h)
            local colorMul = 0.6
            if inSlot then 
                colorMul = 0.9
                hoverClothSlot = i
            end

            dxDrawRectangle(x, y, w, h, tocolor(51, 51, 51, alpha * colorMul))

            local data = slotCache[i]
            local text = "Zárolt slot - Slot megvásárlása " .. yellowHex .. slotPrice .. " PP" .. grayHex .. "-ért"

            local alignX = "center"
            local padding = 0
            local textFont = font4

            if data then 
                text = "üres slot"

                if data.name then 
                    text = data.name

                    alignX = "left"
                    padding = 5
                    textFont = font2

                    local removeButtonX, removeButtonY = x + w - buttonW - padding, y + 3

                    local buttonX, buttonY = removeButtonX - buttonW - padding, removeButtonY
                    local inSlot = exports.cr_core:isInSlot(buttonX, buttonY, buttonW, buttonH)

                    local buttonColor = tocolor(r, g, b, alpha * 0.7)
                    local textColor = tocolor(255, 255, 255, alpha * 0.6)

                    if inSlot then 
                        buttonColor = tocolor(r, g, b, alpha)
                        textColor = tocolor(255, 255, 255, alpha)
                        hoverButton = {name = "edit", index = i}
                    end

                    dxDrawRectangle(buttonX, buttonY, buttonW, buttonH, buttonColor)
                    dxDrawText("Szerkesztés", buttonX, buttonY + 3, buttonX + buttonW, buttonY + buttonH, textColor, 1, font3, "center", "center")

                    local buttonColor2 = tocolor(r2, g2, b2, alpha * 0.7)
                    local textColor2 = tocolor(255, 255, 255, alpha * 0.6)
                    local inSlot = exports.cr_core:isInSlot(removeButtonX, removeButtonY, buttonW, buttonH)
                    if inSlot then 
                        buttonColor2 = tocolor(r2, g2, b2, alpha)
                        textColor2 = tocolor(255, 255, 255)
                        hoverButton = {name = "remove", index = i}
                    end

                    dxDrawRectangle(removeButtonX, removeButtonY, buttonW, buttonH, buttonColor2)
                    dxDrawText("Levétel", removeButtonX, removeButtonY + 3, removeButtonX + buttonW, removeButtonY + buttonH, textColor2, 1, font3, "center", "center")
                end
            end

            dxDrawText(text, x + padding, y + 4, x + w, y + h, tocolor(242, 242, 242, alpha * 0.6), 1, textFont, alignX, "center", false, false, false, true)

            y = y + 23
        end
    end 

    if maxLines > (index - 1) then 
        maxLines = math.max(10, index - 1)
        minLines = maxLines - (10 - 1)
    end 

    --scrollbar
    local percent = math.max(0, index - 1)
    
    if percent >= 1 then
        local gW, gH = 3, 227
        local gX, gY = x + w - 3 - 5, y + 50
        
        scrollingHover = exports["cr_core"]:isInSlot(gX, gY, gW, gH)
        
        if scrolling then
            if isCursorShowing() then
                if getKeyState("mouse1") then
                    local cx, cy = exports['cr_core']:getCursorPosition()
                    local cy = math.min(math.max(cy, gY), gY + gH)
                    local y = (cy - gY) / (gH)
                    local num = percent * y
                    minLines = math.max(1, math.floor(math.min(math.max(num, 1), (percent - 10) + 1)))
                    maxLines = minLines + (10 - 1)
                end
            else
                scrolling = false
            end
        end
        
        dxDrawRectangle(gX,gY,gW,gH, tocolor(242,242,242,alpha * 0.6))
        
        local multiplier = math.min(math.max((maxLines - (minLines - 1)) / percent, 0), 1)
        local multiplier2 = math.min(math.max((minLines - 1) / percent, 0), 1)
        local gY = gY + ((gH) * multiplier2)
        local gH = gH * multiplier
        local r,g,b = 51, 51, 51
        dxDrawRectangle(gX, gY, gW, gH, tocolor(r,g,b, alpha))
    end
    --
end

local oldData = false
local preViewData = false

local maxCloserLook = 50
local maxFarestLook = 90

local objectPosition = Vector3(256.52661132812, -41.777370452881, 1002.0234375)

local function onItemPreviewKey(button, state)
    if button == "escape" and state then 
        cancelEvent()

        processItemPreview(false)
    elseif button == "mouse_wheel_up" and state then 
        preViewData.currentFov = math.max(maxCloserLook, preViewData.currentFov - 1)
    elseif button == "mouse_wheel_down" and state then 
        preViewData.currentFov = math.min(maxFarestLook, preViewData.currentFov + 1)
    end
end

function processItemPreview(state, name, objectId)
    if state then 
        local accId = localPlayer:getData("acc >> id")

        oldData = {
            playerPoint = localPlayer.position,
            interior = localPlayer.interior,
            dimension = localPlayer.dimension,
            frozen = localPlayer.frozen,
            chatState = exports["cr_custom-chat"]:isChatVisible()
        }

        exports["cr_custom-chat"]:showChat(false)

        localPlayer.interior = 14
        localPlayer.dimension = accId
        localPlayer.frozen = true

        local tempObject = Object(objectId, objectPosition)
        tempObject.interior = 14
        tempObject.dimension = accId

        preViewData = {
            tempScreenSource = dxCreateScreenSource(sx, sy),
            screenSource = dxCreateScreenSource(sx, sy),
            itemName = name,
            tempObject = tempObject,
            currentFov = 70,
            greenHex = exports.cr_core:getServerColor("green", true),
            yellowHex = exports.cr_core:getServerColor("yellow", true),
            redHex = exports.cr_core:getServerColor("red", true)
        }

        dxUpdateScreenSource(preViewData.tempScreenSource, true)
        setObjectScale(tempObject, 2)

        createRender("renderItemPreview", renderItemPreview)
        addEventHandler("onClientKey", root, onItemPreviewKey)
    else 
        if isElement(preViewData.tempScreenSource) then 
            preViewData.tempScreenSource:destroy()
            preViewData.tempScreenSource = nil
        end

        if isElement(preViewData.screenSource) then 
            preViewData.screenSource:destroy()
            preViewData.screenSource = nil
        end

        if isElement(preViewData.tempObject) then 
            preViewData.tempObject:destroy()
            preViewData.tempObject = nil
        end

        exports["cr_custom-chat"]:showChat(oldData.chatState)

        localPlayer.position = oldData.playerPoint
        localPlayer.interior = oldData.interior
        localPlayer.dimension = oldData.dimension
        localPlayer.frozen = oldData.frozen

        oldData = false
        preViewData = false

        destroyRender("renderItemPreview")
        setCameraTarget(localPlayer)
        removeEventHandler("onClientKey", root, onItemPreviewKey)
    end
end

function renderItemPreview()
    if preViewData.tempScreenSource then 
        dxDrawImage(0, 0, sx, sy, preViewData.tempScreenSource)
    end

    if preViewData.screenSource then 
        dxUpdateScreenSource(preViewData.screenSource)

        local w, h = 512, 512
        local x, y = sx / 2 - w / 2, sy / 2 - h / 2

        local font = exports.cr_fonts:getFont("Poppins-Regular", 18)

        dxDrawRectangle(x, y, w, h, tocolor(51, 51, 51, 255 * 0.9))
        dxDrawImage(x + 6, y + 6, w - 12, h - 12, preViewData.screenSource)

        dxDrawText(preViewData.itemName, x, y - 30, x + w, y + h, tocolor(255, 255, 255), 1, font, "center", "top")
        dxDrawText("Mozgatás: " .. preViewData.yellowHex .. "egér " .. white .. " | Kilépés: " .. preViewData.redHex .. "ESC " .. white .. " | Zoomolás: " .. preViewData.greenHex .. "görgő", x, y, x + w, y + h + 30, tocolor(255, 255, 255), 1, font, "center", "bottom", false, false, false, true)

        if getKeyState("mouse1") then 
            if isCursorShowing() then 
                local relX, relY = getCursorPosition()
                local absX, absY = (relX - 0.5), (relY - 0.5)
                local absolute = absX + absY
                local absoluteMethod = "x"

                if math.abs(absY) > math.abs(absX) then 
                    absoluteMethod = "y"
                end 

                local elementRX, elementRY, elementRZ = getElementRotation(preViewData.tempObject)

                if absoluteMethod == "y" then 
                    elementRZ = elementRZ - ((absolute) * 100)
                else 
                    elementRZ = elementRZ + ((absolute) * 100)
                end

                setElementRotation(preViewData.tempObject, elementRX, elementRY, elementRZ)

                setCursorPosition(sx / 2, sy / 2)
                setCursorAlpha(0)
            end
        else
            setCursorAlpha(255)
        end

        setCameraMatrix(259.47299194336, -39.513900756836, 1003.3704223633, 258.7177734375, -40.10620880127, 1003.0896606445, 0, preViewData.currentFov) 
    end
end

-- function command()
--     processClothesShop("init")
--     panelType = 3
-- end
-- addCommandHandler("command", command, false, false)

-- setTimer(
--     function()
--         if localPlayer.name == "Hugh_Wiley" then 
--             executeCommandHandler("command")
--         end
--     end, 500, 1
-- )

lastClickTick = -500
function onKey(button, state)
    if button == "mouse1" then 
        if state then 
            if start then 
                if listedHover then 
                    clothes[listedHover][2] = not clothes[listedHover][2]
                    listedHover = nil 
                    return
                elseif viewHover then 
                    local k, k2 = unpack(viewHover)

                    if k and k2 then 
                        local data = panelType == 2 and cache[k][k2] or panelType == 1 and clothes[k][3][k2] or false
                        
                        if data then 
                            local name = data.name
                            local objectId = data.objectId

                            if objectId then 
                                processItemPreview(true, name, objectId)
                                processClothesShop("exit")
                            end
                        end
                    end 
                    viewHover = nil 
                    return 
                elseif buyHover then 
                    local k, k2 = unpack(buyHover)

                    if k and k2 then 
                        local data = clothes[k][3][k2]

                        if data then 
                            local name = data["name"]
                            local price = data["price"]
                            local onlypp = data["onlypp"]
                            local ppPrice = data["ppPrice"]
                            local bone = data["bone"]
                            local defaultRotation = data["defaultRotation"] or {x = 0, y = 0, z = 90}
                            local objectId = data["objectId"]

                            if not hasAttachment(name) then 
                                if exports['cr_network']:getNetworkStatus() then return end 

                                local now = getTickCount()
                                local a = 1
                                if now <= lastClickTick + a * 1000 then
                                    return
                                end
                                lastClickTick = getTickCount()
                                
                                if exports["cr_core"]:takeMoney(localPlayer, price, false) then 
                                    -- local _, _, _, boneRx, boneRy, boneRz = exports.cr_bone_attach:getBonePositionAndRotation(localPlayer, bone)
                                    local boneX, boneY, boneZ = 0, 0, 0
                                    local boneRx, boneRy, boneRz = 0, 0, 0

                                    local data = {
                                        category = k,
                                        name = name,
                                        price = price,
                                        onlypp = onlypp,
                                        ppPrice = ppPrice,
                                        bone = bone,
                                        defaultRotation = defaultRotation,
                                        inUse = false,
                                        objectId = objectId,
                                        objectData = {
                                            x = boneX,
                                            y = boneY,
                                            z = boneZ,
                                            rx = boneRx,
                                            ry = boneRy,
                                            rz = boneRz,
                                            scaleData = {
                                                x = 1,
                                                y = 1,
                                                z = 1
                                            }
                                        }
                                    }

                                    exports["cr_infobox"]:addBox("success", "Sikeresen megvásároltad a "..name.." kiegészítőt.")

                                    triggerServerEvent("attachments.buyAttachment", localPlayer, false, data)
                                else
                                    exports["cr_infobox"]:addBox("error", "Nincs elég pénzed.")
                                end
                            else 
                                exports["cr_infobox"]:addBox("error", "Már megvásároltad ezt a kiegészítőt.")
                            end
                        end 
                    end 

                    buyHover = nil 
                    return 
                elseif pickupHover then 
                    local k, k2 = unpack(pickupHover)

                    if k and k2 then 
                        local data = cache[k][k2]

                        if data then 
                            local objectId = data["objectId"]
                            local bone = data["bone"]
                            local objectData = data["objectData"]

                            local category = getAttachmentCategory(objectId)
                            local index = hasAttachment(objectId)

                            if not attachmentsInUse[objectId] then 
                                triggerServerEvent("attachments.createAttachment", localPlayer, localPlayer, objectId, bone, objectData, category, index, true, selectedSlot)
                            else
                                triggerServerEvent("attachments.destroyAttachment", localPlayer, localPlayer, objectId, category, index, selectedSlot)
                            end

                            processClothesShop("exit")
                        end 
                    end 

                    pickupHover = nil 
                    return 
                elseif moveHover then 
                    local k, k2 = unpack(moveHover)

                    if k and k2 then 
                        local data = cache[k][k2]

                        if data then 
                            local objectId = data["objectId"]

                            if attachmentsInUse[objectId] then 
                                processClothesShop("exit")
            
                                exports["cr_head"]:initHeadMove(true)
                                exports["cr_elementeditor"]:toggleEditor(attachmentsInUse[objectId], "attachmentSaveTrigger", "attachmentCancelTrigger", true)
                            else
                                exports["cr_infobox"]:addBox("error", "Előbb vedd fel a kiválasztott kiegészítőt.")
                            end
                        end 
                    end 

                    moveHover = nil 
                    return 
                elseif hoverClothSlot then 
                    if slotCache[hoverClothSlot] then
                        if not slotCache[hoverClothSlot].id then 
                            panelType = 2
                            selectedSlot = hoverClothSlot
                        else 
                            if hoverButton and hoverButton.name and hoverButton.index then 
                                local data = slotCache[hoverButton.index]

                                if hoverButton.name == "edit" then 
                                    if data then 
                                        local objectId = data.objectId
                                        local objectData = data.objectData

                                        if attachmentsInUse[objectId] then 
                                            processClothesShop("exit")
                        
                                            if objectData then 
                                                local x, y, z = objectData.x, objectData.y, objectData.z
                                                local rx, ry, rz = objectData.rx, objectData.ry, objectData.rz
                                                local scaleData = objectData.scaleData
                                                local scaleX, scaleY, scaleZ = scaleData.x, scaleData.y, scaleData.z

                                                editingCloth = {position = {x, y, z}, rotation = {rx, ry, rz}, scaleData = {scaleX, scaleY, scaleZ}}
                                            end

                                            exports.cr_head:initHeadMove(true)
                                            exports.cr_elementeditor:toggleEditor(attachmentsInUse[objectId], "attachmentSaveTrigger", "attachmentCancelTrigger", true)
                                        else
                                            exports["cr_infobox"]:addBox("error", "Előbb vedd fel a kiválasztott kiegészítőt.")
                                        end
                                    end
                                elseif hoverButton.name == "remove" then 
                                    if data then 
                                        local objectId = data.objectId
                                        local category = getAttachmentCategory(objectId)
                                        local index = hasAttachment(objectId)

                                        triggerServerEvent("attachments.destroyAttachment", localPlayer, localPlayer, objectId, category, index, hoverClothSlot)
                                    end
                                end
                            end
                        end
                    else
                        slotToBuy = hoverClothSlot

                        processClothesShop("exit")

                        local yellowHex = exports.cr_core:getServerColor("yellow", true)
                        local grayHex = "#F2F2F2"

                        exports.cr_dashboard:createAlert(
                            {
                                title = {"Biztosan megakarod venni ezt a slotot " .. yellowHex .. slotPrice .. " PP" .. grayHex .. "-ért?"},
                                buttons = {
                                    {
                                        name = "Igen", 
                                        pressFunc = "attachments.buySlot",
                                        onCreate = "",
                                        color = {exports.cr_core:getServerColor("green", false)},
                                    },

                                    {
                                        name = "Nem", 
                                        onClear = true,
                                        pressFunc = "",
                                        color = {exports.cr_core:getServerColor("red", false)},
                                    },
                                },
                            }
                        )

                        hoverClothSlot = nil
                        hoverButton = nil
                    end
                end 

                if scrollingHover then 
                    scrolling = true

                    scrollingHover = nil
                    return
                end

                if closeHover then 
                    processClothesShop("exit")

                    closeHover = nil
                    return
                end
            end
        else
            if scrolling then 
                scrolling = false
            end
        end
    elseif button == "mouse_wheel_down" then 
        if state then 
            if start then 
                if boxHover then 
                    scrollDown()

                    boxHover = nil
                end
            end
        end
    elseif button == "mouse_wheel_up" then 
        if state then 
            if start then 
                if boxHover then 
                    scrollUP()

                    boxHover = nil
                end
            end
        end
    end
end

function processClothesShop(state)
    if state == "init" then 
        if not start then 
            createRender("renderClothesShop", renderClothesShop)

            start = true

            exports["cr_dx"]:startFade("clothesShopPanel", 
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

            removeEventHandler("onClientKey", root, onKey)
            addEventHandler("onClientKey", root, onKey)
        end 
    elseif state == "exit" then 
        if start then
            start = false 

            exports["cr_dx"]:startFade("clothesShopPanel", 
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

            removeEventHandler("onClientKey", root, onKey)
        end
    end
end

addEventHandler("onClientClick", root,
    function(button, state, absX, absY, worldX, worldY, worldZ, clickedElement)
        if button == "left" then 
            if state == "down" then 
                if isElement(clickedElement) and clickedElement.type == "ped" then 
                    if clickedElement:getData("ped >> clothes") then 
                        local distance = getDistanceBetweenPoints3D(localPlayer.position, clickedElement.position)

                        if distance <= 3 then 
                            if not start then 
                                gPed = clickedElement
                                processClothesShop("init")
                            end
                        end
                    end
                end
            end
        end
    end
)

function showMyClothes()
    if localPlayer:getData("loggedIn") then 
        if not start then 
            panelType = 3

            processClothesShop("init")

            if not firstLoad then 
                triggerServerEvent("attachments.loadAttachments", localPlayer, localPlayer)
            end
        end
    end
end
addCommandHandler("clothes", showMyClothes, false, false)
addCommandHandler("cuccaim", showMyClothes, false, false)

addEvent("attachments.loadAttachments", true)
addEventHandler("attachments.loadAttachments", root,
    function(tbl, tbl2)
        cache = tbl
        slotCache = tbl2

        if not firstLoad then 
            firstLoad = true
        end
    end
)

addEvent("attachments.loadUsingAttachments", true)
addEventHandler("attachments.loadUsingAttachments", root,
    function(tbl)
        attachmentsInUse = tbl
    end
)

addEvent("attachmentSaveTrigger", true)
addEventHandler("attachmentSaveTrigger", root,
    function(element, x, y, z, rx, ry, rz, scale)
        if element:getData("attachmentParent") == localPlayer then 
            exports.cr_head:initHeadMove(false)

            editingCloth = false
            local scaleX, scaleY, scaleZ = element:getScale()
            local scaleData = {x = scaleX, y = scaleY, z = scaleZ}

            local objectId = element.model
            local objectData = {
                x = x,
                y = y,
                z = z,
                rx = rx,
                ry = ry,
                rz = rz,
                scaleData = scaleData
            }

            local category = getAttachmentCategory(objectId)
            local index = hasAttachment(objectId)
            local dbId = getAttachmentDatabaseId(objectId)

            triggerServerEvent("attachments.saveAttachment", localPlayer, localPlayer, objectId, objectData, category, index, dbId)
        end
    end
)

addEvent("attachmentCancelTrigger", true)
addEventHandler("attachmentCancelTrigger", root,
    function(element, x, y, z, rx, ry, rz, scale)
        if element:getData("attachmentParent") == localPlayer then 
            if editingCloth and editingCloth.position and editingCloth.rotation then 
                local x, y, z = unpack(editingCloth.position)
                local rx, ry, rz = unpack(editingCloth.rotation)
                local scaleX, scaleY, scaleZ = unpack(editingCloth.scaleData)

                element:setScale(scaleX, scaleY, scaleZ)
                exports.cr_bone_attach:setElementBonePositionOffset(element, x, y, z)
                exports.cr_bone_attach:setElementBoneRotationOffset(element, rx, ry, rz)
            end

            editingCloth = false
            exports["cr_head"]:initHeadMove(false)
        end
    end
)

function onAttachmentSlotBuy()
    triggerLatentServerEvent("attachments.buySlot", 5000, false, localPlayer, slotToBuy)
end
addEvent("attachments.buySlot", true)
addEventHandler("attachments.buySlot", root, onAttachmentSlotBuy)

function hasAttachment(gName)
    local result = false

    if type(gName) == "string" then 
        for i = 1, #clothes do 
            if cache[i] then 
                for j = 1, #cache[i] do 
                    local v = cache[i][j]

                    if v then 
                        local name = v["name"]

                        if gName:lower() == name:lower() then 
                            result = j
                            break
                        end
                    end

                    if result then 
                        break
                    end
                end
            end
        end
    elseif type(gName) == "number" then 
        for i = 1, #clothes do 
            if cache[i] then 
                for j = 1, #cache[i] do 
                    local v = cache[i][j]

                    if v then 
                        local objectId = v["objectId"]

                        if objectId == gName then 
                            result = j
                            break
                        end
                    end

                    if result then 
                        break
                    end
                end
            end
        end
    end

    return result
end

function getAttachmentCategory(id)
    local result = false

    for i = 1, #clothes do 
        local v = clothes[i]

        if v then 
            for j = 1, #clothes[i][3] do 
                local v2 = clothes[i][3][j]

                if v2 then 
                    local objectId = v2["objectId"]

                    if objectId == id then 
                        result = i
                        break
                    end
                end

                if result then 
                    break
                end
            end
        end
    end

    return result
end

function getAttachmentDatabaseId(objectId)
    local result = false

    for i = 1, #clothes do 
        if cache[i] then 
            for j = 1, #cache[i] do 
                local v = cache[i][j]

                if v then 
                    local id = v["objectId"]
                    local dbId = v["id"]

                    if objectId == id then 
                        result = dbId
                        break
                    end
                end

                if result then 
                    break
                end
            end
        end
    end

    return result
end

function scrollDown()
    local index, num = 1, 0

    for k, v in pairs(clothes) do
        local category, listed, items = unpack(v)

        if listed then
            if index >= minLines and index <= maxLines then
                num = num + 1
            end

            for k2, v2 in pairs(items) do
                index = index + 1

                if index >= minLines and index <= maxLines then
                    num = num + 1
                end
            end
        else
            if index >= minLines and index <= maxLines then
                num = num + 1
            end
        end

        index = index + 1
    end

    if boxHover then
        if maxLines + 1 < index then
            minLines = minLines + 1
            maxLines = maxLines + 1
        end
    end
end

function scrollUP()
    if boxHover then
        if minLines - 1 >= 1 then
            minLines = minLines - 1
            maxLines = maxLines - 1
        end
    end
end