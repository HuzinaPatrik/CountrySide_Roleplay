--
-- c_RTPool3.lua
--

scx, scy = guiGetScreenSize ()

-----------------------------------------------------------------------------------
-- Pool of render targets
-----------------------------------------------------------------------------------
RTPool3 = {}
RTPool3.list = {}

function RTPool3.frameStart()
	for rt,info in pairs(RTPool3.list) do
		info.bInUse = false
	end
end

function RTPool3.GetUnused( sx, sy )
	-- Find unused existing
	for rt,info in pairs(RTPool3.list) do
		if not info.bInUse and info.sx == sx and info.sy == sy then
			info.bInUse = true
			return rt
		end
	end
	-- Add new
	local rt = dxCreateRenderTarget( sx, sy )
	if rt then
		RTPool3.list[rt] = { bInUse = true, sx = sx, sy = sy }
	end
	return rt
end

function RTPool3.clear()
	for rt,info in pairs(RTPool3.list) do
		destroyElement(rt)
	end
	RTPool3.list = {}
end
