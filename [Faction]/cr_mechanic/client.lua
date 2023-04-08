local screenX, screenY = guiGetScreenSize()

local cache = {}
components = {
    --["comp name"] = {isVisible, hunText, {offsets}}
    ["bump_front_dummy"] = {true, "Első lökhárító", {0,0,0, "y"}},
    ["bump_rear_dummy"] = {true, "Hátsó lökhárító", {0,0,0, "y2"}},
    ["door_lf_dummy"] = {true, "Bal első ajtó", {0,-0.75,0, "rot"}},
    ["door_rf_dummy"] = {true, "Jobb első ajtó", {0,-0.75,0, "rot"}},
    ["door_rr_dummy"] = {true, "Jobb hátsó ajtó", {0,-0.5,0, "rot"}},
    ["door_lr_dummy"] = {true, "Bal hátsó ajtó", {0,-0.5,0, "rot"}},
    ["bonnet_dummy"] = {true, "Motorháztető", {0,0.75,0, "rot"}},
    ["boot_dummy"] = {true, "Csomagtartó", {0,-0.5,0, "rot"}},
    ["wheel_lf_dummy"] = {true, "Bal első kerék", {0,0,0}},
    ["wheel_rf_dummy"] = {true, "Jobb első kerék", {0,0,0}},
    ["wheel_lb_dummy"] = {true, "Bal hátsó kerék", {0,0,0}},
    ["wheel_rb_dummy"] = {true, "Jobb első kerék", {0,0,0}},
    
    --Noncomponent
    ["bonnet_dummy2"] = {true, "Motor", {0,0.75,-0.1, "bonnet_dummy"}},
    ["bonnet_dummy3"] = {true, "Olajcsap", {0,0.75,"-z", "bonnet_dummy"}},
    ["bonnet_dummy4"] = {true, "Szélvédő", {0,-0.2,0.2}},
    
    --NotVisible
    ["bump_front_dummy2"] = {false, "Izzók megjavítása", {0,0,0}},
    ["bump_front_dummy3"] = {false, "Sárhányók megjavítása", {0,0,0}},
    ["bonnet_dummy5"] = {false, "Olajszint megmérése", {0,0.75,"-z", "bonnet_dummy"}},
    ["bonnet_dummy6"] = {false, "Üzemanyag leszívása", {0,0.75,"-z", "bonnet_dummy"}},
    ["chassis"] = {true, "Teljes javítás", {0,0,0, "chassis"}},
}

isSpecVeh = {
    --[ModelID] = true
    [482] = true,
}

local state = false

addEventHandler("onClientResourceStart", resourceRoot,
    function()
        for k,v in pairs(getElementsByType("vehicle", _, true)) do
            cache[v] = true
        end
    end
)

addEventHandler("onClientElementStreamIn", root,
    function()
        if source and isElement(source) and source.type == "vehicle" then
            cache[source] = true
        end
    end
)

addEventHandler("onClientElementStreamOut", root,
    function()
        if source and isElement(source) and source.type == "vehicle" then
            cache[source] = nil
        end
    end
)

addEventHandler("onClientElementDestroy", root,
    function()
        if source and isElement(source) and source.type == "vehicle" then
            cache[source] = nil
        end
    end
)

addEventHandler("onClientVehicleDamage", root, 
    function()
        if source and isElement(source) and source:getData("cloned") then
            --outputChatBox("asd")
            cancelEvent()
        end
    end
)

function getNearestVehicle()
    if not inAnyColShape() then return end

    if not exports.cr_dashboard:isPlayerInFaction(localPlayer, 3) then 
        return
    end

    if tonumber(localPlayer:getData('char >> duty') or 0) ~= 3 then 
        return
    end 

    local shortest = 9999
    local vehE
    for k,v in pairs(cache) do
        if isElement(k) then
            if getDistanceBetweenPoints3D(k.position, localPlayer.position) <= shortest then
                if getDistanceBetweenPoints3D(k.position, localPlayer.position) <= 8 then
                    if not k:getData("cloned") and k.alpha >= 0 then
                        shortest = getDistanceBetweenPoints3D(k.position, localPlayer.position)
                        vehE = k
                    end
                end
            end
        else
            cache[k] = nil
        end
    end
    
    return vehE
end

