connection = exports['cr_mysql']:getConnection(getThisResource())
addEventHandler("onResourceStart", root, 
    function(startedRes)
        if getResourceName(startedRes) == "cr_mysql" then
            connection = exports['cr_mysql']:getConnection(getThisResource())
            restartResource(getThisResource())
        end
    end
)

spam = {}

white = "#ffffff"

Async:setPriority("high")
Async:setDebug(true)

accounts = {}
isSerialAttachedToAccount = {}
isEmailAttachedToAccount = {}
idConvertToName = {}
isValidAccount = {}
isLogged = {}
isLoggedElement = {}

characters = {}
isAccountHaveCharacter = {}
isNameRegistered = {}

bans = {}
isIdentityHaveBan = {}

function loadAccounts()
    dbQuery(
        function(query)
            local query, query_lines = dbPoll(query, 0)
            if query_lines > 0 then
                Async:foreach(query, 
                    function(row)
                        local id = tonumber(row["id"])
                        local name = tostring(row["name"])
                        local email = tostring(row["email"])
                        local password = tostring(row["password"])
                        local serial = tostring(row["serial"])    
                        local ip = tostring(row["ip"])
                        local registerdatum = tostring(row["registerdatum"])    
                        local lastlogin = tostring(row["lastlogin"])
                        local online = tonumber(row["online"]) or 0
                        isLogged[name] = false
                        isLoggedElement[name] = false
                        local usedSerials = tostring(row["usedSerials"])        
                        local usedIps = tostring(row["usedIps"])        
                        local usedEmails = tostring(row["usedEmails"])        
                        local banned = tostring(row["banned"])        
                        usedSerials = fromJSON(usedSerials)
                        usedIps = fromJSON(usedIps)
                        usedEmails = fromJSON(usedEmails)
                        banned = stringToBoolean(banned)
                        accounts[name] = {id, password, serial, email, regdate, lastlogin, ip, usedSerials, usedIps, banned, usedEmails}
                        isValidAccount[name] = id
                        if serial ~= "0" then
                            isSerialAttachedToAccount[serial] = name
                        end
                        --[[
                        for k,v in pairs(usedSerials) do
                            isSerialAttachedToAccount[v] = name
                        end
                        ]]
                        isEmailAttachedToAccount[email] = name
                        idConvertToName[id] = name
                    end
                )
            end
            outputDebugString("Loading accounts finished. Loaded #"..query_lines.." accounts!", 0, 255, 50, 255)
            
            for k,v in pairs(getElementsByType("player")) do
                local co = coroutine.create(onStart)
                coroutine.resume(co, v)
            end
        end, 
    connection, "SELECT * FROM `accounts`")
    
    dbQuery(
        function(query)
            local query, query_lines = dbPoll(query, 0)
            if query_lines > 0 then
                Async:foreach(query, 
                    function(row)
                        local id = tonumber(row["id"])
                        local banIdentity = tostring(row["banIdentity"])
                        local reason = tostring(row["reason"])
                        local aName = tostring(row["aName"])
                        local startDate = tostring(row["startDate"])    
                        local endDate = tostring(row["endDate"])
                        
                        local aLevel = tonumber(row["aLevel"])

                        banIdentity = fromJSON(banIdentity)
                        bans[id] = {id, banIdentity, reason, aName, startDate, endDate, aLevel}
                        for k,v in pairs(banIdentity) do
                            isIdentityHaveBan[k] = id
                        end
                    end
                )
            end
            outputDebugString("Loading bans finished. Loaded #"..query_lines.." bans!", 0, 255, 50, 255)
        end, 
    connection, "SELECT * FROM `bans`")
    
    dbQuery(
        function(query)
            local query, query_lines = dbPoll(query, 0)
            if query_lines > 0 then
                Async:foreach(query, 
                    function(row)
                        local id = tonumber(row["id"])
                        local ownerAccountName = tostring(row["ownerAccountName"])
                        local charname = tostring(row["charname"])
                        local position = tostring(row["position"])
                        local details = tostring(row["details"])    
                        local charDetails = tostring(row["charDetails"])
                        local deathDetails = tostring(row["deathDetails"])
                        local adminDetails = tostring(row["adminDetails"])
                        local usedNames = tostring(row["usedNames"])
                        
                        position = fromJSON(position)
                        details = fromJSON(details)
                        charDetails = fromJSON(charDetails)
                        deathDetails = fromJSON(deathDetails)
                        adminDetails = fromJSON(adminDetails)
                        usedNames = fromJSON(usedNames)
                        
                        isAccountHaveCharacter[ownerAccountName] = id
                        isNameRegistered[string.lower(charname)] = id
                        characters[id] = {ownerAccountName, charname, position, details, charDetails, deathDetails, adminDetails, usedNames}
                    end
                )
            end
            outputDebugString("Loading characters finished. Loaded #"..query_lines.." character!", 0, 255, 50, 255)
        end, 
    connection, "SELECT * FROM `characters`")
