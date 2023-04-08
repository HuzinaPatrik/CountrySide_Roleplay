cache = {}
textures = {}

function checkArray(a)
    if not cache[a] then cache[a] = {} end
end

function replace(element, tex, src, tableUpdate, textureQuality)
    if not element or not isElement(element) then return end
    if not tex then return end
    if not src then return end
    --outputChatBox(src)
    --outputChatBox(tostring(fileExists(src)))
    if not fileExists(src) then return end
    --outputChatBox(tostring(element))
    checkArray(element)
    if cache[element][tex .. "-" .. src] then
        destroy(element, tex, src)
    end
    
    checkArray(element)
    
    --outputChatBox(tex)
    local texElement = textures[src]
    if not texElement then
        texElement = dxCreateTexture(src, textureQuality or "dxt1")
        textures[src] = texElement
    end
    local shadElement = dxCreateShader("replace.fx", 0, 100, false, "all")
    engineApplyShaderToWorldTexture(shadElement, tex, element)
    dxSetShaderValue(shadElement, "gTexture", texElement)
    
    cache[element][tex .. "-" .. src] = {texElement, shadElement}
    
    --outputChatBox(tostring(tableUpdate))
    if tableUpdate then
        local a = getElementData(element, "syncTable") or {}
        ----outputChatBox(inspect(a))
        a[tex .. "-" .. src] = {tex, src}
        --outputChatBox(inspect(a))
        setElementData(element, "syncTable", a)
    end
    
    return true, "created"
end

function getLength(a)
    local b = 0
    for k,v in pairs(a) do
        b = b + 1
    end
    return b
end

function destroy(element, tex, src, tableUpdate)
    if not element or not isElement(element) then return end
    if not tex then return end
    if not src then return end
    if cache[element] and cache[element][tex .. "-" .. src] then
        local texture, shader = unpack(cache[element][tex .. "-" .. src])
        --destroyElement(texture)
        destroyElement(shader)
        cache[element][tex .. "-" .. src] = nil
        
        local aN = getLength(cache[element])
        if aN == 0 then
            cache[element] = nil
        end
        
        if tableUpdate then
            local a = getElementData(element, "syncTable") or {}
            a[tex .. "-" .. src] = nil
            setElementData(element, "syncTable", a)
        end
        
        collectgarbage("collect")
        return true, "destroyed"
    end
end

function onStream()
    --outputChatBox("StreamIn: "..source.type)
    if getElementData(source, "syncTable") then
        local a = getElementData(source, "syncTable") or {}
        --outputChatBox("SyncTable: "..tostring(a))
        for k,v in pairs(a) do
            local tex, src = unpack(v)
            --outputChatBox("Tex: "..tex.." - Src: "..src)
            replace(source, tex, src)
        end
    end
end
addEventHandler("onClientElementStreamIn", root, onStream)

function onStreamOut()
    --outputChatBox("StreamOut: "..source.type)
    if getElementData(source, "syncTable") then
        local a = getElementData(source, "syncTable") or {}
        --outputChatBox("SyncTable: "..tostring(a))
        for k,v in pairs(a) do
            local tex, src = unpack(v)
            destroy(source, tex, src)
        end
    end
end
addEventHandler("onClientElementStreamOut", root, onStreamOut)

local isEnabled = {
    ["player"] = true,
    ["object"] = true,
    ["vehicle"] = true,
    ["ped"] = true,
    ["pickup"] = true
}
function onChange(dName, oValue)
    if isEnabled[getElementType(source)] then
        ----outputChatBox(source.type)
        ----outputChatBox(tostring(isElementStreamedIn(source)))
        if isElementStreamedIn(source) then
            ----outputChatBox("dName:"..dName)
            if dName == "syncTable" then
                local a = getElementData(source, "syncTable") or {}
                --outputChatBox("SyncTable:"..inspect(a))
                local a2 = {}
                local oValue = oValue or {}
                for k,v in pairs(a) do
                    local tex, src = unpack(v)
                    --outputChatBox("Cache[source]"..tostring(cache[source]))
                    --outputChatBox("Cache[source][tex-src]"..tostring(cache[source] and cache[source][tex .. "-" .. src]))
                    if not cache[source] or not cache[source][tex .. "-" .. src] then
                        replace(source, tex, src)
                    end
                    a2[k] = v
                end

                for k,v in pairs(oValue) do
                    if not a2[k] then
                        local tex, src = unpack(v)
                        destroy(source, tex, src)
                    end
                end
            end
        end
    end
end
addEventHandler("onClientElementDataChange", root, onChange)

function onDestroy()
    if getElementData(source, "syncTable") then
        if isElementStreamedIn(source) then
            local a = getElementData(source, "syncTable") or {}
            for k,v in pairs(a) do
                local tex, src = unpack(v)
                destroy(source, tex, src)
            end
        end
    end
end
addEventHandler("onClientElementDestroy", root, onDestroy)

function onStart()
    for k,v2 in pairs(getElementsByType("player", _, true)) do
        local a = getElementData(v2, "syncTable") or {}
        for k,v in pairs(a) do
            local tex, src = unpack(v)
            replace(v2, tex, src)
        end
    end
    
    for k,v2 in pairs(getElementsByType("object", _, true)) do
        local a = getElementData(v2, "syncTable") or {}
        for k,v in pairs(a) do
            local tex, src = unpack(v)
            replace(v2, tex, src)
        end
    end
    
    for k,v2 in pairs(getElementsByType("ped", _, true)) do
        local a = getElementData(v2, "syncTable") or {}
        for k,v in pairs(a) do
            local tex, src = unpack(v)
            replace(v2, tex, src)
        end
    end
end
addEventHandler("onClientResourceStart", resourceRoot, onStart)