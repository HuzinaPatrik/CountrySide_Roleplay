local atmCache = {}
local idToAtm = {}

function resetATMs()
    for k, v in pairs(atmCache) do 
        if isElement(k) then 
            local id = k:getData("bank >> atm")

            if k:getData("atm >> unavailable") and not exports.cr_robbery:isATMInUse(id) and not exports.cr_robbery:isGrinded(id) then 
                k:removeData("atm >> unavailable")
                k:removeData("atm >> health")
                k:removeData("atm >> cashBoxes")
                k:removeData("atm >> alreadyNotified")

                -- k.model = 2942
            end
        end
    end

    triggerLatentClientEvent(getElementsByType("player"), "atmRobbery.createATMBlips", 50000, false, getRandomPlayer() or resourceRoot)
end
setTimer(resetATMs, 60 * 60000, 0)

function loadATM(row)
    local id = tonumber(row["id"])
    local position = fromJSON(tostring(row["position"]))
    local x,y,z,dim,int,rot = unpack(position)

    local obj = Object(2942, x, y, z)
    obj.dimension = dim 
    obj.interior = int
    obj.rotation = Vector3(0, 0, rot)
    obj.frozen = true
    obj:setData("bank >> atm", id)

    atmCache[obj] = id
    idToAtm[id] = obj
end

function loadATMs()
    dbQuery(
        function(query)
            local query, query_lines = dbPoll(query, 0)
            if query_lines > 0 then
                Async:foreach(query, 
                    loadATM
                )
            end
            outputDebugString("Loading atms finished. Loaded #"..query_lines.." atms!", 0, 255, 50, 255)
        end, 
    connection, "SELECT * FROM `atms`")
end
addEventHandler("onResourceStart", resourceRoot, loadATMs)

function createATMCmd(sourcePlayer, cmd)
    if exports['cr_permission']:hasPermission(sourcePlayer, "addatm") then 
        local position = {sourcePlayer.position.x, sourcePlayer.position.y, sourcePlayer.position.z - 0.5, sourcePlayer.dimension, sourcePlayer.interior, sourcePlayer.rotation.z + 180}

        dbExec(connection, "INSERT INTO atms SET position=?", toJSON(position))

        dbQuery(
            function(query)
                local query, query_lines = dbPoll(query, 0)
                if query_lines > 0 then
                    Async:foreach(query, 
                        function(row)
                            loadATM(row)

                            local syntax = exports['cr_core']:getServerSyntax(nil, "success")
                            local blue = exports['cr_core']:getServerColor('yellow', true)
                            local white = "#ffffff"
                            outputChatBox(syntax .. "Sikeresen létrehoztál egy atm-t! (ID: "..blue..tonumber(row["id"])..white..")", sourcePlayer, 255, 255, 255, true)

                            local green = exports['cr_core']:getServerColor('yellow', true)
                            local white = "#ffffff"
                            local syntax = exports['cr_admin']:getAdminSyntax()
                            local aName = exports['cr_admin']:getAdminName(sourcePlayer, true)
                            exports['cr_core']:sendMessageToAdmin(sourcePlayer, syntax..green..aName..white.." létrehozott egy atm-t! (ID: "..blue..tonumber(row["id"])..white..")", 6)
                            exports['cr_logs']:addLog(sourcePlayer, "Bank", "addatm", syntax..aName.." létrehozott egy atm-t! (ID: "..tonumber(row["id"])..")")
                        end
                    )
                end
                outputDebugString("Loading atms finished. Loaded #"..query_lines.." atms!", 0, 255, 50, 255)
            end, 
        connection, "SELECT * FROM `atms` WHERE position=?", toJSON(position))

    end 
end 
addCommandHandler("createatm", createATMCmd)
addCommandHandler("addatm", createATMCmd)

