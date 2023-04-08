white = "#ffffff"

function getConvertData(element, k)
    
    --outputChatBox(k)
    local convertData = {}
    
    if k == "bump_front_dummy" then
        convertData[1] = "panelState" -- // Type
        convertData[2] = 5 -- // The Value
        convertData[3] = 0 -- // The SetValue
    elseif k == "bump_rear_dummy" then
        convertData[1] = "panelState" -- // Type
        convertData[2] = 6 -- // The Value
        convertData[3] = 0 -- // The SetValue
    elseif k == "door_lf_dummy" then
        convertData[1] = "doorState" -- // Type
        convertData[2] = 2 -- // The Value
        convertData[3] = 0 -- // The SetValue
    elseif k == "door_rf_dummy" then
        convertData[1] = "doorState" -- // Type
        convertData[2] = 3 -- // The Value
        convertData[3] = 0 -- // The SetValue
    elseif k == "door_rr_dummy" then 
        convertData[1] = "doorState" -- // Type
        convertData[2] = 5 -- // The Value
        convertData[3] = 0 -- // The SetValue
    elseif k == "door_lr_dummy" then
        convertData[1] = "doorState" -- // Type
        convertData[2] = 4 -- // The Value
        convertData[3] = 0 -- // The SetValue
    elseif k == "bonnet_dummy" then
        convertData[1] = "doorState" -- // Type
        convertData[2] = 0 -- // The Value
        convertData[3] = 0 -- // The SetValue
    elseif k == "boot_dummy" then
        convertData[1] = "doorState" -- // Type
        convertData[2] = 1 -- // The Value
        convertData[3] = 0 -- // The SetValue
    elseif k == "wheel_lf_dummy" then
        convertData[1] = "wheelState" -- // Type
        if element:getData("cloned") then
            convertData[2] = {0, 2, 2, 2} -- // The Value
        else
            convertData[2] = {0, -1, -1, -1} -- // The Value
        end
        convertData[3] = 0 -- // The SetValue
    elseif k == "wheel_rf_dummy" then 
        convertData[1] = "wheelState" -- // Type
        if element:getData("cloned") then
            convertData[2] = {2, 2, 0, 2} -- // The Value
        else
            convertData[2] = {-1, -1, 0, -1} -- // The Value
        end
        convertData[3] = 0 -- // The SetValue
    elseif k == "wheel_lb_dummy" then 
        convertData[1] = "wheelState" -- // Type
        if element:getData("cloned") then
            convertData[2] = {2, 0, 2, 2} -- // The Value
        else
            convertData[2] = {-1, 0, -1, -1} -- // The Value
        end
        convertData[3] = 0 -- // The SetValue
    elseif k == "wheel_rb_dummy" then 
        convertData[1] = "wheelState" -- // Type
        if element:getData("cloned") then
            convertData[2] = {2, 2, 2, 0} -- // The Value
        else
            convertData[2] = {-1, -1, -1, 0} -- // The Value
        end
        convertData[3] = 0 -- // The SetValue
    elseif k == "bonnet_dummy2" then
        convertData[1] = "health" -- // Type
        convertData[2] = "" -- // The Value
        convertData[3] = 1000 -- // The SetValue
    elseif k == "bonnet_dummy3" then
        convertData[1] = "data" -- // Type
        convertData[2] = "veh >> lastOilRecoil" -- // The Value
        convertData[3] = tonumber(getElementData(element, "veh >> odometer") or 0) -- // The SetValue
    elseif k == "bonnet_dummy4" then
        convertData[1] = "panelState" -- // Type
        convertData[2] = 4 -- // The Value
        convertData[3] = 0 -- // The SetValue
    elseif k == "bump_front_dummy2" then
        convertData[1] = "lightState" -- // Type
        convertData[2] = {0,1,2,3} -- // The Value
        convertData[3] = 0 -- // The SetValue
    elseif k == "bump_front_dummy3" then
        convertData[1] = "panelState" -- // Type
        convertData[2] = {0,1,2,3} -- // The Value
        convertData[3] = 0 -- // The SetValue
    elseif k == 'chassis' then 
        convertData[1] = "health" -- // Type
        convertData[2] = "" -- // The Value
        convertData[3] = 1000 -- // The SetValue
    elseif k == 'bonnet_dummy6' then 
        convertData[1] = "data" -- // Type
        convertData[2] = {'veh >> fuel', "veh >> fueltype"} -- // The Value
        convertData[3] = {5, element:getData('veh >> oldfueltype')} -- // The SetValue
    end
    
    --outputChatBox(inspect(convertData))
    return convertData
end

