local sx, sy = guiGetScreenSize()

local start = false 
local startTick = getTickCount()

local page = 1

local startAnimation = "InOutQuad"
local startAnimationTime = 250

local selectedWeapon = 0

-- local closeKey = false 
-- local tempClose = 0
-- local closeTick = 0
-- local progressBar = 0

local targetObjects = {}
local moveDatas = {
    ["moves"] = {},
    ["timers"] = {},
    ["datas"] = {},
}

local playerStats = {}

local boxHover = false
local exitTrainingHover = false

function renderMenu()
    local nowTick = getTickCount()
    local alpha
    if start then
        local elapsedTime = nowTick - startTick
        local duration = (startTick + startAnimationTime) - startTick
        local progress = elapsedTime / duration
        local alph = interpolateBetween(
            0, 0, 0,
            255, 0, 0,
            progress, startAnimation
        )
        
        alpha = alph
    else
        local elapsedTime = nowTick - startTick
        local duration = (startTick + startAnimationTime) - startTick
        local progress = elapsedTime / duration
        local alph = interpolateBetween(
            255, 0, 0,
            0, 0, 0,
            progress, startAnimation
        )
        
        alpha = alph
        
        if progress >= 1 then
            if not start then 
                alpha = 0
                selectedWeapon = 0
                forced = false
                priceMultipler = nil
                clickedPed = nil
                playerStats = {}
                destroyRender("renderMenu")
                removeEventHandler("onClientKey", root, onKey)
            end
        end
    end

    local w, h = 295, 255
    
    hoverButton = nil
    boxHover = nil 

    local x, y = sx/2 - w/2, sy/2 - h/2

    if isInSlot(x, y, w, h) then 
        boxHover = true
    end

    if pages[page] == "main" then 
        local font = exports['cr_fonts']:getFont('Poppins-SemiBold', 16)
        local font2 = exports['cr_fonts']:getFont('Poppins-Bold', 12)
        local font3 = exports['cr_fonts']:getFont('Poppins-Medium', 12)

        dxDrawRectangle(x, y, w, h, tocolor(51, 51, 51, alpha * 0.8))
        dxDrawImage(x + 10, y + 5, 25, 25, ":cr_account/files/logo-white.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
        dxDrawText("Fegyverklub", x + 10 + 25 + 10,y+5,x+w,y+5+25 + 4,tocolor(242, 242, 242, alpha),1,font,"left","center")

        dxDrawRectangle(x + 5, y + 40, 285, 160, tocolor(41, 41, 41, alpha * 0.9))
        dxDrawText("Fegyver neve", x + 20, y + 50, x + 20, y + 50, tocolor(242, 242, 242, alpha), 1, font2, "left", "top")
        dxDrawText("Skillpont", x + 275, y + 50, x + 275, y + 50, tocolor(242, 242, 242, alpha), 1, font2, "right", "top")

        local startX, startY = x + 5 + 10, y + 40 + 30

        hoverWeapon = nil
        for key = minLines, maxLines do 
            local value = weapons[key]

            local w2, h2 = 265, 20
            local inSlot = isInSlot(startX, startY, w2, h2)
            if inSlot then 
                hoverWeapon = key
            end

            dxDrawRectangle(startX, startY, w2, h2, ((inSlot or selectedWeapon == key) and tocolor(242, 242, 242, alpha * 0.8) or tocolor(51, 51, 51, alpha * 0.6)))
            dxDrawText(value["name"].." ("..((inSlot or selectedWeapon == key) and "#333333" or "#61b15a").."$"..formatMoney((priceMultipler and math.floor((value["price"] * priceMultipler)) or 0)).. ((inSlot or selectedWeapon == key) and "#333333" or "#f2f2f2") ..")", x + 20, startY, x + 20, startY + h2 + 4, ((inSlot or selectedWeapon == key) and tocolor(51, 51, 51, alpha) or tocolor(242, 242, 242, alpha)), 1, font3, "left", "center", false, false, false, true)
            dxDrawText((playerStats[value["statId"]] and playerStats[value["statId"]] or "0").."/1000", x + 275, startY, x + 275, startY + h2 + 4, ((inSlot or selectedWeapon == key) and tocolor(51, 51, 51, alpha) or tocolor(242, 242, 242, alpha)), 1, font3, "right", "center")

            startY = startY + h2 + 5
        end 

        if exports['cr_core']:isInSlot(x + w/2 - 150/2, y + 40 + 160 + 4, 150, 20) then 
            hoverButton = "start"
            dxDrawRectangle(x + w/2 - 150/2, y + 40 + 160 + 4, 150, 20, tocolor(97, 177, 90, alpha))
            dxDrawText('Indítás', x, y + 40 + 160 + 4, x + w, y + 40 + 160 + 4 + 20 + 4, tocolor(242, 242, 242, alpha), 1, font3, "center", "center")
        else 
            dxDrawRectangle(x + w/2 - 150/2, y + 40 + 160 + 4, 150, 20, tocolor(97, 177, 90, alpha * 0.7))
            dxDrawText('Indítás', x, y + 40 + 160 + 4, x + w, y + 40 + 160 + 4 + 20 + 4, tocolor(242, 242, 242, alpha * 0.6), 1, font3, "center", "center")
        end 

        if exports['cr_core']:isInSlot(x + w/2 - 150/2, y + 20 + 5 + 40 + 160 + 4, 150, 20) then 
            hoverButton = "close"
            dxDrawRectangle(x + w/2 - 150/2, y + 20 + 5 + 40 + 160 + 4, 150, 20, tocolor(255, 59, 59, alpha))
            dxDrawText('Bezárás', x, y + 20 + 5 + 40 + 160 + 4, x + w, y + 20 + 5 + 40 + 160 + 4 + 20 + 4, tocolor(242, 242, 242, alpha), 1, font3, "center", "center")
        else 
            dxDrawRectangle(x + w/2 - 150/2, y + 20 + 5 + 40 + 160 + 4, 150, 20, tocolor(255, 59, 59, alpha * 0.7))
            dxDrawText('Bezárás', x, y + 20 + 5 + 40 + 160 + 4, x + w, y + 20 + 5 + 40 + 160 + 4 + 20 + 4, tocolor(242, 242, 242, alpha * 0.6), 1, font3, "center", "center")
        end 
    elseif pages[page] == "decrease" then 
        local font = exports['cr_fonts']:getFont('Poppins-SemiBold', 16)
        local font2 = exports['cr_fonts']:getFont('Poppins-Bold', 12)
        local font3 = exports['cr_fonts']:getFont('Poppins-Medium', 12)

        dxDrawRectangle(x, y, w, h, tocolor(51, 51, 51, alpha * 0.8))
        dxDrawImage(x + 10, y + 5, 25, 25, ":cr_account/files/logo-white.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
        dxDrawText("Fegyverklub", x + 10 + 25 + 10,y+5,x+w,y+5+25 + 4,tocolor(242, 242, 242, alpha),1,font,"left","center")

        dxDrawRectangle(x + 5, y + 40, 285, 160, tocolor(41, 41, 41, alpha * 0.9))
        dxDrawText("Fegyver neve", x + 20, y + 50, x + 20, y + 50, tocolor(242, 242, 242, alpha), 1, font2, "left", "top")
        dxDrawText("Skillpont", x + 275, y + 50, x + 275, y + 50, tocolor(242, 242, 242, alpha), 1, font2, "right", "top")

        local startX, startY = x + 5 + 10, y + 40 + 30

        hoverWeapon = nil
        for key = minLines, maxLines do 
            local value = weapons[key]

            local w2, h2 = 265, 20
            local inSlot = isInSlot(startX, startY, w2, h2)
            if inSlot then 
                hoverWeapon = key
            end

            dxDrawRectangle(startX, startY, w2, h2, ((inSlot or selectedWeapon == key) and tocolor(242, 242, 242, alpha * 0.8) or tocolor(51, 51, 51, alpha * 0.6)))
            dxDrawText(value["name"].." ("..((inSlot or selectedWeapon == key) and "#333333" or "#61b15a").."$"..formatMoney((priceMultipler and math.floor((value["price"] * priceMultipler)) or 0)).. ((inSlot or selectedWeapon == key) and "#333333" or "#f2f2f2") ..")", x + 20, startY, x + 20, startY + h2 + 4, ((inSlot or selectedWeapon == key) and tocolor(51, 51, 51, alpha) or tocolor(242, 242, 242, alpha)), 1, font3, "left", "center", false, false, false, true)
            dxDrawText((playerStats[value["statId"]] and playerStats[value["statId"]] or "0").."/1000", x + 275, startY, x + 275, startY + h2 + 4, ((inSlot or selectedWeapon == key) and tocolor(51, 51, 51, alpha) or tocolor(242, 242, 242, alpha)), 1, font3, "right", "center")

            startY = startY + h2 + 5
        end 

        if exports['cr_core']:isInSlot(x + w/2 - 150/2, y + 40 + 160 + 4, 150, 20) then 
            hoverButton = "start"
            dxDrawRectangle(x + w/2 - 150/2, y + 40 + 160 + 4, 150, 20, tocolor(97, 177, 90, alpha))
            dxDrawText('Csökkentés', x, y + 40 + 160 + 4, x + w, y + 40 + 160 + 4 + 20 + 4, tocolor(242, 242, 242, alpha), 1, font3, "center", "center")
        else 
            dxDrawRectangle(x + w/2 - 150/2, y + 40 + 160 + 4, 150, 20, tocolor(97, 177, 90, alpha * 0.7))
            dxDrawText('Csökkentés', x, y + 40 + 160 + 4, x + w, y + 40 + 160 + 4 + 20 + 4, tocolor(242, 242, 242, alpha * 0.6), 1, font3, "center", "center")
        end 

        if exports['cr_core']:isInSlot(x + w/2 - 150/2, y + 20 + 5 + 40 + 160 + 4, 150, 20) then 
            hoverButton = "close"
            dxDrawRectangle(x + w/2 - 150/2, y + 20 + 5 + 40 + 160 + 4, 150, 20, tocolor(255, 59, 59, alpha))
            dxDrawText('Bezárás', x, y + 20 + 5 + 40 + 160 + 4, x + w, y + 20 + 5 + 40 + 160 + 4 + 20 + 4, tocolor(242, 242, 242, alpha), 1, font3, "center", "center")
        else 
            dxDrawRectangle(x + w/2 - 150/2, y + 20 + 5 + 40 + 160 + 4, 150, 20, tocolor(255, 59, 59, alpha * 0.7))
            dxDrawText('Bezárás', x, y + 20 + 5 + 40 + 160 + 4, x + w, y + 20 + 5 + 40 + 160 + 4 + 20 + 4, tocolor(242, 242, 242, alpha * 0.6), 1, font3, "center", "center")
        end 
    end

    -- Scrollbar

    dxDrawRectangle(x + 285, y + 70, 3, 120, tocolor(242, 242, 242, alpha * 0.6))

    local percent = #weapons

    if percent >= 1 then
        local gW, gH = 3, 120
        local gX, gY = x + 285, y + 70
        
        scrollingHover = isInSlot(gX, gY, gW, gH)

        if scrolling then
            if isCursorShowing() then
                if getKeyState("mouse1") then
                    local cx, cy = exports["cr_core"]:getCursorPosition()
                    local cy = math.min(math.max(cy, gY), gY + gH)
                    local y = (cy - gY) / (gH)
                    local num = percent * y
                    minLines = math.max(1, math.floor(math.min(math.max(num, 1), (percent - 5) + 1)))
                    maxLines = minLines + (5 - 1)
                end
            else
                scrolling = false
            end
        end

        local multiplier = math.min(math.max((maxLines - (minLines - 1)) / percent, 0), 1)
        local multiplier2 = math.min(math.max((minLines - 1) / percent, 0), 1)
        local gY = gY + ((gH) * multiplier2)
        local gH = gH * multiplier

        dxDrawRectangle(gX, gY, gW, gH, tocolor(255, 59, 59, alpha))
    end

    if clickedPed then 
        if isElement(clickedPed) then 
            if getDistanceBetweenPoints3D(localPlayer.position, clickedPed.position) > 2 then 
                if not forced then 
                    start = false 
                    startTick = getTickCount()
                    forced = true
                end
            end
        end
    end
end

local spamTick = 0
function onKey(button, state)
    if checkRender("renderMenu") then 
        if button == "mouse1" then 
            if state then 
                if getNetworkStatus() then 
                    return 
                end

                if spamTick + 250 > getTickCount() then 
                    return 
                end

                if scrollingHover then 
                    scrolling = true 
                end

                if hoverWeapon then 
                    if selectedWeapon == hoverWeapon then 
                        selectedWeapon = 0
                    else 
                        selectedWeapon = hoverWeapon 
                    end 

                    hoverWeapon = nil
                end

                if hoverButton == "start" then 
                    local weapon = localPlayer:getWeapon()

                    if selectedWeapon > 0 then 
                        if weapon ~= 0 then 
                            if weapons[selectedWeapon]["id"] == weapon then 
                                if pages[page] == "main" then 
                                    if getPlayerStats(weapons[selectedWeapon]["statId"]) < 1000 then 
                                        if hasMoney(localPlayer, math.floor((weapons[selectedWeapon]["price"] * priceMultipler)), false) then 
                                            takeMoney(localPlayer, math.floor((weapons[selectedWeapon]["price"] * priceMultipler)), false)

                                            triggerLatentServerEvent("giveMoneyToFaction", 5000, false, localPlayer, localPlayer, 4, math.floor(math.floor((weapons[selectedWeapon]["price"] * priceMultipler)) * 0.05)) -- GOVERMENT MONEY GIVING
                                            
                                            start = false 
                                            startTick = getTickCount()
                                            _selectedWeapon = selectedWeapon
                                            
                                            processTraining()
                                        else 
                                            return addBox("error", "Nincs elég pénzed.")
                                        end
                                    else 
                                        return addBox("error", "Már a maximumra fejlesztetted ezt a fegyvert.")
                                    end
                                elseif pages[page] == "decrease" then 
                                    if getPlayerStats(weapons[selectedWeapon]["statId"]) >= 10 then 
                                        local newValue = getPlayerStats(weapons[selectedWeapon]["statId"]) - 10
                                        local greenHex = getServerColor("green", true)
                                        triggerLatentServerEvent("changePlayerStats", 5000, false, localPlayer, localPlayer, weapons[selectedWeapon]["statId"], newValue, "decrease")

                                        addBox("success", "Sikeresen csökkentetted a skill pontjaidat. Fegyver: "..greenHex..weapons[selectedWeapon]["name"].."#f2f2f2, új érték: "..greenHex..newValue)

                                        playerStats[weapons[selectedWeapon]["statId"]] = newValue
                                    else 
                                        local redHex = getServerColor("red", true)
                                        addBox("error", "Ahhoz hogy csökkenteni tudd a skill pontjaidat legalább rendelkezned kell "..redHex.."10#f2f2f2 skill ponttal.")
                                        return 
                                    end
                                end
                            else 
                                return addBox("error", "A kezedben lévő fegyver nem egyezik a kiválasztottal.")
                            end
                        else
                            return addBox("error", "Vedd elő a kiválasztott fegyvert.")
                        end
                    else 
                        return addBox("error", "Válaszd ki a kívánt fegyvert.")
                    end

                    hoverButton = nil
                elseif hoverButton == "close" then 
                    start = false 
                    startTick = getTickCount()

                    hoverButton = nil
                end

                spamTick = getTickCount()
            else 
                if scrolling then 
                    scrolling = false
                end
            end
        elseif button == "mouse_wheel_down" then 
            if state then 
                if boxHover then 
                    scrollDown()
                end
            end
        elseif button == "mouse_wheel_up" then 
            if state then 
                if boxHover then 
                    scrollUP()
                end
            end
        -- elseif button == "backspace" then 
        --     if state then 
        --         closeKey = true 
        --         closeTick = getTickCount()
        --         tempClose = progressBar
        --     else 
        --         closeKey = false 
        --         closeTick = getTickCount()
        --         tempClose = progressBar
        --     end
        end
    end
end

function onClick(button, state, absX, absY, worldX, worldY, worldZ, clickedElement)
    if state == "down" then 
        if isElement(clickedElement) then 
            if clickedElement.type == "ped" and clickedElement:getData("ped >> shootingRange") then 
                if getDistanceBetweenPoints3D(localPlayer.position, clickedElement.position) < 2 then 
                    if not checkRender("renderMenu") then 
                        if not localPlayer:getData("hudVisible") then 
                            return 
                        end

                        playerStats = {}

                        start = true 
                        startTick = getTickCount()
                        page = 1
                        clickedPed = clickedElement
                        priceMultipler = tonumber(clickedElement:getData("ped >> priceMultipler"))

                        createRender("renderMenu", renderMenu)
                        removeEventHandler("onClientKey", root, onKey)
                        addEventHandler("onClientKey", root, onKey)

                        for key = 69, 79 do 
                            playerStats[key] = localPlayer:getStat(key)
                        end
                    end
                end
            elseif clickedElement:getData("ped >> decreasePed") then 
                if getDistanceBetweenPoints3D(localPlayer.position, clickedElement.position) < 2 then 
                    if not checkRender("renderMenu") then 
                        if not localPlayer:getData("hudVisible") then 
                            return 
                        end

                        playerStats = {}

                        start = true 
                        startTick = getTickCount()
                        page = 2
                        clickedPed = clickedElement

                        createRender("renderMenu", renderMenu)
                        removeEventHandler("onClientKey", root, onKey)
                        addEventHandler("onClientKey", root, onKey)

                        for key = 69, 79 do 
                            playerStats[key] = localPlayer:getStat(key)
                        end
                    end
                end
            end 
        end
    end
end
addEventHandler("onClientClick", root, onClick)

function renderClock()
    local font = getFont("Poppins-Medium", 16)
    local font2 = getFont("Poppins-Medium", 14)
    local minutesS = formatString(minutes)
    local secondsS = formatString(seconds)
    local x, y = sx - 70, sy - 50
    dxDrawText(minutesS..":"..secondsS, x, y + 1, x, y + 1, tocolor(0, 0, 0, 245), 1, font, "center", "top", false, false, false, true) -- Fent
    dxDrawText(minutesS..":"..secondsS, x, y - 1, x, y - 1, tocolor(0, 0, 0, 245), 1, font, "center", "top", false, false, false, true) -- Lent
    dxDrawText(minutesS..":"..secondsS, x - 1, y, x - 1, y, tocolor(0, 0, 0, 245), 1, font, "center", "top", false, false, false, true) -- Bal
    dxDrawText(minutesS..":"..secondsS, x + 1, y, x + 1, y, tocolor(0, 0, 0, 245), 1, font, "center", "top", false, false, false, true) -- Jobb
    local r, g, b = 242, 242, 242
    if minutes <= 3 then
        r, g, b = 255, 59, 59
    end
    dxDrawText(minutesS..":"..secondsS, x, y, x, y, tocolor(r, g, b, 255), 1, font, "center", "top")

    local redR, redG, redB = exports.cr_core:getServerColor("red", false)

    local buttonW, buttonH = 150, 20
    local buttonX, buttonY = sx - 70 - buttonW / 2 - 70 / 2, sy - 50 - buttonH - 15
    local inSlot = exports.cr_core:isInSlot(buttonX, buttonY, buttonW, buttonH)

    exitTrainingHover = nil

    local buttonColor = tocolor(redR, redG, redB, 255 * 0.7)
    local textColor = tocolor(255, 255, 255, 255 * 0.6)

    if inSlot then 
        exitTrainingHover = true

        buttonColor = tocolor(redR, redG, redB, 255)
        textColor = tocolor(255, 255, 255, 255)
    end

    dxDrawRectangle(buttonX, buttonY, buttonW, buttonH, buttonColor)
    dxDrawText("Lőtér elhagyása", buttonX, buttonY + 4, buttonX + buttonW, buttonY + buttonH, textColor, 1, font2, "center", "center")
end

function onTrainingKey(button, state)
    if button == "mouse1" and state then 
        if exitTrainingHover then 
            exitTrainingHover = false

            processTrainingEnd()
        end
    end
end

function processTraining()
    oldPosition = localPlayer.position
    oldInterior = localPlayer.interior 
    oldDimension = localPlayer.dimension
    oldFrozen = localPlayer.frozen
    playerDimension = localPlayer:getData("acc >> id")
    trainingType = clickedPed:getData("ped >> id")

    local index = 1

    for k, v in pairs(pedDatas) do 
        if not v.decreasePed and v.id == trainingType then 
            index = k

            break
        end
    end

    local x, y, z, rot = unpack(pedDatas[index]["shootingPosition"])

    localPlayer.position = Vector3(x, y, z)
    localPlayer.rotation = Vector3(0, 0, rot)
    localPlayer.frozen = true

    triggerLatentServerEvent("changePlayerDimension", 5000, false, localPlayer, localPlayer, playerDimension)

    targetObjects = {}
    moveDatas = {
        ["moves"] = {},
        ["timers"] = {},
        ["datas"] = {},
    }

    localPlayer:setData("char >> inTraining", true)
    inTraining = true
    currentSkillPoints = 0
    neededSkillPoints = weapons[_selectedWeapon]["minPoints"]

    local yellowHex = getServerColor("lightyellow", true)
    addBox("warning", "A gyakorlat elkezdődött! Ahhoz hogy teljesítsd a minimumot el kell érj "..yellowHex..neededSkillPoints.."#f2f2f2 pontot!")

    removeEventHandler("onClientPlayerWeaponFire", root, handleWeaponFire)
    addEventHandler("onClientPlayerWeaponFire", root, handleWeaponFire)

    local colorCode = '#ff3b3b'
    local text = "#f2f2f2Pontok: "..colorCode..currentSkillPoints.."#f2f2f2/"..colorCode..neededSkillPoints
    exports['cr_dx']:startInfoBar(text)

    minutes = 10
    seconds = 0

    createRender("renderClock", renderClock)

    removeEventHandler("onClientKey", root, onTrainingKey)
    addEventHandler("onClientKey", root, onTrainingKey)

    clockTimer = setTimer(
        function()
            seconds = seconds - 1
            if seconds <= 0 then 
                seconds = 59
                minutes = minutes - 1
                if minutes < 0 then 
                    minutes = 0

                    processTrainingEnd()
                end
            end
        end, 1000, 0
    )


    --for key, value in pairs(targets[trainingType]) do 
    currentObjectID = 1
    local value = targets[trainingType][currentObjectID]

    createHitableObject(value)
    --end
end

function createHitableObject(value)
    local x, y, z, rot = unpack(value["position"])

    local object = Object(value["model"], x, y, z, 0, 0, rot)
    object:setData("training >> id", key)
    object:setBreakable(false)
    object:setInterior(value["interior"])
    object:setDimension(playerDimension)

    if value["moving"] then 
        local objPosition = object.position

        if value["moveLeftRight"] then 
            if not moveDatas["timers"][object] or not isTimer(moveDatas["timers"][object]) then 
                if not moveDatas["datas"][object] then 
                    moveDatas["datas"][object] = {
                        ["oldRandom"] = 0,
                    }
                end

                local randomValue = math.random(1, 2)
                moveDatas["datas"][object]["oldRandom"] = randomValue

                if randomValue == 1 then 
                    moveDatas["moves"][object] = object:move(value["time"], objPosition.x, objPosition.y + 1, objPosition.z, 0, 0, 0, "InOutQuad")
                else 
                    moveDatas["moves"][object] = object:move(value["time"], objPosition.x, objPosition.y - 1, objPosition.z, 0, 0, 0, "InOutQuad")
                end

                moveDatas["timers"][object] = setTimer(
                    function(value)
                        processObjectMove(object, value)
                    end, value["time"] + 1, 0, value
                )
            end
        elseif value["moveForward"] then 
            moveDatas["moves"][object] = object:move(value["time"], objPosition.x - 7, objPosition.y, objPosition.z, 0, 0, 0, "InOutQuad")
        else 
            moveDatas["moves"][object] = object
        end
    end

    targetObjects[object] = object
end 

function processObjectMove(object, value)
    local randomValue = math.random(1, 2)
    local objPosition = object.position

    if moveDatas["datas"][object]["oldRandom"] == randomValue then 
        return processObjectMove(object, value)
    end

    moveDatas["datas"][object]["oldRandom"] = randomValue

    if randomValue == 1 then 
        moveDatas["moves"][object] = object:move(value["time"], objPosition.x, objPosition.y + 1, objPosition.z, 0, 0, 0, "InOutQuad")
    else 
        moveDatas["moves"][object] = object:move(value["time"], objPosition.x, objPosition.y - 1, objPosition.z, 0, 0, 0, "InOutQuad")
    end
end

function processTrainingEnd()
    localPlayer.position = oldPosition
    localPlayer.interior = oldInterior 
    localPlayer.frozen = oldFrozen

    triggerLatentServerEvent("changePlayerDimension", 5000, false, localPlayer, localPlayer, oldDimension)

    exports['cr_dx']:closeInfoBar()

    for key, value in pairs(targetObjects) do 
        if isElement(value) then 
            if moveDatas["timers"][value] and isTimer(moveDatas["timers"][value]) then 
                killTimer(moveDatas["timers"][value])
                moveDatas["timers"][value] = nil 
            end

            value:destroy()
        end
    end

    if clockTimer and isTimer(clockTimer) then 
        killTimer(clockTimer)
        clockTimer = nil
    end

    destroyRender("renderClock")
    removeEventHandler("onClientKey", root, onTrainingKey)

    targetObjects = {}
    moveDatas = {
        ["moves"] = {},
        ["timers"] = {},
        ["datas"] = {},
    }

    if currentSkillPoints >= neededSkillPoints then 
        local currentStat = localPlayer:getStat(weapons[_selectedWeapon]["statId"])
        local greenHex = getServerColor("green", true)
        triggerLatentServerEvent("changePlayerStats", 5000, false, localPlayer, localPlayer, weapons[_selectedWeapon]["statId"], currentStat + 10)

        addBox("success", "Sikeresen teljesítetted a gyakorlatot, szereztél "..greenHex.."10 #f2f2f2skill pontot.")

        _selectedWeapon = nil
    else 
        addBox("error", "Nem sikerült elérned a minimum ponthatárt, ezért megbuktál a gyakorlaton.")
    end

    localPlayer:setData("char >> inTraining", false)
    currentSkillPoints = 0
    neededSkillPoints = 0

    collectgarbage("collect")
end

function handleWeaponFire(weapon, ammo, ammoInClip, hitX, hitY, hitZ, hitElement)
    if source:getData("char >> inTraining") then 
        if hitElement then 
            if targetObjects[hitElement] and weapon == weapons[_selectedWeapon].id then
                if moveDatas["moves"][hitElement] then 
                    hitElement:stop()
                    moveDatas["moves"][hitElement] = nil

                    if moveDatas["timers"][hitElement] and isTimer(moveDatas["timers"][hitElement]) then 
                        killTimer(moveDatas["timers"][hitElement])
                        moveDatas["timers"][hitElement] = nil 
                    end
                end

                targetObjects[hitElement] = nil 
                hitElement:destroy()

                currentObjectID = currentObjectID + 1
                if currentObjectID > #targets[trainingType] then 
                    currentObjectID = 1
                end 
                local value = targets[trainingType][currentObjectID]

                createHitableObject(value)

                local colorCode = '#ff3b3b'
                local text = "#f2f2f2Pontok: "..colorCode..(currentSkillPoints + 1).."#f2f2f2/"..colorCode..neededSkillPoints
                exports['cr_dx']:setInfoBarText(text)

                if currentSkillPoints + 1 >= neededSkillPoints then 
                    currentSkillPoints = currentSkillPoints + 1
                    
                    processTrainingEnd()
                else 
                    currentSkillPoints = currentSkillPoints + 1
                end

                collectgarbage("collect")
            end
        end
    end
end

function scrollDown()
    if checkRender("renderMenu") then 
        if maxLines + 1 <= #weapons then
            minLines = minLines + 1
            maxLines = maxLines + 1
        end
    end
end

function scrollUP()
    if checkRender("renderMenu") then 
        if minLines - 1 >= 1 then
            minLines = minLines - 1
            maxLines = maxLines - 1
        end
    end
end

-- UTILS

function dxDrawOuterBorder(x, y, w, h, borderSize, borderColor, postGUI)
	borderSize = borderSize or 2
	borderColor = borderColor or tocolor(0, 0, 0, 255)
	
	dxDrawRectangle(x - borderSize, y - borderSize, w + (borderSize * 2), borderSize, borderColor, postGUI)
	dxDrawRectangle(x, y + h, w, borderSize, borderColor, postGUI)
	dxDrawRectangle(x - borderSize, y, borderSize, h + borderSize, borderColor, postGUI)
	dxDrawRectangle(x + w, y, borderSize, h + borderSize, borderColor, postGUI)
end

function formatMoney(value)
    return exports["cr_dx"]:formatMoney(value)
end

function isInSlot(x, y, w, h)
    return exports["cr_core"]:isInSlot(x, y, w, h)
end

function getFont(font, size)
    return exports["cr_fonts"]:getFont(font, size)
end

function getServerColor(color, type)
    return exports["cr_core"]:getServerColor(color, type)
end

function addBox(type, ...)
    return exports["cr_infobox"]:addBox(type, ...)
end

function dxDrawImageWithText(imagePath, text, x, y, w, h, imageColor, textColor, imageW, imageH, textScale, textFont, between)
    return exports["cr_dx"]:dxDrawImageWithText(imagePath, text, x, y, w, h, imageColor, textColor, imageW, imageH, textScale, textFont, between)
end

function formatString(n)
    if n < 10 then
        n = "0"..n
    end
    return n
end

function getPlayerStats(statId)
    if playerStats[statId] then 
        return playerStats[statId]
    end

    return 0 
end

function getNetworkStatus()
    return exports["cr_network"]:getNetworkStatus()
end

function hasMoney(thePlayer, value, bank)
    return exports["cr_core"]:hasMoney(thePlayer, value, bank)
end

function takeMoney(thePlayer, value, bank)
    return exports["cr_core"]:takeMoney(thePlayer, value, bank)
end