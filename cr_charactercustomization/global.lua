_minLines = 1
_maxLines = 11

minLines = _minLines
maxLines = _maxLines

_clothesMinLines = 1
_clothesMaxLines = 6

clothesMinLines = _clothesMinLines
clothesMaxLines = _clothesMaxLines

clothesPedSkinId = 16
clothesPedPoint = Vector3(710.92523193359, -107.59420013428, 21.534379959106)
white = "#ffffff"
slotPrice = 1000

clothes = {
    {"Kalapok/Sapkák", false,
        {

        },
    },-- 1

	{"Kabátok", false,
        {
            
        },
    },-- 2

    {"Táskák", false,
        {
            
        },
    },-- 3

    {"Nyakláncok", false,
        {
            
        },
    },-- 4

    {"Szemüvegek", false,
        {
            
        },
    },-- 5
	
	{"Egyéb", false,
        {
            
        },
    },-- 6
}

factionClothes = {}

boneIdsToBonePosition = {
    -- [bone attach id] = getPedBonePosition id
    [1] = 8,
    [2] = 5,
    [3] = 3,
    [4] = 2,
    [5] = 34,
    [6] = 24,
    [7] = 32,
    [8] = 22,
    [9] = 33,
    [10] = 23,
    [11] = 35,
    [12] = 25,
    [13] = 41,
    [14] = 51,
    [15] = 42,
    [16] = 52,
    [17] = 43,
    [18] = 53,
    [19] = 44,
    [20] = 54,
}

function addAttachmentToShop(category, data)
    if category and data then 
        if type(category) == "number" and type(data) == "table" then 
            local category = tonumber(category)

            if clothes[category] and clothes[category][3] then 
                table.insert(clothes[category][3], data)

                return true
            end
        end
    end

    return false
end

function removeAttachmentFromShop(category, name)
    local result = false

    if category and name then 
        local data = clothes[category]

        if data then 
            local items = data[3]

            if items then 
                for i = 1, #items do 
                    local v = items[i]

                    if v then 
                        local gName = v["name"]

                        if gName:lower() == name:lower() then 
                            result = i

                            table.remove(clothes[category][3], result)
                            break 
                        end
                    end
                end
            end
        end
    end

    return result
end

function isPlayerEligible(thePlayer, tbl)
    local result = false

    for i = 1, #tbl do 
        local v = tbl[i]

        if exports.cr_dashboard:isPlayerInFaction(thePlayer, v) then 
            result = i
            break
        end
    end

    return result
end

-- Kalapok/Sapkák
addAttachmentToShop(1, {
    ["name"] = "Cowboy hat",
    ["price"] = 250,
    ["onlypp"] = false,
    ["ppPrice"] = 50,
    ["bone"] = 1,
    ["defaultRotation"] = {x = 0, y = 0, z = 90},
    ["objectId"] = 3090,
})

addAttachmentToShop(1, {
    ["name"] = "Szalma kalap",
    ["price"] = 300,
    ["onlypp"] = false,
    ["ppPrice"] = 55,
    ["bone"] = 1,
    ["defaultRotation"] = {x = 0, y = 0, z = 0},
    ["objectId"] = 1589,
})

addAttachmentToShop(1, {
    ["name"] = "Bikers Helmet",
    ["price"] = 1500,
    ["onlypp"] = false,
    ["ppPrice"] = 10,
    ["bone"] = 1,
    ["defaultRotation"] = {x = 0, y = 0, z = 0},
    ["objectId"] = 3803,
	["invisible"] = true,
    ["availableForFactions"] = {6},
})

addAttachmentToShop(1, {
    ["name"] = "Motocross Helmet",
    ["price"] = 1500,
    ["onlypp"] = false,
    ["ppPrice"] = 100,
    ["bone"] = 1,
    ["defaultRotation"] = {x = 0, y = 0, z = 0},
    ["objectId"] = 3082,
})
-- Kalapok/Sapkák --

-- Kabátok
addAttachmentToShop(2, {
    ["name"] = "Láthatósági mellény",
    ["price"] = 750,
    ["onlypp"] = false,
    ["ppPrice"] = 25,
    ["bone"] = 3,
    ["defaultRotation"] = {x = 0, y = 0, z = 0},
    ["objectId"] = 1254,
})
-- Kabátok --

-- Táskák
addAttachmentToShop(3, {
    ["name"] = "Táska 1",
    ["price"] = 1100,
    ["onlypp"] = false,
    ["ppPrice"] = 90,
    ["bone"] = 3,
    ["defaultRotation"] = {x = 0, y = 0, z = 90},
    ["objectId"] = 3808,
})

addAttachmentToShop(3, {
    ["name"] = "Málhazsák",
    ["price"] = 1100,
    ["onlypp"] = false,
    ["ppPrice"] = 90,
    ["bone"] = 3,
    ["defaultRotation"] = {x = 0, y = 0, z = 0},
    ["objectId"] = 3060,
})
-- Táskák --

