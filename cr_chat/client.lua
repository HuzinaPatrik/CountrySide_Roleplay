local spamTimer
local oldMessage = "BlueMTA"
local maxLength = 120
local bubbleTimer = nil

function generateRandomString( charsCount )
    local str = "";
    for i = 1, charsCount do
    local c = string.char( math.random( 100, 122 ) );
    if i % 2 == 1 then c = string.upper( c ); end
           str = str .. c;
    end
    return str;
end

local emojis = {
    ["%:%)"] = {"mosolyog.", false},
    ["%:%("] = {"szomorú.", false},
    ["%:d"] = {"nevet.", {"rapping", "laugh_01"}},
    ["xd"] = {"szakad a röhögéstől.", {"rapping", "laugh_01"}},
    ["%;%)"] = {"kacsint.", false},
    ["%:o"] = {"meglepődik.", false},
    ["o%_o"] = {"meglepődik.", false},
    ["o%-o"] = {"meglepődik.", false},
    ["0%-0"] = {"meglepődik.", false},
    ["0%_0"] = {"meglepődik.", false},
    ["%;%("] = {"sírva fakad", {"GRAVEYARD", "mrnF_loop"}},
    ["%:%'%("] = {"sírva fakad", {"GRAVEYARD", "mrnF_loop"}},
}

local speakAnimations = {
    {"GHANDS", "gsign1", -1, true, false, false},
    {"GHANDS", "gsign2", -1, true, false, false},
    {"GHANDS", "gsign3", -1, true, false, false},
    {"GHANDS", "gsign4", -1, true, false, false},
    {"GHANDS", "gsign5", -1, true, false, false},
    {"gangs", "prtial_gngtlka", -1, true, false, false},
    {"gangs", "prtial_gngtlkb", -1, true, false, false},
    {"gangs", "prtial_gngtlkc", -1, true, false, false},
    {"gangs", "prtial_gngtlkd", -1, true, false, false},
    {"gangs", "prtial_gngtlke", -1, true, false, false},
    {"gangs", "prtial_gngtlkf", -1, true, false, false},
    {"gangs", "prtial_gngtlkg", -1, true, false, false},
    {"gangs", "prtial_gngtlkh", -1, true, false, false},
}

function createMessage(element, message, mtype)
    if element == localPlayer then
        onClientMessage(localPlayer, message, mtype)
    end
end
addEvent("createMessage", true)
addEventHandler("createMessage", root, createMessage)

function removeHex(text, digits)
    assert(type(text) == "string", "Bad argument 1 @ removeHex [String expected, got " .. tostring(text) .. "]")
    assert(digits == nil or (type(digits) == "number" and digits > 0), "Bad argument 2 @ removeHex [Number greater than zero expected, got " .. tostring(digits) .. "]")
    return string.gsub(text, "#" .. (digits and string.rep("%x", digits) or "%x+"), "")
end

function createMeInPosition(element, message, x,y,z,dim2,int2,maxDist)
    if element == localPlayer then
        --local message
        if string.len(message) > 1 then
            message = string.sub(message, 1, 1) .. string.sub(message, 2, string.len(message))
        elseif string.len(message) < 1 or string.len(message) == 0 then
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax .. "/me [Cselekvés]", 255,255,255,true)
            return
        elseif string.sub(message, 1, 1) == " " then
            return    
        elseif string.len(message) > maxLength then
            return
        else
            message = string.sub(message, 1, 1)
        end
        
        for k,v in pairs(emojis) do
            if string.upper(message):find(string.upper(string.gsub(string.lower(k), string.lower("%%"), "") ), 1, true) then
                onClientMessage(localPlayer, emojis[k][1], 1, true)
                if emojis[k][2] then
                    if not getPedOccupiedVehicle(localPlayer) then
                        setElementData(localPlayer, "animation", emojis[k][2]); 
                        if isTimer(animationTimer) then killTimer(animationTimer) end
                        animationTimer = setTimer(
                            function()
                                localPlayer:setData("animation", {"", ""})
                            end, 3000, 1
                        )
                     end
                end
                --outputChatBox(message)
                --outputChatBox(k)
                local mes = string.gsub(string.lower(message), k, "") 
                local mes2 = string.gsub(mes, " ", "")
                if #mes2 <= 0 then
                    return
                else
                    message = mes
                end
            end
        end
        
        local name = exports['cr_admin']:getAdminName(element)
        
        for k,v in pairs(getElementsByType("player")) do
            local int = getElementInterior(v)
            local dim = getElementDimension(v)
            local x1,y1,z1 = getElementPosition(v)
            if getElementData(v, "player >> recon") then
                local target = getElementData(v, "player >> recon >> target") or v
                x1,y1,z1 = getElementPosition(target)
                int, dim = getElementInterior(target), getElementDimension(target)
            end
            
            if int == int2 and dim == dim2 then
                --local x1, y1, z1 = getElementPosition(v)
                local distance = math.floor(getDistanceBetweenPoints3D(x, y, z, x1, y1, z1))
                local veh2 = getPedOccupiedVehicle(v)
                if not veh or veh2 == veh or not veh:getData("veh >> windows >> closed") then
                    if distance <= (tonumber(maxDist) or 8) then
                        local r,g,b = 194, 162, 218
                        triggerServerEvent("giveMessageToClient", localPlayer,  localPlayer, v, " *** "..name.." "..message, r,g,b, false, false, false)
                    end
                end
            end
        end
    end
end
addEvent("createMeInPosition", true)
addEventHandler("createMeInPosition", root, createMeInPosition)

function createDoInPosition(element, message, x,y,z,dim2,int2,maxDist)
    if element == localPlayer then
        if string.len(message) > 1 then
            message = string.sub(message, 1, 1) .. string.sub(message, 2, string.len(message))
        elseif string.len(message) < 1 or string.len(message) == 0 then
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax .. "/do [Történés]", 255,255,255,true)
            return
        elseif string.sub(message, 1, 1) == " " then
            return    
        elseif string.len(message) > maxLength then
            return
        else
            message = string.sub(message, 1, 1)
        end
        
        for k,v in pairs(emojis) do
            if string.upper(message):find(string.upper(string.gsub(string.lower(k), string.lower("%%"), "") ), 1, true) then
                onClientMessage(localPlayer, emojis[k][1], 1, true)
                if emojis[k][2] then
                    if not getPedOccupiedVehicle(localPlayer) then
                        setElementData(localPlayer, "animation", emojis[k][2]); 
                        if isTimer(animationTimer) then killTimer(animationTimer) end
                        animationTimer = setTimer(
                            function()
                                localPlayer:setData("animation", {"", ""})
                            end, 3000, 1
                        )
                     end
                end
                --outputChatBox(message)
                --outputChatBox(k)
                local mes = string.gsub(string.lower(message), k, "") 
                local mes2 = string.gsub(mes, " ", "")
                if #mes2 <= 0 then
                    return
                else
                    message = mes
                end
            end
        end

        message = message:gsub("^%l", string.upper)
        
        local name = exports['cr_admin']:getAdminName(element)


        for k,v in pairs(getElementsByType("player")) do
            local int = getElementInterior(v)
            local dim = getElementDimension(v)
            local x1,y1,z1 = getElementPosition(v)
            if getElementData(v, "player >> recon") then
                local target = getElementData(v, "player >> recon >> target") or v
                x1,y1,z1 = getElementPosition(target)
                int, dim = getElementInterior(target), getElementDimension(target)
            end
            if int == int2 and dim == dim2 then
                --local x1, y1, z1 = getElementPosition(v)
                local distance = math.floor(getDistanceBetweenPoints3D(x, y, z, x1, y1, z1))
                local veh2 = getPedOccupiedVehicle(v)
                if not veh or veh2 == veh or not veh:getData("veh >> windows >> closed") then
                    if distance <= (tonumber(maxDist) or 8) then
                        local r,g,b = 255, 51, 102
                        triggerServerEvent("giveMessageToClient", localPlayer,  localPlayer, v, " * "..message.." (("..name.."))", r,g,b, false, false, false)
                    end
                end
            end
        end    
    end
end
addEvent("createDoInPosition", true)
addEventHandler("createDoInPosition", root, createDoInPosition)

