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

local textures = {}

local realTime = getRealTime()

local currentHour = realTime.hour
local currentMinute = realTime.minute

local currentYear = realTime.year + 1900
local currentMonth = realTime.month
local currentMonthDay = realTime.monthday
local currentWeekDay = realTime.weekday

local formattedHourString = ("%02d:%02d"):format(currentHour, currentMinute)
local formattedDateString = timeNames.weeks[currentWeekDay] .. ", " .. timeNames.months[currentMonth] .. " " .. currentMonthDay
local dateTimer = false

local hoverKeyPad = false
local homeButtonHover = false

local deleteFromKeyPadIconHover = false
local callIconHover = false

local callDenyIconHover = false
local callAcceptIconHover = false

local messageSendIconHover = false
local backArrowIconHover = false

local iconActionHover = false
local volumeControlHover = false

local toggleIconHover = false
local settingsSelectorHover = false

local ringtoneActionHover = false
local currentRingtone = false
local currentRingtoneElement = false

local leftArrowIconHover = false
local rightArrowIconHover = false

local saveButtonHover = false
local selectedWallpaper = 1
local selectedLockscreen = 1

local addIconHover = false
local checkBoxHover = false

local lockScreenActive = false
local phoneActive = true

local lockScreenStartY = false
local phoneHover = false

local hoverPage = false
local callNumberText = ""

local callTimer = false
local hoverCallIcon = false

local lastInteraction = 0
local interactionDelayTime = 2000
local textDeleteTimer = false

local lastAdvertisement = 0
local advertisementDelay = 60000
local advertisementMultiplier = 1.5
adIconHover = false

local currentPhoneSlot = false
local selectedMessage = false

local screenSource = false
local cameraButtonHover = false

local selfieButtonHover = false
local inSelfieMode = false

local selectedMonth = currentMonth + 1
local selectedDay = false
local circleHoverIcon = false

local switchedFromAlarm = false
local selectedRingtone = false

local contentCache = {alarmTime = false, alarmName = false}
local alarmSoundElement = false
local alarmCheckTimer = false
local alarmDestroyTimer = false

local timerStarted = false
local circleActionHover = false

local timerText = "00:00:00"
local clockTimer = false

local timerData = {
    milliseconds = 0,
    seconds = 0,
    minutes = 0,
}

local callData = {
    targetNumber = false,
    targetElement = false,
    phoneService = false,
    pickedUp = false,
    messages = {}
}

phoneData = {
    myCallNumber = false,
    service = false,
    wallet = false,
    wallpaper = false,
    lockscreen = false,
    ringtone = false,
    ringtoneVolume = false,
    darkwebads = false,
    normalads = false,
    messages = false,
    contacts = false,
    showMyNumber = false,
    calendar = false,
    clock = false,
    simHistory = false,
    callHistory = false
}

local clockCopy = false
local myCallNumberSave = false
local alarmIndexSave = false

calledFaction = 911
calledFactionFrom = false

local contactEditing = {
    isEditing = false,
    selectedName = false,
    selectedNumber = false,
    selectedKey = false
}

phoneMessages = {}
local phoneAlarms = {}
local phoneContacts = {}
local ringtoneElements = {}

function createTextures()
    textures.phone = ":cr_phone/files/images/phone.png"
    -- textures.lockscreens = {}

    -- for i = 1, #availableLockscreens do 
    --     local v = availableLockscreens[i]

    --     if fileExists(v) then 
    --         textures.lockscreens[i] = v
    --     end
    -- end

    textures.lockui = ":cr_phone/files/images/lockscreens/lockui.png"
    textures.homebutton = ":cr_phone/files/images/home.png"

    textures.statusbar = ":cr_phone/files/images/statusbar.png"
    textures.dockbar = ":cr_phone/files/images/dockbar.png"
    textures.dots = ":cr_phone/files/images/dots.png"
    textures.whitebg = ":cr_phone/files/images/whitebg.png"

    -- textures.wallpapers = {}

    -- for i = 1, #availableWallpapers do 
    --     local v = availableWallpapers[i]

    --     if fileExists(v) then 
    --         textures.wallpapers[i] = v
    --     end
    -- end

    textures.dockbarApps = {}

    for i = 1, #applications.dockbar do 
        local v = applications.dockbar[i]

        if fileExists(v.path) then 
            textures.dockbarApps[v.textureName] = v.path
        end
    end

    textures.applications = {}

    for i = 1, #applications.normal do 
        local v = applications.normal[i]

        if fileExists(v.path) then 
            textures.applications[v.textureName] = v.path
        end
    end

    textures.callIcons = {}

    for i = 1, #callIcons do 
        local v = callIcons[i]
        
        if fileExists(v.path) then 
            textures.callIcons[i] = v.path
        end
    end

    textures.clockIcons = {}

    for i = 1, #clockIcons do 
        local v = clockIcons[i]
        
        if fileExists(v.path) then 
            if v.name == "Előzmények" then 
                textures.clockIcons[i] = textures.callIcons[2]
            else
                textures.clockIcons[i] = v.path
            end
        end
    end

    textures.keypad = ":cr_phone/files/images/call/keypad.png"
    textures.callbg = ":cr_phone/files/images/outgoingcall/callbg.png"
    textures.calldeny = ":cr_phone/files/images/outgoingcall/calldeny.png"
    textures.avatar = ":cr_phone/files/images/outgoingcall/avatar.png"
    textures.acceptcall = ":cr_phone/files/images/incomingcall/acceptcall.png"

    textures.backinfo = ":cr_phone/files/images/messages/backinfo.png"
    textures.messagesavatar = ":cr_phone/files/images/messages/messagesavatar.png"
    textures.addtocontactIcon = ":cr_phone/files/images/messages/addtocontact.png"
    textures.deleteIcon = ":cr_phone/files/images/messages/delete.png"
    textures.messagesIcon = ":cr_phone/files/images/messages/messages.png"
    textures.callIcon = ":cr_phone/files/images/messages/call.png"
    
    textures.ownmessage = ":cr_phone/files/images/ownmessage.png"
    textures.targetmessage = ":cr_phone/files/images/targetmessage.png"

    textures.chatinfo = ":cr_phone/files/images/chat/chatinfo.png"
    textures.chatavatar = ":cr_phone/files/images/chat/chatavatar.png"
    textures.chatbar = ":cr_phone/files/images/chat/chatbar.png"

    textures.backArrowIcon = ":cr_phone/files/images/advertisement/backarrow.png"
    textures.adLogo = ":cr_phone/files/images/advertisement/logo.png"
    textures.textbox = ":cr_phone/files/images/advertisement/textbox.png"
    textures.checkbox_off = ":cr_phone/files/images/advertisement/checkbox_off.png"
    textures.checkbox_on = ":cr_phone/files/images/advertisement/checkbox_on.png"

    textures.viewBackInfoIcon = ":cr_phone/files/images/viewmessages/backinfo.png"

    textures.settingsIcons = {}

    for i = 1, #availableSettings do 
        local v = availableSettings[i]

        if fileExists(v.iconPath) then 
            local iconId = v.iconId

            if not textures.settingsIcons[iconId] then 
                textures.settingsIcons[iconId] = v.iconPath
            end
        end
    end

    textures.volumecircle = ":cr_phone/files/images/settings/volumecircle.png"
    textures.arrowIcon = ":cr_phone/files/images/settings/arrow.png"
    textures.toggle_on = ":cr_phone/files/images/settings/toggle_on.png"
    textures.toggle_off = ":cr_phone/files/images/settings/toggle_off.png"
    textures.circleIcon = ":cr_phone/files/images/settings/circle.png"
    textures.circleCheckIcon = ":cr_phone/files/images/settings/circlecheck.png"
    textures.pauseButtonIcon = ":cr_phone/files/images/settings/pausebutton.png"
    textures.playButtonIcon = ":cr_phone/files/images/settings/playbutton.png"
    textures.bigArrowIcon = ":cr_phone/files/images/settings/bigarrow.png"

    textures.camerabg = ":cr_phone/files/images/camera/camerabg.png"
    textures.smallArrowIcon = ":cr_phone/files/images/calendar/smallarrow.png"
    textures.whiteCircleIcon = ":cr_phone/files/images/calendar/whitecircle.png"
    textures.circleWithOutline = ":cr_phone/files/images/calendar/circlewithoutline.png"
    textures.dotForCircleIcon = ":cr_phone/files/images/calendar/dot.png"

    textures.editContactIcon = ":cr_phone/files/images/contacts/editcontact.png"
    textures.timerIcon = ":cr_phone/files/images/clock/timer.png"
    textures.clockArrowIcon = ":cr_phone/files/images/clock/arrow.png"
    textures.bigWhiteCircleIcon = ":cr_phone/files/images/clock/bigwhitecircle.png"

    textures.search = ":cr_phone/files/images/search.png"
end

function destroyTextures()
    textures = {}
    collectgarbage("collect")
end

function onClientStart()
    createTextures()

    dateTimer = setTimer(
        function()
            realTime = getRealTime()

            currentHour = realTime.hour
            currentMinute = realTime.minute

            currentYear = realTime.year + 1900
            currentMonth = realTime.month
            currentMonthDay = realTime.monthday
            currentWeekDay = realTime.weekday

            formattedHourString = ("%02d:%02d"):format(currentHour, currentMinute)
            formattedDateString = timeNames.weeks[currentWeekDay] .. ", " .. timeNames.months[currentMonth] .. " " .. currentMonthDay
        end, 5000, 0
    )
end
-- addEventHandler("onClientResourceStart", resourceRoot, onClientStart)

function getColors(darkMode)
    local bgColor = tocolor(255, 255, 255)
    local iconAndTextColor = tocolor(150, 150, 150)
    local homeButtonColor = tocolor(22, 22, 22)

    if darkMode then 
        bgColor = tocolor(10, 10, 10)
        iconAndTextColor = tocolor(255, 255, 255, 100)
        homeButtonColor = tocolor(255, 255, 255)
    end

    return bgColor, iconAndTextColor, homeButtonColor
end

