local markers = {}
function createMarkers()
    for k,v in pairs(markerPositions) do 
        local x,y,z,dim,int = unpack(v)

        local marker = Marker(x,y,z, "cylinder", 1.5, 255, 235, 59)
        marker:setData("marker >> customMarker", true)
        marker:setData("marker >> customIconPath", ":cr_winemaker/assets/images/icon.png")
        marker:setData("lumberjack >> jobVehicleMarker", k)
        markers[marker] = k

        exports['cr_radar']:createStayBlip("Munkajármű felvétel: "..k, Blip(x, y, z, 0, 2, 255, 0, 0, 255, 0, 0), 0, "job_vehicle", 24, 24, 255, 255, 255)
    end 
end 

function destroyMarkers()
    for k,v in pairs(markers) do 
        if isElement(k) then 
            k:destroy()

            exports['cr_radar']:destroyStayBlip("Munkajármű felvétel: "..v)
        end 
    end 

    markers = {}

    if localPlayer:getData("char >> jobVehicle") then
        triggerLatentServerEvent("destroyJobVehicle", 5000, false, localPlayer, localPlayer)
    end     

    collectgarbage("collect")
end 

addEventHandler("onClientMarkerHit", resourceRoot, 
    function(hitPlayer, matchingDimension)
        if hitPlayer == localPlayer and matchingDimension then 
            if source:getData("lumberjack >> jobVehicleMarker") then 
                if getDistanceBetweenPoints3D(localPlayer.position, source.position) <= 2.5 and localPlayer.onGround then 
                    if localPlayer:getData("char >> jobVehicle") then 
                        exports['cr_jobvehicle']:openRequestPanel({
                            ["type"] = "destroy",
                            ["titleText"] = "Munkajármű leadása",
                            ["buttonText"] = "Leadás",
                        })
                    else 
                        local position = vehiclePositions[math.random(1, #vehiclePositions)]
                        exports['cr_jobvehicle']:openRequestPanel({
                            ["type"] = "request",
                            ["titleText"] = "Munkajármű igénylése",
                            ["buttonText"] = "Igénylés",
                            ["position"] = position,
                            ["vehicles"] = {422},
                            ["now"] = 1,

                            ['jobVehSettings'] = { 
                                ['customCol'] = {'sphere', {-481.57849121094, -180.01181030273, 78.035415649414, 20}},
                            },
                        })
                    end 
                end 
            end 
        end 
    end 
)

addEventHandler("onClientMarkerLeave", resourceRoot,
    function(hitPlayer, matchingDimension)
        if hitPlayer == localPlayer and matchingDimension then 
            if source:getData("lumberjack >> jobVehicleMarker") then 
                exports['cr_jobvehicle']:closeRequestPanel()
            end 
        end 
    end 
)