function onClientMessage(element, message, mtype, ignoreTrigger)
    if not getElementData(element, "loggedIn") then return end
    if element ~= localPlayer then return end
    if not ignoreTrigger and isTimer(spamTimer) then return end
    message = removeHex(message, 6)
    message = findSwearIC(message)
    
    --[[
    if oldMessage == message then 
        --local syntax = exports['cr_core']:getServerSyntax(false, "error")
        --outputChatBox(syntax .. "Ne ismételd önmagadat! (Ne írd 2x ugyan azt a szöveget egymás után)", 255,255,255,true)
        exports['cr_infobox']:addBox("warning", "Ne ismételd önmagad!")
        spamTimer = setTimer(function() end, 300, 1)
        return
    end]]
    
    if getElementData(localPlayer, "char->afk") then
        setElementData(localPlayer, "char->afk", false)
    end
    
    if getElementData(localPlayer, "char >> afk") then
        setElementData(localPlayer, "char >> afk", false)
    end
    
    if getElementData(localPlayer, "char >> tazed") then
        return
    end

    if localPlayer:getData("inDeath") then 
        return 
    end 
    
    oldMessage = message
    
    local veh = getPedOccupiedVehicle(localPlayer)
    if mtype == 0 then
        if localPlayer:getData("drunkSpeak") then
            message = generateRandomString(#message)
        end
        
        --local message
        if string.len(message) > 1 then
            message = string.upper(string.sub(message, 1, 1)) .. string.sub(message, 2, string.len(message))
        elseif string.len(message) < 1 or string.len(message) == 0 then
            return
        elseif string.sub(message, 1, 1) == " " then
            return    
        elseif string.len(message) > maxLength then
            return
        else
            message = string.upper(string.sub(message, 1, 1))
        end

        for k,v in pairs(emojis) do
            if string.upper(message):find(string.upper(string.gsub(string.lower(k), string.lower("%%"), "") ), 1, true) then
                onClientMessage(localPlayer, emojis[k][1], 1, true)
                if emojis[k][2] then
                    if not getPedOccupiedVehicle(localPlayer) then
                        setElementData(localPlayer, "animation", emojis[k][2]); 
                        if isTimer(animationTimer) then killTimer(animationTimer) end
                        animationTimer = setTimer(
                            function()
                                localPlayer:setData("animation", {"", ""})
                            end, 3000, 1
                        )
                     end
                end
                --outputChatBox(message)
                --outputChatBox(k)
                local mes = string.gsub(string.lower(message), k, "") 
                local mes2 = string.gsub(mes, " ", "")
                if #mes2 <= 0 then
                    return
                else
                    message = mes
                end
            end
        end

        if tonumber(localPlayer:getData("options >> speakanimation") or 0) then 
            if not exports['cr_animation']:isPlayerHaveActiveAnimation(localPlayer) then 
                if speakAnimations[tonumber(localPlayer:getData("options >> speakanimation") or 0)] then 
                    local block, anim = unpack(speakAnimations[tonumber(localPlayer:getData("options >> speakanimation") or 0)])
                    localPlayer:setData("animation", {block, anim, 200 * #message,true,false,false,false})
                    if isTimer(animationTimer) then killTimer(animationTimer) end
                    animationTimer = setTimer(
                        function()
                            localPlayer:setData("animation", {"", ""})
                        end, 200 * #message, 1
                    )
                end
            end
        end

        local name = exports['cr_admin']:getAdminName(element)
        if not veh or not getElementData(veh, "veh >> windows >> closed") then
            outputChatBox(name.." mondja: "..message, 255,255,255)
            if showMyBubbles then
                addBubble(localPlayer, message, 255, 255, 255)
            end
        else
            outputChatBox(name.." mondja (járműben): "..message, 255,255,255)
            if showMyBubbles then
                addBubble(localPlayer, message, 255, 255, 255)
            end
        end

        spamTimer = setTimer(function() end, 300, 1)

        local x,y,z = getElementPosition(localPlayer)
        local int2 = getElementInterior(localPlayer)
        local dim2 = getElementDimension(localPlayer)
        if getElementData(localPlayer, "player >> recon") then
            local target = getElementData(localPlayer, "player >> recon >> target") or localPlayer
            x,y,z = getElementPosition(target)
            int, dim = getElementInterior(target), getElementDimension(target)
        end
        for k,v in pairs(getElementsByType("player", root, true)) do
            local int = getElementInterior(v)
            local dim = getElementDimension(v)
            local x1,y1,z1 = getElementPosition(v)
            if getElementData(v, "player >> recon") then
                local target = getElementData(v, "player >> recon >> target") or v
                x1,y1,z1 = getElementPosition(target)
                int, dim = getElementInterior(target), getElementDimension(target)
            end
            if v ~= localPlayer and int == int2 and dim == dim2 then
                local distance = math.floor(getDistanceBetweenPoints3D(x, y, z, x1, y1, z1))

                local veh2 = getPedOccupiedVehicle(v)
                --outputChatBox("WINDOWSTATE: " .. tostring(getElementData(veh, "veh >> windowState")))
                if veh2 and veh and veh == veh2 then
                    local r,g,b = 255,255,255
                    if not getElementData(veh, "veh >> windows >> closed") then
                        triggerServerEvent("giveMessageToClient", localPlayer,  localPlayer, v, name.." mondja: "..message, r,g,b, false, false, message)
                    else    
                        triggerServerEvent("giveMessageToClient", localPlayer,  localPlayer, v, name.." mondja (járműben): "..message, r,g,b, false, false, message)
                    end    
                --elseif distance <= 8 and not veh and not veh2 or distance <= 8 and veh and not veh:getData("veh >> windows >> closed") and not veh2 or veh2 and not veh2:getData("veh >> windows >> closed") and not veh then
                elseif not veh and not veh2 or veh and not veh:getData("veh >> windows >> closed") and not veh2 or veh2 and not veh2:getData("veh >> windows >> closed") and not veh or veh and veh2 and not veh:getData("veh >> windows >> closed") and not veh2:getData("veh >> windows >> closed") then
                    if distance <= 8 then
                        local r,g,b = 255,255,255
                        --outputChatBox(distance)
                        if distance <= 2 then
                            r,g,b = 255,255,255
                        elseif distance <= 4 then
                            r,g,b = 191, 191, 191 --75% white
                        elseif distance <= 6 then
                            r,g,b = 166, 166, 166 --65% white
                        elseif distance <= 8 then
                            r, g, b = 115, 115, 115 --45% white
                        else
                            r, g, b = 95, 95, 95 --?% white
                        end

                        triggerServerEvent("giveMessageToClient", localPlayer,  localPlayer, v, name.." mondja: "..message, r,g,b, false, false, message)
                    end
                end
            end
        end
    elseif mtype == "radio >> speak" then 
        if localPlayer:getData("drunkSpeak") then
            message = generateRandomString(#message)
        end
        
        --local message
        if string.len(message) > 1 then
            message = string.upper(string.sub(message, 1, 1)) .. string.sub(message, 2, string.len(message))
        elseif string.len(message) < 1 or string.len(message) == 0 then
            return
        elseif string.sub(message, 1, 1) == " " then
            return    
        elseif string.len(message) > maxLength then
            return
        else
            message = string.upper(string.sub(message, 1, 1))
        end

        for k,v in pairs(emojis) do
            if string.upper(message):find(string.upper(string.gsub(string.lower(k), string.lower("%%"), "") ), 1, true) then
                onClientMessage(localPlayer, emojis[k][1], 1, true)
                if emojis[k][2] then
                    if not getPedOccupiedVehicle(localPlayer) then 
                        setElementData(localPlayer, "animation", emojis[k][2]); 
                        if isTimer(animationTimer) then killTimer(animationTimer) end
                        animationTimer = setTimer(
                            function()
                                localPlayer:setData("animation", {"", ""})
                            end, 3000, 1
                        )
                     end
                end
                --outputChatBox(message)
                --outputChatBox(k)
                local mes = string.gsub(string.lower(message), k, "") 
                local mes2 = string.gsub(mes, " ", "")
                if #mes2 <= 0 then
                    return
                else
                    message = mes
                end
            end
        end

        local name = exports['cr_admin']:getAdminName(element)
        if not veh or not getElementData(veh, "veh >> windows >> closed") then
            -- outputChatBox(name.." mondja (rádióban): "..message, 255,255,255)
            if showMyBubbles then
                addBubble(localPlayer, message, 255, 255, 255)
            end
        else
            -- outputChatBox(name.." mondja (rádióban) (járműben): "..message, 255,255,255)
            if showMyBubbles then
                addBubble(localPlayer, message, 255, 255, 255)
            end
        end

        spamTimer = setTimer(function() end, 300, 1)

        local x,y,z = getElementPosition(localPlayer)
        local int2 = getElementInterior(localPlayer)
        local dim2 = getElementDimension(localPlayer)
        if getElementData(localPlayer, "player >> recon") then
            local target = getElementData(localPlayer, "player >> recon >> target") or localPlayer
            x,y,z = getElementPosition(target)
            int, dim = getElementInterior(target), getElementDimension(target)
        end

        for k,v in pairs(getElementsByType("player")) do
            local int = getElementInterior(v)
            local dim = getElementDimension(v)
            local x1,y1,z1 = getElementPosition(v)
            if getElementData(v, "player >> recon") then
                local target = getElementData(v, "player >> recon >> target") or v
                x1,y1,z1 = getElementPosition(target)
                int, dim = getElementInterior(target), getElementDimension(target)
            end

            if v ~= localPlayer and int == int2 and dim == dim2 then
                local distance = math.floor(getDistanceBetweenPoints3D(x, y, z, x1, y1, z1))

                local veh2 = getPedOccupiedVehicle(v)
                --outputChatBox("WINDOWSTATE: " .. tostring(getElementData(veh, "veh >> windowState")))
                if veh2 and veh and veh == veh2 then
                    local r,g,b = 255,255,255
                    if not getElementData(veh, "veh >> windows >> closed") then
                        -- triggerServerEvent("giveMessageToClient", localPlayer,  localPlayer, v, name.." mondja (rádióban): "..message, r,g,b, false, false, message)
                    else    
                        -- triggerServerEvent("giveMessageToClient", localPlayer,  localPlayer, v, name.." mondja (rádióban) (járműben): "..message, r,g,b, false, false, message)
                    end    
                elseif not veh and not veh2 or veh and not veh:getData("veh >> windows >> closed") and not veh2 or veh2 and not veh2:getData("veh >> windows >> closed") and not veh or veh and veh2 and not veh:getData("veh >> windows >> closed") and not veh2:getData("veh >> windows >> closed") then
                    if distance <= 8 then
                        local r,g,b = 255,255,255
                        --outputChatBox(distance)
                        if distance <= 2 then
                            r,g,b = 255,255,255
                        elseif distance <= 4 then
                            r,g,b = 191, 191, 191 --75% white
                        elseif distance <= 6 then
                            r,g,b = 166, 166, 166 --65% white
                        elseif distance <= 8 then
                            r, g, b = 115, 115, 115 --45% white
                        else
                            r, g, b = 95, 95, 95 --?% white
                        end

                        -- triggerServerEvent("giveMessageToClient", localPlayer,  localPlayer, v, name.." mondja (rádióban): "..message, r,g,b, false, false, message)
                    end
                end
            end

            if v:getData("usingRadio") then 
                if tonumber(v:getData("usingRadio.frekv") or -1) == tonumber(localPlayer:getData("usingRadio.frekv") or -2) then 
                    local r,g,b = 34, 167, 240
                    triggerServerEvent("giveMessageToClient", localPlayer,  localPlayer, v, name.." rádióban: "..message, r,g,b, false, false, false, true)
                end 
            end 
        end
    elseif mtype == "factionRadio >> speak" then 
        if localPlayer:getData("drunkSpeak") then
            message = generateRandomString(#message)
        end
        
        --local message
        if string.len(message) > 1 then
            message = string.upper(string.sub(message, 1, 1)) .. string.sub(message, 2, string.len(message))
        elseif string.len(message) < 1 or string.len(message) == 0 then
            return
        elseif string.sub(message, 1, 1) == " " then
            return    
        elseif string.len(message) > maxLength then
            return
        else
            message = string.upper(string.sub(message, 1, 1))
        end

        for k,v in pairs(emojis) do
            if string.upper(message):find(string.upper(string.gsub(string.lower(k), string.lower("%%"), "") ), 1, true) then
                onClientMessage(localPlayer, emojis[k][1], 1, true)
                if emojis[k][2] then
                    if not getPedOccupiedVehicle(localPlayer) then 
                        setElementData(localPlayer, "animation", emojis[k][2]); 
                        if isTimer(animationTimer) then killTimer(animationTimer) end
                        animationTimer = setTimer(
                            function()
                                localPlayer:setData("animation", {"", ""})
                            end, 3000, 1
                        )
                     end
                end
                --outputChatBox(message)
                --outputChatBox(k)
                local mes = string.gsub(string.lower(message), k, "") 
                local mes2 = string.gsub(mes, " ", "")
                if #mes2 <= 0 then
                    return
                else
                    message = mes
                end
            end
        end

        local name = exports['cr_admin']:getAdminName(element)
        if not veh or not getElementData(veh, "veh >> windows >> closed") then
            -- outputChatBox(name.." mondja (rádióban): "..message, 255,255,255)
            if showMyBubbles then
                addBubble(localPlayer, message, 255, 255, 255)
            end
        else
            -- outputChatBox(name.." mondja (rádióban) (járműben): "..message, 255,255,255)
            if showMyBubbles then
                addBubble(localPlayer, message, 255, 255, 255)
            end
        end

        spamTimer = setTimer(function() end, 300, 1)

        local x,y,z = getElementPosition(localPlayer)
        local int2 = getElementInterior(localPlayer)
        local dim2 = getElementDimension(localPlayer)
        if getElementData(localPlayer, "player >> recon") then
            local target = getElementData(localPlayer, "player >> recon >> target") or localPlayer
            x,y,z = getElementPosition(target)
            int, dim = getElementInterior(target), getElementDimension(target)
        end

        for k,v in pairs(getElementsByType("player")) do
            local int = getElementInterior(v)
            local dim = getElementDimension(v)
            local x1,y1,z1 = getElementPosition(v)
            if getElementData(v, "player >> recon") then
                local target = getElementData(v, "player >> recon >> target") or v
                x1,y1,z1 = getElementPosition(target)
                int, dim = getElementInterior(target), getElementDimension(target)
            end

            if v ~= localPlayer and int == int2 and dim == dim2 then
                local distance = math.floor(getDistanceBetweenPoints3D(x, y, z, x1, y1, z1))

                local veh2 = getPedOccupiedVehicle(v)
                --outputChatBox("WINDOWSTATE: " .. tostring(getElementData(veh, "veh >> windowState")))
                if veh2 and veh and veh == veh2 then
                    local r,g,b = 255,255,255

                    if exports.cr_dashboard:isPlayerInFactionType(v, 1) or exports.cr_dashboard:isPlayerInFactionType(v, 2) then 
                        if not getElementData(veh, "veh >> windows >> closed") then
                            -- triggerServerEvent("giveMessageToClient", localPlayer,  localPlayer, v, name.." mondja (rádióban): "..message, r,g,b, false, false, message)
                        else    
                            -- triggerServerEvent("giveMessageToClient", localPlayer,  localPlayer, v, name.." mondja (rádióban) (járműben): "..message, r,g,b, false, false, message)
                        end   
                    end 
                elseif not veh and not veh2 or veh and not veh:getData("veh >> windows >> closed") and not veh2 or veh2 and not veh2:getData("veh >> windows >> closed") and not veh or veh and veh2 and not veh:getData("veh >> windows >> closed") and not veh2:getData("veh >> windows >> closed") then
                    if distance <= 8 then
                        local r,g,b = 255,255,255
                        --outputChatBox(distance)
                        if distance <= 2 then
                            r,g,b = 255,255,255
                        elseif distance <= 4 then
                            r,g,b = 191, 191, 191 --75% white
                        elseif distance <= 6 then
                            r,g,b = 166, 166, 166 --65% white
                        elseif distance <= 8 then
                            r, g, b = 115, 115, 115 --45% white
                        else
                            r, g, b = 95, 95, 95 --?% white
                        end

                        if exports.cr_dashboard:isPlayerInFactionType(v, 1) or exports.cr_dashboard:isPlayerInFactionType(v, 2) then 
                            -- triggerServerEvent("giveMessageToClient", localPlayer,  localPlayer, v, name.." mondja (rádióban): "..message, r,g,b, false, false, message)
                        end
                    end
                end
            end

            if exports["cr_dashboard"]:isPlayerInFactionType(v, 1) or exports.cr_dashboard:isPlayerInFactionType(v, 2) then 
                local r,g,b = 215, 86, 86

                local dutyFaction = element:getData("char >> duty")
                local prefix = ""
                local fullText = ""
                if dutyFaction then 
                    prefix = exports["cr_faction_scripts"]:getFactionPrefix(dutyFaction)
                    
                    local factionRank = exports["cr_dashboard"]:getPlayerFactionRankName(element, dutyFaction)
                    fullText = "["..prefix.."] "..factionRank.." "..name.." rádióban: "..message
                else 
                    prefix = ""
                    fullText = name.." rádióban: "..message
                end

                triggerServerEvent("giveMessageToClient", localPlayer,  localPlayer, v, fullText, r,g,b, false, false, false, true) 
            end 
        end
    elseif mtype == "megaphone >> speak" then 
        if localPlayer:getData("drunkSpeak") then
            message = generateRandomString(#message)
        end
        
        --local message
        if string.len(message) > 1 then
            message = string.upper(string.sub(message, 1, 1)) .. string.sub(message, 2, string.len(message))
        elseif string.len(message) < 1 or string.len(message) == 0 then
            return
        elseif string.sub(message, 1, 1) == " " then
            return    
        elseif string.len(message) > maxLength then
            return
        else
            message = string.upper(string.sub(message, 1, 1))
        end

        for k,v in pairs(emojis) do
            if string.upper(message):find(string.upper(string.gsub(string.lower(k), string.lower("%%"), "") ), 1, true) then
                onClientMessage(localPlayer, emojis[k][1], 1, true)
                if emojis[k][2] then
                    if not getPedOccupiedVehicle(localPlayer) then 
                        setElementData(localPlayer, "animation", emojis[k][2]); 
                        if isTimer(animationTimer) then killTimer(animationTimer) end
                        animationTimer = setTimer(
                            function()
                                localPlayer:setData("animation", {"", ""})
                            end, 3000, 1
                        )
                     end
                end
                --outputChatBox(message)
                --outputChatBox(k)
                local mes = string.gsub(string.lower(message), k, "") 
                local mes2 = string.gsub(mes, " ", "")
                if #mes2 <= 0 then
                    return
                else
                    message = mes
                end
            end
        end

        local name = exports['cr_admin']:getAdminName(element)

        spamTimer = setTimer(function() end, 300, 1)

        local x,y,z = getElementPosition(localPlayer)
        local int2 = getElementInterior(localPlayer)
        local dim2 = getElementDimension(localPlayer)
        if getElementData(localPlayer, "player >> recon") then
            local target = getElementData(localPlayer, "player >> recon >> target") or localPlayer
            x,y,z = getElementPosition(target)
            int, dim = getElementInterior(target), getElementDimension(target)
        end
        for k,v in pairs(getElementsByType("player", root, true)) do
            local int = getElementInterior(v)
            local dim = getElementDimension(v)
            local x1,y1,z1 = getElementPosition(v)
            if getElementData(v, "player >> recon") then
                local target = getElementData(v, "player >> recon >> target") or v
                x1,y1,z1 = getElementPosition(target)
                int, dim = getElementInterior(target), getElementDimension(target)
            end
            if int == int2 and dim == dim2 then
                local distance = math.floor(getDistanceBetweenPoints3D(x, y, z, x1, y1, z1))

                local veh2 = getPedOccupiedVehicle(v)
                --outputChatBox("WINDOWSTATE: " .. tostring(getElementData(veh, "veh >> windowState")))  
                if distance <= 35 then
                    local r, g, b = 254, 206, 1
                    --outputChatBox(distance)
                    -- if distance <= 2 then
                    --     r,g,b = 254, 206, 1
                    -- elseif distance <= 4 then
                    --     r,g,b = 254, 206, 1 --75% white
                    -- elseif distance <= 6 then
                    --     r,g,b = 254, 206, 1 --65% white
                    -- elseif distance <= 8 then
                    --     r, g, b = 254, 206, 1 --45% white
                    -- else
                    --     r, g, b = 254, 206, 1 --?% white
                    -- end

                    triggerServerEvent("giveMessageToClient", localPlayer,  localPlayer, v, name.." (Megaphone): "..message, r,g,b, false, false, message)
                end
            end
        end
    elseif mtype == "say >> phone" then
        if localPlayer:getData("drunkSpeak") then
            message = generateRandomString(#message)
        end
        
        --local message
        if string.len(message) > 1 then
            message = string.upper(string.sub(message, 1, 1)) .. string.sub(message, 2, string.len(message))
        elseif string.len(message) < 1 or string.len(message) == 0 then
            return
        elseif string.sub(message, 1, 1) == " " then
            return    
        elseif string.len(message) > maxLength then
            return
        else
            message = string.upper(string.sub(message, 1, 1))
        end

        for k,v in pairs(emojis) do
            if string.upper(message):find(string.upper(string.gsub(string.lower(k), string.lower("%%"), "") ), 1, true) then
                onClientMessage(localPlayer, emojis[k][1], 1, true)
                if emojis[k][2] then
                    if not getPedOccupiedVehicle(localPlayer) then 
                        setElementData(localPlayer, "animation", emojis[k][2]); 
                        if isTimer(animationTimer) then killTimer(animationTimer) end
                        animationTimer = setTimer(
                            function()
                                localPlayer:setData("animation", {"", ""})
                            end, 3000, 1
                        )
                     end
                end
                --outputChatBox(message)
                --outputChatBox(k)
                local mes = string.gsub(string.lower(message), k, "") 
                local mes2 = string.gsub(mes, " ", "")
                if #mes2 <= 0 then
                    return
                else
                    message = mes
                end
            end
        end

        local name = exports['cr_admin']:getAdminName(element)
        if not veh or not getElementData(veh, "veh >> windows >> closed") then
            outputChatBox(name.." mondja (telefonba): "..message, 255,255,255)
            if showMyBubbles then
                addBubble(localPlayer, message, 255, 255, 255)
            end
        else
            outputChatBox(name.." mondja (telefonba) (járműben): "..message, 255,255,255)
            if showMyBubbles then
                addBubble(localPlayer, message, 255, 255, 255)
            end
        end

        spamTimer = setTimer(function() end, 300, 1)

        local x,y,z = getElementPosition(localPlayer)
        local int2 = getElementInterior(localPlayer)
        local dim2 = getElementDimension(localPlayer)
        if getElementData(localPlayer, "player >> recon") then
            local target = getElementData(localPlayer, "player >> recon >> target") or localPlayer
            x,y,z = getElementPosition(target)
            int, dim = getElementInterior(target), getElementDimension(target)
        end
        for k,v in pairs(getElementsByType("player", root, true)) do
            local int = getElementInterior(v)
            local dim = getElementDimension(v)
            local x1,y1,z1 = getElementPosition(v)
            if getElementData(v, "player >> recon") then
                local target = getElementData(v, "player >> recon >> target") or v
                x1,y1,z1 = getElementPosition(target)
                int, dim = getElementInterior(target), getElementDimension(target)
            end
            if v ~= localPlayer and int == int2 and dim == dim2 then
                local distance = math.floor(getDistanceBetweenPoints3D(x, y, z, x1, y1, z1))

                local veh2 = getPedOccupiedVehicle(v)
                --outputChatBox("WINDOWSTATE: " .. tostring(getElementData(veh, "veh >> windowState")))
                if veh2 and veh and veh == veh2 then
                    local r,g,b = 255,255,255
                    if not getElementData(veh, "veh >> windows >> closed") then
                        triggerServerEvent("giveMessageToClient", localPlayer,  localPlayer, v, name.." mondja (telefonba): "..message, r,g,b, false, false, message)
                    else    
                        triggerServerEvent("giveMessageToClient", localPlayer,  localPlayer, v, name.." mondja (telefonba) (járműben): "..message, r,g,b, false, false, message)
                    end    
                elseif not veh and not veh2 or veh and not veh:getData("veh >> windows >> closed") and not veh2 or veh2 and not veh2:getData("veh >> windows >> closed") and not veh or veh and veh2 and not veh:getData("veh >> windows >> closed") and not veh2:getData("veh >> windows >> closed") then
                    if distance <= 8 then
                        local r,g,b = 255,255,255
                        --outputChatBox(distance)
                        if distance <= 2 then
                            r,g,b = 255,255,255
                        elseif distance <= 4 then
                            r,g,b = 191, 191, 191 --75% white
                        elseif distance <= 6 then
                            r,g,b = 166, 166, 166 --65% white
                        elseif distance <= 8 then
                            r, g, b = 115, 115, 115 --45% white
                        else
                            r, g, b = 95, 95, 95 --?% white
                        end

                        triggerServerEvent("giveMessageToClient", localPlayer,  localPlayer, v, name.." mondja (telefonba): "..message, r,g,b, false, false, message)
                    end
                end
            end
        end
    elseif mtype == 1 then
        --local message
        if string.len(message) > 1 then
            message = string.sub(message, 1, 1) .. string.sub(message, 2, string.len(message))
        elseif string.len(message) < 1 or string.len(message) == 0 then
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax .. "/me [Cselekvés]", 255,255,255,true)
            return
        elseif string.sub(message, 1, 1) == " " then
            return    
        elseif string.len(message) > maxLength then
            return
        else
            message = string.sub(message, 1, 1)
        end
        
        for k,v in pairs(emojis) do
            if string.upper(message):find(string.upper(string.gsub(string.lower(k), string.lower("%%"), "") ), 1, true) then
                onClientMessage(localPlayer, emojis[k][1], 1, true)
                if emojis[k][2] then
                    if not getPedOccupiedVehicle(localPlayer) then 
                        setElementData(localPlayer, "animation", emojis[k][2]); 
                        if isTimer(animationTimer) then killTimer(animationTimer) end
                        animationTimer = setTimer(
                            function()
                                localPlayer:setData("animation", {"", ""})
                            end, 3000, 1
                        )
                     end
                end
                --outputChatBox(message)
                --outputChatBox(k)
                local mes = string.gsub(string.lower(message), k, "") 
                local mes2 = string.gsub(mes, " ", "")
                if #mes2 <= 0 then
                    return
                else
                    message = mes
                end
            end
        end
        
        local name = exports['cr_admin']:getAdminName(element)
        outputChatBox(" *** "..name.." "..message, 194, 162, 218)
        local bubbleText = " *** "..message
        if showMyBubbles then
            addBubble(localPlayer, bubbleText, 194, 162, 218)
        end

        spamTimer = setTimer(function() end, 300, 1)

        local x,y,z = getElementPosition(localPlayer)
        local int2 = getElementInterior(localPlayer)
        local dim2 = getElementDimension(localPlayer)
        if getElementData(localPlayer, "player >> recon") then
            local target = getElementData(localPlayer, "player >> recon >> target") or localPlayer
            x,y,z = getElementPosition(target)
            int, dim = getElementInterior(target), getElementDimension(target)
        end
        for k,v in pairs(getElementsByType("player", root, true)) do
            local int = getElementInterior(v)
            local dim = getElementDimension(v)
            local x1,y1,z1 = getElementPosition(v)
            if getElementData(v, "player >> recon") then
                local target = getElementData(v, "player >> recon >> target") or v
                x1,y1,z1 = getElementPosition(target)
                int, dim = getElementInterior(target), getElementDimension(target)
            end
            if v ~= localPlayer and int == int2 and dim == dim2 then
                --local x1, y1, z1 = getElementPosition(v)
                local distance = math.floor(getDistanceBetweenPoints3D(x, y, z, x1, y1, z1))
                local veh2 = getPedOccupiedVehicle(v)
                if not veh or veh2 == veh or not veh:getData("veh >> windows >> closed") then
                    if distance <= 8 then
                        local r,g,b = 194, 162, 218
                        triggerServerEvent("giveMessageToClient", localPlayer,  localPlayer, v, " *** "..name.." "..message, r,g,b, false, false, bubbleText)
                    end
                end
            end
        end
    elseif mtype == "melow" then
        --local message
        if string.len(message) > 1 then
            message = string.sub(message, 1, 1) .. string.sub(message, 2, string.len(message))
        elseif string.len(message) < 1 or string.len(message) == 0 then
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax .. "/melow [Cselekvés]", 255,255,255,true)
            return
        elseif string.sub(message, 1, 1) == " " then
            return    
        elseif string.len(message) > maxLength then
            return
        else
            message = string.sub(message, 1, 1)
        end
        
        for k,v in pairs(emojis) do
            if string.upper(message):find(string.upper(string.gsub(string.lower(k), string.lower("%%"), "") ), 1, true) then
                onClientMessage(localPlayer, emojis[k][1], 1, true)
                if emojis[k][2] then
                    if not getPedOccupiedVehicle(localPlayer) then 
                        setElementData(localPlayer, "animation", emojis[k][2]); 
                        if isTimer(animationTimer) then killTimer(animationTimer) end
                        animationTimer = setTimer(
                            function()
                                localPlayer:setData("animation", {"", ""})
                            end, 3000, 1
                        )
                     end
                end
                --outputChatBox(message)
                --outputChatBox(k)
                local mes = string.gsub(string.lower(message), k, "") 
                local mes2 = string.gsub(mes, " ", "")
                if #mes2 <= 0 then
                    return
                else
                    message = mes
                end
            end
        end
        
        local name = exports['cr_admin']:getAdminName(element)
        outputChatBox("[LOW] *** "..name.." "..message, 194, 162, 218)
        local bubbleText = "[LOW] *** "..message
        if showMyBubbles then
            addBubble(localPlayer, bubbleText, 194, 162, 218)
        end

        spamTimer = setTimer(function() end, 300, 1)

        local x,y,z = getElementPosition(localPlayer)
        local int2 = getElementInterior(localPlayer)
        local dim2 = getElementDimension(localPlayer)
        if getElementData(localPlayer, "player >> recon") then
            local target = getElementData(localPlayer, "player >> recon >> target") or localPlayer
            x,y,z = getElementPosition(target)
            int, dim = getElementInterior(target), getElementDimension(target)
        end
        for k,v in pairs(getElementsByType("player", root, true)) do
            local int = getElementInterior(v)
            local dim = getElementDimension(v)
            local x1,y1,z1 = getElementPosition(v)
            if getElementData(v, "player >> recon") then
                local target = getElementData(v, "player >> recon >> target") or v
                x1,y1,z1 = getElementPosition(target)
                int, dim = getElementInterior(target), getElementDimension(target)
            end
            if v ~= localPlayer and int == int2 and dim == dim2 then
                --local x1, y1, z1 = getElementPosition(v)
                local distance = math.floor(getDistanceBetweenPoints3D(x, y, z, x1, y1, z1))
                local veh2 = getPedOccupiedVehicle(v)
                if not veh or veh2 == veh or not veh:getData("veh >> windows >> closed") then
                    if distance <= 4 then
                        local r,g,b = 194, 162, 218
                        triggerServerEvent("giveMessageToClient", localPlayer,  localPlayer, v, "[LOW] *** "..name.." "..message, r,g,b, false, false, bubbleText)
                    end
                end
            end
        end
    elseif mtype == "do" then
        --local message
        if string.len(message) > 1 then
            message = string.sub(message, 1, 1) .. string.sub(message, 2, string.len(message))
        elseif string.len(message) < 1 or string.len(message) == 0 then
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax .. "/do [Történés]", 255,255,255,true)
            return
        elseif string.sub(message, 1, 1) == " " then
            return    
        elseif string.len(message) > maxLength then
            return
        else
            message = string.sub(message, 1, 1)
        end
        
        for k,v in pairs(emojis) do
            if string.upper(message):find(string.upper(string.gsub(string.lower(k), string.lower("%%"), "") ), 1, true) then
                onClientMessage(localPlayer, emojis[k][1], 1, true)
                if emojis[k][2] then
                    if not getPedOccupiedVehicle(localPlayer) then 
                        setElementData(localPlayer, "animation", emojis[k][2]); 
                        if isTimer(animationTimer) then killTimer(animationTimer) end
                        animationTimer = setTimer(
                            function()
                                localPlayer:setData("animation", {"", ""})
                            end, 3000, 1
                        )
                     end
                end
                --outputChatBox(message)
                --outputChatBox(k)
                local mes = string.gsub(string.lower(message), k, "") 
                local mes2 = string.gsub(mes, " ", "")
                if #mes2 <= 0 then
                    return
                else
                    message = mes
                end
            end
        end

        message = message:gsub("^%l", string.upper)
        
        local name = exports['cr_admin']:getAdminName(element)
        outputChatBox(" * "..message.." (("..name.."))", 255, 51, 102)
        
        --outputChatBox("ASd")
        local bubbleText = " * "..message
        if showMyBubbles then
            addBubble(localPlayer, bubbleText, 255, 51, 102)
        end
        --end

        spamTimer = setTimer(function() end, 300, 1)

        local x,y,z = getElementPosition(localPlayer)
        local int2 = getElementInterior(localPlayer)
        local dim2 = getElementDimension(localPlayer)
        if getElementData(localPlayer, "player >> recon") then
            local target = getElementData(localPlayer, "player >> recon >> target") or localPlayer
            x,y,z = getElementPosition(target)
            int, dim = getElementInterior(target), getElementDimension(target)
        end
        for k,v in pairs(getElementsByType("player", root, true)) do
            local int = getElementInterior(v)
            local dim = getElementDimension(v)
            local x1,y1,z1 = getElementPosition(v)
            if getElementData(v, "player >> recon") then
                local target = getElementData(v, "player >> recon >> target") or v
                x1,y1,z1 = getElementPosition(target)
                int, dim = getElementInterior(target), getElementDimension(target)
            end
            if v ~= localPlayer and int == int2 and dim == dim2 then
                --local x1, y1, z1 = getElementPosition(v)
                local distance = math.floor(getDistanceBetweenPoints3D(x, y, z, x1, y1, z1))
                local veh2 = getPedOccupiedVehicle(v)
                if not veh or veh2 == veh or not veh:getData("veh >> windows >> closed") then
                    if distance <= 8 then
                        local r,g,b = 255, 51, 102
                        triggerServerEvent("giveMessageToClient", localPlayer,  localPlayer, v, " * "..message.." (("..name.."))", r,g,b, false, false, bubbleText)
                    end
                end
            end
        end
    elseif mtype == "dolow" then
        --local message
        if string.len(message) > 1 then
            message = string.sub(message, 1, 1) .. string.sub(message, 2, string.len(message))
        elseif string.len(message) < 1 or string.len(message) == 0 then
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax .. "/dolow [Történés]", 255,255,255,true)
            return
        elseif string.sub(message, 1, 1) == " " then
            return    
        elseif string.len(message) > maxLength then
            return
        else
            message = string.sub(message, 1, 1)
        end
        
        for k,v in pairs(emojis) do
            if string.upper(message):find(string.upper(string.gsub(string.lower(k), string.lower("%%"), "") ), 1, true) then
                onClientMessage(localPlayer, emojis[k][1], 1, true)
                if emojis[k][2] then
                    if not getPedOccupiedVehicle(localPlayer) then 
                        setElementData(localPlayer, "animation", emojis[k][2]); 
                        if isTimer(animationTimer) then killTimer(animationTimer) end
                        animationTimer = setTimer(
                            function()
                                localPlayer:setData("animation", {"", ""})
                            end, 3000, 1
                        )
                     end
                end
                --outputChatBox(message)
                --outputChatBox(k)
                local mes = string.gsub(string.lower(message), k, "") 
                local mes2 = string.gsub(mes, " ", "")
                if #mes2 <= 0 then
                    return
                else
                    message = mes
                end
            end
        end

        message = message:gsub("^%l", string.upper)
        
        local name = exports['cr_admin']:getAdminName(element)
        outputChatBox("[LOW] * "..message.." (("..name.."))", 255, 51, 102)
        
        --outputChatBox("ASd")
        local bubbleText = "[LOW] * "..message
        if showMyBubbles then
            addBubble(localPlayer, bubbleText, 255, 51, 102)
        end
        --end

        spamTimer = setTimer(function() end, 300, 1)

        local x,y,z = getElementPosition(localPlayer)
        local int2 = getElementInterior(localPlayer)
        local dim2 = getElementDimension(localPlayer)
        if getElementData(localPlayer, "player >> recon") then
            local target = getElementData(localPlayer, "player >> recon >> target") or localPlayer
            x,y,z = getElementPosition(target)
            int, dim = getElementInterior(target), getElementDimension(target)
        end
        for k,v in pairs(getElementsByType("player", root, true)) do
            local int = getElementInterior(v)
            local dim = getElementDimension(v)
            local x1,y1,z1 = getElementPosition(v)
            if getElementData(v, "player >> recon") then
                local target = getElementData(v, "player >> recon >> target") or v
                x1,y1,z1 = getElementPosition(target)
                int, dim = getElementInterior(target), getElementDimension(target)
            end
            if v ~= localPlayer and int == int2 and dim == dim2 then
                --local x1, y1, z1 = getElementPosition(v)
                local distance = math.floor(getDistanceBetweenPoints3D(x, y, z, x1, y1, z1))
                local veh2 = getPedOccupiedVehicle(v)
                if not veh or veh2 == veh or not veh:getData("veh >> windows >> closed") then
                    if distance <= 4 then
                        local r,g,b = 255, 51, 102
                        triggerServerEvent("giveMessageToClient", localPlayer,  localPlayer, v, "[LOW] * "..message.." (("..name.."))", r,g,b, false, false, bubbleText)
                    end
                end
            end
        end    
    elseif mtype == "ame" then
        --local message
        if string.len(message) > 1 then
            message = string.sub(message, 1, 1) .. string.sub(message, 2, string.len(message))
        elseif string.len(message) < 1 or string.len(message) == 0 then
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax .. "/ame [Karaktered vizuális leírása]", 255,255,255,true)
            return
        elseif string.sub(message, 1, 1) == " " then
            return    
        elseif string.len(message) > maxLength then
            return
        else
            message = string.sub(message, 1, 1)
        end
        
        for k,v in pairs(emojis) do
            if string.upper(message):find(string.upper(string.gsub(string.lower(k), string.lower("%%"), "") ), 1, true) then
                onClientMessage(localPlayer, emojis[k][1], 1, true)
                if emojis[k][2] then
                    if not getPedOccupiedVehicle(localPlayer) then 
                        setElementData(localPlayer, "animation", emojis[k][2]); 
                        if isTimer(animationTimer) then killTimer(animationTimer) end
                        animationTimer = setTimer(
                            function()
                                localPlayer:setData("animation", {"", ""})
                            end, 3000, 1
                        )
                     end
                end
                --outputChatBox(message)
                --outputChatBox(k)
                local mes = string.gsub(string.lower(message), k, "") 
                local mes2 = string.gsub(mes, " ", "")
                if #mes2 <= 0 then
                    return
                else
                    message = mes
                end
            end
        end

        local name = exports['cr_admin']:getAdminName(element)
        outputChatBox(" >> "..name.." "..message, 183, 146, 211)
        
        local bubbleText = " >> "..message
        if showMyBubbles then
            addBubble(localPlayer, bubbleText, 183, 146, 211)
        end

        spamTimer = setTimer(function() end, 300, 1)

        local x,y,z = getElementPosition(localPlayer)
        local int2 = getElementInterior(localPlayer)
        local dim2 = getElementDimension(localPlayer)
        if getElementData(localPlayer, "player >> recon") then
            local target = getElementData(localPlayer, "player >> recon >> target") or localPlayer
            x,y,z = getElementPosition(target)
            int, dim = getElementInterior(target), getElementDimension(target)
        end
        for k,v in pairs(getElementsByType("player", root, true)) do
            local int = getElementInterior(v)
            local dim = getElementDimension(v)
            local x1,y1,z1 = getElementPosition(v)
            if getElementData(v, "player >> recon") then
                local target = getElementData(v, "player >> recon >> target") or v
                x1,y1,z1 = getElementPosition(target)
                int, dim = getElementInterior(target), getElementDimension(target)
            end
            if v ~= localPlayer and int == int2 and dim == dim2 then
                --local x1, y1, z1 = getElementPosition(v)
                local distance = math.floor(getDistanceBetweenPoints3D(x, y, z, x1, y1, z1))
                local veh2 = getPedOccupiedVehicle(v)
                if not veh or veh2 == veh or not veh:getData("veh >> windows >> closed") then
                    if distance <= 8 then
                        local r,g,b = 183, 146, 211
                        triggerServerEvent("giveMessageToClient", localPlayer,  localPlayer, v, " >> "..name.." "..message, r,g,b, false, false, bubbleText)
                    end
                end
            end
        end
    elseif mtype == "amelow" then
        --local message
        if string.len(message) > 1 then
            message = string.sub(message, 1, 1) .. string.sub(message, 2, string.len(message))
        elseif string.len(message) < 1 or string.len(message) == 0 then
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax .. "/amelow [Karaktered vizuális leírása]", 255,255,255,true)
            return
        elseif string.sub(message, 1, 1) == " " then
            return    
        elseif string.len(message) > maxLength then
            return
        else
            message = string.sub(message, 1, 1)
        end
        
        for k,v in pairs(emojis) do
            if string.upper(message):find(string.upper(string.gsub(string.lower(k), string.lower("%%"), "") ), 1, true) then
                onClientMessage(localPlayer, emojis[k][1], 1, true)
                if emojis[k][2] then
                    if not getPedOccupiedVehicle(localPlayer) then 
                        setElementData(localPlayer, "animation", emojis[k][2]); 
                        if isTimer(animationTimer) then killTimer(animationTimer) end
                        animationTimer = setTimer(
                            function()
                                localPlayer:setData("animation", {"", ""})
                            end, 3000, 1
                        )
                     end
                end
                --outputChatBox(message)
                --outputChatBox(k)
                local mes = string.gsub(string.lower(message), k, "") 
                local mes2 = string.gsub(mes, " ", "")
                if #mes2 <= 0 then
                    return
                else
                    message = mes
                end
            end
        end

        local name = exports['cr_admin']:getAdminName(element)
        outputChatBox("[LOW] >> "..name.." "..message, 183, 146, 211)
        
        local bubbleText = "[LOW] >> "..message
        if showMyBubbles then
            addBubble(localPlayer, bubbleText, 183, 146, 211)
        end

        spamTimer = setTimer(function() end, 300, 1)

        local x,y,z = getElementPosition(localPlayer)
        local int2 = getElementInterior(localPlayer)
        local dim2 = getElementDimension(localPlayer)
        if getElementData(localPlayer, "player >> recon") then
            local target = getElementData(localPlayer, "player >> recon >> target") or localPlayer
            x,y,z = getElementPosition(target)
            int, dim = getElementInterior(target), getElementDimension(target)
        end
        for k,v in pairs(getElementsByType("player", root, true)) do
            local int = getElementInterior(v)
            local dim = getElementDimension(v)
            local x1,y1,z1 = getElementPosition(v)
            if getElementData(v, "player >> recon") then
                local target = getElementData(v, "player >> recon >> target") or v
                x1,y1,z1 = getElementPosition(target)
                int, dim = getElementInterior(target), getElementDimension(target)
            end
            if v ~= localPlayer and int == int2 and dim == dim2 then
                --local x1, y1, z1 = getElementPosition(v)
                local distance = math.floor(getDistanceBetweenPoints3D(x, y, z, x1, y1, z1))
                local veh2 = getPedOccupiedVehicle(v)
                if not veh or veh2 == veh or not veh:getData("veh >> windows >> closed") then
                    if distance <= 4 then
                        local r,g,b = 183, 146, 211
                        triggerServerEvent("giveMessageToClient", localPlayer,  localPlayer, v, "[LOW] >> "..name.." "..message, r,g,b, false, false, bubbleText)
                    end
                end
            end
        end
    elseif mtype == "shout" then
        if localPlayer:getData("drunkSpeak") then
            message = generateRandomString(#message)
        end
        
        --local message
        if string.len(message) > 1 then
            message = string.upper(string.sub(message, 1, 1)) .. string.sub(message, 2, string.len(message))
        elseif string.len(message) < 1 or string.len(message) == 0 then
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax .. "/s [Szöveg]", 255,255,255,true)
            return
        elseif string.sub(message, 1, 1) == " " then
            return    
        elseif string.len(message) > maxLength then
            return
        else
            message = string.upper(string.sub(message, 1, 1))
        end

        for k,v in pairs(emojis) do
            if string.upper(message):find(string.upper(string.gsub(string.lower(k), string.lower("%%"), "") ), 1, true) then
                onClientMessage(localPlayer, emojis[k][1], 1, true)
                if emojis[k][2] then
                    if not getPedOccupiedVehicle(localPlayer) then 
                        setElementData(localPlayer, "animation", emojis[k][2]); 
                        if isTimer(animationTimer) then killTimer(animationTimer) end
                        animationTimer = setTimer(
                            function()
                                localPlayer:setData("animation", {"", ""})
                            end, 3000, 1
                        )
                     end
                end
                --outputChatBox(message)
                --outputChatBox(k)
                local mes = string.gsub(string.lower(message), k, "") 
                local mes2 = string.gsub(mes, " ", "")
                if #mes2 <= 0 then
                    return
                else
                    message = mes
                end
            end
        end

        local name = exports['cr_admin']:getAdminName(element)
        local bubbleText = "ordítja: "..message
        if not veh or not getElementData(veh, "veh >> windows >> closed") then
            outputChatBox(name.." ordítja: "..message, 255,255,255)
            if showMyBubbles then
                addBubble(localPlayer, bubbleText, 255, 255, 255)
            end
        else
            outputChatBox(name.." ordítja (járműben): "..message, 255,255,255)
            if showMyBubbles then
                addBubble(localPlayer, bubbleText, 255, 255, 255)
            end
        end

        if tonumber(localPlayer:getData("options >> shoutanimation") or 0) == 1 then 
            localPlayer:setData("animation", {"on_lookers", "shout_01", 200 * #message,true,false,false,false})
            if isTimer(animationTimer) then killTimer(animationTimer) end
            animationTimer = setTimer(
                function()
                    localPlayer:setData("animation", {"", ""})
                end, 200 * #message, 1
            )
        end

        spamTimer = setTimer(function() end, 300, 1)

        local x,y,z = getElementPosition(localPlayer)
        local int2 = getElementInterior(localPlayer)
        local dim2 = getElementDimension(localPlayer)
        if getElementData(localPlayer, "player >> recon") then
            local target = getElementData(localPlayer, "player >> recon >> target") or localPlayer
            x,y,z = getElementPosition(target)
            int, dim = getElementInterior(target), getElementDimension(target)
        end
        for k,v in pairs(getElementsByType("player")) do
            local int = getElementInterior(v)
            local dim = getElementDimension(v)
            local x1,y1,z1 = getElementPosition(v)
            if getElementData(v, "player >> recon") then
                local target = getElementData(v, "player >> recon >> target") or v
                x1,y1,z1 = getElementPosition(target)
                int, dim = getElementInterior(target), getElementDimension(target)
            end
            if v ~= localPlayer and int == int2 and dim == dim2 then
                --local x1, y1, z1 = getElementPosition(v)
                local distance = math.floor(getDistanceBetweenPoints3D(x, y, z, x1, y1, z1))
                local veh2 = getPedOccupiedVehicle(v)
                if veh2 and veh and veh == veh2 then
                    local r,g,b = 255,255,255
                    if not getElementData(veh, "veh >> windows >> closed") then
                        triggerServerEvent("giveMessageToClient", localPlayer,  localPlayer, v, name.." ordítja: "..message, r,g,b, false, false, bubbleText)
                    else
                        triggerServerEvent("giveMessageToClient", localPlayer,  localPlayer, v, name.." ordítja (járműben): "..message, r,g,b, false, false, bubbleText)
                    end
                elseif distance <= 18 and not veh or distance <= 18 and not veh:getData("veh >> windows >> closed") then
                    local r,g,b = 255,255,255
                    --outputChatBox(distance)
                    if distance <= 4 then
                        r,g,b = 255,255,255
                    elseif distance <= 8 then
                        r,g,b = 191, 191, 191 --75% white
                    elseif distance <= 12 then
                        r,g,b = 166, 166, 166 --65% white
                    elseif distance <= 16 then
                        r, g, b = 115, 115, 115 --45% white
                    else
                        r, g, b = 95, 95, 95 --?% white
                    end
                    triggerServerEvent("giveMessageToClient", localPlayer,  localPlayer, v, name.." ordítja: "..message, r,g,b, false, false, bubbleText)
                elseif distance <= 4 and getElementData(veh, "veh >> windowState") then
                    local r,g,b = 255,255,255
                    --outputChatBox(distance)
                    if distance <= 2 then
                        r,g,b = 166, 166, 166
                    elseif distance <= 4 then
                        r,g,b = 115, 115, 115
                    end
                    triggerServerEvent("giveMessageToClient", localPlayer,  localPlayer, v, name.." ordítja (járműben): "..message, r,g,b, false, false, bubbleText)
                end
            end
        end
    elseif mtype == "c" then
        if localPlayer:getData("drunkSpeak") then
            message = generateRandomString(#message)
        end
        
        --local message
        if string.len(message) > 1 then
            message = string.upper(string.sub(message, 1, 1)) .. string.sub(message, 2, string.len(message))
        elseif string.len(message) < 1 or string.len(message) == 0 then
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax .. "/c [Szöveg]", 255,255,255,true)
            return
        elseif string.sub(message, 1, 1) == " " then
            return    
        elseif string.len(message) > maxLength then
            return
        else
            message = string.upper(string.sub(message, 1, 1))
        end

        for k,v in pairs(emojis) do
            if string.upper(message):find(string.upper(string.gsub(string.lower(k), string.lower("%%"), "") ), 1, true) then
                onClientMessage(localPlayer, emojis[k][1], 1, true)
                if emojis[k][2] then
                    if not getPedOccupiedVehicle(localPlayer) then 
                        setElementData(localPlayer, "animation", emojis[k][2]); 
                        if isTimer(animationTimer) then killTimer(animationTimer) end
                        animationTimer = setTimer(
                            function()
                                localPlayer:setData("animation", {"", ""})
                            end, 3000, 1
                        )
                     end
                end
                --outputChatBox(message)
                --outputChatBox(k)
                local mes = string.gsub(string.lower(message), k, "") 
                local mes2 = string.gsub(mes, " ", "")
                if #mes2 <= 0 then
                    return
                else
                    message = mes
                end
            end
        end

        local name = exports['cr_admin']:getAdminName(element)
        local bubbleText = "suttogja: "..message
        if not veh or not getElementData(veh, "veh >> windows >> closed") then
            outputChatBox(name.." suttogja: "..message, 255,255,255)
            if showMyBubbles then
                addBubble(localPlayer, bubbleText, 255, 255, 255)
            end
        else
            outputChatBox(name.." suttogja (járműben): "..message, 255,255,255)
            if showMyBubbles then
                addBubble(localPlayer, bubbleText, 255, 255, 255)
            end
        end

        playSound("files/ws.wav")

        spamTimer = setTimer(function() end, 300, 1)

        local x,y,z = getElementPosition(localPlayer)
        local int2 = getElementInterior(localPlayer)
        local dim2 = getElementDimension(localPlayer)
        if getElementData(localPlayer, "player >> recon") then
            local target = getElementData(localPlayer, "player >> recon >> target") or localPlayer
            x,y,z = getElementPosition(target)
            int, dim = getElementInterior(target), getElementDimension(target)
        end
        for k,v in pairs(getElementsByType("player", root, true)) do
            local int = getElementInterior(v)
            local dim = getElementDimension(v)
            local x1,y1,z1 = getElementPosition(v)
            if getElementData(v, "player >> recon") then
                local target = getElementData(v, "player >> recon >> target") or v
                x1,y1,z1 = getElementPosition(target)
                int, dim = getElementInterior(target), getElementDimension(target)
            end

            if v ~= localPlayer and int == int2 and dim == dim2 then
                --local x1, y1, z1 = getElementPosition(v)
                local distance = math.floor(getDistanceBetweenPoints3D(x, y, z, x1, y1, z1))
                local veh2 = getPedOccupiedVehicle(v)
                if veh2 and veh == veh2 then
                    local r,g,b = 255,255,255
                    if not getElementData(veh, "veh >> windows >> closed") then
                        triggerServerEvent("giveMessageToClient", localPlayer,  localPlayer, v, name.." suttogja (járműben): "..message, r,g,b, true, false, bubbleText)
                    else
                        triggerServerEvent("giveMessageToClient", localPlayer,  localPlayer, v, name.." suttogja (járműben): "..message, r,g,b, true, false, bubbleText)
                    end
                elseif distance <= 2 and not veh or distance <= 2 and not veh:getData("veh >> windows >> closed") then
                    local r,g,b = 255,255,255
                    --outputChatBox(distance)
                    if distance <= 2 then
                        r,g,b = 255,255,255
                    end
                    triggerServerEvent("giveMessageToClient", localPlayer,  localPlayer, v, name.." suttogja: "..message, r,g,b, true, false, bubbleText)
                end
            end
        end
    elseif mtype == "try2 >> success" then
        --local message
        if string.len(message) > 1 then
            message = string.sub(message, 1, 1) .. string.sub(message, 2, string.len(message))
        elseif string.len(message) < 1 or string.len(message) == 0 then
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax .. "/megpróbálja [Szöveg]", 255,255,255,true)
            return
        elseif string.sub(message, 1, 1) == " " then
            return    
        elseif string.len(message) > maxLength then
            return
        else
            message = string.sub(message, 1, 1)
        end

        if usedTryCommand then
            usedTryCommand = false 
            
            local now = getTickCount()
            local a = 5
            if now <= lastTryTick + (a * 60 * 1000) then
                --local syntax = getServerSyntax("Inventory", "warning")
                --outputChatBox(syntax .. "Csak "..a.." másodpercenként craftolhatsz!")
                exports['cr_infobox']:addBox("warning", "Csak "..a.." percenként használhatod ezt a parancsot!")
                return
            end
            lastTryTick = getTickCount()
        end
        
        for k,v in pairs(emojis) do
            if string.upper(message):find(string.upper(string.gsub(string.lower(k), string.lower("%%"), "") ), 1, true) then
                onClientMessage(localPlayer, emojis[k][1], 1, true)
                if emojis[k][2] then
                    if not getPedOccupiedVehicle(localPlayer) then 
                        setElementData(localPlayer, "animation", emojis[k][2]); 
                        if isTimer(animationTimer) then killTimer(animationTimer) end
                        animationTimer = setTimer(
                            function()
                                localPlayer:setData("animation", {"", ""})
                            end, 3000, 1
                        )
                     end
                end
                --outputChatBox(message)
                --outputChatBox(k)
                local mes = string.gsub(string.lower(message), k, "") 
                local mes2 = string.gsub(mes, " ", "")
                if #mes2 <= 0 then
                    return
                else
                    message = mes
                end
            end
        end
        
        local name = exports['cr_admin']:getAdminName(element)
        outputChatBox(" *** "..name.." megpróbálja "..message.." és sikerül neki!", 71, 209, 71)
        local bubbleText = " *** megpróbálja "..message.." és sikerül neki!"
        if showMyBubbles then
            addBubble(localPlayer, bubbleText, 71, 209, 71)
        end

        spamTimer = setTimer(function() end, 300, 1)

        local x,y,z = getElementPosition(localPlayer)
        local int2 = getElementInterior(localPlayer)
        local dim2 = getElementDimension(localPlayer)
        if getElementData(localPlayer, "player >> recon") then
            local target = getElementData(localPlayer, "player >> recon >> target") or localPlayer
            x,y,z = getElementPosition(target)
            int, dim = getElementInterior(target), getElementDimension(target)
        end
        for k,v in pairs(getElementsByType("player", root, true)) do
            local int = getElementInterior(v)
            local dim = getElementDimension(v)
            local x1,y1,z1 = getElementPosition(v)
            if getElementData(v, "player >> recon") then
                local target = getElementData(v, "player >> recon >> target") or v
                x1,y1,z1 = getElementPosition(target)
                int, dim = getElementInterior(target), getElementDimension(target)
            end
            if v ~= localPlayer and int == int2 and dim == dim2 then
                --local x1, y1, z1 = getElementPosition(v)
                local distance = math.floor(getDistanceBetweenPoints3D(x, y, z, x1, y1, z1))
                local veh2 = getPedOccupiedVehicle(v)
                if distance <= 8 then
                    local r,g,b = 71, 209, 71
                    triggerServerEvent("giveMessageToClient", localPlayer,  localPlayer, v, " *** "..name.." megpróbálja "..message.." és sikerül neki!", r,g,b, false, false, bubbleText)
                end
            end
        end
    elseif mtype == "try2 >> failed" then
        --local message
        if string.len(message) > 1 then
            message = string.sub(message, 1, 1) .. string.sub(message, 2, string.len(message))
        elseif string.len(message) < 1 or string.len(message) == 0 then
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax .. "/megpróbálja [Szöveg]", 255,255,255,true)
            return
        elseif string.sub(message, 1, 1) == " " then
            return    
        elseif string.len(message) > maxLength then
            return
        else
            message = string.sub(message, 1, 1)
        end

        if usedTryCommand then
            usedTryCommand = false 

            local now = getTickCount()
            local a = 5
            if now <= lastTryTick + (a * 60 * 1000) then
                --local syntax = getServerSyntax("Inventory", "warning")
                --outputChatBox(syntax .. "Csak "..a.." másodpercenként craftolhatsz!")
                exports['cr_infobox']:addBox("warning", "Csak "..a.." percenként használhatod ezt a parancsot!")
                return
            end
            lastTryTick = getTickCount()
        end
        
        for k,v in pairs(emojis) do
            if string.upper(message):find(string.upper(string.gsub(string.lower(k), string.lower("%%"), "") ), 1, true) then
                onClientMessage(localPlayer, emojis[k][1], 1, true)
                if emojis[k][2] then
                    if not getPedOccupiedVehicle(localPlayer) then 
                        setElementData(localPlayer, "animation", emojis[k][2]); 
                        if isTimer(animationTimer) then killTimer(animationTimer) end
                        animationTimer = setTimer(
                            function()
                                localPlayer:setData("animation", {"", ""})
                            end, 3000, 1
                        )
                     end
                end
                --outputChatBox(message)
                --outputChatBox(k)
                local mes = string.gsub(string.lower(message), k, "") 
                local mes2 = string.gsub(mes, " ", "")
                if #mes2 <= 0 then
                    return
                else
                    message = mes
                end
            end
        end
        
        local name = exports['cr_admin']:getAdminName(element)
        outputChatBox(" *** "..name.." megpróbálja "..message.." de sajnos nem sikerült neki!", 255, 51, 51)
        local bubbleText = " *** megpróbálja "..message.." de sajnos nem sikerült neki!"
        if showMyBubbles then
            addBubble(localPlayer, bubbleText, 255, 51, 51)
        end

        spamTimer = setTimer(function() end, 300, 1)

        local x,y,z = getElementPosition(localPlayer)
        local int2 = getElementInterior(localPlayer)
        local dim2 = getElementDimension(localPlayer)
        if getElementData(localPlayer, "player >> recon") then
            local target = getElementData(localPlayer, "player >> recon >> target") or localPlayer
            x,y,z = getElementPosition(target)
            int, dim = getElementInterior(target), getElementDimension(target)
        end
        for k,v in pairs(getElementsByType("player", root, true)) do
            local int = getElementInterior(v)
            local dim = getElementDimension(v)
            local x1,y1,z1 = getElementPosition(v)
            if getElementData(v, "player >> recon") then
                local target = getElementData(v, "player >> recon >> target") or v
                x1,y1,z1 = getElementPosition(target)
                int, dim = getElementInterior(target), getElementDimension(target)
            end
            if v ~= localPlayer and int == int2 and dim == dim2 then
                --local x1, y1, z1 = getElementPosition(v)
                local distance = math.floor(getDistanceBetweenPoints3D(x, y, z, x1, y1, z1))
                local veh2 = getPedOccupiedVehicle(v)
                if not veh or veh2 == veh or not veh:getData("veh >> windows >> closed") then
                    if distance <= 8 then
                        local r,g,b = 255, 51, 51
                        triggerServerEvent("giveMessageToClient", localPlayer,  localPlayer, v, " *** "..name.." megpróbálja "..message.." de sajnos nem sikerült neki!", r,g,b, false, false, bubbleText)
                    end
                end
            end
        end    
    elseif mtype == "try >> success" then
        --local message
        if string.len(message) > 1 then
            message = string.sub(message, 1, 1) .. string.sub(message, 2, string.len(message))
        elseif string.len(message) < 1 or string.len(message) == 0 then
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax .. "/megpróbál [Szöveg]", 255,255,255,true)
            return
        elseif string.sub(message, 1, 1) == " " then
            return    
        elseif string.len(message) > maxLength then
            return
        else
            message = string.sub(message, 1, 1)
        end

        if usedTryCommand then
            usedTryCommand = false 
            
            local now = getTickCount()
            local a = 5
            if now <= lastTryTick + (a * 60 * 1000) then
                --local syntax = getServerSyntax("Inventory", "warning")
                --outputChatBox(syntax .. "Csak "..a.." másodpercenként craftolhatsz!")
                exports['cr_infobox']:addBox("warning", "Csak "..a.." percenként használhatod ezt a parancsot!")
                return
            end
            lastTryTick = getTickCount()
        end 
        
        for k,v in pairs(emojis) do
            if string.upper(message):find(string.upper(string.gsub(string.lower(k), string.lower("%%"), "") ), 1, true) then
                onClientMessage(localPlayer, emojis[k][1], 1, true)
                if emojis[k][2] then
                    if not getPedOccupiedVehicle(localPlayer) then 
                        setElementData(localPlayer, "animation", emojis[k][2]); 
                        if isTimer(animationTimer) then killTimer(animationTimer) end
                        animationTimer = setTimer(
                            function()
                                localPlayer:setData("animation", {"", ""})
                            end, 3000, 1
                        )
                     end
                end
                --outputChatBox(message)
                --outputChatBox(k)
                local mes = string.gsub(string.lower(message), k, "") 
                local mes2 = string.gsub(mes, " ", "")
                if #mes2 <= 0 then
                    return
                else
                    message = mes
                end
            end
        end
        
        local name = exports['cr_admin']:getAdminName(element)
        outputChatBox(" *** "..name.." megpróbál "..message.." és sikerül neki!", 71, 209, 71)
        local bubbleText = " *** megpróbál "..message.." és sikerül neki!"
        if showMyBubbles then
            addBubble(localPlayer, bubbleText, 71, 209, 71)
        end

        spamTimer = setTimer(function() end, 300, 1)

        local x,y,z = getElementPosition(localPlayer)
        local int2 = getElementInterior(localPlayer)
        local dim2 = getElementDimension(localPlayer)
        if getElementData(localPlayer, "player >> recon") then
            local target = getElementData(localPlayer, "player >> recon >> target") or localPlayer
            x,y,z = getElementPosition(target)
            int, dim = getElementInterior(target), getElementDimension(target)
        end
        for k,v in pairs(getElementsByType("player", root, true)) do
            local int = getElementInterior(v)
            local dim = getElementDimension(v)
            local x1,y1,z1 = getElementPosition(v)
            if getElementData(v, "player >> recon") then
                local target = getElementData(v, "player >> recon >> target") or v
                x1,y1,z1 = getElementPosition(target)
                int, dim = getElementInterior(target), getElementDimension(target)
            end
            if v ~= localPlayer and int == int2 and dim == dim2 then
                --local x1, y1, z1 = getElementPosition(v)
                local distance = math.floor(getDistanceBetweenPoints3D(x, y, z, x1, y1, z1))
                local veh2 = getPedOccupiedVehicle(v)
                if not veh or veh2 == veh or not veh:getData("veh >> windows >> closed") then
                    if distance <= 8 then
                        local r,g,b = 71, 209, 71
                        triggerServerEvent("giveMessageToClient", localPlayer,  localPlayer, v, " *** "..name.." megpróbál "..message.." és sikerül neki!", r,g,b, false, false, bubbleText)
                    end
                end
            end
        end
    elseif mtype == "try >> failed" then
        --local message
        if string.len(message) > 1 then
            message = string.sub(message, 1, 1) .. string.sub(message, 2, string.len(message))
        elseif string.len(message) < 1 or string.len(message) == 0 then
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax .. "/megpróbál [Szöveg]", 255,255,255,true)
            return
        elseif string.sub(message, 1, 1) == " " then
            return    
        elseif string.len(message) > maxLength then
            return
        else
            message = string.sub(message, 1, 1)
        end

        if usedTryCommand then
            usedTryCommand = false 
            
            local now = getTickCount()
            local a = 5
            if now <= lastTryTick + (a * 60 * 1000) then
                --local syntax = getServerSyntax("Inventory", "warning")
                --outputChatBox(syntax .. "Csak "..a.." másodpercenként craftolhatsz!")
                exports['cr_infobox']:addBox("warning", "Csak "..a.." percenként használhatod ezt a parancsot!")
                return
            end
            lastTryTick = getTickCount()
        end
        
        for k,v in pairs(emojis) do
            if string.upper(message):find(string.upper(string.gsub(string.lower(k), string.lower("%%"), "") ), 1, true) then
                onClientMessage(localPlayer, emojis[k][1], 1, true)
                if emojis[k][2] then
                    if not getPedOccupiedVehicle(localPlayer) then 
                        setElementData(localPlayer, "animation", emojis[k][2]); 
                        if isTimer(animationTimer) then killTimer(animationTimer) end
                        animationTimer = setTimer(
                            function()
                                localPlayer:setData("animation", {"", ""})
                            end, 3000, 1
                        )
                    end
                end
                --outputChatBox(message)
                --outputChatBox(k)
                local mes = string.gsub(string.lower(message), k, "") 
                local mes2 = string.gsub(mes, " ", "")
                if #mes2 <= 0 then
                    return
                else
                    message = mes
                end
            end
        end
        
        local name = exports['cr_admin']:getAdminName(element)
        outputChatBox(" *** "..name.." megpróbál "..message.." de sajnos nem sikerült neki!", 255, 51, 51)
        local bubbleText = " *** megpróbál "..message.." de sajnos nem sikerült neki!"
        if showMyBubbles then
            addBubble(localPlayer, bubbleText, 255, 51, 51)
        end

        spamTimer = setTimer(function() end, 300, 1)

        local x,y,z = getElementPosition(localPlayer)
        local int2 = getElementInterior(localPlayer)
        local dim2 = getElementDimension(localPlayer)
        if getElementData(localPlayer, "player >> recon") then
            local target = getElementData(localPlayer, "player >> recon >> target") or localPlayer
            x,y,z = getElementPosition(target)
            int, dim = getElementInterior(target), getElementDimension(target)
        end
        for k,v in pairs(getElementsByType("player", root, true)) do
            local int = getElementInterior(v)
            local dim = getElementDimension(v)
            local x1,y1,z1 = getElementPosition(v)
            if getElementData(v, "player >> recon") then
                local target = getElementData(v, "player >> recon >> target") or v
                x1,y1,z1 = getElementPosition(target)
                int, dim = getElementInterior(target), getElementDimension(target)
            end
            if v ~= localPlayer and int == int2 and dim == dim2 then
                --local x1, y1, z1 = getElementPosition(v)
                local distance = math.floor(getDistanceBetweenPoints3D(x, y, z, x1, y1, z1))
                local veh2 = getPedOccupiedVehicle(v)
                if not veh or veh2 == veh or not veh:getData("veh >> windows >> closed") then
                    if distance <= 8 then
                        local r,g,b = 255, 51, 51
                        triggerServerEvent("giveMessageToClient", localPlayer,  localPlayer, v, " *** "..name.." megpróbál "..message.." de sajnos nem sikerült neki!", r,g,b, false, false, bubbleText)
                    end
                end
            end
        end
    elseif mtype == "ooc" then
        --local message
        
        --[[
        KELL MÉG BELE AZ ADMINDUTYS CUCC
        ]]
        
        if string.len(message) > maxLength then
            return
        elseif string.len(message) > 1 then
            message = string.sub(message, 1, 1) .. string.sub(message, 2, string.len(message))
        elseif string.len(message) < 1 or string.len(message) == 0 then
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax .. "/b [Szöveg]", 255,255,255,true)
            return
        elseif string.sub(message, 1, 1) == " " then
            return    
        else
            message = string.sub(message, 1, 1)
        end
        
        local name = exports['cr_admin']:getAdminName(element)
        local time = getRealTime()
        local time1 = time.hour
        if time1 < 10 then
            time1 = "0" .. tostring(time1)
        end
        local time2 = time.minute
        if time2 < 10 then
            time2 = "0" .. tostring(time2)
        end
        local time3 = time.second
        if time3 < 10 then
            time3 = "0" .. tostring(time3)
        end
        --local time = time1..":"..time2..":"..time3
        --outputChatBox("A"..message)
        local message = findSwear(message)
        --outputChatBox("B"..message)
        local time = ""
        insertOOC("(( "..name..": "..message.." ))", 0, localPlayer)

        spamTimer = setTimer(function() end, 300, 1)

        local x,y,z = getElementPosition(localPlayer)
        local int2 = getElementInterior(localPlayer)
        local dim2 = getElementDimension(localPlayer)
        if getElementData(localPlayer, "player >> recon") then
            local target = getElementData(localPlayer, "player >> recon >> target") or localPlayer
            x,y,z = getElementPosition(target)
            int, dim = getElementInterior(target), getElementDimension(target)
        end
        for k,v in pairs(getElementsByType("player", root, true)) do
            local int = getElementInterior(v)
            local dim = getElementDimension(v)
            local x1,y1,z1 = getElementPosition(v)
            if getElementData(v, "player >> recon") then
                local target = getElementData(v, "player >> recon >> target") or v
                x1,y1,z1 = getElementPosition(target)
                int, dim = getElementInterior(target), getElementDimension(target)
            end
            if v ~= localPlayer and int == int2 and dim == dim2 then
                --local x1, y1, z1 = getElementPosition(v)
                local distance = math.floor(getDistanceBetweenPoints3D(x, y, z, x1, y1, z1))
                local veh2 = getPedOccupiedVehicle(v)
                if distance <= 8 then
                    local r,g,b = 255, 255, 255
                    if exports['cr_admin']:getAdminDuty(localPlayer) then
                        r,g,b = 210,49,49
                    end
                    triggerServerEvent("giveMessageToClient", localPlayer,  localPlayer, v, "(( "..name..": "..message.." ))", r,g,b, false, true)
                end
            end
        end
    end
