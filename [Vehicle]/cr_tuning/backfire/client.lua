local positions = {
    --[[
        [vehicleID] = {
            {offsetX, offsetY, offsetZ},
			--Bal-jobb, BE-KI, Fel-le,
        }
    ]]

	[429] = {
        {0.125, -2.30, -0.4},
		{0.255, -2.30, -0.4},
		{-0.125, -2.30, -0.4},
		{-0.255, -2.30, -0.4},
    },
}

function vehicleHasBackFire(modelid)
    return positions[modelid]
end 

function createBackFire(e)
    if positions[e.vehicle.model] then 
        for k,v in pairs(positions[e.vehicle.model]) do 
            local ox, oy, oz = unpack(v)
            local matrix = e.vehicle.matrix
            local position = matrix:transformPosition(Vector3(ox, oy, oz))
            fxAddGunshot(position.x, position.y, position.z, (e.vehicle.position.x - position.x) * -1, (e.vehicle.position.y - position.y) * -1, 0, true)
        end 
    end 
end 

addCommandHandler("testbackfire", 
    function()
        if exports['cr_core']:getPlayerDeveloper(localPlayer) then 
            createBackFire(localPlayer)
        end 
    end 
)

oldGear = 1
setTimer(
    function()
        if localPlayer.vehicle and localPlayer.vehicleSeat == 0 then 
            if tonumber((localPlayer.vehicle:getData("veh >> tuningData") or {})["backfire"] or 0) == 1 then 
                if oldGear ~= getVehicleCurrentGear(localPlayer.vehicle) then 
                    local _oldGear = oldGear
                    oldGear = getVehicleCurrentGear(localPlayer.vehicle)

                    if tonumber(oldGear) and tonumber(oldGear) >= 1 then 
                        if oldGear > _oldGear then 
                            createBackFire(localPlayer)

                            local players = exports['cr_core']:getNearbyPlayers("medium")
                            local soundPath = ":cr_vehicle/assets/sounds/backfire.mp3"
                            local sound = playSound3D(soundPath, localPlayer.vehicle.position)
                            sound.dimension = localPlayer.vehicle.dimension 
                            sound.interior = localPlayer.vehicle.interior 
                            sound:attach(localPlayer.vehicle)
                            if #players >= 1 then 
                                triggerLatentServerEvent("syncBackFire", 5000, false, localPlayer, localPlayer, players, soundPath)
                            end 
                        end 
                    end 
                end 
            end 
        end 
    end, 500, 0
)


function syncBackFire(sourcePlayer, soundPath)
    createBackFire(sourcePlayer)

    local sound = playSound3D(soundPath, sourcePlayer.vehicle.position)
    sound.dimension = sourcePlayer.vehicle.dimension 
    sound.interior = sourcePlayer.vehicle.interior 
    sound:attach(sourcePlayer.vehicle)
end 
addEvent("syncBackFire", true)
addEventHandler("syncBackFire", root, syncBackFire)