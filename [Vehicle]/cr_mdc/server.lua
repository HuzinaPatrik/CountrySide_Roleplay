sql = exports["cr_mysql"]:getConnection(getThisResource())
addEventHandler("onResourceStart", root,
    function(startedRes)
        if getResourceName(startedRes) == "cr_mysql" then 
            sql = exports["cr_mysql"]:getConnection(getThisResource())
            restartResource(getThisResource())
        elseif startedRes == getThisResource() then 
            loadAllAccounts()
            loadAllWantedCars()
            loadAllWantedPersons()
            loadAllTickets()
            loadAllWantedWeapons()
            loadAllRegisteredWeapons()
            loadAllRegisteredVehicles()
            loadAllRegisteredAddresses()
            loadAllRegisteredTraffices()
            loadAllLogs()
        end
    end
)

salt = ")x1%e(I|}C666'!|"
white = "#ffffff"

mdcAccounts = {}
mdcWantedCars = {}
mdcWantedPersons = {}
mdcTickets = {}
mdcWantedWeapons = {}
mdcRegisteredWeapons = {}
mdcRegisteredVehicles = {}
mdcRegisteredAddresses = {}
mdcRegisteredTraffices = {}
mdcLogs = {}

mdcViewers = {}
mdcViewersElementCache = {}
mdcActiveUnits = {}
mdcLoggedAccounts = {}
mdcLoginCount = 0

mdcWantedPersonsByName = {}
mdcWantedVehiclesByPlateText = {}

local maxLogs = 250

function stringToBoolean(str)
    if str == "true" then 
        return true
    end

    return false
end

function loadAccount(row)
    local id = tonumber(row.id)
    local username = tostring(row.username)
    local password = tostring(row.password)
    local faction = tonumber(row.faction)
    local leader = stringToBoolean(tostring(row.leader))
    local online = stringToBoolean(tostring(row.online))

    mdcAccounts[username] = {
        id = id,
        password = password,
        faction = faction,
        leader = leader,
        online = online
    }
end

function loadAllAccounts()
    local loaded = 0
    local startTick = getTickCount()

    dbQuery(
        function(query)
            local query, query_lines = dbPoll(query, 0)

            if query_lines > 0 then 
                Async:foreach(query,
                    function(row)
                        loaded = loaded + 1

                        loadAccount(row)
                    end,

                    function()
                        updateAccountOnlineStates()
                        outputDebugString("@loadAllAccounts: loaded " .. loaded .. " / " .. query_lines .. " account(s) in " .. getTickCount() - startTick .. " ms.", 0, 255, 50, 255)
                    end
                )
            end
        end, sql, "SELECT * FROM mdcaccounts"
    )
end

function loadWantedCar(row)
    local id = tonumber(row.id)
    local vehicleType = tostring(row.vehicleType)
    local vehiclePlateText = tostring(row.vehiclePlateText)
    local reason = tostring(row.reason)

    table.insert(mdcWantedCars, 1, {
        id = id,
        vehicleType = vehicleType,
        vehiclePlateText = vehiclePlateText,
        reason = reason
    })

    mdcWantedVehiclesByPlateText[vehiclePlateText] = true
end

function loadAllWantedCars()
    local loaded = 0
    local startTick = getTickCount()

    dbQuery(
        function(queryHandle)
            local query, query_lines = dbPoll(queryHandle, 0)

            if query_lines > 0 then 
                Async:foreach(query,
                    function(row)
                        loaded = loaded + 1

                        loadWantedCar(row)
                    end,

                    function()
                        outputDebugString("@loadAllWantedCars: loaded " .. loaded .. " / " .. query_lines .. " wantedCar(s) in " .. getTickCount() - startTick .. " ms.", 0, 255, 50, 255)
                    end
                )
            end
        end, sql, "SELECT * FROM mdcWantedCars"
    )
end

function loadWantedPerson(row)
    local id = tonumber(row.id)
    local name = tostring(row.name)
    local nationality = tostring(row.nationality)
    local description = tostring(row.description)
    local reason = tostring(row.reason)

    table.insert(mdcWantedPersons, 1, {
        id = id,
        name = name,
        nationality = nationality,
        description = description,
        reason = reason
    })

    mdcWantedPersonsByName[name] = true
end

function loadAllWantedPersons()
    local loaded = 0
    local startTick = getTickCount()

    dbQuery(
        function(queryHandle)
            local query, query_lines = dbPoll(queryHandle, 0)

            if query_lines > 0 then 
                Async:foreach(query,
                    function(row)
                        loaded = loaded + 1

                        loadWantedPerson(row)
                    end,

                    function()
                        outputDebugString("@loadAllWantedPersons: loaded " .. loaded .. " / " .. query_lines .. " wantedPerson(s) in " .. getTickCount() - startTick .. " ms.", 0, 255, 50, 255)
                    end
                )
            end
        end, sql, "SELECT * FROM mdcWantedPersons"
    )
end

function loadTicket(row)
    local id = tonumber(row.id)
    local name = tostring(row.name)
    local jailTime = tonumber(row.jailTime)
    local penalty = tonumber(row.penalty)
    local reason = tostring(row.reason)

    table.insert(mdcTickets, 1, {
        id = id,
        name = name,
        jailTime = jailTime,
        penalty = penalty,
        reason = reason
    })
end

function loadAllTickets()
    local loaded = 0
    local startTick = getTickCount()

    dbQuery(
        function(queryHandle)
            local query, query_lines = dbPoll(queryHandle, 0)

            if query_lines > 0 then 
                Async:foreach(query,
                    function(row)
                        loaded = loaded + 1

                        loadTicket(row)
                    end,

                    function()
                        outputDebugString("@loadAllTickets: loaded " .. loaded .. " / " .. query_lines .. " ticket(s) in " .. getTickCount() - startTick .. " ms.", 0, 255, 50, 255)
                    end
                )
            end
        end, sql, "SELECT * FROM mdcTickets"
    )