end
addEvent("onClientMessage", true)
addEventHandler("onClientMessage", root, onClientMessage)

function rePresentSay(cmd, ...)
    local text = table.concat({...}, " ")
    onClientMessage(localPlayer, text, 0)
end
addCommandHandler("Say", rePresentSay)
addCommandHandler("IC", rePresentSay)
addCommandHandler("Ic", rePresentSay)
addCommandHandler("ic", rePresentSay)
addCommandHandler("iC", rePresentSay)
addCommandHandler("SAY", rePresentSay)
addCommandHandler("saY", rePresentSay)
addCommandHandler("sAY", rePresentSay)
addCommandHandler("sAy", rePresentSay)

function rePresentMe(cmd, ...)
    local text = table.concat({...}, " ")
    onClientMessage(localPlayer, text, 1)
end
addCommandHandler("Me", rePresentMe)
addCommandHandler("me", rePresentMe)
addCommandHandler("ME", rePresentMe)
addCommandHandler("mE", rePresentMe)

function rePresentMeLow(cmd, ...)
    local text = table.concat({...}, " ")
    onClientMessage(localPlayer, text, "melow")
end
addCommandHandler("Melow", rePresentMeLow)
addCommandHandler("melow", rePresentMeLow)
addCommandHandler("MElow", rePresentMeLow)
addCommandHandler("mElow", rePresentMeLow)

