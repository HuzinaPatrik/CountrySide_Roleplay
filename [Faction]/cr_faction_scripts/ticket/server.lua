local sql = exports.cr_mysql:getConnection(getThisResource())

addEventHandler("onResourceStart", root,
    function(startedRes)
        if getResourceName(startedRes) == "cr_mysql" then 
            sql = exports.cr_mysql:getConnection(getThisResource())
            restartResource(getThisResource())
        elseif startedRes == getThisResource() then
            loadAllTicketPed()
        end
    end
)

local ticketPedCache = {}

function loadTicketPed(row)
    local id = tonumber(row.id)
    local position = split(row.position, ", ")
    local rotation = split(row.rotation, ", ")

    local interior = tonumber(row.interior)
    local dimension = tonumber(row.dimension)

    local skinId = tonumber(row.skinId)
    local name = tostring(row.name)

    local createdBy = tostring(row.createdBy)
    local createdAt = tonumber(row.createdAt)

    local pedElement = createPed(skinId, position[1], position[2], position[3])

    pedElement.rotation = Vector3(unpack(rotation))
    pedElement.interior = interior
    pedElement.dimension = dimension
    pedElement.frozen = true

    pedElement:setData("ped.name", name)
    pedElement:setData("ped.type", "Csekk befizetés")
    pedElement:setData("char >> noDamage", true)

    pedElement:setData("ticketPed", id)
    pedElement:setData("ticketPed >> createdBy", createdBy)
    pedElement:setData("ticketPed >> createdAt", createdAt)

    ticketPedCache[id] = pedElement
end

function loadAllTicketPed()
    local startTick = getTickCount()
    local loaded = 0

    dbQuery(
        function(queryHandle)
            local query, query_lines = dbPoll(queryHandle, 0)

            if query_lines > 0 then 
                Async:foreach(query,
                    function(row)
                        loadTicketPed(row)

                        loaded = loaded + 1
                    end,

                    function()
                        outputDebugString("@loadAllTicketPed: loaded " .. loaded .. " / " .. query_lines .. " ticket ped(s) in " .. getTickCount() - startTick .. " ms.", 0, 255, 50, 255)
                    end
                )
            end
        end, sql, "SELECT * FROM ticketpeds"
    )
end

function createTicketPedCommand(thePlayer, cmd, skinId, ...)
    if exports.cr_permission:hasPermission(thePlayer, cmd) then 
        if not skinId or not ... then 
            local syntax = exports.cr_core:getServerSyntax(false, "yellow")

            outputChatBox(syntax .. "/" .. cmd .. " [skinId] [név]", thePlayer, 255, 0, 0, true)
            return
        end

        local skinId = tonumber(skinId)
        local name = table.concat({...}, " ")

        if not skinId then 
            local syntax = exports.cr_core:getServerSyntax("Ticket", "error")

            outputChatBox(syntax .. "Csak szám.", thePlayer, 255, 0, 0, true)
            return
        end

        local skinId = math.floor(tonumber(skinId))

        if not exports.cr_skins:isSkinValid(skinId) then 
            local syntax = exports.cr_core:getServerSyntax("Ticket", "error")

            outputChatBox(syntax .. "Hibás skin id.", thePlayer, 255, 0, 0, true)
            return
        end

        if utf8.len(name) <= 0 then 
            local syntax = exports.cr_core:getServerSyntax("Ticket", "error")

            outputChatBox(syntax .. "A névnek minimum 1 karaktert kell tartalmaznia.", thePlayer, 255, 0, 0, true)
            return
        end

        local concatenatedPosition = table.concat({getElementPosition(thePlayer)}, ", ")
        local concatenatedRotation = table.concat({getElementRotation(thePlayer)}, ", ")

        local interior = thePlayer.interior
        local dimension = thePlayer.dimension

        local createdBy = exports.cr_admin:getAdminName(thePlayer)
        local createdAt = os.time()

        dbExec(sql, "INSERT INTO ticketpeds SET position = ?, rotation = ?, interior = ?, dimension = ?, skinId = ?, name = ?, createdBy = ?, createdAt = ?", concatenatedPosition, concatenatedRotation, interior, dimension, skinId, name, createdBy, createdAt)

        dbQuery(
            function(queryHandle, thePlayer)
                local query, query_lines = dbPoll(queryHandle, 0)

                if query_lines > 0 then 
                    local row = query[1]

                    loadTicketPed(row)

                    if isElement(thePlayer) then 
                        local syntax = exports.cr_core:getServerSyntax("Ticket", "success")
                        local hexColor = exports.cr_core:getServerColor("yellow", true)

                        outputChatBox(syntax .. "Sikeresen létrehoztál egy csekk befizetés npc-t! " .. hexColor .. "(" .. row.id .. ")", thePlayer, 255, 0, 0, true)

                        local adminSyntax = exports.cr_admin:getAdminSyntax()
                        local localName = exports.cr_admin:getAdminName(thePlayer, true)

                        exports.cr_core:sendMessageToAdmin(thePlayer, adminSyntax .. hexColor .. localName .. white .. " létrehozott egy csekk befizetés npc-t. " .. hexColor .. "(" .. row.id .. ")", 3)
                    end
                end
            end, {thePlayer}, sql, "SELECT * FROM ticketpeds WHERE createdAt = ? AND id = LAST_INSERT_ID()", createdAt
        )
    end
