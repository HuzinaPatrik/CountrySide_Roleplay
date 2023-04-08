addEvent("acheat:kick", true)
addEventHandler("acheat:kick", root,
    function(e, reason)
	    kickPlayer(e, "Rendszer", reason)
	end
)

white = "#ffffff"

connection = exports['cr_mysql']:getConnection(getThisResource())
addEventHandler("onResourceStart", root,
    function(startedRes)
        if getResourceName(startedRes) == "cr_mysql" then
	        connection = exports['cr_mysql']:getConnection(getThisResource())
            restartResource(getThisResource())
        end
	end
)

local blockedSerials = {}
local res = Resource.getFromName("cr_core") 
if res and res.state == "running" then
    syntax = exports['cr_core']:getServerSyntax(false, "success")
    syntax2 = exports['cr_core']:getServerSyntax(false, "warning")
    syntax3 = exports['cr_core']:getServerSyntax(false, "error")
end

addEventHandler("onResourceStart", root,
    function(startedRes)
        if getResourceName(startedRes) == "cr_core" then
	        syntax = exports['cr_core']:getServerSyntax(false, "success")
            syntax2 = exports['cr_core']:getServerSyntax(false, "warning")
            syntax3 = exports['cr_core']:getServerSyntax(false, "error")
        end
	end
)

function debugOnResourceStart(startedRes)
    if not startedRes then return end
    local time = exports['cr_core']:getTime() .. " "
    local resName = getResourceName(startedRes)
    exports['cr_logs']:addLog(-1, "ResourceStart", "start", resName .. " - started!")
    outputDebugString(time .. "" .. resName .. " - started!", 0, 20,20,20)
end
addEventHandler("onResourceStart", root, debugOnResourceStart)

function debugOnResourceStop(stoppedRes)
    if not stoppedRes then return end
    local time = exports['cr_core']:getTime() .. " "
    local resName = getResourceName(stoppedRes)
    exports['cr_logs']:addLog(-1, "ResourceStop", "stop", resName .. " - stopped!")
    outputDebugString(time .. "" .. resName .. " - stopped!", 0, 20,20,20)
end
addEventHandler("onResourceStop", root, debugOnResourceStop)

--[[
local slot = getMaxPlayers()
addEventHandler("onResourceStop", resourceRoot,
    function()
        setMaxPlayers(slot)
    end
)]]

local maxPlayers = getMaxPlayers()

function toFloor(num)
	return tonumber(string.sub(tostring(num), 0, -2)) or 0
end

function calculateMaxPlayers()
    local slot = maxPlayers --root:getData("serverslot")
    
    local columns, rows = getPerformanceStats("Lua timing")
    local a = 0
    for k,v in pairs(rows) do
        a = a + toFloor(v[2])
    end
    
    local multipler = 1 - a/50
    local b = math.floor(math.max(getPlayerCount(), math.min(slot, (slot * multipler) + 0.5)))
    setMaxPlayers(b)
    outputDebugString("New serverslot: "..b)

    root:setData("serverslot", b)
end
calculateMaxPlayers()
setTimer(calculateMaxPlayers, 15 * 60 * 1000, 0)

addCommandHandler('setserverslot',  
    function(thePlayer, cmd, num)
        if exports['cr_permission']:hasPermission(thePlayer, 'setserverslot') then
            local num = tonumber(num)

            if not num then 
                local syntax = exports.cr_core:getServerSyntax(false, "yellow")

                outputChatBox(syntax .. "/" .. cmd .. " [szám]", thePlayer, 255, 0, 0, true)
            else 
                maxPlayers = num
                setMaxPlayers(num)
                root:setData("serverslot", num)

                local adminSyntax = exports['cr_admin']:getAdminSyntax()
                local localName = exports['cr_admin']:getAdminName(thePlayer, true)
                local hexColor = exports['cr_core']:getServerColor("yellow", true)

                exports['cr_core']:sendMessageToAdmin(thePlayer, adminSyntax .. hexColor .. localName .. white .. " átállította a szerver slotot: " .. hexColor .. num, 8)
            end 
        end 
    end 
)