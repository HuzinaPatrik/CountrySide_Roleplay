local screenX, screenY = guiGetScreenSize()

local shaderElement = false
local browserElement = false

local volumeMultiplier = 1
local volumeDragStart = false
local currentMovieIndex = false

local gUVScale = {-0.2, 0.4}
local gUVPosition = {0.2, 0.1}
local gUVAnim = {0, 0}
local gUVRotAngle = math.rad(0)
local gColorMulti = {0.61, 0.61, 0.61, 1}
local gVertexColor = false

local cinemaStart = 0
local currentVodId = false

function loadBrowser(browser, vodId, startTime)
    if not isBrowserDomainBlocked("youtube.com") then 
        loadBrowserURL(browser, "https://www.youtube.com/embed/" .. vodId .. "?modestbranding=1&autohide=1&showinfo=0&controls=0&autoplay=1&volume=0&start=" .. math.floor(startTime / 1000))

        dxSetShaderValue(shaderElement, "gUVAnim", gUVAnim)
        dxSetShaderValue(shaderElement, "gUVScale", gUVScale)
        dxSetShaderValue(shaderElement, "gUVPosition", gUVPosition)
        dxSetShaderValue(shaderElement, "gUVRotAngle", gUVRotAngle)
        dxSetShaderValue(shaderElement, "gColorMulti", gColorMulti)
        dxSetShaderValue(shaderElement, "gVertexColor", gVertexColor)

        engineApplyShaderToWorldTexture(shaderElement, "drvin_screen")	
        dxSetShaderValue(shaderElement, "CUSTOMTEX0", browserElement)

        setBrowserVolume(browserElement, volumeMultiplier)
    else
        local syntax = exports.cr_core:getServerSyntax("Cinema", "error")

        outputChatBox(syntax .. "Kérlek engedélyezd a youtube.com domaint.", 255, 0, 0, true)
    end
end

function onClientStart()
    if isElement(shaderElement) then 
        shaderElement:destroy()
        shaderElement = nil
    end

    shaderElement = dxCreateShader("files/shaders/graphics.fx", 200)

    if isElement(browserElement) then 
        browserElement:destroy()
        browserElement = nil
    end

    browserElement = createBrowser(screenX, screenY, false)

    local volumeSave = exports.cr_json:jsonGET("vehCinemaVolumeMultiplier", true, 1)

    if volumeSave then 
        volumeMultiplier = tonumber(volumeSave)
    end

    if localPlayer:getData("loggedIn") then 
        setTimer(triggerServerEvent, 500, 1, "cinema.sync", localPlayer)
    end
end
addEventHandler("onClientResourceStart", resourceRoot, onClientStart)

function onClientStop()
    exports.cr_json:jsonSAVE("vehCinemaVolumeMultiplier", volumeMultiplier, true)
end
addEventHandler("onClientResourceStop", resourceRoot, onClientStop)

function checkDistance()
    if isElement(browserElement) then 
        local distance = getDistanceBetweenPoints3D(320.16928100586, -11.35068321228, 1.578125, getElementPosition(localPlayer))

        if isElement(browserElement) then 
            local volume = distance >= 50 and 0 or volumeMultiplier

            setBrowserVolume(browserElement, volume)
        end
    end
end
createRender("checkDistance", checkDistance)

function onCinemaStart(vodId, startTime, hoverMovieIndex)
    requestBrowserDomains({"youtube.com"})

    if not vodId then 
        return
    end

    cinemaStart = startTime
    currentVodId = vodId
    currentMovieIndex = hoverMovieIndex

    if isElement(browserElement) then 
        loadBrowser(browserElement, vodId, startTime)
    end
end
addEvent("cinema.onCinemaStart", true)
addEventHandler("cinema.onCinemaStart", root, onCinemaStart)

function onCinemaStop()
    if isElement(source) then 
        if isElement(shaderElement) then 
            shaderElement:destroy()
            shaderElement = nil
        end
    
        shaderElement = dxCreateShader("files/shaders/graphics.fx", 200)

        if isElement(browserElement) then 
            browserElement:destroy()
            browserElement = nil
        end
    
        browserElement = createBrowser(screenX, screenY, false)

        cinemaStart = false
        currentVodId = false
        currentMovieIndex = false
    end
