local myShader, textureVol, textureCube, updateTimer, defaultShader1, defaultTexture1, defaultShader2, defaultTexture2

function startWaterShader()
	if isElement(defaultShader1) then 
		defaultShader1:destroy()
	end 

	if isElement(defaultTexture1) then 
		defaultTexture1:destroy()
	end 

	if isElement(defaultShader2) then 
		defaultShader2:destroy()
	end 

	if isElement(defaultTexture2) then 
		defaultTexture2:destroy()
	end 

	myShader, tec = dxCreateShader ( "shaders/water/water.fx" )

	textureVol = dxCreateTexture ( "shaders/water/images/smallnoise3d.dds" );
	textureCube = dxCreateTexture ( "shaders/water/images/cube_env256.dds" );
	dxSetShaderValue ( myShader, "sRandomTexture", textureVol );
	dxSetShaderValue ( myShader, "sReflectionTexture", textureCube );

	engineApplyShaderToWorldTexture ( myShader, "waterclear256" )

	if isTimer(updateTimer) then killTimer(updateTimer) end
	updateTimer = setTimer(	
		function()
			if myShader then
				local r,g,b,a = getWaterColor()
				dxSetShaderValue ( myShader, "sWaterColor", r/255, g/255, b/255, a/255 );
			end
		end,500,0 
	)
end

function stopWaterShader()
	if isElement(myShader) then 
		myShader:destroy()
	end 

	if isElement(textureVol) then 
		textureVol:destroy()
	end 

	if isElement(textureCube) then 
		textureCube:destroy()
	end 

	if isTimer(updateTimer) then killTimer(updateTimer) end

	defaultShader1 = dxCreateShader("shaders/water/files/texturechanger.fx")
	defaultTexture1 = dxCreateTexture("shaders/water/files/waterclear256.png")
	dxSetShaderValue(defaultShader1, "gTexture", defaultTexture1)
	engineApplyShaderToWorldTexture(defaultShader1, "waterclear256")
	
	defaultShader2 = dxCreateShader("shaders/water/files/texturechanger.fx")
	defaultTexture2 = dxCreateTexture("shaders/water/files/waterwake.png")
	dxSetShaderValue(defaultShader2, "gTexture", defaultTexture2)
	engineApplyShaderToWorldTexture(defaultShader2, "waterwake")
end 