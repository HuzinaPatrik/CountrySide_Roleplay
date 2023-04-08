function detachAndAttach(sourceElement, veh, obj)
    if veh:getDoorOpenRatio(4) == 1 and veh:getDoorOpenRatio(5) == 1 then
        if not sourceElement:getData("objInHand") then
            obj:setCollisionsEnabled(false)
            obj:setData("from", veh)
            detachElements(obj, veh)
            attachElements(obj, sourceElement, 0, 2.5, -0.25)
            obj.alpha = 200
            sourceElement:setData("objInHand", obj)
            triggerClientEvent(sourceElement, "doAmbulanceBed", sourceElement)
            veh:setData("veh >> ambulanceBed", not veh:getData("veh >> ambulanceBed")) 
        else
            local syntax = exports['cr_core']:getServerSyntax(nil, "error")
            outputChatBox(syntax .. "Egyszerre 1 hordágyot tolhatsz!", sourceElement, 255,255,255,true)
        end
    else
        local syntax = exports['cr_core']:getServerSyntax(nil, "error")
        outputChatBox(syntax .. "A hordágyat csak akkor veheted ki ha nyitva van a hátsó jobb és bal ajtó!", sourceElement, 255,255,255,true)
    end
    --trigger
end
addEvent("Detach&Attach", true)
addEventHandler("Detach&Attach", root, detachAndAttach)

function detachAndAttach2(sourceElement, veh, obj)
    if veh:getDoorOpenRatio(4) == 1 and veh:getDoorOpenRatio(5) == 1 then
        if sourceElement:getData("objInHand") then
            if obj == sourceElement:getData("objInHand") then
                if obj:getData("from") == veh then
                    obj:setCollisionsEnabled(true)
                    obj:setData("from", nil)
                    detachElements(obj, sourceElement)
                    attachElements(obj, veh, 0, -1, 0.35)
                    obj.alpha = 255
                    sourceElement:setData("objInHand", nil)
                    veh:setData("veh >> ambulanceBed", not veh:getData("veh >> ambulanceBed")) 
                    triggerClientEvent(sourceElement, "stopDoingAmbulanceBed", sourceElement)
                    --trigger
                else
                    local syntax = exports['cr_core']:getServerSyntax(nil, "error")
                    outputChatBox(syntax .. "A hordágy amit visszaszeretnél rakni nem ebből a mentőkocsiból származik!", sourceElement, 255,255,255,true)
                end
            else
                local syntax = exports['cr_core']:getServerSyntax(nil, "error")
                outputChatBox(syntax .. "A hordágy amit visszaszeretnél rakni nem ebből a mentőkocsiból származik!", sourceElement, 255,255,255,true)
            end
        else
            local syntax = exports['cr_core']:getServerSyntax(nil, "error")
            outputChatBox(syntax .. "Ahhoz, hogy visszarakhasd a hordágyot elsőnek nálad kell legyen!", sourceElement, 255,255,255,true)
        end
    else
        local syntax = exports['cr_core']:getServerSyntax(nil, "error")
        outputChatBox(syntax .. "A hordágyat csak akkor rakhatod be ha nyitva van a hátsó jobb és bal ajtó!", sourceElement, 255,255,255,true)
    end
end
addEvent("Detach&Attach2", true)
addEventHandler("Detach&Attach2", root, detachAndAttach2)

function placeAmbulanceBed(sourceElement)
    if sourceElement:getData("objInHand") then 
        local obj = sourceElement:getData("objInHand")
        detachElements(obj, sourceElement)
        obj.alpha = 255
        obj:setCollisionsEnabled(true)
        triggerClientEvent(sourceElement, "stopDoingAmbulanceBed", sourceElement, true)
        obj:setData("placed", true)
        sourceElement:setData("objInHand", nil)
        obj.rotation = sourceElement.rotation
    end
end
addEvent("placeAmbulanceBed", true)
addEventHandler("placeAmbulanceBed", root, placeAmbulanceBed)

function doAmbulanceBedPlacePlayer(sourceElement, nearestE)
    if not sourceElement:getData("objInHand") then 
        if not nearestE:getData("isPlayerInBed") then
            sourceElement:setData("char >> inAmbulanceBed", true)
            sourceElement:setData("char >> inAmbulanceBedE", nearestE)
            nearestE:setData("isPlayerInBed", sourceElement)
            attachElements(sourceElement, nearestE, 0, -1.5, 1)
            --setTimer(detachElements, sourceElement, nearestE)
            --triggerClientEvent(root, "")
            sourceElement:setCollisionsEnabled(false)
        end
    end
end
addEvent("doAmbulanceBedPlacePlayer", true)
addEventHandler("doAmbulanceBedPlacePlayer", root, doAmbulanceBedPlacePlayer)

addEventHandler("onPlayerQuit", root,
    function()
        if source and isElement(source) and source:getData("char >> inAmbulanceBedE") then
            local obj = source:getData("char >> inAmbulanceBedE")
            obj:setData("isPlayerInBed", nil)
        end
    end
)

function stopDoingAmbulanceBedPlacePlayer(sourceElement)
    local nearestE = sourceElement:getData("char >> inAmbulanceBedE")
    if sourceElement:getData("char >> inAmbulanceBed") then 
        sourceElement:setData("char >> inAmbulanceBed", nil)
        sourceElement:setData("char >> inAmbulanceBedE", nil)
        nearestE:setData("isPlayerInBed", nil)
        detachElements(sourceElement, nearestE)
        sourceElement:setCollisionsEnabled(true)
    end
end
addEvent("stopDoingAmbulanceBedPlacePlayer", true)
addEventHandler("stopDoingAmbulanceBedPlacePlayer", root, stopDoingAmbulanceBedPlacePlayer)

function detachAndAttach3(sourceElement, obj)
    if not sourceElement:getData("objInHand") then
        obj:setCollisionsEnabled(false)
        --obj:setData("from", veh)
        --detachElements(obj, veh)
        attachElements(obj, sourceElement, 0, 2.5, -0.25)
        obj.alpha = 200
        obj:setData("placed", nil)
        sourceElement:setData("objInHand", obj)
        triggerClientEvent(sourceElement, "doAmbulanceBed", sourceElement, true)
        --veh:setData("veh >> ambulanceBed", not veh:getData("veh >> ambulanceBed")) 
    else
        local syntax = exports['cr_core']:getServerSyntax(nil, "error")
        outputChatBox(syntax .. "Egyszerre 1 hordágyot tolhatsz!", sourceElement, 255,255,255,true)
    end
end
addEvent("Detach&Attach3", true)
addEventHandler("Detach&Attach3", root, detachAndAttach3)