function renderPhone()
    -- if localPlayer.name ~= "Hugh_Wiley" then 
    --     return
    -- end
    
    local enabled, phoneX, phoneY = exports.cr_interface:getDetails("phone")
    local font = exports.cr_fonts:getFont("SFUIDisplay-Thin", getRealFontSize(32))
    local font2 = exports.cr_fonts:getFont("SFUIDisplay-Regular", getRealFontSize(12))
    local font3 = exports.cr_fonts:getFont("SFUIDisplay-Semibold", getRealFontSize(9))
    local font4 = exports.cr_fonts:getFont("SFUIDisplay-Regular", getRealFontSize(9))
    local font5 = exports.cr_fonts:getFont("SFUIDisplay-Regular", getRealFontSize(7))
    local font6 = exports.cr_fonts:getFont("SFUIDisplay-Regular", getRealFontSize(20))
    local font7 = exports.cr_fonts:getFont("SFUIDisplay-Regular", getRealFontSize(10))
    local font8 = exports.cr_fonts:getFont("SFUIDisplay-Regular", getRealFontSize(16))
    local font9 = exports.cr_fonts:getFont("SFUIDisplay-Light", getRealFontSize(10))
    local font10 = exports.cr_fonts:getFont("SFUIDisplay-Light", getRealFontSize(11))
    local font11 = exports.cr_fonts:getFont("SFUIDisplay-Regular", getRealFontSize(11))
    local font12 = exports.cr_fonts:getFont("SFUIDisplay-Regular", getRealFontSize(14))
    local font13 = exports.cr_fonts:getFont("SFUIDisplay-Regular", getRealFontSize(12))
    local font14 = exports.cr_fonts:getFont("SFUIDisplay-Regular", getRealFontSize(30))
    local font15 = exports.cr_fonts:getFont("SFUIDisplay-Regular", getRealFontSize(13))

    local redR, redG, redB = exports.cr_core:getServerColor("red", false)

    phoneHover = nil
    hoverPage = nil

    if enabled then 
        local phoneW, phoneH = resp(328), resp(638)
        local bgW, bgH = resp(287), resp(602)

        local bgX, bgY = phoneX + resp(20), phoneY + resp(15)
        local inSlot = exports.cr_core:isInSlot(bgX, bgY, bgW, bgH)
        if inSlot then 
            phoneHover = true
        end

        exports.cr_dx:dxDrawImageAsTexture(phoneX, phoneY, phoneW, phoneH, textures.phone)

        if lockScreenActive then 
            local currentLockscreen = phoneData.lockscreen

            exports.cr_dx:dxDrawImageAsTexture(bgX, bgY, bgW, bgH, ":cr_phone/files/images/wallpapers/" .. currentLockscreen .. ".png")
            exports.cr_dx:dxDrawImageAsTexture(bgX, bgY, bgW, bgH, textures.lockui)

            local statusW, statusH = resp(255), resp(10)
            local statusX, statusY = bgX + bgW - statusW - resp(10), bgY + resp(10)

            exports.cr_dx:dxDrawImageAsTexture(statusX, statusY, statusW, statusH, textures.statusbar)
            dxDrawText(formattedHourString, bgX - statusW + resp(45), statusY, bgX + bgW, bgY + bgH, tocolor(255, 255, 255), 1, font3, "center", "top")

            dxDrawText(formattedHourString, bgX, bgY + resp(80), bgX + bgW, bgY + bgH, tocolor(255, 255, 255), 1, font, "center", "top")
            dxDrawText(formattedDateString, bgX, bgY + resp(130), bgX + bgW, bgY + bgH, tocolor(255, 255, 255), 1, font2, "center", "top")
                        
            local homeW, homeH = resp(100), resp(4)
            local homeX, homeY = bgX + homeW - resp(5), bgY + bgH - (homeH * 3)

            exports.cr_dx:dxDrawImageAsTexture(homeX, homeY, homeW, homeH, textures.homebutton)
        else
            local statusW, statusH = resp(255), resp(10)
            local statusX, statusY = bgX + bgW - statusW - resp(10), bgY + resp(10)

            if not selectedPage then 
                local dockW, dockH = resp(266), resp(68)
                local dockX, dockY = bgX + resp(8.5), bgY + bgH - dockH - resp(8.5)
                local currentWallpaper = phoneData.wallpaper

                exports.cr_dx:dxDrawImageAsTexture(bgX, bgY, bgW, bgH, ":cr_phone/files/images/wallpapers/" .. currentWallpaper .. ".png")
                exports.cr_dx:dxDrawImageAsTexture(dockX, dockY, dockW, dockH, textures.dockbar)

                exports.cr_dx:dxDrawImageAsTexture(statusX, statusY, statusW, statusH, textures.statusbar)
                dxDrawText(formattedHourString, bgX - statusW + resp(45), statusY, bgX + bgW, bgY + bgH, tocolor(255, 255, 255), 1, font3, "center", "top")

                local dotsW, dotsH = resp(31), resp(6)
                local dotsX, dotsY = dockX + dockW / 2 - dotsW / 2, dockY - (dotsH * 2)

                exports.cr_dx:dxDrawImageAsTexture(dotsX, dotsY, dotsW, dotsH, textures.dots)

                local appW, appH = resp(46), resp(45)
                local appX, appY = dockX + resp(10), dockY + dockH / 2 - appH / 2

                for i = 1, #applications.dockbar do 
                    local v = applications.dockbar[i]

                    if v and v.textureName then 
                        if textures.dockbarApps[v.textureName] then 
                            local inSlot = exports.cr_core:isInSlot(appX, appY, appW, appH)
                            if inSlot then 
                                hoverPage = i
                            end

                            exports.cr_dx:dxDrawImageAsTexture(appX, appY, appW, appH, textures.dockbarApps[v.textureName])
                        end
                    end

                    appX = appX + appW + resp(22.5)
                end

                local appStartX, appStartY = bgX + resp(20), bgY + resp(50)

                local index = 1
                for i = 0, #applications.normal - 1 do 
                    local v = applications.normal[i + 1]

                    if v and v.textureName then 
                        if textures.applications[v.textureName] then 
                            local appX, appY = appStartX + (appW + resp(21)) * (i % maxAppInARow), appStartY + (appH + resp(40)) * (math.floor(i / maxAppInAColumn))
                            local inSlot = exports.cr_core:isInSlot(appX, appY, appW, appH)
                            if inSlot then 
                                hoverPage = i + 5
                            end

                            exports.cr_dx:dxDrawImageAsTexture(appX, appY, appW, appH, textures.applications[v.textureName])
                            dxDrawText(v.name, appX, appY, appX + appW, appY + appH + resp(20), tocolor(255, 255, 255), 1, font4, "center", "bottom")
                        end
                    end
                end
            else
                if availablePages[selectedPage] then 
                    local darkMode = false
                    local bgColor, iconAndTextColor, homeButtonColor = getColors(darkMode)

                    homeButtonHover = nil
                    if availablePages[selectedPage] == "call" then 
                        local keyPadColor = tocolor(255, 255, 255)
                        local statusColor = tocolor(0, 0, 0)

                        if darkMode then 
                            keyPadColor = tocolor(100, 100, 100)
                            statusColor = tocolor(255, 255, 255, 100)
                        end

                        exports.cr_dx:dxDrawImageAsTexture(bgX, bgY, bgW, bgH, textures.whitebg, 0, 0, 0, bgColor)

                        local statusW, statusH = resp(255), resp(10)
                        local statusX, statusY = bgX + bgW - statusW - resp(10), bgY + resp(10)

                        exports.cr_dx:dxDrawImageAsTexture(statusX, statusY, statusW, statusH, textures.statusbar, 0, 0, 0, statusColor)
                        dxDrawText(formattedHourString, bgX - statusW + resp(45), statusY, bgX + bgW, bgY + bgH, statusColor, 1, font3, "center", "top")
                        dxDrawText(formatPhoneNumber(callNumberText), bgX, bgY + resp(80), bgX + bgW, bgY + bgH, tocolor(0, 0, 0), 1, font6, "center", "top")

                        local keyPadW, keyPadH = resp(223), resp(342)
                        local keyPadX, keyPadY = bgX + bgW / 2 - keyPadW / 2, bgY + keyPadH / 2 - resp(10)

                        exports.cr_dx:dxDrawImageAsTexture(keyPadX, keyPadY, keyPadW, keyPadH, textures.keypad, 0, 0, 0, keyPadColor)

                        local buttonW, buttonH = resp(63), resp(62)

                        hoverKeyPad = nil
                        for i = 0, #keyPad - 1 do 
                            local buttonX, buttonY = keyPadX + (buttonW + resp(17)) * (i % 3), keyPadY + (buttonH + resp(8)) * (math.floor(i / 3))
                            local inSlot = exports.cr_core:isInSlot(buttonX, buttonY, buttonW, buttonH)
                            if inSlot then 
                                hoverKeyPad = i + 1
                            end
                        end

                        deleteFromKeyPadIconHover = nil

                        local deleteIconW, deleteIconH = resp(25), resp(20)
                        local deleteIconX, deleteIconY = keyPadX + keyPadW - deleteIconW - resp(20), keyPadY + keyPadH - deleteIconH - resp(18)
                        local inSlot = exports.cr_core:isInSlot(deleteIconX, deleteIconY, deleteIconW, deleteIconH)
                        if inSlot then 
                            deleteFromKeyPadIconHover = true
                        end

                        callIconHover = nil

                        local callIconW, callIconH = resp(60), resp(60)
                        local callIconX, callIconY = keyPadX + keyPadW / 2 - callIconW / 2, keyPadY + keyPadH - callIconH
                        local inSlot = exports.cr_core:isInSlot(callIconX, callIconY, callIconW, callIconH)
                        if inSlot then 
                            callIconHover = true
                        end

                        local iconW, iconH = resp(40), resp(40)
                        local iconStartX, iconStartY = bgX + resp(10), bgY + bgH - iconH - resp(35)

                        hoverCallIcon = nil

                        for i = 1, #callIcons do 
                            local v = callIcons[i]

                            if textures.callIcons[i] then 
                                local color = iconAndTextColor
                                local inSlot = exports.cr_core:isInSlot(iconStartX, iconStartY, iconW, iconH)
                                if inSlot then 
                                    hoverCallIcon = i
                                end

                                if i == 4 then 
                                    color = tocolor(0, 122, 255)
                                end

                                exports.cr_dx:dxDrawImageAsTexture(iconStartX, iconStartY, iconW, iconH, textures.callIcons[i], 0, 0, 0, color)
                                dxDrawText(v.name, iconStartX, iconStartY, iconStartX + iconW, iconStartY + iconH + resp(5), color, 1, font5, "center", "bottom")
                            end

                            iconStartX = iconStartX + (iconW + resp(17))
                        end

                        local homeW, homeH = resp(100), resp(4)
                        local homeX, homeY = bgX + homeW - resp(5), bgY + bgH - (homeH * 3)
                        local inSlot = exports.cr_core:isInSlot(homeX, homeY, homeW, homeH)
                        if inSlot then 
                            homeButtonHover = true
                        end

                        exports.cr_dx:dxDrawImageAsTexture(homeX, homeY, homeW, homeH, textures.homebutton, 0, 0, 0, homeButtonColor)
                    elseif availablePages[selectedPage] == "outgoingcall" then 
                        exports.cr_dx:dxDrawImageAsTexture(bgX, bgY, bgW, bgH, textures.callbg)

                        exports.cr_dx:dxDrawImageAsTexture(statusX, statusY, statusW, statusH, textures.statusbar)
                        dxDrawText(formattedHourString, bgX - statusW + resp(45), statusY, bgX + bgW, bgY + bgH, tocolor(255, 255, 255), 1, font3, "center", "top")

                        local avatarW, avatarH = resp(40), resp(40)
                        local avatarX, avatarY = bgX + avatarW, bgY + (avatarH * 2) - resp(10)
                        local targetPlayer = phoneContacts[callData.targetNumber] or formatPhoneNumber(callData.targetNumber)

                        exports.cr_dx:dxDrawImageAsTexture(avatarX, avatarY, avatarW, avatarH, textures.avatar)

                        if phoneContacts[callData.targetNumber] or factionCalls[callData.targetNumber] then 
                            dxDrawText(targetPlayer, bgX, avatarY, bgX + bgW, avatarY + avatarH, tocolor(255, 255, 255), 1, font8, "center", "center")
                        else
                            dxDrawText(targetPlayer, avatarX + avatarW + resp(5), avatarY, avatarX + avatarW, avatarY + avatarH, tocolor(255, 255, 255), 1, font8, "left", "center")
                        end

                        dxDrawText("Kimenő hívás...", bgX, bgY, bgX + bgW, avatarY + avatarH + resp(15), tocolor(255, 255, 255), 1, font9, "center", "bottom")

                        callDenyIconHover = nil

                        local callDenyIconW, callDenyIconH = resp(54), resp(53)
                        local callDenyIconX, callDenyIconY = bgX + bgW / 2 - callDenyIconW / 2, bgY + bgH - (callDenyIconH * 3)
                        local inSlot = exports.cr_core:isInSlot(callDenyIconX, callDenyIconY, callDenyIconW, callDenyIconH)
                        if inSlot then 
                            callDenyIconHover = true
                        end

                        exports.cr_dx:dxDrawImageAsTexture(callDenyIconX, callDenyIconY, callDenyIconW, callDenyIconH, textures.calldeny)
                        dxDrawText("Elutasítás", callDenyIconX, callDenyIconY, callDenyIconX + callDenyIconW, callDenyIconY + callDenyIconH + resp(20), tocolor(255, 255, 255), 1, font7, "center", "bottom")
                    elseif availablePages[selectedPage] == "incomingcall" then 
                        exports.cr_dx:dxDrawImageAsTexture(bgX, bgY, bgW, bgH, textures.callbg)

                        exports.cr_dx:dxDrawImageAsTexture(statusX, statusY, statusW, statusH, textures.statusbar)
                        dxDrawText(formattedHourString, bgX - statusW + resp(45), statusY, bgX + bgW, bgY + bgH, tocolor(255, 255, 255), 1, font3, "center", "top")

                        local avatarW, avatarH = resp(40), resp(40)
                        local avatarX, avatarY = bgX + avatarW, bgY + (avatarH * 2) - resp(10)

                        local targetPlayer = phoneContacts[callData.targetNumber] or formatPhoneNumber(callData.targetNumber)
                        local phoneService = callData.phoneService or "United Wireless"

                        exports.cr_dx:dxDrawImageAsTexture(avatarX, avatarY, avatarW, avatarH, textures.avatar)

                        if phoneContacts[callData.targetNumber] then 
                            dxDrawText(targetPlayer, bgX, avatarY, bgX + bgW, avatarY + avatarH, tocolor(255, 255, 255), 1, font8, "center", "center")
                            dxDrawText(phoneService, bgX, avatarY, bgX + bgW, avatarY + avatarH + resp(62), tocolor(255, 255, 255), 1, font2, "center", "center")
                        else
                            dxDrawText(targetPlayer, avatarX + avatarW + resp(5), avatarY, avatarX + avatarW, avatarY + avatarH, tocolor(255, 255, 255), 1, font8, "left", "center")
                            dxDrawText(phoneService, avatarX + avatarW + resp(165), avatarY, avatarX + avatarW, avatarY + avatarH + resp(62), tocolor(255, 255, 255), 1, font2, "center", "center")
                        end

                        dxDrawText("Bejövő hívás...", bgX, bgY, bgX + bgW, bgY + bgH, tocolor(255, 255, 255), 1, font10, "center", "center")

                        callDenyIconHover = nil

                        local callDenyIconW, callDenyIconH = resp(54), resp(53)
                        local callDenyIconX, callDenyIconY = bgX + callDenyIconW - resp(10), bgY + bgH - (callDenyIconH * 3)
                        local inSlot = exports.cr_core:isInSlot(callDenyIconX, callDenyIconY, callDenyIconW, callDenyIconH)
                        if inSlot then 
                            callDenyIconHover = true
                        end

                        exports.cr_dx:dxDrawImageAsTexture(callDenyIconX, callDenyIconY, callDenyIconW, callDenyIconH, textures.calldeny)
                        dxDrawText("Elutasítás", callDenyIconX, callDenyIconY, callDenyIconX + callDenyIconW, callDenyIconY + callDenyIconH + resp(20), tocolor(255, 255, 255), 1, font7, "center", "bottom")

                        callAcceptIconHover = nil

                        local callAcceptIconW, callAcceptIconH = resp(54), resp(53)
                        local callAcceptIconX, callAcceptIconY = bgX + bgW - (callAcceptIconW * 2) + resp(10), bgY + bgH - (callAcceptIconH * 3)
                        local inSlot = exports.cr_core:isInSlot(callAcceptIconX, callAcceptIconY, callAcceptIconW, callAcceptIconH)
                        if inSlot then 
                            callAcceptIconHover = true
                        end

                        exports.cr_dx:dxDrawImageAsTexture(callAcceptIconX, callAcceptIconY, callAcceptIconW, callAcceptIconH, textures.acceptcall)
                        dxDrawText("Elfogadás", callAcceptIconX, callAcceptIconY, callAcceptIconX + callAcceptIconW, callAcceptIconY + callAcceptIconH + resp(20), tocolor(255, 255, 255), 1, font7, "center", "bottom")
                    elseif availablePages[selectedPage] == "chat" then 
                        local statusColor = tocolor(0, 0, 0)

                        if darkMode then 
                            statusColor = tocolor(255, 255, 255, 100)
                        end

                        exports.cr_dx:dxDrawImageAsTexture(bgX, bgY, bgW, bgH, textures.whitebg, 0, 0, 0, bgColor)

                        exports.cr_dx:dxDrawImageAsTexture(statusX, statusY, statusW, statusH, textures.statusbar, 0, 0, 0, statusColor)
                        dxDrawText(formattedHourString, bgX - statusW + resp(45), statusY, bgX + bgW, bgY + bgH, statusColor, 1, font3, "center", "top")

                        local avatarW, avatarH = resp(33), resp(43)
                        local avatarX, avatarY = bgX + bgW / 2 - avatarW / 2, bgY + avatarH / 2 + resp(2)
                        local targetPlayer = phoneContacts[callData.targetNumber] or formatPhoneNumber(callData.targetNumber)

                        exports.cr_dx:dxDrawImageAsTexture(avatarX, avatarY, avatarW, avatarH, textures.chatavatar)
                        dxDrawText(targetPlayer, avatarX, avatarY, avatarX + avatarW, avatarY + avatarH + resp(18), tocolor(0, 0, 0), 1, font10, "center", "bottom")

                        -- local chatInfoW, chatInfoH = resp(254), resp(19)
                        -- local chatInfoX, chatInfoY = bgX + resp(15), avatarY + chatInfoH

                        -- exports.cr_dx:dxDrawImageAsTexture(chatInfoX, chatInfoY, chatInfoW, chatInfoH, textures.chatinfo)

                        local chatInfoW, chatInfoH = resp(259), resp(31)
                        local chatInfoX, chatInfoY = bgX + resp(10), avatarY + chatInfoH - resp(10)

                        exports.cr_dx:dxDrawImageAsTexture(chatInfoX, chatInfoY, chatInfoW, chatInfoH, textures.chatinfo)

                        callDenyIconHover = nil

                        local callDenyIconW, callDenyIconH = resp(30), resp(31)
                        local callDenyIconX, callDenyIconY = bgX + callDenyIconW - resp(20), chatInfoY
                        local inSlot = exports.cr_core:isInSlot(callDenyIconX, callDenyIconY, callDenyIconW, callDenyIconH)
                        if inSlot then 
                            callDenyIconHover = true
                        end

                        -- backArrowIconHover = nil

                        -- local backArrowW, backArrowH = resp(10), resp(19)
                        -- local backArrowX, backArrowY = backInfoX, backInfoY + resp(2)
                        -- local inSlot = exports.cr_core:isInSlot(backArrowX, backArrowY, backArrowW, backArrowH)
                        -- if inSlot then 
                        --     backArrowIconHover = true
                        -- end

                        local lineW, lineH = bgW, resp(1)
                        local lineX, lineY = bgX, bgY + (avatarH * 2) + resp(3)

                        dxDrawRectangle(lineX, lineY, lineW, lineH, tocolor(170, 170, 170))
                        dxDrawText("Hívás folyamatban...", lineX, lineY, lineX + lineW, lineY + lineH + resp(18), tocolor(170, 170, 170), 1, font7, "center", "bottom")

                        local messageBarW, messageBarH = resp(268), resp(30)
                        local messageBarX, messageBarY = bgX + resp(10), lineY + messageBarH + resp(20)

                        for i = chatMinLine, chatMaxLine do 
                            local v = callData.messages[i]

                            if v then 
                                local sourceNumber = v.sourceNumber
                                local text = v.text

                                if sourceNumber == phoneData.myCallNumber then
                                    exports.cr_dx:dxDrawImageAsTexture(messageBarX, messageBarY, messageBarW, messageBarH, textures.ownmessage)
                                    dxDrawText(text, messageBarX, messageBarY, messageBarX + messageBarW - resp(10), messageBarY + messageBarH, tocolor(0, 0, 0), 1, font7, "right", "center", true)
                                else 
                                    exports.cr_dx:dxDrawImageAsTexture(messageBarX, messageBarY, messageBarW, messageBarH, textures.targetmessage)
                                    dxDrawText(text, messageBarX + resp(10), messageBarY, messageBarX + messageBarW, messageBarY + messageBarH, tocolor(0, 0, 0), 1, font7, "left", "center", true)
                                end

                                messageBarY = messageBarY + messageBarH + resp(5)
                            end
                        end

                        local chatBarW, chatBarH = resp(235), resp(35)
                        local chatBarX, chatBarY = bgX + bgW / 2 - chatBarW / 2, bgY + bgH - (chatBarH * 2) + resp(5)

                        exports.cr_dx:dxDrawImageAsTexture(chatBarX, chatBarY, chatBarW, chatBarH, textures.chatbar)

                        messageSendIconHover = nil

                        local messageSendW, messageSendH = resp(26), resp(26)
                        local messageSendX, messageSendY = chatBarX + chatBarW - messageSendW - resp(7), chatBarY + chatBarH / 2 - messageSendH / 2
                        local inSlot = exports.cr_core:isInSlot(messageSendX, messageSendY, messageSendW, messageSendH)
                        if inSlot then 
                            messageSendIconHover = true
                        end

                        UpdatePos("phone.chat", {chatBarX + resp(10), chatBarY, chatBarW - resp(45), chatBarH})
                        UpdateAlpha("phone.chat", tocolor(153, 153, 153, 255))

                        local homeW, homeH = resp(100), resp(4)
                        local homeX, homeY = bgX + homeW - resp(5), bgY + bgH - (homeH * 3)
                        local inSlot = exports.cr_core:isInSlot(homeX, homeY, homeW, homeH)
                        if inSlot then 
                            homeButtonHover = true
                        end

                        exports.cr_dx:dxDrawImageAsTexture(homeX, homeY, homeW, homeH, textures.homebutton, 0, 0, 0, homeButtonColor)
                    elseif availablePages[selectedPage] == "messages" then 
                        local statusColor = tocolor(0, 0, 0)

                        if darkMode then 
                            statusColor = tocolor(255, 255, 255, 100)
                        end

                        exports.cr_dx:dxDrawImageAsTexture(bgX, bgY, bgW, bgH, textures.whitebg, 0, 0, 0, bgColor)

                        exports.cr_dx:dxDrawImageAsTexture(statusX, statusY, statusW, statusH, textures.statusbar, 0, 0, 0, statusColor)
                        dxDrawText(formattedHourString, bgX - statusW + resp(45), statusY, bgX + bgW, bgY + bgH, statusColor, 1, font3, "center", "top")

                        local avatarH = resp(43)
                        local avatarY = bgY + avatarH / 2 + resp(2)
                        
                        local backInfoW, backInfoH = resp(258), resp(16)
                        local backInfoX, backInfoY = bgX + resp(15), avatarY + backInfoH

                        backArrowIconHover = nil

                        local backArrowHoverW, backArrowHoverH = resp(10), resp(19)
                        local backArrowHoverX, backArrowHoverY = backInfoX, backInfoY
                        local inSlot = exports.cr_core:isInSlot(backArrowHoverX, backArrowHoverY, backArrowHoverW, backArrowHoverH)
                        if inSlot then 
                            backArrowIconHover = true
                        end

                        addIconHover = nil

                        local addIconHoverW, addIconHoverH = resp(16), resp(17)
                        local addIconHoverX, addIconHoverY = backInfoX + backInfoW - addIconHoverW, backInfoY
                        local inSlot = exports.cr_core:isInSlot(addIconHoverX, addIconHoverY, addIconHoverW, addIconHoverH)
                        if inSlot then 
                            addIconHover = true
                        end

                        exports.cr_dx:dxDrawImageAsTexture(backInfoX, backInfoY, backInfoW, backInfoH, textures.backinfo)
                        dxDrawText("Üzenetek", backInfoX, backInfoY + resp(2), backInfoX + backInfoW, backInfoY + backInfoH, tocolor(0, 0, 0), 1, font2, "center", "center")

                        local searchW, searchH = resp(179), resp(26)
                        local searchX, searchY = bgX + bgW / 2 - searchW / 2, backInfoY + searchH

                        exports.cr_dx:dxDrawImageAsTexture(searchX, searchY, searchW, searchH, textures.search)

                        UpdatePos("messages.search", {searchX + resp(10), searchY, searchW - resp(45), searchH})
                        UpdateAlpha("messages.search", tocolor(153, 153, 153, 255))

                        local lineW, lineH = bgW, resp(1)
                        local lineX, lineY = bgX, searchY + searchH + resp(10)

                        dxDrawRectangle(lineX, lineY, lineW, lineH, tocolor(170, 170, 170))

                        local avatarW, avatarH = resp(32), resp(32)
                        local avatarX, avatarY = lineX + resp(10), lineY + resp(5)

                        iconActionHover = nil

                        local array = phoneMessages
                        local percent = #array

                        if phoneMessagesSearchCache then 
                            array = phoneMessagesSearchCache
                            percent = #array
                        end

                        if messagesMaxLine > percent then 
                            messagesMinLine = 1
                            _messagesMaxLine = 11
                            messagesMaxLine = _messagesMaxLine
                        end

                        for i = messagesMinLine, messagesMaxLine do 
                            local v = array[i]

                            if v and v.name and v.phoneNumber then 
                                local phoneNumber = v.phoneNumber
                                local name = phoneContacts[phoneNumber] or "Ismeretlen"

                                exports.cr_dx:dxDrawImageAsTexture(avatarX, avatarY, avatarW, avatarH, textures.messagesavatar)
                                dxDrawText(name, avatarX + avatarW + resp(5), avatarY - resp(3), avatarX + avatarW, avatarY + avatarH, tocolor(0, 0, 0), 1, font2, "left", "top")
                                dxDrawText(formatPhoneNumber(phoneNumber), avatarX + avatarW + resp(5), avatarY - resp(5), avatarX + avatarW, avatarY + avatarH, tocolor(0, 0, 0), 1, font7, "left", "bottom")

                                local deleteIconW, deleteIconH = resp(12), resp(14)
                                local deleteIconX, deleteIconY = avatarX + lineW - resp(35), avatarY + resp(10)
                                local inSlot = exports.cr_core:isInSlot(deleteIconX, deleteIconY, deleteIconW, deleteIconH)
                                if inSlot then 
                                    iconActionHover = "deleteFromMessages:" .. i
                                end

                                exports.cr_dx:dxDrawImageAsTexture(deleteIconX, deleteIconY, deleteIconW, deleteIconH, textures.deleteIcon)

                                local addIconW, addIconH = resp(14), resp(14)
                                local addIconX, addIconY = deleteIconX - addIconW - resp(10), deleteIconY
                                local inSlot = exports.cr_core:isInSlot(addIconX, addIconY, addIconW, addIconH)
                                if inSlot then 
                                    iconActionHover = "addToContacts:" .. i
                                end

                                exports.cr_dx:dxDrawImageAsTexture(addIconX, addIconY, addIconW, addIconH, textures.addtocontactIcon)

                                local messagesIconW, messagesIconH = resp(16), resp(14)
                                local messagesIconX, messagesIconY = addIconX - messagesIconW - resp(10), addIconY
                                local inSlot = exports.cr_core:isInSlot(messagesIconX, messagesIconY, messagesIconW, messagesIconH)
                                if inSlot then 
                                    iconActionHover = "selectMessage:" .. i
                                end

                                exports.cr_dx:dxDrawImageAsTexture(messagesIconX, messagesIconY, messagesIconW, messagesIconH, textures.messagesIcon)

                                local callIconW, callIconH = resp(13), resp(13)
                                local callIconX, callIconY = messagesIconX - callIconW - resp(10), messagesIconY
                                local inSlot = exports.cr_core:isInSlot(callIconX, callIconY, callIconW, callIconH)
                                if inSlot then 
                                    iconActionHover = "callFromMessages:" .. i
                                end

                                exports.cr_dx:dxDrawImageAsTexture(callIconX, callIconY, callIconW, callIconH, textures.callIcon)

                                local lineW, lineH = lineW - resp(20), resp(1)
                                local lineX, lineY = bgX + resp(10), avatarY + avatarH + resp(5)

                                dxDrawRectangle(lineX, lineY, lineW, lineH, tocolor(170, 170, 170))

                                avatarY = avatarY + avatarH + resp(10)
                            end
                        end

                        local length = #array

                        if length <= 0 then 
                            dxDrawText("Nincs egyetlen üzeneted sem", lineX, lineY, lineX + lineW, lineY + lineH + resp(25), tocolor(0, 0, 0), 1, font2, "center", "bottom")
                        end

                        local homeW, homeH = resp(100), resp(4)
                        local homeX, homeY = bgX + homeW - resp(5), bgY + bgH - (homeH * 3)
                        local inSlot = exports.cr_core:isInSlot(homeX, homeY, homeW, homeH)
                        if inSlot then 
                            homeButtonHover = true
                        end

                        exports.cr_dx:dxDrawImageAsTexture(homeX, homeY, homeW, homeH, textures.homebutton, 0, 0, 0, homeButtonColor)
                    elseif availablePages[selectedPage] == "addNewMessage" then 
                        local statusColor = tocolor(0, 0, 0)

                        if darkMode then 
                            statusColor = tocolor(255, 255, 255, 100)
                        end

                        exports.cr_dx:dxDrawImageAsTexture(bgX, bgY, bgW, bgH, textures.whitebg, 0, 0, 0, bgColor)

                        exports.cr_dx:dxDrawImageAsTexture(statusX, statusY, statusW, statusH, textures.statusbar, 0, 0, 0, statusColor)
                        dxDrawText(formattedHourString, bgX - statusW + resp(45), statusY, bgX + bgW, bgY + bgH, statusColor, 1, font3, "center", "top")

                        local avatarH = resp(43)
                        local avatarY = bgY + avatarH / 2 + resp(2)
                        
                        local backInfoW, backInfoH = resp(258), resp(16)
                        local backInfoX, backInfoY = bgX + resp(15), avatarY + backInfoH

                        backArrowIconHover = nil

                        local backArrowHoverW, backArrowHoverH = resp(10), resp(19)
                        local backArrowHoverX, backArrowHoverY = backInfoX, backInfoY
                        local inSlot = exports.cr_core:isInSlot(backArrowHoverX, backArrowHoverY, backArrowHoverW, backArrowHoverH)
                        if inSlot then 
                            backArrowIconHover = true
                        end

                        addIconHover = nil

                        local addIconHoverW, addIconHoverH = resp(16), resp(17)
                        local addIconHoverX, addIconHoverY = backInfoX + backInfoW - addIconHoverW, backInfoY
                        local inSlot = exports.cr_core:isInSlot(addIconHoverX, addIconHoverY, addIconHoverW, addIconHoverH)
                        if inSlot then 
                            addIconHover = true
                        end

                        exports.cr_dx:dxDrawImageAsTexture(backInfoX, backInfoY, backInfoW, backInfoH, textures.backinfo)
                        dxDrawText("Üzenet hozzáadása", backInfoX, backInfoY, backInfoX + backInfoW, backInfoY + backInfoH + resp(2), tocolor(0, 0, 0), 1, font2, "center", "bottom")

                        local lineW, lineH = bgW, resp(1)
                        local lineX, lineY = bgX, backInfoY + backInfoH + resp(40)

                        dxDrawRectangle(lineX, lineY, lineW, lineH, tocolor(170, 170, 170))

                        local avatarW, avatarH = resp(33), resp(43)
                        local avatarX, avatarY = bgX + bgW / 2 - avatarW / 2, lineY + avatarH / 2 - resp(5)

                        exports.cr_dx:dxDrawImageAsTexture(avatarX, avatarY, avatarW, avatarH, textures.chatavatar)

                        local lineW, lineH = bgW - resp(40), resp(1)
                        local lineX, lineY = bgX + resp(20), avatarY + (avatarH * 2)

                        dxDrawRectangle(lineX, lineY, lineW, lineH, tocolor(170, 170, 170))

                        dxDrawText("Telefonszám:", lineX, lineY, lineX + lineW, lineY + lineH - resp(2), tocolor(170, 170, 170), 1, font7, "left", "bottom")

                        local textWidth = dxGetTextWidth("Telefonszám:", 1, font7)
                        local inputW, inputH = lineW - resp(85), resp(15)
                        local inputX, inputY = lineX + textWidth + resp(5), lineY - inputH

                        -- dxDrawRectangle(inputX, inputY, inputW, inputH, tocolor(124, 197, 118, 150))

                        UpdatePos("phone.newMessagePhoneNumber", {inputX, inputY, inputW, inputH})
                        UpdateAlpha("phone.newMessagePhoneNumber", tocolor(170, 170, 170))

                        local lineY = lineY + avatarH + resp(5)
                        
                        dxDrawRectangle(lineX, lineY, lineW, lineH, tocolor(170, 170, 170))
                        dxDrawText("Üzenet:", lineX, lineY, lineX + lineW, lineY + lineH - resp(2), tocolor(170, 170, 170), 1, font7, "left", "bottom")

                        local textWidth = dxGetTextWidth("Üzenet:", 1, font7)
                        local inputW, inputH = lineW - resp(55), resp(15)
                        local inputX, inputY = lineX + textWidth + resp(5), lineY - inputH

                        -- dxDrawRectangle(inputX, inputY, inputW, inputH, tocolor(124, 197, 118, 150))

                        UpdatePos("phone.newMessage", {inputX, inputY, inputW, inputH})
                        UpdateAlpha("phone.newMessage", tocolor(170, 170, 170))

                        local homeW, homeH = resp(100), resp(4)
                        local homeX, homeY = bgX + homeW - resp(5), bgY + bgH - (homeH * 3)
                        local inSlot = exports.cr_core:isInSlot(homeX, homeY, homeW, homeH)
                        if inSlot then 
                            homeButtonHover = true
                        end

                        exports.cr_dx:dxDrawImageAsTexture(homeX, homeY, homeW, homeH, textures.homebutton, 0, 0, 0, homeButtonColor)
                    elseif availablePages[selectedPage] == "viewMessages" then 
                        local statusColor = tocolor(0, 0, 0)

                        if darkMode then 
                            statusColor = tocolor(255, 255, 255, 100)
                        end

                        exports.cr_dx:dxDrawImageAsTexture(bgX, bgY, bgW, bgH, textures.whitebg, 0, 0, 0, bgColor)

                        exports.cr_dx:dxDrawImageAsTexture(statusX, statusY, statusW, statusH, textures.statusbar, 0, 0, 0, statusColor)
                        dxDrawText(formattedHourString, bgX - statusW + resp(45), statusY, bgX + bgW, bgY + bgH, statusColor, 1, font3, "center", "top")

                        local avatarW, avatarH = resp(33), resp(43)
                        local avatarX, avatarY = bgX + bgW / 2 - avatarW / 2, bgY + avatarH / 2 + resp(2)
                        local targetPlayer = phoneContacts[selectedMessage] or formatPhoneNumber(selectedMessage)

                        exports.cr_dx:dxDrawImageAsTexture(avatarX, avatarY, avatarW, avatarH, textures.chatavatar)
                        dxDrawText(targetPlayer, avatarX, avatarY, avatarX + avatarW, avatarY + avatarH + resp(18), tocolor(0, 0, 0), 1, font10, "center", "bottom")

                        -- local chatInfoW, chatInfoH = resp(254), resp(19)
                        -- local chatInfoX, chatInfoY = bgX + resp(15), avatarY + chatInfoH

                        -- exports.cr_dx:dxDrawImageAsTexture(chatInfoX, chatInfoY, chatInfoW, chatInfoH, textures.chatinfo)

                        local backInfoW, backInfoH = resp(254), resp(19)
                        local backInfoX, backInfoY = bgX + resp(10), avatarY + backInfoH + resp(5)

                        exports.cr_dx:dxDrawImageAsTexture(backInfoX, backInfoY, backInfoW, backInfoH, textures.viewBackInfoIcon)

                        backArrowIconHover = nil

                        local backArrowIconW, backArrowIconH = resp(10), resp(16)
                        local backArrowIconX, backArrowIconY = bgX + backArrowIconW, backInfoY + resp(4)
                        local inSlot = exports.cr_core:isInSlot(backArrowIconX, backArrowIconY, backArrowIconW, backArrowIconH)
                        if inSlot then 
                            backArrowIconHover = true
                        end

                        local lineW, lineH = bgW, resp(1)
                        local lineX, lineY = bgX, bgY + (avatarH * 2) + resp(3)

                        dxDrawRectangle(lineX, lineY, lineW, lineH, tocolor(170, 170, 170))
                        dxDrawText("Üzenet küldés folyamatban...", lineX, lineY, lineX + lineW, lineY + lineH + resp(18), tocolor(170, 170, 170), 1, font7, "center", "bottom")

                        local messageBarW, messageBarH = resp(268), resp(30)
                        local messageBarX, messageBarY = bgX + resp(10), lineY + messageBarH + resp(20)

                        if selectedMessage and phoneData.messages[selectedMessage] then 
                            for i = viewMessagesMinLine, viewMessagesMaxLine do 
                                local v = phoneData.messages[selectedMessage][i]

                                if v then 
                                    local sourceNumber = v.sourceNumber
                                    local text = v.text

                                    -- local textWidth = dxGetTextWidth(text, 1, font7)
                                    -- textWidth = textWidth + resp(10)
                                    -- textWidth = math.min(messageBarW, textWidth)

                                    if sourceNumber == phoneData.myCallNumber then
                                        -- dxDrawRectangle(messageBarX + messageBarW - textWidth, messageBarY, textWidth, messageBarH, tocolor(50, 154, 253))
                                        exports.cr_dx:dxDrawImageAsTexture(messageBarX, messageBarY, messageBarW, messageBarH, textures.ownmessage)
                                        -- dxDrawText(text, messageBarX, messageBarY, messageBarX + messageBarW - resp(5), messageBarY + messageBarH, tocolor(0, 0, 0), 1, font7, "right", "center", true)
                                        dxDrawText(text, messageBarX, messageBarY, messageBarX + messageBarW - resp(10), messageBarY + messageBarH, tocolor(0, 0, 0), 1, font7, "right", "center", true)
                                    else 
                                        -- dxDrawRectangle(messageBarX, messageBarY, textWidth, messageBarH, tocolor(153, 153, 153))
                                        exports.cr_dx:dxDrawImageAsTexture(messageBarX, messageBarY, messageBarW, messageBarH, textures.targetmessage)
                                        -- dxDrawText(text, messageBarX + resp(5), messageBarY, messageBarX + messageBarW, messageBarY + messageBarH, tocolor(0, 0, 0), 1, font7, "left", "center", true)
                                        dxDrawText(text, messageBarX + resp(10), messageBarY, messageBarX + messageBarW, messageBarY + messageBarH, tocolor(0, 0, 0), 1, font7, "left", "center", true)
                                    end

                                    messageBarY = messageBarY + messageBarH + resp(5)
                                end
                            end
                        end
                        
                        local chatBarW, chatBarH = resp(235), resp(35)
                        local chatBarX, chatBarY = bgX + bgW / 2 - chatBarW / 2, bgY + bgH - (chatBarH * 2) + resp(5)

                        exports.cr_dx:dxDrawImageAsTexture(chatBarX, chatBarY, chatBarW, chatBarH, textures.chatbar)

                        UpdatePos("viewMessages.chat", {chatBarX + resp(10), chatBarY, chatBarW - resp(45), chatBarH})
                        UpdateAlpha("viewMessages.chat", tocolor(153, 153, 153, 255))

                        messageSendIconHover = nil

                        local messageSendW, messageSendH = resp(26), resp(26)
                        local messageSendX, messageSendY = chatBarX + chatBarW - messageSendW - resp(7), chatBarY + chatBarH / 2 - messageSendH / 2
                        local inSlot = exports.cr_core:isInSlot(messageSendX, messageSendY, messageSendW, messageSendH)
                        if inSlot then 
                            messageSendIconHover = true
                        end

                        -- UpdatePos("phone.chat", {chatBarX + resp(10), chatBarY, chatBarW - resp(45), chatBarH})
                        -- UpdateAlpha("phone.chat", tocolor(153, 153, 153, 255))

                        local homeW, homeH = resp(100), resp(4)
                        local homeX, homeY = bgX + homeW - resp(5), bgY + bgH - (homeH * 3)
                        local inSlot = exports.cr_core:isInSlot(homeX, homeY, homeW, homeH)
                        if inSlot then 
                            homeButtonHover = true
                        end

                        exports.cr_dx:dxDrawImageAsTexture(homeX, homeY, homeW, homeH, textures.homebutton, 0, 0, 0, homeButtonColor)
                    elseif availablePages[selectedPage] == "advertisement" then 
                        local statusColor = tocolor(0, 0, 0)

                        if darkMode then 
                            statusColor = tocolor(255, 255, 255, 100)
                        end

                        exports.cr_dx:dxDrawImageAsTexture(bgX, bgY, bgW, bgH, textures.whitebg, 0, 0, 0, bgColor)

                        exports.cr_dx:dxDrawImageAsTexture(statusX, statusY, statusW, statusH, textures.statusbar, 0, 0, 0, statusColor)
                        dxDrawText(formattedHourString, bgX - statusW + resp(45), statusY, bgX + bgW, bgY + bgH, statusColor, 1, font3, "center", "top")

                        local avatarH = resp(43)
                        local avatarY = bgY + avatarH / 2 + resp(2)
                        
                        backArrowIconHover = nil

                        local backArrowW, backArrowH = resp(9), resp(15)
                        local backArrowX, backArrowY = bgX + resp(15), avatarY + backArrowH + resp(10)
                        local inSlot = exports.cr_core:isInSlot(backArrowX, backArrowY, backArrowW, backArrowH)
                        if inSlot then 
                            backArrowIconHover = true
                        end

                        exports.cr_dx:dxDrawImageAsTexture(backArrowX, backArrowY, backArrowW, backArrowH, textures.backArrowIcon)
                        dxDrawText("Hírdetés feladás", backArrowX, backArrowY, bgX + bgW, backArrowY + backArrowH + resp(2), tocolor(0, 0, 0), 1, font2, "center", "bottom")

                        local lineW, lineH = bgW, resp(1)
                        local lineX, lineY = bgX, backArrowY + backArrowH + resp(20)

                        dxDrawRectangle(lineX, lineY, lineW, lineH, tocolor(170, 170, 170))

                        dxDrawText("Hírdetés feladása folyamatban...", lineX, lineY, lineX + lineW, lineY + lineH + resp(35), tocolor(170, 170, 170), 1, font7, "center", "bottom")

                        local logoW, logoH = resp(280), resp(166)
                        local logoX, logoY = bgX + bgW / 2 - logoW / 2, bgY + bgH / 2 - logoH / 2

                        exports.cr_dx:dxDrawImageAsTexture(logoX, logoY, logoW, logoH, textures.adLogo)

                        local textBoxW, textBoxH = resp(237), resp(118)
                        local textBoxX, textBoxY = bgX + bgW / 2 - textBoxW / 2, bgY + bgH - textBoxH - resp(30)

                        exports.cr_dx:dxDrawImageAsTexture(textBoxX, textBoxY, textBoxW, textBoxH, textures.textbox)

                        adIconHover = nil

                        local adIconW, adIconH = resp(26), resp(26)
                        local adIconX, adIconY = textBoxX + textBoxW - adIconW - resp(8), textBoxY + textBoxH - adIconH - resp(6)
                        local inSlot = exports.cr_core:isInSlot(adIconX, adIconY, adIconW, adIconH)
                        if inSlot then 
                            adIconHover = true
                        end

                        -- dxDrawText("Szöveg írása...", textBoxX + resp(5), textBoxY + resp(3), textBoxX + textBoxW, textBoxY + textBoxH, tocolor(170, 170, 170), 1, font4, "left", "top")

                        UpdatePos("phone.advertisementText", {textBoxX + resp(5), textBoxY + resp(3), textBoxW - resp(10), textBoxH})
                        UpdateAlpha("phone.advertisementText", tocolor(170, 170, 170))

                        checkBoxHover = nil

                        local checkBoxW, checkBoxH = resp(16), resp(16)
                        local checkBoxX, checkBoxY = textBoxX, textBoxY - checkBoxH - resp(5)
                        local inSlot = exports.cr_core:isInSlot(checkBoxX, checkBoxY, checkBoxW, checkBoxH)
                        if inSlot then 
                            checkBoxHover = true
                        end

                        exports.cr_dx:dxDrawImageAsTexture(checkBoxX, checkBoxY, checkBoxW, checkBoxH, textures.checkbox_off)

                        if phoneData.showMyNumber then 
                            exports.cr_dx:dxDrawImageAsTexture(checkBoxX, checkBoxY, checkBoxW, checkBoxH, textures.checkbox_on)
                        end

                        dxDrawText("Telefonszámom megjelenítése", checkBoxX + checkBoxW + resp(5), checkBoxY, checkBoxX + checkBoxW, checkBoxY + checkBoxH, tocolor(170, 170, 170), 1, font4, "left", "center")

                        local homeW, homeH = resp(100), resp(4)
                        local homeX, homeY = bgX + homeW - resp(5), bgY + bgH - (homeH * 3)
                        local inSlot = exports.cr_core:isInSlot(homeX, homeY, homeW, homeH)
                        if inSlot then 
                            homeButtonHover = true
                        end

                        exports.cr_dx:dxDrawImageAsTexture(homeX, homeY, homeW, homeH, textures.homebutton, 0, 0, 0, homeButtonColor)
                    elseif availablePages[selectedPage] == "contacts" then 
                        local statusColor = tocolor(0, 0, 0)

                        if darkMode then 
                            statusColor = tocolor(255, 255, 255, 100)
                        end

                        exports.cr_dx:dxDrawImageAsTexture(bgX, bgY, bgW, bgH, textures.whitebg, 0, 0, 0, bgColor)

                        exports.cr_dx:dxDrawImageAsTexture(statusX, statusY, statusW, statusH, textures.statusbar, 0, 0, 0, statusColor)
                        dxDrawText(formattedHourString, bgX - statusW + resp(45), statusY, bgX + bgW, bgY + bgH, statusColor, 1, font3, "center", "top")

                        local avatarH = resp(43)
                        local avatarY = bgY + avatarH / 2 + resp(2)
                        
                        local backInfoW, backInfoH = resp(258), resp(16)
                        local backInfoX, backInfoY = bgX + resp(15), avatarY + backInfoH

                        backArrowIconHover = nil

                        local backArrowHoverW, backArrowHoverH = resp(10), resp(19)
                        local backArrowHoverX, backArrowHoverY = backInfoX, backInfoY
                        local inSlot = exports.cr_core:isInSlot(backArrowHoverX, backArrowHoverY, backArrowHoverW, backArrowHoverH)
                        if inSlot then 
                            backArrowIconHover = true
                        end

                        addIconHover = nil

                        local addIconHoverW, addIconHoverH = resp(16), resp(17)
                        local addIconHoverX, addIconHoverY = backInfoX + backInfoW - addIconHoverW, backInfoY
                        local inSlot = exports.cr_core:isInSlot(addIconHoverX, addIconHoverY, addIconHoverW, addIconHoverH)
                        if inSlot then 
                            addIconHover = true
                        end

                        exports.cr_dx:dxDrawImageAsTexture(backInfoX, backInfoY, backInfoW, backInfoH, textures.backinfo)
                        dxDrawText("Névjegyzék", backInfoX, backInfoY + resp(2), backInfoX + backInfoW, backInfoY + backInfoH, tocolor(0, 0, 0), 1, font2, "center", "center")

                        local searchW, searchH = resp(179), resp(26)
                        local searchX, searchY = bgX + bgW / 2 - searchW / 2, backInfoY + searchH

                        exports.cr_dx:dxDrawImageAsTexture(searchX, searchY, searchW, searchH, textures.search)

                        UpdatePos("contacts.search", {searchX + resp(10), searchY, searchW - resp(45), searchH})
                        UpdateAlpha("contacts.search", tocolor(153, 153, 153, 255))

                        local lineW, lineH = bgW, resp(1)
                        local lineX, lineY = bgX, searchY + searchH + resp(10)

                        dxDrawRectangle(lineX, lineY, lineW, lineH, tocolor(170, 170, 170))

                        local avatarW, avatarH = resp(32), resp(32)
                        local avatarX, avatarY = lineX + resp(10), lineY + resp(5)

                        local iconW, iconH = resp(40), resp(40)
                        local iconStartX, iconStartY = bgX + resp(10), bgY + bgH - iconH - resp(35)

                        hoverCallIcon = nil

                        for i = 1, #callIcons do 
                            local v = callIcons[i]

                            if textures.callIcons[i] then 
                                local color = iconAndTextColor
                                local inSlot = exports.cr_core:isInSlot(iconStartX, iconStartY, iconW, iconH)
                                if inSlot then 
                                    hoverCallIcon = i
                                end

                                if i == 3 then 
                                    color = tocolor(0, 122, 255)
                                end

                                exports.cr_dx:dxDrawImageAsTexture(iconStartX, iconStartY, iconW, iconH, textures.callIcons[i], 0, 0, 0, color)
                                dxDrawText(v.name, iconStartX, iconStartY, iconStartX + iconW, iconStartY + iconH + resp(5), color, 1, font5, "center", "bottom")
                            end

                            iconStartX = iconStartX + (iconW + resp(17))
                        end

                        iconActionHover = nil

                        local array = phoneData.contacts or {}
                        local percent = #array

                        if phoneContactsSearchCache then 
                            array = phoneContactsSearchCache
                            percent = #array
                        end

                        if contactsMaxLine > percent then 
                            contactsMinLine = 1
                            _contactsMaxLine = 10
                            contactsMaxLine = _contactsMaxLine
                        end

                        for i = contactsMinLine, contactsMaxLine do 
                            local v = array[i]

                            local k = i
                            if phoneContactsSearchCache then 
                                v = phoneContactsSearchCache[k]

                                if v then 
                                    k = v.id
                                end 
                            end

                            if v and v.name and v.phoneNumber then 
                                local name = v.name
                                local phoneNumber = v.phoneNumber

                                exports.cr_dx:dxDrawImageAsTexture(avatarX, avatarY, avatarW, avatarH, textures.messagesavatar)

                                if not contactEditing.isEditing then 
                                    dxDrawText(name, avatarX + avatarW + resp(5), avatarY - resp(3), avatarX + avatarW, avatarY + avatarH, tocolor(0, 0, 0), 1, font2, "left", "top")
                                else
                                    if contactEditing.selectedNumber ~= phoneNumber then 
                                        dxDrawText(name, avatarX + avatarW + resp(5), avatarY - resp(3), avatarX + avatarW, avatarY + avatarH, tocolor(0, 0, 0), 1, font2, "left", "top")
                                    end

                                    if contactEditing.selectedKey == k then 
                                        UpdatePos("phone.editContact", {avatarX + avatarW + resp(5), avatarY - resp(3), avatarW, avatarH})
                                        UpdateAlpha("phone.editContact", tocolor(0, 0, 0))
                                    end

                                    if contactEditing.selectedKey < contactsMinLine then 
                                        if GetEdit("phone.editContact") then 
                                            RemoveBar("phone.editContact")

                                            contactEditing = {
                                                isEditing = false,
                                                selectedName = false,
                                                selectedNumber = false,
                                                selectedKey = false
                                            }
                                        end
                                    end
                                end

                                dxDrawText(formatPhoneNumber(phoneNumber), avatarX + avatarW + resp(5), avatarY - resp(5), avatarX + avatarW, avatarY + avatarH, tocolor(0, 0, 0), 1, font7, "left", "bottom")

                                local deleteIconW, deleteIconH = resp(12), resp(14)
                                local deleteIconX, deleteIconY = avatarX + lineW - resp(35), avatarY + resp(10)
                                local inSlot = exports.cr_core:isInSlot(deleteIconX, deleteIconY, deleteIconW, deleteIconH)
                                if inSlot then 
                                    iconActionHover = "deleteFromContacts:" .. i
                                end

                                exports.cr_dx:dxDrawImageAsTexture(deleteIconX, deleteIconY, deleteIconW, deleteIconH, textures.deleteIcon)

                                local editContactIconW, editContactIconH = resp(14), resp(14)
                                local editContactIconX, editContactIconY = deleteIconX - editContactIconW - resp(10), deleteIconY
                                local inSlot = exports.cr_core:isInSlot(editContactIconX, editContactIconY, editContactIconW, editContactIconH)
                                if inSlot then 
                                    iconActionHover = "editContact:" .. i
                                end

                                exports.cr_dx:dxDrawImageAsTexture(editContactIconX, editContactIconY, editContactIconW, editContactIconH, textures.editContactIcon)

                                local messagesIconW, messagesIconH = resp(16), resp(14)
                                local messagesIconX, messagesIconY = editContactIconX - messagesIconW - resp(10), editContactIconY
                                local inSlot = exports.cr_core:isInSlot(messagesIconX, messagesIconY, messagesIconW, messagesIconH)
                                if inSlot then 
                                    iconActionHover = "selectMessage:" .. i
                                end

                                exports.cr_dx:dxDrawImageAsTexture(messagesIconX, messagesIconY, messagesIconW, messagesIconH, textures.messagesIcon)

                                local callIconW, callIconH = resp(13), resp(13)
                                local callIconX, callIconY = messagesIconX - callIconW - resp(10), messagesIconY
                                local inSlot = exports.cr_core:isInSlot(callIconX, callIconY, callIconW, callIconH)
                                if inSlot then 
                                    iconActionHover = "callFromContacts:" .. i
                                end

                                exports.cr_dx:dxDrawImageAsTexture(callIconX, callIconY, callIconW, callIconH, textures.callIcon)

                                local lineW, lineH = lineW - resp(20), resp(1)
                                local lineX, lineY = bgX + resp(10), avatarY + avatarH + resp(5)

                                dxDrawRectangle(lineX, lineY, lineW, lineH, tocolor(170, 170, 170))

                                avatarY = avatarY + avatarH + resp(10)
                            end
                        end

                        local length = #array

                        if length <= 0 then 
                            dxDrawText("Nincs egyetlen névjegyed sem", lineX, lineY, lineX + lineW, lineY + lineH + resp(25), tocolor(0, 0, 0), 1, font2, "center", "bottom")
                        end

                        local homeW, homeH = resp(100), resp(4)
                        local homeX, homeY = bgX + homeW - resp(5), bgY + bgH - (homeH * 3)
                        local inSlot = exports.cr_core:isInSlot(homeX, homeY, homeW, homeH)
                        if inSlot then 
                            homeButtonHover = true
                        end

                        exports.cr_dx:dxDrawImageAsTexture(homeX, homeY, homeW, homeH, textures.homebutton, 0, 0, 0, homeButtonColor)
                    elseif availablePages[selectedPage] == "addNewContact" then 
                        local statusColor = tocolor(0, 0, 0)

                        if darkMode then 
                            statusColor = tocolor(255, 255, 255, 100)
                        end

                        exports.cr_dx:dxDrawImageAsTexture(bgX, bgY, bgW, bgH, textures.whitebg, 0, 0, 0, bgColor)

                        exports.cr_dx:dxDrawImageAsTexture(statusX, statusY, statusW, statusH, textures.statusbar, 0, 0, 0, statusColor)
                        dxDrawText(formattedHourString, bgX - statusW + resp(45), statusY, bgX + bgW, bgY + bgH, statusColor, 1, font3, "center", "top")

                        local avatarH = resp(43)
                        local avatarY = bgY + avatarH / 2 + resp(2)
                        
                        local backInfoW, backInfoH = resp(258), resp(16)
                        local backInfoX, backInfoY = bgX + resp(15), avatarY + backInfoH

                        backArrowIconHover = nil

                        local backArrowHoverW, backArrowHoverH = resp(10), resp(19)
                        local backArrowHoverX, backArrowHoverY = backInfoX, backInfoY
                        local inSlot = exports.cr_core:isInSlot(backArrowHoverX, backArrowHoverY, backArrowHoverW, backArrowHoverH)
                        if inSlot then 
                            backArrowIconHover = true
                        end

                        addIconHover = nil

                        local addIconHoverW, addIconHoverH = resp(16), resp(17)
                        local addIconHoverX, addIconHoverY = backInfoX + backInfoW - addIconHoverW, backInfoY
                        local inSlot = exports.cr_core:isInSlot(addIconHoverX, addIconHoverY, addIconHoverW, addIconHoverH)
                        if inSlot then 
                            addIconHover = true
                        end

                        exports.cr_dx:dxDrawImageAsTexture(backInfoX, backInfoY, backInfoW, backInfoH, textures.backinfo)
                        dxDrawText("Névjegy hozzáadása", backInfoX, backInfoY, backInfoX + backInfoW, backInfoY + backInfoH + resp(2), tocolor(0, 0, 0), 1, font2, "center", "bottom")

                        local lineW, lineH = bgW, resp(1)
                        local lineX, lineY = bgX, backInfoY + backInfoH + resp(40)

                        dxDrawRectangle(lineX, lineY, lineW, lineH, tocolor(170, 170, 170))

                        local avatarW, avatarH = resp(33), resp(43)
                        local avatarX, avatarY = bgX + bgW / 2 - avatarW / 2, lineY + avatarH / 2 - resp(5)

                        exports.cr_dx:dxDrawImageAsTexture(avatarX, avatarY, avatarW, avatarH, textures.chatavatar)

                        local lineW, lineH = bgW - resp(40), resp(1)
                        local lineX, lineY = bgX + resp(20), avatarY + (avatarH * 2)

                        dxDrawRectangle(lineX, lineY, lineW, lineH, tocolor(170, 170, 170))

                        dxDrawText("Név:", lineX, lineY, lineX + lineW, lineY + lineH - resp(2), tocolor(170, 170, 170), 1, font7, "left", "bottom")

                        local textWidth = dxGetTextWidth("Név:", 1, font7)
                        local inputW, inputH = lineW - resp(85), resp(15)
                        local inputX, inputY = lineX + textWidth + resp(5), lineY - inputH

                        -- dxDrawRectangle(inputX, inputY, inputW, inputH, tocolor(124, 197, 118, 150))

                        UpdatePos("phone.newContactName", {inputX, inputY, inputW, inputH})
                        UpdateAlpha("phone.newContactName", tocolor(170, 170, 170))

                        local lineY = lineY + avatarH + resp(5)
                        
                        dxDrawRectangle(lineX, lineY, lineW, lineH, tocolor(170, 170, 170))
                        dxDrawText("Telefonszám:", lineX, lineY, lineX + lineW, lineY + lineH - resp(2), tocolor(170, 170, 170), 1, font7, "left", "bottom")

                        local textWidth = dxGetTextWidth("Telefonszám:", 1, font7)
                        local inputW, inputH = lineW - resp(55), resp(15)
                        local inputX, inputY = lineX + textWidth + resp(5), lineY - inputH

                        -- dxDrawRectangle(inputX, inputY, inputW, inputH, tocolor(124, 197, 118, 150))

                        UpdatePos("phone.newContactPhoneNumber", {inputX, inputY, inputW, inputH})
                        UpdateAlpha("phone.newContactPhoneNumber", tocolor(170, 170, 170))

                        local homeW, homeH = resp(100), resp(4)
                        local homeX, homeY = bgX + homeW - resp(5), bgY + bgH - (homeH * 3)
                        local inSlot = exports.cr_core:isInSlot(homeX, homeY, homeW, homeH)
                        if inSlot then 
                            homeButtonHover = true
                        end

                        exports.cr_dx:dxDrawImageAsTexture(homeX, homeY, homeW, homeH, textures.homebutton, 0, 0, 0, homeButtonColor)
                    elseif availablePages[selectedPage] == "wallet" then 
                        local statusColor = tocolor(0, 0, 0)

                        if darkMode then 
                            statusColor = tocolor(255, 255, 255, 100)
                        end

                        exports.cr_dx:dxDrawImageAsTexture(bgX, bgY, bgW, bgH, textures.whitebg, 0, 0, 0, bgColor)

                        exports.cr_dx:dxDrawImageAsTexture(statusX, statusY, statusW, statusH, textures.statusbar, 0, 0, 0, statusColor)
                        dxDrawText(formattedHourString, bgX - statusW + resp(45), statusY, bgX + bgW, bgY + bgH, statusColor, 1, font3, "center", "top")

                        local avatarH = resp(43)
                        local avatarY = bgY + avatarH / 2 + resp(2)
                        
                        backArrowIconHover = nil

                        local backArrowW, backArrowH = resp(9), resp(15)
                        local backArrowX, backArrowY = bgX + resp(15), avatarY + backArrowH + resp(10)
                        local inSlot = exports.cr_core:isInSlot(backArrowX, backArrowY, backArrowW, backArrowH)
                        if inSlot then 
                            backArrowIconHover = true
                        end

                        exports.cr_dx:dxDrawImageAsTexture(backArrowX, backArrowY, backArrowW, backArrowH, textures.backArrowIcon)
                        dxDrawText("Egyenlegem", backArrowX, backArrowY, bgX + bgW, backArrowY + backArrowH + resp(2), tocolor(0, 0, 0), 1, font2, "center", "bottom")

                        local lineW, lineH = bgW, resp(1)
                        local lineX, lineY = bgX, backArrowY + backArrowH + resp(40)

                        dxDrawRectangle(lineX, lineY, lineW, lineH, tocolor(170, 170, 170))

                        local avatarW, avatarH = resp(33), resp(43)
                        local avatarX, avatarY = bgX + bgW / 2 - avatarW / 2, lineY + avatarH / 2 - resp(5)

                        exports.cr_dx:dxDrawImageAsTexture(avatarX, avatarY, avatarW, avatarH, textures.chatavatar)

                        local lineW, lineH = bgW - resp(40), resp(1)
                        local lineX, lineY = bgX + resp(20), avatarY + (avatarH * 2)

                        dxDrawRectangle(lineX, lineY, lineW, lineH, tocolor(170, 170, 170))

                        dxDrawText("Szolgáltató neve:", lineX, lineY, lineX + lineW, lineY + lineH - resp(2), tocolor(170, 170, 170), 1, font7, "left", "bottom")

                        local textWidth = dxGetTextWidth("Szolgáltató neve:", 1, font7)
                        local service = phoneData.service == "" and "Nincs szolgáltató" or phoneData.service

                        dxDrawText(service, lineX + textWidth + resp(5), lineY, lineX + lineW, lineY + lineH - resp(2), tocolor(redR, redG, redB), 1, font7, "left", "bottom")

                        local lineY = lineY + avatarH
                        
                        dxDrawRectangle(lineX, lineY, lineW, lineH, tocolor(170, 170, 170))
                        dxDrawText("Telefonszámom:", lineX, lineY, lineX + lineW, lineY + lineH - resp(2), tocolor(170, 170, 170), 1, font7, "left", "bottom")

                        local textWidth = dxGetTextWidth("Telefonszámom:", 1, font7)
                        local formattedPhoneNumber = phoneData.myCallNumber <= 0 and "Ismeretlen" or formatPhoneNumber(phoneData.myCallNumber)

                        dxDrawText(formattedPhoneNumber, lineX + textWidth + resp(5), lineY, lineX + lineW, lineY + lineH - resp(2), tocolor(redR, redG, redB), 1, font7, "left", "bottom")

                        local lineY = lineY + avatarH
                        
                        dxDrawRectangle(lineX, lineY, lineW, lineH, tocolor(170, 170, 170))
                        dxDrawText("Egyenlegem:", lineX, lineY, lineX + lineW, lineY + lineH - resp(2), tocolor(170, 170, 170), 1, font7, "left", "bottom")

                        local textWidth = dxGetTextWidth("Egyenlegem:", 1, font7)

                        dxDrawText("$" .. phoneData.wallet, lineX + textWidth + resp(5), lineY, lineX + lineW, lineY + lineH - resp(2), tocolor(redR, redG, redB), 1, font7, "left", "bottom")

                        local homeW, homeH = resp(100), resp(4)
                        local homeX, homeY = bgX + homeW - resp(5), bgY + bgH - (homeH * 3)
                        local inSlot = exports.cr_core:isInSlot(homeX, homeY, homeW, homeH)
                        if inSlot then 
                            homeButtonHover = true
                        end

                        exports.cr_dx:dxDrawImageAsTexture(homeX, homeY, homeW, homeH, textures.homebutton, 0, 0, 0, homeButtonColor)
                    elseif availablePages[selectedPage] == "settings" then 
                        local statusColor = tocolor(0, 0, 0)

                        if darkMode then 
                            statusColor = tocolor(255, 255, 255, 100)
                        end

                        exports.cr_dx:dxDrawImageAsTexture(bgX, bgY, bgW, bgH, textures.whitebg, 0, 0, 0, bgColor)

                        exports.cr_dx:dxDrawImageAsTexture(statusX, statusY, statusW, statusH, textures.statusbar, 0, 0, 0, statusColor)
                        dxDrawText(formattedHourString, bgX - statusW + resp(45), statusY, bgX + bgW, bgY + bgH, statusColor, 1, font3, "center", "top")

                        local avatarH = resp(43)
                        local avatarY = bgY + avatarH / 2 + resp(2)
                        
                        backArrowIconHover = nil

                        local backArrowW, backArrowH = resp(9), resp(15)
                        local backArrowX, backArrowY = bgX + resp(15), avatarY + backArrowH + resp(10)
                        local inSlot = exports.cr_core:isInSlot(backArrowX, backArrowY, backArrowW, backArrowH)
                        if inSlot then 
                            backArrowIconHover = true
                        end

                        exports.cr_dx:dxDrawImageAsTexture(backArrowX, backArrowY, backArrowW, backArrowH, textures.backArrowIcon)
                        dxDrawText("Beállítások", backArrowX, backArrowY, bgX + bgW, backArrowY + backArrowH + resp(2), tocolor(0, 0, 0), 1, font2, "center", "bottom")

                        local searchW, searchH = resp(179), resp(26)
                        local searchX, searchY = bgX + bgW / 2 - searchW / 2, backArrowY + searchH

                        exports.cr_dx:dxDrawImageAsTexture(searchX, searchY, searchW, searchH, textures.search)

                        UpdatePos("settings.search", {searchX + resp(10), searchY, searchW - resp(45), searchH})
                        UpdateAlpha("settings.search", tocolor(153, 153, 153, 255))

                        local lineW, lineH = bgW, resp(1)
                        local lineX, lineY = bgX, searchY + searchH + resp(10)

                        dxDrawRectangle(lineX, lineY, lineW, lineH, tocolor(170, 170, 170))

                        local settingX, settingY = lineX + resp(10), lineY + resp(10)
                        local iconW, iconH = resp(29), resp(29)
                        
                        volumeControlHover = nil
                        toggleIconHover = nil
                        settingsSelectorHover = nil

                        local array = availableSettings
                        local percent = #array

                        if settingsSearchCache then 
                            array = settingsSearchCache
                            percent = #array
                        end

                        -- if messagesMaxLine > percent then 
                        --     messagesMinLine = 1
                        --     _messagesMaxLine = 11
                        --     messagesMaxLine = _messagesMaxLine
                        -- end

                        for i = settingsMinLine, settingsMaxLine do 
                            local v = array[i]

                            if v then 
                                local name = v.name
                                local visibleName = v.visibleName
                                local typ = v.typ
                                local iconId = v.iconId

                                exports.cr_dx:dxDrawImageAsTexture(settingX, settingY, iconW, iconH, textures.settingsIcons[iconId])
                                dxDrawText(visibleName, settingX + iconW + resp(5), settingY, settingX + iconW, settingY + iconH, tocolor(0, 0, 0), 1, font11, "left", "center")

                                local lineW, lineH = lineW - resp(20), resp(1)
                                local lineX, lineY = bgX + resp(10), settingY + iconH + resp(5)

                                dxDrawRectangle(lineX, lineY, lineW, lineH, tocolor(170, 170, 170))

                                if typ == "slider" then 
                                    local sliderW, sliderH = resp(60), resp(1)
                                    local sliderX, sliderY = lineX + lineW - sliderW - resp(5), lineY - iconH / 2 - resp(5)

                                    dxDrawRectangle(sliderX, sliderY, sliderW, sliderH, tocolor(100, 100, 100))

                                    local volumeMultiplier = phoneData.ringtoneVolume or 0
                                    local volumeCircleW, volumeCircleH = resp(10), resp(10)
                                    local volumeCircleX, volumeCircleY = sliderX + (volumeMultiplier * 50), sliderY - volumeCircleH / 2
                                    local inSlot = exports.cr_core:isInSlot(volumeCircleX, volumeCircleY, volumeCircleW, volumeCircleH)
                                    if inSlot then 
                                        volumeControlHover = true
                                    end

                                    exports.cr_dx:dxDrawImageAsTexture(volumeCircleX, volumeCircleY, volumeCircleW, volumeCircleH, textures.volumecircle)

                                    if volumeControlClick then 
                                        if isCursorShowing() and getKeyState("mouse1") then 
                                            local cursorX, cursorY = exports.cr_core:getCursorPosition()

                                            local multiplier = ((cursorX - resp(3)) - sliderX) / sliderW
                                            multiplier = math.max(0, math.min(1, multiplier))

                                            if volumeMultiplier ~= multiplier then 
                                                phoneData.ringtoneVolume = multiplier
                                            end
                                        end
                                    end
                                elseif typ == "selector" then 
                                    local arrowIconW, arrowIconH = resp(8), resp(13)
                                    local arrowIconX, arrowIconY = lineX + lineW - arrowIconW - resp(5), lineY - iconH / 2 - arrowIconH / 2 - resp(5)
                                    local inSlot = exports.cr_core:isInSlot(arrowIconX, arrowIconY, arrowIconW, arrowIconH)
                                    if inSlot then 
                                        settingsSelectorHover = name .. ":" .. i
                                    end

                                    local value = visibleName == "Háttérkép csere" and phoneData.wallpaper or visibleName == "Zárolási kép csere" and phoneData.lockscreen or visibleName == "Csengőhang" and phoneData.ringtone or 0

                                    exports.cr_dx:dxDrawImageAsTexture(arrowIconX, arrowIconY, arrowIconW, arrowIconH, textures.arrowIcon)
                                    dxDrawText(value, arrowIconX, arrowIconY, arrowIconX + arrowIconW - resp(15), arrowIconY + arrowIconH, tocolor(170, 170, 170), 1, font4, "right", "center")
                                elseif typ == "toggle" then 
                                    local toggleIconW, toggleIconH = resp(48), resp(41)
                                    local toggleIconX, toggleIconY = lineX + lineW - toggleIconW - resp(5), lineY - iconH / 2 - toggleIconH / 2 - resp(4)
                                    local currentImage = phoneData.normalads and textures.toggle_on or textures.toggle_off

                                    exports.cr_dx:dxDrawImageAsTexture(toggleIconX, toggleIconY, toggleIconW, toggleIconH, currentImage)

                                    local toggleIconHoverW, toggleIconHoverH = resp(40), resp(25)
                                    local toggleIconHoverX, toggleIconHoverY = toggleIconX + resp(8), toggleIconY + resp(5)
                                    local inSlot = exports.cr_core:isInSlot(toggleIconHoverX, toggleIconHoverY, toggleIconHoverW, toggleIconHoverH)
                                    if inSlot then 
                                        toggleIconHover = true
                                    end
                                end

                                settingY = settingY + iconH + resp(10)
                            end
                        end

                        local homeW, homeH = resp(100), resp(4)
                        local homeX, homeY = bgX + homeW - resp(5), bgY + bgH - (homeH * 3)
                        local inSlot = exports.cr_core:isInSlot(homeX, homeY, homeW, homeH)
                        if inSlot then 
                            homeButtonHover = true
                        end

                        exports.cr_dx:dxDrawImageAsTexture(homeX, homeY, homeW, homeH, textures.homebutton, 0, 0, 0, homeButtonColor)
                    elseif availablePages[selectedPage] == "ringtoneSelector" then 
                        local statusColor = tocolor(0, 0, 0)

                        if darkMode then 
                            statusColor = tocolor(255, 255, 255, 100)
                        end

                        exports.cr_dx:dxDrawImageAsTexture(bgX, bgY, bgW, bgH, textures.whitebg, 0, 0, 0, bgColor)

                        exports.cr_dx:dxDrawImageAsTexture(statusX, statusY, statusW, statusH, textures.statusbar, 0, 0, 0, statusColor)
                        dxDrawText(formattedHourString, bgX - statusW + resp(45), statusY, bgX + bgW, bgY + bgH, statusColor, 1, font3, "center", "top")

                        local avatarH = resp(43)
                        local avatarY = bgY + avatarH / 2 + resp(2)
                        
                        backArrowIconHover = nil

                        local backArrowW, backArrowH = resp(9), resp(15)
                        local backArrowX, backArrowY = bgX + resp(15), avatarY + backArrowH + resp(10)
                        local inSlot = exports.cr_core:isInSlot(backArrowX, backArrowY, backArrowW, backArrowH)
                        if inSlot then 
                            backArrowIconHover = true
                        end

                        exports.cr_dx:dxDrawImageAsTexture(backArrowX, backArrowY, backArrowW, backArrowH, textures.backArrowIcon)
                        dxDrawText("Beállítások", backArrowX, backArrowY, bgX + bgW, backArrowY + backArrowH + resp(2), tocolor(0, 0, 0), 1, font2, "center", "bottom")

                        local searchW, searchH = resp(179), resp(26)
                        local searchX, searchY = bgX + bgW / 2 - searchW / 2, backArrowY + searchH

                        exports.cr_dx:dxDrawImageAsTexture(searchX, searchY, searchW, searchH, textures.search)

                        UpdatePos("ringtoneSelector.search", {searchX + resp(10), searchY, searchW - resp(45), searchH})
                        UpdateAlpha("ringtoneSelector.search", tocolor(153, 153, 153, 255))

                        local lineW, lineH = bgW, resp(1)
                        local lineX, lineY = bgX, searchY + searchH + resp(10)

                        dxDrawRectangle(lineX, lineY, lineW, lineH, tocolor(170, 170, 170))

                        local ringToneIconW, ringToneIconH = resp(24), resp(24)
                        local ringToneIconX, ringToneIconY = lineX + lineW - ringToneIconW - resp(20), lineY + resp(10)

                        local array = availableRingtones
                        local percent = #array

                        if ringTonesSearchCache then 
                            array = ringTonesSearchCache
                            percent = #array
                        end

                        ringtoneActionHover = nil

                        for i = ringTonesMinLine, ringTonesMaxLine do 
                            local v = array[i]

                            if v then 
                                local ringToneId = v.ringToneId

                                local currentImage = phoneData.ringtone == ringToneId and not switchedFromAlarm and textures.circleCheckIcon or textures.circleIcon
                                local inSlot = exports.cr_core:isInSlot(ringToneIconX, ringToneIconY, ringToneIconW, ringToneIconH)
                                if inSlot then 
                                    ringtoneActionHover = "selectRingtone:" .. i
                                end

                                exports.cr_dx:dxDrawImageAsTexture(ringToneIconX, ringToneIconY, ringToneIconW, ringToneIconH, currentImage)
                                dxDrawText(v.name, lineX + resp(15), ringToneIconY, lineX + lineW, ringToneIconY + ringToneIconH, tocolor(0, 0, 0), 1, font11, "left", "center")

                                local statusIconW, statusIconH = resp(24), resp(24)
                                local statusIconX, statusIconY = ringToneIconX - statusIconW - resp(5), ringToneIconY
                                local inSlot = exports.cr_core:isInSlot(statusIconX, statusIconY, statusIconW, statusIconH)
                                if inSlot then 
                                    ringtoneActionHover = "viewRingtone:" .. i
                                end

                                local currentIcon = currentRingtone == i and textures.pauseButtonIcon or textures.playButtonIcon
                                exports.cr_dx:dxDrawImageAsTexture(statusIconX, statusIconY, statusIconW, statusIconH, currentIcon)

                                local lineW, lineH = lineW - resp(20), resp(1)
                                local lineX, lineY = bgX + resp(10), ringToneIconY + ringToneIconH + resp(10)

                                dxDrawRectangle(lineX, lineY, lineW, lineH, tocolor(170, 170, 170))

                                ringToneIconY = ringToneIconY + ringToneIconH + resp(20)
                            end
                        end

                        local homeW, homeH = resp(100), resp(4)
                        local homeX, homeY = bgX + homeW - resp(5), bgY + bgH - (homeH * 3)
                        local inSlot = exports.cr_core:isInSlot(homeX, homeY, homeW, homeH)
                        if inSlot then 
                            homeButtonHover = true
                        end

                        exports.cr_dx:dxDrawImageAsTexture(homeX, homeY, homeW, homeH, textures.homebutton, 0, 0, 0, homeButtonColor)
                    elseif availablePages[selectedPage] == "wallpaperSelector" then 
                        local currentWallpaper = selectedWallpaper and selectedWallpaper or (phoneData.wallpaper or 1)

                        exports.cr_dx:dxDrawImageAsTexture(bgX, bgY, bgW, bgH, ":cr_phone/files/images/wallpapers/" .. currentWallpaper .. ".png")

                        leftArrowIconHover = nil

                        local leftIconColor = tocolor(170, 170, 170)
                        local bigArrowIconW, bigArrowIconH = resp(17), resp(32)
                        local bigArrowLeftIconX, bigArrowLeftIconY = bgX + resp(15), bgY + bgH / 2 - bigArrowIconH / 2
                        local inSlot = exports.cr_core:isInSlot(bigArrowLeftIconX, bigArrowLeftIconY, bigArrowIconW, bigArrowIconH)
                        if inSlot then 
                            leftArrowIconHover = true
                            leftIconColor = tocolor(redR, redG, redB)
                        end

                        exports.cr_dx:dxDrawImageAsTexture(bigArrowLeftIconX, bigArrowLeftIconY, bigArrowIconW, bigArrowIconH, textures.bigArrowIcon, 180, 0, 0, leftIconColor)
                        
                        rightArrowIconHover = nil

                        local rightIconColor = tocolor(170, 170, 170)
                        local bigArrowRightIconX, bigArrowRightIconY = bgX + bgW - resp(32), bigArrowLeftIconY
                        local inSlot = exports.cr_core:isInSlot(bigArrowRightIconX, bigArrowRightIconY, bigArrowIconW, bigArrowIconH)
                        if inSlot then 
                            rightArrowIconHover = true
                            rightIconColor = tocolor(redR, redG, redB)
                        end

                        exports.cr_dx:dxDrawImageAsTexture(bigArrowRightIconX, bigArrowRightIconY, bigArrowIconW, bigArrowIconH, textures.bigArrowIcon, 0, 0, 0, rightIconColor)
                        
                        saveButtonHover = nil

                        local saveButtonW, saveButtonH = resp(148), resp(27)
                        local saveButtonX, saveButtonY = bgX + bgW / 2 - saveButtonW / 2, bgY + bgH - (saveButtonH * 2) - resp(5)
                        local inSlot = exports.cr_core:isInSlot(saveButtonX, saveButtonY, saveButtonW, saveButtonH)
                        if inSlot then 
                            saveButtonHover = true
                        end

                        dxDrawRectangle(saveButtonX, saveButtonY, saveButtonW, saveButtonH, tocolor(redR, redG, redB))
                        dxDrawText("Mentés", saveButtonX, saveButtonY, saveButtonX + saveButtonW, saveButtonY + saveButtonH, tocolor(0, 0, 0), 1, font4, "center", "center")

                        local homeW, homeH = resp(100), resp(4)
                        local homeX, homeY = bgX + homeW - resp(5), bgY + bgH - (homeH * 3)
                        local inSlot = exports.cr_core:isInSlot(homeX, homeY, homeW, homeH)
                        if inSlot then 
                            homeButtonHover = true
                        end

                        exports.cr_dx:dxDrawImageAsTexture(homeX, homeY, homeW, homeH, textures.homebutton, 0, 0, 0, homeButtonColor)
                    elseif availablePages[selectedPage] == "lockScreenSelector" then 
                        local currentLockscreen = selectedLockscreen and selectedLockscreen or (phoneData.lockscreen or 1)

                        exports.cr_dx:dxDrawImageAsTexture(bgX, bgY, bgW, bgH, ":cr_phone/files/images/wallpapers/" .. currentLockscreen .. ".png")

                        leftArrowIconHover = nil

                        local leftIconColor = tocolor(170, 170, 170)
                        local bigArrowIconW, bigArrowIconH = resp(17), resp(32)
                        local bigArrowLeftIconX, bigArrowLeftIconY = bgX + resp(15), bgY + bgH / 2 - bigArrowIconH / 2
                        local inSlot = exports.cr_core:isInSlot(bigArrowLeftIconX, bigArrowLeftIconY, bigArrowIconW, bigArrowIconH)
                        if inSlot then 
                            leftArrowIconHover = true
                            leftIconColor = tocolor(redR, redG, redB)
                        end

                        exports.cr_dx:dxDrawImageAsTexture(bigArrowLeftIconX, bigArrowLeftIconY, bigArrowIconW, bigArrowIconH, textures.bigArrowIcon, 180, 0, 0, leftIconColor)
                        
                        rightArrowIconHover = nil

                        local rightIconColor = tocolor(170, 170, 170)
                        local bigArrowRightIconX, bigArrowRightIconY = bgX + bgW - resp(32), bigArrowLeftIconY
                        local inSlot = exports.cr_core:isInSlot(bigArrowRightIconX, bigArrowRightIconY, bigArrowIconW, bigArrowIconH)
                        if inSlot then 
                            rightArrowIconHover = true
                            rightIconColor = tocolor(redR, redG, redB)
                        end

                        exports.cr_dx:dxDrawImageAsTexture(bigArrowRightIconX, bigArrowRightIconY, bigArrowIconW, bigArrowIconH, textures.bigArrowIcon, 0, 0, 0, rightIconColor)
                        
                        saveButtonHover = nil

                        local saveButtonW, saveButtonH = resp(148), resp(27)
                        local saveButtonX, saveButtonY = bgX + bgW / 2 - saveButtonW / 2, bgY + bgH - (saveButtonH * 2) - resp(5)
                        local inSlot = exports.cr_core:isInSlot(saveButtonX, saveButtonY, saveButtonW, saveButtonH)
                        if inSlot then 
                            saveButtonHover = true
                        end

                        dxDrawRectangle(saveButtonX, saveButtonY, saveButtonW, saveButtonH, tocolor(redR, redG, redB))
                        dxDrawText("Mentés", saveButtonX, saveButtonY, saveButtonX + saveButtonW, saveButtonY + saveButtonH, tocolor(0, 0, 0), 1, font4, "center", "center")

                        local homeW, homeH = resp(100), resp(4)
                        local homeX, homeY = bgX + homeW - resp(5), bgY + bgH - (homeH * 3)
                        local inSlot = exports.cr_core:isInSlot(homeX, homeY, homeW, homeH)
                        if inSlot then 
                            homeButtonHover = true
                        end

                        exports.cr_dx:dxDrawImageAsTexture(homeX, homeY, homeW, homeH, textures.homebutton, 0, 0, 0, homeButtonColor)
                    elseif availablePages[selectedPage] == "camera" then 
                        bgColor = tocolor(44, 44, 44)
                        statusColor = tocolor(130, 130, 130)

                        exports.cr_dx:dxDrawImageAsTexture(bgX, bgY, bgW, bgH, textures.whitebg, 0, 0, 0, bgColor)
                        exports.cr_dx:dxDrawImageAsTexture(statusX, statusY, statusW, statusH, textures.statusbar, 0, 0, 0, statusColor)
                        dxDrawText(formattedHourString, bgX - statusW + resp(45), statusY, bgX + bgW, bgY + bgH, statusColor, 1, font3, "center", "top")

                        local cameraW, cameraH = resp(284), resp(544)
                        local cameraX, cameraY = bgX + resp(1), bgY + resp(28)

                        exports.cr_dx:dxDrawImageAsTexture(cameraX, cameraY, cameraW, cameraH, textures.camerabg)

                        local screenSourceW, screenSourceH = resp(284), resp(374)
                        local screenSourceX, screenSourceY = cameraX, cameraY + resp(32)

                        dxUpdateScreenSource(screenSource)
                        dxDrawImage(screenSourceX, screenSourceY, screenSourceW, screenSourceH, screenSource)

                        cameraButtonHover = nil

                        local buttonW, buttonH = resp(58), resp(58)
                        local buttonX, buttonY = cameraX + cameraW / 2 - buttonW / 2, cameraY + cameraH - buttonH - resp(26)
                        local inSlot = exports.cr_core:isInSlot(buttonX, buttonY, buttonW, buttonH)
                        if inSlot then 
                            cameraButtonHover = true
                        end

                        selfieButtonHover = nil

                        local selfieW, selfieH = resp(40), resp(32)
                        local selfieX, selfieY = cameraX + cameraW - selfieW - resp(32), buttonY + resp(10)
                        local inSlot = exports.cr_core:isInSlot(selfieX, selfieY, selfieW, selfieH)
                        if inSlot then 
                            selfieButtonHover = true
                        end

                        homeButtonColor = tocolor(113, 113, 113)
                        local homeW, homeH = resp(100), resp(4)
                        local homeX, homeY = bgX + homeW - resp(5), bgY + bgH - (homeH * 3)
                        local inSlot = exports.cr_core:isInSlot(homeX, homeY, homeW, homeH)
                        if inSlot then 
                            homeButtonHover = true
                        end

                        exports.cr_dx:dxDrawImageAsTexture(homeX, homeY, homeW, homeH, textures.homebutton, 0, 0, 0, homeButtonColor)

                        if inSelfieMode then 
                            local boneX, boneY, boneZ = getPedBonePosition(localPlayer, 25)
                            local boneX2, boneY2, boneZ2 = getPedBonePosition(localPlayer, 6)

                            setPedLookAt(localPlayer, boneX, boneY, boneZ)
                            setCameraMatrix(boneX, boneY, boneZ + 0.02, boneX2, boneY2, boneZ2)
                        end
                    elseif availablePages[selectedPage] == "calendar" then 
                        local statusColor = tocolor(0, 0, 0)

                        if darkMode then 
                            statusColor = tocolor(255, 255, 255, 100)
                        end

                        exports.cr_dx:dxDrawImageAsTexture(bgX, bgY, bgW, bgH, textures.whitebg, 0, 0, 0, bgColor)

                        exports.cr_dx:dxDrawImageAsTexture(statusX, statusY, statusW, statusH, textures.statusbar, 0, 0, 0, statusColor)
                        dxDrawText(formattedHourString, bgX - statusW + resp(45), statusY, bgX + bgW, bgY + bgH, statusColor, 1, font3, "center", "top")

                        local avatarH = resp(43)
                        local avatarY = bgY + avatarH / 2 + resp(2)
                        
                        local backInfoW, backInfoH = resp(258), resp(16)
                        local backInfoX, backInfoY = bgX + resp(15), avatarY + backInfoH + resp(10)

                        backArrowIconHover = nil

                        local backArrowHoverW, backArrowHoverH = resp(10), resp(19)
                        local backArrowHoverX, backArrowHoverY = backInfoX, backInfoY
                        local inSlot = exports.cr_core:isInSlot(backArrowHoverX, backArrowHoverY, backArrowHoverW, backArrowHoverH)
                        if inSlot then 
                            backArrowIconHover = true
                        end

                        addIconHover = nil

                        local addIconHoverW, addIconHoverH = resp(16), resp(17)
                        local addIconHoverX, addIconHoverY = backInfoX + backInfoW - addIconHoverW, backInfoY
                        local inSlot = exports.cr_core:isInSlot(addIconHoverX, addIconHoverY, addIconHoverW, addIconHoverH)
                        if inSlot then 
                            addIconHover = true
                        end

                        exports.cr_dx:dxDrawImageAsTexture(backInfoX, backInfoY, backInfoW, backInfoH, textures.backinfo)
                        dxDrawText("Naptár", backInfoX, backInfoY, bgX + bgW, backInfoY + backInfoH + resp(2), tocolor(0, 0, 0), 1, font2, "center", "bottom")

                        local lineW, lineH = bgW, resp(1)
                        local lineX, lineY = bgX, backInfoY + backInfoH + resp(40)

                        dxDrawRectangle(lineX, lineY, lineW, lineH, tocolor(170, 170, 170))
                        dxDrawText(timeNames.en_US.months[selectedMonth] .. " " .. currentYear, lineX, lineY + resp(20), lineX + lineW, lineY + lineH, tocolor(0, 0, 0), 1, font12, "center", "top")

                        leftArrowIconHover = nil

                        local arrowIconW, arrowIconH = resp(6), resp(10)
                        local leftArrowIconX, leftArrowIconY = lineX + resp(12), lineY + resp(25)
                        local inSlot = exports.cr_core:isInSlot(leftArrowIconX, leftArrowIconY, arrowIconW, arrowIconH)
                        if inSlot then 
                            leftArrowIconHover = true
                        end

                        exports.cr_dx:dxDrawImageAsTexture(leftArrowIconX, leftArrowIconY, arrowIconW, arrowIconH, textures.smallArrowIcon, 180, 0, 0, tocolor(0, 0, 0))

                        rightArrowIconHover = nil

                        local rightArrowIconX, rightArrowIconY = lineX + lineW - resp(17), leftArrowIconY
                        local inSlot = exports.cr_core:isInSlot(rightArrowIconX, rightArrowIconY, arrowIconW, arrowIconH)
                        if inSlot then 
                            rightArrowIconHover = true
                        end

                        exports.cr_dx:dxDrawImageAsTexture(rightArrowIconX, rightArrowIconY, arrowIconW, arrowIconH, textures.smallArrowIcon, 0, 0, 0, tocolor(0, 0, 0))

                        local startX, startY = bgX - resp(127), lineY + resp(60)

                        for i = 1, #timeNames.en_US.days do 
                            local v = timeNames.en_US.days[i]

                            dxDrawText(v, startX, startY, startX + bgW, startY + lineH, tocolor(0, 0, 0), 1, font7, "center", "center")

                            startX = startX + resp(43)
                        end

                        local monthMaxDays = getMonthMaxDays(selectedMonth, currentYear)

                        local dayW, dayH = resp(42), resp(42)
                        local dayStartX, dayStartY = bgX - resp(3), lineY + resp(63)

                        circleHoverIcon = nil

                        for i = 0, monthMaxDays - 1 do 
                            local dayX, dayY = dayStartX + (dayW) * (i % maxDayInARow), dayStartY + (dayH) * (math.floor(i / maxDayInAColumn))

                            local circleW, circleH = resp(64), resp(64)
                            local circleX, circleY = dayX - resp(10), dayY - resp(10)

                            local circleHoverW, circleHoverH = resp(28), resp(28)
                            local circleHoverX, circleHoverY = circleX + resp(18), circleY + resp(18)
                            local inSlot = exports.cr_core:isInSlot(circleHoverX, circleHoverY, circleHoverW, circleHoverH)
                            if inSlot then 
                                circleHoverIcon = i + 1
                            end

                            if selectedDay == (i + 1) then 
                                exports.cr_dx:dxDrawImageAsTexture(circleX, circleY, circleW, circleH, textures.circleWithOutline)

                                if phoneData.calendar[selectedMonth] and phoneData.calendar[selectedMonth][i + 1] then 
                                    local dotW, dotH = resp(95), resp(95)
                                    local dotX, dotY = circleX - resp(15), circleY - resp(6)

                                    exports.cr_dx:dxDrawImageAsTexture(dotX, dotY, dotW, dotH, textures.dotForCircleIcon, 0, 0, 0, tocolor(0, 122, 255))
                                end

                                if currentMonthDay == (i + 1) and (currentMonth + 1) == selectedMonth then 
                                    exports.cr_dx:dxDrawImageAsTexture(circleX, circleY, circleW, circleH, textures.whiteCircleIcon, 0, 0, 0, tocolor(0, 122, 255))

                                    if phoneData.calendar[selectedMonth] and phoneData.calendar[selectedMonth][i + 1] then
                                        local dotW, dotH = resp(95), resp(95)
                                        local dotX, dotY = circleX - resp(15), circleY - resp(6)

                                        exports.cr_dx:dxDrawImageAsTexture(dotX, dotY, dotW, dotH, textures.dotForCircleIcon)
                                    end
                                end
                            elseif currentMonthDay == (i + 1) and (currentMonth + 1) == selectedMonth then 
                                exports.cr_dx:dxDrawImageAsTexture(circleX, circleY, circleW, circleH, textures.whiteCircleIcon, 0, 0, 0, tocolor(0, 122, 255))

                                if phoneData.calendar[selectedMonth] and phoneData.calendar[selectedMonth][i + 1] then 
                                    local dotW, dotH = resp(95), resp(95)
                                    local dotX, dotY = circleX - resp(15), circleY - resp(6)

                                    exports.cr_dx:dxDrawImageAsTexture(dotX, dotY, dotW, dotH, textures.dotForCircleIcon)
                                end
                            elseif phoneData.calendar[selectedMonth] and phoneData.calendar[selectedMonth][i + 1] then
                                local dotW, dotH = resp(95), resp(95)
                                local dotX, dotY = circleX - resp(15), circleY - resp(4)

                                exports.cr_dx:dxDrawImageAsTexture(dotX, dotY, dotW, dotH, textures.dotForCircleIcon, 0, 0, 0, tocolor(0, 122, 255))
                            end

                            dxDrawText(i + 1, dayX + resp(2), dayY + resp(2), dayX + dayW, dayY + dayH, tocolor(20, 20, 20), 1, font7, "center", "center")
                        end

                        local lineW, lineH = bgW - resp(40), resp(1)
                        local lineX, lineY = bgX + resp(20), bgY + bgH - resp(180)

                        dxDrawRectangle(lineX, lineY, lineW, lineH, tocolor(170, 170, 170))

                        dxDrawText("Idő:", lineX, lineY, lineX + lineW, lineY + lineH - resp(2), tocolor(170, 170, 170), 1, font7, "left", "bottom")

                        local textWidth = dxGetTextWidth("Idő:", 1, font7)
                        local inputW, inputH = lineW - resp(85), resp(15)
                        local inputX, inputY = lineX + textWidth + resp(5), lineY - inputH

                        UpdatePos("phone.calendarTime", {inputX, inputY, inputW, inputH})
                        UpdateAlpha("phone.calendarTime", tocolor(170, 170, 170))

                        -- if phoneData.calendar[selectedMonth] and phoneData.calendar[selectedMonth][selectedDay] then 
                        --     local data = phoneData.calendar[selectedMonth][selectedDay]

                        --     dxDrawText(data.time, lineX + textWidth + resp(5), lineY, lineX + lineW, lineY + lineH - resp(2), tocolor(170, 170, 170), 1, font7, "left", "bottom")
                        -- end

                        local lineY = lineY + resp(48)

                        dxDrawRectangle(lineX, lineY, lineW, lineH, tocolor(170, 170, 170))
                        dxDrawText("Leírás:", lineX, lineY, lineX + lineW, lineY + lineH - resp(2), tocolor(170, 170, 170), 1, font7, "left", "bottom")

                        local textWidth = dxGetTextWidth("Leírás:", 1, font7)
                        local inputW, inputH = lineW - resp(85), resp(15)
                        local inputX, inputY = lineX + textWidth + resp(5), lineY - inputH

                        UpdatePos("phone.calendarDescription", {inputX, inputY, inputW, inputH})
                        UpdateAlpha("phone.calendarDescription", tocolor(170, 170, 170))

                        -- if phoneData.calendar[selectedMonth] and phoneData.calendar[selectedMonth][selectedDay] then 
                        --     local data = phoneData.calendar[selectedMonth][selectedDay]

                        --     dxDrawText(data.description, lineX + textWidth + resp(5), lineY, lineX + lineW, lineY + lineH - resp(2), tocolor(170, 170, 170), 1, font7, "left", "bottom")
                        -- end

                        local lineY = lineY + resp(35)
                        
                        dxDrawRectangle(lineX, lineY, lineW, lineH, tocolor(170, 170, 170))

                        local lineY = lineY + resp(35)
                        
                        dxDrawRectangle(lineX, lineY, lineW, lineH, tocolor(170, 170, 170))

                        local homeW, homeH = resp(100), resp(4)
                        local homeX, homeY = bgX + homeW - resp(5), bgY + bgH - (homeH * 3)
                        local inSlot = exports.cr_core:isInSlot(homeX, homeY, homeW, homeH)
                        if inSlot then 
                            homeButtonHover = true
                        end

                        exports.cr_dx:dxDrawImageAsTexture(homeX, homeY, homeW, homeH, textures.homebutton, 0, 0, 0, homeButtonColor)
                    elseif availablePages[selectedPage] == "clock" then 
                        if availableSubPages[selectedSubPage] == "alarm" then 
                            local statusColor = tocolor(0, 0, 0)

                            if darkMode then 
                                statusColor = tocolor(255, 255, 255, 100)
                            end

                            exports.cr_dx:dxDrawImageAsTexture(bgX, bgY, bgW, bgH, textures.whitebg, 0, 0, 0, bgColor)

                            exports.cr_dx:dxDrawImageAsTexture(statusX, statusY, statusW, statusH, textures.statusbar, 0, 0, 0, statusColor)
                            dxDrawText(formattedHourString, bgX - statusW + resp(45), statusY, bgX + bgW, bgY + bgH, statusColor, 1, font3, "center", "top")

                            local avatarH = resp(43)
                            local avatarY = bgY + avatarH / 2 + resp(2)
                            
                            local backInfoW, backInfoH = resp(258), resp(16)
                            local backInfoX, backInfoY = bgX + resp(15), avatarY + backInfoH + resp(10)

                            backArrowIconHover = nil

                            local backArrowHoverW, backArrowHoverH = resp(10), resp(19)
                            local backArrowHoverX, backArrowHoverY = backInfoX, backInfoY
                            local inSlot = exports.cr_core:isInSlot(backArrowHoverX, backArrowHoverY, backArrowHoverW, backArrowHoverH)
                            if inSlot then 
                                backArrowIconHover = true
                            end

                            addIconHover = nil

                            local addIconHoverW, addIconHoverH = resp(16), resp(17)
                            local addIconHoverX, addIconHoverY = backInfoX + backInfoW - addIconHoverW, backInfoY
                            local inSlot = exports.cr_core:isInSlot(addIconHoverX, addIconHoverY, addIconHoverW, addIconHoverH)
                            if inSlot then 
                                addIconHover = true
                            end

                            exports.cr_dx:dxDrawImageAsTexture(backInfoX, backInfoY, backInfoW, backInfoH, textures.backinfo)
                            dxDrawText("Óra", backInfoX, backInfoY, bgX + bgW, backInfoY + backInfoH + resp(2), tocolor(0, 0, 0), 1, font2, "center", "bottom")

                            local lineW, lineH = bgW, resp(1)
                            local lineX, lineY = bgX, backInfoY + backInfoH + resp(40)

                            dxDrawRectangle(lineX, lineY, lineW, lineH, tocolor(170, 170, 170))

                            local avatarW, avatarH = resp(32), resp(32)
                            local avatarX, avatarY = lineX + resp(10), lineY + resp(5)

                            local array = phoneData.clock.alarm or {}
                            local percent = #array

                            if clockMaxLine > percent then 
                                clockMinLine = 1
                                _clockMaxLine = 6
                                clockMaxLine = _clockMaxLine
                            end

                            iconActionHover = nil
                            toggleIconHover = nil

                            for i = clockMinLine, clockMaxLine do 
                                local v = array[i]

                                if v then 
                                    local time = v.time
                                    local status = v.status

                                    dxDrawText(time, avatarX + avatarW / 2, avatarY, avatarX + avatarW, avatarY + avatarH, tocolor(0, 0, 0), 1, font2, "left", "center")

                                    local toggleIconW, toggleIconH = resp(48), resp(41)
                                    local toggleIconX, toggleIconY = lineX + lineW - toggleIconW - resp(48), avatarY
                                    local currentImage = status and textures.toggle_on or textures.toggle_off

                                    exports.cr_dx:dxDrawImageAsTexture(toggleIconX, toggleIconY, toggleIconW, toggleIconH, currentImage)

                                    local toggleIconHoverW, toggleIconHoverH = resp(40), resp(25)
                                    local toggleIconHoverX, toggleIconHoverY = toggleIconX + resp(8), toggleIconY + resp(5)
                                    local inSlot = exports.cr_core:isInSlot(toggleIconHoverX, toggleIconHoverY, toggleIconHoverW, toggleIconHoverH)
                                    if inSlot then 
                                        toggleIconHover = i
                                    end

                                    local deleteIconW, deleteIconH = resp(12), resp(14)
                                    local deleteIconX, deleteIconY = avatarX + lineW - resp(45), avatarY + resp(10)
                                    local inSlot = exports.cr_core:isInSlot(deleteIconX, deleteIconY, deleteIconW, deleteIconH)
                                    if inSlot then 
                                        iconActionHover = "deleteFromAlarms:" .. i
                                    end

                                    exports.cr_dx:dxDrawImageAsTexture(deleteIconX, deleteIconY, deleteIconW, deleteIconH, textures.deleteIcon)

                                    local lineW, lineH = lineW - resp(40), resp(1)
                                    local lineX, lineY = bgX + resp(20), avatarY + avatarH + resp(5)

                                    dxDrawRectangle(lineX, lineY, lineW, lineH, tocolor(170, 170, 170))

                                    avatarY = avatarY + avatarH + resp(10)
                                end
                            end

                            local length = #array

                            if length <= 0 then 
                                dxDrawText("Nincs egyetlen ébresztőd sem", lineX, lineY, lineX + lineW, lineY + lineH + resp(25), tocolor(0, 0, 0), 1, font2, "center", "bottom")
                            end

                            local lineW = bgW
                            local lineX, lineY = bgX, bgY + bgH - resp(230)

                            dxDrawRectangle(lineX, lineY, lineW, lineH, tocolor(170, 170, 170))

                            local lineW, lineH = bgW - resp(40), resp(1)
                            local lineX, lineY = bgX + resp(20), bgY + bgH - resp(195)

                            dxDrawRectangle(lineX, lineY, lineW, lineH, tocolor(170, 170, 170))
                            dxDrawText("Idő:", lineX, lineY, lineX + lineW, lineY + lineH - resp(2), tocolor(170, 170, 170), 1, font7, "left", "bottom")

                            local textWidth = dxGetTextWidth("Idő:", 1, font7)
                            local inputW, inputH = lineW - resp(85), resp(15)
                            local inputX, inputY = lineX + textWidth + resp(5), lineY - inputH

                            UpdatePos("phone.alarmTime", {inputX, inputY, inputW, inputH})
                            UpdateAlpha("phone.alarmTime", tocolor(170, 170, 170))

                            -- dxDrawRectangle(inputX, inputY, inputW, inputH, tocolor(124, 197, 118, 150))

                            local lineY = lineY + resp(30)

                            dxDrawRectangle(lineX, lineY, lineW, lineH, tocolor(170, 170, 170))
                            dxDrawText("Cím:", lineX, lineY, lineX + lineW, lineY + lineH - resp(2), tocolor(170, 170, 170), 1, font7, "left", "bottom")

                            local textWidth = dxGetTextWidth("Cím:", 1, font7)
                            local inputW, inputH = lineW - resp(85), resp(15)
                            local inputX, inputY = lineX + textWidth + resp(5), lineY - inputH

                            UpdatePos("phone.alarmName", {inputX, inputY, inputW, inputH})
                            UpdateAlpha("phone.alarmName", tocolor(170, 170, 170))

                            rightArrowIconHover = nil

                            local arrowIconW, arrowIconH = resp(8), resp(13)
                            local rightArrowIconX, rightArrowIconY = lineX + lineW - arrowIconW - resp(5), lineY + arrowIconH
                            local inSlot = exports.cr_core:isInSlot(rightArrowIconX, rightArrowIconY, arrowIconW, arrowIconH)
                            if inSlot then 
                                rightArrowIconHover = true
                            end

                            exports.cr_dx:dxDrawImageAsTexture(rightArrowIconX, rightArrowIconY, arrowIconW, arrowIconH, textures.clockArrowIcon, 0, 0, 0, tocolor(170, 170, 170))

                            local lineY = lineY + resp(30)

                            dxDrawRectangle(lineX, lineY, lineW, lineH, tocolor(170, 170, 170))
                            dxDrawText("Csengőhang:", lineX, lineY, lineX + lineW, lineY + lineH - resp(2), tocolor(170, 170, 170), 1, font7, "left", "bottom")

                            local textWidth = dxGetTextWidth("Csengőhang:", 1, font7)
                            local text = selectedRingtone and availableRingtones[selectedRingtone].name or ""
                            
                            dxDrawText(text, lineX + textWidth + resp(5), lineY, lineX + lineW, lineY + lineH - resp(1), tocolor(170, 170, 170), 1, font4, "left", "bottom")

                            local lineW = bgW
                            local lineX, lineY = bgX, bgY + bgH - resp(110)

                            dxDrawRectangle(lineX, lineY, lineW, lineH, tocolor(170, 170, 170))

                            local iconW, iconH = resp(40), resp(40)
                            local iconStartX, iconStartY = bgX + bgW / 2 - iconW - resp(5), bgY + bgH - iconH - resp(35)

                            hoverClockIcon = nil

                            for i = 1, #clockIcons do 
                                local v = clockIcons[i]

                                if textures.clockIcons[i] then 
                                    local color = iconAndTextColor
                                    local inSlot = exports.cr_core:isInSlot(iconStartX, iconStartY, iconW, iconH)
                                    if inSlot then 
                                        hoverClockIcon = i
                                    end

                                    if i == 1 then 
                                        color = tocolor(0, 122, 255)
                                    end

                                    exports.cr_dx:dxDrawImageAsTexture(iconStartX, iconStartY, iconW, iconH, textures.clockIcons[i], 0, 0, 0, color)
                                    dxDrawText(v.name, iconStartX, iconStartY, iconStartX + iconW, iconStartY + iconH + resp(5), color, 1, font5, "center", "bottom")
                                end

                                iconStartX = iconStartX + (iconW + resp(17))
                            end

                            local homeW, homeH = resp(100), resp(4)
                            local homeX, homeY = bgX + homeW - resp(5), bgY + bgH - (homeH * 3)
                            local inSlot = exports.cr_core:isInSlot(homeX, homeY, homeW, homeH)
                            if inSlot then 
                                homeButtonHover = true
                            end

                            exports.cr_dx:dxDrawImageAsTexture(homeX, homeY, homeW, homeH, textures.homebutton, 0, 0, 0, homeButtonColor)
                        elseif availableSubPages[selectedSubPage] == "timer" then
                            local statusColor = tocolor(0, 0, 0)

                            if darkMode then 
                                statusColor = tocolor(255, 255, 255, 100)
                            end

                            exports.cr_dx:dxDrawImageAsTexture(bgX, bgY, bgW, bgH, textures.whitebg, 0, 0, 0, bgColor)

                            exports.cr_dx:dxDrawImageAsTexture(statusX, statusY, statusW, statusH, textures.statusbar, 0, 0, 0, statusColor)
                            dxDrawText(formattedHourString, bgX - statusW + resp(45), statusY, bgX + bgW, bgY + bgH, statusColor, 1, font3, "center", "top")

                            local avatarH = resp(43)
                            local avatarY = bgY + avatarH / 2 + resp(2)
                            
                            backArrowIconHover = nil

                            local backArrowW, backArrowH = resp(9), resp(15)
                            local backArrowX, backArrowY = bgX + resp(15), avatarY + backArrowH + resp(10)
                            local inSlot = exports.cr_core:isInSlot(backArrowX, backArrowY, backArrowW, backArrowH)
                            if inSlot then 
                                backArrowIconHover = true
                            end

                            exports.cr_dx:dxDrawImageAsTexture(backArrowX, backArrowY, backArrowW, backArrowH, textures.backArrowIcon)
                            dxDrawText("Óra", backArrowX, backArrowY, bgX + bgW, backArrowY + backArrowH + resp(2), tocolor(0, 0, 0), 1, font2, "center", "bottom")

                            local lineW, lineH = bgW, resp(1)
                            local lineX, lineY = bgX, backArrowY + backArrowH + resp(40)

                            dxDrawRectangle(lineX, lineY, lineW, lineH, tocolor(170, 170, 170))
                            dxDrawText(timerText, bgX, lineY + resp(50), bgX + bgW, lineY + lineH, tocolor(0, 0, 0), 1, font14, "center", "top")

                            circleActionHover = nil

                            local circleW, circleH = resp(72), resp(72)
                            local circleX, circleY = bgX + resp(10), lineY + resp(50) + circleH + resp(10)
                            local inSlot = exports.cr_core:isInSlot(circleX, circleY, circleW, circleH)
                            if inSlot then 
                                circleActionHover = "roundCircle"
                            end

                            exports.cr_dx:dxDrawImageAsTexture(circleX, circleY, circleW, circleH, textures.bigWhiteCircleIcon, 0, 0, 0, tocolor(170, 186, 170))
                            dxDrawText("KÖR", circleX, circleY, circleX + circleW, circleY + circleH, tocolor(107, 117, 107), 1, font15, "center", "center")

                            local circleX = bgX + bgW - resp(10) - circleW
                            local inSlot = exports.cr_core:isInSlot(circleX, circleY, circleW, circleH)
                            if inSlot then 
                                circleActionHover = "circleButton"
                            end

                            local currentColor = tocolor(6, 255, 0)
                            local textColor = tocolor(3, 163, 0)
                            local currentText = "START"

                            if timerStarted then 
                                currentColor = tocolor(255, 0, 0)
                                textColor = tocolor(163, 0, 0)
                                currentText = "STOP"
                            end

                            exports.cr_dx:dxDrawImageAsTexture(circleX, circleY, circleW, circleH, textures.bigWhiteCircleIcon, 0, 0, 0, currentColor)
                            dxDrawText(currentText, circleX, circleY, circleX + circleW, circleY + circleH, textColor, 1, font15, "center", "center")

                            local lineW = bgW
                            local lineX, lineY = bgX, circleY + circleH + resp(20)

                            dxDrawRectangle(lineX, lineY, lineW, lineH, tocolor(170, 170, 170))

                            local array = phoneData.clock.timer or {}
                            local percent = #array

                            if timerMaxLine > percent then 
                                timerMinLine = 1
                                _timerMaxLine = 6
                                timerMaxLine = _timerMaxLine
                            end

                            local lineW = bgW - resp(40)
                            local lineX, lineStartY = bgX + resp(20), lineY + resp(25)

                            for i = timerMinLine, timerMaxLine do 
                                local v = array[i]

                                if v then 
                                    local roundTime = v.roundTime

                                    dxDrawRectangle(lineX, lineStartY, lineW, lineH, tocolor(170, 170, 170))
                                    dxDrawText("Kör " .. i, lineX, lineStartY, lineX + lineW, lineStartY + lineH - resp(2), tocolor(170, 170, 170), 1, font7, "left", "bottom")
                                    dxDrawText(roundTime, lineX, lineStartY, lineX + lineW, lineStartY + lineH - resp(2), tocolor(170, 170, 170), 1, font7, "right", "bottom")

                                    lineStartY = lineStartY + resp(30)
                                end
                            end

                            local lineW = bgW
                            local lineX, lineY = bgX, lineStartY - resp(15)

                            dxDrawRectangle(lineX, lineY, lineW, lineH, tocolor(170, 170, 170))

                            local iconW, iconH = resp(40), resp(40)
                            local iconStartX, iconStartY = bgX + bgW / 2 - iconW - resp(5), bgY + bgH - iconH - resp(35)

                            hoverClockIcon = nil

                            for i = 1, #clockIcons do 
                                local v = clockIcons[i]

                                if textures.clockIcons[i] then 
                                    local color = iconAndTextColor
                                    local inSlot = exports.cr_core:isInSlot(iconStartX, iconStartY, iconW, iconH)
                                    if inSlot then 
                                        hoverClockIcon = i
                                    end

                                    if i == 2 then 
                                        color = tocolor(0, 122, 255)
                                    end

                                    exports.cr_dx:dxDrawImageAsTexture(iconStartX, iconStartY, iconW, iconH, textures.clockIcons[i], 0, 0, 0, color)
                                    dxDrawText(v.name, iconStartX, iconStartY, iconStartX + iconW, iconStartY + iconH + resp(5), color, 1, font5, "center", "bottom")
                                end

                                iconStartX = iconStartX + (iconW + resp(17))
                            end

                            local homeW, homeH = resp(100), resp(4)
                            local homeX, homeY = bgX + homeW - resp(5), bgY + bgH - (homeH * 3)
                            local inSlot = exports.cr_core:isInSlot(homeX, homeY, homeW, homeH)
                            if inSlot then 
                                homeButtonHover = true
                            end

                            exports.cr_dx:dxDrawImageAsTexture(homeX, homeY, homeW, homeH, textures.homebutton, 0, 0, 0, homeButtonColor)
                        end
                    elseif availablePages[selectedPage] == "callHistory" then 
                        local statusColor = tocolor(0, 0, 0)

                        if darkMode then 
                            statusColor = tocolor(255, 255, 255, 100)
                        end

                        exports.cr_dx:dxDrawImageAsTexture(bgX, bgY, bgW, bgH, textures.whitebg, 0, 0, 0, bgColor)

                        exports.cr_dx:dxDrawImageAsTexture(statusX, statusY, statusW, statusH, textures.statusbar, 0, 0, 0, statusColor)
                        dxDrawText(formattedHourString, bgX - statusW + resp(45), statusY, bgX + bgW, bgY + bgH, statusColor, 1, font3, "center", "top")

                        local avatarH = resp(43)
                        local avatarY = bgY + avatarH / 2 + resp(2)

                        backArrowIconHover = nil

                        local backArrowW, backArrowH = resp(9), resp(15)
                        local backArrowX, backArrowY = bgX + resp(15), avatarY + backArrowH + resp(10)
                        local inSlot = exports.cr_core:isInSlot(backArrowX, backArrowY, backArrowW, backArrowH)
                        if inSlot then 
                            backArrowIconHover = true
                        end

                        exports.cr_dx:dxDrawImageAsTexture(backArrowX, backArrowY, backArrowW, backArrowH, textures.backArrowIcon)
                        dxDrawText("Hívás előzmények", backArrowX, backArrowY, bgX + bgW, backArrowY + backArrowH + resp(2), tocolor(0, 0, 0), 1, font2, "center", "bottom")

                        local searchW, searchH = resp(179), resp(26)
                        local searchX, searchY = bgX + bgW / 2 - searchW / 2, backArrowY + searchH

                        exports.cr_dx:dxDrawImageAsTexture(searchX, searchY, searchW, searchH, textures.search)

                        UpdatePos("callHistory.search", {searchX + resp(10), searchY, searchW - resp(45), searchH})
                        UpdateAlpha("callHistory.search", tocolor(153, 153, 153, 255))

                        local lineW, lineH = bgW, resp(1)
                        local lineX, lineY = bgX, searchY + searchH + resp(10)

                        dxDrawRectangle(lineX, lineY, lineW, lineH, tocolor(170, 170, 170))

                        local avatarW, avatarH = resp(32), resp(32)
                        local avatarX, avatarY = lineX + resp(10), lineY + resp(5)

                        local iconW, iconH = resp(40), resp(40)
                        local iconStartX, iconStartY = bgX + resp(10), bgY + bgH - iconH - resp(35)

                        hoverCallIcon = nil

                        for i = 1, #callIcons do 
                            local v = callIcons[i]

                            if textures.callIcons[i] then 
                                local color = iconAndTextColor
                                local inSlot = exports.cr_core:isInSlot(iconStartX, iconStartY, iconW, iconH)
                                if inSlot then 
                                    hoverCallIcon = i
                                end

                                if i == 2 then 
                                    color = tocolor(0, 122, 255)
                                end

                                exports.cr_dx:dxDrawImageAsTexture(iconStartX, iconStartY, iconW, iconH, textures.callIcons[i], 0, 0, 0, color)
                                dxDrawText(v.name, iconStartX, iconStartY, iconStartX + iconW, iconStartY + iconH + resp(5), color, 1, font5, "center", "bottom")
                            end

                            iconStartX = iconStartX + (iconW + resp(17))
                        end

                        local array = phoneCallHistory or {}
                        local percent = #array

                        if callHistorySearchCache then 
                            array = callHistorySearchCache
                            percent = #array
                        end

                        if callHistoryMaxLine > percent then 
                            callHistoryMinLine = 1
                            _callHistoryMaxLine = 10
                            callHistoryMaxLine = _callHistoryMaxLine
                        end

                        for i = callHistoryMinLine, callHistoryMaxLine do 
                            local v = array[i]

                            if v and v.name and v.phoneNumber and v.formattedYearString and v.formattedHourString then 
                                local phoneNumber = v.phoneNumber
                                local name = phoneContacts[phoneNumber] or "Ismeretlen"

                                local formattedYearString = v.formattedYearString
                                local formattedHourString2 = v.formattedHourString

                                exports.cr_dx:dxDrawImageAsTexture(avatarX, avatarY, avatarW, avatarH, textures.messagesavatar)

                                dxDrawText(name, avatarX + avatarW + resp(5), avatarY - resp(3), avatarX + avatarW, avatarY + avatarH, tocolor(0, 0, 0), 1, font2, "left", "top")
                                dxDrawText(formatPhoneNumber(phoneNumber), avatarX + avatarW + resp(5), avatarY - resp(5), avatarX + avatarW, avatarY + avatarH, tocolor(0, 0, 0), 1, font7, "left", "bottom")
                                dxDrawText(formattedHourString2 .. "\n" .. formattedYearString, avatarX, avatarY, avatarX + bgW - avatarW + resp(5), avatarY + avatarH, tocolor(0, 0, 0), 1, font7, "right", "center")

                                local lineW, lineH = lineW - resp(20), resp(1)
                                local lineX, lineY = bgX + resp(10), avatarY + avatarH + resp(5)

                                dxDrawRectangle(lineX, lineY, lineW, lineH, tocolor(170, 170, 170))

                                avatarY = avatarY + avatarH + resp(10)
                            end
                        end

                        local length = #array

                        if length <= 0 then 
                            dxDrawText("Nincs egyetlen előzményed sem", lineX, lineY, lineX + lineW, lineY + lineH + resp(25), tocolor(0, 0, 0), 1, font2, "center", "bottom")
                        end

                        local homeW, homeH = resp(100), resp(4)
                        local homeX, homeY = bgX + homeW - resp(5), bgY + bgH - (homeH * 3)
                        local inSlot = exports.cr_core:isInSlot(homeX, homeY, homeW, homeH)
                        if inSlot then 
                            homeButtonHover = true
                        end

                        exports.cr_dx:dxDrawImageAsTexture(homeX, homeY, homeW, homeH, textures.homebutton, 0, 0, 0, homeButtonColor)
                    end
                end
            end
        end
    end
