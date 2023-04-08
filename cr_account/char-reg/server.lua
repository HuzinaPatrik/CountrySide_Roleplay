local startMoney = 2000

addEvent("character.Register", true)
addEventHandler("character.Register", root, 
    function(sourceElement, details, t)
        local lastClickTick = spam[sourceElement] or 0
        if lastClickTick + 500 > getTickCount() then
            return
        end
        spam[sourceElement] = getTickCount()
        
        local oName = t[1]
        local oId = t[2]
        local skin = details["skin"]
        local name = details["name"]
        details["skin"] = nil
        details["name"] = nil
        details["walkStyle"] = 121
        details["fightStyle"] = 5
        local a = "Ő egy XX cm magas, XY kg súlyú, XZ éves, XO nemzetiségű ember!"
        a = a:gsub("XX", details["height"])
        a = a:gsub("XY", details["weight"])
        a = a:gsub("XZ", details["age"])
        a = a:gsub("XO", nationalityNumToString(details["nationality"]))
        details["description"] = a
        details = toJSON(details)
        local position = toJSON({2277.3103027344, -90.274909973145, 26.484375, 0,0, 175})

        local details2 = toJSON({
            ['health'] = 100, 
            ['armor'] = 0, 
            ['skin'] = skin, 
            ['money'] = startMoney, 
            ['premiumPoints'] = 0,
            ['playedTime'] = 0, 
            ['level'] = 1, 
            ['pp'] = 0, 
            ['job'] = 0, 
            ['food'] = 100, 
            ['drink'] = 100, 
            ['vehicleLimit'] = 5, 
            ['interiorLimit'] = 5, 
            ['avatar'] = 1, 
            ['isKnow'] = {{["-5000"] = true}, {["-5000"] = true}}, 
            ['bones'] = {true, true, true, true, true}, 
            ['isHidden'] = {}, 
            ['bloodData'] = {}, 
            ['crosshair'] = 1, 
            ['crosshairColor'] = {255, 255, 255}, 
            ['stats'] = {}, 
            ['dutyDatas'] = {false, nil}, 
            ['cuffed'] = false, 
            ['bondage'] = false, 
            ['blinded'] = false, 
            ['jailData'] = {},
        })
        
        local usedNames = toJSON({[name] = true})
        
        dbExec(connection, "INSERT INTO `characters` SET `id`=?, `ownerAccountName`=?, `charName`=?, `position`=?, `details`=?, `charDetails`=?, `usedNames`=?", oId, oName, name, position, details2, details, usedNames)
        
        loadCharacterSQL(oId)
    end
)

function loadCharacterSQL(id)
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
                        outputDebugString("Character #"..id.." - loaded!", 0, 255, 50, 255)
                    end
                )
            end
        end, 
    connection, "SELECT * FROM `characters` WHERE `id`=?", id)
end

function loadCharacter(sourceElement, id, username, a)
    --isLogged[username] = true

    --local lastlogin = accounts[username][6]
    --local regdatum = accounts[username][5]
    dbExec(connection, "UPDATE `accounts` SET `online`=? WHERE `id`=?", 1, id)
    
    local data = characters[id]
    local usedNames = characters[id][8]
    local value = characters[id][2]
    if not usedNames[value] then
        --usedNames[value] = true
        characters[id][8][value] = true
        local usedNames = toJSON(characters[id][8])
        dbExec(connection, "UPDATE `characters` SET `usedNames`=? WHERE `id`=?", usedNames, id)
    end

    triggerClientEvent(sourceElement, "loadCharacter", sourceElement, data)
end
addEvent("loadCharacter", true)
addEventHandler("loadCharacter", root, loadCharacter)

addEvent("checkNameRegistered", true)
addEventHandler("checkNameRegistered", root,
    function(e, b)
        local a = true
        if isNameRegistered[string.lower(b)] then
            a = false
        end
        triggerClientEvent(e, "receiveNameRegisterable", e, a, b)
    end
)

