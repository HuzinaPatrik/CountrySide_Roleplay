local objectCache = {}
local renderState

function checkRender(a)
    if a:lower() == "on" then
        if not renderState then
            renderState = true
            createRender("renderHealth", renderHealth)
        end
    elseif a:lower() == "off" then
        if renderState then
            renderState = false
            destroyRender("renderHealth")
        end
    end
end

addEventHandler("onClientResourceStart", resourceRoot,
    function()
        for k,v in pairs(getElementsByType("object", _, true)) do
            if v:getData("wineMaker >> vine") then
                objectCache[v] = {}
            end
        end
    end
)

addEventHandler("onClientElementStreamIn", root,
    function()
        if source:getData("wineMaker >> vine") then
            objectCache[source] = {}
        end
    end
)

addEventHandler("onClientElementStreamOut", root,
    function()
        if objectCache[source] then
            objectCache[source] = nil
        end
    end
)

local zAxis = 1
local yAxis = -0.5
local renderCache 

setTimer(
    function()
        if not isJobStarted then 
            checkRender("off")
            return 
        end
        
        renderCache = {}
        
        cameraX, cameraY, cameraZ = getElementPosition(localPlayer)
        
        for k,v in pairs(objectCache) do
            local v = v
            if isElement(k) and k.dimension == localPlayer.dimension and k.interior == localPlayer.interior then
                local boneX, boneY, boneZ = getElementPosition(k)
                boneY = boneY + yAxis
                boneZ = boneZ + zAxis
                local dist = math.sqrt((cameraX - boneX) ^ 2 + (cameraY - boneY) ^ 2 + (cameraZ - boneZ) ^ 2)
                if dist <= maxDistance then
                    local sightLine = isLineOfSightClear(cameraX, cameraY, cameraZ, boneX, boneY, boneZ, true, false, false, true, false, false, false, k)
                    if sightLine then
                        v["sightLine"] = true
                        v["distance"] = dist
                        v["id"] = k:getData("wineMaker >> vine")
                        v["health"] = tonumber(k:getData("wineMaker >> health")) or 100
                        
                        renderCache[k] = v
                    end
                end
            end
        end
        
        for k,v in pairs(renderCache) do
            checkRender("on")
            return
        end
        checkRender("off")
    end, 250, 0
)

local animationDetails = {}

function updateAnimationDetails()
    if renderCache then
        for k,v in pairs(renderCache) do
            if not animationDetails[v["id"]] then
                animationDetails[v["id"]] = 0
            end

            if not animationDetails["real" .. v["id"]] then
                animationDetails["real" .. v["id"]] = 0
            end

            if animationDetails[v["id"]] ~= v["health"] then
                animationDetails[v["id"]] = v["health"]
                animationDetails[v["id"] .. "Animation"] = true
                animationDetails[v["id"] .. "AnimationTick"] = getTickCount()
            end
        end
    end    
end
setTimer(updateAnimationDetails, 250, 0)

startAnimation = "InOutQuad"
startAnimationTime = 250
maxDistance = 12

function renderHealth()
    local nowTick = getTickCount()
    local font = exports['cr_fonts']:getFont("Poppins-Regular", 12)
    local r,g,b = 255,59,59
    
    for k,v in pairs(renderCache) do
        local boneX, boneY, boneZ = getElementPosition(k)
        local distance = v["distance"]
        if distance <= maxDistance then
            local size = 1 - (distance / maxDistance)
            local screenX, screenY = getScreenFromWorldPosition(boneX, boneY + yAxis, boneZ + zAxis)
            if screenX and screenY then
                local _k = k

                local k = v["id"]
                if animationDetails[k.."Animation"] then
                    local startTick = animationDetails[k.."AnimationTick"]

                    local elapsedTime = nowTick - startTick
                    local duration = startAnimationTime
                    local progress = elapsedTime / duration
                    local alph = interpolateBetween(
                        animationDetails["real"..k], 0, 0,
                        animationDetails[k], 0, 0,
                        progress, startAnimation
                    )
                    animationDetails["real"..k] = alph

                    if progress >= 1 then
                        animationDetails[k.."Animation"] = false
                    end
                end

                local hp = animationDetails["real"..k] or 0
                local alpha = 255 * size

                local w, h = 150 * size, 15 * size

                dxDrawRectangle(screenX - w/2, screenY- h/2, w, h, tocolor(242, 242, 242, alpha * 0.6))
                dxDrawRectangle(screenX - w/2, screenY - h/2, w * (hp / 100), h, tocolor(r,g,b, alpha))
                dxDrawText(math.floor(hp) .. "%", screenX, screenY, screenX, screenY + 4, tocolor(242, 242, 242, alpha), size, font, "center", "center", false, false, false, true)
            end
        end
    end
end

addEventHandler("onClientClick", root, 
    function(b, s, _, _, _, _, _, worldElement)
        if isJobStarted then 
            if b == "left" and s == "down" then 
                if worldElement and isElement(worldElement) and worldElement:getData("wineMaker >> vine") then 
                    if getDistanceBetweenPoints3D(localPlayer.position, worldElement.position) <= 2 then
                        if localPlayer:getData("winemaker >> objInHand") and tonumber(localPlayer:getData("winemaker >> objInHand") or 7251) == 7251 then 
                            if not worldElement:getData("wineMaker >> doingInteraction") then 
                                if tonumber(worldElement:getData("wineMaker >> health") or 0) == 100 then 
                                    if exports['cr_network']:getNetworkStatus() then return end 

                                    worldElement:setData("wineMaker >> doingInteraction", localPlayer)
                                end 
                            end 
                        end 
                    end 
                end 
            end 
        end 
    end 
)

local gPed;
addEventHandler("onClientElementDataChange", resourceRoot, 
    function(dName, oValue, nValue)
        if dName == "wineMaker >> doingInteraction" then 
            if nValue then 
                if oValue and isElement(oValue) and nValue == localPlayer then 
                    source:setData(dName, oValue)

                    if exports['cr_dx']:isProgressBarActive('wineMakerProgress') then 
                        exports['cr_dx']:endProgressBar('wineMakerProgress')
        
                        localPlayer:setData("forceAnimation", {"", ""})
                    end 

                    return 
                end 

                if nValue == localPlayer then 
                    if not exports['cr_dx']:isProgressBarActive('wineMakerProgress') then 
                        gPed = source
                        
                        localPlayer.rotation = Vector3(0, 0, findRotation(localPlayer.position.x, localPlayer.position.y, source.position.x, source.position.y))
                        localPlayer:setData("forceAnimation", {"bomber", "bom_plant"})

                        exports['cr_dx']:startProgressBar('wineMakerProgress', texts)
                    end 
                end 
            end 
        end 
    end 
)

addEventHandler('ProgressBarEnd', localPlayer, 
    function(id, data)
        if id == 'wineMakerProgress' then 
            gPed:setData("wineMaker >> doingInteraction", nil)

            localPlayer:setData("forceAnimation", {"CARRY", "crry_prtial", 0, true, false, true, true})
            triggerLatentServerEvent("respawnVine", 5000, false, localPlayer, localPlayer, gPed)
        end 
    end 
)

--

function findRotation(x1, y1, x2, y2) 
    local t = -math.deg( math.atan2( x2 - x1, y2 - y1 ) )
    return t < 0 and t + 360 or t
end