function isComponentDamaged(v, k)  
    if isElement(v) then   
        if k == "bump_front_dummy" then
            return getVehiclePanelState(v, 5) > 0
        elseif k == "bump_rear_dummy" then
            return getVehiclePanelState(v, 6) > 0
        elseif k == "door_lf_dummy" then
            return v:getDoorState(2) > 0
        elseif k == "door_rf_dummy" then
            return v:getDoorState(3) > 0
        elseif k == "door_rr_dummy" then 
            return v:getDoorState(5) > 0
        elseif k == "door_lr_dummy" then
            return v:getDoorState(4) > 0
        elseif k == "bonnet_dummy" then
            return v:getDoorState(0) > 0
        elseif k == "boot_dummy" then
            return v:getDoorState(1) > 0
        elseif k == "wheel_lf_dummy" then
            local frontLeft, rearLeft, frontRight, rearRight = getVehicleWheelStates(v)
            return frontLeft > 0
        elseif k == "wheel_rf_dummy" then 
            local frontLeft, rearLeft, frontRight, rearRight = getVehicleWheelStates(v)
            return frontRight > 0
        elseif k == "wheel_lb_dummy" then 
            local frontLeft, rearLeft, frontRight, rearRight = getVehicleWheelStates(v)
            return rearLeft > 0
        elseif k == "wheel_rb_dummy" then 
            local frontLeft, rearLeft, frontRight, rearRight = getVehicleWheelStates(v)
            return rearRight > 0
        elseif k == "bonnet_dummy2" then
            local health = v.health

            if health then 
                return health < 1000
            end
        elseif k == "bonnet_dummy3" then
            return tonumber(getElementData(v, "veh >> odometer") or 0) - tonumber(getElementData(v,"veh >> lastOilRecoil") or 0) >= 500
            --return true
        elseif k == "bonnet_dummy4" then
            return getVehiclePanelState(v, 4) > 0
        elseif k == "bump_front_dummy2" then
            for i = 0, 3 do
                if getVehicleLightState(v, i) > 0 then
                    return true 
                end
            end
            return false
        elseif k == "bump_front_dummy3" then
            for i = 0, 3 do
                if getVehiclePanelState(v, i) > 0 then
                    return true 
                end
            end
            return false
        elseif k == "bonnet_dummy5" then
            return true
        elseif k == 'chassis' then 
            if v.vehicleType == 'Bike' or v.vehicleType == 'BMX' or v.vehicleType == 'Quad' then 
                local health = v.health

                if health then 
                    return health < 1000
                end
            end
        elseif k == 'bonnet_dummy6' then 
            return v:getData('veh >> fueltype') ~= v:getData('veh >> oldfueltype')
        end 
    end
    
    return false
end

function isComponentMissing(v, k)     -- // Innen folytasd!
    --outputChatBox(k)
    if k == "bump_front_dummy" then
        return getVehiclePanelState(v, 5) >= 3
    elseif k == "bump_rear_dummy" then
        return getVehiclePanelState(v, 6) >= 3
    elseif k == "door_lf_dummy" then
        return v:getDoorState(2) >= 4
    elseif k == "door_rf_dummy" then
        return v:getDoorState(3) >= 4
    elseif k == "door_rr_dummy" then 
        return v:getDoorState(5) >= 4
    elseif k == "door_lr_dummy" then
        return v:getDoorState(4) >= 4
    elseif k == "bonnet_dummy" then
        --outputChatBox(inspect(v))
        --outputChatBox(tostring(v:getData("cloned")))
        --outputChatBox(v:getDoorState(0))
        return v:getDoorState(0) >= 4
    elseif k == "boot_dummy" then
        return v:getDoorState(1) >= 4
    elseif k == "wheel_lf_dummy" then
        local frontLeft, rearLeft, frontRight, rearRight = getVehicleWheelStates(v)
        return frontLeft >= 2
    elseif k == "wheel_rf_dummy" then 
        local frontLeft, rearLeft, frontRight, rearRight = getVehicleWheelStates(v)
        return frontRight >= 2
    elseif k == "wheel_lb_dummy" then 
        local frontLeft, rearLeft, frontRight, rearRight = getVehicleWheelStates(v)
        return rearLeft >= 2
    elseif k == "wheel_rb_dummy" then 
        local frontLeft, rearLeft, frontRight, rearRight = getVehicleWheelStates(v)
        return rearRight >= 2
    elseif k == "bonnet_dummy2" then
        local health = v.health
        return false --health < 1000
    elseif k == "bonnet_dummy3" then
        return false -- tonumber(getElementData(v, "veh >> odometer") or 0) - tonumber(getElementData(v,"veh >> lastOilRecoil") or 0) >= 500
        --return true
    elseif k == "bonnet_dummy4" then
        return getVehiclePanelState(v, 4) >= 3
    elseif k == "bump_front_dummy2" then
        --[[
        for i = 0, 3 do
            if getVehicleLightState(v, i) > 0 then
                return true 
            end
        end
        ]]
        return false
    elseif k == "bump_front_dummy3" then
        for i = 0, 3 do
            if getVehiclePanelState(v, i) >= 3 then
                return true 
            end
        end
        return false
    elseif k == "bonnet_dummy5" then
        return true
    elseif k == "chassis" then
        return false
    elseif k == 'bonnet_dummy6' then 
        return v:getData('veh >> fueltype') ~= v:getData('veh >> oldfueltype')
    end
    
    --outputChatBox(k.."!")
    return false
