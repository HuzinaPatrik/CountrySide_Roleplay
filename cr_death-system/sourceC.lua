localPlayer:setData("respawn", false)
localPlayer:setData("clone", nil)

local minutes = 5
local seconds = 0
local movingTimer, clockTimer
local state = false

local speedOnDeath = 0.75
local time = 15000

function startDeath()
    if isTimer(respawnTimer) then
        destroyElement(respawnTimer)
    end

    triggerEvent("stopTazedEffect", localPlayer, localPlayer)
    setElementData(localPlayer, "respawn", false)

    setElementData(localPlayer, "char >> death", true)
    setElementData(localPlayer, "inDeath", true)

    localPlayer:setData('drunkLevel', 0)

    minutes = 5
    seconds = 0

    exports['cr_controls']:toggleAllControls(false, "instant")
    setCameraInterior(localPlayer.interior)
    
    exports['cr_custom-chat']:showChat(false)
    setElementData(localPlayer, "hudVisible", false)
    setElementData(localPlayer, "keysDenied", true)
    
    local x,y,z = getElementPosition(localPlayer)
    state = true

    exports['cr_core']:smoothMoveCamera(x,y,z+1,x,y,z+1,x,y,z+250,x,y,z,time)

    if isTimer(movingTimer) then 
        killTimer(movingTimer)
    end
    
    movingTimer = setTimer(
        function()
            exports['cr_core']:smoothMoveCamera(x,y,z+250,x,y,z,x,y,z+250,x,y,z,7500 + 5000)
            fadeCamera(false, 5, 0,0,0)
            movingTimer = setTimer(
                function()
                    fadeCamera(true, 5)
                    movingTimer = setTimer(
                        function()
                            triggerServerEvent("readyToMoveInNewWorld", localPlayer, localPlayer)
                            exports['cr_controls']:toggleAllControls(true, "instant")
                            setElementData(localPlayer, "char >> bone", {true, true, true, true, true})
                            startShader()
                            setGameSpeed(speedOnDeath)
                            startClockTimer()
                        end, 5000, 1
                    )
                end, 7500, 1
            )
        end, time, 1
    )
end

function startClockTimer()
    stopClockTimer()
    addEventHandler("onClientRender", root, drawnClock, true, "low-5")
    state = true
    heartSound = playSound("sounds/heart.mp3", true)
    setSoundVolume(heartSound, 0.5)
    backgroundSound = playSound("sounds/backgroundSound.mp3", true)
    setSoundVolume(backgroundSound, 0.65)
    effectTimer = setTimer(
        function()
            createEffect()
        end, 1 * 60 * 1000, 0
    )

    clockTimer = setTimer(
        function()
            seconds = seconds - 1
            if seconds <= 0 then
                seconds = 59
                minutes = minutes - 1
                if minutes < 0 then
                    minutes = 0
                    setElementData(localPlayer, "respawn", true)
                    setElementData(localPlayer, "respawn.min", 0)
                    for k,v in pairs(getElementsByType("player")) do 
                        setElementCollidableWith(localPlayer, v, false)
                    end
                    local a = 0
                    triggerServerEvent("collisions", localPlayer, localPlayer, false)
                    respawnTimer = setTimer(
                        function()
                            a = a + 1
                            setElementData(localPlayer, "respawn.min", a)
                            if a == 1 then
                                triggerServerEvent("collisions", localPlayer, localPlayer, true)
                                for k,v in pairs(getElementsByType("player")) do 
                                    setElementCollidableWith(localPlayer, v, true)
                                end
                            elseif a >= 10 then
                                setElementData(localPlayer, "respawn", false)
                            end
                        end, 60 * 1000, 10
                    )
                    triggerServerEvent("goToMedical", localPlayer, localPlayer, time)
                end
            end
        end, 1000, 0
    )
end

local effect = 0
function clearDeathEffects(e)
    if e == localPlayer then
        --setTime(getRealTime()["hour"], getRealTime()["minute"])
        --setWeather(0)
        if isTimer(movingTimer) then 
            killTimer(movingTimer)
        end 
        stopAnim()
        setGameSpeed(1)
        stopClockTimer()
        stopShader()
        fadeCamera(true)
        state = false
    end
