local networkStatus = false -- // TRUE = szar, FALSE = JÓ
local remainSec = 1.25

addEventHandler("onClientRender", root,
    function()
        local network = getNetworkStats()
        local breaked = false
        
        --outputChatBox(("packetlossTotal:"..network["packetlossTotal"])
        if network["packetlossTotal"] > 3 then
            if not networkStatus then
                --outputConsole("[Network] Switched off due to packetloss!")
                gText = "Switched off due to packetloss!"
                networkStatus = true
                lastBreakedTick = getTickCount()
                startPanel()
                return
            end
            
            breaked = true
        end
        
        --outputChatBox(("packetlossLastSecond:"..network["packetlossLastSecond"])
        if network["packetlossLastSecond"] >= 1.6 then
            if not networkStatus then
                --outputConsole("[Network] Switched off due to packetloss!")
                gText = "Switched off due to packetloss!"
                networkStatus = true
                lastBreakedTick = getTickCount()
                startPanel()
                return
            end
            
            breaked = true
        end
        
        --outputChatBox(("messagesInResendBuffer:"..network["messagesInResendBuffer"])
        if network["messagesInResendBuffer"] >= 2 then
            if not networkStatus then
                --outputConsole("[Network] Switched off due to messagesInResendBuffer!")
                gText = "Switched off due to messagesInResendBuffer!"
                networkStatus = true
                lastBreakedTick = getTickCount()
                startPanel()
                return
            end
            
            breaked = true
        end
        
        --outputChatBox(("isLimitedByCongestionControl:"..network["isLimitedByCongestionControl"])
        if network["isLimitedByCongestionControl"] > 0 then
            if not networkStatus then
                gText = "Switched off due to isLimitedByCongestionControl!"
                networkStatus = true
                lastBreakedTick = getTickCount()
                startPanel()
                return
            end
            
            breaked = true
        end
        
        --outputChatBox(("isLimitedByOutgoingBandwidthLimit:"..network["isLimitedByOutgoingBandwidthLimit"])
        if network["isLimitedByOutgoingBandwidthLimit"] > 0 then
            if not networkStatus then
                --outputConsole("[Network] Switched off due to isLimitedByOutgoingBandwidthLimit!")
                gText = "Switched off due to isLimitedByOutgoingBandwidthLimit!"
                networkStatus = true
                lastBreakedTick = getTickCount()
                startPanel()
                return
            end
            
            breaked = true
        end
        
        --outputChatBox(("Ping:" .. localPlayer.ping)
        if localPlayer.ping > 220 then
            if not networkStatus then
                --outputConsole("[Network] Switched off due to ping!")
                gText = "Switched off due to ping!"
                networkStatus = true
                --localPlayer:setData("toggleCursor", true)
                lastBreakedTick = getTickCount()
                startPanel()
                return
            end
            
            breaked = true
        end
        
        if networkStatus and not breaked then
            if lastBreakedTick + (remainSec * 1000) <= getTickCount() then
                --outputConsole("[Network] Switched on!")
                networkStatus = false
                stopPanel()
                return
            end
        end
    end, true, "high+55"
)

function getNetworkStatus()
    return networkStatus
end

--localPlayer:setData("toggleCursor", false)
localPlayer:setData("timedout", false)
function startPanel()
    if not isRenderState then
        localPlayer:setData("timedout", true)
        --outputChatBox("toggleCursor on")
        --localPlayer:setData("toggleCursor", true)
        
        rot = 0
        isRenderState = true

        exports['cr_dx']:startFade("networkWarning", 
            {
                ["startTick"] = getTickCount(),
                ["lastUpdateTick"] = getTickCount(),
                ["time"] = 250,
                ["animation"] = "InOutQuad",
                ["from"] = 0,
                ["to"] = 255,
                ["alpha"] = 0,
                ["progress"] = 0,
            }
        )

        createRender('renderPanel', renderPanel)
        --addEventHandler("onClientRender", root, renderPanel, true, "low-55")
        --exports['cr_blur']:createBlur("networkblur", 15)
    end
end

function stopPanel()
    if isRenderState then
        --outputChatBox("toggleCursor off")
        --localPlayer:setData("toggleCursor", false)
        localPlayer:setData("timedout", false)
        
        isRenderState = false

        exports['cr_dx']:startFade("networkWarning", 
            {
                ["startTick"] = getTickCount(),
                ["lastUpdateTick"] = getTickCount(),
                ["time"] = 250,
                ["animation"] = "InOutQuad",
                ["from"] = 255,
                ["to"] = 0,
                ["alpha"] = 255,
                ["progress"] = 0,
            }
        )
        --removeEventHandler("onClientRender", root, renderPanel)
    end
end

local screenSize = {guiGetScreenSize()}
local s = {guiGetScreenSize()}
local box = {s[1], s[2]}
local pos = {s[1]/2 -box[1]/2,s[2]/2 - box[2]/2}
local rightX, rightY, infoW, infoH = (screenSize[1]/2 - 40/2) * 2 - 10, (screenSize[2]/2 - 685/2) * 2 - 73, 304, 155
local rot = 0

local boxS = {0,0}
local textPos = {s[1]/2,s[2]/2}
function renderPanel()
    if exports['cr_dashboard']:getOption('networkWarning') == 1 then 
        local alpha, progress = exports['cr_dx']:getFade("networkWarning")

        if tonumber(alpha) and tonumber(progress) then 
            if not isRenderState then 
                if progress >= 1 then 
                    destroyRender('renderPanel')
                    return 
                end  
            end 
            
            local awesome = exports['cr_fonts']:getFont("AwesomeFont", 13)
            local font = exports['cr_fonts']:getFont("OpenSans", 13)
            local red = exports['cr_core']:getServerColor("red", true)
            local white = "#ffffff"
            dxDrawText("Kapcsolódás a szerverhez... ("..gText..")", textPos[1]-1, textPos[2]+1,textPos[1]-1, textPos[2]+1, tocolor(0,0,0,alpha),1, font, "center", "center")
            dxDrawText("Kapcsolódás a szerverhez... ("..red..gText..white..")", textPos[1], textPos[2],textPos[1], textPos[2], tocolor(255,255,255,alpha),1, font, "center", "center", false, false, false, true)
            rot = rot + 15
            if rot == 360 then
                rot = 0
            end
            dxDrawImage(textPos[1]-35/2-1, textPos[2]-41, 35,35, "loading.png", rot, 0,0, tocolor(0,0,0,alpha))
            dxDrawImage(textPos[1]-35/2, textPos[2]-40, 35,35, "loading.png", rot, 0,0, tocolor(255,255,255,alpha))

            dxDrawText("", rightX-36, pos[2]+11, rightX-36, pos[2]+11, tocolor(0,0,0,alpha),1, awesome, "center", "top")
            dxDrawText("", rightX-1, pos[2]+11, rightX-1, pos[2]+11, tocolor(0,0,0,alpha),1, awesome, "center", "top")
            dxDrawText("", rightX+32, pos[2]+11, rightX+32, pos[2]+11, tocolor(0,0,0,alpha),1, awesome, "center", "top")

            dxDrawText("", rightX-35, pos[2]+10, rightX-35, pos[2]+10, tocolor(210,49,49,alpha),1, awesome, "center", "top")
            dxDrawText("", rightX, pos[2]+10, rightX, pos[2]+10, tocolor(224, 141, 53,alpha),1, awesome, "center", "top")
            dxDrawText("", rightX+33, pos[2]+10, rightX+33, pos[2]+10, tocolor(124, 197, 118,alpha),1, awesome, "center", "top")
        end
    end 
end