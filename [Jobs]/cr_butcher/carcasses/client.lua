local screenX, screenY = guiGetScreenSize()

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
    local objects = getElementsByType("object", _, true)

    for i = 1, #objects do 
        local v = objects[i]

        if v:getData("carcass >> id") then 
            objectCache[v] = {}
        end
    end
end
addEventHandler("onClientResourceStart", resourceRoot, onStart)

local function onClientStreamIn()
    if source.type == "object" and source:getData("carcass >> id") then 
        if not objectCache[source] then 
            objectCache[source] = {}
        end
    end
end
addEventHandler("onClientElementStreamIn", root, onClientStreamIn)

local function onClientStreamOut()
    if source.type == "object" and objectCache[source] then 
        objectCache[source] = nil
    end
end
addEventHandler("onClientElementStreamOut", root, onClientStreamOut)

local zAxis = 1.8
local yAxis = -0.5
local closestMeatData = false

-- function getPositionFromElementOffset(element,offX,offY,offZ) 
--     local m = getElementMatrix ( element )  -- Get the matrix 
--     local x = offX * m[1][1] + offY * m[2][1] + offZ * m[3][1] + m[4][1]  -- Apply transform 
--     local y = offX * m[1][2] + offY * m[2][2] + offZ * m[3][2] + m[4][2] 
--     local z = offX * m[1][3] + offY * m[2][3] + offZ * m[3][3] + m[4][3] 
--     return x, y, z                               -- Return the transformed point 
-- end 

-- function render()
--     if localPlayer.name ~= "Hugh_Wiley" then 
--         return
--     end

--     local x, y, z = getElementPosition(localPlayer)
--     local x2, y2, z2 = getPositionFromElementOffset(localPlayer, 0, jobData.maxVisibleDistance, 1.8)

--     dxDrawLine3D(x, y, z, x2, y2, z2, tocolor(255, 255, 255), 2)
-- end
-- addEventHandler("onClientRender", root, render)

setTimer(
    function()
        if not isJobStarted then 
            checkRender("off")
            return 
        end
        
        closestMeatData = false
        local playerPosition = localPlayer.position

        for k, v in pairs(objectCache) do
            local v = v

            if isElement(k) and k.dimension == localPlayer.dimension and k.interior == localPlayer.interior then
                local x, y, z = getElementPosition(localPlayer)
                local x2, y2, z2 = getElementPosition(k)
                -- local x2, y2, z2 = getPositionFromElementOffset(localPlayer, 0, jobData.maxVisibleDistance, 1.8)

                local dist = math.sqrt((x - x2) ^ 2 + (y - y2) ^ 2 + (z - z2) ^ 2)

                local sightLine = isLineOfSightClear(x, y, z, x2, y2, z2, true, false, false, true, false, false, false, k)
                -- local hit, hitX, hitY, hitZ, hitElement = processLineOfSight(x, y, z, x2, y2, z2, true, true, true, true, true, false, false)

                if dist <= jobData.maxVisibleDistance then 
                    if sightLine then
                        closestMeatData = {
                            element = k,
                            sightLine = true,
                            id = k:getData("carcass >> id"),
                            health = tonumber(k:getData("carcass >> health") or 100),
                        }
                    end
                end
            end
        end
        
        if closestMeatData then
            checkRender("on")
            return
        end

        checkRender("off")
    end, 250, 0
)

local animationDetails = {}

function updateAnimationDetails()
    if closestMeatData and closestMeatData.id then
        if not animationDetails[closestMeatData.id] then 
            animationDetails[closestMeatData.id] = 0
        end

        if not animationDetails["real" .. closestMeatData.id] then
            animationDetails["real" .. closestMeatData.id] = 0
        end

        if animationDetails[closestMeatData.id] ~= closestMeatData.health then
            animationDetails[closestMeatData.id] = closestMeatData.health
            animationDetails[closestMeatData.id .. "Animation"] = true
            animationDetails[closestMeatData.id .. "AnimationTick"] = getTickCount()
        end
    end    
end
setTimer(updateAnimationDetails, 250, 0)

startAnimation = "InOutQuad"
startAnimationTime = 250

function renderHealth()
    local nowTick = getTickCount()
    local font = exports.cr_fonts:getFont("Poppins-Regular", 12)
    local r, g, b = 255, 59, 59
    
    if closestMeatData then
        local k = closestMeatData.id

        if k then 
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

            local size = 1
            local alpha = 255
            local hp = animationDetails["real" .. k] or 0

            local enabled, actionX, actionY, actionW, actionH, sizable, turnable, sizeDetails, acType, columns = exports.cr_interface:getDetails("Actionbar")

            local barW, barH = 150, 15
            local barX, barY = actionX + actionW / 2 - barW / 2, actionY - 20

            dxDrawRectangle(barX, barY, barW, barH, tocolor(242, 242, 242, alpha * 0.6))
            dxDrawRectangle(barX, barY, barW * (hp / 100), barH, tocolor(r, g, b, alpha))
            dxDrawText(math.floor(hp) .. "%", barX, barY, barX + barW, barY + barH, tocolor(242, 242, 242, alpha), size, font, "center", "center", false, false, false, true)
        end
    end
end