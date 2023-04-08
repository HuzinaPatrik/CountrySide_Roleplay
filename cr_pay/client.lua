local payTimer = false
local payTime = 5000
local white = "#ffffff"

function payCommand(cmd, target, value)
    if localPlayer:getData("loggedIn") then 
        if not target or not value then 
            local syntax = exports["cr_core"]:getServerSyntax(false, "warning")
            outputChatBox(syntax.."/"..cmd.." [Játékos ID/Név] [Összeg]", 255, 0, 0, true)
            return
        else
            if isTimer(payTimer) then 
                local syntax = exports["cr_core"]:getServerSyntax(false, "error")
                outputChatBox(syntax.."Már folyamatban van egy átadás, kérlek várj.", 255, 0, 0, true)
                
                return
            end

            local target = exports["cr_core"]:findPlayer(localPlayer, target)
            local value = tonumber(value)

            if target then 
                if target:getData("loggedIn") then 
                    local distance = getDistanceBetweenPoints3D(localPlayer.position, target.position)

                    local targetMoney = tonumber(target:getData('char >> money') or 0)
                    local localMoney = tonumber(localPlayer:getData('char >> money') or 0)

                    if distance <= 3 then 
                        if value ~= nil then 
                            value = math.floor(value)

                            if value > 0 then 
                                if exports["cr_core"]:hasMoney(localPlayer, value) then 
                                    if exports["cr_network"]:getNetworkStatus() then 
                                        return
                                    end

                                    if target == localPlayer then 
                                        local syntax = exports["cr_core"]:getServerSyntax(false, "error")
                                        outputChatBox(syntax.."Saját magadnak nem adhatsz át pénzt.", 255, 0, 0, true)

                                        return
                                    end

                                    local syntax = exports["cr_core"]:getServerSyntax(false, "info")
                                    outputChatBox(syntax.."Átadás folyamatban...", 255, 0, 0, true)

                                    local sourceName = exports["cr_admin"]:getAdminName(localPlayer)
                                    local targetName = exports["cr_admin"]:getAdminName(target)

                                    payTimer = setTimer(
                                        function(targetMoney, localMoney)
                                            local targetMoneyNew = tonumber(target:getData('char >> money') or 0)
                                            local localMoneyNew = tonumber(localPlayer:getData('char >> money') or 0)

                                            if exports["cr_network"]:getNetworkStatus() then 
                                                return
                                            end

                                            if targetMoneyNew ~= targetMoney then 
                                                return
                                            end 

                                            if localMoneyNew ~= localMoney then 
                                                return
                                            end 

                                            local distance = getDistanceBetweenPoints3D(localPlayer.position, target.position)

                                            if distance > 3 then 
                                                local syntax = exports["cr_core"]:getServerSyntax(false, "error")
                                                outputChatBox(syntax.."A játékos túl messze van tőled.", 255, 0, 0, true)

                                                return
                                            end

                                            exports["cr_core"]:takeMoney(localPlayer, value, false)
                                            exports["cr_core"]:giveMoney(target, value, false)

                                            local syntax = exports["cr_core"]:getServerSyntax(false, "success")
                                            local serverHex = exports["cr_core"]:getServerColor('yellow', true)
                                            outputChatBox(syntax.."Sikeresen átadtál "..serverHex..value..white.." dollárt "..serverHex..targetName..white.." játékosnak.", 255, 0, 0, true)

                                            local message = syntax..serverHex..sourceName..white.." átadott neked "..serverHex..value..white.." dollárt."
                                            triggerServerEvent("outputChatBox", localPlayer, target, message)

                                            exports["cr_chat"]:createMessage(localPlayer, "átadott egy kis pénzt "..targetName.."-nek/nak.", 1)

                                            exports["cr_logs"]:addLog(localPlayer, "Bank", "pay", sourceName.." átadott "..value.." dollárt "..targetName.." játékosnak.")
                                        end, payTime, 1, targetMoney, localMoney
                                    )
                                else
                                    local syntax = exports["cr_core"]:getServerSyntax(false, "error")
                                    outputChatBox(syntax.."Nincs elég pénzed.", 255, 0, 0, true)
                                end
                            else
                                local syntax = exports["cr_core"]:getServerSyntax(false, "error")
                                outputChatBox(syntax.."Az összegnek nagyobbnak kell lennie mint 0.", 255, 0, 0, true)
                            end
                        else
                            local syntax = exports["cr_core"]:getServerSyntax(false, "error")
                            outputChatBox(syntax.."Csak szám.", 255, 0, 0, true)
                        end
                    else
                        local syntax = exports["cr_core"]:getServerSyntax(false, "error")
                        outputChatBox(syntax.."A játékos túl messze van tőled.", 255, 0, 0, true)
                    end
                else
                    local syntax = exports["cr_core"]:getServerSyntax(false, "error")
                    outputChatBox(syntax.."A játékos nincs bejelentkezve.", 255, 0, 0, true)
                end
            else
                local syntax = exports["cr_core"]:getServerSyntax(false, "error")
                outputChatBox(syntax.."A játékos nem található.", 255, 0, 0, true)
            end
        end
    end
end
addCommandHandler("pay", payCommand, false, false)