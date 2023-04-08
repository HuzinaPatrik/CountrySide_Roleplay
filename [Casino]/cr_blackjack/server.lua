local sql = exports.cr_mysql:getConnection(getThisResource())

addEventHandler("onResourceStart", root,
    function(startedRes)
        if getResourceName(startedRes) == "cr_mysql" then 
            sql = exports.cr_mysql:getConnection(getThisResource())
            restartResource(getThisResource())
        elseif startedRes == getThisResource() then
            loadAllCoinDealer()
            loadAllBlackJackTable()
        end
    end
)

local availableCoinDealers = {}
local availableCoinDealerElements = {}

local availableBlackJackTables = {}
local availableBlackJackTableElements = {}

function loadCoinDealer(row)
    local id = tonumber(row.id)
    local position = split(row.position, ", ")
    local rotation = split(row.rotation, ", ")
    local interior = tonumber(row.interior)
    local dimension = tonumber(row.dimension)

    local skinId = tonumber(row.skinId)
    local name = tostring(row.name)

    local x, y, z = unpack(position)
    local rx, ry, rz = unpack(rotation)

    local pedElement = Ped(skinId, x, y, z, rz)

    pedElement.interior = interior
    pedElement.dimension = dimension
    pedElement.frozen = true

    pedElement:setData("ped.name", name)
    pedElement:setData("ped.type", "Coin dealer")
    pedElement:setData("coin >> dealer", id)
    pedElement:setData("char >> noDamage", true)

    availableCoinDealers[id] = pedElement
    availableCoinDealerElements[pedElement] = id
end

function loadAllCoinDealer()
    local loaded = 0
    local startTick = getTickCount()

    dbQuery(
        function(queryHandle)
            local query, query_lines = dbPoll(queryHandle, 0)

            if query_lines > 0 then 
                Async:foreach(query,
                    function(row)
                        loaded = loaded + 1

                        loadCoinDealer(row)
                    end,

                    function()
                        outputDebugString("@loadAllCoinDealer: loaded " .. loaded .. " / " .. query_lines .. " coin dealer(s) in " .. getTickCount() - startTick .. " ms.", 0, 255, 50, 255)
                    end
                )
            end
        end, sql, "SELECT * FROM coindealers"
    )
end

function loadBlackJackTable(row)
    local id = tonumber(row.id)
    local position = split(row.position, ", ")
    local rotation = split(row.rotation, ", ")

    local interior = tonumber(row.interior)
    local dimension = tonumber(row.dimension)

    local x, y, z = unpack(position)
    local rx, ry, rz = unpack(rotation)
    local dealerElement = Ped(189, x, y, z, rz)

    dealerElement.interior = interior
    dealerElement.dimension = dimension
    dealerElement.frozen = true

    dealerElement:setData("ped.name", "Krupié")
    dealerElement:setData("ped.type", "NPC")
    dealerElement:setData("char >> noDamage", true)

    local tableX, tableY, tableZ, tableRot = getPositionInFront(x, y, z, rz, 0.5)
    local tableElement = Object(2188, tableX, tableY, tableZ, 0, 0, tableRot + 180)

    tableElement.interior = interior
    tableElement.dimension = dimension

    tableElement:setData("blackJackTable >> id", id)

    availableBlackJackTables[id] = {tableElement = tableElement, dealerElement = dealerElement}
    availableBlackJackTableElements[tableElement] = id
end

function loadAllBlackJackTable()
    local loaded = 0
    local startTick = getTickCount()

    dbQuery(
        function(queryHandle)
            local query, query_lines = dbPoll(queryHandle, 0)

            if query_lines > 0 then 
                Async:foreach(query,
                    function(row)
                        loaded = loaded + 1

                        loadBlackJackTable(row)
                    end,

                    function()
                        outputDebugString("@loadAllBlackJackTable: loaded " .. loaded .. " / " .. query_lines .. " blackjack table(s) in " .. getTickCount() - startTick .. " ms.", 0, 255, 50, 255)
                    end
                )
            end
        end, sql, "SELECT * FROM blackjackTables"
    )
end