end

function loadWantedWeapon(row)
    local id = tonumber(row.id)
    local weaponName = tostring(row.weaponName)
    local weaponType = tostring(row.weaponType)
    local weaponSerial = tostring(row.weaponSerial)
    local reason = tostring(row.reason)

    table.insert(mdcWantedWeapons, 1, {
        id = id,
        weaponName = weaponName,
        weaponType = weaponType,
        weaponSerial = weaponSerial,
        reason = reason
    })
end

function loadAllWantedWeapons()
    local loaded = 0
    local startTick = getTickCount()

    dbQuery(
        function(queryHandle)
            local query, query_lines = dbPoll(queryHandle, 0)

            if query_lines > 0 then 
                Async:foreach(query,
                    function(row)
                        loaded = loaded + 1

                        loadWantedWeapon(row)
                    end,

                    function()
                        outputDebugString("@loadAllWantedWeapons: loaded " .. loaded .. " / " .. query_lines .. " wantedWeapon(s) in " .. getTickCount() - startTick .. " ms.", 0, 255, 50, 255)
                    end
                )
            end
        end, sql, "SELECT * FROM mdcWantedWeapons"
    )
end

function loadRegisteredWeapon(row)
    local id = tonumber(row.id)
    local ownerName = tostring(row.ownerName)
    local weaponType = tostring(row.weaponType)
    local weaponSerial = tostring(row.weaponSerial)

    table.insert(mdcRegisteredWeapons, 1, {
        id = id,
        ownerName = ownerName,
        weaponType = weaponType,
        weaponSerial = weaponSerial
    })
end

function loadAllRegisteredWeapons()
    local loaded = 0
    local startTick = getTickCount()

    dbQuery(
        function(queryHandle)
            local query, query_lines = dbPoll(queryHandle, 0)

            if query_lines > 0 then 
                Async:foreach(query,
                    function(row)
                        loaded = loaded + 1

                        loadRegisteredWeapon(row)
                    end,

                    function()
                        outputDebugString("@loadAllRegisteredWeapons: loaded " .. loaded .. " / " .. query_lines .. " registered weapon(s) in " .. getTickCount() - startTick .. " ms.", 0, 255, 50, 255)
                    end
                )
            end
        end, sql, "SELECT * FROM mdcRegisteredWeapons"
    )
end

function loadRegisteredVehicle(row)
    local id = tonumber(row.id)
    local ownerName = tostring(row.ownerName)
    local vehicleType = tostring(row.vehicleType)
    local vehiclePlateText = tostring(row.vehiclePlateText)
    local vehicleChassis = tostring(row.vehicleChassis)

    table.insert(mdcRegisteredVehicles, 1, {
        id = id,
        ownerName = ownerName,
        vehicleType = vehicleType,
        vehiclePlateText = vehiclePlateText,
        vehicleChassis = vehicleChassis
    })
end

function loadAllRegisteredVehicles()
    local loaded = 0
    local startTick = getTickCount()

    dbQuery(
        function(queryHandle)
            local query, query_lines = dbPoll(queryHandle, 0)

            if query_lines > 0 then 
                Async:foreach(query,
                    function(row)
                        loaded = loaded + 1

                        loadRegisteredVehicle(row)
                    end,

                    function()
                        outputDebugString("@loadAllRegisteredVehicles: loaded " .. loaded .. " / " .. query_lines .. " registered vehicle(s) in " .. getTickCount() - startTick .. " ms.", 0, 255, 50, 255)
                    end
                )
            end
        end, sql, "SELECT * FROM mdcRegisteredVehicles"
    )
end

function loadRegisteredAddress(row)
    local id = tonumber(row.id)
    local ownerName = tostring(row.ownerName)
    local actualAddress = tostring(row.actualAddress)
    local registerStart = tostring(row.registerStart)
    local expirationDate = tostring(row.expirationDate)

    table.insert(mdcRegisteredAddresses, 1, {
        id = id,
        ownerName = ownerName,
        actualAddress = actualAddress,
        registerStart = registerStart,
        expirationDate = expirationDate
    })
end

function loadAllRegisteredAddresses()
    local loaded = 0
    local startTick = getTickCount()

    dbQuery(
        function(queryHandle)
            local query, query_lines = dbPoll(queryHandle, 0)

            if query_lines > 0 then 
                Async:foreach(query,
                    function(row)
                        loaded = loaded + 1

                        loadRegisteredAddress(row)
                    end,

                    function()
                        outputDebugString("@loadAllRegisteredAddresses: loaded " .. loaded .. " / " .. query_lines .. " registered address(es) in " .. getTickCount() - startTick .. " ms.", 0, 255, 50, 255)
                    end
                )
            end
        end, sql, "SELECT * FROM mdcRegisteredAddresses"
    )
end

function loadRegisteredTraffic(row)
    local id = tonumber(row.id)
    local ownerName = tostring(row.ownerName)
    local vehiclePlateText = tostring(row.vehiclePlateText)
    local vehicleChassis = tostring(row.vehicleChassis)
    local expirationDate = tostring(row.expirationDate)

    table.insert(mdcRegisteredTraffices, 1, {
        id = id,
        ownerName = ownerName,
        vehiclePlateText = vehiclePlateText,
        vehicleChassis = vehicleChassis,
        expirationDate = expirationDate
    })
end

function loadAllRegisteredTraffices()
    local loaded = 0
    local startTick = getTickCount()

    dbQuery(
        function(queryHandle)
            local query, query_lines = dbPoll(queryHandle, 0)

            if query_lines > 0 then 
                Async:foreach(query,
                    function(row)
                        loaded = loaded + 1

                        loadRegisteredTraffic(row)
                    end,

                    function()
                        outputDebugString("@loadAllRegisteredTraffices: loaded " .. loaded .. " / " .. query_lines .. " registered traffic(es) in " .. getTickCount() - startTick .. " ms.", 0, 255, 50, 255)
                    end
                )
            end
        end, sql, "SELECT * FROM mdcRegisteredTraffices"
    )
