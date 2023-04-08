local screenX, screenY = guiGetScreenSize()
local dxDrawMultiplier = math.min(1.25, screenX / 1280)

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

local alpha = 0

local actionHover = false
local needFade = false

local switchingToMainMdcPanel = false
local switchingToUnitPanel = false

local mainPanelActive = false
local unitPanelActive = false

local selectedDuty = false
local vehicleUnit = false

local quittingFromMDC = false
local forcedByCommand = false
local selectedAccount = false

local hoverMenu = false

local isMoving = false
local moveOffsetX = false
local moveOffsetY = false

local pwX, pwY, pwW, pwH = false, false, false, false
local gPwX, gPwY, gPwW, gPwH = false, false, false, false

local mdcMoveHover = false
local adminMenuHover = false
local logMenuHover = false
local penalCodeMenuHover = false

local closeHover = false
local searchHover = false
local wantedCarsHover = false
local wantedPersonsHover = false

local ticketsHover = false
local wantedWeaponsHover = false

local weaponRegistrationHover = false
local vehicleRegistrationHover = false
local addressRegistrationHover = false
local trafficRegistrationHover = false

adminCheckHover = false
local mdcAdminDataHover = false

local deleteButtonHover = false
local mdcLogsHover = false

local hoverSubMenu = false
local punishmentHover = false
local passwordManageHover = false

local addNewUserHover = false
local ticketButtonHover = false

mdcWantedCars = {}
mdcWantedPersons = {}
mdcTickets = {}
mdcWantedWeapons = {}

mdcRegisteredWeapons = {}
mdcRegisteredVehicles = {}
mdcRegisteredAddresses = {}
mdcRegisteredTraffices = {}

mdcAdminData = {}
mdcAdminDataKeys = {}
mdcLogs = {}
mdcLoggedAccounts = {}
mdcLoginCount = 0

local deleteButtonActions = {
    {
        triggerName = "onClientDeleteWantedCar",
        permName = "mdc.deleteWantedPerson"
    },

    {
        triggerName = "onClientDeleteWantedPerson",
        permName = "mdc.deleteWantedPerson"
    },

    {
        triggerName = "onClientDeleteTicket",
        permName = "mdc.deleteTicket"
    },

    {
        triggerName = "onClientDeleteWantedWeapon",
        permName = "mdc.deleteWantedWeapon"
    },

    {
        triggerName = "onClientDeleteRegisteredWeapon",
        permName = "mdc.deleteRegisteredWeapon"
    },

    {
        triggerName = "onClientDeleteRegisteredVehicle",
        permName = "mdc.deleteRegisteredVehicle"
    },

    {
        triggerName = "onClientDeleteRegisteredAddress",
        permName = "mdc.deleteRegisteredAddress"
    },

    {
        triggerName = "onClientDeleteRegisteredTraffic",
        permName = "mdc.deleteRegisteredTraffic"
    },

    {
        triggerName = "onClientDeleteUser",
        permName = "mdc.admin"
    }
}

local mdcDutyBlips = {}

local textures = {}
local textureDeleteTimer = false

local lastInteractionTick = 0
local interactionDelayTime = 500

local oldData = false
local scrollBarHover = false

function createTextures()
    textures.tablet = ":cr_mdc/files/images/tablet.png"
    textures.logo = ":cr_mdc/files/images/logos/pd.png"
    textures.usernameIcon = ":cr_mdc/files/images/username.png"
    textures.passwordIcon = ":cr_mdc/files/images/password.png"
    textures.unitNumber = ":cr_mdc/files/images/unitnr.png"
    textures.circle = ":cr_mdc/files/images/circle.png"
    textures.search = ":cr_mdc/files/images/search.png"
    textures.log = ":cr_mdc/files/images/log.png"
    textures.admin = ":cr_mdc/files/images/admin.png"
    textures.book = ":cr_mdc/files/images/book.png"
    textures.quit = ":cr_mdc/files/images/quit.png"
    textures.check = ":cr_mdc/files/images/check.png"
    textures.trash_nohover = ":cr_mdc/files/images/trash_nohover.png"
    textures.trash_hover = ":cr_mdc/files/images/trash_hover.png"
end

function destroyTextures()
    textures = {}
    collectgarbage("collect")
end

function hasPermission(factionId, permName)
    if factionId and permName then 
        if exports.cr_dashboard:hasPlayerPermission(localPlayer, factionId, permName) or exports.cr_dashboard:isPlayerFactionLeader(localPlayer, factionId) then 
            return true
        end
    end

    return false
end

