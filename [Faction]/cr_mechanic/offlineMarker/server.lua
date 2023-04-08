local syncStarted, isMarkersActive
local cache = {}

function createOfflineMarkers()
    for k,v in ipairs(offlineMarkerPositions) do 
        local x,y,z,dim,int = unpack(v)
        local marker = Marker(x, y, z - 1000, "cylinder", 1.5, 242, 202, 65)
        marker.alpha = 0
        marker.interior = int 
        marker.dimension = dim
        marker:setData("offlineMarker >> id", k)
        marker:setData("offlineMarker >> status", 'inactive')
        marker:setData("marker >> customMarker", true)
        marker:setData("marker >> customIconPath", ":cr_mechanic/files/images/offlineMarker.png")

        cache[marker] = k
    end 
end 
addEventHandler('onResourceStart', resourceRoot, createOfflineMarkers)

local syncResetTimer;

function syncronizeMechanicsDuty()
    if not syncStarted then 
        syncStarted = true 

        local sourcePlayer = getRandomPlayer()
        setTimer(triggerLatentClientEvent, 1000, 1, sourcePlayer, "syncronizeMechanicsDuty", 50000, false, sourcePlayer)

        if isTimer(syncResetTimer) then 
            killTimer(syncResetTimer)
        end 

        syncResetTimer = setTimer(
            function()
                if syncStarted then 
                    syncStarted = false 

                    syncronizeMechanicsDuty()
                end 
            end, 1 * 60 * 1000, 1
        )
    end 
end 
addEventHandler('onResourceStart', resourceRoot, syncronizeMechanicsDuty)
setTimer(syncronizeMechanicsDuty, 5 * 60 * 1000, 0)

function syncResult(num)
    if syncStarted and tonumber(num) then 
        syncStarted = false 

        if num > 0 then 
            if isMarkersActive then 
                isMarkersActive = false

                for k,v in pairs(cache) do 
                    k.alpha = 0
                    k:setData('offlineMarker >> status', 'inactive')
                    local x,y,z = getElementPosition(k)
                    k.position = Vector3(x,y,z - 1000)
                end 

                outputDebugString('Offline Mechanic Markers deactivated!', 0, 255, 87, 87)
            end 
        else 
            if not isMarkersActive then 
                isMarkersActive = true

                for k,v in pairs(cache) do 
                    k.alpha = 255
                    k:setData('offlineMarker >> status', 'active')
                    local x,y,z = getElementPosition(k)
                    k.position = Vector3(x,y,z + 1000)
                end 

                outputDebugString('Offline Mechanic Markers activated!', 0, 87, 255, 87)
            end 
        end 
    end 
end 
addEvent('offlineMarker>>sync>>result', true)
addEventHandler('offlineMarker>>sync>>result', root, syncResult)