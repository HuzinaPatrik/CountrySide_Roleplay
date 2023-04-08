local datas = {
    ["database"] = "mta_dev_logs",
    ["host"] = "127.0.0.1",
    ["name"] = "root",
    ["password"] = 'password',
}

local connection

local firstConnection = true

local tables = {}

function connectToMySQL()
    connection = dbConnect("mysql", "dbname="..datas["database"]..";host="..datas["host"]..";charset=utf8", datas["name"], datas["password"], "tag=caselogdb;log=1;multi_statements=1")
    if connection then
        dbExec(connection, "SET NAMES utf8")
        outputDebugString("Sikeres MYSQL kapcsolat!")
        dbQuery(
            function(query)
                local query, query_lines = dbPoll(query, 0)
                if query_lines > 0 then
                    for i, row in pairs(query) do
                        local table = fromJSON(tostring(row["table"]))
                        if table then
                            tables = table
                        end
                    end
                end
            end, connection, "SELECT `table` FROM `logs.tableSave` WHERE `ID`=1"
        )
        if not firstConnection then
            restartResource(getThisResource())
            firstConnection = true
        end
    else
        outputDebugString("Sikertelen MYSQL kapcsolat!, (Result: Timer started)", 2)
        setTimer(connectToMySQL, 10000, 1)
        firstConnection = false
    end
end
addEventHandler("onResourceStart", resourceRoot, connectToMySQL)

addEventHandler("onResourceStop", resourceRoot,
    function()
        dbExec(connection, "UPDATE `logs.tableSave` SET `table`=? WHERE `ID`=1", toJSON(tables))
    end
)

--[[
Function list:
createLog
getLog(id)
getLogs(table)
removeLog(id)
clearLogs(table)

]]

function createLog(sourceElement, saveType, type, text)
    if not sourceElement then
        assert(sourceElement, "Bad argument 1 @ createLog (element expected, got " .. tostring(type(sourceElement)).. ")")
        return false
    end

    if not saveType then
        assert(saveType, "Bad argument 2 @ createLog (string expected, got " .. tostring(saveType).. ")")
        return false
    end

    if not type then
        assert(type, "Bad argument 3 @ createLog (string expected, got " .. tostring(type).. ")")
        return false
    end

    if not text then
        assert(text, "Bad argument 4 @ createLog (string expected, got " .. tostring(text).. ")")
        return false
    end

    local sourceID
    if isElement(sourceElement) then
        sourceID = tonumber(getElementData(sourceElement, "acc >> id")) or inspect(sourceElement)
    else
        sourceID = tonumber(sourceElement)
    end

    if not sourceID then
        assert(sourceID, "Nil value sourceID @ createLog (string expected, got " .. tostring(sourceID).. ")")
        return false
    end

    text = string.gsub(text, "#"..(6 and string.rep("%x", 6) or "%x+"), "")

    if saveType == "sql" then
        if not tables[type.."-logs"] then
            dbExec(connection, "CREATE TABLE IF NOT EXISTS `"..type.."-logs` (`id` INTEGER NOT NULL primary key AUTO_INCREMENT, `datum` varchar(255) NOT NULL, `text` varchar(5000) NOT NULL, `sourceID` varchar(255) NOT NULL) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;")
            tables[type.."-logs"] = true
        end

        dbExec(connection, "INSERT INTO `"..type.."-logs` SET `datum`=NOW(), `text`=?, `sourceID`=?", text, sourceID)

        return true
    elseif saveType == "file" then
        local datum = exports['cr_core']:getDatum()
        local path = "folders/" .. type .. "/" .. datum .. ".txt"
        text = text .. " ([Source Data]: "..sourceID..")"
        if not fileExists(path) then
            local file = fileCreate(path)
            fileWrite(file, type .. "Logs: ")
            fileClose(file)
        end

        local file = fileOpen(path)
        if file then
            fileSetPos(file, fileGetSize(file))
            local time = exports['cr_core']:getTime()
            fileWrite(file, "\n" .. time .. " " .. text)
            fileClose(file)
        end

        return true
    end
end
addEvent("createLog", true)
addEventHandler("createLog", root, createLog)

function clearLog(type)
    if tables[type.."-logs"] then
        dbExec(connection, "DROP TABLE `"..type.."-logs`")
        tables[type.."-logs"] = nil
        addLog(-1, "sql", type, "StartLog")
        return true, "Törölve"
    end

    return false, "Nincs ilyen tábla"