function createCoinDealerCommand(thePlayer, cmd, skinId, ...)
    if exports.cr_permission:hasPermission(thePlayer, cmd) then 
        if not skinId or not ... then 
            local syntax = exports.cr_core:getServerSyntax(false, "lightyellow")

            outputChatBox(syntax .. "/" .. cmd .. " [skinId] [Név]", thePlayer, 255, 0, 0, true)
            return
        end

        local skinId = tonumber(skinId)
        local name = table.concat({...}, " ")

        if not skinId or not exports.cr_skins:isSkinValid(skinId) then 
            local syntax = exports.cr_core:getServerSyntax(false, "error")

            outputChatBox(syntax .. "Hibás skin id.", thePlayer, 255, 0, 0, true)
            return
        end

        local concatenatedPosition = table.concat({getElementPosition(thePlayer)}, ", ")
        local concatenatedRotation = table.concat({getElementRotation(thePlayer)}, ", ")

        local interior = thePlayer.interior
        local dimension = thePlayer.dimension

        local createdAt = os.time()
        local createdBy = exports.cr_admin:getAdminName(thePlayer)

        dbExec(sql, "INSERT INTO coindealers SET position = ?, rotation = ?, interior = ?, dimension = ?, skinId = ?, name = ?, createdAt = ?, createdBy = ?", concatenatedPosition, concatenatedRotation, interior, dimension, skinId, name, createdAt, createdBy)

        dbQuery(
            function(queryHandle, thePlayer)
                local query, query_lines = dbPoll(queryHandle, 0)

                if query_lines > 0 then 
                    local row = query[1]

                    loadCoinDealer(row)

                    if isElement(thePlayer) then 
                        local syntax = exports.cr_core:getServerSyntax("Blackjack", "success")
                        local hexColor = exports.cr_core:getServerColor("yellow", true)

                        outputChatBox(syntax .. "Sikeresen létrehoztál egy zseton eladó npc-t! " .. hexColor .. "(" .. row.id .. ")", thePlayer, 255, 0, 0, true)

                        local adminSyntax = exports.cr_admin:getAdminSyntax()
                        local localName = exports.cr_admin:getAdminName(thePlayer, true)

                        exports.cr_core:sendMessageToAdmin(thePlayer, adminSyntax .. hexColor .. localName .. white .. " létrehozott egy zseton eladó npc-t. " .. hexColor .. "(" .. row.id .. ")", 3)
                    end
                end
            end, {thePlayer}, sql, "SELECT * FROM coindealers WHERE createdAt = ? AND id = LAST_INSERT_ID()", createdAt
        )
    end
end
addCommandHandler("createcoindealer", createCoinDealerCommand, false, false)

function deleteCoinDealerCommand(thePlayer, cmd, id)
    if exports.cr_permission:hasPermission(thePlayer, cmd) then 
        if not id then 
            local syntax = exports.cr_core:getServerSyntax(false, "lightyellow")

            outputChatBox(syntax .. "/" .. cmd .. " [id]", thePlayer, 255, 0, 0, true)
            return
        end

        local id = tonumber(id)

        if not id then 
            local syntax = exports.cr_core:getServerSyntax(false, "error")

            outputChatBox(syntax .. "Csak szám.", thePlayer, 255, 0, 0, true)
            return
        end

        if not availableCoinDealers[id] then 
            local syntax = exports.cr_core:getServerSyntax(false, "error")

            outputChatBox(syntax .. "Nem létezik zseton eladó ezzel az id-vel.", thePlayer, 255, 0, 0, true)
            return
        end

        local pedElement = availableCoinDealers[id]

        if isElement(availableCoinDealers[id]) then 
            availableCoinDealers[id]:destroy()
            availableCoinDealers[id] = nil
        end

        availableCoinDealerElements[pedElement] = nil

        dbExec(sql, "DELETE FROM coindealers WHERE id = ?", id)

        local syntax = exports.cr_core:getServerSyntax("Blackjack", "success")
        local hexColor = exports.cr_core:getServerColor("yellow", true)

        outputChatBox(syntax .. "Sikeresen töröltél egy zseton eladó npc-t! " .. hexColor .. "(" .. id .. ")", thePlayer, 255, 0, 0, true)

        local adminSyntax = exports.cr_admin:getAdminSyntax()
        local localName = exports.cr_admin:getAdminName(thePlayer, true)

        exports.cr_core:sendMessageToAdmin(thePlayer, adminSyntax .. hexColor .. localName .. white .. " törölt egy zseton eladó npc-t. " .. hexColor .. "(" .. id .. ")", 3)
    end
end
addCommandHandler("deletecoindealer", deleteCoinDealerCommand, false, false)
addCommandHandler("delcoindealer", deleteCoinDealerCommand, false, false)

