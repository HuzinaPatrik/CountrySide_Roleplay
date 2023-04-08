connection = exports['cr_mysql']:getConnection(getThisResource())
addEventHandler("onResourceStart", root, 
    function(startedRes)
        if getResourceName(startedRes) == "cr_mysql" then
            connection = exports['cr_mysql']:getConnection(getThisResource())
            restartResource(getThisResource())
        end
    end
)

local bestSectorDetails = {}

local playerTimes = {}

spam = {}

white = "#ffffff"

Async:setPriority("high")
Async:setDebug(true)

function loadTimes()
    dbQuery(
        function(query)
            local query, query_lines = dbPoll(query, 0)
            if query_lines > 0 then
                Async:foreach(query, 
                    function(row)
                        local id = tonumber(row["id"])
                        local time = tonumber(row["time"])
                        local sectorDetails = fromJSON((row["sectorDetails"]))
                        local playerName = (tostring(row["playerName"]))
                        local playerID = (tonumber(row["playerName"]))
                        local modelid = (tonumber(row["modelid"]))
                        --outputChatBox(modelid)
                        if playerTimes[1] then
                            if time < playerTimes[1][1] then
                                table.insert(playerTimes, 1, {time, sectorDetails, playerName, playerID, modelid})
                            else
                                table.insert(playerTimes, {time, sectorDetails, playerName, playerID, modelid})
                            end
                        else
                            table.insert(playerTimes, {time, sectorDetails, playerName, playerID, modelid})
                        end
                    end
                )
            end
            outputDebugString("Loading times finished. Loaded #"..query_lines.." times!", 0, 255, 50, 255)
        end, 
    connection, "SELECT * FROM `playertimes`")
    
    setTimer(returnData, 5000, 1)
end
addEventHandler("onResourceStart", resourceRoot, loadTimes)

addEventHandler("onResourceStart", resourceRoot,
    function()
        gObj = Object(968, 428.239, 599.900, 18.7)
        gObj.rotation = Vector3(-30, 90, 5) -- nyitva: 0, 0, 30
    end
)

function returnData(e)
    local tableSec = {}
    for i = 1, 10 do
        if playerTimes[i] then
            tableSec[i] = playerTimes[i]
        end
    end
    --outputDebugString(inspect(tableSec))
    if not e then
        triggerClientEvent(root, "returnData", root, {gObj, tableSec})
    else
        triggerClientEvent(e, "returnData", e, {gObj, tableSec})
    end
end
addEvent("returnData", true)
addEventHandler("returnData", root, returnData)

function gateOpen()
    --outputChatBox("asd")
    if not moveState then
        
        moveObject(gObj, 2000, 428.239, 599.900, 18.7, 0, -90, 0)
        moveState = true
        gObj:setData("moveState", true)
        --outputChatBox("asd")
        setTimer(
            function()
                moveObject(gObj, 2000, 428.239, 599.900, 18.7, 0, 90, 0)
                setTimer(
                    function()
                        moveState = false
                        gObj:setData("moveState", false)
                    end, 2500, 1
                )
            end, 5000, 1
        )
    end
end
addEvent("gateOpen", true)
addEventHandler("gateOpen", root, gateOpen)

function playerTime(e, sectorDetails)
    --outputChatBox(sectorDetails)
    local time = sectorDetails["last"]
    local playerName, playerID = exports['cr_admin']:getAdminName(e, false), e:getData("acc >> id")
    local color, white = exports['cr_core']:getServerColor('yellow', true), "#ffffff"
    
    if playerTimes[1] and playerTimes[1][1] then
        if time <= playerTimes[1][1] then
            outputChatBox(exports['cr_core']:getServerSyntax("Versenypálya", "success") .. color .. playerName .. white .." megdöntötte a csúcsidőt. Új csúcsidő: ".. color ..formatIntoTime(time), root, 255,255,255,true)
        end
    else
        outputChatBox(exports['cr_core']:getServerSyntax("Versenypálya", "success") .. color .. playerName .. white .." megdöntötte a csúcsidőt. Új csúcsidő: ".. color ..formatIntoTime(time), root, 255,255,255,true)
    end
    
    table.insert(playerTimes, {time, sectorDetails, playerName, playerID, e.vehicle.model})
    dbExec(connection, "INSERT INTO `playertimes` SET `time`=?,`sectorDetails`=?,`playerName`=?, `playerID`=?, `modelid`=?", time, toJSON(sectorDetails), playerName, playerID, e.vehicle.model)
    table.sort(playerTimes, 
        function(a, b)
            if a and b then
                return a[1] < b[1]
            end
        end
    )
    
    returnData()
end
addEvent("playerTime", true)
addEventHandler("playerTime", root, playerTime)