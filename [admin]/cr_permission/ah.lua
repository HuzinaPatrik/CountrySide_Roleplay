function getAdminCommands(minLevel, only)
    if not tonumber(minLevel) then 
        minLevel = 0
    end 

    if not tonumber(only) then 
        only = 0
    end 

    only = only == 1

    local adminCommands = {}

    local blue = exports['cr_core']:getServerColor("yellow", true)
    local white = "#f2f2f2"

    for k,v in pairs(permissionDetails) do 
        if v[1]:lower() == ("cmd"):lower() then 
            if v[2] >= minLevel and not only or v[2] == minLevel and only then 
                local data = {white .. "/" .. blue .. k .. white, white .. "Minimális szint: " .. blue .. v[2] .. white, v[2]}
                table.insert(adminCommands, 1, data)
            end 
        end 
    end 

    table.sort(adminCommands, 
        function(a, b) 
            if a[1] and b[1] then 
                return a[1] < b[1]
            end 
        end 
    ) 

    return adminCommands
end 

function adminHelpCMD(cmd, level, only)
    if hasPermission(localPlayer, "ah") then
        local playerLevel = exports['cr_admin']:getAdminLevel(localPlayer)

        if not tonumber(level) then 
            level = playerLevel
        end 

        if not tonumber(only) then 
            only = 1
        end 

        level = tonumber(level)

        if playerLevel == 2 then 
            playerLevel = 1
        end

        if level > playerLevel then 
            level = playerLevel
        end 

        only = tonumber(only)

        local adminCommands = getAdminCommands(level, only)

        local blue = exports['cr_core']:getServerColor("yellow", true)
        local white = "#f2f2f2"

        local text = "Szint"
        if only == 0 then 
            text = "Minimális szint"
        end 

        local data = {
            ["hoverText"] = white .. 'Admin Help',
            ["altText"] = white .. "Elérhető admin parancsok: (" .. text .. ": "..blue..level..white..")",
            ["minLines"] = 1,
            ["maxLines"] = 10,
            ["type"] = "default",
        }

        data["texts"] = adminCommands
        exports['cr_dx']:openInformationsPanel(data)
    end 
end 
addCommandHandler("ah", adminHelpCMD)
addCommandHandler("adminhelp", adminHelpCMD)