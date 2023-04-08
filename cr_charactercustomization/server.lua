local sql = exports.cr_mysql:getConnection(getThisResource())

function createAttachmentPed(data)
    local clothesPed = Ped(data.skinId, data.position)

    clothesPed.interior = data.interior
    clothesPed.dimension = data.dimension
    clothesPed.rotation = data.rotation
    clothesPed.frozen = true

    clothesPed:setData("ped.name", data.name)
    clothesPed:setData("ped.type", data.typ)
    clothesPed:setData("ped >> clothes", true)
    clothesPed:setData("char >> noDamage", true)
end

function onStart(startedRes)
    if getResourceName(startedRes) == "cr_mysql" then 
        sql = exports.cr_mysql:getConnection(getThisResource())
        restartResource(getThisResource())
    elseif startedRes == getThisResource() then 
        loadAllAttachments()

        for i = 1, #clothesPedData do 
            local v = clothesPedData[i]
    
            createAttachmentPed(v)
        end
    end
end
addEventHandler("onResourceStart", root, onStart)

local cache = {}
local slotCache = {}
local attachmentsInUse = {}

function checkSlotArray(id)
    if not slotCache[id] then 
        slotCache[id] = {{}, {}}
    end
end

function loadAttachment(row, attach, thePlayer)
    local id = tonumber(row.id)
    local ownerId = tonumber(row.ownerId)
    local slot = tonumber(row.slot)
    local data = fromJSON(row.data)

    if not cache[ownerId] then 
        cache[ownerId] = {}
    end

    if slot and slot > 0 then 
        checkSlotArray(ownerId)

        if not slotCache[ownerId][slot] then 
            slotCache[ownerId][slot] = {}
        end
    end

    if data and data.name then 
        local category = data.category
        local name = data.name
        local price = data.price
        local onlypp = data.onlypp
        local ppPrice = data.ppPrice
        local bone = data.bone
        local inUse = data.inUse
        local objectId = data.objectId
        local objectData = data.objectData
        local x, y, z = objectData.x, objectData.y, objectData.z
        local rx, ry, rz = objectData.rx, objectData.ry, objectData.rz

        local scaleData = objectData.scaleData
        local objectData = {
            x = x,
            y = y,
            z = z,
            rx = rx,
            ry = ry,
            rz = rz,
            scaleData = scaleData
        }

        if not cache[ownerId][category] then 
            cache[ownerId][category] = {}
        end

        local tableData = {
            id = id,
            category = category,
            name = name,
            price = price,
            onlypp = onlypp,
            ppPrice = ppPrice,
            bone = bone,
            inUse = inUse,
            objectId = objectId,
            objectData = objectData,
            slot = slot
        }

        table.insert(cache[ownerId][category], tableData)

        if slot and slot > 0 then 
            slotCache[ownerId][slot] = tableData

            if attach then 
                local isOnline, playerElement = exports.cr_account:getAccountOnline(ownerId)
    
                if isOnline and isElement(playerElement) then 
                    if inUse then 
                        -- thePlayer, objectId, boneId, boneData, category, index, updateClient, slot
                        createAttachment(playerElement, objectId, bone, objectData, category, false, false, slot)
                    end
                end
            end
        end
    end
end

function loadAllAttachments()
    local loaded = 0
    local startTick = getTickCount()

    dbQuery(
        function(queryHandle)
            local query, query_lines = dbPoll(queryHandle, 0)

            if query_lines > 0 then 
                Async:foreach(query,
                    function(row)
                        loaded = loaded + 1

                        loadAttachment(row, true)
                    end,

                    function()
                        collectgarbage("collect")
                        outputDebugString("@loadAllAttachments: loaded " .. loaded .. " / " .. query_lines .. " attachment(s) in " .. (getTickCount() - startTick) .. " ms.", 0, 255, 50, 255)
                    end
                )
            end
        end, sql, "SELECT * FROM attachments"
    )
end

