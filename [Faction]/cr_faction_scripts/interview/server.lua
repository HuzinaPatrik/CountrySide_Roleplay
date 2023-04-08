local pendingInvites = {}

function inviteForInterview(thePlayer, cmd, target)
    if thePlayer:getData("loggedIn") then 
        if hasPlayerPermission(thePlayer, cmd) then 
            if not target then 
                local syntax = exports.cr_core:getServerSyntax(false, "yellow")

                outputChatBox(syntax .. "/" .. cmd .. " [Névrészlet / id]", thePlayer, 255, 0, 0, true)
                return
            end

            local target = exports.cr_core:findPlayer(thePlayer, target)

            if target then 
                if target:getData("loggedIn") then 
                    if target == thePlayer then 
                        local syntax = exports.cr_core:getServerSyntax("Interview", "error")

                        outputChatBox(syntax .. "Saját magadat nem tudod meghívni.", thePlayer, 255, 0, 0, true)
                        return
                    end

                    if target:getData("inInterview") then 
                        local syntax = exports.cr_core:getServerSyntax("Interview", "error")

                        outputChatBox(syntax .. "Ez a játékos már egy másik interjúban szerepel.", thePlayer, 255, 0, 0, true)
                        return
                    end

                    if getDistanceBetweenPoints3D(thePlayer.position, target.position) > 5 then 
                        local syntax = exports.cr_core:getServerSyntax("Interview", "error")

                        outputChatBox(syntax .. "Túl messze vagy a kiválasztott játékostól.", thePlayer, 255, 0, 0, true)
                        return
                    end

                    local newsVan = getVehicleInRange(thePlayer, 582, 5)

                    if not isElement(newsVan) then 
                        local syntax = exports.cr_core:getServerSyntax("Interview", "error")

                        outputChatBox(syntax .. "Nincs a közeledben híradós autó.", thePlayer, 255, 0, 0, true)
                        return
                    end

                    if pendingInvites[target] then 
                        local syntax = exports.cr_core:getServerSyntax("Interview", "error")

                        outputChatBox(syntax .. "A kiválasztott játékosnak már függőben van egy meghívása.", thePlayer, 255, 0, 0, true)
                        return
                    end

                    local syntax = exports.cr_core:getServerSyntax("Interview", "success")
                    local syntax2 = exports.cr_core:getServerSyntax("Interview", "info")

                    local hexColor = exports.cr_core:getServerColor("yellow", true)
                    local greenHex = exports.cr_core:getServerColor("green", true)
                    local redHex = exports.cr_core:getServerColor("red", true)

                    local localName = exports.cr_admin:getAdminName(thePlayer)
                    local targetName = exports.cr_admin:getAdminName(target)

                    outputChatBox(syntax .. "Sikeresen felkérted " .. hexColor .. targetName .. white .. " játékost egy interjúra!", thePlayer, 255, 0, 0, true)
                    outputChatBox(syntax2 .. hexColor .. localName .. white .. " felkért egy interjúra.", target, 255, 0, 0, true)
                    outputChatBox(syntax2 .. "Az elfogadáshoz használd az " .. greenHex .. "/acceptinterview" .. white .. ", az elutasításhoz pedig a " .. redHex .. "/declineinterview " .. white .. "parancsot.", target, 255, 0, 0, true)

                    pendingInvites[target] = thePlayer
                else
                    local syntax = exports.cr_core:getServerSyntax(false, "error")

                    outputChatBox(syntax .. "A játékos nincs bejelentkezve.", thePlayer, 255, 0, 0, true)
                end
            else
                local syntax = exports.cr_core:getServerSyntax(false, "error")

                outputChatBox(syntax .. "Nincs ilyen játékos!", thePlayer, 255, 0, 0, true)
            end
        end
    end
end
addCommandHandler("inviteinterview", inviteForInterview, false, false)

function acceptInterview(thePlayer, cmd)
    if thePlayer:getData("loggedIn") then 
        if pendingInvites[thePlayer] then 
            local syntax = exports.cr_core:getServerSyntax("Interview", "success")
            local syntax2 = exports.cr_core:getServerSyntax("Interview", "info")
            local hexColor = exports.cr_core:getServerColor("yellow", true)

            local localName = exports.cr_admin:getAdminName(thePlayer)
            local sourcePlayer = pendingInvites[thePlayer]

            outputChatBox(syntax .. "Sikeresen elfogadtad az interjú meghívást, írni a " .. hexColor .. "/i" .. white .. " parancsal tudsz.", thePlayer, 255, 0, 0, true)
            outputChatBox(syntax2 .. hexColor .. localName .. white .. " elfogadta az interjú meghívásodat.", sourcePlayer, 255, 0, 0, true)

            thePlayer:setData("inInterview", true)
            pendingInvites[thePlayer] = nil
        else
            local syntax = exports.cr_core:getServerSyntax("Interview", "error")

            outputChatBox(syntax .. "Nincs egy interjú meghívásod sem függőben.", thePlayer, 255, 0, 0, true)
        end
    end
