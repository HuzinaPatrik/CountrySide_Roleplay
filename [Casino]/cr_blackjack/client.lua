local screenX, screenY = guiGetScreenSize()

local alpha = 255

playerCoins = {}
local hoverCoin = false

local closeHover = false
local buyHover = false
local sellHover = false

local isRender = false
local selectedElement = false
local lastCoinTick = -10000

local lastTableTick = 0

function resetCoins()
    for i = 1, #availableCoins do 
        if availableCoins[i] then 
            availableCoins[i].count = 0
        end
    end
end

function renderCoinShop()
    if isElement(selectedElement) then 
        local playerX, playerY, playerZ = getElementPosition(localPlayer)

        if getDistanceBetweenPoints3D(playerX, playerY, playerZ, getElementPosition(selectedElement)) > 3 then 
            if isRender then 
                isRender = false
                manageCoinShop("exit")
            end
        end
    end

    local alpha, progress = exports.cr_dx:getFade("coinShop")

    if alpha and progress then 
        if progress >= 1 and alpha <= 0 then 
            destroyRender("renderCoinShop")
            
            selectedElement = false
            closeHover = false
            -- playerCoins = {}

            resetCoins()
            return
        end
    end

    local font = exports.cr_fonts:getFont("Poppins-SemiBold", 16)
    local font2 = exports.cr_fonts:getFont("Poppins-SemiBold", 14)
    local font3 = exports.cr_fonts:getFont("Poppins-Medium", 14)
    local font4 = exports.cr_fonts:getFont("Poppins-Regular", 12)

    local greenR, greenG, greenB = exports.cr_core:getServerColor("green", false)
    local redR, redG, redB = exports.cr_core:getServerColor("red", false)

    local panelW, panelH = 295, 340
    local panelX, panelY = screenX / 2 - panelW / 2, screenY / 2 - panelH / 2

    dxDrawRectangle(panelX, panelY, panelW, panelH, tocolor(51, 51, 51, alpha * 0.8))

    local logoW, logoH = 26, 30
    local logoX, logoY = panelX + 10, panelY + 8

    dxDrawImage(logoX, logoY, logoW, logoH, "files/images/logo.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
    dxDrawText("Blackjack", logoX + logoW + 10, logoY + 4, logoX + logoW, logoY + logoH, tocolor(255, 255, 255, alpha), 1, font, "left", "center")

    local closeW, closeH = 15, 15
    local closeX, closeY = panelX + panelW - 10 - 15, panelY + 10
    local imageColor = tocolor(255, 59, 59, alpha * 0.6)
    local inSlot = exports.cr_core:isInSlot(closeX, closeY, closeW, closeH)
    
    closeHover = nil

    if inSlot then 
        closeHover = true
        imageColor = tocolor(255, 59, 59, alpha)
    end

    dxDrawImage(closeX, closeY, closeW, closeH, "files/images/close.png", 0, 0, 0, imageColor)

    local buttonW, buttonH = 120, 20
    local buttonX, buttonY = panelX + 20, panelY + panelH - buttonH - 15

    local buttonColor = tocolor(greenR, greenG, greenB, alpha * 0.7)
    local textColor = tocolor(255, 255, 255, alpha * 0.6)
    local inSlot = exports.cr_core:isInSlot(buttonX, buttonY, buttonW, buttonH)

    buyHover = nil

    if inSlot then
        buyHover = true 
        buttonColor = tocolor(greenR, greenG, greenB, alpha)
        textColor = tocolor(255, 255, 255, alpha)
    end

    dxDrawRectangle(buttonX, buttonY, buttonW, buttonH, buttonColor)
    dxDrawText("Vásárlás", buttonX, buttonY + 4, buttonX + buttonW, buttonY + buttonH, textColor, 1, font3, "center", "center")

    local sellButtonW, sellButtonH = 120, 20
    local sellButtonX, sellButtonY = panelX + panelW - sellButtonW - 20, buttonY
    
    local sellButtonColor = tocolor(redR, redG, redB, alpha * 0.7)
    local sellTextColor = tocolor(255, 255, 255, alpha * 0.6)
    local inSlot = exports.cr_core:isInSlot(sellButtonX, sellButtonY, sellButtonW, sellButtonH)

    sellHover = nil

    if inSlot then
        sellHover = true 
        sellButtonColor = tocolor(redR, redG, redB, alpha)
        sellTextColor = tocolor(255, 255, 255, alpha)
    end

    dxDrawRectangle(sellButtonX, sellButtonY, sellButtonW, sellButtonH, sellButtonColor)
    dxDrawText("Eladás", sellButtonX, sellButtonY + 4, sellButtonX + sellButtonW, sellButtonY + sellButtonH, sellTextColor, 1, font3, "center", "center")

    local coinW, coinH = 20, 20
    local coinX, startY = logoX + 3, logoY + 30 + coinH

    local coinSecondRowX, coinSecondRowY = logoX - 10 + panelW / 8, panelY + panelH - coinH - 80
    local allPrice = 0

    hoverCoin = nil

    for i = 1, #availableCoins do 
        local v = availableCoins[i]

        if fileExists("files/images/coins/" .. v.value .. ".png") then 
            dxDrawImage(coinX, startY, coinW, coinH, "files/images/coins/" .. v.value .. ".png", 0, 0, 0, tocolor(255, 255, 255, alpha))
            dxDrawText("$" .. v.value .. " zseton", coinX + coinW + 15, startY + 4, coinX + coinW, startY + coinH, tocolor(255, 255, 255, alpha), 1, font2, "left", "center")

            local minusBgW, minusBgH = 20, 20
            local minusBgX, minusBgY = panelX + panelW - minusBgW - 80, startY
            local inSlot = exports.cr_core:isInSlot(minusBgX, minusBgY, minusBgW, minusBgH)
            local currentMinusImage = ":cr_blackjack/files/images/minus_bg.png"

            if inSlot then 
                currentMinusImage = ":cr_blackjack/files/images/minus_bg_active.png"
                hoverCoin = i .. ":decrease"
            end

            exports.cr_dx:dxDrawImageAsTexture(minusBgX, minusBgY, minusBgW, minusBgH, currentMinusImage, 0, 0, 0, tocolor(255, 255, 255, alpha))

            local middleBgW, middleBgH = 20, 20
            local middleBgX, middleBgY = panelX + panelW - middleBgW - 60, minusBgY

            exports.cr_dx:dxDrawImageAsTexture(middleBgX, middleBgY, middleBgW, middleBgH, ":cr_blackjack/files/images/bg_middle.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
            dxDrawText(v.count, middleBgX, middleBgY + 4, middleBgX + middleBgW, middleBgY + middleBgH, tocolor(255, 255, 255, alpha), 1, font2, "center", "center")

            local plusBgW, plusBgH = 20, 20
            local plusBgX, plusBgY = panelX + panelW - plusBgW - 40, minusBgY
            local inSlot = exports.cr_core:isInSlot(plusBgX, plusBgY, plusBgW, plusBgH)
            local currentPlusImage = ":cr_blackjack/files/images/plus_bg.png"

            if inSlot then 
                currentPlusImage = ":cr_blackjack/files/images/plus_bg_active.png"
                hoverCoin = i .. ":increase"
            end

            exports.cr_dx:dxDrawImageAsTexture(plusBgX, plusBgY, plusBgW, plusBgH, currentPlusImage, 0, 0, 0, tocolor(255, 255, 255, alpha))

            -- Alsó sor

            local count = playerCoins[v.value] and playerCoins[v.value] or 0

            dxDrawImage(coinSecondRowX, coinSecondRowY, coinW, coinH, "files/images/coins/" .. v.value .. ".png", 0, 0, 0, tocolor(255, 255, 255, alpha))
            dxDrawText(count .. " db", coinSecondRowX, coinSecondRowY + 20, coinSecondRowX + coinW, coinSecondRowY + coinH, tocolor(255, 255, 255, alpha), 1, font4, "center", "top")

            allPrice = allPrice + (v.value * v.count)
        end

        coinSecondRowX = coinSecondRowX + coinW + 20
        startY = startY + coinH + 4
    end

    dxDrawText("Összesen: $" .. allPrice, panelX, panelY + 100, panelX + panelW, panelY + panelH, tocolor(255, 255, 255, alpha), 1, font2, "center", "center")
end

function onKey(button, state)
    if button == "mouse1" and state then 
        if hoverCoin then 
            local selected = split(hoverCoin, ":")
            local index = tonumber(selected[1])

            if selected[2] == "decrease" then 
                availableCoins[index].count = math.max(0, availableCoins[index].count - 1)
            elseif selected[2] == "increase" then
                availableCoins[index].count = math.min(999, availableCoins[index].count + 1)
            end
        elseif closeHover then
            if isRender then 
                isRender = false

                manageCoinShop("exit")
            end
        elseif buyHover then
            if isRender then
                local allPrice = 0
                local newCoins = table.copy(playerCoins)
                
                for i = 1, #availableCoins do 
                    local v = availableCoins[i]

                    if v.count > 0 then 
                        if not newCoins[v.value] then 
                            newCoins[v.value] = 0
                        end

                        newCoins[v.value] = newCoins[v.value] + v.count

                        allPrice = allPrice + (v.value * v.count)
                    end
                end

                if allPrice <= 0 then 
                    exports.cr_infobox:addBox("error", "Minimum 1 zsetont kell venned.")

                    return
                end

                if exports.cr_core:hasMoney(localPlayer, allPrice) then 
                    if exports.cr_network:getNetworkStatus() then 
                        return
                    end

                    local nowTick = getTickCount()
                    local count = 10

                    if nowTick <= lastCoinTick + count * 1000 then
                        return
                    end

                    lastCoinTick = getTickCount()

                    exports.cr_core:takeMoney(localPlayer, allPrice, false)
                    exports.cr_logs:addLog(localPlayer, "Blackjack", "buyCoins", exports.cr_admin:getAdminName(localPlayer) .. " vásárolt coinokat " .. allPrice .. " értékben.")
                    triggerLatentServerEvent("giveMoneyToFaction", 5000, false, localPlayer, localPlayer, 4, math.floor(allPrice * 0.05)) -- GOVERMENT MONEY GIVING

                    exports.cr_infobox:addBox("success", "Sikeresen megvásároltad a zsetonokat!")

                    localPlayer:setData("char >> blackJackCoins", newCoins)
                    playerCoins = newCoins

                    resetCoins()
                else
                    exports.cr_infobox:addBox("error", "Nincs elég pénzed a zsetonok megvásárlásához!")
                end
            end
        elseif sellHover then
            if isRender then
                local allPrice = 0
                local newCoins = table.copy(playerCoins)
                
                for i = 1, #availableCoins do 
                    local v = availableCoins[i]

                    if v.count > 0 then 
                        if playerCoins[v.value] then 
                            if playerCoins[v.value] >= v.count then 
                                newCoins[v.value] = math.max(0, newCoins[v.value] - v.count)
                                allPrice = allPrice + (v.value * v.count)
                            end
                        end
                    end
                end

                if allPrice <= 0 then 
                    exports.cr_infobox:addBox("error", "Nincs ennyi zsetonod, amennyit el szeretnél adni.")

                    return
                end

                if exports.cr_network:getNetworkStatus() then 
                    return
                end

                local nowTick = getTickCount()
                local count = 10

                if nowTick <= lastCoinTick + count * 1000 then
                    return
                end

                lastCoinTick = getTickCount()

                exports.cr_core:giveMoney(localPlayer, allPrice, false)
                exports.cr_logs:addLog(localPlayer, "Blackjack", "sellCoins", exports.cr_admin:getAdminName(localPlayer) .. " eladott coinokat " .. allPrice .. " értékben.")
                exports.cr_infobox:addBox("success", "Sikeresen eladtad a kiválasztott zsetonokat!")

                localPlayer:setData("char >> blackJackCoins", newCoins)
                playerCoins = newCoins

                resetCoins()
            end
        end
    end
end

function manageCoinShop(state)
    if state == "init" then 
        exports.cr_dx:startFade("coinShop", 
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

        createRender("renderCoinShop", renderCoinShop)
        addEventHandler("onClientKey", root, onKey)
    elseif state == "exit" then
        exports.cr_dx:startFade("coinShop", 
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

function onClick(button, state, absX, absY, worldX, worldY, worldZ, clickedElement)
    if button ~= "middle" then 
        if isElement(clickedElement) then 
            if clickedElement:getData("coin >> dealer") and getDistanceBetweenPoints3D(localPlayer.position, clickedElement.position) <= 2 then 
                if not isRender and not closeHover then 
                    isRender = true
                    selectedElement = clickedElement
                    playerCoins = localPlayer:getData("char >> blackJackCoins") or {}

                    manageCoinShop("init")
                end
            elseif clickedElement:getData("blackJackTable >> id") and getDistanceBetweenPoints3D(localPlayer.position, clickedElement.position) <= 1.7 then 
                if not isTableCoinRender and not closeTableCoinHover then 
                    if getTickCount() - lastTableTick >= 1000 then 
                        local tableId = clickedElement:getData("blackJackTable >> id")

                        triggerServerEvent("blackJack.openBlackJackTable", localPlayer, tableId, clickedElement)
                        lastTableTick = getTickCount()
                    end
                end
            end
        end
    end
end
addEventHandler("onClientClick", root, onClick)