-- Nyakláncok
addAttachmentToShop(4, {
    ["name"] = "Csokor Nyakkendő",
    ["price"] = 400,
    ["onlypp"] = false,
    ["ppPrice"] = 100,
    ["bone"] = 3,
    ["defaultRotation"] = {x = 0, y = 0, z = 90},
    ["objectId"] = 3112,
})
-- Nyakláncok --

-- Szemüvegek
addAttachmentToShop(5, {
    ["name"] = "Szemüveg 1",
    ["price"] = 1600,
    ["onlypp"] = false,
    ["ppPrice"] = 160,
    ["bone"] = 1,
    ["defaultRotation"] = {x = 0, y = 0, z = 90},
    ["objectId"] = 16644,
})
-- Szemüvegek --

-- Egyéb

addAttachmentToShop(6, {
    ["name"] = "Papagáj",
    ["price"] = 5000,
    ["onlypp"] = false,
    ["ppPrice"] = 250,
    ["bone"] = 3, 
    ["defaultRotation"] = {x = 0, y = 0, z = 0},
    ["objectId"] = 7510,
})

addAttachmentToShop(6, {
    ["name"] = "Sheriff Armor",
    ["price"] = 9999,
    ["onlypp"] = true,
    ["ppPrice"] = 9999,
    ["bone"] = 3,
    ["defaultRotation"] = {x = 0, y = 0, z = 0},
    ["objectId"] = 1242,
    ["invisible"] = true,
    ["availableForFactions"] = {1},
})

addAttachmentToShop(6, {
    ["name"] = "Sheriff (SEB) Armor",
    ["price"] = 9999,
    ["onlypp"] = true,
    ["ppPrice"] = 9999,
    ["bone"] = 3,
    ["defaultRotation"] = {x = 0, y = 0, z = 0},
    ["objectId"] = 962,
    ["invisible"] = true,
    ["availableForFactions"] = {1},
})

addAttachmentToShop(6, {
    ["name"] = "Szakáll",
    ["price"] = 9999,
    ["onlypp"] = false,
    ["ppPrice"] = 9999,
    ["bone"] = 1,
    ["defaultRotation"] = {x = 0, y = 0, z = 90},
    ["objectId"] = 3387,
	["invisible"] = true,
    ["availableForFactions"] = {9},
})

addAttachmentToShop(6, {
    ["name"] = "Stethoscope",
    ["price"] = 9999,
    ["onlypp"] = false,
    ["ppPrice"] = 9999,
    ["bone"] = 3,
    ["defaultRotation"] = {x = 0, y = 0, z = 90},
    ["objectId"] = 7617,
	["invisible"] = true,
    ["availableForFactions"] = {2},
})

--[[
addAttachmentToShop(6, {
    ["name"] = "Sheriff (SEB) Helmet",
    ["price"] = 0,
    ["onlypp"] = true,
    ["ppPrice"] = 9999,
    ["bone"] = 1,
    ["defaultRotation"] = {x = 0, y = 0, z = 0},
    ["objectId"] = 1248,
    ["invisible"] = true,
    ["availableForFactions"] = {1},
})

addAttachmentToShop(6, {
    ["name"] = "Sheriff Holster(Leg)",
    ["price"] = 0,
    ["onlypp"] = true,
    ["ppPrice"] = 9999,
    ["bone"] = 14,
    ["defaultRotation"] = {x = 0, y = 0, z = 0},
    ["objectId"] = 1246,
    ["invisible"] = true,
    ["availableForFactions"] = {1},
})]]
-- Egyéb --

for k, v in pairs(clothes) do 
    local category, listed, items = unpack(v)

    for k2, v2 in pairs(items) do 
        if v2.availableForFactions then 
            v2.category = k

            table.insert(factionClothes, v2)
        end
    end
end

clothesPedData = {
    {
        position = Vector3(201.93241882324, -100.36290740967, 1005.2578125),
        rotation = Vector3(0, 0, 273.8088684082),
        interior = 15,
        dimension = 13,
        skinId = 259,
        name = "Fred Porter",
        typ = "Ruházat"
    },
	
	{
        position = Vector3(201.93241882324, -100.36290740967, 1005.2578125),
        rotation = Vector3(0, 0, 273.8088684082),
        interior = 15,
        dimension = 14,
        skinId = 259,
        name = "Fred Porter",
        typ = "Ruházat"
    },
	
	{
        position = Vector3(201.93241882324, -100.36290740967, 1005.2578125),
        rotation = Vector3(0, 0, 273.8088684082),
        interior = 15,
        dimension = 4,
        skinId = 259,
        name = "Fred Porter",
        typ = "Ruházat"
    },
}