function rePresentDo(cmd, ...)
    local text = table.concat({...}, " ")
    onClientMessage(localPlayer, text, "do")
end
addCommandHandler("Do", rePresentDo)
addCommandHandler("do", rePresentDo)
addCommandHandler("DO", rePresentDo)
addCommandHandler("dO", rePresentDo)

function rePresentDoLow(cmd, ...)
    local text = table.concat({...}, " ")
    onClientMessage(localPlayer, text, "dolow")
end
addCommandHandler("Dolow", rePresentDoLow)
addCommandHandler("dolow", rePresentDoLow)
addCommandHandler("DOlow", rePresentDoLow)
addCommandHandler("dOlow", rePresentDoLow)

function rePresentAme(cmd, ...)
    local text = table.concat({...}, " ")
    onClientMessage(localPlayer, text, "ame")
end
addCommandHandler("AME", rePresentAme)
addCommandHandler("aMe", rePresentAme)
addCommandHandler("Ame", rePresentAme)
addCommandHandler("aME", rePresentAme)
addCommandHandler("AMe", rePresentAme)
addCommandHandler("ame", rePresentAme)

function rePresentAmeLow(cmd, ...)
    local text = table.concat({...}, " ")
    onClientMessage(localPlayer, text, "amelow")
end
addCommandHandler("AMElow", rePresentAmeLow)
addCommandHandler("aMelow", rePresentAmeLow)
addCommandHandler("Amelow", rePresentAmeLow)
addCommandHandler("aMElow", rePresentAmeLow)
addCommandHandler("AMelow", rePresentAmeLow)
addCommandHandler("amelow", rePresentAmeLow)