function checkFactionAttachments(thePlayer)
    local sourcePlayer = client or thePlayer

    if isElement(sourcePlayer) then 
        local id = sourcePlayer:getData("acc >> id")

        if id and id > 0 then 
            for k, v in pairs(factionClothes) do 
                setTimer(
                    function()
                        if v.availableForFactions then 
                            local index = hasAttachment(sourcePlayer, v.objectId)
                            local eligible = isPlayerEligible(sourcePlayer, v.availableForFactions)
        
                            if eligible and not index then 
                                local category = v.category
                                local name = v.name
                                local price = v.price
                                local onlypp = v.onlypp
                                local ppPrice = v.ppPrice
                                local bone = v.bone
                                local defaultRotation = v.defaultRotation
                                local objectId = v.objectId
        
                                local boneX, boneY, boneZ = 0, 0, 0
                                local boneRx, boneRy, boneRz = 0, 0, 0
        
                                local data = {
                                    category = category,
                                    name = name,
                                    price = price,
                                    onlypp = onlypp,
                                    ppPrice = ppPrice,
                                    bone = bone,
                                    defaultRotation = defaultRotation,
                                    inUse = false,
                                    objectId = objectId,
                                    objectData = {
                                        x = boneX,
                                        y = boneY,
                                        z = boneZ,
                                        rx = boneRx,
                                        ry = boneRy,
                                        rz = boneRz,
                                        scaleData = {
                                            x = 1,
                                            y = 1,
                                            z = 1
                                        }
                                    }
                                }
        
                                buyAttachment(sourcePlayer, data)
                            else
                                if not eligible and index then 
                                    local category = v.category
                                    local objectId = v.objectId
        
                                    local slotId = hasAttachmentInSlot(sourcePlayer, objectId)
        
                                    if slotId and slotCache[id] then 
                                        destroyAttachment(sourcePlayer, objectId, category, index, slotId)
                                    end
        
                                    if cache[id] and cache[id][category] and cache[id][category][index] then 
                                        local dbId = cache[id][category][index].id
        
                                        dbExec(sql, "DELETE FROM attachments WHERE id = ?", dbId)
                                        table.remove(cache[id][category], index)
        
                                        loadAttachments(sourcePlayer)
                                        loadUsingAttachments(sourcePlayer)
                                    end
                                end
                            end
                        end
                    end, 5000, 1
                )
            end
        end
    end
end
addEvent("attachments.checkFactionAttachments", true)
addEventHandler("attachments.checkFactionAttachments", root, checkFactionAttachments)

function loadAttachments(thePlayer)
    local sourcePlayer = client or thePlayer

    if isElement(sourcePlayer) then 
        local id = sourcePlayer:getData("acc >> id")

        if id and id > 0 then 
            if not slotCache[id] then 
                slotCache[id] = {{}, {}}

                dbExec(sql, "INSERT INTO attachments SET data = ?, slot = ?, ownerId = ?", toJSON({}), 1, id)
                dbExec(sql, "INSERT INTO attachments SET data = ?, slot = ?, ownerId = ?", toJSON({}), 2, id)
            end
            
            local attachments = cache[id] or {}
            local slots = slotCache[id]

            checkFactionAttachments(sourcePlayer)
            triggerClientEvent(sourcePlayer, "attachments.loadAttachments", sourcePlayer, attachments, slots)
        end
    end
end
addEvent("attachments.loadAttachments", true)
addEventHandler("attachments.loadAttachments", root, loadAttachments)

function loadUsingAttachments(thePlayer)
    if isElement(thePlayer) then 
        local id = thePlayer:getData("acc >> id")

        if id and id > 0 then 
            if attachmentsInUse[id] then 
                triggerClientEvent(thePlayer, "attachments.loadUsingAttachments", thePlayer, attachmentsInUse[id])
            end
        end
    end
end
addEvent("attachments.loadUsingAttachments", true)
addEventHandler("attachments.loadUsingAttachments", root, loadUsingAttachments)

function buyAttachmentSlot(slot)
    if isElement(client) then 
        local premiumPoints = client:getData("char >> premiumPoints") or 0

        if premiumPoints < slotPrice then 
            exports.cr_infobox:addBox(client, "error", "Nincs elég prémiumpontod a slot megvásárlásához!")

            return
        end

        client:setData("char >> premiumPoints", premiumPoints - slotPrice)

        local id = client:getData("acc >> id")

        if id and id > 0 then 
            checkSlotArray(id)

            if not slotCache[id][slot] then 
                slotCache[id][slot] = {}
            end

            dbExec(sql, "INSERT INTO attachments SET data = ?, slot = ?, ownerId = ?", toJSON({}), slot, id)

            exports.cr_infobox:addBox(client, "success", "Sikeresen megvásároltad a kiválasztott slotot!")
            loadAttachments(client)
        end
    end
end
addEvent("attachments.buySlot", true)
addEventHandler("attachments.buySlot", root, buyAttachmentSlot)

