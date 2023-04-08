local blockedSerials = {}
local white = "#ffffff"
blockedSerialsEnabled = true

addEventHandler('onResourceStart', resourceRoot,
    function()	
        setTimer(
            function()
                --restartResource(getThisResource())    
                blockedIPS = {}
                fileDelete(path)
                file = fileCreate(path)
                fileClose(file)
            end, 2 * 24 * 60 * 60 * 1000, 1
        )
        
        dbQuery(function(query)
            local query, query_lines = dbPoll(query, 0)
            if query_lines > 0 then
                for i, row in pairs(query) do
                    local serial = row["serial"]
                    blockedSerials[serial] = true
                end
            end
			outputDebugString("[Success] Loading blockedserials has finished successfuly. Loaded: " .. query_lines .. " serials!")
        end, connection, "SELECT * FROM `blockedserials`")
        
        --
        path = "blockedSerial/blockit.txt"
        --file = fileOpen(path)
        blockedIPS = {}
        if not file then
            file = fileCreate(path)
        end
        
        local buffer = ""
        while not fileIsEOF(file) do
            buffer = buffer .. fileRead(file, 500)
        end
        
        local last = 0
        while true do
            local startpos, endpos = utf8.find(buffer, "\n", last)
            if startpos then
                --outputChatBox(utf8.sub(buffer, last, startpos-1))
                local ip = utf8.sub(buffer, last, (last ~= 0 and startpos-1) or startpos)
                --outputChatBox(ip)
                last = endpos+1
                --outputChatBox(startpos)
                blockedIPS[ip] = true
            else
                break
            end
        end
        --outputChatBox(tostring(string.find(buffer, "\n")))
        --outputChatBox(buffer)
        
        for k,v in pairs(getElementsByType("player")) do
            local serial = v.serial
            local playerIP = v.ip
            if blockedSerialsEnabled and blockedSerials[serial] then
                if not blockedIPS[playerIP] then
                    fileSetPos(file, fileGetSize(file))
                    fileWrite(file, playerIP.."\n")
                    fileFlush(file)   
                    blockedIPS[playerIP] = true
                end
            end
        end
        
        fileClose(file)
	end
)

addEventHandler("onResourceStop", resourceRoot,
    function()
        if file then
            fileDelete(path)
        end
    end
)

addEventHandler("onPlayerConnect", root,
    function(playerNick, playerIP, playerUsername, serial, playerVersionNumber)
        --outputChatBox(serial)
        --if blockedSerialsEnabled and blockedSerials[serial] then
            --cancelEvent(true, "Sikertelen csatlakozás (Error: C20)")
        --end
        
        if blockedSerialsEnabled and blockedSerials[serial] then
            if not blockedIPS[playerIP] then
                file = fileOpen(path)
                fileSetPos(file, fileGetSize(file))
                fileWrite(file, playerIP.."\n")
                fileFlush(file)   
                blockedIPS[playerIP] = true
                fileClose(file)
            end
        end
    end
)

addCommandHandler("createblockedserial", 
    function(thePlayer, cmd, serial)
        --local playerSerial = getPlayerSerial(thePlayer)
        if exports['cr_core']:getPlayerDeveloper(thePlayer) then
            if not serial then
                outputChatBox(syntax2 .. "/"..cmd.." [serial]", thePlayer, 255, 255, 255, true)
                return
            end
            
            if blockedSerials[serial] then
                outputChatBox(syntax3 .. "A serial melyet blockolni szeretnél már blockolva van", thePlayer, 255, 255, 255, true)
                return
            end
            
            dbExec(connection, "INSERT INTO `blockedserials` SET `serial` = ?", serial)
            blockedSerials[serial] = true
            local green = exports['cr_core']:getServerColor('yellow', true)
            local syntax = exports['cr_core']:getServerSyntax(false, "success")
            local aName = exports['cr_admin']:getAdminName(thePlayer, true)
            outputChatBox(syntax .. "Sikeresen hozzáadtad a(z) "..green..serial..white.."-t a blockedserialokhoz!", thePlayer, 255, 255, 255, true)
            local syntax = exports['cr_admin']:getAdminSyntax()
            exports['cr_core']:sendMessageToAdmin(thePlayer, syntax..green..aName..white.." hozzáadta a(z) "..green..serial..white.."-t a blockedserialokhoz!", 9)
            local time = exports['cr_core']:getTime() .. " "
            exports['cr_logs']:addLog(thePlayer, "Admin", "createblockedserial", (tonumber(getElementData(thePlayer, "acc >> id")) or inspect(thePlayer)) .." hozzáadta a(z) "..serial.."-t a blockedserialokhoz!")
            
            file = fileOpen(path)
            for k,v in pairs(getElementsByType("player")) do
                local serial = v.serial
                local playerIP = v.ip
                if blockedSerialsEnabled and blockedSerials[serial] then
                    if not blockedIPS[playerIP] then
                        fileSetPos(file, fileGetSize(file))
                        fileWrite(file, playerIP.."\n")
                        fileFlush(file)   
                        blockedIPS[playerIP] = true
                    end
                end
            end
            fileClose(file)
        end
    end
)

