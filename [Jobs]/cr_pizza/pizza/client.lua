local pizzaCache = {}

function createPizzas()
    for k,v in pairs(pizzaPositions) do 
        local x,y,z,dim,int,rot = unpack(v)
        local obj = Object(1582, x, y, z)
        obj.dimension = dim 
        obj.interior = int 
        obj.rotation = Vector3(0, 0, rot)
        obj.frozen = true 
        obj:setData("pizza >> pizzaPickupObj", k)

        pizzaCache[obj] = k

        exports['cr_radar']:createStayBlip("Pizza felvétel: "..k, Blip(x, y, z, 0, 2, 255, 0, 0, 255, 0, 0), 0, "job", 24, 24, 255, 255, 255)
    end 
end 

function destroyPizzas()
    for k,v in pairs(pizzaCache) do 
        if isElement(k) then 
            k:destroy()

            exports['cr_radar']:destroyStayBlip("Pizza felvétel: "..v)
        end 
    end 

    pizzaCache = {}

    collectgarbage("collect")
end

local lastClickTick = -1000
addEventHandler("onClientClick", root, 
    function(b, s, _, _, _, _, _, worldElement)
        if isJobStarted then 
            if b == "left" and s == "down" then 
                if worldElement and isElement(worldElement) and worldElement:getData("pizza >> pizzaPickupObj") then 
                    if getDistanceBetweenPoints3D(localPlayer.position, worldElement.position) <= 2 then
                        if exports['cr_network']:getNetworkStatus() then return end 

                        local now = getTickCount()
                        local a = 1
                        if now <= lastClickTick + a * 1000 then
                            return
                        end
                        lastClickTick = getTickCount()
                        
                        if not localPlayer:getData("pizza >> objInHand") then 
                            triggerLatentServerEvent("givePizzaToHand", 5000, false, localPlayer, localPlayer, 1582)
                        else 
                            triggerLatentServerEvent("destroyPizzaFromHand", 5000, false, localPlayer, localPlayer)
                        end 
                    end 
                end 
            end 
        end 
    end 
)

addCommandHandler("eldob", 
    function(cmd)
        if isJobStarted then 
            if localPlayer:getData("pizza >> objInHand") then
                local now = getTickCount()
                local a = 1
                if now <= lastClickTick + a * 1000 then
                    return
                end
                lastClickTick = getTickCount()

                triggerLatentServerEvent("destroyPizzaFromHand", 5000, false, localPlayer, localPlayer)
            end 
        end 
    end 
)