end

function getComponentPosOffsets(v, a, rot, k2, _k, disabled)
    local x,y,z = getVehicleComponentPosition(v, k2, "world")
    local x0, y0, z0, x1, y1, z1 = getElementBoundingBox(v)
    local rot = rot
    local offsets = a
    if offsets[4] then
        if offsets[4] == "y" then
            x,y = getElementPosition(v)
            offsets[2] = (math.abs(y0)) + offsets[1]
        elseif offsets[4] == "y2" then
            x,y = getElementPosition(v)
            offsets[2] = -(math.abs(y0))
        elseif offsets[4] == "rot" then
            local r1, r2, r3 = getVehicleComponentRotation(v, k2, "world")
            rot = Vector3(r1, r2, r3)
            --local _x, _y = offsets[1], offsets[2]
            --outputChatBox(r1)
        elseif offsets[4] == "bonnet_dummy" then
            --outputChatBox(offsets[3])
            if offsets[3] == "-z" or _k == "bonnet_dummy3" or _k == "bonnet_dummy5" or _k == "bonnet_dummy6" then
                local x,y,z = getElementPosition(v)
                offsets[3] = z0 - 0.1
                --outputChatBox(z.. " "..localPlayer.position.z+0.5)
                if z <= localPlayer.position.z + 0.5 then
                    disabled = true
                end
            else
                local r1, r2, r3 = getVehicleComponentRotation(v, "bonnet_dummy", "root")
                --outputChatBox(r1)
                local r1 = math.floor(r1)
                if gOffsets[v.model] then 
                    if r1 ~= gOffsets[v.model]["bonnet_open-ratio"][1] then
                        disabled = true
                    end
                end
            end
            --rot = Vector3(r1, r2, r3)
        end
        --offsets[4] = nil
    end

    if _k == "bonnet_dummy" then
        local r1, r2, r3 = getVehicleComponentRotation(v, "bonnet_dummy", "root")
        local r1 = math.floor(r1)
        --outputChatBox(r1)
        if gOffsets[v.model] then 
            if r1 ~= gOffsets[v.model]["bonnet_open-ratio"][2] then
                disabled = true
            end
        end
    end 

    if _k == "boot_dummy" then
        local r1, r2, r3 = getVehicleComponentRotation(v, "boot_dummy", "root")
        local r1 = math.floor(r1)
        --outputChatBox(r1)
        if gOffsets[v.model] then 
            if r1 ~= gOffsets[v.model]["boot_open-ratio"][2] then
                disabled = true
            end
        end
    end

    local pos
    if offsets[1] ~= 0 or offsets[2] ~= 0 or offsets[3] ~= 0 then
        local vehMatrix = Matrix(x,y,z, rot)
        local x,y,z = unpack(offsets)
        if offsets[4] == "rot" then
            if isSpecVeh[v.model]then
                if _k == "door_rr_dummy" then
                    local _x = x
                    x = y
                    y = _x
                elseif _k == "door_lr_dummy" then
                    local _x = x
                    x = math.abs(y)
                    y = _x
                end
            end
        end
        pos = vehMatrix:transformPosition(x,y,z)
    else
        pos = Vector3(x, y, z)
    end
    
    return pos, disabled
end

--Sync

