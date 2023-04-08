--
-- c_bloom.lua
--
local orderPriority = "-1.0"	-- The lower this number, the later the effect is applied
local myScreenSource, blurHShader, tecName, blurVShader, brightPassShader, addBlendShader, effectParts, bAllValid, bEffectEnabled, bAllValid
local Settings = {}
Settings.var = {}

---------------------------------
-- Settings for effect
---------------------------------
local function setEffectVariables()
    local v = Settings.var
    -- Bloom
    v.cutoff = 0.08
    v.power = 1.88
	v.blur = 0.9
    v.bloom = 1.7
    v.blendR = 204
    v.blendG = 153
    v.blendB = 130
    v.blendA = 100

	-- Debugging
    v.PreviewEnable=0
    v.PreviewPosY=0
    v.PreviewPosX=100
    v.PreviewSize=70
end

-----------------------------------------------------------------------------------
-- Apply the different stages
-----------------------------------------------------------------------------------
local function applyDownsample( Src, amount )
	if not Src then return nil end
	amount = amount or 2
	local mx,my = dxGetMaterialSize( Src )
	mx = mx / amount
	my = my / amount
	local newRT = RTPool2.GetUnused(mx,my)
	if not newRT then return nil end
	dxSetRenderTarget( newRT )
	dxDrawImage( 0, 0, mx, my, Src )
	DebugResults2.addItem( newRT, "applyDownsample" )
	return newRT
end

local function applyGBlurH( Src, bloom, blur )
	if not Src then return nil end
	local mx,my = dxGetMaterialSize( Src )
	local newRT = RTPool2.GetUnused(mx,my)
	if not newRT then return nil end
	dxSetRenderTarget( newRT, true ) 
	dxSetShaderValue( blurHShader, "TEX0", Src )
	dxSetShaderValue( blurHShader, "TEX0SIZE", mx,my )
	dxSetShaderValue( blurHShader, "BLOOM", bloom )
	dxSetShaderValue( blurHShader, "BLUR", blur )
	dxDrawImage( 0, 0, mx, my, blurHShader )
	DebugResults2.addItem( newRT, "applyGBlurH" )
	return newRT
end

local function applyGBlurV( Src, bloom, blur )
	if not Src then return nil end
	local mx,my = dxGetMaterialSize( Src )
	local newRT = RTPool2.GetUnused(mx,my)
	if not newRT then return nil end
	dxSetRenderTarget( newRT, true ) 
	dxSetShaderValue( blurVShader, "TEX0", Src )
	dxSetShaderValue( blurVShader, "TEX0SIZE", mx,my )
	dxSetShaderValue( blurVShader, "BLOOM", bloom )
	dxSetShaderValue( blurVShader, "BLUR", blur )
	dxDrawImage( 0, 0, mx,my, blurVShader )
	DebugResults2.addItem( newRT, "applyGBlurV" )
	return newRT
end

local function applyBrightPass( Src, cutoff, power )
	if not Src then return nil end
	local mx,my = dxGetMaterialSize( Src )
	local newRT = RTPool2.GetUnused(mx,my)
	if not newRT then return nil end
	dxSetRenderTarget( newRT, true ) 
	dxSetShaderValue( brightPassShader, "TEX0", Src )
	dxSetShaderValue( brightPassShader, "CUTOFF", cutoff )
	dxSetShaderValue( brightPassShader, "POWER", power )
	dxDrawImage( 0, 0, mx,my, brightPassShader )
	DebugResults2.addItem( newRT, "applyBrightPass" )
	return newRT
end

-----------------------------------------------------------------------------------
-- onClientHUDRender
-----------------------------------------------------------------------------------
local function drawnBloom()
	if not bAllValid or not Settings.var then return end
	local v = Settings.var	
		
	-- Reset render target pool
	RTPool2.frameStart()
	DebugResults2.frameStart()
	-- Update screen
	dxUpdateScreenSource( myScreenSource, true )
		
	-- Start with screen
	local current = myScreenSource

	-- Apply all the effects, bouncing from one render target to another
	current = applyBrightPass( current, v.cutoff, v.power )
	current = applyDownsample( current )
	current = applyDownsample( current )
	current = applyGBlurH( current, v.bloom, v.blur )
	current = applyGBlurV( current, v.bloom, v.blur )

	-- When we're done, turn the render target back to default
	dxSetRenderTarget()

	-- Mix result onto the screen using 'add' rather than 'alpha blend'
	if current then
		dxSetShaderValue( addBlendShader, "TEX0", current )
		local col = tocolor(v.blendR, v.blendG, v.blendB, v.blendA)
		dxDrawImage( 0, 0, scx, scy, addBlendShader, 0,0,0, col )
	end
	-- Debug stuff
	if v.PreviewEnable > 0.5 then
		DebugResults2.drawItems ( v.PreviewSize, v.PreviewPosX, v.PreviewPosY )
	end
end

----------------------------------------------------------------
-- Avoid errors messages when memory is low
----------------------------------------------------------------
_dxDrawImage = dxDrawImage
local function xdxDrawImage(posX, posY, width, height, image, ... )
	if not image then return false end
	return _dxDrawImage( posX, posY, width, height, image, ... )
end

----------------------------------------------------------------
-- enableBloom
----------------------------------------------------------------

function enableBloom()
	if bEffectEnabled then return end
	-- Create things
	myScreenSource = dxCreateScreenSource( scx/2, scy/2 )
	blurHShader,tecName = dxCreateShader( "shaders/bloom/fx/blurH.fx" )
	blurVShader,tecName = dxCreateShader( "shaders/bloom/fx/blurV.fx" )
	brightPassShader,tecName = dxCreateShader( "shaders/bloom/fx/brightPass.fx" )
    addBlendShader,tecName = dxCreateShader( "shaders/bloom/fx/addBlend.fx" )

	-- Get list of all elements used
	effectParts = {
						myScreenSource,
						blurVShader,
						blurHShader,
						brightPassShader,
						addBlendShader,
					}

	-- Check list of all elements used
	bAllValid = true
	for _,part in ipairs(effectParts) do
		bAllValid = part and bAllValid
	end
	
	setEffectVariables ()
	bEffectEnabled = true
	
	if not bAllValid then
		disableBloom()
	end	

	addEventHandler("onClientHUDRender", root, drawnBloom, true, "low" .. orderPriority)
end

-----------------------------------------------------------------------------------
-- disableBloom
-----------------------------------------------------------------------------------
function disableBloom()
	if not bEffectEnabled then return end
	-- Destroy all shaders
	for _,part in ipairs(effectParts) do
		if part then
			destroyElement( part )
		end
	end
	effectParts = {}
	bAllValid = false
	RTPool2.clear()
	
	-- Flag effect as stopped
	bEffectEnabled = false

	removeEventHandler("onClientHUDRender", root, drawnBloom)
end