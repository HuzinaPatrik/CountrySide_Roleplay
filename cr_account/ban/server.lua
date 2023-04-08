white = "#ffffff"

function banCheck(sourceElement)
    local serial = getElementData(sourceElement, "mtaserial")
    local ip = getPlayerIP(sourceElement)
    local table = {[serial] = true, [ip] = true}
    for k,v in pairs(table) do
        local id = isIdentityHaveBan[k]
        if id then
            --bans[id] = {id, banIdentity, reason, aName, startDate, endDate}
            
            local id, banIdentity, reason, aName, startDate, endDate, aLevel = unpack(bans[id])
            
            setElementData(sourceElement, "ban.id", id)
            setElementData(sourceElement, "ban.accountName", banIdentity["accountName"])
            setElementData(sourceElement, "ban.reason", reason)
            setElementData(sourceElement, "ban.aName", aName)
            setElementData(sourceElement, "ban.aLevel", aLevel)
            setElementData(sourceElement, "ban.startDate", startDate)
            setElementData(sourceElement, "ban.endDate", endDate)
            setTimer(
                function()
                    triggerClientEvent(sourceElement, "banResult", sourceElement, true)
                end, 1000, 1
            )
            return
        end
    end
    setTimer(
        function()
            triggerClientEvent(sourceElement, "banResult", sourceElement, false)
        end, 1000, 1
    )
end
addEvent("player.banCheck", true)
addEventHandler("player.banCheck", root, banCheck)

function clearBans()
    dbQuery(
        function(query)
            local query, query_lines = dbPoll(query, 0)
            if query_lines > 0 then
                Async:foreach(query, 
                    function(row)
                        local id = tonumber(row["id"])
                        dbExec(connection, "DELETE FROM `bans` WHERE `id`=?", id)
                        outputDebugString("[Ban] #"..id.." deleted!", 0, 255, 50, 255)

                        local data = bans[id]
                        bans[id] = nil

                        local banIdentity = data[2]
                        for k,v in pairs(banIdentity) do
                            isIdentityHaveBan[k] = nil
                        end

                        local username = banIdentity["accountName"]
                        if username then 
                            local id = accounts[username][1]
                            accounts[username][10] = false
                            dbExec(connection, "UPDATE `accounts` SET `banned`=? WHERE `id`=?", "false", id)
                        end 
                    end
                )
            end
            outputDebugString("[Ban] Succesfully deleted "..query_lines.." ban!", 0, 255, 50, 255)
        end, 
    connection, "SELECT * FROM `bans` WHERE `endDate` < NOW()")
end
clearBans()
setTimer(clearBans, (60 * 60 * 1000), 0)