setTimer(
    function()
        veh = getNearestVehicle()
        --outputChatBox(inspect(veh))
        if veh then
            if not state then
                addEventHandler("onClientRender", root, drawnPanels, true, "low-5")
                state = true
            end
        else
            if state then
                removeEventHandler("onClientRender", root, drawnPanels)
                state = false
            end
        end
    end, 50, 0
)

local boxActive = false

local rowH = 25
local margin = 6
local panelH = 0

local compCount = 0

local isDirectComp = {
    ["bonnet_dummy2"] = true,
    ['chassis'] = true,
    ["bonnet_dummy3"] = true,
    ["bonnet_dummy4"] = true,
    ["bump_front_dummy2"] = true,
    ["bump_front_dummy3"] = true,
    ["bonnet_dummy5"] = true,
    ['bonnet_dummy6'] = true,
}

function drawnPanels()
    if localPlayer.vehicle then return end
    font = exports['cr_fonts']:getFont("Poppins-Medium", 13)
    local v = veh
    if not isElement(v) then return end
    local rot = v.rotation
    local forY = sy / 2 - panelH / 2
    hover = {}

    if boxActive then 
        local w, h = 250 + margin, panelH
        local x, y = sx - w - 15 + (margin / 2), sy / 2 - ((((compCount) * rowH + margin) + (rowH)) / 2)
        forY = y

        dxDrawRectangle(x, y, w, h, tocolor(51, 51, 51, 255 * 0.8))
    else
        compCount = 0
    end

    local gPanelH = 0
    local gCompCount = 0

    for k2,v2 in pairs(components) do
        local isVisible, hunText, a = unpack(v2)
        _k = k2
        k2 = k2:gsub("2", "")
        k2 = k2:gsub("3", "")
        k2 = k2:gsub("4", "")
        k2 = k2:gsub("5", "")
        k2 = k2:gsub("6", "")
        --EGYES KOCSIKNÁL PLD: BURRITO MÉG A HÁTSÓAJTÓ NEM JÓ
        if isVisible then
            --outputChatBox(tostring(v))
            local x,y,z = getVehicleComponentPosition(v, k2, "world")
            if x then
                --outputChatBox("asd")
                local disabled = isComponentDamaged(v, _k)
                --outputChatBox(_k .. " -> "..tostring(disabled))
                disabled = not disabled
                
                local pos, disabled = getComponentPosOffsets(v, a, rot, k2, _k, disabled)
                --outputChatBox(_k .. " -> "..tostring(disabled))
                local gMaxDist = gOffsets[v.model] and gOffsets[v.model]["maxDistance"] or 1.8
                
                if getDistanceBetweenPoints3D(pos, localPlayer.position) <= gMaxDist and not disabled then
                    local sx,sy = getScreenFromWorldPosition(pos)
                    local length = dxGetTextWidth(hunText, 1, font)
                    if sx and sy then
                        local size = {length+20, 25}
                        local multipler = 1
                        size[1] = size[1] * multipler
                        size[2] = size[2] * multipler
                        local x,y,w,h = sx - (size[1]/2), sy - (size[2]/2), size[1], size[2]
                        --hover = {}
                        if isInSlot(x,y,w,h) then
                            hover = {true, v, _k}
                            local r, g, b = exports['cr_core']:getServerColor(nil, false)

                            dxDrawRectangle(x - 1, y - 1, w + 2, h + 2, tocolor(51, 51, 51, 255))
                            dxDrawRectangle(x, y, w, h, tocolor(242, 242, 242, 255))
                            dxDrawText(hunText, x, y + 4, x + w, y + h, tocolor(51, 51, 51, 255), 1, font, "center", "center")
                        else
                            dxDrawRectangle(x, y, w, h, tocolor(51, 51, 51, 255))
                            dxDrawText(hunText, x, y + 4, x + w, y + h, tocolor(255, 255, 255, 255), 1, font, "center", "center")
                        end
                    end
                end
            end
        else
            --outputChatBox(tostring(v))
            local x,y,z = getVehicleComponentPosition(v, k2, "world")
            if x then
                --outputChatBox("asd")
                local disabled = isComponentDamaged(v, _k)
                disabled = not disabled
                
                local pos, disabled = getComponentPosOffsets(v, a, rot, k2, _k, disabled)
                
                -- dxDrawLine3D(pos, localPlayer.position)
                
                --local sx,sy = getScreenFromWorldPosition(pos)
                local gMaxDist = gOffsets[v.model] and gOffsets[v.model]["maxDistance"] or 2.5
                if getDistanceBetweenPoints3D(pos, localPlayer.position) <= gMaxDist and not disabled then
                    gCompCount = gCompCount + 1
                    compCount = gCompCount

                    boxActive = compCount > 0

                    gPanelH = gPanelH + rowH + margin
                    -- gPanelH = gPanelH - 1

                    panelH = gPanelH

                    -- local length = dxGetTextWidth(hunText, 1, font)
                    local size = {250, 25}
                    local multipler = 1

                    size[1] = size[1] * multipler
                    size[2] = size[2] * multipler

                    local w, h = size[1], size[2]
                    local x, y = sx - w - 15, forY + (margin / 2)

                    forY = forY + h + (margin / 2)

                    --hover = {}

                    if isInSlot(x,y,w,h) then
                        hover = {true, v, _k}
                        local r, g, b = exports['cr_core']:getServerColor(nil, false)

                        -- dxDrawRectangle(x - 1, y - 1, w + 2, h + 2, tocolor(51, 51, 51, 255))
                        dxDrawRectangle(x, y, w, h, tocolor(242, 242, 242, 255))
                        dxDrawText(hunText, x, y + 4, x + w, y + h, tocolor(51, 51, 51, 255), 1, font, "center", "center")
                    else
                        dxDrawRectangle(x, y, w, h, tocolor(51, 51, 51, 255 * 0.8))

                        dxDrawText(hunText, x, y + 4, x + w, y + h, tocolor(255, 255, 255, 255), 1, font, "center", "center")
                    end
                else
                    boxActive = gCompCount > 0
                end
            end
        end
    end
