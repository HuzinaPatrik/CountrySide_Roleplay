function hasPermission(thePlayer, factionId, permName)
    if isElement(thePlayer) and factionId and permName then 
        if exports.cr_dashboard:isPlayerInFaction(thePlayer, factionId) then 
            if exports.cr_dashboard:hasPlayerPermission(thePlayer, factionId, permName) or exports.cr_dashboard:isPlayerFactionLeader(thePlayer, factionId) then 
                return true
            end
        end
    end

    return false
end

local pendingRequests = {}

function requestPayCommand(cmd, target, price)
    if localPlayer:getData("loggedIn") then 
        if hasPermission(localPlayer, 3, "mechanic.canRepair") then 
            if not target or not price then 
                local syntax = exports.cr_core:getServerSyntax(false, "yellow")

                outputChatBox(syntax .. "/" .. cmd .. " [Névrészlet / id] [Összeg]", 255, 0, 0, true)
                return
            end

            local target = exports.cr_core:findPlayer(localPlayer, target)
            local price = tonumber(price)

            if target then 
                if target:getData("loggedIn") then 
                    if getDistanceBetweenPoints3D(localPlayer.position, target.position) > 3 then 
                        local syntax = exports.cr_core:getServerSyntax("Mechanic", "error")

                        outputChatBox(syntax .. "Túl messze vagy a kiválasztott játékostól.", 255, 0, 0, true)
                        return
                    end

                    if not price then 
                        local syntax = exports.cr_core:getServerSyntax("Mechanic", "error")

                        outputChatBox(syntax .. "Hibás összeg.", 255, 0, 0, true)
                        return
                    end

                    price = math.floor(tonumber(price))

                    if price <= 0 then 
                        local syntax = exports.cr_core:getServerSyntax("Mechanic", "error")

                        outputChatBox(syntax .. "Az összegnek minimum 1 dollárnak kell lennie.", 255, 0, 0, true)
                        return
                    end

                    if target:getData("mechanic.pendingRequest") then 
                        local syntax = exports.cr_core:getServerSyntax("Mechanic", "error")

                        outputChatBox(syntax .. "Ennek a játékosnak már van egy függőben lévő kérelme.", 255, 0, 0, true)
                        return
                    end

                    triggerLatentServerEvent("mechanic.requestPay", 5000, false, localPlayer, target, price)
                else
                    local syntax = exports.cr_core:getServerSyntax(false, "error")

                    outputChatBox(syntax .. "A játékos nincs bejelentkezve.", 255, 0, 0, true)
                end
            else
                local syntax = exports.cr_core:getServerSyntax(false, "error")

                outputChatBox(syntax .. "Nem található a játékos.", 255, 0, 0, true)
            end
        end
    end
end
addCommandHandler("requestpay", requestPayCommand, false, false)

function acceptFixCommand(cmd)
    if localPlayer:getData("loggedIn") then 
        if not localPlayer:getData("mechanic.pendingRequest") then 
            local syntax = exports.cr_core:getServerSyntax(false, "error")

            outputChatBox(syntax .. "Neked jelenleg nincs függőben egy szerelési kérelmed sem.", 255, 0, 0, true)
            return
        end

        triggerLatentServerEvent("mechanic.acceptFix", 5000, false, localPlayer)
    end
end
addCommandHandler("acceptfix", acceptFixCommand, false, false)

function declineFixCommand(cmd)
    if localPlayer:getData("loggedIn") then 
        if not localPlayer:getData("mechanic.pendingRequest") then 
            local syntax = exports.cr_core:getServerSyntax(false, "error")

            outputChatBox(syntax .. "Neked jelenleg nincs függőben egy szerelési kérelmed sem.", 255, 0, 0, true)
            return
        end

        triggerLatentServerEvent("mechanic.declineFix", 5000, false, localPlayer)
    end
end
addCommandHandler("declinefix", declineFixCommand, false, false)

function payFixCommand(cmd)
    if localPlayer:getData("loggedIn") then 
        if not localPlayer:getData("mechanic.pendingRequest") then 
            local syntax = exports.cr_core:getServerSyntax(false, "error")

            outputChatBox(syntax .. "Neked jelenleg nincs függőben egy szerelési kérelmed sem.", 255, 0, 0, true)
            return
        end

        triggerLatentServerEvent("mechanic.payFix", 5000, false, localPlayer)
    end
end
addCommandHandler("payfix", payFixCommand, false, false)