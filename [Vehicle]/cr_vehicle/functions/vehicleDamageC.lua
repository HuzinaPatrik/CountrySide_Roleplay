function setElementHealthDriving(e, h, l)
    if not tonumber(l) then 
        l = 0 
    end 
    
    if e == localPlayer then
        if not exports['cr_admin']:getAdminDuty(e) then
            setElementHealth(e, h);
            
            if l > 2 then
                triggerEvent("onDamage", localPlayer, nil, nil, nil, l / 10);
            end
        end
    else
        if l > 2 then 
            triggerServerEvent("setElementHealthDriving", localPlayer, e, h, l / 10);
        end 
    end
end

addEventHandler("onClientVehicleDamage", root, function(attacker, weapon, loss)
    local veh = getPedOccupiedVehicle(localPlayer);
    if veh then
        if veh == source then
            local seat = getPedOccupiedVehicleSeat(localPlayer);
            if seat == 0 then
                if not attacker and not weapon then
                    local occupants = getVehicleOccupants(veh);
                        
                    for k,v in pairs(occupants) do
                        if not getElementData(v, "char >> belt") then
                            local oldHealth = getElementHealth(v);
                            local newHealth = oldHealth - ((loss/math.random(8, 10)) * vehicleDamageMultiplier[veh:getData('veh >> virtuaModellID') or veh.model]);
                            setElementHealthDriving(v, newHealth, loss);
                        else
                            local oldHealth = getElementHealth(v);
                            local newHealth = oldHealth - ((loss/math.random(10, 12)) * vehicleDamageMultiplier[veh:getData('veh >> virtuaModellID') or veh.model]);
                            setElementHealthDriving(v, newHealth, loss);
                        end
                    end
                end
            end
        end
    end

    if source:getData("veh >> locked") then 
        if getElementVelocity(source) == 0 then
            if tonumber((source:getData("veh >> tuningData") or {})["stealwarning"] or 0) == 1 then 
                if not source:getData("veh >> stealWarning") then 
                    source:setData("veh >> stealWarning", true)
                end 
            end 
        end 
    end 

    if getElementData(source, "veh >> engineBroken") then
        if getElementData(source, "veh >> engine") then
            setElementData(source, "veh >> engine", false);
        end
            
        if getVehicleEngineState(source) then
            setVehicleEngineState(source, false);
        end
            
        if getElementHealth(source) <= 300 then
            setElementHealth(source, 300);
        end
            
        cancelEvent();
        return;
    end

    if getElementHealth(source) <= 300 then
        if getElementHealth(source) <= 300 then
            setElementHealth(source, 300);
        end
            
        if not getElementData(source, "veh >> engineBroken") then
            setElementData(source, "veh >> engineBroken", true);
                
            if getElementData(source, "veh >> engine") then
                setElementData(source, "veh >> engine", false);
            end
            if getVehicleEngineState(source) then
                setVehicleEngineState(source, false);
            end
        end
            
        cancelEvent();
        return;
    end

    if localPlayer.vehicle == source then 
        if localPlayer.vehicleSeat == 0 then 
            if source.health > 300 and source.health <= 550 then 
                if source.engineState and not source:getData("veh >> engineBroken") then 
                    local chance = (1 - (source.health - 300) / 250) * 100
                    local rand = math.random(1, 100)
                    --outputChatBox(inspect(rand).. " >> "..inspect(chance))
                    if rand <= chance then 
                        if source:getData("veh >> engine") then
                            source:setData("veh >> engine", false)
                        end
                        if source.engineState then
                            source:setEngineState(false)
                        end

                        exports['cr_infobox']:addBox("error", "Lefulladt a járműved!")
                    end
                end 
            end
        end 
    end 
end);

setTimer(function()
    local veh = getPedOccupiedVehicle(localPlayer);
    if veh and getPedOccupiedVehicleSeat(localPlayer) == 0 and not disabledType[getVehicleType(veh)] then
        if getElementHealth(veh) <= 300 then
            setElementHealth(veh, 300);
            cancelEvent();
                
            if not getElementData(veh, "veh >> engineBroken") then
                setElementData(veh, "veh >> engineBroken", true);
                    
                if getElementData(veh, "veh >> engine") then
                    setElementData(veh, "veh >> engine", false);
                end
                    
                if getVehicleEngineState(veh) then
                    setVehicleEngineState(veh, false);
                end
            end
        elseif getElementHealth(veh) > 300 then
            if getVehicleType(veh) ~= "BMX" then
                local lastOilRecoil = getElementData(veh, "veh >> lastOilRecoil");
                local odometer = getElementData(veh, "veh >> odometer");
                if lastOilRecoil + 1000 > odometer then
                    if getElementData(veh, "veh >> engineBroken") then
                        setElementData(veh, "veh >> engineBroken", false);
                    end
                end
            else
                if getElementData(veh, "veh >> engineBroken") then
                    setElementData(veh, "veh >> engineBroken", false);
                end
            end
        end
    end
end, 2000, 0);

setTimer(
    function()
        for k,v in pairs(getElementsByType("vehicle", root, true)) do 
            if v.health <= 300 then 
                v.health = 300

                if not getElementData(v, "veh >> engineBroken") then
                    setElementData(v, "veh >> engineBroken", true);
                        
                    if getElementData(v, "veh >> engine") then
                        setElementData(v, "veh >> engine", false);
                    end

                    if getVehicleEngineState(v) then
                        setVehicleEngineState(v, false);
                    end
                end
            end 
        end 
    end, 1000, 0
)