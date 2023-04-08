local timers = {}

function onLock(source, state)
    local source = source
    local light1 = getElementData(source, "veh >> light");
    
    setElementData(source, "veh >> light", true);
    
    if isTimer(timers[source]) then killTimer(timers[source]) end
    timers[source] = setTimer(function()
        setElementData(source, "veh >> light", false);
            
        if isTimer(timers[source]) then killTimer(timers[source]) end
        timers[source] = setTimer(function()
            setElementData(source, "veh >> light",  light1);
        end, 400, 1);
    end, 400, 1);
end
addEvent("onLock", true);
addEventHandler("onLock", root, onLock);