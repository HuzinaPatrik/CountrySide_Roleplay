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

white = "#ffffff"

Async:setPriority("high")
Async:setDebug(true)

function loadHifi()
    dbQuery(
        function(query)
            local query, query_lines = dbPoll(query, 0)
            local tick = getTickCount()
            if query_lines > 0 then
                Async:foreach(query, 
                    function(row)
                        local id = tonumber(row["id"])
                        local x = tonumber(row["x"])
                        local y = tonumber(row["y"])
                        local z = tonumber(row["z"])
                        local dim = tonumber(row["dimension"])
                        local int = tonumber(row["interior"])
                        local rot = fromJSON(tostring(row["rotZ"]))
                        if not rot or type(rot) ~= "table" then
                            rot = {0,0,0}
                        end
                        local creator = tonumber(row["creator"])
                        local obj = createObject(2102,x,y,z)
                        --local rot = fromJSON
                        obj:setData("hifi >> creator", creator)
                        obj:setData("hifi >> volume", 1)
                        obj.rotation = Vector3(rot[1], rot[2], rot[3])
                        obj.dimension = dim 
                        obj.interior = int
                        --obj.collisions = false
                        cache[obj] = id
                        --outputDebugString("Loading item #"..id, 0, 255, 50, 255)
                    end,
                    -- callback
                    function()
                        --setElementData(root, "loaded", true)
                        collectgarbage("collect")
                        outputDebugString("Loaded "..query_lines.." hifi in "..(getTickCount()-tick).."ms!", 0, 255, 50, 255)
                    end
                )
            end    
        end, 
    connection, "SELECT * FROM `hifi`")
end
addEventHandler("onResourceStart", resourceRoot, loadHifi)

function createHifi(creator, x,y,z, dim, int)
    if isElement(creator) and creator:getData("acc >> id") then
        local obj = createObject(2102,x,y,z,0,0,rotZ)
        obj:setData("hifi >> creator", creator:getData("acc >> id"))
        obj:setData("hifi >> volume", 1)
        obj.dimension = dim 
        obj.interior = int
        --obj.collisions = false
        --cache[obj] = true
        
        dbExec(connection, "INSERT `hifi` SET `x`=?, `y`=?, `z`=?, `dimension`=?, `interior`=?, `rotZ`=?, `creator`=?", x,y,z, dim, int, 0, creator:getData("acc >> id"))
        
        dbQuery(
            function(query)
                local query, query_lines = dbPoll(query, 0)
                if query_lines > 0 then
                    Async:foreach(query, 
                        function(row)
                            local id = tonumber(row["id"])
                            cache[obj] = id
                        end
                    )
                end
            end, 
        connection, "SELECT * FROM `hifi` WHERE `x`=? and `y`=? and `z`=? and `dimension`=? and `interior`=? and `rotZ`=? and `creator`=?", x,y,z, dim, int, 0, creator:getData("acc >> id"))
    end
end
addEvent("createHifi", true)
addEventHandler("createHifi", root, createHifi)

function updateHifiPosition(e, x,y,z)
    if isElement(e) and cache[e] then
        e.position = Vector3(x,y,z)
        dbExec(connection, "UPDATE `hifi` SET `x`=?, `y`=?, `z`=? WHERE `id`=?", x,y,z, cache[e])
    end
end
addEvent("updateHifiPosition", true)
addEventHandler("updateHifiPosition", root, updateHifiPosition)

function updateHifiRotation(e, rot)
    if isElement(e) and cache[e] then
        e.rotation = Vector3(rot[1], rot[2], rot[3])
        dbExec(connection, "UPDATE `hifi` SET `rotZ`=? WHERE `id`=?", toJSON(rot), cache[e])
    end
end
addEvent("updateHifiRotation", true)
addEventHandler("updateHifiRotation", root, updateHifiRotation)

function destroyHifi(destroyer, e)
    if isElement(e) and cache[e] then
        --e.rotation = Vector3(0,0,rotZ)
        local id = cache[e]
        destroyElement(e)
        cache[e] = nil
        dbExec(connection, "DELETE FROM `hifi` WHERE `id`=?", id)
        exports['cr_inventory']:giveItem(destroyer, 22)
        --dbExec(connection, "UPDATE `hifi` SET `rotZ`=? WHERE `id`=?", rotZ, cache[e])
    end
end
addEvent("destroyHifi", true)
addEventHandler("destroyHifi", root, destroyHifi)

addEventHandler("onElementDataChange", resourceRoot,
    function(dName, oValue)
        if dName == "hifi >> movedBy" then
            local val = source:getData(dName)
            --outputChatBox("asd")
            if val then
                source.alpha = 155
                source.collisions = false
            else
                source.alpha = 255
                source.collisions = true
            end
        end
    end
)

function hifiChangeState(element, alpha)
    if isElement(e) and cache[e] then
        e.alpha = alpha
        if alpha == 255 then
            e.collisions = true
        elseif alpha == 180 then
            e.collisions = false
        end
    end
end
addEvent("hifiChangeState", true)
addEventHandler("hifiChangeState", root, hifiChangeState)