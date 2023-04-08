--script by theMark

addEvent('setElementAnimation', true)
addEventHandler('setElementAnimation', root, function(player, element, block, anim)
    if player and element and isElement(player) and isElement(element) then
        element:setAnimation(tostring(block), tostring(anim), -1, false)
    end
end
)

addEvent('freezeOrUnfreezePlayer', true)
addEventHandler('freezeOrUnfreezePlayer', root, function(player, state)
    localPlayer.frozen = state or false
end
)