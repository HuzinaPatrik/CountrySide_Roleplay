local screenX, screenY = guiGetScreenSize()
local dxDrawMultiplier = math.min(1, screenX / 1280)

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

local panelHover = false
local hoverService = false
local selectedService = false

local currentButtonHover = false
local historyHover = false

local hoverKey = false
local historyActive = false

local scrollingHover = false
local scrolling = false

local textureDeleteTimer = false

local walletHistory = {}
local phoneData = false

local startedInteraction = false
local lastInteraction = 0
local interactionDelayTime = 1000

local amountToTake = false
local plusMoneyToAdd = false

local alpha = 255
local textures = {}

function createTextures()
    textures = {}

    textures.logo = ":cr_walletreplenishment/files/images/logo.png"
    textures.log = ":cr_walletreplenishment/files/images/log.png"
    textures.log_active = ":cr_walletreplenishment/files/images/log_active.png"

    textures.keyPadBtn = ":cr_walletreplenishment/files/images/keypadbtn.png"
    textures.keyPadBtn_active = ":cr_walletreplenishment/files/images/keypadbtn_active.png"
    textures.deleteBtnIcon = ":cr_walletreplenishment/files/images/deletebtnicon.png"
end

function destroyTextures()
    textures = {}
    collectgarbage("collect")
end

local selectedWalletPed = false