end
addEvent("clearLog", true)
addEventHandler("clearLog", root, clearLog)

function deleteLog(type)
    if tables[type.."-logs"] then
        dbExec(connection, "DROP TABLE `"..type.."-logs`")
        tables[type.."-logs"] = nil
        return true, "Törölve"
    end

    return false, "Nincs ilyen tábla"
end
addEvent("deleteLog", true)
addEventHandler("deleteLog", root, deleteLog)

function getLog(sourceElement, type)
    if not sourceElement then return end
    if not type then return end

    local sourceID
    if isElement(sourceElement) then
        sourceID = (tonumber(getElementData(sourceElement, "acc >> id")) or inspect(sourceElement))
    else
        sourceID = tonumber(sourceElement)
    end

    if not sourceID then return end

    if tables[type.."-logs"] then
        local returnTable = {}
        local query = dbQuery(connection, "SELECT * FROM `" .. type .. "-logs` WHERE `sourceID`=?", sourceID)
        local queryhandle, query_lines = dbPoll(query, -1)
        if query_lines > 0 then
            for i, row in pairs(queryhandle) do
                local id = tonumber(row["id"])
                local datum = tostring(row["datum"])
                local text = tostring(row["text"])
                local sourceID = tonumber(row["sourceID"])
                returnTable[id] = {datum, text, sourceID}
            end
        end
        return returnTable
    end
    return false
end
addEvent("getLog", true)
addEventHandler("getLog", root, getLog)

function addLog(sourceElement, folder, type, text)
    createLog(sourceElement, "sql", type, text)
end
addEvent("addLog", true)
addEventHandler("addLog", root, addLog)

function getLogTypeCommand(thePlayer, cmd)
    if exports.cr_core:getPlayerDeveloper(thePlayer) then 
        local tbl = {}

        for k, v in pairs(tables) do 
            local splittedTable = split(k, "-")

            if k == "transportitem.player-to-object-logs" or k == "transportitem.player-to-player-logs" or k == "transportitem.model-to-player-logs" then 
                local subString = k:gsub("-logs", "")

                table.insert(tbl, subString)
            else
                if not string.find(splittedTable[1], "transportitem") then 
                    table.insert(tbl, splittedTable[1])
                end
            end
        end

        triggerClientEvent(thePlayer, "logs.getLogType", thePlayer, tbl, "Log típusok")
    end
end
addCommandHandler("getlogtype", getLogTypeCommand, false, false)

function getLogsCommand(thePlayer, cmd, typ, sourceId)
    if exports.cr_core:getPlayerDeveloper(thePlayer) then 
        if not typ or not sourceId then 
            local syntax = exports.cr_core:getServerSyntax(false, "lightyellow")

            outputChatBox(syntax .. "/" .. cmd .. " [típus] [accountId]", thePlayer, 255, 0, 0, true)
            return
        end

        local typ = tostring(typ)
        local sourceId = tonumber(sourceId)

        if not tables[typ .. "-logs"] then 
            local syntax = exports.cr_core:getServerSyntax(false, "error")

            outputChatBox(syntax .. "Nem létezik log ezzel a típussal.", thePlayer, 255, 0, 0, true)
            return
        end

        local tbl = {}

        dbQuery(
            function(queryHandle, thePlayer)
                local query, query_lines = dbPoll(queryHandle, 0)

                if query_lines > 0 then 
                    Async:foreach(query,
                        function(row)
                            table.insert(tbl, {row.datum .. " - " .. row.text, "Account id: " .. row.sourceID})
                        end,

                        function()
                            if isElement(thePlayer) then 
                                triggerClientEvent(thePlayer, "logs.getLogType", thePlayer, tbl, "Account id " .. sourceId .. " logjai")
                            end
                        end
                    )
                else
                    if isElement(thePlayer) then 
                        local syntax = exports.cr_core:getServerSyntax(false, "error")

                        outputChatBox(syntax .. "Nem található log ezzel az accountId-vel.", thePlayer, 255, 0, 0, true)
                    end
                end
            end, {thePlayer}, connection, "SELECT * FROM `??` WHERE sourceId = ?", typ .. "-logs", sourceId
        )
    end
end
addCommandHandler("getlog", getLogsCommand, false, false)