-- /ban
function banPlayer(thePlayer, cmd, target, time, ...)
    if exports['cr_permission']:hasPermission(thePlayer, "ban") then
        local e = {...}
        if not target or not time or #e <= 0  then
            local syntax = exports['cr_core']:getServerSyntax(false, "warning")
            outputChatBox(syntax .. "/"..cmd.. " [Név/ID] [Idő - órában (0 = Örök)] [Indok]", thePlayer, 255,255,255,true)
            return 
        end
        
        local aName = exports['cr_admin']:getAdminName(thePlayer, true)
		local aId = thePlayer:getData("acc >> id")
		local orange = exports['cr_core']:getServerColor("orange", true)
        
        local _target = target
        local target = exports['cr_core']:findPlayer(thePlayer, target)
        if not target then
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax .. "Nincs találat ("..orange.._target..white.."-ra/re)", thePlayer, 255,255,255,true)
            return
        end
        
        time = tonumber(time)
        if time == nil or time < 0 then
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax .. "Az időnek egy számnak kell lennie mely nagyobb/egyenlő mint 0!", thePlayer, 255,255,255,true)
            return
        end
        
        if time == 0 then
            time = 8765812.77
        end
        
        local tALevel = getElementData(target, "admin >> level") or 0
        local pALevel = getElementData(thePlayer, "admin >> level") or 0
        
        if tALevel > pALevel then
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax .. "Magadnál csak kisebb admint bannolhatsz ki!", thePlayer, 255,255,255,true)
            outputChatBox(syntax .. orange..aName..white.." ki akart bannolni!", target, 255,255,255,true)
            return
        end
        
        if target == thePlayer then
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax .. "Saját magadat nem bannolhatod ki!", thePlayer, 255,255,255,true)
            return
        end
        
        local reason = table.concat(e, " ")
        
        if getElementData(target, "loggedIn") then
            local id = getElementData(target, "acc >> id")
            local username = getElementData(target, "acc >> username")
            local serial = getPlayerSerial(target)
            local ip = getPlayerIP(target)
            local banIdentity = {["accountName"] = username, [username] = true, [serial]=true, [ip]=true}
            local serials = accounts[username][8]
            local ips = accounts[username][9]

            for k,v in pairs(serials) do
                banIdentity[k] = true
            end

            for k,v in pairs(ips) do
                banIdentity[k] = true
            end
            banIdentity = toJSON(banIdentity)
            
            local reason = reason
            accounts[username][10] = true
            dbExec(connection, "UPDATE `accounts` SET `banned`=? WHERE `id`=?", "true", id)
            dbExec(connection, "INSERT INTO `bans` SET `banIdentity`=?, `reason`=?, `aName`=?, `startDate`=NOW(), `endDate`=DATE_SUB(NOW(), INTERVAL -"..time.." HOUR), `aId`=?, `aLevel`=?", banIdentity, reason, aName, aId, pALevel)
            
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
                                outputDebugString("Ban id #"..id.." - loaded!", 0, 255, 50, 255)
                            end
                        )
                    end
                end, 
            connection, "SELECT * FROM `bans` WHERE `aName`=? AND `banIdentity`=?", aName, banIdentity)
            
            local targetName = exports['cr_admin']:getAdminName(target, false)
            local text = aName.." kitiltotta "..targetName.."-at/et a szerverről!"
            local text2 = reason
            
            local red = exports['cr_core']:getServerColor("red", true)
            local blue = exports['cr_core']:getServerColor("yellow", true)
            local white = "#F2F2F2"
            local banTime = time
            local banText = ""
            if banTime == 8765812.77 then
                banText = "Időtartam: "..red.."Örökre"..white
            elseif math.floor(banTime / 168) >= 1 then
                banText = "Időtartam: ".. red .. math.floor(banTime / 168) .. " hét" .. white
            else
                banText = "Időtartam: ".. red .. math.ceil(banTime) .. " óra" .. white
            end
            local banText2 = string.gsub(banText, "#" .. (6 and string.rep("%x", 6) or "%x+"), "")
            triggerEvent("showAdminBox",thePlayer, blue .. aName.. white .. " kitiltotta "..red..targetName..white.."-at/et a szerverről!\n"..banText.."\nIndok: "..red..reason, "error", {text, banText2, "Indok: "..text2})
            
            local time = exports['cr_core']:getTime() .. " "
            local text = string.gsub(text, aName, (tonumber(getElementData(thePlayer, "acc >> id")) or inspect(thePlayer)))
            local text = string.gsub(text, targetName, (tonumber(getElementData(target, "acc >> id")) or inspect(target)))
            target:kick(aName, "Ki lettél tiltva a szerverről!")
            
            --local syntax = exports['cr_admin']:getAdminSyntax("Ban")
            --exports['cr_core']:sendMessageToAdmin(thePlayer, syntax .. text, 0)
            --exports['cr_core']:sendMessageToAdmin(thePlayer, syntax .. text2, 0)
            
            exports['cr_logs']:addLog(thePlayer, "Admin", "ban", string.gsub(text, "#%x%x%x%x%x%x", ""))
            exports['cr_logs']:addLog(thePlayer, "Admin", "ban", string.gsub(text2, "#%x%x%x%x%x%x", ""))
            
            dbExec(connection, "INSERT INTO `ban_log` SET `account_id`=?, `reason`=?, `admin`=?", id, reason, aName)
            
            local maxHasFix = exports['cr_admin']:getMaxBanCount() or 0
            local hasFIX = getElementData(thePlayer, "ban >> using") or 0
            local hasFIX = hasFIX + 1
            setElementData(thePlayer, "ban >> using", hasFIX)
            if hasFIX > maxHasFix then
                local green = exports['cr_core']:getServerColor("orange", true)
                local syntax = exports['cr_core']:getServerSyntax(false, "error")
                --local vehicleName = getVehicleName(target)
                outputChatBox(syntax .. "Figyelem! Átlépted a megengedett Ban limitet! (Limit: "..green..maxHasFix..white..") (Bannok száma: "..green..hasFIX..white..")", thePlayer, 255,255,255,true)
            end
        else
            local serial = getPlayerSerial(target)
            local id = isSerialAttachedToAccount[serial]
            if id then
                local username = id
                local id = accounts[id][1]
                local ip = getPlayerIP(target)
                local banIdentity = {["accountName"] = username, [username] = true, [serial]=true, [ip]=true}
                local serials = accounts[username][8]
                local ips = accounts[username][9]

                for k,v in pairs(serials) do
                    banIdentity[k] = true
                end

                for k,v in pairs(ips) do
                    banIdentity[k] = true
                end
                banIdentity = toJSON(banIdentity)
                
                local reason = reason
                accounts[username][10] = true
                dbExec(connection, "UPDATE `accounts` SET `banned`=? WHERE `id`=?", tostring(true), id)
                dbExec(connection, "INSERT INTO `bans` SET `banIdentity`=?, `reason`=?, `aName`=?, `startDate`=NOW(), `endDate`=DATE_SUB(NOW(), INTERVAL -"..time.." HOUR), `aId`=?, `aLevel`=?", banIdentity, reason, aName, aId, pALevel)

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
                                    outputDebugString("Ban id #"..id.." - loaded!", 0, 255, 50, 255)
                                end
                            )
                        end
                    end, 
                connection, "SELECT * FROM `bans` WHERE `aName`=? AND `banIdentity`=?", aName, banIdentity)

                local targetName = exports['cr_admin']:getAdminName(target, false)
                --local syntax = exports['cr_admin']:getAdminSyntax("Ban")
                local text = aName.." kitiltotta "..targetName.."-at/et a szerverről!"
                local text2 = reason
                --exports['cr_core']:sendMessageToAdmin(thePlayer, syntax .. text, 0)
                --exports['cr_core']:sendMessageToAdmin(thePlayer, syntax .. text2, 0)
                local red = exports['cr_core']:getServerColor("red", true)
                local blue = exports['cr_core']:getServerColor("yellow", true)
                local white = "#F2F2F2"
                
                local banTime = time
                local banText = ""
                if banTime == 8765812.77 then
                    banText = "Időtartam: "..red.."Örökre"..white
                elseif math.floor(banTime / 168) >= 1 then
                    banText = "Időtartam: ".. red .. math.floor(banTime / 168) .. " hét" .. white
                else
                    banText = "Időtartam: ".. red .. math.ceil(banTime) .. " óra" .. white
                end
                local banText2 = string.gsub(banText, "#" .. (6 and string.rep("%x", 6) or "%x+"), "")
                triggerEvent("showAdminBox",thePlayer, blue .. aName.. white .. " kitiltotta "..red..targetName..white.."-at/et a szerverről!\n"..banText.."\nIndok: "..red..reason, "error", {text, banText2, "Indok: "..text2})
                local time = exports['cr_core']:getTime() .. " "
                --triggerEvent("showInfo",thePlayer,target,"ban",text2,text)
                --triggerEvent("showAdminBox",thePlayer, "#ff751a" .. aName.." #ffffffkitiltotta #ff751a"..targetName.."#ffffff-at/et a szerverről!\n#ff751aIndok:#ffffff "..reason, "error", {text, "Indok: "..text2})
                local text = string.gsub(text, aName, (tonumber(getElementData(thePlayer, "acc >> id")) or inspect(thePlayer)))
                local text = string.gsub(text, targetName, (tonumber(getElementData(target, "acc >> id")) or inspect(target)))
                target:kick(aName, "Ki lettél tiltva a szerverről!")

                exports['cr_logs']:addLog(thePlayer, "Admin", "ban", string.gsub(text, "#%x%x%x%x%x%x", ""))
                exports['cr_logs']:addLog(thePlayer, "Admin", "ban", string.gsub(text2, "#%x%x%x%x%x%x", ""))
                
                dbExec(connection, "INSERT INTO `ban_log` SET `account_id`=?, `reason`=?, `admin`=?", id, reason, aName)
                
                local maxHasFix = exports['cr_admin']:getMaxBanCount() or 0
                local hasFIX = getElementData(thePlayer, "ban >> using") or 0
                local hasFIX = hasFIX + 1
                setElementData(thePlayer, "ban >> using", hasFIX)
                if hasFIX > maxHasFix then
                    local green = exports['cr_core']:getServerColor("orange", true)
                    local syntax = exports['cr_core']:getServerSyntax(false, "error")
                    --local vehicleName = getVehicleName(target)
                    outputChatBox(syntax .. "Figyelem! Átlépted a megengedett Ban limitet! (Limit: "..green..maxHasFix..white..") (Bannok száma: "..green..hasFIX..white..")", thePlayer, 255,255,255,true)
                end
            else
                local username = "Ismeretlen"
                local ip = getPlayerIP(target)
                local banIdentity = toJSON({["accountName"] = username, [username] = true, [serial]=true, [ip]=true})
                local reason = reason
                --accounts[username][10] = true
                --dbExec(connection, "UPDATE `accounts` SET `banned`=? WHERE `id`=?", tostring(true), id)
                
                dbExec(connection, "INSERT INTO `bans` SET `banIdentity`=?, `reason`=?, `aName`=?, `startDate`=NOW(), `endDate`=DATE_SUB(NOW(), INTERVAL -"..time.." HOUR), `aId` = ?, `aLevel`=?", banIdentity, reason, aName, aId, pALevel)

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
                                    outputDebugString("Ban id #"..id.." - loaded!", 0, 255, 50, 255)
                                end
                            )
                        end
                    end, 
                connection, "SELECT * FROM `bans` WHERE `aName`=? AND `banIdentity`=?", aName, banIdentity)

                local targetName = exports['cr_admin']:getAdminName(target, false)
                local text = aName.." kitiltotta "..targetName.."-at/et a szerverről!"
                local text2 = reason
                
                --exports['cr_core']:sendMessageToAdmin(thePlayer, syntax .. text, 0)
                --exports['cr_core']:sendMessageToAdmin(thePlayer, syntax .. text2, 0)
                local red = exports['cr_core']:getServerColor("red", true)
                local blue = exports['cr_core']:getServerColor("yellow", true)
                local white = "#F2F2F2"
                local banTime = time
                local banText = ""
                if banTime == 8765812.77 then
                    banText = "Időtartam: "..red.."Örökre"..white
                elseif math.floor(banTime / 168) >= 1 then
                    banText = "Időtartam: ".. red .. math.floor(banTime / 168) .. " hét" .. white
                else
                    banText = "Időtartam: ".. red .. math.ceil(banTime) .. " óra" .. white
                end
                local banText2 = string.gsub(banText, "#" .. (6 and string.rep("%x", 6) or "%x+"), "")
                triggerEvent("showAdminBox",thePlayer, blue .. aName.. white .. " kitiltotta "..red..targetName..white.."-at/et a szerverről!\n"..banText.."\nIndok: "..red..reason, "error", {text, banText2, "Indok: "..text2})
                local time = exports['cr_core']:getTime() .. " "
                --triggerEvent("showInfo",thePlayer,target,"ban",text2,text)
                --triggerEvent("showAdminBox",thePlayer, "#ff751a" .. aName.." #ffffffkitiltotta #ff751a"..targetName.."#ffffff-at/et a szerverről!\n#ff751aIndok:#ffffff "..reason, "error", {text, "Indok: "..text2})
                local text = string.gsub(text, aName, (tonumber(getElementData(thePlayer, "acc >> id")) or inspect(thePlayer)))
                local text = string.gsub(text, targetName, (tonumber(getElementData(target, "acc >> id")) or inspect(target)))
                target:kick(aName, "Ki lettél tiltva a szerverről!")

                --local syntax = exports['cr_admin']:getAdminSyntax("Ban")
                exports['cr_logs']:addLog(thePlayer, "Admin", "ban", string.gsub(text, "#%x%x%x%x%x%x", ""))
                exports['cr_logs']:addLog(thePlayer, "Admin", "ban", string.gsub(text2, "#%x%x%x%x%x%x", ""))
                
                --dbExec(connection, "INSERT INTO `ban_log` SET `account_id`=?, `reason`=?, `admin`=?", id, reason, aName)
                local maxHasFix = exports['cr_admin']:getMaxBanCount() or 0
                local hasFIX = getElementData(thePlayer, "ban >> using") or 0
                local hasFIX = hasFIX + 1
                setElementData(thePlayer, "ban >> using", hasFIX)
                if hasFIX > maxHasFix then
                    local green = exports['cr_core']:getServerColor("orange", true)
                    local syntax = exports['cr_core']:getServerSyntax(false, "error")
                    --local vehicleName = getVehicleName(target)
                    outputChatBox(syntax .. "Figyelem! Átlépted a megengedett Ban limitet! (Limit: "..green..maxHasFix..white..") (Bannok száma: "..green..hasFIX..white..")", thePlayer, 255,255,255,true)
                end
            end
        end
    end
