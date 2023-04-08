local sx, sy = guiGetScreenSize()
local white = "#F2F2F2"
lastClickTick = -500
gPrice = 100
gPrice2 = 50

lastFrame = 0

addEventHandler("onClientResourceStart", resourceRoot,
    function()
        local r,g,b = exports['cr_core']:getServerColor("red")
        gMarker = Marker(434.70611572266, 598.26989746094, 17.8, "cylinder", 3.3, r,g,b)
        gMarker:setData("marker >> customMarker", true)
        gMarker:setData("marker >> customIconPath", ":cr_racetrack/files/racing-flag.png")
        
        local r,g,b = exports['cr_core']:getServerColor("red")
        gMarker5 = Marker(429.21499633789, 606.33648681641, 17.8, "cylinder", 3.3, r,g,b)
        gMarker5:setData("marker >> customMarker", true)
        gMarker5:setData("marker >> customIconPath", ":cr_racetrack/files/racing-flag.png")
        
        function returnData(d)
            gObj = d[1]
            --bestSectorDetails = d[2]
            playerTimes = d[2]
            --outputChatBox(playerTimes[1][5])
            local table = {}
            if playerTimes[1] and playerTimes[1][2] then
                for k, v in pairs(playerTimes[1][2]) do
                    if k ~= "last" then
                        table[tonumber(k)] = v
                    else
                        table[k] = v
                    end
                end
            end
            --outputChatBox(playerTimes[1][5])
            bestSectorDetails = table
            --outputDebugString(inspect(bestSectorDetails))
            if not bestSectorDetails then
                bestSectorDetails = {}
            end
            addEventHandler("onClientElementDataChange", gObj,
                function(dName)
                    if dName == "moveState" then
                        if source:getData(dName) then
                            gMarker.position = Vector3(434.70611572266, 598.26989746094, -17.8)
                            gMarker5.position = Vector3(429.21499633789, 606.33648681641, -17.8)
                        else
                            gMarker.position = Vector3(434.70611572266, 598.26989746094, 17.8)
                            gMarker5.position = Vector3(429.21499633789, 606.33648681641, 17.8)
                        end
                    end
                end
            )
            
            if isElement(texElement) then destroyElement(texElement) end
            if isElement(shadElement) then destroyElement(shadElement) end
            if isElement(shader) then
                destroyElement(shader)
            end
            if isElement(renderTarget) then
                destroyElement(renderTarget)
            end
            if isThisRace or isTryThisRace then return end
            renderTarget = dxCreateRenderTarget(420, 10 * 20)
            shader = dxCreateShader("files/texturechanger.fx")
            dxSetShaderValue(shader, "nTexture", renderTarget)
            engineApplyShaderToWorldTexture(shader, "monitor")
            --addEventHandler("onClientRender", root, renderTopList, true, "low-5")
            if isTimer(renderTimer) then killTimer(renderTimer) end
            renderTopList()
            renderTimer = setTimer(renderTopList, 2000, 0)
        end
        addEvent("returnData", true)
        addEventHandler("returnData", localPlayer, returnData)
        
        triggerServerEvent("returnData", localPlayer, localPlayer)
        
        function onStartMarkerHit(hitPlayer, matchingDimension)
            if hitPlayer == localPlayer and matchingDimension and getDistanceBetweenPoints3D(localPlayer.position, source.position) <= 4 then
                local veh = getPedOccupiedVehicle(localPlayer)
                if getPedOccupiedVehicle(localPlayer) and getPedOccupiedVehicleSeat(localPlayer) == 0 then
                    if not panelState then
                        panelState = true
                        addEventHandler("onClientRender", root, drawnPanel, true, "low-5")
                        addEventHandler("onClientClick", root, onClickEvent1)
                    end
                end
            end
        end
        addEventHandler("onClientMarkerHit", gMarker, onStartMarkerHit)        
        
        function onStartMarkerLeave(hitPlayer, matchingDimension)
            if hitPlayer == localPlayer and matchingDimension then
                local veh = getPedOccupiedVehicle(localPlayer)
                if getPedOccupiedVehicle(localPlayer) and getPedOccupiedVehicleSeat(localPlayer) == 0 then
                    if panelState then
                        panelState = false
                        removeEventHandler("onClientRender", root, drawnPanel, true, "low-5")
                        removeEventHandler("onClientClick", root, onClickEvent1)
                    end
                end
            end
        end
        addEventHandler("onClientMarkerLeave", gMarker, onStartMarkerLeave)
        
        function drawnPanel()
            if isElement(gMarker) and getDistanceBetweenPoints3D(gMarker.position, localPlayer.position) >= 5 or not localPlayer.vehicle then
                if panelState then
                    panelState = false
                    removeEventHandler("onClientRender", root, drawnPanel, true, "low-5")
                    removeEventHandler("onClientClick", root, onClickEvent1)
                end
            end

            local alpha = 255

            local font = exports['cr_fonts']:getFont('Poppins-SemiBold', 16)
            local font2 = exports['cr_fonts']:getFont('Poppins-Medium', 12)

            local w, h = 375, 120
            local x, y = sx/2 - w/2, sy/2 - h/2

            dxDrawRectangle(x, y, w, h, tocolor(51, 51, 51, alpha * 0.8))
            dxDrawImage(x + 10, y + 5, 25, 25, ":cr_account/files/logo-white.png", 0, 0, 0, tocolor(255, 255, 255, alpha))

            dxDrawText('Versenypálya', x + 10 + 25 + 10,y+5,x+w,y+5+25 + 4,tocolor(242, 242, 242, alpha),1,font,"left","center")

            selected = nil
            if exports['cr_core']:isInSlot(x + w - 10 - 15, y + 10, 15, 15) then 
                selected = 2 

                dxDrawImage(x + w - 10 - 15, y + 10, 15, 15, ":cr_inventory/assets/images/close.png", 0, 0, 0, tocolor(255, 59, 59, alpha))
            else 
                dxDrawImage(x + w - 10 - 15, y + 10, 15, 15, ":cr_inventory/assets/images/close.png", 0, 0, 0, tocolor(255, 59, 59, alpha * 0.6))
            end 

            local color = exports['cr_core']:getServerColor('green', true)
            dxDrawText("A versenypályára való belépéshez $ "..color..gPrice..white.."-ot(et) kell fizess!", x, y + 40, x + w, y + 40, tocolor(242, 242, 242, alpha), 1, font2, "center", "top", false, false, false, true)

            if exports['cr_core']:isInSlot(x + w/2 - 150/2, y + 85, 150, 20) then 
                selected = 1

                dxDrawRectangle(x + w/2 - 150/2, y + 85, 150, 20, tocolor(97, 177, 90, alpha))
                dxDrawText('Befizetés', x, y + 85, x + w, y + 85 + 20 + 4, tocolor(242, 242, 242, alpha), 1, font2, "center", "center")
            else 
                dxDrawRectangle(x + w/2 - 150/2, y + 85, 150, 20, tocolor(97, 177, 90, alpha * 0.7))
                dxDrawText('Befizetés', x, y + 85, x + w, y + 85 + 20 + 4, tocolor(242, 242, 242, alpha * 0.6), 1, font2, "center", "center")
            end 
        end
        
        function onClickEvent1(b, s)
            if b == "left" and s == "down" then
                if selected == 1 then
                    if getTickCount() <= lastClickTick + 1000 then
                        return
                    end
                    lastClickTick = getTickCount()
                    
                    if exports['cr_core']:takeMoney(localPlayer, gPrice) then
                        if panelState then
                            exports['cr_infobox']:addBox("info", "Menj a kezdőrácsoknál található jelzéshez a kezdéshez!")
                            panelState = false
                            removeEventHandler("onClientRender", root, drawnPanel, true, "low-5")
                            removeEventHandler("onClientClick", root, onClickEvent1)
                            triggerServerEvent("gateOpen", localPlayer, localPlayer)
                            removeEventHandler("onClientMarkerHit", gMarker, onStartMarkerHit)        
                            removeEventHandler("onClientMarkerLeave", gMarker, onStartMarkerLeave)    
                            addEventHandler("onClientMarkerHit", gMarker5, onStartMarkerHit5)        
                            addEventHandler("onClientMarkerLeave", gMarker5, onStartMarkerLeave5)    
                            local r,g,b = exports['cr_core']:getServerColor("red")
                            gMarker2 = Marker(398.60223388672, 607.67535400391, 8.1, "cylinder", 3.3, r,g,b)
                            gMarker2:setData("marker >> customMarker", true)
                            gMarker2:setData("marker >> customIconPath", ":cr_racetrack/files/racing-flag.png")
                            
                            addEventHandler("onClientMarkerHit", gMarker2, onStartMarkerHit2)        
                            addEventHandler("onClientMarkerLeave", gMarker2, onStartMarkerLeave2)    
                            
                            local r,g,b = exports['cr_core']:getServerColor("red")
                            gMarker3 = Marker(396.60668945313, 611.68218994141, 8.15, "cylinder", 3.3, r,g,b)
                            gMarker3:setData("marker >> customMarker", true)
                            gMarker3:setData("marker >> customIconPath", ":cr_racetrack/files/racing-flag.png")
                            
                            addEventHandler("onClientMarkerHit", gMarker3, onStartMarkerHit3)        
                            addEventHandler("onClientMarkerLeave", gMarker3, onStartMarkerLeave3)    
                        end
                    else
                        if panelState then
                            exports['cr_infobox']:addBox("error", "Nincs elég pénzed!")
                            panelState = false
                            removeEventHandler("onClientRender", root, drawnPanel, true, "low-5")
                            removeEventHandler("onClientClick", root, onClickEvent1)
                        end
                    end
                elseif selected == 2 then
                    if panelState then
                        if getTickCount() <= lastClickTick + 500 then
                            return
                        end
                        lastClickTick = getTickCount()
                        panelState = false
                        removeEventHandler("onClientRender", root, drawnPanel, true, "low-5")
                        removeEventHandler("onClientClick", root, onClickEvent1)
                    end
                end
                selected = nil
            end
        end
        
        function onStartMarkerHit5(hitPlayer, matchingDimension)
            if hitPlayer == localPlayer and matchingDimension and getDistanceBetweenPoints3D(localPlayer.position, source.position) <= 4 then
                local veh = getPedOccupiedVehicle(localPlayer)
                if getPedOccupiedVehicle(localPlayer) and getPedOccupiedVehicleSeat(localPlayer) == 0 then
                    if not panelState then
                        panelState = true
                        addEventHandler("onClientRender", root, drawnPanel5, true, "low-5")
                        addEventHandler("onClientClick", root, onClickEvent5)
                    end
                end
            end
        end
        addEventHandler("onClientMarkerHit", gMarker5, onStartMarkerHit5)        
        
        function onStartMarkerLeave5(hitPlayer, matchingDimension)
            if hitPlayer == localPlayer and matchingDimension then
                local veh = getPedOccupiedVehicle(localPlayer)
                if getPedOccupiedVehicle(localPlayer) and getPedOccupiedVehicleSeat(localPlayer) == 0 then
                    if panelState then
                        panelState = false
                        removeEventHandler("onClientRender", root, drawnPanel5, true, "low-5")
                        removeEventHandler("onClientClick", root, onClickEvent5)
                    end
                end
            end
        end
        addEventHandler("onClientMarkerLeave", gMarker5, onStartMarkerLeave5)
        
        function drawnPanel5()
            if isElement(gMarker5) and getDistanceBetweenPoints3D(gMarker5.position, localPlayer.position) >= 5 or not localPlayer.vehicle then
                if panelState then
                    panelState = false
                    --outputChatBox("asd")
                    removeEventHandler("onClientRender", root, drawnPanel5, true, "low-5")
                    removeEventHandler("onClientClick", root, onClickEvent5)
                end
            end

            local alpha = 255

            local font = exports['cr_fonts']:getFont('Poppins-SemiBold', 16)
            local font2 = exports['cr_fonts']:getFont('Poppins-Medium', 12)

            local w, h = 375, 120
            local x, y = sx/2 - w/2, sy/2 - h/2

            dxDrawRectangle(x, y, w, h, tocolor(51, 51, 51, alpha * 0.8))
            dxDrawImage(x + 10, y + 5, 25, 25, ":cr_account/files/logo-white.png", 0, 0, 0, tocolor(255, 255, 255, alpha))

            dxDrawText('Versenypálya', x + 10 + 25 + 10,y+5,x+w,y+5+25 + 4,tocolor(242, 242, 242, alpha),1,font,"left","center")

            selected = nil
            if exports['cr_core']:isInSlot(x + w - 10 - 15, y + 10, 15, 15) then 
                selected = 2 

                dxDrawImage(x + w - 10 - 15, y + 10, 15, 15, ":cr_inventory/assets/images/close.png", 0, 0, 0, tocolor(255, 59, 59, alpha))
            else 
                dxDrawImage(x + w - 10 - 15, y + 10, 15, 15, ":cr_inventory/assets/images/close.png", 0, 0, 0, tocolor(255, 59, 59, alpha * 0.6))
            end 

            dxDrawText("Elszeretnéd hagyni a versenypályát?", x, y + 40, x + w, y + 40, tocolor(242, 242, 242, alpha), 1, font2, "center", "top", false, false, false, true)

            if exports['cr_core']:isInSlot(x + w/2 - 150/2, y + 85, 150, 20) then 
                selected = 1
                
                dxDrawRectangle(x + w/2 - 150/2, y + 85, 150, 20, tocolor(97, 177, 90, alpha))
                dxDrawText('Igen', x, y + 85, x + w, y + 85 + 20 + 4, tocolor(242, 242, 242, alpha), 1, font2, "center", "center")
            else 
                dxDrawRectangle(x + w/2 - 150/2, y + 85, 150, 20, tocolor(97, 177, 90, alpha * 0.7))
                dxDrawText('Igen', x, y + 85, x + w, y + 85 + 20 + 4, tocolor(242, 242, 242, alpha * 0.6), 1, font2, "center", "center")
            end 
        end
        
        function onClickEvent5(b, s)
            if b == "left" and s == "down" then
                if selected == 1 then
                    if getTickCount() <= lastClickTick + 1000 then
                        return
                    end
                    lastClickTick = getTickCount()
                    
                    if panelState then
                        --exports['cr_infobox']:addBox("info", "Menj a kezdőrácsoknál található jelzéshez a kezdéshez!")
                        panelState = false
                        removeEventHandler("onClientRender", root, drawnPanel5, true, "low-5")
                        removeEventHandler("onClientClick", root, onClickEvent5)
                        triggerServerEvent("gateOpen", localPlayer, localPlayer)
                        addEventHandler("onClientMarkerHit", gMarker, onStartMarkerHit)        
                        addEventHandler("onClientMarkerLeave", gMarker, onStartMarkerLeave)    
                        removeEventHandler("onClientMarkerHit", gMarker5, onStartMarkerHit5)        
                        removeEventHandler("onClientMarkerLeave", gMarker5, onStartMarkerLeave5)    

                        --DESTROY
                        
                        panelState = false
                        removeEventHandler("onClientRender", root, drawnPanel3, true, "low-5")
                        removeEventHandler("onClientClick", root, onClickEvent3)
                        --triggerServerEvent("gateOpen", localPlayer, localPlayer)
                        removeEventHandler("onClientMarkerHit", gMarker2, onStartMarkerHit2)        
                        removeEventHandler("onClientMarkerHit", gMarker2, onStartMarkerLeave2)    

                        removeEventHandler("onClientMarkerHit", gMarker3, onStartMarkerHit3)        
                        removeEventHandler("onClientMarkerHit", gMarker3, onStartMarkerLeave3)    

                        if isElement(gMarker2) then
                            destroyElement(gMarker2)
                        end

                        if isElement(gMarker3) then
                            destroyElement(gMarker3)
                        end

                        if isElement(gMarker4) then
                            destroyElement(gMarker4)
                        end
                        
                        if oStates then
                            localPlayer:setData("hudVisible", oStates[1])
                            localPlayer:setData("keysDenied", oStates[2])
                            exports['cr_custom-chat']:showChat(oStates[3])
                        end
                        --triggerAFrissítésre!!

                        removeEventHandler("onClientRender", root, drawnHud)

                        if isElement(shader) then
                            destroyElement(shader)
                        end

                        if isElement(renderTarget) then
                            destroyElement(renderTarget)
                        end

                        if isElement(texElement) then
                            destroyElement(texElement)
                        end

                        if isElement(shadElement) then
                            destroyElement(shadElement)
                        end

                        if isElement(texElement) then destroyElement(texElement) end
                        if isElement(shadElement) then destroyElement(shadElement) end
                        if isElement(shader) then
                            destroyElement(shader)
                        end
                        if isElement(renderTarget) then
                            destroyElement(renderTarget)
                        end
                        renderTarget = dxCreateRenderTarget(420, 10 * 20)
                        shader = dxCreateShader("files/texturechanger.fx")
                        dxSetShaderValue(shader, "nTexture", renderTarget)
                        engineApplyShaderToWorldTexture(shader, "monitor")
                        --addEventHandler("onClientRender", root, renderTopList, true, "low-5")
                        
                        if isThisRace then
                            isThisRace = nil
                        end
                        
                        if isTryThisRace then
                            isTryThisRace = nil
                        end
                        
                        triggerServerEvent("ghostMode", localPlayer, localPlayer.vehicle, "off")
                        
                        if isTimer(renderTimer) then killTimer(renderTimer) end
                        renderTopList()
                        renderTimer = setTimer(renderTopList, 2000, 0)
                    end
                elseif selected == 2 then
                    if panelState then
                        if getTickCount() <= lastClickTick + 500 then
                            return
                        end
                        lastClickTick = getTickCount()
                        panelState = false
                        removeEventHandler("onClientRender", root, drawnPanel5, true, "low-5")
                        removeEventHandler("onClientClick", root, onClickEvent5)
                    end
                end
                selected = nil
            end
        end
        
        function onStartMarkerHit2(hitPlayer, matchingDimension)
            if hitPlayer == localPlayer and matchingDimension and getDistanceBetweenPoints3D(localPlayer.position, source.position) <= 4 then
                local veh = getPedOccupiedVehicle(localPlayer)
                if getPedOccupiedVehicle(localPlayer) and getPedOccupiedVehicleSeat(localPlayer) == 0 then
                    if not panelState then
                        panelState = true
                        addEventHandler("onClientRender", root, drawnPanel2, true, "low-5")
                        addEventHandler("onClientClick", root, onClickEvent2)
                    end
                end
            end
        end
        --addEventHandler("onClientMarkerHit", gMarker, onStartMarkerHit)        
        
        function onStartMarkerLeave2(hitPlayer, matchingDimension)
            if hitPlayer == localPlayer and matchingDimension then
                local veh = getPedOccupiedVehicle(localPlayer)
                if getPedOccupiedVehicle(localPlayer) and getPedOccupiedVehicleSeat(localPlayer) == 0 then
                    if panelState then
                        panelState = false
                        removeEventHandler("onClientRender", root, drawnPanel2, true, "low-5")
                        removeEventHandler("onClientClick", root, onClickEvent2)
                    end
                end
            end
        end
        --addEventHandler("onClientMarkerLeave", gMarker, onStartMarkerLeave)
        
        function drawnPanel2()
            if isElement(gMarker2) and getDistanceBetweenPoints3D(gMarker2.position, localPlayer.position) >= 5 or not localPlayer.vehicle then
                if panelState then
                    panelState = false
                    removeEventHandler("onClientRender", root, drawnPanel2, true, "low-5")
                    removeEventHandler("onClientClick", root, onClickEvent2)
                end
            end

            local alpha = 255

            local font = exports['cr_fonts']:getFont('Poppins-SemiBold', 16)
            local font2 = exports['cr_fonts']:getFont('Poppins-Medium', 12)

            local w, h = 375, 120
            local x, y = sx/2 - w/2, sy/2 - h/2

            dxDrawRectangle(x, y, w, h, tocolor(51, 51, 51, alpha * 0.8))
            dxDrawImage(x + 10, y + 5, 25, 25, ":cr_account/files/logo-white.png", 0, 0, 0, tocolor(255, 255, 255, alpha))

            dxDrawText('Versenypálya', x + 10 + 25 + 10,y+5,x+w,y+5+25 + 4,tocolor(242, 242, 242, alpha),1,font,"left","center")

            selected = nil
            if exports['cr_core']:isInSlot(x + w - 10 - 15, y + 10, 15, 15) then 
                selected = 2 

                dxDrawImage(x + w - 10 - 15, y + 10, 15, 15, ":cr_inventory/assets/images/close.png", 0, 0, 0, tocolor(255, 59, 59, alpha))
            else 
                dxDrawImage(x + w - 10 - 15, y + 10, 15, 15, ":cr_inventory/assets/images/close.png", 0, 0, 0, tocolor(255, 59, 59, alpha * 0.6))
            end 

            local color = exports['cr_core']:getServerColor('green', true)
            dxDrawText("Szeretnél menni egy kört? "..color..gPrice2..white.."$-ba fog kerülni!", x, y + 40, x + w, y + 40, tocolor(242, 242, 242, alpha), 1, font2, "center", "top", false, false, false, true)

            if exports['cr_core']:isInSlot(x + w/2 - 150/2, y + 85, 150, 20) then 
                selected = 1

                dxDrawRectangle(x + w/2 - 150/2, y + 85, 150, 20, tocolor(97, 177, 90, alpha))
                dxDrawText('Igen', x, y + 85, x + w, y + 85 + 20 + 4, tocolor(242, 242, 242, alpha), 1, font2, "center", "center")
            else 
                dxDrawRectangle(x + w/2 - 150/2, y + 85, 150, 20, tocolor(97, 177, 90, alpha * 0.7))
                dxDrawText('Igen', x, y + 85, x + w, y + 85 + 20 + 4, tocolor(242, 242, 242, alpha * 0.6), 1, font2, "center", "center")
            end 
        end
        
        function onClickEvent2(b, s)
            if b == "left" and s == "down" then
                if selected == 1 then
                    if getTickCount() <= lastClickTick + 1000 then
                        return
                    end
                    lastClickTick = getTickCount()
                    
                    if panelState then
                        if exports['cr_core']:takeMoney(localPlayer, gPrice2) then
                            localPlayer.vehicle.position = Vector3(398.60223388672, 607.67535400391, 9.25)
                            localPlayer.vehicle.rotation = Vector3(0, 0, 296)
                            --exports['cr_infobox']:addBox("info", "Menj a kezdőrácsoknál található jelzéshez a kezdéshez!")
                            panelState = false
                            removeEventHandler("onClientRender", root, drawnPanel2, true, "low-5")
                            removeEventHandler("onClientClick", root, onClickEvent2)
                            --triggerServerEvent("gateOpen", localPlayer, localPlayer)
                            removeEventHandler("onClientMarkerHit", gMarker2, onStartMarkerHit2)        
                            removeEventHandler("onClientMarkerHit", gMarker2, onStartMarkerLeave2)    

                            removeEventHandler("onClientMarkerHit", gMarker3, onStartMarkerHit3)        
                            removeEventHandler("onClientMarkerHit", gMarker3, onStartMarkerLeave3)    

                            destroyElement(gMarker2)
                            isThisRace = true
                            triggerServerEvent("ghostMode", localPlayer, localPlayer.vehicle, "on")
                            destroyElement(gMarker3)

                            localPlayer.vehicle.frozen = true
                            exports['cr_controls']:toggleControl("accelerate", false, "instant")
                            if isElement(texElement) then destroyElement(texElement) end
                            if isElement(shadElement) then destroyElement(shadElement) end
                            
                            local v = "monitor"
                            texElement = dxCreateTexture("files/"..v..".png", textureQuality or "dxt1")
                            shadElement = dxCreateShader(":cr_texture/files/replace.fx", 0, 100, false, "all")
                            engineApplyShaderToWorldTexture(shadElement, v)
                            dxSetShaderValue(shadElement, "gTexture", texElement)

                            oStates = {localPlayer:getData("hudVisible"), localPlayer:getData("keysDenied"), exports['cr_custom-chat']:isChatVisible()}
                            localPlayer:setData("hudVisible", false)
                            localPlayer:setData("keysDenied", true)
                            exports['cr_custom-chat']:showChat(false)

                            local i = 1
                            startTimer = setTimer(
                                function()
                                    if isElement(texElement) then destroyElement(texElement) end
                                    if isElement(shadElement) then destroyElement(shadElement) end

                                    local v = "monitor-" .. i
                                    i = i + 1
                                    texElement = dxCreateTexture("files/"..v..".png", textureQuality or "dxt1")
                                    shadElement = dxCreateShader(":cr_texture/files/replace.fx", 0, 100, false, "all")
                                    engineApplyShaderToWorldTexture(shadElement, "monitor")
                                    dxSetShaderValue(shadElement, "gTexture", texElement)

                                    if i == 5 then
                                        --outputChatBox("Start")
                                        startTime = getTickCount()
                                        exports['cr_controls']:toggleControl("accelerate", true, "instant")
                                        localPlayer.vehicle.frozen = false
                                        localPlayer.vehicle.alpha = 255
                                        if isTimer(startTimer) then killTimer(startTimer) end

                                        addEventHandler("onClientRender", root, drawnHud, true, "low-5")
                                        sector = 0
                                        sectorTimes = {}
                                        generateNextSector()

                                        startingGridTimer = setTimer(
                                            function()
                                                if isElement(texElement) then destroyElement(texElement) end
                                                if isElement(shadElement) then destroyElement(shadElement) end
                                                if isElement(shader) then
                                                    destroyElement(shader)
                                                end
                                                if isElement(renderTarget) then
                                                    destroyElement(renderTarget)
                                                end
                                                if isTimer(renderTimer) then killTimer(renderTimer) end
                                                renderTarget = dxCreateRenderTarget(400/2, 150/2)
                                                shader = dxCreateShader("files/texturechanger.fx")
                                                dxSetShaderValue(shader, "nTexture", renderTarget)
                                                engineApplyShaderToWorldTexture(shader, "monitor")
                                            end, 2000, 1
                                        )
                                    end
                                end, 2000, 0
                            )
                        else
                            if panelState then
                                exports['cr_infobox']:addBox("error", "Nincs elég pénzed!")
                                panelState = false
                                removeEventHandler("onClientRender", root, drawnPanel2, true, "low-5")
                                removeEventHandler("onClientClick", root, onClickEvent2)
                            end
                        end
                    end
                elseif selected == 2 then
                    if panelState then
                        if getTickCount() <= lastClickTick + 500 then
                            return
                        end
                        lastClickTick = getTickCount()
                        panelState = false
                        removeEventHandler("onClientRender", root, drawnPanel2, true, "low-5")
                        removeEventHandler("onClientClick", root, onClickEvent2)
                    end
                end
                selected = nil
            end
        end
        
        function onStartMarkerHit3(hitPlayer, matchingDimension)
            if hitPlayer == localPlayer and matchingDimension and getDistanceBetweenPoints3D(localPlayer.position, source.position) <= 4 then
                local veh = getPedOccupiedVehicle(localPlayer)
                if getPedOccupiedVehicle(localPlayer) and getPedOccupiedVehicleSeat(localPlayer) == 0 then
                    if not panelState then
                        panelState = true
                        addEventHandler("onClientRender", root, drawnPanel3, true, "low-5")
                        addEventHandler("onClientClick", root, onClickEvent3)
                    end
                end
            end
        end
        --addEventHandler("onClientMarkerHit", gMarker, onStartMarkerHit)        
        
        function onStartMarkerLeave3(hitPlayer, matchingDimension)
            if hitPlayer == localPlayer and matchingDimension then
                local veh = getPedOccupiedVehicle(localPlayer)
                if getPedOccupiedVehicle(localPlayer) and getPedOccupiedVehicleSeat(localPlayer) == 0 then
                    if panelState then
                        panelState = false
                        removeEventHandler("onClientRender", root, drawnPanel3, true, "low-5")
                        removeEventHandler("onClientClick", root, onClickEvent3)
                    end
                end
            end
        end
        --addEventHandler("onClientMarkerLeave", gMarker, onStartMarkerLeave)
        
        function drawnPanel3()
            if isElement(gMarker3) and getDistanceBetweenPoints3D(gMarker3.position, localPlayer.position) >= 5 or not localPlayer.vehicle then
                if panelState then
                    panelState = false
                    removeEventHandler("onClientRender", root, drawnPanel3, true, "low-5")
                    removeEventHandler("onClientClick", root, onClickEvent3)
                end
            end

            local alpha = 255

            local font = exports['cr_fonts']:getFont('Poppins-SemiBold', 16)
            local font2 = exports['cr_fonts']:getFont('Poppins-Medium', 12)

            local w, h = 375, 120
            local x, y = sx/2 - w/2, sy/2 - h/2

            dxDrawRectangle(x, y, w, h, tocolor(51, 51, 51, alpha * 0.8))
            dxDrawImage(x + 10, y + 5, 25, 25, ":cr_account/files/logo-white.png", 0, 0, 0, tocolor(255, 255, 255, alpha))

            dxDrawText('Versenypálya', x + 10 + 25 + 10,y+5,x+w,y+5+25 + 4,tocolor(242, 242, 242, alpha),1,font,"left","center")

            selected = nil
            if exports['cr_core']:isInSlot(x + w - 10 - 15, y + 10, 15, 15) then 
                selected = 2 

                dxDrawImage(x + w - 10 - 15, y + 10, 15, 15, ":cr_inventory/assets/images/close.png", 0, 0, 0, tocolor(255, 59, 59, alpha))
            else 
                dxDrawImage(x + w - 10 - 15, y + 10, 15, 15, ":cr_inventory/assets/images/close.png", 0, 0, 0, tocolor(255, 59, 59, alpha * 0.6))
            end 

            local color = exports['cr_core']:getServerColor('green', true)
            dxDrawText("Szeretnél menni egy próbakört?", x, y + 40, x + w, y + 40, tocolor(242, 242, 242, alpha), 1, font2, "center", "top", false, false, false, true)

            if exports['cr_core']:isInSlot(x + w/2 - 150/2, y + 85, 150, 20) then 
                selected = 1

                dxDrawRectangle(x + w/2 - 150/2, y + 85, 150, 20, tocolor(97, 177, 90, alpha))
                dxDrawText('Igen', x, y + 85, x + w, y + 85 + 20 + 4, tocolor(242, 242, 242, alpha), 1, font2, "center", "center")
            else 
                dxDrawRectangle(x + w/2 - 150/2, y + 85, 150, 20, tocolor(97, 177, 90, alpha * 0.7))
                dxDrawText('Igen', x, y + 85, x + w, y + 85 + 20 + 4, tocolor(242, 242, 242, alpha * 0.6), 1, font2, "center", "center")
            end 
        end
        
        function onClickEvent3(b, s)
            if b == "left" and s == "down" then
                if selected == 1 then
                    if getTickCount() <= lastClickTick + 1000 then
                        return
                    end
                    lastClickTick = getTickCount()
                    
                    if panelState then
                        localPlayer.vehicle.position = Vector3(396.81677246094, 611.85760498047, 9.25)
                        localPlayer.vehicle.rotation = Vector3(0, 0, 296)
                        --exports['cr_infobox']:addBox("info", "Menj a kezdőrácsoknál található jelzéshez a kezdéshez!")
                        panelState = false
                        removeEventHandler("onClientRender", root, drawnPanel3, true, "low-5")
                        removeEventHandler("onClientClick", root, onClickEvent3)
                        --triggerServerEvent("gateOpen", localPlayer, localPlayer)
                        removeEventHandler("onClientMarkerHit", gMarker2, onStartMarkerHit2)        
                        removeEventHandler("onClientMarkerHit", gMarker2, onStartMarkerLeave2)    
                        
                        removeEventHandler("onClientMarkerHit", gMarker3, onStartMarkerHit3)        
                        removeEventHandler("onClientMarkerHit", gMarker3, onStartMarkerLeave3)    
                        
                        destroyElement(gMarker2)
                        destroyElement(gMarker3)
                        
                        isTryThisRace = true
                        
                        triggerServerEvent("ghostMode", localPlayer, localPlayer.vehicle, "on")
                        
                        localPlayer.vehicle.frozen = true
                        exports['cr_controls']:toggleControl("accelerate", false, "instant")
                        local v = "monitor"
                        texElement = dxCreateTexture("files/"..v..".png", textureQuality or "dxt1")
                        shadElement = dxCreateShader(":cr_texture/files/replace.fx", 0, 100, false, "all")
                        engineApplyShaderToWorldTexture(shadElement, v)
                        dxSetShaderValue(shadElement, "gTexture", texElement)
                        
                        oStates = {localPlayer:getData("hudVisible"), localPlayer:getData("keysDenied"), exports['cr_custom-chat']:isChatVisible()}
                        localPlayer:setData("hudVisible", false)
                        localPlayer:setData("keysDenied", true)
                        
                        local i = 1
                        startTimer = setTimer(
                            function()
                                if isElement(texElement) then destroyElement(texElement) end
                                if isElement(shadElement) then destroyElement(shadElement) end
                                
                                local v = "monitor-" .. i
                                i = i + 1
                                texElement = dxCreateTexture("files/"..v..".png", textureQuality or "dxt1")
                                shadElement = dxCreateShader(":cr_texture/files/replace.fx", 0, 100, false, "all")
                                engineApplyShaderToWorldTexture(shadElement, "monitor")
                                dxSetShaderValue(shadElement, "gTexture", texElement)
                                
                                if i == 5 then
                                    --outputChatBox("Start")
                                    startTime = getTickCount()
                                    localPlayer.vehicle.frozen = false
                                    exports['cr_controls']:toggleControl("accelerate", true, "instant")
                                    localPlayer.vehicle.alpha = 255
                                    if isTimer(startTimer) then killTimer(startTimer) end
                                    
                                    addEventHandler("onClientRender", root, drawnHud, true, "low-5")
                                    sector = 0
                                    sectorTimes = {}
                                    generateNextSector()
                                    
                                    startingGridTimer = setTimer(
                                        function()
                                            if isElement(texElement) then destroyElement(texElement) end
                                            if isElement(shadElement) then destroyElement(shadElement) end
                                            if isElement(shader) then
                                                destroyElement(shader)
                                            end
                                            if isElement(renderTarget) then
                                                destroyElement(renderTarget)
                                            end
                                            if isTimer(renderTimer) then killTimer(renderTimer) end
                                            renderTarget = dxCreateRenderTarget(400/2, 150/2)
                                            shader = dxCreateShader("files/texturechanger.fx")
                                            dxSetShaderValue(shader, "nTexture", renderTarget)
                                            engineApplyShaderToWorldTexture(shader, "monitor")
                                        end, 2000, 1
                                    )
                                end
                            end, 2000, 0
                        )
                    end
                elseif selected == 2 then
                    if panelState then
                        if getTickCount() <= lastClickTick + 500 then
                            return
                        end
                        lastClickTick = getTickCount()
                        panelState = false
                        removeEventHandler("onClientRender", root, drawnPanel3, true, "low-5")
                        removeEventHandler("onClientClick", root, onClickEvent3)
                    end
                end
                selected = nil
            end
        end
        
        --sector = 0
        function drawnHud()
            local font = exports['cr_fonts']:getFont("Rubik-Regular", 13, true)
            --local font = exports['cr_fonts']:getFont("Rubik-Regular", 14, true)
            local font2 = exports['cr_fonts']:getFont("Rubik-Regular", 11)
            local text1 = "S ".. sector .. "/" .. #sectorDetails + 1
            local x, y = sx - 350, 100
            dxDrawText(text1, x, y - 40, x + 300 - 10, y - 20, tocolor(255,255,255,255), 1, font, "right", "center")
            dxDrawRectangle(x, y, 300, 20, tocolor(0,0,0,150)) -- Alsó
            dxDrawRectangle(x, y - 20, 300, 20, tocolor(0,0,0,150)) -- Felső
            dxDrawText("Best", x, y - 20, x + 300 - 10, y, tocolor(255,255,255,255), 1, font2, "right", "center")
            dxDrawText((bestSectorDetails[sector + 1] and formatIntoTime(bestSectorDetails[sector + 1])) or "-----", x + 10, y - 20, x + 300, y, tocolor(255,255,255,255), 1, font2, "left", "center")
            dxDrawLine(x, y, x + 300, y, tocolor(255,255,255,150))
            dxDrawText("Now", x, y, x + 300 - 10, y + 20, tocolor(255,255,255,255), 1, font2, "right", "center")
            local text1 = formatIntoTime(getTickCount() - startTime)
            dxDrawText(text1, x + 10, y, x + 300, y + 20, tocolor(255,255,255,255), 1, font2, "left", "center")
            
            if (bestSectorDetails[sector + 1]) then
                if anim then
                    local now = getTickCount()
                    local elapsedTime = now - animStart
                    local duration = animEnd - animStart
                    local progress = elapsedTime / duration
                    local alpha, _, _ = interpolateBetween ( 
                        0, 0, 0,
                        255, 0, 0, 
                        progress, "OutBounce")
                    if tonumber(animText) <= 0 then
                        dxDrawRectangle(x, y + 20, 300, 20, tocolor(51,255,51,math.min(alpha, 150))) -- Felső
                    else
                        dxDrawRectangle(x, y + 20, 300, 20, tocolor(255,51,51,math.min(alpha, 150))) -- Felső
                    end
                    if progress >= 1 then
                        anim = false    
                    end
                    dxDrawText(formatIntoTime(animText, true), x + 10, y + 20, x + 300, y + 40, tocolor(255,255,255,alpha), 1, font2, "left", "center")
                end

                if not isTimer(startingGridTimer) and isElement(renderTarget) then
                    if getTickCount() >= lastFrame + 2000 then
                        dxSetRenderTarget(renderTarget, true)

                        dxDrawRectangle(0, 0, 400/2, 150/2, tocolor(54, 54, 54, 255))
                        dxDrawText(text1, 0, 0, 400/2, 150/2, tocolor(255, 255, 255, 255), 1, font, "center", "center", false, false, false, true)

                        dxSetRenderTarget()
                        lastFrame = getTickCount()
                    end
                end
            end
        end
        
--        addEventHandler("onClientRender", root, drawnHud)
        
        function func(hitPlayer, matchingDimension)
            if hitPlayer == localPlayer and matchingDimension then
                local num2 = getTickCount() - startTime
                if (bestSectorDetails[sector + 1]) then
                    alpha = 0
                    anim = true
                    animStart = getTickCount()
                    animEnd = animStart + 1000
                    local num = bestSectorDetails[sector + 1]
                    --num2 = getTickCount() - startTime
                    animText = num2 - num
                end
                removeEventHandler("onClientMarkerHit", source, func)    
                sectorTimes[sector] = num2
                destroyElement(gMarker4)
                generateNextSector()
            end
        end
        
        function generateNextSector()
            sector = sector + 1
            --sectorTimes[sector] = getTickCount()
            
            if not sectorDetails[sector] then -- last
                sectorTimes[sector] = getTickCount()  - startTime
                sectorTimes["last"] = getTickCount()  - startTime
                --outputDebugString(inspect(sectorTimes))
                --outputChatBox("Vége")
                
                exports['cr_infobox']:addBox("info", "Sikeresen futam! Idő: ".. formatIntoTime(sectorTimes["last"]))
                
                --oStates = {localPlayer:getData("hudVisible"), localPlayer:getData("keysDenied")}
                if oStates then
                    localPlayer:setData("hudVisible", oStates[1])
                    localPlayer:setData("keysDenied", oStates[2])
                    exports['cr_custom-chat']:showChat(oStates[3])
                end
                
                --triggerAFrissítésre!!
                
                removeEventHandler("onClientRender", root, drawnHud)
                
                if isElement(shader) then
                    destroyElement(shader)
                end
                
                if isElement(renderTarget) then
                    destroyElement(renderTarget)
                end
                
                if isElement(texElement) then
                    destroyElement(texElement)
                end
                
                if isElement(shadElement) then
                    destroyElement(shadElement)
                end
                
                if isElement(texElement) then destroyElement(texElement) end
                if isElement(shadElement) then destroyElement(shadElement) end
                if isElement(shader) then
                    destroyElement(shader)
                end
                if isElement(renderTarget) then
                    destroyElement(renderTarget)
                end
                renderTarget = dxCreateRenderTarget(420, 10 * 20)
                shader = dxCreateShader("files/texturechanger.fx")
                dxSetShaderValue(shader, "nTexture", renderTarget)
                engineApplyShaderToWorldTexture(shader, "monitor")
                --addEventHandler("onClientRender", root, renderTopList, true, "low-5")
                if isTimer(renderTimer) then killTimer(renderTimer) end
                renderTopList()
                renderTimer = setTimer(renderTopList, 2000, 0)
                
                if isThisRace then
                    --TRIGGER
                    isThisRace = nil
                    triggerServerEvent("playerTime", localPlayer, localPlayer, sectorTimes)
                end
                
                if isTryThisRace then
                    isTryThisRace = nil
                end
                
                triggerServerEvent("ghostMode", localPlayer, localPlayer.vehicle, "off")
                
                local r,g,b = exports['cr_core']:getServerColor("red")
                gMarker2 = Marker(398.60223388672, 607.67535400391, 8.1, "cylinder", 3.3, r,g,b)
                gMarker2:setData("marker >> customMarker", true)
                gMarker2:setData("marker >> customIconPath", ":cr_racetrack/files/racing-flag.png")

                addEventHandler("onClientMarkerHit", gMarker2, onStartMarkerHit2)        
                addEventHandler("onClientMarkerLeave", gMarker2, onStartMarkerLeave2)    

                local r,g,b = exports['cr_core']:getServerColor("red")
                gMarker3 = Marker(396.60668945313, 611.68218994141, 8.15, "cylinder", 3.3, r,g,b)
                gMarker3:setData("marker >> customMarker", true)
                gMarker3:setData("marker >> customIconPath", ":cr_racetrack/files/racing-flag.png")

                addEventHandler("onClientMarkerHit", gMarker3, onStartMarkerHit3)        
                addEventHandler("onClientMarkerLeave", gMarker3, onStartMarkerLeave3)    
                return
            end
            
            local x,y,z = unpack(sectorDetails[sector])
            gMarker4 = Marker(x,y,z, "checkpoint", 9, 210,49,49, 255)

            addEventHandler("onClientMarkerHit", gMarker4, func)    
        end
    end
)

