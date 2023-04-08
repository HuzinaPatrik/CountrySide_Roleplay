local function onClientStart()
    if localPlayer:getData("loggedIn") then 
        if (localPlayer:getData("char >> job") or 0) == jobData.jobId then 
            startJob()
        end
    end
end
addEventHandler("onClientResourceStart", resourceRoot, onClientStart)

isJobStarted = false

function startJob()
    isJobStarted = true

    local syntax = exports.cr_core:getServerSyntax("Butcher", "info")
    local radarBlip = exports.cr_radar:createStayBlip("Húsfeldolgozó üzem", Blip(jobData.meatFactoryBlipPoint, 0, 2, 255, 0, 0, 255, 0, 0), 0, "butcher", 24, 24, 255, 255, 255)

    outputChatBox(syntax .. "Sikeresen felvetted a munkát, most menj a húsfeldolgozó üzembe hogy elkezdhess dolgozni.", 255, 0, 0, true)

    createMarkers()
    addEventHandler("onClientMarkerHit", root, onClientMarkerHit)
    addEventHandler("onClientClick", root, onClientClick)
end

function stopJob()
    isJobStarted = false

    destroyMarkers()
    exports.cr_radar:destroyStayBlip("Húsfeldolgozó üzem")

    removeEventHandler("onClientMarkerHit", root, onClientMarkerHit)
    removeEventHandler("onClientClick", root, onClientClick)
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
            if dataName == "butcher >> meatInHand" or dataName == "butcher >> boxInHand" then 
                syncPlayer(source, dataName)
            end
        end
    end
end
addEventHandler("onClientElementDataChange", root, onClientDataChange)