end

function managePhone(state, lockScreen)
    if state == "init" then 
        if lockScreen then 
            lockScreenActive = true
        end

        createRender("renderPhone", renderPhone)

        removeEventHandler("onClientKey", root, onKey)
        addEventHandler("onClientKey", root, onKey)

        createTextures()

        realTime = getRealTime()

        currentHour = realTime.hour
        currentMinute = realTime.minute

        currentYear = realTime.year + 1900
        currentMonth = realTime.month
        currentMonthDay = realTime.monthday
        currentWeekDay = realTime.weekday

        formattedHourString = ("%02d:%02d"):format(currentHour, currentMinute)
        formattedDateString = timeNames.weeks[currentWeekDay] .. ", " .. timeNames.months[currentMonth] .. " " .. currentMonthDay

        dateTimer = setTimer(
            function()
                realTime = getRealTime()

                currentHour = realTime.hour
                currentMinute = realTime.minute

                currentYear = realTime.year + 1900
                currentMonth = realTime.month
                currentMonthDay = realTime.monthday
                currentWeekDay = realTime.weekday

                formattedHourString = ("%02d:%02d"):format(currentHour, currentMinute)
                formattedDateString = timeNames.weeks[currentWeekDay] .. ", " .. timeNames.months[currentMonth] .. " " .. currentMonthDay
            end, 5000, 0
        )

        triggerLatentServerEvent("phone.createPhoneObject", 5000, false, localPlayer)
    elseif state == "destroy" then 
        destroyRender("renderPhone")
        destroyTextures()
        manageRingtonePreview("destroy")
        manageAlarmSound("destroy", false, alarmIndexSave)

        removeEventHandler("onClientKey", root, onKey)
        removeEventHandler("onClientCharacter", root, onCharacter)

        if isElement(screenSource) then 
            screenSource:destroy()
            screenSource = false
        end

        if isTimer(callTimer) then 
            killTimer(callTimer)
            callTimer = nil
        end

        if isTimer(inCallTimer) then 
            killTimer(inCallTimer)
            inCallTimer = nil
        end

        if isTimer(dateTimer) then 
            killTimer(dateTimer)
            dateTimer = nil
        end

        if timerStarted then 
            timerStarted = false
        end

        if isTimer(clockTimer) then 
            killTimer(clockTimer)
            clockTimer = nil
        end

        if callData.targetNumber then 
            triggerServerEvent("phone.denyCall", localPlayer, callData.targetElement, "local")

            callData = {
                targetNumber = false,
                targetElement = false,
                phoneService = false,
                pickedUp = false,
                messages = {}
            }
        end

        if inSelfieMode then 
            localPlayer:setData("forceAnimation", {"", ""})
            setCameraTarget(localPlayer)

            inSelfieMode = false
        end

        selectedPage = false
        switchedFromAlarm = false
        selectedRingtone = false

        manageFactionCall("close", true)
        manageTextbars("destroy")
        resetScroll()

        exports.cr_inventory:updateItemDetails(localPlayer, currentPhoneSlot, 1, {"nbt", phoneData}, true)
        triggerLatentServerEvent("phone.destroyPhoneObject", 5000, false, localPlayer)

        currentPhoneSlot = false
    end
