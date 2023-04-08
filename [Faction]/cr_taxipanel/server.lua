local cache = {}

function createTaxiLamp(veh, zOffset)
    if not cache[veh] then 
        local obj = Object(16178, veh.position)
        obj.collisions = false 
        obj:attach(veh, 0, -0.5, zOffset)

        cache[veh] = obj
    end 
end 
addEvent('createTaxiLamp', true)
addEventHandler('createTaxiLamp', root, createTaxiLamp)

function destroyTaxiLamp(veh) 
    if cache[veh] then 
        cache[veh]:destroy()
        cache[veh] = nil 
        collectgarbage('collect');
    end 
end 
addEvent('destroyTaxiLamp', true)
addEventHandler('destroyTaxiLamp', root, destroyTaxiLamp)