isJobStarted = false

function onClientStart()
    if localPlayer:getData("loggedIn") then 
        if (localPlayer:getData("char >> job") or 0) == jobData.jobId then 
            startJob()
        end
    end
end
addEventHandler("onClientResourceStart", resourceRoot, onClientStart)

function startJob()
    isJobStarted = true

    local syntax = exports.cr_core:getServerSyntax("Miner", "info")

    outputChatBox(syntax .. "Sikeresen felvetted a munkát, most menj a bányával szemben lévő gyárhoz hogy munkajárművet igényelj.", 255, 0, 0, true)

    createJobMarkers()
end

function stopJob()
    isJobStarted = false

    destroyJobMarkers()

    triggerLatentServerEvent("destroyJobVehicle", 5000, false, localPlayer, localPlayer)
end

function onClientDataChange(dataName, oldValue, newValue)
    if source == localPlayer then 
        if dataName == "char >> job" then 
            if newValue and newValue == jobData.jobId then 
                startJob()
            elseif oldValue and oldValue == jobData.jobId then 
                stopJob()
            end
        end
    end

    if source.type == "player" then 
        if isElementStreamedIn(source) then 
            if dataName == "miner >> rockInHand" then 
                syncPlayer(source)
            end
        end
    elseif source.type == "vehicle" then 
        if isElementStreamedIn(source) then 
            if dataName == "miner >> rocksInVeh" then 
                if type(newValue) == "table" then 
                    syncVehicle(source)
                else
                    deSyncVehicle(source)
                end
            end
        end
    end
end
addEventHandler("onClientElementDataChange", root, onClientDataChange)