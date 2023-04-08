function createLogoAnimation(type, pos)
    pos[3] = 130
    pos[4] = 150
    exports['cr_dx']:createLogoAnimation("login", type, pos, {20000, 2000})
end

function updateLogoPos(a)
    a[3] = 130
    a[4] = 150
    exports['cr_dx']:updateLogoPos("login", a)
end

function getLogoPosition()
    return exports['cr_dx']:getLogoPosition("login")
end

function stopLogoAnimation()
    exports['cr_dx']:stopLogoAnimation("login")
end