addEventHandler("onClientVehicleEnter", root, 
    function(player, seat)
        if player == localPlayer then 
            if localPlayer.vehicle:getData('veh >> taxiPlate') then 
                if not isRender then 
                    isRender = true 

                    exports['cr_dx']:startFade("taxi >> panel", 
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

                    exports['cr_interface']:setNode("Taxipanel", "active", true)
                    createRender("drawnPanel", drawnPanel)
                end 
            end 
        end 
    end 
)

function createTaxiLamp(veh)
    if veh and not veh:getData('veh >> taxiPlate') then 
        veh:setData('veh >> taxiPlate', true)
        if veh == localPlayer.vehicle then 
            if localPlayer.vehicle:getData('veh >> taxiPlate') then 
                if not isRender then 
                    isRender = true 

                    exports['cr_dx']:startFade("taxi >> panel", 
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

                    exports['cr_interface']:setNode("Taxipanel", "active", true)
                    createRender("drawnPanel", drawnPanel)
                end 
            end
        end 

        local _, _, z1, _, _, z2 = getElementBoundingBox(veh)
        local z = z2 - 0.1
        triggerServerEvent('createTaxiLamp', localPlayer, veh, z)
    end 
end 
addEvent('createTaxiLamp', true)
addEventHandler('createTaxiLamp', root, createTaxiLamp)

function syncronizeTaxiLamp(veh)
    if veh and veh:getData('veh >> taxiPlate') then 
        local _, _, z1, _, _, z2 = getElementBoundingBox(veh)
        local z = z2 - 0.1
        triggerServerEvent('createTaxiLamp', localPlayer, veh, z)
    end 
end 
addEvent('syncTaxiLamp', true)
addEventHandler('syncTaxiLamp', root, syncTaxiLamp)

function destroyTaxiLamp(veh)
    if veh and veh:getData('veh >> taxiPlate') then 
        veh:setData('veh >> taxiPlate', false)

        triggerServerEvent('destroyTaxiLamp', localPlayer, veh)
    end 
end 

function drawnPanel()
    local alpha, progress = exports['cr_dx']:getFade("taxi >> panel")
    if not isRender then 
        if progress >= 1 then 
            exports['cr_interface']:setNode("Taxipanel", "active", false)
            destroyRender("drawnPanel")
            return 
        end  
    end 

    if not localPlayer.vehicle or not localPlayer.vehicle:getData('veh >> taxiPlate') then 
        if isRender then 
            isRender = false 

            exports['cr_dx']:startFade("taxi >> panel", 
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

        return 
    end 

    local x, y = exports['cr_interface']:getNode("Taxipanel", "x"), exports['cr_interface']:getNode("Taxipanel", "y")

    local buttons = 0 
    if not localPlayer.vehicle:getData("taxipanel >> state") then 
        buttons = 1
    elseif localPlayer.vehicle:getData("taxipanel >> state") == "start" then 
        buttons = 1
    elseif localPlayer.vehicle:getData("taxipanel >> state") == "finish" then 
        buttons = 1
    end 

    local w, h = 180, 100 --128
    if localPlayer.vehicleSeat ~= 0 then 
        h = 70
    end 
    
    local font = exports['cr_fonts']:getFont('Poppins-SemiBold', 16)
    local font2 = exports['cr_fonts']:getFont('Poppins-Medium', 14)

    dxDrawRectangle(x, y, w, h, tocolor(51, 51, 51, alpha * 0.8))
    dxDrawImage(x + 10, y + 5, 26, 30, ":cr_account/files/logo-white.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
	dxDrawText("Taxióra", x + 10 + 26 + 10,y+5,x+w,y+5+30 + 4,tocolor(242, 242, 242, alpha),1,font,"left","center")

    dxDrawRectangle(x + 15, y + 40, 150, 20, tocolor(51, 51, 51, alpha * 0.6))
    local blue = '#61b15a'
    local green = '#61b15a'
    local text = "#f2f2f2Díj "..blue.."($/km)#f2f2f2: "..price .. green .. " $"
    if localPlayer.vehicle:getData("taxipanel >> state") then 
        local price = tonumber(localPlayer.vehicle:getData("taxipanel >> price") or 0)
        text = "#f2f2f2Viteldíj "..blue.."($/km)#f2f2f2: "..price .. green .. " $"
    end 
    dxDrawText(text, x + 15 + 5, y + 40, x + 15 + 150, y + 40 + 20 + 4, tocolor(242, 242, 242, alpha), 1, font2, "left", "center", false, false, false, true)

    if localPlayer.vehicleSeat == 0 then 
        local text = "Elindítás"
        if localPlayer.vehicle:getData("taxipanel >> state") == "start" then 
            text = "Leállítás"
        elseif localPlayer.vehicle:getData("taxipanel >> state") == "finish" then 
            text = "Nullázás"
        end 

        hover = nil
        if exports['cr_core']:isInSlot(x + 15, y + 70, 150, 23) then 
            hover = true

            dxDrawRectangle(x + 15, y + 70, 150, 23, tocolor(97, 177, 90, alpha))
            dxDrawText(text, x + 15, y + 70, x + 15 + 150, y + 70 + 23 + 4, tocolor(242, 242, 242, alpha), 1, font2, "center", "center", false, false, false, true)
        else 
            dxDrawRectangle(x + 15, y + 70, 150, 23, tocolor(97, 177, 90, alpha * 0.7))
            dxDrawText(text, x + 15, y + 70, x + 15 + 150, y + 70 + 23 + 4, tocolor(242, 242, 242, alpha * 0.6), 1, font2, "center", "center", false, false, false, true)
        end 
    end
end 

addEventHandler("onClientClick", root, 
    function(b, s)
        if isRender then 
            if b == "left" and s == "down" then 
                if hover then 
                    if localPlayer.vehicleSeat == 0 then 
                        if not localPlayer.vehicle:getData("taxipanel >> state") then 
                            local hasPerm = false 
                            for k,v in pairs(localPlayer.vehicle.occupants) do 
                                if v ~= localPlayer then 
                                    v:setData("taxipanel >> needPay", localPlayer)
                                    localPlayer.vehicle:setData('taxipanel >> needToPay', v)
                                    hasPerm = true 
                                    break 
                                end 
                            end 

                            if hasPerm then 
                                if isTimer(odometerTimer) then killTimer(odometerTimer) end 
                                oldOdometerValue = math.floor(tonumber(localPlayer.vehicle:getData("veh >> odometer") or 0))
                                localPlayer.vehicle:setData("taxipanel >> price", 0)
                                localPlayer.vehicle:setData("taxipanel >> state", "start")

                                playSound('assets/sounds/taxibutton.mp3')
                                exports['cr_chat']:createMessage(localPlayer, "Odanyúl  a kezével a taxiórához majd el indítja.", 1)

                                odometerTimer = setTimer(
                                    function()
                                        if not isRender then 
                                            if isTimer(odometerTimer) then killTimer(odometerTimer) end 
                                            return
                                        end 

                                        local odometerVal = math.floor(tonumber(localPlayer.vehicle:getData("veh >> odometer") or 0))
                                        if oldOdometerValue ~= odometerVal then 
                                            local between = (odometerVal - oldOdometerValue) * price
                                            oldOdometerValue = odometerVal
                                            localPlayer.vehicle:setData("taxipanel >> price", localPlayer.vehicle:getData("taxipanel >> price") + between)
                                        end 
                                    end, 1000, 0
                                )
                            else 
                                exports['cr_infobox']:addBox("error", "A kocsiban nem ül senki olyan akit eltudnál szállítani!")
                            end 
                        elseif localPlayer.vehicle:getData("taxipanel >> state") == "start" then
                            localPlayer.vehicle:setData("taxipanel >> state", "finish")

                            playSound('assets/sounds/taxibutton.mp3')
                            exports['cr_chat']:createMessage(localPlayer, "Odanyúl a taxiórához majd megállítja ezt követően kinyomtatja a számlát.", 1)
                            playSound('assets/sounds/taxiprint.mp3')

                            for k,v in pairs(localPlayer.vehicle.occupants) do 
                                if v ~= localPlayer then 
                                    if v:getData("taxipanel >> needPay") then 
                                        local syntax = exports['cr_core']:getServerSyntax("Taxi", "info")
                                        local text = syntax .. "A fuvar fizetéséhez használd a /paytaxi parancsot!"
                                        triggerLatentServerEvent("outputChatBox", 5000, false, localPlayer, v, text)
                                        break 
                                    end 
                                end 
                            end 
                            if isTimer(odometerTimer) then killTimer(odometerTimer) end 
                        elseif localPlayer.vehicle:getData("taxipanel >> state") == "finish" then
                            if not localPlayer.vehicle:getData('taxipanel >> needToPay') then 
                                localPlayer.vehicle:setData("taxipanel >> state", nil)
                                playSound('assets/sounds/taxibutton.mp3')
                            else 
                                exports['cr_infobox']:addBox('error', 'Ameddig nincs kifizetve nem tudod nullázni!')
                            end 
                        end 
                    end 
                end 
            end 
        end 
    end 
)

addCommandHandler("paytaxi", 
    function()
        if localPlayer:getData("taxipanel >> needPay") then 
            if localPlayer.vehicle:getData("taxipanel >> state") == "finish" then
                if exports['cr_core']:takeMoney(localPlayer, tonumber(localPlayer.vehicle:getData("taxipanel >> price") or 0)) then 
                    exports['cr_core']:giveMoney(localPlayer:getData("taxipanel >> needPay"), tonumber(localPlayer.vehicle:getData("taxipanel >> price") or 0))
                    exports['cr_chat']:createMessage(localPlayer, "kifizeti a viteldíjat", 1)
                    localPlayer:getData("taxipanel >> needPay").vehicle:setData('taxipanel >> needToPay', nil)
                    localPlayer:setData("taxipanel >> needPay", nil)
                else 
                    exports['cr_infobox']:addBox("error", "Nincs elég pénzed")
                end 
            end 
        end 
    end 
)