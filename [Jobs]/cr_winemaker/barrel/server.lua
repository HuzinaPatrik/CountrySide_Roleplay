local barrelCache = {}
local barrelTimers = {}

-- // 5LET: A kis szarba beletöltöd a vine-t (statusbar + Animálódva az érettet scálázza fel kliens oldalon Z-jét aztán szeróra syncelje fel.) - aztán kelljen rárakni azt a szart ami megdolgozza, ha megdolgozzta nyomsz rá 1 bal klikket és statusbarral lefedi) miután lefedte 1-2 percig érjen ha megért tudja felvenni és bevinni 1 cpbe ahol megkapja érte a pénzt majd 15 perc múlva respawnolódjon.

addEventHandler("onResourceStart", resourceRoot,
    function()
        for k,v in pairs(barrelPositions) do 
            local x,y,z,dim,int,rot = unpack(v)

            local obj = Object(6933, x, y, z)
            obj.dimension = dim 
            obj.interior = int 
            obj.rotation = Vector3(0, 0, rot)

            obj:setData("wineMaker >> barrel", k)

            barrelCache[obj] = true
        end 
    end 
)

addEvent("ownBarrel", true)
addEventHandler("ownBarrel", root, 
    function(sourcePlayer, obj)
        if barrelCache[obj] then 
            obj:setData('wineMaker >> barrel >> playerOwn', sourcePlayer)
            sourcePlayer:setData('wineMaker >> barrel >> playerOwn', obj)

            obj.model = 7344

            barrelTimers[obj] = setTimer(
                function(sourcePlayer, obj)
                    if isElement(sourcePlayer) then 
                        sourcePlayer:setData('wineMaker >> barrel >> playerOwn', nil)
                    end 

                    obj:setData('wineMaker >> barrel >> playerOwn', nil)

                    if obj:getData('wineMaker >> packedBarrel') then 
                        local id = obj:getData('wineMaker >> packedBarrel') or -1
        
                        obj:setData('wineMaker >> barrel', id)
                        obj:setData('wineMaker >> packedBarrel', nil)
                    end 

                    obj:setData('wineMaker >> doingBarrelInteraction', nil)

                    obj:setData('wineMaker >> ripe', nil)

                    obj.model = 6933

                    barrelTimers[obj] = nil 
                    collectgarbage('collect')
                end, 5 * 60 * 1000, 1, sourcePlayer, obj 
            )
        end 
    end 
)

addEvent("resetBarrel", true)
addEventHandler("resetBarrel", root, 
    function(sourcePlayer, obj)
        if barrelCache[obj] then 
            if isElement(sourcePlayer) then 
                sourcePlayer:setData('wineMaker >> barrel >> playerOwn', nil)
            end 
            obj:setData('wineMaker >> barrel >> playerOwn', nil)

            if obj:getData('wineMaker >> packedBarrel') then 
                local id = obj:getData('wineMaker >> packedBarrel') or -1

                obj:setData('wineMaker >> barrel', id)
                obj:setData('wineMaker >> packedBarrel', nil)
            end 

            obj:setData('wineMaker >> doingBarrelInteraction', nil)

            obj:setData('wineMaker >> ripe', nil)

            obj.model = 6933

            if isTimer(barrelTimers[obj]) then 
                killTimer(barrelTimers[obj])

                barrelTimers[obj] = nil 
                collectgarbage('collect')
            end 
        end 
    end 
)

addEvent("finishBarrel", true)
addEventHandler("finishBarrel", root, 
    function(sourcePlayer, obj)
        if barrelCache[obj] then 
            if isTimer(barrelTimers[obj]) then 
                killTimer(barrelTimers[obj])

                barrelTimers[obj] = nil 
            end 

            collectgarbage('collect')

            obj.model = 6929

            local id = obj:getData('wineMaker >> barrel') or -1
            obj:setData('wineMaker >> barrel', nil)
            obj:setData('wineMaker >> packedBarrel', id)
            obj:setData('wineMaker >> barrel >> playerOwn', sourcePlayer)
            sourcePlayer:setData('wineMaker >> barrel >> playerOwn', obj)

            barrelTimers[obj] = setTimer(
                function(sourcePlayer, obj)
                    if isElement(sourcePlayer) then 
                        sourcePlayer:setData('wineMaker >> barrel >> playerOwn', nil)
                    end 

                    obj:setData('wineMaker >> barrel >> playerOwn', nil)

                    if obj:getData('wineMaker >> packedBarrel') then 
                        local id = obj:getData('wineMaker >> packedBarrel') or -1
        
                        obj:setData('wineMaker >> barrel', id)
                        obj:setData('wineMaker >> packedBarrel', nil)
                    end 

                    obj:setData('wineMaker >> doingBarrelInteraction', nil)

                    obj:setData('wineMaker >> ripe', nil)

                    obj.model = 6933

                    barrelTimers[obj] = nil 
                    collectgarbage('collect')
                end, 10 * 60 * 1000, 1, sourcePlayer, obj 
            )
        end 
    end 
) 

addEvent('respawnBarrel', true)
addEventHandler('respawnBarrel', root, 
    function(sourcePlayer, obj)
        if barrelCache[obj] then 
            if isTimer(barrelTimers[obj]) then 
                killTimer(barrelTimers[obj])

                barrelTimers[obj] = nil 
            end 

            if isElement(sourcePlayer) then 
                sourcePlayer:setData('wineMaker >> barrel >> playerOwn', nil)
            end 

            obj:setData('wineMaker >> barrel >> playerOwn', nil)

            if obj:getData('wineMaker >> packedBarrel') then 
                local id = obj:getData('wineMaker >> packedBarrel') or -1

                obj:setData('wineMaker >> barrel', id)
                obj:setData('wineMaker >> packedBarrel', nil)
            end 

            obj:setData('wineMaker >> doingBarrelInteraction', nil)

            obj:setData('wineMaker >> ripe', nil)

            obj.model = 6933

            local x,y,z = getElementPosition(obj)
            obj.position = Vector3(x, y, z - 100)

            barrelTimers[obj] = setTimer(
                function(obj)
                    local x,y,z = getElementPosition(obj)
                    obj.position = Vector3(x, y, z + 100)
                end, 15 * 60 * 1000, 1, obj
            )
        end 
    end 
)