function rePresentShout(cmd, ...)
    local text = table.concat({...}, " ")
    onClientMessage(localPlayer, text, "shout")
end
addCommandHandler("s", rePresentShout)
addCommandHandler("S", rePresentShout)
addCommandHandler("Shout", rePresentShout)
addCommandHandler("shout", rePresentShout)

function rePresentC(cmd, ...)
    local text = table.concat({...}, " ")
    onClientMessage(localPlayer, text, "c")
end
addCommandHandler("c", rePresentC)
addCommandHandler("C", rePresentC)

lastTryTick = -(5 * 60 * 1000) - 1000 
function rePresentTry(cmd, ...)    
    local text = table.concat({...}, " ")
    local rand = math.random(1,2) 

    usedTryCommand = true
    if rand == 1 then
        onClientMessage(localPlayer, text, "try >> success")
    else
        onClientMessage(localPlayer, text, "try >> failed")
    end
end
addCommandHandler("try", rePresentTry)
addCommandHandler("Try", rePresentTry)
addCommandHandler("megprobal", rePresentTry)
addCommandHandler("Megprobal", rePresentTry)
addCommandHandler("Megpróbál", rePresentTry)
addCommandHandler("megpróbál", rePresentTry)

function rePresentTry2(cmd, ...)
    local text = table.concat({...}, " ")
    local rand = math.random(1,2) 

    usedTryCommand = true
    if rand == 1 then
        onClientMessage(localPlayer, text, "try2 >> success")
    else
        onClientMessage(localPlayer, text, "try2 >> failed")
    end
