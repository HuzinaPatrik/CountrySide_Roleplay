addEvent("faction.customName", true)
addEventHandler("faction.customName", root,
    function(thePlayer, name)
        local name = name:gsub(" ", "_")
        local serverHex = exports["cr_core"]:getServerColor("blue", true)
        local id, data = exports["cr_account"]:getPlayerDatasByName(name)

        if id and data then 
            local syntax = exports["cr_core"]:getServerSyntax(false, "error")
            return outputChatBox(syntax.."Hibás név, már létezik ilyen karakter ezzel a névvel!", thePlayer, 255, 0, 0, true)
        else 
            local syntax = exports["cr_core"]:getServerSyntax(false, "success")
            local serverHex = exports["cr_core"]:getServerColor("yellow", true)

            outputChatBox(syntax.."Sikeresen megváltoztattad az álnevedet. "..serverHex.."("..name:gsub("_", " ")..")", thePlayer, 255, 0, 0, true)
            exports["cr_core"]:sendMessageToAdmin(thePlayer, exports["cr_admin"]:getAdminSyntax()..serverHex..exports["cr_admin"]:getAdminName(thePlayer).."#ffffff bekapcsolta az álnevet. "..serverHex.."("..name:gsub("_", " ")..")", 3)

            thePlayer:setData("char >> customName", tostring(name))
        end
    end
)