local screenWidth, screenHeight = guiGetScreenSize()
local bitDepth = 32 -- between 1 and 64
local outlineStrength = 0.5 -- between 0 and 1 // higher amount will decrease outline strenght
local myScreenSource = dxCreateScreenSource(screenWidth, screenHeight)

addEventHandler("onClientResourceStart", resourceRoot,
    function()
        if getVersion().sortable < "1.3.1" then
            return
        else
            toonShader, toonTec = dxCreateShader("shaders/toonShader.fx")
        end
    end
)

function startShader()
    addEventHandler("onClientPreRender", root, shaderDrawn, true, "low-5")
end

function stopShader()
    removeEventHandler("onClientPreRender", root, shaderDrawn)
end

function shaderDrawn()
    if (toonShader) then
        dxUpdateScreenSource(myScreenSource)
        
        dxSetShaderValue(toonShader, "ScreenSource", myScreenSource)
		dxSetShaderValue(toonShader, "ScreenWidth", screenWidth)
		dxSetShaderValue(toonShader, "ScreenHeight", screenHeight)
        dxSetShaderValue(toonShader, "BitDepth", bitDepth)
		dxSetShaderValue(toonShader, "OutlineStrength", outlineStrength)

        dxDrawImage(0, 0, screenWidth, screenHeight, toonShader)
    end
end

addEventHandler("onClientResourceStop", resourceRoot,
    function()
        if (toonShader) then
            destroyElement(toonShader)
            toonShader = nil
        end
    end
)