function renderWallet()
    local alpha, progress = exports.cr_dx:getFade("walletPanel")
    
    if alpha and progress then 
        if alpha <= 0 and progress >= 1 then 
            destroyRender("renderWallet")
            manageTextbars("destroy")

            selectedService = false
            historyActive = false
            startedInteraction = false
            selectedWalletPed = false

            if isTimer(textureDeleteTimer) then 
                killTimer(textureDeleteTimer)
                textureDeleteTimer = nil
            end

            textureDeleteTimer = setTimer(destroyTextures, 500, 1)
        end
    end

    if isElement(selectedWalletPed) then 
        local playerX, playerY, playerZ = getElementPosition(localPlayer)
        local pedX, pedY, pedZ = getElementPosition(selectedWalletPed)
        local distance = getDistanceBetweenPoints3D(playerX, playerY, playerZ, pedX, pedY, pedZ)

        if distance > 3 then 
            if not startedInteraction then 
                startedInteraction = true

                manageWallet("exit")
            end
        end
    end

    local font = exports.cr_fonts:getFont("Poppins-SemiBold", getRealFontSize(16))
    local font2 = exports.cr_fonts:getFont("Poppins-Medium", getRealFontSize(14))
    local font3 = exports.cr_fonts:getFont("Poppins-Regular", getRealFontSize(12))
    local font4 = exports.cr_fonts:getFont("Poppins-Bold", getRealFontSize(12))
    local font5 = exports.cr_fonts:getFont("Poppins-SemiBold", getRealFontSize(13))
    local font6 = exports.cr_fonts:getFont("Poppins-Bold", getRealFontSize(14))
    local font7 = exports.cr_fonts:getFont("Poppins-Medium", getRealFontSize(12))

    local redR, redG, redB = exports.cr_core:getServerColor("red", false)
    local greenR, greenG, greenB = exports.cr_core:getServerColor("green", false)
    local greenHex = exports.cr_core:getServerColor("green", true)

    local bgW, bgH = resp(400), selectedService and not historyActive and resp(350) or historyActive and resp(410) or resp(155)
    local bgX, bgY = screenX / 2 - bgW / 2, screenY / 2 - bgH / 2

    dxDrawRectangle(bgX, bgY, bgW, bgH, tocolor(51, 51, 51, alpha * 0.8))

    local logoW, logoH = resp(26), resp(30)
    local logoX, logoY = bgX + resp(10), bgY + resp(8)

    exports.cr_dx:dxDrawImageAsTexture(logoX, logoY, logoW, logoH, textures.logo, 0, 0, 0, tocolor(255, 255, 255, alpha))
    dxDrawText("Egyenleg feltöltés", logoX + logoW + resp(10), logoY + resp(4), logoX + logoW, logoY + logoH, tocolor(255, 255, 255, alpha), 1, font, "left", "center")

    local logW, logH = resp(24), resp(24)
    local logX, logY = bgX + bgW - logW - resp(2), bgY + resp(2)

    historyHover = nil

    local hoverW, hoverH = resp(16), resp(17)
    local hoverX, hoverY = logX + resp(3), logY + resp(5)
    local inSlot = exports.cr_core:isInSlot(hoverX, hoverY, hoverW, hoverH)

    local logImage = textures.log

    if inSlot then 
        historyHover = true
        logImage = textures.log_active
    else
        if historyActive then 
            logImage = textures.log_active
        end
    end

    exports.cr_dx:dxDrawImageAsTexture(logX, logY, logW, logH, logImage, 0, 0, 0, tocolor(255, 255, 255, alpha))

    currentButtonHover = nil

    if not historyActive then 
        dxDrawText("Kérlek válassz szolgáltatót", logoX + resp(5), logoY, logoX + logoW, logoY + logoH + resp(30), tocolor(255, 255, 255, alpha), 1, font2, "left", "bottom")

        local buttonW, buttonH = resp(110), resp(25)
        local buttonX, buttonY = bgX + resp(25), logoY + buttonH + resp(45)
        local _buttonH = buttonH
        local _buttonY = buttonY

        hoverService = nil

        for i = serviceMinLine, serviceMaxLine do 
            local v = availableServices[i]
            local inSlot = exports.cr_core:isInSlot(buttonX, buttonY, buttonW, buttonH)

            local buttonColor = tocolor(51, 51, 51, alpha * 0.8)
            local buttonTextColor = tocolor(255, 255, 255, alpha * 0.8)
            local buttonFont = font3

            if inSlot then 
                hoverService = i

                buttonColor = tocolor(242, 242, 242, alpha)
                buttonTextColor = tocolor(51, 51, 51, alpha)
                buttonFont = font4
            else
                if selectedService == i then 
                    buttonColor = tocolor(242, 242, 242, alpha)
                    buttonTextColor = tocolor(51, 51, 51, alpha)
                    buttonFont = font4
                end
            end
            
            dxDrawRectangle(buttonX, buttonY, buttonW, buttonH, buttonColor)

            if v then 
                dxDrawText(v.name, buttonX, buttonY + resp(2), buttonX + buttonW, buttonY + buttonH, buttonTextColor, 1, buttonFont, "center", "center")
            end

            buttonX = buttonX + buttonW + resp(10)
        end

        if not selectedService then 
            local buttonW, buttonH = resp(150), resp(20)
            local buttonX, buttonY = bgX + bgW / 2 - buttonW / 2, bgY + bgH - buttonH - resp(15)
            local inSlot = exports.cr_core:isInSlot(buttonX, buttonY, buttonW, buttonH)

            local cancelButtonColor = tocolor(redR, redG, redB, alpha * 0.7)
            local cancelButtonTextColor = tocolor(255, 255, 255, alpha * 0.6)

            if inSlot then 
                currentButtonHover = "cancelButton"

                cancelButtonColor = tocolor(redR, redG, redB, alpha)
                cancelButtonTextColor = tocolor(255, 255, 255, alpha)
            end

            dxDrawRectangle(buttonX, buttonY, buttonW, buttonH, cancelButtonColor)
            dxDrawText("Mégse", buttonX, buttonY + resp(2), buttonX + buttonW, buttonY + buttonH, cancelButtonTextColor, 1, font2, "center", "center")
        else 
            local buttonW, buttonH = resp(150), resp(20)
            local buttonX, buttonY = bgX + resp(45), bgY + bgH - buttonH - resp(15)
            local inSlot = exports.cr_core:isInSlot(buttonX, buttonY, buttonW, buttonH)

            local depositButtonColor = tocolor(greenR, greenG, greenB, alpha * 0.7)
            local depositButtonTextColor = tocolor(255, 255, 255, alpha * 0.6)

            if inSlot then 
                currentButtonHover = "depositButton"

                depositButtonColor = tocolor(greenR, greenG, greenB, alpha)
                depositButtonTextColor = tocolor(255, 255, 255, alpha)
            end

            local buttonText = phoneData.service ~= availableServices[selectedService].name and "Szolgáltató váltás" or "Feltöltés"

            dxDrawRectangle(buttonX, buttonY, buttonW, buttonH, depositButtonColor)
            dxDrawText(buttonText, buttonX, buttonY + resp(2), buttonX + buttonW, buttonY + buttonH, depositButtonTextColor, 1, font2, "center", "center")

            local buttonX = bgX + bgW - buttonW - resp(45)
            local inSlot = exports.cr_core:isInSlot(buttonX, buttonY, buttonW, buttonH)

            local cancelButtonColor = tocolor(redR, redG, redB, alpha * 0.7)
            local cancelButtonTextColor = tocolor(255, 255, 255, alpha * 0.6)

            if inSlot then 
                currentButtonHover = "cancelButton"

                cancelButtonColor = tocolor(redR, redG, redB, alpha)
                cancelButtonTextColor = tocolor(255, 255, 255, alpha)
            end

            dxDrawRectangle(buttonX, buttonY, buttonW, buttonH, cancelButtonColor)
            dxDrawText("Mégse", buttonX, buttonY + resp(2), buttonX + buttonW, buttonY + buttonH, cancelButtonTextColor, 1, font2, "center", "center")

            local inputFieldW, inputFieldH = resp(150), resp(20)
            local inputFieldX, inputFieldY = bgX + bgW / 2 - inputFieldW / 2, _buttonY + _buttonH + inputFieldH

            dxDrawRectangle(inputFieldX, inputFieldY, inputFieldW, inputFieldH, tocolor(51, 51, 51, alpha * 0.8))
            dxDrawText("Összeg:", inputFieldX + resp(4), inputFieldY + resp(4), inputFieldX + inputFieldW, inputFieldY + inputFieldH, tocolor(255, 255, 255, alpha * 0.6), 1, font5, "left", "center")

            local textWidth = dxGetTextWidth("Összeg:", 1, font5)

            dxDrawText("$", inputFieldX + resp(4) + textWidth + resp(5), inputFieldY + resp(4), inputFieldX + inputFieldW, inputFieldY + inputFieldH, tocolor(greenR, greenG, greenB, alpha), 1, font5, "left", "center")

            UpdatePos("wallet.amount", {inputFieldX + resp(4) + textWidth + resp(15), inputFieldY + resp(2), inputFieldW, inputFieldH})
            UpdateAlpha("wallet.amount", tocolor(255, 255, 255, alpha))

            local keyPadW, keyPadH = resp(48), resp(48)
            local keyPadStartX, keyPadStartY = inputFieldX + keyPadW / 4, inputFieldY + keyPadH / 2

            hoverKey = nil

            for i = keyPadMinLine, keyPadMaxLine - 1 do 
                local v = keyPad[i + 1]
                local keyPadX, keyPadY = keyPadStartX + (keyPadW - resp(6)) * (i % maxKeyInARow), keyPadStartY + (keyPadH - resp(13)) * (math.floor(i / maxKeyInAColumn))

                local currentImage = textures.keyPadBtn
                local textColor = tocolor(255, 255, 255, alpha * 0.6)
                local iconColor = tocolor(255, 255, 255, alpha * 0.6)

                local hoverW, hoverH = keyPadW - resp(13), keyPadH - resp(19)
                local hoverX, hoverY = keyPadX + resp(6), keyPadY + resp(10)
                local inSlot = exports.cr_core:isInSlot(hoverX, hoverY, hoverW, hoverH)

                if inSlot then 
                    hoverKey = i + 1

                    currentImage = textures.keyPadBtn_active
                    textColor = tocolor(255, 255, 255, alpha)
                    iconColor = tocolor(255, 255, 255, alpha)
                else
                    if getKeyState(v) then 
                        currentImage = textures.keyPadBtn_active
                        textColor = tocolor(255, 255, 255, alpha)
                        iconColor = tocolor(255, 255, 255, alpha)
                    end
                end

                exports.cr_dx:dxDrawImageAsTexture(keyPadX, keyPadY, keyPadW, keyPadH, currentImage, 0, 0, 0, tocolor(255, 255, 255, alpha))

                if v ~= "icon" then 
                    dxDrawText(v, keyPadX, keyPadY + resp(4), keyPadX + keyPadW, keyPadY + keyPadH, textColor, 1, font, "center", "center")
                else 
                    local iconW, iconH = resp(24), resp(24)
                    local iconX, iconY = keyPadX + iconW / 2, keyPadY + iconH / 2

                    exports.cr_dx:dxDrawImageAsTexture(iconX, iconY, iconW, iconH, textures.deleteBtnIcon, 0, 0, 0, iconColor)
                end
            end
        end
    else
        dxDrawText("Előzmények", logoX + resp(5), logoY, logoX + logoW, logoY + logoH + resp(30), tocolor(255, 255, 255, alpha), 1, font6, "left", "bottom")

        local lineW, lineH = bgW - resp(20), resp(20)
        local lineX, lineY = bgX + resp(10), logoY + logoH + lineH + resp(10)

        local scrollW, scrollH = resp(3), resp(108)
        local scrollX, scrollY = bgX + bgW - scrollW - resp(2), lineY

        scrollBarHover = exports.cr_core:isInSlot(scrollX, scrollY, scrollW, scrollH)
        
        -- Scrollbar

        dxDrawRectangle(scrollX, scrollY, scrollW, scrollH, tocolor(242, 242, 242, alpha * 0.6))

        local percent = #phoneData.simHistory

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

                        historyMinLine = math.max(1, math.floor(math.min(math.max(num, 1), (percent - _historyMaxLine) + 1)))
                        historyMaxLine = historyMinLine + (_historyMaxLine - 1)
                    end
                else
                    scrolling = false
                end
            end

            local multiplier = math.min(math.max((historyMaxLine - (historyMinLine - 1)) / percent, 0), 1)
            local multiplier2 = math.min(math.max((historyMinLine - 1) / percent, 0), 1)
            local gY = gY + ((gH) * multiplier2)
            local gH = gH * multiplier

            local r, g, b = 255, 59, 59
            dxDrawRectangle(gX, gY, gW, gH, tocolor(r, g, b, alpha))
        end

        panelHover = nil

        local hoverW, hoverH = lineW, resp(108)
        local hoverX, hoverY = lineX, lineY
        local inSlot = exports.cr_core:isInSlot(hoverX, hoverY, hoverW, hoverH)
        if inSlot then 
            panelHover = true
        end

        for i = historyMinLine, historyMaxLine do 
            local v = phoneData.simHistory[i]

            local lineColor = tocolor(51, 51, 51, alpha * 0.29)
            local textColor = tocolor(255, 255, 255, alpha)

            local inSlot = exports.cr_core:isInSlot(lineX, lineY, lineW, lineH)
            if inSlot then 
                lineColor = tocolor(242, 242, 242, alpha)
                textColor = tocolor(51, 51, 51, alpha)
            end

            dxDrawRectangle(lineX, lineY, lineW, lineH, lineColor)

            if v then 
                local text = v.text

                local availableForHover = false
                local normalText = text

                if utf8.len(text) > 66 then 
                    text = (utf8.sub(text, 1, -(utf8.len(text) - 66)) .. "..."):gsub("#......", "")
                    availableForHover = true
                end

                if inSlot then 
                    text = text:gsub("#......", "#333333")
                end

                dxDrawText(text, lineX + resp(5), lineY + resp(4), lineX + lineW, lineY + lineH, textColor, 1, font7, "left", "center", false, false, false, true)

                if availableForHover then 
                    if inSlot then 
                        exports.cr_dx:drawTooltip(1, normalText)
                    end
                end
            end

            lineY = lineY + lineH + resp(2)
        end

        local buttonW, buttonH = resp(150), resp(20)
        local buttonX, buttonY = bgX + resp(45), bgY + bgH - buttonH - resp(15)
        local inSlot = exports.cr_core:isInSlot(buttonX, buttonY, buttonW, buttonH)

        local depositButtonColor = tocolor(greenR, greenG, greenB, alpha * 0.7)
        local depositButtonTextColor = tocolor(255, 255, 255, alpha * 0.6)

        if inSlot then 
            currentButtonHover = "depositButton"

            depositButtonColor = tocolor(greenR, greenG, greenB, alpha)
            depositButtonTextColor = tocolor(255, 255, 255, alpha)
        end

        local buttonText = phoneData.service ~= availableServices[selectedService].name and "Szolgáltató váltás" or "Feltöltés"

        dxDrawRectangle(buttonX, buttonY, buttonW, buttonH, depositButtonColor)
        dxDrawText(buttonText, buttonX, buttonY + resp(2), buttonX + buttonW, buttonY + buttonH, depositButtonTextColor, 1, font2, "center", "center")

        local buttonX = bgX + bgW - buttonW - resp(45)
        local inSlot = exports.cr_core:isInSlot(buttonX, buttonY, buttonW, buttonH)

        local cancelButtonColor = tocolor(redR, redG, redB, alpha * 0.7)
        local cancelButtonTextColor = tocolor(255, 255, 255, alpha * 0.6)

        if inSlot then 
            currentButtonHover = "cancelButton"

            cancelButtonColor = tocolor(redR, redG, redB, alpha)
            cancelButtonTextColor = tocolor(255, 255, 255, alpha)
        end

        dxDrawRectangle(buttonX, buttonY, buttonW, buttonH, cancelButtonColor)
        dxDrawText("Mégse", buttonX, buttonY + resp(2), buttonX + buttonW, buttonY + buttonH, cancelButtonTextColor, 1, font2, "center", "center")

        local buttonH = resp(25)
        local buttonX, buttonY = bgX + resp(25), logoY + buttonH + resp(45)

        local inputFieldW, inputFieldH = resp(150), resp(20)
        local inputFieldX, inputFieldY = bgX + bgW / 2 - inputFieldW / 2, lineY + (inputFieldH / 2)

        dxDrawRectangle(inputFieldX, inputFieldY, inputFieldW, inputFieldH, tocolor(51, 51, 51, alpha * 0.8))
        dxDrawText("Összeg:", inputFieldX + resp(4), inputFieldY + resp(4), inputFieldX + inputFieldW, inputFieldY + inputFieldH, tocolor(255, 255, 255, alpha * 0.6), 1, font5, "left", "center")

        local textWidth = dxGetTextWidth("Összeg:", 1, font5)

        dxDrawText("$", inputFieldX + resp(4) + textWidth + resp(5), inputFieldY + resp(4), inputFieldX + inputFieldW, inputFieldY + inputFieldH, tocolor(greenR, greenG, greenB, alpha), 1, font5, "left", "center")

        UpdatePos("wallet.amount", {inputFieldX + resp(4) + textWidth + resp(15), inputFieldY + resp(2), inputFieldW, inputFieldH})
        UpdateAlpha("wallet.amount", tocolor(255, 255, 255, alpha))

        local keyPadW, keyPadH = resp(48), resp(48)
        local keyPadStartX, keyPadStartY = inputFieldX + keyPadW / 4, inputFieldY + keyPadH / 2

        hoverKey = nil

        for i = keyPadMinLine, keyPadMaxLine - 1 do 
            local v = keyPad[i + 1]
            local keyPadX, keyPadY = keyPadStartX + (keyPadW - resp(6)) * (i % maxKeyInARow), keyPadStartY + (keyPadH - resp(13)) * (math.floor(i / maxKeyInAColumn))

            local currentImage = textures.keyPadBtn
            local textColor = tocolor(255, 255, 255, alpha * 0.6)
            local iconColor = tocolor(255, 255, 255, alpha * 0.6)

            local hoverW, hoverH = keyPadW - resp(13), keyPadH - resp(19)
            local hoverX, hoverY = keyPadX + resp(6), keyPadY + resp(10)
            local inSlot = exports.cr_core:isInSlot(hoverX, hoverY, hoverW, hoverH)

            if inSlot then 
                hoverKey = i + 1

                currentImage = textures.keyPadBtn_active
                textColor = tocolor(255, 255, 255, alpha)
                iconColor = tocolor(255, 255, 255, alpha)
            else
                if getKeyState(v) then 
                    currentImage = textures.keyPadBtn_active
                    textColor = tocolor(255, 255, 255, alpha)
                    iconColor = tocolor(255, 255, 255, alpha)
                end
            end

            exports.cr_dx:dxDrawImageAsTexture(keyPadX, keyPadY, keyPadW, keyPadH, currentImage, 0, 0, 0, tocolor(255, 255, 255, alpha))

            if v ~= "icon" then 
                dxDrawText(v, keyPadX, keyPadY + resp(4), keyPadX + keyPadW, keyPadY + keyPadH, textColor, 1, font, "center", "center")
            else 
                local iconW, iconH = resp(24), resp(24)
                local iconX, iconY = keyPadX + iconW / 2, keyPadY + iconH / 2

                exports.cr_dx:dxDrawImageAsTexture(iconX, iconY, iconW, iconH, textures.deleteBtnIcon, 0, 0, 0, iconColor)
            end
        end
    end
