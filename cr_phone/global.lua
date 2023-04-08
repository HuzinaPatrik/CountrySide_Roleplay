applications = {
    dockbar = {
        {
            textureName = "call",
            path = ":cr_phone/files/images/dockbar/call.png",
        },

        {
            textureName = "safari",
            path = ":cr_phone/files/images/dockbar/safari.png"
        },

        {
            textureName = "messages",
            path = ":cr_phone/files/images/dockbar/messages.png"
        },

        {
            textureName = "music",
            path = ":cr_phone/files/images/dockbar/music.png"
        }
    },

    normal = {
        {
            textureName = "ad",
            path = ":cr_phone/files/images/apps/ad.png",
            name = "Hirdetés"
        },

        {
            textureName = "contacts",
            path = ":cr_phone/files/images/apps/contacts.png",
            name = "Névjegyzék"
        },

        {
            textureName = "wallet",
            path = ":cr_phone/files/images/apps/wallet.png",
            name = "Egyenleg"
        },

        {
            textureName = "camera",
            path = ":cr_phone/files/images/apps/camera.png",
            name = "Kamera"
        },

        {
            textureName = "gallery",
            path = ":cr_phone/files/images/apps/gallery.png",
            name = "Galéria"
        },

        {
            textureName = "settings",
            path = ":cr_phone/files/images/apps/settings.png",
            name = "Beállítások"
        },

        {
            textureName = "calendar",
            path = ":cr_phone/files/images/apps/calendar.png",
            name = "Naptár"
        },

        {
            textureName = "clock",
            path = ":cr_phone/files/images/apps/clock.png",
            name = "Óra"
        }
    }
}

callIcons = {
    {
        path = ":cr_phone/files/images/call/favorites.png",
        name = "Kedvencek"
    },

    {
        path = ":cr_phone/files/images/call/history.png",
        name = "Előzmények"
    },

    {
        path = ":cr_phone/files/images/call/contacts.png",
        name = "Névjegyzék"    
    },

    {
        path = ":cr_phone/files/images/call/buttons.png",
        name = "Gombok"
    },

    {
        path = ":cr_phone/files/images/call/voicemail.png",
        name = "Hangposta"
    }
}

clockIcons = {
    {
        path = ":cr_phone/files/images/call/history.png",
        name = "Ébresztő"
    },

    {
        path = ":cr_phone/files/images/clock/timer.png",
        name = "Stopper"
    }
}

keyPad = {"1", "2", "3", "4", "5", "6", "7", "8", "9", "*", "0", "#"}
keyPadIndexed = {}

for k, v in pairs(keyPad) do 
    keyPadIndexed[v] = true
end

availablePages = {"call", "safari", "messages", "music", "advertisement", "contacts", "wallet", "camera", "gallery", "settings", "calendar", "clock", "outgoingcall", "incomingcall", "chat", "addNewMessage", "viewMessages", "ringtoneSelector", "wallpaperSelector", "lockScreenSelector", "addNewContact", "callHistory"}
availableSubPages = {"alarm", "timer"}
notAvailablePages = {safari = true, music = true, gallery = true}
selectedPage = false
selectedSubPage = 1

availableSettings = {
    {
        iconPath = ":cr_phone/files/images/settings/wallpaper.png",
        iconId = 1,
        typ = "toggle",
        visibleName = "Hirdetések"
    },

    {
        iconPath = ":cr_phone/files/images/settings/wallpaper.png",
        iconId = 1,
        typ = "selector",
        name = "wallpaperChange",
        visibleName = "Háttérkép csere"
    },

    {
        iconPath = ":cr_phone/files/images/settings/wallpaper.png",
        iconId = 1,
        typ = "selector",
        name = "lockScreenChange",
        visibleName = "Zárolási kép csere"
    },

    {
        iconPath = ":cr_phone/files/images/settings/ringtone.png",
        iconId = 2,
        typ = "selector",
        name = "ringtoneChange",
        visibleName = "Csengőhang"
    },

    {
        iconPath = ":cr_phone/files/images/settings/ringtone.png",
        iconId = 2,
        typ = "slider",
        visibleName = "Csengőhang hangerő"
    }
}

availableRingtones = {
    {
        soundPath = "files/sounds/ringtones/1.mp3",
        ringToneId = 1,
        name = "Csengőhang 1"
    },

    {
        soundPath = "files/sounds/ringtones/2.ogg",
        ringToneId = 2,
        name = "Csengőhang 2"
    },

    {
        soundPath = "",
        ringToneId = 3,
        name = "Csengőhang 3"
    },

    {
        soundPath = "",
        ringToneId = 4,
        name = "Csengőhang 4"
    },

    {
        soundPath = "",
        ringToneId = 5,
        name = "Csengőhang 5"
    }
}

availableWallpapers = {":cr_phone/files/images/wallpapers/1.png", ":cr_phone/files/images/wallpapers/2.png", ":cr_phone/files/images/wallpapers/3.png", ":cr_phone/files/images/wallpapers/4.png", ":cr_phone/files/images/wallpapers/5.png"}
availableLockscreens = {":cr_phone/files/images/lockscreens/1.png", ":cr_phone/files/images/lockscreens/2.png"}

maxAppInARow = 4
maxAppInAColumn = 4
maxCallNumberLength = 15

maxDayInARow = 7
maxDayInAColumn = 7

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

white = "#ffffff"