function renderMDC()
    local alpha, progress = exports["cr_dx"]:getFade("mdcPanel")
    if alpha and progress then 
        if progress >= 1 then 
            if alpha <= 0 then 
                if not switchingToMainMdcPanel and not switchingToUnitPanel then 
                    destroyRender("renderMDC")

                    selectedMenu = 1
                    selectedSubMenu = 1

                    if isTimer(textureDeleteTimer) then 
                        killTimer(textureDeleteTimer)
                        textureDeleteTimer = nil
                    end

                    textureDeleteTimer = setTimer(destroyTextures, 2000, 1)
                    
                    selectedDuty = false
                    if quittingFromMDC then 
                        quittingFromMDC = false
                        mainPanelActive = false
                        selectedDuty = false
                    end
                else 
                    if not switchingToUnitPanel then 
                        switchingToMainMdcPanel = false
                        unitPanelActive = false
                        mainPanelActive = true

                        exports["cr_dx"]:startFade("mdcPanel", 
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

                        manageTextbars("destroy")
                        manageTextbars("create")
                    else 
                        switchingToUnitPanel = false
                        unitPanelActive = true

                        manageTextbars("destroy")
                        manageTextbars("create")

                        exports["cr_dx"]:startFade("mdcPanel", 
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
                end
            end
        end
    end

    if not mainPanelActive and not unitPanelActive then 
        -- local _, x, y = exports["cr_interface"]:getDetails("mdcLoginPanel")
        local w, h = resp(1500), resp(900)
        local x, y = screenX / 2 - w / 2, screenY / 2 - h / 2
        local font = exports.cr_fonts:getFont("Poppins-Medium", getRealFontSize(15))
        local font2 = exports.cr_fonts:getFont("Poppins-Medium", getRealFontSize(13))

        local realW, realH = w / 2 + resp(190), h / 2 + resp(101)
        local realX, realY = x + realW / 4 + resp(45), y + realH / 4 + resp(37)

        mdcMoveHover = nil
        if exports.cr_core:isInSlot(realX, realY - resp(20), realW, resp(20)) then 
            mdcMoveHover = true
        end

        if isCursorShowing() then 
            if isMoving then 
                local cursorX, cursorY = exports.cr_core:getCursorPosition()

                exports.cr_interface:setNode("mdcLoginPanel", "x", cursorX - moveOffsetX)
                exports.cr_interface:setNode("mdcLoginPanel", "y", cursorY - moveOffsetY)
            end
        end

        dxDrawRectangle(realX, realY, realW, realH, tocolor(10, 13, 21, alpha))
        exports.cr_dx:dxDrawImageAsTexture(x, y, w, h, textures.tablet, 0, 0, 0, tocolor(255, 255, 255, alpha))

        local imgW, imgH = resp(256), resp(256)
        local widthWithoutCrop = resp(250)
        local logoPadding = resp(7)

        local distanceBetween = resp(45)
        local imgX, imgY = realX - distanceBetween + widthWithoutCrop + (imgW / 2) + logoPadding, realY + imgH / 4 - resp(44)
        local buttonPadding = resp(10)

        exports.cr_dx:dxDrawImageAsTexture(imgX, imgY, imgW, imgH, textures.logo, 0, 0, 0, tocolor(255, 255, 255, alpha))

        local userNameInputW, userNameInputH = resp(300), resp(35)
        local userNameInputX, userNameInputY = realX + imgW + (userNameInputW / 4) - logoPadding, realY + imgH + userNameInputH

        dxDrawRectangle(userNameInputX, userNameInputY, userNameInputW, userNameInputH, tocolor(255, 255, 255, alpha * 0.8))

        UpdatePos("mdcLogin.username", {userNameInputX, userNameInputY + resp(2), userNameInputW, userNameInputH})
        UpdateAlpha("mdcLogin.username", tocolor(122, 122, 124, alpha))

        local iconW, iconH = resp(32), resp(32)
        local iconX, iconY = userNameInputX + resp(4), userNameInputY + resp(1)

        exports.cr_dx:dxDrawImageAsTexture(iconX, iconY, iconW, iconH, textures.usernameIcon, 0, 0, 0, tocolor(122, 124, 124, alpha))
        
        local pipeW, pipeH = 1, userNameInputH - resp(6)
        local pipeX, pipeY = iconX + iconW + resp(3), iconY + resp(2)

        dxDrawRectangle(pipeX, pipeY, pipeW, pipeH, tocolor(122, 124, 124, alpha))

        local passwordInputX, passwordInputY = userNameInputX, userNameInputY + userNameInputH + buttonPadding

        dxDrawRectangle(passwordInputX, passwordInputY, userNameInputW, userNameInputH, tocolor(255, 255, 255, alpha * 0.8))
        -- dxDrawText("password", passwordInputX, passwordInputY + resp(4), passwordInputX + userNameInputW, passwordInputY + userNameInputH, tocolor(122, 122, 124, alpha), 1, font2, "center", "center")

        UpdatePos("mdcLogin.password", {passwordInputX, passwordInputY + resp(2), userNameInputW, userNameInputH})
        UpdateAlpha("mdcLogin.password", tocolor(122, 122, 124, alpha))

        local iconY = iconY + buttonPadding + userNameInputH + resp(1)

        exports.cr_dx:dxDrawImageAsTexture(iconX, iconY, iconW, iconH, textures.passwordIcon, 0, 0, 0, tocolor(122, 124, 124, alpha))
        
        local pipeW, pipeH = 1, userNameInputH - resp(6)
        local pipeX, pipeY = iconX + iconW + resp(3), iconY + resp(2)

        dxDrawRectangle(pipeX, pipeY, pipeW, pipeH, tocolor(122, 124, 124, alpha))

        local loginButtonW, loginButtonH = resp(200), resp(35)
        local loginButtonX, loginButtonY = userNameInputX + loginButtonW / 4, passwordInputY + userNameInputH + loginButtonH - buttonPadding
        local r, g, b = exports.cr_core:getServerColor("green", false)
        local inSlot = exports.cr_core:isInSlot(loginButtonX, loginButtonY, loginButtonW, loginButtonH)

        local buttonColor = tocolor(r, g, b, alpha * 0.7)
        local textColor = tocolor(255, 255, 255, alpha * 0.6)

        actionHover = nil
        if inSlot then 
            buttonColor = tocolor(r, g, b, alpha)
            textColor = tocolor(255, 255, 255, alpha)
            actionHover = "login"
        end

        dxDrawRectangle(loginButtonX, loginButtonY, loginButtonW, loginButtonH, buttonColor)
        dxDrawText("Bejelentkezés", loginButtonX, loginButtonY + resp(4), loginButtonX + loginButtonW, loginButtonY + loginButtonH, textColor, 1, font, "center", "center")
    elseif unitPanelActive then 
        local w, h = resp(1500), resp(900)
        local x, y = screenX / 2 - w / 2, screenY / 2 - h / 2
        local font = exports.cr_fonts:getFont("Poppins-Medium", getRealFontSize(15))
        local font2 = exports.cr_fonts:getFont("Poppins-Medium", getRealFontSize(13))

        local realW, realH = w / 2 + resp(190), h / 2 + resp(101)
        local realX, realY = x + realW / 4 + resp(45), y + realH / 4 + resp(37)

        -- mdcMoveHover = nil
        -- if exports.cr_core:isInSlot(realX, realY - resp(20), realW, resp(20)) then 
        --     mdcMoveHover = true
        -- end

        -- if isCursorShowing() then 
        --     if isMoving then 
        --         local cursorX, cursorY = exports.cr_core:getCursorPosition()

        --         exports.cr_interface:setNode("mdcLoginPanel", "x", cursorX - moveOffsetX)
        --         exports.cr_interface:setNode("mdcLoginPanel", "y", cursorY - moveOffsetY)
        --     end
        -- end

        dxDrawRectangle(realX, realY, realW, realH, tocolor(10, 13, 21, alpha))
        exports.cr_dx:dxDrawImageAsTexture(x, y, w, h, textures.tablet, 0, 0, 0, tocolor(255, 255, 255, alpha))

        local imgW, imgH = resp(256), resp(256)
        local widthWithoutCrop = resp(250)
        local logoPadding = resp(7)

        local distanceBetween = resp(45)
        local imgX, imgY = realX - distanceBetween + widthWithoutCrop + (imgW / 2) + logoPadding, realY + imgH / 4 - resp(44)
        local buttonPadding = resp(10)

        exports.cr_dx:dxDrawImageAsTexture(imgX, imgY, imgW, imgH, textures.logo, 0, 0, 0, tocolor(255, 255, 255, alpha))

        local unitInputW, unitInputH = resp(300), resp(35)
        local unitInputX, unitInputY = realX + imgW + (unitInputW / 4) - logoPadding, realY + imgH + unitInputH

        dxDrawRectangle(unitInputX, unitInputY, unitInputW, unitInputH, tocolor(255, 255, 255, alpha * 0.8))
        -- dxDrawText("username", userNameInputX, userNameInputY + resp(4), userNameInputX + userNameInputW, userNameInputY + userNameInputH, tocolor(122, 122, 124, alpha), 1, font2, "center", "center")

        UpdatePos("mdcUnit.unit", {unitInputX, unitInputY + resp(2), unitInputW, unitInputH})
        UpdateAlpha("mdcUnit.unit", tocolor(122, 122, 124, alpha))

        local iconW, iconH = resp(32), resp(32)
        local iconX, iconY = unitInputX + resp(4), unitInputY + resp(2)

        exports.cr_dx:dxDrawImageAsTexture(iconX, iconY, iconW, iconH, textures.unitNumber, 0, 0, 0, tocolor(122, 124, 124, alpha))
        
        local pipeW, pipeH = 1, unitInputH - resp(6)
        local pipeX, pipeY = iconX + iconW + resp(3), iconY + resp(2)

        dxDrawRectangle(pipeX, pipeY, pipeW, pipeH, tocolor(122, 124, 124, alpha))

        local unitButtonW, unitButtonH = resp(200), resp(35)
        local unitButtonX, unitButtonY = unitInputX + unitButtonW / 4, unitInputY + unitInputH + unitButtonH - buttonPadding
        local r, g, b = exports.cr_core:getServerColor("green", false)
        local inSlot = exports.cr_core:isInSlot(unitButtonX, unitButtonY, unitButtonW, unitButtonH)

        local buttonColor = tocolor(r, g, b, alpha * 0.7)
        local textColor = tocolor(255, 255, 255, alpha * 0.6)

        actionHover = nil
        if inSlot then 
            buttonColor = tocolor(r, g, b, alpha)
            textColor = tocolor(255, 255, 255, alpha)
            actionHover = "login"
        end

        dxDrawRectangle(unitButtonX, unitButtonY, unitButtonW, unitButtonH, buttonColor)
        dxDrawText("Tovább", unitButtonX, unitButtonY + resp(4), unitButtonX + unitButtonW, unitButtonY + unitButtonH, textColor, 1, font, "center", "center")
    else
        local w, h = resp(1500), resp(900)
        local x, y = screenX / 2 - w / 2, screenY / 2 - h / 2
        local font = exports.cr_fonts:getFont("Poppins-Medium", getRealFontSize(15))
        local font2 = exports.cr_fonts:getFont("Poppins-Medium", getRealFontSize(13))
        local font3 = exports.cr_fonts:getFont("Poppins-Bold", getRealFontSize(11))
        local font4 = exports.cr_fonts:getFont("Poppins-Medium", getRealFontSize(11))
        local font5 = exports.cr_fonts:getFont("Poppins-Medium", getRealFontSize(9))
        local font6 = exports.cr_fonts:getFont("Poppins-Bold", getRealFontSize(9))

        local redHex = exports.cr_core:getServerColor("red", true)
        local greenHex = exports.cr_core:getServerColor("green", true)
        local orangeHex = exports.cr_core:getServerColor("orange", true)

        local rr, rg, rb = exports.cr_core:getServerColor("red", false)
        local gr, gg, gb = exports.cr_core:getServerColor("green", false)
        local yr, yg, yb = exports.cr_core:getServerColor("yellow", false)

        local realW, realH = w / 2 + resp(190), h / 2 + resp(101)
        local realX, realY = x + realW / 4 + resp(45), y + realH / 4 + resp(37)

        dxDrawRectangle(realX, realY, realW, realH, tocolor(10, 13, 21, alpha))
        exports.cr_dx:dxDrawImageAsTexture(x, y, w, h, textures.tablet, 0, 0, 0, tocolor(255, 255, 255, alpha))

        local imgW, imgH = resp(128), resp(128)
        local widthWithoutCrop = resp(250)
        local logoPadding = resp(7)

        local distanceBetween = resp(45)
        local imgX, imgY = realX + imgW / 2, realY + (imgH / 4) - resp(24)
        local buttonPadding = resp(10)

        exports.cr_dx:dxDrawImageAsTexture(imgX, imgY, imgW, imgH, textures.logo, 0, 0, 0, tocolor(255, 255, 255, alpha))
        dxDrawText("Egységszám: " .. redHex .. vehicleUnit, imgX, imgY, imgX + imgW, imgY + imgH + resp(10), tocolor(255, 255, 255, alpha * 0.8), 1, font2, "center", "bottom", false, false, false, true)

        local buttonW, buttonH = resp(180), resp(26)
        local buttonX, buttonY = realX + buttonW / 4 - resp(10), realY + imgH + buttonH

        deleteButtonHover = nil
        hoverMenu = nil
        for i = menusMinLine, menusMaxLine do 
            local v = menus[i]
            local inSlot = exports.cr_core:isInSlot(buttonX, buttonY, buttonW, buttonH)
            local buttonColor = tocolor(26, 32, 59, alpha * 0.71)
            local textColor = tocolor(255, 255, 255, alpha * 0.6)

            if inSlot then 
                hoverMenu = i
                
                buttonColor = tocolor(61, 74, 134, alpha)
                textColor = tocolor(255, 255, 255, alpha)
            else
                if selectedMenu == i then 
                    buttonColor = tocolor(61, 74, 134, alpha)
                    textColor = tocolor(255, 255, 255, alpha)
                end
            end

            dxDrawRectangle(buttonX, buttonY, buttonW, buttonH, buttonColor)
            dxDrawText(v.name, buttonX, buttonY + resp(4), buttonX + buttonW, buttonY + buttonH, textColor, 1, font3, "center", "center")

            buttonY = buttonY + buttonH + resp(7)
        end

        local hexCode = redHex
        local dutyText = "Szolgálat: " .. hexCode .. "OFF"

        if selectedDuty then 
            hexCode = greenHex
            dutyText = "Szolgálat: " .. hexCode .. "ON"
        end

        dxDrawText(dutyText, buttonX, buttonY, buttonX + buttonW, buttonY + buttonH, tocolor(255, 255, 255, alpha * 0.8), 1, font2, "left", "bottom", false, false, false, true)
        dxDrawText("Kérlek válassz szolgálat típust!", buttonX, buttonY, buttonX + buttonW, buttonY + buttonH + resp(20), tocolor(255, 255, 255, alpha * 0.8), 1, font2, "left", "bottom")

        local circleW, circleH = resp(50), resp(50)
        local circleX, circleY = realX + circleW - resp(2), buttonY + circleH

        activeHover = nil
        for i = circlesMinLine, circlesMaxLine do 
            local inSlot = exports.cr_core:isInSlot(circleX, circleY, circleW, circleH)
            local imageColor = tocolor(255, 255, 255, alpha * 0.6)
            local textColor = tocolor(255, 255, 255, alpha * 0.6)

            if inSlot then 
                activeHover = i

                imageColor = tocolor(61, 74, 134, alpha)
                textColor = tocolor(255, 255, 255, alpha)
            else
                if selectedDuty == i then 
                    imageColor = tocolor(61, 74, 134, alpha)
                    textColor = tocolor(255, 255, 255, alpha)
                end
            end

            exports.cr_dx:dxDrawImageAsTexture(circleX, circleY, circleW, circleH, textures.circle, 0, 0, 0, imageColor)
            dxDrawText(i, circleX, circleY + resp(4), circleX + circleW, circleY + circleH, textColor, 1, font, "center", "center")

            circleX = circleX + circleW + resp(5)
        end

        local hexCode = redHex
        local text = "Jelenleg " .. hexCode .. "offline" .. white .. " státuszban vagy!"

        if selectedDuty then 
            text = "Jelenleg " .. hexCode .. mdcDutyTypes[selectedDuty] .. white .. " státuszban vagy!"
        end

        dxDrawText(text, buttonX + resp(5), circleY, buttonX + buttonW, circleY + circleH + resp(27), tocolor(255, 255, 255, alpha * 0.8), 1, font2, "center", "bottom", false, false, false, true)

        local quitW, quitH = resp(32), resp(32)
        local iconX, quitY = realX + realW - quitW - resp(15), realY + resp(16)
        local quitColor = tocolor(255, 255, 255, alpha * 0.6)

        local hoverW, hoverH = quitW - resp(10), quitH - resp(10)
        local hoverX, hoverY = iconX + resp(5), quitY + resp(5)
        local inSlot = exports.cr_core:isInSlot(hoverX, hoverY, hoverW, hoverH)

        closeHover = nil
        if inSlot then
            quitColor = tocolor(rr, rg, rb, alpha)
            closeHover = true

            local textWidth = dxGetTextWidth("Kijelentkezés", 1, font3)

            exports.cr_dx:dxDrawImageAsTexture(iconX, quitY, quitW, quitH, textures.quit, 0, 0, 0, quitColor)
            dxDrawText("Kijelentkezés", iconX - textWidth, quitY + resp(4), iconX + quitW, quitY + quitH, quitColor, 1, font3, "left", "center")

            iconX = iconX - textWidth
        else 
            exports.cr_dx:dxDrawImageAsTexture(iconX, quitY, quitW, quitH, textures.quit, 0, 0, 0, quitColor)
        end

        local bookW, bookH = resp(32), resp(32)
        local bookX, bookY = iconX - bookW, quitY
        local bookColor = tocolor(255, 255, 255, alpha * 0.6)

        local hoverW, hoverH = bookW - resp(10), bookH - resp(10)
        local hoverX, hoverY = bookX + resp(5), bookY + resp(5)
        local inSlot = exports.cr_core:isInSlot(hoverX, hoverY, hoverW, hoverH)

        penalCodeMenuHover = nil
        if inSlot then 
            bookColor = tocolor(rr, rg, rb, alpha)
            penalCodeMenuHover = true

            local textWidth = dxGetTextWidth("Penal Code", 1, font3)

            exports.cr_dx:dxDrawImageAsTexture(bookX, bookY, bookW, bookH, textures.book, 0, 0, 0, bookColor)
            dxDrawText("Penal Code", bookX - textWidth, bookY + resp(4), iconX + bookW, bookY + bookH, tocolor(rr, rg, rb, alpha), 1, font3, "left", "center")

            iconX = iconX - textWidth
        else
            if selectedMenu == 11 then 
                bookColor = tocolor(rr, rg, rb, alpha)

                local textWidth = dxGetTextWidth("Penal Code", 1, font3)

                exports.cr_dx:dxDrawImageAsTexture(bookX, bookY, bookW, bookH, textures.book, 0, 0, 0, bookColor)
                dxDrawText("Penal Code", bookX - textWidth, bookY + resp(4), iconX + bookW, bookY + bookH, tocolor(rr, rg, rb, alpha), 1, font3, "left", "center")

                iconX = iconX - textWidth
            else
                exports.cr_dx:dxDrawImageAsTexture(bookX, bookY, bookW, bookH, textures.book, 0, 0, 0, bookColor)
            end
        end

        local adminW, adminH = resp(32), resp(32)
        local adminX, adminY = iconX - bookW - adminW, bookY
        local adminColor = tocolor(255, 255, 255, alpha * 0.6)

        local hoverW, hoverH = adminW - resp(10), adminH - resp(10)
        local hoverX, hoverY = adminX + resp(5), adminY + resp(5)
        local inSlot = exports.cr_core:isInSlot(hoverX, hoverY, hoverW, hoverH)

        adminMenuHover = nil
        if inSlot then 
            adminColor = tocolor(rr, rg, rb, alpha)
            adminMenuHover = true

            local textWidth = dxGetTextWidth("Admin felület", 1, font3)

            exports.cr_dx:dxDrawImageAsTexture(adminX, adminY, adminW, adminH, textures.admin, 0, 0, 0, adminColor)
            dxDrawText("Admin felület", adminX - textWidth, adminY + resp(4), adminX + adminW, adminY + adminH, tocolor(rr, rg, rb, alpha), 1, font3, "left", "center")

            iconX = iconX - textWidth
        else
            if selectedMenu == 9 then 
                adminColor = tocolor(rr, rg, rb, alpha)

                local textWidth = dxGetTextWidth("Admin felület", 1, font3)

                exports.cr_dx:dxDrawImageAsTexture(adminX, adminY, adminW, adminH, textures.admin, 0, 0, 0, adminColor)
                dxDrawText("Admin felület", adminX - textWidth, adminY + resp(4), adminX + adminW, adminY + adminH, tocolor(rr, rg, rb, alpha), 1, font3, "left", "center")
    
                iconX = iconX - textWidth
            else
                exports.cr_dx:dxDrawImageAsTexture(adminX, adminY, adminW, adminH, textures.admin, 0, 0, 0, adminColor)
            end
        end

        local logW, logH = resp(32), resp(32)
        local logX, logY = iconX - bookW - adminW - logW, adminY
        local logColor = tocolor(255, 255, 255, alpha * 0.6)

        local hoverW, hoverH = logW - resp(10), logH - resp(10)
        local hoverX, hoverY = logX + resp(5), logY + resp(5)
        local inSlot = exports.cr_core:isInSlot(hoverX, hoverY, hoverW, hoverH)

        logMenuHover = nil
        if inSlot then 
            logColor = tocolor(rr, rg, rb, alpha)
            logMenuHover = true

            local textWidth = dxGetTextWidth("Log", 1, font3)

            exports.cr_dx:dxDrawImageAsTexture(logX, logY, logW, logH, textures.log, 0, 0, 0, logColor)
            dxDrawText("Log", logX - textWidth, logY + resp(4), logX + logW, logY + logH, tocolor(rr, rg, rb, alpha), 1, font3, "left", "center")
        else
            if selectedMenu == 10 then 
                logColor = tocolor(rr, rg, rb, alpha)

                local textWidth = dxGetTextWidth("Log", 1, font3)

                exports.cr_dx:dxDrawImageAsTexture(logX, logY, logW, logH, textures.log, 0, 0, 0, logColor)
                dxDrawText("Log", logX - textWidth, logY + resp(4), logX + logW, logY + logH, tocolor(rr, rg, rb, alpha), 1, font3, "left", "center")
            else
                exports.cr_dx:dxDrawImageAsTexture(logX, logY, logW, logH, textures.log, 0, 0, 0, logColor)
            end
        end

        if selectedMenu == 1 then 
            local wantedCarsW, wantedCarsH = resp(680), resp(280)
            local wantedCarsX, wantedCarsY = realX + buttonW + resp(60), buttonY - wantedCarsH - resp(40) - buttonPadding
            local rowPadding = resp(5)
            local inSlot = exports.cr_core:isInSlot(wantedCarsX, wantedCarsY, wantedCarsW, wantedCarsH)
            
            wantedCarsHover = nil
            if inSlot then 
                wantedCarsHover = true
            end

            dxDrawRectangle(wantedCarsX, wantedCarsY, wantedCarsW, wantedCarsH, tocolor(51, 51, 51, alpha * 0.29))

            dxDrawText("Típus", wantedCarsX + resp(15), wantedCarsY + resp(7), wantedCarsX + wantedCarsW, wantedCarsY + wantedCarsH, tocolor(255, 255, 255, alpha), 1, font3, "left", "top")
            dxDrawText("Rendszám", wantedCarsX + resp(150), wantedCarsY + resp(7), wantedCarsX + wantedCarsW, wantedCarsY + wantedCarsH, tocolor(255, 255, 255, alpha), 1, font3, "left", "top")
            dxDrawText("Indok", wantedCarsX + resp(350), wantedCarsY + resp(7), wantedCarsX + wantedCarsW, wantedCarsY + wantedCarsH, tocolor(255, 255, 255, alpha), 1, font3, "left", "top")

            local scrollW, scrollH = 3, wantedCarsH - resp(30) - rowPadding
            local scrollX, scrollY = wantedCarsX + wantedCarsW - scrollW, wantedCarsY + resp(30)

            scrollBarHover = exports.cr_core:isInSlot(scrollX, scrollY, scrollW, scrollH)
            
            -- Scrollbar

            dxDrawRectangle(scrollX, scrollY, scrollW, scrollH, tocolor(242, 242, 242, alpha * 0.6))

            local percent = #mdcWantedCars

            if mdcWantedCarsSearchCache then
                percent = #mdcWantedCarsSearchCache
            end

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

                            mdcWantedCarsMinLine = math.max(1, math.floor(math.min(math.max(num, 1), (percent - _mdcWantedCarsMaxLine) + 1)))
                            mdcWantedCarsMaxLine = mdcWantedCarsMinLine + (_mdcWantedCarsMaxLine - 1)
                        end
                    else
                        scrolling = false
                    end
                end

                local multiplier = math.min(math.max((mdcWantedCarsMaxLine - (mdcWantedCarsMinLine - 1)) / percent, 0), 1)
                local multiplier2 = math.min(math.max((mdcWantedCarsMinLine - 1) / percent, 0), 1)
                local gY = gY + ((gH) * multiplier2)
                local gH = gH * multiplier

                local r, g, b = 255, 59, 59
                dxDrawRectangle(gX, gY, gW, gH, tocolor(r, g, b, alpha))
            end

            local wantedCarsLineW, wantedCarsLineH = wantedCarsW - (rowPadding * 4), resp(20)
            local wantedCarsLineX, wantedCarsLineY = wantedCarsX + (rowPadding * 2), wantedCarsY + wantedCarsLineH + (rowPadding * 2)

            local array = mdcWantedCars
            local percent = #array

            if mdcWantedCarsSearchCache then 
                array = mdcWantedCarsSearchCache
                percent = #array
            end

            if mdcWantedCarsMaxLine > percent then 
                mdcWantedCarsMinLine = 1
                _mdcWantedCarsMaxLine = 10
                mdcWantedCarsMaxLine = _mdcWantedCarsMaxLine
            end

            for i = mdcWantedCarsMinLine, mdcWantedCarsMaxLine do 
                local v = array[i]
                
                local inSlot = exports.cr_core:isInSlot(wantedCarsLineX, wantedCarsLineY, wantedCarsLineW, wantedCarsLineH)
                local rowColor = tocolor(51, 51, 51, alpha * 0.29)
                local textColor = tocolor(255, 255, 255, alpha)

                if inSlot then 
                    rowColor = tocolor(255, 255, 255, alpha * 0.8)
                    textColor = tocolor(51, 51, 51, alpha)
                end

                dxDrawRectangle(wantedCarsLineX, wantedCarsLineY, wantedCarsLineW, wantedCarsLineH, rowColor)
                
                if v and v.vehicleType then
                    local vehicleType = v.vehicleType
                    local vehiclePlateText = v.vehiclePlateText
                    local reason = v.reason
                    
                    local vehicleTypeAvailableForHover = false

                    if utf8.len(vehicleType) > 15 then 
                        clippedVehicleType = utf8.sub(vehicleType, 1, -(utf8.len(vehicleType) - 15)) .. "..."
                        vehicleTypeAvailableForHover = true
                    end

                    if vehicleTypeAvailableForHover then 
                        local hoverLineW, hoverLineH = resp(110), wantedCarsLineH
                        local hoverLineX, hoverLineY = wantedCarsLineX + resp(5), wantedCarsLineY
                        local inSlot = exports.cr_core:isInSlot(hoverLineX, hoverLineY, hoverLineW, hoverLineH)

                        if inSlot then 
                            exports.cr_dx:drawTooltip(1, vehicleType)
                        end
                    end

                    local text = vehicleTypeAvailableForHover and clippedVehicleType or vehicleType

                    dxDrawText(text, wantedCarsLineX + (rowPadding * 2) - resp(4), wantedCarsLineY + resp(4), wantedCarsLineX + wantedCarsLineW, wantedCarsLineY + wantedCarsLineH, textColor, 1, font4, "left", "center")
                    dxDrawText(vehiclePlateText, wantedCarsLineX + resp(140), wantedCarsLineY + resp(4), wantedCarsLineX + wantedCarsLineW, wantedCarsLineY + wantedCarsLineH, textColor, 1, font4, "left", "center")
                    
                    local trashW, trashH = resp(32), resp(32)
                    local lineY = wantedCarsLineY + wantedCarsLineH / 2 - resp(2)

                    local trashX, trashY = wantedCarsLineX + wantedCarsLineW - trashW, lineY - trashH / 2 + resp(1.5)
                    local trashColor = tocolor(rr, rg, rb, alpha * 0.7)
                    local trashTexture = textures.trash_nohover

                    local hoverW, hoverH = resp(14), resp(16)
                    local hoverX, hoverY = trashX + hoverW / 2 + resp(2), trashY + hoverH / 2
                    local inSlot = exports.cr_core:isInSlot(hoverX, hoverY, hoverW, hoverH)

                    if inSlot then 
                        trashColor = tocolor(rr, rg, rb, alpha)
                        trashTexture = textures.trash_hover
                        deleteButtonHover = i

                        dxDrawText("Törlés", trashX - trashW, trashY + resp(4), trashX + trashW, trashY + trashH, tocolor(rr, rg, rb, alpha), 1, font3, "left", "center")
                    end

                    exports.cr_dx:dxDrawImageAsTexture(trashX, trashY, trashW, trashH, trashTexture, 0, 0, 0, trashColor)

                    local availableForHover = false

                    if utf8.len(reason) > 30 then 
                        clippedReason = utf8.sub(reason, 1, -(utf8.len(reason) - 30)) .. "..."
                        availableForHover = true
                    end

                    if availableForHover then 
                        local hoverLineW, hoverLineH = wantedCarsLineW / 2 - resp(84), wantedCarsLineH
                        local hoverLineX, hoverLineY = wantedCarsLineX + wantedCarsLineW - hoverLineW - resp(74), wantedCarsLineY
                        local inSlot = exports.cr_core:isInSlot(hoverLineX, hoverLineY, hoverLineW, hoverLineH)

                        if inSlot then 
                            exports.cr_dx:drawTooltip(1, reason)
                        end
                    end

                    local text = availableForHover and clippedReason or reason
                    dxDrawText(text, wantedCarsLineX + resp(340), wantedCarsLineY + resp(4), wantedCarsLineX + wantedCarsLineW, wantedCarsLineY + wantedCarsLineH, textColor, 1, font4, "left", "center")
                end

                wantedCarsLineY = wantedCarsLineY + wantedCarsLineH + rowPadding
            end

            -- 280, 18 - search

            local searchW, searchH = resp(280), resp(18)
            local searchX, searchY = wantedCarsX + wantedCarsW - searchW, wantedCarsY - searchH - rowPadding

            dxDrawRectangle(searchX, searchY, searchW, searchH, tocolor(51, 51, 51, alpha * 0.29))
            -- dxDrawText("Search", searchX + rowPadding, searchY + resp(4), searchX + searchW, searchY + searchH, tocolor(255, 255, 255, alpha * 0.8), 1, font4, "left", "center")

            UpdatePos("mdc.search", {searchX + rowPadding, searchY + resp(2), searchW - rowPadding, searchH})
            UpdateAlpha("mdc.search", tocolor(255, 255, 255, alpha * 0.8))

            local searchIconW, searchIconH = resp(32), resp(32)
            local searchIconX, searchIconY = searchX + searchW - searchIconW + (rowPadding / 2), searchY - resp(7)

            exports.cr_dx:dxDrawImageAsTexture(searchIconX, searchIconY, searchIconW, searchIconH, textures.search, 0, 0, 0, tocolor(255, 255, 255, alpha * 0.8))

            local ticketW, ticketH = wantedCarsW, resp(155)
            local ticketX, ticketY = realX + buttonW + resp(60), buttonY - ticketH / 2 + resp(40)

            dxDrawRectangle(ticketX, ticketY, ticketW, ticketH, tocolor(51, 51, 51, alpha * 0.29))
            dxDrawText("Körözés kiadása", ticketX + resp(15), ticketY + resp(10), ticketX + ticketW, ticketY + ticketH, tocolor(255, 255, 255, alpha), 1, font3, "left", "top")

            local vehInputW, vehInputH = resp(400), resp(20)
            local vehInputX, vehInputY = ticketX + resp(15), ticketY + (vehInputH * 2)
            local inputPadding = resp(5)

            dxDrawRectangle(vehInputX, vehInputY, vehInputW, vehInputH, tocolor(51, 51, 51, alpha * 0.6))
            dxDrawText("Jármű típusa:", vehInputX + resp(4), vehInputY + resp(4), vehInputX + vehInputW, vehInputY + vehInputH, tocolor(255, 255, 255, alpha * 0.8), 1, font4, "left", "center")

            local textWidth = dxGetTextWidth("Jármű típusa:", 1, font4)

            UpdatePos("mdc.wantedCarType", {vehInputX + textWidth + resp(8), vehInputY + resp(2), vehInputW - textWidth - resp(8), vehInputH})
            UpdateAlpha("mdc.wantedCarType", tocolor(255, 255, 255, alpha * 0.8))

            local plateInputX, plateInputY = vehInputX, vehInputY + vehInputH + inputPadding

            dxDrawRectangle(plateInputX, plateInputY, vehInputW, vehInputH, tocolor(51, 51, 51, alpha * 0.6))
            dxDrawText("Rendszám:", plateInputX + resp(4), plateInputY + resp(4), plateInputX + vehInputW, plateInputY + vehInputH, tocolor(255, 255, 255, alpha * 0.8), 1, font4, "left", "center")

            local textWidth = dxGetTextWidth("Rendszám:", 1, font4)

            UpdatePos("mdc.wantedCarPlate", {plateInputX + textWidth + resp(8), plateInputY + resp(2), vehInputW - textWidth - resp(8), vehInputH})
            UpdateAlpha("mdc.wantedCarPlate", tocolor(255, 255, 255, alpha * 0.8))

            local reasonInputX, reasonInputY = vehInputX, plateInputY + vehInputH + inputPadding

            dxDrawRectangle(reasonInputX, reasonInputY, vehInputW, vehInputH, tocolor(51, 51, 51, alpha * 0.6))
            dxDrawText("Indok:", reasonInputX + resp(4), reasonInputY + resp(4), reasonInputX + vehInputW, reasonInputY + vehInputH, tocolor(255, 255, 255, alpha * 0.8), 1, font4, "left", "center")

            local textWidth = dxGetTextWidth("Indok:", 1, font4)

            UpdatePos("mdc.wantedCarReason", {reasonInputX + textWidth + resp(8), reasonInputY + resp(2), vehInputW - textWidth - resp(8), vehInputH})
            UpdateAlpha("mdc.wantedCarReason", tocolor(255, 255, 255, alpha * 0.8))

            local buttonW, buttonH = resp(200), resp(25)
            local buttonX, buttonY = ticketX + ticketW - buttonW - buttonPadding, ticketY + ticketH - buttonH - buttonPadding
            local inSlot = exports.cr_core:isInSlot(buttonX, buttonY, buttonW, buttonH)
            
            local buttonColor = tocolor(gr, gg, gb, alpha * 0.7)
            local textColor = tocolor(255, 255, 255, alpha * 0.6)

            ticketButtonHover = nil
            if inSlot then 
                buttonColor = tocolor(gr, gg, gb, alpha)
                textColor = tocolor(255, 255, 255, alpha)
                ticketButtonHover = true
            end

            dxDrawRectangle(buttonX, buttonY, buttonW, buttonH, buttonColor)
            dxDrawText("Körözés kiadása", buttonX, buttonY + resp(4), buttonX + buttonW, buttonY + buttonH, textColor, 1, font2, "center", "center")
        elseif selectedMenu == 2 then 
            local wantedPersonsW, wantedPersonsH = resp(680), resp(280)
            local wantedPersonsX, wantedPersonsY = realX + buttonW + resp(60), buttonY - wantedPersonsH - resp(40) - buttonPadding
            local rowPadding = resp(5)
            local inSlot = exports.cr_core:isInSlot(wantedPersonsX, wantedPersonsY, wantedPersonsW, wantedPersonsH)
            
            wantedPersonsHover = nil
            if inSlot then 
                wantedPersonsHover = true
            end

            dxDrawRectangle(wantedPersonsX, wantedPersonsY, wantedPersonsW, wantedPersonsH, tocolor(51, 51, 51, alpha * 0.29))

            dxDrawText("Név", wantedPersonsX + resp(15), wantedPersonsY + resp(7), wantedPersonsX + wantedPersonsW, wantedPersonsY + wantedPersonsH, tocolor(255, 255, 255, alpha), 1, font3, "left", "top")
            dxDrawText("Nemzetiség", wantedPersonsX + resp(150), wantedPersonsY + resp(7), wantedPersonsX + wantedPersonsW, wantedPersonsY + wantedPersonsH, tocolor(255, 255, 255, alpha), 1, font3, "left", "top")
            dxDrawText("Személy leírás", wantedPersonsX + resp(280), wantedPersonsY + resp(7), wantedPersonsX + wantedPersonsW, wantedPersonsY + wantedPersonsH, tocolor(255, 255, 255, alpha), 1, font3, "left", "top")
            dxDrawText("Indok", wantedPersonsX + resp(380), wantedPersonsY + resp(7), wantedPersonsX + wantedPersonsW, wantedPersonsY + wantedPersonsH, tocolor(255, 255, 255, alpha), 1, font3, "center", "top")

            local scrollW, scrollH = 3, wantedPersonsH - resp(30) - rowPadding
            local scrollX, scrollY = wantedPersonsX + wantedPersonsW - scrollW, wantedPersonsY + resp(30)

            scrollBarHover = exports.cr_core:isInSlot(scrollX, scrollY, scrollW, scrollH)
            
            -- Scrollbar

            dxDrawRectangle(scrollX, scrollY, scrollW, scrollH, tocolor(242, 242, 242, alpha * 0.6))

            local percent = #mdcWantedPersons

            if mdcWantedPersonsSearchCache then
                percent = #mdcWantedPersonsSearchCache
            end

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

                            mdcWantedPersonsMinLine = math.max(1, math.floor(math.min(math.max(num, 1), (percent - _mdcWantedPersonsMaxLine) + 1)))
                            mdcWantedPersonsMaxLine = mdcWantedPersonsMinLine + (_mdcWantedPersonsMaxLine - 1)
                        end
                    else
                        scrolling = false
                    end
                end

                local multiplier = math.min(math.max((mdcWantedPersonsMaxLine - (mdcWantedPersonsMinLine - 1)) / percent, 0), 1)
                local multiplier2 = math.min(math.max((mdcWantedPersonsMinLine - 1) / percent, 0), 1)
                local gY = gY + ((gH) * multiplier2)
                local gH = gH * multiplier

                local r, g, b = 255, 59, 59
                dxDrawRectangle(gX, gY, gW, gH, tocolor(r, g, b, alpha))
            end

            local wantedPersonsLineW, wantedPersonsLineH = wantedPersonsW - (rowPadding * 4), resp(20)
            local wantedPersonsLineX, wantedPersonsLineY = wantedPersonsX + (rowPadding * 2), wantedPersonsY + wantedPersonsLineH + (rowPadding * 2)

            local array = mdcWantedPersons
            local percent = #array

            if mdcWantedPersonsSearchCache then 
                array = mdcWantedPersonsSearchCache
                percent = #array
            end

            if mdcWantedPersonsMaxLine > percent then 
                mdcWantedPersonsMinLine = 1
                _mdcWantedPersonsMaxLine = 10
                mdcWantedPersonsMaxLine = _mdcWantedPersonsMaxLine
            end

            for i = mdcWantedPersonsMinLine, mdcWantedPersonsMaxLine do 
                local v = array[i]
                
                local inSlot = exports.cr_core:isInSlot(wantedPersonsLineX, wantedPersonsLineY, wantedPersonsLineW, wantedPersonsLineH)
                local rowColor = tocolor(51, 51, 51, alpha * 0.29)
                local textColor = tocolor(255, 255, 255, alpha)

                if inSlot then 
                    rowColor = tocolor(255, 255, 255, alpha * 0.8)
                    textColor = tocolor(51, 51, 51, alpha)
                end

                dxDrawRectangle(wantedPersonsLineX, wantedPersonsLineY, wantedPersonsLineW, wantedPersonsLineH, rowColor)
                
                if v and v.name then
                    local name = v.name
                    local nationality = v.nationality
                    local description = v.description
                    local reason = v.reason
                    
                    dxDrawText(name:gsub("_", " "), wantedPersonsLineX + (rowPadding * 2) - resp(4), wantedPersonsLineY + resp(4), wantedPersonsLineX + wantedPersonsLineW, wantedPersonsLineY + wantedPersonsLineH, textColor, 1, font4, "left", "center")
                    dxDrawText(nationality, wantedPersonsLineX + resp(140), wantedPersonsLineY + resp(4), wantedPersonsLineX + wantedPersonsLineW, wantedPersonsLineY + wantedPersonsLineH, textColor, 1, font4, "left", "center")
                    
                    local trashW, trashH = resp(32), resp(32)
                    local lineY = wantedPersonsLineY + wantedPersonsLineH / 2 - resp(2)

                    local trashX, trashY = wantedPersonsLineX + wantedPersonsLineW - trashW, lineY - trashH / 2 + resp(1.5)
                    local trashColor = tocolor(rr, rg, rb, alpha * 0.7)
                    local trashTexture = textures.trash_nohover

                    local hoverW, hoverH = resp(14), resp(16)
                    local hoverX, hoverY = trashX + hoverW / 2 + resp(2), trashY + hoverH / 2
                    local inSlot = exports.cr_core:isInSlot(hoverX, hoverY, hoverW, hoverH)

                    if inSlot then 
                        trashColor = tocolor(rr, rg, rb, alpha)
                        trashTexture = textures.trash_hover
                        deleteButtonHover = i

                        dxDrawText("Törlés", trashX - trashW, trashY + resp(4), trashX + trashW, trashY + trashH, tocolor(rr, rg, rb, alpha), 1, font3, "left", "center")
                    end

                    exports.cr_dx:dxDrawImageAsTexture(trashX, trashY, trashW, trashH, trashTexture, 0, 0, 0, trashColor)

                    local availableForDescriptionHover = false

                    if utf8.len(description) > 30 then 
                        clippedDescription = utf8.sub(description, 1, -(utf8.len(description) - 30)) .. "..."
                        availableForDescriptionHover = true
                    end

                    local text = availableForDescriptionHover and clippedDescription or description
                    dxDrawText(text, wantedPersonsLineX + resp(270), wantedPersonsLineY + resp(4), wantedPersonsLineX + wantedPersonsLineW, wantedPersonsLineY + wantedPersonsLineH, textColor, 1, font4, "left", "center")
                    
                    local availableForReasonHover = false

                    if utf8.len(reason) > 10 then 
                        clippedReason = utf8.sub(reason, 1, -(utf8.len(reason) - 10)) .. "..."
                        availableForReasonHover = true
                    end

                    local text = availableForReasonHover and clippedReason or reason
                    dxDrawText(text, wantedPersonsLineX + wantedPersonsLineW / 2 + resp(173), wantedPersonsLineY + resp(4), wantedPersonsLineX + wantedPersonsLineW, wantedPersonsLineY + wantedPersonsLineH, textColor, 1, font4, "left", "center")

                    if availableForDescriptionHover then 
                        local hoverLineW, hoverLineH = wantedPersonsLineW / 4 + resp(18), wantedPersonsLineH
                        local hoverLineX, hoverLineY = wantedPersonsLineX + hoverLineW + resp(105) - resp(18), wantedPersonsLineY
                        local inSlot = exports.cr_core:isInSlot(hoverLineX, hoverLineY, hoverLineW, hoverLineH)

                        if inSlot then 
                            exports.cr_dx:drawTooltip(1, description)
                        end
                    end

                    if availableForReasonHover then 
                        local hoverLineW, hoverLineH = wantedPersonsLineW / 4 - resp(95), wantedPersonsLineH
                        local hoverLineX, hoverLineY = wantedPersonsLineX + wantedPersonsLineW - hoverLineW - resp(90), wantedPersonsLineY
                        local inSlot = exports.cr_core:isInSlot(hoverLineX, hoverLineY, hoverLineW, hoverLineH)

                        if inSlot then 
                            exports.cr_dx:drawTooltip(1, reason)
                        end
                    end
                end

                wantedPersonsLineY = wantedPersonsLineY + wantedPersonsLineH + rowPadding
            end

            -- 280, 18 - search

            local searchW, searchH = resp(280), resp(18)
            local searchX, searchY = wantedPersonsX + wantedPersonsW - searchW, wantedPersonsY - searchH - rowPadding

            dxDrawRectangle(searchX, searchY, searchW, searchH, tocolor(51, 51, 51, alpha * 0.29))
            -- dxDrawText("Search", searchX + rowPadding, searchY + resp(4), searchX + searchW, searchY + searchH, tocolor(255, 255, 255, alpha * 0.8), 1, font4, "left", "center")

            UpdatePos("mdc.search", {searchX + rowPadding, searchY + resp(2), searchW - rowPadding, searchH})
            UpdateAlpha("mdc.search", tocolor(255, 255, 255, alpha * 0.8))

            local searchIconW, searchIconH = resp(32), resp(32)
            local searchIconX, searchIconY = searchX + searchW - searchIconW + (rowPadding / 2), searchY - resp(7)

            exports.cr_dx:dxDrawImageAsTexture(searchIconX, searchIconY, searchIconW, searchIconH, textures.search, 0, 0, 0, tocolor(255, 255, 255, alpha * 0.8))

            local ticketW, ticketH = wantedPersonsW, resp(155)
            local ticketX, ticketY = realX + buttonW + resp(60), buttonY - ticketH / 2 + resp(40)

            dxDrawRectangle(ticketX, ticketY, ticketW, ticketH, tocolor(51, 51, 51, alpha * 0.29))
            dxDrawText("Körözés kiadása", ticketX + resp(15), ticketY + resp(10), ticketX + ticketW, ticketY + ticketH, tocolor(255, 255, 255, alpha), 1, font3, "left", "top")

            local nameInputW, nameInputH = resp(400), resp(20)
            local nameInputX, nameInputY = ticketX + resp(15), ticketY + (nameInputH * 2)
            local inputPadding = resp(5)

            dxDrawRectangle(nameInputX, nameInputY, nameInputW, nameInputH, tocolor(51, 51, 51, alpha * 0.6))
            dxDrawText("Név:", nameInputX + resp(4), nameInputY + resp(4), nameInputX + nameInputW, nameInputY + nameInputH, tocolor(255, 255, 255, alpha * 0.8), 1, font4, "left", "center")

            local textWidth = dxGetTextWidth("Név:", 1, font4)

            UpdatePos("mdc.wantedPersonName", {nameInputX + textWidth + resp(8), nameInputY + resp(2), nameInputW - textWidth - resp(8), nameInputH})
            UpdateAlpha("mdc.wantedPersonName", tocolor(255, 255, 255, alpha * 0.8))

            local nationalityInputX, nationalityInputY = nameInputX, nameInputY + nameInputH + inputPadding

            dxDrawRectangle(nationalityInputX, nationalityInputY, nameInputW, nameInputH, tocolor(51, 51, 51, alpha * 0.6))
            dxDrawText("Nemzetiség:", nationalityInputX + resp(4), nationalityInputY + resp(4), nationalityInputX + nameInputW, nationalityInputY + nameInputH, tocolor(255, 255, 255, alpha * 0.8), 1, font4, "left", "center")

            local textWidth = dxGetTextWidth("Nemzetiség:", 1, font4)

            UpdatePos("mdc.wantedPersonNationality", {nationalityInputX + textWidth + resp(8), nationalityInputY + resp(2), nameInputW - textWidth - resp(8), nameInputH})
            UpdateAlpha("mdc.wantedPersonNationality", tocolor(255, 255, 255, alpha * 0.8))

            local descriptionInputX, descriptionInputY = nameInputX, nationalityInputY + nameInputH + inputPadding

            dxDrawRectangle(descriptionInputX, descriptionInputY, nameInputW, nameInputH, tocolor(51, 51, 51, alpha * 0.6))
            dxDrawText("Személy leírás:", descriptionInputX + resp(4), descriptionInputY + resp(4), descriptionInputX + nameInputW, descriptionInputY + nameInputH, tocolor(255, 255, 255, alpha * 0.8), 1, font4, "left", "center")

            local textWidth = dxGetTextWidth("Személy leírás:", 1, font4)

            UpdatePos("mdc.wantedPersonDescription", {descriptionInputX + textWidth + resp(8), descriptionInputY + resp(2), nameInputW - textWidth - resp(8), nameInputH})
            UpdateAlpha("mdc.wantedPersonDescription", tocolor(255, 255, 255, alpha * 0.8))

            local reasonInputX, reasonInputY = nameInputX, descriptionInputY + nameInputH + inputPadding

            dxDrawRectangle(reasonInputX, reasonInputY, nameInputW, nameInputH, tocolor(51, 51, 51, alpha * 0.6))
            dxDrawText("Indok:", reasonInputX + resp(4), reasonInputY + resp(4), reasonInputX + nameInputW, reasonInputY + nameInputH, tocolor(255, 255, 255, alpha * 0.8), 1, font4, "left", "center")

            local textWidth = dxGetTextWidth("Indok:", 1, font4)

            UpdatePos("mdc.wantedPersonReason", {reasonInputX + textWidth + resp(8), reasonInputY + resp(2), nameInputW - textWidth - resp(8), nameInputH})
            UpdateAlpha("mdc.wantedPersonReason", tocolor(255, 255, 255, alpha * 0.8))

            local buttonW, buttonH = resp(200), resp(25)
            local buttonX, buttonY = ticketX + ticketW - buttonW - buttonPadding, ticketY + ticketH - buttonH - buttonPadding
            local inSlot = exports.cr_core:isInSlot(buttonX, buttonY, buttonW, buttonH)
            
            local buttonColor = tocolor(gr, gg, gb, alpha * 0.7)
            local textColor = tocolor(255, 255, 255, alpha * 0.6)

            ticketButtonHover = nil
            if inSlot then 
                buttonColor = tocolor(gr, gg, gb, alpha)
                textColor = tocolor(255, 255, 255, alpha)
                ticketButtonHover = true
            end

            dxDrawRectangle(buttonX, buttonY, buttonW, buttonH, buttonColor)
            dxDrawText("Körözés kiadása", buttonX, buttonY + resp(4), buttonX + buttonW, buttonY + buttonH, textColor, 1, font2, "center", "center")
        elseif selectedMenu == 3 then 
            local ticketW, ticketH = resp(680), resp(280)
            local ticketX, ticketY = realX + buttonW + resp(60), buttonY - ticketH - resp(40) - buttonPadding
            local rowPadding = resp(5)
            local inSlot = exports.cr_core:isInSlot(ticketX, ticketY, ticketW, ticketH)
            
            ticketsHover = nil
            if inSlot then 
                ticketsHover = true
            end

            dxDrawRectangle(ticketX, ticketY, ticketW, ticketH, tocolor(51, 51, 51, alpha * 0.29))

            dxDrawText("Név", ticketX + resp(15), ticketY + resp(7), ticketX + ticketW, ticketY + ticketH, tocolor(255, 255, 255, alpha), 1, font3, "left", "top")
            dxDrawText("Börtönbüntetés", ticketX + resp(150), ticketY + resp(7), ticketX + ticketW, ticketY + ticketH, tocolor(255, 255, 255, alpha), 1, font3, "left", "top")
            dxDrawText("Bírság", ticketX + resp(350), ticketY + resp(7), ticketX + ticketW, ticketY + ticketH, tocolor(255, 255, 255, alpha), 1, font3, "left", "top")
            dxDrawText("Indok", ticketX + resp(300), ticketY + resp(7), ticketX + ticketW, ticketY + ticketH, tocolor(255, 255, 255, alpha), 1, font3, "center", "top")

            local scrollW, scrollH = 3, ticketH - resp(30) - rowPadding
            local scrollX, scrollY = ticketX + ticketW - scrollW, ticketY + resp(30)

            scrollBarHover = exports.cr_core:isInSlot(scrollX, scrollY, scrollW, scrollH)
            
            -- Scrollbar

            dxDrawRectangle(scrollX, scrollY, scrollW, scrollH, tocolor(242, 242, 242, alpha * 0.6))

            local percent = #mdcTickets

            if mdcTicketsSearchCache then
                percent = #mdcTicketsSearchCache
            end

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

                            mdcTicketsMinLine = math.max(1, math.floor(math.min(math.max(num, 1), (percent - _mdcTicketsMaxLine) + 1)))
                            mdcTicketsMaxLine = mdcTicketsMinLine + (_mdcTicketsMaxLine - 1)
                        end
                    else
                        scrolling = false
                    end
                end

                local multiplier = math.min(math.max((mdcTicketsMaxLine - (mdcTicketsMinLine - 1)) / percent, 0), 1)
                local multiplier2 = math.min(math.max((mdcTicketsMinLine - 1) / percent, 0), 1)
                local gY = gY + ((gH) * multiplier2)
                local gH = gH * multiplier

                local r, g, b = 255, 59, 59
                dxDrawRectangle(gX, gY, gW, gH, tocolor(r, g, b, alpha))
            end

            local ticketLineW, ticketLineH = ticketW - (rowPadding * 4), resp(20)
            local ticketLineX, ticketLineY = ticketX + (rowPadding * 2), ticketY + ticketLineH + (rowPadding * 2)

            local array = mdcTickets
            local percent = #array

            if mdcTicketsSearchCache then 
                array = mdcTicketsSearchCache
                percent = #array
            end

            if mdcTicketsMaxLine > percent then 
                mdcTicketsMinLine = 1
                _mdcTicketsMaxLine = 10
                mdcTicketsMaxLine = _mdcTicketsMaxLine
            end

            for i = mdcTicketsMinLine, mdcTicketsMaxLine do 
                local v = array[i]
                
                local inSlot = exports.cr_core:isInSlot(ticketLineX, ticketLineY, ticketLineW, ticketLineH)
                local rowColor = tocolor(51, 51, 51, alpha * 0.29)
                local textColor = tocolor(255, 255, 255, alpha)
                local dollarSignColor = tocolor(gr, gg, gb, alpha)
                local dollarSignTextWidth = dxGetTextWidth("$", 1, font3, true)

                if inSlot then 
                    rowColor = tocolor(255, 255, 255, alpha * 0.8)
                    textColor = tocolor(51, 51, 51, alpha)
                    dollarSignColor = tocolor(51, 51, 51, alpha)
                end

                dxDrawRectangle(ticketLineX, ticketLineY, ticketLineW, ticketLineH, rowColor)
                
                if v and v.name then
                    local name = v.name
                    local jailTime = v.jailTime
                    local penalty = v.penalty
                    local reason = v.reason
                    
                    dxDrawText(name:gsub("_", " "), ticketLineX + (rowPadding * 2) - resp(4), ticketLineY + resp(4), ticketLineX + ticketLineW, ticketLineY + ticketLineH, textColor, 1, font4, "left", "center")
                    dxDrawText(jailTime .. " perc", ticketLineX - ticketLineW / 2 + resp(40), ticketLineY + resp(4), ticketLineX + ticketLineW, ticketLineY + ticketLineH, textColor, 1, font4, "center", "center")
                    dxDrawText("$", ticketLineX + resp(340), ticketLineY + resp(5), ticketLineX + ticketLineW, ticketLineY + ticketLineH, dollarSignColor, 1, font3, "left", "center")
                    dxDrawText(penalty, ticketLineX + resp(340) + dollarSignTextWidth + resp(3), ticketLineY + resp(4), ticketLineX + ticketLineW, ticketLineY + ticketLineH, textColor, 1, font4, "left", "center")
                    
                    local trashW, trashH = resp(32), resp(32)
                    local lineY = ticketLineY + ticketLineH / 2 - resp(2)

                    local trashX, trashY = ticketLineX + ticketLineW - trashW, lineY - trashH / 2 + resp(1.5)
                    local trashColor = tocolor(rr, rg, rb, alpha * 0.7)
                    local trashTexture = textures.trash_nohover

                    local hoverW, hoverH = resp(14), resp(16)
                    local hoverX, hoverY = trashX + hoverW / 2 + resp(2), trashY + hoverH / 2
                    local inSlot = exports.cr_core:isInSlot(hoverX, hoverY, hoverW, hoverH)

                    if inSlot then 
                        trashColor = tocolor(rr, rg, rb, alpha)
                        trashTexture = textures.trash_hover
                        deleteButtonHover = i

                        dxDrawText("Törlés", trashX - trashW, trashY + resp(4), trashX + trashW, trashY + trashH, tocolor(rr, rg, rb, alpha), 1, font3, "left", "center")
                    end

                    exports.cr_dx:dxDrawImageAsTexture(trashX, trashY, trashW, trashH, trashTexture, 0, 0, 0, trashColor)

                    local availableForReasonHover = false

                    if utf8.len(reason) > 15 then 
                        clippedReason = utf8.sub(reason, 1, -(utf8.len(reason) - 15)) .. "..."
                        availableForReasonHover = true
                    end

                    local text = availableForReasonHover and clippedReason or reason
                    dxDrawText(text, ticketLineX + ticketLineW / 2 + resp(135), ticketLineY + resp(4), ticketLineX + ticketLineW, ticketLineY + ticketLineH, textColor, 1, font4, "left", "center")

                    if availableForReasonHover then 
                        local hoverLineW, hoverLineH = ticketLineW / 2 - resp(205), ticketLineH
                        local hoverLineX, hoverLineY = ticketLineX + ticketLineW - hoverLineW - resp(70), ticketLineY
                        local inSlot = exports.cr_core:isInSlot(hoverLineX, hoverLineY, hoverLineW, hoverLineH)

                        if inSlot then 
                            exports.cr_dx:drawTooltip(1, reason)
                        end
                    end
                end

                ticketLineY = ticketLineY + ticketLineH + rowPadding
            end

            -- 280, 18 - search

            local searchW, searchH = resp(280), resp(18)
            local searchX, searchY = ticketX + ticketW - searchW, ticketY - searchH - rowPadding

            dxDrawRectangle(searchX, searchY, searchW, searchH, tocolor(51, 51, 51, alpha * 0.29))
            -- dxDrawText("Search", searchX + rowPadding, searchY + resp(4), searchX + searchW, searchY + searchH, tocolor(255, 255, 255, alpha * 0.8), 1, font4, "left", "center")

            UpdatePos("mdc.search", {searchX + rowPadding, searchY + resp(2), searchW - rowPadding, searchH})
            UpdateAlpha("mdc.search", tocolor(255, 255, 255, alpha * 0.8))

            local searchIconW, searchIconH = resp(32), resp(32)
            local searchIconX, searchIconY = searchX + searchW - searchIconW + (rowPadding / 2), searchY - resp(7)

            exports.cr_dx:dxDrawImageAsTexture(searchIconX, searchIconY, searchIconW, searchIconH, textures.search, 0, 0, 0, tocolor(255, 255, 255, alpha * 0.8))

            local ticketW, ticketH = ticketW, resp(155)
            local ticketX, ticketY = realX + buttonW + resp(60), buttonY - ticketH / 2 + resp(40)

            dxDrawRectangle(ticketX, ticketY, ticketW, ticketH, tocolor(51, 51, 51, alpha * 0.29))
            dxDrawText("Büntetés kiadása", ticketX + resp(15), ticketY + resp(10), ticketX + ticketW, ticketY + ticketH, tocolor(255, 255, 255, alpha), 1, font3, "left", "top")

            local nameInputW, nameInputH = resp(400), resp(20)
            local nameInputX, nameInputY = ticketX + resp(15), ticketY + (nameInputH * 2)
            local inputPadding = resp(5)

            dxDrawRectangle(nameInputX, nameInputY, nameInputW, nameInputH, tocolor(51, 51, 51, alpha * 0.6))
            dxDrawText("Név:", nameInputX + resp(4), nameInputY + resp(4), nameInputX + nameInputW, nameInputY + nameInputH, tocolor(255, 255, 255, alpha * 0.8), 1, font4, "left", "center")

            local textWidth = dxGetTextWidth("Név:", 1, font4)

            UpdatePos("mdc.ticketName", {nameInputX + textWidth + resp(8), nameInputY + resp(2), nameInputW - textWidth - resp(8), nameInputH})
            UpdateAlpha("mdc.ticketName", tocolor(255, 255, 255, alpha * 0.8))

            local ticketInputX, ticketInputY = nameInputX, nameInputY + nameInputH + inputPadding

            dxDrawRectangle(ticketInputX, ticketInputY, nameInputW, nameInputH, tocolor(51, 51, 51, alpha * 0.6))
            dxDrawText("Bírság:", ticketInputX + resp(4), ticketInputY + resp(4), ticketInputX + nameInputW, ticketInputY + nameInputH, tocolor(255, 255, 255, alpha * 0.8), 1, font4, "left", "center")

            local textWidth = dxGetTextWidth("Bírság:", 1, font4)

            UpdatePos("mdc.penalty", {ticketInputX + textWidth + resp(8), ticketInputY + resp(2), nameInputW - textWidth - resp(8), nameInputH})
            UpdateAlpha("mdc.penalty", tocolor(255, 255, 255, alpha * 0.8))

            local jailInputX, jailInputY = nameInputX, ticketInputY + nameInputH + inputPadding

            dxDrawRectangle(jailInputX, jailInputY, nameInputW, nameInputH, tocolor(51, 51, 51, alpha * 0.6))
            dxDrawText("Börtönbüntetés:", jailInputX + resp(4), jailInputY + resp(4), jailInputX + nameInputW, jailInputY + nameInputH, tocolor(255, 255, 255, alpha * 0.8), 1, font4, "left", "center")

            local textWidth = dxGetTextWidth("Börtönbüntetés:", 1, font4)

            UpdatePos("mdc.jailTime", {jailInputX + textWidth + resp(8), jailInputY + resp(2), nameInputW - textWidth - resp(8), nameInputH})
            UpdateAlpha("mdc.jailTime", tocolor(255, 255, 255, alpha * 0.8))

            local reasonInputX, reasonInputY = nameInputX, jailInputY + nameInputH + inputPadding

            dxDrawRectangle(reasonInputX, reasonInputY, nameInputW, nameInputH, tocolor(51, 51, 51, alpha * 0.6))
            dxDrawText("Indok:", reasonInputX + resp(4), reasonInputY + resp(4), reasonInputX + nameInputW, reasonInputY + nameInputH, tocolor(255, 255, 255, alpha * 0.8), 1, font4, "left", "center")

            local textWidth = dxGetTextWidth("Indok:", 1, font4)

            UpdatePos("mdc.ticketReason", {reasonInputX + textWidth + resp(8), reasonInputY + resp(2), nameInputW - textWidth - resp(8), nameInputH})
            UpdateAlpha("mdc.ticketReason", tocolor(255, 255, 255, alpha * 0.8))

            local buttonW, buttonH = resp(200), resp(25)
            local buttonX, buttonY = ticketX + ticketW - buttonW - buttonPadding, ticketY + ticketH - buttonH - buttonPadding
            local inSlot = exports.cr_core:isInSlot(buttonX, buttonY, buttonW, buttonH)
            
            local buttonColor = tocolor(gr, gg, gb, alpha * 0.7)
            local textColor = tocolor(255, 255, 255, alpha * 0.6)

            ticketButtonHover = nil
            if inSlot then 
                buttonColor = tocolor(gr, gg, gb, alpha)
                textColor = tocolor(255, 255, 255, alpha)
                ticketButtonHover = true
            end

            dxDrawRectangle(buttonX, buttonY, buttonW, buttonH, buttonColor)
            dxDrawText("Új büntetés", buttonX, buttonY + resp(4), buttonX + buttonW, buttonY + buttonH, textColor, 1, font2, "center", "center")
        elseif selectedMenu == 4 then 
            local wantedWeaponsW, wantedWeaponsH = resp(680), resp(280)
            local wantedWeaponsX, wantedWeaponsY = realX + buttonW + resp(60), buttonY - wantedWeaponsH - resp(40) - buttonPadding
            local rowPadding = resp(5)
            local inSlot = exports.cr_core:isInSlot(wantedWeaponsX, wantedWeaponsY, wantedWeaponsW, wantedWeaponsH)
            
            wantedWeaponsHover = nil
            if inSlot then 
                wantedWeaponsHover = true
            end

            dxDrawRectangle(wantedWeaponsX, wantedWeaponsY, wantedWeaponsW, wantedWeaponsH, tocolor(51, 51, 51, alpha * 0.29))

            dxDrawText("Fegyver neve", wantedWeaponsX + resp(15), wantedWeaponsY + resp(7), wantedWeaponsX + wantedWeaponsW, wantedWeaponsY + wantedWeaponsH, tocolor(255, 255, 255, alpha), 1, font3, "left", "top")
            dxDrawText("Típus", wantedWeaponsX + resp(150), wantedWeaponsY + resp(7), wantedWeaponsX + wantedWeaponsW, wantedWeaponsY + wantedWeaponsH, tocolor(255, 255, 255, alpha), 1, font3, "left", "top")
            dxDrawText("Sorozatszám", wantedWeaponsX + resp(300), wantedWeaponsY + resp(7), wantedWeaponsX + wantedWeaponsW, wantedWeaponsY + wantedWeaponsH, tocolor(255, 255, 255, alpha), 1, font3, "left", "top")
            dxDrawText("Indok", wantedWeaponsX + resp(230), wantedWeaponsY + resp(7), wantedWeaponsX + wantedWeaponsW, wantedWeaponsY + wantedWeaponsH, tocolor(255, 255, 255, alpha), 1, font3, "center", "top")

            local scrollW, scrollH = 3, wantedWeaponsH - resp(30) - rowPadding
            local scrollX, scrollY = wantedWeaponsX + wantedWeaponsW - scrollW, wantedWeaponsY + resp(30)

            scrollBarHover = exports.cr_core:isInSlot(scrollX, scrollY, scrollW, scrollH)
            
            -- Scrollbar

            dxDrawRectangle(scrollX, scrollY, scrollW, scrollH, tocolor(242, 242, 242, alpha * 0.6))

            local percent = #mdcWantedWeapons

            if mdcWantedWeaponsSearchCache then
                percent = #mdcWantedWeaponsSearchCache
            end

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

                            mdcWantedWeaponsMinLine = math.max(1, math.floor(math.min(math.max(num, 1), (percent - _mdcWantedWeaponsMaxLine) + 1)))
                            mdcWantedWeaponsMaxLine = mdcWantedWeaponsMinLine + (_mdcWantedWeaponsMaxLine - 1)
                        end
                    else
                        scrolling = false
                    end
                end

                local multiplier = math.min(math.max((mdcWantedWeaponsMaxLine - (mdcWantedWeaponsMinLine - 1)) / percent, 0), 1)
                local multiplier2 = math.min(math.max((mdcWantedWeaponsMinLine - 1) / percent, 0), 1)
                local gY = gY + ((gH) * multiplier2)
                local gH = gH * multiplier

                local r, g, b = 255, 59, 59
                dxDrawRectangle(gX, gY, gW, gH, tocolor(r, g, b, alpha))
            end

            local wantedWeaponsLineW, wantedWeaponsLineH = wantedWeaponsW - (rowPadding * 4), resp(20)
            local wantedWeaponsLineX, wantedWeaponsLineY = wantedWeaponsX + (rowPadding * 2), wantedWeaponsY + wantedWeaponsLineH + (rowPadding * 2)

            local array = mdcWantedWeapons
            local percent = #array

            if mdcWantedWeaponsSearchCache then 
                array = mdcWantedWeaponsSearchCache
                percent = #array
            end

            if mdcWantedWeaponsMaxLine > percent then 
                mdcWantedWeaponsMinLine = 1
                _mdcWantedWeaponsMaxLine = 10
                mdcWantedWeaponsMaxLine = _mdcWantedWeaponsMaxLine
            end

            for i = mdcWantedWeaponsMinLine, mdcWantedWeaponsMaxLine do 
                local v = array[i]
                
                local inSlot = exports.cr_core:isInSlot(wantedWeaponsLineX, wantedWeaponsLineY, wantedWeaponsLineW, wantedWeaponsLineH)
                local rowColor = tocolor(51, 51, 51, alpha * 0.29)
                local textColor = tocolor(255, 255, 255, alpha)

                if inSlot then 
                    rowColor = tocolor(255, 255, 255, alpha * 0.8)
                    textColor = tocolor(51, 51, 51, alpha)
                end

                dxDrawRectangle(wantedWeaponsLineX, wantedWeaponsLineY, wantedWeaponsLineW, wantedWeaponsLineH, rowColor)
                
                if v and v.weaponName then
                    local weaponName = v.weaponName
                    local weaponType = v.weaponType
                    local weaponSerial = v.weaponSerial
                    local reason = v.reason
                    
                    dxDrawText(weaponName, wantedWeaponsLineX + (rowPadding * 2) - resp(4), wantedWeaponsLineY + resp(4), wantedWeaponsLineX + wantedWeaponsLineW, wantedWeaponsLineY + wantedWeaponsLineH, textColor, 1, font4, "left", "center")
                    dxDrawText(weaponType, wantedWeaponsLineX + resp(140), wantedWeaponsLineY + resp(4), wantedWeaponsLineX + wantedWeaponsLineW, wantedWeaponsLineY + wantedWeaponsLineH, textColor, 1, font4, "left", "center")
                    dxDrawText(weaponSerial, wantedWeaponsLineX - resp(5), wantedWeaponsLineY + resp(4), wantedWeaponsLineX + wantedWeaponsLineW, wantedWeaponsLineY + wantedWeaponsLineH, textColor, 1, font4, "center", "center")
                    
                    local trashW, trashH = resp(32), resp(32)
                    local lineY = wantedWeaponsLineY + wantedWeaponsLineH / 2 - resp(2)

                    local trashX, trashY = wantedWeaponsLineX + wantedWeaponsLineW - trashW, lineY - trashH / 2 + resp(1.5)
                    local trashColor = tocolor(rr, rg, rb, alpha * 0.7)
                    local trashTexture = textures.trash_nohover

                    local hoverW, hoverH = resp(14), resp(16)
                    local hoverX, hoverY = trashX + hoverW / 2 + resp(2), trashY + hoverH / 2
                    local inSlot = exports.cr_core:isInSlot(hoverX, hoverY, hoverW, hoverH)

                    if inSlot then 
                        trashColor = tocolor(rr, rg, rb, alpha)
                        trashTexture = textures.trash_hover
                        deleteButtonHover = i

                        dxDrawText("Törlés", trashX - trashW, trashY + resp(4), trashX + trashW, trashY + trashH, tocolor(rr, rg, rb, alpha), 1, font3, "left", "center")
                    end

                    exports.cr_dx:dxDrawImageAsTexture(trashX, trashY, trashW, trashH, trashTexture, 0, 0, 0, trashColor)

                    local availableForReasonHover = false

                    if utf8.len(reason) > 20 then 
                        clippedReason = utf8.sub(reason, 1, -(utf8.len(reason) - 20)) .. "..."
                        availableForReasonHover = true
                    end

                    local text = availableForReasonHover and clippedReason or reason
                    dxDrawText(text, wantedWeaponsLineX + wantedWeaponsLineW / 2 + resp(99), wantedWeaponsLineY + resp(4), wantedWeaponsLineX + wantedWeaponsLineW, wantedWeaponsLineY + wantedWeaponsLineH, textColor, 1, font4, "left", "center")

                    if availableForReasonHover then 
                        local hoverLineW, hoverLineH = wantedWeaponsLineW / 2 - resp(170), wantedWeaponsLineH
                        local hoverLineX, hoverLineY = wantedWeaponsLineX + wantedWeaponsLineW - hoverLineW - resp(72), wantedWeaponsLineY
                        local inSlot = exports.cr_core:isInSlot(hoverLineX, hoverLineY, hoverLineW, hoverLineH)

                        if inSlot then 
                            exports.cr_dx:drawTooltip(1, reason)
                        end
                    end
                end

                wantedWeaponsLineY = wantedWeaponsLineY + wantedWeaponsLineH + rowPadding
            end

            -- 280, 18 - search

            local searchW, searchH = resp(280), resp(18)
            local searchX, searchY = wantedWeaponsX + wantedWeaponsW - searchW, wantedWeaponsY - searchH - rowPadding

            dxDrawRectangle(searchX, searchY, searchW, searchH, tocolor(51, 51, 51, alpha * 0.29))
            -- dxDrawText("Search", searchX + rowPadding, searchY + resp(4), searchX + searchW, searchY + searchH, tocolor(255, 255, 255, alpha * 0.8), 1, font4, "left", "center")

            UpdatePos("mdc.search", {searchX + rowPadding, searchY + resp(2), searchW - rowPadding, searchH})
            UpdateAlpha("mdc.search", tocolor(255, 255, 255, alpha * 0.8))

            local searchIconW, searchIconH = resp(32), resp(32)
            local searchIconX, searchIconY = searchX + searchW - searchIconW + (rowPadding / 2), searchY - resp(7)

            exports.cr_dx:dxDrawImageAsTexture(searchIconX, searchIconY, searchIconW, searchIconH, textures.search, 0, 0, 0, tocolor(255, 255, 255, alpha * 0.8))

            local ticketW, ticketH = wantedWeaponsW, resp(155)
            local ticketX, ticketY = realX + buttonW + resp(60), buttonY - ticketH / 2 + resp(40)

            dxDrawRectangle(ticketX, ticketY, ticketW, ticketH, tocolor(51, 51, 51, alpha * 0.29))
            dxDrawText("Körözés kiadása", ticketX + resp(15), ticketY + resp(10), ticketX + ticketW, ticketY + ticketH, tocolor(255, 255, 255, alpha), 1, font3, "left", "top")

            local weaponNameInputW, weaponNameInputH = resp(400), resp(20)
            local weaponNameInputX, weaponNameInputY = ticketX + resp(15), ticketY + (weaponNameInputH * 2)
            local inputPadding = resp(5)

            dxDrawRectangle(weaponNameInputX, weaponNameInputY, weaponNameInputW, weaponNameInputH, tocolor(51, 51, 51, alpha * 0.6))
            dxDrawText("Fegyver neve:", weaponNameInputX + resp(4), weaponNameInputY + resp(4), weaponNameInputX + weaponNameInputW, weaponNameInputY + weaponNameInputH, tocolor(255, 255, 255, alpha * 0.8), 1, font4, "left", "center")

            local textWidth = dxGetTextWidth("Fegyver neve:", 1, font4)

            UpdatePos("mdc.weaponName", {weaponNameInputX + textWidth + resp(8), weaponNameInputY + resp(2), weaponNameInputW - textWidth - resp(8), weaponNameInputH})
            UpdateAlpha("mdc.weaponName", tocolor(255, 255, 255, alpha * 0.8))

            local weaponTypeInputX, weaponTypeInputY = weaponNameInputX, weaponNameInputY + weaponNameInputH + inputPadding

            dxDrawRectangle(weaponTypeInputX, weaponTypeInputY, weaponNameInputW, weaponNameInputH, tocolor(51, 51, 51, alpha * 0.6))
            dxDrawText("Típus:", weaponTypeInputX + resp(4), weaponTypeInputY + resp(4), weaponTypeInputX + weaponNameInputW, weaponTypeInputY + weaponNameInputH, tocolor(255, 255, 255, alpha * 0.8), 1, font4, "left", "center")

            local textWidth = dxGetTextWidth("Típus:", 1, font4)

            UpdatePos("mdc.weaponType", {weaponTypeInputX + textWidth + resp(8), weaponTypeInputY + resp(2), weaponNameInputW - textWidth - resp(8), weaponNameInputH})
            UpdateAlpha("mdc.weaponType", tocolor(255, 255, 255, alpha * 0.8))

            local weaponSerialInputX, weaponSerialInputY = weaponNameInputX, weaponTypeInputY + weaponNameInputH + inputPadding

            dxDrawRectangle(weaponSerialInputX, weaponSerialInputY, weaponNameInputW, weaponNameInputH, tocolor(51, 51, 51, alpha * 0.6))
            dxDrawText("Sorozatszám:", weaponSerialInputX + resp(4), weaponSerialInputY + resp(4), weaponSerialInputX + weaponNameInputW, weaponSerialInputY + weaponNameInputH, tocolor(255, 255, 255, alpha * 0.8), 1, font4, "left", "center")

            local textWidth = dxGetTextWidth("Sorozatszám:", 1, font4)

            UpdatePos("mdc.weaponSerial", {weaponSerialInputX + textWidth + resp(8), weaponSerialInputY + resp(2), weaponNameInputW - textWidth - resp(8), weaponNameInputH})
            UpdateAlpha("mdc.weaponSerial", tocolor(255, 255, 255, alpha * 0.8))

            local reasonInputX, reasonInputY = weaponSerialInputX, weaponSerialInputY + weaponNameInputH + inputPadding

            dxDrawRectangle(reasonInputX, reasonInputY, weaponNameInputW, weaponNameInputH, tocolor(51, 51, 51, alpha * 0.6))
            dxDrawText("Indok:", reasonInputX + resp(4), reasonInputY + resp(4), reasonInputX + weaponNameInputW, reasonInputY + weaponNameInputH, tocolor(255, 255, 255, alpha * 0.8), 1, font4, "left", "center")

            local textWidth = dxGetTextWidth("Indok:", 1, font4)

            UpdatePos("mdc.weaponReason", {reasonInputX + textWidth + resp(8), reasonInputY + resp(2), weaponNameInputW - textWidth - resp(8), weaponNameInputH})
            UpdateAlpha("mdc.weaponReason", tocolor(255, 255, 255, alpha * 0.8))

            local buttonW, buttonH = resp(200), resp(25)
            local buttonX, buttonY = ticketX + ticketW - buttonW - buttonPadding, ticketY + ticketH - buttonH - buttonPadding
            local inSlot = exports.cr_core:isInSlot(buttonX, buttonY, buttonW, buttonH)
            
            local buttonColor = tocolor(gr, gg, gb, alpha * 0.7)
            local textColor = tocolor(255, 255, 255, alpha * 0.6)

            ticketButtonHover = nil
            if inSlot then 
                buttonColor = tocolor(gr, gg, gb, alpha)
                textColor = tocolor(255, 255, 255, alpha)
                ticketButtonHover = true
            end

            dxDrawRectangle(buttonX, buttonY, buttonW, buttonH, buttonColor)
            dxDrawText("Körözés kiadása", buttonX, buttonY + resp(4), buttonX + buttonW, buttonY + buttonH, textColor, 1, font2, "center", "center")
        elseif selectedMenu == 5 then 
            local weaponRegistrationW, weaponRegistrationH = resp(680), resp(280)
            local weaponRegistrationX, weaponRegistrationY = realX + buttonW + resp(60), buttonY - weaponRegistrationH - resp(40) - buttonPadding
            local rowPadding = resp(5)
            local inSlot = exports.cr_core:isInSlot(weaponRegistrationX, weaponRegistrationY, weaponRegistrationW, weaponRegistrationH)
            
            weaponRegistrationHover = nil
            if inSlot then 
                weaponRegistrationHover = true
            end

            dxDrawRectangle(weaponRegistrationX, weaponRegistrationY, weaponRegistrationW, weaponRegistrationH, tocolor(51, 51, 51, alpha * 0.29))

            dxDrawText("Tulajdonos", weaponRegistrationX + resp(15), weaponRegistrationY + resp(7), weaponRegistrationX + weaponRegistrationW, weaponRegistrationY + weaponRegistrationH, tocolor(255, 255, 255, alpha), 1, font3, "left", "top")
            dxDrawText("Típus", weaponRegistrationX + resp(230), weaponRegistrationY + resp(7), weaponRegistrationX + weaponRegistrationW, weaponRegistrationY + weaponRegistrationH, tocolor(255, 255, 255, alpha), 1, font3, "left", "top")
            dxDrawText("Sorozatszám", weaponRegistrationX + resp(385), weaponRegistrationY + resp(7), weaponRegistrationX + weaponRegistrationW, weaponRegistrationY + weaponRegistrationH, tocolor(255, 255, 255, alpha), 1, font3, "left", "top")
            -- dxDrawText("Alvázszám", weaponRegistrationX + resp(370), weaponRegistrationY + resp(7), weaponRegistrationX + weaponRegistrationW, weaponRegistrationY + weaponRegistrationH, tocolor(255, 255, 255, alpha), 1, font3, "center", "top")

            local scrollW, scrollH = 3, weaponRegistrationH - resp(30) - rowPadding
            local scrollX, scrollY = weaponRegistrationX + weaponRegistrationW - scrollW, weaponRegistrationY + resp(30)

            scrollBarHover = exports.cr_core:isInSlot(scrollX, scrollY, scrollW, scrollH)
            
            -- Scrollbar

            dxDrawRectangle(scrollX, scrollY, scrollW, scrollH, tocolor(242, 242, 242, alpha * 0.6))

            local percent = #mdcRegisteredWeapons

            if mdcRegisteredWeaponsSearchCache then
                percent = #mdcRegisteredWeaponsSearchCache
            end

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

                            mdcWeaponRegistrationMinLine = math.max(1, math.floor(math.min(math.max(num, 1), (percent - _mdcWeaponRegistrationMaxLine) + 1)))
                            mdcWeaponRegistrationMaxLine = mdcWeaponRegistrationMinLine + (_mdcWeaponRegistrationMaxLine - 1)
                        end
                    else
                        scrolling = false
                    end
                end

                local multiplier = math.min(math.max((mdcWeaponRegistrationMaxLine - (mdcWeaponRegistrationMinLine - 1)) / percent, 0), 1)
                local multiplier2 = math.min(math.max((mdcWeaponRegistrationMinLine - 1) / percent, 0), 1)
                local gY = gY + ((gH) * multiplier2)
                local gH = gH * multiplier

                local r, g, b = 255, 59, 59
                dxDrawRectangle(gX, gY, gW, gH, tocolor(r, g, b, alpha))
            end

            local weaponRegistrationLineW, weaponRegistrationLineH = weaponRegistrationW - (rowPadding * 4), resp(20)
            local weaponRegistrationLineX, weaponRegistrationLineY = weaponRegistrationX + (rowPadding * 2), weaponRegistrationY + weaponRegistrationLineH + (rowPadding * 2)

            local array = mdcRegisteredWeapons
            local percent = #array

            if mdcRegisteredWeaponsSearchCache then 
                array = mdcRegisteredWeaponsSearchCache
                percent = #array
            end

            if mdcWeaponRegistrationMaxLine > percent then 
                mdcVehicleRegistrationMinLine = 1
                _mdcWeaponRegistrationMaxLine = 10
                mdcWeaponRegistrationMaxLine = _mdcWeaponRegistrationMaxLine
            end

            for i = mdcWeaponRegistrationMinLine, mdcWeaponRegistrationMaxLine do 
                local v = array[i]
                
                local inSlot = exports.cr_core:isInSlot(weaponRegistrationLineX, weaponRegistrationLineY, weaponRegistrationLineW, weaponRegistrationLineH)
                local rowColor = tocolor(51, 51, 51, alpha * 0.29)
                local textColor = tocolor(255, 255, 255, alpha)

                if inSlot then 
                    rowColor = tocolor(255, 255, 255, alpha * 0.8)
                    textColor = tocolor(51, 51, 51, alpha)
                end

                dxDrawRectangle(weaponRegistrationLineX, weaponRegistrationLineY, weaponRegistrationLineW, weaponRegistrationLineH, rowColor)
                
                if v and v.ownerName then
                    local ownerName = v.ownerName
                    local weaponType = v.weaponType
                    local weaponSerial = v.weaponSerial
                    
                    dxDrawText(ownerName:gsub("_", " "), weaponRegistrationLineX + (rowPadding * 2) - resp(4), weaponRegistrationLineY + resp(4), weaponRegistrationLineX + weaponRegistrationLineW, weaponRegistrationLineY + weaponRegistrationLineH, textColor, 1, font4, "left", "center")
                    dxDrawText(weaponType, weaponRegistrationLineX + resp(220), weaponRegistrationLineY + resp(4), weaponRegistrationLineX + weaponRegistrationLineW, weaponRegistrationLineY + weaponRegistrationLineH, textColor, 1, font4, "left", "center")
                    dxDrawText(weaponSerial, weaponRegistrationLineX + resp(375), weaponRegistrationLineY + resp(4), weaponRegistrationLineX + weaponRegistrationLineW, weaponRegistrationLineY + weaponRegistrationLineH, textColor, 1, font4, "left", "center")

                    local trashW, trashH = resp(32), resp(32)
                    local lineY = weaponRegistrationLineY + weaponRegistrationLineH / 2 - resp(2)

                    local trashX, trashY = weaponRegistrationLineX + weaponRegistrationLineW - trashW, lineY - trashH / 2 + resp(1.5)
                    local trashColor = tocolor(rr, rg, rb, alpha * 0.7)
                    local trashTexture = textures.trash_nohover

                    local hoverW, hoverH = resp(14), resp(16)
                    local hoverX, hoverY = trashX + hoverW / 2 + resp(2), trashY + hoverH / 2
                    local inSlot = exports.cr_core:isInSlot(hoverX, hoverY, hoverW, hoverH)

                    if inSlot then 
                        trashColor = tocolor(rr, rg, rb, alpha)
                        trashTexture = textures.trash_hover
                        deleteButtonHover = i

                        dxDrawText("Törlés", trashX - trashW, trashY + resp(4), trashX + trashW, trashY + trashH, tocolor(rr, rg, rb, alpha), 1, font3, "left", "center")
                    end

                    exports.cr_dx:dxDrawImageAsTexture(trashX, trashY, trashW, trashH, trashTexture, 0, 0, 0, trashColor)
                end

                weaponRegistrationLineY = weaponRegistrationLineY + weaponRegistrationLineH + rowPadding
            end

            -- 280, 18 - search

            local searchW, searchH = resp(280), resp(18)
            local searchX, searchY = weaponRegistrationX + weaponRegistrationW - searchW, weaponRegistrationY - searchH - rowPadding

            dxDrawRectangle(searchX, searchY, searchW, searchH, tocolor(51, 51, 51, alpha * 0.29))
            -- dxDrawText("Search", searchX + rowPadding, searchY + resp(4), searchX + searchW, searchY + searchH, tocolor(255, 255, 255, alpha * 0.8), 1, font4, "left", "center")

            UpdatePos("mdc.search", {searchX + rowPadding, searchY + resp(2), searchW - rowPadding, searchH})
            UpdateAlpha("mdc.search", tocolor(255, 255, 255, alpha * 0.8))

            local searchIconW, searchIconH = resp(32), resp(32)
            local searchIconX, searchIconY = searchX + searchW - searchIconW + (rowPadding / 2), searchY - resp(7)

            exports.cr_dx:dxDrawImageAsTexture(searchIconX, searchIconY, searchIconW, searchIconH, textures.search, 0, 0, 0, tocolor(255, 255, 255, alpha * 0.8))

            local ticketW, ticketH = weaponRegistrationW, resp(155)
            local ticketX, ticketY = realX + buttonW + resp(60), buttonY - ticketH / 2 + resp(40)

            dxDrawRectangle(ticketX, ticketY, ticketW, ticketH, tocolor(51, 51, 51, alpha * 0.29))
            dxDrawText("Új nyilvántartás hozzáadása", ticketX + resp(15), ticketY + resp(10), ticketX + ticketW, ticketY + ticketH, tocolor(255, 255, 255, alpha), 1, font3, "left", "top")

            local ownerInputW, ownerInputH = resp(400), resp(20)
            local ownerInputX, ownerInputY = ticketX + resp(15), ticketY + (ownerInputH * 2)
            local inputPadding = resp(5)

            dxDrawRectangle(ownerInputX, ownerInputY, ownerInputW, ownerInputH, tocolor(51, 51, 51, alpha * 0.6))
            dxDrawText("Tulajdonos:", ownerInputX + resp(4), ownerInputY + resp(4), ownerInputX + ownerInputW, ownerInputY + ownerInputH, tocolor(255, 255, 255, alpha * 0.8), 1, font4, "left", "center")

            local textWidth = dxGetTextWidth("Tulajdonos:", 1, font4)

            UpdatePos("mdc.weaponRegistrationOwnerName", {ownerInputX + textWidth + resp(8), ownerInputY + resp(2), ownerInputW - textWidth - resp(8), ownerInputH})
            UpdateAlpha("mdc.weaponRegistrationOwnerName", tocolor(255, 255, 255, alpha * 0.8))

            local weaponTypeInputX, weaponTypeInputY = ownerInputX, ownerInputY + ownerInputH + inputPadding

            dxDrawRectangle(weaponTypeInputX, weaponTypeInputY, ownerInputW, ownerInputH, tocolor(51, 51, 51, alpha * 0.6))
            dxDrawText("Típus:", weaponTypeInputX + resp(4), weaponTypeInputY + resp(4), weaponTypeInputX + ownerInputW, weaponTypeInputY + ownerInputH, tocolor(255, 255, 255, alpha * 0.8), 1, font4, "left", "center")

            local textWidth = dxGetTextWidth("Típus:", 1, font4)

            UpdatePos("mdc.weaponRegistrationWeaponType", {weaponTypeInputX + textWidth + resp(8), weaponTypeInputY + resp(2), ownerInputW - textWidth - resp(8), ownerInputH})
            UpdateAlpha("mdc.weaponRegistrationWeaponType", tocolor(255, 255, 255, alpha * 0.8))

            local weaponSerialInputX, weaponSerialInputY = ownerInputX, weaponTypeInputY + ownerInputH + inputPadding

            dxDrawRectangle(weaponSerialInputX, weaponSerialInputY, ownerInputW, ownerInputH, tocolor(51, 51, 51, alpha * 0.6))
            dxDrawText("Sorozatszám:", weaponSerialInputX + resp(4), weaponSerialInputY + resp(4), weaponSerialInputX + ownerInputW, weaponSerialInputY + ownerInputH, tocolor(255, 255, 255, alpha * 0.8), 1, font4, "left", "center")

            local textWidth = dxGetTextWidth("Sorozatszám:", 1, font4)

            UpdatePos("mdc.weaponRegistrationWeaponSerial", {weaponSerialInputX + textWidth + resp(8), weaponSerialInputY + resp(2), ownerInputW - textWidth - resp(8), ownerInputH})
            UpdateAlpha("mdc.weaponRegistrationWeaponSerial", tocolor(255, 255, 255, alpha * 0.8))

            local buttonW, buttonH = resp(200), resp(25)
            local buttonX, buttonY = ticketX + ticketW - buttonW - buttonPadding, ticketY + ticketH - buttonH - buttonPadding
            local inSlot = exports.cr_core:isInSlot(buttonX, buttonY, buttonW, buttonH)
            
            local buttonColor = tocolor(gr, gg, gb, alpha * 0.7)
            local textColor = tocolor(255, 255, 255, alpha * 0.6)

            ticketButtonHover = nil
            if inSlot then 
                buttonColor = tocolor(gr, gg, gb, alpha)
                textColor = tocolor(255, 255, 255, alpha)
                ticketButtonHover = true
            end

            dxDrawRectangle(buttonX, buttonY, buttonW, buttonH, buttonColor)
            dxDrawText("Új nyilvántartás hozzáadása", buttonX, buttonY + resp(4), buttonX + buttonW, buttonY + buttonH, textColor, 1, font2, "center", "center")
        elseif selectedMenu == 6 then 
            local vehicleRegistrationW, vehicleRegistrationH = resp(680), resp(280)
            local vehicleRegistrationX, vehicleRegistrationY = realX + buttonW + resp(60), buttonY - vehicleRegistrationH - resp(40) - buttonPadding
            local rowPadding = resp(5)
            local inSlot = exports.cr_core:isInSlot(vehicleRegistrationX, vehicleRegistrationY, vehicleRegistrationW, vehicleRegistrationH)
            
            vehicleRegistrationHover = nil
            if inSlot then 
                vehicleRegistrationHover = true
            end

            dxDrawRectangle(vehicleRegistrationX, vehicleRegistrationY, vehicleRegistrationW, vehicleRegistrationH, tocolor(51, 51, 51, alpha * 0.29))

            dxDrawText("Tulajdonos", vehicleRegistrationX + resp(15), vehicleRegistrationY + resp(7), vehicleRegistrationX + vehicleRegistrationW, vehicleRegistrationY + vehicleRegistrationH, tocolor(255, 255, 255, alpha), 1, font3, "left", "top")
            dxDrawText("Típus", vehicleRegistrationX + resp(170), vehicleRegistrationY + resp(7), vehicleRegistrationX + vehicleRegistrationW, vehicleRegistrationY + vehicleRegistrationH, tocolor(255, 255, 255, alpha), 1, font3, "left", "top")
            dxDrawText("Rendszám", vehicleRegistrationX + resp(325), vehicleRegistrationY + resp(7), vehicleRegistrationX + vehicleRegistrationW, vehicleRegistrationY + vehicleRegistrationH, tocolor(255, 255, 255, alpha), 1, font3, "left", "top")
            dxDrawText("Alvázszám", vehicleRegistrationX + resp(370), vehicleRegistrationY + resp(7), vehicleRegistrationX + vehicleRegistrationW, vehicleRegistrationY + vehicleRegistrationH, tocolor(255, 255, 255, alpha), 1, font3, "center", "top")

            local scrollW, scrollH = 3, vehicleRegistrationH - resp(30) - rowPadding
            local scrollX, scrollY = vehicleRegistrationX + vehicleRegistrationW - scrollW, vehicleRegistrationY + resp(30)

            scrollBarHover = exports.cr_core:isInSlot(scrollX, scrollY, scrollW, scrollH)
            
            -- Scrollbar

            dxDrawRectangle(scrollX, scrollY, scrollW, scrollH, tocolor(242, 242, 242, alpha * 0.6))

            local percent = #mdcRegisteredVehicles

            if mdcRegisteredVehiclesSearchCache then
                percent = #mdcRegisteredVehiclesSearchCache
            end

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

                            mdcVehicleRegistrationMinLine = math.max(1, math.floor(math.min(math.max(num, 1), (percent - _mdcVehicleRegistrationMaxLine) + 1)))
                            mdcVehicleRegistrationMaxLine = mdcVehicleRegistrationMinLine + (_mdcVehicleRegistrationMaxLine - 1)
                        end
                    else
                        scrolling = false
                    end
                end

                local multiplier = math.min(math.max((mdcVehicleRegistrationMaxLine - (mdcVehicleRegistrationMinLine - 1)) / percent, 0), 1)
                local multiplier2 = math.min(math.max((mdcVehicleRegistrationMinLine - 1) / percent, 0), 1)
                local gY = gY + ((gH) * multiplier2)
                local gH = gH * multiplier

                local r, g, b = 255, 59, 59
                dxDrawRectangle(gX, gY, gW, gH, tocolor(r, g, b, alpha))
            end

            local vehicleRegistrationLineW, vehicleRegistrationLineH = vehicleRegistrationW - (rowPadding * 4), resp(20)
            local vehicleRegistrationLineX, vehicleRegistrationLineY = vehicleRegistrationX + (rowPadding * 2), vehicleRegistrationY + vehicleRegistrationLineH + (rowPadding * 2)

            local array = mdcRegisteredVehicles
            local percent = #array

            if mdcRegisteredVehiclesSearchCache then 
                array = mdcRegisteredVehiclesSearchCache
                percent = #array
            end

            if mdcVehicleRegistrationMaxLine > percent then 
                mdcVehicleRegistrationMinLine = 1
                _mdcVehicleRegistrationMaxLine = 10
                mdcVehicleRegistrationMaxLine = _mdcVehicleRegistrationMaxLine
            end

            for i = mdcVehicleRegistrationMinLine, mdcVehicleRegistrationMaxLine do 
                local v = array[i]
                
                local inSlot = exports.cr_core:isInSlot(vehicleRegistrationLineX, vehicleRegistrationLineY, vehicleRegistrationLineW, vehicleRegistrationLineH)
                local rowColor = tocolor(51, 51, 51, alpha * 0.29)
                local textColor = tocolor(255, 255, 255, alpha)

                if inSlot then 
                    rowColor = tocolor(255, 255, 255, alpha * 0.8)
                    textColor = tocolor(51, 51, 51, alpha)
                end

                dxDrawRectangle(vehicleRegistrationLineX, vehicleRegistrationLineY, vehicleRegistrationLineW, vehicleRegistrationLineH, rowColor)
                
                if v and v.ownerName then
                    local ownerName = v.ownerName
                    local vehicleType = v.vehicleType
                    local vehiclePlateText = v.vehiclePlateText
                    local vehicleChassis = v.vehicleChassis
                    
                    dxDrawText(ownerName:gsub("_", " "), vehicleRegistrationLineX + (rowPadding * 2) - resp(4), vehicleRegistrationLineY + resp(4), vehicleRegistrationLineX + vehicleRegistrationLineW, vehicleRegistrationLineY + vehicleRegistrationLineH, textColor, 1, font4, "left", "center")
                    dxDrawText(vehicleType, vehicleRegistrationLineX - resp(310), vehicleRegistrationLineY + resp(4), vehicleRegistrationLineX + vehicleRegistrationLineW, vehicleRegistrationLineY + vehicleRegistrationLineH, textColor, 1, font4, "center", "center")
                    dxDrawText(vehiclePlateText, vehicleRegistrationLineX + resp(25), vehicleRegistrationLineY + resp(4), vehicleRegistrationLineX + vehicleRegistrationLineW, vehicleRegistrationLineY + vehicleRegistrationLineH, textColor, 1, font4, "center", "center")
                    dxDrawText(vehicleChassis, vehicleRegistrationLineX + vehicleRegistrationLineW / 2 + resp(40), vehicleRegistrationLineY + resp(4), vehicleRegistrationLineX + vehicleRegistrationLineW, vehicleRegistrationLineY + vehicleRegistrationLineH, textColor, 1, font4, "center", "center")

                    local trashW, trashH = resp(32), resp(32)
                    local lineY = vehicleRegistrationLineY + vehicleRegistrationLineH / 2 - resp(2)

                    local trashX, trashY = vehicleRegistrationLineX + vehicleRegistrationLineW - trashW, lineY - trashH / 2 + resp(1.5)
                    local trashColor = tocolor(rr, rg, rb, alpha * 0.7)
                    local trashTexture = textures.trash_nohover

                    local hoverW, hoverH = resp(14), resp(16)
                    local hoverX, hoverY = trashX + hoverW / 2 + resp(2), trashY + hoverH / 2
                    local inSlot = exports.cr_core:isInSlot(hoverX, hoverY, hoverW, hoverH)

                    if inSlot then 
                        trashColor = tocolor(rr, rg, rb, alpha)
                        trashTexture = textures.trash_hover
                        deleteButtonHover = i

                        dxDrawText("Törlés", trashX - trashW, trashY + resp(4), trashX + trashW, trashY + trashH, tocolor(rr, rg, rb, alpha), 1, font3, "left", "center")
                    end

                    exports.cr_dx:dxDrawImageAsTexture(trashX, trashY, trashW, trashH, trashTexture, 0, 0, 0, trashColor)
                end

                vehicleRegistrationLineY = vehicleRegistrationLineY + vehicleRegistrationLineH + rowPadding
            end

            -- 280, 18 - search

            local searchW, searchH = resp(280), resp(18)
            local searchX, searchY = vehicleRegistrationX + vehicleRegistrationW - searchW, vehicleRegistrationY - searchH - rowPadding

            dxDrawRectangle(searchX, searchY, searchW, searchH, tocolor(51, 51, 51, alpha * 0.29))
            -- dxDrawText("Search", searchX + rowPadding, searchY + resp(4), searchX + searchW, searchY + searchH, tocolor(255, 255, 255, alpha * 0.8), 1, font4, "left", "center")

            UpdatePos("mdc.search", {searchX + rowPadding, searchY + resp(2), searchW - rowPadding, searchH})
            UpdateAlpha("mdc.search", tocolor(255, 255, 255, alpha * 0.8))

            local searchIconW, searchIconH = resp(32), resp(32)
            local searchIconX, searchIconY = searchX + searchW - searchIconW + (rowPadding / 2), searchY - resp(7)

            exports.cr_dx:dxDrawImageAsTexture(searchIconX, searchIconY, searchIconW, searchIconH, textures.search, 0, 0, 0, tocolor(255, 255, 255, alpha * 0.8))

            local ticketW, ticketH = vehicleRegistrationW, resp(155)
            local ticketX, ticketY = realX + buttonW + resp(60), buttonY - ticketH / 2 + resp(40)

            dxDrawRectangle(ticketX, ticketY, ticketW, ticketH, tocolor(51, 51, 51, alpha * 0.29))
            dxDrawText("Új nyilvántartás hozzáadása", ticketX + resp(15), ticketY + resp(10), ticketX + ticketW, ticketY + ticketH, tocolor(255, 255, 255, alpha), 1, font3, "left", "top")

            local ownerInputW, ownerInputH = resp(400), resp(20)
            local ownerInputX, ownerInputY = ticketX + resp(15), ticketY + (ownerInputH * 2)
            local inputPadding = resp(5)

            dxDrawRectangle(ownerInputX, ownerInputY, ownerInputW, ownerInputH, tocolor(51, 51, 51, alpha * 0.6))
            dxDrawText("Tulajdonos:", ownerInputX + resp(4), ownerInputY + resp(4), ownerInputX + ownerInputW, ownerInputY + ownerInputH, tocolor(255, 255, 255, alpha * 0.8), 1, font4, "left", "center")

            local textWidth = dxGetTextWidth("Tulajdonos:", 1, font4)

            UpdatePos("mdc.vehicleRegistrationOwnerName", {ownerInputX + textWidth + resp(8), ownerInputY + resp(2), ownerInputW - textWidth - resp(8), ownerInputH})
            UpdateAlpha("mdc.vehicleRegistrationOwnerName", tocolor(255, 255, 255, alpha * 0.8))

            local vehicleTypeInputX, vehicleTypeInputY = ownerInputX, ownerInputY + ownerInputH + inputPadding

            dxDrawRectangle(vehicleTypeInputX, vehicleTypeInputY, ownerInputW, ownerInputH, tocolor(51, 51, 51, alpha * 0.6))
            dxDrawText("Típus:", vehicleTypeInputX + resp(4), vehicleTypeInputY + resp(4), vehicleTypeInputX + ownerInputW, vehicleTypeInputY + ownerInputH, tocolor(255, 255, 255, alpha * 0.8), 1, font4, "left", "center")

            local textWidth = dxGetTextWidth("Típus:", 1, font4)

            UpdatePos("mdc.vehicleRegistrationVehicleType", {vehicleTypeInputX + textWidth + resp(8), vehicleTypeInputY + resp(2), ownerInputW - textWidth - resp(8), ownerInputH})
            UpdateAlpha("mdc.vehicleRegistrationVehicleType", tocolor(255, 255, 255, alpha * 0.8))

            local vehiclePlateTextInputX, vehiclePlateTextInputY = ownerInputX, vehicleTypeInputY + ownerInputH + inputPadding

            dxDrawRectangle(vehiclePlateTextInputX, vehiclePlateTextInputY, ownerInputW, ownerInputH, tocolor(51, 51, 51, alpha * 0.6))
            dxDrawText("Rendszám:", vehiclePlateTextInputX + resp(4), vehiclePlateTextInputY + resp(4), vehiclePlateTextInputX + ownerInputW, vehiclePlateTextInputY + ownerInputH, tocolor(255, 255, 255, alpha * 0.8), 1, font4, "left", "center")

            local textWidth = dxGetTextWidth("Rendszám:", 1, font4)

            UpdatePos("mdc.vehicleRegistrationVehiclePlateText", {vehiclePlateTextInputX + textWidth + resp(8), vehiclePlateTextInputY + resp(2), ownerInputW - textWidth - resp(8), ownerInputH})
            UpdateAlpha("mdc.vehicleRegistrationVehiclePlateText", tocolor(255, 255, 255, alpha * 0.8))

            local vehicleChassisInputX, vehicleChassisInputY = ownerInputX, vehiclePlateTextInputY + ownerInputH + inputPadding

            dxDrawRectangle(vehicleChassisInputX, vehicleChassisInputY, ownerInputW, ownerInputH, tocolor(51, 51, 51, alpha * 0.6))
            dxDrawText("Alvázszám:", vehicleChassisInputX + resp(4), vehicleChassisInputY + resp(4), vehicleChassisInputX + ownerInputW, vehicleChassisInputY + ownerInputH, tocolor(255, 255, 255, alpha * 0.8), 1, font4, "left", "center")

            local textWidth = dxGetTextWidth("Alvázszám:", 1, font4)

            UpdatePos("mdc.vehicleRegistrationVehicleChassis", {vehicleChassisInputX + textWidth + resp(8), vehicleChassisInputY + resp(2), ownerInputW - textWidth - resp(8), ownerInputH})
            UpdateAlpha("mdc.vehicleRegistrationVehicleChassis", tocolor(255, 255, 255, alpha * 0.8))

            local buttonW, buttonH = resp(200), resp(25)
            local buttonX, buttonY = ticketX + ticketW - buttonW - buttonPadding, ticketY + ticketH - buttonH - buttonPadding
            local inSlot = exports.cr_core:isInSlot(buttonX, buttonY, buttonW, buttonH)
            
            local buttonColor = tocolor(gr, gg, gb, alpha * 0.7)
            local textColor = tocolor(255, 255, 255, alpha * 0.6)

            ticketButtonHover = nil
            if inSlot then 
                buttonColor = tocolor(gr, gg, gb, alpha)
                textColor = tocolor(255, 255, 255, alpha)
                ticketButtonHover = true
            end

            dxDrawRectangle(buttonX, buttonY, buttonW, buttonH, buttonColor)
            dxDrawText("Új nyilvántartás hozzáadása", buttonX, buttonY + resp(4), buttonX + buttonW, buttonY + buttonH, textColor, 1, font2, "center", "center")
        elseif selectedMenu == 7 then 
            local addressRegistrationW, addressRegistrationH = resp(680), resp(280)
            local addressRegistrationX, addressRegistrationY = realX + buttonW + resp(60), buttonY - addressRegistrationH - resp(40) - buttonPadding
            local rowPadding = resp(5)
            local inSlot = exports.cr_core:isInSlot(addressRegistrationX, addressRegistrationY, addressRegistrationW, addressRegistrationH)
            
            addressRegistrationHover = nil
            if inSlot then 
                addressRegistrationHover = true
            end

            dxDrawRectangle(addressRegistrationX, addressRegistrationY, addressRegistrationW, addressRegistrationH, tocolor(51, 51, 51, alpha * 0.29))

            dxDrawText("Tulajdonos", addressRegistrationX + resp(15), addressRegistrationY + resp(7), addressRegistrationX + addressRegistrationW, addressRegistrationY + addressRegistrationH, tocolor(255, 255, 255, alpha), 1, font3, "left", "top")
            dxDrawText("Pontos cím", addressRegistrationX + resp(170), addressRegistrationY + resp(7), addressRegistrationX + addressRegistrationW, addressRegistrationY + addressRegistrationH, tocolor(255, 255, 255, alpha), 1, font3, "left", "top")
            dxDrawText("Regisztráció kezdete", addressRegistrationX + resp(355), addressRegistrationY + resp(7), addressRegistrationX + addressRegistrationW, addressRegistrationY + addressRegistrationH, tocolor(255, 255, 255, alpha), 1, font3, "left", "top")
            dxDrawText("Lejárat", addressRegistrationX + resp(420), addressRegistrationY + resp(7), addressRegistrationX + addressRegistrationW, addressRegistrationY + addressRegistrationH, tocolor(255, 255, 255, alpha), 1, font3, "center", "top")

            local scrollW, scrollH = 3, addressRegistrationH - resp(30) - rowPadding
            local scrollX, scrollY = addressRegistrationX + addressRegistrationW - scrollW, addressRegistrationY + resp(30)

            scrollBarHover = exports.cr_core:isInSlot(scrollX, scrollY, scrollW, scrollH)
            
            -- Scrollbar

            dxDrawRectangle(scrollX, scrollY, scrollW, scrollH, tocolor(242, 242, 242, alpha * 0.6))

            local percent = #mdcRegisteredAddresses

            if mdcRegisteredAddressesSearchCache then
                percent = #mdcRegisteredAddressesSearchCache
            end

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

                            mdcAddressRegistrationMinLine = math.max(1, math.floor(math.min(math.max(num, 1), (percent - _mdcAddressRegistrationMaxLine) + 1)))
                            mdcAddressRegistrationMaxLine = mdcAddressRegistrationMinLine + (_mdcAddressRegistrationMaxLine - 1)
                        end
                    else
                        scrolling = false
                    end
                end

                local multiplier = math.min(math.max((mdcAddressRegistrationMaxLine - (mdcAddressRegistrationMinLine - 1)) / percent, 0), 1)
                local multiplier2 = math.min(math.max((mdcAddressRegistrationMinLine - 1) / percent, 0), 1)
                local gY = gY + ((gH) * multiplier2)
                local gH = gH * multiplier

                local r, g, b = 255, 59, 59
                dxDrawRectangle(gX, gY, gW, gH, tocolor(r, g, b, alpha))
            end

            local addressRegistrationLineW, addressRegistrationLineH = addressRegistrationW - (rowPadding * 4), resp(20)
            local addressRegistrationLineX, addressRegistrationLineY = addressRegistrationX + (rowPadding * 2), addressRegistrationY + addressRegistrationLineH + (rowPadding * 2)

            local array = mdcRegisteredAddresses
            local percent = #array

            if mdcRegisteredAddressesSearchCache then 
                array = mdcRegisteredAddressesSearchCache
                percent = #array
            end

            if mdcAddressRegistrationMaxLine > percent then 
                mdcVehicleRegistrationMinLine = 1
                _mdcAddressRegistrationMaxLine = 10
                mdcAddressRegistrationMaxLine = _mdcAddressRegistrationMaxLine
            end

            for i = mdcAddressRegistrationMinLine, mdcAddressRegistrationMaxLine do 
                local v = array[i]
                
                local inSlot = exports.cr_core:isInSlot(addressRegistrationLineX, addressRegistrationLineY, addressRegistrationLineW, addressRegistrationLineH)
                local rowColor = tocolor(51, 51, 51, alpha * 0.29)
                local textColor = tocolor(255, 255, 255, alpha)

                if inSlot then 
                    rowColor = tocolor(255, 255, 255, alpha * 0.8)
                    textColor = tocolor(51, 51, 51, alpha)
                end

                dxDrawRectangle(addressRegistrationLineX, addressRegistrationLineY, addressRegistrationLineW, addressRegistrationLineH, rowColor)
                
                if v and v.ownerName then
                    local ownerName = v.ownerName
                    local actualAddress = v.actualAddress
                    local registerStart = v.registerStart
                    local expirationDate = v.expirationDate
                    
                    dxDrawText(ownerName:gsub("_", " "), addressRegistrationLineX + (rowPadding * 2) - resp(4), addressRegistrationLineY + resp(4), addressRegistrationLineX + addressRegistrationLineW, addressRegistrationLineY + addressRegistrationLineH, textColor, 1, font4, "left", "center")
                    dxDrawText(actualAddress, addressRegistrationLineX + resp(160), addressRegistrationLineY + resp(4), addressRegistrationLineX + addressRegistrationLineW, addressRegistrationLineY + addressRegistrationLineH, textColor, 1, font4, "left", "center")
                    dxDrawText(registerStart, addressRegistrationLineX + resp(345), addressRegistrationLineY + resp(4), addressRegistrationLineX + addressRegistrationLineW, addressRegistrationLineY + addressRegistrationLineH, textColor, 1, font4, "left", "center")
                    dxDrawText(expirationDate, addressRegistrationLineX + addressRegistrationLineW / 2 + resp(80), addressRegistrationLineY + resp(4), addressRegistrationLineX + addressRegistrationLineW, addressRegistrationLineY + addressRegistrationLineH, textColor, 1, font4, "center", "center")

                    local trashW, trashH = resp(32), resp(32)
                    local lineY = addressRegistrationLineY + addressRegistrationLineH / 2 - resp(2)

                    local trashX, trashY = addressRegistrationLineX + addressRegistrationLineW - trashW, lineY - trashH / 2 + resp(1.5)
                    local trashColor = tocolor(rr, rg, rb, alpha * 0.7)
                    local trashTexture = textures.trash_nohover

                    local hoverW, hoverH = resp(14), resp(16)
                    local hoverX, hoverY = trashX + hoverW / 2 + resp(2), trashY + hoverH / 2
                    local inSlot = exports.cr_core:isInSlot(hoverX, hoverY, hoverW, hoverH)

                    if inSlot then 
                        trashColor = tocolor(rr, rg, rb, alpha)
                        trashTexture = textures.trash_hover
                        deleteButtonHover = i

                        dxDrawText("Törlés", trashX - trashW, trashY + resp(4), trashX + trashW, trashY + trashH, tocolor(rr, rg, rb, alpha), 1, font3, "left", "center")
                    end

                    exports.cr_dx:dxDrawImageAsTexture(trashX, trashY, trashW, trashH, trashTexture, 0, 0, 0, trashColor)
                end

                addressRegistrationLineY = addressRegistrationLineY + addressRegistrationLineH + rowPadding
            end

            -- 280, 18 - search

            local searchW, searchH = resp(280), resp(18)
            local searchX, searchY = addressRegistrationX + addressRegistrationW - searchW, addressRegistrationY - searchH - rowPadding

            dxDrawRectangle(searchX, searchY, searchW, searchH, tocolor(51, 51, 51, alpha * 0.29))
            -- dxDrawText("Search", searchX + rowPadding, searchY + resp(4), searchX + searchW, searchY + searchH, tocolor(255, 255, 255, alpha * 0.8), 1, font4, "left", "center")

            UpdatePos("mdc.search", {searchX + rowPadding, searchY + resp(2), searchW - rowPadding, searchH})
            UpdateAlpha("mdc.search", tocolor(255, 255, 255, alpha * 0.8))

            local searchIconW, searchIconH = resp(32), resp(32)
            local searchIconX, searchIconY = searchX + searchW - searchIconW + (rowPadding / 2), searchY - resp(7)

            exports.cr_dx:dxDrawImageAsTexture(searchIconX, searchIconY, searchIconW, searchIconH, textures.search, 0, 0, 0, tocolor(255, 255, 255, alpha * 0.8))

            local ticketW, ticketH = addressRegistrationW, resp(155)
            local ticketX, ticketY = realX + buttonW + resp(60), buttonY - ticketH / 2 + resp(40)

            dxDrawRectangle(ticketX, ticketY, ticketW, ticketH, tocolor(51, 51, 51, alpha * 0.29))
            dxDrawText("Új nyilvántartás hozzáadása", ticketX + resp(15), ticketY + resp(10), ticketX + ticketW, ticketY + ticketH, tocolor(255, 255, 255, alpha), 1, font3, "left", "top")

            local ownerInputW, ownerInputH = resp(400), resp(20)
            local ownerInputX, ownerInputY = ticketX + resp(15), ticketY + (ownerInputH * 2)
            local inputPadding = resp(5)

            dxDrawRectangle(ownerInputX, ownerInputY, ownerInputW, ownerInputH, tocolor(51, 51, 51, alpha * 0.6))
            dxDrawText("Tulajdonos:", ownerInputX + resp(4), ownerInputY + resp(4), ownerInputX + ownerInputW, ownerInputY + ownerInputH, tocolor(255, 255, 255, alpha * 0.8), 1, font4, "left", "center")

            local textWidth = dxGetTextWidth("Tulajdonos:", 1, font4)

            UpdatePos("mdc.addressRegistrationOwnerName", {ownerInputX + textWidth + resp(8), ownerInputY + resp(2), ownerInputW - textWidth - resp(8), ownerInputH})
            UpdateAlpha("mdc.addressRegistrationOwnerName", tocolor(255, 255, 255, alpha * 0.8))

            local addressInputX, addressTypeInputY = ownerInputX, ownerInputY + ownerInputH + inputPadding

            dxDrawRectangle(addressInputX, addressTypeInputY, ownerInputW, ownerInputH, tocolor(51, 51, 51, alpha * 0.6))
            dxDrawText("Pontos cím:", addressInputX + resp(4), addressTypeInputY + resp(4), addressInputX + ownerInputW, addressTypeInputY + ownerInputH, tocolor(255, 255, 255, alpha * 0.8), 1, font4, "left", "center")

            local textWidth = dxGetTextWidth("Pontos cím:", 1, font4)

            UpdatePos("mdc.addressRegistrationAddress", {addressInputX + textWidth + resp(8), addressTypeInputY + resp(2), ownerInputW - textWidth - resp(8), ownerInputH})
            UpdateAlpha("mdc.addressRegistrationAddress", tocolor(255, 255, 255, alpha * 0.8))

            local registerStartInputX, registerStartInputY = ownerInputX, addressTypeInputY + ownerInputH + inputPadding

            dxDrawRectangle(registerStartInputX, registerStartInputY, ownerInputW, ownerInputH, tocolor(51, 51, 51, alpha * 0.6))
            dxDrawText("Regisztráció kezdete:", registerStartInputX + resp(4), registerStartInputY + resp(4), registerStartInputX + ownerInputW, registerStartInputY + ownerInputH, tocolor(255, 255, 255, alpha * 0.8), 1, font4, "left", "center")

            local textWidth = dxGetTextWidth("Regisztráció kezdete:", 1, font4)

            UpdatePos("mdc.addressRegistrationRegisterStart", {registerStartInputX + textWidth + resp(8), registerStartInputY + resp(2), ownerInputW - textWidth - resp(8), ownerInputH})
            UpdateAlpha("mdc.addressRegistrationRegisterStart", tocolor(255, 255, 255, alpha * 0.8))

            local expirationInputX, expirationInputY = ownerInputX, registerStartInputY + ownerInputH + inputPadding

            dxDrawRectangle(expirationInputX, expirationInputY, ownerInputW, ownerInputH, tocolor(51, 51, 51, alpha * 0.6))
            dxDrawText("Lejárat:", expirationInputX + resp(4), expirationInputY + resp(4), expirationInputX + ownerInputW, expirationInputY + ownerInputH, tocolor(255, 255, 255, alpha * 0.8), 1, font4, "left", "center")

            local textWidth = dxGetTextWidth("Lejárat:", 1, font4)

            UpdatePos("mdc.addressRegistrationExpirationDate", {expirationInputX + textWidth + resp(8), expirationInputY + resp(2), ownerInputW - textWidth - resp(8), ownerInputH})
            UpdateAlpha("mdc.addressRegistrationExpirationDate", tocolor(255, 255, 255, alpha * 0.8))

            local buttonW, buttonH = resp(200), resp(25)
            local buttonX, buttonY = ticketX + ticketW - buttonW - buttonPadding, ticketY + ticketH - buttonH - buttonPadding
            local inSlot = exports.cr_core:isInSlot(buttonX, buttonY, buttonW, buttonH)
            
            local buttonColor = tocolor(gr, gg, gb, alpha * 0.7)
            local textColor = tocolor(255, 255, 255, alpha * 0.6)

            ticketButtonHover = nil
            if inSlot then 
                buttonColor = tocolor(gr, gg, gb, alpha)
                textColor = tocolor(255, 255, 255, alpha)
                ticketButtonHover = true
            end

            dxDrawRectangle(buttonX, buttonY, buttonW, buttonH, buttonColor)
            dxDrawText("Új nyilvántartás hozzáadása", buttonX, buttonY + resp(4), buttonX + buttonW, buttonY + buttonH, textColor, 1, font2, "center", "center")
        elseif selectedMenu == 8 then 
            local trafficRegistrationW, trafficRegistrationH = resp(680), resp(280)
            local trafficRegistrationX, trafficRegistrationY = realX + buttonW + resp(60), buttonY - trafficRegistrationH - resp(40) - buttonPadding
            local rowPadding = resp(5)
            local inSlot = exports.cr_core:isInSlot(trafficRegistrationX, trafficRegistrationY, trafficRegistrationW, trafficRegistrationH)
            
            trafficRegistrationHover = nil
            if inSlot then 
                trafficRegistrationHover = true
            end

            dxDrawRectangle(trafficRegistrationX, trafficRegistrationY, trafficRegistrationW, trafficRegistrationH, tocolor(51, 51, 51, alpha * 0.29))

            dxDrawText("Tulajdonos", trafficRegistrationX + resp(15), trafficRegistrationY + resp(7), trafficRegistrationX + trafficRegistrationW, trafficRegistrationY + trafficRegistrationH, tocolor(255, 255, 255, alpha), 1, font3, "left", "top")
            dxDrawText("Rendszám", trafficRegistrationX + resp(170), trafficRegistrationY + resp(7), trafficRegistrationX + trafficRegistrationW, trafficRegistrationY + trafficRegistrationH, tocolor(255, 255, 255, alpha), 1, font3, "left", "top")
            dxDrawText("Alvázszám", trafficRegistrationX + resp(325), trafficRegistrationY + resp(7), trafficRegistrationX + trafficRegistrationW, trafficRegistrationY + trafficRegistrationH, tocolor(255, 255, 255, alpha), 1, font3, "left", "top")
            dxDrawText("Lejárat", trafficRegistrationX + resp(420), trafficRegistrationY + resp(7), trafficRegistrationX + trafficRegistrationW, trafficRegistrationY + trafficRegistrationH, tocolor(255, 255, 255, alpha), 1, font3, "center", "top")

            local scrollW, scrollH = 3, trafficRegistrationH - resp(30) - rowPadding
            local scrollX, scrollY = trafficRegistrationX + trafficRegistrationW - scrollW, trafficRegistrationY + resp(30)

            scrollBarHover = exports.cr_core:isInSlot(scrollX, scrollY, scrollW, scrollH)
            
            -- Scrollbar

            dxDrawRectangle(scrollX, scrollY, scrollW, scrollH, tocolor(242, 242, 242, alpha * 0.6))

            local percent = #mdcRegisteredTraffices

            if mdcRegisteredTrafficesSearchCache then
                percent = #mdcRegisteredTrafficesSearchCache
            end

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

                            mdcTrafficRegistrationMinLine = math.max(1, math.floor(math.min(math.max(num, 1), (percent - _mdcTrafficRegistrationMaxLine) + 1)))
                            mdcTrafficRegistrationMaxLine = mdcTrafficRegistrationMinLine + (_mdcTrafficRegistrationMaxLine - 1)
                        end
                    else
                        scrolling = false
                    end
                end

                local multiplier = math.min(math.max((mdcTrafficRegistrationMaxLine - (mdcTrafficRegistrationMinLine - 1)) / percent, 0), 1)
                local multiplier2 = math.min(math.max((mdcTrafficRegistrationMinLine - 1) / percent, 0), 1)
                local gY = gY + ((gH) * multiplier2)
                local gH = gH * multiplier

                local r, g, b = 255, 59, 59
                dxDrawRectangle(gX, gY, gW, gH, tocolor(r, g, b, alpha))
            end

            local trafficRegistrationLineW, trafficRegistrationLineH = trafficRegistrationW - (rowPadding * 4), resp(20)
            local trafficRegistrationLineX, trafficRegistrationLineY = trafficRegistrationX + (rowPadding * 2), trafficRegistrationY + trafficRegistrationLineH + (rowPadding * 2)

            local array = mdcRegisteredTraffices
            local percent = #array

            if mdcRegisteredTrafficesSearchCache then 
                array = mdcRegisteredTrafficesSearchCache
                percent = #array
            end

            if mdcTrafficRegistrationMaxLine > percent then 
                mdcTrafficRegistrationMinLine = 1
                _mdcTrafficRegistrationMaxLine = 10
                mdcTrafficRegistrationMaxLine = _mdcTrafficRegistrationMaxLine
            end

            for i = mdcTrafficRegistrationMinLine, mdcTrafficRegistrationMaxLine do 
                local v = array[i]
                
                local inSlot = exports.cr_core:isInSlot(trafficRegistrationLineX, trafficRegistrationLineY, trafficRegistrationLineW, trafficRegistrationLineH)
                local rowColor = tocolor(51, 51, 51, alpha * 0.29)
                local textColor = tocolor(255, 255, 255, alpha)

                if inSlot then 
                    rowColor = tocolor(255, 255, 255, alpha * 0.8)
                    textColor = tocolor(51, 51, 51, alpha)
                end

                dxDrawRectangle(trafficRegistrationLineX, trafficRegistrationLineY, trafficRegistrationLineW, trafficRegistrationLineH, rowColor)
                
                if v and v.ownerName then
                    local ownerName = v.ownerName
                    local vehiclePlateText = v.vehiclePlateText
                    local vehicleChassis = v.vehicleChassis
                    local expirationDate = v.expirationDate
                    
                    dxDrawText(ownerName:gsub("_", " "), trafficRegistrationLineX + (rowPadding * 2) - resp(4), trafficRegistrationLineY + resp(4), trafficRegistrationLineX + trafficRegistrationLineW, trafficRegistrationLineY + trafficRegistrationLineH, textColor, 1, font4, "left", "center")
                    dxDrawText(vehiclePlateText, trafficRegistrationLineX + resp(160), trafficRegistrationLineY + resp(4), trafficRegistrationLineX + trafficRegistrationLineW, trafficRegistrationLineY + trafficRegistrationLineH, textColor, 1, font4, "left", "center")
                    dxDrawText(vehicleChassis, trafficRegistrationLineX + resp(315), trafficRegistrationLineY + resp(4), trafficRegistrationLineX + trafficRegistrationLineW, trafficRegistrationLineY + trafficRegistrationLineH, textColor, 1, font4, "left", "center")
                    dxDrawText(expirationDate, trafficRegistrationLineX + trafficRegistrationLineW / 2 + resp(80), trafficRegistrationLineY + resp(4), trafficRegistrationLineX + trafficRegistrationLineW, trafficRegistrationLineY + trafficRegistrationLineH, textColor, 1, font4, "center", "center")

                    local trashW, trashH = resp(32), resp(32)
                    local lineY = trafficRegistrationLineY + trafficRegistrationLineH / 2 - resp(2)

                    local trashX, trashY = trafficRegistrationLineX + trafficRegistrationLineW - trashW, lineY - trashH / 2 + resp(1.5)
                    local trashColor = tocolor(rr, rg, rb, alpha * 0.7)
                    local trashTexture = textures.trash_nohover

                    local hoverW, hoverH = resp(14), resp(16)
                    local hoverX, hoverY = trashX + hoverW / 2 + resp(2), trashY + hoverH / 2
                    local inSlot = exports.cr_core:isInSlot(hoverX, hoverY, hoverW, hoverH)

                    if inSlot then 
                        trashColor = tocolor(rr, rg, rb, alpha)
                        trashTexture = textures.trash_hover
                        deleteButtonHover = i

                        dxDrawText("Törlés", trashX - trashW, trashY + resp(4), trashX + trashW, trashY + trashH, tocolor(rr, rg, rb, alpha), 1, font3, "left", "center")
                    end

                    exports.cr_dx:dxDrawImageAsTexture(trashX, trashY, trashW, trashH, trashTexture, 0, 0, 0, trashColor)
                end

                trafficRegistrationLineY = trafficRegistrationLineY + trafficRegistrationLineH + rowPadding
            end

            -- 280, 18 - search

            local searchW, searchH = resp(280), resp(18)
            local searchX, searchY = trafficRegistrationX + trafficRegistrationW - searchW, trafficRegistrationY - searchH - rowPadding

            dxDrawRectangle(searchX, searchY, searchW, searchH, tocolor(51, 51, 51, alpha * 0.29))
            -- dxDrawText("Search", searchX + rowPadding, searchY + resp(4), searchX + searchW, searchY + searchH, tocolor(255, 255, 255, alpha * 0.8), 1, font4, "left", "center")

            UpdatePos("mdc.search", {searchX + rowPadding, searchY + resp(2), searchW - rowPadding, searchH})
            UpdateAlpha("mdc.search", tocolor(255, 255, 255, alpha * 0.8))

            local searchIconW, searchIconH = resp(32), resp(32)
            local searchIconX, searchIconY = searchX + searchW - searchIconW + (rowPadding / 2), searchY - resp(7)

            exports.cr_dx:dxDrawImageAsTexture(searchIconX, searchIconY, searchIconW, searchIconH, textures.search, 0, 0, 0, tocolor(255, 255, 255, alpha * 0.8))

            local ticketW, ticketH = trafficRegistrationW, resp(155)
            local ticketX, ticketY = realX + buttonW + resp(60), buttonY - ticketH / 2 + resp(40)

            dxDrawRectangle(ticketX, ticketY, ticketW, ticketH, tocolor(51, 51, 51, alpha * 0.29))
            dxDrawText("Új nyilvántartás hozzáadása", ticketX + resp(15), ticketY + resp(10), ticketX + ticketW, ticketY + ticketH, tocolor(255, 255, 255, alpha), 1, font3, "left", "top")

            local ownerInputW, ownerInputH = resp(400), resp(20)
            local ownerInputX, ownerInputY = ticketX + resp(15), ticketY + (ownerInputH * 2)
            local inputPadding = resp(5)

            dxDrawRectangle(ownerInputX, ownerInputY, ownerInputW, ownerInputH, tocolor(51, 51, 51, alpha * 0.6))
            dxDrawText("Tulajdonos:", ownerInputX + resp(4), ownerInputY + resp(4), ownerInputX + ownerInputW, ownerInputY + ownerInputH, tocolor(255, 255, 255, alpha * 0.8), 1, font4, "left", "center")

            local textWidth = dxGetTextWidth("Tulajdonos:", 1, font4)

            UpdatePos("mdc.trafficRegistrationOwnerName", {ownerInputX + textWidth + resp(8), ownerInputY + resp(2), ownerInputW - textWidth - resp(8), ownerInputH})
            UpdateAlpha("mdc.trafficRegistrationOwnerName", tocolor(255, 255, 255, alpha * 0.8))

            local vehiclePlateTextInputX, vehiclePlateTextInputY = ownerInputX, ownerInputY + ownerInputH + inputPadding

            dxDrawRectangle(vehiclePlateTextInputX, vehiclePlateTextInputY, ownerInputW, ownerInputH, tocolor(51, 51, 51, alpha * 0.6))
            dxDrawText("Rendszám:", vehiclePlateTextInputX + resp(4), vehiclePlateTextInputY + resp(4), vehiclePlateTextInputX + ownerInputW, vehiclePlateTextInputY + ownerInputH, tocolor(255, 255, 255, alpha * 0.8), 1, font4, "left", "center")

            local textWidth = dxGetTextWidth("Rendszám:", 1, font4)

            UpdatePos("mdc.trafficRegistrationVehiclePlateText", {vehiclePlateTextInputX + textWidth + resp(8), vehiclePlateTextInputY + resp(2), ownerInputW - textWidth - resp(8), ownerInputH})
            UpdateAlpha("mdc.trafficRegistrationVehiclePlateText", tocolor(255, 255, 255, alpha * 0.8))

            local vehicleChassisInputX, vehicleChassisInputY = ownerInputX, vehiclePlateTextInputY + ownerInputH + inputPadding

            dxDrawRectangle(vehicleChassisInputX, vehicleChassisInputY, ownerInputW, ownerInputH, tocolor(51, 51, 51, alpha * 0.6))
            dxDrawText("Alvázszám:", vehicleChassisInputX + resp(4), vehicleChassisInputY + resp(4), vehicleChassisInputX + ownerInputW, vehicleChassisInputY + ownerInputH, tocolor(255, 255, 255, alpha * 0.8), 1, font4, "left", "center")

            local textWidth = dxGetTextWidth("Alvázszám:", 1, font4)

            UpdatePos("mdc.trafficRegistrationVehicleChassis", {vehicleChassisInputX + textWidth + resp(8), vehicleChassisInputY + resp(2), ownerInputW - textWidth - resp(8), ownerInputH})
            UpdateAlpha("mdc.trafficRegistrationVehicleChassis", tocolor(255, 255, 255, alpha * 0.8))

            local expirationInputX, expirationInputY = ownerInputX, vehicleChassisInputY + ownerInputH + inputPadding

            dxDrawRectangle(expirationInputX, expirationInputY, ownerInputW, ownerInputH, tocolor(51, 51, 51, alpha * 0.6))
            dxDrawText("Lejárat:", expirationInputX + resp(4), expirationInputY + resp(4), expirationInputX + ownerInputW, expirationInputY + ownerInputH, tocolor(255, 255, 255, alpha * 0.8), 1, font4, "left", "center")

            local textWidth = dxGetTextWidth("Lejárat:", 1, font4)

            UpdatePos("mdc.trafficRegistrationExpirationDate", {expirationInputX + textWidth + resp(8), expirationInputY + resp(2), ownerInputW - textWidth - resp(8), ownerInputH})
            UpdateAlpha("mdc.trafficRegistrationExpirationDate", tocolor(255, 255, 255, alpha * 0.8))

            local buttonW, buttonH = resp(200), resp(25)
            local buttonX, buttonY = ticketX + ticketW - buttonW - buttonPadding, ticketY + ticketH - buttonH - buttonPadding
            local inSlot = exports.cr_core:isInSlot(buttonX, buttonY, buttonW, buttonH)
            
            local buttonColor = tocolor(gr, gg, gb, alpha * 0.7)
            local textColor = tocolor(255, 255, 255, alpha * 0.6)

            ticketButtonHover = nil
            if inSlot then 
                buttonColor = tocolor(gr, gg, gb, alpha)
                textColor = tocolor(255, 255, 255, alpha)
                ticketButtonHover = true
            end

            dxDrawRectangle(buttonX, buttonY, buttonW, buttonH, buttonColor)
            dxDrawText("Új nyilvántartás hozzáadása", buttonX, buttonY + resp(4), buttonX + buttonW, buttonY + buttonH, textColor, 1, font2, "center", "center")
        elseif selectedMenu == 10 then 
            local logsW, logsH = resp(680), resp(455)
            local logsX, logsY = realX + buttonW + resp(60), buttonY - logsH / 2 - resp(80) - (buttonPadding * 2) + buttonPadding / 2 - resp(7.5)
            local rowPadding = resp(5)
            local inSlot = exports.cr_core:isInSlot(logsX, logsY, logsW, logsH)
            
            mdcLogsHover = nil
            if inSlot then 
                mdcLogsHover = true
            end

            dxDrawRectangle(logsX, logsY, logsW, logsH, tocolor(51, 51, 51, alpha * 0.29))

            dxDrawText("Idő", logsX + resp(15), logsY + resp(7), logsX + logsW, logsY + logsH, tocolor(255, 255, 255, alpha), 1, font3, "left", "top")
            dxDrawText("Log", logsX + resp(400), logsY + resp(7), logsX + logsW, logsY + logsH, tocolor(255, 255, 255, alpha), 1, font3, "left", "top")

            local scrollW, scrollH = 3, logsH - resp(30) - rowPadding
            local scrollX, scrollY = logsX + logsW - scrollW, logsY + resp(30)

            scrollBarHover = exports.cr_core:isInSlot(scrollX, scrollY, scrollW, scrollH)
            
            -- Scrollbar

            dxDrawRectangle(scrollX, scrollY, scrollW, scrollH, tocolor(242, 242, 242, alpha * 0.6))

            local percent = #mdcLogs

            if mdcLogsSearchCache then
                percent = #mdcLogsSearchCache
            end

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

                            mdcLogsMinLine = math.max(1, math.floor(math.min(math.max(num, 1), (percent - _mdcLogsMaxLine) + 1)))
                            mdcLogsMaxLine = mdcLogsMinLine + (_mdcLogsMaxLine - 1)
                        end
                    else
                        scrolling = false
                    end
                end

                local multiplier = math.min(math.max((mdcLogsMaxLine - (mdcLogsMinLine - 1)) / percent, 0), 1)
                local multiplier2 = math.min(math.max((mdcLogsMinLine - 1) / percent, 0), 1)
                local gY = gY + ((gH) * multiplier2)
                local gH = gH * multiplier

                local r, g, b = 255, 59, 59
                dxDrawRectangle(gX, gY, gW, gH, tocolor(r, g, b, alpha))
            end

            local logsLineW, logsLineH = logsW - (rowPadding * 4), resp(20)
            local logsLineX, logsLineY = logsX + (rowPadding * 2), logsY + logsLineH + (rowPadding * 2)

            local array = mdcLogs
            local percent = #array

            if mdcLogsSearchCache then 
                array = mdcLogsSearchCache
                percent = #array
            end

            if mdcLogsMaxLine > percent then 
                mdcLogsMinLine = 1
                _mdcLogsMaxLine = 17
                mdcLogsMaxLine = _mdcLogsMaxLine
            end

            for i = mdcLogsMinLine, mdcLogsMaxLine do 
                local v = array[i]
                
                local inSlot = exports.cr_core:isInSlot(logsLineX, logsLineY, logsLineW, logsLineH)
                local rowColor = tocolor(51, 51, 51, alpha * 0.29)
                local textColor = tocolor(255, 255, 255, alpha)

                if inSlot then 
                    rowColor = tocolor(255, 255, 255, alpha * 0.8)
                    textColor = tocolor(51, 51, 51, alpha)
                end

                dxDrawRectangle(logsLineX, logsLineY, logsLineW, logsLineH, rowColor)
                
                if v and v.createdAt then
                    local createdAt = v.createdAt
                    local text = v.text

                    local createdAtX = logsLineX + (rowPadding * 2) - resp(4)
                    local textWidth = dxGetTextWidth(createdAt, 1, font4)

                    dxDrawText(createdAt, createdAtX, logsLineY + resp(4), logsLineX + logsLineW, logsLineY + logsLineH, textColor, 1, font4, "left", "center")

                    local availableForTextHover = false
                    local realText = text:gsub("#......", "")

                    if utf8.len(text) > 118 then 
                        clippedText = utf8.sub(text, 1, -(utf8.len(text) - 118)) .. "..."
                        availableForTextHover = true
                    end

                    local finalText = availableForTextHover and clippedText or text
                    local finalText = inSlot and finalText:gsub("#......", "") or finalText

                    dxDrawText(finalText, createdAtX + textWidth + resp(3), logsLineY + resp(4), logsLineX + logsLineW, logsLineY + logsLineH, textColor, 1, font4, "left", "center", false, false, false, true)

                    if availableForTextHover then 
                        local hoverLineW, hoverLineH = dxGetTextWidth(finalText, 1, font4, true), logsLineH
                        local hoverLineX, hoverLineY = logsLineX + textWidth + resp(8), logsLineY
                        local inSlot = exports.cr_core:isInSlot(hoverLineX, hoverLineY, hoverLineW, hoverLineH)

                        if inSlot then 
                            exports.cr_dx:drawTooltip(1, text)
                        end
                    end
                end

                logsLineY = logsLineY + logsLineH + rowPadding
            end

            -- 280, 18 - search

            local searchW, searchH = resp(280), resp(18)
            local searchX, searchY = logsX + logsW - searchW, logsY - searchH - rowPadding

            dxDrawRectangle(searchX, searchY, searchW, searchH, tocolor(51, 51, 51, alpha * 0.29))

            UpdatePos("mdc.search", {searchX + rowPadding, searchY + resp(2), searchW - rowPadding, searchH})
            UpdateAlpha("mdc.search", tocolor(255, 255, 255, alpha * 0.8))

            local searchIconW, searchIconH = resp(32), resp(32)
            local searchIconX, searchIconY = searchX + searchW - searchIconW + (rowPadding / 2), searchY - resp(7)

            exports.cr_dx:dxDrawImageAsTexture(searchIconX, searchIconY, searchIconW, searchIconH, textures.search, 0, 0, 0, tocolor(255, 255, 255, alpha * 0.8))
        elseif selectedMenu == 9 then 
            local adminW, adminH = resp(680), resp(280)
            local adminX, adminY = realX + buttonW + resp(60), buttonY - adminH - resp(40) - buttonPadding
            local rowPadding = resp(5)
            local inSlot = exports.cr_core:isInSlot(adminX, adminY, adminW, adminH)
            
            mdcAdminDataHover = nil
            if inSlot then 
                mdcAdminDataHover = true
            end

            dxDrawRectangle(adminX, adminY, adminW, adminH, tocolor(51, 51, 51, alpha * 0.29))

            dxDrawText("Név", adminX + resp(15), adminY + resp(7), adminX + adminW, adminY + adminH, tocolor(255, 255, 255, alpha), 1, font3, "left", "top")
            dxDrawText("Online", adminX + resp(200), adminY + resp(7), adminX + adminW, adminY + adminH, tocolor(255, 255, 255, alpha), 1, font3, "left", "top")
            dxDrawText("Kezelés", adminX + resp(450), adminY + resp(7), adminX + adminW, adminY + adminH, tocolor(255, 255, 255, alpha), 1, font3, "left", "top")
            -- dxDrawText("Indok", adminX + resp(400), adminY + resp(7), adminX + adminW, adminY + adminH, tocolor(255, 255, 255, alpha), 1, font3, "center", "top")

            local scrollW, scrollH = 3, adminH - resp(30) - rowPadding
            local scrollX, scrollY = adminX + adminW - scrollW, adminY + resp(30)

            scrollBarHover = exports.cr_core:isInSlot(scrollX, scrollY, scrollW, scrollH)
            
            -- Scrollbar

            dxDrawRectangle(scrollX, scrollY, scrollW, scrollH, tocolor(242, 242, 242, alpha * 0.6))

            local percent = #mdcAdminData

            if mdcAdminDataSearchCache then
                percent = #mdcAdminDataSearchCache
            end

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

                            mdcAdminPanelMinLine = math.max(1, math.floor(math.min(math.max(num, 1), (percent - _mdcAdminPanelMaxLine) + 1)))
                            mdcAdminPanelMaxLine = mdcAdminPanelMinLine + (_mdcAdminPanelMaxLine - 1)
                        end
                    else
                        scrolling = false
                    end
                end

                local multiplier = math.min(math.max((mdcAdminPanelMaxLine - (mdcAdminPanelMinLine - 1)) / percent, 0), 1)
                local multiplier2 = math.min(math.max((mdcAdminPanelMinLine - 1) / percent, 0), 1)
                local gY = gY + ((gH) * multiplier2)
                local gH = gH * multiplier

                local r, g, b = 255, 59, 59
                dxDrawRectangle(gX, gY, gW, gH, tocolor(r, g, b, alpha))
            end

            local adminLineW, adminLineH = adminW - (rowPadding * 4), resp(20)
            local adminLineX, adminLineY = adminX + (rowPadding * 2), adminY + adminLineH + (rowPadding * 2)

            local array = mdcAdminData
            local percent = #array

            if mdcAdminDataSearchCache then 
                array = mdcAdminDataSearchCache
                percent = #array
            end

            if mdcAdminPanelMaxLine > percent then 
                mdcAdminPanelMinLine = 1
                _mdcAdminPanelMaxLine = 10
                mdcAdminPanelMaxLine = _mdcAdminPanelMaxLine
            end

            passwordManageHover = nil
            adminCheckHover = nil
            gPwX, gPwY, gPwW, gPwH = nil, nil, nil, nil

            for i = mdcAdminPanelMinLine, mdcAdminPanelMaxLine do 
                local v = array[i]
                
                local inSlot = exports.cr_core:isInSlot(adminLineX, adminLineY, adminLineW, adminLineH)
                local rowColor = tocolor(51, 51, 51, alpha * 0.29)
                local textColor = tocolor(255, 255, 255, alpha)

                if inSlot then 
                    rowColor = tocolor(255, 255, 255, alpha * 0.8)
                    textColor = tocolor(51, 51, 51, alpha)
                end

                dxDrawRectangle(adminLineX, adminLineY, adminLineW, adminLineH, rowColor)
                
                if v and v.username then
                    local username = v.username
                    local password = v.password
                    local online = v.online
                    local isLeader = v.leader
                    local factionPrefix = v.factionPrefix
                    
                    local onlineText = online and "Igen" or "Nem"
                    local onlineColor = online and tocolor(gr, gg, gb, alpha) or tocolor(rr, rg, rb, alpha)
                    
                    local usernameColor = isLeader and tocolor(yr, yg, yb, alpha) or textColor
                    local usernameText = username .." - " .. factionPrefix

                    if inSlot then 
                        usernameColor = tocolor(51, 51, 51, alpha)
                        onlineColor = tocolor(51, 51, 51, alpha)
                    end

                    dxDrawText(usernameText, adminLineX + (rowPadding * 2) - resp(4), adminLineY + resp(4), adminLineX + adminLineW, adminLineY + adminLineH, usernameColor, 1, font4, "left", "center")
                    -- dxDrawText(password, adminLineX + resp(140), adminLineY + resp(4), adminLineX + adminLineW, adminLineY + adminLineH, textColor, 1, font4, "left", "center")
                    dxDrawText(onlineText, adminLineX - resp(245), adminLineY + resp(4), adminLineX + adminLineW, adminLineY + adminLineH, onlineColor, 1, font4, "center", "center")

                    local newPwW, newPwH = resp(150), resp(12)
                    local newPwX, newPwY = adminLineX + adminLineW / 2 + newPwW / 2 - resp(30), adminLineY + newPwH / 2 - resp(2)
                    local inSlot = exports.cr_core:isInSlot(newPwX, newPwY, newPwW, newPwH)
                    if inSlot then 
                        passwordManageHover = i
                        gPwX, gPwY, gPwW, gPwH = newPwX, newPwY, newPwW, newPwH
                    end

                    dxDrawRectangle(newPwX, newPwY, newPwW, newPwH, tocolor(51, 51, 51, alpha * 0.6))
                    dxDrawText("Új jelszó:", newPwX - resp(52), newPwY + resp(4), newPwX + newPwW, newPwY + newPwH, textColor, 1, font4, "left", "center")

                    local checkW, checkH = resp(32), resp(32)
                    local checkX, checkY = newPwX + newPwW + checkW / 2 - resp(15), newPwY - checkH / 2 + resp(6)
                    local checkColor = tocolor(gr, gg, gb, alpha * 0.7)

                    local hoverW, hoverH = resp(16), resp(16)
                    local hoverX, hoverY = checkX + hoverW / 2, checkY + hoverH / 2
                    local inSlot = exports.cr_core:isInSlot(hoverX, hoverY, hoverW, hoverH)

                    if inSlot then 
                        checkColor = tocolor(gr, gg, gb, alpha)
                        adminCheckHover = i
                    end

                    exports.cr_dx:dxDrawImageAsTexture(checkX, checkY, checkW, checkH, textures.check, 0, 0, 0, checkColor)

                    local trashW, trashH = resp(32), resp(32)
                    local trashX, trashY = adminLineX + adminLineW - trashW, checkY
                    local trashColor = tocolor(rr, rg, rb, alpha * 0.7)
                    local trashTexture = textures.trash_nohover

                    local hoverW, hoverH = resp(14), resp(16)
                    local hoverX, hoverY = trashX + hoverW / 2 + resp(2), trashY + hoverH / 2
                    local inSlot = exports.cr_core:isInSlot(hoverX, hoverY, hoverW, hoverH)

                    if inSlot then 
                        trashColor = tocolor(rr, rg, rb, alpha)
                        trashTexture = textures.trash_hover
                        deleteButtonHover = i

                        dxDrawText("Törlés", trashX - trashW, trashY + resp(4), trashX + trashW, trashY + trashH, tocolor(rr, rg, rb, alpha), 1, font3, "left", "center")
                    end

                    exports.cr_dx:dxDrawImageAsTexture(trashX, trashY, trashW, trashH, trashTexture, 0, 0, 0, trashColor)
                end

                adminLineY = adminLineY + adminLineH + rowPadding
            end

            -- 280, 18 - search

            local searchW, searchH = resp(280), resp(18)
            local searchX, searchY = adminX + adminW - searchW, adminY - searchH - rowPadding

            dxDrawRectangle(searchX, searchY, searchW, searchH, tocolor(51, 51, 51, alpha * 0.29))
            -- dxDrawText("Search", searchX + rowPadding, searchY + resp(4), searchX + searchW, searchY + searchH, tocolor(255, 255, 255, alpha * 0.8), 1, font4, "left", "center")

            UpdatePos("mdc.search", {searchX + rowPadding, searchY + resp(2), searchW - rowPadding, searchH})
            UpdateAlpha("mdc.search", tocolor(255, 255, 255, alpha * 0.8))

            local searchIconW, searchIconH = resp(32), resp(32)
            local searchIconX, searchIconY = searchX + searchW - searchIconW + (rowPadding / 2), searchY - resp(7)

            exports.cr_dx:dxDrawImageAsTexture(searchIconX, searchIconY, searchIconW, searchIconH, textures.search, 0, 0, 0, tocolor(255, 255, 255, alpha * 0.8))

            local ticketW, ticketH = adminW, resp(155)
            local ticketX, ticketY = realX + buttonW + resp(60), buttonY - ticketH / 2 + resp(40)

            dxDrawRectangle(ticketX, ticketY, ticketW, ticketH, tocolor(51, 51, 51, alpha * 0.29))
            dxDrawText("Új felhasználó", ticketX + resp(15), ticketY + resp(10), ticketX + ticketW, ticketY + ticketH, tocolor(255, 255, 255, alpha), 1, font3, "left", "top")

            local userNameW, userNameH = resp(290), resp(20)
            local userNameX, userNameY = ticketX + resp(15), ticketY + (userNameH * 2)
            local inputPadding = resp(5)

            dxDrawRectangle(userNameX, userNameY, userNameW, userNameH, tocolor(51, 51, 51, alpha * 0.6))
            dxDrawText("Felhasználó:", userNameX + resp(4), userNameY + resp(4), userNameX + userNameW, userNameY + userNameH, tocolor(255, 255, 255, alpha * 0.8), 1, font4, "left", "center")

            local textWidth = dxGetTextWidth("Felhasználó:", 1, font4)

            UpdatePos("mdc.newUser.username", {userNameX + textWidth + resp(8), userNameY + resp(2), userNameW - textWidth - resp(8), userNameH})
            UpdateAlpha("mdc.newUser.username", tocolor(255, 255, 255, alpha * 0.8))

            local passwordX, passwordY = userNameX, userNameY + userNameH + inputPadding

            dxDrawRectangle(passwordX, passwordY, userNameW, userNameH, tocolor(51, 51, 51, alpha * 0.6))
            dxDrawText("Jelszó:", passwordX + resp(4), passwordY + resp(4), passwordX + userNameW, passwordY + userNameH, tocolor(255, 255, 255, alpha * 0.8), 1, font4, "left", "center")

            local textWidth = dxGetTextWidth("Jelszó:", 1, font4)

            UpdatePos("mdc.newUser.password", {passwordX + textWidth + resp(8), passwordY + resp(2), userNameW - textWidth - resp(8), userNameH})
            UpdateAlpha("mdc.newUser.password", tocolor(255, 255, 255, alpha * 0.8))

            local factionPrefixX, factionPrefixY = userNameX, passwordY + userNameH + inputPadding

            dxDrawRectangle(factionPrefixX, factionPrefixY, userNameW, userNameH, tocolor(51, 51, 51, alpha * 0.6))
            dxDrawText("Szervezet rövidítése:", factionPrefixX + resp(4), factionPrefixY + resp(4), factionPrefixX + userNameW, factionPrefixY + userNameH, tocolor(255, 255, 255, alpha * 0.8), 1, font4, "left", "center")

            local textWidth = dxGetTextWidth("Szervezet rövidítése:", 1, font4)

            UpdatePos("mdc.newUser.factionPrefix", {factionPrefixX + textWidth + resp(8), factionPrefixY + resp(2), userNameW - textWidth - resp(8), userNameH})
            UpdateAlpha("mdc.newUser.factionPrefix", tocolor(255, 255, 255, alpha * 0.8))

            local buttonW, buttonH = resp(200), resp(25)
            local buttonX, buttonY = factionPrefixX + userNameW / 2 - buttonW / 2, ticketY + ticketH - buttonH - buttonPadding - (buttonPadding / 2) + resp(2)
            local inSlot = exports.cr_core:isInSlot(buttonX, buttonY, buttonW, buttonH)
            
            local buttonColor = tocolor(gr, gg, gb, alpha * 0.7)
            local textColor = tocolor(255, 255, 255, alpha * 0.6)

            addNewUserHover = nil
            if inSlot then 
                buttonColor = tocolor(gr, gg, gb, alpha)
                textColor = tocolor(255, 255, 255, alpha)
                addNewUserHover = true
            end

            dxDrawRectangle(buttonX, buttonY, buttonW, buttonH, buttonColor)
            dxDrawText("Hozzáadás", buttonX, buttonY + resp(4), buttonX + buttonW, buttonY + buttonH, textColor, 1, font2, "center", "center")

            local lineW, lineH = 1, ticketH - resp(24)
            local lineX, lineY = ticketX + ticketW / 2 - lineW / 2, ticketY + resp(12)

            dxDrawRectangle(lineX, lineY, lineW, lineH, tocolor(255, 255, 255, alpha * 0.6))

            dxDrawText("Statisztika", lineX + resp(20), ticketY + resp(10), ticketX + ticketW, ticketY + ticketH, tocolor(255, 255, 255, alpha), 1, font3, "left", "top")

            local statsPadding = resp(4)
            local adminStatsW, adminStatsH = resp(290), resp(15)
            local adminStatsX, adminStatsY = lineX + resp(20), ticketY + (adminStatsH * 2) + statsPadding

            for i = adminStatsMinLine, adminStatsMaxLine do 
                local v = adminDataStats[i]

                local inSlot = exports.cr_core:isInSlot(adminStatsX, adminStatsY, adminStatsW, adminStatsH)
                local rowColor = tocolor(51, 51, 51, alpha * 0.6)
                local textColor = tocolor(255, 255, 255, alpha)
                local hexColor = orangeHex

                if inSlot then 
                    rowColor = tocolor(255, 255, 255, alpha * 0.8)
                    textColor = tocolor(51, 51, 51, alpha)
                    hexColor = "#333333"
                end

                dxDrawRectangle(adminStatsX, adminStatsY, adminStatsW, adminStatsH, rowColor)

                if v then 
                    local text = v:gsub("@A", hexColor .. mdcLoginCount)

                    text = text:gsub("@B", hexColor .. #mdcWantedCars)
                    text = text:gsub("@C", hexColor .. #mdcWantedPersons)
                    text = text:gsub("@D", hexColor .. #mdcTickets)
                    text = text:gsub("@E", hexColor .. #mdcAdminData)
                    text = text:gsub("@F", hexColor .. #mdcLoggedAccounts)

                    dxDrawText(text, adminStatsX + resp(4), adminStatsY + resp(4), adminStatsX + adminStatsW, adminStatsY + adminStatsH, textColor, 1, font5, "left", "center", false, false, false, true)
                end

                adminStatsY = adminStatsY + adminStatsH + statsPadding
            end
        elseif selectedMenu == 11 then 
            local penalCodeW, penalCodeH = resp(680), resp(455)
            local penalCodeX, penalCodeY = realX + buttonW + resp(60), buttonY - penalCodeH / 2 - resp(80) - (buttonPadding * 2) + buttonPadding / 2 - resp(7.5)
            local rowPadding = resp(5)
            local inSlot = exports.cr_core:isInSlot(penalCodeX, penalCodeY, penalCodeW, penalCodeH)
            
            punishmentHover = nil
            if inSlot then 
                punishmentHover = true
            end

            dxDrawRectangle(penalCodeX, penalCodeY, penalCodeW, penalCodeH, tocolor(51, 51, 51, alpha * 0.29))

            dxDrawText("Büntetés megnevezése", penalCodeX + resp(15), penalCodeY + resp(7), penalCodeX + penalCodeW, penalCodeY + penalCodeH, tocolor(255, 255, 255, alpha), 1, font3, "left", "top")
            dxDrawText("Pénzbírság", penalCodeX + resp(225), penalCodeY + resp(7), penalCodeX + penalCodeW, penalCodeY + penalCodeH, tocolor(255, 255, 255, alpha), 1, font3, "left", "top")
            dxDrawText("Börtönbüntetés", penalCodeX + resp(325), penalCodeY + resp(7), penalCodeX + penalCodeW, penalCodeY + penalCodeH, tocolor(255, 255, 255, alpha), 1, font3, "left", "top")
            dxDrawText("Egyéb / Óvadék", penalCodeX + resp(400), penalCodeY + resp(7), penalCodeX + penalCodeW, penalCodeY + penalCodeH, tocolor(255, 255, 255, alpha), 1, font3, "center", "top")

            local scrollW, scrollH = 3, penalCodeH - resp(30) - rowPadding
            local scrollX, scrollY = penalCodeX + penalCodeW - scrollW, penalCodeY + resp(30)

            scrollBarHover = exports.cr_core:isInSlot(scrollX, scrollY, scrollW, scrollH)

            -- Scrollbar

            dxDrawRectangle(scrollX, scrollY, scrollW, scrollH, tocolor(242, 242, 242, alpha * 0.6))

            local percent = #punishmentMenus[selectedSubMenu].subMenu

            if punishmentMenusSearchCache then
                percent = #punishmentMenusSearchCache
            end

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

                            punishmentMinLine = math.max(1, math.floor(math.min(math.max(num, 1), (percent - _punishmentMaxLine) + 1)))
                            punishmentMaxLine = punishmentMinLine + (_punishmentMaxLine - 1)
                        end
                    else
                        scrolling = false
                    end
                end

                local multiplier = math.min(math.max((punishmentMaxLine - (punishmentMinLine - 1)) / percent, 0), 1)
                local multiplier2 = math.min(math.max((punishmentMinLine - 1) / percent, 0), 1)
                local gY = gY + ((gH) * multiplier2)
                local gH = gH * multiplier

                local r, g, b = 255, 59, 59
                dxDrawRectangle(gX, gY, gW, gH, tocolor(r, g, b, alpha))
            end

            local penalCodeLineW, penalCodeLineH = penalCodeW - (rowPadding * 4), resp(20)
            local penalCodeLineX, penalCodeLineY = penalCodeX + (rowPadding * 2), penalCodeY + penalCodeLineH + (rowPadding * 2)

            local array = punishmentMenus[selectedSubMenu].subMenu
            local percent = #array

            if punishmentMenusSearchCache then 
                array = punishmentMenusSearchCache
                percent = #array
            end

            if maxPunishmentMenuLine > percent then 
                punishmentMinLine = 1
                _punishmentMaxLine = 17
                punishmentMaxLine = _punishmentMaxLine
            end

            for i = punishmentMinLine, punishmentMaxLine do 
                local v = array[i]
                local dollarSignColor = tocolor(gr, gg, gb, alpha)
                local dollarSignTextWidth = dxGetTextWidth("$", 1, font3, true)
                
                local inSlot = exports.cr_core:isInSlot(penalCodeLineX, penalCodeLineY, penalCodeLineW, penalCodeLineH)
                local rowColor = tocolor(51, 51, 51, alpha * 0.29)
                local textColor = tocolor(255, 255, 255, alpha)

                if inSlot then 
                    rowColor = tocolor(255, 255, 255, alpha * 0.8)
                    textColor = tocolor(51, 51, 51, alpha)
                    dollarSignColor = tocolor(51, 51, 51, alpha)
                end

                dxDrawRectangle(penalCodeLineX, penalCodeLineY, penalCodeLineW, penalCodeLineH, rowColor)
                
                if v and v.penaltyName then
                    local penaltyName = v.penaltyName
                    local penalty = v.penalty
                    local jailTime = v.jailTime
                    local other = v.other

                    dxDrawText(penaltyName, penalCodeLineX + (rowPadding * 2) - resp(4), penalCodeLineY + resp(4), penalCodeLineX + penalCodeLineW, penalCodeLineY + penalCodeLineH, textColor, 1, font4, "left", "center")
                    dxDrawText("$", penalCodeLineX + resp(225), penalCodeLineY + resp(4), penalCodeLineX + penalCodeLineW, penalCodeLineY + penalCodeLineH, dollarSignColor, 1, font3, "left", "center")
                    dxDrawText(penalty, penalCodeLineX + resp(225) + dollarSignTextWidth + resp(3), penalCodeLineY + resp(4), penalCodeLineX + penalCodeLineW, penalCodeLineY + penalCodeLineH, textColor, 1, font4, "left", "center")

                    dxDrawText(jailTime .. " perc", penalCodeLineX + resp(330) + dollarSignTextWidth + resp(3), penalCodeLineY + resp(4), penalCodeLineX + penalCodeLineW, penalCodeLineY + penalCodeLineH, textColor, 1, font4, "left", "center")
                    
                    local availableForHover = false

                    if utf8.len(other) > 37 then 
                        clippedOther = utf8.sub(other, 1, -(utf8.len(other) - 37)) .. "..."
                        availableForHover = true
                    end

                    if availableForHover then 
                        local hoverLineW, hoverLineH = penalCodeLineW / 2 - resp(90), penalCodeLineH
                        local hoverLineX, hoverLineY = penalCodeLineX + penalCodeLineW - hoverLineW - resp(5), penalCodeLineY
                        local inSlot = exports.cr_core:isInSlot(hoverLineX, hoverLineY, hoverLineW, hoverLineH)

                        if inSlot then 
                            exports.cr_dx:drawTooltip(1, other)
                        end
                    end

                    local text = availableForHover and clippedOther or other
                    dxDrawText(text, penalCodeLineX + resp(410), penalCodeLineY + resp(4), penalCodeLineX + penalCodeLineW, penalCodeLineY + penalCodeLineH, textColor, 1, font4, "center", "center")
                end

                penalCodeLineY = penalCodeLineY + penalCodeLineH + rowPadding
            end

            -- 280, 18 - search

            local searchW, searchH = resp(280), resp(18)
            local searchX, searchY = penalCodeX + penalCodeW - searchW, penalCodeY - searchH - rowPadding

            dxDrawRectangle(searchX, searchY, searchW, searchH, tocolor(51, 51, 51, alpha * 0.29))
            -- dxDrawText("Search", searchX + rowPadding, searchY + resp(4), searchX + searchW, searchY + searchH, tocolor(255, 255, 255, alpha * 0.8), 1, font4, "left", "center")

            UpdatePos("mdc.search", {searchX + rowPadding, searchY + resp(2), searchW - rowPadding, searchH})
            UpdateAlpha("mdc.search", tocolor(255, 255, 255, alpha * 0.8))

            local searchIconW, searchIconH = resp(32), resp(32)
            local searchIconX, searchIconY = searchX + searchW - searchIconW + (rowPadding / 2), searchY - resp(7)

            exports.cr_dx:dxDrawImageAsTexture(searchIconX, searchIconY, searchIconW, searchIconH, textures.search, 0, 0, 0, tocolor(255, 255, 255, alpha * 0.8))

            local menuW, menuH = resp(81), resp(18)
            local menuX, menuY = penalCodeX, penalCodeY - (searchH * 2) - searchH / 2 - buttonPadding

            hoverSubMenu = nil

            for i = minPunishmentMenuLine, maxPunishmentMenuLine do 
                local v = punishmentMenus[i]
                local name = v.name

                local buttonColor = tocolor(26, 32, 59, alpha * 0.71)
                local textColor = tocolor(255, 255, 255, alpha * 0.6)
                local inSlot = exports.cr_core:isInSlot(menuX, menuY, menuW, menuH)

                if inSlot then 
                    hoverSubMenu = i
                    
                    buttonColor = tocolor(61, 74, 134, alpha)
                    textColor = tocolor(255, 255, 255, alpha)
                else
                    if selectedSubMenu == i then 
                        buttonColor = tocolor(61, 74, 134, alpha)
                        textColor = tocolor(255, 255, 255, alpha)
                    end
                end

                dxDrawRectangle(menuX, menuY, menuW, menuH, buttonColor)
                dxDrawText(name, menuX, menuY + resp(4), menuX + menuW, menuY + menuH, textColor, 1, font6, "center", "center")

                menuX = menuX + menuW + resp(7)
            end
        end
    end
end

function onKey(button, state)
    if button == "mouse1" then 
        if state then 
            if checkRender("renderMDC") then 
                if not mainPanelActive and not unitPanelActive then 
                    if mdcMoveHover then 
                        local cursorX, cursorY = exports.cr_core:getCursorPosition()
                        local _, x, y, w, h = exports.cr_interface:getDetails("mdcLoginPanel")

                        isMoving = true
                        moveOffsetX = cursorX - x
                        moveOffsetY = cursorY - y

                        mdcMoveHover = nil
                    end

                    if actionHover == "login" then 
                        local username = GetText("mdcLogin.username")
                        local password = GetText("mdcLogin.password")
                        local factionId = mdcAdminDataKeys[username] and mdcAdminDataKeys[username].faction or 0

                        if not hasPermission(factionId, "mdc.login") then 
                            exports.cr_infobox:addBox("warning", "Neked ehhez nincs jogosultságod!")
                            
                            return
                        end

                        if username:len() > 3 then 
                            if password:len() > 4 then 
                                triggerLatentServerEvent("mdc >> loginToAccount", 5000, false, localPlayer, localPlayer, username, password)
                            else
                                return exports.cr_infobox:addBox("error", "A jelszónak minimum 4 karakternek kell lennie!")
                            end
                        else
                            return exports.cr_infobox:addBox("error", "A felhasználónévnek minimum 3 karakternek kell lennie!")
                        end
                    end

                    if actionHover == "close" then 
                        manageMDCPanel("exit")

                        actionHover = nil
                    end
                elseif unitPanelActive then 
                    if mdcMoveHover then 
                        local cursorX, cursorY = exports["cr_core"]:getCursorPosition()
                        local _, x, y, w, h = exports["cr_interface"]:getDetails("mdcLoginPanel")

                        isMoving = true
                        moveOffsetX = cursorX - x
                        moveOffsetY = cursorY - y

                        mdcMoveHover = nil
                    end

                    if actionHover == "login" then 
                        local unit = GetText("mdcUnit.unit")

                        if unit ~= "unit number" and tostring(unit):len() >= 3 then 
                            triggerLatentServerEvent("mdc >> changeUnit", 5000, false, localPlayer, localPlayer, unit)
                        else 
                            return exports["cr_infobox"]:addBox("error", "Az egységszámnak minimum 4 karaktert kell tartalmaznia.")
                        end
                    end

                    if actionHover == "close" then 
                        manageMDCPanel("exit")

                        actionHover = nil
                    end
                elseif mainPanelActive then 
                    if mdcMoveHover and not isMenuHover() then 
                        local cursorX, cursorY = exports["cr_core"]:getCursorPosition()
                        local _, x, y, w, h = exports["cr_interface"]:getDetails("mdcPanel")

                        isMoving = true
                        moveOffsetX = cursorX - x
                        moveOffsetY = cursorY - y

                        mdcMoveHover = nil
                    end

                    if hoverMenu then 
                        if selectedMenu ~= hoverMenu then 
                            selectedMenu = hoverMenu

                            manageTextbars("destroy")
                            manageTextbars("create")
                        end

                        hoverMenu = nil 
                    end

                    if isMenuHover() then 
                        local i = getMenuIndex()

                        if i and selectedMenu ~= i then 
                            if i == 9 or i == 10 then 
                                local username = localPlayer:getData("mdc >> loggedUsername")

                                local hasLeaderPermission = false
                                local factionId = mdcAdminDataKeys[username] and mdcAdminDataKeys[username].faction or 0
                                local permName = i == 9 and "mdc.logs" or "mdc.admin"

                                if not hasPermission(factionId, permName) then 
                                    exports.cr_infobox:addBox("warning", "Neked ehhez nincs jogosultságod!")
                                    
                                    return
                                end
                            end

                            selectedMenu = i

                            manageTextbars("destroy")
                            manageTextbars("create")
                        end
                    end

                    if hoverSubMenu then 
                        if selectedSubMenu ~= hoverSubMenu then 
                            selectedSubMenu = hoverSubMenu

                            punishmentMinLine = 1
                            _punishmentMaxLine = 17
                            punishmentMaxLine = _punishmentMaxLine
                        end

                        hoverSubMenu = nil
                    end

                    if activeHover then 
                        if lastInteractionTick + interactionDelayTime > getTickCount() then 
                            return
                        end

                        if type(activeHover) == "number" then 
                            if selectedDuty ~= activeHover then 
                                selectedDuty = activeHover
                            else
                                selectedDuty = false
                            end

                            triggerLatentServerEvent("mdc >> changeDutyType", 5000, false, localPlayer, localPlayer, vehicleUnit, selectedDuty)

                            activeHover = nil
                        end

                        lastInteractionTick = getTickCount()
                    end

                    if ticketButtonHover then 
                        local username = localPlayer:getData("mdc >> loggedUsername")
                        local factionId = mdcAdminDataKeys[username] and mdcAdminDataKeys[username].faction or 0

                        if selectedMenu == 1 then 
                            if not hasPermission(factionId, "mdc.addWantedVehicle") then 
                                exports.cr_infobox:addBox("warning", "Neked ehhez nincs jogosultságod!")

                                return
                            end

                            local vehicleType = GetText("mdc.wantedCarType")
                            local vehiclePlateText = GetText("mdc.wantedCarPlate")
                            local reason = GetText("mdc.wantedCarReason")

                            if utf8.len(vehicleType) < 3 then 
                                exports.cr_infobox:addBox("error", "A megadott jármű típus túl rövid! (Minimum 3 karakter)")

                                return
                            end

                            if utf8.len(vehiclePlateText) <= 0 then 
                                exports.cr_infobox:addBox("error", "A megadott rendszám túl rövid! (Minimum 1 karakter)")

                                return
                            end

                            if utf8.len(reason) < 10 then 
                                exports.cr_infobox:addBox("error", "A megadott indok túl rövid! (Minimum 10 karakter)")

                                return
                            end

                            triggerLatentServerEvent("onClientAddWantedCar", 5000, false, localPlayer, vehicleType, vehiclePlateText, reason)

                            SetText("mdc.wantedCarType", "")
                            SetText("mdc.wantedCarPlate", "")
                            SetText("mdc.wantedCarReason", "")
                        elseif selectedMenu == 2 then 
                            if not hasPermission(factionId, "mdc.addWantedPerson") then 
                                exports.cr_infobox:addBox("warning", "Neked ehhez nincs jogosultságod!")

                                return
                            end

                            local name = GetText("mdc.wantedPersonName")
                            local nationality = GetText("mdc.wantedPersonNationality")
                            local description = GetText("mdc.wantedPersonDescription")
                            local reason = GetText("mdc.wantedPersonReason")

                            if utf8.len(name) < 3 then 
                                exports.cr_infobox:addBox("error", "A megadott név túl rövid! (Minimum 3 karakter)")

                                return
                            end

                            if utf8.len(nationality) <= 0 then 
                                exports.cr_infobox:addBox("error", "A megadott nemzetiség túl rövid! (Minimum 1 karakter)")

                                return
                            end

                            if utf8.len(description) < 10 then 
                                exports.cr_infobox:addBox("error", "A megadott személy leírás túl rövid! (Minimum 10 karakter)")

                                return
                            end

                            if utf8.len(reason) < 10 then 
                                exports.cr_infobox:addBox("error", "A megadott indok túl rövid! (Minimum 10 karakter)")

                                return
                            end

                            triggerLatentServerEvent("onClientAddWantedPerson", 5000, false, localPlayer, name, nationality, description, reason)

                            SetText("mdc.wantedPersonName", "")
                            SetText("mdc.wantedPersonNationality", "")
                            SetText("mdc.wantedPersonDescription", "")
                            SetText("mdc.wantedPersonReason", "")
                        elseif selectedMenu == 3 then 
                            if not hasPermission(factionId, "mdc.addNewTicket") then 
                                exports.cr_infobox:addBox("warning", "Neked ehhez nincs jogosultságod!")

                                return
                            end

                            local name = GetText("mdc.ticketName")
                            local penalty = GetText("mdc.penalty")
                            local jailTime = GetText("mdc.jailTime")
                            local reason = GetText("mdc.ticketReason")

                            if utf8.len(name) < 3 then 
                                exports.cr_infobox:addBox("error", "A megadott név túl rövid! (Minimum 3 karakter)")

                                return
                            end

                            if not tonumber(penalty) or tonumber(penalty) <= 0 then 
                                exports.cr_infobox:addBox("error", "Hibás bírság! (Minimum 1 dollár)")

                                return
                            end

                            if not tonumber(jailTime) or tonumber(jailTime) <= 0 then 
                                exports.cr_infobox:addBox("error", "Hibás börtönbüntetés! (Minimum 1 perc)")

                                return
                            end

                            if utf8.len(reason) < 10 then 
                                exports.cr_infobox:addBox("error", "A megadott indok túl rövid! (Minimum 10 karakter)")

                                return
                            end

                            triggerLatentServerEvent("onClientCreateNewTicket", 5000, false, localPlayer, name, jailTime, penalty, reason)

                            SetText("mdc.ticketName", "")
                            SetText("mdc.penalty", "")
                            SetText("mdc.jailTime", "")
                            SetText("mdc.ticketReason", "")
                        elseif selectedMenu == 4 then 
                            if not hasPermission(factionId, "mdc.addWantedWeapon") then 
                                exports.cr_infobox:addBox("warning", "Neked ehhez nincs jogosultságod!")

                                return
                            end

                            local weaponName = GetText("mdc.weaponName")
                            local weaponType = GetText("mdc.weaponType")
                            local weaponSerial = GetText("mdc.weaponSerial")
                            local weaponReason = GetText("mdc.weaponReason")

                            if utf8.len(weaponName) < 3 then 
                                exports.cr_infobox:addBox("error", "A megadott név túl rövid! (Minimum 3 karakter)")

                                return
                            end

                            if utf8.len(weaponType) < 3 then 
                                exports.cr_infobox:addBox("error", "A megadott típus túl rövid! (Minimum 3 karakter)")

                                return
                            end

                            if utf8.len(weaponSerial) < 3 then 
                                exports.cr_infobox:addBox("error", "A megadott sorozatszám túl rövid! (Minimum 3 karakter)")

                                return
                            end

                            if utf8.len(weaponReason) < 10 then 
                                exports.cr_infobox:addBox("error", "A megadott indok túl rövid! (Minimum 10 karakter)")

                                return
                            end

                            triggerLatentServerEvent("onClientAddWantedWeapon", 5000, false, localPlayer, weaponName, weaponType, weaponSerial, weaponReason)

                            SetText("mdc.weaponName", "")
                            SetText("mdc.weaponType", "")
                            SetText("mdc.weaponSerial", "")
                            SetText("mdc.weaponReason", "")
                        elseif selectedMenu == 5 then 
                            if not hasPermission(factionId, "mdc.addRegisteredWeapon") then 
                                exports.cr_infobox:addBox("warning", "Neked ehhez nincs jogosultságod!")

                                return
                            end

                            local ownerName = GetText("mdc.weaponRegistrationOwnerName")
                            local weaponType = GetText("mdc.weaponRegistrationWeaponType")
                            local weaponSerial = GetText("mdc.weaponRegistrationWeaponSerial")

                            if utf8.len(ownerName) < 3 then 
                                exports.cr_infobox:addBox("error", "A megadott név túl rövid! (Minimum 3 karakter)")

                                return
                            end

                            if utf8.len(weaponType) < 3 then 
                                exports.cr_infobox:addBox("error", "A megadott típus túl rövid! (Minimum 3 karakter)")

                                return
                            end

                            if utf8.len(weaponSerial) < 3 then 
                                exports.cr_infobox:addBox("error", "A megadott sorozatszám túl rövid! (Minimum 3 karakter)")

                                return
                            end

                            triggerLatentServerEvent("onClientAddRegisteredWeapon", 5000, false, localPlayer, ownerName, weaponType, weaponSerial)

                            SetText("mdc.weaponRegistrationOwnerName", "")
                            SetText("mdc.weaponRegistrationWeaponType", "")
                            SetText("mdc.weaponRegistrationWeaponSerial", "")
                        elseif selectedMenu == 6 then 
                            if not hasPermission(factionId, "mdc.addRegisteredVehicle") then 
                                exports.cr_infobox:addBox("warning", "Neked ehhez nincs jogosultságod!")

                                return
                            end

                            local ownerName = GetText("mdc.vehicleRegistrationOwnerName")
                            local vehicleType = GetText("mdc.vehicleRegistrationVehicleType")
                            local vehiclePlateText = GetText("mdc.vehicleRegistrationVehiclePlateText")
                            local vehicleChassis = GetText("mdc.vehicleRegistrationVehicleChassis")

                            if utf8.len(ownerName) < 3 then 
                                exports.cr_infobox:addBox("error", "A megadott név túl rövid! (Minimum 3 karakter)")

                                return
                            end

                            if utf8.len(vehicleType) < 3 then 
                                exports.cr_infobox:addBox("error", "A megadott típus túl rövid! (Minimum 3 karakter)")

                                return
                            end

                            if utf8.len(vehiclePlateText) <= 0 then 
                                exports.cr_infobox:addBox("error", "A megadott rendszám túl rövid! (Minimum 1 karakter)")

                                return
                            end

                            if utf8.len(vehicleChassis) < 5 then 
                                exports.cr_infobox:addBox("error", "A megadott alvázszám túl rövid! (Minimum 5 karakter)")

                                return
                            end

                            triggerLatentServerEvent("onClientAddRegisteredVehicle", 5000, false, localPlayer, ownerName, vehicleType, vehiclePlateText, vehicleChassis)

                            SetText("mdc.vehicleRegistrationOwnerName", "")
                            SetText("mdc.vehicleRegistrationVehicleType", "")
                            SetText("mdc.vehicleRegistrationVehiclePlateText", "")
                            SetText("mdc.vehicleRegistrationVehicleChassis", "")
                        elseif selectedMenu == 7 then 
                            if not hasPermission(factionId, "mdc.addRegisteredAddress") then 
                                exports.cr_infobox:addBox("warning", "Neked ehhez nincs jogosultságod!")

                                return
                            end
                            
                            local ownerName = GetText("mdc.addressRegistrationOwnerName")
                            local actualAddress = GetText("mdc.addressRegistrationAddress")
                            local registerStart = GetText("mdc.addressRegistrationRegisterStart")
                            local expirationDate = GetText("mdc.addressRegistrationExpirationDate")

                            if utf8.len(ownerName) < 3 then 
                                exports.cr_infobox:addBox("error", "A megadott név túl rövid! (Minimum 3 karakter)")

                                return
                            end

                            if utf8.len(actualAddress) < 10 then 
                                exports.cr_infobox:addBox("error", "A megadott cím túl rövid! (Minimum 10 karakter)")

                                return
                            end

                            if utf8.len(registerStart) < 3 then 
                                exports.cr_infobox:addBox("error", "A megadott dátum túl rövid! (Minimum 3 karakter)")

                                return
                            end

                            if utf8.len(expirationDate) < 3 then 
                                exports.cr_infobox:addBox("error", "A megadott dátum túl rövid! (Minimum 3 karakter)")

                                return
                            end

                            triggerLatentServerEvent("onClientAddRegisteredAddress", 5000, false, localPlayer, ownerName, actualAddress, registerStart, expirationDate)

                            SetText("mdc.addressRegistrationOwnerName", "")
                            SetText("mdc.addressRegistrationAddress", "")
                            SetText("mdc.addressRegistrationRegisterStart", "")
                            SetText("mdc.addressRegistrationExpirationDate", "")
                        elseif selectedMenu == 8 then 
                            if not hasPermission(factionId, "mdc.addRegisteredTraffic") then 
                                exports.cr_infobox:addBox("warning", "Neked ehhez nincs jogosultságod!")

                                return
                            end

                            local ownerName = GetText("mdc.trafficRegistrationOwnerName")
                            local vehiclePlateText = GetText("mdc.trafficRegistrationVehiclePlateText")
                            local vehicleChassis = GetText("mdc.trafficRegistrationVehicleChassis")
                            local expirationDate = GetText("mdc.trafficRegistrationExpirationDate")

                            if utf8.len(ownerName) < 3 then 
                                exports.cr_infobox:addBox("error", "A megadott név túl rövid! (Minimum 3 karakter)")

                                return
                            end

                            if utf8.len(vehiclePlateText) <= 0 then 
                                exports.cr_infobox:addBox("error", "A megadott rendszám túl rövid! (Minimum 1 karakter)")

                                return
                            end

                            if utf8.len(vehicleChassis) < 5 then 
                                exports.cr_infobox:addBox("error", "A megadott alvázszám túl rövid! (Minimum 5 karakter)")

                                return
                            end

                            if utf8.len(expirationDate) < 3 then 
                                exports.cr_infobox:addBox("error", "A megadott dátum túl rövid! (Minimum 3 karakter)")

                                return
                            end

                            triggerLatentServerEvent("onClientAddRegisteredTraffic", 5000, false, localPlayer, ownerName, vehiclePlateText, vehicleChassis, expirationDate)

                            SetText("mdc.trafficRegistrationOwnerName", "")
                            SetText("mdc.trafficRegistrationVehiclePlateText", "")
                            SetText("mdc.trafficRegistrationVehicleChassis", "")
                            SetText("mdc.trafficRegistrationExpirationDate", "")
                        end
                    end

                    if passwordManageHover then 
                        if selectedAccount ~= passwordManageHover or not GetEdit("mdc.newPassword") then 
                            selectedAccount = passwordManageHover
                            pwX, pwY, pwW, pwH = gPwX, gPwY, gPwW, gPwH
                            
                            manageTextbars("destroy")
                            manageTextbars("create")
                        end

                        passwordManageHover = nil
                    end

                    if deleteButtonHover then 
                        local username = localPlayer:getData("mdc >> loggedUsername")
                        local factionId = mdcAdminDataKeys[username] and mdcAdminDataKeys[username].faction or 0

                        if deleteButtonActions[selectedMenu] then 
                            if lastInteractionTick + (interactionDelayTime * 2) > getTickCount() then 
                                return
                            end

                            local data = deleteButtonActions[selectedMenu]
                            local triggerName = data.triggerName
                            local permName = data.permName

                            if not hasPermission(factionId, permName) then 
                                exports.cr_infobox:addBox("warning", "Neked ehhez nincs jogosultságod!")
                                
                                return
                            end

                            local value = deleteButtonHover

                            if selectedMenu == 9 then
                                local username = mdcAdminData[deleteButtonHover].username

                                value = username
                            end

                            triggerLatentServerEvent(triggerName, 5000, false, localPlayer, value)

                            lastInteractionTick = getTickCount()
                        end

                        deleteButtonHover = nil
                    end

                    if adminCheckHover then 
                        if GetEdit("mdc.newPassword") then 
                            local newPassword = GetText("mdc.newPassword")

                            if utf8.len(newPassword) < 4 then 
                                exports.cr_infobox:addBox("error", "A megadott jelszó túl rövid! (Minimum 4 karakter)")

                                return
                            end

                            if lastInteractionTick + (interactionDelayTime * 2) > getTickCount() then 
                                return
                            end

                            local username = mdcAdminData[adminCheckHover].username

                            triggerLatentServerEvent("onClientUserPasswordChange", 5000, false, localPlayer, username, newPassword)
                            SetText("mdc.newPassword", "")

                            lastInteractionTick = getTickCount()
                        else 
                            exports.cr_infobox:addBox("error", "Előbb válassz ki egy felhasználót.")
                        end

                        adminCheckHover = nil
                    end

                    if addNewUserHover then 
                        local username = localPlayer:getData("mdc >> loggedUsername")
                        local factionId = mdcAdminDataKeys[username] and mdcAdminDataKeys[username].faction or 0

                        if not exports.cr_dashboard:isPlayerFactionLeader(localPlayer, factionId) then 
                            exports.cr_infobox:addBox("warning", "Neked ehhez nincs jogosultságod!")
                            
                            return
                        end

                        local username = GetText("mdc.newUser.username")
                        local password = GetText("mdc.newUser.password")
                        local factionPrefix = GetText("mdc.newUser.factionPrefix")

                        if utf8.len(username) < 3 then 
                            exports.cr_infobox:addBox("error", "A megadott név túl rövid! (Minimum 3 karakter)")

                            return
                        end

                        if utf8.len(password) < 4 then 
                            exports.cr_infobox:addBox("error", "A megadott jelszó túl rövid! (Minimum 4 karakter)")

                            return
                        end

                        if utf8.len(factionPrefix) < 2 then 
                            exports.cr_infobox:addBox("error", "A megadott rövidítés túl rövid! (Minimum 2 karakter)")

                            return
                        end

                        local factionId, factionPrefixes = exports.cr_faction_scripts:getFactionIdByPrefix(factionPrefix)

                        if not factionId and factionPrefixes then 
                            exports.cr_infobox:addBox("error", "A megadott rövidítés hibás! Elérhető rövidítések: " .. table.concat(factionPrefixes, ", "))

                            return
                        end

                        triggerLatentServerEvent("onClientCreateNewUser", 5000, false, localPlayer, username, password, factionPrefix)

                        SetText("mdc.newUser.username", "")
                        SetText("mdc.newUser.password", "")
                        SetText("mdc.newUser.factionPrefix", "")

                        addNewUserHover = nil
                    end

                    if closeHover then 
                        manageMDCPanel("quit")

                        closeHover = nil
                    end

                    if scrollingHover then 
                        if not scrolling then 
                            scrolling = true
                        end

                        scrollingHover = nil
                    end
                end
            end
        else
            if isMoving then 
                isMoving = false 
                moveOffsetX = false
                moveOffsetY = false
            end

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

function manageMDCPanel(state, ignoreTrigger)
    if state == "init" then 
        createRender("renderMDC", renderMDC)

        if isTimer(textureDeleteTimer) then 
            killTimer(textureDeleteTimer)
            textureDeleteTimer = nil
        end

        createTextures()
        manageTextbars("create")

        removeEventHandler("onClientKey", root, onKey)
        addEventHandler("onClientKey", root, onKey)

        if not oldData then 
            oldData = {
                chat = exports["cr_custom-chat"]:isChatVisible(),
                hud = localPlayer:getData("hudVisible"),
                keys = localPlayer:getData("keysDenied")
            }
        end

        exports["cr_custom-chat"]:showChat(false)

        exports["cr_dx"]:startFade("mdcPanel", 
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

        localPlayer:setData("hudVisible", false)
        localPlayer:setData("keysDenied", true)
    elseif state == "exit" then 
        removeEventHandler("onClientKey", root, onKey)

        if oldData then 
            exports["cr_custom-chat"]:showChat(oldData.chat)

            localPlayer:setData("hudVisible", oldData.hud)
            localPlayer:setData("keysDenied", oldData.keys)

            oldData = false
        end

        manageTextbars("destroy")

        exports["cr_dx"]:startFade("mdcPanel", 
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

        triggerLatentServerEvent("onClientPanelClose", 5000, false, localPlayer)
    elseif state == "switchToUnitPanel" then 
        if not forcedByCommand then 
            switchingToUnitPanel = true

            if not oldData then 
                oldData = {
                    chat = exports["cr_custom-chat"]:isChatVisible(),
                    hud = localPlayer:getData("hudVisible"),
                    keys = localPlayer:getData("keysDenied")
                }
            end

            manageTextbars("destroy")
            manageTextbars("create")

            createTextures()

            exports["cr_dx"]:startFade("mdcPanel", 
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
        else
            forcedByCommand = false
            unitPanelActive = true

            createRender("renderMDC", renderMDC)

            manageTextbars("create")
            createTextures()

            if not oldData then 
                oldData = {
                    chat = exports["cr_custom-chat"]:isChatVisible(),
                    hud = localPlayer:getData("hudVisible"),
                    keys = localPlayer:getData("keysDenied")
                }
            end

            exports["cr_custom-chat"]:showChat(false)

            removeEventHandler("onClientKey", root, onKey)
            addEventHandler("onClientKey", root, onKey)

            exports["cr_dx"]:startFade("mdcPanel", 
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

            localPlayer:setData("hudVisible", false)
            localPlayer:setData("keysDenied", true)
        end
    elseif state == "switchToMainMdcPanel" then 
        if not forcedByCommand then 
            switchingToMainMdcPanel = true

            if not oldData then 
                oldData = {
                    chat = exports["cr_custom-chat"]:isChatVisible(),
                    hud = localPlayer:getData("hudVisible"),
                    keys = localPlayer:getData("keysDenied")
                }
            end

            exports["cr_dx"]:startFade("mdcPanel", 
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
        else
            forcedByCommand = false
            mainPanelActive = true

            createRender("renderMDC", renderMDC)

            if needFade then 
                exports["cr_dx"]:startFade("mdcPanel", 
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

                unitPanelActive = false
                needFade = false
            end

            createTextures()
            manageTextbars("create")

            if not oldData then 
                oldData = {
                    chat = exports["cr_custom-chat"]:isChatVisible(),
                    hud = localPlayer:getData("hudVisible"),
                    keys = localPlayer:getData("keysDenied")
                }
            end
            
            exports["cr_custom-chat"]:showChat(false)

            removeEventHandler("onClientKey", root, onKey)
            addEventHandler("onClientKey", root, onKey)

            exports["cr_dx"]:startFade("mdcPanel", 
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

            localPlayer:setData("hudVisible", false)
            localPlayer:setData("keysDenied", true)
        end

        manageTextbars("destroy")
        manageTextbars("create")

        if localPlayer:isInVehicle() then 
            local vehicle = localPlayer.vehicle
            local data = vehicle:getData("veh >> mdcData") or {["unit"] = false, ["loggedIn"] = false, ["duty"] = false}

            if data["unit"] then 
                vehicleUnit = data["unit"]
            end

            if data["duty"] then 
                selectedDuty = data["duty"]
            end
        end

        if not ignoreTrigger then 
            triggerLatentServerEvent("onClientPanelView", 5000, false, localPlayer)
        end
    elseif state == "quit" then
        if localPlayer:isInVehicle() then 
            local vehicle = localPlayer.vehicle
            local data = vehicle:getData("veh >> mdcData") or {["unit"] = false, ["loggedIn"] = false, ["duty"] = false}

            data["unit"] = false
            data["loggedIn"] = false

            vehicle:setData("veh >> mdcData", data)

            quittingFromMDC = true

            if oldData then 
                exports["cr_custom-chat"]:showChat(oldData.chat)

                localPlayer:setData("hudVisible", oldData.hud)
                localPlayer:setData("keysDenied", oldData.keys)
            end

            oldData = false

            triggerLatentServerEvent("mdc >> quitMDC", 5000, false, localPlayer, localPlayer, vehicle, vehicleUnit)

            manageTextbars("destroy")

            exports["cr_dx"]:startFade("mdcPanel", 
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

            triggerLatentServerEvent("onClientPanelClose", 5000, false, localPlayer)
        end
    end
end
addEvent("mdc >> manageMDCPanel", true)
addEventHandler("mdc >> manageMDCPanel", root, manageMDCPanel)

function manageTextbars(state)
    if state == "create" then 
        if not mainPanelActive and not unitPanelActive then 
            CreateNewBar("mdcLogin.username", {0, 0, 0, 0}, {20, "username", false, tocolor(255, 255, 255), {"Poppins-Medium", getRealFontSize(13)}, 1, "center", "center", false}, 1)
            CreateNewBar("mdcLogin.password", {0, 0, 0, 0}, {20, "password", false, tocolor(255, 255, 255), {"Poppins-Medium", getRealFontSize(13)}, 1, "center", "center", true}, 2, true)
        else
            if mainPanelActive then 
                CreateNewBar("mdc.search", {0, 0, 0, 0}, {35, "Search", false, tocolor(255, 255, 255), {"Poppins-Medium", getRealFontSize(11)}, 1, "left", "center", false}, 1)

                if menus[selectedMenu] and menus[selectedMenu].textBars then 
                    local array = menus[selectedMenu].textBars

                    for k, v in pairs(array) do 
                        local maxLength = v.maxLength
                        local inputId = v.inputId
                        local onlyNumber = v.onlyNumber

                        CreateNewBar(k, {0, 0, 0, 0}, {maxLength, "", onlyNumber, tocolor(255, 255, 255), {"Poppins-Medium", getRealFontSize(11)}, 1, "left", "center", false}, inputId)
                    end
                end

                if selectedMenu == 9 then 
                    if selectedAccount then 
                        CreateNewBar("mdc.newPassword", {pwX + resp(3), pwY + resp(2), pwW, pwH}, {25, "", false, tocolor(255, 255, 255), {"Poppins-Medium", getRealFontSize(10)}, 1, "left", "center", true}, 1)
                    end

                    CreateNewBar("mdc.newUser.username", {0, 0, 0, 0}, {25, "", false, tocolor(255, 255, 255), {"Poppins-Medium", getRealFontSize(11)}, 1, "left", "center", false}, 2)
                    CreateNewBar("mdc.newUser.password", {0, 0, 0, 0}, {25, "", false, tocolor(255, 255, 255), {"Poppins-Medium", getRealFontSize(11)}, 1, "left", "center", true}, 3)
                    CreateNewBar("mdc.newUser.factionPrefix", {0, 0, 0, 0}, {10, "", false, tocolor(255, 255, 255), {"Poppins-Medium", getRealFontSize(11)}, 1, "left", "center", false}, 4)
                end
            elseif unitPanelActive then 
                CreateNewBar("mdcUnit.unit", {0, 0, 0, 0}, {12, "unit number", false, tocolor(255, 255, 255), {"Poppins-Medium", getRealFontSize(13)}, 1, "center", "center", false}, 1)
            end
        end
    elseif state == "destroy" then 
        Clear()
    end
end

function mdcCommand(cmd)
    if localPlayer:getData("loggedIn") then 
        if exports["cr_faction_scripts"]:hasPlayerPermission(localPlayer, cmd) then 
            if localPlayer:isInVehicle() then 
                if allowedVehicles[localPlayer.vehicle.model] then 
                    if lastInteractionTick + interactionDelayTime > getTickCount() then 
                        return
                    end

                    if isTimer(textureDeleteTimer) then 
                        killTimer(textureDeleteTimer)
                        textureDeleteTimer = nil
                    end

                    if not checkRender("renderMDC") then 
                        local vehicle = localPlayer.vehicle
                        local data = vehicle:getData("veh >> mdcData") or {["unit"] = false, ["loggedIn"] = false, ["duty"] = false}

                        if data["loggedIn"] then 
                            local loggedUsername = localPlayer:getData("mdc >> loggedUsername")

                            if not loggedUsername or loggedUsername ~= data["loggedIn"] then 
                                localPlayer:setData("mdc >> loggedUsername", data["loggedIn"])
                            end

                            if data["unit"] or switchingToMainMdcPanel then
                                if switchingToMainMdcPanel then 
                                    needFade = true
                                    switchingToMainMdcPanel = false 
                                end

                                forcedByCommand = true

                                manageMDCPanel("switchToMainMdcPanel")
                                triggerLatentServerEvent("onClientMDCDataRequest", 5000, false, localPlayer)
                            else 
                                if not switchingToMainMdcPanel then 
                                    forcedByCommand = true

                                    manageMDCPanel("switchToUnitPanel")
                                end
                            end
                        else
                            quittingFromMDC = false
                            mainPanelActive = false
                            unitPanelActive = false
                            selectedDuty = false

                            manageMDCPanel("init")
                        end
                    else 
                        manageMDCPanel("exit")
                    end

                    lastInteractionTick = getTickCount()
                end
            end
        end
    end
end
addCommandHandler("mdc", mdcCommand, false, false)

function scrollDown()
    if checkRender("renderMDC") then 
        if wantedCarsHover then 
            local percent = #mdcWantedCars

            if mdcWantedCarsSearchCache then 
                percent = #mdcWantedCarsSearchCache
            end

            if mdcWantedCarsMaxLine + 1 <= percent then 
                mdcWantedCarsMinLine = mdcWantedCarsMinLine + 1
                mdcWantedCarsMaxLine = mdcWantedCarsMaxLine + 1
            end
        elseif wantedPersonsHover then 
            local percent = #mdcWantedPersons
            
            if mdcWantedPersonsSearchCache then 
                percent = #mdcWantedPersonsSearchCache
            end

            if mdcWantedPersonsMaxLine + 1 <= percent then 
                mdcWantedPersonsMinLine = mdcWantedPersonsMinLine + 1
                mdcWantedPersonsMaxLine = mdcWantedPersonsMaxLine + 1
            end
        elseif ticketsHover then 
            local percent = #mdcTickets
            
            if mdcTicketsSearchCache then 
                percent = #mdcTicketsSearchCache
            end

            if mdcTicketsMaxLine + 1 <= percent then 
                mdcTicketsMinLine = mdcTicketsMinLine + 1
                mdcTicketsMaxLine = mdcTicketsMaxLine + 1
            end
        elseif wantedWeaponsHover then 
            local percent = #mdcWantedWeapons
            
            if mdcWantedWeaponsSearchCache then 
                percent = #mdcWantedWeaponsSearchCache
            end

            if mdcWantedWeaponsMaxLine + 1 <= percent then 
                mdcWantedWeaponsMinLine = mdcWantedWeaponsMinLine + 1
                mdcWantedWeaponsMaxLine = mdcWantedWeaponsMaxLine + 1
            end
        elseif weaponRegistrationHover then 
            local percent = #mdcRegisteredWeapons

            if mdcRegisteredWeaponsSearchCache then 
                percent = #mdcRegisteredWeaponsSearchCache
            end

            if mdcWeaponRegistrationMaxLine + 1 <= percent then 
                mdcWeaponRegistrationMinLine = mdcVehicleRegistrationMinLine + 1
                mdcWeaponRegistrationMaxLine = mdcWeaponRegistrationMaxLine + 1
            end
        elseif vehicleRegistrationHover then 
            local percent = #mdcRegisteredVehicles

            if mdcRegisteredVehiclesSearchCache then 
                percent = #mdcRegisteredVehiclesSearchCache
            end

            if mdcVehicleRegistrationMaxLine + 1 <= percent then 
                mdcVehicleRegistrationMinLine = mdcVehicleRegistrationMinLine + 1
                mdcVehicleRegistrationMaxLine = mdcVehicleRegistrationMaxLine + 1
            end
        elseif addressRegistrationHover then 
            local percent = #mdcRegisteredAddresses

            if mdcRegisteredAddressesSearchCache then 
                percent = #mdcRegisteredAddressesSearchCache
            end

            if mdcAddressRegistrationMaxLine + 1 <= percent then 
                mdcAddressRegistrationMinLine = mdcAddressRegistrationMinLine + 1
                mdcAddressRegistrationMaxLine = mdcAddressRegistrationMaxLine + 1
            end
        elseif trafficRegistrationHover then 
            local percent = #mdcRegisteredTraffices

            if mdcRegisteredTrafficesSearchCache then 
                percent = #mdcRegisteredTrafficesSearchCache
            end

            if mdcTrafficRegistrationMaxLine + 1 <= percent then 
                mdcTrafficRegistrationMinLine = mdcTrafficRegistrationMinLine + 1
                mdcTrafficRegistrationMaxLine = mdcTrafficRegistrationMaxLine + 1
            end
        elseif mdcAdminDataHover then 
            local percent = #mdcAdminData
            
            if mdcAdminDataSearchCache then 
                percent = #mdcAdminDataSearchCache
            end

            if selectedAccount and GetEdit("mdc.newPassword") then 
                RemoveBar("mdc.newPassword")
                selectedAccount = false
            end

            if mdcAdminPanelMaxLine + 1 <= percent then 
                mdcAdminPanelMinLine = mdcAdminPanelMinLine + 1
                mdcAdminPanelMaxLine = mdcAdminPanelMaxLine + 1
            end
        elseif mdcLogsHover then 
            local percent = #mdcLogs
            
            if mdcLogsSearchCache then 
                percent = #mdcLogsSearchCache
            end

            if mdcLogsMaxLine + 1 <= percent then 
                mdcLogsMinLine = mdcLogsMinLine + 1
                mdcLogsMaxLine = mdcLogsMaxLine + 1
            end
        elseif punishmentHover then 
            if punishmentMaxLine + 1 <= #punishmentMenus[selectedSubMenu]["subMenu"] then 
                punishmentMinLine = punishmentMinLine + 1
                punishmentMaxLine = punishmentMaxLine + 1
            end
        end
    end
end

function scrollUP()
    if checkRender("renderMDC") then 
        if wantedCarsHover then 
            if mdcWantedCarsMinLine - 1 >= 1 then
                mdcWantedCarsMinLine = mdcWantedCarsMinLine - 1
                mdcWantedCarsMaxLine = mdcWantedCarsMaxLine - 1
            end
        elseif wantedPersonsHover then 
            if mdcWantedPersonsMinLine - 1 >= 1 then
                mdcWantedPersonsMinLine = mdcWantedPersonsMinLine - 1
                mdcWantedPersonsMaxLine = mdcWantedPersonsMaxLine - 1
            end
        elseif ticketsHover then 
            if mdcTicketsMinLine - 1 >= 1 then
                mdcTicketsMinLine = mdcTicketsMinLine - 1
                mdcTicketsMaxLine = mdcTicketsMaxLine - 1
            end
        elseif wantedWeaponsHover then 
            if mdcWantedWeaponsMinLine - 1 >= 1 then
                mdcWantedWeaponsMinLine = mdcWantedWeaponsMinLine - 1
                mdcWantedWeaponsMaxLine = mdcWantedWeaponsMaxLine - 1
            end
        elseif weaponRegistrationHover then 
            if mdcWeaponRegistrationMinLine - 1 >= 1 then
                mdcWeaponRegistrationMinLine = mdcWeaponRegistrationMinLine - 1
                mdcWeaponRegistrationMaxLine = mdcWeaponRegistrationMaxLine - 1
            end
        elseif vehicleRegistrationHover then 
            if mdcVehicleRegistrationMinLine - 1 >= 1 then
                mdcVehicleRegistrationMinLine = mdcVehicleRegistrationMinLine - 1
                mdcVehicleRegistrationMaxLine = mdcVehicleRegistrationMaxLine - 1
            end
        elseif addressRegistrationHover then 
            if mdcAddressRegistrationMinLine - 1 >= 1 then
                mdcAddressRegistrationMinLine = mdcAddressRegistrationMinLine - 1
                mdcAddressRegistrationMaxLine = mdcAddressRegistrationMaxLine - 1
            end
        elseif trafficRegistrationHover then 
            if mdcTrafficRegistrationMinLine - 1 >= 1 then
                mdcTrafficRegistrationMinLine = mdcTrafficRegistrationMinLine - 1
                mdcTrafficRegistrationMaxLine = mdcTrafficRegistrationMaxLine - 1
            end
        elseif mdcAdminDataHover then 
            if selectedAccount and GetEdit("mdc.newPassword") then 
                RemoveBar("mdc.newPassword")
                selectedAccount = false
            end

            if mdcAdminPanelMinLine - 1 >= 1 then
                mdcAdminPanelMinLine = mdcAdminPanelMinLine - 1
                mdcAdminPanelMaxLine = mdcAdminPanelMaxLine - 1
            end
        elseif mdcLogsHover then 
            if mdcLogsMinLine - 1 >= 1 then
                mdcLogsMinLine = mdcLogsMinLine - 1
                mdcLogsMaxLine = mdcLogsMaxLine - 1
            end
        elseif punishmentHover then 
            if punishmentMinLine - 1 >= 1 then
                punishmentMinLine = punishmentMinLine - 1
                punishmentMaxLine = punishmentMaxLine - 1
            end
        end
    end
end

function dxDrawOuterBorder(x, y, w, h, borderSize, borderColor, postGUI)
	borderSize = borderSize or 2
	borderColor = borderColor or tocolor(0, 0, 0, 255)
	
	dxDrawRectangle(x - borderSize, y - borderSize, w + (borderSize * 2), borderSize, borderColor, postGUI)
	dxDrawRectangle(x, y + h, w, borderSize, borderColor, postGUI)
	dxDrawRectangle(x - borderSize, y, borderSize, h + borderSize, borderColor, postGUI)
	dxDrawRectangle(x + w, y, borderSize, h + borderSize, borderColor, postGUI)
end

function isMenuHover()
    if adminMenuHover or logMenuHover or penalCodeMenuHover or closeHover or searchHover then 
        return true
    end

    return false
end

function getMenuIndex()
    if adminMenuHover then 
        return 9
    end

    if logMenuHover then 
        return 10
    end

    if penalCodeMenuHover then 
        return 11
    end

    return false
end

function drawTooltip(x, y, w, h, text, alpha, font)
    dxDrawRectangle(x, y, w, h, tocolor(44, 44, 44, alpha))
    dxDrawText(text, x, y, x + w, y + h, tocolor(130, 130, 130, alpha), 1, font, "center", "center")

    local w, h = res(50), res(50)
    local x, y = x + w / 2, y + res(6)

    exports.cr_dx:dxDrawImageAsTexture(x, y, w, h, textures["tooltiparrow"], 0, 0, 0, tocolor(44, 44, 44, alpha))
end

function onLoginSuccess(username)
    local vehicle = localPlayer.vehicle

    if vehicle then 
        local data = vehicle:getData("veh >> mdcData") or {unit = false}

        if source == localPlayer then 
            if not data.unit then 
                manageMDCPanel("switchToUnitPanel")
            else
                manageMDCPanel("switchToMainMdcPanel", true)
            end
        else
            if checkRender("renderMDC") then 
                manageMDCPanel("switchToUnitPanel", true)
            end

            local loggedUsername = localPlayer:getData("mdc >> loggedUsername")

            if loggedUsername ~= username then 
                localPlayer:setData("mdc >> loggedUsername", username)
            end
        end
    end
end
addEvent("mdc >> loginSuccess", true)
addEventHandler("mdc >> loginSuccess", root, onLoginSuccess)

addEventHandler("onClientVehicleExit", root,
    function(thePlayer, seat)
        if thePlayer == localPlayer then 
            if allowedVehicles[source.model] then 
                manageMDCPanel("exit")

                if localPlayer:getData("mdc >> loggedUsername") then 
                    localPlayer:setData("mdc >> loggedUsername", nil)
                end
            end
        end
    end
)

function onClientPlayerWasted()
    if checkRender("renderMDC") then 
        manageMDCPanel("exit")
    end
end
addEventHandler("onClientPlayerWasted", localPlayer, onClientPlayerWasted)

function destroyDutyBlips()
    for k, v in pairs(mdcDutyBlips) do 
        if isElement(v.element) then 
            v.element:destroy()
            v.element = nil
        end

        if isTimer(v.theTimer) then 
            killTimer(v.theTimer)
            v.theTimer = nil
        end

        exports["cr_radar"]:destroyStayBlip(v.name)
    end

    mdcDutyBlips = {}
    collectgarbage("collect")
end

function createAllDutyBlip()
    destroyDutyBlips()
    
    local vehicles = getElementsByType("vehicle")
    for k = 1, #vehicles do 
        local v = vehicles[k]

        if v then 
            local faction = v:getData("veh >> faction")

            if faction and faction > 0 then 
                if not mdcDutyBlips[v] then
                    local data = v:getData("veh >> mdcData") or {["unit"] = false, ["loggedIn"] = false, ["duty"] = false}
                    
                    if data.unit then 
                        createDutyBlip(v, data)
                    end
                end
            end
        end
    end
end

function createDutyBlip(vehicle, data)
    if exports.cr_dashboard:isPlayerInFaction(localPlayer, 1) then 
        if mdcDutyBlips[vehicle] then 
            local name = mdcDutyBlips[vehicle].name
            local element = mdcDutyBlips[vehicle].element
            local timer = mdcDutyBlips[vehicle].theTimer
            
            if isElement(element) then 
                element:destroy()
            end

            if isTimer(timer) then 
                killTimer(timer) 
            end
            
            exports.cr_radar:destroyStayBlip(name)
            mdcDutyBlips[vehicle] = nil
            collectgarbage("collect")
        end

        if data.duty and data.unit then 
            local name = ""

            if data.unit and data.duty then 
                name = data.unit .. " - " .. mdcDutyTypes[data.duty]
            end

            local element = Blip(vehicle.position, 0, 2, 255, 0, 0, 255, 0, 0)
            element:attach(vehicle)

            mdcDutyBlips[vehicle] = {name = name, element = element, theTimer = false}

            local r, g, b = getBlipColorByDutyType(data.duty)
            local state = true

            if data.duty == 2 then 
                exports.cr_radar:createStayBlip(name, element, 0, "target", 24, 24, r, g, b)

                mdcDutyBlips[vehicle].theTimer = setTimer(
                    function(gName)
                        exports.cr_radar:destroyStayBlip(gName)
                        
                        if state then 
                            local r, g, b = exports.cr_core:getServerColor("blue", false)

                            exports.cr_radar:createStayBlip(name, element, 0, "target", 24, 24, r, g, b)
                        else
                            local r, g, b = getBlipColorByDutyType(data.duty)

                            exports.cr_radar:createStayBlip(name, element, 0, "target", 24, 24, r, g, b)
                        end

                        state = not state
                    end, 500, 0, name
                )
            else 
                exports.cr_radar:createStayBlip(name, element, 0, "target", 24, 24, r, g, b)
            end
        end

        if selectedDuty ~= data.duty then 
            if localPlayer:isInVehicle() and localPlayer.vehicle == vehicle then 
                selectedDuty = data.duty
            end
        end
    end
end

local oldFactions = {}
local factionChangeTimer = false

function onClientMDCDataRequest(accounts, wantedCars, wantedPersons, wantedWeapons, tickets, registeredWeapons, registeredVehicles, registeredAddresses, registeredTraffices, logs, loggedAccounts, loginCount)
    mdcWantedCars = wantedCars
    mdcWantedPersons = wantedPersons
    mdcTickets = tickets
    mdcWantedWeapons = wantedWeapons

    mdcRegisteredWeapons = registeredWeapons
    mdcRegisteredVehicles = registeredVehicles
    mdcRegisteredAddresses = registeredAddresses
    mdcRegisteredTraffices = registeredTraffices

    local array = {}
    local loggedArray = {}
    local loggedArrayUsernames = {}

    for k, v in pairs(accounts) do 
        local factionPrefix = exports.cr_faction_scripts:getFactionPrefix(v.faction)

        if v.leader then 
            table.insert(array, 1, {
                id = v.id,
                username = k,
                password = v.password,
                faction = v.faction,
                factionPrefix = factionPrefix,
                leader = v.leader,
                online = v.online
            })
        else
            table.insert(array, {
                id = v.id,
                username = k,
                password = v.password,
                faction = v.faction,
                factionPrefix = factionPrefix,
                leader = v.leader,
                online = v.online
            })
        end

        if v.online then
            table.insert(loggedArray, {
                username = k,
                element = false
            })

            loggedArrayUsernames[k] = true
        end
    end

    local logsArray = {}

    for k, v in pairs(logs) do 
        local createdAt = getRealTime(v.createdAt)
        local createdAtText = ("[%i.%.2i.%.2i - %.2i:%.2i:%.2i]"):format(createdAt.year + 1900, createdAt.month + 1, createdAt.monthday, createdAt.hour, createdAt.minute, createdAt.second)

        table.insert(logsArray, {
            id = v.id,
            createdAt = createdAtText,
            text = v.text
        })
    end

    for k, v in pairs(loggedAccounts) do 
        if not loggedArrayUsernames[k] then 
            table.insert(loggedArray, {
                username = k,
                element = v
            })
        end
    end

    mdcAdminData = array
    mdcAdminDataKeys = accounts
    mdcLogs = logsArray
    mdcLoggedAccounts = loggedArray
    mdcLoginCount = loginCount
end
addEvent("onClientMDCDataRequest", true)
addEventHandler("onClientMDCDataRequest", root, onClientMDCDataRequest)

function onClientStart()
    setTimer(triggerLatentServerEvent, 2000, 1, "onClientMDCDataRequest", 5000, localPlayer)
    createAllDutyBlip()

    local resource = getResourceFromName("cr_dashboard")

    if resource and getResourceState(resource) == "running" and localPlayer:getData("loggedIn") then 
        oldFactions = exports.cr_dashboard:getPlayerFactions(localPlayer)
    end

    if isTimer(factionChangeTimer) then 
        killTimer(factionChangeTimer)
        factionChangeTimer = nil
    end

    factionChangeTimer = setTimer(
        function()
            if localPlayer:getData("loggedIn") then 
                local resource = getResourceFromName("cr_dashboard")

                if resource and getResourceState(resource) == "running" then 
                    local currentFactions = exports.cr_dashboard:getPlayerFactions(localPlayer)
        
                    if #currentFactions ~= #oldFactions then 
                        createAllDutyBlip()
        
                        oldFactions = currentFactions
                    end
                end
            end
        end, 1000, 0
    )
end
addEventHandler("onClientResourceStart", resourceRoot, onClientStart)

local renderCache = {}
local maxDistance = 30

addEventHandler("onClientElementDataChange", root,
    function(dataName, oldValue, newValue)
        if source.type == "vehicle" then 
            if dataName == "veh >> mdcData" then 
                local data = source:getData("veh >> mdcData") or {["unit"] = false, ["loggedIn"] = false, ["duty"] = false}

                if data["unit"] then 
                    if vehicleUnit ~= data["unit"] then 
                        if localPlayer:isInVehicle() and localPlayer.vehicle == source then 
                            vehicleUnit = data["unit"]
                        end
                    end
                end

                if data["loggedIn"] then 
                    if not vehicleUnit or vehicleUnit ~= data["unit"] then 
                        if localPlayer:isInVehicle() and localPlayer.vehicle == source then 
                            vehicleUnit = data["unit"]
                        end
                    end
                else
                    local vehicle = localPlayer.vehicle

                    if vehicle and vehicle == source then 
                        if mainPanelActive or unitPanelActive and not quittingFromMDC then 
                            manageMDCPanel("exit")
                        end
                    end
                end

                if type(data["duty"]) == "number" or type(data["duty"]) == "boolean" then 
                    createDutyBlip(source, data)
                end
            end
        end
    end
)

function renderVehicleUnits()
    for k, v in pairs(renderCache) do 
        if isElement(k) then 
            local compX, compY, compZ = k:getComponentPosition("bump_rear_dummy", "world")

            if compX and compY and compZ then 
                local theX, theY = getScreenFromWorldPosition(compX, compY, compZ, 1.0)
                local size = v["size"]
                local unit = v["unit"]

                if theX and theY then 
                    if size > 0 then 
                        if unit then 
                            shadowedText(unit, theX, theY, theX, theY, tocolor(255, 255, 255), size, exports["cr_fonts"]:getFont("Roboto", 17), "center", "center")
                        end
                    end
                end
            end
        end
    end
end
createRender("renderVehicleUnits", renderVehicleUnits)

setTimer(
    function()
        renderCache = {}

        if not localPlayer:getData("hudVisible") then 
            return 
        end

        local cameraX, cameraY, cameraZ = getCameraMatrix()
        local dim2, int2 = localPlayer.dimension, localPlayer.interior
        local vehicles = getElementsByType("vehicle", root, true)

        for k = 1, #vehicles do 
            local v = vehicles[k]

            if v then 
                local dim1 = v.dimension
                local int1 = v.interior

                if v.alpha == 255 and dim1 == dim2 and int1 == int2 then
                    local worldX, worldY, worldZ = getElementPosition(v)
                    local line = isLineOfSightClear(cameraX, cameraY, cameraZ, worldX, worldY, worldZ, true, false, false, true, false, false, false, localPlayer)

                    if line then
                        if allowedVehicles[v.model] then 
                            if isElementStreamedIn(v) and isElementOnScreen(v) then 
                                local distance = math.sqrt((cameraX - worldX) ^ 2 + (cameraY - worldY) ^ 2 + (cameraZ - worldZ) ^ 2) - 3
                                local size = 1 - (distance / maxDistance)
                                local data = v:getData("veh >> mdcData") or {["unit"] = false, ["loggedIn"] = false, ["duty"] = false}

                                if data["unit"] then 
                                    renderCache[v] = {
                                        ["distance"] = distance,
                                        ["size"] = size,
                                        ["unit"] = data["unit"],
                                    }
                                end
                            end
                        end
                    end
                end
            end
        end
    end, 150, 0
)

function shadowedText(text,x,y,w,h,color,fontsize,font,aligX,alignY, ignoreDrawn)
    dxDrawText(text:gsub("#%x%x%x%x%x%x", ""),x,y+1,w,h+1,tocolor(0,0,0,200),fontsize,font,aligX,alignY) -- Fent
    dxDrawText(text:gsub("#%x%x%x%x%x%x", ""),x,y-1,w,h-1,tocolor(0,0,0,200),fontsize,font,aligX,alignY) -- Lent
    dxDrawText(text:gsub("#%x%x%x%x%x%x", ""),x-1,y,w-1,h,tocolor(0,0,0,200),fontsize,font,aligX,alignY) -- Bal
    dxDrawText(text:gsub("#%x%x%x%x%x%x", ""),x+1,y,w+1,h,tocolor(0,0,0,200),fontsize,font,aligX,alignY) -- Jobb
    
    dxDrawText(text,x,y,w,h,color,fontsize,font,aligX,alignY, false, false, false, true, true)
end