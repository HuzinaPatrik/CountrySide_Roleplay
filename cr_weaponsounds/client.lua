addEventHandler("onClientPlayerWeaponFire", root,
    function(weapon, ammo, ammoInClip)
        if weaponDatas[weapon] then 
            if weaponDatas[weapon]["path"] then 
                local path = weaponDatas[weapon]["path"]
                local maxDistance = weaponDatas[weapon]["maxDistance"]
                local soundElement = Sound3D(path, source.position)

                soundElement:setMinDistance(0)
                soundElement:setMaxDistance(maxDistance)
                soundElement:setInterior(source.interior)
                soundElement:setDimension(source.dimension)
            end
        end
    end
)