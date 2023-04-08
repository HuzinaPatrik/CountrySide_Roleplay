function createWalletPed(data)
    local walletPed = Ped(data.skinId, data.position)

    walletPed.interior = data.interior
    walletPed.dimension = data.dimension
    walletPed.rotation = data.rotation
    walletPed.frozen = true

    walletPed:setData("ped.name", data.name)
    walletPed:setData("ped.type", data.typ)
    walletPed:setData("ped >> wallet", true)
    walletPed:setData("char >> noDamage", true)
end

function onStart()
    for i = 1, #walletPedData do 
        local v = walletPedData[i]

        createWalletPed(v)
    end
end
addEventHandler("onResourceStart", resourceRoot, onStart)

function addToHistory(array, text)
    if type(array) == "table" and text then 
        local createdAt = os.time()

        table.insert(array, 1, {
            text = text,
            createdAt = createdAt
        })
    end

    return array
end

function updateWallet(phoneData, currentSlot, selectedService, amountToTake, plusMoney)
    if type(phoneData) == "table" and isElement(client) and currentSlot then
        if exports.cr_core:hasMoney(client, amountToTake) then 
            local yellowHex = exports.cr_core:getServerColor("yellow", true)

            local oldPhoneNumber = tonumber(phoneData.myCallNumber) or 0
            local oldService = phoneData.service
            local newService = availableServices[selectedService].name

            local currentTime = exports.cr_core:getTime()
            local newNumber = false

            local plusWalletText = tonumber(plusMoney) and tonumber(plusMoney) > 0 and white .. ", Plusz egyenleg: $" .. yellowHex .. plusMoney or ""
            local logMessage = currentTime .. "Szolgáltató váltás. Új szolgáltató: " .. yellowHex .. newService .. plusWalletText

            if oldService ~= newService or oldPhoneNumber <= 0 then 
                newNumber = exports.cr_phone:createNewPhone(newService, true)

                phoneData.contacts = {}
                phoneData.messages = {}
                phoneData.callHistory = {}

                phoneData.myCallNumber = newNumber
                phoneData.service = newService
                exports.cr_inventory:updateItemDetails(client, currentSlot, 1, {"value", newNumber}, true)
            end
            
            if plusMoney and tonumber(plusMoney) then 
                phoneData.wallet = phoneData.wallet + tonumber(plusMoney)

                if oldService == newService then 
                    logMessage = currentTime .. "Pénzfeltöltés (+ $" .. yellowHex .. plusMoney .. white .. ")"
                end
            end

            local updatedHistory = addToHistory(phoneData.simHistory, logMessage)
            phoneData.simHistory = updatedHistory

            exports.cr_inventory:updateItemDetails(client, currentSlot, 1, {"nbt", phoneData}, true)

            triggerLatentClientEvent(client, "phone.updatePhoneNbt", 50000, false, client, phoneData)

            if tonumber(amountToTake) then 
                exports.cr_core:takeMoney(client, amountToTake)
            end
        else 
            local syntax = exports.cr_core:getServerSyntax("Wallet", "error")
            outputChatBox(syntax .. "Nincs elég pénzed.", client, 255, 0, 0, true)
        end
    end
end
addEvent("wallet.updateWallet", true)
addEventHandler("wallet.updateWallet", root, updateWallet)