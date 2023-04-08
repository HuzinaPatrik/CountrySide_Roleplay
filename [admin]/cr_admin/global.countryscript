local aTitles = {
    --[level] = "Text"
    [-2] = "RP Őr 2",
    [-1] = "RP Őr 1",
    [0] = "Játékos",
    [1] = "Ideiglenes Adminsegéd",
    [2] = "Adminsegéd",
    [3] = "Admin 1",
    [4] = "Admin 2",
    [5] = "Admin 3",
    [6] = "Admin 4",
    [7] = "Admin 5",
    [8] = "FőAdmin",
    [9] = "Admin Controller",
    [10] = "Server-Manager",
    [11] = "Fejlesztő",
    [12] = "Tulajdonos",
}

function getMaxKickCount()
    return 1
end

function getMaxBanCount()
    return 1
end

function getMaxJailCount()
    return 1
end

function getMaxRTCCount()
    return 1
end

function getMaxFuelCount()
    return 1
end

function getMaxFixCount()
    return 1
end

function getAdminTitle(e)
    local level = getAdminLevel(e)
    local title = aTitles[level] or "Ismeretlen (Jelentsd fejlesztőnek!)"
    return title
end

function getAdminLevel(e)
    local level = tonumber(getElementData(e, "admin >> level")) or 0

    return level
end 

function getAdminTitleByLevel(level)
    local title = aTitles[level] or "Ismeretlen (Jelentsd fejlesztőnek!)"
    return title
end

local aColors = {
    --[level] = {hexColor, r,g,b}
    [-6] = {"#3d7abc", 61,122,188},
    [-5] = {"#3d7abc", 61,122,188},
    [-4] = {"#3d7abc", 61,122,188},
    [-3] = {"#3d7abc", 61,122,188},
    [-2] = {"#3d7abc", 61,122,188},
    [-1] = {"#3d7abc", 61,122,188},
    [0] = {"#9c9c9c", 156,156,156},
    [1] = {"#ff66d9", 255,102,217},
    [2] = {"#ff66d9", 255,102,217},
    [3] = {"#55c371", 85,195,113},
    [4] = {"#55c371", 85,195,113},
    [5] = {"#55c371", 85,195,113},
    [6] = {"#55c371", 85,195,113},
    [7] = {"#55c371", 85,195,113},
    [8] = {"#3460e5", 52,96,229},
    [9] = {"#ffd11a", 255,209,26},
    [10] = {"#ff751a", 255,117,26},
    [11] = {"#3d7abc", 61,122,188},
    [12] = {"#ff3333", 255,51,51},
}

function getAdminColor(e, level, hexColor)
    if level then
        if hexColor then
            local color = aColors[level] or "Ismeretlen (Jelentsd fejlesztőnek!)"
            return color[1]
        else
            local level = getAdminLevel(e)
            local color = aColors[level] or "Ismeretlen (Jelentsd fejlesztőnek!)"
            return color[2], color[3], color[4]
        end
    else
        local level = getAdminLevel(e)
        if hexColor then
            local color = aColors[level] or "Ismeretlen (Jelentsd fejlesztőnek!)"
            return color[1]
        else
            local level = getAdminLevel(e)
            local color = aColors[level] or "Ismeretlen (Jelentsd fejlesztőnek!)"
            return color[2], color[3], color[4]
        end
    end
end

function getAdminColorByLevel(level, hexColor)
    if hexColor then
        local color = aColors[level] or "Ismeretlen (Jelentsd fejlesztőnek!)"
        return color[1]
    else
        local color = aColors[level] or "Ismeretlen (Jelentsd fejlesztőnek!)"
        return color[2], color[3], color[4]
    end
end

function getAdminDuty(e, ignoreAS)
    local duty = getElementData(e, "admin >> duty")
    local adminlevel = getElementData(e, "admin >> level")

    if not ignoreAS then 
        if adminlevel == 1 or adminlevel == 2 then
            duty = true
        end
    end
    
    if adminlevel == 0 then
        duty = false
    end
    
    return duty
end

function getAdminName(e, onlyAdminName)
    local name = e:getData("char >> name") or getPlayerName(e)
    name = name:gsub("_", " ")

    if e:getData("char >> customName") then 
        local gName = e:getData("char >> customName")

        name = gName:gsub("[()]", ""):gsub("#......", "")
    end

    if e:getData("admin >> duty") or onlyAdminName then
        name = e:getData("admin >> name") or name

        if tonumber(e:getData("admin >> level") or 0) < 0 then 
            name = "RP Őr"
        end 
    end

    if not name then
        name = inspect(name)
    end
    return name
end

local white = "#ffffff"

function getAdminSyntax(commandSyntax, specialColor)
    if not commandSyntax then
        commandSyntax = "Admin"
    end
    if not specialColor then
        specialColor = "red"
    end
    local hexColor = exports['cr_core']:getServerColor(specialColor, true)
    local text = hexColor.."["..commandSyntax.."] "..white
    return text
end