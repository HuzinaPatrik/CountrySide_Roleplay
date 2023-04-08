local maxSMS = 250
local phones = {}

function createNewPhone(service, updateNumber)
    if not updateNumber then 
        return 0
    else 
        local service = service or "Blue Wireless"
        local phoneNumber = shopTypes[service].numberPrefix .. math.random(100, 999) .. math.random(1000, 9999)

        return tonumber(phoneNumber)
    end
end

function addToCallHistory(array, targetNumber)
    if array and targetNumber  then 
        if not array[targetNumber] then 
            array[targetNumber] = {}
        end

        local count = tonumber(array[targetNumber].count or 0)
        local lastInteractAt = getRealTime().timestamp

        array[targetNumber] = {
            count = count + 1,
            lastInteractAt = lastInteractAt
        }

        return array
    end
end

function startCall(myCallNumber, targetNumber)
    if isElement(client) and myCallNumber and targetNumber then
        targetNumber = tonumber(targetNumber)

        local localData = exports.cr_inventory:hasPhone(myCallNumber)
        local targetData = exports.cr_inventory:hasPhone(targetNumber)

        if localData and targetData then 
            local localAccId, localNbt, localIType, localSlot = unpack(localData)
            local targetAccId, targetNbt, targetIType, targetSlot = unpack(targetData)
            local isOnline, targetElement = exports.cr_account:getAccountOnline(targetAccId)
            local targetService = targetNbt.service

            if targetElement == client then 
                local syntax = exports.cr_core:getServerSyntax("Phone", "error")

                outputChatBox(syntax .. "Saját magadat nem tudod felhívni.", client, 255, 0, 0, true)

                return
            end

            if targetNbt.service and targetNbt.service:len() <= 0 then 
                local syntax = exports.cr_core:getServerSyntax("Phone", "error")

                outputChatBox(syntax .. "Ezen a számon előfizető nem kapcsolható.", client, 255, 0, 0, true)
                return
            end

            if not isElement(targetElement) then 
                local syntax = exports.cr_core:getServerSyntax("Phone", "error")

                outputChatBox(syntax .. "Ezen a számon előfizető nem kapcsolható. (A játékos nem elérhető)", client, 255, 0, 0, true)
                return
            end

            if targetElement:getData("phone >> alreadyInCall") then 
                local syntax = exports.cr_core:getServerSyntax("Phone", "error")
                
                outputChatBox(syntax .. "Ez a szám foglalt.", client, 255, 0, 0, true)

                return
            end

            local updatedLocalCallHistory = addToCallHistory(localNbt.callHistory, targetNumber)
            local updatedTargetCallHistory = addToCallHistory(targetNbt.callHistory, myCallNumber)

            localNbt.callHistory = updatedLocalCallHistory
            targetNbt.callHistory = updatedTargetCallHistory

            savePhoneData(targetElement, targetNbt, targetSlot)
            savePhoneData(client, localNbt, localSlot)

            triggerClientEvent(client, "phone.updateCallHistory", client, myCallNumber, updatedLocalCallHistory)
            triggerClientEvent(targetElement, "phone.updateCallHistory", targetElement, targetNumber, updatedTargetCallHistory)

            triggerClientEvent(client, "phone.startCallOnClient", client, targetNumber, targetElement, targetService)
        else
            local syntax = exports.cr_core:getServerSyntax("Phone", "error")

            outputChatBox(syntax .. "Ezen a számon előfizető nem kapcsolható.", client, 255, 0, 0, true)
        end
    end
end
addEvent("phone.startCall", true)
addEventHandler("phone.startCall", root, startCall)

function startCallToTarget(myCallNumber, targetElement, targetNumber, sourceRingtone, sourceRingtoneVolume, phoneService)
    if isElement(client) then 
        if isElement(targetElement) then 
            local players = getElementsByType("player")

            triggerClientEvent(targetElement, "phone.ring", client, myCallNumber, client, targetNumber, phoneService)
            triggerClientEvent(players, "phone.managePhoneRingSound", targetElement, "init", sourceRingtone, sourceRingtoneVolume)

            client:setData("phone >> alreadyInCall", targetNumber)
            targetElement:setData("phone >> alreadyInCall", myCallNumber)
        else
            triggerClientEvent(client, "phone.denyCall", client, true)
        end
    end
end
addEvent("phone.startCallToTarget", true)
addEventHandler("phone.startCallToTarget", root, startCallToTarget)

function acceptCall(targetElement)
    if isElement(client) and isElement(targetElement) then 
        local players = getElementsByType("player")

        triggerClientEvent(targetElement, "phone.acceptCall", client)
        triggerClientEvent(players, "phone.managePhoneRingSound", client, "destroy")
    end
end
addEvent("phone.acceptCall", true)
addEventHandler("phone.acceptCall", root, acceptCall)

function denyCall(targetElement, spec)
    if isElement(client) and isElement(targetElement) then 
        local players = getElementsByType("player")
        local player = spec == "local" and client or targetElement

        triggerClientEvent(targetElement, "phone.denyCall", client)

        if spec ~= "noTrigger" then 
            triggerClientEvent(players, "phone.managePhoneRingSound", player, "destroy")
        end

        if client:getData("phone >> alreadyInCall") then 
            client:removeData("phone >> alreadyInCall")
        end

        if targetElement:getData("phone >> alreadyInCall") then 
            targetElement:removeData("phone >> alreadyInCall")
        end
    end
