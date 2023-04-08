addEvent("glue>vehicle>attach",true)
addEventHandler("glue>vehicle>attach",root,
    function(e,x, y, z, rotX, rotY, rotZ)
        local wep = getPedWeapon(source)
        local wep2 = getPedTotalAmmo(source)
        --outputChatBox(wep)
        --outputChatBox(wep2)
        attachElements(source, e, x, y, z, rotX, rotY, rotZ)
        takeAllWeapons(source)
        setTimer(giveWeapon, 50, 1, source, wep, wep2, true)
    end
)

addEvent("glue>vehicle>deattach",true)
addEventHandler("glue>vehicle>deattach",root,
    function()
        detachElements(source)
    end
)