connection = exports['cr_mysql']:getConnection(getThisResource())
addEventHandler("onResourceStart", root, 
    function(startedRes)
        if getResourceName(startedRes) == "cr_mysql" then
            connection = exports['cr_mysql']:getConnection(getThisResource())
            restartResource(getThisResource())
        end
    end
)

cache = {}
idCache = {}

Async:setPriority("high")
Async:setDebug(true)

function loadFurniture(row)
    local id = tonumber(row["id"])
    local objectID = tonumber(row["objectID"])
    local owner = tonumber(row["owner"])
    local position = fromJSON(tostring(row["position"]))
    local x,y,z,dim,int,rotX,rotY,rotZ = unpack(position)

    local obj = Object(objectID, x, y, z)
    obj.rotation = Vector3(rotX, rotY, rotZ)
    obj.dimension = dim 
    obj.interior = int 
    obj:setData("furniture >> id", id)
    obj:setData("furniture >> owner", owner)

    cache[obj] = id
    idCache[id] = obj 
end 

function destroyFurniture(id)
    if idCache[id] then 
        local obj = idCache[id]
        cache[obj] = nil 
        obj:destroy()
        idCache[id] = nil 
        collectgarbage("collect")

        dbExec(connection, "DELETE FROM furniture WHERE id=?", id)
    elseif cache[id] then 
        local obj = id
        local id = cache[obj]
        cache[obj] = nil 
        obj:destroy()
        idCache[id] = nil 
        collectgarbage("collect")

        dbExec(connection, "DELETE FROM furniture WHERE id=?", id)
    end 
end 

function loadFurnitures()
    dbQuery(
        function(query)
            local query, query_lines = dbPoll(query, 0)
            local tick = getTickCount()
            if query_lines > 0 then
                Async:foreach(query, 
                    loadFurniture,
                    
                    function()
                        collectgarbage("collect")
                        outputDebugString("Loaded "..query_lines.." furniture in "..(getTickCount()-tick).."ms!", 0, 255, 50, 255)
                    end
                )
            end    
        end, 
    connection, "SELECT * FROM furniture")
end 
addEventHandler("onResourceStart", resourceRoot, loadFurnitures)

function createFurniture(sourcePlayer, objectID, x, y, z, dim, int)
    if sourcePlayer:getData("loggedIn") then 
        local position = toJSON({x,y,z,dim,int,0,0,0})
        dbExec(connection, "INSERT INTO furniture SET objectID=?, owner=?, position=?", objectID, sourcePlayer:getData("acc >> id"), position)

        dbQuery(
            function(query)
                local query, query_lines = dbPoll(query, 0)
                local tick = getTickCount()
                if query_lines > 0 then
                    Async:foreach(query, 
                        loadFurniture,
                        
                        function()
                            collectgarbage("collect")
                            outputDebugString("Loaded "..query_lines.." furniture in "..(getTickCount()-tick).."ms!", 0, 255, 50, 255)
                        end
                    )
                end    
            end, 
        connection, "SELECT * FROM furniture WHERE objectID=? AND owner=? AND position=?", objectID, sourcePlayer:getData("acc >> id"), position)
    end 
end 
addEvent("createFurniture", true)
addEventHandler("createFurniture", root, createFurniture)

addEvent("destroyFurniture", true)
addEventHandler("destroyFurniture", root, 
    function(sourcePlayer, obj)
        if cache[obj] then 
            local itemid = exports['cr_inventory']:getFurnitureItemIDByObjectID(obj.model)
            exports['cr_inventory']:giveItem(sourcePlayer, itemid)

            destroyFurniture(obj)
        end 
    end 
)

addEvent("updateFurniturePosition", true)
addEventHandler("updateFurniturePosition", root, 
    function(sourcePlayer, obj, x, y, z, rx, ry, rz)
        if cache[obj] then 
            obj.position = Vector3(x,y,z)
            obj.rotation = Vector3(rx,ry,rz)
            local id = cache[obj]
            local position = toJSON({x,y,z,obj.dimension,obj.interior,rx,ry,rz})
            dbExec(connection, "UPDATE furniture SET position=? WHERE id=?", position, id)
        end 
    end 
)