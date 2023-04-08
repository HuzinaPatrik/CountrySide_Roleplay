--

afk = false
lastClickTick = -5000

function startAfkTimer(oldData)
    if not localPlayer:getData("loggedIn") then return end
    stopAfkTimer()
    --outputChatBox("Afk start: "..tostring(afk))
    
    afkStartTimer = setTimer(
        function()
            if afk then
                if oldData then
                    local afkData = localPlayer:getData("afk.data") or {["seconds"] = "00", ["minutes"] = "00", ["hours"] = "00"}
                    seconds = tonumber(afkData.seconds)
                    --setElementData(localPlayer, "afk.seconds", "00")
                    minutes = tonumber(afkData.minutes)
                    --setElementData(localPlayer, "afk.minutes", "00")
                    hours = tonumber(afkData.hours)
                    --setElementData(localPlayer, "afk.hours", "00")
                else
                    seconds = 0
        --            setElementData(localPlayer, "afk.data", {["seconds"] = "00", ["minutes"] = "00", ["hours"] = "00"})
                    minutes = 0
                    --setElementData(localPlayer, "afk.minutes", "00")
                    hours = 0
                    --setElementData(localPlayer, "afk.hours", "00")
                end
                afkTimer = setTimer(
                    function()
                        seconds = seconds + 1
                        --outputChatBox("asd2")
                        --setElementData(localPlayer, "afk.seconds", formatString(seconds))
                        setElementData(localPlayer, "afk.data", {["seconds"] = formatString(seconds), ["minutes"] = formatString(minutes), ["hours"] = formatString(hours)})
                        if seconds >= 60 then
                            seconds = 0 
                            --setElementData(localPlayer, "afk.seconds", formatString(seconds))
                            minutes = minutes + 1
                            --setElementData(localPlayer, "afk.minutes", formatString(minutes))
                            setElementData(localPlayer, "afk.data", {["seconds"] = formatString(seconds), ["minutes"] = formatString(minutes), ["hours"] = formatString(hours)})

                            if hours >= 1 and minutes >= 30 then
                                if not exports['cr_core']:getPlayerDeveloper(localPlayer) then
                                    triggerServerEvent("acheat:kick", localPlayer, localPlayer, "Túl sokat afkoltál (Átlépted az 1.5 órás korlátot)!")
                                end
                            end

                            if minutes == 30 then
                                local syntax = exports['cr_core']:getServerSyntax("AFK", "warning")
                                local aName = exports['cr_admin']:getAdminName(localPlayer)
                                local white = "#ffffff"
                                local green = exports['cr_core']:getServerColor(nil, true)
                                exports['cr_core']:sendMessageToAdmin(localPlayer, syntax .. green .. aName .. white .. ": "..green..hours..white.." órája és "..green..minutes..white.." perce afkol!", 3)
                            end

                            if minutes >= 60 then
                                minutes = 0
                                --setElementData(localPlayer, "afk.minutes", formatString(minutes))
                                hours = hours + 1
                                --setElementData(localPlayer, "afk.hours", formatString(hours))
                                setElementData(localPlayer, "afk.data", {["seconds"] = formatString(seconds), ["minutes"] = formatString(minutes), ["hours"] = formatString(hours)})

                                local syntax = exports['cr_core']:getServerSyntax("AFK", "warning")
                                local aName = exports['cr_admin']:getAdminName(localPlayer)
                                local white = "#ffffff"
                                local green = exports['cr_core']:getServerColor(nil, true)
                                exports['cr_core']:sendMessageToAdmin(localPlayer, syntax .. green .. aName .. white .. ": "..green..hours..white.." órája és "..green..minutes..white.." perce afkol!", 3)
                            end
                        end
                    end, 1000, 0
                )
            end
        end, 30 * 1000, 1
    )
end

function stopAfkTimer()
    --outputChatBox("Afk stop: "..tostring(afk))
    if isTimer(afkStartTimer) then 
        killTimer(afkStartTimer) 
    end
    if isTimer(afkTimer) then
        setElementData(localPlayer, "afk.data", {["seconds"] = "00", ["minutes"] = "00", ["hours"] = "00"})
        killTimer(afkTimer)
        seconds, minutes, hours = 0,0,0
        --setElementData(localPlayer, "afk.seconds", nil)
        --setElementData(localPlayer, "afk.minutes", nil)
        --setElementData(localPlayer, "afk.hours", nil)
    end
end
--

local lastClickTick = getTickCount()

addEventHandler("onClientKey", root, 
    function()
        if not isMTAWindowActive() then
            lastClickTick = getTickCount()
            if afk then
                --outputChatBox("asd")
                stopAfkTimer()
                setElementData(localPlayer, "char >> afk", false)
                afk = false
            end
        end
    end
)

setTimer( 
    function()
        if not isMTAWindowActive() then
            local nowTick = getTickCount()
            if nowTick - lastClickTick >= 60000 then
                if not afk then
                    afk = true
                    startAfkTimer()
                    setElementData(localPlayer, "char >> afk", true)
                end
            end
        end
    end, 1000, 0
)
	
addEventHandler("onClientRestore", root, 
    function()
        if not isMTAWindowActive() then
            lastClickTick = getTickCount()
            if afk then
                setElementData(localPlayer, "char >> afk", false)
                stopAfkTimer()
                afk = false
            end
        end
    end
)

addEventHandler("onClientMinimize", root, 
    function()
        if not isMTAWindowActive() then
            if not afk then
                afk = true
                startAfkTimer()
                setElementData(localPlayer, "char >> afk", true)
            end
        end
    end
)
	
addEventHandler("onClientCursorMove", root, 
    function()
        if not isMTAWindowActive() then
            lastClickTick = getTickCount()
            if afk then
                setElementData(localPlayer, "char >> afk", false)
                stopAfkTimer()
                afk = false
            end
        end
    end
)

local seconds,minutes,hours = 0, 0, 0

function formatString(s)
    if s < 10 then
        return "0" .. tostring(s)
    end
    return tostring(s)
end

if getElementData(localPlayer, "char >> afk") then
    afk = true
    startAfkTimer(true)
end