end

function loadLog(row)
    local id = tonumber(row.id)
    local createdAt = tonumber(row.createdAt)
    local text = tostring(row.text)

    table.insert(mdcLogs, 1, {
        id = id,
        createdAt = createdAt,
        text = text
    })
end

function loadAllLogs()
    local loaded = 0
    local startTick = getTickCount()

    dbQuery(
        function(queryHandle)
            local query, query_lines = dbPoll(queryHandle, 0)

            if query_lines > 0 then 
                Async:foreach(query,
                    function(row)
                        loaded = loaded + 1

                        loadLog(row)
                    end,

                    function()
                        outputDebugString("@loadAllLogs: loaded " .. loaded .. " / " .. query_lines .. " log(s) in " .. getTickCount() - startTick .. " ms.", 0, 255, 50, 255)
                    end
                )
            end
        end, sql, "SELECT * FROM mdcLogs"
    )
end

function loadData(thePlayer, sendTo)
    if isElement(thePlayer) then 
        triggerLatentClientEvent(sendTo, "onClientMDCDataRequest", 50000, false, thePlayer, 
            mdcAccounts,
            mdcWantedCars,
            mdcWantedPersons,
            mdcWantedWeapons,
            mdcTickets,
            mdcRegisteredWeapons,
            mdcRegisteredVehicles,
            mdcRegisteredAddresses,
            mdcRegisteredTraffices,
            mdcLogs,
            mdcLoggedAccounts,
            mdcLoginCount
        )
    end
end

function onClientMDCDataRequest()
    if isElement(client) then 
        loadData(client, client)
    end
end
addEvent("onClientMDCDataRequest", true)
addEventHandler("onClientMDCDataRequest", root, onClientMDCDataRequest)

function addToViewers(thePlayer)
    if isElement(thePlayer) then 
        if not mdcViewersElementCache[thePlayer] then 
            mdcViewersElementCache[thePlayer] = true

            table.insert(mdcViewers, thePlayer)
        end
    end
end

function removeFromViewers(thePlayer)
    if mdcViewersElementCache[thePlayer] then 
        mdcViewersElementCache[thePlayer] = nil

        for k, v in pairs(mdcViewers) do 
            if v == thePlayer then 
                table.remove(mdcViewers, k)
                break
            end
        end
    end
end

function onClientPanelView()
    if isElement(client) then 
        addToViewers(client)
    end
end
addEvent("onClientPanelView", true)
addEventHandler("onClientPanelView", root, onClientPanelView)

function onClientPanelClose()
    if isElement(client) then 
        removeFromViewers(client)
    end
end
addEvent("onClientPanelClose", true)
addEventHandler("onClientPanelClose", root, onClientPanelClose)

function updateAccountOnlineStates()
    local players = getElementsByType("player")

    for i = 1, #players do 
        local v = players[i]

        if v:getData("mdc >> loggedUsername") then 
            local username = v:getData("mdc >> loggedUsername")

            local co = coroutine.create(setAccountOnlineState)
            coroutine.resume(co, v, username, true)
        end
    end
end

function setAccountOnlineState(thePlayer, username, state)
    if isElement(thePlayer) then 
        if mdcAccounts[username] then 
            local dbId = mdcAccounts[username].id

            dbExec(sql, "UPDATE mdcaccounts SET online = ? WHERE id = ? AND username = ?", tostring(state), dbId, username)

            mdcAccounts[username].online = state
            mdcLoggedAccounts[username] = state and thePlayer or nil

            if mdcLoggedAccounts[username] then 
                mdcLoginCount = mdcLoginCount + 1
            else
                collectgarbage("collect")
            end
        end
    end
end

function loginToAccount(thePlayer, username, password)
    if client and client == thePlayer and username and password then 
        if mdcAccounts[username] then 
            local realPassword = mdcAccounts[username].password
            local hashPassword1 = hash("sha512", username .. password .. username)
            local hashedPassword = hash("md5", salt .. hashPassword1 .. salt)

            if realPassword:lower() == hashedPassword:lower() then 
                local online = mdcAccounts[username].online

                if not online then 
                    setAccountOnlineState(thePlayer, username, true)

                    local vehicle = thePlayer.vehicle
                    local data = vehicle:getData("veh >> mdcData") or {["unit"] = false, ["loggedIn"] = false, ["duty"] = false}

                    local syntax = exports.cr_core:getServerSyntax("MDC", "red")
                    local serverHex = exports.cr_core:getServerColor("yellow", true)

                    exports.cr_infobox:addBox(thePlayer, "success", "Sikeresen bejelentkeztél.")
                    exports.cr_dashboard:sendMessageToFaction(1, syntax..serverHex..exports.cr_admin:getAdminName(thePlayer)..white.." bejelentkezett egy mdc felhasználóba. "..serverHex.."("..username..")")
                    
                    local occupants = vehicle:getOccupants()

                    triggerLatentClientEvent(occupants, "mdc >> loginSuccess", 50000, false, thePlayer, username)

                    data["loggedIn"] = username
                    vehicle:setData("veh >> mdcData", data)
                    thePlayer:setData("mdc >> loggedUsername", username)

                    addToViewers(thePlayer)
                    loadData(thePlayer, mdcViewers)
                else 
                    exports.cr_infobox:addBox(thePlayer, "error", "Ez a felhasználó már használatban van.")
                end
            else
                exports.cr_infobox:addBox(thePlayer, "error", "Hibás jelszó.")
            end
        else
            exports.cr_infobox:addBox(thePlayer, "error", "Nem található felhasználó ezzel a névvel.")
        end
    end
end
addEvent("mdc >> loginToAccount", true)
addEventHandler("mdc >> loginToAccount", root, loginToAccount)