function buyAttachment(thePlayer, data)
    local sourcePlayer = client or thePlayer

    if isElement(sourcePlayer) and data then 
        local id = sourcePlayer:getData("acc >> id")

        if id and id > 0 then 
            local jsonData = toJSON(data)

            dbExec(sql, "INSERT INTO attachments SET ownerId = ?, data = ?, slot = ?", id, jsonData, 0)

            dbQuery(
                function(queryHandle, thePlayer)
                    local query, query_lines = dbPoll(queryHandle, 0)

                    if query_lines > 0 then 
                        local row = query[1]

                        loadAttachment(row, false, thePlayer)
                        loadAttachments(thePlayer)
                    end
                end, {sourcePlayer}, sql, "SELECT * FROM attachments WHERE id = LAST_INSERT_ID() AND ownerId = ?", id
            )
        end
    end
end
addEvent("attachments.buyAttachment", true)
addEventHandler("attachments.buyAttachment", root, buyAttachment)

function createAttachment(thePlayer, objectId, boneId, boneData, category, index, updateClient, slot)
    if isElement(thePlayer) and objectId and boneId and boneData then 
        local id = thePlayer:getData("acc >> id")
        local index = index or hasAttachment(thePlayer, objectId)
        local oldInUse = true

        if id and id > 0 then 
            if not attachmentsInUse[id] then 
                attachmentsInUse[id] = {}
            end

            local boneX, boneY, boneZ = boneData.x, boneData.y, boneData.z
            local boneRx, boneRy, boneRz = boneData.rx, boneData.ry, boneData.rz
            
            local scaleData = boneData.scaleData
            local scaleX, scaleY, scaleZ = scaleData.x, scaleData.y, scaleData.z

            local obj = Object(objectId, 0, 0, 0)

            obj.interior = thePlayer.interior
            obj.dimension = thePlayer.dimension

            obj:setScale(scaleX, scaleY, scaleZ)
            obj:setData("attachmentParent", thePlayer)

            attachmentsInUse[id][objectId] = obj

            if category and index and cache[id][category][index] then 
                oldInUse = cache[id][category][index].inUse
                cache[id][category][index].inUse = true
            end

            local data = cache[id][category][index]
            local dbId = data.id
            local name = data.name
            local price = data.price
            local onlypp = data.onlypp
            local ppPrice = data.ppPrice
            local inUse = data.inUse

            local wholeData = {
                id = dbId,
                category = category,
                name = name,
                price = price,
                onlypp = onlypp,
                ppPrice = ppPrice,
                bone = boneId,
                inUse = inUse,
                objectId = objectId,
                objectData = boneData,
            }

            if slot then 
                if not slotCache[id] then 
                    slotCache[id] = {}
                end

                if not slotCache[id][slot] or not slotCache[id][slot].id then 
                    slotCache[id][slot] = wholeData
                end
            end

            if not oldInUse then 
                local jsonData = toJSON(wholeData)

                dbExec(sql, "UPDATE attachments SET slot = ?, data = ? WHERE ownerId = ? AND id = ?", slot, jsonData, id, dbId)
            end

            exports.cr_bone_attach:attachElementToBone(obj, thePlayer, boneId, boneX, boneY, boneZ, boneRx, boneRy, boneRz)

            if updateClient then 
                loadAttachments(thePlayer)
                loadUsingAttachments(thePlayer)
            end
        end
    end
end
addEvent("attachments.createAttachment", true)
addEventHandler("attachments.createAttachment", root, createAttachment)

function destroyAttachment(thePlayer, objectId, category, index, slot)
    if isElement(thePlayer) and objectId and category and index and slot then 
        local id = thePlayer:getData("acc >> id")

        if id and id > 0 then 
            if attachmentsInUse[id] and isElement(attachmentsInUse[id][objectId]) then 
                exports.cr_bone_attach:detachElementFromBone(attachmentsInUse[id][objectId])

                attachmentsInUse[id][objectId]:destroy()
                attachmentsInUse[id][objectId] = nil

                cache[id][category][index].inUse = false
                slotCache[id][slot] = {}

                local data = cache[id][category][index]
                local dbId = data.id
                local jsonData = toJSON(data)

                dbExec(sql, "UPDATE attachments SET slot = ?, data = ? WHERE ownerId = ? AND id = ?", 0, jsonData, id, dbId)

                loadAttachments(thePlayer)
                loadUsingAttachments(thePlayer)
                collectgarbage("collect")
            end
        end
    end
end
addEvent("attachments.destroyAttachment", true)
addEventHandler("attachments.destroyAttachment", root, destroyAttachment)