end

local texts = {
    ["bump_front_dummy"] = "Az első lökhárító @r folyamatban...",
    ["bump_rear_dummy"] = "A hátsó lökhárító @r folyamatban...",
    ["door_lf_dummy"] = "A bal első ajtó @r folyamatban...",
    ["door_rf_dummy"] = "A jobb első ajtó @r folyamatban...",
    ["door_rr_dummy"] = "A jobb hátsó ajtó @r folyamatban...",
    ["door_lr_dummy"] = "A bal hátsó ajtó @r folyamatban...",
    ["bonnet_dummy"] = "A motorháztető @r folyamatban...",
    ["boot_dummy"] = "A csomagtartó @r folyamatban...",
    ["wheel_lf_dummy"] = "A bal első kerék @r folyamatban...",
    ["wheel_rf_dummy"] = "A jobb első kerék @r folyamatban...",
    ["wheel_lb_dummy"] = "A bal hátsó kerék @r folyamatban...",
    ["wheel_rb_dummy"] = "A jobb hátsó kerék @r folyamatban...",
    ["bonnet_dummy2"] = "A motor megjavítása folyamatban...",
    ['chassis'] = 'A teljes javítás folyamatban...',
    ["bonnet_dummy3"] = "Az olajcsere folyamatban...",
    ["bonnet_dummy4"] = "A szélvédő megjavítása folyamatban...",
    ["bump_front_dummy2"] = "Az izzók megjavítása folyamatban...",
    ["bump_front_dummy3"] = "A sárhányok megjavítása folyamatban...",
    ["bonnet_dummy5"] = "Az olajszint megmérése folyamatban...",
    ['bonnet_dummy6'] = 'A rossz üzemanyag leengedése folyamatban...',
}

local rpTexts = {
    ["bump_front_dummy"] = "elkezdte @r a(z) első lökhárítót",
    ["bump_rear_dummy"] = "elkezdte @r a(z) hátsó lökhárítót",
    ["door_lf_dummy"] = "elkezdte @r a(z) bal első ajtót",
    ["door_rf_dummy"] = "elkezdte @r a(z) jobb első ajtót",
    ["door_rr_dummy"] = "elkezdte @r a(z) jobb hátsó ajtót",
    ["door_lr_dummy"] = "elkezdte @r a(z) bal hátsó ajtót",
    ["bonnet_dummy"] = "elkezdte @r a(z) motorháztetőt",
    ["boot_dummy"] = "elkezdte @r a(z) csomagtartót",
    ["wheel_lf_dummy"] = "elkezdte @r a(z) bal első kereket",
    ["wheel_rf_dummy"] = "elkezdte @r a(z) jobb első kereket",
    ["wheel_lb_dummy"] = "elkezdte @r a(z) bal hátsó kereket",
    ["wheel_rb_dummy"] = "elkezdte @r a(z) jobb hátsó kereket",
    ["bonnet_dummy2"] = "elkezdte megjavítani a motort",
    ['chassis'] = 'elkezdte megjavítani a motort',
    ["bonnet_dummy3"] = "elkezdte kicserélni az olajat",
    ["bonnet_dummy4"] = "elkezdte megjavítani a szélvédőt",
    ["bump_front_dummy2"] = "elkezdte megjavítani az izzókat",
    ["bump_front_dummy3"] = "elkezdte megjavítani a sárhányókat",
    ["bonnet_dummy5"] = "elkezdte megmérni az olajszintet",
    ['bonnet_dummy6'] = 'elkezdte leszívni az üzemanyagot',
}

