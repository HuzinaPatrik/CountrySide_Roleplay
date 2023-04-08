function generatePassword(username, password)
    if username and password then 
        local hashPassword1 = hash("sha512", username .. password .. username)
        local hashedPassword = hash("md5", salt .. hashPassword1 .. salt)

        return hashedPassword
    end

    return false
end

function createAccount(thePlayer, factionId, username, password)
    if isElement(thePlayer) and not mdcAccounts[username] then 
        local startTick = getTickCount()
        local hashedPassword = generatePassword(username, password)

        dbExec(sql, "INSERT INTO mdcaccounts SET username = ?, password = ?, faction = ?, leader = ?, online = ?", username, hashedPassword, factionId, "false", "false")

        dbQuery(
            function(queryHandle, thePlayer)
                local query, query_lines = dbPoll(queryHandle, 0)

                if query_lines > 0 then 
                    local row = query[1]

                    loadAccount(row)
                    outputDebugString("@createAccount: created 1 account in " .. getTickCount() - startTick .. " ms.", 0, 255, 50, 255)
                    
                    if isElement(thePlayer) then 
                        local syntax = exports.cr_core:getServerSyntax(false, "success")
                        local hexCode = exports.cr_core:getServerColor("blue", true)

                        local name = exports.cr_admin:getAdminName(thePlayer)
                        local hexColor = exports.cr_core:getServerColor("yellow", true)

                        outputChatBox(syntax .. "Sikeresen létrehoztad a felhasználót! " .. hexCode .. "(" .. row.username .. ") " .. white .. "ID: " .. hexCode .. row.id, thePlayer, 255, 0, 0, true)
                        addLog(thePlayer, hexColor .. name .. white .. " létrehozott egy felhasználót. Név: " .. hexColor .. row.username)

                        if not mdcViewersElementCache[thePlayer] then 
                            addToViewers(thePlayer)
                        end

                        loadData(thePlayer, getElementsByType("player"))
                    end
                end
            end, {thePlayer}, sql, "SELECT * FROM mdcaccounts WHERE id = LAST_INSERT_ID() AND username = ?", username
        )
    else
        local syntax = exports.cr_core:getServerSyntax(false, "error")

        outputChatBox(syntax .. "Már létezik egy felhasználó ezzel a névvel.", thePlayer, 255, 0, 0, true)
    end
end

function deleteAccount(thePlayer, username)
    if isElement(thePlayer) and mdcAccounts[username] then 
        local dbId = mdcAccounts[username].id

        dbExec(sql, "DELETE FROM mdcaccounts WHERE id = ?", dbId)
        mdcAccounts[username] = nil

        local syntax = exports.cr_core:getServerSyntax(false, "success")
        local hexCode = exports.cr_core:getServerColor("blue", true)

        local name = exports.cr_admin:getAdminName(thePlayer)
        local hexColor = exports.cr_core:getServerColor("yellow", true)

        outputChatBox(syntax .. "Sikeresen törölted a felhasználót! " .. hexCode .. "(" .. username .. ") " .. white .. "ID: " .. hexCode .. dbId, thePlayer, 255, 0, 0, true)
        addLog(thePlayer, hexColor .. name .. white .. " kitörölt egy felhasználót. Név: " .. hexColor .. username)
        loadData(thePlayer, mdcViewers)
    end
end

function createAccountCommand(thePlayer, cmd, factionId, username, password)
    if thePlayer:getData("loggedIn") then 
        if exports.cr_dashboard:isPlayerInFactionType(thePlayer, 1) then 
            if not factionId or not username or not password then 
                local syntax = exports.cr_core:getServerSyntax(false, "yellow")

                outputChatBox(syntax .. "/" .. cmd .. " [Frakció] [Felhasználónév] [Jelszó]", thePlayer, 255, 0, 0, true)
                return
            end

            local factionId = tonumber(factionId)
            local username = tostring(username)
            local password = tostring(password)

            if factionId ~= nil then 
                factionId = math.floor(tonumber(factionId))

                if factionId > 0 then 
                    local prefix = exports.cr_faction_scripts:getFactionPrefix(factionId)

                    if prefix and prefix ~= "Ismeretlen" then 
                        if exports.cr_dashboard:isPlayerFactionLeader(thePlayer, factionId) then 
                            if utf8.len(username) < 3 then 
                                local syntax = exports.cr_core:getServerSyntax(false, "error")

                                outputChatBox(syntax .. "A megadott név túl rövid! (Minimum 3 karakter)", thePlayer, 255, 0, 0, true)
    
                                return
                            end

                            if utf8.len(password) < 4 then 
                                local syntax = exports.cr_core:getServerSyntax(false, "error")

                                outputChatBox(syntax .. "A megadott jelszó túl rövid! (Minimum 4 karakter)", thePlayer, 255, 0, 0, true)

                                return
                            end

                            createAccount(thePlayer, factionId, username, password)
                        else
                            local syntax = exports.cr_core:getServerSyntax(false, "error")

                            outputChatBox(syntax .. "Nem te vagy a beírt frakció vezetője.", thePlayer, 255, 0, 0, true)
                        end
                    else 
                        local syntax = exports.cr_core:getServerSyntax(false, "error")
                        local hexColor = exports.cr_core:getServerColor("yellow", true)
                        local allFactionPrefixes = exports.cr_faction_scripts:getFactionPrefixes()

                        outputChatBox(syntax .. "Hibás frakció id! Nem létezik rövidítés ezzel az id-vel.", thePlayer, 255, 0, 0, true)
                        outputChatBox(" ", thePlayer, 255, 0, 0, true)
                        
                        outputChatBox(syntax .. "Elérhető rövidítések:", thePlayer, 255, 0, 0, true)

                        for k, v in pairs(allFactionPrefixes) do 
                            outputChatBox(syntax .. "Rövidítés: " .. hexColor .. v.prefix .. white .. " ID: " .. hexColor .. k, thePlayer, 255, 0, 0, true) 
                        end
                    end
                else
                    local syntax = exports.cr_core:getServerSyntax(false, "error")

                    outputChatBox(syntax .. "A frakciónak nagyobbnak kell lennie mint 0.", thePlayer, 255, 0, 0, true)
                end
            else
                local syntax = exports.cr_core:getServerSyntax(false, "error")

                outputChatBox(syntax .. "Csak szám.", thePlayer, 255, 0, 0, true)
            end
        end
    end
end
addCommandHandler("createmdcaccount", createAccountCommand, false, false)

function deleteAccountCommand(thePlayer, cmd, username)
    if thePlayer:getData("loggedIn") then 
        if not username then 
            local syntax = exports.cr_core:getServerSyntax(false, "yellow")

            outputChatBox(syntax .. "/" .. cmd .. " [Felhasználónév]", thePlayer, 255, 0, 0, true)
            return
        end

        local username = tostring(username)

        if not mdcAccounts[username] then 
            local syntax = exports.cr_core:getServerSyntax(false, "error")

            outputChatBox(syntax .. "Nem létezik felhasználó ezzel a névvel.", thePlayer, 255, 0, 0, true)
            return
        end

        local sourceFactionId = mdcAccounts[username].faction

        if exports.cr_dashboard:isPlayerFactionLeader(thePlayer, sourceFactionId) then 
            deleteAccount(thePlayer, username)
        else
            local syntax = exports.cr_core:getServerSyntax(false, "error")

            outputChatBox(syntax .. "Nem tudod kitörölni ezt a felhasználót, mivel nem vagy vezető az adott frakcióban.", thePlayer, 255, 0, 0, true)
        end
    end
end
addCommandHandler("deletemdcaccount", deleteAccountCommand, false, false)