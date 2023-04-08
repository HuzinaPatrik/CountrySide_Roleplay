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

local sx, sy = guiGetScreenSize()
local w, h, w2 = 310, 10, 310
local x, y = sx / 2 - w / 2, sy - h - 90
local waterState = false
local oxigen = getPedOxygenLevel(localPlayer)

function getDetails(component)
    return exports['cr_interface']:getDetails(component)
end

function drawnEvent()
    if not getElementData(localPlayer, "hudVisible") then return end
    local enabled,x,y,w,h,sizable,turnable = getDetails("oxygen")
    local w, h = 75, 75
    local oxigen = math.min(1000, getPedOxygenLevel(localPlayer))
    local multipler = (oxigen / 1000)
    --local w = w * multipler
    dxDrawImage(x, y, w, h, "files/water.png", 0,0,0, tocolor(120,120,120,255))
    if multipler >= 1 then multipler = 1 end
    if multipler <= 0 then multipler = 0 end
    
    --outputChatBox((1 - multipler))
    local h = h * (1 - multipler)
    dxDrawImageSection(x, y + h, w, 75 - h, 0, h, w, 75 - h, "files/water.png", 0,0,0, tocolor(242,242,242,255))
end

setTimer(
    function()
        if isElementInWater(localPlayer) then
            if not waterState then
                waterState = true
                --addEventHandler("onClientRender", root, drawnEvent, true, "low-5")
                createRender("drawnEvent", drawnEvent)
            end
        else
            if waterState then
                waterState = false
                --removeEventHandler("onClientRender", root, drawnEvent)
                destroyRender("drawnEvent")
            end
        end
    end, 350, 0
)