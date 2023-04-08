local rods = {}
local floats = {}

addEvent("fishing.createFishingRod", true)
addEventHandler("fishing.createFishingRod", root,
    function(thePlayer)
        if isElement(thePlayer) then 
            if not rods[thePlayer] then 
                rods[thePlayer] = Object(fishingRodObjectId, 0, 0, 0, 0, 0, 0)
                rods[thePlayer]:setCollisionsEnabled(false)
                exports["cr_bone_attach"]:attachElementToBone(rods[thePlayer], thePlayer, 12, 0.15, 0.05, 0.07, 0, 260, 0)

                thePlayer:setData("char >> fishing", true)
            else 
                if isElement(rods[thePlayer]) then 
                    exports["cr_bone_attach"]:detachElementFromBone(rods[thePlayer])

                    rods[thePlayer]:destroy()
                    rods[thePlayer] = nil 

                    if floats[thePlayer] and isElement(floats[thePlayer]) then 
                        floats[thePlayer]:destroy()
                        floats[thePlayer] = nil 

                        triggerLatentClientEvent(root, "fishing.sync", 50000, false, thePlayer, rods, floats)
                    end

                    collectgarbage("collect")

                    thePlayer:setData("char >> fishing", false)
                end
            end
        end
    end
)

addEvent("fishing.createFloat", true)
addEventHandler("fishing.createFloat", root,
    function(thePlayer, worldX, worldY, worldZ)
        if isElement(thePlayer) then 
            if rods[thePlayer] and isElement(rods[thePlayer]) then 
                if not floats[thePlayer] and worldX and worldY and worldZ then 
                    floats[thePlayer] = Object(floatObjectId, worldX, worldY, worldZ)
                    floats[thePlayer]:setCollisionsEnabled(false)
                else 
                    if isElement(floats[thePlayer]) then 
                        floats[thePlayer]:destroy()
                        floats[thePlayer] = nil 

                        collectgarbage("collect")
                    end
                end

                triggerLatentClientEvent(root, "fishing.sync", 50000, false, thePlayer, rods, floats)
            end
        end
    end
)

addEventHandler("onPlayerQuit", root,
    function()
        if rods[source] then 
            rods[source]:destroy()
            rods[source] = nil 
        end

        if floats[source] then 
            floats[source]:destroy()
            floats[source] = nil 

            triggerLatentClientEvent(root, "fishing.sync", 50000, false, source, rods, floats)
        end

        collectgarbage("collect")
    end
)