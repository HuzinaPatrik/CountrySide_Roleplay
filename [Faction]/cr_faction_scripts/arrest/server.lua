function arrestPlayer(thePlayer, target, min, ticket, reason, id)
    if isElement(thePlayer) and isElement(target) then 
        local newPosition = Vector3(jailDatas["cellPositions"][id][1], jailDatas["cellPositions"][id][2], jailDatas["cellPositions"][id][3])
        local newInterior, newDimension = jailDatas["cellPositions"][id][4], jailDatas["cellPositions"][id][5]
        local dbId = tonumber(target:getData("acc >> id"))
        local syntax = exports["cr_core"]:getServerSyntax("Jail", "red")
        local serverHex = exports["cr_core"]:getServerColor("yellow", true)

        target.position = newPosition 
        target.interior = newInterior 
        target.dimension = newDimension

        outputChatBox(syntax..serverHex..exports["cr_admin"]:getAdminName(thePlayer).."#ffffff őrizetbe vett téged.", target, 255, 0, 0, true)
        outputChatBox(syntax..serverHex.."Idő:#ffffff "..min.."#ffffff perc.", target, 255, 0, 0, true)

        if ticket > 0 then 
            outputChatBox(syntax..serverHex.."Bírság:#ffffff "..ticket.."#ffffff dollár.", target, 255, 0, 0, true)
        end

        outputChatBox(syntax..serverHex.."Indok:#ffffff "..reason, target, 255, 0, 0, true)

        triggerLatentClientEvent(target, "faction.startJailTimer", 50000, false, thePlayer)
    end
end
addEvent("faction.arrestPlayer", true)
addEventHandler("faction.arrestPlayer", root, arrestPlayer)

function releasePlayer(thePlayer)
    if isElement(thePlayer) then 
        thePlayer.position = jailReleasePoint
        thePlayer.rotation = jailReleaseRotationPoint
        thePlayer.interior = jailReleaseInterior 
        thePlayer.dimension = jailReleaseDimension 

        local syntax = exports["cr_core"]:getServerSyntax("Jail", "green")
        outputChatBox(syntax.."Kiszabadultál a börtönből, legközelebb vigyázz magadra!", thePlayer, 255, 0, 0, true)

        triggerLatentClientEvent(thePlayer, "faction.destroyJailTimer", 50000, false, thePlayer)
        thePlayer:removeData("jail >> data")
    end
end
addEvent("faction.releasePlayer", true)
addEventHandler("faction.releasePlayer", root, releasePlayer)