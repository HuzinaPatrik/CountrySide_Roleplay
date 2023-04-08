addEvent("faction.trackPlayer", true)
addEventHandler("faction.trackPlayer", root,
    function(thePlayer, sourceNumber)
        if isElement(thePlayer) and sourceNumber then 
            local data = exports["cr_inventory"]:hasPhone(sourceNumber)

            if data then 
                local accId, nbt = unpack(data)
                local isOnline, targetElement = exports["cr_account"]:getAccountOnline(accId)

                if isOnline then 
                    if isElement(targetElement) then 
                        local syntax = exports["cr_core"]:getServerSyntax(false, "success")
                        outputChatBox(syntax.."Célpont megtalálva, adatok lekérése...", thePlayer, 255, 0, 0, true)

                        triggerLatentClientEvent(thePlayer, "faction.trackPlayer", 50000, false, thePlayer, sourceNumber, targetElement)
                    end
                else 
                    local syntax = exports["cr_core"]:getServerSyntax(false, "red")
                    return outputChatBox(syntax.."Nem található játékos ezzel a telefonszámmal.", thePlayer, 255, 0, 0, true)
                end
            end
        end
    end
)