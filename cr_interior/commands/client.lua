function gpsInterior(cmd, id)
    if not id then
        if gpsState then
            if isTimer(gpsUpdateTimer) then killTimer(gpsUpdateTimer) end
            removeEventHandler("onClientMarkerHit", gpsMarker, finishGPS)
            if isElement(gpsMarker) then destroyElement(gpsMarker) end
            
            local syntax = exports['cr_core']:getServerSyntax(false, "success")
            exports['cr_radar']:destroyStayBlip("Ingatlanod!")
            exports['cr_infobox']:addBox("info", "GPS Poziciók törölve!")
            gpsState = false
            
            return
        else
            local syntax = exports['cr_core']:getServerSyntax(false, "warning")
            outputChatBox(syntax .. "/"..cmd.." [ID]", 255,255,255,true)
            return
        end
    elseif tonumber(id) == nil then
        local syntax = exports['cr_core']:getServerSyntax(false, "error")
        exports['cr_infobox']:addBox("error", "Az ID-nek egy számnak kell lennie!")
        
        return
    end
    
    local target = nil
    local id = math.floor(id)
    
    if gpsState then
        if isTimer(gpsUpdateTimer) then killTimer(gpsUpdateTimer) end
        removeEventHandler("onClientMarkerHit", gpsMarker, finishGPS)
        
        if isElement(gpsMarker) then destroyElement(gpsMarker) end
        
        local syntax = exports['cr_core']:getServerSyntax(false, "success")
        exports['cr_radar']:destroyStayBlip("Ingatlanod!")
        exports['cr_infobox']:addBox("info", "GPS Poziciók törölve!")
        gpsState = false
    else
        local target = false
        for k,v in pairs(getElementsByType("marker")) do
            local data = getElementData(v, "marker >> data")
            if data then
                local id2 = data["id"]
                if id2 == tonumber(id) then
                    local hasKey = exports['cr_inventory']:hasItem(localPlayer, 17, id2) or true
                    if hasKey then
                        target = v
                        
                        break
                    else
                        local green = exports['cr_core']:getServerColor("orange", true)
                        local syntax = exports['cr_core']:getServerSyntax(false, "error")
                        exports['cr_infobox']:addBox("error", "Nincs kulcsod a(z) "..id.." idjü ingatlanhoz!")
                        return
                    end
                end
            end
        end
        
        if target then
            local x,y,z = getElementPosition(target)
			local blip = createBlip(x,y,z,0,2,255,0,0,255,0,0)
			attachElements(blip, target)
            exports['cr_radar']:createStayBlip("Ingatlanod!",createBlip (x,y,z,0,2,255,0,0,255,0,0),1,"target",24,24,255,87,87)
            
            gpsState = true
            gpsMarker = createMarker(x,y,z, "checkpoint", 6)
            attachElements(gpsMarker, target)
            addEventHandler("onClientMarkerHit", gpsMarker, finishGPS)
            local syntax = exports['cr_core']:getServerSyntax(false, "success")
            exports['cr_infobox']:addBox("success", "Ingatlan megjelölve!")
        else
            local green = exports['cr_core']:getServerColor("orange", true)
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            exports['cr_infobox']:addBox("error", "Hibás ingatlan ID (ID: "..id..")")
        end
    end
end
addCommandHandler("gpsinterior", gpsInterior, false, false)

function finishGPS()
    if isTimer(gpsUpdateTimer) then killTimer(gpsUpdateTimer) end
    removeEventHandler("onClientMarkerHit", gpsMarker, finishGPS)
    if isElement(gpsMarker) then destroyElement(gpsMarker) end
    exports['cr_radar']:destroyStayBlip("Ingatlanod!")
    exports['cr_infobox']:addBox("success", "Megérkeztél a kijelölt ingatlanhoz!")
    gpsState = false
end