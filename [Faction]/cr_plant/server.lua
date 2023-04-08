local sql = exports.cr_mysql:getConnection(getThisResource())

local growthTimer = false
local saveTimer = false

addEventHandler("onResourceStart", root,
    function(startedRes)
        if getResourceName(startedRes) == "cr_mysql" then 
            sql = exports.cr_mysql:getConnection(getThisResource())
            restartResource(getThisResource())
        elseif startedRes == getThisResource() then
            loadAllPlant()

            if isTimer(growthTimer) then 
                killTimer(growthTimer)
                growthTimer = nil
            end

            if isTimer(saveTimer) then 
                killTimer(saveTimer)
                saveTimer = nil
            end

            growthTimer = setTimer(managePlantsGrowth, 60 * 60000, 0)
            saveTimer = setTimer(saveAllPlant, 90 * 60000, 0)
        end
    end
)

local potCache = {}
local potElementCache = {}
local plantCache = {}
local plantElementCache = {}

local waterCanCache = {}

function loadPlant(row)
    local id = tonumber(row.id)
    local objectId = tonumber(row.objectId)
    local position = fromJSON(row.position)
    local status = tonumber(row.status)
    local growth = tonumber(row.growth)
    local moisture = tonumber(row.moisture)

    local potX, potY, potZ = position.x, position.y, position.z
    local potInterior, potDimension = position.interior, position.dimension
    local potObject = Object(potObjectId, potX, potY, potZ)

    potObject.interior = potInterior
    potObject.dimension = potDimension

    potObject:setData("plant >> pot", true)

    potCache[id] = potObject
    potElementCache[potObject] = id

    if objectId and objectId > 0 and plantTypes[objectId] then 
        local plantObject = Object(objectId, potX, potY, potZ)
        local objectSize = math.max(0, math.min(1, growth / 100))

        plantObject.interior = potInterior
        plantObject.dimension = potDimension
        plantObject.collisions = false
        plantObject:setScale(objectSize)

        plantObject:setData("plant >> id", id)
        plantObject:setData("plant >> status", status)
        plantObject:setData("plant >> growth", growth)
        plantObject:setData("plant >> moisture", moisture)
        plantObject:setData("plant >> parent", potObject)
        potObject:setData("plant >> parent", plantObject)

        plantCache[id] = plantObject
        plantElementCache[plantObject] = id
    end
end

function loadAllPlant()
    local loaded = 0
    local startTick = getTickCount()

    dbQuery(
        function(queryHandle)
            local query, query_lines = dbPoll(queryHandle, 0)

            if query_lines > 0 then 
                Async:foreach(query,
                    function(row)
                        loaded = loaded + 1

                        loadPlant(row)
                    end,

                    function()
                        collectgarbage("collect")
                        outputDebugString("@loadAllPlant: loaded " .. loaded .. " / " .. query_lines .. " plant(s) in " .. getTickCount() - startTick .. " ms.", 0, 255, 50, 255)
                    end
                )
            end
        end, sql, "SELECT * FROM plants"
    )
end

function createPlant(itemId, objectId)
    if isElement(client) and itemId and objectId then 
        local objectId = tonumber(objectId)

        local x, y, z = getElementPosition(client)
        local z = z - 0.8

        local interior, dimension = client.interior, client.dimension
        local position = {x = x, y = y, z = z, interior = interior, dimension = dimension}
        local jsonObject = toJSON(position)

        dbExec(sql, "INSERT INTO plants SET objectId = ?, position = ?", objectId, jsonObject)

        dbQuery(
            function(queryHandle, thePlayer)
                local query, query_lines = dbPoll(queryHandle, 0)

                if query_lines > 0 then 
                    local row = query[1]

                    loadPlant(row)

                    if isElement(thePlayer) then 
                        local syntax = exports.cr_core:getServerSyntax("Drug", "success")
                        outputChatBox(syntax .. "Sikeresen leraktad a cserepet.", thePlayer, 255, 0, 0, true)
                    end
                end
            end, {client}, sql, "SELECT * FROM plants WHERE position = ? AND id = LAST_INSERT_ID()", jsonObject
        )
    end
end
addEvent("plant.createPlant", true)
addEventHandler("plant.createPlant", root, createPlant)

