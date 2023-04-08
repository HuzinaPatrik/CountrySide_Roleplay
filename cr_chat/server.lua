function playerChat(message, messageType)
	cancelEvent()
    triggerClientEvent(source, "onClientMessage", source, source, message, messageType)
end
addEventHandler("onPlayerChat", root, playerChat)

function createMessage(element, message, mtype)
    triggerClientEvent(element, "createMessage", element, element, message, mtype)
end

addEvent("giveMessageToClient", true)
addEventHandler("giveMessageToClient", root, 
    function(sElement, e, text, r,g,b, whisper, ooc, bubbleText, radio)
        if not whisper then whisper = false end
        if not ooc then ooc = false end
        triggerClientEvent(e, "chat -- receive", e, e, text, r,g,b, whisper, ooc, sElement, radio)
        
        if ooc then
            outputServerLog("[OOC] " .. text)
        else
            --iprint(sElement)
            outputServerLog(text)
            if bubbleText then
                triggerClientEvent(e, "addBubble", e, sElement, bubbleText or text, r,g,b)
            end
        end
    end
)

function createMeInPosition(element, message, x,y,z,dim2,int2,maxDist)
    triggerClientEvent(element, "createMeInPosition", element, element, message, x,y,z,dim2,int2,maxDist)
end
addEvent("createMeInPosition", true)
addEventHandler("createMeInPosition", root, createMeInPosition)

function createDoInPosition(element, message, x,y,z,dim2,int2,maxDist)
    triggerClientEvent(element, "createDoInPosition", element, element, message, x,y,z,dim2,int2,maxDist)
end
addEvent("createDoInPosition", true)
addEventHandler("createDoInPosition", root, createDoInPosition)

local cache = {}
 
function blockFlood()
    if exports['cr_core']:getPlayerDeveloper(source) then
        return
    end
    
	if not cache[source] then
        cache[source] = {}
        cache[source]["num"] = 1
	else
        local source = source
        cache[source]["num"] = cache[source]["num"] + 1
        if cache[source]["num"] >= 5 and cache[source]["num"] <= 10 then
            cancelEvent()
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax .. " 1 másodpercen belül csak 5 parancs használható!", source, 255,255,255,true)
        elseif cache[source]["num"] >= 10 then
            cancelEvent()
            setElementData(source, "specialKick", true)
            setElementData(source, "specialKickReason", "Floodolás miatt!")
            kickPlayer(source, "Rendszer", "Túl sok parancsot használtál 1 másodpercen belül! (Flood érzékelve, feltüntetve!)")
        end
	end
end
addEventHandler("onPlayerCommand", root, blockFlood)

setTimer(
    function()
        cache = {}
    end, 1000, 0
)

addEventHandler("onElementDataChange", root,
    function(dName)
        if dName == "animation" then
            if not source.ducked then 
                local forceAnim = false
                local forceAnimation = getElementData(source, "forceAnimation") or {"", ""}
                if forceAnimation[1] ~= "" or forceAnimation[2] ~= "" then
                    forceAnim = true
                end
                if forceAnim then
                    return
                end

                local value = getElementData(source, dName)
                if value[2] == "shout_01" or value[1] == "GHANDS" then 
                    setPedAnimation(source, unpack(value))
                elseif value[2] == "" or value[1] == "" then 
                    setPedAnimation(source, "", "")
                else 
                    setPedAnimation(source, value[1], value[2], 3000,false,false,false,false)
                end
            end
        end
    end
)