end
addEvent("cinema.onCinemaStop", true)
addEventHandler("cinema.onCinemaStop", root, onCinemaStop)

function onClientBrowserWhitelistChange(newDomains)
    for k, v in pairs(newDomains) do 
        if v == "youtube.com" then 
            if currentVodId then 
                loadBrowser(browserElement, currentVodId, cinemaStart)
            else 
                triggerServerEvent("cinema.sync", localPlayer)
            end
            
            break
        end
    end
end
addEventHandler("onClientBrowserWhitelistChange", root, onClientBrowserWhitelistChange)

-- Movie selector

local hoverButton = false
local hoverVolume = false
local closeHover = false
local panelHover = false

local selectorModeHover = false
local selectorModeActive = false

local selectedElement = false
local hasPermissionToSeeSelector = false
local lastCinemaClickAt = 0

local cinemaMinLines = 1
local _cinemaMaxLines = 10
local cinemaMaxLines = _cinemaMaxLines

local isRender = false
local availableFactions = {4, 9}

local availableMovies = {
    {
        name = "Kincs, ami nincs",
        vodId = "L4iUmQS0uXI"
    },

    {
        name = "Made in Hungária",
        vodId = "4uyYFInms8g"
    },

    {
        name = "Bűnvadászok",
        vodId = "6sdzCv0MAas"
    },

    {
        name = "És megint dühbe jövünk",
        vodId = "SgAlcqrHD7Q"
    },

    {
        name = "Londoni csapás",
        vodId = "ViMjn4j4NKQ"
    },

    {
        name = "A köd",
        vodId = "w1_ku4Nzy2g"
    },

    {
        name = "Pixel",
        vodId = "nAPCIJyvsn4"
    },

    {
        name = "Forráskód",
        vodId = "AXNn9nDPK1s"
    },

    {
        name = "Üvegtigris",
        vodId = "kGuaDIcVG6Y"
    },

    {
        name = "Üvegtigris 2",
        vodId = "1pE6LSy33Dg"
    },

    {
        name = "Üvegtigris 3",
        vodId = "kvW-2S3qWYo"
    },

    {
        name = "Argo",
        vodId = "5ZHDrcrQEIc"
    },

    {
        name = "Pappa Pia",
        vodId = "uWH1pCfoYTA"
    },

    {
        name = "Zimmer Feri",
        vodId = "p3IQle8yFvs"
    },

    {
        name = "Vigyázat vadnyugat",
        vodId = "7CC5cyMqteI"
    },

    {
        name = "Need for Speed",
        vodId = "08YHoKX25sE"
    },

    {
        name = "Taxi 1",
        vodId = "BNpPBoZQ2iY"
    },

    {
        name = "Az éjszakai járőr",
        vodId = "UQfTvjLvw1g"
    }
}

function hasPermission(factionId, permName)
    if factionId and permName then 
        if exports.cr_dashboard:hasPlayerPermission(localPlayer, factionId, permName) or exports.cr_dashboard:isPlayerFactionLeader(localPlayer, factionId) then 
            return true
        end
    end

    return false
end

function advertiseMovieCommand(cmd, ...)
    local canAdvertise = false
    
    for k, v in pairs(availableFactions) do 
        if hasPermission(v, "gov.advertiseMovie") then 
            canAdvertise = true

            break
        end
    end

    if canAdvertise then 
        if not ... then 
            local syntax = exports.cr_core:getServerSyntax(false, "lightyellow")

            outputChatBox(syntax .. "/" .. cmd .. " [szöveg]", 255, 0, 0, true)
            return
        end

        local text = table.concat({...}, " ")

        if utf8.len(text) > 0 then 
            local greenColor = exports.cr_core:getServerColor("green", true)
            local hexColor = exports.cr_core:getServerColor("yellow", true)
            local white = "#ffffff"
            
            local adminSyntax = exports.cr_admin:getAdminSyntax()
            local localName = exports.cr_admin:getAdminName(localPlayer)

            exports.cr_core:sendMessageToAdmin(localPlayer, greenColor .. "[Blueberry Cinema]: " .. white .. text, 0)
            exports.cr_core:sendMessageToAdmin(localPlayer, adminSyntax .. hexColor .. localName .. white .. " használta a " .. hexColor .. "/" .. cmd .. white .. " parancsot.", 3)
        else
            local syntax = exports.cr_core:getServerSyntax("Cinema", "error")

            outputChatBox(syntax .. "A szövegnek minimum 1 karaktert kell tartalmaznia.", 255, 0, 0, true)
        end
    end