end
addCommandHandler("ban", banPlayer)
addCommandHandler("banp", banPlayer)
addCommandHandler("pban", banPlayer)

-- /oban
function obanPlayer(thePlayer, cmd, target, time, ...)
    if exports['cr_permission']:hasPermission(thePlayer, "oban") then
        local e = {...}
        if not target or not time or #e <= 0  then
            local syntax = exports['cr_core']:getServerSyntax(false, "warning")
            outputChatBox(syntax .. "/"..cmd.. " [KarakterNév (TELJES! '_'-al)/accountNév/Serial] [Idő - órában (0 = Örök)] [Indok]", thePlayer, 255,255,255,true)
            return 
        end
        
        local _target = target
        local target = isNameRegistered[string.lower(target)] or accounts[target] or isSerialAttachedToAccount[target]
        local orange = exports['cr_core']:getServerColor("orange", true)
		
        if target then
            local oName, oID
            if type(target) == "number" then
                oID = target
                oName = idConvertToName[oID]
            elseif type(target) == "table" then
                oID = target[1]
                oName = _target
            end

            local aName = exports['cr_admin']:getAdminName(thePlayer, true)
			local aId = thePlayer:getData("acc >> id")

            time = tonumber(time)
            if time == nil or time < 0 then
                local syntax = exports['cr_core']:getServerSyntax(false, "error")
                outputChatBox(syntax .. "Az időnek egy számnak kell lennie mely nagyobb/egyenlő mint 0!", thePlayer, 255,255,255,true)
                return
            end

            --time = math.floor(time)
            if time == 0 then
                time = 8765812.77
            end
            
            
            local tALevel = characters[oID][7][1] or 0
            local pALevel = getElementData(thePlayer, "admin >> level") or 0

            if tALevel > pALevel then
                local syntax = exports['cr_core']:getServerSyntax(false, "error")
                outputChatBox(syntax .. "Magadnál csak kisebb admint bannolhatsz ki!", thePlayer, 255,255,255,true)
                --outputChatBox(syntax .. orange..aName..white.." ki akart bannolni!", target, 255,255,255,true)
                return
            end

            local aID = getElementData(thePlayer, "acc >> id")
            if oID == aID then
                local syntax = exports['cr_core']:getServerSyntax(false, "error")
                outputChatBox(syntax .. "Saját magadat nem bannolhatod ki!", thePlayer, 255,255,255,true)
                return
            end

            local reason = table.concat(e, " ")

            local id = oID
            local username = oName
            local serials = accounts[username][8]
            local ips = accounts[username][9]
            local banIdentity = {["accountName"] = username, [username] = true}
            
            for k,v in pairs(serials) do
                banIdentity[k] = true
            end
            
            for k,v in pairs(ips) do
                banIdentity[k] = true
            end
            
            banIdentity = toJSON(banIdentity)
            
            local reason = reason
            accounts[username][10] = true
            dbExec(connection, "UPDATE `accounts` SET `banned`=? WHERE `id`=?", tostring(true), id)
            --, `aLevel`=?, pALevel
            dbExec(connection, "INSERT INTO `bans` SET `banIdentity`=?, `reason`=?, `aName`=?, `startDate`=NOW(), `endDate`=DATE_SUB(NOW(), INTERVAL -"..time.." HOUR), `aId` = ?, `aLevel`=?", banIdentity, reason, aName, aId, pALevel)

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
                                outputDebugString("Ban id #"..id.." - loaded!", 0, 255, 50, 255)
                            end
                        )
                    end
                end, 
            connection, "SELECT * FROM `bans` WHERE `aName`=? AND `banIdentity`=?", aName, banIdentity)

            local syntax = exports['cr_admin']:getAdminSyntax("Ban")
            local targetName = characters[oID][2]:gsub("_", " ")
            local text = aName.." kitiltotta "..targetName.."-at/et a szerverről!"
            local text2 = reason
            --exports['cr_core']:sendMessageToAdmin(thePlayer, syntax .. text, 0)
            --exports['cr_core']:sendMessageToAdmin(thePlayer, syntax .. text2, 0)
            --triggerEvent("showInfo",thePlayer,thePlayer,"ban",text2,text)
            --triggerEvent("showAdminBox",thePlayer, "#ff751a" .. aName.." #ffffffkitiltotta #ff751a"..targetName.."#ffffff-at/et a szerverről! #ff751aa[Offline]#ffffff\n#ff751aIndok:#ffffff "..reason, "error", {text .. "[Offline]", "Indok: "..text2})
            local red = exports['cr_core']:getServerColor("red", true)
            local blue = exports['cr_core']:getServerColor("yellow", true)
            local white = "#F2F2F2"
            local banTime = time
            local banText = ""
            if banTime == 8765812.77 then
                banText = "Időtartam: "..red.."Örökre"..white
            elseif math.floor(banTime / 168) >= 1 then
                banText = "Időtartam: ".. red .. math.floor(banTime / 168) .. " hét" .. white
            else
                banText = "Időtartam: ".. red .. math.ceil(banTime) .. " óra" .. white
            end
            local banText2 = string.gsub(banText, "#" .. (6 and string.rep("%x", 6) or "%x+"), "")
            triggerEvent("showAdminBox",thePlayer, blue .. aName.. white .. " kitiltotta "..red..targetName..white.."-at/et a szerverről! "..red.."[Offline]"..white.."\n"..banText.."\nIndok: "..red..reason, "error", {text .. " [Offline]", banText2, "Indok: "..text2})
            
            local time = exports['cr_core']:getTime() .. " "
            local text = string.gsub(text, aName, (tonumber(getElementData(thePlayer, "acc >> id")) or inspect(thePlayer)))
            local text = string.gsub(text, targetName, oID)
            exports['cr_logs']:addLog(thePlayer, "Admin", "oban", string.gsub(text, "#%x%x%x%x%x%x", ""))
            exports['cr_logs']:addLog(thePlayer, "Admin", "oban", string.gsub(text2, "#%x%x%x%x%x%x", ""))
            
            dbExec(connection, "INSERT INTO `ban_log` SET `account_id`=?, `reason`=?, `admin`=?", id, reason, aName)
            
            local maxHasFix = exports['cr_admin']:getMaxBanCount() or 0
            local hasFIX = getElementData(thePlayer, "ban >> using") or 0
            local hasFIX = hasFIX + 1
            setElementData(thePlayer, "ban >> using", hasFIX)
            if hasFIX > maxHasFix then
                local green = exports['cr_core']:getServerColor("orange", true)
                local syntax = exports['cr_core']:getServerSyntax(false, "error")
                --local vehicleName = getVehicleName(target)
                outputChatBox(syntax .. "Figyelem! Átlépted a megengedett Ban limitet! (Limit: "..green..maxHasFix..white..") (Bannok száma: "..green..hasFIX..white..")", thePlayer, 255,255,255,true)
            end
        else
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax .. "Nincs találat ("..orange.._target..white.."-ra/re)", thePlayer, 255,255,255,true)
            return
        end
    end
