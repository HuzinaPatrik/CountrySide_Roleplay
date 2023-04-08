local value = {}
value["disabled"] = true

setTimer(
    function()
        if not value["disabled"] then
            local w, h = guiGetScreenSize ()
            local x, y, z = getWorldFromScreenPosition ( w/2, h/2, 10 )
            setPedLookAt(localPlayer, x,y,z)
        end
    end, 100, 0
)

function toggleHeadMove(val)
    value["disabled"] = val ~= 1
end

function initHeadMove(state)
    if state then
        local matrix = localPlayer.matrix
        local newPosition = matrix:transformPosition(Vector3(0,5,0))
        setPedLookAt(localPlayer, newPosition.x, newPosition.y, newPosition.z)
        oValue = value["disabled"]
        value["disabled"] = true
    else
        value["disabled"] = oValue
    end
end

function getHeadState()
    return value["disabled"]
end