function saveAttachment(thePlayer, objectId, objectData, category, index, dbId)
    if isElement(thePlayer) and objectId and objectData and category and index then 
        local id = thePlayer:getData("acc >> id")

        if id and id > 0 then 
            if attachmentsInUse[id] and isElement(attachmentsInUse[id][objectId]) then 
                local x, y, z = objectData.x, objectData.y, objectData.z
                local rx, ry, rz = objectData.rx, objectData.ry, objectData.rz

                local scaleData = objectData.scaleData
                local scaleX, scaleY, scaleZ = scaleData.x, scaleData.y, scaleData.z

                cache[id][category][index].objectData = {
                    x = x,
                    y = y,
                    z = z,
                    rx = rx,
                    ry = ry,
                    rz = rz,
                    scaleData = scaleData
                }

                cache[id][category][index].inUse = true

                local data = cache[id][category][index]
                local dbId = data.id
                local jsonData = toJSON(data)

                dbExec(sql, "UPDATE attachments SET data = ? WHERE ownerId = ? AND id = ?", jsonData, id, dbId)

                attachmentsInUse[id][objectId]:setScale(scaleX, scaleY, scaleZ)
                exports.cr_bone_attach:setElementBonePositionOffset(attachmentsInUse[id][objectId], x, y, z)
                exports.cr_bone_attach:setElementBoneRotationOffset(attachmentsInUse[id][objectId], rx, ry, rz)
            end
        end
    end
end
addEvent("attachments.saveAttachment", true)
addEventHandler("attachments.saveAttachment", root, saveAttachment)

function createAttachments(thePlayer)
    if isElement(thePlayer) then 
        local id = thePlayer:getData("acc >> id")

        if id and id > 0 then 
            local data = cache[id]

            if data then 
                for k, v in pairs(data) do 
                    for i, v2 in ipairs(v) do 
                        outputChatBox(inspect(v2), thePlayer)
                        if v2.inUse then 
                            local objectId = v2.objectId
                            local boneId = v2.bone
                            local objectData = v2.objectData
                            local category = v2.category
                            local slot = v2.slot

                            createAttachment(thePlayer, objectId, boneId, objectData, category, false, false, slot)
                        end
                    end
                end

                loadAttachments(thePlayer)
                loadUsingAttachments(thePlayer)
            end
        end
    end
end

function destroyAttachments(thePlayer)
    if isElement(thePlayer) then 
        local id = thePlayer:getData("acc >> id")

        if id and id > 0 then 
            if attachmentsInUse[id] then 
                for k, v in pairs(attachmentsInUse[id]) do 
                    exports.cr_bone_attach:detachElementFromBone(v)

                    if isElement(v) then 
                        v:destroy()
                    end
                end

                attachmentsInUse[id] = nil
                collectgarbage("collect")
            end
        end
    end
end

function onDataChange(dataName, oldValue, newValue)
    if source.type == "player" then 
        if dataName == "loggedIn" then 
            if newValue and source:getData(dataName) then 
                createAttachments(source)
            end
        end
    end
end
addEventHandler("onElementDataChange", root, onDataChange)

function onQuit()
    if source:getData("loggedIn") then 
        destroyAttachments(source)
    end
end
addEventHandler("onPlayerQuit", root, onQuit)

-- setTimer(createAttachments, 500, 1, getPlayerFromName("Hugh_Wiley"))

function hasAttachment(thePlayer, gName)
    local result = false

    if isElement(thePlayer) then 
        local id = thePlayer:getData("acc >> id")

        if id and id > 0 then 
            local cache = cache[id]

            if type(gName) == "string" then 
                if cache then 
                    for i = 1, #clothes do 
                        if cache[i] then 
                            for j = 1, #cache[i] do 
                                local v = cache[i][j]

                                if v then 
                                    local name = v.name

                                    if gName:lower() == name:lower() then 
                                        result = j
                                        break
                                    end
                                end
                            end
                        end
                    end
                end
            elseif type(gName) == "number" then 
                if cache then 
                    for i = 1, #clothes do 
                        if cache[i] then 
                            for j = 1, #cache[i] do 
                                local v = cache[i][j]

                                if v then 
                                    local objectId = v.objectId

                                    if objectId == gName then 
                                        result = j
                                        break
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    return result
end

function hasAttachmentInSlot(thePlayer, objectId)
    local result = false

    if isElement(thePlayer) then 
        local id = thePlayer:getData("acc >> id")

        if id and id > 0 then 
            local data = slotCache[id]

            for k, v in pairs(data) do 
                if v.objectId then 
                    if v.objectId == objectId then 
                        result = k
                        break
                    end
                end
            end
        end
    end

    return result
end