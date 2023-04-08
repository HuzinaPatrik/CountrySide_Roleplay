function createAnimals()
    for k,v in pairs(animals) do 
        local x,y,z,dim,int,rot,name,maxDist,damageDist,type = unpack(v)
        local modelid = animalTypes[type][1]
        local typeName = animalTypes[type][2]
        local health = animalTypes[type][3]
        local respawnTime = animalTypes[type][4]
        local ped = Ped(0, x,y,z)
        ped.dimension = dim
        ped.interior = int 
        ped.rotation = Vector3(0,0,rot)
        ped:setData("hunter >> spawnPoint", {x,y,z})
        ped:setData("ped.name", name)
        ped:setData("ped.type", typeName)		
        ped:setData("ped >> skin", modelid)		
        ped:setData("hunter >> id", k)	
        ped:setData("hunter >> maxDist", maxDist)
        ped:setData("hunter >> damageDist", damageDist)
        ped:setData("hunter >> type", type)
        ped:setData("hunter >> health", health)
        ped:setData("hunter >> maxHealth", health)
        ped:setData("hunter >> respawnTime", respawnTime)
    end 
end 
addEventHandler("onResourceStart", resourceRoot, createAnimals)

local timers = {}
addEvent("StartAnimalRespawn", true)
addEventHandler("StartAnimalRespawn", root, 
    function(animal)
        local x, y, z = unpack(animals[animal:getData("hunter >> id")])
        animal.position = Vector3(x, y, -50)
        animal.frozen = true

        local respawnTime = animalTypes[animal:getData("hunter >> type")][4]

        if isTimer(timers[animal]) then killTimer(timers[animal]) end 
        timers[animal] = setTimer(
            function()
                local x, y, z = unpack(animals[animal:getData("hunter >> id")])
                animal.position = Vector3(x, y, z)
                animal.frozen = false 
                animal:setData("hunter >> health", animal:getData("hunter >> maxHealth"))
                animal:setData("hunter >> doingInteraction", nil)
                animal:setData("hunter >> attacker", nil)
            end, respawnTime, 1
        )
    end 
)