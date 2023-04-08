function toggleMoveControls(e, val)
    exports['cr_controls']:toggleControl(e, "jump", val, "instant")
    exports['cr_controls']:toggleControl(e, "fire", val, "instant")
    exports['cr_controls']:toggleControl(e, "action", val, "instant")
    exports['cr_controls']:toggleControl(e, "crouch", val, "instant")
    exports['cr_controls']:toggleControl(e, "sprint", val, "instant")
    exports['cr_controls']:toggleControl(e, "enter_exit", val, "instant")
end 

addEvent("giveWoodToHand", true)
addEventHandler("giveWoodToHand", root, 
    function(e, model)
        if not e:getData("lumberjack >> objInHand") then 
            e:setData("lumberjack >> objInHand", tonumber(model))
            e:setData("forceAnimation", {"CARRY", "crry_prtial", 0, true, false, true, true})

            toggleMoveControls(e, false)
        end 
    end 
)

addEvent("destroyWoodFromHand", true)
addEventHandler("destroyWoodFromHand", root, 
    function(e)
        if e:getData('lumberjack >> objInHand') then 
            e:setData("lumberjack >> objInHand", nil)
            e:setData("forceAnimation", {"", ""})

            toggleMoveControls(e, true)
            collectgarbage("collect")
        end 
    end 
)

local timers = {}

addEvent("addWoodToVeh", true)
addEventHandler("addWoodToVeh", root, 
    function(veh, e, id)
        local woodData = veh:getData("lumberjack >> wood") or {}

        if e:getData('lumberjack >> objInHand') and veh and not woodData[id] then 
            local modelid = tonumber(e:getData('lumberjack >> objInHand') or 1463)
            e:setData("lumberjack >> objInHand", nil)

            toggleMoveControls(e, true)
            
            woodData[id] = {
                ['modelid'] = modelid,
            }

            veh:setData("lumberjack >> wood", woodData)

            collectgarbage("collect")
        end 
    end 
)

addEvent("takeWoodFromVeh", true)
addEventHandler("takeWoodFromVeh", root, 
    function(veh, e, id)
        local woodData = veh:getData("lumberjack >> wood") or {}

        if not e:getData('lumberjack >> objInHand') and veh and woodData[id] then 
            local modelid = woodData[id]['modelid'] or 1463

            woodData[id] = nil

            veh:setData("lumberjack >> wood", woodData)

            e:setData("lumberjack >> objInHand", modelid)

            toggleMoveControls(e, false)

            collectgarbage("collect")
        end 
    end 
)