function toggleMoveControls(e, val)
    exports['cr_controls']:toggleControl(e, "jump", val, "instant")
    exports['cr_controls']:toggleControl(e, "fire", val, "instant")
    exports['cr_controls']:toggleControl(e, "action", val, "instant")
    exports['cr_controls']:toggleControl(e, "crouch", val, "instant")
    exports['cr_controls']:toggleControl(e, "sprint", val, "instant")
    exports['cr_controls']:toggleControl(e, "enter_exit", val, "instant")
end 

addEvent("givePizzaToHand", true)
addEventHandler("givePizzaToHand", root, 
    function(e, model)
        if not e:getData("pizza >> objInHand") then 
            e:setData("pizza >> objInHand", tonumber(model))
            e:setData("forceAnimation", {"CARRY", "crry_prtial", 0, true, false, true, true})

            toggleMoveControls(e, false)
        end 
    end 
)

addEvent("destroyPizzaFromHand", true)
addEventHandler("destroyPizzaFromHand", root, 
    function(e)
        if e:getData('pizza >> objInHand') then 
            e:setData("pizza >> objInHand", nil)
            e:setData("forceAnimation", {"", ""})

            toggleMoveControls(e, true)
            collectgarbage("collect")
        end 
    end 
)

local timers = {}

addEvent("addPizzaToVeh", true)
addEventHandler("addPizzaToVeh", root, 
    function(veh, e, id)
        local pizzas = tonumber(veh:getData("pizza >> pizza") or 0)

        if pizzas + 1 <= 8 then 
            if e:getData('pizza >> objInHand') and veh then 
                local modelid = tonumber(e:getData('pizza >> objInHand') or 1582)
                e:setData("pizza >> objInHand", nil)

                toggleMoveControls(e, true)

                veh:setData("pizza >> pizza", pizzas + 1)

                collectgarbage("collect")
            end 
        end
    end 
)

addEvent("takePizzaFromVeh", true)
addEventHandler("takePizzaFromVeh", root, 
    function(veh, e, id)
        local pizzas = tonumber(veh:getData("pizza >> pizza") or 0)

        if pizzas - 1 >= 0 then 
            if not e:getData('pizza >> objInHand') and veh then 
                veh:setData("pizza >> pizza", pizzas - 1)

                e:setData("pizza >> objInHand", 1582)

                toggleMoveControls(e, false)

                collectgarbage("collect")
            end
        end 
    end 
)