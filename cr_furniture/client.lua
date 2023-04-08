addEventHandler("onClientResourceStart", resourceRoot, 
    function()
        for i = 0, 4 do
            setInteriorFurnitureEnabled(i, false)
        end
    end 
)

addEventHandler("onClientElementDataChange", root, 
    function(dName, oValue, nValue)
        if dName == "furniture >> movedBy" then 
            if nValue then 
                if oValue and isElement(oValue) and nValue == localPlayer then 
                    source:setData(dName, oValue)

                    if editingState then 
                        editingState = false 
                        exports['cr_elementeditor']:quitEditor(true)
                    end 

                    return 
                end 

                if nValue == localPlayer then 
                    if not editingState then 
                        editingState = true 

                        exports["cr_elementeditor"]:toggleEditor(source, "onSaveFurniturePositionEditor", "onSaveFurnitueDeleteEditor")
                    exports['cr_chat']:createMessage(localPlayer, "elkezd mozgatni egy bútort", 1)
                    end 
                end 
            end 
        end 
    end 
)

addEvent("onSaveFurniturePositionEditor", true)
addEventHandler("onSaveFurniturePositionEditor", localPlayer, 
    function(e, x, y, z, rx, ry, rz)
        if editingState then 
            e:setData("furniture >> movedBy", nil)
            
            editingState = false 

            triggerLatentServerEvent("updateFurniturePosition", 5000, false, localPlayer, localPlayer, e, x, y, z, rx, ry, rz)
        end 
    end 
)

addEvent("onSaveFurnitueDeleteEditor", true)
addEventHandler("onSaveFurnitueDeleteEditor", localPlayer, 
    function(e)
        if editingState then 
            e:setData("furniture >> movedBy", nil)

            editingState = false 
        end 
    end 
)