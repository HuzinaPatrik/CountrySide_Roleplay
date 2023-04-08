horns = {
    "files/sounds/horn/1.mp3",
    "files/sounds/horn/2.mp3",
    "files/sounds/horn/3.mp3",
}

local sounds = {}
local soundTimers = {}

function getMaximumHorns()
    local val = 0
    if horns then 
        val = tonumber(#horns or 0)
    end 

    return val
end

function onHorn(button, press)
    if localPlayer.vehicle and localPlayer.vehicleSeat == 0 then 
        if button == "h" and press then
            local tuningData = localPlayer.vehicle:getData("veh >> tuningData") or {}
            if tonumber(tuningData["horn"] or 0) > 0 then 
                if not isElement(sounds[localPlayer.vehicle]) then 
                    sounds[localPlayer.vehicle] = playSound3D(horns[tonumber(tuningData["horn"] or 0)], localPlayer.vehicle.position, true)
                    sounds[localPlayer.vehicle]:attach(localPlayer.vehicle)

                    if isTimer(soundTimers[localPlayer.vehicle]) then killTimer(soundTimers[localPlayer.vehicle]) end 
                    local players = exports['cr_core']:getNearbyPlayers("high")
                    soundTimers[localPlayer.vehicle] = setTimer(triggerLatentServerEvent, 500, 1, "syncHorn", 5000, false, localPlayer, players, localPlayer, true)
                end 

                cancelEvent()
            end 
        elseif button == "h" and not press then 
            local tuningData = localPlayer.vehicle:getData("veh >> tuningData") or {}
            if tonumber(tuningData["horn"] or 0) > 0 then 
                if isElement(sounds[localPlayer.vehicle]) then 
                    sounds[localPlayer.vehicle]:destroy()
                    sounds[localPlayer.vehicle] = nil 
                    collectgarbage("collect")

                    if isTimer(soundTimers[localPlayer.vehicle]) then killTimer(soundTimers[localPlayer.vehicle]) end 
                    local players = exports['cr_core']:getNearbyPlayers("high")
                    soundTimers[localPlayer.vehicle] = setTimer(triggerLatentServerEvent, 500, 1, "syncHorn", 5000, false, localPlayer, players, localPlayer, false)
                end 

                cancelEvent()
            end 
        end
    end 
end
addEventHandler("onClientKey", root, onHorn)

function playHornSound(e, state)
    if e.vehicle then 
        local tuningData = e.vehicle:getData("veh >> tuningData") or {}
        if tonumber(tuningData["horn"] or 0) > 0 then 
            if state then 
                if not isElement(sounds[e.vehicle]) then 
                    sounds[e.vehicle] = playSound3D(horns[tonumber(tuningData["horn"] or 0)], e.vehicle.position, true)
                    sounds[e.vehicle]:attach(e.vehicle)
                end 
            else
                if isElement(sounds[e.vehicle]) then 
                    sounds[e.vehicle]:destroy()
                    sounds[e.vehicle] = nil 
                    collectgarbage("collect")
                end 
            end 
        end 
    end 
end 
addEvent("playHornSound", true)
addEventHandler("playHornSound", root, playHornSound)