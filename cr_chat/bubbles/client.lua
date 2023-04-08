local showTime = 6
local bubbles = {}
--[[
Tábla felépítése:
bubbles = {element, text, {r,g,b}, id}
]]
local bubblesID = 0
local maxBubbles = 10

local showBubbles = true
local renderCache = {}
showMyBubbles = false

function setBubbles(val)
    showBubbles = val == 1
    if showBubbles then 
        createRender("drawnBubbles", drawnBubbles)
    else 
        destroyRender("drawnBubbles")
    end 
end 

function setMyBubbles(val)
    showMyBubbles = val == 1
    for k, v in pairs(bubbles) do
        local element, text, r,g,b,a, id, length, anim, startTick, showTime = unpack(v)
        if element == localPlayer then
            removeText(element, text)
        end
    end
end 
localPlayer:setData("enableBubbles", true)

addEventHandler("onClientElementDataChange", root,
    function(dName, oValue, nValue)
        if dName == "enableBubbles" then
            if not nValue then
                if isElementStreamedIn(source) then
                    for k, v in pairs(bubbles) do
                        local element, text, r,g,b,a, id, length, anim, startTick, showTime = unpack(v)
                        if element == source then
                            removeText(element, text)
                        end
                    end
                end
            end
        end
    end
)
function addBubble(element, text, r,g,b)
    if not element:getData("enableBubbles") then return end
    
    local bubblesL = 0
    local _gD
    for k, v in pairs(bubbles) do
        if v[1] == element then
            bubblesL = bubblesL + 1
            if v[7] == maxBubbles then
                _gD = k
            end
        end
    end
    
    if bubblesL >= maxBubbles and _gD then 
        table.remove(bubbles, _gD) 
        generateRenderCache()
        generateRenderCache2()
    end
    
    local element, text, r,g,b = element, text, r, g, b
    local flood = false
    
    if element.vehicle and element.vehicle:getData("veh >> windows >> closed") and localPlayer.vehicle ~= element.vehicle then
        return
    end
    
    if localPlayer.vehicle and localPlayer.vehicle:getData("veh >> windows >> closed") and localPlayer.vehicle ~= element.vehicle then
        return
    end
    
    if #text > 120 then
        return
    end
    
    --[[
    for k,v in pairs(bubbles) do
        if v[2] == text then
            flood = true
            return
        end
    end]]
    
    for k,v in pairs(bubbles) do
        if v[1] == element then
            bubbles[k][7] = bubbles[k][7] + 1
        end
    end
    
    --if flood then return end --antiflood
    
    font = exports['cr_fonts']:getFont("Poppins-Regular", 12)
    fontsize = 1
    local length = dxGetTextWidth(text, 1, font, true) + 10
    local showTime = #text * 200
    
    if element == localPlayer then
        localPlayer:setData("bubbleOn", true)
        if isTimer(deactivateTimer) then killTimer(deactivateTimer) end
        deactivateTimer = setTimer(
            function()
                localPlayer:setData("bubbleOn", false)
            end, showTime + 2000, 1
        )
    end
    
    local tableToRecord = {element, text, r,g,b,255, 1, length, "start", getTickCount(), showTime}
    table.insert(bubbles, tableToRecord)
    
    generateRenderCache()
    generateRenderCache2()
    --[[
    setTimer(
        function()
            for k,v in pairs(bubbles) do
                if v[1] == element and v[2] == text then
                    bubbles[k][9] = "shading"
                    return
                end
            end
        end, showTime * 1000, 1
    )]]
    --outputChatBox("asd")
end
addEvent("addBubble", true)
addEventHandler("addBubble", root, addBubble)

function removeText(element, text)
    local id
    
    for k,v in pairs(bubbles) do
        if v[1] == element and v[2] == text then
            id = v[7]
            table.remove(bubbles, k)
            break
        end
    end
    
    if id then
        for k,v in pairs(bubbles) do
            if v[1] == element and id <= bubbles[k][7] then
                bubbles[k][7] = bubbles[k][7] - 1
            end
        end
    end
    
    generateRenderCache()
    generateRenderCache2()
end

local animSpeed = 2
local maxDistance = 42

if multipable then
    multipler = 1
end

function generateRenderCache()
    --renderCache = {}
    local px,py,pz = getElementPosition(localPlayer)
    local cameraX, cameraY, cameraZ = getCameraMatrix()
    local int2 = getElementInterior(localPlayer)
    local dim2 = getElementDimension(localPlayer)
    for k,v in pairs(bubbles) do
        local _k = k
        local k, text, r,g,b,a, id, length, anim, startTick, showTime = unpack(v)
        if isElement(k) then
            local boneX, boneY, boneZ = getPedBonePosition(k, 5)
            boneZ = boneZ + 0.5
            if isElementOnScreen(k) then
                bubbles[_k]["sightLine"] = isLineOfSightClear(cameraX, cameraY, cameraZ, boneX, boneY, boneZ, true, false, false, true, false, false, false, localPlayer)
                bubbles[_k]["distance"] = math.sqrt((cameraX - boneX) ^ 2 + (cameraY - boneY) ^ 2 + (cameraZ - boneZ) ^ 2)
                bubbles[_k]["alpha"] = k.alpha >= 255
            end
        else
            table.remove(bubbles, _k)
        end
    end
end
setTimer(generateRenderCache, 150, 0)