end
addEventHandler("onResourceStart", resourceRoot, loadAccounts)

function getPlayerDatasByName(name)
    if isNameRegistered[string.lower(name)] then
        local id = isNameRegistered[string.lower(name)]
        return id, characters[id], accounts[name]
    else
        return false
    end
end

function getPlayerDatasByID(id)
    if characters[id] then
        return id, characters[id], accounts[idConvertToName[id]]
    else
        return false
    end
end

function getAccountOnline(id)
    if idConvertToName[id] then
        return isLogged[idConvertToName[id]], isLoggedElement[idConvertToName[id]]
    end
end

function updatePlayerJailData(id, newValue)
    if characters[id] then
        characters[id][7].ajail = newValue
        --dbExec(connection, "UPDATE ")
        dbExec(connection, "UPDATE `characters` SET `adminDetails`=? WHERE `id`=?", toJSON(characters[id][7]), id)
    end
end

function updatePlayerPosition(id, newValue)
    if characters[id] then
        characters[id][3] = toJSON(newValue)
        --dbExec(connection, "UPDATE ")
        dbExec(connection, "UPDATE `characters` SET `position`=? WHERE `id`=?", toJSON(characters[id][3]), id)
    end
end


function onQuitEvent()
    --outputChatBox(tostring(getElementData(e, "acc >> loggedIn")))
    if getElementData(source, "loggedIn") then
        local id = getElementData(source, "acc >> id")
        local name = getElementData(source, "acc >> username")
        isLogged[name] = false
        isLoggedElement[name] = false
        dbExec(connection, "UPDATE `accounts` SET `online`=? WHERE `id`=?", 0, id)
        outputDebugString("Account: #"..id..", #"..name.." state - offline")
    end
end
addEventHandler("onPlayerQuit", root, onQuitEvent)

function onQuit(e)
    --outputChatBox(tostring(getElementData(e, "acc >> loggedIn")))
    if getElementData(e, "loggedIn") then
        local id = getElementData(e, "acc >> id")
        local name = getElementData(e, "acc >> username")
        isLogged[name] = false
        isLoggedElement[name] = false
        dbExec(connection, "UPDATE `accounts` SET `online`=? WHERE `id`=?", 0, id)
        outputDebugString("Account: #"..id..", #"..name.." state - offline")
    end
end

addEventHandler("onResourceStop", resourceRoot,
    function()
        for k,v in pairs(getElementsByType("player")) do
            local co = coroutine.create(onQuit)
            coroutine.resume(co, v)
        end
        
        for k,v in pairs(isLogged) do
            if v then
                local name = k
                dbExec(connection, "UPDATE `accounts` SET `online`=? WHERE `name`=?", 0, name)
                outputDebugString("Account: #"..name.." state - offline")
            end
        end
    end
)

function onStart(e)
    --outputChatBox(tostring(getElementData(e, "acc >> loggedIn")))
    if getElementData(e, "loggedIn") then
        local id = getElementData(e, "acc >> id")
        local name = getElementData(e, "acc >> username")
        isLogged[name] = true
        isLoggedElement[name] = e
        dbExec(connection, "UPDATE `accounts` SET `online`=? WHERE `id`=?", 1, id)
        outputDebugString("Account: #"..id..", #"..name.." state - online")
    end
