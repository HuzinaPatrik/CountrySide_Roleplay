addEventHandler("onResourceStart", resourceRoot,
    function()
        local jobPed = Ped(21, 2266.1872558594, -72.535736083984, 26.78125, 180)
        jobPed:setData("ped.name", "Tobias Ingram")
        jobPed:setData("ped.type", "Munkáltató")
        jobPed:setData("job >> ped", true)
        jobPed:setData("char >> noDamage", true)
        jobPed:setFrozen(true)
    end
)