function changeUnit(thePlayer, unit)
    if client and client == thePlayer and unit then 
        local vehicle = thePlayer.vehicle
        local data = vehicle:getData("veh >> mdcData") or {["unit"] = false, ["loggedIn"] = false, ["duty"] = false}

        local syntax = exports.cr_core:getServerSyntax("MDC", "red")
        local green = exports.cr_core:getServerColor("green", true)
        local serverHex = exports.cr_core:getServerColor("yellow", true)

        if not mdcActiveUnits[unit] then 
            exports.cr_dashboard:sendMessageToFaction(1, syntax.."A(z) "..serverHex..unit..white.." egység "..green.."elérhető.")

            local occupants = vehicle:getOccupants()
            triggerLatentClientEvent(occupants, "mdc >> manageMDCPanel", 50000, false, thePlayer, "switchToMainMdcPanel")

            data["unit"] = unit
            vehicle:setData("veh >> mdcData", data)

            mdcActiveUnits[unit] = true
        else
            return exports.cr_infobox:addBox(thePlayer, "error", "Már létezik egy egység ezzel az egységszámmal.")
        end
    end
end
addEvent("mdc >> changeUnit", true)
addEventHandler("mdc >> changeUnit", root, changeUnit)

function quitMDC(thePlayer, vehicle, vehicleUnit)
    if client and client == thePlayer and vehicle and vehicleUnit then 
        local username = thePlayer:getData("mdc >> loggedUsername")

        if mdcAccounts[username] then 
            setAccountOnlineState(thePlayer, username, false)

            local syntax = exports.cr_core:getServerSyntax("MDC", "red")
            local red = exports.cr_core:getServerColor("red", true)
            local serverHex = exports.cr_core:getServerColor("yellow", true)

            exports.cr_dashboard:sendMessageToFaction(1, syntax.."A(z) "..serverHex..vehicleUnit..white.." egység "..red.."feloszlott.")
            mdcActiveUnits[vehicleUnit] = nil
            
            local occupants = vehicle:getOccupants()
            for k, v in pairs(occupants) do 
                if isElement(v) then 
                    if v:getData("mdc >> loggedUsername") then 
                        v:removeData("mdc >> loggedUsername")
                    end
                end
            end

            removeFromViewers(thePlayer)
            loadData(thePlayer, mdcViewers)
        end
    end
end
addEvent("mdc >> quitMDC", true)
addEventHandler("mdc >> quitMDC", root, quitMDC)

function changeDutyType(thePlayer, vehicleUnit, selectedDuty)
    if client and client == thePlayer and vehicleUnit then 
        local syntax = exports.cr_core:getServerSyntax("MDC", "red")
        local red = exports.cr_core:getServerColor("red", true)
        local serverHex = exports.cr_core:getServerColor("yellow", true)

        local dutyType = mdcDutyTypes[selectedDuty]
        local hex = serverHex

        if not selectedDuty then 
            dutyType = "szolgálaton kívül"
            hex = red
        end

        local vehicle = thePlayer.vehicle
        local data = vehicle:getData("veh >> mdcData") or {["unit"] = false, ["loggedIn"] = false, ["duty"] = false}
        
        data["duty"] = selectedDuty
        vehicle:setData("veh >> mdcData", data)

        exports.cr_dashboard:sendMessageToFaction(1, syntax .. "A(z) "..serverHex..vehicleUnit..white.." egység szolgálati állapota: "..hex..dutyType..".")
    end
end
addEvent("mdc >> changeDutyType", true)
addEventHandler("mdc >> changeDutyType", root, changeDutyType)

function addLog(thePlayer, text)
    if isElement(thePlayer) then 
        if #mdcLogs + 1 > maxLogs then 
            local lastIndex = #mdcLogs
            local data = mdcLogs[lastIndex]
            
            if data and data.id then 
                local id = data.id

                dbExec(sql, "DELETE FROM mdcLogs WHERE id = ?", id)
                table.remove(mdcLogs, lastIndex)
            end
        end

        local createdAt = os.time()
        dbExec(sql, "INSERT INTO mdcLogs SET createdAt = ?, text = ?", createdAt, text)

        dbQuery(
            function(queryHandle, thePlayer)
                local query, query_lines = dbPoll(queryHandle, 0)

                if query_lines > 0 then 
                    local row = query[1]

                    loadLog(row)

                    if isElement(thePlayer) then 
                        loadData(thePlayer, mdcViewers)
                    end
                end
            end, {thePlayer}, sql, "SELECT * FROM mdcLogs WHERE id = LAST_INSERT_ID() AND createdAt = ?", createdAt
        )
    end
end

function onClientAddWantedCar(vehicleType, vehiclePlateText, reason)
    if isElement(client) then 
        dbExec(sql, "INSERT INTO mdcWantedCars SET vehicleType = ?, vehiclePlateText = ?, reason = ?", vehicleType, vehiclePlateText, reason)

        dbQuery(
            function(queryHandle, thePlayer)
                local query, query_lines = dbPoll(queryHandle, 0)

                if query_lines > 0 then 
                    local row = query[1]

                    loadWantedCar(row)

                    if isElement(thePlayer) then 
                        local name = exports.cr_admin:getAdminName(thePlayer)
                        local hexColor = exports.cr_core:getServerColor("yellow", true)

                        exports.cr_infobox:addBox(thePlayer, "success", "Sikeresen hozzáadtad a körözött járművekhez!")
                        addLog(thePlayer, hexColor .. name .. white .. " körözést adott ki egy járműre. Rendszám: " .. hexColor .. row.vehiclePlateText .. white .. ", Indok: " .. hexColor .. row.reason)
                        loadData(thePlayer, mdcViewers)
                    end
                end
            end, {client}, sql, "SELECT * FROM mdcWantedCars WHERE id = LAST_INSERT_ID() AND vehiclePlateText = ?", vehiclePlateText
        )
    end
end
addEvent("onClientAddWantedCar", true)
addEventHandler("onClientAddWantedCar", root, onClientAddWantedCar)

