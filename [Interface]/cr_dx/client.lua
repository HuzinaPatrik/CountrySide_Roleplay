function formatMoney(n) 
    local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$') 
    return left..(num:reverse():gsub('(%d%d%d)','%1.'):reverse())..right 
end 

local textures = {}
local texturesLastUsedTick = {}

function dxDrawImageAsTexture(x, y, w, h, imgPath, rot, rotCenterX, rotCenterY, color, postGui, imgDetails)
    if not textures[imgPath] then
        if not imgDetails then 
            imgDetails = {'argb', true, 'clamp'}
        end 

        textures[imgPath] = dxCreateTexture(imgPath, unpack(imgDetails))
    end

    local img = textures[imgPath]

    if img then 
        texturesLastUsedTick[imgPath] = {img, getTickCount()}

        dxDrawImage(x, y, w, h, img, rot, rotCenterX, rotCenterY, color, postGui)
    end
end 

function getTexture(imgPath, imgDetails)
    if not textures[imgPath] then
        if not imgDetails then 
            imgDetails = {'argb', true, 'clamp'}
        end 

        textures[imgPath] = dxCreateTexture(imgPath, unpack(imgDetails))
    end

    local img = textures[imgPath]

    if img then 
        texturesLastUsedTick[imgPath] = {img, getTickCount()}

        return img
    end

    return false
end 

setTimer(
    function()
        for k,v in pairs(texturesLastUsedTick) do
            if v[2] + 500 <= getTickCount() then
                v[1]:destroy()

                texturesLastUsedTick[k] = nil
                textures[k] = nil

                collectgarbage("collect")
            end
        end
    end, 500, 0
)