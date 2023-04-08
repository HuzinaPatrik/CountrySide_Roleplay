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
            if v:getData("lumberjack >> tree") then
                objectCache[v] = {}
            end
        end
    end
)

addEventHandler("onClientElementStreamIn", root,
    function()
        if source:getData("lumberjack >> tree") then
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
local yAxis = 0
local renderCache 

setTimer(
    function()
        if not isJobStarted then 
            checkRender("off")
            return 
        end

        if localPlayer:getWeapon() ~= 10 then 
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

                if not k:getData('lumberjack >> tree >> fallen') or k:getData('lumberjack >> tree >> fallen') and k:getData('lumberjack >> tree >> falled') then
                    if dist <= maxDistance then
                        local sightLine = isLineOfSightClear(cameraX, cameraY, cameraZ, boneX, boneY, boneZ, true, false, false, true, false, false, false, k)

                        if sightLine then
                            v["sightLine"] = true
                            v["distance"] = dist
                            v["id"] = k:getData("lumberjack >> tree")
                            v['falled'] = k:getData('lumberjack >> tree >> falled')
                            v['cuttingCount'] = k:getData('lumberjack >> tree >> cuttingCount')
                            v['maxCuttingCount'] = k:getData('lumberjack >> tree >> maxCuttingCount')
                            v['ownerName'] = k:getData('lumberjack >> tree >> ownerName')
                            v["health"] = tonumber(k:getData("lumberjack >> health")) or 100
                            
                            renderCache[k] = v
                        end
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
    local yellow = exports['cr_core']:getServerColor('yellow', true)
    local orange = exports['cr_core']:getServerColor('orange', true)
    local r,g,b = 255,59,59
    
    for k,v in pairs(renderCache) do
        local boneX, boneY, boneZ = getElementPosition(k)
        local distance = v["distance"]
        if distance <= maxDistance then
            local size = 1 - (distance / maxDistance)
            local screenX, screenY = getScreenFromWorldPosition(boneX, boneY + yAxis, boneZ + zAxis)
            if screenX and screenY then
                local _k = k

                if v['falled'] then 
                    dxDrawText('Kivágva '..yellow..v['ownerName']..'#F2F2F2 által!\nÁllapot: '..orange..v['cuttingCount']..'/'..v['maxCuttingCount'], screenX, screenY, screenX, screenY + 4, tocolor(242, 242, 242, alpha), size, font, "center", "center", false, false, false, true)
                else 
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
end