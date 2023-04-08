local isNitroActive, upgradeID

function startNitro()
    if localPlayer.vehicle then 
        if localPlayer:getData("inDeath") or localPlayer:getData("keysDenied") or localPlayer.vehicleSeat ~= 0  then 
            return 
        end 

        local now = getTickCount()
        local a = 1
        if now <= lastClickTick + a * 1000 then
            return
        end

        lastClickTick = getTickCount()

        local tuningData = localPlayer.vehicle:getData("veh >> tuningData") or {}
        if tonumber(tuningData["nitro"] or 0) == 1 then 
            if not isNitroActive then 
                local compatibleUpgrades = localPlayer.vehicle:getCompatibleUpgrades(8)
                if compatibleUpgrades and #compatibleUpgrades >= 1 then 
                    isNitroActive = true
                    upgradeID = compatibleUpgrades[#compatibleUpgrades]
                    localPlayer.vehicle:addUpgrade(upgradeID)

                    setVehicleNitroLevel(localPlayer.vehicle, tuningData["nitroLevel"])
                    setVehicleNitroActivated(localPlayer.vehicle, true)
                    localPlayer.vehicle:setData("veh >> nitro >> active", true)
                    createRender("checkNitroLevel", checkNitroLevel)
                    addEventHandler("onClientElementDestroy", localPlayer.vehicle, endNitro)
                end
            end
        end 
    end 
end 

bindKey("mouse1", "down", startNitro)
bindKey("lalt", "down", startNitro)
bindKey("ralt", "down", startNitro)

function endNitro(veh)
    if isNitroActive then 
        isNitroActive = false
        destroyRender("checkNitroLevel")
        setVehicleNitroActivated(veh, false)
        setVehicleNitroLevel(veh, 0)
        removeVehicleUpgrade(veh, upgradeID)
        veh:setData("veh >> nitro >> active", false)
        removeEventHandler("onClientElementDestroy", veh, endNitro)
    end 
end 

function stopNitro()
    if localPlayer.vehicle then 
        endNitro(localPlayer.vehicle)
    end 
end 

addEventHandler("onClientVehicleExit", root, 
    function(thePlayer, seat)
        if thePlayer == localPlayer and seat == 0 then 
            endNitro()
        end 
    end 
)

addEventHandler("onClientPlayerWasted", localPlayer, stopNitro)
addEventHandler("onClientResourceStop", resourceRoot, stopNitro)

bindKey("mouse1", "up", stopNitro)
bindKey("lalt", "up", stopNitro)
bindKey("ralt", "up", stopNitro)

function checkNitroLevel()
    if localPlayer:getData("keysDenied") or localPlayer:getData("inDeath") then 
        stopNitro()
    end 

    local tuningData = localPlayer.vehicle:getData("veh >> tuningData") or {}
    setVehicleNitroLevel(localPlayer.vehicle, tuningData["nitroLevel"])
    setVehicleNitroActivated(localPlayer.vehicle, true)
end 