end
addCommandHandler("advertisemovie", advertiseMovieCommand, false, false)

function renderMovieSelector()
    local alpha, progress = exports.cr_dx:getFade("movieSelector")

    if alpha and progress then 
        if progress >= 1 and alpha <= 0 then 
            if not isRender then 
                scrollBarHover = false
                scrolling = false

                selectedElement = false
                closeHover = false

                hoverButton = false
                hoverVolume = false

                destroyRender("renderMovieSelector")

                return
            end
        end
    end

    if isElement(selectedElement) then 
        local playerX, playerY, playerZ = getElementPosition(localPlayer)

        if getDistanceBetweenPoints3D(playerX, playerY, playerZ, getElementPosition(selectedElement)) > 50 then 
            if isRender then 
                isRender = false

                processMovieSelector("exit")
            end
        end
    end

    local cursorX, cursorY = false, false

    if isCursorShowing() then 
        cursorX, cursorY = exports.cr_core:getCursorPosition()
    end

    local font = exports.cr_fonts:getFont("Poppins-SemiBold", 16)
    local font2 = exports.cr_fonts:getFont("Poppins-Medium", 12)
    local font3 = exports.cr_fonts:getFont("Poppins-Medium", 14)
    local font4 = exports.cr_fonts:getFont("Poppins-Medium", 16)
    local font5 = exports.cr_fonts:getFont("Poppins-Regular", 16)

    local redR, redG, redB = exports.cr_core:getServerColor("red", false)
    local greenR, greenG, greenB = exports.cr_core:getServerColor("green", false)

    local panelW, panelH = 400, selectorModeActive and 350 or 150
    local panelX, panelY = screenX / 2 - panelW / 2, screenY / 2 - panelH / 2
    local inSlot = exports.cr_core:isInSlot(panelX, panelY, panelW, panelH)

    panelHover = nil

    if inSlot then 
        panelHover = true
    end

    dxDrawRectangle(panelX, panelY, panelW, panelH, tocolor(51, 51, 51, alpha * 0.8))

    local logoW, logoH = 26, 30
    local logoX, logoY = panelX + 10, panelY + 8
    local headerText = selectorModeActive and "Filmválasztó" or "Autósmozi"

    dxDrawImage(logoX, logoY, logoW, logoH, "files/images/logo.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
    dxDrawText(headerText, logoX + logoW + 10, logoY + 4, logoX + logoW, logoY + logoH, tocolor(255, 255, 255, alpha), 1, font, "left", "center")

    if selectorModeActive then 
        local rowW, rowH = panelW - 20, 20
        local rowX, rowY = panelX + 10, logoY + logoH + rowH + 15

        local scrollW, scrollH = 3, rowH + (rowH * _cinemaMaxLines)
        local scrollX, scrollY = panelX + panelW - scrollW - 3, rowY

        scrollBarHover = exports.cr_core:isInSlot(scrollX, scrollY, scrollW, scrollH)
        
        -- Scrollbar

        dxDrawRectangle(scrollX, scrollY, scrollW, scrollH, tocolor(242, 242, 242, alpha * 0.6))

        local percent = #availableMovies

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

                        cinemaMinLines = math.max(1, math.floor(math.min(math.max(num, 1), (percent - _cinemaMaxLines) + 1)))
                        cinemaMaxLines = cinemaMinLines + (_cinemaMaxLines - 1)
                    end
                else
                    scrolling = false
                end
            end

            local multiplier = math.min(math.max((cinemaMaxLines - (cinemaMinLines - 1)) / percent, 0), 1)
            local multiplier2 = math.min(math.max((cinemaMinLines - 1) / percent, 0), 1)
            local gY = gY + ((gH) * multiplier2)
            local gH = gH * multiplier

            local r, g, b = 255, 59, 59
            dxDrawRectangle(gX, gY, gW, gH, tocolor(r, g, b, alpha))
        end

        hoverButton = nil

        for i = cinemaMinLines, cinemaMaxLines do 
            local rowColor = tocolor(51, 51, 51, alpha * 0.29)
            local rowTextColor = tocolor(255, 255, 255, alpha)

            local inSlot = exports.cr_core:isInSlot(rowX, rowY, rowW, rowH)

            if inSlot then 
                rowColor = tocolor(242, 242, 242, alpha)
                rowTextColor = tocolor(51, 51, 51, alpha)
            end

            dxDrawRectangle(rowX, rowY, rowW, rowH, rowColor)

            local buttonW, buttonH = 100, 15
            local buttonX, buttonY = rowX + rowW - buttonW - 5, rowY + rowH / 2 - buttonH / 2
            local buttonText = "Lejátszás"
            local inSlot = exports.cr_core:isInSlot(buttonX, buttonY, buttonW, buttonH)

            local buttonColor = tocolor(greenR, greenG, greenB, alpha * 0.7)
            local textColor = tocolor(255, 255, 255, alpha * 0.6)

            if availableMovies[i] and availableMovies[i].vodId == currentVodId then 
                buttonColor = tocolor(redR, redG, redB, alpha * 0.7)
                textColor = tocolor(255, 255, 255, alpha * 0.6)
                buttonText = "Kikapcsolás"
            end

            if inSlot then 
                if availableMovies[i] and availableMovies[i].vodId == currentVodId then 
                    hoverButton = "stop:" .. i

                    buttonColor = tocolor(redR, redG, redB, alpha)
                    textColor = tocolor(255, 255, 255, alpha)
                else
                    hoverButton = "start:" .. i

                    buttonColor = tocolor(greenR, greenG, greenB, alpha)
                    textColor = tocolor(255, 255, 255, alpha)
                end
            end

            dxDrawRectangle(buttonX, buttonY, buttonW, buttonH, buttonColor)
            dxDrawText(buttonText, buttonX, buttonY + 2, buttonX + buttonW, buttonY + buttonH, textColor, 1, font2, "center", "center")

            if availableMovies[i] then 
                local v = availableMovies[i]

                dxDrawText(v.name, rowX + 5, rowY + 4, rowX + rowW, rowY + rowH, rowTextColor, 1, font3, "left", "center")
            end

            rowY = rowY + rowH + 2
        end
    else 
        dxDrawText("Jelenlegi film:", panelX, panelY - 25, panelX + panelW, panelY + panelH, tocolor(255, 255, 255, alpha), 1, font4, "center", "center")

        local currentMovieName = currentMovieIndex and availableMovies[currentMovieIndex].name or "Nem megy film"
        dxDrawText(currentMovieName, panelX, panelY + 15, panelX + panelW, panelY + panelH, tocolor(255, 255, 255, alpha), 1, font5, "center", "center")
    end

    if hasPermissionToSeeSelector then 
        local iconW, iconH = 15, 15
        local iconX, iconY = panelX + panelW - 10 - 15 - iconW - 10, panelY + 10
        local imageColor = tocolor(255, 255, 255, alpha)

        local inSlot = exports.cr_core:isInSlot(iconX, iconY, iconW, iconH)

        selectorModeHover = nil

        if inSlot or selectorModeActive then 
            imageColor = tocolor(greenR, greenG, greenB, alpha)
            
            if inSlot then 
                selectorModeHover = true
            end
        end

        dxDrawImage(iconX, iconY, iconW, iconH, "files/images/settings.png", 0, 0, 0, imageColor)
    end

    local volumeW, volumeH = panelW - 40, 20
    local volumeX, volumeY = panelX + 20, panelY + panelH - volumeH - 20
    local inSlot = exports.cr_core:isInSlot(volumeX, volumeY, volumeW, volumeH)

    hoverVolume = nil

    if inSlot then 
        hoverVolume = true
    end

    local r, g, b = interpolateBetween(redR, redG, redB, greenR, greenG, greenB, volumeMultiplier, "InOutQuad")

    dxDrawRectangle(volumeX, volumeY, volumeW, volumeH, tocolor(51, 51, 51, alpha * 0.29))
    dxDrawRectangle(volumeX, volumeY, volumeW * volumeMultiplier, volumeH, tocolor(r, g, b, alpha))
    dxDrawText("Hangerő: " .. math.ceil(volumeMultiplier * 100) .. "%", volumeX, volumeY + 4, volumeX + volumeW, volumeY + volumeH, tocolor(255, 255, 255, alpha), 1, font3, "center", "center")

    local closeW, closeH = 15, 15
    local closeX, closeY = panelX + panelW - closeW - 10, panelY + 10
    local inSlot = exports.cr_core:isInSlot(closeX, closeY, closeW, closeH)

    local closeColor = tocolor(255, 59, 59, alpha * 0.6)

    closeHover = nil

    if inSlot then 
        closeHover = true
        closeColor = tocolor(255, 59, 59, alpha)
    end

    dxDrawImage(closeX, closeY, closeW, closeH, "files/images/close.png", 0, 0, 0, closeColor)

    if volumeDragStart then 
        volumeMultiplier = math.max(0, math.min(1, (cursorX - volumeX) / volumeW))
    end
end

function processMovieSelector(state)
    if state == "init" then 
        exports.cr_dx:startFade("movieSelector", 
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

        local canUseCinema = false

        for k, v in pairs(availableFactions) do 
            if hasPermission(v, "gov.manageCinema") then 
                canUseCinema = true

                break
            end
        end

        hasPermissionToSeeSelector = canUseCinema
        isRender = true
        createRender("renderMovieSelector", renderMovieSelector)

        removeEventHandler("onClientKey", root, onKey)
        addEventHandler("onClientKey", root, onKey)
    elseif state == "exit" then
        exports.cr_dx:startFade("movieSelector", 
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
    if button == "mouse1" then 
        if state then 
            if hoverVolume then 
                if not volumeDragStart then 
                    volumeDragStart = true
                end
            elseif closeHover then
                if isRender then 
                    isRender = false

                    processMovieSelector("exit")
                end
            elseif hoverButton then
                local selectedButton = split(hoverButton, ":")

                if selectedButton[1] then 
                    local index = tonumber(selectedButton[2])

                    if availableMovies[index] then 
                        if getTickCount() - lastCinemaClickAt >= 2000 then 
                            if selectedButton[1] == "start" then 
                                triggerServerEvent("cinema.startMovie", localPlayer, availableMovies[index].vodId, index)
                            elseif selectedButton[1] == "stop" then
                                triggerServerEvent("cinema.stopMovie", localPlayer)
                            end
                            
                            if isRender then 
                                isRender = false

                                processMovieSelector("exit")
                            end

                            lastCinemaClickAt = getTickCount()
                        end
                    end
                end
            elseif selectorModeHover then
                if hasPermissionToSeeSelector then 
                    selectorModeActive = not selectorModeActive
                end
            elseif scrollBarHover then
                if not scrolling then
                    scrolling = true
                end
            end
        else
            if volumeDragStart then 
                volumeDragStart = false
            elseif scrolling then
                scrolling = false
            end
        end
    elseif button == "mouse_wheel_down" then
        if state then 
            scrollDown()
        end
    elseif button == "mouse_wheel_up" then
        if state then 
            scrollUp()
        end
    end
end

function scrollDown()
    if panelHover and selectorModeActive then 
        if cinemaMaxLines + 1 <= #availableMovies then 
            cinemaMinLines = cinemaMinLines + 1
            cinemaMaxLines = cinemaMaxLines + 1
        end
    end
end

function scrollUp()
    if panelHover and selectorModeActive then 
        if cinemaMinLines - 1 > 0 then 
            cinemaMinLines = cinemaMinLines - 1
            cinemaMaxLines = cinemaMaxLines - 1
        end
    end
end

function onClick(button, state, absX, absY, worldX, worldY, worldZ, clickedElement)
    if button ~= "middle" then 
        if isElement(clickedElement) then 
            if clickedElement.model == 16000 then 
                if getDistanceBetweenPoints3D(localPlayer.position, clickedElement.position) <= 50 then 
                    if not isRender and not closeHover and not selectorModeHover and not hoverButton then 
                        selectedElement = clickedElement
                        processMovieSelector("init")
                    end
                end
            end
        end
    end
end
addEventHandler("onClientClick", root, onClick)