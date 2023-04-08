renderTimers = {}

function createRender(id, func)
    if not isTimer(renderTimers[id]) then
        renderTimers[id] = setTimer(func, 5, 0)
    end
end

function destroyRender(id)
    if isTimer(renderTimers[id]) then
        killTimer(renderTimers[id])
        renderTimers[id] = nil
        collectgarbage("collect")
    end
end

local cache = {}
local soundCache = {}
local sx, sy = guiGetScreenSize()
local font = dxCreateFont("files/font.ttf", 12)

exports['cr_controls']:toggleControl('radio_next', false, "instant")
exports['cr_controls']:toggleControl('radio_previous', false, "instant")
exports['cr_controls']:toggleControl('radio_user_track_skip', false, "instant")

function startRadio()
    if localPlayer.vehicle then
        local veh = localPlayer.vehicle
        if getVehicleType(veh) == "Automobile" or getVehicleType(veh) == "Plane" or getVehicleType(veh) == "Monster Truck" then
            if not start then
                _gVeh = localPlayer.vehicle
                exports['cr_interface']:setNode("radio", "active", true)
                multiplier = tonumber(veh:getData("radio >> volume") or 1)
                channel = tonumber(veh:getData("radio >> channel") or 1)
                moving = nil
                start = true
                startTick = getTickCount()
                --addEventHandler("onClientRender", root, drawnRadio, true, "low-5")
                createRender("drawnRadio", drawnRadio)
            else
                start = false
                startTick = getTickCount()
                --resetRadioName()
            end
        end
    end
end
bindKey("r", "down", startRadio)

hunChars = {
    ["á"] = "a",
    ["é"] = "e",
    ["ő"] = "o",
    ["ó"] = "o",
    ["ö"] = "o",
    ["ú"] = "u",
    ["ü"] = "u",
    ["ű"] = "u",
    ["í"] = "i",
}

setTimer(
    function()
        if start then
            if localPlayer.vehicle:getData("radio >> enabled") then
                if not soundCache[localPlayer.vehicle] then
                    streamVehicle(localPlayer.vehicle)
                end
                
                local channel = tonumber(localPlayer.vehicle:getData("radio >> channel") or 1)
                local channelName = channels[channel][1]
                local details = getSoundMetaTags(soundCache[localPlayer.vehicle])
                local musicName = details["title"]
                if not musicName then
                    musicName = details["stream_title"]
                    if not musicName then
                        musicName = "Ismeretlen zene cím"
                    end
                end
                
                if #musicName <= 5 then
                    musicName = "Ismeretlen zene cím"
                end
                
                for k,v in pairs(hunChars) do
                    musicName = utf8.gsub(musicName, k, v)
                    musicName = utf8.gsub(musicName, utf8.upper(k), utf8.upper(v))
                end
                
                local st = ""
                for k in string.gmatch(musicName, "%w+") do
                    st = st .. " " .. k
                end
                musicName = st
                
                local txt = channelName .. " >> " .. musicName
                
                if radioText ~= txt then
                    --oText = txt
                    radioText = txt

                    startTickCount = getTickCount()
                    animState = "right"
                end
            end
        end
    end, 500, 0
)

