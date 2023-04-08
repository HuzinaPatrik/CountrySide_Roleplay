addEventHandler("onVehicleStartExit", root, 
    function(player, seat, jacked)
        if isElement(source) then
            if getElementData(source, "veh >> locked") and not jacked then
                exports['cr_infobox']:addBox(player, "error", "A jármű jelenleg zárva van!")
                cancelEvent()
                return;
            elseif getElementData(player, "char >> belt") then
                exports['cr_infobox']:addBox(player, "error", "Addig nem tudsz kiszállni, míg be van kötve a biztonsági öved (F5)!")
                cancelEvent()
                return;
            elseif player:getData("taxipanel >> needPay") then 
                exports['cr_infobox']:addBox(player, "error", "Amíg nem fizeted ki a fuvart addig nem szállhatsz ki!")
                cancelEvent()
            end
        end 
    end
);

function playVehicleSound3D(sourcePlayer, sendTo, soundPath)
    triggerLatentClientEvent(sendTo, "playVehicleSound3D", 50000, false, sourcePlayer, sourcePlayer, soundPath)
end 
addEvent("playVehicleSound3D", true)
addEventHandler("playVehicleSound3D", root, playVehicleSound3D)

function syncBackFire(sourcePlayer, sendTo, soundPath)
    triggerLatentClientEvent(sendTo, "syncBackFire", 50000, false, sourcePlayer, sourcePlayer, soundPath)
end 
addEvent("syncBackFire", true)
addEventHandler("syncBackFire", root, syncBackFire)