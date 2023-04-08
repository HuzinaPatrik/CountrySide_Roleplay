local cache = {}

addEventHandler("onClientResourceStart", resourceRoot, 
    function()
        for k,v in pairs(getElementsByType("object", _, true)) do 
            if v:getData("placedo >> id") then 
                cache[v] = {
                    ["owner"] = v:getData("placedo >> owner"), 
                    ["text"] = v:getData("placedo >> text"),
                }
            end 
        end 
    end 
)

addEventHandler("onClientElementStreamIn", resourceRoot, 
    function()
        if source:getData("placedo >> id") then 
            cache[source] = {
                ["owner"] = source:getData("placedo >> owner"), 
                ["text"] = source:getData("placedo >> text"),
            }
        end 
    end 
)

addEventHandler("onClientElementStreamOut", resourceRoot, 
    function()
        if cache[source] then 
            cache[source] = nil 

            collectgarbage("collect")
        end 
    end 
)

lastClickTick = -1000
addCommandHandler("placedo", 
    function(cmd, ...)
        local text = table.concat({...}, " ")
        if not text or #text <= 10 then 
            local syntax = exports['cr_core']:getServerSyntax(nil, "warning")
            outputChatBox(syntax .. "/"..cmd.." [Szöveg]", 255, 255, 255, true)
            return 
        end 

        local now = getTickCount()
        local a = 1
        if now <= lastClickTick + a * 1000 then
            return
        end

        lastClickTick = getTickCount()

        local text = exports['cr_core']:getTime() .. " " .. text .. " (" .. exports['cr_admin']:getAdminName(localPlayer) .. ")"

        local a = 50
        text = addCharToString(text, a, "\n", math.floor(#text / a))

        triggerLatentServerEvent("createPlacedo", 5000, false, localPlayer, localPlayer, text)
    end 
)

setTimer(
    function()
        local cameraX, cameraY, cameraZ = getCameraMatrix()

        for k,v in pairs(cache) do
            if isElement(k) then
                local boneX, boneY, boneZ = getElementPosition(k)
                if isElementOnScreen(k) then
                    cache[k]["sightLine"] = isLineOfSightClear(cameraX, cameraY, cameraZ, boneX, boneY, boneZ, true, false, false, true, false, false, false, localPlayer)
                    cache[k]["distance"] = math.sqrt((cameraX - boneX) ^ 2 + (cameraY - boneY) ^ 2 + (cameraZ - boneZ) ^ 2)
                    cache[k]["text"] = k:getData("placedo >> text")
                    cache[k]["gText"] = string.gsub(k:getData("placedo >> text"), "#%x%x%x%x%x%x", "")
                    cache[k]["owner"] = k:getData("placedo >> owner")
                    cache[k]["hasPerm"] = k:getData("placedo >> owner") == localPlayer:getData("acc >> id") or exports['cr_permission']:hasPermission(localPlayer, "deleteplacedo")
                    if k:getData("placedo >> editing") then 
                        cache[k]["hasPerm"] = false 
                    end 
                end
            else 
                cache[k] = nil
            end 
        end
    end, 150, 0
)

renderCache = {}
local renderState

setTimer(
    function()
        local cache = cache
        renderCache = {}

        for k,v in pairs(cache) do
            if isElement(k) and isElementStreamedIn(k) then
                local sightLine = v["sightLine"]
                if sightLine then
                    renderCache[k] = v
                end
            end
        end

        for k,v in pairs(renderCache) do 
            if not renderState then 
                renderState = true 
                createRender("drawnPlacedo", drawnPlacedo)
            end 

            return 
        end 

        if renderState then 
            renderState = false
            destroyRender("drawnPlacedo")
        end 
    end, 100, 0
)

local maxDistance = 32
function drawnPlacedo()
    local font = exports['cr_fonts']:getFont("Roboto", 11) 

    moveHover = nil
    deleteHover = nil 
    for element, value in pairs(renderCache) do
        if not isElement(element) then 
            cache[element] = nil
            renderCache[element] = nil 

            collectgarbage("collect")

            return
        end 

        local boneX, boneY, boneZ = getElementPosition(element)

        local distance = value["distance"]
        if distance <= maxDistance then
            local size = 1 - (distance / maxDistance)
            local screenX, screenY = getScreenFromWorldPosition(boneX, boneY, boneZ)
            if screenX and screenY then
                local alpha = 255*size

                dxDrawText(value["gText"],screenX+1,0+1,screenX+1,screenY+1,tocolor(0, 0, 0, alpha),size, font, "center", "bottom", false, false, false, true, true)
                dxDrawText(value["text"],screenX,0,screenX,screenY,tocolor(255, 51, 102, alpha),size, font, "center", "bottom", false, false, false, true, true)

                if distance <= maxDistance * 0.25 then
                    local hasPerm = value["hasPerm"]
                    if hasPerm then 
                        local w, h = 25 * size, 25 * size
                        if exports['cr_core']:isInSlot(screenX - w - 2.5, screenY, w, h) then 
                            moveHover = element
                            dxDrawImage(screenX - w - 2.5, screenY, w, h, "assets/images/resize.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
                        else 
                            dxDrawImage(screenX - w - 2.5, screenY, w, h, "assets/images/resize.png", 0, 0, 0, tocolor(255, 255, 255, math.min(120, alpha)))
                        end 

                        if exports['cr_core']:isInSlot(screenX + 2.5, screenY, w, h) then 
                            deleteHover = element
                            dxDrawImage(screenX + 2.5, screenY, w, h, "assets/images/delete.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
                        else 
                            dxDrawImage(screenX + 2.5, screenY, w, h, "assets/images/delete.png", 0, 0, 0, tocolor(255, 255, 255, math.min(120, alpha)))
                        end 
                    end 
                end 
            end 
        end 
    end 
end 

addEventHandler("onClientElementDataChange", root, 
    function(dName, oValue, nValue)
        if dName == "placedo >> editing" then 
            if nValue then 
                if oValue and isElement(oValue) and nValue == localPlayer then 
                    source:setData(dName, oValue)

                    if editingState then 
                        editingState = false 
                        exports['cr_elementeditor']:quitEditor(true)
                    end 

                    return 
                end 

                if nValue == localPlayer then 
                    if not editingState then 
                        editingState = true 

                        exports['cr_elementeditor']:toggleEditor(source, "placedoSaveTrigger", "placedoRemoveTrigger", true)
                    end 
                end 
            end 
        end 
    end 
)

addEvent("placedoSaveTrigger", true)
addEventHandler("placedoSaveTrigger", localPlayer, 
    function(e, x, y, z)
        if editingState then 
            e:setData("placedo >> editing", nil)
            
            editingState = false 

            triggerLatentServerEvent("updatePlacedoPosition", 5000, false, localPlayer, localPlayer, e, x, y, z)
        end 
    end 
)

addEvent("placedoRemoveTrigger", true)
addEventHandler("placedoRemoveTrigger", localPlayer, 
    function(e)
        if editingState then 
            e:setData("placedo >> editing", nil)

            editingState = false 
        end 
    end 
)

addEventHandler("onClientClick", root, 
    function(b, s)
        if b == "left" and s == "down"  then 
            if deleteHover then 
                local now = getTickCount()
                local a = 1
                if now <= lastClickTick + a * 1000 then
                    return
                end

                lastClickTick = getTickCount()

                triggerLatentServerEvent("deletePlacedo", 5000, false, localPlayer, deleteHover:getData("placedo >> id"))
                deleteHover = nil 
                return 
            elseif moveHover then 
                local now = getTickCount()
                local a = 1
                if now <= lastClickTick + a * 1000 then
                    return
                end

                lastClickTick = getTickCount()

                if not moveHover:getData("placedo >> editing") then 
                    moveHover:setData("placedo >> editing", localPlayer)
                end 

                moveHover = nil 
                return 
            end 
        end 
    end 
)

local maxDistNearby = 18
function getNearbyPlacedo(cmd)
    if exports['cr_permission']:hasPermission(localPlayer, "getnearbyplacedo") then
        local target = false
        local px, py, pz = getElementPosition(localPlayer)
        local green = exports['cr_core']:getServerColor("orange", true)
        local syntax = exports['cr_core']:getServerSyntax("Placedo", "info")
        local white = "#ffffff"
        local hasVeh = false
        for k,v in pairs(getElementsByType("object", _, true)) do
            local x,y,z = getElementPosition(v)
            local dist = getDistanceBetweenPoints3D(x,y,z,px,py,pz)
            if dist <= maxDistNearby then
                local id = getElementData(v, "placedo >> id") or 0
                if id > 0 then
                    outputChatBox(syntax.."ID: "..green..id..white..", Távolság: "..green..math.floor(dist)..white.." yard", 255,255,255,true)
                    hasVeh = true
                end
            end
        end

        if not hasVeh then
            local green = exports['cr_core']:getServerColor("orange", true)
            local syntax = exports['cr_core']:getServerSyntax("Placedo", "error")
            outputChatBox(syntax .. "Nincs placedo a közeledben!", 255,255,255,true)
        end
    end
end
addCommandHandler("getnearbyplacedo", getNearbyPlacedo)
addCommandHandler("getnearbyPlacedo", getNearbyPlacedo)
addCommandHandler("getNearbyPlaceDo", getNearbyPlacedo)
addCommandHandler("getnearbyplaceDo", getNearbyPlacedo)

--
function addCharToString(str, pos, chr, howMany, origPos)
    if howMany == 0 then return str end
    if not origPos then origPos = pos end
    local stringVariation = str:sub(1, pos) .. chr .. str:sub(pos + 1)
    howMany = howMany - 1
    return addCharToString(stringVariation, pos + origPos, chr, howMany, origPos)
end