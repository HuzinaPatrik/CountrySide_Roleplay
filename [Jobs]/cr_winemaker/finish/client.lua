local markerCache = {}

function createFinishMarkers()
    for k,v in pairs(finishMarkerPositions) do 
        local x,y,z,dim,int = unpack(v)

        local marker = Marker(x,y,z, "cylinder", 1.5, 97, 177, 90)
        marker:setData("marker >> customMarker", true)
        marker:setData("marker >> customIconPath", ":cr_winemaker/assets/images/finish.png")
        marker:setData("winemaker >> finishMarker", k)
        markerCache[marker] = k

        exports['cr_radar']:createStayBlip("Hordó leadás: "..k, Blip(x, y, z, 0, 2, 255, 0, 0, 255, 0, 0), 0, "target", 24, 24, 97, 177, 90)
    end 
end 

function destroyFinishMarkers()
    for k,v in pairs(markerCache) do 
        if isElement(k) then 
            k:destroy()

            exports['cr_radar']:destroyStayBlip("Hordó leadás: "..v)
        end 
    end 

    markerCache = {}

    collectgarbage('collect')
end 

local lastClickTick = -30000
addEventHandler("onClientMarkerHit", resourceRoot, 
    function(hitPlayer, matchingDimension)
        if hitPlayer == localPlayer and matchingDimension then 
            if source:getData("winemaker >> finishMarker") then 
                if getDistanceBetweenPoints3D(localPlayer.position, source.position) <= 3 then 
                    if localPlayer:getData("winemaker >> objInHand") and tonumber(localPlayer:getData('winemaker >> objInHand') or 0) == 6929 then
                        if exports['cr_network']:getNetworkStatus() then return end 

                        local now = getTickCount()
                        local a = 30
                        if now <= lastClickTick + a * 1000 then
                            return
                        end
                        lastClickTick = getTickCount()

                        triggerLatentServerEvent("destroyChestFromHand", 5000, false, localPlayer, localPlayer)
                        localPlayer:setData("forceAnimation", {"carry", "putdwn",-1,false, false, false, false, 250, true})
                        if isTimer(animationTimer) then 
                            killTimer(animationTimer) 
                            animationTimer = nil 
                        end 
        
                        animationTimer = setTimer(
                            function()
                                localPlayer:setData("forceAnimation", nil)
                            end, 275, 1
                        )

                        local salaryMultiplier = exports.cr_salary:getMultiplier() or 1

                        local money = 500 * salaryMultiplier
                        exports['cr_core']:giveMoney(localPlayer, money)
                        exports['cr_infobox']:addBox('success', 'Sikeresen leadtad a hordót ezért kaptál $ '..money..' dollárt!')
                    end 
                end 
            end 
        end 
    end 
)