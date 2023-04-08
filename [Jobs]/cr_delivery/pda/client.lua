local screenX, screenY = guiGetScreenSize()
local dxDrawMultiplier = math.min(0.8, screenX / 1280)

function resp(val)
    return val * dxDrawMultiplier
end

function getRealFontSize(a)
    local a = resp(a)
    local val = ((a) - math.floor(a))
    if val < 0.5 then
        return math.floor(a)
    elseif val >= 0.5 then
        return math.ceil(a)
    end
end

local pdaWidth, pdaHeight = resp(278), resp(603)
local pdaPosX, pdaPosY = screenX - pdaWidth - resp(15), screenY / 2 - pdaHeight / 2

local moveData = false

local realTime = getRealTime()
local hours = realTime.hour
local minutes = realTime.minute
local realTimeUpdateTimer = false

orders = {}
ordersInPDA = {}

local minLine = 1
local maxLine = 10

local scrolling = false
local scrollingHover = false

local alpha = 0

local _orderMinLine = 1
local orderMinLine = _orderMinLine

local _orderMaxLine = 10
local orderMaxLine = _orderMaxLine

local hoverOrder = false
local panelHover = false
local closeHover = false

isOrdersShowing = false
clickedVehicle = false

isPDAShowing = false
closingPanel = false
currentOrderInHand = false

liftUpAnimationTimer = false

function renderPDA()
    if isCursorShowing() then 
        if moveData then 
            local cursorX, cursorY = exports.cr_core:getCursorPosition()

            pdaPosX = cursorX + moveData.offsetX
            pdaPosY = cursorY + moveData.offsetY
        end
    end

    dxDrawImage(pdaPosX, pdaPosY, pdaWidth, pdaHeight, "files/images/pda/bg.png")

    local iconW, iconH = resp(48), resp(48)
    local iconX, iconY = pdaPosX + resp(3), pdaPosY + iconH / 2 + resp(8)

    dxDrawImage(iconX, iconY, iconW, iconH, "files/images/pda/signal.png")

    local font = exports.cr_fonts:getFont("Poppins-Regular", getRealFontSize(13))
    dxDrawText("Figma", iconX + iconW + resp(20), iconY + resp(5), iconX + iconW, iconY + iconH, tocolor(0, 0, 0), 1, font, "center", "center")

    dxDrawImage(iconX + iconW + resp(20), iconY, iconW, iconH, "files/images/pda/wifi.png")
    dxDrawImage(iconX + pdaWidth - iconW - resp(50), iconY, iconW, iconH, "files/images/pda/battery.png")

    dxDrawText(string.format("%02d:%02d", hours, minutes), iconX + pdaWidth - iconW + resp(25), iconY + resp(2), iconX + pdaWidth - iconW - resp(45) + iconW, iconY + iconH, tocolor(0, 0, 0), 1, font, "center", "center")

    local font2 = exports.cr_fonts:getFont("Poppins-Regular", getRealFontSize(15))
    dxDrawText("Kézbesítések", pdaPosX + resp(15), pdaPosY + resp(80), pdaPosX + pdaWidth, pdaPosY + pdaHeight, tocolor(0, 0, 0), 1, font2, "left", "top")

    local font3 = exports.cr_fonts:getFont("Poppins-Regular", getRealFontSize(13))
    local font4 = exports.cr_fonts:getFont("Poppins-Regular", getRealFontSize(10))
    local font5 = exports.cr_fonts:getFont("Poppins-Regular", getRealFontSize(11))

    local orderY = pdaPosY + resp(110)
    for i = minLine, maxLine do 
        local v = ordersInPDA[i]

        if v then 
            local orderId = v.orderId
            local customer = v.customer

            local zoneName = v.zoneName
            local delivered = v.delivered

            if orderId and customer then 
                local text = "#" .. orderId .." - " .. customer

                local iconW, iconH = resp(48), resp(48)
                local iconX, iconY = pdaPosX + pdaWidth - iconW - resp(15), orderY - resp(10)

                dxDrawImage(iconX - resp(35), iconY, iconW, iconH, "files/images/pda/location_hover.png")

                if delivered then 
                    dxDrawImage(iconX, iconY, iconW, iconH, "files/images/pda/delivered_hover.png")
                    dxDrawText("Kézbesítve", iconX, iconY, iconX + iconW, iconY + iconH + resp(2), tocolor(51, 51, 51), 1, font4, "center", "bottom")
                else
                    dxDrawImage(iconX, iconY, iconW, iconH, "files/images/pda/delivered.png")
                end

                dxDrawText(text, pdaPosX + resp(15), orderY, pdaPosX + pdaWidth, pdaPosY + pdaHeight, tocolor(0, 0, 0), 1, font3, "left", "top")
                dxDrawText(zoneName, pdaPosX + resp(82), orderY + resp(18), pdaPosX + pdaWidth, pdaPosY + pdaHeight, tocolor(0, 0, 0), 1, font5, "left", "top")

                local lineW, lineH = pdaWidth - resp(40), resp(1)
                local lineX, lineY = pdaPosX + resp(20), orderY + resp(40)

                dxDrawRectangle(lineX, lineY, lineW, lineH, tocolor(51, 51, 51, 255 * 0.3))

                orderY = orderY + resp(45)
            end
        end
    end
