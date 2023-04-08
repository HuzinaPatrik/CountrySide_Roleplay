screenX, screenY = guiGetScreenSize()

local colorizePed = {255 / 255, 59 / 255, 59 / 255, 1} -- rgba colors 
local specularPower = 1.3
local effectMaxDistance = 10
local isPostAura = true
local scx, scy = guiGetScreenSize ()
local effectOn = nil
local myRT = nil
local myShader = nil
local isMRTEnabled = false
local outlineEffect = {}
local PWTimerUpdate = 110

--createElementOutlineEffect(clickedElement, true)
--destroyElementOutlineEffect(selectedElement)

function enableOutline(isMRT)
	if isMRT and isPostAura then 
		myRT = dxCreateRenderTarget(scx, scy, true)
		myShader = dxCreateShader("fx/edge.fx")
		if not myRT or not myShader then 
			isMRTEnabled = false
			return
		else
			dxSetShaderValue(myShader, "sTex0", myRT)
			dxSetShaderValue(myShader, "sRes", scx, scy)
			isMRTEnabled = true
		end
	else
		isMRTEnabled = false
	end
	pwEffectEnabled = true
end

function disableOutline()
	if isElement(myRT) then
		destroyElement(myRT)
	end
    if isElement(myShader) then
        destroyElement(myShader)
    end

    myRT = nil
    myShader = nil
end

function createElementOutlineEffect(element, isMRT)
    if not myRT or not myShader then
        enableOutline(isMRT)
    end

    effectOn = true
    if not outlineEffect[element] then
		if isMRT then 
			outlineEffect[element] = dxCreateShader("fx/wall_mrt.fx", 1, 0, true, "all")
		else
			outlineEffect[element] = dxCreateShader("fx/wall.fx", 1, 0, true, "all")
		end

		if not outlineEffect[element] then 
            return false
		else
			if myRT then
				dxSetShaderValue (outlineEffect[element], "secondRT", myRT)
			end
			dxSetShaderValue(outlineEffect[element], "sColorizePed",colorizePed)
			dxSetShaderValue(outlineEffect[element], "sSpecularPower",specularPower)
			engineApplyShaderToWorldTexture ( outlineEffect[element], "*" , element )
			engineRemoveShaderFromWorldTexture(outlineEffect[element],"muzzle_texture*", element)
			if not isMRT then
				if getElementAlpha(element)==255 then setElementAlpha(element, 254) end
			end
		    return true
		end
    end
end

function destroyElementOutlineEffect(element)
    if outlineEffect[element] then
		destroyElement(outlineEffect[element])
		outlineEffect[element] = nil
        disableOutline()
	end
end

addEventHandler( "onClientPreRender", root,
    function()
		if not pwEffectEnabled or not isMRTEnabled or not effectOn then return end
		dxSetRenderTarget( myRT, true )
		dxSetRenderTarget()
    end
, true, "high" )


addEventHandler( "onClientHUDRender", root,
    function()
		if not pwEffectEnabled or not isMRTEnabled or not effectOn or not myShader then return end

		dxDrawImage( 0, 0, scx, scy, myShader)
    end
)

function switchOutline(pwOn, isMRT)
	if pwOn then
		enableOutline(isMRT)
	else
		disableOutline()
	end
end

addEvent("switchOutline", true)
addEventHandler("switchOutline", resourceRoot, switchOutline)