end

--[[ /changeaccname
function changeAccountName(thePlayer, cmd, oldName, newName)
    if exports['cr_permission']:hasPermission(thePlayer, "changeaccname") then
        if not oldName or not newName then
            local syntax = exports['cr_core']:getServerSyntax(false, "warning")
            outputChatBox(syntax .. "/"..cmd.. " [oldName] [newName]", thePlayer, 255,255,255,true)
            return 
        end
        
        local acc = accounts[oldName]
        
        local green = exports['cr_core']:getServerColor("orange", true)
        
        if acc then
            if accounts[newName] then
                local syntax = exports['cr_core']:getServerSyntax(false, "error")
                outputChatBox(syntax ..green..newName..white.. " nevű account már foglalt!", thePlayer, 255,255,255,true)
                return
            end
            
            local aName = exports['cr_admin']:getAdminName(thePlayer, true)
            
            local id = acc[1]
            accounts[newName] = acc
            accounts[oldName] = nil
            dbExec(connection, "UPDATE `accounts` SET `name`=? WHERE `id`=?", newName, id)

            local syntax = exports['cr_admin']:getAdminSyntax()
            local text = green..aName..white.." megváltoztatta "..green..oldName..white.." account nevét "..green..newName..white.."-ra/re"
            exports['cr_core']:sendMessageToAdmin(thePlayer, syntax .. text, 9)
            local time = exports['cr_core']:getTime() .. " "
            local text = string.gsub(text, aName, (tonumber(getElementData(thePlayer, "acc >> id")) or inspect(thePlayer)))
            local text = string.gsub(text, oldName, id)
            local text = string.gsub(text, newName, id)
            exports['cr_logs']:addLog(thePlayer, "Admin", "changeaccname", string.gsub(text, "#%x%x%x%x%x%x", ""))
        else
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax .. "Nincs találat "..green..oldName..white.." nevű accountra!", thePlayer, 255,255,255,true)
            return
        end
    end
end
addCommandHandler("changeusername", changeAccountName)
addCommandHandler("changeaccname", changeAccountName)

addEvent("change.accname", true)
addEventHandler("change.accname", root,
    function(oldName, newName)
        local acc = accounts[oldName]
        local id = acc[1]
        accounts[newName] = acc
        accounts[oldName] = nil
        dbExec(connection, "UPDATE `accounts` SET `name`=? WHERE `id`=?", newName, id)
    end
)--]]

-- /changeaccpw
function changeAccountPW(thePlayer, cmd, oldName, newPassword)
    if exports['cr_permission']:hasPermission(thePlayer, "changeaccpw") then
        if not oldName or not newPassword then
            local syntax = exports['cr_core']:getServerSyntax(false, "warning")
            outputChatBox(syntax .. "/"..cmd.. " [name] [newPassword]", thePlayer, 255,255,255,true)
            return 
        end
        
        local acc = accounts[oldName]
        
        local green = exports['cr_core']:getServerColor("orange", true)
        
        if acc then            
            local aName = exports['cr_admin']:getAdminName(thePlayer, true)
            
            local id = acc[1]
            local hashPassword1 = hash("sha512", oldName .. newPassword .. oldName)
            local hashedPassword = hash("md5", salt .. hashPassword1 .. salt)
            accounts[oldName][2] = hashedPassword
            dbExec(connection, "UPDATE `accounts` SET `password`=? WHERE `id`=?", hashedPassword, id)

            local syntax = exports['cr_admin']:getAdminSyntax()
            local text = green..aName..white.." megváltoztatta "..green..oldName..white.." account jelszavát!"
            exports['cr_core']:sendMessageToAdmin(thePlayer, syntax .. text, 9)
            local time = exports['cr_core']:getTime() .. " "
            local text = string.gsub(text, aName, (tonumber(getElementData(thePlayer, "acc >> id")) or inspect(thePlayer)))
            local text = string.gsub(text, oldName, id)
            exports['cr_logs']:addLog(thePlayer, "Admin", "changeaccpw", string.gsub(text, "#%x%x%x%x%x%x", ""))
        else
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax .. "Nincs találat "..green..oldName..white.." nevű accountra!", thePlayer, 255,255,255,true)
            return
        end
    end
