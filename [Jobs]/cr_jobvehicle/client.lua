function openRequestPanel(data)
    if not isRender then 
        isRender = true
        gData = data

        exports['cr_dx']:startFade("jobvehicle >> panel", 
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

        createRender("drawnPanel", drawnPanel)
    end 
end 

function closeRequestPanel()
    if isRender then 
        isRender = false

        exports['cr_dx']:startFade("jobvehicle >> panel", 
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
    end 
end 

local sx, sy = guiGetScreenSize()
function drawnPanel()
    local alpha, progress = exports['cr_dx']:getFade("jobvehicle >> panel")
    if not isRender then 
        if progress >= 1 then 
            destroyRender("drawnPanel")
            return 
        end  
    end 

    specHover = nil
    specArrowHover = nil

    local font = exports['cr_fonts']:getFont('Poppins-SemiBold', 16)
    local font2 = exports['cr_fonts']:getFont('Poppins-Medium', 14)

	local w, h = 270, 30 + 15 + (gData["type"] == "request" and 155 or 40) + 60
	local x, y = sx/2 - w/2, sy/2 - h/2

	dxDrawRectangle(x, y, w, h, tocolor(51, 51, 51, alpha * 0.8))
	dxDrawImage(x + 10, y + 5, 25, 25, ":cr_account/files/logo-white.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
	dxDrawText(gData["titleText"], x + 10 + 25 + 10,y+5,x+w,y+5+25 + 4,tocolor(242, 242, 242, alpha),1,font,"left","center")

	if exports['cr_core']:isInSlot(x + w - 10 - 15, y + 10, 15, 15) then 
        specHover = 2   

        dxDrawImage(x + w - 10 - 15, y + 10, 15, 15, ":cr_inventory/assets/images/close.png", 0, 0, 0, tocolor(255, 59, 59, alpha))
    else 
        dxDrawImage(x + w - 10 - 15, y + 10, 15, 15, ":cr_inventory/assets/images/close.png", 0, 0, 0, tocolor(255, 59, 59, alpha * 0.6))
    end 

    local w2, h2 = 210, 110
    if gData["type"] == 'request' then 
        local y = y + 30 + 15 

        if #gData["vehicles"] > 1 then 
            if exports['cr_core']:isInSlot(x + 30/2 - 12/2, y + 25 + h2/2 - 10/2, 12, 10) then 
                specArrowHover = "left"
                dxDrawImage(x + 30/2 - 12/2, y + 25 + h2/2 - 10/2, 12, 10, ":cr_carshop/files/imgs/leftArrow.png", 0, 0, 0, tocolor(255, 59, 59, alpha))
            else 
                dxDrawImage(x + 30/2 - 12/2, y + 25 + h2/2 - 10/2, 12, 10, ":cr_carshop/files/imgs/leftArrow.png", 0, 0, 0, tocolor(242, 242, 242, alpha * 0.6))
            end 

            if exports['cr_core']:isInSlot(x + 30 + w2 + 30/2 - 12/2, y + 25 + h2/2 - 10/2, 12, 10) then 
                specArrowHover = "right"
                dxDrawImage(x + 30 + w2 + 30/2 - 12/2, y + 25 + h2/2 - 10/2, 12, 10, ":cr_carshop/files/imgs/leftArrow.png", 180, 0, 0, tocolor(255, 59, 59, alpha))
            else 
                dxDrawImage(x + 30 + w2 + 30/2 - 12/2, y + 25 + h2/2 - 10/2, 12, 10, ":cr_carshop/files/imgs/leftArrow.png", 180, 0, 0, tocolor(242, 242, 242, alpha * 0.6))
            end 
        end 

        exports['cr_dx']:dxDrawImageWithText(":cr_jobvehicle/assets/images/icon.png", 'Munkajármű', x + 30.5 + w2/2, y, x + 30.5 + w2/2, y + 25, tocolor(242, 242, 242, alpha), tocolor(242, 242, 242, alpha), 20, 15, 1, font2, 5, -2)
        dxDrawRectangle(x + 30, y + 25, w2, h2, tocolor(51, 51, 51, alpha))
        dxDrawImage(x + 30 + 3, y + 25 + 3, w2 - 6, h2 - 6, ":cr_jobvehicle/assets/images/"..gData["vehicles"][gData["now"]]..".png", 0, 0, 0, tocolor(255, 255, 255, alpha))
        dxDrawText(exports['cr_vehicle']:getVehicleName(gData["vehicles"][gData["now"]]) or '', x + 30, y + 25 + h2, x + 30 + w2, y + 25 + h2 + 20 + 4, tocolor(242, 242, 242, alpha), 1, font2, 'center', 'center')
    else 
        -- // Mégsem gomb
        local y = y + 30 + 15 + (gData["type"] == "request" and 155 or 0) + 10 + 30 + 10

        if exports['cr_core']:isInSlot(x + 30, y, w2, 30) then 
            specHover = 2

            dxDrawRectangle(x + 30, y, w2, 30, tocolor(255, 59, 59, alpha))
            dxDrawText('Mégsem', x + 30, y, x + 30 + w2, y + 30 + 4, tocolor(242, 242, 242, alpha), 1, font2, "center", "center")
        else 
            dxDrawRectangle(x + 30, y, w2, 30, tocolor(255, 59, 59, alpha * 0.6))
            dxDrawText('Mégsem', x + 30, y, x + 30 + w2, y + 30 + 4, tocolor(242, 242, 242, alpha * 0.6), 1, font2, "center", "center")
        end 
    end 

    local y = y + 30 + 15 + (gData["type"] == "request" and 155 or 0) + 10
    if exports['cr_core']:isInSlot(x + 30, y, w2, 30) then 
        specHover = 1

        dxDrawRectangle(x + 30, y, w2, 30, tocolor(97, 177, 90, alpha))
        dxDrawText(gData["buttonText"] or '', x + 30, y, x + 30 + w2, y + 30 + 4, tocolor(242, 242, 242, alpha), 1, font2, "center", "center")
    else 
        dxDrawRectangle(x + 30, y, w2, 30, tocolor(97, 177, 90, alpha * 0.6))
        dxDrawText(gData["buttonText"] or '', x + 30, y, x + 30 + w2, y + 30 + 4, tocolor(242, 242, 242, alpha * 0.6), 1, font2, "center", "center")
    end 
end 

addEventHandler("onClientClick", root, 
    function(b, s)
        if isRender then 
            if b == "left" and s == "down" then 
                if specArrowHover then 
                    if specArrowHover == "left" then 
                        gData["now"] = math.max(1, gData["now"] - 1)
                    elseif specArrowHover == "right" then 
                        gData["now"] = math.min(#gData["vehicles"], gData["now"] + 1)
                    end 

                    specArrowHover = nil 
                elseif specHover == 1 then 
                    if gData["type"] == "request" then 
                        triggerLatentServerEvent("createJobVehicle", 5000, false, localPlayer, localPlayer, gData["vehicles"][gData["now"]], gData["position"], gData['jobVehSettings'] or {})
                    else 
                        triggerLatentServerEvent("destroyJobVehicle", 5000, false, localPlayer, localPlayer)
                    end 
                    closeRequestPanel()
                    specHover = nil 
                elseif specHover == 2 then 
                    closeRequestPanel()
                    specHover = nil 
                end 
            end 
        end 
    end 
)

--[[
local blue = exports['cr_core']:getServerColor("blue", true)
openRequestPanel({
    ["type"] = "request",
    ["titleText"] = "Munkajármű "..blue.."igénylése",
    ["buttonText"] = "Igénylés",
    ["position"] = {-145.29344177246, -1369.9372558594, 2.6518149375916, 0, 0, 56},
    ["vehicles"] = {411,2,3},
    ["now"] = 1,
})

local red = exports['cr_core']:getServerColor("red", true)
openRequestPanel({
    ["type"] = "destroy",
    ["titleText"] = "Munkajármű "..red.."leadása",
    ["buttonText"] = "Leadás",
})]]

addEventHandler("onClientElementDataChange", localPlayer, 
    function(dName, oValue, nValue)
        if dName == "loggedIn" and nValue then 
            for k,v in pairs(getElementsByType("vehicle")) do 
                if v:getData("veh >> jobVehicle") and v:getData("veh >> jobVehicle") == localPlayer:getData("acc >> id") then 
                    localPlayer:setData("char >> jobVehicle", v)
                    triggerLatentServerEvent("killServerSideJobTimer", 5000, false, localPlayer, v)
                    break 
                end 
            end 
        end 
    end 
)

local start, startTimer;
local a;
addEventHandler("onClientVehicleEnter", root, 
    function(player, seat)
        if player == localPlayer then 
            if localPlayer:getData("char >> jobVehicle") and localPlayer:getData("char >> jobVehicle") == source then 
                if isTimer(respawnTimer) then killTimer(respawnTimer) end 
                exports['cr_infobox']:addBox("info", "Beszálltál a munkajárművedbe!")

                if source:getData('veh >> jobVehicle >> ghostMode') then 
                    if isTimer(startTimer) then killTimer(startTimer) end

                    start = true

                    gVeh = source;

                    local settings = source:getData('veh >> jobVehicle >> ghostMode >> settings') or {}

                    a = 15

                    if settings['customTime'] then 
                        a = tonumber(settings['customTime'])
                    end 

                    triggerServerEvent("ghostMode", localPlayer, localPlayer.vehicle, "on", true)

                    local hexCode = exports['cr_core']:getServerColor('yellow', true)
                    exports['cr_dx']:startInfoBar('#f2f2f2A munkajármű nem érintkezhet más játékosokkal és járművekkel még '..hexCode..a..'#f2f2f2 másodpercig!')

                    --[[
                        Settings
                    ]]
                    local e;

                    if settings['customCol'] then 
                        if isElement(settings['customCol']) then -- Létrehozva
                            e = settings['customCol']

                        else -- Létrehozásra készül
                            local type, createData = unpack(settings['customCol'])

                            if type == 'sphere' then 
                                e = createColSphere(unpack(createData))
                            elseif type == 'rectangle' then 
                                e = createColRectangle(unpack(createData))
                            elseif type == 'cuboid' then 
                                e = createColCuboid(unpack(createData))
                            elseif type == 'polygon' then 
                                e = createColPolygon(unpack(createData))
                            elseif type == 'tube' then 
                                e = createColTube(unpack(createData))    
                            elseif type == 'circle' then 
                                e = createColCircle(unpack(createData))    
                            end 

                            e.dimension = tonumber(createData['dimension'] or 0)
                            e.interior = tonumber(createData['interior'] or 0)

                            e:setData('destroyAfterLeave', true)
                        end 

                        if e then 
                            addEventHandler('onClientColShapeLeave', e, onColShapeLeave)
                        end 
                    end 

                    gCol = e;

                    startTimer = setTimer(
                        function(veh, e)
                            if veh and isElement(veh) then 
                                a = a - 1 

                                if a <= 0 then 
                                    start = false 
                                    
                                    exports['cr_dx']:closeInfoBar()

                                    veh:setData('veh >> jobVehicle >> ghostMode', false)

                                    triggerServerEvent("ghostMode", localPlayer, localPlayer.vehicle, "off", true)

                                    if e then 
                                        removeEventHandler('onClientColShapeLeave', e, onColShapeLeave)
                                    end 
                                else 
                                    local hexCode = exports['cr_core']:getServerColor('yellow', true)
                                    exports['cr_dx']:setInfoBarText('#f2f2f2A munkajármű nem érintkezhet más játékosokkal és járművekkel még '..hexCode..a..'#f2f2f2 másodpercig!')
                                end 
                            end 
                        end, 1 * 1000, a, source, e
                    )
                end 
            end 
        end 
    end 
)

function onColShapeLeave(leavingPlayer, matchingDimension)
    if leavingPlayer == localPlayer and localPlayer.vehicle and localPlayer.vehicle == gVeh and localPlayer:getData("char >> jobVehicle") and localPlayer:getData("char >> jobVehicle") == localPlayer.vehicle and matchingDimension then 
        if start then 
            if isTimer(startTimer) then killTimer(startTimer) end

            start = false 

            exports['cr_dx']:closeInfoBar()

            triggerServerEvent("ghostMode", localPlayer, localPlayer.vehicle, "off", true)

            removeEventHandler('onClientColShapeLeave', source, onColShapeLeave)

            if source:getData('destroyAfterLeave') then 
                source:destroy()
            end 

            localPlayer.vehicle:setData('veh >> jobVehicle >> ghostMode', false)
        end 
    end 
end 

addEventHandler("onClientVehicleExit", root, 
    function(player, seat)
        if player == localPlayer then 
            if localPlayer:getData("char >> jobVehicle") and localPlayer:getData("char >> jobVehicle") == source then 
                exports['cr_infobox']:addBox("info", "Kiszálltál a munkajárművedből, 15 perc múlva törlődik!")
                if isTimer(respawnTimer) then killTimer(respawnTimer) end 
                respawnTimer = setTimer(triggerLatentServerEvent, 15 * 60 * 1000, 1, "destroyJobVehicle", false, localPlayer, localPlayer)

                if start then 
                    if isTimer(startTimer) then killTimer(startTimer) end

                    start = false 

                    exports['cr_dx']:closeInfoBar()

                    triggerServerEvent("ghostMode", localPlayer, localPlayer.vehicle, "off", true)

                    if gCol then 
                        removeEventHandler('onClientColShapeLeave', gCol, onColShapeLeave)
                    end 
                end 
            end 
        end 
    end 
)

addEventHandler('onClientElementDestroy', root, 
    function()
        if start then 
            if localPlayer:getData("char >> jobVehicle") and localPlayer:getData("char >> jobVehicle") == source and source == gVeh then 
                if isTimer(respawnTimer) then killTimer(respawnTimer) end 
                
                if start then 
                    if isTimer(startTimer) then killTimer(startTimer) end

                    start = false 

                    exports['cr_dx']:closeInfoBar()

                    if gCol then 
                        removeEventHandler('onClientColShapeLeave', gCol, onColShapeLeave)

                        if gCol:getData('destroyAfterLeave') then 
                            gCol:destroy()
                        end 
                    end 
                end 
            end 
        end 
    end 
)