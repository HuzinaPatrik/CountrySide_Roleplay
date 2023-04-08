addEventHandler("onClientElementDataChange", root,
    function(dName, oValue)
        if dName == "hifi >> movedBy" then
            local val = source:getData(dName)
            if val then
                if oValue then
                    if val ~= oValue then
                        if localPlayer == val then
                            --source:setData("hifi >> movedBy", oValue)
                            exports['cr_elementeditor']:resetEditorElementChanges(true)
                        end
                    end
                end
            end
        end
    end
)

addEvent("onSaveHifiPositionEditor",true)
addEventHandler("onSaveHifiPositionEditor",root,
    function(element, x, y, z, rx, ry, rz, scale, array)
--        triggerServerEvent("onHifiSetPosition",element,element, x, y, z, rx, ry, rz)
        --outputChatBox("awsd")
        --tputChatBox(exports['cr_core']:getServerSyntax("Hifi", "success") .. "sikeresen megváltoztattad egy hifi pozicióját!")
        triggerServerEvent("updateHifiPosition", localPlayer, element, x,y,z)
        triggerServerEvent("updateHifiRotation", localPlayer, element, {rx,ry,rz})
        triggerServerEvent("hifiChangeState", localPlayer, element, 255)
        element:setData("hifi >> movedBy", nil)
        --is_lines_rendered = true
    end
)

addEvent("onSaveHifiDeleteEditor", true)
addEventHandler("onSaveHifiDeleteEditor",root,
    function(element, x, y, z, rx, ry, rz, scale, array)
        triggerServerEvent("hifiChangeState", localPlayer, element, 255)
        element:setData("hifi >> movedBy", nil)
    end
)


local nearest = nil
local cache = {}
local soundCache = {}
local scaleTimers = {}

function getNearest()
    nearest = nil
    local dist = 9999
    for v, k in pairs(cache) do
        if not isElement(v) then 
            stopSync(v)
        else 
            if v.model == 2102 then
                if getDistanceBetweenPoints3D(localPlayer.position, v.position) <= 16 then
                    if getDistanceBetweenPoints3D(localPlayer.position, v.position) <= dist then
                        nearest = v
                        dist = getDistanceBetweenPoints3D(localPlayer.position, v.position)
                    end
                end
            end
        end 
    end
    
    if isElement(nearest) then
        local pos = nearest.matrix
        local lines = 
        {
            {nil,nil},
            {pos:transformPosition(0.3,0,0.3),pos:transformPosition(0.3,0,0.5)},
            {pos:transformPosition(0.2,0,0.3),pos:transformPosition(0.2,0,0.5)},
            {pos:transformPosition(0.1,0,0.3),pos:transformPosition(0.1,0,0.5)},
            {pos:transformPosition(0,0,0.3),pos:transformPosition(0,0,0.5)},
            {pos:transformPosition(-0.1,0,0.3),pos:transformPosition(-0.1,0,0.5)},
            {pos:transformPosition(-0.2,0,0.3),pos:transformPosition(-0.2,0,0.5)},
            {pos:transformPosition(-0.3,0,0.3),pos:transformPosition(-0.3,0,0.5)},
        } 
        local h_pos = pos:transformPosition(0,0,0.5)
         --setElementPosition( hifi_sync[element][2],getElementPosition(element))
        values = {nearest,soundCache[nearest],lines,h_pos}
        
        if not renderState then
            renderState = true
            --addEventHandler("onClientRender", root, drawnLines, true, "low-5")
            createRender("drawnLines", drawnLines)
        end
    else
        if renderState then
            renderState = false
            --removeEventHandler("onClientRender", root, drawnLines)
            destroyRender("drawnLines")
        end
    end
end
setTimer(getNearest, 200, 0)

function startSync(e)
    if localPlayer.vehicle then
        if localPlayer.vehicle:getData("veh >> windows >> closed") then -- az ő ablaka van felhúzva
            return
        end
    end

    stopSync(e)

    if exports['cr_dashboard']:getOption('streamerMode') == 0 then 
        cache[e] = e:getData("hifi >> channel") or 1
        local channels = exports['cr_radio']:getChannels()
        local url = channels[e:getData("hifi >> channel") or 1][2]
        --outputChatBox(url)
        local sound = playSound3D(url, e.position)
        sound.dimension = e.dimension 
        sound.interior = e.interior 
        --sound:attach(e)

        --setSoundMaxDistance(sound, 16)
        local e = e -- mta hotfix :D
        scaleTimers[e] = setTimer(
            function(e)
                e.scale = math.random(8, 14) / 10
            end, 100, 0, e
        )
        
        soundCache[e] = sound
    end
end

function stopSync(e)
    if isElement(soundCache[e]) then
        destroyElement(soundCache[e])
    end
    if isTimer(scaleTimers[e]) then 
        e.scale = 1
        killTimer(scaleTimers[e])
    end 
    scaleTimers[e] = nil 
    soundCache[e] = nil
    cache[e] = nil
    collectgarbage("collect")
