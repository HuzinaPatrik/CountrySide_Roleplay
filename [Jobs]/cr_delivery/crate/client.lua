local playerCache = {}

function carryRestriction(state)
    state = not state

    exports.cr_controls:toggleControl(jobData.carryControls, state, "instant")
end

function deliverPackage(element, orderId)
    if orderIdCache[orderId:lower()] then 
        local index = orderIdCache[orderId:lower()]

        if ordersInPDA[index] then 
            local data = ordersInPDA[index]

            if not data.delivered then 
                local currentText = 1
                local name = ""

                local conversationData = normalConversations.customer[currentText]
                local whoIsTalking = conversationData.whoIsTalking

                if whoIsTalking == "player" then 
                    name = exports.cr_admin:getAdminName(localPlayer)
                else
                    name = element:getData("ped.name")
                end

                local text = conversationData.text
                local fullText = name .. " mondja: " .. text

                outputChatBox(fullText, 255, 255, 255)

                setTimer(
                    function()
                        if normalConversations.customer[currentText + 1] then 
                            currentText = currentText + 1

                            local conversationData = normalConversations.customer[currentText]
                            local whoIsTalking = conversationData.whoIsTalking

                            if whoIsTalking == "player" then 
                                name = exports.cr_admin:getAdminName(localPlayer)
                            else
                                name = element:getData("ped.name")
                            end

                            local text = conversationData.text
                            local fullText = name .. " mondja: " .. text

                            outputChatBox(fullText, 255, 255, 255)

                            if currentText == 2 then 
                                setPedAnimation(element, "ped", "idle_chat", -1, true, true, false)
                            elseif currentText == 3 then 
                                givePackageToCustomer(element, index, orderId)
                                payOut()
                            end
                        end
                    end, 2000, 2
                )
            end
        end
    end
end

function givePackageToCustomer(element, index, orderId)
    setPedAnimation(element, "dealer", "dealer_deal", -1, true, true, false)
    localPlayer:setData("forceAnimation", {"dealer", "dealer_deal"})

    setTimer(
        function(element)
            setPedAnimation(element, false)
            localPlayer:setData("forceAnimation", {"", ""})
        end, 3300, 1, element
    )

    if isElement(createdMarkers[element]) then 
        createdMarkers[element]:destroy()
    end

    createdMarkers[element] = nil
    ordersInPDA[index].delivered = true
    isTalkingWithPed = false

    for k, v in pairs(orders) do 
        if v.orderId == orderId then 
            table.remove(orders, k)

            break
        end
    end

    local randomLocation = locationCache[orderId:lower()]

    if randomLocation and createdLocations[randomLocation] then 
        createdLocations[randomLocation] = nil
    end

    locationCache[orderId:lower()] = nil

    localPlayer:setData("delivery >> crateInHand", nil)
    carryRestriction(false)

    exports.cr_radar:destroyStayBlip("#" .. orderId .. " - " .. element:getData("ped.name"))

    if #orders <= 0 then 
        local syntax = exports.cr_core:getServerSyntax("Delivery", "info")

        isVehicleFilledUp = false
        resetPDA()

        outputChatBox(syntax .. "Végeztél a csomagok kiszállításával, új csomagokért állj bele az árufeltöltő jelölésbe.", 255, 0, 0, true)
    end

    collectgarbage("collect")
end

local lastPayOutTick = -10000

function payOut()
    if exports.cr_network:getNetworkStatus() then 
        return
    end

    local nowTick = getTickCount()
    local count = 10

    if nowTick <= lastPayOutTick + count * 1000 then
        return
    end

    lastPayOutTick = getTickCount()

    local salaryMultiplier = exports.cr_salary:getMultiplier()
    local money = math.random(jobData.minMoney, jobData.maxMoney) * salaryMultiplier

    local syntax = exports.cr_core:getServerSyntax("Delivery", "success")
    local hexColor = exports.cr_core:getServerColor("yellow", true)
    
    outputChatBox(syntax .. "Leszállítottad a küldeményt. A fizetésed: " .. hexColor .. "$" .. money .. white .. ".", 255, 0, 0, true)

    exports.cr_core:giveMoney(localPlayer, money)
end