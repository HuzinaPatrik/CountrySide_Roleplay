function disableAllTypeOfSpeakingOnTheStart()
    for k, element in pairs(getElementsByType("player")) do
        setPedVoice(element, "PED_TYPE_DISABLED", "nil")
    end
    
    for k, element in pairs(getElementsByType("ped")) do
        setPedVoice(element, "PED_TYPE_DISABLED", "nil")
    end
end

setPedVoice(localPlayer, "PED_TYPE_DISABLED", "nil")

function disableAllTypeOfSpeakingOnStream()
    if getElementType(source) == "player" or getElementType(source) == "ped" then
        setPedVoice(source, "PED_TYPE_DISABLED", "nil")
    end
end
addEventHandler("onClientElementStreamIn", root, disableAllTypeOfSpeakingOnStream)