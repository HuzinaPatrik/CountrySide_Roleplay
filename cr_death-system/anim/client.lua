local start, startTick, animTimer
local disabledControls = {"fire", "forwards", "backwards", "left", "right", "action", "crouch", "jump", "sprint", "steer_forward", "steer_back", "accelerate", "brake_reverse", "enter_exit", "vehicle_left", "vehicle_right"}

setTimer(
    function()
        if not localPlayer:getData("loggedIn") then  
            return 
        end 

        if localPlayer.health <= 15 and localPlayer.health > 0 then 
            if not start then 
                start = true  
                startTick = getTickCount()
                localPlayer:setData("inAnim", {getTickCount(), startTick})
                localPlayer:setData("bloodData", {})

                if localPlayer.vehicle then 
                    setElementData(localPlayer, "forceAnimation", {"ped", "car_dead_lhs"});
                else 
                    setElementData(localPlayer, "forceAnimation", {"sweet", "sweet_injuredloop"});
                end 

                local time = exports['cr_core']:getTime()
                local white = "#dcdcdc"
                local syntax = white .. time .. " "
                local blue = exports['cr_core']:getServerColor('yellow', true)
                local playerName = exports['cr_admin']:getAdminName(localPlayer)
                exports['cr_core']:sendMessageToAdmin(localPlayer, syntax .. blue .. playerName .. white .. " animba esett!", 3)
                exports['cr_logs']:addLog(localPlayer, "Anim", "inAnim", time .. " " .. playerName .. " animba esett!")

                exports['cr_controls']:toggleControl(disabledControls, false, "instant")
                -- exports['cr_controls']:toggleAllControls(false, true, false, "instant")

                if isTimer(animTimer) then 
                    killTimer(animTimer)
                end 

                if isTimer(updateTimer) then 
                    killTimer(updateTimer)
                end 

                animTimer = setTimer(checkAnimation, 5 * 1000, 0)

                if isTimer(clockTimer) then 
                    killTimer(clockTimer)
                end 

                seconds = 0 
                minutes = 10

                clockTimer = setTimer( 
                    function()
                        localPlayer:setData("inAnim", {getTickCount(), startTick})
                        seconds = seconds - 1 
                        if seconds <= 0 then 
                            seconds = 59
                            minutes = minutes - 1 
                            if minutes <= 0 then 
                                seconds = 0
                                minutes = 0 

                                stopAnim()

                                localPlayer.health = 0
                            end 
                        end 
                    end, 1000, 0
                )

                createRender("drawnTimer", drawnTimer)
            end 
        elseif localPlayer.health > 15 or localPlayer:getData("inDeath") then 
            if start then 
                localPlayer:setData("inAnim", false)
                start = false 
                startTick = getTickCount()
                setElementData(localPlayer, "forceAnimation", {"", ""});

                exports['cr_controls']:toggleControl(disabledControls, true, "instant")
                -- exports['cr_controls']:toggleAllControls(true, "instant")

                if isTimer(clockTimer) then 
                    killTimer(clockTimer)
                end 

                if isTimer(animTimer) then 
                    killTimer(animTimer)
                end 

                if isTimer(updateTimer) then 
                    killTimer(updateTimer)
                end 

                destroyRender("drawnTimer")
            end 
        end 
    end, 500, 0 
)

function stopAnim()
    if start then 
        localPlayer:setData("inAnim", false)
        start = false 
        startTick = getTickCount()
        setElementData(localPlayer, "forceAnimation", {"", ""});

        exports['cr_controls']:toggleControl(disabledControls, true, "instant")
        -- exports['cr_controls']:toggleAllControls(true, "instant")

        if isTimer(clockTimer) then 
            killTimer(clockTimer)
        end 

        if isTimer(animTimer) then 
            killTimer(animTimer)
        end 

        destroyRender("drawnTimer")
    end
end 

function drawnTimer()
    local nowTick = getTickCount()
    local alpha = 0
    if start then
        local elapsedTime = nowTick - startTick
        local duration = 250
        local progress = elapsedTime / duration
        local alph = interpolateBetween(
            0, 0, 0,
            255, 0, 0,
            progress, "InOutQuad"
        )

        alpha = alph
    else

        local elapsedTime = nowTick - startTick
        local duration = 250
        local progress = elapsedTime / duration
        local alph = interpolateBetween(
            255, 0, 0,
            0, 0, 0,
            progress, "InOutQuad"
        )

        alpha = alph
    end 

    local x, y, w = exports['cr_interface']:getNode("Actionbar", "x"), exports['cr_interface']:getNode("Actionbar", "y"), exports['cr_interface']:getNode("Actionbar", "width")
    local font = exports['cr_fonts']:getFont("Roboto", 20)

    local minutes, seconds = minutes, seconds 
    local color = tocolor(255,255,255, alpha)
    if minutes < 5 then 
        color = tocolor(255, 59, 59, alpha)
    end 

    if minutes < 10 then 
        minutes = "0" .. minutes 
    end 

    if seconds < 10 then 
        seconds = "0" .. seconds 
    end 

    exports['cr_core']:shadowedText(minutes .. ":" .. seconds, x, y - 30, x + w, y - 30, color, 1, font, "center", "bottom", false, alpha)
end 

local updateTimer;
function checkAnimation()
    local anim1, anim2 = getPedAnimation(localPlayer)
    local realAnim1, realAnim2 = "sweet", "sweet_injuredloop"

    if localPlayer.vehicle then 
        realAnim1, realAnim2 = "ped", "car_dead_lhs"
    end 

    if anim1 ~= realAnim1 or anim2 ~= realAnim2 then 
        setElementData(localPlayer, "forceAnimation", {"", ""});

        if isTimer(updateTimer) then 
            killTimer(updateTimer)
        end 
        updateTimer = setTimer(setElementData, 1000, 1, localPlayer, "forceAnimation", {realAnim1, realAnim2});
    end 
end 