end

function showPhone(data, activeSlot)
    if activeSlot then 
        managePhone("init", true)

        exports.cr_chat:createMessage(localPlayer, "elővesz egy telefont.", 1)

        if data[1] and data[3] then 
            phoneMessages = {}
            phoneAlarms = {}
            phoneContacts = {}
            phoneCallHistory = {}

            phoneData = {
                myCallNumber = data[1],
                service = data[3].service,
                wallet = data[3].wallet,
                wallpaper = data[3].wallpaper,
                lockscreen = data[3].lockscreen,
                ringtone = data[3].ringtone,
                ringtoneVolume = data[3].ringtoneVolume,
                darkwebads = data[3].darkwebads,
                normalads = data[3].normalads,
                messages = data[3].messages,
                contacts = data[3].contacts,
                showMyNumber = data[3].showMyNumber,
                calendar = data[3].calendar,
                clock = data[3].clock,
                simHistory = data[3].simHistory,
                callHistory = data[3].callHistory
            }

            local messageSave = table.copy(phoneData.messages)
            phoneData.messages = {}

            for k, v in pairs(messageSave) do
                phoneData.messages[tonumber(k)] = v

                table.insert(phoneMessages, {
                    name = "Ismeretlen",
                    text = v.text,
                    phoneNumber = tonumber(k)
                })
            end

            table.sort(phoneMessages,
                function(a, b)
                    local sourceNumber = tonumber(a.phoneNumber)
                    local targetNumber = tonumber(b.phoneNumber)

                    local a = phoneData.messages[sourceNumber][1]
                    local b = phoneData.messages[targetNumber][1]

                    if a.sendAt and b.sendAt then 
                        return tonumber(a.sendAt) > tonumber(b.sendAt)
                    end
                end
            )

            if phoneData.clock and phoneData.clock.alarm then 
                for k, v in pairs(phoneData.clock.alarm) do 
                    phoneAlarms[v.time] = true
                end
            end

            if phoneData.contacts then 
                for k, v in pairs(phoneData.contacts) do 
                    phoneContacts[v.phoneNumber] = v.name
                end
            end

            if phoneData.callHistory then 
                phoneCallHistory = {}

                for k, v in pairs(phoneData.callHistory) do 
                    local lastInteractAt = v.lastInteractAt
                    local realTime = getRealTime(lastInteractAt)
                    
                    local formattedYearString = ("%d.%.2d.%.2d."):format(realTime.year + 1900, realTime.month + 1, realTime.monthday)
                    local formattedHourString2 = ("%02d:%02d:%02d"):format(realTime.hour, realTime.minute, realTime.second)

                    local name = phoneContacts[k] or "Ismeretlen"

                    table.insert(phoneCallHistory, {
                        name = name,
                        phoneNumber = tonumber(k),
                        lastInteractAt = lastInteractAt,
                        formattedYearString = formattedYearString,
                        formattedHourString = formattedHourString2
                    })
                end
            end

            clockCopy = table.copy(phoneData.clock)
            myCallNumberSave = phoneData.myCallNumber
        end

        currentPhoneSlot = data[2]

        if availablePages[selectedPage] == "camera" then 
            if not screenSource then 
                screenSource = dxCreateScreenSource(screenX, screenY)
            end
        end

        initAlarms()
    else
        managePhone("destroy")

        exports.cr_chat:createMessage(localPlayer, "elrak egy telefont.", 1)

        phoneData = {
            myCallNumber = false,
            service = false,
            wallet = false,
            wallpaper = false,
            lockscreen = false,
            ringtone = false,
            ringtoneVolume = false,
            darkwebads = false,
            normalads = false,
            messages = false,
            contacts = false,
            showMyNumber = false,
            calendar = false,
            clock = false,
            simHistory = false,
            callHistory = false
        }
    end
