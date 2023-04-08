local screenX, screenY = guiGetScreenSize()
-- local dxDrawMultiplier = math.min(1, screenX / 1280)

local function reMap(value, low1, high1, low2, high2)
    return low2 + (value - low1) * (high2 - low2) / (high1 - low1)
end

local dxDrawMultiplier = math.min(1, reMap(screenX, 1024, 1920, 0.75, 1))

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

local alpha = 255
local blockActionTimer = false
local calculateTimer = false
local dealerGetsNewCardTimer = false
local setAnimTimer = false

local hoverCoin = false
local buyHover = false

closeTableCoinHover = false
isTableCoinRender = false
selectedTableElement = false
isGameActive = false

local lastCoinTick = -10000
local selectedPanel = 1
local switchingToTheGame = false

local notificationText = false
local hoverNotificationButton = false

local availableButtons = {"double", "hit", "stand"}
local coinsToPlayWith = {}
local hoverButton = false

local moveCardTick = 0
local moveDealerCardTick = 0
local playerScore = 0
local dealerScore = 0

local blockActions = false
local alreadyDoubled = false
local haveToLose = false

local dealerCardTable = {}
local playerCardTable = {}

local cardTypes = {
	{index = "2C", value = 2, alreadySelected = false},
	{index = "2D", value = 2, alreadySelected = false},
	{index = "2H", value = 2, alreadySelected = false},
	{index = "2S", value = 2, alreadySelected = false},
	{index = "3C", value = 3, alreadySelected = false},
	{index = "3D", value = 3, alreadySelected = false},
	{index = "3H", value = 3, alreadySelected = false},
	{index = "3S", value = 3, alreadySelected = false},
	{index = "4C", value = 4, alreadySelected = false},
	{index = "4D", value = 4, alreadySelected = false},
	{index = "4H", value = 4, alreadySelected = false},
	{index = "4S", value = 4, alreadySelected = false},
	{index = "5C", value = 5, alreadySelected = false},
	{index = "5D", value = 5, alreadySelected = false},
	{index = "5H", value = 5, alreadySelected = false},
	{index = "5S", value = 5, alreadySelected = false},
	{index = "6C", value = 6, alreadySelected = false},
	{index = "6D", value = 6, alreadySelected = false},
	{index = "6H", value = 6, alreadySelected = false},
	{index = "6S", value = 6, alreadySelected = false},
	{index = "7C", value = 7, alreadySelected = false},
	{index = "7D", value = 7, alreadySelected = false},
	{index = "7H", value = 7, alreadySelected = false},
	{index = "7S", value = 7, alreadySelected = false},
	{index = "8C", value = 8, alreadySelected = false},
	{index = "8D", value = 8, alreadySelected = false},
	{index = "8H", value = 8, alreadySelected = false},
	{index = "8S", value = 8, alreadySelected = false},
	{index = "9C", value = 9, alreadySelected = false},
	{index = "9D", value = 9, alreadySelected = false},
	{index = "9H", value = 9, alreadySelected = false},
	{index = "9S", value = 9, alreadySelected = false},
	{index = "TC", value = 10, alreadySelected = false},
	{index = "TD", value = 10, alreadySelected = false},
	{index = "TH", value = 10, alreadySelected = false},
	{index = "TS", value = 10, alreadySelected = false},
	{index = "JC", value = 10, alreadySelected = false},
	{index = "JD", value = 10, alreadySelected = false},
	{index = "JH", value = 10, alreadySelected = false},
	{index = "JS", value = 10, alreadySelected = false},
	{index = "KC", value = 10, alreadySelected = false},
	{index = "KD", value = 10, alreadySelected = false},
	{index = "KH", value = 10, alreadySelected = false},
	{index = "KS", value = 10, alreadySelected = false},
	{index = "QC", value = 10, alreadySelected = false},
	{index = "QD", value = 10, alreadySelected = false},
	{index = "QH", value = 10, alreadySelected = false},
	{index = "QS", value = 10, alreadySelected = false},
	{index = "AC", value = 11, secondValue = 1, alreadySelected = false},
	{index = "AD", value = 11, secondValue = 1, alreadySelected = false},
	{index = "AH", value = 11, secondValue = 1, alreadySelected = false},
	{index = "AS", value = 11, secondValue = 1, alreadySelected = false}
}

