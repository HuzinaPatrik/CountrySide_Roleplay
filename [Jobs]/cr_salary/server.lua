local multiplier = 0

addEvent("onSalaryMultiplierChange", true)

function genMultiplier(sync)
    local randomNumber = math.random(minMultiplier, maxMultiplier)

    multiplier = randomNumber

    if sync then 
        triggerClientEvent(getElementsByType("player"), "onMultiplierRequest", resourceRoot, multiplier)
    end

    outputDebugString("@genMultiplier: generated new salary multiplier: " .. multiplier, 0, 255, 50, 255)
    triggerEvent("onSalaryMultiplierChange", resourceRoot, multiplier)

    return true
end

function setMultiplier(val, sync)
    multiplier = val

    if sync then 
        triggerClientEvent(getElementsByType("player"), "onMultiplierRequest", resourceRoot, multiplier)
    end

    outputDebugString("@setMultiplier: changed salary multiplier to " .. multiplier, 0, 255, 50, 255)
    triggerEvent("onSalaryMultiplierChange", resourceRoot, multiplier)

    return true
end

function getMultiplier()
    return multiplier
end

function onStart()
    genMultiplier()
end
addEventHandler("onResourceStart", resourceRoot, onStart)

function onMultiplierRequest()
    if isElement(client) then 
        triggerClientEvent(client, "onMultiplierRequest", client, multiplier)
    end
end
addEvent("onMultiplierRequest", true)
addEventHandler("onMultiplierRequest", root, onMultiplierRequest)

function setSalaryMultiplierCommand(thePlayer, cmd, val)
    if exports.cr_permission:hasPermission(thePlayer, cmd) or exports.cr_core:getPlayerDeveloper(thePlayer) then
        if not val then 
            local syntax = exports.cr_core:getServerSyntax(false, "lightyellow")
            outputChatBox(syntax .. "/" .. cmd .. " [érték]", thePlayer, 255, 0, 0, true)

            return
        end

        local val = tonumber(val)

        if not val then 
            local syntax = exports.cr_core:getServerSyntax(false, "error")
            outputChatBox(syntax .. "Csak szám.", thePlayer, 255, 0, 0, true)

            return
        end

        if val <= 0 then 
            local syntax = exports.cr_core:getServerSyntax(false, "error")
            outputChatBox(syntax .. "Az értéknek nagyobbnak kell lennie mint 0!", thePlayer, 255, 0, 0, true)

            return
        end

        setMultiplier(val, true)

        local syntax = exports.cr_core:getServerSyntax(false, "success")
        local hexColor = exports.cr_core:getServerColor("yellow", true)
        local white = "#ffffff"

        local adminSyntax = exports.cr_admin:getAdminSyntax()
        local adminName = exports.cr_admin:getAdminName(thePlayer, true)

        outputChatBox(syntax .. "Sikeresen megváltoztattad a fizetési szorzót! " .. hexColor .. "(" .. multiplier .. ")", thePlayer, 255, 0, 0, true)
        exports.cr_core:sendMessageToAdmin(thePlayer, adminSyntax .. hexColor .. adminName .. white .. " megváltoztatta a fizetési szorzót. " .. hexColor .. "(" .. multiplier .. ")", 6)
    end
end
addCommandHandler("setsalarymultiplier", setSalaryMultiplierCommand)

function getSalaryMultiplierCommand(thePlayer)
    if exports.cr_permission:hasPermission(thePlayer, cmd) or exports.cr_core:getPlayerDeveloper(thePlayer) then 
        local syntax = exports.cr_core:getServerSyntax(false, "info")
        local hexColor = exports.cr_core:getServerColor("yellow", true)

        outputChatBox(syntax .. "A jelenlegi fizetés szorzó: " .. hexColor .. multiplier, thePlayer, 255, 0, 0, true)
    end
end
addCommandHandler("getsalarymultiplier", getSalaryMultiplierCommand, false, false)