end

function initAlarms()
    if isTimer(alarmCheckTimer) then 
        killTimer(alarmCheckTimer)
        alarmCheckTimer = nil
    end

    alarmCheckTimer = setTimer(
        function()
            local alarms = clockCopy and clockCopy.alarm and clockCopy.alarm or {}

            if alarms then 
                local realTime = getRealTime()

                for i = 1, #alarms do 
                    local v = alarms[i]

                    if v.time and v.selectedRingtone then 
                        local time = v.time
                        local status = v.status

                        local selectedRingtone = v.selectedRingtone
                        local alreadyPlayed = v.alreadyPlayed
                        local splittedTable = split(time, ":")

                        if tonumber(splittedTable[1]) and tonumber(splittedTable[2]) then 
                            if status and not alreadyPlayed then 
                                local alarmHour = tonumber(splittedTable[1])
                                local alarmMinute = tonumber(splittedTable[2])

                                if alarmHour == realTime.hour and alarmMinute == realTime.minute then 
                                    manageAlarmSound("init", selectedRingtone, i)

                                    break
                                end
                            end
                        end
                    end
                end
            end
        end, 30000, 0
    )
end

-- if localPlayer.name == "Hugh_Wiley" then 
--     setTimer(showPhone, 100, 1, {}, true)
-- end

