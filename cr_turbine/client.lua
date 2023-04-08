local cache = {}
createCache = {
    --{x,y,z, rot},
    {1392.2639160156, -743.79644775391, 97.030960083008, 220},
    {1013.2525634766, -725.03344726563, 118.31688690186, 120},
    {573.86468505859, -977.07287597656, 86.062583923340, 190},
    {526.37658691406, -840.15032958984, 91.155136108398, 126},
    {1259.6092529297, -664.54779052734, 103.67860412598, 171},
    {1996.5046386719, -827.65130615234, 127.84468078613, 221},
    {1126.2683105469, -242.52851867676, 70.0830078125, 325},
    {809.69689941406, 131.46459960938, 60.827835083008, 0},
    {1041.60546875, 218.69618225098, 36.209323883057, 325},
    {2628.4299316406, -67.108489990234, 51.908760070801, 37},
    {-353.51736450195, -219.47518920898, 57.946598052979, 57},
    {546.66918945312, 727.20257568359, 9.0328636169434, 242},
}

addEventHandler("onClientResourceStart", resourceRoot,
    function()
        for k,v in pairs(createCache) do
            local x,y,z,rot = unpack(v)
            z = z + 32
            local obj = Object(3279, x,y,z, 0, 0, rot)
            local objLod = Object(3279, x,y,z, 0, 0, rot, true)
            setLowLODElement(obj, objLod)
            engineSetModelLODDistance(3279, 1000)
            
            local desiredRelativePosition = Vector3(0, 5.5, 31.5) -- 5 meters front of player is a y = 5 vector
            local matrix = obj.matrix
            local newPosition = matrix:transformPosition(desiredRelativePosition)
            local obj2 = Object(3271, newPosition, 0, 0, rot)
            local obj2Lod = Object(3271, newPosition, 0, 0, rot, true)
            setLowLODElement(obj2, obj2Lod)
            engineSetModelLODDistance(3271, 1000)
            cache[k] = {obj, objLod, obj2, obj2Lod}
            
            startRotate(k)
        end
    end
)

local rotateTime = 15 * 1000 -- 45 sec

function startRotate(id)
    local obj, objLod, obj2, obj2Lod = unpack(cache[id])
    if isElement(obj2) then
        rotateOne(obj2, obj2Lod)
    end
end

function rotateOne(obj, obj2Lod)
    local velocity = getWindVelocity()
    if velocity >= 0.01 then
        local time = rotateTime - (rotateTime * (velocity / 10))
        local position = obj.position
        moveObject(obj, time, position,0,90,0)
        moveObject(obj2Lod, time, position,0,90,0)
        setTimer(rotateOne, time, 1, obj, obj2Lod)
    else
        setTimer(rotateOne, rotateTime, 1, obj, obj2Lod)
    end
end