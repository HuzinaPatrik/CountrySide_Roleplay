addEventHandler("onClientResourceStart", resourceRoot, function()
    local texture = dxCreateTexture("assets/images/plate.png", "dxt5");
    local shader = dxCreateShader("assets/textures/texture.fx");
    dxSetShaderValue(shader, "gTexture", texture);
        
    engineApplyShaderToWorldTexture(shader, "plateback3");
    engineApplyShaderToWorldTexture(shader, "plateback2");
    engineApplyShaderToWorldTexture(shader, "plateback1");
end);

local maxDistance = 26;

local value = {};

addEventHandler("onClientResourceStart", resourceRoot, function()
    value = exports['cr_json']:jsonGET("save.json", true, {["disabled"] = false}) or {};
        
    if not value["disabled"] then
        --addEventHandler("onClientRender", root, renderVehiclePlate, true, "low-5");
        createRender("renderVehiclePlate", renderVehiclePlate)
    end
end);

addEventHandler("onClientResourceStop", resourceRoot, function()
    exports['cr_json']:jsonSAVE("save.json", value, true);
end);

function togglePlate()
    if not localPlayer:getData("loggedIn") then return end
    value["disabled"] = not value["disabled"];
    if value["disabled"] then
        exports['cr_infobox']:addBox("error", "Sikeresen kikapcsoltad a rendszámok megjelenitését!");
        --removeEventHandler("onClientRender", root, renderVehiclePlate);
        destroyRender("renderVehiclePlate")
    else
        exports['cr_infobox']:addBox("success", "Sikeresen bekapcsoltad a rendszámok megjelenitését!");
        --addEventHandler("onClientRender", root, renderVehiclePlate, true, "low-5");
        createRender("renderVehiclePlate", renderVehiclePlate)
    end
end
bindKey("F10", "down", togglePlate);

function dxDrawRectangleBox(left, top, width, height)
    dxDrawRectangle(left, top, width, height, tocolor(44,44,44,160));
    dxDrawRectangle(left-1, top, 1, height, tocolor(33,33,33,220));
    dxDrawRectangle(left+width, top, 1, height, tocolor(33,33,33,220));
    dxDrawRectangle(left, top-1, width, 1, tocolor(33,33,33,220));
    dxDrawRectangle(left, top+height, width, 1, tocolor(33,33,33,220));
end

local renderCache = {}

setTimer(
    function()
        if (value and not value["disabled"]) then
            local cameraX, cameraY, cameraZ = getCameraMatrix();
            local dim2, int2 = getElementDimension(localPlayer), getElementInterior(localPlayer);
            renderCache = {}

            for k,element in pairs(getElementsByType("vehicle", root, true)) do
                if isElementStreamedIn(element) and isElementOnScreen(element) then
                    if getPedOccupiedVehicle(localPlayer) ~= element then
                        if not disabledType[getVehicleType(element)] then
                            local dim1 = getElementDimension(element);
                            local int1 = getElementInterior(element);
                            if getElementAlpha(element) == 255 and dim1 == dim2 and int1 == int2 then
                                local worldX, worldY, worldZ = getElementPosition(element);
                                local line = isLineOfSightClear(cameraX, cameraY, cameraZ, worldX, worldY, worldZ, true, false, false, true, false, false, false, localPlayer);

                                if line then
                                    local distance = math.sqrt((cameraX - worldX) ^ 2 + (cameraY - worldY) ^ 2 + (cameraZ - worldZ) ^ 2) - 3;

                                    if getVehiclePlateText(element) and not element:getData("cloned") then
                                        --if distance <= maxDistance then
                                        local size = 1 - (distance / maxDistance);
                                        renderCache[element] = {
                                            ["vehID"] = getElementData(element, "veh >> id"),
                                            ["cloned"] = getElementData(element, "cloned"),
                                            ["distance"] = distance,
                                            ["plateText"] = getVehiclePlateText(element),
                                            --["length"] = dxGetTextWidth(getVehiclePlateText(element), size, font) + 15 * size,
                                        }
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end, 150, 0
)

function renderVehiclePlate()
    if not getElementData(localPlayer, "hudVisible") then 
        return; 
    end

    local font = exports['cr_fonts']:getFont("BrushScriptMT", 6)
    local font2 = exports['cr_fonts']:getFont("ChauPhilomeneOne", 18)

    local cameraX, cameraY, cameraZ = getCameraMatrix();
    
    --local dim2, int2 = getElementDimension(localPlayer), getElementInterior(localPlayer);
    
    --local a = 0
    for element, value in pairs(renderCache) do
        --a = a +1
        local distance = value["distance"]
        if distance <= maxDistance then
            local boneX, boneY, boneZ = getElementPosition(element);
            local size = 1 - (distance / maxDistance);
            local screenX, screenY = getScreenFromWorldPosition(boneX, boneY, boneZ + (1.5));

            if screenX and screenY then
                local alpha = interpolateBetween(0,0,0,255, 0, 0, size, "Linear")
                local plateText = value["plateText"]
                --local x = value["length"]
                --local y = 25 * size;

                --dxDrawRectangle(screenX - x/2, screenY - y / 2, x, y, tocolor(51,51,51,alpha * 0.8));
                local w, h = 100 * size, 45 * size
                exports['cr_dx']:dxDrawImageAsTexture(screenX - w/2, screenY - h/2, w, h, ':cr_vehicle/assets/images/bg.png', 0, 0, 0, tocolor(242, 242, 242, alpha * 0.6)) 
                dxDrawText(plateText, screenX, screenY, screenX, screenY + (4 * size), tocolor(12,70,148,alpha), size, font2, "center", "center");
                dxDrawText('Red County', screenX, screenY - h/2 + (2 * size), screenX, screenY + h/2, tocolor(252,0,0,alpha), size, font, "center", "top");
            end
        end
    end
    --output
end