local sql = exports.cr_mysql:getConnection(getThisResource())

local fuelPriceChangeTimer = false

addEventHandler("onResourceStart", root,
    function(startedRes)
        if getResourceName(startedRes) == "cr_mysql" then 
            sql = exports.cr_mysql:getConnection(getThisResource())
            restartResource(getThisResource())
        elseif startedRes == getThisResource() then
            loadAllFuel()
            loadAllFuelPed()
            loadAllFuelArea()
            generateFuelPrices()

            if isTimer(fuelPriceChangeTimer) then 
                killTimer(fuelPriceChangeTimer)
                fuelPriceChangeTimer = nil
            end

            fuelPriceChangeTimer = setTimer(generateFuelPrices, 30 * 60000, 0, true)
        end
    end
)

local fuelCache = {}
local fuelPedCache = {}
local fuelAreaCache = {}
local fuelPrices = {10, 5} -- petrol, diesel

function generateFuelPrices(needTrigger)
    local chance = math.random(0, 100)

    local syntax = exports.cr_core:getServerSyntax("Fuel", "info")
    local hexColor = exports.cr_core:getServerColor("yellow", true)

    if chance >= 50 then 
        local oldPetrolPrice = fuelPrices[1]
        local oldDieselPrice = fuelPrices[2]
    
        fuelPrices = {math.random(minPetrolPrice, maxPetrolPrice), math.random(minDieselPrice, maxDieselPrice)}
        
        outputChatBox(syntax .. "Az üzemanyagárak megváltoztak.", root, 255, 0, 0, true)
        outputChatBox(syntax .. "A " .. hexColor .. "benzin" .. white .. " ára mostantól " .. hexColor .. "$" .. fuelPrices[1] .. white .. ".", root, 255, 0, 0, true)
        outputChatBox(syntax .. "A " .. hexColor .. "dízel" .. white .. " ára mostantól " .. hexColor .. "$" .. fuelPrices[2] .. white .. ".", root, 255, 0, 0, true)
    else
        local fuelType = math.random(1, #fuelPrices)
        local oldPrice = fuelPrices[fuelType]
        local fuelString = fuelType == 1 and "benzin" or "dízel"

        fuelPrices[fuelType] = fuelType == 1 and math.random(minPetrolPrice, maxPetrolPrice) or math.random(minDieselPrice, maxDieselPrice)

        outputChatBox(syntax .. "Az üzemanyagárak megváltoztak.", root, 255, 0, 0, true)
        outputChatBox(syntax .. "A " .. hexColor .. fuelString .. white .. " ára mostantól " .. hexColor .. "$" .. fuelPrices[fuelType] .. white .. ".", root, 255, 0, 0, true)
    end

    if needTrigger then 
        local players = getElementsByType("player")

        triggerClientEvent(players, "fuel.requestFuelPrices", getRandomPlayer() or resourceRoot, fuelPrices)
    end
end

function loadAllFuel()
    local loaded = 0
    local startTick = getTickCount()

    dbQuery(
        function(queryHandle)
            local query, query_lines = dbPoll(queryHandle, 0)

            if query_lines > 0 then 
                Async:foreach(query,
                    function(row)
                        loaded = loaded + 1

                        loadFuel(row)
                    end,

                    function()
                        outputDebugString("@loadAllFuel: loaded " .. loaded .. " / " .. query_lines .. " fuel(s) in " .. getTickCount() - startTick .. " ms.", 0, 255, 50, 255)
                    end
                )
            end
        end, sql, "SELECT * FROM fuels"
    )
end

function loadAllFuelPed()
    local loaded = 0
    local startTick = getTickCount()

    dbQuery(
        function(queryHandle)
            local query, query_lines = dbPoll(queryHandle, 0)

            if query_lines > 0 then 
                Async:foreach(query,
                    function(row)
                        loaded = loaded + 1

                        loadFuelPed(row)
                    end,

                    function()
                        outputDebugString("@loadAllFuelPed: loaded " .. loaded .. " / " .. query_lines .. " fuel ped(s) in " .. getTickCount() - startTick .. " ms.", 0, 255, 50, 255)
                    end
                )
            end
        end, sql, "SELECT * FROM fuelpeds"
    )
end

function loadAllFuelArea()
    local loaded = 0
    local startTick = getTickCount()

    dbQuery(
        function(queryHandle)
            local query, query_lines = dbPoll(queryHandle, 0)

            if query_lines > 0 then 
                Async:foreach(query,
                    function(row)
                        loaded = loaded + 1

                        loadFuelArea(row)
                    end,

                    function()
                        outputDebugString("@loadAllFuelArea: loaded " .. loaded .. " / " .. query_lines .. " fuel area(s) in " .. getTickCount() - startTick .. " ms.", 0, 255, 50, 255)
                    end
                )
            end
        end, sql, "SELECT * FROM fuelareas"
    )
end

function loadFuel(row)
    local id = tonumber(row.id)

    local position = split(row.position, ", ")
    local rotation = split(row.rotation, ", ")

    local interior = tonumber(row.interior)
    local dimension = tonumber(row.dimension)
    local createdBy = tostring(row.createdBy)
    local createdAt = tonumber(row.createdAt)

    fuelCache[id] = {
        id = id,
        position = position,
        rotation = rotation,
        interior = interior,
        dimension = dimension,

        createdBy = createdBy,
        createdAt = createdAt
    }
end

function loadFuelPed(row)
    local id = tonumber(row.id)

    local position = split(row.position, ", ")
    local rotation = split(row.rotation, ", ")

    local interior = tonumber(row.interior)
    local dimension = tonumber(row.dimension)

    local skinId = tonumber(row.skinId)
    local name = tostring(row.name)

    local createdBy = tostring(row.createdBy)
    local createdAt = tonumber(row.createdAt)

    local pedElement = Ped(skinId, unpack(position))

    pedElement.rotation = Vector3(unpack(rotation))
    pedElement.interior = interior
    pedElement.dimension = dimension
    pedElement.frozen = true

    pedElement:setData("ped.name", name)
    pedElement:setData("ped.type", "Benzinkutas")
    pedElement:setData("fuel >> pedId", id)
    pedElement:setData("fuelPed >> createdBy", createdBy)
    pedElement:setData("fuelPed >> createdAt", createdAt)
    pedElement:setData("char >> noDamage", true)

    fuelPedCache[id] = {
        id = id,

        position = position,
        rotation = rotation,

        interior = interior,
        dimension = dimension,

        skinId = skinId,
        name = name,
        pedElement = pedElement,

        createdBy = createdBy,
        createdAt = createdAt
    }
end

function loadFuelArea(row)
    local id = tonumber(row.id)
    local position = split(row.position, ", ")

    local interior = tonumber(row.interior)
    local dimension = tonumber(row.dimension)
    local radius = tonumber(row.radius)

    local createdBy = tostring(row.createdBy)
    local createdAt = tonumber(row.createdAt)

    local colElement = createColSphere(position[1], position[2], position[3], radius)
    colElement:setData("fuel >> fuelArea", id)
    colElement:setData("fuelArea >> createdBy", createdBy)
    colElement:setData("fuelArea >> createdAt", createdAt)

    fuelAreaCache[id] = {
        colElement = colElement,
        interior = interior,
        dimension = dimension,
        radius = radius,
        createdBy = createdBy,
        createdAt = createdAt
    }
end

function requestFuelPumps(thePlayer, includePrices, includeColshape)
    local thePlayer = client or thePlayer

    if isElement(thePlayer) then 
        if includePrices then 
            local currentColshape = false

            if includeColshape then 
                for k, v in pairs(fuelAreaCache) do 
                    if isElement(v.colElement) then 
                        if isElementWithinColShape(thePlayer, v.colElement) then 
                            currentColshape = v.colElement
                            break
                        end
                    end
                end
            end

            triggerClientEvent(thePlayer, "fuel.requestFuelPumps", thePlayer, fuelCache, fuelPrices, currentColshape)
        else 
            triggerClientEvent(thePlayer, "fuel.requestFuelPumps", thePlayer, fuelCache)
        end
    end
end
addEvent("fuel.requestFuelPumps", true)
addEventHandler("fuel.requestFuelPumps", root, requestFuelPumps)

function requestCurrentColshape(thePlayer)
    local thePlayer = client or thePlayer

    if isElement(thePlayer) then 
        local currentColshape = false

        for k, v in pairs(fuelAreaCache) do 
            if isElement(v.colElement) then 
                if isElementWithinColShape(thePlayer, v.colElement) then 
                    currentColshape = v.colElement
                    break
                end
            end
        end

        triggerClientEvent(thePlayer, "fuel.requestCurrentColshape", thePlayer, currentColshape)
    end
end
addEvent("fuel.requestCurrentColshape", true)
addEventHandler("fuel.requestCurrentColshape", root, requestCurrentColshape)

function resetFuelDataForStation(stationId, positionId, players, typ)
    if isElement(client) then 
        table.insert(players, client)
        triggerLatentClientEvent(players, "fuel.resetFuelDataForStation", 50000, false, client, stationId, positionId, typ)

        client:removeData("fuelStation")
    end
end
addEvent("fuel.resetFuelDataForStation", true)
addEventHandler("fuel.resetFuelDataForStation", root, resetFuelDataForStation)

function createFuelCommand(thePlayer, cmd, rot)
    if exports.cr_permission:hasPermission(thePlayer, cmd) or exports.cr_core:getPlayerDeveloper(thePlayer) then 
        local playerX, playerY, playerZ = getElementPosition(thePlayer)
        playerZ = playerZ + 0.85

        local rotationX, rotationY, rotationZ = getElementRotation(thePlayer)

        if rot and tonumber(rot) then 
            rotationZ = rot
        end

        local concatenatedPosition = table.concat({playerX, playerY, playerZ}, ", ")
        local concatenatedRotation = table.concat({rotationX, rotationY, rotationZ}, ", ")

        local interior, dimension = thePlayer.interior, thePlayer.dimension
        local createdBy = exports.cr_admin:getAdminName(thePlayer)
        local createdAt = os.time()

        dbExec(sql, "INSERT INTO fuels SET position = ?, rotation = ?, interior = ?, dimension = ?, createdBy = ?, createdAt = ?", concatenatedPosition, concatenatedRotation, interior, dimension, createdBy, createdAt)

        dbQuery(
            function(queryHandle, thePlayer)
                local query, query_lines = dbPoll(queryHandle, 0)

                if query_lines > 0 then 
                    local row = query[1]

                    loadFuel(row)
                    triggerClientEvent(getElementsByType("player"), "fuel.loadFuelPoint", thePlayer or getRandomPlayer(), row.id, fuelCache[row.id])

                    if isElement(thePlayer) then 
                        local syntax = exports.cr_core:getServerSyntax("Fuel", "success")
                        local hexColor = exports.cr_core:getServerColor("yellow", true)

                        outputChatBox(syntax .. "Sikeresen létrehoztál egy kutat. " .. hexColor .. "(" .. row.id .. ")", thePlayer, 255, 0, 0, true)

                        local adminSyntax = exports.cr_admin:getAdminSyntax()
                        local localName = exports.cr_admin:getAdminName(thePlayer, true)

                        exports.cr_core:sendMessageToAdmin(thePlayer, adminSyntax .. hexColor .. localName .. white .. " létrehozott egy kutat. " .. hexColor .. "(" .. row.id .. ")", 3)
                    end
                end
            end, {thePlayer}, sql, "SELECT * FROM fuels WHERE createdAt = ? AND id = LAST_INSERT_ID()", createdAt
        )
    end
end
addCommandHandler("createfuel", createFuelCommand, false, false)

function createFuelPedCommand(thePlayer, cmd, skinId, ...)
    if exports.cr_permission:hasPermission(thePlayer, cmd) then 
        if not skinId or not ... then 
            local syntax = exports.cr_core:getServerSyntax(false, "yellow")

            outputChatBox(syntax .. "/" .. cmd .. " [skinId] [név]", thePlayer, 255, 0, 0, true)
            return
        end

        local skinId = tonumber(skinId)
        local name = table.concat({...}, " ")

        if not skinId then 
            local syntax = exports.cr_core:getServerSyntax("Fuel", "error")

            outputChatBox(syntax .. "Csak szám.", thePlayer, 255, 0, 0, true)
            return
        end

        local skinId = math.floor(tonumber(skinId))

        if not exports.cr_skins:isSkinValid(skinId) then 
            local syntax = exports.cr_core:getServerSyntax("Fuel", "error")

            outputChatBox(syntax .. "Hibás skin id.", thePlayer, 255, 0, 0, true)
            return
        end

        if utf8.len(name) <= 0 then 
            local syntax = exports.cr_core:getServerSyntax("Fuel", "error")

            outputChatBox(syntax .. "A névnek minimum 1 karaktert kell tartalmaznia.", thePlayer, 255, 0, 0, true)
            return
        end

        local concatenatedPosition = table.concat({getElementPosition(thePlayer)}, ", ")
        local concatenatedRotation = table.concat({getElementRotation(thePlayer)}, ", ")
        
        local interior = thePlayer.interior
        local dimension = thePlayer.dimension

        local createdBy = exports.cr_admin:getAdminName(thePlayer)
        local createdAt = os.time()

        dbExec(sql, "INSERT INTO fuelpeds SET position = ?, rotation = ?, interior = ?, dimension = ?, skinId = ?, name = ?, createdBy = ?, createdAt = ?", concatenatedPosition, concatenatedRotation, interior, dimension, skinId, name, createdBy, createdAt)

        dbQuery(
            function(queryHandle, thePlayer)
                local query, query_lines = dbPoll(queryHandle, 0)

                if query_lines > 0 then 
                    local row = query[1]

                    loadFuelPed(row)

                    if isElement(thePlayer) then 
                        local syntax = exports.cr_core:getServerSyntax("Fuel", "success")
                        local hexColor = exports.cr_core:getServerColor("yellow", true)

                        outputChatBox(syntax .. "Sikeresen létrehoztál egy benzinkutast. " .. hexColor .. "(" .. row.id .. ")", thePlayer, 255, 0, 0, true)

                        local adminSyntax = exports.cr_admin:getAdminSyntax()
                        local localName = exports.cr_admin:getAdminName(thePlayer, true)

                        exports.cr_core:sendMessageToAdmin(thePlayer, adminSyntax .. hexColor .. localName .. white .. " létrehozott egy benzinkutast. " .. hexColor .. "(" .. row.id .. ")", 3)
                    end
                end
            end, {thePlayer}, sql, "SELECT * FROM fuelpeds WHERE createdAt = ? AND id = LAST_INSERT_ID()", createdAt
        )
    end
end
addCommandHandler("createfuelped", createFuelPedCommand, false, false)

function createFuelAreaCommand(thePlayer, cmd, radius)
    if exports.cr_permission:hasPermission(thePlayer, cmd) then 
        if not radius then 
            local syntax = exports.cr_core:getServerSyntax(false, "yellow")

            outputChatBox(syntax .. "/" .. cmd .. " [radius]", thePlayer, 255, 0, 0, true)
            return
        end

        local radius = tonumber(radius)

        if not radius then 
            local syntax = exports.cr_core:getServerSyntax(false, "yellow")

            outputChatBox(syntax .. "Csak szám.", thePlayer, 255, 0, 0, true)
            return
        end

        local concatenatedPosition = table.concat({getElementPosition(thePlayer)}, ", ")
        local interior = thePlayer.interior
        local dimension = thePlayer.dimension

        local createdBy = exports.cr_admin:getAdminName(thePlayer)
        local createdAt = os.time()

        dbExec(sql, "INSERT INTO fuelareas SET position = ?, interior = ?, dimension = ?, radius = ?, createdBy = ?, createdAt = ?", concatenatedPosition, interior, dimension, radius, createdBy, createdAt)

        dbQuery(
            function(queryHandle, thePlayer)
                local query, query_lines = dbPoll(queryHandle, 0)

                if query_lines > 0 then 
                    local row = query[1]

                    loadFuelArea(row)

                    if isElement(thePlayer) then 
                        local syntax = exports.cr_core:getServerSyntax("Fuel", "success")
                        local hexColor = exports.cr_core:getServerColor("yellow", true)

                        outputChatBox(syntax .. "Sikeresen létrehoztál egy tankolási területet. " .. hexColor .. "(" .. row.id .. ")", thePlayer, 255, 0, 0, true)

                        local adminSyntax = exports.cr_admin:getAdminSyntax()
                        local localName = exports.cr_admin:getAdminName(thePlayer, true)

                        exports.cr_core:sendMessageToAdmin(thePlayer, adminSyntax .. hexColor .. localName .. white .. " létrehozott egy tankolási területet. " .. hexColor .. "(" .. row.id .. ")", 3)
                    end
                end
            end, {thePlayer}, sql, "SELECT * FROM fuelareas WHERE createdAt = ? AND id = LAST_INSERT_ID()", createdAt
        )
    end
end
addCommandHandler("createfuelarea", createFuelAreaCommand, false, false)

function deleteFuelArea(id)
    dbExec(sql, "DELETE FROM fuelareas WHERE id = ?", id)

    local data = fuelAreaCache[id]

    if isElement(data.colElement) then 
        data.colElement:destroy()
        data.colElement = nil
    end

    fuelAreaCache[id] = nil
end

function deleteFuelAreaCommand(thePlayer, cmd, id)
    if exports.cr_permission:hasPermission(thePlayer, cmd) then 
        if not id then 
            local syntax = exports.cr_core:getServerSyntax(false, "yellow")
            
            outputChatBox(syntax .. "/" .. cmd .. " [id]", thePlayer, 255, 0, 0, true)
            return
        end

        local id = tonumber(id)

        if not id then 
            local syntax = exports.cr_core:getServerSyntax(false, "yellow")

            outputChatBox(syntax .. "Csak szám.", thePlayer, 255, 0, 0, true)
            return
        end

        local id = math.floor(tonumber(id))

        if not fuelAreaCache[id] then 
            local syntax = exports.cr_core:getServerSyntax(false, "yellow")

            outputChatBox(syntax .. "Nem létezik tankolási terület ezzel az id-vel.", thePlayer, 255, 0, 0, true)
            return
        end

        deleteFuelArea(id)

        local syntax = exports.cr_core:getServerSyntax("Fuel", "success")
        local hexColor = exports.cr_core:getServerColor("yellow", true)

        outputChatBox(syntax .. "Sikeresen kitörölted a tankolási területet. " .. hexColor .. "(" .. id .. ")", thePlayer, 255, 0, 0, true)

        local adminSyntax = exports.cr_admin:getAdminSyntax()
        local localName = exports.cr_admin:getAdminName(thePlayer, true)

        exports.cr_core:sendMessageToAdmin(thePlayer, adminSyntax .. hexColor .. localName .. white .. " kitörölt egy tankolási területet. " .. hexColor .. "(" .. id .. ")", 3)
    end
end
addCommandHandler("deletefuelarea", deleteFuelAreaCommand, false, false)

function deleteFuelPed(id)
    dbExec(sql, "DELETE FROM fuelpeds WHERE id = ?", id)

    local data = fuelPedCache[id]

    if isElement(data.pedElement) then 
        data.pedElement:destroy()
        data.pedElement = nil
    end

    fuelPedCache[id] = nil
end

function deleteFuelPedCommand(thePlayer, cmd, id)
    if exports.cr_permission:hasPermission(thePlayer, cmd) then 
        if not id then 
            local syntax = exports.cr_core:getServerSyntax(false, "yellow")

            outputChatBox(syntax .. "/" .. cmd .. " [id]", thePlayer, 255, 0, 0, true)
            return
        end

        local id = tonumber(id)

        if not id then 
            local syntax = exports.cr_core:getServerSyntax("Fuel", "error")

            outputChatBox(syntax .. "Csak szám.", thePlayer, 255, 0, 0, true)
            return
        end

        if not fuelPedCache[id] then 
            local syntax = exports.cr_core:getServerSyntax("Fuel", "error")

            outputChatBox(syntax .. "Nem létezik benzinkutas ezzel az id-vel.", thePlayer, 255, 0, 0, true)
            return
        end

        deleteFuelPed(id)

        local syntax = exports.cr_core:getServerSyntax("Fuel", "success")
        local hexColor = exports.cr_core:getServerColor("yellow", true)

        outputChatBox(syntax .. "Sikeresen kitörölted a benzinkutast. " .. hexColor .. "(" .. id .. ")", thePlayer, 255, 0, 0, true)

        local adminSyntax = exports.cr_admin:getAdminSyntax()
        local localName = exports.cr_admin:getAdminName(thePlayer, true)

        exports.cr_core:sendMessageToAdmin(thePlayer, adminSyntax .. hexColor .. localName .. white .. " kitörölt egy benzinkutast. " .. hexColor .. "(" .. id .. ")", 3)
    end
end
addCommandHandler("deletefuelped", deleteFuelPedCommand, false, false)

function deleteFuel(thePlayer, id)
    dbExec(sql, "DELETE FROM fuels WHERE id = ?", id)
    triggerClientEvent(getElementsByType("player"), "fuel.deleteFuelStation", thePlayer or getRandomPlayer(), id)

    fuelCache[id] = nil
end

function deleteFuelCommand(thePlayer, cmd, id)
    if exports.cr_permission:hasPermission(thePlayer, cmd) or exports.cr_core:getPlayerDeveloper(thePlayer) then 
        if not id then 
            local syntax = exports.cr_core:getServerSyntax(false, "yellow")

            outputChatBox(syntax .. "/" .. cmd .. " [id]", thePlayer, 255, 0, 0, true)
            return
        end

        local id = tonumber(id)

        if not fuelCache[id] then 
            local syntax = exports.cr_core:getServerSyntax("Fuel", "error")

            outputChatBox(syntax .. "Nem létezik kút ezzel az id-vel.", thePlayer, 255, 0, 0, true)
            return
        end

        deleteFuel(thePlayer, id)

        local syntax = exports.cr_core:getServerSyntax("Fuel", "success")
        local hexColor = exports.cr_core:getServerColor("yellow", true)

        outputChatBox(syntax .. "Sikeresen kitörölted a kutat. " .. hexColor .. "(" .. id .. ")", thePlayer, 255, 0, 0, true)

        local adminSyntax = exports.cr_admin:getAdminSyntax()
        local localName = exports.cr_admin:getAdminName(thePlayer, true)

        exports.cr_core:sendMessageToAdmin(thePlayer, adminSyntax .. hexColor .. localName .. white .. " kitörölt egy kutat. " .. hexColor .. "(" .. id .. ")", 3)
    end
end
addCommandHandler("deletefuel", deleteFuelCommand, false, false)