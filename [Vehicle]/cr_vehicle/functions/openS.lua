local timers = {}

addEventHandler("onElementDataChange", root, 
    function(dName, oValue, nValue)
        if dName == "veh >> stealWarning" then 
            if nValue then 
                if isTimer(timers[source]) then 
                    killTimer(timers[source]) 
                end 

                local source = source 
                timers[source] = setTimer(
                    function()
                        if not isElement(source) then 
                            if isTimer(timers[source]) then 
                                killTimer(timers[source]) 
                            end 

                            return 
                        end 

                        source:setData("veh >> light", not source:getData("veh >> light"))
                    end, 500, 0
                )
            else 
                if isTimer(timers[source]) then 
                    killTimer(timers[source]) 
                end 
            end 
        end 
    end 
)

addEventHandler("onElementDestroy", root, 
    function()
        if isTimer(timers[source]) then 
            killTimer(timers[source]) 
        end 
    end 
)