end

function renderOrders()
    local alpha, progress = exports.cr_dx:getFade("delivery >> ordersPanel")

    if closingPanel then 
        if progress >= 1 then 
            destroyRender("renderOrders")

            isOrdersShowing = false
            closingPanel = false
            closeHover = false
            hoverOrder = false

            return
        end
    end

    if isElement(clickedVehicle) then 
        if getDistanceBetweenPoints3D(localPlayer.position, clickedVehicle.position) >= 5 then 
            closeOrdersPanel()
        end
    end

    local panelW, panelH = 320, 525
    local panelX, panelY = screenX / 2 - panelW / 2, screenY / 2 - panelH / 2
    local inSlot = exports.cr_core:isInSlot(panelX, panelY, panelW, panelH)

    panelHover = nil
    if inSlot then 
        panelHover = true
    end

    local closeW, closeH = 15, 15
    local closeX, closeY = panelX + panelW - 10 - 15, panelY + 10
    local closeMultiplier = 0.6
    local inSlot = exports.cr_core:isInSlot(closeX, closeY, closeW, closeH)

    closeHover = nil
    if inSlot then 
        closeHover = true
        closeMultiplier = 1
    end

    dxDrawRectangle(panelX, panelY, panelW, panelH, tocolor(51, 51, 51, alpha * 0.8))
    dxDrawImage(closeX, closeY, closeW, closeH, ":cr_inventory/assets/images/close.png", 0, 0, 0, tocolor(255, 59, 59, alpha * closeMultiplier))
    
    local logoW, logoH = 32, 32
    local logoX, logoY = panelX + 10, panelY + 5

    local font = exports.cr_fonts:getFont("Poppins-Bold", 15)

    dxDrawImage(logoX, logoY, logoW, logoH, ":cr_account/files/logo-white.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
    dxDrawText("Áruszállító", logoX + logoW + 10, logoY + 4, logoX + logoW, logoY + logoH, tocolor(255, 255, 255, alpha), 1, font, "left", "center")

    local iconW, iconH = 48, 48
    local iconX = panelX + 10

    local orderY = panelY + logoH + 10

    local font2 = exports.cr_fonts:getFont("Poppins-Medium", 14)
    local greenR, greenG, greenB = exports.cr_core:getServerColor("green", false)

    -- Scrollbar

    local scrollX, scrollY = panelX + panelW - 8, panelY + 50
    local scrollW, scrollH = 3, panelH - 100

    dxDrawRectangle(scrollX, scrollY, scrollW, scrollH, tocolor(242, 242, 242, alpha * 0.6))

    local percent = #orders

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

                    orderMinLine = math.max(1, math.floor(math.min(math.max(num, 1), (percent - _orderMaxLine) + 1)))
                    orderMaxLine = orderMinLine + (_orderMaxLine - 1)
                end
            else
                scrolling = false
            end
        end

        local multiplier = math.min(math.max((orderMaxLine - (orderMinLine - 1)) / percent, 0), 1)
        local multiplier2 = math.min(math.max((orderMinLine - 1) / percent, 0), 1)
        local gY = gY + ((gH) * multiplier2)
        local gH = gH * multiplier
        local r, g, b = 255, 59, 59

        dxDrawRectangle(gX, gY, gW, gH, tocolor(r, g, b, alpha))
    end

    hoverOrder = nil
    for i = orderMinLine, orderMaxLine do 
        local v = ordersInPDA[i]

        if v and v.visible then 
            local orderId = v.orderId
            local orderType = v.orderType == "Package" and "Csomag" or "Levél"
            local orderIcon = v.orderType == "Package" and "files/images/panel/package.png" or "files/images/panel/letter.png"

            dxDrawImage(iconX, orderY, iconW, iconH, orderIcon, 0, 0, 0, tocolor(255, 255, 255, alpha))
            dxDrawText(orderType, iconX + iconW + 13, orderY - 10, iconX + iconW, orderY + iconH, tocolor(255, 255, 255, alpha * 0.8), 1, font2, "left", "center")
            dxDrawText("#" .. orderId, iconX + iconW + 13, orderY - 10 + 35, iconX + iconW, orderY + iconH, tocolor(255, 255, 255, alpha * 0.8), 1, font2, "left", "center")

            local buttonW, buttonH = 125, 25
            local buttonX, buttonY = panelX + panelW - buttonW - 25, orderY + buttonH / 2

            local alphaMul = 0.7
            local textAlphaMul = 0.6

            local inSlot = exports.cr_core:isInSlot(buttonX, buttonY, buttonW, buttonH)
            if inSlot then 
                hoverOrder = i

                alphaMul = 1
                textAlphaMul = 1
            end

            dxDrawRectangle(buttonX, buttonY, buttonW, buttonH, tocolor(greenR, greenG, greenB, alpha * alphaMul))
            dxDrawText("Kivesz", buttonX, buttonY + 4, buttonX + buttonW, buttonY + buttonH, tocolor(255, 255, 255, alpha * textAlphaMul), 1, font2, "center", "center")

            orderY = orderY + iconH
        end
    end
end

local function onClientKey(button, state)
    if button == "mouse1" then 
        if state then 
            local cursorX, cursorY = exports.cr_core:getCursorPosition()

            if exports.cr_core:isInSlot(pdaPosX, pdaPosY, pdaWidth, 45) then 
                if not moveData then 
                    moveData = {
                        offsetX = pdaPosX - cursorX,
                        offsetY = pdaPosY - cursorY
                    }
                end
            elseif scrollingHover then 
                if not scrolling then 
                    scrolling = true
                    scrollingHover = false
                end
            elseif closeHover then 
                closeOrdersPanel()
                closeHover = false
            elseif hoverOrder then 
                if not localPlayer:getData("delivery >> crateInHand") and ordersInPDA[hoverOrder].visible then 
                    local nowTick = getTickCount()
                    
                    if lastClick + 1500 > nowTick then 
                        return
                    end

                    ordersInPDA[hoverOrder].visible = false
                    currentOrderInHand = hoverOrder

                    localPlayer:setData("forceAnimation", {"carry", "liftup", -1, false, false, false, false, 250, true})

                    if isTimer(liftUpAnimationTimer) then 
                        killTimer(liftUpAnimationTimer)
                        liftUpAnimationTimer = nil
                    end

                    liftUpAnimationTimer = setTimer(
                        function()
                            localPlayer:setData("forceAnimation", {"carry", "crry_prtial", 0, true, false, true, true})
                            liftUpAnimationTimer = nil
                        end, 275, 1
                    )

                    triggerLatentServerEvent("onClientDeliveryPackagePickup", 5000, false, localPlayer)
                    closeOrdersPanel()

                    lastClick = getTickCount()
                end

                hoverOrder = false
            end
        else
            if moveData then 
                moveData = false
            end

            if scrolling then 
                scrolling = false
            end
        end
    elseif button == "backspace" and state then 
        if isOrdersShowing then 
            closeOrdersPanel()
        end
    elseif button == "mouse_wheel_down" and state then
        scrollDown()
    elseif button == "mouse_wheel_up" and state then 
        scrollUP()
    end
end

function resetPDA(state)
    ordersInPDA = {}

    destroyRender("renderPDA")

    if isTimer(realTimeUpdateTimer) then 
        killTimer(realTimeUpdateTimer)
        realTimeUpdateTimer = nil
    end

    if state then 
        removeEventHandler("onClientKey", root, onClientKey)
    end
end

function manageOrdersPanel(state)
    if state == "open" then 
        isOrdersShowing = true

        createRender("renderOrders", renderOrders)

        exports.cr_dx:startFade("delivery >> ordersPanel", 
            {
                startTick = getTickCount(),
                lastUpdateTick = getTickCount(),
                time = 250,
                animation = "InOutQuad",
                from = 0,
                to = 255,
                alpha = 0,
                progress = 0,
            }
        )

        removeEventHandler("onClientKey", root, onClientKey)
        addEventHandler("onClientKey", root, onClientKey)
    elseif state == "close" then
        closingPanel = true

        exports.cr_dx:startFade("delivery >> ordersPanel", 
            {
                startTick = getTickCount(),
                lastUpdateTick = getTickCount(),
                time = 250,
                animation = "InOutQuad",
                from = 255,
                to = 0,
                alpha = 255,
                progress = 0,
            }
        )
    end
end

function closeOrdersPanel()
    if not closingPanel then 
        manageOrdersPanel("close")
    end

    closeHover = false
end

orderIdCache = {}
createdLocations = {}
locationCache = {}

function generateOrderId(isLetter)
    local prefix = isLetter and "L" or "P"
    local numbers = generateString(5, true, false)
    local formattedString = prefix .. numbers

    if orderIdCache[formattedString:lower()] then 
        return generateOrderId(isLetter)
    end

    return formattedString
end

function getRandomLocation()
    local randomLocation = math.random(1, #jobData.deliveryPositions)

    if createdLocations[randomLocation] then 
        return getRandomLocation()
    end

    createdLocations[randomLocation] = true

    return randomLocation
end

function generateOrders()
    orders = {}

    local orderCount = math.random(jobData.minOrder, jobData.maxOrder)
    
    for i = 1, orderCount do 
        local isLetter = math.random(1, 2) == 1

        local orderId = generateOrderId(isLetter)
        local orderType = isLetter and "Letter" or "Package"

        local randomLocation = getRandomLocation()
        local locationData = jobData.deliveryPositions[randomLocation]

        local x, y, z = locationData.x, locationData.y, locationData.z
        local interior, dimension = locationData.interior, locationData.dimension
		local desiredRotation = locationData.rotation

        local gender = locationData.gender
        local customer = exports.cr_core:createRandomName(gender)
        local skinId = locationData.skinId

        createCustomer(orderId, customer, skinId, x, y, z, desiredRotation)

        table.insert(orders, {
            orderId = orderId,
            orderType = orderType,
            customer = customer,
            zoneName = getZoneName(x, y, z),
            delivered = false,
            visible = true
        })

        table.insert(ordersInPDA, {
            orderId = orderId,
            orderType = orderType,
            customer = customer,
            zoneName = getZoneName(x, y, z),
            delivered = false,
            visible = true
        })

        orderIdCache[orderId:lower()] = i
        locationCache[orderId:lower()] = randomLocation
    end
end

function setupDeliveryLocations()
    generateOrders()
    createRender("renderPDA", renderPDA)
    isPDAShowing = true

    if not isTimer(realTimeUpdateTimer) then 
        realTimeUpdateTimer = setTimer(
            function()
                realTime = getRealTime()
                hours = realTime.hour
                minutes = realTime.minute
            end, 60000, 0
        )
    end

    removeEventHandler("onClientKey", root, onClientKey)
    addEventHandler("onClientKey", root, onClientKey)
end

function resetPDAPosition()
    if localPlayer:getData("loggedIn") and (localPlayer:getData("char >> job") or 0) == jobData.jobId then 
        pdaPosX = screenX - pdaWidth - 15
        pdaPosY = screenY / 2 - pdaHeight / 2
    end
end
addCommandHandler("resetpda", resetPDAPosition, false, false)

function scrollDown()
    if isPDAShowing then 
        if exports.cr_core:isInSlot(pdaPosX, pdaPosY, pdaWidth, pdaHeight) then 
            if maxLine + 1 <= #orders then 
                minLine = minLine + 1
                maxLine = maxLine + 1
            end
        end
    end

    if isOrdersShowing then 
        if panelHover then 
            if orderMaxLine + 1 <= #orders then 
                orderMinLine = orderMinLine + 1
                orderMaxLine = orderMaxLine + 1
            end
        end
    end
end

function scrollUP()
    if isPDAShowing then 
        if exports.cr_core:isInSlot(pdaPosX, pdaPosY, pdaWidth, pdaHeight) then 
            if minLine - 1 > 0 then 
                minLine = minLine - 1
                maxLine = maxLine - 1
            end
        end
    end

    if isOrdersShowing then 
        if panelHover then 
            if orderMinLine - 1 > 0 then 
                orderMinLine = orderMinLine - 1
                orderMaxLine = orderMaxLine - 1
            end
        end
    end
end