lightObjects = {
	[1350] = {5, 4, -6, 4, -1},
	[1351] = {5, 4, -6, 4, -1},
	[1352] = {5, 4, -6, 4, -1},
	[3516] = {13, 4, -3, 11, -1},
}

function getRoundedRotation(rotation)
	local rot = math.floor(rotation)
	rot = 360 - rot
	if rot >= 41 and rot <= 139 then
		return 270
	elseif rot >= 140 and rot <= 220 then
		return 180
	elseif rot >= 221 and rot <= 319 then
		return 90
	elseif rot <= 40 or rot >= 320 then
		return 0
	end
end