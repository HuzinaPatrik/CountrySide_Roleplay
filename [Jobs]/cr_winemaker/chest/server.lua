function toggleMoveControls(e, val)
    exports['cr_controls']:toggleControl(e, "jump", val, "instant")
    exports['cr_controls']:toggleControl(e, "fire", val, "instant")
    exports['cr_controls']:toggleControl(e, "action", val, "instant")
    exports['cr_controls']:toggleControl(e, "crouch", val, "instant")
    exports['cr_controls']:toggleControl(e, "sprint", val, "instant")
    exports['cr_controls']:toggleControl(e, "enter_exit", val, "instant")
end 

addEvent("giveChestToHand", true)
addEventHandler("giveChestToHand", root, 
    function(e, model)
        if not e:getData("winemaker >> objInHand") then 
            e:setData("winemaker >> objInHand", tonumber(model))
            e:setData("forceAnimation", {"CARRY", "crry_prtial", 0, true, false, true, true})

            toggleMoveControls(e, false)
        end 
    end 
)

addEvent("destroyChestFromHand", true)
addEventHandler("destroyChestFromHand", root, 
    function(e)
        if e:getData('winemaker >> objInHand') then 
            e:setData("winemaker >> objInHand", nil)
            e:setData("forceAnimation", {"", ""})

            toggleMoveControls(e, true)
            collectgarbage("collect")
        end 
    end 
)

local timers = {}

addEvent("addChestToVeh", true)
addEventHandler("addChestToVeh", root, 
    function(veh, e, id)
        local chestData = veh:getData("winemaker >> chest") or {}

        if e:getData('winemaker >> objInHand') and veh and not chestData[id] then 
            local modelid = tonumber(e:getData('winemaker >> objInHand') or 7251)
            e:setData("winemaker >> objInHand", nil)

            toggleMoveControls(e, true)
            
            chestData[id] = {
                ['modelid'] = modelid,
            }

            veh:setData("winemaker >> chest", chestData)

            collectgarbage("collect")
        end 
    end 
)

addEvent("takeChestFromVeh", true)
addEventHandler("takeChestFromVeh", root, 
    function(veh, e, id)
        local chestData = veh:getData("winemaker >> chest") or {}

        if not e:getData('winemaker >> objInHand') and veh and chestData[id] then 
            local modelid = chestData[id]['modelid'] or 7251

            chestData[id] = nil

            veh:setData("winemaker >> chest", chestData)

            e:setData("winemaker >> objInHand", modelid)

            toggleMoveControls(e, false)

            collectgarbage("collect")
        end 
    end 
)