function onClientDeleteWantedCar(index)
    if isElement(client) then 
        if index and mdcWantedCars[index] then 
            local data = mdcWantedCars[index]

            if data.id then 
                local id = data.id
                local vehiclePlateText = data.vehiclePlateText

                local name = exports.cr_admin:getAdminName(client)
                local hexColor = exports.cr_core:getServerColor("yellow", true)

                dbExec(sql, "DELETE FROM mdcWantedCars WHERE id = ?", id)
                table.remove(mdcWantedCars, index)

                if mdcWantedVehiclesByPlateText[vehiclePlateText] then 
                    mdcWantedVehiclesByPlateText[vehiclePlateText] = nil
                end

                exports.cr_infobox:addBox(client, "success", "Sikeresen kitörölted a körözött járművekből!")
                addLog(client, hexColor .. name .. white .. " eltávolított egy körözött járművet. Rendszám: " .. hexColor .. vehiclePlateText)
                loadData(client, mdcViewers)
            end
        end
    end
end
addEvent("onClientDeleteWantedCar", true)
addEventHandler("onClientDeleteWantedCar", root, onClientDeleteWantedCar)

function onClientAddWantedPerson(name, nationality, description, reason)
    if isElement(client) then 
        dbExec(sql, "INSERT INTO mdcWantedPersons SET name = ?, nationality = ?, description = ?, reason = ?", name, nationality, description, reason)

        dbQuery(
            function(queryHandle, thePlayer)
                local query, query_lines = dbPoll(queryHandle, 0)

                if query_lines > 0 then 
                    local row = query[1]

                    loadWantedPerson(row)

                    if isElement(thePlayer) then 
                        local name = exports.cr_admin:getAdminName(thePlayer)
                        local hexColor = exports.cr_core:getServerColor("yellow", true)

                        exports.cr_infobox:addBox(thePlayer, "success", "Sikeresen hozzáadtad a körözött személyekhez!")

                        addLog(thePlayer, hexColor .. name .. white .. " körözést adott ki egy személyre. Név: " .. hexColor .. row.name .. white .. ", Indok: " .. hexColor .. row.reason)
                        loadData(thePlayer, mdcViewers)
                    end
                end
            end, {client}, sql, "SELECT * FROM mdcWantedPersons WHERE id = LAST_INSERT_ID() AND name = ?", name
        )
    end
end
addEvent("onClientAddWantedPerson", true)
addEventHandler("onClientAddWantedPerson", root, onClientAddWantedPerson)

function onClientDeleteWantedPerson(index)
    if isElement(client) then 
        if index and mdcWantedPersons[index] then 
            local data = mdcWantedPersons[index]

            if data.id then 
                local id = data.id
                local wantedName = data.name

                local name = exports.cr_admin:getAdminName(client)
                local hexColor = exports.cr_core:getServerColor("yellow", true)

                dbExec(sql, "DELETE FROM mdcWantedPersons WHERE id = ?", id)
                table.remove(mdcWantedPersons, index)

                if mdcWantedPersonsByName[wantedName] then 
                    mdcWantedPersonsByName[wantedName] = nil
                end

                exports.cr_infobox:addBox(client, "success", "Sikeresen kitörölted a körözött személyekből!")
                addLog(client, hexColor .. name .. white .. " eltávolított egy körözött személyt. Név: " .. hexColor .. wantedName)
                loadData(client, mdcViewers)
            end
        end
    end
end
addEvent("onClientDeleteWantedPerson", true)
addEventHandler("onClientDeleteWantedPerson", root, onClientDeleteWantedPerson)

function onClientCreateNewTicket(name, jailTime, penalty, reason)
    if isElement(client) then 
        dbExec(sql, "INSERT INTO mdcTickets SET name = ?, jailTime = ?, penalty = ?, reason = ?", name, jailTime, penalty, reason)

        dbQuery(
            function(queryHandle, thePlayer)
                local query, query_lines = dbPoll(queryHandle, 0)

                if query_lines > 0 then 
                    local row = query[1]

                    loadTicket(row)

                    if isElement(thePlayer) then 
                        local name = exports.cr_admin:getAdminName(thePlayer)
                        local hexColor = exports.cr_core:getServerColor("yellow", true)

                        exports.cr_infobox:addBox(thePlayer, "success", "Sikeresen hozzáadtad a büntetésekhez!")

                        addLog(thePlayer, hexColor .. name .. white .. " kiadott egy új büntetést. Név: " .. hexColor .. row.name .. white .. ", Indok: " .. hexColor .. row.reason)
                        loadData(thePlayer, mdcViewers)
                    end
                end
            end, {client}, sql, "SELECT * FROM mdcTickets WHERE id = LAST_INSERT_ID() AND name = ?", name
        )
    end
end
addEvent("onClientCreateNewTicket", true)
addEventHandler("onClientCreateNewTicket", root, onClientCreateNewTicket)

function onClientDeleteTicket(index)
    if isElement(client) then 
        if index and mdcTickets[index] then 
            local data = mdcTickets[index]

            if data.id then 
                local id = data.id
                local ticketName = data.name

                local name = exports.cr_admin:getAdminName(client)
                local hexColor = exports.cr_core:getServerColor("yellow", true)

                dbExec(sql, "DELETE FROM mdcTickets WHERE id = ?", id)
                table.remove(mdcTickets, index)

                exports.cr_infobox:addBox(client, "success", "Sikeresen kitörölted a büntetésekből!")
                addLog(client, hexColor .. name .. white .. " eltávolított egy büntetést. Név: " .. hexColor .. ticketName)
                loadData(client, mdcViewers)
            end
        end
    end
end
addEvent("onClientDeleteTicket", true)
addEventHandler("onClientDeleteTicket", root, onClientDeleteTicket)

