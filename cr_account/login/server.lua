function spawnPl(sourceElement, SkinID, x,y,z, rot, dim,int, Health, Armor, fightStyle, walkStyle, deathReasons, stats, bones)
    local pos = Vector3(x,y,z + (Health >= 1 and 1 or 0))
    sourceElement:spawn(pos, rot, SkinID)    
    sourceElement:setDimension(dim)
    sourceElement:setInterior(int)
    sourceElement:setHealth(Health)
    sourceElement:setArmor(Armor)
    setPedFightingStyle(sourceElement, fightStyle)
    setPedWalkingStyle(sourceElement, walkStyle)
    sourceElement:setAlpha(50)
    sourceElement:setFrozen(true)
    setElementData(sourceElement, "hudVisible", false)
    setElementData(sourceElement, "keysDenied", true)
    sourceElement:setCollisionsEnabled(false)

    if Health <= 0 then 
        setElementData(sourceElement, "deathReason", deathReasons[1])
        setElementData(sourceElement, "deathReason >> admin", deathReasons[2])
    end

    if stats then 
        for k,v in pairs(stats) do 
            if tonumber(v or 0) > 0 then 
                sourceElement:setStat(tonumber(k), v)
            end 
        end 
    end 
    
    triggerClientEvent(sourceElement, "cameraSpawn", sourceElement, Health, bones)
end
addEvent("spawnPl", true)
addEventHandler("spawnPl", root, spawnPl)

function unFreeze(sourceElement, hp, bones)
    sourceElement:setAlpha(50)
    sourceElement:setData("loading", true)
    sourceElement:setFrozen(false)
    sourceElement:setCollisionsEnabled(true)
    local name = getElementData(sourceElement, "acc >> username")
    local id = getElementData(sourceElement, "acc >> id")
    isLogged[name] = true
    isLoggedElement[name] = sourceElement
    outputDebugString("Account: #"..id..", #"..name.." state - online")
    setElementData(sourceElement, "loggedIn", true)

    if hp > 0 then
        exports["cr_infobox"]:addBox(sourceElement, "success", "Sikeres bejelentkezés. Jó játékot!")
        setElementData(sourceElement, 'char >> bone', bones)
        setElementData(sourceElement, "hudVisible", true)
        setElementData(sourceElement, "keysDenied", false)

        if sourceElement:getData("char >> duty") then 
            exports.cr_dashboard:checkPlayerDutyStatus(sourceElement, sourceElement:getData("char >> duty"))
        end
    end
end
addEvent("unFreeze", true)
addEventHandler("unFreeze", root, unFreeze)

addEvent("playerAlpha", true)
addEventHandler("playerAlpha", root,
    function(e)
        e.alpha = 255
    end
)