gOffsets = {
    --[[ 
        [ModelID] = {
            ["componentName"] = {ox, oy, oy, orx, ory, orz},
        },
    ]]--
    
    [502] = {
        ["maxDistance"] = 1.8, -- Hány yardról jelenik meg a drawnolás, hosszabb kocsiknál ez nyilván nagyobb, hogy tisztán kijöjjön motorháztető, etc...
        ["bonnet_open-ratio"] = {54, 0}, --Milyen értéknél van full kinyitva és milyen értéknél van full bezárva a motorháztető. Szerón való lekérdezése: Beszállsz a kocsiba és /crun localPlayer.vehicle:getComponentRotation("bonnet_dummy")
        ["boot_open-ratio"] = {54, 0}, --Milyen értéknél van full kinyitva és milyen értéknél van full bezárva a csomagtartó. Szerón való lekérdezése: Beszállsz a kocsiba és /crun localPlayer.vehicle:getComponentRotation("boot_dummy")
        
        ["door_lf_dummy"] = {0.5,0.4,-0.6,0,90,90},
        ["door_rf_dummy"] = {-0.5,0.4,-0.55,0,270,270},
        
        ["wheel_lf_dummy"] = {1.5,0.85,-0.55,0,90,90},
        ["wheel_lb_dummy"] = {-1.5,0.85,-0.55,0,90,90},
        ["wheel_rf_dummy"] = {-1.6,0.85,-0.55,0,270,270},
        ["wheel_rb_dummy"] = {1.5,0.85,-0.55,0,270,270},
        
        ["bonnet_dummy"] = {0,-1.7,0.1,0,0,0},
    },
    
    [516] = {
        ["maxDistance"] = 1.8,-- Hány yardról jelenik meg a drawnolás, hosszabb kocsiknál ez nyilván nagyobb, hogy tisztán kijöjjön motorháztető, etc...
        ["bonnet_open-ratio"] = {54, 0}, --Milyen értéknél van full kinyitva és milyen értéknél van full bezárva a motorháztető. Szerón való lekérdezése: Beszállsz a kocsiba és /crun localPlayer.vehicle:getComponentRotation("bonnet_dummy")
        ["boot_open-ratio"] = {306, 0}, --Milyen értéknél van full kinyitva és milyen értéknél van full bezárva a csomagtartó. Szerón való lekérdezése: Beszállsz a kocsiba és /crun localPlayer.vehicle:getComponentRotation("boot_dummy")
        
        ["door_lf_dummy"] = {0.5,0.4,-0.6,0,90,90},
        ["door_rf_dummy"] = {-0.5,0.4,-0.55,0,270,270},
        ["door_rr_dummy"] = {-0.5,0.4,-0.55,0,270,270},
        ["door_lr_dummy"] = {-0.5,0.4,-0.55,0,270,270},
        
        ["wheel_lf_dummy"] = {1.5,0.85,-0.55,0,90,90},
        ["wheel_lb_dummy"] = {-1.5,0.85,-0.55,0,90,90},
        ["wheel_rf_dummy"] = {-1.6,0.85,-0.55,0,270,270},
        ["wheel_rb_dummy"] = {1.5,0.85,-0.55,0,270,270},
        
        ["bonnet_dummy"] = {0,-1.7,0.1,0,0,0},
        ["boot_dummy"] = {0,-1.7,0.1,0,0,0},
    },

    [400] = {
        ["maxDistance"] = 1.8,-- Hány yardról jelenik meg a drawnolás, hosszabb kocsiknál ez nyilván nagyobb, hogy tisztán kijöjjön motorháztető, etc...
        ["bonnet_open-ratio"] = {54, 0}, --Milyen értéknél van full kinyitva és milyen értéknél van full bezárva a motorháztető. Szerón való lekérdezése: Beszállsz a kocsiba és /crun localPlayer.vehicle:getComponentRotation("bonnet_dummy")
        ["boot_open-ratio"] = {288, 0}, --Milyen értéknél van full kinyitva és milyen értéknél van full bezárva a csomagtartó. Szerón való lekérdezése: Beszállsz a kocsiba és /crun localPlayer.vehicle:getComponentRotation("boot_dummy")
        
        ["door_lf_dummy"] = {-0.3,0.7,1.3,0,270,270},
        ["door_rf_dummy"] = {0.5,0.4,-0.55,0,270,270},
        ["door_rr_dummy"] = {0.7,0.6,-0.3,0,270,270},
        ["door_lr_dummy"] = {0.7,0.7,1.3,0,270,270},
        
        ["wheel_lf_dummy"] = {1.5,0.85,-0.55,0,90,90},
        ["wheel_lb_dummy"] = {-1.5,0.85,-0.55,0,90,90},
        ["wheel_rf_dummy"] = {-1.6,0.85,-0.55,0,270,270},
        ["wheel_rb_dummy"] = {1.5,0.85,-0.55,0,270,270},
		
		["bump_front_dummy"] = {0,2.8,0.1,0,0,0},
		["bump_rear_dummy"] = {0,2.9,0.7,0,0,0},
        
        ["bonnet_dummy"] = {0,-1.7,0.1,0,0,0},
        ["boot_dummy"] = {0,2.8,0.1,0,0,0},
    },
}