function manageTextbars(state)
    if state == "create" then 
        if availablePages[selectedPage] == "chat" then 
            CreateNewBar("phone.chat", {0, 0, 0, 0}, {25, "Üzenet írása...", false, tocolor(255, 255, 255), {"SFUIDisplay-Regular", getRealFontSize(9)}, 1, "left", "center", false, true}, 1)
        elseif availablePages[selectedPage] == "messages" then 
            CreateNewBar("messages.search", {0, 0, 0, 0}, {18, "Keresés...", false, tocolor(255, 255, 255), {"SFUIDisplay-Regular", getRealFontSize(9)}, 1, "left", "center", false, true}, 1)
        elseif availablePages[selectedPage] == "addNewMessage" then 
            CreateNewBar("phone.newMessagePhoneNumber", {0, 0, 0, 0}, {10, "", true, tocolor(255, 255, 255), {"SFUIDisplay-Regular", getRealFontSize(9)}, 1, "left", "center", false, true}, 1)
            CreateNewBar("phone.newMessage", {0, 0, 0, 0}, {18, "", false, tocolor(255, 255, 255), {"SFUIDisplay-Regular", getRealFontSize(9)}, 1, "left", "center", false, true}, 2)
        elseif availablePages[selectedPage] == "viewMessages" then 
            CreateNewBar("viewMessages.chat", {0, 0, 0, 0}, {25, "Üzenet írása...", false, tocolor(255, 255, 255), {"SFUIDisplay-Regular", getRealFontSize(9)}, 1, "left", "center", false, true}, 1)
        elseif availablePages[selectedPage] == "advertisement" then 
            CreateNewBar("phone.advertisementText", {0, 0, 0, 0}, {120, "Szöveg írása...", false, tocolor(255, 255, 255), {"SFUIDisplay-Regular", getRealFontSize(9)}, 1, "left", "top", false, false, true}, 1)
        elseif availablePages[selectedPage] == "contacts" then 
            CreateNewBar("contacts.search", {0, 0, 0, 0}, {18, "Keresés...", false, tocolor(255, 255, 255), {"SFUIDisplay-Regular", getRealFontSize(9)}, 1, "left", "center", false, true}, 1)
        elseif availablePages[selectedPage] == "callHistory" then
            CreateNewBar("callHistory.search", {0, 0, 0, 0}, {18, "Keresés...", false, tocolor(255, 255, 255), {"SFUIDisplay-Regular", getRealFontSize(9)}, 1, "left", "center", false, true}, 1)
        elseif availablePages[selectedPage] == "addNewContact" then 
            CreateNewBar("phone.newContactName", {0, 0, 0, 0}, {18, "", false, tocolor(255, 255, 255), {"SFUIDisplay-Regular", getRealFontSize(9)}, 1, "left", "center", false, true}, 1)
            CreateNewBar("phone.newContactPhoneNumber", {0, 0, 0, 0}, {10, "", true, tocolor(255, 255, 255), {"SFUIDisplay-Regular", getRealFontSize(9)}, 1, "left", "center", false, true}, 2)
        elseif availablePages[selectedPage] == "settings" then 
            CreateNewBar("settings.search", {0, 0, 0, 0}, {18, "Keresés...", false, tocolor(255, 255, 255), {"SFUIDisplay-Regular", getRealFontSize(9)}, 1, "left", "center", false, true}, 1)
        elseif availablePages[selectedPage] == "calendar" then
            CreateNewBar("phone.calendarTime", {0, 0, 0, 0}, {18, "", false, tocolor(255, 255, 255), {"SFUIDisplay-Regular", getRealFontSize(10)}, 1, "left", "center", false, true}, 1)
            CreateNewBar("phone.calendarDescription", {0, 0, 0, 0}, {18, "", false, tocolor(255, 255, 255), {"SFUIDisplay-Regular", getRealFontSize(10)}, 1, "left", "center", false, true}, 2)
        elseif availablePages[selectedPage] == "clock" then
            if availableSubPages[selectedSubPage] == "alarm" then 
                local alarmTime = contentCache.alarmTime or ""
                local alarmName = contentCache.alarmName or ""

                CreateNewBar("phone.alarmTime", {0, 0, 0, 0}, {4, alarmTime, true, tocolor(255, 255, 255), {"SFUIDisplay-Regular", getRealFontSize(9)}, 1, "left", "center", false, true}, 1)
                CreateNewBar("phone.alarmName", {0, 0, 0, 0}, {18, alarmName, false, tocolor(255, 255, 255), {"SFUIDisplay-Regular", getRealFontSize(9)}, 1, "left", "center", false, true}, 1)

                contentCache = {alarmTime = false, alarmName = false}
            end
        elseif availablePages[selectedPage] == "ringtoneSelector" then 
            CreateNewBar("ringtoneSelector.search", {0, 0, 0, 0}, {18, "Keresés...", false, tocolor(255, 255, 255), {"SFUIDisplay-Regular", getRealFontSize(9)}, 1, "left", "center", false, true}, 1)
        end
    elseif state == "destroy" then
        Clear()

        if contactEditing.selectedName then 
            contactEditing = {
                isEditing = false,
                selectedName = false,
                selectedNumber = false,
                selectedKey = false
            }
        end
    end
end
manageTextbars("create")

