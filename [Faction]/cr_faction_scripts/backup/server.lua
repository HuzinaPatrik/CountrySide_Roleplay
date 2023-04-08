addEvent("faction.createBackup", true)
addEventHandler("faction.createBackup", root,
    function(reason)
        triggerLatentClientEvent(getElementsByType("player"), "faction.createBackup", 50000, false, client, client, reason)
    end
)

addEvent("faction.destroyBackup", true)
addEventHandler("faction.destroyBackup", root,
    function()
        triggerLatentClientEvent(getElementsByType("player"), "faction.destroyBackup", 50000, false, client, client)
    end
)