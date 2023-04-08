sx, sy = guiGetScreenSize()

local spamTimerDoorPanel = 0
function toggleDoorPanel()
    local veh = getPedOccupiedVehicle(localPlayer)
    
    if veh then
        if getVehicleType(veh) ~= "Automobile" then return end
        if windowState then return end
        if spamTimerDoorPanel + 500 > getTickCount() then return end
        spamTimerDoorPanel = getTickCount()
        
        if getPedOccupiedVehicleSeat(localPlayer) == 0 then
            doorState = not doorState
            
            if doorState then
                exports['cr_interface']:setNode('doorPanel', "active", true)

                createRender("drawnDoorPanel", drawnDoorPanel)

                exports["cr_dx"]:startFade("doorPanel", 
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
            else
                exports['cr_interface']:setNode('doorPanel', "active", false)

                exports["cr_dx"]:startFade("doorPanel", 
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
    end
end
addCommandHandler("doorpanel", toggleDoorPanel)
addCommandHandler("cveh", toggleDoorPanel)

addEventHandler("onClientVehicleExit", root,
    function(thePlayer, seat)
        if thePlayer == localPlayer then 
            if renderTimers["drawnDoorPanel"] then 
                doorState = false 
                exports["cr_dx"]:startFade("doorPanel", 
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
    end
)

function dxDrawRectangleBox2(left, top, width, height, color, color2)
    if not color then
        color = tocolor(44,44,44,255)
    end
    if not color2 then
        color2 = tocolor(33,33,33,255)
    end
    
    dxDrawRectangle(left, top, width, height, color)
end

function isInSlot(xS,yS,wS,hS)
    return exports['cr_core']:isInSlot(xS, yS, wS, hS)
end

local convertNumToComponent = {
    [0] = "bonnet_dummy", -- motorháztetó
    [1] = "door_lf_dummy", -- bal első
    [2] = "door_rf_dummy", -- jobb első
    [3] = "door_lr_dummy", -- bal hátsó
    [4] = "door_rr_dummy", -- jobb hátsó
}

local convertNumToDoorNum = {
    [0] = 0, -- motorháztető
    [1] = 2, -- bal első
    [2] = 3, -- jobb első
    [3] = 4, -- bal hátsó
    [4] = 5, -- jobb hátsó
}

local spamTimerClick = 0
addEventHandler("onClientClick", root, 
function(b, s)
        if b == "left" and s == "down" then
            if doorState then
                if spamTimerClick + 800 > getTickCount() then return end
                spamTimerClick = getTickCount()

                local veh = getPedOccupiedVehicle(localPlayer)
                if not veh then 
                    return 
                end

                local components = veh:getComponents()
                
                if hoverNum then 
                    if components[convertNumToComponent[hoverNum]] then 
                        local windowState = veh:getDoorOpenRatio(convertNumToDoorNum[hoverNum]) == 1
                        triggerLatentServerEvent("changeDoorState", 5000, false, localPlayer, veh, convertNumToDoorNum[hoverNum], windowState)

                        local newWindowState = windowState

                        if not newWindowState then
                            exports["cr_chat"]:createMessage(localPlayer, doorNames2[hoverNum]["open"], 1)
                        else
                            exports["cr_chat"]:createMessage(localPlayer, doorNames2[hoverNum]["close"], 1)
                        end

                        hoverNum = nil 
                    end
                end

                if closeHover then 
                    if renderTimers["drawnDoorPanel"] then 
                        if doorState then 
                            exports['cr_interface']:setNode('doorPanel', "active", false)

                            doorState = false 
                            exports["cr_dx"]:startFade("doorPanel", 
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

                    closeHover = nil
                end
            end
        end
    end
)

function drawnDoorPanel()
    local _, x, y, _w, _h = exports["cr_interface"]:getDetails("doorPanel")

    local font = exports['cr_fonts']:getFont('Poppins-SemiBold', 14)
    local font2 = exports['cr_fonts']:getFont('Poppins-Medium', 12)

    local fullHeight = 0
    for key = 0, #doorNames do 
        local w2, h2 = 160, 20

        fullHeight = fullHeight + h2 + 5
    end 

    local w, h = 210, 40 + 10 + 10 + (fullHeight - 5) + 10 + 10

    local veh = getPedOccupiedVehicle(localPlayer)
    if not veh then 
        return 
    end

    local alpha, progress = exports["cr_dx"]:getFade("doorPanel")
    if alpha and progress then 
        if progress >= 1 then 
            if alpha <= 0 then 
                destroyRender("drawnDoorPanel")
            end
        end
    end

    dxDrawRectangle(x, y, w, h, tocolor(51, 51, 51, alpha * 0.8))
    boxHover = exports['cr_core']:isInSlot(x,y,w,h)
    dxDrawImage(x + 10, y + 5, 25, 25, ":cr_account/files/logo-white.png", 0, 0, 0, tocolor(255, 255, 255, alpha))

    dxDrawText('Ajtók kezelése', x + 10 + 25 + 10,y+5,x+w,y+5+25 + 4,tocolor(242, 242, 242, alpha),1,font,"left","center")

    closeHover = nil
    if exports['cr_core']:isInSlot(x + w - 10 - 15, y + 10, 15, 15) then 
        closeHover = true 

        dxDrawImage(x + w - 10 - 15, y + 10, 15, 15, ":cr_inventory/assets/images/close.png", 0, 0, 0, tocolor(255, 59, 59, alpha))
    else 
        dxDrawImage(x + w - 10 - 15, y + 10, 15, 15, ":cr_inventory/assets/images/close.png", 0, 0, 0, tocolor(255, 59, 59, alpha * 0.6))
    end 

    dxDrawRectangle(x + 15, y + 50, 180, (fullHeight - 5) + 10 + 10, tocolor(41, 41, 41, alpha * 0.9))
    hoverComponent = nil

    local startX, startY = x + 15 + 10, y + 50 + 10

    hoverNum = nil 
    for key = 0, #doorNames do 
        local name = doorNames[key]

        local w2, h2 = 160, 20
        
        local inSlot = isCursorHover(startX, startY, w2, h2)
        local inSlot2 = isCursorHover(startX + w2 - 25 - 5, startY + h2/2 - 12/2, 25, 12)

        if inSlot then 
            dxDrawRectangle(startX, startY, w2, h2, tocolor(242, 242, 242, alpha * 0.8))
            dxDrawText(name, startX + 5, startY, startX + w2, startY + h2 + 4, tocolor(51, 51, 51, alpha), 1, font2, "left", "center")
        else 
            dxDrawRectangle(startX, startY, w2, h2, tocolor(51, 51, 51, alpha * 0.6))
            dxDrawText(name, startX + 5, startY, startX + w2, startY + h2 + 4, tocolor(242, 242, 242, alpha * 0.6), 1, font2, "left", "center")
        end 

        local windowState = veh:getDoorOpenRatio(convertNumToDoorNum[key]) == 1
        if windowState then 
            dxDrawImage(startX + w2 - 25 - 5, startY + h2/2 - 12/2, 25, 12, 'assets/images/slider-on.png', 0, 0, 0, tocolor(255, 255, 255, alpha))
        else 
            dxDrawImage(startX + w2 - 25 - 5, startY + h2/2 - 12/2, 25, 12, 'assets/images/slider-off.png', 0, 0, 0, tocolor(255, 255, 255, alpha))
        end

        startY = startY + h2 + 5

        if inSlot2 then 
            hoverNum = key

            exports['cr_dx']:drawTooltip(1, '#F2F2F2' .. (windowState and 'Bezárás' or 'Kinyitás'))
        end
    end
end

bindKey("accelerate", "down", 
    function()
        local veh = getPedOccupiedVehicle(localPlayer)
        if getPedOccupiedVehicleSeat(localPlayer) ~= 0 then return end
        if veh and isElementFrozen(veh) then
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax .. "Behúzott kézifékkel nem tudsz elindulni!", 255,255,255,true)
        end
    end
)

bindKey("brake_reverse", "down", 
    function()
        local veh = getPedOccupiedVehicle(localPlayer)
        if getPedOccupiedVehicleSeat(localPlayer) ~= 0 then return end
        if veh and isElementFrozen(veh) then
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax .. "Behúzott kézifékkel nem tudsz elindulni!", 255,255,255,true)
        end
    end
)