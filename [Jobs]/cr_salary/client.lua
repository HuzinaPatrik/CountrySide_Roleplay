local multiplier = 0

addEvent("onClientSalaryMultiplierChange", true)

function onClientStart()
    setTimer(triggerServerEvent, 1500, 1, "onMultiplierRequest", localPlayer)
end
addEventHandler("onClientResourceStart", resourceRoot, onClientStart)

function onMultiplierRequest(num)
    multiplier = num

    triggerEvent("onClientSalaryMultiplierChange", localPlayer, multiplier)
end
addEvent("onMultiplierRequest", true)
addEventHandler("onMultiplierRequest", root, onMultiplierRequest)

function getMultiplier()
    return multiplier
end