addCommandHandler("removeblockedserial", 
    function(thePlayer, cmd, serial)
        --local playerSerial = getPlayerSerial(thePlayer)
        if exports['cr_core']:getPlayerDeveloper(thePlayer) then
            if not serial then
                outputChatBox(syntax2 .. "/"..cmd.." [serial]", thePlayer, 255, 255, 255, true)
                return
            end
            
            if not blockedSerials[serial] then
                outputChatBox(syntax3 .. "A törlendő serialnak blockedserialnak kell lennie (Ez a serial nem blockedserial!)", thePlayer, 255, 255, 255, true)
                return
            end
            dbExec(connection, "DELETE FROM `blockedserials` WHERE `serial` = ?", serial)
            blockedSerials[serial] = false
            local green = exports['cr_core']:getServerColor('yellow', true)
            local syntax = exports['cr_core']:getServerSyntax(false, "success")
            local aName = exports['cr_admin']:getAdminName(thePlayer, true)
            outputChatBox(syntax .. "Sikeresen törölted a(z) "..green..serial..white.."-t a blockedserialokból!", thePlayer, 255, 255, 255, true)
            local syntax = exports['cr_admin']:getAdminSyntax()
            exports['cr_core']:sendMessageToAdmin(thePlayer, syntax..green..aName..white.." törölte a(z) "..green..serial..white.."-t a blockedserialokból!", 9)
            local time = exports['cr_core']:getTime() .. " "
            exports['cr_logs']:addLog(thePlayer, "Admin", "removeblockedserial", (tonumber(getElementData(thePlayer, "acc >> id")) or inspect(thePlayer)) .." törölte a(z) "..serial.."-t a blockedserialokból!")
            
            --restartResource(getThisResource())
            --fileDelete(path)
            --fileCreate(path)
            blockedIPS = {}
            fileDelete(path)
            file = fileCreate(path)
            fileClose(file)
        end
    end
)

addCommandHandler("changeBlockedserials", 
    function(thePlayer, cmd)
        --local playerSerial = getPlayerSerial(thePlayer)
        if exports['cr_core']:getPlayerDeveloper(thePlayer) then
            blockedSerialsEnabled = not blockedSerialsEnabled
            
            if blockedSerialsEnabled then
                outputChatBox(syntax .. "Sikeresen bekapcsoltad a blockedserials-t", thePlayer, 255, 255, 255, true)
                local aName = exports['cr_admin']:getAdminName(thePlayer, false)
                local green = exports['cr_core']:getServerColor('yellow', true)
                exports['cr_core']:sendMessageToAdmin(thePlayer, syntax..green..aName..white.." bekapcsolta a blockedserials-t!", 9)
                exports['cr_logs']:addLog(thePlayer, "Admin", "changeBlockedserials-on", (tonumber(getElementData(thePlayer, "acc >> id")) or inspect(thePlayer)) .." bekapcsolta a blockedserials-t!")
                
                for k,v in pairs(getElementsByType("player")) do
                    local serial = v:getData("mtaserial") or v.serial
                    if blockedSerials[serial] then
                        v:kick("Console", "Fejlesztői mód engedélyezve")
                    end
                end
            else
                outputChatBox(syntax .. "Sikeresen kikapcsoltad a blockedserials-t", thePlayer, 255, 255, 255, true)
                local aName = exports['cr_admin']:getAdminName(thePlayer, false)
                local green = exports['cr_core']:getServerColor('yellow', true)
                exports['cr_core']:sendMessageToAdmin(thePlayer, syntax..green..aName..white.." kikapcsolta a blockedserials-t!", 9)
                exports['cr_logs']:addLog(thePlayer, "Admin", "changeBlockedserials-off", (tonumber(getElementData(thePlayer, "acc >> id")) or inspect(thePlayer)) .." kikapcsolta a blockedserials-t!")
            end
        end
    end
)

addCommandHandler("blockedSerialsState", 
    function(thePlayer, cmd)
        --local playerSerial = getPlayerSerial(thePlayer)
        if exports['cr_core']:getPlayerDeveloper(thePlayer) then
            outputDebugString("Blockedserials state: "..tostring(blockedSerialsEnabled))
        end
    end
)

function jsonGETT(file)
    local fileHandle
    local jsonDATA = {}
    if not fileExists(file) then
        fileHandle = fileCreate(file)
        --local num = originalMaxLines
        --local x, y = sx/2, sy/2
        fileWrite(fileHandle, toJSON({true}))
        fileClose(fileHandle)
        fileHandle = fileOpen(file)
    else
        fileHandle = fileOpen(file)
    end
    if fileHandle then
        local buffer
        local allBuffer = ""
        while not fileIsEOF(fileHandle) do
            buffer = fileRead(fileHandle, 500)
            allBuffer = allBuffer..buffer
        end
        jsonDATA = fromJSON(allBuffer)
        fileClose(fileHandle)
    end
    return jsonDATA
end
 
function jsonSAVET(file, data)
    if fileExists(file) then
        fileDelete(file)
    end
    local fileHandle = fileCreate(file)
    fileWrite(fileHandle, toJSON(data))
    fileFlush(fileHandle)
    fileClose(fileHandle)
    return true
end

addEventHandler("onResourceStart", resourceRoot,
    function()
        blockedSerialsEnabled = unpack(jsonGETT("@option.json"))
        outputDebugString("Blockedserials state: "..tostring(blockedSerialsEnabled))
    end
)

addEventHandler("onResourceStop", resourceRoot,
    function()
        jsonSAVET("@option.json", {blockedSerialsEnabled})
    end
)