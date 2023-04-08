connection = exports['cr_mysql']:getConnection(getThisResource())
addEventHandler("onResourceStart", root, 
    function(startedRes)
        if getResourceName(startedRes) == "cr_mysql" then
            connection = exports['cr_mysql']:getConnection(getThisResource())
            restartResource(getThisResource())
        end
    end
)

bank_accounts = {}
player_bank_accounts = {}
bankCardNumberToID = {}

function getBankData(sendTo, sourcePlayer, id, typ)
    if typ == "all" then
        if bank_accounts[id] then 
            triggerLatentClientEvent(sendTo, "returnBankData", 50000, false, sourcePlayer, sendTo, id, bank_accounts[id], "all")
        end
    elseif typ == "request" then
        if bank_accounts[id] then 
            triggerLatentClientEvent(sendTo, "returnBankData", 50000, false, sourcePlayer, sendTo, id, bank_accounts[id], "all")
        end
    elseif typ == "clear" then
        triggerLatentClientEvent(sendTo, "returnBankData", 50000, false, sourcePlayer, sendTo, id, nil, "clear")
    end
end
addEvent("getBankData", true)
addEventHandler("getBankData", root, getBankData)

function loadBankAccount(row)
    local id = tonumber(row["id"])
    local owner = tonumber(row["owner"])
    local cardnumber = tonumber(row["cardnumber"])
    local money = tonumber(row["money"])
    local main = tonumber(row["main"])
    local createdate = tostring(row["createdate"])
    local pincode = tonumber(row["pincode"])
    local logs = fromJSON(tostring(row["logs"]))
    local money_take_logs = fromJSON(tostring(row["money_take_logs"]))
    local money_add_logs = fromJSON(tostring(row["money_add_logs"]))
    local password_change_logs = fromJSON(tostring(row["password_change_logs"]))

    bank_accounts[id] = {id, owner, cardnumber, money, main, pincode, logs, money_take_logs, money_add_logs, password_change_logs}

    if not player_bank_accounts[owner] then 
        player_bank_accounts[owner] = {}
    end 

    if main == 1 then 
        table.insert(player_bank_accounts[owner], 1, id)
    else 
        table.insert(player_bank_accounts[owner], #player_bank_accounts[owner], id)
    end 
    
    bankCardNumberToID[cardnumber] = id
end 

function loadBankAccounts()
    dbQuery(
        function(query)
            local query, query_lines = dbPoll(query, 0)
            if query_lines > 0 then
                Async:foreach(query, 
                    loadBankAccount
                )
            end
            outputDebugString("Loading bankaccounts finished. Loaded #"..query_lines.." bankaccounts!", 0, 255, 50, 255)
        end, 
    connection, "SELECT * FROM `bankaccounts`")
end
addEventHandler("onResourceStart", resourceRoot, loadBankAccounts)

function checkPlayerBankAccounts(e)
    if isElement(e) then
        if e:getData("acc >> id") then
            if player_bank_accounts[e:getData("acc >> id")] then
                for k,v in pairs(player_bank_accounts[e:getData("acc >> id")]) do 
                    getBankData(e, e, v, "all")
                end 
            end
        end
    end
end
addEvent("checkPlayerBankAccounts", true)
addEventHandler("checkPlayerBankAccounts", root, checkPlayerBankAccounts)

function transferMoney(sourcePlayer, id, clientMoney, cardNumber, subjectText, messageText, moneyText)
    if isElement(sourcePlayer) and tonumber(id) and tonumber(clientMoney) and tonumber(cardNumber) and subjectText and messageText and tonumber(moneyText) then 
        if bank_accounts[id] then 
            if bank_accounts[id][4] == clientMoney then 
                if bank_accounts[id][4] >= tonumber(moneyText) then 
                    local targetID = bankCardNumberToID[tonumber(cardNumber)] 
                    if targetID and bank_accounts[targetID] then 
                        local money = tonumber(math.ceil(tonumber(moneyText) - (tonumber(moneyText) * 0.1)))
                        bank_accounts[id][4] = bank_accounts[id][4] - tonumber(moneyText)
                        bank_accounts[targetID][4] = bank_accounts[targetID][4] + tonumber(money)
                        dbExec(connection, "UPDATE bankaccounts SET money=? WHERE ID=?", bank_accounts[id][4], id)
                        dbExec(connection, "UPDATE bankaccounts SET money=? WHERE ID=?", bank_accounts[targetID][4], targetID)

                        local blue = exports['cr_core']:getServerColor('yellow', true)
                        local green = exports['cr_core']:getServerColor('green', true)

                        addBankLog(id, {color .. "Átutaltál "..green.."$ "..moneyText..color.."-t "..blue..formatCardNumber(tostring(cardNumber))..color.." számlára!", blue .. "Tárgy: " .. color .. subjectText .. "\n" .. blue .. "Üzenet: " .. color .. messageText})
                        addBankLog(targetID, {color .. "Érkezett "..green.."$ "..money..color.." a(z) "..blue..formatCardNumber(tostring(bank_accounts[id][3]))..color.." számláról!", blue .. "Tárgy: " .. color .. subjectText .. "\n" .. blue .. "Üzenet: " .. color .. messageText})
                        getBankData(sourcePlayer, sourcePlayer, id, "all")

                        local ownerID = bank_accounts[targetID][2]
                        local online, playerElement = exports['cr_account']:getAccountOnline(ownerID)
                        if online then 
                            getBankData(playerElement, playerElement, targetID, "all")
                        end 

                        exports['cr_infobox']:addBox(sourcePlayer, "success", "Sikeres utalás!")

                        local aName = exports['cr_admin']:getAdminName(sourcePlayer)
                        exports['cr_logs']:addLog(sourcePlayer, "Bank", "transferMoney", aName.." utalt "..formatCardNumber(tostring(bank_accounts[id][3])).."-ról "..formatCardNumber(tostring(cardNumber)).."-ra $ ".. moneyText .. " ot/et")
                    else 
                        exports['cr_infobox']:addBox(sourcePlayer, "error", "Nem található ilyen számlaszám!")
                    end 
                end 
            end 
        end 
    end 
end 
addEvent("transferMoney", true)
addEventHandler("transferMoney", root, transferMoney)

function takeMoneyFromBank(sourcePlayer, id, clientMoney, moneyText)
    if isElement(sourcePlayer) and tonumber(id) and tonumber(clientMoney) and tonumber(moneyText) then 
        if bank_accounts[id] then 
            if bank_accounts[id][4] == clientMoney then 
                if bank_accounts[id][4] >= tonumber(moneyText) then 
                    local money = tonumber(math.ceil(tonumber(moneyText) - (tonumber(moneyText) * 0.05)))
                    bank_accounts[id][4] = bank_accounts[id][4] - tonumber(moneyText)
                    exports['cr_core']:giveMoney(sourcePlayer, money)
                    dbExec(connection, "UPDATE bankaccounts SET money=? WHERE ID=?", bank_accounts[id][4], id)

                    local blue = exports['cr_core']:getServerColor('yellow', true)
                    local green = exports['cr_core']:getServerColor('green', true)
                    addBankMoneyTakeLog(id, color .. "Felvettél " .. green .. "$ ".. moneyText .. color .. " ot/et")
                    getBankData(sourcePlayer, sourcePlayer, id, "all")

                    local aName = exports['cr_admin']:getAdminName(sourcePlayer)
                    exports['cr_logs']:addLog(sourcePlayer, "Bank", "takeMoneyFromBank", aName .. " kivett ".. formatCardNumber(tostring(bank_accounts[id][3])) .. "-ról $ " .. moneyText .. " ot/et")
                end 
            end 
        end 
    end 
end 
addEvent("takeMoneyFromBank", true)
addEventHandler("takeMoneyFromBank", root, takeMoneyFromBank)

function addMoneyToBank(sourcePlayer, id, clientMoney, moneyText)
    if isElement(sourcePlayer) and tonumber(id) and tonumber(clientMoney) and tonumber(moneyText) then 
        if bank_accounts[id] then 
            if bank_accounts[id][4] == clientMoney then 
                if exports['cr_core']:takeMoney(sourcePlayer, tonumber(moneyText)) then 
                    local money = tonumber(math.ceil(tonumber(moneyText) - (tonumber(moneyText) * 0.05)))
                    bank_accounts[id][4] = bank_accounts[id][4] + tonumber(money)
                    dbExec(connection, "UPDATE bankaccounts SET money=? WHERE ID=?", bank_accounts[id][4], id)

                    local blue = exports['cr_core']:getServerColor('yellow', true)
                    local green = exports['cr_core']:getServerColor('green', true)
                    addBankMoneyAddLog(id, color .. "Beraktál " .. green .. "$ " .. moneyText .. color .. " ot/et")
                    getBankData(sourcePlayer, sourcePlayer, id, "all")

                    local aName = exports['cr_admin']:getAdminName(sourcePlayer)
                    exports['cr_logs']:addLog(sourcePlayer, "Bank", "addMoneyToBank", aName.." berakott ".. formatCardNumber(tostring(bank_accounts[id][3])) .. "-ra $ " .. moneyText .. " ot/et")
                end 
            end 
        end 
    end 
end 
addEvent("addMoneyToBank", true)
addEventHandler("addMoneyToBank", root, addMoneyToBank)

function changeBankAccountPassword(sourcePlayer, id, clientPassword, passwordText)
    if isElement(sourcePlayer) and tonumber(id) and tonumber(clientPassword) and tonumber(passwordText) then 
        if bank_accounts[id] then 
            if bank_accounts[id][6] == tonumber(clientPassword) then 
                if tonumber(clientPassword) ~= tonumber(passwordText) then 
                    local oldPassword = tonumber(clientPassword)
                    local newPassword = tonumber(passwordText)
                    bank_accounts[id][6] = newPassword
                    dbExec(connection, "UPDATE bankaccounts SET pincode=? WHERE ID=?", bank_accounts[id][6], id)

                    local blue = exports['cr_core']:getServerColor('yellow', true)
                    addBankPasswordChangeLog(id, blue .. oldPassword .. color .. "-ról " .. blue .. newPassword .. color .. "-ra/re!")
                    getBankData(sourcePlayer, sourcePlayer, id, "all")

                    exports['cr_infobox']:addBox(sourcePlayer, "success", "Sikeres jelszóváltoztatás!")
                end 
            end 
        end 
    end 
end     
addEvent("changeBankAccountPassword", true)
addEventHandler("changeBankAccountPassword", root, changeBankAccountPassword)

function setBankAccountMain(sourcePlayer, id, clientMainState)
    if isElement(sourcePlayer) and tonumber(id) and tonumber(clientMainState) then 
        if bank_accounts[id] then 
            if bank_accounts[id][5] == tonumber(clientMainState) then 
                bank_accounts[id][5] = 1
                dbExec(connection, "UPDATE bankaccounts SET main=? WHERE ID=?", bank_accounts[id][5], id)

                local ownerID = bank_accounts[id][2]
                table.sort(player_bank_accounts[ownerID], 
                    function(a, b)
                        if bank_accounts[a][5] > bank_accounts[b][5] then 
                            return bank_accounts[a][5] > bank_accounts[b][5]
                        end 
                    end
                )

                getBankData(sourcePlayer, sourcePlayer, id, "all")

                for k,v in pairs(player_bank_accounts[ownerID]) do 
                    if v ~= id then 
                        bank_accounts[v][5] = 0
                        getBankData(sourcePlayer, sourcePlayer, v, "all")
                        dbExec(connection, "UPDATE bankaccounts SET main=? WHERE ID=?", bank_accounts[v][5], v)
                    end 
                end 

                exports['cr_infobox']:addBox(sourcePlayer, "success", "Sikeresen elsődleges számlává tetted a számlát!")
            end 
        end 
    end 
end 
addEvent("setBankAccountMain", true)
addEventHandler("setBankAccountMain", root, setBankAccountMain)

function deleteBankAccount(sourcePlayer, id)
    if isElement(sourcePlayer) and tonumber(id) then 
        if bank_accounts[id] then 
            if bank_accounts[id][4] >= 0 then 
                local ownerID = bank_accounts[id][2]
                if #player_bank_accounts[ownerID] > 1 then 
                    for k,v in pairs(player_bank_accounts[ownerID]) do 
                        if v == id then 
                            table.remove(player_bank_accounts[ownerID], k)
                            break 
                        end 
                    end 

                    local accID = player_bank_accounts[ownerID][1]
                    if bank_accounts[accID] then 
                        bank_accounts[accID][5] = 1
                        dbExec(connection, "UPDATE bankaccounts SET main=? WHERE ID=?", bank_accounts[accID][5], accID)
                        getBankData(sourcePlayer, sourcePlayer, accID, "all")
                    end 
                else 
                    player_bank_accounts[ownerID] = nil 
                end 

                bankCardNumberToID[bank_accounts[id][3]] = nil 
                bank_accounts[id] = nil 
                collectgarbage("collect")

                dbExec(connection, "DELETE FROM bankaccounts WHERE ID=?", id)

                exports['cr_infobox']:addBox(sourcePlayer, "success", "Sikeresen kitörölted a bankszámlát!")
            end 
        end
    end 
end 
addEvent("deleteBankAccount", true)
addEventHandler("deleteBankAccount", root, deleteBankAccount)

local maxLogs = 250
function addBankLog(id, text)
    if bank_accounts[id] then 
        local logs = bank_accounts[id][7]
        local time = exports['cr_core']:getTime() .. " "
        if #logs + 1 > maxLogs then 
            table.remove(logs, #logs)
        end 

        if type(text) == "table" then 
            text[1] = time .. text[1]
        else 
            text = time .. text
        end 

        table.insert(logs, 1, text) 

        dbExec(connection, "UPDATE bankaccounts SET logs=? WHERE ID=?", toJSON(bank_accounts[id][7]), id)
    end 
end 
addEvent("addBankLog", true)
addEventHandler("addBankLog", root, addBankLog)

local maxLogs = 100
function addBankMoneyTakeLog(id, text)
    if bank_accounts[id] then 
        local logs = bank_accounts[id][8]
        local time = exports['cr_core']:getTime() .. " "
        if #logs + 1 > maxLogs then 
            table.remove(logs, #logs)
        end 

        if type(text) == "table" then 
            text[1] = time .. text[1]
        else 
            text = time .. text
        end 

        table.insert(logs, 1, text) 

        dbExec(connection, "UPDATE bankaccounts SET money_take_logs=? WHERE ID=?", toJSON(bank_accounts[id][8]), id)
    end 
end 
addEvent("addBankMoneyTakeLog", true)
addEventHandler("addBankMoneyTakeLog", root, addBankMoneyTakeLog)

local maxLogs = 100
function addBankMoneyAddLog(id, text)
    if bank_accounts[id] then 
        local logs = bank_accounts[id][9]
        local time = exports['cr_core']:getTime() .. " "
        if #logs + 1 > maxLogs then 
            table.remove(logs, #logs)
        end 

        if type(text) == "table" then 
            text[1] = time .. text[1]
        else 
            text = time .. text
        end 

        table.insert(logs, 1, text) 

        dbExec(connection, "UPDATE bankaccounts SET money_add_logs=? WHERE ID=?", toJSON(bank_accounts[id][9]), id)
    end 
end 
addEvent("addBankMoneyAddLog", true)
addEventHandler("addBankMoneyAddLog", root, addBankMoneyAddLog)

local maxLogs = 100
function addBankPasswordChangeLog(id, text)
    if bank_accounts[id] then 
        local logs = bank_accounts[id][10]
        local time = exports['cr_core']:getTime() .. " "
        if #logs + 1 > maxLogs then 
            table.remove(logs, #logs)
        end 

        if type(text) == "table" then 
            text[1] = time .. text[1]
        else 
            text = time .. text
        end 

        table.insert(logs, 1, text) 

        dbExec(connection, "UPDATE bankaccounts SET password_change_logs=? WHERE ID=?", toJSON(bank_accounts[id][10]), id)
    end 
end 
addEvent("addBankPasswordChangeLog", true)
addEventHandler("addBankPasswordChangeLog", root, addBankPasswordChangeLog)

--
function getPlayerBankAccounts(e)
    local player_bank_accounts = {} 
    for k,v in pairs(bank_accounts) do 
        if v[2] == e:getData("acc >> id") then 
            if v[5] == 1 then 
                table.insert(player_bank_accounts, 1, v)
            else 
                table.insert(player_bank_accounts, #player_bank_accounts, v)
            end 
        end 
    end 

    return player_bank_accounts
end 

function getPlayerMainAccount(e)
    for k,v in pairs(bank_accounts) do 
        if v[2] == e:getData("acc >> id") then 
            if v[5] == 1 then 
                return k
            end 
        end 
    end 

    return false
end 

function getBankAccountMoney(sourcePlayer, id)
    if not tonumber(id) then 
        id = getPlayerMainAccount(sourcePlayer)
    end 

    if tonumber(id) then 
        if bankCardNumberToID[id] then 
            id = bankCardNumberToID[id]
        end 

        if bank_accounts[id] then 
            return bank_accounts[id][4]
        end
    end 

    return -1 
end 

function hasMoney(sourcePlayer, id, money)
    if not tonumber(id) then 
        id = getPlayerMainAccount(sourcePlayer)
    end 

    if tonumber(id) and tonumber(money) then 
        if bankCardNumberToID[id] then 
            id = bankCardNumberToID[id]
        end 

        if bank_accounts[id] then 
            if bank_accounts[id][4] >= money then 
                return true 
            end 
        end
    end 

    return false 
end 

function takeMoney(sourcePlayer, id, money)
    if not tonumber(id) then 
        id = getPlayerMainAccount(sourcePlayer)
    end 

    if tonumber(id) and tonumber(money) then 
        if bankCardNumberToID[id] then 
            id = bankCardNumberToID[id]
        end 

        if bank_accounts[id] then 
            bank_accounts[id][4] = bank_accounts[id][4] - tonumber(money)
            dbExec(connection, "UPDATE bankaccounts SET money=? WHERE ID=?", bank_accounts[id][4], id)

            local blue = exports['cr_core']:getServerColor('yellow', true)
            local green = exports['cr_core']:getServerColor('green', true)
            addBankLog(id, blue .. "[Tranzakció] " .. color .. "Levonásra került " .. green .."$ " .. money)
            getBankData(sourcePlayer, sourcePlayer, id, "all")

            exports['cr_logs']:addLog(sourcePlayer, "Bank", "takeMoney", formatCardNumber(tostring(bank_accounts[id][3])) .. "-ról levonásra került $ " .. money)
        end 
    end 
end 
addEvent("bank >> takeMoney", true)
addEventHandler("bank >> takeMoney", root, 
    function(sourcePlayer, id, clientMoney, money)
        if tonumber(id) and tonumber(clientMoney) and tonumber(money) then 
            if bank_accounts[id] then 
                if bank_accounts[id][4] == clientMoney then 
                    if bank_accounts[id][4] >= tonumber(money) then 
                        takeMoney(sourcePlayer, id, money)
                    end 
                end 
            end 
        end 
    end 
)

function giveMoney(sourcePlayer, id, money)
    if not tonumber(id) then 
        id = getPlayerMainAccount(sourcePlayer)
    end 

    if tonumber(id) and tonumber(money) then 
        if bankCardNumberToID[id] then 
            id = bankCardNumberToID[id]
        end 

        if bank_accounts[id] then 
            bank_accounts[id][4] = bank_accounts[id][4] + tonumber(money)
            dbExec(connection, "UPDATE bankaccounts SET money=? WHERE ID=?", bank_accounts[id][4], id)

            local blue = exports['cr_core']:getServerColor('yellow', true)
            local green = exports['cr_core']:getServerColor('green', true)
            addBankLog(id, blue .. "[Tranzakció] " .. color .. "Hozzáadásra került " .. green .. "$ " .. money)
            getBankData(sourcePlayer, sourcePlayer, id, "all")

            exports['cr_logs']:addLog(sourcePlayer, "Bank", "giveMoney", formatCardNumber(tostring(bank_accounts[id][3])) .. "-ra hozzáadásra került $ " .. money)
        end 
    end 
end 
addEvent("bank >> giveMoney", true)
addEventHandler("bank >> giveMoney", root, 
    function(sourcePlayer, id, clientMoney, money)
        if tonumber(id) and tonumber(clientMoney) and tonumber(money) then 
            if bank_accounts[id] then 
                if bank_accounts[id][4] == clientMoney then 
                    giveMoney(sourcePlayer, id, money)
                end 
            end 
        end 
    end 
)


--[[
    Commands:
]]

function checkBankMoney(sourcePlayer, cmd, target)
    if exports['cr_permission']:hasPermission(sourcePlayer, 'checkbankmoney') then
        if not target then 
            local syntax = exports['cr_core']:getServerSyntax('Bank', 'warning')
            outputChatBox(syntax .. '/'..cmd..' [Target]', sourcePlayer, 255, 255, 255, true) 
            return 
        end 

        local target = exports['cr_core']:findPlayer(sourcePlayer, target)

        if target and isElement(target) then 
            local bankAccounts = getPlayerBankAccounts(target)
            if #bankAccounts > 0 then 
                local syntax = exports['cr_core']:getServerSyntax('Bank', 'info')
                local green = exports['cr_core']:getServerColor('yellow', true)
                for k,v in pairs(bankAccounts) do 
                    local id = v[1]
                    local cardNumber = v[3]
                    local money = v[4]

                    outputChatBox(syntax .. 'ID: '..green..id..'#ffffff, Azonosító: '..green..cardNumber..'#ffffff, Vagyon: '..green..money..'#ffffff!', sourcePlayer, 255, 255, 255, true) 
                end 
            else
                local syntax = exports['cr_core']:getServerSyntax('Bank', 'error')
                outputChatBox(syntax .. 'Nem található bankszámla!', sourcePlayer, 255, 255, 255, true) 
            end 
        else 
            local syntax = exports['cr_core']:getServerSyntax('Bank', 'error')
            outputChatBox(syntax .. 'Nem található a kiválasztott player!', sourcePlayer, 255, 255, 255, true) 
        end 
    end 
end 
addCommandHandler('checkbankmoney', checkBankMoney)