function delATMCmd(sourcePlayer, cmd, id)
    if exports['cr_permission']:hasPermission(sourcePlayer, "delatm") then 
        if not tonumber(id) then 
            local syntax = exports["cr_core"]:getServerSyntax(nil, "warning")
            outputChatBox(syntax .. "/"..cmd.." [ATM ID]", sourcePlayer, 255, 255, 255, true)
            return 
        end 

        if idToAtm[tonumber(id)] then 
            local obj = idToAtm[tonumber(id)]
            atmCache[obj] = nil 
            idToAtm[tonumber(id)] = nil 
            obj:destroy()

            collectgarbage("collect")

            dbExec(connection, "DELETE FROM atms WHERE id=?", tonumber(id))

            local syntax = exports['cr_core']:getServerSyntax(nil, "success")
            local blue = exports['cr_core']:getServerColor('yellow', true)
            local white = "#ffffff"
            outputChatBox(syntax .. "Sikeresen törölt egy atm-t! (ID: "..blue..tonumber(id)..white..")", sourcePlayer, 255, 255, 255, true)

            local green = exports['cr_core']:getServerColor('yellow', true)
            local white = "#ffffff"
            local syntax = exports['cr_admin']:getAdminSyntax()
            local aName = exports['cr_admin']:getAdminName(sourcePlayer, true)
            exports['cr_core']:sendMessageToAdmin(sourcePlayer, syntax..green..aName..white.." törölt egy atm-t! (ID: "..blue..tonumber(id)..white..")", 6)
            exports['cr_logs']:addLog(sourcePlayer, "Bank", "delatm", syntax..aName.." törölt egy atm-t! (ID: "..tonumber(id)..")")
        else 
            local syntax = exports['cr_core']:getServerSyntax(nil, "error")
            outputChatBox(syntax .. "Nem található ilyen idjű atm!", sourcePlayer, 255, 255, 255, true)
        end 
    end 
end 
addCommandHandler("removeatm", delATMCmd)
addCommandHandler("delatm", delATMCmd)

function takeMoneyFromBankATM(sourcePlayer, id, clientMoney, moneyText)
    if isElement(sourcePlayer) and tonumber(id) and tonumber(clientMoney) and tonumber(moneyText) then 
        if bank_accounts[id] then 
            if bank_accounts[id][4] == clientMoney then 
                if bank_accounts[id][4] >= tonumber(moneyText) then 
                    local money = tonumber(math.ceil(tonumber(moneyText) - (tonumber(moneyText) * 0.1)))
                    bank_accounts[id][4] = bank_accounts[id][4] - tonumber(moneyText)
                    exports['cr_core']:giveMoney(sourcePlayer, money)
                    dbExec(connection, "UPDATE bankaccounts SET money=? WHERE ID=?", bank_accounts[id][4], id)

                    local blue = exports['cr_core']:getServerColor('yellow', true)
                    addBankLog(id, blue .. "[ATM]" .. color .. " Felvettél " .. blue .. moneyText .. " $" .. color .. "-ot/et")
                    getBankData(sourcePlayer, sourcePlayer, id, "all")

                    local aName = exports['cr_admin']:getAdminName(sourcePlayer)
                    exports['cr_logs']:addLog(sourcePlayer, "Bank", "takeMoneyFromBankATM", aName.." kivett ".. formatCardNumber(tostring(bank_accounts[id][3])) .. "-ról " .. moneyText .. "$-ot/et")
                end 
            end 
        end 
    end 
end 
addEvent("takeMoneyFromBank.ATM", true)
addEventHandler("takeMoneyFromBank.ATM", root, takeMoneyFromBankATM)

function addMoneyToBankATM(sourcePlayer, id, clientMoney, moneyText)
    if isElement(sourcePlayer) and tonumber(id) and tonumber(clientMoney) and tonumber(moneyText) then 
        if bank_accounts[id] then 
            if bank_accounts[id][4] == clientMoney then 
                if exports['cr_core']:takeMoney(sourcePlayer, tonumber(moneyText)) then 
                    local money = tonumber(math.ceil(tonumber(moneyText) - (tonumber(moneyText) * 0.1)))
                    bank_accounts[id][4] = bank_accounts[id][4] + tonumber(money)
                    dbExec(connection, "UPDATE bankaccounts SET money=? WHERE ID=?", bank_accounts[id][4], id)

                    local blue = exports['cr_core']:getServerColor('yellow', true)
                    addBankLog(id, blue .. "[ATM]" .. color .. " Beraktál " .. blue .. moneyText .. " $" .. color .. "-ot/et")
                    getBankData(sourcePlayer, sourcePlayer, id, "all")

                    local aName = exports['cr_admin']:getAdminName(sourcePlayer)
                    exports['cr_logs']:addLog(sourcePlayer, "Bank", "addMoneyToBankATM", aName.." berakott ".. formatCardNumber(tostring(bank_accounts[id][3])) .. "-ra " .. moneyText .. "$-ot/et")
                end 
            end 
        end 
    end 
end 
addEvent("addMoneyToBank.ATM", true)
addEventHandler("addMoneyToBank.ATM", root, addMoneyToBankATM)