end
addEvent("Clear -> DeathEffect", true)
addEventHandler("Clear -> DeathEffect", root, clearDeathEffects)

addEventHandler("onClientResourceStop", resourceRoot,
    function()
        if localPlayer:getData("inDeath") then
            clearDeathEffects(localPlayer)
        end
    end
)

function createEffect()
    effect = effect + 1
    if effect > 4 then
        effect = 1
    end
    
    if effect == 4 then -- Víz felemelkedik 10 Másodpercig
        exploisonTimer = setTimer(
            function()
                local x,y,z = getElementPosition(localPlayer)
                local replace = {
                    [1] = 1,
                    [2] = -1,
                }
                createExplosion(x - (math.random(10,20) * replace[math.random(1,2)]), y - (math.random(10,20) * replace[math.random(1,2)]), z, 12)
            end, 2.5 * 1000, 0
        )
        setTimer(
            function()
                killTimer(exploisonTimer)
            end, 30 * 1000, 1
        )
    elseif effect == 2 then -- Fehér villanás 10 Másodpercig, kiesel a világból
        startWhiteShader()
        exports['cr_controls']:toggleAllControls(false, "instant")
        setSoundVolume(heartSound, 1)
        setSoundVolume(backgroundSound, 0.1)
        local x,y,z = getElementPosition(localPlayer)
        setElementPosition(localPlayer, x,y,z + 10)
        setElementFrozen(localPlayer, true)
        setTimer(
            function()
                setElementFrozen(localPlayer, false)
                stopWhiteShader()
                exports['cr_controls']:toggleAllControls(true, "instant")
                setSoundVolume(heartSound, 0.5)
                setSoundVolume(backgroundSound, 0.7)
            end, 10 * 1000, 1
        )
    end
end

function stopClockTimer()
    if state then
        removeEventHandler("onClientRender", root, drawnClock)
        state = false
    end
    if isTimer(movingTimer) then
        killTimer(movingTimer)
    end
    if isTimer(effectTimer) then
        killTimer(effectTimer)
    end
    if isTimer(clockTimer) then
        killTimer(clockTimer)
    end
    if isElement(heartSound) then
        destroyElement(heartSound)
    end
    if isElement(backgroundSound) then
        destroyElement(backgroundSound)
    end
end

function formatString(n)
    if n < 10 then
        n = "0" .. n
    end
    return n
end

local sx, sy = guiGetScreenSize()

function drawnClock()
    local font = exports['cr_fonts']:getFont("Poppins-SemiBold", 16)
    local minutesS = formatString(minutes)
    local secondsS = formatString(seconds)
    local x, y = sx - 70, sy - 50
    dxDrawText(minutesS .. ":" .. secondsS,x,y+1,x,y+1,tocolor(0,0,0,245),1, font, "center", "top", false, false, false, true) -- Fent
    dxDrawText(minutesS .. ":" .. secondsS,x,y-1,x,y-1,tocolor(0,0,0,245),1, font, "center", "top", false, false, false, true) -- Lent
    dxDrawText(minutesS .. ":" .. secondsS,x-1,y,x-1,y,tocolor(0,0,0,245),1, font, "center", "top", false, false, false, true) -- Bal
    dxDrawText(minutesS .. ":" .. secondsS,x+1,y,x+1,y,tocolor(0,0,0,245),1, font, "center", "top", false, false, false, true) -- Jobb
    local r,g,b = 255,255,255
    if minutes <= 3 then
        r,g,b = 255,87,87
    end
    dxDrawText(minutesS .. ":" .. secondsS, x, y, x, y, tocolor(r,g,b,255), 1, font, "center", "top")
end

addEventHandler("onClientResourceStart", resourceRoot,
    function()
        if getElementData(localPlayer, "char >> death") then
            startDeath()
        end   
    end
)