end
addCommandHandler("changeuserpw", changeAccountPW)
addCommandHandler("changeaccpw", changeAccountPW)

addEvent("change.accpw", true)
addEventHandler("change.accpw", root,
    function(oldName, newPassword)
        local acc = accounts[oldName]
        local id = acc[1]
        local hashPassword1 = hash("sha512", oldName .. newPassword .. oldName)
        local hashedPassword = hash("md5", salt .. hashPassword1 .. salt)
        accounts[oldName][2] = hashedPassword
        dbExec(connection, "UPDATE `accounts` SET `password`=? WHERE `id`=?", hashedPassword, id)
    end
)

-- /changeaccemail
function changeAccountEmail(thePlayer, cmd, oldName, newPassword)
    if exports['cr_permission']:hasPermission(thePlayer, "changeaccemail") then
        if not oldName or not newPassword then
            local syntax = exports['cr_core']:getServerSyntax(false, "warning")
            outputChatBox(syntax .. "/"..cmd.. " [name] [newEmail]", thePlayer, 255,255,255,true)
            return 
        end
        
        local acc = accounts[oldName]
        
        local green = exports['cr_core']:getServerColor("orange", true)
        
        if acc then            
            local aName = exports['cr_admin']:getAdminName(thePlayer, true)
            
            if isEmailAttachedToAccount[newPassword] then
                local syntax = exports['cr_core']:getServerSyntax(false, "error")
                outputChatBox(syntax ..green..newPassword..white.. " email már rögzítve van egy accounthoz!", thePlayer, 255,255,255,true)
                return
            end
            
            local id = acc[1]
            local oValue = accounts[oldName][4]
            isEmailAttachedToAccount[oValue] = nil
            
            isEmailAttachedToAccount[newPassword] = oldName
            accounts[oldName][4] = newPassword
            dbExec(connection, "UPDATE `accounts` SET `email`=? WHERE `id`=?", newPassword, id)
            
            local usedEmails = accounts[oldName][11]
            if not usedEmails[newPassword] then
                accounts[oldName][11][newPassword] = true
                local usedEmails = toJSON(accounts[oldName][11])
                dbExec(connection, "UPDATE `accounts` SET `usedEmails`=? WHERE `id`=?", usedEmails, id)
            end

            local syntax = exports['cr_admin']:getAdminSyntax()
            local text = green..aName..white.." megváltoztatta "..green..oldName..white.." account emailjét "..green..newPassword..white.."-ra/re!"
            exports['cr_core']:sendMessageToAdmin(thePlayer, syntax .. text, 9)
            local time = exports['cr_core']:getTime() .. " "
            local text = string.gsub(text, aName, (tonumber(getElementData(thePlayer, "acc >> id")) or inspect(thePlayer)))
            local text = string.gsub(text, oldName, id)
            exports['cr_logs']:addLog(thePlayer, "Admin", "changeaccemail", string.gsub(text, "#%x%x%x%x%x%x", ""))

            local isOnline, onlineElement = getAccountOnline(id)
            if isOnline then 
                onlineElement:setData("acc >> email", newPassword)
            end 
        else
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax .. "Nincs találat "..green..oldName..white.." nevű accountra!", thePlayer, 255,255,255,true)
            return
        end
    end
end
addCommandHandler("changeuseremail", changeAccountEmail)
addCommandHandler("changeaccemail", changeAccountEmail)

