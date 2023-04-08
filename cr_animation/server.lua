local timers = {}

function applyAnimation(element, block, anim, time, loop, updatePosition, interruptable, freezeLastFrame, blendTime)
    local forceAnim = false
    local forceAnimation = getElementData(element, "forceAnimation") or {"", ""}
    if forceAnimation[1] ~= "" or forceAnimation[2] ~= "" then
        forceAnim = true
    end
    if forceAnim then
        return
    end
    
    if time == nil then 
        time = -1 
    end
    if loop == nil then
        loop = true 
    end
    if updatePosition == nil then 
        updatePosition = true
    end
    setPedAnimation(element, block, anim, time, loop, updatePosition, interruptable)
    if time > 100 then
        if isTimer(timers[element]) then 
            killTimer(timers[element]) 
        end 
        timers[element] = setTimer(setPedAnimation, 50, 2, element, block, anim, time, loop, updatePosition, interruptable)
    end
    if time > 50 then
        if isTimer(timers[element]) then 
            killTimer(timers[element]) 
        end 
        timers[element] = setTimer(removeAnimation, time, 1, element)
    end
    setElementData(element, "realAnimation", true)
end
addEvent("applyAnimation", true)
addEventHandler("applyAnimation", root, applyAnimation)

function removeAnimation(element)
    setPedAnimation(element)
    setElementData(element, "realAnimation", false)
end
addEvent("removeAnimation", true)
addEventHandler("removeAnimation", root, removeAnimation)

addEventHandler("onElementDataChange", root,
    function(dName, oValue, value)
        if dName == "forceAnimation" then
            --iprint(value)
            if value and type(value) == "table" then 
                if value[1] == "" and value[2] == "" then
                    if isTimer(timers[source]) then 
                        killTimer(timers[source]) 
                    end 
                    --setPedAnimation(source, "ped", "WOMAN_walknorm")
                    setPedAnimation(source, "ped", "WOMAN_walknorm")
                    timers[source] = setTimer(setPedAnimation, 50, 1, source, "", "")
                elseif value[3] then 
                    if isTimer(timers[source]) then 
                        killTimer(timers[source]) 
                    end 
                    setPedAnimation(source, unpack(value))
                    if value[3] > 0 then 
                        timers[source] = setTimer(setElementData, value[3], 1, source, "forceAnimation", nil)
                    end 
                else 
                    setPedAnimation(source, value[1], value[2], -1, true, false, true)
                end
            end 
        end
    end
)