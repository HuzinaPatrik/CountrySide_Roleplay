function getPlayerPets(cache)
    if cache then 
        PetSelected = nil
        playerPetInfos = {}

        local data = {}
        for k,v in pairs(cache) do 
            table.insert(data, v)
        end 

        table.sort(data, function(a, b)
            if a[1] and b[1] then
                return tonumber(a[1]) < tonumber(b[1])
            end
        end);

        petCache = data
    end 
end 
addEvent("getPlayerPets", true)
addEventHandler("getPlayerPets", root, getPlayerPets)

addEventHandler("onClientResourceStart", resourceRoot, 
    function()
        if localPlayer:getData("loggedIn") then 
            triggerLatentServerEvent("getPlayerPets", 5000, false, localPlayer, localPlayer)
        end 
    end 
)

addEventHandler("onClientElementDataChange", localPlayer,
    function(dName, oValue, nValue)
        if dName == "loggedIn" then 
            if nValue then 
                triggerLatentServerEvent("getPlayerPets", 5000, false, localPlayer, localPlayer)
            end 
        end 
    end 
)

function inviteToTradePet(sourcePlayer, petName, id, price)
    if isElement(sourcePlayer) and tonumber(id) then 
        local blue = exports['cr_core']:getServerColor("yellow", true)
        local red = exports['cr_core']:getServerColor("red", true)
        local white = "#F2F2F2"
        local r,g,b = exports['cr_core']:getServerColor("green")
        local r2,g2,b2 = exports['cr_core']:getServerColor("red")
        
        createAlert(
            {
                ['headerText'] = 'Pet',
                ["title"] = {white .. blue .. exports['cr_admin']:getAdminName(sourcePlayer) .. white .." elszeretné neked adni a petjét ("..blue..petName..white..":"..blue..id..white..") ".. blue .. price .. white .. "$ ért!"},
                ["buttons"] = {
                    {
                        ["name"] = "Elfogadás", 
                        ["pressFunc"] = function()
                            if exports['cr_core']:takeMoney(localPlayer, price) then 
                                triggerLatentServerEvent("sellPet", 5000, false, localPlayer, sourcePlayer, localPlayer, petID)

                                exports['cr_infobox']:addBox("success", "Sikeresen megvetted a petet!")
                            else 
                                exports['cr_infobox']:addBox("error", "Nincs elég pénzed!")
                            end 
                        end,
                        ["onCreate"] = function()
                            sourcePlayer = sourcePlayer
                            petID = id
                        end,
                        ["color"] = {r,g,b},
                    },

                    {
                        ["name"] = "Elutasítás", 
                        ["onClear"] = true,
                        ["pressFunc"] = function()
                        end,
                        ["color"] = {r2, g2, b2},
                    },
                },
            }
        )
    end 
end
addEvent("inviteToTradePet", true)
addEventHandler("inviteToTradePet", root, inviteToTradePet)