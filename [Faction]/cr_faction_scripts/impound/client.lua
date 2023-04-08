function impoundVehicle(cmd, ...)
    if localPlayer:getData("loggedIn") then 
        if hasPlayerPermission(localPlayer, cmd) then 
            if not ... then 
                local syntax = exports["cr_core"]:getServerSyntax(false, "lightyellow")
                return outputChatBox(syntax.."/"..cmd.." [eljáró szerv neve]", 255, 0, 0, true)
            else
                if localPlayer:isInVehicle() then 
                    local enforcerFaction = table.concat({...}, " ")
                    local vehicle = localPlayer.vehicle 

                    if not vehicle:getData("veh >> faction") or vehicle:getData("veh >> faction") <= 0 then 
                        triggerLatentServerEvent("factionscripts.impoundVehicle", 5000, false, localPlayer, localPlayer, vehicle, enforcerFaction)
                    else 
                        local syntax = exports["cr_core"]:getServerSyntax("Impound", "error")
                        return outputChatBox(syntax.."Frakció járművet nem foglalhatsz le.", 255, 0, 0, true)
                    end
                else 
                    local syntax = exports["cr_core"]:getServerSyntax("Impound", "error")
                    return outputChatBox(syntax.."Nem ülsz járműben.", 255, 0, 0, true)
                end
            end
        end
    end
end
addCommandHandler("lefoglal", impoundVehicle, false, false)
addCommandHandler("impound", impoundVehicle, false, false)