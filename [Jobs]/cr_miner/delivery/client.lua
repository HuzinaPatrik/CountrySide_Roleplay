local rocksToDeliver = 0

function deliverRocks(count)
    if count then
        local vehicle = localPlayer.vehicle

        localPlayer:setData("handbrakeDisabled", true)

        rocksToDeliver = count
        exports.cr_dx:startProgressBar("miner >> deliverRocks", {
            {"Várd meg, amíg lepakolják a köveket a járművedről.", jobData.deliverTime}
        })

        vehicle.frozen = true
        exports.cr_controls:toggleControl("enter_exit", false, "high")

        removeEventHandler("ProgressBarEnd", localPlayer, onProgressBarEnd)
        addEventHandler("ProgressBarEnd", localPlayer, onProgressBarEnd)
    else
        localPlayer.frozen = true

        payOut(1)
        triggerLatentServerEvent("onClientDeliverRock", 5000, false, localPlayer)
    end
end

function onProgressBarEnd(id)
    if id == "miner >> deliverRocks" then 
        payOut(rocksToDeliver)
    end
end

local lastPayOutTick = -10000

function payOut(rocks)
    if exports.cr_network:getNetworkStatus() then 
        return
    end

    local vehicle = localPlayer.vehicle

    localPlayer:setData("handbrakeDisabled", false)

    if vehicle then 
        vehicle.frozen = false
        vehicle:setData("miner >> rocksInVeh", nil)
    end
    
    exports.cr_controls:toggleControl("enter_exit", true, "high")

    local nowTick = getTickCount()
    local count = 10

    if nowTick <= lastPayOutTick + count * 1000 then
        return
    end

    lastPayOutTick = getTickCount()

    local salaryMultiplier = exports.cr_salary:getMultiplier()
    local randomMoney = (jobData.payment * rocks) * salaryMultiplier --(math.random(jobData.minPayment, jobData.maxPayment) * rocks) * salaryMultiplier

    local syntax = exports.cr_core:getServerSyntax("Miner", "success")
    local hexColor = exports.cr_core:getServerColor("yellow", true)

    outputChatBox(syntax .. "Sikeresen lepakolták a köveket a járművedről.", 255, 0, 0, true)
    outputChatBox(syntax .. "Fizettséged: " .. hexColor .. "$" .. randomMoney, 255, 0, 0, true)

    removeEventHandler("ProgressBarEnd", localPlayer, onProgressBarEnd)

    rocksToDeliver = 0
    exports.cr_core:giveMoney(localPlayer, randomMoney)
    -- triggerLatentServerEvent("onClientDeliverRocks", 5000, false, localPlayer)
end