function interactLogin(sourceElement, username, password)  
    
    --Email logon
    if isEmailAttachedToAccount[username] then
        username = isEmailAttachedToAccount[username]
    end
    --
    
    if not isValidAccount[username] then
        exports["cr_infobox"]:addBox(sourceElement, "error", "Ez a felhasználónév ("..username..") nincs regisztrálva!")
        return
    end

    if isLogged[username] then
        exports["cr_infobox"]:addBox(sourceElement, "error", "Ez a felhasználó ("..username..") már használatban van!")
        return
    end
    
    local lastClickTick = spam[sourceElement] or 0
    if lastClickTick + 1500 > getTickCount() then
        return
    end
    spam[sourceElement] = getTickCount()

    local data = accounts[username]
    --accounts[name] = {id, password, serial, email, regdate, lastlogin, ip, usedSerials, usedIps, banned}
    local id = data[1]
    local realPassword = data[2]
    local serial = data[3]
    local email = data[4]
    local registerdatum = data[5]
    local lastlogin = data[6]
    local ip = data[7]
    local usedSerials = data[8]
    local usedIps = data[9]
    local banned = data[10]
    local usedEmails = data[11]

    local mtaserial = getElementData(sourceElement, "mtaserial")
    local nowIP = getPlayerIP(sourceElement)
    
    --outputChatBox(string.lower(realPassword))
    --outputChatBox(string.lower(password))
    if string.lower(password) ~= string.lower(realPassword) then
        local hashedPassword = hash("sha512", username .. password .. username)
        local hashedPassword2 = hash("md5", salt .. hashedPassword .. salt)

        if string.lower(realPassword) ~= string.lower(hashedPassword2) then
            exports["cr_infobox"]:addBox(sourceElement, "error", "Hibás jelszó!")
            return
        end
    end
    
    if banned then
        local banID = isIdentityHaveBan[username]
        banIdentity = bans[banID][2]
        banIdentity[mtaserial] = true
        banIdentity[nowIP] = true
        isIdentityHaveBan[mtaserial] = banID
        isIdentityHaveBan[nowIP] = banID
        bans[banID][2] = banIdentity
        kickPlayer(sourceElement, "Rendszer", "Ki lettél tiltva a szerverről!")
        dbExec(connection, "UPDATE `bans` SET `banIdentity`=? WHERE `id`=?", toJSON(banIdentity), banID)
        return
    end

    if string.lower(serial) ~= string.lower(mtaserial) then
        if tostring(serial) == "0" or tonumber(serial) == 0 then -- Serial váltás
            if not isSerialAttachedToAccount[mtaserial] then
                dbExec(connection, "UPDATE `accounts` SET `serial`=? WHERE `id`=?", mtaserial, id)
                accounts[username][3] = mtaserial
                isSerialAttachedToAccount[mtaserial] = username
            else
                exports["cr_infobox"]:addBox(sourceElement, "error", "A te serialod másik felhasználóhoz van csatolva! ("..tostring(isSerialAttachedToAccount[mtaserial])..")!")
                return
            end
        else
            exports["cr_infobox"]:addBox(sourceElement, "error", "A te serialod ("..mtaserial..") nem ehhez a felhasználóhoz van társítva!")
            return
        end
    end
    
    if not usedSerials[mtaserial] then
        accounts[username][8][mtaserial] = true
        local usedSerials = toJSON(accounts[username][8])
        dbExec(connection, "UPDATE `accounts` SET `usedSerials`=? WHERE `id`=?", usedSerials, id)
    end
    
    if not usedIps[nowIP] then
        accounts[username][9][nowIP] = true
        local usedIps = toJSON(accounts[username][9])
        dbExec(connection, "UPDATE `accounts` SET `usedIps`=? WHERE `id`=?", usedIps, id)
    end
    
    if not usedEmails[email] then
        accounts[username][11][email] = true
        local usedEmails = toJSON(accounts[username][11])
        dbExec(connection, "UPDATE `accounts` SET `usedEmails`=? WHERE `id`=?", usedEmails, id)
    end

    --isLogged[username] = true

    --local lastlogin = accounts[username][6]
    --local regdatum = accounts[username][5]

    dbExec(connection, "UPDATE `accounts` SET `lastlogin`=NOW() WHERE `id`=?", id)
    dbQuery(function(query)
        local query, query_lines = dbPoll(query, 0)
        if query_lines > 0 then
            --for i, row in pairs(query) do
            Async:foreach(query, function(row)
                local lastlogin = tostring(row["lastlogin"])
                accounts[username][6] = lastlogin   
            end)
        end
    end, connection, "SELECT `lastlogin` FROM `accounts` WHERE `id` = ?", id)

    --setElementData(sourceElement, "acc >> loggedIn", true)
    setElementData(sourceElement, "acc >> id", id)
    setElementData(sourceElement, "acc >> username", username)
    setElementData(sourceElement, "acc >> email", email)

    if isAccountHaveCharacter[username] then
        triggerClientEvent(sourceElement, "loadScreen", sourceElement)
    else
        triggerClientEvent(sourceElement, "Start.Char-Register", sourceElement)
    end
    
    --triggerClientEvent(sourceElement, "idgLoading", sourceElement)
end
addEvent("login.goLogin", true)
addEventHandler("login.goLogin", root, interactLogin)

local isValid = {
    ["char >> skin"] = true,
    ["char >> fightStyle"] = true,
    ["char >> walkStyle"] = true,
    ["char >> headless"] = true,
    ["char >> name"] = true,
    ["char >> armor"] = true,
    ["char >> health"] = true,
}

