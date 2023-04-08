local trackedPlayer = false 
local started = false
local marker = false
local spamTick = 0

function trackPlayer(cmd, targetNumber)
    if localPlayer:getData("loggedIn") then 
        if hasPlayerPermission(localPlayer, cmd) then 
            if not targetNumber then 
                if not started then 
                    local syntax = exports["cr_core"]:getServerSyntax(false, "lightyellow")
                    return outputChatBox(syntax.."/"..cmd.." [telefonszám]", 255, 0, 0, true)
                else 
                    local syntax = exports["cr_core"]:getServerSyntax(false, "info")
                    local serverHex = exports["cr_core"]:getServerColor("blue", true)

                    outputChatBox(syntax.."Trackelés befejezve.", 255, 0, 0, true)
                    exports["cr_core"]:sendMessageToAdmin(localPlayer, exports["cr_admin"]:getAdminSyntax()..serverHex..exports["cr_admin"]:getAdminName(localPlayer).."#ffffff abbahagyta a lenyomozást.", 3)
                    
                    started = false 

                    if isElement(marker) then 
                        marker:destroy()
                        gBlip:destroy()

                        exports["cr_radar"]:destroyStayBlip("Célpont")

                        collectgarbage("collect")
                    end
                end
            else 
                local targetNumber = tonumber(targetNumber)

                if targetNumber ~= nil then 
                    if tostring(targetNumber):len() == 10 then 
                        if not started then 
                            local syntax = exports["cr_core"]:getServerSyntax(false, "red")

                            if spamTick + 60000 > getTickCount() then 
                                return outputChatBox(syntax.."Csak percenként nyomozhatsz le embereket.", 255, 0, 0, true)
                            end
                            
                            local syntax = exports["cr_core"]:getServerSyntax(false, "info")

                            outputChatBox(syntax.."Trackelés elkezdése...", 255, 0, 0, true)

                            started = true 

                            triggerLatentServerEvent("faction.trackPlayer", 5000, false, localPlayer, localPlayer, targetNumber)
                        else 
                            local syntax = exports["cr_core"]:getServerSyntax(false, "info")
                            local serverHex = exports["cr_core"]:getServerColor("blue", true)

                            outputChatBox(syntax.."Trackelés befejezve.", 255, 0, 0, true)
                            exports["cr_core"]:sendMessageToAdmin(localPlayer, exports["cr_admin"]:getAdminSyntax()..serverHex..exports["cr_admin"]:getAdminName(localPlayer).."#ffffff abbahagyta a lenyomozást.", 3)
                            
                            started = false 

                            if isElement(marker) then 
                                marker:destroy()
                                gBlip:destroy()

                                exports["cr_radar"]:destroyStayBlip("Célpont")

                                collectgarbage("collect")
                            end
                        end

                        spamTick = getTickCount()
                    else 
                        local syntax = exports["cr_core"]:getServerSyntax(false, "red")
                        return outputChatBox(syntax.."Hibás telefonszám.", 255, 0, 0, true)
                    end
                else 
                    local syntax = exports["cr_core"]:getServerSyntax(false, "red")
                    return outputChatBox(syntax.."Csak szám.", 255, 0, 0, true)
                end
            end
        end
    end
end
addCommandHandler("trackplayer", trackPlayer, false, false)

addEvent("faction.trackPlayer", true)
addEventHandler("faction.trackPlayer", root,
    function(sourceNumber, targetElement)
        trackedPlayer = targetElement

        local position = targetElement.position 
        local interior = targetElement.interior 
        local dimension = targetElement.dimension 

        local r, g, b = exports["cr_core"]:getServerColor("red", false)
        local serverHex = exports["cr_core"]:getServerColor("blue", true)

        marker = Marker(position, "checkpoint", 1.5, r, g, b)
        marker.interior = interior 
        marker.dimension = dimension
        -- marker:attach(targetElement)

        gBlip = Blip(position, 0, 2, 255, 0, 0, 255, 0, 0)
        -- gBlip:attach(targetElement)

        exports["cr_radar"]:createStayBlip("Célpont", gBlip, 0, "target", 24, 24, 255, 87, 87)

        exports["cr_core"]:sendMessageToAdmin(localPlayer, exports["cr_admin"]:getAdminSyntax()..serverHex..exports["cr_admin"]:getAdminName(localPlayer).."#ffffff lenyomozta a(z) "..serverHex..exports["cr_phone"]:formatPhoneNumber(sourceNumber).."#ffffff-s számot. "..serverHex.."("..exports["cr_admin"]:getAdminName(targetElement)..")", 3)
    end
)

addEventHandler("onClientPlayerQuit", root,
    function(reason)
        if trackedPlayer == source then 
            local syntax = exports["cr_core"]:getServerSyntax(false, "info")
            local serverHex = exports["cr_core"]:getServerColor("blue", true)

            outputChatBox(syntax.."Trackelés befejezve (A trackelt játékos lecsatlakozott a szerverről).", 255, 0, 0, true)
            exports["cr_core"]:sendMessageToAdmin(localPlayer, exports["cr_admin"]:getAdminSyntax()..serverHex..exports["cr_admin"]:getAdminName(localPlayer).."#ffffff abbahagyta a lenyomozást (A lenyomozott játékos lecsatlakozott a szerverről).", 3)
            
            started = false 

            if isElement(marker) then 
                marker:destroy()
                gBlip:destroy()

                exports["cr_radar"]:destroyStayBlip("Célpont")

                collectgarbage("collect")
            end
        end
    end
)