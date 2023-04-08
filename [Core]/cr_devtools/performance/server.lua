addEvent("getServerPerformanceStats", true)
addEventHandler("getServerPerformanceStats", getRootElement(),
	function (category)
		triggerClientEvent(source, "getServerPerformanceStats", source, getPerformanceStats(category))
	end
)

addEvent("performanceFromAnotherClient", true)
addEventHandler("performanceFromAnotherClient", getRootElement(),
	function (anotherClient, category)
		triggerClientEvent(anotherClient, "clientFromAnotherClient", client, category)
	end
)

addEvent("sendToAnother", true)
addEventHandler("sendToAnother", getRootElement(),
	function (player, columns, rows)
		triggerClientEvent(source, "getServerPerformanceStats", player, columns, rows, getPlayerName(source))
	end
)

addCommandHandler("performance",
	function (player, command, target)
		if exports['cr_permission']:hasPermission(player, "performance") and target then
			local targetPlayer = exports['cr_core']:findPlayer(player, target)
			if targetPlayer then
				triggerClientEvent(player, "clientPerformance", targetPlayer)
			end
		end
	end
)