end
addCommandHandler("acceptinterview", acceptInterview, false, false)

function declineInterview(thePlayer, cmd)
    if thePlayer:getData("loggedIn") then 
        if pendingInvites[thePlayer] then 
            local syntax = exports.cr_core:getServerSyntax("Interview", "success")
            local hexColor = exports.cr_core:getServerColor("yellow", true)
            local syntax2 = exports.cr_core:getServerSyntax("Interview", "info")

            local localName = exports.cr_admin:getAdminName(thePlayer)
            local sourcePlayer = pendingInvites[thePlayer]

            outputChatBox(syntax .. "Sikeresen elutasítottad az interjú meghívást.", thePlayer, 255, 0, 0, true)
            outputChatBox(syntax2 .. hexColor .. localName .. white .. " elutasította az interjú meghívásodat.", sourcePlayer, 255, 0, 0, true)

            pendingInvites[thePlayer] = nil
        else
            local syntax = exports.cr_core:getServerSyntax("Interview", "error")

            outputChatBox(syntax .. "Nincs egy interjú meghívásod sem függőben.", thePlayer, 255, 0, 0, true)
        end
    end
end
addCommandHandler("declineinterview", declineInterview, false, false)

function endInterview(thePlayer, cmd, target)
    if thePlayer:getData("loggedIn") then 
        if hasPlayerPermission(thePlayer, cmd) then 
            if not target then 
                local syntax = exports.cr_core:getServerSyntax(false, "yellow")

                outputChatBox(syntax .. "/" .. cmd .. " [Névrészlet / id]", thePlayer, 255, 0, 0, true)
                return
            end

            local target = exports.cr_core:findPlayer(thePlayer, target)

            if target then 
                if target:getData("loggedIn") then 
                    if target == thePlayer then 
                        local syntax = exports.cr_core:getServerSyntax("Interview", "error")

                        outputChatBox(syntax .. "Saját magaddal nem tudod abbahagyni az interjút.", thePlayer, 255, 0, 0, true)
                        return
                    end

                    if not target:getData("inInterview") then 
                        local syntax = exports.cr_core:getServerSyntax("Interview", "error")

                        outputChatBox(syntax .. "Ez a játékos nem szerepel egy interjúban sem.", thePlayer, 255, 0, 0, true)
                        return
                    end

                    if getDistanceBetweenPoints3D(thePlayer.position, target.position) > 5 then 
                        local syntax = exports.cr_core:getServerSyntax("Interview", "error")

                        outputChatBox(syntax .. "Túl messze vagy a kiválasztott játékostól.", thePlayer, 255, 0, 0, true)
                        return
                    end

                    local newsVan = getVehicleInRange(thePlayer, 582, 5)

                    if not isElement(newsVan) then 
                        local syntax = exports.cr_core:getServerSyntax("Interview", "error")

                        outputChatBox(syntax .. "Nincs a közeledben híradós autó.", thePlayer, 255, 0, 0, true)
                        return
                    end

                    local syntax = exports.cr_core:getServerSyntax("Interview", "success")
                    local syntax2 = exports.cr_core:getServerSyntax("Interview", "info")

                    local hexColor = exports.cr_core:getServerColor("yellow", true)
                    local greenHex = exports.cr_core:getServerColor("green", true)
                    local redHex = exports.cr_core:getServerColor("red", true)

                    local localName = exports.cr_admin:getAdminName(thePlayer)
                    local targetName = exports.cr_admin:getAdminName(target)

                    outputChatBox(syntax .. "Sikeresen abbahagytad az interjút " .. hexColor .. targetName .. white .. " játékossal!", thePlayer, 255, 0, 0, true)
                    outputChatBox(syntax2 .. hexColor .. localName .. white .. " abbahagyta az interjút veled.", target, 255, 0, 0, true)

                    target:removeData("inInterview")
                else
                    local syntax = exports.cr_core:getServerSyntax(false, "error")

                    outputChatBox(syntax .. "A játékos nincs bejelentkezve.", thePlayer, 255, 0, 0, true)
                end
            else
                local syntax = exports.cr_core:getServerSyntax(false, "error")

                outputChatBox(syntax .. "Nincs ilyen játékos!", thePlayer, 255, 0, 0, true)
            end
        end
    end
end
addCommandHandler("endinterview", endInterview, false, false)

function onQuit()
    if pendingInvites[source] then 
        pendingInvites[source] = nil
    end
end
addEventHandler("onPlayerQuit", root, onQuit)