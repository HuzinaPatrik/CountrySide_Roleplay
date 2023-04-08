local models = {
    --{source = "files/asd", modelID},
    --{"files/cj_flag1", 2047},
}

local textures = {
	-- eCola --
    "cj_sprunk_front",
	-- eCola --
	
    "sprunk_postersign1",
    "chillidog_sign",
	"coronastar",
    "iceysign",
    "iceyside",
    --"redwhite_stripe",
    --"cj_painting1",
    "bigsprunkcan",
    "sprunk_temp",
    --"ah_picture2",
    "bloodpool_64",
    "bubbles",
    "fireball6",
    "smoke",
    "smokeII_3",
    "vehiclelights128",
    "vehiclelightson128",
    "vehicleshatter128",
    "lamp_shad_64",
    "headlight",
    "headlight1",
    --"collisionsmoke",
    "particleskid",
    "carparkwall1_256",
    "cj_slatedwood2",
    --"notice02",
	"cj_flag1",
	
	--Edison--
	--"shortsMOB",
	--"hmogar",
	--"WMYBE",
	--"sweet",
	
	--WILEY STORE--
	--"sw_genstore2"
	
    --"ws_airsecurity",
    --"bridge_egg_sfw",
    --"carwash_sign2",
    --"monitor",
    "book",	
}

local protect = {
    --["cj_painting1"] = true,
}

addEventHandler("onClientResourceStart", resourceRoot,
    function()
        for k,v in pairs(models) do
            local source, id = unpack(v)
            txd = engineLoadTXD(source .. ".txd")
            engineImportTXD(txd, id)
        end
        
        for k,v in pairs(textures) do
            texElement = dxCreateTexture("files/"..v..".png", textureQuality or "dxt1")
            local protected = protect[v]
            if protected then
                fileDelete("files/"..v..".png")
            end    
            local shadElement = dxCreateShader("files/replace.fx", 0, 0, false, "all")
            engineApplyShaderToWorldTexture(shadElement, v)
            dxSetShaderValue(shadElement, "gTexture", texElement)
        end
    end
)