addEvent("change.accEmail", true)
addEventHandler("change.accEmail", root,
    function(sourcePlayer, accName, newEmail)
        if sourcePlayer and accName and newEmail then 
            if isEmailAttachedToAccount[newEmail] then 
                if isEmailAttachedToAccount[newEmail] then 
                    exports['cr_infobox']:addBox(sourcePlayer, "error", "A mostani email címedre nem változtathatod!")
                    triggerLatentClientEvent(sourcePlayer, "email.error", 50000, false, sourcePlayer)
                    return 
                end 

                exports['cr_infobox']:addBox(sourcePlayer, "warning", "Ez az email már egy másik felhasználóhoz van csatolva!")
                triggerLatentClientEvent(sourcePlayer, "email.error", 50000, false, sourcePlayer)
                return 
            end 

            local acc = accounts[accName]
            local id = acc[1]
            local oValue = acc[4]
            isEmailAttachedToAccount[oValue] = nil
            accounts[accName][4] = newEmail
            isEmailAttachedToAccount[newEmail] = accName
            dbExec(connection, "UPDATE `accounts` SET `email`=? WHERE `id`=?", newEmail, id)
            
            local usedEmails = accounts[accName][11]
            if not usedEmails[newEmail] then
                accounts[accName][11][newEmail] = true
                local usedEmails = toJSON(accounts[accName][11])
                dbExec(connection, "UPDATE `accounts` SET `usedEmails`=? WHERE `id`=?", usedEmails, id)
                --outputChatBox("sql megvolt mert olyan emailt kapott ami eddig még nem volt usedEmails-ben")
            end

            sourcePlayer:setData("acc >> email", newEmail)
            exports['cr_infobox']:addBox(sourcePlayer, "success", "Sikeresen megváltoztattad az email címed!")
        end
    end
)

-- /changeaccserial
function changeAccountSerial(thePlayer, cmd, oldName)
    if exports['cr_permission']:hasPermission(thePlayer, "changeaccserial") then
        if not oldName then
            local syntax = exports['cr_core']:getServerSyntax(false, "warning")
            outputChatBox(syntax .. "/"..cmd.. " [name]", thePlayer, 255,255,255,true)
            return 
        end
        
        local acc = accounts[oldName]
        
        local green = exports['cr_core']:getServerColor("orange", true)
        
        if acc then            
            local aName = exports['cr_admin']:getAdminName(thePlayer, true)
            
            local id = acc[1]
            local oValue = accounts[oldName][3]
            isSerialAttachedToAccount[oValue] = nil
            accounts[oldName][3] = 0
            dbExec(connection, "UPDATE `accounts` SET `serial`=? WHERE `id`=?", 0, id)

            local syntax = exports['cr_admin']:getAdminSyntax()
            local text = green..aName..white.." megváltoztatta "..green..oldName..white.." account serialját "..green.."0"..white.."-ra!"
            exports['cr_core']:sendMessageToAdmin(thePlayer, syntax .. text, 9)
            local time = exports['cr_core']:getTime() .. " "
            local text = string.gsub(text, aName, (tonumber(getElementData(thePlayer, "acc >> id")) or inspect(thePlayer)))
            local text = string.gsub(text, oldName, id)
            exports['cr_logs']:addLog(thePlayer, "Admin", "changeaccserial", string.gsub(text, "#%x%x%x%x%x%x", ""))
        else
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax .. "Nincs találat "..green..oldName..white.." nevű accountra!", thePlayer, 255,255,255,true)
            return
        end
    end
end
addCommandHandler("changeuserserial", changeAccountSerial)
addCommandHandler("changeaccserial", changeAccountSerial)

addEvent("change.accserial", true)
addEventHandler("change.accserial", root,
    function(oldName)
        local acc = accounts[oldName]
        local oldSerial = acc[3]
        isSerialAttachedToAccount[oldSerial] = nil
        local id = acc[1]
        accounts[oldName][3] = 0
        dbExec(connection, "UPDATE `accounts` SET `serial`=? WHERE `id`=?", 0, id)
    end
)

function getCharacterNameByID(id)
    if characters[id] then
        return characters[id][2]
    else
        return "Ismeretlen"
    end
end

function getCharacterCount()
	return #characters
end