function onKey(button, state)
    if phoneActive then 
        if button == "mouse1" then 
            if state then 
                if lockScreenActive then 
                    if phoneHover then 
                        local cursorX, cursorY = exports.cr_core:getCursorPosition()

                        lockScreenStartY = cursorY
                    end
                else
                    if not selectedPage then 
                        if hoverPage then 
                            local pageName = availablePages[hoverPage]

                            if selectedPage ~= hoverPage and pageName and not notAvailablePages[pageName] then 
                                selectedPage = hoverPage

                                manageTextbars("create")

                                if availablePages[selectedPage] == "call" then 
                                    removeEventHandler("onClientCharacter", root, onCharacter)
                                    addEventHandler("onClientCharacter", root, onCharacter)
                                elseif availablePages[selectedPage] == "camera" then 
                                    if not isElement(screenSource) then 
                                        screenSource = dxCreateScreenSource(screenX, screenY)
                                    end
                                end
                            end
                        end
                    else
                        if availablePages[selectedPage] == "call" then 
                            if hoverKeyPad then 
                                if utf8.len(callNumberText .. keyPad[hoverKeyPad]) < maxCallNumberLength then
                                    callNumberText = callNumberText .. keyPad[hoverKeyPad]
                                end
                            elseif deleteFromKeyPadIconHover then 
                                if utf8.len(callNumberText) > 0 then 
                                    removeCharacterFromCallNumber()
                                end
                            elseif hoverCallIcon then 
                                if callIcons[hoverCallIcon].name == "Névjegyzék" then 
                                    manageTextbars("destroy")
                                    selectedPage = 6
                                    manageTextbars("create")
                                elseif callIcons[hoverCallIcon].name == "Előzmények" then 
                                    manageTextbars("destroy")
                                    selectedPage = 22
                                    manageTextbars("create")
                                end

                                removeEventHandler("onClientCharacter", root, onCharacter)
                            elseif callIconHover then 
                                startCall()
                            end
                        elseif availablePages[selectedPage] == "outgoingcall" then 
                            if callDenyIconHover then 
                                if lastInteraction + interactionDelayTime > getTickCount() then 
                                    return
                                end

                                triggerServerEvent("phone.denyCall", localPlayer, callData.targetElement)

                                callData = {
                                    targetNumber = false,
                                    targetElement = false,
                                    phoneService = false,
                                    pickedUp = false,
                                    messages = {}
                                }

                                selectedPage = false
                                lastInteraction = getTickCount()
                            end
                        elseif availablePages[selectedPage] == "incomingcall" then 
                            if callDenyIconHover then 
                                if lastInteraction + interactionDelayTime > getTickCount() then 
                                    return
                                end

                                triggerServerEvent("phone.denyCall", localPlayer, callData.targetElement, "local")

                                callData = {
                                    targetNumber = false,
                                    targetElement = false,
                                    phoneService = false,
                                    pickedUp = false,
                                    messages = {}
                                }

                                selectedPage = false
                                lastInteraction = getTickCount()
                            elseif callAcceptIconHover then 
                                if lastInteraction + interactionDelayTime > getTickCount() then 
                                    return
                                end

                                triggerServerEvent("phone.acceptCall", localPlayer, callData.targetElement)

                                selectedPage = 15
                                manageTextbars("create")

                                lastInteraction = getTickCount()
                            end
                        elseif availablePages[selectedPage] == "chat" then
                            if messageSendIconHover then 
                                sendMessageInCall()
                            elseif callDenyIconHover then 
                                if lastInteraction + interactionDelayTime > getTickCount() then 
                                    return
                                end

                                triggerServerEvent("phone.denyCall", localPlayer, callData.targetElement)

                                callData = {
                                    targetNumber = false,
                                    targetElement = false,
                                    phoneService = false,
                                    pickedUp = false,
                                    messages = {}
                                }

                                selectedPage = false
                                lastInteraction = getTickCount()

                                manageTextbars("destroy")
                            end
                        elseif availablePages[selectedPage] == "messages" then
                            if backArrowIconHover then 
                                manageTextbars("destroy")
                                selectedPage = false
                            elseif addIconHover then 
                                manageTextbars("destroy")
                                selectedPage = 16
                                manageTextbars("create")
                            elseif iconActionHover then 
                                local splittedTable = split(iconActionHover, ":")
                                
                                if splittedTable[1] == "callFromMessages" then 
                                    if lastInteraction + interactionDelayTime > getTickCount() then 
                                        return
                                    end

                                    local index = tonumber(splittedTable[2])
                                    local hoverMessage = phoneMessages[index]

                                    local service = phoneData.service

                                    if shopTypes[service] then 
                                        local shopData = shopTypes[service]

                                        if tonumber(hoverMessage.phoneNumber) and tonumber(hoverMessage.phoneNumber) <= 0 then 
                                            local syntax = exports.cr_core:getServerSyntax("Phone", "error")
                            
                                            outputChatBox(syntax .. "Ezen a számon előfizető nem kapcsolható.", 255, 0, 0, true)
                                            return
                                        end

                                        if phoneData.wallet - shopData.pricePerCall >= 0 then 
                                            triggerServerEvent("phone.startCall", localPlayer, phoneData.myCallNumber, hoverMessage.phoneNumber)
                                        else 
                                            local syntax = exports.cr_core:getServerSyntax("Phone", "error")

                                            outputChatBox(syntax .. "Nincs elég pénzed a hívás megkezdéséhez.", 255, 0, 0, true)
                                        end
                                    end

                                    lastInteraction = getTickCount()
                                elseif splittedTable[1] == "selectMessage" then 
                                    local index = tonumber(splittedTable[2])
                                    local hoverMessage = phoneMessages[index]

                                    manageTextbars("destroy")

                                    selectedMessage = hoverMessage.phoneNumber
                                    selectedPage = 17

                                    manageTextbars("create")
                                elseif splittedTable[1] == "addToContacts" then 
                                    local index = tonumber(splittedTable[2])
                                    local hoverMessage = phoneMessages[index]

                                    local name = hoverMessage.name
                                    local phoneNumber = hoverMessage.phoneNumber

                                    if phoneContacts[phoneNumber] then 
                                        local syntax = exports.cr_core:getServerSyntax("Phone", "error")

                                        outputChatBox(syntax .. "Ez a telefonszám már szerepel a névjegyek közt.", 255, 0, 0, true)
                                        return
                                    end

                                    table.insert(phoneData.contacts, {
                                        name = name,
                                        phoneNumber = tonumber(phoneNumber)
                                    })
    
                                    phoneContacts[tonumber(phoneNumber)] = name
    
                                    local syntax = exports.cr_core:getServerSyntax("Phone", "success")
                                    outputChatBox(syntax .. "Sikeresen hozzáadtad a névjegyekhez!", 255, 0, 0, true)
                                elseif splittedTable[1] == "deleteFromMessages" then 
                                    local index = tonumber(splittedTable[2])
                                    local hoverMessage = phoneMessages[index]

                                    table.remove(phoneMessages, index)
                                    if phoneData.messages[hoverMessage.phoneNumber] then 
                                        phoneData.messages[hoverMessage.phoneNumber] = nil
                                    end

                                    local syntax = exports.cr_core:getServerSyntax("Phone", "success")

                                    outputChatBox(syntax .. "Sikeresen kitörölted az üzenetek közül!", 255, 0, 0, true)
                                end
                            end
                        elseif availablePages[selectedPage] == "addNewMessage" then 
                            if backArrowIconHover then 
                                manageTextbars("destroy")

                                selectedPage = 3
                                manageTextbars("create")
                            elseif addIconHover then 
                                if lastInteraction + interactionDelayTime > getTickCount() then 
                                    return
                                end

                                local phoneNumber = GetText("phone.newMessagePhoneNumber")
                                local text = GetText("phone.newMessage")

                                if not tonumber(phoneNumber) then 
                                    local syntax = exports.cr_core:getServerSyntax("Phone", "error")

                                    outputChatBox(syntax .. "Hibás telefonszám.", 255, 0, 0, true)
                                    return
                                end

                                if utf8.len(phoneNumber) < 10 then 
                                    local syntax = exports.cr_core:getServerSyntax("Phone", "error")

                                    outputChatBox(syntax .. "A telefonszámnak minimum 10 karaktert kell tartalmaznia.", 255, 0, 0, true)
                                    return
                                end

                                if utf8.len(text) < 5 then 
                                    local syntax = exports.cr_core:getServerSyntax("Phone", "error")

                                    outputChatBox(syntax .. "Az üzenetnek minimum 5 karaktert kell tartalmaznia.", 255, 0, 0, true)
                                    return
                                end

                                if phoneData.messages[tonumber(phoneNumber)] then 
                                    local syntax = exports.cr_core:getServerSyntax("Phone", "error")

                                    outputChatBox(syntax .. "Ez a telefonszám már szerepel az üzeneteid közt.", 255, 0, 0, true)
                                    return
                                end

                                if factionCalls[tonumber(phoneNumber)] then 
                                    local syntax = exports.cr_core:getServerSyntax("Phone", "error")

                                    outputChatBox(syntax .. "Ennek a szervezetnek nem tudsz üzenetet küldeni.", 255, 0, 0, true)
                                    return
                                end

                                local service = phoneData.service

                                if service then 
                                    local shopData = shopTypes[service]

                                    if tonumber(phoneNumber) and tonumber(phoneNumber) <= 0 then 
                                        local syntax = exports.cr_core:getServerSyntax("Phone", "error")
                            
                                        outputChatBox(syntax .. "Ezen a számon előfizető nem kapcsolható.", 255, 0, 0, true)
                                        return
                                    end

                                    if shopData then 
                                        if phoneData.wallet - shopData.pricePerSms > 0 then 
                                            phoneData.wallet = phoneData.wallet - shopData.pricePerSms

                                            exports.cr_inventory:updateItemDetails(localPlayer, currentPhoneSlot, 1, {"nbt", phoneData}, true)
                                        else
                                            local syntax = exports.cr_core:getServerSyntax("Phone", "error")

                                            outputChatBox(syntax .. "Nincs elég pénz a kártyádon az üzenet elküldéséhez.", 255, 0, 0, true)
                                            return
                                        end
                                    end
                                end

                                triggerServerEvent("phone.addNewSMS", localPlayer, phoneData.myCallNumber, phoneNumber, text)

                                lastInteraction = getTickCount()
                            end
                        elseif availablePages[selectedPage] == "viewMessages" then 
                            if backArrowIconHover then 
                                manageTextbars("destroy")

                                selectedPage = 3
                                manageTextbars("create")
                            elseif messageSendIconHover then 
                                sendNewSMS()
                            end
                        elseif availablePages[selectedPage] == "advertisement" then 
                            if backArrowIconHover then 
                                manageTextbars("destroy")
                                selectedPage = false
                            elseif checkBoxHover then 
                                phoneData.showMyNumber = not phoneData.showMyNumber
                            elseif adIconHover then 
                                if lastAdvertisement + advertisementDelay > getTickCount() then 
                                    local syntax = exports.cr_core:getServerSyntax("Phone", "error")

                                    outputChatBox(syntax .. "Csak percenként hirdethetsz.", 255, 0, 0, true)
                                    return
                                end

                                local currentText = GetText("phone.advertisementText")
                                local text = currentText == "Szöveg írása..." and "" or currentText

                                local textLength = utf8.len(text)
                                if textLength < 5 then 
                                    local syntax = exports.cr_core:getServerSyntax("Phone", "error")

                                    outputChatBox(syntax .. "A hirdetés szövegének minimum 5 karaktert kell tartalmaznia.", 255, 0, 0, true)
                                    return
                                end

                                if textLength > 80 then 
                                    local syntax = exports.cr_core:getServerSyntax("Phone", "error")

                                    outputChatBox(syntax .. "A hirdetés szövege maximum 80 karakter hosszú lehet.", 255, 0, 0, true)
                                    return
                                end

                                local advertisementCost = math.ceil(textLength * advertisementMultiplier)

                                if phoneData.wallet - advertisementCost >= 0 then 
                                    phoneData.wallet = phoneData.wallet - advertisementCost

                                    local players = {}
                                    local allPlayers = getElementsByType("player")

                                    for i = 1, #allPlayers do 
                                        local v = allPlayers[i]

                                        if v:getData("loggedIn") then 
                                            table.insert(players, v)
                                        end
                                    end

                                    local syntax = exports.cr_core:getServerSyntax("Phone", "success")
                                    local hexColor = exports.cr_core:getServerColor("yellow", true)

                                    outputChatBox(syntax .. "Sikeres hirdetés! A következő összeg levonásra került a kártyádról: " .. hexColor .. "$" .. advertisementCost, 255, 0, 0, true)

                                    triggerServerEvent("phone.advertisement", localPlayer, currentText, phoneData.myCallNumber, phoneData.showMyNumber, players)
                                    exports.cr_inventory:updateItemDetails(localPlayer, currentPhoneSlot, 1, {"nbt", phoneData}, true)

                                    lastAdvertisement = getTickCount()
                                else
                                    local syntax = exports.cr_core:getServerSyntax("Phone", "error")
                                    local hexColor = exports.cr_core:getServerColor("yellow", true)

                                    outputChatBox(syntax .. "Nincs elég pénz a kártyádon a hirdetéshez. " .. hexColor .. "($" .. advertisementCost .. ")", 255, 0, 0, true)
                                end
                            end
                        elseif availablePages[selectedPage] == "contacts" then 
                            if backArrowIconHover then 
                                manageTextbars("destroy")
                                selectedPage = false
                            elseif addIconHover then 
                                manageTextbars("destroy")
                                selectedPage = 21
                                manageTextbars("create")
                            elseif hoverCallIcon then 
                                if callIcons[hoverCallIcon].name == "Gombok" then 
                                    manageTextbars("destroy")
                                    selectedPage = 1
                                    manageTextbars("create")

                                    addEventHandler("onClientCharacter", root, onCharacter)
                                elseif callIcons[hoverCallIcon].name == "Előzmények" then
                                    manageTextbars("destroy")
                                    selectedPage = 22
                                    manageTextbars("create")
                                end
                            elseif iconActionHover then 
                                local splittedTable = split(iconActionHover, ":")
                                
                                if splittedTable[1] == "callFromContacts" then 
                                    if lastInteraction + interactionDelayTime > getTickCount() then 
                                        return
                                    end

                                    local index = tonumber(splittedTable[2])
                                    local hoverData = phoneData.contacts[index]

                                    if hoverData.phoneNumber == phoneData.myCallNumber then 
                                        local syntax = exports.cr_core:getServerSyntax("Phone", "error")

                                        outputChatBox(syntax .. "Saját magadat nem hívhatod fel!", 255, 0, 0, true)
                                        return
                                    end

                                    local service = phoneData.service

                                    if shopTypes[service] then 
                                        local shopData = shopTypes[service]

                                        if tonumber(hoverData.phoneNumber) and tonumber(hoverData.phoneNumber) <= 0 then 
                                            local syntax = exports.cr_core:getServerSyntax("Phone", "error")
                            
                                            outputChatBox(syntax .. "Ezen a számon előfizető nem kapcsolható.", 255, 0, 0, true)
                                            return
                                        end

                                        if phoneData.wallet - shopData.pricePerCall >= 0 then 
                                            triggerServerEvent("phone.startCall", localPlayer, phoneData.myCallNumber, hoverData.phoneNumber)
                                        else 
                                            local syntax = exports.cr_core:getServerSyntax("Phone", "error")

                                            outputChatBox(syntax .. "Nincs elég pénzed a hívás megkezdéséhez.", 255, 0, 0, true)
                                        end
                                    end

                                    lastInteraction = getTickCount()
                                elseif splittedTable[1] == "selectMessage" then 
                                    local index = tonumber(splittedTable[2])
                                    local hoverData = phoneData.contacts[index]
                                    
                                    if hoverData.phoneNumber == phoneData.myCallNumber then 
                                        local syntax = exports.cr_core:getServerSyntax("Phone", "error")

                                        outputChatBox(syntax .. "Saját magadnak nem küldhetsz üzenetet!", 255, 0, 0, true)
                                        return
                                    end

                                    manageTextbars("destroy")

                                    selectedMessage = hoverData.phoneNumber
                                    selectedPage = 17

                                    manageTextbars("create")
                                elseif splittedTable[1] == "editContact" then 
                                    local index = tonumber(splittedTable[2])
                                    local data = phoneData.contacts[index]

                                    if phoneContactsSearchCache then 
                                        data = phoneContactsSearchCache[index]

                                        index = data.id
                                    end

                                    if data then 
                                        if lastInteraction + interactionDelayTime > getTickCount() then 
                                            return 
                                        end

                                        local phoneNumber = data.phoneNumber

                                        if not contactEditing.isEditing then 
                                            contactEditing.isEditing = true
                                            contactEditing.selectedName = data.name
                                            contactEditing.selectedNumber = phoneNumber
                                            contactEditing.selectedKey = index

                                            if contactEditing.selectedName then 
                                                CreateNewBar("phone.editContact", {0, 0, 0, 0}, {10, contactEditing.selectedName, false, tocolor(255, 255, 255), {"SFUIDisplay-Regular", getRealFontSize(12)}, 1, "left", "top", false}, 1)
                                            end
                                        else 
                                            if contactEditing.selectedNumber ~= phoneNumber then 
                                                contactEditing.selectedName = data.name
                                                contactEditing.selectedNumber = phoneNumber
                                                contactEditing.selectedKey = index

                                                RemoveBar("phone.editContact")
                                                if contactEditing.selectedName then 
                                                    CreateNewBar("phone.editContact", {0, 0, 0, 0}, {10, contactEditing.selectedName, false, tocolor(255, 255, 255), {"SFUIDisplay-Regular", getRealFontSize(12)}, 1, "left", "top", false}, 1)
                                                end
                                            else
                                                local editedName = GetText("phone.editContact")

                                                if utf8.len(editedName) < 2 then 
                                                    return exports.cr_infobox:addBox("error", "A név túl rövid. (Minimum 2 karakter)")
                                                end

                                                phoneData.contacts[contactEditing.selectedKey].name = editedName
                                                phoneContacts[contactEditing.selectedNumber] = editedName
                                                contactEditing = {
                                                    isEditing = false,
                                                    selectedName = false,
                                                    selectedNumber = false,
                                                    selectedKey = false
                                                }

                                                RemoveBar("phone.editContact")
                                                exports.cr_infobox:addBox("success", "Sikeresen megváltoztattad a kiválasztott számhoz tartozó nevet. (" .. editedName .. ")")
                                            end
                                        end
                                    end
                                elseif splittedTable[1] == "deleteFromContacts" then 
                                    local index = tonumber(splittedTable[2])
                                    local phoneNumber = phoneData.contacts[index].phoneNumber

                                    table.remove(phoneData.contacts, index)
                                    phoneContacts[phoneNumber] = nil

                                    local syntax = exports.cr_core:getServerSyntax("Phone", "success")
                                    outputChatBox(syntax .. "Sikeresen kitörölted a névjegyek közül!", 255, 0, 0, true)
                                end
                            end
                        elseif availablePages[selectedPage] == "addNewContact" then 
                            if backArrowIconHover then
                                manageTextbars("destroy")
                                selectedPage = 6
                                manageTextbars("create")
                            elseif addIconHover then 
                                local name = GetText("phone.newContactName")
                                local phoneNumber = GetText("phone.newContactPhoneNumber")

                                if utf8.len(name) < 3 then 
                                    local syntax = exports.cr_core:getServerSyntax("Phone", "error")

                                    outputChatBox(syntax .. "A névnek minimum 3 karaktert kell tartalmaznia.", 255, 0, 0, true)
                                    return
                                end

                                if utf8.len(phoneNumber) < 10 then 
                                    local syntax = exports.cr_core:getServerSyntax("Phone", "error")

                                    outputChatBox(syntax .. "A telefonszámnak minimum 10 karaktert kell tartalmaznia.", 255, 0, 0, true)
                                    return
                                end

                                table.insert(phoneData.contacts, {
                                    name = name,
                                    phoneNumber = tonumber(phoneNumber)
                                })

                                phoneContacts[tonumber(phoneNumber)] = name

                                local syntax = exports.cr_core:getServerSyntax("Phone", "success")
                                outputChatBox(syntax .. "Sikeresen hozzáadtad a névjegyekhez!", 255, 0, 0, true)

                                manageTextbars("destroy")
                                selectedPage = 6
                                manageTextbars("create")
                            end
                        elseif availablePages[selectedPage] == "wallet" then 
                            if backArrowIconHover then 
                                selectedPage = false
                            end
                        elseif availablePages[selectedPage] == "camera" then 
                            if cameraButtonHover then 
                                local pixels = screenSource:getPixels()
                                if not pixels then
                                    local syntax = exports.cr_core:getServerSyntax("Phone", "error")

                                    outputChatBox(syntax .. "Nem sikerült lementeni a képet. Lehetséges, hogy nincs engedélyezve a képernyő feltöltés az MTA-n belül.", 255, 0, 0, true)
                                    return
                                end 

                                local realTime = getRealTime()
                                local fileName = realTime.timestamp .. ".jpeg"
                                local file = File.create("photos/" .. fileName)

                                if not file then
                                    local syntax = exports.cr_core:getServerSyntax("Phone", "error")

                                    outputChatBox(syntax .. "Nem sikerült lementeni a képet - A fájl létrehozása sikertelen.", 255, 0, 0, true)
                                    return
                                end 

                                local convertedPixels = dxConvertPixels(pixels, "jpeg")
                                
                                file:write(convertedPixels)
                                file:close()
                                
                                local syntax = exports.cr_core:getServerSyntax("Phone", "success")
                                outputChatBox(syntax .. "A kép le lett mentve. Az '<MTA elérési útvonal>/mods/deathmatch/resources/cr_phone/photos/' mappában találod " .. fileName .. " név alatt.", 255, 0, 0, true)
                            elseif selfieButtonHover then 
                                if not inSelfieMode then
                                    localPlayer:setData("forceAnimation", {"SHOP", "ROB_Loop_Threat", -1, false, true, false})

                                    inSelfieMode = true
                                else
                                    localPlayer:setData("forceAnimation", {"", ""})
                                    setCameraTarget(localPlayer)

                                    inSelfieMode = false
                                end
                            end
                        elseif availablePages[selectedPage] == "settings" then 
                            if backArrowIconHover then 
                                manageTextbars("destroy")
                                selectedPage = false
                            elseif volumeControlHover then 
                                if not volumeControlClick then 
                                    volumeControlClick = true
                                end
                            elseif toggleIconHover then 
                                phoneData.normalads = not phoneData.normalads
                            elseif settingsSelectorHover then 
                                local splittedTable = split(settingsSelectorHover, ":")

                                if splittedTable[1] == "ringtoneChange" then 
                                    manageTextbars("destroy")

                                    selectedPage = 18
                                    manageTextbars("create")
                                elseif splittedTable[1] == "wallpaperChange" then 
                                    manageTextbars("destroy")
                                    
                                    selectedPage = 19
                                    selectedWallpaper = phoneData.wallpaper
                                elseif splittedTable[1] == "lockScreenChange" then 
                                    manageTextbars("destroy")
                                    
                                    selectedPage = 20
                                    selectedLockscreen = phoneData.lockscreen
                                end
                            end
                        elseif availablePages[selectedPage] == "ringtoneSelector" then 
                            if backArrowIconHover then 
                                manageTextbars("destroy")
                                manageRingtonePreview("destroy")

                                selectedPage = switchedFromAlarm and 12 or 10
                                manageTextbars("create")

                                switchedFromAlarm = false
                            elseif ringtoneActionHover then 
                                local splittedTable = split(ringtoneActionHover, ":")
                                local index = tonumber(splittedTable[2])

                                if index then 
                                    if splittedTable[1] == "selectRingtone" then
                                        if not switchedFromAlarm then 
                                            if phoneData.ringtone ~= index then 
                                                phoneData.ringtone = index
                                            end
                                        else 
                                            selectedRingtone = index

                                            manageTextbars("destroy")
                                            selectedPage = 12
                                            manageTextbars("create")

                                            switchedFromAlarm = false
                                        end
                                    elseif splittedTable[1] == "viewRingtone" then 
                                        if currentRingtone ~= index then 
                                            manageRingtonePreview("init", index)
                                        else
                                            manageRingtonePreview("destroy")
                                        end
                                    end
                                end
                            end
                        elseif availablePages[selectedPage] == "wallpaperSelector" then 
                            if leftArrowIconHover then 
                                if selectedWallpaper - 1 > 0 then 
                                    selectedWallpaper = selectedWallpaper - 1
                                end
                            elseif rightArrowIconHover then 
                                if fileExists("files/images/wallpapers/" .. selectedWallpaper + 1 .. ".png") then 
                                    selectedWallpaper = selectedWallpaper + 1
                                end
                            elseif saveButtonHover then 
                                phoneData.wallpaper = selectedWallpaper
                                selectedWallpaper = 1

                                manageTextbars("destroy")
                                selectedPage = false
                            end
                        elseif availablePages[selectedPage] == "lockScreenSelector" then 
                            if leftArrowIconHover then 
                                if selectedLockscreen - 1 > 0 then 
                                    selectedLockscreen = selectedLockscreen - 1
                                end
                            elseif rightArrowIconHover then 
                                if fileExists("files/images/wallpapers/" .. selectedLockscreen + 1 .. ".png") then 
                                    selectedLockscreen = selectedLockscreen + 1
                                end
                            elseif saveButtonHover then 
                                phoneData.lockscreen = selectedLockscreen
                                selectedLockscreen = 1

                                manageTextbars("destroy")
                                selectedPage = false
                            end
                        elseif availablePages[selectedPage] == "calendar" then
                            if backArrowIconHover then 
                                manageTextbars("destroy")

                                selectedPage = false
                            elseif addIconHover then
                                local time = GetText("phone.calendarTime")
                                local description = GetText("phone.calendarDescription")

                                if not selectedDay then 
                                    local syntax = exports.cr_core:getServerSyntax("Phone", "error")

                                    outputChatBox(syntax .. "Nincs kiválasztva nap.", 255, 0, 0, true)
                                    return
                                end

                                if utf8.len(time) < 5 then 
                                    local syntax = exports.cr_core:getServerSyntax("Phone", "error")

                                    outputChatBox(syntax .. "Az időnek minimum 5 karaktert kell tartalmaznia.", 255, 0, 0, true)
                                    return
                                end

                                if utf8.len(description) < 5 then 
                                    local syntax = exports.cr_core:getServerSyntax("Phone", "error")

                                    outputChatBox(syntax .. "A leírásnak minimum 5 karaktert kell tartalmaznia.", 255, 0, 0, true)
                                    return
                                end

                                if not phoneData.calendar[selectedMonth] then 
                                    phoneData.calendar[selectedMonth] = {}
                                end

                                phoneData.calendar[selectedMonth][selectedDay] = {
                                    time = time,
                                    description = description
                                }

                                local syntax = exports.cr_core:getServerSyntax("Phone", "success")
                                outputChatBox(syntax .. "Sikeresen hozzáadtad a naptárhoz!", 255, 0, 0, true)
                            elseif circleHoverIcon then 
                                if selectedDay ~= circleHoverIcon then 
                                    selectedDay = circleHoverIcon
                                else
                                    selectedDay = false
                                end

                                RemoveBar("phone.calendarTime")
                                RemoveBar("phone.calendarDescription")

                                CreateNewBar("phone.calendarTime", {0, 0, 0, 0}, {18, "", false, tocolor(255, 255, 255), {"SFUIDisplay-Regular", getRealFontSize(10)}, 1, "left", "bottom", false, true}, 1)
                                CreateNewBar("phone.calendarDescription", {0, 0, 0, 0}, {18, "", false, tocolor(255, 255, 255), {"SFUIDisplay-Regular", getRealFontSize(10)}, 1, "left", "bottom", false, true}, 2)

                                if phoneData.calendar[selectedMonth] and phoneData.calendar[selectedMonth][selectedDay] then 
                                    local data = phoneData.calendar[selectedMonth][selectedDay]

                                    SetText("phone.calendarTime", data.time)
                                    SetText("phone.calendarDescription", data.description)
                                end
                            elseif leftArrowIconHover then 
                                manageTextbars("destroy")
                                manageTextbars("create")

                                if selectedDay then 
                                    selectedDay = false
                                end

                                if selectedMonth - 1 > 0 then 
                                    selectedMonth = selectedMonth - 1
                                end
                            elseif rightArrowIconHover then 
                                manageTextbars("destroy")
                                manageTextbars("create")

                                if selectedDay then 
                                    selectedDay = false
                                end

                                if selectedMonth + 1 <= #timeNames.en_US.months then 
                                    selectedMonth = selectedMonth + 1
                                end
                            end
                        elseif availablePages[selectedPage] == "clock" then
                            if availableSubPages[selectedSubPage] == "alarm" then 
                                if backArrowIconHover then 
                                    manageTextbars("destroy")
                                    manageAlarmSound("destroy", false, alarmIndexSave)
                                    selectedPage = false
                                elseif hoverClockIcon then
                                    manageTextbars("destroy")
                                    selectedSubPage = hoverClockIcon
                                    manageTextbars("create")
                                elseif toggleIconHover then
                                    phoneData.clock.alarm[toggleIconHover].status = not phoneData.clock.alarm[toggleIconHover].status
                                elseif iconActionHover then 
                                    local splittedTable = split(iconActionHover, ":")

                                    if splittedTable[1] == "deleteFromAlarms" then 
                                        local index = tonumber(splittedTable[2])

                                        if phoneData.clock.alarm[index] then 
                                            table.remove(phoneData.clock.alarm, index)
                                            table.remove(clockCopy.alarm, index)

                                            if alarmIndexSave == index then 
                                                alarmIndexSave = false
                                            end
                                        end
                                    end
                                elseif addIconHover then
                                    local time = GetText("phone.alarmTime")
                                    local name = GetText("phone.alarmName")

                                    if utf8.len(time) <= 0 then 
                                        local syntax = exports.cr_core:getServerSyntax("Phone", "error")

                                        outputChatBox(syntax .. "Az időnek minimum 1 karaktert kell tartalmaznia.", 255, 0, 0, true)
                                        return
                                    end

                                    local firstTwo = utf8.sub(time, 1, 2)

                                    if utf8.len(firstTwo) ~= 2 then 
                                        local syntax = exports.cr_core:getServerSyntax("Phone", "error")

                                        outputChatBox(syntax .. "Az idő első két számának minimum 2 karaktert kell tartalmaznia.", 255, 0, 0, true)
                                        return
                                    end

                                    local lastTwo = utf8.sub(time, 3, 4)

                                    if utf8.len(lastTwo) ~= 2 then 
                                        local syntax = exports.cr_core:getServerSyntax("Phone", "error")

                                        outputChatBox(syntax .. "Az idő utolsó két számának minimum 2 karaktert kell tartalmaznia.", 255, 0, 0, true)
                                        return
                                    end

                                    if tonumber(firstTwo) >= 24 then 
                                        local syntax = exports.cr_core:getServerSyntax("Phone", "error")

                                        outputChatBox(syntax .. "Az idő első két száma nem lehet nagyobb vagy egyenlő 24-el.", 255, 0, 0, true)
                                        return
                                    end

                                    if tonumber(lastTwo) >= 60 then 
                                        local syntax = exports.cr_core:getServerSyntax("Phone", "error")

                                        outputChatBox(syntax .. "Az idő utolsó két száma nem lehet nagyobb vagy egyenlő 60-al.", 255, 0, 0, true)
                                        return
                                    end

                                    if not selectedRingtone then 
                                        local syntax = exports.cr_core:getServerSyntax("Phone", "error")

                                        outputChatBox(syntax .. "Nincs csengőhang kiválasztva.", 255, 0, 0, true)
                                        return
                                    end

                                    local formattedTime = firstTwo .. ":" .. lastTwo

                                    if phoneAlarms[formattedTime] then 
                                        local syntax = exports.cr_core:getServerSyntax("Phone", "error")

                                        outputChatBox(syntax .. "Már van egy ébresztőd ezzel az idővel!", 255, 0, 0, true)
                                        return
                                    end

                                    if not phoneData.clock then 
                                        phoneData.clock = {}                                        
                                    end

                                    if not phoneData.clock.alarm then 
                                        phoneData.clock.alarm = {}
                                    end

                                    table.insert(phoneData.clock.alarm, {
                                        time = formattedTime,
                                        status = true,
                                        name = name,
                                        selectedRingtone = selectedRingtone
                                    })

                                    if not clockCopy.alarm then 
                                        clockCopy.alarm = {}
                                    end

                                    table.insert(clockCopy.alarm, {
                                        time = formattedTime,
                                        status = true,
                                        name = name,
                                        selectedRingtone = selectedRingtone
                                    })

                                    phoneAlarms[formattedTime] = true

                                    local syntax = exports.cr_core:getServerSyntax("Phone", "success")
                                    outputChatBox(syntax .. "Sikeresen hozzáadtad az ébresztőkhöz!", 255, 0, 0, true)
                                elseif rightArrowIconHover then
                                    local time = GetText("phone.alarmTime")
                                    local name = GetText("phone.alarmName")

                                    contentCache = {alarmTime = time, alarmName = name}

                                    manageTextbars("destroy")
                                    selectedPage = 18
                                    switchedFromAlarm = true
                                    manageTextbars("create")
                                end
                            elseif availableSubPages[selectedSubPage] == "timer" then 
                                if backArrowIconHover then 
                                    manageTextbars("destroy")
                                    selectedSubPage = 1
                                    manageTextbars("create")

                                    if timerStarted then 
                                        timerStarted = false
                                    end

                                    if isTimer(clockTimer) then 
                                        killTimer(clockTimer)
                                        clockTimer = nil
                                    end
                                elseif hoverClockIcon then
                                    manageTextbars("destroy")
                                    selectedSubPage = hoverClockIcon
                                    manageTextbars("create")
                                elseif circleActionHover then
                                    if circleActionHover == "circleButton" then 
                                        if not timerStarted then 
                                            timerStarted = true

                                            if isTimer(clockTimer) then 
                                                killTimer(clockTimer)
                                                clockTimer = nil
                                            end

                                            clockTimer = setTimer(
                                                function()
                                                    timerData.milliseconds = timerData.milliseconds + 1

                                                    if timerData.milliseconds >= 59 then 
                                                        timerData.milliseconds = 0
                                                        timerData.seconds = timerData.seconds + 1

                                                        if timerData.seconds >= 59 then 
                                                            timerData.seconds = 0
                                                            timerData.minutes = timerData.minutes + 1
                                                        end
                                                    end

                                                    timerText = ("%02d:%02d:%02d"):format(timerData.minutes, timerData.seconds, timerData.milliseconds)
                                                end, 15, 0
                                            )
                                        else 
                                            timerStarted = false

                                            if isTimer(clockTimer) then 
                                                killTimer(clockTimer)
                                                clockTimer = nil
                                            end
                                        end
                                    elseif circleActionHover == "roundCircle" then
                                        if timerText == "00:00:00" then
                                            local syntax = exports.cr_core:getServerSyntax("Phone", "error")

                                            outputChatBox(syntax .. "A köridő méréséhez indítsd el a stoppert.", 255, 0, 0, true)
                                            return
                                        end

                                        local lastIndex = #phoneData.clock.timer

                                        if lastIndex + 1 > _timerMaxLine then 
                                            phoneData.clock.timer = {}
                                        end

                                        table.insert(phoneData.clock.timer, {
                                            roundTime = timerText
                                        })

                                        timerText = "00:00:00"
                                    end
                                end
                            end
                        elseif availablePages[selectedPage] == "callHistory" then
                            if backArrowIconHover then
                                manageTextbars("destroy")
                                selectedPage = 1
                                manageTextbars("create")

                                addEventHandler("onClientCharacter", root, onCharacter)
                            elseif hoverCallIcon then 
                                if callIcons[hoverCallIcon].name == "Névjegyzék" then
                                    manageTextbars("destroy")
                                    selectedPage = 6
                                    manageTextbars("create")
                                elseif callIcons[hoverCallIcon].name == "Gombok" then
                                    manageTextbars("destroy")
                                    selectedPage = 1
                                    manageTextbars("create")

                                    addEventHandler("onClientCharacter", root, onCharacter)
                                end
                            end
                        end
                    end

                    if homeButtonHover then 
                        if availablePages[selectedPage] == "call" then 
                            removeEventHandler("onClientCharacter", root, onCharacter)
                        elseif availablePages[selectedPage] == "camera" then 
                            if isElement(screenSource) then 
                                screenSource:destroy()
                                screenSource = false
                            end

                            if inSelfieMode then 
                                localPlayer:setData("forceAnimation", {"", ""})
                                setCameraTarget(localPlayer)
                    
                                inSelfieMode = false
                            end
                        end

                        manageTextbars("destroy")

                        selectedPage = false
                        homeButtonHover = nil
                    end
                end
            else
                if lockScreenStartY and isCursorShowing() then 
                    local cursorX, cursorY = exports.cr_core:getCursorPosition()

                    if cursorY < lockScreenStartY then 
                        lockScreenStartY = false
                        lockScreenActive = false
                    end
                elseif volumeControlClick then 
                    volumeControlClick = false
                end
            end
        elseif button == "mouse_wheel_down" then
            if state and phoneHover and selectedPage then 
                scrollDown()
            end
        elseif button == "mouse_wheel_up" then
            if state and phoneHover and selectedPage then 
                scrollUP()
            end
        elseif button == "enter" then 
            if state then 
                if selectedPage then 
                    if availablePages[selectedPage] == "chat" then 
                        local activeEdit = GetActiveEdit()

                        if activeEdit and activeEdit == "phone.chat" then 
                            sendMessageInCall()
                        end
                    elseif availablePages[selectedPage] == "call" then
                        startCall()
                    elseif availablePages[selectedPage] == "viewMessages" then 
                        local activeEdit = GetActiveEdit()

                        if activeEdit and activeEdit == "viewMessages.chat" then 
                            sendNewSMS()
                        end
                    end
                end
            end
        elseif button == "backspace" then 
            if state then 
                if selectedPage and availablePages[selectedPage] == "call" then 
                    if utf8.len(callNumberText) > 0 then 
                        removeCharacterFromCallNumber()

                        if isTimer(textDeleteCheckTimer) then 
                            killTimer(textDeleteCheckTimer)
                            textDeleteCheckTimer = nil
                        end

                        if isTimer(textDeleteTimer) then 
                            killTimer(textDeleteTimer)
                            textDeleteTimer = nil
                        end

                        textDeleteCheckTimer = setTimer(
                            function()
                                if getKeyState("backspace") then 
                                    textDeleteTimer = setTimer(removeCharacterFromCallNumber, 100, 1, true)
                                end
                            end, 100, 1
                        )
                    end
                end
            else
                if selectedPage and availablePages[selectedPage] == "call" then 
                    if isTimer(textDeleteCheckTimer) then 
                        killTimer(textDeleteCheckTimer)
                        textDeleteCheckTimer = nil
                    end

                    if isTimer(textDeleteTimer) then 
                        killTimer(textDeleteTimer)
                        textDeleteTimer = nil
                    end
                end
            end
        end

        if selectedPage and availablePages[selectedPage] == "call" then 
            cancelEvent()
        end
    end
end