function onClientAddWantedWeapon(weaponName, weaponType, weaponSerial, reason)
    if isElement(client) then 
        dbExec(sql, "INSERT INTO mdcWantedWeapons SET weaponName = ?, weaponType = ?, weaponSerial = ?, reason = ?", weaponName, weaponType, weaponSerial, reason)

        dbQuery(
            function(queryHandle, thePlayer)
                local query, query_lines = dbPoll(queryHandle, 0)

                if query_lines > 0 then 
                    local row = query[1]

                    loadWantedWeapon(row)

                    if isElement(thePlayer) then 
                        local name = exports.cr_admin:getAdminName(thePlayer)
                        local hexColor = exports.cr_core:getServerColor("yellow", true)

                        exports.cr_infobox:addBox(thePlayer, "success", "Sikeresen hozzáadtad a körözött fegyverekhez!")

                        addLog(thePlayer, hexColor .. name .. white .. " körözést adott ki egy fegyverre. Sorozatszám: " .. hexColor .. row.weaponSerial .. white .. ", Indok: " .. hexColor .. row.reason)
                        loadData(thePlayer, mdcViewers)
                    end
                end
            end, {client}, sql, "SELECT * FROM mdcWantedWeapons WHERE id = LAST_INSERT_ID() AND weaponSerial = ?", weaponSerial
        )
    end
end
addEvent("onClientAddWantedWeapon", true)
addEventHandler("onClientAddWantedWeapon", root, onClientAddWantedWeapon)

function onClientDeleteWantedWeapon(index)
    if isElement(client) then 
        if index and mdcWantedWeapons[index] then 
            local data = mdcWantedWeapons[index]

            if data.id then 
                local id = data.id
                local weaponSerial = data.weaponSerial

                local name = exports.cr_admin:getAdminName(client)
                local hexColor = exports.cr_core:getServerColor("yellow", true)

                dbExec(sql, "DELETE FROM mdcWantedWeapons WHERE id = ?", id)
                table.remove(mdcWantedWeapons, index)

                exports.cr_infobox:addBox(client, "success", "Sikeresen kitörölted a körözött fegyverekből!")
                addLog(client, hexColor .. name .. white .. " eltávolított egy körözött fegyvert. Sorozatszám: " .. hexColor .. weaponSerial)
                loadData(client, mdcViewers)
            end
        end
    end
end
addEvent("onClientDeleteWantedWeapon", true)
addEventHandler("onClientDeleteWantedWeapon", root, onClientDeleteWantedWeapon)

function onClientCreateNewUser(username, password, factionPrefix)
    if isElement(client) and not mdcAccounts[username] then 
        local hashedPassword = generatePassword(username, password)
        local faction = exports.cr_faction_scripts:getFactionIdByPrefix(factionPrefix)

        dbExec(sql, "INSERT INTO mdcaccounts SET username = ?, password = ?, faction = ?, leader = ?, online = ?", username, hashedPassword, faction, "false", "false")

        dbQuery(
            function(queryHandle, thePlayer)
                local query, query_lines = dbPoll(queryHandle, 0)

                if query_lines > 0 then 
                    local row = query[1]

                    loadAccount(row)

                    if isElement(thePlayer) then 
                        local syntax = exports.cr_core:getServerSyntax(false, "success")
                        local hexCode = exports.cr_core:getServerColor("blue", true)

                        local name = exports.cr_admin:getAdminName(thePlayer)
                        local hexColor = exports.cr_core:getServerColor("yellow", true)

                        exports.cr_infobox:addBox(thePlayer, "success", "Sikeresen létrehoztad a felhasználót! (" .. row.username .. ") ID: " .. row.id)
                        addLog(thePlayer, hexColor .. name .. white .. " létrehozott egy normál felhasználót. Név: " .. hexColor .. row.username)
                        loadData(thePlayer, getElementsByType("player"))
                    end
                end
            end, {client}, sql, "SELECT * FROM mdcaccounts WHERE id = LAST_INSERT_ID() AND username = ?", username
        )
    else
        exports.cr_infobox:addBox(client, "error", "Már létezik egy felhasználó ezzel a névvel.")
    end
end
addEvent("onClientCreateNewUser", true)
addEventHandler("onClientCreateNewUser", root, onClientCreateNewUser)

function onClientDeleteUser(username)
    if isElement(client) then 
        if username and mdcAccounts[username] then 
            local data = mdcAccounts[username]

            if data.id then 
                local id = data.id

                local name = exports.cr_admin:getAdminName(client)
                local hexColor = exports.cr_core:getServerColor("yellow", true)

                if mdcLoggedAccounts[username] then 
                    local loggedElement = mdcLoggedAccounts[username]
                    
                    if isElement(loggedElement) then 
                        triggerLatentClientEvent(loggedElement, "mdc >> manageMDCPanel", 50000, false, loggedElement, "quit")
    
                        exports.cr_infobox:addBox(loggedElement, "info", "Kitörölték a felhasználód, ezért ki lettél jelentkeztetve!")
                    end
                end

                dbExec(sql, "DELETE FROM mdcaccounts WHERE id = ?", id)
                mdcAccounts[username] = nil

                exports.cr_infobox:addBox(client, "success", "Sikeresen kitörölted a felhasználót!")
                addLog(client, hexColor .. name .. white .. " kitörölt egy normál felhasználót. Név: " .. hexColor .. username)
                loadData(client, mdcViewers)
            end
        end
    end
end
addEvent("onClientDeleteUser", true)
addEventHandler("onClientDeleteUser", root, onClientDeleteUser)