end
addEvent("phone.denyCall", true)
addEventHandler("phone.denyCall", root, denyCall)

function sendMessageInCall(myCallNumber, targetElement, text)
    if isElement(client) and myCallNumber and isElement(targetElement) and text then 
        triggerClientEvent(targetElement, "phone.receiveMessageInCall", client, myCallNumber, text)
    end
end
addEvent("phone.sendMessageInCall", true)
addEventHandler("phone.sendMessageInCall", root, sendMessageInCall)

function addSMS(array, text, targetNumber, sourceNumber)
    targetNumber = tonumber(targetNumber)
    sourceNumber = tonumber(sourceNumber)

    if not array[targetNumber] then 
        array[targetNumber] = {}
    end

    local lastIndex = #array[targetNumber]
    if lastIndex + 1 > maxSMS then 
        table.remove(array[targetNumber], lastIndex)
    end

    table.insert(array[targetNumber], {
        text = text,
        sourceNumber = sourceNumber,
        sendAt = getRealTime().timestamp
    })

    return array
end

function addNewSMS(myCallNumber, targetNumber, text)
    if isElement(client) and myCallNumber and targetNumber and text then 
        myCallNumber = tonumber(myCallNumber)
        targetNumber = tonumber(targetNumber)

        local localData = exports.cr_inventory:hasPhone(myCallNumber)
        local targetData = exports.cr_inventory:hasPhone(targetNumber)

        if localData and targetData then 
            local localAccId, localNbt, localIType, localSlot = unpack(localData)
            local targetAccId, targetNbt, targetIType, targetSlot = unpack(targetData)

            local isOnline, targetElement = exports.cr_account:getAccountOnline(targetAccId)

            if not isElement(targetElement) then 
                local syntax = exports.cr_core:getServerSyntax("Phone", "error")

                outputChatBox(syntax .. "A telefonszámon előfizető nem kapcsolható!", client, 255, 0, 0, true)
                return
            end

            if targetElement == client then 
                local syntax = exports.cr_core:getServerSyntax("Phone", "error")

                outputChatBox(syntax .. "Saját magadnak nem tudsz üzenetet küldeni!", client, 255, 0, 0, true)
                return
            end

            exports.cr_chat:createMessage(client, "küldött egy sms-t.", 1)
            exports.cr_chat:createMessage(targetElement, "kapott egy sms-t.", "do")

            local updatedLocalMessages = addSMS(localNbt.messages, text, targetNumber, myCallNumber)
            local updatedTargetMessages = addSMS(targetNbt.messages, text, myCallNumber, myCallNumber)

            localNbt.messages = updatedLocalMessages
            targetNbt.messages = updatedTargetMessages

            triggerClientEvent(client, "phone.updateMessages", client, myCallNumber, updatedLocalMessages)
            triggerClientEvent(targetElement, "phone.updateMessages", targetElement, targetNumber, updatedTargetMessages)

            savePhoneData(targetElement, targetNbt, targetSlot)
            savePhoneData(client, localNbt, localSlot)
        else
            local syntax = exports.cr_core:getServerSyntax("Phone", "error")

            outputChatBox(syntax .. "A telefonszámon előfizető nem kapcsolható!", client, 255, 0, 0, true)
        end
    end
end
addEvent("phone.addNewSMS", true)
addEventHandler("phone.addNewSMS", root, addNewSMS)

function onPlayerAdvertisement(text, myCallNumber, showMyNumber, players)
    if isElement(client) and type(players) == "table" then 
        local playerName = exports.cr_admin:getAdminName(client)

        triggerClientEvent(players, "phone.advertisement", client, playerName, text, myCallNumber, showMyNumber)
    end
end
addEvent("phone.advertisement", true)
addEventHandler("phone.advertisement", root, onPlayerAdvertisement)

function createPhoneObject()
    if isElement(client) then 
        local id = client:getData("acc >> id")

        if not phones[id] then 
            local object = Object(16184, 0, 0, 0, 0, 0, 0)
            object:setCollisionsEnabled(false)
            exports.cr_bone_attach:attachElementToBone(object, client, 11, 0, 0.02, 0.18, -5, 90, 0)

            phones[id] = object 
        end
    end
end
addEvent("phone.createPhoneObject", true)
addEventHandler("phone.createPhoneObject", root, createPhoneObject)

function destroyPhoneObject()
    if isElement(client) then 
        local id = client:getData("acc >> id")

        if phones[id] then 
            if isElement(phones[id]) then 
                exports.cr_bone_attach:detachElementFromBone(phones[id])

                phones[id]:destroy()
                phones[id] = nil 
                collectgarbage("collect")
            end
        end
    end
end
addEvent("phone.destroyPhoneObject", true)
addEventHandler("phone.destroyPhoneObject", root, destroyPhoneObject)

addEventHandler("onPlayerQuit", root,
    function(quitType)
        local id = source:getData("acc >> id")

        if id then 
            if phones[id] then 
                if isElement(phones[id]) then 
                    phones[id]:destroy()
                    phones[id] = nil 
                    collectgarbage("collect")
                end
            end
        end
    end
)

function savePhoneData(thePlayer, phoneData, currentSlot)
    thePlayer = thePlayer or client

    if isElement(thePlayer) and phoneData and currentSlot then 
        exports.cr_inventory:updateItemDetails(thePlayer, currentSlot, 1, {"nbt", phoneData}, true)
    end
end
addEvent("phone.savePhoneData", true)
addEventHandler("phone.savePhoneData", root, savePhoneData)