lastClick = 0

function onClientStart()
    if localPlayer:getData("loggedIn") then 
        if (localPlayer:getData("char >> job") or 0) == jobData.jobId then 
            startJob()
        end
    end

    local players = getElementsByType("player")

    for i = 1, #players do 
        local v = players[i]

        if v:getData("delivery >> crateInHand") then 
            syncPlayer(v)
        end
    end
end
addEventHandler("onClientResourceStart", resourceRoot, onClientStart)

function startJob()
    local syntax = exports.cr_core:getServerSyntax("Delivery", "info")

    outputChatBox(syntax .. "Sikeresen felvetted a munkát, most menj a munkajármű felvevőhöz!", 255, 255, 255, true)

    createJobMarkers()
    createJobPeds()

    addEventHandler("onClientMarkerHit", root, onClientMarkerHit)
    addEventHandler("onClientMarkerLeave", root, onClientMarkerLeave)
end

function stopJob()
    destroyCustomers()
    destroyElements()
    resetPDA(true)

    removeEventHandler("onClientMarkerHit", root, onClientMarkerHit)
    removeEventHandler("onClientMarkerLeave", root, onClientMarkerLeave)

    orders = {}
    isVehicleFilledUp = false
end

function onClientDataChange(dataName, oldValue, newValue)
    if source.type == "player" then 
        if source == localPlayer then 
            if dataName == "char >> job" then 
                if newValue and newValue == jobData.jobId then 
                    startJob()
                elseif oldValue and oldValue == jobData.jobId then
                    stopJob()
                end
            elseif dataName == "char >> jobVehicle" and localPlayer:getData("char >> job") == jobData.jobId then 
                if not isElement(newValue) then 
                    destroyCustomers()
                    resetPDA()
                    destroyPickupMarkers()

                    exports.cr_radar:destroyStayBlip("Áru felvétele")

                    orders = {}
                    isVehicleFilledUp = false
                    talkedWithShiftLeader = false
                end
            end
        end
        
        if isElementStreamedIn(source) then 
            if dataName == "delivery >> crateInHand" then 
                syncPlayer(source)
            end
        end
    end
end
addEventHandler("onClientElementDataChange", root, onClientDataChange)