function onClientUserPasswordChange(username, newPassword)
    if isElement(client) then 
        if mdcAccounts[username] then 
            local id = mdcAccounts[username].id
            local oldPassword = mdcAccounts[username].password
            local hashedPassword = generatePassword(username, newPassword)

            if utf8.lower(oldPassword) == utf8.lower(hashedPassword) then 
                exports.cr_infobox:addBox(client, "error", "A régi jelszó nem egyezhet meg az újal!")

                return
            end

            dbExec(sql, "UPDATE mdcaccounts SET password = ? WHERE id = ? AND username = ?", hashedPassword, id, username)
            mdcAccounts[username].password = hashedPassword

            exports.cr_infobox:addBox(client, "success", "Sikeresen megváltoztattad a jelszót!")

            local name = exports.cr_admin:getAdminName(client)
            local hexColor = exports.cr_core:getServerColor("yellow", true)

            if mdcLoggedAccounts[username] then 
                local loggedElement = mdcLoggedAccounts[username]
                
                if isElement(loggedElement) then 
                    triggerLatentClientEvent(loggedElement, "mdc >> manageMDCPanel", 50000, false, loggedElement, "quit")

                    exports.cr_infobox:addBox(loggedElement, "info", "Megváltozott a jelszavad, ezért ki lettél jelentkeztetve!")
                end
            end

            addLog(client, hexColor .. name .. white .. " megváltoztatta " .. hexColor .. username .. white .. " felhasználó jelszavát.")
            loadData(client, mdcViewers)
        else
            exports.cr_infobox:addBox(client, "error", "Nem létezik felhasználó ezzel a névvel.")
        end
    end
end
addEvent("onClientUserPasswordChange", true)
addEventHandler("onClientUserPasswordChange", root, onClientUserPasswordChange)

function onClientAddRegisteredVehicle(ownerName, vehicleType, vehiclePlateText, vehicleChassis)
    if isElement(client) then 
        dbExec(sql, "INSERT INTO mdcRegisteredVehicles SET ownerName = ?, vehicleType = ?, vehiclePlateText = ?, vehicleChassis = ?", ownerName, vehicleType, vehiclePlateText, vehicleChassis)

        dbQuery(
            function(queryHandle, thePlayer)
                local query, query_lines = dbPoll(queryHandle, 0)

                if query_lines > 0 then 
                    local row = query[1]

                    loadRegisteredVehicle(row)

                    if isElement(thePlayer) then 
                        local name = exports.cr_admin:getAdminName(thePlayer)
                        local hexColor = exports.cr_core:getServerColor("yellow", true)

                        exports.cr_infobox:addBox(thePlayer, "success", "Sikeresen hozzáadtad a jármű nyilvántartásokhoz!")

                        addLog(thePlayer, hexColor .. name .. white .. " hozzáadott egy járművet a nyilvántartásokhoz. Rendszám: " .. hexColor .. row.vehiclePlateText .. white .. ", Alvázszám: " .. hexColor .. row.vehicleChassis)
                        loadData(thePlayer, mdcViewers)
                    end
                end
            end, {client}, sql, "SELECT * FROM mdcRegisteredVehicles WHERE id = LAST_INSERT_ID() AND vehicleChassis = ?", vehicleChassis
        )
    end
end
addEvent("onClientAddRegisteredVehicle", true)
addEventHandler("onClientAddRegisteredVehicle", root, onClientAddRegisteredVehicle)

function onClientDeleteRegisteredVehicle(index)
    if isElement(client) then 
        if index and mdcRegisteredVehicles[index] then 
            local data = mdcRegisteredVehicles[index]

            if data.id then 
                local id = data.id
                local vehiclePlateText = data.vehiclePlateText

                local name = exports.cr_admin:getAdminName(client)
                local hexColor = exports.cr_core:getServerColor("yellow", true)

                dbExec(sql, "DELETE FROM mdcRegisteredVehicles WHERE id = ?", id)
                table.remove(mdcRegisteredVehicles, index)

                exports.cr_infobox:addBox(client, "success", "Sikeresen kitörölted a jármű nyilvántartásokból!")
                addLog(client, hexColor .. name .. white .. " eltávolított egy járművet a nyilvántartásokból. Rendszám: " .. hexColor .. vehiclePlateText)
                loadData(client, mdcViewers)
            end
        end
    end
end
addEvent("onClientDeleteRegisteredVehicle", true)
addEventHandler("onClientDeleteRegisteredVehicle", root, onClientDeleteRegisteredVehicle)

function onClientAddRegisteredWeapon(ownerName, weaponType, weaponSerial)
    if isElement(client) then 
        dbExec(sql, "INSERT INTO mdcRegisteredWeapons SET ownerName = ?, weaponType = ?, weaponSerial = ?", ownerName, weaponType, weaponSerial)

        dbQuery(
            function(queryHandle, thePlayer)
                local query, query_lines = dbPoll(queryHandle, 0)

                if query_lines > 0 then 
                    local row = query[1]

                    loadRegisteredWeapon(row)

                    if isElement(thePlayer) then 
                        local name = exports.cr_admin:getAdminName(thePlayer)
                        local hexColor = exports.cr_core:getServerColor("yellow", true)

                        exports.cr_infobox:addBox(thePlayer, "success", "Sikeresen hozzáadtad a fegyver nyilvántartásokhoz!")

                        addLog(thePlayer, hexColor .. name .. white .. " hozzáadott egy fegyvert a nyilvántartásokhoz. Sorozatszám: " .. hexColor .. row.weaponSerial)
                        loadData(thePlayer, mdcViewers)
                    end
                end
            end, {client}, sql, "SELECT * FROM mdcRegisteredWeapons WHERE id = LAST_INSERT_ID() AND weaponSerial = ?", weaponSerial
        )
    end
end
addEvent("onClientAddRegisteredWeapon", true)
addEventHandler("onClientAddRegisteredWeapon", root, onClientAddRegisteredWeapon)

function onClientDeleteRegisteredWeapon(index)
    if isElement(client) then 
        if index and mdcRegisteredWeapons[index] then 
            local data = mdcRegisteredWeapons[index]

            if data.id then 
                local id = data.id
                local weaponSerial = data.weaponSerial

                local name = exports.cr_admin:getAdminName(client)
                local hexColor = exports.cr_core:getServerColor("yellow", true)

                dbExec(sql, "DELETE FROM mdcRegisteredWeapons WHERE id = ?", id)
                table.remove(mdcRegisteredWeapons, index)

                exports.cr_infobox:addBox(client, "success", "Sikeresen kitörölted a fegyver nyilvántartásokból!")
                addLog(client, hexColor .. name .. white .. " eltávolított egy fegyvert a nyilvántartásokból. Sorozatszám: " .. hexColor .. weaponSerial)
                loadData(client, mdcViewers)
            end
        end
    end