function setname_sc(element,cmd, target,...)
    if exports['cr_permission']:hasPermission(element, "setname") then
        if not (target) or not(...) then
            local syntax = exports['cr_core']:getServerSyntax(false, "warning")
            outputChatBox(syntax.."#ffffff /"..cmd.." [Játékos ID/Név] [Name]",element,0,0,0,true)
        else
            local target = exports['cr_core']:findPlayer(element, target)
            if target then
                local aName = exports['cr_admin']:getAdminName(target, false) --getElementData(target,"char >> name"):gsub("_"," ")
                if target:getData("loggedIn") then
                    local color = exports['cr_core']:getServerColor('yellow', true)
                    local newName = table.concat({...}, " ")
                    local newName = newName:gsub(" ","_")
                    if #newName <= 8 and #newName >= 30 then
                        local syntax = exports['cr_core']:getServerSyntax(false, "error")
                        outputChatBox(syntax.."A karakternév minimum 8, maximum 30 karakter lehet!",element,255,255,255,true)
                        return
                    end
                    
                    local name = newName:gsub("_", " ")
                    local count = 1
                    local fullName = ""
                    while true do
                        local a = gettok(name, count, string.byte(' '))
                        if a then
                            count = count + 1
                            if gettok(name, count, string.byte(' ')) then
                                a = a .. "_"
                            end
                            a = string.upper(utfSub(a, 1, 1)) .. string.lower(utfSub(a, 2, #a))
                            fullName = fullName .. a
                        else
                            break
                        end
                    end
                    newName = fullName
                    
                    if not isNameRegistered[string.lower(newName)] then
                        local syntax = exports['cr_core']:getServerSyntax(false, "success")
                        outputChatBox(syntax.."Sikeresen megváltoztattad "..color..aName.."#ffffff nevét! ("..color..newName:gsub("_", " ").."#ffffff)",element,255,255,255,true)
                        exports['cr_core']:sendMessageToAdmin(target,exports['cr_admin']:getAdminSyntax()..color..exports['cr_admin']:getAdminName(element,true).."#ffffff megváltoztatta "..color..aName.."#ffffff nevét! ("..color..newName:gsub("_", " ").."#ffffff)",1)
                        
                        exports['cr_infobox']:addBox(target, "success", "Új nevet kaptál! ("..newName:gsub("_", " ")..")")
                        
                        local text = tonumber(element:getData("acc >> id") or 0).." megváltoztatta" .. tonumber(target:getData("acc >> id") or 0).." nevét! ("..newName..")"
                        exports['cr_logs']:addLog(thePlayer, "Admin", "ban", string.gsub(text, "#%x%x%x%x%x%x", ""))

                        target:setData("char >> name", newName)
                    else
                        local syntax = exports['cr_core']:getServerSyntax(false, "error")
                        outputChatBox(syntax.."A karakter név már foglalt!",element,255,255,255,true)
                    end
                else
                    local syntax = exports['cr_core']:getServerSyntax(false, "error")
                    outputChatBox(syntax..aName.." nincs bejelentkezve!",element,255,255,255,true)
                end
            else
                local syntax = exports['cr_core']:getServerSyntax(false, "error")
                outputChatBox(syntax.."Nincs találat "..target.."-ra(re)!",element,255,255,255,true)
            end
        end
    end
end
addCommandHandler("setname", setname_sc)
addCommandHandler("changename", setname_sc)

function givePremiumPoint(amount, accId)    
    if tonumber(amount) and tonumber(accId) then 
        local data = characters[accId]

        local newValue = amount;

        --//Online rész
        local online, playerE = getAccountOnline(accId)
        if online and isElement(playerE) then 
            exports['cr_infobox']:addBox(playerE, 'success', 'Sikeresen jóváírtunk neked '..amount..' pp-t!')

            newValue = tonumber(playerE:getData('char >> premiumPoints') or 0) + amount

            playerE:setData('char >> premiumPoints', newValue)
        else 
            if data and data[4] then
                newValue = tonumber(data[4]['pp']) + amount
            end 
        end 
        
        --//Offline Rész
        if data and data[4] then 
            data[4]['pp'] = newValue

            dbExec(connection, "UPDATE `characters` SET `details`=? WHERE `id`=?", toJSON(data[4]), accId)
        end 
    end 
end 