local hunText = {
    ["Fist"] = "Halált okozó testi sértés",
    ["Brassknuckle"] = "Boxer",
    ["Golfclub"] = "Golfütő",
    ["Nightstick"] = "Gumibot",
    ["Knife"] = "Kés",
    ["Bat"] = "Baseball ütő",
    ["Shovel"] = "Ásó",
    ["Poolstick"] = "Dákó",
    ["Chainsaw"] = "Láncfűrész",
    ["Cane"] = "Járóbot",
    ["Flower"] = "Csokor virág",
    ["Fire Extinguisher"] = "Tűzoltó készülék",
    ["Spraycan"] = "Spray kanna",
    ["Molotov"] = "Molotov gránát",
    ["Teargas"] = "Könnygáz",
    ["Grenade"] = "Gránát",
    ["Flamethrower"] = "Elégett",
    ["Rocket Launcher"] = "Rakétavető",
    ["Rocket Launcher HS"] = "Rakétavető HK",
    ["Sniper"] = "Mesterlövész puska",
    ["Rifle"] = "Vadászpuska",
    ["Combat Shotgun"] = "SPAZ-12 taktikai sörétes puska",
    ["Sawed-off"] = "Rövid csövű sörétes puska",
    ["Shotgun"] = "Sörétes puska",
    ["Colt 45"] = "Glock 18",
    ["Silenced"] = "Hangtompítós Colt-45",
    ["Satchel"] = "Tapadó bomba",
    ["Explosion"] = "Felrobbant",
}

function getWeaponNameTranslated(name)
    return hunText[name]
end

function player_Wasted(attacker, weapon, bodypart)
    local hexColor = "#ff3333"
    local tempString = "#ffffffHalál oka: "
    local tempString2 = "#ffffffHalál oka: "
    if attacker then
        if getElementType(attacker) == "player" then
            local weaponName = getWeaponNameFromID(weapon)
            if hunText[weaponName] then
                weaponName = hunText[weaponName]
            end
            tempString = tempString .. hexColor .. weaponName..""
            local killerName = getElementData(attacker, "char >> name"):gsub("_", " ") or getPlayerName(attacker):gsub("_", " ")
            tempString2 = tempString2 .. hexColor .. weaponName.." #ffffff(" .. hexColor .. killerName .. "#ffffff)"
        elseif getElementType(attacker) == "vehicle" then
            tempString = tempString .. hexColor .. "Elütötték#ffffff!"
            local killerName = "Ismeretlen, Kocsi id: " .. tonumber(getElementData(attacker, "veh >> id") or "Ismeretlen")
            local killer = getVehicleController(attacker)
            if killer then
                killerName = getElementData(killer, "char >> name"):gsub("_", " ") or getPlayerName(killer):gsub("_", " ")
            end
            tempString2 = tempString2 .. hexColor .. "Elütötték#ffffff! (" .. hexColor .. killerName .. "#ffffff)"
        end
        if ( bodypart == 9 ) then
            if not getElementData(localPlayer, "char >> headless") then
                setElementData(localPlayer, "char >> headless", true)
            end
            tempString = tempString.." #ffffff(" .. hexColor .. "FEJLÖVÉS!#ffffff)"
            tempString2 = tempString2.." #ffffff(" .. hexColor .. "FEJLÖVÉS!#ffffff)"
        end
    else
        tempString = tempString .. hexColor .. "Ismeretlen!"
        tempString2 = tempString2 .. hexColor .. "Ismeretlen! (Ismeretlen elkövető...)"
    end
    
    if localPlayer:getData("specialReason") then
        local value = localPlayer:getData("specialReason")
        if type(value) == "table" then
            tempString = value[1]
            tempString2 = value[2]
        else
            tempString = value
            tempString2 = value
        end
        localPlayer:setData("specialReason", nil)
    end
    
    setElementData(localPlayer, "deathReason", tempString)
    setElementData(localPlayer, "deathReason >> admin", tempString2)
end
addEventHandler("onClientPlayerWasted", localPlayer, player_Wasted)