end
addCommandHandler("oban", obanPlayer)
addCommandHandler("obanp", obanPlayer)
addCommandHandler("opban", obanPlayer)

function ucpBan(accID, adminName, accID2, aLevel)
    local target = accID
    local _target = target
    local target = isNameRegistered[target] or accounts[target] or isSerialAttachedToAccount[target]
    local orange = exports['cr_core']:getServerColor("orange", true)

    if target then
        local oName, oID
        if type(target) == "number" then
            oID = target
            oName = idConvertToName[oID]
        elseif type(target) == "table" then
            oID = target[1]
            oName = _target
        end

        local aName = adminName -- exports['cr_admin']:getAdminName(thePlayer, true)
        local aId = accID2 -- thePlayer:getData("acc >> id")

        time = tonumber(time)
        if time == nil or time < 0 then
            --local syntax = exports['cr_core']:getServerSyntax(false, "error")
            --outputChatBox(syntax .. "Az időnek egy számnak kell lennie mely nagyobb/egyenlő mint 0!", thePlayer, 255,255,255,true)
            return
        end

        --time = math.floor(time)
        if time == 0 then
            time = 8765812.77
        end


        local tALevel = characters[oID][7][1] or 0
        local pALevel = aLevel --getElementData(thePlayer, "admin >> level") or 0

        if tALevel > pALevel then
            --local syntax = exports['cr_core']:getServerSyntax(false, "error")
            --outputChatBox(syntax .. "Magadnál csak kisebb admint bannolhatsz ki!", thePlayer, 255,255,255,true)
            --outputChatBox(syntax .. orange..aName..white.." ki akart bannolni!", target, 255,255,255,true)
            return
        end

        local aID = getElementData(thePlayer, "acc >> id")
        if oID == aID then
            --local syntax = exports['cr_core']:getServerSyntax(false, "error")
            --outputChatBox(syntax .. "Saját magadat nem bannolhatod ki!", thePlayer, 255,255,255,true)
            return
        end

        local reason = table.concat(e, " ")

        local id = oID
        local username = oName
        local serials = accounts[username][8]
        local ips = accounts[username][9]
        local banIdentity = {["accountName"] = username, [username] = true}

        for k,v in pairs(serials) do
            banIdentity[k] = true
        end

        for k,v in pairs(ips) do
            banIdentity[k] = true
        end

        banIdentity = toJSON(banIdentity)

        local reason = reason
        accounts[username][10] = true
        
        dbExec(connection, "UPDATE `accounts` SET `banned`=? WHERE `id`=?", tostring(true), id)
        dbExec(connection, "INSERT INTO `bans` SET `banIdentity`=?, `reason`=?, `aName`=?, `startDate`=NOW(), `endDate`=DATE_SUB(NOW(), INTERVAL -"..time.." HOUR), `aId` = ?, `aLevel`=?", banIdentity, reason, aName, aId, pALevel)

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
                            outputDebugString("Ban id #"..id.." - loaded!", 0, 255, 50, 255)
                        end
                    )
                end
            end, 
        connection, "SELECT * FROM `bans` WHERE `aName`=? AND `banIdentity`=?", aName, banIdentity)

        local syntax = exports['cr_admin']:getAdminSyntax("Ban")
        local targetName = characters[oID][2]:gsub("_", " ")
        local text = aName.." kitiltotta "..targetName.."-at/et a szerverről!"
        local text2 = reason
        --exports['cr_core']:sendMessageToAdmin(thePlayer, syntax .. text, 0)
        --exports['cr_core']:sendMessageToAdmin(thePlayer, syntax .. text2, 0)
        --triggerEvent("showInfo",thePlayer,thePlayer,"ban",text2,text)
        --triggerEvent("showAdminBox",thePlayer, "#ff751a" .. aName.." #ffffffkitiltotta #ff751a"..targetName.."#ffffff-at/et a szerverről! #ff751aa[Offline]#ffffff\n#ff751aIndok:#ffffff "..reason, "error", {text .. "[Offline]", "Indok: "..text2})
        local red = exports['cr_core']:getServerColor("red", true)
        local blue = exports['cr_core']:getServerColor("yellow", true)
        local white = "#F2F2F2"
        local banTime = time
        local banText = ""
        if banTime == 8765812.77 then
            banText = "Időtartam: "..red.."Örökre"..white
        elseif math.floor(banTime / 168) >= 1 then
            banText = "Időtartam: ".. red .. math.floor(banTime / 168) .. " hét" .. white
        else
            banText = "Időtartam: ".. red .. math.ceil(banTime) .. " óra" .. white
        end
        local banText2 = string.gsub(banText, "#" .. (6 and string.rep("%x", 6) or "%x+"), "")
        triggerEvent("showAdminBox",thePlayer, blue .. aName.. white .. " kitiltotta "..red..targetName..white.."-at/et a szerverről! "..red.."[Offline]"..white.."\n"..banText.."\nIndok: "..red..reason, "error", {text .. " [Offline]", banText2, "Indok: "..text2})
        local time = exports['cr_core']:getTime() .. " "
        local text = string.gsub(text, aName, accID2)
        local text = string.gsub(text, targetName, oID)
        exports['cr_logs']:addLog(thePlayer, "Admin", "oban", string.gsub(text, "#%x%x%x%x%x%x", ""))
        exports['cr_logs']:addLog(thePlayer, "Admin", "oban", string.gsub(text2, "#%x%x%x%x%x%x", ""))

        dbExec(connection, "INSERT INTO `ban_log` SET `account_id`=?, `reason`=?, `admin`=?", id, reason, aName)
    else
        --local syntax = exports['cr_core']:getServerSyntax(false, "error"
        --outputChatBox(syntax .. "Nincs találat ("..orange.._target..white.."-ra/re)", thePlayer, 255,255,255,true)
        return
    end
end
addEvent("ucpBan", true)
addEventHandler("ucpBan", root, ucpBan)

-- /unban
function unbanPlayer(thePlayer, cmd, target)
    if exports['cr_permission']:hasPermission(thePlayer, "unban") then
        if not target then
            local syntax = exports['cr_core']:getServerSyntax(false, "warning")
            outputChatBox(syntax .. "/"..cmd.. " [banID]", thePlayer, 255,255,255,true)
            return 
        end
        
        target = tonumber(target)
        local orange = exports['cr_core']:getServerColor("orange", true)
		
        if not target then
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax .. "A BanIDnek egy számnak kell lennie!", thePlayer, 255,255,255,true)
            return
        end
        
        local _target = target
        local target = bans[target]
        
        if target then
            local oName, oID
            oName = target[2]["accountName"]
            oID = accounts[oName][1]
            
            local tALevel = target[7] or 0
            local pALevel = getElementData(thePlayer, "admin >> level") or 0

            if tALevel > pALevel then
                local syntax = exports['cr_core']:getServerSyntax(false, "error")
                outputChatBox(syntax .. "Nálad magasabb szintű admin bannolta a célpontot!", thePlayer, 255,255,255,true)
                --outputChatBox(syntax .. orange..aName..white.." ki akart bannolni!", target, 255,255,255,true)
                return
            end

            local aName = exports['cr_admin']:getAdminName(thePlayer, true)

            local id = oID
            local username = oName
            
            local banIdentity = target[2]
            for k,v in pairs(banIdentity) do
                isIdentityHaveBan[k] = nil
            end
            bans[_target] = nil
            accounts[username][10] = false
            dbExec(connection, "UPDATE `accounts` SET `banned`=? WHERE `id`=?", "false", id)
            
            dbExec(connection, "DELETE FROM `bans` WHERE `id`=?", _target)

            local syntax = exports['cr_admin']:getAdminSyntax("Ban")
            local targetName = characters[oID][2]:gsub("_", " ")
            local text = orange..aName..white.." feloldotta "..orange..targetName..white.." tiltását!"
            exports['cr_core']:sendMessageToAdmin(thePlayer, syntax .. text, 3)
            local time = exports['cr_core']:getTime() .. " "
            local text = string.gsub(text, aName, (tonumber(getElementData(thePlayer, "acc >> id")) or inspect(thePlayer)))
            local text = string.gsub(text, targetName, oID)
            exports['cr_logs']:addLog(thePlayer, "Admin", "unban", string.gsub(text, "#%x%x%x%x%x%x", ""))
            
            dbExec(connection, "UPDATE `ban_log` SET `status`=? WHERE `account_id`=?", 'Deactive', id)
			exports.cr_ucp:deactivateUnbanRequest(id)
        else
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax .. "Nincs találat ("..orange.._target..white.." idjű banra)", thePlayer, 255,255,255,true)
            return
        end
    end