function createBlackJackTableCommand(thePlayer, cmd)
    if exports.cr_permission:hasPermission(thePlayer, cmd) then 
        local concatenatedPosition = table.concat({getElementPosition(thePlayer)}, ", ")
        local concatenatedRotation = table.concat({getElementRotation(thePlayer)}, ", ")

        local interior = thePlayer.interior
        local dimension = thePlayer.dimension

        local createdAt = os.time()
        local createdBy = exports.cr_admin:getAdminName(thePlayer)

        dbExec(sql, "INSERT INTO blackjackTables SET position = ?, rotation = ?, interior = ?, dimension = ?, createdAt = ?, createdBy = ?", concatenatedPosition, concatenatedRotation, interior, dimension, createdAt, createdBy)

        dbQuery(
            function(queryHandle, thePlayer)
                local query, query_lines = dbPoll(queryHandle, 0)

                if query_lines > 0 then 
                    local row = query[1]

                    loadBlackJackTable(row)

                    if isElement(thePlayer) then 
                        local syntax = exports.cr_core:getServerSyntax("Blackjack", "success")
                        local hexColor = exports.cr_core:getServerColor("yellow", true)

                        outputChatBox(syntax .. "Sikeresen létrehoztál egy blackjack asztalt! " .. hexColor .. "(" .. row.id .. ")", thePlayer, 255, 0, 0, true)

                        local adminSyntax = exports.cr_admin:getAdminSyntax()
                        local localName = exports.cr_admin:getAdminName(thePlayer, true)

                        exports.cr_core:sendMessageToAdmin(thePlayer, adminSyntax .. hexColor .. localName .. white .. " létrehozott egy blackjack asztalt. " .. hexColor .. "(" .. row.id .. ")", 3)
                    end
                end
            end, {thePlayer}, sql, "SELECT * FROM blackjackTables WHERE createdAt = ? AND id = LAST_INSERT_ID()", createdAt
        )
    end
end
addCommandHandler("createblackjacktable", createBlackJackTableCommand, false, false)

function deleteBlackJackTableCommand(thePlayer, cmd, id)
    if exports.cr_permission:hasPermission(thePlayer, cmd) then 
        if not id then 
            local syntax = exports.cr_core:getServerSyntax(false, "lightyellow")

            outputChatBox(syntax .. "/" .. cmd .. " [id]", thePlayer, 255, 0, 0, true)
            return
        end

        local id = tonumber(id)

        if not id then 
            local syntax = exports.cr_core:getServerSyntax(false, "error")

            outputChatBox(syntax .. "Csak szám.", thePlayer, 255, 0, 0, true)
            return
        end

        if not availableBlackJackTables[id] then 
            local syntax = exports.cr_core:getServerSyntax(false, "error")

            outputChatBox(syntax .. "Nem létezik blackjack asztal ezzel az id-vel.", thePlayer, 255, 0, 0, true)
            return
        end

        local tableData = availableBlackJackTables[id]
        local tableElement = tableData.tableElement

        if isElement(tableData.tableElement) then 
            tableData.tableElement:destroy()
            tableData.tableElement = nil
        end

        if isElement(tableData.dealerElement) then 
            tableData.dealerElement:destroy()
            tableData.dealerElement = nil
        end

        availableBlackJackTables[id] = nil
        availableBlackJackTableElements[tableElement] = nil

        dbExec(sql, "DELETE FROM blackjackTables WHERE id = ?", id)

        local syntax = exports.cr_core:getServerSyntax("Blackjack", "success")
        local hexColor = exports.cr_core:getServerColor("yellow", true)

        outputChatBox(syntax .. "Sikeresen töröltél egy blackjack asztalt! " .. hexColor .. "(" .. id .. ")", thePlayer, 255, 0, 0, true)

        local adminSyntax = exports.cr_admin:getAdminSyntax()
        local localName = exports.cr_admin:getAdminName(thePlayer, true)

        exports.cr_core:sendMessageToAdmin(thePlayer, adminSyntax .. hexColor .. localName .. white .. " törölt egy blackjack asztalt. " .. hexColor .. "(" .. id .. ")", 3)
    end
end
addCommandHandler("deleteblackjacktable", deleteBlackJackTableCommand, false, false)
addCommandHandler("delblackjacktable", deleteBlackJackTableCommand, false, false)