end
addEvent("onClientDeleteRegisteredWeapon", true)
addEventHandler("onClientDeleteRegisteredWeapon", root, onClientDeleteRegisteredWeapon)

function onClientAddRegisteredAddress(ownerName, actualAddress, registerStart, expirationDate)
    if isElement(client) then 
        dbExec(sql, "INSERT INTO mdcRegisteredAddresses SET ownerName = ?, actualAddress = ?, registerStart = ?, expirationDate = ?", ownerName, actualAddress, registerStart, expirationDate)

        dbQuery(
            function(queryHandle, thePlayer)
                local query, query_lines = dbPoll(queryHandle, 0)

                if query_lines > 0 then 
                    local row = query[1]

                    loadRegisteredAddress(row)

                    if isElement(thePlayer) then 
                        local name = exports.cr_admin:getAdminName(thePlayer)
                        local hexColor = exports.cr_core:getServerColor("yellow", true)

                        exports.cr_infobox:addBox(thePlayer, "success", "Sikeresen hozzáadtad a lakcím nyilvántartásokhoz!")

                        addLog(thePlayer, hexColor .. name .. white .. " hozzáadott egy lakcímet a nyilvántartásokhoz. Cím: " .. hexColor .. row.actualAddress)
                        loadData(thePlayer, mdcViewers)
                    end
                end
            end, {client}, sql, "SELECT * FROM mdcRegisteredAddresses WHERE id = LAST_INSERT_ID() AND actualAddress = ?", actualAddress
        )
    end
end
addEvent("onClientAddRegisteredAddress", true)
addEventHandler("onClientAddRegisteredAddress", root, onClientAddRegisteredAddress)

function onClientDeleteRegisteredAddress(index)
    if isElement(client) then 
        if index and mdcRegisteredAddresses[index] then 
            local data = mdcRegisteredAddresses[index]

            if data.id then 
                local id = data.id
                local actualAddress = data.actualAddress

                local name = exports.cr_admin:getAdminName(client)
                local hexColor = exports.cr_core:getServerColor("yellow", true)

                dbExec(sql, "DELETE FROM mdcRegisteredAddresses WHERE id = ?", id)
                table.remove(mdcRegisteredAddresses, index)

                exports.cr_infobox:addBox(client, "success", "Sikeresen kitörölted a lakcím nyilvántartásokból!")
                addLog(client, hexColor .. name .. white .. " eltávolított egy lakcímet a nyilvántartásokból. Cím: " .. hexColor .. actualAddress)
                loadData(client, mdcViewers)
            end
        end
    end
end
addEvent("onClientDeleteRegisteredAddress", true)
addEventHandler("onClientDeleteRegisteredAddress", root, onClientDeleteRegisteredAddress)

function onClientAddRegisteredTraffic(ownerName, vehiclePlateText, vehicleChassis, expirationDate)
    if isElement(client) then 
        dbExec(sql, "INSERT INTO mdcRegisteredTraffices SET ownerName = ?, vehiclePlateText = ?, vehicleChassis = ?, expirationDate = ?", ownerName, vehiclePlateText, vehicleChassis, expirationDate)

        dbQuery(
            function(queryHandle, thePlayer)
                local query, query_lines = dbPoll(queryHandle, 0)

                if query_lines > 0 then 
                    local row = query[1]

                    loadRegisteredTraffic(row)

                    if isElement(thePlayer) then 
                        local name = exports.cr_admin:getAdminName(thePlayer)
                        local hexColor = exports.cr_core:getServerColor("yellow", true)

                        exports.cr_infobox:addBox(thePlayer, "success", "Sikeresen hozzáadtad a forgalmi nyilvántartásokhoz!")

                        addLog(thePlayer, hexColor .. name .. white .. " hozzáadott egy forgalmit a nyilvántartásokhoz. Rendszám: " .. hexColor .. row.vehiclePlateText)
                        loadData(thePlayer, mdcViewers)
                    end
                end
            end, {client}, sql, "SELECT * FROM mdcRegisteredTraffices WHERE id = LAST_INSERT_ID() AND vehicleChassis = ?", vehicleChassis
        )
    end
end
addEvent("onClientAddRegisteredTraffic", true)
addEventHandler("onClientAddRegisteredTraffic", root, onClientAddRegisteredTraffic)

function onClientDeleteRegisteredTraffic(index)
    if isElement(client) then 
        if index and mdcRegisteredTraffices[index] then 
            local data = mdcRegisteredTraffices[index]

            if data.id then 
                local id = data.id
                local vehiclePlateText = data.vehiclePlateText

                local name = exports.cr_admin:getAdminName(client)
                local hexColor = exports.cr_core:getServerColor("yellow", true)

                dbExec(sql, "DELETE FROM mdcRegisteredTraffices WHERE id = ?", id)
                table.remove(mdcRegisteredTraffices, index)

                exports.cr_infobox:addBox(client, "success", "Sikeresen kitörölted a forgalmi nyilvántartásokból!")
                addLog(client, hexColor .. name .. white .. " eltávolított egy forgalmit a nyilvántartásokból. Rendszám: " .. hexColor .. vehiclePlateText)
                loadData(client, mdcViewers)
            end
        end
    end
end
addEvent("onClientDeleteRegisteredTraffic", true)
addEventHandler("onClientDeleteRegisteredTraffic", root, onClientDeleteRegisteredTraffic)

function getWantedVehicles()
    return mdcWantedCars, mdcWantedVehiclesByPlateText
end

function getWantedPersons()
    return mdcWantedPersons, mdcWantedPersonsByName
end

function onQuit()
    removeFromViewers(source)
end
addEventHandler("onPlayerQuit", root, onQuit)