end
addCommandHandler("try2", rePresentTry2)
addCommandHandler("Try2", rePresentTry2)
addCommandHandler("megprobalja", rePresentTry2)
addCommandHandler("Megprobalja", rePresentTry2)
addCommandHandler("Megpróbálja", rePresentTry2)
addCommandHandler("megpróbálja", rePresentTry2)

addEvent("chat -- receive", true)
addEventHandler("chat -- receive", root,
    function(e, message, r,g,b, whisper, ooc, sElement, radio)
        if e == localPlayer then    
            if ooc then
                --outputChatBox(message, r,g,b)
                insertOOC(message, 0, sElement)
            else
                outputChatBox(message, r,g,b)
            end

            if radio then 
                playSound("files/radio.mp3")
            end 

            if whisper then
                playSound("files/ws.wav")
            end
        end
    end
)

addEventHandler("onClientResourceStart", resourceRoot,
    function()
        --outputChatBox("asd")
        --unbindKey("b", "down", "chatbox", "OOC")
        --bindKey("t", "down", "chatbox", "Say")
        bindKey("b", "down", "chatbox", "OOC")
        bindKey("y", "down", "chatbox", "Rádió")
        --unbindKey("y", "down", "chatbox", "Rádió")
    end
)

function useOOC(cmd, ...)
    local text = table.concat({...}, " ")
    onClientMessage(localPlayer, text, "ooc")