end

function onKey(button, state)
    if button == "mouse1" then 
        if state then 
            if hoverService then 
                if selectedService ~= hoverService then 
                    selectedService = hoverService
                end

                if not GetEdit("wallet.amount") then 
                    manageTextbars("create")
                end
            elseif historyHover then
                historyActive = not historyActive

                if not GetEdit("wallet.amount") then 
                    manageTextbars("create")
                else
                    if not historyActive and not selectedService then 
                        manageTextbars("destroy")
                    end
                end
            elseif currentButtonHover then
                if currentButtonHover == "cancelButton" then 
                    if not startedInteraction then 
                        startedInteraction = true

                        manageWallet("exit")
                    end
                elseif currentButtonHover == "depositButton" then
                    if lastInteraction + interactionDelayTime > getTickCount() or startedInteraction then 
                        return
                    end

                    if not selectedService then 
                        local syntax = exports.cr_core:getServerSyntax("Wallet", "error")

                        outputChatBox(syntax .. "Nincs kiválasztva szolgáltató.", 255, 0, 0, true)
                        return
                    end

                    local selectedShop = availableServices[selectedService]
                    local selectedServiceName = selectedShop.name

                    local selectedShopData = selectedShop.data
                    local pricePerCall = selectedShopData.pricePerCall
                    local pricePerSms = selectedShopData.pricePerSms
                    
                    local servicePrice = selectedShopData.servicePrice
                    local fullServicePrice = pricePerCall + pricePerSms + servicePrice
                    local oldService = phoneData.service

                    local amount = GetText("wallet.amount")
                    local plusMoney = 0
                    local yellowHex = exports.cr_core:getServerColor("yellow", true)
                    local redHex = exports.cr_core:getServerColor("red", true)
                    local fullAmount = fullServicePrice + plusMoney
                    amountToTake = fullAmount

                    local titleText = ""
                    local acceptButtonName = "Igen"
                    local cancelButtonName = "Nem"

                    if tonumber(amount) and tonumber(amount) > 0 then 
                        plusMoney = tonumber(amount)

                        if oldService == selectedServiceName then 
                            titleText = white .. "Egyenleget készülsz hozzáadni a " .. yellowHex .. exports.cr_phone:formatPhoneNumber(phoneData.myCallNumber) .. white .. " számhoz tartozó készülékhez. Hozzáadni kívánt egyenleg: $" .. yellowHex .. plusMoney

                            acceptButtonName = "Hozzáadás"
                            cancelButtonName = "Mégse"
                            fullAmount = fullServicePrice + plusMoney
                        end

                        amountToTake = plusMoney
                    end

                    local plusWalletText = plusMoney > 0 and white .. " (+ $" .. yellowHex .. plusMoney .. white .. " egyenleg)" or ""

                    if oldService ~= selectedServiceName then 
                        titleText = white .. "Biztosan a " .. yellowHex .. selectedServiceName .. white .. " szolgáltatót választod? A szolgáltatás, hívás, és az sms-ek ára összesen: " .. yellowHex .. "$" .. (fullAmount + plusMoney) .. plusWalletText .. "\n" .. redHex .. "FIGYELMEZTETÉS: " .. white .. "Új szolgáltatónál minden névjegyed, a hívásnaplód és üzeneted törlésre kerül!"

                        if utf8.len(plusWalletText) > 0 then 
                            fullAmount = fullServicePrice + plusMoney
                        end

                        amountToTake = fullAmount
                    else
                        fullAmount = plusMoney
                        amountToTake = fullAmount
                    end

                    if oldService == selectedServiceName and plusMoney <= 0 then 
                        local syntax = exports.cr_core:getServerSyntax("Wallet", "error")
                        local text = plusMoney <= 0 and "A feltölteni kívánt egyenlegnek nagyobbnak kell lennie mint 0." or "Már ennél a szolgáltatónál vagy."

                        outputChatBox(syntax .. text, 255, 0, 0, true)
                        return
                    end

                    exports.cr_dashboard:createAlert(
                        {
                            title = {titleText},
                            buttons = {
                                {
                                    name = acceptButtonName, 
                                    pressFunc = "wallet.updateWallet",
                                    color = {exports.cr_core:getServerColor("green", false)},
                                },

                                {
                                    name = cancelButtonName, 
                                    onClear = true,
                                    pressFunc = "wallet.resetWalletInteractions",
                                    color = {exports.cr_core:getServerColor("red", false)},
                                },
                            },
                        }
                    )

                    plusMoneyToAdd = plusMoney

                    startedInteraction = true
                    lastInteraction = getTickCount()
                end
            elseif hoverKey and keyPad[hoverKey] and not startedInteraction then
                local realText = GetText("wallet.amount")

                if keyPad[hoverKey] ~= "icon" and keyPad[hoverKey] ~= "X" then 
                    local realText = GetText("wallet.amount")
                    local text = realText == "0" and "" or realText
                    local value = keyPad[hoverKey]
                    
                    if utf8.len(text .. value) <= 5 then 
                        SetText("wallet.amount", text .. value)
                    end
                else
                    local text = utf8.sub(realText, 1, -2)

                    SetText("wallet.amount", text)
                end
            elseif historyActive then
                if scrollingHover then 
                    if not scrolling then 
                        scrolling = true
                    end
                end
            end
        else
            if scrolling then 
                scrolling = false
            end
        end
    elseif button == "mouse_wheel_down" then
        if state then 
            scrollDown()
        end
    elseif button == "mouse_wheel_up" then
        if state then 
            scrollUP()
        end
    end
