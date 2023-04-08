addEventHandler("onVehicleDamage", root, function(loss)
    if(source:getData("veh >> engineBroken")) then
        if(source:getData("veh >> engine")) then
            source:getData("veh >> engine", false)
        end
        if(getVehicleEngineState(source)) then
            setVehicleEngineState(source, false)
        end
        if(getElementHealth(source) <= 300) then
            setElementHealth(source, 300)
        end  
        cancelEvent();
    end
    if(getElementHealth(source) <= 300) then
        if(getVehicleType(source) == "BMX") then return; end
        if(getElementHealth(source) <= 300) then
            setElementHealth(source, 300)
        end
        if(not getElementData(source, "veh >> engineBroken")) then
            setElementData(source, "veh >> engineBroken", true)
            if(getElementData(source, "veh >> engine")) then
                setElementData(source, "veh >> engine", false)
            end 
            if(getVehicleEngineState(source)) then
                setVehicleEngineState(source, false)
            end
        end
        cancelEvent()
    end
end)

function setElementHealthDriving(e, h, l)
    if not tonumber(l) then 
        l = 0 
    end 

	if not exports['cr_admin']:getAdminDuty(e) then
        setElementHealth(e, h);
        
		if l > 2 then
			triggerClientEvent(e, "onDamage", e, nil, nil, nil, l / 10);
		end
	end
end
addEvent("setElementHealthDriving", true)
addEventHandler("setElementHealthDriving", root, setElementHealthDriving)