end

function deSyncAllHifis()
    if exports['cr_dashboard']:getOption('streamerMode') == 1 then 
        for k,v in pairs(getElementsByType("object", _, true)) do
            if v.model == 2102 then
                --outputChatBox("asd")
                if v:getData("hifi >> state") then
                    stopSync(v)
                end
            end
        end
    end 
end 

function syncAllHifis()
    if exports['cr_dashboard']:getOption('streamerMode') == 0 then 
        for k,v in pairs(getElementsByType("object", _, true)) do
            if v.model == 2102 then
                --outputChatBox("asd")
                if v:getData("hifi >> state") then
                    startSync(v)
                end
            end
        end
    end 
end 

function onStart()
    for k,v in pairs(getElementsByType("object", _, true)) do
        if v.model == 2102 then
            --outputChatBox("asd")
            if v:getData("hifi >> state") then
                startSync(v)
            end
        end
    end
    
    local enabled = exports['cr_json']:jsonGET("@radio_settings.json", true)
    is_lined_enabled = enabled[1]
end
addEventHandler("onClientResourceStart", resourceRoot, onStart)

function onStop()
    exports['cr_json']:jsonSAVE("@radio_settings.json", {is_lined_enabled}, true)
    --is_lined_enabled = not enabled[1]
end
addEventHandler("onClientResourceStop", resourceRoot, onStop)

addEventHandler("onClientElementStreamIn", root,
    function()
        if source:getData("hifi >> state") then
            startSync(source)
        end
    end
)

addEventHandler("onClientElementStreamOut", root,
    function()
        if source:getData("hifi >> state") then
            stopSync(source)
        end
    end
)

addEventHandler("onClientElementDataChange", root,
    function(dName, oValue, nValue)
        if source and isElement(source) and source.type == "object" or source and isElement(source) and source.type == "vehicle" then
            if isElementStreamedIn(source) then
                if dName == "hifi >> state" then
                    local val = source:getData(dName)
                    if val then
                        startSync(source)
                    else
                        stopSync(source)
                    end
                elseif dName == "hifi >> channel" then
                    startSync(source)
                elseif dName == "veh >> windows >> closed" then
                    if nValue then
                        deSyncAll()
                    else
                        syncAll()
                    end
                end
            end
        end
    end
)

function syncAll()
    for k,v in pairs(getElementsByType("object", _, true)) do
        if v.model == 2102 then
            --outputChatBox("asd")
            if v:getData("hifi >> state") then
                startSync(v)
            end
        end
    end
end

function deSyncAll()
    for k,v in pairs(soundCache) do
        stopSync(k)
    end
end

addEventHandler("onClientVehicleEnter", root,
    function(thePlayer, seat)
        if thePlayer == localPlayer then
            if localPlayer.vehicle then
                if localPlayer.vehicle:getData("veh >> windows >> closed") then -- az ő ablaka van felhúzva
                    deSyncAll()
                end
            end
        end
    end
)

addEventHandler("onClientVehicleExit", root,
    function(thePlayer, seat)
        if thePlayer == localPlayer then
            if localPlayer.vehicle then
                if localPlayer.vehicle:getData("veh >> windows >> closed") then -- az ő ablaka van felhúzva
                    syncAll()
                end
            end
        end
    end
)

function drawnLines()
    if not is_lined_enabled then
        local sound_data = false
        --local values = sound_data

        if isElement(values[2]) then 
            if  not isSoundPaused (values[2]) then sound_data = getSoundFFTData(values[2],4096,12) end
            if sound_data  then
                if isElementOnScreen(values[1]) then
                    local r,g,b = exports['cr_core']:getServerColor("gray")
                    
                    for i = 1,11 do				
                        sound_data[i] = sound_data[i]*5
                        if sound_data[i] > 1 then sound_data[i] = 1
                        elseif sound_data[i] < 0.1 then sound_data[i] = 0.1 end
                        --sound_data[i] = --math.round(sound_data[i],10,"floor") 				 
                    end	
                    
                    for i = 2,8 do
                        dxDrawLine3D(values[3][i][1]:getX(),values[3][i][1]:getY(),values[3][i][1]:getZ(),values[3][i][2]:getX(),values[3][i][2]:getY(),values[3][i][2]:getZ()+(values[3][i][2]:getZ()-values[3][i][1]:getZ())*sound_data[12-i]*1.5,tocolor(r,g,b,150),3)
                    end
                end
            end
        end
    end
end



addCommandHandler("toghifilines",function()
	is_lined_enabled = not is_lined_enabled
end)

function math.round(number, decimals, method)
    decimals = decimals or 0
    local factor = 10 ^ decimals
    if (method == "ceil" or method == "floor") then return math[method](number * factor) / factor
    else return tonumber(("%."..decimals.."f"):format(number)) end
end