end

function getPhoneSlot(givedValue)
    local items = exports.cr_inventory:getItems(localPlayer, 1)
    local result = false 

    if items then 
        for slot, data in pairs(items) do 
            local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)

            if itemid == 15 then 
                if tonumber(value) == tonumber(givedValue) then 
                    result = slot 
                    break 
                end
            end
        end
    end

    return result
end

function updateWallet()
    startedInteraction = false

    local currentSlot = getPhoneSlot(phoneData.myCallNumber)
    triggerLatentServerEvent("wallet.updateWallet", 5000, false, localPlayer, phoneData, currentSlot, selectedService, amountToTake, plusMoneyToAdd)

    amountToTake = false
    plusMoneyToAdd = false

    manageWallet("exit")
end
addEvent("wallet.updateWallet", true)
addEventHandler("wallet.updateWallet", root, updateWallet)

function resetWalletInteractions()
    amountToTake = false
    plusMoneyToAdd = false
    startedInteraction = false
end
addEvent("wallet.resetWalletInteractions", true)
addEventHandler("wallet.resetWalletInteractions", root, resetWalletInteractions)

function manageWallet(state)
    if state == "init" then 
        manageTextbars("create")
        createTextures()
        createRender("renderWallet", renderWallet)

        removeEventHandler("onClientKey", root, onKey)
        addEventHandler("onClientKey", root, onKey)

        exports.cr_dx:startFade("walletPanel", 
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
    elseif state == "exit" then
        removeEventHandler("onClientKey", root, onKey)

        exports.cr_dx:startFade("walletPanel", 
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
    end
end

function updateDatas(nbt, value, element)
    if not checkRender("renderWallet") and type(nbt) == "table" and value and element then 
        startedInteraction = false
        selectedWalletPed = element

        local serviceName = nbt.service
        local index = getServiceIndex(serviceName)

        if index then 
            selectedService = index
        end

        manageWallet("init")

        phoneData = nbt
        phoneData.myCallNumber = tonumber(value)
    end
end

function scrollDown()
    if historyActive then 
        if panelHover then 
            local percent = #phoneData.simHistory

            if historyMaxLine + 1 <= percent then 
                historyMinLine = historyMinLine + 1
                historyMaxLine = historyMaxLine + 1
            end
        end
    end
end

function scrollUP()
    if historyActive then 
        if panelHover then 
            if historyMinLine - 1 >= 1 then
                historyMinLine = historyMinLine - 1
                historyMaxLine = historyMaxLine - 1
            end
        end
    end
end

function manageTextbars(state)
    if state == "create" then 
        CreateNewBar("wallet.amount", {0, 0, 0, 0}, {5, "0", true, tocolor(255, 255, 255), {"Poppins-SemiBold", getRealFontSize(13)}, 1, "left", "center", false}, 1)
    elseif state == "destroy" then
        Clear()
    end
end