function destroyPlant(object, addItem)
    if isElement(client) and isElement(object) then 
        local potObject = object:getData("plant >> parent")

        if isElement(potObject) then 
            local id = object:getData("plant >> id")
            local growth = object:getData("plant >> growth") or 0
            local status = object:getData("plant >> status") or 0

            local plantObjectId = object.model
            local plantData = plantTypes[plantObjectId]
            
            if plantData then 
                if growth >= 85 then 
                    if status > minStatus then 
                        local itemId = plantData.itemId
                        local randomCount = growth == 100 and math.random(2, 5) or growth >= 85 and 1 or false

                        if randomCount then 
                            exports.cr_inventory:giveItem(client, itemId, 1, randomCount)

                            local syntax = exports.cr_core:getServerSyntax("Drug", "success")
                            local hexColor = exports.cr_core:getServerColor("yellow", true)
                            local itemName = exports.cr_inventory:getItemName(itemId)

                            outputChatBox(syntax .. "Sikeresen betakarítottad a növényt. Kaptál " .. hexColor .. randomCount .. white .. " db " .. hexColor .. itemName .. white .. "-t.", client, 255, 0, 0, true)
                        end
                    else 
                        exports.cr_inventory:giveItem(client, witheredPlantItemId, 1)

                        local syntax = exports.cr_core:getServerSyntax("Drug", "error")
                        outputChatBox(syntax .. "A növény nem volt betakarításra kész, vagy nagyon rossz volt az állapota, és ezért nem kaptál semmit.", client, 255, 0, 0, true)
                    end
                end
            end

            dbExec(sql, "DELETE FROM plants WHERE id = ?", id)

            potObject:destroy()
            object:destroy()

            potCache[id] = nil
            potElementCache[potObject] = nil

            plantCache[id] = nil
            plantElementCache[object] = nil

            collectgarbage("collect")
        end
    end
end
addEvent("plant.destroyPlant", true)
addEventHandler("plant.destroyPlant", root, destroyPlant)

function managePlantGrowth(object)
    if isElement(object) then 
        local growth = object:getData("plant >> growth")
        local status = object:getData("plant >> status")
        local moisture = object:getData("plant >> moisture")

        if growth and moisture then 
            if moisture <= minMoisture then 
                if status > 0 then 
                    local randomValue = math.random(1, 5)
                    local newStatus = math.max(0, status - randomValue)

                    object:setData("plant >> status", newStatus)
                end
            else
                if growth < 100 then 
                    local randomValue = math.random(1, 4)
                    local newGrowth = math.min(100, growth + randomValue)
                    local newSize = math.max(0, math.min(1, newGrowth / 100))

                    object:setScale(newSize)
                    object:setData("plant >> growth", newGrowth)
                end
            end

            local randomValue = math.random(3, 8)
            local newMoisture = math.max(0, moisture - randomValue)

            object:setData("plant >> moisture", newMoisture)
        end
    end
end

function manageWaterCan(thePlayer, state, value)
    local thePlayer = thePlayer or client

    if isElement(thePlayer) then 
        local id = thePlayer:getData("acc >> id")

        if state == "create" then
            if not waterCanCache[id] then 
                local object = Object(3385, 0, 0, 0, 0, 0, 0)

                object.interior = thePlayer.interior
                object.dimension = thePlayer.dimension
                object.collisions = false

                exports.cr_bone_attach:attachElementToBone(object, thePlayer, 12, 0, 0.02, 0.0, -5, 0, 0)
                exports.cr_chat:createMessage(thePlayer, "elővesz egy vizes kannát.", 1)

                waterCanCache[id] = object

                thePlayer:setData("usingWaterCan", value)
            end
        elseif state == "destroy" then
            local object = waterCanCache[id]

            if isElement(object) then 
                exports.cr_bone_attach:detachElementFromBone(object)
                object:destroy()
            end

            exports.cr_chat:createMessage(thePlayer, "elrak egy vizes kannát.", 1)
            waterCanCache[id] = nil

            thePlayer:removeData("usingWaterCan")
        end
    end
end
addEvent("plant.manageWaterCan", true)
addEventHandler("plant.manageWaterCan", root, manageWaterCan)

function manageWatering(players, state)
    if isElement(client) and players then 
        local id = client:getData("acc >> id")

        if not waterCanCache[id] then 
            return
        end

        triggerClientEvent(players, "plant.manageWatering", client, state, waterCanCache[id])
    end
end
addEvent("plant.manageWatering", true)
addEventHandler("plant.manageWatering", root, manageWatering)

function managePlantsGrowth()
    for k, v in pairs(plantElementCache) do 
        if isElement(k) then 
            local co = coroutine.create(managePlantGrowth)
            coroutine.resume(co, k)
        end
    end
end

function savePlant(object)
    if isElement(object) then 
        local id = object:getData("plant >> id")
        local growth = object:getData("plant >> growth")
        local status = object:getData("plant >> status")
        local moisture = object:getData("plant >> moisture")

        dbExec(sql, "UPDATE plants SET growth = ?, status = ?, moisture = ? WHERE id = ?", growth, status, moisture, id)
    end
end

function saveAllPlant()
    local saved = 0
    local startTick = getTickCount()

    for k, v in pairs(plantElementCache) do 
        if isElement(k) then 
            local co = coroutine.create(savePlant)
            coroutine.resume(co, k)

            saved = saved + 1
        end
    end

    outputDebugString("@saveAllPlant: saved " .. saved .. " plant(s) in " .. getTickCount() - startTick .. " ms.", 0, 255, 50, 255)
end
-- addEventHandler("onResourceStop", resourceRoot, saveAllPlant)