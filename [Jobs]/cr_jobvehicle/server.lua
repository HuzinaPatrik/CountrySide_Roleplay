addEvent("createJobVehicle", true)
addEventHandler("createJobVehicle", root, 
    function(sourcePlayer, model, position, jobVehSettings)
        if not sourcePlayer:getData("char >> jobVehicle") then 
            exports['cr_infobox']:addBox(sourcePlayer, "success", "Sikeresen igényeltél egy munkajárművet!")
            local x,y,z,dim,int,rot = unpack(position)
            local veh = exports["cr_vehicle"]:makeTemporaryVehicle(sourcePlayer, model, x, y, z, dim, int, 0, 0, rot, {math.random(0, 255), math.random(0, 255), math.random(0, 255)}, {255, 255}, true, nil, 1)
            sourcePlayer:setData("char >> jobVehicle", veh)
            veh:setData("veh >> jobVehicle", sourcePlayer:getData("acc >> id"))
            veh:setData("veh >> group", (sourcePlayer:getData("char >> group") or 0))
            veh:setData('veh >> jobVehicle >> ghostMode', true);
            veh:setData('veh >> jobVehicle >> ghostMode >> settings', jobVehSettings)
            veh:setData('veh >> tuningData', {["gps"] = 1})
        end 
    end 
)

addEvent("destroyJobVehicle", true)
addEventHandler("destroyJobVehicle", root, 
    function(sourcePlayer)
        if sourcePlayer:getData("char >> jobVehicle") then 
            exports['cr_infobox']:addBox(sourcePlayer, "success", "Sikeresen leadtad a munkajárművet!")

            local veh = sourcePlayer:getData("char >> jobVehicle")
            if isElement(veh) then 
                exports['cr_vehicle']:destroyTemporaryVehicle(veh:getData("veh >> id"))
            end 
            sourcePlayer:setData("char >> jobVehicle", nil)
        end 
    end 
)

local timers = {}
addEventHandler("onPlayerQuit", root, 
    function()
        if source:getData("char >> jobVehicle") then 
            local veh = source:getData("char >> jobVehicle")

            --veh:setData('veh >> jobVehicle >> ghostMode', true);

            if isElement(veh) then 
                if isTimer(timers[veh:getData("veh >> id")]) then killTimer(timers[veh:getData("veh >> id")]) end
                timers[veh:getData("veh >> id")] = setTimer(
                    function(veh)
                        if isElement(veh) then 
                            exports['cr_vehicle']:destroyTemporaryVehicle(veh:getData("veh >> id"))
                        end 
                    end, 30 * 60 * 1000, 1, veh
                )
            end
        end 
    end 
)

addEvent("killServerSideJobTimer", true)
addEventHandler("killServerSideJobTimer", root, 
    function(veh)
        if isElement(veh) then 
            if isTimer(timers[veh:getData("veh >> id")]) then 
                killTimer(timers[veh:getData("veh >> id")]) 
            end
        end 
    end 
)