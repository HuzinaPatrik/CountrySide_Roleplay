function fixVehicleComponent(v, data)
    if v and isElement(v) and data then
        local typ, val, setVal = unpack(data) 
        --outputChatBox(type(typ) .. " "..inspect(typ))
        --outputChatBox(type(val) .. " "..inspect(val))
        --outputChatBox(type(setVal) .. " "..inspect(setVal)) 
        
        if typ == "panelState" then
            if type(val) == "table" then
                for _, num in pairs(val) do
                    v:setPanelState(num, setVal)
                end
            else
                v:setPanelState(val, setVal)
            end
        elseif typ == "doorState" then
            if type(val) == "table" then
                for _, num in pairs(val) do
                    v:setDoorState(num, setVal)
                end
            else
                v:setDoorState(val, setVal)
            end
        elseif typ == "wheelState" then
            v:setWheelStates(unpack(val))
        elseif typ == "health" then
            v.health = setVal
        elseif typ == "data" then
            if type(val) == 'table' and type(setVal) == 'table' then 
                for k2,v2 in pairs(val) do 
                    v:setData(val[k2], setVal[k2])
                end 
            else 
                v:setData(val, setVal)
            end 
        elseif typ == "lightState" then
            if type(val) == "table" then
                for _, num in pairs(val) do
                    v:setLightState(num, setVal)
                end
            else
                v:setLightState(val, setVal)
            end
        end
    end
end
addEvent("fixVehicleComponent", true)
addEventHandler("fixVehicleComponent", root, fixVehicleComponent)

function cloneVehicle(sourceElement, v, offsets, component, ignore)
    --outputChatBox(component)
    local x,y,z = v.position.x, v.position.y, v.position.z + 5
    local clonedVeh = cloneElement(v, x,y,z-10)
    setTimer(setVehicleEngineState, 400, 1, clonedVeh, false)
    clonedVeh:setData("parent", v)
    v:setData(component.."->parent", clonedVeh)
    --v:setData("comp", component)
    sourceElement:setData("doingState", {v, component})
    clonedVeh.health = 1000
    clonedVeh:setData("cloned", true)
    clonedVeh.frozen = true
    clonedVeh:attach(sourceElement, unpack(offsets))
    --setTimer(triggerClientEvent, 200, 1, sourceElement, "syncComponent", sourceElement, sourceElement, clonedVeh, component)
    setElementCollisionsEnabled(clonedVeh, false)
    setTimer(setVehicleDamageProof, 50, 1, clonedVeh,  true)
	setTimer(setElementFrozen, 50, 1, clonedVeh, true)
    clonedVeh.alpha = 0
    setTimer(
        function() 
            clonedVeh:setData("hide", {[component] = true})
            --setTimer(setElementCollisionsEnabled, 200, 1, clonedVeh, false)
            if ignore then
                clonedVeh.alpha = 0
            else
                clonedVeh.alpha = 255
            end
        end, 400, 1
    )
end
addEvent("cloneVehicle", true)
addEventHandler("cloneVehicle", root, cloneVehicle)

function destroyClonedVehicle(sourceElement, v, component)
    --outputChatBox(component)
    --outputChatBox(inspect(sourceElement))
    --outputChatBox(inspect(v))
    local clonedVeh = v:getData(component .. "->parent")
    --outputChatBox(inspect(clonedVeh))
    if isElement(clonedVeh) then
        --local component = v:getData("hide")
        v:setData(component.."->doing", false)
        destroyElement(clonedVeh)
        
        sourceElement:setData("doingState", nil)
        triggerClientEvent(sourceElement, "resetDoingState", sourceElement)
    end
    resetVehHidedComp(v, component)
end
addEvent("destroyClonedVehicle", true)
addEventHandler("destroyClonedVehicle", root, destroyClonedVehicle)

function toggleAlpha(sourceElement, v, a)
    v.alpha = a
end
addEvent("toggleAlpha", true)
addEventHandler("toggleAlpha", root, toggleAlpha)

function resetVehHidedComp(v, comp)
    --local comp = v:getData("hide")
    --outputChatBox(comp)
    --v:setData(comp.."->hide", 1)

    if comp then
        local data = getConvertData(v, comp)
        --outputChatBox(inspect(data))
        local typ, val = unpack(data) 

        if typ == "panelState" then
            --outputChatBox(type(val) .. " "..inspect(val))
            --outputChatBox(type(setVal) .. " "..inspect(setVal))
            if type(val) == "table" then
                for _, num in pairs(val) do
                    local setVal = v:getPanelState(num)
                    v:setPanelState(num, 0)
                    v:setPanelState(num, setVal)
                end
            else
                local setVal = v:getPanelState(val)
                v:setPanelState(val, 0)
                v:setPanelState(val, setVal)
            end
        elseif typ == "doorState" then
            --outputChatBox(type(val) .. " "..inspect(val))
            --outputChatBox(type(setVal) .. " "..inspect(setVal))
            if type(val) == "table" then
                for _, num in pairs(val) do
                    local setVal = v:getDoorState(num)
                    v:setDoorState(num, 0)
                    v:setDoorState(num, setVal)
                end
            else
                local setVal = v:getDoorState(val)
                v:setDoorState(val, 0)
                v:setDoorState(val, setVal)
            end
        elseif typ == "wheelState" then
            local setVal = {v:getWheelStates()}
            v:setWheelStates(0,0,0,0)
            v:setWheelStates(unpack(setVal))
        elseif typ == "health" then
            local setVal = v.health
            v.health = setVal
        elseif typ == "data" then
            local setVal = v:getData(val)
            v:setData(val, setVal)
        elseif typ == "lightState" then
            if type(val) == "table" then
                for _, num in pairs(val) do
                    local setVal = v:getLightState(num)
                    v:setLightState(num, 0)
                    v:setLightState(num, setVal)
                end
            else
                local setVal = v:getLightState(val)
                v:setLightState(val, 0)
                v:setLightState(val, setVal)
            end
        end
    end
end
addEvent("resetVehHidedComp", true)
addEventHandler("resetVehHidedComp", root, resetVehHidedComp)

function onPlayerQuit()
    if source:getData("doingState") and type(source:getData("doingState")) == "table" then
        local table = source:getData("doingState")
        destroyClonedVehicle(source, table[1], table[2])
    end
end
addEventHandler("onPlayerQuit", root, onPlayerQuit)