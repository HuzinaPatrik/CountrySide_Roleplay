local cuffData = {}
local handCuffObjectId = 3330

function onClientStart()
    local txd = engineLoadTXD("cuff/files/cuff.txd")

    engineImportTXD(txd, handCuffObjectId)

    local dff = engineLoadDFF("cuff/files/cuff.dff")
    engineReplaceModel(dff, handCuffObjectId)

    engineLoadIFP("cuff/files/cuff.ifp", "cuff_custom")
end
addEventHandler("onClientResourceStart", resourceRoot, onClientStart)

function renderCuff()
    for k, v in pairs(cuffData) do 
        if isElement(k) then 
            local leftHandCuff = v.leftHandCuff
            local rightHandCuff = v.rightHandCuff
            local following = v.following
            local currentAnim = v.currentAnim
            local availableElement = false

            if isElementStreamedIn(k) and isElementOnScreen(k) and isElement(leftHandCuff) and isElement(rightHandCuff) then 
                local leftHandCuffX, leftHandCuffY, leftHandCuffZ = getElementPosition(leftHandCuff)
                local rightHandCuffX, rightHandCuffY, rightHandCuffZ = getElementPosition(rightHandCuff)

                dxDrawLine3D(leftHandCuffX, leftHandCuffY, leftHandCuffZ, rightHandCuffX, rightHandCuffY, rightHandCuffZ, tocolor(50, 50, 50), 1)

                if isElement(following) then 
                    local boneX, boneY, boneZ = getPedBonePosition(following, 25)

                    dxDrawLine3D(leftHandCuffX, leftHandCuffY, leftHandCuffZ, boneX, boneY, boneZ, tocolor(20, 20, 20), 1)
                    availableElement = true
                end
            end

            if availableElement then 
                if not isPedInVehicle(following) then 
                    local playerX, playerY, playerZ = getElementPosition(k)
                    local followingX, followingY, followingZ = getElementPosition(following)

                    local deltaX = followingX - playerX
                    local deltaY = followingY - playerY
                    local distance = deltaX * deltaX + deltaY * deltaY

                    if distance >= 2 then 
                        local rotX, rotY, rotZ = getElementRotation(k)
                        local newRot = -math.deg(math.atan2(deltaX, deltaY))

                        setElementRotation(k, rotX, rotY, newRot, "default", true)

                        if currentAnim ~= "walking" then 
                            cuffData[k].currentAnim = "walking"
                            k:setData("currentAnimation", "walking")
                        end
                    else
                        if currentAnim ~= "standing_front" then
                            cuffData[k].currentAnim = "standing_front"
                            k:setData("currentAnimation", "standing_front")
                        end
                    end
                end
            end
        end
    end
end
createRender("renderCuff", renderCuff)

function handleDataChange(dataName, oldValue, newValue)
    if source.type == "player" then 
        if dataName == "char >> cuffed" then 
            if newValue then 
                if cuffData[source] then 
                    if isElement(cuffData[source].leftHandCuff) then 
                        cuffData[source].leftHandCuff:destroy()
                        cuffData[source].leftHandCuff = nil
                    end
    
                    if isElement(cuffData[source].rightHandCuff) then 
                        cuffData[source].rightHandCuff:destroy()
                        cuffData[source].rightHandCuff = nil
                    end

                    if isElement(cuffData[source].soundElement) then 
                        cuffData[source].soundElement:destroy()
                        cuffData[source].soundElement = nil
                    end
                else
                    cuffData[source] = {leftHandCuff = false, rightHandCuff = false, soundElement = false, following = false, currentAnim = false}
                end

                if isElement(newValue.cuffedBy) then 
                    local leftHandCuff = Object(handCuffObjectId, 0, 0, 0)

                    cuffData[source].leftHandCuff = leftHandCuff
                    exports.cr_bone_attach:attachElementToBone(cuffData[source].leftHandCuff, source, 11, 0, 0, 0, 90, -45, 0)
            
                    local rightHandCuff = Object(handCuffObjectId, 0, 0, 0)
            
                    cuffData[source].rightHandCuff = rightHandCuff
                    exports.cr_bone_attach:attachElementToBone(cuffData[source].rightHandCuff, source, 12, 0, 0, 0, 90, -45, 0)

                    setPedAnimation(source, "cuff_custom", "standing_b", -1, true, false)

                    cuffData[source].soundElement = playSound3D("cuff/files/sounds/handcuff.ogg", source.position)
                    cuffData[source].soundElement.interior = source.interior
                    cuffData[source].soundElement.dimension = source.dimension

                    setSoundMaxDistance(cuffData[source].soundElement, 5)

                    setTimer(
                        function(thePlayer)
                            if cuffData[thePlayer] then 
                                cuffData[thePlayer].soundElement = nil
                            end
                        end, 1200, 1, source
                    )
                end
            else
                if cuffData[source] then 
                    if isElement(cuffData[source].leftHandCuff) then 
                        exports.cr_bone_attach:detachElementFromBone(cuffData[source].leftHandCuff)

                        cuffData[source].leftHandCuff:destroy()
                        cuffData[source].leftHandCuff = nil
                    end
    
                    if isElement(cuffData[source].rightHandCuff) then 
                        exports.cr_bone_attach:detachElementFromBone(cuffData[source].rightHandCuff)

                        cuffData[source].rightHandCuff:destroy()
                        cuffData[source].rightHandCuff = nil
                    end

                    if isElement(cuffData[source].soundElement) then 
                        cuffData[source].soundElement:destroy()
                        cuffData[source].soundElement = nil
                    end

                    cuffData[source] = nil
                    setPedAnimation(source, false)
                end
            end
        elseif dataName == "char >> follow" then
            if isElement(newValue) then 
                if cuffData[source] then 
                    cuffData[source].following = newValue
                end
            else
                if cuffData[source] then 
                    cuffData[source].following = nil

                    setPedAnimation(source, "cuff_custom", "standing_b", -1, true, false)
                end
            end
        elseif dataName == "currentAnimation" then
            if newValue then 
                if newValue == "walking" then 
                    setPedAnimation(source, "cuff_custom", "walking", -1, true, true)
                elseif newValue == "standing_front" then
                    setPedAnimation(source, "cuff_custom", "standing_f", -1, true, false)
                elseif newValue == "standing_back" then
                    setPedAnimation(source, "cuff_custom", "standing_b", -1, true, false)
                end
            else
                setPedAnimation(source, false)
            end
        end
    end
end
addEventHandler("onClientElementDataChange", root, handleDataChange)

function onClientQuit()
    if cuffData[source] then 
        if isElement(cuffData[source].leftHandCuff) then 
            exports.cr_bone_attach:detachElementFromBone(cuffData[source].leftHandCuff)

            cuffData[source].leftHandCuff:destroy()
            cuffData[source].leftHandCuff = nil
        end

        if isElement(cuffData[source].rightHandCuff) then 
            exports.cr_bone_attach:detachElementFromBone(cuffData[source].rightHandCuff)

            cuffData[source].rightHandCuff:destroy()
            cuffData[source].rightHandCuff = nil
        end

        if isElement(cuffData[source].soundElement) then 
            cuffData[source].soundElement:destroy()
            cuffData[source].soundElement = nil
        end

        cuffData[source] = nil
    end
end
addEventHandler("onClientPlayerQuit", root, onClientQuit)