addEventHandler("onElementDataChange", root,
    function(dName, oValue)
        if getElementType(source) == "player" then
            if dName == "char >> skin" or dName == "char >> dutyskin" then
                local value = getElementData(source, dName)
                if tonumber(value) then 
                    setElementModel(source, value)
                end 
            elseif dName == "char >> fightStyle" then
                local value = getElementData(source, dName)
                setPedFightingStyle(source, value)
                
                if getElementData(source, "char >> details") then
                    local v = getElementData(source, "char >> details")
                    v["fightStyle"] = value
                    setElementData(source, "char >> details", v)
                end
            elseif dName == "char >> walkStyle" then
                local value = getElementData(source, dName)
                setPedWalkingStyle(source, value)
                
                if getElementData(source, "char >> details") then
                    local v = getElementData(source, "char >> details")
                    v["walkStyle"] = value
                    setElementData(source, "char >> details", v)
                end
            elseif dName == "char >> name" then
                local id = getElementData(source, "acc >> id")
                if oValue then
                    isNameRegistered[string.lower(oValue)] = nil
                end
                local value = getElementData(source, dName)
                setPlayerName(source, value)
                characters[id][2] = value
                isNameRegistered[string.lower(value)] = id

                local usedNames = characters[id][8]

                if not usedNames[value] then
                    --usedNames[value] = true
                    characters[id][8][value] = true
                    local usedNames = toJSON(characters[id][8])
                    dbExec(connection, "UPDATE `characters` SET `usedNames`=? WHERE `id`=?", usedNames, id)
                end
            elseif dName == "char >> health" then
                local value = getElementData(source, dName)
                setElementHealth(source, value) 
            elseif dName == "char >> armor" then
                local value = getElementData(source, dName)
                setPedArmor(source, value)    
            elseif dName == "char >> headless" then
                local value = getElementData(source, dName)
                setPedHeadless(source, value)
            end
        end
    end
)

function forgetPassSearch(sourceElement, val)
    local lastClickTick = spam[sourceElement] or 0
    if lastClickTick + 1500 > getTickCount() then -- 1.5 sec
        return
    end
    spam[sourceElement] = getTickCount()
    
    local match = val
    
    --accounts[name] = {id, password, serial, email, regdate, lastlogin, ip, usedSerials, usedIps, banned, usedEmails}
    --isEmailAttachedToAccount[email] = name
    
    if accounts[val] then
        match = {val, accounts[val][4]}
    elseif isEmailAttachedToAccount[val] then
        match = {isEmailAttachedToAccount[val], val}
    end
    
    if match and match[1] then
        if accounts[match[1]] then
            local serial = accounts[match[1]][3]
            if serial ~= sourceElement:getData("mtaserial") then
                exports['cr_infobox']:addBox(sourceElement, "error", "Ez az account ("..match[1]..") nem a te serialodhoz tartozik!")
                return
            end
        end
    end
    
    triggerClientEvent(sourceElement, "ForgetPass>Search", sourceElement, sourceElement, match)
end
addEvent("ForgetPass>Search", true)
addEventHandler("ForgetPass>Search", root, forgetPassSearch)

local allowed = {{48, 57}, {97, 122}}

local codes = {}
local codeTimers = {}
local codeSpamTimers = {}

function genCode()
    local len = 10
    
    --code
    math.randomseed(getTickCount())
    local str = ""
    for i = 1, len do
        local charlist = allowed[math.random(1,2)]
        str = str .. string.char(math.random(charlist[1], charlist[2]))
    end
    --
    
    return string.upper(str)
end

function destroyCode(e, val, ignore)
    if codes[e] then
        codes[e] = nil
        if not ignore then
            exports['cr_infobox']:addBox(e, "error", "Mivel letelt a 15 perc ezért új kódot kell igényelj!")
            triggerClientEvent(e, "ForgetPass>Search", e, e, val)
        end
    end
end
addEvent("destroyCode", true)
addEventHandler("destroyCode", root, destroyCode)

function forgetPassSend(sourceElement, val)
    local minutes = 15
    local lastClickTick = codeSpamTimers[sourceElement] or 0
    if lastClickTick + minutes * 60 * 1000 > getTickCount() then -- 1.5 sec
        exports['cr_infobox']:addBox(sourceElement, "error", minutes .. " percenként küldhetsz jelszó emlékeztető emailt!")
        return
    end
    codeSpamTimers[sourceElement] = getTickCount()
    
    local accName, accEmail = unpack(val)
    
    local code = genCode()    
    codes[sourceElement] = code

    callRemote("http://csrp.hu/resetPassword/"..base64Encode(accName).."/"..base64Encode(accEmail).."/"..base64Encode(code).."/M3NSOTJrMjA=", function() end)

    triggerClientEvent(sourceElement, "ForgetPass>Send", sourceElement, sourceElement, code)
    
    if isTimer(codeTimers[sourceElement]) then 
        killTimer(codeTimers[sourceElement]) 
    end
    
    codeTimers[sourceElement] = setTimer(destroyCode, minutes * 60 * 1000, 1, sourceElement, val)

    exports['cr_infobox']:addBox(sourceElement, "info", "A kód kiküldve az emailre, "..minutes.." perced van!")
end
addEvent("ForgetPass>Send", true)
addEventHandler("ForgetPass>Send", root, forgetPassSend)