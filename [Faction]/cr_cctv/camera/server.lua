local shootDelayCache = {}

function getNearestCamera(thePlayer, range)
    local range = range or 30
    local sourcePosition = thePlayer.position
    local sourceInterior = thePlayer.interior
    local sourceDimension = thePlayer.dimension

    local elements = getElementsWithinRange(sourcePosition, range, "object")
    local result = false

    for i = 1, #elements do 
        local v = elements[i]

        if isElement(v) then 
            local distance = getDistanceBetweenPoints3D(sourcePosition, getElementPosition(v))

            if distance <= range then 
                if v:getData("camera >> id") then 
                    local cameraInterior = getElementInterior(v)
                    local cameraDimension = getElementDimension(v)

                    if cameraInterior == sourceInterior and cameraDimension == sourceDimension then 
                        result = v
                        break
                    end
                end
            end
        end
    end

    return result
end

function handleWeaponFire(weapon, endX, endY, endZ, hitElement, startX, startY, startZ)
    if not shootDelayCache[source] then 
        shootDelayCache[source] = 0
    end

    if getTickCount() - shootDelayCache[source] >= 10000 then 
        local result = getNearestCamera(source, 30)

        if isElement(result) then 
            local zoneName = getZoneName(result.position)
            local syntax = exports.cr_core:getServerSyntax("MDC", "error")
            local hexColor = exports.cr_core:getServerColor("yellow", true)
            local perpetrator = "Ismeretlen"
            local wantedPersons, wantedPersonsByName = exports.cr_mdc:getWantedPersons()
            local perpetratorName = exports.cr_admin:getAdminName(source)

            local reason = false

            if wantedPersonsByName[perpetratorName] then 
                perpetrator = perpetratorName

                for k, v in pairs(wantedPersons) do 
                    if v.name == perpetrator then 
                        reason = v.reason
                        break
                    end
                end
            end

            local realTime = getRealTime()
            local formattedTime = ("%d.%.2d.%.2d - %02d:%02d:%02d"):format(realTime.year + 1900, realTime.month + 1, realTime.monthday, realTime.hour, realTime.minute, realTime.second)

            exports.cr_dashboard:sendMessageToFaction(1, syntax .. "Egy térfigyelő kamera lövést észlelt.")
            exports.cr_dashboard:sendMessageToFaction(1, syntax .. "Helyszín: " .. hexColor .. zoneName)
            exports.cr_dashboard:sendMessageToFaction(1, syntax .. "Elkövető: " .. hexColor .. perpetrator .. white .. ", elkövetés ideje: " .. hexColor .. formattedTime)

            if reason then 
                exports.cr_dashboard:sendMessageToFaction(1, syntax .. "Körözés indoka: " .. hexColor .. reason)
            end
        end

        shootDelayCache[source] = getTickCount()
    end
end
addEventHandler("onPlayerWeaponFire", root, handleWeaponFire)

function handlePlayerDead()
    local result = getNearestCamera(source, 30)

    if isElement(result) then 
        local zoneName = getZoneName(result.position)
        local syntax = exports.cr_core:getServerSyntax("MDC", "error")
        local hexColor = exports.cr_core:getServerColor("yellow", true)

        local realTime = getRealTime()
        local formattedTime = ("%d.%.2d.%.2d - %02d:%02d:%02d"):format(realTime.year + 1900, realTime.month + 1, realTime.monthday, realTime.hour, realTime.minute, realTime.second)

        exports.cr_dashboard:sendMessageToFaction(1, syntax .. "Egy térfigyelő kamera gyilkosságot észlelt.")
        exports.cr_dashboard:sendMessageToFaction(1, syntax .. "Helyszín: " .. hexColor .. zoneName)
        exports.cr_dashboard:sendMessageToFaction(1, syntax .. "Halál ideje: " .. hexColor .. formattedTime)
    end
end
addEventHandler("onPlayerWasted", root, handlePlayerDead)

function onQuit()
    if shootDelayCache[source] then 
        shootDelayCache[source] = nil
    end
end
addEventHandler("onPlayerQuit", root, onQuit)