end
addCommandHandler("b", useOOC)
addCommandHandler("B", useOOC)
addCommandHandler("OOC", useOOC)
addCommandHandler("ooc", useOOC)
addCommandHandler("Ooc", useOOC)
addCommandHandler("OoC", useOOC)

function rePresentRadio(cmd, ...)
    if localPlayer:getData("usingRadio") then 
        local text = table.concat({...}, " ")
        onClientMessage(localPlayer, text, "radio >> speak")
    end 
end
addCommandHandler("r", rePresentRadio)
addCommandHandler("R", rePresentRadio)
addCommandHandler("radio", rePresentRadio)
addCommandHandler("Radio", rePresentRadio)
addCommandHandler("Rádió", rePresentRadio)

function rePresentFactionRadio(cmd, ...)
    if localPlayer:getData("loggedIn") then 
        if exports["cr_dashboard"]:isPlayerInFactionType(localPlayer, 1) or exports.cr_dashboard:isPlayerInFactionType(v, 2) then 
            local text = table.concat({...}, " ")
            onClientMessage(localPlayer, text, "factionRadio >> speak")
        end
    end
end
addCommandHandler("d", rePresentFactionRadio, false, false)

function rePresentMegaphone(cmd, ...)
    if localPlayer:getData("loggedIn") then 
        local allowedVehicles = exports.cr_mdc:getAllowedVehicles()
        local vehicle = localPlayer.vehicle
        local text = table.concat({...}, " ")

        if localPlayer:getData("char >> megaphoneInHand") or (vehicle and allowedVehicles[vehicle.model]) then 
            local seat = localPlayer.vehicleSeat

            if seat then 
                if seat == 0 or seat == 1 then 
                    onClientMessage(localPlayer, text, "megaphone >> speak")
                else
                    if localPlayer:getData("char >> megaphoneInHand") then 
                        onClientMessage(localPlayer, text, "megaphone >> speak")
                    else
                        local syntax = exports.cr_core:getServerSyntax(false, "error")
                        outputChatBox(syntax .. "Csak a sofőr és az anyósülésről tudod használni a fedélzeti megafont!", 255, 0, 0, true)
                    end
                end
            else
                onClientMessage(localPlayer, text, "megaphone >> speak")
            end
        else 
            local syntax = exports.cr_core:getServerSyntax(false, "error")
            outputChatBox(syntax .. "Nincs a kezedben megafon.", 255, 0, 0, true)
        end
    end
