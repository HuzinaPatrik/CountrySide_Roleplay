addDebugHook("preFunction",
	function (sourceResource, functionName, isAllowedByACL, luaFilename, luaLineNumber, ...)
		local args = {...}
		local isSafeFunction = true
		
		for k,v in pairs(args) do
			args[k] = tostring(v)
		end
		
		if not (sourceResource and getResourceName(sourceResource)) then
			isSafeFunction = false
		end
		
		if not isSafeFunction then
            exports['cr_logs']:createLog(localPlayer, "sql", "FunctionDefend", "player: "..exports['cr_admin']:getAdminName(localPlayer)..", resourceName: " .. resourceName .. ", functionName: " .. functionName .. ", luaFilename: " .. (luaFilename or "unknown") .. ", luaLineNumber: " .. (luaLineNumber or "-") .. ", args: " .. (args and table.concat(args, "|") or "-"))
            outputDebugString("player: "..exports['cr_admin']:getAdminName(localPlayer)..", resourceName: " .. resourceName .. ", functionName: " .. functionName .. ", luaFilename: " .. (luaFilename or "unknown") .. ", luaLineNumber: " .. (luaLineNumber or "-") .. ", args: " .. (args and table.concat(args, "|") or "-"))
			return "skip"
		end
	end, {"loadstring", "setElementData", "triggerServerEvent"}
)

function checkAdminLevel()
    local oLevel = tonumber(localPlayer:getData("admin >> level"))
    if oLevel then
        if exports['cr_admin']:getAdminTitle(localPlayer):lower() == tostring("Ismeretlen (Jelentsd fejlesztőnek!)"):lower() then
            localPlayer:setData("admin >> level", 0)
            localPlayer:setData("admin >> duty", false)
            
            exports['cr_logs']:createLog(localPlayer, "sql", "AdminRankDefend", "player: "..exports['cr_admin']:getAdminName(localPlayer).."; AdminLevel: "..oLevel)
            outputDebugString("Nem megfelelő adminrank! Player: "..exports['cr_admin']:getAdminName(localPlayer).. "; AdminLevel: "..oLevel, 0, 255, 87, 87)
        end
        
        if localPlayer:getData("admin >> duty") then
            if oLevel <= 2 then
                localPlayer:setData("admin >> duty", false)
                exports['cr_logs']:createLog(localPlayer, "sql", "AdminDutyDefend", "player: "..exports['cr_admin']:getAdminName(localPlayer).."; AdminLevel: "..oLevel)
                outputDebugString("Nem lehet admindutyban mégis abban van! Player: "..exports['cr_admin']:getAdminName(localPlayer).. "; AdminLevel: "..oLevel, 0, 255, 87, 87)
            end
        end
        
        --[[
        if not localPlayer:getData("loggedIn") then
            if oLevel > 0 then
                localPlayer:setData("admin >> level", 0)
                localPlayer:setData("admin >> duty", false)

                exports['cr_logs']:createLog(localPlayer, "sql", "AdminRankDefendWithoutLogin", "player: "..exports['cr_admin']:getAdminName(localPlayer).."; AdminLevel: "..oLevel)
                outputDebugString("Nincs belépve mégis van adminrank! Player: "..exports['cr_admin']:getAdminName(localPlayer).. "; AdminLevel: "..oLevel, 0, 255, 87, 87)
            end
        end]]
    end
end
setTimer(checkAdminLevel, 1000, 0)