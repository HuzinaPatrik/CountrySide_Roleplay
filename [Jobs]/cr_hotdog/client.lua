function startJob()
    if not isJobStarted then 
        isJobStarted = true 

        local syntax = exports['cr_core']:getServerSyntax(nil, "info")
        outputChatBox(syntax .. "Sikeresen felvetted a munkát! Menj a dog houseba ahhoz, hogy elkezdhesd a munka valamelyik folyamatát!", 255, 255, 255, true)

        createMakingUtils()
    end 
end 

function stopJob()
    if isJobStarted then 
        isJobStarted = false 

        destroyMakingUtils()
        cancelDoingOrder()
        closeHotdogCreator()
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