end
addCommandHandler("m", rePresentMegaphone, false, false)

function insertOOC(message, typ, p)
    triggerEvent("onOOCMessageSend", localPlayer, message, typ, p)
end

local swears = {
    --
    {"fos"},
    {"f**"},
    {"f*s"},
    {"fo*"},
    --
    {"kurva"},
    {"k*rva"},
    {"ku*va"},
    {"kur*a"},
    {"kurv*"},
    --
    {"anyád"},
    {"anyad"},
    {"any*d"},
    {"*ny*d"},
    {"any*d"},
    --
    {"hülye"},
    {"hulye"},
    {"h*lye"},
    {"h*ly*"},
    {"hüje"},
    {"huje"},
    {"h*je"},
    {"h*j*"},
    {"hűlye"},
    {"hűje"},
    --
    {"szar"},
    {"sz*r"},
    {"sz**"},
    {"sza*"},
    --
    {"faszfej"},
    {"foszfej"},
    {"fasz fej"},
    {"fosz fej"},
    --
    {"fasszopo"},
    {"faszopo"},
    --
    {"mocskos"},
    {"m*cskos"},
    --
    {"dögölnél"},
    {"dogolnel"},
    --
    {"fasz"},
    {"fassz"},
    {"fsz"},
    {"fosz"},
    {"f*sz"},
    {"fa**"},
    --
    {"pina"},
    {"pna"},
    {"puna"},
    {"p*na"},
    {"pi**"},
    --
    {"punci"},
    {"p*nci"},
    --
    {"gci"},
    {"geci"},
    {"g*ci"},
    {"ge*i"},
    {"gecci"},
    {"gacci"},
    --
    {"tetves"},
    {"tötves"},
    {"t*tves"},
    --
    {"noob"},
    {"nob"},
    {"n**b"},
    {"n*b"},
    --
    {"balfasz"},
    {"b*lfasz"},
    --
    {"csicska"},
    {"cs*cska"},
    {"cscska"},
    --
    {"nyomorék"},
    {"nyomorek"},
    {"nyomor*k"},
    {"nyomorult"},
    {"nyomorúlt"},
    --
    {"csíra"},
    {"csira"},
    {"csra"},
    {"cs*ra"},
    --
    {"bazdmeg"},
    {"bozdmeg"},
    {"b*zdmeg"},
    {"b*zdm*g"},
    --
    {"bazd"},
    {"b*zd"},
    {"bzd"},
    --
    {"buzi"},
    {"b*zi"},
    {"bzi"},
    --[[
    {"see", true},
    {"látás", true},
    {"hl", true},
    {"hungary", true},
    {"life", true},
    {"avrp", true},
    {"fine", true},
    {"replay", true},
    {"social", true},
    {"gaming", true},
    {"mta", true},
    {"fly", true},
    {"owl", true},
    {"lv", true},
    {"v2", true},
    {"v3", true},
    {"v4", true},
    {"las venturas", true},]]
}

local stars = "**************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************"

function findSwear(msg)
    local syntax = exports['cr_core']:getServerSyntax("Chat", "error")
    local color = exports['cr_core']:getServerColor("red", true)
    local color2 = exports['cr_core']:getServerColor(nil, true)
    local white = "#ffffff"
    local without = msg
    local strF = without
    for k,v in pairs(swears) do
        local swear = v[1]
        local last = 1
        --outputChatBox("asd1")
        --outputChatBox(swear)
        while true do
            local a, b = without:lower():find(swear:lower(), last, true)
            if a or b then
                if not v[2] then
                    --outputChatBox(syntax .. "Tiltott "..color.."szót"..white.." használtál! ("..color..swear..white..")", 255,255,255,true)
                end

                --local aName = exports['cr_admin']:getAdminName(localPlayer)
                --local text = color2 .. aName .. white .. " tiltott szót használt! ("..color..swear..white..")"
                --exports['cr_core']:sendMessageToAdmin(localPlayer, syntax .. text, 3)

                local str = without:sub(1, a - 1)
                str = str .. stars:sub(1, #swear)
                str = str .. without:sub(b + 1, #without)

                without = str
                last = b + 1
            else
                break
            end
        end
    end
    
    return without
end

function findSwearIC(msg)
    local syntax = exports['cr_core']:getServerSyntax("Chat", "error")
    local color = exports['cr_core']:getServerColor("red", true)
    local color2 = exports['cr_core']:getServerColor(nil, true)
    local white = "#ffffff"
    local without = msg
    local strF = without
    for k,v in pairs(swears) do
        if v[2] then
            local swear = v[1]
            local last = 1
            --outputChatBox("asd1")
            --outputChatBox(swear)
            while true do
                local a, b = without:lower():find(swear:lower(), last, true)
                if a or b then
                    if not v[2] then
                        --outputChatBox(syntax .. "Tiltott "..color.."szót"..white.." használtál! ("..color..swear..white..")", 255,255,255,true)
                    end

                    --local aName = exports['cr_admin']:getAdminName(localPlayer)
                    --local text = color2 .. aName .. white .. " tiltott szót használt! ("..color..swear..white..")"
                    --exports['cr_core']:sendMessageToAdmin(localPlayer, syntax .. text, 3)

                    local str = without:sub(1, a - 1)
                    str = str .. stars:sub(1, #swear)
                    str = str .. without:sub(b + 1, #without)

                    without = str
                    last = b + 1
                else
                    break
                end
            end
        end
    end
    
    return without
end
--findSwear("see anyád")