function changeCustomName(cmd, ...)
    if localPlayer:getData("loggedIn") then 
        if hasPlayerPermission(localPlayer, cmd) then 
            if not ... then 
                local customName = localPlayer:getData("char >> customName")

                if not customName or customName:len() <= 0 then 
                    local syntax = exports["cr_core"]:getServerSyntax(false, "lightyellow")
                    return outputChatBox(syntax.."/"..cmd.." [név]", 255, 0, 0, true)
                else 
                    local syntax = exports["cr_core"]:getServerSyntax(false, "success")
                    local serverHex = exports["cr_core"]:getServerColor("yellow", true)

                    outputChatBox(syntax.."Sikeresen kikapcsoltad az álnevet.", 255, 0, 0, true)
                    exports["cr_core"]:sendMessageToAdmin(localPlayer, exports["cr_admin"]:getAdminSyntax()..serverHex..exports["cr_admin"]:getAdminName(localPlayer).."#ffffff kikapcsolta az álnevet.", 3)

                    localPlayer:setData("char >> customName", false)
                end
            else 
                local name = table.concat({...}, " ")
                local customName = localPlayer:getData("char >> customName")

                if name then 
                    if not customName or customName:len() <= 0 then 
                        triggerLatentServerEvent("faction.customName", 5000, false, localPlayer, localPlayer, name)
                    else 
                        local syntax = exports["cr_core"]:getServerSyntax(false, "success")
                        local serverHex = exports["cr_core"]:getServerColor("yellow", true)

                        outputChatBox(syntax.."Sikeresen kikapcsoltad az álnevet.", 255, 0, 0, true)
                        exports["cr_core"]:sendMessageToAdmin(localPlayer, exports["cr_admin"]:getAdminSyntax()..serverHex..exports["cr_admin"]:getAdminName(localPlayer).."#ffffff kikapcsolta az álnevet.", 3)

                        localPlayer:setData("char >> customName", false)
                    end
                end
            end
        end
    end
end
addCommandHandler("alnev", changeCustomName, false, false)