-- Colt- 45, Colt- 45 Silenced, Desert Eagle, Shotgun, Shawn-off Shotgun, Combat Shotgun, Uzi, Tec-9, MP5, AK-47, M4, Vadászpuska, Sniper Rifle, Sokkoló

weapons = {
    [1] = {
        ["name"] = "Glock",
        ["price"] = 500,
        ["id"] = 22, -- alap gtas fegyver id
        ["statId"] = 69,
        ["minPoints"] = 25,
    },
    [2] = {
        ["name"] = "Hangtompítós pisztoly",
        ["price"] = 500,
        ["id"] = 23, -- alap gtas fegyver id
        ["statId"] = 70,
        ["minPoints"] = 25,
    },
    [3] = {
        ["name"] = "Desert Eagle",
        ["price"] = 750,
        ["id"] = 24, -- alap gtas fegyver id
        ["statId"] = 71,
        ["minPoints"] = 30,
    },
    [4] = {
        ["name"] = "Shotgun",
        ["price"] = 1300,
        ["id"] = 25, -- alap gtas fegyver id
        ["statId"] = 72,
        ["minPoints"] = 50,
    },
    [5] = {
        ["name"] = "Sawed-off Shotgun",
        ["price"] = 1500,
        ["id"] = 26, -- alap gtas fegyver id
        ["statId"] = 73,
        ["minPoints"] = 50,
    },
    [6] = {
        ["name"] = "Combat Shotgun",
        ["price"] = 1750,
        ["id"] = 27, -- alap gtas fegyver id
        ["statId"] = 74,
        ["minPoints"] = 50,
    },
    [7] = {
        ["name"] = "Uzi",
        ["price"] = 1400,
        ["id"] = 28, -- alap gtas fegyver id
        ["statId"] = 75,
        ["minPoints"] = 65,
    },
    [8] = {
        ["name"] = "Tec-9",
        ["price"] = 800,
        ["id"] = 32, -- alap gtas fegyver id
        ["statId"] = 75,
        ["minPoints"] = 35,
    },
    [9] = {
        ["name"] = "MP5",
        ["price"] = 2000,
        ["id"] = 29, -- alap gtas fegyver id
        ["statId"] = 76,
        ["minPoints"] = 45,
    },
    [10] = {
        ["name"] = "AK-47",
        ["price"] = 2500,
        ["id"] = 30, -- alap gtas fegyver id
        ["statId"] = 77,
        ["minPoints"] = 100,
    },
    [11] = {
        ["name"] = "M4",
        ["price"] = 2250,
        ["id"] = 31, -- alap gtas fegyver id
        ["statId"] = 78,
        ["minPoints"] = 100,
    },
    [12] = {
        ["name"] = "Vadászpuska",
        ["price"] = 3500,
        ["id"] = 33, -- alap gtas fegyver id
        ["statId"] = 79,
        ["minPoints"] = 35,
    },
    [13] = {
        ["name"] = "Mesterlövész",
        ["price"] = 3500,
        ["id"] = 34, -- alap gtas fegyver id
        ["statId"] = 79,
        ["minPoints"] = 15,
    },
}

pedDatas = {
    {
        ["name"] = "Daniel Grenier",
        ["tag"] = "Lőtér",
        ["position"] = {316.10858154297, -134.16033935547, 999.6015625, 90},
        ["model"] = 22,
        ["interior"] = 7,
        ["dimension"] = 255,
        ["priceMultipler"] = 1,
        ["id"] = 2,
        ["location"] = "Blueberry",
        ["shootingPosition"] = {300.07867431641, -134.12905883789, 1004.0625, 92},
    },

    {
        ["name"] = "Robert Robinson",
        ["tag"] = "Lőtér",
        ["position"] = {293.54415893555, -83.504730224609, 1001.515625, 90},
        ["model"] = 22,
        ["interior"] = 4,
        ["dimension"] = 6,
        ["priceMultipler"] = 2,
        ["id"] = 1,
        ["location"] = "Palomino Creek",
        ["shootingPosition"] = {302.82806396484, -64.097991943359, 1001.515625, 268},
    },

    {
        ["name"] = "Maer Hassn",
        ["tag"] = "Lőtér",
        ["position"] = {308.14974975586, -143.09059143066, 999.6015625},
        ["model"] = 161,
        ["interior"] = 7,
        ["dimension"] = 255,
        ["decreasePed"] = true,
    },

    {
        ["name"] = "Seymour Trottle",
        ["tag"] = "Lőtér",
        ["position"] = {297.11608886719, -82.527557373047, 1001.515625},
        ["model"] = 161,
        ["interior"] = 4,
        ["dimension"] = 6,
        ["decreasePed"] = true,
    },
}

targets = {
    [1] = {
        [1] = {
            ["position"] = {314.90484619141, -66.965759277344, 1000.515625, 90},
            ["moving"] = true,
            ["moveLeftRight"] = true, -- ezt azokhoz amik csak jobbra / balra menjenek
            ["time"] = 500, -- ezredmásodpercben hogy mennyi időnként menjen jobbra / balra
            ["model"] = 1584,
            ["interior"] = 4,
        },
        [2] = {
            ["position"] = {314.90484619141, -64.965759277344, 1000.515625, 90},
            ["moving"] = true,
            ["moveForward"] = true, -- ezt meg azoknak amik közelednek a playerhez
            ["time"] = 10000, -- ezredmásodpercben hogy mennyi idő legyen mire a megadott helyre ér
            ["model"] = 1585,
            ["interior"] = 4,
        },
        [3] = {
            ["position"] = {314.90484619141, -62.965759277344, 1000.515625, 90},
            ["moving"] = true,
            ["model"] = 1586,
            ["interior"] = 4,
        },
    },
    [2] = {
        {
            ["position"] = {285.97756958008, -129.90744018555, 1003.0625, 271},
            ["moving"] = true,
            ["moveLeftRight"] = true, -- ezt azokhoz amik csak jobbra / balra menjenek
            ["time"] = 500, -- ezredmásodpercben hogy mennyi időnként menjen jobbra / balra
            ["model"] = 1584,
            ["interior"] = 7,
        },

        {
            ["position"] = {285.97756958008, -131.90744018555, 1003.0625, 271},
            ["moving"] = true,
            ["moveForward"] = true, -- ezt meg azoknak amik közelednek a playerhez
            ["time"] = 10000, -- ezredmásodpercben hogy mennyi idő legyen mire a megadott helyre ér
            ["model"] = 1585,
            ["interior"] = 7,
        },

        {
            ["position"] = {285.97756958008, -133.90744018555, 1003.0625, 271},
            ["moving"] = true,
            ["model"] = 1586,
            ["interior"] = 7,
        },
    },
    [3] = {
        [1] = {
            ["position"] = {293.62982177734, -12.915963172913, 1000.515625, 178},
            ["model"] = 1586,
            ["interior"] = 1,
        },
    },
}

pages = {"main", "decrease"}

minLines = 1
maxLines = 5

function convertNameToKey(name)
    local result = false 
    for key = 1, #weapons do 
        local value = weapons[key]
        if value then 
            if value["name"]:lower() == name:lower() then 
                result = key 
                break 
            end
        end
    end

    return result
end

function getWeaponStatIdByName(...)
    local result = false 
    if ... then 
        local name = table.concat({...}, " ")
        if name:len() > 0 then 
            local id = convertNameToKey(name)
            if id and id > 0 then 
                result = weapons[id]["statId"]
            end
        end
    end

    return result
end