function renderTableCoins()
    local alpha, progress = exports.cr_dx:getFade("tableCoinPanel")

    if alpha and progress then 
        if progress >= 1 and alpha <= 0 then 
            destroyRender("renderTableCoins")
            
            if not switchingToTheGame then 
                selectedTableElement = false
            end

            closeTableCoinHover = false
            hoverNotificationButton = false
            -- playerCoins = {}

            resetCoins()

            if switchingToTheGame then 
                exports.cr_dx:startFade("blackJackGamePanel", 
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

                isGameActive = true
                createRender("renderTheGame", renderTheGame)

                setTimer(
                    function()
                        moveDealerCardTick = getTickCount()
                    end, 1000, 1
                )

                selectedPanel = 2
                switchingToTheGame = false
            end

            return
        end
    end

    if isElement(selectedTableElement) then 
        local playerX, playerY, playerZ = getElementPosition(localPlayer)
        local distance = getDistanceBetweenPoints3D(playerX, playerY, playerZ, getElementPosition(selectedTableElement))

        if distance > 3 then 
            if isTableCoinRender then 
                isTableCoinRender = false

                manageTableCoinPanel("exit")
            end
        end
    end

    local font = exports.cr_fonts:getFont("Poppins-SemiBold", 16)
    local font2 = exports.cr_fonts:getFont("Poppins-SemiBold", 14)
    local font3 = exports.cr_fonts:getFont("Poppins-Medium", 14)
    local font4 = exports.cr_fonts:getFont("Poppins-Regular", 12)

    local greenR, greenG, greenB = exports.cr_core:getServerColor("green", false)

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
    
    closeTableCoinHover = nil

    if inSlot then 
        closeTableCoinHover = true
        imageColor = tocolor(255, 59, 59, alpha)
    end

    dxDrawImage(closeX, closeY, closeW, closeH, "files/images/close.png", 0, 0, 0, imageColor)

    local buttonW, buttonH = 150, 20
    local buttonX, buttonY = panelX + buttonW / 2, panelY + panelH - buttonH - 15
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
    dxDrawText("Feltesz", buttonX, buttonY + 4, buttonX + buttonW, buttonY + buttonH, textColor, 1, font3, "center", "center")

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

function renderTheGame()
    local cursorX, cursorY = exports.cr_core:getCursorPosition()
    local alpha, progress = exports.cr_dx:getFade("blackJackGamePanel")

    if alpha and progress then 
        if progress >= 1 and alpha <= 0 then 
            destroyRender("renderTheGame")

            if isElement(selectedTableElement) then 
                local tableId = selectedTableElement:getData("blackJackTable >> id")

                triggerServerEvent("blackJack.closeBlackJackPanel", localPlayer, tableId)
            end

            coinsToPlayWith = {}
            hoverNotificationButton = false
        end
    end

    if isElement(selectedTableElement) then 
        local playerX, playerY, playerZ = getElementPosition(localPlayer)
        local distance = getDistanceBetweenPoints3D(playerX, playerY, playerZ, getElementPosition(selectedTableElement))

        if distance > 3 then 
            if isGameActive then 
                isGameActive = false

                manageTableCoinPanel("exitTheGame")
            end
        end
    end

    local font = exports.cr_fonts:getFont("Poppins-SemiBold", getRealFontSize(13))
    local font2 = exports.cr_fonts:getFont("Poppins-Bold", getRealFontSize(14))
    local font3 = exports.cr_fonts:getFont("Poppins-SemiBold", 16)
    local font4 = exports.cr_fonts:getFont("Poppins-SemiBold", 13)
    local font5 = exports.cr_fonts:getFont("Poppins-Medium", 13)
    local font6 = exports.cr_fonts:getFont("Poppins-Medium", 14)

    local greenR, greenG, greenB = exports.cr_core:getServerColor("green", false)
    local redR, redG, redB = exports.cr_core:getServerColor("red", false)
    local greenHex = exports.cr_core:getServerColor("green", true)

    local tableW, tableH = resp(890), resp(889)
    local tableX, tableY = screenX / 2 - tableW / 2, screenY / 2 - tableH / 2 - resp(60)

    dxDrawRectangle(0, 0, screenX, screenY, tocolor(0, 0, 0, alpha * 0.3))
    dxDrawImage(tableX, tableY, tableW, tableH, "files/images/table.png", 0, 0, 0, tocolor(255, 255, 255, alpha))

    local coinW, coinH = resp(25) - resp(6), resp(25) - resp(6)
    local coinX, coinY = tableX + resp(57) + resp(3), tableY + resp(315) + resp(3)
        
    local allPrice = 0
    local count = 0

    for k, v in pairs(coinsToPlayWith) do 
        count = count + 1
        allPrice = allPrice + (v.value * v.count)

        if fileExists("files/images/coins/" .. k .. ".png") then 
            dxDrawImage(coinX, coinY, coinW, coinH, "files/images/coins/" .. k .. ".png", 0, 0, 0, tocolor(255, 255, 255, alpha), true)
            dxDrawText(v.count .. "x", coinX + coinW + resp(2), coinY + resp(4), coinX + coinW, coinY + coinH, tocolor(255, 255, 255, alpha), 1, font, "left", "center", false, false, true)
        end

        coinX = coinX + coinW + resp(25)
    end

    local coinBackW, coinBackH = count * resp(43) + resp(10), resp(25)
    local coinBackX, coinBackY = tableX + resp(50), tableY + resp(315)

    local priceBackW, priceBackH = resp(100), resp(25)
    local priceBackX, priceBackY = tableX + resp(50), tableY + resp(280)

    dxDrawRoundedCorneredRectangle("full", 6, coinBackX, coinBackY, coinBackW, coinBackH, ":cr_blackjack/files/images/roundedcorner.png", tocolor(164, 84, 6, alpha))
	dxDrawRoundedCorneredRectangle("full", 6, priceBackX, priceBackY, priceBackW, priceBackH, ":cr_blackjack/files/images/roundedcorner.png", tocolor(164, 84, 6, alpha))

    dxDrawText("Tét: " .. greenHex .. "$" .. allPrice, priceBackX, priceBackY + resp(2), priceBackX + priceBackW, priceBackY + priceBackH, tocolor(255, 255, 255, alpha), 1, font, "center", "center", false, false, false, true)

    local buttonW, buttonH = resp(70), resp(70)
    local buttonX, buttonY = tableX + tableW / 2 - buttonW - buttonW / 2 - resp(10), tableY + tableH - resp(10)

    hoverButton = nil

    for i = 1, #availableButtons do
        local v = availableButtons[i]
        local imageColor = tocolor(255, 255, 255, alpha)
        local inSlot = exports.cr_core:isInSlot(buttonX, buttonY, buttonW, buttonH)
        
        if inSlot then 
            imageColor = tocolor(greenR, greenG, greenB, alpha)
            hoverButton = v
        end

        if fileExists("files/images/" .. v .. ".png") then 
            dxDrawImage(buttonX, buttonY, buttonW, buttonH, "files/images/" .. v .. ".png", 0, 0, 0, imageColor)
        end

        if hoverButton == "double" then 
            exports.cr_dx:drawTooltip(2, "Duplázás", {cursorX, cursorY, {["alpha"] = alpha}})
        elseif hoverButton == "hit" then
            exports.cr_dx:drawTooltip(2, "Kérés", {cursorX, cursorY, {["alpha"] = alpha}})
        elseif hoverButton == "stand" then
            exports.cr_dx:drawTooltip(2, "Megállás", {cursorX, cursorY, {["alpha"] = alpha}})
        end

        buttonX = buttonX + buttonW + resp(12)
    end

    local pScore = 0
    local cardW, cardH = resp(72), resp(100)
    local cardX, cardY = tableX + tableW / 2 - resp(70), tableY + tableH - resp(215)

	for k, v in pairs(playerCardTable) do
        local currentImage = v.blank and "files/images/cards/back.png" or "files/images/cards/" .. v.cardIndex .. ".png"

        dxDrawImage(cardX, cardY, cardW, cardH, currentImage, 0, 0, 0, tocolor(255, 255, 255, alpha))

		if pScore + v.value > 21 and v.secondValue then
			v.value = v.secondValue
		end

        cardX = cardX + resp(30)
		pScore = pScore + v.value
	end

	playerScore = pScore

    local scoreW, scoreH = resp(25), resp(25)
    local scoreX, scoreY = tableX + resp(425), tableY + resp(795)

    dxDrawRoundedCorneredRectangle("full", 4, scoreX, scoreY, scoreW, scoreH, ":cr_blackjack/files/images/roundedcorner.png", tocolor(255, 192, 0, alpha))
    dxDrawText(pScore, scoreX, scoreY + resp(4), scoreX + scoreW, scoreY + scoreH, tocolor(0, 0, 0, math.min(200, alpha)), 1, font2, "center", "center")

    if moveCardTick > 0 then
		local progress = (getTickCount() - moveCardTick) / 1000
		local x, y, rot = interpolateBetween(tableX + resp(711), tableY + resp(397), -66, tableX + tableW / 2 - resp(70) + #playerCardTable * resp(30), tableY + tableH - resp(215), 0, progress, "Linear")
		
        if progress <= 1.5 then
            local cardW, cardH = resp(72), resp(100)

			dxDrawImage(x, y, cardW, cardH, "files/images/cards/back.png", rot)
		else
			if #playerCardTable < 1 then
				moveCardTick = getTickCount()
			end

			if #playerCardTable < 2 then
				local newCard = getRandomCard()
                
				table.insert(playerCardTable, {cardIndex = newCard.index, blank = false, value = newCard.value, secondValue = (newCard.secondValue or false)})
				blockActions = false
			end
		end
	end

    local dScore = 0
    local cardW, cardH = resp(72), resp(100)
    local cardX, cardY = tableX + tableW / 2 - resp(90), tableY + tableH / 2 + resp(50)

	for k, v in pairs(dealerCardTable) do
		if not v.blank then
			dxDrawImage(cardX, cardY, cardW, cardH, "files/images/cards/" .. v.cardIndex .. ".png", 0, 0, 0, tocolor(255, 255, 255, alpha))
			
            if dScore + v.value > 21 and v.secondValue then
				v.value = v.secondValue
			end

			dScore = dScore + v.value
		else
			dxDrawImage(cardX, cardY, cardW, cardH, "files/images/cards/back.png")
		end

        cardX = cardX + resp(30)
	end

	dealerScore = dScore

    local scoreW, scoreH = resp(25), resp(25)
    local scoreX, scoreY = tableX + resp(425), tableY + resp(455)

    dxDrawRoundedCorneredRectangle("full", 4, scoreX, scoreY, scoreW, scoreH, ":cr_blackjack/files/images/roundedcorner.png", tocolor(255, 192, 0, alpha))
    dxDrawText(dScore, scoreX, scoreY + resp(4), scoreX + scoreW, scoreY + scoreH, tocolor(0, 0, 0, math.min(200, alpha)), 1, font2, "center", "center")

    if moveDealerCardTick > 0 then
		local progress = (getTickCount() - moveDealerCardTick) / 1000
		local x, y, rot = interpolateBetween(tableX + resp(711), tableY + resp(397), -66, tableX + tableW / 2 - resp(90) + #dealerCardTable * resp(30), tableY + tableH / 2 + resp(50), 0, progress, "Linear")
		
        if progress <= 1.5 then
            local cardW, cardH = resp(72), resp(100)

			dxDrawImage(x, y, cardW, cardH, "files/images/cards/back.png", rot)
		else
			if #dealerCardTable < 1 then
				moveDealerCardTick = getTickCount()
			end

			if #dealerCardTable < 2 then
				local newCard = getRandomCard()

				table.insert(dealerCardTable, {cardIndex = newCard.index, blank = false, value = newCard.value, secondValue = (newCard.secondValue or false)})
				if #dealerCardTable == 2 then
					dealerCardTable[2].blank = true
					moveCardTick = getTickCount()
				end
			end
		end
	end

    -- Notification

    local notificationAlpha, notificationProgress = exports.cr_dx:getFade("blackJackNotification")

    if notificationText then 
        local textWidth = dxGetTextWidth(notificationText:gsub("#......", ""), 1, font4, false) + 50

        local panelW, panelH = math.max(375, textWidth), 130
        local panelX, panelY = screenX / 2 - panelW / 2, screenY / 2 - panelH / 2

        dxDrawRectangle(panelX, panelY, panelW, panelH, tocolor(51, 51, 51, notificationAlpha * 0.8))

        local logoW, logoH = 26, 30
        local logoX, logoY = panelX + 10, panelY + 8

        dxDrawImage(logoX, logoY, logoW, logoH, "files/images/logo.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
        dxDrawText("Blackjack", logoX + logoW + 10, logoY + 4, logoX + logoW, logoY + logoH, tocolor(255, 255, 255, alpha), 1, font3, "left", "center")

        local nextButtonW, nextButtonH = 150, 20
        local nextButtonX, nextButtonY = panelX + 32, panelY + panelH - nextButtonH - 15
        
        local nextButtonColor = tocolor(greenR, greenG, greenB, notificationAlpha * 0.7)
        local nextTextColor = tocolor(255, 255, 255, notificationAlpha * 0.6)
        local inSlot = exports.cr_core:isInSlot(nextButtonX, nextButtonY, nextButtonW, nextButtonH)

        hoverNotificationButton = nil

        if inSlot then 
            nextButtonColor = tocolor(greenR, greenG, greenB, notificationAlpha)
            nextTextColor = tocolor(255, 255, 255, notificationAlpha)
            hoverNotificationButton = "yes"
        end

        dxDrawRectangle(nextButtonX, nextButtonY, nextButtonW, nextButtonH, nextButtonColor)
        dxDrawText("Igen", nextButtonX, nextButtonY + 2, nextButtonX + nextButtonW, nextButtonY + nextButtonH, nextTextColor, 1, font6, "center", "center")

        dxDrawText(notificationText, nextButtonX, nextButtonY - 90, nextButtonX + nextButtonW, nextButtonY + nextButtonH, tocolor(255, 255, 255, notificationAlpha), 1, font4, "left", "center", false, false, false, true)
        dxDrawText("Szeretnél új kört kezdeni?", nextButtonX, nextButtonY - 55, nextButtonX + nextButtonW, nextButtonY + nextButtonH, tocolor(255, 255, 255, notificationAlpha), 1, font5, "left", "center")

        local cancelButtonW, cancelButtonH = 150, 20
        local cancelButtonX, cancelButtonY = panelX + panelW - cancelButtonW - 32, nextButtonY
        
        local cancelButtonColor = tocolor(redR, redG, redB, notificationAlpha * 0.7)
        local cancelTextColor = tocolor(255, 255, 255, notificationAlpha * 0.6)
        local inSlot = exports.cr_core:isInSlot(cancelButtonX, cancelButtonY, cancelButtonW, cancelButtonH)

        if inSlot then 
            cancelButtonColor = tocolor(redR, redG, redB, notificationAlpha)
            cancelTextColor = tocolor(255, 255, 255, notificationAlpha)
            hoverNotificationButton = "no"
        end

        dxDrawRectangle(cancelButtonX, cancelButtonY, cancelButtonW, cancelButtonH, cancelButtonColor)
        dxDrawText("Nem", cancelButtonX, cancelButtonY + 2, cancelButtonX + cancelButtonW, cancelButtonY + cancelButtonH, cancelTextColor, 1, font6, "center", "center")
    end
end

function onTableCoinKey(button, state)
    if button == "mouse1" and state then 
        if selectedPanel == 1 then 
            if hoverCoin then 
                local selected = split(hoverCoin, ":")
                local index = tonumber(selected[1])

                if selected[2] == "decrease" then 
                    availableCoins[index].count = math.max(0, availableCoins[index].count - 1)
                elseif selected[2] == "increase" then
                    availableCoins[index].count = math.min(999, availableCoins[index].count + 1)
                end
            elseif closeTableCoinHover then
                if isTableCoinRender then 
                    isTableCoinRender = false

                    if isElement(selectedTableElement) then 
                        local tableId = selectedTableElement:getData("blackJackTable >> id")
        
                        triggerServerEvent("blackJack.closeBlackJackPanel", localPlayer, tableId)
                    end

                    manageTableCoinPanel("exit")
                end
            elseif buyHover then
                if isTableCoinRender then
                    local allPrice = 0
                    local newCoins = table.copy(playerCoins)
                    
                    for i = 1, #availableCoins do 
                        local v = availableCoins[i]

                        if v.count > 0 then 
                            if playerCoins[v.value] then 
                                if playerCoins[v.value] >= v.count then 
                                    newCoins[v.value] = math.max(0, newCoins[v.value] - v.count)
                                    coinsToPlayWith[v.value] = {value = v.value, count = v.count}
                                    allPrice = allPrice + (v.value * v.count)
                                end
                            end
                        end
                    end

                    if allPrice <= 0 then 
                        exports.cr_infobox:addBox("error", "Minimum 1 zsetonnal kell játszanod.")

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

                    -- exports.cr_infobox:addBox("success", "Sikeresen elkezdted a játékot!")

                    localPlayer:setData("char >> blackJackCoins", newCoins)
                    playerCoins = newCoins

                    resetCoins()
                    manageTableCoinPanel("switchToTheGame")
                end
            end
        elseif selectedPanel == 2 then
            if hoverButton then 
                if hoverButton == "double" then 
                    if not notificationText then 
                        playerDoublesTheMoney()
                    end
                elseif hoverButton == "hit" then
                    if not notificationText then 
                        playerWantsNewCard()
                    end
                elseif hoverButton == "stand" then
                    if not notificationText then 
                        playerStopsTheGame()
                    end
                end
            elseif hoverNotificationButton then
                if hoverNotificationButton == "yes" then 
                    restartTheGame()
                elseif hoverNotificationButton == "no" then
                    closeTheGame()
                end
            end
        end
    end
end

function playerDoublesTheMoney()
	if not alreadyDoubled then
        if #playerCardTable >= 2 and not blockActions then 
            blockActions = true

            setTimer(
                function()
                    blockActions = false
                end, 1000, 1
            )

            if not notificationText then
                local doubleTable = {}
                local canPlay = true

                for k, v in pairs(coinsToPlayWith) do
                    if playerCoins[k] then 
                        if playerCoins[k] < v.count then
                            exports.cr_infobox:addBox("error", "Nincs elég zsetonod a duplázáshoz!")
                            canPlay = false
                            break
                        else
                            doubleTable[k] = v.count
                        end
                    else
                        exports.cr_infobox:addBox("error", "Nincs elég zsetonod a duplázáshoz!")
                        canPlay = false
                        break
                    end
                end

                if canPlay then 
                    for k, v in pairs(doubleTable) do
                        if not playerCoins[k] then 
                            playerCoins[k] = 0
                        end

                        playerCoins[k] = playerCoins[k] - coinsToPlayWith[k].count
                        coinsToPlayWith[k].count = coinsToPlayWith[k].count * 2
                    end

                    alreadyDoubled = true
                    exports.cr_infobox:addBox("success", "Sikeresen dupláztad a tétet.")

                    playerWantsNewCard()
                end
            end
        else 
            exports.cr_infobox:addBox("error", "Ne használd ilyen gyorsan a gombokat!")
        end
	else
        exports.cr_infobox:addBox("error", "Egyszer már dupláztál ebben a körben!")
	end
end

function playerWantsNewCard()
	if #playerCardTable >= 2 and not blockActions or alreadyDoubled then
		if not isTimer(waitCalculateTimer) then
			blockActions = true
			moveCardTick = getTickCount()

            setTimer(
                function()
                    local newCard = getRandomCard()
                    
                    table.insert(playerCardTable, {cardIndex = newCard.index, blank = false, value = newCard.value, secondValue = (newCard.secondValue or false)})
                    calculateTimer = setTimer(
                        function()
                            if playerScore > 21 then 
                                setWinner("dealer")
                            end

                            if isTimer(calculateTimer) then 
                                killTimer(calculateTimer)
                                calculateTimer = nil
                            end

                            if isTimer(blockActionTimer) then 
                                killTimer(blockActionTimer)
                                blockActionTimer = nil
                            end

                            blockActionTimer = setTimer(
                                function()
                                    blockActions = false
                                end, 1000, 1
                            )
                        end, 100, 1
                    )
                end, 1500, 1
            )
		end
	else
        exports.cr_infobox:addBox("error", "Ne használd ilyen gyorsan a gombokat!")
	end
end

function playerStopsTheGame()
	if #playerCardTable >= 2 and not blockActions then
		dealerCardTable[2].blank = false
		blockActions = true

        setTimer(
            function()
                if dealerScore <= playerScore then
                    if dealerScore == 21 and playerScore == dealerScore then
                        setWinner("draw")
                    else
                        moveDealerCardTick = getTickCount()

                        if isTimer(dealerGetsNewCardTimer) then 
                            killTimer(dealerGetsNewCardTimer)
                            dealerGetsNewCardTimer = nil
                        end

                        dealerGetsNewCardTimer = setTimer(
                            function()
                                local newCard = getRandomCard()

                                table.insert(dealerCardTable, {cardIndex = newCard.index, blank = false, value = newCard.value, secondValue = (newCard.secondValue or false)})
                                local cloneValue = newCard.value

                                if dealerScore + newCard.value > 21 and newCard.secondValue then
                                    cloneValue = newCard.secondValue
                                end

                                if dealerScore + cloneValue <= playerScore and dealerScore + cloneValue < 21 then
                                    moveDealerCardTick = getTickCount()
                                else
                                    if isTimer(dealerGetsNewCardTimer) then 
                                        killTimer(dealerGetsNewCardTimer)
                                        dealerGetsNewCardTimer = nil
                                    end

                                    if dealerScore + cloneValue <= 21 then
                                        if dealerScore + cloneValue == playerScore then
                                            setWinner("draw")
                                        else
                                            setWinner("dealer")
                                        end
                                    else
                                        setWinner("player")
                                    end
                                end
                            end, 1500, 0
                        )
                    end
                else
                    setWinner("dealer")
                end
            end, 1000, 1
        )
	else
		exports.cr_infobox:addBox("error", "Ne használd ilyen gyorsan a gombokat!")
	end
end

local wonCount = 0
local nextFail = false

function setWinner(winner)
    local greenHex = exports.cr_core:getServerColor("green", true)
    local redHex = exports.cr_core:getServerColor("red", true)
    local yellowHex = exports.cr_core:getServerColor("lightyellow", true)

    -- playerCardTable = {}
    -- dealerCardTable = {}

    moveDealerCardTick = 0
    moveCardTick = 0
    
    exports.cr_dx:startFade("blackJackNotification", 
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

    if winner == "player" then 
        local winPrice = 0

        if not nextFail then 
            nextFail = math.random(1, 3)
        end

        wonCount = wonCount + 1

        if wonCount >= nextFail then 
            haveToLose = true
        end

        for k, v in pairs(coinsToPlayWith) do
            if v.count > 0 then
                playerCoins[k] = playerCoins[k] + (v.count * 2)
                winPrice = winPrice + (v.value * v.count) * 2
            end
        end

        notificationText = greenHex .. "Gratulálunk, ebben a körben te nyertél! Nyereményed: $" .. winPrice

        localPlayer:setData("char >> blackJackCoins", playerCoins)
        localPlayer:setData("forceAnimation", {"casino", "roulette_win", 1500, false, false, false, false})

        setAnimTimer = setTimer(setElementData, 1550, 1, localPlayer, "forceAnimation", {"casino", "roulette_loop", -1, true, false, false})
    elseif winner == "dealer" then
        wonCount = 0
        nextFail = false
        haveToLose = false

        notificationText = redHex .. "Sajnáljuk, ebben a körben nem nyertél! :("

        localPlayer:setData("forceAnimation", {"casino", "roulette_lose", 1500, false, false, false, false})
        setAnimTimer = setTimer(setElementData, 1550, 1, localPlayer, "forceAnimation", {"casino", "roulette_loop", -1, true, false, false})
    elseif winner == "draw" then
        notificationText = yellowHex .. "Ebben a körben döntetlen alakult ki. A tét visszajár."

        for k, v in pairs(coinsToPlayWith) do
            if v.count > 0 then
                playerCoins[k] = playerCoins[k] + v.count
            end
        end

        localPlayer:setData("char >> blackJackCoins", playerCoins)
        localPlayer:setData("forceAnimation", {"casino", "roulette_lose", 1500, false, false, false, false})

        setAnimTimer = setTimer(setElementData, 1550, 1, localPlayer, "forceAnimation", {"casino", "roulette_loop", -1, true, false, false})
    end
end

function restartTheGame()
	local doubleTable = {}
    local canPlay = true

    alreadyDoubled = false
    playerCardTable = {}
    dealerCardTable = {}

	for k, v in pairs(cardTypes) do
		v.alreadySelected = false
	end

	for k, v in pairs(coinsToPlayWith) do
        if playerCoins[k] then 
            if playerCoins[k] < v.count then
                exports.cr_infobox:addBox("error", "Nincs elég zsetonod, hogy újrakezd!")

                for k, v in pairs(coinsToPlayWith) do
                    v.count = 0
                end

                notificationText = false
                hoverNotificationButton = false
                canPlay = false
                isTableCoinRender = false
                manageTableCoinPanel("exitTheGame")

                break
            else
                doubleTable[k] = v.count
            end
        else
            notificationText = false
            hoverNotificationButton = false
            canPlay = false
            isTableCoinRender = false
            manageTableCoinPanel("exitTheGame")

            break
        end
	end

    if canPlay then 
        for k, v in pairs(doubleTable) do
            playerCoins[k] = playerCoins[k] - coinsToPlayWith[k].count
        end

        moveDealerCardTick = getTickCount()
        notificationText = false
        hoverNotificationButton = false
        
        localPlayer:setData("char >> blackJackCoins", playerCoins)
    end
end

function closeTheGame()
	for k, v in pairs(coinsToPlayWith) do
		v.count = 0
	end

	for k, v in pairs(cardTypes) do
		v.alreadySelected = false
	end

    if isTimer(setAnimTimer) then 
        killTimer(setAnimTimer)
        setAnimTimer = nil
    end

    playerCardTable = {}
    dealerCardTable = {}

	notificationText = false
    hoverNotificationButton = false
    isTableCoinRender = false
	manageTableCoinPanel("exitTheGame")
end

function manageTableCoinPanel(state)
    if state == "init" then 
        exports.cr_dx:startFade("tableCoinPanel", 
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

        createRender("renderTableCoins", renderTableCoins)
        addEventHandler("onClientKey", root, onTableCoinKey)
        addEventHandler("onClientPlayerWasted", localPlayer, onClientWasted)
    elseif state == "switchToTheGame" then
        exports.cr_dx:startFade("tableCoinPanel", 
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

        playerCoins = localPlayer:getData("char >> blackJackCoins") or {}
        switchingToTheGame = true
    elseif state == "exit" then
        exports.cr_dx:startFade("tableCoinPanel", 
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

        removeEventHandler("onClientKey", root, onTableCoinKey)
        removeEventHandler("onClientPlayerWasted", localPlayer, onClientWasted)
    elseif state == "exitTheGame" then
        exports.cr_dx:startFade("blackJackGamePanel", 
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

        removeEventHandler("onClientKey", root, onTableCoinKey)
        removeEventHandler("onClientPlayerWasted", localPlayer, onClientWasted)
    end
end

function openBlackJackTable(element)
    isTableCoinRender = true
    selectedPanel = 1

    selectedTableElement = element
    playerCoins = localPlayer:getData("char >> blackJackCoins") or {}

    manageTableCoinPanel("init")
end
addEvent("blackJack.openBlackJackTable", true)
addEventHandler("blackJack.openBlackJackTable", root, openBlackJackTable)

function onClientWasted()
    if isTableCoinRender then 
        isTableCoinRender = false

        manageTableCoinPanel("exit")
    else
        manageTableCoinPanel("exitTheGame")
    end

    if isElement(selectedTableElement) then 
        local tableId = selectedTableElement:getData("blackJackTable >> id")

        triggerServerEvent("blackJack.closeBlackJackPanel", localPlayer, tableId)
    end
end

function getRandomCard()
    local randomCardNum

    if not haveToLose then 
        math.randomseed(getTickCount())

        randomCardNum = math.random(1, #cardTypes)

        math.randomseed(getTickCount())
        while cardTypes[randomCardNum].alreadySelected do
            randomCardNum = math.random(1, #cardTypes)
        end

        cardTypes[randomCardNum].alreadySelected = true
    else 
        local nextIndex = false
        local currentVal = false

        for i = 1, #cardTypes do 
            local v = cardTypes[i]

            if dealerCardTable[1] and not dealerCardTable[2] then 
                local diff = 21 - dealerCardTable[1].value

                if v.value == diff or v.value < diff then 
                    nextIndex = i

                    break
                end
            end
        end

        math.randomseed(getTickCount())

        randomCardNum = math.random(1, #cardTypes)

        math.randomseed(getTickCount())
        while cardTypes[randomCardNum].alreadySelected do
            randomCardNum = math.random(1, #cardTypes)
        end

        if nextIndex then 
            randomCardNum = nextIndex
        end

        cardTypes[randomCardNum].alreadySelected = true
    end

	return cardTypes[randomCardNum]
end

-- COMMANDS

function nearbyBlackJackTables(cmd)
    if exports.cr_permission:hasPermission(localPlayer, cmd) then 
        local cache = {}
        local objects = getElementsByType("object", resourceRoot, true)
        local playerX, playerY, playerZ = getElementPosition(localPlayer)

        for i = 1, #objects do 
            local v = objects[i]

            if v:getData("blackJackTable >> id") and getDistanceBetweenPoints3D(playerX, playerY, playerZ, getElementPosition(v)) <= 15 then 
                table.insert(cache, v)
            end
        end

        if #cache > 0 then 
            local syntax = exports.cr_core:getServerSyntax("Blackjack", "info")
            local hexColor = exports.cr_core:getServerColor("yellow", true)

            for i = 1, #cache do 
                local v = cache[i]

                if isElement(v) then 
                    local id = v:getData("blackJackTable >> id")
                    local distance = math.floor(getDistanceBetweenPoints3D(playerX, playerY, playerZ, getElementPosition(v)))

                    outputChatBox(syntax .. "ID: " .. hexColor .. id .. white .. ", távolság: " .. hexColor .. distance .. white .. " yard.", 255, 0, 0, true)
                end
            end
        else
            local syntax = exports.cr_core:getServerSyntax("Blackjack", "error")

            outputChatBox(syntax .. "Nincs a közeledben blackjack asztal.", 255, 0, 0, true)
        end
    end
end
addCommandHandler("nearbyblackjacktables", nearbyBlackJackTables, false, false)

function nearbyCoinDealers(cmd)
    if exports.cr_permission:hasPermission(localPlayer, cmd) then 
        local cache = {}
        local peds = getElementsByType("ped", resourceRoot, true)
        local playerX, playerY, playerZ = getElementPosition(localPlayer)

        for i = 1, #peds do 
            local v = peds[i]

            if v:getData("coin >> dealer") and getDistanceBetweenPoints3D(playerX, playerY, playerZ, getElementPosition(v)) <= 15 then 
                table.insert(cache, v)
            end
        end

        if #cache > 0 then 
            local syntax = exports.cr_core:getServerSyntax("Blackjack", "info")
            local hexColor = exports.cr_core:getServerColor("yellow", true)

            for i = 1, #cache do 
                local v = cache[i]

                if isElement(v) then 
                    local id = v:getData("coin >> dealer")
                    local name = v:getData("ped.name")
                    local distance = math.floor(getDistanceBetweenPoints3D(playerX, playerY, playerZ, getElementPosition(v)))

                    outputChatBox(syntax .. "ID: " .. hexColor .. id .. white .. ", név: " .. hexColor .. name .. white .. ", távolság: " .. hexColor .. distance .. white .. " yard.", 255, 0, 0, true)
                end
            end
        else
            local syntax = exports.cr_core:getServerSyntax("Blackjack", "error")

            outputChatBox(syntax .. "Nincs a közeledben zseton eladó npc.", 255, 0, 0, true)
        end
    end
end
addCommandHandler("nearbycoindealers", nearbyCoinDealers, false, false)

-- ASSETS

function dxDrawRoundedCorneredRectangle(alignment, cornerSize, x, y, width, height, cornerImage, ...)
	if not (alignment and cornerSize and x and y and width and height and cornerImage) then
		return
	end

	if width < cornerSize * 2 then
		width = cornerSize * 2
	end

	if height < cornerSize * 2 then
		height = cornerSize * 2
	end

	-- if not isElement(cornerImage) then
	-- 	dxDrawRectangle(x, y, width, height, ...)
	-- 	return
	-- end

	if alignment == "full" or alignment == "top" then
		exports.cr_dx:dxDrawImageAsTexture(x, y, cornerSize, cornerSize, cornerImage, 0, 0, 0, ...)
		exports.cr_dx:dxDrawImageAsTexture(x + cornerSize + (width - cornerSize * 2), y, cornerSize, cornerSize, cornerImage, 90, 0, 0, ...)
		dxDrawRectangle(x + cornerSize, y, width - cornerSize * 2, cornerSize, ...)
	end

	if alignment == "top" then
		dxDrawRectangle(x, y + cornerSize, width, height - cornerSize, ...)
	end

	if alignment == "full" or alignment == "bottom" then
		exports.cr_dx:dxDrawImageAsTexture(x, y + height - cornerSize, cornerSize, cornerSize, cornerImage, 270, 0, 0, ...)
		exports.cr_dx:dxDrawImageAsTexture(x + cornerSize + (width - cornerSize * 2), y + height - cornerSize, cornerSize, cornerSize, cornerImage, 180, 0, 0, ...)
		dxDrawRectangle(x + cornerSize, y + height - cornerSize, width - cornerSize * 2, cornerSize, ...)
	end

	if alignment == "left" then
		exports.cr_dx:dxDrawImageAsTexture(x, y, cornerSize, cornerSize, cornerImage, 0, 0, 0, ...)
		exports.cr_dx:dxDrawImageAsTexture(x, y + height - cornerSize, cornerSize, cornerSize, cornerImage, 270, 0, 0, ...)
		dxDrawRectangle(x + cornerSize, y, width - cornerSize * 2, cornerSize, ...)
		dxDrawRectangle(x + cornerSize, y + height - cornerSize, width - cornerSize * 2, cornerSize, ...)
		dxDrawRectangle(x+width-cornerSize, y, cornerSize, height, ...)
		dxDrawRectangle(x, y + cornerSize, width, height - cornerSize * 2, ...)
	end

	if alignment == "right" then
		exports.cr_dx:dxDrawImageAsTexture(x + cornerSize + (width - cornerSize * 2), y, cornerSize, cornerSize, cornerImage, 90, 0, 0, ...)
		exports.cr_dx:dxDrawImageAsTexture(x + cornerSize + (width - cornerSize * 2), y + height - cornerSize, cornerSize, cornerSize, cornerImage, 180, 0, 0, ...)
		dxDrawRectangle(x + cornerSize, y + height - cornerSize, width - cornerSize * 2, cornerSize, ...)
		dxDrawRectangle(x, y + cornerSize, width, height - cornerSize * 2, ...)
		dxDrawRectangle(x + cornerSize, y, width - cornerSize * 2, cornerSize, ...)
		dxDrawRectangle(x, y, cornerSize, height, ...)
	end

	if alignment == "bottom" then
		dxDrawRectangle(x, y, width, height - cornerSize, ...)
	end

	if alignment == "full" then
		dxDrawRectangle(x, y + cornerSize, width, height - cornerSize * 2, ...)
	end
end