end
addCommandHandler("createticketped", createTicketPedCommand, false, false)

function deleteTicketPedCommand(thePlayer, cmd, id)
    if exports.cr_permission:hasPermission(thePlayer, cmd) then 
        if not id then 
            local syntax = exports.cr_core:getServerSyntax(false, "yellow")

            outputChatBox(syntax .. "/" .. cmd .. " [id]", thePlayer, 255, 0, 0, true)
            return
        end

        local id = tonumber(id)

        if not id then 
            local syntax = exports.cr_core:getServerSyntax("Ticket", "error")

            outputChatBox(syntax .. "Csak szám.", thePlayer, 255, 0, 0, true)
            return
        end

        local id = math.floor(tonumber(id))

        if not ticketPedCache[id] then 
            local syntax = exports.cr_core:getServerSyntax("Ticket", "error")

            outputChatBox(syntax .. "Nem létezik csekk befizetés npc ezzel az id-vel.", thePlayer, 255, 0, 0, true)
            return
        end

        local pedElement = ticketPedCache[id]

        if isElement(pedElement) then 
            pedElement:destroy()
        end

        dbExec(sql, "DELETE FROM ticketpeds WHERE id = ?", id)
        ticketPedCache[id] = nil

        local syntax = exports.cr_core:getServerSyntax("Ticket", "success")
        local hexColor = exports.cr_core:getServerColor("yellow", true)

        outputChatBox(syntax .. "Sikeresen kitörölted a csekk befizetés npc-t! " .. hexColor .. "(" .. id .. ")", thePlayer, 255, 0, 0, true)

        local adminSyntax = exports.cr_admin:getAdminSyntax()
        local localName = exports.cr_admin:getAdminName(thePlayer, true)

        exports.cr_core:sendMessageToAdmin(thePlayer, adminSyntax .. hexColor .. localName .. white .. " kitörölt egy csekk befizetés npc-t. " .. hexColor .. "(" .. id .. ")", 3)
    end
end
addCommandHandler("deleteticketped", deleteTicketPedCommand, false, false)

function createTicket(offenderElement, ticketData, mdTicket)
    if isElement(client) and isElement(offenderElement) and ticketData then 
        triggerLatentClientEvent(offenderElement, "ticket.showTicket", 50000, false, client, ticketData, mdTicket)

        if isElement(ticketData.offenderElement) then 
            local element = ticketData.offenderElement
            
            ticketData.signedOffender = true
            ticketData.offenderNameSignature = exports.cr_admin:getAdminName(element)

            ticketData.offenderElement = nil
            ticketData.mdTicket = mdTicket
            ticketData.timestamp = os.time() + (24 * 60 * 60) -- 24 óra

            exports.cr_inventory:giveItem(element, 128, ticketData)
        end
    end
end
addEvent("ticket.createTicket", true)
addEventHandler("ticket.createTicket", root, createTicket)