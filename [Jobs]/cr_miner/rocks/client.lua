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

local function onStart()
    local objects = getElementsByType("object", resourceRoot, true)

    for i = 1, #objects do 
        local v = objects[i]

        if v:getData("rock >> health") then 
            objectCache[v] = {}
        end
    end
end
addEventHandler("onClientResourceStart", resourceRoot, onStart)

local function onElementStreamIn()
    if source:getData("rock >> health") then 
        objectCache[source] = {}
    end
end
addEventHandler("onClientElementStreamIn", root, onElementStreamIn)

local function onElementStreamOut()
    if objectCache[source] then 
        objectCache[source] = nil
    end
end
addEventHandler("onClientElementStreamOut", root, onElementStreamOut)

local zAxis = 1
local yAxis = -0.5
local maxDistance = 15
local renderCache 

setTimer(
    function()
        if not isJobStarted then 
            checkRender("off")
            return 
        end
        
        renderCache = {}
        cameraX, cameraY, cameraZ = getElementPosition(localPlayer)
        
        for k, v in pairs(objectCache) do
            local v = v

            if isElement(k) and k.dimension == localPlayer.dimension and k.interior == localPlayer.interior then
                local boneX, boneY, boneZ = getElementPosition(k)

                boneY = boneY + yAxis
                boneZ = boneZ + zAxis

                local dist = math.sqrt((cameraX - boneX) ^ 2 + (cameraY - boneY) ^ 2 + (cameraZ - boneZ) ^ 2)

                if dist <= maxDistance then
                    local sightLine = isLineOfSightClear(cameraX, cameraY, cameraZ, boneX, boneY, boneZ, true, false, false, true, false, false, false, k)
                    
                    if sightLine then
                        v.sightLine = true
                        v.distance = dist
                        v.id = k:getData("rock >> id")
                        v.health = tonumber(k:getData("rock >> health")) or 100
                        
                        renderCache[k] = v
                    end
                end
            end
        end
        
        for k, v in pairs(renderCache) do
            checkRender("on")
            return
        end

        checkRender("off")
    end, 250, 0
)

local animationDetails = {}

function updateAnimationDetails()
    if renderCache then
        for k, v in pairs(renderCache) do
            if not animationDetails[v.id] then
                animationDetails[v.id] = 0
            end

            if not animationDetails["real" .. v.id] then
                animationDetails["real" .. v.id] = 0
            end

            if animationDetails[v.id] ~= v.health then
                animationDetails[v.id] = v.health
                animationDetails[v.id .. "Animation"] = true
                animationDetails[v.id .. "AnimationTick"] = getTickCount()
            end
        end
    end    
end
setTimer(updateAnimationDetails, 250, 0)

local startAnimation = "InOutQuad"
local startAnimationTime = 250

function renderHealth()
    local nowTick = getTickCount()
    local font = exports.cr_fonts:getFont("Poppins-Regular", 12)
    local r, g, b = 255, 59, 59
    
    for k, v in pairs(renderCache) do
        local boneX, boneY, boneZ = getElementPosition(k)
        local distance = v.distance

        if distance <= maxDistance then
            local size = 1 - (distance / maxDistance)
            local screenX, screenY = getScreenFromWorldPosition(boneX, boneY + yAxis, boneZ + zAxis)

            if screenX and screenY then
                local _k = k
                local k = v.id

                if animationDetails[k .. "Animation"] then
                    local startTick = animationDetails[k .. "AnimationTick"]

                    local elapsedTime = nowTick - startTick
                    local duration = startAnimationTime
                    local progress = elapsedTime / duration
                    local alph = interpolateBetween(
                        animationDetails["real" .. k], 0, 0,
                        animationDetails[k], 0, 0,
                        progress, startAnimation
                    )
                    animationDetails["real" .. k] = alph

                    if progress >= 1 then
                        animationDetails[k .. "Animation"] = false
                    end
                end

                local hp = animationDetails["real" .. k] or 0
                local alpha = 255 * size

                local barW, barH = 150 * size, 15 * size
                local barX, barY = screenX - barW / 2, screenY - barH / 2

                dxDrawRectangle(barX, barY, barW, barH, tocolor(242, 242, 242, alpha * 0.6))
                dxDrawRectangle(barX, barY, barW * (hp / 100), barH, tocolor(r,g,b, alpha))
                dxDrawText(math.floor(hp) .. "%", screenX, screenY, screenX, screenY + 4, tocolor(242, 242, 242, alpha), size, font, "center", "center", false, false, false, true)
            end
        end
    end
end