local spaceText = "                                                                                                                                                                                                                                                                                                                   "
startAnimation = "InOutQuad"
startAnimationTime = 250 -- / 1000 = 0.2 másodperc
function drawnRadio()
    local alpha
    local nowTick = getTickCount()
    if start then
        local elapsedTime = nowTick - startTick
        local duration = (startTick + startAnimationTime) - startTick
        local progress = elapsedTime / duration
        local alph = interpolateBetween(
            0, 0, 0,
            255, 0, 0,
            progress, startAnimation
        )
        
        alpha = alph
    else
        
        local elapsedTime = nowTick - startTick
        local duration = (startTick + startAnimationTime) - startTick
        local progress = elapsedTime / duration
        local alph = interpolateBetween(
            255, 0, 0,
            0, 0, 0,
            progress, startAnimation
        )
        
        alpha = alph
        
        if progress >= 1 then
            if isTimer(updateTimer) then killTimer(updateTimer) end
            exports['cr_interface']:setNode("radio", "active", false)
            --removeEventHandler("onClientRender", root, drawnRadio)
            destroyRender("drawnRadio")
        end
    end
    
    local w, h = 501, 122
    if not localPlayer.vehicle then
        if start then
            clearSoundCache(_gVeh)
            start = false
            startTick = getTickCount()
        end
    end
    
    local sx, sy = exports['cr_interface']:getNode("radio", "x"), exports['cr_interface']:getNode("radio", "y")
    
    dxDrawImage(sx, sy, w, h, "files/bg.png", 0,0,0, tocolor(255,255,255,alpha))
    local w2,h2 = 270, 6
    _gX, _gY, _gW, _gH = sx + 116, sy + 59, w2, h2
    
    if moving then
        if isCursorShowing() then
            if getKeyState("mouse1") then
                local cx, cy = exports['cr_core']:getCursorPosition()
                local a = (cx - _gX) / _gW
                if a ~= multiplier then
                    multiplier = math.max(math.min(a, 1), 0)
                    if soundCache[localPlayer.vehicle] then
                        soundCache[localPlayer.vehicle].volume = multiplier
                    end

                    if isTimer(updateTimer) then killTimer(updateTimer) end
                    updateTimer = setTimer(
                        function()
                            localPlayer.vehicle:setData("radio >> volume", multiplier)
                        end, 250, 1
                    )
                end
            end
        else
            moving = false
        end
    end
    
    local w2 = w2 * multiplier
    dxDrawImageSection(sx + 116, sy + 59, w2, h2, 0, 0, w2, h2, "files/line.png", 0,0,0, tocolor(255,255,255,alpha))
    local w3, h3 = 13, 13
    dxDrawImage(sx + 116 + w2 - w3/2, sy + 59 + h2/2 - h3/2, w3, h3, "files/pin.png", 0,0,0, tocolor(255,255,255,alpha))
    
    --dxDrawRectangle(sx + w/2 - 280/2, sy + 19, 280, 27)
    
    if soundCache[localPlayer.vehicle] then
        local b = 5
        local a = (271 / b)
        local bt = getSoundFFTData(soundCache[localPlayer.vehicle],8192,(a) + 1)
        local startX = sx + w/2 - 270/2
        if bt then
            for i=1,a do
                bt[i] = (math.sqrt(bt[i]) * (256/10)) * multiplier --scale it (sqrt to make low values more visible)
                dxDrawRectangle(startX, sy + 19 + 27, b, -bt[i], tocolor(156, 156, 156, alpha))
                startX = startX + b
            end
        end
    end
    
    hover = nil
    if exports['cr_core']:isInSlot(sx + w/2 - 280/2, sy + h - 48, 30, 30) then
        hover = "left"
    elseif exports['cr_core']:isInSlot(sx + w/2 - 280/2 + 35, sy + h - 48, 30, 30) then
        hover = "stop"
    elseif exports['cr_core']:isInSlot(sx + w/2 - 280/2 + 35 + 35, sy + h - 48, 30, 30) then
        hover = "start"
    elseif exports['cr_core']:isInSlot(sx + w/2 - 280/2 + 35 + 35 + 35, sy + h - 48, 30, 30) then
        hover = "right"
    end
    
    --dxDrawRectangle(sx + w/2 - 280/2 + 135, sy + h - 45, 145, 28)
    
    ---
    local x,y,w,h = sx + w/2 - 280/2 + 135, sy + h - 45, 143, 28
    --DrawRectangle(x, y, w, h)
    local r,g,b = 255, 59, 59
    local tWidth2 = dxGetTextWidth(" ", 1, font, true)
    local radioName = radioText and string.upper(radioText)
    
    if radioName then
        local tWidth = dxGetTextWidth(radioName, 1, font, true) + 10
        local need = tWidth - w
        local text = ""
        local spaces
        --outputChatBox(tWidth)
        --outputChatBox(w)
        if need - 10 > 0 then
            --outputChatBox("asd")
            spaces = (need / tWidth2)
            if spaces ~= math.floor(spaces) then
                --percent = ((percent / maxColumns) + (math.ceil(percent / maxColumns) - (percent / maxColumns))) * maxColumns
                spaces = math.floor(spaces)
            end
        end

        if spaces then
            if animState == "right" then
                local elapsedTime = nowTick - startTickCount
                local duration = (startTickCount + (#radioName * 150)) - startTickCount
                local progress = elapsedTime / duration
                local alph = interpolateBetween(
                    spaces, 0, 0,
                    -spaces, 0, 0,
                    progress, "Linear"
                )

                local spaces = alph --spaces
                text = spaceText:sub(1, math.abs(spaces))

                if progress >= 1.5 then
                    startTickCount = getTickCount()
                    animState = "left"
                end

                if spaces >= 0 then
                    dxDrawText(text .. radioName .. "°", x, y, x + w, y + h, tocolor(r,g,b,alpha), 1, font, "center", "center", true)
                elseif spaces <= 0 then
                    dxDrawText(radioName .. text .. "°", x, y, x + w, y + h, tocolor(r,g,b,alpha), 1, font, "center", "center", true)
                end
            elseif animState == "left" then
                local elapsedTime = nowTick - startTickCount
                local duration = (startTickCount + (#radioName * 150)) - startTickCount
                local progress = elapsedTime / duration
                local alph = interpolateBetween(
                    -spaces, 0, 0,
                    spaces, 0, 0,
                    progress, "Linear"
                )

                spaces = alph --spaces / 2
                text = spaceText:sub(1, math.abs(spaces))

                if progress >= 2 then
                    startTickCount = getTickCount()
                    animState = "right"
                end
                --outputChatBox(spaces)

                if spaces >= 0 then
                    dxDrawText(text .. radioName .. "°", x, y, x + w, y + h, tocolor(r,g,b,alpha), 1, font, "center", "center", true)
                elseif spaces <= 0 then
                    dxDrawText(radioName .. text .. "°", x, y, x + w, y + h, tocolor(r,g,b,alpha), 1, font, "center", "center", true)
                end
            end
        else
            dxDrawText(radioName, x, y, x + w, y + h, tocolor(r,g,b,alpha), 1, font, "left", "center", true)
        end

        --outputChatBox(spaces)
        --outputChatBox(text)
        --dxDrawText("KARAKTER LÉTREHOZÁS" .. text, 500, 500, 500 + 100, 500 + 40, tocolor(r,g,b,alpha), 1, font, "right", "center", true)
        --dxDrawRectangle(sx + w/2 - 280/2, sy + h - 48, 280, 30)
    end
end

local lastClickTick = 0
addEventHandler("onClientClick", root,
    function(b, s)
        if b == "left" and s == "down" then
            if start then
                if hover then
                    if lastClickTick + 500 > getTickCount() then
                        return
                    end
                    lastClickTick = getTickCount()
                    
                    if localPlayer.vehicleSeat <= 1 then
                        if hover == "left" then
                            if not localPlayer.vehicle:getData("radio >> enabled") then return end
                            local channel = tonumber(localPlayer.vehicle:getData("radio >> channel") or 1)
                            if channel - 1 >= 1 then
                                playSound("files/button.mp3")
                                localPlayer.vehicle:setData("radio >> channel", channel - 1)
                                
                                setElementData(localPlayer, "animation", {"", ""})
                                setElementData(localPlayer, "animation", {"PED", "Car_tune_radio"})
                                radioText = nil
                            end
                        elseif hover == "right" then
                            if not localPlayer.vehicle:getData("radio >> enabled") then return end
                            local channel = tonumber(localPlayer.vehicle:getData("radio >> channel") or 1)
                            if channels[channel + 1] then
                                playSound("files/button.mp3")
                                localPlayer.vehicle:setData("radio >> channel", channel + 1)
                                
                                setElementData(localPlayer, "animation", {"", ""})
                                setElementData(localPlayer, "animation", {"PED", "Car_tune_radio"})
                                radioText = nil
                            end
                        elseif hover == "start" then
                            if not localPlayer.vehicle:getData("radio >> enabled") then
                                localPlayer.vehicle:setData("radio >> enabled", true)
                                playSound("files/button.mp3")
                                exports['cr_chat']:createMessage(localPlayer, "bekapcsolja egy jármű rádióját", 1)
                                
                                setElementData(localPlayer, "animation", {"", ""})
                                setElementData(localPlayer, "animation", {"PED", "Car_tune_radio"})
                                radioText = nil
                            end                            
                        elseif hover == "stop" then
                            if localPlayer.vehicle:getData("radio >> enabled") then
                                localPlayer.vehicle:setData("radio >> enabled", false)
                                playSound("files/button.mp3")
                                exports['cr_chat']:createMessage(localPlayer, "kikapcsolja egy jármű rádióját", 1)
                                
                                setElementData(localPlayer, "animation", {"", ""})
                                setElementData(localPlayer, "animation", {"PED", "Car_tune_radio"})
                                radioText = nil
                            end
                        end
                    end
                    hover = nil
                end
            end
        end
    end
)

addEventHandler("onClientClick", root,
    function(b,s)
        if b == "left" and s == "down" then
            if start then
                if exports['cr_core']:isInSlot(_gX, _gY, _gW, _gH) then
                    if localPlayer.vehicleSeat <= 1 then
                        moving = true  
                    end
                end
            end
        elseif b == "left" and s == "up" then
            if moving then
                moving = false
            end
        end
    end
)

addEventHandler("onClientElementDestroy", root,
    function()
        local v = source
        if v.type == "vehicle" then
            clearSoundCache(v)
            
            if v == localPlayer.vehicle then
                if v:getData("veh >> windows >> closed") then
                    for k,v in pairs(getElementsByType("vehicle", _, true)) do
                        if k ~= source then
                            streamVehicle(v)
                        end
                    end
                end
            end
        end
    end
)

function clearSoundCache(v)
    if soundCache[v] then
        local e = soundCache[v]
        e:destroy()
        soundCache[v] = nil
    end
end

function streamVehicle(v)
    clearSoundCache(v)

    if exports['cr_dashboard']:getOption('streamerMode') == 0 then 
        if v:getData("radio >> enabled") then
            if localPlayer.vehicle == v then -- beül
                local channel = tonumber(v:getData("radio >> channel") or 1)
                local volume = tonumber(v:getData("radio >> volume") or 1)
                if not channels[channel] then
                    v:setData("radio >> channel", 1)
                    channel = 1
                end
                
                local url = channels[channel][2]
                local sound = playSound(url)
                soundCache[v] = sound
                setTimer(setSoundVolume, 50, 1, sound, volume)
            else -- nem az övé
                if localPlayer.vehicle then -- kocsiból
                    if localPlayer.vehicle:getData("veh >> windows >> closed") then -- az ő ablaka van felhúzva
                        return
                    elseif v:getData("veh >> windows >> closed") then -- a másik ablaka van felhúzva
                        return
                    end

                    local channel = tonumber(v:getData("radio >> channel") or 1)
                    local volume = tonumber(v:getData("radio >> volume") or 1)
                    if not channels[channel] then
                        v:setData("radio >> channel", 1)
                        channel = 1
                    end
                    
                    local url = channels[channel][2]
                    
                    local sound = playSound3D(url, v.position)
                    soundCache[v] = sound
                    setTimer(setSoundVolume, 50, 1, sound, volume)
                    setTimer(setSoundMaxDistance, 50, 1, sound, 40)
                    setTimer(attachElements, 50, 1, sound, v)
                else
                    if v:getData("veh >> windows >> closed") then -- a másik ablaka van felhúzva
                        return
                    end

                    local channel = tonumber(v:getData("radio >> channel") or 1)
                    local volume = tonumber(v:getData("radio >> volume") or 1)
                    if not channels[channel] then
                        v:setData("radio >> channel", 1)
                        channel = 1
                    end

                    local url = channels[channel][2]
                    local sound = playSound3D(url, v.position)
                    soundCache[v] = sound
                    setTimer(setSoundVolume, 50, 1, sound, volume)
                    setTimer(setSoundMaxDistance, 50, 1, sound, 40)
                    setTimer(attachElements, 50, 1, sound, v)
                end
            end
        end
    end 
end

function deSyncAllVehicles()
    if exports['cr_dashboard']:getOption('streamerMode') == 1 then 
        for k,v in pairs(getElementsByType("vehicle", _, true)) do
            clearSoundCache(v)
        end
    end 
end 

function syncAllVehicles()
    if exports['cr_dashboard']:getOption('streamerMode') == 0 then 
        for k,v in pairs(getElementsByType("vehicle", _, true)) do
            streamVehicle(v)
        end
    end 
end 

addEventHandler("onClientResourceStart", resourceRoot,
    function()
        for k,v in pairs(getElementsByType("vehicle", _, true)) do
            streamVehicle(v)
        end
    end
)

addEventHandler("onClientVehicleEnter", root,
    function(thePlayer, seat)
        if thePlayer == localPlayer then
            radioText = ""
            streamVehicle(source)
            
            if source:getData("veh >> windows >> closed") then
                for k,v in pairs(soundCache) do
                    if k ~= source then
                        clearSoundCache(k)
                    end
                end
            end
        end
    end
)

addEventHandler("onClientVehicleExit", root,
    function(thePlayer, seat)
        if thePlayer == localPlayer then
            radioText = ""
            streamVehicle(source)
            
            if source:getData("veh >> windows >> closed") then
                for k,v in pairs(getElementsByType("vehicle", _, true)) do
                    if v ~= source then
                        streamVehicle(v)
                    end
                end
            end
        end
    end
)

addEventHandler("onClientElementStreamIn", root,
    function()
        if source.type == "vehicle" then
            streamVehicle(source)
        end
    end
)

addEventHandler("onClientElementStreamOut", root,
    function()
        if source.type == "vehicle" then
            clearSoundCache(source)
        end
    end
)

addEventHandler("onClientElementDataChange", root,
    function(dName, oValue, nValue)
        if dName == "radio >> volume" then
            if isElementStreamedIn(source) then
                if soundCache[source] then
                    soundCache[source].volume = nValue
                    
                    if source == localPlayer.vehicle then
                        multiplier = tonumber(source:getData("radio >> volume") or 1)
                    end
                end    
            end
        elseif dName == "radio >> enabled" then
            if isElementStreamedIn(source) then
                if source == localPlayer.vehicle then
                    radioText = ""
                end
                
                if nValue then
                    streamVehicle(source)
                else
                    clearSoundCache(source)
                end
            end
        elseif dName == "radio >> channel" then
            if isElementStreamedIn(source) then
                if source == localPlayer.vehicle then
                    radioText = ""
                end
                
                streamVehicle(source)
            end
        elseif dName == "veh >> windows >> closed" then
            if isElementStreamedIn(source) then
                if nValue then
                    if localPlayer.vehicle and localPlayer.vehicle == source then 
                        for k,v in pairs(soundCache) do
                            if k ~= source then
                                clearSoundCache(k)
                            end
                        end
                    end 

                    streamVehicle(source)
                else
                    if localPlayer.vehicle and localPlayer.vehicle == source then 
                        for k,v in pairs(getElementsByType("vehicle", _, true)) do
                            if v ~= source then
                                streamVehicle(v)
                            end
                        end
                    end 

                    streamVehicle(source)
                end
            end
        end
    end
)