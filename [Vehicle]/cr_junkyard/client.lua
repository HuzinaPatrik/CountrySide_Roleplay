local sx, sy = guiGetScreenSize()
local white = "#F2F2F2"

function hitJunkCP(hitPlayer, matchingDimension)
    if hitPlayer == localPlayer and matchingDimension and getDistanceBetweenPoints3D(localPlayer.position, source.position) <= 3 then
        if getElementData(source, "junkyard") then
            local veh = getPedOccupiedVehicle(localPlayer)
            if getPedOccupiedVehicle(localPlayer) then
                if localPlayer.vehicleSeat == 0 then
                    local vehId = veh:getData("veh >> owner") or -1
                    local vehId2 = veh:getData("veh >> id") or -1
                    local accId = localPlayer:getData("acc >> id") or -2

                    if vehId == accId and vehId2 >= 1 then
                        gVeh = veh
                        gMarker = source
                        start = true

                        createRender('renderPanel', renderPanel)
                        addEventHandler("onClientClick", root, panelClick)

                        exports["cr_dx"]:startFade("junkyardPanel", 
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

                        vehid = getElementModel(gVeh)
                        vehiclePrice = exports['cr_carshop']:getVehiclePrice(veh, 1) or 0
                        local carHealthMp = getElementHealth(gVeh) / 1000

                        vehiclePrice = math.floor(vehiclePrice*multipler*carHealthMp)
                    else
                        exports['cr_infobox']:addBox("error", "Ez nem a te járműved!")
                    end
                end
            end
        end
    end
end
addEventHandler("onClientMarkerHit", root, hitJunkCP)

function closeJunkYard()
    if start then
        start = false

        exports["cr_dx"]:startFade("junkyardPanel", 
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

        removeEventHandler("onClientClick", root, panelClick)
    end
end 

function leaveJunkCP(hitPlayer, matchingDimension)
    if hitPlayer == localPlayer and matchingDimension then
        if getElementData(source, "junkyard") then
            local veh = getPedOccupiedVehicle(localPlayer)
            if getPedOccupiedVehicle(localPlayer) then
                closeJunkYard()
            end
        end
    end
end
addEventHandler("onClientMarkerLeave", root, leaveJunkCP)

function renderPanel()
    local nowTick = getTickCount()
    local alpha, progress = exports["cr_dx"]:getFade("junkyardPanel")
    if not start then
        if progress >= 1 then 
            destroyRender('renderPanel')

            return
        end
    end
    
    if not localPlayer.vehicle or gMarker:getData("using") then
        closeJunkYard()

        return 
    end

    local font = exports['cr_fonts']:getFont('Poppins-SemiBold', 16)
    local font2 = exports['cr_fonts']:getFont('Poppins-Medium', 12)
    local font3 = exports['cr_fonts']:getFont('Poppins-Medium', 14)

    local w, h = 400, 446
    local x, y = sx/2 - w/2, sy/2 - h/2

    dxDrawRectangle(x, y, w, h, tocolor(51, 51, 51, alpha * 0.8))

	dxDrawImage(x + 10, y + 5, 25, 25, ":cr_account/files/logo-white.png", 0, 0, 0, tocolor(255, 255, 255, alpha))

	dxDrawText('Roncstelep', x + 10 + 25 + 10,y+5,x+w,y+5+25 + 4,tocolor(242, 242, 242, alpha),1,font,"left","center")

    selected = nil
	if exports['cr_core']:isInSlot(x + w - 10 - 15, y + 10, 15, 15) then 
		selected = 2

        dxDrawImage(x + w - 10 - 15, y + 10, 15, 15, ":cr_inventory/assets/images/close.png", 0, 0, 0, tocolor(255, 59, 59, alpha))
    else 
        dxDrawImage(x + w - 10 - 15, y + 10, 15, 15, ":cr_inventory/assets/images/close.png", 0, 0, 0, tocolor(255, 59, 59, alpha * 0.6))
    end 

    dxDrawImage(x + w/2 - 144/2, y + 260/2 - 144/2, 144, 144, "files/icon.png", 0, 0, 0, tocolor(255, 255, 255, alpha))

    dxDrawRectangle(x, y + 260, w, 120, tocolor(41, 41, 41, alpha * 0.48))

    local green = exports['cr_core']:getServerColor('green', true)
    local red = exports['cr_core']:getServerColor('red', true)
    dxDrawText("Járműved bezúzatásáért kapsz egy adott összeget.\nAmennyiben tényleg beszeretnéd zúzatni a járművedet,\nakkor kattints a "..green.."‘Zúzás’"..white.."  gombra,\nviszont ha nem szeretnéd akkor "..red.."zárd"..white.." be a panelt!\nÁr: "..green.. '$ '..vehiclePrice, x, y + 260, x + w, y + 260 + 120 + 4, tocolor(242, 242, 242, alpha), 1, font2, "center", "center", false, false, false, true)

    local startY = y + 395
    local buttonW, buttonH = 150, 30
    if exports['cr_core']:isInSlot(x + w/2 - buttonW/2, startY, buttonW, buttonH) then 
        selected = 1

        dxDrawRectangle(x + w/2 - buttonW/2, startY, buttonW, buttonH, tocolor(97, 177, 90, alpha)) 
        dxDrawText('Zúzás', x, startY, x + w, startY + buttonH + 4, tocolor(242, 242, 242, alpha), 1, font3, 'center', 'center')
    else
        dxDrawRectangle(x + w/2 - buttonW/2, startY, buttonW, buttonH, tocolor(97, 177, 90, alpha * 0.6)) 
        dxDrawText('Zúzás', x, startY, x + w, startY + buttonH + 4, tocolor(242, 242, 242, alpha * 0.7), 1, font3, 'center', 'center')
    end 
end

addEvent("changeMultipler", true)
addEventHandler("changeMultipler", root, 
    function(mp)
        multipler = mp
    end
)    

addEvent("getData", true)
addEventHandler("getData", root, 
    function(datas)
        gMarker = datas[1]
        craneObj = datas[2]
        crObj = datas[3]


        addEventHandler("onClientElementDataChange", craneObj,
            function(dName)
                if source == craneObj then
                    if dName == "startPos" then
                        if isElementStreamedIn(craneObj) then
                            local val = source:getData(dName)
                            if val then
                                if not lineState then
                                    startPos = val
                                    lineState = true

                                    createRender('drawnLines', drawnLines)
                                end
                            else
                                if lineState then
                                    lineState = false
                                    
                                    destroyRender('drawnLines')
                                end
                            end
                        end
                    end
                end
            end
        )
    end
)    


function onStart()
    triggerServerEvent("requestMultipler", localPlayer, localPlayer)
end
addEventHandler("onClientResourceStart", resourceRoot, onStart)

lastClickTick = 0

function panelClick(button, state, absoluteX, absoluteY, worldX, worldY, worldZ, clickedElement)
    if button == "left" and state == "down" then
        if start then 
            if selected == 2 then
                closeJunkYard()
            elseif selected == 1 then
                local now = getTickCount()
                if now <= lastClickTick + 1000 then
                    return
                end
                
                if gMarker:getData("using") then 
                    return 
                end

                if exports['cr_network']:getNetworkStatus() then 
                    return 
                end

                if not localPlayer.vehicle then 
                    return 
                end

                lastClickTick = getTickCount()

                closeJunkYard()

                exports['cr_infobox']:addBox("success", "Sikeresen bezúzattad a járműved $ "..vehiclePrice.." ért!")
                exports['cr_core']:giveMoney(localPlayer, vehiclePrice)

                local _, _, z1, _, _, z2 = getElementBoundingBox(localPlayer.vehicle)
                local z = math.abs(z1) + math.abs(z2)
                triggerServerEvent("acceptOffer", localPlayer, localPlayer, z)
            end

            selected = nil
        end 
    end
end

addEventHandler("onClientKey",root,
	function(bill,press)
		if bill == "enter" and start and not isChatBoxInputActive() then
            cancelEvent()
            if press then
                local now = getTickCount()
                if now <= lastClickTick + 1000 then
                    return
                end
                
                if gMarker:getData("using") then 
                    return 
                end

                if exports['cr_network']:getNetworkStatus() then 
                    return 
                end

                if not localPlayer.vehicle then 
                    return 
                end

                lastClickTick = getTickCount()

                closeJunkYard()

                exports['cr_infobox']:addBox("success", "Sikeresen bezúzattad a járműved $ "..vehiclePrice.." ért!")
                exports['cr_core']:giveMoney(localPlayer, vehiclePrice)

                local _, _, z1, _, _, z2 = getElementBoundingBox(localPlayer.vehicle)
                local z = math.abs(z1) + math.abs(z2)
                triggerServerEvent("acceptOffer", localPlayer, localPlayer, z)

                return
            end
		elseif bill == "backspace" and start and not isChatBoxInputActive() then
			if press then
                closeJunkYard()

                return
            end
		end
	end
)

--3dLine
function drawnLines()
    if isElementStreamedIn(craneObj) then
        dxDrawLine3D(startPos[1], startPos[2], startPos[3], craneObj.position, tocolor(0,0,0,255), 10)
    end
end