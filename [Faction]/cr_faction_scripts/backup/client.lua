local hasBackup = false 
local onGoingBackups = {}

function backupCommand(cmd, ...)
    if localPlayer:getData("loggedIn") then 
        if hasPlayerPermission(localPlayer, cmd) then 
            if not ... then 
                if not hasBackup then 
                    local syntax = exports["cr_core"]:getServerSyntax(false, "lightyellow")
                    return outputChatBox(syntax.."/"..cmd.." [indok]", 255, 0, 0, true)
                else 
                    local syntax = exports["cr_core"]:getServerSyntax("Backup", "red")
                    local serverHex = exports["cr_core"]:getServerColor("yellow", true)

                    hasBackup = false 
                    exports["cr_dashboard"]:sendMessageToFaction(1, syntax..serverHex..exports["cr_admin"]:getAdminName(localPlayer).."#ffffff lemondta az erősítést.")
                    triggerLatentServerEvent("faction.destroyBackup", 5000, false, localPlayer)
                end
            else 
                local reason = table.concat({...}, " ")
                local syntax = exports["cr_core"]:getServerSyntax("Backup", "red")
                local serverHex = exports["cr_core"]:getServerColor("yellow", true)

                if not hasBackup then 
                    hasBackup = true 

                    exports["cr_dashboard"]:sendMessageToFaction(1, syntax..serverHex..exports["cr_admin"]:getAdminName(localPlayer).."#ffffff erősítést kért. Indok: "..serverHex..reason)

                    triggerLatentServerEvent("faction.createBackup", 5000, false, localPlayer, reason)
                else 
                    hasBackup = false 
                    exports["cr_dashboard"]:sendMessageToFaction(1, syntax..serverHex..exports["cr_admin"]:getAdminName(localPlayer).."#ffffff lemondta az erősítést.")
                    triggerLatentServerEvent("faction.destroyBackup", 5000, false, localPlayer)
                end
            end
        end
    end
end
addCommandHandler("backup", backupCommand, false, false)

function createBackup(thePlayer, reason)
    if not onGoingBackups[thePlayer] then 
        if hasPlayerPermission(localPlayer, "backup") then 
            local blipName = "Erősítés - " .. reason

            onGoingBackups[thePlayer] = {}
            onGoingBackups[thePlayer].theBlip = Blip(thePlayer.position, 0, 2, 255, 0, 0, 255, 0, 0)
            onGoingBackups[thePlayer].theBlip:attach(thePlayer)
            onGoingBackups[thePlayer].blipName = blipName

            exports["cr_radar"]:createStayBlip(blipName, onGoingBackups[thePlayer].theBlip, 0, "target", 24, 24, 102, 178, 255)
        end
    end
end
addEvent("faction.createBackup", true)
addEventHandler("faction.createBackup", root, createBackup)

function destroyBackup(thePlayer)
    if onGoingBackups[thePlayer] then 
        if isElement(onGoingBackups[thePlayer].theBlip) then 
            onGoingBackups[thePlayer].theBlip:destroy()
            exports.cr_radar:destroyStayBlip(onGoingBackups[thePlayer].blipName)
        end

        onGoingBackups[thePlayer] = nil
        collectgarbage("collect")
    end
end
addEvent("faction.destroyBackup", true)
addEventHandler("faction.destroyBackup", root, destroyBackup)

addEventHandler("onClientPlayerQuit", root,
    function()
        if onGoingBackups[source] then 
            destroyBackup(source)
        end
    end
)