function generateRenderCache2()
    renderCache = {}
    local int2 = getElementInterior(localPlayer)
    local dim2 = getElementDimension(localPlayer)
    for k,v in pairs(bubbles) do
        local _k = k
        local k, text, r,g,b,a, id, length, anim, startTick, showTime = unpack(v)
        local dim1 = getElementDimension(k)
        local int1 = getElementInterior(k)
        if isElement(k) and isElementStreamedIn(k) and dim1 == dim2 and int1 == int2 then
            if v["alpha"] then
                --boneZ = boneZ + 0.2
                local sightLine = v["sightLine"]
                if anames then
                    sightLine = true
                end
                if sightLine then
                    renderCache[_k] = v
                end
            end
        else
            table.remove(bubbles, _k)
        end
    end
end
setTimer(generateRenderCache2, 50, 0)

function drawnBubbles()
    local nowTick = getTickCount()
    font = exports['cr_fonts']:getFont("Poppins-Regular", 12)
    
    for k,v in pairs(renderCache) do
        local element, text, r,g,b,a, id, length, anim, startTick, showTime = unpack(v)
        
        if not isElement(element) then
            removeText(element, text)
        end
        local distance = v["distance"]
        if distance < 0 then
            distance = 0
        end
        local boneX, boneY, boneZ = getPedBonePosition(element, 5)
        if distance < maxDistance then
            local size = 1 - (distance / maxDistance)
            local sx, sy = getScreenFromWorldPosition(boneX, boneY, boneZ + (0.5 * size))
            if element.vehicle and element.vehicle:getData("veh >> windows >> closed") and localPlayer.vehicle ~= element.vehicle then
                removeText(element, text)
                return
            end
            
            if element.vehicle and element.vehicle:getData("veh >> windows >> closed") and localPlayer.vehicle ~= element.vehicle then
                removeText(element, text)
                return
            end
            if sx and sy and not veh then
                local _sy = sy -- - ((40 * id) * size)
                local syDiff = ((40 * id) * size)

                local wMultipler = 0
                if anim == "start" then
                    local elapsedTime = nowTick - startTick
                    local duration = (startTick + 1000) - startTick
                    local progress = elapsedTime / duration
                    local alph, syNow = interpolateBetween(
                        0, 0, 0,
                        255, syDiff, 0,
                        progress, "InOutQuad"
                    )

                    a = alph
                    sy = _sy - syNow

                    if progress >= 1 then
                        if bubbles[k] then
                            bubbles[k][6] = 255
                            bubbles[k][9] = "showing"
                            bubbles[k][10] = getTickCount()
                        end
                    end
                    
                    wMultipler = 1
                elseif anim == "showing" then
                    local elapsedTime = nowTick - startTick
                    local duration = (startTick + (showTime)) - startTick
                    local progress = elapsedTime / duration
                    local alph = 255
                    local syNow = syDiff
                    
                    a = alph
                    sy = _sy - syNow

                    if progress >= 1 then
                        if bubbles[k] then
                            bubbles[k][9] = "shading"
                            bubbles[k][10] = getTickCount()
                        end
                    end
                    
                    wMultipler = 1 - progress
                elseif anim == "shading" then
                    local elapsedTime = nowTick - startTick
                    local duration = (startTick + 1000) - startTick
                    local progress = elapsedTime / duration
                    local alph, syNow = interpolateBetween(
                        255, syDiff, 0,
                        0, 0, 0,
                        progress, "InOutQuad"
                    )

                    a = alph
                    sy = _sy - syNow

                    if progress >= 1 then
                        a = 0
                        if bubbles[k] then
                            bubbles[k][6] = 0
                            bubbles[k][9] = "normal"
                        end
                        
                        removeText(element, text)
                    end
                end
                local alpha = a
                local length = length * size
                local nb = 20 * size
                local _a = 2 * size
                local x, y = sx - (length/2) - _a,  sy - _a
                local w, h = length + (_a * 2), nb + (_a * 2)
                dxDrawRectangle(x, y, w, h, tocolor(51, 51, 51, alpha * 0.8))
                local lr, lg, lb = exports['cr_core']:getServerColor("yellow")
                if r == 255 and g == 51 and b == 102 then
                    lr, lg, lb = exports['cr_core']:getServerColor("red")
                elseif r == 255 and g == 51 and b == 51 then
                    lr, lg, lb = exports['cr_core']:getServerColor("red")
                elseif r == 71 and g == 209 and b == 71 then
                    lr, lg, lb = exports['cr_core']:getServerColor("green")
                end
                dxDrawLine(x, y + h, x + ((w) * wMultipler), y + h, tocolor(lr, lg, lb,math.min(alpha, 255 * 0.5)), 2)
                dxDrawText(text, sx, sy, sx, sy + nb, tocolor(r,g,b,alpha),size, font, "center", "bottom", false, false, false, true, true)
            end
        end
    end
end

addEventHandler("onClientPlayerQuit", root,
    function()
        if bubbles[source] then
            for k,v in pairs(bubbles) do
                local element, text, r,g,b,a, id, length, anim, startTick, showTime = unpack(v)
                if element == source then
                    removeText(element, source)
                end
            end
        end
    end
)

addEventHandler("onClientElementStreamOut", root,
    function()
        if bubbles[source] then
            for k,v in pairs(bubbles) do
                local element, text, r,g,b,a, id, length, anim, startTick, showTime = unpack(v)
                if element == source then
                    removeText(element, source)
                end
            end
        end
    end
)