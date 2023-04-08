local resetTimer;
local lastHitTick = -750

localPlayer:setData('lumberjack >> tree >> hit', nil)

function onTreeHit(loss, attacker)
    if isJobStarted then 
        if attacker == localPlayer and localPlayer:getWeapon() == 10 then 
            if source:getData('lumberjack >> tree') and not source:getData('lumberjack >> tree >> fallen') then 
                if not source:getData('lumberjack >> tree >> hit') or not isElement(source:getData('lumberjack >> tree >> hit')) or source:getData('lumberjack >> tree >> hit') == localPlayer or tonumber(source:getData('lumberjack >> tree >> hit'):getData('char >> group') or -1) == tonumber(localPlayer:getData('char >> group') or -2) then 
                    if not localPlayer:getData('lumberjack >> tree >> hit') or not isElement(localPlayer:getData('lumberjack >> tree >> hit')) or localPlayer:getData('lumberjack >> tree >> hit') == source then 
                        local now = getTickCount()
                        local a = 0.75

                        if now <= lastHitTick + a * 1000 then
                            return
                        end

                        lastHitTick = getTickCount()
                        
                        source:setData('lumberjack >> tree >> hit', localPlayer)
                        localPlayer:setData('lumberjack >> tree >> hit', source)

                        Sound3D('assets/sounds/chop.mp3', source.position)

                        if isTimer(resetTimer) then 
                            killTimer(resetTimer)
                        end 

                        resetTimer = setTimer(
                            function(obj)
                                if isElement(obj) then 
                                    obj:setData('lumberjack >> tree >> hit', nil)
                                    localPlayer:setData('lumberjack >> tree >> hit', nil)
                                    obj:setData("lumberjack >> health", 100)
                                end 
                            end, 1 * 60 * 1000, 1, source
                        )

                        local newHealth = math.max(0, tonumber(source:getData('lumberjack >> health') or 100) - (math.random(1, 20) * (math.random(1, 200) / 100)))
                        source:setData('lumberjack >> health', newHealth)

                        if newHealth == 0 then 
                            if not source:getData('lumberjack >> tree >> fallen') then 
                                if isTimer(resetTimer) then 
                                    killTimer(resetTimer)
                                end 
                                
                                triggerLatentServerEvent('treeFalls', 5000, false, localPlayer, localPlayer, source)

                                local players = exports['cr_core']:getNearbyPlayers("medium")
                                if #players >= 1 then 
                                    triggerLatentServerEvent("playSound3D", 5000, false, localPlayer, localPlayer, source, players, "assets/sounds/fall.mp3")
                                end 

                                local sound = Sound3D("assets/sounds/fall.mp3", source.position)
                                sound.dimension = source.dimension 
                                sound.interior = source.interior 
                                sound:attach(source)
                            end 
                        end 
                    end 
                end 
            end 
        end
    end 
end 
addEventHandler("onClientObjectDamage", resourceRoot, onTreeHit)

addEventHandler('onClientResourceStop', resourceRoot, 
    function()
        if localPlayer:getData('lumberjack >> tree >> hit') then 
            local obj = localPlayer:getData('lumberjack >> tree >> hit')

            localPlayer:setData('lumberjack >> tree >> hit', nil)

            if obj:getData('lumberjack >> tree >> hit') == localPlayer then 
                obj:setData('lumberjack >> tree >> hit', nil)
                obj:setData("lumberjack >> health", 100)
            end 
        end 
    end 
)