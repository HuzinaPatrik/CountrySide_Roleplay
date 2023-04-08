local cache = {}

local connection = exports['cr_mysql']:getConnection(getThisResource())
addEventHandler("onResourceStart", root, 
    function(startedRes)
        if getResourceName(startedRes) == "cr_mysql" then
            connection = exports['cr_mysql']:getConnection(getThisResource())
            restartResource(getThisResource())
        end
    end
)

Async:setPriority("high")
Async:setDebug(true)

addEventHandler("onResourceStart", resourceRoot, 
    function()
        dbQuery(function(query)
            local query, query_lines = dbPoll(query, 0)
            if query_lines > 0 then
                --for i, row in pairs(query) do
                Async:foreach(query, function(row)
                    --local id = tonumber(row["id"])
                    loadSpeedCam(row)
                end) 
            end
			outputDebugString("[Success] Loading trafficboards has finished successfuly. Loaded: " .. query_lines .. " trafficboards!")
        end, connection, "SELECT * FROM `trafficboards`")
    end
)

function loadSpeedCam(details)
    local id = tonumber(details["id"])
    local type = tonumber(details["type"])
    local pos = fromJSON(tostring(details["pos"]))
    local modelid = 1375
    local x,y,z,int,dim,rot = unpack(pos)

    local object = createObject(modelid, x,y,z)
    setElementDimension(object, dim)
    setElementInterior(object, int)
    setElementRotation(object, 0,0,rot)
    setElementData(object, "TrafficBoards.id", id)
    setElementData(object, "TrafficBoards.type", type)
    setElementData(object, "defPositions", {x = x,y = y,z = z})
end

function createTrafficBoards(table1, type, sourceElement)
    local a1 = toJSON(table1)
    dbExec(connection, "INSERT INTO `trafficboards` SET `pos`=?, `type`=?", a1, type)
    
    dbQuery(function(query)
        local query, query_lines = dbPoll(query, 0)
        if query_lines > 0 then
            --for i, row in pairs(query) do
            Async:foreach(query, function(row)
                local id = tonumber(row["id"])
                local syntax = exports['cr_core']:getServerSyntax("TrafficBoards", "success")
                local green = exports['cr_core']:getServerColor(nil, true)        
                outputChatBox(syntax .. "Sikeresen létrehoztál egy TrafficBoardsot, #ID: "..green..id, sourceElement, 255,255,255,true)
                loadSpeedCam(row)
            end) 
        end
        --outputDebugString("[Success] Loading trafficboards has finished successfuly. Loaded: " .. query_lines .. " trafficboards!")
    end, connection, "SELECT * FROM `trafficboards` WHERE `pos`=?", a1)
end
addEvent("createTrafficBoards", true)
addEventHandler("createTrafficBoards", root, createTrafficBoards)

function deleteTrafficBoards(object)
    local id = getElementData(object, "TrafficBoards.id") or 0
    
    destroyElement(object)
    
    dbExec(connection, "DELETE FROM `trafficboards` WHERE `id`=?", id)
end
addEvent("deleteTrafficBoards", true)
addEventHandler("deleteTrafficBoards", root, deleteTrafficBoards)