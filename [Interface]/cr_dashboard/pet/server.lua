connection = exports['cr_mysql']:getConnection(getThisResource())
addEventHandler("onResourceStart", root, 
    function(startedRes)
        if getResourceName(startedRes) == "cr_mysql" then
            connection = exports['cr_mysql']:getConnection(getThisResource())
            restartResource(getThisResource())
        end
    end
)

local pets = {}
local playerPets = {}
local spawnedPets = {}

Async:setPriority("high")
Async:setDebug(true)

function loadPets()
    dbQuery(
        function(query)
            local query, query_lines = dbPoll(query, 0)
            if query_lines > 0 then
                Async:foreach(query, 
                    function(row)
                        local id = tonumber(row["id"])
                        local modelid = tonumber(row["modelid"])
                        local owner = tonumber(row["owner"])
                        local name = tostring(row["name"])
                        local data = fromJSON(tostring(row["data"]))
                        pets[id] = {id, modelid, owner, name, data}
                        
                        if not playerPets[tonumber(owner)] then 
                            playerPets[tonumber(owner)] = {}
                        end
                        table.insert(playerPets[tonumber(owner)], id)
                    end
                )
            end
            outputDebugString("Loading pets finished. Loaded #"..query_lines.." pets!", 0, 255, 50, 255)
        end, 
    connection, "SELECT * FROM pets")
end
addEventHandler("onResourceStart", resourceRoot, loadPets)

function getPlayerPets(element)
    if element:getData("loggedIn") then 
        if playerPets[tonumber(element:getData("acc >> id"))] then 
            local data = {}
            for k, v in pairs(playerPets[tonumber(element:getData("acc >> id"))]) do 
                data[v] = pets[v]
            end 
            triggerLatentClientEvent(element, "getPlayerPets", 50000, false, element, data)
        end 
    end 
end 
addEvent("getPlayerPets", true)
addEventHandler("getPlayerPets", root, getPlayerPets)

function createPet(element, modelid, name)
    local element = element
    dbExec(connection, "INSERT INTO pets SET modelid=?, owner=?, name=?", tonumber(modelid), tonumber(element:getData("acc >> id")), name)

    dbQuery(
        function(query)
            local query, query_lines = dbPoll(query, 0)
            if query_lines > 0 then
                Async:foreach(query, 
                    function(row)
                        local id = tonumber(row["id"])
                        local modelid = tonumber(row["modelid"])
                        local owner = tonumber(row["owner"])
                        local name = tostring(row["name"])
                        local data = fromJSON(tostring(row["data"]))
                        pets[id] = {id, modelid, owner, name, data}
                        
                        if not playerPets[tonumber(owner)] then 
                            playerPets[tonumber(owner)] = {}
                        end
                        table.insert(playerPets[tonumber(owner)], id)

                        getPlayerPets(element)
                    end
                )
            end
            outputDebugString("Loading pets finished. Loaded #"..query_lines.." pets!", 0, 255, 50, 255)
        end, 
    connection, "SELECT * FROM pets WHERE modelid=? and owner=? and name=?", tonumber(modelid), tonumber(element:getData("acc >> id")), name)
end 
addEvent("createPet", true)
addEventHandler("createPet", root, createPet)

function spawnPet(element, id)
    if pets[id] then 
        if not spawnedPets[id] then 
            local id, modelid, owner, name, data = unpack(pets[id])
            if data[1] >= 1 then 
                if tonumber(owner or 0) == element:getData("acc >> id") then
                    local x,y,z = getElementPosition(element)
                    local pet = Ped(0, x,y - 2,z)
                    pet:setData("pet >> id", id)
                    pet:setData("pet >> name", name)
                    pet:setData("pet >> owner", owner)
                    pet:setData("pet >> follow", element)
                    pet:setData("pet >> data", data)
                    pet:setData("ped >> skin", modelid)
                    local yellow = exports['cr_core']:getServerColor("yellow")
                    local orange = exports['cr_core']:getServerColor("orangeNew")
                    pet:setData("ped.name", name .. " ["..id.."]")
                    pet:setData("ped.type", "Pet - "..petTypeNames[tonumber(modelid)])
                    pet:setData("ped.id", "Pet")
                    element:setData("pet", pet)
                    setPedStat(pet, 24, 1000)
                    pet.health = data[1]
                    spawnedPets[id] = pet
                end
            else 
                exports['cr_infobox']:addBox(element, "error", "Ez a pet halott!")
            end
        end 
    end 
end 
addEvent("spawnPet", true)
addEventHandler("spawnPet", root, spawnPet)

function revivePet(element, id)
    if pets[id] then 
        local id, modelid, owner, name, data = unpack(pets[id])
        if data[1] <= 0 then 
            if tonumber(owner or 0) == element:getData("acc >> id") then 
                pets[id][5][1] = 200
                local data = pets[id][5]
                dbExec(connection, "UPDATE pets SET data=? WHERE ID=?", toJSON(data), id)

                exports['cr_infobox']:addBox(element, "success", "Sikeresen felélesztetted a petet!")

                getPlayerPets(element)
            end
        else 
            exports['cr_infobox']:addBox(element, "error", "Ez a pet nem halott!")
        end
    end 
