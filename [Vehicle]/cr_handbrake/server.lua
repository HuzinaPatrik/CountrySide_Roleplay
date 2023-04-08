addEvent("toggleHandbrake", true)
addEventHandler("toggleHandbrake", root, function(e, val) 
    e:setFrozen(val)
end)