function renderTopList()
    local font = exports['cr_fonts']:getFont("Rubik-Regular", 12)
    
    dxSetRenderTarget(renderTarget, true)
    
    dxDrawRectangle(0, 0, 420, 10 * 20, tocolor(54, 54, 54, 255))
    local startY = 0
    for i = 1, 10 do
        local v = playerTimes[i]
        if v then
            local modelid = playerTimes[i][5]
            local time, sectorDetails, playerName, playerID = unpack(v)
            --modelid = 502
            local time = formatIntoTime(time)
            dxDrawText("#"..i.." > "..time .. " - "..playerName .. " - " .. exports['cr_vehicle']:getVehicleName(modelid), 10, startY, 420, startY + 20, tocolor(255,255,255,255), 1, font, "left", "center")
            startY = startY + 20
        end
    end
    
    dxSetRenderTarget()
end

--Render
        
screenSize = {guiGetScreenSize()}
getCursorPos = getCursorPosition
function getCursorPosition()

    --outputChatBox(tostring(isCursorShowing()))
    if isCursorShowing() then
        --outputChatBox("asd")
        local x,y = getCursorPos()
        --outputChatBox("x"..tostring(x))
        --outputChatBox("y"..tostring(y))
        x, y = x * screenSize[1], y * screenSize[2] 
        return x,y
    else
        return -5000, -5000
    end
end

cursorState = isCursorShowing()
cursorX, cursorY = getCursorPosition()

function isInBox(dX, dY, dSZ, dM, eX, eY)
    if eX >= dX and eX <= dX+dSZ and eY >= dY and eY <= dY+dM then
        return true
    else
        return false
    end
end

function isInSlot(xS,yS,wS,hS)
    if isCursorShowing() then
        local cursorX, cursorY = getCursorPosition()
        if isInBox(xS,yS,wS,hS, cursorX, cursorY) then
            return true
        else
            return false
        end
    end 
end