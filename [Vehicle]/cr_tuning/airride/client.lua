local isRenderState, selected 

addCommandHandler("airride", 
    function(cmd)
        if localPlayer.vehicle then 
            if tonumber((localPlayer.vehicle:getData("veh >> tuningData") or {})["airride"] or 0) == 1 then 
                if not isRenderState then 
                    exports['cr_dx']:startFade("airride", 
                        {
                            ["startTick"] = getTickCount(),
                            ["lastUpdateTick"] = getTickCount(),
                            ["time"] = 250,
                            ["animation"] = "InOutQuad",
                            ["from"] = 0,
                            ["to"] = 255,
                            ["alpha"] = 0,
                            ["progress"] = 0,
                        }
                    )
                    isRenderState = true 
                    bindKey("backspace", "down", closeAirRidePanel)
                    createRender("drawnAirRide", drawnAirRide)
                    exports['cr_interface']:setNode("airride", "active", true)
                    oldLevel = tonumber((localPlayer.vehicle:getData("veh >> tuningData") or {})["airrideLevel"] or 3)
                    addEventHandler("onClientClick", root, onClick)
                else 
                    closeAirRidePanel()
                end 
            end 
        end 
    end 
)

function closeAirRidePanel()
    if isRenderState then 
        exports['cr_dx']:startFade("airride", 
            {
                ["startTick"] = getTickCount(),
                ["lastUpdateTick"] = getTickCount(),
                ["time"] = 250,
                ["animation"] = "InOutQuad",
                ["from"] = 255,
                ["to"] = 0,
                ["alpha"] = 255,
                ["progress"] = 0,
            }
        )
        isRenderState = false 
        unbindKey("backspace", "down", closeAirRidePanel)
        exports['cr_interface']:setNode("airride", "active", false)
        local tuningData = localPlayer.vehicle:getData("veh >> tuningData") or {}
        tuningData["airrideLevel"] = oldLevel 
        localPlayer.vehicle:setData("veh >> tuningData", tuningData)
        exports['cr_handling']:refreshHandling(localPlayer.vehicle)
        removeEventHandler("onClientClick", root, onClick)
    end 
end 

function drawnAirRide()
    local alpha, progress = exports['cr_dx']:getFade("airride")
    if not isRenderState then 
        if progress >= 1 then 
            destroyRender("drawnAirRide")
            return 
        end  
    end 

    if not localPlayer.vehicle or localPlayer:getData("inDeath") then 
        closeAirRidePanel()
    end 

    local x, y = exports['cr_interface']:getNode("airride", "x"), exports['cr_interface']:getNode("airride", "y")
    local w, h = 211, 415
    dxDrawImage(x, y, w, h, "files/airride/bg.png", 0, 0, 0, tocolor(255, 255, 255, alpha))

    local airrideLevel = tonumber((localPlayer.vehicle:getData("veh >> tuningData") or {})["airrideLevel"] or 3)
    local font = exports['cr_fonts']:getFont("DS-DIGI", 20)
    dxDrawText("Airride \n"..airrideLevel, x + 40, y + 70, x + 40 + 130, y + 70 + 100, tocolor(59, 94, 67, alpha), 1, font, "center", "center")

    selected = nil 

    if exports['cr_core']:isInSlot(x + 40, y + 192, 60, 37) then
        selected = 1
    elseif exports['cr_core']:isInSlot(x + 45, y + 230, 55, 37) then 
        selected = 2
    elseif exports['cr_core']:isInSlot(x + 50, y + 270, 50, 36) then 
        selected = 3 
    elseif exports['cr_core']:isInSlot(x + 110, y + 192, 60, 37) then 
        selected = 4 
    elseif exports['cr_core']:isInSlot(x + 110, y + 230, 55, 37) then
        selected = 5 
    elseif exports['cr_core']:isInSlot(x + 110, y + 270, 50, 36) then
        selected = 6
    end 
end 

function onClick(b, s)
    if isRenderState then 
        if b == "left" and s == "down" then 
            if tonumber(selected) then 
                if selected == 1 then --set 
                    local tuningData = localPlayer.vehicle:getData("veh >> tuningData") or {}
                    closeAirRidePanel()
                    localPlayer.vehicle:setData("veh >> tuningData", tuningData)
                    exports['cr_handling']:refreshHandling(localPlayer.vehicle)
                    playSound("files/airride/airride.mp3")
                elseif selected == 2 then --fel
                    local tuningData = localPlayer.vehicle:getData("veh >> tuningData") or {}
                    tuningData["airrideLevel"] = math.min(5, tonumber(tuningData["airrideLevel"] or 3) + 1)
                    localPlayer.vehicle:setData("veh >> tuningData", tuningData)
                    exports['cr_handling']:refreshHandling(localPlayer.vehicle)
                elseif selected == 3 then --kikapcs
                    closeAirRidePanel()
                elseif selected == 4 then --mégse
                    closeAirRidePanel()
                elseif selected == 5 then --le
                    local tuningData = localPlayer.vehicle:getData("veh >> tuningData") or {}
                    tuningData["airrideLevel"] = math.max(1, tonumber(tuningData["airrideLevel"] or 3) - 1)
                    localPlayer.vehicle:setData("veh >> tuningData", tuningData)
                    exports['cr_handling']:refreshHandling(localPlayer.vehicle)
                elseif selected == 6 then --default
                    local tuningData = localPlayer.vehicle:getData("veh >> tuningData") or {}
                    tuningData["airrideLevel"] = 3
                    localPlayer.vehicle:setData("veh >> tuningData", tuningData)
                    exports['cr_handling']:refreshHandling(localPlayer.vehicle)
                end 

                selected = nil 
            end 
        end 
    end 
end 