addEventHandler("onClientElementDataChange", root,
    function(dName, oValue)
        local value = source:getData(dName)
        
        --outputChatBox(tostring(utf8.sub(dName, #dName - 6, #dName)))
        if string.lower(utf8.sub(dName, #dName - 6, #dName)) == string.lower("->doing") then
            if oValue and isElement(oValue) and value and isElement(value) then
                if value == localPlayer then
                    if doingState then
                        setElementData(source, dName, oValue)
                        setElementData(localPlayer, "forceAnimation", {"", ""})
                        if isElement(repairSound) then
                            destroyElement(repairSound)
                        end
                        repairSound = nil
                        getVehComponentBackToVeh(source, doingState)
                        gVeh = nil
                        doingState = nil
                        exports.cr_dx:endProgressBar("mechanic >> doingRender")
                        -- removeEventHandler("onClientRender", root, doingRender, true, "low-5")
                    end
                end
            end
        end
    end
)

addEventHandler("onClientClick", root,
    function(b, s)
        if b == "left" and s == "down" then
            --outputChatBox("asd1")
            if state then
                --outputChatBox("asd2")
                if hover[1] then
                    --outputChatBox("asd3")
                    local _, element, componentName = unpack(hover)
                    if isElement(element) then
                        --outputChatBox("asd4")
                        if not doingState then
                            --outputChatBox("asd5")
                            --if componentName == 
                            if not element:getData(componentName.."->doing") then
                                if not exports.cr_dx:isProgressBarActive("mechanic >> doingRender") then 
                                    if not localPlayer:getData("mechanic.canRepair") then 
                                        local syntax = exports.cr_core:getServerSyntax("Mechanic", "error")
                                        local hexColor = exports.cr_core:getServerColor("yellow", true)

                                        outputChatBox(syntax .. "Addig nem tudod elkezdeni a szerelést, ameddig nem küldted el a szerelési kérelmet az adott játékosnak.", 255, 0, 0, true)
                                        outputChatBox(syntax .. "A szerelési kérelem elküldéséhez használd a " .. hexColor .. "/requestpay " .. white .. "parancsot.", 255, 0, 0, true)
                                        return
                                    end

                                    gText = texts[componentName]
                                    local rpText = rpTexts[componentName]
                                    if componentName == "bonnet_dummy3" then
                                        element:setData("oilChange", true)
                                    end
                                    
                                    --outputChatBox(componentName)
                                    if not isDirectComp[componentName] and isComponentMissing(element, componentName) then
                                        doingState = componentName
                                        gVeh = element
                                        --outputChatBox(inspect(gVeh))
                                        gVeh:setData(componentName.."->doing", localPlayer)
                                        getVehComponentToHand(element, componentName, true)
                                        local syntax = exports['cr_core']:getServerSyntax("Mechanic", "info")
                                        --triggerServerEvent("toggleAlpha", localPlayer, localPlayer, element, 0)
                                        outputChatBox(syntax .. "Menj a sárga cphez, hogy megkaphasd ezt az alkatrészt!",255,255,255,true)
                                        return
                                    end
                                    
                                    if not isDirectComp[componentName] then
                                        gText = utf8.gsub(gText, "@r", "leszerelése")
                                        rpText = utf8.gsub(rpText, "@r", "leszerelni")
                                    end
                                    doingState = componentName
                                    gVeh = element
                                    --outputChatBox(inspect(gVeh))
                                    gVeh:setData(componentName.."->doing", localPlayer)
                                    -- addEventHandler("onClientRender", root, doingRender, true, "low-5")

                                    local randomTime = math.random(5000, 10000)
                                    exports.cr_dx:startProgressBar("mechanic >> doingRender", {
                                        {gText, randomTime}
                                    })

                                    triggerServerEvent("applyAnimation", localPlayer, localPlayer, "BOMBER", "BOM_Plant")
                                    setElementData(localPlayer, "forceAnimation", {"BOMBER", "BOM_Plant"})
                                    --setPedAnimation(localPlayer, "BOMBER", "BOM_Plant")
                                    repairSound = playSound("files/repair.mp3", true)
                                    exports['cr_chat']:createMessage(localPlayer, rpText, 1)
                                    xS = 0
                                    animate(0, 1, "Linear", randomTime, 
                                        function(v)
                                            --outputChatBox(xS)
                                            xS = v
                                        end,

                                        function()
                                            -- removeEventHandler("onClientRender", root, doingRender, true, "low-5")
                                            setElementData(localPlayer, "forceAnimation", {"", ""})
                                            destroyElement(repairSound)
                                            repairSound = nil
                                            
                                            if componentName == "bonnet_dummy3" then
                                                element:setData("oilChange", false)
                                            end
                                            if isDirectComp[componentName] then
                                                gVeh:setData(componentName.."->doing", false)
                                                fixVehComponent(element, componentName)
                                                --element:setData("oilChange", false)
                                                doingState = false
                                            else
                                                getVehComponentToHand(element, componentName)
                                            end
                                        end, "animating"
                                    )
                                end
                            else
                                local syntax = exports['cr_core']:getServerSyntax("Mechanic", "error")
                                outputChatBox(syntax .. "Ezt az alkatrészt nem szedheted le hisz egy kollégád már ezt megtette!", 255,255,255,true)
                            end
                        elseif doingState and doingState == componentName then
                            if element == gVeh then
                                local v, k = gVeh:getData(doingState.."->parent"), doingState --gVeh:getData("hide")
                                if not isComponentDamaged(v, k) then
                                    if not exports.cr_dx:isProgressBarActive("mechanic >> doingRender") then 
                                        gText = texts[componentName]
                                        local rpText = rpTexts[componentName]
                                        
                                        if not isDirectComp[componentName] then
                                            gText = utf8.gsub(gText, "@r", "felszerelése")
                                            rpText = utf8.gsub(rpText, "@r", "felszerelni")
                                        end
                                        doingState = componentName
                                        gVeh = element
                                        --outputChatBox(inspect(gVeh))
                                        --gVeh:setData(componentName.."->doing", localPlayer)
                                        -- addEventHandler("onClientRender", root, doingRender, true, "low-5")

                                        local randomTime = math.random(5000, 10000)
                                        exports.cr_dx:startProgressBar("mechanic >> doingRender", {
                                            {gText, randomTime}
                                        })

                                        --setElementData(localPlayer, "forceAnimation", {"", ""})
                                        --if isTimer(animTimer) then killTimer(animTimer) end
                                        triggerServerEvent("applyAnimation", localPlayer, localPlayer, "BOMBER", "BOM_Plant")
                                        setElementData(localPlayer, "forceAnimation", {"BOMBER", "BOM_Plant"})
                                        --setPedAnimation(localPlayer, "BOMBER", "BOM_Plant")
                                        --triggerServerEvent("destroyClonedVehicle", localPlayer, localPlayer, gVeh)
                                        repairSound = playSound("files/repair.mp3", true)
                                        exports['cr_chat']:createMessage(localPlayer, rpText, 1)
                                        xS = 0
                                        animate(0, 1, "Linear", randomTime, 
                                            function(v)
                                                --outputChatBox(xS)
                                                xS = v
                                            end,

                                            function()
                                                -- removeEventHandler("onClientRender", root, doingRender, true, "low-5")
                                                setElementData(localPlayer, "forceAnimation", {"", ""})
                                                destroyElement(repairSound)
                                                repairSound = nil
                                                getVehComponentBackToVeh(element, componentName)
                                                gVeh = nil
                                                doingState = nil
                                            end, "animating"
                                        )
                                        --Visszaszerelés
                                        --getVehComponentBackToVeh(element, componentName)
                                    end
                                else
                                    local syntax = exports['cr_core']:getServerSyntax("Mechanic", "error")
                                    outputChatBox(syntax .. "Az alkatrész amit visszaszeretnél szerelni törött!",255,255,255,true)
                                end
                            else
                                local syntax = exports['cr_core']:getServerSyntax("Mechanic", "error")
                                outputChatBox(syntax .. "Csak arra a kocsira szerelheted fel az alkatrészt melyről leszedted!", 255,255,255,true)
                            end
                        end
                    end
                end
            end
        end
    end
)

addEventHandler("onClientResourceStop", resourceRoot,
    function()
        if doingState then
            local componentName = doingState
            --outputChatBox("asd1")
            gVeh:setData(componentName.."->doing", false)
            doingState = false
            if not isDirectComp[componentName] then
                --outputChatBox("asd2")
                getVehComponentBackToVeh(element, componentName)
            end
        end
    end
)

function fixVehComponent(element, k)
    if k == "bonnet_dummy5" then
        local odometer, lastOilRecoil = tonumber(getElementData(element, "veh >> odometer") or 0), tonumber(getElementData(element, "veh >> lastOilRecoil") or 0)
        local syntax = exports['cr_core']:getServerSyntax("Mechanic", "info")
        local green = exports['cr_core']:getServerColor(nil, true)
        white = "#ffffff"
        outputChatBox(syntax .. "A jármű jelenlegi olaj információ: ",255,255,255,true)
        outputChatBox(syntax .. "Utolsó feltöltés: "..green..lastOilRecoil .. "#ffffff km-nél.",255,255,255,true)
        outputChatBox(syntax .. "Jelenlegi km óra állás: "..green..odometer,255,255,255,true)
        outputChatBox(syntax .. "Lerobbanás: "..green.. (odometer-lastOilRecoil) .. white .. " km múlva",255,255,255,true)
        return
    end
    
    local convertData = getConvertData(element, k)
    --convertData[1] = 
    
    --Innen folytatom: jobb oldalra még rakd be, hogy olajszint megvizsgálása
    triggerServerEvent("fixVehicleComponent", localPlayer, element, convertData)
end

function getAttachOffsets(element, component)
    local offsets = {0,0,0,0,0,0}
    if gOffsets[element.model] and gOffsets[element.model][component] then
        offsets = gOffsets[element.model][component]
    end
    
    return offsets
end

function getVehComponentToHand(element, component, ignore)
    if not ignore then
        setElementData(localPlayer, "forceAnimation", {"SP", "SP"})
        triggerServerEvent("applyAnimation", localPlayer, localPlayer, "CARRY", "crry_prtial", 0, true, false, false)
        offControls()
    end
    --gVeh:setData("hide", "")
    gVeh:setData(component.."->hide", 0)
    local offsets = getAttachOffsets(element, component)
    triggerServerEvent("cloneVehicle", localPlayer, localPlayer, gVeh, offsets, component, ignore)
    
    animTimer = setTimer(checkAnim, 400, 0)
end

function checkAnim()
    local forceAnim = localPlayer:getData("forceAnimation") or {"", ""}
    if forceAnim[1] == "SP" then
        local Block, Anim = getPedAnimation(localPlayer)
        if Block ~= "CARRY" or Anim ~= "crry_prtial" then
            triggerServerEvent("applyAnimation", localPlayer, localPlayer, "CARRY", "crry_prtial", 0, true, false, false)
            offControls()
        end
    end
end

function offControls()
    if not oldState then
        oldState = {isControlEnabled("crouch"), isControlEnabled("jump"), isControlEnabled("sprint"), isControlEnabled("enter_exit"), isControlEnabled("fire"), isControlEnabled("enter_passenger")}
    end
    toggleControl("crouch", false)
	toggleControl("jump", false)
	toggleControl("sprint", false)
	toggleControl("enter_exit", false)
	toggleControl("fire", false)
	toggleControl("enter_passenger", false)
end

function onControls()
    if oldState then
        toggleControl("crouch", oldState[1])
        toggleControl("jump", oldState[2])
        toggleControl("sprint", oldState[3])
        toggleControl("enter_exit", oldState[4])
        toggleControl("fire", oldState[5])
        toggleControl("enter_passenger", oldState[6])
        oldState = nil

        -- exports['cr_death-system']:resetBone()
    end
end

addEventHandler("onClientElementStreamIn", root,
    function()
        if source and source.type == "vehicle" then
            local value = source:getData("hide")
            if value then
                if type(value) == "table" then
                    local components = getVehicleComponents(source)
                    for k2 in pairs(components) do
                        if not value[k2] then
                            if not isComponentMissing(source, k2) then
                                setTimer(setVehicleComponentVisible, 50, 1, source, k2, false)
                            end
                        end
                    end
                    
                    for k,v in pairs(value) do
                        if not isComponentMissing(source, k) then
                            setTimer(setVehicleComponentVisible, 50, 1, source, k, true)
                        end
                    end
                else
                    if not isComponentMissing(source, source:getData("hide")) then
                        setVehicleComponentVisible(source, source:getData("hide"), false)
                    end
                end
            end
        end
    end
)

addEventHandler("onClientElementDataChange", root,
    function(dName, oValue)
        --outputChatBox(dName)
        if dName == "hide" then
            if source.type == "vehicle" then
                local value = source:getData(dName)
                --outputChatBox(inspect(value))
                if value then
                    if type(value) == "table" then
                        local components = getVehicleComponents(source)
                        for k2 in pairs(components) do
                            if not value[k2] then
                                --outputChatBox(k2.."->"..tostring(isComponentMissing(source, k2)))
                                if not isComponentMissing(source, k2) then
                                    setTimer(setVehicleComponentVisible, 50, 1, source, k2, false)
                                end
                            end
                        end
                        
                        for k,v in pairs(value) do
                            --outputChatBox(k.."->"..tostring(isComponentMissing(source, k)))
                            if not isComponentMissing(source, k) then
                                setTimer(setVehicleComponentVisible, 50, 1, source, k, true)
                            end
                        end
                    --[[
                    else
                        if not isComponentMissing(source, source:getData("hide")) then
                            setVehicleComponentVisible(source, source:getData("hide"), false)
                        end]]    
                    end
                else
                    if oValue then
                        if type(oValue) == "table" then
                            local components = source.components
                            for k2 in pairs(components) do
                                if not isComponentMissing(source, k2) then
                                    setTimer(setVehicleComponentVisible, 50, 1, source, k2, true)
                                end
                            end
                        --[[
                        else
                            if not isComponentMissing(source, oValue) then
                                setVehicleComponentVisible(source, oValue, true)
                            end]]
                        end
                    end
                end
            end
        elseif string.lower(utf8.sub(dName, #dName - 5, #dName)) == string.lower("->hide") then
            if source.type == "vehicle" then
                local value = source:getData(dName)
                local compName = string.lower(utf8.sub(dName, 1, #dName - 6)) 
                if value and tonumber(value) then
                    if not isComponentMissing(source, compName) then
                        if value == 1 then
                            --outputChatBox("asd2")
                            setVehicleComponentVisible(source, compName, true)
                        else
                            setVehicleComponentVisible(source, compName, false)
                        end
                    end
                end
            end
        end
    end
)

function getVehComponentBackToVeh(element, component, ignore)
    --outputChatBox("asd3")
    if isTimer(animTimer) then killTimer(animTimer) end
    setElementData(localPlayer, "forceAnimation", {"", ""})
    triggerServerEvent("removeAnimation", localPlayer, localPlayer)
    --outputChatBox(inspect(gVeh))
    gVeh:setData(component.."->doing", false)
    gVeh:setData(component.."->hide", 1)
    --outputChatBox(component)
    --outputChatBox(inspect(gVeh))
    triggerServerEvent("destroyClonedVehicle", localPlayer, localPlayer, gVeh, component)
    gVeh:setData(component.."->parent", nil)
    doingState = false
    
    local convertData = getConvertData(element, component)
    --convertData[1] = 

    --Innen folytatom: jobb oldalra még rakd be, hogy olajszint megvizsgálása
    triggerServerEvent("fixVehicleComponent", localPlayer, element, convertData)
    onControls()
end

function resetDoingState()
    doingState = false
    if isTimer(animTimer) then killTimer(animTimer) end
    setElementData(localPlayer, "forceAnimation", {"", ""})
    triggerServerEvent("applyAnimation", localPlayer, localPlayer, "", "")
    triggerServerEvent("removeAnimation", localPlayer, localPlayer)
    onControls()
end
addEvent("resetDoingState", true)
addEventHandler("resetDoingState", root, resetDoingState)

local oilEffects = {}

addEventHandler("onClientElementDataChange", root,
    function(dName, oValue)
        if dName == "oilChange" then
            local value = source:getData(dName)
            if value then
                if oilEffects[source] and isElement(oilEffects[source]) then
                    destroyElement(oilEffects[source])
                end
                local oilEffect = createEffect("puke", getElementPosition(source))
                setEffectSpeed(oilEffect, 0.25)
                oilEffects[source] = oilEffect
            else
                if oilEffects[source] and isElement(oilEffects[source]) then
                    destroyElement(oilEffects[source])
                end
            end
        end
    end
)

-- function doingRender()
--     local font = exports['cr_fonts']:getFont("RobotoB", 8)

--     local w,h = 400, 15
--     local x, y = sx/2-w/2, sy - h - 20
    
--     --outputChatBox(xS)

--     dxDrawRectangle(x,y,w,h, tocolor(44,44,44,255))
--     local r,g,b = exports['cr_core']:getServerColor(nil, false)
--     dxDrawRectangle(x,y,w * xS,h, tocolor(57, 123, 199, 255))
--     dxDrawText("#9c9c9c"..gText, x,y,x+w,y+h, tocolor(255, 255, 255, 255), 1, font, "center", "center", false, false, false, true)
-- end

sx, sy = guiGetScreenSize()
screenSize = {guiGetScreenSize()}
getCursorPos = getCursorPosition
function getCursorPosition()

    --outputChatBox(tostring(isCursorShowing()))
    if isCursorShowing() then
        --outputChatBox("asd")
        local x,y = getCursorPos()
        --outputChatBox("x"..tostring(x))
        --outputChatBox("y"..tostring(y))
        x, y = x * screenSize[1], y * screenSize[2] 
        return x,y
    else
        return -5000, -5000
    end
end

cursorState = isCursorShowing()
cursorX, cursorY = getCursorPosition()

function isInBox(dX, dY, dSZ, dM, eX, eY)
    if eX >= dX and eX <= dX+dSZ and eY >= dY and eY <= dY+dM then
        return true
    else
        return false
    end
end

function isInSlot(xS,yS,wS,hS)
    if isCursorShowing() then
        local cursorX, cursorY = getCursorPosition()
        if isInBox(xS,yS,wS,hS, cursorX, cursorY) then
            return true
        else
            return false
        end
    end 
end

--
local anims, builtins = {}, {"Linear", "InQuad", "OutQuad", "InOutQuad", "OutInQuad", "InElastic", "OutElastic", "InOutElastic", "OutInElastic", "InBack", "OutBack", "InOutBack", "OutInBack", "InBounce", "OutBounce", "InOutBounce", "OutInBounce", "SineCurve", "CosineCurve"}

function table.find(t, v)
	for k, a in ipairs(t) do
		if a == v then
			return k
		end
	end
	return false
end

function animate(f, t, easing, duration, onChange, onEnd, boolean)
	assert(type(f) == "number", "Bad argument @ 'animate' [expected number at argument 1, got "..type(f).."]")
	assert(type(t) == "number", "Bad argument @ 'animate' [expected number at argument 2, got "..type(t).."]")
	assert(type(easing) == "string" or (type(easing) == "number" and (easing >= 1 or easing <= #builtins)), "Bad argument @ 'animate' [Invalid easing at argument 3]")
	assert(type(duration) == "number", "Bad argument @ 'animate' [expected function at argument 4, got "..type(duration).."]")
	assert(type(onChange) == "function", "Bad argument @ 'animate' [expected function at argument 5, got "..type(onChange).."]")
    if boolean then
        anims[boolean] = {from = f, to = t, easing = table.find(builtins, easing) and easing or builtins[easing], duration = duration, start = getTickCount( ), onChange = onChange, onEnd = onEnd}
    else
	   table.insert(anims, {from = f, to = t, easing = table.find(builtins, easing) and easing or builtins[easing], duration = duration, start = getTickCount( ), onChange = onChange, onEnd = onEnd})
    end
	return #anims
end

function destroyAnimation(a)
	if anims[a] then
		table.remove(anims, a)
	end
    started = false
end

addEventHandler("onClientRender", root, function( )
	local now = getTickCount( )
	for k,v in pairs(anims) do
		v.onChange(interpolateBetween(v.from, 0, 0, v.to, 0, 0, (now - v.start) / v.duration, v.easing))
		if now >= v.start+v.duration then
			if type(v.onEnd) == "function" then
				v.onEnd( )
			end
            if type(k) == "number" then
			    table.remove(anims, k)
            else
                anims[k] = nil
            end
		end
	end
end)

-- addCommandHandler("asd",
--     function()
--         local veh = localPlayer.vehicle

--         for k, v in pairs(components) do 
--             local damaged = isComponentDamaged(veh, k)

--             if k ~= "bonnet_dummy5" then 
--                 iprint(damaged, k, getTickCount())
--             end
--         end
--     end
-- )