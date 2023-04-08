function generateRandomCardNumber(e)
    local num = math.random(1, 9)
    for i = 1, 11 do 
        num = tonumber(num .. math.random(1, 9))
    end 

    if bankCardNumberToID[num] then 
        return generateRandomCardNumber(e)
    else 
        if isElement(e) then 
            triggerLatentClientEvent(e, "resultCardNumber", 50000, false, e, e, num)
        else 
            return num 
        end 
    end 
end 
addEvent("generateRandomCardNumber", true)
addEventHandler("generateRandomCardNumber", root, generateRandomCardNumber)

function createNewCard(player, num, main)
    if isElement(player) and tonumber(num) then 
        if not tonumber(main) then 
            main = 0
        end 

        if bankCardNumberToID[num] then 
            num = generateRandomCardNumber()
        end 

        local time = exports['cr_core']:getTime()

        exports['cr_inventory']:giveItem(player, 97, num, 1)
        local player = player
        dbExec(connection, "INSERT INTO bankaccounts SET owner=?, cardnumber=?, main=?, money=?, createdate=?, pincode=?", player:getData("acc >> id"), tonumber(num), tonumber(main), 0, time, "1234")
        dbQuery(
            function(query)
                local query, query_lines = dbPoll(query, 0)
                if query_lines > 0 then
                    Async:foreach(query, 
                        function(row)
                            loadBankAccount(row)
                            local blue = exports['cr_core']:getServerColor("yellow", true)
                            addBankLog(row["id"], blue .. exports['cr_admin']:getAdminName(player) .. color .. " létrehozta a bankszámlát!")
                            getBankData(player, player, row["id"], "all")
                        end 
                    )
                end
                outputDebugString("Loading bankaccounts finished. Loaded #"..query_lines.." bankaccounts!", 0, 255, 50, 255)
            end, 
        connection, "SELECT * FROM `bankaccounts` WHERE owner=? AND cardnumber=? AND main=? AND money=? AND createdate=? AND pincode=?", player:getData("acc >> id"), tonumber(num), tonumber(main), 0, time, "1234")
    end 
end 
addEvent("createNewCard", true)
addEventHandler("createNewCard", root, createNewCard)