function startCall()
    if callData.targetNumber then 
        return
    end

    if lastInteraction + interactionDelayTime > getTickCount() then 
        return
    end

    if utf8.len(callNumberText) <= 0 then 
        local syntax = exports.cr_core:getServerSyntax("Phone", "error")

        outputChatBox(syntax .. "A hívószámnak minimum 1 karaktert kell tartalmaznia.", 255, 0, 0, true)
        return
    end

    local phoneNumber = tonumber(callNumberText)

    if factionCalls[phoneNumber] then 
        if localPlayer.interior > 0 then 
            local syntax = exports.cr_core:getServerSyntax("Phone", "error")

            outputChatBox(syntax .. "Interiorban nem tudod használni a segélyhívót.", 255, 0, 0, true)
            return
        end

        removeEventHandler("onClientCharacter", root, onCharacter)
        selectedPage = 13
        manageTextbars("destroy")

        if isTimer(callTimer) then 
            killTimer(callTimer)
            callTimer = nil
        end

        if isTimer(inCallTimer) then 
            killTimer(inCallTimer)
            inCallTimer = nil
        end

        callData = {
            targetNumber = phoneNumber,
            targetElement = false,
            phoneService = false,
            pickedUp = false,
            messages = {}
        }

        callTimer = setTimer(
            function(phoneNumber)
                manageTextbars("destroy")

                callData = {
                    targetNumber = false,
                    targetElement = false,
                    phoneService = false,
                    pickedUp = false,
                    messages = {}
                }

                calledFaction = phoneNumber
                calledFactionFrom = phoneData.myCallNumber
                selectedPage = false

                manageFactionCall("init")

                if isTimer(callTimer) then 
                    killTimer(callTimer)
                    callTimer = nil
                end

                callNumberText = ""
            end, 2000, 1, phoneNumber
        )
    else
        local service = phoneData.service

        if shopTypes[service] then 
            local shopData = shopTypes[service]

            if tonumber(callNumberText) and tonumber(callNumberText) <= 0 then 
                local syntax = exports.cr_core:getServerSyntax("Phone", "error")

                outputChatBox(syntax .. "Ezen a számon előfizető nem kapcsolható.", 255, 0, 0, true)
                return
            end

            if phoneData.wallet - shopData.pricePerCall >= 0 then 
                triggerServerEvent("phone.startCall", localPlayer, phoneData.myCallNumber, callNumberText)
            else 
                local syntax = exports.cr_core:getServerSyntax("Phone", "error")

                outputChatBox(syntax .. "Nincs elég pénzed a hívás megkezdéséhez.", 255, 0, 0, true)
            end
        end
    end

    callNumberText = ""
    lastInteraction = getTickCount()
end

function removeCharacterFromCallNumber(repeatTimer)
    callNumberText = utf8.sub(callNumberText, 1, -2)

    if repeatTimer then 
        textDeleteTimer = setTimer(removeCharacterFromCallNumber, 100, 1, repeatTimer)
    end
end

function startCallOnClient(targetNumber, targetElement, phoneService)
    manageTextbars("destroy")

    callData = {
        targetNumber = targetNumber,
        targetElement = targetElement,
        phoneService = phoneService,
        pickedUp = false,
        messages = {}
    }

    if isElement(targetElement) then 
        selectedPage = 13

        managePhone("init")

        if isTimer(callTimer) then 
            killTimer(callTimer)
            callTimer = nil
        end

        callTimer = setTimer(triggerServerEvent, 2000, 1, "phone.startCallToTarget", localPlayer, phoneData.myCallNumber, callData.targetElement, targetNumber, phoneData.ringtone, phoneData.ringtoneVolume, phoneData.service)

        if not factionCalls[tonumber(targetNumber)] then 
            local service = phoneData.service

            if service then 
                local shopData = shopTypes[service]

                if shopData then 
                    if phoneData.wallet - shopData.pricePerCall > 0 then 
                        phoneData.wallet = phoneData.wallet - shopData.pricePerCall

                        exports.cr_inventory:updateItemDetails(localPlayer, currentPhoneSlot, 1, {"nbt", phoneData}, true)
                    else
                        local syntax = exports.cr_core:getServerSyntax("Phone", "error")

                        outputChatBox(syntax .. "Nincs elég pénz a kártyádon.", 255, 0, 0, true)
                        return
                    end
                end
            end

            if isTimer(inCallTimer) then 
                killTimer(inCallTimer)
                inCallTimer = nil
            end

            inCallTimer = setTimer(
                function()
                    local service = phoneData.service

                    if service then 
                        local shopData = shopTypes[service]

                        if shopData then 
                            if phoneData.wallet - shopData.pricePerCall > 0 then 
                                phoneData.wallet = phoneData.wallet - shopData.pricePerCall

                                exports.cr_inventory:updateItemDetails(localPlayer, currentPhoneSlot, 1, {"nbt", phoneData}, true)
                            else
                                if isTimer(inCallTimer) then 
                                    killTimer(inCallTimer)
                                    inCallTimer = nil
                                end

                                phoneData.wallet = 0
                                selectedPage = false
                                manageTextbars("destroy")

                                local syntax = exports.cr_core:getServerSyntax("Phone", "error")

                                triggerServerEvent("phone.denyCall", localPlayer, callData.targetElement)
                                exports.cr_inventory:updateItemDetails(localPlayer, currentPhoneSlot, 1, {"nbt", phoneData}, true)

                                outputChatBox(syntax .. "A hívás abbamaradt, mivel elfogyott a kártyán lévő pénz.", 255, 0, 0, true)
                            end
                        end
                    end
                end, 60000, 0
            )
        end
    else
        selectedPage = 13

        if isTimer(callTimer) then 
            killTimer(callTimer)
            callTimer = nil
        end

        callTimer = setTimer(
            function()
                local syntax = exports.cr_core:getServerSyntax("Phone", "error")

                selectedPage = false
                outputChatBox(syntax .. "A hívás abbamaradt, mivel nem található előfizető a megadott számon. (A játékos nincs fent a szerveren)", 255, 0, 0, true)
            end, 5000, 1
        )
    end
end
addEvent("phone.startCallOnClient", true)
addEventHandler("phone.startCallOnClient", root, startCallOnClient)

function ringPhone(myCallNumber, sourceElement, targetNumber, phoneService)
    if checkRender("renderPhone") then  
        if phoneData.myCallNumber ~= targetNumber then 
            exports.cr_inventory:findAndUseItemByIDAndValue(15, targetNumber)
        end 
    else 
        exports.cr_inventory:findAndUseItemByIDAndValue(15, targetNumber)
    end 

    manageTextbars("destroy")

    lockScreenActive = false
    selectedPage = 14
    callData = {
        targetNumber = myCallNumber,
        targetElement = sourceElement,
        phoneService = phoneService,
        pickedUp = false,
        messages = {}
    }

    managePhone("init")
end
addEvent("phone.ring", true)
addEventHandler("phone.ring", root, ringPhone)

function acceptCall()
    selectedPage = 15

    manageTextbars("create")
end
addEvent("phone.acceptCall", true)
addEventHandler("phone.acceptCall", root, acceptCall)

function denyCall(extra)
    selectedPage = false

    if callData.targetElement then 
        callData = {
            targetNumber = false,
            targetElement = false,
            phoneService = false,
            pickedUp = false,
            messages = {}
        }

        manageTextbars("destroy")
    end

    if isTimer(inCallTimer) then 
        killTimer(inCallTimer)
        inCallTimer = nil
    end

    if extra then 
        local syntax = exports.cr_core:getServerSyntax("Phone", "error")

        outputChatBox(syntax .. "A hívás abbamaradt, mivel nem található előfizető a megadott számon. (A játékos nincs fent a szerveren)", 255, 0, 0, true)
    end
end
addEvent("phone.denyCall", true)
addEventHandler("phone.denyCall", root, denyCall)

function sendMessageInCall()
    if lastInteraction + (interactionDelayTime / 2) > getTickCount() then 
        return
    end

    local text = GetText("phone.chat")

    if utf8.len(text) <= 0 then 
        local syntax = exports.cr_core:getServerSyntax("Phone", "error")

        outputChatBox(syntax .. "Az üzenetnek minimum 1 karaktert kell tartalmaznia.", 255, 0, 0, true)
        return
    end

    table.insert(callData.messages, {
        sourceNumber = phoneData.myCallNumber,
        text = text
    })

    if #callData.messages > _chatMaxLine then 
        scrollDown()
    end

    SetText("phone.chat", "")
    triggerServerEvent("phone.sendMessageInCall", localPlayer, phoneData.myCallNumber, callData.targetElement, text)

    lastInteraction = getTickCount()
end

function receiveMessageInCall(sourceNumber, text)
    if sourceNumber and text then 
        table.insert(callData.messages, {
            sourceNumber = sourceNumber,
            text = text
        })

        if #callData.messages > _chatMaxLine then 
            local data = callData.messages

            chatMinLine = #data - (_chatMaxLine - 1)
            chatMaxLine = #data
        end
    end
end
addEvent("phone.receiveMessageInCall", true)
addEventHandler("phone.receiveMessageInCall", root, receiveMessageInCall)

function sendNewSMS()
    local text = GetText("viewMessages.chat")

    if utf8.len(text) <= 0 then 
        local syntax = exports.cr_core:getServerSyntax("Phone", "error")

        outputChatBox(syntax .. "Az üzenetnek minimum 1 karaktert kell tartalmaznia.", 255, 0, 0, true)
        return
    end

    if lastInteraction + interactionDelayTime > getTickCount() then 
        return
    end

    local service = phoneData.service

    if service then 
        local shopData = shopTypes[service]

        if tonumber(selectedMessage) and tonumber(selectedMessage) <= 0 then 
            local syntax = exports.cr_core:getServerSyntax("Phone", "error")

            outputChatBox(syntax .. "Ezen a számon előfizető nem kapcsolható.", 255, 0, 0, true)
            return
        end

        if shopData then 
            if phoneData.wallet - shopData.pricePerSms > 0 then 
                phoneData.wallet = phoneData.wallet - shopData.pricePerSms

                exports.cr_inventory:updateItemDetails(localPlayer, currentPhoneSlot, 1, {"nbt", phoneData}, true)
            else
                local syntax = exports.cr_core:getServerSyntax("Phone", "error")

                outputChatBox(syntax .. "Nincs elég pénz a kártyádon az üzenet elküldéséhez.", 255, 0, 0, true)
                return
            end
        end
    end

    triggerServerEvent("phone.addNewSMS", localPlayer, phoneData.myCallNumber, selectedMessage, text)
    SetText("viewMessages.chat", "")

    lastInteraction = getTickCount()
end

function updateMessages(phoneNumber, data)
    if checkRender("renderPhone") then 
        if phoneData.myCallNumber == phoneNumber then 
            phoneData.messages = data
            phoneMessages = {}

            for k, v in pairs(phoneData.messages) do 
                table.insert(phoneMessages, {
                    name = "Ismeretlen",
                    text = v.text,
                    phoneNumber = k
                })
            end

            table.sort(phoneMessages,
                function(a, b)
                    local sourceNumber = a.phoneNumber
                    local targetNumber = b.phoneNumber

                    local a = phoneData.messages[sourceNumber][1]
                    local b = phoneData.messages[targetNumber][1]

                    if a.sendAt and b.sendAt then 
                        return tonumber(a.sendAt) > tonumber(b.sendAt)
                    end
                end
            )

            if selectedMessage and phoneData.messages[selectedMessage] then 
                local data = phoneData.messages[selectedMessage]
                
                if #data > _viewMessagesMaxLine then 
                    viewMessagesMinLine = #data - (_viewMessagesMaxLine - 1)
                    viewMessagesMaxLine = #data
                end
            end
        end
    end
end
addEvent("phone.updateMessages", true)
addEventHandler("phone.updateMessages", root, updateMessages)

function updateCallHistory(phoneNumber, data)
    if checkRender("renderPhone") then 
        if phoneData.myCallNumber == phoneNumber then 
            phoneData.callHistory = data
            phoneCallHistory = {}

            for k, v in pairs(data) do 
                local lastInteractAt = v.lastInteractAt
                local realTime = getRealTime(lastInteractAt)
                
                local formattedYearString = ("%d.%.2d.%.2d."):format(realTime.year + 1900, realTime.month + 1, realTime.monthday)
                local formattedHourString2 = ("%02d:%02d:%02d"):format(realTime.hour, realTime.minute, realTime.second)

                local name = phoneContacts[k] or "Ismeretlen"

                table.insert(phoneCallHistory, {
                    name = name,
                    phoneNumber = k,
                    lastInteractAt = lastInteractAt,
                    formattedYearString = formattedYearString,
                    formattedHourString = formattedHourString2
                })
            end
        end
    end
end
addEvent("phone.updateCallHistory", true)
addEventHandler("phone.updateCallHistory", root, updateCallHistory)

function onPlayerAdvertisement(playerName, text, myCallNumber, showMyNumber)
    if playerName and text and myCallNumber then 
        local greenHex = exports.cr_core:getServerColor("green", true)

        local syntax = greenHex .. "HIRDETÉS: " .. white .. text .. " ((" .. playerName .. "))"
        local syntax2 = greenHex .. "ELÉRHETŐSÉG: " .. white .. formatPhoneNumber(myCallNumber)

        if showMyNumber then 
            outputChatBox(syntax, 255, 0, 0, true)
            outputChatBox(syntax2, 255, 0, 0, true)
        else
            outputChatBox(syntax, 255, 0, 0, true)
        end
    end
end
addEvent("phone.advertisement", true)
addEventHandler("phone.advertisement", root, onPlayerAdvertisement)

function manageRingtonePreview(state, index)
    if state == "init" then 
        if availableRingtones[index] then 
            if isElement(currentRingtoneElement) then 
                currentRingtoneElement:destroy()
                currentRingtoneElement = nil
            end

            local data = availableRingtones[index]
            local soundPath = data.soundPath

            if fileExists(soundPath) then 
                currentRingtoneElement = playSound(soundPath, true)
            end

            currentRingtone = index
        end
    elseif state == "destroy" then 
        if isElement(currentRingtoneElement) then 
            currentRingtoneElement:destroy()
            currentRingtoneElement = nil
        end

        currentRingtone = false
        collectgarbage("collect")
    end
end

function managePlayerRingtone(thePlayer, state, index, volumeMul)
    if state == "init" then 
        if availableRingtones[index] then 
            if isElement(ringtoneElements[thePlayer]) then 
                ringtoneElements[thePlayer]:destroy()
                ringtoneElements[thePlayer] = nil
            end

            local data = availableRingtones[index]
            local soundPath = data.soundPath

            volumeMul = volumeMul or 1
            volumeMul = math.max(0, math.min(1, volumeMul))

            if fileExists(soundPath) then 
                ringtoneElements[thePlayer] = playSound3D(soundPath, thePlayer.position, true)

                attachElements(ringtoneElements[thePlayer], thePlayer)
                setSoundVolume(ringtoneElements[thePlayer], volumeMul)
                setSoundMinDistance(ringtoneElements[thePlayer], 1)
                setSoundMaxDistance(ringtoneElements[thePlayer], 10)
            end
        end
    elseif state == "destroy" then
        if isElement(ringtoneElements[thePlayer]) then 
            ringtoneElements[thePlayer]:destroy()
            ringtoneElements[thePlayer] = nil

            collectgarbage("collect")
        end
    end
end

function manageAlarmSound(state, index, alarmIndex)
    if state == "init" then 
        if availableRingtones[index] then 
            if not checkRender("renderPhone") then 
                exports.cr_inventory:findAndUseItemByIDAndValue(15, myCallNumberSave)
            end

            if isElement(alarmSoundElement) then 
                alarmSoundElement:destroy()
                alarmSoundElement = nil
            end

            local data = availableRingtones[index]
            local soundPath = data.soundPath

            if fileExists(soundPath) then 
                alarmSoundElement = playSound(soundPath, true)

                if isTimer(alarmDestroyTimer) then 
                    killTimer(alarmDestroyTimer)
                    alarmDestroyTimer = nil
                end

                alarmDestroyTimer = setTimer(manageAlarmSound, 3000, 1, "destroy")

                setTimer(
                    function()
                        exports.cr_chat:createMessage(localPlayer, "megszólal az ébresztője.", "do")
                    end, 1000, 1
                )

                alarmIndexSave = alarmIndex
                clockCopy.alarm[alarmIndex].alreadyPlayed = true

                selectedPage = 12
                selectedSubPage = 1

                if callData.targetNumber then 
                    local syntax = exports.cr_core:getServerSyntax("Phone", "info")
                    outputChatBox(syntax .. "A hívásod abbamaradt, mivel megszólalt az egyik ébresztőd.", 255, 0, 0, true)

                    triggerServerEvent("phone.denyCall", localPlayer, callData.targetElement)
        
                    callData = {
                        targetNumber = false,
                        targetElement = false,
                        phoneService = false,
                        pickedUp = false,
                        messages = {}
                    }
                end
            end
        end
    elseif state == "destroy" then 
        if isElement(alarmSoundElement) then 
            alarmSoundElement:destroy()
            alarmSoundElement = nil
        end

        if alarmIndexSave and clockCopy.alarm[alarmIndexSave] then 
            clockCopy.alarm[alarmIndexSave].alreadyPlayed = true
        end

        collectgarbage("collect")
    end
end

function managePhoneRingSound(state, ringtoneId, ringtoneMul)
    if isElement(source) and state then 
        managePlayerRingtone(source, state, ringtoneId, ringtoneMul)
    end
end
addEvent("phone.managePhoneRingSound", true)
addEventHandler("phone.managePhoneRingSound", root, managePhoneRingSound)

function updatePhoneNbt(nbt)
    if checkRender("renderPhone") then 
        phoneData = nbt
        myCallNumberSave = phoneData.myCallNumber

        phoneMessages = {}
        phoneContacts = {}
        phoneCallHistory = {}

        local messageSave = table.copy(phoneData.messages)
        phoneData.messages = {}

        for k, v in pairs(messageSave) do
            phoneData.messages[tonumber(k)] = v

            table.insert(phoneMessages, {
                name = "Ismeretlen",
                text = v.text,
                phoneNumber = tonumber(k)
            })
        end

        table.sort(phoneMessages,
            function(a, b)
                local sourceNumber = tonumber(a.phoneNumber)
                local targetNumber = tonumber(b.phoneNumber)

                local a = phoneData.messages[sourceNumber][1]
                local b = phoneData.messages[targetNumber][1]

                if a.sendAt and b.sendAt then 
                    return tonumber(a.sendAt) > tonumber(b.sendAt)
                end
            end
        )

        if phoneData.contacts then 
            for k, v in pairs(phoneData.contacts) do 
                phoneContacts[v.phoneNumber] = v.name
            end
        end

        if phoneData.callHistory then 
            for k, v in pairs(phoneData.callHistory) do 
                local lastInteractAt = v.lastInteractAt
                local realTime = getRealTime(lastInteractAt)
                
                local formattedYearString = ("%d.%.2d.%.2d."):format(realTime.year + 1900, realTime.month + 1, realTime.monthday)
                local formattedHourString2 = ("%02d:%02d:%02d"):format(realTime.hour, realTime.minute, realTime.second)

                local name = phoneContacts[k] or "Ismeretlen"

                table.insert(phoneCallHistory, {
                    name = name,
                    phoneNumber = tonumber(k),
                    lastInteractAt = lastInteractAt,
                    formattedYearString = formattedYearString,
                    formattedHourString = formattedHourString2
                })
            end
        end
    end
end
addEvent("phone.updatePhoneNbt", true)
addEventHandler("phone.updatePhoneNbt", root, updatePhoneNbt)

function onQuit()
    managePlayerRingtone(source, "destroy")

    if callData.targetNumber and callData.targetElement == source then 
        triggerServerEvent("phone.denyCall", localPlayer, callData.targetElement, "noTrigger")

        selectedPage = false
        callData = {
            targetNumber = false,
            targetElement = false,
            phoneService = false,
            pickedUp = false,
            messages = {}
        }

        local syntax = exports.cr_core:getServerSyntax("Phone", "info")
        outputChatBox(syntax .. "A hívás abbamaradt, mivel a hívott játékos lecsatlakozott.", 255, 0, 0, true)
    end
end
addEventHandler("onClientPlayerQuit", root, onQuit)

function onCharacter(char)
    if callNumberText and keyPadIndexed[char] then 
        if utf8.len(callNumberText .. char) < maxCallNumberLength then
            callNumberText = callNumberText .. char
        end
    end
end

function scrollDown()
    if availablePages[selectedPage] == "chat" then 
        if chatMaxLine + 1 <= #callData.messages then 
            chatMinLine = chatMinLine + 1
            chatMaxLine = chatMaxLine + 1
        end
    elseif availablePages[selectedPage] == "messages" then 
        local percent = #phoneMessages

        if phoneMessagesSearchCache then 
            percent = #phoneMessagesSearchCache
        end

        if messagesMaxLine + 1 <= percent then 
            messagesMinLine = messagesMinLine + 1
            messagesMaxLine = messagesMaxLine + 1
        end
    elseif availablePages[selectedPage] == "viewMessages" then 
        if viewMessagesMaxLine + 1 <= #phoneData.messages[selectedMessage] then 
            viewMessagesMinLine = viewMessagesMinLine + 1
            viewMessagesMaxLine = viewMessagesMaxLine + 1
        end
    elseif availablePages[selectedPage] == "contacts" then 
        local percent = #phoneData.contacts

        if phoneContactsSearchCache then 
            percent = #phoneContactsSearchCache
        end

        if contactsMaxLine + 1 <= percent then 
            contactsMinLine = contactsMinLine + 1
            contactsMaxLine = contactsMaxLine + 1
        end
    elseif availablePages[selectedPage] == "callHistory" then 
        local percent = #phoneCallHistory

        if callHistorySearchCache then 
            percent = #callHistorySearchCache
        end

        if callHistoryMaxLine + 1 <= percent then 
            callHistoryMinLine = callHistoryMinLine + 1
            callHistoryMaxLine = callHistoryMaxLine + 1
        end
    elseif availablePages[selectedPage] == "settings" then 
        local percent = #availableSettings

        if settingsSearchCache then 
            percent = #settingsSearchCache
        end

        if settingsMaxLine + 1 <= percent then 
            settingsMinLine = settingsMinLine + 1
            settingsMaxLine = settingsMaxLine + 1
        end
    elseif availablePages[selectedPage] == "clock" then 
        if availableSubPages[selectedSubPage] == "alarm" then 
            local percent = #phoneData.clock.alarm

            if clockMaxLine + 1 <= percent then 
                clockMinLine = clockMinLine + 1
                clockMaxLine = clockMaxLine + 1
            end
        end
    elseif availablePages[selectedPage] == "ringtoneSelector" then 
        local percent = #availableRingtones

        if ringTonesSearchCache then 
            percent = #ringTonesSearchCache
        end

        if ringTonesMaxLine + 1 <= percent then 
            ringTonesMinLine = ringTonesMinLine + 1
            ringTonesMaxLine = ringTonesMaxLine + 1
        end
    end
end

function scrollUP()
    if availablePages[selectedPage] == "chat" then 
        if chatMinLine - 1 >= 1 then
            chatMinLine = chatMinLine - 1
            chatMaxLine = chatMaxLine - 1
        end
    elseif availablePages[selectedPage] == "messages" then 
        if messagesMinLine - 1 >= 1 then
            messagesMinLine = messagesMinLine - 1
            messagesMaxLine = messagesMaxLine - 1
        end
    elseif availablePages[selectedPage] == "viewMessages" then 
        if viewMessagesMinLine - 1 >= 1 then
            viewMessagesMinLine = viewMessagesMinLine - 1
            viewMessagesMaxLine = viewMessagesMaxLine - 1
        end
    elseif availablePages[selectedPage] == "contacts" then 
        if contactsMinLine - 1 >= 1 then
            contactsMinLine = contactsMinLine - 1
            contactsMaxLine = contactsMaxLine - 1
        end
    elseif availablePages[selectedPage] == "callHistory" then 
        if callHistoryMinLine - 1 >= 1 then
            callHistoryMinLine = callHistoryMinLine - 1
            callHistoryMaxLine = callHistoryMaxLine - 1
        end
    elseif availablePages[selectedPage] == "settings" then 
        if settingsMinLine - 1 >= 1 then
            settingsMinLine = settingsMinLine - 1
            settingsMaxLine = settingsMaxLine - 1
        end
    elseif availablePages[selectedPage] == "clock" then 
        if availableSubPages[selectedSubPage] == "alarm" then 
            if clockMinLine - 1 >= 1 then
                clockMinLine = clockMinLine - 1
                clockMaxLine = clockMaxLine - 1
            end
        end
    elseif availablePages[selectedPage] == "ringtoneSelector" then 
        if ringTonesMinLine - 1 >= 1 then
            ringTonesMinLine = ringTonesMinLine - 1
            ringTonesMaxLine = ringTonesMaxLine - 1
        end
    end
end

function resetScroll()
    chatMinLine = 1
    _chatMaxLine = 11
    chatMaxLine = _chatMaxLine

    messagesMinLine = 1
    _messagesMaxLine = 11
    messagesMaxLine = _messagesMaxLine

    viewMessagesMinLine = 1
    _viewMessagesMaxLine = 11
    viewMessagesMaxLine = _viewMessagesMaxLine

    contactsMinLine = 1
    _contactsMaxLine = 10
    contactsMaxLine = _contactsMaxLine

    settingsMinLine = 1
    _settingsMaxLine = 5
    settingsMaxLine = _settingsMaxLine

    ringTonesMinLine = 1
    _ringTonesMaxLine = 5
    ringTonesMaxLine = _ringTonesMaxLine

    callHistoryMinLine = 1
    _callHistoryMaxLine = 10
    callHistoryMaxLine = _callHistoryMaxLine

    clockMinLine = 1
    _clockMaxLine = 6
    clockMaxLine = _clockMaxLine

    timerMinLine = 1
    _timerMaxLine = 6
    timerMaxLine = _timerMaxLine
end

function callCommand(cmd)
    if localPlayer:getData("loggedIn") then 
        local hexColor = exports.cr_core:getServerColor("yellow", true)
        local data = {
            hoverText = "Segélyhívó",
            minLines = 1,
            maxLines = 10
        }

        local texts = {}

        for k, v in pairs(factionCalls) do 
            if type(v) == "table" then 
                if #v <= 0 then 
                    local factionName = v.factionName

                    if not factionName then 
                        factionName = exports.cr_dashboard:getFactionName(v.factionId)
                    end

                    table.insert(texts, {factionName, "Telefonszám: " .. hexColor .. k})
                else
                    for i = 1, #v do
                        local v2 = v[i]
    
                        local factionName = v2.factionName

                        if not factionName then 
                            factionName = exports.cr_dashboard:getFactionName(v2.factionId)
                        end

                        table.insert(texts, {factionName, "Telefonszám: " .. hexColor .. k})
                    end
                end
            end
        end

        data.texts = texts 
        exports.cr_dx:openInformationsPanel(data)
    end
end
addCommandHandler("call", callCommand, false, false)