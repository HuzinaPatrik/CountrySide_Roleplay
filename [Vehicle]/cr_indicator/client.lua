local lastInteract = 0

local deniedVehicleTypes = {
    BMX = true,
    Bike = true
}

function toggleIndicator(button, state)
    local vehicle = localPlayer.vehicle

    if vehicle then 
        local vehicleSeat = localPlayer.vehicleSeat

        if vehicleSeat == 0 and not isCursorShowing() and not localPlayer:getData("keysDenied") and not deniedVehicleTypes[getVehicleType(vehicle)] then 
            local indicatorSideData = indicatorSides[button]

            local indicatorSide = indicatorSideData.name
            local indicatorData = indicatorSideData.data

            if lastInteract + 500 > getTickCount() then 
                return
            end

            triggerServerEvent("indicator.toggleIndicator", localPlayer, vehicle, indicatorSide, indicatorData)
            lastInteract = getTickCount()
        end
    end
end
bindKey("mouse1", "down", toggleIndicator)
bindKey("mouse2", "down", toggleIndicator)
bindKey("F4", "down", toggleIndicator)

function playIndicatorSound()
    playSound("files/sounds/index.wav")
end
addEvent("indicator.playIndicatorSound", true)
addEventHandler("indicator.playIndicatorSound", root, playIndicatorSound)