shopTypes = {
    ["Blue Wireless"] = {
        numberPrefix = 212,
        pricePerCall = 5,
        pricePerSms = 3,
        servicePrice = 200,
    },
    
    ["Chat Mobility"] = {
        numberPrefix = 305,
        pricePerCall = 3,
        pricePerSms = 5,
        servicePrice = 250,
    },

    ["United Wireless"] = {
        numberPrefix = 646,
        pricePerCall = 4,
        pricePerSms = 4,
        servicePrice = 300,
    }
}

factionCalls = {
    [911] = {
        {
            factionId = 1,
            name = "LSSD",
            factionName = "Red County Sheriff Department",
            commandName = "acceptsheriff @A",
            dispatchColor = "#49A64C"
        },

        {
            factionId = 2,
            name = "RCMD",
            factionName = "Red County Medical Department",
            commandName = "acceptmedic @A",
            dispatchColor = "red"
        }
    },

    [122] = {
        factionId = 5,
        name = "Taxi",
        factionName = "Red County Taxi",
        commandName = "accepttaxi @A",
        dispatchColor = "#f48942",
    },

    [555] = {
        factionId = 3,
        name = "Mechanic",
        factionName = "Red County Mechanic Service",
        commandName = "acceptmechanic @A",
        dispatchColor = "blue",
    },

    -- [122] = { -- taxi
    --     factionId = 12,
    --     name = "Los Santos Taxi Co",
    --     number = 122,
    --     canReceiveCalls = true,
    --     customColor = "lightyellow",
    --     prefix = "Taxi"
    -- },

    -- [133] = { -- lsmc
    --     factionId = 13,
    --     name = "Los Santos Medical Center",
    --     number = 133,
    --     canReceiveCalls = true,
    --     customColor = "red",
    --     prefix = "Medic"
    -- }
}

factionCallsByFactionId = {
    -- [fraki id] = telefonszám
    [2] = 911,
    [12] = 122,
    [13] = 133
}

function getFactionCalls()
    return factionCalls
end

function convertFactionToCallNumber(number)
    if factionCallsByFactionId[number] then 
        return factionCallsByFactionId[number]
    end

    return 0
end

function getShopDatas(shop)
    if shopTypes[shop] then 
        return shop, shopTypes[shop]
    end

    return false
end

function getAvailableShops()
    return shopTypes
end

timeNames = {
    weeks = {
        [0] = "Vasárnap",
        [1] = "Hétfő",
        [2] = "Kedd",
        [3] = "Szerda",
        [4] = "Csütörtök",
        [5] = "Péntek",
        [6] = "Szombat"
    },

    months = {
        [0] = "Január",
        [1] = "Február",
        [2] = "Március",
        [3] = "Április",
        [4] = "Május",
        [5] = "Június",
        [6] = "Július",
        [7] = "Augusztus",
        [8] = "Szeptember",
        [9] = "Október",
        [10] = "November",
        [11] = "December"
    },

    en_US = {
        months = {
            [1] = "J A N U A R Y",
            [2] = "F E B R U A R Y",
            [3] = "M A R C H",
            [4] = "A P R I L",
            [5] = "M A Y",
            [6] = "J U N E",
            [7] = "J U L Y",
            [8] = "A U G U S T",
            [9] = "S E P T E M B E R",
            [10] = "O C T O B E R",
            [11] = "N O V E M B E R",
            [12] = "D E C E M B E R"
        },

        days = {"Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"}
    }
}

months = { 
    [1] = 31, 
    [2] = 28, 
    [3] = 31, 
    [4] = 30, 
    [5] = 31, 
    [6] = 30, 
    [7] = 31, 
    [8] = 31, 
    [9] = 30, 
    [10] = 31, 
    [11] = 30, 
    [12] = 31
}

function isLeapYear(year) 
    if ((year % 4 == 0) and (year % 100 ~= 0)) or (year % 400 == 0) then 
        return true 
    end 

    return false 
end

function getMonthMaxDays(month, year) 
    if months[month] then 
        if month == 2 and isLeapYear(year) then 
            return 29 
        else 
            return months[month] 
        end 
    end 

    return false 
end 

function table.copy(array)
    local tbl = {}

    for k, v in pairs(array) do 
        if type(v) == "table" then 
            tbl[k] = table.copy(v)
        else
            tbl[k] = v
        end
    end

    return tbl
end

function formatPhoneNumber(num)
    if num and tonumber(num) and #tostring(num) >= 1 then 
        local num = tostring(tonumber(num))
        local formattedString = "(" .. num:sub(1, 3) .. ") "
        
        if num == "Ismeretlen" then 
            return "Ismeretlen"
        end

        if num:len() > 0 then 
            if num:sub(4, 6):len() > 0 then 
                formattedString = formattedString .. num:sub(4, 6) 
            end

            if num:sub(7, 11):len() > 0 then 
                formattedString = formattedString .. "-" .. num:sub(7, 11)
            end
        end

        return (num:len() > 0 and formattedString or "")
    end 

    return ""
end

function rotateAround(angle, x, y, x2, y2)
    local targetX = x2 or 0
    local targetY = y2 or 0
    local centerX = x
    local centerY = y

    local radians = math.rad(angle)
    local rotatedX = targetX + (centerX - targetX) * math.cos(radians) - (centerY - targetY) * math.sin(radians)
    local rotatedY = targetY + (centerX - targetX) * math.sin(radians) + (centerY - targetY) * math.cos(radians)

    return rotatedX, rotatedY
end