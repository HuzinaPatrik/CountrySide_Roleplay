function startJob()
    if not isJobStarted then 
        isJobStarted = true 

        local syntax = exports['cr_core']:getServerSyntax(nil, "info")
        outputChatBox(syntax .. "Sikeresen felvetted a munkát! Menj a munkakocsifelvevőhöz ahhoz, hogy felvehesd a munkakocsidat!", 255, 255, 255, true)
        createMarkers()
        createListUtils()
    end 
end 

function stopJob()
    if isJobStarted then 
        isJobStarted = false 

        destroyMarkers()
        destroyListUtils()
    end 
end 

addEventHandler("onClientResourceStart", resourceRoot, 
    function()
        if localPlayer:getData("loggedIn") then 
            if localPlayer:getData("char >> job") == jobID then 
                startJob()
            end 
        end 
    end 
)

addEventHandler("onClientElementDataChange", localPlayer, 
    function(dName, oValue, nValue)
        if dName == "char >> job" then 
            if nValue and nValue == jobID then 
                startJob()
            else 
                stopJob()
            end 
        end 
    end 
)