end 
addEvent("revivePet", true)
addEventHandler("revivePet", root, revivePet)

function warpPetIntoVehicle(element, seat)
    if element then 
        local pet = element:getData("pet")
        if isElement(pet) then
            warpPedIntoVehicle(pet, element.vehicle, seat)
            pet:setData("char >> belt", true)
        end
    end
end 
addEvent("warpPetIntoVehicle", true)
addEventHandler("warpPetIntoVehicle", root, warpPetIntoVehicle)

function removePetFromVehicle(element)
    if element then 
        local pet = element:getData("pet")
        if isElement(pet) then
            local x,y,z = getElementPosition(pet.vehicle)
            removePedFromVehicle(pet)
            pet:setData("char >> belt", false)
            pet.position = Vector3(x,y,z + 2)
        end
    end 
end 
addEvent("removePetFromVehicle", true)
addEventHandler("removePetFromVehicle", root, removePetFromVehicle)

function deSpawnPet(element, health)
    if element:getData("pet") and isElement(element:getData("pet")) then 
        local id = element:getData("pet"):getData("pet >> id")
        if pets[id] then 
            if spawnedPets[id] then 
                local data = spawnedPets[id]:getData("pet >> data") or {200, 100, 100, 100}
                if not tonumber(health) then 
                    data[1] = spawnedPets[id].health
                else 
                    data[1] = health
                end 
                spawnedPets[id]:destroy()
                spawnedPets[id] = nil
                pets[id][5] = data
                dbExec(connection, "UPDATE pets SET data=? WHERE ID=?", toJSON(data), id)
                element:setData("pet", nil)
            end 
        end 
    end
end 
addEvent("deSpawnPet", true)
addEventHandler("deSpawnPet", root, deSpawnPet)

addEventHandler("onPlayerQuit", root, 
    function()
        if source:getData("pet") then 
            deSpawnPet(source)
        end 
    end 
)

addEventHandler("onResourceStop", resourceRoot, 
    function()
        for k,v in pairs(getElementsByType("player")) do 
            deSpawnPet(v)
        end 
    end 
)

function inviteToTradePet(sourcePlayer, targetPlayer, id, price)
    if isElement(sourcePlayer) and isElement(targetPlayer) and tonumber(id) then 
        if pets[id] and tonumber(price) then 
            if pets[id][3] == sourcePlayer:getData("acc >> id") then 
                triggerLatentClientEvent(targetPlayer, "inviteToTradePet", 50000, false, sourcePlayer, sourcePlayer, pets[id][4], id, price)
            end
        end 
    end 
end
addEvent("inviteToTradePet", true)
addEventHandler("inviteToTradePet", root, inviteToTradePet)

function sellPet(sourcePlayer, targetPlayer, id)
    if isElement(sourcePlayer) and isElement(targetPlayer) and tonumber(id) then 
        if pets[id] then 
            if pets[id][3] == sourcePlayer:getData("acc >> id") then 
                local oldOwner = pets[id][3]
                local newOwner = targetPlayer:getData("acc >> id")
                if tonumber(newOwner) then 
                    pets[id][3] = newOwner
                    dbExec(connection, "UPDATE pets SET owner=? WHERE ID=?", newOwner, id)

                    if not playerPets[tonumber(newOwner)] then 
                        playerPets[tonumber(newOwner)] = {}
                    end
                    table.insert(playerPets[tonumber(newOwner)], id)

                    if playerPets[tonumber(oldOwner)] then 
                        for k,v in pairs(playerPets[tonumber(oldOwner)]) do 
                            if v == id then 
                                table.remove(playerPets[tonumber(oldOwner)], k)
                                break 
                            end 
                        end 
                    end 

                    getPlayerPets(sourcePlayer)
                    getPlayerPets(targetPlayer)
                end 
            end
        end 
    end 
end
addEvent("sellPet", true)
addEventHandler("sellPet", root, sellPet)

function renamePet(sourcePlayer, data, newName)
    if isElement(sourcePlayer) and data and newName then 
        local id = data[1]
        if pets[id] then 
            if pets[id][3] == sourcePlayer:getData("acc >> id") then 
                pets[id][4] = newName
                dbExec(connection, "UPDATE pets SET name=? WHERE ID=?", newName, id)
                if sourcePlayer:getData("pet") and sourcePlayer:getData("pet"):getData("pet >> id") == id then 
                    sourcePlayer:getData("pet"):setData("pet >> name", newName)
                    sourcePlayer:getData("pet"):setData("ped.name", newName)
                end

                getPlayerPets(sourcePlayer)

                exports['cr_infobox']:addBox(sourcePlayer, "success", "Sikeresen megváltoztattad a pet nevét "..newName.."-ra/re!")
            end
        end 
    end 
end
addEvent("renamePet", true)
addEventHandler("renamePet", root, renamePet)

addEvent("playSound3D", true)
addEventHandler("playSound3D", root, 
    function(sourcePlayer, sourceElement, sendTo, path)
        triggerLatentClientEvent(sendTo, "playSound3D", 50000, false, sourcePlayer, sourceElement, path)
    end 
)