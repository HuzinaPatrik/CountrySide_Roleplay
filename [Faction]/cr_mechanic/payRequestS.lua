function requestPay(target, price)
    if isElement(client) and isElement(target) and price then 
        local syntax = exports.cr_core:getServerSyntax("Mechanic", "success")
        local syntax2 = exports.cr_core:getServerSyntax("Mechanic", "info")

        local hexColor = exports.cr_core:getServerColor("yellow", true)
        local hexColor2 = exports.cr_core:getServerColor("green", true)
        local hexColor3 = exports.cr_core:getServerColor("red", true)

        local localName = exports.cr_admin:getAdminName(client)
        local targetName = exports.cr_admin:getAdminName(target)

        outputChatBox(syntax .. "Sikeresen elküldted a szerelési kérelmedet " .. hexColor .. targetName .. white .. " játékosnak.", client, 255, 0, 0, true)
        outputChatBox(syntax2 .. hexColor .. localName .. white .. " elküldött neked egy szerelési kérelmet. A szerelés ára: " .. hexColor2 .. "$" .. price, target, 255, 0, 0, true)

        outputChatBox(syntax2 .. "Az elfogadáshoz használd az " .. hexColor2 .. "/acceptfix " .. white .. "parancsot.", target, 255, 0, 0, true)
        outputChatBox(syntax2 .. "Az elutasításhoz használd a " .. hexColor3 .. "/declinefix " .. white .. "parancsot.", target, 255, 0, 0, true)

        target:setData("mechanic.pendingRequest", {sourcePlayer = client, price = price, state = 'unaccepted'})
    end
end
addEvent("mechanic.requestPay", true)
addEventHandler("mechanic.requestPay", root, requestPay)

function acceptFix()
    if isElement(client) then 
        local data = client:getData("mechanic.pendingRequest")
        local sourcePlayer = data.sourcePlayer
        local price = data.price
        local state = data.state

        if state == 'unaccepted' then
            if not exports.cr_core:hasMoney(client, price) then
                local syntax = exports.cr_core:getServerSyntax("Mechanic", "error")
                local hexColor = exports.cr_core:getServerColor("green", true)

                outputChatBox(syntax .. "Nincs elég pénzed. " .. hexColor .. "($" .. price .. ")", client, 255, 0, 0, true)
                return
            end

            client:setData("mechanic.pendingRequest", {sourcePlayer = sourcePlayer, price = price, state = 'accepted'})

            local syntax = exports.cr_core:getServerSyntax("Mechanic", "success")
            local syntax2 = exports.cr_core:getServerSyntax("Mechanic", "info")

            local hexColor = exports.cr_core:getServerColor("yellow", true)
            local localName = exports.cr_admin:getAdminName(client)

            outputChatBox(syntax .. "Sikeresen elfogadtad a szerelési kérelmet. A kifizetéshez használd a " .. hexColor .. "/payfix " .. white .. "parancsot.", client, 255, 0, 0, true)

            if isElement(sourcePlayer) then 
                outputChatBox(syntax2 .. hexColor .. localName .. white .. " elfogadta a szerelési kérelmet.", sourcePlayer, 255, 0, 0, true)
                sourcePlayer:setData("mechanic.canRepair", true)
            end
        end

        -- exports.cr_core:takeMoney(client, price)
        -- client:removeData("mechanic.pendingRequest")
    end
end
addEvent("mechanic.acceptFix", true)
addEventHandler("mechanic.acceptFix", root, acceptFix)

function declineFix()
    if isElement(client) then 
        local data = client:getData("mechanic.pendingRequest") or {}
        local sourcePlayer = data.sourcePlayer

        local syntax = exports.cr_core:getServerSyntax("Mechanic", "success")
        local syntax2 = exports.cr_core:getServerSyntax("Mechanic", "info")

        local hexColor = exports.cr_core:getServerColor("yellow", true)
        local localName = exports.cr_admin:getAdminName(client)

        outputChatBox(syntax .. "Sikeresen elutasítottad a szerelési kérelmet.", client, 255, 0, 0, true)

        if isElement(sourcePlayer) then 
            outputChatBox(syntax2 .. hexColor .. localName .. white .. " elutasította a szerelési kérelmet.", sourcePlayer, 255, 0, 0, true)
        end

        client:removeData("mechanic.pendingRequest")
    end
end
addEvent("mechanic.declineFix", true)
addEventHandler("mechanic.declineFix", root, declineFix)

function payFix()
    if isElement(client) then 
        local data = client:getData("mechanic.pendingRequest") or {}
        local sourcePlayer = data.sourcePlayer

        if not isElement(sourcePlayer) then 
            local syntax = exports.cr_core:getServerSyntax("Mechanic", "error")

            outputChatBox(syntax .. "A szerelő lecsatlakozott a szerverről, ezért a szerelési kérelem abbamaradt.", client, 255, 0, 0, true)
            client:removeData("mechanic.pendingRequest")
            return
        end

        local price = data.price

        if not exports.cr_core:hasMoney(client, price) then 
            local syntax = exports.cr_core:getServerSyntax("Mechanic", "error")
            local hexColor = exports.cr_core:getServerColor("green", true)

            outputChatBox(syntax .. "Nincs elég pénzed. " .. hexColor .. "($" .. price .. ")", client, 255, 0, 0, true)
            return
        end

        exports.cr_core:takeMoney(client, price)
        exports.cr_core:giveMoney(sourcePlayer, price)

        local syntax = exports.cr_core:getServerSyntax("Mechanic", "success")
        local syntax2 = exports.cr_core:getServerSyntax("Mechanic", "info")

        local hexColor = exports.cr_core:getServerColor("yellow", true)
        local localName = exports.cr_admin:getAdminName(client)

        outputChatBox(syntax .. "Sikeresen kifizetted a szerelést.", client, 255, 0, 0, true)
        outputChatBox(syntax2 .. hexColor .. localName .. white .. " kifizette a szerelést. Ár: " .. hexColor .. "$" .. price, sourcePlayer, 255, 0, 0, true)

        client:removeData("mechanic.pendingRequest")
        sourcePlayer:removeData("mechanic.canRepair")
    end
end
addEvent("mechanic.payFix", true)
addEventHandler("mechanic.payFix", root, payFix)