end
addCommandHandler("unban", unbanPlayer)
addCommandHandler("unbanp", unbanPlayer)

function ucpUnban(banID, accID, adminName, accID2, aLevel)

    --outputChatBox("asd")
    
    local id
    if bans[banID] then
        id = banID
    else
        id = isIdentityHaveBan[banID]
    end
    if id then
        target = tonumber(id)
        local orange = exports['cr_core']:getServerColor("orange", true)

        if not target then
            --local syntax = exports['cr_core']:getServerSyntax(false, "error")
            --outputChatBox(syntax .. "A BanIDnek egy számnak kell lennie!", thePlayer, 255,255,255,true)
            return
        end

        local _target = target
        local target = bans[target]

        if target then
            local oName, oID
            oName = target[2]["accountName"]
            oID = accounts[oName][1]
            
            local tALevel = target[7] or 0
            local pALevel = getElementData(thePlayer, "admin >> level") or 0

            if tALevel > pALevel then
                --local syntax = exports['cr_core']:getServerSyntax(false, "error")
                --outputChatBox(syntax .. "Nálad magasabb szintű admin bannolta a célpontot!", thePlayer, 255,255,255,true)
                --outputChatBox(syntax .. orange..aName..white.." ki akart bannolni!", target, 255,255,255,true)
                return
            end

            local aName = adminName --exports['cr_admin']:getAdminName(thePlayer, true)

            local id = oID
            local username = oName

            local banIdentity = target[2]
            for k,v in pairs(banIdentity) do
                isIdentityHaveBan[k] = nil
            end
            bans[_target] = nil
            accounts[username][10] = false
            dbExec(connection, "UPDATE `accounts` SET `banned`=? WHERE `id`=?", "false", id)

            dbExec(connection, "DELETE FROM `bans` WHERE `id`=?", _target)

            local syntax = exports['cr_admin']:getAdminSyntax("Ban")
            local targetName = characters[oID][2]:gsub("_", " ")
            local text = orange..aName..white.." feloldotta "..orange..targetName..white.." tiltását!"
            exports['cr_core']:sendMessageToAdmin(getRandomPlayer(), syntax .. text, 3)
            local time = exports['cr_core']:getTime() .. " "
            local text = string.gsub(text, aName, accID2)
            local text = string.gsub(text, targetName, oID)
            exports['cr_logs']:addLog(thePlayer, "Admin", "unban", string.gsub(text, "#%x%x%x%x%x%x", ""))

            dbExec(connection, "UPDATE `ban_log` SET `status`=? WHERE `account_id`=?", 'Deactive', id)
            exports.cr_ucp:deactivateUnbanRequest(id)
        else
            --local syntax = exports['cr_core']:getServerSyntax(false, "error")
            --outputChatBox(syntax .. "Nincs találat ("..orange.._target..white.." idjű banra)", thePlayer, 255,255,255,true)
            return
        end
    end
end
addEvent("ucpUnban", true)
addEventHandler("ucpUnban", root, ucpUnban)