addEventHandler("onClientPlayerWasted", localPlayer,
    function(killer,weapon,bodypart)
        if not state then
            startDeath()
        end
    end
)

addEventHandler("onClientElementDataChange", localPlayer,
    function(dName)
        if dName == "char >> death" then
            local value = getElementData(source, dName)
            if value then
                if not state then
                    startDeath()
                end
            end
        end
    end
)

addEventHandler("onClientPlayerSpawn", localPlayer,
    function()
        if getElementData(localPlayer, "inDeath") then
            exports['cr_controls']:toggleAllControls(false, "instant")
            exports['cr_custom-chat']:showChat(false)
            setElementData(localPlayer, "hudVisible", false)
            setElementData(localPlayer, "char >> headless", false)
            setGameSpeed(speedOnDeath)

            local x,y,z = getElementPosition(localPlayer)
            exports['cr_core']:smoothMoveCamera(x, y, z + 250, x, y, z, x, y, z + 4, x, y, z + 3, time)
            setTimer(
                function()
                    setCameraTarget(localPlayer, localPlayer)
                    exports['cr_controls']:toggleAllControls(true, "instant")

                    -- vehicle sync végett
                    localPlayer.dimension = (localPlayer:getData("acc >> id") or 0) - 1
                    localPlayer.dimension = localPlayer:getData("acc >> id")
                end, time, 1
            )
        end
    end
)

addEvent("spawn - event", true)
addEventHandler("spawn - event", root,
    function(e)
        if e ~= localPlayer then return end
        stopClockTimer()
        exports['cr_core']:stopSmoothMoveCamera()
        setElementData(localPlayer, "char >> death", false)
        exports['cr_controls']:toggleAllControls(true, "instant")
        setElementData(localPlayer, "inDeath", false)
        setGameSpeed(1)
        setElementData(localPlayer, "char >> food", 100)
        setElementData(localPlayer, "char >> drink", 100)
        setElementData(localPlayer, "char >> headless", false)
        setCameraTarget(localPlayer, localPlayer)
        exports['cr_custom-chat']:showChat(true)
        setElementData(localPlayer, "hudVisible", true)
        setElementData(localPlayer, "keysDenied", false)
        setElementFrozen(localPlayer, false)
    end
)

--[[
setTimer(
    function()
        if state then
            setTime(0,0)
            setWeather(19)
        end
    end, 1000, 0
)]]

local white = "#ffffff"

addCommandHandler("asegit", 
    function(cmd, target)
        if exports['cr_permission']:hasPermission(localPlayer, cmd) then
            if not target then
                local syntax = exports['cr_core']:getServerSyntax(false, "warning")
                outputChatBox(syntax .. "/"..cmd.." [target]", 255,255,255,true)
                return
            else
                local target = exports['cr_core']:findPlayer(localPlayer, target)
                if target then
                    if not getElementData(target, "char >> death") then
                        local syntax = exports['cr_core']:getServerSyntax(false, "error")
                        outputChatBox(syntax.."A játékos nem halott!", 255,255,255,true)
                        return
                    end
                    local x,y,z = getElementPosition(target)
                    triggerServerEvent("goToMedical", localPlayer, target, 2000, x,y,z)
                    local syntax = exports['cr_core']:getServerSyntax(false, "success")
                    local syntax2 = exports['cr_admin']:getAdminSyntax()
                    local name = exports['cr_admin']:getAdminName(target)
                    local aName = exports['cr_admin']:getAdminName(localPlayer, true)
                    local hexColor = exports['cr_core']:getServerColor('yellow', true)
                    outputChatBox(syntax .. "Sikeresen újraélesztetted "..hexColor..name..white.." játékost!", 255,255,255,true)
                    local text = syntax2 .. ""..hexColor..aName..white.." újraélesztette "..hexColor..name..white.." játékost!"
                    exports['cr_core']:sendMessageToAdmin(localPlayer, text, 3)
                    local text = syntax .. "Újraélesztett "..hexColor..aName..white.."!"
                    triggerServerEvent("outputChatBox", localPlayer, target, text)
                end
            end
        end
    end
)