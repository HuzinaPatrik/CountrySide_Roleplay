local shader = DxShader("files/texchanger.fx")
local texture = DxTexture("files/transparent.png")
dxSetShaderValue(shader, "gTexture", texture)

addEventHandler("onClientResourceStart", resourceRoot,
    function()
        shader:applyToWorldTexture("shad_car")
        shader:applyToWorldTexture("shad_ped")
    end
)