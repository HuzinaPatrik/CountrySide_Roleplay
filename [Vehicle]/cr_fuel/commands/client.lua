function getNearbyFuelStations(cmd)
    if exports.cr_permission:hasPermission(localPlayer, cmd) or exports.cr_core:getPlayerDeveloper(localPlayer) then 
        local count = 0
        local objects = getElementsByType("object", resourceRoot, true)
        local syntax = exports.cr_core:getServerSyntax("Fuel", "info")

        local hexColor = exports.cr_core:getServerColor("yellow", true)
        local position = localPlayer.position

        for i = 1, #objects do 
            local v = objects[i]
            local id = v:getData("fuel >> id")

            if id then 
                local distance = getDistanceBetweenPoints3D(position, v.position)

                if distance <= maxDistance then 
                    local createdBy = v:getData("fuel >> createdBy")
                    local createdAt = v:getData("fuel >> createdAt")

                    local realTime = getRealTime(createdAt)
                    local formattedString = ("%i.%.2i.%.2i - %.2i:%.2i:%.2i"):format(realTime.year + 1900, realTime.month + 1, realTime.monthday, realTime.hour, realTime.minute, realTime.second)

                    outputChatBox(syntax .. "ID: " .. hexColor .. id .. white .. ", távolság: " .. hexColor .. math.floor(distance) .. white .. " yard.", 255, 0, 0, true)
                    outputChatBox(syntax .. "Létrehozta: " .. hexColor .. createdBy .. white .. ", ekkor: " .. hexColor .. formattedString, 255, 0, 0, true)

                    count = count + 1
                end
            end
        end

        if count == 0 then 
            outputChatBox(syntax .. "Nem található benzinkút " .. hexColor .. maxDistance .. white .. " yardos körzetben.", 255, 0, 0, true)
        end
    end
end
addCommandHandler("nearbyfuels", getNearbyFuelStations, false, false)

function getNearbyFuelPeds(cmd)
    if exports.cr_permission:hasPermission(localPlayer, cmd) or exports.cr_core:getPlayerDeveloper(localPlayer) then 
        local count = 0
        local peds = getElementsByType("ped", resourceRoot, true)
        local syntax = exports.cr_core:getServerSyntax("Fuel", "info")

        local hexColor = exports.cr_core:getServerColor("yellow", true)
        local position = localPlayer.position

        for i = 1, #peds do 
            local v = peds[i]
            local id = v:getData("fuel >> pedId")

            if id then 
                local distance = getDistanceBetweenPoints3D(position, v.position)

                if distance <= maxDistance then 
                    local createdBy = v:getData("fuelPed >> createdBy")
                    local createdAt = v:getData("fuelPed >> createdAt")
                    local pedName = v:getData("ped.name")

                    local realTime = getRealTime(createdAt)
                    local formattedString = ("%i.%.2i.%.2i - %.2i:%.2i:%.2i"):format(realTime.year + 1900, realTime.month + 1, realTime.monthday, realTime.hour, realTime.minute, realTime.second)

                    outputChatBox(syntax .. "ID: " .. hexColor .. id .. white .. ", távolság: " .. hexColor .. math.floor(distance) .. white .. " yard. Név: " .. hexColor .. pedName:gsub("_", " "), 255, 0, 0, true)
                    outputChatBox(syntax .. "Létrehozta: " .. hexColor .. createdBy .. white .. ", ekkor: " .. hexColor .. formattedString, 255, 0, 0, true)

                    count = count + 1
                end
            end
        end

        if count == 0 then 
            outputChatBox(syntax .. "Nem található benzinkutas " .. hexColor .. maxDistance .. white .. " yardos körzetben.", 255, 0, 0, true)
        end
    end
end
addCommandHandler("nearbyfuelpeds", getNearbyFuelPeds, false, false)

function getNearbyFuelAreas(cmd)
    if exports.cr_permission:hasPermission(localPlayer, cmd) or exports.cr_core:getPlayerDeveloper(localPlayer) then 
        local count = 0
        local fuelAreas = getElementsByType("colshape", resourceRoot, true)
        local syntax = exports.cr_core:getServerSyntax("Fuel", "info")

        local hexColor = exports.cr_core:getServerColor("yellow", true)
        local position = localPlayer.position

        for i = 1, #fuelAreas do 
            local v = fuelAreas[i]
            local id = v:getData("fuel >> fuelArea")

            if id then 
                local distance = getDistanceBetweenPoints3D(position, v.position)

                if distance <= maxDistance then 
                    local createdBy = v:getData("fuelArea >> createdBy")
                    local createdAt = v:getData("fuelArea >> createdAt")

                    local realTime = getRealTime(createdAt)
                    local formattedString = ("%i.%.2i.%.2i - %.2i:%.2i:%.2i"):format(realTime.year + 1900, realTime.month + 1, realTime.monthday, realTime.hour, realTime.minute, realTime.second)

                    outputChatBox(syntax .. "ID: " .. hexColor .. id .. white .. ", távolság: " .. hexColor .. math.floor(distance) .. white .. " yard.", 255, 0, 0, true)
                    outputChatBox(syntax .. "Létrehozta: " .. hexColor .. createdBy .. white .. ", ekkor: " .. hexColor .. formattedString, 255, 0, 0, true)

                    count = count + 1
                end
            end
        end

        if count == 0 then 
            outputChatBox(syntax .. "Nem található tankolási terület " .. hexColor .. maxDistance .. white .. " yardos körzetben.", 255, 0, 0, true)
        end
    end
end
addCommandHandler("nearbyfuelareas", getNearbyFuelAreas, false, false)